local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./AttributeSignal")
local folder = Instance.new("Folder")
folder.Archivable = false
folder.Name = "__AttributeAPIInternal"
folder.Parent = ReplicatedStorage
local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = "attributeChangedEvent"
remoteEvent.Parent = folder
local remoteEvent2 = Instance.new("RemoteEvent")
remoteEvent2.Name = "batchAttributesChangedEvent"
remoteEvent2.Parent = folder
local remoteEvent3 = Instance.new("RemoteEvent")
remoteEvent3.Name = "restreamAttributesEvent"
remoteEvent3.Parent = folder
local remoteEvent4 = Instance.new("RemoteEvent")
remoteEvent4.Name = "sendInitialAttributesEvent"
remoteEvent4.Parent = folder
local v = {
	["nil"] = true,
	string = true,
	boolean = true,
	number = true,
	UDim = true,
	UDim2 = true,
	BrickColor = true,
	Color3 = true,
	Vector2 = true,
	Vector3 = true,
	CFrame = true,
	NumberSequence = true,
	ColorSequence = true,
	NumberRange = true,
	Rect = true,
	Font = true
}
local class = {}
class.__index = class
local v2 = {}

function class:SetAttribute(value: string, p)
	if typeof(value) ~= "string" then
		error((`attribute key must be a string {self._inst:GetFullName()}`))
	end

	if not v[typeof(p)] then
		error((`invalid attribute value type for instance {self._inst:GetFullName()}`))
	end

	if self._attr[value] ~= p then
		self._attr[value] = p

		if self._signals[value] then
			self._signals[value]:Fire()
		end

		remoteEvent:FireAllClients(self._inst, value, p)
	end
end

function class:GetAttribute(p2: string)
	return self._attr[p2]
end

function class:GetAttributeAsync(p: string)
	if self._attr[p] ~= nil then
		return self._attr[p]
	end

	local thread = coroutine.running()
	local v3 = nil
	v3 = self:OnAttributeChanged(p, function()
		v3()
		task.spawn(thread, self._attr[p])
	end)
	return coroutine.yield()
end

function class:GetAttributes()
	return table.clone(self._attr)
end

function class:OnAttributeChanged(p2: string, callback)
	if not self._signals[p2] then
		self._signals[p2] = module.new()
	end

	local _signal = self._signals[p2]
	local connection = _signal:Connect(callback)
	return function()
		connection:Disconnect()

		if not _signal:HasConnection() then
			self._signals[p2] = nil
		end
	end
end

function class:Destroy()
	if v2[self._inst] == self then
		v2[self._inst] = nil
	end
end

remoteEvent3.OnServerEvent:Connect(function(player, p)
	local v3 = v2[p]

	if not v3 then
		return
	end

	remoteEvent2:FireClient(player, p, v3._attr)
end)

local function sendInitialAttributes(player)
	local v3 = {}

	for k, v4 in next, v2, nil do
		table.insert(v3, { v4._attr, k })
	end

	remoteEvent4:FireClient(player, v3)
end

for _, v3 in Players:GetPlayers() do
	sendInitialAttributes(v3)
end

Players.PlayerAdded:Connect(sendInitialAttributes)
local AttributeAPI = {}

function AttributeAPI.container(instance)
	if v2[instance] then
		return v2[instance]
	end

	local v3 = nil
	v3 = setmetatable({
		_attr = {},
		_signals = {},
		_inst = instance,
		_destroyingConnection = instance.Destroying:Connect(function()
			if v2[instance] == v3 then
				v2[instance] = nil
			end
		end)
	}, class)
	v2[instance] = v3
	return v3
end

function AttributeAPI.waitUntilReady()
	return true
end

return AttributeAPI