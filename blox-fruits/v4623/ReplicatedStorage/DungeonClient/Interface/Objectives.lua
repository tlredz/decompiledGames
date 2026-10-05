local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.Packages.ReactRoblox)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local createElement = React.createElement

local function ObjectiveItem(p)
	local objectiveFolder = p.objectiveFolder
	local _ = p.isSubObjectiveOf
	local state, setState = React.useState(objectiveFolder:GetAttribute("Name"))
	local _, setState2 = React.useState(Enum.Font.SourceSans)
	local _, setState3 = React.useState(Color3.fromRGB(255, 255, 255))
	React.useRef(workspace.CurrentCamera.ViewportSize.Y * 0.024)
	React.useEffect(function()
		local connections = {}

		local function updateText()
			local name = objectiveFolder:GetAttribute("Name")
			local isComplete = objectiveFolder:GetAttribute("IsComplete")
			local isOptional = objectiveFolder:GetAttribute("IsOptional")
			local isHidden = objectiveFolder:GetAttribute("IsHidden")

			if isOptional then
				name = "<i>" .. (name or "") .. " (Optional)</i>"
				setState2(Enum.Font.SourceSansItalic)
			else
				setState2(Enum.Font.SourceSans)
			end

			if isComplete then
				name = "<s>" .. (name or "") .. "</s>"
			end

			if isHidden and not isComplete then
				setState3(Color3.fromRGB(192, 192, 192))
				name = typeof(isHidden) ~= "string" and "???.." or isHidden
			else
				local v2

				if isComplete then
					v2 = Color3.fromRGB(144, 255, 144)
				else
					v2 = Color3.new(1, 1, 1)
				end

				setState3(v2)
			end

			setState("• " .. (name or ""))
		end

		table.insert(connections, objectiveFolder:GetAttributeChangedSignal("IsComplete"):Connect(updateText))
		table.insert(connections, objectiveFolder:GetAttributeChangedSignal("IsOptional"):Connect(updateText))
		table.insert(connections, objectiveFolder:GetAttributeChangedSignal("IsHidden"):Connect(updateText))
		table.insert(connections, objectiveFolder:GetAttributeChangedSignal("Name"):Connect(updateText))
		updateText()
		return function()
			warn("disconnected objective listeners")

			for _, connection in connections do
				connection:Disconnect()
			end
		end
	end, { objectiveFolder })
	local isCompleted = objectiveFolder:GetAttribute("IsCompleted") or false
	local color

	if isCompleted then
		color = Color3.fromRGB(179, 179, 179)
	else
		color = Color3.fromRGB(212, 212, 212)
	end

	if isCompleted then
		local _ = "<s>• " .. state .. "</s>"
	else
		local _ = "• " .. state
	end

	return React.createElement("TextLabel", {
		BackgroundTransparency = 1,
		FontFace = Font.new("rbxasset://fonts/families/HighwayGothic.json"),
		RichText = true,
		Size = UDim2.fromScale(1, 0.25),
		Text = state,
		TextColor3 = color,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left
	})
end

local function ObjectivesInnerFrame(p)
	local v = React.useMemo(function()
		local children = {}

		for _, objectiveFolder in p.ObjectivesList do
			table.insert(children, createElement(ObjectiveItem, {
				objectiveFolder = objectiveFolder
			}))
		end

		return children
	end, { p.ObjectivesList })
	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.028, 0.3),
		Size = UDim2.fromScale(0.876161, 0.614815)
	}, { React.createElement("UIListLayout", {
			Padding = UDim.new(0.1, 0),
			SortOrder = Enum.SortOrder.LayoutOrder
		}), v })
end

local _ = {
	Empty = 0,
	Blue = 1,
	Gold = 2
}

local function StarsComponent(_)
	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.69, 0.5),
		Size = UDim2.fromScale(0.380805, 0.819543)
	}, {
		uIListLayout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0.03, 0),
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		star1 = React.createElement("ImageLabel", {
			BackgroundTransparency = 1,
			Image = "rbxassetid://116516971928499",
			ImageRectOffset = Vector2.new(528, 0),
			ImageRectSize = Vector2.new(132, 132),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.211382, 1),
			ZIndex = 3
		}, {
			uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint")
		}),
		star2 = React.createElement("ImageLabel", {
			BackgroundTransparency = 1,
			Image = "rbxassetid://116516971928499",
			ImageRectOffset = Vector2.new(396, 0),
			ImageRectSize = Vector2.new(132, 132),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.211382, 1),
			ZIndex = 2
		}, {
			uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint")
		}),
		star3 = React.createElement("ImageLabel", {
			BackgroundTransparency = 1,
			Image = "rbxassetid://116516971928499",
			ImageRectSize = Vector2.new(132, 132),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.211382, 1)
		}, {
			uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint")
		})
	})
end

local function ObjectivesHeaderFrame(p)
	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 0.5,
		BorderColor3 = Color3.new(),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.fromScale(1, 0.235)
	}, {
		uIGradient = React.createElement("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.339975, 0),
				NumberSequenceKeypoint.new(0.729763, 0.4875),
				NumberSequenceKeypoint.new(1, 1)
			})
		}),
		textLabel = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.new("rbxasset://fonts/families/HighwayGothic.json"),
			Position = UDim2.fromScale(0.05, 0.54),
			Size = UDim2.fromScale(0.628, 0.8),
			Text = "Dungeon - Easy",
			TextColor3 = Color3.new(),
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left
		}, {
			uIStroke = React.createElement("UIStroke"),
			textLabel = React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				FontFace = Font.new("rbxasset://fonts/families/HighwayGothic.json"),
				Position = UDim2.fromScale(0.5, 0.425),
				Size = UDim2.fromScale(1, 1),
				Text = "Dungeon - Easy",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left
			}, {
				uIStroke = React.createElement("UIStroke"),
				uIGradient = React.createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 214, 49)),
						ColorSequenceKeypoint.new(0.447323, Color3.fromRGB(255, 241, 87)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 214, 49))
					}),
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(0.298144, 0),
						NumberSequenceKeypoint.new(0.700696, 0.0125),
						NumberSequenceKeypoint.new(1, 0)
					})
				})
			})
		}),
		stars = createElement(StarsComponent, p)
	})
end

local function ObjectiveFrameComponent(p)
	local v = Maid.new()
	React.useEffect(function()
		return function()
			v:DoCleaning()
		end
	end, {})
	return (React.createElement("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 0.5,
		BorderColor3 = Color3.new(),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromScale(0.272496, 0.212965)
	}, {
		uIGradient = React.createElement("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.403487, 0),
				NumberSequenceKeypoint.new(0.707347, 0.35625),
				NumberSequenceKeypoint.new(1, 1)
			})
		}),
		uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 2.393
		}),
		uISizeConstraint = React.createElement("UISizeConstraint", {
			MaxSize = Vector2.new(300, 300)
		}),
		Header = createElement(ObjectivesHeaderFrame, p),
		InnerFrame = createElement(ObjectivesInnerFrame, p)
	}))
end

return ObjectiveFrameComponent