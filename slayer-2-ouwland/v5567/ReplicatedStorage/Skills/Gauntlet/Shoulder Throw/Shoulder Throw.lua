local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local Utility = require(CAM.Global.Utility)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local Config = require(script.Parent.Config)
local ShoulderThrow = {
	Id = 0
}
local shoulderThrowStartup = script.ShoulderThrowStartup
local postSimulationConnection = nil

function ShoulderThrow.Hold(player)
	v:Clean()

	if postSimulationConnection then
		postSimulationConnection:Disconnect()
		postSimulationConnection = nil
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (animator and humanoidRootPart) then
		return
	end

	local id = ShoulderThrow.Id
	local track = animator:LoadAnimation(shoulderThrowStartup)
	v:Add(track)
	track:Play()
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
		if ShoulderThrow.Id ~= id then
			return
		end

		local mousepos2 = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			Vector3.new(mousepos2.X, humanoidRootPart.Position.Y, mousepos2.Z),
			alignOrientationWithAttachment.CFrame
		)
	end)
	task.wait(0.6833333333333333)

	if ShoulderThrow.Id ~= id then
		return
	end

	if postSimulationConnection then
		postSimulationConnection:Disconnect()
		postSimulationConnection = nil
	end

	alignOrientationWithAttachment:Destroy()
	v2:Destroy()
	task.wait(1.3833333333333335)

	if ShoulderThrow.Id ~= id then
		return
	end

	v:Clean()
end

function ShoulderThrow.UnHold(_) end

function ShoulderThrow.Cancel(_)
	if postSimulationConnection then
		postSimulationConnection:Disconnect()
		postSimulationConnection = nil
	end

	v:Clean()
end

return ShoulderThrow