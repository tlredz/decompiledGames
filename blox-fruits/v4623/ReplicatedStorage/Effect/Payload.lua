local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = RunService:IsClient() and RunService:IsRunning()
local Payload = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function makeEffectPlayer(character, p2: string)
	return {
		__EffectFakePlayer = true,
		Name = p2,
		DisplayName = p2,
		UserId = 0,
		Character = character
	}
end

local function getEffectPlayer(model, p)
	if v then
		return nil
	end

	if (p == "Player" or p == "player") and typeof(model) == "Instance" and model:IsA("Model") then
		return makeEffectPlayer(model, model.Name)
	end

	if type(model) ~= "table" then
		return nil
	end

	local model2 = rawget(model, "Character")

	if typeof(model2) ~= "Instance" or not model2:IsA("Model") then
		return nil
	end

	local success, result = pcall(function()
		return require(game.ServerStorage.Global)
	end)

	if not success or type(result) ~= "table" or type(result.enemies) ~= "table" or result.enemies[model2] ~= model then
		return nil
	end

	local v2 = rawget(model, "Data")
	local name = rawget(model, "Name")

	if type(name) ~= "string" and type(v2) == "table" then
		name = rawget(v2, "Name")
	end

	if type(name) ~= "string" then
		name = model2.Name
	end

	return makeEffectPlayer(model2, name)
end

local copyEffectData

copyEffectData = function(character, p2, p3)
	local effectPlayer = getEffectPlayer(character, p3)

	if effectPlayer then
		return effectPlayer
	end

	if type(character) ~= "table" then
		return character
	end

	if rawget(character, "__FakeType") ~= nil and character.GetEffectPart then
		return character:GetEffectPart()
	end

	if p2[character] then
		return nil
	end

	p2[character] = true
	local result = {}

	for k, v2 in next, character, nil do
		local v3 = copyEffectData(k, p2)

		if v3 == nil then
			continue
		end

		local v4 = copyEffectData(v2, p2, k)

		if v4 ~= nil then
			result[v3] = v4
		end
	end

	p2[character] = nil
	return result
end

local createStreamedObjects

createStreamedObjects = function(items, p)
	if p[items] then
		return
	end

	p[items] = true

	for k, item in pairs(items) do
		if typeof(item) == "table" then
			createStreamedObjects(item, p)
		elseif typeof(item) == "Instance" then
			local EncodeObj = require(ReplicatedStorage.Util.EncodeObj)
			items[k] = EncodeObj(item)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function decodeObject(p)
	local Util = require(ReplicatedStorage.Util)
	return Util.EncodeObj(p)
end

local getStreamedObjects

getStreamedObjects = function(items, list)
	local v2 = false

	for k, item in pairs(items) do
		if typeof(item) == "table" and item[3] == "__StreamedObject" then
			items[k] = decodeObject(item)

			if items[k] == nil then
				table.insert(list, k)
				v2 = true
			end
		elseif typeof(item) == "table" and getStreamedObjects(item, list) == false then
			v2 = true
		end
	end

	return v2 == false
end

local hydrateEffectFakePlayers

hydrateEffectFakePlayers = function(items, p)
	if type(items) ~= "table" or p[items] then
		return
	end

	p[items] = true

	if rawget(items, "__EffectFakePlayer") == true then
		local v2 = rawget(items, "Character")

		if typeof(v2) == "Instance" then
			setmetatable(items, {
				__index = function(_, p2)
					local success, result = pcall(function()
						return v2[p2]
					end)

					if not success then
						return nil
					end

					if type(result) == "function" then
						return function(_, ...)
							return result(v2, ...)
						end
					end

					return result
				end
			})
		end
	end

	for _, item in pairs(items) do
		hydrateEffectFakePlayers(item, p)
	end
end

function Payload.encode(p)
	if type(p) ~= "table" then
		return p
	end

	local v2 = copyEffectData(p, {})

	if not v then
		createStreamedObjects(v2, {})
	end

	return v2
end

function Payload.decode(list)
	local v2 = {}
	local v3

	if type(list) == "table" then
		if list[3] == "__StreamedObject" then
			list = decodeObject(list)
			v3 = list ~= nil
		else
			v3 = getStreamedObjects(list, v2)
		end

		if v3 then
			hydrateEffectFakePlayers(list, {})
		end
	else
		v3 = true
	end

	return list, v3, v2
end

function Payload.hydrateSourcePlayerProxy(p)
	local sourcePlayer = p.SourcePlayer
	setmetatable(p, {
		__index = function(_, p2)
			local v2 = sourcePlayer[p2]

			if not v2 then
				return nil
			end

			if type(v2) == "function" then
				return function(_, ...)
					return v2(sourcePlayer, ...)
				end
			end

			return v2
		end
	})
end

return Payload