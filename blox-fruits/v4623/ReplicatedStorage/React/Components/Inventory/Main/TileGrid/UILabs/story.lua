local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local Types = require(game.ReplicatedStorage.React.Components.Inventory.Types)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local parentModule = require(script.Parent)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		SizeXPx = UILabs.Slider(300, 1, math.round(workspace.CurrentCamera.ViewportSize.X), 1),
		SizeYPx = UILabs.Slider(400, 1, math.round(workspace.CurrentCamera.ViewportSize.Y), 1),
		MaxCellsPerRow = UILabs.Slider(4, 2, 6, 1),
		Variant = UILabs.Choose({ "Fade", "Elevated", "Display" }, 2)
	}
}, function(p)
	local variant = p.controls.Variant
	local maxCellsPerRow = p.controls.MaxCellsPerRow
	local sizeXPx = p.controls.SizeXPx
	local sizeYPx = p.controls.SizeYPx
	local state, setState = React.useState(false)
	local tiles = React.useMemo(function()
		local result = {}

		for _, idType in ItemId.getTypes():unwrap() do
			for _, v3 in ItemConfig.Query.select({
				Index = {
					IdType = idType
				}
			}) do
				local itemId = v3.Index.ItemId

				if ItemId.getDataFromId(itemId):isErr() then
					continue
				end

				local v4 = {
					ItemId = itemId
				}
				TableUtil.deepFreeze(v4)
				assert(Types.Types.Tile.check(v4))
				table.insert(result, v4)
			end
		end

		TableUtil.randomize(result)
		table.freeze(result)
		return result
	end, {})
	React.useEffect(function()
		if state then
			return function() end
		end

		local thread = task.spawn(function()
			task.wait()
			setState(true)
		end)
		return function()
			task.cancel(thread)
		end
	end, {})
	return createElement(parentModule, {
		Tiles = tiles,
		Variant = variant,
		RowCellCount = maxCellsPerRow,
		BackgroundTransparency = 0.5,
		OnGamepadBorderExit = function() end,
		OnScrollToTop = function() end,
		ScrollToTop = false,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutomaticSize = Enum.AutomaticSize.None,
		Size = UDim2.fromOffset(sizeXPx, sizeYPx)
	})
end)