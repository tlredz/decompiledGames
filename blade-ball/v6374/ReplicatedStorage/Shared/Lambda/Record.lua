local v = newproxy(true)

getmetatable(v).__tostring = function()
	return "RecordIdentifier"
end

local v2 = newproxy(true)

getmetatable(v2).__tostring = function()
	return "Valid"
end

local v3 = newproxy(true)

getmetatable(v3).__tostring = function()
	return "Invalid"
end

local Record = {}
local Promise = require(script.Parent.Promise)

function Record.Evaluate(value)
	if typeof(value) == "table" and value[v] or not value then
		value = value.Value
	end

	return value
end

function Record.Try(p, callback, callback2)
	if p.status ~= v3 then
		callback(p)
		return p
	end

	if callback2 then
		callback2(p.logs)
	end

	return p
end

function Record.Catch(p, callback)
	if p.Status == v3 then
		callback(p)
	end

	return p
end

function Record.Promisify(p)
	return p.Status == v3 and Promise.reject(p.Value) or Promise.resolve(p.Value)
end

function Record.Morph(p, ...)
	if p.status == v3 then
		return Record.Update(p, "Record rejected from Morph chain: record invalid")
	end

	local v4 = Record.Update(p, "Morph chain began")

	for k, v5 in next, { ... }, nil do
		v4 = v5(v4)

		if typeof(v4) == "table" and v4[v] then
			if v4.status == v3 then
				return Record.Update(v4, (`Merge chain ended prematurely at {k}: record invalidated`))
			end
		else
			error((`Function #{k} in Morph chain returned a non-record value {v4}`))
		end
	end

	return Record.Update(v4, "Morph chain ended successfully")
end

function Record.Record(validValue, p2: string, status)
	local v4 = {
		Value = validValue,
		ValidValue = validValue,
		Logs = { p2 },
		Status = status,
		[v] = true
	}
	table.freeze(v4)
	return v4
end

function Record.Update(data, p: string, p2)
	if typeof(data) ~= "table" or not data[v] then
		return (Record.Record(data, p, v2))
	end

	local clone = table.clone(data.Logs)
	table.insert(clone, p)
	clone[50] = nil
	table.freeze(clone)
	local v4 = {
		Value = p2 or data.value
	}
	local validValue

	if data.Status == v3 then
		validValue = data.ValidValue or data
	else
		validValue = data
	end

	v4.ValidValue = validValue
	v4.Logs = clone
	v4.Status = data.status
	v4[v] = true
	table.freeze(v4)
	return v4
end

function Record.Modify(p, p2: string, callback)
	local clone = table.clone(p)
	clone.Value = callback(clone.Value)
	table.insert(clone.Logs, p2)
	clone.Logs[50] = nil
	table.freeze(clone)
	return clone
end

function Record.Invalidate(data, p: string)
	if typeof(data) ~= "table" or not data[v] then
		return (Record.Record(data, "Invalidated: " .. p, v3))
	end

	local clone = table.clone(data.Logs)
	table.insert(clone, p)
	clone[50] = nil
	table.freeze(clone)
	local v4 = {
		Value = data.value,
		ValidValue = data.ValidValue,
		Status = v3,
		Logs = clone,
		[v] = true
	}
	table.freeze(v4)
	return v4
end

function Record.Validate(p, p2: string)
	local clone = table.clone(Record.Update(p, "Validated: " .. p2))
	clone.status = v2
	clone.ValidValue = clone.Value
	table.freeze(clone)
	return clone
end

Record.Valid = v2
Record.Invalid = v3
return Record