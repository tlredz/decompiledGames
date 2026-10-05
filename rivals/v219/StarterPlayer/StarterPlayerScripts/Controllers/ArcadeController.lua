local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local RotatingQueueLibrary = require(ReplicatedStorage.Modules.RotatingQueueLibrary)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local DuelController = require(Players.LocalPlayer.PlayerScripts.Controllers.DuelController)
local SendChat = require(Players.LocalPlayer.PlayerScripts.Modules.Functions.SendChat)
local rotatingQueueHolograms = Players.LocalPlayer.PlayerScripts.Assets.RotatingQueueHolograms
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.DuelSet = Signal.new()
	self.UpdateJoinCooldown = Signal.new()
	self.CurrentDuel = nil
	self._local_fighter = nil
	self._has_joined_arcade_duel = false
	self._hologram_loop_thread = nil
	self._rotating_queue_hologram = nil
	self._join_cooldown_hash = 0
	self:_Init()
	return self
end

function class:GetJoinCooldown()
	return (math.ceil(self._local_fighter and self._local_fighter:GetJoinCooldown() or 0))
end

function class:CanJoin()
	local currentDuel = self.CurrentDuel

	if currentDuel then
		if self.CurrentDuel:Get("Status") == "GameOver" then
			currentDuel = false
		else
			currentDuel = self:GetJoinCooldown() <= 0
		end
	end

	return currentDuel
end

function class.ToArcadeServer(_, p)
	return ReplicatedStorage.Remotes.Arcade.TeleportToArcadeServer:InvokeServer(p)
end

function class:Join()
	self._has_joined_arcade_duel = true
	ReplicatedStorage.Remotes.Arcade.Join:FireServer()
end

function class:_UpdateHologram(p2)
	if self._rotating_queue_hologram then
		self._rotating_queue_hologram:Destroy()
		self._rotating_queue_hologram = nil
	end

	local parent = CollectionService:GetTagged("LobbyRotatingQueueHologram")[1]

	if not parent then
		return
	end

	task.defer(function()
		local DELETE_AT_RUNTIME = parent:WaitForChild("DELETE_AT_RUNTIME", 2)

		if DELETE_AT_RUNTIME then
			task.defer(DELETE_AT_RUNTIME.Destroy, DELETE_AT_RUNTIME)
		end
	end)
	local primary = parent:WaitForChild("Primary")
	local particles = parent:WaitForChild("Particles")
	local emit = particles:WaitForChild("Emit")
	local attachment = particles:WaitForChild("Attachment")
	local proximityPrompt = parent:WaitForChild("Prompt"):WaitForChild("ProximityPrompt")
	proximityPrompt.ObjectText = "Limited Time"
	self._rotating_queue_hologram = (rotatingQueueHolograms:FindFirstChild(RotatingQueueLibrary:GetCurrent().Name) or rotatingQueueHolograms.Default):Clone()
	self._rotating_queue_hologram:PivotTo(primary.CFrame)
	self._rotating_queue_hologram.Name = "_hologram"
	self._rotating_queue_hologram.Parent = parent

	if p2 then
		SendChat({
			Text = "[SERVER] New gamemodes are here! Open the PLAY page now! 🎉",
			Color = Color3.fromRGB(100, 255, 50)
		})
		Utility:PlayParticles(emit)
		Utility:CreateSound("rbxassetid://120776960987657", 0.75, 1, particles, true, 15)
		Utility:CreateSound("rbxassetid://75616400922980", 1, 1, particles, true, 15)

		for _, child in pairs(attachment:GetChildren()) do
			child.Enabled = true
		end

		task.delay(10, function()
			for _, child in pairs(attachment:GetChildren()) do
				child.Enabled = false
			end
		end)
	end
end

function class:_UpdateHologramLoop()
	if self._local_fighter and not (self._local_fighter:Get("IsInDuel") or self._local_fighter:Get("IsInShootingRange")) then
		if not self._hologram_loop_thread then
			self._hologram_loop_thread = task.spawn(function()
				self:_UpdateHologram()

				while true do
					wait(RotatingQueueLibrary:GetTimeUntilNext() + 1)
					self:_UpdateHologram(true)
				end
			end)
		end
	elseif self._hologram_loop_thread then
		task.cancel(self._hologram_loop_thread)
		self._hologram_loop_thread = nil
	end
end

function class:_UpdateJoinCooldown()
	self._join_cooldown_hash += 1
	local _join_cooldown_hash = self._join_cooldown_hash
	local joinCooldown = self._local_fighter:GetJoinCooldown()
	local v = tick() + joinCooldown
	self.UpdateJoinCooldown:Fire()

	for _ = 1, joinCooldown do
		wait(1)
		self.UpdateJoinCooldown:Fire()

		if self._join_cooldown_hash ~= _join_cooldown_hash then
			return
		end
	end

	wait(v - tick())

	if self._join_cooldown_hash ~= _join_cooldown_hash then
		return
	end

	self.UpdateJoinCooldown:Fire()
end

function class:_HookLocalFighter()
	self._local_fighter = FighterController:WaitForLocalFighter()
	self._local_fighter:GetDataChangedSignal("IsInDuel"):Connect(function()
		self:_UpdateHologramLoop()
	end)
	self._local_fighter:GetDataChangedSignal("IsInShootingRange"):Connect(function()
		self:_UpdateHologramLoop()
	end)
	self._local_fighter:GetDataChangedSignal("JoinCooldown"):Connect(function()
		self:_UpdateJoinCooldown()
	end)
	task.defer(self._UpdateHologramLoop, self)
	task.defer(self._UpdateJoinCooldown, self)
end

function class:_DuelRemoved(p)
	if self.CurrentDuel == p then
		self.CurrentDuel = nil
		self.DuelSet:Fire(p)
	end
end

function class:_DuelAdded(currentDuel)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function check_is_arcade_duel()
		if currentDuel:Get("IsCurrentArcadeDuel") then
			self.CurrentDuel = currentDuel
			self.DuelSet:Fire(currentDuel)
		end
	end

	currentDuel:GetDataChangedSignal("IsCurrentArcadeDuel"):Connect(check_is_arcade_duel)
	check_is_arcade_duel() -- equivalent call inferred; original call site unknown
end

function class:_PromptAdded(instance)
	if not CONSTANTS.IS_ARCADE_SERVER then
		return
	end

	instance:RemoveTag("LobbyOpenPagePrompt")
	instance.Triggered:Connect(function()
		ReplicatedStorage.Remotes.Matchmaking.BackToHub:FireServer()
	end)
	instance.ObjectText = DuelLibrary.ArcadeModeByPlaceID[tostring(CONSTANTS.PLACE_ID)].DisplayName
	instance.ActionText = "Leave"
end

function class:_Init()
	self.DuelSet:Connect(function(object2)
		object2:GetDataChangedSignal("Status"):Connect(function()
			self.UpdateJoinCooldown:Fire()
		end)
		self.UpdateJoinCooldown:Fire()

		if not FighterController.LocalFighter or FighterController.LocalFighter:Get("IsInDuel") or FighterController.LocalFighter:Get("IsInShootingRange") then
			return
		end

		if CONSTANTS.IS_ARCADE_SERVER and not self._has_joined_arcade_duel and #object2.Duelers >= 3 and object2:Get("Status") ~= "Voting" then
			SpectateController:SpectateDuelRequest(object2)
		else
			self:Join()
		end
	end)
	DuelController.ObjectAdded:Connect(function(p)
		self:_DuelAdded(p)
	end)
	DuelController.ObjectRemoved:Connect(function(p)
		self:_DuelRemoved(p)
	end)
	CollectionService:GetInstanceAddedSignal("LobbyRotatingQueueHologram"):Connect(function(p)
		self:_UpdateHologram(p)
	end)
	CollectionService:GetInstanceAddedSignal("LobbyArcadePrompt"):Connect(function(p)
		self:_PromptAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("LobbyArcadePrompt")) do
		task.defer(self._PromptAdded, self, v)
	end

	for _, object2 in pairs(DuelController.Objects) do
		task.defer(self._DuelAdded, self, object2)
	end

	task.defer(self._HookLocalFighter, self)
end

return class._new()