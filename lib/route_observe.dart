import 'package:flutter/material.dart';

/// Global RouteObserver instance.
///
/// Register this in MaterialApp's `navigatorObservers` list (see main.dart).
/// Any widget that mixes in `RouteAware` can then subscribe to it (typically
/// in `didChangeDependencies`) to get `didPopNext()` callbacks — fired when
/// a route pushed *on top* of that widget's route is popped and the widget
/// becomes the visible/topmost route again.
///
/// This is what lets HomeScreen refetch its data when the user comes back
/// from ProductDetailScreen, SearchResultsScreen, etc. — no matter how many
/// screens were stacked on top or how the user navigated through them.
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();