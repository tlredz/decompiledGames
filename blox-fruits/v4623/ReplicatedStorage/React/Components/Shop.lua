local React = require(game.ReplicatedStorage.Packages.React)
local Spring = require(game.ReplicatedStorage.Packages.Spring)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local Header = require(game.ReplicatedStorage.React.Components.Header)
local ConfirmationDialog = require(game.ReplicatedStorage.React.Components.Shop.ConfirmationDialog)
local Content = require(game.ReplicatedStorage.React.Components.Shop.Content)
local DrawContextProvider = require(game.ReplicatedStorage.React.Components.DrawContextProvider)
local Scrim = require(script.Scrim)
local useSpringEffect = require(game.ReplicatedStorage.React.Hooks.Animation.useSpringEffect)
local useGiftCount = require(game.ReplicatedStorage.React.Hooks.Player.useGiftCount)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local current2 = typeof(props.IsOpen) ~= "boolean" or props.IsOpen
	local v2 = useGiftCount()
	local ref = React.useRef(nil)
	local state, setState = React.useState(current2 and "Default" or "Offscreen")
	local ref2 = React.useRef(current2)
	ref2.current = current2
	useSpringEffect(current2 and 1 or 0, Spring.new(0.85, 2, current2 and 1 or 0), true, function(p: number, _: number)
		local current = ref.current

		if current then
			current.Visible = p > 0
			current.Position = UDim2.fromScale(0.5, 1):Lerp(UDim2.fromScale(0.5, 0.475), p)
			current.AnchorPoint = Vector2.new(0.5, p * 0.5)
		end
	end, function()
		setState("Moving")
	end, function()
		if ref2.current then
			setState("Default")
		else
			setState("Offscreen")
		end
	end)
	local mergeFrame = RobloxTypes.mergeFrame({
		ref = ref,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.5, 0.475),
		Size = UDim2.fromScale(0.5, 0.5),
		Visible = false
	}, props)
	local children = {
		UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
			AspectRatio = 1.5
		}),
		UISizeConstraint = createElement("UISizeConstraint", {
			MaxSize = Vector2.new(800, 800),
			MinSize = Vector2.new(350, 400)
		}),
		Scrim = 0,
		Header = 0,
		DrawContextProvider = 0
	}
	local scrim

	if props.SelectedItemId then
		scrim = createElement(Scrim, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, 4, 1, 4),
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH
		}, {
			ConfirmationDialog = createElement(ConfirmationDialog, {
				ItemId = props.SelectedItemId,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.55),
				Size = UDim2.fromScale(0.65, 0.65),
				ZIndex = 4,
				OnBuy = function()
					props.OnInteraction({
						Type = "PurchaseProduct",
						ItemId = props.SelectedItemId
					})
				end,
				OnGift = function()
					props.OnInteraction({
						Type = "GiftProduct",
						ItemId = props.SelectedItemId
					})
				end,
				OnCancel = function()
					props.OnInteraction({
						Type = "Select"
					})
				end
			})
		})
	end

	children.Scrim = scrim
	children.Header = createElement(Header, {
		Text = "Shop",
		AnchorPoint = Vector2.new(0.5, 0),
		LayoutOrder = -1,
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.new(1, 0, 0.11, -2),
		ZIndex = CONSTANTS.LAYER.RAISED,
		OnGift = (not v2 or v2 == 0) and (function()
			props.OnInteraction({
				Type = "GiftBanner"
			})
		end or nil) or nil,
		OnExit = function()
			props.OnInteraction({
				Type = "Exit"
			})
		end
	})
	children.DrawContextProvider = createElement(DrawContextProvider, {
		Context = props.SelectedItemId and "Background" or state
	}, {
		Content = createElement(Content, {
			DrawContext = state,
			OnInteraction = function(data)
				if data.Type == "Product" then
					local itemId = data.ItemId

					if data.IsGiftable == false then
						props.OnInteraction({
							Type = "PurchaseProduct",
							ItemId = itemId
						})
					else
						props.OnInteraction({
							Type = "Select",
							ItemId = itemId
						})
					end
				elseif data.Type == "Premium" then
					props.OnInteraction({
						Type = "Premium"
					})
				elseif data.Type == "FruitShop" then
					props.OnInteraction({
						Type = "FruitShop"
					})
				elseif data.Type == "GiftBanner" then
					props.OnInteraction({
						Type = "GiftBanner"
					})
				elseif data.Type == "ChromaticBanner" then
					props.OnInteraction({
						Type = "ChromaticBanner"
					})
				end
			end
		})
	})
	return createElement("Frame", mergeFrame, {
		DrawContextProvider = createElement(DrawContextProvider, {
			Context = state
		}, children)
	})
end