local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local GameplayUtility = require(ReplicatedStorage.Modules.GameplayUtility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local SpectateController = CONSTANTS.IS_CLIENT and require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local OutOfBoundsMachine = {}
OutOfBoundsMachine.__index = OutOfBoundsMachine

function OutOfBoundsMachine.new(fighter_subject, value)
	local self = setmetatable({}, OutOfBoundsMachine)
	self.SteppedOut = Signal.new()
	self.Warning = Signal.new()
	self.Kill = Signal.new()
	self._fighter_subject = fighter_subject
	self._update_frequency = value or 0.1
	self._next_update = 0
	self._oob_details = nil
	self._connections = {}
	self._object_connections = {}
	self._is_visible = false
	self:_Init()
	return self
end

function OutOfBoundsMachine:GetSubject()
	if self._fighter_subject then
		return self._fighter_subject.Entity
	end

	return SpectateController and SpectateController.CurrentSubject and SpectateController.CurrentSubject.IsLocalPlayer and SpectateController.CurrentSubject.Entity
end

function OutOfBoundsMachine:IsOutOfBounds()
	local subject = self:GetSubject()

	if subject and subject:IsAlive() and subject.RootPart then
		return GameplayUtility:IsWithinOOBPart(subject.RootPart.Position)
	end
end

function OutOfBoundsMachine:SetVisible(is_visible)
	self._is_visible = is_visible

	if self._is_visible then
		return
	end

	for _, v in pairs(CollectionService:GetTagged("OutOfBoundsSafePart")) do
		self:_UpdateVisibilityForPart(v)
	end

	for _, v in pairs(CollectionService:GetTagged("OutOfBoundsPart")) do
		self:_UpdateVisibilityForPart(v)
	end
end

function OutOfBoundsMachine:Update(_)
	if tick() < self._next_update then
		return
	end

	self._next_update = tick() + self._update_frequency

	if self:_CheckKill() then
		return
	end

	local isOutOfBounds = self:IsOutOfBounds()

	if isOutOfBounds then
		if not self._oob_details or isOutOfBounds ~= self._oob_details.Part then
			local oOBWarnDelay = GameplayUtility:GetOOBWarnDelay(isOutOfBounds:GetAttribute("WarnDelay"))
			local oOBKillDelay = GameplayUtility:GetOOBKillDelay(isOutOfBounds:GetAttribute("KillDelay"))

			if not self._oob_details or oOBWarnDelay + oOBKillDelay < self._oob_details.KillTime - tick() then
				self._oob_details = {
					Part = isOutOfBounds,
					WarnTime = tick() + oOBWarnDelay,
					KillTime = tick() + oOBWarnDelay + oOBKillDelay
				}
				self.Warning:Fire(oOBWarnDelay + oOBKillDelay)
			end
		end
	elseif self._oob_details then
		self._oob_details = nil
		self.SteppedOut:Fire()
	end

	self:_CheckKill()
end

function OutOfBoundsMachine:Destroy()
	self.SteppedOut:Destroy()
	self.Warning:Destroy()
	self.Kill:Destroy()

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	for _, _object_connection in pairs(self._object_connections) do
		for _, connection in pairs(_object_connection) do
			connection:Disconnect()
		end
	end
end

function OutOfBoundsMachine:_CheckKill()
	if not (self._oob_details and tick() >= self._oob_details.KillTime) then
		return
	end

	self.Kill:Fire(self._oob_details.Part, self:GetSubject() or nil)
	self._oob_details = nil
	self.SteppedOut:Fire()
	return true
end

function OutOfBoundsMachine:_UpdateVisibilityForPart(p2)
	if self._is_visible then
		p2.Transparency = 0
		p2.Material = Enum.Material.ForceField
		p2.Color = Color3.fromRGB(255, 215, 0)
	else
		task.defer(p2.ClearAllChildren, p2)
		p2.Transparency = 1
	end
end

function OutOfBoundsMachine:_ObjectAdded(instance)
	self:_ObjectRemoved(instance)
	self._object_connections[instance] = {}
	table.insert(self._object_connections[instance], instance.ChildAdded:Connect(function(child)
		task.defer(child.Destroy, child)
	end))
	self:_UpdateVisibilityForPart(instance)
end

function OutOfBoundsMachine:_ObjectRemoved(p2)
	for _, connection in pairs(self._object_connections[p2] or {}) do
		connection:Disconnect()
	end

	self._object_connections[p2] = nil
end

function OutOfBoundsMachine:_Init()
	table.insert(self._connections, CollectionService:GetInstanceAddedSignal("OutOfBoundsPart"):Connect(function(p)
		self:_ObjectAdded(p)
	end))
	table.insert(self._connections, CollectionService:GetInstanceAddedSignal("OutOfBoundsSafePart"):Connect(function(p)
		self:_ObjectAdded(p)
	end))

	for _, v in pairs(CollectionService:GetTagged("OutOfBoundsPart")) do
		task.defer(self._ObjectAdded, self, v)
	end

	for _, v in pairs(CollectionService:GetTagged("OutOfBoundsSafePart")) do
		task.defer(self._ObjectAdded, self, v)
	end
end

return OutOfBoundsMachine