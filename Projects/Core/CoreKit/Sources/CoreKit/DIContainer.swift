//
//  DIContainer.swift
//  CoreKit
//
//  Created by groot on 7/29/26.
//

import Foundation

/// 의존성 획득 계약(UI 비의존). Composition Root(메인 액터)에서만 사용한다.
@MainActor
public protocol DIResolver: AnyObject {
    func resolve<T>(_ type: T.Type) -> T
}

/// 경량 서비스 로케이터형 DI 컨테이너.
///
/// 부팅 시 Composition Root(메인 액터)에서만 등록·resolve 되므로 `@MainActor` 격리로
/// 저장소 접근을 직렬화한다(수동 락 불필요, 동기 API 유지).
@MainActor
public final class DIContainer: DIResolver {
    private var factories: [ObjectIdentifier: () -> Any] = [:]

    public init() {}

    /// 타입에 대한 생성 팩토리 등록.
    /// 팩토리는 매 `resolve` 호출마다 실행된다 — 싱글턴은 인스턴스를 클로저에 캡처해 등록한다.
    public func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        factories[ObjectIdentifier(type)] = factory
    }

    /// 등록된 타입 획득. 미등록이면 프로그래머 오류로 간주.
    public func resolve<T>(_ type: T.Type) -> T {
        guard let factory = factories[ObjectIdentifier(type)], let value = factory() as? T else {
            preconditionFailure("DIContainer: \(T.self) 미등록")
        }
        return value
    }
}
