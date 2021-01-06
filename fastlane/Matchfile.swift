public class Matchfile: MatchfileProtocol {
    public var platform: String { return "macos" }
    public var gitUrl: String { return "https://github.com/supersimple33/certificates.git" }
    public var type: String { return "development" } // The default type, can be: appstore, adhoc, enterprise or development
    public var appIdentifier: [String] { return ["com.addisonhanrattie.TouchBarVisualizer"] }
//    public var username:String { return "" } // Your Apple Developer Portal username
}

// For all available options run `fastlane match --help`
// Remove the // in the beginning of the line to enable the other options
