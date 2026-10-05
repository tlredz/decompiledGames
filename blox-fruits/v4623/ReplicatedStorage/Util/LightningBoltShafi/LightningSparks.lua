local parentModule = require(script.Parent)
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local RunService = game:GetService("RunService")
local v = {}
local v2 = 0
local count = 0
local heartbeatConnection = nil
local fn
local fn2
local random = Random.new()
local LightningSparks = {}
LightningSparks.__index = LightningSparks

function LightningSparks:new(value)
	local object = setmetatable({}, LightningSparks)
	self.TrackSegmentState = true
	object.Enabled = true
	object.LightningBolt = self
	object.MaxSparkCount = value or 10
	object.MinSpeed = 4
	object.MaxSpeed = 6
	object.MinDistance = 3
	object.MaxDistance = 6
	object.MinPartsPerSpark = 8
	object.MaxPartsPerSpark = 10
	object.SparksN = 0
	object.SlotTable = {}
	count += 1
	object.RefIndex = count
	object.Destroyed = false
	v[object.RefIndex] = object
	v2 += 1
	fn()
	return object
end

function LightningSparks:Destroy()
	if self.Destroyed then
		return
	end

	self.Destroyed = true
	v[self.RefIndex] = nil
	v2 -= 1

	if v2 == 0 then
		fn2()
	end

	for k, v3 in pairs(self.SlotTable) do
		if v3.Destroyed then
			self.SlotTable[k] = nil
		end
	end
end

function RandomVectorOffset(p, p2)
	return (CFrame.lookAt(Vector3.new(), p) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p2), 1))),
		0,
		0
	)).LookVector
end

if RunService:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	local function updateSparks()
		for _, v3 in pairs(v) do
			local lightningBolt = v3.LightningBolt

			if lightningBolt.Destroyed then
				v3:Destroy()
				break
			end

			if v3.Enabled == true and lightningBolt.Enabled == true and v3.SparksN < v3.MaxSparkCount then
				local points = lightningBolt.Points
				local radii = lightningBolt.Radii
				local opacities = lightningBolt.Opacities
				local segmentCount = lightningBolt.SegmentCount
				local v4 = 1 - lightningBolt.ContractFrom
				local v5 = {}

				for i = 1, segmentCount do
					local opacity = opacities[i]

					if opacity ~= nil and v4 < opacity and points[i + 1] ~= nil then
						v5[#v5 + 1] = (i - 0.5) / segmentCount
					end
				end

				local v6, v7

				if #v5 ~= 0 then
					v6 = math.ceil(v5[1] * v3.MaxSparkCount)
					v7 = math.ceil(v5[#v5] * v3.MaxSparkCount)
				end

				for _ = 1, random:NextInteger(1, v3.MaxSparkCount - v3.SparksN) do
					if #v5 == 0 then
						break
					end

					local v8 = {}

					for i = v6, v7 do
						if v3.SlotTable[i] == nil then
							v8[#v8 + 1] = i
						end
					end

					if #v8 == 0 then
						continue
					end

					local v9 = v8[random:NextInteger(1, #v8)]
					local number = random:NextNumber(-0.5, 0.5)
					local v10 = (v9 - 0.5 + number) / v3.MaxSparkCount
					local v11 = 10
					local v12 = 1

					for i = 1, #v5 do
						local v13 = math.abs(v5[i] - v10)

						if not (v13 < v11) then
							continue
						end

						v12 = math.floor(v5[i] * segmentCount + 0.5 + 0.5)
						v11 = v13
					end

					local point = points[v12]
					local point2 = points[v12 + 1]
					local v13 = point2 - point
					local unit = v13.Unit
					local v14 = {
						WorldPosition = 0.5 * (point + point2) + number * unit * v13.Magnitude
					}
					local v15 = {
						WorldPosition = v14.WorldPosition + RandomVectorOffset(unit, 0.7853981633974483) * random:NextNumber(
							v3.MinDistance,
							v3.MaxDistance
						)
					}
					v14.WorldAxis = (v15.WorldPosition - v14.WorldPosition).Unit
					v15.WorldAxis = v14.WorldAxis
					local v16 = parentModule.new(v14, v15, random:NextInteger(v3.MinPartsPerSpark, v3.MaxPartsPerSpark))
					v16.MinRadius = 0
					v16.MaxRadius = 0.8
					v16.AnimationSpeed = 0
					v16.Thickness = radii[v12]
					v16.MinThicknessMultiplier = 1
					v16.MaxThicknessMultiplier = 1
					v16.PulseLength = 0.5
					v16.PulseSpeed = random:NextNumber(v3.MinSpeed, v3.MaxSpeed)
					v16.FadeLength = 0.25
					local color = lightningBolt.Color

					if typeof(color) ~= "Color3" then
						color = #lightningBolt.Parts ~= 0 and lightningBolt.Parts[v12].Color or lightningBolt.RenderedColor or color.Keypoints[1].Value
					end

					local HSV, _, v17 = Color3.toHSV(color)
					v16.Color = Color3.fromHSV(HSV, 0.5, v17)
					v3.SlotTable[v9] = v16
				end
			end

			local count2 = 0

			for k, v4 in pairs(v3.SlotTable) do
				if v4.Destroyed then
					v3.SlotTable[k] = nil
				else
					count2 += 1
				end
			end

			v3.SparksN = count2
		end
	end

	fn = function()
		if heartbeatConnection == nil and v2 > 0 then
			heartbeatConnection = RunService.Heartbeat:Connect(updateSparks)
		end
	end

	fn2 = function()
		if heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end
else
	fn = function() end

	fn2 = function() end
end

return LightningSparks