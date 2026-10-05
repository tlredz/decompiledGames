local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
require("@game/ReplicatedStorage/Types/Templates")
require(ReplicatedStorage.Shared.EmotesShared)
local Utils = require(ReplicatedStorage.Common.Utils)
local v = Observers.observeTag("AnimatedSwordAccessory", function(object)
	local parent = object.Parent
	local parent2 = parent and parent.Parent
	local humanoid = parent2 and parent2:WaitForChild("Humanoid", 5)
	local humanoidRootPart = parent2 and parent2:WaitForChild("HumanoidRootPart", 5)
	local torso = parent2 and parent2:WaitForChild("Torso", 5)

	if not parent2 or parent2.ClassName ~= "Model" or not (humanoid and humanoidRootPart and torso) then
		return nil
	end

	local maid = Trove.new()
	local maid2 = maid:Extend()

	local function updateEmote()
		maid2:Clean()
		local v2 = parent2:GetAttribute("CurrentEmote") ~= nil

		for _, v3 in parent:QueryDescendants("Motor6D"), nil, nil do
			v3.Enabled = not v2
		end

		task.delay(0, function()
			for _, v3 in parent:QueryDescendants("Motor6D"), nil, nil do
				v3.Enabled = not v2
			end
		end)

		if not v2 then
			object.Parent = parent
			return
		end

		for _, v3 in object:QueryDescendants("BasePart [$Animatable = true]"), nil, nil do
			local v4 = v3
			task.delay(0, function()
				maid2:Add(Utils.Physics.CreateMotor(torso, v4))
			end)
		end

		object.Parent = parent2
	end

	maid:Add(parent2:GetAttributeChangedSignal("CurrentEmote"):Connect(updateEmote))
	task.spawn(updateEmote)
	return function()
		maid:Destroy()
	end
end, { workspace })
local v2 = Observers.observeTag("RyuzakuraKatanaIdle", function(instance)
	local parent = instance.Parent
	local parent2 = parent and parent.Parent

	if not (parent2 and parent2:IsA("Model")) then
		return nil
	end

	local maid = Trove.new()
	local v3 = maid:Add(Instance.new("Animation"))
	v3.AnimationId = "rbxassetid://99472414752056"
	maid:Add(task.spawn(function()
		local v4 = os.clock() + 5
		local animator = nil

		while os.clock() < v4 and instance.Parent do
			local animationController = instance:FindFirstChildWhichIsA("AnimationController", true)

			if animationController then
				animator = animationController:FindFirstChildOfClass("Animator")
			else
				animator = nil
			end

			if animator then
				break
			else
				task.wait()
			end
		end

		if not animator then
			warn((`No Animator found for {instance:GetFullName()}`))
			return
		end

		local v5 = maid:Add(animator:LoadAnimation(v3), "Destroy")
		v5.Looped = true
		v5.Priority = Enum.AnimationPriority.Idle
		v5:Play()
		maid:Add(v5.Stopped:Connect(function()
			task.defer(function()
				if instance.Parent and instance:HasTag("RyuzakuraKatanaIdle") and not v5.IsPlaying then
					v5:Play()
				end
			end)
		end))
	end))
	return function()
		maid:Destroy()
	end
end, { workspace })
return function()
	v()
	v2()
end