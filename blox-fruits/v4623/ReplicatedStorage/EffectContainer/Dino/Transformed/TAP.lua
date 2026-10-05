local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.MasterClock
local _ = Util.Debris
local sound = Util.Sound
local player = nil
local TweenService = game:GetService("TweenService")
local FX = require(game.ReplicatedStorage.FX)
local TAP = FX:WaitForChild("Dino").Transformed.TAP

local function ClawSlash(folder, humanoidRootPart, data)
	local multiplier = data.Multiplier
	local slashAngle = data.SlashAngle
	local slashAngle2 = data.SlashAngle2
	local yPosition = data.YPosition
	local clone = data.SlashType:Clone()
	clone.CFrame = humanoidRootPart.CFrame
	clone.Weld.Part0 = humanoidRootPart
	clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.new(0, yPosition, 0) * slashAngle * slashAngle2
	Util.SetParentOverrideWithColor(clone, folder, player, "TRexFruitVFXColor")

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

	task.spawn(function()
		task.wait(0.125)
		local clone2 = TAP.SlashHit:Clone()
		clone2.CFrame = clone.CFrame * CFrame.new(0, 0, -18.5)
		Util.SetParentOverrideWithColor(clone2, folder, player, "TRexFruitVFXColor")

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end)
	coroutine.wrap(function()
		for _, beam in pairs(clone:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			local startDelay = beam:GetAttribute("StartDelay")
			local v = beam
			local v2 = beam:GetAttribute("EndDelay")
			coroutine.wrap(function()
				local tween = TweenService:Create(
					v,
					TweenInfo.new(v2 / 1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						Width0 = v.Width0,
						Width1 = v.Width1
					}
				)
				v.Width0 = 0
				v.Width1 = 0
				task.wait(startDelay)
				tween:Play()
				task.wait(v2)
				task.wait(0.012)
				local tween2 = TweenService:Create(
					v,
					TweenInfo.new(v2 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween2:Play()
				tween2.Completed:Wait()
				v:Destroy()
			end)()
		end
	end)()
	local tween = TweenService:Create(
		clone.Weld,
		TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.Angles(
				-2.6179938779914944,
				0,
				0
			)
		}
	)
	tween:Play()
	tween.Completed:Wait()
	clone.Weld.Enabled = false
	clone.Anchored = true
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CFrame = clone.CFrame * CFrame.Angles(-1.3089969389957472, 0, 0)
	}):Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CameraRoar(p)
	task.spawn(function()
		local currentCamera = workspace.CurrentCamera
		task.spawn(function()
			local clone = TAP.Blur:Clone()
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
		local clone = TAP.CameraFocus:Clone()
		Util.SetParentOverrideWithColor(clone, p, player, "TRexFruitVFXColor")
		local renderSteppedConnection = RunService.RenderStepped:Connect(function()
			clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(1.5707963267948966, 0, 0)
		end)
		local tween = TweenService:Create(currentCamera, TweenInfo.new(0.66), {
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

return function(player2)
	player = player2.player
	local ID = player2.ID
	local character = player2.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 800 then
		return
	end

	local folder = Instance.new("Folder", _WorldOrigin)
	Util.Debris:AddItem(folder, 4)

	if ID == 1 then
		task.spawn(function()
			local v = {
				Multiplier = 2,
				SlashAngle = CFrame.Angles(0, 0, -1.0471975511965976),
				SlashAngle2 = CFrame.Angles(2.9670597283903604, 0, 0),
				YPosition = 3,
				SlashType = TAP.Slash
			}
			sound:Play("DinoM1_1", humanoidRootPart, nil, 1.2, 1)
			sound:Play("DinoM1_2", humanoidRootPart, nil, 0.8, 1)
			ClawSlash(folder, humanoidRootPart, v)
		end)
	elseif ID == 2 then
		task.spawn(function()
			local v = {
				Multiplier = 2,
				SlashAngle = CFrame.Angles(0, 0, 1.2217304763960306),
				SlashAngle2 = CFrame.Angles(2.9670597283903604, 0, 0),
				YPosition = 3,
				SlashType = TAP.Slash
			}
			sound:Play("DinoM1_3", humanoidRootPart, nil, 1, 1)
			ClawSlash(folder, humanoidRootPart, v)
		end)
	elseif ID == 3 then
		local clone = TAP.Bite:Clone()
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 3, -11.5)
		Util.SetParentOverrideWithColor(clone, folder, player, "TRexFruitVFXColor")
		clone.Main.Part0 = humanoidRootPart
		clone.Main.C0 = CFrame.new(0, 3, -11.5)
		Util.Sound:Play("Hunters Rage- Release (2)", humanoidRootPart, nil, 1.35, 1)

		for _, emitter in pairs(clone:GetDescendants()) do
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
	elseif ID == 4 then
		task.spawn(function()
			local cframe = CFrame.new(0, 3, -11.5)
			local cFrame = humanoidRootPart.CFrame * cframe
			local clone = TAP.RoarStartImpact:Clone()
			clone.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone, folder, player, "TRexFruitVFXColor")
			clone.Main.Part0 = humanoidRootPart
			clone.Main.C0 = cframe
			Util.Sound:Play("Dinosaur Roar", humanoidRootPart, nil, 1.4, 1)

			for _, emitter in pairs(clone:GetDescendants()) do
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

			task.wait(0.15)
			local clone2 = TAP.RoarStart:Clone()
			clone2.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone2, folder, player, "TRexFruitVFXColor")
			clone2.Main.Part0 = humanoidRootPart
			clone2.Main.C0 = cframe

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			local clone3 = TAP.RoarGround:Clone()
			clone3.CFrame = CFrame.new(cFrame.Position)
			Util.SetParentOverrideWithColor(clone3, folder, player, "TRexFruitVFXColor")
			local descendants = clone3:GetDescendants()
			local v2 = false
			task.spawn(function()
				for _, emitter in pairs(descendants) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				local flag = false
				local v3 = false

				while v2 == false do
					local v4 = humanoidRootPart.CFrame * cframe
					local ray = Util.Ray
					local position = v4.Position
					local v5 = { workspace.Characters, workspace.Enemies }
					local v6, v7, v8 = ray(position, createVector(-0, -20, -0), v5)

					if v6 then
						clone3.CFrame = CFrame.new(v7, v7 + v8) * CFrame.Angles(-1.5707963267948966, 0, 0)

						if not flag then
							flag = true

							for _, emitter in pairs(descendants) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								if v3 == false and emitter:GetAttribute("Color") then
									emitter.Color = ColorSequence.new(v6.Color, v6.Color)
								end

								emitter.Enabled = true
							end

							if not v3 then
								v3 = true
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
				CameraRoar(folder) -- equivalent call inferred; original call site unknown
			end

			task.wait(0.66)
			v2 = true

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
	end
end