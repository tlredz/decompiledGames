local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local numberRange = NumberRange.new(0.4, 1.6)
local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Sine)
local v = { Color3.fromRGB(255, 186, 80), Color3.fromRGB(255, 101, 93), Color3.fromRGB(255, 214, 66) }
local v2 = {}

for k, v3 in v do
	v2[k] = v3:Lerp(Color3.new(), 0.9)
end

local RodOfTheSingularityClient = {
	Morph = function(state, _, object)
		state._random = Random.new()
		state.pulling = false
		local resilience = object.resilience
		local v3 = (state._random:NextInteger(0, 1) == 0 and -0.25 or 0.25) + state._random:NextNumber(-0.1, 0.1)
		local anchorPoint = object.reel_bar.AnchorPoint
		local clone = script.Pull:Clone()
		clone.Playing = true
		clone.Volume = 0
		clone.PlaybackSpeed = numberRange.Min
		clone.Parent = object.reel
		state.reelTrove:Add(clone)
		local modifier = object:CreateModifier("resilience", "force")
		local modifier2 = object:CreateModifier("barMoveSpeed", "force")
		local modifier3 = object:CreateModifier("progressefficiency", "force_add")
		local lastTime = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateFish()
			if lastTime and tick() - lastTime < 0.05 then
				return
			end

			lastTime = tick()

			if object.active then
				object.core.fish:MoveRandom()
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function barUpdate(onbar: boolean)
			state.pulling = onbar
			modifier.Value = onbar and resilience or -1e999
			modifier2.Value = onbar and 0.1 or 1.5
			updateFish() -- equivalent call inferred; original call site unknown
		end

		object.barPosition = 0.5 + v3
		state.reelTrove:Add(object.OnFishEnterBar:Connect(function()
			barUpdate(true) -- equivalent call inferred; original call site unknown
		end))
		state.reelTrove:Add(object.OnFishExitBar:Connect(function()
			barUpdate(false) -- equivalent call inferred; original call site unknown
		end))
		barUpdate(object.onbar) -- equivalent call inferred; original call site unknown
		local icon = object.reel_bar.fish.icon
		local frame = Instance.new("Frame")
		frame.Name = "PullParticles"
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.fromScale(1, 1)
		frame.ZIndex = object.reel_bar.ZIndex - 1
		frame.Parent = object.reel
		state.reelTrove:Add(frame)
		local frame2 = Instance.new("Frame")
		frame2.Name = "Overlay"
		frame2.Size = UDim2.fromScale(1, 1)
		frame2.AnchorPoint = Vector2.new(0, 1)
		frame2.Position = UDim2.fromScale(0, 1)
		frame2.BorderSizePixel = 0
		frame2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		frame2.BackgroundTransparency = 1
		frame2.ZIndex = -100
		frame2.Parent = object.reel
		state.reelTrove:Add(frame2)
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Rotation = 90
		uIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.7, 0),
			NumberSequenceKeypoint.new(1, 0)
		})
		uIGradient.Parent = frame2
		task.defer(function()
			if object.rodName == "Rod of the Singularity" then
				GeneralUtils.fastTween(frame2, tweenInfo, {
					BackgroundTransparency = 0.1
				})
			end
		end)
		local v4 = {}
		local v5 = 0

		local function emitParticle(point: Vector2)
			local number = state._random:NextNumber(11, 21)
			local number2 = state._random:NextNumber(-1.5707963267948966, 1.5707963267948966)
			local number3 = state._random:NextNumber(70, 130)
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.BackgroundTransparency = 1
			imageLabel.Image = "rbxassetid://6673021984"
			imageLabel.ImageColor3 = v[state._random:NextInteger(1, #v)]
			imageLabel.ImageTransparency = 1
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.Size = UDim2.fromOffset(number, number)
			imageLabel.ZIndex = frame.ZIndex
			imageLabel.Parent = frame
			local v6 = point + Vector2.new(math.sin(number2), -math.cos(number2)) * number3
			table.insert(v4, {
				label = imageLabel,
				origin = v6,
				position = v6,
				age = 0,
				life = state._random:NextNumber(0.35, 0.55),
				size = number
			})
		end

		local v6 = 0
		local v7 = 0
		local total = 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stepProgress(p: number)
			if state.pulling then
				v7 = 0
				v6 += state.config.ProgressGain * p
				total += state.config.ProgressGain * p
			else
				v7 = math.min(v7 + state.config.ProgressDecay_Ramp * p, state.config.ProgressDecay_Max)
				v6 = math.max(v6 - v7 * p, 0)
			end

			modifier3.Value = v6 / 100
		end

		local function stepParticles(p: number)
			local v8 = icon.AbsolutePosition + icon.AbsoluteSize / 2

			if state.pulling then
				v5 += p * 50

				while v5 >= 1 do
					v5 -= 1
					emitParticle(v8)
				end
			else
				v5 = 0
			end

			local absolutePosition = frame.AbsolutePosition

			for i = #v4, 1, -1 do
				local v9 = v4[i]
				v9.age += p

				if v9.age >= v9.life then
					v9.label:Destroy()
					table.remove(v4, i)
				else
					local v10 = v9.age / v9.life
					local position = v9.position
					v9.position = v9.origin:Lerp(v8, v10 * v10)
					local v11 = 1 - v10 * 0.65
					local v12 = v9.position - absolutePosition
					local v13 = v9.position - position
					v9.label.Position = UDim2.fromOffset(v12.X, v12.Y)
					v9.label.Size = UDim2.fromOffset(v9.size * v11, v9.size * v11)
					v9.label.ImageTransparency = math.clamp(
						math.max(1 - v10 / 0.2, 0) + math.max((v10 - 0.8) / 0.2, 0),
						0,
						1
					)

					if v13.Magnitude > 0.01 then
						v9.label.Rotation = math.deg((math.atan2(-v13.X, v13.Y)))
					end
				end
			end
		end

		local v8 = 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stepSound(p: number)
			if state.pulling then
				v8 = math.min(v8 + p / 0.4, 1)
			else
				v8 = math.max(v8 - p / 0.6, 0)
			end

			local v9 = v8 * v8 * (3 - v8 * 2)
			clone.Volume = v9 * 0.4
			clone.PlaybackSpeed = numberRange.Min + (numberRange.Max - numberRange.Min) * v9
		end

		local v9 = 0
		local v10 = 1
		local v11 = 0

		local function stepOverlay(p: number)
			if state.pulling and not SettingsController:GetSettingValue("photosensitiveMode") then
				v9 = math.min(v9 + p / 0.5, 1)
			else
				v9 = math.max(v9 - p / 0.5, 0)
			end

			v11 += p

			while v11 >= 0.2 do
				v11 -= 0.2
				v10 = v10 % #v2 + 1
			end

			local v12 = v10 % #v2 + 1
			local lerped = v2[v10]:Lerp(v2[v12], v11 / 0.2)
			local v13 = v9 * v9 * (3 - v9 * 2)
			frame2.BackgroundColor3 = Color3.new():Lerp(lerped, v13)
		end

		local v12 = 0
		local total2 = 0

		local function stepBar(p: number)
			local v13 = v12 * -32 - total2 * 6

			if state.pulling then
				v13 += 11 + state._random:NextNumber(-15, 15)
			end

			total2 += v13 * p
			local v14 = math.clamp(v12 + total2 * p, 0, 1.6)

			if v14 == v12 and (v14 == 0 or v14 == 1.6) then
				total2 = 0
			end

			v12 = v14
			object.reel_bar.AnchorPoint = anchorPoint - Vector2.new(0, v12)

			if not object.active and v12 == 0 and total2 == 0 then
				object.reel_bar.AnchorPoint = anchorPoint
				state._step = nil
			end
		end

		function state._step(p: number)
			if object.active then
				stepProgress(p) -- equivalent call inferred; original call site unknown
				stepParticles(p)
				stepSound(p) -- equivalent call inferred; original call site unknown
				stepOverlay(p)
			end

			stepBar(p)
		end

		state.reelTrove:Add(object.PreMinigameEnd:Connect(function()
			state.pulling = false
			frame:Destroy()
			clone:Destroy()
			GeneralUtils.fastTween(frame2, tweenInfo, {
				BackgroundTransparency = 1
			})
		end))
		state.reelTrove:Add(object.BuildEndingData:Bind(function(p)
			p.Singularity_GrossProgressGain = total
			return p
		end))
	end,
	TickLogic = function(p, p2, p3: number)
		if p2.ready and p._step then
			p._step(p3)
		end
	end
}
setmetatable(RodOfTheSingularityClient, module)
return RodOfTheSingularityClient