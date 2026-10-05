local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Net = require(packages.Net)
local v = {}

local function collectNote(p: string)
	v[p] = true

	for _, v2 in CollectionService:GetTagged("VarnNote") do
		if v2.Name == p then
			v2:Destroy()
		end
	end
end

return {
	Start = function(_)
		if game.GameId == 7431162737 then
			return
		end

		local remoteEvent = Net:RemoteEvent("CultLairNotes/Collect")
		local remoteFunction = Net:RemoteFunction("CultLairNotes/GetCollected")
		remoteEvent.OnClientEvent:Connect(function(p: string)
			collectNote(p)
		end)
		CollectionService:GetInstanceAddedSignal("VarnNote"):Connect(function(instance)
			if v[instance.Name] then
				instance:Destroy()
			end
		end)
		local success, result = pcall(function()
			return remoteFunction:InvokeServer()
		end)

		if success and typeof(result) == "table" then
			for _, v2 in result do
				collectNote(v2)
			end
		end
	end
}