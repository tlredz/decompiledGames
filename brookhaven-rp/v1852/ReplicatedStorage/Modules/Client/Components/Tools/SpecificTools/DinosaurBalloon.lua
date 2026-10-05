local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v = Component.new({
	Tag = "DinosaurBalloon",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = self._Janitor:Add(Janitor.new())
	self._isEquipped = false
	self._dinoMesh = self.Instance:WaitForChild("Dino")
	self._dinoMesh.Anchored = true
	self._dinoMesh.Transparency = 1
	self._dinoMesh.Beam.Enabled = false
end

function v:_onEquipped()
	if self._isEquipped then
		return
	end

	self._isEquipped = true
	local parent = self.Instance.Parent
	local rightHand = parent:FindFirstChild("RightHand")

	if not rightHand then
		return
	end

	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local clone = self._dinoMesh:Clone()
	clone.Transparency = 0
	clone.Beam.Enabled = true
	clone.Anchored = false
	clone.CanCollide = false
	clone.Parent = workspace
	self._equipJanitor:Add(clone)
	local position = rightHand.Position + createVector(0, 3.5, 0)
	local cframe = CFrame.lookAt(createVector(0, 0, 0), humanoidRootPart.CFrame.LookVector)
	clone.Position = position
	local bodyPosition = Instance.new("BodyPosition")
	bodyPosition.D = 10
	bodyPosition.P = 100
	bodyPosition.Position = position
	bodyPosition.Parent = clone
	self._equipJanitor:Add(bodyPosition)
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.D = 10
	bodyGyro.P = 100
	bodyGyro.CFrame = cframe
	bodyGyro.MaxTorque = createVector(1e999, 1e999, 1e999)
	bodyGyro.Parent = clone
	self._equipJanitor:Add(bodyGyro)
	self._equipJanitor:Add(RunService.Heartbeat:Connect(function()
		local position2 = rightHand.Position + createVector(0, 3.5, 0)

		if (clone.Position - position2).Magnitude > 50 then
			clone.Position = position2
		end

		bodyPosition.Position = position2
		bodyGyro.CFrame = CFrame.lookAt(createVector(0, 0, 0), humanoidRootPart.CFrame.LookVector)
	end))
end

function v:_onUnequipped()
	self._isEquipped = false
	self._equipJanitor:Cleanup()
end

function v:Start()
	self._Janitor:Add(self.Instance.Equipped:Connect(function()
		self:_onEquipped()
	end))
	self._Janitor:Add(self.Instance.Unequipped:Connect(function()
		self:_onUnequipped()
	end))

	if self.Instance.Parent:FindFirstChildOfClass("Humanoid") then
		self:_onEquipped()
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v