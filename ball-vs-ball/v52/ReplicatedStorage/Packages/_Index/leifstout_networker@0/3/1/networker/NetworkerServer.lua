local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local NetworkerUtils = require(script.Parent.NetworkerUtils)
local folder

if RunService:IsRunning() and RunService:IsServer() then
	folder = Instance.new("Folder")
	folder.Name = "_remotes"
	folder.Parent = script.Parent
else
	folder = nil
end

local NetworkerServer = {}
NetworkerServer.__index = NetworkerServer

function NetworkerServer.new(instance, p, p2)
	assert(RunService:IsServer(), "NetworkerServer can only be created on the server")
	local object = setmetatable({
		networkTag = instance,
		_accessLookup = {}
	}, NetworkerServer)
	local folder2 = Instance.new("Folder")
	local remoteEvent = Instance.new("RemoteEvent")
	local remoteFunction = Instance.new("RemoteFunction")
	remoteEvent.Parent = folder2
	remoteFunction.Parent = folder2
	object.remotes = folder2
	object.event = remoteEvent
	object.func = remoteFunction

	if typeof(instance) == "Instance" then
		assert(
			instance:GetAttribute(NetworkerUtils.INSTANCE_ATTRIBUTE) == nil,
			"NetworkerServer instance already has a networkTag attribute"
		)
		local networkTag = HttpService:GenerateGUID(false):sub(1, 13)
		object.instance = instance
		object.networkTag = networkTag
		instance:SetAttribute(NetworkerUtils.INSTANCE_ATTRIBUTE, networkTag)
		object.instanceConn = instance.Destroying:Once(function()
			object:destroy()
		end)
	end

	folder2.Name = object.networkTag
	assert(folder:FindFirstChild(folder2.Name) == nil, "NetworkerServer with the same name already exists")
	folder2.Parent = folder

	if p2 then
		assert(p, "Module must be provided if clientAccess is specified")
		object:addClientAccess(p, p2)
	end

	local function callback(p3, p4: string, ...)
		local v = object._accessLookup[p4]

		if v then
			return v.method(v.module, p3, ...)
		end

		warn(p4 .. " does not exist or is restricted for ", instance)
	end

	remoteEvent.OnServerEvent:Connect(callback)
	remoteFunction.OnServerInvoke = callback
	return object
end

function NetworkerServer:addClientAccess(module, items)
	local function addAccess(items2)
		for _, item in items do
			for k, item2 in items2 do
				if item2 ~= item then
					continue
				end

				assert(self._accessLookup[k] == nil, "Client access method already exists: " .. k)
				assert(type(item2) == "function", "Client access method must be a function: " .. k)
				self._accessLookup[k] = {
					module = module,
					method = item
				}
			end
		end
	end

	addAccess(module)
	local metatable = getmetatable(module)
	local __index = metatable and metatable.__index

	if __index then
		addAccess(__index)
	end
end

function NetworkerServer:addRecipient(p2)
	if not self.recipients then
		self.recipients = {}
	end

	assert(self.recipients, "Recipients list is nil")
	table.insert(self.recipients, p2)
end

function NetworkerServer.removeRecipient(p, p2)
	if not p.recipients then
		return
	end

	local index = table.find(p.recipients, p2)

	if index then
		table.remove(p.recipients, index)
	end
end

function NetworkerServer:clearRecipients()
	self.recipients = nil
end

function NetworkerServer:fire(instance, p2: string, ...)
	if typeof(instance) == "Instance" then
		self.event:FireClient(instance, p2, ...)
		return
	end

	for _, player in instance do
		self.event:FireClient(player, p2, ...)
	end
end

function NetworkerServer:fireAll(p2: string, ...)
	self.event:FireAllClients(p2, ...)
end

function NetworkerServer:fireAllExcept(instance, p2: string, ...)
	local v = typeof(instance) == "Instance" and { instance } or instance

	for _, player in Players:GetPlayers() do
		if not table.find(v, player) then
			self.event:FireClient(player, p2, ...)
		end
	end
end

function NetworkerServer:fireRecipients(p: string, ...)
	if self.recipients then
		self:fire(self.recipients, p, ...)
	else
		warn("No recipients set for service ", self.networkTag)
	end
end

function NetworkerServer:set(p, p2: string, p3)
	self:fire(p, NetworkerUtils.SET_TAG, p2, p3)
end

function NetworkerServer:setAll(p: string, p2)
	self:fireAll(NetworkerUtils.SET_TAG, p, p2)
end

function NetworkerServer:setAllExcept(p, p2: string, p3)
	self:fireAllExcept(p, NetworkerUtils.SET_TAG, p2, p3)
end

function NetworkerServer:setRecipients(p: string, p2)
	self:fireRecipients(NetworkerUtils.SET_TAG, p, p2)
end

function NetworkerServer:destroy()
	self.remotes:Destroy()
	self:clearRecipients()

	if self.instanceConn then
		self.instanceConn:Disconnect()
	end

	if self.instance then
		self.instance:SetAttribute(NetworkerUtils.INSTANCE_ATTRIBUTE, nil)
		self.instance = nil
	end
end

return NetworkerServer