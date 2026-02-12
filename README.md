# Flutter Weather Module

This is a Flutter **module** designed to be embedded into a native Android or iOS application. It provides a weather search interface powered by the `wttr.in` service.

## Features
- **Weather Fetching**: Uses the `http` package to get JSON data from `https://wttr.in`.
- **Zero API Keys**: Uses the free `wttr.in` service.
- **Native Integration**: 
  - Uses `MethodChannel('com.weatherapp/navigation')` to communicate back to the host app.
  - Specifically implements a `goBack` method to handle navigation requests from the Flutter UI back to Native.

## How to use in Native Android
The module is integrated into the host app via `settings.gradle`:

```gradle
setBinding(new Binding([gradle: this]))
evaluate(new File(
  settingsDir.parentFile,
  'flutter_weather_module/.android/include_flutter.groovy'
))
```

And in the app-level `build.gradle`:

```gradle
dependencies {
    implementation project(':flutter')
}
```

## Communication Protocol
- **Channel Name**: `com.weatherapp/navigation`
- **Methods**:
  - `goBack`: Called by Flutter when the user clicks the back icon. The native host should listen for this and pop the Flutter view or switch screens.

## Local Development
Since this is a module, you can test it by running:
```bash
flutter run
```
within this directory, which will use the auto-generated `.android` or `.ios` wrapper projects.
