local Freeze = require(script.Parent.Parent.Parent.Freeze)
local Utils = require(script.Parent.Parent.Internal.Utils)
local Signal = require(script.Parent.Parent.Parent.Signal)
require(script.Parent.Parent.Internal.Types)
local Graph = require(script.Parent.Parent.Internal.Graph)
local ClientReplion = {}
ClientReplion.__index = ClientReplion

function ClientReplion.new(list)
	return (setmetatable({
		Data = list[3],
		Tags = list[5],
		ReplicateTo = list[4],
		_channel = list[2],
		_beforeDestroy = Signal.new(),
		_rootNode = Graph.createRootNode()
	}, ClientReplion))
end

function ClientReplion:__tostring()
	return (`Replion<{self._channel}>`)
end

function ClientReplion:BeforeDestroy(on_beforeDestroy)
	return self._beforeDestroy:Connect(on_beforeDestroy)
end

function ClientReplion:OnDataChange(p2)
	return Graph.connect(self._rootNode, "onDataChange", "__root", p2)
end

function ClientReplion:OnChange(p2, p3)
	return Graph.connect(self._rootNode, "onChange", p2, p3)
end

function ClientReplion:OnDescendantChange(p2, p3)
	return Graph.connect(self._rootNode, "onDescendantChange", p2, p3)
end

function ClientReplion:OnArrayInsert(p2, p3)
	return Graph.connect(self._rootNode, "onArrayInsert", p2, p3)
end

function ClientReplion:OnArrayRemove(p2, p3)
	return Graph.connect(self._rootNode, "onArrayRemove", p2, p3)
end

function ClientReplion:_set(p, p2)
	local pathTable = Utils.getPathTable(p)

	if Freeze.Dictionary.getIn(self.Data, pathTable) == p2 then
		return p2
	end

	local v = Freeze.Dictionary.setIn(self.Data, pathTable, p2)
	local data = self.Data
	self.Data = v
	Graph.fireEvent(self._rootNode, "onDataChange", "__root", v, pathTable)
	Graph.fireChange(self._rootNode, pathTable, v, data)
	return p2
end

function ClientReplion:_update(p, p2, p3)
	local mapped = Freeze.Dictionary.map(p2 or p, function(none, p4)
		if none == Utils.SerializedNone then
			none = Freeze.None
		end

		if p3 then
			return none, (tonumber(p4))
		end

		return none, p4
	end)
	local pathTable = Utils.getPathTable(p)
	local data = self.Data
	local merged

	if p2 == nil then
		merged = Freeze.Dictionary.merge(self.Data, mapped)
	else
		merged = Freeze.Dictionary.mergeIn(self.Data, pathTable, mapped)
	end

	self.Data = merged
	Graph.fireEvent(self._rootNode, "onDataChange", "__root", merged, pathTable)
	Graph.fireChange(self._rootNode, pathTable, merged, data)
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
	Graph.fireEvent(self._rootNode, "onDataChange", "__root", v4, pathTable)
	Graph.fireEvent(self._rootNode, "onArrayInsert", pathTable, v2, p2)
	Graph.fireChange(self._rootNode, pathTable, v4, data)
end

function ClientReplion:_remove(p, p2)
	local pathTable = Utils.getPathTable(p)
	local expect = self:GetExpect(p, (`"{Utils.getPathString(p)}" is not a valid path!`))
	local v = p2 or #expect
	local v2 = expect[v]
	local v3 = Freeze.List.remove(expect, v)
	local data = self.Data
	local v4 = Freeze.Dictionary.setIn(self.Data, pathTable, v3)
	self.Data = v4
	Graph.fireEvent(self._rootNode, "onDataChange", "__root", v4, pathTable)
	Graph.fireEvent(self._rootNode, "onArrayRemove", p, v, v2)
	Graph.fireChange(self._rootNode, pathTable, v4, data)
	return v2
end

function ClientReplion:_clear(p)
	local pathTable = Utils.getPathTable(p)
	local data = self.Data
	local v = Freeze.Dictionary.setIn(self.Data, pathTable, {})
	self.Data = v
	Graph.fireEvent(self._rootNode, "onDataChange", "__root", v, pathTable)
	Graph.fireChange(self._rootNode, pathTable, v, data)
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

	self._beforeDestroy:Fire()
	self._beforeDestroy:DisconnectAll()
	Graph.destroyRootNode(self._rootNode)
	self._rootNode = nil
	self.Destroyed = true
end

return ClientReplion