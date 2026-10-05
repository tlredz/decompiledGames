local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local RocksModule = require(game.ReplicatedStorage.Util.RocksModule)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map

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
	TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(1.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
}

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Parent = p2 or _WorldOrigin
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	return clone
end

local currentCamera = workspace.CurrentCamera
local Util = require(game.ReplicatedStorage.Util)
return function(p)
	local cFrame = p.CFrame
	Util.Sound:Play("LoudTremorWave1", cFrame)

	if (cFrame.Position - currentCamera.CFrame.Position).Magnitude < 290 then
		Util.CameraShaker:ShakeOnce(12, 12, 0.1, 1)
	end

	local raycastResult = workspace:Raycast(cFrame.Position, createVector(0, -35, 0), raycastParams)

	if raycastResult then
		local cFrame2 = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 10) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		) * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
		local clone = script.Scar:Clone()
		clone.Parent = _WorldOrigin
		clone.Name = clone.Name
		clone.CFrame = cFrame2
		TweenService:Create(clone.Decal, v[2], {
			Transparency = 1
		}):Play()
		Util.Debris:AddItem(clone, 1.5)
		local cframe = CFrame.new(raycastResult.Position)
		local clone2 = script.MeshPart:Clone()
		clone2.Parent = _WorldOrigin
		clone2.Name = clone2.Name
		clone2.CFrame = cframe
		TweenService:Create(clone2, v[3], {
			Transparency = 1,
			Size = Vector3.new(clone2.Size.X * 3.5, clone2.Size.Y * 0, clone2.Size.Z * 3.5),
			Orientation = clone2.Orientation + createVector(0, 135, 0)
		}):Play()
		Util.Debris:AddItem(clone2, 1)
	end

	local clone = script.eff:Clone()
	clone.Parent = _WorldOrigin
	clone.Name = clone.Name
	clone.CFrame = cFrame
	Util.Debris:AddItem(clone, 2)

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if emitter.Name == "Rocks2" and raycastResult then
			emitter.Color = ColorSequence.new(raycastResult.Instance.Color)
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		elseif emitter.Name ~= "Rocks2" or raycastResult then
			local lifetime = emitter.Lifetime
			emitter.Lifetime = NumberRange.new(lifetime.Min * 1, lifetime.Max * 1)
			local speed = emitter.Speed
			emitter.Speed = NumberRange.new(speed.Min * 1, speed.Max * 1)
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	RocksModule.Ground(cFrame.Position, 40, createVector(6, 6.6666665, 6), { map }, 10, false, 1, true)
end