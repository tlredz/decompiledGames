local v = {}
local count = 0

for i = 32, 127 do
	if not (i ~= 34 and i ~= 92) then
		continue
	end

	local v2 = string.char(i)
	v[v2] = count
	v[count] = v2
	count += 1
end

local v2 = {}

for i = 1, 34 do
	local v3 = ({ 34, 92, 127 })[i - 31] or i
	local v4 = string.char(v3)
	local v5 = string.char(v3 + 31)
	v2[v4] = v5
	v2[v5] = v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function escape(value)
	return (value:gsub("[%c\"\\]", function(p)
		return "\127" .. v2[p]
	end))
end

local function unescape(value)
	return (value:gsub("\127(.)", function(p)
		return v2[p]
	end))
end

local function copy(items)
	local result = {}

	for k, item in pairs(items) do
		result[k] = item
	end

	return result
end

local function tobase93(p)
	local v3 = ""

	repeat
		local v4 = p % 93
		v3 = v[v4] .. v3
		p = (p - v4) / 93
	until p == 0

	return v3
end

local function tobase10(value)
	local total = 0

	for i = 1, #value do
		total += 93 ^ (i - 1) * v[value:sub(-i, -i)]
	end

	return total
end

local Compress = {}

function Compress.compress(value)
	local v4 = {}

	for k, v5 in pairs(v) do
		v4[k] = v5
	end

	local v5 = ""
	local v6 = {}
	local count2 = #v4
	local v7 = 1
	local v8 = {}
	local count3 = 0

	local function listkey(p)
		local v9 = v4[p]
		local v10 = ""

		repeat
			local v11 = v9 % 93
			v10 = v[v11] .. v10
			v9 = (v9 - v11) / 93
		until v9 == 0

		local v11 = #v10

		if v7 < v11 then
			local v12 = v8
			local v13 = v7
			local v14 = #v10
			local v15 = count3
			v7 = v14
			count3 = 0
			v12[v13] = v15
		end

		v6[#v6 + 1] = (" "):rep(v7 - #v10) .. v10
		count3 += 1
	end

	local v9 = escape(value) -- equivalent call inferred; original call site unknown

	for i = 1, #v9 do
		local v10 = v9:sub(i, i)
		local v11 = v5 .. v10

		if v4[v11] then
			v5 = v11
		else
			local v12 = v4[v5]
			local v13 = ""

			repeat
				local v14 = v12 % 93
				v13 = v[v14] .. v13
				v12 = (v12 - v14) / 93
			until v12 == 0

			if v7 < #v13 then
				local v14 = #v13
				v8[v7] = count3
				v7 = v14
				count3 = 0
			end

			v6[#v6 + 1] = (" "):rep(v7 - #v13) .. v13
			count3 += 1
			count2 += 1
			v4[v11] = count2
			v4[count2] = v11
			v5 = v10
		end
	end

	local v10 = v4[v5]
	local v11 = ""

	repeat
		local v12 = v10 % 93
		v11 = v[v12] .. v11
		v10 = (v10 - v12) / 93
	until v10 == 0

	if v7 < #v11 then
		local v12 = #v11
		v8[v7] = count3
		v7 = v12
		count3 = 0
	end

	v6[#v6 + 1] = (" "):rep(v7 - #v11) .. v11
	count3 += 1
	v8[v7] = count3
	return table.concat(v8, ",") .. "|" .. table.concat(v6)
end

function Compress.decompress(value)
	local v4 = {}

	for k, v5 in pairs(v) do
		v4[k] = v5
	end

	local match, v5 = value:match("(.-)|(.*)")
	local v6 = {}
	local total = 1
	local v7 = {}

	for k in match:gmatch("%d+") do
		local v8 = #v6 + 1
		v6[v8] = v5:sub(total, total + k * v8 - 1)
		total += k * v8
	end

	local v8 = nil

	for i = 1, #v6 do
		for k in v6[i]:gmatch(("."):rep(i)) do
			local v9 = v4[tobase10(k)]

			if v8 then
				if v9 then
					v7[#v7 + 1] = v9
					v4[#v4 + 1] = v8 .. v9:sub(1, 1)
				else
					v9 = v8 .. v8:sub(1, 1)
					v7[#v7 + 1] = v9
					v4[#v4 + 1] = v9
				end
			else
				v7[1] = v9
			end

			v8 = v9
		end
	end

	return (table.concat(v7):gsub("\127(.)", function(p)
		return v2[p]
	end))
end

return Compress