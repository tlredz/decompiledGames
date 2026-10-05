local parent = script.Parent.Parent
local modules = parent.Modules
local components = parent.Components
local Packages = require(modules.Packages)
local PacketSizeCounter = require(Packages.Directory.PacketSizeCounter)
local StudioSettings = require(components.StudioSettings)
local v = {
	["\7"] = "\\a",
	["\8"] = "\\b",
	["\f"] = "\\f",
	["\n"] = "\\n",
	["\r"] = "\\r",
	["\t"] = "\\t",
	["\11"] = "\\v",
	["\0"] = "\\0"
}
local v2 = {
	["and"] = true,
	["break"] = true,
	["do"] = true,
	["else"] = true,
	["elseif"] = true,
	["end"] = true,
	["false"] = true,
	["for"] = true,
	["function"] = true,
	["if"] = true,
	["in"] = true,
	["local"] = true,
	["nil"] = true,
	["not"] = true,
	["or"] = true,
	["repeat"] = true,
	["return"] = true,
	["then"] = true,
	["true"] = true,
	["until"] = true,
	["while"] = true,
	continue = true
}
local v3 = {
	["&"] = "&amp;",
	["<"] = "&lt;",
	[">"] = "&gt;",
	["\""] = "&quot;",
	["'"] = "&apos;"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function GetByteSize(p)
	local dataByteSize = PacketSizeCounter.GetDataByteSize(p)

	if dataByteSize < 1000 then
		return (`{dataByteSize} bytes`)
	end

	return string.format("%.3f kilobytes", dataByteSize / 1000)
end

local v4 = {
	string = "ScriptString",
	number = "ScriptNumber",
	operator = "ScriptOperator",
	keyword = "ScriptKeyword",
	boolean = "ScriptKeyword",
	builtin = "ScriptBuiltInFunction",
	funcname = "ScriptFunctionName",
	text = "ScriptText",
	["nil"] = "ScriptKeyword",
	bytesize = "ScriptComment",
	bracket = "ScriptBracket"
}
local v5 = {}

local function UpdateStyleGuideColors()
	local theme = StudioSettings.Theme

	for k, v6 in v4 do
		v5[k] = `#{theme:GetColor(v6):ToHex()}`
	end
end

UpdateStyleGuideColors()
StudioSettings.ThemeChanged:Connect(UpdateStyleGuideColors)
local class = {}
class.__index = class

function class.new(value)
	return (setmetatable({
		parts = {},
		glyphCount = 0,
		maxGlyphs = value or 20000,
		trimmed = false
	}, class))
end

function class:getRemainingGlyphs()
	return (math.max(0, self.maxGlyphs - self.glyphCount - 13))
end

function class:canAddGlyphs(p2)
	return self.glyphCount + p2 + 13 <= self.maxGlyphs
end

function class:addRaw(list)
	if self.trimmed then
		return false
	end

	local count = #list

	if self:canAddGlyphs(count) then
		table.insert(self.parts, list)
		self.glyphCount += count
		return true
	else
		self.trimmed = true
		table.insert(self.parts, "... [Trimmed]")
		self.glyphCount += 13
		return false
	end
end

function class:addFormatted(value, value2)
	if self.trimmed then
		return false
	end

	local count = #value2

	if self:canAddGlyphs(count) then
		table.insert(self.parts, value)
		self.glyphCount += count
		return true
	else
		local remainingGlyphs = self:getRemainingGlyphs()

		if remainingGlyphs > 0 then
			local v6 = string.sub(value2, 1, remainingGlyphs)
			table.insert(
				self.parts,
				string.format("<font color=\"%s\">%s</font>", string.match(value, "color=\"([^\"]+)\"") or v5.text, v6)
			)
			self.glyphCount += #v6
		end

		self.trimmed = true
		table.insert(self.parts, "... [Trimmed]")
		self.glyphCount += 13
		return false
	end
end

function class:toString()
	return table.concat(self.parts)
end

function class:isTrimmed()
	return self.trimmed
end

local function Syntax(p, p2, object)
	local v6 = string.format("<font color=\"%s\">%s</font>", v5[p2] or v5.text, p)

	if not object then
		return v6
	end

	object:addFormatted(v6, p)
	return v6
end

local v6 = {
	["."] = function(object)
		local v7 = string.format("<font color=\"%s\">%s</font>", v5.operator or v5.text, ".")

		if not object then
			return v7
		end

		object:addFormatted(v7, ".")
		return v7
	end,
	[","] = function(object)
		local v7 = string.format("<font color=\"%s\">%s</font>", v5.text or v5.text, ",")

		if not object then
			return v7
		end

		object:addFormatted(v7, ",")
		return v7
	end,
	["="] = function(object)
		local v7 = string.format("<font color=\"%s\">%s</font>", v5.operator or v5.text, "=")

		if not object then
			return v7
		end

		object:addFormatted(v7, "=")
		return v7
	end,
	["("] = function(object)
		local v7 = string.format("<font color=\"%s\">%s</font>", v5.bracket or v5.text, "(")

		if not object then
			return v7
		end

		object:addFormatted(v7, "(")
		return v7
	end,
	[")"] = function(object)
		local v7 = string.format("<font color=\"%s\">%s</font>", v5.bracket or v5.text, ")")

		if not object then
			return v7
		end

		object:addFormatted(v7, ")")
		return v7
	end,
	["{"] = function(object)
		local v7 = string.format("<font color=\"%s\">%s</font>", v5.bracket or v5.text, "{")

		if not object then
			return v7
		end

		object:addFormatted(v7, "{")
		return v7
	end,
	["}"] = function(object)
		local v7 = string.format("<font color=\"%s\">%s</font>", v5.bracket or v5.text, "}")

		if not object then
			return v7
		end

		object:addFormatted(v7, "}")
		return v7
	end,
	["["] = function(object)
		local v7 = string.format("<font color=\"%s\">%s</font>", v5.bracket or v5.text, "[")

		if not object then
			return v7
		end

		object:addFormatted(v7, "[")
		return v7
	end,
	["]"] = function(object)
		local v7 = string.format("<font color=\"%s\">%s</font>", v5.bracket or v5.text, "]")

		if not object then
			return v7
		end

		object:addFormatted(v7, "]")
		return v7
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function CleanupString(value)
	local v7 = string.gsub(value, "[%c%z]", v)
	return (string.gsub(v7, "[%&%<%>%\"%']", v3))
end

local function GetHierarchy(instance, object)
	local v7 = true
	local v8 = {}
	local v9 = {}

	while v7 do
		local parent2 = instance.Parent
		v7 = parent2 and parent2.Parent and parent2 ~= game
		local cleanupString = CleanupString(instance.Name) -- equivalent call inferred; original call site unknown

		if v2[cleanupString] or not string.match(cleanupString, "^[_%a][_%w]*$") then
			local formatted = `&quot;{cleanupString}&quot;`
			local v11 = string.format("<font color=\"%s\">%s</font>", v5.string or v5.text, formatted)
			table.insert(v8, 1, (`{v6["["](nil)}{v11}{v6["]"](nil)}`))
			table.insert(v9, 1, (`["{cleanupString}"]`))
			instance = parent2
		else
			table.insert(
				v8,
				1,
				(`{v7 and v6["."](nil) or ""}{string.format("<font color=\"%s\">%s</font>", v5.text or v5.text, cleanupString)}`)
			)
			table.insert(v9, 1, (`{v7 and "." or ""}{cleanupString}`))
			instance = parent2
		end
	end

	local joined = table.concat(v8)
	local joined2 = table.concat(v9)

	if object then
		object:addFormatted(joined, joined2)
	end

	return joined
end

local function ReadBuffer(buf: buffer)
	local v7 = buffer.len(buf)
	local v8 = table.create(v7)

	for i = 0, v7 - 1 do
		table.insert(v8, (buffer.readu8(buf, i)))
	end

	return table.concat(v8, " ")
end

local function SerializeType(value, typeName, object)
	local v7, v8

	if typeName == "string" then
		local cleanupString = CleanupString(value) -- equivalent call inferred; original call site unknown
		v7 = `"{cleanupString}"`
		local formatted = `&quot;{cleanupString}&quot;`
		v8 = string.format("<font color=\"%s\">%s</font>", v5.string or v5.text, formatted)
	else
		if typeName == "Instance" then
			return (GetHierarchy(value, object))
		end

		if typeName == "buffer" then
			local readBuffer = ReadBuffer(value)
			v7 = `buffer.new(${readBuffer})`
			v8 = `{string.format("<font color=\"%s\">%s</font>", v5.builtin or v5.text, "buffer")}{v6["."](nil)}{string.format("<font color=\"%s\">%s</font>", v5.builtin or v5.text, "new")}{v6["("](nil)}{string.format("<font color=\"%s\">%s</font>", v5.number or v5.text, readBuffer)}{v6[")"](nil)}`
		elseif type(value) == typeName then
			v7 = tostring(value)
			v8 = string.format("<font color=\"%s\">%s</font>", v5[typeName] or v5.text, v7)
		else
			local v9 = tostring(value)
			v7 = `{typeName}.new({v9})`
			v8 = `{string.format("<font color=\"%s\">%s</font>", v5.builtin or v5.text, typeName)}{v6["."](nil)}{string.format("<font color=\"%s\">%s</font>", v5.builtin or v5.text, "new")}{v6["("](nil)}{string.format("<font color=\"%s\">%s</font>", v5.number or v5.text, v9)}{v6[")"](nil)}`
		end
	end

	if object then
		object:addFormatted(v8, v7)
	end

	return v8
end

local TableToSyntaxString

TableToSyntaxString = function(items, p, options, count, p2)
	local v7 = p2 or class.new()
	local v8 = options or {}

	if v8[items] then
		local v9 = string.format("<font color=\"%s\">%s</font>", v5.string or v5.text, "&quot;[Cyclic reference]&quot;")

		if v7 then
			v7:addFormatted(v9, "&quot;[Cyclic reference]&quot;")
		end

		return v7:toString()
	else
		v8[items] = true
		local v9 = not p
		local v10 = (count or 0) + 1
		local v11 = string.rep("    ", v10 - 1)
		local v12 = string.rep("    ", v10 - 2)
		local v13 = next(items) == nil
		local v14 = true

		if v10 ~= 1 and not v13 then
			v6["{"](v7)
			v7:addRaw("\n")
		end

		local v15 = 1

		for k, item in items do
			if v7:isTrimmed() then
				break
			end

			if v15 ~= k then
				v14 = false
			end

			local typeName = typeof(k)
			local typeName2 = typeof(item)

			if v15 > 1 then
				v7:addRaw("\n")
			end

			v7:addRaw(v11)

			if not v14 then
				if typeName == "string" then
					k = CleanupString(k)

					if v2[k] or not string.match(k, "^[_%a][_%w]*$") then
						v6["["](v7)
						local formatted = `&quot;{k}&quot;`
						local v16 = string.format("<font color=\"%s\">%s</font>", v5.string or v5.text, formatted)

						if v7 then
							v7:addFormatted(v16, formatted)
						end

						v6["]"](v7)
					else
						v7:addRaw(k)
					end
				else
					v6["["](v7)

					if typeName == "table" then
						TableToSyntaxString(k, p, v8, 1, v7)
					else
						SerializeType(k, typeName, v7)
					end

					v6["]"](v7)
				end

				if typeName ~= "table" and v9 then
					local byteSize = GetByteSize(k) -- equivalent call inferred; original call site unknown
					local formatted = `: {byteSize} `
					local v17 = string.format("<font color=\"%s\">%s</font>", v5.bytesize or v5.text, formatted)

					if v7 then
						v7:addFormatted(v17, formatted)
					end
				end

				v7:addRaw(" ")
				v6["="](v7)
				v7:addRaw(" ")
			end

			if typeName2 == "table" then
				TableToSyntaxString(item, p, v8, v10, v7)
			else
				SerializeType(item, typeName2, v7)
			end

			if typeName2 ~= "table" and v9 then
				local byteSize = GetByteSize(item) -- equivalent call inferred; original call site unknown
				local formatted = `: {byteSize}`
				local v17 = string.format("<font color=\"%s\">%s</font>", v5.bytesize or v5.text, formatted)

				if v7 then
					v7:addFormatted(v17, formatted)
				end
			end

			v6[","](v7)
			v15 += 1
		end

		if v10 == 1 then
			return v7:toString()
		end

		if v13 then
			v6["{"](v7)
		else
			v7:addRaw("\n")
			v7:addRaw(v12)
		end

		v6["}"](v7)
		return v7:toString()
	end
end

return TableToSyntaxString