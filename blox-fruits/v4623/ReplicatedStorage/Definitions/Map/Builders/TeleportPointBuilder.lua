local Type = require(game.ReplicatedStorage.Packages.Type)
local TypeUtil = require(game.ReplicatedStorage.Util.TypeUtil)
local Types = require(game.ReplicatedStorage.Definitions.Map.Types)
local TeleportPointBuilder = {}
TeleportPointBuilder.PendingTeleportPoint = TypeUtil.Types.BetterUnion({
	Assigned = Types.TeleportPoint,
	Inherited = Type.strictInterface({
		Position = Type.Vector3
	})
})

function TeleportPointBuilder.new(vector: Vector3, sprite)
	return table.freeze({
		Sprite = sprite,
		Position = vector
	})
end

function TeleportPointBuilder.resolve(p, p2)
	return table.freeze({
		Sprite = p.Sprite or p2,
		Position = p.Position
	})
end

return TeleportPointBuilder