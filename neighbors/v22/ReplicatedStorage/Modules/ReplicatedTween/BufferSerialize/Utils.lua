local IdUtils = require(script.IdUtils)
local Properties = require(script.Properties)
local v = {
	"table",
	"number",
	"string",
	"boolean",
	"CFrame",
	"Vector3",
	"Vector2",
	"Vector3int16",
	"Vector2int16",
	"Instance",
	"Color3",
	"EnumItem"
}
local v2 = {
	boolean = 1,
	CFrame = 22,
	Vector3 = 12,
	Vector2 = 8,
	Vector3int16 = 6,
	Vector2int16 = 4,
	Color3 = 3,
	EnumItem = 3
}
local v3 = {
	u8 = 1,
	i8 = 1,
	u16 = 2,
	i16 = 2,
	u32 = 4,
	i32 = 4,
	f32 = 4,
	f64 = 8
}

local function nully(p, p2)
	if p == nil then
		return p2
	end

	return p
end

local getDataInfo

getDataInfo = function(instance, data)
	local typeName = typeof(instance)
	local index = table.find(v, typeName)
	local v4 = v2[typeName]
	assert(index ~= nil, (`Unsupported datatype: {typeName}`))

	if typeName == "string" then
		return index, #{ instance:byte(1, instance:len()) } + 1
	end

	if typeName == "table" then
		local total = 0

		for k, v5 in instance do
			local v6

			if data.keys then
				local v7
				v7, v6 = getDataInfo(k, data)
				_ = v7
			else
				v6 = -1
			end

			local v7, v8 = getDataInfo(v5, data)
			total += v6 + 1 + (1 + v8)
		end

		return index, total + 1
	else
		if typeName == "number" then
			return index, v3[data.numbersAs]
		end

		if typeName ~= "Instance" then
			return index, v4
		end

		if not data.writeInstanceAsCopy then
			v4 = 2
			return index, v4
		end

		local v5, v6 = getDataInfo({
			instance.ClassName,
			instance.Name,
			instance:GetAttributes(),
			instance:GetTags(),
			Properties.getProperties(instance),
			instance:GetChildren()
		}, data)
		_ = v5
		return index, v6
	end
end

local Utils = {}
Utils.waitForId = IdUtils.waitforid
Utils.validateId = IdUtils.validateid
Utils.TYPE_SIGNATURES = v
Utils.TYPE_FORMATS = v2
Utils.NUMBER_SIZES = v3
Utils.getDataInfo = getDataInfo

function Utils.fillreadopt(options)
	local v4 = options or {}
	local errorOnException = v4.errorOnException

	if errorOnException == nil then
		errorOnException = false
	end

	local keys = v4.keys
	local v5 = {
		errorOnException = errorOnException,
		keys = keys == nil or keys,
		readInstanceAsCopy = 0,
		numbersAs = 0
	}
	local readInstanceAsCopy = v4.readInstanceAsCopy

	if readInstanceAsCopy == nil then
		readInstanceAsCopy = false
	end

	v5.readInstanceAsCopy = readInstanceAsCopy
	local numbersAs = v4.numbersAs
	v5.numbersAs = numbersAs == nil and "i32" or numbersAs
	return v5
end

function Utils.fillwriteopt(options)
	local v4 = options or {}
	local errorOnException = v4.errorOnException

	if errorOnException == nil then
		errorOnException = false
	end

	local keys = v4.keys
	local v5 = {
		errorOnException = errorOnException,
		keys = keys == nil or keys,
		writeInstanceAsCopy = 0,
		numbersAs = 0
	}
	local writeInstanceAsCopy = v4.writeInstanceAsCopy

	if writeInstanceAsCopy == nil then
		writeInstanceAsCopy = false
	end

	v5.writeInstanceAsCopy = writeInstanceAsCopy
	local numbersAs = v4.numbersAs
	v5.numbersAs = numbersAs == nil and "i32" or numbersAs
	return v5
end

Utils.Properties = Properties
return Utils