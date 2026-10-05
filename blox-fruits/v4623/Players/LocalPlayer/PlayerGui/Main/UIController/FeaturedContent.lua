local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local SaleService = require(game.ReplicatedStorage.SaleService)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("Economy"):tag("Featured"):traceback():build()
local IdMap = require(game.ReplicatedStorage.IdMap)
local Tile = require(game.ReplicatedStorage.React.Components.BundleShop.Tile)
local use = require(game.ReplicatedStorage.React.Hooks.Item.Owned.use)
local scrollingFrame = script.Parent.Parent:WaitForChild("Shop"):WaitForChild("MenuShop"):WaitForChild("ScrollingFrame")
local uIPadding = scrollingFrame:WaitForChild("UIPadding")
local fruits = scrollingFrame:WaitForChild("Fruits")
local info = v.info
local createElement = React.createElement
return function()
	info("Initializing FeaturedContent module")
	scrollingFrame.Position = UDim2.new(0.5, -12, 0.5, 0)
	uIPadding.PaddingLeft = UDim.new(0, 24)
	scrollingFrame.Size = UDim2.new(0.84, 24, 1, 0)

	while SaleService:GetIfInitialized() == false do
		info("Waiting for SaleService to initialize...")
		task.wait()
	end

	info("Rendering tiles")
	local root = ReactRoblox.createRoot(fruits)

	local function onClick(p: number)
		local unwrapped = ItemConfig.match(p):unwrap()
		assert(unwrapped.Index.IdType == "Redeemable", (`item "{unwrapped.Index.DebugLabel}" is not a redeemable`))
		print("purchasing ", unwrapped.Index.DebugLabel)
		local Global = require(game.ReplicatedStorage.Global)
		Global.hookBuy(unwrapped.Index.StorageKey)
	end

	root:render((ReactRoblox.createPortal(createElement(function()
		local yetiYeti = use(IdMap.Moveset["Yeti-Yeti"])
		local v2 = (use(IdMap.Mutation.YETIMUTFiend) or not yetiYeti) and "Control" or "Fiend"
		return createElement(React.Fragment, {}, {
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
				VerticalFlex = Enum.UIFlexAlignment.Fill,
				Padding = UDim.new(0.012, 0),
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			Yeti = createElement(Tile, {
				LayoutOrder = 2,
				Type = "Yeti",
				OnClick = onClick,
				FlexWidthRatio = v2 == "Control" and 2 or 1
			}),
			Alt = createElement(Tile, {
				LayoutOrder = v2 == "Control" and 3 or 1,
				Type = v2,
				OnClick = onClick,
				FlexWidthRatio = 3
			})
		})
	end, {}), fruits)))
	fruits.Destroying:Connect(function()
		info("Unmounting tiles on destroy")
		root:unmount()
	end)
	info("Mounting tiles")
end