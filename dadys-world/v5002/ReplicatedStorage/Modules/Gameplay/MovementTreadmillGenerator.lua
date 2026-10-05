local createVector = vector.create
local MovementTreadmillGenerator = {}
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local v = {}

local function getCharacterBaseSpeed(instance, p, p2)
	local selectedCharacter = instance:GetAttribute("SelectedCharacter")

	if selectedCharacter and v[selectedCharacter] then
		if p == "run" then
			return 2
		end

		return 1
	else
		return p2
	end
end

local function createMovementGUI(instance)
	local screenGui = instance:WaitForChild("PlayerGui"):FindFirstChild("ScreenGui")

	if not screenGui then
		return nil
	end

	local showTreadmillDebug = workspace:FindFirstChild("Info") and workspace.Info:FindFirstChild("ShowTreadmillDebug")
	local frame = Instance.new("Frame")
	frame.Name = "TreadmillFeedback"

	if showTreadmillDebug then
		frame.Size = UDim2.new(0, 320, 0, 160)
		frame.Position = UDim2.new(0, 20, 0.25, 0)
		frame.BackgroundTransparency = 0.2
	else
		frame.Size = UDim2.new(0, 250, 0, 80)
		frame.Position = UDim2.new(0, 20, 0.15, 0)
		frame.BackgroundTransparency = 0.8
	end

	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 12)
	uICorner.Parent = frame
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Title"

	if showTreadmillDebug then
		textLabel.Size = UDim2.new(1, 0, 0, 30)
		textLabel.Position = UDim2.new(0, 0, 0, 5)
		textLabel.Text = "🏃 MOVEMENT TREADMILL"
	else
		textLabel.Size = UDim2.new(1, 0, 0, 20)
		textLabel.Position = UDim2.new(0, 0, 0, 0)
		textLabel.Text = "Movement Generator"
	end

	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.Parent = frame
	local textLabel2

	if not showTreadmillDebug then
		textLabel2 = Instance.new("TextLabel")
		textLabel2.Name = "SpeedDisplay"
		textLabel2.Size = UDim2.new(1, 0, 0, 35)
		textLabel2.Position = UDim2.new(0, 0, 0, 20)
		textLabel2.BackgroundTransparency = 1
		textLabel2.Text = "Speed: 0.0"
		textLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel2.TextScaled = true
		textLabel2.Font = Enum.Font.SourceSansBold
		textLabel2.TextStrokeTransparency = 0.5
		textLabel2.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		textLabel2.Parent = frame
	end

	local frame2, textLabel3, textLabel4

	if showTreadmillDebug then
		local frame3 = Instance.new("Frame")
		frame3.Name = "SpeedBackground"
		frame3.Size = UDim2.new(0.9, 0, 0, 20)
		frame3.Position = UDim2.new(0.05, 0, 0, 40)
		frame3.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		frame3.BorderSizePixel = 0
		frame3.Parent = frame
		local uICorner2 = Instance.new("UICorner")
		uICorner2.CornerRadius = UDim.new(0, 10)
		uICorner2.Parent = frame3
		frame2 = Instance.new("Frame")
		frame2.Name = "SpeedFill"
		frame2.Size = UDim2.new(0, 0, 1, 0)
		frame2.Position = UDim2.new(0, 0, 0, 0)
		frame2.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
		frame2.BorderSizePixel = 0
		frame2.Parent = frame3
		local uICorner3 = Instance.new("UICorner")
		uICorner3.CornerRadius = UDim.new(0, 10)
		uICorner3.Parent = frame2
		textLabel3 = Instance.new("TextLabel")
		textLabel3.Name = "WalkSpeedText"
		textLabel3.Size = UDim2.new(0.5, 0, 0, 18)
		textLabel3.Position = UDim2.new(0, 5, 0, 65)
		textLabel3.BackgroundTransparency = 1
		textLabel3.Text = "Walk: 16 (0.0)"
		textLabel3.TextColor3 = Color3.fromRGB(200, 200, 200)
		textLabel3.TextScaled = true
		textLabel3.Font = Enum.Font.SourceSans
		textLabel3.Parent = frame
		textLabel4 = Instance.new("TextLabel")
		textLabel4.Name = "SprintStatus"
		textLabel4.Size = UDim2.new(0.5, -10, 0, 18)
		textLabel4.Position = UDim2.new(0.5, 5, 0, 65)
		textLabel4.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		textLabel4.BackgroundTransparency = 0.3
		textLabel4.Text = "🚶 WALKING"
		textLabel4.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel4.TextScaled = true
		textLabel4.Font = Enum.Font.SourceSansBold
		textLabel4.Parent = frame
		local uICorner4 = Instance.new("UICorner")
		uICorner4.CornerRadius = UDim.new(0, 6)
		uICorner4.Parent = textLabel4
	end

	local frame3 = Instance.new("Frame")
	frame3.Name = "GeneratorProgressBg"
	frame3.Size = UDim2.new(0.9, 0, 0, 12)

	if showTreadmillDebug then
		frame3.Position = UDim2.new(0.05, 0, 0, 90)
	else
		frame3.Position = UDim2.new(0.05, 0, 0, 60)
	end

	frame3.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	frame3.BorderSizePixel = 0
	frame3.Parent = frame
	local uICorner2 = Instance.new("UICorner")
	uICorner2.CornerRadius = UDim.new(0, 4)
	uICorner2.Parent = frame3
	local frame4 = Instance.new("Frame")
	frame4.Name = "GeneratorProgressFill"
	frame4.Size = UDim2.new(0, 0, 1, 0)
	frame4.Position = UDim2.new(0, 0, 0, 0)
	frame4.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
	frame4.BorderSizePixel = 0
	frame4.Parent = frame3
	local uICorner3 = Instance.new("UICorner")
	uICorner3.CornerRadius = UDim.new(0, 4)
	uICorner3.Parent = frame4
	local textLabel5, textLabel6

	if showTreadmillDebug then
		textLabel5 = Instance.new("TextLabel")
		textLabel5.Name = "ProgressText"
		textLabel5.Size = UDim2.new(1, 0, 0, 15)
		textLabel5.Position = UDim2.new(0, 0, 0, 110)
		textLabel5.BackgroundTransparency = 1
		textLabel5.Text = "Generator: 0% complete"
		textLabel5.TextColor3 = Color3.fromRGB(200, 200, 200)
		textLabel5.TextScaled = true
		textLabel5.Font = Enum.Font.SourceSans
		textLabel5.Parent = frame
		textLabel6 = Instance.new("TextLabel")
		textLabel6.Name = "TimeText"
		textLabel6.Size = UDim2.new(1, 0, 0, 15)
		textLabel6.Position = UDim2.new(0, 0, 0, 130)
		textLabel6.BackgroundTransparency = 1
		textLabel6.Text = "ETA: Calculating..."
		textLabel6.TextColor3 = Color3.fromRGB(255, 215, 0)
		textLabel6.TextScaled = true
		textLabel6.Font = Enum.Font.SourceSansBold
		textLabel6.Parent = frame
	end

	return {
		gui = frame,
		speedFill = frame2,
		walkSpeedText = textLabel3,
		sprintStatus = textLabel4,
		progressText = textLabel5,
		timeText = textLabel6,
		genProgressFill = frame4,
		speedDisplay = textLabel2,
		showDebugInfo = showTreadmillDebug
	}
end

function MovementTreadmillGenerator.Initialize(instance, player, p, p2)
	if not (instance and player) then
		warn("[MovementTreadmillGenerator] Missing required parameters")
		return nil
	end

	local v2 = not p2 and "" or p2.suffix or ""
	local prompt = p2 and p2.prompt
	local character = player.Character

	if not (character and character.PrimaryPart) then
		warn("[MovementTreadmillGenerator] Player character not found")
		return nil
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		warn("[MovementTreadmillGenerator] Humanoid not found")
		return nil
	end

	local removeCharacterAntiExploitModule = game.ServerStorage:FindFirstChild("Bindables") and game.ServerStorage.Bindables:FindFirstChild("RemoveCharacterAntiExploitModule")

	if removeCharacterAntiExploitModule then
		removeCharacterAntiExploitModule:Fire(player, true)
	end

	character:GetAttribute("TreadmillDazed")
	local flag = true
	local total = 0
	local v3 = {}
	local total2 = 1
	local v4 = nil
	local flag2 = false
	local animationBoost = 1
	local v6 = 0
	local fn

	local function startTreadmillAnimation()
		for _, v7 in pairs(humanoid:GetPlayingAnimationTracks()) do
			local v8 = not v7.Animation and "" or v7.Animation.Name or ""

			if not (v8:lower():find("walk") or v8:lower():find("run")) then
				continue
			end

			v7:Stop(0.1)
		end

		local walkAnimationId = character:GetAttribute("WalkAnimationId")

		if character.Name == "RazzleDazzle" or character.Name == "Razzle&Dazzle" then
			print("[MovementTreadmill] DEBUG - RazzleDazzle animation check:")
			print("  - WalkAnimationId attribute:", walkAnimationId or "nil")
			print("  - AnimSet attribute:", character:GetAttribute("AnimSet") or "nil")
			print("  - Character name:", character.Name)
		end

		if not walkAnimationId then
			local animations = character:FindFirstChild("Animations")

			if animations then
				local walk = animations:FindFirstChild("Walk")

				if walk and walk:IsA("Animation") then
					walkAnimationId = walk.AnimationId
				end
			end
		end

		if not walkAnimationId then
			return nil
		end

		local animation = Instance.new("Animation")
		animation.AnimationId = walkAnimationId
		animation.Name = "TreadmillWalk"
		local track = humanoid:LoadAnimation(animation)
		track.Looped = true
		local config = character:FindFirstChild("Config")

		if (config and config:FindFirstChild("ModuleName") and config.ModuleName.Value) == "Eggson" then
			track.Priority = Enum.AnimationPriority.Action3
		else
			track.Priority = Enum.AnimationPriority.Action4
		end

		track:Play(0.1)
		return track
	end

	local v7 = startTreadmillAnimation()
	local v8 = "walk"
	local now = tick()
	character:SetAttribute("TreadmillMode", true)
	character:SetAttribute("DisableQuirks", true)
	character:SetAttribute("DisableSprintAnimations", true)
	character:SetAttribute("TreadmillForceMovement", true)
	local fakeValveReference = instance:FindFirstChild("FakeValveReference" .. v2)

	if not fakeValveReference then
		if v2 == "" then
			fakeValveReference = instance:FindFirstChild("FakeValveReference")
		else
			fakeValveReference = false
		end
	end

	local value = fakeValveReference and fakeValveReference.Value
	local child = instance:FindFirstChild("TreadmillLightReference" .. v2)
	local value2

	if child and child.Value then
		value2 = child.Value
	else
		local treadmillGame = instance:FindFirstChild("TreadmillGame" .. v2)

		if not treadmillGame then
			if v2 == "" then
				treadmillGame = instance:FindFirstChild("TreadmillGame")
			else
				treadmillGame = false
			end
		end

		value2 = treadmillGame and treadmillGame:FindFirstChild("TreadmillLight")
	end

	if not value2 then
		local v9 = instance:FindFirstChild("BaseMachine" .. v2) or instance:FindFirstChild("wipGenerator" .. v2)
		value2 = v9 and v9:FindFirstChild("Light") or instance:FindFirstChild("Light" .. v2)
	end

	local size = not value and createVector(1, 1, 1) or value.Size or createVector(1, 1, 1)

	local function createTreadmillParticle(childName)
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head") or character.PrimaryPart

		if not humanoidRootPart then
			return nil
		end

		local child2 = humanoidRootPart:FindFirstChild("TreadmillParticleAttachment_" .. childName)

		if child2 then
			child2:Destroy()
		end

		local attachment = Instance.new("Attachment")
		attachment.Name = "TreadmillParticleAttachment_" .. childName

		if humanoidRootPart.Name == "HumanoidRootPart" then
			if childName == "Drops" then
				attachment.Position = createVector(0, 1, 0)
			else
				attachment.Position = Vector3.new(0, humanoidRootPart.Size.Y / 2, 0)
			end
		elseif humanoidRootPart.Name == "Head" then
			if childName == "Drops" then
				attachment.Position = createVector(0, -0.3, 0)
			else
				attachment.Position = createVector(0, 0, 0)
			end
		else
			attachment.Position = Vector3.new(0, humanoidRootPart.Size.Y / 2, 0)
		end

		attachment.Parent = humanoidRootPart
		local child3 = ReplicatedStorage:FindFirstChild("Parts") and ReplicatedStorage.Parts:FindFirstChild(childName)
		local particleEmitter = child3 and child3:FindFirstChildOfClass("ParticleEmitter")

		if not particleEmitter then
			local drops = ReplicatedStorage:FindFirstChild("Parts") and ReplicatedStorage.Parts:FindFirstChild("Drops")
			particleEmitter = drops and drops:FindFirstChildOfClass("ParticleEmitter")

			if not particleEmitter then
				warn("[MovementTreadmill] Particle template not found:", childName)
				return nil
			end
		end

		local clone = particleEmitter:Clone()
		clone.Name = "Treadmill" .. childName
		clone.Rate = childName == "Drops" and 1.5 or 0

		if childName == "Drops" then
			clone.Lifetime = NumberRange.new(0.4, 0.6)
			clone.Speed = NumberRange.new(clone.Speed.Min * 0.5, clone.Speed.Max * 0.5)
		end

		clone.Parent = attachment
		clone.Enabled = true
		return clone
	end

	local function updateProgress(p3)
		if not flag then
			return
		end

		if p and p.Value and p.Value.Parent then
			local v10 = p3 * 0.07
			instance.Stats.CurrentAmount.Value = math.min(
				instance.Stats.CurrentAmount.Value + v10,
				instance.Stats.RequiredAmount.Value
			)

			if not instance.PlayerCompletion:FindFirstChild(character.Name) then
				local numberValue = Instance.new("NumberValue")
				numberValue.Name = character.Name
				numberValue.Value = 0
				numberValue.Parent = instance.PlayerCompletion
			end

			instance.PlayerCompletion[character.Name].Value = instance.PlayerCompletion[character.Name].Value + v10
		else
			local v10 = p3 * 0.07
			instance.Stats.CurrentAmount.Value = math.min(
				instance.Stats.CurrentAmount.Value + v10,
				instance.Stats.RequiredAmount.Value
			)
		end
	end

	local function animateTreadmillCharacter()
		if not (flag and humanoid) then
			return
		end

		local now2 = tick()
		local stats = character:FindFirstChild("Stats")

		if stats and stats:FindFirstChild("HoldingSprint") then
			local _ = stats.HoldingSprint.Value
		end

		if stats and stats:FindFirstChild("CurrentStamina") then
			local _ = stats.CurrentStamina.Value > 0
		end

		local v10 = stats and stats:FindFirstChild("Sprinting") and stats.Sprinting.Value and "run" or "walk"
		local v11 = v10 ~= v8
		local v12 = now2 - now
		local v13 = v8 == "idle" and 0 or v10 == "run" and v8 == "walk" and 0.03 or 0.05

		if v11 and v13 < v12 then
			v8 = v10
			now = now2

			if v7 then
				v7:Stop(0.1)
				v7:Destroy()
				v7 = nil
			end

			for _, v14 in pairs(humanoid:GetPlayingAnimationTracks()) do
				if v14 == v7 then
					continue
				end

				local v15 = not v14.Animation and "" or v14.Animation.Name or ""

				if not (v15:lower():find("walk") or v15:lower():find("run") or v15:lower():find("sprint")) then
					continue
				end

				v14:Stop(0)
			end

			local v14 = 1
			local runAnimationId

			if v10 == "run" then
				runAnimationId = character:GetAttribute("RunAnimationId")
			else
				runAnimationId = character:GetAttribute("WalkAnimationId")
			end

			if character.Name == "RazzleDazzle" or character.Name == "Razzle&Dazzle" then
				print("[MovementTreadmill] animateTreadmillCharacter - RazzleDazzle animation update:")
				print("  - Animation state:", v10)
				print("  - Animation ID from attribute:", runAnimationId or "nil")
				print("  - AnimSet:", character:GetAttribute("AnimSet") or "nil")
			end

			if not runAnimationId then
				local animations = character:FindFirstChild("Animations")

				if animations then
					if v10 == "run" then
						local run = animations:FindFirstChild("Run")

						if run and run:IsA("Animation") then
							runAnimationId = run.AnimationId
						else
							local walk = animations:FindFirstChild("Walk")

							if walk and walk:IsA("Animation") then
								runAnimationId = walk.AnimationId
								v14 = 1.5
							end
						end
					else
						local walk = animations:FindFirstChild("Walk")

						if walk and walk:IsA("Animation") then
							runAnimationId = walk.AnimationId
						end
					end
				end
			end

			local selectedCharacter = player:GetAttribute("SelectedCharacter")

			if selectedCharacter and v[selectedCharacter] then
				v14 = v10 == "run" and 2 or 1
			end

			if runAnimationId then
				local animation = Instance.new("Animation")
				animation.AnimationId = runAnimationId
				animation.Name = "Treadmill" .. (v10 == "run" and "Run" or "Walk")
				local track = humanoid:LoadAnimation(animation)
				track.Looped = true
				local config = character:FindFirstChild("Config")

				if (config and config:FindFirstChild("ModuleName") and config.ModuleName.Value) == "Eggson" then
					track.Priority = Enum.AnimationPriority.Action3
				else
					track.Priority = Enum.AnimationPriority.Action4
				end

				track:Play(0.1)

				if flag2 then
					track:AdjustSpeed(v14 * animationBoost)
				else
					track:AdjustSpeed(v14)
				end

				v7 = track
			end
		end
	end

	local function animateMachine(p3, _)
		if not flag then
			return
		end

		local v10 = not (p3 > 0.1) and 1 or 1 + p3 / 16 * 1.5
		total2 += (v10 - total2) * 0.1

		if value then
			local tween = TweenService:Create(
				value,
				TweenInfo.new(0.5 / total2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
				{
					Rotation = value.Rotation + createVector(0, 360, 0)
				}
			)
			local v11 = (total2 - 1) * 0.1 + 1
			local tween2 = TweenService:Create(value, TweenInfo.new(0.2), {
				Size = size * v11
			})
			tween:Play()
			tween2:Play()
		end

		if value2 then
			local v11 = math.clamp(total2 - 0.5, 0, 1)
			local color = Color3.fromRGB(
				math.floor(v11 * 90 + 165),
				math.floor(v11 * 161 + 54),
				(math.floor(v11 * 74 + 56))
			)
			TweenService:Create(value2, TweenInfo.new(0.3), {
				Color = color
			}):Play()
		end

		animateTreadmillCharacter()
	end

	local now2 = tick()
	local lastTime = tick()
	tick()
	tick()
	local now3 = tick()
	local v10 = 0

	local function trackMovement()
		local now4 = tick()

		if now4 - v10 < 0.05 then
			return
		end

		v10 = now4

		if instance.Stats.Completed.Value == true then
			if flag then
				fn()
			end
		elseif flag and character and character.Parent and character.PrimaryPart then
			local _ = p and p.Value and p.Value.Parent
			local v11 = now4 - now2
			now2 = now4
			local stats = character:FindFirstChild("Stats")
			local v12

			if stats then
				local sprinting = stats:FindFirstChild("Sprinting")
				stats:FindFirstChild("HoldingSprint")
				stats:FindFirstChild("CurrentStamina")
				stats:FindFirstChild("Stamina")
				local speedModifier = stats:FindFirstChild("SpeedModifier")
				local runSpeedModifier = stats:FindFirstChild("RunSpeedModifier")
				local walkSpeed = stats:FindFirstChild("WalkSpeed")
				local runSpeed = stats:FindFirstChild("RunSpeed")
				stats:FindFirstChild("StaminaRegenModifier")
				local value3 = 16
				local value4 = 1

				if sprinting and sprinting.Value == true then
					if runSpeed then
						value3 = runSpeed.Value
					end

					if runSpeedModifier then
						value4 = runSpeedModifier.Value
					end
				else
					if walkSpeed then
						value3 = walkSpeed.Value
					end

					if speedModifier then
						value4 = speedModifier.Value
					end
				end

				v12 = value3 * value4
				local v13 = math.min(v12, 80) * v11

				if v13 > 0.1 then
					total += v13
					updateProgress(v13)

					if character and p and p.Value then
						local trinkets = character:FindFirstChild("Trinkets")

						if trinkets then
							local trinket1 = trinkets:FindFirstChild("Trinket1")
							local trinket2 = trinkets:FindFirstChild("Trinket2")
							local child2 = trinket1 and trinket1.Value ~= "None" and ReplicatedStorage.TrinketData:FindFirstChild(trinket1.Value)

							if child2 then
								local _, _ = pcall(function()
									local module = require(child2)

									if module.MachineEvent and typeof(module.TriggerMachineEvent) == "function" then
										module.TriggerMachineEvent(trinket1, instance, p)
									end
								end)
							end

							if trinket2 and trinket2.Value ~= "None" then
								local child3 = ReplicatedStorage.TrinketData:FindFirstChild(trinket2.Value)

								if child3 then
									local _, _ = pcall(function()
										local module = require(child3)

										if module.MachineEvent and typeof(module.TriggerMachineEvent) == "function" then
											module.TriggerMachineEvent(trinket2, instance, p)
										end
									end)
								end
							end
						end
					end
				end
			else
				v12 = 0
			end

			if not flag2 and now4 - now3 >= 4 and flag then
				local v13 = stats and v12 > 0.1
				local treadmillSkillCheckActive = character:GetAttribute("TreadmillSkillCheckActive")

				if v13 and not treadmillSkillCheckActive then
					character:SetAttribute("TreadmillSkillCheckActive", true)
					flag2 = true
					animationBoost = math.random(300, 500) / 100
					v6 = now4

					if v4 then
						v4.Enabled = false
						v4:Destroy()
						v4 = nil
					end

					v4 = createTreadmillParticle("Drops")

					if v7 and v7.IsPlaying then
						local v14 = v8
						local selectedCharacter = player:GetAttribute("SelectedCharacter")
						local v15 = not (selectedCharacter and v[selectedCharacter]) and 1 or v14 == "run" and 2 or 1
						v7:AdjustSpeed(v15 * animationBoost)
					end

					character:SetAttribute("TreadmillAnimationBoost", animationBoost)

					local function invokeClientTreadmillSkillCheck(player2, value3, p3)
						local skillcheckUpdate = ReplicatedStorage.Events.SkillcheckUpdate
						local flag3 = false
						local v14 = nil
						coroutine.wrap(function()
							local _, _ = pcall(function()
								v14 = skillcheckUpdate:InvokeClient(player2, instance, {
									type = "treadmill",
									boundarySize = value3,
									animationBoost = animationBoost
								})
							end)
							flag3 = true
						end)()
						local lastTime2 = tick()

						while not flag3 and tick() - lastTime2 < p3 do
							if not flag then
								return "noinput"
							end

							local RunService2 = game:GetService("RunService")
							RunService2.Heartbeat:Wait()
						end

						if flag3 then
							return v14
						end

						return "noinput"
					end

					local v14 = invokeClientTreadmillSkillCheck(
						player,
						character:WaitForChild("Stats"):WaitForChild("BoundarySize").Value,
						5
					)
					flag2 = false
					character:SetAttribute("TreadmillSkillCheckActive", nil)

					if flag then
						if v14 == true then
							updateProgress(instance.Stats.RequiredAmount.Value * 0.05)
							local trinkets = character and p and p.Value and character:FindFirstChild("Trinkets")

							if trinkets then
								local trinket1 = trinkets:FindFirstChild("Trinket1")
								local trinket2 = trinkets:FindFirstChild("Trinket2")
								local child2 = trinket1 and trinket1.Value ~= "None" and ReplicatedStorage.TrinketData:FindFirstChild(trinket1.Value)

								if child2 then
									local success, result = pcall(function()
										local module = require(child2)

										if module.SkillCheckCompleteEvent and typeof(module.TriggerSkillCheckCompleteEvent) == "function" then
											module.TriggerSkillCheckCompleteEvent(trinket1, instance, p)
										end
									end)

									if not success then
										warn(
											"[TreadmillTapSkillCheck] Failed to trigger trinket 1 complete event:",
											result
										)
									end
								end

								local child3 = trinket2 and trinket2.Value ~= "None" and ReplicatedStorage.TrinketData:FindFirstChild(trinket2.Value)

								if child3 then
									local success, result = pcall(function()
										local module = require(child3)

										if module.SkillCheckCompleteEvent and typeof(module.TriggerSkillCheckCompleteEvent) == "function" then
											module.TriggerSkillCheckCompleteEvent(trinket2, instance, p)
										end
									end)

									if not success then
										warn(
											"[TreadmillTapSkillCheck] Failed to trigger trinket 2 complete event:",
											result
										)
									end
								end
							end
						elseif v14 == false or v14 == "noinput" then
							if v4 then
								v4.Enabled = false

								if v4.Parent then
									v4.Parent:Destroy()
								else
									v4:Destroy()
								end

								v4 = nil
							end

							if not flag then
								return
							end

							local flag3 = true
							local trinkets = character and p and p.Value and character:FindFirstChild("Trinkets")

							if trinkets then
								local trinket1 = trinkets:FindFirstChild("Trinket1")
								local trinket2 = trinkets:FindFirstChild("Trinket2")
								local child2 = trinket1 and trinket1.Value ~= "None" and ReplicatedStorage.TrinketData:FindFirstChild(trinket1.Value)

								if child2 then
									local success, result = pcall(function()
										local module = require(child2)

										if typeof(module.TriggerSkillCheckFailEvent) == "function" and module.TriggerSkillCheckFailEvent(
											trinket1,
											instance,
											p
										) then
											flag3 = false

											if module.GeneratorSound then
												Audio:Play(module.GeneratorSound, {
													Volume = 0.5,
													Parent = instance
												})
											end

											local displayMessage = module.GeneratorText and ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("DisplayMessage")

											if displayMessage then
												displayMessage:FireClient(
													player,
													module.GeneratorText,
													Color3.fromRGB(100, 255, 100)
												)
											end
										end
									end)

									if not success then
										warn("[TreadmillTapSkillCheck] Failed to check trinket 1 fail event:", result)
									end
								end

								local child3 = flag3 and trinket2 and trinket2.Value ~= "None" and ReplicatedStorage.TrinketData:FindFirstChild(trinket2.Value)

								if child3 then
									local success, result = pcall(function()
										local module = require(child3)

										if typeof(module.TriggerSkillCheckFailEvent) == "function" and module.TriggerSkillCheckFailEvent(
											trinket2,
											instance,
											p
										) then
											flag3 = false

											if module.GeneratorSound then
												Audio:Play(module.GeneratorSound, {
													Volume = 0.5,
													Parent = instance
												})
											end

											local displayMessage = module.GeneratorText and ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("DisplayMessage")

											if displayMessage then
												displayMessage:FireClient(
													player,
													module.GeneratorText,
													Color3.fromRGB(100, 255, 100)
												)
											end
										end
									end)

									if not success then
										warn("[TreadmillTapSkillCheck] Failed to check trinket 2 fail event:", result)
									end
								end
							end

							if flag3 then
								local v15 = prompt or instance:FindFirstChild("Prompt")
								local fail = v15 and v15:FindFirstChild("Fail")

								if fail and fail.Playing ~= true then
									fail:Play()
								end

								local success, result = pcall(function()
									ReplicatedStorage.Events.MachineEvent:Fire(character, instance)
								end)

								if not success then
									warn("[TreadmillTapSkillCheck] Failed to alert monsters:", result)
								end
							end

							local success, result = pcall(function()
								local DebuffManager = require(ReplicatedStorage.Modules.Gameplay.DebuffManager)

								if DebuffManager.ApplyTreadmillDazed(character, 1, 3) then
								end
							end)

							if not success then
								warn("[TreadmillTapSkillCheck] Failed to apply debuff via DebuffManager:", result)
							end
						end

						animationBoost = 1

						if v7 and v7.IsPlaying then
							local v15 = v8
							local selectedCharacter = player:GetAttribute("SelectedCharacter")
							local v16 = not (selectedCharacter and v[selectedCharacter]) and 1 or v15 == "run" and 2 or 1
							v7:AdjustSpeed(v16)
						end

						character:SetAttribute("TreadmillAnimationBoost", nil)

						if v4 then
							v4.Enabled = false

							if v4.Parent then
								v4.Parent:Destroy()
							else
								v4:Destroy()
							end

							v4 = nil
						end

						now3 = tick()
					else
						if not v4 then
							return
						end

						v4.Enabled = false

						if v4.Parent then
							v4.Parent:Destroy()
						end

						v4 = nil
						return
					end
				end
			end

			local value3 = stats and stats:FindFirstChild("Sprinting") and stats.Sprinting.Value
			animateMachine(v12, value3)
		elseif flag and not (character and character.Parent) then
			fn()
		end
	end

	task.spawn(function()
		if v7 and v7.IsPlaying then
			return
		end

		v8 = "idle"
		animateTreadmillCharacter()
	end)
	v3.movementConnection = RunService.Heartbeat:Connect(trackMovement)
	v3.walkAnimConnection = character:GetAttributeChangedSignal("WalkAnimationId"):Connect(function()
		if flag then
		end
	end)
	v3.runAnimConnection = character:GetAttributeChangedSignal("RunAnimationId"):Connect(function()
		if flag then
		end
	end)
	v3.animSetConnection = character:GetAttributeChangedSignal("AnimSet"):Connect(function() end)
	v3.completionConnection = instance.Stats.CurrentAmount.Changed:Connect(function()
		if instance.Stats.CurrentAmount.Value >= instance.Stats.RequiredAmount.Value then
			local _ = tick() - lastTime
		end
	end)
	v3.characterRemovingConnection = character:GetPropertyChangedSignal("Parent"):Connect(function()
		if not character.Parent then
			fn()
		end
	end)
	v3.humanoidDiedConnection = humanoid.Died:Connect(function()
		fn()
	end)

	fn = function()
		flag = false
		flag2 = false

		if removeCharacterAntiExploitModule then
			removeCharacterAntiExploitModule:Fire(player, false)
		end

		local success, result = pcall(function()
			if character and character:GetAttribute("TreadmillSkillCheckActive") then
				character:SetAttribute("TreadmillSkillCheckActive", nil)
				local skillcheckUpdate = ReplicatedStorage.Events.SkillcheckUpdate
				pcall(function()
					if player and player.Parent then
						skillcheckUpdate:FireClient(player, "cancel")
					end
				end)
			end
		end)

		if not success then
			warn("[MovementTreadmill] Failed to force stop skill checks:", result)
		end

		if character then
			character:SetAttribute("TreadmillSkillCheckReady", nil)
			character:SetAttribute("TreadmillSkillCheckResult", nil)
			character:SetAttribute("TreadmillSkillCheckTime", nil)
			character:SetAttribute("TreadmillAnimationBoost", nil)
			character:SetAttribute("TreadmillSkillCheckActive", nil)
		end

		for _, connection in pairs(v3) do
			if not connection then
				continue
			end

			if typeof(connection) == "RBXScriptConnection" then
				connection:Disconnect()
			elseif typeof(connection) == "thread" then
				task.cancel(connection)
			end
		end

		if value then
			TweenService:Create(value, TweenInfo.new(1), {
				Size = size,
				Rotation = createVector(0, 0, 0)
			}):Play()
		end

		if value2 then
			TweenService:Create(value2, TweenInfo.new(1), {
				Color = Color3.fromRGB(165, 54, 56)
			}):Play()
		end

		if v4 then
			v4.Enabled = false

			if v4.Parent then
				v4.Parent:Destroy()
			end

			v4 = nil
		end

		if v7 then
			pcall(function()
				if v7.IsPlaying then
					v7:Stop(0)
				end

				v7:Destroy()
			end)
			v7 = nil
		end

		local humanoid2 = character and character:FindFirstChild("Humanoid")

		if humanoid2 then
			local playingAnimationTracks = humanoid2:GetPlayingAnimationTracks()

			for _, playingAnimationTrack in pairs(playingAnimationTracks) do
				local v11 = playingAnimationTrack
				pcall(function()
					local v12 = not v11.Animation and "" or v11.Animation.Name or ""

					if v12:find("Treadmill") or v11.Priority == Enum.AnimationPriority.Action4 or v12:find("Walk") and v11.Priority >= Enum.AnimationPriority.Action or v12:find("Run") and v11.Priority >= Enum.AnimationPriority.Action then
						v11:Stop(0)
						v11:Destroy()
					end
				end)
			end
		end

		if character then
			character:SetAttribute("TreadmillMode", nil)
			character:SetAttribute("DisableQuirks", nil)
			character:SetAttribute("DisableSprintAnimations", nil)
			character:SetAttribute("TreadmillForceMovement", nil)
		end
	end

	return {
		Stop = fn,
		GetTotalDistance = function()
			return total
		end,
		IsActive = function()
			return flag
		end
	}
end

return MovementTreadmillGenerator