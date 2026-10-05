require(script.Parent:WaitForChild("types"):WaitForChild("color-types"))
local utils = require(script.Parent:WaitForChild("utils"))
local last = utils.last
local clip_rgb = utils.clip_rgb
local input = require(script.Parent:WaitForChild("io"):WaitForChild("input"))
local Color = {}
local v = {
	__index = Color,
	__tostring = function(object)
		return object:toString()
	end
}

function Color.new(...)
	local self = setmetatable({}, v)
	local v2 = table.pack(...)

	if type(v2[1]) == "table" and getmetatable(v2[1]) == v then
		return v2[1]
	end

	local v3 = last(...)
	local flag

	if v3 == nil or v3 == "" then
		flag = true

		if not input.sorted then
			table.sort(input.autodetect, function(a, b)
				return a.p > b.p
			end)
			input.sorted = true
		end

		for _, v5 in input.autodetect do
			v3 = v5.test(...)

			if v3 ~= nil and v3 ~= "" then
				break
			end
		end
	else
		flag = false
	end

	if v3 == nil or not input.format[v3] then
		local v4 = {}

		for i = 1, v2.n do
			v4[i] = tostring(v2[i])
		end

		local v5 = "{ " .. table.concat(v4, ", ") .. " }"
		error((`unknown format: {v5}`))
	else
		local v4

		if flag then
			v4 = input.format[v3](...)
		else
			v4 = input.format[v3](unpack(v2, 1, v2.n - 1))
		end

		self._rgb = clip_rgb(v4)
	end

	if #self._rgb == 3 then
		table.insert(self._rgb, 1)
	end

	return self
end

function Color:toString()
	return self:hex()
end

return Color