import UIKit

/// 공통 타이포. Dynamic Type 대응 preferred font 기반.
public enum AppFont {
    public static let largeTitle: UIFont = .preferredFont(forTextStyle: .largeTitle)
    public static let title: UIFont = .preferredFont(forTextStyle: .title2)
    public static let headline: UIFont = .preferredFont(forTextStyle: .headline)
    public static let body: UIFont = .preferredFont(forTextStyle: .body)
    public static let subheadline: UIFont = .preferredFont(forTextStyle: .subheadline)
    public static let caption: UIFont = .preferredFont(forTextStyle: .caption1)

    /// 볼드 변형.
    public static func bold(_ style: UIFont.TextStyle) -> UIFont {
        let base = UIFont.preferredFont(forTextStyle: style)
        let descriptor = base.fontDescriptor.withSymbolicTraits(.traitBold) ?? base.fontDescriptor
        return UIFont(descriptor: descriptor, size: 0)
    }
}
