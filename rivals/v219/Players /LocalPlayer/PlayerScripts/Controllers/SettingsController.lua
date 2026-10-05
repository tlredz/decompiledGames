local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._default_settings_cooldown = 0
	self:_Init()
	return self
end

function class.GetMobileButtonSetting(_, p, p2, p3, p4)
	local function get(p5)
		if p4 and p4[p5] ~= nil then
			return p4[p5]
		end

		return (PlayerDataController:GetSetting(p5))
	end

	local v = "MobileButton " .. p .. " Override"
	local v2

	if p3 then
		v2 = "MobileButton " .. p .. " " .. p3
	end

	if v2 and PlayerDataController:GetSetting(v) then
		if p4 and p4[v2] ~= nil then
			return p4[v2]
		end

		return (PlayerDataController:GetSetting(v2))
	else
		if not p2 then
			return nil
		end

		if p4 and p4[p2] ~= nil then
			return p4[p2]
		end

		return (PlayerDataController:GetSetting(p2))
	end
end

function class.SwitchSettingsProfile(_, value)
	assert(typeof(value) == "number")
	ReplicatedStorage.Remotes.Data.SwitchSettingsProfile:FireServer(value)
end

function class:ChangeSetting(p, p2)
	self:ChangeSettings({
		{ p, p2 }
	})
end

function class:ChangeSettings(p)
	ReplicatedStorage.Remotes.Data.ChangeSettings:FireServer(p)
end

function class:DefaultSettings(p2)
	if tick() < self._default_settings_cooldown then
		return
	end

	self._default_settings_cooldown = tick() + 1
	ReplicatedStorage.Remotes.Data.DefaultSettings:FireServer(p2)
end

function class:_ResetHUDSetting()
	if TeleportService:GetTeleportSetting("DontResetHUDSetting") then
		return
	end

	TeleportService:SetTeleportSetting("DontResetHUDSetting", true)
	self:ChangeSetting("Hide HUD", false)
end

function class:_Init()
	task.defer(self._ResetHUDSetting, self)
end

return class._new()