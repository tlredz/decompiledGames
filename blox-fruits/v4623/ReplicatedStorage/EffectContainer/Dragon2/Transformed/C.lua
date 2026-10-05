local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local FX = require(game.ReplicatedStorage.FX)
local C = FX:WaitForChild("Dragon2").Transformed.C
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
local Signal2 = require(ReplicatedStorage:WaitForChild("Util"):WaitForChild("Signal2"))
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
	local time = data.Time or 0.2
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
				local tweenProperty = TweenCoordinator.tweenProperty(p, k, item, time, out, onOneDone)
				table.insert(tweenProperties, tweenProperty)
			end

			if flag2 then
				for _, v3 in ipairs(tweenProperties) do
					TweenCoordinator.pause(v3)
				end
			end
		end,
		Pause = function(self)
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

local partCache = Util.PartCache
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
Util.ResizeModel(C.FlyRock, 2, C.FlyRock.Position)
Util.ResizeModel(C.Phase2.StarStartImpactSmall, 40, C.Phase2.StarStartImpactSmall.Position)

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(_, folder)
	task.spawn(function()
		local v2 = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v2 = math.max(v2, emitter.Lifetime.Max + emitter:GetAttribute("EmitDelay"))
			end
		end

		task.wait(v2)
		folder:Destroy()
	end)
end

local v2 = nil
local v3 = nil
local v4 = nil
local v5 = 0
local now = nil
local thread = nil
local folder = nil
local folder2 = nil
local folder3 = nil
local folder4 = nil

local function ensurePartCaches(_)
	now = tick()

	if not v2 then
		if thread then
			warn("The last cleaning task errored somehow?")

			if folder then
				folder:Destroy()
			end

			if folder2 then
				folder2:Destroy()
			end

			if folder3 then
				folder3:Destroy()
			end

			if folder4 then
				folder4:Destroy()
			end
		end

		folder2 = Instance.new("Folder", _WorldOrigin)
		folder2.Name = "PillarFolder_Dragon"
		local clone = C.Phase3.Pillar:Clone()
		v2 = partCache.new(clone, 13.666666666666666)
		v2:SetCacheParent(folder2)
		folder = Instance.new("Folder", _WorldOrigin)
		folder.Name = "GroundBurnFolder_Dragon"
		local clone2 = C.Phase3.GroundBurn:Clone()
		v3 = partCache.new(clone2, 38)
		v3:SetCacheParent(folder)
		folder4 = Instance.new("Folder", _WorldOrigin)
		folder4.Name = "ProjectileFolder_Dragon"
		local clone3 = C.Phase3.FireProjectile:Clone()
		v4 = partCache.new(clone3, 38)
		v4:SetCacheParent(folder4)
		folder3 = Instance.new("Folder", _WorldOrigin)
		folder3.Name = "FlyRockFolder_Dragon"
		v5 = partCache.new(C.FlyRock, 76)
		v5:SetCacheParent(folder3)
		thread = task.defer(function()
			repeat
				task.wait(120)
			until now + 120 < tick()

			folder:Destroy()
			v3:Dispose()
			v3 = nil
			folder = nil
			folder2:Destroy()
			v2:Dispose()
			v2 = nil
			folder2 = nil
			folder4:Destroy()
			v4:Dispose()
			v4 = nil
			folder4 = nil
			folder3:Destroy()
			v5:Dispose()
			v5 = nil
			folder3 = nil
			thread = nil
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ReturnImpactAfterDuration(_, folder5, object)
	task.spawn(function()
		local v6 = 0

		for _, emitter in pairs(folder5:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v6 = math.max(v6, emitter.Lifetime.Max + emitter:GetAttribute("EmitDelay"))
			end
		end

		task.wait(v6)
		object:ReturnPart(folder5)
	end)
end

local function viewerIsClose(_, p, p2, callback)
	local character = localPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).Magnitude <= p2 then
			callback()
		end
	end
end

local function AlignCFrame(_, data, normal)
	local v6 = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v6).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v6).Unit
	return CFrame.fromMatrix(p, unit2, v6, unit3)
end

local function quadBezier(_, p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(_, p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(_, p, p2, p3, p4, p5)
	local v6 = p2 + (p3 - p2) * p
	local v7 = p3 + (p4 - p3) * p
	local v8 = p4 + (p5 - p4) * p
	local v9 = v6 + (v7 - v6) * p
	return v9 + (v7 + (v8 - v7) * p - v9) * p
end

local rock2 = Util.Rock2

local function RockCrater(_, p, _, data)
	if not (ziggy12 and p) then
		return
	end

	local radius = data.Radius
	local size = data.Size
	local duration = data.Duration
	local amount = data.Amount
	local v6 = p.Position + createVector(0, 1, 0)

	for i = 1, amount do
		local v7 = 360 / amount * i
		local v8 = CFrame.new(v6, v6 + p.Normal * 2) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
			0,
			math.rad(v7),
			0
		) * CFrame.new(0, 0, -radius * (math.random() < 0.4 and 1.5 or 1))
		local rayMap, v9, v10 = Util.RayMap(v8.Position, v8.upVector * -30)

		if not rayMap then
			continue
		end

		local v11 = size * math.random(15, 20) / 10
		local v12 = size * math.random(10, 20) / 10
		local v13 = size * math.random(10, 30) / 10
		rock2.new({
			FadeIn = 0.016666666666666666,
			Lifetime = duration,
			FadeOut = { 0.25, 0.35 },
			FadeOutSteps = 0.05,
			Size = Vector3.new(v11, v12, v13) + Vector3.new(
				0,
				math.random(-v12 / 3, v12 / 3),
				math.random(-v13 / 3, v13 / 3)
			),
			Scale = { 1, 2 },
			UpdateRate = 0.1
		}):Spawn(CFrame.new(v9, v9 + v10) * CFrame.Angles(-1.5707963267948966, 0, 0), 0.333)
	end
end

local v6 = 0

local function GroundFlyRocks(player, data, _, data2, RocksFlyVelocityCallbackFunction2)
	if math.random() < 0.05 or v6 >= 57 then
		return
	end

	local cframe = CFrame.new(data.Position)
	local material = data.Material
	local color = data.Instance.Color
	local rockAmount = data2.RockAmount
	local rockSize = data2.RockSize
	local positionOffset = data2.PositionOffset
	local _ = data2.RockRotationAmount
	local _ = data2.RockRotationSpeed
	local _ = data2.RockRotationPower
	local duration = data2.Duration
	v6 += rockAmount

	for _ = 1, rockAmount do
		local part = v5:GetPart()
		part.Position = cframe.Position + Vector3.new(
			math.random(-positionOffset, positionOffset),
			math.random(1, positionOffset) + rockSize,
			math.random(-positionOffset, positionOffset)
		)
		part.Size = Vector3.new(
			math.random(rockSize / 2, rockSize),
			math.random(rockSize / 2, rockSize),
			math.random(rockSize / 2, rockSize)
		) * createVector(3, 1, 3) * 1.75
		part.Material = material
		Util.ColorShiftObjectDescendants(part, player, "DragonFruitVFXColor", true)
		part.Color = color
		part.RotVelocity = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 9
		part.Velocity = RocksFlyVelocityCallbackFunction2(part)
		part.Anchored = false
		rocks:ApplyCollision(part, nil, true)
		task.spawn(function()
			task.wait(0.125)
			local v8 = duration + math.random(10, 20) / 100
			task.wait(v8 * 0.5)
			task.wait(v8 * 0.5)
			part.Size *= 0.5
			task.wait(0.1)
			part.Size *= 0.5
			task.wait(0.1)
			part.Anchored = true
			v5:ReturnPart(part)
			v6 -= 1
		end)
	end
end

local function ProjectileDrop(player, folder5, p, _, _, raycastParams, data, random)
	local descendants = folder5:GetDescendants()

	for _, effect in pairs(descendants) do
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = true
			effect:Emit(1)
		elseif effect:IsA("Trail") then
			effect.Enabled = true
			local _Lifetime = effect:GetAttribute("_Lifetime") or effect.Lifetime

			if not effect:GetAttribute("_Lifetime") then
				effect:SetAttribute("_Lifetime", _Lifetime)
			end

			effect.Lifetime = _Lifetime * math.random(5, 15) / 10
		end
	end

	local aoeRange = data.AoeRange
	local downRayRange = data.DownRayRange
	local speed = data.Speed
	local v7 = data.Offset * 2
	local position = folder5.Position
	local i = data.i
	local projectileCount = data.ProjectileCount
	local v8 = math.sin(i / projectileCount * 3.141592653589793 * 4 + random:NextNumber(0, 0.5)) * (aoeRange * (i / projectileCount) ^ 0.6)
	local v9 = math.cos(i / projectileCount * 3.141592653589793 * 4 + random:NextNumber(0, 0.5)) * (aoeRange * (i / projectileCount) ^ 0.6)
	local v10 = p.Position + Vector3.new(v8, 0, v9)
	local raycastResult = workspace:Raycast(v10, createVector(0, 1, 0) * -downRayRange, raycastParams)

	if raycastResult and raycastResult.Instance and raycastResult.Instance.Name == "WaterBase-Plane" then
		raycastResult = nil
	end

	local position2 = raycastResult and raycastResult.Position or v10 - createVector(0, 1, 0) * downRayRange
	local magnitude = (position - position2).Magnitude
	local cframe = CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
	folder5.CFrame = CFrame.new(position, position2) * cframe
	local v11 = (position - position2) / 2
	local cframe2 = CFrame.new(CFrame.new(position) * (v11 / 1.5))
	local cframe3 = CFrame.new(CFrame.new(position2) * (v11 / 1.5))
	local cframe4 = CFrame.new(cframe2.Position, cframe2.Position + folder5.CFrame.LookVector)
	local cframe5 = CFrame.new(cframe3.Position, cframe3.Position + folder5.CFrame.LookVector)
	local v12 = cframe4 * CFrame.new(0, v7 * 7.5, 0)
	local v13 = cframe5 * CFrame.new(0, v7 * 2.5, 0)
	local position3 = v12.Position
	local position4 = v13.Position
	local lastTime = tick()
	local v14 = 0.95 * (magnitude / speed) / 60

	while tick() - lastTime < v14 do
		local v15 = ((tick() - lastTime) / v14) ^ 0.75
		local v16 = cubicBezier(player, v15, position, position3, position4, position2)
		folder5.CFrame = CFrame.new(v16, position2)
		RunService.Heartbeat:Wait()
	end

	for _, effect in pairs(descendants) do
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = false
		elseif effect:IsA("Trail") then
			effect.Enabled = false
		end
	end

	task.defer(function()
		v4:ReturnPart(folder5)
	end)
	return raycastResult
end

local function tweenClock(_, check, p, p2, p3)
	local lastTime = tick()

	while tick() - lastTime < p3 do
		local v7 = (tick() - lastTime) / p3
		local _ = p + (p2 - p) * v7
		check(v7)
		local RunService2 = game:GetService("RunService")
		RunService2.RenderStepped:Wait()
	end

	check(1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ScreenEffect(player, endPosition, duration)
	local character = localPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - endPosition).Magnitude <= 2000 then
			duration *= 3.5
			task.spawn(function()
				local clockTime = game.Lighting.ClockTime
				local sky = game.Lighting:FindFirstChildWhichIsA("Sky")
				local moonAngularSize = sky.MoonAngularSize
				local sunAngularSize = sky.SunAngularSize
				local screenColorDC = game.Lighting:FindFirstChild("ScreenColorDC") or C.Phase2.ScreenColorDC:Clone()
				Util.SetParentOverrideWithColor(screenColorDC, game.Lighting, player, "DragonFruitVFXColor")
				screenColorDC:SetAttribute("UsedTimes", screenColorDC:GetAttribute("UsedTimes") + 1)
				local usedTimes = screenColorDC:GetAttribute("UsedTimes")
				TweenProps(screenColorDC, TweenInfo.new(0.75), {
					Brightness = -0.1,
					Contrast = 0.1,
					Saturation = 0.1
				}):Play()
				local color3Constructor = Util.WrapColor3Constructor(
					Color3.fromRGB(93, 79, 166),
					player,
					"DragonFruitVFXColor"
				)
				task.spawn(function()
					local lastTime = tick()

					while screenColorDC:IsDescendantOf(game.Lighting) do
						local v7 = tick() - lastTime
						local v8 = not (duration - 1 < v7) and 0 or (v7 - (duration - 1)) / 1
						local v9 = math.max(
							0,
							(math.min(1, 1 - ((workspace.CurrentCamera.CFrame.p - endPosition).Magnitude / 750) ^ 1.5))
						) * screenColorDC.Saturation / 0.1
						screenColorDC.TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(166, 103, 57),
							player,
							"DragonFruitVFXColor"
						):Lerp(
							color3Constructor,
							v8
						):Lerp(
							Util.WrapColor3ConstructorForTintColor(Color3.new(1, 1, 1), player, "DragonFruitVFXColor"),
							1 - v9
						)
						task.wait()
					end
				end)
				local lastTime = tick()

				while tick() - lastTime < 0.25 do
					if screenColorDC:GetAttribute("UsedTimes") == usedTimes then
						local v7 = (tick() - lastTime) / 0.25
						sky.MoonAngularSize = moonAngularSize * (1 - v7)
						sky.SunAngularSize = sunAngularSize * (1 - v7)
					end

					local RunService2 = game:GetService("RunService")
					RunService2.RenderStepped:Wait()
				end

				if screenColorDC:GetAttribute("UsedTimes") == usedTimes then
					sky.MoonAngularSize = 0
					sky.SunAngularSize = 0
				end

				local function check(_)
					return screenColorDC:GetAttribute("UsedTimes") == usedTimes
				end

				local v7 = clockTime > 12 and 23.999 or 0.001
				tweenClock(player, check, clockTime, v7, 1)
				tweenClock(player, check, v7, v7, duration - 1)

				if screenColorDC:GetAttribute("UsedTimes") == usedTimes then
					task.spawn(function()
						tweenClock(player, check, v7, clockTime, 0.65)
						local lastTime2 = tick()

						while tick() - lastTime2 < 0.25 do
							if screenColorDC:GetAttribute("UsedTimes") == usedTimes then
								local v8 = (tick() - lastTime2) / 0.25
								sky.MoonAngularSize = 11 * v8
								sky.SunAngularSize = 22 * v8
							end

							local RunService2 = game:GetService("RunService")
							RunService2.RenderStepped:Wait()
						end

						if screenColorDC:GetAttribute("UsedTimes") == usedTimes then
							sky.MoonAngularSize = 11
							sky.SunAngularSize = 22
						end
					end)
					local tweenProps = TweenProps(screenColorDC, TweenInfo.new(1.5), {
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(255, 255, 255),
							player,
							"DragonFruitVFXColor"
						),
						Brightness = 0,
						Contrast = 0,
						Saturation = 0
					})
					tweenProps:Play()
					tweenProps.Completed:Wait()

					if screenColorDC:GetAttribute("UsedTimes") == usedTimes then
						screenColorDC:Destroy()
					end
				end
			end)
		end
	end
end

local function SpinStars(player, primaryPart, folder5, duration)
	local v7 = 0.75 + duration * 3

	for _ = 1, 7 do
		local v8 = (50 + (primaryPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude / 4.75) * (1 + math.random() * 0.333)

		if v8 >= 800 then
			break
		else
			local v9 = v8
			task.spawn(function()
				local clone = C.Phase1.StarTrail:Clone()
				local v10 = math.random(10, 20) / 10
				clone.ScaleModel:ScaleTo(v10)
				clone.CFrame = CFrame.new(primaryPart.Position) * CFrame.Angles(
					math.rad((math.random(-90, 90))),
					0,
					(math.rad((math.random(-90, 90))))
				)
				clone.ScaleModel.Trail1.WeldConstraint.Enabled = false
				clone.ScaleModel.Trail1.CFrame = clone.CFrame * CFrame.new(0, 0, -v9 * v10) * CFrame.Angles(
					0,
					1.5707963267948966,
					0
				)
				clone.ScaleModel.Trail1.WeldConstraint.Enabled = true
				Util.SetParentOverrideWithColor(clone, folder5, player, "DragonFruitVFXColor")
				local flag = true
				local v11 = math.random(15, 50) / 100
				task.spawn(function()
					task.wait(v7 - (0.7 + v11))
					flag = false
				end)

				while flag do
					local v12 = math.random(-90, 90) / 5
					local v13 = math.random(-90, 90) / 5
					local tweenProps = TweenProps(
						clone,
						TweenInfo.new(v11, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							CFrame = clone.CFrame * CFrame.Angles(math.rad(v12), 0.8726646259971648, (math.rad(v13)))
						}
					)
					tweenProps:Play()
					tweenProps.Completed:Wait()
				end

				local v12 = math.random(-90, 90) / 5
				local v13 = math.random(-90, 90) / 5
				local tweenProps2 = TweenProps(
					clone,
					TweenInfo.new(v11 / 2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						CFrame = clone.CFrame * CFrame.Angles(math.rad(v12), 2.6179938779914944, (math.rad(v13)))
					}
				)
				tweenProps2:Play()
				clone.ScaleModel.Trail1.WeldConstraint.Enabled = false
				clone.ScaleModel.Trail1.Anchored = true
				TweenProps(
					clone.ScaleModel.Trail1,
					TweenInfo.new(v11 / 2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						CFrame = clone.CFrame
					}
				):Play()
				tweenProps2.Completed:Wait()

				for i, effect in pairs(clone:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end
			end)
		end
	end
end

local function StartExplosion(p, cFrame, p2)
	local DISTANCE_THRESHOLD = 700
	local raycastParams = RaycastParams.new()
	raycastParams.IgnoreWater = false
	raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
	local clone = C.Extra.Star:Clone()
	clone.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, p2, p, "DragonFruitVFXColor")

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v7 = emitter
		task.spawn(function()
			v7.Enabled = true
			v7:Emit(1)
			task.wait(0.15)
			v7.Enabled = false
		end)
	end

	task.spawn(function()
		local v7 = 0.25 + tick()
		local v8 = {}

		for _ = 1, 7 do
			task.spawn(function()
				local clone2 = C.Extra.Trails.SpinTrail:Clone()
				local v9 = math.random(10, 20) / 10
				local v10 = math.random(50, 70) * 2
				clone2.ScaleModel:ScaleTo(v9)
				clone2.CFrame = cFrame * CFrame.Angles(
					math.rad((math.random(-90, 90))),
					math.rad((math.random(-90, 90))),
					(math.rad((math.random(-90, 90))))
				)
				clone2.ScaleModel.Motor6D.C0 = clone2.CFrame * CFrame.new(0, 0, -v10 * v9)
				Util.SetParentOverrideWithColor(clone2, p2, p, "DragonFruitVFXColor")
				TweenProps(
					clone2.ScaleModel.Motor6D,
					TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						C0 = CFrame.new(0, 0, 0)
					}
				):Play()
				local speed = math.random(15, 30) / 100
				v8[clone2] = {
					Speed = speed,
					SpinTime = tick()
				}

				for _, effect in pairs(clone2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") then
						effect.Enabled = true
						effect:Emit(1)
					elseif effect:IsA("Trail") then
						effect.Enabled = true
						local _Lifetime = effect:GetAttribute("_Lifetime") or effect.Lifetime

						if not effect:GetAttribute("_Lifetime") then
							effect:SetAttribute("_Lifetime", _Lifetime)
						end

						effect.Lifetime = _Lifetime * math.random(10, 35) / 10
					end
				end
			end)
		end

		while v7 - tick() > 0 do
			for k, v9 in pairs(v8) do
				if not (v9.SpinTime - tick() <= 0) then
					continue
				end

				v9.SpinTime = tick() + v9.Speed
				TweenProps(k, TweenInfo.new(v9.Speed * 1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					CFrame = k.CFrame * CFrame.Angles(0, 2.6179938779914944, 0)
				}):Play()
			end

			task.wait(0.1)
		end

		for k, v9 in pairs(v8) do
			local folder5 = k
			local v10 = v9
			task.spawn(function()
				local v11 = math.random(-90, 90) / 5
				local v12 = math.random(-90, 90) / 5

				for i, effect in pairs(folder5:GetDescendants()) do
					if effect:IsA("ParticleEmitter") then
						effect.Enabled = false
					elseif effect:IsA("Trail") then
						effect.Lifetime = 0.115
						effect.Color = ColorSequence.new(
							Util.WrapColor3Constructor(Color3.fromRGB(11, 7, 24), p, "DragonFruitVFXColor"),
							Util.WrapColor3Constructor(Color3.fromRGB(5, 5, 24), p, "DragonFruitVFXColor")
						)
					end
				end

				local tweenProps = TweenProps(
					folder5,
					TweenInfo.new(v10.Speed / 2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						CFrame = folder5.CFrame * CFrame.Angles(math.rad(v11), 2.6179938779914944, (math.rad(v12)))
					}
				)
				tweenProps:Play()
				folder5.ScaleModel.Motor6D.Enabled = false
				folder5.ScaleModel.Trail1.Anchored = true
				TweenProps(
					folder5.ScaleModel.Trail1,
					TweenInfo.new(v10.Speed / 2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						CFrame = cFrame * CFrame.Angles(math.rad(v11), 2.6179938779914944, (math.rad(v12)))
					}
				):Play()
				tweenProps.Completed:Wait()

				for i, trail in pairs(folder5:GetDescendants()) do
					if trail:IsA("Trail") then
						trail.Enabled = false
					end
				end
			end)
		end

		v8 = nil
	end)
	local currentCamera = workspace.CurrentCamera

	if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude < DISTANCE_THRESHOLD then
		Util.CameraShaker:ShakeOnce(14, 14, 0.1, 1.5)
	end

	if localPlayer == game.Players.LocalPlayer and (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude < DISTANCE_THRESHOLD then
		task.spawn(function()
			TweenProps(currentCamera, TweenInfo.new(0.325), {
				FieldOfView = 90
			}):Play()
			task.delay(0.325, function()
				TweenProps(currentCamera, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					FieldOfView = 115
				}):Play()
			end)
		end)
	end

	task.wait(0.215)
	clone:Destroy()
	local clone2 = C.Extra.StarEndImpact:Clone()
	clone2.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone2, p2, p, "DragonFruitVFXColor")

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v7 = emitter
		task.spawn(function()
			if v7:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v7:GetAttribute("EmitDelay"))
			end

			v7:Emit(v7:GetAttribute("EmitCount"))
		end)
	end

	local clone3 = C.Extra.BeforeExplosion:Clone()
	clone3.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone3, p2, p, "DragonFruitVFXColor")

	for _, emitter in pairs(clone3:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v7 = emitter
		task.spawn(function()
			v7:Emit(5)
			v7.Enabled = true
			task.wait(0.415)
			v7.Enabled = false
		end)
	end

	if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude < DISTANCE_THRESHOLD then
		task.spawn(function()
			task.wait(0.25)
			Util.CameraShaker:ShakeOnce(18, 24, 0.1, 3)
			local clone4 = C.Extra.CameraFocus:Clone()
			Util.SetParentOverrideWithColor(clone4, p2, p, "DragonFruitVFXColor")
			local renderSteppedConnection = RunService.RenderStepped:Connect(function()
				clone4.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0, 0, 0)
			end)

			for _, emitter in pairs(clone4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(1)
				end
			end

			task.wait(1.5)
			renderSteppedConnection:Disconnect()
			clone4:Destroy()
		end)
	end

	if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude < DISTANCE_THRESHOLD then
		task.spawn(function()
			task.wait(0.15)
			local screenColorDTEC = C.Extra.ScreenColorDTEC
			local v7 = game.Lighting:FindFirstChild("ScreenColorDTEC")

			if v7 then
				v7:SetAttribute("UsedTimes", v7:GetAttribute("UsedTimes") + 1)
			else
				v7 = Instance.new("ColorCorrectionEffect")
				v7.Name = "ScreenColorDTEC"
			end

			Util.SetParentOverrideWithColor(v7, game.Lighting, p, "DragonFruitVFXColor")
			local usedTimes = v7:GetAttribute("UsedTimes")
			local tweenProps = TweenProps(v7, TweenInfo.new(0.07), {
				Brightness = screenColorDTEC.Brightness,
				Contrast = screenColorDTEC.Contrast,
				Saturation = screenColorDTEC.Saturation,
				TintColor = screenColorDTEC.TintColor
			})
			tweenProps:Play()
			tweenProps.Completed:Wait()
			local tweenProps2 = TweenProps(v7, TweenInfo.new(0.05), {
				Brightness = 3
			})
			tweenProps2:Play()
			tweenProps2.Completed:Wait()
			local tweenProps3 = TweenProps(v7, TweenInfo.new(0.07), {
				Saturation = -0.5,
				Contrast = 3,
				TintColor = Util.WrapColor3ConstructorForTintColor(
					Color3.fromRGB(255, 255, 255),
					p,
					"DragonFruitVFXColor"
				),
				Brightness = 0.15
			})
			tweenProps3:Play()
			tweenProps3.Completed:Wait()

			if v7:GetAttribute("UsedTimes") == usedTimes then
				local tweenProps4 = TweenProps(v7, TweenInfo.new(0.15), {
					Saturation = 0,
					Contrast = 0,
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(172, 144, 255),
						p,
						"DragonFruitVFXColor"
					),
					Brightness = 0
				})
				tweenProps4:Play()
				tweenProps4.Completed:Wait()
				task.wait(0.15)
				local tweenProps5 = TweenProps(v7, TweenInfo.new(0.75), {
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						p,
						"DragonFruitVFXColor"
					),
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				})
				tweenProps5:Play()
				tweenProps5.Completed:Wait()

				if v7:GetAttribute("UsedTimes") == usedTimes then
					v7:Destroy()
				end
			end
		end)
	end

	task.wait(0.15)
	clone2:Destroy()
	task.spawn(function()
		local clone4 = C.Extra.SlashModel:Clone()
		clone4.PrimaryPart.CFrame = cFrame * CFrame.Angles(
			math.rad(math.random(-90, 90) / 15),
			math.rad((math.random(-90, 90))),
			(math.rad(math.random(-90, 90) / 15))
		)
		Util.SetParentOverrideWithColor(clone4, p2, p, "DragonFruitVFXColor")
		task.spawn(function()
			task.spawn(function()
				for i = 150, 225, 14 do
					clone4:ScaleTo(i / 100)
					task.wait(0.03333333333333333)
				end

				for i = 225, 270, 10 do
					clone4:ScaleTo(i / 100)
					task.wait(0.03333333333333333)
				end
			end)

			for _, beam in pairs(clone4:GetDescendants()) do
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
				local v9 = beam
				task.spawn(function()
					tweenProps.Completed:Wait()
					v9:Destroy()
				end)
			end
		end)
		task.spawn(function()
			local v7 = math.random(40, 70) / 1.5
			local v8 = 0.15 * math.random() + 0.15

			for _ = 1, 7 do
				local tweenProps = TweenProps(
					clone4.PrimaryPart,
					TweenInfo.new(v8 / 7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						CFrame = clone4.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(-v7), 0)
					}
				)
				tweenProps:Play()
				tweenProps.Completed:Wait()
			end

			local tweenProps2 = TweenProps(
				clone4.PrimaryPart,
				TweenInfo.new(v8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = clone4.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(-v7 * 2), 0)
				}
			)
			tweenProps2:Play()
			tweenProps2.Completed:Wait()
		end)
	end)

	for _ = 1, 7 do
		local clone4 = C.Extra.SlashModel:Clone()
		clone4.PrimaryPart.CFrame = cFrame * CFrame.Angles(
			math.rad(math.random(-90, 90) / 10),
			math.rad((math.random(-90, 90))),
			(math.rad(math.random(-90, 90) / 10))
		)
		Util.SetParentOverrideWithColor(clone4, p2, p, "DragonFruitVFXColor")
		local folder5 = clone4
		task.spawn(function()
			task.spawn(function()
				for i = 100, 175, 12 do
					folder5:ScaleTo(i / 100)
					task.wait(0.06666666666666667)
				end

				for i = 175, 250, 20 do
					folder5:ScaleTo(i / 100)
					task.wait(0.06666666666666667)
				end
			end)
			local v7 = 0.25 * math.random() + 0.25

			for i, beam in pairs(folder5:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				local tweenProps = TweenProps(
					beam,
					TweenInfo.new(v7, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tweenProps:Play()
				local v10 = beam
				task.spawn(function()
					tweenProps.Completed:Wait()
					v10:Destroy()
				end)
			end
		end)
		task.spawn(function()
			local v8 = math.random(40, 70)
			local v9 = 0.15 * math.random() + 0.15

			for i = 1, 12 do
				local tweenProps = TweenProps(
					clone4.PrimaryPart,
					TweenInfo.new(v9 / 12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						CFrame = clone4.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(-v8), 0)
					}
				)
				tweenProps:Play()
				tweenProps.Completed:Wait()
			end

			local tweenProps2 = TweenProps(
				clone4.PrimaryPart,
				TweenInfo.new(v9, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = clone4.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(-v8 * 2), 0)
				}
			)
			tweenProps2:Play()
			tweenProps2.Completed:Wait()
		end)
	end

	task.spawn(function()
		for _ = 1, 7 do
			task.spawn(function()
				local clone4 = C.Extra.Trails.SmallTrail:Clone()
				clone4.CFrame = cFrame * CFrame.Angles(
					0,
					math.rad((math.random(-180, 180))),
					(math.rad(math.random(-180, 180) / 15))
				) * CFrame.Angles(math.rad(math.random(-25, 50) / 5), 0, 0)
				Util.SetParentOverrideWithColor(clone4, p2, p, "DragonFruitVFXColor")
				clone4.CFrame *= CFrame.new(0, 0, -100)
				clone4.Anchored = false

				for _, effect in pairs(clone4:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = true
					end
				end

				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(700000000, 700000000, 700000000)
				bodyVelocity.P = 30000
				Util.SetParentOverrideWithColor(bodyVelocity, clone4, p, "DragonFruitVFXColor")
				local v7 = math.random(100, 250) * 2
				task.delay(math.random(10, 20) / 100, function()
					bodyVelocity:Destroy()
				end)
				bodyVelocity.Velocity = clone4.CFrame.LookVector * v7
				task.wait(1.5)

				for _, effect in pairs(clone4:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end
			end)
		end
	end)

	if localPlayer == game.Players.LocalPlayer then
		TweenProps(currentCamera, TweenInfo.new(1), {
			FieldOfView = 70
		}):Play()
	end
end

local function FinalProjectile(player, cFrame, folder5, cframe)
	local clone = C.BeforeExtra.ProjectileStartImpact:Clone()
	clone.CFrame = cFrame * CFrame.new(0, 25, 0)
	Util.SetParentOverrideWithColor(clone, folder5, player, "DragonFruitVFXColor")
	local clone2 = C.BeforeExtra.BeamProjectile:Clone()
	clone2.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone2, folder5, player, "DragonFruitVFXColor")

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true
		emitter:Emit(1)
	end

	Util.SetParentOverrideWithColor(clone2.Beam.Attach1, clone, player, "DragonFruitVFXColor")
	clone.Attach1.Position = createVector(0, -25, 0)
	TweenProps(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		CFrame = cframe
	}):Play()
	task.wait(0.35)

	for _, effect in pairs(clone2:GetDescendants()) do
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = false
		elseif effect:IsA("Beam") then
			local tweenProps = TweenProps(
				effect,
				TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Width0 = 0,
					Width1 = 0
				}
			)
			tweenProps:Play()
			local v9 = effect
			task.spawn(function()
				tweenProps.Completed:Wait()
				v9:Destroy()
			end)
		end
	end

	local clone3 = C.BeforeExtra.ProjectileExplosion:Clone()
	clone3.CFrame = clone2.CFrame
	Util.SetParentOverrideWithColor(clone3, folder5, player, "DragonFruitVFXColor")

	for _, emitter in pairs(clone3:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v7 = emitter
		task.spawn(function()
			if v7:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v7:GetAttribute("EmitDelay"))
			end

			v7:Emit(v7:GetAttribute("EmitCount"))
		end)
	end

	DeleteImpactAfterDuration(nil, clone3) -- equivalent call inferred; original call site unknown
	local cFrame2 = clone2.CFrame
	StartExplosion(player, cFrame2 * CFrame.new(0, 25, 0), folder5)
	task.spawn(function()
		local clone4 = C.AfterExtra.Explosion:Clone()
		clone4.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone4, folder5, player, "DragonFruitVFXColor")
		NumberRange.new(math.random(-90, 90))

		for _, emitter in pairs(clone4:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v7 = emitter
			task.spawn(function()
				if v7:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v7:GetAttribute("EmitDelay"))
				end

				v7:Emit(v7:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(nil, clone4) -- equivalent call inferred; original call site unknown
		local clone5 = C.AfterExtra.GroundImpact:Clone()
		clone5.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone5, folder5, player, "DragonFruitVFXColor")

		for _, emitter in pairs(clone5:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v7 = emitter
			task.spawn(function()
				if v7:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v7:GetAttribute("EmitDelay"))
				end

				v7:Emit(v7:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(nil, clone5) -- equivalent call inferred; original call site unknown
		local clone6 = C.AfterExtra.GroundExplosion:Clone()
		clone6.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone6, folder5, player, "DragonFruitVFXColor")

		for _, emitter in pairs(clone6:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v7 = emitter
			task.spawn(function()
				if v7:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v7:GetAttribute("EmitDelay"))
				end

				v7:Emit(v7:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(nil, clone6) -- equivalent call inferred; original call site unknown
		local clone7 = C.AfterExtra.GroundExplosion2:Clone()
		clone7.CFrame = cFrame2 * CFrame.Angles(-1.5707963267948966, 0, 0)
		Util.SetParentOverrideWithColor(clone7, folder5, player, "DragonFruitVFXColor")

		for _, emitter in pairs(clone7:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v7 = emitter
			task.spawn(function()
				if v7:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v7:GetAttribute("EmitDelay"))
				end

				v7:Emit(v7:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(nil, clone7) -- equivalent call inferred; original call site unknown
	end)
end

local function CameraFlame(player, folder5, p, p2, humanoidRootPart)
	local currentCamera = workspace.CurrentCamera
	local clone = C.Extra.CameraFocus2:Clone()
	Util.SetParentOverrideWithColor(clone, folder5, player, "DragonFruitVFXColor")
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0, 0, 0)
	end)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	local v7 = tick() + p
	local v8 = false

	while true do
		if (p2 - humanoidRootPart.Position).Magnitude < 540 and v8 == false then
			v8 = true

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end
		else
			v8 = false

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end

		task.wait(0.1)

		if not (v7 - tick() <= 0) then
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

local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
local v7 = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
return function(data)
	local WAIT_INTERVAL = 0.15
	ensurePartCaches(data.player)
	local root = data.Root
	local player = data.player

	if (workspace.CurrentCamera.CFrame.p - root.Position).Magnitude > 2000 then
		return
	end

	local cframe = CFrame.new(0, 1, -3)
	local folder5 = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder5, _WorldOrigin, player, "DragonFruitVFXColor")
	Util.Debris:AddItem(folder5, 25)
	local cFrame2 = root.CFrame * cframe
	local clone = C.Phase1.StartImpact:Clone()

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.LockedToPart = true
		end
	end

	clone.CFrame = cFrame2
	Util.SetParentOverrideWithColor(clone, folder5, player, "DragonFruitVFXColor")
	local v9 = Util.Sound:Play("BF_WD_Western_C_Charge_01", root)
	task.spawn(function()
		while clone:IsDescendantOf(workspace) do
			clone.CFrame = root.CFrame * cframe
			RunService.RenderStepped:Wait()
		end
	end)
	DeleteImpactAfterDuration(nil, clone) -- equivalent call inferred; original call site unknown

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v10 = emitter
		task.spawn(function()
			if v10:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v10:GetAttribute("EmitDelay"))
			end

			v10:Emit(v10:GetAttribute("EmitCount"))
		end)
	end

	task.wait(0.05)
	local clone2 = C.Phase1.FireOrbModel:Clone()
	local primaryPart = clone2.PrimaryPart
	primaryPart.CFrame = cFrame2
	primaryPart.Weld.C0 = cframe
	Util.SetParentOverrideWithColor(clone2, folder5, player, "DragonFruitVFXColor")
	primaryPart.Weld.Part0 = root

	for _, emitter in pairs(primaryPart:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	task.wait(0.25)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 10
	local tweenProps = TweenProps(
		numberValue,
		TweenInfo.new(0.125, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 100, true),
		{
			Value = 13
		}
	)
	tweenProps:Play()
	task.delay(2.5, function()
		if tweenProps ~= nil then
			tweenProps = TweenProps(
				numberValue,
				TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 100, true),
				{
					Value = 14
				}
			)
			tweenProps:Play()
		end

		task.wait(2.5)

		if tweenProps ~= nil then
			tweenProps = TweenProps(
				numberValue,
				TweenInfo.new(0.075, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 100, true),
				{
					Value = 15
				}
			)
			tweenProps:Play()
		end
	end)
	local now2 = tick()

	while true do
		if tick() - now2 > 0 then
			now2 = tick() + 0.03333333333333333
			clone2:ScaleTo(numberValue.Value / 10)
		end

		task.wait()

		if not (not data.Holding or data.Holding.Value == false or not data.Holding:IsDescendantOf(workspace)) then
			continue
		end

		local v11

		repeat
			task.wait()
			v11 = not root:IsDescendantOf(workspace)
		until data.State and data.State:GetAttribute("EndPosition") or v11

		if v11 then
			if v9 then
				Util.Sound:FadeOut(v9, 0.1)
			end

			folder5:Destroy()
			numberValue:Destroy()
			clone2:Destroy()
			tweenProps:Pause()
			tweenProps = nil
			break
		else
			if v9 then
				Util.Sound:FadeOut(v9, 0.1)
			end

			tweenProps:Pause()
			numberValue:Destroy()
			tweenProps = nil
			primaryPart.Weld:Destroy()
			primaryPart.Anchored = true
			primaryPart.Massless = false
			local endPosition = data.State:GetAttribute("EndPosition")
			local clone3 = C.Phase1.OrbTrailModel:Clone()
			Util.SetParentOverrideWithColor(primaryPart, clone3, player, "DragonFruitVFXColor")
			local primaryPart2 = clone3.PrimaryPart
			primaryPart2.CFrame = cFrame2
			Util.SetParentOverrideWithColor(clone3, folder5, player, "DragonFruitVFXColor")
			primaryPart2.Weld.Part0 = primaryPart
			task.spawn(function()
				local lastTime = tick()

				while tick() - lastTime < 0.15 do
					clone3:ScaleTo(0.25 + (tick() - lastTime) / 0.15 * 4)
					task.wait(0.03333333333333333)
				end

				clone3:ScaleTo(4.25)
			end)
			local effectsByEffect = {}

			for _, effect in pairs(primaryPart2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") then
					effect.Enabled = true
					effect:Emit(5)
					effectsByEffect[effect] = effect
				elseif effect:IsA("Trail") then
					effect.Enabled = true
				end
			end

			task.spawn(function()
				local lastTime = tick()

				repeat
					for k, v14 in pairs(effectsByEffect) do
						v14:Emit(1)
					end

					task.wait(0.015)
				until tick() - lastTime >= 0.135
			end)
			task.spawn(function()
				local lastTime = tick()

				for _ = 1, 4 do
					task.spawn(function()
						local clone4 = C.Phase1.SmallTrail:Clone()
						clone4.CFrame = primaryPart.CFrame
						Util.SetParentOverrideWithColor(clone4, folder5, player, "DragonFruitVFXColor")
						clone4.Weld.Part0 = primaryPart
						clone4.Weld.Part1 = clone4
						clone4.Weld.C0 = clone4.Weld.Part0.CFrame:ToObjectSpace(clone4.Weld.Part1.CFrame) * CFrame.Angles(
							0,
							0,
							(math.rad((math.random(-180, 180))))
						)

						for _, effect in pairs(clone4:GetDescendants()) do
							if effect:IsA("ParticleEmitter") then
								effect.Enabled = true
							elseif effect:IsA("Trail") then
								effect.Enabled = true
							end
						end

						repeat
							clone4.Weld.C0 = clone4.Weld.Part0.CFrame:ToObjectSpace(clone4.Weld.Part1.CFrame) * CFrame.Angles(
								0,
								0,
								0.2617993877991494
							)
							RunService.Heartbeat:Wait()
						until tick() - lastTime >= 0.135

						for _, effect in pairs(clone4:GetDescendants()) do
							if effect:IsA("ParticleEmitter") then
								effect.Enabled = false
							elseif effect:IsA("Trail") then
								effect.Enabled = false
							end
						end
					end)
				end
			end)
			primaryPart.CFrame = CFrame.new(primaryPart.Position, endPosition)
			task.wait()
			local clone4 = C.Phase1.OrbShoot:Clone()
			clone4.CFrame = primaryPart.CFrame
			Util.SetParentOverrideWithColor(clone4, folder5, player, "DragonFruitVFXColor")
			Util.Sound:Play("BF_WD_Western_C_Fire_01", clone4.Position)
			DeleteImpactAfterDuration(nil, clone4) -- equivalent call inferred; original call site unknown

			for _, emitter in pairs(clone4:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v14 = emitter
				task.spawn(function()
					if v14:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v14:GetAttribute("EmitDelay"))
					end

					v14:Emit(v14:GetAttribute("EmitCount"))
				end)
			end

			TweenProps(primaryPart, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = CFrame.new(endPosition, primaryPart.Position + primaryPart.CFrame.LookVector) * CFrame.Angles(
					0,
					3.141592653589793,
					0
				)
			}):Play()
			local position = primaryPart.Position
			local character = localPlayer.Character

			if character ~= nil then
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart and (humanoidRootPart.Position - position).Magnitude <= 250 then
					Util.CameraShaker:ShakeOnce(16, 9, 0.5, 1)
				end
			end

			local duration = data.Duration or 1
			ScreenEffect(player, endPosition, duration) -- equivalent call inferred; original call site unknown
			task.wait(WAIT_INTERVAL)
			task.wait(WAIT_INTERVAL)

			for _, emitter in pairs(primaryPart:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			for _, emitter in pairs(primaryPart2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			primaryPart2.Anchored = true
			DeleteImpactAfterDuration(nil, primaryPart) -- equivalent call inferred; original call site unknown
			local groundBurnDuration = data.GroundBurnDuration or 3
			local downRayRange = data.DownRayRange or 700
			local aoeRange = data.AoeRange or 180
			local _ = data.ExplosionDelay or 0.3
			local cFrame = primaryPart.CFrame
			local clone5 = C.Phase2.StarStartImpactSmall:Clone()
			clone5.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone5, folder5, player, "DragonFruitVFXColor")
			local clonesByClone = {
				[clone5] = clone5
			}
			Util.Sound:Play("BF_WD_Western_C_Blackhole_01", cFrame.Position)
			task.spawn(function()
				local v16 = tick() + 7

				while v16 - tick() > 0 do
					for k, v17 in pairs(clonesByClone) do
						v17.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.p, cFrame.Position) * CFrame.new(
							0,
							0,
							-360
						)
					end

					RunService.PreRender:Wait()
				end
			end)
			DeleteImpactAfterDuration(nil, clone5) -- equivalent call inferred; original call site unknown

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

			local clonesByClone2 = clonesByClone
			task.spawn(function()
				task.wait(0.1)
				local clone6 = C.Extra.BeforeExplosionSmall:Clone()
				clone6.CFrame = cFrame2
				Util.SetParentOverrideWithColor(clone6, folder5, player, "DragonFruitVFXColor")
				clonesByClone2[clone6] = clone6

				for i, emitter in pairs(clone6:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v16 = emitter
					task.spawn(function()
						v16:Emit(5)
						v16.Enabled = true
						task.wait(0.3)
						v16.Enabled = false
					end)
				end
			end)
			task.wait(WAIT_INTERVAL)
			primaryPart:Destroy()
			task.wait(WAIT_INTERVAL)
			local clone6 = C.Phase2.StarExplosionBig:Clone()
			clone6.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone6, folder5, player, "DragonFruitVFXColor")
			clonesByClone[clone6] = clone6
			DeleteImpactAfterDuration(nil, clone6) -- equivalent call inferred; original call site unknown

			for _, emitter in pairs(clone6:GetDescendants()) do
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

			local numberValue2 = Instance.new("NumberValue", folder5)
			numberValue2.Value = 0.5
			local cFrame3 = cFrame
			task.delay(0.1, function()
				local SunlightBurst = require(script.SunlightBurst)
				SunlightBurst(cFrame3.Position, 360, folder5, 0.4 + duration * 3, numberValue2, player)
			end)
			SpinStars(player, primaryPart, folder5, duration)
			local clonesByClone3 = {}
			local cFrame4 = cFrame
			local v20 = duration
			task.spawn(function()
				for i = 1, 8 do
					task.wait(0.1)
					local raycastParams2 = RaycastParams.new()
					raycastParams2.IgnoreWater = false
					raycastParams2.FilterDescendantsInstances = {
						workspace.Characters,
						workspace.Enemies,
						workspace._WorldOrigin
					}
					local v21 = CFrame.new(cFrame4.Position) * CFrame.Angles(0, i / 8 * 3.141592653589793 * 2, 0) * CFrame.new(
						0,
						0,
						data.AoeRange * (0.3 + math.random() * 0.7)
					)
					local raycastResult = workspace:Raycast(
						v21.Position + createVector(0, 15, 0) + createVector(0, 1, 0),
						createVector(-0, -1400, -0),
						raycastParams2
					)

					if not raycastResult then
						continue
					end

					local clone7 = C.Phase3.LavaBeamModel:Clone()
					local primaryPart3 = clone7.PrimaryPart
					primaryPart3.CFrame = CFrame.new(raycastResult.Position)
					Util.SetParentOverrideWithColor(clone7, folder5, player, "DragonFruitVFXColor")
					clone7:ScaleTo(math.random(10, 20) / 10)
					local position2 = primaryPart3.Attach1.Position * math.random(12, 20) / 10
					primaryPart3.Attach1.Position = position2
					local v23 = 0.75 + math.random() * 1.25

					for i2, descendant in pairs(primaryPart3:GetDescendants()) do
						if descendant:IsA("ParticleEmitter") then
							descendant.Enabled = true
						elseif descendant:IsA("Beam") then
							local tweenProps2 = TweenProps(descendant, TweenInfo.new(v23), {
								Width0 = descendant.Width0,
								Width1 = descendant.Width1,
								CurveSize0 = descendant.CurveSize0,
								CurveSize1 = descendant.CurveSize1
							})
							descendant.Width0 = 1
							descendant.Width1 = 1
							descendant.CurveSize0 = math.random(-10, 10)
							descendant.CurveSize1 = math.random(-10, 10)
							tweenProps2:Play()
						elseif descendant:IsA("Attachment") then
							local tweenProps2 = TweenProps(descendant, TweenInfo.new(v23), {
								Position = descendant.Position
							})
							descendant.Position = createVector(0, 0, 0)
							tweenProps2:Play()
						end
					end

					clonesByClone3[clone7] = clone7
				end

				task.wait(v20 * 2)

				for k, folder6 in pairs(clonesByClone3) do
					for i, descendant in pairs(folder6:GetDescendants()) do
						if descendant:IsA("ParticleEmitter") then
							descendant.Enabled = false
						elseif descendant:IsA("Beam") then
							TweenProps(descendant, TweenInfo.new(0.3 + math.random(35, 100) / 100), {
								Width0 = 0,
								Width1 = 0
							}):Play()
							local v21 = descendant
							task.delay(1, function()
								v21:Destroy()
							end)
						elseif descendant:IsA("Attachment") then
							TweenProps(descendant, TweenInfo.new(0.3 + math.random(35, 100) / 100), {
								Position = createVector(0, 0, 0)
							}):Play()
						end
					end
				end

				clonesByClone3 = nil
			end)
			local v21 = nil
			local v22 = cFrame
			task.spawn(function()
				local position2 = v22.Position
				local ray = Ray.new(position2 + createVector(0, 1, 0), createVector(0, 1, 0) * -downRayRange)
				local part, v24 = workspace:FindPartOnRayWithIgnoreList(ray, v7)
				local raycastResult = workspace:Raycast(
					position2 + createVector(0, 1, 0),
					createVector(0, 1, 0) * -downRayRange,
					raycastParams
				)
				v21 = v24

				if raycastResult then
					for i = 1, 7 do
						task.spawn(function()
							local clone7 = C.Phase3.SpinTrail:Clone()
							local v25 = math.random(10, 20) / 10
							local v26 = math.random(50, 70) * 4.25
							clone7.ScaleModel:ScaleTo(v25)
							clone7.CFrame = CFrame.new(v21 + Vector3.new(0, math.random(5, 25), 0)) * CFrame.Angles(
								math.rad(math.random(-90, 90) / 100),
								math.rad((math.random(-90, 90))),
								(math.rad(math.random(-90, 90) / 100))
							)
							clone7.ScaleModel.Trail1.WeldConstraint.Enabled = false
							clone7.ScaleModel.Trail1.CFrame = clone7.CFrame * CFrame.new(0, 0, -v26 * v25) * CFrame.Angles(
								0,
								1.5707963267948966,
								0
							)
							clone7.ScaleModel.Trail1.WeldConstraint.Enabled = true
							Util.SetParentOverrideWithColor(clone7, folder5, player, "DragonFruitVFXColor")
							local flag = true
							local v27 = math.random(15, 30) / 100
							task.spawn(function()
								task.wait(3.5 - (math.random(10, 150) / 100 + v27))
								flag = false
							end)

							for i2, effect in pairs(clone7:GetDescendants()) do
								if effect:IsA("ParticleEmitter") then
									effect.Enabled = true
									effect:Emit(1)
								elseif effect:IsA("Trail") then
									effect.Enabled = true
									local _Lifetime = effect:GetAttribute("_Lifetime") or effect.Lifetime

									if not effect:GetAttribute("_Lifetime") then
										effect:SetAttribute("_Lifetime", _Lifetime)
									end

									effect.Lifetime = _Lifetime * math.random(10, 35) / 10
								end
							end

							while flag do
								local tweenProps2 = TweenProps(
									clone7,
									TweenInfo.new(v27, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
									{
										CFrame = clone7.CFrame * CFrame.Angles(0, 0.8726646259971648, 0)
									}
								)
								tweenProps2:Play()
								tweenProps2.Completed:Wait()
							end

							local v28 = math.random(-90, 90) / 5
							local v29 = math.random(-90, 90) / 5
							local tweenProps3 = TweenProps(
								clone7,
								TweenInfo.new(v27 / 2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									CFrame = clone7.CFrame * CFrame.Angles(
										math.rad(v28),
										2.6179938779914944,
										(math.rad(v29))
									)
								}
							)
							tweenProps3:Play()
							clone7.ScaleModel.Trail1.WeldConstraint.Enabled = false
							clone7.ScaleModel.Trail1.Anchored = true
							TweenProps(
								clone7.ScaleModel.Trail1,
								TweenInfo.new(v27 / 2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									CFrame = v22 * CFrame.Angles(math.rad(v28), 2.6179938779914944, (math.rad(v29)))
								}
							):Play()
							tweenProps3.Completed:Wait()

							for i2, effect in pairs(clone7:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = false
								end
							end
						end)
					end
				end
			end)
			local downRayRange2 = downRayRange
			local cFrame5 = cFrame
			task.spawn(function()
				tick()

				local function RocksFlyVelocityCallbackFunction2(p)
					return CFrame.new(
						p.Position,
						(CFrame.new(p.Position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
							0,
							0,
							-70
						)).Position + Vector3.new(math.random(-10, 10), math.random(80, 250), math.random(-10, 10))
					).LookVector * math.random(150, 180) * (2 + math.random() * 1.25)
				end

				local v28 = {
					Radius = 25,
					Size = 5,
					Duration = 3,
					Amount = 3,
					CurrentRock = C.CraterRock
				}
				local v29 = {
					RockAmount = 1,
					RockSize = 7,
					PositionOffset = 30,
					RockRotationAmount = 7,
					RockRotationSpeed = 0.15,
					RockRotationPower = 100,
					Duration = 3.5
				}
				task.spawn(function()
					local random = Random.new(data.Seed)
					local clone7 = C.Phase3.Explosion2:Clone()
					local descendants = clone7:GetDescendants()

					for k, emitter in pairs(descendants) do
						if emitter:IsA("ParticleEmitter") then
							emitter.LockedToPart = false
						end
					end

					local clone8 = C.Phase3.GroundImpact:Clone()
					local descendants2 = clone8:GetDescendants()

					for k, emitter in pairs(descendants2) do
						if emitter:IsA("ParticleEmitter") then
							emitter.LockedToPart = false
						end
					end

					local clone9 = C.Phase3.GroundExplosion:Clone()
					local descendants3 = clone9:GetDescendants()

					for k, emitter in pairs(descendants3) do
						if emitter:IsA("ParticleEmitter") then
							emitter.LockedToPart = false
						end
					end

					for i = 1, data.ProjectileCount do
						local v30 = i
						task.spawn(function()
							local v31 = {
								DownRayRange = downRayRange2,
								AoeRange = aoeRange,
								Speed = random:NextInteger(35, 100) / 12.5,
								Offset = random:NextInteger(35, 50) * 2,
								i = v30,
								ProjectileCount = data.ProjectileCount
							}

							if v30 % 4 ~= 0 then
								return
							end

							local part = v4:GetPart()
							Util.ColorShiftObjectDescendants(part, player, "DragonFruitVFXColor")
							part.CFrame = cFrame5
							local projectileDrop = ProjectileDrop(
								player,
								part,
								cFrame5,
								folder5,
								v7,
								raycastParams,
								v31,
								random
							)
							local cframe2 = CFrame.new(part.Position + createVector(0, 3, 0))
							local clone10 = C.Phase3.Explosion:Clone()
							clone10.CFrame = cframe2
							Util.SetParentOverrideWithColor(clone10, folder5, player, "DragonFruitVFXColor")
							Util.Sound:Play(
								"BF_WD_Western_C_MeteorRain_Impacts_0" .. tostring(math.random(1, 4)),
								clone10.Position
							)
							local numberRange = NumberRange.new(math.random(-90, 90))

							for i2, emitter in pairs(clone10:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								if emitter.Parent == clone10.Attachment2 then
									emitter.Rotation = numberRange
								end

								local v33 = emitter
								task.spawn(function()
									if v33:GetAttribute("EmitDelay") ~= 0 then
										task.wait(v33:GetAttribute("EmitDelay"))
									end

									v33:Emit(v33:GetAttribute("EmitCount"))
								end)
							end

							DeleteImpactAfterDuration(nil, clone10) -- equivalent call inferred; original call site unknown
							task.spawn(function()
								local position2 = cframe2.Position
								local character2 = localPlayer.Character

								if character2 ~= nil then
									local humanoidRootPart = character2:FindFirstChild("HumanoidRootPart")

									if humanoidRootPart and (humanoidRootPart.Position - position2).Magnitude <= 100 then
										Util.CameraShaker:ShakeOnce(10, 5, 0.115, 0.1)
									end
								end

								clone7.CFrame = cframe2
								Util.SetParentOverrideWithColor(clone7, folder5, player, "DragonFruitVFXColor")

								for k, emitter in pairs(descendants) do
									if not emitter:IsA("ParticleEmitter") then
										continue
									end

									local v33 = emitter
									task.spawn(function()
										if v33:GetAttribute("EmitDelay") ~= 0 then
											task.wait(v33:GetAttribute("EmitDelay"))
										end

										v33:Emit(v33:GetAttribute("EmitCount"))
									end)
								end
							end)

							if projectileDrop then
								task.spawn(function()
									if math.random(1, 3) == 1 then
										local part2 = v2:GetPart()
										Util.ColorShiftObjectDescendants(part2, player, "DragonFruitVFXColor")
										part2.CFrame = CFrame.new(part.Position)

										for i2, emitter in pairs(part2:GetDescendants()) do
											if not emitter:IsA("ParticleEmitter") then
												continue
											end

											emitter.Enabled = true
											local v33 = emitter
											task.spawn(function()
												task.wait(math.random(10, 30) / 10)
												v33.Enabled = false
											end)
										end

										task.delay(3, function()
											ReturnImpactAfterDuration(nil, part2, v2) -- equivalent call inferred; original call site unknown
										end)
									end
								end)
								local cFrame6 = AlignCFrame(
									player,
									CFrame.new(projectileDrop.Position),
									projectileDrop.Normal
								) + projectileDrop.Normal * 0.05
								RockCrater(player, projectileDrop, folder5, v28)
								task.spawn(function()
									clone8.CFrame = cFrame6
									Util.SetParentOverrideWithColor(clone8, folder5, player, "DragonFruitVFXColor")

									for k, emitter in pairs(descendants2) do
										if not emitter:IsA("ParticleEmitter") then
											continue
										end

										local v34 = emitter
										task.spawn(function()
											if v34:GetAttribute("EmitDelay") ~= 0 then
												task.wait(v34:GetAttribute("EmitDelay"))
											end

											v34:Emit(v34:GetAttribute("EmitCount"))
										end)
									end

									clone9.CFrame = cFrame6
									Util.SetParentOverrideWithColor(clone9, folder5, player, "DragonFruitVFXColor")

									for k, emitter in pairs(descendants3) do
										if not emitter:IsA("ParticleEmitter") then
											continue
										end

										local v34 = emitter
										task.spawn(function()
											if v34:GetAttribute("EmitDelay") ~= 0 then
												task.wait(v34:GetAttribute("EmitDelay"))
											end

											v34:Emit(v34:GetAttribute("EmitCount"))
										end)
									end

									GroundFlyRocks(
										player,
										projectileDrop,
										folder5,
										v29,
										RocksFlyVelocityCallbackFunction2
									)
									local part2 = v3:GetPart()
									Util.ColorShiftObjectDescendants(part2, player, "DragonFruitVFXColor")
									part2.CFrame = cFrame6

									for i2, emitter in pairs(part2:GetDescendants()) do
										if not emitter:IsA("ParticleEmitter") then
											continue
										end

										if emitter.Parent == part2.Attachment then
											local v34 = emitter
											task.spawn(function()
												for i3 = 1, groundBurnDuration do
													v34:Emit(1)
													task.wait(1)
												end
											end)
										elseif emitter.Parent ~= part2.Attachment then
											local v34 = emitter
											task.spawn(function()
												v34.Enabled = true
												task.wait(groundBurnDuration)
												v34.Enabled = false
											end)
										end
									end

									task.delay(groundBurnDuration, function()
										ReturnImpactAfterDuration(nil, part2, v3) -- equivalent call inferred; original call site unknown
									end)
								end)
							end
						end)
					end
				end)
			end)
			local v28 = duration
			task.spawn(function()
				if localPlayer.Character or not localPlayer.Character.HumanoidRootPart then
					CameraFlame(player, folder5, v28 * 3 + 0.05, endPosition, localPlayer.Character.HumanoidRootPart)
				end
			end)
			task.wait(2.5)
			local v30 = false
			local v31 = {}
			local v33 = {}
			task.spawn(function()
				local v35 = tick() + 3

				repeat
					for k, v36 in pairs(v33) do
						v36:Emit(1)
					end

					task.wait(0.0015)
				until v35 - tick() <= 0
			end)
			local v35 = cFrame
			local v36 = v33
			local clonesByClone4 = clonesByClone
			local v37 = numberValue2
			local effectsByEffect2 = v31
			local auraModelsByAuraModel = {}
			task.spawn(function()
				for i = 1, 5 do
					task.spawn(function()
						local cFrame6 = v35 * CFrame.Angles(
							math.rad((math.random(-180, 180))),
							math.rad((math.random(-180, 180))),
							(math.rad((math.random(-180, 180))))
						) * CFrame.new(0, 0, -700)
						local position2 = v35.Position
						local v39 = math.random(70, 100) / 3
						local clone7 = C.Phase4.FocusTrail:Clone()
						clone7.CFrame = cFrame6
						Util.SetParentOverrideWithColor(clone7, folder5, player, "DragonFruitVFXColor")

						for i2, effect in pairs(clone7:GetDescendants()) do
							if effect:IsA("ParticleEmitter") then
								if effect.Parent.Name == "Aura" or effect.Parent.Name == "Impact" then
									if effect.Parent.Name == "Impact" then
										effect:Emit(effect:GetAttribute("EmitCount"))
									end
								else
									effect:Emit(1)
									effect.Enabled = true
									v36[effect] = effect
								end
							elseif effect:IsA("Trail") then
								effect.Enabled = true
							end
						end

						local position3 = clone7.Position
						local magnitude = (position3 - position2).Magnitude
						clone7.CFrame = CFrame.new(position3, position2)
						local v40 = (position3 - position2) / 2
						local position4 = CFrame.new(CFrame.new(position3) * (v40 / -1.5)).Position
						local position5 = CFrame.new(CFrame.new(position2) * (v40 / 1.5)).Position
						local v41 = magnitude / 1.25
						local v42 = position4 + Vector3.new(
							math.random(-v41, v41),
							math.random(-v41 / 2, v41),
							math.random(-v41, v41)
						)
						local v43 = position5 + Vector3.new(
							math.random(-v41, v41),
							math.random(-v41 / 2, v41),
							math.random(-v41, v41)
						)
						local lastTime = tick()
						local v44 = magnitude / v39 / 60

						while tick() - lastTime < v44 do
							local v45 = (tick() - lastTime) / v44
							local v46 = cubicBezier(player, v45, position3, v42, v43, position2)
							clone7.CFrame = clone7.CFrame:Lerp(CFrame.new(v46, position2), v45)
							RunService.Heartbeat:Wait()
						end

						if v30 == true then
							clone7:Destroy()
							return
						end

						clone7.Trail.WeldConstraint.Enabled = false
						clone7.Trail.Anchored = true
						clone7.SmallAura.WeldConstraint.Enabled = false
						clone7.SmallAura.Anchored = true
						clone7.Star.WeldConstraint.Enabled = false
						clone7.Star.Anchored = true
						clonesByClone4[clone7] = clone7
						v37.Value = math.clamp(v37.Value + 0.1, 0.2, 1)

						for i2, effect in pairs(clone7:GetDescendants()) do
							if effect:IsA("ParticleEmitter") then
								if effect.Parent.Name == "Aura" then
									effect:Emit(1)
									effect.Enabled = true
									effectsByEffect2[effect] = effect
								elseif effect.Parent.Name == "Impact" then
									effect:Emit(effect:GetAttribute("EmitCount"))
								else
									effect.Enabled = false
									v36[effect] = nil
								end
							elseif effect:IsA("Trail") then
								effect.Enabled = false
							end
						end

						auraModelsByAuraModel[clone7.AuraModel] = clone7.AuraModel
					end)
					task.wait(0.125)

					for k, v38 in pairs(auraModelsByAuraModel) do
						v38:ScaleTo(v37.Value)
					end
				end
			end)
			local cFrame7 = cFrame
			local clonesByClone5 = clonesByClone
			task.delay(1, function()
				local clone7 = C.Phase4.FinalExplosionCharge:Clone()
				clone7.CFrame = cFrame7
				Util.SetParentOverrideWithColor(clone7, folder5, player, "DragonFruitVFXColor")
				clonesByClone5[clone7] = clone7

				for i, emitter in pairs(clone7:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v39 = emitter
					task.spawn(function()
						v39:Emit(5)
						v39.Enabled = true
						task.wait(0.5)
						v39.Enabled = false
					end)
				end
			end)
			local cFrame8 = cFrame
			task.spawn(function()
				task.wait(0.95)

				for i = 1, 1 do
					local clone7 = C.Extra.SlashModel:Clone()
					clone7.PrimaryPart.CFrame = CFrame.new(cFrame8.Position) * CFrame.new(0, -75, 0) * CFrame.Angles(
						0,
						math.rad((math.random(-90, 90))),
						0
					)
					Util.SetParentOverrideWithColor(clone7, folder5, player, "DragonFruitVFXColor")
					local folder6 = clone7
					task.spawn(function()
						task.spawn(function()
							for i2 = 700, 375, -50 do
								folder6:ScaleTo(i2 / 100)
								task.wait(0.03333333333333333)
							end

							for i2 = 275, 100, -30 do
								folder6:ScaleTo(i2 / 100)
								task.wait(0.03333333333333333)
							end
						end)

						for i2, beam in pairs(folder6:GetDescendants()) do
							if not beam:IsA("Beam") then
								continue
							end

							local tweenProps2 = TweenProps(
								beam,
								TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
								{
									Width0 = 0,
									Width1 = 0
								}
							)
							tweenProps2:Play()
							local v42 = beam
							task.spawn(function()
								tweenProps2.Completed:Wait()
								v42:Destroy()
							end)
						end
					end)
					task.spawn(function()
						local v41 = math.random(40, 70)
						local v42 = 0.15 * math.random() + 0.15

						for i2 = 1, 12 do
							local tweenProps2 = TweenProps(
								clone7.PrimaryPart,
								TweenInfo.new(v42 / 12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									CFrame = clone7.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(-v41), 0)
								}
							)
							tweenProps2:Play()
							tweenProps2.Completed:Wait()
						end

						local tweenProps3 = TweenProps(
							clone7.PrimaryPart,
							TweenInfo.new(v42, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = clone7.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(-v41 * 2), 0)
							}
						)
						tweenProps3:Play()
						tweenProps3.Completed:Wait()
					end)
				end
			end)
			task.wait(1)
			v30 = true
			local clone7 = C.BeforeExtra.ProjectileStartImpact:Clone()
			clone7.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone7, folder5, player, "DragonFruitVFXColor")
			clonesByClone[clone7] = clone7

			for _, emitter in pairs(clone7:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v40 = emitter
				task.spawn(function()
					if v40:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v40:GetAttribute("EmitDelay"))
					end

					v40:Emit(v40:GetAttribute("EmitCount"))
				end)
			end

			for _, v40 in pairs(v31) do
				v40.Enabled = false
			end

			FinalProjectile(player, cFrame, folder5, CFrame.new(v21))
			break
		end
	end
end