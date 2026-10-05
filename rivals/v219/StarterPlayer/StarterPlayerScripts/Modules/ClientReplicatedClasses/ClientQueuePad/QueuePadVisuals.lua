local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local EventLibrary = require(ReplicatedStorage.Modules.EventLibrary)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local TeammateSlot = require(Players.LocalPlayer.PlayerScripts.Modules.TeammateSlot)
local lobbyVisuals = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("LobbyVisuals")
local queuePadPlayerSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("QueuePadPlayerSlot")
local QueuePadVisuals = {}
QueuePadVisuals.__index = QueuePadVisuals

function QueuePadVisuals.new(clientQueuePad)
	local self = setmetatable({}, QueuePadVisuals)
	self.ClientQueuePad = clientQueuePad
	self._visuals_folder = self.ClientQueuePad:Get("Model"):WaitForChild("Visuals")
	self._teammate_slots = {}
	self._team_slots = {}
	self._pads = {}
	self._surface_guis = {}
	self:_Init()
	return self
end

function QueuePadVisuals:Destroy()
	for _, v in pairs(self._surface_guis) do
		v:Destroy()
	end
end

function QueuePadVisuals:_UpdateQueueName()
	local numTeams = self.ClientQueuePad:Get("NumTeams")
	local playersPerTeam = self.ClientQueuePad:Get("PlayersPerTeam")
	local infinitePlayersPerTeam = self.ClientQueuePad:Get("InfinitePlayersPerTeam")
	local actualQueueName = self.ClientQueuePad:GetActualQueueName()
	local matchmakingQueue = DuelLibrary.MatchmakingQueues[actualQueueName]

	for k, v in pairs(self._surface_guis) do
		local warning = v.MainFrame.Warning
		warning.Visible = k == 1 and not (matchmakingQueue and matchmakingQueue.AreStreaksDisabled()) and CONSTANTS.IS_PUBLIC_SERVER
	end

	local titleName = matchmakingQueue and matchmakingQueue.TitleName
	local v = string.rep((infinitePlayersPerTeam and "∞" or playersPerTeam) .. "v", numTeams)
	local text = string.sub(v, 1, #v - 1)
	local textLabel = self._visuals_folder:WaitForChild("QueueName"):WaitForChild("Players"):WaitForChild("SurfaceGui"):WaitForChild("TextLabel")
	textLabel.Text = text
	local textLabel_2 = self._visuals_folder:WaitForChild("QueueName"):WaitForChild("Title"):WaitForChild("SurfaceGui"):WaitForChild("Frame"):WaitForChild("TextLabel")
	textLabel_2.Text = titleName or ""
	local surfaceGui = self._visuals_folder:WaitForChild("QueueName"):WaitForChild("Title"):WaitForChild("SurfaceGui")
	surfaceGui.Enabled = titleName
	local title = self._visuals_folder:WaitForChild("QueueName"):WaitForChild("Title")
	title.Transparency = titleName and 0.4 or 1
end

function QueuePadVisuals:_Update()
	for _, _teammate_slot in pairs(self._teammate_slots) do
		_teammate_slot:Destroy()
	end

	self._teammate_slots = {}
	local playersPerTeam = self.ClientQueuePad:Get("PlayersPerTeam")
	local infinitePlayersPerTeam = self.ClientQueuePad:Get("InfinitePlayersPerTeam")
	local clientFightersWaiting = self.ClientQueuePad:GetClientFightersWaiting()

	for k, v in pairs(clientFightersWaiting) do
		local _team_slot = self._team_slots[k]
		local v2

		if infinitePlayersPerTeam then
			v2 = #v or playersPerTeam
		else
			v2 = playersPerTeam
		end

		_team_slot.Slot.Title.Text = #v .. "/" .. (infinitePlayersPerTeam and "∞" or playersPerTeam)
		local full = _team_slot.Slot.Full
		full.Visible = playersPerTeam <= #v and not infinitePlayersPerTeam
		_team_slot.SetCellSize(v2)
		_team_slot.CreatePlayerSlots(v2)

		for k2, v4 in pairs(v) do
			local playerSlot = _team_slot.PlayerSlots[k2]

			if not playerSlot then
				continue
			end

			local v5 = TeammateSlot.new(
				v4.Player.UserId,
				v4:Get("Controls"),
				1,
				false,
				true,
				v4.Player:GetAttribute("StatisticDuelsWinStreak"),
				v4.Player:GetAttribute("Level")
			)
			v5.SlotFrame.Container.Background.Visible = false
			v5.SlotFrame.Parent = playerSlot
			table.insert(self._teammate_slots, v5)
		end
	end

	for k, _pad in pairs(self._pads) do
		local team = DuelLibrary.Teams[k]
		local v = #clientFightersWaiting[k] > 0
		local anchored = not v
		local padColor = v and team.PadColor or Color3.fromRGB(202, 203, 209)
		local padColor2 = v and team.PadColor2 or Color3.fromRGB(252, 250, 255)

		if EventLibrary.LOBBY_VISUALS_PROFILE == "Festive" then
			_pad.Outer.Anchored = anchored
			_pad.Inner.Anchored = anchored
			_pad.Glow.Transparency = v and 0.02 or 1
			_pad.Outer.Transparency = v and 0.02 or 1
			_pad.Inner.Transparency = v and 0.02 or 1
			_pad.Extra.Ribbon.Transparency = v and 0 or 1
		elseif EventLibrary.LOBBY_VISUALS_PROFILE == "Spooky" then
			_pad.Outer.Anchored = anchored
			_pad.Inner.Anchored = anchored
			_pad.Glow.Transparency = v and 0.02 or 1
			_pad.Glow.Color = padColor
		else
			_pad.Outer.Anchored = anchored
			_pad.Outer2.Anchored = anchored
			_pad.Outer3.Anchored = anchored
			_pad.Inner.Anchored = anchored
			_pad.Inner2.Anchored = anchored
			_pad.Inner3.Anchored = anchored
			_pad.Glow.Transparency = v and 0.02 or 1
			_pad.Outer.Transparency = v and 0 or 0.75
			_pad.Inner.Transparency = v and 0 or 0.75
			_pad.Glow.Color = padColor
			_pad.Inner.Color = padColor
			_pad.Outer.Color = padColor
			_pad.Inner2.Color = padColor2
			_pad.Inner3.Color = padColor2
			_pad.Outer2.Color = padColor2
			_pad.Outer3.Color = padColor2
		end
	end

	self:_UpdateQueueName()
end

function QueuePadVisuals:_SetupSurfaceGui(layoutOrder)
	local team = DuelLibrary.Teams[layoutOrder]
	local clone = (lobbyVisuals:FindFirstChild(EventLibrary.LOBBY_VISUALS_PROFILE) and lobbyVisuals[EventLibrary.LOBBY_VISUALS_PROFILE]:FindFirstChild("QueuePadBoardGui") or lobbyVisuals.Default.QueuePadBoardGui):Clone()
	clone.Name ..= self.ClientQueuePad:Get("Model").Name
	local clone2 = (lobbyVisuals:FindFirstChild(EventLibrary.LOBBY_VISUALS_PROFILE) and lobbyVisuals[EventLibrary.LOBBY_VISUALS_PROFILE]:FindFirstChild("QueuePadTeamSlot") or lobbyVisuals.Default.QueuePadTeamSlot):Clone()
	clone2.Logo.Image = team.Logo
	clone2.LayoutOrder = layoutOrder
	clone2.Parent = clone.MainFrame.TeamSlotContainer
	local clones = {}

	local function create_player_slots(p)
		for _, v in pairs(clones) do
			v:Destroy()
		end

		table.clear(clones)

		for i = 1, p do
			local clone3 = queuePadPlayerSlot:Clone()
			clone3.LayoutOrder = i
			clone3.Parent = clone2.Players
			clones[i] = clone3
		end
	end

	local function set_cell_size(p)
		local v = 1 / math.ceil((math.sqrt((math.max(p, 1)))))
		clone2.Players.Layout.CellSize = UDim2.new(v, -1, v, -1)
	end

	clone.Adornee = self._visuals_folder:WaitForChild("Board" .. layoutOrder)
	clone.Parent = Players.LocalPlayer.PlayerGui
	self._surface_guis[layoutOrder] = clone
	self._team_slots[layoutOrder] = {
		Slot = clone2,
		PlayerSlots = clones,
		SetCellSize = set_cell_size,
		CreatePlayerSlots = create_player_slots
	}
end

function QueuePadVisuals:_SetupPad(p)
	local waitForChild = self.ClientQueuePad:Get("Model"):WaitForChild("Important"):WaitForChild("Team" .. p)
	waitForChild.Transparency = 1
	local child = self._visuals_folder:WaitForChild("Team" .. p)
	local clone = child:Clone()
	clone.Outer.CanCollide = false
	clone.Outer.CanTouch = false
	clone.Outer.CanQuery = false
	clone.Outer.Anchored = true
	local attachment = Instance.new("Attachment")
	attachment.CFrame = CFrame.Angles(0, 0, 1.5707963267948966)
	attachment.Parent = clone.Outer
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.RigidityEnabled = true
	alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPosition.Position = clone.Outer.Position
	alignPosition.Attachment0 = attachment
	alignPosition.Parent = clone.Outer
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.CFrame = attachment.WorldCFrame
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.AlignType = Enum.AlignType.PrimaryAxisParallel
	alignOrientation.RigidityEnabled = true
	alignOrientation.Attachment0 = attachment
	alignOrientation.Parent = clone.Outer
	local angularVelocity = Instance.new("AngularVelocity")
	angularVelocity.AngularVelocity = Vector3.new(0, 2 * (p % 2 == 0 and 1 or -1), 0)
	angularVelocity.MaxTorque = 10000
	angularVelocity.Attachment0 = attachment
	angularVelocity.Parent = clone.Outer
	clone.Inner.CanCollide = false
	clone.Inner.CanTouch = false
	clone.Inner.CanQuery = false
	clone.Inner.Anchored = true
	local attachment2 = Instance.new("Attachment")
	attachment2.CFrame = CFrame.Angles(0, 0, 1.5707963267948966)
	attachment2.Parent = clone.Inner
	local alignPosition2 = Instance.new("AlignPosition")
	alignPosition2.RigidityEnabled = true
	alignPosition2.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPosition2.Position = clone.Inner.Position
	alignPosition2.Attachment0 = attachment2
	alignPosition2.Parent = clone.Inner
	local alignOrientation2 = Instance.new("AlignOrientation")
	alignOrientation2.CFrame = attachment2.WorldCFrame
	alignOrientation2.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation2.AlignType = Enum.AlignType.PrimaryAxisParallel
	alignOrientation2.RigidityEnabled = true
	alignOrientation2.Attachment0 = attachment2
	alignOrientation2.Parent = clone.Inner
	local angularVelocity2 = Instance.new("AngularVelocity")
	angularVelocity2.AngularVelocity = Vector3.new(0, -2 * (p % 2 == 0 and 1 or -1), 0)
	angularVelocity2.MaxTorque = 10000
	angularVelocity2.Attachment0 = attachment2
	angularVelocity2.Parent = clone.Inner
	clone.Parent = child.Parent
	self._pads[p] = clone
	child:Destroy()
end

function QueuePadVisuals:_Setup()
	for i = 1, self.ClientQueuePad:Get("NumTeams") do
		self:_SetupSurfaceGui(i)
		self:_SetupPad(i)
	end

	self:_Update()
end

function QueuePadVisuals:_Init()
	self.ClientQueuePad.Activity:Connect(function()
		self:_Update()
	end)
	task.spawn(self._Setup, self)
end

return QueuePadVisuals