local createVector = vector.create
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")
local parent = script.Parent.Parent
local Enigma = require(parent:WaitForChild("Packages"):WaitForChild("Enigma"))
local Head = require(parent:WaitForChild("Character"):WaitForChild("Head"))
local EnigmaService = {}
EnigmaService.__index = EnigmaService
local v = nil

function EnigmaService.new()
	return (setmetatable({
		Offsets = {}
	}, EnigmaService))
end

function EnigmaService.GetInstance()
	if not v then
		v = EnigmaService.new()
	end

	return v
end

function EnigmaService.GetCFrames(p, p2)
	if not Enigma.Enabled then
		return {}
	end

	local v2 = p2.Parts.Head.CFrame * p2.Head:GetEyesOffset() * UserInputService:GetUserCFrame(Enum.UserCFrame.Head):Inverse()
	local userCFrame = Enigma:GetUserCFrame("LeftFoot")
	local userCFrame2 = Enigma:GetUserCFrame("RightFoot")
	local v3 = {}

	if userCFrame and p.Offsets.LeftFoot then
		v3.LeftFoot = v2 * userCFrame * p.Offsets.LeftFoot
	end

	if userCFrame2 and p.Offsets.RightFoot then
		v3.RightFoot = v2 * userCFrame2 * p.Offsets.RightFoot
	end

	return v3
end

function EnigmaService.Calibrate(p, p2)
	if not Enigma.Enabled then
		return
	end

	local userCFrame = Enigma:GetUserCFrame("LeftFoot")
	local userCFrame2 = Enigma:GetUserCFrame("RightFoot")

	if not (userCFrame or userCFrame2) then
		return
	end

	local attachments = p2.Attachments
	local renderCFrame = Workspace.CurrentCamera:GetRenderCFrame()
	local v2 = renderCFrame * UserInputService:GetUserCFrame(Enum.UserCFrame.Head):Inverse()
	local v3 = v2 * UserInputService:GetUserCFrame(Enum.UserCFrame.Floor)
	local v4 = Head.new(p2.Parts.Head)
	local v5 = v4:GetNeckCFrame((v4:GetHeadCFrame(renderCFrame))) * attachments.UpperTorso.NeckRigAttachment.CFrame:Inverse() * attachments.UpperTorso.WaistRigAttachment.CFrame * attachments.LowerTorso.WaistRigAttachment.CFrame:Inverse()

	if userCFrame then
		local cframe = v2 * userCFrame
		local v6 = v5 * attachments.LowerTorso.LeftHipRigAttachment.CFrame * attachments.LeftUpperLeg.LeftHipRigAttachment.CFrame:Inverse() * attachments.LeftUpperLeg.LeftKneeRigAttachment.CFrame * attachments.LeftLowerLeg.LeftKneeRigAttachment.CFrame:Inverse() * attachments.LeftLowerLeg.LeftAnkleRigAttachment.CFrame * attachments.LeftFoot.LeftAnkleRigAttachment.CFrame:Inverse()
		local v7 = v6 * attachments.LeftFoot.LeftFootAttachment.CFrame
		local v8 = CFrame.new(0, v3.Y - v7.Y, 0) * v6
		p.Offsets.LeftFoot = cframe:Inverse() * v8
	end

	if userCFrame2 then
		local cframe = v2 * userCFrame2
		local v6 = v5 * attachments.LowerTorso.RightHipRigAttachment.CFrame * attachments.RightUpperLeg.RightHipRigAttachment.CFrame:Inverse() * attachments.RightUpperLeg.RightKneeRigAttachment.CFrame * attachments.RightLowerLeg.RightKneeRigAttachment.CFrame:Inverse() * attachments.RightLowerLeg.RightAnkleRigAttachment.CFrame * attachments.RightFoot.RightAnkleRigAttachment.CFrame:Inverse()
		local v7 = v6 * attachments.RightFoot.RightFootAttachment.CFrame
		local v8 = CFrame.new(0, v3.Y - v7.Y, 0) * v6
		p.Offsets.RightFoot = cframe:Inverse() * v8
	end
end

function EnigmaService:Enable()
	Enigma:Enable()
	local position = createVector(0, 0, 0)
	local flag = false
	UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.ButtonA then
			flag = true
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Thumbstick1 then
			if input.Position.Magnitude > 0.2 then
				position = input.Position
			else
				position = createVector(0, 0, 0)
			end
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Thumbstick1 then
			position = createVector(0, 0, 0)
		elseif input.KeyCode == Enum.KeyCode.ButtonA then
			flag = false
		end
	end)
	RunService:BindToRenderStep("EnigmaCustomMovement", Enum.RenderPriority.Input.Value + 1, function()
		if not Enigma:IsActive() then
			return
		end

		local character = Players.LocalPlayer.Character

		if not character then
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if not humanoid or humanoid.Health <= 0 then
			return
		end

		local renderCFrame = Workspace.CurrentCamera:GetRenderCFrame()
		local position2 = (CFrame.new(-renderCFrame.Position) * renderCFrame * CFrame.new(position.X, 0, -position.Y)).Position

		if position2.Magnitude > 0.01 or not VRService.AvatarGestures then
			Players.LocalPlayer:Move(position2, false)
		end

		if flag then
			humanoid.Jump = true
		end
	end)
end

return EnigmaService