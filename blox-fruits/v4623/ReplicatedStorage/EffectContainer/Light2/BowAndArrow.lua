local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local masterClock = Util.MasterClock
local FX = require(game.ReplicatedStorage.FX)
local _WorldOrigin2 = workspace._WorldOrigin
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
	local range = data.Range

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
		return
	end

	sound:Play("Pika_LightKick", cFrame.p)
	local clone = script.BowFire:Clone()
	Util.Debris:AddItem(clone, 1)
	clone.CFrame = cFrame * CFrame.new(0, 0, -4)
	clone.Parent = _WorldOrigin

	for _, child in pairs(clone.Attachment:GetChildren()) do
		local emitCount = child:GetAttribute("EmitCount")

		if emitCount then
			child:Emit(emitCount)
		end
	end

	local v = math.min(range, (cFrame.p - targetCFrame.p).magnitude)
	local cframe = CFrame.new(cFrame.p, targetCFrame.p)
	local clone2 = script.LightArrow:Clone()

	local function fn(p, _)
		local clone3 = ReplicatedStorage.Assets.Models.ThinnerWind:Clone()
		clone3.Transparency = 0.01
		clone3.Color = Color3.fromRGB(255, 255, 110)
		clone3.CFrame = p * CFrame.Angles(0, 1.5707963267948966, 1.5707963267948966)
		clone3.Parent = _WorldOrigin2
		local tween = TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
			Transparency = 1,
			Size = clone3.Size * createVector(2, 2, 2) * 4.5,
			CFrame = clone3.CFrame * CFrame.new(0, 5, 0)
		})
		tween.Completed:Connect(function()
			clone3:Destroy()
		end)
		tween:Play()
		local clone4 = script.ArrowTravel.Attachment:Clone()
		clone4.Position = p.Position
		clone4.Parent = workspace.Terrain
		clone4.Sharp:Emit(10)
		Util.Debris:AddItem(clone4, 1)
	end

	local cframe2 = CFrame.Angles(0, 0, 1.5707963267948966)
	local clone3 = clone2:Clone()
	clone3.Anchored = true
	clone3.CFrame = cframe * cframe2
	clone3.Parent = _WorldOrigin2
	local v2 = {
		{ clone3.xAttachment0, clone3.xAttachment1, clone3.TrailTwo }
	}

	for _ = 1, 2 do
		local clone4 = clone3.xAttachment0:Clone()
		local clone5 = clone3.xAttachment1:Clone()
		local clone6 = clone3.TrailTwo:Clone()
		clone4.Parent = clone3
		clone5.Parent = clone3
		clone6.Parent = clone3
		clone6.Attachment0 = clone4
		clone6.Attachment1 = clone5
		table.insert(v2, { clone4, clone5, clone6 })
	end

	local v3 = masterClock:GetTime() - data.Timestamp
	local v4 = math.max(v / 1000 - v3, 0)
	local lastTime = tick()
	local now = 0

	while tick() - lastTime < v4 do
		local v5 = tick() - lastTime
		local v6 = math.min(1, (tick() - lastTime) / v4)
		clone3.CFrame = cframe:Lerp(targetCFrame, v6) * cframe2

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

	clone3.CFrame = targetCFrame
	clone3.Transparency = 1

	for _, emitter in pairs(clone3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	Util.Debris:AddItem(clone3, 2)
	local clone4 = script.ArrowBlast:Clone()
	Util.Debris:AddItem(clone4, 3)
	clone4.Position = targetCFrame.Position
	clone4.Parent = _WorldOrigin
	task.delay(2, function()
		if clone4 then
			clone4:Destroy()
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function mapRay(p, p2)
		local ray = Ray.new(p, p2)
		return workspace:FindPartOnRayWithWhitelist(ray, { workspace.Map })
	end

	local v7, _, _ = mapRay(targetCFrame.p - targetCFrame.LookVector, targetCFrame.LookVector * 5)

	for _, emitter in ipairs(clone4.Attachment:GetChildren()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		Util.Misc.ScaleParticle(emitter, 1.25)

		if emitter.Name == "Rocks" then
			if v7 then
				emitter.Color = ColorSequence.new(v7.Color)
			end
		else
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	TweenService:Create(clone4.Attachment.Light, TweenInfo.new(0.35), {
		Range = 0,
		Brightness = 0
	}):Play()

	if (workspace.CurrentCamera.CFrame.Position - targetCFrame.p).Magnitude < 100 then
		Util.CameraShaker:ShakeOnce(10, 10, 0.01, 0.6)
	end

	local ground = RocksModule.Ground
	local p = targetCFrame.p
	local v8 = { workspace.Map }
	ground(p, 50, createVector(6, 6.6666665, 6), v8, 8, false, 1.5, true)
	local raycastResult = workspace:Raycast(
		targetCFrame.Position + createVector(0, 2.5, 0),
		createVector(0, -30, 0),
		raycastParams
	)

	if raycastResult then
		local v9 = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 10) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		) * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
		local scar, v10, _ = FX:WaitForChild("Scar")
		local effect = createEffect(v9, scar, v10) -- equivalent call inferred; original call site unknown
		effect.Size = createVector(68.75, 0.125, 68.75)
		effect.Parent = workspace._WorldOrigin
		task.delay(1.5, function()
			if not effect:FindFirstChild("Decal") then
				effect:Destroy()
				return
			end

			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(effect.Decal, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
		end)
		Util.Debris:AddItem(effect, 2.5)
	end
end