local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local Tightrope = require(Players.LocalPlayer.PlayerScripts.Modules.Tightrope)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.Tightropes = {}
	self:_Init()
	return self
end

function class.GetActiveTightrope(p)
	for _, tightrope in pairs(p.Tightropes) do
		if tightrope.Active then
			return tightrope
		end
	end
end

function class:GetTightrope(p2)
	for k, tightrope in pairs(self.Tightropes) do
		if tightrope.Part == p2 then
			return tightrope, k
		end
	end
end

function class:JumpOff()
	for _, tightrope in pairs(self.Tightropes) do
		tightrope:JumpOff()
	end
end

function class:_ObjectAdded(p2)
	local v = Tightrope.new(self, p2)
	table.insert(self.Tightropes, v)
end

function class:_ObjectRemoved(p)
	local tightrope, v = self:GetTightrope(p)

	if not tightrope then
		return
	end

	tightrope:Destroy()
	table.remove(self.Tightropes, v)
end

function class:_HookLocalFighter()
	local v = FighterController:WaitForLocalFighter()

	local function entity_added(entity)
		entity.AirborneChanged:Connect(function()
			if entity:IsAirborne() then
				self:JumpOff()
			end
		end)
		entity:GetDataChangedSignal("IsFrozen"):Connect(function()
			if entity:Get("IsFrozen") then
				self:JumpOff()
			end
		end)
	end

	v.EntityAdded:Connect(entity_added)

	if v.Entity then
		entity_added(v.Entity)
	end
end

function class:_Init()
	CollectionService:GetInstanceAddedSignal("Tightrope"):Connect(function(p)
		self:_ObjectAdded(p)
	end)
	CollectionService:GetInstanceRemovedSignal("Tightrope"):Connect(function(p)
		self:_ObjectRemoved(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("Tightrope")) do
		task.defer(self._ObjectAdded, self, v)
	end

	task.defer(self._HookLocalFighter, self)
end

return class._new()