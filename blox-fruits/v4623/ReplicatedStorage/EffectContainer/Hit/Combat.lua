local util = game.ReplicatedStorage:WaitForChild("Util")
local Debris = require(util.Debris)
require(game.ReplicatedStorage.Util.Sound)
require(game.ReplicatedStorage.Effect)
game:GetService("TweenService")
game:GetService("RunService")
local ScaleParticle = require(game.ReplicatedStorage.Util.ScaleParticle)
local v = {
	Sword = 1.75,
	Kitsune = 1.85,
	Angel = 0.55
}

for _, emitter in pairs(script:GetDescendants()) do
	if emitter:IsA("ParticleEmitter") then
		ScaleParticle({
			Emitter = emitter,
			Scale = v[emitter.Parent.Name] or 1.3333,
			Time = 0
		})
	end
end

local function func(data)
	local position = data.Position

	if (position - workspace.CurrentCamera.CFrame.p).Magnitude > 150 then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Position = position
	attachment.Parent = workspace.Terrain

	for _, child in pairs(script[data.Type]:GetChildren()) do
		local clone = child:Clone()

		if data.Scale then
			ScaleParticle({
				Emitter = clone,
				Scale = data.Scale,
				Time = 0
			})
		end

		clone.Parent = attachment
		clone:Emit(child:GetAttribute("EmitCount") or 1)
	end

	Debris:AddItem(attachment, 2)
end

return func