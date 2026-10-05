local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local StarterPlayer = game:GetService("StarterPlayer")
local StaffTreadmill = require(ReplicatedStorage._FRAMEWORK.Features.StaffTreadmill)
local PersonalTreadmill = require(StarterPlayer.StarterPlayerScripts.PersonalTreadmill)
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local UpgradeMultipliers = require(ReplicatedStorage._FRAMEWORK.Libraries.UpgradeMultipliers)
local NotificationSystem = require(ReplicatedStorage:WaitForChild("NotificationSystem"))
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))

-- equivalent calls inferred from this helper; original call sites unknown
local function showTreadmillGain(data, trail: number, TREADMILL_SPEED_MULT: number)
	NotificationSystem:ShowPlusOne(
		data.StepBonus,
		data.SpeedBoostMultiplier,
		trail,
		TREADMILL_SPEED_MULT,
		data.BonusXPMultiplier or 1
	)
end

local localPlayer = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local updateSpeed = remotes:WaitForChild("UpdateSpeed")
local promptGoldTreadmill = remotes:WaitForChild("PromptGoldTreadmill")
local promptDiamondTreadmill = remotes:WaitForChild("PromptDiamondTreadmill")
local promptCandyTreadmill = remotes:WaitForChild("PromptCandyTreadmill")
local promptAdminTreadmill = remotes:WaitForChild("PromptAdminTreadmill")
local treadmillSignal = remotes:WaitForChild("TreadmillSignal")
local v = false
local v2 = nil
local v3 = 0
local v4 = nil
local Raycast = require(ReplicatedStorage:WaitForChild("Treadmill"):WaitForChild("Raycast"))
local treadmillFilter = Raycast.getTreadmillFilter()

local function checkFloor()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return nil
	end

	local raycastResult = workspace:Raycast(humanoidRootPart.Position, createVector(0, -7, 0), treadmillFilter)

	if not (raycastResult and raycastResult.Instance) then
		return nil
	end

	local instance = raycastResult.Instance

	if CollectionService:HasTag(instance, "AdminTreadmill") then
		return "Admin"
	end

	if CollectionService:HasTag(instance, "AdminAbuseTreadmill") then
		return "AdminAbuse"
	end

	if CollectionService:HasTag(instance, "CandyTreadmill") then
		return "Candy"
	end

	if CollectionService:HasTag(instance, "DiamondTreadmill") then
		return "Diamond"
	end

	if CollectionService:HasTag(instance, "GoldTreadmill") then
		return "Gold"
	end

	if CollectionService:HasTag(instance, "AATreadmillX3ll3n") then
		return "AATreadmillX3ll3n"
	end

	if CollectionService:HasTag(instance, "HourlyTreadmill") then
		return "Hourly"
	end

	if CollectionService:HasTag(instance, "DailyTreadmill") then
		return "Daily"
	end

	if CollectionService:HasTag(instance, "Treadmill") then
		return "Normal"
	end

	if CollectionService:HasTag(instance, StaffTreadmill.TREADMILL_TAG) then
		return StaffTreadmill.TREADMILL_TAG
	end

	if CollectionService:HasTag(instance, "VoidTreadmillAAChichine") then
		return "VoidTreadmillAAChichine"
	end

	if CollectionService:HasTag(instance, "AdminAbuse_IndependanceTreadmill") then
		return "AdminAbuse_IndependanceTreadmill"
	end

	if CollectionService:HasTag(instance, "AdminAbuse_July14thTreadmill") then
		return "AdminAbuse_July14thTreadmill"
	end

	if CollectionService:HasTag(instance, "AdminAbuse_WorldCupTreadmill") then
		return "AdminAbuse_WorldCupTreadmill"
	end

	if CollectionService:HasTag(instance, "BBNOConcertTreadmill") then
		return "BBNOConcertTreadmill"
	end

	if CollectionService:HasTag(instance, "SummerTreadmill") then
		return "SummerTreadmill"
	end

	if CollectionService:HasTag(instance, "LastSummerTreadmill") then
		return "LastSummerTreadmill"
	end

	if CollectionService:HasTag(instance, "TreadmillTheHunt20") then
		return "TreadmillTheHunt20"
	end

	return nil
end

localPlayer.CharacterAdded:Connect(function()
	v4 = nil
	v = false
	v2 = nil
end)
RunService.Heartbeat:Connect(function()
	if PersonalTreadmill:isActive() then
		return
	end

	local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		return
	end

	local v5 = checkFloor()
	local v6 = v5 ~= nil

	if v6 ~= v then
		v = v6
		v2 = v5
		treadmillSignal:FireServer(v)
	end

	if v then
		local now = os.clock()
		local v7 = ClientState:Get()
		local XP_TIME_BASED = Config.XP_TIME_BASED
		local v8 = math.clamp(
			(humanoid.WalkSpeed - XP_TIME_BASED.MIN_SPEED) / (XP_TIME_BASED.MAX_SPEED - XP_TIME_BASED.MIN_SPEED),
			0,
			1
		)

		if XP_TIME_BASED.MAX_COOLDOWN - v8 * (XP_TIME_BASED.MAX_COOLDOWN - XP_TIME_BASED.MIN_COOLDOWN) <= now - v3 then
			local equippedTrail = v7.EquippedTrail or "None"
			local trail = UpgradeMultipliers.trail(equippedTrail)

			if v2 == "Admin" then
				if v7.AdminTreadmillActive then
					updateSpeed:FireServer("AdminTreadmill")
					showTreadmillGain(v7, trail, 100) -- equivalent call inferred; original call site unknown
				else
					promptAdminTreadmill:FireServer()
					v = false
				end
			elseif v2 == "AdminAbuse" then
				updateSpeed:FireServer("AdminAbuseTreadmill")
				showTreadmillGain(v7, trail, 120) -- equivalent call inferred; original call site unknown
			elseif v2 == "Candy" then
				if v7.CandyTreadmillActive then
					updateSpeed:FireServer("CandyTreadmill")
					showTreadmillGain(v7, trail, 25) -- equivalent call inferred; original call site unknown
				else
					promptCandyTreadmill:FireServer()
					v = false
				end
			elseif v2 == "Diamond" then
				if v7.DiamondTreadmillActive then
					updateSpeed:FireServer("DiamondTreadmill")
					showTreadmillGain(v7, trail, 9) -- equivalent call inferred; original call site unknown
				else
					promptDiamondTreadmill:FireServer()
					v = false
				end
			elseif v2 == "Gold" then
				if v7.GoldTreadmillActive then
					updateSpeed:FireServer("GoldTreadmill")
					showTreadmillGain(v7, trail, 3) -- equivalent call inferred; original call site unknown
				else
					promptGoldTreadmill:FireServer()
					v = false
				end
			elseif v2 == "AATreadmillX3ll3n" then
				local Workspace = game:GetService("Workspace")

				if Workspace:FindFirstChild("AAX3LL3N_Live") then
					updateSpeed:FireServer("AATreadmillX3ll3n")
					showTreadmillGain(v7, trail, 150) -- equivalent call inferred; original call site unknown
				else
					v = false
				end
			elseif v2 == "Hourly" then
				if workspace:FindFirstChild("HourlyTreadmill_Active") then
					updateSpeed:FireServer("HourlyTreadmill")
					showTreadmillGain(v7, trail, 5) -- equivalent call inferred; original call site unknown
				else
					v = false
				end
			elseif v2 == "Daily" then
				if workspace:FindFirstChild("DailyTreadmill_Active") then
					updateSpeed:FireServer("DailyTreadmill")
					showTreadmillGain(v7, trail, 25) -- equivalent call inferred; original call site unknown
				else
					v = false
				end
			elseif v2 == StaffTreadmill.TREADMILL_TAG then
				updateSpeed:FireServer(StaffTreadmill.TREADMILL_TAG)
				showTreadmillGain(v7, trail, StaffTreadmill.TREADMILL_SPEED_MULT) -- equivalent call inferred; original call site unknown
			elseif v2 == "VoidTreadmillAAChichine" then
				updateSpeed:FireServer("VoidTreadmillAAChichine")
				showTreadmillGain(v7, trail, 150) -- equivalent call inferred; original call site unknown
			elseif v2 == "AdminAbuse_IndependanceTreadmill" then
				updateSpeed:FireServer("AdminAbuse_IndependanceTreadmill")
				showTreadmillGain(v7, trail, 150) -- equivalent call inferred; original call site unknown
			elseif v2 == "AdminAbuse_July14thTreadmill" then
				updateSpeed:FireServer("AdminAbuse_July14thTreadmill")
				showTreadmillGain(v7, trail, 150) -- equivalent call inferred; original call site unknown
			elseif v2 == "AdminAbuse_WorldCupTreadmill" then
				updateSpeed:FireServer("AdminAbuse_WorldCupTreadmill")
				showTreadmillGain(v7, trail, 150) -- equivalent call inferred; original call site unknown
			elseif v2 == "BBNOConcertTreadmill" then
				updateSpeed:FireServer("BBNOConcertTreadmill")
				showTreadmillGain(v7, trail, 150) -- equivalent call inferred; original call site unknown
			elseif v2 == "SummerTreadmill" then
				updateSpeed:FireServer("SummerTreadmill")
				showTreadmillGain(v7, trail, 150) -- equivalent call inferred; original call site unknown
			elseif v2 == "LastSummerTreadmill" then
				updateSpeed:FireServer("LastSummerTreadmill")
				showTreadmillGain(v7, trail, 150) -- equivalent call inferred; original call site unknown
			elseif v2 == "TreadmillTheHunt20" then
				updateSpeed:FireServer("TreadmillTheHunt20")
				showTreadmillGain(v7, trail, 150) -- equivalent call inferred; original call site unknown
			else
				updateSpeed:FireServer("Treadmill")
				showTreadmillGain(v7, trail, 1) -- equivalent call inferred; original call site unknown
			end

			v3 = now
		end
	end
end)