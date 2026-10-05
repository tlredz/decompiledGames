local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local trajectoryVisualNode = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("TrajectoryVisualNode")
local TrajectoryVisual = {}
TrajectoryVisual.__index = TrajectoryVisual

function TrajectoryVisual.new(value)
	local self = setmetatable({}, TrajectoryVisual)
	self._num_segments = value or 100
	self._folder = Instance.new("Folder")
	self._impact_sphere = Instance.new("Part")
	self._segments = {}
	self._renderstep_connection = nil
	self._last_args = {}
	self:_Init()
	return self
end

function TrajectoryVisual:OnStep(onRenderStepped)
	if self._renderstep_connection then
		self._renderstep_connection:Disconnect()
		self._renderstep_connection = nil
	end

	self._renderstep_connection = RunService.RenderStepped:Connect(onRenderStepped)
end

function TrajectoryVisual:Update(p, p2, value, value2, p3, value3)
	if self._last_args[1] == p and self._last_args[2] == p2 and self._last_args[3] == value and self._last_args[4] == value2 and self._last_args[5] == p3 and self._last_args[6] == value3 then
		return
	end

	self._last_args = {
		p,
		p2,
		value,
		value2,
		p3,
		value3
	}
	local position = p
	local flag = false
	local v = value2 or 0.05
	local v2 = value3 or 1e999
	local v3 = value or 196.2

	for k, _segment in pairs(self._segments) do
		if flag then
			_segment.CFrame = CFrame.new(position)
		else
			local v4 = math.min(v2, (k - 1) * v + 0)
			local v5 = p + p2 * v4 - createVector(0, 1, 0) * v3 * v4 ^ 2

			if position:FuzzyEq(v5) then
				_segment.CFrame = CFrame.new(position)
			else
				local raycastResult = Utility:Raycast(
					position,
					v5,
					(position - v5).Magnitude,
					p3,
					Enum.RaycastFilterType.Include
				)
				_segment.CFrame = position:FuzzyEq(raycastResult.Position) and CFrame.new(position) or CFrame.new(
					position,
					raycastResult.Position
				)
				position = raycastResult.Position

				if raycastResult.Instance or v2 <= v4 then
					flag = true
				end
			end
		end
	end

	self._impact_sphere.CFrame = CFrame.new(position)
end

function TrajectoryVisual:Destroy()
	if self._renderstep_connection then
		self._renderstep_connection:Disconnect()
		self._renderstep_connection = nil
	end

	self._folder:Destroy()
end

function TrajectoryVisual:_Setup()
	for i = 1, self._num_segments do
		local clone = trajectoryVisualNode:Clone()
		clone.Size = createVector(1, 2, 1) * (i * 0.02 + 0.1)
		clone.Parent = self._folder
		self._segments[i] = clone
		local _segment = self._segments[i - 1]

		if not _segment then
			continue
		end

		clone.Beam.Attachment0 = _segment.Attachment
		clone.Beam.Width0 = _segment.Size.Y / 4
		clone.Beam.Width1 = clone.Beam.Width0
	end

	self._impact_sphere.Shape = "Ball"
	self._impact_sphere.Color = Color3.fromRGB(255, 255, 255)
	self._impact_sphere.Material = Enum.Material.ForceField
	self._impact_sphere.Size = createVector(3, 3, 3)
	self._impact_sphere.Anchored = true
	self._impact_sphere.CanCollide = false
	self._impact_sphere.CanTouch = false
	self._impact_sphere.CanQuery = false
	self._impact_sphere.CastShadow = false
	self._impact_sphere.Parent = self._folder
	self._folder.Parent = workspace
end

function TrajectoryVisual:_Init()
	self:_Setup()
end

return TrajectoryVisual