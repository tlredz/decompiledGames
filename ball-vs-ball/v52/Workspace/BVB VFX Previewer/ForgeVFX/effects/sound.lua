local createVector = vector.create
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local module = require("../mod/attributes")
local module2 = require("../mod/tween")
require("../types")
local module3 = require("../mod/utility")
local module4 = require("../pkg/Promise")
local random = Random.new()
local parent = nil

local function selectRandomSound(object)
	local v2 = module.get(object, "SoundPoolTag", "")

	if v2 == "" then
		return object
	end

	local tagged = CollectionService:GetTagged(v2)
	local sounds = {}
	local soundPoolWeights = {}
	local total = 0

	for _, sound in tagged do
		if not sound:IsA("Sound") then
			continue
		end

		table.insert(sounds, sound)
		local soundPoolWeight = module.get(sound, "SoundPoolWeight", 1)
		table.insert(soundPoolWeights, soundPoolWeight)
		total += soundPoolWeight
	end

	if #sounds == 0 then
		return object
	end

	if total > 0 then
		local v3 = random:NextNumber() * total
		local total2 = 0

		for k, v4 in soundPoolWeights do
			total2 += v4

			if v3 <= total2 then
				return sounds[k]
			end
		end
	end

	return sounds[random:NextInteger(1, #sounds)]
end

local function createSoundClone(instance, instance2, list)
	local clone = instance2:Clone()

	for _, tag in clone:GetTags() do
		clone:RemoveTag(tag)
	end

	local basePart = instance:FindFirstAncestorWhichIsA("BasePart")
	local part = nil

	if module3.PLUGIN_CONTEXT then
		if basePart then
			part = Instance.new("Part")
			part.Name = "SoundEmitter"
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Transparency = 1
			part.Size = createVector(1, 1, 1)
			part.CFrame = basePart.CFrame
			part.Parent = parent
			clone.Parent = part
			table.insert(list, part)
		else
			clone.Parent = parent
			table.insert(list, clone)
		end
	else
		if basePart then
			clone.Parent = basePart
		else
			clone.Parent = workspace.Terrain
		end

		table.insert(list, clone)
	end

	return clone, part
end

local function playSingleSound(instance, p, soundClone, p2, list, emitDuration: number)
	local playbackSpeed = soundClone.PlaybackSpeed
	local volumeEnd = module.get(p, "Volume_End", soundClone.Volume)
	local volumeStart = module.get(p, "Volume_Start", soundClone.Volume)
	soundClone.Volume = volumeStart

	if volumeStart == volumeEnd then
		soundClone.Volume = volumeStart
	else
		local volumeDuration = module.get(p, "Volume_Duration", soundClone.TimeLength)
		table.insert(
			list,
			module2.fromParams(module.get(p, "Volume_Curve", module3.default_bezier), volumeDuration, function(p3, p4)
				soundClone.Volume = module3.lerp(volumeStart, volumeEnd, p3)
				return p4 * playbackSpeed
			end)
		)
	end

	local speedEnd = module.get(p, "Speed_End", soundClone.PlaybackSpeed)
	local speedStart = module.get(p, "Speed_Start", soundClone.PlaybackSpeed)
	playbackSpeed = speedStart
	local v2 = nil

	if speedStart == speedEnd then
		soundClone.PlaybackSpeed = speedStart
	else
		local speedDuration = module.get(p, "Speed_Duration", soundClone.TimeLength)
		v2 = module2.fromParams(module.get(p, "Speed_Curve", module3.default_bezier), speedDuration, function(p3, p4)
			playbackSpeed = module3.lerp(speedStart, speedEnd, p3)
			soundClone.PlaybackSpeed = playbackSpeed
			return p4
		end)
		table.insert(list, v2)
	end

	local rollOffEnd = module.get(p, "RollOff_End", soundClone.RollOffMinDistance)
	local rollOffStart = module.get(p, "RollOff_Start", soundClone.RollOffMinDistance)

	if rollOffStart ~= rollOffEnd then
		local rollOffDuration = module.get(p, "RollOff_Duration", soundClone.TimeLength)
		table.insert(
			list,
			module2.fromParams(module.get(p, "RollOff_Curve", module3.default_bezier), rollOffDuration, function(p3, p4)
				soundClone.RollOffMinDistance = module3.lerp(rollOffStart, rollOffEnd, p3)
				return p4 * playbackSpeed
			end, v2)
		)
	end

	if soundClone.PlayOnRemove and not module3.PLUGIN_CONTEXT then
		soundClone:Destroy()
	else
		soundClone:Play()
	end

	local basePart = p2 and instance:FindFirstAncestorWhichIsA("BasePart")

	if basePart then
		table.insert(list, RunService.Heartbeat:Connect(function()
			if p2.Parent then
				p2.CFrame = basePart.CFrame
			end
		end))
	end

	if emitDuration > 0 then
		task.wait(emitDuration)
		soundClone:Stop()
	else
		module2.timer(soundClone.TimeLength, function(p3, p4)
			if soundClone.PlaybackSpeed > 0 or p4 > 0 and v2 and v2.Connected then
				return p3 * soundClone.PlaybackSpeed
			end

			return nil
		end, v2, list)
	end

	return v2
end

local Sound = {}

function Sound.init()
	if not module3.PLUGIN_CONTEXT then
		return
	end

	local plugin = script:FindFirstAncestorOfClass("Plugin")

	if not plugin then
		return
	end

	parent = plugin:CreateDockWidgetPluginGui(
		"VFXForgeSoundPlayer",
		DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, true, 200, 100, 100, 50)
	)

	if parent then
		parent.Name = "VFXForgeSoundPlayer"
	end
end

function Sound.deinit()
	if parent then
		parent:Destroy()
		parent = nil
	end
end

function Sound.emit(object, p)
	if object.Playing then
		object:Stop()
	end

	local soundPoolIsSource = module.get(object, "SoundPoolIsSource", false)
	local soundPoolInheritAttributes = module.get(object, "SoundPoolInheritAttributes", false)

	if soundPoolInheritAttributes and not soundPoolIsSource then
		object = selectRandomSound(object) or object
	end

	local emitDelay = module.get(object, "EmitDelay", 0)
	local emitDuration = module.get(object, "EmitDuration", 0)
	local emitCount = module.get(object, "EmitCount", 1)
	local range = module.getRange(object, "EmitInterval", NumberRange.new(0, 0))
	local repeatCount = module.get(object, "RepeatCount", 1)
	local range2 = module.getRange(object, "RepeatInterval", NumberRange.new(0, 0))
	task.wait(emitDelay)
	local v2 = {}

	for i = 1, emitCount do
		local v3 = soundPoolInheritAttributes and object or not soundPoolIsSource and selectRandomSound(object) or object

		if not v3 then
			continue
		end

		local v4

		if soundPoolInheritAttributes and v3 ~= object then
			v4 = v3
		else
			v4 = object
		end

		for i2 = 1, repeatCount do
			local v5 = v3
			local v6 = v4
			table.insert(v2, module4.new(function(callback)
				local soundClone, v7 = createSoundClone(object, v5, p)
				playSingleSound(object, v6, soundClone, v7, p, emitDuration)

				if v7 then
					v7:Destroy()
				else
					soundClone:Destroy()
				end

				callback()
			end))

			if i2 < repeatCount and range2.Max > 0 then
				task.wait(random:NextNumber(range2.Min, range2.Max))
			end
		end

		if i < emitCount and range.Max > 0 then
			task.wait(random:NextNumber(range.Min, range.Max))
		end
	end

	module4.all(v2):await()
end

return Sound