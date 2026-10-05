require(script.Parent.Parent:WaitForChild("io"):WaitForChild("rgb"))
require(script.Parent.Parent:WaitForChild("types"):WaitForChild("blend-types"))
local chroma = require(script.Parent.Parent:WaitForChild("chroma"))

local function blendFn(p, p2, p3, p4)
	if not p[p4] then
		error((`unknown blend mode {p4}`))
	end

	return p[p4](p2, p3)
end

local object = setmetatable({}, {
	__call = blendFn
})

local function blend_f(callback)
	return function(p, p2)
		local rgb = chroma(p2):rgb()
		local rgb2 = chroma(p):rgb()
		return chroma.rgb(callback(rgb, rgb2))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function each(callback)
	return function(list, list2)
		return { callback(list[1], list2[1]), callback(list[2], list2[2]), (callback(list[3], list2[3])) }
	end
end

local function normal(p: number)
	return p
end

local function multiply(p: number, p2: number)
	return p * p2 / 255
end

local function darken(p: number, p2: number)
	if p2 < p then
		return p2
	end

	return p
end

local function lighten(p: number, p2: number)
	if p2 < p then
		return p
	end

	return p2
end

local function screen(p: number, p2: number)
	return (1 - (1 - p / 255) * (1 - p2 / 255)) * 255
end

local function overlay(p: number, p2: number)
	if p2 < 128 then
		return p * 2 * p2 / 255
	end

	return (1 - (1 - p / 255) * 2 * (1 - p2 / 255)) * 255
end

local function burn(p: number, p2: number)
	return (1 - (1 - p2 / 255) / (p / 255)) * 255
end

local function dodge(p: number, p2: number)
	if p == 255 then
		return 255
	end

	local v = p2 / 255 * 255 / (1 - p / 255)

	if v > 255 then
		return 255
	end

	return v
end

local v = each(normal) -- equivalent call inferred; original call site unknown

function object.normal(p, p2)
	local rgb = chroma(p2):rgb()
	local rgb2 = chroma(p):rgb()
	return chroma.rgb(v(rgb, rgb2))
end

local v2 = each(multiply) -- equivalent call inferred; original call site unknown

function object.multiply(p, p2)
	local rgb = chroma(p2):rgb()
	local rgb2 = chroma(p):rgb()
	return chroma.rgb(v2(rgb, rgb2))
end

local v3 = each(screen) -- equivalent call inferred; original call site unknown

function object.screen(p, p2)
	local rgb = chroma(p2):rgb()
	local rgb2 = chroma(p):rgb()
	return chroma.rgb(v3(rgb, rgb2))
end

local v4 = each(overlay) -- equivalent call inferred; original call site unknown

function object.overlay(p, p2)
	local rgb = chroma(p2):rgb()
	local rgb2 = chroma(p):rgb()
	return chroma.rgb(v4(rgb, rgb2))
end

local v5 = each(darken) -- equivalent call inferred; original call site unknown

function object.darken(p, p2)
	local rgb = chroma(p2):rgb()
	local rgb2 = chroma(p):rgb()
	return chroma.rgb(v5(rgb, rgb2))
end

local v6 = each(lighten) -- equivalent call inferred; original call site unknown

function object.lighten(p, p2)
	local rgb = chroma(p2):rgb()
	local rgb2 = chroma(p):rgb()
	return chroma.rgb(v6(rgb, rgb2))
end

local v7 = each(dodge) -- equivalent call inferred; original call site unknown

function object.dodge(p, p2)
	local rgb = chroma(p2):rgb()
	local rgb2 = chroma(p):rgb()
	return chroma.rgb(v7(rgb, rgb2))
end

local v8 = each(burn) -- equivalent call inferred; original call site unknown

function object.burn(p, p2)
	local rgb = chroma(p2):rgb()
	local rgb2 = chroma(p):rgb()
	return chroma.rgb(v8(rgb, rgb2))
end

return object