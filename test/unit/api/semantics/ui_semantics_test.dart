// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:opentelemetry_api/opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('UI Semantics', () {
    group('AppLifecycleStates', () {
      test('should have correct keys', () {
        expect(AppLifecycleStates.active.key, equals('device.app.lifecycle.active'));
        expect(AppLifecycleStates.resumed.key, equals('device.app.lifecycle.resumed'));
        expect(AppLifecycleStates.detached.key, equals('device.app.lifecycle.detached'));
        expect(AppLifecycleStates.inactive.key, equals('device.app.lifecycle.inactive'));
        expect(AppLifecycleStates.hidden.key, equals('device.app.lifecycle.hidden'));
        expect(AppLifecycleStates.paused.key, equals('device.app.lifecycle.paused'));
      });

      test('appLifecycleStateFor should return correct state', () {
        expect(AppLifecycleStates.appLifecycleStateFor('detached'), equals(AppLifecycleStates.detached));
        expect(AppLifecycleStates.appLifecycleStateFor('resumed'), equals(AppLifecycleStates.resumed));
        expect(AppLifecycleStates.appLifecycleStateFor('inactive'), equals(AppLifecycleStates.inactive));
        expect(AppLifecycleStates.appLifecycleStateFor('hidden'), equals(AppLifecycleStates.hidden));
        expect(AppLifecycleStates.appLifecycleStateFor('paused'), equals(AppLifecycleStates.paused));
        expect(AppLifecycleStates.appLifecycleStateFor('unknown'), equals(AppLifecycleStates.active));
      });
    });

    group('AppLifecycleSemantics', () {
      test('should have correct keys', () {
        expect(AppLifecycleSemantics.appLaunchId.key, equals('app.launch.id'));
        expect(AppLifecycleSemantics.appLifecycleId.key, equals('app_lifecycle.id'));
        expect(AppLifecycleSemantics.appLifecycleChange.key, equals('app_lifecycle.changed'));
        expect(AppLifecycleSemantics.appLifecycleState.key, equals('app_lifecycle.state'));
        expect(AppLifecycleSemantics.appLifecycleStateId.key, equals('app_lifecycle.state_id'));
        expect(AppLifecycleSemantics.appLifecyclePreviousState.key, equals('app_lifecycle.previous_state'));
        expect(AppLifecycleSemantics.appLifecyclePreviousStateId.key, equals('app_lifecycle.previous_state_id'));
        expect(AppLifecycleSemantics.appLifecyclePreviousLifecycleId.key, equals('app_lifecycle.previous_lifecycle_id'));
        expect(AppLifecycleSemantics.appLifecycleTimestamp.key, equals('app_lifecycle.timestamp'));
        expect(AppLifecycleSemantics.appLifecycleDuration.key, equals('app_lifecycle.duration'));
        expect(AppLifecycleSemantics.appStartType.key, equals('app.start.type'));
      });
    });

    group('AppStartType', () {
      test('should have correct keys', () {
        expect(AppStartType.cold.key, equals('cold'));
        expect(AppStartType.hot.key, equals('hot'));
      });
    });

    group('AppInfoSemantics', () {
      test('should have correct keys', () {
        expect(AppInfoSemantics.appId.key, equals('app.id'));
        expect(AppInfoSemantics.appName.key, equals('app.name'));
        expect(AppInfoSemantics.appVersion.key, equals('app.version'));
        expect(AppInfoSemantics.appBuildNumber.key, equals('app.build_number'));
        expect(AppInfoSemantics.appPackageName.key, equals('app.package_name'));
      });
    });

    group('DeviceSemantics', () {
      test('should have correct keys', () {
        expect(DeviceSemantics.deviceId.key, equals('device.id'));
        expect(DeviceSemantics.deviceModel.key, equals('device.model'));
        expect(DeviceSemantics.devicePlatform.key, equals('device.platform'));
        expect(DeviceSemantics.deviceOsVersion.key, equals('device.os_version'));
        expect(DeviceSemantics.isPhysicalDevice.key, equals('device.physical'));
        expect(DeviceSemantics.isiOSAppOnMac.key, equals('device.ios_on_mac'));
      });
    });

    group('BatterySemantics', () {
      test('should have correct keys', () {
        expect(BatterySemantics.batteryLevel.key, equals('battery.level'));
        expect(BatterySemantics.batteryState.key, equals('battery.state'));
        expect(BatterySemantics.batteryStateFull.key, equals('battery.state.full'));
        expect(BatterySemantics.batteryStateCharging.key, equals('battery.state.charging'));
        expect(BatterySemantics.batteryStateConnectedNotCharging.key, equals('battery.state.connected_not_charging'));
        expect(BatterySemantics.batteryStateDischanrging.key, equals('battery.state.discharging'));
        expect(BatterySemantics.batteryStateUnknown.key, equals('battery.state.unknown'));
        expect(BatterySemantics.batterySaveMode.key, equals('battery.save_mode'));
      });
    });

    group('NavigationSemantics', () {
      test('should have correct keys', () {
        expect(NavigationSemantics.navigationAction.key, equals('navigation.action'));
        expect(NavigationSemantics.navigationTrigger.key, equals('navigation.trigger'));
        expect(NavigationSemantics.navigationTimestamp.key, equals('navigation.timestamp'));
        expect(NavigationSemantics.routeName.key, equals('navigation.route.name'));
        expect(NavigationSemantics.routeId.key, equals('navigation.route.id'));
        expect(NavigationSemantics.routeKey.key, equals('navigation.route.key'));
        expect(NavigationSemantics.routePath.key, equals('navigation.route.path'));
        expect(NavigationSemantics.routeArguments.key, equals('navigation.route.arguments'));
        expect(NavigationSemantics.routeTimestamp.key, equals('navigation.route.timestamp'));
        expect(NavigationSemantics.previousRouteName.key, equals('navigation.previous_route_name'));
        expect(NavigationSemantics.previousRouteId.key, equals('navigation.previous_route_id'));
        expect(NavigationSemantics.previousRoutePath.key, equals('navigation.previous_route_path'));
        expect(NavigationSemantics.previousRouteDuration.key, equals('route.previous_route_duration'));
        expect(NavigationSemantics.routeTransitionDuration.key, equals('route.transition_duration'));
      });
    });

    group('InteractionType', () {
      test('should have correct keys', () {
        expect(InteractionType.click.key, equals('click'));
        expect(InteractionType.drag.key, equals('drag'));
        expect(InteractionType.focusChange.key, equals('focus_change'));
        expect(InteractionType.formSubmit.key, equals('form_submit'));
        expect(InteractionType.keydown.key, equals('keydown'));
        expect(InteractionType.keyup.key, equals('keyup'));
        expect(InteractionType.listSelection.key, equals('list_selection'));
        expect(InteractionType.listSelectionIndex.key, equals('list_selected_index'));
        expect(InteractionType.longPress.key, equals('long_press'));
        expect(InteractionType.menuSelect.key, equals('menu_select'));
        expect(InteractionType.menuSelectedItem.key, equals('menu_selected_item'));
        expect(InteractionType.scroll.key, equals('scroll'));
        expect(InteractionType.swipe.key, equals('swipe'));
        expect(InteractionType.tap.key, equals('tap'));
        expect(InteractionType.textInput.key, equals('text_input'));
        expect(InteractionType.gestureDeltaX.key, equals('gesture.delta_x'));
        expect(InteractionType.gestureDeltaY.key, equals('gesture.delta_y'));
        expect(InteractionType.gestureDirection.key, equals('gesture.direction'));
      });
    });

    group('InteractionSemantics', () {
      test('should have correct keys', () {
        expect(InteractionSemantics.userInteraction.key, equals('user_interaction'));
        expect(InteractionSemantics.interactionType.key, equals('interaction.type'));
        expect(InteractionSemantics.interactionTarget.key, equals('interaction.target'));
        expect(InteractionSemantics.interactionResult.key, equals('interaction.result'));
        expect(InteractionSemantics.inputDelay.key, equals('input.delay'));
      });
    });

    group('PerformanceSemantics', () {
      test('should have correct keys', () {
        expect(PerformanceSemantics.renderDuration.key, equals('render.duration'));
        expect(PerformanceSemantics.firstPaint.key, equals('first.paint'));
        expect(PerformanceSemantics.firstContentfulPaint.key, equals('first.contentful.paint'));
        expect(PerformanceSemantics.timeToInteractive.key, equals('time.to.interactive'));
        expect(PerformanceSemantics.frameTime.key, equals('frame.time'));
        expect(PerformanceSemantics.frameRate.key, equals('frame.rate'));
        expect(PerformanceSemantics.jankCount.key, equals('jank.count'));
        expect(PerformanceSemantics.memoryUsage.key, equals('memory.usage'));
        expect(PerformanceSemantics.rumFirstInputDelay.key, equals('first_input_delay'));
      });
    });
    
    group('ErrorSemantics', () {
      test('should have correct keys', () {
        expect(ErrorSemantics.errorType.key, equals('error.type'));
        expect(ErrorSemantics.errorSource.key, equals('error.source'));
        expect(ErrorSemantics.errorMessage.key, equals('error.message'));
        expect(ErrorSemantics.errorStacktrace.key, equals('error.stacktrace'));
        expect(ErrorSemantics.crashFreeSessionRate.key, equals('crash.free.session.rate'));
      });
    });

    group('NetworkSemantics', () {
      test('should have correct keys', () {
        expect(NetworkSemantics.networkConnectivity.key, equals('network.connectivity'));
        expect(NetworkSemantics.networkType.key, equals('network.type'));
        expect(NetworkSemantics.networkRequestUrl.key, equals('network.request.url'));
        expect(NetworkSemantics.networkRequestDuration.key, equals('network.request.duration'));
      });
    });

    group('SessionViewSemantics', () {
      test('should have correct keys', () {
        expect(SessionViewSemantics.sessionId.key, equals('session.id'));
        expect(SessionViewSemantics.rumSessionId.key, equals('session_id'));
        expect(SessionViewSemantics.sessionStart.key, equals('session.start'));
        expect(SessionViewSemantics.sessionDuration.key, equals('session.duration'));
        expect(SessionViewSemantics.viewName.key, equals('view.name'));
        expect(SessionViewSemantics.rumViewName.key, equals('view_name'));
        expect(SessionViewSemantics.rumViewId.key, equals('view_id'));
        expect(SessionViewSemantics.viewStart.key, equals('view.start'));
        expect(SessionViewSemantics.viewDuration.key, equals('view.duration'));
        expect(SessionViewSemantics.rumViewLoadTime.key, equals('view_load_time'));
        expect(SessionViewSemantics.rumActionCount.key, equals('action.count'));
        expect(SessionViewSemantics.rumUserSatisfactionScore.key, equals('user_satisfaction_score'));
      });
    });

    group('UserSemantics', () {
      test('should have correct keys', () {
        expect(UserSemantics.userId.key, equals('user.id'));
        expect(UserSemantics.userRole.key, equals('user.role'));
        expect(UserSemantics.userSession.key, equals('user.session'));
      });
    });
  });
}
