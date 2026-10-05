local Freeze = require(script.Parent.Parent.Parent.Freeze)
local Utils = require(script.Parent.Parent.Internal.Utils)
local Signal = require(script.Parent.Parent.Parent.Signal)
require(script.Parent.Parent.Internal.Types)
local Signals = require(script.Parent.Parent.Internal.Signals)
local ClientReplion = {}
ClientReplion.__index = ClientReplion

function ClientReplion.new(list)
	return (setmetatable({
		Data = list[3],
		Tags = list[5],
		ReplicateTo = list[3],
		_channel = list[2],
		_beforeDestroy = Signal.new(),
		_signals = Signals.new()
	}, ClientReplion))
end

function ClientReplion:__tostring()
	return (`Replion<{self._channel}>`)
end

function ClientReplion:BeforeDestroy(on_beforeDestroy)
	return self._beforeDestroy:Connect(on_beforeDestroy)
end

function ClientReplion:OnDataChange(p2)
	return self._signals:Connect("onDataChange", "__root", p2)
end

function ClientReplion:OnChange(p2, p3)
	return self._signals:Connect("onChange", p2, p3)
end

function ClientReplion:OnDescendantChange(p2, p3)
	return self._signals:Connect("onDescendantChange", p2, p3)
end

function ClientReplion:OnArrayInsert(p2, p3)
	return self._signals:Connect("onArrayInsert", p2, p3)
end

function ClientReplion:OnArrayRemove(p2, p3)
	return self._signals:Connect("onArrayRemove", p2, p3)
end

function ClientReplion:_set(p, p2)
	local pathTable = Utils.getPathTable(p)

	if Freeze.Dictionary.getIn(self.Data, pathTable) == p2 then
		return p2
	end

	local v = Freeze.Dictionary.setIn(self.Data, pathTable, p2)
	local data = self.Data
	self.Data = v
	self._signals:FireEvent("onDataChange", "__root", v, pathTable)
	self._signals:FireChange(p, v, data)
	return p2
end

function ClientReplion:_update(p, p2)
	local mapped = Freeze.Dictionary.map(p2 or p, function(none, p3)
		if none == Utils.SerializedNone then
			none = Freeze.None
		end

		return none, p3
	end)
	local data = self.Data

	if p2 == nil then
		local merged = Freeze.Dictionary.merge(self.Data, mapped)
		self.Data = merged
		self._signals:FireEvent("onDataChange", "__root", merged, {})

		for k, v in mapped do
			self._signals:FireEvent("onChange", k, Utils.getValue(v), data[k])
		end
	else
		local pathTable = Utils.getPathTable(p)
		local mergeIn = Freeze.Dictionary.mergeIn(self.Data, pathTable, mapped)
		self.Data = mergeIn
		self._signals:FireEvent("onDataChange", "__root", mergeIn, pathTable)

		for k, v in mapped do
			local v2 = Freeze.List.push(pathTable, k)
			local v3 = Freeze.Dictionary.getIn(data, v2)
			self._signals:FireEvent("onChange", v2, Utils.getValue(v), v3)
		end

		self._signals:FireChange(p, mergeIn, data)
	end
end

function ClientReplion:_increase(p, p2)
	return self:_set(p, self:GetExpect(p) + p2)
end

function ClientReplion:_decrease(p, p2)
	return self:_increase(p, -p2)
end

function ClientReplion:_insert(p, p2, p3)
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
end

function ClientReplion:_remove(p, p2)
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
	return v3
end

function ClientReplion:_clear(p)
	local pathTable = Utils.getPathTable(p)
	local data = self.Data
	local v = Freeze.Dictionary.setIn(self.Data, pathTable, {})
	self.Data = v
	self._signals:FireEvent("onDataChange", "__root", v, pathTable)
	self._signals:FireChange(p, v, data)
end

function ClientReplion:Find(p, p2)
	local v = self:Get(p)

	if not v then
		return
	end

	local index = table.find(v, p2)

	if index then
		return index, p2
	end
end

function ClientReplion:Get(p2)
	return Freeze.Dictionary.getIn(self.Data, Utils.getPathTable(p2))
end

function ClientReplion:GetExpect(p, p2)
	assert(p, "Path is required!")
	local v = p2 or `"{Utils.getPathString(p)}" is not a valid path!`
	local v2 = self:Get(p)

	if v2 == nil then
		error(v)
	end

	return v2
end

function ClientReplion:Destroy()
	if self.Destroyed then
		return
	end

	self.Destroyed = true
	self._beforeDestroy:Fire(self)
	self._beforeDestroy:DisconnectAll()
	self._signals:Destroy()
end

return ClientReplion