local UserGameSettings = UserSettings():GetService("UserGameSettings")
game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("RunService")
local thrown = workspace.Thrown
local map = workspace:FindFirstChild("Map")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { map }

local function fn(p)
	local total = 0

	while total < p do
		local RunService = game:GetService("RunService")
		total += RunService.Heartbeat:Wait()
	end

	return total
end

local v = {
	Emit = {
		Fast = {
			0.1,
			0.15,
			0.225,
			0.275,
			0.3,
			0.325,
			0.35,
			0.45,
			0.6,
			0.7
		},
		Default = {
			0.2,
			0.3,
			0.45,
			0.55,
			0.65,
			0.75,
			0.85,
			1,
			1,
			1
		}
	}
}
local v2 = {
	Beam = true,
	Trail = true,
	ParticleEmitter = true,
	Decal = true
}

local function ValidateInstance(descendant, callback)
	if typeof(callback) == "table" then
		local instances = callback.Instances or {}
		local classes = callback.Classes or {}
		local _ = callback.Callback

		if instances[descendant] or classes[descendant.ClassName] then
			return false
		end
	elseif typeof(callback) == "function" then
		return callback(descendant)
	end

	return v2[descendant.ClassName] ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetEmitCount(instance, p: number)
	local emitCount = instance:GetAttribute("EmitCount")
	assert(emitCount, (`{instance.Name} does not have a EmitCount attribute!`))
	return (math.ceil(emitCount * v.Emit.Default[p]))
end

local function fn2(folder, p)
	if folder == nil then
		return {
			Group = nil,
			Items = {}
		}
	end

	local descendants = {}

	for _, descendant in folder:GetDescendants() do
		if ValidateInstance(descendant, p) then
			table.insert(descendants, descendant)
		end
	end

	return {
		Group = folder,
		Items = descendants
	}
end

local Utilities = {
	Ran = Random.new(),
	FullCircle = 6.283185307179586,
	Lerp = function(p: number, p2: number, p3: number)
		return p + (p2 - p) * p3
	end
}

function Utilities.TweenNumberSequence(sequence, sequence2, value, value2, p, value3, p2, p3)
	assert(sequence and typeof(sequence) == "NumberSequence", "Invalid numberSequence")
	assert(sequence2 and typeof(sequence2) == "NumberSequence", "Invalid targetSequence")
	local v3

	if value then
		if type(value) == "number" then
			v3 = value > 0
		else
			v3 = false
		end
	else
		v3 = value
	end

	assert(v3, "Invalid smoothness")
	local v4

	if value2 then
		if type(value2) == "number" then
			v4 = value2 > 0
		else
			v4 = false
		end
	else
		v4 = value2
	end

	assert(v4, "Invalid timeTaken")
	assert(type(p[value3]) == "userdata", "Invalid objectToUpdate")
	assert(value3 and type(value3) == "string", "Invalid propertyName")
	local keypoints = sequence.Keypoints
	local keypoints2 = sequence2.Keypoints
	local times = {}
	local v5 = {}
	local envelopes = {}

	for _, keypoint in ipairs(keypoints) do
		table.insert(times, keypoint.Time)
		table.insert(v5, keypoint.Value)
		table.insert(envelopes, keypoint.Envelope)
	end

	local function updateNumberSequence(value4)
		local numberSequenceKeypoints = {}

		for i, v6 in ipairs(times) do
			local v7 = math.abs(v6 - keypoints2[1].Time)
			local v8 = 1

			for i2, keypoint in ipairs(keypoints2) do
				local v9 = math.abs(v6 - keypoint.Time)

				if not (v9 < v7) then
					continue
				end

				v8 = i2
				v7 = v9
			end

			local value5 = keypoints2[v8].Value
			local envelope = keypoints2[v8].Envelope
			local lerped = Utilities.Lerp(v5[i], value5, value4)
			local lerped2 = Utilities.Lerp(envelopes[i], envelope, value4)
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v6, lerped, lerped2))
		end

		return NumberSequence.new(numberSequenceKeypoints)
	end

	for i = 0, 1, 1 / (value * value2) do
		p[value3] = updateNumberSequence(game.TweenService:GetValue(i, p2, p3))
		fn(1 / value)
	end

	local numberSequenceKeypoints = {}

	for _, v6 in ipairs(times) do
		local v7 = math.abs(v6 - keypoints2[1].Time)
		local v8 = 1

		for i, keypoint in ipairs(keypoints2) do
			local v9 = math.abs(v6 - keypoint.Time)

			if not (v9 < v7) then
				continue
			end

			v8 = i
			v7 = v9
		end

		local value4 = keypoints2[v8].Value
		local _ = keypoints2[v8].Envelope
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v6, value4, value4))
	end

	p[value3] = NumberSequence.new(numberSequenceKeypoints)
end

function Utilities.GetRaySurface(raycastResult: RaycastResult)
	return CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
		-1.5707963267948966,
		0,
		0
	)
end

function Utilities.SpawnGroup(instance, cframe: CFrame?, p: number?)
	local clone = instance:Clone()

	if cframe then
		clone:PivotTo(cframe)
	end

	clone.Parent = thrown

	if p then
		game.Debris:AddItem(clone, p)
		return clone
	end

	game.Debris:AddItem(clone, 7)
	return clone
end

function Utilities.PlayFlipbook(p, moduleScript)
	if p then
		for _, texture in ipairs(require(moduleScript)) do
			if not p.Decal then
				continue
			end

			p.Decal.Texture = texture
			fn(0.01)
		end
	end
end

function Utilities.loopAndStopFlipbook(p, moduleScript, duration: number)
	local flag = true
	coroutine.wrap(function()
		while flag do
			if not p then
				continue
			end

			for _, texture in ipairs(require(moduleScript)) do
				if p.Parent and p.Decal then
					p.Decal.Texture = texture
					fn(0.01)
				else
					break
				end
			end

			fn(0.01)
		end
	end)()
	task.delay(duration, function()
		flag = false
	end)
end

function Utilities.ScaleObject(instance, cframe: CFrame?, p: number, p2: number, p3: number, flag: boolean)
	for i = 1, p2 do
		local v3

		if flag then
			v3 = p + i / p3
		else
			v3 = math.max(p * (1 - i / p2), 0.001)
		end

		instance:ScaleTo(v3)
		instance:PivotTo(cframe)
		fn(0.01)
	end
end

local function EmitItem(instance, p: number)
	local emitDuration = instance:GetAttribute("EmitDuration")
	local emitDelay = instance:GetAttribute("EmitDelay")
	local emitCount = instance:GetAttribute("EmitCount")

	if emitDelay then
		fn(emitDelay)
	end

	if emitDuration then
		instance.Enabled = true
		task.delay(emitDuration, function()
			instance.Enabled = false
		end)
	end

	if emitCount then
		instance:Emit(GetEmitCount(instance, p))
	end
end

function Utilities.GetUserSetting(p: string)
	if p ~= "Quality" then
		return
	end

	local value = tonumber(UserGameSettings.SavedQualityLevel.Value)

	if value == 0 then
		return 10
	end

	return value
end

function Utilities.Emit(...)
	local v3 = { ... }
	task.spawn(function()
		local v4 = fn2(table.unpack(v3))

		if v4.Group:GetAttribute("_Hidden") then
			return
		end

		local items = v4.Items
		local userSetting = Utilities.GetUserSetting("Quality")
		assert(userSetting, debug.traceback("Could not fetch quality level!"))

		for _, emitter in items do
			if emitter:IsA("ParticleEmitter") then
				task.spawn(EmitItem, emitter, userSetting)
			end
		end
	end)
end

function Utilities.BindMesh(instance, callback, flag: boolean?)
	local v3 = flag == nil or flag
	task.spawn(function()
		callback(instance)

		if not v3 then
			return
		end

		instance:Destroy()
	end)
end

function Utilities.SpawnImpactFrame(data)
	local assets = script.Assets
	task.spawn(function()
		local clones = {}

		for _, parent in data.Highlighting or {} do
			local clone = assets.ImpactFrameHighlight:Clone()
			clone.FillColor = data.Highlight1 or Color3.new(0, 0, 0)
			clone.Parent = parent
			table.insert(clones, clone)
		end

		local clone = assets.ImpactFrameCorrection:Clone()
		clone.TintColor = data.Color1 or Color3.new(1, 1, 1)
		clone.Parent = game:GetService("Lighting")
		fn(data.GeneralDuration or data.Duration1 or 0.02)
		clone.TintColor = data.Color2 or Color3.new(0, 0, 0)

		for _, v3 in clones do
			v3.FillColor = data.Highlight2 or Color3.new(1, 1, 1)
		end

		fn(data.GeneralDuration or data.Duration2 or 0.02)

		for _, v3 in clones do
			v3:Destroy()
		end

		clone:Destroy()
	end)
end

return Utilities