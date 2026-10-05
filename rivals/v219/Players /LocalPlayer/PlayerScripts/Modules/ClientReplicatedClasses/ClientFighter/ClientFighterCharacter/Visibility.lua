local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local v = {
	"HitboxHead",
	"HitboxBody",
	"HitboxHeadSmall",
	"HitboxBodySmall"
}
local Visibility = {}
Visibility.__index = Visibility

function Visibility.new(clientFighterCharacter)
	local self = setmetatable({}, Visibility)
	self.ClientFighterCharacter = clientFighterCharacter
	self._destroyed = false
	self._original_properties = {}
	self._is_translucent = false
	self._update_debounce = false
	self._hitboxes_visible = nil
	self._update_hitboxes_check = false
	self:_Init()
	return self
end

function Visibility:SetTranslucent(is_translucent)
	if is_translucent == self._is_translucent then
		return
	end

	self._is_translucent = is_translucent
	self:_BulkUpdate()
end

function Visibility:SetHitboxesVisible(hitboxes_visible)
	self._hitboxes_visible = hitboxes_visible
	self:_UpdateHitboxes()
end

function Visibility:CloneModel()
	self:_Verify(true, false)
	local archivable = self.ClientFighterCharacter.Model.Archivable
	self.ClientFighterCharacter.Model.Archivable = true
	local clone = self.ClientFighterCharacter.Model:Clone()
	self.ClientFighterCharacter.Model.Archivable = archivable
	self:_Verify(true, nil)
	return clone
end

function Visibility.Update(_, _, _) end

function Visibility:Destroy()
	self._destroyed = true
end

function Visibility._GetHeight(p)
	local model = Instance.new("Model")

	for _, part in pairs(p.ClientFighterCharacter.Model:GetChildren()) do
		if not (part:IsA("BasePart") and part.Transparency < 0.9 and part.Material ~= Enum.Material.ForceField) then
			continue
		end

		local part2 = Instance.new("Part")
		part2.Size = part.ExtentsSize
		part2.CFrame = part.ExtentsCFrame
		part2.Parent = model
	end

	local _, v2 = model:GetBoundingBox()
	return v2.Y
end

function Visibility:_UpdateHitboxes()
	if self._hitboxes_visible == nil then
		return
	end

	self._update_hitboxes_check = true
	task.defer(function()
		if not self._update_hitboxes_check or self._destroyed then
			return
		end

		self._update_hitboxes_check = false
		local transparency = self._hitboxes_visible and not self.ClientFighterCharacter.ClientFighter:IsActuallyFirstPerson() and 0 or 1

		for _, v3 in pairs(v) do
			local silentWaitForChild = Utility:SilentWaitForChild(self.ClientFighterCharacter.Model, v3)
			silentWaitForChild.Transparency = transparency
		end
	end)
end

function Visibility:_Update(instance)
	if not (self._original_properties[instance] or self.ClientFighterCharacter:IsAlive()) then
		return
	end

	local v2 = self.ClientFighterCharacter:IsHidden() or self.ClientFighterCharacter.ClientFighter:Get("IsHiddenByEmotes") or self.ClientFighterCharacter.ClientFighter:Get("IsHiddenByCutscene")
	local _is_translucent = self._is_translucent or self.ClientFighterCharacter:Get("IsTranslucent") and not self.ClientFighterCharacter.ClientFighter:Get("IsSpectating")

	if instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("Texture") then
		self._original_properties[instance] = self._original_properties[instance] or {
			Transparency = instance.Transparency
		}
		local transparency = self._original_properties[instance].Transparency
		instance.Transparency = transparency + (1 - transparency) * (v2 and 1 or _is_translucent and 0.875 or 0)
	elseif instance:IsA("ParticleEmitter") or instance:IsA("Fire") or instance:IsA("Sparkles") or instance:IsA("Smoke") or instance:IsA("Trail") then
		self._original_properties[instance] = self._original_properties[instance] or {
			Enabled = instance.Enabled
		}
		instance.Enabled = not (v2 or _is_translucent) and self._original_properties[instance].Enabled

		if not instance.Enabled and instance:IsA("ParticleEmitter") then
			instance:Clear()
		end
	end
end

function Visibility:_BulkUpdate()
	for _, descendant in pairs(self.ClientFighterCharacter.Model:GetDescendants()) do
		if table.find(v, descendant.Name) or descendant:GetAttribute("IgnoreVisibilityCheck") then
			continue
		end

		self:_Update(descendant)
	end
end

function Visibility:_Verify(p, p2)
	local v2 = self.ClientFighterCharacter.ClientFighter:IsActuallyFirstPerson() and self.ClientFighterCharacter.ClientFighter:IsActive()

	if not p and v2 == self.ClientFighterCharacter:IsHidden() then
		return
	end

	local clientFighterCharacter = self.ClientFighterCharacter

	if p2 ~= nil then
		v2 = p2
	end

	clientFighterCharacter:SetHidden(v2)
	self:_BulkUpdate()
end

function Visibility:_Init()
	self.ClientFighterCharacter.EnteredWorld:Connect(function()
		self:_Verify(true)
		self:_UpdateHitboxes()
	end)
	self.ClientFighterCharacter.BurnEffectPlaying:Connect(function(items)
		for _, item in pairs(items) do
			self:_Update(item)
		end
	end)
	self.ClientFighterCharacter.Model.ChildAdded:Connect(function(_)
		if self._update_debounce or not self.ClientFighterCharacter:IsAlive() then
			return
		end

		self._update_debounce = true
		task.defer(function()
			self._update_debounce = false
			self:_Verify(true)
			self:_UpdateHitboxes()
		end)
	end)
	self.ClientFighterCharacter:GetDataChangedSignal("IsTranslucent"):Connect(function()
		self:_Verify()
	end)
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter:GetDataChangedSignal("IsSpectating"):Connect(function()
		self:_Verify()
		self:_UpdateHitboxes()
	end))
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter:GetDataChangedSignal("IsInDuel"):Connect(function()
		self:_Verify()
	end))
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter.ItemAdded:Connect(function()
		self:_Verify()
		self:_UpdateHitboxes()
	end))
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter.ItemRemoved:Connect(function()
		self:_Verify()
		self:_UpdateHitboxes()
	end))
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter:GetDataChangedSignal("IsHiddenByEmotes"):Connect(function()
		self:_Verify(true)
	end))
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter:GetDataChangedSignal("IsHiddenByCutscene"):Connect(function()
		self:_Verify(true)
	end))
	self.ClientFighterCharacter:AddConnection(CameraController.StateChanged:Connect(function()
		self:_Verify()
		self:_UpdateHitboxes()
	end))
	self.ClientFighterCharacter:AddConnection(PlayerDataController:GetSettingChangedSignal("Player Hitboxes"):Connect(function()
		self:_UpdateHitboxes()
	end))
	self:_Verify(true)
	self:_UpdateHitboxes()
end

return Visibility