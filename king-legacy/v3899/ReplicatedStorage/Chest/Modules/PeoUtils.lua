local createVector = vector.create
local PeoUtils = {}
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local folder = nil
local folder2 = nil
local bindableEvent = Instance.new("BindableEvent")
local v = {}

if RunService:IsClient() then
	folder = Instance.new("Folder")
	folder.Name = "Sound Repository Client"
	folder.Parent = ReplicatedStorage
elseif RunService:IsServer() then
	folder2 = Instance.new("Folder")
	folder2.Name = "Sound Repository Server"
	folder2.Parent = ReplicatedStorage
end

function PeoUtils.ResizeParticlesByFactor(folder3, value: number)
	if not folder3 then
		return
	end

	local v2 = value or 1

	for _, emitter in pairs(folder3:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local numberSequenceKeypoints = {}

		for _, keypoint in pairs(emitter.Size.Keypoints) do
			table.insert(
				numberSequenceKeypoints,
				NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * v2, keypoint.Envelope * v2)
			)
		end

		emitter.Size = NumberSequence.new(numberSequenceKeypoints)
	end
end

function PeoUtils.EmitParticles(folder3)
	if not folder3 then
		return
	end

	for _, emitter in pairs(folder3:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")
		local emitDelay = emitter:GetAttribute("EmitDelay")
		local emitDuration = emitter:GetAttribute("EmitDuration")

		if emitDuration then
			local v2 = emitDelay
			local v3 = emitter
			local v4 = emitDuration
			task.spawn(function()
				if v2 then
					task.wait(v2)
				end

				v3.Enabled = true
				task.wait(v4)
				v3.Enabled = nil
			end)
		end

		if emitDelay then
			local v2 = emitter
			local v3 = emitCount
			task.delay(emitDelay, function()
				v2:Emit(v3 or 0)
			end)
		elseif emitCount then
			emitter:Emit(emitCount)
		end
	end

	return true
end

function PeoUtils.EmitParticlesAndExecute(folder3, callback)
	if not folder3 then
		return
	end

	for _, emitter in pairs(folder3:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")
		local emitDelay = emitter:GetAttribute("EmitDelay")

		if emitDelay then
			local v2 = emitter
			local v3 = emitCount
			task.delay(emitDelay, function()
				v2:Emit(v3 or 0)

				if callback then
					task.defer(callback, v2)
				end
			end)
		elseif emitCount then
			emitter:Emit(emitCount)

			if callback then
				task.defer(callback, emitter)
			end
		end
	end

	return true
end

function PeoUtils.ValidateBeforeEmitParticles(folder3, callback)
	if not (folder3 and callback) then
		return
	end

	for _, emitter in pairs(folder3:GetDescendants()) do
		if not (emitter:IsA("ParticleEmitter") and callback(emitter)) then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")
		local emitDelay = emitter:GetAttribute("EmitDelay")

		if emitDelay then
			local v2 = emitter
			local v3 = emitCount
			task.delay(emitDelay, function()
				v2:Emit(v3 or 0)
			end)
		elseif emitCount then
			emitter:Emit(emitCount)
		end
	end

	return true
end

function PeoUtils.SetParticleEnabled(folder3, enabled: boolean)
	if not folder3 then
		return
	end

	for _, emitter in pairs(folder3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end

	return true
end

function PeoUtils.CreateSound(p)
	local name = "(" .. (p.Name or "N/A") .. ") " .. (p.SoundId or "N/A")
	local parent = nil

	if RunService:IsClient() then
		parent = folder
	elseif RunService:IsServer() then
		parent = folder2
	end

	local v4 = parent:FindFirstChild(name)

	if not v4 then
		v4 = Instance.new("Sound")

		for k, v5 in pairs(p) do
			local v6 = k
			local v7 = v5
			local _, result = pcall(function()
				v4[v6] = v7
			end)

			if result then
				print(result)
			end
		end

		v4.Name = name
		v4.Parent = parent
	end

	local clone = v4:Clone()
	clone.Name = p.Name or "N/A"
	return clone
end

function PeoUtils.CFrameLookAt(vector2: Vector3, vector3: Vector3)
	local unit = (vector3 - vector2).Unit
	local vector4 = -(unit ~= unit and createVector(0, 0, -1) or unit)
	local cross = vector4:Cross(createVector(0, -1, 0))
	local cross2 = vector4:Cross(cross)
	return CFrame.fromMatrix(vector2, cross, cross2, vector4)
end

function PeoUtils.DeferredTask(callback)
	local v2 = {}
	local callbacks = {}
	local v3 = "Processing"
	local v4 = nil

	function v2.AndThen(_, callback2)
		if v3 == "Processing" then
			table.insert(callbacks, callback2)
		else
			callback2(unpack(v4))
		end

		return v2
	end

	local function Resolve(...)
		v4 = { ... }
		v3 = "Resolved"

		for _, v5 in pairs(callbacks) do
			v5(unpack(v4))
		end
	end

	coroutine.wrap(function()
		local _, _ = pcall(callback, Resolve)
	end)()
	return v2
end

function PeoUtils.Trajectory(vector2: Vector3, vector3: Vector3, p: number)
	local gravity = workspace.Gravity
	local v2 = vector3 - vector2
	local vector4 = Vector3.new(v2.X, 0, v2.Z)
	local magnitude = vector4.Magnitude
	local Y = v2.Y
	local v3 = math.rad(p)
	local v4 = gravity * magnitude ^ 2
	local v5 = math.cos(v3) ^ 2 * 2 * (magnitude * math.tan(v3) - Y)

	if v5 <= 0 then
		return PeoUtils.TimedTrajectory(vector2, vector3, 1)
	end

	local v6 = math.sqrt(v4 / v5)

	if v6 == v6 then
		return vector4.Unit * v6 * math.cos(v3) + Vector3.new(0, v6 * math.sin(v3), 0)
	end
end

function PeoUtils.TimedTrajectory(vector2: Vector3, vector3: Vector3, p: number)
	local gravity = workspace.Gravity
	local v2 = vector3 - vector2
	local vector4 = Vector3.new(v2.X, 0, v2.Z)
	local Y = v2.Y
	return vector4 / p + Vector3.new(0, (Y + 0.5 * gravity * p ^ 2) / p, 0)
end

function PeoUtils.Dust(_, p, value: number)
	if not p then
		return
	end

	local v2 = value or 1

	if typeof(v2) ~= "number" or v2 <= 0 then
		return
	end

	bindableEvent:Fire(p, v2)
end

function PeoUtils.GetMobCenterPosition(p: string)
	local monster = workspace:FindFirstChild("Monster")

	if not monster then
		return nil
	end

	local v2 = createVector(0, 0, 0)
	local count = 0

	for _, folder3 in ipairs(monster:GetChildren()) do
		if not folder3:IsA("Folder") then
			continue
		end

		for _, model in ipairs(folder3:GetChildren()) do
			if not (model:IsA("Model") and model.Name == p and model.PrimaryPart) then
				continue
			end

			v2 += model.PrimaryPart.Position
			count += 1
		end
	end

	if count == 0 then
		return nil
	end

	return v2 / count
end

function PeoUtils.KillThread(list)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function Kill(p)
		local v2 = v[p]

		if v2 then
			v2._Dead = true
			v[p] = nil
		end
	end

	if typeof(list) == "table" then
		for _, v2 in ipairs(list) do
			Kill(v2) -- equivalent call inferred; original call site unknown
		end
	else
		Kill(list) -- equivalent call inferred; original call site unknown
	end
end

bindableEvent.Event:Connect(function(instance, duration: number)
	PeoUtils.KillThread(instance)
	local v2 = {}

	if typeof(instance) == "table" then
		for _, v3 in ipairs(instance) do
			v2[v3] = {
				_Dead = false
			}
			v[v3] = v2[v3]
		end
	else
		v2[instance] = {
			_Dead = false
		}
		v[instance] = v2[instance]
	end

	task.delay(duration, function()
		if typeof(instance) == "table" then
			for _, v3 in ipairs(instance) do
				local v4 = v2[v3]

				if not v4 or v4._Dead then
					continue
				end

				if v3 and v3:IsDescendantOf(game) then
					v3:Destroy()
				end

				PeoUtils.KillThread(v3)
			end

			table.clear(v2)
		else
			local v3 = v2[instance]

			if not v3 or v3._Dead then
				return
			end

			if instance and instance:IsDescendantOf(game) then
				instance:Destroy()
			end

			PeoUtils.KillThread(instance)
			table.clear(v2)
		end
	end)
end)

function PeoUtils.GetAnimator(parent)
	if not parent then
		return
	end

	local v2 = parent:FindFirstChildOfClass("Animator")

	if RunService:IsClient() then
		return v2 or parent
	end

	if not v2 then
		v2 = Instance.new("Animator")
		v2.Parent = parent
	end

	return v2
end

function PeoUtils.PlayOneShotAnim(data, animation, fadeTime: number, speed, priority)
	if not data then
		warn("forgot animator!")
		return
	end

	local animator

	if typeof(data) == "table" then
		animator = data.Animator
		animation = data.Animation
		fadeTime = data.FadeTime
		speed = data.Speed
		priority = data.Priority
	else
		animator = data
	end

	if typeof(animation) == "string" then
		local v2 = ReplicatedStorage.Chest.Animation.AnimationUtils:FindFirstChild(animation)

		if not v2 then
			v2 = Instance.new("Animation")
			v2.Name = animation
			v2.AnimationId = animation
			v2.Parent = ReplicatedStorage.Chest.Animation.AnimationUtils
		end

		animation = v2
	end

	if animator:IsA("Humanoid") then
		local v2 = animator:FindFirstChildOfClass("Animator")

		if RunService:IsServer() and not v2 then
			v2 = Instance.new("Animator")
			v2.Parent = animator
		end

		animator = v2 or animator
	end

	local track = animator:LoadAnimation(animation)
	track:Play(fadeTime or 0.1)
	track:AdjustSpeed(speed or 1)
	track.Priority = priority or track.Priority
	local stoppedConnection = nil
	stoppedConnection = track.Stopped:Once(function()
		track:Destroy()

		if stoppedConnection then
			stoppedConnection:Disconnect()
			stoppedConnection = nil
		end
	end)
	return track
end

function PeoUtils.StopOneShotAnim(p, p2, fadeTime: number)
	if not p then
		warn("forgot animator!")
		return
	end

	local animator

	if typeof(p) == "table" then
		animator = p.Animator
		fadeTime = p.FadeTime
	else
		animator = p
	end

	if animator:IsA("Humanoid") then
		local v2 = animator:FindFirstChildOfClass("Animator")

		if RunService:IsServer() and not v2 then
			v2 = Instance.new("Animator")
			v2.Parent = animator
		end

		animator = v2 or animator
	end

	if animator then
		for _, v2 in ipairs(animator:GetPlayingAnimationTracks()) do
			if v2.Name == p2 then
				v2:Stop(fadeTime or 0.1)
			end
		end
	end
end

function PeoUtils.RandomUniqueId()
	return (HttpService:GenerateGUID(false):gsub("-", ""):sub(1, 10):gsub(".", function(value)
		if math.random() < 0.5 then
			value = string.upper(value) or value
		end

		return value
	end))
end

function PeoUtils:LerpCF(data, cframe: CFrame)
	local cFrame = self.CFrame
	local v2 = 0
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		v2 = math.min(v2 + dt / data.Time, 1)
		local value = TweenService:GetValue(
			v2,
			data.EasingStyle or Enum.EasingStyle.Linear,
			data.EasingDirection or Enum.EasingDirection.InOut
		)

		if not self:GetAttribute("NoLerp") then
			self.CFrame = cFrame:Lerp(cframe, value)
		elseif heartbeatConnection and heartbeatConnection.Connected then
			heartbeatConnection:Disconnect()
		end
	end)
	task.delay(data.Time + 0.001, function()
		if heartbeatConnection and heartbeatConnection.Connected then
			heartbeatConnection:Disconnect()
		end

		heartbeatConnection = nil
	end)
end

function PeoUtils.RandomTableWeight(items)
	local total = 0

	for _, item in pairs(items) do
		total += item
	end

	local number = Random.new():NextNumber(0, total)
	local total2 = 0

	for k, item in pairs(items) do
		total2 += item

		if number <= total2 then
			return k
		end
	end
end

function PeoUtils.GetAttachment(parent)
	if not parent then
		return
	end

	local v2 = parent:FindFirstChildOfClass("Attachment")

	if not v2 then
		v2 = Instance.new("Attachment")
		v2.Parent = parent
	end

	return v2
end

function PeoUtils.FindNearestTarget() end

return PeoUtils