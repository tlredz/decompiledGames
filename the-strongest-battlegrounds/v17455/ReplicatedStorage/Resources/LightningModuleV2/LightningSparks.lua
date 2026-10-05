local parentModule = require(script.Parent)
local v = {}
local random = Random.new()
local LightningSparks = {}
LightningSparks.__index = LightningSparks

function LightningSparks.new(lightningBolt, value)
	local self = setmetatable({}, LightningSparks)
	self.Enabled = true
	self.LightningBolt = lightningBolt
	self.MaxSparkCount = value or 10
	self.MinSpeed = 4
	self.MaxSpeed = 6
	self.MinDistance = 3
	self.MaxDistance = 6
	self.MinPartsPerSpark = 8
	self.MaxPartsPerSpark = 10
	self.SparksN = 0
	self.SlotTable = {}
	self.RefIndex = #v + 1
	v[self.RefIndex] = self
	return self
end

function LightningSparks:Destroy()
	v[self.RefIndex] = nil

	for k, v2 in pairs(self.SlotTable) do
		if v2.Parts[1].Parent == nil then
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

local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function()
	for _, v2 in pairs(v) do
		if v2.Enabled == true and v2.SparksN < v2.MaxSparkCount then
			local lightningBolt = v2.LightningBolt

			if lightningBolt.Parts[1].Parent == nil then
				v2:Destroy()
				break
			end

			local parts = lightningBolt.Parts
			local count = #parts
			local v3 = {}

			for i = 1, #parts do
				if parts[i].Transparency < 0.3 then
					v3[#v3 + 1] = (i - 0.5) / count
				end
			end

			local v4, v5

			if #v3 ~= 0 then
				v4 = math.ceil(v3[1] * v2.MaxSparkCount)
				v5 = math.ceil(v3[#v3] * v2.MaxSparkCount)
			end

			for _ = 1, random:NextInteger(1, v2.MaxSparkCount - v2.SparksN) do
				if #v3 == 0 then
					break
				end

				local v6 = {}

				for i = v4, v5 do
					if v2.SlotTable[i] == nil then
						v6[#v6 + 1] = i
					end
				end

				if #v6 == 0 then
					continue
				end

				local v7 = v6[random:NextInteger(1, #v6)]
				local number = random:NextNumber(-0.5, 0.5)
				local v8 = (v7 - 0.5 + number) / v2.MaxSparkCount
				local v9 = 10
				local v10 = 1

				for i = 1, #v3 do
					local v11 = math.abs(v3[i] - v8)

					if not (v11 < v9) then
						continue
					end

					v10 = math.floor(v3[i] * count + 0.5 + 0.5)
					v9 = v11
				end

				local part = parts[v10]
				local v11 = {
					WorldPosition = part.Position + number * part.CFrame.RightVector * part.Size.X
				}
				local v12 = {
					WorldPosition = v11.WorldPosition + RandomVectorOffset(part.CFrame.RightVector, 0.7853981633974483) * random:NextNumber(
						v2.MinDistance,
						v2.MaxDistance
					)
				}
				v11.WorldAxis = (v12.WorldPosition - v11.WorldPosition).Unit
				v12.WorldAxis = v11.WorldAxis
				local v13 = parentModule.new(v11, v12, random:NextInteger(v2.MinPartsPerSpark, v2.MaxPartsPerSpark))
				v13.MinRadius = 0
				v13.MaxRadius = 0.8
				v13.AnimationSpeed = 0
				v13.Thickness = part.Size.Y / 2
				v13.MinThicknessMultiplier = 1
				v13.MaxThicknessMultiplier = 1
				v13.PulseLength = 0.5
				v13.PulseSpeed = random:NextNumber(v2.MinSpeed, v2.MaxSpeed)
				v13.FadeLength = 0.25
				local HSV, _, v14 = Color3.toHSV(part.Color)
				v13.Color = Color3.fromHSV(HSV, 0.5, v14)
				v2.SlotTable[v7] = v13
			end
		end

		local count = 0

		for k, v3 in pairs(v2.SlotTable) do
			if v3.Parts[1].Parent == nil then
				v2.SlotTable[k] = nil
			else
				count += 1
			end
		end

		v2.SparksN = count
	end
end)
return LightningSparks