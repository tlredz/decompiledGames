local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage.FX)
local _ = Util.Sound
local masterClock = Util.MasterClock
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback()
		end
	end
end

local function purpleVision()
	local Lighting = game:GetService("Lighting")

	if not Lighting:FindFirstChild("PurpleSlashTint") then
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		Util.Debris:AddItem(colorCorrectionEffect, 5)
		colorCorrectionEffect.Parent = game:GetService("Lighting")
		colorCorrectionEffect.Name = "PurpleSlashTint"
		local tween = TweenService:Create(
			colorCorrectionEffect,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
			{
				Brightness = 0.3,
				Contrast = 0.3,
				Saturation = 1,
				TintColor = Color3.fromRGB(158, 46, 255)
			}
		)
		tween.Completed:Connect(function()
			colorCorrectionEffect:Destroy()
		end)
		tween:Play()
	end
end

local function hitExplosion(cFrame)
	local clone = FX:WaitForChild("Weapons").PurpleDash:Clone()
	Util.Debris:AddItem(clone, 2)
	local ring = clone.Ring

	for _ = 1, 3 do
		local clone2 = ring:Clone()
		Util.Debris:AddItem(clone2, 2)
		clone2.CFrame = CFrame.new(cFrame.p) * CFrame.Angles(
			math.rad((math.random(-90, 90))),
			math.rad((math.random(-90, 90))),
			(math.rad((math.random(-90, 90))))
		)
		clone2.Parent = _WorldOrigin
		local tween = TweenService:Create(
			clone2,
			TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Size = Vector3.new(clone2.Size.X * 3, 0, clone2.Size.X * 3),
				CFrame = clone2.CFrame * CFrame.Angles(0, 3.0543261909900767, 0),
				Transparency = 1,
				Color = Color3.fromRGB(144, 65, 255)
			}
		)
		tween.Completed:Connect(function()
			clone2:Destroy()
		end)
		tween:Play()
		wait(0.05)
	end

	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 3)
	part.Size = createVector(25, 25, 25)
	part.Anchored = true
	part.CanCollide = false
	part.Shape = Enum.PartType.Ball
	part.Transparency = 1
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxassetid://243098098"
	particleEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(214, 46, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(214, 46, 255))
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.614, 0.238),
		NumberSequenceKeypoint.new(0.843, 0.488),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.522, 2.85, 1.45),
		NumberSequenceKeypoint.new(1, 2.5)
	})
	particleEmitter.LightEmission = 1
	particleEmitter.ZOffset = 2
	particleEmitter.Drag = 20
	particleEmitter.Speed = NumberRange.new(30)
	particleEmitter.Rate = 500
	particleEmitter.SpreadAngle = Vector2.new(360, 360)
	particleEmitter.RotSpeed = NumberRange.new(999, 9999)
	particleEmitter.Lifetime = NumberRange.new(0.25)
	particleEmitter.Parent = part
	local particleEmitter2 = Instance.new("ParticleEmitter")
	particleEmitter2.Texture = "rbxassetid://2812352733"
	particleEmitter2.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(78, 29, 127)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(78, 29, 127))
	})
	particleEmitter2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.614, 0.238),
		NumberSequenceKeypoint.new(0.843, 0.488),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter2.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.504, 8.55, 1.45),
		NumberSequenceKeypoint.new(1, 2.5)
	})
	particleEmitter2.LightEmission = 0.85
	particleEmitter2.ZOffset = 0
	particleEmitter2.Speed = NumberRange.new(15)
	particleEmitter2.Rate = 15
	particleEmitter2.SpreadAngle = Vector2.new(-90, 360)
	particleEmitter2.RotSpeed = NumberRange.new(360)
	particleEmitter2.Lifetime = NumberRange.new(0.4)
	particleEmitter2.Enabled = false
	particleEmitter2.Parent = part
	local particleEmitter3 = Instance.new("ParticleEmitter")
	particleEmitter3.Texture = "rbxassetid://1690541156"
	particleEmitter3.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.15, Color3.fromRGB(135, 55, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(147, 74, 255))
	})
	particleEmitter3.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.054, 0.246),
		NumberSequenceKeypoint.new(0.23, 0.0273),
		NumberSequenceKeypoint.new(0.524, 0.0492),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter3.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 5.65),
		NumberSequenceKeypoint.new(0.0612, 1.45, 0.637),
		NumberSequenceKeypoint.new(0.179, 1.15, 0.6),
		NumberSequenceKeypoint.new(0.325, 0.75, 0.219),
		NumberSequenceKeypoint.new(1, 0)
	})
	particleEmitter3.LightEmission = 1
	particleEmitter3.Drag = 6
	particleEmitter3.Acceleration = createVector(0, -45, 0)
	particleEmitter3.Speed = NumberRange.new(100)
	particleEmitter3.Rate = 25
	particleEmitter3.SpreadAngle = Vector2.new(-90, 90)
	particleEmitter3.RotSpeed = NumberRange.new(-1500, 1500)
	particleEmitter3.Lifetime = NumberRange.new(3)
	particleEmitter3.Enabled = false
	particleEmitter3.Parent = part
	particleEmitter3:Emit(math.random(10, 15))
	particleEmitter2:Emit(math.random(2, 3))
	spawn(function()
		wait(0.5)
		particleEmitter.Enabled = false
	end)
	part.CFrame = cFrame
	part.Parent = _WorldOrigin
	local p = cFrame.p
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= 35 then
			Util.CameraShaker:ShakeOnce(5, 15, 0.2, 0.5)
			purpleVision()
		end
	end
end

local function slashProjectile(cFrame, positionObject, timestamp, lifetime, distance)
	Util.Sound:Play("Buddha_slam", cFrame.p, nil, 2 + math.random(-10, 10) / 100, 0.2)
	Util.Sound:Play("QuickSlice", cFrame.p, nil, 1.7 + math.random(-10, 10) / 100, 0.5)
	local clone = FX:WaitForChild("Weapons").PurpleSlash:Clone()
	Util.Debris:AddItem(clone, lifetime + 5)
	local miniBlobs = clone.Slash2.MiniBlobs
	local slashBeams = clone.SlashBeams
	local movementTrail = slashBeams.MovementTrail
	miniBlobs.Enabled = true
	movementTrail.Enabled = true
	clone.Parent = _WorldOrigin
	Util.Sound:Play("KiDashLoop", slashBeams, nil, 2 + math.random(-10, 10) / 100, 0.25)
	local v = masterClock:GetTime() - timestamp
	local _ = cFrame.lookVector
	local value = false
	positionObject.Changed:Connect(function()
		value = positionObject.Value
	end)
	local lastTime = tick()
	tick()
	local v2 = cFrame
	local v3 = v2
	v2 = v3

	while tick() - lastTime + v < lifetime do
		local _ = (tick() - lastTime + v) / lifetime
		local v5 = (tick() - lastTime + v) / 100 / (lifetime / 100)
		local lerped = cFrame:Lerp(cFrame * CFrame.new(0, 0, -distance), v5)
		clone:SetPrimaryPartCFrame(lerped)
		local magnitude = (v3.p - lerped.p).Magnitude
		local ray, _, _ = Util.Ray(
			v3.p,
			v3.lookVector.Unit * magnitude,
			{ workspace.Characters, workspace.Enemies },
			false
		)

		if value or ray then
			v2 = v3
			break
		end

		RunService.RenderStepped:Wait()
		v2 = v3
		v3 = lerped
	end

	if clone then
		local v5 = Util.Sound:Play("Buddha_ex", v2.p, nil, 1.1 + math.random(-25, 25) / 100, 0.25)
		Util.Sound:Play("Lightning1", v2.p, nil, 1.8 + math.random(-15, 15) / 100, 0.25)
		Util.Sound:Play("ShortExplosion2", v2.p, nil, 1 + math.random(-20, 20) / 100, 0.5)
		TweenService:Create(v5, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
			Pitch = math.random(5, 6) / 10
		}):Play()
		local part = Instance.new("Part")
		Util.Debris:AddItem(part, 5)
		part.Size = createVector(0.05, 0.05, 0.05)
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		part.Position = v2.p
		part.Parent = _WorldOrigin
		miniBlobs.Parent = part
		movementTrail.Parent = part
		miniBlobs.Enabled = false
		movementTrail.Enabled = false
		clone:Destroy()
	end

	hitExplosion(v2)
end

return function(data)
	local stage = data.Stage or 1

	if stage == 1 then
		local cFrame = data.CFrame
		Util.Sound:Play("Leap", cFrame, nil, 1.3 + math.random(-22, 22) / 100, 0.8)

		for i = 1, 5 do
			local cFrame2 = cFrame * CFrame.new(0, 0, -i * 10)
			local clone = FX:WaitForChild("Weapons").PurpleDash:Clone()
			Util.Debris:AddItem(clone, 1)
			local shockwave = clone.Shockwave
			Util.Debris:AddItem(shockwave, 2)
			shockwave.Size = createVector(3, 5.419, 3)
			shockwave.CFrame = cFrame2 * CFrame.Angles(1.57, 0, 0)
			shockwave.Parent = _WorldOrigin
			clone:Destroy()
			local tween = TweenService:Create(
				shockwave,
				TweenInfo.new(0.4 - i / 15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(40, 0.1, 40) * (1 - i / 20),
					CFrame = shockwave.CFrame * CFrame.new(0, 0, 0),
					Transparency = 1
				}
			)
			tween.Completed:Connect(function()
				shockwave:Destroy()
			end)
			tween:Play()
			local part = Instance.new("Part")
			Util.Debris:AddItem(part, 3)
			part.Size = createVector(8, 8, 8)
			part.Anchored = true
			part.CanCollide = false
			part.Shape = Enum.PartType.Ball
			part.Transparency = 1
			local particleEmitter = Instance.new("ParticleEmitter")
			particleEmitter.Texture = "rbxassetid://1690541156"
			particleEmitter.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(0.15, Color3.fromRGB(135, 55, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(147, 74, 255))
			})
			particleEmitter.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.054, 0.246),
				NumberSequenceKeypoint.new(0.23, 0.0273),
				NumberSequenceKeypoint.new(0.524, 0.0492),
				NumberSequenceKeypoint.new(1, 1)
			})
			particleEmitter.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 5.65),
				NumberSequenceKeypoint.new(0.0612, 1.45, 0.637),
				NumberSequenceKeypoint.new(0.179, 1.15, 0.6),
				NumberSequenceKeypoint.new(0.325, 0.75, 0.219),
				NumberSequenceKeypoint.new(1, 0)
			})
			particleEmitter.LightEmission = 1
			particleEmitter.Drag = 6
			particleEmitter.Acceleration = createVector(0, -45, 0)
			particleEmitter.Speed = NumberRange.new(75)
			particleEmitter.Rate = 25
			particleEmitter.SpreadAngle = Vector2.new(-90, 90)
			particleEmitter.RotSpeed = NumberRange.new(-1000, 1000)
			particleEmitter.Lifetime = NumberRange.new(2, 3)
			particleEmitter.Enabled = false
			particleEmitter.Parent = part
			part.CFrame = cFrame2
			part.Parent = _WorldOrigin
			particleEmitter:Emit(10)
		end
	elseif stage == 2 then
		local cFrame = data.CFrame

		if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
			return
		end

		local lifetime = data.Lifetime
		local distance = data.Distance
		slashProjectile(cFrame, data.PositionObject, data.Timestamp, lifetime, distance)
	end
end