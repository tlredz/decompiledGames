return function(_, list)
	for _, v in pairs(list) do
		if v.Character then
			v:LoadCharacter()
		end
	end

	return ("Respawned %d players."):format(#list)
end