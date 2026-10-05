local Players = game:GetService("Players")
local Network = require(script.Parent.Parent.Internal.Network)
local Signal = require(script.Parent.Parent.Parent.Signal)
local Utils = require(script.Parent.Parent.Internal.Utils)
local Signals = require(script.Parent.Parent.Internal.Signals)
require(script.Parent.Parent.Internal.Types)
local Freeze = require(script.Parent.Parent.Parent.Freeze)
local count = 0
local _ids = {}
local ServerReplion = {}
ServerReplion.__index = ServerReplion

function ServerReplion.new(data)
	assert(type(data.Channel) == "string", (`"Channel" expected string, got {type(data.Channel)}`))
	assert(data.ReplicateTo, "ReplicateTo is required!")
	local replicateTo = data.ReplicateTo
	local id = nil

	if count + 1 > 1114111 then
		if #_ids > 0 then
			id = table.remove(_ids, 1)
		end
	else
		count += 1
		id = count
	end

	assert(id, "No available ID!")
	assert(id <= 1114111, (`ID limit reached! You already have {1114111} ServerReplions!`))
	local object = setmetatable({
		Data = data.Data,
		Channel = data.Channel,
		Tags = not data.Tags and {} or data.Tags,
		ReplicateTo = replicateTo,
		_id = id,
		_packedId = utf8.char(id),
		_beforeDestroy = Signal.new(),
		_signals = Signals.new()
	}, ServerReplion)
	Network.sendTo(replicateTo, "Added", object:_serialize())
	return object
end

function ServerReplion.__tostring(p)
	local channel = p.Channel
	local replicateTo = p.ReplicateTo

	if type(replicateTo) == "table" then
		local names = {}

		for k, item in replicateTo do
			names[k] = item.Name
		end

		replicateTo = table.concat(names, ", ")
	elseif typeof(replicateTo) == "Instance" then
		replicateTo = replicateTo.Name
	end

	return (`Replion<{channel}:{replicateTo}>`)
end

function ServerReplion:_serialize()
	return {
		self._packedId,
		self.Channel,
		self.Data,
		self.ReplicateTo,
		self.Tags
	}
end

function ServerReplion:BeforeDestroy(on_beforeDestroy)
	return self._beforeDestroy:Connect(on_beforeDestroy)
end

function ServerReplion:OnDataChange(p2)
	return self._signals:Connect("onDataChange", "__root", p2)
end

function ServerReplion:OnChange(p2, p3)
	return self._signals:Connect("onChange", p2, p3)
end

function ServerReplion:OnArrayInsert(p2, p3)
	return self._signals:Connect("onArrayInsert", p2, p3)
end

function ServerReplion:OnArrayRemove(p2, p3)
	return self._signals:Connect("onArrayRemove", p2, p3)
end

function ServerReplion:OnDescendantChange(p2, p3)
	return self._signals:Connect("onDescendantChange", p2, p3)
end

function ServerReplion:SetReplicateTo(player)
	local v

	if player == "All" or type(player) == "table" then
		v = true
	elseif typeof(player) == "Instance" then
		v = player:IsA("Player")
	else
		v = false
	end

	assert(v, "ReplicateTo must be a Player, a table of Players or \"All\"")
	local replicateTo = self.ReplicateTo

	if replicateTo == player then
		return
	end

	local players

	if replicateTo == "All" then
		players = Players:GetPlayers()
	else
		players = type(replicateTo) ~= "table" and { player } or replicateTo
	end

	local players2

	if player == "All" then
		players2 = Players:GetPlayers()
	else
		players2 = type(player) ~= "table" and { player } or player
	end

	for _, player2 in players do
		if not table.find(players2, player2) then
			Network.sendTo(player2, "Removed", self._packedId)
		end
	end

	for _, player2 in players2 do
		if not table.find(players, player2) then
			Network.sendTo(player, "Added", self:_serialize())
		end
	end

	self.ReplicateTo = player
	Network.sendTo(player, "UpdateReplicateTo", self._packedId, player)
end

function ServerReplion:Set(p, p2)
	local pathTable = Utils.getPathTable(p)
	local v = Freeze.Dictionary.getIn(self.Data, pathTable)

	if v and Freeze.Dictionary.equals(v, p2) then
		return v
	end

	local v2 = Freeze.Dictionary.setIn(self.Data, pathTable, p2)
	local data = self.Data
	self.Data = v2
	self._signals:FireEvent("onDataChange", "__root", v2, pathTable)
	self._signals:FireChange(p, v2, data)
	Network.sendTo(self.ReplicateTo, "Set", self._packedId, p, p2)
	return p2
end

function ServerReplion:Update(p, p2)
	local v

	if p2 then
		v = Utils.getPathTable(p)
	else
		v = nil
	end

	local filtered = Freeze.Dictionary.filter(p2 or p, function(p3, p4)
		local v2

		if v then
			v2 = Freeze.Dictionary.getIn(self.Data, v)
		else
			v2 = self.Data[p4]
		end

		return not Freeze.Dictionary.equals(v2, p3)
	end)

	if Freeze.isEmpty(filtered) then
		return
	end

	local data = self.Data

	if v then
		local mergeIn = Freeze.Dictionary.mergeIn(self.Data, v, filtered)
		self.Data = mergeIn
		self._signals:FireEvent("onDataChange", "__root", mergeIn, v)

		for k, v2 in filtered do
			local v3 = Freeze.List.push(v, k)
			local v4 = Freeze.Dictionary.getIn(data, v3)
			self._signals:FireEvent("onChange", v3, Utils.getValue(v2), v4)
		end

		self._signals:FireChange(p, mergeIn, data)
	else
		local merged = Freeze.Dictionary.merge(self.Data, filtered)
		self.Data = merged
		self._signals:FireEvent("onDataChange", "__root", merged, {})

		for k, v2 in filtered do
			self._signals:FireEvent("onChange", k, Utils.getValue(v2), data[k])
		end
	end

	local mapped = Freeze.Dictionary.map(filtered, function(serializedNone, p3)
		if serializedNone == Freeze.None then
			serializedNone = Utils.SerializedNone
		end

		return serializedNone, p3
	end)

	if v then
		Network.sendTo(self.ReplicateTo, "Update", self._packedId, p, mapped)
	else
		Network.sendTo(self.ReplicateTo, "Update", self._packedId, mapped)
	end
end

function ServerReplion:Increase(p, value)
	assert(type(value) == "number", (`"amount" expected number, got {type(value)}`))
	return self:Set(p, self:GetExpect(p, (`"{Utils.getPathString(p)}" is not a valid path!`)) + value)
end

function ServerReplion:Decrease(p, p2)
	return self:Increase(p, -p2)
end

function ServerReplion:Insert(p, p2, p3)
	local pathTable = Utils.getPathTable(p)
	local v = assert(Freeze.Dictionary.getIn(self.Data, pathTable), (`"{Utils.getPathString(p)}" is not a valid path!`))
	local v2 = p3 or #v + 1
	local v3 = Freeze.List.insert(v, v2, p2)
	local data = self.Data
	local v4 = Freeze.Dictionary.setIn(self.Data, pathTable, v3)
	self.Data = v4
	self._signals:FireEvent("onDataChange", "__root", v4, pathTable)
	self._signals:FireEvent("onArrayInsert", pathTable, v2, p2)
	self._signals:FireChange(pathTable, v4, data)
	Network.sendTo(self.ReplicateTo, "ArrayUpdate", self._packedId, "i", p, p2, p3)
end

function ServerReplion:Remove(p, p2)
	local pathTable = Utils.getPathTable(p)
	local v = assert(Freeze.Dictionary.getIn(self.Data, pathTable), (`"{Utils.getPathString(p)}" is not a valid path!`))
	local v2 = p2 or #v
	local v3 = v[v2]
	local v4 = Freeze.List.remove(v, v2)
	local data = self.Data
	local v5 = Freeze.Dictionary.setIn(self.Data, pathTable, v4)
	self.Data = v5
	self._signals:FireEvent("onDataChange", "__root", v5, pathTable)
	self._signals:FireEvent("onArrayRemove", p, v2, v3)
	self._signals:FireChange(p, v5, data)
	Network.sendTo(self.ReplicateTo, "ArrayUpdate", self._packedId, "r", p, p2)
	return v3
end

function ServerReplion:Clear(p)
	local expect = self:GetExpect(p, (`"{Utils.getPathString(p)}" is not a valid path!`))

	if Freeze.isEmpty(expect) then
		return
	end

	local pathTable = Utils.getPathTable(p)
	local data = self.Data
	local v = Freeze.Dictionary.setIn(self.Data, pathTable, {})
	self.Data = v
	self._signals:FireEvent("onDataChange", "__root", v, pathTable)
	self._signals:FireChange(p, v, data)
	Network.sendTo(self.ReplicateTo, "ArrayUpdate", self._packedId, "c", p)
end

function ServerReplion:Find(p, p2)
	local v = self:Get(p)

	if not v then
		return
	end

	local index = table.find(v, p2)

	if index then
		return index, p2
	end
end

function ServerReplion:Get(p2)
	assert(p2, "Path is required!")
	return Freeze.Dictionary.getIn(self.Data, Utils.getPathTable(p2))
end

function ServerReplion:GetExpect(p, p2)
	assert(p, "Path is required!")
	local v = p2 or `"{Utils.getPathString(p)}" is not a valid path!`
	local v2 = self:Get(p)

	if v2 == nil then
		error(v)
	end

	return v2
end

function ServerReplion:Destroy()
	if self.Destroyed then
		return
	end

	self.Destroyed = true
	self._beforeDestroy:Fire(self)
	self._beforeDestroy:DisconnectAll()
	self._signals:Destroy()
	Network.sendTo(self.ReplicateTo, "Removed", self._packedId)
	table.insert(_ids, self._id)
end

return ServerReplion