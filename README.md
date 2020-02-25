# Employeeify
 
 Simple iOS app for downloading employee data and displaying it in a list.
 
 ## Notes
 - Opted to implement a simple Employee Detail view in SwiftUI; rather than condense all that information in the main list I opted to split it out into a detail view, and I rarely get a chance to work with SwiftUI. Note I noticed that the spacing for the non-square image of Jack Dorsey is a bit inconsistent.
 - Images are cached in the documents directory when downloaded so they do not need to be downloaded again, and at runtime images are cached in an `NSCache`-based cache which reduces loading images from file and can automatically free up resources in low-memory situations. In a production application one would also add some mechanism for clearing out old images from the documents directory.
 - Simple unit and UI tests are included, focused mainly on the different loading scenarios provided in the instructions. Again, I opted to spend a bit more time on these to experiment a bit with launch arguments and modularizing the data sources. The `DataProvider` is abstracted to not specify where the data is coming from, as it may be loaded directly from JSON files (in the case of testing) or from the API / disk cache. 
 - The app supports both iPhone and iPad, as well both Light and Dark Mode. 
