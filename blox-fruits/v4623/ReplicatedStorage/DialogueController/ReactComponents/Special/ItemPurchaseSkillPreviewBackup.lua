local React = require(game.ReplicatedStorage.Packages.React)
local FruitSkills = require(game.ReplicatedStorage.FruitSkills)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local BACKGROUND = CONSTANTS.COLOR.PANEL.BACKGROUND
local SUBTLE = CONSTANTS.ALPHA.SUBTLE
local BLACK = CONSTANTS.COLOR.PALETTE.BLACK
local REGULAR = CONSTANTS.THICKNESS.OUTLINE.REGULAR
local OPAQUE = CONSTANTS.ALPHA.OPAQUE
local BACKGROUND2 = CONSTANTS.COLOR.HEADER.BACKGROUND
local HIGHLIGHT = CONSTANTS.COLOR.HEADER.HIGHLIGHT
local OPAQUE2 = CONSTANTS.ALPHA.OPAQUE
local lerped = CONSTANTS.COLOR.PANEL.BACKGROUND:Lerp(CONSTANTS.COLOR.PALETTE.BLACK, 0.5)
local SUBTLE2 = CONSTANTS.ALPHA.SUBTLE
local BLACK2 = CONSTANTS.COLOR.PALETTE.BLACK
local REGULAR2 = CONSTANTS.THICKNESS.OUTLINE.REGULAR
local OPAQUE3 = CONSTANTS.ALPHA.OPAQUE
local DISPLAY_LIGHT = CONSTANTS.FONT.FACE.DISPLAY_LIGHT
local WHITE = CONSTANTS.COLOR.PALETTE.WHITE
local BLACK3 = CONSTANTS.COLOR.PALETTE.BLACK
local color = Color3.fromRGB(255, 212, 74)

local function isSkillRow(list)
	return typeof(list) == "table" and typeof(list[2]) == "number" and typeof(list[3]) == "string"
end

local function appendSkillRows(list, list2)
	for _, v in ipairs(list2) do
		local v2

		if typeof(v) == "table" and typeof(v[2]) == "number" then
			v2 = typeof(v[3]) == "string"
		else
			v2 = false
		end

		if v2 then
			table.insert(list, {
				level = v[2],
				name = v[3],
				order = #list + 1
			})
		end
	end
end

local function getSkillRows(itemName: string)
	local fruitSkill = FruitSkills[itemName]

	if typeof(fruitSkill) ~= "table" then
		return {}
	end

	local v = {}
	local v2 = fruitSkill[1]
	local v3

	if typeof(v2) == "table" and typeof(v2[2]) == "number" then
		v3 = typeof(v2[3]) == "string"
	else
		v3 = false
	end

	if v3 then
		appendSkillRows(v, fruitSkill)
	elseif typeof(fruitSkill[1]) == "table" then
		appendSkillRows(v, fruitSkill[1])
	end

	table.sort(v, function(a, b)
		if a.level == b.level then
			return a.order < b.order
		end

		return a.level < b.level
	end)
	return v
end

local function getItemName(props)
	if typeof(props.itemName) == "string" and props.itemName ~= "" then
		return props.itemName
	end

	if typeof(props.subtitle) == "string" and props.subtitle ~= "" then
		return props.subtitle
	end

	if typeof(props.dialogueSubtitle) == "string" and props.dialogueSubtitle ~= "" then
		return props.dialogueSubtitle
	end

	if typeof(props.title) == "string" and FruitSkills[props.title] then
		return props.title
	end

	if typeof(props.dialogueTitle) == "string" and FruitSkills[props.dialogueTitle] then
		return props.dialogueTitle
	end

	return nil
end

local function TextStroke(p)
	return React.createElement("UIStroke", {
		Color = p.color,
		Thickness = p.thickness or 2
	})
end

local function SkillRow(props)
	local zIndex = props.zIndex
	return React.createElement("Frame", {
		BackgroundColor3 = lerped,
		BackgroundTransparency = SUBTLE2,
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromScale(1, props.rowHeight),
		ZIndex = zIndex
	}, {
		uICorner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0.12, 0)
		}),
		uIStroke = React.createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = BLACK2,
			Thickness = REGULAR2,
			Transparency = OPAQUE3
		}),
		level = React.createElement("TextLabel", {
			BackgroundTransparency = 1,
			FontFace = DISPLAY_LIGHT,
			Position = UDim2.fromScale(0.67, 0.12),
			Size = UDim2.fromScale(0.3, 0.76),
			Text = `Mastery {props.skill.level}`,
			TextColor3 = color,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = (zIndex or 1) + 1
		}, {
			textStroke = React.createElement(TextStroke, {
				color = BLACK3
			})
		}),
		name = React.createElement("TextLabel", {
			BackgroundTransparency = 1,
			FontFace = DISPLAY_LIGHT,
			Position = UDim2.fromScale(0.03, 0.12),
			Size = UDim2.fromScale(0.62, 0.76),
			Text = props.skill.name,
			TextColor3 = WHITE,
			TextScaled = true,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = (zIndex or 1) + 1
		}, {
			textStroke = React.createElement(TextStroke, {
				color = BLACK3
			})
		})
	})
end

local function SkillRows(p)
	local children = {
		uIListLayout = React.createElement("UIListLayout", {
			Padding = UDim.new(0.06, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}),
		uIPadding = React.createElement("UIPadding", {
			PaddingBottom = UDim.new(0.035, 0),
			PaddingLeft = UDim.new(0.025, 0),
			PaddingRight = UDim.new(0.025, 0),
			PaddingTop = UDim.new(0.035, 0)
		})
	}
	local v = math.max(#p.skills, 1)
	local rowHeight = math.clamp((1 - math.max(v - 1, 0) * 0.06 - 0.07) / v, 0.11, 0.24)

	for i, skill in ipairs(p.skills) do
		children[`skill{i}`] = React.createElement(SkillRow, {
			skill = skill,
			layoutOrder = i,
			rowHeight = rowHeight,
			zIndex = p.zIndex
		})
	end

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0, 0.245),
		Size = UDim2.fromScale(1, 0.755),
		ZIndex = p.zIndex
	}, children)
end

local function Header(p)
	local zIndex = p.zIndex
	return React.createElement("Frame", {
		BackgroundColor3 = BACKGROUND2,
		BackgroundTransparency = OPAQUE2,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 0.245),
		ZIndex = zIndex
	}, {
		uIGradient = React.createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, BACKGROUND2),
				ColorSequenceKeypoint.new(0.5, HIGHLIGHT),
				ColorSequenceKeypoint.new(1, BACKGROUND2)
			})
		}),
		title = React.createElement("TextLabel", {
			BackgroundTransparency = 1,
			FontFace = DISPLAY_LIGHT,
			Position = UDim2.fromScale(0.18, 0.12),
			Size = UDim2.fromScale(0.64, 0.76),
			Text = "SKILLS",
			TextColor3 = WHITE,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = (zIndex or 1) + 1
		}, {
			textStroke = React.createElement(TextStroke, {
				color = BLACK3
			})
		})
	})
end

local function ItemPurchaseSkillPreview(props)
	local itemName = getItemName(props)

	if not itemName then
		return nil
	end

	local skillRows = getSkillRows(itemName)

	if #skillRows == 0 then
		return nil
	end

	local zIndex = props.zIndex
	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		AutoLocalize = false,
		BackgroundColor3 = BACKGROUND,
		BackgroundTransparency = SUBTLE,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = props.position or UDim2.new(0, 0, 0, -6),
		Size = props.size or UDim2.fromScale(0.65, 0.56),
		Visible = props.visible ~= false,
		ZIndex = zIndex
	}, {
		uICorner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0.03, 0)
		}),
		uIStroke = React.createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = BLACK,
			Thickness = REGULAR,
			Transparency = OPAQUE
		}),
		header = React.createElement(Header, {
			zIndex = (zIndex or 1) + 1
		}),
		rows = React.createElement(SkillRows, {
			skills = skillRows,
			zIndex = (zIndex or 1) + 1
		})
	})
end

return ItemPurchaseSkillPreview