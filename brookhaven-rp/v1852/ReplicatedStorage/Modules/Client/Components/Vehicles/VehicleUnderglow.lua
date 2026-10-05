local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleUnderglow"
})

function v:UpdateUnderglowSize(instance)
	local size = self.Instance.Size
	local v2 = not self.underglowLengthFactor and 1 or self.underglowLengthFactor.Value or 1
	local v3 = not self.underglowWidthFactor and 1.5 or self.underglowWidthFactor.Value or 1.5
	local vehicleLengthFactor = self.vehicleLengthFactor or 1
	local vehicleWidthFactor = self.vehicleWidthFactor or 1
	instance.Size = Vector3.new(size.X * v3 * vehicleWidthFactor, 0.05, size.Z * v2 * vehicleLengthFactor)
	local v4 = v3 * vehicleWidthFactor / 1.5
	local v5 = v2 * vehicleLengthFactor / 1

	for _, child in instance:GetChildren() do
		if child:IsA("Attachment") then
			local position

			if self.originalAttachmentPositions == nil or self.originalAttachmentPositions[child] == nil then
				position = child.Position
			else
				position = self.originalAttachmentPositions[child]
			end

			local v6 = position.X * v4
			local v7 = position.Z * v5

			if child:GetAttribute("Front") then
				v7 = -instance.Size.Z / 1.3
			elseif child:GetAttribute("Back") then
				v7 = instance.Size.Z / 1.3
			end

			child.Position = Vector3.new(v6, 0, v7)
		elseif child:IsA("Beam") then
			local X = instance.Size.X

			if child.Attachment0 ~= nil and math.abs(child.Attachment0.Position.X) < 0.1 then
				child.Width0 = X * 1.5
			end

			if child.Attachment1 ~= nil and math.abs(child.Attachment1.Position.X) < 0.1 then
				child.Width1 = X * 1.5
			end
		end
	end
end

function v:UpdateUnderglowCFrame()
	if not (self.underglowClone.Parent and self.Instance.Parent) then
		return
	end

	local physicalWheels = {}
	local vectors = {}
	local count = 0
	local underglowOffset = self.vehicle:GetAttribute("UnderglowOffset") or CFrame.new(0, 0.1, 0)

	if self.wheelsFolder then
		for _, child in self.wheelsFolder:GetChildren() do
			if not (child:HasTag("Wheel") or child:HasTag("WheelSteering")) or child:HasTag("WheelSki") then
				continue
			end

			local physicalWheel = child:FindFirstChild("PhysicalWheel")

			if not physicalWheel then
				continue
			end

			local name = child.Name
			local v2

			if string.find(name, "WheelFL") then
				v2 = "FL"
			elseif string.find(name, "WheelFR") then
				v2 = "FR"
			elseif string.find(name, "WheelBR") then
				v2 = "BR"
			elseif string.find(name, "WheelBL") then
				v2 = "BL"
			elseif string.find(name, "WheelFC") then
				v2 = "FC"
			elseif string.find(name, "WheelBC") then
				v2 = "BC"
			else
				v2 = nil
			end

			if not v2 or physicalWheels[v2] then
				continue
			end

			physicalWheels[v2] = physicalWheel
			vectors[v2] = Vector3.new(0, -physicalWheel.Size.Y / 2, 0)
			count += 1
		end
	end

	if physicalWheels.FL and physicalWheels.FR and physicalWheels.BR and physicalWheels.BL then
		local v2 = physicalWheels.FL.Position + vectors.FL
		local v3 = physicalWheels.FR.Position + vectors.FR
		local v4 = physicalWheels.BR.Position + vectors.BR
		local v5 = physicalWheels.BL.Position + vectors.BL
		local v6 = (v2 + v3 + v4 + v5) / 4
		local unit = (v2 - v4):Cross(v3 - v5).Unit
		local v7 = -unit
		local unit2 = unit:Cross(v2 - v5).Unit
		local cFrame = CFrame.fromMatrix(v6, unit2, v7) * underglowOffset
		self.underglowClone.CFrame = cFrame
	elseif count == 3 then
		local v2 = {}
		local v3 = {}

		for k, v4 in pairs(physicalWheels) do
			table.insert(v2, v4.Position + vectors[k])
			table.insert(v3, k)
		end

		local v4 = createVector(0, 0, 0)

		for _, v5 in pairs(v2) do
			v4 += v5
		end

		local v5 = v4 / 3
		local v6 = v2[1]
		local v7 = v2[2]
		local v8 = v2[3]
		local unit = (v7 - v6):Cross(v8 - v6).Unit

		if unit.Y < 0 then
			unit = -unit
		end

		local unit2 = self.Instance.CFrame.LookVector:Cross(unit).Unit
		local unit3 = unit2:Cross(unit).Unit
		local cFrame = CFrame.fromMatrix(v5, unit2, unit, unit3) * underglowOffset
		self.underglowClone.CFrame = cFrame
	elseif count == 2 then
		local v2 = {}
		local v3 = {}

		for k, v4 in pairs(physicalWheels) do
			table.insert(v2, v4.Position + vectors[k])
			table.insert(v3, k)
		end

		local midpoint = (v2[1] + v2[2]) / 2
		local unit = (v2[1] - v2[2]):Cross(createVector(0, 1, 0)).Unit
		local unit2 = unit:Cross(createVector(0, 1, 0)).Unit
		local cFrame = CFrame.fromMatrix(midpoint, unit, createVector(0, 1, 0), unit2) * underglowOffset
		self.underglowClone.CFrame = cFrame
	else
		local physicalWheel = self.wheelsFolder:GetChildren()[1]:FindFirstChild("PhysicalWheel")
		local v2 = self.underglowClone.Position - Vector3.new(0, physicalWheel.Size.Y / 2.8, 0)
		self.underglowClone.CFrame = CFrame.new(v2)
	end
end

function v:RenderUnderglow()
	local size = self.Instance.Size
	local cFrame = self.Instance.CFrame * CFrame.new(0, -(size.Y / 2), 0)
	self.underglowClone.CFrame = cFrame
	self.underglowClone.Size = Vector3.new(self.Instance.Size.X / 2, 0.05, self.Instance.Size.Z / 2)
	self.underglowClone.Anchored = true
	self:UpdateUnderglowSize(self.underglowClone)
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	self.vehicle = VehicleController.GetVehicleModelFromInstance(self.Instance)
	self.underglowLengthFactor = self.Instance:FindFirstChild("UnderglowLengthFactor")
	self.underglowWidthFactor = self.Instance:FindFirstChild("UnderglowWidthFactor")
	self.vehicleLengthFactor = not self.vehicle and 1 or self.vehicle:GetAttribute("UnderglowLengthVehicleFactor") or 1
	self.vehicleWidthFactor = not self.vehicle and 1 or self.vehicle:GetAttribute("UnderglowWidthVehicleFactor") or 1
	local underglow = ReplicatedStorage:FindFirstChild("Underglow")

	if not underglow then
		warn("VehicleUnderglow: Underglow folder not found")
		return
	end

	local underglow2 = self.Instance:FindFirstChild("Underglow")

	if not underglow2 then
		warn("VehicleUnderglow: Underglow value not found")
		return
	end

	local child = underglow:FindFirstChild(underglow2.Value)

	if not child then
		warn("VehicleUnderglow: Underglow part not found")
		return
	end

	local underglowClone = self._Janitor:Add(child:Clone())
	underglowClone.Anchored = false
	underglowClone.CanCollide = false
	underglowClone.CastShadow = false
	underglowClone.Massless = true
	underglowClone.Transparency = 1
	underglowClone.Parent = self.Instance
	self.underglowClone = underglowClone
	self.originalAttachmentPositions = {}

	for _, attachment in underglowClone:GetChildren() do
		if attachment:IsA("Attachment") then
			self.originalAttachmentPositions[attachment] = attachment.Position
		end
	end

	for _, child2 in self.Instance:WaitForChild("UnderglowColors"):GetChildren() do
		local v3 = child2
		self._Janitor:Add(child2.Changed:Connect(function()
			for i, beam in self.underglowClone:GetChildren() do
				if not (beam:IsA("Beam") and "Color" .. beam:GetAttribute("ColorIndex") == v3.Name) then
					continue
				end

				beam.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, v3.Value),
					ColorSequenceKeypoint.new(1, v3.Value)
				})
			end
		end))

		for _, beam in self.underglowClone:GetChildren() do
			if not (beam:IsA("Beam") and "Color" .. beam:GetAttribute("ColorIndex") == child2.Name) then
				continue
			end

			beam.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, child2.Value),
				ColorSequenceKeypoint.new(1, child2.Value)
			})
		end
	end

	if self.vehicle:FindFirstChild("Chassis") then
		self.wheelsFolder = self.vehicle.Chassis:FindFirstChild("Wheels")
		self._Janitor:Add(RunService.RenderStepped:Connect(function()
			self:UpdateUnderglowCFrame()
		end))
		self._Janitor:Add(self.underglowLengthFactor.Changed:Connect(function()
			self:UpdateUnderglowSize(self.underglowClone)
		end))
		self._Janitor:Add(self.underglowWidthFactor.Changed:Connect(function()
			self:UpdateUnderglowSize(self.underglowClone)
		end))

		if self.vehicle:GetAttribute("IsBike") then
			local chassis = self.vehicle:FindFirstChild("Chassis")

			if not chassis then
				warn("VehicleUnderglow: Chassis not found")
				return
			end

			local wheelie = chassis:FindFirstChild("Wheelie")

			if wheelie then
				self._Janitor:Add(wheelie.Changed:Connect(function()
					for _, beam in self.underglowClone:GetChildren() do
						if beam:IsA("Beam") then
							beam.Enabled = not wheelie.Value
						end
					end
				end))
			else
				warn("VehicleUnderglow: Wheelie value not found")
				return
			end
		end

		self.underglowClone = underglowClone
	else
		self._Janitor:Add(self.underglowLengthFactor.Changed:Connect(function()
			self:UpdateUnderglowSize(self.underglowClone)
		end))
		self._Janitor:Add(self.underglowWidthFactor.Changed:Connect(function()
			self:UpdateUnderglowSize(self.underglowClone)
		end))
	end
end

function v:RenderSteppedUpdate()
	self:RenderUnderglow()
end

function v:Stop()
	self._Janitor:Destroy()
end

return v