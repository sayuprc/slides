---
theme: dracula
title: SOLID 原則/開放・閉鎖原則(OCP)
author: 白湯/sayuprc
colorSchema: dark
---

# SOLID 原則<br>開放閉鎖原則(OCP)

___
<br>

### Open Closed Principle

---

# SOLID 原則とは

OOP において、ソフトウェア設計時に従うべき 5 つのガイドラインのこと

<v-click>
  <Arrow x1="400" y1="185" x2="330" y2="185" />
  <span style="position: absolute; top: 170px; left: 405px;">今回はこれの話</span>
</v-click>

- Single Responsibility Principle
- Open / Closed Principle
- Liskov Substitution Principle
- Interface Segregation Principle
- Dependency Inversion Principle

---
layout: quote
---

# 開放・閉鎖原則(OCP)

> 拡張に対しては開いていて、修正に対しては閉じている状態がよい

---
layout: center
---

# 要するに

---
layout: center
---

# 既存の成果物を変更せずに拡張できるようにすべきということ

---

# 良くない例

```php{all|3-7}
class PaymentService {
    public function handle(string $method, int $amount) {
        if ($method === 'CreditCard') {
            // クレジットカードでの支払い処理
        } elseif ($method === 'BankTransfer') {
            // 銀行振込での支払い処理
        }
    }
}
```

<!--
支払処理を行うクラスで $method に応じて分岐をしている
-->

---

# どこが良くないのか

- 支払方法の追加や修正がある場合に `PaymentService` クラスに手が入る

---

# 何が良くないのか

- 手が入る = ミスる可能性がある
  - 「改修前は動いてたのに…」が起こりうる

---

# 良い実装例

```php{all|1-3|5-15|17-21}
interface PaymentMethod {
    public function pay(int $amount);
}

class CreditCardPayment implements PaymentMethod {
    public function pay(int $amount) {
        // クレジットカードでの支払い処理
    }
}

class BankTransferPayment implements PaymentMethod {
    public function pay(int $amount) {
        // 銀行振込での支払い処理
    }
}

class PaymentService {
    public function handle(PaymentMethod $method, int $amount) {
        $method->pay($amount);
    }
}
```

<!--
支払方法を抽象化したインターフェースを作る  
それぞれの支払い方法で実装して、サービス側はインターフェースに依存するようにする
-->

---

# メリット

- 機能追加、修正するときに既存の処理を壊すことがない
  - 機能追加の場合: `PaymentMethod` インターフェースを実装したクラスを新しく作るだけ
  - 修正の場合: 該当クラスのみを直すだけ

---

# どうやったらいいか

- インターフェースを活用する

---

# まとめ

- インターフェースと抽象化を活用しよう

---

# 参考

- Clean Architecture 達人に学ぶソフトウェアの構造と設計 
