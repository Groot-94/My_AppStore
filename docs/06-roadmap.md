# 06. 로드맵

문서 검토 완료 후 진행할 개발 순서. 각 마일스톤은 **빌드/실행 검증 가능한 단위**.

## M0 — 프로젝트 골격 (첫 목표)
- Tuist `Project.swift`/`Workspace.swift` + `ProjectDescriptionHelpers`의 모듈 팩토리 작성: Core 5 + Feature(피처당 Interface+Impl) + AppUIKit.
- 각 모듈 빈 뼈대(placeholder 타입) + `*Interface` 계약 + 의존 그래프 연결.
- `tuist generate` 성공, AppUIKit이 빈 TabBar로 **시뮬레이터 실행**까지 확인.
- `tuist graph`로 순환/역참조 없음 검증(CI 등록).

## M1 — Core 구현
- `CoreKit`: `DIContainer`/`DIResolver`, `StoreConfig`, 공통 에러/로거 (UI 비의존).
- `Networking`: `NetworkClient` + 요청 빌더/디코딩/에러 (iTunes를 모르는 범용 계층).
- `ITunesKit`: 공용 DTO(`ITunesAppDTO`/`RSSEntryDTO`) + `ITunesClient`(search/lookup/chart) + 엔드포인트.
- `Persistence`: 이미지 로더 + 응답/이미지 캐시 + `RecentSearchStore`.
- `DesignSystem`: 색/폰트 + `AppRowCell`, `AppIconView`, `RatingView`, `GetButton` + 스토어 피드 컴포넌트(엔티티 비의존 — 구성 모델 입력).

## M2 — Search 수직 슬라이스
- Search 피처(Domain/Data/Presentation) 전체 구현.
- 실제 iTunes Search로 검색→목록→(상세 자리표시자) 동작.
- DI/라우팅 최초 배선 검증.

## M3 — AppDetail
- Lookup 기반 상세 화면. Search에서 실제 이동 연결.

## M4 — Apps / Games / SeeAll
- RSS 차트 + DesignSystem 스토어 피드 컴포넌트 재사용. 캐러셀/차트/카테고리.
- `SeeAll` 피처("모두 보기") 구현 + Apps/Games에 `SeeAllBuilder` 주입.

## M5 — Today / Arcade
- 정적 큐레이션 + Lookup 하이브리드.

## M6 — 다듬기
- 이미지 캐싱/스켈레톤/에러·빈 상태, 다크모드, 접근성, 애니메이션.

## M7 — SwiftUI 버전
- `AppSwiftUI` 타깃 + 피처별 SwiftUI 뷰(ViewModel 재사용). 우선 Search/AppDetail부터.

## 테스트 병행

각 마일스톤에서 해당 범위의 테스트를 함께 작성한다(별도 마일스톤으로 미루지 않음).

- **피처 UseCase** 유닛 테스트 — Repository 목 주입. 비즈니스 규칙(트림/빈값, 필터, 부분 실패 허용)이 대상.
- **피처 Mapper** 테스트 — 고정 JSON 픽스처(ITunesKit DTO 입력). 안전 기본값 규칙(평점 0, "무료") 검증.
- **ViewModel 상태 전이** 테스트 — loading→loaded/empty/failed, Task 취소, 부분 성공.
- **테스트하지 않는 것(의도적)**: UIKit 뷰 레이아웃(스냅샷 테스트는 후속 옵션), URLSession 실통신(NetworkClient 목으로 대체), 정적 큐레이션 JSON 내용 자체.
- `*Testing` 타깃(Mock/Stub)은 Search·AppDetail부터 제공 — 타 피처 테스트가 계약(Interface) 목만으로 작성됨을 시연.
