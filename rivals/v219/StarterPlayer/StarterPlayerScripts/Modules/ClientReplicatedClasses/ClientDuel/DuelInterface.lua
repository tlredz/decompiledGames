local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local EliminatedEffect = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.EliminatedEffect)
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Pages)
local Inset = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Inset)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local EliminationFeed = require(script:WaitForChild("EliminationFeed"))
local HardcoreParkour = require(script:WaitForChild("HardcoreParkour"))
local FinalResults = require(script:WaitForChild("FinalResults"))
local RoundResult = require(script:WaitForChild("RoundResult"))
local StoryDialog = require(script:WaitForChild("StoryDialog"))
local MatchPoint = require(script:WaitForChild("MatchPoint"))
local Scoreboard = require(script:WaitForChild("Scoreboard"))
local HeadHoncho = require(script:WaitForChild("HeadHoncho"))
local Buttons = require(script:WaitForChild("Buttons"))
local Scores = require(script:WaitForChild("Scores"))
local Voting = require(script:WaitForChild("Voting"))
local UpNext = require(script:WaitForChild("UpNext"))
local Timer = require(script:WaitForChild("Timer"))
local Blur = require(script:WaitForChild("Blur"))
local duelInterface = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DuelInterface")
local DuelInterface = {}
DuelInterface.__index = DuelInterface

function DuelInterface.new(clientDuel)
	local self = setmetatable({}, DuelInterface)
	self.ClientDuel = clientDuel
	self.Frame = duelInterface:Clone()
	self.FinalResults = FinalResults.new(self)
	self.Voting = Voting.new(self)
	self.EliminationFeed = EliminationFeed.new(self)
	self.Scoreboard = Scoreboard.new(self)
	self.RoundResult = RoundResult.new(self)
	self.MatchPoint = MatchPoint.new(self)
	self.Scores = Scores.new(self)
	self.Timer = Timer.new(self)
	self.UpNext = UpNext.new(self)
	self.HeadHoncho = HeadHoncho.new(self)
	self.HardcoreParkour = HardcoreParkour.new(self)
	self.StoryDialog = StoryDialog.new(self)
	self.Buttons = Buttons.new(self)
	self.Blur = Blur.new(self)
	self._destroyed = false
	self._connections = {}
	self._sounds = {}
	self._client_duelers = {}
	self:_Init()
	return self
end

function DuelInterface:IsActive()
	return self.Frame.Visible
end

function DuelInterface.IsPageOpen(_)
	return Pages.PageSystem.CurrentPage ~= nil
end

function DuelInterface:GetLoggedClientDuelers(p2)
	if self.ClientDuel:Get("ArcadeMode") then
		local v = {}

		for k in pairs(self._client_duelers) do
			if not table.find(self.ClientDuel.Duelers, k) then
				v[k] = true
			end
		end

		for k in pairs(v) do
			self._client_duelers[k] = nil
		end
	end

	if not p2 then
		return self._client_duelers
	end

	local v = {}

	for k in pairs(self._client_duelers) do
		local score

		if self.ClientDuel:Get("ArcadeMode") then
			if self.ClientDuel:Get("ScoresBehavior") == "Duelers" then
				score = self.ClientDuel:Get("Scores")[k:Get("DuelerID")] or -1
			elseif self.ClientDuel:Get("ScoresBehavior") == "Teams" then
				score = self.ClientDuel:Get("Scores")[k:Get("TeamID")] or -1
			else
				score = false
			end
		else
			score = -1
		end

		local v2 = {
			ClientDueler = k,
			Score = score,
			Damage = k:Get("Damage") or -1,
			DamageTaken = k:Get("DamageTaken") or -1
		}
		table.insert(v, v2)
	end

	table.sort(v, function(a, b)
		local score = a.Score or -1
		local score2 = b.Score or -1

		if math.abs(score - score2) > 0.01 then
			return score2 < score
		end

		local damage = a.Damage or -1
		local damage2 = b.Damage or -1

		if math.abs(damage - damage2) > 0.01 then
			return damage2 < damage
		end

		return (a.DamageTaken or -1) < (b.DamageTaken or -1)
	end)
	local clientDuelers = {}

	for _, v2 in pairs(v) do
		table.insert(clientDuelers, v2.ClientDueler)
	end

	return clientDuelers
end

function DuelInterface:CreateSound(...)
	if not self:IsActive() then
		return
	end

	local sound = Utility:CreateSound(...)
	table.insert(self._sounds, sound)
	return sound
end

function DuelInterface:RawCreateSound(...)
	local sound = self:CreateSound(...)
	local index = sound and table.find(self._sounds, sound)

	if index then
		table.remove(self._sounds, index)
	end

	return sound
end

function DuelInterface:Destroy()
	self._destroyed = true

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	for _, _sound in pairs(self._sounds) do
		_sound:Destroy()
	end

	self._client_duelers = {}
	self.EliminationFeed:Destroy()
	self.HardcoreParkour:Destroy()
	self.FinalResults:Destroy()
	self.StoryDialog:Destroy()
	self.RoundResult:Destroy()
	self.MatchPoint:Destroy()
	self.Scoreboard:Destroy()
	self.HeadHoncho:Destroy()
	self.Buttons:Destroy()
	self.Scores:Destroy()
	self.Voting:Destroy()
	self.UpNext:Destroy()
	self.Timer:Destroy()
	self.Blur:Destroy()
	self.Frame:Destroy()
end

function DuelInterface:_UpdateSpectating()
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self._connections = {}
	self.Frame.Visible = self.ClientDuel:Get("IsSpectating")
	self.Blur:Update()
	self.HardcoreParkour:Update()

	if not self.Frame.Visible then
		return
	end

	table.insert(self._connections, self.ClientDuel.DuelerRemoved:Connect(function(p)
		if self.ClientDuel:Get("ArcadeMode") then
			self._client_duelers[p] = nil
		end

		self.Scoreboard:Generate()
	end))
	table.insert(self._connections, self.ClientDuel:GetDataChangedSignal("MaxMapBansPerTeam"):Connect(function()
		self.Voting:Generate()
	end))
	table.insert(self._connections, self.ClientDuel:GetDataChangedSignal("VoteBansRemaining"):Connect(function()
		self.Voting:Generate()
	end))
	table.insert(self._connections, self.ClientDuel:GetDataChangedSignal("VoteOptions"):Connect(function()
		self.Voting:Generate()
		self.Timer:UpdateSizeAndPosition()
		self.Scores:Generate()
	end))
	table.insert(self._connections, self.ClientDuel:GetDataChangedSignal("ScoreNeededToWin"):Connect(function()
		self.Scores:Generate()
	end))
	table.insert(self._connections, self.ClientDuel:GetDataChangedSignal("ScoresBehavior"):Connect(function()
		self.Scores:Generate()
	end))
	table.insert(self._connections, self.ClientDuel:GetDataChangedSignal("Status"):Connect(function()
		self.Buttons:Update()
		self.Scoreboard:Open()
		self.HeadHoncho:Update()
		self.HardcoreParkour:Update()
		self.StoryDialog:Update()
		self.UpNext:Update()

		if self.ClientDuel:Get("ArcadeMode") and self.ClientDuel:Get("Status") == "GameOver" then
			self:CreateSound("rbxassetid://99135525400251", 2, 1, script, true, 5)
		end
	end))
	table.insert(self._connections, self.ClientDuel:GetDataChangedSignal("CanSwitchItems"):Connect(function()
		self.Buttons:Update()
	end))
	table.insert(self._connections, self.ClientDuel:GetDataChangedSignal("RoundNum"):Connect(function()
		self.Buttons:Update()
	end))
	table.insert(self._connections, self.ClientDuel:GetDataChangedSignal("CanTrackStatistics"):Connect(function()
		self.Buttons:Update()
	end))
	table.insert(self._connections, self.ClientDuel:GetDataChangedSignal("RematchCount"):Connect(function()
		self.FinalResults.Buttons:Update()
	end))
	table.insert(self._connections, self.ClientDuel:GetDataChangedSignal("RematchGoal"):Connect(function()
		self.FinalResults.Buttons:Update()
	end))
	table.insert(self._connections, self.ClientDuel:GetDataChangedSignal("RematchAvailable"):Connect(function()
		self.FinalResults.Buttons:Update()
	end))
	table.insert(self._connections, self.ClientDuel:GetDataChangedSignal("RematchSuccess"):Connect(function()
		self.FinalResults.Buttons:Update()
	end))
	table.insert(self._connections, self.ClientDuel:GetDataChangedSignal("StaggeredSpawnsOrder"):Connect(function()
		self.Scoreboard:Generate()
		self.UpNext:Update()
		self.Buttons:Update()
	end))
	table.insert(
		self._connections,
		self.ClientDuel:GetDataChangedSignal("HideMostDuelInterfaceElements"):Connect(function()
			self.Timer:Update()
			self.Scores:UpdateVisibility()
		end)
	)
	table.insert(self._connections, GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(function()
		self.Scoreboard:UpdatePreferredTransparency()
	end))
	table.insert(self._connections, EliminatedEffect.VisibilityChanged:Connect(function()
		self.UpNext:Update()
	end))
	table.insert(self._connections, Pages.PageSystem.PagesActivity:Connect(function()
		self.Buttons:Update()
		self.Scores:UpdateVisibility()
		self.EliminationFeed:Update()
		self.Timer:Update()
		self.Scoreboard:Open()
		self.Voting:Generate()
		self.RoundResult:UpdateVisibility()
		self.FinalResults:UpdateVisibility()
		self.HeadHoncho:Update()
		self.HardcoreParkour:Update()
		self.StoryDialog:Update()
	end))
	table.insert(self._connections, Inset.MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self.EliminationFeed:UpdatePosition()
	end))

	local function map_added(object2, _)
		table.insert(self._connections, object2:GetDataChangedSignal("ObbyStartPosition"):Connect(function()
			self.HardcoreParkour:Update()
		end))
		table.insert(self._connections, object2:GetDataChangedSignal("ObbyFinishPosition"):Connect(function()
			self.HardcoreParkour:Update()
		end))
		self.HardcoreParkour:Update()
	end

	table.insert(self._connections, self.ClientDuel.MapAdded:Connect(map_added))

	if self.ClientDuel.Map then
		task.spawn(map_added, self.ClientDuel.Map, true)
	end

	local function dueler_added(object2, p)
		table.insert(self._connections, object2:GetDataChangedSignal("LastVote"):Connect(function()
			self.Voting:Generate()
		end))
		table.insert(self._connections, object2:GetDataChangedSignal("IsHeadHoncho"):Connect(function()
			self.HeadHoncho:Update()
		end))
		table.insert(self._connections, object2:GetDataChangedSignal("Eliminations"):Connect(function()
			self.Scoreboard:Generate()
		end))
		table.insert(self._connections, object2:GetDataChangedSignal("Deaths"):Connect(function()
			self.Scoreboard:Generate()
		end))
		table.insert(self._connections, object2:GetDataChangedSignal("Assists"):Connect(function()
			self.Scoreboard:Generate()
		end))
		table.insert(self._connections, object2:GetDataChangedSignal("Damage"):Connect(function()
			self.Scoreboard:Generate()
		end))
		table.insert(self._connections, object2.ItemAdded:Connect(function()
			self.Scoreboard:Generate()
		end))
		table.insert(self._connections, object2.ItemRemoved:Connect(function()
			self.Scoreboard:Generate()
		end))
		table.insert(self._connections, object2.Died:Connect(function()
			self.UpNext:Update()

			if object2.IsLocalPlayer then
				self.Buttons:Update()
			end
		end))
		table.insert(self._connections, object2.EntityAdded:Connect(function()
			self.UpNext:Update()

			if object2.IsLocalPlayer then
				self.Buttons:Update()
			end
		end))
		table.insert(self._connections, object2.HealthChanged:Connect(function()
			self.Scoreboard:Generate()
			self.UpNext:Update()

			if object2.IsLocalPlayer then
				self.Buttons:Update()
			end
		end))
		table.insert(self._connections, object2.ClientFighter:GetDataChangedSignal("ConnectionLevel"):Connect(function()
			self.Scoreboard:Generate()
		end))

		if object2.IsLocalPlayer then
			table.insert(self._connections, object2:GetDataChangedSignal("SwitchItemsCount"):Connect(function()
				self.Buttons:Update()
			end))
			table.insert(self._connections, object2:GetDataChangedSignal("SwitchItemsMax"):Connect(function()
				self.Buttons:Update()
			end))
			table.insert(self._connections, object2:GetDataChangedSignal("TeamID"):Connect(function()
				self.Scores:Generate()
			end))
			table.insert(
				self._connections,
				object2.ClientFighter:GetDataChangedSignal("CanPickWeapons"):Connect(function()
					self.Buttons:Update()
				end)
			)
			table.insert(
				self._connections,
				object2.ClientFighter:GetDataChangedSignal("LastPickedWeapons"):Connect(function()
					self.Buttons:Update()
				end)
			)
			table.insert(self._connections, object2.ClientFighter.InvincibilityChanged:Connect(function()
				self.Buttons:Update()
			end))
		end

		self._client_duelers[object2] = true

		if not p then
			self.Buttons:Update()
			self.Scoreboard:Generate()
			self.StoryDialog:Update()

			if object2.IsLocalPlayer then
				self.Scores:Generate()
			end
		end
	end

	table.insert(self._connections, self.ClientDuel.DuelerAdded:Connect(dueler_added))

	for _, dueler in pairs(self.ClientDuel.Duelers) do
		task.spawn(dueler_added, dueler, true)
	end

	self.Buttons:Update()
	self.Scores:UpdateVisibility()
	self.Scores:Generate()
	self.Voting:Generate()
	self.Timer:UpdateSizeAndPosition()
	self.Timer:Update()
	self.Scoreboard:Generate()
	self.Scoreboard:UpdatePreferredTransparency()
	self.Scoreboard:Open(false)
	self.EliminationFeed:Update()
	self.RoundResult:UpdateVisibility()
	self.FinalResults:UpdateVisibility()
	self.UpNext:Update()
	self.HeadHoncho:Update()
	self.HardcoreParkour:Update()
	self.StoryDialog:Update()
end

function DuelInterface:_Setup()
	self.Frame.Visible = false
	self.Frame.Parent = UILibrary:GetTo("MainFrame", "DuelInterfaces")
end

function DuelInterface:_Init()
	self.ClientDuel:GetDataChangedSignal("IsSpectating"):Connect(function()
		self:_UpdateSpectating()
	end)
	self:_Setup()
	task.spawn(self._UpdateSpectating, self)
end

return DuelInterface