local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")
game:GetService("RunService")
local TextTags = require(script.Parent.TextTags)
local Translation = {}
local v = {
	b = true,
	br = true,
	font = true,
	i = true,
	s = true,
	sc = true,
	smallcaps = true,
	stroke = true,
	u = true,
	uc = true,
	uppercase = true
}
local v2 = {
	["&amp;"] = "&",
	["&gt;"] = ">",
	["&lt;"] = "<"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function tagName(value: string)
	return value:match("^</?%s*([%w_]+)")
end

local function isNativeRichTextTagName(value: string?)
	return value ~= nil and v[string.lower(value)] == true
end

local function isRecognizedTag(value: string)
	if TextTags.resolve(value) == nil then
		local v4 = tagName(value) -- equivalent call inferred; original call site unknown

		if v4 == nil then
			return false
		else
			return v[string.lower(v4)] == true
		end
	else
		return true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function escapeRichTextLiteral(value: string)
	return (value:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function nextRichTextEntity(value: string, p: number)
	for k, v3 in v2 do
		if value:sub(p, p + #k - 1) == k then
			return k, v3
		end
	end

	return nil, nil
end

local v3 = nil
task.spawn(function()
	local success, result = pcall(function()
		return LocalizationService:GetTranslatorForPlayerAsync(Players.LocalPlayer)
	end)

	if not success then
		return
	end

	v3 = result
end)

function Translation.stripTags(value: string)
	local v4 = 1
	local v5 = {}

	while v4 <= #value do
		local v6 = value:sub(v4, v4)

		if v6 == "<" then
			local v7 = value:find(">", v4, true)
			local v8 = v7 and value:sub(v4, v7)

			if v8 then
				local v9

				if TextTags.resolve(v8) == nil then
					local v10 = tagName(v8) -- equivalent call inferred; original call site unknown

					if v10 == nil then
						v9 = false
					else
						v9 = v[string.lower(v10)] == true
					end
				else
					v9 = true
				end

				if v9 then
					v4 = v7 + 1
					continue
				end
			end
		end

		table.insert(v5, v6)
		v4 += 1
	end

	return table.concat(v5)
end

Translation.onRetranslated = nil

local function makeContextLabel(text: string)
	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return nil
	end

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "TranslationContext"
	textLabel.BackgroundTransparency = 1
	textLabel.TextTransparency = 1
	textLabel.Size = UDim2.fromOffset(1, 1)
	textLabel.Text = text
	textLabel.Parent = playerGui:FindFirstChild("DialogueGui") or playerGui
	task.delay(30, function()
		textLabel:Destroy()
	end)
	return textLabel
end

function Translation.translate(value: string)
	local v4 = {}
	local text = value:gsub("<[^<>]->", function(p)
		table.insert(v4, p)
		return (`\{{#v4}}`)
	end)

	local function restoreTags(value2: string)
		return (value2:gsub("{(%d+)}", function(p)
			return v4[tonumber(p)] or ""
		end))
	end

	local contextLabel = makeContextLabel(text)
	local v6 = text
	local v7 = v3

	if v7 then
		local success, result = pcall(function()
			return v7:Translate(contextLabel or game, text)
		end)

		if success and result ~= "" then
			v6 = result
		end
	end

	if contextLabel then
		contextLabel:GetPropertyChangedSignal("LocalizedText"):Connect(function()
			local localizedText = contextLabel.LocalizedText

			if localizedText == "" or localizedText == text or localizedText == v6 then
				return
			end

			local onRetranslated = Translation.onRetranslated

			if onRetranslated then
				onRetranslated(value, (localizedText:gsub("{(%d+)}", function(p)
					return v4[tonumber(p)] or ""
				end)))
			end
		end)
	end

	return (v6:gsub("{(%d+)}", function(p)
		return v4[tonumber(p)] or ""
	end))
end

function Translation.toWords(value: string)
	local result = {}
	local v4 = {}
	local v5 = {}
	local v6 = {}
	local bubble = nil
	local v7 = {}
	local v8 = {}
	local joined = ""
	local animate2 = nil
	local v10 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isTextLayoutProp(p: string?)
		return p == "textXAlignment" or p == "textYAlignment"
	end

	local function appendChar(value3: string)
		local v11 = escapeRichTextLiteral(value3) -- equivalent call inferred; original call site unknown

		if #v7 == 0 then
			local tags = {}

			for _, v12 in v4 do
				table.insert(tags, v12.tag)
			end

			joined = table.concat(tags)
			local v12

			if next(v5) ~= nil then
				v12 = table.clone(v5)
			end

			animate2 = v12
			local v13

			if next(v6) ~= nil then
				v13 = table.clone(v6)
			end

			v10 = v13
		end

		table.insert(v7, value3)
		table.insert(v8, v11)
	end

	local function appendLiteral(value3: string)
		for k, v11 in utf8.graphemes(value3) do
			appendChar(value3:sub(k, v11))
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function appendTag(p: string)
		if #v7 > 0 then
			table.insert(v8, p)
		end
	end

	local function flush()
		if #v7 == 0 then
			return
		end

		local v11 = ""

		for i = #v4, 1, -1 do
			v11 ..= v4[i].closeText
		end

		table.insert(result, {
			raw = table.concat(v7),
			rich = joined .. table.concat(v8) .. v11,
			animate = animate2,
			textXAlignment = v10 and v10.textXAlignment,
			textYAlignment = v10 and v10.textYAlignment,
			bubble = bubble
		})
		table.clear(v7)
		table.clear(v8)
		joined = ""
		animate2 = nil
		v10 = nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function markLineBreak()
		local v11 = result[#result]

		if v11 then
			v11.lineBreakAfter = true
		end
	end

	local v11 = 1

	while v11 <= #value do
		local v12 = value:sub(v11, v11)

		if v12 == "<" then
			local v13 = value:find(">", v11, true)
			local tag = v13 and value:sub(v11, v13)
			local name = tag and tag:match("^</?%s*([%w_]+)")
			local resolved

			if tag then
				resolved = TextTags.resolve(tag)
			end

			if resolved then
				if resolved.kind == "metadataClose" then
					local prop = resolved.prop

					if isTextLayoutProp(prop) then
						v6[prop] = nil
					else
						v5[prop] = nil
					end
				elseif resolved.kind == "metadataPoint" then
					flush()
					local v16 = result[#result]

					if v16 then
						local prop = resolved.prop

						if isTextLayoutProp(prop) then
							if prop == "textXAlignment" then
								v16.textXAlignment = resolved.value
							else
								v16.textYAlignment = resolved.value
							end
						else
							local animate = v16.animate or {}

							if typeof(resolved.value) == "number" then
								animate[prop] = (animate[prop] or 0) + resolved.value
							else
								animate[prop] = resolved.value
							end

							v16.animate = animate
						end
					end
				elseif resolved.kind == "metadata" then
					local prop = resolved.prop

					if isTextLayoutProp(prop) then
						v6[prop] = resolved.value
					else
						v5[prop] = resolved.value
					end
				elseif resolved.kind == "open" then
					table.insert(v4, {
						name = resolved.name,
						tag = resolved.openText,
						closeText = resolved.closeText
					})
					appendTag(resolved.openText) -- equivalent call inferred; original call site unknown
				elseif resolved.kind == "close" then
					local closeText = resolved.closeText

					for i = #v4, 1, -1 do
						if v4[i].name ~= resolved.name then
							continue
						end

						closeText = v4[i].closeText
						table.remove(v4, i)
						break
					end

					if closeText and #v7 > 0 then
						table.insert(v8, closeText)
					end
				elseif resolved.kind == "element" then
					flush()
					local v16 = {
						raw = "",
						rich = "",
						sprite = resolved.element,
						animate = 0,
						textXAlignment = 0,
						textYAlignment = 0,
						bubble = 0
					}
					local animate

					if next(v5) ~= nil then
						animate = table.clone(v5)
					end

					v16.animate = animate
					v16.textXAlignment = v6.textXAlignment
					v16.textYAlignment = v6.textYAlignment
					v16.bubble = bubble
					table.insert(result, v16)
				elseif resolved.kind == "bubbleOpen" then
					flush()
					bubble = resolved.value
				elseif resolved.kind == "bubbleClose" then
					flush()
					bubble = nil
				end

				v11 = v13 + 1
			else
				if tag then
					local v16

					if name == nil then
						v16 = false
					else
						v16 = v[string.lower(name)] == true
					end

					if v16 then
						if tag:sub(2, 2) == "/" then
							for i = #v4, 1, -1 do
								if string.lower(v4[i].name) ~= string.lower(name) then
									continue
								end

								table.remove(v4, i)
								break
							end

							appendTag(tag) -- equivalent call inferred; original call site unknown
						elseif tag:sub(-2) == "/>" then
							flush()
							markLineBreak() -- equivalent call inferred; original call site unknown
						else
							table.insert(v4, {
								name = name,
								tag = tag,
								closeText = `</{name}>`
							})
							appendTag(tag) -- equivalent call inferred; original call site unknown
						end

						v11 = v13 + 1
						continue
					end
				end

				if tag then
					appendLiteral(tag)
					v11 = v13 + 1
				else
					appendChar(v12)
					v11 += 1
				end
			end
		else
			if v12:match("%s") then
				if bubble then
					appendChar(" ")
				else
					flush()
					local v13 = v12 == "\n" and result[#result]

					if v13 then
						v13.lineBreakAfter = true
					end
				end
			else
				appendChar(v12)
			end

			v11 += 1
		end
	end

	flush()
	return result
end

function Translation.toCharacters(value: string)
	local result = {}
	local v4 = {}

	local function emitRun(value2: string)
		if value2 == "" then
			return
		end

		local v5 = ""
		local v6 = ""

		for _, v7 in v4 do
			v5 ..= v7.tag
			v6 = `</{v7.name}>` .. v6
		end

		local v7 = 1

		while v7 <= #value2 do
			local v8, raw = nextRichTextEntity(value2, v7)

			if v8 and raw then
				table.insert(result, {
					raw = raw,
					rich = v5 .. v8 .. v6
				})
				v7 += #v8
			else
				local v10, v11 = utf8.graphemes(value2, v7)()

				if v10 and v11 then
					local raw2 = value2:sub(v10, v11)
					table.insert(result, {
						raw = raw2,
						rich = v5 .. raw2 .. v6
					})
					v7 = v11 + 1
				else
					break
				end
			end
		end
	end

	local v5 = 1
	local v6 = 1

	while v5 <= #value do
		if value:sub(v5, v5) == "<" then
			local v7 = value:find(">", v5, true)
			local tag = v7 and value:sub(v5, v7)
			local name = tag and tag:match("^</?%s*([%w_]+)")

			if tag then
				local v10

				if name == nil then
					v10 = false
				else
					v10 = v[string.lower(name)] == true
				end

				if v10 then
					emitRun(value:sub(v6, v5 - 1))

					if tag:sub(2, 2) == "/" then
						for i = #v4, 1, -1 do
							if v4[i].name ~= name then
								continue
							end

							table.remove(v4, i)
							break
						end
					elseif tag:sub(-2) ~= "/>" then
						table.insert(v4, {
							name = name,
							tag = tag
						})
					end

					v5 = v7 + 1
					v6 = v5
					continue
				end
			end
		end

		v5 += 1
	end

	emitRun(value:sub(v6))
	return result
end

return Translation