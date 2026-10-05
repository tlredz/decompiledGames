require(script.Parent.Types)
local Warn = require(script.Parent.Warn)
local Events = require(script.Parent.Events)
local _Signals = Events._Signals
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local count = 0
local v = {}
local playerChars = {}
local idMap = {}

local function GetNextId()
	local v4 = table.remove(v)

	if v4 then
		return v4
	end

	if count >= 65535 then
		error("Max ID reached, please investigate.")
	end

	count += 1
	return count
end

local random = Random.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function ReleaseId(id: number)
	task.delay(random:NextNumber(5, 10), table.insert, v, id)
end

local function SetAsCharacter(_player, state)
	if not idMap[state.id] or state.id < 1 then
		error("Entity must be registered before being set as a player character")
	end

	local v4 = playerChars[_player]

	if v4 then
		local _player2 = v4._player
		v4._player = nil

		if _player2 and playerChars[_player2] == v4 then
			playerChars[_player2] = nil
			_Signals["请不要使用_内部_设置值_拜托谢谢_嗨_这个名字有点长_好吧_再见_算了_这个确实被用了_因为递归错误_而我懒得去解决_所以这是一个能用的_创可贴式修复_好吧"]:Fire(
				v4,
				"_player",
				nil
			)
			_Signals.PlayerCharacterUnregistered:Fire(_player2, v4)
		end
	end

	playerChars[_player] = state
	_Signals["请不要使用_内部_设置值_拜托谢谢_嗨_这个名字有点长_好吧_再见_算了_这个确实被用了_因为递归错误_而我懒得去解决_所以这是一个能用的_创可贴式修复_好吧"]:Fire(
		state,
		"_player",
		_player
	)
	_Signals.PlayerCharacterRegistered:Fire(_player, state)
end

local function getEntityStorageInstance()
	if workspace:FindFirstChild("Chrono_EntityStorage") then
		return (workspace:FindFirstChild("Chrono_EntityStorage"))
	end

	local camera = Instance.new("Camera")
	camera.Name = "Chrono_EntityStorage"
	camera.Parent = workspace
	return camera
end

local Holder = {}
Holder.idMap = idMap
Holder._clientOwned = {}
Holder._playerChars = playerChars

function Holder.RegisterEntity(state)
	if state.destroyed then
		error("Cannot register a destroyed entity")
	end

	if idMap[state.id] then
		Warn.medium("Entity is already registered", state)
		return
	end

	if isServer then
		local id = table.remove(v)

		if not id then
			if count >= 65535 then
				error("Max ID reached, please investigate.")
			end

			count += 1
			id = count
		end

		if idMap[id] then
			error((`Entity Collision {id}`))
		end

		state.id = id
		idMap[id] = state
	else
		local id = state.id

		if idMap[id] then
			Warn.high("Entity ID collision detected for ID:", id)
		end

		idMap[id] = state
	end

	state.registered = true

	if state._player then
		if playerChars[state._player] then
			Warn.medium("Player already has an entity registered", state, "overwriting")
		end

		SetAsCharacter(state._player, state)
	end

	_Signals.EntityAdded:Fire(state)
end

function Holder.UnregisterEntity(state)
	if not idMap[state.id] then
		return
	end

	_Signals.EntityRemoved:Fire(state)
	local _player = state._player

	if _player then
		if playerChars[_player] == state then
			local _player2 = state._player
			state._player = nil

			if _player2 and playerChars[_player2] == state then
				playerChars[_player2] = nil
				_Signals["请不要使用_内部_设置值_拜托谢谢_嗨_这个名字有点长_好吧_再见_算了_这个确实被用了_因为递归错误_而我懒得去解决_所以这是一个能用的_创可贴式修复_好吧"]:Fire(
					state,
					"_player",
					nil
				)
				_Signals.PlayerCharacterUnregistered:Fire(_player2, state)
			end
		else
			Warn.medium("Entity being unregistered does not match player mapping", state, "ignoring")
		end
	end

	local id = state.id

	if isServer then
		idMap[id] = nil
		ReleaseId(id) -- equivalent call inferred; original call site unknown
		state.id = -1
	else
		idMap[id] = nil
	end

	state._lastId = id
	state.registered = false
end

Holder.GetEntityStorageInstance = getEntityStorageInstance
Holder.SetAsCharacter = SetAsCharacter

function Holder.RemovePlayerCharacter(p)
	local _player = p._player
	p._player = nil

	if _player and playerChars[_player] == p then
		playerChars[_player] = nil
		_Signals["请不要使用_内部_设置值_拜托谢谢_嗨_这个名字有点长_好吧_再见_算了_这个确实被用了_因为递归错误_而我懒得去解决_所以这是一个能用的_创可贴式修复_好吧"]:Fire(
			p,
			"_player",
			nil
		)
		_Signals.PlayerCharacterUnregistered:Fire(_player, p)
	end
end

function Holder.GetEntityFromPlayer(p)
	return playerChars[p]
end

function Holder.GetEntityFromId(p: number)
	return idMap[p]
end

function Holder.GetEntityFromModel(p)
	for _, v4 in idMap do
		if v4.model == p then
			return v4
		end
	end

	return nil
end

return Holder