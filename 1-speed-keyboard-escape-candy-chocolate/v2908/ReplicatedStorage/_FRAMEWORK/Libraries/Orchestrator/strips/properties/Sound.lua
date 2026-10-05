local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
require(script.Parent.Parent.Parent.types.Property)
require(script.Parent.Parent.Parent.types.Strip)
local SoundManager = require(ReplicatedStorage._FRAMEWORK.Features.ClientOnly.SoundManager)
local v = { "Sound", "SoundGroup", "CustomSound" }
local dataTemplate = {
	soundType = "Sound",
	soundPath = "",
	soundGroupPath = "Woosh.LongWooshes",
	customSoundId = "",
	volume = NumberRange.new(0.5),
	playbackSpeed = NumberRange.new(0.8, 1.2),
	rollOffMaxDistance = 500,
	rollOffMinDistance = 40,
	timePosition = 0,
	debrisTimer = 60,
	followTarget = true
}

-- equivalent calls inferred from this helper; original call sites unknown
local function sampleRange(range: NumberRange)
	if range.Min == range.Max then
		return range.Min
	end

	return Random.new():NextNumber(range.Min, range.Max)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSoundType(p)
	if p.soundType == "SoundGroup" or p.soundType == "CustomSound" then
		return p.soundType
	end

	return "Sound"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function normalizeCustomSoundId(customSoundId: string)
	local v3 = string.match(customSoundId, "^%s*rbxassetid://(%d+)%s*$") or string.match(customSoundId, "^%s*(%d+)%s*$")

	if v3 then
		return (`rbxassetid://{v3}`)
	end

	return ""
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createSound(data)
	local soundType = getSoundType(data) -- equivalent call inferred; original call site unknown

	if soundType == "SoundGroup" then
		return SoundManager.getRandomSoundFromGroup(data.soundGroupPath)
	end

	if soundType ~= "CustomSound" then
		return SoundManager.getSound(data.soundPath)
	end

	return SoundManager.getSound(normalizeCustomSoundId(data.customSoundId))
end

local function getAttachmentHost(instance)
	if instance:IsA("BasePart") then
		return instance
	end

	if instance:IsA("Model") and instance.PrimaryPart ~= nil then
		return instance.PrimaryPart
	end

	return instance:FindFirstChildWhichIsA("BasePart", true)
end

local function createStaticEmitter(cFrame: CFrame)
	local part = Instance.new("Part")
	part.Name = "OrchestratorSoundEmitter"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
	part.CFrame = cFrame
	part.Parent = Workspace
	return part
end

local function createEmitter(attachment, followTarget: boolean, p: number)
	local primaryPart

	if followTarget then
		if attachment:IsA("BasePart") then
			primaryPart = attachment
		elseif attachment:IsA("Model") and attachment.PrimaryPart ~= nil then
			primaryPart = attachment.PrimaryPart
		else
			primaryPart = attachment:FindFirstChildWhichIsA("BasePart", true)
		end
	end

	local selected

	if primaryPart == nil then
		local pivot = attachment:GetPivot()
		selected = Instance.new("Part")
		selected.Name = "OrchestratorSoundEmitter"
		selected.Anchored = true
		selected.CanCollide = false
		selected.CanQuery = false
		selected.CanTouch = false
		selected.CastShadow = false
		selected.Size = createVector(1, 1, 1)
		selected.Transparency = 1
		selected.CFrame = pivot
		selected.Parent = Workspace
	else
		selected = Instance.new("Attachment")
		selected.Name = "OrchestratorSoundEmitter"
		selected.Parent = primaryPart
	end

	Debris:AddItem(selected, p)
	return selected
end

local function playSound(data, attachment)
	local sound = createSound(data) -- equivalent call inferred; original call site unknown
	local range = sampleRange(data.volume) -- equivalent call inferred; original call site unknown
	sound.Volume = math.max(range, 0)
	local range2 = sampleRange(data.playbackSpeed) -- equivalent call inferred; original call site unknown
	sound.PlaybackSpeed = math.max(range2, 0.01)
	sound.RollOffMinDistance = math.max(data.rollOffMinDistance, 0)
	sound.RollOffMaxDistance = math.max(data.rollOffMaxDistance, sound.RollOffMinDistance)
	sound.TimePosition = math.max(data.timePosition, 0)
	local v5 = math.max(data.debrisTimer, 0)
	local parent = nil

	if attachment == nil then
		sound.Parent = Workspace.Terrain
		SoundManager.listenInPlugin(sound)
	elseif attachment:IsA("Attachment") and data.followTarget then
		sound.Parent = attachment
		SoundManager.listenInPlugin(sound)
	elseif attachment:IsA("Attachment") then
		local worldCFrame = attachment.WorldCFrame
		parent = Instance.new("Part")
		parent.Name = "OrchestratorSoundEmitter"
		parent.Anchored = true
		parent.CanCollide = false
		parent.CanQuery = false
		parent.CanTouch = false
		parent.CastShadow = false
		parent.Size = createVector(1, 1, 1)
		parent.Transparency = 1
		parent.CFrame = worldCFrame
		parent.Parent = Workspace
		Debris:AddItem(parent, v5)
		sound.Parent = parent
		SoundManager.listenInPlugin(sound)
	else
		parent = createEmitter(attachment, data.followTarget, v5)
		sound.Parent = parent
		SoundManager.listenInPlugin(sound)
	end

	local v7 = false
	sound.Destroying:Connect(function()
		local v8 = parent

		if not v7 and v8 ~= nil and v8.Parent ~= nil then
			v7 = true
			v8:Destroy()
		end
	end)
	sound.Ended:Once(function()
		if sound.Parent ~= nil then
			sound:Destroy()
		end
	end)
	Debris:AddItem(sound, v5)
	sound:Play()
end

local Sound = {}
Sound.stripType = "property"
Sound.playbackMode = "action"
Sound.propertyName = "Sound"
Sound.context = "client"
Sound.catchUpPolicies = { "skip" }
Sound.dataTemplate = dataTemplate
Sound.supportsGlobal = true

function Sound.buildEditor(p, state, instance)
	if instance == nil or not (instance:IsA("PVInstance") or instance:IsA("Attachment")) then
		instance = nil
	end

	p.Components:AddTab(function(object)
		object:SetTabs(v):SetOnTabChanged(function(soundType: string)
			state.soundType = soundType
		end)
		object:GetComponentCtn("Sound"):AddBigDropdown(function(object2)
			object2:SetChoiceList(SoundManager.getAllSoundPaths()):SetSizeY(150):SetSelected(state.soundPath):SetOnChanged(function(soundPath: string?)
				if soundPath ~= nil then
					state.soundPath = soundPath
				end
			end)
		end)
		object:GetComponentCtn("SoundGroup"):AddBigDropdown(function(object2)
			object2:SetChoiceList(SoundManager.getAllSoundGroupPaths()):SetSizeY(150):SetSelected(state.soundGroupPath):SetOnChanged(function(soundGroupPath: string?)
				if soundGroupPath ~= nil then
					state.soundGroupPath = soundGroupPath
				end
			end)
		end)
		object:GetComponentCtn("CustomSound"):AddField(function(object2)
			object2:SetText("Asset ID"):SetValue(state.customSoundId):SetOnChangedUnfocus(function(customSoundId: string)
				state.customSoundId = customSoundId
			end)
		end)
		object:OpenTab(getSoundType(state))
	end)
	p.Components:AddNumberRangeField(function(object)
		object:SetText("Volume"):SetValue(state.volume):SetOnChangedUnfocus(function(volume: NumberRange)
			state.volume = volume
		end)
	end)
	p.Components:AddNumberRangeField(function(object)
		object:SetText("Playback Speed"):SetValue(state.playbackSpeed):SetOnChangedUnfocus(function(playbackSpeed: NumberRange)
			state.playbackSpeed = playbackSpeed
		end)
	end)
	p.Components:AddNumberField(function(object)
		object:SetText("Rolloff Max Distance"):SetValue(state.rollOffMaxDistance):SetNumberFilter(0):SetOnChangedUnfocus(function(rollOffMaxDistance: number)
			state.rollOffMaxDistance = rollOffMaxDistance
		end)
	end)
	p.Components:AddNumberField(function(object)
		object:SetText("Rolloff Min Distance"):SetValue(state.rollOffMinDistance):SetNumberFilter(0):SetOnChangedUnfocus(function(rollOffMinDistance: number)
			state.rollOffMinDistance = rollOffMinDistance
		end)
	end)
	p.Components:AddNumberField(function(object)
		object:SetText("Time Position"):SetValue(state.timePosition):SetNumberFilter(0):SetOnChangedUnfocus(function(timePosition: number)
			state.timePosition = timePosition
		end)
	end)
	p.Components:AddNumberField(function(object)
		object:SetText("Debris Timer"):SetValue(state.debrisTimer):SetNumberFilter(0):SetOnChangedUnfocus(function(debrisTimer: number)
			state.debrisTimer = debrisTimer
		end)
	end)
	p.Components:AddCheckbox(function(object)
		object:SetText("Follow Target"):SetValue(state.followTarget):SetOnChanged(function(followTarget: boolean)
			state.followTarget = followTarget
		end)
	end)
	p.Components:AddSplit(function(object)
		object:SetLeftSizePercent(0.35)
		object.LeftComponents:AddButton(function(object2)
			object2:SetButtonText("Stop Sounds"):SetButtonCallback(function()
				SoundManager.stopAllSoundInPlugin()
			end)
		end)
		object.RightComponents:AddButton(function(object2)
			object2:SetButtonText("Preview"):SetButtonCallback(function()
				playSound(state, instance)
			end)
		end)
	end)
end

function Sound.supports(instance)
	return instance:IsA("PVInstance") or instance:IsA("Attachment")
end

function Sound.capture(_, _)
	return table.clone(dataTemplate)
end

function Sound.trigger(p, p2, p3)
	if p3.isGlobal then
		p = nil
	end

	playSound(p2, p)
end

function Sound.preload(p)
	local soundType = getSoundType(p) -- equivalent call inferred; original call site unknown

	if soundType == "Sound" then
		if p.soundPath == "" then
			return
		end

		SoundManager.preloadSound(p.soundPath)
	elseif soundType == "CustomSound" then
		SoundManager.preloadSound(normalizeCustomSoundId(p.customSoundId))
	end
end

return Sound