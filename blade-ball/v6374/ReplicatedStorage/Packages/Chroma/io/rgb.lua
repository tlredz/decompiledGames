local Color = require(script.Parent.Parent:WaitForChild("Color"))
local chroma = require(script.Parent.Parent:WaitForChild("chroma"))
local input = require(script.Parent:WaitForChild("input"))
local utils = require(script.Parent.Parent:WaitForChild("utils"))
local unpack2 = utils.unpack
local round = math.round

function Color:rgb(flag: boolean?)
	local v = flag == nil or flag
	local _rgb = self._rgb

	if v == false then
		return { _rgb[1], _rgb[2], _rgb[3] }
	end

	return { round(_rgb[1]), round(_rgb[2]), (round(_rgb[3])) }
end

function Color:rgba(flag: boolean?)
	local v = flag == nil or flag
	local _rgb = self._rgb

	if v == false then
		return {
			_rgb[1],
			_rgb[2],
			_rgb[3],
			_rgb[4]
		}
	end

	return {
		round(_rgb[1]),
		round(_rgb[2]),
		round(_rgb[3]),
		_rgb[4]
	}
end

function chroma.rgb(...)
	local v = table.pack(...)
	v[v.n + 1] = "rgb"
	return Color.new(unpack(v, 1, v.n + 1))
end

function input.format.rgb(...)
	local v = unpack2(table.pack(...), "rgba")

	if v[4] == nil then
		v[4] = 1
	end

	return v
end

table.insert(input.autodetect, {
	p = 39,
	test = function(...)
		local v = unpack2(table.pack(...), "rgba")

		if type(v) == "table" and (#v == 3 or #v == 4 and type(v[4]) == "number" and v[4] >= 0 and v[4] <= 1) then
			return "rgb"
		end

		return nil
	end
})
return nil