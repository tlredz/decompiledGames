local createVector = vector.create
local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.Components.Map.Types)
local useAll = require(game.ReplicatedStorage.React.Hooks.Island.useAll)
return function(p, rect: Rect)
	local v = useAll()
	return React.useMemo(function()
		local result = {}

		if not (p and #v ~= 0) then
			return nil
		end

		for _, v2 in v do
			result[v2.Index.Key] = v2.World.Position * createVector(1, 0, 1)
		end

		result[p.ISLAND_NAMES.NE] = Vector3.new(rect.Max.X, 0, rect.Min.Y)
		result[p.ISLAND_NAMES.SE] = Vector3.new(rect.Max.X, 0, rect.Max.Y)
		result[p.ISLAND_NAMES.SW] = Vector3.new(rect.Min.X, 0, rect.Max.Y)
		result[p.ISLAND_NAMES.NW] = Vector3.new(rect.Min.X, 0, rect.Min.Y)
		result[p.ISLAND_NAMES.N] = Vector3.new(rect.Min.X + rect.Width / 2, 0, rect.Min.Y)
		result[p.ISLAND_NAMES.S] = Vector3.new(rect.Min.X + rect.Width / 2, 0, rect.Max.Y)
		result[p.ISLAND_NAMES.E] = Vector3.new(rect.Max.X, 0, rect.Min.Y + rect.Height / 2)
		result[p.ISLAND_NAMES.W] = Vector3.new(rect.Min.X, 0, rect.Min.Y + rect.Height / 2)
		return result
	end, { p, v, rect })
end