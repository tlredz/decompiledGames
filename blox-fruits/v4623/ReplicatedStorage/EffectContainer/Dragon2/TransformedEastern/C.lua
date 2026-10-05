local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local FX = require(game.ReplicatedStorage.FX)
local C = FX:WaitForChild("Dragon2").TransformedEastern.C
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
local Signal2 = require(game.ReplicatedStorage.Util.Signal2)
local TweenCoordinator = require(ReplicatedStorage:WaitForChild("Util"):WaitForChild("TweenCoordinator"))
local v = {
	[Enum.EasingStyle.Linear] = TweenCoordinator.ease.linear,
	[Enum.EasingStyle.Quad] = {
		In = TweenCoordinator.ease.quadIn,
		Out = TweenCoordinator.ease.quadOut,
		InOut = TweenCoordinator.ease.quadInOut
	},
	[Enum.EasingStyle.Cubic] = {
		In = TweenCoordinator.ease.quadIn,
		Out = TweenCoordinator.ease.cubicOut,
		InOut = TweenCoordinator.ease.quadInOut
	},
	[Enum.EasingStyle.Sine] = {
		In = TweenCoordinator.ease.quadIn,
		Out = TweenCoordinator.ease.sineOut,
		InOut = TweenCoordinator.ease.quadInOut
	}
}

local function resolveEase(p, p2)
	local selected = v[p] or v[Enum.EasingStyle.Quad]

	if typeof(selected) == "function" then
		return selected
	end

	if p2 == Enum.EasingDirection.In then
		return selected.In
	end

	if p2 == Enum.EasingDirection.Out then
		return selected.Out
	end

	return selected.InOut
end

local function TweenProps(p, data, items)
	local time2 = data.Time or 0.2
	local easingStyle = data.EasingStyle
	local easingDirection = data.EasingDirection
	local out = v[easingStyle] or v[Enum.EasingStyle.Quad]

	if typeof(out) ~= "function" then
		if easingDirection == Enum.EasingDirection.In then
			out = out.In
		elseif easingDirection == Enum.EasingDirection.Out then
			out = out.Out
		else
			out = out.InOut
		end
	end

	local completed = Signal2.new()
	local count = 0
	local count2 = 0
	local flag = false
	local tweenProperties = {}
	local flag2 = false

	for _ in pairs(items) do
		count += 1
	end

	local function onOneDone()
		count2 += 1

		if count <= count2 then
			completed:Fire(p)
		end
	end

	return {
		Play = function(self)
			if flag then
				return
			end

			tweenProperties = {}
			count2 = 0

			for k, item in pairs(items) do
				local tweenProperty = TweenCoordinator.tweenProperty(p, k, item, time2, out, onOneDone)
				table.insert(tweenProperties, tweenProperty)
			end

			if flag2 then
				for _, v3 in ipairs(tweenProperties) do
					TweenCoordinator.pause(v3)
				end
			end
		end,
		Pause = function(_)
			flag2 = true

			for _, v3 in ipairs(tweenProperties) do
				TweenCoordinator.pause(v3)
			end
		end,
		Resume = function(_)
			flag2 = false

			for _, v3 in ipairs(tweenProperties) do
				TweenCoordinator.resume(v3)
			end
		end,
		Cancel = function(_)
			flag = true

			for _, v3 in ipairs(tweenProperties) do
				TweenCoordinator.cancel(v3)
			end

			tweenProperties = {}
		end,
		Completed = completed
	}
end

local lightningBolt2 = Util.LightningBolt2
local sound = Util.Sound
Util.ResizeModel(C.Phase3.FlyRock, 2, C.Phase3.FlyRock.Position)
Util.ResizeModel(C.Phase3.FireProjectile2, 0.175, C.Phase3.FireProjectile2)
local tasklib = require(game.ReplicatedStorage.Util.tasklib)
local v2 = tasklib("FX", 0.004, true)
local partCache = Util.PartCache
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local cameraShaker = Util.CameraShaker
local v3 = 0
local v4 = 0
local waterBasePlane = nil
task.spawn(function()
	waterBasePlane = workspace.Map:WaitForChild("WaterBase-Plane", 9999)
end)
local v5 = {}

local function ensurePartCaches(player, p)
	local v6 = v5[player]

	if v6 then
		return v6
	end

	v5[player] = {}
	local model = Instance.new("Model", _WorldOrigin)
	model.Name = `{player.Name}Eastern_C_FX`

	if p then
		task.wait()
	end

	local model2 = Instance.new("Model", model)
	model2.Name = "FocusTrailFolder_Dragon2"
	local clone = C.Phase4.FocusTrail:Clone()
	local focusTrailCache = partCache.new(clone, 38)

	if p then
		task.wait()
	end

	focusTrailCache:SetCacheParent(model2)
	local model3 = Instance.new("Model", model)
	model3.Name = "ProjectileFolder_Dragon2"
	local clone2 = C.Phase3.FireProjectile2:Clone()
	local projectileCache = partCache.new(clone2, 38)

	if p then
		task.wait()
	end

	projectileCache:SetCacheParent(model3)
	local model4 = Instance.new("Model", model)
	model4.Name = "FlyRockFolder_Dragon2"
	local flyRockCache = partCache.new(C.Phase3.FlyRock, 76)

	if p then
		task.wait()
	end

	flyRockCache:SetCacheParent(model4)
	v5[player] = {
		FlyRockCache = flyRockCache,
		FlyRockFolder = model4,
		ProjectileCache = projectileCache,
		ProjectileFolder = model3,
		FocusTrailCache = focusTrailCache,
		FocusTrailFolder = model2
	}
	local playerRemovingConnection = nil
	playerRemovingConnection = game.Players.PlayerRemoving:Connect(function(player2)
		if player2 == player then
			model:Destroy()
			playerRemovingConnection:Disconnect()
		end
	end)
	return v5[player]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v6 = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v6 = math.max(v6, emitter.Lifetime.Max + emitter:GetAttribute("EmitDelay"))
			end
		end

		task.wait(v6)
		folder:Destroy()
	end)
end

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).Magnitude <= p2 then
			callback()
		end
	end
end

local function AlignCFrame(data, normal)
	local v6 = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v6).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v6).Unit
	return CFrame.fromMatrix(p, unit2, v6, unit3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ScreenEffect(position, p, _, p2, callback, p3)
	task.spawn(function()
		local screenColorDC2 = game.Lighting:FindFirstChild("ScreenColorDC2") or C.Phase2.ScreenColorDC2:Clone()
		Util.SetParentOverrideWithColor(screenColorDC2, game.Lighting, p3, "DragonFruitVFXColor")
		screenColorDC2:SetAttribute("UsedTimes", screenColorDC2:GetAttribute("UsedTimes") + 1)
		local usedTimes = screenColorDC2:GetAttribute("UsedTimes")
		TweenProps(screenColorDC2, TweenInfo.new(0.75), {
			Brightness = -0.01,
			Contrast = 0.1,
			Saturation = 0.1
		}):Play()
		local currentCamera = workspace.CurrentCamera
		task.spawn(function()
			local lerped = Util.WrapColor3Constructor(Color3.fromRGB(93, 79, 166), p3, "DragonFruitVFXColor"):Lerp(
				Util.WrapColor3Constructor(Color3.new(1, 1, 1), p3, "DragonFruitVFXColor"),
				0.5
			)

			while screenColorDC2:IsDescendantOf(game.Lighting) do
				local magnitude = (workspace.CurrentCamera.CFrame.p - position).Magnitude
				local magnitude2 = (workspace.CurrentCamera.CFrame.p - p.Position).Magnitude
				local v6 = math.max(0, (math.min(1, 1 - (magnitude / 700) ^ 1.5))) * screenColorDC2.Saturation / 0.1
				local v7 = math.max(0, (math.min(1, 1 - (magnitude2 / 700) ^ 1.5))) * screenColorDC2.Saturation / 0.1
				screenColorDC2.TintColor = Util.WrapColor3ConstructorForTintColor(
					Color3.fromRGB(181, 113, 82),
					p3,
					"DragonFruitVFXColor"
				):Lerp(
					lerped,
					(math.max(v7 - v6, 0))
				):Lerp(
					Util.WrapColor3ConstructorForTintColor(Color3.new(1, 1, 1), p3, "DragonFruitVFXColor"):Lerp(
						lerped,
						(math.max(v7 - v6, 0))
					),
					1 - v6
				)
				task.wait()
			end
		end)
		local clone = C.Phase1.CameraFocus:Clone()
		Util.SetParentOverrideWithColor(clone, p2, p3, "DragonFruitVFXColor")
		local v6 = false
		local flag = false
		local renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local v7 = (workspace.CurrentCamera.CFrame.p - p.Position).Magnitude < 600
			clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3)

			if flag then
				return
			end

			if v7 and v6 == false then
				v6 = true

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			else
				v6 = false

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end
		end)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		while callback() do
			task.wait(0.05)
		end

		task.wait(0.5)

		if screenColorDC2:GetAttribute("UsedTimes") == usedTimes then
			local tweenProps = TweenProps(screenColorDC2, TweenInfo.new(1.5), {
				TintColor = Util.WrapColor3ConstructorForTintColor(
					Color3.fromRGB(255, 255, 255),
					p3,
					"DragonFruitVFXColor"
				),
				Brightness = 0,
				Contrast = 0,
				Saturation = 0
			})
			tweenProps:Play()
			tweenProps.Completed:Wait()

			if screenColorDC2:GetAttribute("UsedTimes") == usedTimes then
				screenColorDC2:Destroy()
			end
		end

		flag = true

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(1)
		renderSteppedConnection:Disconnect()
		clone:Destroy()
	end)
end

local function CameraFlame(folder, holding, part, humanoidRootPart, p, player)
	local currentCamera = workspace.CurrentCamera
	local clone = C.Extra.CameraFocus2:Clone()
	Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -2)
	end)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	if p then
		clone.CameraFocus3:Destroy()
		Util.ResizeModel(clone, 4.2, clone.Position)
	end

	local flag = false

	while true do
		if (humanoidRootPart.Position - part.Position).Magnitude < 405 then
			if not flag then
				flag = true

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end
		elseif flag then
			flag = false

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end

		task.wait(0.1)

		if holding.Value ~= false then
			continue
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(1)
		renderSteppedConnection:Disconnect()
		clone:Destroy()
		break
	end
end

local function FireProjectile(folder, part, player, MainCheck)
	local player2 = player.player
	local partCaches = ensurePartCaches(player2)

	if player.PreCache then
		return
	end

	local v6 = part.CFrame * CFrame.new(0, -5, -22.5)
	Util.HeartbeatLoopFor.HeartbeatLoopFor(7, function()
		v6 = part.CFrame * CFrame.new(0, -5, -22.5)
	end)

	local function quadBezier(p, p2, p3, p4)
		return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
	end

	local function lerp(p, p2, p3)
		return p + (p2 - p) * p3
	end

	local function cubicBezier(p, p2, p3, p4, p5)
		local v7 = p2 + (p3 - p2) * p
		local v8 = p3 + (p4 - p3) * p
		local v9 = p4 + (p5 - p4) * p
		local v10 = v7 + (v8 - v7) * p
		return v10 + (v8 + (v9 - v8) * p - v10) * p
	end

	local rock2 = Util.Rock2

	-- equivalent calls inferred from this helper; original call sites unknown
	local function RockCrater(p, _, data)
		if not p then
			return
		end

		v2:yieldto_unthrottled(function()
			local radius = data.Radius
			local size = data.Size
			local duration = data.Duration
			local amount = data.Amount
			local v7 = p.Position + createVector(0, 1, 0)

			for i = 1, amount do
				local v8 = 360 / amount * i
				local v9 = CFrame.new(v7, v7 + p.Normal * 2) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
					0,
					math.rad(v8),
					0
				) * CFrame.new(0, 0, -radius * (math.random() < 0.4 and 1.5 or 1))
				local rayMap, v10, v11 = Util.RayMap(v9.Position, v9.upVector * -30)

				if not rayMap then
					continue
				end

				local v12 = size * math.random(15, 20) / 10
				local v13 = size * math.random(10, 20) / 10
				local v14 = size * math.random(10, 30) / 10
				rock2.new({
					FadeIn = 0.016666666666666666,
					Lifetime = duration,
					FadeOut = { 0.25, 0.35 },
					FadeOutSteps = 0.05,
					Size = Vector3.new(v12, v13, v14) + Vector3.new(
						0,
						math.random(-v13 / 3, v13 / 3),
						math.random(-v14 / 3, v14 / 3)
					),
					Scale = { 1, 2 },
					UpdateRate = 0.1
				}):Spawn(CFrame.new(v10, v10 + v11) * CFrame.Angles(-1.5707963267948966, 0, 0), 0.333)
			end
		end)
	end

	local function GroundFlyRocks(data, _, state, RocksFlyVelocityCallbackFunction2)
		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			local magnitude = (currentCamera.CFrame.Position - data.Position).Magnitude

			if magnitude > 350 then
				return
			end

			if magnitude > 200 then
				state.RockAmount = math.max(1, (math.floor(state.RockAmount * 0.5)))
			end
		end

		if math.random() < 0.05 or v3 >= 57 then
			return
		end

		v2:yieldto_unthrottled(function()
			local cframe = CFrame.new(data.Position)
			local material = data.Material
			local color = data.Instance.Color
			local rockAmount = state.RockAmount
			local rockSize = state.RockSize
			local positionOffset = state.PositionOffset
			local _ = state.RockRotationAmount
			local _ = state.RockRotationSpeed
			local _ = state.RockRotationPower
			local duration = state.Duration
			v3 += rockAmount

			for _ = 1, rockAmount do
				v2:yieldto(function()
					local part2 = partCaches.FlyRockCache:GetPart()
					part2.Position = cframe.Position + Vector3.new(
						math.random(-positionOffset, positionOffset),
						math.random(1, positionOffset) + rockSize,
						math.random(-positionOffset, positionOffset)
					)
					part2.Size = Vector3.new(
						math.random(rockSize / 2, rockSize),
						math.random(rockSize / 2, rockSize),
						math.random(rockSize / 2, rockSize)
					) * createVector(3, 1, 3) * 1.75
					part2.Material = material
					part2.Color = color
					part2.RotVelocity = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 9
					part2.Velocity = RocksFlyVelocityCallbackFunction2(part2)
					part2.Anchored = false
					part2.CanCollide = false
					part2.CanTouch = false
					rocks:ApplyCollision(part2, nil, true)
					v2:spawn(function()
						v2:wait(0.125)
						local v7 = duration + math.random(10, 20) / 100
						v2:wait(v7 * 0.5)
						v2:wait(v7 * 0.5)
						part2.Size *= 0.5
						v2:wait(0.1)
						part2.Size *= 0.5
						v2:wait(0.1)
						part2.Anchored = true
						partCaches.FlyRockCache:ReturnPart(part2)
						v3 -= 1
					end)
				end)
			end
		end)
	end

	local function ProjectileDrop(folder2, p, _, _, raycastParams, data, random)
		local aoeRange = data.AoeRange
		local downRayRange = data.DownRayRange
		local _ = data.Speed
		local _ = data.Offset
		local position = folder2.Position
		local i = data.i
		local projectileCount = data.ProjectileCount
		local v7 = math.sin(i * 3 / projectileCount * 3.141592653589793 * 12 + random:NextNumber(0, 0.5))
		local v8 = i * 3 / projectileCount

		if v8 > 2 then
			v8 -= 2
		elseif v8 > 1 then
			v8 -= 1
		end

		local v9 = v7 * (aoeRange * math.clamp(v8 ^ 0.6 + random:NextNumber(-0.05, 0), 0, 1))
		local v10 = math.cos(i * 3 / projectileCount * 3.141592653589793 * 12 + random:NextNumber(0, 0.5))
		local v11 = i * 3 / projectileCount

		if v11 > 2 then
			v11 -= 2
		elseif v11 > 1 then
			v11 -= 1
		end

		local v12 = v10 * (aoeRange * math.clamp(v11 ^ 0.6 + random:NextNumber(-0.05, 0), 0, 1))
		local v13 = p.Position + Vector3.new(v9, 0, v12)
		local raycastResult = workspace:Raycast(v13, createVector(0, 1, 0) * -downRayRange, raycastParams)
		local position2 = raycastResult and raycastResult.Position or v13 - createVector(0, 1, 0) * downRayRange
		local _ = (position - position2).Magnitude
		folder2.CFrame = CFrame.new(position, position2)
		local lastTime = tick()
		local v14 = 0.2
		local _ = createVector(0, 1, 0) * (150 + math.random(0, 300) + (position - position2).Y)
		local color3Constructor = Util.WrapColor3Constructor(
			Color3.new(0.756863, 0.270588, 1),
			player2,
			"DragonFruitVFXColor"
		)
		local position3 = p.Position
		local cframe = CFrame.lookAt(position3, position2)
		local v15 = (position2 - position3).Magnitude * 0.5773502691896257 * 1.3333333333333333
		sound:Play("BF_V3_WhiteGlove_C_LightningStrike_0" .. tostring(math.random(1, 4)), folder2)
		local v16 = localPlayer.Name == "Zioles" or isStudio
		local v17 = math.max(math.min(57 - v4, 8), 2)
		v4 += v17
		local rightVector = (cframe * CFrame.Angles(0, 0, 1.0471975511965976)).RightVector
		local v20 = {
			WorldPosition = position2,
			WorldAxis = -rightVector
		}
		local v21 = lightningBolt2.new({
			WorldPosition = position3,
			WorldAxis = rightVector
		}, v20, v17)

		if not v16 then
			v21.UpdateRate = 0.03333333333333333
		end

		local curveSize = v15 * 1.4
		local curveSize2 = v15 * 1.4
		v21.CurveSize0 = curveSize
		v21.CurveSize1 = curveSize2
		v21.Color = color3Constructor
		v21.AnimationSpeed = 15
		v21.PulseLength = 0.5
		v21.FadeLength = 0.25
		v21.ContractFrom = 0.75
		v21.PulseSpeed = 1 / v14 + math.random(-5, 5) / 10
		v21.Thickness = 7.5 + math.random() * 6
		v21.MaxRadius = v15 * 0.7
		v21.MinThicknessMultiplier = 1
		v21.MaxThicknessMultiplier = 1
		v21.ColorOffsetSpeed = 4
		v21.Frequency = 0.6
		local v24 = v14 * 1.4
		local part2 = partCaches.FocusTrailCache:GetPart()
		Util.ColorShiftObjectDescendants(part2, player2, "DragonFruitVFXColor")
		local descendants = part2:GetDescendants()
		v2:yieldto_unthrottled(function()
			for _, effect in pairs(descendants) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
					continue
				end

				effect.Enabled = true

				if effect:IsA("ParticleEmitter") then
					effect:Emit(3)
				end
			end
		end)

		while tick() - lastTime < v24 do
			folder2.CFrame = CFrame.new(v21.LastPoint or position3)
			part2.CFrame = folder2.CFrame
			RunService.RenderStepped:Wait()
		end

		folder2.CFrame = CFrame.new(position2)
		part2.CFrame = folder2.CFrame
		RunService.RenderStepped:Wait()
		v2:yieldto(function()
			for _, effect in pairs(folder2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			for _, effect in pairs(descendants) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end)
		task.defer(function()
			v4 -= v17
			partCaches.ProjectileCache:ReturnPart(folder2)
			partCaches.FocusTrailCache:ReturnPart(part2)
		end)
		return raycastResult
	end

	local raycastParams = RaycastParams.new()
	raycastParams.IgnoreWater = false
	raycastParams.FilterDescendantsInstances = {
		workspace.Characters,
		workspace.Enemies,
		workspace._WorldOrigin,
		waterBasePlane
	}
	local v7 = {
		workspace.Characters,
		workspace.Enemies,
		workspace._WorldOrigin,
		waterBasePlane
	}
	local downRayRange = player.DownRayRange or 500
	local aoeRange = player.AoeRange or 450

	local function RocksFlyVelocityCallbackFunction2(p)
		return CFrame.new(
			p.Position,
			(CFrame.new(p.Position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(0, 0, -70)).Position + Vector3.new(
				math.random(-10, 10),
				math.random(80, 250),
				math.random(-10, 10)
			)
		).LookVector * math.random(150, 180) * (2 + math.random() * 1.25)
	end

	local v8 = {
		Radius = 25,
		Size = 5,
		Duration = 3,
		Amount = 3,
		CurrentRock = C.Phase3.CraterRock
	}
	local clone = C.Phase3.Explosion:Clone()
	local v9 = {
		RockAmount = 1,
		RockSize = 7,
		PositionOffset = 30,
		RockRotationAmount = 7,
		RockRotationSpeed = 0.15,
		RockRotationPower = 100,
		Duration = 3.5
	}

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.LockedToPart = false
		end
	end

	local clone2 = C.Phase3.Explosion2:Clone()

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.LockedToPart = false
		end
	end

	local clone3 = C.Phase3.GroundImpact:Clone()

	for _, emitter in pairs(clone3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.LockedToPart = false
		end
	end

	local clone4 = C.Phase3.GroundExplosion:Clone()

	for _, emitter in pairs(clone4:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.LockedToPart = false
		end
	end

	local random = Random.new(player.Seed)
	local now = 0
	local count = 0

	while MainCheck() do
		if os.clock() - now > 0.05 then
			now = os.clock()
			count += 1

			if player.Duration / 0.05 + 0.04 < count then
				break
			end

			if player2 == game.Players.LocalPlayer then
				Util.CameraShaker:ShakeOnce(4, 10, 0.1, 1.2)
			end

			v2:spawn(function()
				local v10 = {
					DownRayRange = downRayRange,
					AoeRange = aoeRange,
					Speed = random:NextInteger(70, 100) / 10,
					Offset = random:NextInteger(35, 50) * 2,
					i = count,
					ProjectileCount = player.Duration / 0.05
				}

				if count % 4 ~= 0 then
					return
				end

				local part2 = partCaches.ProjectileCache:GetPart()
				Util.ColorShiftObjectDescendants(part2, player2, "DragonFruitVFXColor")

				for _, trail in pairs(part2:GetDescendants()) do
					if not trail:IsA("Trail") then
						continue
					end

					trail.Enabled = true
					trail.Lifetime = (trail.Name == "Trail" and 0.3 or 0.25) * math.random(6, 12) / 10 * 0.75
				end

				part2.CFrame = v6 * CFrame.Angles(
					math.rad((math.random(-90, 90))),
					math.rad((math.random(-90, 90))),
					(math.rad((math.random(-90, 90))))
				)
				part2.CFrame *= CFrame.new(0, 0, -22.5)
				local projectileDrop = ProjectileDrop(part2, v6, folder, v7, raycastParams, v10, random, player2)
				local position = part2.Position
				local character = game.Players.LocalPlayer.Character

				if character ~= nil then
					local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart and (humanoidRootPart.Position - position).Magnitude <= 100 then
						cameraShaker:ShakeOnce(10, 5, 0.115, 0.1)
					end
				end

				local cframe = CFrame.new(part2.Position + createVector(0, 3, 0))
				clone.CFrame = cframe
				Util.SetParentOverrideWithColor(clone, folder, player2, "DragonFruitVFXColor")
				local numberRange = NumberRange.new(math.random(-90, 90))

				for _, emitter in pairs(clone:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					if emitter.Parent == clone.Attachment2 then
						emitter.Rotation = numberRange
					end

					local v12 = emitter
					v2:spawn(function()
						if v12:GetAttribute("EmitDelay") ~= 0 then
							v2:wait(v12:GetAttribute("EmitDelay"))
						end

						v2:yieldto_unthrottled(function()
							v12:Emit(v12:GetAttribute("EmitCount"))
						end)
					end)
				end

				v2:spawn(function()
					clone2.CFrame = cframe
					Util.SetParentOverrideWithColor(clone2, folder, player2, "DragonFruitVFXColor")

					for _, emitter in pairs(clone2:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v12 = emitter
						v2:spawn(function()
							if v12:GetAttribute("EmitDelay") ~= 0 then
								v2:wait(v12:GetAttribute("EmitDelay"))
							end

							v2:yieldto_unthrottled(function()
								v12:Emit(v12:GetAttribute("EmitCount"))
							end)
						end)
					end
				end)

				if projectileDrop then
					local v12 = AlignCFrame(CFrame.new(projectileDrop.Position), projectileDrop.Normal) + projectileDrop.Normal * 0.05
					local v13 = v8

					if projectileDrop then
						RockCrater(true, nil, v13) -- equivalent call inferred; original call site unknown
					end

					v2:spawn(function()
						v2:bulkmoveto(clone3, v12)
						Util.SetParentOverrideWithColor(clone3, folder, player2, "DragonFruitVFXColor")

						for _, emitter in pairs(clone3:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v14 = emitter
							v2:spawn(function()
								if v14:GetAttribute("EmitDelay") ~= 0 then
									v2:wait(v14:GetAttribute("EmitDelay"))
								end

								v2:yieldto_unthrottled(function()
									v14:Emit(v14:GetAttribute("EmitCount"))
								end)
							end)
						end

						v2:bulkmoveto(clone4, v12)
						Util.SetParentOverrideWithColor(clone4, folder, player2, "DragonFruitVFXColor")

						if player2 == game.Players.LocalPlayer then
							sound:Play(
								"BF_V3_Meteor_Ground_Impact_0" .. tostring(math.random(1, 4)),
								clone4.Position,
								60,
								math.random(10, 13) / 10
							)
						else
							sound:Play(
								"BF_V3_Meteor_Ground_Impact_0" .. tostring(math.random(1, 4)),
								clone4.Position,
								nil,
								math.random(10, 12) / 10
							)
						end

						for _, emitter in pairs(clone4:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v14 = emitter
							task.spawn(function()
								if v14:GetAttribute("EmitDelay") ~= 0 then
									task.wait(v14:GetAttribute("EmitDelay"))
								end

								v2:yieldto_unthrottled(function()
									v14:Emit(v14:GetAttribute("EmitCount"))
								end)
							end)
						end

						v2:yieldto_unthrottled(function()
							if math.random(1, 3) == 1 then
								local clone5 = C.Phase3.Pillar:Clone()
								clone5.CFrame = CFrame.new(part2.Position)
								Util.SetParentOverrideWithColor(clone5, folder, player2, "DragonFruitVFXColor")

								for _, emitter in pairs(clone5:GetDescendants()) do
									if not emitter:IsA("ParticleEmitter") then
										continue
									end

									emitter.Enabled = true
									local v14 = emitter
									task.spawn(function()
										task.wait(math.random(1, 4) / 10)
										v14.Enabled = false
									end)
								end
							end
						end)
						GroundFlyRocks(projectileDrop, folder, v9, RocksFlyVelocityCallbackFunction2)
						local clone5 = C.Phase3.GroundBurn:Clone()
						v2:bulkmoveto(clone5, v12)
						Util.SetParentOverrideWithColor(clone5, folder, player2, "DragonFruitVFXColor")

						for _, emitter in pairs(clone5:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							if emitter.Parent == clone5.Attachment then
								local v14 = emitter
								task.spawn(function()
									v14:Emit(1)
									task.wait(1)
									v14:Emit(1)
									task.wait(1)
								end)
							elseif emitter.Parent ~= clone5.Attachment then
								local v14 = emitter
								task.spawn(function()
									v14.Enabled = true
									task.wait(2)
									v14.Enabled = false
								end)
							end
						end
					end)
				end
			end)
		end

		task.wait()
	end

	if player2 == game.Players.LocalPlayer then
		Util.CameraShaker:ShakeOnce(4, 10, 0.2, 2.5)
	end
end

local function mockRootPart(_, cFrame: CFrame)
	local part = Instance.new("Part")
	part.Name = "Mock" .. part.Name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cFrame
	part.Parent = workspace._WorldOrigin
	Util.DestroyAfter(part, 14)
	return part
end

local function StartExplosion(cFrame, folder, player)
	local DISTANCE_THRESHOLD = 400
	local clone = C.Extra.StartStartImpact:Clone()
	v2:bulkmoveto(clone, cFrame)
	Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v6 = emitter
		task.spawn(function()
			if v6:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v6:GetAttribute("EmitDelay"))
			end

			v6:Emit(v6:GetAttribute("EmitCount"))
		end)
	end

	DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
	local raycastParams = RaycastParams.new()
	raycastParams.IgnoreWater = false
	raycastParams.FilterDescendantsInstances = {
		workspace.Characters,
		workspace.Enemies,
		workspace._WorldOrigin,
		waterBasePlane
	}
	local clone2 = C.Extra.Star:Clone()
	v2:bulkmoveto(clone2, cFrame)
	Util.SetParentOverrideWithColor(clone2, folder, player, "DragonFruitVFXColor")

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v6 = emitter
		task.spawn(function()
			v6.Enabled = true
			v6:Emit(1)
			task.wait(0.35)
			v6.Enabled = false
		end)
	end

	v2:spawn(function()
		local v6 = 0.5 + tick()
		local v7 = {}

		for _ = 1, 7 do
			v2:spawn(function()
				local clone3 = C.Extra.Trails.SpinTrail:Clone()
				local v8 = math.random(10, 20) / 10
				local v9 = math.random(50, 70) * 2
				clone3.ScaleModel:ScaleTo(v8)
				v2:bulkmoveto(
					clone3,
					cFrame * CFrame.Angles(
						math.rad((math.random(-90, 90))),
						math.rad((math.random(-90, 90))),
						(math.rad((math.random(-90, 90))))
					)
				)
				clone3.ScaleModel.Motor6D.C0 = clone3.CFrame * CFrame.new(0, 0, -v9 * v8)
				Util.SetParentOverrideWithColor(clone3, folder, player, "DragonFruitVFXColor")
				TweenProps(
					clone3.ScaleModel.Motor6D,
					TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						C0 = CFrame.new(0, 0, 0)
					}
				):Play()
				local speed = math.random(15, 30) / 100
				v7[clone3] = {
					Speed = speed,
					SpinTime = tick()
				}

				for _, effect in pairs(clone3:GetDescendants()) do
					if effect:IsA("ParticleEmitter") then
						effect.Enabled = true
						effect:Emit(1)
					elseif effect:IsA("Trail") then
						effect.Enabled = true
						effect.Lifetime = effect.Lifetime * math.random(10, 35) / 10
					end
				end
			end)
		end

		while v6 - tick() > 0 do
			for k, v8 in pairs(v7) do
				if not (v8.SpinTime - tick() <= 0) then
					continue
				end

				v8.SpinTime = tick() + v8.Speed
				TweenProps(k, TweenInfo.new(v8.Speed * 1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					CFrame = k.CFrame * CFrame.Angles(0, 2.6179938779914944, 0)
				}):Play()
			end

			task.wait(0.1)
		end

		for k, v8 in pairs(v7) do
			local folder2 = k
			local v9 = v8
			v2:spawn(function()
				local v10 = math.random(-90, 90) / 5
				local v11 = math.random(-90, 90) / 5

				for i, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") then
						effect.Enabled = false
					elseif effect:IsA("Trail") then
						effect.Lifetime = 0.115
						effect.Color = ColorSequence.new(
							Util.WrapColor3Constructor(Color3.fromRGB(11, 7, 24), player, "DragonFruitVFXColor"),
							Util.WrapColor3Constructor(Color3.fromRGB(5, 5, 24), player, "DragonFruitVFXColor")
						)
					end
				end

				local tweenProps = TweenProps(
					folder2,
					TweenInfo.new(v9.Speed / 2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						CFrame = folder2.CFrame * CFrame.Angles(math.rad(v10), 2.6179938779914944, (math.rad(v11)))
					}
				)
				tweenProps:Play()
				folder2.ScaleModel.Motor6D.Enabled = false
				folder2.ScaleModel.Trail1.Anchored = true
				TweenProps(
					folder2.ScaleModel.Trail1,
					TweenInfo.new(v9.Speed / 2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						CFrame = cFrame * CFrame.Angles(math.rad(v10), 2.6179938779914944, (math.rad(v11)))
					}
				):Play()
				tweenProps.Completed:Wait()

				for i, trail in pairs(folder2:GetDescendants()) do
					if trail:IsA("Trail") then
						trail.Enabled = false
					end
				end
			end)
		end

		v7 = nil
	end)

	if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude < DISTANCE_THRESHOLD then
		Util.CameraShaker:ShakeOnce(14, 14, 0.1, 1.5)
	end

	v2:wait(0.35)
	clone2:Destroy()
	local clone3 = C.Extra.StarEndImpact:Clone()
	clone3.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone3, folder, player, "DragonFruitVFXColor")

	for _, emitter in pairs(clone3:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v6 = emitter
		task.spawn(function()
			if v6:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v6:GetAttribute("EmitDelay"))
			end

			v6:Emit(v6:GetAttribute("EmitCount"))
		end)
	end

	v2:step()
	local clone4 = C.Extra.BeforeExplosion:Clone()
	clone4.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone4, folder, player, "DragonFruitVFXColor")

	for _, emitter in pairs(clone4:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v6 = emitter
		task.spawn(function()
			v6:Emit(5)
			v6.Enabled = true
			task.wait(0.415)
			v6.Enabled = false
		end)
	end

	if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude < DISTANCE_THRESHOLD then
		task.spawn(function()
			local currentCamera = workspace.CurrentCamera
			task.wait(0.435)

			if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude < 400 then
				Util.CameraShaker:ShakeOnce(18, 24, 0.1, 3)
			end

			local clone5 = C.Extra.CameraFocus:Clone()
			Util.SetParentOverrideWithColor(clone5, folder, player, "DragonFruitVFXColor")
			local renderSteppedConnection = RunService.RenderStepped:Connect(function()
				clone5.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -1)
			end)

			for _, emitter in pairs(clone5:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(1)
				end
			end

			task.wait(1.5)
			renderSteppedConnection:Disconnect()
			clone5:Destroy()
		end)
	end

	task.wait(0.415)
	clone3:Destroy()
	local clone5 = C.Extra.Explosion:Clone()
	clone5.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone5, folder, player, "DragonFruitVFXColor")
	local play = Util.Sound:Play("BF_V3_WhiteGlove_C_FinalExplosion_01", clone5.Position)
	play.Volume = 2.5

	for _, emitter in pairs(clone5:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v6 = emitter
		task.spawn(function()
			if v6:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v6:GetAttribute("EmitDelay"))
			end

			v6:Emit(v6:GetAttribute("EmitCount"))
		end)
	end

	DeleteImpactAfterDuration(clone5) -- equivalent call inferred; original call site unknown
	v2:spawn(function()
		local clone6 = C.Extra.SlashModel:Clone()
		clone6.PrimaryPart.CFrame = cFrame * CFrame.Angles(
			math.rad(math.random(-90, 90) / 15),
			math.rad((math.random(-90, 90))),
			(math.rad(math.random(-90, 90) / 15))
		)
		Util.SetParentOverrideWithColor(clone6, folder, player, "DragonFruitVFXColor")
		v2:spawn(function()
			v2:spawn(function()
				clone6:ScaleTo(1.5)
				v2:wait(0.1)
				clone6:ScaleTo(1.92)
				v2:wait(0.1)
				clone6:ScaleTo(2.25)
				v2:wait(0.1)
			end)

			for _, beam in pairs(clone6:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				local tweenProps = TweenProps(
					beam,
					TweenInfo.new(0.225, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tweenProps:Play()
				local v8 = beam
				v2:spawn(function()
					tweenProps.Completed:Wait()
					v8:Destroy()
				end)
			end
		end)
		v2:spawn(function()
			local v6 = math.random(40, 70) / 1.5
			local v7 = 0.15 * math.random() + 0.15

			for _ = 1, 7 do
				local tweenProps = TweenProps(
					clone6.PrimaryPart,
					TweenInfo.new(v7 / 7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						CFrame = clone6.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(-v6), 0)
					}
				)
				tweenProps:Play()
				tweenProps.Completed:Wait()
			end

			local tweenProps2 = TweenProps(
				clone6.PrimaryPart,
				TweenInfo.new(v7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = clone6.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(-v6 * 2), 0)
				}
			)
			tweenProps2:Play()
			tweenProps2.Completed:Wait()
		end)
	end)

	for _ = 1, 7 do
		v2:yieldto(function()
			local clone6 = C.Extra.SlashModel:Clone()
			clone6.PrimaryPart.CFrame = cFrame * CFrame.Angles(
				math.rad((math.random(-90, 90))),
				math.rad((math.random(-90, 90))),
				(math.rad((math.random(-90, 90))))
			)
			Util.SetParentOverrideWithColor(clone6, folder, player, "DragonFruitVFXColor")
			task.spawn(function()
				task.spawn(function()
					for i = 100, 175, 18 do
						clone6:ScaleTo(i / 100)
						task.wait(0.1)
					end

					clone6:ScaleTo(1.75)
					task.wait(0.1)
				end)
				local v6 = 0.25 * math.random() + 0.25

				for _, beam in pairs(clone6:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					local tweenProps = TweenProps(
						beam,
						TweenInfo.new(v6, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
						{
							Width0 = 0,
							Width1 = 0
						}
					)
					tweenProps:Play()
					local v9 = beam
					task.spawn(function()
						tweenProps.Completed:Wait()
						v9:Destroy()
					end)
				end
			end)
			task.spawn(function()
				local v6 = math.random(40, 70)
				local v7 = 0.15 * math.random() + 0.15

				for _ = 1, 12 do
					local tweenProps = TweenProps(
						clone6.PrimaryPart,
						TweenInfo.new(v7 / 12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CFrame = clone6.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(-v6), 0)
						}
					)
					tweenProps:Play()
					tweenProps.Completed:Wait()
				end

				local tweenProps2 = TweenProps(
					clone6.PrimaryPart,
					TweenInfo.new(v7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						CFrame = clone6.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(-v6 * 2), 0)
					}
				)
				tweenProps2:Play()
				tweenProps2.Completed:Wait()
			end)
		end)
	end

	if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude < DISTANCE_THRESHOLD then
		task.spawn(function()
			local screenColorDTEC = C.Extra.ScreenColorDTEC
			local v6 = game.Lighting:FindFirstChild("ScreenColorDTEC")

			if v6 then
				v6:SetAttribute("UsedTimes", v6:GetAttribute("UsedTimes") + 1)
			else
				v6 = Instance.new("ColorCorrectionEffect")
				v6.Name = "ScreenColorDTEC"
			end

			Util.SetParentOverrideWithColor(v6, game.Lighting, player, "DragonFruitVFXColor")
			local usedTimes = v6:GetAttribute("UsedTimes")
			local tweenProps = TweenProps(v6, TweenInfo.new(0.07), {
				Brightness = screenColorDTEC.Brightness,
				Contrast = screenColorDTEC.Contrast,
				Saturation = screenColorDTEC.Saturation,
				TintColor = screenColorDTEC.TintColor
			})
			tweenProps:Play()
			tweenProps.Completed:Wait()
			local tweenProps2 = TweenProps(v6, TweenInfo.new(0.05), {
				Brightness = 3
			})
			tweenProps2:Play()
			tweenProps2.Completed:Wait()
			local tweenProps3 = TweenProps(v6, TweenInfo.new(0.07), {
				Saturation = -0.5,
				Contrast = 3,
				TintColor = Util.WrapColor3ConstructorForTintColor(
					Color3.fromRGB(255, 255, 255),
					player,
					"DragonFruitVFXColor"
				),
				Brightness = 0.15
			})
			tweenProps3:Play()
			tweenProps3.Completed:Wait()

			if v6:GetAttribute("UsedTimes") == usedTimes then
				local tweenProps4 = TweenProps(v6, TweenInfo.new(0.15), {
					Saturation = 0,
					Contrast = 0,
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(172, 144, 255),
						player,
						"DragonFruitVFXColor"
					),
					Brightness = 0
				})
				tweenProps4:Play()
				tweenProps4.Completed:Wait()
				task.wait(0.15)
				local tweenProps5 = TweenProps(v6, TweenInfo.new(0.75), {
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"DragonFruitVFXColor"
					),
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				})
				tweenProps5:Play()
				tweenProps5.Completed:Wait()

				if v6:GetAttribute("UsedTimes") == usedTimes then
					v6:Destroy()
				end
			end
		end)
	end

	task.spawn(function()
		for _ = 1, 15 do
			task.spawn(function()
				local clone6 = C.Extra.Trails.SmallTrail:Clone()
				clone6.CFrame = cFrame * CFrame.Angles(
					0,
					math.rad((math.random(-180, 180))),
					(math.rad(math.random(-180, 180) / 15))
				) * CFrame.Angles(math.rad((math.random(-25, 50))), 0, 0)
				Util.SetParentOverrideWithColor(clone6, folder, player, "DragonFruitVFXColor")
				clone6.CFrame *= CFrame.new(0, 0, -100)
				clone6.Anchored = false

				for _, effect in pairs(clone6:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = true
					end
				end

				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(700000000, 700000000, 700000000)
				bodyVelocity.P = 30000
				Util.SetParentOverrideWithColor(bodyVelocity, clone6, player, "DragonFruitVFXColor")
				local v6 = math.random(100, 250) * 2
				task.delay(math.random(10, 20) / 100, function()
					bodyVelocity:Destroy()
				end)
				bodyVelocity.Velocity = clone6.CFrame.LookVector * v6
				task.wait(1.5)

				for _, effect in pairs(clone6:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end
			end)
		end
	end)

	for _ = 1, 15 do
		task.spawn(function()
			local clone6 = C.Extra.ExplosionStars:Clone()
			clone6.CFrame = cFrame * CFrame.new(math.random(-250, 250), math.random(-25, 300), math.random(-250, 250))
			Util.SetParentOverrideWithColor(clone6, folder, player, "DragonFruitVFXColor")
			TweenProps(clone6, TweenInfo.new(1), {
				CFrame = clone6.CFrame * CFrame.new(0, -300, 0)
			}):Play()
			task.wait(0.25 * math.random() + 0.75)

			for _, emitter in pairs(clone6:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
	end
end

local heartbeatLoopFor = Util.HeartbeatLoopFor.HeartbeatLoopFor
local time2 = time

function RenderSteppedLoopFor(p, callback, callback2)
	local renderSteppedConnection = nil
	local v6 = time2()
	local bindableEvent = Instance.new("BindableEvent")
	local v7 = false
	local v8 = {
		Disconnect = function(self)
			if callback2 then
				v7 = true
				callback2()
			end

			if bindableEvent ~= nil then
				bindableEvent:Fire()
			end

			if renderSteppedConnection ~= nil then
				renderSteppedConnection:Disconnect()
			end
		end
	}
	local v9 = false
	renderSteppedConnection = RunService.RenderStepped:Connect(function(_)
		if time2() - v6 < p and v9 == false then
			if callback(v8) then
				v9 = true
			end
		elseif v7 == true or callback2 == nil then
			if bindableEvent ~= nil then
				bindableEvent:Fire()
			end

			if renderSteppedConnection ~= nil then
				renderSteppedConnection:Disconnect()
			end
		else
			v7 = true
			callback2()

			if bindableEvent ~= nil then
				bindableEvent:Fire()
			end

			if renderSteppedConnection ~= nil then
				renderSteppedConnection:Disconnect()
			end
		end
	end)
	bindableEvent.Event:Wait()
	bindableEvent:Destroy()

	if renderSteppedConnection ~= nil then
		renderSteppedConnection:Disconnect()
	end

	return renderSteppedConnection
end

local inverse = (CFrame.lookAt(createVector(0, 0, 0), createVector(0, 1, 0)):Inverse() * CFrame.Angles(
	0,
	4.71238898038469,
	0
)):Inverse()
return function(player)
	ensurePartCaches(player.player, player.PreCache)
	local v6 = {
		WorldPosition = Vector3.new(),
		WorldAxis = Vector3.new()
	}
	local v7 = {
		WorldPosition = Vector3.new(),
		WorldAxis = Vector3.new()
	}
	lightningBolt2.new(v6, v7, 2):Destroy()

	if player.PreCache then
		return
	end

	local character = player.Character
	local duration = player.Duration or 3
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local tongue3 = player.dragonModel.RootPart:FindFirstChild("Tongue3", true)
	local player2 = player.player
	local v8 = CFrame.new(C.MouthOffset.Value) * CFrame.Angles(-0.8, 0, 0)
	local _ = humanoid.RootPart
	local cFrame = tongue3.WorldCFrame * inverse * v8
	local part = Instance.new("Part")
	part.Name = "Mock" .. part.Name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cFrame
	part.Parent = workspace._WorldOrigin
	Util.DestroyAfter(part, 14)

	if not part or (part.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 2000 then
		return
	end

	local _ = CFrame.lookAt(createVector(0, 0, 0), createVector(0, 1, 0)):Inverse() * CFrame.Angles(
		0,
		4.71238898038469,
		0
	)
	v2:spawn(function()
		RenderSteppedLoopFor(20, function(connection)
			if part:IsDescendantOf(workspace) then
				part.CFrame = tongue3.WorldCFrame * inverse * v8
			else
				connection:Disconnect()
				return true
			end
		end)
	end)
	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, _WorldOrigin, player2, "DragonFruitVFXColor")
	Util.Debris:AddItem(folder, 15)
	local cFrame2 = part.CFrame * CFrame.new(0, -5, -22.5)
	heartbeatLoopFor(duration + 1, function()
		cFrame2 = part.CFrame * CFrame.new(0, -5, -22.5)
	end)

	local function continuouslyCFrameAtHRP(p, cframe)
		if cframe == nil then
			cframe = CFrame.new()
		end

		heartbeatLoopFor(duration + 1, function()
			p.CFrame = part.CFrame * CFrame.new(0, -5, -22.5) * cframe
		end)
		return cFrame2
	end

	local clone = C.Phase1.StarStartImpact:Clone()
	local cframe = nil

	if cframe == nil then
		cframe = CFrame.new()
	end

	heartbeatLoopFor(duration + 1, function()
		clone.CFrame = part.CFrame * CFrame.new(0, -5, -22.5) * cframe
	end)
	clone.CFrame = cFrame2
	Util.SetParentOverrideWithColor(clone, folder, player2, "DragonFruitVFXColor")
	v2:step()
	local v11 = sound:Play("BF_V3_WhiteGlove_C_DragonRage_01", part)
	v11.Volume = 3
	DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
	task.delay(0.15, function()
		v2:spawn(function()
			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v12 = emitter
				v2:spawn(function()
					if v12:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v12:GetAttribute("EmitDelay"))
					end

					v12:Emit(v12:GetAttribute("EmitCount"))
				end)
			end
		end)
	end)
	local clone2 = nil
	v2:yieldto(function()
		clone2 = C.Phase1.StartStars:Clone()
		local v12 = clone2
		local v13 = clone2
		local cframe2 = nil

		if cframe2 == nil then
			cframe2 = CFrame.new()
		end

		heartbeatLoopFor(duration + 1, function()
			v13.CFrame = part.CFrame * CFrame.new(0, -5, -22.5) * cframe2
		end)
		v12.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone2, folder, player2, "DragonFruitVFXColor")
		v2:step()

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end
	end)
	duration += 0.35
	local lastTime = tick()

	local function MainCheck()
		if tick() - lastTime < 1 then
			return true
		end

		return tick() - lastTime < duration and player.Holding and player.Holding.Value and player.Holding:IsDescendantOf(workspace)
	end

	v2:spawn(function()
		local v12 = tick() + duration
		local clone3 = C.Phase1.CameraStarImpact:Clone()
		local cframe2 = nil

		if cframe2 == nil then
			cframe2 = CFrame.new()
		end

		heartbeatLoopFor(duration + 1, function()
			clone3.CFrame = part.CFrame * CFrame.new(0, -5, -22.5) * cframe2
		end)
		clone3.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone3, folder, player2, "DragonFruitVFXColor")

		for _, emitter in pairs(clone3:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v13 = emitter
			task.spawn(function()
				if v13:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v13:GetAttribute("EmitDelay"))
				end

				v13:Emit(v13:GetAttribute("EmitCount"))
			end)
		end

		if player2 == game.Players.LocalPlayer or (cFrame2.p - workspace.CurrentCamera.CFrame.p).Magnitude < 300 then
			Util.CameraShaker:ShakeOnce(15, 20, 0.1, 2)
			v2:spawn(function()
				v2:yieldto(function()
					local clone4 = C.Phase1.ScreenColor:Clone()
					Util.SetParentOverrideWithColor(clone4, game.Lighting, player2, "DragonFruitVFXColor")
					local tweenProps = TweenProps(clone4, TweenInfo.new(0.025), {
						Brightness = clone4.Brightness,
						Contrast = clone4.Contrast,
						Saturation = clone4.Saturation,
						TintColor = clone4.TintColor
					})
					clone4.Brightness = 0
					clone4.Contrast = 0
					clone4.Saturation = 0
					clone4.TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player2,
						"DragonFruitVFXColor"
					)
					tweenProps:Play()
					task.wait(0.05)
					local tweenProps2 = TweenProps(clone4, TweenInfo.new(0.0125), {
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(255, 255, 255),
							player2,
							"DragonFruitVFXColor"
						),
						Brightness = 0,
						Contrast = 0,
						Saturation = 0
					})
					tweenProps2:Play()
					tweenProps2.Completed:Wait()
					clone4:Destroy()
				end)
				v2:yieldto(function()
					task.wait(0.1)
					local clone4 = C.Phase1.Bloom:Clone()
					Util.SetParentOverrideWithColor(clone4, game.Lighting, player2, "DragonFruitVFXColor")
					local tweenProps = TweenProps(clone4, TweenInfo.new(0.15), {
						Size = 50,
						Threshold = 1.25
					})
					tweenProps:Play()
					tweenProps.Completed:Wait()
					task.wait(0.15)
					local tweenProps2 = TweenProps(clone4, TweenInfo.new(0.5), {
						Size = 24,
						Threshold = 2
					})
					tweenProps2:Play()
					tweenProps2.Completed:Wait()
					clone4:Destroy()
				end)
				task.wait(0.05)
				local clone4 = C.Phase1.ScreenColor2:Clone()
				Util.SetParentOverrideWithColor(clone4, game.Lighting, player2, "DragonFruitVFXColor")
				local tweenProps3 = TweenProps(clone4, TweenInfo.new(0.05), {
					Brightness = clone4.Brightness,
					Contrast = clone4.Contrast,
					Saturation = clone4.Saturation,
					TintColor = clone4.TintColor
				})
				clone4.Brightness = 0
				clone4.Contrast = 0
				clone4.Saturation = 0
				clone4.TintColor = Util.WrapColor3ConstructorForTintColor(
					Color3.fromRGB(255, 255, 255),
					player2,
					"DragonFruitVFXColor"
				)
				tweenProps3:Play()
				tweenProps3.Completed:Wait()
				task.wait(0.07)
				local tweenProps4 = TweenProps(clone4, TweenInfo.new(0.05), {
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player2,
						"DragonFruitVFXColor"
					),
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				})
				tweenProps4:Play()
				tweenProps4.Completed:Wait()
				clone4:Destroy()
			end)
		end

		while v12 - tick() > 0 do
			local v13

			if tick() - lastTime < 1 then
				v13 = true
			elseif tick() - lastTime < duration then
				v13 = player.Holding and player.Holding.Value and player.Holding:IsDescendantOf(workspace)
			else
				v13 = false
			end

			if not v13 then
				break
			end

			clone3.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.p, cFrame2.Position) * CFrame.new(0, 0, -12)
			RunService.PreRender:Wait()
		end
	end)
	task.wait(0.35)

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	local clone3 = C.Phase1.FireOrbModel:Clone()
	local primaryPart = clone3.PrimaryPart
	local cframe2 = nil

	if cframe2 == nil then
		cframe2 = CFrame.new()
	end

	heartbeatLoopFor(duration + 1, function()
		primaryPart.CFrame = part.CFrame * CFrame.new(0, -5, -22.5) * cframe2
	end)
	primaryPart.CFrame = cFrame2
	Util.SetParentOverrideWithColor(clone3, folder, player2, "DragonFruitVFXColor")
	v2:step()

	for _, effect in pairs(primaryPart:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = true
		end
	end

	local clone4 = C.Phase2.AreaSparks:Clone()
	local cframe3 = nil

	if cframe3 == nil then
		cframe3 = CFrame.new()
	end

	heartbeatLoopFor(duration + 1, function()
		clone4.CFrame = part.CFrame * CFrame.new(0, -5, -22.5) * cframe3
	end)
	clone4.CFrame = cFrame2
	v2:step()
	Util.SetParentOverrideWithColor(clone4, folder, player2, "DragonFruitVFXColor")

	for _, emitter in pairs(clone4:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	v2:spawn(function()
		FireProjectile(folder, part, player, MainCheck)
	end)
	v2:spawn(function()
		local raycastParams = RaycastParams.new()
		raycastParams.IgnoreWater = false
		raycastParams.FilterDescendantsInstances = {
			workspace.Characters,
			workspace.Enemies,
			workspace._WorldOrigin,
			waterBasePlane
		}
		local _ = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
		local downRayRange = player.DownRayRange or 500
		local raycastResult = workspace:Raycast(part.Position, createVector(0, 1, 0) * -downRayRange, raycastParams)
		local position = raycastResult and raycastResult.Position or part.Position - createVector(0, 1, 0) * downRayRange
		ScreenEffect(position, part, nil, folder, MainCheck, player2) -- equivalent call inferred; original call site unknown
	end)
	local clonesByClone = {}
	v2:spawn(function()
		local raycastParams = RaycastParams.new()
		raycastParams.IgnoreWater = false
		raycastParams.FilterDescendantsInstances = {
			workspace.Characters,
			workspace.Enemies,
			workspace._WorldOrigin,
			waterBasePlane
		}

		for i = 1, 9 do
			local v12 = i
			task.delay(0.6 * math.random(), function()
				local v13 = CFrame.new(cFrame2.Position) * CFrame.Angles(0, v12 / 9 * 3.141592653589793 * 2, 0) * CFrame.new(
					0,
					0,
					player.AoeRange * (0.4 + math.random() * 0.6)
				)
				local downRayRange = player.DownRayRange or 500
				local raycastResult = workspace:Raycast(
					v13.Position + createVector(0, 15, 0) + createVector(0, 1, 0),
					createVector(0, 1, 0) * -downRayRange,
					raycastParams
				)

				if raycastResult then
					local clone5 = C.Phase3.LavaBeamModel:Clone()
					local primaryPart2 = clone5.PrimaryPart
					primaryPart2.CFrame = CFrame.new(raycastResult.Position) * CFrame.Angles(
						0,
						math.rad((math.random(-180, 180))),
						0
					)
					Util.SetParentOverrideWithColor(clone5, folder, player2, "DragonFruitVFXColor")
					clone5:ScaleTo(math.random(10, 20) / 10)
					local position = primaryPart2.Attach1.Position * math.random(12, 20) / 10
					primaryPart2.Attach1.Position = position

					for i2, descendant in pairs(primaryPart2:GetDescendants()) do
						if descendant:IsA("ParticleEmitter") then
							descendant.Enabled = true
						elseif descendant:IsA("Beam") then
							local tweenProps = TweenProps(descendant, TweenInfo.new(0.35 + math.random() * 0.35), {
								Width0 = descendant.Width0,
								Width1 = descendant.Width1,
								CurveSize0 = descendant.CurveSize0,
								CurveSize1 = descendant.CurveSize1
							})
							descendant.Width0 = 1
							descendant.Width1 = 1
							descendant.CurveSize0 = math.random(-10, 10)
							descendant.CurveSize1 = math.random(-10, 10)
							tweenProps:Play()
						elseif descendant:IsA("Attachment") then
							local tweenProps = TweenProps(descendant, TweenInfo.new(0.35 + math.random() * 0.35), {
								Position = descendant.Position
							})
							descendant.Position = createVector(0, 0, 0)
							tweenProps:Play()
						end
					end

					if clonesByClone then
						clonesByClone[clone5] = clone5
					else
						clone5:Destroy()
					end
				end
			end)
		end
	end)
	v2:spawn(function()
		local attachment0sByClone = {}

		for _ = 1, 10 do
			v2:yieldto(function()
				local clone5 = C.Phase3.SmallSpinTrail:Clone()
				clone5.CFrame = cFrame2
				Util.SetParentOverrideWithColor(clone5, folder, player2, "DragonFruitVFXColor")
				clone5.AlignPosition.Position = cFrame2.Position
				clone5.AlignOrientation.CFrame = cFrame2
				clone5.Anchored = false
				clone5.Attachment0.Position = Vector3.new(0, 0, math.random(50, 150))
				clone5.Attachment0.Orientation = Vector3.new(
					math.random(-5, 5) * 2,
					math.random(-180, 180),
					math.random(-5, 5) * 2
				)
				attachment0sByClone[clone5] = clone5.Attachment0
			end)
		end

		local v12 = tick() + 5
		local v13 = 0.016666666666666666

		while true do
			for k, v14 in pairs(attachment0sByClone) do
				v14.Orientation += Vector3.new(0, v13 * 3 * 60, 0)
				k.AlignPosition.Position = cFrame2.Position
				k.AlignOrientation.CFrame = CFrame.new(cFrame2.Position)
			end

			v13 = task.wait()

			if not (clonesByClone == nil or v12 - tick() <= 0) then
				continue
			end

			for folder2, _ in pairs(attachment0sByClone) do
				for _, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end
			end

			break
		end
	end)
	v2:spawn(function()
		local clone5 = C.Phase2.StarExplosion:Clone()
		local cframe4 = nil

		if cframe4 == nil then
			cframe4 = CFrame.new()
		end

		heartbeatLoopFor(duration + 1, function()
			clone5.CFrame = part.CFrame * CFrame.new(0, -5, -22.5) * cframe4
		end)
		clone5.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone5, folder, player2, "DragonFruitVFXColor")
		local emittersByEmitter = {}

		for _, emitter in pairs(clone5:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emittersByEmitter[emitter] = emitter
			end
		end

		local v12 = tick() + duration

		while v12 - tick() > 0 do
			local v13

			if tick() - lastTime < 1 then
				v13 = true
			elseif tick() - lastTime < duration then
				v13 = player.Holding and player.Holding.Value and player.Holding:IsDescendantOf(workspace)
			else
				v13 = false
			end

			if not v13 then
				break
			end

			for _, v14 in pairs(emittersByEmitter) do
				v14:Emit(v14:GetAttribute("EmitCount"))
			end

			task.wait(0.25)
		end
	end)
	local currentCamera = workspace.CurrentCamera

	if player2 == game.Players.LocalPlayer then
		TweenProps(currentCamera, TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			FieldOfView = 110
		}):Play()
	end

	v2:spawn(function()
		CameraFlame(
			folder,
			player.Holding,
			part,
			game.Players.LocalPlayer.Character.HumanoidRootPart,
			player2 == game.Players.LocalPlayer,
			player2
		)
	end)
	v2:spawn(function()
		local now = tick()
		local v12 = true
		local v13 = 1

		while true do
			local v14

			if tick() - lastTime < 1 then
				v14 = true
			elseif tick() - lastTime < duration then
				v14 = player.Holding and player.Holding.Value and player.Holding:IsDescendantOf(workspace)
			else
				v14 = false
			end

			if v14 then
				if now - tick() <= 0 then
					now = tick() + 0.10500000000000001

					if v12 == true then
						v13 += 0.30000000000000004
						clone3:ScaleTo(v13)

						if v13 >= 1.25 then
							v12 = false
						end
					elseif v12 == false then
						v13 -= 0.30000000000000004
						clone3:ScaleTo(v13)

						if v13 <= 1 then
							v12 = true
						end
					end
				end

				task.wait()
			else
				task.delay(0.5, function()
					for _, folder2 in pairs(clonesByClone) do
						for _, descendant in pairs(folder2:GetDescendants()) do
							if descendant:IsA("ParticleEmitter") then
								descendant.Enabled = false
							elseif descendant:IsA("Beam") then
								TweenProps(descendant, TweenInfo.new(0.3 + math.random(35, 100) / 100), {
									Width0 = 0,
									Width1 = 0
								}):Play()
								local v15 = descendant
								task.delay(1, function()
									v15:Destroy()
								end)
							elseif descendant:IsA("Attachment") then
								TweenProps(descendant, TweenInfo.new(0.3 + math.random(35, 100) / 100), {
									Position = createVector(0, 0, 0)
								}):Play()
							end
						end
					end

					clonesByClone = nil
				end)
				task.spawn(function()
					task.wait(0.1)

					if character:GetAttribute("CastSupernova") then
						if player2 == game.Players.LocalPlayer then
							TweenProps(currentCamera, TweenInfo.new(0.7649999999999999), {
								FieldOfView = 70
							}):Play()
						end

						task.delay(0.7649999999999999, function()
							if player2 == game.Players.LocalPlayer then
								TweenProps(
									currentCamera,
									TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
									{
										FieldOfView = 130
									}
								):Play()
							end
						end)
						StartExplosion(primaryPart.CFrame, folder, player2)
						task.wait(0.8)
					end

					if player2 == game.Players.LocalPlayer then
						TweenProps(currentCamera, TweenInfo.new(1), {
							FieldOfView = 70
						}):Play()
					end
				end)

				for _, emitter in pairs(primaryPart:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter.Enabled = false
					emitter:Destroy()
				end

				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				if v11 then
					sound:FadeOut(v11, 0.75)
				end

				local clone5 = C.Phase2.StarEndImpact:Clone()
				local cframe4 = nil

				if cframe4 == nil then
					cframe4 = CFrame.new()
				end

				heartbeatLoopFor(duration + 1, function()
					clone5.CFrame = part.CFrame * CFrame.new(0, -5, -22.5) * cframe4
				end)
				clone5.CFrame = cFrame2
				Util.SetParentOverrideWithColor(clone5, folder, player2, "DragonFruitVFXColor")
				DeleteImpactAfterDuration(clone5) -- equivalent call inferred; original call site unknown

				for _, emitter in pairs(clone5:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v16 = emitter
					task.spawn(function()
						if v16:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v16:GetAttribute("EmitDelay"))
						end

						v16:Emit(v16:GetAttribute("EmitCount"))
					end)
				end

				break
			end
		end
	end)
end