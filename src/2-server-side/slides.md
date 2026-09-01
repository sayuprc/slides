---
theme: neversink
addons:
  - slidev-addon-shared
title: クライアントの知らないサーバーの世界 〜共有状態と共有実行環境〜
author: 白湯/sayuprc
slide_info: false
color: sky-light
---

# クライアントの知らない<br>サーバーの世界

---
color: sky-light
---

# 今日のゴール

- サーバー固有の制約を 2 つの軸で整理する
- 「正しさ」と「効率」のトレードオフを言葉にする
- 設計やレビューで見る観点を増やす

<!--
前回は地図を渡す回でした

今回は「共有状態」と「共有実行環境」に絞って深掘りします
-->

---
color: sky-light
---

# お断り

<br>

- 網羅ガイドではない
- 具体技術は一例であり、正解のカタログではない
- 実装手順やベストプラクティス集でもない

<!--
前提としてこの資料はサーバーのすべてを網羅しているわけではありません

具体的な技術は一例であり、その時々によって正解は異なります

パターンを知って適切な選択ができるようになりましょう
-->

---
color: sky-light
---

# サーバーには 2 つの制約がある

<br>

1. **共有状態** を正しく保つ
2. **共有実行環境** を効率よく使う

そのうえで:

- 両方にまたがるトレードオフ
- 外部失敗と障害の観測

<!--
正しさと効率は、しばしばぶつかります

ぶつかりどころが、サーバーサイドらしい設計判断です

2 軸の外側にも、サーバーらしい世界はあります
-->

---
layout: section
slide_info: false
color: sky-light
---

# 1. 共有状態を正しく保つ

---
layout: center
slide_info: false
style: |
  background-color: #E9EFF5;
  color: #0ea5e9;
---

# みんなで触るデータを<br>壊さない

---
color: sky-light
---

# この章で扱うこと

<br>

- Validation (クライアントを信用しない)
- Transaction (まとめて成功 / 失敗)
- 冪等性 (何度来ても壊れない)
- 競合・状態遷移・外部整合性は周辺として紹介

---
layout: center
slide_info: false
style: |
  background-color: #E9EFF5;
  color: #0ea5e9;
---

# サーバーの入口に来るものは<br>すべて疑う

---
color: sky-light
---

# クライアントを信用しない

<br>

- Validation
- Authentication / Authorization
- 不正値・改ざん・想定外入力

<!--
画面で弾いても、リクエストは別経路から来ます

必須チェック・型・範囲・権限はサーバー側で最終判定します
-->

---
color: sky-light
---

# よくある勘違い

<br>

| クライアント側 | サーバー側の現実 |
| --- | --- |
| ボタンを連打できない | 同じリクエストを何度でも送れる |
| hidden は見えない | 値は改ざんできる |
| ログイン済み画面 | トークンや Cookie を盗まれることもある |
| 自分の画面だけ見える | ID を書き換えられると他人のデータに届く |

<!--
UI の制約は利便性であって、セキュリティ境界ではありません
-->

---
color: sky-light
---

# 認可の一歩先

<br>

- Authentication: 誰か
- Authorization: 何をしてよいか
- IDOR: 他人の ID を指定して通ってしまう抜け
- テナント分離: 組織をまたいでデータが見えないか

<!--
ログイン済みだから安全、にはなりません

「このユーザーがこのリソースを触ってよいか」を毎回確認します
-->

---
color: sky-light
---

# データ設計も防波堤になる

<br>

- 型
- NULL の意味
- UNIQUE / FK / CHECK
- 正規化・非正規化

<!--
アプリの if だけでは守りきれません

DB の制約は最後の防波堤になります
-->

---
layout: center
slide_info: false
style: |
  background-color: #E9EFF5;
  color: #0ea5e9;
---

# 同時に書き込まれると<br>壊れる

---
color: sky-light
---

# サーバーには同時にアクセスが来る

<br>

- Race Condition
- Lock
- Optimistic / Pessimistic Lock
- Atomic Update

<!--
ローカルで再現しにくいバグの代表です

「読んでから書く」は並走すると壊れます
-->

---
color: sky-light
---

# レースの例

<br>

```text
1. A: 在庫を読む → 1
2. B: 在庫を読む → 1
3. A: 在庫を 0 にして保存
4. B: 在庫を 0 にして保存
```

結果: 在庫 1 なのに 2 件売れる

<!--
図を差し替える場合は images/ 配下に置く

対策の方向性は、DB 制約・行ロック・原子的更新・在庫引当の直列化などです

ここでは「同時は起きる」こと自体を共有したいです
-->

---
color: sky-light
---

# データの整合性を守る

<br>

- Transaction
- Atomicity
- Commit / Rollback
- Isolation Level

<!--
複数の更新を「全部成功か全部失敗」にまとめます

Isolation Level は、どこまで他の処理の途中を見るかの話です
-->

---
color: sky-light
---

# Transaction が守ること

<br>

```text
1. 在庫を減らす
2. 注文を作る
3. 支払いレコードを作る
```

途中で失敗したら、全部なかったことにする

<!--
1 つだけ成功して残ると、データが嘘になります

Transaction は「まとまり」を約束する道具です
-->

---
layout: center
slide_info: false
style: |
  background-color: #E9EFF5;
  color: #0ea5e9;
---

# 同じ処理が<br>二度来ても壊れない

---
color: sky-light
---

# 冪等性

<br>

- 二重送信
- Retry されても壊れない設計
- Idempotency Key

<!--
ネットワークは「届いたか分からない」ことがあります

だから再送は普通に起きます
-->

---
color: sky-light
---

# 冪等でないと何が起きるか

<br>

```text
1. 決済 API を呼ぶ
2. 応答がタイムアウト
3. クライアントが再送する
```

実は 1 回目は成功していた → 二重課金

<!--
「失敗したように見えた」と「実行されなかった」は別です
-->

---
color: sky-light
---

# 状態遷移も守る

<br>

- 「どの状態からどの状態へ遷移できるか」
- 不正な状態遷移を防ぐ

```text
draft → paid → shipped
 paid  ← draft に戻さない
```

<!--
列の値を直接書き換えられる設計だと、ありえない状態が生まれます

許可された遷移だけを DB やコードで強制します
-->

---
color: sky-light
---

# 外部システムとの整合性

<br>

- DB + 外部 API を 1 Transaction にはできない
- 部分成功
- 補償処理

<!--
ローカル関数のように全部成功か全部失敗、にはなりません

複数の副作用があるほど、途中失敗の設計が必要です
-->

---
color: sky-light
---

# 途中失敗の典型

<br>

```text
1. 注文を DB に保存   ← 成功
2. 決済 API を呼ぶ     ← タイムアウト
3. メールを送る        ← 未実行
```

このあと再実行したら何が起きる？

<!--
決済が実は成功していたら二重課金になります

冪等キーや Outbox が効いてくる理由です
-->

---
color: sky-light
---

# 結果整合性という選択肢

<br>

- 即座にすべてを一致させる必要はないケース
- Queue / Event
- 非同期処理
- Outbox / Saga は発展編

<!--
強い一貫性が常に正解ではありません

遅れを許容できるなら、設計の自由度が上がります
-->

---
layout: center
slide_info: false
style: |
  background-color: #E9EFF5;
  color: #0ea5e9;
---

# 「成功したように見える」と<br>「全体として正しい」は違う

---
layout: section
slide_info: false
color: sky-light
---

# 2. 共有実行環境を<br>効率よく使う

---
layout: center
slide_info: false
style: |
  background-color: #E9EFF5;
  color: #0ea5e9;
---

# サーバーは<br>あなたの専用機ではない

---
color: sky-light
---

# この章で扱うこと

<br>

- 計算量 / Memory
- DB 負荷
- 非同期処理
- 分散環境
- Connection・並列・Cache は周辺として紹介

---
color: sky-light
---

# 複数リクエストが同時に動く

<br>

- 「自分の処理だけが動いているわけではない」
- Concurrency
- CPU / Memory / Connection は共有物

<!--
1 リクエストの浪費は、他の全リクエストの遅延になります
-->

---
layout: center
slide_info: false
style: |
  background-color: #E9EFF5;
  color: #0ea5e9;
---

# 1 リクエストが<br>全体を圧迫する

---
color: sky-light
---

# CPU

<br>

- 計算量
- アルゴリズム
- 無駄な計算をしない

<!--
リクエスト数が増えると、無駄な計算も一緒に増えます

まず測って、重い場所を特定します
-->

---
color: sky-light
---

# Memory

<br>

- 1 リクエストで大量に使わない
- 全件ロード vs Stream / Chunk
- Memory Leak

<!--
巨大な配列を一度に持つと、他のリクエストのメモリを奪います

ファイルや大量レコードは、分割して流す発想が必要です
-->

---
color: sky-light
---

# Connection は有限

<br>

- DB Connection Pool
- HTTP Connection
- Thread / Process

<!--
特に DB 接続数はすぐ上限に当たります

待たされる接続が増えると、全体が止まります
-->

---
layout: center
slide_info: false
style: |
  background-color: #E9EFF5;
  color: #0ea5e9;
---

# DB はいちばん共有されやすい<br>ボトルネック

---
color: sky-light
---

# DB 負荷

<br>

- Query 回数
- N+1
- Index
- Execution Plan

<!--
アプリが速くても、DB が詰まれば全体が遅いです

まずは何回・どのクエリが走っているかを見ます
-->

---
color: sky-light
---

# N+1 のイメージ

<br>

```text
1. 注文一覧を取る          ← 1 回
2. 各注文のユーザーを取る  ← N 回
```

注文が 100 件なら、クエリは 101 回

<!--
ループ内の個別取得は、データ量に比例して悪化します
-->

---
color: sky-light
---

# I/O 待ちと CPU 処理は違う

<br>

- DB
- Network
- File
- CPU を使っている時間とは別物

<!--
待っている間も、接続やスレッドなどの資源は占有され得ます

「自分は暇」でも、共有資源は消費しています
-->

---
color: sky-light
---

# 並列処理

<br>

- 独立した処理を並列化する
- 並列化すれば必ず速くなるわけではない

<!--
依存がある処理を無理に並べても効果は薄いです

共有資源の上限にもぶつかります
-->

---
layout: center
slide_info: false
style: |
  background-color: #E9EFF5;
  color: #0ea5e9;
---

# 全部をリクエスト中に<br>やらなくていい

---
color: sky-light
---

# 非同期処理

<br>

- Queue / Job
- バックグラウンド処理
- 「レスポンス中に全部やらなくていい」

<!--
ユーザーが待たなくてよい処理は、後回しにできます

その代わり、結果の遅延と失敗の再処理が必要です
-->

---
color: sky-light
---

# 同期でやりすぎると

<br>

```text
API
 ├─ DB 保存
 ├─ 画像変換
 ├─ 外部 API
 ├─ メール送信
 └─ 検索インデックス更新
```

全部待たせると遅いし、途中失敗にも弱い

<!--
応答に必要な最小だけ同期にし、残りは非同期へ寄せる判断が重要です
-->

---
color: sky-light
---

# 非同期に寄せると

<br>

```text
API
 ├─ DB 保存
 └─ Queue に後続処理を積む
      ├─ 画像変換
      ├─ メール送信
      └─ 検索インデックス更新
```

速さの代わりに、結果整合性と失敗の再処理が必要

---
color: sky-light
---

# Cache

<br>

- 計算や DB アクセスを減らす
- Cache invalidation
- 整合性とのトレードオフ

<!--
Cache は速さの道具であり、真実の源泉ではありません

無効化設計がない Cache は負債になりやすいです
-->

---
layout: center
slide_info: false
style: |
  background-color: #E9EFF5;
  color: #0ea5e9;
---

# 1 台の成功体験は<br>複数台で裏切られる

---
color: sky-light
---

# Scale Up / Scale Out

<br>

- Scale Up: 1 台を強くする
- Scale Out: 台数を増やす

<!--
強くするだけでは限界があります

台数を増やすと、状態の置き場所が問題になります
-->

---
color: sky-light
---

# 分散環境

<br>

- 複数サーバーで動く
- Stateless
- ローカルメモリに状態を持つ問題
- Distributed Lock

<!--
「このプロセス内だけ」の前提は、スケールアウトで壊れます
-->

---
color: sky-light
---

# ローカル前提が壊れる例

<br>

```text
1. Client → Server A: ログイン
2. Server A: Session をメモリに保存
3. Client → Server B: 次のリクエスト
4. Server B: セッションがない
```

結果: ログインしたのに、次の画面で切れたように見える

<!--
Session や一時ファイル、プロセス内 Cache は分散で罠になります
-->

---
color: sky-light
---

# Backpressure / Rate Limit

<br>

- 処理できる以上のリクエストを受けない
- 外部 API の Rate Limit
- Load shedding / Graceful degradation

<!--
全部処理しようとして全体停止するより、一部を落とす判断が必要な場面があります
-->

---
layout: center
slide_info: false
style: |
  background-color: #E9EFF5;
  color: #0ea5e9;
---

# 共有資源を奪い合う前提で<br>設計する

---
layout: section
slide_info: false
color: sky-light
---

# 3. 両方にまたがる話

---
layout: center
slide_info: false
style: |
  background-color: #E9EFF5;
  color: #0ea5e9;
---

# 正しさと効率は<br>しばしばぶつかる

---
color: sky-light
---

# Transaction / Lock

<br>

- 整合性を守れる
- ただし Lock が長いと性能が落ちる

<!--
守りを厚くするほど、待ちが増えます
-->

---
color: sky-light
---

# Cache

<br>

- 高速になる
- ただし古いデータを返す可能性がある

<!--
鮮度をどこまで許すかが設計です
-->

---
color: sky-light
---

# 非同期処理

<br>

- リクエストを軽くできる
- ただし結果整合性を考える必要がある

<!--
速さの代わりに、「今はまだ反映されていない」を扱います
-->

---
color: sky-light
---

# Retry

<br>

- 可用性は上がる
- ただし負荷増大・二重実行の危険がある

<!--
Retry と冪等性はセットで考えます

落ちている相手に全員が即リトライすると、障害を拡大します
-->

---
color: sky-light
---

# 分散

<br>

- 処理能力は上げられる
- 整合性の維持は難しくなる

<!--
台数を増やすほど、状態の置き場と同期が難しくなります
-->

---
layout: center
slide_info: false
style: |
  background-color: #E9EFF5;
  color: #0ea5e9;
---

# どちらかを捨てるのではなく<br>代償を払う場所を選ぶ

---
layout: section
slide_info: false
color: sky-light
---

# 4. 外部は失敗する /<br>障害を観測する

---
layout: center
slide_info: false
style: |
  background-color: #E9EFF5;
  color: #0ea5e9;
---

# 2 軸の外側にも<br>サーバーらしい世界がある

---
color: sky-light
---

# 外部システムは信用しすぎない

<br>

- Timeout
- Retry
- Circuit Breaker
- 外部 API 障害
- 部分障害

<!--
外部 API は自分たちの SLA を保証しません

遅い・落ちる・たまに変なレスポンス、を前提にします
-->

---
color: sky-light
---

# リトライは両刃

<br>

- 一時障害には有効
- 相手をさらに追い込むこともある
- 冪等でないと二重実行になる
- バックオフと上限が必要

<!--
どこまで Retry してよいかは、相手と自分の両方を見ます
-->

---
color: sky-light
---

# ネットワークは壊れる

<br>

- Latency
- Timeout
- DNS
- 接続切断
- クライアント切断後も処理が続く

<!--
リクエストが届いたことと、相手が処理を終えたことは別です

クライアントがブラウザを閉じても、サーバー処理は続き得ます
-->

---
color: sky-light
---

# 障害を調査できるようにする

<br>

- Logging
- Metrics
- Tracing
- Request ID
- Monitoring / Alert

<!--
起きないことが理想でも、起きたときに追えることが必要です

特に Request ID は複数サービスを横断する手がかりです
-->

---
color: sky-light
---

# 最低限ほしい観測ポイント

<br>

- リクエストの入口と出口
- 外部呼び出しの成否 / レイテンシ
- キューの滞留量
- エラー率の急変
- デプロイとの相関

<!--
アラートは「人が起きて対応できる粒度」にします
-->

---
layout: section
slide_info: false
color: sky-light
---

# まとめ

---
color: sky-light
---

# サーバー側で見る観点

<br>

1. 共有状態を正しく保つ
2. 共有実行環境を効率よく使う
3. 両方のトレードオフを意識する
4. 外部失敗と観測まで含める

---
color: sky-light
---

# 本編で持ち帰ってほしいこと

<br>

| 軸 | キーワード |
| --- | --- |
| 状態 | Validation / Transaction / 冪等性 |
| 実行 | 計算量・Memory / DB / 非同期 / 分散 |
| 横断 | Lock・Cache・Retry の代償 |
| 別枠 | Timeout・Log・Request ID |

---
layout: center
slide_info: false
style: |
  background-color: #E9EFF5;
  color: #0ea5e9;
---

# 「動いた」の次に<br>「壊れ方」を想像する

---
color: sky-light
---

# レビューで使える問い

<br>

- 二重に来たらどうなる？
- 途中で失敗したら何が残る？
- この処理は共有資源をどれだけ使う？
- 別サーバーでも同じ動きか？
- 障害時に追える手がかりはあるか？

---
layout: center
slide_info: false
style: |
  background-color: #E9EFF5;
  color: #0ea5e9;
---

# 質問・議論

---
color: sky-light
---

# こういう世界もある

<br>

- Isolation Level
- Optimistic / Pessimistic Lock
- Transaction Outbox / Saga
- Cache invalidation
- 分散トレーシング

<!--
今日触れた地図の周辺にも、こういう用語・概念があります

全部覚える必要はなく、「そういう話がある」と知っていれば十分です
-->
