local createVector = vector.create
local parent = script.Parent.Parent
local NexusInstance = require(parent:WaitForChild("Packages"):WaitForChild("NexusInstance"))
local typedEvent = NexusInstance.TypedEvent
local VRInputService = {}
VRInputService.__index = VRInputService
local v = nil

function VRInputService.new(p, p2)
	local v2 = {
		RecenterOffset = CFrame.identity,
		ThumbstickValues = {
			[Enum.KeyCode.Thumbstick1] = createVector(0, 0, 0),
			[Enum.KeyCode.Thumbstick2] = createVector(0, 0, 0)
		},
		VRService = p or game:GetService("VRService"),
		UserInputService = p2 or game:GetService("UserInputService"),
		Recentered = typedEvent.new(),
		EyeLevelSet = typedEvent.new()
	}
	local object = setmetatable(v2, VRInputService)
	object.UserInputService.InputEnded:Connect(function(input)
		if object.ThumbstickValues[input.KeyCode] then
			object.ThumbstickValues[input.KeyCode] = createVector(0, 0, 0)
		end
	end)
	object.UserInputService.InputChanged:Connect(function(input)
		if object.ThumbstickValues[input.KeyCode] then
			object.ThumbstickValues[input.KeyCode] = input.Position
		end
	end)
	return object
end

function VRInputService.GetInstance()
	if not v then
		v = VRInputService.new()
	end

	return v
end

function VRInputService:GetVRInputs()
	local result = {
		[Enum.UserCFrame.Head] = self.VRService:GetUserCFrame(Enum.UserCFrame.Head)
	}

	if self.VRService:GetUserCFrameEnabled(Enum.UserCFrame.LeftHand) then
		result[Enum.UserCFrame.LeftHand] = self.VRService:GetUserCFrame(Enum.UserCFrame.LeftHand)
	else
		result[Enum.UserCFrame.LeftHand] = result[Enum.UserCFrame.Head] * CFrame.new(-1, -2.5, 0.5)
	end

	if self.VRService:GetUserCFrameEnabled(Enum.UserCFrame.RightHand) then
		result[Enum.UserCFrame.RightHand] = self.VRService:GetUserCFrame(Enum.UserCFrame.RightHand)
	else
		result[Enum.UserCFrame.RightHand] = result[Enum.UserCFrame.Head] * CFrame.new(1, -2.5, 0.5)
	end

	local v2

	if self.ManualNormalHeadLevel then
		v2 = -self.ManualNormalHeadLevel
	else
		local Y = (result[Enum.UserCFrame.Head] * CFrame.new(0, 0, 0.5)).Y

		if not self.HighestHeadHeight or self.HighestHeadHeight < Y then
			self.HighestHeadHeight = Y
		end

		v2 = -self.HighestHeadHeight
	end

	for _, v3 in { Enum.UserCFrame.Head, Enum.UserCFrame.LeftHand, Enum.UserCFrame.RightHand } do
		result[v3] = CFrame.new(0, v2, 0) * self.RecenterOffset * result[v3]
	end

	return result
end

function VRInputService:Recenter()
	local userCFrame = self.VRService:GetUserCFrame(Enum.UserCFrame.Head)
	self.RecenterOffset = CFrame.Angles(0, -math.atan2(-userCFrame.LookVector.X, -userCFrame.LookVector.Z), 0) * CFrame.new(
		-userCFrame.X,
		0,
		-userCFrame.Z
	)
	self.Recentered:Fire()
end

function VRInputService:SetEyeLevel()
	self.ManualNormalHeadLevel = self.VRService:GetUserCFrame(Enum.UserCFrame.Head).Y
	self.EyeLevelSet:Fire()
end

function VRInputService.GetThumbstickPosition(p, p2)
	return p.ThumbstickValues[p2] or createVector(0, 0, 0)
end

return VRInputService