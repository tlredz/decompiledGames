local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local MinigameSettings = require(ReplicatedStorage.CAM.Global.MinigameSettings)
local ServerClientPortal = require(ReplicatedStorage.CAM.Global.ServerClientPortal)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local localPlayer = Players.LocalPlayer
local notification = ReplicatedStorage.Communication.CnC.Notifications.Notification
local v = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function equipCooldownLeft()
	return (math.max(v - os.clock(), 0))
end

local flag = false
local v2 = false
local v3 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function Dialogues()
	return require(ReplicatedStorage.CAM.Client.Modules.GamePlay.Dialogue)
end

local function setBoardOpen(flag2: boolean)
	if flag2 and MinigameSettings.Get("NoCrowBoard") == true or flag2 == v3 then
		return
	end

	v3 = flag2

	if flag2 then
		local dialogues = Dialogues() -- equivalent call inferred; original call site unknown
		dialogues.OpenDialogue:Fire("CrowTasks")
	else
		local dialogues = Dialogues() -- equivalent call inferred; original call site unknown
		dialogues.CurrentDialogue.Cancel:Fire()
	end
end

local function crowModelName()
	return (`{localPlayer.Name}'s Crow Model`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startFollowing()
	if flag then
		return
	end

	flag = true
	local v4 = nil
	local v5 = nil
	local v6 = 0
	local v7 = false
	RunService.PostSimulation:Connect(function(dt: number)
		local debree = workspace:FindFirstChild("Debree")
		local child = debree and debree:FindFirstChild((`{localPlayer.Name}'s Crow Model`))

		if child == nil then
			v7 = false
			v4 = nil
			v5 = nil

			if v3 == false then
				return
			end

			v3 = false
			local dialogues = Dialogues() -- equivalent call inferred; original call site unknown
			dialogues.CurrentDialogue.Cancel:Fire()
		else
			if child ~= v5 then
				v5 = child
				v4 = nil
			end

			local root = child:FindFirstChild("Root")

			if root == nil then
				return
			end

			local character = localPlayer.Character
			local upperTorso = character and character:FindFirstChild("UpperTorso")
			local crowShoulderAttachment = upperTorso and upperTorso:FindFirstChild("Crow-Shoulder-Attachment")

			if crowShoulderAttachment == nil then
				return
			end

			local mainAt = root.MainAt
			local crowVelocity = root.CrowVelocity
			local crowOrientation = root.CrowOrientation
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local v8 = crowShoulderAttachment.WorldPosition - mainAt.WorldPosition
			local magnitude = v8.Magnitude
			local v9

			if v7 then
				v9 = magnitude <= 3
			else
				v9 = magnitude <= 1.5
			end

			v7 = v9
			local v10 = v8 * 2.0833333333333335

			if v10.Magnitude > 25 then
				v10 = v10.Unit * 25
			end

			if not v7 then
				v10 = v8.Unit * math.max(v10.Magnitude, 8)
			end

			local v11 = 1 - math.exp(dt * -15)
			crowVelocity.VectorVelocity = crowVelocity.VectorVelocity:Lerp(v10, v11)

			if v7 then
				if humanoidRootPart then
					crowOrientation.CFrame = humanoidRootPart.CFrame
				end
			else
				local position = root.Position
				local v12 = 1 - math.exp(dt * -6)
				crowOrientation.CFrame = crowOrientation.CFrame:Lerp(CFrame.lookAt(position, position + v8), v12)
			end

			local v12 = v7 and "idle" or "fly"
			local v13 = v12 ~= v4
			local now = os.clock()

			if v13 or now - v6 >= 2 then
				ServerClientPortal.Server("CrowAnim", v12)
				v4 = v12
				v6 = now
			end

			if v13 then
				setBoardOpen(v7 and v2)
			end
		end
	end)
end

local Crow = {}

function Crow.check(_, _: string)
	if not Checker.check(localPlayer) then
		return false
	end

	local data = Utility.GetData(localPlayer)
	local race = data and data:FindFirstChild("Race")
	local value = race and race.Value

	if value ~= "Slayer" and value ~= "Hybrid" then
		notification:Fire("Notify", {
			Text = "Only Slayers can call a Kasugai crow",
			Type = "Denied"
		})
		return false
	end

	local v4 = equipCooldownLeft() -- equivalent call inferred; original call site unknown

	if v4 > 0 then
		notification:Fire("Notify", {
			Text = `Wait {math.ceil(v4)} seconds`,
			Type = "Denied"
		})
		return false
	else
		return true
	end
end

function Crow.Equipped(_, _: string)
	v2 = true
	startFollowing() -- equivalent call inferred; original call site unknown
end

function Crow.UnEquipped(_, _: string)
	v2 = false

	if v3 ~= false then
		v3 = false
		local dialogues = Dialogues() -- equivalent call inferred; original call site unknown
		dialogues.CurrentDialogue.Cancel:Fire()
	end

	v = os.clock() + gameSettings.crowEquipCooldown
end

function Crow.MouseDown(_, _: string) end

function Crow.MouseUp(_, _: string) end

return Crow