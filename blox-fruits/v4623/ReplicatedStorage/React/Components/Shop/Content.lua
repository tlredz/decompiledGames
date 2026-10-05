local React = require(game.ReplicatedStorage.Packages.React)
local FeaturedFruits = require(script.Sections.FeaturedFruits)
local FruitShop = require(script.Sections.FruitShop)
local ExpBoosts = require(script.Sections.ExpBoosts)
local Fragments = require(script.Sections.Fragments)
local Products = require(script.Sections.Products)
local Gamepasses = require(script.Sections.Gamepasses)
local Mastery = require(script.Sections.Mastery)
local SimulationData = require(script.Sections.SimulationData)
local GiftBanner = require(script.GiftBanner)
local ChromaticShopBanner = require(script.Sections.ChromaticShopBanner)
require(game.ReplicatedStorage.React.Components.DrawContextProvider)
require(game.ReplicatedStorage.React.Hooks.useCurrentSea)
local useGiftCount = require(game.ReplicatedStorage.React.Hooks.Player.useGiftCount)
require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	local v = useGiftCount()
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		ClipsDescendants = true,
		Position = UDim2.fromScale(0.5, 1),
		Size = UDim2.fromScale(1, 0.9)
	}, {
		UICorner = createElement("UICorner", {
			TopRightRadius = CONSTANTS.SPACING.CORNER_RADIUS.NONE,
			TopLeftRadius = CONSTANTS.SPACING.CORNER_RADIUS.NONE,
			BottomRightRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.XS,
			BottomLeftRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.XS
		}),
		Layout = createElement(React.Fragment, {}, {
			UIPadding = createElement("UIPadding", {
				PaddingBottom = CONSTANTS.SPACING.PADDING.OFFSET.LG,
				PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.LG,
				PaddingLeft = CONSTANTS.SPACING.PADDING.SCALE.MD,
				PaddingRight = CONSTANTS.SPACING.PADDING.SCALE.MD
			})
		}),
		GiftBanner = createElement(GiftBanner, {
			OnClick = function()
				p.OnInteraction({
					Type = "GiftBanner"
				})
			end
		}),
		ScrollingFrame = createElement("ScrollingFrame", {
			AnchorPoint = Vector2.new(0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			CanvasSize = UDim2.new(),
			ScrollBarThickness = 10,
			Size = UDim2.new(1, 12, 1 - (v and v > 0 and 0.12 or 0), 0),
			Position = UDim2.new(0, 0, v and v > 0 and 0.12 or 0, 0),
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			VerticalScrollBarInset = Enum.ScrollBarInset.Always,
			ZIndex = CONSTANTS.LAYER.RAISED,
			LayoutOrder = 2
		}, {
			Layout = createElement(React.Fragment, {}, {
				UIPadding = createElement("UIPadding", {
					PaddingBottom = CONSTANTS.SPACING.PADDING.OFFSET.LG,
					PaddingRight = UDim.new(0, CONSTANTS.THICKNESS.SCROLLBAR.REGULAR)
				}),
				UIListLayout = createElement("UIListLayout", {
					Padding = UDim.new(0.008, 0),
					SortOrder = Enum.SortOrder.LayoutOrder
				})
			}),
			ChromaticBanner = createElement(ChromaticShopBanner, {
				LayoutOrder = -6,
				DrawContext = p.DrawContext,
				OpenPremiumWindow = function()
					p.OnInteraction({
						Type = "ChromaticBanner"
					})
				end,
				OnClick = function(itemId, isGiftable)
					p.OnInteraction({
						Type = "Product",
						ItemId = itemId,
						IsGiftable = isGiftable
					})
				end
			}),
			FruitShop = createElement(FruitShop, {
				LayoutOrder = -5,
				OnClick = function()
					p.OnInteraction({
						Type = "FruitShop"
					})
				end
			}),
			FeaturedFruits = createElement(FeaturedFruits, {
				LayoutOrder = -1,
				OnClick = function(itemId: number)
					p.OnInteraction({
						Type = "Product",
						ItemId = itemId,
						IsGiftable = true
					})
				end
			}),
			ExpBoosts = createElement(ExpBoosts, {
				OnClick = function(itemId: number)
					p.OnInteraction({
						Type = "Product",
						ItemId = itemId,
						IsGiftable = true
					})
				end
			}),
			Fragments = createElement(Fragments, {
				LayoutOrder = 2,
				OnClick = function(itemId: number)
					p.OnInteraction({
						Type = "Product",
						ItemId = itemId,
						IsGiftable = true
					})
				end
			}),
			Products = createElement(Products, {
				LayoutOrder = 6,
				OnClick = function(itemId: number, isGiftable: boolean)
					p.OnInteraction({
						Type = "Product",
						ItemId = itemId,
						IsGiftable = isGiftable
					})
				end
			}),
			Gamepasses = createElement(Gamepasses, {
				LayoutOrder = 9,
				OnClick = function(itemId: number)
					p.OnInteraction({
						Type = "Product",
						ItemId = itemId,
						IsGiftable = true
					})
				end
			}),
			Mastery = createElement(Mastery, {
				LayoutOrder = 15,
				OnClick = function(_: number, itemId: number?)
					assert(itemId, "missing product id")
					p.OnInteraction({
						Type = "Product",
						ItemId = itemId,
						IsGiftable = false
					})
				end
			}),
			SimulationData = createElement(SimulationData, {
				LayoutOrder = 17,
				OnClick = function(itemId: number)
					p.OnInteraction({
						Type = "Product",
						ItemId = itemId,
						IsGiftable = true
					})
				end
			})
		})
	})
end