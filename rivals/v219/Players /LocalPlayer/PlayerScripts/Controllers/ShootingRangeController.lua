local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
local ShootingRangeDisplay = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ShootingRangeDisplay"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("Pages"))
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._enter_cooldown = 0
	self._exit_cooldown = 0
	self._shooting_range_displays = {}
	self:_Init()
	return self
end

function class:Enter(...)
	Pages.PageSystem:CloseCurrentPage()
	ReplicatedStorage.Remotes.Misc.ShootingRangeEnter:FireServer(...)
end

function class:Leave(p)
	ReplicatedStorage.Remotes.Misc.ShootingRangeLeave:FireServer(p)
end

function class:_TrashPromptAdded(instance)
	local proximityPrompt = instance:WaitForChild("Primary"):WaitForChild("ProximityPrompt")
	local close = instance:WaitForChild("MeshPart"):WaitForChild("Close")
	local open = instance:WaitForChild("MeshPart"):WaitForChild("Open")
	local lid = instance:WaitForChild("Lid")
	local v = nil

	local function move_lid(worldCFrame)
		if v then
			v:Pause()
			v:Destroy()
		end

		v = TweenService:Create(lid, tweenInfo, {
			CFrame = worldCFrame
		})
		v:Play()
	end

	proximityPrompt.PromptShown:Connect(function()
		move_lid(open.WorldCFrame)
	end)
	proximityPrompt.PromptHidden:Connect(function()
		move_lid(close.WorldCFrame)
	end)
	proximityPrompt.Triggered:Connect(function(player)
		if player == Players.LocalPlayer then
			ReplicatedStorage.Remotes.Misc.ShootingRangeTrashItems:FireServer()
		end
	end)
end

function class:_EntranceAdded(p)
	p.Touched:Connect(function(otherPart)
		if tick() > self._enter_cooldown and otherPart and otherPart.AssemblyRootPart and otherPart.AssemblyRootPart.Parent and Players:GetPlayerFromCharacter(otherPart.AssemblyRootPart.Parent) == Players.LocalPlayer then
			self._enter_cooldown = tick() + 1
			self:Enter()
		end
	end)
	self._shooting_range_displays[p] = ShootingRangeDisplay.new(p)
end

function class:_ExitAdded(p)
	p.Touched:Connect(function(otherPart)
		if tick() > self._exit_cooldown and otherPart and otherPart.AssemblyRootPart and otherPart.AssemblyRootPart.Parent and Players:GetPlayerFromCharacter(otherPart.AssemblyRootPart.Parent) == Players.LocalPlayer then
			self._exit_cooldown = tick() + 1
			self:Leave()
		end
	end)
end

function class:_HookLocalFighter()
	local v = FighterController:WaitForLocalFighter()

	local function update_displays()
		local v2 = not (v:Get("IsInDuel") or v:Get("IsInShootingRange"))

		for _, _shooting_range_display in pairs(self._shooting_range_displays) do
			_shooting_range_display:SetEnabled(v2)
		end
	end

	v:GetDataChangedSignal("IsInShootingRange"):Connect(update_displays)
	v:GetDataChangedSignal("IsInDuel"):Connect(update_displays)
	update_displays()
end

function class._ShootingRangeVisuals(_)
	local function object_added(instance)
		local doors = instance:WaitForChild("Doors")
		local sign = instance:WaitForChild("Sign")

		if CONSTANTS.SHOOTING_RANGE_ACTIVE then
			task.defer(doors.Destroy, doors)
			return
		end

		task.defer(sign.Destroy, sign)
		doors:PivotTo(doors:GetPivot() + createVector(0, 100, 0))
	end

	CollectionService:GetInstanceAddedSignal("LobbyShootingRangeVisuals"):Connect(object_added)

	for _, v in pairs(CollectionService:GetTagged("LobbyShootingRangeVisuals")) do
		task.defer(object_added, v)
	end
end

function class:_Init()
	task.defer(self._ShootingRangeVisuals, self)

	if not CONSTANTS.SHOOTING_RANGE_ACTIVE then
		return
	end

	CollectionService:GetInstanceAddedSignal("ShootingRangeEntrance"):Connect(function(p)
		self:_EntranceAdded(p)
	end)
	CollectionService:GetInstanceAddedSignal("ShootingRangeTrashPrompt"):Connect(function(p)
		self:_TrashPromptAdded(p)
	end)
	CollectionService:GetInstanceAddedSignal("ShootingRangeExit"):Connect(function(p)
		self:_ExitAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("ShootingRangeEntrance")) do
		task.defer(self._EntranceAdded, self, v)
	end

	for _, v in pairs(CollectionService:GetTagged("ShootingRangeTrashCan")) do
		task.defer(self._TrashPromptAdded, self, v)
	end

	for _, v in pairs(CollectionService:GetTagged("ShootingRangeExit")) do
		task.defer(self._ExitAdded, self, v)
	end

	task.spawn(self._HookLocalFighter, self)
end

return class._new()