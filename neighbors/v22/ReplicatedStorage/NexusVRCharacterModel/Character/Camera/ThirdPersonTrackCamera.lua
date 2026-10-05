local Players = game:GetService("Players")
local parent = script.Parent.Parent.Parent
local CommonCamera = require(parent:WaitForChild("Character"):WaitForChild("Camera"):WaitForChild("CommonCamera"))
local ThirdPersonTrackCamera = {}
ThirdPersonTrackCamera.__index = ThirdPersonTrackCamera
setmetatable(ThirdPersonTrackCamera, CommonCamera)

function ThirdPersonTrackCamera.new()
	return (setmetatable(CommonCamera.new(), ThirdPersonTrackCamera))
end

function ThirdPersonTrackCamera:Enable()
	self.FetchInitialCFrame = true
end

function ThirdPersonTrackCamera:Disable()
	self.FetchInitialCFrame = nil
end

function ThirdPersonTrackCamera:UpdateCamera(cframe: CFrame)
	if self.FetchInitialCFrame then
		local baseFaceAngleY = math.atan2(-cframe.LookVector.X, -cframe.LookVector.Z)
		self.BaseFaceAngleY = baseFaceAngleY
		self.BaseCFrame = CFrame.new(cframe.Position) * CFrame.Angles(0, baseFaceAngleY, 0)
		self.FetchInitialCFrame = nil
	end

	local value = 1
	local character = Players.LocalPlayer.Character

	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			local bodyHeightScale = humanoid:FindFirstChild("BodyHeightScale")

			if bodyHeightScale then
				value = bodyHeightScale.Value
			end
		end
	end

	local baseCFrame = self.BaseCFrame
	local v = baseCFrame:Inverse() * cframe
	self:SetCFrame(baseCFrame * CFrame.new(0, 0, value * -10) * CFrame.Angles(0, 3.141592653589793, 0) * v)
end

return ThirdPersonTrackCamera