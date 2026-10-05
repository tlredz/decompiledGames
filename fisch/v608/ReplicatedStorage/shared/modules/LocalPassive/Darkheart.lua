game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local StatusEffectsController = require(ReplicatedStorage.client.legacyControllers.StatusEffectsController)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local Darkheart = {
	Morph = function(data, _, object)
		local icon = object.reel_bar.fish.icon
		local imageColor3 = icon.ImageColor3
		local clone = script.indicatorContainer:Clone()
		local clones = table.create(data.config.MAX_STACKS)

		for i = 1, data.config.MAX_STACKS do
			local clone2 = script.heartTemplate:Clone()
			clone2.LayoutOrder = i
			clone2.Parent = clone
			clones[i] = clone2
		end

		clone.Parent = object.reel_bar
		local v = 0
		local v2 = 0
		local v3 = StatusEffectsController:GetStatusesOfType("DarkHeart")[1]
		local stack = v3 and v3.Data.Stack or 0

		local function updateIndicator()
			for i, v4 in ipairs(clones) do
				local imageColor

				if i <= stack then
					imageColor = Color3.fromRGB(91, 91, 91)
				else
					imageColor = Color3.fromRGB(0, 0, 0)
				end

				v4.ImageColor3 = imageColor
			end
		end

		updateIndicator()
		data.current.core.minigame.NoFail = stack > 0
		local frame = Instance.new("Frame")
		frame.Name = "DarkOverlay"
		frame.LayoutOrder = 999
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		frame.Size = UDim2.fromScale(2, 2)
		frame.BorderSizePixel = 0
		frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		frame.BackgroundTransparency = 1
		frame.Parent = object.reel
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Rotation = 90
		uIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(0.25, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(125, 125, 125)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		})
		uIGradient.Offset = Vector2.new(0, 1)
		uIGradient.Parent = frame
		local persistent = object.renderTweens:CreatePersistent(frame, TweenInfo.new(2.5), {
			BackgroundTransparency = 1
		})
		local persistent2 = object.renderTweens:CreatePersistent(
			uIGradient,
			TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
			{
				Offset = Vector2.new(0, -1)
			}
		)
		data.reelTrove:Add(persistent)
		data.reelTrove:Add(persistent2)

		local function darken()
			v += data.config.DARKNESS_PER_SLASH

			if not SettingsController:GetSettingValue("photosensitiveMode") then
				persistent:Cancel()
				persistent2:Cancel()
				uIGradient.Offset = Vector2.new(0, 1)
				frame.BackgroundTransparency = 0
				persistent2:Play()
				task.delay(0.1, function()
					persistent:Play()
				end)
			end

			if v >= 100 then
				v -= 100

				if stack < data.config.MAX_STACKS then
					stack += 1
					data.current.core.minigame.NoFail = stack > 0
					updateIndicator()
				else
					if object.stats.ForcedProgressSpeed < -50 then
						object:AddProgress(data.config.DARKNESS_PROGRESS_MAX_STACKS_FPS)
					else
						object:AddProgress(data.config.DARKNESS_PROGRESS_MAX_STACKS)
					end

					script.MaxDarkness:Play()
				end
			end

			v = math.clamp(v, 0, 100)
		end

		data.reelTrove:Add(object.OnSlash:Connect(function(p, p2)
			if p ~= "rod" or p2 ~= "Darkheart" then
				return
			end

			darken()
		end))
		object.BuildEndingData:Bind(function(p)
			p.Darkheart_EndingStacks = stack
			return p
		end)
		local v4 = false
		data.reelTrove:Add(object.OnLogicStep:Connect(function(p)
			local v5 = v2
			local v6 = v
			local v7 = 1 - math.exp(-p / 0.15)
			v2 = v5 + (v6 - v5) * v7
			icon.ImageColor3 = imageColor3:Lerp(Color3.new(), v2 / 100)

			if object.progress <= 0 and stack > 0 and not v4 then
				v4 = true
				object:AddProgress((object.stats.StartingProgress - object.progress) / object.trueprogressefficiency)
				object:TweenModifier(
					"progressLossMultiplier",
					"multiply",
					0,
					1,
					TweenInfo.new(3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
				)
				object.fx:SpawnShake(data.current.reel_bar, 0.25, 0.25, 0.01, false)
				stack -= 1
				updateIndicator()
				script.Revive:Play()

				if stack <= 0 then
					object:WaitLogic(1)
					object.core.minigame.NoFail = false
				end

				object:WaitLogic(1)
				v4 = false
			end
		end))
		data.reelTrove:Add(task.spawn(function()
			while object:WaitLogic(data.config.DRAIN_TIME) do
				v = math.clamp(v - data.config.DARKNESS_DRAIN, 0, 100)
			end
		end))
	end
}
setmetatable(Darkheart, module)
return Darkheart