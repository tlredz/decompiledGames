local createVector = vector.create
local RunService = game:GetService("RunService")
local Component = require(game.ReplicatedStorage.Modules.Component)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local v = Component.new({
	Tag = "BasicMob"
})

local function readFootstepSounds(instance)
	local footstepSounds = instance:GetAttribute("FootstepSounds")

	if typeof(footstepSounds) ~= "string" then
		return nil
	end

	local result = {}

	for k in string.gmatch(footstepSounds, "[^;]+") do
		table.insert(result, k)
	end

	if #result > 0 then
		return result
	end

	return nil
end

function v:Construct()
	local instance = self.Instance
	self.footstepSounds = readFootstepSounds(instance)
	local footstepStride = instance:GetAttribute("FootstepStride")
	self.footstepStride = (typeof(footstepStride) ~= "number" or not (footstepStride > 0)) and 6 or footstepStride
	self.footstepDistance = 0
end

function v:StepFootsteps(p: number)
	local instance = self.Instance
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local humanoid = instance:FindFirstChildWhichIsA("Humanoid")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoid) then
		return
	end

	if humanoid.FloorMaterial == Enum.Material.Air or humanoid.Health <= 0 then
		self.footstepDistance = 0
		return
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera and (currentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 150 then
		return
	end

	local magnitude = (humanoidRootPart.AssemblyLinearVelocity * createVector(1, 0, 1)).Magnitude

	if magnitude < 0.5 then
		self.footstepDistance = 0
		return
	end

	self.footstepDistance += magnitude * p

	if self.footstepDistance < self.footstepStride then
		return
	end

	self.footstepDistance -= self.footstepStride
	Sound:Play(self.footstepSounds[math.random(1, #self.footstepSounds)], humanoidRootPart.Position, {
		group = "LowPriority"
	})
end

function v:Start()
	if not self.footstepSounds then
		return
	end

	self.footstepConnection = RunService.Heartbeat:Connect(function(dt: number)
		self:StepFootsteps(dt)
	end)
end

function v:Stop()
	if self.footstepConnection then
		self.footstepConnection:Disconnect()
		self.footstepConnection = nil
	end
end

return v