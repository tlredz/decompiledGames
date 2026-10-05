local React = require(game.ReplicatedStorage.Packages.React)
local Shop = require(game.ReplicatedStorage.React.Components.Gacha.ChromaticBanner.Shop)
local useSale = require(game.ReplicatedStorage.React.Hooks.useSale)
local usePolicyService = require(game.ReplicatedStorage.React.Hooks.Player.usePolicyService)
require(game.ReplicatedStorage.React.Components.DrawContextProvider)
local Global = require(game.ReplicatedStorage.Global)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local v = useSale("MagnetChromaticGacha2026")
	local v2 = usePolicyService()
	local dateTime

	if v then
		dateTime = v.Date.Finish:unwrap()
	end

	if Global.IsUnitTest then
		dateTime = DateTime.fromUnixTimestamp(DateTime.now().UnixTimestamp + 120)
	end

	if not (dateTime and DateTime.now().UnixTimestamp < dateTime.UnixTimestamp) or v2 and v2.ArePaidRandomItemsRestricted or props.DrawContext == "Offscreen" then
		return createElement(React.Fragment, {}, {})
	end

	return createElement(React.Fragment, {}, {
		Header = createElement("Frame", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			LayoutOrder = props.LayoutOrder,
			Size = UDim2.fromScale(1, 0.05),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			Background = createElement("Frame", {
				BackgroundColor3 = CONSTANTS.COLOR.DIVIDER.BORDER,
				BackgroundTransparency = 0,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.new(1, 0, 0, 1),
				ZIndex = CONSTANTS.LAYER.RAISED
			}),
			Text = createElement("TextLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.BODY,
				LayoutOrder = 1,
				Position = UDim2.fromScale(0, 0.05),
				Size = UDim2.fromScale(0.6, 0.9),
				Text = "🤑  PREMIUM GACHA",
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				UIStroke = createElement("UIStroke", {
					Color = Color3.fromRGB(143, 102, 0),
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
				}),
				UIGradient = createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.PALETTE.WHITE),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 225, 0))
					}),
					Rotation = 90
				})
			})
		}),
		Card = createElement("Frame", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			LayoutOrder = props.LayoutOrder,
			Size = UDim2.fromScale(1, 0.43),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			More = createElement("CanvasGroup", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Size = UDim2.fromScale(1, 0.43),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				SizeConstraint = Enum.SizeConstraint.RelativeXX
			}, {
				Component = createElement(Shop, {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.new(1, -4, 1, -4),
					BoxName = "PremiumChromaticMagnetGacha26",
					OnPurchase = function(p)
						local unwrapped = ItemConfig.match(p):unwrap()
						local onClick = props.OnClick
						local v3

						if unwrapped.Economy then
							v3 = unwrapped.Economy.IsGiftable == true
						else
							v3 = false
						end

						onClick(p, v3)
					end,
					OnItemSelected = function()
						props.OpenPremiumWindow()
					end,
					TimeEnds = dateTime
				})
			})
		})
	})
end