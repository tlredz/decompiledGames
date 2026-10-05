game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("ContentProvider")
local SoundService = game:GetService("SoundService")
local Sprite = require(script.modules:FindFirstChild("Sprite"))
local SmokeParticles = require(script.modules:FindFirstChild("SmokeParticles"))
local module = require("./PassiveHandler")
require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("library"):WaitForChild("rods"))
local total = 0
local localPlayer = Players.LocalPlayer
local active = workspace:WaitForChild("active")
local stars = script.assets:FindFirstChild("Stars")
local impact = script.assets:FindFirstChild("Impact")
local stunnedStars = script.assets:FindFirstChild("StunnedStars")
local bonk = script.assets:FindFirstChild("Bonk")
local smoke = script.assets:FindFirstChild("Smoke")
local cartoonhammer = script.assets:FindFirstChild("cartoon-hammer")
local boom = script.assets:FindFirstChild("Boom")

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

-- equivalent calls inferred from this helper; original call sites unknown
local function getOwnedFishModel()
	local descendants = active:QueryDescendants((`[$OwnerId = {localPlayer.UserId}]`))

	if #descendants > 0 then
		return descendants[1]
	end

	return nil
end

local function emitParticleEmitters(folder)
	local descendants = folder:GetDescendants()

	for i = 1, #descendants do
		local emitter = descendants[i]

		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end
end

local function setVfxEnabled(folder, enabled: boolean)
	local descendants = folder:GetDescendants()

	for _, effect in descendants do
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
	imageLabel.ImageColor3 = Color3.fromRGB(255, 0, 0)
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
	return imageLabel, uIScale
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

local Tidemourner = {
	Morph = function(p, instance, object)
		if not object.rod then
			warn("Tidemourner passive canceled: No active rod tool!")
			return
		end

		local bobber = object.rod:FindFirstChild("bobber")
		local icon = instance:FindFirstChild("fish"):FindFirstChild("icon")
		local progress = instance:FindFirstChild("progress")
		local bar = progress:FindFirstChild("bar")

		if not icon then
			return
		end

		local config = p.config
		object:Preload({ script.assets })
		task.spawn(function()
			object:WaitUntilReady()
			local cast_power = object.cast_power

			if not cast_power then
				warn("No cast power data for the current reel!")
				return
			end

			-- equivalent call inferred; original call site unknown
			if not getOwnedFishModel() then
				warn((`Could not find fish model! "{instance.Name}"`))
				return
			end

			local value = bobber and (bobber:IsA("ObjectValue") and bobber.Value or bobber)

			if not value then
				warn((`Could not find bobber part! "{instance.Name}"`))
				return
			end

			local total2 = 0
			local v = 0
			local v2 = 0
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
			local v3 = Sprite.new({
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
			v3:Stop()
			local clone = attachStarsVfx(value) -- equivalent call inferred; original call site unknown
			local v5 = false
			object.trove:Add(function()
				v3:Destroy()
				imageLabel:Destroy()

				if clone and clone.Parent then
					clone:Destroy()
				end
			end)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateStars(p2: number)
				if not clone then
					return
				end

				total += p2 * 8
				clone:PivotTo(value.CFrame * CFrame.new(0, 3, 0) * CFrame.Angles(0, total, 0))
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
				imageLabel2.Parent = icon
				local uIScale2 = Instance.new("UIScale")
				uIScale2.Scale = 1
				uIScale2.Parent = imageLabel2
				SoundService:PlayLocalSound(cartoonhammer)
				spawnImpactDots(icon)
				SmokeParticles.Play(icon, {
					image = smoke.Image,
					distMin = 3,
					distMax = 5,
					startScaleMin = 1,
					startScaleMax = 2
				})
				local tween2 = TweenService:Create(uIScale2, TweenInfo.new(0.4, Enum.EasingStyle.Elastic), {
					Scale = 4
				})
				local v6 = nil
				tween2.Completed:Once(function()
					tween2:Destroy()

					if v6 then
						v6()
					end
				end)
				tween2:Play()
				local tween3 = TweenService:Create(imageLabel2, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {
					Position = UDim2.fromScale(0.5, -math.random(10, 20) / 10)
				})
				local v8 = nil
				tween3.Completed:Once(function()
					tween3:Destroy()

					if v8 then
						v8()
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
				v3:Play()
				spawnImpactBonkVfx(value, CFrame.new(0, 3, 0))

				if clone then
					setVfxEnabled(clone, true)
				end

				playStunUIBurst()
				object.fx:SpawnShake(instance, 0.5, 3, 0.01, true)
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function disableStunVfx()
				if clone then
					setVfxEnabled(clone, false)
				end

				imageLabel.Visible = false
				v3:Stop()
			end

			local v6 = (cast_power / 100) ^ 2 * config.MAX_INITIAL_PROGRESS

			if v6 > 0 then
				local v7 = math.clamp(v6 / config.MAX_INITIAL_PROGRESS, 0, 1)
				local lerped = Color3.fromRGB(71, 255, 43):Lerp(Color3.fromRGB(255, 56, 56), v7)
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
				imageLabel2.Parent = progress
				bar.BackgroundColor3 = lerped
				local uIScale2 = Instance.new("UIScale")
				uIScale2.Scale = 1
				uIScale2.Parent = imageLabel2
				local tween2 = TweenService:Create(uIScale2, TweenInfo.new(0.4, Enum.EasingStyle.Elastic), {
					Scale = 8
				})
				local v8 = nil
				tween2.Completed:Once(function()
					tween2:Destroy()

					if v8 then
						v8()
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
					local v11 = nil
					tween3.Completed:Once(function()
						tween3:Destroy()

						if v11 then
							v11()
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
				object:TweenModifier("progress", "add", 0, v6, TweenInfo.new(0.5))
			end

			if object.cast_power and object.cast_power >= 96 and math.random() <= config.PERFECT_STUN_CHANCE then
				v2 = os.clock() + config.PERFECT_STUN_DURATION
				object:FreezeFish(config.PERFECT_STUN_DURATION)
				enableStunVfx()
				v5 = true
			end

			object.trove:Add(object.OnFishExitBar:Connect(function()
				total2 = 0
			end))
			object.trove:Add(object.OnLogicStep:Connect(function(p2)
				if not (instance and instance.Parent) then
					return
				end

				updateStars(p2) -- equivalent call inferred; original call site unknown
				v3:Update(p2)
				local now = os.clock()
				local v7 = now < v2

				if v7 and not v5 then
					enableStunVfx()
				elseif not v7 and v5 then
					disableStunVfx() -- equivalent call inferred; original call site unknown
				end

				v5 = v7

				if not object.onbar then
					total2 = 0
					return
				end

				local v8 = v + config.HAMMER_COOLDOWN <= now
				total2 += p2

				if total2 < config.TIME_ON_BAR_FOR_HAMMER or (not v8 or v7) then
					return
				end

				v = now
				total2 = 0
				v2 = now + config.HAMMER_STUN_DURATION
				object:FreezeFish(config.HAMMER_STUN_DURATION)
				object:AddProgress(config.HAMMER_PROGRESS_BONUS)
				enableStunVfx()
				v5 = true
			end))
		end)
	end
}
setmetatable(Tidemourner, module)
return Tidemourner