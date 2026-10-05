local React = require(game.ReplicatedStorage.Packages.React)
local ResourceBar = require(script.ResourceBar)
local useEnergy = require(game.ReplicatedStorage.React.Hooks.Player.useEnergy)
local useHealth = require(game.ReplicatedStorage.React.Hooks.Player.useHealth)
local useLastInput = require(game.ReplicatedStorage.React.Hooks.useLastInput)
local useStrictLerp = require(game.ReplicatedStorage.React.Hooks.Animation.useStrictLerp)
local useCharacter = require(game.ReplicatedStorage.React.Hooks.Player.useCharacter)
local useMatchingChild = require(game.ReplicatedStorage.React.Hooks.Instance.useMatchingChild)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
local useAttribute = require(game.ReplicatedStorage.React.Hooks.Instance.useAttribute)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement

function energyBar(p)
	local v = useEnergy()
	local clone = table.clone(p)
	local v2 = not (v and v.Max > 0) and 0 or v.Current / v.Max
	clone.Alpha = useStrictLerp(v2, v2, 0.3, nil, nil)
	clone.Variant = "Blue"
	clone.Label = "Energy"
	clone.ValueText = not v and "..." or `{math.floor(v.Current)}/{math.floor(v.Max)}`
	return createElement(ResourceBar, clone)
end

function healthBar(p)
	local v = useHealth()
	local v2 = (not v or not v.Max or v.Max == 1e999) and 1 or v.Max or 1
	local v3 = useCharacter()
	local v4 = useAttribute(v3, "OverflowHP")
	local v5 = useMockState("OverflowHP", 0)

	if v5 then
		v4 = v5:get()
	end

	local v6 = useMatchingChild(v3, function(p2)
		if not p2 or p2.Name ~= "PainTransformed" or not p2 then
			p2 = nil
		end

		return p2
	end) ~= nil
	local v7 = useMockState("IsPainTransformed", false)

	if v7 then
		v6 = v7:get()
	end

	local clone = table.clone(p)
	local v8 = not (v and v2 > 0) and 0 or math.clamp(v.Current / v2, 0, 1)
	clone.Alpha = useStrictLerp(v8, v8, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local v9 = not (v and v2 > 0 and v4) and 0 or math.clamp(v4 / v2, 0, 1)
	clone.OverflowAlpha = useStrictLerp(v9, v9, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	clone.Label = "Health"
	clone.ValueText = not v and "..." or `{v.Max ~= v2 and "∞" or `{math.floor(v.Current)}/{math.floor(v.Max)}`}`
	clone.Variant = v6 and "Red" or "Green"
	return createElement(ResourceBar, clone)
end

return function(p)
	local v = useLastInput()
	return createElement("Frame", RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Active = false
	}, p), {
		UIFlex = v ~= "Touch" and createElement("UIFlexItem", {
			FlexMode = Enum.UIFlexMode.Fill
		}),
		UIPadding = v ~= "Touch" and createElement("UIPadding", {
			PaddingTop = UDim.new(0.01, 12),
			PaddingLeft = UDim.new(0.002, 0),
			PaddingRight = UDim.new(0.002, 0),
			PaddingBottom = UDim.new(0.01, 8)
		}),
		UIListLayout = v == "Touch" and createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.01, 7)
		}) or createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			Padding = CONSTANTS.SPACING.PADDING.SCALE.XL
		}),
		HP = createElement(healthBar, {
			Size = v == "Touch" and UDim2.new(0.49, -1, 1, 0) or UDim2.fromScale(1, 0.5),
			LayoutOrder = 1
		}),
		Energy = createElement(energyBar, {
			Size = v == "Touch" and UDim2.new(0.49, -1, 1, 0) or UDim2.fromScale(1, 0.5),
			LayoutOrder = 2
		})
	})
end