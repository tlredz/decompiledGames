local Colors = require(script.Colors)
local colors = {}
local TextTags = {}

for k, color in Colors do
	colors[k:lower()] = color
end

local function toColor3(value: string?)
	if not value or value == "" then
		return nil
	end

	local match, v, v2 = value:match("^(%d+)%s*,%s*(%d+)%s*,%s*(%d+)$")

	if match then
		return Color3.fromRGB(tonumber(match), tonumber(v), (tonumber(v2)))
	end

	if value:match("^#%x%x%x%x%x%x$") then
		return Color3.fromHex(value)
	end

	local v3 = colors[value:lower()]

	if v3 then
		return (Color3.fromHex(v3))
	end

	return nil
end

function TextTags.color(p: string)
	return toColor3(p)
end

local function colorOpen(value: string?)
	if not value or value == "" then
		warn("[DIALOGUE]", "<color> needs a value")
		return nil
	end

	local match, v, v2 = value:match("^(%d+)%s*,%s*(%d+)%s*,%s*(%d+)$")

	if match then
		return (`<font color="rgb({match},{v},{v2})">`)
	end

	if value:match("^#%x%x%x%x%x%x$") then
		return (`<font color="{value}">`)
	end

	local v3 = colors[value:lower()]

	if v3 then
		return (`<font color="{v3}">`)
	end

	warn("[DIALOGUE]", (`unknown color "{value}"`))
	return nil
end

local v = nil
local v2 = false

local function getSprite(p: string)
	if not v2 then
		v2 = true
		local spritesheets = game.ReplicatedStorage:FindFirstChild("Spritesheets")

		if spritesheets and spritesheets:IsA("ModuleScript") then
			local success, result = pcall(require, spritesheets)

			if not success then
				result = nil
			end

			v = result
		end
	end

	if v then
		return v.MAP[p]
	end

	return nil
end

function TextTags.sprite(p: string)
	return (getSprite(p))
end

local v3 = {}

function TextTags.register(p)
	for _, name in p.names do
		v3[name:lower()] = p
	end
end

TextTags.register({
	names = { "color" },
	open = colorOpen,
	close = "</font>"
})
TextTags.register({
	names = { "size" },
	open = function(p: string?)
		local v4 = tonumber(p)

		if v4 then
			return (`<font size="{math.clamp(math.floor(v4), 1, 200)}">`)
		end

		warn("[DIALOGUE]", (`<size> needs a number, got "{p}"`))
		return nil
	end,
	close = "</font>"
})
TextTags.register({
	names = { "bubble" },
	bubble = true
})
TextTags.register({
	names = { "sprite" },
	element = function(p: string?)
		if not p or p == "" then
			warn("[DIALOGUE]", "<sprite/> needs a name")
			return nil
		end

		local sprite = getSprite(p)

		if not sprite then
			warn("[DIALOGUE]", (`unknown sprite "{p}"`))
		end

		return sprite
	end
})
TextTags.register({
	names = { "textXAlignment" },
	metadata = "textXAlignment"
})
TextTags.register({
	names = { "textYAlignment" },
	metadata = "textYAlignment"
})

for k, color in Colors do
	local v4 = color
	TextTags.register({
		names = { k },
		open = function()
			return (`<font color="{v4}">`)
		end,
		close = "</font>"
	})
end

local Legacy = require(script.Legacy)

for _, v4 in Legacy, nil, nil do
	TextTags.register(v4)
end

local function parse(value: string)
	local match = value:match("^</%s*([%w_]+)%s*>$")

	if match then
		return match, nil, true, false
	end

	local v4 = value:sub(-2) == "/>"
	local v5 = value:sub(2, v4 and -3 or -2)
	local match2, v6 = v5:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")

	if not (match2 and v6) then
		match2, v6 = v5:match("^%s*([%w_]+)%s+[%w_]+%s*=%s*(.-)%s*$")
	end

	if match2 and v6 then
		return match2, v6:match("^\"(.*)\"$") or v6:match("^'(.*)'$") or v6, false, v4
	end

	return v5:match("^%s*([%w_]+)%s*$"), nil, false, v4
end

function TextTags.resolve(p: string)
	local v4, v5, v6, v7 = parse(p)

	if not v4 then
		return nil
	end

	local lower = v4:lower()
	local v8 = v3[lower]

	if not v8 then
		return nil
	end

	local v9 = v6 or v7 and (v5 == nil or v5 == "" or v5 == "/")

	if v8.metadata then
		if v9 then
			return {
				kind = "metadataClose",
				prop = v8.metadata
			}
		end

		return {
			kind = v8.point and "metadataPoint" or "metadata",
			prop = v8.metadata,
			value = tonumber(v5) or v5
		}
	elseif v8.bubble then
		if v9 then
			return {
				kind = "bubbleClose"
			}
		end

		local color = toColor3(v5)

		if color then
			return {
				kind = "bubbleOpen",
				value = {
					color = color
				}
			}
		end

		warn("[DIALOGUE]", (`<bubble> needs a color, got "{v5}"`))
		return {
			kind = "drop"
		}
	elseif v8.element then
		local element

		if not v9 then
			element = v8.element(v5)
		end

		if element == nil then
			return {
				kind = "drop"
			}
		end

		return {
			kind = "element",
			element = element
		}
	else
		if not v8.open then
			return nil
		end

		if v9 then
			return {
				kind = "close",
				name = lower,
				closeText = v8.close
			}
		end

		local openText = v8.open(v5)

		if openText then
			return {
				kind = "open",
				name = lower,
				openText = openText,
				closeText = v8.close
			}
		end

		return {
			kind = "drop"
		}
	end
end

return TextTags