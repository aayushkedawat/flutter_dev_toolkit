import '../core/deep_link_store.dart';
import '../models/deep_link_entry.dart';

/// Framework-agnostic deep link recorder for Flutter Dev Toolkit.
///
/// Call [DevToolkitDeepLinkObserver.onLinkReceived] anywhere in your app when
/// you receive a deep link — inside `onGenerateRoute`, a `go_router` redirect,
/// a `uni_links` stream handler, or any other routing mechanism.
///
/// Example with `uni_links`:
/// ```dart
/// uriLinkStream.listen((uri) {
///   if (uri != null) {
///     DevToolkitDeepLinkObserver.onLinkReceived(uri.toString());
///   }
/// });
/// ```
///
/// Example with `go_router`:
/// ```dart
/// GoRouter(
///   redirect: (context, state) {
///     DevToolkitDeepLinkObserver.onLinkReceived(
///       state.uri.toString(),
///       source: 'go_router',
///     );
///     return null;
///   },
/// )
/// ```
class DevToolkitDeepLinkObserver {
  DevToolkitDeepLinkObserver._();

  /// Record [uri] in the Deep Links panel.
  ///
  /// [source] is an optional label (e.g. `'go_router'`, `'uni_links'`) shown
  /// in the inspector to identify where the link was captured.
  static void onLinkReceived(String uri, {String? source}) {
    DeepLinkStore.add(DeepLinkEntry(uri: uri, source: source));
  }
}
