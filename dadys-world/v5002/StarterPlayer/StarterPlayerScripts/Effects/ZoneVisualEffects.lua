local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local v = nil
local success, result = pcall(function()
	local IchorScreenEffects = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Zones"):WaitForChild("IchorScreenEffects"))
	v = IchorScreenEffects
end)

if not success then
	warn("[ZoneVisualEffects] Failed to load IchorScreenEffects:", result)
end

local v2 = {
	IchorPuddle = {
		attribute = "InIchorPuddle",
		screenOverlay = {
			enabled = true,
			fadeOutDuration = 5
		}
	}
}
local class = {}
class.__index = class

function class.new(name, config)
	local self = setmetatable({}, class)
	self.name = name
	self.config = config
	self.screenEffect = nil
	self:_initialize()
	return self
end

function class:_initialize()
	if not v then
		warn("[ScreenOverlayManager] IchorScreenEffects module not available")
		return
	end

	local ichorScreen = ReplicatedStorage:FindFirstChild("Parts") and ReplicatedStorage.Parts:FindFirstChild("Overlays") and ReplicatedStorage.Parts.Overlays:FindFirstChild("IchorScreen")

	if not ichorScreen then
		warn("[ScreenOverlayManager] IchorScreen not found in ReplicatedStorage.Parts.Overlays")
		return
	end

	self.screenEffect = v.new(ichorScreen)

	if self.screenEffect then
		return
	end

	warn("[ScreenOverlayManager] Failed to create screen effect for", self.name)
end

function class:show()
	if self.screenEffect then
		self.screenEffect:Enter()
	end
end

function class:hide()
	if self.screenEffect then
		self.screenEffect:Exit(self.config.fadeOutDuration or 5)
	end
end

function class:reset()
	if self.screenEffect then
		self.screenEffect:Destroy()
		self.screenEffect = nil
	end

	self:_initialize()
end

function class:destroy()
	if self.screenEffect then
		self.screenEffect:Destroy()
		self.screenEffect = nil
	end
end

function class:forceCleanup()
	if self.screenEffect then
		self.screenEffect:Destroy()
		self.screenEffect = nil
	end

	local playerGui = localPlayer:FindFirstChild("PlayerGui")
	local screenGui = playerGui and playerGui:FindFirstChild("ScreenGui")
	local ichorScreen = screenGui and screenGui:FindFirstChild("IchorScreen")

	if ichorScreen then
		ichorScreen:Destroy()
	end

	self:_initialize()
end

local class2 = {}
class2.__index = class2

function class2.new(name, config)
	local self = setmetatable({}, class2)
	self.name = name
	self.config = config
	self.isActive = false

	if config.screenOverlay and config.screenOverlay.enabled then
		self.screenOverlayManager = class.new(name, config.screenOverlay)
	end

	return self
end

function class2:enter()
	if self.isActive then
		return
	end

	self.isActive = true

	if self.screenOverlayManager then
		self.screenOverlayManager:show()
	end
end

function class2:exit()
	if not self.isActive then
		return
	end

	self.isActive = false

	if self.screenOverlayManager then
		self.screenOverlayManager:hide()
	end
end

function class2:reset()
	self.isActive = false

	if self.screenOverlayManager then
		self.screenOverlayManager:reset()
	end
end

function class2:forceCleanup()
	self.isActive = false

	if self.screenOverlayManager then
		self.screenOverlayManager:forceCleanup()
	end
end

local v3 = {}
local connections = {}

local function initializeEffects()
	local count = 0

	for k, v4 in pairs(v2) do
		v3[k] = class2.new(k, v4)
		count += 1
	end
end

local function setupAttributeListeners(instance)
	if not instance then
		return
	end

	for _, connection in pairs(connections) do
		if connection.Connected then
			connection:Disconnect()
		end
	end

	connections = {}

	for k, v4 in pairs(v2) do
		local v5 = v3[k]

		if not v5 then
			continue
		end

		if instance:GetAttribute(v4.attribute) then
			v5:enter()
		end

		local v6 = v4
		local v7 = v5
		local connection = instance:GetAttributeChangedSignal(v4.attribute):Connect(function()
			if instance:GetAttribute(v6.attribute) then
				v7:enter()
			else
				v7:exit()
			end
		end)
		table.insert(connections, connection)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onCharacterDied()
	for _, v4 in pairs(v3) do
		v4:forceCleanup()
	end
end

local function onFloorChanged()
	onCharacterDied() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setupDeathListener(instance)
	if not instance then
		return
	end

	task.spawn(function()
		local humanoid = instance:WaitForChild("Humanoid", 10)

		if humanoid then
			humanoid.Died:Connect(onCharacterDied)
		elseif instance.Parent then
			warn("[ZoneVisualEffects] Failed to find Humanoid for death listener")
		end
	end)
end

local function onCharacterAdded(instance)
	for _, v4 in pairs(v3) do
		v4:reset()
	end

	setupAttributeListeners(instance)
	setupDeathListener(instance) -- equivalent call inferred; original call site unknown
end

initializeEffects()

if localPlayer.Character then
	setupAttributeListeners(localPlayer.Character)
	local character = localPlayer.Character

	if character then
		task.spawn(function()
			local humanoid = character:WaitForChild("Humanoid", 10)

			if humanoid then
				humanoid.Died:Connect(onCharacterDied)
			elseif character.Parent then
				warn("[ZoneVisualEffects] Failed to find Humanoid for death listener")
			end
		end)
	end
end

localPlayer.CharacterAdded:Connect(onCharacterAdded)
local info = workspace:FindFirstChild("Info")
local floor = info and info:FindFirstChild("Floor")

if floor then
	floor.Changed:Connect(onFloorChanged)
end