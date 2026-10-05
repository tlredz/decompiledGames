local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local Utility = require(CAM.Global.Utility)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local Config = require(script.Parent.Config)
local PhantomBarrage = {
	Id = 0
}
local phantomBarrage = script.PhantomBarrage
local postSimulationConnection = nil

function PhantomBarrage.Hold(player)
	v:Clean()

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

	local id = PhantomBarrage.Id
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
		if PhantomBarrage.Id ~= id then
			return
		end

		local mousepos2 = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			Vector3.new(mousepos2.X, humanoidRootPart.Position.Y, mousepos2.Z),
			alignOrientationWithAttachment.CFrame
		)
	end)
	local track = animator:LoadAnimation(phantomBarrage)
	v:Add(track)
	track:Play()
	track:AdjustSpeed(Config.WINDUP_SPEED)
	task.wait(Config.BARRAGE_AT)

	if PhantomBarrage.Id ~= id then
		return
	end

	track:AdjustSpeed(1)
	task.wait(Config.END_AT - Config.BARRAGE_AT)

	if PhantomBarrage.Id ~= id then
		return
	end

	if postSimulationConnection then
		postSimulationConnection:Disconnect()
		postSimulationConnection = nil
	end

	v:Clean()
end

function PhantomBarrage.UnHold(_) end

function PhantomBarrage.Cancel(_)
	if postSimulationConnection then
		postSimulationConnection:Disconnect()
		postSimulationConnection = nil
	end

	v:Clean()
end

return PhantomBarrage