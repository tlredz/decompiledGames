local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad)
local v = {
	[Enum.UserCFrame.LeftHand] = Enum.KeyCode.Thumbstick1,
	[Enum.UserCFrame.RightHand] = Enum.KeyCode.Thumbstick2
}
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local VRService = game:GetService("VRService")
local parent = script.Parent.Parent.Parent
local module = require(parent)
local api = module.Api
require(parent:WaitForChild("Character"))
local CameraService = require(parent:WaitForChild("State"):WaitForChild("CameraService"))
local instance = CameraService.GetInstance()
local CharacterService = require(parent:WaitForChild("State"):WaitForChild("CharacterService"))
local instance2 = CharacterService.GetInstance()
local Settings = require(parent:WaitForChild("State"):WaitForChild("Settings"))
local instance3 = Settings.GetInstance()
local VRInputService = require(parent:WaitForChild("State"):WaitForChild("VRInputService"))
local instance4 = VRInputService.GetInstance()
local BaseController = {}
BaseController.__index = BaseController

-- equivalent calls inferred from this helper; original call sites unknown
local function GetAngleToGlobalY(cframe: CFrame)
	return (math.atan2(-cframe.LookVector.X, -cframe.LookVector.Z))
end

function BaseController.new()
	return (setmetatable({
		Active = false,
		ActionsToLock = { Enum.KeyCode.ButtonR3 }
	}, BaseController))
end

function BaseController:UpdateCharacterReference()
	local character = self.Character
	self.Character = instance2:GetCharacter(Players.LocalPlayer)

	if self.Character then
		return character ~= self.Character
	end

	return false
end

function BaseController:Enable()
	if not self.Connections then
		self.Connections = {}
	end

	self.Active = true

	if not self.ActionsToUnbind then
		self.ActionsToUnbind = {}
	end

	for _, v2 in self.ActionsToLock do
		local GUID = HttpService:GenerateGUID()
		ContextActionService:BindActionAtPriority(GUID, function()
			return self.Active and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
		end, false, Enum.ContextActionPriority.High.Value, v2)
		table.insert(self.ActionsToUnbind, GUID)
	end

	self:UpdateCharacterReference()

	if not self.Character then
		return
	end

	local connections = self.Connections
	table.insert(connections, (instance4.EyeLevelSet:Connect(function()
		local lastHeadCFrame = self.LastHeadCFrame

		if lastHeadCFrame and lastHeadCFrame.Y > 0 then
			self.LastHeadCFrame = CFrame.new(0, -lastHeadCFrame.Y, 0) * lastHeadCFrame
		end
	end)))
	table.insert(connections, self.Character.Humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
		if self.Character:GetHumanoidSeatPart() then
			self:PlayBlur()
			instance4:Recenter()
		end
	end))
	self.Character.Humanoid.AutoRotate = false
end

function BaseController:Disable()
	self.Active = false
	self.Character = nil
	self.LastHeadCFrame = nil
	self.LastRotationUpdateTick = nil

	if self.Connections then
		for _, connection in self.Connections do
			connection:Disconnect()
		end
	end

	if self.ActionsToUnbind then
		for _, v2 in self.ActionsToUnbind do
			ContextActionService:UnbindAction(v2)
		end
	end

	self.Connections = nil
end

function BaseController:ScaleInput(cframe: CFrame)
	if self.Character and cframe then
		return CFrame.new(cframe.Position * (self.Character:GetHumanoidScale("BodyHeightScale") - 1)) * cframe
	end

	return cframe
end

function BaseController.GetJoystickState(_, state)
	local thumbstickPosition = instance4:GetThumbstickPosition(state.Thumbstick)
	local v2 = (thumbstickPosition.X ^ 2 + thumbstickPosition.Y ^ 2) ^ 0.5
	local v3 = math.atan2(thumbstickPosition.X, thumbstickPosition.Y)
	local directionState

	if v3 >= -2.356194490192345 and v3 <= -0.7853981633974483 then
		directionState = "Left"
	elseif v3 >= -0.7853981633974483 and v3 <= 0.7853981633974483 then
		directionState = "Forward"
	elseif v3 >= 0.7853981633974483 and v3 <= 2.356194490192345 then
		directionState = "Right"
	else
		directionState = nil
	end

	local v5 = v2 >= 0.6 and "Extended" or v2 <= 0.4 and "Released" or "InBetween"
	local v6 = nil

	if v5 == "Released" then
		local v7 = state.RadiusState == "Extended" and "Released" or v6
		state.RadiusState = "Released"
		state.DirectionState = nil
		return directionState, "Released", v7
	else
		if v5 ~= "Extended" then
			return directionState, v5, v6
		end

		if state.RadiusState == nil or state.RadiusState == "Released" then
			local v7 = state.RadiusState ~= "Extended" and "Extended" or v6
			state.RadiusState = "Extended"
			state.DirectionState = directionState
			return directionState, v5, v7
		else
			if state.DirectionState ~= directionState then
				v6 = state.RadiusState ~= "Cancelled" and "Cancel" or v6
				state.RadiusState = "Cancelled"
				state.DirectionState = nil
			end

			return directionState, v5, v6
		end
	end
end

function BaseController:PlayBlur()
	local setting = instance3:GetSetting("Movement.SnapTeleportBlur")

	if setting ~= nil and not setting then
		return
	end

	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Parent = workspace.CurrentCamera
	blurEffect.Size = 56
	local tween = TweenService:Create(blurEffect, tweenInfo, {
		Size = 0
	})
	tween:Play()
	tween.Completed:Connect(function()
		blurEffect:Destroy()
	end)
end

function BaseController:UpdateCharacter()
	local v2 = self:UpdateCharacterReference()

	if not self.Character then
		return
	end

	if v2 then
		self:Enable()
	end

	local vRInputs = instance4:GetVRInputs()
	local cframe = self:ScaleInput(vRInputs[Enum.UserCFrame.Head])
	local scaleInput = self:ScaleInput(vRInputs[Enum.UserCFrame.LeftHand])
	local scaleInput2 = self:ScaleInput(vRInputs[Enum.UserCFrame.RightHand])
	local v3 = cframe:Inverse() * scaleInput
	local v4 = cframe:Inverse() * scaleInput2

	if self.Character:GetHumanoidSeatPart() then
		self.Character:UpdateFromInputsSeated(cframe, cframe * v3, cframe * v4)
	elseif self.LastHeadCFrame then
		local v5 = self.Character.Parts.HumanoidRootPart.CFrame * self.Character.Attachments.HumanoidRootPart.RootRigAttachment.CFrame * CFrame.new(
			0,
			-self.Character.Motors.Root.Transform.Position.Y,
			0
		) * self.Character.Motors.Root.Transform * self.Character.Attachments.LowerTorso.RootRigAttachment.CFrame:Inverse() * self.Character.Attachments.LowerTorso.WaistRigAttachment.CFrame * self.Character.Motors.Waist.Transform * self.Character.Attachments.UpperTorso.WaistRigAttachment.CFrame:Inverse() * self.Character.Attachments.UpperTorso.NeckRigAttachment.CFrame * self.Character.Motors.Neck.Transform * self.Character.Attachments.Head.NeckRigAttachment.CFrame:Inverse()
		local eyesOffset = self.Character.Head:GetEyesOffset()
		local v6 = v5 * eyesOffset
		local v7 = self.LastHeadCFrame:Inverse() * cframe

		if cframe.UpVector.Y < 0 then
			v7 = CFrame.Angles(0, 3.141592653589793, 0) * v7
		end

		local v8 = (CFrame.new(cframe.Position) * CFrame.Angles(
			0,
			math.atan2(-cframe.LookVector.X, -cframe.LookVector.Z),
			0
		)):Inverse() * cframe
		local angleToGlobalY = GetAngleToGlobalY(self.LastHeadCFrame) -- equivalent call inferred; original call site unknown
		local angleToGlobalY2 = GetAngleToGlobalY(cframe) -- equivalent call inferred; original call site unknown
		local cframe2 = CFrame.new(0, (CFrame.new(0, eyesOffset.Y, 0) * (cframe * eyesOffset:Inverse())).Y, 0)
		local angleToGlobalY3 = GetAngleToGlobalY(v6) -- equivalent call inferred; original call site unknown
		local cframe3 = CFrame.Angles(0, angleToGlobalY3 + (angleToGlobalY2 - angleToGlobalY), 0)
		local position = (cframe2 * CFrame.new((cframe3 * CFrame.new(v7.X, 0, v7.Z)).Position) * v6).Position
		local v12 = CFrame.new(position) * cframe3 * v8
		self.Character:UpdateFromInputs(v12, v12 * v3, v12 * v4)
	end

	if self.Character.Parts.HumanoidRootPart:IsDescendantOf(Workspace) and self.Character.Humanoid.Health > 0 then
		instance:UpdateCamera(self.Character.Parts.HumanoidRootPart.CFrame * self.Character.Attachments.HumanoidRootPart.RootRigAttachment.CFrame * self.Character.Motors.Root.Transform * self.Character.Attachments.LowerTorso.RootRigAttachment.CFrame:Inverse() * self.Character.Attachments.LowerTorso.WaistRigAttachment.CFrame * self.Character.Motors.Waist.Transform * self.Character.Attachments.UpperTorso.WaistRigAttachment.CFrame:Inverse() * self.Character.Attachments.UpperTorso.NeckRigAttachment.CFrame * self.Character.Motors.Neck.Transform * self.Character.Attachments.Head.NeckRigAttachment.CFrame:Inverse() * self.Character.Head:GetEyesOffset())
		self.LastHeadCFrame = cframe
	elseif not Workspace.CurrentCamera.HeadLocked then
		local renderCFrame = Workspace.CurrentCamera:GetRenderCFrame()
		local lastHeadCFrame = self.LastHeadCFrame or CFrame.new()
		local scaleInput3 = self:ScaleInput(instance4:GetVRInputs()[Enum.UserCFrame.Head])
		instance:UpdateCamera(renderCFrame * lastHeadCFrame:Inverse() * scaleInput3)
		self.LastHeadCFrame = scaleInput3
	end
end

function BaseController:UpdateRotating(p, p2: string, p3: string)
	if VRService.AvatarGestures then
		self.LastRotationUpdateTick = nil
		return
	end

	if not self.Character or self.Character.Humanoid.Sit then
		self.LastRotationUpdateTick = nil
		return
	end

	if p2 ~= "Left" and p2 ~= "Right" then
		self.LastRotationUpdateTick = nil
		return
	end

	if api.Controller and not api.Controller:IsControllerInputEnabled(p) then
		return
	end

	local humanoidRootPart = self.Character.Parts.HumanoidRootPart
	local UserGameSettings = UserSettings():GetService("UserGameSettings")

	if UserGameSettings.VRSmoothRotationEnabled then
		local thumbstickPosition = instance4:GetThumbstickPosition(v[p])

		if not (math.abs(thumbstickPosition.X) >= 0.2) then
			self.LastRotationUpdateTick = nil
			return
		end

		local lastRotationUpdateTick = self.LastRotationUpdateTick or tick()
		local now = tick()
		local v2 = now - lastRotationUpdateTick
		humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(
			0,
			-thumbstickPosition.X * 6.283185307179586 * v2,
			0
		) * (CFrame.new(-humanoidRootPart.Position) * humanoidRootPart.CFrame)
		self.LastRotationUpdateTick = now
	elseif p3 == "Extended" then
		if p2 == "Left" then
			self:PlayBlur()
			humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, 0.5235987755982988, 0) * (CFrame.new(-humanoidRootPart.Position) * humanoidRootPart.CFrame)
		elseif p2 == "Right" then
			self:PlayBlur()
			humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, -0.5235987755982988, 0) * (CFrame.new(-humanoidRootPart.Position) * humanoidRootPart.CFrame)
		end
	end
end

return BaseController