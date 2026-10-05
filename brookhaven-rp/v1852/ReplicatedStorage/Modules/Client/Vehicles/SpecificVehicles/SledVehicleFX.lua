local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "SledVehicleFX"
})

function v:Construct()
	self._Janitor = Janitor.new()
	local value = self.Instance:WaitForChild("PlayerObject").Value

	if not value then
		return
	end

	local character = value.Character

	if not character then
		return
	end

	local middle = self.Instance:WaitForChild("Middle")
	self.engineSound = middle:WaitForChild("Engine")
	local leftTrail = middle:WaitForChild("LeftTrail")
	local rightTrail = middle:WaitForChild("RightTrail")
	self.leftTrail = leftTrail
	self.rightTrail = rightTrail
	self.bottomCenterAttachment = middle:WaitForChild("BottomCenter")
	local snowEmitterPart = middle:WaitForChild("SnowEmitterPart")
	local L = snowEmitterPart:WaitForChild("L")
	local R = snowEmitterPart:WaitForChild("R")
	local snow = L:WaitForChild("Snow")
	local snow2 = R:WaitForChild("Snow")
	self.snowEmitter1 = snow
	self.snowEmitter2 = snow2
	self.humanoid = character:WaitForChild("Humanoid")
	self.humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end

function v:Start()
	local _ = self.humanoid
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { self.Instance, self.humanoidRootPart.Parent }
	raycastParams.RespectCanCollide = true
	local _, _ = self.Instance:GetBoundingBox()
	self._Janitor:Add(RunService.Stepped:Connect(function(_, _: number)
		local magnitude = self.humanoidRootPart.AssemblyLinearVelocity.Magnitude
		local playbackSpeed = math.clamp(magnitude / 80, 0.8, 2)

		if workspace:Raycast(
			self.bottomCenterAttachment.WorldPosition,
			-self.bottomCenterAttachment.WorldCFrame.UpVector,
			raycastParams
		) and magnitude > 5 then
			if not self.snowEmitter1.Enabled then
				self.snowEmitter1.Enabled = true
				self.leftTrail.Enabled = true
			end

			if not self.snowEmitter2.Enabled then
				self.snowEmitter2.Enabled = true
				self.rightTrail.Enabled = true
			end

			self.snowEmitter1.Rate = math.clamp(magnitude * 200 / 50, 10, 200)
			self.snowEmitter2.Rate = math.clamp(magnitude * 200 / 50, 10, 200)
		else
			if self.snowEmitter1.Enabled then
				self.snowEmitter1.Enabled = false
				self.leftTrail.Enabled = false
			end

			if self.snowEmitter2.Enabled then
				self.snowEmitter2.Enabled = false
				self.rightTrail.Enabled = false
			end
		end

		if magnitude < 5 then
			self.engineSound.Volume = 0

			if self.engineSound.IsPlaying then
				self.engineSound:Stop()
			end
		else
			self.engineSound.PlaybackSpeed = playbackSpeed
			self.engineSound.Volume = 0.3

			if not self.engineSound.IsPlaying then
				self.engineSound:Play()
			end
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v