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

function LightningSparks.new(lightningBolt, _)
	local self = setmetatable({}, LightningSparks)
	self.LightningBolt = lightningBolt
	self.MaxSparkCount = 1
	self.MinSpeed = 4
	self.MaxSpeed = 6
	self.MinDistance = 3
	self.MaxDistance = 6
	self.MinPartsPerSpark = 2
	self.MaxPartsPerSpark = 4
	self.SparksN = 0
	self.SlotTable = {}
	count += 1
	self.RefIndex = count
	self.Destroyed = false
	v[self.RefIndex] = self
	v2 += 1
	fn()
	return self
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
		if v3.Parts[1].Parent == nil then
			self.SlotTable[k] = nil
		end
	end
end

function RandomVectorOffset(p, p2)
	return (CFrame.new(Vector3.new(), p) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p2), 1))),
		0,
		0
	)).LookVector
end

local color = Color3.new(1, 1, 1)

if RunService:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	local function updateSparks()
		for _, v3 in pairs(v) do
			if v3.SparksN < v3.MaxSparkCount then
				local lightningBolt = v3.LightningBolt

				if lightningBolt.Parts[1].Parent == nil then
					v3:Destroy()
					break
				end

				local parts = lightningBolt.Parts
				local count2 = #parts
				local v4 = {}

				for i = 1, #parts do
					if parts[i].Transparency <= 0 then
						v4[#v4 + 1] = (i - 0.5) / count2
					end
				end

				local v5, v6

				if #v4 ~= 0 then
					v5 = math.ceil(v4[1] * v3.MaxSparkCount)
					v6 = math.ceil(v4[#v4] * v3.MaxSparkCount)
				end

				for _ = 1, random:NextInteger(1, v3.MaxSparkCount - v3.SparksN) do
					if #v4 == 0 then
						break
					end

					local v7 = {}

					for i = v5, v6 do
						if v3.SlotTable[i] == nil then
							v7[#v7 + 1] = i
						end
					end

					if #v7 == 0 then
						continue
					end

					local v8 = v7[random:NextInteger(1, #v7)]
					local number = random:NextNumber(-0.5, 0.5)
					local v9 = (v8 - 0.5 + number) / v3.MaxSparkCount
					local v10 = 10
					local v11 = 1

					for i = 1, #v4 do
						local v12 = math.abs(v4[i] - v9)

						if not (v12 < v10) then
							continue
						end

						v11 = math.floor(v4[i] * count2 + 0.5 + 0.5)
						v10 = v12
					end

					local part = parts[v11]
					local v12 = {
						WorldPosition = part.Position + number * part.CFrame.RightVector * part.Size.X
					}
					local v13 = {
						WorldPosition = v12.WorldPosition + RandomVectorOffset(
							part.CFrame.RightVector,
							0.7853981633974483
						) * random:NextNumber(v3.MinDistance, v3.MaxDistance)
					}
					v12.WorldAxis = (v13.WorldPosition - v12.WorldPosition).Unit
					v13.WorldAxis = v12.WorldAxis
					v12.Parent = "parent"
					v13.Parent = "parent"
					local v14 = parentModule.new(
						v12,
						v13,
						0,
						0,
						random:NextInteger(v3.MinPartsPerSpark, v3.MaxPartsPerSpark),
						part.Color:Lerp(color, 0.333)
					)

					if not v14 then
						continue
					end

					v14.MaxAngleOffset = 1.2217304763960306
					v14.SizingOffset = 0.4
					v14.AnimationSpeed = 0
					v14.Thickness = part.Size.Y / 2
					v14.MinThicknessMultiplier = 1
					v14.MaxThicknessMultiplier = 1
					v14.PulseLength = 0.5
					v14.PulseSpeed = random:NextNumber(v3.MinSpeed, v3.MaxSpeed)
					v14.FadeLength = 0.1
					v3.SlotTable[v8] = v14
				end
			end

			local count2 = 0

			for k, v4 in pairs(v3.SlotTable) do
				if v4.Parts[1].Parent == nil then
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