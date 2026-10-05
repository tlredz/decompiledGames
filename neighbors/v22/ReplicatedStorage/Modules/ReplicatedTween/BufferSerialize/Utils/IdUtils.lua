local function getWithSameUniqueId(p: number)
	local descendants = {}

	for _, descendant in game:GetDescendants() do
		if descendant:GetAttribute("UniqueId") == p then
			table.insert(descendants, descendant)
		end
	end

	return descendants
end

local function waitforid(instance)
	local uniqueId = instance:GetAttribute("UniqueId")

	if uniqueId then
		return uniqueId
	end

	local count = 0

	repeat
		task.wait(1)
		uniqueId = instance:GetAttribute("UniqueId")
		count += 1
	until uniqueId or count == 5

	if count == 5 then
		warn("Max retries exceeded.")
	end

	return uniqueId
end

return {
	validateid = function(instance)
		local v = waitforid(instance)

		if #getWithSameUniqueId(v) > 1 then
			repeat
				task.wait(1)
			until instance:GetAttribute("UniqueId") ~= v
		end

		return v
	end,
	waitforid = waitforid
}