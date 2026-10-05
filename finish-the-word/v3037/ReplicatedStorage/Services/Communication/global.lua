local replicatedStorage = game.ReplicatedStorage
local machine = require(replicatedStorage:WaitForChild("Services"):WaitForChild("Core"):WaitForChild("machine"))
local req = machine.req(replicatedStorage, "Services", "Communication", "event")
local req2 = machine.req(replicatedStorage, "Classes", "DataTypes", "class")
local req3 = machine.req(replicatedStorage, "Services", "Utility", "dictUtil")
machine.req(replicatedStorage, "Services", "Utility", "stringUtil")
local RunService = game:GetService("RunService")
local v = {}
local v2 = {}
local shell2 = req2.new()
local v4 = {
	string = tostring,
	userdata = function(instance)
		assert(instance.ClassName == "Player", "Attempted to serialize non-player userdata " .. instance:GetFullName())
		return instance.UserId
	end
}

local function serializeKeys(items)
	local v5 = ""

	for _, item in pairs(items) do
		local typeName = type(item)
		local v6 = v4[typeName]
		assert(v6, "Attempted to serialize Key of unsupported DataType " .. typeName)
		v5 ..= v6(item)
	end

	return v5
end

local function parseKeys(...)
	local v5 = { ... }
	return v5, (table.remove(v5))
end

function v.set(...)
	local v5, v6 = parseKeys(...)
	local v7 = serializeKeys(v5)
	v2[v7] = v6
	return v6
end

function v.remove(...)
	local v5 = serializeKeys({ ... })
	local v6 = v2[v5]
	v2[v5] = nil
	return v6
end

function shell2:__index(p2)
	return self._State[p2]
end

local v5 = {
	add = function(p, p2, p3)
		p[p2] += p3
	end,
	sub = function(self, p2, p3)
		self[p2] -= p3
	end,
	set = function(p, p2, p3, _)
		p[p2] = p3
	end,
	unset = function(p, p2, _, p3)
		p[p2] = p3
	end
}
local _ = {
	add = v5.sub,
	sub = v5.add,
	set = v5.unset,
	unset = v5.set
}

local function resolveKeychain(p, list)
	for i = 2, #list do
		p = p[list[i]]
	end

	return p
end

local function unshell(object)
	if type(object) == "table" and req2.isInstance(object, shell2) then
		object = object:getTable() or object
	end

	return object
end

local function shellNewIndex(object, p, p2)
	local v6 = object[p]

	if type(p2) == "table" and p2._Class ~= shell2 then
		local clone = table.clone(object._Keys)
		table.insert(clone, p)
		object._State[p] = shell2(object._Player, p2, object._ClassModuleName, clone, object._auto_repl)
	else
		object._State[p] = p2
	end

	if v6 ~= p2 then
		local v7 = {}

		for i = 2, #object._Keys do
			v7[i - 1] = object._Keys[i]
		end

		table.insert(v7, p)
		req.fire("StateChanged", object._Player, object._ClassModuleName, p, p2, v7)
	end
end

function shell2:__newindex(p, p2)
	if self._auto_repl then
		self:replicate(p, p2)
	else
		shellNewIndex(self, p, p2)
	end
end

function shell2:__len(_, _)
	return #self._State
end

function shell2:pairs()
	return next, self._State, nil
end

function shell2.empty(_)
	return (setmetatable({
		_State = {}
	}, {
		__index = {
			pairs = function(self)
				return pairs(self._State)
			end
		}
	}))
end

function shell2:auto_repl(p)
	rawset(self, "_auto_repl", p)

	for _, v6 in self:pairs() do
		if type(v6) == "table" then
			v6:auto_repl(p)
		end
	end
end

function shell2:table_insert(p, p2)
	local count = #self
	local v6

	if p2 then
		v6 = p
	else
		v6 = count + 1
		p2 = p
	end

	for i = count + 1, v6 + 1, -1 do
		self[i] = self[i - 1]
	end

	self[v6] = p2
end

function shell2:table_remove(p)
	local v6 = #self
	local v7 = self[p]

	for i = p, v6 do
		self[i] = self[i + 1]
	end

	return v7
end

function shell2.ipairs(p)
	local function iter(p2, p3)
		local v6 = p3 + 1
		local v7 = p2._State[v6]

		if v7 then
			return v6, v7
		end
	end

	return iter, p, 0
end

local v6 = {
	table = true,
	string = true,
	boolean = true,
	number = true,
	userdata = true
}

function shell2:getTable()
	local result = {}

	for k, v7 in self:pairs() do
		if not (type(k) ~= "string" or k:sub(1, 1) ~= "_") then
			continue
		end

		local typeName = type(v7)

		if typeName == "table" then
			result[k] = v7:getTable()
		elseif v6[typeName] then
			result[k] = v7
		end
	end

	return result
end

function shell2:cond_replicate(p, p2, p3)
	if p then
		self:replicate(p2, p3)
	else
		shellNewIndex(self, p2, p3)
	end
end

function shell2:new(player, _State, classModuleName, keys, auto_repl)
	if _State._State then
		_State = _State._State
	end

	self._State = {}
	self._Keys = keys
	self._Player = player
	self._ClassModuleName = classModuleName
	self._auto_repl = auto_repl

	for k, v7 in pairs(_State) do
		if type(v7) == "table" then
			local clone = table.clone(keys)
			table.insert(clone, k)
			self._State[k] = shell2(player, v7, classModuleName, clone, self._auto_repl)
		else
			self._State[k] = v7
		end
	end

	local metatable = getmetatable(_State)

	if metatable then
		setmetatable(self._State, metatable)
	end
end

function v.shell(p, p2, ...)
	local v7, v8 = parseKeys(...)
	local v9 = serializeKeys(v7)
	assert(type(v8) == "table", "Attempted to replicate non-table value")
	local fetched = _G.fetch(p2)
	local v10 = shell2(p, v8, p2, { v9 })

	if not workspace:GetAttribute("TEST") and v10.postShell then
		v10.postShell(v10)
	end

	return v10, v9, fetched
end

v.Shell = shell2

function v.onStateChanged(p, p2, p3, callback)
	return req.connect("StateChanged", function(p4, p5, p6, p7, p8)
		if p4 ~= p or p5 ~= p2 or not req3.subMatch(p8, p3) then
			return
		end

		callback(p4, p5, p6, p7, p8)
	end, {
		Blocking = true
	})
end

if RunService:IsServer() then
	for _, child in pairs(script:GetChildren()) do
		child:destroy()
	end

	local remoteEvent = Instance.new("RemoteEvent", script)
	local remoteFunction = Instance.new("RemoteFunction", script)
	remoteEvent.Name = "client"
	remoteFunction.Name = "server"
	local v7 = {}

	function shell2:replicate(p, p2)
		local v8 = self._State[p]
		shellNewIndex(self, p, p2)

		if v8 == p2 then
			return
		end

		self:repl(p)
	end

	function shell2:plus(p, p2)
		self:replicate(p, self[p] + p2)
	end

	function shell2:repl(p)
		remoteEvent:FireClient(self._Player, self._Keys, p, self._State[p])
	end

	function v.get(...)
		return v2[serializeKeys({ ... })]
	end

	function v:replicate(p2, ...)
		local shell, serializedKey, classModule = v.shell(self, p2, ...)
		v2[serializedKey] = shell
		v7[self.UserId .. serializedKey] = {
			SerializedKey = serializedKey,
			ClassModule = classModule
		}
		return v2[serializedKey]
	end

	function v.replicateRemove(p, ...)
		local v8 = serializeKeys({ ... })
		local v9 = v2[v8]
		v2[v8] = nil
		v7[p.UserId .. v8] = nil
		return v9
	end

	remoteFunction.OnServerInvoke = function(p, p2)
		local v8 = v7[p.UserId .. p2]

		if not v8 then
			return
		end

		local v9 = v.get(v8.SerializedKey)

		if v9 then
			return v9:getTable(), v8.ClassModule
		end
	end

	return v
else
	local server = script:WaitForChild("server")
	local client = script:WaitForChild("client")

	function shell2:replicate(p2, p3)
		self[p2] = p3
	end

	function v.getNotRep(...)
		return v2[serializeKeys({ ... })]
	end

	if workspace:GetAttribute("TEST") then
		function v.testData()
			local import = _G.import("savedState")
			local import2 = _G.import("sessionState")
			local v7 = newproxy(true)
			getmetatable(v7).__index = {
				UserId = 1,
				ClassName = "Player",
				GetFullName = function()
					return "game.Players.HinataSpikes19"
				end
			}
			local shell = v.shell(v7, "savedState", "playerSave", v7, import(v7, {}))
			return shell, (v.shell(v7, "sessionState", "playerSession", v7, import2(v7, shell)))
		end
	end

	function v.get(...)
		if workspace:GetAttribute("TEST") then
			local v7, v8 = v.testData()
			return ({ ... })[1] == "playerSave" and v7 or v8
		end

		local v7 = serializeKeys({ ... })

		if v2[v7] then
			return v2[v7]
		end

		local v8, v9 = server:InvokeServer(v7)

		if not v8 then
			return v2[v7]
		end

		local v10

		if v9 then
			local module = require(v9)
			v10 = module or {}
		else
			v10 = {}
		end

		local v11 = req2.new(shell2, v10)

		function v11.new(...)
			shell2.new(...)
		end

		return v8, v10, function(p)
			v2[v7] = v11(game.Players.LocalPlayer, p, v9.Name, { v7 })
			return v2[v7]
		end
	end

	client.OnClientEvent:Connect(function(list, p, _State)
		if type(_State) == "table" and _State._State then
			_State = _State._State
		end

		local _States = v2[table.remove(list, 1)]

		if not _States then
			warn("attempted to replicate state mutation before state was replicated", list, _State)
			return
		end

		local _ = _States._ClassModuleName

		for _, v7 in pairs(list) do
			_States = _States[v7]
		end

		_States[p] = _State
		req.fire("stateReplicated", list, p, _State)
	end)
	return v
end