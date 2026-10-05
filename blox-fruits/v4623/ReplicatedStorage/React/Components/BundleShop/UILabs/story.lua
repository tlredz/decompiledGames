local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local SaleService = require(game.ReplicatedStorage.SaleService)
local BundleShop = require(game.ReplicatedStorage.React.Components.BundleShop)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		SaleType = UILabs.Choose({ "HalloweenBundle2025", "FoxSpiritBundle2025", "Valentines2026Bundle" }, 1)
	}
}, function(p)
	local ref = React.useRef(true)

	if ref.current then
		ref.current = false
		SaleService.init()
	end

	React.useEffect(function()
		return function()
			SaleService:Destroy()
		end
	end, {})
	local saleType = p.controls.SaleType
	return createElement(BundleShop, {
		IsOpen = true,
		BundleOffsaleTime = DateTime.fromUnixTimestamp(DateTime.now().UnixTimestamp + 120),
		SaleType = saleType,
		IsUIHidden = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.7, 0.6),
		OnProductClick = function(p2: number)
			print("OnProductClick:", p2)
		end,
		OnFocusClick = function(p2)
			print("OnFocusClick:", p2)
		end,
		PreviewFrameEffect = function(_, _)
			return function() end
		end
	}, {})
end)