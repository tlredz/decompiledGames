local function removeTable(list, p)
	for i = 1, #list do
		if list[i] ~= p then
			continue
		end

		table.remove(list, i)
		break
	end
end

return removeTable