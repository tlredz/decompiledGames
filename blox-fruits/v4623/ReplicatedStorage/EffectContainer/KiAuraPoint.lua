local ReplicatedStorage = game:GetService("ReplicatedStorage")
local terrain = workspace.Terrain
local FX = require(ReplicatedStorage.FX)

local function linear(p, p2, p3, p4)
	return p3 * p / p4 + p2
end

local Queue = require(ReplicatedStorage:WaitForChild("Queue"))
local kiAuraPoint = Queue.new("KiAuraPoint", function(_, _, state, p, p2)
	if state.remove then
		local _ = #state.bin > 0
	end

	if state.time > state.duration then
		state.remove = true
	end

	if not state.remove then
		state.counter += p

		if p2 < 0.8 and state.counter > state.rate then
			local _ran = state._ran

			for _ = 1, state.count do
				local clone = state.originalSpike:Clone()
				local attachment = Instance.new("Attachment")
				local attachment2 = Instance.new("Attachment")
				clone.Attachment0 = attachment
				clone.Attachment1 = attachment2
				attachment.Parent = terrain
				attachment2.Parent = terrain
				clone.Parent = terrain
				clone.Enabled = true
				local height = state.riseoffset * math.random()
				local lookVector = (state.cframe * CFrame.Angles(
					_ran() * state.offset,
					_ran() * state.offset,
					_ran() * state.offset
				)).lookVector
				local cf = CFrame.new(state.cframe.p) * CFrame.new(Vector3.new(), lookVector)
				table.insert(state.bin, {
					a0 = attachment,
					a1 = attachment2,
					B = clone,
					i = 0,
					height = height,
					cf = cf
				})
			end

			state.counter = 0
		end
	end

	for _, v in next, state.bin, nil do
		local a0 = v.a0
		local a1 = v.a1
		local B = v.B
		local height = v.height
		local cf = v.cf
		v.i = math.min(v.i + p * state.speed, 1)

		if v.i < 1 then
			if state.color then
				local v2 = state.color.Keypoints[2] and state.color.Keypoints[1].Value:lerp(
					state.color.Keypoints[2].Value,
					v.i
				) or state.color.Keypoints[1].Value
				B.Color = ColorSequence.new(v2)
			end

			B.Width0 = state.width * (1 - v.i * 0.9)
			B.Width1 = B.Width0
			local v2 = 1 + state.height * v.i

			if v.i > state.trans[2] then
				local v3 = v.i - state.trans[2]
				local v4 = 1 - state.trans[2]
				B.Transparency = NumberSequence.new(1 * v3 / v4 + 0)
			elseif v.i < state.trans[1] then
				local i = v.i
				local tran = state.trans[1]
				B.Transparency = NumberSequence.new(-1 * i / tran + 1)
			end

			a0.CFrame = cf * CFrame.new(0, 0, -(height + v.i * state.rise))
			a1.CFrame = cf * CFrame.new(0, 0, -(height - v2 + v.i * state.rise))
		else
			v.removing = true
			B:Destroy()
			a1:Destroy()
			a0:Destroy()
		end
	end

	local v = 1

	while v <= #state.bin do
		local v2 = state.bin[v]

		if v2.removing then
			v2.removing = false
			table.remove(state.bin, v)
			v -= 1
		end

		v += 1
	end
end, 300, 0.002)
return function(state)
	typeof(state.Color)

	if state.Remove then
		for _, v in next, kiAuraPoint.bin, nil do
			local value = v.color.Keypoints[#v.color.Keypoints].Value
			local value2 = v.color.Keypoints[#v.color.Keypoints].Value

			if not (v.cframe == state.CFrame and v.speed == state.Speed and v.rate == state.Rate and v.width == state.Width) then
				continue
			end

			if v.height ~= state.Height then
				continue
			end

			local r = value2.r
			local r2 = value.r
			local v2 = nil or 0.01
			local v3

			if r - v2 < r2 then
				v3 = r2 < r + v2
			else
				v3 = false
			end

			if not v3 then
				continue
			end

			local g = value2.g
			local g2 = value.g
			local v4 = nil or 0.01
			local v5

			if g - v4 < g2 then
				v5 = g2 < g + v4
			else
				v5 = false
			end

			if not v5 then
				continue
			end

			local b = value2.b
			local b2 = value.b
			local v6 = nil or 0.01
			local v7

			if b - v6 < b2 then
				v7 = b2 < b + v6
			else
				v7 = false
			end

			if v7 then
				v.remove = true
			end
		end
	else
		local clone = FX:WaitForChild("AuraSpike"):Clone()

		if #state.Color.Keypoints == 1 then
			clone.Color = state.Color
			state.Color = nil
		end

		if state.LightEmission then
			clone.LightEmission = state.LightEmission
		end

		if state.ZOffset then
			clone.ZOffset = state.ZOffset
		end

		if state.Mode then
			if state.Mode == "Dense" then
				clone.Texture = "rbxassetid://1826184620"
			elseif state.Mode == "ReallyDense" then
				clone.Texture = "rbxassetid://1829270442"
			end
		else
			clone.Texture = "rbxassetid://1826127663"
		end

		local v = 0
		local v2 = 0
		local v4 = {
			renderPoint = state.CFrame.p,
			cframe = state.CFrame,
			color = state.Color,
			rate = state.Rate,
			height = state.Height,
			speed = state.Speed,
			count = state.Count,
			offset = state.Offset or 0,
			width = state.Width or 8,
			rise = 0,
			riseoffset = 0,
			trans = 0,
			originalSpike = 0,
			duration = 0,
			bin = 0,
			counter = 0,
			_ran = 0,
			ran = 0
		}
		v4.height = state.Height or 8
		v4.rise = state.Rise or 5
		v4.riseoffset = state.RiseOffset or 1
		v4.trans = state.FadeInOut or { 0.2, 0.4 }
		v4.originalSpike = clone
		v4.duration = state.Duration or 1
		v4.bin = {}

		function v4._ran()
			v = (v + math.random()) % 1
			return v - 0.5
		end

		function v4.ran()
			while true do
				local v5 = math.random() - 0.5
				local v6 = v2
				local v7 = 0.1 or 0.01
				local v8

				if v5 - v7 < v6 then
					v8 = v6 < v5 + v7
				else
					v8 = false
				end

				if v8 ~= false then
					continue
				end

				v2 = v5
				return v5
			end
		end

		kiAuraPoint:add(v4)
	end
end