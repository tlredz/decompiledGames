local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
require(ReplicatedStorage.Modules.InputLibrary)
local MatchmakingController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("MatchmakingController"))
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
local ArcadeController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ArcadeController"))
local PartyController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PartyController"))
local Matchmaking = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Lobby"):WaitForChild("Matchmaking"))
local MobileInputs = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("MobileInputs"))
local Teleporting = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Teleporting"))
local Equipment = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Equipment"))
local Queue = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Queue"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Pages"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.Frame = UILibrary:GetTo("MainFrame", "Lobby", "Play")
	self.HubButton = self.Frame:WaitForChild("Hub")
	self.PlayButton = self.Frame:WaitForChild("Play")
	self.PlayButtonOffFrame = self.PlayButton:WaitForChild("Off")
	self.PlayButtonOffJoinText = self.PlayButtonOffFrame:WaitForChild("Title")
	self.PlayButtonJoinFrame = self.PlayButton:WaitForChild("Join")
	self.PlayButtonJoinText = self.PlayButtonJoinFrame:WaitForChild("Title")
	self.PlayButtonJoinBubble = self.PlayButtonJoinFrame:WaitForChild("Bubble")
	self.PlayButtonJoinBubbleText = self.PlayButtonJoinBubble:WaitForChild("Title")
	self.PlayButtonJoinBubbleBackground = self.PlayButtonJoinBubble:WaitForChild("Background")
	self.RematchButton = self.Frame:WaitForChild("Rematch")
	self.RematchCountText = self.RematchButton:WaitForChild("Count")
	self.IsHubVisible = false
	self.IsPlayVisible = false
	self.IsRematchVisible = false
	self._bubble_effect = 0
	self:_Init()
	return self
end

function class:GoBackToHub()
	ReplicatedStorage.Remotes.Matchmaking.BackToHub:FireServer()
end

function class:RematchRequest()
	ReplicatedStorage.Remotes.Duels.Rematch:FireServer()
end

function class:OpenPlayPage()
	if CONSTANTS.IS_ARCADE_SERVER or ArcadeController.CurrentDuel then
		ArcadeController:Join()
	elseif PlayerDataController:GetStatistic("StatisticDuelsPlayed") <= 1 and PlayerDataController:GetStatistic("StatisticDuelsWon") < CONSTANTS.BEGINNER_QUEUE_WINS and not PartyController.CurrentParty then
		MatchmakingController:QueueInto(CONSTANTS.BEGINNER_QUEUE_NAME)
	else
		Pages.PageSystem:OpenPage("Matchmaking", true)
	end
end

function class:_UpdateLayouts()
	self.PlayButtonJoinBubbleBackground.Size = UDim2.new(
		0,
		self.PlayButtonJoinBubbleText.TextBounds.X + self.PlayButtonJoinBubble.AbsoluteSize.Y,
		1,
		0
	)
end

function class:_UpdateRematchButton()
	local matchmadeRematchSuccess = MatchmakingController:Get("MatchmadeRematchSuccess")
	local matchmadeRematchCount = MatchmakingController:Get("MatchmadeRematchCount")
	local matchmadeRematchGoal = MatchmakingController:Get("MatchmadeRematchGoal")
	local isRematchAvailable = MatchmakingController:IsRematchAvailable()
	self.RematchCountText.Text = matchmadeRematchSuccess and "• • •" or isRematchAvailable and matchmadeRematchCount .. " / " .. matchmadeRematchGoal or "Unavailable"
end

function class:_BubbleEffect()
	self._bubble_effect += 1
	local _bubble_effect = self._bubble_effect

	if not (self.Frame.Visible and self.PlayButtonJoinFrame.Visible and self.PlayButtonJoinBubble.Visible) then
		return
	end

	while _bubble_effect == self._bubble_effect do
		if self.PlayButtonJoinBubble:IsDescendantOf(Players) then
			self.PlayButtonJoinBubble:TweenPosition(UDim2.new(0.5, 0, -0.5, 0), "Out", "Sine", 0.5, true)
		end

		wait(0.5)

		if _bubble_effect ~= self._bubble_effect then
			break
		end

		if self.PlayButtonJoinBubble:IsDescendantOf(Players) then
			self.PlayButtonJoinBubble:TweenPosition(UDim2.new(0.5, 0, -0.2, 0), "In", "Sine", 0.5, true)
		end

		wait(0.5)
	end
end

function class:_UpdatePlayButton()
	if CONSTANTS.IS_ARCADE_SERVER or ArcadeController.CurrentDuel then
		local joinCooldown = ArcadeController:GetJoinCooldown()
		local currentDuel = ArcadeController.CurrentDuel

		if currentDuel then
			if ArcadeController.CurrentDuel:Get("Status") == "GameOver" then
				currentDuel = false
			else
				currentDuel = joinCooldown <= 0
			end
		end

		self.PlayButtonJoinBubble.Visible = false
		self.PlayButtonOffJoinText.Text = joinCooldown > 0 and joinCooldown or "Join"
		self.PlayButtonJoinFrame.Visible = currentDuel
		self.PlayButtonOffFrame.Visible = not currentDuel
	else
		local v = next(PlayerDataController:Get("FreeWeaponTrialsRemaining"))
		self.PlayButtonJoinBubble.Visible = v or PlayerDataController:GetStatistic("StatisticDuelsPlayed") <= 3
		self.PlayButtonJoinBubbleText.Text = v and "Your free weapon trial is ready!" or "Join the queue to start playing!"
		self.PlayButtonJoinText.Text = "Play"
		self.PlayButtonJoinFrame.Visible = true
		self.PlayButtonOffFrame.Visible = false
	end

	task.spawn(self._BubbleEffect, self)
end

function class:_UpdateVisibility()
	local v = not (Pages.PageSystem.CurrentPage or Equipment.IsOpen or Queue:IsVisible() or Matchmaking:IsVisible() or Teleporting.Enabled or MobileInputs.EditorEnabled or GuiService.MenuIsOpen)
	self.IsHubVisible = v and (CONSTANTS.IS_ARCADE_SERVER or MatchmakingController:IsMatchmadeDuelOver()) and PartyController:IsPartyLeader()
	self.IsPlayVisible = v and (CONSTANTS.QUEUES_ACTIVE or CONSTANTS.IS_ARCADE_SERVER or ArcadeController.CurrentDuel or MatchmakingController:IsMatchmadeDuelOver())
	self.IsRematchVisible = v and MatchmakingController:IsRematchAvailable()
	self.HubButton:TweenPosition(
		self.IsHubVisible and UDim2.new(-3.5, 0, 0.5, 0) or UDim2.new(-3.5, 0, 7, 0),
		"Out",
		"Quint",
		0.25,
		true
	)
	self.PlayButton:TweenPosition(
		self.IsPlayVisible and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0.5, 0, 7, 0),
		"Out",
		"Quint",
		0.25,
		true
	)
	self.RematchButton:TweenPosition(
		self.IsRematchVisible and UDim2.new(4.5, 0, 0.5, 0) or UDim2.new(4.5, 0, 7, 0),
		"Out",
		"Quint",
		0.25,
		true
	)
end

function class:_Init()
	self.PlayButton.MouseButton1Click:Connect(function()
		self:OpenPlayPage()
	end)
	self.HubButton.MouseButton1Click:Connect(function()
		self:GoBackToHub()
	end)
	self.RematchButton.MouseButton1Click:Connect(function()
		self:RematchRequest()
	end)
	self.Frame:GetPropertyChangedSignal("Visible"):Connect(function()
		self:_UpdatePlayButton()
	end)
	self.PlayButtonJoinBubbleText:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateLayouts()
	end)
	self.PlayButtonJoinBubble:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateLayouts()
	end)
	PartyController.PartyChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	MatchmakingController.MatchmadeDuelEnded:Connect(function()
		self:_UpdateVisibility()
	end)
	MatchmakingController.RematchDetailsChanged:Connect(function()
		self:_UpdateVisibility()
		self:_UpdateRematchButton()
	end)
	Equipment.Opened:Connect(function()
		self:_UpdateVisibility()
	end)
	Pages.PageSystem.PageOpened:Connect(function()
		self:_UpdateVisibility()
	end)
	Pages.PageSystem.PageClosed:Connect(function()
		self:_UpdateVisibility()
	end)
	Queue.VisibilityChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	Matchmaking.VisibilityChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	Teleporting.EnabledChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	MobileInputs.EditorEnabledChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	PlayerDataController:GetDataChangedSignal("StatisticDuelsPlayed"):Connect(function()
		self:_UpdatePlayButton()
	end)
	PlayerDataController:GetDataChangedSignal("FreeWeaponTrialsRemaining"):Connect(function()
		self:_UpdatePlayButton()
	end)
	ArcadeController.DuelSet:Connect(function(_)
		self:_UpdateVisibility()
		self:_UpdatePlayButton()
	end)
	ArcadeController.UpdateJoinCooldown:Connect(function()
		self:_UpdatePlayButton()
	end)
	GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
		self:_UpdateVisibility()
	end)

	if ArcadeController.CurrentDuel then
		task.defer(self._ArcadeDuelAdded, self, ArcadeController.CurrentDuel)
	end

	self:_UpdateLayouts()
	self:_UpdatePlayButton()
	self:_UpdateVisibility()
	ButtonEffect:Add(self.HubButton)
	ButtonEffect:Add(self.PlayButton)
	ButtonEffect:Add(self.RematchButton)
end

return class._new()