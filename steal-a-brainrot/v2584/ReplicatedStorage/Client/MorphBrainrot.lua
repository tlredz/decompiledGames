local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)
local animals = ReplicatedStorage.Animations.Animals
local localPlayer = Players.LocalPlayer
local remoteEvent = Net:RemoteEvent("MorphBrainrot")
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanup()
	if not v then
		return
	end

	if v.connection then
		v.connection:Disconnect()
	end

	if v.walkTrack then
		v.walkTrack:Stop()
	end

	if v.idleTrack then
		v.idleTrack:Stop()
	end

	v = nil
end

local function startAnimations(childName: string)
	cleanup() -- equivalent call inferred; original call site unknown
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	local morphBrainrot = character:WaitForChild("MorphBrainrot", 5)

	if not morphBrainrot then
		return
	end

	local animationController = morphBrainrot:FindFirstChildOfClass("AnimationController") or Instance.new(
		"AnimationController",
		morphBrainrot
	)
	local child = animals:FindFirstChild(childName)

	if not child then
		return
	end

	local idle = child:FindFirstChild("Idle")
	local walk = child:FindFirstChild("Walk")

	if not (idle and walk) then
		return
	end

	local track = animationController:LoadAnimation(idle)
	local track2 = animationController:LoadAnimation(walk)
	track.Priority = Enum.AnimationPriority.Action
	track2.Priority = Enum.AnimationPriority.Action
	track.Looped = true
	track2.Looped = true
	track:Play()
	local v2 = false
	v = {
		idleTrack = track,
		walkTrack = track2,
		connection = humanoid.Running:Connect(function(p)
			if p > 0.1 and not v2 then
				v2 = true
				track:Stop()
				track2:Play()
			elseif p <= 0.1 and v2 then
				v2 = false
				track2:Stop()
				track:Play()
			end
		end)
	}
end

remoteEvent.OnClientEvent:Connect(function(p: string?)
	if p then
		startAnimations(p)
		return
	end

	cleanup() -- equivalent call inferred; original call site unknown
end)