local Players = game:GetService("Players")
local Option = require(game.ReplicatedStorage.Packages.Option)
local Result = require(game.ReplicatedStorage.Packages.Result)
local Error = require(game.ReplicatedStorage.Packages.Error)
local Vec = require(game.ReplicatedStorage.Packages.Vec)
require(game.ReplicatedStorage.Packages.VecDeque)
require(game.ReplicatedStorage.Packages.HashMap)

function cleanKeyword(value: string)
	return (value:lower():gsub("/", ""):gsub("--", ""):gsub("-", "_"):gsub("%s", ""))
end

function cleanKeywordVec(object)
	local emptyMut = Vec.emptyMut()
	object:forEach(function(p)
		local v = cleanKeyword(p)

		if emptyMut:contains(v) == false then
			emptyMut:push(v)
		end
	end)
	return emptyMut:freeze()
end

function cleanPath(value: string)
	return (value:lower():gsub("%s", ""):gsub("%p", ""))
end

function newCommandStruct(name: string, p2: string, permission: string, p4, p5, description, parameters, callback)
	return {
		Name = name,
		Command = cleanKeyword(p2),
		Permission = permission,
		Group = Option.match(p4, function(p8)
			return Option.some(cleanPath(p8))
		end, function()
			return Option.none()
		end),
		Aliases = cleanKeywordVec(p5),
		Description = description,
		Parameters = parameters,
		Callback = callback
	}
end

function newParameterStruct(p: string, p2, isOptional: boolean, description, p4)
	return {
		Name = cleanKeyword(p),
		Aliases = cleanKeywordVec(p2),
		IsOptional = isOptional,
		Description = description,
		Type = p4
	}
end

local class = {}
class.__index = class
local class2 = {}
class2.__index = class2

function class2.Builder(data)
	local v = newParameterStruct(data.Name, data.Aliases, data.IsOptional, data.Description, data.Type)
	setmetatable(v, class)
	table.freeze(v)
	return v
end

function class2.GetValue(data, p: string)
	local v = cleanKeyword(p)

	if data.Type.Type ~= "Player" then
		return
	end

	local player = Players:FindFirstChild(v)

	if not player and tonumber(v) then
		player = Players
	end

	if player == nil then
		if data.IsOptional then
			return Result.ok(Option.none())
		end

		return Result.err(Error.new("ParameterError"):body(data):description((`no player found at "{v}" for parameter "{data.Name}"`)):build())
	elseif player:IsA("Player") then
		return Result.ok(Option.some((table.freeze({
			Type = "Player",
			Value = player
		}))))
	else
		return Result.err(Error.new("ParameterError"):body(data):description((`expected player for "{v}", found "{player.ClassName}" for parameter "{data.Name}"`)):build())
	end
end

function class2.IsNameMatch(p, p2: string)
	local v = cleanKeyword(p2)

	if v == p.Name then
		return true
	end

	for _, v2 in ipairs(p.Aliases:drain()) do
		if v2 == v then
			return true
		end
	end

	return false
end

function class.Build(data)
	local v = newParameterStruct(data.Name, data.Aliases, data.IsOptional, data.Description, data.Type)
	setmetatable(v, class2)
	table.freeze(v)
	return v
end

function class.SetDescription(data, p: string)
	return class2.Builder(newParameterStruct(data.Name, data.Aliases, data.IsOptional, Option.some(p), data.Type))
end

function class.SetIsOptional(data, flag: boolean)
	return class2.Builder(newParameterStruct(data.Name, data.Aliases, flag, data.Description, data.Type))
end

function class:InsertAlias(p: string)
	if self.Aliases:contains(p) then
		return self
	end

	local mut = self.Aliases:asMut()
	mut:push(p)
	return class2.Builder(newParameterStruct(self.Name, mut:freeze(), self.IsOptional, self.Description, self.Type))
end

function class.ExtendAliases(object, list)
	for _, v in ipairs(list) do
		object = object:InsertAlias(v)
	end

	return object
end

local class3 = {}
class3.__index = class3
local class4 = {}
class4.__index = class4

function class4.Builder(data)
	local v = newCommandStruct(
		data.Name,
		data.Command,
		data.Permission,
		data.Group,
		data.Aliases,
		data.Description,
		data.Parameters,
		data.Callback
	)
	setmetatable(v, class3)
	table.freeze(v)
	return v
end

function class4.Invoke(_, _: string) end

function class3.Build(data)
	local v = newCommandStruct(
		data.Name,
		data.Command,
		data.Permission,
		data.Group,
		data.Aliases,
		data.Description,
		data.Parameters,
		data.Callback
	)
	setmetatable(v, class4)
	table.freeze(v)
	return v
end

function class3.SetPermission(data, p: string)
	return class4.Builder(newCommandStruct(
		data.Name,
		data.Command,
		p,
		data.Group,
		data.Aliases,
		data.Description,
		data.Parameters,
		data.Callback
	))
end

function class3.SetDescription(data, p: string)
	return class4.Builder(newCommandStruct(
		data.Name,
		data.Command,
		data.Permission,
		data.Group,
		data.Aliases,
		Option.some(p),
		data.Parameters,
		data.Callback
	))
end

function class3.SetGroup(data, p: string)
	return class4.Builder(newCommandStruct(
		data.Name,
		data.Command,
		data.Permission,
		Option.some(p),
		data.Aliases,
		data.Description,
		data.Parameters,
		data.Callback
	))
end

function class3:InsertAlias(p: string)
	if self.Aliases:contains(p) then
		return self
	end

	local mut = self.Aliases:asMut()
	mut:push(p)
	return class4.Builder(newCommandStruct(
		self.Name,
		self.Command,
		self.Permission,
		self.Group,
		mut:freeze(),
		self.Description,
		self.Parameters,
		self.Callback
	))
end

function class3.ExtendAliases(object, list)
	for _, v in ipairs(list) do
		object = object:InsertAlias(v)
	end

	return object
end

local AdminCommand = {}
AdminCommand.Command = {
	fromProcessedLegacy = function(_: string, _) end,
	fromLegacy = function(_: string, _: number, _, _) end,
	new = function(_: string, _: string, _) end
}
AdminCommand.Parameter = {
	Player = {
		new = function(_: string) end
	},
	Object = {
		new = function(_: string, _: string) end
	}
}

function AdminCommand.isCommand(p)
	return typeof(p) == "table" and getmetatable(p) == class4
end

function AdminCommand.isCommandBuilder(p)
	return typeof(p) == "table" and getmetatable(p) == class3
end

function AdminCommand.isParameter(p)
	return typeof(p) == "table" and getmetatable(p) == class2
end

function AdminCommand.isParameterBuilder(p)
	return typeof(p) == "table" and getmetatable(p) == class
end

return AdminCommand