local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GameplayUtility = require(ReplicatedStorage.Modules.GameplayUtility)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local EmoteRenderLogic = {}
EmoteRenderLogic.__index = EmoteRenderLogic

function EmoteRenderLogic.new(emoteController)
	local self = setmetatable({}, EmoteRenderLogic)
	self.EmoteController = emoteController
	self._subject_enemies = {}
	self._subject_enemies_changed = Signal.new()
	self._subject_enemy_added = Signal.new()
	self._subject_enemy_removed = Signal.new()
	self._update_visibility_thread = nil
	self._dont_render_until = 0
	self._last_is_emoting_check = nil
	self:_Init()
	return self
end

function EmoteRenderLogic:_IsSystemActive()
	local v = SpectateController:IsSubjectEmoting() or tick() < self._dont_render_until
	local v2 = not CameraController:HasThirdPersonAccess(true)
	return v and v2
end

function EmoteRenderLogic:_GetPosition(object)
	return object and object:IsAlive() and object.Entity and object.Entity.RootPart and object.Entity.RootPart.Position
end

function EmoteRenderLogic:_IsHidden(p)
	if p == SpectateController.CurrentSubject or tick() > self._dont_render_until and not SpectateController:IsSubjectEmoting() then
		return false
	end

	local _GetPosition = self:_GetPosition(SpectateController.CurrentSubject)
	local v = _GetPosition and self:_GetPosition(p)

	if not (_GetPosition and v) then
		return false
	end

	if Utility:Raycast(
		_GetPosition,
		v,
		(_GetPosition - v).Magnitude,
		SpectateController.CurrentSubject:GetRaycastWhitelist(),
		Enum.RaycastFilterType.Include
	).Instance then
		return true
	end

	if GameplayUtility:GetSmokeCloudBetweenPoints(_GetPosition, v) or #GameplayUtility:GetSmokeCloudsInSphere(v) > 0 or #GameplayUtility:GetSmokeCloudsInSphere(_GetPosition) > 0 then
		return true
	end

	return false
end

function EmoteRenderLogic:_UpdateVisibility()
	local isSubjectEmoting = SpectateController:IsSubjectEmoting()

	if self._last_is_emoting_check and not isSubjectEmoting then
		self._dont_render_until = tick() + 0.25
		task.delay(0.25, self._CheckSubjectEmoteStatus, self)
	end

	self._last_is_emoting_check = isSubjectEmoting

	for _, _subject_enemy in pairs(self._subject_enemies) do
		local v = self:_IsHidden(_subject_enemy) or nil

		if v ~= _subject_enemy:Get("IsHiddenByEmotes") then
			_subject_enemy:SetReplicate("IsHiddenByEmotes", v)
		end
	end
end

function EmoteRenderLogic:_CheckSubjectEmoteStatus()
	if self._update_visibility_thread then
		task.cancel(self._update_visibility_thread)
		self._update_visibility_thread = nil
	end

	self:_UpdateVisibility()
	self:_UpdateList()

	if not self:_IsSystemActive() then
		return
	end

	self._update_visibility_thread = task.spawn(function()
		while true do
			wait(0.1)
			self:_UpdateVisibility()
		end
	end)
end

function EmoteRenderLogic:_GetList()
	local currentSubject = SpectateController.CurrentSubject

	if not (currentSubject and currentSubject:Get("IsInDuel") and self:_IsSystemActive() and SpectateController.CurrentDuelSubject and SpectateController.CurrentDuelSubject.LocalDueler) then
		return {}
	end

	local result = {}

	for _, object2 in pairs(FighterController.Objects) do
		if not (object2 ~= currentSubject and object2:Get("EnvironmentID") == currentSubject:Get("EnvironmentID")) then
			continue
		end

		if not (not object2:Get("TeamID") or object2:Get("TeamID") ~= currentSubject:Get("TeamID")) then
			continue
		end

		table.insert(result, object2)
	end

	return result
end

function EmoteRenderLogic:_UpdateList()
	local _GetList = self:_GetList()
	local flag = false

	for i = #self._subject_enemies, 1, -1 do
		local _subject_enemy = self._subject_enemies[i]

		if table.find(_GetList, _subject_enemy) then
			continue
		end

		table.remove(self._subject_enemies, i)
		self._subject_enemy_removed:Fire(_subject_enemy)
		flag = true
	end

	for _, v in pairs(_GetList) do
		if table.find(self._subject_enemies, v) then
			continue
		end

		table.insert(self._subject_enemies, v)
		self._subject_enemy_added:Fire(v)
		flag = true
	end

	if flag then
		self._subject_enemies_changed:Fire()
	end
end

function EmoteRenderLogic:_FighterAdded(object2, p)
	object2:GetDataChangedSignal("EnvironmentID"):Connect(function()
		self:_UpdateList()
	end)
	object2:GetDataChangedSignal("TeamID"):Connect(function()
		self:_UpdateList()
	end)

	if not p then
		self:_UpdateList()
	end
end

function EmoteRenderLogic:_Init()
	self._subject_enemy_added:Connect(function(object2)
		object2:SetReplicate("IsHiddenByEmotes", nil)
	end)
	self._subject_enemy_removed:Connect(function(object2)
		object2:SetReplicate("IsHiddenByEmotes", nil)
	end)
	SpectateController.DuelSubjectChanged:Connect(function()
		self:_CheckSubjectEmoteStatus()
	end)
	SpectateController.SubjectEmoteStatusChanged:Connect(function()
		self:_CheckSubjectEmoteStatus()
	end)
	FighterController.ObjectAdded:Connect(function(p)
		self:_FighterAdded(p)
	end)

	for _, object2 in pairs(FighterController.Objects) do
		task.spawn(self._FighterAdded, self, object2, true)
	end

	task.defer(self._CheckSubjectEmoteStatus, self)
end

return EmoteRenderLogic