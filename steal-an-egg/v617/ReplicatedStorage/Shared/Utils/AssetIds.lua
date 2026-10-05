local v2 = {
	"rbxassetid://",
	"https://assetdelivery.roblox.com/v1/asset/?id=",
	"https://www.roblox.com/asset/?id=",
	"http://www.roblox.com/asset/?id="
}

local function wholePositive(p: number)
	if p > 0 and p < 1e999 and p % 1 == 0 then
		return p
	end

	return nil
end

local function digitsBehindHead(value: string)
	for _, v3 in v2 do
		if string.sub(value, 1, #v3) ~= v3 then
			continue
		end

		local v4 = string.sub(value, #v3 + 1)

		if string.find(v4, "^%d+$") == nil then
			return nil
		end

		return v4
	end

	return nil
end

return table.freeze({
	Parse = function(value)
		if type(value) == "number" then
			if value > 0 and value < 1e999 and value % 1 == 0 then
				return value
			end

			return nil
		else
			local v3 = tonumber(value)

			if v3 == nil then
				local v4 = digitsBehindHead(value)

				if v4 == nil then
					v3 = nil
				else
					v3 = tonumber(v4)
				end
			end

			if v3 == nil then
				return nil
			end

			if v3 > 0 and v3 < 1e999 and v3 % 1 == 0 then
				return v3
			end

			return nil
		end
	end
})