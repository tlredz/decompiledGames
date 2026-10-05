local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Config = require(script.Parent.Config)
require(script.Parent.Types)
local create = Vide.create
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy)
local vector = Vector2.new(0.5, 0)
local vector2 = Vector2.new(0.5, 0.29333333333333333)

-- equivalent calls inferred from this helper; original call sites unknown
local function ease(value: number, p, p2)
	return TweenService:GetValue(math.clamp(value, 0, 1), p, p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getTopOffset()
	return GuiService:GetGuiInset().Y
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getHuntBannerPosition()
	local _, v = GuiService:GetGuiInset()
	local v2 = (GuiService:IsTenFootInterface() and 100 or 60) + 10
	return UDim2.new(0.5, 0, 1, -v.Y - v2 - 12)
end

return {
	mount = function(playerGui, callback)
		local source = Vide.source(false)
		local v = {}
		local v2 = nil
		local v3 = nil
		local v4 = nil
		local now = nil
		local v5 = nil
		local yearCounterRollSeconds = 0
		local v6 = false
		local flag = false
		local v7 = nil
		local v8 = nil
		local v9 = nil
		local v10 = nil
		local isA = playerGui:IsA("PlayerGui")
		local v11 = Vide.mount(function()
			local v12 = {}

			for i = 1, 4 do
				local labels = {}

				for i2 = 0, 9 do
					labels[i2 + 1] = create("TextLabel")({
						Name = `Digit{i2}`,
						Size = UDim2.fromScale(1, 1),
						Position = UDim2.fromScale(0, i2),
						BackgroundTransparency = 1,
						FontFace = rbxassetfontsfamiliesGothamSSmjson,
						Text = tostring(i2),
						TextColor3 = Color3.fromRGB(247, 251, 255),
						TextScaled = true,
						create("UITextSizeConstraint")({
							MaxTextSize = 60,
							MinTextSize = 12
						}),
						create("UIStroke")({
							Color = Color3.fromRGB(24, 34, 50),
							Thickness = 2,
							Transparency = 0.15
						})
					})
				end

				local strip = create("Frame")({
					Name = "Strip",
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					labels
				})
				v[i] = {
					strip = strip,
					labels = labels,
					direction = 1,
					steps = 0,
					delaySeconds = 0
				}
				v12[i] = create("Frame")({
					Name = `Column{i}`,
					Position = UDim2.fromOffset((i - 1) * 42, 0),
					Size = UDim2.fromOffset(42, 72),
					BackgroundTransparency = 1,
					ClipsDescendants = true,
					strip
				})
			end

			v3 = create("UIScale")({
				Scale = 1
			})
			v8 = create("TextLabel")({
				Name = "Timer",
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0.5, 92, 0, 44),
				Size = UDim2.fromOffset(100, 40),
				FontFace = rbxassetfontsfamiliesGothamSSmjson,
				Text = "",
				TextSize = 25,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Color3.fromRGB(175, 180, 190),
				TextStrokeTransparency = 0.5
			})
			v9 = create("TextLabel")({
				Name = "Instructions",
				BackgroundTransparency = 1,
				TextScaled = true,
				Position = UDim2.fromOffset(10, 76),
				Size = UDim2.new(1, -20, 0, 54),
				FontFace = rbxassetfontsfamiliesGothamSSmjson,
				Text = "",
				TextSize = 30,
				TextWrapped = true,
				TextColor3 = Color3.fromRGB(240, 243, 250),
				TextStrokeTransparency = 0.5
			})
			v10 = create("TextLabel")({
				Name = "HuntBonus",
				AnchorPoint = Vector2.new(0.5, 1),
				Position = getHuntBannerPosition(),
				Size = UDim2.new(1, -32, 0, 64),
				BackgroundTransparency = 1,
				FontFace = rbxassetfontsfamiliesGothamSSmjson,
				Text = Config.huntBannerText,
				TextSize = 18,
				TextScaled = true,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Bottom,
				TextColor3 = Color3.fromRGB(255, 214, 120),
				TextStrokeTransparency = 0.45,
				Visible = source,
				create("UISizeConstraint")({
					MaxSize = Vector2.new(360, 64)
				}),
				create("UITextSizeConstraint")({
					MinTextSize = 12,
					MaxTextSize = 18
				})
			})
			v2 = create("CanvasGroup")({
				Name = "Year",
				AnchorPoint = vector,
				Position = UDim2.new(0.5, 0, 0, GuiService:GetGuiInset().Y),
				Size = UDim2.new(1, 0, 0, 150),
				BackgroundTransparency = 1,
				GroupTransparency = 1,
				v3,
				v8,
				v9,
				create("Frame")({
					Name = "Digits",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0, 44),
					Size = UDim2.fromOffset(168, 72),
					BackgroundTransparency = 1,
					v12
				})
			})
			local v15 = create(isA and "ScreenGui" or "Frame")
			local v16 = {
				Name = "20YearsEventYearCounter",
				DisplayOrder = isA and 28990 or nil,
				IgnoreGuiInset = isA and true or nil,
				ResetOnSpawn = not isA and nil
			}
			local screenInsets

			if isA then
				screenInsets = Enum.ScreenInsets.None
			end

			v16.ScreenInsets = screenInsets
			v16.ClipToDeviceSafeArea = not isA and nil
			local enabled

			if isA then
				enabled = source
			end

			v16.Enabled = enabled
			local visible

			if not isA then
				visible = source
			end

			v16.Visible = visible
			local size

			if not isA then
				size = UDim2.fromScale(1, 1)
			end

			v16.Size = size
			v16.BackgroundTransparency = not isA and 1 or nil
			v16.ClipsDescendants = not isA or nil
			v16[1], v16[2] = v2, v10
			v4 = v15(v16)
			Vide.cleanup(v4)
			return v4
		end, playerGui)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function reset()
			v6 = false
			now = nil
			v5 = nil
			source(false)
			v7 = nil
		end

		local function setDigits(p: number)
			for k, v12 in v do
				v12.strip.Position = UDim2.fromScale(0, 0)
				local v13 = math.floor(p / 10 ^ (4 - k)) % 10

				for k2, label in v12.labels do
					label.Text = tostring((v13 + k2 - 1) % 10)
					label.Position = UDim2.fromScale(0, k2 - 1)
				end
			end
		end

		return {
			setStatus = function(p: number?, p2: number, text: string)
				if flag then
					return
				end

				local v12 = v7 ~= p
				v7 = p
				v8.Text = "(" .. math.max(0, (math.ceil(p2))) .. "s)"
				v9.Text = text

				if p then
					source(true)

					if not now and v12 then
						setDigits(p)
					end
				else
					reset() -- equivalent call inferred; original call site unknown
				end
			end,
			show = function(p: number, p2: number)
				if flag then
					return
				end

				v6 = p ~= p2
				now = os.clock()
				v5 = nil
				yearCounterRollSeconds = Config.yearCounterRollSeconds
				local direction = p <= p2 and 1 or -1

				for k, v13 in v do
					local v14 = 10 ^ (4 - k)
					local v15 = math.floor(p / v14) % 10
					v13.steps = (math.floor(p2 / v14) % 10 - v15) * direction % 10
					v13.direction = direction
					v13.delaySeconds = not (v13.steps > 0) and 0 or (4 - k) * Config.yearCounterDigitStaggerSeconds
					yearCounterRollSeconds = math.max(
						yearCounterRollSeconds,
						Config.yearCounterRollSeconds + v13.delaySeconds
					)
					v13.strip.Position = UDim2.fromScale(0, 0)

					for k2, label in v13.labels do
						label.Text = tostring((v15 + (k2 - 1) * direction) % 10)
						label.Position = UDim2.fromScale(0, (k2 - 1) * direction)
					end
				end

				v2.AnchorPoint = vector
				v2.Position = UDim2.new(0.5, 0, 0, GuiService:GetGuiInset().Y)
				v2.GroupTransparency = 0
				v3.Scale = 0.65
				source(true)
			end,
			roll = function()
				local v12 = now

				if v12 and not (v5 or flag) then
					v5 = math.max(os.clock(), v12 + Config.yearCounterEnterSeconds)
				end
			end,
			update = function()
				local v12 = now

				if flag then
					return
				end

				local absoluteSize = v4.AbsoluteSize
				local topOffset = getTopOffset() -- equivalent call inferred; original call site unknown
				v10.Position = getHuntBannerPosition()
				local v14 = topOffset / math.max(1, absoluteSize.Y)
				local v15 = math.clamp(math.min(absoluteSize.X / 640, absoluteSize.Y / 360), 0.45, 1)

				if v12 then
					local now2 = os.clock()
					local textTransparency = ease(
						(now2 - v12) / Config.yearCounterEnterSeconds,
						Enum.EasingStyle.Quart,
						Enum.EasingDirection.Out
					) -- equivalent call inferred; original call site unknown
					v2.AnchorPoint = vector:Lerp(vector2, textTransparency)
					v2.Position = UDim2.fromScale(0.5, v14 + (0.5 - v14) * textTransparency)
					v2.GroupTransparency = 0
					v3.Scale = v15 * (textTransparency * 0.35 + 0.65)
					v8.TextTransparency = textTransparency
					v9.TextTransparency = textTransparency
					v8.TextStrokeTransparency = textTransparency * 0.5 + 0.5
					v9.TextStrokeTransparency = textTransparency * 0.5 + 0.5
					local v18 = v5

					if v18 then
						if v6 and v18 <= now2 then
							v6 = false

							if callback then
								callback()
							end
						end

						for _, v19 in v do
							local v21 = ease(
								(now2 - v18 - v19.delaySeconds) / Config.yearCounterRollSeconds,
								Enum.EasingStyle.Sine,
								Enum.EasingDirection.InOut
							) -- equivalent call inferred; original call site unknown
							v19.strip.Position = UDim2.fromScale(0, -v19.direction * v19.steps * v21)
						end

						local v19 = v18 + yearCounterRollSeconds + Config.yearCounterHoldSeconds

						if v19 <= now2 then
							local v20 = (now2 - v19) / Config.yearCounterExitSeconds
							local v22 = ease(v20, Enum.EasingStyle.Quad, Enum.EasingDirection.In) -- equivalent call inferred; original call site unknown
							v2.AnchorPoint = vector2:Lerp(vector, v22)
							v2.Position = UDim2.fromScale(0.5, (v14 - 0.5) * v22 + 0.5)
							v3.Scale = v15 * (1 - v22 * 0.35)
							v8.TextTransparency = 1 - v22
							v9.TextTransparency = 1 - v22
							v8.TextStrokeTransparency = 1 - v22 * 0.5
							v9.TextStrokeTransparency = 1 - v22 * 0.5

							if v20 >= 1 then
								now = nil
								v5 = nil

								if v7 then
									setDigits(v7)
								end
							end
						end
					end
				else
					v2.AnchorPoint = vector
					v2.Position = UDim2.fromScale(0.5, v14)
					v2.GroupTransparency = 0
					v3.Scale = v15 * 0.65
					v8.TextTransparency = 0
					v9.TextTransparency = 0
					v8.TextStrokeTransparency = 0.5
					v9.TextStrokeTransparency = 0.5
				end
			end,
			reset = reset,
			destroy = function()
				if not flag then
					reset() -- equivalent call inferred; original call site unknown
					flag = true
					v11()
				end
			end
		}
	end
}