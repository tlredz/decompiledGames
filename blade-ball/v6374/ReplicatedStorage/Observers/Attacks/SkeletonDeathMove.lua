local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerInfo = require(ReplicatedStorage.ServerInfo)

if not ServerInfo.isBossFightServer() then
	return nil
end

local galaxyBoss = ReplicatedStorage.Assets.GalaxyBoss
return Observers.observeTag("GalaxyBossSkeletonDeathMove", function(instance)
	local skelly = instance:WaitForChild("Skelly", 5)
	local circle001 = skelly and skelly:WaitForChild("Circle.001", 5)
	local circle001Root = circle001 and circle001:WaitForChild("Root", 5)

	if not circle001Root then
		return
	end

	local humanoid = instance:FindFirstChildWhichIsA("Humanoid")

	if humanoid then
		local track = humanoid:FindFirstChildWhichIsA("Animator"):LoadAnimation(galaxyBoss.Death)
		track:Play()
		local timePositions = {}
		track:GetMarkerReachedSignal("Pin"):Connect(function(p)
			timePositions[p] = track.TimePosition
		end)
		track:GetMarkerReachedSignal("GOTO"):Connect(function(p)
			local timePosition = timePositions[p]

			if timePosition then
				track.TimePosition = timePosition
			end
		end)
		track:GetMarkerReachedSignal("GOTO"):Wait()
		task.wait(0.4)
	end

	local clone = galaxyBoss.RGGround:Clone()
	clone.Parent = circle001Root.Parent
	clone:Play()
	clone.Ended:Connect(function()
		clone:Destroy()
	end)
	local tween = TweenService:Create(
		circle001Root,
		TweenInfo.new(1.4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
		{
			CFrame = circle001Root.CFrame - createVector(0, 10, 0)
		}
	)
	tween:Play()
	tween.Completed:Once(function(p)
		if p == Enum.PlaybackState.Completed then
			instance:Destroy()
		end
	end)
end, { workspace })