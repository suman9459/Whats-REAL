#!/bin/bash
echo "Please manually add these files to your Xcode project:"
echo "1. Right-click on 'Services' folder in Xcode"
echo "2. Select 'Add Files to Whats REAL...'"
echo "3. Navigate to Whats REAL/Whats REAL/Services/"
echo "4. Select all .swift files EXCEPT FirebaseAuthService.swift"
echo "5. Make sure 'Copy items if needed' is UNCHECKED"
echo "6. Make sure 'Add to targets: Whats REAL' is CHECKED"
echo "7. Click Add"
echo ""
echo "Repeat for Models folder:"
echo "1. Right-click on 'Models' folder in Xcode"  
echo "2. Add all .swift files from Whats REAL/Whats REAL/Models/"
echo ""
echo "Files to add in Services:"
find "Whats REAL/Whats REAL/Services" -name "*.swift" ! -name "FirebaseAuthService.swift" -exec basename {} \;
echo ""
echo "Files to add in Models:"
find "Whats REAL/Whats REAL/Models" -name "*.swift" -exec basename {} \;
