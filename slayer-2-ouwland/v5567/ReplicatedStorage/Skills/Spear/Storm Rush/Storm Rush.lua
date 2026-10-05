local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local DebrisModule = require(CAM.DebrisModule)
local Utility = require(CAM.Global.Utility)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Config = require(script.Parent.Config)
local StormRush = {
	Id = 0,
	HoverReady = false
}
local skill_stand_still = skills.holder.skill_stand_still
local startup = script.Startup
local barrage = script.Barrage
local kick = script.Kick
local jump = script.Jump
local fall = script.Fall
local land = script.Land

function StormRush.Hold(player)
	v:Clean()
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not (animator and humanoidRootPart) then
		return
	end

	local id = StormRush.Id
	StormRush.HoverReady = false
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 70,
			MaxTorque = 500000,
			CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z),
				humanoidRootPart.CFrame
			)
		}
	)
	v:Add(alignOrientationWithAttachment)
	v:Add(v2)
	DebrisModule:AddItem(alignOrientationWithAttachment, Config.HOLD_LOCK_DURATION)
	DebrisModule:AddItem(v2, Config.HOLD_LOCK_DURATION)
	v:Connect(RunService.PostSimulation, function()
		if StormRush.Id ~= id then
			return
		end

		local mousepos2 = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			Vector3.new(mousepos2.X, humanoidRootPart.Position.Y, mousepos2.Z),
			alignOrientationWithAttachment.CFrame
		)
	end)
	task.spawn(function()
		local track = animator:LoadAnimation(startup)
		v:Add(track)
		track:Play()
		task.wait(Config.STARTUP_AT)

		if StormRush.Id ~= id then
			return
		end

		local track2 = animator:LoadAnimation(barrage)
		track2.Looped = true
		v:Add(track2)
		track2:Play()
		task.wait(Config.BARRAGE_DUR)

		if StormRush.Id ~= id then
			return
		end

		track2:Stop()
		local track3 = animator:LoadAnimation(kick)
		v:Add(track3)
		track3:Play()
		task.wait(Config.KICK_HIT_AT)

		if StormRush.Id ~= id then
			return
		end

		local SHC = character:FindFirstChild("SHC")

		if SHC then
			SHC:SetAttribute("en", true)
		end

		task.wait(Config.KICK_DUR - Config.KICK_HIT_AT)

		if StormRush.Id ~= id then
			return
		end

		local clone = skill_stand_still:Clone()
		clone.LinearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
		clone.LinearVelocity.MaxAxesForce = createVector(1000000, 1000000, 1000000)
		clone.LinearVelocity.VectorVelocity = Vector3.new(0, Config.RISE_SPEED, 0)
		clone.Parent = humanoidRootPart
		v:Add(clone)
		DebrisModule:AddItem(clone, Config.HOLD_LOCK_DURATION)
		local track4 = animator:LoadAnimation(jump)
		v:Add(track4)
		track4:Play()
		task.wait(Config.RISE_DURATION)

		if StormRush.Id ~= id then
			return
		end

		clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
		track4:AdjustSpeed(0)
		StormRush.HoverReady = true

		if SHC then
			SHC:SetAttribute("en", false)
		end
	end)
	task.wait(Config.MIN_HOLD_DUR)
end

function StormRush.UnHold(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not (animator and humanoidRootPart) then
		v:Clean()
		return true
	end

	if StormRush.HoverReady then
		StormRush.HoverReady = false
		local id = StormRush.Id
		local position = humanoidRootPart.Position
		local unit = (humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)).Unit
		local v2 = position + unit * Config.SLAM_FORWARD
		local raycastResult = workspace:Raycast(
			v2 + createVector(0, 5, 0),
			Vector3.new(0, -Config.MAX_SLAM_DIST, 0),
			RaycastHelper.Crater
		)
		local position2

		if raycastResult then
			position2 = raycastResult.Position
		else
			position2 = Vector3.new(v2.X, position.Y - 30, v2.Z)
		end

		local v3 = position2 + Vector3.new(0, humanoid.HipHeight + humanoidRootPart.Size.Y / 2, 0)
		v:Clean()
		local v4 = math.max((v3 - position).Magnitude / Config.SLAM_SPEED, 0.05)
		local clone = skill_stand_still:Clone()
		clone.LinearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
		clone.LinearVelocity.MaxAxesForce = createVector(1000000, 1000000, 1000000)
		clone.LinearVelocity.VectorVelocity = (v3 - position) / v4
		clone.Parent = humanoidRootPart
		v:Add(clone)
		DebrisModule:AddItem(clone, v4 + 1)
		local track = animator:LoadAnimation(fall)
		v:Add(track)
		track:Play()
		track:AdjustSpeed(Config.FALL_DUR / v4)
		task.wait(v4)

		if StormRush.Id ~= id then
			return true
		end

		track:Stop()
		clone:Destroy()
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
		local track2 = animator:LoadAnimation(land)
		v:Add(track2)
		track2:Play()
		task.delay(Config.LAND_DUR, function()
			if StormRush.Id ~= id then
				return
			end

			v:Clean()
		end)
		return CFrame.lookAt(position2, position2 + unit)
	else
		v:Clean()
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		return true
	end
end

function StormRush.Cancel(_)
	StormRush.HoverReady = false
	v:Clean()
end

return StormRush