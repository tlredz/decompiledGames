local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
require(game.ReplicatedStorage.Util.ScaleParticle)
local SlantedRocks = require(game.ReplicatedStorage.Util.SlantedRocks)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local cannon = FX:WaitForChild("Phoenix1").Cannon

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
	TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true),
	TweenInfo.new(0.4, Enum.EasingStyle.Sine)
}

local function createEffect(cFrame, model, p, p2)
	local clone = model:Clone()
	clone.Name = p or clone.Name

	if model:IsA("Model") then
		clone:SetPrimaryPartCFrame(cFrame)
	else
		clone.CFrame = cFrame
	end

	clone.Parent = p2 or _WorldOrigin
	return clone
end

for _, emitter in pairs(cannon.release:GetDescendants()) do
	if emitter:IsA("ParticleEmitter") then
		Util.ScaleParticle({
			Emitter = emitter,
			Time = 0,
			Scale = 2
		})
	end
end

return function(player)
	local character = player.Character
	local humanoidRootPart = character.HumanoidRootPart

	if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 500 then
		return
	end

	if character == game.Players.LocalPlayer.Character or (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude < 50 then
		Util.CameraShaker:Shake(Util.CameraShaker.Presets.Explosion2)
		local clone = cannon.Blur:Clone()
		clone.Parent = game.Lighting
		TweenService:Create(clone, v[2], {
			Size = 0
		}):Play()
		Debris:AddItem(clone, 1)
	end

	Util.Sound:Play("Phoenix1Blast", humanoidRootPart.Position)
	local cFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -10) * CFrame.Angles(0, -1.57, 0)
	local release = cannon.release
	local clone = release:Clone()
	clone.Name = clone.Name

	if release:IsA("Model") then
		clone:SetPrimaryPartCFrame(cFrame)
	else
		clone.CFrame = cFrame
	end

	clone.Parent = _WorldOrigin
	Debris:AddItem(clone, 1)

	for _, child in pairs(clone.Attachment:GetChildren()) do
		local speed = child.Speed
		child.Speed = NumberRange.new(speed.Min * 2, speed.Max * 2)
		child:Emit(child:GetAttribute("EmitCount"))
	end

	local cFrame2 = humanoidRootPart.CFrame * CFrame.new(0, 0, -15)
	local wind = cannon.Wind
	local clone2 = wind:Clone()
	clone2.Name = clone2.Name

	if wind:IsA("Model") then
		clone2:SetPrimaryPartCFrame(cFrame2)
	else
		clone2.CFrame = cFrame2
	end

	clone2.Parent = _WorldOrigin
	Debris:AddItem(clone2, 1)
	TweenService:Create(clone2, v[4], {
		Transparency = 1,
		CFrame = clone2.CFrame * CFrame.new(0, 0, -6) * CFrame.Angles(0, 0, 1.57)
	}):Play()
	TweenService:Create(clone2.Mesh, v[4], {
		Scale = Vector3.new(clone2.Mesh.Scale.X * 1.25, clone2.Mesh.Scale.Y * 1.25, clone2.Mesh.Scale.Z * 2.5) * 1.75
	}):Play()
	SlantedRocks({
		Cframe = humanoidRootPart.CFrame,
		Size = 6,
		X = 10,
		Z = 15,
		Ammount = 12
	})
end