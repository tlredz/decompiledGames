local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages:WaitForChild("Net"))
local PlayerData = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("PlayerData"))
local localPlayer = Players.LocalPlayer

if PlayerData.client.hasSeenSeatTutorial() then
	return
end

local v = ReplicatedStorage:WaitForChild("美术素材"):WaitForChild("杂项"):WaitForChild("新手引导射线")
local firstChild = Workspace:FindFirstChild("双人对战", true)

if not firstChild then
	return
end

local v2 = { "座位1", "座位2" }
local v3 = {}
local flag = false
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil
local characterAddedConnection = nil
local onClientEventConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyBeam()
	if v4 then
		v4:Destroy()
	end

	v4 = nil
	v5 = nil
	v6 = nil
	v7 = nil
end

local function ensureBeam(humanoidRootPart)
	if v4 then
		return
	end

	local clone = v:Clone()
	local attachment = clone:FindFirstChild("起点")
	local attachment2 = clone:FindFirstChild("终点")

	if attachment and attachment:IsA("Attachment") and attachment2 and attachment2:IsA("Attachment") then
		v5 = attachment
		v6 = attachment2
		v5.Parent = humanoidRootPart
		v5.CFrame = CFrame.new()
		clone.Enabled = false
		clone.Parent = humanoidRootPart
		v4 = clone
		v7 = nil
	else
		warn("[NewbieSeatGuide] 引导射线模板缺少起点/终点 Attachment")
		clone:Destroy()
	end
end

local function setTarget(parent)
	if not (v4 and v6 and parent ~= v7) then
		return
	end

	v7 = parent
	local v8 = v4
	local v9 = v6

	if not parent then
		v8.Enabled = false
		return
	end

	v9.Parent = parent
	v9.CFrame = CFrame.new()
	v8.Enabled = true
end

local function applySnapshot(p)
	if type(p) ~= "table" then
		return
	end

	if p.table then
		local v8 = false

		for k, v10 in v3 do
			if v10.table ~= p.table then
				continue
			end

			v3[k] = p
			v8 = true
			break
		end

		if not v8 then
			table.insert(v3, p)
		end
	else
		local tables = p.tables

		if type(tables) == "table" then
			v3 = tables
		end
	end
end

local function isLocalPlayerSeatedAnywhere()
	for _, v8 in v3 do
		local seats = v8.seats

		if not seats then
			continue
		end

		for _, seat in seats do
			if seat and seat.userId == localPlayer.UserId then
				return true
			end
		end
	end

	return false
end

local function countOccupied(items)
	local count = 0

	if items then
		for _, item in items do
			if item then
				count += 1
			end
		end
	end

	return count
end

local function findEmptySeatInteractPoint(table2, seats)
	for _, childName in v2 do
		if seats and seats[childName] then
			continue
		end

		local child = table2:FindFirstChild(childName)
		local part = child and child:FindFirstChild("交互点")

		if part and part:IsA("BasePart") then
			return part
		end
	end

	return nil
end

local function betterCandidate(p, distance: number, point)
	if p and not (distance < p.distance) then
		return p
	end

	return {
		distance = distance,
		point = point
	}
end

local function pickTargetInteractPoint(position: Vector3)
	local v8 = nil
	local v9 = nil

	for _, v10 in v3 do
		local table2 = v10.table

		if not (table2 and table2:IsA("Model") and table2:IsDescendantOf(firstChild)) then
			continue
		end

		local seats = v10.seats
		local emptySeatInteractPoint = findEmptySeatInteractPoint(table2, seats)

		if not emptySeatInteractPoint then
			continue
		end

		local magnitude = (emptySeatInteractPoint.Position - position).Magnitude
		local count = 0

		if seats then
			for _, seat in seats do
				if seat then
					count += 1
				end
			end
		end

		v8 = count == 1 and (not v8 or magnitude < v8.distance) and {
			distance = magnitude,
			point = emptySeatInteractPoint
		} or v8

		if not v9 or magnitude < v9.distance then
			v9 = {
				distance = magnitude,
				point = emptySeatInteractPoint
			}
		end
	end

	if v8 then
		return v8.point
	end

	if v9 then
		return v9.point
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disconnectAll()
	if characterAddedConnection then
		characterAddedConnection:Disconnect()
		characterAddedConnection = nil
	end

	if onClientEventConnection then
		onClientEventConnection:Disconnect()
		onClientEventConnection = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function finishTutorial()
	if flag then
		return
	end

	flag = true
	destroyBeam() -- equivalent call inferred; original call site unknown
	disconnectAll() -- equivalent call inferred; original call site unknown
end

local function reevaluate()
	if flag then
		return
	end

	if isLocalPlayerSeatedAnywhere() then
		finishTutorial() -- equivalent call inferred; original call site unknown
	else
		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			return
		end

		ensureBeam(humanoidRootPart)
		local parent = pickTargetInteractPoint(humanoidRootPart.Position)

		if v4 then
			if not (v6 and parent ~= v7) then
				return
			end

			v7 = parent
			local v9 = v4
			local v10 = v6

			if parent then
				v10.Parent = parent
				v10.CFrame = CFrame.new()
				v9.Enabled = true
			else
				v9.Enabled = false
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onCharacterAdded(character)
	destroyBeam() -- equivalent call inferred; original call site unknown

	if flag then
		return
	end

	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		reevaluate()
	end
end

characterAddedConnection = localPlayer.CharacterAdded:Connect(onCharacterAdded)
onClientEventConnection = Net:RemoteEvent("DuelTableState").OnClientEvent:Connect(function(p)
	applySnapshot(p)
	reevaluate()
end)
Net:RemoteEvent("DuelTableStateRequest"):FireServer()

if localPlayer.Character then
	onCharacterAdded(localPlayer.Character) -- equivalent call inferred; original call site unknown
end

task.spawn(function()
	while not flag do
		reevaluate()
		task.wait(1)
	end
end)