local HttpService = game:GetService("HttpService")
require(script.Parent.Parent.types)
local createMotion = require(script.Parent.Parent.createMotion)

local function createSnapshot(p, value: number?)
	local motion = createMotion(0)
	motion:to(p)
	local v = {}

	for _ = 1, value or 20 do
		local v2 = motion:step(0.1)

		if v2 < 1 then
			v2 = math.floor(v2 * 100) / 100
		elseif v2 > 1 then
			v2 = math.ceil(v2 * 100) / 100
		end

		table.insert(v, v2)

		if v2 == 1 then
			break
		end
	end

	return HttpService:JSONEncode(v), motion
end

return {
	createSnapshot = createSnapshot,
	testSnapshot = function(p, value: string)
		local snapshot, v2 = createSnapshot(p, select(2, string.gsub(value, ",", ",")) + 1)

		if snapshot ~= value then
			error(`Snapshot does not match expected value.\n\nExpected:\n{value}\n\nActual:\n{snapshot}`, 2)
		end

		return v2
	end
}