#!/bin/bash

# EchoLingo Mobile Quick Start Script
# Navigate to project and start Expo with QR code for scanning

echo "🚀 Starting EchoLingo Mobile App for Expo Go..."
echo "=============================================="

# Navigate to the mobile directory
cd "$(dirname "$0")/mobile"

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: Cannot find mobile/package.json"
    echo "Please run this script from the Echo-Lingo-main directory"
    exit 1
fi

# Check if node is installed
if ! command -v node &> /dev/null; then
    echo "❌ Error: Node.js is not installed"
    echo "Please install Node.js: https://nodejs.org/"
    exit 1
fi

# Check if Expo CLI is available
if ! command -v npx &> /dev/null; then
    echo "❌ Error: npx is not available"
    exit 1
fi

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install dependencies"
        exit 1
    fi
fi

# Kill any existing processes on port 8081
echo "🧹 Cleaning up existing processes..."
lsof -ti:8081 | xargs kill -9 2>/dev/null || true
pkill -f "expo start" 2>/dev/null || true

# Start Expo development server
echo "📱 Starting Expo development server..."
echo ""

# Use the existing script from package.json which includes EXPO_NO_TELEMETRY=1
npm run dev

echo "=============================================="
echo "✅ To use with Expo Go:"
echo "📱 1. Install 'Expo Go' app on your phone"
echo "📱 2. Scan the QR code displayed above"
echo "📱 3. The app will load on your device"
echo ""
echo "💡 Alternative options:"
echo "📱 Press 'i' for iOS simulator"
echo "📱 Press 'a' for Android emulator"
echo "📱 Press 'w' for web browser"
echo ""
echo "Press Ctrl+C to stop the development server"
echo "=============================================="