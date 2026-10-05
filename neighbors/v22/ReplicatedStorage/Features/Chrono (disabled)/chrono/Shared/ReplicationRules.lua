local shared = script.Parent.Parent.Shared
local Warn = require(script.Parent.Warn)
require(shared.Types)
local Holder = require(shared.Holder)
local v = {}

local function GetIdFrom(instance)
	if typeof(instance) == "number" then
		return instance
	end

	if typeof(instance) == "table" then
		return instance.id
	end

	if typeof(instance) ~= "Instance" then
		return nil
	end

	if instance:IsA("Player") then
		local entity = Holder.GetEntityFromPlayer(instance)
		return entity and entity.id or nil
	end

	if not instance:IsA("Model") then
		return nil
	end

	local entity = Holder.GetEntityFromModel(instance)
	return entity and entity.id or nil
end

local function CompileRule(p)
	local filterType = p.filterType
	local v2 = {}

	for _, v3 in p.filterPlayers or {} do
		v2[v3] = true
	end

	if filterType == "exclude" then
		if next(v2) == nil then
			return function()
				return true
			end
		end

		return function(_, p2)
			return v2[p2] ~= true
		end
	elseif next(v2) == nil then
		return function()
			return false
		end
	else
		return function(_, p2)
			return v2[p2] == true
		end
	end
end

local ReplicationRules = {}

function ReplicationRules.SetReplicationRule(p, callback)
	local idFrom = GetIdFrom(p)

	if not idFrom then
		Warn.low("no id", p)
	elseif callback == nil then
		v[idFrom] = nil
	elseif typeof(callback) == "function" then
		v[idFrom] = callback
	else
		v[idFrom] = CompileRule(callback)
	end
end

function ReplicationRules.Allows(p, p2)
	local v2 = v[p.id]

	if not v2 then
		return true
	end

	local entity = Holder.GetEntityFromPlayer(p2)
	return v2(p, p2, entity and entity.id or nil)
end

function ReplicationRules.Include(filterPlayers)
	return (CompileRule({
		filterType = "include",
		filterPlayers = filterPlayers
	}))
end

function ReplicationRules.Exclude(filterPlayers)
	return (CompileRule({
		filterType = "exclude",
		filterPlayers = filterPlayers
	}))
end

return ReplicationRules