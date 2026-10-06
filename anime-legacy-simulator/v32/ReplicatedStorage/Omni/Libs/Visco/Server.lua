local Players = game:GetService("Players")
local parent = script.Parent
local assets = parent.Assets
local use = assets.Events.Use
local _ = assets.Interface
local request = assets.Events.Request
local Utils = require(parent.Utils)
local flag = false
local v = {}
local v2 = {}
local callbacks = {}
local v3 = {
	Types = {},
	Kinds = {},
	Commands = {}
}
local Visco = {}
local class = {}

function class:ResolveTableEntry(items, p)
	local typeValuesByName = {}

	for k, item in items do
		if not Utils:CheckIfAllowed(item, p) then
			continue
		end

		local default = p[k]

		if default == nil then
			default = item.Default
		end

		if default == nil and item.Mode == "boolean" then
			default = false
		end

		local typeValue = class:ResolveTypeValue(item, default, p)

		if typeValue == nil and not item.Optional then
			return nil
		end

		if typeValue ~= nil then
			typeValuesByName[item.Name] = typeValue
		end
	end

	return typeValuesByName
end

function class:ResolveTypeValue(data, child, p)
	if data.Mode == "options" or data.Mode == "tables" then
		if not child or typeof(child) ~= "table" then
			return nil
		end

		if data.Mode == "options" then
			for _, item in child do
				if not item or typeof(item) ~= "string" then
					return nil
				end
			end
		end
	elseif data.Mode == "table" then
		if not child or typeof(child) ~= "table" then
			return nil
		end
	elseif data.Mode == "boolean" then
		if typeof(child) ~= "boolean" then
			return nil
		end
	elseif not child or typeof(child) ~= "string" then
		return nil
	end

	if data.Mode == "number" then
		child = Utils:Unformat(child)
	elseif data.Mode == "option" then
		local type = Utils:ResolveType(data.Type, p)
		local list = data.List or Utils:GetOptionsForType(v3, type)

		if not (list and table.find(list, child)) then
			return nil
		end

		if type == "player" then
			child = Players:FindFirstChild(child)
		end
	elseif data.Mode == "options" then
		local type = Utils:ResolveType(data.Type, p)
		local list = data.List or Utils:GetOptionsForType(v3, type)

		if not list then
			return nil
		end

		for _, item in child do
			if not table.find(list, item) then
				return nil
			end
		end
	elseif data.Mode == "table" then
		local propertiesForType = Utils:GetPropertiesForType(v3, data)

		if not propertiesForType then
			return nil
		end

		child = class:ResolveTableEntry(propertiesForType, child)
	elseif data.Mode == "tables" then
		local propertiesForType = Utils:GetPropertiesForType(v3, data)

		if not propertiesForType then
			return nil
		end

		local tableEntries = {}

		for _, item in child do
			if typeof(item) ~= "table" then
				continue
			end

			local tableEntry = class:ResolveTableEntry(propertiesForType, item)

			if tableEntry then
				table.insert(tableEntries, tableEntry)
			end
		end

		child = tableEntries
	end

	if child == nil then
		return nil
	end

	return child
end

function class:UseCommand(player, value: string, items)
	if not (player and player:IsA("Player")) then
		error((`INVALID PLAYER AT VISCO: {player}!`))
	end

	if typeof(value) ~= "string" then
		error((`INVALID COMMAND NAME AT VISCO: {value}!`))
	end

	if typeof(items) ~= "table" then
		error((`INVALID TYPES AT VISCO: {items}!`))
	end

	local command = v3.Commands[value]

	if not command then
		return
	end

	local v4 = {}

	for k, item in items do
		local v5 = tonumber(k)

		if v5 then
			v4[v5] = item
		end
	end

	local v5 = {}
	local v6 = {}

	for k, type in command.Types do
		local default = v4[k]

		if default == nil then
			default = type.Default
		end

		local typeValue = class:ResolveTypeValue(type, default, v4)

		if typeValue ~= nil then
			v5[k] = typeValue
		end
	end

	for k, type in command.Types do
		if v5[k] == nil and type.Default ~= nil then
			v5[k] = type.Default
		end

		if v5[k] == nil and type.Mode == "boolean" then
			v5[k] = false
		end
	end

	for i, type in ipairs(command.Types) do
		if not Utils:CheckIfAllowed(type, v5) then
			continue
		end

		local v7 = v5[i]

		if v7 == nil and not type.Optional then
			use:FireClient(player, false, (`Command {value} failed because argument '{type.Name}' was missing!`))
			return
		else
			v6[i] = v7
		end
	end

	local permission = command.Permission

	if permission and Visco:GetPermissionOfPlayer(player) < (v[permission] or 0) then
		use:FireClient(player, false, (`You don't have the needed permissions to use command '{value}'!`))
		return
	end

	local callback, v7 = command.Callback(player, table.unpack(v6, 1, #command.Types))

	if callback == false then
		use:FireClient(player, false, v7 or `Command '{value}' failed!`)
		return
	end

	for _, v8 in callbacks do
		v8(player, value, command, v5)
	end

	use:FireClient(player, true, v7 or `Command '{value}' has been used successfully!`)
end

function Visco.Initialize(_)
	if flag then
		error("VISCO HAS ALREADY BEEN INITIALIZED!")
	end

	flag = true
end

function Visco:RequestCommandsData()
	if flag then
		return v3
	end
end

function Visco.RegisterCommandsIn(_, instance)
	for _, moduleScript in instance:GetChildren() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		if v3.Commands[moduleScript.Name] then
			error((`DUPLICATED COMMAND AT VISCO: {moduleScript.Name}!`))
		end

		local module = require(moduleScript)

		if not module then
			continue
		end

		local callback = module.Callback

		if not callback or typeof(callback) ~= "function" then
			error((`INVALID COMMAND CALLBACK AT VISCO: {moduleScript.Name}!`))
		end

		v3.Commands[moduleScript.Name] = module
	end
end

function Visco.RegisterTypesIn(_, instance)
	for _, moduleScript in instance:GetChildren() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		if v3.Types[moduleScript.Name] then
			error((`DUPLICATED TYPE AT VISCO: {moduleScript.Name}!`))
		end

		local module = require(moduleScript)

		if module then
			v3.Types[moduleScript.Name] = module
		end
	end
end

function Visco.RegisterKindsIn(_, instance)
	for _, moduleScript in instance:GetChildren() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		if v3.Kinds[moduleScript.Name] then
			error((`DUPLICATED KIND AT VISCO: {moduleScript.Name}!`))
		end

		local module = require(moduleScript)

		if module then
			v3.Kinds[moduleScript.Name] = module
		end
	end
end

function Visco.CreatePermission(_, value: string, value2: number)
	if typeof(value) ~= "string" then
		error((`INVALID PERMISSION NAME AT VISCO: {value}!`))
	end

	if typeof(value2) ~= "number" then
		error((`INVALID PERMISSION LEVEL AT VISCO: {value2}!`))
	end

	if v[value] then
		warn((`DUPLICATED PERMISSION AT VISCO: {value}!`))
	else
		v[value] = value2
	end
end

function Visco.AddPermissionToPlayer(_, player, value: string)
	if not (player and player:IsA("Player")) then
		error((`INVALID PLAYER AT VISCO: {player}!`))
	end

	if typeof(value) ~= "string" then
		error((`INVALID PERMISSION NAME AT VISCO: {value}!`))
	end

	local v4 = v[value]

	if not v4 or v4 < Visco:GetPermissionOfPlayer(player) then
		return
	end

	v2[player.UserId] = v4
	player:SetAttribute("VISCO_USER", true)
end

function Visco:GetPermissionOfPlayer(p)
	return v2[p.UserId] or 0
end

function Visco.RegisterEndBack(_, callback)
	if typeof(callback) ~= "function" then
		error((`INVALID ENDBACK AT VISCO: {callback}!`))
	end

	table.insert(callbacks, callback)
end

use.OnServerEvent:Connect(function(p, value: string, p2)
	if not flag or (not value or typeof(value) ~= "string") then
		return
	end

	if not p2 or typeof(p2) ~= "table" then
		return
	end

	class:UseCommand(p, value, p2)
end)

request.OnServerInvoke = function(_)
	return Visco:RequestCommandsData()
end

Players.PlayerRemoving:Connect(function(player)
	local playerByUserId = Players:GetPlayerByUserId(player.UserId)

	if playerByUserId and playerByUserId ~= player then
		return
	end

	v2[player.UserId] = nil
end)
return Visco