local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemId = require(ReplicatedStorage.Economy.ItemId)
require(ReplicatedStorage.React.Components.Inventory.Types)
local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local parentModule = require(script.Parent)
local createElement = React.createElement

local function component(_)
	local state, setState = React.useState(true)
	return createElement(parentModule, {
		IsOpen = state,
		SetIsOpen = setState,
		Tiles = React.useMemo(function()
			local result = {}

			for _, idType in ItemId.getTypes():unwrap() do
				for _, v3 in ItemConfig.Query.select({
					Index = {
						IdType = idType
					}
				}) do
					table.insert(result, {
						ItemId = v3.Index.ItemId
					})
				end
			end

			table.freeze(result)
			return result
		end, {})
	})
end

return function(p)
	local root = ReactRoblox.createRoot(p)
	task.spawn(function()
		root:render((ReactRoblox.createPortal(createElement(component, {}), p)))
	end)
	return function()
		root:unmount()
	end
end