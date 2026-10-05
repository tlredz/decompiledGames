local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local GuardAreaGeometry = require(ReplicatedStorage.Shared.Util.GuardAreaGeometry)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local Player = require(ReplicatedStorage.Shared.Player)
local PointInBox = require(ReplicatedStorage.Shared.Utils.PointInBox)
local color = Color3.fromRGB(255, 70, 70)
local SAFE_ZONE = Constants.TAGS_MAP.Gameplay.SAFE_ZONE
local localPlayer = Players.LocalPlayer
local world = Workspace.World
assert(world:IsA("Folder"), "expected a Folder at Workspace.World")
local areas = world.Areas
assert(areas:IsA("Folder"), "expected a Folder at Workspace.World.Areas")
local separationLine = areas.SeparationLine
assert(separationLine:IsA("BasePart"), "expected a BasePart at Workspace.World.Areas.SeparationLine")
local ToolGameplayGuard = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function footPosition(p)
	local part = Player.FindRootPart(p)

	if part == nil or not part:IsA("BasePart") then
		return nil
	end

	return part.Position
end

local function isGear(instance)
	return instance == nil or typeof(instance:GetAttribute("GearName")) == "string"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isObbying(player)
	if not Workspace:GetAttribute("Event_MonsterEvent") then
		return false
	end

	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		return humanoidRootPart.Position.Z > -268
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refuse()
	Toast.Show({
		Color = color,
		Text = "Cannot use items in the safe zone!",
		Seconds = 2,
		Unique = true
	})
end

function ToolGameplayGuard.IsInsideArena(p)
	local v = footPosition(p) -- equivalent call inferred; original call site unknown
	return v ~= nil and GuardAreaGeometry.IsPastLine(separationLine, v)
end

function ToolGameplayGuard.IsLocalInsideArena()
	return ToolGameplayGuard.IsInsideArena(localPlayer)
end

function ToolGameplayGuard.IsInsideSafeZone(p)
	local v = footPosition(p) -- equivalent call inferred; original call site unknown
	local v2 = v == nil and {} or CollectionService:GetTagged(SAFE_ZONE)
	local v3 = 1

	while v3 <= #v2 do
		local part = v2[v3]
		v3 += 1

		if part:IsA("BasePart") and part:IsDescendantOf(Workspace) and PointInBox(part.CFrame, part.Size, v) then
			return true
		end
	end

	return false
end

function ToolGameplayGuard.AllowsLocalUse(instance)
	if localPlayer:GetAttribute("InBossArena") or localPlayer:GetAttribute("InScrambleArena") then
		return true
	end

	local v = instance ~= nil and typeof(instance:GetAttribute("GearName")) ~= "string" or ToolGameplayGuard.IsLocalInsideArena() and not ToolGameplayGuard.IsInsideSafeZone(localPlayer)

	if not v then
		refuse() -- equivalent call inferred; original call site unknown
	end

	-- equivalent call inferred; original call site unknown
	if isObbying(localPlayer) then
		refuse() -- equivalent call inferred; original call site unknown
		return false
	end

	return v
end

return ToolGameplayGuard