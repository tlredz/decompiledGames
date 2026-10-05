local TextService = game:GetService("TextService")
local v = {
	b = "bold",
	i = "italic",
	u = "underline",
	s = "strikethrough",
	uppercase = "uppercase",
	uc = "uppercase",
	smallcaps = "smallcaps",
	sc = "smallcaps"
}
local v2 = {
	b = true,
	i = true,
	u = true,
	s = true,
	font = true,
	stroke = true,
	mark = true,
	uppercase = true,
	uc = true,
	smallcaps = true,
	sc = true
}
local v3 = {
	br = true
}
local v4 = {
	["&lt;"] = "<",
	["&gt;"] = ">",
	["&amp;"] = "&",
	["&quot;"] = "\"",
	["&apos;"] = "'"
}
local v5 = {
	bold = { "<b>", "</b>" },
	italic = { "<i>", "</i>" },
	underline = { "<u>", "</u>" },
	strikethrough = { "<s>", "</s>" },
	uppercase = { "<uc>", "</uc>" },
	smallcaps = { "<sc>", "</sc>" }
}
local v6 = {
	"bold",
	"italic",
	"underline",
	"strikethrough",
	"uppercase",
	"smallcaps"
}
local v7 = {
	color = true,
	c = true,
	size = true,
	face = true,
	weight = true
}
local v8 = {
	"color",
	"face",
	"size",
	"weight"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function unescape(value: string)
	return (value:gsub("&%w+;", function(p)
		return v4[p] or p
	end))
end

local function parseAttributes(value: string)
	local result = {}
	local count = #value
	local match = value:match("^%s*=%s*\"([^\"]*)\"")
	local v9

	if match then
		v9 = #value:match("^%s*=%s*\"[^\"]*\"") + 1
	else
		v9 = 1
		match = nil
	end

	while v9 <= count do
		local match2 = value:match("^%s+", v9)

		if match2 then
			v9 += #match2
		end

		if count < v9 then
			break
		end

		local v10, v11
		v10, v11, v9 = value:match("^(%w+)%s*=%s*\"([^\"]*)\"()", v9)

		if not v10 then
			break
		end

		result[v10] = v11
	end

	return match, result
end

local function mergeStyleStack(items)
	local result = {}
	local flag = false

	for _, item in items do
		for k, attr in item.attrs do
			flag = true

			if type(attr) == "table" then
				local v9 = result[k]

				if type(v9) ~= "table" then
					v9 = {}
					result[k] = v9
				end

				for k2, v10 in attr do
					v9[k2] = v10
				end
			else
				result[k] = attr
			end
		end
	end

	if flag then
		return result
	end

	return nil
end

local function parseColor(value: string)
	local match, v9, v10 = value:match("^rgb%s*%((%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)$")

	if match then
		return Color3.fromRGB(tonumber(match), tonumber(v9), (tonumber(v10)))
	end

	if value:sub(1, 1) == "#" then
		return Color3.fromHex(value)
	end

	return nil
end

local v9 = {
	color = true,
	c = true
}

local function attrsForTag(lower: string, p)
	local result = {}
	local v10 = v[lower]

	if v10 then
		result[v10] = true
	end

	if lower == "font" then
		local family = p.family
		local v11 = p.b ~= nil or p.bold ~= nil
		local v12 = p.i ~= nil or p.italic ~= nil

		if family then
			local bold

			if v11 then
				bold = Enum.FontWeight.Bold
			else
				bold = Enum.FontWeight.Regular
			end

			local v13

			if v12 then
				v13 = Enum.FontStyle.Italic
			else
				v13 = Enum.FontStyle.Normal
			end

			result.fontFace = Font.new(family, bold, v13)
		end

		local fontRT = {}
		local flag = false

		for k, v14 in p do
			if not (k ~= "family" and k ~= "b" and k ~= "bold" and k ~= "i") then
				continue
			end

			if k == "italic" then
				continue
			end

			local v15 = k == "c" and "color" or k

			if v7[k] then
				fontRT[v15] = v14
				flag = true

				if v15 ~= "color" then
					result[v15] = v14
				end
			else
				result[k] = v14
			end
		end

		if flag then
			result._fontRT = fontRT
			return result
		end
	elseif lower == "stroke" then
		local stroke = {}

		for k, v12 in p do
			if v9[k] then
				stroke[k] = parseColor(v12) or v12
			else
				stroke[k] = v12
			end
		end

		result.stroke = stroke
		return result
	elseif lower == "mark" then
		local mark = {}

		for k, v12 in p do
			if v9[k] then
				mark[k] = parseColor(v12) or v12
			else
				mark[k] = v12
			end
		end

		result.mark = mark
	end

	return result
end

local function emitText(list, value: string, p)
	local v10 = mergeStyleStack(p)
	local rtPrefix = ""
	local rtSuffix = ""
	local v13

	if v10 then
		v13 = {}
		local v14 = false

		for _, v15 in v6 do
			if not v10[v15] then
				continue
			end

			local v16 = v5[v15]
			rtPrefix ..= v16[1]
			rtSuffix = v16[2] .. rtSuffix
		end

		local _fontRT = v10._fontRT

		if _fontRT then
			local v15 = {}

			for _, v16 in v8 do
				if _fontRT[v16] then
					table.insert(v15, (`{v16}="{_fontRT[v16]}"`))
				end
			end

			if #v15 > 0 then
				rtPrefix ..= "<font " .. table.concat(v15, " ") .. ">"
				rtSuffix = "</font>" .. rtSuffix
			end
		end

		for k, v15 in v10 do
			if v5[k] or k == "_fontRT" then
				continue
			end

			v13[k] = v15
			v14 = true
		end

		if not v14 then
			v13 = nil
		end
	else
		v13 = v10
	end

	if #rtPrefix > 0 then
		v13 = v13 or {}
		v13._rtPrefix = rtPrefix
		v13._rtSuffix = rtSuffix
	end

	local v14 = 1

	while v14 <= #value do
		local v15 = string.find(value, "\n", v14, true)

		if v15 then
			local v16 = string.sub(value, v14, v15 - 1)

			if #v16 > 0 then
				table.insert(list, {
					t = "text",
					v = v16,
					a = v13
				})
			end

			table.insert(list, {
				t = "newline"
			})
			v14 = v15 + 1
		else
			local v16 = string.sub(value, v14)

			if #v16 > 0 then
				table.insert(list, {
					t = "text",
					v = v16,
					a = v13
				})
				break
			else
				break
			end
		end
	end
end

local TextParser = {
	customTags = { "image" },
	getDisplayText = function(p)
		local v10 = p.v
		local _rtPrefix = p.a and p.a._rtPrefix

		if _rtPrefix then
			return _rtPrefix .. v10 .. p.a._rtSuffix
		end

		return v10
	end
}

function TextParser.parse(value: string)
	local count = #value
	local v10 = {}
	local v11 = 1
	local result = {}
	local v12 = {}

	for _, customTag in TextParser.customTags do
		v10[customTag] = true
	end

	while v11 <= count do
		if string.sub(value, v11, v11) == "<" then
			if string.sub(value, v11, v11 + 3) == "<!--" then
				local v13 = string.find(value, "-->", v11 + 4, true)

				if v13 then
					v11 = v13 + 3
				else
					v11 = count + 1
				end

				continue
			elseif string.sub(value, v11, v11 + 1) == "</" then
				local v13 = string.find(value, ">", v11 + 2, true)

				if v13 then
					local match = string.sub(value, v11 + 2, v13 - 1):match("^%s*(%w+)%s*$")

					if match then
						local lower = match:lower()

						for i = #v12, 1, -1 do
							if v12[i].tag ~= lower then
								continue
							end

							table.remove(v12, i)
							break
						end
					end

					v11 = v13 + 1
					continue
				else
					v11 += 1
					continue
				end
			else
				local v13 = string.find(value, ">", v11 + 1, true)

				if v13 then
					local v14 = string.sub(value, v11 + 1, v13 - 1)

					if v14:sub(-1) == "/" then
						v14 = v14:sub(1, -2)
					end

					local match = v14:match("^%s*(%w+)")

					if match then
						local lower = match:lower()
						local v15 = v14:sub(#lower + 1)

						if v3[lower] then
							table.insert(result, {
								t = "newline"
							})
							v11 = v13 + 1
							continue
						elseif v10[lower] then
							local _, v16 = parseAttributes(v15)
							local v17 = {
								t = lower
							}

							if v16.id then
								v17.v = v16.id
								v16.id = nil
							end

							if next(v16) then
								v17.a = v16
							end

							table.insert(result, v17)
							v11 = v13 + 1
							continue
						elseif v2[lower] then
							local _, v16 = parseAttributes(v15)
							table.insert(v12, {
								tag = lower,
								attrs = attrsForTag(lower, v16)
							})
							v11 = v13 + 1
							continue
						end
					end

					local v15 = string.sub(value, v11, v13)
					local v16 = string.find(value, "<", v13 + 1, true)
					local v17

					if v16 then
						v17 = v16 - 1
					else
						v17 = count
					end

					local v18 = unescape(v15 .. string.sub(value, v13 + 1, v17)) -- equivalent call inferred; original call site unknown
					emitText(result, v18, v12)
					v11 = v17 + 1
					continue
				end
			end
		end

		local v13 = string.find(value, "<", v11 + 1, true)
		local v14

		if v13 then
			v14 = v13 - 1
		else
			v14 = count
		end

		local v15 = unescape(string.sub(value, v11, v14)) -- equivalent call inferred; original call site unknown
		emitText(result, v15, v12)
		v11 = v14 + 1
	end

	return result
end

local function resolveFont(data, p)
	if not data then
		return p
	end

	if data.fontFace then
		return data.fontFace
	end

	local face = data.face
	local weight = data.weight
	local regular = Enum.FontWeight.Regular

	if weight then
		regular = Enum.FontWeight[weight] or regular
	end

	if face then
		return Font.fromName(face, regular)
	end

	if weight then
		return Font.new(p.Family, regular)
	end

	return p
end

local function measureText(text: string, size: number, font)
	local getTextBoundsParams = Instance.new("GetTextBoundsParams")
	getTextBoundsParams.Text = text
	getTextBoundsParams.Size = size
	getTextBoundsParams.Font = font
	getTextBoundsParams.Width = 1e999
	return TextService:GetTextBoundsAsync(getTextBoundsParams).X
end

function TextParser.parseLines(height: number, p2, items, p3: number?, value: number?)
	local v10 = value or 1
	local v11 = {
		{
			width = 0,
			height = height,
			y = 0,
			nodes = {}
		}
	}
	local total = 0
	local v12 = p3 ~= nil

	local function current()
		return v11[#v11]
	end

	local function newLine()
		local v13 = v11[#v11]
		total += v13.height
		table.insert(v11, {
			width = 0,
			height = height * v10,
			y = total,
			nodes = {}
		})
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function appendNode(p4, p5: number, size: number)
		local v13 = v11[#v11]
		p4.x = v13.width
		table.insert(v13.nodes, p4)
		v13.width += p5

		if v13.height < size then
			v13.height = size * v10
		end
	end

	local function measureNode(text: string, p4)
		local size = height

		if p4 and p4.size then
			size = tonumber(p4.size) or height
		elseif p4 and p4.scale then
			size = height * (tonumber(p4.scale) or 1)
		end

		local font = resolveFont(p4, p2)
		local getTextBoundsParams = Instance.new("GetTextBoundsParams")
		getTextBoundsParams.Text = text
		getTextBoundsParams.Size = size
		getTextBoundsParams.Font = font
		getTextBoundsParams.Width = 1e999
		return TextService:GetTextBoundsAsync(getTextBoundsParams).X, size, font
	end

	for _, item in items do
		if item.t == "newline" then
			newLine()
		elseif item.t == "image" then
			local a = item.a
			local size

			if a then
				if a.size then
					size = tonumber(a.size) or height
				elseif a.scale then
					size = height * (tonumber(a.scale) or 1)
				else
					size = height
				end
			else
				size = height
			end

			if v12 and p3 < v11[#v11].width + size and v11[#v11].width > 0 then
				newLine()
			end

			appendNode(item, size, size) -- equivalent call inferred; original call site unknown
		elseif item.t == "text" then
			local text = item.v
			local a = item.a
			local size

			if a and a.size then
				size = tonumber(a.size) or height
			elseif a and a.scale then
				size = height * (tonumber(a.scale) or 1)
			else
				size = height
			end

			local font = resolveFont(a, p2)
			local getTextBoundsParams = Instance.new("GetTextBoundsParams")
			getTextBoundsParams.Text = text
			getTextBoundsParams.Size = size
			getTextBoundsParams.Font = font
			getTextBoundsParams.Width = 1e999
			local X = TextService:GetTextBoundsAsync(getTextBoundsParams).X

			if v12 and not (v11[#v11].width + X <= p3) then
				while #text > 0 do
					local v14 = p3 - v11[#v11].width
					local getTextBoundsParams2 = Instance.new("GetTextBoundsParams")
					getTextBoundsParams2.Text = text
					getTextBoundsParams2.Size = size
					getTextBoundsParams2.Font = font
					getTextBoundsParams2.Width = 1e999
					local X2 = TextService:GetTextBoundsAsync(getTextBoundsParams2).X

					if X2 <= v14 then
						appendNode({
							t = "text",
							v = text,
							a = a
						}, X2, size) -- equivalent call inferred; original call site unknown
						break
					else
						local v15 = 1
						local v16 = {}

						while true do
							local v17 = v15 <= #text and text:find("%s", v15)

							if not v17 then
								break
							end

							table.insert(v16, v17 - 1)
							v15 = text:find("%S", v17)

							if not v15 then
								break
							end
						end

						local v17 = 0

						for _, v18 in v16 do
							local text2 = text:sub(1, v18)
							local getTextBoundsParams3 = Instance.new("GetTextBoundsParams")
							getTextBoundsParams3.Text = text2
							getTextBoundsParams3.Size = size
							getTextBoundsParams3.Font = font
							getTextBoundsParams3.Width = 1e999

							if TextService:GetTextBoundsAsync(getTextBoundsParams3).X <= v14 then
								v17 = v18
							else
								break
							end
						end

						if v17 > 0 then
							local text2 = text:sub(1, v17)
							local getTextBoundsParams3 = Instance.new("GetTextBoundsParams")
							getTextBoundsParams3.Text = text2
							getTextBoundsParams3.Size = size
							getTextBoundsParams3.Font = font
							getTextBoundsParams3.Width = 1e999
							appendNode({
								t = "text",
								v = text2,
								a = a
							}, TextService:GetTextBoundsAsync(getTextBoundsParams3).X, size) -- equivalent call inferred; original call site unknown
							local v20 = text:find("%S", v17 + 1)
							text = not v20 and "" or text:sub(v20)

							if #text > 0 then
								newLine()
							end
						elseif v11[#v11].width > 0 then
							newLine()
						else
							local v18 = text:find("%s")
							local text2

							if v18 then
								text2 = text:sub(1, v18 - 1)
							else
								text2 = text
							end

							local getTextBoundsParams3 = Instance.new("GetTextBoundsParams")
							getTextBoundsParams3.Text = text2
							getTextBoundsParams3.Size = size
							getTextBoundsParams3.Font = font
							getTextBoundsParams3.Width = 1e999
							appendNode({
								t = "text",
								v = text2,
								a = a
							}, TextService:GetTextBoundsAsync(getTextBoundsParams3).X, size) -- equivalent call inferred; original call site unknown
							local v21 = text:find("%S", #text2 + 1)
							text = not v21 and "" or text:sub(v21)

							if #text > 0 then
								newLine()
							end
						end
					end
				end
			else
				appendNode(item, X, size) -- equivalent call inferred; original call site unknown
			end
		else
			appendNode(item, 0, 0) -- equivalent call inferred; original call site unknown
		end
	end

	return v11
end

function TextParser.hasNewlines(items)
	for _, item in items do
		if item.t == "newline" then
			return true
		end
	end

	return false
end

function TextParser.totalWidth(items, p: number, p2)
	local total = 0

	for _, item in items do
		if item.t == "text" then
			local text = item.v
			local a = item.a
			local size

			if a and a.size then
				size = tonumber(a.size) or p
			elseif a and a.scale then
				size = p * (tonumber(a.scale) or 1)
			else
				size = p
			end

			local font = resolveFont(a, p2)
			local getTextBoundsParams = Instance.new("GetTextBoundsParams")
			getTextBoundsParams.Text = text
			getTextBoundsParams.Size = size
			getTextBoundsParams.Font = font
			getTextBoundsParams.Width = 1e999
			total += TextService:GetTextBoundsAsync(getTextBoundsParams).X
		elseif item.t == "image" then
			local a = item.a
			local size

			if a then
				if a.size then
					size = tonumber(a.size) or p
				elseif a.scale then
					size = p * (tonumber(a.scale) or 1)
				else
					size = p
				end
			else
				size = p
			end

			total += size
		end
	end

	return total
end

function TextParser.maximumMultilineTextSize(p, p2, point: Vector2, p3: number?, p4: number?)
	local Y = math.floor(point.Y)

	if Y < 1 then
		return 1
	end

	local v10 = 1
	local v11 = 1

	while v10 <= Y do
		local v12 = math.floor((v10 + Y) / 2)
		local lines = TextParser.parseLines(v12, p2, p, p3, p4)
		local v13 = 0
		local total = 0

		for _, line in lines do
			v13 = math.max(v13, line.width)
			total += line.height
		end

		if v13 <= point.X and total <= point.Y then
			v10 = v12 + 1
			v11 = v12
		else
			Y = v12 - 1
		end
	end

	return v11
end

function TextParser.maximumTextSize(p, p2, point: Vector2)
	local Y = math.floor(point.Y)

	if Y < 1 then
		return 1
	end

	local totalWidth = TextParser.totalWidth(p, 100, p2)

	if totalWidth == 0 then
		return Y
	end

	local v10 = math.floor((math.min(Y, 100 * point.X / totalWidth)))
	local v11 = math.max(1, v10 - 5)
	local v12 = math.min(Y, v10 + 5)
	local v13 = v11

	while v11 <= v12 do
		local v14 = math.floor((v11 + v12) / 2)

		if TextParser.totalWidth(p, v14, p2) <= point.X then
			v11 = v14 + 1
			v13 = v14
		else
			v12 = v14 - 1
		end
	end

	return v13
end

local getTextBoundsParams = Instance.new("GetTextBoundsParams")
getTextBoundsParams.Text = "a"
getTextBoundsParams.Size = 10

function TextParser.loadFont(font)
	getTextBoundsParams.Font = font
	TextService:GetTextBoundsAsync(getTextBoundsParams)
end

return TextParser