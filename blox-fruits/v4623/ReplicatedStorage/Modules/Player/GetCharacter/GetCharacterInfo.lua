local GetPlayer = require(game.ReplicatedStorage.Modules.Player.GetPlayer)
local characters = workspace:WaitForChild("Characters")
return function(p)
	local player = GetPlayer(p)

	if player and player.Team then
		local character = player.Character

		if character and character.Parent == characters then
			local primaryPart = character.PrimaryPart

			if primaryPart and primaryPart:GetAttribute("DoneSpawning") and character:FindFirstChild("CharacterReady") then
				local humanoid = character:FindFirstChildOfClass("Humanoid")

				if humanoid and humanoid.Health > 0 then
					return {
						Character = character,
						Humanoid = humanoid,
						PrimaryPart = primaryPart
					}
				end
			end
		end
	end

	return nil
end