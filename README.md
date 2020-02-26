# Employeeify
 
 Simple iOS app for downloading employee data and displaying it in a list.
 
 ## Tools
 - Xcode 11.3.1 (macOS 10.15.3)
 - iOS 13.2
 - Swift 5
 
 ## Focus Areas
 Beyond getting the basic functionality down, I used this as an opportunity to experiment a bit with modularizing the network calls so they can be swapped out easily (i.e. for unit and UI tests). I also took this as an chance to play around a bit more with SwiftUI for the `EmployeeDetailView`, since that was not an explicit requirement of the assignment, but the app felt incomplete without it. I distributed my time fairly evenly across building the interface, setting up the backend, and the testing framework.  
 
 ## Devices
 The app was primarily designed for the iPhone, but I have also ensured it works well on the iPad. It works best on iPhone 6 and up, as the text is a bit squished on smaller devices. It also works in both Portrait and Landscape orientation, as well as both Light and Dark Mode. With a bit more work the main list could support accessibility text sizes, but the detail view does a decent job.

## Copied-in Code
Only copied in a very simple SwiftUI view called `CircleImage` from Apple's SwiftUI tutorials. Otherwise, aimed to keep the project as simple as possible using only built-in APIs and the SDK. Components like the JSON decoding and diffable table view data source were not directly copied in but were straightforward as I had other personal projects using a similar setup. 

The app icon image is from [Icons8](https://icons8.com/icon/pack/characters/ios).

## Time Spent
The core work for the assignment took about 3 hours. I spent another few hours making the `DataProvider` architecture more testable, and experimenting with SwiftUI to build the detail view. I also added in the list sorting button to experiment with `KeyPath`.

## Additional Notes 
 - Images are cached in the documents directory when downloaded so they do not need to be downloaded again, and at runtime images are cached in an `NSCache`-based cache which reduces loading images from file and can automatically free up resources in low-memory situations. In a production application one would also add some mechanism for clearing out old images from the documents directory, and one could certainly create a more elaborate wrapper around `NSCache`.
 - Simple unit and UI tests are included, focused mainly on the different loading scenarios provided in the instructions. Again, I opted to spend a bit more time on these to experiment a bit with launch arguments and modularizing the data sources to provide a flexible framework for creating a variety of tests. The `DataProvider` is abstracted to not specify where the data is coming from, as it may be loaded directly from JSON files (in the case of testing) or from the API / disk cache.
 - Note the spacing around the image of Jack Dorsey in the SwiftUI view is actually inconsistent compared to the rendering of other employees because the image isn't square. Decided not to spend much time on fixing it.
 - The header that shows when the results are loading, empty, or there was an error is very simple, and could benefit from a nicer design. 
