local SimpleTest = require(game.ReplicatedStorage.Packages.SimpleTest)
local parentModule = require(script.Parent)
local v = {
	{
		Method = "unique"
	},
	{
		Method = "rejectsMalformed"
	}
}

for _, definition in parentModule.DEFINITIONS do
	table.insert(v, {
		Method = "roundTrip",
		Definition = definition,
		Segments = { definition.Key }
	})

	for _, island in definition.Islands do
		table.insert(v, {
			Method = "roundTrip",
			Definition = island,
			Segments = { island.Index.Map, island.Index.Key }
		})

		if not island.BonusMoments then
			continue
		end

		for _, bonusMoment in island.BonusMoments do
			table.insert(v, {
				Method = "roundTrip",
				Definition = bonusMoment,
				Segments = { bonusMoment.Index.Map, bonusMoment.Index.Island, bonusMoment.Index.Key }
			})
		end
	end
end

local function getMinimumLength(list)
	local v2 = #list - 1

	for _, v3 in list do
		v2 += #v3
	end

	return v2
end

local function findBonusMomentSegments()
	for _, v2 in v do
		if v2.Method == "roundTrip" and #v2.Segments == 3 then
			return v2.Segments
		end
	end

	error("no bonus moment definitions to test against")
end

return SimpleTest.Test.new({ SimpleTest.Parameter.Choose.new("TestCase", v, function(p)
		if p.Method == "roundTrip" then
			return (`{p.Method}:{table.concat(p.Segments, "/")}`)
		end

		return p.Method
	end) }, function(data)
	if data.Method == "roundTrip" then
		local address = parentModule.getAddress(data.Definition)
		assert(string.find(address, "[^ -~]") == nil, (`address "{address}" contains non-ascii characters`))
		local v2 = #address
		local segments = data.Segments
		local v3 = #segments - 1

		for _, segment in segments do
			v3 += #segment
		end

		local v4 = v2 == v3
		local v5 = #address
		local segments2 = data.Segments
		local v6 = #segments2 - 1

		for _, segment in segments2 do
			v6 += #segment
		end

		assert(v4, (`address "{address}" is {v5} bytes, expected {v6}`))

		for _, segment in data.Segments do
			assert(string.find(address, segment, 1, true), (`address "{address}" is missing "{segment}"`))
		end

		local v9 = parentModule.fromAddress(address)
		return v9.Type == data.Definition._AddressType and v9.Definition == data.Definition
	elseif data.Method == "unique" then
		local v2 = {}

		for _, v3 in v do
			if v3.Method ~= "roundTrip" then
				continue
			end

			local address = parentModule.getAddress(v3.Definition)

			if v2[address] then
				return false
			else
				v2[address] = true
			end
		end

		return true
	else
		if data.Method ~= "rejectsMalformed" then
			error((`unknown case: {data.Method}`))
			return
		end

		local v2, v3, v4 = table.unpack(findBonusMomentSegments())

		for _, v5 in {
			"",
			"/",
			`{v2}?`,
			`{v2}/`,
			`{v2}/{v3}?`,
			`{v2}/{v3}/`,
			`{v2}/{v3}/{v4}?`,
			`{v2}/{v3}/{v4}/`,
			`{v2}/{v3}/{v4}/{v4}`,
			(`{v3}/{v2}`)
		} do
			if pcall(parentModule.fromAddress, v5) then
				return false
			end
		end

		return true
	end
end, #v + 1)