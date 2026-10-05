local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "CharacterSnowPrints"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.footPrintsModel = ReplicatedStorage:WaitForChild("SnowPrints"):WaitForChild(self.Instance.Name)
	self.humanoid = self.Instance:WaitForChild("Humanoid")
	self.humanoidRootPart = self.Instance:WaitForChild("HumanoidRootPart")
	self.snowPrints = {}
	self.raycastParams = RaycastParams.new()
	self.raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	self.raycastParams.FilterDescendantsInstances = { self.Instance }
	self.raycastParams.RespectCanCollide = false

	for _, part in self.footPrintsModel:GetChildren() do
		if part:IsA("BasePart") then
			table.insert(self.snowPrints, part)
		end
	end

	self._Janitor:Add(self.footPrintsModel.ChildAdded:Connect(function(part)
		if part:IsA("BasePart") then
			table.insert(self.snowPrints, part)
		end
	end))
	self._Janitor:Add(self.footPrintsModel.ChildRemoved:Connect(function(child)
		for k, snowPrint in self.snowPrints do
			if snowPrint ~= child then
				continue
			end

			table.remove(self.snowPrints, k)
			break
		end
	end))
end

function v:CreateSnowPrint(instance)
	local v2 = table.remove(self.snowPrints, 1)

	if not v2 then
		return
	end

	local raycastResult = workspace:Raycast(
		instance.Position + instance.CFrame.UpVector,
		-instance.CFrame.UpVector * 3,
		self.raycastParams
	)

	if not raycastResult then
		table.insert(self.snowPrints, v2)
		return
	end

	self.humanoidRootPart.Running.PlaybackSpeed = 1.1
	self.humanoidRootPart.Running.SoundId = "rbxassetid://79017765559990"
	local lookVector = self.humanoidRootPart.CFrame.LookVector
	local normal = raycastResult.Normal
	local position = raycastResult.Position
	local cross = normal:Cross((Vector3.new(lookVector.X, 0, lookVector.Z))):Cross(normal)

	if cross.Magnitude < 0.0001 then
		cross = normal:Cross(createVector(1, 0, 0))

		if cross.Magnitude < 0.0001 then
			cross = normal:Cross(createVector(0, 0, 1))
		end
	end

	local unit = cross.Unit
	local unit2 = normal:Cross(unit).Unit
	v2.CFrame = CFrame.fromMatrix(position + normal * 0.02, unit2, normal, -unit)
	v2.Transparency = 0.4
	v2.Parent = workspace
	TweenService:Create(v2, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
		Transparency = 1
	}):Play()
	task.delay(1.1, function()
		v2.Parent = self.footPrintsModel
		table.insert(self.snowPrints, v2)
	end)
end

function v:RevertToDefault()
	self.humanoidRootPart.Running.PlaybackSpeed = 1.85
	self.humanoidRootPart.Running.SoundId = "rbxasset://sounds/action_footsteps_plastic.mp3"
end

function v:Start()
	local humanoid = self.humanoid
	local v2 = nil
	self._Janitor:Add(humanoid.Touched:Connect(function(otherPart, p)
		if p.Name ~= "LeftFoot" and p.Name ~= "RightFoot" or v2 and v2 == p or humanoid.MoveDirection.Magnitude <= 0.1 then
			return
		end

		local state = humanoid:GetState()

		if state ~= Enum.HumanoidStateType.Running and state ~= Enum.HumanoidStateType.RunningNoPhysics then
			return
		end

		if otherPart.Material ~= Enum.Material.Snow and otherPart.MaterialVariant ~= "Snow" and otherPart.Name ~= "Snow" and otherPart.Name ~= "SnowGrass" then
			self:RevertToDefault()
			return
		end

		v2 = p
		self:CreateSnowPrint(p)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v