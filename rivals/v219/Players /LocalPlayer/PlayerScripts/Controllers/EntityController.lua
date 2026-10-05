local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
require(ReplicatedStorage.Modules.GameplayUtility)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local EnemyController = require(Players.LocalPlayer.PlayerScripts.Controllers.EnemyController)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._hurt_effect_enabled = false
	self._hurt_effect_outline_only = false
	self._hurt_effect_color_fill = Color3.fromRGB(255, 50, 50)
	self._hurt_effect_color_outline = Color3.fromRGB(255, 255, 255)
	self:_Init()
	return self
end

function class.GetScreenPoints(_, object, p)
	local screenPoints = {}

	for _, v in pairs({ EnemyController.Objects, FighterController:GetEntities() }) do
		for _, v2 in pairs(v) do
			if p and v2.AimAssistBlacklist or not object:IsValidTarget(v2) then
				continue
			end

			local screenPoint, v3 = v2:GetScreenPoint()

			if v3 and screenPoint.Z < CONSTANTS.RENDER_DISTANCE then
				screenPoints[v2] = screenPoint
			end
		end
	end

	return screenPoints
end

function class:_UpdateSettings()
	local setting = PlayerDataController:GetSetting("Damage Flashing")
	self._hurt_effect_enabled = setting ~= "Disabled"
	self._hurt_effect_outline_only = setting == "Outline"
	self._hurt_effect_color_fill = Utility:Color3FromHex(PlayerDataController:GetSetting("Damage Flashing Color Base"))
	self._hurt_effect_color_outline = Utility:Color3FromHex(PlayerDataController:GetSetting("Damage Flashing Color Flash"))
end

function class:_SetupHurtEffect(model)
	local v

	if typeof(model) == "Instance" then
		v = model:IsA("Model")
	else
		v = false
	end

	assert(v, "Argument 1 invalid, expected a Model")
	model:SetAttribute("PlayHurtEffect", 0)
	local v2 = nil
	model:GetAttributeChangedSignal("PlayHurtEffect"):Connect(function()
		if not self._hurt_effect_enabled then
			return
		end

		if v2 then
			v2:Destroy()
			v2 = nil
		end

		local highlight = Instance.new("Highlight")
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.Name = "HurtEffect"
		highlight.Adornee = model
		highlight.Parent = model
		v2 = highlight
		Utility:RenderstepForLoop(0, 100, 1, function(p)
			if highlight ~= v2 then
				return true
			end

			local outlineTransparency = 1 - (1 - p / 100) ^ 5
			local _hurt_effect_color_fill = self._hurt_effect_color_outline:Lerp(
				self._hurt_effect_color_fill,
				(math.min(1, p / 5))
			)
			highlight.FillColor = _hurt_effect_color_fill
			highlight.FillTransparency = self._hurt_effect_outline_only and 1 or outlineTransparency
			highlight.OutlineTransparency = outlineTransparency
			local v4 = highlight

			if not self._hurt_effect_outline_only then
				_hurt_effect_color_fill = self._hurt_effect_color_fill
			end

			v4.OutlineColor = _hurt_effect_color_fill
		end)
		highlight:Destroy()
	end)
end

function class:_SetupHurtEffects()
	local model = Instance.new("Model")
	model.Name = "HurtEffect"
	model.Parent = workspace
	self:_SetupHurtEffect(model)
	self:_SetupHurtEffect(workspace:WaitForChild("ViewModels"):WaitForChild("FirstPerson"))
end

function class:_Init()
	PlayerDataController:GetSettingChangedSignal("Damage Flashing"):Connect(function()
		self:_UpdateSettings()
	end)
	PlayerDataController:GetSettingChangedSignal("Damage Flashing Color Base"):Connect(function()
		self:_UpdateSettings()
	end)
	PlayerDataController:GetSettingChangedSignal("Damage Flashing Color Flash"):Connect(function()
		self:_UpdateSettings()
	end)
	task.spawn(self._SetupHurtEffects, self)
	self:_UpdateSettings()
end

return class._new()