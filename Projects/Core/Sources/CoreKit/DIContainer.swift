import Foundation

/// 의존성 획득 계약 (UI 비의존).
///
/// 피처는 Core 인프라를 이 `DIResolver` 로 획득한다.
public protocol DIResolver: AnyObject {
    func resolve<T>(_ type: T.Type) -> T
}

/// 경량 서비스 로케이터형 DI 컨테이너.
///
/// Composition Root(AppUIKit)에서 Core 구현체를 등록하고, 피처가 `resolve` 로 획득한다.
/// 등록은 팩토리 클로저로 보관해 지연 생성한다.
public final class DIContainer: DIResolver {
    private var factories: [ObjectIdentifier: () -> Any] = [:]

    public init() {}

    /// 타입에 대한 생성 팩토리 등록.
    public func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        factories[ObjectIdentifier(type)] = factory
    }

    /// 등록된 타입 획득. 미등록이면 프로그래머 오류로 간주.
    public func resolve<T>(_ type: T.Type) -> T {
        guard let factory = factories[ObjectIdentifier(type)],
              let value = factory() as? T
        else {
            preconditionFailure("DIContainer: \(T.self) 미등록")
        }
        return value
    }
}
