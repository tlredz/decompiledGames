local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local GameplayUtility = require(ReplicatedStorage.Modules.GameplayUtility)
require(ReplicatedStorage.Modules.Utility)
require(Players.LocalPlayer.PlayerScripts.Controllers.WrapController)
local JumpPads = require(Players.LocalPlayer.PlayerScripts.Modules.GameComponents.JumpPads)
local Custom = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Custom)
local object = setmetatable({}, Custom)
object.__index = object

function object.new(...)
	local self = setmetatable(Custom.new(...), object)
	self._use_cooldown = 0
	self._preview_connection = nil
	self._preview_model = nil
	self:_Init()
	return self
end

function object.GetAutoShootReactionTime(_)
	return nil
end

function object:CanQuickAttack()
	return tick() > self._use_cooldown and (self:Get("Ammo") or 1e999) > 0 and not self:IsEquipping() and self:_CanPlace()
end

function object:StartShooting(p)
	if not p and (tick() < self._use_cooldown or (self:Get("Ammo") or 1e999) <= 0 or self:IsEquipping() or not self:_CanPlace()) then
		return false
	end

	self._use_cooldown = tick() + self.Info.Cooldown
	self:CooldownEffect("rbxassetid://17156089790", self.Info.Cooldown, "Use")
	self.ViewModel:StopAnimation("Inspect")
	self.ViewModel:PlayAnimation("Use", 0.5)
	return true, "StartShooting", (self.ClientFighter:GetCameraData())
end

function object:Equip(...)
	Custom.Equip(self, ...)
	self:_StartPlacementPreview()
end

function object:Unequip(...)
	self:_StopPlacementPreview()
	Custom.Unequip(self, ...)
end

function object:Destroy()
	self:_StopPlacementPreview()
	Custom.Destroy(self)
end

function object:_GetPlacementData()
	local cameraData = self.ClientFighter:GetCameraData(nil, nil, true)
	local jumpPadPlacement, v = GameplayUtility:GetJumpPadPlacement(
		self.ClientFighter:Get("EnvironmentID"),
		self.Info.MaxReach,
		cameraData[utf8.char(0)],
		cameraData[utf8.char(1)],
		cameraData[utf8.char(2)],
		cameraData[utf8.char(3)]
	)
	return jumpPadPlacement, v
end

function object:_CanPlace()
	local _GetPlacementData, v = self:_GetPlacementData()
	return _GetPlacementData.Instance and v, _GetPlacementData, v
end

function object:_StopPlacementPreview()
	if self._preview_connection then
		self._preview_connection:Disconnect()
		self._preview_connection = nil
	end

	if self._preview_model then
		self._preview_model:Destroy()
		self._preview_model = nil
	end
end

function object:_StartPlacementPreview()
	self:_StopPlacementPreview()

	if not (self.ClientFighter.IsLocalPlayer and self.ClientFighter:Get("IsSpectating")) then
		return
	end

	local folder = JumpPads:CreateJumpPadVisual(self.ViewModel.Name, self.Info.HitboxSize)

	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Material = Enum.Material.ForceField
		part.Color = Color3.fromRGB(0, 200, 255)
		part.CastShadow = false
	end

	local function update()
		if not (tick() > self._use_cooldown and (self:Get("Ammo") or 1e999) > 0) then
			folder.Parent = nil
			return
		end

		local _, _, v = self:_CanPlace()

		if not self:_CanPlace() then
			folder.Parent = nil
			return
		end

		folder.Parent = workspace
		folder:PivotTo(v)
	end

	self._preview_connection = RunService.RenderStepped:Connect(update)
	update()
	self._preview_model = folder
end

function object:_Init()
	table.insert(self._connections, self.ClientFighter:GetDataChangedSignal("IsSpectating"):Connect(function()
		if self.ClientFighter:Get("IsSpectating") then
			if self.IsEquipped then
				self:_StartPlacementPreview()
			end
		else
			self:_StopPlacementPreview()
		end
	end))
end

return object