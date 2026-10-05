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
	amp = "&",
	apos = "'",
	gt = ">",
	lt = "<",
	quot = "\""
}
local v3 = nil
local flag = false
local v4 = {}
local count = 0

local function getTextTags()
	if flag then
		return v3
	end

	flag = true
	local success, result = pcall(function()
		return require(game.ReplicatedStorage.DialogueController.TextTags)
	end)

	if success then
		v3 = result
	end

	return v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tagName(value: string)
	return value:match("^</?%s*([%w_]+)")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function normalizedTagName(value: string)
	local v5 = tagName(value) -- equivalent call inferred; original call site unknown

	if v5 then
		return (string.lower(v5))
	end

	return nil
end

local function isNativeRichTextTag(p: string)
	local v5 = normalizedTagName(p) -- equivalent call inferred; original call site unknown
	return v5 ~= nil and v[v5] == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isClosingTag(value: string)
	return value:sub(2, 2) == "/"
end

local function isSelfClosingTag(value: string)
	return value:sub(-2) == "/>"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function closeTextForTag(p: string)
	local v6 = normalizedTagName(p) -- equivalent call inferred; original call site unknown
	return (`</{v6 or ""}>`)
end

local function escapeRichTextLiteral(value: string)
	return (value:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function unescapeRichTextEntities(value: string)
	return (value:gsub("&(%a+);", function(p)
		return v2[p] or `&{p};`
	end))
end

local function resolveTextTag(p: string)
	if not flag then
		flag = true
		local success, result = pcall(function()
			return require(game.ReplicatedStorage.DialogueController.TextTags)
		end)

		if success then
			v3 = result
		end
	end

	local v5 = v3

	if v5 then
		return (v5.resolve(p))
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function appendOpenTags(tags, items)
	for _, item in items do
		table.insert(tags, item.tag)
	end
end

local function activeSuffix(list)
	local v5 = ""

	for i = #list, 1, -1 do
		v5 ..= list[i].closeText
	end

	return v5
end

local function removeOpenTag(list, p: string)
	for i = #list, 1, -1 do
		if list[i].name ~= p then
			continue
		end

		table.remove(list, i)
		break
	end
end

local RichText = {}

function RichText.escapeLiteral(value: string)
	return (value:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

function RichText.unescapeEntities(value: string)
	return (value:gsub("&(%a+);", function(p)
		return v2[p] or `&{p};`
	end))
end

function RichText.normalize(value: string)
	if not string.find(value, "<", 1, true) then
		return value
	end

	local v5 = v4[value]

	if v5 then
		return v5
	end

	local v6 = value:gsub("<[^<>]->", function(value2)
		if not flag then
			flag = true
			local success, result = pcall(function()
				return require(game.ReplicatedStorage.DialogueController.TextTags)
			end)

			if success then
				v3 = result
			end
		end

		local v7 = v3
		local resolved

		if v7 then
			resolved = v7.resolve(value2)
		end

		if resolved then
			if resolved.kind == "open" then
				return resolved.openText or ""
			end

			if resolved.kind == "close" then
				return resolved.closeText or ""
			end

			if resolved.kind == "element" then
				return "[icon]"
			end

			return ""
		else
			local v8 = normalizedTagName(value2) -- equivalent call inferred; original call site unknown
			local v9

			if v8 == nil then
				v9 = false
			else
				v9 = v[v8] == true
			end

			if v9 then
				return value2
			end

			return (value2:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
		end
	end)

	if count >= 1200 then
		table.clear(v4)
		count = 0
	end

	v4[value] = v6
	count += 1
	return v6
end

function RichText.strip(value: string)
	if not string.find(value, "<", 1, true) then
		return (value:gsub("&(%a+);", function(p)
			return v2[p] or `&{p};`
		end))
	end

	local v5 = 1
	local v6 = {}

	while v5 <= #value do
		local v7 = value:sub(v5, v5)

		if v7 == "<" then
			local v8 = value:find(">", v5, true)
			local v9 = v8 and value:sub(v5, v8)
			local resolved

			if v9 then
				if not flag then
					flag = true
					local success, result = pcall(function()
						return require(game.ReplicatedStorage.DialogueController.TextTags)
					end)

					if success then
						v3 = result
					end
				end

				local v10 = v3

				if v10 then
					resolved = v10.resolve(v9)
				end
			end

			if resolved then
				if resolved.kind == "element" then
					table.insert(v6, "[icon]")
				end

				v5 = v8 + 1
			else
				if v9 then
					local v10 = normalizedTagName(v9) -- equivalent call inferred; original call site unknown
					local v11

					if v10 == nil then
						v11 = false
					else
						v11 = v[v10] == true
					end

					if v11 then
						local v12 = normalizedTagName(v9) -- equivalent call inferred; original call site unknown

						if v12 == "br" then
							table.insert(v6, "\n")
						end

						v5 = v8 + 1
						continue
					end
				end

				if v9 then
					table.insert(v6, v9)
					v5 = v8 + 1
				else
					table.insert(v6, v7)
					v5 += 1
				end
			end
		else
			table.insert(v6, v7)
			v5 += 1
		end
	end

	return (table.concat(v6):gsub("&(%a+);", function(p)
		return v2[p] or `&{p};`
	end))
end

function RichText.splitLines(value: string)
	local result = {}
	local v5 = {}
	local v6 = {}

	local function pushLine()
		local joined = table.concat(v5)
		local v8 = v6
		local v9 = ""

		for i = #v8, 1, -1 do
			v9 ..= v8[i].closeText
		end

		table.insert(result, joined .. v9)
		table.clear(v5)
		appendOpenTags(v5, v6) -- equivalent call inferred; original call site unknown
	end

	local v7 = 1

	while v7 <= #value do
		local v8 = value:sub(v7, v7)

		if v8 == "\n" then
			local joined = table.concat(v5)
			local v9 = ""

			for i = #v6, 1, -1 do
				v9 ..= v6[i].closeText
			end

			table.insert(result, joined .. v9)
			table.clear(v5)
			appendOpenTags(v5, v6) -- equivalent call inferred; original call site unknown
		else
			if v8 == "<" then
				local v9 = value:find(">", v7, true)
				local tag = v9 and value:sub(v7, v9)

				if tag then
					local v11 = normalizedTagName(tag) -- equivalent call inferred; original call site unknown
					local v12

					if v11 == nil then
						v12 = false
					else
						v12 = v[v11] == true
					end

					if v12 then
						local name = normalizedTagName(tag) -- equivalent call inferred; original call site unknown

						if name == "br" then
							local joined = table.concat(v5)
							local v14 = ""

							for i = #v6, 1, -1 do
								v14 ..= v6[i].closeText
							end

							table.insert(result, joined .. v14)
							table.clear(v5)
							appendOpenTags(v5, v6) -- equivalent call inferred; original call site unknown
						elseif isClosingTag(tag) then
							removeOpenTag(v6, name)
							table.insert(v5, tag)
						elseif tag:sub(-2) == "/>" then
							table.insert(v5, tag)
						else
							local v14 = {
								name = name,
								tag = tag,
								closeText = closeTextForTag(tag)
							}
							table.insert(v6, v14)
							table.insert(v5, tag)
						end

						v7 = v9 + 1
						continue
					end
				end
			end

			table.insert(v5, v8)
		end

		v7 += 1
	end

	local joined = table.concat(v5)
	local v8 = ""

	for i = #v6, 1, -1 do
		v8 ..= v6[i].closeText
	end

	table.insert(result, joined .. v8)
	return result
end

return RichText