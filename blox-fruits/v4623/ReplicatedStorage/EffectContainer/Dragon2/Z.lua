local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local sound = Util.Sound
local masterClock = Util.MasterClock
local debris = Util.Debris
local rock2 = Util.Rock2
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Z = FX:WaitForChild("Dragon2").Z

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function lerpInBack(p, p2, p3)
	return p + (p2 - p) * (p3 * p3 * (3 * p3 - 2))
end

local function cflerp(object, p, p2)
	return object:lerp(p, p2)
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function cubicBezier(p, position, p2, p3, position2)
	return position * (1 - p) ^ 3 + p2 * 3 * p * (1 - p) ^ 2 + p3 * 3 * (1 - p) * p ^ 2 + position2 * p ^ 3
end

local function charInRange(p, p2)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			return true
		end
	end

	return false
end

local function cameraInRange(p, p2)
	return (workspace.CurrentCamera.CFrame.p - p).Magnitude < p2
end

local sine = Util.Tween.ease.out.sine

local function emberBlob(value, p, p2, p3, p4)
	local color3Constructor = Util.WrapColor3Constructor(Color3.fromRGB(188, 155, 93), p4, "DragonFruitVFXColor")
	local color3Constructor2 = Util.WrapColor3Constructor(Color3.fromRGB(255, 85, 0), p4, "DragonFruitVFXColor")
	local part = Instance.new("Part")
	part.CanCollide = false
	part.Anchored = true
	part.Size = createVector(2, 2, 5)
	part.Color = color3Constructor
	part.Material = Enum.Material.Neon
	part.CFrame = p3.CFrame
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = Enum.MeshType.Sphere
	Util.SetParentOverrideWithColor(specialMesh, part, p4, "DragonFruitVFXColor")
	local v = value or 3

	for k, v2 in pairs(p3) do
		part[k] = v2
	end

	Util.SetParentOverrideWithColor(part, _WorldOrigin, p4, "DragonFruitVFXColor")
	local tween = TweenService:Create(
		part,
		TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = createVector(0, 0, 0)
		}
	)
	local flag = true
	local thread = task.spawn(function()
		local v2 = 0.016666666666666666
		local total = 1

		for i = 1, 999 * v do
			if i % 6 == 0 then
				part.Color = color3Constructor:Lerp(color3Constructor2, sine((total - 1) / 60 / v, 0, 1, 1))
			end

			part.CFrame = part.CFrame * CFrame.new(0, 0, -p2 * v2 * 60) * CFrame.Angles(
				math.rad(p * math.cos(total / 5 + math.random(-15, 15) / 10)) * v2 * 60,
				0,
				0
			)
			total += v2 * 1 * 60
			v2 = RunService.RenderStepped:Wait()
		end

		part:Destroy()
		flag = nil
	end)
	tween.Completed:Connect(function()
		part:Destroy()

		if flag then
			task.cancel(thread)
		end
	end)
	tween:Play()
end

local function newCylinder(items)
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Cylinder
	part.Anchored = true
	part.CastShadow = false
	part.CanCollide = false
	part.Size = createVector(1, 1, 1)

	for k, item in pairs(items) do
		part[k] = item
	end

	return part
end

local function scaleParticle(state, p)
	local v = {
		Size = state.Size.Keypoints,
		Speed = state.Speed
	}

	for i = 1, #v.Size do
		v.Size[i] = NumberSequenceKeypoint.new(v.Size[i].Time, v.Size[i].Value * p, v.Size[i].Envelope * p)
	end

	state.Size = NumberSequence.new(v.Size)
	state.Speed = NumberRange.new(state.Speed.Min * p, state.Speed.Max * p)
end

local function TornadoSlash(folder, data, p)
	local multiplier = data.Multiplier
	local multiplier2 = data.Multiplier2
	local mutliplier2Time = data.Mutliplier2Time
	local beamOutTime = data.BeamOutTime
	local slashAngle = data.SlashAngle
	local slashAngle2 = data.SlashAngle2
	local slashType = data.SlashType
	local slashCFrame = data.SlashCFrame
	local slashSpeed = data.SlashSpeed
	local slashSpeed2 = data.SlashSpeed2
	local spinIterations = data.SpinIterations
	local clone = slashType:Clone()
	clone.CFrame = slashCFrame
	Util.SetParentOverrideWithColor(clone, folder, p, "DragonFruitVFXColor")

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("Beam") then
			descendant.CurveSize0 *= multiplier
			descendant.CurveSize1 *= multiplier
			descendant.Width0 *= multiplier
			descendant.Width1 *= multiplier
		elseif descendant:IsA("Attachment") then
			descendant.Position = Vector3.new(
				descendant.Position.X * multiplier,
				descendant.Position.Y * multiplier,
				descendant.Position.Z * multiplier
			)
		end
	end

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("Beam") then
			descendant.Enabled = true
			local v = descendant
			task.spawn(function()
				local tween = TweenService:Create(
					v,
					TweenInfo.new(mutliplier2Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						CurveSize0 = v.CurveSize0 * multiplier2,
						CurveSize1 = v.CurveSize1 * multiplier2,
						Width0 = v.Width0 * multiplier2,
						Width1 = v.Width1 * multiplier2
					}
				)
				v.Width0 = 0
				v.Width1 = 0
				tween:Play()
			end)
		elseif descendant:IsA("Attachment") then
			TweenService:Create(
				descendant,
				TweenInfo.new(mutliplier2Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Position = Vector3.new(
						descendant.Position.X * multiplier2,
						descendant.Position.Y * multiplier2,
						descendant.Position.Z * multiplier2
					)
				}
			):Play()
		end
	end

	for _ = 1, spinIterations do
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(slashSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = clone.CFrame * slashAngle
			}
		)
		tween:Play()
		tween.Completed:Wait()
	end

	for _, beam in pairs(clone:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		local v = beam
		task.spawn(function()
			local tween = TweenService:Create(
				v,
				TweenInfo.new(beamOutTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Width0 = 0,
					Width1 = 0
				}
			)
			tween:Play()
			tween.Completed:Wait()
			v:Destroy()
		end)
	end

	TweenService:Create(clone, TweenInfo.new(slashSpeed2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CFrame = clone.CFrame * slashAngle2
	}):Play()
end

local function blast(data, p, p2, position, p3, p4, p5, p6, p7)
	local v = 1 + (p4 - 1) * 3

	if p2 then
		local part = Instance.new("Part")
		Util.Debris:AddItem(part, 15)
		part.Size = createVector(0, 0, 0)
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.Transparency = 1
		Util.SetParentOverrideWithColor(part, _WorldOrigin, p7, "DragonFruitVFXColor")
		local v2 = 45 * v
		local v3 = math.ceil(12 * v)

		for i = 1, v3 do
			local v4 = 360 / v3 * i
			local v5 = CFrame.new(position, position + p5) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
				0,
				math.rad(v4),
				0
			) * CFrame.new(0, 0, -v2)
			local ray, v6, v7 = Util.Ray(
				v5.Position,
				v5.upVector.Unit * -30,
				{ workspace.Characters, workspace.Enemies },
				false
			)

			if not ray then
				continue
			end

			local v8 = rock2.new({
				FadeIn = { 0.5, 1 },
				Lifetime = math.random(25, 30) / 10,
				FadeOut = { 0.4, 0.5 },
				Size = Vector3.new(math.random(3, 6) * v, 2 * v, math.random(3, 6) * v),
				Scale = { 1, 2 }
			})
			v8:Spawn(
				CFrame.new(v6, v6 + v7) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(0, math.rad(v4), 0),
				0.05
			)
			local clone = data.FireRise:Clone()
			Util.SetParentOverrideWithColor(clone, v8.Part, p7, "DragonFruitVFXColor")
			local clone2 = data.Smoke:Clone()
			Util.SetParentOverrideWithColor(clone2, v8.Part, p7, "DragonFruitVFXColor")

			for _, v9 in pairs({ clone2, clone }) do
				scaleParticle(v9, v)
			end

			task.delay(1, function()
				if clone2 then
					clone2.Enabled = false
					Util.SetParentOverrideWithColor(clone2, part, p7, "DragonFruitVFXColor")
				end

				if clone then
					clone.Enabled = false
					Util.SetParentOverrideWithColor(clone, part, p7, "DragonFruitVFXColor")
				end
			end)

			if not (math.random(1, 100) <= 50) then
				continue
			end

			v8.Type = "Flying"
			v8:Eject({
				Velocity = (v5.UpVector * (workspace.Gravity / 2 + math.random(-20, 40)) + v8.Part.CFrame.lookVector * math.random(
					30,
					50
				)) * v,
				RotVelocity = createVector(3.1415927, 3.1415927, 3.1415927)
			})
		end
	end

	local position2 = position + p5 * 10 * v
	local part = Instance.new("Part")
	debris:AddItem(part, 20)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.Size = createVector(1, 1, 1)
	part.Position = position2
	part.Name = "seedPart"
	Util.SetParentOverrideWithColor(part, _WorldOrigin, p7, "DragonFruitVFXColor")

	for _ = 1, math.random(25, 35) do
		local v3 = CFrame.new(position2, position) * CFrame.Angles(
			math.rad(math.random(-70, 70) * (1 + (v - 1) * 0.2)),
			math.rad(math.random(-70, 70) * (1 + (v - 1) * 0.2)),
			0
		)
		local ray, v4, v5 = Util.Ray(
			position2,
			v3.lookVector.Unit * 50 * v,
			{ workspace.Characters, workspace.Enemies },
			false
		)

		if not ray then
			continue
		end

		local attachment = Instance.new("Attachment")
		Util.SetParentOverrideWithColor(attachment, part, p7, "DragonFruitVFXColor")
		attachment.WorldCFrame = CFrame.new(v4, v4 + v5 * 1.1) * CFrame.Angles(-1.5707963267948966, 0, 0)

		if v5 == createVector(0, 1, 0) then
			attachment.Orientation = createVector(0, 90, 0)
		end

		local clone = data.FireFlakes:Clone()
		Util.SetParentOverrideWithColor(clone, attachment, p7, "DragonFruitVFXColor")
		local clone2 = data.FlyingFlakes:Clone()
		Util.SetParentOverrideWithColor(clone2, attachment, p7, "DragonFruitVFXColor")
		scaleParticle(clone, v)
		scaleParticle(clone2, v)
		task.delay(3, function()
			if clone2 then
				clone2.Enabled = false
			end
		end)
		clone:Emit(1)
	end

	task.spawn(function()
		local v3 = Util.Sound:Play("BF_V3_Dragon_Z_Explosion_02", position)
		v3.RollOffMinDistance = 60 * v

		if p6 then
			v3.PlaybackSpeed = 1 - 0.3 * p6
		end

		Util.DestroyAfter(v3, 10)
		local clone = data.BlastModel:Clone()
		Util.Debris:AddItem(clone, 15)
		local shockwave = clone.Shockwave
		local windRing = clone.WindRing
		local cloudCore = clone.CloudCore
		local cloudMiddle = clone.CloudMiddle
		local cloudShell = clone.CloudShell
		local _ = clone.PrimaryPart
		local cFrame = CFrame.new(
			position,
			position + (p3 == nil and createVector(0, 1, 0) or p3 or createVector(0, 1, 0))
		) * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone:SetPrimaryPartCFrame(cFrame * CFrame.new(0, 1, 0))
		local clone2 = data.BlastParticles:Clone()
		debris:AddItem(clone2, 20)
		clone2.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone2, _WorldOrigin, p7, "DragonFruitVFXColor")

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			scaleParticle(emitter, v)

			if emitter.Name == "Flakes" then
				emitter.ShapePartial *= v
				emitter.TimeScale = math.max(0.2, emitter.TimeScale - v / 7 + 0.75)
			else
				emitter.TimeScale = math.max(0.2, emitter.TimeScale - v / 5 + 0.2)
			end

			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end

		for _ = 0, 2 do
			local clone3 = data.HeatwaveRing:Clone()
			clone3.Size = createVector(0, 0, 0)
			clone3.CFrame = cFrame * CFrame.Angles(
				math.rad((math.random(-40, 40))),
				math.rad((math.random(-150, 150))),
				(math.rad((math.random(-40, 40))))
			)
			local tween = TweenService:Create(
				clone3,
				TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Color = Util.WrapColor3Constructor(Color3.fromRGB(168, 65, 17), p7, "DragonFruitVFXColor"),
					Size = Vector3.new(math.random(220, 250) * v, 15 * v, math.random(220, 250) * v),
					CFrame = clone3.CFrame * CFrame.Angles(0, 2.2689280275926285, 0),
					Transparency = 1
				}
			)
			tween.Completed:Connect(function()
				clone3:Destroy()
			end)
			Util.SetParentOverrideWithColor(clone3, _WorldOrigin, p7, "DragonFruitVFXColor")
			tween:Play()
		end

		local pointLight = Instance.new("PointLight")
		pointLight.Color = Util.WrapColor3Constructor(Color3.fromRGB(255, 155, 33), p7, "DragonFruitVFXColor")
		pointLight.Brightness = 0.5
		pointLight.Range = 1
		pointLight.Shadows = true
		Util.SetParentOverrideWithColor(pointLight, clone2, p7, "DragonFruitVFXColor")
		local tween = TweenService:Create(
			pointLight,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
			{
				Brightness = 5,
				Range = 220 * v,
				Color = Util.WrapColor3Constructor(Color3.fromRGB(255, 84, 17), p7, "DragonFruitVFXColor")
			}
		)
		tween.Completed:Connect(function()
			if pointLight then
				pointLight:Destroy()
			end
		end)
		tween:Play()
		local cframe = CFrame.Angles(
			math.rad((math.random(-50, 50))),
			math.rad((math.random(-170, 170))),
			(math.rad((math.random(-50, 50))))
		)
		local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0)
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, p7, "DragonFruitVFXColor")
		local tween2 = TweenService:Create(
			shockwave,
			TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Transparency = 1,
				Size = Vector3.new(160 * v, 5, 160 * v),
				CFrame = shockwave.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(0, 2.792526803190927, 0)
			}
		)
		local tween3 = TweenService:Create(
			windRing,
			TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Transparency = 1,
				Size = Vector3.new(220 * v, 5, 220 * v),
				CFrame = windRing.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(0, 2.792526803190927, 0)
			}
		)
		local tween4 = TweenService:Create(cloudCore, tweenInfo, {
			Size = Vector3.new(113.136 * v, 114.308 * v, 112.472 * v),
			CFrame = cloudCore.CFrame * cframe
		})
		local tween5 = TweenService:Create(cloudMiddle, tweenInfo, {
			Size = Vector3.new(115.096 * v, 117.954 * v, 114.751 * v),
			CFrame = cloudMiddle.CFrame * cframe
		})
		local tween6 = TweenService:Create(cloudShell, tweenInfo, {
			Size = Vector3.new(120.606 * v, 123.772 * v, 120.488 * v),
			CFrame = cloudShell.CFrame * cframe
		})

		for _, v5 in pairs({
			{ tween2, shockwave },
			{ tween3, windRing }
		}) do
			local v6 = v5
			v5[1].Completed:Connect(function()
				v6[2]:Destroy()
				v6[1]:Destroy()
			end)
			v5[1]:Play()
		end

		for _, v5 in pairs({
			{ tween4, cloudCore },
			{ tween5, cloudMiddle },
			{ tween6, cloudShell }
		}) do
			local tween7 = TweenService:Create(
				v5[2],
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
				{
					Transparency = 1,
					Size = createVector(0, 0, 0),
					CFrame = v5[2].CFrame * CFrame.new(math.random(-50, 50) * v, 2 * v, math.random(-50, 50) * v)
				}
			)
			local v6 = v5
			tween7.Completed:Connect(function()
				v6[2]:Destroy()
				tween7:Destroy()
			end)
			local v8 = tween7
			local v9 = v5
			v5[1].Completed:Connect(function()
				v8:Play()
				v9[1]:Destroy()
			end)
			v5[1]:Play()
		end

		for _ = 0, 10 do
			local v5 = math.random(5, 8)
			local v6 = math.random(20, 25)
			local v7 = { math.random(-55, -25), math.random(25, 55) }
			local v8 = { math.random(-55, -25), math.random(25, 55) }
			local v9 = { math.random(-55, -25), math.random(25, 55) }
			emberBlob(math.random(15, 20) / 10, 15, 3 * v, {
				CFrame = CFrame.new(
					position,
					position + (p3 == nil and createVector(0, 1, 0) or p3 or createVector(0, 1, 0))
				) * CFrame.Angles(
					math.rad(v7[math.random(1, #v7)]),
					math.rad(v8[math.random(1, #v8)]),
					(math.rad(v9[math.random(1, #v9)]))
				),
				Color = Util.WrapColor3Constructor(Color3.fromRGB(188, 125, 0), p7, "DragonFruitVFXColor"),
				Size = Vector3.new(v5, v5, v6) * v
			}, p7)
		end

		local v5 = p == game.Players.LocalPlayer.Character and 2 or 1
		local v6 = position
		local v7 = 150 * v * v5
		local character = game.Players.LocalPlayer.Character
		local v8

		if character == nil then
			v8 = false
		else
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			v8 = humanoidRootPart and (humanoidRootPart.Position - v6).magnitude <= v7 and true or false
		end

		if v8 then
			Util.CameraShaker:ShakeOnce(math.clamp(10 * v, 10, 25), math.clamp(15 * v, 10, 25), 1, 1)
			Effect.new("ColorCorrection"):replicate({
				TintColor = Util.WrapColor3ConstructorForTintColor(
					Color3.fromRGB(255, 179, 134),
					p7,
					"DragonFruitVFXColor"
				),
				Brightness = -0.2,
				Contrast = 0.5,
				FadeIn = 0.4,
				FadeOut = 0.6,
				Lifetime = 0.5
			})
			local blurEffect = Instance.new("BlurEffect")
			blurEffect.Size = 0
			local setParentOverrideWithColor = Util.SetParentOverrideWithColor
			local Lighting = game:GetService("Lighting")
			setParentOverrideWithColor(blurEffect, Lighting, p7, "DragonFruitVFXColor")
			local tween7 = TweenService:Create(
				blurEffect,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0),
				{
					Size = 4
				}
			)
			tween7.Completed:Connect(function()
				if blurEffect then
					blurEffect:Destroy()
				end
			end)
			tween7:Play()
		end
	end)
	task.spawn(function()
		local clone = data.ExplosionModel:Clone()
		Util.Debris:AddItem(clone, 15)
		clone.PrimaryPart.CFrame = CFrame.new(position)
		clone:ScaleTo(1.85 * v)
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, p7, "DragonFruitVFXColor")

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end)
end

local function beamProjectile(SUPERCHARGE, player, chargeTime, player2)
	if player.Scale > 1.9 then
		local v = player.Character == game.Players.LocalPlayer.Character and 2 or 1
		local p = player.CFrame.p
		local v2 = 100 * player.Scale * v
		local character = game.Players.LocalPlayer.Character
		local v3

		if character == nil then
			v3 = false
		else
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			v3 = humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= v2 and true or false
		end

		if v3 then
			Effect.new("ColorCorrection"):replicate({
				TintColor = Util.WrapColor3ConstructorForTintColor(
					Color3.fromRGB(1, 1, 1),
					player2,
					"DragonFruitVFXColor"
				),
				Brightness = -200,
				Contrast = 3000,
				Saturation = -1.3,
				FadeIn = 0,
				FadeOut = 0,
				Lifetime = 0.1
			})
			local blurEffect = Instance.new("BlurEffect")
			blurEffect.Size = 0
			local setParentOverrideWithColor = Util.SetParentOverrideWithColor
			local Lighting = game:GetService("Lighting")
			setParentOverrideWithColor(blurEffect, Lighting, player2, "DragonFruitVFXColor")
			local tween = TweenService:Create(
				blurEffect,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0),
				{
					Size = 5
				}
			)
			tween.Completed:Connect(function()
				if blurEffect then
					blurEffect:Destroy()
				end
			end)
			tween:Play()
		end
	end

	local magnitude = (player.CFrame.Position - player.ExplosionPosition).Magnitude
	local v = {
		Life = player.Life,
		Dist = player.Distance,
		Scale = player.Scale,
		SpawnCF = player.CFrame,
		SpawnTime = player.SpawnTime,
		DeltaTime = masterClock:GetTime() - player.SpawnTime,
		Loop = {
			t = tick(),
			lp = tick(),
			lpl = tick(),
			lcyl = tick(),
			currentCFrame = player.CFrame,
			lastCF = player.CFrame,
			lastCyl = nil,
			lastCylCF = nil,
			lastDist = 1,
			dt = 0.016666666666666666,
			hit = nil,
			pos = nil,
			norm = nil
		}
	}
	local clone = SUPERCHARGE.Fireball:Clone()
	debris:AddItem(clone, v.Life + 5)
	clone.CFrame = v.SpawnCF
	local back = clone.Back
	local center = clone.Center
	local _ = v.SpawnCF.lookVector
	local segmentGlint = clone.SegmentGlint
	scaleParticle(segmentGlint, v.Scale)
	local segmentFire = clone.SegmentFire
	scaleParticle(segmentFire, v.Scale)
	local v2 = {}

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			scaleParticle(descendant, v.Scale)
			descendant:Emit(descendant:GetAttribute("EmitCount"))
		elseif descendant:IsA("Attachment") and descendant.Name ~= "Back" and descendant.Name ~= "Center" then
			descendant.Position *= v.Scale
		elseif descendant:IsA("Beam") then
			for _, v3 in pairs({
				"Width0",
				"Width1",
				"CurveSize0",
				"CurveSize1",
				"Segments"
			}) do
				descendant[v3] *= v.Scale
			end
		end
	end

	Util.SetParentOverrideWithColor(clone, _WorldOrigin, player2, "DragonFruitVFXColor")
	local scale = player.Scale

	if player.SuperCharge and player.SuperCharge >= 2 then
		scale *= 2
	end

	local v3 = {
		Size = Vector3.new(1, 6 * scale, 6 * scale),
		CFrame = v.Loop.lastCF,
		Color = Util.WrapColor3Constructor(Color3.fromRGB(255, 210, 138), player2, "DragonFruitVFXColor"),
		Material = Enum.Material.Neon,
		Transparency = 0,
		Parent = _WorldOrigin
	}
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Cylinder
	part.Anchored = true
	part.CastShadow = false
	part.CanCollide = false
	part.Size = createVector(1, 1, 1)

	for k, v4 in pairs(v3) do
		part[k] = v4
	end

	debris:AddItem(part, 5)
	v.Loop.lastCyl = part
	v.Loop.lastCylCF = part.CFrame
	v.Loop.lcyl = tick()

	for _, v4 in pairs({ back.CrescentsLoose, back.FireShapeLoose }) do
		v4:Emit(v4:GetAttribute("EmitCount"))
		segmentGlint:Emit(3)
		segmentFire:Emit(3)
	end

	local clone2 = SUPERCHARGE.BeamStartModel:Clone()
	clone2:ScaleTo(scale)
	Util.Debris:AddItem(clone2, 5)
	Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player2, "DragonFruitVFXColor")
	local primaryPart = clone2.PrimaryPart
	local beam = primaryPart.Beam
	local clone3 = SUPERCHARGE.Beam2:Clone()
	Util.Debris:AddItem(clone3, 5)
	Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player2, "DragonFruitVFXColor")

	for _, emitter in pairs(beam:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	for _, emitter in pairs(clone3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	primaryPart.CFrame = v.SpawnCF
	beam.CFrame = v.SpawnCF
	clone3.CFrame = v.SpawnCF
	local clone4 = SUPERCHARGE.ExplosionTrail:Clone()
	clone4.CFrame = v.Loop.lastCF
	clone4.Anchored = false
	clone4.Weld.Part0 = beam
	Util.SetParentOverrideWithColor(clone4, primaryPart, player2, "DragonFruitVFXColor")
	table.insert(v2, { part, nil, tick() })
	task.spawn(function()
		while #v2 > 0 do
			for k, v4 in pairs(v2) do
				if v4[1] then
					local v5 = math.clamp((tick() - v4[3]) / 0.55, 0, 1)
					local v6 = v4[1]
					local vector2 = Vector3.new(v4[1].Size.X, 2 * scale, 2 * scale)
					v6.Size = vector2 + (Vector3.new(v4[1].Size.X, 0, 0) - vector2) * (v5 * v5 * (3 * v5 - 2))
					v4[1].Color = v4[1].Color:Lerp(
						Util.WrapColor3Constructor(Color3.fromRGB(255, 177, 88), player2, "DragonFruitVFXColor"),
						v5
					)

					if v5 >= 1 then
						v4[1].Transparency = 1
						local v7 = v4
						local v8 = k
						task.delay(1, function()
							if v7[1] then
								v7[1]:Destroy()
							end

							table.remove(v2, v8)
						end)
					end
				else
					table.remove(v2, k)
				end
			end

			RunService.RenderStepped:Wait()
		end
	end)
	local v4 = true
	task.spawn(function()
		repeat
			local tween = TweenService:Create(
				clone4.Weld,
				TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					C0 = clone4.Weld.Part0.CFrame:ToObjectSpace(clone4.Weld.Part1.CFrame) * CFrame.Angles(
						0,
						0,
						1.5707963267948966
					)
				}
			)
			tween:Play()
			tween.Completed:Wait()
		until v4 == false
	end)

	if player.SuperCharge then
		local clone5 = SUPERCHARGE.Transformed.SparksImpact:Clone()
		clone5.CFrame = v.SpawnCF
		local folder = Instance.new("Folder", workspace._WorldOrigin)
		Util.Debris:AddItem(folder, 2)
		Util.SetParentOverrideWithColor(clone5, folder, player2, "DragonFruitVFXColor")

		for _, emitter in pairs(clone5:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		task.spawn(function()
			local folder2 = Instance.new("Folder", workspace._WorldOrigin)
			Util.Debris:AddItem(folder2, 2)
			local slashCFrame = v.SpawnCF * CFrame.new(0, 0, -5)
			TornadoSlash(folder2, {
				Multiplier = 1.15,
				Multiplier2 = math.clamp(v.Scale, 1.25, 2.5),
				Mutliplier2Time = 0.25,
				BeamOutTime = 0.25,
				SlashAngle = CFrame.new(0, 0, -5) * CFrame.Angles(0, 0, -0.8726646259971648),
				SlashAngle2 = CFrame.new(0, 0, -5) * CFrame.Angles(0, 0, -1.7453292519943295),
				SlashType = SUPERCHARGE.BeamSlash,
				SlashCFrame = slashCFrame,
				SlashSpeed = 0.05,
				SlashSpeed2 = 1,
				SpinIterations = 5
			}, player2)
		end)
		task.spawn(function()
			local folder2 = Instance.new("Folder", workspace._WorldOrigin)
			Util.Debris:AddItem(folder2, 2)
			local slashCFrame = v.SpawnCF * CFrame.new(0, 0, -25)
			TornadoSlash(folder2, {
				Multiplier = 1.3,
				Multiplier2 = math.clamp(v.Scale, 1.25, 2),
				Mutliplier2Time = 0.25,
				BeamOutTime = 0.25,
				SlashAngle = CFrame.new(0, 0, 3.5) * CFrame.Angles(0, 0, 0.8726646259971648),
				SlashAngle2 = CFrame.new(0, 0, 5) * CFrame.Angles(0, 0, 1.7453292519943295),
				SlashType = SUPERCHARGE.BeamSlash,
				SlashCFrame = slashCFrame,
				SlashSpeed = 0.025,
				SlashSpeed2 = 0.35,
				SpinIterations = 5
			}, player2)
		end)
	end

	if player.SuperCharge and player.SuperCharge >= 2 then
		local folder = Instance.new("Folder", workspace._WorldOrigin)
		Util.Debris:AddItem(folder, 3)
		task.spawn(function()
			local cFrame = v.SpawnCF * CFrame.new(0, 0, -125)
			local clone5 = SUPERCHARGE.Transformed.RingBeamModel:Clone()
			clone5.PrimaryPart.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone5, folder, player2, "DragonFruitVFXColor")
			local beamsByBeam = {}
			local flag = false

			for _, beam2 in pairs(clone5:GetDescendants()) do
				if not beam2:IsA("Beam") then
					continue
				end

				local v6 = beam2
				task.spawn(function()
					local tween = TweenService:Create(
						v6,
						TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0),
						{
							Width0 = v6.Width0 * 7,
							Width1 = v6.Width1 * 7
						}
					)
					tween:Play()
					tween.Completed:Wait()
					local tween2 = TweenService:Create(
						v6,
						TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0),
						{
							Width0 = v6.Width0 * 2,
							Width1 = v6.Width1 * 2
						}
					)
					tween2:Play()
					tween2.Completed:Wait()
					TweenService:Create(v6, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0), {
						Width0 = v6.Width0 * 0.25,
						Width1 = v6.Width1 * 0.25
					}):Play()
				end)
				beamsByBeam[beam2] = beam2
			end

			task.spawn(function()
				local tween = TweenService:Create(
					clone5.PrimaryPart,
					TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						CFrame = clone5.PrimaryPart.CFrame * CFrame.new(0, 0, 10)
					}
				)
				tween:Play()
				tween.Completed:Wait()
				TweenService:Create(
					clone5.PrimaryPart,
					TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						CFrame = clone5.PrimaryPart.CFrame * CFrame.new(0, 0, 150)
					}
				):Play()
			end)
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = 0.0001
			Util.SetParentOverrideWithColor(numberValue, clone5, player2, "DragonFruitVFXColor")
			TweenService:Create(numberValue, TweenInfo.new(0.35), {
				Value = 0.1
			}):Play()
			task.spawn(function()
				for i = 15, 50, 5 do
					if flag then
						break
					end

					clone5:ScaleTo(i / 10)
					task.wait(numberValue.Value)
				end

				for i = 50, 100, 5 do
					if flag then
						break
					end

					clone5:ScaleTo(i / 10)
					task.wait(numberValue.Value)
				end
			end)
			task.wait(0.3)
			task.spawn(function()
				local lastTime = tick()

				while tick() - lastTime < 0.2 do
					local v6 = 0.9 + (tick() - lastTime) / 0.2 * 0.1
					local numberSequence = NumberSequence.new(v6, v6)

					for _, v7 in pairs(beamsByBeam) do
						v7.Transparency = numberSequence
					end

					task.wait()
				end

				for _, v6 in pairs(beamsByBeam) do
					v6.Transparency = NumberSequence.new(1, 1)
				end

				flag = true
			end)
		end)
		task.spawn(function()
			local cFrame = v.SpawnCF * CFrame.new(0, 0, -125)
			local clone5 = SUPERCHARGE.Transformed.RingBeamModel:Clone()
			clone5.PrimaryPart.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone5, folder, player2, "DragonFruitVFXColor")
			local beamsByBeam = {}
			local flag = false

			for _, beam2 in pairs(clone5:GetDescendants()) do
				if not beam2:IsA("Beam") then
					continue
				end

				local v6 = beam2
				task.spawn(function()
					local tween = TweenService:Create(
						v6,
						TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0),
						{
							Width0 = v6.Width0 * 7,
							Width1 = v6.Width1 * 7
						}
					)
					tween:Play()
					tween.Completed:Wait()
					local tween2 = TweenService:Create(
						v6,
						TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0),
						{
							Width0 = v6.Width0 * 2,
							Width1 = v6.Width1 * 2
						}
					)
					tween2:Play()
					tween2.Completed:Wait()
					TweenService:Create(v6, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0), {
						Width0 = v6.Width0 * 0.25,
						Width1 = v6.Width1 * 0.25
					}):Play()
				end)
				beamsByBeam[beam2] = beam2
			end

			task.spawn(function()
				local tween = TweenService:Create(
					clone5.PrimaryPart,
					TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						CFrame = clone5.PrimaryPart.CFrame * CFrame.new(0, 0, 10)
					}
				)
				tween:Play()
				tween.Completed:Wait()
				TweenService:Create(
					clone5.PrimaryPart,
					TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						CFrame = clone5.PrimaryPart.CFrame * CFrame.new(0, 0, 75)
					}
				):Play()
			end)
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = 0.0001
			TweenService:Create(numberValue, TweenInfo.new(0.35), {
				Value = 0.1
			}):Play()
			task.spawn(function()
				for i = 15, 25, 5 do
					if flag then
						break
					end

					clone5:ScaleTo(i / 10)
					task.wait(numberValue.Value)
				end

				for i = 25, 50, 5 do
					if flag then
						break
					end

					clone5:ScaleTo(i / 10)
					task.wait(numberValue.Value)
				end
			end)
			task.wait(0.225)
			task.spawn(function()
				local lastTime = tick()

				while tick() - lastTime < 0.2 do
					local v6 = 0.9 + (tick() - lastTime) / 0.2 * 0.1
					local numberSequence = NumberSequence.new(v6, v6)

					for _, v7 in pairs(beamsByBeam) do
						v7.Transparency = numberSequence
					end

					task.wait()
				end

				for _, v6 in pairs(beamsByBeam) do
					v6.Transparency = NumberSequence.new(1, 1)
				end

				flag = true
			end)
		end)
	end

	task.spawn(function()
		TweenService:Create(
			primaryPart.Attach_0,
			TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.5),
			{
				CFrame = primaryPart.Attach_0.CFrame * CFrame.new(-v.Dist / 50, 0, 0)
			}
		):Play()
		task.wait(0.15)

		for _, beam2 in pairs(primaryPart:GetDescendants()) do
			if not beam2:IsA("Beam") then
				continue
			end

			if v4 == false then
				break
			else
				TweenService:Create(beam2, TweenInfo.new(0.5), {
					Width0 = beam2.Width0 / 1.5,
					Width1 = beam2.Width1
				}):Play()
			end
		end
	end)
	tick()
	local spawnCF = v.SpawnCF
	local v6 = magnitude / v.Dist * v.Life
	local flag = false

	while not flag do
		local v8 = (tick() - v.Loop.t + v.DeltaTime) / v6

		if v8 >= 1 then
			v8 = 1
			flag = true
		end

		local loop = v.Loop
		loop.currentCFrame = v.SpawnCF * CFrame.new(0, 0, -magnitude * v8)
		clone.CFrame = v.Loop.currentCFrame
		beam.CFrame = v.Loop.currentCFrame
		local magnitude2 = (v.Loop.currentCFrame.Position - spawnCF.Position).Magnitude
		clone3.Size = Vector3.new(clone3.Size.X, clone3.Size.Y, magnitude2)
		clone3.CFrame = spawnCF * CFrame.new(0, 0, -clone3.Size.Z / 2)

		if tick() - v.Loop.lp > 0.02 then
			for _, v9 in pairs({
				back.Crescents,
				back.CrescentsLoose,
				back.FireShape,
				back.FireShapeLoose,
				center.Embers,
				center.Plasma
			}) do
				v9:Emit(v9:GetAttribute("EmitCount"))
			end

			v.Loop.lp = tick()
		end

		if tick() - v.Loop.lpl > 0.02 then
			for _, v9 in pairs({ back.CrescentsLoose, back.FireShapeLoose }) do
				v9:Emit(v9:GetAttribute("EmitCount"))
				segmentGlint:Emit(3)
				segmentFire:Emit(3)
			end

			v.Loop.lpl = tick()
		end

		if v.Loop.lastCyl then
			local magnitude3 = (v.Loop.lastCylCF.p - v.Loop.currentCFrame.p).Magnitude
			local cFrame = CFrame.new(v.Loop.lastCylCF.p, v.Loop.currentCFrame.p) * CFrame.new(0, 0, -magnitude3 / 2) * CFrame.Angles(
				0,
				1.5707963267948966,
				0
			)
			v.Loop.lastCyl.CFrame = cFrame
			local lastCyl = v.Loop.lastCyl
			local v10 = 6 * v.Scale
			lastCyl.Size = Vector3.new(magnitude3, v10, 6 * v.Scale)
		end

		if flag then
			break
		else
			v.Loop.dt = RunService.RenderStepped:Wait()
		end
	end

	v4 = false
	local explosionPosition = player.ExplosionPosition
	local hit = player.RayData.Hit
	local norm = player.RayData.Norm

	if not hit then
		norm = -v.SpawnCF.LookVector
	end

	task.spawn(
		blast,
		SUPERCHARGE,
		player.Character,
		hit,
		explosionPosition,
		norm,
		v.Scale,
		hit and norm or createVector(0, 1, 0),
		chargeTime,
		player2
	)

	if clone then
		local part2 = Instance.new("Part")
		Util.Debris:AddItem(part2, 15)
		part2.Size = Vector3.new()
		part2.Anchored = true
		part2.CanCollide = false
		part2.Transparency = 1
		part2.CFrame = clone.CFrame
		Util.SetParentOverrideWithColor(part2, _WorldOrigin, player2, "DragonFruitVFXColor")

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				Util.SetParentOverrideWithColor(emitter, part2, player2, "DragonFruitVFXColor")
			end
		end

		clone:Destroy()
	end

	for _, effect in pairs(primaryPart:GetDescendants()) do
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = false
		elseif effect:IsA("Beam") then
			TweenService:Create(effect, TweenInfo.new(0.5), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end
	end

	task.spawn(function()
		task.wait(0.1)

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
	v = nil
end

local function mockRootPart(cFrame: CFrame)
	local part = Instance.new("Part")
	part.Name = "Mock" .. part.Name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cFrame
	part.Parent = workspace._WorldOrigin
	return part
end

local time2 = time

function RenderSteppedLoopFor(p, callback, callback2)
	local renderSteppedConnection = nil
	local v = time2()
	local bindableEvent = Instance.new("BindableEvent")
	local v2 = false
	local v3 = {
		Disconnect = function(self)
			if callback2 then
				v2 = true
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
	local v4 = false
	renderSteppedConnection = RunService.RenderStepped:Connect(function(_)
		if time2() - v < p and v4 == false then
			if callback(v3) then
				v4 = true
			end
		elseif v2 == true or callback2 == nil then
			if bindableEvent ~= nil then
				bindableEvent:Fire()
			end

			if renderSteppedConnection ~= nil then
				renderSteppedConnection:Disconnect()
			end
		else
			v2 = true
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

local v = CFrame.new(0, -7.5, 2.5) * CFrame.Angles(-0.8, 0, 0)
return function(player)
	local player2 = player.player
	local SUPERCHARGE = player.SuperCharge and Z.SUPERCHARGE or Z
	local ID = player.ID

	if ID == 1 then
		local head = player.Head
		local holdValue = player.HoldValue
		local humanoid = player.Humanoid
		local start = player.Start
		local charge = player.Charge
		local flag

		if player.dragonModel then
			local tongue3 = player.dragonModel.RootPart:FindFirstChild("Tongue3", true) or nil
			local inverse = (CFrame.lookAt(createVector(0, 0, 0), createVector(0, 1, 0)):Inverse() * CFrame.Angles(
				0,
				4.71238898038469,
				0
			)):Inverse()
			local cFrame = tongue3.WorldCFrame * inverse * v
			local part = Instance.new("Part")
			part.Name = "Mock" .. part.Name
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Transparency = 1
			part.CFrame = cFrame
			part.Parent = workspace._WorldOrigin
			head = part
			task.spawn(function()
				RenderSteppedLoopFor(999, function(connection)
					if head:IsDescendantOf(workspace) then
						head.CFrame = tongue3.WorldCFrame * inverse * v
					else
						connection:Disconnect()
						return true
					end
				end)
			end)
			flag = true
		else
			flag = false
		end

		if head and holdValue and humanoid then
			local offset = player.Offset
			local windUp = player.WindUp
			local v2 = math.max(0.01, charge - (masterClock:GetTime() - start))
			local v3 = humanoid.Health > 0
			local diedConnection = nil
			diedConnection = humanoid.Died:Connect(function()
				v3 = false
				diedConnection:Disconnect()
			end)

			if (head.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > (player.Transformed and 1500 or 750) or humanoid.Health <= 0 then
				return
			end

			local cFrame = head.CFrame * offset
			Util.Sound:Play("Burning", head, nil, 1.2, 0.5)
			Util.Sound:Play("BF_V3_Dragon_Z_Activate_02", head)
			local v5 = Util.Sound:Play(
				"BF_V3_Dragon_Z_Hold_03",
				head,
				player.Hybrid and 12 or not player.Transformed and 8 or nil
			)
			TweenService:Create(v5, TweenInfo.new(0.4), {
				Volume = 1
			}):Play()

			if player.Transformed then
				local clone = SUPERCHARGE.Transformed.HeatwaveCharge:Clone()
				clone.CFrame = cFrame
				Util.SetParentOverrideWithColor(clone, _WorldOrigin, player2, "DragonFruitVFXColor")
				local flag2 = true

				for _, emitter in pairs(clone.Start:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				local clone2 = SUPERCHARGE.Transformed.FireOrbModel:Clone()
				local fireOrb = clone2.FireOrb
				fireOrb.CFrame = cFrame
				Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player2, "DragonFruitVFXColor")
				clone2:ScaleTo(0.3)
				task.spawn(function()
					local v6 = tick() + v2
					local numberValue = Instance.new("NumberValue")
					numberValue.Value = 0.3
					TweenService:Create(
						numberValue,
						TweenInfo.new(v2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Value = 1
						}
					):Play()

					repeat
						clone2:ScaleTo(numberValue.Value)
						task.wait(0.016666666666666666)
					until v6 - tick() <= 0 or flag2 == false

					numberValue:Destroy()

					if flag2 then
						clone2:ScaleTo(numberValue.Value)
						local v7 = {
							"Attachment",
							"Attachment2",
							"Attachment3",
							"Attachment7",
							"AreaSparks"
						}

						for _, v8 in pairs(v7) do
							v7[v8] = true
						end

						for _, emitter in pairs(fireOrb:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = v7[emitter.Parent.Name]
							end
						end

						local v8 = tick() + 1.6
						local numberValue2 = Instance.new("NumberValue")
						numberValue2.Value = 1
						TweenService:Create(
							numberValue2,
							TweenInfo.new(1.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Value = 0.3
							}
						):Play()

						repeat
							clone2:ScaleTo(numberValue2.Value)
							task.wait(0.016666666666666666)
						until v8 - tick() <= 0 or flag2 == false

						numberValue2:Destroy()

						if flag2 then
							clone2:ScaleTo(numberValue2.Value)
						end

						for _, emitter in pairs(fireOrb:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					else
						for _, emitter in pairs(fireOrb:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					end
				end)

				for _, emitter in pairs(fireOrb:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				local time3 = masterClock:GetTime()
				local lastTime = tick()
				local lastTime2 = tick()
				local v6 = false
				local v7 = false

				local function running()
					return masterClock:GetTime() - time3 < windUp or v3 and holdValue and holdValue.Value == true
				end

				if player.SuperCharge then
					task.delay(v2, function()
						if not v7 and clone then
							Util.Sound:Play("BF_V3_Dragon_Z_Activate_02", head)

							if v5 then
								sound:FadeOut(v5, 0.2)
								v5 = Util.Sound:Play(
									"Untransformed_Z_Hold_MaxPower_01",
									head,
									player.Hybrid and 12 or not player.Transformed and 8 or nil
								)
							end

							v6 = true
						end
					end)
				end

				task.spawn(function()
					local v8 = {}
					local v9 = {}

					for _, child in pairs(clone2.FireOrb.MouthFlames:GetChildren()) do
						for i = 0, 2 do
							local v10 = child["Attach" .. i]

							for _, beam in pairs(v10:GetChildren()) do
								if beam:IsA("Beam") then
									table.insert(v8, { beam.Width0, beam.Width1, beam })
								end
							end

							table.insert(v9, { i, v10 })
						end
					end

					local lastTime3 = os.clock()

					while true do
						local v10 = (os.clock() - lastTime3) * 1.5
						local v11 = 0.3 + 0.7 * ((os.clock() - lastTime3) / v2) ^ 0.75

						if v11 >= 1 then
							v11 = math.max(0, 1 - ((v11 - 1) * (v2 + 1.6)) ^ 0.75)
						end

						local v12 = 5 * v11 * 1.75
						local v13 = 30 * v11 * 2
						local v14 = 15 * v11 * 2.25

						for _, v15 in pairs(v8) do
							local v16 = v15[1]
							local v17 = v15[2]
							local v18 = v15[3]
							v18.Width0 = v16 * 3 * v11 * (math.sin(v10 * 1.2) * 0.3333333333333333 + 1)
							v18.Width1 = v17 * 3 * v11 * (math.cos(v10 * 1.2) * 0.3333333333333333 + 1)
						end

						for _, v15 in pairs(v9) do
							local v16 = v15[1]
							local v17 = v15[2]
							local v18 = v10 * 67.5

							if v16 == 0 then
								v17.Position = Vector3.new(v12, 0, 0)
								v17.Orientation = Vector3.new(0, v18, -v18)
							else
								local v19 = v16 == 1 and 1.25 or 1
								v17.Position = Vector3.new(
									v12 / 2,
									0,
									v13 * v19 * (math.sin(v10 * 1.2) * 0.3333333333333333 + 1)
								)
								v17.Orientation = Vector3.new(0, v18, -v18)
								v17.Beam.CurveSize0 = (math.sin(v10) * 0.5 + 1.5) * v14 / 2
								v17.Beam.CurveSize1 = -v17.Beam.CurveSize0

								if v16 == 2 then
									v17.Beam2.CurveSize0 = v17.Beam.CurveSize0
									v17.Beam2.CurveSize1 = v17.Beam.CurveSize0
								end
							end
						end

						task.wait()

						if flag2 ~= false then
							continue
						end

						Util.Debris:AddItem(clone2, 3)
						break
					end
				end)
				local clone3 = SUPERCHARGE.Transformed.RingBeamImpact:Clone()
				clone3.CFrame = head.CFrame
				Util.SetParentOverrideWithColor(clone3, fireOrb, player2, "DragonFruitVFXColor")
				clone3.Attachment.Particle_1:Emit(5)

				while (masterClock:GetTime() - time3 < windUp or v3 and holdValue and holdValue.Value == true) and head do
					local workspace2 = workspace

					if not head:IsDescendantOf(workspace2) or player.HoldValue.Parent == nil or player.HoldValue.Parent.Parent == nil then
						break
					end

					local v8 = (masterClock:GetTime() - time3) / v2
					local v9 = math.clamp(v8, 0, 1)
					clone3.CFrame = head.CFrame

					if clone then
						clone.Idle1.InLines.Squash = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 5 + -7 * v9, 0),
							NumberSequenceKeypoint.new(1, -1.8, 0)
						})
					end

					if v5 then
						v5.Pitch = 0.5 + 0.5 * v9
					end

					if tick() - lastTime > 0.3 then
						for _, emitter in pairs(clone.Idle1:GetChildren()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							if emitter.Name == "InLines" then
								if not v6 then
									emitter:Emit(emitter:GetAttribute("EmitCount"))
								end
							else
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						lastTime = tick()
					end

					if v6 and tick() - lastTime2 > 0.25 and v8 < v2 + 1.75 - 0.25 then
						for _, emitter in pairs(clone.Idle2:GetChildren()) do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						lastTime2 = tick()
					end

					local cFrame2 = head.CFrame * offset
					clone.CFrame = cFrame2
					fireOrb.CFrame = cFrame2
					RunService.RenderStepped:Wait()
				end

				flag2 = false
				TweenService:Create(clone.Idle1.Light, TweenInfo.new(0.3), {
					Brightness = 0
				}):Play()
				task.spawn(function()
					for _, effect in pairs(fireOrb:GetDescendants()) do
						if effect:IsA("ParticleEmitter") then
							effect.Enabled = false
						elseif effect:IsA("Beam") then
							TweenService:Create(effect, TweenInfo.new(0.25 + math.random(50, 150) / 250), {
								Width0 = 0,
								Width1 = 0,
								CurveSize0 = 0,
								CurveSize1 = 0
							}):Play()
							local v8 = effect
							task.spawn(function()
								task.wait(1)
								v8.Enabled = false
							end)
						elseif effect.Name == "Attach1" or effect.Name == "Attach2" then
							TweenService:Create(effect, TweenInfo.new(0.15 + math.random(50, 150) / 250), {
								Position = effect.Parent.Attach0.Position
							}):Play()
						end
					end

					task.wait(3)

					if fireOrb then
						fireOrb:Destroy()
					end
				end)

				if v5 then
					Util.Sound:FadeOut(v5, 0.1)
				end

				TweenService:Create(clone, TweenInfo.new(0.1), {
					Transparency = 1
				}):Play()

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				Util.Debris:AddItem(clone, 5)
				v7 = true
			else
				local clone = nil

				if player.Hybrid then
					task.spawn(function()
						local humanoidRootPart = player.Humanoid.Parent:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart then
							local ray, v6, _ = Util.Ray(
								humanoidRootPart.Position,
								-(CFrame.new(humanoidRootPart.Position).upVector.Unit * (humanoidRootPart.Size.Y / 2) + createVector(
									0,
									10,
									0
								)),
								{ workspace.Characters, workspace.Enemies },
								false
							)
							CFrame.new(humanoidRootPart.Position - Vector3.new(0, humanoidRootPart.Size.Y / 2 + 3, 0))

							if ray then
								local cframe = CFrame.new(v6 + createVector(0, 2.5, 0))
								clone = Z.Extra.GroundBurn:Clone()
								debris:AddItem(clone, 60)
								clone.CFrame = cframe
								Util.SetParentOverrideWithColor(clone, _WorldOrigin, player2, "DragonFruitVFXColor")

								for _, emitter in pairs(clone:GetDescendants()) do
									if not emitter:IsA("ParticleEmitter") then
										continue
									end

									local v7 = emitter
									task.spawn(function()
										v7.Rate *= 2
										v7.Enabled = true
									end)
								end
							end
						end
					end)
				end

				local clone2 = SUPERCHARGE.HeatwaveCharge:Clone()
				clone2.CFrame = cFrame
				Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player2, "DragonFruitVFXColor")

				for _, emitter in pairs(clone2.Start:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				local clone3 = SUPERCHARGE.MouthFlame:Clone()
				clone3.PrimaryPart.CFrame = cFrame
				Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player2, "DragonFruitVFXColor")
				local clone4 = SUPERCHARGE.FlameAura:Clone()
				clone4.CFrame = cFrame * CFrame.new(0, -1.5, 0)
				Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player2, "DragonFruitVFXColor")
				local clone5 = SUPERCHARGE.FlameAura2:Clone()
				clone5.CFrame = cFrame * CFrame.new(0, -3, 0)
				Util.SetParentOverrideWithColor(clone5, clone4, player2, "DragonFruitVFXColor")

				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				local time3 = masterClock:GetTime()
				local lastTime = tick()
				local lastTime2 = tick()
				local v6 = false
				local v7 = false

				local function running()
					return masterClock:GetTime() - time3 < windUp or v3 and holdValue and holdValue.Value == true
				end

				local colorSequence = ColorSequence.new(
					Util.WrapColor3Constructor(Color3.fromRGB(255, 126, 21), player2, "DragonFruitVFXColor"),
					Util.WrapColor3Constructor(Color3.fromRGB(255, 55, 15), player2, "DragonFruitVFXColor")
				)
				task.spawn(function()
					local v8 = charge / 4

					for i = 1, 4 do
						task.wait(v8)

						if not (masterClock:GetTime() - time3 < windUp) and (not v3 or not holdValue or holdValue.Value ~= true) then
							break
						end

						local v9 = nil
						local cframe = CFrame.new(0, 0, 0)

						if i == 1 then
							v9 = 0.75
							cframe = CFrame.new(0, 0, -1)
							colorSequence = ColorSequence.new(
								Util.WrapColor3Constructor(Color3.fromRGB(255, 94, 20), player2, "DragonFruitVFXColor"),
								Util.WrapColor3Constructor(Color3.fromRGB(255, 55, 15), player2, "DragonFruitVFXColor")
							)
						elseif i == 2 then
							v9 = 1
							cframe = CFrame.new(0, 0, -1.5)
							colorSequence = ColorSequence.new(
								Util.WrapColor3Constructor(Color3.fromRGB(255, 55, 20), player2, "DragonFruitVFXColor"),
								Util.WrapColor3Constructor(Color3.fromRGB(255, 28, 43), player2, "DragonFruitVFXColor")
							)
						elseif i == 3 then
							v9 = 1.25
							cframe = CFrame.new(0, 0, -3)
							colorSequence = ColorSequence.new(
								Util.WrapColor3Constructor(Color3.fromRGB(255, 52, 25), player2, "DragonFruitVFXColor"),
								Util.WrapColor3Constructor(Color3.fromRGB(255, 39, 53), player2, "DragonFruitVFXColor")
							)
						elseif i == 4 then
							v9 = 1.5
							cframe = CFrame.new(0, 0, -5)
							colorSequence = ColorSequence.new(
								Util.WrapColor3Constructor(Color3.fromRGB(255, 41, 80), player2, "DragonFruitVFXColor"),
								Util.WrapColor3Constructor(Color3.fromRGB(255, 67, 30), player2, "DragonFruitVFXColor")
							)
						end

						local clone6 = SUPERCHARGE.MouthFlame2:Clone()
						clone6.PrimaryPart.CFrame = cFrame
						clone6:ScaleTo(v9)
						Util.SetParentOverrideWithColor(clone6, clone3, player2, "DragonFruitVFXColor")
						local weld = clone6.PrimaryPart.Weld
						weld.Part0 = head
						weld.C0 = cframe
						clone6.PrimaryPart.Attachment.Orientation = Vector3.new(
							math.random(-90, 90),
							math.random(-90, 90),
							math.random(-90, 90)
						)
					end
				end)

				if player.SuperCharge then
					task.delay(v2, function()
						if not v7 and clone2 then
							Util.Sound:Play("BF_V3_Dragon_Z_Activate_02", head)
							v6 = true
						end
					end)
				end

				local v8 = true
				task.spawn(function()
					local holdTrails = SUPERCHARGE.HoldTrails
					local count = #holdTrails:GetChildren()

					repeat
						task.spawn(function()
							local position2 = head.Position
							local v9 = math.random(1, count)
							local clone6 = holdTrails["Trail" .. tostring(v9)]:Clone()
							clone6.CFrame = cFrame * CFrame.new(
								math.random(-25, 25),
								math.random(2, 10),
								math.random(-25, -15)
							)
							Util.SetParentOverrideWithColor(clone6, _WorldOrigin, player2, "DragonFruitVFXColor")
							clone6.Attach1.Trail.Color = colorSequence
							local position3 = clone6.Position
							local magnitude = (position3 - position2).Magnitude
							clone6.CFrame = CFrame.new(position3, position2)
							local v10 = (position3 - position2) / 2
							local position4 = CFrame.new(CFrame.new(position3) * (v10 / -1.5)).Position
							local position5 = CFrame.new(CFrame.new(position2) * (v10 / 1.5)).Position
							local halfMagnitude = magnitude / 2
							local v12 = position4 + Vector3.new(
								math.random(-halfMagnitude, halfMagnitude),
								math.random(-halfMagnitude / 2, halfMagnitude),
								math.random(-halfMagnitude, halfMagnitude)
							)
							local v13 = position5 + Vector3.new(
								math.random(-halfMagnitude, halfMagnitude),
								math.random(-halfMagnitude / 2, halfMagnitude),
								math.random(-halfMagnitude, halfMagnitude)
							)
							local v14 = math.random(10, 20) / 10
							local lastTime3 = tick()
							local v15 = magnitude / v14 / 60

							while tick() - lastTime3 < v15 do
								local v16 = (tick() - lastTime3) / v15
								local v17 = cubicBezier(v16, position3, v12, v13, position2)
								clone6.CFrame = clone6.CFrame:Lerp(CFrame.new(v17, position2), v16)
								RunService.Heartbeat:Wait()
							end

							for _, emitter in pairs(clone6:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end

							Util.Debris:AddItem(clone6, 1)
						end)
						task.wait(0.1)
					until v8 == false

					if clone then
						for _, emitter in pairs(clone:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						task.delay(5, function()
							clone:Destroy()
						end)
					end
				end)

				while (masterClock:GetTime() - time3 < windUp or v3 and holdValue and holdValue.Value == true) and head do
					local workspace2 = workspace

					if not head:IsDescendantOf(workspace2) or player.HoldValue.Parent == nil or player.HoldValue.Parent.Parent == nil then
						break
					end

					local v9 = math.clamp((masterClock:GetTime() - time3) / v2, 0, 1)

					if clone2 then
						clone2.Idle1.InLines.Squash = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 5 + -7 * v9, 0),
							NumberSequenceKeypoint.new(1, -1.8, 0)
						})
					end

					if v5 then
						v5.Pitch = 0.5 + 0.5 * v9
					end

					if tick() - lastTime > 0.3 then
						for _, emitter in pairs(clone2.Idle1:GetChildren()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							if emitter.Name == "InLines" then
								if not v6 then
									emitter:Emit(emitter:GetAttribute("EmitCount"))
								end
							else
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						lastTime = tick()
					end

					if v6 and tick() - lastTime2 > 0.4 then
						for _, emitter in pairs(clone2.Idle2:GetChildren()) do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						lastTime2 = tick()
					end

					cFrame = head.CFrame * offset
					clone2.CFrame = cFrame
					clone3.PrimaryPart.CFrame = cFrame
					RunService.RenderStepped:Wait()
				end

				v8 = false
				TweenService:Create(clone2.Idle1.Light, TweenInfo.new(0.3), {
					Brightness = 0
				}):Play()

				if v5 then
					Util.Sound:FadeOut(v5, 0.1)
				end

				TweenService:Create(clone2, TweenInfo.new(0.1), {
					Transparency = 1
				}):Play()

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				Util.Debris:AddItem(clone2, 5)
				Util.Debris:AddItem(clone3, 5)
				Util.Debris:AddItem(clone4, 5)
				v7 = true
			end

			if flag then
				task.delay(2.5, function()
					head:Destroy()
				end)
			end
		end
	elseif ID == 2 then
		local cFrame = player.CFrame
		local cframe

		if player.dragonModel then
			local tongue3 = player.dragonModel.RootPart:FindFirstChild("Tongue3", true) or nil
			local inverse = (CFrame.lookAt(createVector(0, 0, 0), createVector(0, 1, 0)):Inverse() * CFrame.Angles(
				0,
				4.71238898038469,
				0
			)):Inverse()
			local v2 = tongue3.WorldCFrame * inverse * v
			local v3 = v2.p - cFrame.p
			local _, v4 = Util.RayMap(cFrame.p, v3)
			local v5 = CFrame.new(v4 - v3.Unit * 0.01) * (v2 - v2.Position)
			local v6 = CFrame.lookAt(player.CFrame.Position, player.ExplosionPosition).Rotation + (v5 * player.Offset).Position
			cframe = CFrame.lookAt(v6.Position, player.ExplosionPosition)
			player.CFrame = cframe
		else
			cframe = CFrame.new(player.Head.Position, player.ExplosionPosition) * player.Offset
			player.CFrame = cframe
		end

		local magnitude = (player.CFrame.p - player.ExplosionPosition).Magnitude
		local magnitude2 = (workspace.CurrentCamera.CFrame.p - cframe.p).Magnitude

		if magnitude + 500 < magnitude2 then
			return
		end

		local v2 = player.Character == game.Players.LocalPlayer.Character and 2 or 1
		local position = player.CFrame.Position
		local v3 = 25 * v2 * (player.Transformed and 10 or 1)
		local character = game.Players.LocalPlayer.Character
		local v4

		if character == nil then
			v4 = false
		else
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			v4 = humanoidRootPart and (humanoidRootPart.Position - position).magnitude <= v3 and true or false
		end

		if v4 then
			Util.CameraShaker:ShakeOnce(
				5 * (player.Transformed and 2 or 1),
				15 * (player.Transformed and 2 or 1),
				0.2,
				0.5 * (player.Transformed and 2 or 1)
			)
		end

		local v5 = Util.Sound:Play("BF_V3_Dragon_Z_Fire_01", cframe.Position, player.dragonModel and 60 or 10)

		if player.chargeTime then
			v5.PlaybackSpeed = 1 - 0.4 * player.chargeTime
		end

		Util.DestroyAfter(v5, 10)
		local clone = SUPERCHARGE.DashWind:Clone()
		Util.Debris:AddItem(clone, 2)
		clone.CFrame = cframe
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player2, "DragonFruitVFXColor")
		local ray, v6, _ = Util.Ray(
			cframe.Position,
			CFrame.new(cframe.Position).UpVector.Unit * -15,
			{ workspace.Characters, workspace.Enemies },
			false
		)
		local v7 = cframe * CFrame.new(0, 0, -5)

		if ray then
			clone.CFrame = CFrame.new(v6, (Vector3.new(v7.X, v6.Y, v7.Z)))

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				scaleParticle(emitter, player.Scale + 1)
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		task.spawn(function()
			beamProjectile(SUPERCHARGE, {
				CFrame = player.CFrame,
				SpawnTime = player.SpawnTime,
				Life = player.Life,
				Distance = player.Distance,
				ExplosionPosition = player.ExplosionPosition,
				Scale = player.Scale,
				SuperCharge = player.SuperCharge,
				Character = player.Character,
				RayData = player.RayData
			}, player.chargeTime, player2)
		end)
		local clone2 = SUPERCHARGE.BeamFire:Clone()
		debris:AddItem(clone2, 2)
		clone2.CFrame = cframe
		Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player2, "DragonFruitVFXColor")

		for _, child in pairs(clone2.Attachment:GetChildren()) do
			scaleParticle(child, player.Scale)
			child:Emit(child:GetAttribute("EmitCount"))
		end

		for _ = 0, 8 do
			local v8 = math.random(3, 5) * player.Scale
			local v9 = math.random(10, 15) * player.Scale
			local v10 = { math.random(-55, -25) * player.Scale, math.random(25, 55) * player.Scale }
			local v11 = { math.random(-55, -25) * player.Scale, math.random(25, 55) * player.Scale }
			local v12 = { math.random(-55, -25) * player.Scale, math.random(25, 55) * player.Scale }
			emberBlob(math.random(5, 15) / 10, 8, 1, {
				CFrame = player.CFrame * CFrame.Angles(
					math.rad(v10[math.random(1, #v10)]),
					math.rad(v11[math.random(1, #v11)]),
					(math.rad(v12[math.random(1, #v12)]))
				),
				Color = Util.WrapColor3Constructor(Color3.fromRGB(188, 155, 93), player2, "DragonFruitVFXColor"),
				Size = Vector3.new(v8, v8, v9)
			}, player2)
		end
	end
end