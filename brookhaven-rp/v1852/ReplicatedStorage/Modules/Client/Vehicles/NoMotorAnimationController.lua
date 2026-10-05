local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local NoMotorAnimationController = {}
local tracksByName = {}
local maid = nil
local maid2 = nil

function NoMotorAnimationController.FrameworkInit()
	maid = Janitor.new()
	maid2 = Janitor.new()
end

function NoMotorAnimationController.FrameworkStart()
	local localPlayer = Players.LocalPlayer
	local character = localPlayer.Character
	localPlayer.CharacterAdded:Connect(function(character2)
		NoMotorAnimationController.loadAnimations(character2:WaitForChild("Humanoid"))
	end)
	localPlayer.CharacterRemoving:Connect(function()
		maid2:Cleanup()
	end)

	if character then
		NoMotorAnimationController.loadAnimations(character:WaitForChild("Humanoid"))
	end
end

function NoMotorAnimationController.loadAnimations(animator)
	local noMotorAnimations = ReplicatedStorage:WaitForChild("NoMotorAnimations")

	for _, animation in noMotorAnimations:GetChildren() do
		local track = animator:LoadAnimation(animation)
		track.Priority = Enum.AnimationPriority.Action
		tracksByName[animation.Name] = track
	end

	maid2:Add(noMotorAnimations.ChildAdded:Connect(function(child)
		local track = animator:LoadAnimation(child)
		track.Priority = Enum.AnimationPriority.Action
		tracksByName[child.Name] = track
	end))
end

function NoMotorAnimationController.StopAll()
	maid:Cleanup()

	for _, v in tracksByName do
		v:Stop()
	end
end

function NoMotorAnimationController:Play()
	local v = tracksByName[self]
	assert(v, "unknown animation " .. self)

	if not v.IsPlaying then
		v:Play(nil, nil, 0)
	end
end

function NoMotorAnimationController.StartSpeedControl(p: string)
	local v = tracksByName[p]
	assert(v, "unknown animation " .. p)
	maid:Add(RunService.Heartbeat:Connect(function()
		v:AdjustSpeed(Players.LocalPlayer.Character.Head.Velocity.magnitude / 10)
	end))
end

function NoMotorAnimationController.HasAnimation(p: string)
	return tracksByName[p] ~= nil
end

return NoMotorAnimationController