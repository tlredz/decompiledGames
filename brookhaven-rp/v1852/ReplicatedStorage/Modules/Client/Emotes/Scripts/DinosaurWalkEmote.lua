local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local DinosaurWalkEmote = {}
DinosaurWalkEmote.__index = DinosaurWalkEmote

function DinosaurWalkEmote.new()
	return (setmetatable({
		_janitor = Janitor.new()
	}, DinosaurWalkEmote))
end

function DinosaurWalkEmote:start(instance, object)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
		return
	end

	local sound = Instance.new("Sound")
	sound.Name = "DinosaurWalkStomp"
	sound.SoundId = "rbxassetid://98134976973041"
	sound.RollOffMaxDistance = 20
	sound.Parent = humanoidRootPart
	sound:AddTag("AdaptiveSound")
	self._janitor:Add(sound)
	self._janitor:Add(object:GetMarkerReachedSignal("Stomp"):Connect(function()
		sound:Play()
	end))
	self._janitor:Add(object.Stopped:Connect(function()
		self._janitor:Cleanup()
	end))
end

return DinosaurWalkEmote