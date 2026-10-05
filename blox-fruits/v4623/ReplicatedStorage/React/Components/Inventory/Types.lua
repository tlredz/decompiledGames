local Error = require(game.ReplicatedStorage.Packages.Error)
local Type = require(game.ReplicatedStorage.Packages.Type)

function checkIsFrozen(list)
	if typeof(list) ~= "table" then
		return false, (`Expected a table, got {typeof(list)}`)
	end

	if table.isfrozen(list) then
		return true
	end

	return false, (`table {Error.displayAsJson(list)} is not frozen`)
end

return {
	Types = {
		Tile = {
			eq = function(p, p2)
				return p == p2 or p.NetworkedUID == p2.NetworkedUID and p.ItemId == p2.ItemId
			end,
			check = Type.intersection(checkIsFrozen, Type.strictInterface({
				ItemId = Type.integer,
				NetworkedUID = Type.optional(Type.string)
			}))
		}
	}
}