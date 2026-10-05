local luauregexp = require(script.Parent.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("luau-regexp"))
local string2 = require(script.Parent.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("@jsdotlua"):WaitForChild("string"))
local hsl2rgb = require(script.Parent.Parent:WaitForChild("hsl"):WaitForChild("hsl2rgb"))
local input = require(script.Parent.Parent:WaitForChild("input"))
require(script.Parent.Parent:WaitForChild("named"))
local v = luauregexp("^rgb\\(\\s*(-?\\d+),\\s*(-?\\d+)\\s*,\\s*(-?\\d+)\\s*\\)$")
local v2 = luauregexp("^rgba\\(\\s*(-?\\d+),\\s*(-?\\d+)\\s*,\\s*(-?\\d+)\\s*,\\s*([01]|[01]?\\.\\d+)\\)$")
local v3 = luauregexp("^rgb\\(\\s*(-?\\d+(?:\\.\\d+)?)%,\\s*(-?\\d+(?:\\.\\d+)?)%\\s*,\\s*(-?\\d+(?:\\.\\d+)?)%\\s*\\)$")
local v4 = luauregexp("^rgba\\(\\s*(-?\\d+(?:\\.\\d+)?)%,\\s*(-?\\d+(?:\\.\\d+)?)%\\s*,\\s*(-?\\d+(?:\\.\\d+)?)%\\s*,\\s*([01]|[01]?\\.\\d+)\\)$")
local v5 = luauregexp("^hsl\\(\\s*(-?\\d+(?:\\.\\d+)?),\\s*(-?\\d+(?:\\.\\d+)?)%\\s*,\\s*(-?\\d+(?:\\.\\d+)?)%\\s*\\)$")
local v6 = luauregexp("^hsla\\(\\s*(-?\\d+(?:\\.\\d+)?),\\s*(-?\\d+(?:\\.\\d+)?)%\\s*,\\s*(-?\\d+(?:\\.\\d+)?)%\\s*,\\s*([01]|[01]?\\.\\d+)\\)$")
local round = math.round

local function css2rgbTest(p: string)
	return v:test(p) or v2:test(p) or v3:test(p) or v4:test(p) or v5:test(p) or v6:test(p)
end

return {
	css2rgb = function(value: string)
		local trimmed = string2.trim(string.lower(value))

		if input.format.named then
			local success, result = pcall(input.format.named, trimmed)

			if success then
				return result
			end
		end

		local v7 = v:exec(trimmed)

		if v7 ~= nil then
			return {
				tonumber(v7[2]),
				tonumber(v7[3]),
				tonumber(v7[4]),
				1
			}
		end

		local v8 = v2:exec(trimmed)

		if v8 ~= nil then
			return {
				tonumber(v8[2]),
				tonumber(v8[3]),
				tonumber(v8[4]),
				(tonumber(v8[5]))
			}
		end

		local v9 = v3:exec(trimmed)

		if v9 == nil then
			local v10 = v4:exec(trimmed)

			if v10 == nil then
				local v11 = v5:exec(trimmed)

				if v11 == nil then
					local v12 = v6:exec(trimmed)

					if v12 == nil then
						return nil
					end

					local v14 = hsl2rgb({ tonumber(v12[2]), tonumber(v12[3]) * 0.01, tonumber(v12[4]) * 0.01 })
					v14[4] = tonumber(v12[5])
					return v14
				else
					local v13 = hsl2rgb({ tonumber(v11[2]), tonumber(v11[3]) * 0.01, tonumber(v11[4]) * 0.01 })
					v13[4] = 1
					return v13
				end
			else
				local v11 = {
					round(tonumber(v10[2]) * 2.55),
					round(tonumber(v10[3]) * 2.55),
					round(tonumber(v10[4]) * 2.55),
					(round(tonumber(v10[5]) * 2.55))
				}
				v11[4] = tonumber(v10[5])
				return v11
			end
		else
			return {
				round(tonumber(v9[2]) * 2.55),
				round(tonumber(v9[3]) * 2.55),
				round(tonumber(v9[4]) * 2.55),
				1
			}
		end
	end,
	test = css2rgbTest
}