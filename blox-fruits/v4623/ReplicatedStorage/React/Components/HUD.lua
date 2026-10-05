local React = require(game.ReplicatedStorage.Packages.React)
local Currency = require(script.Currency)
local Menu = require(script.Menu)
local Version = require(script.Version)
local StatBars = require(script.StatBars)
local ExpAndLevel = require(script.ExpAndLevel)
local useLastInput = require(game.ReplicatedStorage.React.Hooks.useLastInput)
local useIsDungeon = require(game.ReplicatedStorage.React.Hooks.useIsDungeon)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(script.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	local v = useLastInput()
	local v2 = useIsDungeon()
	local mergeFrame = RobloxTypes.mergeFrame({
		Active = false,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, p)
	local v8 = {
		Position = UDim2.new(0, 9, 0.6, -12),
		AnchorPoint = Vector2.new(0, 0),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		Size = UDim2.new(0.19, 2, 0.4, 12)
	}
	local v9 = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = CONSTANTS.SPACING.PADDING.NONE,
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		Menu = p.OnMenuAction and not v2 and createElement(Menu, {
			LayoutOrder = 1,
			OnMenuAction = p.OnMenuAction,
			SizeConstraint = Enum.SizeConstraint.RelativeXY,
			Size = UDim2.new(1, 0, 0.235, 14)
		}) or createElement("Frame", {
			LayoutOrder = 1,
			Active = false,
			SizeConstraint = Enum.SizeConstraint.RelativeXY,
			Size = UDim2.new(1, 0, 0.235, 14),
			BackgroundTransparency = 1
		}),
		AboveAwakeningMeter = createElement("Frame", {
			LayoutOrder = 2,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			BackgroundColor3 = Color3.new(0, 1, 0),
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y
		}, {
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				VerticalFlex = Enum.UIFlexAlignment.Fill,
				Padding = CONSTANTS.SPACING.PADDING.NONE,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			CurrencyContainer = v ~= "Touch" and createElement(Currency, {
				LayoutOrder = 2,
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				Size = UDim2.new(1, 0, 0.09)
			}),
			UIPadding = v == "Touch" and createElement("UIPadding", {
				PaddingTop = UDim.new(0.15, 0)
			}),
			ExpAndLevel = createElement(ExpAndLevel, {
				LayoutOrder = 3,
				SizeConstraint = Enum.SizeConstraint.RelativeXY,
				Size = v == "Touch" and UDim2.new(1, 0, 0.24, 2) or UDim2.new(1, 0, 0.225, 0)
			})
		}),
		StatMeters = v ~= "Touch" and createElement(StatBars, {
			LayoutOrder = 3,
			Size = UDim2.fromScale(1, 0)
		}),
		AwakeningMeterZone = createElement("Frame", {
			LayoutOrder = v == "Touch" and 4 or 6,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			BackgroundColor3 = Color3.new(1, 0, 0),
			Size = UDim2.fromScale(1, v == "Touch" and 0.1 or 0.075)
		}),
		BelowAwakeningMeter = 0
	}
	local belowAwakeningMeter

	if v == "Touch" then
		belowAwakeningMeter = createElement("Frame", {
			LayoutOrder = 5,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Size = UDim2.fromScale(1, 0.3)
		}, {
			UIFlexItem = createElement("UIFlexItem", {
				FlexMode = Enum.UIFlexMode.Fill
			}),
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				Padding = CONSTANTS.SPACING.PADDING.NONE,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			CurrencyContainer = createElement("Frame", {
				Size = UDim2.new(1, 0, 0.7, 6),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				SizeConstraint = Enum.SizeConstraint.RelativeXY
			}, {
				UIListLayout = createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Bottom,
					Padding = CONSTANTS.SPACING.PADDING.NONE,
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				Fragments = createElement(Currency, {
					LayoutOrder = 1,
					SizeConstraint = Enum.SizeConstraint.RelativeXY,
					Size = UDim2.new(1, 0, 0.5),
					LockTo = "Fragments"
				}),
				Beli = createElement(Currency, {
					LayoutOrder = 2,
					SizeConstraint = Enum.SizeConstraint.RelativeXY,
					Size = UDim2.new(1, 0, 0.5),
					LockTo = "Beli"
				})
			})
		})
	else
		belowAwakeningMeter = false
	end

	v9.BelowAwakeningMeter = belowAwakeningMeter
	return createElement("Frame", mergeFrame, {
		LowerLeftColumn = createElement("Frame", v8, v9),
		CenteredStatBars = v == "Touch" and createElement(StatBars, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.955, -70),
			Size = UDim2.new(0.39, 2, 0.05, 5)
		}),
		Version = createElement(Version, {
			AnchorPoint = Vector2.new(0, 1),
			Position = v == "Touch" and UDim2.fromScale(0.16, 1) or UDim2.new(0, 4, 1, 0),
			Size = UDim2.new(0.2, 0, 0, 16),
			TextSize = 15
		})
	})
end