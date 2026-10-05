local createVector = vector.create
game:GetService("Players")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local debree = workspace.Debree
local assets = script:FindFirstChild("Assets")
script:FindFirstChild("Sounds")
script:FindFirstChild("Rigs")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local CraterExtension = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.CraterExtension)
local TokenKit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Token.TokenKit)
local BezierModule = require(ReplicatedStorage.CAM.Client.Modules.Effects.BezierModule)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local ImpactFrames = require(ReplicatedStorage.CAM.Client.Modules.Effects.ImpactFrames)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local localPlayer = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include

local function EmitAll(folder, color: Color3?)
	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if color and emitter.Name == "DustRaycast" then
			emitter.Color = ColorSequence.new(color)
		end

		local v = emitter
		task.delay(emitter:GetAttribute("EmitDelay") or 0, function()
			v:Emit(v:GetAttribute("EmitCount") or 30)
		end)
	end
end

function Toggle(folder, flag: boolean?)
	for _, descendant in folder:GetDescendants() do
		if descendant.ClassName == "ParticleEmitter" or descendant.ClassName == "Beam" or descendant.ClassName == "PointLight" or descendant.ClassName == "Trail" then
			descendant.Enabled = flag or false
		end
	end
end

function BlurEffect(value)
	local blurEffect = Instance.new("BlurEffect")
	local lighting = game.Lighting
	blurEffect.Size = 5
	blurEffect.Parent = lighting
	DebrisModule:AddItem(blurEffect, value or 0.08333333333333333)
end

function Weld(p, part)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = p
	weldConstraint.Part1 = part
	weldConstraint.Parent = p
	return weldConstraint
end

return function(instance, p: string, parent, _, instance2)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart
	instance:FindFirstChild("UpperTorso")

	if p ~= "Cancel" and (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	local name = string.format("%s Koketsu arrow effects", instance.Name)
	local parent3 = debree:FindFirstChild(name)

	if p == "Startup" then
		if parent3 ~= nil then
			parent3:Destroy()
		end

		parent3 = Instance.new("Folder")
		parent3.Name = name
		parent3.Parent = debree
		DebrisModule:AddItem(parent3, 10)
	end

	local v3 = { instance, parent }

	if parent3 == nil then
		return
	end

	if p == "Startup" then
		local part

		if typeof(parent) == "Instance" then
			part = parent
		end

		if not (part and part:IsA("BasePart")) then
			part = workspace.Debree.Projectiles:WaitForChild(`{instance.Name} - Koketsu Arrow`, 2)
		end

		if part == nil then
			return
		end

		local clone = assets.Projectile:Clone()
		clone.Parent = parent3
		local clone2 = script.Sounds.PS2arrowULTattempt:Clone()
		clone2.Parent = clone.PrimaryPart
		clone2:Play()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0.98583984375, -0.09681105613708496, -5.2540283203125) * CFrame.fromEulerAnglesYXZ(
			0.001424319576472044,
			0.012316026724874973,
			-1.6016160249710083
		))
		local weld = Instance.new("Weld")
		weld.Part0 = part
		weld.Part1 = clone.PrimaryPart
		weld.Parent = clone.PrimaryPart
		local clone3 = assets.SkillInitialFX:Clone()
		clone3.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -1, 0)
		clone3.Parent = parent3
		EmitAll(clone3)
		EmitAll(clone)
		DebrisModule:AddItem(clone3, 2)
		task.wait(0.5)
		Toggle(clone, false)

		for _, descendant in ipairs(clone:GetDescendants()) do
			if descendant.ClassName == "Trail" then
				descendant.Enabled = false
			end

			if descendant.ClassName == "Decal" then
				TweenService:Create(descendant, TweenInfo.new(0.1), {
					Transparency = 1
				}):Play()
			end
		end
	end

	if p == "Start" then
		if parent.Parent == nil then
			return
		end

		local upperTorso = parent:FindFirstChild("UpperTorso")
		local humanoidRootPart2 = parent:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart2 == nil or upperTorso == nil then
			return
		end

		local clone = assets.UpperTorso:Clone()
		clone.Parent = parent3
		local projectile = parent3:FindFirstChild("Projectile", 0.25)

		if projectile ~= nil then
			projectile:Destroy()
		end

		local weld = Instance.new("Weld")
		weld.Part0 = clone
		weld.Part1 = upperTorso
		weld.Parent = clone
		DebrisModule:AddItem(clone, 3)
		DebrisModule:AddItem(clone.Rush, 2.5)

		for _, descendant in ipairs(clone:GetDescendants()) do
			if descendant.ClassName == "Trail" then
				descendant.Lifetime = 0.35
			end
		end

		task.delay(0.35, function()
			local clone2 = assets.ArrowModel3:Clone()
			clone2:PivotTo(humanoidRootPart.CFrame * CFrame.new(
				15.0086669921875,
				0.060420989990234375,
				0.68927001953125
			) * CFrame.fromEulerAnglesYXZ(0.32804620265960693, -0.3494413197040558, -0.6040559411048889))
			clone2.Parent = parent3
			DebrisModule:AddItem(clone2, 1.4)
			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position,
				humanoidRootPart.CFrame.LookVector * 20,
				raycastParams
			)
			local v4

			if raycastResult then
				v4 = raycastResult.Position
			else
				v4 = (humanoidRootPart.CFrame * CFrame.new(-2, 20, -40)).Position
			end

			local v5 = BezierModule.new({ clone2.PrimaryPart.Position, v4 })
			v5:CreatePoint(CFrame.new(v5:GetDistance() / 15, v5:GetDistance() / -4, v5:GetDistance() / 5))
			task.wait(0.06999999999999999)
			v5.Speed = 30
			v5:Play(function(position)
				if clone2 == nil or clone2.Parent == nil then
					return true
				end

				clone2.PrimaryPart.CFrame = CFrame.new(position)
			end)
		end)
		task.delay(0.35, function()
			local clone2 = assets.ArrowModel3:Clone()
			clone2:PivotTo(humanoidRootPart.CFrame * CFrame.new(
				-15.1329345703125,
				-0.8270683288574219,
				-1.1129150390625
			) * CFrame.fromEulerAnglesYXZ(0.22519375383853912, -0.03930621221661568, 0.3720952272415161))
			clone2.Parent = parent3
			DebrisModule:AddItem(clone2, 1.4)
			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position,
				humanoidRootPart.CFrame.LookVector * 20,
				raycastParams
			)
			local v4

			if raycastResult then
				v4 = raycastResult.Position
			else
				v4 = (humanoidRootPart.CFrame * CFrame.new(2, 20, -40)).Position
			end

			local v5 = BezierModule.new({ clone2.PrimaryPart.Position, v4 })
			v5:CreatePoint(CFrame.new(v5:GetDistance() / -15, v5:GetDistance() / -4, v5:GetDistance() / 5))
			task.wait(0.06999999999999999)
			v5.Speed = 30
			v5:Play(function(position)
				if clone2 == nil or clone2.Parent == nil then
					return true
				end

				clone2.PrimaryPart.CFrame = CFrame.new(position)
			end)
		end)
		task.wait(0.7)
		task.wait(0.735)
		local clone2 = assets.EnemyRoot:Clone()
		clone2.Parent = parent3
		clone2.CFrame = humanoidRootPart2.CFrame
		local raycastResult = workspace:Raycast(
			clone2.Position + createVector(0, 1, 0),
			createVector(-0, -5, -0),
			raycastParams
		)

		if raycastResult then
			EmitAll(clone2, raycastResult.Instance.Color)
		else
			EmitAll(clone2)
		end

		DebrisModule:AddItem(clone2, 3)
	end

	if p == "ArrowStorm" then
		local humanoidRootPart2 = parent:FindFirstChild("HumanoidRootPart")
		local upperTorso = parent:FindFirstChild("UpperTorso") or parent:FindFirstChild("LowerTorso") or humanoidRootPart2

		if humanoidRootPart2 == nil then
			return
		end

		local v4 = {
			{
				cf = CFrame.new(17.0841064453125, 14.256473541259766, -46.21337890625) * CFrame.fromEulerAnglesYXZ(
					-0.08562701940536499,
					2.022969961166382,
					-2.0005548000335693
				),
				distance = 30,
				tweenTime = 0.15,
				delay = 0.2,
				waitTime = 0.3
			},
			{
				cf = CFrame.new(-5.3184814453125, 5.971668243408203, -39.50653076171875) * CFrame.fromEulerAnglesYXZ(
					0.7162882685661316,
					-1.7344743013381958,
					1.3687057495117188
				),
				distance = 30,
				tweenTime = 0.15,
				delay = 0.2,
				waitTime = 0.4
			},
			{
				cf = CFrame.new(-7.9437255859375, 25.817575454711914, -32.94549560546875) * CFrame.fromEulerAnglesYXZ(
					-1.0492197275161743,
					-1.177425503730774,
					1.2400262355804443
				),
				distance = 50,
				tweenTime = 0.25,
				delay = 0.3,
				waitTime = 0.2
			}
		}

		local function spawnArrow(parent2, data)
			local humanoidRootPart3 = parent2:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart3 == nil then
				return
			end

			local clone = assets.ArrowModel:Clone()
			clone.Parent = parent3
			clone:PivotTo(humanoidRootPart3.CFrame * data.cf)
			DebrisModule:AddItem(clone, 0.5)

			for _, descendant in ipairs(clone:GetDescendants()) do
				if descendant.ClassName == "Trail" then
					descendant.Enabled = true
				end

				if descendant.ClassName == "Decal" then
					descendant.Transparency = 0
				end
			end

			TweenService:Create(clone.PrimaryPart, TweenInfo.new(data.tweenTime), {
				CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, -data.distance)
			}):Play()
			task.delay(data.delay, function()
				for _, descendant in ipairs(clone:GetDescendants()) do
					if descendant.ClassName == "Trail" then
						descendant.Enabled = false
					end

					if descendant.ClassName == "Decal" then
						TweenService:Create(descendant, TweenInfo.new(0.1), {
							Transparency = 1
						}):Play()
					end
				end
			end)
		end

		for _, v5 in ipairs(v4) do
			spawnArrow(parent, v5)
			task.wait(v5.waitTime)
		end

		local clone = assets.UpperTorso:Clone()
		clone.Parent = parent3
		clone.Rush:Destroy()
		local weld = Instance.new("Weld")
		weld.Part0 = clone
		weld.Part1 = upperTorso
		weld.Parent = clone
		task.delay(2, function()
			for _, descendant in ipairs(clone:GetDescendants()) do
				if descendant.ClassName == "Trail" then
					descendant.Lifetime = 0.5
				end
			end
		end)
		DebrisModule:AddItem(clone, 3)
	end

	if p == "Impact1" then
		local clone = assets.Explosion:Clone()
		clone.Parent = parent3
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(6.2952880859375, -2.308598279953003, -44.98162841796875)
		local raycastResult = workspace:Raycast(
			clone.Position + createVector(0, 1, 0),
			createVector(-0, -5, -0),
			raycastParams
		)

		if raycastResult then
			EmitAll(clone, raycastResult.Instance.Color)
		else
			EmitAll(clone)
		end

		DebrisModule:AddItem(clone, 3)
		CraterExtension.Ground(clone.Position, 11, createVector(1.5, 2.5, 2), nil, 2, false, 2)
		CraterExtension.Ground(clone.Position, 12, createVector(1.5, 1.5, 2), nil, 5, false, 2)
		BlurEffect(0.2)
		task.spawn(TokenKit.GroundRocks, {
			CF = clone.CFrame,
			InnerRadius = 5,
			OuterRadius = 21,
			Velocity = {
				Min = 20,
				Max = 40
			},
			Size = {
				Min = 0.5,
				Max = 1
			}
		})
		Cam_Shaker(clone.Position, {
			FadeInTime = 0,
			Frequency = 0.2,
			Amplitude = 0.3,
			SustainTime = 0.3,
			FadeOutTime = 0.4,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	end

	if p == "Impact2" then
		local clone = assets.Explosion:Clone()
		clone.Parent = parent3
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(-8.7489013671875, -2.3617184162139893, -40.55487060546875)
		local raycastResult = workspace:Raycast(
			clone.Position + createVector(0, 1, 0),
			createVector(-0, -5, -0),
			raycastParams
		)

		if raycastResult then
			EmitAll(clone, raycastResult.Instance.Color)
		else
			EmitAll(clone)
		end

		DebrisModule:AddItem(clone, 3)
		CraterExtension.Ground(clone.Position, 11, createVector(1.5, 2.5, 2), nil, 2, false, 2)
		CraterExtension.Ground(clone.Position, 12, createVector(1.5, 1.5, 2), nil, 5, false, 2)
		BlurEffect(0.2)
		task.spawn(TokenKit.GroundRocks, {
			CF = clone.CFrame,
			InnerRadius = 5,
			OuterRadius = 21,
			Velocity = {
				Min = 20,
				Max = 40
			},
			Size = {
				Min = 0.5,
				Max = 1
			}
		})
		Cam_Shaker(clone.Position, {
			FadeInTime = 0,
			Frequency = 0.2,
			Amplitude = 0.3,
			SustainTime = 0.3,
			FadeOutTime = 0.4,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	end

	if p == "Impact3" then
		local clone = assets.Explosion:Clone()
		clone.Parent = parent3
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(-10.4627685546875, -2.3617184162139893, -40.86309814453125)
		local raycastResult = workspace:Raycast(
			clone.Position + createVector(0, 1, 0),
			createVector(-0, -5, -0),
			raycastParams
		)

		if raycastResult then
			EmitAll(clone, raycastResult.Instance.Color)
		else
			EmitAll(clone)
		end

		DebrisModule:AddItem(clone, 3)
		CraterExtension.Ground(clone.Position, 11, createVector(1.5, 2.5, 2), nil, 2, false, 2)
		CraterExtension.Ground(clone.Position, 12, createVector(1.5, 1.5, 2), nil, 5, false, 2)
		BlurEffect(0.2)
		task.spawn(TokenKit.GroundRocks, {
			CF = clone.CFrame,
			InnerRadius = 5,
			OuterRadius = 21,
			Velocity = {
				Min = 20,
				Max = 40
			},
			Size = {
				Min = 0.5,
				Max = 1
			}
		})
		Cam_Shaker(clone.Position, {
			FadeInTime = 0,
			Frequency = 0.2,
			Amplitude = 0.3,
			SustainTime = 0.3,
			FadeOutTime = 0.4,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	end

	if p == "Impact4" then
		local clone = assets.Explosion:Clone()
		clone.Parent = parent3
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(10.2799072265625, -2.308598279953003, -37.64569091796875)
		local raycastResult = workspace:Raycast(
			clone.Position + createVector(0, 1, 0),
			createVector(-0, -5, -0),
			raycastParams
		)

		if raycastResult then
			EmitAll(clone, raycastResult.Instance.Color)
		else
			EmitAll(clone)
		end

		DebrisModule:AddItem(clone, 3)
		CraterExtension.Ground(clone.Position, 11, createVector(1.5, 2.5, 2), nil, 2, false, 2)
		CraterExtension.Ground(clone.Position, 12, createVector(1.5, 1.5, 2), nil, 5, false, 2)
		BlurEffect(0.2)
		task.spawn(TokenKit.GroundRocks, {
			CF = clone.CFrame,
			InnerRadius = 5,
			OuterRadius = 21,
			Velocity = {
				Min = 20,
				Max = 40
			},
			Size = {
				Min = 0.5,
				Max = 1
			}
		})
		Cam_Shaker(clone.Position, {
			FadeInTime = 0,
			Frequency = 0.2,
			Amplitude = 0.3,
			SustainTime = 0.3,
			FadeOutTime = 0.4,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	end

	if p == "Impact5" then
		BlurEffect(0.2)
		local clone = assets.Explosion:Clone()
		clone.Parent = parent3
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(5.4256591796875, -2.3617184162139893, -43.80859375)
		local raycastResult = workspace:Raycast(
			clone.Position + createVector(0, 1, 0),
			createVector(-0, -5, -0),
			raycastParams
		)

		if raycastResult then
			EmitAll(clone, raycastResult.Instance.Color)
		else
			EmitAll(clone)
		end

		DebrisModule:AddItem(clone, 3)
		CraterExtension.Ground(clone.Position, 11, createVector(1.5, 2.5, 2), nil, 2, false, 2)
		CraterExtension.Ground(clone.Position, 12, createVector(1.5, 1.5, 2), nil, 5, false, 2)
		task.spawn(TokenKit.GroundRocks, {
			CF = clone.CFrame,
			InnerRadius = 5,
			OuterRadius = 21,
			Velocity = {
				Min = 20,
				Max = 40
			},
			Size = {
				Min = 0.5,
				Max = 1
			}
		})
		Cam_Shaker(clone.Position, {
			FadeInTime = 0,
			Frequency = 0.2,
			Amplitude = 0.3,
			SustainTime = 0.3,
			FadeOutTime = 0.4,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	end

	if p == "FinalAct" then
		parent3.Name = "--"
		local humanoidRootPart2 = parent:FindFirstChild("HumanoidRootPart")
		local upperTorso = parent:FindFirstChild("UpperTorso") or parent:FindFirstChild("LowerTorso") or humanoidRootPart2

		if humanoidRootPart2 == nil then
			return
		end

		task.wait(0.2)
		local v4 = {
			{
				cf = CFrame.new(0.6845703125, 32.286643981933594, -35.0782470703125) * CFrame.fromEulerAnglesYXZ(
					0.7057914733886719,
					-2.7021286487579346,
					0.04749560356140137
				),
				distance = 1,
				tweenTime = 0.5,
				delay = 0.01,
				waitTime = 0.02
			},
			{
				cf = CFrame.new(-1.1151123046875, 30.1959228515625, -34.56805419921875) * CFrame.fromEulerAnglesYXZ(
					-0.40455013513565063,
					2.651578903198242,
					0.16614006459712982
				),
				distance = 1,
				tweenTime = 0.5,
				delay = 0.01,
				waitTime = 0.02
			},
			{
				cf = CFrame.new(0.61669921875, 30.643165588378906, -35.49835205078125) * CFrame.fromEulerAnglesYXZ(
					-0.14343257248401642,
					-2.4596176147460938,
					-0.7431215643882751
				),
				distance = 1,
				tweenTime = 0.5,
				delay = 0.01,
				waitTime = 0.02
			},
			{
				cf = CFrame.new(-1.7255859375, 32.078025817871094, -36.04638671875) * CFrame.fromEulerAnglesYXZ(
					0.6688879728317261,
					2.027688980102539,
					-0.3412601351737976
				),
				distance = 1,
				tweenTime = 0.5,
				delay = 0.01,
				waitTime = 0.02
			},
			{
				cf = CFrame.new(-0.394287109375, 33.10137939453125, -36.71337890625) * CFrame.fromEulerAnglesYXZ(
					1.2895060777664185,
					0.8243750333786011,
					0.20841917395591736
				),
				distance = 1,
				tweenTime = 0.5,
				delay = 0.01,
				waitTime = 0.02
			},
			{
				cf = CFrame.new(-1.7349853515625, 31.052730560302734, -35.61724853515625) * CFrame.fromEulerAnglesYXZ(
					0.02956434339284897,
					1.8091399669647217,
					0.983963131904602
				),
				distance = 1,
				tweenTime = 0.5,
				delay = 0.01,
				waitTime = 0.02
			}
		}

		local function spawnArrow(parent2, data)
			if parent3 == nil or parent3.Parent == nil then
				return
			end

			local humanoidRootPart3 = parent2:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart3 == nil then
				return
			end

			local clone = assets.ArrowModel1:Clone()
			clone.Parent = parent3
			clone:PivotTo(humanoidRootPart3.CFrame * data.cf)
			DebrisModule:AddItem(clone, 4)

			for _, descendant in ipairs(clone:GetDescendants()) do
				if descendant.ClassName == "Trail" then
					descendant.Enabled = true
				end

				if descendant.ClassName == "Decal" then
					descendant.Transparency = 0
				end
			end

			TweenService:Create(clone.PrimaryPart, TweenInfo.new(data.tweenTime), {
				CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, -data.distance)
			}):Play()
			task.delay(2.5, function()
				if parent3 == nil or parent3.Parent == nil then
					return
				end

				TweenService:Create(clone.PrimaryPart, TweenInfo.new(0.4), {
					CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, -20)
				}):Play()
				Toggle(clone, false)
				task.wait(0.5)
				task.delay(data.delay, function()
					for _, descendant in ipairs(clone:GetDescendants()) do
						if descendant.ClassName == "Trail" then
							descendant.Enabled = false
						end

						if descendant.ClassName == "Decal" then
							TweenService:Create(descendant, TweenInfo.new(0.1), {
								Transparency = 1
							}):Play()
						end
					end
				end)
			end)
		end

		for _, v5 in ipairs(v4) do
			spawnArrow(parent, v5)
			task.wait(v5.waitTime)
		end

		task.wait(2)
		local clone = assets.LastExplo:Clone()
		clone.Parent = parent3
		local upperTorso2 = parent:FindFirstChild("UpperTorso") or parent:FindFirstChild("LowerTorso") or parent:FindFirstChild("HumanoidRootPart") or upperTorso
		clone:PivotTo(CFrame.new(upperTorso2.Position))
		task.delay(0.16666666666666666, function()
			local WAIT_INTERVAL = 0.016666666666666666
			local WAIT_INTERVAL_2 = 0.03333333333333333
			local clone2 = assets.ColorCorrection1:Clone()
			clone2.Parent = Lighting
			local clone3 = assets.ColorCorrection2:Clone()
			clone3.Parent = Lighting
			Lighting.ColorCorrection.Enabled = false
			clone3.Enabled = true
			task.wait(WAIT_INTERVAL_2)
			clone3.Enabled = false
			clone2.Enabled = true
			task.wait(WAIT_INTERVAL_2)
			clone2.Enabled = false
			task.wait(WAIT_INTERVAL)
			Lighting.ColorCorrection.Enabled = true
			clone2.Enabled = false

			if localPlayer.Character and table.find(v3, localPlayer.Character) then
				ImpactFrames.PlaySet({
					FrameRate = 0.016666666666666666,
					FramesSetName = "KoketsuArrow"
				})
			end

			task.wait(0.2)
			Lighting.ColorCorrection.Enabled = false
			clone3.Enabled = true
			task.wait(WAIT_INTERVAL)
			clone3.Enabled = false
			clone2.Enabled = true
			task.wait(WAIT_INTERVAL)
			clone2.Enabled = false
			task.wait(WAIT_INTERVAL_2)
			clone3.Enabled = true
			task.wait(WAIT_INTERVAL_2)
			clone3.Enabled = false
			clone2.Enabled = true
			task.wait(WAIT_INTERVAL)
			Lighting.ColorCorrection.Enabled = true
			clone2.Enabled = false
			clone2:Destroy()
			clone3:Destroy()
		end)
		BlurEffect(0.2)
		Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		DebrisModule:AddItem(clone, 3)
		local clone2 = assets.FlashHit:Clone()
		clone2.Parent = parent
		DebrisModule:AddItem(clone2, 0.2)
	end

	if p == "UltimateCamera" then
		local clone = assets.CameraVFX:Clone()
		clone.Parent = parent3
		local rigidConstraint = clone.Bone.Attachment.RigidConstraint
		local camattach = clone.Bone.camattach
		DebrisModule:AddItem(clone, 6)
		camattach.Parent = instance2:FindFirstChild("Bone")
		rigidConstraint.Attachment1 = camattach
		Ouwmit.Emit(clone.WindStuff1, Ouwmit.Owned(instance))
		task.spawn(function()
			task.wait(0.5)

			if parent3 == nil then
				return
			end

			vfxUtility.TweenFOV(0.5, 35)
			task.wait(2)

			if parent3 == nil then
				return
			end

			vfxUtility.TweenFOV(0.5, 60)
			task.wait(3)

			if parent3 == nil then
			end
		end)
		task.delay(3.3333333333333335, function()
			local morebgfx = assets:FindFirstChild("morebgfx")

			if morebgfx then
				local clone2 = morebgfx:Clone()
				clone2.Parent = parent3
				clone2:PivotTo(humanoidRootPart.CFrame)
				DebrisModule:AddItem(clone2.Extras.Model.SphereBG, 2.5)
				DebrisModule:AddItem(clone2, 5)
				Ouwmit.Emit(clone2, Ouwmit.Owned(instance))
			end

			task.wait(0.5)
			local clone2 = assets.Camera_VFX:Clone()
			clone2.Parent = parent3
			clone2:PivotTo(instance2.PrimaryPart.CFrame)
			local rigidConstraint2 = clone2.Bone.Attachment.RigidConstraint
			local camattach2 = clone2.Bone.camattach
			DebrisModule:AddItem(clone2, 6)
			camattach2.Parent = instance2:FindFirstChild("Bone")
			rigidConstraint2.Attachment1 = camattach2
		end)
	end

	if p == "Cancel" then
		parent3:Destroy()
		vfxUtility.CancelFOV()
	end
end