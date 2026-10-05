local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local SaleService = require(game.ReplicatedStorage.SaleService)
local Banner = require(game.ReplicatedStorage.React.Components.BundleShop.Banner)
local names = {}

for _, child in script.Parent:GetChildren() do
	if child ~= script then
		table.insert(names, child.Name)
	end
end

table.freeze(names)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		BannerType = UILabs.Choose(names, 1),
		IncludePreviewButton = UILabs.Boolean(false)
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
	local bannerType = p.controls.BannerType
	local includePreviewButton = p.controls.IncludePreviewButton
	return createElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(600, 200)
	}, {
		UIFlexibleLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			VerticalFlex = Enum.UIFlexAlignment.Fill
		}),
		Banner = createElement(Banner, {
			Type = bannerType,
			LayoutOrder = 1,
			OnClick = function(p2: number)
				print("Clicked tile with redeemableId:", p2)
			end,
			OnPreviewClick = includePreviewButton and function()
				print("Preview clicked tile")
			end or nil
		}, {})
	})
end)