local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local Util = require(game.ReplicatedStorage.Util)
require(game.ReplicatedStorage.Util.ScaleParticle)
require(game.ReplicatedStorage.Util.CameraShaker)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }
local v = {
	TweenInfo.new(1, Enum.EasingStyle.Sine),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
}

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

return function(player)
	local character = player.Character
	local humanoidRootPart = character.HumanoidRootPart
	local holding = player.Holding

	if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 1200 then
		return
	end

	local cFrame = humanoidRootPart.CFrame
	local clone = script.Tornado:Clone()
	clone.Name = "SnowNado"
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	clone.BodyWeld.Part0 = humanoidRootPart

	if character == game.Players.LocalPlayer.Character then
		local clone2 = script.Blur:Clone()
		clone2.Name = "SnowNado"
		clone2.Parent = game.Lighting
		TweenService:Create(clone2, v[2], {
			Size = 7
		}):Play()
	end

	local v2 = Util.Sound:Play("WindTunnelLoop", humanoidRootPart, nil, 1.5)
	wait()

	while holding and holding.Value and holding:IsDescendantOf(character) do
		task.wait(0.1)
	end

	Util.Sound:FadeOut(v2, 0.5)
	local snowNado = game.Lighting:FindFirstChild("SnowNado")

	if snowNado and character == game.Players.LocalPlayer.Character then
		snowNado.Name ..= "Deactivated"
		TweenService:Create(snowNado, v[2], {
			Size = 0
		}):Play()
		Debris:AddItem(snowNado, 1)
	end

	if clone then
		clone.BodyWeld.Part0 = nil
		clone.Anchored = true

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		Debris:AddItem(clone, 1)
	end
end