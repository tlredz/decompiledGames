local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local BoostPill = require(script.BoostPill)
local ExpBar = require(script.ExpBar)
local useLevel = require(game.ReplicatedStorage.React.Hooks.Player.useLevel)
local useAttribute = require(game.ReplicatedStorage.React.Hooks.Instance.useAttribute)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
local useIsDungeon = require(game.ReplicatedStorage.React.Hooks.useIsDungeon)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(game.ReplicatedStorage.React.Components.HUD.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement

function fishFriendBoost(p)
	local v2

	if RunService:IsRunning() then
		v2 = Players.LocalPlayer
	end

	local v3 = useAttribute(v2, "FishFriendBonus")
	local v4 = useMockState("FishFriendBoost", 0)

	if v4 then
		v3 = v4:get()
	end

	local v5

	if type(v3) == "number" and v3 > 0 then
		return createElement(BoostPill, {
			Image = "rbxassetid://119324077504967",
			ImageRectSize = Vector2.new(150, 150),
			Amount = `+{2.5 * v3}% Luck{v3 >= 6 and " (MAX)" or ""}`,
			AmountSize = UDim2.new(2.36234, -4, 0.6, 0),
			AmountPosition = UDim2.fromScale(2.13396, 0.699999),
			AmountColor = Color3.fromRGB(255, 238, 0),
			Description = "Fishing Together",
			DescriptionColor = Color3.fromRGB(199, 223, 255),
			DescriptionPosition = UDim2.fromScale(0.7, 0.55),
			HasCaret = true,
			IsDescriptionVisible = p.IsDescriptionVisible,
			Size = UDim2.fromScale(0.7, 0.5599999999999999),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			ZIndex = CONSTANTS.LAYER.OVERLAY
		}) or nil
	end

	return v5
end

function exploreBoost(p)
	local v2

	if RunService:IsRunning() then
		v2 = Players.LocalPlayer
	end

	local v3 = useAttribute(v2, "ExploreBoost")
	local v4 = useMockState("ExploreBoost", 0)

	if v4 then
		v3 = v4:get()
	end

	return type(v3) == "number" and v3 > 0 and createElement(BoostPill, {
		Image = "http://www.roblox.com/asset/?id=15060132629",
		Amount = `{v3}`,
		AmountColor = Color3.fromRGB(225, 193, 154),
		AmountStrokeColor = Color3.fromRGB(76, 22, 29),
		Description = `Sea Exploration Group: {v3} Players`,
		DescriptionPosition = UDim2.fromScale(1, 0.5),
		IsDescriptionVisible = p.IsDescriptionVisible,
		Size = UDim2.fromScale(0.7, 0.5599999999999999),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		ZIndex = CONSTANTS.LAYER.OVERLAY
	}) or nil
end

function friendBoost(p)
	local v = useIsDungeon()
	local v2 = useAttribute(Players.LocalPlayer, "FriendBoost")
	local v3 = useMockState("FriendBoost", 0)

	if v3 then
		v2 = v3:get()
	end

	local v4 = useAttribute(Players.LocalPlayer, "NumFriends")
	local v5 = useMockState("FriendCount", 0)

	if v5 then
		v4 = v5:get()
	end

	local v6 = v2 and math.floor(v2 * 100 + 0.5) or nil
	local v7

	if v4 then
		v7 = math.min(math.min(v4, 3) * 15, 45) or nil
	end

	local v8

	if not (v or not (v6 and v7 and v6 > 0 and v7 > 0)) then
		return createElement(BoostPill, {
			Image = "http://www.roblox.com/asset/?id=12521449836",
			Amount = `{v6}%`,
			AmountColor = Color3.fromRGB(255, 94, 172),
			AmountStrokeColor = Color3.fromRGB(76, 22, 29),
			Description = `{v4} friend{v4 > 1 and "s are" or " is"} in your server! +{v7}% EXP`,
			IsDescriptionVisible = p.IsDescriptionVisible,
			Size = UDim2.fromScale(0.7, 0.5599999999999999),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			ZIndex = CONSTANTS.LAYER.OVERLAY
		}) or nil
	end

	return v8
end

return function(p)
	local v = useLevel()
	local state, setState = React.useState(nil)
	local isDescriptionVisible

	if state == nil then
		isDescriptionVisible = false
	else
		isDescriptionVisible = state ~= Enum.GuiState.Idle
	end

	local v3 = useIsDungeon()
	local v7 = RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		[React.Change.GuiState] = function(p2)
			setState(p2.GuiState)
		end
	}, p)
	local v8 = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = CONSTANTS.SPACING.PADDING.SCALE.XXL,
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		LevelContainer = createElement("Frame", {
			LayoutOrder = 1,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			BackgroundColor3 = CONSTANTS.COLOR.DISABLED.BORDER,
			Size = UDim2.fromScale(1, 0)
		}, {
			UIFlexItem = createElement("UIFlexItem", {
				FlexMode = Enum.UIFlexMode.Fill
			}),
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = CONSTANTS.SPACING.PADDING.SCALE.LG,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			LevelTextContainer = createElement("Frame", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				LayoutOrder = 1
			}, {
				UIListLayout = createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				Level = createElement("TextLabel", {
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Size = UDim2.fromScale(0, 1.5),
					FontFace = Font.new(
						CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO,
						Enum.FontWeight.Bold,
						Enum.FontStyle.Normal
					),
					Text = `Lv. {v or 1}`,
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true,
					TextStrokeTransparency = CONSTANTS.ALPHA.OPAQUE,
					TextXAlignment = Enum.TextXAlignment.Left,
					AutomaticSize = Enum.AutomaticSize.X,
					LayoutOrder = 1
				}, {
					UIStroke = React.createElement("UIStroke", {
						StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
						Thickness = 0.025
					})
				})
			}),
			BoostContainer = createElement("Frame", {
				LayoutOrder = 2,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Size = UDim2.fromScale(1, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				AutomaticSize = Enum.AutomaticSize.None
			}, {
				UIListLayout = createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Bottom,
					Padding = CONSTANTS.SPACING.PADDING.NONE,
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				ExploreBoost = createElement(exploreBoost, {
					IsDescriptionVisible = isDescriptionVisible
				}),
				FriendBoost = createElement(friendBoost, {
					IsDescriptionVisible = isDescriptionVisible
				}),
				FishFriendBoost = createElement(fishFriendBoost, {
					IsDescriptionVisible = isDescriptionVisible
				}),
				UIFlexItem = createElement("UIFlexItem", {
					FlexMode = Enum.UIFlexMode.Fill
				}),
				UIPadding = createElement("UIPadding", {
					PaddingBottom = CONSTANTS.SPACING.PADDING.SCALE.XL
				})
			})
		}),
		BarContainer = 0
	}
	local v11 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0.15, 2),
		AutomaticSize = Enum.AutomaticSize.None
	}
	local bar

	if not v3 then
		bar = createElement(ExpBar, {
			LayoutOrder = 2,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 1, 2)
		}) or nil
	end

	v8.BarContainer = createElement("Frame", v11, {
		Bar = bar
	})
	return createElement("Frame", v7, v8)
end