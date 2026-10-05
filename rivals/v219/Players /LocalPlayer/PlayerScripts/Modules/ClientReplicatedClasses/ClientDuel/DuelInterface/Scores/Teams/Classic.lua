local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local TeammateSlot = require(Players.LocalPlayer.PlayerScripts.Modules.TeammateSlot)
local duelScoresChatBubbleContainer = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DuelScoresChatBubbleContainer")
local duelScoresTeamSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DuelScoresTeamSlot")
local Classic = {}
Classic.__index = Classic

function Classic.new(teams)
	local self = setmetatable({}, Classic)
	self.Teams = teams
	self._connections = {}
	self._team_slots = {}
	self._dueler_slots = {}
	self:_Init()
	return self
end

function Classic:GetChatBubbleContainer(p2)
	for k, _dueler_slot in pairs(self._dueler_slots) do
		if k.Player == p2 then
			return _dueler_slot.ChatBubbleContainer
		end
	end
end

function Classic:Generate()
	self:_Clear()

	if self.Teams.Scores.DuelInterface.ClientDuel:Get("ScoresBehavior") ~= "Teams" or self.Teams.Scores.DuelInterface.ClientDuel:Get("ScoreNeededToWin") then
		return
	end

	for i = 1, self.Teams.Scores.DuelInterface.ClientDuel:Get("NumTeams") do
		local team = DuelLibrary.Teams[i]
		local v = self.Teams.Scores.DuelInterface.ClientDuel.LocalDueler and team.TeamID == self.Teams.Scores.DuelInterface.ClientDuel.LocalDueler:Get("TeamID")

		if not self.Teams.Scores.DuelInterface.ClientDuel.LocalDueler then
			v = i % 2 == 0
		end

		local clone = duelScoresTeamSlot:Clone()
		clone.Background.ImageColor3 = DuelLibrary:GetTeamColor(team.TeamID)
		clone.Container.Position = v and UDim2.new(1, 0, 0.5, 0) or UDim2.new(0, 0, 0.5, 0)
		clone.Container.AnchorPoint = v and Vector2.new(1, 0.5) or Vector2.new(0, 0.5)
		clone.Container.Teammates.Position = v and UDim2.new(0, 0, 0.5, 0) or UDim2.new(1, 0, 0.5, 0)
		clone.Container.Teammates.AnchorPoint = v and Vector2.new(0, 0.5) or Vector2.new(1, 0.5)
		clone.Container.Score.Position = v and UDim2.new(1, 0, 0.5, 0) or UDim2.new(0, 0, 0.5, 0)
		clone.Container.Score.AnchorPoint = v and Vector2.new(1, 0.5) or Vector2.new(0, 0.5)
		clone.Container.Teammates.Layout.HorizontalAlignment = v and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left
		clone.LayoutOrder = i
		clone.Parent = v and self.Teams.LeftFrame or self.Teams.RightFrame
		self._team_slots[i] = clone
		local score = clone.Container.Score
		local layout = clone.Container.Teammates.Layout

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update()
			clone.Size = UDim2.new(0, layout.AbsoluteContentSize.X + score.AbsoluteSize.X, 1, 0)
		end

		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
		score:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
		update() -- equivalent call inferred; original call site unknown
	end

	table.insert(
		self._connections,
		self.Teams.Scores.DuelInterface.ClientDuel:GetDataChangedSignal("Scores"):Connect(function(_)
			self:_UpdateScores()
		end)
	)
	table.insert(self._connections, self.Teams.Scores.DuelInterface.ClientDuel.DuelerAdded:Connect(function(p)
		self:_AddClientDueler(p)
	end))

	if self.Teams.Scores.DuelInterface.ClientDuel:Get("ArcadeMode") then
		table.insert(self._connections, self.Teams.Scores.DuelInterface.ClientDuel.DuelerRemoved:Connect(function(p)
			self:_RemoveClientDueler(p)
		end))
	end

	for k in pairs(self.Teams.Scores.DuelInterface:GetLoggedClientDuelers()) do
		self:_AddClientDueler(k, true)
	end

	self:_UpdateScores()
end

function Classic:Destroy()
	self:_Clear()
end

function Classic:_UpdateScores()
	local scores = self.Teams.Scores.DuelInterface.ClientDuel:Get("Scores")

	for k, _team_slot in pairs(self._team_slots) do
		_team_slot.Container.Score.Text = scores[DuelLibrary.Teams[k].TeamID]
	end
end

function Classic:_RemoveClientDueler(p2)
	local _dueler_slot = self._dueler_slots[p2]

	if not _dueler_slot then
		return
	end

	for _, connection in pairs(_dueler_slot.Connections) do
		connection:Disconnect()
	end

	_dueler_slot.TeammateSlot:Destroy()
	self._dueler_slots[p2] = nil
end

function Classic:_AddClientDueler(object2)
	self:_RemoveClientDueler(object2)
	local connections = {}
	local teammateSlot = TeammateSlot.new(object2.Player.UserId)
	teammateSlot.SlotFrame.Container.Background.Visible = false

	local function update_details()
		local status = self.Teams.Scores.DuelInterface.ClientDuel:Get("Status")
		local teamID = object2:Get("TeamID")
		local v2 = self.Teams.Scores.DuelInterface.ClientDuel.LocalDueler and teamID == self.Teams.Scores.DuelInterface.ClientDuel.LocalDueler:Get("TeamID")
		local controls = object2.ClientFighter:Get("Controls")
		local v3 = object2:GetHealth() / object2:GetMaxHealth()
		local v4 = not table.find(self.Teams.Scores.DuelInterface.ClientDuel.Duelers, object2)
		local v5 = self.Teams.Scores.DuelInterface.ClientDuel.LocalDueler and not v2

		if v5 then
			if status == "RoundFinished" then
				v5 = false
			else
				v5 = status ~= "GameOver"
			end
		end

		local v6

		if not self.Teams.Scores.DuelInterface.ClientDuel.IsRanked then
			v6 = object2.Player:GetAttribute("Level")
		end

		teammateSlot:SetDetails(controls, v3, v4, v5, nil, v6)
	end

	table.insert(
		connections,
		self.Teams.Scores.DuelInterface.ClientDuel:GetDataChangedSignal("Status"):Connect(update_details)
	)
	table.insert(connections, object2.ClientFighter:GetDataChangedSignal("Controls"):Connect(update_details))
	table.insert(connections, object2.Player:GetAttributeChangedSignal("Level"):Connect(update_details))
	table.insert(connections, self.Teams.Scores.DuelInterface.ClientDuel.DuelerRemoved:Connect(update_details))
	table.insert(connections, object2:GetDataChangedSignal("TeamID"):Connect(update_details))
	table.insert(connections, object2.HealthChanged:Connect(update_details))
	update_details()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update_parent()
		local teamID = object2:Get("TeamID")
		local slotFrame = teammateSlot.SlotFrame
		local parent

		if teamID then
			parent = self._team_slots[DuelLibrary.TeamsByID[teamID].TeamIndex].Container.Teammates
		end

		slotFrame.Parent = parent
	end

	table.insert(connections, object2:GetDataChangedSignal("TeamID"):Connect(update_parent))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update_turn()
		teammateSlot:SetStaggeredSpawnsTurn(object2:GetStaggeredSpawnsTurn(), object2:Get("TeamID"))
	end

	table.insert(
		connections,
		self.Teams.Scores.DuelInterface.ClientDuel:GetDataChangedSignal("StaggeredSpawnsOrder"):Connect(update_turn)
	)
	table.insert(connections, object2:GetDataChangedSignal("TeamID"):Connect(update_turn))
	update_turn() -- equivalent call inferred; original call site unknown

	if self.Teams.Scores.DuelInterface.ClientDuel.IsRanked and object2:CanShowRankToLocalPlayer() then
		teammateSlot:SetDisplayELO(object2.Player:GetAttribute("DisplayELO"))
	end

	local clone = duelScoresChatBubbleContainer:Clone()
	clone.Parent = teammateSlot.SlotFrame
	update_parent() -- equivalent call inferred; original call site unknown
	self._dueler_slots[object2] = {
		ClientDueler = object2,
		TeammateSlot = teammateSlot,
		ChatBubbleContainer = clone,
		Connections = connections
	}
end

function Classic:_Clear()
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	for _, _team_slot in pairs(self._team_slots) do
		_team_slot:Destroy()
	end

	for k in pairs(self._dueler_slots) do
		self:_RemoveClientDueler(k)
	end

	self._connections = {}
	self._team_slots = {}
	self._dueler_slots = {}
end

function Classic:_Init() end

return Classic