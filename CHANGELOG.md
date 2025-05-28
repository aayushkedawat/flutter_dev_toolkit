## 1.2.0

### ✨ Features
- Introduced plugin registry with `BuiltInPluginType` enum for cleaner plugin control.
- Removed legacy flags (`enableRouteInterceptor`, `enableNetworkInterceptor`, `enableLifecycleInterceptor`).
- Built-in plugins now registered via enum-based `disableBuiltInPlugins`.
- Modular plugin architecture for Logs, Network, Routes, Device Info.
- Each plugin can define its own export and clear actions.
- Export and clear buttons now come with confirmation dialogs and clipboard/share support.
- Plugin-specific app bars with actions and optional config panels.
- Added proper lifecycle handling (`onPause`, `onResume`) in plugins.
- Active plugin state synced with tab selection on open/close.

### 🐛 Fixes
- Fixed bug where plugin state was not updated on overlay reopen.
- Fixed default tab and plugin mismatch on initial open.
- UI updates now reflect after clearing logs or routes.

### 📦 Housekeeping
- Updated README to reflect new plugin management approach.
- Deprecated old config flags in favor of enum-driven `disableBuiltInPlugins`.

## 1.1.2
- Minor Fixes

## 1.1.1
- Minor Fixes

## 1.1.0
### Added
- 🚀 New App State Inspector tab
- 🎯 Bloc state tracking via DevBlocObserver
- 💡 Pretty JSON formatting + state timestamp
- 🧠 Responsive layout (split for desktop, expansion on mobile)
- 🪄 Copy state to clipboard
- 🎛 Framework adapter system with dropdown support

## 1.0.0
- Initial release with Logs, Network, Routes, Performance
- Plugin system and built-in plugins
- Error handling and DevOverlay
