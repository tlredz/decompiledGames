local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local Signal = require(ReplicatedStorage.Modules.Signal)
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local TeammateSlot = require(Players.LocalPlayer.PlayerScripts.Modules.TeammateSlot)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local duelsBoardTeamSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DuelsBoardTeamSlot")
local duelsBoardSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DuelsBoardSlot")
local DuelDisplay = {}
DuelDisplay.__index = DuelDisplay

function DuelDisplay.new(clientDuel)
	local self = setmetatable({}, DuelDisplay)
	self.GameOver = Signal.new()
	self.ClientDuel = clientDuel
	self.Frame = duelsBoardSlot:Clone()
	self._destroyed = false
	self._connections = {}
	self._num_teams = self.ClientDuel:Get("NumTeams")
	self._team_slots = {}
	self._team_ids = {}
	self._dueler_slots = {}
	self:_Init()
	return self
end

function DuelDisplay:Destroy()
	self._destroyed = true

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self.GameOver:Destroy()
	self.Frame:Destroy()
end

function DuelDisplay:_DuelerAdded(object2)
	if self._destroyed then
		return
	end

	self:_UpdateScores()
	local index = table.find(self._team_ids, object2:Get("TeamID"))
	local v = TeammateSlot.new(
		object2.Player.UserId,
		object2.ClientFighter:Get("Controls"),
		1,
		false,
		false,
		object2.Player:GetAttribute("StatisticDuelsWinStreak"),
		object2.Player:GetAttribute("Level")
	)
	v.SlotFrame.Container.Background.Visible = false
	v.SlotFrame.Parent = index and self.Frame.Teams[index].Container or self.Frame.Teams
	self._dueler_slots[object2] = v

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update_health()
		v:SetHealthPercent(object2:GetHealth() / object2:GetMaxHealth())
	end

	table.insert(self._connections, object2.HealthChanged:Connect(update_health))
	update_health() -- equivalent call inferred; original call site unknown
end

function DuelDisplay:_DuelerRemoved(p2)
	if not self.ClientDuel:Get("ArcadeMode") then
		return
	end

	local _dueler_slot = self._dueler_slots[p2]

	if not _dueler_slot then
		return
	end

	_dueler_slot:Destroy()
	self._dueler_slots[p2] = nil
end

function DuelDisplay:_UpdateScores()
	local scoresBehavior = self.ClientDuel:Get("ScoresBehavior")
	local scores = self.ClientDuel:Get("Scores")

	for k, _team_id in pairs(self._team_ids) do
		self.Frame.Teams[k].Container.Score.Visible = scoresBehavior == "Teams"
		self.Frame.Teams[k].Container.Score.Text = scores[_team_id] or "0"
	end
end

function DuelDisplay:_UpdateMap()
	local name = self.ClientDuel.Map and self.ClientDuel.Map.Model and self.ClientDuel.Map.Model.Name
	self.Frame.Picture.Image = not name and "" or DuelLibrary.Maps[name].Image
	self.Frame.NoPicture.Visible = name == nil
end

function DuelDisplay:_Setup()
	for i = 1, self._num_teams do
		local clone = duelsBoardTeamSlot:Clone()
		clone.Container.Layout.HorizontalAlignment = self._num_teams == 2 and i == 1 and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left
		clone.Container.Score.LayoutOrder = clone.Container.Layout.HorizontalAlignment == Enum.HorizontalAlignment.Right and 99999 or -99999
		clone.Size = UDim2.new(0.9 / self._num_teams, 0, 1, 0)
		clone.LayoutOrder = i * 2
		clone.Name = i
		clone.Parent = self.Frame.Teams
		self._team_slots[i] = clone
		table.insert(self._team_ids, utf8.char(i))
	end

	self.Frame.Teams.Spectate.LayoutOrder = self._num_teams == 2 and 3 or -1

	for _, dueler in pairs(self.ClientDuel.Duelers) do
		task.defer(self._DuelerAdded, self, dueler)
	end
end

function DuelDisplay:_Init()
	self.Frame.SpectateButton.MouseButton1Click:Connect(function()
		SpectateController:SpectateDuelRequest(self.ClientDuel)
	end)
	table.insert(self._connections, self.ClientDuel.MapAdded:Connect(function()
		self:_UpdateMap()
	end))
	table.insert(self._connections, self.ClientDuel:GetDataChangedSignal("Scores"):Connect(function()
		self:_UpdateScores()
	end))
	table.insert(self._connections, self.ClientDuel.DuelerAdded:Connect(function(p)
		self:_DuelerAdded(p)
	end))
	table.insert(self._connections, self.ClientDuel.DuelerRemoved:Connect(function(p)
		self:_DuelerRemoved(p)
	end))
	table.insert(self._connections, self.ClientDuel.DuelerRemoved:Connect(function(p)
		if self._dueler_slots[p] then
			self._dueler_slots[p]:SetDisconnected(true)
		end
	end))
	table.insert(self._connections, self.ClientDuel:GetDataChangedSignal("Status"):Connect(function()
		if self.ClientDuel:Get("Status") == "GameOver" then
			self.GameOver:Fire()
		end
	end))
	self:_Setup()
	self:_UpdateMap()
	self:_UpdateScores()
	ButtonEffect:Add(self.Frame.SpectateButton, nil, {
		TargetElement = self.Frame.Teams.Spectate.Icon
	})
end

return DuelDisplay