import Nuke

// MARK: - ImagePipelineConfig

enum ImagePipelineConfig {

    static func setup() {
        let dataCache = try? DataCache(name: "com.beautyn.imageCache")
        dataCache?.sizeLimit = 150 * 1024 * 1024

        var config = ImagePipeline.Configuration()
        config.dataCache = dataCache
        config.imageCache = ImageCache(countLimit: 100)
        config.isProgressiveDecodingEnabled = true
        ImagePipeline.shared = ImagePipeline(configuration: config)
    }
}
