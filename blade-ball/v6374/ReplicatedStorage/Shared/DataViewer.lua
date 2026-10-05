local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Shared.DeepCopy)
local v2 = require3(ReplicatedStorage2.Packages.Freeze)
local v3 = require3(ReplicatedStorage2.Packages.Charm)
local v4 = require3(script.VirtualRenderer)
local v5 = newproxy()

local function isArray(list)
	local v6 = table.maxn(list)
	return v6 ~= 0 and #list == v6 and not next(list, v6)
end

local function parseValueFromType(p: string, value)
	if p == "string" then
		return (tostring(value or ""))
	elseif p == "number" then
		return tonumber(value) or 0
	end

	if p == "table" then
		if type(value) == "table" then
			return value
		end

		return {}
	else
		if p ~= "boolean" then
			error((`Invalid Type "{p}"`))
			return
		end

		return value == nil or value == "" or value == true
	end
end

local fn

fn = function(data)
	local key = data.Key
	local v6 = {
		Name = data.Name or `[{tostring(data.Data)}]`,
		Data = data.Data,
		Status = data.Status or 0,
		Readonly = 0,
		RequestUpdate = 0
	}
	local readonly

	if data.Readonly == nil then
		readonly = false
	else
		readonly = data.Readonly
	end

	v6.Readonly = readonly
	v6.RequestUpdate = data.RequestUpdate
	local atom = v3.atom(v6.Status)
	local v8

	if type(v6.Data) == "table" then
		v8 = {
			Name = v6.Name,
			Value = v3.atom({}),
			Hidden = v3.atom(true),
			Collapsed = v3.atom(false),
			Status = atom,
			_userExpanded = false
		}
	else
		v8 = {
			Name = v6.Name,
			Value = v3.atom(v6.Data),
			Hidden = v3.atom(true),
			Status = atom
		}
	end

	v8.ParentFrame = v3.atom(nil)
	v8._initialStatus = v6.Status

	if key == nil then
		key = v6.Name
	end

	v8._key = key

	if type(v6.Data) ~= "table" then
		return v3.atom(v8)
	end

	local data2 = v6.Data
	local v9 = table.maxn(data2)
	local isArray2

	if v9 == 0 or #data2 ~= v9 then
		isArray2 = false
	else
		isArray2 = not next(data2, v9)
	end

	v8._isArray = isArray2

	function v8._addChild(p, p2)
		v8.Value(function(p3)
			local v11 = p3[p]

			if v11 then
				v3.untracked(v11).Value(p2)
				return p3
			end

			local clone = table.clone(p3)
			clone[p] = fn({
				Data = p2 == v5 and "nil" or p2,
				Name = tostring(p),
				Key = p,
				Status = p2 == v5 and -1 or data2[p] == nil and 1 or nil,
				Readonly = v6.Readonly,
				RequestUpdate = v6.RequestUpdate
			})
			return clone
		end)
	end

	local v11 = {}

	for k, v12 in data2 do
		v11[k] = fn({
			Data = v12 == v5 and "nil" or v12,
			Name = tostring(k),
			Key = k,
			Status = v12 == v5 and -1 or nil,
			Readonly = v6.Readonly,
			RequestUpdate = v6.RequestUpdate
		})
	end

	v8.Value(v11)
	return v3.atom(v8)
end

local calculateDeltaTables

calculateDeltaTables = function(p, items, p2)
	local v6 = p2 or utf8.char(0)

	if p == nil or p == v6 then
		return v6
	end

	local result = v(p)

	for k, _ in items do
		if result[k] == nil then
			result[k] = v6
		end
	end

	for k, v7 in result do
		if v7 == v6 then
			continue
		end

		if type(v7) == "table" and type(items[k]) == "table" then
			result[k] = calculateDeltaTables(v7, items[k], v6)
		elseif v2.Dictionary.equals(items[k], v7) then
			result[k] = nil
		end
	end

	if v2.Dictionary.count(result) == 0 then
		return nil
	end

	return result
end

local propertyToTable

propertyToTable = function(p)
	if p.Status() == -1 then
		return nil
	end

	local value = p.Value()

	if type(value) ~= "table" then
		return value
	end

	local clone = table.clone(value)

	for k, v6 in value do
		clone[k] = propertyToTable(v6())
	end

	return clone
end

local function parseSearchQuery(value: string)
	local v6 = string.match(value, "^%s*(.-)%s*$")
	local v7 = string.lower(v6)

	if v7 == "" then
		return nil
	end

	local v8, v9 = string.match(v7, "^(.-)%s*[=:]%s*(.*)$")
	local v10 = v8 or v7

	if v9 == nil or v9 == "" then
		v9 = nil
	end

	if v10 == "" and v9 == nil then
		return nil
	end

	return {
		Key = v10,
		Value = v9,
		IsPath = string.find(v10, ".", 1, true) ~= nil
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function containsPlain(value: string, p: string)
	return string.find(value, p, 1, true) ~= nil
end

local function matchesQuery(data, p: string, name: string, value: string?)
	local v6

	if data.Key == "" then
		v6 = true
	else
		if data.IsPath then
			name = p
		end

		v6 = containsPlain(name, data.Key)
	end

	if data.Value == nil then
		if v6 then
			return true
		end

		local v7 = not data.IsPath
		return v7 and value ~= nil and containsPlain(value, data.Key)
	else
		return v6 and value ~= nil and containsPlain(value, data.Value)
	end
end

local searchProperties

searchProperties = function(data, p, p2: string, flag: boolean?)
	local value = data.Value()
	local name = string.lower((tostring(data.Name or "")))

	if typeof(value) == "table" then
		assert(data.Collapsed)
		local v6 = p2 == ""
		local v7 = p == nil or not v6 and matchesQuery(p, p2, name, nil)
		local v8 = false
		local v9 = false

		for _, v10 in value do
			local untracked = v3.untracked(v10)
			local name2 = string.lower((tostring(untracked.Name or "")))

			if not v6 then
				name2 = `{p2}.{name2}`
			end

			local v11, v12 = searchProperties(untracked, p, name2, flag or v7)
			v8 = v8 or v11
			v9 = v9 or v12
		end

		local v10 = v7 or v9
		local v11 = flag == true or (v10 or v8)
		data.Hidden(not v11)

		if p == nil then
			data.Collapsed(data._userExpanded == true)
		else
			data.Collapsed(v9)
		end

		return v11, v10
	else
		local v6 = p == nil or matchesQuery(p, p2, name, string.lower((tostring(value or ""))))
		local selected = flag == true or v6
		data.Hidden(not selected)
		return selected, v6
	end
end

local function CreateSearchHandler(callback, invalidate)
	local v6 = ""
	local count = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function runSearch(p: string)
		v3.batch(function()
			searchProperties(callback(), parseSearchQuery(p), "")
		end)
		invalidate()
	end

	local function applySearch(text: string)
		v6 = text
		count += 1
		local v7 = count

		if parseSearchQuery(text) ~= nil then
			task.delay(0.35, function()
				if v7 == count then
					runSearch(v6) -- equivalent call inferred; original call site unknown
				end
			end)
			return
		end

		runSearch(text) -- equivalent call inferred; original call site unknown
	end

	return table.freeze({
		search = applySearch,
		connectTo = function(instance)
			applySearch(instance.Text)
			return instance:GetPropertyChangedSignal("Text"):Connect(function()
				applySearch(instance.Text)
			end)
		end
	})
end

local v6 = utf8.char(0)
return {
	NIL_KEY = v5,
	new = function(holder, p2, p3)
		local atom = v3.atom({
			HasChanges = false,
			Data = p2
		})
		local readonly

		if type(p3) == "table" then
			readonly = p3.Readonly == true
		else
			readonly = false
		end

		local v8 = nil

		local function requestUpdate()
			local v9 = propertyToTable(v8())
			local v10 = calculateDeltaTables(v9, p2, v6)
			local delta

			if v10 ~= v6 then
				delta = v10
			end

			atom({
				Data = v9,
				Delta = delta,
				HasChanges = v10 ~= nil
			})
		end

		local v10 = {
			Data = p2,
			Name = 0,
			Readonly = 0,
			RequestUpdate = 0
		}
		local name

		if type(p3) == "table" then
			name = p3.Name
		end

		v10.Name = name
		v10.Readonly = readonly
		v10.RequestUpdate = requestUpdate
		v8 = fn(v10)
		local renderer = v4({
			Holder = holder,
			Root = v8,
			Readonly = readonly,
			RequestUpdate = requestUpdate,
			ParseValue = parseValueFromType
		})
		v3.batch(function()
			searchProperties(v8(), nil, "")
		end)
		renderer.Invalidate()
		return {
			delta = atom,
			property = v8,
			renderer = renderer,
			Destroy = renderer.Destroy,
			searchHandler = CreateSearchHandler(v8, renderer.Invalidate)
		}
	end
}