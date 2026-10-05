local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Effect"))
local IslandDistance = require(ReplicatedStorage:WaitForChild("IslandDistance"))
local Water = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("World"):WaitForChild("Water"))
local WaterVolumes = require(ReplicatedStorage:WaitForChild("Util"):WaitForChild("GetWaterHeightAtLocation"):WaitForChild("WaterVolumes"))
local v = {
	Dinghy = 56,
	PirateSloop = 92,
	MarineSloop = 89
}
local overlapParams = OverlapParams.new()
overlapParams.MaxParts = 15
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { workspace:WaitForChild("Map"), workspace:FindFirstChild("Boats") }
local Movement = {}

function Movement.register(boat, options)
	local v2 = {
		Owner = nil,
		Active = false
	}

	for k, v3 in pairs(options or {}) do
		v2[k] = v3
	end

	v2.Boat = boat
	v2.Active = true
	v2.InUse = true
	v2.SpeedAlpha = 0
	v2.Throttle = 0
	v2.Steer = 0
	v2.Velocity = 0
	v2.ModelSize = v2.Boat:GetModelSize()

	if not v2.Boat:WaitForChild("VehicleSeat", 60) then
		return
	end

	v2.VehicleSeat = v2.Boat.VehicleSeat
	v2.TurnRadius = v[v2.Boat.Name]
	v2.YOffset = createVector(0, 1, 0) * v2.Boat.VehicleSeat.BodyPosition.Position
	v2.PositionOffset = v2.VehicleSeat.BodyPosition:GetAttribute("PositionInfluence") or createVector(0, 0, 0)
	v2.VehicleSeat.BodyPosition:SetAttribute("YOffset", v2.YOffset)
	v2.VehicleSeat.BodyPosition:SetAttribute("PositionOffset", createVector(0, 0, 0))
	v2.Boat:SetAttribute("DistanceAlpha", 0)
	v2.Mass = 0

	for _, part in pairs(v2.Boat:GetDescendants()) do
		if not part:IsA("BasePart") or part.Massless then
			continue
		end

		v2.Mass += part:GetMass()
	end

	v2.SteerSpring = Util.Spring.new(0.75, 0.25, 0)
	v2.SmoothSteer = Util.Spring.new(1.5, 0.75, 0)
	v2.WaterSpring = Util.Spring.new(1, 1, 0)
	v2.SwayDirection = math.random(2) == 1 and 1 or -1
	v2.SwayTime = 0
	v2.Start = tick()

	if v2.Owner == localPlayer and UserInputService.TouchEnabled then
		localPlayer.CameraMinZoomDistance = 40
	end

	return (setmetatable(v2, {
		__index = Movement
	}))
end

function Movement:refresh(options)
	for k, v2 in pairs(options or {}) do
		self[k] = v2
	end

	self.Start = tick()
	self.Active = true
	self.InUse = true

	if self.Owner == localPlayer and UserInputService.TouchEnabled then
		localPlayer.CameraMinZoomDistance = 40
	end
end

function Movement:unregister()
	self.InUse = false

	if self.Owner == localPlayer and UserInputService.TouchEnabled then
		localPlayer.CameraMinZoomDistance = 0.5
	end
end

local part2 = nil
local weld = nil
local getMassPart

getMassPart = function()
	part2 = Instance.new("Part")
	part2.CustomPhysicalProperties = PhysicalProperties.new(100, 1, 0)
	part2.Transparency = 1
	part2.CanCollide = false
	part2.Size = createVector(5, 5, 5)
	part2.RootPriority = -126
	part2.Destroying:Connect(function()
		part2 = getMassPart()
	end)
	weld = Instance.new("Weld", part2)
	weld.Part1 = part2
	return part2
end

part2 = getMassPart()

local function masspartUpdate(parent)
	if not (parent and parent.PrimaryPart) then
		part2.Parent = nil
		return
	end

	if parent == part2.Parent then
		return
	end

	part2.Parent = nil
	weld.Part0 = parent.PrimaryPart
	weld.C0 = CFrame.new(parent.PrimaryPart.Position) - parent:GetBoundingBox().Position
	part2.Parent = parent
end

function Movement:update(p)
	local _ = tick() - self.Start
	self.Boat = self.Boat:IsDescendantOf(workspace) and self.Boat:FindFirstChild("VehicleSeat") and self.Boat

	if not self.Boat then
		self.Active = false
		return
	end

	if self.Boat:FindFirstChild("OpeBusy") then
		self.SpeedAlpha = 0
		self.Throttle = 0
		self.Steer = 0
		self.Velocity = 0
	else
		local _ = self.Boat
		local vehicleSeat = self.VehicleSeat
		local maxSpeed = vehicleSeat.MaxSpeed
		local v3 = vehicleSeat.TurnSpeed * 0.75
		local steerFloat = vehicleSeat.SteerFloat
		local throttleFloat = vehicleSeat.ThrottleFloat

		if not vehicleSeat.Occupant then
			steerFloat = 0
			throttleFloat = 0
		end

		self.SmoothSteer:SetGoal(steerFloat)
		self.SmoothSteer:GetPosition()

		if self.TurnRadius then
			local v4 = vehicleSeat.MaxSpeed / self.TurnRadius
			local v5 = v4 * (math.abs(steerFloat) < 0.05 and 0 or math.clamp(steerFloat, -1, 1))
			local v6 = v4 / (math.abs(v5) < math.abs(self.Steer) and 0.25 or 0.35) * p
			self.Steer += math.clamp(v5 - self.Steer, -v6, v6)
		elseif math.abs(steerFloat) < 0.5 then
			if self.Steer < 0 then
				self.Steer = math.min(0, self.Steer + p * (vehicleSeat.MaxSpeed / 20))
			end

			if self.Steer > 0 then
				self.Steer = math.max(0, self.Steer - p * (vehicleSeat.MaxSpeed / 20))
			end
		else
			self.Steer = math.clamp(
				self.Steer + v3 * p * 0.85 * steerFloat * (vehicleSeat.MaxSpeed * 1),
				-math.rad(40 + vehicleSeat.Torque) * (vehicleSeat.MaxSpeed / 80),
				math.rad(40 + vehicleSeat.Torque) * (vehicleSeat.MaxSpeed / 80)
			)
		end

		if math.abs(throttleFloat) < 0.5 then
			if self.Velocity < 0 then
				self.Velocity = math.min(0, self.Velocity + p * 40)
			end

			if self.Velocity > 0 then
				self.Velocity = math.max(0, self.Velocity - p * 40)
			end
		else
			self.Velocity = math.clamp(
				self.Velocity + p * throttleFloat * (vehicleSeat.MaxSpeed / 1.3),
				-vehicleSeat.MaxSpeed / 1.4,
				vehicleSeat.MaxSpeed
			)
		end

		local alignCFrame = Util.Misc.AlignCFrame(vehicleSeat.CFrame * CFrame.new(0, 0, -10))

		if self.Owner == localPlayer then
			self.OldCFrame = self.OldCFrame or vehicleSeat.CFrame
		end

		local v4 = CFrame.new(
			Vector3.new(vehicleSeat.Position.X, vehicleSeat.BodyPosition.Position.Y, vehicleSeat.Position.Z),
			(Vector3.new(alignCFrame.p.x, vehicleSeat.BodyPosition.Position.Y, alignCFrame.p.z))
		) * CFrame.Angles(0, -self.Steer * (math.abs(self.Velocity) / vehicleSeat.MaxSpeed) * p, 0)
		local dot = vehicleSeat.CFrame.LookVector:Dot(v4.LookVector * self.Velocity)
		local v5 = dot / maxSpeed
		self.SpeedAlpha = math.abs(v5)
		self.Throttle = math.sign(v5)
		local speedAlpha = self.SpeedAlpha
		local throttle = self.Throttle
		local v6 = IslandDistance(v4.Position) - 250
		local v7 = math.clamp(v6, 0, 500) / 500
		local _ = v6 <= 0
		local unit = createVector(0, 0, 0)

		if math.abs(dot) > 0 then
			Vector3.new()
			local frontOffset

			if throttle > 0 then
				frontOffset = self.Boat:GetAttribute("FrontOffset") or createVector(0, 0, 0)
			else
				frontOffset = (self.Boat:GetAttribute("BackOffset") or createVector(0, 0, 0)) * createVector(1, 1, 0.75)
			end

			local v8 = v4.LookVector * dot * p
			local v9 = self.ModelSize * Vector3.new(1, 1, math.abs(throttle) * 0.5) * Vector3.new(
				1 - frontOffset.X,
				1 - frontOffset.Y,
				1 - frontOffset.Z
			) + v8
			local modelCFrame = self.Boat:GetModelCFrame()
			local v10 = (v4 - v4.p + modelCFrame.p) * CFrame.new(0, 0, -v9.Z / 2 * throttle) + v8 / 2
			local vector2 = Vector3.new(
				math.clamp(v9.X, 0, 3000),
				math.clamp(v9.Y, 0, 30000),
				(math.clamp(v9.Y, 0, 30000))
			)
			local partBoundsInBox = workspace:GetPartBoundsInBox(v10, vector2, overlapParams)
			local count = 0
			local parts = {}
			local velocity = 0
			local v12 = false

			for _, part in pairs(partBoundsInBox) do
				if part:IsDescendantOf(self.Boat) then
					continue
				end

				if part:IsDescendantOf(workspace.Boats) then
					unit = (v10.Position - part.Position).unit
					count += 1
					velocity = 0
					v12 = true
				elseif part.Transparency < 1 and part.CanCollide then
					count += 1

					if part:IsA("MeshPart") then
						table.insert(parts, part)
					end
				end
			end

			if count > 0 then
				for _, _ in pairs(parts) do
					local rayCastWhitelist, _, _ = Util.RayCastWhitelist(
						v10.p - v10.UpVector * self.ModelSize.Y / 2,
						throttle * v10.LookVector * v9.Z * 1.1,
						{ workspace.Map },
						false
					)

					if not (rayCastWhitelist and rayCastWhitelist.Transparency < 1 and rayCastWhitelist.CanCollide) then
						continue
					end

					v12 = true
					break
				end

				if v12 or #parts == 0 then
					if velocity == velocity then
						self.Velocity = velocity
					else
						self.Velocity = 0
					end

					self.Throttle = 0
					self.Steer = 0
				end
			end
		end

		local positionOffset = self.PositionOffset

		if vehicleSeat.BodyPosition:GetAttribute("SpeedInfluence") then
			positionOffset *= self.SpeedAlpha
		end

		local v8 = positionOffset * v7
		self.Boat:SetAttribute("DistanceAlpha", v7)
		vehicleSeat.BodyPosition:SetAttribute("PositionOffset", v8)
		local boatColumn = WaterVolumes.queryBoatColumn(vehicleSeat.Position)
		self.WaterSpring:SetGoal(not boatColumn and 0 or WaterVolumes.getSurfaceHeight(boatColumn, vehicleSeat.Position) - Water.SEA_LEVEL)
		self.WaterSpring:Update(p)
		vehicleSeat.BodyGyro.CFrame = v4 - v4.p
		vehicleSeat.BodyVelocity.Velocity = v4.LookVector * self.Velocity + unit
		vehicleSeat.BodyPosition.Position = self.YOffset + v8 + createVector(0, 1, 0) * self.WaterSpring:GetPosition()

		if not self.InUse and self.Velocity == 0 then
			self.Active = false
		end

		if speedAlpha < 0.1 then
			self.SwayTime += p * 0.5
		end

		local v9 = math.sign(throttleFloat)
		local v10 = v9 == 0 and 1 or v9

		if vehicleSeat.Anchored then
			vehicleSeat.BodyVelocity.Velocity = createVector(0, 0, 0)
			vehicleSeat.BodyGyro.CFrame = vehicleSeat.CFrame.Rotation
		end

		self.SteerSpring:SetGoal(0.15707963267948966 * steerFloat * v10 * speedAlpha + 0.06981317007977318 * self.SwayDirection * math.sin(self.SwayTime) * (1 - speedAlpha))
		self.SteerSpring:Update(p)
		local position = self.SteerSpring:GetPosition()
		vehicleSeat.BodyGyro.CFrame *= CFrame.Angles(0, 0, -position)

		if self.Owner == localPlayer then
			local _ = self.InUse
		end

		self.OldCFrame = vehicleSeat.CFrame
	end

	self.SmoothSteer:Update(p)
end

return Movement