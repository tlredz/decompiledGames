local clock = os.clock
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local _ = Workspace.CurrentCamera
local part = Instance.new("Part")
part.TopSurface = 0
part.BottomSurface = 0
part.Anchored = true
part.CanCollide = false
part.CanQuery = false
part.CanTouch = false
part.Locked = true
part.CastShadow = false
part.Shape = "Cylinder"
part.Name = "BoltPart"
part.Material = Enum.Material.Neon
part.Color = Color3.new(1, 1, 1)
part.Transparency = 1

local function CubicBezier(p, p2, p3, p4, p5)
	return p2 * (1 - p) ^ 3 + p3 * 3 * p * (1 - p) ^ 2 + p4 * 3 * (1 - p) * p ^ 2 + p5 * p ^ 3
end

local function DiscretePulse(p, p2, p3, p4, p5, min, max)
	return (math.clamp(p4 / (2 * p5) - math.abs((p - p2 * p3 + 0.5 * p4) / p5), min, max))
end

local function ExtrudeCenter(p)
	return (math.exp(-5000 * (p - 0.5) ^ 10))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function NoiseBetween(p, p2, p3, minThicknessMultiplier, maxThicknessMultiplier)
	return minThicknessMultiplier + (maxThicknessMultiplier - minThicknessMultiplier) * (math.noise(p, p2, p3) + 0.5)
end

local inverse = CFrame.lookAt(Vector3.new(), vector.create(1, 0, 0)):Inverse()
local v = {}
local LightningBolt = {
	__type = "LightningBolt"
}
LightningBolt.__index = LightningBolt

function LightningBolt.new(attachment, attachment2, value)
	local self = setmetatable({}, LightningBolt)
	self.Enabled = true
	self.Attachment0 = attachment
	self.Attachment1 = attachment2
	self.CurveSize0 = 0
	self.CurveSize1 = 0
	self.MinRadius = 0
	self.MaxRadius = 2.4
	self.Frequency = 1
	self.AnimationSpeed = 7
	self.Thickness = 1
	self.MinThicknessMultiplier = 0.2
	self.MaxThicknessMultiplier = 1
	self.MinTransparency = 0
	self.MaxTransparency = 1
	self.PulseSpeed = 2
	self.PulseLength = 1000000
	self.FadeLength = 0.2
	self.ContractFrom = 0.5
	self.Color = Color3.new(1, 1, 1)
	self.ColorOffsetSpeed = 3
	self.SpaceCurveFunction = CubicBezier
	self.OpacityProfileFunction = DiscretePulse
	self.RadialProfileFunction = ExtrudeCenter
	self._Parts = {}

	for i = 1, value or 30 do
		self._Parts[i] = part:Clone()
		self._Parts[i].Parent = Workspace.CurrentCamera
	end

	self._PartsHidden = false
	self._DisabledTransparency = 1
	self._StartT = clock()
	self._RanNum = math.random() * 100
	self._RefIndex = #v + 1
	v[self._RefIndex] = self
	return self
end

function LightningBolt:Destroy()
	v[self._RefIndex] = nil

	for i = 1, #self._Parts do
		self._Parts[i]:Destroy()
	end
end

function LightningBolt:DestroyDissipate(value, value2)
	local v2 = value or 0.2
	local v3 = value2 or 0.5
	local now = clock()
	local minTransparency = self.MinTransparency
	local contractFrom = self.ContractFrom
	local v4 = self.ContractFrom + 1 / (#self._Parts * self.FadeLength)
	local maxRadius = self.MaxRadius
	local minThicknessMultiplier = self.MinThicknessMultiplier
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v5 = clock() - now
		self.MinThicknessMultiplier = minThicknessMultiplier + (-2 - minThicknessMultiplier) * v5 / v2

		if v5 < v2 * 0.4 then
			local v6 = v5 / (v2 * 0.4)
			self.MinTransparency = minTransparency + (contractFrom - minTransparency) * v6
		elseif v5 < v2 then
			local v6 = (v5 - v2 * 0.4) / (v2 * 0.6)
			self.MinTransparency = contractFrom + (v4 - contractFrom) * v6
			self.MaxRadius = maxRadius * (1 + v3 * v6)
			self.MinRadius += (self.MaxRadius - self.MinRadius) * v6
		else
			if clock() - self._StartT < (self.PulseLength + 1) / self.PulseSpeed then
				self:Destroy()
			end

			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end)
end

function LightningBolt:_UpdateGeometry(p, p2, p3, p4, p5, p6)
	local v2 = 1 - self.MaxTransparency
	local v3 = 1 - self.MinTransparency
	local opacityProfileFunction = self.OpacityProfileFunction(
		p2,
		p3,
		self.PulseSpeed,
		self.PulseLength,
		self.FadeLength,
		v2,
		v3
	)
	local v4 = self.Thickness * p4 * opacityProfileFunction
	local v5 = v4 > 0 and opacityProfileFunction or 0
	local v6 = 1 - self.ContractFrom
	local count = #self._Parts

	if v6 < v5 then
		p.Size = Vector3.new((p6 - p5).Magnitude, v4, v4)
		p.CFrame = CFrame.lookAt((p5 + p6) * 0.5, p6) * inverse
		p.Transparency = 1 - v5
	else
		if not (v6 - 1 / (count * self.FadeLength) < v5) then
			p.Transparency = 1
			return
		end

		local v7 = (1 - (v5 - (v6 - 1 / (count * self.FadeLength))) * count * self.FadeLength) * (p2 < p3 * self.PulseSpeed - 0.5 * self.PulseLength and 1 or -1)
		p.Size = Vector3.new((1 - math.abs(v7)) * (p6 - p5).Magnitude, v4, v4)
		p.CFrame = CFrame.lookAt(p5 + (p6 - p5) * (math.max(0, v7) + (1 - math.abs(v7)) * 0.5), p6) * inverse
		p.Transparency = 1 - v5
	end
end

function LightningBolt:_UpdateColor(p, p2, p3)
	if typeof(self.Color) == "Color3" then
		p.Color = self.Color
		return
	end

	local v2 = (self._RanNum + p2 - p3 * self.ColorOffsetSpeed) % 1
	local keypoints = self.Color.Keypoints

	for i = 1, #keypoints - 1 do
		if not (keypoints[i].Time < v2 and v2 < keypoints[i + 1].Time) then
			continue
		end

		p.Color = keypoints[i].Value:lerp(
			keypoints[i + 1].Value,
			(v2 - keypoints[i].Time) / (keypoints[i + 1].Time - keypoints[i].Time)
		)
		break
	end
end

function LightningBolt:_Disable()
	self.Enabled = false

	for _, _Part in ipairs(self._Parts) do
		_Part.Transparency = self._DisabledTransparency
	end
end

RunService.Heartbeat:Connect(function()
	debug.profilebegin("LightningBolt")

	for _, v2 in pairs(v) do
		if v2.Enabled == true then
			v2._PartsHidden = false
			local minRadius = v2.MinRadius
			local maxRadius = v2.MaxRadius
			local _Parts = v2._Parts
			local count = #_Parts
			local _RanNum = v2._RanNum
			local animationSpeed = v2.AnimationSpeed
			local frequency = v2.Frequency
			local minThicknessMultiplier = v2.MinThicknessMultiplier
			local maxThicknessMultiplier = v2.MaxThicknessMultiplier
			local v3 = clock() - v2._StartT
			local spaceCurveFunction = v2.SpaceCurveFunction
			local radialProfileFunction = v2.RadialProfileFunction
			local v4 = (v2.PulseLength + 1) / v2.PulseSpeed
			local attachment0 = v2.Attachment0
			local attachment1 = v2.Attachment1
			local curveSize0 = v2.CurveSize0
			local curveSize1 = v2.CurveSize1
			local worldPosition = attachment0.WorldPosition
			local v5 = attachment0.WorldPosition + attachment0.WorldAxis * curveSize0
			local v6 = attachment1.WorldPosition - attachment1.WorldAxis * curveSize1
			local worldPosition2 = attachment1.WorldPosition
			local v7 = spaceCurveFunction(0, worldPosition, v5, v6, worldPosition2)

			if v3 < v4 then
				local v8 = v7

				for i = 1, count do
					local _Part = _Parts[i]
					local v9 = i / count
					local v10 = animationSpeed * -v3 + frequency * 10 * v9 - 0.2 + _RanNum * 4
					local v11 = 5 * (animationSpeed * 0.01 * -v3 / 10 + frequency * v9) + _RanNum * 4
					local v12 = 5 * v10
					local v13 = 1 * v11
					local v14 = 0 + 0.6283185307179586 * (math.noise(v12, 1.5, v13) + 0.5)
					local v15 = 0.5 * v10
					local v16 = 0.1 * v11
					local v17 = v14 + (0 + 5.654866776461628 * (math.noise(v15, 1.5, v16) + 0.5))
					local v18 = NoiseBetween(3.4, v11, v10, minRadius, maxRadius) * radialProfileFunction(v9)
					local noiseBetween = NoiseBetween(2.3, v11, v10, minThicknessMultiplier, maxThicknessMultiplier) -- equivalent call inferred; original call site unknown
					local v20 = spaceCurveFunction(v9, worldPosition, v5, v6, worldPosition2)
					local position

					if i == count then
						position = v20
					else
						position = (CFrame.new(v8, v20) * CFrame.Angles(0, 0, v17) * CFrame.Angles(
							math.acos((math.clamp(
								6.123233995736766e-17 + 0.9999999999999999 * (math.noise(v11, v10, 2.7) + 0.5),
								-1,
								1
							))),
							0,
							0
						) * CFrame.new(0, 0, -v18)).Position or v20
					end

					v2:_UpdateGeometry(_Part, v9, v3, noiseBetween, v7, position)
					v2:_UpdateColor(_Part, v9, v3)
					v8 = v20
					v7 = position
				end
			else
				v2:Destroy()
			end
		elseif v2._PartsHidden == false then
			v2._PartsHidden = true
			v2:_Disable()
		end
	end

	debug.profileend()
end)
return LightningBolt