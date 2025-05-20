import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'dart:js' as js;
import 'package:firebase_auth/firebase_auth.dart';

/// A utility class that handles Google Sign In specifically for web platforms.
class WebGoogleSignIn {
  static const String viewType = 'google-sign-in-button';
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Register the platform view factory for the Google Sign In button
  static void registerViewFactory() {
    // Register a factory that creates a DOM element for the Google Sign In button
    ui.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) {
        final div = html.DivElement()
          ..id = 'google-sign-in-button-$viewId'
          ..style.width = '100%'
          ..style.height = '50px'
          ..style.display = 'flex'
          ..style.justifyContent = 'center'
          ..style.alignItems = 'center';

        // Add the Google Sign In button
        _renderGoogleSignInButton(div.id);

        return div;
      },
    );
  }

  /// Initialize the Google Identity Services library and configure it
  static void initialize() {
    // Load the Google Identity Services JavaScript library if not already loaded
    if (!_isGsiLoaded()) {
      final scriptElement = html.ScriptElement()
        ..src = 'https://accounts.google.com/gsi/client'
        ..async = true
        ..defer = true;

      html.document.head!.append(scriptElement);
    }
  }

  /// Check if the GSI library is loaded
  static bool _isGsiLoaded() {
    return js.context.hasProperty('google') &&
        js.context['google'].hasProperty('accounts') &&
        js.context['google']['accounts'].hasProperty('id');
  }

  /// Render the Google Sign In button in the specified container
  static void _renderGoogleSignInButton(String containerId) {
    // Create a completer to handle the async loading of the GSI library
    final completer = Completer<void>();

    // Wait for GSI library to load
    if (_isGsiLoaded()) {
      completer.complete();
    } else {
      final checkInterval =
          Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (_isGsiLoaded()) {
          timer.cancel();
          completer.complete();
        }
      });

      // Timeout after 10 seconds
      Future.delayed(const Duration(seconds: 10), () {
        if (!completer.isCompleted) {
          checkInterval.cancel();
          completer.completeError(
              'Timeout waiting for Google Identity Services to load');
        }
      });
    }

    // After GSI is loaded, render the button
    completer.future.then((_) {
      js.context.callMethod('eval', [
        '''
        google.accounts.id.initialize({
          client_id: '381215284570-jlp6mjjvh120i6pk1sjcci0rgbir9l5r.apps.googleusercontent.com',
          callback: (response) => window.onGoogleSignInResponse(response),
          auto_select: false,
          cancel_on_tap_outside: true,
        });
        
        google.accounts.id.renderButton(
          document.getElementById('$containerId'),
          { 
            theme: 'filled_blue',
            size: 'large',
            text: 'signin_with',
            width: 240
          }
        );
      '''
      ]);

      // Set up the callback function
      _setupCallback();
    }).catchError((error) {
      print('Error loading Google Identity Services: $error');
    });
  }

  /// Set up the callback function that will be called when the user signs in
  static void _setupCallback() {
    // Add the callback to the window object so it can be called from JavaScript
    js.context['onGoogleSignInResponse'] = (response) async {
      try {
        // Create a credential from the ID token
        final idToken = response['credential'];
        final credential = GoogleAuthProvider.credential(idToken: idToken);

        // Sign in with Firebase Auth
        await _auth.signInWithCredential(credential);

        // Notify the app that sign in is complete
        _notifySignInComplete();
      } catch (e) {
        print('Error signing in with Google: $e');
        _notifySignInError(e.toString());
      }
    };
  }

  /// Notify the app that sign in is complete
  static void _notifySignInComplete() {
    // Create a custom event to notify the Flutter app
    final event = html.CustomEvent('googleSignInComplete');
    html.window.dispatchEvent(event);
  }

  /// Notify the app that there was an error signing in
  static void _notifySignInError(String error) {
    // Create a custom event to notify the Flutter app
    final event =
        html.CustomEvent('googleSignInError', detail: {'error': error});
    html.window.dispatchEvent(event);
  }
}
