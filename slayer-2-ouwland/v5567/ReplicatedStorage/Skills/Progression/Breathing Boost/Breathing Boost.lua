local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local global = CAM:WaitForChild("Global")
local skills = ReplicatedStorage:WaitForChild("Skills")
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Utility = require(global:WaitForChild("Utility"))
local DebrisModule = require(CAM:WaitForChild("DebrisModule"))
local ServerClientPortal = require(global:WaitForChild("ServerClientPortal"))
local Run_Handler = require(CAM:WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("GamePlay"):WaitForChild("Run_Handler"))
local Config = require(script.Parent.Config)
local BreathingBoost = {
	Id = 0
}
local localPlayer = Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local skill_stand_still = skills:WaitForChild("holder"):WaitForChild("skill_stand_still")
local name = script.Parent.Name
local maid = cleanit.new()
local v = cleanit.new()
local v2 = nil

local function enhancedHearingClip()
	local clan = skills:FindFirstChild("Clan")
	local enhancedHearing = clan ~= nil and clan:FindFirstChild("Enhanced Hearing") or nil
	local enhancedHearing2 = enhancedHearing ~= nil and enhancedHearing:FindFirstChild("Enhanced Hearing") or nil

	if enhancedHearing2 == nil then
		return nil
	end

	local enhancedHearing3 = enhancedHearing2:FindFirstChild("EnhancedHearing") or enhancedHearing2:FindFirstChild("Animation")

	if enhancedHearing3 == nil or not enhancedHearing3:IsA("Animation") then
		return nil
	end

	return enhancedHearing3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopWatch()
	v:Clean()

	if v2 ~= nil and v2.__Active then
		v2:Destroy()
	end

	v2 = nil
end

local function startWatch(humanoid)
	stopWatch() -- equivalent call inferred; original call site unknown
	local link = ServerClientPortal.Link(name, Config.WINDUP + Config.DURATION + 1)
	v2 = link
	local v3 = false
	local v4 = false

	local function report(flag: boolean?)
		if not v3 then
			return
		end

		local v5

		if Run_Handler.Is_Running == true then
			v5 = humanoid.MoveDirection.Magnitude > Config.MOVE_THRESHOLD
		else
			v5 = false
		end

		if v5 == v4 and not flag then
			return
		end

		v4 = v5
		ServerClientPortal.Server(name, v4)
	end

	link:Connect(function(p)
		if p == "Start" then
			v3 = true
			local v5

			if Run_Handler.Is_Running == true then
				v5 = humanoid.MoveDirection.Magnitude > Config.MOVE_THRESHOLD
			else
				v5 = false
			end

			local _ = v5 == v4
			v4 = v5
			ServerClientPortal.Server(name, v4)
		elseif p == "End" then
			stopWatch() -- equivalent call inferred; original call site unknown
		end
	end)
	v:Connect(Run_Handler.RunningChanged.Event, function()
		if not v3 then
			return
		end

		local v5

		if Run_Handler.Is_Running == true then
			v5 = humanoid.MoveDirection.Magnitude > Config.MOVE_THRESHOLD
		else
			v5 = false
		end

		if v5 == v4 then
			return
		end

		v4 = v5
		ServerClientPortal.Server(name, v4)
	end)
	v:Connect(humanoid:GetPropertyChangedSignal("MoveDirection"), function()
		if not v3 then
			return
		end

		local v5

		if Run_Handler.Is_Running == true then
			v5 = humanoid.MoveDirection.Magnitude > Config.MOVE_THRESHOLD
		else
			v5 = false
		end

		if v5 == v4 then
			return
		end

		v4 = v5
		ServerClientPortal.Server(name, v4)
	end)
end

function BreathingBoost.Hold(player)
	if player == nil then
		return false
	end

	local character = player.Character

	if character == nil then
		return false
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return false
	end

	maid:Clean()
	local id = BreathingBoost.Id
	local clone = skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	DebrisModule:AddItem(clone, Config.WINDUP)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", Config.WINDUP))
	local v3 = enhancedHearingClip()
	local animator = humanoid:FindFirstChildOfClass("Animator")
	local track

	if v3 == nil or animator == nil then
		track = nil
	else
		track = animator:LoadAnimation(v3)
		maid:Add(track)
		track:Play()
		track.Stopped:Once(function()
			track:Destroy()
		end)
	end

	startWatch(humanoid)
	task.wait(Config.WINDUP)

	if id ~= BreathingBoost.Id then
		return true
	end

	if track ~= nil then
		maid:Remove(track)
	end

	maid:Clean()
	return true
end

function BreathingBoost.Cancel(_)
	maid:Clean()
end

return BreathingBoost