local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local IdMap = require(game.ReplicatedStorage.IdMap)
local TextUtil = require(game.ReplicatedStorage.Modules.Util.TextUtil)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag(script.Name):tag("Gacha"):tag("Client"):tag("UI"):build()
local SimpleButton = require(game.ReplicatedStorage.React.Components.Gacha.Buttons.SimpleButton)
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
local useRobuxSpent = require(game.ReplicatedStorage.React.Hooks.Player.useRobuxSpent)
local useTestGroup = require(game.ReplicatedStorage.React.Hooks.Player.useTestGroup)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
require(game.ReplicatedStorage.TestingGroupUtil.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local x1ChromaticMagnet2026Box = IdMap.Redeemable["x1 Chromatic Magnet 2026 Box"]
local x3ChromaticMagnet2026Box = IdMap.Redeemable["x3 Chromatic Magnet 2026 Box"]
local x10ChromaticMagnet2026Box = IdMap.Redeemable["x10 Chromatic Magnet 2026 Box"]
local x50ChromaticMagnet2026Box = IdMap.Redeemable["x50 Chromatic Magnet 2026 Box"]
local uDim = UDim.new(0, 8)
local vector = Vector2.new(0.3, 0.6)
local uDim2 = UDim2.fromScale(0.371456, 0.549358)
local v2 = {
	[x1ChromaticMagnet2026Box] = {
		Size = UDim2.fromScale(0.25, 1),
		LayoutOrder = 1,
		ZIndex = CONSTANTS.LAYER.CONTENT,
		Quantity = 1,
		Variant = "Green",
		Header = {
			Text = "x1 Roll"
		}
	},
	[x3ChromaticMagnet2026Box] = {
		Size = UDim2.fromScale(0.25, 1),
		LayoutOrder = 2,
		ZIndex = CONSTANTS.LAYER.RAISED,
		Quantity = 3,
		Variant = "Green",
		Header = {
			Text = "x3 Rolls"
		}
	},
	[x10ChromaticMagnet2026Box] = {
		Size = UDim2.fromScale(0.25, 1),
		LayoutOrder = 3,
		ZIndex = CONSTANTS.LAYER.RAISED_HIGH,
		Variant = "Yellow",
		Quantity = 10,
		WasPrice = {
			Value = 2000,
			DiscountText = "10% Off"
		},
		Header = {
			Text = "x10 Rolls",
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.HEADER.BACKGROUND),
				ColorSequenceKeypoint.new(0.509499, CONSTANTS.COLOR.PALETTE.GOLD_450),
				ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.HEADER.BACKGROUND)
			})
		}
	},
	[x50ChromaticMagnet2026Box] = {
		Size = UDim2.fromScale(0.3333333333333333, 1),
		LayoutOrder = 4,
		ZIndex = 4,
		Quantity = 50,
		Variant = "Rainbow",
		MinSpend = 3000,
		WasPrice = {
			Value = 10000,
			DiscountText = "10% Off"
		},
		Header = {
			Text = "x50 Rolls",
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(0.354059, Color3.fromRGB(255, 93, 177)),
				ColorSequenceKeypoint.new(0.666667, Color3.fromRGB(156, 106, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 221, 255))
			})
		}
	}
}
local info = v.info
local localPlayer = Players.LocalPlayer
local createElement = React.createElement

local function mergeTables(instance, instance2)
	local archivable

	if instance.Archivable == nil then
		archivable = instance2.Archivable
	else
		archivable = instance.Archivable
	end

	local result = {
		Archivable = archivable,
		Name = instance.Name or instance2.Name,
		children = createElement(React.Fragment, {}, instance.children or {}, instance2.children or {}),
		ref = instance.ref or instance2.ref
	}

	for k, v4 in pairs(instance) do
		result[k] = v4
	end

	for k, v4 in pairs(instance2) do
		if not result[k] then
			result[k] = v4
		end
	end

	return result
end

return function(props)
	local v3 = useMatch(x1ChromaticMagnet2026Box)
	local v4 = useMatch(x3ChromaticMagnet2026Box)
	local v5 = useMatch(x10ChromaticMagnet2026Box)
	local v6 = useMatch(x50ChromaticMagnet2026Box)
	local v7 = not RunService:IsRunning() and 9999 or useRobuxSpent()
	local v8 = useTestGroup(localPlayer, "x50RollV1")
	info((`x1={v3 ~= nil}, x3={v4 ~= nil}, x10={v5 ~= nil}, x50={v6 ~= nil}`))
	info((`robuxSpent={v7}`))
	info((`group={v8}`))
	local v10

	if v3 then
		v10 = v3.Index.ItemId or nil
	end

	local v11 = useRobuxPrice(v10)
	local v13

	if v4 then
		v13 = v4.Index.ItemId or nil
	end

	local v14 = useRobuxPrice(v13)
	local v16

	if v5 then
		v16 = v5.Index.ItemId or nil
	end

	local v17 = useRobuxPrice(v16)
	local v19

	if v6 then
		v19 = v6.Index.ItemId or nil
	end

	local v20 = useRobuxPrice(v19)
	local v21 = React.useMemo(function()
		local v22 = {}

		if v3 and v3.Index.ItemId then
			v22[v3.Index.ItemId] = v11
		end

		if v4 and v4.Index.ItemId then
			v22[v4.Index.ItemId] = v14
		end

		if v5 and v5.Index.ItemId then
			v22[v5.Index.ItemId] = v17
		end

		if v6 and v6.Index.ItemId then
			v22[v6.Index.ItemId] = v20
		end

		return v22
	end, {
		v11,
		v14,
		v17,
		v20
	})
	local v22 = v2[x50ChromaticMagnet2026Box]
	local v23 = v22 and v22.MinSpend and v22.MinSpend <= v7 and true or false
	local v24 = {}

	for k, v25 in pairs(v2) do
		local visible = not (v25 and v25.MinSpend and v7 < v25.MinSpend)

		if v8 == "Hidden" and x50ChromaticMagnet2026Box == k then
			info("group is hidden and id is x50, hide it")
			visible = false
		end

		local v28 = {
			StrokeAllowed = not props.ClipCorners,
			AutoButtonColor = not props.ClipCorners,
			ApplyCorner = props.ClipCorners and {
				CornerRadius = uDim,
				Left = v25.LayoutOrder == 1,
				Right = v25.LayoutOrder == 3 and not v23 or v25.LayoutOrder == 4
			} or nil,
			Variant = v25.Variant,
			Text = not v21[k] and "???" or `{FormatUtil.ROBUX_ICON}{TextUtil.commaValue(v21[k])}`,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 10
		}
		local v29 = k

		v28[React.Event.Activated] = function()
			props.OnPurchase(v29)
		end

		v28.SubText = v25.WasPrice and v11 and {
			Text = `{FormatUtil.ROBUX_ICON}{TextUtil.commaValue(v25.Quantity * v11)}`,
			TextColor = CONSTANTS.COLOR.PALETTE.BLACK,
			CrossedOut = true
		} or nil
		local v30 = mergeTables(v28, v25)
		local formatted = `{k}`
		local v33 = {
			Size = v25.Size,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Visible = visible,
			LayoutOrder = v25.LayoutOrder,
			ZIndex = v25.ZIndex
		}
		local discount

		if props.DiscountBanner and v25.WasPrice and v11 and v21[k] then
			discount = createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://117259165403809",
				Position = props.DiscountBanner.Position,
				AnchorPoint = props.DiscountBanner.AnchorPoint or vector,
				Size = props.DiscountBanner.Size or uDim2,
				ZIndex = 999
			}, {
				TextLabelShadow = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.DISPLAY,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.9, 0.825),
					Text = `{math.floor(100 * (v11 * v25.Quantity - v21[k]) / (v11 * v25.Quantity))}% Off`,
					TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					TextScaled = true,
					TextStrokeTransparency = CONSTANTS.ALPHA.MID
				}, {
					TextLabel = createElement("TextLabel", {
						AnchorPoint = Vector2.new(1, 1),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						FontFace = CONSTANTS.FONT.FACE.DISPLAY,
						Position = UDim2.fromScale(0.995, 0.925),
						Size = UDim2.fromScale(1, 1),
						Text = `{math.floor(100 * (v11 * v25.Quantity - v21[k]) / (v11 * v25.Quantity))}% Off`,
						TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
						TextScaled = true,
						TextStrokeTransparency = CONSTANTS.ALPHA.MID,
						ZIndex = CONSTANTS.LAYER.OVERLAY
					})
				})
			})
		end

		local v37 = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.5, -0.425),
			Size = UDim2.fromScale(1, 0.65),
			ZIndex = 999
		}
		local v40 = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			Position = UDim2.fromScale(0.5, -0.4),
			RichText = true,
			Size = UDim2.fromScale(0, 1.1),
			Text = v25.Header.Text,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH
		}
		local v41 = {
			UIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
			}),
			UIGradient = 0
		}
		local uIGradient

		if v25.Header.Color then
			uIGradient = createElement("UIGradient", {
				Color = v25.Header.Color
			})
		end

		v41.UIGradient = uIGradient
		v24[formatted] = createElement("Frame", v33, {
			Discount = discount,
			Header = createElement("Frame", v37, {
				Quantity = createElement("TextLabel", v40, v41),
				UIListLayout = createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = CONSTANTS.SPACING.PADDING.SCALE.XS,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center
				})
			}),
			Button = createElement(SimpleButton, v30)
		})
	end

	return createElement(React.Fragment, {}, v24)
end