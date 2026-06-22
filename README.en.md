[中文](README.md) | [English](README.en.md) | [日本語](README.ja.md)

# ProCropper PDF

A cross-platform PDF cropper built with Flutter, designed to provide a smarter and more efficient PDF margin-cropping experience on both mobile and desktop. It runs as a standalone application and does not require any additional runtime environment.

This project is inspired by Briss's overlay preview and grouped cropping workflow, and further improves and refines that approach.
The system can automatically analyze page structure based on page content (text/ink distribution), split pages into different cropping groups, and generate matching crop areas, significantly reducing manual work for users.

# Features

- [x] PDF overlay preview
- [x] Multiple intelligent page grouping strategies
- [x] Automatic crop box generation
- [x] Manual crop box adjustment
- [x] Copy and paste crop boxes across multiple pages
- [x] Multiple crop boxes for a single group to support page-splitting workflows
- [x] Manual filtering of page edge areas
- [x] Aspect ratio locking for a full-screen experience across different screen sizes
- [x] Outward margin expansion mode
- [x] Share-based PDF import/export on mobile
- [x] Parameter-based and drag-and-drop import on desktop
- [x] Drag-and-drop PDF import on the home page
- [x] Responsive editor layout for both large and small screens
- [x] Multiple languages supported (Chinese, English, Japanese)
- [x] E-ink display optimization
- [x] Encrypted PDF processing
- [x] Preview cropped results
- [x] Multi-window support (experimental)
- [x] Fully automatic batch cropping
- [ ] Performance optimization and improved large-file support

# Supported Platforms

- [x] Windows
- [x] macOS
- [x] Android
- [x] iOS
- [x] Linux (experimental)
- [ ] OHOS (in progress)

# Screenshots

### Standard Mode (Tablet, Desktop)
![Standard Mode](assets/snapshots/snapshot.png)

### Compact Mode (Phone)
![Compact Mode](assets/snapshots/snapshot_compact.png)
