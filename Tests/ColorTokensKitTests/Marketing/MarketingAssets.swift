import Foundation
import os
import SwiftUI

import CoreImage

/// Generates marketing assets for the README and documentation
@MainActor
public struct MarketingAssets {
    private static let logger = Logger(
        subsystem: "com.colortokenskit.marketing",
        category: "AssetGeneration"
    )

    /// Generates all marketing assets
    public static func generateAssets(in directory: URL) {
        logger.info("Starting marketing asset generation")

        // Generate each asset
        generateColorGrid(in: directory)
        generateColorSystemComparison(in: directory)
        generateCoverImage(in: directory)
        generateSimpleCardViewImage(in: directory)
        generateSimpleCardViewDarkModeImage(in: directory)
        generatePillViewImage(in: directory)

        logger.info("Completed marketing asset generation")
    }

    private static func generateColorGrid(in directory: URL) {
        logger.info("Generating color grid image...")
        let view = ColorGridView()
        saveImage(view, name: "color-grid", size: ImageSize.size, in: directory)
    }

    private static func generateColorSystemComparison(in directory: URL) {
        logger.info("Generating color system comparison image...")
        let view = ColorSystemComparisonView()
        saveImage(view, name: "color-system-comparison", size: ImageSize.size, in: directory)
    }

    private static func generateCoverImage(in directory: URL) {
        logger.info("Generating cover image...")
        let view = CoverImageView()
        saveImage(view, name: "cover-image", size: ImageSize.size, in: directory)
    }
    
    private static func generateSimpleCardViewImage(in directory: URL) {
        logger.info("Generating simple card view image...")
        let view = ThemedCardView()
        saveImage(view, name: "simple-card-view", size: ImageSize.size, in: directory)
    }
    
    private static func generateSimpleCardViewDarkModeImage(in directory: URL) {
        logger.info("Generating simple card view image...")
        let view = ThemedCardView().colorScheme(.dark)
        saveImage(view, name: "simple-card-dark-mode-view", size: ImageSize.size, in: directory)
    }

    private static func generatePillViewImage(in directory: URL) {
        logger.info("Generating pill view image...")
        let view = PillView()
        saveImage(view, name: "pill-view", size: ImageSize.size, in: directory)
    }
    
	private static func saveImage(_ view: some View, name: String, size: CGSize, in directory: URL) {
		do {
			let someView = view.frame(width: size.width, height: size.height)
			let renderer = ImageRenderer(content: someView)
			let ciContext = CIContext()
			let ciImage = CIImage(cgImage: renderer.cgImage!)
			let destinationPath = directory.appendingPathComponent("\(name).png")
			try ciContext.writePNGRepresentation(of: ciImage, to: destinationPath , format: .RGBA8, colorSpace: ciImage.colorSpace!)
		} catch {
			logger.error("Failed to save \(name) image: \(error.localizedDescription)")
		}
	}
}
