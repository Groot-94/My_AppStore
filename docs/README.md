# My_AppStore 설계 문서

애플 App Store 클론(iOS)의 **개발 착수 전 설계 문서 세트**. 이 문서들을 먼저 검토·확정한 뒤 코드 작성을 시작한다.

## 문서 목록

| 문서 | 내용 |
|------|------|
| [01-overview](01-overview.md) | 프로젝트 개요, 목표, 범위(In/Out of Scope) |
| [02-architecture](02-architecture.md) | 모듈 그래프, 의존 규칙, 클린 아키텍처, DI/라우팅 전략 |
| [03-modules](03-modules.md) | 모듈별 책임·공개 API·의존 관계 |
| [04-data-api](04-data-api.md) | iTunes Search/Lookup/RSS API 명세, 공용 DTO·피처별 엔티티 매핑 |
| [05-features/](05-features/) | 피처별 상세 스펙 + UI 스케치·UI 흐름 (Search, Today, Apps, Games, Arcade, AppDetail, SeeAll) |
| [06-roadmap](06-roadmap.md) | 마일스톤·개발 순서 |
| [07-conventions](07-conventions.md) | 코딩/네이밍/테스트/모듈 컨벤션 |
| [08-flow-diagrams](08-flow-diagrams.md) | 모듈 그래프·계층 데이터 흐름·피처별 런타임 흐름 |

## 확정된 핵심 결정 (요약)

- **플랫폼**: iOS 17+ 네이티브, Swift 6.2
- **UI**: UIKit 먼저 → SwiftUI 나중에. 공통 로직은 UI 비의존 모듈로 재사용
- **아키텍처**: 풀 모듈러 — 피처당 `Interface`/`Implementation`/`Testing`/`Example` 타깃. 피처 내부는 클린 아키텍처(폴더 구분). 피처 간 연결은 상대 피처의 `*Interface`(Builder 계약) 주입
- **공용 Domain 없음**: 엔티티·UseCase·Repository는 피처가 소유. iTunes 응답 디코딩(DTO)·호출만 `ITunesKit`으로 공용화
- **공통 모듈(Core 5)**: CoreKit / Networking / Persistence / ITunesKit / DesignSystem
- **데이터**: 실제 iTunes API (Search / Lookup / Apple Marketing RSS), 인증 불필요
- **프로젝트 생성**: Tuist (`Project.swift`/`Workspace.swift` → `.xcodeproj`)

## 검토 체크리스트

- [ ] 모듈 경계와 의존 방향이 순환 없이 성립하는가
- [ ] 피처 간 결합이 프로토콜/DI로만 이뤄지는가 (구현 직접 참조 없음)
- [ ] UIKit/SwiftUI 교체 시 피처의 Domain/Data가 영향받지 않는가
- [ ] iTunes API로 각 화면에 필요한 데이터가 모두 확보되는가
- [ ] 피처 스펙의 화면·상태·에러 처리가 실제 App Store와 부합하는가
- [ ] 로드맵의 첫 마일스톤이 "빌드/실행 검증 가능한 골격"인가
