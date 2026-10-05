game:GetService("AssetService")
local ArcMesh = {}
ArcMesh.__index = ArcMesh

local function evalNumberSequence(sequence, p: number)
	local keypoints = sequence.Keypoints

	if p <= keypoints[1].Time then
		return keypoints[1].Value
	end

	for i = 1, #keypoints - 1 do
		local keypoint = keypoints[i]
		local keypoint2 = keypoints[i + 1]

		if not (p <= keypoint2.Time) then
			continue
		end

		local v = (p - keypoint.Time) / math.max(1e-9, keypoint2.Time - keypoint.Time)
		return keypoint.Value + (keypoint2.Value - keypoint.Value) * v
	end

	return keypoints[#keypoints].Value
end

function ArcMesh.new(value: number, radius: number, cf: CFrame, value2: number?, value3: number?)
	local self = setmetatable({}, ArcMesh)
	self.arcDegrees = math.clamp(value, 0.001, 360)
	self.radius = radius
	self.cf = cf
	self.outerSegments = value2 or 64
	self.radialSegments = value3 or 6
	self.color = Color3.new(1, 1, 1)
	self._part = script.Part:Clone()
	self._meshPart = self._part
	self._part.Parent = workspace
	self._part.CFrame = cf * CFrame.Angles(0, -math.rad(-value / 2 + 180), 0)
	self._part.SurfaceGui.Frame.ImageLabel.UIGradient.Rotation = value + -90
	self._part.Size = Vector3.new(radius * 3.14, 0.1, radius * 3.14)
	return self
end

function ArcMesh:TweenTransparency(p2, p3: number)
	if self._part then
		local TweenService = game:GetService("TweenService")
		return TweenService:Create(self._part.SurfaceGui.Frame.ImageLabel, p2, {
			ImageTransparency = p3
		})
	end

	local TweenService = game:GetService("TweenService")
	return TweenService:Create(self._meshPart, p2, {
		Transparency = p3
	})
end

function ArcMesh:GetPart()
	return self._meshPart
end

function ArcMesh:UpdateTransparency(p, value: number?)
	local _em = self._em
	local v = table.create(self.radialSegments + 1)
	local v2 = value or 0

	for i = 1, self.radialSegments + 1 do
		local v3 = ((i - 1) / self.radialSegments + v2) % 1
		local v4 = math.clamp(evalNumberSequence(p, v3), 0, 1)
		v[i] = _em:AddColor(self.color, v4)
	end

	for _, face in ipairs(self.faces) do
		if face.pattern == "ioo" then
			_em:SetFaceColors(face.id, { v[face.inner], v[face.outer], v[face.outer] })
		else
			_em:SetFaceColors(face.id, { v[face.inner], v[face.inner], v[face.outer] })
		end
	end
end

return ArcMesh