# YogaPlayground

To use playground:
— Open "YogaPlayground.xcworksapce"
– Build "PlaygroundShim-Package" target

To update PlaygroundShim:
— Go to "Packages/PlaygroundShim"
— Run "swift package generate-xcodeproj"
— Open "YogaPlayground.xcworksapce"
— Select "PlaygroundShim/Yoga" target
— Set MODULEMAP_FILE = ../Yoga/Sources/Yoga.modulemap
