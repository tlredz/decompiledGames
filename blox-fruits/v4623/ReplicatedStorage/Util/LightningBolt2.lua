local clock = os.clock
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)

if RunService:IsServer() or not RunService:IsRunning() or GlobalUtil.FFlags.IsUnitTest == true then
	return {}
end

local folder = Instance.new("Folder")
folder.Name = "LightningCache"
folder.Parent = Workspace:WaitForChild("_WorldOrigin")
local part = Instance.new("Part")
part.TopSurface = 0
part.BottomSurface = 0
part.Anchored = true
part.CanCollide = false
part.Locked = true
part.CastShadow = false
part.CanTouch = false
part.CanQuery = false
part.Shape = "Block"
part.Name = "BoltPart"
part.Material = Enum.Material.Neon
part.Color = Color3.new(1, 1, 1)
part.Transparency = 1
local PartCache = require(script.Parent:WaitForChild("PartCache"))
local v = {}

for _ = 1, 50 do
	local model = Instance.new("Model")
	model.Name = "SubFolder"
	model.Parent = folder
	local v2 = PartCache.new(part, 25)
	v2:SetCacheParent(model)
	table.insert(v, v2)
end

local function CubicBezier(p, p2, p3, p4, p5)
	return p2 * (1 - p) ^ 3 + p3 * 3 * p * (1 - p) ^ 2 + p4 * 3 * (1 - p) * p ^ 2 + p5 * p ^ 3
end

local function DiscretePulse(p, p2, p3, p4, p5, p6, p7)
	return (math.clamp(p4 / (2 * p5) - math.abs((p - p2 * p3 + 0.5 * p4) / p5), math.min(p6, p7), (math.max(p7, p6))))
end

local function ExtrudeCenter(p)
	return (math.exp(-5000 * (p - 0.5) ^ 10))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function NoiseBetween(p, p2, p3, minThicknessMultiplier, maxThicknessMultiplier)
	return minThicknessMultiplier + (maxThicknessMultiplier - minThicknessMultiplier) * (math.noise(p, p2, p3) + 0.5)
end

local inverse = CFrame.lookAt(Vector3.new(), vector.create(1, 0, 0)):inverse()
local v2 = {}
local v3 = 0
local count = 0
local heartbeatConnection = nil
local fn
local fn2
local v4 = nil
local LightningBolt2 = {
	__type = "LightningBolt"
}
LightningBolt2.__index = LightningBolt2
LightningBolt2.VERSION = 1.1

function LightningBolt2.new(attachment, attachment2, value)
	local self = setmetatable({}, LightningBolt2)
	self.UpdateRate = 0.016666666666666666
	self._LastUpdate = clock()
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
	self._PartsHidden = false
	self._DisabledTransparency = 1
	self._StartT = clock()
	self._RanNum = math.random() * 100
	count += 1
	self._RefIndex = count
	self._Destroyed = false

	for i = 1, value or 30 do
		self._Parts[i] = v[1 + self._RefIndex % 50]:GetPart()
	end

	v2[self._RefIndex] = self
	v3 += 1
	fn()
	return self
end

function LightningBolt2:Destroy()
	if self._Destroyed then
		return
	end

	self._Destroyed = true
	v2[self._RefIndex] = nil
	v3 -= 1

	if v3 == 0 then
		fn2()
	end

	for i = 1, #self._Parts do
		v[1 + self._RefIndex % 50]:ReturnPart(self._Parts[i])
	end
end

function LightningBolt2:DestroyDissipate(value, value2)
	local v5 = value or 0.2
	local v6 = value2 or 0.5
	local now = clock()
	local minTransparency = self.MinTransparency
	local contractFrom = self.ContractFrom
	local v7 = self.ContractFrom + 1 / (#self._Parts * self.FadeLength)
	local maxRadius = self.MaxRadius
	local minThicknessMultiplier = self.MinThicknessMultiplier
	local heartbeatConnection2 = nil
	heartbeatConnection2 = RunService.Heartbeat:Connect(function()
		local v8 = clock() - now
		self.MinThicknessMultiplier = minThicknessMultiplier + (-2 - minThicknessMultiplier) * v8 / v5

		if v8 < v5 * 0.4 then
			local v9 = v8 / (v5 * 0.4)
			self.MinTransparency = minTransparency + (contractFrom - minTransparency) * v9
		elseif v8 < v5 then
			local v9 = (v8 - v5 * 0.4) / (v5 * 0.6)
			self.MinTransparency = contractFrom + (v7 - contractFrom) * v9
			self.MaxRadius = maxRadius * (1 + v6 * v9)
			self.MinRadius += (self.MaxRadius - self.MinRadius) * v9
		else
			if clock() - self._StartT < (self.PulseLength + 1) / self.PulseSpeed then
				self:Destroy()
			end

			heartbeatConnection2:Disconnect()
			heartbeatConnection2 = nil
		end
	end)
end

local v5 = {}
local v6 = {}

function LightningBolt2:_UpdateGeometry(p, p2, p3, p4, p5, p6)
	local v7 = 1 - self.MaxTransparency
	local v8 = 1 - self.MinTransparency
	local opacityProfileFunction = self.OpacityProfileFunction(
		p2,
		p3,
		self.PulseSpeed,
		self.PulseLength,
		self.FadeLength,
		v7,
		v8
	)
	local v9 = self.Thickness * p4 * opacityProfileFunction
	local v10 = v9 > 0 and opacityProfileFunction or 0
	local v11 = 1 - self.ContractFrom
	local count2 = #self._Parts

	if v11 < v10 then
		p.Size = Vector3.new((p6 - p5).Magnitude, v9, v9)
		table.insert(v5, p)
		table.insert(v6, CFrame.lookAt((p5 + p6) * 0.5, p6) * inverse)
		p.Transparency = 0
	else
		if not (v11 - 1 / (count2 * self.FadeLength) < v10) then
			p.Transparency = 1
			return
		end

		local v12 = (1 - (v10 - (v11 - 1 / (count2 * self.FadeLength))) * count2 * self.FadeLength) * (p2 < p3 * self.PulseSpeed - 0.5 * self.PulseLength and 1 or -1)
		p.Size = Vector3.new((1 - math.abs(v12)) * (p6 - p5).Magnitude, v9, v9)
		table.insert(v5, p)
		table.insert(v6, CFrame.lookAt(p5 + (p6 - p5) * (math.max(0, v12) + (1 - math.abs(v12)) * 0.5), p6) * inverse)
		p.Transparency = 0
	end
end

function LightningBolt2:_UpdateColor(p, p2, p3)
	if typeof(self.Color) == "Color3" then
		p.Color = self.Color
		return
	end

	local v7 = (self._RanNum + p2 - p3 * self.ColorOffsetSpeed) % 1
	local keypoints = self.Color.Keypoints

	for i = 1, #keypoints - 1 do
		if not (keypoints[i].Time < v7 and v7 < keypoints[i + 1].Time) then
			continue
		end

		p.Color = keypoints[i].Value:lerp(
			keypoints[i + 1].Value,
			(v7 - keypoints[i].Time) / (keypoints[i + 1].Time - keypoints[i].Time)
		)
		break
	end
end

function LightningBolt2:_Disable()
	self.Enabled = false

	for _, _Part in ipairs(self._Parts) do
		_Part.Transparency = self._DisabledTransparency
	end
end

local flag = false
local flag2 = false

local function updateBranches()
	v4 = v4 or require(game.ReplicatedStorage.Global)

	if v4.FastMode then
		flag = not flag

		if flag then
			return
		end
	end

	if flag2 then
		return
	end

	flag2 = true

	for _, v7 in pairs(v2) do
		if v7.Enabled == true then
			if not (clock() - v7._LastUpdate < v7.UpdateRate) then
				v7._LastUpdate = clock()
				v7._PartsHidden = false
				local minRadius = v7.MinRadius
				local maxRadius = v7.MaxRadius
				local _Parts = v7._Parts
				local count2 = #_Parts
				local _RanNum = v7._RanNum
				local animationSpeed = v7.AnimationSpeed
				local frequency = v7.Frequency
				local minThicknessMultiplier = v7.MinThicknessMultiplier
				local maxThicknessMultiplier = v7.MaxThicknessMultiplier
				local v8 = clock() - v7._StartT
				local spaceCurveFunction = v7.SpaceCurveFunction
				local radialProfileFunction = v7.RadialProfileFunction
				local v9 = (v7.PulseLength + 1) / v7.PulseSpeed
				local attachment0 = v7.Attachment0
				local attachment1 = v7.Attachment1
				local curveSize0 = v7.CurveSize0
				local curveSize1 = v7.CurveSize1
				local worldPosition = attachment0.WorldPosition
				local v10 = attachment0.WorldPosition + attachment0.WorldAxis * curveSize0
				local v11 = attachment1.WorldPosition - attachment1.WorldAxis * curveSize1
				local worldPosition2 = attachment1.WorldPosition
				local v12 = spaceCurveFunction(0, worldPosition, v10, v11, worldPosition2)

				if v8 < v9 then
					local v13 = v12

					for i = 1, count2 do
						local _Part = _Parts[i]
						local v14 = i / count2
						local v15 = animationSpeed * -v8 + frequency * 10 * v14 - 0.2 + _RanNum * 4
						local v16 = 5 * (animationSpeed * 0.01 * -v8 / 10 + frequency * v14) + _RanNum * 4
						local v17 = 5 * v15
						local v18 = 1 * v16
						local v19 = 0 + 0.6283185307179586 * (math.noise(v17, 1.5, v18) + 0.5)
						local v20 = 0.5 * v15
						local v21 = 0.1 * v16
						local v22 = v19 + (0 + 5.654866776461628 * (math.noise(v20, 1.5, v21) + 0.5))
						local v23 = NoiseBetween(3.4, v16, v15, minRadius, maxRadius) * radialProfileFunction(v14)
						local noiseBetween = NoiseBetween(2.3, v16, v15, minThicknessMultiplier, maxThicknessMultiplier) -- equivalent call inferred; original call site unknown
						local v25 = spaceCurveFunction(v14, worldPosition, v10, v11, worldPosition2)
						local position

						if i == count2 then
							position = v25
						else
							position = (CFrame.new(v13, v25) * CFrame.Angles(0, 0, v22) * CFrame.Angles(
								math.acos((math.clamp(
									6.123233995736766e-17 + 0.9999999999999999 * (math.noise(v16, v15, 2.7) + 0.5),
									-1,
									1
								))),
								0,
								0
							) * CFrame.new(0, 0, -v23)).Position or v25
						end

						v7:_UpdateGeometry(_Part, v14, v8, noiseBetween, v12, position)
						v7:_UpdateColor(_Part, v14, v8)
						v13 = v25
						v12 = position
					end

					v7.LastPoint = spaceCurveFunction(v8 / v9, worldPosition, v10, v11, worldPosition2)
				else
					v7.LastPoint = spaceCurveFunction(1, worldPosition, v10, v11, worldPosition2)
					v7:Destroy()
				end
			end
		elseif v7._PartsHidden == false then
			v7._PartsHidden = true
			v7:_Disable()
		end
	end

	Workspace:BulkMoveTo(v5, v6, Enum.BulkMoveMode.FireCFrameChanged)
	table.clear(v5)
	table.clear(v6)
	flag2 = false
end

fn = function()
	if heartbeatConnection == nil and v3 > 0 then
		heartbeatConnection = RunService.Heartbeat:Connect(updateBranches)
	end
end

fn2 = function()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

return LightningBolt2