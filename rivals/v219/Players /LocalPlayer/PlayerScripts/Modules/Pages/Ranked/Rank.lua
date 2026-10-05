local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ELOBar = require(Players.LocalPlayer.PlayerScripts.Modules.ELOBar)
local Rank = {}
Rank.__index = Rank

function Rank.new(page)
	local self = setmetatable({}, Rank)
	self.Page = page
	self.Frame = self.Page.Container:WaitForChild("Rank")
	self.ELOBar = ELOBar.new()
	self:_Init()
	return self
end

function Rank:Open()
	self.ELOBar:Update(true)
	self:_UpdateLayoutOrder()
end

function Rank:Close()
	self.ELOBar:Update(false)
	self:_UpdateLayoutOrder()
end

function Rank:_UpdateLayoutOrder()
	local v = PlayerDataController:Get("Seasons")[SeasonLibrary.CurrentSeason.Name]
	local v2 = v and v.RankedPerformances[SeasonLibrary.UNIVERSAL_ELO_NAME]
	local v3 = v2 and v2.CurrentELO ~= nil
	self.Frame.LayoutOrder = v3 and 0 or 20
end

function Rank:_Setup()
	self.ELOBar:SetParent(self.Frame)
end

function Rank:_Init()
	self:_Setup()
	self:_UpdateLayoutOrder()
end

return Rank