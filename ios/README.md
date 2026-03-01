# OnmyoTCG iOS MVP (SwiftUI / MVVM)

## 前提
- Swift 5.9+
- iOS 17+
- Xcode 15+
- 本ディレクトリは既存Web資産と分離して追加したiOS MVP実装です。

## 目的
- 和風・陰陽TCG（3分）
- ガチャ（無料チケット優先、1連160、10連初回980）
- 交換所（護符交換）
- PvE勝利報酬による成長（PLv）
- デイリー配布（JST基準、月パスボーナス反映）

## 構成
- `OnmyoTCG/Models`: ドメインモデル
- `OnmyoTCG/Services`: 主要ロジック
- `OnmyoTCG/ViewModels`: 画面状態管理
- `OnmyoTCG/Views`: SwiftUI画面
- `OnmyoTCG/Resources/Data`: Bundle読み込みJSON
- `OnmyoTCGTests`: XCTest（ロジック担保）

## ローカル実行
1. XcodeでiOS App Targetに `ios/OnmyoTCG` を追加
2. `Resources/Data/*.json` をCopy Bundle Resourcesに追加
3. iOS 17 simulator で実行

## ロジック確認（CLI）
Swift Packageを利用して、Coreロジックのみテストできます。

```bash
cd ios
swift test
```

## メモ
- 重要ロジックはService層に配置
- UIはMVPとして薄く実装
