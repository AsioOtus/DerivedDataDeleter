import Foundation

struct Log {
	static var isOn: Bool = true
	
	static func url (_ url: URL) {
		guard isOn else { return }
		
		print("Scan - \(url.path)")
	}
	
	static func directory (_ name: String, _ level: UInt) {
		guard isOn else { return }
		
		print(" ".repeating(4 * level) + name)
	}
	
	static func warn (_ message: String, _ level: UInt) {
		guard isOn else { return }
		
		print(" ".repeating(4 * level) + "WARN - " + message)
	}
	
	static func error (_ message: String, _ level: UInt) {
		guard isOn else { return }
		
		print(" ".repeating(4 * level) + "ERROR - " + message)
	}
}

extension String {
	func repeating (_ count: UInt) -> String {
		return String(repeating: " ", count: Int(count))
	}
}
