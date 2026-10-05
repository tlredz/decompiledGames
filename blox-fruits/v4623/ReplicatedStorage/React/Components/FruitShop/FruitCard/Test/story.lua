local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
require(game.ReplicatedStorage.React.RobloxTypes)
local parentModule = require(script.Parent)
require(script.Parent.Parent.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement

local function component(_)
	local state, setState = React.useState(false)
	local state2, setState2 = React.useState(false)
	local state3, setState3 = React.useState(false)
	local state4, _ = React.useState(true)
	local v = React.useMemo(function()
		return require(game.ReplicatedStorage.Controllers.UI.FruitShop.Data)
	end, {})
	local v2 = React.useMemo(function()
		local PERMANENT_FRUIT = require(game.ReplicatedStorage.Shop.LIBRARY.PRODUCTS.PERMANENT_FRUIT)

		for _, v3 in pairs(PERMANENT_FRUIT) do
			return v3
		end

		error("Control fruit not found in permanent fruits")
	end, {})
	return createElement("Frame", {
		Name = "StoryContainer",
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.875, 1),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, {
		FruitCard = createElement(parentModule, {
			IsControllerActive = false,
			Data = v["Control-Control"],
			Item = v2,
			CardHeightRatio = 0.22435897435897437,
			PanelHeightRatio = 0.125,
			CardAnimationEasingStyle = Enum.EasingStyle.Quad,
			CardAnimationEasingDirection = Enum.EasingDirection.InOut,
			CardAnimationDuration = 0.2,
			IsOwned = state3,
			BuildQuality = "Full",
			IsLocked = state4,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromScale(0.7, 0.3),
			HoverWiggleEnabled = true,
			PanelPadding = UDim.new(0, 4),
			IsSelected = state,
			IsEquipped = state2,
			OnCardClick = function()
				setState(not state)
			end,
			OnGiftClick = function()
				print("gift click")
			end,
			OnMutationClick = function()
				print("mutation click")
			end,
			OnTempPurchaseClick = function()
				setState2(true)
			end,
			OnPermPurchaseClick = function()
				setState3(true)
				setState2(true)
			end
		}, {})
	})
end

return function(p)
	local folder = Instance.new("Folder")
	local root = ReactRoblox.createRoot(folder)
	local thread = task.spawn(function()
		local element = React.createElement(component, {})
		root:render((ReactRoblox.createPortal(element, p)))
	end)
	return function()
		folder:Destroy()
		print("Shop clean up")
		root:unmount()
		task.cancel(thread)
	end
end