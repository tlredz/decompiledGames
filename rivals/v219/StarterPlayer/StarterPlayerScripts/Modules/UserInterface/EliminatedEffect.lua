local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ComplianceController"))
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ControlsController"))
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
local DuelController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("DuelController"))
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("WeaponStatusHandler"))
local TeammateSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("TeammateSlot"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local eliminatedCard = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("EliminatedCard")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.VisibilityChanged = Signal.new()
	self.Frame = UILibrary:GetTo("MainFrame", "EliminatedEffect")
	self._last_eliminated_card = nil
	self:_Init()
	return self
end

function class:IsVisible()
	return self._last_eliminated_card ~= nil
end

function class:Play(p, p2, p3, p4, p5)
	if self._last_eliminated_card then
		self._last_eliminated_card:Destroy()
	end

	Utility:CreateSound("rbxassetid://17016581922", 0.75, 1 + 0.1 * math.random(), script, true, 10)
	local v = p or Players.LocalPlayer
	local v2 = v == Players.LocalPlayer
	local v3 = typeof(v) == "Instance"
	local v4

	if typeof(v) == "table" then
		v4 = v
	else
		v4 = false
	end

	local clone = eliminatedCard:Clone()
	clone.Frame.Container.Clip.Container.Description.Text = "eliminated " .. (v2 and "yourself" or "you") .. (not p4 and "" or " with " .. p4 or "")
	clone.Frame.Container.Clip.Container.Username.Text = (v2 or not v3 or v.Name == v.DisplayName) and "" or "@" .. v.Name or ""
	clone.Frame.Container.Clip.Container.Player.Text = v2 and "You" or v3 and ComplianceController:GetName(v) or not v4 and "???" or v4.DisplayName or "???"
	clone.Frame.Container.Clip.Container.Player.Position = clone.Frame.Container.Clip.Container.Username.Text == "" and UDim2.new(
		0.2,
		0,
		0.35,
		0
	) or UDim2.new(0.2, 0, 0.225, 0)
	clone.Frame.Container.Clip.Container.Weapon.Image = ItemLibrary:GetViewModelImage(p4, p5, true) or ""
	clone.Frame.Container.Clip.Container.Background.ImageColor3 = v3 and DuelLibrary:GetTeamColor(v:GetAttribute("TeamID")) or DuelLibrary.EMPTY_TEAM_COLOR
	clone.Frame.Container.Clip.Container.PlayerSlot.FakeEliminator.Image = v4 and v4.Image or ""
	clone.Frame.Container.Weapon.Image = clone.Frame.Container.Clip.Container.Weapon.Image

	if p4 and ItemLibrary.Items[p4] then
		WeaponStatusHandler:ApplyItemStatusToText(
			clone.Frame.Container.Clip.Container.Description,
			ItemLibrary.Items[p4].Status
		)
	end

	clone.Parent = self.Frame
	BetterDebris:AddItem(clone, 10)
	self:_SetLastEliminatedCard(clone)

	if v3 then
		local duel = DuelController:GetDuel(Players.LocalPlayer)
		local dueler = duel and duel:GetDueler(v)
		local isRanked = duel and duel.IsRanked
		local statisticDuelsWinStreak

		if not isRanked then
			statisticDuelsWinStreak = v:GetAttribute("StatisticDuelsWinStreak")
		end

		local level

		if not isRanked then
			level = v:GetAttribute("Level")
		end

		local displayELO = v:GetAttribute("DisplayELO")
		local v5 = TeammateSlot.new(v.UserId, p2, p3, nil, nil, statisticDuelsWinStreak, level)
		v5.SlotFrame.Parent = clone.Frame.Container.Clip.Container.PlayerSlot

		if isRanked and dueler and dueler:CanShowRankToLocalPlayer() then
			v5:SetDisplayELO(displayELO)
		end
	end

	clone.Frame.Container.Size = UDim2.new(0, 0, 1, 0)
	clone.Frame.Container:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Quint", 1, true)
	wait(5)
	Utility:RenderstepForLoop(0, 100, 5, function(p6)
		clone.GroupTransparency = (p6 / 100) ^ 5
	end)
	clone:Destroy()

	if self._last_eliminated_card ~= clone then
		return
	end

	self:_SetLastEliminatedCard(nil)
end

function class:_SetLastEliminatedCard(last_eliminated_card)
	self._last_eliminated_card = last_eliminated_card
	self.VisibilityChanged:Fire()
end

function class:_HookLocalFighter()
	FighterController:WaitForLocalFighter().EntityAdded:Connect(function()
		if self._last_eliminated_card and ControlsController.CurrentControls == "Touch" then
			self._last_eliminated_card:Destroy()
			self:_SetLastEliminatedCard(nil)
		end
	end)
end

function class:_Init()
	task.defer(self._HookLocalFighter, self)
end

return class._new()