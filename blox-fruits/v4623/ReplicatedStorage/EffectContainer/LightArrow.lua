local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local _ = Util.Sound
local masterClock = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local function ScaleParticle(state, p)
	local numberSequenceKeypoints = {}

	for _, keypoint in next, state.Size.Keypoints, nil do
		local v = keypoint.Value * p
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, v, v < keypoint.Envelope and v or keypoint.Envelope)
		)
	end

	state.Speed = NumberRange.new(state.Speed.Min * p, state.Speed.Max * p)
	return NumberSequence.new(numberSequenceKeypoints)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, scar, p, _)
	local clone = scar:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	return clone
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { workspace.Map }
local RocksModule = require(game.ReplicatedStorage.Util.RocksModule)
return function(data)
	local cFrame = data.CFrame
	local targetCFrame = data.TargetCFrame

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
		return
	end

	local v = math.min(500, (cFrame.p - targetCFrame.p).magnitude)
	local cframe = CFrame.new(cFrame.p, targetCFrame.p)
	local lightArrow = ReplicatedStorage.Assets.Models.LightArrow

	local function fn(p, _)
		local clone = ReplicatedStorage.Assets.Models.ThinnerWind:Clone()
		clone.Transparency = 0.01
		clone.Color = Color3.fromRGB(255, 255, 110)
		clone.CFrame = p * CFrame.Angles(0, 1.5707963267948966, 1.5707963267948966)
		clone.Parent = _WorldOrigin
		local tween = TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
			Transparency = 1,
			Size = clone.Size * createVector(2, 2, 2) * 4.5,
			CFrame = clone.CFrame * CFrame.new(0, 5, 0)
		})
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()
		local clone2 = FX:WaitForChild("Attachments").LightExplosion:Clone()
		clone2.PointLight:Destroy()
		clone2.Explosion.Size = ScaleParticle(clone2.Explosion, 3)
		clone2.Position = p.p
		clone2.Parent = workspace.Terrain
		clone2.Explosion:Emit(7)
		Util.Debris:AddItem(clone2, 1)
	end

	local cframe2 = CFrame.Angles(0, 0, 1.5707963267948966)
	local clone = lightArrow:Clone()
	clone.Anchored = true
	clone.CFrame = cframe * cframe2
	clone.Parent = _WorldOrigin
	local v2 = {
		{ clone.xAttachment0, clone.xAttachment1, clone.TrailTwo }
	}

	for _ = 1, 2 do
		local clone2 = clone.xAttachment0:Clone()
		local clone3 = clone.xAttachment1:Clone()
		local clone4 = clone.TrailTwo:Clone()
		clone2.Parent = clone
		clone3.Parent = clone
		clone4.Parent = clone
		clone4.Attachment0 = clone2
		clone4.Attachment1 = clone3
		table.insert(v2, { clone2, clone3, clone4 })
	end

	local v3 = masterClock:GetTime() - data.Timestamp
	local v4 = math.max(v / 500 - v3, 0)
	local lastTime = tick()
	local now = 0

	while tick() - lastTime < v4 do
		local v5 = tick() - lastTime
		local v6 = math.min(1, (tick() - lastTime) / v4)
		clone.CFrame = cframe:Lerp(targetCFrame, v6) * cframe2

		if tick() - now > 0.03333333333333333 then
			now = tick()
			fn(cframe:Lerp(targetCFrame, v6), 7)
		end

		for k, v7 in pairs(v2) do
			local v8 = (10 - k * 1.5) * (1 - v6)
			local v9 = 6.283185307179586 * (k / 3)
			local cframe3 = CFrame.new(math.sin(v5 * 20 + v9) * v8, math.cos(v5 * 20 + v9) * v8, 0)
			v7[1].CFrame = cframe3 + createVector(0, 0.75, 0)
			v7[2].CFrame = cframe3 - createVector(0, 0.75, 0)
		end

		RunService.RenderStepped:Wait()
	end

	clone.CFrame = targetCFrame
	clone.Transparency = 1

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	Util.Debris:AddItem(clone, 2)
	local clone2 = FX:WaitForChild("Attachments").LightExplosion:Clone()
	clone2.PointLight.Range = 80
	clone2.PointLight.Brightness = 15
	clone2.Position = targetCFrame.p
	clone2.Parent = workspace.Terrain
	clone2.Star.Size = ScaleParticle(clone2.Star, 6)
	clone2.Star_Color.Size = ScaleParticle(clone2.Star_Color, 12)
	clone2.Explosion.Size = ScaleParticle(clone2.Explosion, 12)
	clone2.Star:Emit(3)
	clone2.Star_Color:Emit(3)
	clone2.Explosion:Emit(50)
	TweenService:Create(clone2.PointLight, TweenInfo.new(0.3), {
		Brightness = 0,
		Range = 40
	}):Play()
	local ground = RocksModule.Ground
	local p = targetCFrame.p
	local v5 = { workspace.Map }
	ground(p, 45, createVector(6, 6.6666665, 6), v5, 8, false, 1.5, true)
	local raycastResult = workspace:Raycast(
		targetCFrame.Position + createVector(0, 2.5, 0),
		createVector(0, -30, 0),
		raycastParams
	)

	if raycastResult then
		local v6 = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 10) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		) * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
		local scar, v7, _ = FX:WaitForChild("Scar")
		local effect = createEffect(v6, scar, v7) -- equivalent call inferred; original call site unknown
		effect.Size = createVector(56.25, 0.125, 56.25)
		effect.Parent = workspace._WorldOrigin
		task.delay(1.5, function()
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(effect.Decal, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
		end)
		Util.Debris:AddItem(effect, 2.5)
	end

	wait(2)
	clone2:Destroy()
end