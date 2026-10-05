local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local remoteEvent = require3(ReplicatedStorage2.Packages.Net):RemoteEvent("DebugLog")
local DebugController = {
	Log = function(self, p: string, p2: string, p3, value: string?)
		if typeof(p3) == "table" then
			p3 = HttpService:JSONEncode(p3)
		end

		remoteEvent:FireServer(p, value or "normal", p2, p3)
	end
}

function DebugController.Info(_, p: string, p2: string, p3)
	DebugController:Log(p, p2, p3, "info")
end

function DebugController.Error(_, p: string, p2: string, p3)
	DebugController:Log(p, p2, p3, "error")
end

function DebugController.Warn(_, p: string, p2: string, p3)
	DebugController:Log(p, p2, p3, "warn")
end

return DebugController