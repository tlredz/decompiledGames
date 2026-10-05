local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local bindableEvent = Instance.new("BindableEvent")
local v = {
	Changed = bindableEvent.Event
}
local replicateds = {}
local replicated = FastFlags.Replicated("Game.Balance.Enabled", function(p)
	assert(type(p) == "boolean")
	return p
end, true)
local copy

copy = function(items)
	if type(items) ~= "table" then
		return items
	end

	local result = {}

	for k, item in items do
		result[k] = copy(item)
	end

	return result
end

local storable

storable = function(list)
	if type(list) ~= "table" then
		return list
	end

	local count = 0
	local v2 = true

	for k in list do
		count += 1

		if type(k) ~= "number" or k % 1 ~= 0 or k < 1 then
			v2 = false
		end
	end

	local v3 = v2 and count == #list
	local result = {}

	for k, v4 in list do
		if not v3 then
			k = tostring(k)
		end

		result[k] = storable(v4)
	end

	return result
end

local validate

validate = function(items, value, p)
	assert(type(items) == type(value), p .. " has the wrong type")

	if type(value) == "number" then
		local v2

		if items == items then
			v2 = math.abs(items) < 1e999
		else
			v2 = false
		end

		assert(v2, p .. " must be finite")
		assert(value < 0 or items >= 0, p .. " must be nonnegative")
	elseif type(value) == "table" then
		for k, item in items do
			local v2

			if value[k] == nil then
				v2 = tonumber(k) or k
			else
				v2 = k
			end

			assert(value[v2] ~= nil, p .. " has an unknown key " .. tostring(k))
			validate(item, value[v2], p .. "." .. tostring(k))
		end
	elseif type(value) == "string" then
		assert(items == value, p .. " identifies content and cannot be renamed")
	end
end

local selectFields

selectFields = function(items, items2)
	if items2 == true then
		if type(items) ~= "table" then
			return items
		end

		local result = {}

		for k, item in items do
			if not (type(item) == "number" or type(item) == "table" or type(item) == "string") then
				continue
			end

			result[k] = selectFields(item, true)
		end

		return result
	else
		local result = {}

		for k, item in items2 do
			if items[k] ~= nil then
				result[k] = selectFields(items[k], item)
			end
		end

		return result
	end
end

local cloneSelected

cloneSelected = function(p, items)
	local clone = table.clone(p)

	for k, item in items do
		if type(item) == "table" then
			clone[k] = cloneSelected(p[k], item)
		end
	end

	return clone
end

local apply

apply = function(p, items, p2)
	for k, item in items do
		local v2 = p2[k]

		if v2 == nil then
			v2 = p2[tostring(k)]
		end

		if type(item) == "table" then
			apply(p[k], item, v2 or {})
		else
			if v2 == nil then
				v2 = item
			end

			p[k] = v2
		end
	end
end

function v.Bind(p, items, p2, p3, callback)
	assert(replicateds[p] == nil, "Duplicate balance key " .. p)
	local v2 = {}

	if p3 then
		for k, item in items do
			v2[k] = selectFields(item, p2)
		end
	else
		v2 = selectFields(items, p2)
	end

	local selected = cloneSelected(items, v2)

	local function assertion(p4)
		validate(p4, v2, p)

		if callback then
			local v3 = copy(v2)
			apply(v3, v2, p4)
			callback(v3)
		end

		return p4
	end

	local replicated2 = FastFlags.Replicated(p, assertion, (storable(v2)))
	replicateds[p] = replicated2

	local function refresh()
		apply(selected, v2, not replicated:Get() and {} or replicated2:Get())
		bindableEvent:Fire(p)
	end

	replicated2.Changed:Connect(refresh)
	replicated.Changed:Connect(refresh)
	refresh()
	return selected
end

return table.freeze(v)