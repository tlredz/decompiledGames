local RunService = game:GetService("RunService")
local Result = require(game.ReplicatedStorage.Packages.Result)
local Types = require(game.ReplicatedStorage.React.Components.Inventory.Types)

if RunService:IsRunning() then
	task.spawn(function()
		require(game.ReplicatedStorage.Modules.FishHelper)
	end)
end

local check = Types.Types.Tile.check

function matchTile(p)
	return Result.match(Result.catch(check(p)), function(_)
		return Result.ok(p)
	end, function(p2)
		return Result.err(p2)
	end)
end

return {
	Types = {
		Tile = {
			check = Types.Types.Tile.check,
			new = function(itemId: number, value2: string?)
				if typeof(itemId) ~= "number" then
					return Result.err("Expected itemId to be a number, got " .. typeof(itemId))
				end

				if value2 ~= nil and typeof(value2) ~= "string" then
					return Result.err("Expected networkedUID to be a string or nil, got " .. typeof(value2))
				end

				local v = {
					ItemId = itemId,
					NetworkedUID = value2
				}
				table.freeze(v)
				return Result.ok(v)
			end,
			eq = Types.Types.Tile.eq,
			match = matchTile
		}
	}
}