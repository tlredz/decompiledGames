local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
require(ReplicatedStorage.Packages.ReactRoblox)
local createElement = React.createElement
local PlayerPortraitFrame = require(script.Parent.PlayerPortraitFrame)
local updateSelectedPlayer = nil

local function mainPlayerFrame(props)
	local v3 = {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = React.useMemo(function()
			if props.isMainPlayer then
			end

			return 1
		end, {}),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromScale(0.415044, 1),
		[React.Event.MouseEnter] = function()
			updateSelectedPlayer(props.portraitUserId)
		end
	}
	local v7 = {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(-0.02, -0.02),
		Size = UDim2.fromScale(1, 1)
	}
	local v10 = {
		portraitUserId = props.portraitUserId,
		statusGradientColor = props.statusGradientColor,
		isMVP = props.isMVP,
		isMainPlayer = props.isMainPlayer,
		Size = 0
	}
	local size

	if props.isMainPlayer then
		size = UDim2.new(0.592, 0, 0.524, 0)
	else
		size = UDim2.new(0.214, 0, 1.018, 0)
	end

	v10.Size = size
	return createElement("Frame", v3, {
		player1 = createElement("Frame", v7, {
			portrait = createElement(PlayerPortraitFrame, v10),
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				FontFace = Font.new("rbxasset://fonts/families/HighwayGothic.json"),
				Position = UDim2.fromScale(0.5, 0.761905),
				Size = UDim2.fromScale(1.08146, 0.130255),
				Text = props.displayName,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true
			}, {
				victoryUIGradient = createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 199, 29)),
						ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(255, 239, 60)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 199, 29))
					})
				}),
				uIStroke = createElement("UIStroke", {
					Thickness = 1.5
				})
			}),
			textLabel2 = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				FontFace = Font.new("rbxasset://fonts/families/HighwayGothic.json"),
				Position = UDim2.fromScale(0.5, 0.892934),
				Size = UDim2.fromScale(0.930792, 0.121414),
				Text = props.subText,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true
			})
		})
	})
end

local function otherPlayerFrame(props)
	local v3 = {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.948638, 0),
		Size = UDim2.fromScale(0.945256, 0.259959),
		[React.Event.MouseEnter] = function()
			updateSelectedPlayer(props.portraitUserId)
		end
	}
	local v6 = {
		portraitUserId = props.portraitUserId,
		statusGradientColor = props.statusGradientColor,
		isMVP = props.isMVP,
		isMainPlayer = props.isMainPlayer,
		Size = 0
	}
	local size

	if props.isMainPlayer then
		size = UDim2.new(0.592, 0, 0.524, 0)
	else
		size = UDim2.new(0.214, 0, 1.018, 0)
	end

	v6.Size = size
	return createElement("Frame", v3, {
		portrait = createElement(PlayerPortraitFrame, v6),
		textLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.new("rbxasset://fonts/families/HighwayGothic.json"),
			Position = UDim2.fromScale(0.260869, 0.285068),
			Size = UDim2.fromScale(0.797045, 0.427602),
			Text = props.displayName,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left
		}, {
			victoryUIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 199, 29)),
					ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(255, 239, 60)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 199, 29))
				})
			}),
			uIStroke = createElement("UIStroke", {
				Thickness = 1.5
			})
		}),
		textLabel2 = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.new("rbxasset://fonts/families/HighwayGothic.json"),
			Position = UDim2.fromScale(0.26087, 0.71267),
			Size = UDim2.fromScale(0.662471, 0.386878),
			Text = props.subText,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left
		})
	})
end

return function(p)
	updateSelectedPlayer = p.updateSelectedPlayer
	local children = {}
	local v = nil

	for _, allPlayer in ipairs(p.allPlayers) do
		if allPlayer.isMainPlayer then
			v = allPlayer
		else
			table.insert(children, createElement(otherPlayerFrame, allPlayer))
		end
	end

	local element = createElement("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.00215172, 0),
		Size = UDim2.fromScale(0.557597, 1)
	}, { createElement("UIListLayout", {
			Padding = UDim.new(0.1, 0),
			SortOrder = Enum.SortOrder.LayoutOrder
		}), children })
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1.01,
		Position = UDim2.fromScale(0.627884, 0.0124518),
		Size = UDim2.fromScale(0.70309, 0.468189)
	}, {
		otherPlayers = element,
		player = createElement(mainPlayerFrame, v)
	})
end