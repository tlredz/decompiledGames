local shared = script:WaitForChild("Shared")
local client = script:WaitForChild("Client")
return {
	Client = {
		StarwatchClient = require(client:WaitForChild("StarwatchClient")),
		SHA256 = require(client:WaitForChild("SHA256"))
	},
	Shared = {
		EventIngestor = shared:WaitForChild("StarwatchClientEventIngestor"),
		SafeCall = require(shared:WaitForChild("SafeCall")),
		HashUtils = require(shared:WaitForChild("HashUtils")),
		Enums = {
			DefaultEvents = require(shared:WaitForChild("Enums").DefaultEvents),
			DefaultGauges = require(shared:WaitForChild("Enums").DefaultGauges),
			Platform = require(shared:WaitForChild("Enums").Platform)
		}
	}
}