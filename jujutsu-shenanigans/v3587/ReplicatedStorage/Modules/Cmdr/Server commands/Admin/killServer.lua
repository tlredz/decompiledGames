return function(_, list)
	for _, v in pairs(list) do
		if v.Character then
			v.Character:BreakJoints()
		end
	end

	return ("Killed %d players."):format(#list)
end