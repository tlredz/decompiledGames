local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local EmotesShared = require(ReplicatedStorage.Shared.EmotesShared)
require("@game/ReplicatedStorage/Types/Templates")
local v = {
	Kitty = {
		EmoteId = "Emote554",
		Offset = CFrame.new(0, -1, 0)
	},
	["T-Rex"] = {
		EmoteId = "Emote991",
		Offset = CFrame.new(0, 0, 0)
	}
}

local function getDefaultProperty(instance, p: string)
	local formatted = `Default_{p}`
	local attribute = instance:GetAttribute(formatted)

	if not attribute then
		attribute = instance[p]
		instance:SetAttribute(formatted, attribute)
	end

	return attribute
end

return Observers.observeTag("AnimatedAccessory", function(instance)
	local parent = instance.Parent
	local parent2 = parent and parent.Parent
	local humanoid = parent2 and parent2:WaitForChild("Humanoid", 5)
	local humanoidRootPart = parent2 and parent2:WaitForChild("HumanoidRootPart", 5)

	if not parent2 or parent2.ClassName ~= "Model" or not (humanoid and humanoidRootPart) then
		return nil
	end

	local animationController = instance:WaitForChild("AnimationController", 5)
	local animator = animationController and animationController:WaitForChild("Animator", 5)
	local animations = animator and animator:WaitForChild("Animations", 5)
	local primaryPart = instance.PrimaryPart

	if not animator then
		warn((`No Animator found for AnimatedAccessory {instance:GetFullName()}`))
		return nil
	end

	if not animations then
		warn((`No Animations folder found for AnimatedAccessory {instance:GetFullName()}`))
		return nil
	end

	local maid = Trove.new()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function loadTrack(childName: string)
		local child = animations:FindFirstChild(childName)

		if child then
			return maid:Add(animator:LoadAnimation(child))
		end
	end

	local track = loadTrack("Idle") -- equivalent call inferred; original call site unknown

	if track then
		track:Play()
	end

	local v3 = {
		Jump = 0,
		Walk = 0,
		Run = 0,
		Falling = 0,
		Parry = 0
	}
	local jump = loadTrack("Jump") -- equivalent call inferred; original call site unknown
	v3.Jump = jump
	local walk = loadTrack("Walk") -- equivalent call inferred; original call site unknown
	v3.Walk = walk
	local run = loadTrack("Run") -- equivalent call inferred; original call site unknown
	v3.Run = run
	local falling = loadTrack("Falling") -- equivalent call inferred; original call site unknown
	v3.Falling = falling
	local parry2 = loadTrack("Parry") -- equivalent call inferred; original call site unknown
	v3.Parry = parry2

	if not (v3.Jump and v3.Falling and v3.Run and v3.Walk) then
		maid:Destroy()
		return nil
	end

	local v9 = false
	local v10 = nil

	local function playAnimation(p: string?)
		v10 = p

		if not v9 then
			local v11 = p and v3[p]

			if v11 and not v11.IsPlaying then
				v11:Play()
			end
		end

		for k, v11 in pairs(v3) do
			if v11 and v11.IsPlaying and (k ~= p or v9) then
				v11:Stop()
			end
		end
	end

	local minWalkSpeed = instance:GetAttribute("MinWalkSpeed") or 5
	local minRunSpeed = instance:GetAttribute("MinRunSpeed") or 16
	local minJumpSpeed = instance:GetAttribute("MinJumpSpeed") or 5

	if instance:GetAttribute("ReflectAnimate") then
		local v11 = {
			idle = "Idle",
			run = "Run",
			walk = "Walk",
			jump = "Jump",
			fall = "Falling"
		}

		local function updateAnimation()
			playAnimation(v11[parent2:GetAttribute("CurrentlyPlayingAnimation") or "idle"] or "Idle")
		end

		maid:Add(parent2:GetAttributeChangedSignal("CurrentlyPlayingAnimation"):Connect(updateAnimation))
		task.spawn(updateAnimation)
	else
		maid:Add(RunService.PostSimulation:Connect(function()
			if not (parent2 and parent2.Parent) then
				return
			end

			local assemblyLinearVelocity = humanoidRootPart and humanoidRootPart.AssemblyLinearVelocity or createVector(
				0,
				0,
				0
			)
			local magnitude = (assemblyLinearVelocity * createVector(1, 0, 1)).Magnitude

			if minJumpSpeed < assemblyLinearVelocity.Y then
				playAnimation("Jump")
				return
			end

			if assemblyLinearVelocity.Y < -minJumpSpeed then
				playAnimation("Falling")
				return
			end

			if v3.Falling.IsPlaying then
				v3.Falling:Stop()
			end

			if v3.Jump.IsPlaying then
				v3.Jump:Stop()
			end

			if minRunSpeed <= magnitude then
				playAnimation("Run")
				return
			end

			if minWalkSpeed <= magnitude then
				playAnimation("Walk")
				return
			end

			if v3.Run.IsPlaying then
				v3.Run:Stop()
			end

			if v3.Walk.IsPlaying then
				v3.Walk:Stop()
			end
		end))
	end

	local maid2 = maid:Extend()
	local v11 = v[instance.Name]

	local function updateEmote()
		maid2:Clean()
		local currentEmote = parent2:GetAttribute("CurrentEmote")
		v9 = currentEmote ~= nil and v11 and (currentEmote == v11.EmoteId or v11.EmoteId == "any")
		playAnimation(v10)

		if v9 and track then
			track:Stop()
			maid2:Add(function()
				track:Play()
			end)

			if primaryPart then
				for _, instance2 in primaryPart:GetJoints() do
					if not ((instance2:IsA("Motor6D") or instance2:IsA("Weld")) and instance2.Part1 == primaryPart) then
						continue
					end

					local default_C0 = instance2:GetAttribute("Default_C0")

					if not default_C0 then
						default_C0 = instance2.C0
						instance2:SetAttribute("Default_C0", default_C0)
					end

					instance2.C0 = CFrame.new(0, default_C0.Y, 0) * (v11 and v11.Offset or CFrame.identity)
					local v13 = instance2
					maid2:Add(function()
						v13.C0 = default_C0
					end)
				end
			end
		end

		local animationTrackForAnimator = currentEmote and EmotesShared:GetAnimationTrackForAnimator(
			animator,
			maid2,
			script:FindFirstChild(currentEmote) or currentEmote
		)

		if animationTrackForAnimator then
			animationTrackForAnimator:Play()
			maid2:Add(function()
				animationTrackForAnimator:Stop()
				animationTrackForAnimator:Destroy()
			end)
		end
	end

	maid:Add(parent2:GetAttributeChangedSignal("CurrentEmote"):Connect(updateEmote))
	task.spawn(updateEmote)

	if v3.Parry then
		local function parry()
			if not parent2:GetAttribute("Parrying") then
				return
			end

			v3.Parry:Play()
		end

		maid:Add(parent2:GetAttributeChangedSignal("LastParry"):Connect(parry))
		maid:Add(parent2:GetAttributeChangedSignal("Parrying"):Connect(parry))
	end

	return function()
		maid:Destroy()
	end
end, { workspace })