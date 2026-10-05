local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local onyxLavaSplash = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("OnyxLavaSplash")
return function(p, position, value)
	local raycastResult = Utility:Raycast(
		position,
		position - createVector(0, 1, 0),
		500,
		{ p },
		Enum.RaycastFilterType.Include
	)

	if raycastResult.Instance then
		position = raycastResult.Position
	end

	local clone = onyxLavaSplash:Clone()
	clone.Size = createVector(1, 1, 1)
	clone.CanCollide = true
	clone.CollisionGroup = "IgnoreEntities"
	clone.CFrame = CFrame.new(position)
	clone.Parent = workspace
	clone.Attachment.LavaDroplets.Color = ColorSequence.new(p.Color)
	clone.Attachment.LavaDroplets:Emit(25)
	BetterDebris:AddItem(clone, 5)
	Utility:CreateSound(value or "rbxassetid://12100798607", 1, 1 + 0.25 * math.random(), clone, true, 5)
end