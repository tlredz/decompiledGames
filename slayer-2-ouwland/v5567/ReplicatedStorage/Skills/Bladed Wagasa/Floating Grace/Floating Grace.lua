local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local DebrisModule = require(CAM.DebrisModule)
local Utility = require(CAM.Global.Utility)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local Config = require(script.Parent.Config)
local FloatingGrace = {
	Id = 0,
	holdStart = 0
}
local skill_stand_still = skills.holder.skill_stand_still
local floatingGraceStartup = script.FloatingGraceStartup
local floatingGraceRelease = script.FloatingGraceRelease
local umbrellaStartup = script.UmbrellaStartup
local umbrellaRelease = script.UmbrellaRelease
local postSimulationConnection = nil

function FloatingGrace.Hold(player)
	maid:Clean()

	if postSimulationConnection then
		postSimulationConnection:Disconnect()
		postSimulationConnection = nil
	end

	FloatingGrace.holdStart = os.clock()
	local id = FloatingGrace.Id
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (animator and humanoidRootPart) then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", Config.MAX_DURATION))
	local clone = skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	DebrisModule:AddItem(clone, Config.MAX_DURATION + 0.2)
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local alignOrientationWithAttachment, v = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.AllAxes,
			Responsiveness = 70,
			MaxTorque = 500000,
			CFrame = Utility.SafeLookAt(humanoidRootPart.Position, mousepos, humanoidRootPart.CFrame)
		}
	)
	maid:Add(alignOrientationWithAttachment)
	maid:Add(v)
	DebrisModule:AddItem(alignOrientationWithAttachment, Config.MAX_DURATION)
	DebrisModule:AddItem(v, Config.MAX_DURATION)
	postSimulationConnection = RunService.PostSimulation:Connect(function()
		if FloatingGrace.Id == id then
			local mousepos2 = Platform_Handler.mousepos(Config.MOUSE_RANGE)
			alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				mousepos2,
				alignOrientationWithAttachment.CFrame
			)
		elseif postSimulationConnection then
			postSimulationConnection:Disconnect()
			postSimulationConnection = nil
		end
	end)
	local track = animator:LoadAnimation(floatingGraceStartup)
	maid:Add(track)
	track:Play()
	task.delay(Config.DEPLOY_DELAY, function()
		if FloatingGrace.Id ~= id then
			return
		end

		if track.IsPlaying then
			track:AdjustSpeed(0)
		end
	end)
	local track2 = animator:LoadAnimation(umbrellaStartup)
	track2:Play()
	maid:Add(track2)
	task.wait(Config.DEPLOY_DELAY + 0.05)
end

function FloatingGrace.UnHold(player)
	if postSimulationConnection then
		postSimulationConnection:Disconnect()
		postSimulationConnection = nil
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if animator == nil then
		maid:Clean()
		return true
	end

	maid:Clean()
	local track = animator:LoadAnimation(floatingGraceRelease)
	maid:Add(track)
	track:Play()
	local track2 = animator:LoadAnimation(umbrellaRelease)
	track2:Play()
	maid:Add(track2)
	return true
end

function FloatingGrace.Cancel(_)
	if postSimulationConnection then
		postSimulationConnection:Disconnect()
		postSimulationConnection = nil
	end

	maid:Clean()
end

return FloatingGrace