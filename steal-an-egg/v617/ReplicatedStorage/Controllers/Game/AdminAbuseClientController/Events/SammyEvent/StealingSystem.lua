local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CarryRunBackEffects = require(script.Parent.Parent.Parent.Parent.AreaEggsController.CarryRunBackEffects)
local Player = require(ReplicatedStorage.Shared.Player)
require(ReplicatedStorage.Packages.Trove)
local TutorialBeam = require(ReplicatedStorage.Client.WorldFX.TutorialBeam)
local localPlayer = Players.LocalPlayer
local v = nil
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function raidMap()
	return Workspace:FindFirstChild("SammyEventMap")
end

local function returnPoint()
	local v2 = raidMap() -- equivalent call inferred; original call site unknown
	local laserGun

	if v2 then
		laserGun = v2:FindFirstChild("LaserGun")
	end

	local returnZone

	if laserGun then
		returnZone = laserGun:FindFirstChild("ReturnZone")
	end

	if returnZone == nil or not returnZone:IsA("BasePart") then
		return nil
	end

	return returnZone
end

local function nearestSteal()
	local v2 = raidMap() -- equivalent call inferred; original call site unknown
	local part = Player.FindRootPart(localPlayer)

	if v2 == nil or part == nil or not part:IsA("BasePart") then
		return nil
	end

	local v3 = 1e999
	local v4 = nil

	for _, model in v2:GetChildren() do
		if not model:IsA("Model") then
			continue
		end

		local stealBrainrot = model:FindFirstChild("StealBrainrot", true)
		local parent

		if stealBrainrot ~= nil then
			parent = stealBrainrot.Parent
		end

		if not (parent ~= nil and parent:IsA("BasePart")) then
			continue
		end

		local magnitude = (parent.Position - part.Position).Magnitude

		if not (magnitude < v3) then
			continue
		end

		v4 = parent
		v3 = magnitude
	end

	return v4
end

local function cageTarget()
	local v2 = raidMap() -- equivalent call inferred; original call site unknown
	local cagedBen

	if v2 then
		cagedBen = v2:FindFirstChild("CagedBen")
	end

	local hitbox

	if cagedBen then
		hitbox = cagedBen:FindFirstChild("Hitbox")
	end

	if hitbox == nil or not hitbox:IsA("BasePart") then
		return nil
	end

	return hitbox
end

-- equivalent calls inferred from this helper; original call sites unknown
local function dropBeam()
	local v2 = v

	if v2 ~= nil then
		v = nil
		TutorialBeam.Destroy(v2)
	end
end

local function refresh()
	local hitbox

	if localPlayer:GetAttribute("SammyCarrying") == nil then
		hitbox = nearestSteal()

		if not hitbox then
			local v2 = raidMap() -- equivalent call inferred; original call site unknown
			local cagedBen

			if v2 then
				cagedBen = v2:FindFirstChild("CagedBen")
			end

			if cagedBen then
				hitbox = cagedBen:FindFirstChild("Hitbox")
			else
				hitbox = nil
			end

			if hitbox == nil or not hitbox:IsA("BasePart") then
				hitbox = nil
			end
		end
	else
		local v2 = raidMap() -- equivalent call inferred; original call site unknown
		local laserGun

		if v2 then
			laserGun = v2:FindFirstChild("LaserGun")
		end

		if laserGun then
			hitbox = laserGun:FindFirstChild("ReturnZone")
		end

		if hitbox == nil or not hitbox:IsA("BasePart") then
			hitbox = nil
		end
	end

	if hitbox == nil then
		dropBeam() -- equivalent call inferred; original call site unknown
	else
		local v2 = v

		if v2 == nil then
			v = TutorialBeam.Attach(hitbox, {
				BeamName = "SammyReturnBeam"
			})
		else
			TutorialBeam.Retarget(v2, hitbox)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopRunBack()
	if flag then
		flag = false
		CarryRunBackEffects.ForceStop()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function syncRunBack()
	if localPlayer:GetAttribute("SammyCarrying") == nil then
		stopRunBack() -- equivalent call inferred; original call site unknown
	elseif not flag then
		flag = true
		CarryRunBackEffects.ForceStart()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stop()
	dropBeam() -- equivalent call inferred; original call site unknown
	stopRunBack() -- equivalent call inferred; original call site unknown
end

local function start(maid)
	stop() -- equivalent call inferred; original call site unknown
	maid:Connect(localPlayer:GetAttributeChangedSignal("SammyCarrying"), function()
		refresh()
		syncRunBack() -- equivalent call inferred; original call site unknown
	end)
	maid:Add(stop)
	maid:Add(task.spawn(function()
		Workspace:WaitForChild("SammyEventMap", 10)

		while true do
			refresh()
			task.wait(0.25)
		end
	end))
end

return {
	Start = start,
	Stop = stop
}