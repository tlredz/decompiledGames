local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local Config = require(script.Parent.Config)
local CAM = ReplicatedStorage.CAM
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local Utility = require(CAM.Global.Utility)
local maid = cleanit.new()
local ScytherVortex = {
	Id = 0
}
local track = nil
local clone = nil

function ScytherVortex.Hold(player)
	maid:Clean()

	if track then
		track:Stop()
		track = nil
	end

	if clone then
		clone:Destroy()
		clone = nil
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not (humanoid and humanoidRootPart) then
		return
	end

	local id = ScytherVortex.Id
	clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	local mousepos = Platform_Handler.mousepos(500)
	local createAlignOrientationWithAttachment = Utility.CreateAlignOrientationWithAttachment
	local v = {
		AlignType = Enum.AlignType.PrimaryAxisParallel,
		Responsiveness = 70,
		MaxTorque = 500000,
		CFrame = 0
	}
	local safeLookAt = Utility.SafeLookAt
	local position = humanoidRootPart.Position
	local X = mousepos.X
	v.CFrame = safeLookAt(position, Vector3.new(X, humanoidRootPart.Position.Y, mousepos.Z), humanoidRootPart.CFrame)
	local alignOrientationWithAttachment, v2 = createAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		v
	)
	maid:Add(alignOrientationWithAttachment)
	maid:Add(v2)
	maid:Add(RunService.PostSimulation:Connect(function()
		if id ~= ScytherVortex.Id then
			return
		end

		mousepos = Platform_Handler.mousepos(500)
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z),
			alignOrientationWithAttachment.CFrame
		)
	end))
	local animator = humanoid:FindFirstChildOfClass("Animator")
	local startup = script:FindFirstChild("Startup")

	if animator and startup then
		track = animator:LoadAnimation(startup)
		track:Play()
		local v3 = track
		task.delay(Config.HOLD_AT, function()
			if id ~= ScytherVortex.Id then
				return
			end

			if track == v3 and v3.IsPlaying then
				v3:AdjustSpeed(0)
			end
		end)
	end
end

function ScytherVortex.UnHold(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoid) then
		maid:Clean()
		return
	end

	local id = ScytherVortex.Id
	local v, v2 = ManuelCancel.new(player, 2)
	v:Connect(function(...)
		v2()
		ScytherVortex.Id = -1
		warn("Cancel")
		ScytherVortex.Cancel(player)
	end)
	local v3 = track

	if v3 then
		if v3.TimePosition < Config.HOLD_AT then
			v3.TimePosition = Config.HOLD_AT
		end

		v3:AdjustSpeed(1)
		v3.Stopped:Wait()
	end

	if id ~= ScytherVortex.Id then
		return
	end

	if not humanoidRootPart.Parent then
		maid:Clean()
		return
	end

	maid:Clean()
	local animator = humanoid:FindFirstChildOfClass("Animator")
	local back = script:FindFirstChild("Back")

	if animator and back then
		local track2 = animator:LoadAnimation(back)
		track2:Play()
		Debris:AddItem(track2, Config.BACK_TIME + 1)
	end

	if not clone then
		clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
		clone.Parent = humanoidRootPart
	end

	local linearVelocity = clone.LinearVelocity
	local v4 = -humanoidRootPart.CFrame.LookVector
	local vector2 = Vector3.new(v4.X, 0, v4.Z)

	if vector2.Magnitude > 0 then
		vector2 = vector2.Unit
	end

	local v5 = Config.BACK_DISTANCE / Config.BACK_TIME
	local lastTime = os.clock()
	maid:Add(RunService.PostSimulation:Connect(function()
		if id ~= ScytherVortex.Id then
			return
		end

		local v6 = (os.clock() - lastTime) / Config.BACK_TIME

		if v6 >= 1 or not humanoidRootPart.Parent then
			linearVelocity.VectorVelocity = createVector(0, 0, 0)
			return
		end

		local v7 = 1 - v6
		linearVelocity.VectorVelocity = vector2 * v5 * v7
	end))
	task.delay(Config.BACK_TIME, function()
		if id ~= ScytherVortex.Id then
			return
		end

		if humanoidRootPart.Parent then
			humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		end

		maid:Clean()

		if clone then
			clone:Destroy()
			clone = nil
		end
	end)
end

function ScytherVortex.Cancel(player)
	maid:Clean()

	if track then
		track:Stop()
		track = nil
	end

	if clone then
		clone:Destroy()
		clone = nil
	end

	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)

		for _, child in pairs(humanoidRootPart:GetChildren()) do
			if child.Name == "skill_stand_still" or child.Name == "skill_look_at" then
				child:Destroy()
			end
		end
	end
end

return ScytherVortex