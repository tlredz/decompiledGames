local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local GlowyBackground = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("GlowyBackground"))
local ChickenFooter = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ChickenFooter"))
require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local teleportingGui = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("TeleportingGui")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.EnabledChanged = Signal.new()
	self.Enabled = nil
	self.GUI = teleportingGui:Clone()
	self.Frame = self.GUI:WaitForChild("Teleporting")
	self.Container = self.Frame:WaitForChild("Container")
	self.Dots = self.Container:WaitForChild("Waiting"):WaitForChild("Dots")
	self._enabled_hash = 0
	self._blur = Instance.new("BlurEffect")
	self._chicken_footer = ChickenFooter.new()
	self._glowy_background = GlowyBackground.new("Teleporting")
	self:_Init()
	return self
end

function class:Enable(enabled)
	if enabled == self.Enabled then
		return
	end

	self.Enabled = enabled
	self.EnabledChanged:Fire()
	self._enabled_hash += 1
	task.spawn(self._Update, self)
end

function class:_Update()
	local _enabled_hash = self._enabled_hash
	self.Container.Visible = self.Enabled
	self._glowy_background:SetEnabled(self.Enabled)

	if self.Enabled then
		self.Dots:AddTag("UILoadingDots")
		self._chicken_footer:Show()
		self._chicken_footer:EnableTimer()
		self._chicken_footer:EnableFunFacts()
		self._chicken_footer:SetStatus("Teleporting")
	else
		self.Dots:RemoveTag("UILoadingDots")
		self._chicken_footer:Hide()
	end

	local _ = self.Enabled
	local _ = self.Enabled
	local v = self.Enabled and 0 or 56
	local v2 = self.Enabled and 56 or 0
	Utility:RenderstepForLoop(0, 100, 4, function(p)
		if _enabled_hash ~= self._enabled_hash then
			return true
		end

		local v3 = 1 - (1 - p / 100) ^ 3
		self._blur.Size = v + (v2 - v) * v3
	end)
end

function class:_Setup()
	self._blur.Size = 0
	self._blur.Name = "Teleporting"
	self._blur.Parent = Lighting
	self._chicken_footer:SetParent(self.Frame)
	self._glowy_background:SetParent(self.Frame)
	self.GUI.Parent = Players.LocalPlayer.PlayerGui
end

function class:_Init()
	self.EnabledChanged:Connect(function()
		if self.Enabled then
			TeleportService:SetTeleportGui(self.GUI)
		end
	end)
	ReplicatedStorage.Remotes.Misc.Teleporting.OnClientEvent:Connect(function(p)
		self:Enable(p)
	end)
	self:_Setup()
	self:Enable(false)
end

return class._new()