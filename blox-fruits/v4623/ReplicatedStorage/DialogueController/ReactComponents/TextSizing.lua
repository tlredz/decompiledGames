local GuiService = game:GetService("GuiService")
local TextService = game:GetService("TextService")
local TextSizing = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function readPreferenceKey()
	local success, result = pcall(function()
		return GuiService.PreferredTextSize
	end)

	if success then
		return (tostring(result))
	end

	return "Unknown"
end

local textBoundsAsyncs = {}
local v = {}
local v2 = {}
local values = {}
local success, result = pcall(function()
	return GuiService.PreferredTextSize
end)
local v3 = not success and "Unknown" or tostring(result)
local v4 = {}
local flag = false
local v5 = false
local v6 = nil

local function fontKey(data)
	local v7 = values[data]

	if v7 then
		return v7
	end

	local formatted = `{data.Family}:{data.Weight.Name}:{data.Style.Name}`
	values[data] = formatted
	return formatted
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearMeasurementCaches()
	table.clear(textBoundsAsyncs)
	table.clear(v)
	table.clear(v2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshPreferenceKey()
	local preferenceKey = readPreferenceKey() -- equivalent call inferred; original call site unknown

	if v3 == preferenceKey then
		return false
	end

	v3 = preferenceKey
	clearMeasurementCaches() -- equivalent call inferred; original call site unknown
	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ensurePreferenceSignal()
	if flag then
		return
	end

	flag = true
	local success2, result2 = pcall(function()
		return GuiService:GetPropertyChangedSignal("PreferredTextSize"):Connect(function()
			-- equivalent call inferred; original call site unknown
			if not refreshPreferenceKey() then
				return
			end

			for k in v4 do
				k()
			end
		end)
	end)
	v5 = success2 and result2 ~= nil

	if not v5 then
		result2 = nil
	end

	v6 = result2
end

function TextSizing.preferenceKey()
	ensurePreferenceSignal() -- equivalent call inferred; original call site unknown

	if v5 then
		return v3
	end

	local preferenceKey = readPreferenceKey() -- equivalent call inferred; original call site unknown

	if v3 ~= preferenceKey then
		v3 = preferenceKey
		clearMeasurementCaches() -- equivalent call inferred; original call site unknown
	end

	return v3
end

function TextSizing.onPreferenceChanged(callback)
	ensurePreferenceSignal() -- equivalent call inferred; original call site unknown

	if not v5 or v6 == nil then
		return nil
	end

	v4[callback] = true
	local flag2 = false
	return {
		Disconnect = function()
			if flag2 then
				return
			end

			flag2 = true
			v4[callback] = nil
		end
	}
end

local fn

function TextSizing.bounds(text: string, font, p: number, flag2: boolean?, width: number?)
	local v7 = math.max(1, (math.floor(p + 0.5)))
	local preferenceKey = TextSizing.preferenceKey()
	local v8 = values[font]

	if not v8 then
		v8 = `{font.Family}:{font.Weight.Name}:{font.Style.Name}`
		values[font] = v8
	end

	local size = fn(v7, font, v8, preferenceKey)
	local formatted = `{preferenceKey}:{v8}:{v7}:{size}:{tostring(flag2 == true)}:{width or 0}:{text}`
	local v10 = textBoundsAsyncs[formatted]

	if v10 ~= nil then
		return v10
	end

	local getTextBoundsParams = Instance.new("GetTextBoundsParams")
	getTextBoundsParams.Text = text
	getTextBoundsParams.Font = font
	getTextBoundsParams.Size = size
	getTextBoundsParams.RichText = flag2 == true

	if width then
		getTextBoundsParams.Width = width
	end

	local success2, textBoundsAsync = pcall(TextService.GetTextBoundsAsync, TextService, getTextBoundsParams)

	if not success2 then
		return Vector2.zero
	end

	textBoundsAsyncs[formatted] = textBoundsAsync
	return textBoundsAsync
end

function TextSizing.fitTextSize(p: string, p2, point: Vector2, p3: number, value: number?, flag2: boolean?)
	local v7 = math.max(1, value or 1)
	local v8 = math.max(v7, (math.floor(p3 + 0.5)))
	local v9 = v7

	while v7 <= v8 do
		local v10 = math.floor((v7 + v8) / 2)
		local bounds = TextSizing.bounds(p, p2, v10, flag2)

		if bounds.X <= point.X + 0.5 and bounds.Y <= point.Y + 0.5 then
			v7 = v10 + 1
			v9 = v10
		else
			v8 = v10 - 1
		end
	end

	return v9
end

local function textSizeOffset(p: number, p2, p3: string, p4: string)
	local v7 = math.max(1, (math.floor(p + 0.5)))
	local formatted = `{p4}:{p3}:{v7}`
	local v8 = v[formatted]

	if v8 ~= nil then
		return v8
	end

	local getTextSizeOffsetAsync = TextService.GetTextSizeOffsetAsync

	if typeof(getTextSizeOffsetAsync) ~= "function" then
		return 0
	end

	local success2, result2 = pcall(getTextSizeOffsetAsync, TextService, v7, p2)

	if not success2 or typeof(result2) ~= "number" then
		return 0
	end

	v[formatted] = result2
	return result2
end

fn = function(p: number, p2, p3: string, preferenceKey: string)
	local v7 = math.max(1, (math.floor(p + 0.5)))
	local formatted = `{preferenceKey}:{p3}:{v7}`
	local v8 = v2[formatted]

	if v8 ~= nil then
		return v8
	end

	local v9 = math.max(1, (math.floor(v7 + math.max(textSizeOffset(v7, p2, p3, preferenceKey), 0) + 0.5)))
	v2[formatted] = v9
	return v9
end

function TextSizing.renderTextSizeForMeasuredSize(p: number, data)
	local preferenceKey = TextSizing.preferenceKey()
	local v7 = values[data]

	if not v7 then
		v7 = `{data.Family}:{data.Weight.Name}:{data.Style.Name}`
		values[data] = v7
	end

	return fn(p, data, v7, preferenceKey)
end

return TextSizing