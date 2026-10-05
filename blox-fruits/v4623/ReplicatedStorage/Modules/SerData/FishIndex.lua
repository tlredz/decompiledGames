local Utility = require(script.Parent.Utility)
local FishIndex = {}

function FishIndex.encode(items)
	local writer = Utility.newWriter()
	writer(16, 0)
	local v = {}

	for k in items do
		table.insert(v, k)
	end

	writer(16, #v)

	for _, v2 in v do
		local item = items[v2]
		writer(16, v2)
		writer(32, item.CaughtCount)
		writer(16, item.LowestWeight)
		writer(16, item.HighestWeight)
	end

	return Utility.Trim(writer(16, 12345))
end

function FishIndex.decode(buf: buffer)
	local reader = Utility.newReader(buf)
	local v = reader(16)
	local result = nil

	if v == 0 then
		local v2 = reader(16)
		result = table.create(v2)

		for _ = 1, v2 do
			result[reader(16)] = {
				CaughtCount = reader(32),
				LowestWeight = reader(16),
				HighestWeight = reader(16)
			}
		end
	else
		error((`UNSUPPORTED FORMAT VERSION -> {v}`))
	end

	local v2 = reader(16)

	if v2 ~= 12345 then
		error((`CORRUPT END IDENTIFIER -> {v2}`))
	end

	return result
end

return FishIndex