# PC Remote Control - Android Client

A modern Android application for remotely controlling a Windows PC. Built with Flutter for a beautiful, native mobile experience.

## Features

### Remote Control Capabilities
- **Mouse Control**: Full touchpad with sensitivity adjustment, tap for left click, long-press for right click, double-tap for double-click, and scroll support
- **Media Controls**: Play/pause, next/previous track, volume control, seek forward/backward
- **Browser Controls**: Navigate back/forward, refresh, manage tabs, close/open tabs
- **Window Management**: Alt+Tab, minimize, maximize, fullscreen, close windows
- **Text Input**: Send text directly to remote computer
- **Clipboard Sync**: Bidirectional clipboard synchronization with auto-sync option

### User Interface
- Modern Material Design 3 UI
- Dark/Light theme support (follows system theme)
- Tabbed interface for easy navigation
- Connection status indicator in app bar
- Responsive design optimized for mobile devices

## Installation

### Option 1: Install APK (Easiest)
1. Download the latest APK from releases
2. Enable "Install from Unknown Sources" in Android settings
3. Install the APK
4. Grant necessary permissions (Internet access)

### Option 2: Build from Source

#### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Android Studio or Android SDK
- Java Development Kit (JDK) 11 or higher
- Android device or emulator

#### Build Steps

1. **Clone the repository:**
```bash
git clone <repository-url>
cd pc_remote_client
```

2. **Install Flutter dependencies:**
```bash
flutter pub get
```

3. **Connect your Android device or start emulator:**
```bash
# Check connected devices
flutter devices

# Or start an emulator
flutter emulators --launch <emulator_id>
```

4. **Run in debug mode:**
```bash
flutter run
```

5. **Build release APK:**
```bash
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

6. **Build App Bundle (for Play Store):**
```bash
flutter build appbundle --release
```

## Usage

### Connecting to Remote PC

1. **Start the Remote Mouse Server** on your Windows PC
2. **Note the connection details:**
   - IP address (e.g., 192.168.1.100)
   - Port (default: 8765)
   - Authentication token (shown in server)
3. **Launch PC Remote Control** app on Android
4. **Go to Connection tab**
5. **Enter server address**: `192.168.1.100:8765`
6. **Enter authentication token**
7. **Tap Connect**

### Mouse Control

- **Move cursor**: Touch and drag on the trackpad area
- **Left click**: Single tap on trackpad
- **Right click**: Long-press on trackpad
- **Double click**: Double-tap on trackpad or use button
- **Scroll**: Use scroll gestures on trackpad
- **Adjust sensitivity**: Use slider (0.5x to 5.0x)

### Media Controls

Access the Media tab to:
- Control playback (play, pause, stop, next, previous)
- Adjust volume (up, down, mute)
- Seek in media (forward/backward)
- Quick space bar for pause/play

### Browser Controls

Access the Browser tab to:
- Navigate pages (back, forward, refresh, home)
- Manage tabs (new, close, next, previous)
- Quick shortcuts for common browser actions

### Window Management

Access the Window tab to:
- Switch applications (Alt+Tab)
- Control window state (minimize, maximize, fullscreen)
- Close active window

### Text Input

Access the Text tab to:
- Type multi-line text
- Send text to remote computer
- Text is typed exactly as entered

### Clipboard Sync

Access the Clipboard tab to:
- **Enable Auto Sync**: Automatically receive clipboard updates
- **Get Clipboard**: Manually fetch remote clipboard content
- **Copy to Local**: Copy remote clipboard to your device
- **Set Remote**: Send text to remote PC's clipboard

## Permissions

The app requires the following permissions:
- **INTERNET**: To connect to the remote PC server
- **ACCESS_NETWORK_STATE**: To check network connectivity

No other permissions are required. The app does NOT:
- Access your contacts
- Access your camera
- Access your files
- Track your location
- Show ads

## Connection Settings

Default settings for quick connection:
- **Server Address**: `192.168.1.100:8765`
- **Token**: `CHANGE_ME_1234`

**Important**: Change the default token for security!

## Security Considerations

1. **Change Default Token**: Never use `CHANGE_ME_1234` in production
2. **Use on Trusted Networks**: Only connect on private, secure WiFi networks
3. **Firewall Configuration**: Ensure Windows Firewall allows the server
4. **No Internet Exposure**: Keep the server on local network only
5. **Consider VPN**: For remote access outside local network

## Troubleshooting

### Cannot Connect
- ✓ Verify server is running on Windows PC
- ✓ Check IP address and port are correct
- ✓ Ensure both devices are on same WiFi network
- ✓ Verify firewall allows port 8765
- ✓ Check token matches server token

### Mouse Not Moving
- ✓ Adjust sensitivity slider
- ✓ Check server has proper Windows permissions
- ✓ Restart server and reconnect
- ✓ Try different sensitivity settings

### Clipboard Not Working
- ✓ Enable "Auto Clipboard Sync" in Clipboard tab
- ✓ Manually request with "Get Remote Clipboard"
- ✓ Check both devices have clipboard permissions

### Connection Drops
- ✓ Check WiFi signal strength
- ✓ Disable battery optimization for app
- ✓ Keep phone screen on during use
- ✓ Move closer to WiFi router

## API Documentation

For detailed API documentation, see [end-point.md](../end-point.md)

## System Requirements

### Android Device
- Android 5.0 (Lollipop) or higher (API level 21+)
- 50MB free storage
- WiFi connection
- Active network connection

### Windows PC (Server)
- Windows 10 or higher
- Remote Mouse Server installed and running
- Same network as Android device

## Technology Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **UI**: Material Design 3
- **Communication**: WebSocket (dart:io)
- **Platform**: Android (API 21+)

## Project Structure

```
pc_remote_client/
├── android/                      # Android-specific files
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── kotlin/          # Android Kotlin code
│   │   │   ├── res/             # Android resources
│   │   │   └── AndroidManifest.xml
│   │   └── build.gradle         # App-level Gradle config
│   ├── build.gradle             # Project-level Gradle config
│   └── gradle.properties        # Gradle properties
├── lib/
│   ├── main.dart                # App entry point
│   ├── screens/
│   │   └── home_screen.dart     # Main screen with tabs
│   ├── services/
│   │   └── websocket_service.dart # WebSocket communication
│   └── widgets/
│       ├── connection_panel.dart  # Connection UI
│       ├── mouse_control_panel.dart
│       ├── media_control_panel.dart
│       ├── browser_control_panel.dart
│       ├── window_control_panel.dart
│       ├── text_input_panel.dart
│       └── clipboard_panel.dart
├── pubspec.yaml                 # Flutter dependencies
└── README.md                    # This file
```

## Building for Production

### Generate Signed APK

1. **Create keystore:**
```bash
keytool -genkey -v -keystore ~/pc-remote.keystore -alias pc-remote -keyalg RSA -keysize 2048 -validity 10000
```

2. **Create `android/key.properties`:**
```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=pc-remote
storeFile=<path-to-keystore>/pc-remote.keystore
```

3. **Update `android/app/build.gradle`:**
Add before `android` block:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Update `buildTypes`:
```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

4. **Build signed APK:**
```bash
flutter build apk --release
```

## Privacy Policy

This app:
- Does NOT collect any personal data
- Does NOT send data to external servers
- Only connects to the IP address you specify
- Does NOT track usage or analytics
- Does NOT contain ads
- All communication stays on your local network

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Acknowledgments

- Built with Flutter by Google
- Uses Material Design 3
- WebSocket protocol for real-time communication

## Support

For issues or questions, please open an issue on GitHub.

---

**Version**: 1.0.0+1
**Platform**: Android
**Min SDK**: 21 (Android 5.0)
**Target SDK**: Latest
**Last Updated**: 2025-10-11
