local TweenService = game:GetService("TweenService")
local resume = coroutine.resume
local create = coroutine.create
require(game.ReplicatedStorage.Util.BezierCurve)
game:GetService("RunService")
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local drill = FX:WaitForChild("DeathStep2").ModeBlue.Drill

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
	TweenInfo.new(0.2, Enum.EasingStyle.Sine),
	TweenInfo.new(0.2376, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	TweenInfo.new(0.09504, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
	TweenInfo.new(0.0792, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

local _ = { "RightLowerLeg", "RightFoot", "RightUpperLeg" }
return function(player)
	local character = player.Character
	local humanoidRootPart = character.HumanoidRootPart
	local random = Random.new()

	if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 800 then
		return
	end

	local effect = createEffect(humanoidRootPart.CFrame, drill.Charge, "DrillEffects" .. character.Name) -- equivalent call inferred; original call site unknown
	effect.Weld.Part0 = humanoidRootPart
	local effect2 = createEffect(humanoidRootPart.CFrame, drill.eff, "DrillEffects" .. character.Name) -- equivalent call inferred; original call site unknown
	effect2.Weld.Part0 = humanoidRootPart

	for _, child in pairs(effect2.Particles:GetChildren()) do
		local speed = child.Speed
		child.Speed = NumberRange.new(speed.Min * 2, speed.Max * 2)
		local lifetime = child.Lifetime
		child.Lifetime = NumberRange.new(lifetime.Min * 0.5, lifetime.Max * 0.5)
		local acceleration = child.Acceleration
		child.Acceleration = Vector3.new(acceleration.X * 2, acceleration.Y * 2, acceleration.Z * 2)
		child.Rate *= 2
	end

	local lastTime = tick()

	while player.Active and player.Active:IsDescendantOf(workspace) do
		local cFrame = humanoidRootPart.CFrame * CFrame.new(
			random:NextNumber(-1, 1) * 1.25,
			random:NextNumber(-2.5, 1.5) * 1.25,
			-1.25
		) * CFrame.Angles(random:NextNumber(-0.5, -0.1), random:NextNumber(1.2, 1.8), random:NextNumber(-0.5, -0.1))
		local clone = drill.Leg:Clone()
		clone.Name = clone.Name
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
		local v5 = random:NextNumber(4, 8) * 1.75
		local tween = TweenService:Create(clone, v[1], {
			CFrame = clone.CFrame * CFrame.new(17.5, 0, 0),
			Transparency = 1,
			Size = clone.Size * v5
		})
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()

		if tick() - lastTime > 0.05 then
			if humanoidRootPart then
				Util.Sound:Play("MeleeSwingLoud", humanoidRootPart.Position)
				tick()
			end

			lastTime = tick()
		end

		task.wait(0.016666666666666666)
	end

	Util.Sound:Play("MeleeSwingLoud", humanoidRootPart.Position)
	local cFrame2 = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
	local clone = drill.wave1:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame2
	clone.Parent = _WorldOrigin
	Debris:AddItem(clone, 1)

	for _, decal in pairs(clone.Dec:GetChildren()) do
		if decal:IsA("Decal") then
			TweenService:Create(decal, v[2], {
				Transparency = 1
			}):Play()
		end
	end

	resume(create(function()
		local cFrame3 = humanoidRootPart.CFrame

		for _ = 1, 3 do
			TweenService:Create(clone, v[3], {
				CFrame = cFrame3 * CFrame.Angles(-0.9424777960769379, 0, 0)
			}):Play()
			cFrame3 *= CFrame.Angles(-0.9424777960769379, 0, 0)
			task.wait(0.144)
		end
	end))
	local cFrame4 = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
	local clone2 = drill.wave2:Clone()
	clone2.Name = clone2.Name
	clone2.CFrame = cFrame4
	clone2.Parent = _WorldOrigin
	Debris:AddItem(clone2, 1)

	for _, decal in pairs(clone2.Dec:GetChildren()) do
		if decal:IsA("Decal") then
			TweenService:Create(decal, v[2], {
				Transparency = 1
			}):Play()
		end
	end

	resume(create(function()
		local cFrame3 = humanoidRootPart.CFrame

		for _ = 1, 3 do
			TweenService:Create(clone2, v[4], {
				CFrame = cFrame3 * CFrame.Angles(-0.9424777960769379, 0, 0)
			}):Play()
			cFrame3 *= CFrame.Angles(-0.9424777960769379, 0, 0)
			task.wait(0.12)
		end
	end))

	for _, folder in pairs({ effect, effect2 }) do
		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = false
			elseif descendant:IsA("Weld") then
				descendant:Destroy()
			end
		end

		folder.Anchored = true
		Debris:AddItem(folder, 1)
	end
end