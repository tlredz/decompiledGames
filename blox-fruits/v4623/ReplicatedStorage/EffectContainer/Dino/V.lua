local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.MasterClock
local _ = Util.BoatTween
local debris = Util.Debris
local sound = Util.Sound
local _ = Util.PartCache
local player = nil
local _ = Util.CameraShaker
local FX = require(game.ReplicatedStorage.FX)
local V = FX:WaitForChild("Dino").V

-- equivalent calls inferred from this helper; original call sites unknown
local function CameraRoar(p)
	task.spawn(function()
		local currentCamera = workspace.CurrentCamera
		task.spawn(function()
			local clone = V.Blur:Clone()
			debris:AddItem(clone, 10)
			local tween = TweenService:Create(clone, TweenInfo.new(0.15), {
				Size = clone.Size
			})
			clone.Size = 0
			Util.SetParentOverrideWithColor(clone, workspace.CurrentCamera, player, "TRexFruitVFXColor")
			tween:Play()
			tween.Completed:Wait()
			local tween2 = TweenService:Create(clone, TweenInfo.new(0.5), {
				Size = 0
			})
			tween2:Play()
			tween2.Completed:Wait()
			clone:Destroy()
		end)
		local clone = V.CameraFocus:Clone()
		debris:AddItem(clone, 10)
		Util.SetParentOverrideWithColor(clone, p, player, "TRexFruitVFXColor")
		local renderSteppedConnection = RunService.RenderStepped:Connect(function()
			clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(1.5707963267948966, 0, 0)
		end)
		local tween = TweenService:Create(currentCamera, TweenInfo.new(1.2), {
			FieldOfView = 100
		})
		tween:Play()
		tween.Completed:Wait()
		TweenService:Create(currentCamera, TweenInfo.new(0.25), {
			FieldOfView = 70
		}):Play()
		renderSteppedConnection:Disconnect()
		clone:Destroy()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GroundRocks(p, _, _, _, _)
	task.spawn(function()
		local v = p
		v.Massless = false
		v.Anchored = false
		task.spawn(function()
			task.wait(0.25)
			task.wait(math.random(1, 20) / 100)
			local tween = TweenService:Create(v, TweenInfo.new(0.25), {
				Size = createVector(0.1, 0.1, 0.1)
			})
			tween.Completed:Connect(function()
				v:Destroy()
			end)
			tween:Play()
		end)
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
		bodyVelocity.P = 3000
		Util.SetParentOverrideWithColor(bodyVelocity, v, player, "TRexFruitVFXColor")
		bodyVelocity.Velocity = CFrame.new(
			v.Position,
			(CFrame.new(v.Position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(0, 0, -50)).Position + Vector3.new(
				math.random(-10, 10) / 5,
				math.random(80, 250),
				math.random(-10, 10) / 5
			)
		).LookVector * math.random(50, 100)
		task.delay(0.05, function()
			bodyVelocity:Destroy()
		end)
		v.Attachment0.Orientation = Vector3.new(math.random(-90, 90), math.random(-90, 90), math.random(-90, 90))
	end)
end

local function DropBigMeteor(_WorldOrigin2, spawnCF, endCF, duration, boss, meteorScale)
	local v = meteorScale or 2
	local cframe = CFrame.Angles(1.5707963267948966, 0, 0)
	local cFrame2 = spawnCF * cframe
	local model = nil
	local clone

	if boss then
		model = Instance.new("Model")
		model.Name = "TrexBossMeteor"
		clone = V.Meteor:Clone()
		clone.Name = "Meteor"
		clone.Parent = model
		model.PrimaryPart = clone
		Util.SetParentOverrideWithColor(model, _WorldOrigin2, player, "TRexFruitVFXColor")
		model:ScaleTo(v)
		model:PivotTo(cFrame2)
		debris:AddItem(model, duration + 1)
	else
		clone = V.Meteor:Clone()
		debris:AddItem(clone, duration + 1)
		clone.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone, _WorldOrigin2, player, "TRexFruitVFXColor")
	end

	sound:Play("Reptilian Scales- Meteor Fire", clone, nil, 1, 1)

	for _, emitter in ipairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local cFrame3 = endCF * cframe
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			CFrame = cFrame3
		}
	)
	tween:Play()
	tween.Completed:Wait()
	local cFrame = clone.CFrame

	for _, effect in ipairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = false
		elseif effect:IsA("Beam") then
			effect.Enabled = false
		end
	end

	local clone2

	if boss then
		local model2 = Instance.new("Model")
		model2.Name = "TrexBossMeteorExplosion"
		clone2 = V.MeteorExplosion:Clone()
		clone2.Name = "MeteorExplosion"
		clone2.Parent = model2
		model2.PrimaryPart = clone2
		Util.SetParentOverrideWithColor(model2, _WorldOrigin2, player, "TRexFruitVFXColor")
		model2:PivotTo(clone.CFrame)
		model2:ScaleTo(v)
		debris:AddItem(model2, 5)
	else
		clone2 = V.MeteorExplosion:Clone()
		clone2.CFrame = clone.CFrame
		Util.SetParentOverrideWithColor(clone2, _WorldOrigin2, player, "TRexFruitVFXColor")
		debris:AddItem(clone2, 5)
	end

	sound:Play("Reptilian Scales- Meteor Explode", clone2.Position, nil, 1 + math.random(-15, 15) / 100, 1)

	for _, emitter in ipairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v4 = emitter
		task.spawn(function()
			if v4:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v4:GetAttribute("EmitDelay"))
			end

			v4:Emit(v4:GetAttribute("EmitCount"))
		end)
	end

	local ray = Util.Ray
	local v4 = cFrame.Position + createVector(0, 1, 0)
	local v5 = { workspace.Characters, workspace.Enemies }
	local v6, v7, _ = ray(v4, createVector(-0, -60, -0), v5, false)

	if v6 then
		local v8 = {}

		for _, descendant in ipairs(clone.Core:GetDescendants()) do
			if descendant:IsA("Weld") then
				descendant:Destroy()
			elseif descendant:IsA("MeshPart") then
				local v9 = descendant
				table.insert(v8, function()
					GroundRocks(v9) -- equivalent call inferred; original call site unknown
				end)
			end
		end

		for _, v9 in pairs(v8) do
			v9()
		end

		local parent

		if boss then
			parent = Instance.new("Model")
			parent.Name = "TrexBossGroundMeteorExplosion"
			local clone3 = V.GroundMeteorExplosion:Clone()
			clone3.Name = "GroundMeteorExplosion"
			clone3.Parent = parent
			parent.PrimaryPart = clone3
			Util.SetParentOverrideWithColor(parent, _WorldOrigin2, player, "TRexFruitVFXColor")
			parent:PivotTo(CFrame.new(v7 + createVector(0, 1, 0)))
			debris:AddItem(parent, 10)

			if Util.ScaleParticle2 then
				for _, emitter in ipairs(parent:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						Util.ScaleParticle2(emitter, v - 2, false)
					end
				end
			end
		else
			parent = V.GroundMeteorExplosion:Clone()
			parent.CFrame = CFrame.new(v7 + createVector(0, 1, 0))
			Util.SetParentOverrideWithColor(parent, _WorldOrigin2, player, "TRexFruitVFXColor")
			debris:AddItem(parent, 10)
		end

		for _, emitter in ipairs(parent:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	elseif model then
		model:Destroy()
	else
		clone:Destroy()
	end
end

local function BurnScreenEffect(_WorldOrigin2)
	local currentCamera = workspace.CurrentCamera
	local clone = V.BurnCameraFocus:Clone()
	debris:AddItem(clone, 10)
	Util.SetParentOverrideWithColor(clone, _WorldOrigin2, player, "TRexFruitVFXColor")
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(1.5707963267948966, 0, 0)
	end)

	for _, emitter in ipairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local tweensByClone = {}

	for i = 1, 3 do
		local v = i
		task.spawn(function()
			local clone2 = nil

			if v == 1 then
				clone2 = V.ScreenColor1:Clone()
			elseif v == 2 then
				clone2 = V.ScreenColor2:Clone()
			elseif v == 3 then
				clone2 = V.ScreenColor3:Clone()
			end

			debris:AddItem(clone2, 10)
			Util.SetParentOverrideWithColor(clone2, currentCamera, player, "TRexFruitVFXColor")
			local tween = TweenService:Create(
				clone2,
				TweenInfo.new(
					math.random(10, 30) / 100,
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.Out,
					0,
					false,
					math.random(0, 10) / 100
				),
				{
					Brightness = clone2.Brightness,
					Contrast = clone2.Contrast,
					Saturation = clone2.Saturation,
					TintColor = clone2.TintColor
				}
			)
			clone2.Brightness = 0
			clone2.Contrast = 0
			clone2.Saturation = 0
			clone2.TintColor = Util.WrapColor3Constructor(Color3.fromRGB(255, 255, 255), player, "TRexFruitVFXColor")
			tweensByClone[clone2] = tween
			tween:Play()
		end)
	end

	task.wait(2)

	for k, _ in pairs(tweensByClone) do
		local tween = TweenService:Create(k, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Brightness = 0,
			Contrast = 0,
			Saturation = 0,
			TintColor = Util.WrapColor3Constructor(Color3.fromRGB(255, 255, 255), player, "TRexFruitVFXColor")
		})
		local v = k
		tween.Completed:Connect(function()
			v:Destroy()
		end)
		tween:Play()
	end

	for _, emitter in ipairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	task.wait(1.5)
	renderSteppedConnection:Disconnect()
	clone:Destroy()
end

return function(player2)
	player = player2.player
	local ID = player2.ID

	if ID == 1 then
		local character = player2.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 1000 then
				return
			end

			local cframe = CFrame.new()
			local cframe2 = CFrame.new(humanoidRootPart.Position)
			local clone = V.RoarStartImpact:Clone()
			debris:AddItem(clone, 10)
			clone.CFrame = cframe2
			Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "TRexFruitVFXColor")
			clone.Weld.Part0 = humanoidRootPart
			clone.Weld.C0 = cframe
			sound:Play("Tail Slash- Explosion", clone.Position, nil, 1, 1)

			for _, emitter in ipairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v = emitter
				task.spawn(function()
					if v:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v:GetAttribute("EmitDelay"))
					end

					v:Emit(v:GetAttribute("EmitCount"))
				end)
			end

			task.wait(0.1)
			local clone2 = V.RoarStart:Clone()
			debris:AddItem(clone2, 7)
			clone2.CFrame = cframe2
			Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "TRexFruitVFXColor")
			clone2.Weld.Part0 = humanoidRootPart
			clone2.Weld.C0 = cframe
			sound:Play("Reptilian Scales- Dinosaur Transformation", clone2.Position, nil, 1.5, 1)
			sound:Play("Dinosaur Roar", clone2.Position, nil, 1, 1)

			for _, emitter in ipairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			local clone3 = V.RoarGround:Clone()
			debris:AddItem(clone3, 7)
			clone3.CFrame = CFrame.new(cframe2.Position)
			Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "TRexFruitVFXColor")
			local descendants = clone3:GetDescendants()
			local v = false
			task.spawn(function()
				for _, emitter in pairs(descendants) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				local flag = false
				local v2 = false

				while v == false do
					local v3 = humanoidRootPart.CFrame * cframe
					local ray = Util.Ray
					local position = v3.Position
					local v4 = { workspace.Characters, workspace.Enemies }
					local v5, v6, v7 = ray(position, createVector(-0, -20, -0), v4)

					if v5 then
						clone3.CFrame = CFrame.new(v6, v6 + v7) * CFrame.Angles(-1.5707963267948966, 0, 0)

						if not flag then
							flag = true

							for _, emitter in pairs(descendants) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								if v2 == false and emitter:GetAttribute("Color") then
									emitter.Color = ColorSequence.new(v5.Color, v5.Color)
								end

								emitter.Enabled = true
							end

							if not v2 then
								v2 = true
							end
						end
					elseif flag then
						flag = false

						for _, emitter in pairs(descendants) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					end

					task.wait(0.1)
				end

				for _, emitter in pairs(descendants) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)

			if game.Players.LocalPlayer.Character and character == game.Players.LocalPlayer.Character then
				CameraRoar(_WorldOrigin) -- equivalent call inferred; original call site unknown
			end

			local clone4 = V.RoarAura:Clone()
			debris:AddItem(clone4, 10)
			clone4.CFrame = cframe2 * CFrame.new(0, 15, 0)
			Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "TRexFruitVFXColor")
			clone4.Weld.Part0 = humanoidRootPart
			clone4.Weld.C0 = cframe

			for _, emitter in ipairs(clone4:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v2 = emitter
				task.spawn(function()
					if v2:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v2:GetAttribute("EmitDelay"))
					end

					v2:Emit(v2:GetAttribute("EmitCount"))
				end)
			end

			task.wait(1.2)
			v = true

			for _, emitter in ipairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end
	elseif ID == 2 then
		local spawnCF = player2.SpawnCF
		local endCF = player2.EndCF
		local duration = player2.Duration
		local boss = player2.Boss
		local meteorScale = player2.MeteorScale

		if (endCF.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 1000 then
			return
		end

		task.spawn(function()
			DropBigMeteor(_WorldOrigin, spawnCF, endCF, duration, boss, meteorScale)
		end)
	elseif ID == 3 then
		if player2.Player == game.Players.LocalPlayer then
			BurnScreenEffect(_WorldOrigin)
		elseif (workspace.CurrentCamera.CFrame.p - player2.Origin).Magnitude < player2.Distance then
			BurnScreenEffect(_WorldOrigin)
		end
	end
end