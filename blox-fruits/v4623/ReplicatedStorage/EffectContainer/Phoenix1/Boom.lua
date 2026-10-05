local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
require(game.ReplicatedStorage.Util.ScaleParticle)
require(game.ReplicatedStorage.Util.RocksModule)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local boom = FX:WaitForChild("Phoenix1").Boom

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
	TweenInfo.new(0.27, Enum.EasingStyle.Sine),
	TweenInfo.new(0.3, Enum.EasingStyle.Sine),
	TweenInfo.new(0.12, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
	TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
	TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true)
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

return function(p)
	local cFrame = p.CFrame

	if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).magnitude > 320 then
		return
	end

	local cFrame2 = CFrame.new(cFrame.p, workspace.CurrentCamera.CFrame.p) * CFrame.Angles(1.5707963267948966, 0, 0)
	Util.Sound:Play("Phoenix1Boom", cFrame2)
	local explosion = boom.Explosion
	local clone = explosion:Clone()
	clone.Name = clone.Name

	if explosion:IsA("Model") then
		clone:SetPrimaryPartCFrame(cFrame2)
	else
		clone.CFrame = cFrame2
	end

	clone.Parent = _WorldOrigin
	Debris:AddItem(clone, 2)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	task.wait(0.05)

	if (workspace.CurrentCamera.CFrame.Position - cFrame2.Position).magnitude < 80 then
		Util.CameraShaker:Shake(Util.CameraShaker.Presets.Explosion2)
	end

	for _ = 1, 2 do
		local cFrame3 = clone.CFrame * CFrame.Angles(
			math.rad((math.random(0, 180))),
			math.rad((math.random(0, 180))),
			(math.rad((math.random(0, 180))))
		)
		local color1 = boom.Color1
		local clone2 = color1:Clone()
		clone2.Name = clone2.Name

		if color1:IsA("Model") then
			clone2:SetPrimaryPartCFrame(cFrame3)
		else
			clone2.CFrame = cFrame3
		end

		clone2.Parent = _WorldOrigin
		TweenService:Create(clone2, v[1], {
			Size = Vector3.new(clone2.Size.X * 7.5, clone2.Size.Y, clone2.Size.Z * 7.5),
			Transparency = 1
		}):Play()
		Debris:AddItem(clone2, 1)
	end
end