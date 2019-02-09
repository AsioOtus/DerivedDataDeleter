import Foundation

class Deleter {
	let targetDirectoryUrl: URL
	let ignoringDirectoriesNames: [String]
	let maxDepthLevel: UInt
	let directoryNameForDeleting: String
	
	let fileManager = FileManager.default
	var foundDirectories = [(url: URL, size: UInt64)]()
	
	var foundDirectoriesInfo: String {
		return foundDirectories.reduce(""){ $0 + "\($1.url) - \(ByteCountFormatter.string(fromByteCount: Int64($1.size), countStyle: .file))\n" }
	}
	
	init (
		targetDirectoryUrl: URL,
		ignoringDirectoriesNames: [String],
		maxDepthLevel: UInt,
		directoryNameForDeleting: String = "DerivedData"
	) {
		self.targetDirectoryUrl = targetDirectoryUrl
		self.ignoringDirectoriesNames = ignoringDirectoriesNames
		self.maxDepthLevel = maxDepthLevel
		self.directoryNameForDeleting = directoryNameForDeleting
	}
	
	func searchDirectories () {
		searchDirectories(at: targetDirectoryUrl)
	}
	
	private func searchDirectories (at url: URL, level: UInt = 0) {
		Log.directory(url.lastPathComponent, level)
		let directoryItemsNames: [String]
		
		do {
			directoryItemsNames = try fileManager.contentsOfDirectory(atPath: url.path)
		} catch {
			Log.error(error.localizedDescription, level)
			return
		}
		
		let directoryItemsUrls = directoryItemsNames.map{ url.appendingPathComponent($0, isDirectory: true) }
		
		var isDirectoryForDeletingFound = false
		
		for directoryItemUrl in directoryItemsUrls {
			if directoryItemUrl.lastPathComponent == directoryNameForDeleting {
				let foundDirectorySize = try! size(of: directoryItemUrl)
				foundDirectories.append((directoryItemUrl, foundDirectorySize))
				
				isDirectoryForDeletingFound = true
				break
			}
		}
		
		guard !isDirectoryForDeletingFound else {
			Log.warn("Found \(directoryNameForDeleting)", level)
			return
		}
		
		guard level <= maxDepthLevel else {
			Log.warn("Max level depth reached - \(maxDepthLevel)", level)
			return
		}
		
		for directoryItemUrl in directoryItemsUrls {
			guard
				isDirectoryExists(at: directoryItemUrl.path) &&
				!ignoringDirectoriesNames.contains(directoryItemUrl.lastPathComponent)
			else { continue }
			
			searchDirectories(at: directoryItemUrl, level: level + 1)
		}
	}
	
	func deleteFoundDirectories () {
		do {
			try foundDirectories.forEach {
				Log.directory("Deleting " + $0.url.path, 0)
				try fileManager.removeItem(atPath: $0.url.path)
			}
		} catch {
			Log.error(error.localizedDescription, 0)
		}
	}
	
	func isDirectoryExists (at path: String) -> Bool {
		var isDirectory = ObjCBool(true)
		let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
		return exists && isDirectory.boolValue
	}
	
	func size (of directoryUrl: URL) throws -> UInt64 {
		let directoryPath = directoryUrl.path
		
		let filesArray: [String] = try fileManager.subpathsOfDirectory(atPath: directoryPath) as [String]
		var fileSize:UInt64 = 0
		
		for fileName in filesArray {
			var fileUrl = URL(fileURLWithPath: directoryPath)
			fileUrl.appendPathComponent(fileName)
			let fileDictionary: NSDictionary = try fileManager.attributesOfItem(atPath: fileUrl.path) as NSDictionary
			fileSize += UInt64(fileDictionary.fileSize())
		}
		
		return fileSize
	}
}
