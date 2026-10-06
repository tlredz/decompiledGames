local RunService = game:GetService("RunService")
local parent = script.Parent.Parent
local Signal = require(parent.Signal)
local Networker = require(parent.Networker)
local Value = require(script.Parent.Value)

if RunService:IsServer() then
	return {}
end

local DataServiceClient = {}
DataServiceClient.hasLoaded = false
DataServiceClient.loadedSignal = Signal.new()

function DataServiceClient:init(p)
	self.networker = Networker.client.new("DataService", self)

	if not RunService:IsRunning() then
		self:load(p)
	end

	if self.hasLoaded then
		return self.data
	end

	self.loadedSignal:Wait()
	return self.data
end

function DataServiceClient:load(p2)
	self.data = Value.new(p2)
	self.hasLoaded = true
	self.loadedSignal:Fire()
end

function DataServiceClient:get(list)
	if not self.hasLoaded then
		self.loadedSignal:Wait()
	end

	local data2 = self.data

	for i = #list, 2, -1 do
		data2 = data2[list[i]]
	end

	return data2[list[1]]
end

function DataServiceClient:set(p, p2)
	self:get(p)(p2)
end

function DataServiceClient:insert(p, p2, p3: number?)
	self:get(p).Insert(p2, p3)
end

function DataServiceClient:remove(p, p2: number?)
	self:get(p).Remove(p2)
end

return DataServiceClient