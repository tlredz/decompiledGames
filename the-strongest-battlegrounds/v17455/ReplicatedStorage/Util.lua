game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Util = {}
local v = {}
local v2 = {}
local random = Random.new(12312)

function Util.EmitParticlesAlt(_, folder)
	for _, emitter in pairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"), emitter:GetAttribute("EmitDelay"))
		end
	end
end

function Util.AddToCoreLoop(_, p)
	table.insert(v, p)
end

function Util.FetchQuickPart(_)
	local part = Instance.new("Part")
	part.Anchored = false
	part.CanCollide = false
	part.Transparency = 1
	part.CanCollide = false
	part.CastShadow = false
	part.Massless = true
	part.CanQuery = false
	return part
end

function Util:AddTempFunction(callback, _: boolean)
	local v3 = {
		callback = callback,
		Creation = os.clock(),
		HasWarned = false,
		traceback = debug.traceback()
	} or {
		callback = callback,
		DONTWARN = true
	}
	table.insert(v2, v3)
end

function Util.BindWithSpacing(_, callback, p, p2, callback2)
	local lastTime = os.clock()
	local v3 = lastTime
	local v4 = false
	Util:AddTempFunction(function()
		local v5 = os.clock() - v3

		if p < v5 then
			v3 = os.clock() + p
			local v6 = (os.clock() - lastTime) / p2
			local lerped = Lerp(1, 0, v6)
			callback((os.clock() - lastTime) / p2, v5, lerped, os.clock() - lastTime)
		end

		if not v4 and p2 < os.clock() - lastTime then
			v4 = true

			if callback2 then
				callback2((os.clock() - lastTime) / p2, v5)
			end

			return true
		end
	end)
end

function Util.FadePointLightIn(_, state, duration: number)
	local brightness = state.Brightness
	local range = state.Range
	state.Brightness = 0
	state.Range = 0
	TweenService:Create(state, TweenInfo.new(duration), {
		Brightness = brightness,
		Range = range
	}):Play()
end

function Util.DisableAllVisuals(_, folder)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("PointLight")) then
			continue
		end

		descendant.Enabled = false
	end
end

function Util.EnabledAllVisuals(_, folder)
	for _, descendant in pairs(folder:GetDescendants()) do
		if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("PointLight")) then
			continue
		end

		descendant.Enabled = true
	end
end

function Util.EmitAllParticles(_, folder)
	for _, emitter in ipairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter.Rate)
		end
	end
end

function Util.ScaleParticles(_, folder, p)
	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local numberSequenceKeypoints = {}

		for i = 1, #emitter.Size.Keypoints do
			table.insert(
				numberSequenceKeypoints,
				NumberSequenceKeypoint.new(
					emitter.Size.Keypoints[i].Time,
					emitter.Size.Keypoints[i].Value * p,
					emitter.Size.Keypoints[i].Envelope
				)
			)
		end

		emitter.Speed = NumberRange.new(emitter.Speed.Min * p, emitter.Speed.Max * p)
		emitter.Acceleration *= p
		emitter.Size = NumberSequence.new(numberSequenceKeypoints)
		table.clear(numberSequenceKeypoints)
	end
end

function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function Util.Lerp(_, p, p2, p3)
	return p + (p2 - p) * p3
end

function Util.ReturnRandomAngle(_)
	return CFrame.Angles(random:NextNumber(-360, 360), random:NextNumber(-360, 360), random:NextNumber(-360, 360))
end

function Util.ConvertNormalPosToCF(_, p, p2)
	local upVector = CFrame.lookAt(p2, p2 + p).UpVector
	local cross = upVector:Cross(p)
	return CFrame.fromMatrix(p2, -cross, p, upVector)
end

function Util.UnixConnection2(_, p, callback, callback2, callback3)
	local v3 = false
	local flag = false
	local lastTime = tick()
	Util:AddTempFunction(function(p2)
		v3 = not (lastTime + p > tick())

		if callback and (callback2 and callback2() or callback2 == nil) and not v3 then
			local v4 = (tick() - lastTime) / p
			callback(v4, p2, Lerp(1, 0, v4), tick() - lastTime)
		else
			if flag then
				return
			end

			flag = true

			if callback and v3 then
				callback(1, p2, 0, p)
			end

			if callback3 then
				callback3(1, p2, 0)
			end

			return true
		end
	end)
end

function Util.UnixConnection(_, p: number, callback, callback2, callback3)
	local renderStepped

	if RunService:IsClient() then
		renderStepped = RunService.RenderStepped
	else
		renderStepped = RunService.Heartbeat
	end

	local connection = nil
	local v3 = false
	local lastTime = os.clock()
	local v4 = false
	connection = renderStepped:Connect(function(p2)
		if not v4 then
			v4 = true
			v3 = not (lastTime + p > os.clock())

			if callback and (callback2 and callback2() or callback2 == nil) and not v3 then
				local v5 = (os.clock() - lastTime) / p
				callback(v5, p2, Lerp(1, 0, v5), os.clock() - lastTime)
			else
				connection:Disconnect()

				if callback and v3 then
					callback(1, p2, 0, p)
				end

				if callback3 then
					callback3(1, p2, 0)
				end
			end

			v4 = false
		end
	end)
	return connection
end

function Util.UnixWithFrequency(_, p, p2, callback, callback2)
	local lastTime = os.clock()
	local heartbeat

	if RunService:IsServer() then
		heartbeat = RunService.Heartbeat
	else
		heartbeat = RunService.RenderStepped
	end

	local now = lastTime
	local connection = nil
	connection = heartbeat:Connect(function(_)
		local v3 = os.clock() - now

		if p2 < v3 then
			now = os.clock()
			callback((os.clock() - lastTime) / p, v3)
		end

		if connection and p < os.clock() - lastTime then
			connection:Disconnect()
			connection = nil

			if callback2 then
				callback2(1, v3)
			end
		end
	end)
end

local v3

if RunService:IsServer() then
	v3 = RunService.Heartbeat
else
	v3 = RunService.RenderStepped
end

v3:Connect(function(p)
	for _, v4 in pairs(v) do
		v4(p)
	end

	for _, v4 in pairs(v2) do
		if v4.callback(p) then
			table.remove(v2, table.find(v2, v4))
		end
	end
end)
return Util