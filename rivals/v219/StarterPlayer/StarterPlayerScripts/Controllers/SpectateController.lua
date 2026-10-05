local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local InputLibrary = require(ReplicatedStorage.Modules.InputLibrary)
local Signal = require(ReplicatedStorage.Modules.Signal)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local DuelController = require(Players.LocalPlayer.PlayerScripts.Controllers.DuelController)
local Teleporting = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Teleporting)
local Queue = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Queue)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.SubjectChanged = Signal.new()
	self.SubjectEmoteStatusChanged = Signal.new()
	self.DuelSubjectChanged = Signal.new()
	self.DuelSubjectEnvironmentIDChanged = Signal.new()
	self.DuelSubjectStatusChanged = Signal.new()
	self.Subjects = {}
	self.CurrentSubject = nil
	self.CurrentDuelSubject = nil
	self._duel_connections = {}
	self._subject_connections = {}
	self._last_spectating_user_id = nil
	self._spectate_duel_request_queue = {}
	self._spectate_duel_request_queue_active = false
	self._duel_just_spectated = {}
	self._firing_subject_changed = nil
	self._process_mb2_on_input_ended_delta = nil
	self:_Init()
	return self
end

function class.IsRendered(p, p2)
	return CONSTANTS.IS_ARCADE_SERVER or Players.LocalPlayer:GetAttribute("EnvironmentID") == p2 or p.CurrentDuelSubject and p.CurrentDuelSubject:Get("EnvironmentID") == p2
end

function class.IsSubjectEmoting(p)
	return p.CurrentSubject and p.CurrentSubject.Entity and p.CurrentSubject.Entity:IsEmoting()
end

function class:IsThereValidSubject(p)
	for _, subject in pairs(self.Subjects) do
		if subject ~= p and self:_IsValidSubject(subject) then
			return true
		end
	end

	return false
end

function class:Increment(p)
	if not self.CurrentDuelSubject or self.CurrentSubject and self.CurrentSubject.IsLocalPlayer or not self:IsThereValidSubject(self.CurrentSubject) then
		return
	end

	local v = not self.CurrentSubject and 0 or table.find(self.Subjects, self.CurrentSubject) or 0
	local v2

	if v or p ~= 1 then
		if v or p ~= -1 then
			if p == 1 and v == #self.Subjects then
				v2 = 1
			elseif p == -1 and v == 1 then
				v2 = #self.Subjects
			else
				v2 = v + p
			end
		else
			v2 = #self.Subjects
		end
	else
		v2 = 1
	end

	self:_RawSetCurrentSubject(self.Subjects[v2])
	self:_VerifySubject(p == -1)
end

function class:Next()
	self._duel_just_spectated = {}
	self:Increment(1)
end

function class:Last()
	self._duel_just_spectated = {}
	self:Increment(-1)
end

function class:Exit()
	if self.CurrentDuelSubject and not self.CurrentDuelSubject.LocalDueler then
		self:SpectateDuelRequest(nil)
	end
end

function class:SpectateDuelRequest(object)
	if object and not object.LocalDueler and (Queue:IsVisible() or object:Get("Status") == "GameOver") then
		return
	end

	local v = { DuelController:GetDuel(Players.LocalPlayer) or object }
	table.insert(self._spectate_duel_request_queue, v)
	task.spawn(function()
		if self._spectate_duel_request_queue_active then
			return
		end

		self._spectate_duel_request_queue_active = true

		while #self._spectate_duel_request_queue > 0 do
			local v2 = table.remove(self._spectate_duel_request_queue, 1)
			local objectID = self.CurrentDuelSubject and self.CurrentDuelSubject:Get("ObjectID") or nil
			local objectID2 = v2[1] and v2[1]:Get("ObjectID") or nil

			if objectID2 == objectID then
				continue
			end

			ReplicatedStorage.Remotes.Replication.Fighter.SpectateDuel:FireServer(objectID2)
			wait(1)
		end

		self._spectate_duel_request_queue = {}
		self._spectate_duel_request_queue_active = false
	end)
end

function class:Update(p2)
	local fighters = self.CurrentDuelSubject and self.CurrentDuelSubject:GetFighters() or FighterController:GetFightersNotInDuel()

	if FighterController.LocalFighter and not table.find(fighters, FighterController.LocalFighter) then
		table.insert(fighters, FighterController.LocalFighter)
	end

	local v = {}

	for _, fighter in pairs(fighters) do
		if v[fighter.Player] then
			continue
		end

		v[fighter.Player] = true

		if CONSTANTS.IS_TESTING_SERVER then
			fighter:Update(p2)
		else
			local success, result = pcall(fighter.Update, fighter, p2)

			if not success then
				warn("ClientFighter::Update errored:", result)
			end
		end
	end
end

function class:_IsValidSubject(object)
	if not (CameraController:GetPublicState() ~= CameraController.CameraState.States.CustomFreecam and (object and object:IsAlive())) then
		return false
	end

	if self.CurrentDuelSubject and not table.find(self.CurrentDuelSubject:GetFighters(), object) then
		return false
	end

	if not (self.CurrentDuelSubject and self.CurrentDuelSubject.LocalDueler) then
		return true
	end

	if self.CurrentDuelSubject and self.CurrentDuelSubject.LocalDueler and self.CurrentDuelSubject.LocalDueler:IsAlive() then
		return object == self.CurrentDuelSubject.LocalDueler.ClientFighter
	end

	local teamID = self.CurrentDuelSubject.LocalDueler:Get("TeamID")

	if not teamID or self.CurrentDuelSubject:Get("IsCurrentArcadeDuel") then
		return true
	end

	local v = false

	for _, dueler in pairs(self.CurrentDuelSubject.Duelers) do
		if not (dueler:Get("TeamID") == teamID and dueler:IsAlive()) then
			continue
		end

		v = true
		break
	end

	if self.CurrentDuelSubject:Get("StaggeredSpawns") and self.CurrentDuelSubject:Get("Status") ~= "RoundFinished" or v then
		return object:Get("TeamID") == teamID
	end

	return true
end

function class:_RawSetCurrentSubject(currentSubject)
	if currentSubject == self.CurrentSubject then
		return
	end

	for _, _subject_connection in pairs(self._subject_connections) do
		_subject_connection:Disconnect()
	end

	self._subject_connections = {}

	if self.CurrentSubject then
		self.CurrentSubject:SetReplicate("IsSpectating", false)

		if self.CurrentDuelSubject and self.CurrentSubject.Player then
			self._duel_just_spectated[self.CurrentSubject.Player] = tick()
		end
	end

	self.CurrentSubject = currentSubject
	self.SubjectChanged:FireDeferred()

	if self.CurrentSubject then
		self.CurrentSubject:SetReplicate("IsSpectating", true)
	end
end

function class:_VerifySubject(p)
	local v = not self.CurrentSubject and 1 or table.find(self.Subjects, self.CurrentSubject) or 1
	local v2 = p and -1 or 1
	local v3 = nil

	for i = 1, #self.Subjects do
		local v4 = (v + (i - 1) * v2 - 1) % #self.Subjects + 1
		local subject = self.Subjects[v4]

		if not self:_IsValidSubject(subject) then
			continue
		end

		v3 = subject
		break
	end

	if v3 == self.CurrentSubject then
		return
	end

	self:_RawSetCurrentSubject(v3)

	if not self.CurrentSubject then
		return
	end

	local function verify_subject()
		self:_VerifySubject()
	end

	table.insert(self._subject_connections, self.CurrentSubject.EntityRemoved:Connect(verify_subject))
	table.insert(self._subject_connections, self.CurrentSubject.EntityAdded:Connect(verify_subject))
	table.insert(self._subject_connections, self.CurrentSubject.Died:Connect(verify_subject))

	local function entity_added(p2)
		table.insert(self._subject_connections, p2.EmoteStatusChanged:Connect(function()
			self.SubjectEmoteStatusChanged:Fire()
		end))
	end

	table.insert(self._subject_connections, self.CurrentSubject.EntityAdded:Connect(entity_added))

	if self.CurrentSubject.Entity then
		local entity = self.CurrentSubject.Entity
		table.insert(self._subject_connections, entity.EmoteStatusChanged:Connect(function()
			self.SubjectEmoteStatusChanged:Fire()
		end))
	end
end

function class:_CleanupCurrentDuelSubject(p)
	for _, _duel_connection in pairs(self._duel_connections) do
		_duel_connection:Disconnect()
	end

	self._duel_connections = {}
	self._duel_just_spectated = {}

	for i = #self.Subjects, 1, -1 do
		self:_RemoveSubject(self.Subjects[i], true)
	end

	self:_VerifySubject()

	if self.CurrentDuelSubject and self.CurrentDuelSubject ~= p then
		self.CurrentDuelSubject:SetReplicate("IsSpectating", false)

		for _, dueler in pairs(self.CurrentDuelSubject.Duelers) do
			if not dueler.ClientFighter then
				continue
			end

			dueler.ClientFighter:ClearInterface()
			dueler.ClientFighter:ClearSounds(true)
		end
	end
end

function class:_SpectateDuel(currentDuelSubject)
	local duel = DuelController:GetDuel(Players.LocalPlayer)

	if duel and currentDuelSubject ~= duel then
		return
	end

	self:_CleanupCurrentDuelSubject(currentDuelSubject)
	self.CurrentDuelSubject = currentDuelSubject
	self.DuelSubjectChanged:Fire()

	if not self.CurrentDuelSubject then
		return
	end

	self.CurrentDuelSubject:SetReplicate("IsSpectating", true)
	table.insert(
		self._duel_connections,
		self.CurrentDuelSubject:GetDataChangedSignal("EnvironmentID"):Connect(function()
			self.DuelSubjectEnvironmentIDChanged:Fire()
		end)
	)
	table.insert(self._duel_connections, self.CurrentDuelSubject:GetDataChangedSignal("Status"):Connect(function()
		self.DuelSubjectStatusChanged:Fire()
	end))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function verify_subject()
		self:_VerifySubject()
	end

	table.insert(
		self._duel_connections,
		self.CurrentDuelSubject:GetDataChangedSignal("IsCurrentArcadeDuel"):Connect(verify_subject)
	)
	table.insert(self._duel_connections, self.CurrentDuelSubject:GetDataChangedSignal("Status"):Connect(verify_subject))
	task.defer(verify_subject)

	local function dueler_removed(p)
		if p.IsLocalPlayer then
			self:SpectateDuelRequest(nil)
		else
			self:_RemoveSubject(p.ClientFighter)
		end
	end

	table.insert(self._duel_connections, self.CurrentDuelSubject.DuelerRemoved:Connect(dueler_removed))

	local function dueler_added(object2, p)
		table.insert(self._duel_connections, object2:GetDataChangedSignal("TeamID"):Connect(verify_subject))
		table.insert(self._duel_connections, object2.EntityAdded:Connect(verify_subject))
		table.insert(self._duel_connections, object2.Eliminated:Connect(verify_subject))
		table.insert(self._duel_connections, object2.Died:Connect(verify_subject))
		self:_AddSubject(object2.ClientFighter, p)
	end

	table.insert(self._duel_connections, self.CurrentDuelSubject.DuelerAdded:Connect(dueler_added))

	for _, dueler in pairs(self.CurrentDuelSubject.Duelers) do
		task.spawn(dueler_added, dueler, true)
	end

	table.insert(self._duel_connections, self.CurrentDuelSubject.SpectateThisPlayer:Connect(function(p, p2)
		if tick() > (self._duel_just_spectated[p] or 0) + 0.3 then
			return
		end

		local v = nil

		for _, subject in pairs(self.Subjects) do
			if subject.Player ~= p2 then
				continue
			end

			v = subject
			break
		end

		self:_RawSetCurrentSubject(v)
		verify_subject() -- equivalent call inferred; original call site unknown
	end))
end

function class:_AddSubject(p, p2)
	if table.find(self.Subjects, p) then
		return
	end

	table.insert(self.Subjects, p)

	if not p2 then
		self:_VerifySubject()
	end
end

function class:_RemoveSubject(p, p2)
	if p.IsLocalPlayer then
		return
	end

	local index = table.find(self.Subjects, p)

	if not index then
		return
	end

	if p == self.CurrentSubject then
		self:Increment(-1)
	end

	table.remove(self.Subjects, index)

	if not p2 then
		self:_VerifySubject()
	end
end

function class:_SpectatingReplicationLoop()
	while true do
		wait(1)
		local userId = self.CurrentSubject and self.CurrentSubject.Player.UserId

		if userId == self._last_spectating_user_id then
			continue
		end

		self._last_spectating_user_id = userId
		ReplicatedStorage.Remotes.Replication.Fighter.Spectating:FireServer(self._last_spectating_user_id)
	end
end

function class:_ProcessInput(p)
	local v = CameraController:GetPublicState() == CameraController.CameraState.States.CustomFreecam

	if InputLibrary:InputIs(p, "SpectateNext") and not v then
		self:Next()
	elseif InputLibrary:InputIs(p, "SpectateLast") and not v then
		self:Last()
	elseif InputLibrary:InputIs(p, "SpectateExit") then
		self:Exit()
	end
end

function class:_HookLocalFighter()
	local v = FighterController:WaitForLocalFighter()

	local function update_duel_subject()
		local spectatingDuelObjectID = v:Get("SpectatingDuelObjectID")
		local duelByID = spectatingDuelObjectID and DuelController:GetDuelByID(spectatingDuelObjectID) or nil
		self:_SpectateDuel(duelByID)
	end

	v:GetDataChangedSignal("SpectatingDuelObjectID"):Connect(update_duel_subject)
	local spectatingDuelObjectID = v:Get("SpectatingDuelObjectID")
	self:_SpectateDuel(spectatingDuelObjectID and DuelController:GetDuelByID(spectatingDuelObjectID) or nil)
end

function class:_Init()
	self.SubjectChanged:Connect(function()
		self.SubjectEmoteStatusChanged:Fire()
		CameraController:SetSubject(self.CurrentSubject)
	end)
	self.DuelSubjectChanged:Connect(function()
		self:_VerifySubject()
		CameraController.CameraState:SetCustomFreecamEnabled(false)
		CameraController:SetDuelSubject(self.CurrentDuelSubject)
	end)
	RunService:BindToRenderStep("SpectateController", Enum.RenderPriority.Camera.Value + 1, function(p)
		self:Update(p)
	end)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if CameraController:GetPublicState() == CameraController.CameraState.States.ThirdPersonUnlockedMouse and input.UserInputType == Enum.UserInputType.MouseButton2 then
			self._process_mb2_on_input_ended_delta = 0
		else
			self:_ProcessInput(input)
		end
	end)
	UserInputService.InputChanged:Connect(function(input, _)
		if not self._process_mb2_on_input_ended_delta or input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end

		self._process_mb2_on_input_ended_delta += Vector2.new(input.Delta.X, input.Delta.Y).Magnitude
	end)
	UserInputService.InputEnded:Connect(function(input, _)
		local _process_mb2_on_input_ended_delta = self._process_mb2_on_input_ended_delta

		if not _process_mb2_on_input_ended_delta or input.UserInputType ~= Enum.UserInputType.MouseButton2 then
			return
		end

		self._process_mb2_on_input_ended_delta = nil

		if _process_mb2_on_input_ended_delta > 5 then
			return
		end

		self:_ProcessInput(input)
	end)
	FighterController.ObjectAdded:Connect(function(data)
		if not data.IsLocalPlayer then
			return
		end

		data.EntityAdded:Connect(function()
			self:_VerifySubject()
		end)
		data.EntityRemoved:Connect(function()
			self:_VerifySubject()
		end)
		data.Died:Connect(function()
			self:_VerifySubject()
		end)
		self:_AddSubject(data)
	end)
	FighterController.ObjectRemoved:Connect(function(p)
		self:_RemoveSubject(p)
	end)
	DuelController.LocalPlayerJoinedDuel:Connect(function(p, _)
		self:SpectateDuelRequest(p)
	end)
	DuelController.LocalPlayerLeftDuel:Connect(function(_, _)
		self:SpectateDuelRequest(nil)
	end)
	DuelController.ObjectRemoved:Connect(function(p)
		if self.CurrentDuelSubject == p then
			self:SpectateDuelRequest(nil)
		end
	end)
	CameraController.CustomFreecamStateChanged:Connect(function()
		self:_VerifySubject()
	end)
	Teleporting.EnabledChanged:Connect(function()
		if Teleporting.Enabled then
			self:SpectateDuelRequest(nil)
		end
	end)
	Queue.VisibilityChanged:Connect(function()
		if Queue:IsVisible() then
			self:SpectateDuelRequest(nil)
		end
	end)
	self:_VerifySubject()
	task.spawn(self._HookLocalFighter, self)
	task.spawn(self._SpectatingReplicationLoop, self)
end

return class._new()