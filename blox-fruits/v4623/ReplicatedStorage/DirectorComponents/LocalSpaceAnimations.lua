local createVector = vector.create
local class = {}
class.__index = class
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Director"))

local function UnweldIfNeeded(folder)
	local descendants = folder:GetDescendants()
	local weldConstraints = {}

	for _, weldConstraint in ipairs(descendants) do
		if weldConstraint:IsA("WeldConstraint") and CollectionService:HasTag(weldConstraint, "UnweldLocally") then
			weldConstraints[#weldConstraints + 1] = weldConstraint
		end
	end

	for _, v in ipairs(weldConstraints) do
		v:Destroy()
	end
end

function class:Init()
	local vWorldStorm = self.Instance:WaitForChild("VWorldStorm")
	self.TagAddedConnection = CollectionService:GetInstanceAddedSignal("LocalSpaceRotation"):Connect(function(p)
		self.ObjectInfoQueue[p] = true
	end)
	self.TagRemovedConnection = CollectionService:GetInstanceRemovedSignal("LocalSpaceRotation"):Connect(function(p)
		if self.ObjectInfo[p] then
			self.ObjectInfo[p] = nil

			if self.ObjectInfoQueue[p] then
				self.ObjectInfoQueue[p] = nil
			end
		end
	end)

	for _, v in pairs(CollectionService:GetTagged("LocalSpaceRotation")) do
		if v:IsDescendantOf(vWorldStorm) then
			self:SetUpObject(v)
		end
	end

	self.HeartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		self:Update(dt)
	end)
end

function class:Destroy()
	if self.TagAddedConnection then
		self.TagAddedConnection:Disconnect()
	end

	if self.TagRemovedConnection then
		self.TagRemovedConnection:Disconnect()
	end

	if self.HeartbeatConnection then
		self.HeartbeatConnection:Disconnect()
	end
end

function class:SetUpObject(model)
	if not model:FindFirstChild("Speed") then
		return false
	end

	local delay = model:FindFirstChild("Delay")

	if not delay then
		return false
	end

	local axis = model:FindFirstChild("Axis")

	if not axis then
		return false
	end

	local parent = model.Parent

	if not parent then
		return false
	end

	local v

	if parent:IsA("Model") then
		if not parent.PrimaryPart then
			return false
		end

		v = parent.PrimaryPart.CFrame:Inverse()
	else
		v = parent.CFrame:Inverse()
	end

	local cFrame

	if model:IsA("Model") then
		cFrame = model.PrimaryPart.CFrame
	else
		cFrame = model.CFrame
	end

	local value = delay.Value
	local curAngle = value == 0 and 0 or 6.283185307179586 / (12 * value)
	local axisMask = not (axis.Value.Magnitude > 1e-6) and createVector(1, 0, 0) or axis.Value.Unit
	UnweldIfNeeded(model.Parent)
	self.ObjectInfo[model] = {
		origLocalCFrame = v * cFrame,
		timeToAngle = 6.283185307179586 / (12 * model.Speed.Value),
		curAngle = curAngle,
		axisMask = axisMask
	}
	return true
end

function class:Update(p: number)
	for k, _ in pairs(self.ObjectInfoQueue) do
		if self:SetUpObject(k) then
			self.ObjectInfoQueue[k] = nil
		end
	end

	for model, v in pairs(self.ObjectInfo) do
		local parent = model.Parent

		if not parent then
			continue
		end

		local cFrame

		if parent:IsA("Model") then
			if not parent.PrimaryPart then
				continue
			end

			cFrame = parent.PrimaryPart.CFrame
		else
			cFrame = parent.CFrame
		end

		v.curAngle += p * v.timeToAngle
		local v2 = v.origLocalCFrame * CFrame.Angles(
			v.axisMask.X * v.curAngle,
			v.axisMask.Y * v.curAngle,
			v.axisMask.Z * v.curAngle
		)

		if model:IsA("Model") then
			model.PrimaryPart.CFrame = cFrame * v2
		else
			model.CFrame = cFrame * v2
		end
	end

	self.Instance:WaitForChild("VWorldStorm").Exterior.Event_SkyPortal.LightBlockers.CentralSpin.CFrame *= CFrame.Angles(
		0,
		0.005,
		0
	)
end

return {
	new = function(instance, _)
		return (setmetatable({
			Instance = instance,
			ObjectInfo = {},
			ObjectInfoQueue = {}
		}, class))
	end,
	ancestor = workspace
}