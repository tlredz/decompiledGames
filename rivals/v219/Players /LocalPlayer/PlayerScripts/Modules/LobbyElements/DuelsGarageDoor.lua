local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Signal = require(ReplicatedStorage.Modules.Signal)
local ArcadeController = require(Players.LocalPlayer.PlayerScripts.Controllers.ArcadeController)
local LobbyElement = require(Players.LocalPlayer.PlayerScripts.Modules.LobbyElement)
local object = setmetatable({}, LobbyElement)
object.__index = object

function object._new(...)
	local self = setmetatable(LobbyElement.new(...), object)
	self._update_garage_doors_internal = Signal.new()
	self:_Init()
	return self
end

function object:_DoorAdded(instance)
	local door = instance:WaitForChild("Door")
	local arcadePortal = instance:WaitForChild("ArcadePortal")

	if CONSTANTS.QUEUES_ACTIVE then
		task.defer(arcadePortal.Destroy, arcadePortal)
		return
	end

	local portal = arcadePortal:WaitForChild("Portal")
	local hitbox = portal:WaitForChild("Hitbox")
	portal:PivotTo(arcadePortal:WaitForChild("Anchor").CFrame)
	local unanchorMe = portal:WaitForChild("Model"):WaitForChild("UnanchorMe")
	local clone = unanchorMe:Clone()
	clone:PivotTo(unanchorMe:GetPivot())
	clone.Parent = unanchorMe.Parent
	unanchorMe.Parent = nil

	for _, part in pairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") or part:HasTag("DontUnanchorMe") then
			continue
		end

		part.Anchored = false
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		local v = ArcadeController.CurrentDuel and ArcadeController.CurrentDuel:Get("Status") ~= "GameOver"
		door:PivotTo(self:_GetOriginalPivot(door) + (v and createVector(0, 0, 0) or createVector(0, -21.75, 0)))
		arcadePortal.Parent = v and instance or nil
	end

	self._update_garage_doors_internal:Connect(update)
	update() -- equivalent call inferred; original call site unknown
	hitbox.Touched:Connect(function(otherPart)
		if Players:GetPlayerFromCharacter(otherPart.Parent) == Players.LocalPlayer then
			ArcadeController:Join()
		end
	end)
end

function object:_ClientDuelAdded(object2)
	object2:GetDataChangedSignal("Status"):Connect(function()
		self._update_garage_doors_internal:Fire()
	end)
	self._update_garage_doors_internal:Fire()
end

function object:_Init()
	CollectionService:GetInstanceAddedSignal("LobbyDuelsGarageDoor"):Connect(function(p)
		self:_DoorAdded(p)
	end)
	ArcadeController.DuelSet:Connect(function(p)
		if ArcadeController.CurrentDuel then
			self:_ClientDuelAdded(p)
		else
			self._update_garage_doors_internal:Fire()
		end
	end)

	if ArcadeController.CurrentDuel then
		task.defer(self._ClientDuelAdded, self, ArcadeController.CurrentDuel)
	end

	for _, v in pairs(CollectionService:GetTagged("LobbyDuelsGarageDoor")) do
		task.defer(self._DoorAdded, self, v)
	end
end

return object._new()