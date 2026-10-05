local TextService = game:GetService("TextService")
local RichText = require(script.Parent.RichText)
local TextMetrics = {}
local v = {}
local count = 0
local v2 = {}
local count2 = 0

local function plainText(p: string)
	local v3 = v2[p]

	if v3 then
		return v3
	end

	local strip = RichText.strip(p)

	if count2 >= 1500 then
		table.clear(v2)
		count2 = 0
	end

	v2[p] = strip
	count2 += 1
	return strip
end

-- equivalent calls inferred from this helper; original call sites unknown
local function widthKey(p: number?)
	if p == nil or p == 1e999 then
		return "inf"
	end

	return (tostring((math.floor(p + 0.5))))
end

local function fontKey(p)
	return p.Name
end

function TextMetrics.stripRichText(p: string)
	local v3 = v2[p]

	if v3 then
		return v3
	end

	local strip = RichText.strip(p)

	if count2 >= 1500 then
		table.clear(v2)
		count2 = 0
	end

	v2[p] = strip
	count2 += 1
	return strip
end

function TextMetrics.measurePlain(p: string, p2: number, p3, value: number?)
	local formatted = `{p3.Name}|{p2}|{widthKey(value)}|{p}`
	local v3 = v[formatted]

	if v3 then
		return v3
	end

	local success, result = pcall(function()
		return TextService:GetTextSize(p, p2, p3, Vector2.new(value or 1e999, 1e999))
	end)

	if not success then
		result = Vector2.new(0, p2 + 2)
	end

	if count >= 1500 then
		table.clear(v)
		count = 0
	end

	v[formatted] = result
	count += 1
	return result
end

function TextMetrics.measureRich(p: string, p2: number, p3, p4: number?)
	local measurePlain = TextMetrics.measurePlain
	local v3 = v2[p]

	if v3 then
		return measurePlain(v3, p2, p3, p4)
	end

	v3 = RichText.strip(p)

	if count2 >= 1500 then
		table.clear(v2)
		count2 = 0
	end

	v2[p] = v3
	count2 += 1
	return measurePlain(v3, p2, p3, p4)
end

return TextMetrics