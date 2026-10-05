local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local EliminatedEffect = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.EliminatedEffect)
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Pages)
local UpNext = {}
UpNext.__index = UpNext

function UpNext.new(duelInterface)
	local self = setmetatable({}, UpNext)
	self.DuelInterface = duelInterface
	self.Frame = self.DuelInterface.Frame:WaitForChild("UpNext")
	self.Container = self.Frame:WaitForChild("Container"):WaitForChild("SpectateBuffer"):WaitForChild("Container")
	self.Background = self.Container:WaitForChild("Background")
	self.Title = self.Container:WaitForChild("Title")
	self:_Init()
	return self
end

function UpNext:Update()
	local v = not self.DuelInterface.Scoreboard:IsOpen() and not (self.DuelInterface.Voting:IsOpen() or EliminatedEffect:IsVisible()) and not Pages.PageSystem.CurrentPage and self.DuelInterface.ClientDuel:Get("Status") == "RoundStarted"
	local staggeredSpawnsTurn = self.DuelInterface.ClientDuel.LocalDueler and self.DuelInterface.ClientDuel.LocalDueler:GetStaggeredSpawnsTurn()
	local v2 = staggeredSpawnsTurn and staggeredSpawnsTurn <= 1
	local playSourceName = self.DuelInterface.ClientDuel:Get("PlaySourceName")

	if playSourceName then
		if DuelLibrary.PlaySources[playSourceName].DuelLogic == "Zombie Tower" then
			playSourceName = self.DuelInterface.ClientDuel.LocalDueler and self.DuelInterface.ClientDuel.LocalDueler.ClientFighter and not self.DuelInterface.ClientDuel.LocalDueler.ClientFighter:IsAlive()
		else
			playSourceName = false
		end
	end

	self.Frame.Visible = v and (v2 or playSourceName)
	self.Title.Text = v2 and "You're up next!" or playSourceName and "Waiting to be revived by a Revive Drop" or ""
end

function UpNext.Destroy(_) end

function UpNext:_UpdateBackground()
	self.Background.Size = UDim2.new(0, self.Title.TextBounds.X + self.Container.AbsoluteSize.Y * 0.6, 1, 0)
end

function UpNext:_Init()
	self.DuelInterface.Scoreboard.VisibilityChanged:Connect(function()
		self:Update()
	end)
	self.DuelInterface.Voting.VisibilityChanged:Connect(function()
		self:Update()
	end)
	self.Container:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateBackground()
	end)
	self.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateBackground()
	end)
	self:_UpdateBackground()
end

return UpNext