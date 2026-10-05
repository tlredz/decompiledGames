local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Network = require(ReplicatedStorage.Modules.Network)
Network:listen("Tool/ReloadSnowball", function(parent, p)
	task.wait(0.4)
	local clone = ReplicatedStorage.Assets.Misc.NewSnowball:Clone()
	clone.Anchored = false
	clone.Parent = parent
	clone.Weld.Part0 = parent:FindFirstChild("LeftHand")
	Debris:AddItem(clone, p)
end)