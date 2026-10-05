return function(_, list)
	for _, v in pairs(list) do
		v:Kick("Kicked by admin.")
	end

	return ("Kicked %d players."):format(#list)
end