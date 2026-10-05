return function(list)
	for i = #list, 1, -1 do
		if list[i]:GetAttribute("IsInvisible") then
			table.remove(list, i)
		end
	end
end