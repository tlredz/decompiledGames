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
	local id

	if count + 1 > 65535 or #_ids >= 1000 then
		id = table.remove(_ids, 1)
	else
		count += 1
		id = count
	end

	assert(id, "No available ID!")
	assert(id <= 65535, (`ID limit reached! You already have {65535} ServerReplions!`))
	local object = setmetatable({
		Data = data.Data,
		Channel = data.Channel,
		Tags = not data.Tags and {} or data.Tags,
		ReplicateTo = replicateTo,
		DisableAutoDestroy = data.DisableAutoDestroy,
		_id = id,
		_packedId = utf8.char(id),
		_beforeDestroy = Signal.new(),
		_signals = Signals.new(),
		_replicateToChanged = Signal.new()
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
		players = type(replicateTo) ~= "table" and { replicateTo } or replicateTo
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
			Network.sendTo(player2, "Added", self:_serialize())
		end
	end

	self.ReplicateTo = player
	self._replicateToChanged:Fire(player, replicateTo)
	Network.sendTo(player, "UpdateReplicateTo", self._packedId, player)
end

function ServerReplion:Set(p, p2)
	local pathTable = Utils.getPathTable(p)
	local v = pcall(function()
		debug.profilebegin((`Replion:Set "{self.Channel}" "{table.concat(pathTable)}"`))
	end)
	local v2 = Freeze.Dictionary.getIn(self.Data, pathTable)

	if v2 and Freeze.Dictionary.equals(v2, p2) then
		if _G.__DEV__ and type(v2) == "table" and v2 == p2 then
			local v3, v4 = debug.info(2, "sl")
			local pathString = Utils.getPathString(p)
			warn(`Warning: Skipping Replion:Set('{pathString}') due to identical table references.\n` .. `Consider using Replion:Update('{pathString}') at {v3}:{v4} instead.`)
		end

		if v then
			debug.profileend()
		end

		return v2
	else
		if _G.__DEV__ and type(v2) == "table" and type(p2) == "table" then
			local keys = Freeze.Dictionary.keys(v2)
			local keys2 = Freeze.Dictionary.keys(p2)

			if Freeze.List.equals(keys, keys2) then
				local v3, v4 = debug.info(2, "sl")
				local pathString = Utils.getPathString(p)
				local filtered = Freeze.Dictionary.filter(p2, function(p3, p4)
					return not Freeze.Dictionary.equals(v2[p4], p3)
				end)

				if Freeze.Dictionary.count(filtered) ~= Freeze.Dictionary.count(p2) then
					local v5 = ""

					for k, v6 in filtered do
						v5 ..= `\n\t{k} = {v6},`
					end

					warn([[
Warning: Sending a table with identical keys but different values to the client.
]] .. `Consider using Replion:Update('{pathString}', \{{v5}\n}) at {v3}:{v4} for optimized updates.`)
				end
			end
		end

		local v3 = Freeze.Dictionary.setIn(self.Data, pathTable, p2)
		local data = self.Data
		self.Data = v3
		self._signals:FireEvent("onDataChange", "__root", v3, pathTable)
		self._signals:FireChange(p, v3, data)
		Network.sendTo(self.ReplicateTo, "Set", self._packedId, p, p2)

		if v then
			debug.profileend()
		end

		return p2
	end
end

function ServerReplion:Update(p, p2)
	local v

	if p2 then
		v = Utils.getPathTable(p)
	end

	local data

	if v then
		data = Freeze.Dictionary.getIn(self.Data, v)
	else
		data = self.Data
	end

	local filtered = Freeze.Dictionary.filter(p2 or p, function(p3, p4)
		return not data or not Freeze.Dictionary.equals(data[p4], p3)
	end)

	if Freeze.isEmpty(filtered) then
		return
	end

	local data2 = self.Data

	if v then
		local mergeIn = Freeze.Dictionary.mergeIn(self.Data, v, filtered)
		self.Data = mergeIn
		self._signals:FireEvent("onDataChange", "__root", mergeIn, v)

		for k, v2 in filtered do
			local v3 = Freeze.List.push(v, k)
			local v4 = Freeze.Dictionary.getIn(data2, v3)
			self._signals:FireEvent("onChange", v3, Utils.getValue(v2), v4)
		end

		self._signals:FireChange(p, mergeIn, data2)
	else
		local merged = Freeze.Dictionary.merge(self.Data, filtered)
		self.Data = merged
		self._signals:FireEvent("onDataChange", "__root", merged, {})

		for k, v2 in filtered do
			self._signals:FireEvent("onChange", k, Utils.getValue(v2), data2[k])
		end
	end

	local v2 = table.maxn(filtered)
	local v3 = nil

	if v2 > 0 then
		local count2 = 0

		for k in filtered do
			count2 += 1

			if k == count2 then
				continue
			end

			v3 = true
			break
		end

		v3 = v3 or count2 ~= v2

		if _G.__DEV__ and v3 then
			local v5, v6 = debug.info(2, "sl")
			warn([[
Warning: You're trying to send an unordered array to the client, RemotesEvents can't send unordered arrays.
]] .. "The array will be transformed into a dictionary to be sent to the client.\n" .. `at {v5}:{v6}`)
		end
	end

	local mapped = Freeze.Dictionary.map(filtered, function(serializedNone, p3)
		if serializedNone == Freeze.None then
			serializedNone = Utils.SerializedNone
		end

		if v3 then
			return serializedNone, (tostring(p3))
		end

		return serializedNone, p3
	end)

	if v then
		Network.sendTo(self.ReplicateTo, "Update", self._packedId, p, mapped, v3)
	else
		Network.sendTo(self.ReplicateTo, "Update", self._packedId, mapped, nil, v3)
	end
end

function ServerReplion:Increase(p, value)
	assert(type(value) == "number", (`"amount" expected number, got {type(value)}`))
	local expect = self:GetExpect(p, (`"{Utils.getPathString(p)}" is not a valid path!`))

	if value == 0 then
		return expect
	end

	if not _G.__DEV__ or type(expect) == "number" then
		return self:Set(p, expect + value)
	end

	local v, v2 = debug.info(2, "sl")
	warn(`Warning: Attempt to increase non-numeric value at "{Utils.getPathString(p)}"\n` .. `Check if the path is correct at {v}:{v2}.`)
	return expect
end

function ServerReplion:Decrease(p, p2)
	return self:Increase(p, -p2)
end

function ServerReplion:Insert(p, p2, p3)
	local pathTable = Utils.getPathTable(p)
	local expect = self:GetExpect(p, (`"{Utils.getPathString(p)}" is not a valid path!`))
	local v = p3 or #expect + 1
	local v2 = Freeze.List.insert(expect, v, p2)
	local data = self.Data
	local v3 = Freeze.Dictionary.setIn(self.Data, pathTable, v2)
	self.Data = v3
	self._signals:FireEvent("onDataChange", "__root", v3, pathTable)
	self._signals:FireEvent("onArrayInsert", pathTable, v, p2)
	self._signals:FireChange(pathTable, v3, data)
	Network.sendTo(self.ReplicateTo, "ArrayUpdate", self._packedId, "i", p, p2, p3)
end

function ServerReplion:Remove(p, p2)
	local pathTable = Utils.getPathTable(p)
	local expect = self:GetExpect(p, (`"{Utils.getPathString(p)}" is not a valid path!`))
	local v = p2 or #expect
	local v2 = expect[v]
	local v3 = Freeze.List.remove(expect, v)
	local data = self.Data
	local v4 = Freeze.Dictionary.setIn(self.Data, pathTable, v3)
	self.Data = v4
	self._signals:FireEvent("onDataChange", "__root", v4, pathTable)
	self._signals:FireEvent("onArrayRemove", p, v, v2)
	self._signals:FireChange(p, v4, data)
	Network.sendTo(self.ReplicateTo, "ArrayUpdate", self._packedId, "r", p, p2)
	return v2
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
	local pathTable = Utils.getPathTable(p2)
	local v = pcall(function()
		debug.profilebegin((`Replion:Get "{self.Channel}" "{table.concat(pathTable)}"`))
	end)
	local v2 = Freeze.Dictionary.getIn(self.Data, pathTable)

	if _G.__DEV__ and v2 == nil then
		local pathTable2 = Utils.getPathTable(p2)

		for k, v3 in pathTable2 do
			if type(v3) ~= "string" then
				continue
			end

			local trimString = Utils.trimString(v3)

			if trimString == v3 then
				continue
			end

			local v4 = Freeze.List.set(pathTable2, k, trimString)

			if not Freeze.Dictionary.getIn(self.Data, v4) then
				continue
			end

			local v5, v6 = debug.info(2, "sl")
			warn(`Warning: the path "{Utils.getPathString(p2)}" has a key with leading or trailing whitespaces.\n` .. `This is likely a mistake, consider using "{Utils.getPathString(v4)}" at {v5}:{v6} instead.`)
		end
	end

	if v then
		debug.profileend()
	end

	return v2
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

	self._beforeDestroy:Fire()
	self._beforeDestroy:DisconnectAll()
	self._replicateToChanged:Destroy()
	self._signals:Destroy()
	self.Destroyed = true
	Network.sendTo(self.ReplicateTo, "Removed", self._packedId)

	if not table.find(_ids, self._id) then
		table.insert(_ids, self._id)
	end
end

return ServerReplion