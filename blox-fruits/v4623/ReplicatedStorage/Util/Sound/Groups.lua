local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local config = {
	GroupOrder = { "HighPriority", "LowPriority" },
	Priorities = {
		HighPriority = 2,
		LowPriority = 1
	},
	DefaultGroup = "HighPriority",
	FolderToGroup = {
		Ambience = "LowPriority",
		AwakenedBossAmbients = "LowPriority",
		AwakenedBossIntros = "LowPriority",
		JingleBells = "LowPriority",
		Gacha = "HighPriority",
		Unboxing = "HighPriority",
		UI = "HighPriority"
	},
	CompressorsEnabled = true,
	Compressors = {
		{
			On = "LowPriority",
			SideChain = "HighPriority",
			Threshold = -25,
			Ratio = 4,
			Attack = 0.1,
			Release = 2
		}
	},
	DuckTweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
}
local v2 = {
	Groups = {},
	BaseVolumes = {},
	SettingFactors = {
		HighPriority = 1,
		LowPriority = 1
	},
	ActiveTokens = {},
	Satellites = {},
	ActiveTweens = {},
	CompressorsInited = false
}
local isClient = RunService:IsClient()
local Groups = {}
local v3 = {}

function Groups.isGroupName(value)
	return typeof(value) == "string" and config.Priorities[value] ~= nil
end

function Groups.getGroup(childName: string)
	local group = v2.Groups[childName]

	if group and group.Parent then
		return group
	end

	local soundGroup = SoundService:FindFirstChild(childName)

	if not (soundGroup and soundGroup:IsA("SoundGroup")) then
		return nil
	end

	v2.Groups[childName] = soundGroup

	if v2.BaseVolumes[childName] == nil then
		v2.BaseVolumes[childName] = soundGroup.Volume
	end

	return soundGroup
end

function Groups.groupForFolderName(p: string?)
	local selected = p and config.FolderToGroup[p]
	return selected or config.DefaultGroup
end

function Groups.folderGroupFor(parent, p)
	while parent and parent.Parent ~= p do
		parent = parent.Parent
	end

	local groupForFolderName = Groups.groupForFolderName
	local v4

	if parent then
		v4 = parent.Name
	end

	return groupForFolderName(v4)
end

function Groups.resolveTemplateGroup(instance, p)
	local soundGroup = instance:GetAttribute("SoundGroup")

	if Groups.isGroupName(soundGroup) then
		return soundGroup
	end

	return Groups.folderGroupFor(instance, p)
end

function Groups.parsePlayOptions(radius, speed: number?, volume: number?, fadeIn: number?)
	if typeof(radius) == "table" then
		return radius
	end

	return {
		radius = radius,
		speed = speed,
		volume = volume,
		fadeIn = fadeIn
	}
end

function Groups:assign(p2: string)
	self.SoundGroup = Groups.getGroup(p2)
end

function Groups.getEffectiveFactor(p: string)
	return v2.SettingFactors[p] * v3.duckFactorFor(p)
end

function Groups.setSettingFactor(p: string, p2: number)
	v2.SettingFactors[p] = p2
	v3.applyGroup(p, config.DuckTweenInfo)
end

function Groups.duck(factors, p)
	local tweenInfo = p or config.DuckTweenInfo
	local v5 = nil
	v5 = {
		Release = function(_)
			if not v2.ActiveTokens[v5] then
				return
			end

			v2.ActiveTokens[v5] = nil

			for k in factors do
				v3.applyGroup(k, tweenInfo)
			end
		end
	}
	v2.ActiveTokens[v5] = {
		Factors = factors,
		TweenInfo = tweenInfo
	}

	for k in factors do
		v3.applyGroup(k, tweenInfo)
	end

	return v5
end

function Groups.registerSatellite(group, parentName: string)
	local v4 = {
		Group = group,
		ParentName = parentName,
		BaseVolume = group.Volume
	}
	table.insert(v2.Satellites, v4)
	v3.applySatellite(v4, config.DuckTweenInfo)

	if v2.CompressorsInited then
		v3.addCompressorsTo(group, parentName)
	end
end

function Groups.initCompressors()
	if not isClient or not config.CompressorsEnabled or v2.CompressorsInited then
		return
	end

	v2.CompressorsInited = true

	for _, v4 in config.GroupOrder do
		local group = Groups.getGroup(v4)

		if group then
			v3.addCompressorsTo(group, v4)
		end
	end

	for _, satellite in v2.Satellites do
		v3.addCompressorsTo(satellite.Group, satellite.ParentName)
	end
end

Groups.Config = config

function v3.duckFactorFor(p: string)
	local v4 = 1

	for _, activeToken in v2.ActiveTokens do
		local factor = activeToken.Factors[p]

		if factor and factor < v4 then
			v4 = factor
		end
	end

	return v4
end

function v3:tweenVolume(volume: number, p2)
	local activeTween = v2.ActiveTweens[self]

	if activeTween then
		activeTween:Cancel()
		v2.ActiveTweens[self] = nil
	end

	if p2.Time <= 0 then
		self.Volume = volume
		return
	end

	local tween = TweenService:Create(self, p2, {
		Volume = volume
	})
	v2.ActiveTweens[self] = tween
	tween:Play()
end

function v3.applyGroup(p: string, p2)
	if not isClient then
		return
	end

	local group = Groups.getGroup(p)

	if group then
		v3.tweenVolume(group, v2.BaseVolumes[p] * Groups.getEffectiveFactor(p), p2)
	end

	for _, satellite in v2.Satellites do
		if satellite.ParentName == p then
			v3.applySatellite(satellite, p2)
		end
	end
end

function v3.applySatellite(data, p)
	if not isClient then
		return
	end

	v3.tweenVolume(data.Group, data.BaseVolume * Groups.getEffectiveFactor(data.ParentName), p)
end

function v3.addCompressorsTo(parent, p: string)
	for k, compressor in config.Compressors do
		if compressor.On ~= p then
			continue
		end

		local group = Groups.getGroup(compressor.SideChain)

		if not group then
			continue
		end

		local compressorSoundEffect = Instance.new("CompressorSoundEffect")
		compressorSoundEffect.Name = `Duck_{compressor.SideChain}`
		compressorSoundEffect.Threshold = compressor.Threshold
		compressorSoundEffect.Ratio = compressor.Ratio
		compressorSoundEffect.Attack = compressor.Attack
		compressorSoundEffect.Release = compressor.Release
		compressorSoundEffect.GainMakeup = 0
		compressorSoundEffect.Priority = k
		compressorSoundEffect.SideChain = group
		compressorSoundEffect.Parent = parent
	end
end

return Groups