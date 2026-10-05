local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local TeammateSlot = require(Players.LocalPlayer.PlayerScripts.Modules.TeammateSlot)
local duelScoresTeammateScoreNeededSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DuelScoresTeammateScoreNeededSlot")
local duelScoresTeamScoreNeededSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DuelScoresTeamScoreNeededSlot")
local duelScoresChatBubbleContainer = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DuelScoresChatBubbleContainer")
local ScoreNeeded = {}
ScoreNeeded.__index = ScoreNeeded

function ScoreNeeded.new(teams)
	local self = setmetatable({}, ScoreNeeded)
	self.Teams = teams
	self._connections = {}
	self._team_slots = {}
	self._dueler_slots = {}
	self._bubbles_end_time = nil
	self:_Init()
	return self
end

function ScoreNeeded:GetChatBubbleContainer(p2)
	for k, _dueler_slot in pairs(self._dueler_slots) do
		if k.Player == p2 then
			return _dueler_slot.ChatBubbleContainer
		end
	end
end

function ScoreNeeded:Generate()
	self:_Clear()

	if self.Teams.Scores.DuelInterface.ClientDuel:Get("ScoresBehavior") ~= "Teams" or not self.Teams.Scores.DuelInterface.ClientDuel:Get("ScoreNeededToWin") then
		return
	end

	if self.Teams.Scores.DuelInterface.ClientDuel:Get("VoteOptions") then
		self._bubbles_end_time = nil
		return
	end

	self._bubbles_end_time = self._bubbles_end_time or tick() + 12
	local v = tick() < self._bubbles_end_time
	local bubbles = {}

	for i = 1, self.Teams.Scores.DuelInterface.ClientDuel:Get("NumTeams") do
		local team = DuelLibrary.Teams[i]
		local v2 = self.Teams.Scores.DuelInterface.ClientDuel.LocalDueler and team.TeamID == self.Teams.Scores.DuelInterface.ClientDuel.LocalDueler:Get("TeamID")

		if not self.Teams.Scores.DuelInterface.ClientDuel.LocalDueler then
			v2 = i % 2 == 0
		end

		local teamColor = DuelLibrary:GetTeamColor(team.TeamID)
		local color = Color3.new(teamColor.R * 0.5, teamColor.G * 0.5, teamColor.B * 0.5)
		local clone = duelScoresTeamScoreNeededSlot:Clone()
		clone.Container.Bubble.Visible = v2 and v
		clone.Container.Progress.Bar.BackgroundColor3 = color
		clone.Container.Progress.Bar.UIStroke.Color = color
		clone.Container.Progress.Bar.Bar.BackgroundColor3 = teamColor
		clone.Container.Progress.Bar.Bar.UIStroke.Color = teamColor
		clone.AnchorPoint = v2 and Vector2.new(1, 0) or Vector2.new(0, 0)
		clone.Container.AnchorPoint = v2 and Vector2.new(1, 0.5) or Vector2.new(0, 0.5)
		clone.Container.Position = v2 and UDim2.new(1, 0, 0.5, 0) or UDim2.new(0, 0, 0.5, 0)
		clone.Container.Progress.Position = v2 and UDim2.new(1, 0, 0.5, 0) or UDim2.new(0, 0, 0.5, 0)
		clone.Container.Progress.AnchorPoint = v2 and Vector2.new(1, 0.5) or Vector2.new(0, 0.5)
		clone.Container.Progress.Bar.Bar.Position = v2 and UDim2.new(0, -1, 0.5, 0) or UDim2.new(1, 1, 0.5, 0)
		clone.Container.Progress.Bar.Bar.AnchorPoint = v2 and Vector2.new(0, 0.5) or Vector2.new(1, 0.5)
		clone.Container.Progress.Bar.Bar.Value.AnchorPoint = v2 and Vector2.new(1, 0.5) or Vector2.new(0, 0.5)
		clone.Container.Progress.Bar.Bar.Value.Position = v2 and UDim2.new(1, 0, 0.5, 0) or UDim2.new(0, 0, 0.5, 0)
		clone.Container.Progress.Bar.Bar.Value.Title.AnchorPoint = v2 and Vector2.new(1, 0.5) or Vector2.new(0, 0.5)
		clone.Container.Progress.Bar.Bar.Value.Title.Position = v2 and UDim2.new(0.875, 0, 0.5, 0) or UDim2.new(
			0.125,
			0,
			0.5,
			0
		)
		clone.Container.Progress.Bar.Bar.Value.Title.TextXAlignment = v2 and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
		clone.Container.Teammates.Position = v2 and UDim2.new(-7.5, 0, 1.75, 0) or UDim2.new(8.5, 0, 1.75, 0)
		clone.Container.Teammates.Layout.HorizontalAlignment = v2 and Enum.HorizontalAlignment.Left or Enum.HorizontalAlignment.Right
		clone.LayoutOrder = i
		clone.Parent = v2 and self.Teams.LeftFrame or self.Teams.RightFrame
		self._team_slots[i] = clone
		table.insert(bubbles, clone.Container.Bubble)
		local background = clone.Container.Bubble.Container.Background
		local title = clone.Container.Bubble.Container.Title

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update()
			background.Size = UDim2.new(1.625, title.TextBounds.X, 1, 0)
		end

		title:GetPropertyChangedSignal("TextBounds"):Connect(update)
		update() -- equivalent call inferred; original call site unknown
	end

	if v then
		local thread = task.spawn(function()
			while true do
				for _, v2 in pairs(bubbles) do
					if v2:IsDescendantOf(Players) then
						v2:TweenPosition(UDim2.new(1, 0, 1.5, 0), "Out", "Sine", 0.5, true)
					end
				end

				wait(0.5)

				for _, v2 in pairs(bubbles) do
					if v2:IsDescendantOf(Players) then
						v2:TweenPosition(UDim2.new(1, 0, 1.25, 0), "In", "Sine", 0.5, true)
					end
				end

				wait(0.5)
			end
		end)
		task.delay(self._bubbles_end_time - tick(), function()
			task.cancel(thread)

			for _, v2 in pairs(bubbles) do
				v2.Visible = false
			end
		end)
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

function ScoreNeeded:Destroy()
	self:_Clear()
end

function ScoreNeeded:_UpdateScores()
	local scoreNeededToWin = self.Teams.Scores.DuelInterface.ClientDuel:Get("ScoreNeededToWin")
	local scores = self.Teams.Scores.DuelInterface.ClientDuel:Get("Scores")

	for k, _team_slot in pairs(self._team_slots) do
		local score = scores[DuelLibrary.Teams[k].TeamID]
		_team_slot.Container.Bubble.Container.Title.Text = Utility:PrettyNumber(scoreNeededToWin) .. " points to win"
		_team_slot.Container.Progress.Bar.Bar.Value.Title.Text = " " .. Utility:PrettyNumber(score) .. " "
		_team_slot.Container.Progress.Bar.Bar.Size = UDim2.new(math.clamp(score / scoreNeededToWin, 0.125, 1), 2, 1, 2)
	end
end

function ScoreNeeded:_RemoveClientDueler(p2)
	local _dueler_slot = self._dueler_slots[p2]

	if not _dueler_slot then
		return
	end

	for _, connection in pairs(_dueler_slot.Connections) do
		connection:Disconnect()
	end

	_dueler_slot.PlayerSlot:Destroy()
	_dueler_slot.TeammateSlot:Destroy()
	self._dueler_slots[p2] = nil
end

function ScoreNeeded:_AddClientDueler(object2)
	self:_RemoveClientDueler(object2)
	local connections = {}
	local clone = duelScoresTeammateScoreNeededSlot:Clone()

	local function update_parent()
		local teamID = object2:Get("TeamID")
		local v = clone
		local parent

		if teamID then
			parent = self._team_slots[DuelLibrary.TeamsByID[teamID].TeamIndex].Container.Teammates
		end

		v.Parent = parent
	end

	table.insert(connections, object2:GetDataChangedSignal("TeamID"):Connect(update_parent))
	local teammateSlot = TeammateSlot.new(object2.Player.UserId, nil, nil, nil, true)
	teammateSlot.SlotFrame.Container.Size = UDim2.new(0.825, 0, 0.825, 0)
	teammateSlot.SlotFrame.Container.Headshot.UICorner.CornerRadius = UDim.new(1, 0)
	teammateSlot.SlotFrame.Container.Background.Visible = false
	teammateSlot.SlotFrame.Parent = clone
	local clone2 = duelScoresChatBubbleContainer:Clone()
	clone2.Size = UDim2.new(1.5, 0, 1.5, 0)
	clone2.Position = UDim2.new(0.5, 0, 1.25, 0)
	clone2.Parent = teammateSlot.SlotFrame
	local teamID = object2:Get("TeamID")
	local parent2

	if teamID then
		parent2 = self._team_slots[DuelLibrary.TeamsByID[teamID].TeamIndex].Container.Teammates
	end

	clone.Parent = parent2
	self._dueler_slots[object2] = {
		ClientDueler = object2,
		PlayerSlot = clone,
		TeammateSlot = teammateSlot,
		ChatBubbleContainer = clone2,
		Connections = connections
	}
end

function ScoreNeeded:_Clear()
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

function ScoreNeeded:_Init() end

return ScoreNeeded