import UIKit

/// 공통 색상 팔레트. 다크모드 대응을 위해 시스템/시맨틱 컬러 우선.
public enum AppColors {
    public static let background: UIColor = .systemBackground
    public static let secondaryBackground: UIColor = .secondarySystemBackground
    public static let groupedBackground: UIColor = .systemGroupedBackground

    public static let label: UIColor = .label
    public static let secondaryLabel: UIColor = .secondaryLabel
    public static let tertiaryLabel: UIColor = .tertiaryLabel

    public static let separator: UIColor = .separator
    public static let accent: UIColor = .systemBlue
    public static let ratingStar: UIColor = .systemGray

    /// 아이콘 플레이스홀더 배경.
    public static let placeholder: UIColor = .tertiarySystemFill
}
