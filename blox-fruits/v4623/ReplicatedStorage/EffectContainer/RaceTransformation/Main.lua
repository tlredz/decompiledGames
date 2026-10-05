local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local VignetteService = require(game.ReplicatedStorage.Util.VignetteService)
local currentCamera = workspace.CurrentCamera
local Main = require(game.ReplicatedStorage.Util.CameraShaker.Main)
local CameraShaker = require(game.ReplicatedStorage.Util.CameraShaker)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local TweenService2 = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local raceTransformation = FX:WaitForChild("RaceTransformation")
local debris = Util.Debris
local ray = Util.Ray
local _ = Util.Tween
local misc = Util.Misc

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }
local v = {
	TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
}

local function createEffect(cFrame, instance, p, p2, player, race)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame

	if race ~= "Draco" then
		clone.Parent = p2 or _WorldOrigin
		return clone
	end

	Util.SetParentOverrideWithColor(clone, p2 or _WorldOrigin, player, "DracoRaceVFXColors", true)
	Util.SyncColorsOnChange(clone, player, "DracoRaceVFXColors", true)
	return clone
end

local function LumFromRGB(data)
	local v2 = 0.2126 * data.R + 0.7152 * data.G + 0.0722 * data.B

	if v2 > 0.4 then
		return v2
	end

	return 0
end

local Pool = require(ReplicatedStorage:WaitForChild("Pool"))
local _ = createVector(-0, -1, -0) * workspace.Gravity
local part = Instance.new("Part")
part.TopSurface = 0
part.BottomSurface = 0
part.Anchored = true
part.CanCollide = true
part.Size = createVector(1, 1, 1)
part.CFrame = CFrame.identity
local CustomCollisions = require(game.ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local v2 = Pool.new(string.format("Race/%s/%s", script.Parent.Name, "Rocks"))
v2:setAction(function(object, p)
	local now = tick()
	local parts = {}
	local v3 = {}

	for _, v4 in pairs(object.Pool) do
		local origin = v4.Origin
		local rotation = v4.Rotation
		local size = v4.Size
		local part2 = v4.Part
		local dust = v4.Dust
		local rotationAxis = v4.RotationAxis
		local drag = v4.Drag
		local velocity = v4.Velocity
		local acceleration = v4.Acceleration
		local lifetime = v4.Lifetime
		local v5 = now - v4.Start
		local v6 = math.clamp(v5 / (lifetime / 2), 0, 1)
		local v7 = (1 - math.clamp((v5 - lifetime / 2) / (lifetime / 2), 0, 1)) * 1.5 * acceleration
		local position = misc.CalculatePosition(velocity, v7, drag, v5)
		v4.RotationOffset *= CFrame.Angles(rotationAxis.X * p * v6, rotationAxis.Y * p * v6, rotationAxis.Z * p * v6)
		table.insert(parts, part2)
		table.insert(v3, CFrame.new(origin + position) * rotation * v4.RotationOffset)

		if lifetime <= v5 or v4.ForceFinish then
			part2.RotVelocity = rotationAxis
			part2.Anchored = false
			dust.Enabled = false
			TweenService2:Create(part2, TweenInfo.new(lifetime / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Size = size * 0
			}):Play()
			object:remove(v4)
		elseif lifetime / 2 <= v5 then
			part2.CanCollide = true
		end
	end

	workspace:BulkMoveTo(parts, v3)
end)

local function createRock(data)
	local random = Random.new()
	local reference = data.Reference
	local hit = data.Hit
	local magnitude = (data.Scale or createVector(1, 2, 1)).Magnitude

	if not (hit and reference) or (currentCamera.CFrame.p - reference.CFrame.p).Magnitude > 275 + reference.Size.Magnitude * 2 then
		return
	end

	local dustCenter = reference.DustCenter
	local rocks2 = dustCenter.Rocks
	local dust = reference.DustAttachment.Dust
	local number = random:NextNumber(rocks2.Lifetime.Min, rocks2.Lifetime.Max)
	local spreadAngle = rocks2.SpreadAngle
	local spreadAngleFromCFrame, v3 = misc.SpreadAngleFromCFrame(reference.CFrame, spreadAngle)
	local rotation = spreadAngleFromCFrame - spreadAngleFromCFrame.p
	local velocity = v3 * random:NextNumber(rocks2.Speed.Min, rocks2.Speed.Max)
	local acceleration = rocks2.Acceleration
	local drag = rocks2.Drag
	local origin = reference.CFrame * dustCenter.Position
	local rotationAxis = random:NextNumber(0.7853981633974483, 6.283185307179586) * Vector3.new(
		random:NextNumber(-1, 1) * 3.141592653589793,
		random:NextNumber(-1, 1) * 3.141592653589793,
		random:NextNumber(-1, 1) * 3.141592653589793
	)
	local identity = CFrame.identity
	local clone = part:Clone()
	local size = Vector3.new(random:NextNumber(0.5, 1.5), random:NextNumber(0.125, 0.75), random:NextNumber(0.5, 1.5)) * (magnitude / 4)
	clone.CanCollide = false
	clone.Color = hit.Color
	clone.Material = hit.Material
	clone.Size = size * 0
	clone.CFrame = dustCenter.CFrame * CFrame.new(dustCenter.Position)
	local clone2 = dust:Clone()
	clone2.LockedToPart = false
	clone2.EmissionDirection = Enum.NormalId.Bottom
	clone2.Rate /= 2
	misc.ScaleParticle(clone2, size.Magnitude * 1 / 4)
	clone2.Lifetime = NumberRange.new(clone2.Lifetime.Min, clone2.Lifetime.Max)
	clone2.Enabled = true
	clone2.Parent = clone
	rocks:ApplyCollision(clone, nil, true)
	clone.Parent = _WorldOrigin
	debris:AddItem(clone, number * 2)
	TweenService2:Create(clone, TweenInfo.new(number / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = size
	}):Play()

	if size.Magnitude > 1.3 then
		Util.Sound:Play("Earthquake", clone, nil, random:NextNumber(0.25, 1.5), 0.03)
	end

	v2:add({
		Origin = origin,
		Rotation = rotation,
		Size = size,
		Part = clone,
		Dust = clone2,
		RotationAxis = rotationAxis,
		Drag = drag,
		Velocity = velocity,
		Acceleration = acceleration,
		Lifetime = number,
		RotationOffset = identity,
		Start = tick()
	})
end

local v3 = {
	Ghoul = "RaceAura1",
	Cyborg = "RaceAura4",
	Human = "RaceAura5",
	Skypiea = "RaceAura3",
	Mink = "RaceAura2",
	Fishman = "RaceAura6",
	Draco = "RaceAura7"
}
return function(player)
	local character = player.Character
	local _ = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart
	local v4 = character == game.Players.LocalPlayer.Character
	local player2 = player.player

	if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 700 then
		return
	end

	if v4 then
		local duration = player.Mastery and 1.666 or 3
		local BodyMover = require(game.ReplicatedStorage.Util.BodyMover)
		BodyMover.new(character):Create("BodyPosition", {
			Priority = 1e999,
			Position = humanoidRootPart.Position,
			Duration = duration
		})
		local BodyMover2 = require(game.ReplicatedStorage.Util.BodyMover)
		BodyMover2.new(character):Create("BodyGyro", {
			Priority = 1e999,
			CFrame = humanoidRootPart.CFrame,
			Duration = duration
		})
	end

	local v5

	if not player.Mastery then
		v5 = Sound:Play("AwakeningStart", humanoidRootPart)
	end

	task.wait(0.1)
	player.CFrame = humanoidRootPart.CFrame
	task.spawn(function()
		local lastTime = tick()

		while tick() - lastTime < 4 do
			player.CFrame = humanoidRootPart.CFrame
			wait()
		end
	end)
	local color1 = player.Color1 or Color3.new(1, 0.0431373, 0.0588235)
	local color2 = player.Color2 or Color3.new(0.419608, 0.0156863, 0.0235294)
	local color3 = player.Color3 or Color3.new(1, 0.368627, 0.380392)
	local root = nil

	if not player.Mastery then
		root = createEffect(
			humanoidRootPart.CFrame * CFrame.new(0, -2, 0),
			raceTransformation.Effects.Platform,
			nil,
			nil,
			player2,
			player.Race
		)
		local effect = createEffect(
			humanoidRootPart.CFrame,
			raceTransformation.Effects.PlayerPlatform,
			nil,
			nil,
			player2,
			player.Race
		)
		debris:AddItem(root, 4.5)
		debris:AddItem(effect, 4.5)

		for _, child in pairs(root.Attachment:GetChildren()) do
			child.Color = misc.SwapColorInKeypoints(child.Color.Keypoints, Color3.new(1, 0, 0), color1)
			local v7 = child

			local function fn()
				if v7:GetAttribute("Emit") or v7:GetAttribute("EmitCount") then
					v7:Emit(v7:GetAttribute("Emit") or v7:GetAttribute("EmitCount"))
				end

				if v7:GetAttribute("Enable") then
					v7.Enabled = true
				end
			end

			if child:GetAttribute("EmitDelay") then
				task.delay(child:GetAttribute("EmitDelay"), fn)
			else
				fn()
			end
		end

		for _, child in pairs(effect.Attachment:GetChildren()) do
			child.Color = misc.SwapColorInKeypoints(child.Color.Keypoints, Color3.new(1, 0, 0), color2)
			-- equivalent calls inferred from this helper; original call sites unknown
			local v7 = child

			local function fn()
				if v7:GetAttribute("Enable") then
					v7.Enabled = true
				end
			end

			if child:GetAttribute("EmitDelay") then
				task.delay(child:GetAttribute("EmitDelay"), fn)
			else
				fn() -- equivalent call inferred; original call site unknown
			end
		end

		local v7 = false

		if v4 then
			CameraShaker:ShakeSustain(Main.Presets.Bump4)
			task.spawn(function()
				while not v7 do
					workspace.CurrentCamera.FieldOfView = Lerp(workspace.CurrentCamera.FieldOfView, 60, 0.05)
					task.wait()
				end
			end)
		end

		local v8 = false
		task.spawn(function()
			local random = Random.new()
			local now = tick()
			local v9 = 0

			while true do
				local lastTime = tick()
				local v10 = lastTime - now

				if lastTime - v9 >= 0.016666666666666666 then
					Effect.new("RaceTransformation.Trail"):replicate({
						Root = root,
						Offset = CFrame.Angles(
							random:NextNumber(-3.141592653589793, 3.141592653589793) * random:NextNumber(0, 1),
							0,
							random:NextNumber(-3.141592653589793, 3.141592653589793) * random:NextNumber(0, 1)
						),
						Color = random:NextInteger(1, 2) == 1 and color1 or color2,
						Radius = { random:NextNumber(4, 6), random:NextNumber(6, 12) },
						Height = { random:NextNumber(-2, 4), random:NextNumber(5, 6) },
						FadeIn = 0.15,
						FadeOut = 0.15,
						player = player2,
						race = player.Race
					})
					v9 = lastTime
				end

				if v10 >= 5 or v8 then
					break
				end

				task.wait(0.016666666666666666)
				local _ = tick() - lastTime
			end
		end)
		task.wait(0.5)

		for _, child in pairs(root.Attachment:GetChildren()) do
			child.Enabled = false
		end

		task.wait(0.15)

		for _, child in pairs(effect.Attachment:GetChildren()) do
			child.Enabled = false
			local min = child.Lifetime.Min
			local max = child.Lifetime.Max
			child.ZOffset += 1.5
			child.Lifetime = NumberRange.new(min * 0.95, max * 0.95)
			local v9 = child

			local function fn()
				if v9:GetAttribute("Emit") or v9:GetAttribute("EmitCount") then
					v9:Emit(v9:GetAttribute("Emit") or v9:GetAttribute("EmitCount"))
				end

				if v9:GetAttribute("Enable") then
					v9.Enabled = true
				end
			end

			if child:GetAttribute("EmitDelay") then
				task.delay(child:GetAttribute("EmitDelay") * 0.95, fn)
			else
				fn()
			end
		end

		v8 = true
		Sound:FadeOut(v5, 0.3)
		task.wait(0.15)

		for _, child in pairs(effect.Attachment:GetChildren()) do
			child.Enabled = false
		end

		task.wait(0.1)
		v7 = true
	end

	Sound:Play("AwakeningExplosion", player.CFrame)

	if v4 then
		local clone = raceTransformation.Main.ScreenSmoke:Clone()
		clone.Color = ColorSequence.new(color2)
		local vignette = VignetteService:CreateVignette({ clone })
		vignette:UpdateEnabled(true)
		vignette:Enabled(true)
		CameraShaker:ShakeSustain(Main.Presets.Bump2)
		task.delay(1.5, function()
			vignette:UpdateEnabled(false)
			vignette:Enabled(false)
			task.wait(1)
			vignette:Destroy()
		end)
		task.spawn(function()
			local lastTime = tick()

			while tick() - lastTime < 1.4 do
				workspace.CurrentCamera.FieldOfView = Lerp(workspace.CurrentCamera.FieldOfView, 100, 0.15)
				task.wait()
			end

			local fieldOfView = workspace.CurrentCamera.FieldOfView
			local lastTime2 = tick()

			while tick() - lastTime2 < 0.5 do
				workspace.CurrentCamera.FieldOfView = Lerp(fieldOfView, 70, (tick() - lastTime2) / 0.5)
				task.wait()
			end

			workspace.CurrentCamera.FieldOfView = 70
		end)
	end

	if v4 or (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude < 70 then
		local clone = raceTransformation.Main.Blur:Clone()
		clone.Parent = game.Lighting
		debris:AddItem(clone, 2.5)
		Effect.new("ShakeCam"):replicate({
			5,
			10,
			0,
			1.5,
			createVector(0.25, 0.25, 0.25),
			createVector(4, 1, 1)
		})
		task.delay(1.5, function()
			TweenService:Create(clone, v[1], {
				Size = 0
			}):Play()
		end)
		task.delay(0.1, function()
			local clone2 = raceTransformation.Main["CC" .. 1]:Clone()
			debris:AddItem(clone2, 0.3)
			clone2.TintColor = color3
			clone2.Parent = game.Lighting
			TweenService:Create(clone2, v[2], {
				Saturation = 0,
				Brightness = 0,
				Contrast = 0
			}):Play()
		end)
	end

	local effect = createEffect(
		humanoidRootPart.CFrame * CFrame.new(0, -2, 0),
		raceTransformation.Effects.Platform2,
		nil,
		nil,
		player2,
		player.Race
	)
	local effect2 = createEffect(
		humanoidRootPart.CFrame,
		raceTransformation.Effects.PlayerPlatform2,
		nil,
		nil,
		player2,
		player.Race
	)
	debris:AddItem(effect, 4.5)
	debris:AddItem(effect2, 4.5)

	for _, child in pairs(effect.Attachment:GetChildren()) do
		child.Color = misc.SwapColorInKeypoints(child.Color.Keypoints, Color3.new(1, 0, 0), color1)
		local v7 = child

		local function fn()
			if v7:GetAttribute("Emit") or v7:GetAttribute("EmitCount") then
				v7:Emit(v7:GetAttribute("Emit") or v7:GetAttribute("EmitCount"))
			end

			v7.Enabled = true
		end

		if child:GetAttribute("EmitDelay") then
			task.delay(child:GetAttribute("EmitDelay"), fn)
		else
			fn()
		end
	end

	for _, emitter in pairs(effect:GetChildren()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Color = misc.SwapColorInKeypoints(emitter.Color.Keypoints, Color3.new(1, 0, 0), color2)
		local v7 = emitter

		local function fn()
			if v7:GetAttribute("Emit") or v7:GetAttribute("EmitCount") then
				v7:Emit(v7:GetAttribute("Emit") or v7:GetAttribute("EmitCount"))
			end

			v7.Enabled = true
		end

		if emitter:GetAttribute("EmitDelay") then
			task.delay(emitter:GetAttribute("EmitDelay"), fn)
		else
			fn()
		end
	end

	for _, child in pairs(effect.Attachment2:GetChildren()) do
		child.Color = misc.SwapColorInKeypoints(child.Color.Keypoints, Color3.new(1, 0, 0), color1)
		local v7 = child

		local function fn()
			if v7:GetAttribute("Emit") or v7:GetAttribute("EmitCount") then
				v7:Emit(v7:GetAttribute("Emit") or v7:GetAttribute("EmitCount"))
			end

			v7.Enabled = true
		end

		if child:GetAttribute("EmitDelay") then
			task.delay(child:GetAttribute("EmitDelay"), fn)
		else
			fn()
		end
	end

	for _, child in pairs(effect2.Attachment:GetChildren()) do
		child.Color = misc.SwapColorInKeypoints(child.Color.Keypoints, Color3.new(1, 0, 0), color2)
		local v7 = child

		local function fn()
			if v7:GetAttribute("Emit") or v7:GetAttribute("EmitCount") then
				v7:Emit(v7:GetAttribute("Emit") or v7:GetAttribute("EmitCount"))
			end

			v7.Enabled = true
		end

		if child:GetAttribute("EmitDelay") then
			task.delay(child:GetAttribute("EmitDelay"), fn)
		else
			fn()
		end
	end

	local v7 = false
	task.spawn(function()
		local random = Random.new()
		local now = tick()
		local v8 = 0
		local v9 = 0

		while true do
			local lastTime = tick()
			local v10 = lastTime - now
			local v11 = math.min(1, v10 / 0.5)

			if lastTime - v8 >= 0.022222222222222223 then
				Effect.new("RaceTransformation.Trail"):replicate({
					Root = effect,
					Offset = CFrame.Angles(
						random:NextNumber(-3.141592653589793, 3.141592653589793) * random:NextNumber(0, 1),
						0,
						random:NextNumber(-3.141592653589793, 3.141592653589793) * random:NextNumber(0, 1)
					),
					Reverse = true,
					Color = random:NextInteger(1, 2) == 1 and color1 or color2,
					Radius = { random:NextNumber(6, 8), random:NextNumber(8, 16) },
					Height = { random:NextNumber(-2, 4), random:NextNumber(6, 16) },
					FadeIn = random:NextNumber(0.15, 0.25),
					FadeOut = random:NextNumber(0.15, 0.25),
					player = player2,
					race = player.Race
				})
				Effect.new("RaceTransformation.Trail"):replicate({
					Root = effect,
					Offset = CFrame.Angles(
						random:NextNumber(-3.141592653589793, 3.141592653589793) * random:NextNumber(0, 1),
						0,
						random:NextNumber(-3.141592653589793, 3.141592653589793) * random:NextNumber(0, 1)
					),
					Reverse = true,
					Color = random:NextInteger(1, 2) == 1 and color1 or color2,
					Radius = { random:NextNumber(10, 15), random:NextNumber(15, 25) },
					Height = { random:NextNumber(-2, 6), random:NextNumber(6, 25) },
					FadeIn = random:NextNumber(0.15, 0.25),
					FadeOut = random:NextNumber(0.15, 0.25),
					player = player2,
					race = player.Race
				})
				v8 = lastTime
			end

			if lastTime - v9 > 0.2 then
				local number = random:NextNumber(1, 3)
				Effect.new("Dough.Shockwaves.Slash"):replicate({
					CFrame = effect.CFrame * CFrame.new(0, random:NextNumber(-2, 4), 0) * CFrame.Angles(
						random:NextNumber(-3.141592653589793, 3.141592653589793) * random:NextNumber(0, 1) * v11,
						0,
						random:NextNumber(-3.141592653589793, 3.141592653589793) * random:NextNumber(0, 1) * v11
					),
					Color = number == 1 and color1 or number == 2 and Color3.new(1, 1, 1) or color2,
					Scale = {
						createVector(1, 1, 1) * random:NextNumber(8, 12),
						createVector(1, 0, 1) * random:NextNumber(15, 30)
					},
					VectorOffset = createVector(0, 1, 0) * random:NextNumber(0, v11 * 15),
					Transparency = random:NextNumber(0.6, 0.8),
					Brightness = random:NextNumber(1, 2),
					Duration = random:NextNumber(0.15, 0.3),
					RotationSpeed = random:NextNumber(1, 3),
					player = player2,
					race = player.Race
				})
				v9 = lastTime
			end

			if v10 >= 5 or v7 then
				break
			end

			task.wait(0.016666666666666666)
			local _ = tick() - lastTime
		end
	end)
	task.wait(1)

	for _, emitter in pairs(effect:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	for _, emitter in pairs(effect2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	v7 = true

	if v4 then
		CameraShaker:StopSustained(1)
	end

	local count = 0
	local raceTransformed

	repeat
		wait(0.1)
		raceTransformed = character:FindFirstChild("RaceTransformed")
		count += 1
	until raceTransformed and raceTransformed.Value or count >= 150

	if not character:IsDescendantOf(workspace) then
		return
	end

	local v8 = Util.Sound:Play(v3[player.Race], humanoidRootPart)
	tick()
	local v9 = {}
	local v10 = 0
	local v11 = 0
	local v12 = false

	while character:IsDescendantOf(workspace) and raceTransformed and raceTransformed.Value do
		local now = tick()
		local v13 = true
		local A = raceTransformed:GetAttribute("A")
		local B = raceTransformed:GetAttribute("B")
		local C = raceTransformed:GetAttribute("C")

		if A and B and C and (player.Race ~= "Skypiea" and player.Race ~= "Ghoul" or not (B >= 1)) then
			if player.Race == "Draco" and (B >= 1 or A >= 1) then
				v13 = false
			end
		else
			v13 = false
		end

		if humanoidRootPart.Velocity.Magnitude < 0.5 and v13 then
			local hit, _, _ = ray(
				humanoidRootPart.Position + humanoidRootPart.CFrame.UpVector,
				-humanoidRootPart.CFrame.UpVector * (humanoidRootPart.Size.Magnitude * 3),
				{ workspace.Characters, workspace.Enemies }
			)

			if hit then
				local v15 = humanoidRootPart.Size.Y / 2

				if #v9 == 0 then
					for _, attachment in pairs(raceTransformation.Main.Idle:GetChildren()) do
						if attachment:IsA("Attachment") and attachment.Name:find("Dust") then
							table.insert(v9, {
								Attachment = attachment:Clone(),
								AttachmentData = {},
								ParticleData = {}
							})
						end
					end

					for _, v16 in pairs(v9) do
						for _, child in pairs(v16.Attachment:GetChildren()) do
							v16.ParticleData[child] = {}
							v16.ParticleData[child].Size = child.Size.Keypoints
							v16.ParticleData[child].Acceleration = child.Acceleration
							v16.ParticleData[child].Speed = child.Speed
							child.Enabled = false
						end

						v16.AttachmentData.Position = v16.Attachment.Position
						v16.AttachmentData.CFrame = v16.Attachment.CFrame
						v16.Attachment.Parent = humanoidRootPart
					end
				end

				if now - v10 > 0.25 then
					for _, v16 in pairs(v9) do
						v16.Attachment.Parent = humanoidRootPart
						v16.Attachment.CFrame = v16.AttachmentData.CFrame - v16.AttachmentData.Position + v16.AttachmentData.Position * v15

						for _, child in pairs(v16.Attachment:GetChildren()) do
							Util.Misc.ScaleParticle(child, v15, {
								Size = v16.ParticleData[child].Size,
								Acceleration = v16.ParticleData[child].Acceleration,
								Speed = v16.ParticleData[child].Speed
							})
							child.Color = ColorSequence.new(hit.Color:Lerp(Color3.new(1, 1, 1), 0.3))

							if child.Name ~= "Rocks" then
								child.Enabled = true
							end
						end
					end

					if now - v10 - 0.25 > 0.25 and now - v11 > 0.1 then
						createRock({
							Reference = humanoidRootPart,
							Hit = hit,
							Scale = humanoidRootPart.Size
						})
						v11 = now
					end

					if not v12 then
						local v17 = Util.Sound:Play("WindTunnelLoop", humanoidRootPart, nil, 0.75)
						task.delay(0.1, function()
							Util.Sound:FadeOut(v17, 0.25)
						end)
						v12 = true
					end
				end
			end
		else
			v10 = now
			v12 = false

			for _, v14 in pairs(v9) do
				for _, child in pairs(v14.Attachment:GetChildren()) do
					child.Enabled = false
				end

				local worldCFrame = v14.Attachment.WorldCFrame
				v14.Attachment.Parent = workspace.Terrain
				v14.Attachment.WorldCFrame = worldCFrame
			end
		end

		task.wait()
	end

	if v8 then
		Util.Sound:FadeOut(v8, 1)
	end

	for _, v13 in pairs(v9) do
		for _, child in pairs(v13.Attachment:GetChildren()) do
			child.Enabled = false
		end
	end

	wait(1)

	for k, v13 in pairs(v9) do
		v13.Attachment:Destroy()
		v9[k] = nil
	end
end