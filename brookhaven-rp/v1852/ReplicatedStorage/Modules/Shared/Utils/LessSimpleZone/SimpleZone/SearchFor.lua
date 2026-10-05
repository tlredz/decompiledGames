-- equivalent calls inferred from this helper; original call sites unknown
local function splitRecursiveProperty(value: string)
	local parts = value:split("_")
	return parts[1], #parts > 1 and table.concat(parts, "_", 2, #parts)
end

local function propertyChecker(item, p, checkCondition, items)
	for k, item2 in items do
		local v, v2 = splitRecursiveProperty(k) -- equivalent call inferred; original call site unknown

		if v == "Parent" and v2 then
			checkCondition(SearchFor({ item.Parent }, {
				[v2] = item2
			}, p)[item.Parent])
		elseif item:FindFirstChild(v) and v2 then
			checkCondition(SearchFor({ item:FindFirstChild(v) }, {
				[v2] = item2
			}, p)[item.Parent])
		elseif item2 == "Tag" then
			checkCondition(item:HasTag(v))
		elseif v:match("Attribute_") then
			checkCondition(item:GetAttribute(v:split("_")[2]) == item2)
		else
			checkCondition(item[v] == item2)
		end
	end
end

function SearchFor(items, p, p2: string)
	local v

	if p2 == nil then
		v = false
	else
		v = p2 == "Or" or p2 == "And"
	end

	assert(v, "Bad mode argument.")
	local result = {}

	for _, item in items do
		local v2 = false
		local v3 = item

		local function checkCondition(p3)
			if p3 and p2 == "Or" then
				table.insert(result, v3)
			elseif not p3 and p2 == "And" then
				v2 = true
			end
		end

		propertyChecker(item, p2, checkCondition, p)

		if v2 or p2 ~= "And" then
			continue
		end

		table.insert(result, item)
	end

	return result
end

return SearchFor