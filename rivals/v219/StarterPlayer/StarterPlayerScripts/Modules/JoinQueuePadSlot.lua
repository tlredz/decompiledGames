local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Signal = require(ReplicatedStorage.Modules.Signal)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local joinQueuePadPlayerSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("JoinQueuePadPlayerSlot")
local joinQueuePadTeamSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("JoinQueuePadTeamSlot")
local joinQueuePadTitleVS = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("JoinQueuePadTitleVS")
local joinQueuePadSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("JoinQueuePadSlot")
local JoinQueuePadSlot = {}
JoinQueuePadSlot.__index = JoinQueuePadSlot

function JoinQueuePadSlot.new(clientQueuePad)
	local self = setmetatable({}, JoinQueuePadSlot)
	self.VisibilityChanged = Signal.new()
	self.ClientQueuePad = clientQueuePad
	self.Frame = joinQueuePadSlot:Clone()
	self._team_slots = {}
	self._extra_team_related_objects = {}
	self._update_hash = 0
	self:_Init()
	return self
end

function JoinQueuePadSlot.IsVisible(p)
	return p.Frame.Visible
end

function JoinQueuePadSlot:_Update()
	local clientFightersWaiting = self.ClientQueuePad:GetClientFightersWaiting()
	local count = 0

	for i = 1, self.ClientQueuePad:Get("NumTeams") do
		for i2 = 1, self.ClientQueuePad:Get("PlayersPerTeam") do
			local playerSlot = self._team_slots[i].PlayerSlots[i2]
			local v = clientFightersWaiting[i][i2]

			if v then
				count += 1
				playerSlot.Headshot.Image = string.format(CONSTANTS.HEADSHOT_IMAGE, v.Player.UserId)
				playerSlot.Dots:RemoveTag("UILoadingDots")
				playerSlot.Dots.Visible = false
			else
				playerSlot.Headshot.Image = ""
				playerSlot.Dots:AddTag("UILoadingDots")
				playerSlot.Dots.Visible = true
			end
		end
	end

	local v

	if count > 0 then
		v = count < self.ClientQueuePad:Get("NumTeams") * self.ClientQueuePad:Get("PlayersPerTeam")
	else
		v = false
	end

	if v then
		task.spawn(function()
			local _update_hash = self._update_hash
			wait(1)

			if _update_hash ~= self._update_hash or self.Frame.Visible then
				return
			end

			self._update_hash += 1
			self.Frame.Visible = true
			self.VisibilityChanged:Fire()
			self.Frame.Container.Position = UDim2.new(4, 0, 0, 0)
			self.Frame.Container:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quint", 0.5, true)
		end)
		return
	end

	self._update_hash += 1
	self.Frame.Visible = false
	self.VisibilityChanged:Fire()
end

function JoinQueuePadSlot:_Generate()
	for _, _team_slot in pairs(self._team_slots) do
		_team_slot.Slot:Destroy()
	end

	for _, _extra_team_related_object in pairs(self._extra_team_related_objects) do
		_extra_team_related_object:Destroy()
	end

	self._team_slots = {}
	self._extra_team_related_objects = {}
	local v = 1 / math.ceil((math.sqrt((self.ClientQueuePad:Get("PlayersPerTeam")))))
	local count = 0

	for i = 1, self.ClientQueuePad:Get("NumTeams") do
		count += 1
		local clone = joinQueuePadTeamSlot:Clone()
		clone.LayoutOrder = count
		clone.Container.Layout.CellSize = UDim2.new(v, 0, v, 0)
		clone.Container.Layout.StartCorner = self.ClientQueuePad:Get("NumTeams") == 2 and i == 2 and Enum.StartCorner.TopRight or Enum.StartCorner.TopLeft
		clone.Parent = self.Frame.Container.Details
		local clones = {}

		for i2 = 1, self.ClientQueuePad:Get("PlayersPerTeam") do
			local clone2 = joinQueuePadPlayerSlot:Clone()
			clone2.LayoutOrder = i2
			clone2.Parent = clone.Container
			clones[i2] = clone2
		end

		self._team_slots[i] = {
			Slot = clone,
			PlayerSlots = clones
		}

		if not (i < self.ClientQueuePad:Get("NumTeams")) then
			continue
		end

		count += 1
		local clone2 = joinQueuePadTitleVS:Clone()
		clone2.LayoutOrder = count
		clone2.Parent = self.Frame.Container.Details
		table.insert(self._extra_team_related_objects, clone2)
	end

	local v2 = 0.3333333333333333 * (self.ClientQueuePad:Get("NumTeams") - 2)
	self.Frame.Size = UDim2.new(0.6666666666666666 + v2, 0, 0.4, 0)
end

function JoinQueuePadSlot:_Setup()
	self.Frame.Container.Background.ImageColor3 = UILibrary.BUTTON_BACKGROUND_COLOR
	self.Frame.Container.Background.ImageTransparency = UILibrary.BUTTON_BACKGROUND_TRANSPARENCY
end

function JoinQueuePadSlot:_Init()
	self.Frame.Container.Join.MouseButton1Click:Connect(function()
		if FighterController.LocalFighter and FighterController.LocalFighter:IsAlive() then
			FighterController.LocalFighter.Entity.Model:PivotTo(CFrame.new(self.ClientQueuePad:GetTeleportPosition()) * FighterController.LocalFighter.Entity.Model:GetPivot().Rotation)
		end
	end)
	self.ClientQueuePad.Activity:Connect(function(p)
		if p == "PlayersPerTeam" then
			self:_Generate()
		end

		self:_Update()
	end)
	self:_Setup()
	self:_Generate()
	self:_Update()
	ButtonEffect:Add(self.Frame.Container.Join)
end

return JoinQueuePadSlot