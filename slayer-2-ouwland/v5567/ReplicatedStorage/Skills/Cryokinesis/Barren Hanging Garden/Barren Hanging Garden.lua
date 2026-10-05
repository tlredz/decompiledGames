local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local ServerClientPortal = require(CAM.Global.ServerClientPortal)
local Utility = require(CAM.Global.Utility)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Config = require(script.Parent.Config)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local skill_stand_still = ReplicatedStorage.Skills.holder.skill_stand_still
local BarrenHangingGarden = {
	Id = 0
}
local barrenHangingGardenFar = script.BarrenHangingGardenFar
local barrenHangingGardenStartup = script.BarrenHangingGardenStartup
local barrenHangingGardenLoop = script.BarrenHangingGardenLoop
local barrenHangingGardenRelease = script.BarrenHangingGardenRelease
local v = {
	branch = nil,
	holdStartupTrack = nil,
	holdFarTrack = nil,
	holdStart = 0
}

function BarrenHangingGarden.Hold(player)
	maid:Clean()
	v.branch = nil
	v.holdStartupTrack = nil
	v.holdFarTrack = nil
	local id = BarrenHangingGarden.Id
	local character = player.Character
	local animator = character:FindFirstChild("Humanoid"):FindFirstChild("Animator")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local clone = skill_stand_still:Clone()
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	local getvaluesfolder = Utility.getvaluesfolder(character)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", 6))
	local mousepos = Platform_Handler.mousepos()
	local vector2 = Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z)
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			Responsiveness = 70,
			MaxTorque = 500000,
			CFrame = Utility.SafeLookAt(humanoidRootPart.Position, vector2, humanoidRootPart.CFrame)
		}
	)
	maid:Add(v2)
	maid:Add(alignOrientationWithAttachment)
	maid:Connect(RunService.PostSimulation, function()
		if id ~= BarrenHangingGarden.Id then
			return
		end

		local mousepos2 = Platform_Handler.mousepos()
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			Vector3.new(mousepos2.X, humanoidRootPart.Position.Y, mousepos2.Z),
			alignOrientationWithAttachment.CFrame
		)
	end)
	local link = ServerClientPortal.Link(script.Parent.Name, 3)
	maid:Add(link)
	link:Once(function(p: string)
		v.holdStart = os.clock()

		if p == "Close" then
			v.branch = "Close"
			local track = animator:LoadAnimation(barrenHangingGardenStartup)
			maid:Add(track)
			track:Play()
			v.holdStartupTrack = track
			task.wait(Config.HOLD_FREEZE_MARK)

			if BarrenHangingGarden.Id ~= id then
				return
			end

			track:AdjustSpeed(0)
		else
			v.branch = "Far"
			local track = animator:LoadAnimation(barrenHangingGardenFar)
			maid:Add(track)
			track:Play()
			track:AdjustSpeed(0)
			v.holdFarTrack = track
		end
	end)
end

function BarrenHangingGarden.UnHold(player)
	local id = BarrenHangingGarden.Id
	local animator = player.Character:FindFirstChild("Humanoid"):FindFirstChild("Animator")
	local lastTime = os.clock()

	while v.branch == nil and os.clock() - lastTime < Config.BRANCH_SIGNAL_TIMEOUT and BarrenHangingGarden.Id == id do
		task.wait()
	end

	if BarrenHangingGarden.Id ~= id then
		return
	end

	ManuelCancel.new(player, 3):Connect(function()
		if BarrenHangingGarden.Id ~= id then
			return
		end

		BarrenHangingGarden.Id = -1
		BarrenHangingGarden.Cancel(player)
	end)

	if v.branch == "Close" then
		if v.holdStartupTrack then
			v.holdStartupTrack:AdjustSpeed(1)
		end

		local v2 = os.clock() - v.holdStart

		if v.holdStartupTrack and v2 < Config.HOLD_FREEZE_MARK then
			v.holdStartupTrack.TimePosition = Config.HOLD_FREEZE_MARK
		end

		task.wait(0.07)

		if BarrenHangingGarden.Id ~= id then
			return
		end

		local track = animator:LoadAnimation(barrenHangingGardenLoop)
		maid:Add(track)
		track:Play()
		track:AdjustSpeed(1.5)
		task.wait(Config.CLOSE_BARRAGE_DURATION)

		if BarrenHangingGarden.Id ~= id then
			return
		end

		track:Stop()
		local track2 = animator:LoadAnimation(barrenHangingGardenRelease)
		maid:Add(track2)
		track2:Play()
	elseif v.holdFarTrack ~= nil then
		v.holdFarTrack:AdjustSpeed(1)
	end

	task.wait(1.15)

	if BarrenHangingGarden.Id ~= id then
		return
	end

	maid:Clean()
end

function BarrenHangingGarden.Cancel(_)
	v.branch = nil
	v.holdStartupTrack = nil
	v.holdFarTrack = nil
	maid:Clean()
end

return BarrenHangingGarden