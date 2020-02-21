## FraudForce on Carthage

### Cartfile

For example:

`binary "https://iovation.github.io/deviceprint-SDK-iOS/FraudForce.js" >= 5.0.0`

(Choose a "version requirement" befitting your project. 5.0.0. is the minimum version that is compatiable with Carthage.)

### Caveats
1. `carthage update` will return an error. This is a false failure, and it has been reported in the [Carthage GitHub repo](https://github.com/Carthage/Carthage) ([issue 2514](https://github.com/Carthage/Carthage/issues/2514)).
2. Following the Carthage integration instructions (both the “Quick Start” and “Adding frameworks to an application”) produces a build failure in Xcode. Removing `FraudForce.framework` from the “Embed Frameworks” build phase fixes the error (since the Carthage-recommended Run Script phase does the same job).


###Good luck!
