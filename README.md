# Employeeify
 
 Simple iOS app for downloading employee data and displaying it in a list.
 
 Employee Detail view added as a bonus in SwiftUI.
 
 Images are cached in the documents directory when downloaded so they do not need to be downloaded again, and at runtime images are cached in an `NSCache`-based cache which reduces loading images from file and can automatically free up resources in low-memory situations.
 
 The `DataProvider` is abstracted to not specify where the data is coming from, as it may be loaded directly from JSON files (in the case of testing) or from the API / disk cache. 
