local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CharacterUtil = require(ReplicatedStorage.Modules.Shared.Utils.CharacterUtil)
return {
	HasPermissionAndIsCloseEnough = function(player, p, p2: number, object, list)
		if object and not object:HasAnyRole(player, table.unpack(list)) then
			return false
		end

		local distanceTo = CharacterUtil.distanceTo(player.Character, p, "UpperTorso")
		return distanceTo ~= nil and not (p2 < distanceTo)
	end
}