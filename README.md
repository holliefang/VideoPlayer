
# Video Player App

這個專案是一個簡單的影片播放應用程式，使用 MVVM 架構來實現。用戶可以輸入影片 URL，並播放影片，同時支持播放、暫停、調整進度條功能。

## 目標

- 提供簡單易用的介面來播放影片。
- 使用 ViewModel 來分離視圖、邏輯和數據層。
- 支援影片的播放控制，包括播放、暫停、進度條調整等功能。

## 目錄結構
```
VideoPlayerApp/
├── Application/
│   └── AppDelegate.swift
│   └── SceneDelegate.swift  
├── Views/
│   └── PlayerView.swift
│   └── PlayerControlView.swift
│   └── VideoURLInputViewController.swift
├── ViewModels/
│   └── VideoViewModel.swift
├── Data/
│   └── LocalStorage.swift
│   └── UserDefaultStorage.swift
```
## 架構
- ViewModel: 負責處理 Player 的業務邏輯（例如播放、暫停等）以供 View 顯示。
- View: 顯示界面和 user interaction，並通過 ViewModel 更新畫面。它不直接處理業務邏輯或數據。

## 主要功能
1. 影片播放: 用戶可以輸入影片 URL 並開始播放。
2. 播放控制: 提供播放、暫停等控制。
3. 影片進度條: 顯示影片當前播放進度，並支持調整進度條來選擇播放時間。
4. 影片歷史記錄: 儲存播放過的影片 URL 並可以方便地查看和重新播放。

### 主要分層
1. ViewModel (影片邏輯): 負責處理影片的播放邏輯（如控制播放、暫停、進度等）。
2. View (視圖控制): 顯示影片播放介面，並處理用戶的操作，如播放按鈕、進度條等。

## 計畫中的功能
- 快進、音量調整等播放控制
- 多語言支援 
- 離線觀看模式
- 支援更多影片格式

## 未來架構優化
- 目標：拆分架構，讓 Player 更容易測試。
- 方法：使用 Dependency Injection 減少 Player 與 VideoViewModel 之間的緊耦合，讓單元測試更容易實現。
