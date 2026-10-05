local createVector = vector.create
local _ = game.Players.LocalPlayer
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Gas").Transformed.F.Assets
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local function DeleteImpactAfterDuration(folder)
	local v = 0

	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local max = emitter.Lifetime.Max
		v = math.max(v, max)
	end

	task.spawn(function()
		task.wait(v)
		folder:Destroy()
	end)
end

local function FlameBurst(root, cFrame, folder)
	local clone = assets.Phase2.HitFlame:Clone()
	clone:PivotTo(cFrame * CFrame.new(0, -4.5, -23))
	clone.Weld.C0 = CFrame.new(0, -4.5, -23)
	clone.PrimaryPart.Anchored = false
	clone.Parent = folder
	clone.Weld.Part0 = root

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true
		emitter:Emit(1)
	end

	task.spawn(function()
		for i = 2, 7 do
			clone:ScaleTo(i / 10)
			task.wait(0.07)
		end
	end)
	task.wait(0.75)

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = false
		elseif effect:IsA("Beam") then
			TweenService:Create(effect, TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end
	end
end

local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace.Enemies, workspace.Characters, workspace._WorldOrigin }
return function(instance)
	local root = instance.Root
	local cFrame = root.CFrame

	if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 900 then
		return
	end

	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 7)

	if instance.Stage == 1 then
		local position = instance.Position
		local duration = instance.Duration or 0.3
		local magnitude = (cFrame.Position - position).Magnitude
		task.spawn(function()
			root.Anchored = true
			local cFrame2 = CFrame.new(instance.Position, root.Position) * CFrame.Angles(0, 3.141592653589793, 0)
			local lastTime = os.clock()

			while os.clock() - lastTime < duration do
				local v2 = (os.clock() - lastTime) / duration
				root.CFrame = cFrame2 * CFrame.new(0, 0, magnitude * (1 - v2 ^ 0.5))
				RunService.PreSimulation:Wait()
			end

			root.CFrame = cFrame2
			root.Anchored = false
		end)
		local clone = assets.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame
		clone.Parent = folder
		Util.Sound:Play("BF_GASFRUIT_TSFM_TravelingGas_Lunge_01", root)
		DeleteImpactAfterDuration(clone)

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

		local clone2 = assets.Phase1.Dash:Clone()
		clone2.CFrame = cFrame
		clone2.Anchored = true
		clone2.Parent = folder
		local flag = true
		task.spawn(function()
			while flag do
				clone2.CFrame = root.CFrame * clone2.Weld.C0
				RunService.PreSimulation:Wait()
			end
		end)
		local emittersByEmitter = {}

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			emittersByEmitter[emitter] = emitter
		end

		task.spawn(function()
			local lastTime = tick()

			repeat
				for _, v in pairs(emittersByEmitter) do
					v:Emit(1)
				end

				task.wait(0.05)
				local v = tick() - lastTime
			until duration * 0.9 <= v
		end)
		task.spawn(function()
			task.wait(duration * 0.85)

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") and emitter.Parent.Name == "LineAttachment" then
					emitter.Enabled = false
				end
			end

			task.wait(duration * 0.15)
			flag = false

			for _, effect in pairs(clone2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end)
		task.spawn(function()
			local clone3 = assets.Phase1.GroundGas:Clone()
			clone3.CFrame = cFrame
			clone3.Parent = folder

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			local now = tick()
			local v = duration * 0.7 + tick()
			local emitters = {}
			local v2 = false

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					table.insert(emitters, emitter)
				end
			end

			while true do
				local raycastResult = workspace:Raycast(
					root.Position + createVector(0, 1, 0),
					createVector(-0, -50, -0),
					raycastParams
				)

				if raycastResult then
					clone3.CFrame = CFrame.new(raycastResult.Position + createVector(0, 0.5, 0))

					if v2 == false then
						v2 = true

						for _, v3 in pairs(emitters) do
							v3.Enabled = true
						end
					end

					if now - tick() <= 0 then
						now = 0.025 + tick()

						for _, v3 in pairs(emitters) do
							v3:Emit(v3:GetAttribute("EmitCount"))
						end
					end
				elseif v2 == true then
					v2 = false

					for _, v3 in pairs(emitters) do
						v3.Enabled = false
					end
				end

				task.wait()

				if not (v - tick() <= 0) then
					continue
				end

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				break
			end
		end)
	elseif instance.Stage == 2 then
		local cFrame2 = instance.CFrame
		local clone = assets.Phase2.GrabImpact:Clone()
		clone.CFrame = cFrame2
		clone.Parent = folder
		Util.Sound:Play("BF_GASFRUIT_TSFM_TravelingGas_Hit_02", root)
		DeleteImpactAfterDuration(clone)

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

		local function isAffected()
			if instance.Root == game.Players.LocalPlayer.Character.HumanoidRootPart then
				return true
			end

			for _, caughtCharacter in pairs(instance.CaughtCharacters) do
				if caughtCharacter:FindFirstChild("HumanoidRootPart") and caughtCharacter.HumanoidRootPart == game.Players.LocalPlayer.Character.HumanoidRootPart then
					return true
				end
			end
		end

		task.spawn(function()
			local currentCamera = workspace.CurrentCamera

			if not isAffected() then
				return
			end

			Util.CameraShaker:ShakeOnce(9, 13, 0.6, 1.1)
			local screenColorGF1 = assets.Phase1.ScreenColorGF1
			local v = game.Lighting:FindFirstChild("ScreenColorGZ")

			if v then
				v:SetAttribute("UsedTimes", v:GetAttribute("UsedTimes") + 1)
			else
				v = Instance.new("ColorCorrectionEffect")
			end

			v.Parent = game.Lighting
			local usedTimes = v:GetAttribute("UsedTimes")
			local tween = TweenService:Create(v, TweenInfo.new(0.1), {
				Brightness = screenColorGF1.Brightness,
				Contrast = screenColorGF1.Contrast,
				Saturation = screenColorGF1.Saturation,
				TintColor = screenColorGF1.TintColor
			})
			tween:Play()
			task.spawn(function()
				task.wait(0.1)
				tween = TweenService:Create(v, TweenInfo.new(0.6), {
					Brightness = -0.3,
					Contrast = 0.7,
					Saturation = -0.7,
					TintColor = Color3.fromRGB(166, 185, 255)
				})
				tween:Play()
			end)
			local clone2 = assets.Phase2.CameraFocus:Clone()
			clone2.Parent = folder
			local renderSteppedConnection = RunService.RenderStepped:Connect(function()
				clone2.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, 0)
			end)

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			task.wait(0.7)

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.spawn(function()
				if v:GetAttribute("UsedTimes") == usedTimes then
					tween = TweenService:Create(v, TweenInfo.new(0.01), {
						TintColor = Color3.fromRGB(255, 255, 255),
						Brightness = 0,
						Contrast = 0,
						Saturation = 0
					})
					tween:Play()
					tween.Completed:Wait()

					if v:GetAttribute("UsedTimes") == usedTimes then
						v:Destroy()
					end
				end
			end)
			task.wait(1)
			renderSteppedConnection:Disconnect()
			clone2:Destroy()
		end)
		FlameBurst(root, cFrame2, folder)
		local clone2 = assets.Phase3.Explosion:Clone()
		clone2.CFrame = cFrame2
		clone2.Parent = folder
		DeleteImpactAfterDuration(clone2)

		for _, emitter in pairs(clone2:GetDescendants()) do
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

		local clone3 = assets.Phase3.ThrowImpact:Clone()
		clone3.CFrame = cFrame2
		clone3.Parent = folder
		DeleteImpactAfterDuration(clone3)

		for _, emitter in pairs(clone3:GetDescendants()) do
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

		task.spawn(function()
			local _ = workspace.CurrentCamera

			if not isAffected() then
				return
			end

			Util.CameraShaker:ShakeOnce(22, 22, 0.05, 0.5)
			local screenColorGF2 = assets.Phase3.ScreenColorGF2
			local v = game.Lighting:FindFirstChild("ScreenColorGZ")

			if v then
				v:SetAttribute("UsedTimes", v:GetAttribute("UsedTimes") + 1)
			else
				v = Instance.new("ColorCorrectionEffect")
			end

			v.Parent = game.Lighting
			local usedTimes = v:GetAttribute("UsedTimes")
			local tween = TweenService:Create(v, TweenInfo.new(0.1), {
				Brightness = screenColorGF2.Brightness,
				Contrast = screenColorGF2.Contrast,
				Saturation = screenColorGF2.Saturation,
				TintColor = screenColorGF2.TintColor
			})
			tween:Play()
			local bloomEffect = Instance.new("BloomEffect")
			bloomEffect.Parent = game.Lighting
			bloomEffect.Size += 10
			local v2 = TweenService:Create(bloomEffect, TweenInfo.new(0.1), {
				Size = 54
			}):Play()
			task.delay(0.1, function()
				v2 = TweenService:Create(bloomEffect, TweenInfo.new(0.25), {
					Size = 0
				}):Play()
				task.wait(0.25)
				bloomEffect:Destroy()
			end)
			task.wait(0.1)
			task.spawn(function()
				tween = TweenService:Create(v, TweenInfo.new(0.1), {
					Brightness = 0.15,
					Contrast = screenColorGF2.Contrast,
					Saturation = -1,
					TintColor = Color3.fromRGB(214, 198, 255)
				})
				tween:Play()
				task.wait(0.1)

				if v:GetAttribute("UsedTimes") == usedTimes then
					tween = TweenService:Create(v, TweenInfo.new(0.15), {
						TintColor = Color3.fromRGB(255, 255, 255),
						Brightness = 0,
						Contrast = 0,
						Saturation = 0
					})
					tween:Play()
					tween.Completed:Wait()

					if v:GetAttribute("UsedTimes") == usedTimes then
						v:Destroy()
					end
				end
			end)
			task.wait(1)
		end)
	end
end