local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)

local function whichScopeLivesLonger(list, p)
	local v = 2
	local v2 = { list, p }
	local v3 = {}
	local count = 0
	local v4 = {}

	while v > 0 do
		for _, list2 in v2 do
			v3[list2] = true

			for _, v5 in ipairs(list2) do
				if v5 == list then
					return "definitely-b"
				end

				if v5 == p then
					return "definitely-a"
				end

				if not (typeof(v5) == "table" and v5[1] ~= nil and v3[list2] == nil) then
					continue
				end

				count += 1
				v4[count] = v5
			end
		end

		table.clear(v2)
		v = count
		v4, v2 = v2, v4
		count = 0
	end

	return "unsure"
end

local function whichLivesLonger(list, p, p2, p3)
	if External.isTimeCritical() then
		return "unsure"
	end

	if list ~= p2 then
		return (whichScopeLivesLonger(list, p2))
	end

	for i = #list, 1, -1 do
		local v = list[i]

		if v == p then
			return "definitely-b"
		end

		if v == p3 then
			return "definitely-a"
		end
	end

	return "unsure"
end

return whichLivesLonger