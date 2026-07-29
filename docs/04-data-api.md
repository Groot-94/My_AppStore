# 04. 데이터 · iTunes API

애플 공개 API 3종을 사용. **인증/API 키 불필요**. 기본 국가 `kr`, 언어 `ko_kr`.

## 1) iTunes Search API — 키워드 검색

```
GET https://itunes.apple.com/search
  ?term={검색어}
  &country=kr
  &media=software        # 앱만
  &entity=software       # iPhone 앱 (iPadSoftware 별도)
  &limit=25
  &lang=ko_kr
```

응답: `{ resultCount, results: [App...] }`

## 2) iTunes Lookup API — ID로 상세

```
GET https://itunes.apple.com/lookup?id={trackId}&country=kr&lang=ko_kr
GET https://itunes.apple.com/lookup?id={id1},{id2},...   # 복수 조회
```

응답 형태는 Search와 동일(`results` 배열).

## 3) Apple Marketing RSS — 인기 차트

```
GET https://rss.applemarketingtools.com/api/v2/kr/apps/{feed}/{limit}/apps.json
  feed  = top-free | top-paid
  limit = 10 | 25 | 50 | 100
```

응답: `{ feed: { title, results: [ {id, name, artistName, artworkUrl100, genres:[{genreId, name, url}], url} ] } }`

> 실응답 주의: RSS는 301 리다이렉트로 응답(URLSession 자동 처리). `genres`가 **빈 배열로 오는 경우가 있음**(top-free에서 관찰) — 디코더에서 기본 `[]` 처리.

> RSS 항목은 **필드가 적다**(스크린샷/설명/평점 없음). 상세가 필요하면 `id`로 **Lookup**을 이어서 호출한다(차트 → id 수집 → lookup 배치).
> RSS에 게임 전용 피드는 없다 — 게임 차트는 `genres`에 "Games" 포함 항목을 필터해 만든다(→ [05-features/games](05-features/games.md)).

## 주요 응답 필드 (Search/Lookup App 객체)

| 필드 | 용도 |
|------|------|
| `trackId` | 앱 고유 ID (엔티티 id) |
| `trackName` | 앱 이름 |
| `artistName` / `sellerName` | 개발사 |
| `primaryGenreName`, `genres[]` | 카테고리 — Search/Lookup의 `genres`는 **문자열 배열**(RSS는 객체 배열, 별도 DTO) |
| `artworkUrl512` / `artworkUrl100` / `artworkUrl60` | 아이콘 |
| `screenshotUrls[]`, `ipadScreenshotUrls[]` | 스크린샷 |
| `description`, `releaseNotes` | 설명 / 새 소식 |
| `averageUserRating`, `userRatingCount` | 평점 / 리뷰 수 |
| `formattedPrice`, `price`, `currency` | 가격 표시 |
| `version`, `currentVersionReleaseDate` | 버전 / 갱신일 |
| `contentAdvisoryRating` | 연령 등급 |
| `fileSizeBytes`, `minimumOsVersion` | 크기 / 최소 OS — `fileSizeBytes`는 **문자열**로 반환됨 |
| `languageCodesISO2A[]` | 지원 언어 |

## 공용 DTO · 클라이언트 (ITunesKit 소유)

iTunes 응답 스키마는 전 피처 동일하므로 **디코딩(DTO)과 API 호출만 공용화**한다. 엔티티가 아니라 "원본 응답의 타입 표현"이다.

```swift
// ITunesKit — DTO는 응답 스키마 그대로. 화면 개념 없음.
public struct ITunesSearchResponse: Decodable, Sendable {
    public let resultCount: Int
    public let results: [ITunesAppDTO]
}
public struct ITunesAppDTO: Decodable, Sendable { /* 위 필드 표의 원본 필드들 — 실응답에서 자주 누락되므로 대부분 옵셔널 */ }
public struct RSSEntryDTO: Decodable, Sendable {
    public let id: String
    public let name: String
    public let artistName: String
    public let artworkUrl100: String
    public let genres: [RSSGenreDTO]
}

public enum ChartFeed: String, Sendable {
    case topFree = "top-free"
    case topPaid = "top-paid"
}

public protocol ITunesClient: Sendable {
    func search(term: String, genreID: Int?, limit: Int) async throws -> [ITunesAppDTO]
    func lookup(ids: [Int]) async throws -> [ITunesAppDTO]
    func chart(_ feed: ChartFeed, limit: Int) async throws -> [RSSEntryDTO]
}
```

## 피처별 엔티티 (각 피처 Domain 소유 — 공용 엔티티 없음)

각 화면이 **필요한 필드만** 갖는다. 엔티티 정의는 피처 스펙 문서에 있고, 여기서는 원천 필드 대응만 요약한다.

| 피처 | 엔티티 | 주요 필드 (DTO 원천) |
|------|------|------|
| Search | `SearchResultItem` | id, name, sellerName, genre, iconURL(artworkUrl100), rating, ratingCount, priceText |
| AppDetail | `AppDetail` | 풀 스펙 — 스크린샷/설명/releaseNotes/버전/크기/언어/연령 등급 등 전 필드 |
| Today | `TodayCard` + `TodayAppSummary` | 카드 메타(정적 JSON) + id, name, genre, iconURL, priceText |
| Apps·Games | `FeaturedApp` / `ChartItem` / `Category` | rank(배열 순서+1), id, name, artistName, artworkURL, genre / Category는 정적 목록 |
| Arcade | `ArcadeGame` | id, name, genre, artworkURL (히어로 배너는 정적) |
| SeeAll | `SeeAllItem` | rank, id, name, artistName, artworkURL, genre |

## 매핑 규칙 (각 피처의 Data/Mapper)

- 각 피처 Mapper가 **ITunesKit DTO → 자기 엔티티** 변환. 매퍼는 얇게, 피처당 파일 1~2개.
- 안전 기본값 컨벤션(전 피처 공통): `averageUserRating` 없으면 0, `formattedPrice` 없으면 "무료", artwork URL 파싱 실패 시 nil(플레이스홀더 표시).
- RSS 항목의 `rank`는 배열 인덱스+1로 부여.

### 확정된 결정
- **DTO/클라이언트**: `ITunesKit`에 집약. **엔티티**: 피처 소유(공용 Domain 모듈 없음) — 근거는 [02-architecture](02-architecture.md).
- **국가/언어 상수**: `CoreKit`에 `StoreConfig(country:lang:)` 두고 주입.
- **게임 차트**: RSS + `genres` 필터. **추천 캐러셀**(Apps/Games): 정적 큐레이션 ID + Lookup 배치(Today/Arcade와 동일 패턴).

## 에러 처리

- 네트워크 실패/디코딩 실패/빈 결과를 구분: `NetworkError`(Networking) → 피처에서 사용자용 메시지로 변환.
- 빈 결과(`resultCount == 0`)는 에러가 아니라 "결과 없음" 상태로 표현.
- Lookup 응답 캐시는 AppDetail 피처의 Repository가 `Persistence.Cache`로 수행(캐시 우선, miss 시 API).
