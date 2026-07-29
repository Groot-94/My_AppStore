//
//  DIContainer.swift
//  CoreKit
//
//  Created by groot on 7/29/26.
//

import Foundation

/// 의존성 획득 계약(UI 비의존).
public protocol DIResolver: AnyObject, Sendable {
    func resolve<T>(_ type: T.Type) -> T
}

/// 경량 서비스 로케이터형 DI 컨테이너.
///
/// 저장소를 `NSLock` 으로 보호하므로 `@unchecked Sendable`. 팩토리 클로저는 `@Sendable`
/// 로 제한된다(등록 값은 대부분 Sendable 서비스이거나 부팅 시점 UI 객체).
public final class DIContainer: DIResolver, @unchecked Sendable {
    private let lock = NSLock()
    private var factories: [ObjectIdentifier: @Sendable () -> Any] = [:]

    public init() {}

    /// 타입에 대한 생성 팩토리 등록.
    public func register<T>(_ type: T.Type, factory: @escaping @Sendable () -> T) {
        lock.lock()
        defer { lock.unlock() }
        factories[ObjectIdentifier(type)] = factory
    }

    /// 등록된 타입 획득. 미등록이면 프로그래머 오류로 간주.
    public func resolve<T>(_ type: T.Type) -> T {
        lock.lock()
        let factory = factories[ObjectIdentifier(type)]
        lock.unlock()

        guard let factory, let value = factory() as? T else {
            preconditionFailure("DIContainer: \(T.self) 미등록")
        }
        return value
    }
}
