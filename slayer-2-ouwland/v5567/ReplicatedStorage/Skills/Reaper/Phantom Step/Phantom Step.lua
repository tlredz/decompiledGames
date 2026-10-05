local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local client = CAM.Client
local global = CAM.Global
local Platform_Handler = require(client.Controllers.Platform_Handler)
local cleanit = require(game.ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local Utility = require(global.Utility)
local DebrisModule = require(CAM.DebrisModule)
local ManuelCancel = require(ReplicatedStorage2.CAM.Global.Subsets.Gameplay.ManuelCancel)
local RaycastHelper = require(global.RaycastHelper)
local Config = require(script.Parent.Config)

local function wallAhead(p, vector2: Vector3, p2: number)
	local raycastResult = workspace:Raycast(p.Position, vector2 * (p2 * 0.05 + 3), RaycastHelper.Crater)
	return raycastResult ~= nil and raycastResult.Normal.Y < 0.5
end

local PhantomStep = {
	Id = 0
}
local v2 = {}

function PhantomStep.Hold(player)
	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local rootPart = humanoid.RootPart

	if not rootPart then
		return
	end

	local animator = humanoid:FindFirstChild("Animator")

	if not animator then
		return
	end

	local track = animator:LoadAnimation(script.User)
	track:Play()
	v2.User_Animation = track
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local alignOrientationWithAttachment, v3 = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		AlignType = Enum.AlignType.PrimaryAxisParallel,
		Responsiveness = 75,
		MaxTorque = 3000,
		CFrame = Utility.SafeLookAt(rootPart.Position, mousepos, rootPart.CFrame)
	})
	v:Add(v3)
	alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
		rootPart.Position,
		mousepos,
		alignOrientationWithAttachment.CFrame
	)
	local clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Parent = rootPart
	DebrisModule:AddItem(clone, 10)
	v2.mover = clone
	local linearVelocity = clone.LinearVelocity
	local id = PhantomStep.Id
	task.wait(Config.STARTUP_AT)

	if PhantomStep.Id == id then
		linearVelocity.VectorVelocity = rootPart.CFrame.LookVector * Config.DASH_SPEED * createVector(1, 0, 1)
		v:Connect(RunService.Heartbeat, function(_: number)
			local mousepos2 = Platform_Handler.mousepos(Config.MOUSE_RANGE)
			alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
				rootPart.Position,
				mousepos2,
				alignOrientationWithAttachment.CFrame
			)
			local lookVector = rootPart.CFrame.LookVector
			local linearVelocity2 = linearVelocity
			local DASH_SPEED = Config.DASH_SPEED
			local raycastResult = workspace:Raycast(
				rootPart.Position,
				lookVector * (DASH_SPEED * 0.05 + 3),
				RaycastHelper.Crater
			)
			linearVelocity2.VectorVelocity = raycastResult ~= nil and raycastResult.Normal.Y < 0.5 and createVector(
				0,
				0,
				0
			) or lookVector * Config.DASH_SPEED * createVector(1, 0, 1)
		end)
	end

	task.wait(0.2)
end

function PhantomStep.UnHold(player)
	v:Clean()
	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local rootPart = humanoid.RootPart

	if not rootPart then
		return
	end

	local id = PhantomStep.Id
	local v3, v4 = ManuelCancel.new(player, 1)
	v3:Connect(function()
		PhantomStep.Cancel(player)
	end)

	if v2.User_Animation.TimePosition < Config.UNHOLD_ANIM_SKIP_TO then
		v2.User_Animation.TimePosition = Config.UNHOLD_ANIM_SKIP_TO
	end

	local mover = v2.mover

	if mover then
		local linearVelocity = mover.LinearVelocity
		local lookVector = rootPart.CFrame.LookVector
		DebrisModule:AddItem(mover, Config.BURST_DURATION)
		local lastTime = os.clock()

		while true do
			local v5 = (os.clock() - lastTime) / Config.BURST_DURATION

			if v5 >= 1 then
				break
			end

			local v6 = Config.BURST_SPEED * (1 - v5) ^ 2
			local raycastResult = workspace:Raycast(
				rootPart.Position,
				lookVector * (v6 * 0.05 + 3),
				RaycastHelper.Crater
			)
			linearVelocity.VectorVelocity = raycastResult ~= nil and raycastResult.Normal.Y < 0.5 and createVector(
				0,
				0,
				0
			) or lookVector * v6
			RunService.Heartbeat:Wait()
		end

		if PhantomStep.Id == id then
			v2.mover = nil
		end
	end

	v4()
end

function PhantomStep.Cancel(player)
	v:Clean()

	if v2.User_Animation then
		v2.User_Animation:Stop()
		v2.User_Animation:Destroy()
	end

	if v2.mover then
		v2.mover:Destroy()
		v2.mover = nil
	end

	local character = player.Character

	if not character then
		return
	end

	local primaryPart = character.PrimaryPart

	if not primaryPart then
		return
	end

	primaryPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	primaryPart.AssemblyAngularVelocity = createVector(0, 0, 0)
end

return PhantomStep