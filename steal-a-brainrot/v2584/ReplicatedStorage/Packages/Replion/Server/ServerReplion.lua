local Players = game:GetService("Players")
local Network = require(script.Parent.Parent.Internal.Network)
local Signal = require(script.Parent.Parent.Parent.Signal)
local Utils = require(script.Parent.Parent.Internal.Utils)
local Graph = require(script.Parent.Parent.Internal.Graph)
require(script.Parent.Parent.Internal.Types)
local Freeze = require(script.Parent.Parent.Parent.Freeze)
local count = 0
local _ids = {}
local v = {}
local ServerReplion = {}
ServerReplion.__index = ServerReplion

function ServerReplion.new(data)
	assert(type(data.Channel) == "string", (`"Channel" expected string, got {type(data.Channel)}`))
	assert(data.ReplicateTo, "ReplicateTo is required!")
	local replicateTo = data.ReplicateTo
	local id

	if count + 1 > 65535 or #_ids >= 16 then
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
		_rootNode = Graph.createRootNode(),
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
	return Graph.connect(self._rootNode, "onDataChange", { "__root" }, p2)
end

function ServerReplion:OnChange(p2, p3)
	return Graph.connect(self._rootNode, "onChange", p2, p3)
end

function ServerReplion:Observe(p, callback)
	task.spawn(function()
		callback(self:Get(p), nil)
	end)
	return Graph.connect(self._rootNode, "onChange", p, callback)
end

function ServerReplion:OnArrayInsert(p2, p3)
	return Graph.connect(self._rootNode, "onArrayInsert", p2, p3)
end

function ServerReplion:OnArrayRemove(p2, p3)
	return Graph.connect(self._rootNode, "onArrayRemove", p2, p3)
end

function ServerReplion:SetReplicateTo(player)
	local v2

	if player == "All" or type(player) == "table" then
		v2 = true
	elseif typeof(player) == "Instance" then
		v2 = player:IsA("Player")
	else
		v2 = false
	end

	assert(v2, "ReplicateTo must be a Player, a table of Players or \"All\"")
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
	local v2 = Freeze.Dictionary.getIn(self.Data, pathTable)

	if Freeze.Dictionary.equals(v2, p2) then
		if not _G.__DEV__ or type(v2) ~= "table" then
			return v2
		end

		local v3, v4 = debug.info(2, "sl")
		local formatted = `{v3}:{v4}`
		local pathString = Utils.getPathString(p)

		if v[formatted] then
			return v2
		end

		if v2 == p2 then
			warn(`Warning: Skipping Replion:Set('{pathString}') due to identical table references.\n` .. `Consider using Replion:Update('{pathString}') at {v3}:{v4} instead.`)
		elseif v2 ~= p2 and type(p2) == "table" then
			warn(`Warning: Replion:Set('{pathString}') detected a new table reference, but all values inside are identical.\n` .. `This may indicate the use of a shallow clone for the table at Replion:Get('{pathString}') without properly cloning nested values. ` .. `Review your table cloning logic at {v3}:{v4}.`)
		end

		v[formatted] = true
		return v2
	else
		if _G.__DEV__ and type(v2) == "table" and type(p2) == "table" then
			local keys = Freeze.Dictionary.keys(v2)
			local keys2 = Freeze.Dictionary.keys(p2)

			if Freeze.List.equals(keys, keys2) then
				local v3, v4 = debug.info(2, "sl")
				local pathString = Utils.getPathString(p)
				local formatted = `{v3}:{v4}`

				if not v[formatted] then
					v[formatted] = true
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
		end

		local v3 = Freeze.Dictionary.setIn(self.Data, pathTable, p2)
		local data = self.Data
		self.Data = v3
		Network.sendTo(self.ReplicateTo, "Set", self._packedId, p, p2)
		Graph.fireEvent(self._rootNode, "onDataChange", "__root", v3, pathTable)
		Graph.fireChange(self._rootNode, pathTable, v3, data)
		return p2
	end
end

function ServerReplion:Update(p, p2)
	local v2

	if p2 then
		v2 = Utils.getPathTable(p)
	end

	local data

	if v2 then
		data = Freeze.Dictionary.getIn(self.Data, v2)
	else
		data = self.Data
	end

	local filtered = Freeze.Dictionary.filter(p2 or p, function(p3, p4)
		return not data or not Freeze.Dictionary.equals(data[p4], p3)
	end)

	if next(filtered) == nil then
		return
	end

	local data2 = self.Data
	local merged

	if v2 then
		merged = Freeze.Dictionary.mergeIn(self.Data, v2, filtered)
	else
		merged = Freeze.Dictionary.merge(self.Data, filtered)
	end

	self.Data = merged
	Graph.fireEvent(self._rootNode, "onDataChange", "__root", merged, v2)
	Graph.fireChange(self._rootNode, v2, merged, data2)
	local v3 = table.maxn(filtered)
	local v4 = nil

	if v3 > 0 then
		local count2 = 0

		for k in filtered do
			count2 += 1

			if k == count2 then
				continue
			end

			v4 = true
			break
		end

		v4 = v4 or count2 ~= v3

		if _G.__DEV__ and v4 then
			local v6, v7 = debug.info(2, "sl")
			local formatted = `{v6}:{v7}`

			if not v[formatted] then
				v[formatted] = true
				warn([[
Warning: You're trying to send an unordered array to the client, RemotesEvents can't send unordered arrays.
]] .. "The array will be transformed into a dictionary to be sent to the client.\n" .. `at {v6}:{v7}`)
			end
		end
	end

	local mapped = Freeze.Dictionary.map(filtered, function(serializedNone, p3)
		if serializedNone == Freeze.None then
			serializedNone = Utils.SerializedNone
		end

		if v4 then
			return serializedNone, (tostring(p3))
		end

		return serializedNone, p3
	end)

	if v2 then
		Network.sendTo(self.ReplicateTo, "Update", self._packedId, p, mapped, v4)
	else
		Network.sendTo(self.ReplicateTo, "Update", self._packedId, mapped, nil, v4)
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

	local v2, v3 = debug.info(2, "sl")
	local formatted = `{v2}:{v3}`

	if not v[formatted] then
		v[formatted] = true
		warn(`Warning: Attempt to increase non-numeric value at "{Utils.getPathString(p)}"\n` .. `Check if the path is correct at {v2}:{v3}.`)
	end

	return expect
end

function ServerReplion:Decrease(p, p2)
	return self:Increase(p, -p2)
end

function ServerReplion:Insert(p, p2, p3)
	local pathTable = Utils.getPathTable(p)
	local expect = self:GetExpect(p, (`"{Utils.getPathString(p)}" is not a valid path!`))
	local v2 = p3 or #expect + 1
	local clone = table.clone(expect)
	table.insert(clone, v2, p2)
	local data = self.Data
	local v3 = Freeze.Dictionary.setIn(self.Data, pathTable, clone)
	self.Data = v3
	Graph.fireEvent(self._rootNode, "onDataChange", "__root", v3, pathTable)
	Graph.fireEvent(self._rootNode, "onArrayInsert", pathTable, v2, p2)
	Graph.fireChange(self._rootNode, pathTable, v3, data)
	Network.sendTo(self.ReplicateTo, "ArrayUpdate", self._packedId, "i", p, p2, p3)
end

function ServerReplion:Remove(p, p2)
	local pathTable = Utils.getPathTable(p)
	local expect = self:GetExpect(p, (`"{Utils.getPathString(p)}" is not a valid path!`))
	local v2 = p2 or #expect
	local v3 = expect[v2]
	local clone = table.clone(expect)
	table.remove(clone, v2)
	local data = self.Data
	local v4 = Freeze.Dictionary.setIn(self.Data, pathTable, clone)
	self.Data = v4
	Graph.fireEvent(self._rootNode, "onDataChange", "__root", v4, pathTable)
	Graph.fireEvent(self._rootNode, "onArrayRemove", p, v2, v3)
	Graph.fireChange(self._rootNode, pathTable, v4, data)
	Network.sendTo(self.ReplicateTo, "ArrayUpdate", self._packedId, "r", p, p2)
	return v3
end

function ServerReplion:Clear(p)
	local expect = self:GetExpect(p, (`"{Utils.getPathString(p)}" is not a valid path!`))

	if next(expect) == nil then
		return
	end

	local pathTable = Utils.getPathTable(p)
	local data = self.Data
	local v2 = Freeze.Dictionary.setIn(self.Data, pathTable, {})
	self.Data = v2
	Graph.fireEvent(self._rootNode, "onDataChange", "__root", v2, pathTable)
	Graph.fireChange(self._rootNode, pathTable, v2, data)
	Network.sendTo(self.ReplicateTo, "ArrayUpdate", self._packedId, "c", p)
end

function ServerReplion:Find(p, p2)
	local v2 = self:Get(p)

	if not v2 then
		return
	end

	local index = table.find(v2, p2)

	if index then
		return index, p2
	end
end

function ServerReplion:Get(p2)
	assert(p2, "Path is required!")
	local pathTable = Utils.getPathTable(p2)
	local v2 = Freeze.Dictionary.getIn(self.Data, pathTable)

	if not _G.__DEV__ or v2 ~= nil then
		return v2
	end

	for k, v3 in pathTable do
		if type(v3) ~= "string" then
			continue
		end

		local trimString = Utils.trimString(v3)

		if trimString == v3 then
			continue
		end

		local v4 = Freeze.List.set(pathTable, k, trimString)

		if not Freeze.Dictionary.getIn(self.Data, v4) then
			continue
		end

		local v5, v6 = debug.info(2, "sl")
		warn(`Warning: the path "{Utils.getPathString(p2)}" has a key with leading or trailing whitespaces.\n` .. `This is likely a mistake, consider using "{Utils.getPathString(v4)}" at {v5}:{v6} instead.`)
	end

	return v2
end

function ServerReplion:GetExpect(p, p2)
	assert(p, "Path is required!")
	local v2 = p2 or `"{Utils.getPathString(p)}" is not a valid path!`
	local v3 = self:Get(p)

	if v3 == nil then
		error(v2)
	end

	return v3
end

function ServerReplion:Destroy()
	if self.Destroyed then
		return
	end

	self._beforeDestroy:Fire()
	self._beforeDestroy:DisconnectAll()
	self._replicateToChanged:Destroy()
	Graph.destroyRootNode(self._rootNode)
	self._rootNode = nil
	self.Destroyed = true
	Network.sendTo(self.ReplicateTo, "Removed", self._packedId)

	if table.find(_ids, self._id) == nil then
		table.insert(_ids, self._id)
	end
end

return ServerReplion