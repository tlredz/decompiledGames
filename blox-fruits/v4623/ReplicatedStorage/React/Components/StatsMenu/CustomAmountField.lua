local React = require(game.ReplicatedStorage.Packages.React)
local useLevelCap = require(game.ReplicatedStorage.React.Hooks.Player.useLevelCap)
local useLevels = require(game.ReplicatedStorage.React.Hooks.Player.Stats.useLevels)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	local v = useLevels()
	local v2 = useLevelCap()
	local ref = React.useRef(nil)
	local v3 = React.useMemo(function()
		local v5 = v2
		local count = 0

		for _, v6 in v do
			if not v6 then
				continue
			end

			count += 1
			v5 = math.min(v5, v6)
		end

		return (math.max(1, v2 - (count == 0 and 0 or v5)))
	end, { v2, v })
	return createElement(React.Fragment, {}, {
		CustomAmount = createElement("TextLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = Font.new(CONSTANTS.FONT.FAMILY.HIGHWAY_GOTHIC),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(0.88, 0.055),
			Size = UDim2.fromScale(0.337, 0.06),
			Text = "Custom Amount:",
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Bottom
		}),
		StatPointsTextBox = createElement("Frame", {
			BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
			BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(0.985, 0.055),
			Size = UDim2.fromScale(0.1, 0.0672119)
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0.07, 0)
			}),
			UIStroke = createElement("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
			}),
			TextBox = createElement("TextBox", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = Font.new(CONSTANTS.FONT.FAMILY.HIGHWAY_GOTHIC),
				PlaceholderColor3 = Color3.fromRGB(127, 127, 127),
				PlaceholderText = "1",
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				Text = not p.Amount and "" or tostring(p.Amount),
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextYAlignment = Enum.TextYAlignment.Bottom,
				TextScaled = true,
				[React.Event.Focused] = function(p2)
					ref.current = nil
					p.OnChange(nil)
					p2.Text = ""
				end,
				[React.Change.Text] = function(p2)
					local text = tonumber(p2.Text)
					local current = text and math.clamp(math.round(text), 1, v3)

					if current then
						p2.Text = tostring(current)

						if ref.current == current then
							return
						end

						ref.current = current
						p.OnChange(current)
					elseif p2.Text ~= "" then
						ref.current = 1
						p2.Text = ""
						p.OnChange(1)
					end
				end
			})
		})
	})
end