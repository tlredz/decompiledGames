local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local EventLibrary = require(ReplicatedStorage.Modules.EventLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local FinisherPlayer = require(script:WaitForChild("FinisherPlayer"))
local EmotePlayer = require(script:WaitForChild("EmotePlayer"))
local UnlockModel = require(script:WaitForChild("UnlockModel"))
local equipmentScenes = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("EquipmentScenes")
local v = {
	"Default",
	"Green Screen",
	"Pink Screen",
	"Blue Screen"
}
local Scene = {}
Scene.__index = Scene

function Scene.new(equipment)
	local self = setmetatable({}, Scene)
	self.Equipment = equipment
	self.Model = (equipmentScenes:FindFirstChild(EventLibrary.LOBBY_VISUALS_PROFILE) or equipmentScenes:WaitForChild("Default")):Clone()
	self.FinisherPlayer = FinisherPlayer.new(self)
	self.EmotePlayer = EmotePlayer.new(self)
	self.UnlockModel = UnlockModel.new(self)
	self._backgrounds_folder = self.Model:WaitForChild("Backgrounds")
	self._hide_career_folder = self._backgrounds_folder:WaitForChild("Default"):WaitForChild("HideCareer")
	self._backgrounds = {}
	self._dof = Instance.new("DepthOfFieldEffect")
	self:_Init()
	return self
end

function Scene.GetCFrame(p)
	return p.Model.Primary.CFrame
end

function Scene:GetHumanoidCFrame()
	return self.FinisherPlayer:GetHumanoidCFrame()
end

function Scene:OnOpen(...)
	self.Model.Parent = self.Equipment.IsOpen and workspace or nil
	self:_UpdateDOF()
	self.UnlockModel:OnOpen(...)
end

function Scene:OnCustomizingStateChanged(...)
	self.FinisherPlayer:OnCustomizingStateChanged(...)
	self.EmotePlayer:OnCustomizingStateChanged(...)
end

function Scene:OnStateChanged(...)
	self.FinisherPlayer:OnStateChanged(...)
	self.EmotePlayer:OnStateChanged(...)
	self.UnlockModel:OnStateChanged(...)
end

function Scene:_UpdateDOF()
	local _dof = self._dof
	local parent

	if self.Equipment.IsOpen and self.Equipment:IsOpenEffectDone() ~= self.Equipment.Camera:IsClosing() then
		parent = Lighting or nil
	end

	_dof.Parent = parent
end

function Scene:_UpdateCareerFolder()
	local isCareerPageOpen = self.Equipment:IsCareerPageOpen()
	local customizingType = self.Equipment:GetCustomizingType()
	local v2 = isCareerPageOpen or customizingType == "Finisher" or customizingType == "Emote"
	local _hide_career_folder = self._hide_career_folder
	local parent

	if not v2 then
		parent = self._backgrounds.Default or nil
	end

	_hide_career_folder.Parent = parent
end

function Scene:_UpdateBackgroundFolder()
	local setting = PlayerDataController:GetSetting("Equipment Background")

	for k, _background in pairs(self._backgrounds) do
		local parent

		if k == setting then
			parent = self._backgrounds_folder or nil
		end

		_background.Parent = parent
	end
end

function Scene:_Setup()
	for _, childName in pairs(v) do
		self._backgrounds[childName] = self._backgrounds_folder:WaitForChild(childName)
	end

	self._dof.FarIntensity = 0.75
	self._dof.FocusDistance = 0.05
	self._dof.InFocusRadius = 15
	self._dof.NearIntensity = 0
	self._dof.Name = "Equipment"
end

function Scene:_Init()
	self.Equipment.CareerPageOpened:Connect(function()
		self:_UpdateCareerFolder()
	end)
	self.Equipment.CustomizingChanged:Connect(function()
		self:_UpdateCareerFolder()
	end)
	self.Equipment.FinishedOpenEffect:Connect(function()
		self:_UpdateDOF()
	end)
	PlayerDataController:GetSettingChangedSignal("Equipment Background"):Connect(function()
		self:_UpdateBackgroundFolder()
	end)
	self:_Setup()
	self:_UpdateCareerFolder()
	self:_UpdateBackgroundFolder()
end

return Scene