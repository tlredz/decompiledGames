local Utility = require(script.Parent.Utility)
local v = { "Shiny", "Corrupted", "Celestial" }
local count = #v
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getMaskForModifier(p: string)
	local index = table.find(v, p)

	if index then
		return v2[index]
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function popcount(p: number)
	local v3 = p - bit32.band(bit32.rshift(p, 1), 1431655765)
	local v4 = bit32.band(v3, 858993459) + bit32.band(bit32.rshift(v3, 2), 858993459)
	return (bit32.rshift(bit32.band(v4 + bit32.rshift(v4, 4), 252645135) * 16843009, 24))
end

for i = 1, 32 do
	v2[i] = 2 ^ (i - 1)
end

local FishInventory = {}

function FishInventory.encode(list)
	local writer = Utility.newWriter()
	writer(16, 1)
	writer(16, #list)

	for _, v3 in list do
		writer(16, v3.Id)
		writer(16, v3.Weight)
		local v4 = 0

		for _, modifier in v3.Modifiers do
			local maskForModifier = getMaskForModifier(modifier) -- equivalent call inferred; original call site unknown

			if maskForModifier then
				v4 = bit32.bor(v4, maskForModifier)
			end
		end

		writer(32, v4)
		writer(1, v3.Favorited == true and 1 or 0)
	end

	return Utility.Trim(writer(16, 36925))
end

function FishInventory.decode(buf: buffer)
	local reader = Utility.newReader(buf)
	local v3 = reader(16)
	local result = nil

	if v3 == 0 then
		local v4 = reader(16)
		result = table.create(v4)

		for i = 1, v4 do
			local id = reader(16)
			local weight = reader(16)
			local v7 = reader(32)
			local modifiers = table.create(popcount(v7))
			local count2 = 0

			for i2 = 1, count do
				local v9 = v[i2]
				local maskForModifier = getMaskForModifier(v9) -- equivalent call inferred; original call site unknown

				if not (maskForModifier and bit32.band(v7, maskForModifier) == maskForModifier) then
					continue
				end

				count2 += 1
				modifiers[count2] = v9
			end

			local HttpService = game:GetService("HttpService")
			result[i] = {
				Id = id,
				Weight = weight,
				Modifiers = modifiers,
				WEAK_UID = HttpService:GenerateGUID(false),
				Favorited = false
			}
		end
	elseif v3 == 1 then
		local v4 = reader(16)
		result = table.create(v4)

		for i = 1, v4 do
			local id = reader(16)
			local weight = reader(16)
			local v7 = reader(32)
			local v8 = reader(1)
			local modifiers = table.create(popcount(v7))
			local count2 = 0

			for i2 = 1, count do
				local v10 = v[i2]
				local maskForModifier = getMaskForModifier(v10) -- equivalent call inferred; original call site unknown

				if not (maskForModifier and bit32.band(v7, maskForModifier) == maskForModifier) then
					continue
				end

				count2 += 1
				modifiers[count2] = v10
			end

			local v10 = {
				Id = id,
				Weight = weight,
				Modifiers = modifiers,
				Favorited = v8 == 1,
				WEAK_UID = 0
			}
			local HttpService = game:GetService("HttpService")
			v10.WEAK_UID = HttpService:GenerateGUID(false)
			result[i] = v10
		end
	else
		error((`UNSUPPORTED FORMAT VERSION -> {v3}`))
	end

	local v4 = reader(16)

	if v4 ~= 36925 then
		error((`CORRUPT END IDENTIFIER -> {v4}`))
	end

	return result
end

return FishInventory