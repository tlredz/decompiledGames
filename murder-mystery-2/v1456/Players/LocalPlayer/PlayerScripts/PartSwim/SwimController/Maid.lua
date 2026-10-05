local GetPromiseLibrary = require(script.GetPromiseLibrary)
local Symbol = require(script.Symbol)
local v, v2 = GetPromiseLibrary()
local symbol = Symbol("IndicesReference")
local symbol2 = Symbol("LinkToInstanceIndex")
local Maid = {
	ClassName = "Janitor",
	CurrentlyCleaning = true,
	[symbol] = nil
}
Maid.__index = Maid
local v5 = {
	["function"] = true,
	RBXScriptConnection = "Disconnect"
}

function Maid.Is(p)
	return type(p) == "table" and getmetatable(p) == Maid
end

function Maid:_Add(callback, p, p2)
	if p2 then
		self:Remove(p2)
		local callbacks = self[symbol]

		if not callbacks then
			callbacks = {}
			self[symbol] = callbacks
		end

		callbacks[p2] = callback
	end

	local v6 = p or v5[typeof(callback)] or "Destroy"

	if type(callback) ~= "function" and not callback[v6] then
		warn(string.format(
			"Object %s doesn't have method %s, are you sure you want to add it? Traceback: %s",
			tostring(callback),
			tostring(v6),
			debug.traceback(nil, 2)
		))
	end

	self[callback] = v6
	return callback
end

function Maid:Add(...)
	for _, v6 in pairs({ ... }) do
		self:_Add(v6)
	end
end

function Maid:AddPromise(object2)
	if not v then
		return object2
	end

	if not v2.is(object2) then
		error(string.format(
			"Invalid argument #1 to 'Janitor:AddPromise' (Promise expected, got %s (%s))",
			typeof(object2),
			(tostring(object2))
		))
	end

	if object2:getStatus() ~= v2.Status.Started then
		return object2
	end

	local v6 = newproxy(false)
	local _Add = self:_Add(v2.new(function(callback, _, callback2)
		if callback2(function()
			object2:cancel()
		end) then
			return
		end

		callback(object2)
	end), "cancel", v6)
	_Add:finallyCall(self.Remove, self, v6)
	return _Add
end

function Maid:Remove(p2)
	local v6 = self[symbol]
	local v7 = v6 and v6[p2]

	if not v7 then
		return self
	end

	local v8 = self[v7]

	if v8 then
		if v8 == true then
			v7()
		else
			local v9 = v7[v8]

			if v9 then
				v9(v7)
			end
		end

		self[v7] = nil
	end

	v6[p2] = nil
	return self
end

function Maid.Get(p, p2)
	local v6 = p[symbol]

	if v6 then
		return v6[p2]
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetFenv(items)
	return function()
		for k, item in pairs(items) do
			if k ~= symbol then
				return k, item
			end
		end
	end
end

function Maid:Cleanup()
	if not self.CurrentlyCleaning then
		self.CurrentlyCleaning = nil
		local fenv = GetFenv(self) -- equivalent call inferred; original call site unknown
		local v7, v8 = fenv()

		while v7 and v8 do
			if v8 == true then
				v7()
			else
				local v9 = v7[v8]

				if v9 then
					v9(v7)
				end
			end

			self[v7] = nil
			v7, v8 = fenv()
		end

		local v9 = self[symbol]

		if v9 then
			table.clear(v9)
			self[symbol] = {}
		end

		self.CurrentlyCleaning = false
	end
end

function Maid:Destroy()
	self:Cleanup()
	table.clear(self)
	setmetatable(self, nil)
end

Maid.__call = Maid.Cleanup
local v6 = {
	Connected = true
}
v6.__index = v6

function v6:Disconnect()
	if self.Connected then
		self.Connected = false
		self.Connection:Disconnect()
	end
end

function v6._new(connection)
	return (setmetatable({
		Connection = connection
	}, v6))
end

function v6.__tostring(p)
	return "RbxScriptConnection<" .. tostring(p.Connected) .. ">"
end

function Maid:LinkToInstance(instance, flag: boolean?)
	local ancestryChangedConnection = nil
	local v7 = flag and newproxy(false) or symbol2
	local v8 = instance.Parent == nil
	local object2 = setmetatable({}, v6)

	local function ChangedFunction(_, p)
		if object2.Connected then
			v8 = p == nil

			if v8 then
				task.defer(function()
					if not object2.Connected then
						return
					end

					if not ancestryChangedConnection.Connected then
						self:Cleanup()
						return
					end

					while v8 and ancestryChangedConnection.Connected and object2.Connected do
						task.wait()
					end

					if object2.Connected and v8 then
						self:Cleanup()
					end
				end)
			end
		end
	end

	ancestryChangedConnection = instance.AncestryChanged:Connect(ChangedFunction)
	object2.Connection = ancestryChangedConnection

	if not v8 then
		return self:_Add(object2, "Disconnect", v7)
	end

	local parent = instance.Parent

	if not object2.Connected then
		return self:_Add(object2, "Disconnect", v7)
	end

	if parent == nil then
		v8 = true
	else
		v8 = false
	end

	if v8 then
		task.defer(function()
			if not object2.Connected then
				return
			end

			if not ancestryChangedConnection.Connected then
				self:Cleanup()
				return
			end

			while v8 and ancestryChangedConnection.Connected and object2.Connected do
				task.wait()
			end

			if object2.Connected and v8 then
				self:Cleanup()
			end
		end)
	end

	return self:_Add(object2, "Disconnect", v7)
end

function Maid:LinkToInstances(...)
	local v7 = Maid.new()

	for _, v8 in ipairs({ ... }) do
		v7:_Add(self:LinkToInstance(v8, true), "Disconnect")
	end

	return v7
end

function Maid.new()
	return (setmetatable({
		CurrentlyCleaning = false,
		[symbol] = nil
	}, Maid))
end

return Maid