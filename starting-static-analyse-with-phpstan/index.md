---
marp: true
paginate: true
title: PHPStan で始める静的解析
description: 
author: 白湯/sayuprc
---

# PHPStan で始める静的解析

---
<!-- 
header: PHPStan で始める静的解析
-->

# 静的解析とは

## コードを**実行せず**にその品質や信頼性を確認できる技術やツール


---

# メリット

- コード品質の向上
  - テスト不要で早期にバグ検知が可能
  - 
- レビューの効率化
  - CI と組み合わせることでおかしなコードが PR に含まれるのを防げる
  - レビュワーはビジネスロジックのレビューにだけ注力すればよい

----

# 代表的なツール

## PHPStan

- 型の不整合や未使用変数、未到達コードの検知などさまざまなことをしてくれる
  - コーディングスタイルの検知はできない
- Laravel や Symfony などのフレームワーク、ライブラリで使える拡張が充実している

## Psalm

- 基本的には PHPStan と大きくは変わらない
- コーディングスタイルの検知と自動修正機能がある

---

# 使い方

- Composer を利用してインストールするのがおすすめされている
  - `composer require --dev phpstan/phpstan`
    - ルートディレクトリに `phpstan.neon` を作成し、`./vendor/bin/phpstan analyse` で実行
- Laravel を使っている場合は `composer require --dev larastan/larastan` を入れれば OK

---

# 使い方

## phpstan.neon

```yaml
parameters:
  # 解析対象のパス
  paths:
    - app
  
  # 解析レベル(高いほうが厳しい)
  level: 5
```

---

# 使い方

## phpstan.neon

```yaml
parameters:
  # 解析対象のパス
  paths:
    - app
  
  # 解析レベル(高いほうが厳しい) 6 からが本番！
  level: 5
```

---

# 使い方(Laravel の場合)

## phpstan.neon

```yaml
includes:
  - vendor/larastan/larastan/extension.neon

parameters:
  paths:
    - app
  
  level: 5
```

---
<style scoped>
.speech-bubble {
    position: absolute; /* 絶対位置で配置 */
    top: 400px; /* 縦方向の位置 */
    right: 600px; /* 横方向の位置 */
    background: #f0f0f0;
    border-radius: 10px;
    padding: 10px 15px;
    display: inline-block;
    max-width: 60%;
    z-index: 100; /* 最前面に表示 */
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* 見やすくする影 */
  }

  .speech-bubble:after {
    content: '';
    position: absolute;
    bottom: 0;
    left: 20px;
    width: 0;
    height: 0;
    border: 10px solid transparent;
    border-top-color: #f0f0f0;
    border-bottom: 0;
    margin-left: -5px;
    margin-bottom: -10px;
  }

  .content {
    position: relative;
    padding: 100px; /* 吹き出しが被らないように余白を確保 */
  }
</style>

<div class="speech-bubble">数値を求めているのに</div>

```php
<?php declare(strict_types=1);

function add(int $a, int $x): int
{
    return $a + $b;
}

echo add('1', '2');
```

---

```php
<?php declare(strict_types=1);

function add(int $a, int $x): int
{
    return $a + $b;
}

echo add('1', '2');
```
