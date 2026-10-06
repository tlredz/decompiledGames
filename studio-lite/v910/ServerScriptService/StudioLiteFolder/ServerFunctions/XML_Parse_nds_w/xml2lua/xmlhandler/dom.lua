local function init()
	return {
		options = {
			commentNode = 1,
			piNode = 1,
			dtdNode = 1,
			declNode = 1
		},
		current = {
			_children = {},
			_type = "ROOT"
		},
		_stack = {}
	}
end

local v = init()

function v.new(p)
	local v2 = init()
	v2.__index = p
	setmetatable(v2, p)
	return v2
end

function v:starttag(p)
	local v2 = {
		_type = "ELEMENT",
		_name = p.name,
		_attr = p.attrs,
		_children = {}
	}

	if not self.root then
		self.root = v2
	end

	table.insert(self._stack, v2)
	table.insert(self.current._children, v2)
	self.current = v2
end

function v:endtag(p)
	local v2 = self._stack[#self._stack]

	if p.name ~= v2._name then
		error("XML Error - Unmatched Tag [" .. ":" .. p.name .. "]\n")
	end

	table.remove(self._stack)
	self.current = self._stack[#self._stack]

	if not self.current then
		local v3 = {
			_children = {},
			_type = "ROOT"
		}

		if self.decl then
			table.insert(v3._children, self.decl)
			self.decl = nil
		end

		if self.dtd then
			table.insert(v3._children, self.dtd)
			self.dtd = nil
		end

		if self.root then
			table.insert(v3._children, self.root)
			self.root = v3
		end

		self.current = v3
	end
end

function v.text(p, text)
	table.insert(p.current._children, {
		_type = "TEXT",
		_text = text
	})
end

function v.comment(p, text)
	if p.options.commentNode then
		table.insert(p.current._children, {
			_type = "COMMENT",
			_text = text
		})
	end
end

function v.pi(p, p2)
	if p.options.piNode then
		local v2 = {
			_type = "PI",
			_name = p2.name,
			_attr = p2.attrs
		}
		table.insert(p.current._children, v2)
	end
end

function v:decl(p2)
	if self.options.declNode then
		self.decl = {
			_type = "DECL",
			_name = p2.name,
			_attr = p2.attrs
		}
	end
end

function v:dtd(p2)
	if self.options.dtdNode then
		self.dtd = {
			_type = "DTD",
			_name = p2.name,
			_text = p2.value
		}
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function xmlEscape(_text)
	local v2 = string.gsub(_text, "&", "&amp;")
	local v3 = string.gsub(v2, "<", "&lt;")
	return string.gsub(v3, ">", "&gt;")
end

local function attrsToStr(_attr)
	if not _attr then
		return ""
	end

	if type(_attr) ~= "table" then
		return "BUG:unknown type:" .. type(_attr)
	end

	local v2 = ""

	for k, item in pairs(_attr) do
		local v3 = tostring(item)
		local v4 = string.find(v3, "'")
		local v5 = string.find(v3, "\"")
		local v6 = "\""

		if v4 and v5 then
			local v7 = string.gsub(v3, "\"", "&quot;")
			v3 = string.gsub(v7, "'", "&apos;")
		elseif v5 then
			v6 = "'"
		end

		v2 = " " .. tostring(k) .. "=" .. v6 .. v3 .. v6
	end

	return v2
end

local toXmlStr

toXmlStr = function(data, p)
	if not data then
		return "BUG:node==nil"
	end

	if not data._type then
		return "BUG:node._type==nil"
	end

	local v2 = ""

	for _ = 0, p + 1 do
		v2 ..= " "
	end

	if data._type == "ROOT" then
		local v3 = ""

		for _, v4 in pairs(data._children) do
			v3 ..= toXmlStr(v4, p + 2)
		end

		return v3
	elseif data._type == "ELEMENT" then
		local v3 = v2 .. "<" .. data._name .. attrsToStr(data._attr)

		if not data._children or #data._children == 0 then
			return v3 .. "/>\n"
		end

		local v4 = v3 .. ">\n"

		for _, v5 in pairs(data._children) do
			local v6 = toXmlStr(v5, p + 2)

			if v6 then
				v4 ..= v6
			else
				print("BUG:xx==nil")
			end
		end

		return v4 .. v2 .. "</" .. data._name .. ">\n"
	elseif data._type == "TEXT" then
		return v2 .. xmlEscape(data._text) .. "\n"
	else
		if data._type == "COMMENT" then
			return v2 .. "<!--" .. data._text .. "-->\n"
		end

		if data._type == "PI" then
			return v2 .. "<?" .. data._name .. " " .. data._attr._text .. "?>\n"
		end

		if data._type == "DECL" then
			return v2 .. "<?" .. data._name .. attrsToStr(data._attr) .. "?>\n"
		end

		if data._type == "DTD" then
			return v2 .. "<!" .. data._name .. " " .. data._text .. ">\n"
		end

		return "BUG:unknown type:" .. tostring(data._type)
	end
end

function v.toXml(_, p)
	return (toXmlStr(p, -4))
end

v.cdata = v.text
v.__index = v
return v