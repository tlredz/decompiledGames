local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Signal = require(ReplicatedStorage.Modules.Signal)
local UserInterfaceController = require(Players.LocalPlayer.PlayerScripts.Controllers.UserInterfaceController)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local EmoteRenderLogic = require(script:WaitForChild("EmoteRenderLogic"))
local EmoteSoundLogic = require(script:WaitForChild("EmoteSoundLogic"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.CanEmoteChanged = Signal.new()
	self.EmoteRenderLogic = EmoteRenderLogic.new(self)
	self.EmoteSoundLogic = EmoteSoundLogic.new(self)
	self._emoting_cooldown = 0
	self._equipping_items_cooldown = 0
	self:_Init()
	return self
end

function class:IsEquippingItemsDisabled()
	return tick() < self._equipping_items_cooldown
end

function class:CanEmote(p2)
	if UserInterfaceController:IsEquipmentOpen() or not p2 and UserInterfaceController:IsPageOpen() or tick() < self._emoting_cooldown then
		return false
	end

	local fighter = FighterController:GetFighter(Players.LocalPlayer)
	local isSpectating = fighter and fighter:Get("IsSpectating")
	local v

	if CameraController:GetPublicState() == CameraController.CameraState.States.CustomFreecam then
		v = not SpectateController.CurrentDuelSubject or SpectateController.CurrentDuelSubject.LocalDueler
	else
		v = false
	end

	if isSpectating or v then
		return fighter.IsLocalPlayer and fighter:IsAlive() and not fighter.Entity:Get("IsFrozen") and next(PlayerDataController:Get("EquippedEmotes")) ~= nil
	end

	return false
end

function class:UseEmote(p)
	local v = PlayerDataController:Get("EquippedEmotes")[p]

	if not v then
		return
	end

	self:UseEmoteByName(v.Name)
end

function class:UseEmoteByName(p2)
	self._equipping_items_cooldown = tick() + 0.5
	ReplicatedStorage.Remotes.Replication.Fighter.UseEmoteByName:FireServer(p2)
end

function class.EquipEmote(_, p, p2)
	ReplicatedStorage.Remotes.Data.EquipEmote:FireServer(p, p2)
end

function class:_FighterAdded(object)
	if not object.IsLocalPlayer then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function changed()
		self.CanEmoteChanged:Fire()
	end

	object:GetDataChangedSignal("IsSpectating"):Connect(changed)
	object.HealthChanged:Connect(changed)
	changed() -- equivalent call inferred; original call site unknown

	local function entity_added(object2)
		object2:GetDataChangedSignal("IsFrozen"):Connect(changed)
		changed() -- equivalent call inferred; original call site unknown
	end

	object.EntityAdded:Connect(entity_added)

	if object.Entity then
		task.spawn(entity_added, object.Entity)
	end

	object.EquippedItemChanged:Connect(function()
		self._emoting_cooldown = tick() + 0.5
		changed() -- equivalent call inferred; original call site unknown
		task.delay(0.5, changed)
	end)
end

function class:_Init()
	PlayerDataController:GetDataChangedSignal("EquippedEmotes"):Connect(function()
		self.CanEmoteChanged:Fire()
	end)
	CameraController.StateChanged:Connect(function()
		self.CanEmoteChanged:Fire()
	end)
	SpectateController.DuelSubjectChanged:Connect(function()
		self.CanEmoteChanged:Fire()
	end)
	UserInterfaceController.PageSystemPagesActivity:Connect(function()
		self.CanEmoteChanged:Fire()
	end)
	UserInterfaceController.EquipmentOpened:Connect(function()
		self.CanEmoteChanged:Fire()
	end)
	FighterController.ObjectAdded:Connect(function(p)
		self:_FighterAdded(p)
	end)

	for _, object2 in pairs(FighterController.Objects) do
		task.spawn(self._FighterAdded, self, object2)
	end
end

return class._new()