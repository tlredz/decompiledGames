game:GetService("ReplicatedStorage")

local function checkTable(list, p)
	if table.find(list, p) then
		return true
	end

	return false
end

return checkTable