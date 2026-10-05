local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
local MaterialIconsHD = require(game.ReplicatedStorage.Packages.MaterialIconsHD)
local MathUtil = require(game.ReplicatedStorage.Modules.Util.MathUtil)
local Sunburst = require(game.ReplicatedStorage.React.Components.Gacha.Sunburst)
local Sparkles = require(game.ReplicatedStorage.React.Components.Gacha.Sparkles)
local IdMap = require(game.ReplicatedStorage.IdMap)
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)

local function fn(p)
	local enabled = p.Enabled == true
	local ref = React.useRef(nil)
	React.useEffect(function()
		local flag = false

		if ref.current and enabled then
			task.spawn(function()
				local total = 0

				while flag == false do
					local imageTransparency = (math.sin(total * 0.4 * 3.141592653589793 * 2) + 1) / 2 * -0.7 + 0.7
					ref.current.ImageTransparency = imageTransparency
					total += task.wait()
				end
			end)
		end

		return function()
			flag = true
		end
	end, { ref.current, enabled })
	return createElement("ImageLabel", {
		ref = ref,
		Visible = enabled,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = "rbxassetid://71586799415001",
		Position = UDim2.fromScale(0.5, 0.55),
		ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.fromScale(1.35, 1.35),
		ZIndex = -999
	})
end

return function(props)
	local item = props.Item
	local data = item.Data
	local v = useMatch(data.ItemId)
	local sprite = v and v.Display and v.Display.Sprite or MaterialIconsHD.broken_image
	local ref = React.useRef(nil)
	local element = createElement("ImageLabel", RobloxTypes.mergeImageLabel({
		ref = ref,
		ZIndex = CONSTANTS.LAYER.RAISED_HIGH,
		Image = sprite.Image,
		ImageRectOffset = sprite.ImageRectOffset,
		ImageRectSize = sprite.ImageRectSize
	}, props.FruitIcon))
	local state, setState = React.useState(item.Hovering)

	if item.Hovering ~= nil and state ~= item.Hovering then
		setState(item.Hovering)
	end

	local selectable = item.Selectable == true
	local ref2 = React.useRef(UDim2.fromScale(0.5, 0.5))
	local ref3 = React.useRef(UDim2.fromScale(0.9, 0.9))
	local ref4 = React.useRef(UDim2.fromScale(ref3.current.X.Scale + 0.05, ref3.current.Y.Scale + 0.05))
	React.useEffect(function()
		local v2

		if ref.current then
			local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
			local TweenService = game:GetService("TweenService")
			local current = ref.current
			local size

			if state then
				size = ref4.current
			else
				size = ref3.current
			end

			v2 = TweenService:Create(current, tweenInfo, {
				Size = size,
				Position = ref2.current
			})
			v2:Play()
		else
			v2 = nil
		end

		return function()
			if v2 then
				v2:Cancel()
			end
		end
	end, { state, ref.current })
	local v2 = React.useMemo(function()
		return (RobloxTypes.mergeImageButton({
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Selectable = selectable,
			Active = selectable,
			[React.Event.MouseEnter] = selectable and function()
				setState(true)
			end or nil,
			[React.Event.MouseLeave] = selectable and function()
				setState(false)
			end or nil,
			[React.Event.Activated] = props.OnItemSelected ~= nil and function()
				props.OnItemSelected(item)
			end or nil
		}, props.ImageButton))
	end, { selectable, props.OnItemSelected, item })
	local v3 = React.useMemo(function()
		return RobloxTypes.mergeFrame({}, props.Odds)
	end, { props.Odds })
	local v4 = React.useMemo(function()
		local mergeTextLabel = RobloxTypes.mergeTextLabel
		local text

		if v then
			text = v.Display and v.Display.Name or v.Index.StorageKey or nil
		end

		return mergeTextLabel({
			ZIndex = 4,
			Text = text
		}, props.NameLabel)
	end, { props.NameLabel })
	local v5 = React.useMemo(function()
		local mergeTextLabel = RobloxTypes.mergeTextLabel
		local v6 = {
			Visible = not data.IsPastItem,
			Text = `{math.clamp(data.Pity, 0, data.RollGuarantee)}/{data.RollGuarantee}`,
			TextColor3 = 0
		}
		local textColor

		if data.IsNextItem then
			textColor = Color3.fromRGB(255, 196, 0)
		else
			textColor = CONSTANTS.COLOR.PALETTE.WHITE
		end

		v6.TextColor3 = textColor
		return mergeTextLabel(v6, props.PityCounter)
	end, {
		props.PityCounter,
		item.ShowPity,
		data.Pity,
		data.RollGuarantee
	})
	local children2

	if props.children ~= nil then
		children2 = createElement(React.Fragment, {}, props.children)
	end

	local v11 = {
		Enabled = data.Index >= 6,
		Properties = 0
	}
	local color

	if data.ItemId == IdMap.PhysicalMoveset["Arcsteel Magnet"] then
		color = Color3.new(255, 0, 0)
	elseif data.ItemId == IdMap.PhysicalMoveset["Sealed Fiend"] then
		color = Color3.new(0.568627, 0.105882, 1)
	end

	v11.Properties = {
		ImageColor3 = color
	}
	local children = {
		Children = children2,
		Sunburst = createElement(Sunburst, v11),
		Sparkles = createElement(Sparkles, {
			Enabled = data.Index >= 6
		}),
		NameLabel = 0,
		Odds = 0,
		PityCounter = 0,
		FruitIcon = 0,
		Selection = 0
	}
	local nameLabel

	if item.ShowName == true then
		nameLabel = createElement("TextLabel", v4, {
			UIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
			})
		})
	end

	children.NameLabel = nameLabel
	local odds

	if item.ShowOdds == true then
		odds = createElement("Frame", v3, {
			UIGradient = createElement("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.561644, 0),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.BODY_BOLD,
				Position = UDim2.fromScale(0.1, 0.45),
				Size = UDim2.fromScale(0.8, 0.9),
				Text = `{tostring(MathUtil.round(data.Chance * 100, 1))}%`,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left
			}, {
				UIStroke = createElement("UIStroke")
			})
		})
	end

	children.Odds = odds
	local pityCounter

	if item.ShowPity == true then
		pityCounter = createElement("TextLabel", v5, {
			UIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
			})
		})
	end

	children.PityCounter = pityCounter
	children.FruitIcon = element
	children.Selection = createElement(fn, {
		Enabled = item.Selected == true or (item.Selectable and state == true and true or false)
	})
	return createElement("ImageButton", v2, children)
end