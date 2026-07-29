import UIKit
import Persistence

/// 스크린샷 가로 페이저(AppDetail 헤더용). 엔티티 비의존 — URL 배열 입력.
public final class ScreenshotPager: UIView {
    private let collectionView: UICollectionView
    private var urls: [URL] = []
    private var loader: ImageLoading?

    public init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ScreenshotCell.self, forCellWithReuseIdentifier: ScreenshotCell.reuseID)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    /// - Parameters:
    ///   - urls: 스크린샷 URL 배열(빈 배열이면 표시할 것 없음).
    ///   - loader: 이미지 로더.
    public func configure(urls: [URL], loader: ImageLoading?) {
        self.urls = urls
        self.loader = loader
        collectionView.reloadData()
    }
}

extension ScreenshotPager: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        urls.count
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ScreenshotCell.reuseID,
            for: indexPath
        )
        if let cell = cell as? ScreenshotCell {
            if let loader { cell.configure(loader: loader) }
            cell.setImage(url: urls[indexPath.item])
        }
        return cell
    }
}

extension ScreenshotPager: UICollectionViewDelegateFlowLayout {
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let height = collectionView.bounds.height
        // 대략 9:16 세로 스크린샷 비율.
        return CGSize(width: height * 0.56, height: height)
    }
}

/// 스크린샷 셀(내부 전용).
final class ScreenshotCell: UICollectionViewCell {
    static let reuseID = "ScreenshotCell"
    private let imageView = AppIconView(cornerRadius: 16)

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(loader: ImageLoading) { imageView.configure(loader: loader) }
    func setImage(url: URL?) { imageView.setImage(url: url) }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.setImage(url: nil)
    }
}
