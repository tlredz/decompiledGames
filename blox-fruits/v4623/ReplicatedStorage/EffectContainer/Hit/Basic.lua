local util = game.ReplicatedStorage:WaitForChild("Util")
local Debris = require(util.Debris)
require(game.ReplicatedStorage.Util.Sound)
require(game.ReplicatedStorage.Effect)
game:GetService("TweenService")
game:GetService("RunService")
local ScaleParticle = require(game.ReplicatedStorage.Util.ScaleParticle)

for _, child in pairs(script.Attachments.Hit:GetChildren()) do
	ScaleParticle({
		Emitter = child,
		Scale = 1.35,
		Time = 0,
		EasingStyle = Enum.EasingStyle.Linear,
		EasingDirection = Enum.EasingDirection.Out
	})
end

local function func(p)
	local position = p.Position
	assert(position, "Position not found.")

	if (position - workspace.CurrentCamera.CFrame.p).Magnitude > 150 then
		return
	end

	local clone = script.Attachments.Hit:Clone()
	clone.Position = position
	clone.Parent = workspace.Terrain

	for _, child in pairs(clone:GetChildren()) do
		child:Emit((math.ceil((child:GetAttribute("EmitCount") or 1) * 1.25)))
	end

	Debris:AddItem(clone, 2)
end

return func