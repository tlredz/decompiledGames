local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local global = CAM.Global
local client = CAM.Client
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local Utility = require(global.Utility)
local SkillAimMarker = require(client.Modules.Effects.SkillAimMarker)
local Platform_Handler = require(client.Controllers.Platform_Handler)
local ServerClientPortal = require(global.ServerClientPortal)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local RaycastHelper = require(global.RaycastHelper)
local Config = require(script.Parent.Config)
local MelodicWhisper = {
	Id = 0
}
local v = {
	branch = nil,
	holdTrack = nil,
	aimMarker = nil
}
local melodicWhisperClose = script.MelodicWhisperClose
local melodicWhisperFar = script.MelodicWhisperFar
local skill_stand_still = skills.holder.skill_stand_still

local function updateAim(character, rootPart, alignOrientationWithAttachment)
	local maximizeRayClient, _, _, target = RaycastHelper.MaximizeRayClient(
		rootPart.Position,
		Platform_Handler.mousepos(Config.MOUSE_RANGE),
		Config.MOUSE_RANGE,
		true,
		Config.SPHERECAST_RADIUS,
		Config.DOWNCAST
	)
	local vector2 = Vector3.new(maximizeRayClient.X, rootPart.Position.Y, maximizeRayClient.Z)

	if alignOrientationWithAttachment then
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			rootPart.Position,
			vector2,
			alignOrientationWithAttachment.CFrame
		)
	else
		rootPart.CFrame = Utility.SafeLookAt(rootPart.Position, vector2, rootPart.CFrame)
	end

	local child = character:FindFirstChild(Config.POS_PART_NAME)

	if child then
		child.Position = maximizeRayClient
		local bp = child:FindFirstChild("bp")

		if bp then
			bp.Position = maximizeRayClient
		end
	end

	if v.aimMarker then
		v.aimMarker:Update({
			position = maximizeRayClient,
			target = target
		})
	end
end

function MelodicWhisper.Hold(player)
	maid:Clean()
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local animator = humanoid:FindFirstChild("Animator")
	local id = MelodicWhisper.Id
	v.branch = nil
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		Responsiveness = 70,
		MaxTorque = 500000,
		CFrame = Utility.SafeLookAt(
			rootPart.Position,
			Vector3.new(mousepos.X, rootPart.Position.Y, mousepos.Z),
			rootPart.CFrame
		)
	})
	local extended = maid:Extend()
	extended:Add(v2)
	extended:Add(alignOrientationWithAttachment)
	extended:Connect(RunService.PostSimulation, function()
		if id ~= MelodicWhisper.Id then
			return
		end

		updateAim(character, rootPart, alignOrientationWithAttachment)
	end)
	local link = ServerClientPortal.Link(script.Parent.Name, 3)
	maid:Add(link)
	link:Once(function(branch: string)
		v.branch = branch

		if branch == "Close" then
			local track = animator:LoadAnimation(melodicWhisperClose)
			v.holdTrack = track
			maid:Add(track)
			track:Play()
			local clone = skill_stand_still:Clone()
			clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
			clone.Parent = rootPart
			maid:Add(clone)
			task.wait(Config.CLOSE_HOLD_FREEZE_MARK)

			if id ~= MelodicWhisper.Id or v.holdTrack ~= track then
				return
			end

			track:AdjustSpeed(0)
		elseif branch == "Far" then
			local track = animator:LoadAnimation(melodicWhisperFar)
			v.holdTrack = track
			maid:Add(track)
			track:Play()
			track:AdjustSpeed(0)
			task.wait(0.25)

			if id ~= MelodicWhisper.Id or v.holdTrack ~= track then
				return
			end

			track:AdjustSpeed(1)
			v.aimMarker = SkillAimMarker.new({
				Dot = true,
				Highlight = true
			})
			extended:Add(v.aimMarker)
			local total = 0

			for _, v3 in Config.FAR_PROJECTILE_DELAY_TIMES do
				total += v3
			end

			task.wait(total)

			if not extended.Clean then
				return
			end

			extended:Clean()
			v.aimMarker = nil
		end
	end)
end

function MelodicWhisper.UnHold(p)
	local id = MelodicWhisper.Id
	local lastTime = os.clock()

	while v.branch == nil and os.clock() - lastTime < Config.BRANCH_SIGNAL_TIMEOUT and MelodicWhisper.Id == id do
		task.wait()
	end

	if MelodicWhisper.Id ~= id then
		return
	end

	maid:Add(ManuelCancel.new(p, 2, nil, script.Parent.Name):Connect(function()
		MelodicWhisper.Id = -1
		MelodicWhisper.Cancel(p)
	end))

	if v.branch == "Close" and v.holdTrack then
		v.holdTrack:AdjustSpeed(1)
	end

	task.spawn(function()
		if v.branch == "Close" then
			task.wait(Config.CLOSE_TAIL_DURATION)
		elseif v.holdTrack then
			local v2 = math.max(v.holdTrack.Length - v.holdTrack.TimePosition, 0)
			task.wait((math.min(v2, Config.FAR_MAX_TAIL_GRACE)))
		end

		if MelodicWhisper.Id ~= id then
			return
		end

		MelodicWhisper.Cancel(p)
	end)
end

function MelodicWhisper.Cancel(_)
	maid:Clean()
	v.branch = nil
	v.holdTrack = nil
end

return MelodicWhisper