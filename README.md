# Swiss Calculator & Vault

A sleek, cross-platform Flutter application that functions as a highly precise standard/scientific calculator on the surface, but reveals an encrypted local storage vault when a custom PIN sequence is keyed in.

## Features

- **Surface Calculator:** Full standard mathematical functions, historical tracking, and a sliding panel for advanced operations.
- **Dynamic Theme Engine:** Swaps cleanly between deep dark profiles and light profiles based on system theme.
- **Hidden Privacy Space:** Accessible via a user-defined numeric password bypass.
  - **Secure Notes:** Fully encrypted scratchpad memory with an inline immediate "panic wipe" kill switch.
  - **Isolated Media Gallery:** Internal image pipeline that completely bypasses the host operating system's native photo galleries.
  - **Advanced Viewfinder:** Dedicated hardware integration supporting aspect ratio locking (1:1, 3:4, 9:16) and variable linear focal zoom.

## Tech Stack

- **Framework:** Flutter / Dart
- **Storage Tier:** SharedPreferences (Persistent Key-Value Ecosystem)
- **Hardware Integrations:** Camera API, PathProvider File Sandbox