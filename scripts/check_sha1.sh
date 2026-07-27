#!/bin/bash

echo "--- Android SHA-1 Check ---"
if [ -f "android/gradlew" ]; then
    cd android
    ./gradlew signingReport | grep -A 5 "release" | grep "SHA1"
    echo ""
    echo "Copy the SHA-1 from 'release' variant and add it to Firebase Console."
else
    echo "Error: android/gradlew not found. Are you in the Flutter project root?"
fi
