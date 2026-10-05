local deepCopy

deepCopy = function(items)
	local result = {}

	for k, item in pairs(items) do
		if type(item) == "table" then
			item = deepCopy(item)
		end

		result[k] = item
	end

	return result
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
return (deepCopy((require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync")))))