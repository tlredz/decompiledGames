local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local function preloadRetextureImages(folder)
	if not RunService:IsClient() then
		return
	end

	local v = {}
	local v2 = {}

	for _, configuration in folder:GetDescendants() do
		if not (configuration:IsA("Configuration") and configuration.Name == "RetextureForRecolor") then
			continue
		end

		local decal = configuration:FindFirstChildWhichIsA("Decal")
		local texture = decal and decal.Texture

		if not texture or texture == "" or v[texture] then
			continue
		end

		v[texture] = true
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Image = texture
		table.insert(v2, imageLabel)
	end

	if #v2 > 0 then
		local success, result = pcall(function()
			ContentProvider:PreloadAsync(v2)
		end)

		for _, v3 in v2 do
			v3:Destroy()
		end

		if not success then
			warn("Failed to preload recolor textures:", result)
		end
	end
end

preloadRetextureImages(script)
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 0, 20)),
	ColorSequenceKeypoint.new(0.55, Color3.fromRGB(185, 139, 244)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 220, 255))
})
local colorSequence2 = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 0, 20)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(235, 220, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 0, 20))
})
local color = Color3.fromRGB(185, 139, 244)
local v = {
	BackForce = true,
	BlueLines = true,
	LinesUp = true,
	redline = true,
	Shockwaves = true,
	ShotSting = true,
	Strike = true,
	WhiteLines = true
}
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local _ = FX:WaitForChild("Longsword").X
local x_Tr = FX:WaitForChild("YetiEffectsRed").X_Tr
local Rock2 = require(game.ReplicatedStorage.Util.Rock2)
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt

local function putFolder(parent, name: string)
	local v2 = parent:FindFirstChild(name)

	if v2 == nil then
		v2 = Instance.new("Folder")
		v2.Name = name
		v2.Parent = parent
	end

	return v2
end

local function putValueAsValueObject(parent, name: string, p, value: number)
	local v3 = {
		boolean = "BoolValue",
		CFrame = "CFrameValue",
		Color3 = "Color3Value",
		number = "NumberValue",
		Instance = "ObjectValue",
		Ray = "RayValue",
		string = "StringValue",
		Vector3 = "Vector3Value"
	}
	local instance = parent:FindFirstChild(name)

	if instance == nil then
		instance = Instance.new(v3[typeof(p)])
		instance.Name = name
		instance.Parent = parent
	end

	instance.Value = p
	destroyAfter(instance, value or 60)
	return instance
end

local function getValueOfValueObject(instance, childName: string)
	local child = instance:FindFirstChild(childName)

	if child == nil then
		return nil
	end

	return child.Value
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

local function createDefaultProjectile(p: number)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Shape = Enum.PartType.Ball
	part.Size = createVector(4, 4, 4)
	part.Transparency = 1
	part.Name = "Projectile"
	part.Parent = _WorldOrigin
	destroyAfter(part, p + 7)
	return part
end

-- equivalent calls inferred from this helper; original call sites unknown
local function snapProjectileToFinalPos(p, p2)
	p.CFrame = p.CFrame.Rotation + p2
end

local function shouldStopProjectile(instance)
	return instance:GetAttribute("ProjectileActive") ~= true and instance:GetAttribute("ImpactPos") ~= nil and instance:GetAttribute("DisabledInterp") < 0.9999
end

local function hasVoidYetiSkin(player, hrp)
	if typeof(player) == "Instance" then
		local yetiFruitVFXColor = player:FindFirstChild("YetiFruitVFXColor")

		if yetiFruitVFXColor and yetiFruitVFXColor:GetAttribute("SkinStorageKey") == "FIENDSKINsealed" then
			return true
		end
	end

	if hrp and hrp:GetAttribute("YetiSkin") == "FIENDSKINsealed" then
		return true
	end

	local parent = hrp and hrp.Parent
	local primaryPart = parent and parent.PrimaryPart

	if primaryPart and primaryPart:GetAttribute("YetiSkin") == "FIENDSKINsealed" then
		return true
	end

	return false
end

local function applyVoidSkyStreakColor(instance)
	if instance:IsA("Beam") then
		instance.Color = colorSequence2
	elseif instance:IsA("ParticleEmitter") or instance:IsA("Trail") then
		instance.Color = colorSequence
	elseif instance:IsA("PointLight") or instance:IsA("SpotLight") or instance:IsA("SurfaceLight") then
		instance.Color = color
	elseif instance:IsA("Decal") then
		instance.Color3 = color
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyVoidSkyStreakOverride(folder, flag: boolean?)
	for _, decal in ipairs(folder:GetDescendants()) do
		if flag or v[decal.Name] then
			applyVoidSkyStreakColor(decal)
		elseif decal:IsA("Decal") and decal.Name == "Decal" and decal.Parent and decal.Parent.Name == "Part" and decal.Parent.Parent and decal.Parent.Parent.Name == "Paraboloid" then
			applyVoidSkyStreakColor(decal)
		end
	end
end

local function fireClientProjectile(p: number, callback, p2, part, callback2)
	local v2 = callback2 or function(_)
		return CFrame.new()
	end
	local v3 = p2 or Instance.new("Folder")

	if not part then
		part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Shape = Enum.PartType.Ball
		part.Size = createVector(4, 4, 4)
		part.Transparency = 1
		part.Name = "Projectile"
		part.Parent = _WorldOrigin
		destroyAfter(part, p + 7)
	end

	part.CFrame = CFrame.lookAt(callback(0.001), callback(0.002)) * v2(0.001)
	local bindableEvent = Instance.new("BindableEvent")
	destroyAfter(bindableEvent, 7)
	local v5 = false
	local connection = nil
	connection = heartbeatLoopFor2(p, function(_, _, p3)
		local v6 = v3
		local v7

		if v6:GetAttribute("ProjectileActive") == true or v6:GetAttribute("ImpactPos") == nil then
			v7 = false
		else
			v7 = v6:GetAttribute("DisabledInterp") < 0.9999
		end

		if not v7 then
			part.CFrame = CFrame.lookAt(callback(p3), callback(p3 + 0.01)) * v2(p3)
			return
		end

		connection:Disconnect()
		connection = nil
		snapProjectileToFinalPos(part, v3:GetAttribute("ImpactPos")) -- equivalent call inferred; original call site unknown
		bindableEvent:Fire(v3:GetAttribute("ImpactPos"), "Impact")
		v5 = true
	end, function()
		if v5 == true then
			return
		end

		snapProjectileToFinalPos(part, callback(1)) -- equivalent call inferred; original call site unknown
		bindableEvent:Fire(callback(1), "NonImpact")
	end)
	return bindableEvent, part, connection
end

local function cameraShakeAt(vector2: Vector3, value: number, value2: number, value3: number, value4: number, value5: number)
	local v2 = value2 or 8
	local v3 = value3 or 14
	local v4 = value4 or 0.2
	local v5 = value5 or 0.7

	if (value or 300) > (Workspace.CurrentCamera.CFrame.Position - vector2).Magnitude then
		Util.CameraShaker:ShakeOnce(v2, v3, v4, v5)
	end
end

local function haltUntilCondition(callback, value: number?)
	local v2 = value or 10
	local bindableEvent = Instance.new("BindableEvent")
	task.delay(v2, bindableEvent.Fire, bindableEvent)
	local connection = nil
	connection = heartbeatLoopFor2(v2, function()
		local success, result = pcall(callback)

		if success and result then
			bindableEvent:Fire()
			connection:Disconnect()
			connection = nil
		elseif not success then
			print("haltUntilCondition: Error in predicate function: ", result)
			bindableEvent:Fire()
			connection:Disconnect()
			connection = nil
		end
	end)
	bindableEvent.Event:Wait()
	bindableEvent:Destroy()
end

local function alignCFrameWithPlane(rotation: CFrame, vector2: Vector3)
	local v2 = { rotation.RightVector, rotation.UpVector, rotation.LookVector }
	local v3 = -1e999
	local vector3 = nil

	for _, vector4 in ipairs(v2) do
		local dot = vector4:Dot(vector2)

		if not (v3 < math.abs(dot)) then
			continue
		end

		v3 = math.abs(dot)
		vector3 = math.sign(dot) * vector4
	end

	local cross = vector3:Cross(vector2)
	local v4 = math.acos((math.clamp(v3, -1, 1)))

	if cross.Magnitude < 0.0001 then
		return rotation.Rotation
	end

	return CFrame.fromAxisAngle(cross, v4) * rotation.Rotation
end

local function snapPointToPlane(vector2: Vector3, vector3: Vector3, vector4: Vector3)
	local unit = vector3.Unit
	local X = unit.X
	local Y = unit.Y
	local Z = unit.Z
	local X2 = vector2.X
	local Z2 = vector2.Z
	local dot = vector4:Dot(unit)
	local v2

	if math.abs(Y) < 0.1 then
		v2 = vector2.Y
	else
		v2 = (dot - X2 * X - Z2 * Z) / Y
	end

	return (Vector3.new(X2, v2, Z2))
end

local function alignWithGround(folder, raycastResult: RaycastResult)
	local v2 = not raycastResult and createVector(0, 1, 0) or raycastResult.Normal

	if typeof(folder) == "CFrame" then
		local position = folder.Position
		local rotation = folder.Rotation
		local position2

		if raycastResult then
			position2 = raycastResult.Position
		else
			position2 = position
		end

		local unit = v2.Unit
		local X = unit.X
		local Y = unit.Y
		local Z = unit.Z
		local X2 = position.X
		local Z2 = position.Z
		local dot = position2:Dot(unit)
		local v3

		if math.abs(Y) < 0.1 then
			v3 = position.Y
		else
			v3 = (dot - X2 * X - Z2 * Z) / Y
		end

		local vector2 = Vector3.new(X2, v3, Z2)
		local v4 = vector2 + v2 * (position.Y - vector2.Y)
		return alignCFrameWithPlane(rotation, v2) + v4
	else
		if typeof(folder) == "Instance" and folder:IsA("BasePart") then
			local position = folder.CFrame.Position
			local rotation = folder.CFrame.Rotation
			local position2

			if raycastResult then
				position2 = raycastResult.Position
			else
				position2 = position
			end

			local unit = v2.Unit
			local X = unit.X
			local Y = unit.Y
			local Z = unit.Z
			local X2 = position.X
			local Z2 = position.Z
			local dot = position2:Dot(unit)
			local v3

			if math.abs(Y) < 0.1 then
				v3 = position.Y
			else
				v3 = (dot - X2 * X - Z2 * Z) / Y
			end

			local vector2 = Vector3.new(X2, v3, Z2)
			local v4 = vector2 + v2 * (position.Y - vector2.Y)
			folder.CFrame = alignCFrameWithPlane(rotation, v2) + v4
		else
			if typeof(folder) ~= "Instance" or not folder:IsA("Model") then
				warn("alignWithGround: Failed to align with ground for object of type " .. typeof(folder))
				return
			end

			local pivot = folder:GetPivot()
			local position = pivot.Position
			local rotation = pivot.Rotation
			local position2

			if raycastResult then
				position2 = raycastResult.Position
			else
				position2 = position
			end

			local unit = v2.Unit
			local X = unit.X
			local Y = unit.Y
			local Z = unit.Z
			local X2 = position.X
			local Z2 = position.Z
			local dot = position2:Dot(unit)
			local v3

			if math.abs(Y) < 0.1 then
				v3 = position.Y
			else
				v3 = (dot - X2 * X - Z2 * Z) / Y
			end

			local vector2 = Vector3.new(X2, v3, Z2)
			local v4 = vector2 + v2 * (position.Y - vector2.Y)
			folder:PivotTo(alignCFrameWithPlane(rotation, v2) + v4)
		end

		for _, emitter in ipairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.LockedToPart = true
			end
		end
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
	part.Parent = _WorldOrigin
	destroyAfter(part, 7)
	return part
end

local function playAnimationOnPlayer(p, p2, p3: string)
	if localPlayer ~= p2 then
		return nil
	end

	local v2 = Util.Anims:Get(p, p3)
	v2:Play()
	return v2
end

local m1s = FX:WaitForChild("YetiEffectsRed").M1s

local function emitAll(folder, p)
	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
			continue
		end

		if effect:IsA("Beam") then
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v2 = effect:GetAttribute("EmitDuration")
			local v3 = effect
			task.delay(tonumber(emitDelay) or 0, function()
				if tonumber(v2) and v2 ~= 0 then
					v3.Enabled = true

					if not v3:GetAttribute("pr3") then
						v3:SetAttribute("pr3", 0)
					end

					local v4 = (v3:GetAttribute("pr3") + 1) % 1000
					v3:SetAttribute("pr3", v4)
					task.wait(v2)

					if v4 == v3:GetAttribute("pr3") then
						v3.Enabled = false
					end
				end
			end)
		elseif not p or effect.Parent.Name ~= "Front" then
			local emitCount = effect:GetAttribute("EmitCount")
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v2 = effect
			local v4 = effect:GetAttribute("EmitDuration")
			task.delay(tonumber(emitDelay) or 0, function()
				v2:Emit(emitCount or 0)

				if tonumber(v4) and v4 ~= 0 then
					v2.Enabled = true

					if not v2:GetAttribute("pr3") then
						v2:SetAttribute("pr3", 0)
					end

					local v5 = (v2:GetAttribute("pr3") + 1) % 1000
					v2:SetAttribute("pr3", v5)
					task.wait(v4)

					if v5 == v2:GetAttribute("pr3") then
						v2.Enabled = false
					end
				end
			end)
		end
	end
end

local TweenService2 = game:GetService("TweenService")
return function(data)
	local player = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		warn("Missing hrp, effect code aborted")
		return
	end

	local parent = hrp.Parent
	local currentCamera = Workspace.CurrentCamera
	local cFrame = hrp.CFrame
	local Spikes = require(script.Parent.Parent.Modules.Spikes)
	local voidYetiSkin = hasVoidYetiSkin(player, hrp)
	print(voidYetiSkin)
	local _ = data.shootDir

	if (cFrame.Position - currentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	print("M1 4th combo: VFX as you go down goes in the below task.spawn do end scope")
	Util.Sound:Play("AkumaYeti_M1_Slam_Explosion_0" .. tostring(math.random(1, 2)), hrp)
	task.spawn(function()
		task.spawn(function()
			local clone = m1s.FALLBLUE2:Clone()
			clone.CFrame = hrp.CFrame
			Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "YetiFruitVFXColor")

			if voidYetiSkin then
				applyVoidSkyStreakOverride(clone)
			end

			Util.Debris:AddItem(clone, 3)
			TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				CFrame = hrp.CFrame * CFrame.new(0, -50, 0)
			}):Play()

			if parent == game.Players.LocalPlayer.Character then
				TweenService:Create(
					Workspace.Camera,
					TweenInfo.new(0.175, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						FieldOfView = 45
					}
				):Play()
			end

			emitAll(parent.YetiRig.YetiRig.Uppercut["Hand2.R"])
			task.spawn(function()
				for _ = 1, 4 do
					emitAll(clone)
					task.wait(0.045)
				end
			end)
		end)
	end)
	local timeUntilImpact = data.timeUntilImpact
	task.wait(timeUntilImpact)

	if parent == game.Players.LocalPlayer.Character then
		TweenService:Create(Workspace.Camera, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			FieldOfView = 70
		}):Play()
	end

	print("M1 4th combo: VFX Ground slam [this is missing spikes from main blox fruits place so dont add too much extra]")
	local v2 = _WorldOrigin
	task.spawn(function()
		local clone = m1s.HRPFX.Impact3:Clone()
		local clone2 = m1s.HRPFX.Roar:Clone()
		Util.SetParentOverrideWithColor(clone, hrp, player, "YetiFruitVFXColor")
		Util.SetParentOverrideWithColor(clone2, hrp, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone, 3)
		Util.Debris:AddItem(clone2, 3)
		emitAll(clone)
		emitAll(clone2)
		local part = Instance.new("Part")
		part.CanTouch = false
		part.CanQuery = false
		part.CanCollide = false
		part.Anchored = true
		part.Transparency = 1
		part.CFrame = hrp.CFrame
		part.Parent = _WorldOrigin
		Util.Debris:AddItem(part, 3)
		task.spawn(function()
			task.wait(0.3)

			for _ = 1, 19 do
				local clone3 = m1s.IceWind:Clone()
				clone3.CFrame = part.CFrame * CFrame.Angles(
					math.rad(math.random(-3600, 3600) / 10),
					math.rad(math.random(-3600, 3600) / 10),
					(math.rad(math.random(-3600, 3600) / 10))
				)
				clone3.Position = part.position
				clone3.Anchored = false
				Util.SetParentOverrideWithColor(clone3, v2, player, "YetiFruitVFXColor")
				local v3 = math.random(2, 10) / 5
				local v4 = math.random(20, 40) / 5

				if math.random(2) == 1 then
					v4 *= -1
				end

				for _, attachment in pairs(clone3:GetDescendants()) do
					if not attachment:IsA("Attachment") then
						continue
					end

					attachment.Position = Vector3.new(0, attachment.Name == "Top" and v3 or -v3, 0)
					attachment.Position += Vector3.new(0, v4, 0)
				end

				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
				bodyVelocity.Velocity = clone3.CFrame.LookVector * math.random(160, 340)
				bodyVelocity.Parent = clone3
				local v5 = math.random(22, 41) / 1.5
				clone3.RotVelocity = clone3.CFrame.LookVector * v5
				coroutine.resume(coroutine.create(function()
					task.wait(math.random(40, 70) / 100)
					clone3.Anchored = true
					Util.Debris:AddItem(clone3, 1.5)
				end))
			end
		end)
		local ray = Util.Ray
		local v3 = hrp.Position + createVector(0, 1, 0)
		local v4 = { Workspace.Characters, Workspace.Enemies, Workspace._WorldOrigin }
		local v5, v6, v7 = ray(v3, createVector(-0, -140, -0), v4)

		if v5 ~= nil then
			local clone3 = m1s.ImpactGround:Clone()
			clone3.CFrame = CFrame.new(v6)
			Util.SetParentOverrideWithColor(clone3, v2, player, "YetiFruitVFXColor")
			emitAll(clone3)
			task.delay(0.3, function()
				local v8 = CFrame.new(v6, v6 + v7) * CFrame.Angles(-1.5707963267948966, 0, 0)
				local random2 = Random.new()

				for i = 1, 45 do
					local v9 = 6.283185307179586 * (i / 45)
					local v10 = Rock2.new({
						Type = "Ground",
						FadeOut = { 0.25, 0.5 },
						FadeIn = { 0.25, 0.5 },
						Lifetime = { 1, 2.5 },
						Size = Vector3.new(random2:NextNumber(1, 2), random2:NextNumber(1, 2), random2:NextNumber(1, 2)),
						Scale = { 3.75, 7.5 }
					})

					if random2:NextInteger(1, 20) % 4 == 0 then
						local unit = Vector3.new(
							math.sin(random2:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2,
							random2:NextNumber(0, 1) * 1.25,
							math.cos(random2:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2
						).Unit
						v10.Type = "Flying"
						v10:Spawn(v8 * CFrame.Angles(0, v9, 0) * CFrame.new(0, 0, -34.199999999999996))
						v10:Eject({
							Velocity = Util.Misc.Physics.Velocity(
								Vector3.new(),
								unit * random2:NextNumber(30, 120),
								Vector3.new(0, -Workspace.Gravity * random2:NextNumber(0.25, 1), 0),
								0.25 + random2:NextNumber(0, 2)
							),
							AngularVelocity = Vector3.new(
								random2:NextNumber(-1, 1),
								random2:NextNumber(-1, 1),
								random2:NextNumber(-1, 1)
							) * 2 * 3.141592653589793 * (1 / v10.Scale)
						})
					else
						v10:Spawn(v8 * CFrame.Angles(0, v9, 0) * CFrame.new(0, 0, -34.199999999999996))
						v10:TweenShift((v8 * CFrame.Angles(0, v9, 0)).LookVector * 15 * random2:NextNumber(1, 2), 0.25)
					end
				end
			end)
			task.spawn(function()
				local v8 = v6
				local cframe = CFrame.new(v6)
				local clone4 = x_Tr.Impact2ndFloor:Clone()
				clone4.CFrame = cframe
				Util.SetParentOverrideWithColor(clone4, v2, player, "YetiFruitVFXColor")
				emitAll(clone4)
				Util.Debris:AddItem(clone4, 4.5)
				task.spawn(function()
					if (v8 - Workspace.CurrentCamera.CFrame.Position).Magnitude < 310 then
						task.wait(0.3)
						Util.CameraShaker:ShakeOnce(12, 8, 0.05, 1, createVector(1, 1, 1), createVector(1, 1, 1))
						local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
						colorCorrectionEffect.Parent = game.Lighting
						Util.Debris:AddItem(colorCorrectionEffect, 1.5)
						TweenService2:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.02, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(172, 99, 255),
									player,
									"YetiFruitVFXColor"
								),
								Brightness = -0.2,
								Saturation = 0.7
							}
						):Play()
						task.spawn(function()
							task.wait(0.02)
							TweenService2:Create(
								colorCorrectionEffect,
								TweenInfo.new(0.01, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									TintColor = Util.WrapColor3ConstructorForTintColor(
										Color3.fromRGB(178, 71, 255),
										player,
										"YetiFruitVFXColor"
									),
									Brightness = 0.9,
									Saturation = 0.7
								}
							):Play()
							task.wait(0.01)
							TweenService2:Create(
								colorCorrectionEffect,
								TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									TintColor = Util.WrapColor3ConstructorForTintColor(
										Color3.fromRGB(255, 255, 255),
										player,
										"YetiFruitVFXColor"
									),
									Brightness = 0,
									Saturation = 0
								}
							):Play()
						end)
						task.spawn(function()
							TweenService2:Create(
								Workspace.Camera,
								TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									FieldOfView = 75
								}
							):Play()
							task.wait(0.05)
							TweenService2:Create(
								Workspace.Camera,
								TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									FieldOfView = 70
								}
							):Play()
						end)
					end
				end)
			end)
			local cframe = CFrame.new(v6)
			local clone4 = m1s.CracksGround:Clone()
			clone4.CFrame = cframe
			Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "YetiFruitVFXColor")

			if voidYetiSkin then
				applyVoidSkyStreakOverride(clone4)
			end

			Util.Debris:AddItem(clone4, 8)
			Spikes.Ring(player, 7, 1, clone4, nil, 26, 20, 9, 2, "DefrostBear", _WorldOrigin)
			Spikes.Ring(player, 8, 2, clone4, nil, 14, 12, 9, 2, nil, _WorldOrigin)

			if (cframe.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 310 then
				Util.CameraShaker:ShakeOnce(10, 7, 0.1, 0.2)
			end

			task.delay(0.3, function()
				emitAll(clone4)
				Spikes.Ring(player, 8, 2, clone4, nil, 32, 24, 5, 2, nil, v2)
				Spikes.Ring(player, 8, 1, clone4, nil, 56, 32, 5, 2, nil, v2)
			end)
		end
	end)
	task.spawn(function()
		local function emitWithDelay(emitter)
			local emitDelay = emitter:GetAttribute("EmitDelay")

			if emitDelay then
				task.delay(emitDelay, function()
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end)
			else
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local function emitWithDelayDescendants(folder)
			for _, emitter in ipairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitWithDelay(emitter)
				end
			end
		end

		local function AkumaChargeup()
			local clone = script.Akuma:Clone()
			task.delay(4, function()
				if clone and clone.Parent then
					clone:Destroy()
				end
			end)
			Util.SetParentOverrideWithColor(clone, Workspace._WorldOrigin, player, "YetiFruitVFXColor")

			if voidYetiSkin then
				applyVoidSkyStreakOverride(clone, true) -- equivalent call inferred; original call site unknown
			end

			clone = clone.AkumaYeti
			heartbeatLoopFor2(4, function()
				clone.CFrame = CFrame.new(hrp.Position)
			end)
			clone.Light.PointLight.Range = clone.Parent:GetScale() * 2
			emitWithDelayDescendants(clone)
			task.spawn(function()
				local function hermite(vector2: Vector3, vector3: Vector3, vector4: Vector3, vector5: Vector3, p: number)
					local v3 = p * p
					local v4 = v3 * p
					local v5 = v4 * 2 - v3 * 3 + 1
					local v6 = v4 - v3 * 2 + p
					local v7 = v4 * -2 + v3 * 3
					local v8 = v4 - v3
					return v5 * vector2 + v6 * vector4 + v7 * vector3 + v8 * vector5
				end

				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function smooth(p: number)
					return p * p * (3 - p * 2)
				end

				local v3 = 240 * clone.Parent:GetScale()
				local v4 = 0.65 * v3
				local v5 = 1.35 * v3

				for i = 1, 30 do
					local clone2 = script.Akuma.AkumaYeti.Script.TrailPartChargeup:Clone()
					clone2.Trail.Enabled = true
					Util.SetParentOverrideWithColor(clone2, Workspace._WorldOrigin, player, "YetiFruitVFXColor")

					if voidYetiSkin then
						applyVoidSkyStreakOverride(clone2, true) -- equivalent call inferred; original call site unknown
					end

					task.delay(4 + random:NextNumber(-0.4, 0.8), function()
						if clone2 and clone2.Parent then
							clone2:Destroy()
						end
					end)
					local v7 = random:NextUnitVector() * v3
					local v8 = hrp.Position + v7
					local v9 = hrp.Position - v8
					local vector2 = v9 / math.max(v9.Magnitude, 0.001)
					local cross = vector2:Cross(random:NextUnitVector())
					local v10 = cross.Magnitude < 0.001 and createVector(0, 1, 0) or cross.Unit
					local v11 = (vector2 + v10 * random:NextNumber(-1.2, 1.2) + Vector3.new(
						0,
						random:NextNumber(-0.6, 1.4),
						0
					)).Unit * random:NextNumber(v4, v5)
					local v12 = (vector2 + v10 * random:NextNumber(-1, 1) + Vector3.new(
						0,
						random:NextNumber(-0.4, 1),
						0
					)).Unit * random:NextNumber(v4, v5)
					clone2.CFrame = CFrame.lookAt(v8, v8 + v11)
					local v16 = i
					local v17 = clone2
					local v18 = clone2
					heartbeatLoopFor2(0.3 + random:NextNumber(-0.08, 0.12), function(p, p2, p3)
						local v19 = smooth(p3)
						local position = hrp.Position
						local v23 = v19 * v19
						local v24 = v23 * v19
						local v25 = v24 * 2 - v23 * 3 + 1
						local v26 = v24 - v23 * 2 + v19
						local v27 = v24 * -2 + v23 * 3
						local v28 = v24 - v23
						local v29 = v25 * v8 + v26 * v11 + v27 * position + v28 * v12
						local v30 = math.sin(p2 * 0 + v16) * 0
						local cframe = CFrame.fromAxisAngle((v11 + v12).Unit, p2 * 0)
						local v31 = math.clamp(v19 + p, 0, 1)
						local v35 = v31 * v31
						local v36 = v35 * v31
						local v37 = v36 * 2 - v35 * 3 + 1
						local v38 = v36 - v35 * 2 + v31
						local v39 = v36 * -2 + v35 * 3
						local v40 = v36 - v35
						local v41 = v37 * v8 + v38 * v11 + v39 * position + v40 * v12 - v29

						if v41.Magnitude < 0.001 then
							v41 = v12
						end

						local unit = v41.Unit
						local cross2 = unit:Cross(createVector(0, 1, 0))
						local vector3 = cross2.Magnitude < 0.001 and createVector(1, 0, 0) or cross2.Unit
						local unit2 = vector3:Cross(unit).Unit
						local v42 = v29 + (vector3 * v30 + unit2 * (v30 * 0.4))
						v17.CFrame = cframe * CFrame.lookAt(v42, v42 + unit)
						v17.Trail.Transparency = NumberSequence.new(p3)
					end, function()
						v18.Trail.Transparency = NumberSequence.new(1)
					end)
				end
			end)
		end

		AkumaChargeup()
	end)
	task.wait(0.3)
	game:GetService("RunService")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function smoothstep01(value: number)
		local v3 = math.clamp(value, 0, 1)
		return v3 * v3 * (3 - v3 * 2)
	end

	local function slerpDir(unit: Vector3, vector2: Vector3, p: number)
		local unit2 = unit.Unit
		local unit3 = vector2.Unit
		local dot = unit2:Dot(unit3)

		if dot > 0.9995 then
			return (unit2 + p * (unit3 - unit2)).Unit
		end

		local v3 = math.clamp(dot, -1, 1)

		if v3 < -0.9995 then
			local rightVector = CFrame.lookAlong(createVector(0, 0, 0), unit2).RightVector
			local v4 = 3.141592653589793 * p
			return (unit2 * math.cos(v4) + rightVector * math.sin(v4)).Unit
		else
			local v4 = math.acos(v3)
			local v5 = v4 * p
			local v6 = math.sin(v5)
			local v7 = math.sin(v4)
			local v8 = math.cos(v5) - v3 * v6 / v7
			local v9 = v6 / v7
			return (unit2 * v8 + unit3 * v9).Unit
		end
	end

	local function getBeamTemplates(beamTemplatesFolder)
		local beams = {}

		for _, beam in ipairs(beamTemplatesFolder:GetChildren()) do
			if beam:IsA("Beam") then
				table.insert(beams, beam)
			end
		end

		return beams
	end

	local function chooseTemplate(data2)
		if data2.templateInstance then
			return data2.templateInstance
		end

		local beamTemplates = getBeamTemplates(data2.beamTemplatesFolder)
		assert(#beamTemplates > 0, "BeamTemplates folder must contain at least one Beam.")

		if data2.templateName then
			for _, beamTemplate in ipairs(beamTemplates) do
				if beamTemplate.Name == data2.templateName then
					return beamTemplate
				end
			end

			error(("No Beam template named '%s' found in BeamTemplates."):format(data2.templateName))
		end

		return beamTemplates[(data2.random or Random.new()):NextInteger(1, #beamTemplates)]
	end

	local function makeId(object)
		return ("%06d"):format(object:NextInteger(0, 999999))
	end

	local v3 = {
		spawnSpiral = function(data2)
			assert(data2 and data2.originPart, "spawnSpiral requires params.originPart")
			assert(data2.beamSpline, "spawnSpiral requires params.beamSpline")
			assert(data2.beamTemplatesFolder, "spawnSpiral requires params.beamTemplatesFolder")
			local originPart = data2.originPart
			local beamSpline = data2.beamSpline
			local turns = data2.turns or 2
			local height = data2.height or 80
			local axisOffsetLocal = data2.axisOffsetLocal or createVector(0, 0, 0)
			local phaseOffsetRadians = data2.phaseOffsetRadians or 0
			local v4 = data2.spin == nil and 1 or data2.spin >= 0 and 1 or -1
			local radius = data2.radius or 14
			local beamsPerSpiral = data2.beamsPerSpiral or 4
			local samplesPerBeam = data2.samplesPerBeam or 10
			local growTime = data2.growTime or 0.5
			local v5 = math.clamp(data2.torsionBlend or 0.5, 0, 1)
			local random2 = data2.random or Random.new()
			local v6 = chooseTemplate(data2)
			local parentFolder = data2.parentFolder or originPart
			local folderName = data2.folderName or "SpiralVFX_" .. ("%06d"):format(random2:NextInteger(0, 999999))
			local folder = Instance.new("Folder")
			folder.Name = folderName
			folder.Parent = parentFolder
			local clones = table.create(beamsPerSpiral)
			local v7 = table.create(beamsPerSpiral)
			local v8 = table.create(beamsPerSpiral)

			for i = 1, beamsPerSpiral do
				local clone = v6:Clone()
				clone.Name = ("SpiralBeam_%02d"):format(i)
				Util.SetParentOverrideWithColor(clone, folder, player, "YetiFruitVFXColor")

				if voidYetiSkin then
					applyVoidSkyStreakColor(clone)
				end

				clone.Enabled = true
				local attachment = Instance.new("Attachment")
				attachment.Name = ("Spiral_Att0_%02d"):format(i)
				attachment.Parent = originPart
				local attachment2 = Instance.new("Attachment")
				attachment2.Name = ("Spiral_Att1_%02d"):format(i)
				attachment2.Parent = originPart
				clone.Attachment0 = attachment
				clone.Attachment1 = attachment2
				clones[i] = clone
				v7[i] = attachment
				v8[i] = attachment2
			end

			if beamSpline.forceDisableRobloxBeamLOD then
				beamSpline.forceDisableRobloxBeamLOD(clones)
			end

			local widthOverride = data2.widthOverride

			local function beamWidthFunction(p: number)
				if widthOverride then
					return widthOverride(p)
				end

				return 16
			end

			local v9 = data2.spinWithTime == nil or data2.spinWithTime
			local spinTimeScale = data2.spinTimeScale or 1
			local v10 = 0
			local radiusScaleEnd = data2.radiusScaleEnd or 1
			local v11 = 1
			local flag = false
			local now = 0
			local v12 = growTime <= 0 and 0.0001 or growTime

			local function spiralLocalPosition(p: number)
				local v13 = p ^ 0.5
				local v14 = v13 * turns * 6.283185307179586 * v4 + phaseOffsetRadians + v10
				local v15 = radius * v11 * v13 ^ 0.3
				local v16 = v15 * math.cos(v14)
				local v17 = v15 * math.sin(v14)
				return Vector3.new(v16, v13 * height, v17) + axisOffsetLocal
			end

			local function spiralLocalHelixTangentUnit(p: number)
				local v13 = p * turns * 6.283185307179586 * v4 + phaseOffsetRadians + v10
				local v14 = turns * 6.283185307179586 * v4
				local v15 = radius * v11
				local v16 = -v15 * math.sin(v13) * v14
				local v17 = v15 * math.cos(v13) * v14
				return Vector3.new(v16, height, v17).Unit
			end

			local v13 = 0.5 / beamsPerSpiral

			local function renderSpiral(p: number)
				if v9 then
					v10 = time() * spinTimeScale
				else
					v10 = 0
				end

				if flag then
					local v14 = math.clamp((os.clock() - now) / v12, 0, 1)
					v11 = 1 + (radiusScaleEnd - 1) * smoothstep01(v14)
				else
					v11 = 1
				end

				local v14 = math.clamp(math.ceil(p * beamsPerSpiral), 1, beamsPerSpiral)
				local cFrame2 = originPart.CFrame
				local v15 = p ^ 0.5
				local v16 = v15 * turns * 6.283185307179586 * v4 + phaseOffsetRadians + v10
				local v17 = radius * v11 * v15 ^ 0.3
				local v18 = v17 * math.cos(v16)
				local v19 = v17 * math.sin(v16)
				local pointToWorldSpace = cFrame2:PointToWorldSpace(Vector3.new(v18, v15 * height, v19) + axisOffsetLocal)

				for i = v14 + 1, beamsPerSpiral do
					local v20 = clones[i]
					v20.Width0 = 0
					v20.Width1 = 0
					v7[i].WorldPosition = pointToWorldSpace
					v8[i].WorldPosition = pointToWorldSpace
				end

				local v20 = table.create(v14)

				for i = 1, v14 do
					v20[i] = clones[i]
				end

				local function unitIntervalSpaceCurve(p2: number)
					local v21 = p2 * p
					local cFrame3 = originPart.CFrame
					local v22 = v21 ^ 0.5
					local v23 = v22 * turns * 6.283185307179586 * v4 + phaseOffsetRadians + v10
					local v24 = radius * v11 * v22 ^ 0.3
					local v25 = v24 * math.cos(v23)
					local v26 = v24 * math.sin(v23)
					return cFrame3:PointToWorldSpace(Vector3.new(v25, v22 * height, v26) + axisOffsetLocal)
				end

				local function beamTorsionCurve(p2: number)
					local v21 = p2 * 0.9 * turns * 6.283185307179586 * v4 + phaseOffsetRadians + v10
					local v22 = turns * 6.283185307179586 * v4
					local v23 = radius * v11
					local v24 = -v23 * math.sin(v21) * v22
					local v25 = v23 * math.cos(v21) * v22
					local v26 = slerpDir(Vector3.new(v24, height, v25).Unit, createVector(0, 1, 0), v5)
					return originPart.CFrame:VectorToWorldSpace(v26)
				end

				beamSpline.draw(unitIntervalSpaceCurve, beamWidthFunction, beamTorsionCurve, v20, samplesPerBeam)
				beamSpline.applyTransparencySequence(NumberSequence.new(p ^ 12), clones)
			end

			if beamSpline.applyTransparencySequence then
				beamSpline.applyTransparencySequence(NumberSequence.new(0), clones)
			end

			task.spawn(function()
				renderSpiral(v13)
				task.wait()
				renderSpiral(v13)
				now = os.clock()
				flag = true
				local v14 = now

				while true do
					local v15 = (os.clock() - v14) / growTime

					if v15 >= 1 then
						break
					end

					local v16 = smoothstep01(v15) -- equivalent call inferred; original call site unknown
					renderSpiral(v13 + (1 - v13) * v16)
					task.wait()
				end

				renderSpiral(1)

				if data2.autoDestroyDelay ~= nil then
					task.delay(data2.autoDestroyDelay, function()
						if folder.Parent then
							folder:Destroy()
						end

						for i = 1, beamsPerSpiral do
							if v7[i].Parent then
								v7[i]:Destroy()
							end

							if v8[i].Parent then
								v8[i]:Destroy()
							end
						end
					end)
				end
			end)
			return folder
		end
	}

	function v3.spawnAkumaBurst(data2)
		local random2 = data2.random or Random.new()
		local count = data2.count or 4
		local doubles = data2.doubles or 2
		local duration = data2.duration or 0.5
		local radiusMin = data2.radiusMin or 8
		local radiusMax = data2.radiusMax or 22
		local heightMin = data2.heightMin or 45
		local heightMax = data2.heightMax or 90
		local turnsMin = data2.turnsMin or 1.5
		local turnsMax = data2.turnsMax or 2.6
		local phaseJitterRadians = data2.phaseJitterRadians or 0
		local v4 = data2.phaseRandomFull == nil or data2.phaseRandomFull
		local v5 = data2.spinRandom == nil or data2.spinRandom
		local spinWithTime = data2.spinWithTime == nil or data2.spinWithTime
		local spinTimeScaleMin = data2.spinTimeScaleMin or 1
		local spinTimeScaleMax = data2.spinTimeScaleMax or 1
		local fadeOutTime = data2.fadeOutTime
		local fadeOutTime2 = fadeOutTime == nil and 0.2 or fadeOutTime
		local radiusScaleEndMin = data2.radiusScaleEndMin or 1
		local radiusScaleEndMax = data2.radiusScaleEndMax or 1
		local beamTemplates = getBeamTemplates(data2.beamTemplatesFolder)
		assert(#beamTemplates > 0, "BeamTemplates must contain at least one Beam.")

		local function pickTemplateExcept(template)
			if #beamTemplates == 1 then
				return beamTemplates[1]
			end

			local v8

			repeat
				v8 = beamTemplates[random2:NextInteger(1, #beamTemplates)]
			until v8 ~= template

			return v8
		end

		local v8 = table.create(count)

		for i = 1, count do
			local number = random2:NextNumber(radiusMin, radiusMax)
			local number2 = random2:NextNumber(heightMin, heightMax)
			local number3 = random2:NextNumber(turnsMin, turnsMax)
			local v9 = (not v4 and 0 or random2:NextNumber(0, 6.283185307179586)) + random2:NextNumber(
				-phaseJitterRadians,
				phaseJitterRadians
			)
			local spin = not v5 and 1 or random2:NextInteger(0, 1) == 0 and 1 or -1
			local number4 = random2:NextNumber(spinTimeScaleMin, spinTimeScaleMax)
			local number5 = random2:NextNumber(radiusScaleEndMin, radiusScaleEndMax)
			local beamTemplate = beamTemplates[random2:NextInteger(1, #beamTemplates)]
			v8[i] = {
				radius = number,
				height = number2,
				turns = number3,
				phase = v9,
				spin = spin,
				template = beamTemplate,
				spinWithTime = spinWithTime,
				spinTimeScale = number4,
				radiusScaleEnd = number5
			}
			v3.spawnSpiral({
				originPart = data2.originPart,
				beamSpline = data2.beamSpline,
				beamTemplatesFolder = data2.beamTemplatesFolder,
				templateInstance = beamTemplate,
				radius = number,
				radiusScaleEnd = number5,
				height = number2,
				turns = number3,
				spin = spin,
				phaseOffsetRadians = v9,
				spinWithTime = spinWithTime,
				spinTimeScale = number4,
				growTime = duration * random2:NextNumber(0.85, 1.1),
				fadeOutTime = fadeOutTime2,
				beamsPerSpiral = data2.beamsPerSpiral or 4,
				samplesPerBeam = data2.samplesPerBeam or 10,
				baseWidth = data2.baseWidth or 0.25,
				widthTaperFraction = data2.widthTaperFraction or 0.3,
				torsionBlend = data2.torsionBlend or 0.5,
				parentFolder = data2.parentFolder,
				autoDestroyDelay = data2.autoDestroyDelay,
				random = random2
			})
		end

		for _ = 1, doubles do
			local v9 = v8[random2:NextInteger(1, #v8)]
			local templateInstance = pickTemplateExcept(v9.template)
			v3.spawnSpiral({
				originPart = data2.originPart,
				beamSpline = data2.beamSpline,
				beamTemplatesFolder = data2.beamTemplatesFolder,
				templateInstance = templateInstance,
				radius = v9.radius,
				radiusScaleEnd = v9.radiusScaleEnd,
				height = v9.height,
				turns = v9.turns,
				spin = v9.spin,
				phaseOffsetRadians = v9.phase,
				spinWithTime = v9.spinWithTime,
				spinTimeScale = v9.spinTimeScale,
				growTime = duration * random2:NextNumber(0.85, 1.1),
				fadeOutTime = fadeOutTime2,
				beamsPerSpiral = data2.beamsPerSpiral or 4,
				samplesPerBeam = data2.samplesPerBeam or 10,
				baseWidth = data2.baseWidth or 0.25,
				widthTaperFraction = data2.widthTaperFraction or 0.3,
				torsionBlend = data2.torsionBlend or 0.5,
				parentFolder = data2.parentFolder,
				autoDestroyDelay = data2.autoDestroyDelay,
				random = random2
			})
		end
	end

	local BeamSpline = require(script:WaitForChild("BeamSpline"))
	local beamTemplates = script:WaitForChild("BeamTemplates")
	local clone = script:WaitForChild("SpiralBeams2"):Clone()
	clone:PivotTo(CFrame.new(data.impactPos))
	Util.SetParentOverrideWithColor(clone, Workspace._WorldOrigin, player, "YetiFruitVFXColor")

	if voidYetiSkin then
		applyVoidSkyStreakOverride(clone)
	end

	task.delay(4, function()
		if clone and clone.Parent then
			clone:Destroy()
		end
	end)
	local spiralBeams = clone.SpiralBeams
	task.spawn(function()
		v3.spawnAkumaBurst({
			originPart = spiralBeams,
			beamSpline = BeamSpline,
			beamTemplatesFolder = beamTemplates,
			count = 7,
			doubles = 14,
			duration = 0.5,
			radiusMin = 14,
			radiusMax = 16.799999999999997,
			heightMin = 160,
			heightMax = 200,
			turnsMin = 0.5,
			turnsMax = 0.7,
			phaseRandomFull = true,
			phaseJitterRadians = 0,
			spinRandom = true,
			spinWithTime = true,
			spinTimeScaleMin = 2,
			spinTimeScaleMax = 2,
			radiusScaleEndMin = 4,
			radiusScaleEndMax = 4,
			autoDestroyDelay = 0.1,
			beamsPerSpiral = 7,
			samplesPerBeam = 20
		})
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function PlayFlipbook(part)
		task.spawn(function()
			if not part then
				return
			end

			local folder = part:FindFirstChildOfClass("Folder")
			local decal = part:FindFirstChildOfClass("Decal")

			if not (folder and decal) then
				return
			end

			local texturesByName = {}
			local v4 = 0

			for _, decal2 in ipairs(folder:GetChildren()) do
				if not decal2:IsA("Decal") then
					continue
				end

				local name = tonumber(decal2.Name)

				if not name then
					continue
				end

				texturesByName[name] = decal2.Texture

				if v4 < name then
					v4 = name
				end
			end

			if v4 == 0 then
				return
			end

			part:SetAttribute("PlayFlipbook", true)
			local v5 = 1

			while part and part.Parent and part:GetAttribute("PlayFlipbook") == true do
				task.wait(0.016666666666666666)
				local texture = texturesByName[v5]

				if texture then
					decal.Texture = texture
				end

				v5 = v5 % v4 + 1
			end
		end)
	end

	local TweenService3 = game:GetService("TweenService")
	local children = {}

	for _, child in ipairs(spiralBeams.Parent:GetChildren()) do
		if child.Name ~= "Paraboloid" then
			continue
		end

		table.insert(children, child)
		local part = child:FindFirstChild("Part")

		if not part then
			continue
		end

		local specialMesh = part:FindFirstChildOfClass("SpecialMesh")

		if specialMesh then
			if specialMesh:GetAttribute("DefaultScale") == nil then
				specialMesh:SetAttribute("DefaultScale", specialMesh.Scale)
			end

			specialMesh.Scale = specialMesh:GetAttribute("DefaultScale")
		end

		child.Part.Decal.Transparency = -5
		PlayFlipbook(child.Part) -- equivalent call inferred; original call site unknown
	end

	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for _, v4 in ipairs(children) do
		local part = v4:FindFirstChild("Part")

		if not part then
			continue
		end

		local specialMesh = part:FindFirstChildOfClass("SpecialMesh")
		local defaultScale = specialMesh:GetAttribute("DefaultScale")

		if not (specialMesh and defaultScale) then
			continue
		end

		specialMesh.Scale = defaultScale * 0.4
		TweenService3:Create(specialMesh, tweenInfo, {
			Scale = defaultScale * 1.4
		}):Play()
	end

	for _, child in ipairs(spiralBeams.Parent.Particles.Attachment:GetChildren()) do
		child.Enabled = true
	end

	task.wait(0.4)
	task.spawn(function()
		local v4 = time()

		while time() - v4 < 0.1 do
			task.wait()
			local v5 = math.clamp((time() - v4) / 0.1, 0, 1)

			for _, v6 in ipairs(children) do
				v6.Part.Decal.Transparency = v5 ^ 4
			end
		end

		for _, v5 in ipairs(children) do
			v5.Part:SetAttribute("PlayFlipbook", false)
		end
	end)

	for _, child in ipairs(spiralBeams.Parent.Particles.Attachment:GetChildren()) do
		child.Enabled = false
	end
end