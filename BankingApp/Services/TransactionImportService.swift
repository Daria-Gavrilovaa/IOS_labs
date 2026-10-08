//
//  TransactionImportService.swift
//  BankingApp
//
//  Created by MAC on 27.09.26.
//

import Foundation
import Combine

enum ImportError: LocalizedError {
    case invalidFormat(String)
    case emptyFile
    case decodingFailed(Error)
    case allRowsRejected(Int)

    var errorDescription: String? {
        switch self {
        case .invalidFormat(let s):   return "Неверный формат: \(s)"
        case .emptyFile:              return "Файл пустой"
        case .decodingFailed(let e):  return "Ошибка чтения: \(e.localizedDescription)"
        case .allRowsRejected(let n): return "Все \(n) записей отклонены при валидации"
        }
    }
}

struct ImportResult {
    let transactions: [TransactionDTO]
    let rejected: [(row: Int, reason: String)]
}

protocol TransactionImportProtocol {
    func importFile(at url: URL) -> AnyPublisher<ImportResult, ImportError>
}

final class TransactionImportService: TransactionImportProtocol {

    private let isoFormatter: ISO8601DateFormatter
    private let isoFormatterNoFraction: ISO8601DateFormatter

    init() {
        let f1 = ISO8601DateFormatter()
        f1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter = f1

        let f2 = ISO8601DateFormatter()
        f2.formatOptions = [.withInternetDateTime]
        isoFormatterNoFraction = f2
    }

    func importFile(at url: URL) -> AnyPublisher<ImportResult, ImportError> {
        Deferred { [weak self] () -> Future<ImportResult, ImportError> in
            Future { promise in
                guard let self = self else {
                    promise(.failure(.emptyFile)); return
                }

                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        let needsScope = url.startAccessingSecurityScopedResource()
                        defer { if needsScope { url.stopAccessingSecurityScopedResource() } }

                        let data = try Data(contentsOf: url)
                        guard !data.isEmpty else {
                            promise(.failure(.emptyFile)); return
                        }

                        let dtos: [TransactionDTO]
                        do {
                            dtos = try JSONDecoder().decode([TransactionDTO].self, from: data)
                        } catch {
                            promise(.failure(.decodingFailed(error))); return
                        }

                        var valid: [TransactionDTO] = []
                        var rejected: [(Int, String)] = []

                        for (idx, dto) in dtos.enumerated() {
                            if let reason = self.validate(dto) {
                                rejected.append((idx, reason))
                            } else {
                                valid.append(dto)
                            }
                        }

                        if valid.isEmpty {
                            promise(.failure(.allRowsRejected(dtos.count))); return
                        }

                        let result = ImportResult(
                            transactions: valid,
                            rejected: rejected.map { (row: $0.0, reason: $0.1) }
                        )
                        promise(.success(result))

                    } catch {
                        promise(.failure(.decodingFailed(error)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func validate(_ dto: TransactionDTO) -> String? {
        guard !dto.currency.isEmpty, dto.currency.count == 3 else {
            return "currency должна быть 3-буквенным кодом"
        }
        guard dto.amount >= 0 else {
            return "amount не может быть отрицательным"
        }
        guard !dto.merchant.trimmingCharacters(in: .whitespaces).isEmpty else {
            return "merchant пустой"
        }
        guard dto.mcc.count == 4, dto.mcc.allSatisfy({ $0.isNumber }) else {
            return "mcc должен быть 4-значным числом"
        }
        guard parseDate(dto.date) != nil else {
            return "date не парсится как ISO8601"
        }
        return nil
    }

    private func parseDate(_ s: String) -> Date? {
        isoFormatter.date(from: s) ?? isoFormatterNoFraction.date(from: s)
    }
}
