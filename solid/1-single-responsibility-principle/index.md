---
marp: true
paginate: true
title: SOLID 原則/単一責任の原則
author: 白湯/sayuprc
---

# SOLID 原則<br>単一責任の原則

<hr>

## Single Responsibility Principle

---

<!--
header: SRP: 単一責任の原則
-->

# SRP: 単一責任の原則とは何か

---

## モジュールの変更を要求するアクターはたった 1 つであるべき

---

## アクターの説明をする

---

# 良くない実装例

```php
class User {
    public function save() {
        // ユーザーを保存する処理
    }

    public function hashPassword() {
        // パスワードをハッシュ化する処理
    }

    public function sendJoinMail() {
        // 入会メールを送信する処理
    }
}
```

---

# 良くない実装例

User クラスが保存処理やメールの送信処理を行っている

- ユーザーの情報が変わった場合
- 保存先が変わった場合
- メールの送信方法が変わった場合
- メールの送信内容が変わった場合

---

# 良い実装例

<style scoped>
  marp-pre {
    padding-bottom: 8px;
  }
</style>

```php
class User {
}

class UserRepository {
    public function save(User $user) {
        // ユーザーを保存する処理
    }
}

class PasswordHasher {
    public function handle(string $plainPassword) {
        // パスワードをハッシュ化する処理
    }
}

class JoinMailService {
    public function send(User $user) {
        // 入会メールを送信する処理
    }
}
```

---

# 良い実装例

それぞれの処理を担当するクラスを作成することで、User クラスを変更するアクターを 1 つにすることができる

---

# 守らないとどうなるのか
