local Compress = require(script.Parent.Compress)
local UTF8 = require(script.UTF8)
local HttpService = game:GetService("HttpService")
local v = {}
local Encoder = {}

for i = 0, 127 do
	v[i] = BrickColor.palette(i)
end

function Encoder:BrickColorToId(p)
	for i = 0, 127 do
		if v[i] == p then
			return i
		end
	end
end

function Encoder:RoundNumber(...)
	local v2 = { ... }

	for k, v3 in v2 do
		v2[k] = math.floor(tonumber(v3) * 1000) / 1000
	end

	return unpack(v2)
end

function Encoder:SafeString(value)
	if value:sub(1, 2):match("%d~") then
		value = value:sub(3)
	end

	if UTF8.validate(value) then
		return value
	end

	return ""
end

function Encoder:EncodeType(object2, instance)
	if typeof(object2) == "Vector3" then
		return "1~" .. self:RoundNumber(object2.X) .. "," .. self:RoundNumber(object2.Y) .. "," .. self:RoundNumber(object2.Z)
	end

	if typeof(object2) == "BrickColor" then
		return "2~" .. self:BrickColorToId(object2)
	end

	if typeof(object2) == "CFrame" then
		return "3~" .. table.concat({ self:RoundNumber(object2:components()) }, ",")
	end

	if typeof(object2) == "Color3" then
		return "4~" .. object2.r .. "," .. object2.g .. "," .. object2.b
	end

	if instance:IsA("IntValue") then
		return "5~" .. object2
	end

	if instance:IsA("NumberValue") then
		return "6~" .. self:RoundNumber(object2)
	end

	if instance:IsA("StringValue") then
		return self:SafeString(object2)
	end

	return object2
end

function Encoder:ToNumber(value, count)
	local v2 = { value:match(("([%d.-]+),"):rep(count):sub(1, -2)) }

	for k, v3 in v2 do
		v2[k] = tonumber(v3)
	end

	return unpack(v2)
end

function Encoder:DecodeType(value)
	if typeof(value) == "boolean" then
		return value, "BoolValue"
	end

	if value:sub(1, 2) == "1~" then
		return Vector3.new(self:ToNumber(value, 3)), "Vector3Value"
	end

	if value:sub(1, 2) == "2~" then
		return v[tonumber(value:sub(3))], "BrickColorValue"
	end

	if value:sub(1, 2) == "3~" then
		return CFrame.new(self:ToNumber(value, 12)), "CFrameValue"
	end

	if value:sub(1, 2) == "4~" then
		return Color3.new(self:ToNumber(value, 3)), "Color3Value"
	end

	if value:sub(1, 2) == "5~" then
		return tonumber(value:sub(3)), "IntValue"
	end

	if value:sub(1, 2) == "6~" then
		return tonumber(value:sub(3)), "NumberValue"
	end

	return value, "StringValue"
end

function Encoder:Flatten(p)
	return { p.Name, self:EncodeType(p.Value, p) }
end

function Encoder:Roughen(list, parent)
	local decodeType, v2 = self:DecodeType(list[2])
	local instance = Instance.new(v2)
	instance.Name = list[1]
	instance.Value = decodeType
	instance.Parent = parent
	return instance
end

function Encoder:Directory(p)
	return {
		p.Name,
		{}
	}
end

function Encoder:Encode(p)
	local main

	main = function(instance, list)
		for _, child in instance:GetChildren() do
			if child:IsA("Folder") then
				local directory = self:Directory(child)
				main(child, directory[2])
				table.insert(list, directory)
			elseif not child:IsA("Pants") then
				table.insert(list, self:Flatten(child))
			end
		end

		return list
	end

	return (main(p, {}))
end

function Encoder:Decode(p)
	local main

	main = function(folder, items)
		for _, item in items do
			if typeof(item[2]) == "table" then
				local folder2 = Instance.new("Folder")
				folder2.Name = item[1]
				folder2.Parent = folder
				main(folder2, item[2])
			else
				self:Roughen(item, folder)
			end
		end

		return folder
	end

	if typeof(p) == "table" then
		return (main(Instance.new("Folder"), p))
	end

	return (main(Instance.new("Folder"), HttpService:JSONDecode(Compress.decompress(p))))
end

return Encoder