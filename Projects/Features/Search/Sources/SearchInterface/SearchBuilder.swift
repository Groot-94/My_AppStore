import UIKit

/// Search 진입 계약.
///
/// `build()` 는 UIViewController(및 내부 @MainActor ViewModel)를 생성하므로 메인 액터에서 수행한다.
@MainActor
public protocol SearchBuilder {
    func build() -> UIViewController
}
