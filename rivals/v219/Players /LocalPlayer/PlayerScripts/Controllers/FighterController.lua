local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
game:GetService("RunService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.CONSTANTS)
local EnumLibrary = require(ReplicatedStorage.Modules.EnumLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local ReplicatedController = require(Players.LocalPlayer.PlayerScripts.Modules.ReplicatedController)
local defaultCharacter = Players.LocalPlayer.PlayerScripts.Assets:WaitForChild("Misc"):WaitForChild("DefaultCharacter")
local object = setmetatable({}, ReplicatedController)
object.__index = object

function object._new()
	local self = setmetatable(ReplicatedController.new("Fighter"), object)
	self.LocalFighter = nil
	self._network_id_map = {}
	self._last_connection_level = nil
	self._player_to_fighter = {}
	self._model_to_fighter = {}
	self._last_controls_replicated_time = 0
	self._character_model_cache = {}
	self:_Init()
	return self
end

function object:GetFighter(player)
	local selected = self._player_to_fighter[player] or self._model_to_fighter[player]

	if selected then
		return selected
	end

	if not player then
		return
	end

	if typeof(player) == "Instance" then
		if not player:IsA("Player") then
			return self:GetFighter(Players:GetPlayerFromCharacter(player))
		end

		for k, object3 in pairs(self.Objects) do
			if object3.Player == player then
				return object3, k
			end
		end

		return nil
	else
		if typeof(player) == "number" then
			return self:GetFighter(Players:GetPlayerByUserId(player))
		end

		assert(
			false,
			"Argument 1 invalid, expected a Player or a Model or nil, got " .. tostring(player) .. " (type: " .. (typeof(player) == "Instance" and player.ClassName or typeof(player)) .. ")"
		)
	end
end

function object:GetFighterFromNetworkID(p2)
	return self._network_id_map[p2]
end

function object.GetFightersNotInDuel(p)
	local result = {}

	for _, object2 in pairs(p.Objects) do
		if not object2:Get("IsInDuel") then
			table.insert(result, object2)
		end
	end

	return result
end

function object.GetEntities(p)
	local entities = {}

	for _, object2 in pairs(p.Objects) do
		if object2.Entity then
			table.insert(entities, object2.Entity)
		end
	end

	return entities
end

function object.GetFighterModels(p, p2)
	local models = {}

	for _, object2 in pairs(p.Objects) do
		if not object2.Entity or p2 and object2.IsLocalPlayer then
			continue
		end

		table.insert(models, object2.Entity.Model)
	end

	return models
end

function object:GetWrap(p2)
	for _, object2 in pairs(self.Objects) do
		local item = object2:GetItem(p2)

		if item then
			return item:GetWrap()
		end
	end
end

function object:WaitForFighter(...)
	local fighter

	while true do
		fighter = self:GetFighter(...)

		if fighter then
			break
		end

		self.ObjectAdded:Wait()
	end

	return fighter
end

function object:WaitForLocalFighter()
	return self:WaitForFighter(Players.LocalPlayer)
end

function object:GenerateCharacterModel(p2, p3)
	if self._character_model_cache[tostring(p2)] then
		return self._character_model_cache[tostring(p2)]
	end

	local function generate()
		local success, humanoidDescriptionFromUserIdAsync = pcall(
			Players.GetHumanoidDescriptionFromUserIdAsync,
			Players,
			p2
		)

		if not success then
			warn("Failed to fetch humanoid description:", humanoidDescriptionFromUserIdAsync)
			return
		end

		humanoidDescriptionFromUserIdAsync.Torso = 15365012259
		humanoidDescriptionFromUserIdAsync.LeftArm = 15365010034
		humanoidDescriptionFromUserIdAsync.RightArm = 15365012263
		humanoidDescriptionFromUserIdAsync.LeftLeg = 15365010038
		humanoidDescriptionFromUserIdAsync.RightLeg = 15365010030
		local success2, result = pcall(
			Players.CreateHumanoidModelFromDescriptionAsync,
			Players,
			humanoidDescriptionFromUserIdAsync,
			Enum.HumanoidRigType.R15
		)

		if not success2 then
			warn("Failed to create humanoid model:", result)
			return
		end

		self._preloaded_character_model = result
		local v = {
			Template = result
		}
		self._character_model_cache[tostring(p2)] = v
		return v
	end

	if p3 then
		return generate()
	end

	task.spawn(generate)
	return self._character_model_cache[tostring(p2)] or {
		Template = defaultCharacter
	}
end

function object._VerifyEntityLoop(p)
	local function is_inaccurate()
		return not p.LocalFighter:Get("IsInDuel") and not p.LocalFighter:Get("IsInShootingRange") and Players.LocalPlayer.Character and (not p.LocalFighter.Entity or p.LocalFighter.Entity.Model ~= Players.LocalPlayer.Character)
	end

	while wait(1) do
		if not is_inaccurate() then
			continue
		end

		wait(2)

		if not is_inaccurate() then
			continue
		end

		ReplicatedStorage.Remotes.Replication.Fighter.VerifyClientEntity:FireServer()
		wait(10)
	end
end

function object:_ConnectionLevelReplicationLoop()
	while true do
		wait(1)

		if not (self.LocalFighter and self.LocalFighter:Get("IsInDuel")) then
			continue
		end

		local connectionLevel = Utility:GetConnectionLevel((Utility:GetLocalConnectionPing()))

		if connectionLevel == self._last_connection_level then
			continue
		end

		self._last_connection_level = connectionLevel
		ReplicatedStorage.Remotes.Replication.Fighter.UpdateConnectionLevel:FireServer(connectionLevel)
	end
end

function object:_UpdateNetworkIDMap()
	self._network_id_map = {}

	for _, object2 in pairs(self.Objects) do
		local decodedNetworkID = object2:Get("DecodedNetworkID")

		if decodedNetworkID then
			self._network_id_map[decodedNetworkID] = object2
		end
	end
end

function object:_FighterAdded(object3)
	object3:GetDataChangedSignal("DecodedNetworkID"):Connect(function()
		self:_UpdateNetworkIDMap()
	end)
	object3.EntityAdded:Connect(function(p)
		self._model_to_fighter[p.Model] = object3
	end)
	object3.EntityRemoved:Connect(function(_)
		for k, v in pairs(self._model_to_fighter) do
			if v == object3 then
				self._model_to_fighter[k] = nil
			end
		end
	end)

	if object3.Entity and object3.Entity.Model then
		self._model_to_fighter[object3.Entity.Model] = object3
	end

	self._player_to_fighter[object3.Player] = object3
	self:_UpdateNetworkIDMap()
end

function object:_ReplicateControls()
	if not self.LocalFighter then
		return
	end

	local v = math.max(0.2 - (tick() - self._last_controls_replicated_time), 0.2)
	task.delay(v, function()
		if typeof(ControlsController.CurrentControls) == "string" then
			ReplicatedStorage.Remotes.Replication.Fighter.SetControls:FireServer(ControlsController.CurrentControls)
		end
	end)
end

function object._CameraReplicationLoop(p)
	local function send(p2)
		if p2 and not utf8.len(p2) then
			return
		end

		ReplicatedStorage.Remotes.Replication.Fighter.UpdateCameraRotation:FireServer(p2, nil)
	end

	local v = false
	local v2 = nil

	while true do
		wait(0.1)

		if p.LocalFighter and p.LocalFighter:Get("IsSpectating") and CameraController:GetPublicState() then
			local encodeCameraRotation = Utility:EncodeCameraRotation(CameraController.Rotation)

			if v or encodeCameraRotation ~= v2 then
				task.defer(send, encodeCameraRotation)
			end

			v2 = encodeCameraRotation
			v = false
		elseif not v then
			task.defer(send, Utility:EncodeCameraRotation(Vector2.zero))
			v = true
		end
	end
end

function object:_HookLocalFighter()
	self.LocalFighter = self:WaitForLocalFighter()

	local function update_third_person_overide()
		CameraController:SetThirdPersonOverride(self.LocalFighter:Get("ThirdPersonOverride"))
	end

	self.LocalFighter:GetDataChangedSignal("ThirdPersonOverride"):Connect(update_third_person_overide)
	task.defer(update_third_person_overide)
	local count = 0
	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Event:Connect(function()
		ReplicatedStorage.Remotes.Replication.Fighter.ResetCharacter:FireServer()
	end)

	local function update_reset_button()
		count += 1
		local v = count

		while count == v do
			local success, result = pcall(
				StarterGui.SetCore,
				StarterGui,
				"ResetButtonCallback",
				not self.LocalFighter:Get("IsInDuel") and bindableEvent
			)

			if success then
				break
			end

			warn("Failed to set reset button callback", result)
			wait(0.1)
		end
	end

	self.LocalFighter:GetDataChangedSignal("IsInDuel"):Connect(update_reset_button)
	task.defer(update_reset_button)
	self:_ReplicateControls()
	task.defer(self._CameraReplicationLoop, self)
	task.defer(self._ConnectionLevelReplicationLoop, self)
	task.defer(self._VerifyEntityLoop, self)
end

function object:_Setup()
	function self._reject_object_added_serial_callback(p2)
		return not (p2[EnumLibrary:ToEnum("Player")] or Players:GetPlayerByUserId(p2[EnumLibrary:ToEnum("UserID")]))
	end
end

function object:_Init()
	self.ObjectAdded:Connect(function(p)
		self:_FighterAdded(p)
	end)
	self.ObjectRemoved:Connect(function(p)
		for k, v in pairs(self._player_to_fighter) do
			if v == p then
				self._model_to_fighter[k] = nil
			end
		end

		for k, v in pairs(self._model_to_fighter) do
			if v == p then
				self._model_to_fighter[k] = nil
			end
		end
	end)
	ControlsController.ControlsChanged:Connect(function()
		self:_ReplicateControls()
	end)
	ReplicatedStorage.Remotes.Replication.Fighter.UpdateCameraRotations.OnClientEvent:Connect(function(p)
		local decodeCameraRotationBulk = Utility:DecodeCameraRotationBulk(p)

		for _, list in pairs(decodeCameraRotationBulk) do
			local v, v2, v3 = table.unpack(list)
			local fighterFromNetworkID = self:GetFighterFromNetworkID(v)

			if fighterFromNetworkID then
				fighterFromNetworkID:SetReplicate("CameraRotation", Utility:FromXYToCameraRotation(v2, v3))
			end
		end
	end)

	for _, object3 in pairs(self.Objects) do
		task.spawn(self._FighterAdded, self, object3)
	end

	self:_Setup()
	task.defer(self._HookLocalFighter, self)
end

return object._new()