local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

if not RunService:IsStudio() then
	return
end

local rightBracket = Enum.KeyCode.RightBracket
local leftBracket = Enum.KeyCode.LeftBracket
local backSlash = Enum.KeyCode.BackSlash
local P = Enum.KeyCode.P
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetRigService = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PetRigService"))

local function GetMount()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local petMountJoint = humanoidRootPart and humanoidRootPart:FindFirstChild("PetMountJoint")
	local part1 = petMountJoint and petMountJoint.Part1
	local parent = part1 and part1.Parent

	if humanoid and parent and part1 then
		return humanoid, parent, part1, petMountJoint, humanoidRootPart
	end

	return nil
end

local Y = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function RideOffsetOf(instance)
	local data = instance:FindFirstChild("Data")
	local positionAdjust = data and data:FindFirstChild("PositionAdjust")
	return PetRigService.RideOffset(instance, positionAdjust and positionAdjust.Value or createVector(0, -1.4, 0))
end

local function ApplyPositionAdjust()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local petMountJoint = humanoidRootPart and humanoidRootPart:FindFirstChild("PetMountJoint")
	local part1 = petMountJoint and petMountJoint.Part1
	local parent = part1 and part1.Parent

	if not (humanoid and parent and part1) then
		humanoid = nil
		petMountJoint = nil
		parent = nil
	end

	if not (humanoid and petMountJoint) then
		return
	end

	local rideOffset = RideOffsetOf(parent) -- equivalent call inferred; original call site unknown
	petMountJoint.C0 = CFrame.new(rideOffset) * petMountJoint.C0.Rotation

	if Y then
		humanoid.HipHeight -= rideOffset.Y - Y
	end

	Y = rideOffset.Y
end

local function BoneSeatToPaws(folder, p)
	local pivot = folder:GetPivot()
	local Y2 = pivot:PointToObjectSpace(p.Position).Y
	local v = nil
	local v2 = nil

	for _, bone in folder:GetDescendants() do
		if not bone:IsA("Bone") then
			continue
		end

		local Y3 = pivot:PointToObjectSpace(bone.WorldCFrame.Position).Y

		if not v or Y3 < v then
			v = Y3
		end

		if bone.Parent:IsA("Bone") and (not v2 or Y3 < v2) then
			v2 = Y3
		end
	end

	local v3 = v2 or v
	return v3 and Y2 - v3 or nil
end

local total = 0
local v = nil

local function Report(_, parent, part1)
	local boneSeatToPaws = BoneSeatToPaws(parent, part1)

	if not boneSeatToPaws or boneSeatToPaws <= 0 then
		warn("[RideCalibrate] " .. parent.Name .. ": no bones to measure against")
		return
	end

	local data = parent:FindFirstChild("Data")
	local rideGroundOffset = data and data:FindFirstChild("RideGroundOffset")
	local value = tonumber(rideGroundOffset and rideGroundOffset.Value) or 0
	local v3 = math.max((value ~= value or math.abs(value) == 1e999) and 0 or value, -0.95)
	local v4 = boneSeatToPaws * 1.06
	local v5 = v3 + total / v4
	local positionAdjust = data and data:FindFirstChild("PositionAdjust")
	local orientationAdjust = data and (data:FindFirstChild("OrientationAdjust") or data:FindFirstChild("OrientaionAdjust"))
	print(string.format([[
[RideCalibrate] %s
    RideGroundOffset  %.3f -> %.3f   (nudged %+.3f studs, 1 press = %.4f)
    PositionAdjust    %s
    OrientationAdjust %s]], parent.Name, v3, v5, total, 0.02 / v4, positionAdjust and tostring(positionAdjust.Value) or "(unset)", orientationAdjust and tostring(orientationAdjust.Value) or "(unset)"))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Nudge(p)
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local petMountJoint = humanoidRootPart and humanoidRootPart:FindFirstChild("PetMountJoint")
	local part1 = petMountJoint and petMountJoint.Part1
	local parent = part1 and part1.Parent

	if not (humanoid and parent and part1) then
		humanoid = nil
		parent = nil
		part1 = nil
	end

	if not humanoid then
		warn("[RideCalibrate] not riding anything")
		return
	end

	if parent ~= v then
		v = parent
		total = 0
	end

	humanoid.HipHeight += p
	total += p
	Report(humanoid, parent, part1)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or input.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end

	if input.KeyCode == rightBracket then
		Nudge(0.02) -- equivalent call inferred; original call site unknown
	elseif input.KeyCode == leftBracket then
		Nudge(-0.02) -- equivalent call inferred; original call site unknown
	elseif input.KeyCode == backSlash then
		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local petMountJoint = humanoidRootPart and humanoidRootPart:FindFirstChild("PetMountJoint")
		local part1 = petMountJoint and petMountJoint.Part1
		local parent = part1 and part1.Parent

		if not (humanoid and parent and part1) then
			humanoid = nil
			parent = nil
			part1 = nil
		end

		if humanoid then
			Report(humanoid, parent, part1)
		else
			warn("[RideCalibrate] not riding anything")
		end
	elseif input.KeyCode == P then
		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local petMountJoint = humanoidRootPart and humanoidRootPart:FindFirstChild("PetMountJoint")
		local part1 = petMountJoint and petMountJoint.Part1
		local parent = part1 and part1.Parent

		if not (humanoid and parent and part1) then
			humanoid = nil
			parent = nil
			part1 = nil
		end

		if humanoid then
			humanoid.HipHeight -= total
			total = 0
			Report(humanoid, parent, part1)
		end
	end
end)
print("[RideCalibrate] Studio only. Mount a pet, then  ]  raise   [  lower   \\  report   P  reset")
print("[RideCalibrate] PositionAdjust and OrientationAdjust apply live - just type into them while riding.")
local v2 = nil
local connections = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function UnwatchRig()
	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)
	v2 = nil
	Y = nil
end

local function WatchRig(parent)
	if parent == v2 then
		return
	end

	UnwatchRig() -- equivalent call inferred; original call site unknown
	v2 = parent
	local data = parent:FindFirstChild("Data")

	if not data then
		return
	end

	local positionAdjust = data:FindFirstChild("PositionAdjust")
	Y = (RideOffsetOf(parent)).Y

	if positionAdjust then
		table.insert(connections, positionAdjust.Changed:Connect(function()
			ApplyPositionAdjust()
			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local petMountJoint = humanoidRootPart and humanoidRootPart:FindFirstChild("PetMountJoint")
			local part1 = petMountJoint and petMountJoint.Part1
			local parent2 = part1 and part1.Parent

			if not (humanoid and parent2 and part1) then
				humanoid = nil
				parent2 = nil
				part1 = nil
			end

			if humanoid and parent2 == parent then
				Report(humanoid, parent2, part1)
			end
		end))
	end

	local orientationAdjust = data:FindFirstChild("OrientationAdjust") or data:FindFirstChild("OrientaionAdjust")

	if orientationAdjust then
		table.insert(connections, orientationAdjust.Changed:Connect(function()
			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local petMountJoint = humanoidRootPart and humanoidRootPart:FindFirstChild("PetMountJoint")
			local part1 = petMountJoint and petMountJoint.Part1
			local parent2 = part1 and part1.Parent

			if not (humanoid and parent2 and part1) then
				humanoid = nil
				parent2 = nil
				part1 = nil
			end

			if humanoid and parent2 == parent then
				Report(humanoid, parent2, part1)
			end
		end))
	end
end

RunService.Heartbeat:Connect(function()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local petMountJoint = humanoidRootPart and humanoidRootPart:FindFirstChild("PetMountJoint")
	local part1 = petMountJoint and petMountJoint.Part1
	local parent = part1 and part1.Parent

	if not (humanoid and parent and part1) then
		parent = nil
	end

	if parent then
		WatchRig(parent)
	elseif v2 then
		UnwatchRig() -- equivalent call inferred; original call site unknown
	end
end)