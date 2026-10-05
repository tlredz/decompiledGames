local Players = game:GetService("Players")
game:GetService("TeleportService")
require(script.Parent.Promise)
local TeleportationUtil = {}

function TeleportationUtil.TeleportPlayersInBox(instance, position: Vector3)
	if not (instance and position) then
		return
	end

	local boundingBox, v = instance:GetBoundingBox()
	local partBoundsInBox = workspace:GetPartBoundsInBox(boundingBox, v)

	for _, v2 in ipairs(partBoundsInBox) do
		local playerFromCharacter = Players:GetPlayerFromCharacter(v2.Parent)

		if not playerFromCharacter then
			continue
		end

		local character = playerFromCharacter.Character

		if character then
			character:MoveTo(position)
		end
	end
end

function TeleportationUtil.ResetPlayersInBoxBackToLobby(instance)
	if not instance then
		return
	end

	local boundingBox, v = instance:GetBoundingBox()
	local partBoundsInBox = workspace:GetPartBoundsInBox(boundingBox, v)

	for _, v2 in ipairs(partBoundsInBox) do
		local playerFromCharacter = Players:GetPlayerFromCharacter(v2.Parent)

		if playerFromCharacter then
			playerFromCharacter:LoadCharacterAsync()
		end
	end
end

return TeleportationUtil