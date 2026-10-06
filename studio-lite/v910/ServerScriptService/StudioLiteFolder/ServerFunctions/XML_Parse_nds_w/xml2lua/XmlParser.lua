local function decimalToHtmlChar(p)
	local v = tonumber(p)

	if v >= 0 and v < 256 then
		return (string.char(v))
	end

	return "&#" .. p .. ";"
end

local function hexadecimalToHtmlChar(p)
	local v = tonumber(p, 16)

	if v >= 0 and v < 256 then
		return (string.char(v))
	end

	return "&#x" .. p .. ";"
end

local XmlParser = {
	_XML = "^([^<]*)<(%/?)([^>]-)(%/?)>",
	_ATTR1 = "([%w-:_]+)%s*=%s*\"(.-)\"",
	_ATTR2 = "([%w-:_]+)%s*=%s*'(.-)'",
	_CDATA = "<%!%[CDATA%[(.-)%]%]>",
	_PI = "<%?(.-)%?>",
	_COMMENT = "<!%-%-(.-)%-%->",
	_TAG = "^(.-)%s.*",
	_LEADINGWS = "^%s+",
	_TRAILINGWS = "%s+$",
	_WS = "^%s*$",
	_DTD1 = "<!DOCTYPE%s+(.-)%s+(SYSTEM)%s+[\"'](.-)[\"']%s*(%b[])%s*>",
	_DTD2 = "<!DOCTYPE%s+(.-)%s+(PUBLIC)%s+[\"'](.-)[\"']%s+[\"'](.-)[\"']%s*(%b[])%s*>",
	_DTD3 = "<!DOCTYPE%s+(.-)%s+%[%s+.-%]>",
	_DTD4 = "<!DOCTYPE%s+(.-)%s+(SYSTEM)%s+[\"'](.-)[\"']%s*>",
	_DTD5 = "<!DOCTYPE%s+(.-)%s+(PUBLIC)%s+[\"'](.-)[\"']%s+[\"'](.-)[\"']%s*>",
	_DTD6 = "<!DOCTYPE%s+(.-)%s+(PUBLIC)%s+[\"'](.-)[\"']%s*>",
	_ATTRERR1 = "=+?%s*\"[^\"]*$",
	_ATTRERR2 = "=+?%s*'[^']*$",
	_TAGEXT = "(%/?)>",
	_errstr = {
		xmlErr = "Error Parsing XML",
		declErr = "Error Parsing XMLDecl",
		declStartErr = "XMLDecl not at start of document",
		declAttrErr = "Invalid XMLDecl attributes",
		piErr = "Error Parsing Processing Instruction",
		commentErr = "Error Parsing Comment",
		cdataErr = "Error Parsing CDATA",
		dtdErr = "Error Parsing DTD",
		endTagErr = "End Tag Attributes Invalid",
		unmatchedTagErr = "Unbalanced Tag",
		incompleteXmlErr = "Incomplete XML Document"
	},
	_ENTITIES = {
		["&lt;"] = "<",
		["&gt;"] = ">",
		["&amp;"] = "&",
		["&quot;"] = "\"",
		["&apos;"] = "'",
		["&#(%d+);"] = decimalToHtmlChar,
		["&#x(%x+);"] = hexadecimalToHtmlChar
	}
}

function XmlParser.new(handler, options)
	local v = {
		handler = handler,
		options = options,
		_stack = {}
	}
	setmetatable(v, XmlParser)
	v.__index = XmlParser
	return v
end

local fexists

fexists = function(metatable, p)
	if metatable == nil then
		return false
	end

	if metatable[p] == nil then
		return fexists(getmetatable(metatable), p)
	end

	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function err(p, p2, p3)
	local errorHandler = p.options.errorHandler
end

local function stripWS(p, value)
	if p.options.stripWS then
		local v = string.gsub(value, "^%s+", "")
		value = string.gsub(v, "%s+$", "")
	end

	return value
end

local function parseEntities(data, value)
	if data.options.expandEntities then
		for k, v in pairs(data._ENTITIES) do
			value = string.gsub(value, k, v)
		end
	end

	return value
end

local function parseTag(data, value)
	local v = {
		name = string.gsub(value, data._TAG, "%1"),
		attrs = {}
	}

	local function fn(p, p2)
		v.attrs[p] = parseEntities(data, p2)
		v.attrs._ = 1
	end

	string.gsub(value, data._ATTR1, fn)
	string.gsub(value, data._ATTR2, fn)

	if v.attrs._ then
		v.attrs._ = nil
		return v
	end

	v.attrs = nil
	return v
end

local function parseXmlDeclaration(data, value, state)
	local match, endMatch, text = string.find(value, data._PI, state.pos)
	state.match = match
	state.endMatch = endMatch
	state.text = text

	if not state.match then
		local declErr = data._errstr.declErr
		local pos = state.pos
		err(data) -- equivalent call inferred; original call site unknown
	end

	if state.match ~= 1 then
		local declStartErr = data._errstr.declStartErr
		local pos = state.pos
		err(data) -- equivalent call inferred; original call site unknown
	end

	local v4 = parseTag(data, state.text)

	if v4.attrs and v4.attrs.version == nil then
		local declAttrErr = data._errstr.declAttrErr
		local pos = state.pos
		err(data) -- equivalent call inferred; original call site unknown
	end

	local handler = data.handler
	local v5

	if handler == nil then
		v5 = false
	else
		v5 = handler.decl ~= nil or fexists(getmetatable(handler), "decl")
	end

	if v5 then
		data.handler:decl(v4, state.match, state.endMatch)
	end

	return v4
end

local function parseXmlProcessingInstruction(data, value, state)
	local v = {}
	local match, endMatch, text = string.find(value, data._PI, state.pos)
	state.match = match
	state.endMatch = endMatch
	state.text = text

	if not state.match then
		local piErr = data._errstr.piErr
		local pos = state.pos
		err(data) -- equivalent call inferred; original call site unknown
	end

	local handler = data.handler
	local v5

	if handler == nil then
		v5 = false
	else
		v5 = handler.pi ~= nil or fexists(getmetatable(handler), "pi")
	end

	if not v5 then
		return v
	end

	v = parseTag(data, state.text)
	local text2 = string.sub(state.text, string.len(v.name) + 1)

	if text2 ~= "" then
		if v.attrs then
			v.attrs._text = text2
		else
			v.attrs = {
				_text = text2
			}
		end
	end

	data.handler:pi(v, state.match, state.endMatch)
	return v
end

local function parseComment(data, value, state)
	local match, endMatch, text2 = string.find(value, data._COMMENT, state.pos)
	state.match = match
	state.endMatch = endMatch
	state.text = text2

	if not state.match then
		local commentErr = data._errstr.commentErr
		local pos = state.pos
		err(data) -- equivalent call inferred; original call site unknown
	end

	local handler = data.handler
	local v4

	if handler == nil then
		v4 = false
	else
		v4 = handler.comment ~= nil or fexists(getmetatable(handler), "comment")
	end

	if v4 then
		local text = state.text

		if data.options.stripWS then
			local v6 = string.gsub(text, "^%s+", "")
			text = string.gsub(v6, "%s+$", "")
		end

		state.text = parseEntities(data, text)
		data.handler:comment(state.text, next, state.match, state.endMatch)
	end
end

local function _parseDtd(data, value, pos)
	local v = {
		data._DTD1,
		data._DTD2,
		data._DTD3,
		data._DTD4,
		data._DTD5,
		data._DTD6
	}

	for k, v2 in pairs(v) do
		local v3, v4, root, v6, name, uri, internal = string.find(value, v2, pos)

		if v3 then
			return v3, v4, {
				_root = root,
				_type = v6,
				_name = name,
				_uri = uri,
				_internal = internal
			}
		end
	end

	return nil
end

local function parseDtd(p, value, state)
	local match, endMatch, v3 = _parseDtd(p, value, state.pos)
	state.match = match
	state.endMatch = endMatch
	_ = v3

	if not state.match then
		local dtdErr = p._errstr.dtdErr
		local pos = state.pos
		err(p) -- equivalent call inferred; original call site unknown
	end

	local handler = p.handler
	local v4

	if handler == nil then
		v4 = false
	else
		v4 = handler.dtd ~= nil or fexists(getmetatable(handler), "dtd")
	end

	if v4 then
		local v5 = {
			name = "DOCTYPE",
			value = string.sub(value, state.match + 10, state.endMatch - 1)
		}
		p.handler:dtd(v5, state.match, state.endMatch)
	end
end

local function parseCdata(data, value, state)
	local match, endMatch, text = string.find(value, data._CDATA, state.pos)
	state.match = match
	state.endMatch = endMatch
	state.text = text

	if not state.match then
		local cdataErr = data._errstr.cdataErr
		local pos = state.pos
		err(data) -- equivalent call inferred; original call site unknown
	end

	local handler = data.handler
	local v4

	if handler == nil then
		v4 = false
	else
		v4 = handler.cdata ~= nil or fexists(getmetatable(handler), "cdata")
	end

	if v4 then
		data.handler:cdata(state.text, nil, state.match, state.endMatch)
	end
end

local function parseNormalTag(data, value, state)
	while true do
		local errStart, errEnd = string.find(state.tagstr, data._ATTRERR1)
		state.errStart = errStart
		state.errEnd = errEnd

		if state.errEnd == nil then
			local errStart2, errEnd2 = string.find(state.tagstr, data._ATTRERR2)
			state.errStart = errStart2
			state.errEnd = errEnd2

			if state.errEnd == nil then
				local v5 = parseTag(data, state.tagstr)

				if state.endt1 == "/" then
					local handler = data.handler
					local v6

					if handler == nil then
						v6 = false
					else
						v6 = handler.endtag ~= nil or fexists(getmetatable(handler), "endtag")
					end

					if v6 then
						local attrs = v5.attrs
						local v7 = table.remove(data._stack) == v5.name
						data.handler:endtag(v5, state.match, state.endMatch)
						return v5
					end
				else
					table.insert(data._stack, v5.name)
					local handler = data.handler
					local v6

					if handler == nil then
						v6 = false
					else
						v6 = handler.starttag ~= nil or fexists(getmetatable(handler), "starttag")
					end

					if v6 then
						data.handler:starttag(v5, state.match, state.endMatch)
					end

					if state.endt2 == "/" then
						table.remove(data._stack)
						local handler2 = data.handler
						local v7

						if handler2 == nil then
							v7 = false
						else
							v7 = handler2.endtag ~= nil or fexists(getmetatable(handler2), "endtag")
						end

						if v7 then
							data.handler:endtag(v5, state.match, state.endMatch)
						end
					end
				end

				return v5
			end
		end

		local extStart, extEnd, endt = string.find(value, data._TAGEXT, state.endMatch + 1)
		state.extStart = extStart
		state.extEnd = extEnd
		state.endt2 = endt
		state.tagstr ..= string.sub(value, state.endMatch, state.extEnd - 1)

		if not state.match then
			local xmlErr = data._errstr.xmlErr
			local pos = state.pos
			err(data) -- equivalent call inferred; original call site unknown
		end

		state.endMatch = state.extEnd
	end
end

local function parseTagType(p, p2, p3)
	if string.find(string.sub(p3.tagstr, 1, 5), "?xml%s") then
		parseXmlDeclaration(p, p2, p3)
	elseif string.sub(p3.tagstr, 1, 1) == "?" then
		parseXmlProcessingInstruction(p, p2, p3)
	elseif string.sub(p3.tagstr, 1, 3) == "!--" then
		parseComment(p, p2, p3)
	elseif string.sub(p3.tagstr, 1, 8) == "!DOCTYPE" then
		parseDtd(p, p2, p3)
	elseif string.sub(p3.tagstr, 1, 8) == "![CDATA[" then
		parseCdata(p, p2, p3)
	else
		parseNormalTag(p, p2, p3)
	end
end

local function getNextTag(data, value, state)
	local match, endMatch, text, endt, tagstr, endt2 = string.find(value, data._XML, state.pos)
	state.match = match
	state.endMatch = endMatch
	state.text = text
	state.endt1 = endt
	state.tagstr = tagstr
	state.endt2 = endt2

	if not state.match then
		if string.find(value, data._WS, state.pos) then
			if #data._stack == 0 then
				return false
			end

			local incompleteXmlErr = data._errstr.incompleteXmlErr
			local pos = state.pos
			err(data) -- equivalent call inferred; original call site unknown
		else
			local xmlErr = data._errstr.xmlErr
			local pos = state.pos
			err(data) -- equivalent call inferred; original call site unknown
		end
	end

	state.text = state.text or ""
	state.tagstr = state.tagstr or ""
	state.match = state.match or 0
	return state.endMatch ~= nil
end

function XmlParser.parse(p, p2, p3)
	if type(p) ~= "table" or getmetatable(p) ~= XmlParser then
		error("You must call xmlparser:parse(parameters) instead of xmlparser.parse(parameters)")
	end

	local parseAttributes = p3 == nil or p3
	p.handler.parseAttributes = parseAttributes
	local v2 = {
		match = 0,
		endMatch = 0,
		pos = 1
	}

	while v2.match and getNextTag(p, p2, v2) do
		v2.startText = v2.match
		v2.endText = v2.match + string.len(v2.text) - 1
		v2.match += string.len(v2.text)
		local text = v2.text

		if p.options.stripWS then
			local v4 = string.gsub(text, "^%s+", "")
			text = string.gsub(v4, "%s+$", "")
		end

		v2.text = parseEntities(p, text)

		if v2.text ~= "" then
			local handler = p.handler
			local v4

			if handler == nil then
				v4 = false
			else
				v4 = handler.text ~= nil or fexists(getmetatable(handler), "text")
			end

			if v4 then
				p.handler:text(v2.text, nil, v2.match, v2.endText)
			end
		end

		parseTagType(p, p2, v2)
		v2.pos = v2.endMatch + 1
	end
end

XmlParser.__index = XmlParser
return XmlParser