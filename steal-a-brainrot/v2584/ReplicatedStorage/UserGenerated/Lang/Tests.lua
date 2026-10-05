local Stringify = require(game.ReplicatedStorage.UserGenerated.Strings.Stringify)
local DeepEquals = require(game.ReplicatedStorage.UserGenerated.Collections.DeepEquals)

local function Equals(p, p2)
	if rawequal(p, p2) then
		return true
	end

	return (type(p) ~= "table" or type(p2) ~= "table") and p ~= p and p2 ~= p2
end

local function StripErrorSource(p)
	local v = tostring(p)
	local v2, v3 = string.match(v, "^(.*:%d+): (.+)$")

	if v2 then
		return v3 or v
	end

	return v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ToString(p)
	return Stringify.Pretty(p, {
		Pretty = false,
		IndentChar = "",
		IndentSize = 0
	})
end

return table.freeze({
	IsEqual = Equals,
	ErrorUnsafe = function(p, callback, ...)
		local v = nil
		local v2 = table.pack(xpcall(callback, function(p2)
			v = p2
		end, ...))

		if v2[1] then
			error("ExpectedError", 2)
		end

		if v ~= p then
			error(`ExpectedError Mismatch: {string.format("%q", (tostring(v)))}`, 2)
		end

		return table.unpack(v2, 2)
	end,
	Error = function(p, callback, ...)
		local v = nil
		local v2 = table.pack(xpcall(callback, function(p2)
			v = p2
		end, ...))

		if v2[1] then
			error(`ExpectedError({Stringify.Pretty(p, {
				Pretty = false,
				IndentChar = "",
				IndentSize = 0
			})})`, 2)
		end

		if type(v) == "string" then
			local v3 = tostring(v)
			local v4, v5 = string.match(v3, "^(.*:%d+): (.+)$")

			if v4 then
				v3 = v5 or v3
			end

			v = v3
		end

		if p == v then
			return table.unpack(v2, 2)
		end

		local toString = ToString(p) -- equivalent call inferred; original call site unknown
		local v4 = v
		error(`ExpectedError({toString}): {Stringify.Pretty(v4, {
			Pretty = false,
			IndentChar = "",
			IndentSize = 0
		})}`, 2)
		return table.unpack(v2, 2)
	end,
	Equal = function(p, p2)
		if not rawequal(p, p2) and (type(p) == "table" and type(p2) == "table" or p == p or p2 == p2) then
			error(`Equal({Stringify.Pretty(p, {
				Pretty = false,
				IndentChar = "",
				IndentSize = 0
			})}, {Stringify.Pretty(p2, {
				Pretty = false,
				IndentChar = "",
				IndentSize = 0
			})})`, 2)
		end
	end,
	DeepEqual = function(p, p2)
		if not DeepEquals(p, p2) then
			error(`DeepEqual({Stringify.Pretty(p, {
				Pretty = false,
				IndentChar = "",
				IndentSize = 0
			})}, {Stringify.Pretty(p2, {
				Pretty = false,
				IndentChar = "",
				IndentSize = 0
			})})`, 2)
		end
	end,
	FuzzyEqual = function(p: number, p2: number, value: number?)
		if (value or 0.001) < math.abs(p - p2) then
			error(`FuzzyEqual({tostring(p)}, {tostring(p2)}): {math.abs(p - p2)}`, 2)
		end
	end,
	ColorEqual = function(color: Color3, color2: Color3, value: number?)
		local v = Vector3.new(color.R, color.G, color.B) * 255

		if (value or 0.001) < (Vector3.new(color2.R, color2.G, color2.B) * 255 - v).Magnitude then
			error(`ColorEqual({Stringify.Pretty(color, {
				Pretty = false,
				IndentChar = "",
				IndentSize = 0
			})}, {Stringify.Pretty(color2, {
				Pretty = false,
				IndentChar = "",
				IndentSize = 0
			})})`, 2)
		end
	end
})