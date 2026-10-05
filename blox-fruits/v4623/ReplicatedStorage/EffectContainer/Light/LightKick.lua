local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local lightKick = FX:WaitForChild("LightEffects").LightKick
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local TweenService = game:GetService("TweenService")
local _ = Util.ScaleParticle

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(p, p2)
	return p * p2
end

local v = {
	TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
	TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true),
	TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, instance, p)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	return clone
end

local _ = Util.VignetteService
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = {
	_WorldOrigin,
	Workspace.CurrentCamera,
	Workspace.Characters,
	Workspace.Enemies
}
local rocksModule = Util.RocksModule
return function(data)
	local char = data.char
	local root = data.root
	local impactPos = data.impactPos
	local willImpact = data.willImpact
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local speedOfBeam = data.speedOfBeam

	if humanoid == nil or root == nil then
		return
	end

	local position = root.Position
	local v2 = (impactPos - position).Magnitude / speedOfBeam

	if (position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1600 then
		return
	end

	local effect = createEffect(
		CFrame.new(root.Position, impactPos) * CFrame.Angles(1.57, 0, 0) * CFrame.new(0, -8, 0),
		lightKick.MeshPart
	) -- equivalent call inferred; original call site unknown
	destroyAfter(effect, 0.5)
	TweenService:Create(effect, v[4], {
		Transparency = 1,
		Size = Vector3.new(0, effect.Size.Y * 2, 0)
	}):Play()
	local effect2 = createEffect(CFrame.new(), lightKick.Beam) -- equivalent call inferred; original call site unknown
	heartbeatLoopFor2(v2, function(_, _, p)
		local v4 = position + (impactPos - position) * p
		effect2.Size = Vector3.new(effect2.Size.X, (position - v4).Magnitude, effect2.Size.Z)
		effect2.CFrame = CFrame.lookAt(position, v4) * CFrame.new(0, 0, -((v4 - root.Position).Magnitude / 2)) * CFrame.Angles(
			1.5707963267948966,
			0,
			0
		)
	end, function()
		local impactPos2 = impactPos
		effect2.Size = Vector3.new(effect2.Size.X, (position - impactPos2).Magnitude, effect2.Size.Z)
		effect2.CFrame = CFrame.lookAt(position, impactPos2) * CFrame.new(
			0,
			0,
			-((impactPos2 - root.Position).Magnitude / 2)
		) * CFrame.Angles(1.5707963267948966, 0, 0)
		TweenService:Create(effect2, v[5], {
			Size = Vector3.new(0, effect2.Size.Y, 0)
		}):Play()
	end)
	destroyAfter(effect2, v2 + 0.31)
	task.spawn(function()
		for i = 3.5, 1.5, -1 do
			local effect3 = createEffect(
				CFrame.new(root.Position, impactPos) * CFrame.new(0, 0, -((impactPos - root.Position).Magnitude / i)) * CFrame.Angles(
					0,
					1.57,
					1.57
				),
				lightKick.Shockwave2
			) -- equivalent call inferred; original call site unknown
			TweenService:Create(effect3, v[4], {
				CFrame = effect3.CFrame * CFrame.new(0, 8.5, 0),
				Size = Vector3.new(effect3.Size.X * 2 * (i / 2.5), 0, effect3.Size.Z * 2 * (i / 2.5)),
				Transparency = 1
			}):Play()
			destroyAfter(effect3, 0.5)
			task.wait(v2 * 0.25)
		end
	end)
	Util.Sound:Play("Pika_LightKick", root.Position)
	task.wait(v2)
	local raycastResult = Workspace:Raycast(root.Position, (impactPos - root.Position) * 1.1, raycastParams)

	if not raycastResult or math.abs(((impactPos - root.Position).Unit:Dot(raycastResult.Normal))) < 0.2 then
		raycastResult = Workspace:Raycast(impactPos + createVector(0, 4, 0), createVector(-0, -8, -0), raycastParams)
	end

	local effect3 = createEffect(CFrame.new(impactPos), lightKick.eff) -- equivalent call inferred; original call site unknown
	destroyAfter(effect3, 1.55)

	for _, child in ipairs(effect3.Attachment:GetChildren()) do
		if child.Name == "smoke" or child.Name == "Rocks" then
			if willImpact and raycastResult then
				if child.Name ~= "Rocks" then
					child.Color = ColorSequence.new(raycastResult.Instance.Color)
				end

				child:Emit(child:GetAttribute("EmitCount"))
			end
		else
			child:Emit(child:GetAttribute("EmitCount"))
		end
	end

	Util.Sound:Play("Pika_LightKickExplosion", impactPos)

	for i = 1, 2 do
		local effect4 = createEffect(effect3.CFrame * CFrame.new(0, 3, 0), lightKick.Shockwave) -- equivalent call inferred; original call site unknown
		destroyAfter(effect4, 0.5)

		if i == 1 then
			TweenService:Create(effect4, v[5], {
				CFrame = effect4.CFrame * CFrame.new(0, -2, 0),
				Size = Vector3.new(effect4.Size.X * 2.5, 0, effect4.Size.Z * 2.5),
				Transparency = 1
			}):Play()
		else
			effect4.CFrame *= CFrame.new(0, 9, 0)
			TweenService:Create(effect4, v[5], {
				CFrame = effect4.CFrame * CFrame.new(0, -2, 0),
				Size = Vector3.new(effect4.Size.X * 1.75, 0, effect4.Size.Z * 1.75),
				Transparency = 1
			}):Play()
		end
	end

	if willImpact and raycastResult then
		local effect4 = createEffect(
			CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 10) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			) * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0),
			lightKick.Scar
		) -- equivalent call inferred; original call site unknown
		destroyAfter(effect4, 1.25)

		for _, child in ipairs(effect4:GetChildren()) do
			TweenService:Create(child, v[3], {
				Transparency = 1
			}):Play()
		end
	end

	if (Workspace.CurrentCamera.CFrame.Position - impactPos).Magnitude < 100 then
		Util.CameraShaker:ShakeOnce(10, 10, 0.01, 0.6)
	end

	local ground = rocksModule.Ground
	local v4 = { Workspace.Map }
	ground(impactPos, 43.75, createVector(5, 7, 5), v4, 12, false, 1, true)
end