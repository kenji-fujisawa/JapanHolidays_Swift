# JapanHolidays

日本の祝日判定と祝日名の取得を行なう Swift ライブラリ  
[内閣府の祝日データ](https://www8.cao.go.jp/chosei/shukujitsu/gaiyou.html) を使用して祝日を判定します

## 導入

File -> Add Package Dependencies... から `https://github.com/kenji-fujisawa/JapanHolidays_Swift` を追加してください  
<img width="1512" height="965" alt="Image" src="https://github.com/user-attachments/assets/5deb574c-c935-4bda-b2c6-4a3e443f83dd" />

macOS 向けのアプリの場合は App Sandbox の設定で Outgoing Connections を有効にしてください  
<img width="426" height="85" alt="Image" src="https://github.com/user-attachments/assets/3d4b761b-6e58-4b4f-8885-8d1b7d01e6aa" />

## 使用方法

### 祝日判定

```
import JapanHolidays

Holidays.isHoliday(year: 2026, month: 1, day: 12)       // true
Holidays.isHoliday(year: 2025, month: 1, day: 12)       // false

Holidays.isHoliday(Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 12)) ?? Date())    // true
Holidays.isHoliday(Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 12)) ?? Date())    // false
```

### 祝日名の取得

```
import JapanHolidays

Holidays.getName(year: 2026, month: 1, day: 12)     // "成人の日"
Holidays.getName(year: 2025, month: 1, day: 12)     // nil

Holidays.getName(Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 12)) ?? Date())  // "成人の日"
Holidays.getName(Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 12)) ?? Date())  // nil
```

## 補足

初期状態で 2027 年までの祝日データを内包していますが、以降はアプリ起動時に 30 日おきに最新データをチェックし、SQLite にキャッシュします

また、アプリ起動時に非同期で SQLite を読み込むので、メソッドの呼び出し時点で初期化が完了していなかった場合は正しい結果が得られない可能性があります  
そのような場合は `joinInit()` で初期化完了を待機してください

```
    @State var text: String = ""
    
    var body: some View {
        Text(text)
        .task {
            Holidays.joinInit()
            text = Holidays.getName(year: 2026, month: 1, day: 12) ?? ""
        }
    }
```

## Lisence

This project is licensed under the MIT License, see the LICENSE.txt file for details
