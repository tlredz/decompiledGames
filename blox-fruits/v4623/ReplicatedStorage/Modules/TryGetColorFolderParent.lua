local Players = game:GetService("Players")

local function resolve(value, _: string)
	if not value then
		return nil
	end

	local character = nil

	if typeof(value) == "Instance" then
		character = value
	elseif typeof(value) == "table" and value.Character and typeof(value.Character) == "Instance" then
		character = value.Character
	end

	local playerFromCharacter = character and character:IsA("Model") and Players:GetPlayerFromCharacter(character)
	return playerFromCharacter or character
end

return function(player)
	local success, result = pcall(function()
		local v = resolve(player.SkinParent, "data.SkinParent")

		if v then
			return v
		end

		local v2 = resolve(player.summoner, "data.summoner")

		if v2 then
			return v2
		end

		local v3 = resolve(player.player or player.Player or player.plr, "data.[Player,plr,player]")
		return v3 or resolve(player.Character or player.char, "data.[char,Character]")
	end)

	if success then
		return result
	end

	task.spawn(error, result)
	return nil
end