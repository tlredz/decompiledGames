local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local Utility = require(CAM.Global.Utility)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local Config = require(script.Parent.Config)
local FlashFist = {
	Id = 0
}
local flashFist = script.FlashFist
local track = nil
local postSimulationConnection = nil

function FlashFist.Hold(player)
	v:Clean()

	if track then
		track:Stop()
		track = nil
	end

	if postSimulationConnection then
		postSimulationConnection:Disconnect()
		postSimulationConnection = nil
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not (animator and humanoidRootPart) then
		return
	end

	local id = FlashFist.Id
	local clone = skills.holder.skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	v:Add(clone)
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
	postSimulationConnection = RunService.PostSimulation:Connect(function()
		if FlashFist.Id ~= id then
			return
		end

		local mousepos2 = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			Vector3.new(mousepos2.X, humanoidRootPart.Position.Y, mousepos2.Z),
			alignOrientationWithAttachment.CFrame
		)
	end)
	track = animator:LoadAnimation(flashFist)
	track:Play()
	task.delay(Config.HOLD_PAUSE, function()
		if FlashFist.Id ~= id then
			return
		end

		if track and track.IsPlaying then
			track:AdjustSpeed(0)
		end
	end)
end

function FlashFist.UnHold(_)
	local id = FlashFist.Id

	if postSimulationConnection then
		postSimulationConnection:Disconnect()
		postSimulationConnection = nil
	end

	local v2

	if track then
		v2 = math.max(0, Config.HOLD_PAUSE - track.TimePosition)
		track:AdjustSpeed(1)
	else
		v2 = 0
	end

	task.delay(v2 + Config.END_AT, function()
		if FlashFist.Id ~= id then
			return
		end

		v:Clean()

		if track then
			track:Stop()
			track = nil
		end
	end)
end

function FlashFist.Cancel(_)
	if postSimulationConnection then
		postSimulationConnection:Disconnect()
		postSimulationConnection = nil
	end

	v:Clean()

	if track then
		track:Stop()
		track = nil
	end
end

return FlashFist