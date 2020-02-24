## FraudForce on Carthage

### Cartfile


`binary "https://iovation.github.io/deviceprint-SDK-iOS/FraudForce.json" >= 5.0.3`

* The **_origin_** should conform to the [binary only frameworks](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#binary-only-frameworks) style.
* Choose a [version requirement](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#version-requirement) befitting your project.
 * `5.0.0` is the minimum version that is compatiable with Carthage.

### Caveats
1. `carthage update` can return an error. This is a false failure, and it has been reported in the [Carthage GitHub repo](https://github.com/Carthage/Carthage) ([issue 2514](https://github.com/Carthage/Carthage/issues/2514)).
 * Error message, `A shell task (... dwarfdump ...) failed with exit code 1`
2. Following the Carthage integration instructions (both the [Quick Start](https://github.com/Carthage/Carthage#quick-start) and [Adding frameworks to an application](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application)) produces a build failure in Xcode. Removing `FraudForce.framework` from the “Embed Frameworks” build phase fixes the error (since the Carthage-recommended Run Script phase does the same job).


### Good luck!
