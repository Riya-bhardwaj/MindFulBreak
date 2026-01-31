import Foundation

struct AppConfig: Codable {
    let workDurationMinutes: Int
    let breakDurationSeconds: Int
    let warningTimeSeconds: Int

    static let `default` = AppConfig(
        workDurationMinutes: 25,
        breakDurationSeconds: 300,
        warningTimeSeconds: 5
    )
}

class ConfigManager {
    static let shared = ConfigManager()

    private(set) var config: AppConfig

    private init() {
        config = Self.loadConfig()
    }

    private static func loadConfig() -> AppConfig {
        // Try to load from bundle resources
        if let url = Bundle.main.url(forResource: "config", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let config = try JSONDecoder().decode(AppConfig.self, from: data)
                return config
            } catch {
                print("Failed to load config from bundle: \(error)")
            }
        }

        // Try to load from Sources/Resources directory (development)
        let fileManager = FileManager.default
        let currentPath = fileManager.currentDirectoryPath
        let configPath = "\(currentPath)/Sources/Resources/config.json"

        if fileManager.fileExists(atPath: configPath) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: configPath))
                let config = try JSONDecoder().decode(AppConfig.self, from: data)
                return config
            } catch {
                print("Failed to load config from file: \(error)")
            }
        }

        // Return default config
        return AppConfig.default
    }

    var workDurationSeconds: TimeInterval {
        TimeInterval(config.workDurationMinutes * 60)
    }

    var breakDurationSeconds: TimeInterval {
        TimeInterval(config.breakDurationSeconds)
    }

    var warningTimeSeconds: TimeInterval {
        TimeInterval(config.warningTimeSeconds)
    }
}
