local createVector = vector.create
local random = Random.new()
local count = 0
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function acquireProperty()
	return table.remove(v) or {}
end

local Mesh = {
	releaseProperty = function(p)
		if #v < 512 then
			table.insert(v, p)
		end
	end
}
local cframe = CFrame.new()
local v2 = {
	Top = CFrame.new(0, 1, 0),
	Front = CFrame.new(0, 0, -1),
	Bottom = CFrame.new(0, -1, 0),
	Left = CFrame.new(-1, 0, 0),
	Right = CFrame.new(1, 0, 0),
	Back = CFrame.new(0, 0, 1)
}
local v3 = {
	[createVector(0, -1, 0)] = CFrame.Angles(1.5707963267948966, 0, 0),
	[createVector(0, 1, 0)] = CFrame.Angles(-1.5707963267948966, 0, 0),
	[createVector(-1, 0, 0)] = CFrame.Angles(0, -1.5707963267948966, 0),
	[createVector(1, 0, 0)] = CFrame.Angles(0, 1.5707963267948966, 0),
	[createVector(0, 0, -1)] = CFrame.Angles(0, 0, 0),
	[createVector(0, 0, 1)] = CFrame.Angles(0, -3.141592653589793, 0),
	[createVector(0, 0, 0)] = CFrame.Angles(0, 0, 0)
}
local v4 = {
	__index = Mesh
}
local v5 = {
	__index = function(p, p2)
		local number = random:NextNumber(-1, 1)
		rawset(p, p2, number)
		return number
	end
}

function Mesh.new(meshEmitter, p)
	local meshEmitterObject = meshEmitter.MeshEmitterObject
	local v6 = {}

	for k, v7 in p or meshEmitterObject:GetAttributes() do
		if typeof(v7) == "NumberRange" then
			v7 = random:NextNumber(v7.Min, v7.Max)
		end

		v6[k] = v7
	end

	v6.Elapsed = 0
	v6.Alpha = 0
	v6.PartOffset = cframe
	v6._vX = 0
	v6._vY = 0
	v6._vZ = 0
	v6._csX = 0
	v6._csY = 0
	v6._csZ = 0
	v6._opX = 0
	v6._opY = 0
	v6._opZ = 0
	count += 1
	v6.id = count
	v6.MeshEmitter = meshEmitter
	v6.MeshEmitterObject = meshEmitterObject
	v6.Origin = meshEmitterObject.Parent
	v6.Static = meshEmitter.StaticCache
	v6.NoEnvelope = meshEmitter.NoEnvelopeCache
	v6.Envelopes = setmetatable({}, v5)
	v6.OriginPosition = nil
	v6.MeshInstance = nil
	v6.Decal = false
	v6.SpecialMesh = false
	v6.OnDeath = nil
	local object = setmetatable(v6, v4)
	object.Lifetime = math.max(object.Lifetime or 0, 0.01)

	if not v2[object.EmissionDirection] then
		object.EmissionDirection = "Top"
	end

	object:InitialVelocity()
	object:CreateObject()
	object:ApplyStaticProperties()
	return object
end

function Mesh:InitialVelocity()
	if self.Origin:IsA("BasePart") and self.VelocityInheritance and self.VelocityInheritance > 0 then
		local v6 = self.Origin.AssemblyLinearVelocity * self.VelocityInheritance
		self._vX = v6.X
		self._vY = v6.Y
		self._vZ = v6.Z
	end

	if self.Origin then
		local v6

		if self.Origin:IsA("Attachment") then
			v6 = CFrame.new(self.Origin.WorldPosition, (self.Origin.WorldCFrame * v2[self.EmissionDirection]).Position)
		else
			v6 = CFrame.new(self.Origin.Position, (self.Origin.CFrame * v2[self.EmissionDirection]).Position)
		end

		local lookVector = (v6 * CFrame.Angles(
			math.rad((random:NextNumber(-self.SpreadAngle.X, self.SpreadAngle.X))),
			math.rad((random:NextNumber(-self.SpreadAngle.Y, self.SpreadAngle.Y))),
			0
		)).LookVector
		local speed = self.Speed
		self._vX += lookVector.X * speed
		self._vY += lookVector.Y * speed
		self._vZ += lookVector.Z * speed
	end

	self.OriginalVelocity = Vector3.new(self._vX, self._vY, self._vZ)
end

function Mesh.CollapseRange(_, range: NumberRange)
	return random:NextNumber(range.Min, range.Max)
end

function Mesh:EvalNumberSequence(p)
	local v6 = self.Static[p]

	if v6 then
		return v6
	end

	local v7 = self[p]

	if not v7 then
		return nil
	end

	local keypoints = v7.Keypoints
	local count2 = #keypoints
	local alpha = self.Alpha
	local v8 = alpha < 0 and 0 or alpha > 1 and 1 or alpha
	local flag = not self.NoEnvelope[p]

	if count2 == 2 then
		local keypoint = keypoints[1]
		local keypoint2 = keypoints[2]
		local v9 = keypoint.Value + (keypoint2.Value - keypoint.Value) * v8

		if flag then
			return v9 + (keypoint.Envelope + (keypoint2.Envelope - keypoint.Envelope) * v8) * self.Envelopes[p]
		end

		return v9
	else
		if v8 <= 0 then
			local keypoint = keypoints[1]
			return keypoint.Value + (flag and keypoint.Envelope * self.Envelopes[p] or 0)
		end

		if v8 >= 1 then
			local keypoint = keypoints[count2]
			return keypoint.Value + (flag and keypoint.Envelope * self.Envelopes[p] or 0)
		end

		for i = 1, count2 - 1 do
			local keypoint = keypoints[i]
			local keypoint2 = keypoints[i + 1]

			if not (keypoint.Time <= v8 and v8 < keypoint2.Time) then
				continue
			end

			local v9 = (v8 - keypoint.Time) / (keypoint2.Time - keypoint.Time)
			local v10 = keypoint.Value + (keypoint2.Value - keypoint.Value) * v9

			if flag then
				return v10 + (keypoint.Envelope + (keypoint2.Envelope - keypoint.Envelope) * v9) * self.Envelopes[p]
			end

			return v10
		end
	end
end

function Mesh:EvalColorSequence(p2)
	local v6 = self.Static[p2]

	if v6 then
		return v6
	end

	local v7 = self[p2]

	if not v7 then
		return nil
	end

	local keypoints = v7.Keypoints
	local count2 = #keypoints
	local alpha = self.Alpha
	local v8 = alpha < 0 and 0 or alpha > 1 and 1 or alpha

	if count2 == 2 then
		local value = keypoints[1].Value
		local value2 = keypoints[2].Value
		return Color3.new(
			value.R + (value2.R - value.R) * v8,
			value.G + (value2.G - value.G) * v8,
			value.B + (value2.B - value.B) * v8
		)
	else
		if v8 <= 0 then
			return keypoints[1].Value
		end

		if v8 >= 1 then
			return keypoints[count2].Value
		end

		for i = 1, count2 - 1 do
			local keypoint = keypoints[i]
			local keypoint2 = keypoints[i + 1]

			if not (keypoint.Time <= v8 and v8 < keypoint2.Time) then
				continue
			end

			local v9 = (v8 - keypoint.Time) / (keypoint2.Time - keypoint.Time)
			local value = keypoint.Value
			local value2 = keypoint2.Value
			return Color3.new(
				value.R + (value2.R - value.R) * v9,
				value.G + (value2.G - value.G) * v9,
				value.B + (value2.B - value.B) * v9
			)
		end
	end
end

function Mesh:CreateObject()
	local position

	if self.Origin and self.Origin:IsA("BasePart") then
		self.PartOffset = CFrame.new(
			random:NextNumber(-self.Origin.Size.X / 2, self.Origin.Size.X / 2),
			random:NextNumber(-self.Origin.Size.Y / 2, self.Origin.Size.Y / 2),
			random:NextNumber(-self.Origin.Size.Z / 2, self.Origin.Size.Z / 2)
		)
		position = (self.Origin.CFrame * self.PartOffset).Position
	else
		position = not (self.Origin and self.Origin:IsA("Attachment")) and createVector(0, 0, 0) or self.Origin.WorldPosition
	end

	self.OriginPosition = position
	local part = self.MeshEmitter.MeshCache:GetPart()
	part:SetAttribute("n", (part:GetAttribute("n") or 0) + 1)
	part.Archivable = false
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	part.Locked = true
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
	self.MeshInstance = part
	part.Material = self.Material or part.Material
	local castShadow

	if self.CastShadow == nil then
		castShadow = part.CastShadow
	else
		castShadow = self.CastShadow
	end

	part.CastShadow = castShadow
	self.Decal = part:FindFirstChildOfClass("Decal") or false
	self.SpecialMesh = part:FindFirstChildOfClass("SpecialMesh") or false
	self._hasRot = self.RotX ~= 0 or self.RotY ~= 0 or self.RotZ ~= 0

	if self._hasRot then
		self._rotCFrame = CFrame.Angles(math.rad(self.RotX), math.rad(self.RotY), (math.rad(self.RotZ)))
	end

	self._stationary = self._vX * self._vX + self._vY * self._vY + self._vZ * self._vZ < 1e-6 and (self.MaxSpin or 0) == 0 and not self.LockedToPart

	if self.Flipbook then
		local flipbook = self.MeshEmitterObject.Value:FindFirstChild("Flipbook")

		if flipbook then
			self.Flipbook = require(flipbook)

			if self.Decal then
				self.Decal.Texture = self.Flipbook[1]
			end
		else
			self.Flipbook = false
		end
	end
end

function Mesh:UpdateAlpha(p)
	self.Elapsed += p
	self.Alpha = self.Elapsed / self.Lifetime * self.TimeScale

	if self.Alpha > 1 then
		return true
	end
end

function Mesh:ApplyStaticProperties()
	local decal = self.Decal
	local meshInstance = self.MeshInstance
	local specialMesh = self.SpecialMesh
	local v6 = self.Static.Transparency ~= nil
	local v7 = self.Static.Color ~= nil
	local v8

	if self.LinkedSize then
		v8 = self.Static.Size ~= nil
	elseif self.Static.SizeX == nil or self.Static.SizeY == nil then
		v8 = false
	else
		v8 = self.Static.SizeZ ~= nil
	end

	self.NeedsTransparency = not v6
	self.NeedsColor = not v7
	self.NeedsSize = not v8
	self.AllStatic = v6 and v7 and v8 and not self.Flipbook

	if v6 then
		local transparency = self.Static.Transparency

		if self.TransferTransparency then
			if decal then
				decal.Transparency = transparency
			end
		else
			meshInstance.Transparency = transparency
		end
	end

	if v7 then
		local color = self.Static.Color

		if self.ColorFactor then
			color = Color3.new(color.R * self.ColorFactor, color.G * self.ColorFactor, color.B * self.ColorFactor)
		end

		if self.TransferColor then
			if decal then
				decal.Color3 = color
			end
		else
			meshInstance.Color = color
		end
	end

	if v8 then
		local v9

		if self.LinkedSize then
			local size = self.Static.Size
			v9 = Vector3.new(size, size, size) * self.MaxSize
		else
			v9 = Vector3.new(self.Static.SizeX, self.Static.SizeY, self.Static.SizeZ) * self.MaxSize
		end

		if specialMesh then
			specialMesh.Scale = v9
		else
			meshInstance.Size = v9
		end
	end
end

function Mesh:EvaluateProperties(p)
	local property = acquireProperty() -- equivalent call inferred; original call site unknown

	if self.NeedsTransparency then
		property.Transparency = self:EvalNumberSequence("Transparency") or 1
	end

	if self.NeedsColor then
		property.Color = self:EvalColorSequence("Color")

		if self.ColorFactor and property.Color then
			property.Color = Color3.new(
				property.Color.R * self.ColorFactor,
				property.Color.G * self.ColorFactor,
				property.Color.B * self.ColorFactor
			)
		end
	end

	local maxSpin = self.MaxSpin

	if maxSpin and maxSpin ~= 0 then
		local evalNumberSequence = self:EvalNumberSequence("Spin")
		local v7 = evalNumberSequence or self:EvalNumberSequence("SpinX") or 1
		local v8 = evalNumberSequence or self:EvalNumberSequence("SpinY") or 1
		local v9 = evalNumberSequence or self:EvalNumberSequence("SpinZ") or 1
		local v10 = p * maxSpin * self.TimeScale
		self._csX += v7 * v10
		self._csY += v8 * v10
		self._csZ += v9 * v10
	end

	if self.NeedsSize then
		if self.LinkedSize then
			local evalNumberSequence = self:EvalNumberSequence("Size")
			property.MeshSize = Vector3.new(evalNumberSequence, evalNumberSequence, evalNumberSequence) * self.MaxSize
		else
			property.MeshSize = Vector3.new(
				self:EvalNumberSequence("SizeX"),
				self:EvalNumberSequence("SizeY"),
				(self:EvalNumberSequence("SizeZ"))
			) * self.MaxSize
		end
	end

	if self._stationary and self._cframeWritten then
		return property
	end

	if self.LockedToPart then
		if self.Origin:IsA("Attachment") then
			self.OriginPosition = (self.Origin.WorldCFrame * self.PartOffset).Position
		else
			self.OriginPosition = (self.Origin.CFrame * self.PartOffset).Position
		end
	end

	local drag = self.Drag

	if drag and drag > 0 then
		local v7 = 1 - drag * 0.5 * p * self.TimeScale
		self._vX *= v7
		self._vY *= v7
		self._vZ *= v7
	end

	local v7 = p * self.TimeScale
	local v8 = self._vX * v7
	local v9 = self._vY * v7
	local v10 = self._vZ * v7
	self._opX += v8
	self._opY += v9
	self._opZ += v10
	local originPosition = self.OriginPosition
	local v11 = originPosition.X + self._opX
	local v12 = originPosition.Y + self._opY
	local v13 = originPosition.Z + self._opZ

	if self.FaceVelocity then
		property.MeshCFrame = CFrame.new(Vector3.new(v11, v12, v13), (Vector3.new(v11 + v8, v12 + v9, v13 + v10))) * (v3[self.FRONT_VECTOR] or cframe)
	else
		property.MeshCFrame = CFrame.new(v11, v12, v13)
	end

	local _csX = self._csX
	local _csY = self._csY
	local _csZ = self._csZ

	if _csX ~= 0 or _csY ~= 0 or _csZ ~= 0 then
		if self._hasRot then
			property.MeshCFrame *= self._rotCFrame * CFrame.Angles(math.rad(_csX), math.rad(_csY), (math.rad(_csZ)))
			return property
		end

		property.MeshCFrame *= CFrame.Angles(math.rad(_csX), math.rad(_csY), (math.rad(_csZ)))
	elseif self._hasRot then
		property.MeshCFrame *= self._rotCFrame
	end

	return property
end

function Mesh:Update(data)
	if self.AllStatic then
		return
	end

	local decal = self.Decal
	local meshInstance = self.MeshInstance

	if self.NeedsTransparency then
		local transparency = data.Transparency

		if self._lastT ~= transparency then
			self._lastT = transparency

			if self.TransferTransparency then
				if decal then
					decal.Transparency = transparency
				end
			else
				meshInstance.Transparency = transparency
			end
		end
	end

	if self.NeedsColor then
		local color = data.Color

		if self._lastC ~= color then
			self._lastC = color

			if self.TransferColor then
				if decal then
					decal.Color3 = color
				end
			else
				meshInstance.Color = color
			end
		end
	end

	if self.NeedsSize then
		local meshSize = data.MeshSize

		if self._lastS ~= meshSize then
			self._lastS = meshSize
			local specialMesh = self.SpecialMesh

			if specialMesh then
				specialMesh.Scale = meshSize
			else
				meshInstance.Size = meshSize
			end
		end
	end

	if self.Flipbook then
		local lastF = math.ceil(#self.Flipbook * self.Alpha)

		if lastF ~= self._lastF then
			self._lastF = lastF
			decal.Texture = self.Flipbook[lastF]
		end
	end
end

function Mesh:Destroy()
	self.MeshEmitter.MeshCache:ReturnPart(self.MeshInstance)
	self.MeshInstance = nil
	self.OnDeath(self)
end

return Mesh