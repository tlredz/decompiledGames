local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local TeammateSlot = require(Players.LocalPlayer.PlayerScripts.Modules.TeammateSlot)
local duelScoresDuelerTeamBackground = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DuelScoresDuelerTeamBackground")
local duelScoresChatBubbleContainer = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DuelScoresChatBubbleContainer")
local duelScoresDuelerSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DuelScoresDuelerSlot")
local Duelers = {}
Duelers.__index = Duelers

function Duelers.new(scores)
	local self = setmetatable({}, Duelers)
	self.Scores = scores
	self.Frame = self.Scores.Frame:WaitForChild("Duelers")
	self.Container = self.Frame:WaitForChild("Container")
	self._connections = {}
	self._dueler_slots = {}
	self:_Init()
	return self
end

function Duelers:GetChatBubbleContainer(p2)
	local v = nil

	for k, _dueler_slot in pairs(self._dueler_slots) do
		local v2 = k.Player == p2
		v = v or v2 and _dueler_slot.ChatBubbleContainer
		_dueler_slot.TeammateSlot.SlotFrame.ZIndex = v2 and 2 or 1
	end

	return v
end

function Duelers:Generate()
	self:_Clear()

	if self.Scores.DuelInterface.ClientDuel:Get("ScoresBehavior") ~= "Duelers" or self.Scores.DuelInterface.ClientDuel:Get("VoteOptions") then
		return
	end

	table.insert(
		self._connections,
		self.Scores.DuelInterface.ClientDuel:GetDataChangedSignal("Scores"):Connect(function(_)
			self:_UpdateRanks()
		end)
	)
	table.insert(self._connections, self.Scores.DuelInterface.ClientDuel.DuelerAdded:Connect(function(p)
		self:_AddClientDueler(p)
	end))

	if self.Scores.DuelInterface.ClientDuel:Get("ArcadeMode") then
		table.insert(self._connections, self.Scores.DuelInterface.ClientDuel.DuelerRemoved:Connect(function(p)
			self:_RemoveClientDueler(p)
		end))
	end

	for k in pairs(self.Scores.DuelInterface:GetLoggedClientDuelers()) do
		self:_AddClientDueler(k, true)
	end

	self:_UpdateRanks()
end

function Duelers:Destroy()
	self:_Clear()
end

function Duelers:_UpdateRanks()
	task.defer(function()
		local loggedClientDuelers = self.Scores.DuelInterface:GetLoggedClientDuelers(true)

		for k, loggedClientDueler in pairs(loggedClientDuelers) do
			local _dueler_slot = self._dueler_slots[loggedClientDueler]

			if not _dueler_slot then
				continue
			end

			_dueler_slot.TeammateSlot.SlotFrame.LayoutOrder = k
			_dueler_slot.TeammateSlot.SlotFrame.Visible = k <= 9 or loggedClientDueler.IsLocalPlayer
			_dueler_slot.ScoreSlot.Rank.Text = "#" .. k
		end
	end)
end

function Duelers:_RemoveClientDueler(p, p2)
	local _dueler_slot = self._dueler_slots[p]

	if not _dueler_slot then
		return
	end

	for _, connection in pairs(_dueler_slot.Connections) do
		connection:Disconnect()
	end

	_dueler_slot.TeammateSlot:Destroy()
	self._dueler_slots[p] = nil

	if not p2 then
		self:_UpdateRanks()
	end
end

function Duelers:_AddClientDueler(object2, p)
	self:_RemoveClientDueler(object2, p)
	local connections = {}
	local teammateSlot = TeammateSlot.new(object2.Player.UserId, nil, nil, nil, true)
	local clone = duelScoresDuelerTeamBackground:Clone()
	clone.Parent = teammateSlot.SlotFrame.Container.Background
	local imageTransparency = teammateSlot.SlotFrame.Container.Background.ImageTransparency

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update_team()
		local teamID = object2:Get("TeamID")
		teammateSlot.SlotFrame.Container.Background.ImageTransparency = teamID and 1 or imageTransparency
		clone.ImageColor3 = DuelLibrary:GetTeamColor(teamID)
		clone.Visible = teamID ~= nil
	end

	table.insert(connections, object2:GetDataChangedSignal("TeamID"):Connect(update_team))
	update_team() -- equivalent call inferred; original call site unknown
	local clone2 = duelScoresDuelerSlot:Clone()
	clone2.Parent = teammateSlot.SlotFrame

	local function update_score()
		local prettyNumber = Utility:PrettyNumber(self.Scores.DuelInterface.ClientDuel:Get("Scores")[object2:Get("DuelerID")])
		local _ = object2 and object2.ClientFighter and object2.ClientFighter.Items[1] and ItemLibrary.ViewModels[object2.ClientFighter.Items[1].Name].EliminationFeedImage
		clone2.Score.Text = prettyNumber
		clone2.Weapon.Image = ""
	end

	table.insert(
		connections,
		self.Scores.DuelInterface.ClientDuel:GetDataChangedSignal("IsGunGame"):Connect(update_score)
	)
	table.insert(connections, self.Scores.DuelInterface.ClientDuel:GetDataChangedSignal("Scores"):Connect(update_score))
	update_score()
	local clone3 = duelScoresChatBubbleContainer:Clone()
	clone3.Position = UDim2.new(0.5, 0, 1.375, 0)
	clone3.Parent = teammateSlot.SlotFrame
	teammateSlot.SlotFrame.Parent = self.Container
	self._dueler_slots[object2] = {
		ClientDueler = object2,
		TeammateSlot = teammateSlot,
		ScoreSlot = clone2,
		ChatBubbleContainer = clone3,
		Connections = connections
	}

	if not p then
		self:_UpdateRanks()
	end
end

function Duelers:_Clear()
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	for k in pairs(self._dueler_slots) do
		self:_RemoveClientDueler(k)
	end

	self._connections = {}
	self._dueler_slots = {}
end

function Duelers:_Init() end

return Duelers