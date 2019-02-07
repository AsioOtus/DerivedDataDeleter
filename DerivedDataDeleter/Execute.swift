import Foundation

func execute (
	targetDirectoryPath: String,
	ignoringDirectoriesNames: [String],
	maxDepthLevel: UInt,
	logs: Bool = true,
	directoryNameForDeleting: String = "DerivedData"
) {
	Log.isOn = logs
	
	let targetDirectoryUrl = URL(fileURLWithPath: targetDirectoryPath)
	
	let deleter = Deleter(
		targetDirectoryUrl: targetDirectoryUrl,
		ignoringDirectoriesNames: ignoringDirectoriesNames,
		maxDepthLevel: maxDepthLevel
	)
	
	print("Search START")
	
	deleter.searchDirectories()
	
	print("Search COMPLETED")
	
	print()
	
	if !deleter.foundDirectories.isEmpty {
		print("Found \(directoryNameForDeleting) directories:")
		printFoundDirectories(deleter.foundDirectories)
		print()
	
		print("Found directories:")
		print("Count - \(deleter.foundDirectories.count)")
		print("Size - \(ByteCountFormatter.string(fromByteCount: Int64(deleter.foundDirectories.map{ $0.size }.reduce(0, +)), countStyle: .file))")
		print()
	
		print("Delete found directories? (enter Y for continues)")
		print("> ", terminator: "")
		let continueDeleting = readLine()
		
		if let continueDeleting = continueDeleting, continueDeleting == "Y" {
			print("Deleting START")
			deleter.deleteFoundDirectories()
			print("Deleting COMPLETED")
		}
	} else {
		print("\(directoryNameForDeleting) directories not found")
	}
}


func printFoundDirectories (_ directories: [(url: URL, size: UInt64)]) {
	for directory in directories {
		print("\(directory.url) - \(ByteCountFormatter.string(fromByteCount: Int64(directory.size), countStyle: .file))")
	}
}
