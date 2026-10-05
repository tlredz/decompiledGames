local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ELOShield = {}
ELOShield.__index = ELOShield

function ELOShield.new(page)
	local self = setmetatable({}, ELOShield)
	self.Page = page
	self.Frame = self.Page.Container:WaitForChild("ELOShield")
	self.Title = self.Frame:WaitForChild("Title")
	self.LeftIcon = self.Title:WaitForChild("Left")
	self.RightIcon = self.Title:WaitForChild("Right")
	self:_Init()
	return self
end

function ELOShield:Open()
	self:_Update()
end

function ELOShield.Close(_) end

function ELOShield:_UpdateIcons()
	self.LeftIcon.Position = UDim2.new(0.5, -self.Title.TextBounds.X / 2, 0.5, 0)
	self.RightIcon.Position = UDim2.new(0.5, self.Title.TextBounds.X / 2, 0.5, 0)
end

function ELOShield:_Update()
	local v = PlayerDataController:Get("Seasons")[SeasonLibrary.CurrentSeason.Name]
	local v2 = v and v.RankedPerformances[SeasonLibrary.UNIVERSAL_ELO_NAME]
	self.Frame.Visible = v2 and v2.ELOShieldsRemaining > 0
	self:_UpdateIcons()
end

function ELOShield:_Init()
	self.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateIcons()
	end)
	self:_UpdateIcons()
end

return ELOShield