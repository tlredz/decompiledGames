local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local Util = require(game.ReplicatedStorage.Util)
local Effect = require(game.ReplicatedStorage.Effect)
local AttributeCounter = require(game.ReplicatedStorage.Util.AttributeCounter)
local Global = require(game.ReplicatedStorage.Global)
local CompassTracker = require(game.ReplicatedStorage.GuideModule.CompassTracker)
local TavernDoors = require(game.ReplicatedStorage.Controllers.IslandController.TavernDoors)
local v = {
	TRIGGER_RANGE = 16,
	LEAVE_RANGE = 26,
	VIBRATE_INTERVAL = 0.09,
	VIBRATE_ANGLE = 3,
	KICK_FLY_SPEED = 34,
	KICK_FLY_SIDE = 6,
	KICK_FLY_UP = 12,
	KICK_SPIN = 10,
	KICK_ANIM_LEAD = 0.25,
	KICK_SETTLE = 0.4,
	BREACH_SPOT_GAP = 8,
	BREACH_SPOT_RADIUS = 6,
	BREACH_SPOT_WAIT = 1.5,
	BREACH_SPOT_RESEND = 0.5,
	DOOR_REGEN_DELAY = 20,
	WALK_IN_OUTSIDE_GAP = 4,
	WALK_IN_DEPTH = 10,
	WALK_IN_TIMEOUT = 3,
	WALK_IN_SPACING = 4.5,
	EXIT_TAVERN_TIMEOUT = 3,
	BREACH_CONFIRM_TIMEOUT = 4
}
local v2 = {
	NOISE_MIN = 0.6,
	NOISE_MAX = 1.4,
	NOISE_SOUNDS = {
		"BrokenGlass",
		"CupHit",
		"DeepPunch",
		"WoodCreak"
	},
	BREAK_SOUNDS = {
		"PirateVillageSFX.PirateVillBonus_Hooligan_Break_Bottle_01",
		"PirateVillageSFX.PirateVillBonus_Hooligan_Break_Bottle_02",
		"PirateVillageSFX.PirateVillBonus_Hooligan_Break_Bottle_03"
	},
	BOTTLE_SIZE = createVector(0.55, 1.35, 0.55),
	BOTTLE_COLOR = Color3.fromRGB(86, 138, 74),
	BOTTLE_TRANSPARENCY = 0.2,
	BOTTLE_REFLECTANCE = 0.15,
	BOTTLE_SPIN = 22,
	BOTTLE_TRAIL_LIFETIME = 0.18,
	SHATTER_GLASS_COLOR = Color3.fromRGB(198, 236, 210),
	SHATTER_GLASS_COUNT = 26,
	SHATTER_LIQUID_COLOR = Color3.fromRGB(104, 152, 86),
	SHATTER_LIQUID_COUNT = 18,
	SHATTER_CLEANUP = 1.3,
	SHARD_COUNT = 7,
	SHARD_SIZE_MIN = 0.12,
	SHARD_SIZE_VAR = 0.22,
	SHARD_SPEED_MIN = 6,
	SHARD_SPEED_VAR = 12,
	SHARD_UP_MIN = 4,
	SHARD_UP_VAR = 9,
	SHARD_SPIN = 26,
	SHARD_GRAVITY = 95,
	SHARD_LIFETIME = 1.6,
	SHARD_FADE_START = 0.9,
	THROW_SOUNDS = {
		"PirateVillageSFX.PirateVillBonus_Hooligan_Throw_Bottle_01",
		"PirateVillageSFX.PirateVillBonus_Hooligan_Throw_Bottle_02",
		"PirateVillageSFX.PirateVillBonus_Hooligan_Throw_Bottle_03"
	},
	KICK_SOUND = "PirateVillageSFX.Player_Burst_Through_Tavern_Door_01",
	DOOR_FIGHT_SOUND = "PirateVillageSFX.PirateVillBonus_Tavern_Fight_Behind_Door_01",
	DOOR_RATTLE_SOUND = "PirateVillageSFX.PirateVillBonus_Tavern_Door_Rattling_Loop_01",
	DOOR_LOOP_FADE = 0.35,
	KICK_ANIMATION = "Kick",
	DUST_EFFECT = "DustExplosion",
	DUST_SIZE = 16,
	DUST_DURATION = 1,
	DUST_OFFSET = 2,
	DUST_COLOR_A = Color3.fromRGB(158, 138, 112),
	DUST_COLOR_B = Color3.fromRGB(92, 78, 60),
	DEBRIS_COUNT = 16,
	DEBRIS_LIFETIME = 1.5,
	DEBRIS_FADE_START = 0.9,
	DEBRIS_GRAVITY = 90,
	DEBRIS_SPEED_MIN = 20,
	DEBRIS_SPEED_MAX = 52,
	DEBRIS_SIDE_SPREAD = 16,
	DEBRIS_UP_SPREAD = 16,
	DEBRIS_SPIN = 20,
	DEBRIS_COLOR = Color3.fromRGB(104, 74, 48)
}
local v3 = {
	CUTSCENE_FOV = 66,
	CAM_SKIN = 0.8,
	CAM_MIN = 3,
	SHOT1_TIME = 2.4,
	SHOT2_TIME = 2.4,
	BARTENDER_SHOT_TIME = 1.8,
	FIGHTER_FOCUS_UP = 2,
	FIGHTER_CAM_WIDE = 21,
	FIGHTER_CAM_PUSH = 15,
	FIGHTER_CAM_CLOSE = 13,
	FIGHTER_CAM_SPREAD = 2.1,
	FIGHTER_CAM_HIGH = 8,
	FIGHTER_CAM_MID = 2,
	FIGHTER_APPROACH_BIAS = 0.7,
	FIGHTER_ARC = 22,
	DOOR_WATCH_LEAD = 1.4,
	DOOR_WATCH_HOLD = 3,
	DOOR_WATCH_BACK = 8,
	DOOR_WATCH_SIDE = 4.5,
	DOOR_WATCH_UP = 3,
	DOOR_WATCH_DRIFT = 1.2,
	DOOR_WATCH_SLEEPER_UP = 0.8,
	DOOR_WATCH_AIM_BLEND = 0.45,
	DOOR_WATCH_AIM_DIST = 40,
	DOOR_WATCH_LOOK_UP = 1,
	BOTTLE_THROWS = {
		{
			time = 0.8,
			brawler = 2
		},
		{
			time = 2.6,
			brawler = 2
		},
		{
			time = 4.4,
			brawler = 2
		}
	},
	THROW_ANIM_LEAD = 0.35,
	THROW_HAND_PARTS = { "RightHand", "RightLowerArm", "RightUpperArm" },
	THROW_FALLBACK_UP = 1.6,
	BOTTLE_SPEED = 55,
	BOTTLE_FLIGHT_MIN = 0.35,
	BOTTLE_FLIGHT_MAX = 1.1,
	BOTTLE_ARC_PER_STUD = 0.18,
	BOTTLE_ARC_MAX = 7,
	BOTTLE_TARGET_UP = 0.4,
	BOTTLE_SPREAD_SIDE = 7,
	BOTTLE_SPREAD_DEPTH = 5,
	BOTTLE_SPREAD_UP = 2.5,
	INTRO_CAM_BACK = 10,
	INTRO_CAM_SIDE = 2.5,
	INTRO_CAM_UP = 1.5,
	INTRO_CAM_LOOK_UP = 0.5,
	CONFRONT_CAM_BACK = 11,
	CONFRONT_CAM_UP = 4,
	CONFRONT_CAM_ARC = -50,
	CONFRONT_PAN_FREQ = 2.2,
	FIGHT_FADE_OUT = 0.35,
	FIGHT_FADE_HOLD = 0.25,
	FIGHT_FADE_IN = 0.4,
	GANG_CAM_BACK = 11,
	GANG_CAM_UP = 4,
	GANG_CAM_SPREAD = 2.4,
	BARTENDER_CAM_FRONT = 6,
	BARTENDER_CAM_SIDE = 2.5,
	BARTENDER_CAM_UP = 1.5,
	BARTENDER_CAM_LOOK_UP = 0.5
}
local v4 = {
	CINEMATIC_RETURN_TIME = 0.6,
	OWNER_NAME = "Tavern Owner",
	BARTENDER_IDLE = "rbxassetid://95213211381644",
	BARTENDER_SAVED_IDLE = "rbxassetid://18884840386",
	BARTENDER_ANIM_FADE = 0.2,
	TOOL_ANIMS_FOLDER = "Animations",
	TOOL_IDLE_ANIM = "Idle",
	BARTENDER_LOWER_ARM_SCALE = 0.99,
	BARTENDER_INTERACT_RANGE = 12,
	BARTENDER_APPROACH_RANGE = 16,
	BARTENDER_LEAVE_RANGE = 26,
	BARTENDER_POTION_TOOL = "Invisibility Potion",
	AURA_FOLDER = "NPCAura",
	AURA_NAME = "MISC.",
	AURA_LIFT = 0.1,
	MISC_COLOR = Color3.fromRGB(255, 255, 255),
	QUEST_GUI = "QuestBBG",
	TALK_GUI = "Talk",
	TALK_FADE = 0.4,
	TALK_STROKE = 0.3,
	TALK_SHOWN_POSITION = UDim2.new(0.1, 0, 0, 0),
	TALK_HIDDEN_POSITION = UDim2.new(0.1, 0, 0, -40),
	INTERACT_TAP_COOLDOWN = 0.35,
	BRAWL_FOLDER_NAME = "Tavern_Brawl",
	BRAWLER_TAG = "TavernBrawler",
	BARRIER_DOOR_NAME = "Barrier_Door",
	BARRIER_FOLDER_RETRY = 0.5,
	BARRIER_FOLDER_TIMEOUT = 30,
	LOCAL_DOORS_NAME = "LocalTavernDoors",
	MOVEMENT_COUNTER = "DisableMovement",
	MOVEMENT_LOCK_MAX = 45
}
local v5 = nil
local v6 = nil
local v7 = {}
local v8 = nil
local v9 = nil
local v10 = nil
local v11 = false
local flag = false
local v12 = false
local flag2 = false
local v13 = false
local v14 = false
local v15 = false
local v16 = nil
local v17 = 1
local v18 = false
local v19 = false
local flag3 = false
local v20 = false
local v21 = false
local flag4 = false
local flag5 = false
local flag6 = false
local v22 = false
local v23 = false
local v24 = false
local v25 = false
local heartbeatConnection = nil
local heartbeatConnection2 = nil
local thread = nil
local thread2 = nil
local flag7 = false
local v26 = {}
local thread3 = nil
local v27 = nil
local v28 = nil
local v29 = nil
local v30 = nil
local v31 = false
local v32 = nil
local v33 = false
local v34 = nil
local connections = {}
local v35 = nil
local v36 = nil
local thread4 = nil
local flag8 = false
local v37 = nil
local v38 = nil
local v39 = nil
local flag9 = false
local v40 = {}
local v41 = false
local descendantAddedConnection = nil
local count = 0
local object = setmetatable({}, {
	__mode = "k"
})
local v42 = nil
local rigs = script:FindFirstChild("Rigs")
local bartender

if rigs then
	bartender = rigs:FindFirstChild("Bartender")
end

if bartender and bartender:IsA("Model") then
	v42 = bartender
end

-- equivalent calls inferred from this helper; original call sites unknown
local function flatUnit(vector2: Vector3, vector3: Vector3)
	local vector4 = Vector3.new(vector2.X, 0, vector2.Z)

	if vector4.Magnitude > 0.01 then
		return vector4.Unit
	end

	return vector3
end

local function openDialogue(object2, fn)
	local DialogueController = require(game.ReplicatedStorage.DialogueController)
	fn(true)
	object2:getMaid():GiveTask(function()
		fn(false)
	end)

	if DialogueController.start(object2) ~= nil then
		return true
	end

	fn(false)
	return false
end

local function getRoot()
	local character = Players.LocalPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function brawlerCentroid()
	if #v7 == 0 then
		return nil
	end

	local v43 = createVector(0, 0, 0)

	for _, v44 in v7 do
		v43 += v44.Position
	end

	return v43 / #v7
end

local function insideDirection()
	local v43 = v6

	if not v43 then
		return createVector(0, 0, 1)
	end

	local v44 = brawlerCentroid() -- equivalent call inferred; original call site unknown

	if v44 then
		local v45 = v44 - v43.Position
		local lookVector = v43.LookVector
		local vector2 = Vector3.new(v45.X, 0, v45.Z)

		if vector2.Magnitude > 0.01 then
			return vector2.Unit
		end

		return lookVector
	else
		local lookVector = v43.LookVector
		local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)

		if vector2.Magnitude > 0.01 then
			return vector2.Unit
		end

		return createVector(0, 0, 1)
	end
end

local function cameraCollisionParams()
	local filterDescendantsInstances = { workspace.Terrain }

	for _, childName in {
		"Characters",
		"Enemies",
		"NPCs",
		"_WorldOrigin"
	} do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(filterDescendantsInstances, child)
		end
	end

	local character = Players.LocalPlayer.Character

	if character then
		table.insert(filterDescendantsInstances, character)
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	raycastParams.RespectCanCollide = true
	raycastParams.IgnoreWater = true
	return raycastParams
end

local function safeCameraPosition(vector2: Vector3, vector3: Vector3, p)
	local v43 = vector3 - vector2

	if v43.Magnitude < 0.1 then
		return vector3
	end

	local raycastResult = workspace:Raycast(vector2, v43, p)

	if not raycastResult then
		return vector3
	end

	local v44 = (raycastResult.Position - vector2).Magnitude - v3.CAM_SKIN
	return vector2 + v43.Unit * math.max(v44, v3.CAM_MIN)
end

local function framedShot(vector2: Vector3, vector3: Vector3)
	local lookAt = CFrame.lookAt
	local v43 = cameraCollisionParams()
	local v44 = vector2 - vector3

	if v44.Magnitude < 0.1 then
		return lookAt(vector2, vector3)
	end

	local raycastResult = workspace:Raycast(vector3, v44, v43)

	if raycastResult then
		local v45 = (raycastResult.Position - vector3).Magnitude - v3.CAM_SKIN
		vector2 = vector3 + v44.Unit * math.max(v45, v3.CAM_MIN)
	end

	return lookAt(vector2, vector3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rotateFlat(unit: Vector3, p: number)
	local v43 = math.rad(p)
	local v44 = math.cos(v43)
	local v45 = math.sin(v43)
	return (Vector3.new(unit.X * v44 + unit.Z * v45, unit.Y, -unit.X * v45 + unit.Z * v44))
end

local function fighterPositions()
	local positions = {}

	for k, v43 in v7 do
		if k ~= v8 then
			table.insert(positions, v43.Position)
		end
	end

	if #positions == 0 then
		for _, v43 in v7 do
			table.insert(positions, v43.Position)
		end
	end

	return positions
end

local function closeUpShot(list, p: number, p2: number)
	if #list == 0 then
		return nil
	end

	local v43 = createVector(0, 0, 0)

	for _, v44 in list do
		v43 += v44
	end

	local v44 = v43 / #list
	local v45 = 0

	for _, v46 in list do
		v45 = math.max(v45, (v46 - v44).Magnitude)
	end

	local v46 = v6
	local lookVector

	if v46 then
		local v47 = brawlerCentroid() -- equivalent call inferred; original call site unknown

		if v47 then
			local v48 = v47 - v46.Position
			lookVector = v46.LookVector
			local vector2 = Vector3.new(v48.X, 0, v48.Z)

			if vector2.Magnitude > 0.01 then
				lookVector = vector2.Unit
			end
		else
			local lookVector2 = v46.LookVector
			local vector2 = Vector3.new(lookVector2.X, 0, lookVector2.Z)

			if vector2.Magnitude > 0.01 then
				lookVector = vector2.Unit
			else
				lookVector = createVector(0, 0, 1)
			end
		end
	else
		lookVector = createVector(0, 0, 1)
	end

	return framedShot(
		v44 - lookVector * math.max(p, v45 * v3.GANG_CAM_SPREAD) + Vector3.new(0, p2, 0),
		v44 + createVector(0, 1.2, 0)
	)
end

local function fighterAxisPerp(list, vector2: Vector3)
	local vector3 = flatUnit(list[#list] - list[1], vector2) -- equivalent call inferred; original call site unknown
	local cross = vector3:Cross(createVector(0, 1, 0))
	local unit

	if cross.Magnitude > 0.001 then
		unit = cross.Unit
	else
		unit = -vector2
	end

	if unit:Dot(-vector2) < 0 then
		unit = -unit
	end

	return unit
end

local function fighterTwoShot(CONFRONT_CAM_BACK: number, CONFRONT_CAM_UP: number, CONFRONT_CAM_ARC: number)
	local v43 = fighterPositions()

	if #v43 < 2 then
		return closeUpShot(v43, CONFRONT_CAM_BACK, CONFRONT_CAM_UP)
	end

	local v44 = createVector(0, 0, 0)

	for _, v45 in v43 do
		v44 += v45
	end

	local v45 = v44 / #v43
	local v46 = 0

	for _, v47 in v43 do
		v46 = math.max(v46, (v47 - v45).Magnitude)
	end

	local v47 = v6
	local lookVector

	if v47 then
		local v48 = brawlerCentroid() -- equivalent call inferred; original call site unknown

		if v48 then
			local v49 = v48 - v47.Position
			lookVector = v47.LookVector
			local vector2 = Vector3.new(v49.X, 0, v49.Z)

			if vector2.Magnitude > 0.01 then
				lookVector = vector2.Unit
			end
		else
			local lookVector2 = v47.LookVector
			local vector2 = Vector3.new(lookVector2.X, 0, lookVector2.Z)

			if vector2.Magnitude > 0.01 then
				lookVector = vector2.Unit
			else
				lookVector = createVector(0, 0, 1)
			end
		end
	else
		lookVector = createVector(0, 0, 1)
	end

	local v48 = math.max(CONFRONT_CAM_BACK, v46 * v3.FIGHTER_CAM_SPREAD)
	local vector2 = flatUnit(v43[#v43] - v43[1], lookVector) -- equivalent call inferred; original call site unknown
	local cross = vector2:Cross(createVector(0, 1, 0))
	local unit

	if cross.Magnitude > 0.001 then
		unit = cross.Unit
	else
		unit = -lookVector
	end

	if unit:Dot(-lookVector) < 0 then
		unit = -unit
	end

	return framedShot(
		v45 + rotateFlat(unit, CONFRONT_CAM_ARC) * v48 + Vector3.new(0, CONFRONT_CAM_UP, 0),
		v45 + createVector(0, 1.2, 0)
	)
end

local function distanceToDoor()
	local v43 = v6
	local character = Players.LocalPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoidRootPart = nil
	end

	if v43 and humanoidRootPart then
		return (humanoidRootPart.Position - v43.Position).Magnitude
	end

	return nil
end

local function isInsideTavern()
	local v43 = v6
	local character = Players.LocalPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoidRootPart = nil
	end

	if not (v43 and humanoidRootPart) then
		return false
	end

	local v44 = humanoidRootPart.Position - v43.Position
	local v45 = v6
	local lookVector

	if v45 then
		local v46 = brawlerCentroid() -- equivalent call inferred; original call site unknown

		if v46 then
			local v47 = v46 - v45.Position
			lookVector = v45.LookVector
			local vector2 = Vector3.new(v47.X, 0, v47.Z)

			if vector2.Magnitude > 0.01 then
				lookVector = vector2.Unit
			end
		else
			local lookVector2 = v45.LookVector
			local vector2 = Vector3.new(lookVector2.X, 0, lookVector2.Z)

			if vector2.Magnitude > 0.01 then
				lookVector = vector2.Unit
			else
				lookVector = createVector(0, 0, 1)
			end
		end
	else
		lookVector = createVector(0, 0, 1)
	end

	return lookVector:Dot((Vector3.new(v44.X, 0, v44.Z))) > 0
end

local function getTavernDoorModel()
	local map = workspace:FindFirstChild("Map")
	local pirate

	if map then
		pirate = map:FindFirstChild("Pirate")
	end

	local tavernNEW

	if pirate then
		tavernNEW = pirate:FindFirstChild("TavernNEW")
	end

	local tavernDoor

	if tavernNEW then
		tavernDoor = tavernNEW:FindFirstChild("TavernDoor")
	end

	if tavernDoor and tavernDoor:IsA("Model") then
		return tavernDoor
	end

	return nil
end

local function getBrawlFolder()
	local map = workspace:FindFirstChild("Map")
	local pirate

	if map then
		pirate = map:FindFirstChild("Pirate")
	end

	if pirate then
		return pirate:FindFirstChild(v4.BRAWL_FOLDER_NAME) or pirate:FindFirstChild(v4.BRAWL_FOLDER_NAME, true)
	end

	return nil
end

local function applyBarrierInstance(instance, flag10: boolean)
	if instance:IsA("BasePart") then
		if flag10 then
			if not object[instance] then
				object[instance] = {
					CanCollide = instance.CanCollide,
					CanTouch = instance.CanTouch,
					CanQuery = instance.CanQuery
				}
			end

			instance.LocalTransparencyModifier = 1
			instance.CanCollide = false
			instance.CanTouch = false
			instance.CanQuery = false
		else
			instance.LocalTransparencyModifier = 0
			local v43 = object[instance]

			if v43 then
				instance.CanCollide = v43.CanCollide
				instance.CanTouch = v43.CanTouch
				instance.CanQuery = v43.CanQuery
				object[instance] = nil
			end
		end
	elseif instance:IsA("Decal") then
		instance.LocalTransparencyModifier = flag10 and 1 or 0
	end
end

local function applyBarrierDoors(folder, flag10: boolean)
	for _, folder2 in folder:GetDescendants() do
		if folder2.Name ~= v4.BARRIER_DOOR_NAME then
			continue
		end

		applyBarrierInstance(folder2, flag10)

		for _, descendant in folder2:GetDescendants() do
			applyBarrierInstance(descendant, flag10)
		end
	end
end

local function isBarrierDescendant(parent, p)
	while parent and parent ~= p do
		if parent.Name == v4.BARRIER_DOOR_NAME then
			return true
		else
			parent = parent.Parent
		end
	end

	return false
end

local function setBarriersCleared(flag10: boolean)
	v41 = flag10
	count += 1

	if descendantAddedConnection then
		descendantAddedConnection:Disconnect()
		descendantAddedConnection = nil
	end

	if flag10 then
		local v43 = count
		task.spawn(function()
			local map = workspace:FindFirstChild("Map")
			local pirate

			if map then
				pirate = map:FindFirstChild("Pirate")
			end

			local v44

			if pirate then
				v44 = pirate:FindFirstChild(v4.BRAWL_FOLDER_NAME) or pirate:FindFirstChild(v4.BRAWL_FOLDER_NAME, true)
			else
				v44 = nil
			end

			local total = 0

			while not v44 and count == v43 and total < v4.BARRIER_FOLDER_TIMEOUT do
				total += task.wait(v4.BARRIER_FOLDER_RETRY)
				local map2 = workspace:FindFirstChild("Map")
				local pirate2

				if map2 then
					pirate2 = map2:FindFirstChild("Pirate")
				end

				if pirate2 then
					v44 = pirate2:FindFirstChild(v4.BRAWL_FOLDER_NAME) or pirate2:FindFirstChild(
						v4.BRAWL_FOLDER_NAME,
						true
					)
				else
					v44 = nil
				end
			end

			if not v44 or count ~= v43 then
				return
			end

			descendantAddedConnection = v44.DescendantAdded:Connect(function(descendant)
				if v41 then
					local v45 = v44
					local parent = descendant
					local flag11

					while true do
						if not parent or parent == v45 then
							flag11 = false
							break
						end

						if parent.Name == v4.BARRIER_DOOR_NAME then
							flag11 = true
							break
						else
							parent = parent.Parent
						end
					end

					if flag11 then
						applyBarrierInstance(descendant, true)
					end
				end
			end)
			applyBarrierDoors(v44, true)
		end)
	else
		local map = workspace:FindFirstChild("Map")
		local pirate

		if map then
			pirate = map:FindFirstChild("Pirate")
		end

		local v43

		if pirate then
			v43 = pirate:FindFirstChild(v4.BRAWL_FOLDER_NAME) or pirate:FindFirstChild(v4.BRAWL_FOLDER_NAME, true)
		end

		if v43 then
			applyBarrierDoors(v43, false)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getLocalDoorFolder()
	local tavernDoorModel = getTavernDoorModel()

	if tavernDoorModel then
		return (tavernDoorModel:FindFirstChild(v4.LOCAL_DOORS_NAME))
	end

	return nil
end

local function closedDoorCFrame(name: string, localDoorFolder)
	local tavernDoorModel = getTavernDoorModel()

	if not tavernDoorModel then
		return nil
	end

	for _, model in tavernDoorModel:GetDescendants() do
		if not model:IsA("Model") or model.Name ~= name or model:IsDescendantOf(localDoorFolder) then
			continue
		end

		local door = model:FindFirstChild("door")

		if door and door:IsA("BasePart") then
			return door.CFrame
		end
	end

	return nil
end

local function refreshDoorUnits()
	table.clear(v40)
	local localDoorFolder = getLocalDoorFolder() -- equivalent call inferred; original call site unknown

	if not localDoorFolder then
		return
	end

	for _, model in localDoorFolder:GetDescendants() do
		if not (model:IsA("Model") and (model.Name == "Leftdoor" or model.Name == "Rightdoor")) then
			continue
		end

		local door = model:FindFirstChild("door")
		local hinge = model:FindFirstChild("hinge")

		if not (door and door:IsA("BasePart") and hinge and hinge:IsA("BasePart")) then
			continue
		end

		local unit = createVector(0, 1, 0)
		local hingeConstraint = model:FindFirstChildWhichIsA("HingeConstraint", true)
		local attachment0

		if hingeConstraint then
			attachment0 = hingeConstraint.Attachment0
		end

		if attachment0 then
			local worldAxis = attachment0.WorldAxis

			if worldAxis.Magnitude > 0.5 then
				unit = worldAxis.Unit
			end
		end

		table.insert(v40, {
			door = door,
			hinge = hinge,
			axis = unit,
			restCF = closedDoorCFrame(model.Name, localDoorFolder) or door.CFrame,
			constraint = hingeConstraint
		})
	end
end

local function stopVibration()
	if thread then
		task.cancel(thread)
		thread = nil
	end

	for _, v43 in v40 do
		local door = v43.door

		if not (door.Parent and door.Anchored) then
			continue
		end

		door.CFrame = v43.restCF
		door.Anchored = false
	end
end

local function snapDoorsClosed()
	refreshDoorUnits()

	for _, v43 in v40 do
		local door = v43.door

		if not door.Parent then
			continue
		end

		door.Anchored = true
		door.AssemblyLinearVelocity = createVector(0, 0, 0)
		door.AssemblyAngularVelocity = createVector(0, 0, 0)
		door.CFrame = v43.restCF
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startVibration()
	if thread then
		return
	end

	snapDoorsClosed()
	thread = task.spawn(function()
		local v43 = 1

		while true do
			if #v40 == 0 then
				refreshDoorUnits()
			end

			local v44 = false

			for _, v45 in v40 do
				local door = v45.door

				if not door.Parent then
					continue
				end

				door.Anchored = true
				local cframe = CFrame.new(v45.hinge.Position)
				local v46 = v43 * 0.05235987755982989 * (0.5 + math.random() * 0.5)
				door.CFrame = cframe * CFrame.fromAxisAngle(v45.axis, v46) * cframe:Inverse() * v45.restCF
				v44 = true
			end

			if #v40 > 0 and not v44 then
				table.clear(v40)
			end

			v43 = -v43
			task.wait(0.09)
		end
	end)
end

local frozen = table.freeze({ v2.DOOR_FIGHT_SOUND, v2.DOOR_RATTLE_SOUND })

local function startDoorLoops()
	local v43 = v6

	if #v26 > 0 or not v43 then
		return
	end

	for _, v44 in frozen do
		local v45 = v44
		pcall(function()
			local v46 = Util.Sound:Play(v45, v43)
			v46.Looped = true
			table.insert(v26, v46)
		end)
	end
end

local function stopDoorLoops()
	if #v26 == 0 then
		return
	end

	local v43 = v26
	v26 = {}

	for _, v44 in v43 do
		local v45 = v44
		pcall(function()
			Util.Sound:FadeOut(v45, v2.DOOR_LOOP_FADE)
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopBrawlNoise()
	stopDoorLoops()

	if thread2 then
		task.cancel(thread2)
		thread2 = nil
	end

	flag7 = false
end

local function brawlNoiseCFrame()
	if not flag7 then
		return v6
	end

	local v43 = brawlerCentroid() -- equivalent call inferred; original call site unknown

	if v43 then
		return CFrame.new(v43)
	end

	return v6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startBrawlNoise()
	startDoorLoops()

	if thread2 then
		return
	end

	thread2 = task.spawn(function()
		while true do
			local cframe

			if flag7 then
				local v43 = brawlerCentroid() -- equivalent call inferred; original call site unknown

				if v43 then
					cframe = CFrame.new(v43)
				else
					cframe = v6
				end
			else
				cframe = v6
			end

			if cframe then
				local v44 = v2.NOISE_SOUNDS[math.random(#v2.NOISE_SOUNDS)]
				local v45 = cframe
				pcall(function()
					Util.Sound:Play(v44, v45)
				end)
				task.wait(v2.NOISE_MIN + math.random() * (v2.NOISE_MAX - v2.NOISE_MIN))
			else
				task.wait(v2.NOISE_MIN + math.random() * (v2.NOISE_MAX - v2.NOISE_MIN))
			end
		end
	end)
end

local function releaseIntroCamera(flag10: boolean)
	local v43 = v38
	v38 = nil

	if not v43 then
		return
	end

	pcall(function()
		if flag10 then
			v43:Destroy()
		else
			v43:FadeOut(v4.CINEMATIC_RETURN_TIME)
		end
	end)
end

local function npcGuiTemplate(childName: string)
	local nPCManager = game.ReplicatedStorage:FindFirstChild("NPCManager")
	local NPC

	if nPCManager then
		NPC = nPCManager:FindFirstChild("NPC")
	end

	local nPCInitialization

	if NPC then
		nPCInitialization = NPC:FindFirstChild("NPCInitialization")
	end

	local GUI

	if nPCInitialization then
		GUI = nPCInitialization:FindFirstChild("GUI")
	end

	if GUI then
		return (GUI:FindFirstChild(childName))
	end

	return nil
end

local function talkPromptLabel()
	local v43 = v32

	if not (v43 and v43.Parent) then
		return nil
	end

	local textLabel = v43:FindFirstChild("TextLabel")

	if textLabel and textLabel:IsA("TextLabel") then
		return textLabel
	end

	return nil
end

local function setTalkPromptVisible(flag10: boolean)
	if v33 == flag10 then
		return
	end

	local v43 = v32
	local v44 = v32
	local textLabel

	if v44 and v44.Parent then
		textLabel = v44:FindFirstChild("TextLabel")

		if not (textLabel and textLabel:IsA("TextLabel")) then
			textLabel = nil
		end
	end

	if not (v43 and textLabel) then
		return
	end

	v33 = flag10

	if v34 then
		v34:Cancel()
		v34 = nil
	end

	if flag10 then
		v43.Enabled = true
		local tween = TweenService:Create(textLabel, TweenInfo.new(v4.TALK_FADE), {
			Position = v4.TALK_SHOWN_POSITION,
			TextTransparency = 0,
			TextStrokeTransparency = v4.TALK_STROKE
		})
		v34 = tween
		tween:Play()
	else
		local tween = TweenService:Create(textLabel, TweenInfo.new(v4.TALK_FADE), {
			Position = v4.TALK_HIDDEN_POSITION,
			TextTransparency = 1,
			TextStrokeTransparency = 1
		})
		v34 = tween
		tween.Completed:Once(function(p)
			if p == Enum.PlaybackState.Completed and not v33 and v43.Parent then
				v43.Enabled = false
			end
		end)
		tween:Play()
	end
end

local function attachTalkPrompt(clone)
	if v32 then
		return
	end

	local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return
	end

	local billboardGui = npcGuiTemplate(v4.TALK_GUI)

	if not (billboardGui and billboardGui:IsA("BillboardGui")) then
		return
	end

	local clone2 = billboardGui:Clone()
	local textLabel = clone2:FindFirstChild("TextLabel")

	if textLabel and textLabel:IsA("TextLabel") then
		textLabel.Position = v4.TALK_HIDDEN_POSITION
		textLabel.TextTransparency = 1
		textLabel.TextStrokeTransparency = 1
	end

	clone2.Enabled = false
	clone2.Parent = humanoidRootPart
	v32 = clone2
	v33 = false
end

local function disarmBartenderTrigger()
	if heartbeatConnection2 then
		heartbeatConnection2:Disconnect()
		heartbeatConnection2 = nil
	end

	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)
	v24 = false
	v25 = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeBartender()
	disarmBartenderTrigger()
	v28 = nil
	v29 = nil
	v30 = nil

	if v34 then
		v34:Cancel()
		v34 = nil
	end

	v32 = nil
	v33 = false

	if v27 then
		v27:Destroy()
		v27 = nil
	end
end

local function distanceToBartender()
	local v43 = v10
	local character = Players.LocalPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoidRootPart = nil
	end

	if v43 and humanoidRootPart then
		return (humanoidRootPart.Position - v43.Position).Magnitude
	end

	return nil
end

local function bartenderFocusCFrame()
	local v43 = v10

	if not v43 then
		return nil
	end

	local lookVector = v43.LookVector
	local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
	local vector3 = not (vector2.Magnitude > 0.01) and createVector(0, 0, 1) or vector2.Unit
	local cross = vector3:Cross(createVector(0, 1, 0))
	local v44 = not (cross.Magnitude > 0.001) and createVector(1, 0, 0) or cross.Unit
	return framedShot(
		v43.Position + vector3 * v3.BARTENDER_CAM_FRONT + v44 * v3.BARTENDER_CAM_SIDE + Vector3.new(
			0,
			v3.BARTENDER_CAM_UP,
			0
		),
		v43.Position + Vector3.new(0, v3.BARTENDER_CAM_LOOK_UP, 0)
	)
end

local function startBartenderDialogue()
	local v43 = v5

	if v23 or not (v43 or flag6) then
		return
	end

	local DialogueController = require(game.ReplicatedStorage.DialogueController)

	if DialogueController.Active then
		return
	end

	local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
	local v44 = DialogueController.new()
	v44:setTitle(v4.OWNER_NAME)
	v44:addPage("Main", function(object2)
		object2:setTitle(v4.OWNER_NAME)
		local v45 = bartenderFocusCFrame()

		if v45 then
			local v46 = CameraController.new()
			v44:getMaid():GiveTask(function()
				v46:FadeOut(v4.CINEMATIC_RETURN_TIME)
			end)
			v46.Animations:AnimateTo(v45, 1, 1.5)
		end

		if flag6 then
			object2:addText("Still standing, this old place - and that's down to you.")
			object2:addText("Any time you're passing through, the first drink's on the house.")
		elseif v20 and v43 then
			object2:addText("You... you saved me!")
			object2:addText("Sheesh, this place is a wreck. But, I owe you big time. If it weren't for you, I'd have more damaged supplies that I'd have to pay for.")
			object2:addText("Thank you for your help. Hopefully I don't see those pirates again! Here, a brew on the house. Then go let the Pirate Adventurer know I'm doing okay, thanks to you.")
			object2:noCancel()
			object2:addOptionType("Accept", function(object3)
				object3:setText("Take the brew")
				object3:onSelected(function()
					v43:FireServer("ClaimReward")
				end)
			end)
			object2:addOptionType("Leave", function(object3)
				object3:setText("Not yet")
			end)
		elseif flag then
			object2:addText("Look out! They're still smashing everything in sight!")
		else
			object2:addText("H-help... they've been at it for hours. They'll bring the whole tavern down!")
		end
	end)
	openDialogue(v44:build(), function(p)
		v23 = p
	end)
end

local function canInteractWithBartender()
	if not v27 or v23 or flag and not v20 then
		return false
	end

	local v43 = v10
	local character = Players.LocalPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoidRootPart = nil
	end

	local magnitude

	if v43 and humanoidRootPart then
		magnitude = (humanoidRootPart.Position - v43.Position).Magnitude
	end

	return magnitude ~= nil and magnitude <= v4.BARTENDER_INTERACT_RANGE
end

local function shouldAutoOpenBartender()
	if not v27 or v23 or (not v20 or flag6) then
		return false
	end

	local v43 = v10
	local character = Players.LocalPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoidRootPart = nil
	end

	local magnitude

	if v43 and humanoidRootPart then
		magnitude = (humanoidRootPart.Position - v43.Position).Magnitude
	end

	return magnitude ~= nil and magnitude <= v4.BARTENDER_APPROACH_RANGE
end

local function armBartenderTrigger()
	if heartbeatConnection2 then
		return
	end

	local DialogueController = require(game.ReplicatedStorage.DialogueController)
	v24 = false
	heartbeatConnection2 = RunService.Heartbeat:Connect(function()
		if v23 then
			local v43 = v10
			local character = Players.LocalPlayer.Character
			local humanoidRootPart

			if character then
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			end

			if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				humanoidRootPart = nil
			end

			local magnitude

			if v43 and humanoidRootPart then
				magnitude = (humanoidRootPart.Position - v43.Position).Magnitude
			end

			if magnitude == nil or v4.BARTENDER_LEAVE_RANGE < magnitude then
				DialogueController.close()
			end

			v24 = false
			v25 = true
			setTalkPromptVisible(false)
		else
			local v43

			if v27 and not v23 and (not flag or v20) then
				local v44 = v10
				local character = Players.LocalPlayer.Character
				local humanoidRootPart

				if character then
					humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				end

				if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
					humanoidRootPart = nil
				end

				local magnitude

				if v44 and humanoidRootPart then
					magnitude = (humanoidRootPart.Position - v44.Position).Magnitude
				end

				if magnitude == nil then
					v43 = false
				else
					v43 = magnitude <= v4.BARTENDER_INTERACT_RANGE
				end
			else
				v43 = false
			end

			v24 = v43
			setTalkPromptVisible(v24)

			if v24 then
				Global.tapCooldown = os.clock() + v4.INTERACT_TAP_COOLDOWN
			end

			local v44

			if v27 and not v23 and v20 and not flag6 then
				local v45 = v10
				local character = Players.LocalPlayer.Character
				local humanoidRootPart

				if character then
					humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				end

				if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
					humanoidRootPart = nil
				end

				local magnitude

				if v45 and humanoidRootPart then
					magnitude = (humanoidRootPart.Position - v45.Position).Magnitude
				end

				if magnitude == nil then
					v44 = false
				else
					v44 = magnitude <= v4.BARTENDER_APPROACH_RANGE
				end
			else
				v44 = false
			end

			if v44 and not v25 then
				v25 = true
				startBartenderDialogue()
			else
				v25 = v44
			end
		end
	end)

	local function onInteract(flag10: boolean)
		if flag10 or not v24 then
			return
		end

		startBartenderDialogue()
	end

	table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end

		if not gameProcessed then
			if not v24 then
				return
			end

			startBartenderDialogue()
		end
	end))
	table.insert(connections, UserInputService.TouchTap:Connect(function(_, flag10: boolean)
		if not flag10 then
			if not v24 then
				return
			end

			startBartenderDialogue()
		end
	end))
end

local function attachQuestIndicator()
	local v43 = v27

	if not v43 then
		return
	end

	local humanoidRootPart = v43:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart or not humanoidRootPart:IsA("BasePart") or humanoidRootPart:FindFirstChild(v4.QUEST_GUI) then
		return
	end

	local billboardGui = npcGuiTemplate(v4.QUEST_GUI)

	if not (billboardGui and billboardGui:IsA("BillboardGui")) then
		return
	end

	local clone = billboardGui:Clone()
	local title = clone:FindFirstChild("Title")

	if title and title:IsA("TextLabel") then
		title.Text = v4.AURA_NAME
		title.TextColor3 = v4.MISC_COLOR
	end

	local mark = clone:FindFirstChild("Mark")

	if mark and mark:IsA("TextLabel") then
		mark.Text = ""
		mark.Visible = true
		mark.TextColor3 = v4.MISC_COLOR
	end

	local markImage = clone:FindFirstChild("MarkImage")

	if markImage and markImage:IsA("GuiObject") then
		markImage.Visible = false
	end

	local head = v43:FindFirstChild("Head")

	if head and head:IsA("BasePart") then
		clone.ExtentsOffsetWorldSpace = createVector(0, 1, 0) * (humanoidRootPart.Position - head.Position).Magnitude
	end

	clone.Parent = humanoidRootPart
end

local function dressBartenderRig(folder)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false

		if part.Name == "LeftLowerArm" or part.Name == "RightLowerArm" then
			part.Size *= v4.BARTENDER_LOWER_ARM_SCALE
		end
	end

	local humanoid = folder:FindFirstChildWhichIsA("Humanoid")

	if humanoid then
		humanoid.DisplayName = v4.OWNER_NAME
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Subject
		humanoid.NameDisplayDistance = 40
		humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		humanoid.BreakJointsOnDeath = false
		humanoid.RequiresNeck = false
		humanoid.AutoRotate = false
		humanoid.EvaluateStateMachine = false
	end
end

local function ensureAnimator(parent)
	local animator = parent:FindFirstChildWhichIsA("Animator")

	if animator then
		return animator
	end

	local animator2 = Instance.new("Animator")
	animator2.Parent = parent
	return animator2
end

local function playLooped(animator, animation, priority, p: number)
	local success, result = pcall(function()
		return animator:LoadAnimation(animation)
	end)

	if not (success and result) then
		return nil
	end

	result.Priority = priority
	result.Looped = true
	result:Play(p)
	return result
end

local function playBartenderIdle(instance)
	local humanoid = instance:FindFirstChildWhichIsA("Humanoid")

	if not humanoid then
		return
	end

	local BARTENDER_SAVED_IDLE

	if v20 or flag6 then
		BARTENDER_SAVED_IDLE = v4.BARTENDER_SAVED_IDLE
	else
		BARTENDER_SAVED_IDLE = v4.BARTENDER_IDLE
	end

	if v29 == BARTENDER_SAVED_IDLE and v28 then
		return
	end

	local v43 = v28
	v28 = nil

	if v43 then
		pcall(function()
			v43:Stop(v4.BARTENDER_ANIM_FADE)
			v43:Destroy()
		end)
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = BARTENDER_SAVED_IDLE
	v29 = BARTENDER_SAVED_IDLE
	local v44 = humanoid:FindFirstChildWhichIsA("Animator")

	if not v44 then
		v44 = Instance.new("Animator")
		v44.Parent = humanoid
	end

	local idle = Enum.AnimationPriority.Idle
	local BARTENDER_ANIM_FADE = v4.BARTENDER_ANIM_FADE
	local success, result = pcall(function()
		return v44:LoadAnimation(animation)
	end)

	if success and result then
		result.Priority = idle
		result.Looped = true
		result:Play(BARTENDER_ANIM_FADE)
	else
		result = nil
	end

	v28 = result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshBartenderIdle()
	local v43 = v27

	if v43 then
		playBartenderIdle(v43)
	end
end

local function playBartenderAnimations(folder)
	playBartenderIdle(folder)

	for _, tool in folder:GetDescendants() do
		if not tool:IsA("Tool") then
			continue
		end

		local animationController = tool:FindFirstChildWhichIsA("AnimationController")
		local child = tool:FindFirstChild(v4.TOOL_ANIMS_FOLDER)
		local animation

		if child then
			animation = child:FindFirstChild(v4.TOOL_IDLE_ANIM)
		end

		if not (animationController and animation and animation:IsA("Animation")) then
			continue
		end

		local v43 = animationController:FindFirstChildWhichIsA("Animator")

		if not v43 then
			v43 = Instance.new("Animator")
			v43.Parent = animationController
		end

		local idle = Enum.AnimationPriority.Idle
		local animator = v43
		local v44 = animation
		local success, result = pcall(function()
			return animator:LoadAnimation(v44)
		end)

		if not (success and result) then
			continue
		end

		result.Priority = idle
		result.Looped = true
		result:Play(0)
	end
end

local function spawnBartender()
	local v43 = v10
	local v44 = v42

	if v27 or not (v43 and v44) then
		return
	end

	local clone = v44:Clone()
	clone.Name = v4.OWNER_NAME
	local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		clone.PrimaryPart = humanoidRootPart
		humanoidRootPart.Anchored = true
	end

	dressBartenderRig(clone)
	clone:PivotTo(v43)
	clone.Parent = workspace.Terrain
	v27 = clone
	playBartenderAnimations(clone)
	attachTalkPrompt(clone)
	armBartenderTrigger()
end

local function floorYAt(position: Vector3)
	local children = { workspace.Terrain }

	for _, childName in { "Characters", "Enemies", "NPCs" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(children, child)
		end
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = children
	raycastParams.RespectCanCollide = true
	raycastParams.IgnoreWater = true
	local raycastResult = workspace:Raycast(position + createVector(0, 6, 0), createVector(0, -40, 0), raycastParams)

	if raycastResult then
		return raycastResult.Position.Y
	end

	return position.Y - 4
end

local function removeBartenderPotion(folder)
	for _, tool in folder:GetDescendants() do
		if tool:IsA("Tool") and tool.Name == v4.BARTENDER_POTION_TOOL then
			tool:Destroy()
		end
	end
end

local function attachInteractionRing(instance)
	if v30 then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return
	end

	local assets = game.ReplicatedStorage:FindFirstChild("Assets")
	local child

	if assets then
		child = assets:FindFirstChild(v4.AURA_FOLDER)
	end

	local part

	if child then
		part = child:FindFirstChild(v4.AURA_NAME)
	end

	if not (part and part:IsA("BasePart")) then
		return
	end

	local vector2 = Vector3.new(
		humanoidRootPart.Position.X,
		floorYAt(humanoidRootPart.Position),
		humanoidRootPart.Position.Z
	)
	local cFrame2 = CFrame.new(vector2 + createVector(0, 1, 0) * v4.AURA_LIFT, vector2 + createVector(0, 1, 0)) * CFrame.Angles(
		-1.5707963267948966,
		0,
		0
	)
	local clone = part:Clone()
	local cFrame = clone.CFrame

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CFrame = cFrame2 * (cFrame:Inverse() * descendant.CFrame)
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
			descendant.CastShadow = false
		elseif descendant:IsA("ParticleEmitter") then
			descendant.LockedToPart = true

			if descendant.Name == "EmitOnce" then
				descendant.Enabled = false
			end
		end
	end

	clone.CFrame = cFrame2
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone.Parent = humanoidRootPart
	v30 = clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyBartenderSavedState()
	local v43 = v27

	if not (v43 and (v20 or flag6)) then
		return
	end

	removeBartenderPotion(v43)
	attachInteractionRing(v43)
	attachQuestIndicator()
	refreshBartenderIdle() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopBartenderStar()
	if not v31 then
		return
	end

	v31 = false
	pcall(function()
		CompassTracker.removeTracker("TavernBrawlBartender")
	end)
end

local function startBartenderStar()
	if v31 or not v10 then
		return
	end

	v31 = true
	pcall(function()
		CompassTracker.createTracker("TavernBrawlBartender", {
			Target = function()
				local v43 = v10

				if v43 then
					return v43.Position
				end

				return createVector(0, 0, 0)
			end,
			AlertIconSettings = {
				Sprite = "Badge Star"
			},
			IconSettings = {
				Sprite = "Badge Star",
				ShowIsland = false
			},
			ViewportSettings = {
				UseIconAsBackground = false
			},
			ShowOffScreenAlert = true
		})
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshBartenderStar()
	if v5 and v20 and not flag6 then
		if not v31 then
			if not v10 then
				return
			end

			v31 = true
			pcall(function()
				CompassTracker.createTracker("TavernBrawlBartender", {
					Target = function()
						local v43 = v10

						if v43 then
							return v43.Position
						end

						return createVector(0, 0, 0)
					end,
					AlertIconSettings = {
						Sprite = "Badge Star"
					},
					IconSettings = {
						Sprite = "Badge Star",
						ShowIsland = false
					},
					ViewportSettings = {
						UseIconAsBackground = false
					},
					ShowOffScreenAlert = true
				})
			end)
		end
	else
		stopBartenderStar() -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resetProgress()
	if v23 then
		local DialogueController = require(game.ReplicatedStorage.DialogueController)
		DialogueController.close()
	end

	v20 = false
	flag6 = false

	if v27 then
		removeBartender() -- equivalent call inferred; original call site unknown
		spawnBartender()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tumbleDebris(part, vector2: Vector3, vector3: Vector3, p: number, p2: number, p3: number, p4: number)
	local position = part.Position
	local v43 = part.CFrame - part.Position
	local v44 = p + part.Size.Y / 2
	local transparency = part.Transparency
	local v45 = vector2
	task.spawn(function()
		local total = 0

		while total < p3 and part.Parent do
			local v46 = RunService.RenderStepped:Wait()
			total += v46

			if v44 < position.Y then
				v45 -= Vector3.new(0, p2 * v46, 0)
				position += v45 * v46
				v43 = CFrame.Angles(vector3.X * v46, vector3.Y * v46, vector3.Z * v46) * v43

				if position.Y < v44 then
					position = Vector3.new(position.X, v44, position.Z)
				end
			end

			part.CFrame = CFrame.new(position) * v43

			if not (p4 < total) then
				continue
			end

			local v47 = math.clamp((total - p4) / (p3 - p4), 0, 1)
			part.Transparency = transparency + (1 - transparency) * v47
		end

		part:Destroy()
	end)
end

local function spawnGlassShard(position: Vector3, p: number)
	local part = Instance.new("Part")
	part.Name = "TavernGlassShard"
	part.Size = Vector3.new(
		v2.SHARD_SIZE_MIN + math.random() * v2.SHARD_SIZE_VAR,
		v2.SHARD_SIZE_MIN + math.random() * v2.SHARD_SIZE_VAR,
		v2.SHARD_SIZE_MIN + math.random() * v2.SHARD_SIZE_VAR
	)
	part.Color = v2.BOTTLE_COLOR
	part.Material = Enum.Material.Glass
	part.Transparency = v2.BOTTLE_TRANSPARENCY
	part.Reflectance = v2.BOTTLE_REFLECTANCE
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.CFrame = CFrame.new(position) * CFrame.Angles(math.random() * 6, math.random() * 6, math.random() * 6)
	part.Parent = workspace.Terrain
	local vector2 = Vector3.new(math.random() - 0.5, 0, math.random() - 0.5)
	tumbleDebris(
		part,
		(not (vector2.Magnitude > 0.01) and createVector(1, 0, 0) or vector2.Unit) * (v2.SHARD_SPEED_MIN + math.random() * v2.SHARD_SPEED_VAR) + Vector3.new(
			0,
			v2.SHARD_UP_MIN + math.random() * v2.SHARD_UP_VAR,
			0
		),
		Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * v2.SHARD_SPIN,
		p,
		v2.SHARD_GRAVITY,
		v2.SHARD_LIFETIME,
		v2.SHARD_FADE_START
	) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playRandomSound(list, cFrame: CFrame)
	pcall(function()
		Util.Sound:Play(list[math.random(#list)], cFrame)
	end)
end

local function shatterBottle(folder)
	local position = folder.Position
	folder.Transparency = 1

	for _, trail in folder:GetDescendants() do
		if trail:IsA("Trail") then
			trail.Enabled = false
		end
	end

	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Color = ColorSequence.new(v2.SHATTER_GLASS_COLOR)
	particleEmitter.LightEmission = 0.35
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 0.02)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.7, 0.35),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Lifetime = NumberRange.new(0.35, 0.8)
	particleEmitter.Speed = NumberRange.new(9, 22)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.Acceleration = createVector(0, -70, 0)
	particleEmitter.Drag = 2
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.RotSpeed = NumberRange.new(-320, 320)
	particleEmitter.Enabled = false
	particleEmitter.Parent = folder
	particleEmitter:Emit(v2.SHATTER_GLASS_COUNT)
	local particleEmitter2 = Instance.new("ParticleEmitter")
	particleEmitter2.Color = ColorSequence.new(v2.SHATTER_LIQUID_COLOR)
	particleEmitter2.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.55),
		NumberSequenceKeypoint.new(1, 0.1)
	})
	particleEmitter2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.25),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter2.Lifetime = NumberRange.new(0.25, 0.55)
	particleEmitter2.Speed = NumberRange.new(4, 12)
	particleEmitter2.SpreadAngle = Vector2.new(180, 180)
	particleEmitter2.Acceleration = createVector(0, -55, 0)
	particleEmitter2.Enabled = false
	particleEmitter2.Parent = folder
	particleEmitter2:Emit(v2.SHATTER_LIQUID_COUNT)
	local v43 = floorYAt(position)

	for _ = 1, v2.SHARD_COUNT do
		spawnGlassShard(position, v43)
	end

	playRandomSound(v2.BREAK_SOUNDS, folder.CFrame) -- equivalent call inferred; original call site unknown
	task.delay(v2.SHATTER_CLEANUP, function()
		folder:Destroy()
	end)
end

local function throwBottle(position: Vector3, vector2: Vector3)
	local magnitude = (vector2 - position).Magnitude
	local v43 = math.clamp(magnitude / v3.BOTTLE_SPEED, v3.BOTTLE_FLIGHT_MIN, v3.BOTTLE_FLIGHT_MAX)
	local v44 = math.min(magnitude * v3.BOTTLE_ARC_PER_STUD, v3.BOTTLE_ARC_MAX)
	task.spawn(function()
		local part = Instance.new("Part")
		part.Name = "TavernBrawlBottle"
		part.Size = v2.BOTTLE_SIZE
		part.Color = v2.BOTTLE_COLOR
		part.Material = Enum.Material.Glass
		part.Transparency = v2.BOTTLE_TRANSPARENCY
		part.Reflectance = v2.BOTTLE_REFLECTANCE
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.CFrame = CFrame.new(position)
		part.Parent = workspace.Terrain
		local attachment = Instance.new("Attachment")
		attachment.Position = Vector3.new(0, part.Size.Y / 2, 0)
		attachment.Parent = part
		local attachment2 = Instance.new("Attachment")
		attachment2.Position = Vector3.new(0, -part.Size.Y / 2, 0)
		attachment2.Parent = part
		local trail = Instance.new("Trail")
		trail.Attachment0 = attachment
		trail.Attachment1 = attachment2
		trail.Lifetime = v2.BOTTLE_TRAIL_LIFETIME
		trail.MinLength = 0
		trail.LightEmission = 0.3
		trail.Color = ColorSequence.new(v2.SHATTER_GLASS_COLOR)
		trail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.55),
			NumberSequenceKeypoint.new(1, 1)
		})
		trail.Parent = part
		local vector3 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)
		local v45 = (not (vector3.Magnitude > 0.01) and createVector(1, 0, 0) or vector3.Unit) * v2.BOTTLE_SPIN
		playRandomSound(v2.THROW_SOUNDS, part.CFrame) -- equivalent call inferred; original call site unknown
		local lastTime = os.clock()

		while true do
			local v46 = math.clamp((os.clock() - lastTime) / v43, 0, 1)
			local v47 = position:Lerp(vector2, v46) + Vector3.new(0, v44 * 4 * v46 * (1 - v46), 0)
			part.CFrame = CFrame.new(v47) * CFrame.Angles(v45.X * v46, v45.Y * v46, v45.Z * v46)

			if v46 >= 1 then
				break
			end

			RunService.RenderStepped:Wait()
		end

		shatterBottle(part)
	end)
end

local function findBrawlerRig(p: number)
	local enemies = workspace:FindFirstChild("Enemies")

	if not enemies then
		return nil
	end

	for _, model in enemies:GetChildren() do
		if model:IsA("Model") and model:GetAttribute(v4.BRAWLER_TAG) == p then
			return model
		end
	end

	return nil
end

local function throwOrigin(p: number, cframe: CFrame)
	local brawlerRig = findBrawlerRig(p)

	if brawlerRig then
		for _, childName in v3.THROW_HAND_PARTS do
			local part = brawlerRig:FindFirstChild(childName)

			if part and part:IsA("BasePart") then
				return part.Position
			end
		end
	end

	return cframe.Position + Vector3.new(0, v3.THROW_FALLBACK_UP, 0)
end

local function brawlerBottleThrow(brawler: number)
	if #v7 == 0 then
		return
	end

	local v43 = v5

	if v43 then
		v43:FireServer("ThrowBottle")
	end

	task.wait(v3.THROW_ANIM_LEAD)

	if not flag3 then
		return
	end

	local v44 = (brawler - 1) % #v7 + 1
	local v45 = throwOrigin(v44, v7[v44])
	local vector2 = Vector3.new(0, v3.BOTTLE_TARGET_UP + (math.random() - 0.5) * v3.BOTTLE_SPREAD_UP, 0)
	local v46 = v10
	local v47

	if v46 then
		v47 = v46.Position + vector2 + v46.RightVector * ((math.random() - 0.5) * v3.BOTTLE_SPREAD_SIDE) + v46.LookVector * ((math.random() - 0.5) * v3.BOTTLE_SPREAD_DEPTH)
	else
		local v48 = brawlerCentroid() -- equivalent call inferred; original call site unknown
		v47 = v48 + vector2 + Vector3.new(
			(math.random() - 0.5) * v3.BOTTLE_SPREAD_SIDE,
			0,
			(math.random() - 0.5) * v3.BOTTLE_SPREAD_SIDE
		)
	end

	throwBottle(v45, v47)
end

local function lerpV(vector2: Vector3, vector3: Vector3, p: number)
	return vector2 + (vector3 - vector2) * p
end

local function getControls()
	if v37 then
		return v37
	end

	local success, result = pcall(function()
		local playerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts", 5)
		local playerModule

		if playerScripts then
			playerModule = playerScripts:WaitForChild("PlayerModule", 5)
		end

		if not playerModule then
			return nil
		end

		local module = require(playerModule)
		return (module:GetControls())
	end)

	if not success then
		result = nil
	end

	v37 = result
	return v37
end

local function releaseMovementLock()
	if thread4 then
		task.cancel(thread4)
		thread4 = nil
	end

	local v43 = v35
	v35 = nil
	v36 = nil

	if v43 then
		pcall(function()
			v43:Unlock()
		end)
	end

	if flag8 then
		flag8 = false

		if not v37 then
			local success, result = pcall(function()
				local playerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts", 5)
				local playerModule

				if playerScripts then
					playerModule = playerScripts:WaitForChild("PlayerModule", 5)
				end

				if not playerModule then
					return nil
				end

				local module = require(playerModule)
				return (module:GetControls())
			end)

			if not success then
				result = nil
			end

			v37 = result
		end

		local v44 = v37

		if v44 then
			pcall(function()
				v44:Enable()
			end)
		end
	end
end

local function setMovementLocked(flag10: boolean)
	if not flag10 then
		releaseMovementLock()
		return
	end

	local character = Players.LocalPlayer.Character

	if v35 and v36 ~= character then
		releaseMovementLock()
	end

	if not v35 and character then
		local anyInstanceLock = AttributeCounter.anyInstanceLock(character, v4.MOVEMENT_COUNTER)
		anyInstanceLock:Lock()
		v35 = anyInstanceLock
		v36 = character
	end

	if not flag8 then
		flag8 = true

		if not v37 then
			local success, result = pcall(function()
				local playerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts", 5)
				local playerModule

				if playerScripts then
					playerModule = playerScripts:WaitForChild("PlayerModule", 5)
				end

				if not playerModule then
					return nil
				end

				local module = require(playerModule)
				return (module:GetControls())
			end)

			if not success then
				result = nil
			end

			v37 = result
		end

		local v43 = v37

		if v43 then
			pcall(function()
				v43:Disable()
			end)
		end
	end

	if thread4 then
		task.cancel(thread4)
	end

	thread4 = task.delay(v4.MOVEMENT_LOCK_MAX, function()
		thread4 = nil
		releaseMovementLock()
	end)
end

local function makeFade()
	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return nil, nil
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TavernBrawlCinematic"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 60
	screenGui.Parent = playerGui
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	return frame, screenGui
end

local function fade(fade2, backgroundTransparency: number, duration: number)
	if not fade2 then
		task.wait(duration)
		return
	end

	local tween = TweenService:Create(fade2, TweenInfo.new(duration), {
		BackgroundTransparency = backgroundTransparency
	})
	tween:Play()
	tween.Completed:Wait()
end

local function runShot(vector2: Vector3, vector3: Vector3, vector4: Vector3, vector5: Vector3, p: number)
	local v43 = cameraCollisionParams()
	local lastTime = os.clock()

	while true do
		local v44 = math.clamp((os.clock() - lastTime) / p, 0, 1)
		local currentCamera = workspace.CurrentCamera

		if not currentCamera then
			break
		end

		local v45 = vector4 + (vector5 - vector4) * v44
		currentCamera.CameraType = Enum.CameraType.Scriptable
		currentCamera.FieldOfView = v3.CUTSCENE_FOV
		local v46 = vector2 + (vector3 - vector2) * v44
		local v47 = v46 - v45

		if not (v47.Magnitude < 0.1) then
			local raycastResult = workspace:Raycast(v45, v47, v43)

			if raycastResult then
				local v48 = (raycastResult.Position - v45).Magnitude - v3.CAM_SKIN
				v46 = v45 + v47.Unit * math.max(v48, v3.CAM_MIN)
			end
		end

		currentCamera.CFrame = CFrame.lookAt(v46, v45)

		if v44 >= 1 then
			break
		else
			RunService.RenderStepped:Wait()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playKickAnimation()
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	pcall(function()
		local v43 = Util.Anims:GetLocal(character, v2.KICK_ANIMATION)

		if v43 then
			v43:Play(0.05, 1, 1.1)
		end
	end)
end

local function spawnSplinter(position: Vector3, vector2: Vector3, vector3: Vector3, p: number)
	local part = Instance.new("Part")
	part.Name = "TavernDoorSplinter"
	part.Size = Vector3.new(0.2 + math.random() * 0.3, 0.2 + math.random() * 0.4, 0.7 + math.random() * 1.5)
	part.Color = v2.DEBRIS_COLOR
	part.Material = Enum.Material.Wood
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	local v43 = position + vector3 * ((math.random() - 0.5) * 6) + Vector3.new(0, (math.random() - 0.5) * 7, 0)
	part.CFrame = CFrame.new(v43) * CFrame.Angles(math.random() * 6, math.random() * 6, math.random() * 6)
	part.Parent = workspace.Terrain
	tumbleDebris(
		part,
		vector2 * (v2.DEBRIS_SPEED_MIN + math.random() * (v2.DEBRIS_SPEED_MAX - v2.DEBRIS_SPEED_MIN)) + vector3 * ((math.random() - 0.5) * v2.DEBRIS_SIDE_SPREAD) + Vector3.new(
			0,
			math.random() * v2.DEBRIS_UP_SPREAD,
			0
		),
		Vector3.new((math.random() - 0.5) * 2, (math.random() - 0.5) * 2, (math.random() - 0.5) * 2) * v2.DEBRIS_SPIN,
		p,
		v2.DEBRIS_GRAVITY,
		v2.DEBRIS_LIFETIME,
		v2.DEBRIS_FADE_START
	) -- equivalent call inferred; original call site unknown
end

local function doorBurst(cframe: CFrame, vector2: Vector3)
	local cross = vector2:Cross(createVector(0, 1, 0))
	local v43 = not (cross.Magnitude > 0.001) and createVector(1, 0, 0) or cross.Unit
	local position = cframe.Position
	local v44 = floorYAt(position)
	pcall(function()
		Effect.new(v2.DUST_EFFECT):play({
			CFrame = CFrame.new(position + vector2 * v2.DUST_OFFSET),
			Size = { 0, v2.DUST_SIZE },
			Duration = v2.DUST_DURATION,
			ColorSequence = ColorSequence.new(v2.DUST_COLOR_A, v2.DUST_COLOR_B)
		})
	end)

	for _ = 1, v2.DEBRIS_COUNT do
		spawnSplinter(position, vector2, v43, v44)
	end
end

local function kickDoors(cframe: CFrame, vector2: Vector3)
	if #v40 == 0 then
		refreshDoorUnits()
	end

	local cross = vector2:Cross(createVector(0, 1, 0))
	local vector3 = not (cross.Magnitude > 0.001) and createVector(1, 0, 0) or cross.Unit

	for _, v43 in v40 do
		local door = v43.door

		if not door.Parent then
			continue
		end

		door.Anchored = false

		if v43.constraint and v43.constraint.Parent then
			v43.constraint:Destroy()
		end

		local v44 = vector3:Dot(door.Position - cframe.Position) >= 0 and 1 or -1
		door.AssemblyLinearVelocity = vector2 * 34 + vector3 * (v44 * 6) + createVector(0, 12, 0)
		door.AssemblyAngularVelocity = Vector3.new(
			(math.random() - 0.5) * 2,
			(math.random() - 0.5) * 2,
			(math.random() - 0.5) * 2
		) * 10
	end

	pcall(function()
		Util.Sound:Play(v2.KICK_SOUND, cframe)
	end)
	doorBurst(cframe, vector2)
	table.clear(v40)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelDoorCleanup()
	if thread3 then
		task.cancel(thread3)
		thread3 = nil
	end
end

local function scheduleDoorCleanup()
	cancelDoorCleanup() -- equivalent call inferred; original call site unknown
	local localDoorFolder = getLocalDoorFolder() -- equivalent call inferred; original call site unknown

	if not localDoorFolder then
		return
	end

	thread3 = task.delay(20, function()
		thread3 = nil

		if localDoorFolder.Parent then
			localDoorFolder:Destroy()
		end

		table.clear(v40)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearLocalDoors()
	cancelDoorCleanup() -- equivalent call inferred; original call site unknown
	local localDoorFolder = getLocalDoorFolder() -- equivalent call inferred; original call site unknown

	if localDoorFolder then
		localDoorFolder:Destroy()
	end

	table.clear(v40)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreDoors()
	cancelDoorCleanup() -- equivalent call inferred; original call site unknown
	table.clear(v40)
	v15 = false
	v16 = nil
	TavernDoors:Rebuild()
end

local function burstDoors(cframe: CFrame?, lookVector: Vector3?, flag10: boolean?)
	local localDoorFolder = getLocalDoorFolder() -- equivalent call inferred; original call site unknown

	if v15 and v16 == localDoorFolder then
		return false
	end

	local v43 = cframe or v6

	if not v43 then
		return false
	end

	if flag10 then
		if not localDoorFolder then
			return false
		end

		v15 = true
		v16 = nil
		clearLocalDoors() -- equivalent call inferred; original call site unknown
		return true
	else
		v15 = true
		v16 = localDoorFolder
		stopVibration()

		if not lookVector then
			local v45 = v6

			if v45 then
				local v46 = brawlerCentroid() -- equivalent call inferred; original call site unknown

				if v46 then
					local v47 = v46 - v45.Position
					lookVector = v45.LookVector
					local vector2 = Vector3.new(v47.X, 0, v47.Z)

					if vector2.Magnitude > 0.01 then
						lookVector = vector2.Unit
					end
				else
					local lookVector2 = v45.LookVector
					local vector2 = Vector3.new(lookVector2.X, 0, lookVector2.Z)

					if vector2.Magnitude > 0.01 then
						lookVector = vector2.Unit
					else
						lookVector = createVector(0, 0, 1)
					end
				end
			else
				lookVector = createVector(0, 0, 1)
			end
		end

		kickDoors(v43, lookVector)
		cancelDoorCleanup() -- equivalent call inferred; original call site unknown
		local localDoorFolder2 = getLocalDoorFolder() -- equivalent call inferred; original call site unknown

		if localDoorFolder2 then
			thread3 = task.delay(v.DOOR_REGEN_DELAY, function()
				thread3 = nil

				if localDoorFolder2.Parent then
					localDoorFolder2:Destroy()
				end

				table.clear(v40)
			end)
		end

		return true
	end
end

local function slotLateral(vector2: Vector3)
	if v17 <= 1 then
		return createVector(0, 0, 0)
	end

	local cross = vector2:Cross(createVector(0, 1, 0))
	local v43 = not (cross.Magnitude > 0.001) and createVector(1, 0, 0) or cross.Unit
	local v44 = v17 - 1
	return v43 * ((v44 % 2 == 1 and 1 or -1) * math.ceil(v44 / 2) * 4.5)
end

local function breachSpotPosition()
	local v43 = v6

	if not v43 then
		return nil
	end

	local v44 = v6
	local lookVector

	if v44 then
		local v45 = brawlerCentroid() -- equivalent call inferred; original call site unknown

		if v45 then
			local v46 = v45 - v44.Position
			lookVector = v44.LookVector
			local vector2 = Vector3.new(v46.X, 0, v46.Z)

			if vector2.Magnitude > 0.01 then
				lookVector = vector2.Unit
			end
		else
			local lookVector2 = v44.LookVector
			local vector2 = Vector3.new(lookVector2.X, 0, lookVector2.Z)

			if vector2.Magnitude > 0.01 then
				lookVector = vector2.Unit
			else
				lookVector = createVector(0, 0, 1)
			end
		end
	else
		lookVector = createVector(0, 0, 1)
	end

	local v45 = v43.Position - lookVector * 8
	local v46

	if v17 <= 1 then
		v46 = createVector(0, 0, 0)
	else
		local cross = lookVector:Cross(createVector(0, 1, 0))
		local v47 = not (cross.Magnitude > 0.001) and createVector(1, 0, 0) or cross.Unit
		local v48 = v17 - 1
		v46 = v47 * ((v48 % 2 == 1 and 1 or -1) * math.ceil(v48 / 2) * v.WALK_IN_SPACING)
	end

	return v45 + v46
end

local function atBreachSpot()
	local v43 = v6
	local v44

	if v43 then
		local v45 = v6
		local lookVector

		if v45 then
			local v46 = brawlerCentroid() -- equivalent call inferred; original call site unknown

			if v46 then
				local v47 = v46 - v45.Position
				lookVector = v45.LookVector
				local vector2 = Vector3.new(v47.X, 0, v47.Z)

				if vector2.Magnitude > 0.01 then
					lookVector = vector2.Unit
				end
			else
				local lookVector2 = v45.LookVector
				local vector2 = Vector3.new(lookVector2.X, 0, lookVector2.Z)

				if vector2.Magnitude > 0.01 then
					lookVector = vector2.Unit
				else
					lookVector = createVector(0, 0, 1)
				end
			end
		else
			lookVector = createVector(0, 0, 1)
		end

		local v46 = v43.Position - lookVector * v.BREACH_SPOT_GAP
		local v47

		if v17 <= 1 then
			v47 = createVector(0, 0, 0)
		else
			local cross = lookVector:Cross(createVector(0, 1, 0))
			local v48 = not (cross.Magnitude > 0.001) and createVector(1, 0, 0) or cross.Unit
			local v49 = v17 - 1
			v47 = v48 * ((v49 % 2 == 1 and 1 or -1) * math.ceil(v49 / 2) * v.WALK_IN_SPACING)
		end

		v44 = v46 + v47
	end

	local character = Players.LocalPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoidRootPart = nil
	end

	if v44 and humanoidRootPart then
		local v45 = humanoidRootPart.Position - v44
		return Vector3.new(v45.X, 0, v45.Z).Magnitude <= 6
	else
		return true
	end
end

local function awaitBreachSpot(object2)
	local total = 0
	local v43 = false

	while total < 1.5 do
		local v44 = v6
		local v45

		if v44 then
			local v46 = v6
			local lookVector

			if v46 then
				local v47 = brawlerCentroid() -- equivalent call inferred; original call site unknown

				if v47 then
					local v48 = v47 - v46.Position
					lookVector = v46.LookVector
					local vector2 = Vector3.new(v48.X, 0, v48.Z)

					if vector2.Magnitude > 0.01 then
						lookVector = vector2.Unit
					end
				else
					local lookVector2 = v46.LookVector
					local vector2 = Vector3.new(lookVector2.X, 0, lookVector2.Z)

					if vector2.Magnitude > 0.01 then
						lookVector = vector2.Unit
					else
						lookVector = createVector(0, 0, 1)
					end
				end
			else
				lookVector = createVector(0, 0, 1)
			end

			local v47 = v44.Position - lookVector * v.BREACH_SPOT_GAP
			local v48

			if v17 <= 1 then
				v48 = createVector(0, 0, 0)
			else
				local cross = lookVector:Cross(createVector(0, 1, 0))
				local v49 = not (cross.Magnitude > 0.001) and createVector(1, 0, 0) or cross.Unit
				local v50 = v17 - 1
				v48 = v49 * ((v50 % 2 == 1 and 1 or -1) * math.ceil(v50 / 2) * v.WALK_IN_SPACING)
			end

			v45 = v47 + v48
		end

		local character = Players.LocalPlayer.Character
		local humanoidRootPart

		if character then
			humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		end

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			humanoidRootPart = nil
		end

		local v46

		if v45 and humanoidRootPart then
			local v47 = humanoidRootPart.Position - v45
			v46 = Vector3.new(v47.X, 0, v47.Z).Magnitude <= v.BREACH_SPOT_RADIUS
		else
			v46 = true
		end

		if v46 then
			return
		end

		if not v43 and total >= 0.5 then
			object2:FireServer("TakeBreachSpot")
			v43 = true
		end

		total += task.wait(0.05)
	end

	warn("[Tavern Brawl] player never reached the breach spot - kicking anyway")
end

local function performKick(object2)
	local DISTANCE_EPSILON = 0.01
	stopVibration()
	stopBrawlNoise() -- equivalent call inferred; original call site unknown
	playKickAnimation() -- equivalent call inferred; original call site unknown
	task.wait(0.25)
	local v43 = v6
	local v44 = v6
	local lookVector

	if v44 then
		local v45 = brawlerCentroid() -- equivalent call inferred; original call site unknown

		if v45 then
			local v46 = v45 - v44.Position
			lookVector = v44.LookVector
			local vector2 = Vector3.new(v46.X, 0, v46.Z)

			if vector2.Magnitude > DISTANCE_EPSILON then
				lookVector = vector2.Unit
			end
		else
			local lookVector2 = v44.LookVector
			local vector2 = Vector3.new(lookVector2.X, 0, lookVector2.Z)

			if vector2.Magnitude > DISTANCE_EPSILON then
				lookVector = vector2.Unit
			else
				lookVector = createVector(0, 0, 1)
			end
		end
	else
		lookVector = createVector(0, 0, 1)
	end

	local localDoorFolder = getLocalDoorFolder() -- equivalent call inferred; original call site unknown

	if not v15 or v16 ~= localDoorFolder then
		local v45 = v43 or v6

		if v45 then
			v15 = true
			v16 = localDoorFolder
			stopVibration()

			if not lookVector then
				local v47 = v6

				if v47 then
					local v48 = brawlerCentroid() -- equivalent call inferred; original call site unknown

					if v48 then
						local v49 = v48 - v47.Position
						lookVector = v47.LookVector
						local vector2 = Vector3.new(v49.X, 0, v49.Z)

						if vector2.Magnitude > DISTANCE_EPSILON then
							lookVector = vector2.Unit
						end
					else
						local lookVector2 = v47.LookVector
						local vector2 = Vector3.new(lookVector2.X, 0, lookVector2.Z)

						if vector2.Magnitude > DISTANCE_EPSILON then
							lookVector = vector2.Unit
						else
							lookVector = createVector(0, 0, 1)
						end
					end
				else
					lookVector = createVector(0, 0, 1)
				end
			end

			kickDoors(v45, lookVector)
			cancelDoorCleanup() -- equivalent call inferred; original call site unknown
			local localDoorFolder2 = getLocalDoorFolder() -- equivalent call inferred; original call site unknown

			if localDoorFolder2 then
				thread3 = task.delay(v.DOOR_REGEN_DELAY, function()
					thread3 = nil

					if localDoorFolder2.Parent then
						localDoorFolder2:Destroy()
					end

					table.clear(v40)
				end)
			end
		end
	end

	object2:FireServer("DoorsKicked")
end

local function walkInside()
	local v43 = v6

	if not v43 then
		return
	end

	local character = Players.LocalPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if not humanoid or humanoid.Health <= 0 or not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return
	end

	local v44 = v6
	local lookVector

	if v44 then
		local v45 = brawlerCentroid() -- equivalent call inferred; original call site unknown

		if v45 then
			local v46 = v45 - v44.Position
			lookVector = v44.LookVector
			local vector2 = Vector3.new(v46.X, 0, v46.Z)

			if vector2.Magnitude > 0.01 then
				lookVector = vector2.Unit
			end
		else
			local lookVector2 = v44.LookVector
			local vector2 = Vector3.new(lookVector2.X, 0, lookVector2.Z)

			if vector2.Magnitude > 0.01 then
				lookVector = vector2.Unit
			else
				lookVector = createVector(0, 0, 1)
			end
		end
	else
		lookVector = createVector(0, 0, 1)
	end

	local v45

	if v17 <= 1 then
		v45 = createVector(0, 0, 0)
	else
		local cross = lookVector:Cross(createVector(0, 1, 0))
		local v46 = not (cross.Magnitude > 0.001) and createVector(1, 0, 0) or cross.Unit
		local v47 = v17 - 1
		v45 = v46 * ((v47 % 2 == 1 and 1 or -1) * math.ceil(v47 / 2) * v.WALK_IN_SPACING)
	end

	for _, position in { v43.Position - lookVector * 4 + v45, v43.Position + lookVector * 10 + v45 } do
		humanoid:MoveTo(position)
		local v46 = false
		local moveToFinishedConnection = humanoid.MoveToFinished:Once(function()
			v46 = true
		end)
		local total = 0

		while not v46 and total < 3 do
			total += task.wait(0.05)
		end

		moveToFinishedConnection:Disconnect()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disarmTrigger()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	v18 = false
end

local fn

-- equivalent calls inferred from this helper; original call sites unknown
local function abandonBreach(p)
	flag2 = false
	stopVibration()
	stopBrawlNoise() -- equivalent call inferred; original call site unknown
	local v43 = v38
	v38 = nil

	if v43 then
		local flag10 = false
		pcall(function()
			if flag10 then
				v43:Destroy()
			else
				v43:FadeOut(v4.CINEMATIC_RETURN_TIME)
			end
		end)
	end

	releaseMovementLock()

	if v5 == p and not (flag or v13) then
		fn()
	end
end

local function championShot()
	local v43

	if v8 and v7[v8] then
		v43 = v7[v8].Position
	end

	local v44 = v9 or v43

	if v44 then
		return closeUpShot({ v44 }, v3.CONFRONT_CAM_BACK, v3.CONFRONT_CAM_UP)
	end

	return nil
end

local function releaseConfrontCamera(flag10: boolean)
	local v43 = v39
	v39 = nil

	if not v43 then
		return
	end

	pcall(function()
		if flag10 then
			v43:Destroy()
		else
			v43:FadeOut(v4.CINEMATIC_RETURN_TIME)
		end
	end)
end

local function runFightTransition()
	local DialogueController = require(game.ReplicatedStorage.DialogueController)
	local fade2, v43 = makeFade()
	setMovementLocked(true)
	fade(fade2, 0, v3.FIGHT_FADE_OUT)
	local v44 = v39
	v39 = nil

	if v44 then
		local flag10 = true
		pcall(function()
			if flag10 then
				v44:Destroy()
			else
				v44:FadeOut(v4.CINEMATIC_RETURN_TIME)
			end
		end)
	end

	if v11 then
		DialogueController.close()
	end

	task.wait(v3.FIGHT_FADE_HOLD)
	fade(fade2, 1, v3.FIGHT_FADE_IN)

	if v43 then
		v43:Destroy()
	end

	releaseMovementLock()
	flag9 = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function requestFight(object2)
	if flag4 then
		return
	end

	flag4 = true
	setMovementLocked(true)
	object2:FireServer("BeginFight")
end

local function startConfrontation(object2)
	if v5 ~= object2 then
		return
	end

	local DialogueController = require(game.ReplicatedStorage.DialogueController)

	if DialogueController.Active then
		requestFight(object2) -- equivalent call inferred; original call site unknown
	else
		local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
		local v43 = DialogueController.new()
		v43:setTitle("Tavern Pirate")

		local function finishConfrontation()
			requestFight(object2) -- equivalent call inferred; original call site unknown
		end

		local function aimAt(cframe: CFrame?)
			if not cframe then
				return
			end

			if v39 then
				v39.Animations:AnimateTo(cframe, 1, v3.CONFRONT_PAN_FREQ)
				return
			end

			local v44 = CameraController.new()
			v39 = v44
			v43:getMaid():GiveTask(function()
				if not flag9 then
					local v45 = v39
					v39 = nil

					if not v45 then
						return
					end

					local flag10 = false
					pcall(function()
						if flag10 then
							v45:Destroy()
						else
							v45:FadeOut(v4.CINEMATIC_RETURN_TIME)
						end
					end)
				end
			end)
			v44.Animations:AnimateTo(cframe, 1, 1.6)
		end

		v43:addPage("Main", function(object3)
			object3:setTitle("Tavern Pirate")
			object3:setSubtitle("Tavern Wreckers")
			object3:noCancel()
			setMovementLocked(true)
			aimAt(fighterTwoShot(v3.CONFRONT_CAM_BACK, v3.CONFRONT_CAM_UP, v3.CONFRONT_CAM_ARC))
			object3:addText("OI! Who kicked the door in?!")
			object3:addText("Look at this one, lads... bargin' into OUR tavern!")
			object3:jumpToOnAdvance("Champion")
			object3:onFinished(finishConfrontation)
		end)
		v43:addPage("Champion", function(object3)
			object3:setTitle("Tavern Pirate")
			object3:setSubtitle("Tavern Wreckers")
			object3:noCancel()
			setMovementLocked(true)
			aimAt(championShot())
			object3:addText("You think you can get in the way of our fun? Think twice before meddling in our business!")
			object3:addText("Y'know it's pirate code to fight fair... so it's just me and you. Put 'em up!")
			object3:onFinished(finishConfrontation)
		end)

		if not openDialogue(v43:build(), function(p)
			v11 = p
		end) then
			requestFight(object2) -- equivalent call inferred; original call site unknown
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function requestGangUp(object2)
	if flag5 then
		return
	end

	flag5 = true
	object2:FireServer("BeginGangUp")
end

local function startGangUp(list)
	local v43 = v5

	if not v43 or v21 then
		return
	end

	v21 = true
	local DialogueController = require(game.ReplicatedStorage.DialogueController)

	if DialogueController.Active then
		requestGangUp(v43) -- equivalent call inferred; original call site unknown
	else
		local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
		local v44 = DialogueController.new()
		v44:setTitle("Tavern Pirate")
		v44:addPage("Main", function(object2)
			object2:setTitle("Tavern Pirate")
			object2:setSubtitle("Tavern Wreckers")
			object2:noCancel()
			setMovementLocked(true)
			local v45 = closeUpShot(list, v3.GANG_CAM_BACK, v3.GANG_CAM_UP)

			if v45 then
				local v46 = CameraController.new()
				v44:getMaid():GiveTask(function()
					v46:FadeOut(v4.CINEMATIC_RETURN_TIME)
				end)
				v46.Animations:AnimateTo(v45, 1, 1.6)
			end

			object2:addText("Whattt...? Maybe there's some grit to this person after all. They seem tough..")

			if #list > 1 then
				object2:addText("You aren't going to get in the way of our fun, especially after pummeling our friend!")
				object2:addText("Forget the code! BOTH of us, NOW! Put 'im through the floorboards!")
			else
				object2:addText("Forget the code - I'm finishin' what he started!")
			end

			object2:onFinished(function()
				requestGangUp(v43) -- equivalent call inferred; original call site unknown
			end)
		end)
		local v46 = openDialogue(v44:build(), function(p)
			v11 = p
		end)
		releaseMovementLock()

		if not v46 then
			requestGangUp(v43) -- equivalent call inferred; original call site unknown
		end
	end
end

local function doorWatchAim(vector2: Vector3, vector3: Vector3, vector4: Vector3)
	local unit = (vector4 - vector2).Unit
	local lerped = unit:Lerp((vector3 - vector2).Unit, v3.DOOR_WATCH_AIM_BLEND)

	if lerped.Magnitude < 0.001 then
		lerped = unit
	end

	return vector2 + lerped.Unit * v3.DOOR_WATCH_AIM_DIST
end

local function doorWatchShot(cframe: CFrame, lookVector: Vector3)
	local DISTANCE_EPSILON = 0.001
	local cross = lookVector:Cross(createVector(0, 1, 0))
	local v43 = not (cross.Magnitude > DISTANCE_EPSILON) and createVector(1, 0, 0) or cross.Unit
	local v44

	if v8 then
		v44 = v7[v8]
	end

	local position

	if v44 then
		position = v44.Position
	else
		if #v7 ~= 0 then
			local v45 = createVector(0, 0, 0)

			for _, v46 in v7 do
				v45 += v46.Position
			end

			position = v45 / #v7
		end

		if not position then
			position = cframe.Position
		end
	end

	local v45 = position + createVector(0, 1, 0) * v3.DOOR_WATCH_SLEEPER_UP
	local v46 = v45 + lookVector * v3.DOOR_WATCH_BACK + v43 * v3.DOOR_WATCH_SIDE + createVector(0, 1, 0) * v3.DOOR_WATCH_UP
	local v47 = cframe.Position + createVector(0, 1, 0) * v3.DOOR_WATCH_LOOK_UP
	local v48 = v46 + lookVector * v3.DOOR_WATCH_DRIFT
	local v49 = v46 - lookVector * v3.DOOR_WATCH_DRIFT
	local unit = (v47 - v48).Unit
	local lerped = unit:Lerp((v45 - v48).Unit, v3.DOOR_WATCH_AIM_BLEND)

	if lerped.Magnitude < DISTANCE_EPSILON then
		lerped = unit
	end

	local v50 = v48 + lerped.Unit * v3.DOOR_WATCH_AIM_DIST
	local unit2 = (v47 - v49).Unit
	local lerped2 = unit2:Lerp((v45 - v49).Unit, v3.DOOR_WATCH_AIM_BLEND)

	if lerped2.Magnitude < DISTANCE_EPSILON then
		lerped2 = unit2
	end

	return v48, v49, v50, v49 + lerped2.Unit * v3.DOOR_WATCH_AIM_DIST
end

local function runBreachCutscene(object2)
	local DISTANCE_EPSILON = 0.01
	local v43 = v6

	if not v43 or #v7 == 0 then
		return false
	end

	local v44 = fighterPositions()

	if #v44 == 0 then
		return false
	end

	local v45 = v6
	local lookVector

	if v45 then
		local v46 = brawlerCentroid() -- equivalent call inferred; original call site unknown

		if v46 then
			local v47 = v46 - v45.Position
			lookVector = v45.LookVector
			local vector2 = Vector3.new(v47.X, 0, v47.Z)

			if vector2.Magnitude > DISTANCE_EPSILON then
				lookVector = vector2.Unit
			end
		else
			local lookVector2 = v45.LookVector
			local vector2 = Vector3.new(lookVector2.X, 0, lookVector2.Z)

			if vector2.Magnitude > DISTANCE_EPSILON then
				lookVector = vector2.Unit
			else
				lookVector = createVector(0, 0, 1)
			end
		end
	else
		lookVector = createVector(0, 0, 1)
	end

	local v46 = createVector(0, 0, 0)

	for _, v47 in v44 do
		v46 += v47
	end

	local v47 = v46 / #v44
	local v48 = 0

	for _, v49 in v44 do
		v48 = math.max(v48, (v49 - v47).Magnitude)
	end

	local unit

	if #v44 > 1 then
		local v49 = v44[#v44] - v44[1]
		local vector2 = Vector3.new(v49.X, 0, v49.Z)

		if vector2.Magnitude > DISTANCE_EPSILON then
			unit = vector2.Unit
		else
			unit = lookVector
		end
	else
		unit = lookVector
	end

	local cross = unit:Cross(createVector(0, 1, 0))
	local unit2

	if cross.Magnitude > 0.001 then
		unit2 = cross.Unit
	else
		unit2 = -lookVector
	end

	if unit2:Dot(-lookVector) < 0 then
		unit2 = -unit2
	end

	local fade2, v49 = makeFade()
	local currentCamera = workspace.CurrentCamera
	local cameraType

	if currentCamera then
		cameraType = currentCamera.CameraType
	else
		cameraType = Enum.CameraType.Custom
	end

	local fieldOfView = not currentCamera and 70 or currentCamera.FieldOfView

	local function restoreCamera()
		local currentCamera2 = workspace.CurrentCamera

		if currentCamera2 then
			currentCamera2.FieldOfView = fieldOfView
			local cameraType2

			if cameraType == Enum.CameraType.Scriptable then
				cameraType2 = Enum.CameraType.Custom
			else
				cameraType2 = cameraType
			end

			currentCamera2.CameraType = cameraType2
		end
	end

	fade(fade2, 0, 0.35)
	local v51 = v38
	v38 = nil

	if v51 then
		local flag10 = true
		pcall(function()
			if flag10 then
				v51:Destroy()
			else
				v51:FadeOut(v4.CINEMATIC_RETURN_TIME)
			end
		end)
	end

	object2:FireServer("TakeBreachSpot")
	flag7 = true
	local v52 = v47 + createVector(0, 1, 0) * v3.FIGHTER_FOCUS_UP
	local v53 = math.max(v3.FIGHTER_CAM_CLOSE, v48 * v3.FIGHTER_CAM_SPREAD)
	local v55 = flatUnit(v43.Position - v47, unit2) -- equivalent call inferred; original call site unknown
	local v57 = flatUnit(unit2 * v3.FIGHTER_APPROACH_BIAS + v55, unit2) -- equivalent call inferred; original call site unknown
	local v58 = v52 + v57 * math.max(v3.FIGHTER_CAM_WIDE, v53 + 6) + createVector(0, 1, 0) * v3.FIGHTER_CAM_HIGH
	local v59 = v52 + v57 * math.max(v3.FIGHTER_CAM_PUSH, v53) + createVector(0, 1, 0) * v3.FIGHTER_CAM_MID
	local v60 = v52 + rotateFlat(unit2, v3.FIGHTER_ARC) * v53 + createVector(0, 1, 0) * v3.FIGHTER_CAM_MID
	local v61 = v52 + rotateFlat(unit2, -v3.FIGHTER_ARC) * v53 + createVector(0, 1, 0) * v3.FIGHTER_CAM_MID

	if currentCamera then
		currentCamera.CameraType = Enum.CameraType.Scriptable
		currentCamera.FieldOfView = v3.CUTSCENE_FOV
		currentCamera.CFrame = CFrame.lookAt(v58, v52)
	end

	for _, v62 in v3.BOTTLE_THROWS do
		local v63 = v62
		task.delay(v62.time, function()
			if flag3 then
				brawlerBottleThrow(v63.brawler)
			end
		end)
	end

	fade(fade2, 1, 0.4)
	local v62 = false
	local success, result = pcall(function()
		local DISTANCE_EPSILON2 = 0.01
		runShot(v58, v59, v52, v52, v3.SHOT1_TIME)
		runShot(v60, v61, v52, v52, v3.SHOT2_TIME)
		local v63 = v10

		if v63 then
			local lookVector2 = v63.LookVector
			local unit3 = -lookVector
			local vector2 = Vector3.new(lookVector2.X, 0, lookVector2.Z)

			if vector2.Magnitude > DISTANCE_EPSILON2 then
				unit3 = vector2.Unit
			end

			local v64 = v63.Position + createVector(0, 0.6, 0)
			runShot(
				v63.Position + unit3 * 7 + createVector(0, 2.5, 0),
				v63.Position + unit3 * 4.5 + createVector(0, 1.8, 0),
				v64,
				v64,
				v3.BARTENDER_SHOT_TIME
			)
		end

		local v64, v65, v66, v67 = doorWatchShot(v43, lookVector)
		local v68 = v3.DOOR_WATCH_LEAD / (v3.DOOR_WATCH_LEAD + v3.DOOR_WATCH_HOLD)
		local lerped = v64:Lerp(v65, v68)
		local lerped2 = v66:Lerp(v67, v68)
		object2:FireServer("TakeBreachSpot")
		runShot(v64, lerped, v66, lerped2, v3.DOOR_WATCH_LEAD)
		awaitBreachSpot(object2)
		v62 = true
		stopVibration()
		stopBrawlNoise() -- equivalent call inferred; original call site unknown
		playKickAnimation() -- equivalent call inferred; original call site unknown
		task.wait(v.KICK_ANIM_LEAD)
		local v70 = v6
		local v71 = v6
		local lookVector2

		if v71 then
			local v72 = brawlerCentroid() -- equivalent call inferred; original call site unknown

			if v72 then
				local v73 = v72 - v71.Position
				lookVector2 = v71.LookVector
				local vector2 = Vector3.new(v73.X, 0, v73.Z)

				if vector2.Magnitude > DISTANCE_EPSILON2 then
					lookVector2 = vector2.Unit
				end
			else
				local lookVector3 = v71.LookVector
				local vector2 = Vector3.new(lookVector3.X, 0, lookVector3.Z)

				if vector2.Magnitude > DISTANCE_EPSILON2 then
					lookVector2 = vector2.Unit
				else
					lookVector2 = createVector(0, 0, 1)
				end
			end
		else
			lookVector2 = createVector(0, 0, 1)
		end

		local localDoorFolder = getLocalDoorFolder() -- equivalent call inferred; original call site unknown

		if not v15 or v16 ~= localDoorFolder then
			local v72 = v70 or v6

			if v72 then
				v15 = true
				v16 = localDoorFolder
				stopVibration()

				if not lookVector2 then
					local v74 = v6

					if v74 then
						local v75 = brawlerCentroid() -- equivalent call inferred; original call site unknown

						if v75 then
							local v76 = v75 - v74.Position
							lookVector2 = v74.LookVector
							local vector2 = Vector3.new(v76.X, 0, v76.Z)

							if vector2.Magnitude > DISTANCE_EPSILON2 then
								lookVector2 = vector2.Unit
							end
						else
							local lookVector3 = v74.LookVector
							local vector2 = Vector3.new(lookVector3.X, 0, lookVector3.Z)

							if vector2.Magnitude > DISTANCE_EPSILON2 then
								lookVector2 = vector2.Unit
							else
								lookVector2 = createVector(0, 0, 1)
							end
						end
					else
						lookVector2 = createVector(0, 0, 1)
					end
				end

				kickDoors(v72, lookVector2)
				cancelDoorCleanup() -- equivalent call inferred; original call site unknown
				local localDoorFolder2 = getLocalDoorFolder() -- equivalent call inferred; original call site unknown

				if localDoorFolder2 then
					thread3 = task.delay(v.DOOR_REGEN_DELAY, function()
						thread3 = nil

						if localDoorFolder2.Parent then
							localDoorFolder2:Destroy()
						end

						table.clear(v40)
					end)
				end
			end
		end

		object2:FireServer("DoorsKicked")
		local v72 = true
		task.spawn(function()
			task.wait(0.4)
			walkInside()
			v72 = false
		end)
		runShot(lerped, v65, lerped2, v67, v3.DOOR_WATCH_HOLD)
		local total = 0

		while v72 and total < 3 do
			total += task.wait(0.1)
		end
	end)

	if success then
		fade(fade2, 0, 0.35)
		local currentCamera2 = workspace.CurrentCamera

		if currentCamera2 then
			currentCamera2.FieldOfView = fieldOfView

			if cameraType == Enum.CameraType.Scriptable then
				cameraType = Enum.CameraType.Custom
			end

			currentCamera2.CameraType = cameraType
		end

		fade(fade2, 1, 0.4)

		if v49 then
			v49:Destroy()
		end

		return v62
	else
		warn((`[Tavern Brawl] breach cutscene failed: {result}`))
		local currentCamera2 = workspace.CurrentCamera

		if currentCamera2 then
			currentCamera2.FieldOfView = fieldOfView

			if cameraType == Enum.CameraType.Scriptable then
				cameraType = Enum.CameraType.Custom
			end

			currentCamera2.CameraType = cameraType
		end

		if v49 then
			v49:Destroy()
		end

		return v62
	end
end

local function runBreachSequence(object2)
	if flag3 then
		return
	end

	flag3 = true

	if v6 then
		setMovementLocked(true)
		local success, result = pcall(function()
			local DISTANCE_EPSILON = 0.01

			if not runBreachCutscene(object2) then
				object2:FireServer("TakeBreachSpot")
				awaitBreachSpot(object2)
				stopVibration()
				stopBrawlNoise() -- equivalent call inferred; original call site unknown
				playKickAnimation() -- equivalent call inferred; original call site unknown
				task.wait(v.KICK_ANIM_LEAD)
				local v44 = v6
				local v45 = v6
				local lookVector

				if v45 then
					local v46 = brawlerCentroid() -- equivalent call inferred; original call site unknown

					if v46 then
						local v47 = v46 - v45.Position
						lookVector = v45.LookVector
						local vector2 = Vector3.new(v47.X, 0, v47.Z)

						if vector2.Magnitude > DISTANCE_EPSILON then
							lookVector = vector2.Unit
						end
					else
						local lookVector2 = v45.LookVector
						local vector2 = Vector3.new(lookVector2.X, 0, lookVector2.Z)

						if vector2.Magnitude > DISTANCE_EPSILON then
							lookVector = vector2.Unit
						else
							lookVector = createVector(0, 0, 1)
						end
					end
				else
					lookVector = createVector(0, 0, 1)
				end

				local localDoorFolder = getLocalDoorFolder() -- equivalent call inferred; original call site unknown

				if not v15 or v16 ~= localDoorFolder then
					local v46 = v44 or v6

					if v46 then
						v15 = true
						v16 = localDoorFolder
						stopVibration()

						if not lookVector then
							local v48 = v6

							if v48 then
								local v49 = brawlerCentroid() -- equivalent call inferred; original call site unknown

								if v49 then
									local v50 = v49 - v48.Position
									lookVector = v48.LookVector
									local vector2 = Vector3.new(v50.X, 0, v50.Z)

									if vector2.Magnitude > DISTANCE_EPSILON then
										lookVector = vector2.Unit
									end
								else
									local lookVector2 = v48.LookVector
									local vector2 = Vector3.new(lookVector2.X, 0, lookVector2.Z)

									if vector2.Magnitude > DISTANCE_EPSILON then
										lookVector = vector2.Unit
									else
										lookVector = createVector(0, 0, 1)
									end
								end
							else
								lookVector = createVector(0, 0, 1)
							end
						end

						kickDoors(v46, lookVector)
						cancelDoorCleanup() -- equivalent call inferred; original call site unknown
						local localDoorFolder2 = getLocalDoorFolder() -- equivalent call inferred; original call site unknown

						if localDoorFolder2 then
							thread3 = task.delay(v.DOOR_REGEN_DELAY, function()
								thread3 = nil

								if localDoorFolder2.Parent then
									localDoorFolder2:Destroy()
								end

								table.clear(v40)
							end)
						end
					end
				end

				object2:FireServer("DoorsKicked")
				task.wait(0.4)
				walkInside()
			end
		end)
		local v43 = v38
		v38 = nil

		if v43 then
			local flag10 = false
			pcall(function()
				if flag10 then
					v43:Destroy()
				else
					v43:FadeOut(v4.CINEMATIC_RETURN_TIME)
				end
			end)
		end

		if not success then
			warn((`[Tavern Brawl] breach sequence failed: {result}`))
			stopVibration()
			stopBrawlNoise() -- equivalent call inferred; original call site unknown
		end

		startConfrontation(object2)
		flag3 = false
	else
		stopVibration()
		stopBrawlNoise() -- equivalent call inferred; original call site unknown
		local v43 = v38
		v38 = nil

		if v43 then
			local flag10 = false
			pcall(function()
				if flag10 then
					v43:Destroy()
				else
					v43:FadeOut(v4.CINEMATIC_RETURN_TIME)
				end
			end)
		end

		releaseMovementLock()
		flag3 = false
	end
end

local function doorRevealCFrame(cframe: CFrame)
	local v43 = v6
	local lookVector

	if v43 then
		local v44 = brawlerCentroid() -- equivalent call inferred; original call site unknown

		if v44 then
			local v45 = v44 - v43.Position
			lookVector = v43.LookVector
			local vector2 = Vector3.new(v45.X, 0, v45.Z)

			if vector2.Magnitude > 0.01 then
				lookVector = vector2.Unit
			end
		else
			local lookVector2 = v43.LookVector
			local vector2 = Vector3.new(lookVector2.X, 0, lookVector2.Z)

			if vector2.Magnitude > 0.01 then
				lookVector = vector2.Unit
			else
				lookVector = createVector(0, 0, 1)
			end
		end
	else
		lookVector = createVector(0, 0, 1)
	end

	local vector2 = -lookVector
	local cross = vector2:Cross(createVector(0, 1, 0))
	local v44 = not (cross.Magnitude > 0.001) and createVector(1, 0, 0) or cross.Unit
	local v45 = cframe.Position + vector2 * v3.INTRO_CAM_BACK + v44 * v3.INTRO_CAM_SIDE + Vector3.new(
		0,
		v3.INTRO_CAM_UP,
		0
	)
	return CFrame.lookAt(v45, cframe.Position + Vector3.new(0, v3.INTRO_CAM_LOOK_UP, 0))
end

local function buildIntroDialogue(object2)
	local DialogueController = require(game.ReplicatedStorage.DialogueController)
	local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
	local v43 = {
		controller = nil
	}
	local v44 = DialogueController.new()
	v44:setTitle("???")
	return v44:addPage("Main", function(object3)
		startVibration() -- equivalent call inferred; original call site unknown
		startBrawlNoise() -- equivalent call inferred; original call site unknown
		v44:getMaid():GiveTask(function()
			if not (flag or v12) then
				stopVibration()
				stopBrawlNoise() -- equivalent call inferred; original call site unknown
			end
		end)
		local v45 = v6

		if v45 and not v43.controller then
			local controller = CameraController.new()
			v43.controller = controller
			v44:getMaid():GiveTask(function()
				if flag2 then
					v38 = controller
				else
					controller:FadeOut(v4.CINEMATIC_RETURN_TIME)
				end
			end)
			controller.Animations:AnimateTo(doorRevealCFrame(v45), 1, 1.5)
		end

		object3:setTitle("???")
		object3:noCancel()
		object3:addText("That noise... what could be causing all the ruckus at this time of day?")
		object3:addText("Yikes, it sounds like a lot of pirate mishap is happening inside. If I go in there, I'm sure I'd be causing a disturbance. It might call for a fight...")
		object3:addText("But it also sounds like someone is in trouble! It might be worth taking a stand to stop the commotion.")
		object3:addOptionType("Boss", function(object4)
			object4:setText("Breach Door")
			object4:onSelected(function()
				if flag or v12 then
					return
				end

				v12 = true
				flag2 = true
				disarmTrigger() -- equivalent call inferred; original call site unknown
				object2:FireServer("Breach")
				task.delay(4, function()
					if not v12 or flag then
						return
					end

					v12 = false
					abandonBreach(object2) -- equivalent call inferred; original call site unknown
				end)
			end)
		end)
		object3:addOptionType("Leave", function(object4)
			object4:setText("Walk Away")
		end)
	end):build()
end

local function startIntro()
	local v43 = v5

	if v43 and v14 and not (v11 or flag or v12 or v13) then
		local v44 = v6
		local character = Players.LocalPlayer.Character
		local humanoidRootPart

		if character then
			humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		end

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			humanoidRootPart = nil
		end

		local v45

		if v44 and humanoidRootPart then
			local v46 = humanoidRootPart.Position - v44.Position
			local v47 = v6
			local lookVector

			if v47 then
				local v48 = brawlerCentroid() -- equivalent call inferred; original call site unknown

				if v48 then
					local v49 = v48 - v47.Position
					lookVector = v47.LookVector
					local vector2 = Vector3.new(v49.X, 0, v49.Z)

					if vector2.Magnitude > 0.01 then
						lookVector = vector2.Unit
					end
				else
					local lookVector2 = v47.LookVector
					local vector2 = Vector3.new(lookVector2.X, 0, lookVector2.Z)

					if vector2.Magnitude > 0.01 then
						lookVector = vector2.Unit
					else
						lookVector = createVector(0, 0, 1)
					end
				end
			else
				lookVector = createVector(0, 0, 1)
			end

			if lookVector:Dot((Vector3.new(v46.X, 0, v46.Z))) > 0 then
				v45 = true
			else
				v45 = false
			end
		else
			v45 = false
		end

		if not v45 then
			local DialogueController = require(game.ReplicatedStorage.DialogueController)

			if DialogueController.Active then
				return
			end

			openDialogue(buildIntroDialogue(v43), function(p)
				v11 = p
			end)
		end
	end
end

local function requestTavernExit()
	local v43 = v5

	if not v43 or not v14 or v19 or flag or v12 or v13 or v20 then
		return
	end

	local DialogueController = require(game.ReplicatedStorage.DialogueController)

	if DialogueController.Active then
		return
	end

	v19 = true
	v43:FireServer("ExitTavern")
	task.spawn(function()
		local DISTANCE_EPSILON = 0.01
		local total = 0

		while true do
			local v44 = v6
			local character = Players.LocalPlayer.Character
			local humanoidRootPart

			if character then
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			end

			if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				humanoidRootPart = nil
			end

			local v45

			if v44 and humanoidRootPart then
				local v46 = humanoidRootPart.Position - v44.Position
				local v47 = v6
				local lookVector

				if v47 then
					local v48 = brawlerCentroid() -- equivalent call inferred; original call site unknown

					if v48 then
						local v49 = v48 - v47.Position
						lookVector = v47.LookVector
						local vector2 = Vector3.new(v49.X, 0, v49.Z)

						if vector2.Magnitude > DISTANCE_EPSILON then
							lookVector = vector2.Unit
						end
					else
						local lookVector2 = v47.LookVector
						local vector2 = Vector3.new(lookVector2.X, 0, lookVector2.Z)

						if vector2.Magnitude > DISTANCE_EPSILON then
							lookVector = vector2.Unit
						else
							lookVector = createVector(0, 0, 1)
						end
					end
				else
					lookVector = createVector(0, 0, 1)
				end

				if lookVector:Dot((Vector3.new(v46.X, 0, v46.Z))) > 0 then
					v45 = true
				else
					v45 = false
				end
			else
				v45 = false
			end

			if v45 and total < 3 then
				total += task.wait(0.1)
			else
				v19 = false

				if v5 ~= v43 or flag then
					break
				end

				local v46 = v6
				local character2 = Players.LocalPlayer.Character
				local humanoidRootPart2

				if character2 then
					humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")
				end

				if not (humanoidRootPart2 and humanoidRootPart2:IsA("BasePart")) then
					humanoidRootPart2 = nil
				end

				local v47

				if v46 and humanoidRootPart2 then
					local v48 = humanoidRootPart2.Position - v46.Position
					local v49 = v6
					local lookVector

					if v49 then
						local v50 = brawlerCentroid() -- equivalent call inferred; original call site unknown

						if v50 then
							local v51 = v50 - v49.Position
							lookVector = v49.LookVector
							local vector2 = Vector3.new(v51.X, 0, v51.Z)

							if vector2.Magnitude > DISTANCE_EPSILON then
								lookVector = vector2.Unit
							end
						else
							local lookVector2 = v49.LookVector
							local vector2 = Vector3.new(lookVector2.X, 0, lookVector2.Z)

							if vector2.Magnitude > DISTANCE_EPSILON then
								lookVector = vector2.Unit
							else
								lookVector = createVector(0, 0, 1)
							end
						end
					else
						lookVector = createVector(0, 0, 1)
					end

					v47 = lookVector:Dot((Vector3.new(v48.X, 0, v48.Z))) > 0
				else
					v47 = false
				end

				if not v47 then
					startIntro()
				end

				break
			end
		end
	end)
end

fn = function()
	if heartbeatConnection then
		return
	end

	local DialogueController = require(game.ReplicatedStorage.DialogueController)
	v18 = false
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v43 = v6
		local character = Players.LocalPlayer.Character
		local humanoidRootPart

		if character then
			humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		end

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			humanoidRootPart = nil
		end

		local magnitude

		if v43 and humanoidRootPart then
			magnitude = (humanoidRootPart.Position - v43.Position).Magnitude
		end

		if v11 then
			if not flag and not v12 and (magnitude == nil or magnitude > 26) then
				DialogueController.close()
			end

			v18 = true
		else
			local v44

			if magnitude == nil then
				v44 = false
			else
				v44 = magnitude <= 16
			end

			if v44 and not v18 then
				local v45 = v6
				local character2 = Players.LocalPlayer.Character
				local humanoidRootPart2

				if character2 then
					humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")
				end

				if not (humanoidRootPart2 and humanoidRootPart2:IsA("BasePart")) then
					humanoidRootPart2 = nil
				end

				local flag10

				if v45 and humanoidRootPart2 then
					local v46 = humanoidRootPart2.Position - v45.Position
					local v47 = v6
					local lookVector

					if v47 then
						local v48 = brawlerCentroid() -- equivalent call inferred; original call site unknown

						if v48 then
							local v49 = v48 - v47.Position
							lookVector = v47.LookVector
							local vector2 = Vector3.new(v49.X, 0, v49.Z)

							if vector2.Magnitude > 0.01 then
								lookVector = vector2.Unit
							end
						else
							local lookVector2 = v47.LookVector
							local vector2 = Vector3.new(lookVector2.X, 0, lookVector2.Z)

							if vector2.Magnitude > 0.01 then
								lookVector = vector2.Unit
							else
								lookVector = createVector(0, 0, 1)
							end
						end
					else
						lookVector = createVector(0, 0, 1)
					end

					if lookVector:Dot((Vector3.new(v46.X, 0, v46.Z))) > 0 then
						flag10 = true
					else
						flag10 = false
					end
				else
					flag10 = false
				end

				if flag10 then
					requestTavernExit()
				elseif not v13 then
					startIntro()
				end
			end

			v18 = v44
		end
	end)
end

local TavernBrawl = {}
TavernBrawl.DataName = script.Name
TavernBrawl.Repeatable = true

function TavernBrawl.OnLoad(p)
	v5 = p
	releaseMovementLock()
	flag = false
	v12 = false
	flag2 = false
	v13 = false
	v14 = false
	v15 = false
	v16 = nil
	v17 = 1
	v20 = false
	v21 = false
	flag4 = false
	flag5 = false
	flag6 = false
	v22 = (p.Completions or 0) > 0
	flag3 = false
	v19 = false
	flag9 = false
	v9 = nil
	v11 = false
	v23 = false
	v18 = false
	v24 = false
	refreshBartenderStar() -- equivalent call inferred; original call site unknown
end

function TavernBrawl.OnComplete(_, p, p2)
	disarmTrigger() -- equivalent call inferred; original call site unknown
	local v43 = v38
	v38 = nil

	if v43 then
		local flag10 = false
		pcall(function()
			if flag10 then
				v43:Destroy()
			else
				v43:FadeOut(v4.CINEMATIC_RETURN_TIME)
			end
		end)
	end

	local v44 = v39
	v39 = nil

	if v44 then
		local flag10 = false
		pcall(function()
			if flag10 then
				v44:Destroy()
			else
				v44:FadeOut(v4.CINEMATIC_RETURN_TIME)
			end
		end)
	end

	releaseMovementLock()
	flag9 = false
	stopVibration()
	stopBrawlNoise() -- equivalent call inferred; original call site unknown
	restoreDoors() -- equivalent call inferred; original call site unknown
	v11 = false
	flag = false
	v12 = false
	flag2 = false
	v13 = false
	v14 = false
	v15 = false
	v16 = nil
	v17 = 1
	v21 = false
	flag4 = false
	flag5 = false
	flag3 = false
	v19 = false

	if p then
		flag6 = true
		applyBartenderSavedState() -- equivalent call inferred; original call site unknown
		v41 = true
		count += 1

		if descendantAddedConnection then
			descendantAddedConnection:Disconnect()
			descendantAddedConnection = nil
		end

		local v45 = count
		task.spawn(function()
			local map = workspace:FindFirstChild("Map")
			local pirate

			if map then
				pirate = map:FindFirstChild("Pirate")
			end

			local v46

			if pirate then
				v46 = pirate:FindFirstChild(v4.BRAWL_FOLDER_NAME) or pirate:FindFirstChild(v4.BRAWL_FOLDER_NAME, true)
			else
				v46 = nil
			end

			local total = 0

			while not v46 and count == v45 and total < v4.BARRIER_FOLDER_TIMEOUT do
				total += task.wait(v4.BARRIER_FOLDER_RETRY)
				local map2 = workspace:FindFirstChild("Map")
				local pirate2

				if map2 then
					pirate2 = map2:FindFirstChild("Pirate")
				end

				if pirate2 then
					v46 = pirate2:FindFirstChild(v4.BRAWL_FOLDER_NAME) or pirate2:FindFirstChild(
						v4.BRAWL_FOLDER_NAME,
						true
					)
				else
					v46 = nil
				end
			end

			if not v46 or count ~= v45 then
				return
			end

			descendantAddedConnection = v46.DescendantAdded:Connect(function(descendant)
				if v41 then
					local v47 = v46
					local parent = descendant
					local flag10

					while true do
						if not parent or parent == v47 then
							flag10 = false
							break
						end

						if parent.Name == v4.BARRIER_DOOR_NAME then
							flag10 = true
							break
						else
							parent = parent.Parent
						end
					end

					if flag10 then
						applyBarrierInstance(descendant, true)
					end
				end
			end)
			applyBarrierDoors(v46, true)
		end)
	else
		v20 = false
		v23 = false
		removeBartender() -- equivalent call inferred; original call site unknown
	end

	if p or p2 then
		v5 = nil
	end

	refreshBartenderStar() -- equivalent call inferred; original call site unknown
end

TavernBrawl.RemoteEvents = {
	Setup = function(_, p, items, p2, value, p3, p4, p5)
		if typeof(p) ~= "CFrame" then
			p = nil
		end

		v6 = p
		table.clear(v7)

		if typeof(items) == "table" then
			for _, item in items do
				if typeof(item) == "CFrame" then
					table.insert(v7, item)
				end
			end
		end

		if typeof(value) ~= "number" or not v7[value] then
			value = nil
		end

		v8 = value

		if typeof(p2) ~= "CFrame" then
			p2 = nil
		end

		v10 = p2
		v13 = p3 == true
		v14 = p4 == true
		v20 = p5 == true
		restoreDoors() -- equivalent call inferred; original call site unknown
		setBarriersCleared(v22)
		spawnBartender()
		applyBartenderSavedState() -- equivalent call inferred; original call site unknown

		if v5 and v20 and not flag6 then
			if not v31 and v10 then
				v31 = true
				pcall(function()
					CompassTracker.createTracker("TavernBrawlBartender", {
						Target = function()
							local v43 = v10

							if v43 then
								return v43.Position
							end

							return createVector(0, 0, 0)
						end,
						AlertIconSettings = {
							Sprite = "Badge Star"
						},
						IconSettings = {
							Sprite = "Badge Star",
							ShowIsland = false
						},
						ViewportSettings = {
							UseIconAsBackground = false
						},
						ShowOffScreenAlert = true
					})
				end)
			end
		else
			stopBartenderStar() -- equivalent call inferred; original call site unknown
		end

		task.spawn(function()
			pcall(function()
				Effect.preload(v2.DUST_EFFECT)
			end)
		end)

		if v6 then
			fn()
		end
	end,
	BarriersCleared = function(_)
		v41 = true
		count += 1

		if descendantAddedConnection then
			descendantAddedConnection:Disconnect()
			descendantAddedConnection = nil
		end

		local v43 = count
		task.spawn(function()
			local map = workspace:FindFirstChild("Map")
			local pirate

			if map then
				pirate = map:FindFirstChild("Pirate")
			end

			local v44

			if pirate then
				v44 = pirate:FindFirstChild(v4.BRAWL_FOLDER_NAME) or pirate:FindFirstChild(v4.BRAWL_FOLDER_NAME, true)
			else
				v44 = nil
			end

			local total = 0

			while not v44 and count == v43 and total < v4.BARRIER_FOLDER_TIMEOUT do
				total += task.wait(v4.BARRIER_FOLDER_RETRY)
				local map2 = workspace:FindFirstChild("Map")
				local pirate2

				if map2 then
					pirate2 = map2:FindFirstChild("Pirate")
				end

				if pirate2 then
					v44 = pirate2:FindFirstChild(v4.BRAWL_FOLDER_NAME) or pirate2:FindFirstChild(
						v4.BRAWL_FOLDER_NAME,
						true
					)
				else
					v44 = nil
				end
			end

			if not v44 or count ~= v43 then
				return
			end

			descendantAddedConnection = v44.DescendantAdded:Connect(function(descendant)
				if v41 then
					local v45 = v44
					local parent = descendant
					local flag10

					while true do
						if not parent or parent == v45 then
							flag10 = false
							break
						end

						if parent.Name == v4.BARRIER_DOOR_NAME then
							flag10 = true
							break
						else
							parent = parent.Parent
						end
					end

					if flag10 then
						applyBarrierInstance(descendant, true)
					end
				end
			end)
			applyBarrierDoors(v44, true)
		end)
	end,
	ResetProgress = function(p)
		v5 = p
		v22 = (p.Completions or 0) > 0
		resetProgress() -- equivalent call inferred; original call site unknown
		restoreDoors() -- equivalent call inferred; original call site unknown

		if v5 and v20 and not flag6 then
			if not v31 and v10 then
				v31 = true
				pcall(function()
					CompassTracker.createTracker("TavernBrawlBartender", {
						Target = function()
							local v43 = v10

							if v43 then
								return v43.Position
							end

							return createVector(0, 0, 0)
						end,
						AlertIconSettings = {
							Sprite = "Badge Star"
						},
						IconSettings = {
							Sprite = "Badge Star",
							ShowIsland = false
						},
						ViewportSettings = {
							UseIconAsBackground = false
						},
						ShowOffScreenAlert = true
					})
				end)
			end
		else
			stopBartenderStar() -- equivalent call inferred; original call site unknown
		end

		v18 = false
	end,
	SetAvailable = function(_, p)
		local v43 = v14
		v14 = p == true

		if v14 then
			if not v43 then
				v18 = false
			end
		elseif v11 and not (flag or v12) then
			local DialogueController = require(game.ReplicatedStorage.DialogueController)
			DialogueController.close()
		end
	end,
	BrawlActive = function(_, p)
		v13 = p == true
		v15 = false
		v16 = nil

		if not v13 then
			restoreDoors() -- equivalent call inferred; original call site unknown
		end
	end,
	DoorsBurst = function(_, p, p2, p3)
		if typeof(p) ~= "CFrame" then
			p = nil
		end

		if typeof(p2) ~= "Vector3" then
			p2 = nil
		end

		burstDoors(p, p2, p3 == true)
	end,
	BreachDenied = function(p)
		if not v12 or flag then
			return
		end

		v12 = false
		abandonBreach(p) -- equivalent call inferred; original call site unknown
	end,
	BreachStart = function(p, value, p2)
		v12 = false

		if flag then
			return
		end

		flag = true
		v13 = true
		flag2 = true
		v17 = typeof(value) ~= "number" and 1 or value

		if typeof(p2) ~= "Vector3" then
			p2 = nil
		end

		v9 = p2
		disarmTrigger() -- equivalent call inferred; original call site unknown
		local DialogueController = require(game.ReplicatedStorage.DialogueController)

		if DialogueController.Active then
			DialogueController.close()
		end

		task.spawn(runBreachSequence, p)
	end,
	FightStart = function(_)
		if flag9 then
			return
		end

		flag9 = true
		task.spawn(runFightTransition)
	end,
	GangUpStart = function(_)
		if not v11 then
			return
		end

		local DialogueController = require(game.ReplicatedStorage.DialogueController)
		DialogueController.close()
	end,
	GangUp = function(_, items)
		local v43 = {}

		if typeof(items) == "table" then
			for _, item in items do
				if typeof(item) == "Vector3" then
					table.insert(v43, item)
				end
			end
		end

		task.spawn(startGangUp, v43)
	end,
	BrawlersDefeated = function(_)
		v20 = true
		v13 = false
		releaseMovementLock()
		applyBartenderSavedState() -- equivalent call inferred; original call site unknown
		refreshBartenderStar() -- equivalent call inferred; original call site unknown
	end
}
return TavernBrawl