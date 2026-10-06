local Xml2lua = {
	_VERSION = "1.6-1"
}
local XmlParser = require(script:WaitForChild("XmlParser", 999))
local printableInternal

printableInternal = function(items, value)
	if items == nil then
		return
	end

	local v = value or 1
	local v2 = string.rep(" ", v * 2)

	for k, item in pairs(items) do
		if type(item) == "table" then
			print(v2 .. k)
			printableInternal(item, v + 1)
		else
			print(v2 .. k .. "=" .. item)
		end
	end
end

function Xml2lua.parser(p)
	if p == Xml2lua then
		error("You must call xml2lua.parse(handler) instead of xml2lua:parse(handler)")
	end

	return XmlParser.new(p, {
		stripWS = 1,
		expandEntities = 1,
		errorHandler = function(value, p2)
			error(string.format("%s [char=%d]\n", value or "Parse Error", p2))
		end
	})
end

function Xml2lua.printable(p)
	printableInternal(p)
end

function Xml2lua.toString(items)
	local v = ""
	local v2 = ""

	if type(items) ~= "table" then
		return items
	end

	for k, item in pairs(items) do
		if type(item) == "table" then
			item = Xml2lua.toString(item)
		end

		v2 ..= v .. string.format("%s=%s", k, item)
		v = ","
	end

	return "{" .. v2 .. "}"
end

local function attrToXml(options)
	local v = ""

	for k, v2 in pairs(options or {}) do
		v ..= " " .. k .. "=" .. "\"" .. v2 .. "\""
	end

	return v
end

local function getSingleChild(items)
	local count = 0

	for _ in pairs(items) do
		count += 1
	end

	if count == 1 then
		for k, _ in pairs(items) do
			return k
		end
	end

	return nil
end

local function getFirstValue(items)
	if type(items) ~= "table" then
		return items
	end

	for _, item in pairs(items) do
		return item
	end

	return nil
end

Xml2lua.pretty = true

function Xml2lua.getSpaces(p)
	return not Xml2lua.pretty and "" or string.rep(" ", p * 2)
end

function Xml2lua.addTagValueAttr(p, p2, p3, p4)
	local v = attrToXml(p3)
	local spaces = Xml2lua.getSpaces(p4)

	if p2 == "" then
		table.insert(Xml2lua.xmltb, spaces .. "<" .. p .. v .. "/>")
	else
		table.insert(Xml2lua.xmltb, spaces .. "<" .. p .. v .. ">" .. tostring(p2) .. "</" .. p .. ">")
	end
end

function Xml2lua.startTag(p, p2, p3)
	local v = attrToXml(p2)
	local spaces = Xml2lua.getSpaces(p3)

	if p ~= nil then
		table.insert(Xml2lua.xmltb, spaces .. "<" .. p .. v .. ">")
	end
end

function Xml2lua.endTag(p, p2)
	local spaces = Xml2lua.getSpaces(p2)

	if p ~= nil then
		table.insert(Xml2lua.xmltb, spaces .. "</" .. p .. ">")
	end
end

function Xml2lua.isChildArray(items)
	for k, _ in pairs(items) do
		if type(k) == "number" then
			return true
		end
	end

	return false
end

function Xml2lua.isTableEmpty(items)
	for k, _ in pairs(items) do
		if k ~= "_attr" then
			return false
		end
	end

	return true
end

function Xml2lua:parseTableToXml(p2, p3)
	if p2 ~= "_attr" then
		if type(self) == "table" then
			if Xml2lua.isChildArray(self) then
				for _, v in pairs(self) do
					Xml2lua.parseTableToXml(v, p2, p3)
				end
			else
				if Xml2lua.isTableEmpty(self) then
					Xml2lua.addTagValueAttr(p2, "", self._attr, p3)
					return
				end

				Xml2lua.startTag(p2, self._attr, p3)

				for k, v in pairs(self) do
					Xml2lua.parseTableToXml(v, k, p3 + 1)
				end

				Xml2lua.endTag(p2, p3)
			end
		else
			Xml2lua.addTagValueAttr(p2, self, nil, p3)
		end
	end
end

function Xml2lua.toXml(items, p, value)
	Xml2lua.xmltb = {}
	local count = 0
	local v = value or 0

	for _ in pairs(items) do
		count += 1
	end

	local v2

	if count == 1 then
		for k, _ in pairs(items) do
			v2 = k
			break
		end
	end

	local v3 = p or v2

	if v2 then
		local parseTableToXml = Xml2lua.parseTableToXml

		if type(items) == "table" then
			for _, item in pairs(items) do
				items = item
				break
			end
		end

		parseTableToXml(items, v3, v)
	else
		Xml2lua.parseTableToXml(items, v3, v)
	end

	if Xml2lua.pretty then
		return table.concat(Xml2lua.xmltb, "\n")
	end

	return table.concat(Xml2lua.xmltb)
end

return Xml2lua