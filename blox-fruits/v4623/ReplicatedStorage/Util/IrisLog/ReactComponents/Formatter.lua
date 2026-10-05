local Formatter = {}
local RichText = require(script.Parent.RichText)
local object = setmetatable({}, {
	__mode = "k"
})
local object2 = setmetatable({}, {
	__mode = "k"
})
local object3 = setmetatable({}, {
	__mode = "k"
})
local v = {}
local v2 = {
	["</font>"] = true,
	["</text>"] = true,
	["</br>"] = true,
	["</tree>"] = true,
	["</div>"] = true,
	["</cdiv>"] = true,
	["</agrid>"] = true,
	["</alist>"] = true,
	["</bubble>"] = true,
	["</btn>"] = true,
	["</chk>"] = true,
	["</cmbo>"] = true,
	["</combochild>"] = true,
	["</stay>"] = true,
	["</tip>"] = true
}

local function concatParts(items, p)
	if not items then
		return ""
	end

	local texts = {}

	for _, item in items do
		local text = Formatter.toText(item, p)

		if text ~= nil and text ~= "" then
			table.insert(texts, text)
		end
	end

	return table.concat(texts)
end

local function tableToText(list, p)
	if #list > 0 then
		local v3 = {}

		for _, v4 in list do
			table.insert(v3, Formatter.toText(v4, p) or "")
		end

		return "{" .. table.concat(v3, ", ") .. "}"
	else
		local v3 = {}

		for k, v4 in list do
			table.insert(v3, (`{Formatter.toText(k, p) or tostring(k)}: {Formatter.toText(v4, p) or ""}`))
		end

		return "{" .. table.concat(v3, "; ") .. "}"
	end
end

function Formatter.toText(list, p)
	local typeName = typeof(list)

	if typeName == "nil" then
		return nil
	elseif typeName == "string" then
		return RichText.normalize(list)
	elseif typeName == "number" then
		return (tostring(math.round(list * 1000) / 1000))
	elseif typeName == "boolean" then
		return (`<b>{list}</b>`)
	elseif typeName == "function" then
		return Formatter.toText(list(), p)
	end

	if typeName ~= "table" then
		return (tostring(list))
	end

	local v3 = list[3]
	local v4 = v2[v3] == true

	if v4 then
		local v5 = object3[list]

		if v5 ~= nil then
			if v5 == v then
				return nil
			end

			return v5
		end
	end

	local v5

	if v3 == "</font>" then
		v5 = (list[1] or "") .. concatParts(list[2], p) .. (list[3] or "")
	elseif v3 == "</text>" then
		v5 = concatParts(list[2], p)
	elseif v3 == "</br>" then
		v5 = "\n"
	elseif v3 == "</tree>" or v3 == "</div>" or v3 == "</cdiv>" then
		v5 = Formatter.toText(list[1], p)
	elseif v3 == "</agrid>" or v3 == "</alist>" or v3 == "</bubble>" then
		v5 = concatParts(list[4], p)
	elseif v3 == "</btn>" or v3 == "</chk>" or v3 == "</cmbo>" or v3 == "</combochild>" then
		v5 = Formatter.toText(list[4], p)
	elseif v3 == "</srvst>" then
		local serverStates = p and p.ServerStates
		v5 = Formatter.toText(serverStates and serverStates[list[2]], p)
	elseif v3 == "</robj>" then
		local replicatedHandles = p and p.ReplicatedHandles
		local v6 = replicatedHandles and replicatedHandles[list[1]]
		local v7

		if v6 and v6.Kind == "object" then
			v7 = v6.Value
		else
			v7 = list[4]
		end

		v5 = concatParts(v7, p)
	elseif v3 == "</ilog>" then
		local replicatedHandles = p and p.ReplicatedHandles
		local v6 = replicatedHandles and replicatedHandles[list[1]]
		local value

		if v6 and v6.Kind == "inline-log" then
			value = v6.Value
		else
			value = list[4]
		end

		v5 = not (value and value.Name) and "InlineLog" or tostring(value.Name)
	elseif v3 ~= "</stay>" then
		v5 = v3 == "</tip>" and "[?]" or tableToText(list, p)
	end

	if v4 and not Formatter.containsDynamic(list) then
		object3[list] = v5 or v
	end

	return v5
end

function Formatter.containsTag(list, p: string)
	if typeof(list) ~= "table" then
		return false
	end

	if list[3] == p then
		return true
	end

	for _, v3 in list do
		if Formatter.containsTag(v3, p) then
			return true
		end
	end

	return false
end

function Formatter.containsStay(p)
	return Formatter.containsTag(p, "</stay>")
end

local containsDynamicValue

containsDynamicValue = function(list, p)
	local typeName = typeof(list)

	if typeName == "function" then
		return true
	end

	if typeName ~= "table" then
		return false
	end

	local v3 = list[3]
	local v4 = typeof(v3) == "string"

	if v4 then
		local v5 = object2[list]

		if v5 ~= nil then
			return v5
		end
	end

	if p[list] then
		return false
	end

	p[list] = true

	if v3 == "</srvst>" or v3 == "</robj>" or v3 == "</ilog>" then
		if v4 then
			object2[list] = true
		end

		p[list] = nil
		return true
	else
		for _, v5 in list do
			if not containsDynamicValue(v5, p) then
				continue
			end

			if v4 then
				object2[list] = true
			end

			p[list] = nil
			return true
		end

		if v4 then
			object2[list] = false
		end

		p[list] = nil
		return false
	end
end

function Formatter.containsDynamic(p)
	return (containsDynamicValue(p, {}))
end

function Formatter.lineContainsDynamic(p)
	local v3 = object[p]

	if v3 ~= nil then
		return v3
	end

	local containsDynamic = Formatter.containsDynamic(p)
	object[p] = containsDynamic
	return containsDynamic
end

function Formatter.getRepeatCount(p)
	local metatable = getmetatable(p)

	if metatable and metatable.repeats then
		return metatable.repeats
	end

	return 0
end

return Formatter