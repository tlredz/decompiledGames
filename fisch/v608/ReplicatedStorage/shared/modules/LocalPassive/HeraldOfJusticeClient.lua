local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local SoundService = game:GetService("SoundService")
local Sprite = require(script.modules:FindFirstChild("Sprite"))
local SmokeParticles = require(script.modules:FindFirstChild("SmokeParticles"))
local module = require("./PassiveHandler")
require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("library"):WaitForChild("rods"))
local total = 0
local color = Color3.fromRGB(255, 220, 80)
local color2 = Color3.fromRGB(255, 255, 200)
local color3 = Color3.fromRGB(255, 255, 255)
local color4 = Color3.fromRGB(160, 140, 100)
local color5 = Color3.fromRGB(255, 240, 150)
local localPlayer = Players.LocalPlayer
local active = workspace:WaitForChild("active")
local stars = script.assets:FindFirstChild("Stars")
local impact = script.assets:FindFirstChild("Impact")
local stunnedStars = script.assets:FindFirstChild("StunnedStars")
local bonk = script.assets:FindFirstChild("Bonk")
local smoke = script.assets:FindFirstChild("Smoke")
local cartoonhammer = script.assets:FindFirstChild("cartoon-hammer")
local boom = script.assets:FindFirstChild("Boom")
local axeIcon = script.assets:FindFirstChild("axeIcon")
local slashZone = script.assets:FindFirstChild("slashZone")
local timerLabel = script.assets:FindFirstChild("timerLabel")
local statusLabel = script.assets:FindFirstChild("statusLabel")

-- equivalent calls inferred from this helper; original call sites unknown
local function tween(p, tweenInfo, p2, fn)
	local tween2 = TweenService:Create(p, tweenInfo, p2)
	tween2.Completed:Once(function()
		tween2:Destroy()

		if fn then
			fn()
		end
	end)
	tween2:Play()
	return tween2
end

local function getOwnedFishModel()
	local descendants = active:QueryDescendants((`[$OwnerId = {localPlayer.UserId}]`))
	return #descendants > 0 and descendants[1] or nil
end

local function emitParticleEmitters(folder)
	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end
end

local function setVfxEnabled(folder, enabled: boolean)
	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
			continue
		end

		effect.Enabled = enabled
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function attachStarsVfx(parent)
	local clone = stars:Clone()
	clone.Parent = parent
	setVfxEnabled(clone, false)
	return clone
end

local function spawnImpactDots(icon)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "ImpactDots"
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.Position = UDim2.fromScale(0.25, 0.5)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.BackgroundTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Visible = true
	imageLabel.ZIndex = 7
	imageLabel.Image = impact.Image
	imageLabel.ImageColor3 = Color3.fromRGB(255, 220, 80)
	imageLabel.Parent = icon
	local uIScale = Instance.new("UIScale")
	uIScale.Scale = 1
	uIScale.Parent = imageLabel
	local tween2 = TweenService:Create(uIScale, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {
		Scale = 4
	})
	local v = nil
	tween2.Completed:Once(function()
		tween2:Destroy()

		if v then
			v()
		end
	end)
	tween2:Play()

	local function fn()
		imageLabel:Destroy()
	end

	tween(imageLabel, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {
		ImageTransparency = 1
	}, fn) -- equivalent call inferred; original call site unknown
end

local function spawnImpactBonkVfx(parent, cframe: CFrame)
	local impactBonk = script:FindFirstChild("ImpactBonk")

	if not impactBonk then
		return
	end

	local clone = impactBonk:Clone()
	clone.Parent = parent
	clone:PivotTo(parent.CFrame * cframe)
	emitParticleEmitters(clone)
	task.delay(2, function()
		if clone and clone.Parent then
			clone:Destroy()
		end
	end)
end

local HeraldOfJusticeClient = {
	Morph = function(p, instance, object)
		if not object.rod then
			warn("Herald of Justice passive canceled: no active rod tool!")
			return
		end

		local bobber = object.rod:FindFirstChild("bobber")
		local fish = instance:FindFirstChild("fish")
		local icon = fish and fish:FindFirstChild("icon")
		local progress = instance:FindFirstChild("progress")
		local bar = progress and progress:FindFirstChild("bar")
		local reel_bar = object.reel_bar

		if not icon then
			return
		end

		local config = p.config
		task.spawn(ContentProvider.PreloadAsync, ContentProvider, { script.assets })
		task.spawn(function()
			object:WaitUntilReady()
			local cast_power = object.cast_power
			local value = bobber and (bobber:IsA("ObjectValue") and bobber.Value or bobber)
			local v = 0
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "StunnedSprite"
			imageLabel.Size = UDim2.fromScale(0.4, 0.4)
			imageLabel.Position = UDim2.fromScale(0.5, 0.5)
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.Visible = false
			imageLabel.BackgroundTransparency = 1
			imageLabel.ScaleType = Enum.ScaleType.Fit
			imageLabel.Image = stunnedStars.Image
			imageLabel.Parent = icon
			local uIScale = Instance.new("UIScale")
			uIScale.Scale = 6
			uIScale.Parent = imageLabel
			local v2 = Sprite.new({
				gui = imageLabel,
				frameWidth = 204,
				frameHeight = 204,
				startFrame = 1,
				endFrame = 23,
				columns = 5,
				rows = 5,
				fps = 24,
				loop = true
			})
			v2:Stop()
			local clone4 = attachStarsVfx(value) -- equivalent call inferred; original call site unknown
			local v4 = false
			local total2 = 0
			local SLASH_COOLDOWN = 0
			local flag = false
			local v5 = 0
			local v6 = config.SLASH_ZONE_WIDTH / 2
			local total3 = 0
			local clone = slashZone:Clone()
			clone.Size = UDim2.new(config.SLASH_ZONE_WIDTH, 0, 1, 0)
			clone.BackgroundColor3 = color
			clone.Parent = reel_bar
			local uIScale2 = Instance.new("UIScale")
			uIScale2.Scale = 0
			uIScale2.Parent = clone
			local uIStroke = clone.UIStroke
			local clone_2 = axeIcon:Clone()
			clone_2.Parent = clone
			local clone2 = timerLabel:Clone()
			clone2.Parent = clone
			object.trove:Add(function()
				v2:Destroy()
				imageLabel:Destroy()
				clone:Destroy()

				if clone4 and clone4.Parent then
					clone4:Destroy()
				end
			end)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateStars(p2: number)
				if not clone4 then
					return
				end

				total += p2 * 8
				clone4:PivotTo(value.CFrame * CFrame.new(0, 3, 0) * CFrame.Angles(0, total, 0))
			end

			local function playStunUIBurst()
				local imageLabel2 = Instance.new("ImageLabel")
				imageLabel2.Name = "Bonk"
				imageLabel2.Size = UDim2.fromScale(1, 1)
				imageLabel2.Position = UDim2.fromScale(0.5, 0.5)
				imageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
				imageLabel2.BackgroundTransparency = 1
				imageLabel2.ZIndex = 10
				imageLabel2.ScaleType = Enum.ScaleType.Fit
				imageLabel2.Rotation = math.random(-15, 15)
				imageLabel2.Image = bonk.Image
				imageLabel2.ImageColor3 = Color3.fromRGB(255, 230, 120)
				imageLabel2.Parent = icon
				local uIScale3 = Instance.new("UIScale")
				uIScale3.Scale = 1
				uIScale3.Parent = imageLabel2
				SoundService:PlayLocalSound(cartoonhammer)
				spawnImpactDots(icon)
				SmokeParticles.Play(icon, {
					image = smoke.Image,
					distMin = 3,
					distMax = 5,
					startScaleMin = 1,
					startScaleMax = 2
				})
				local tween2 = TweenService:Create(uIScale3, TweenInfo.new(0.4, Enum.EasingStyle.Elastic), {
					Scale = 4
				})
				local v7 = nil
				tween2.Completed:Once(function()
					tween2:Destroy()

					if v7 then
						v7()
					end
				end)
				tween2:Play()
				local tween3 = TweenService:Create(imageLabel2, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {
					Position = UDim2.fromScale(0.5, -math.random(10, 20) / 10)
				})
				local v9 = nil
				tween3.Completed:Once(function()
					tween3:Destroy()

					if v9 then
						v9()
					end
				end)
				tween3:Play()
				task.delay(0.4, function()
					local function fn()
						imageLabel2:Destroy()
					end

					tween(imageLabel2, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
						ImageTransparency = 1
					}, fn) -- equivalent call inferred; original call site unknown
				end)
			end

			local function enableStunVfx()
				imageLabel.Visible = true
				v2:Play()
				spawnImpactBonkVfx(value, CFrame.new(0, 3, 0))

				if clone4 then
					setVfxEnabled(clone4, true)
				end

				playStunUIBurst()
				object.fx:SpawnShake(instance, 0.5, 3, 0.01, true)
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function disableStunVfx()
				if clone4 then
					setVfxEnabled(clone4, false)
				end

				imageLabel.Visible = false
				v2:Stop()
			end

			local function showSlashZone()
				v5 = math.random() * (1 - config.SLASH_ZONE_WIDTH) + v6
				clone.Position = UDim2.new(v5, 0, 0, 0)
				clone.BackgroundColor3 = color
				clone.Visible = true
				flag = true
				total3 = 0
				uIScale2.Scale = 0
				local tween2 = TweenService:Create(
					uIScale2,
					TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						Scale = 1
					}
				)
				local v8 = nil
				tween2.Completed:Once(function()
					tween2:Destroy()

					if v8 then
						v8()
					end
				end)
				tween2:Play()
			end

			local function hideSlashZone()
				flag = false

				local function fn()
					clone.Visible = false
					uIScale2.Scale = 0
				end

				tween(uIScale2, TweenInfo.new(0.12, Enum.EasingStyle.Quint), {
					Scale = 0
				}, fn) -- equivalent call inferred; original call site unknown
			end

			local function barOverlapsZone()
				return object:IsInBar(v5, config.SLASH_ZONE_WIDTH)
			end

			local function spawnFeedbackLabel(text: string, color6: Color3)
				local clone3 = statusLabel:Clone()
				clone3.Size = UDim2.new(config.SLASH_ZONE_WIDTH * 2.5, 0, 0, 22)
				clone3.Position = UDim2.new(v5, 0, -0.05, 0)
				clone3.Text = text
				clone3.TextColor3 = color6
				clone3.Parent = reel_bar
				local uIScale3 = Instance.new("UIScale")
				uIScale3.Scale = 0.6
				uIScale3.Parent = clone3
				local tween2 = TweenService:Create(
					uIScale3,
					TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						Scale = 1
					}
				)
				local v7 = nil
				tween2.Completed:Once(function()
					tween2:Destroy()

					if v7 then
						v7()
					end
				end)
				tween2:Play()
				local tween3 = TweenService:Create(clone3, TweenInfo.new(0.55, Enum.EasingStyle.Quint), {
					Position = UDim2.new(v5, 0, -0.45, 0)
				})
				local v9 = nil
				tween3.Completed:Once(function()
					tween3:Destroy()

					if v9 then
						v9()
					end
				end)
				tween3:Play()
				task.delay(0.3, function()
					local function fn()
						clone3:Destroy()
					end

					tween(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
						TextTransparency = 1
					}, fn) -- equivalent call inferred; original call site unknown
				end)
			end

			local function spawnAxe()
				local character = localPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart then
					return
				end

				local heraldofJusticeProp = ReplicatedStorage.resources.replicated.instances.general:FindFirstChild("HeraldofJusticeProp")

				if not heraldofJusticeProp then
					return
				end

				local clone3 = heraldofJusticeProp:Clone()
				local primaryPart = clone3.PrimaryPart
				primaryPart.Anchored = true
				primaryPart.PivotOffset *= CFrame.new(0, 2.5, 0)
				local v7 = CFrame.new(value.Position) * humanoidRootPart.CFrame.Rotation
				local v8 = v7 * CFrame.new(0, 0, -30)
				local v9 = v7 * CFrame.new(0, 0, -30) * CFrame.Angles(1.5707963267948966, 0, 0)
				clone3:PivotTo(v8)
				clone3.Name = localPlayer.Name
				clone3.Parent = workspace.active.debrisfx
				local total4 = 0
				local v10 = false
				task.spawn(function()
					while true do
						local v11 = RunService.RenderStepped:Wait()

						if not clone3.Parent then
							break
						end

						total4 += v11
						clone3:PivotTo(v8:Lerp(
							v9,
							(TweenService:GetValue(
								math.clamp(total4 / 0.75, 0, 1),
								Enum.EasingStyle.Back,
								Enum.EasingDirection.In
							))
						))

						if not v10 and total4 >= 0.675 then
							v10 = true
							object.fx:SpawnShake(instance, 0.5, 5, 0.01, true)
							SoundService:PlayLocalSound(cartoonhammer)
							object:FreezeFish(config.SLASH_STUN_DURATION)
							object:AddProgress(config.SLASH_PROGRESS_BONUS)
							enableStunVfx()
							v4 = true
							v = os.clock() + config.SLASH_STUN_DURATION
						end

						if total4 >= 0.75 then
							break
						end
					end

					task.delay(1, function()
						if clone3 and clone3.Parent then
							clone3:Destroy()
						end
					end)
				end)
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function playHitFeedback()
				clone.BackgroundColor3 = color3
				clone.BackgroundTransparency = 0
				uIStroke.Color = color3
				spawnFeedbackLabel("SLASH!", color5)
				spawnAxe()
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function playMissFeedback()
				clone.BackgroundColor3 = color4
				clone.BackgroundTransparency = 0.45
				uIStroke.Color = color4
				spawnFeedbackLabel("MISS..", color4)
			end

			local v7 = (cast_power / 100) ^ 2 * config.MAX_INITIAL_PROGRESS

			if v7 > 0 then
				local v8 = math.clamp(v7 / config.MAX_INITIAL_PROGRESS, 0, 1)
				local lerped = Color3.fromRGB(71, 255, 43):Lerp(Color3.fromRGB(255, 200, 0), v8)
				local imageLabel2 = Instance.new("ImageLabel")
				imageLabel2.Name = "Boom"
				imageLabel2.Size = UDim2.fromScale(0.3, 1)
				imageLabel2.Position = UDim2.fromScale(0, 0.5)
				imageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
				imageLabel2.BackgroundTransparency = 1
				imageLabel2.ZIndex = 10
				imageLabel2.ScaleType = Enum.ScaleType.Fit
				imageLabel2.Rotation = math.random(-5, 5)
				imageLabel2.Image = boom.Image
				imageLabel2.ImageColor3 = Color3.fromRGB(255, 230, 100)
				imageLabel2.Parent = progress
				bar.BackgroundColor3 = lerped
				local uIScale3 = Instance.new("UIScale")
				uIScale3.Scale = 1
				uIScale3.Parent = imageLabel2
				local tween2 = TweenService:Create(uIScale3, TweenInfo.new(0.4, Enum.EasingStyle.Elastic), {
					Scale = 8
				})
				local v9 = nil
				tween2.Completed:Once(function()
					tween2:Destroy()

					if v9 then
						v9()
					end
				end)
				tween2:Play()
				task.delay(0.8, function()
					local tween3 = TweenService:Create(
						bar,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						}
					)
					local v12 = nil
					tween3.Completed:Once(function()
						tween3:Destroy()

						if v12 then
							v12()
						end
					end)
					tween3:Play()

					local function fn()
						imageLabel2:Destroy()
					end

					tween(imageLabel2, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
						ImageTransparency = 1
					}, fn) -- equivalent call inferred; original call site unknown
				end)
				object:TweenModifier("progress", "add", 0, v7, TweenInfo.new(0.5))
			end

			if object.cast_power and object.cast_power >= 96 and math.random() <= config.PERFECT_STUN_CHANCE then
				v = os.clock() + config.PERFECT_STUN_DURATION
				object:FreezeFish(config.PERFECT_STUN_DURATION)
				enableStunVfx()
				v4 = true
			end

			object.trove:Add(object.OnLogicStep:Connect(function(p2)
				if not (instance and instance.Parent) then
					return
				end

				updateStars(p2) -- equivalent call inferred; original call site unknown
				v2:Update(p2)
				local v8 = os.clock() < v

				if v8 and not v4 then
					enableStunVfx()
				elseif not v8 and v4 then
					disableStunVfx() -- equivalent call inferred; original call site unknown
				end

				v4 = v8

				if SLASH_COOLDOWN > 0 then
					SLASH_COOLDOWN -= p2

					if SLASH_COOLDOWN <= 0 then
						total2 = 0
					end
				elseif flag then
					total2 += p2
					total3 += p2
					local v9 = math.clamp(total2 / config.SLASH_INTERVAL, 0, 1)
					local v10 = math.max(config.SLASH_INTERVAL - total2, 0)
					clone2.Text = string.format("%.1f", v10)

					if v9 >= 0.6699999999999999 then
						local v11 = (v9 - 0.6699999999999999) / 0.33
						local v12 = v11 * 5 + 3
						local midpoint = (math.sin(total3 * v12 * 3.141592653589793 * 2) + 1) / 2
						clone.BackgroundColor3 = color:Lerp(color2, v11):Lerp(
							Color3.fromRGB(255, 255, 255),
							midpoint * 0.35
						)
						clone.BackgroundTransparency = (1 - midpoint) * 0.2 + 0.1
						uIStroke.Color = color2:Lerp(Color3.fromRGB(255, 255, 255), midpoint * 0.6)
					else
						clone.BackgroundColor3 = color
						clone.BackgroundTransparency = 0.25
						uIStroke.Color = Color3.fromRGB(255, 255, 200)
					end

					if total2 < config.SLASH_INTERVAL then
						return
					end

					if object:IsInBar(v5, config.SLASH_ZONE_WIDTH) then
						playHitFeedback() -- equivalent call inferred; original call site unknown
					else
						playMissFeedback() -- equivalent call inferred; original call site unknown
					end

					task.delay(0.18, hideSlashZone)
					total2 = 0
					SLASH_COOLDOWN = config.SLASH_COOLDOWN
				else
					total2 += p2

					if total2 >= config.SLASH_INTERVAL then
						showSlashZone()
						total2 = 0
					end
				end
			end))
		end)
	end
}
setmetatable(HeraldOfJusticeClient, module)
return HeraldOfJusticeClient