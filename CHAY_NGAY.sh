#!/bin/bash

echo "========================================"
echo "  LLM Incident Reporting - Quick Start"
echo "========================================"
echo ""

echo "[1/3] Checking Node.js..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found! Please install Node.js first."
    exit 1
fi
echo "✅ Node.js found"
echo ""

echo "[2/3] Installing dependencies..."
npm install
if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi
echo "✅ Dependencies installed"
echo ""

echo "[3/3] Starting server..."
echo ""
echo "✅ Server is starting on http://localhost:3000"
echo "✅ Press Ctrl+C to stop"
echo ""
echo "To test, open another terminal and run:"
echo "   bash test-simple.sh"
echo ""
npm run dev

