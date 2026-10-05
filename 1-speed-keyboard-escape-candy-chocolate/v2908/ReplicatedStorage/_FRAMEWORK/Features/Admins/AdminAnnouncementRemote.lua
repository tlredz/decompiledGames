local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if not RunService:IsServer() then
			return
		end

		local parent = ReplicatedStorage:FindFirstChild("Remotes")

		if not parent then
			parent = Instance.new("Folder")
			parent.Name = "Remotes"
			parent.Parent = ReplicatedStorage
		end

		if not parent:FindFirstChild("AdminAnnounce") then
			local remoteEvent = Instance.new("RemoteEvent")
			remoteEvent.Name = "AdminAnnounce"
			remoteEvent.Parent = parent
		end
	end
})
return {}