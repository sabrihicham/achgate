#!/bin/bash

# Quick setup script for running the profile screen on web
# Usage: chmod +x setup_web.sh && ./setup_web.sh

echo "🚀 Setting up Flutter Web for Profile Screen Demo"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

echo "✅ Flutter found"

# Enable web support
echo "🌐 Enabling Flutter Web support..."
flutter config --enable-web

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Build for web
echo "🔨 Building for web..."
flutter build web --web-renderer html

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Web build successful!"
    echo ""
    echo "🎉 Profile Screen is ready for web!"
    echo ""
    echo "To run the app:"
    echo "  flutter run -d chrome"
    echo ""
    echo "To serve the built web app:"
    echo "  cd build/web && python3 -m http.server 8000"
    echo "  Then open: http://localhost:8000"
    echo ""
    echo "📱 The profile screen is responsive and optimized for:"
    echo "  • Desktop (1200px+)"
    echo "  • Tablet (768px - 1199px)"
    echo "  • Mobile (< 768px)"
else
    echo "❌ Build failed. Please check the errors above."
    exit 1
fi
