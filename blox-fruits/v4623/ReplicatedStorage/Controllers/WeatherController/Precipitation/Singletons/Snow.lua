local createVector = vector.create
game:GetService("Players")
game:GetService("TweenService")
game:GetService("RunService")
local precipitation = game.ReplicatedStorage.Controllers.WeatherController.Precipitation
local TableUtil = require(game.ReplicatedStorage.Modules.TableUtil)
local module = require(precipitation)
local Groups = require(game.ReplicatedStorage.Util.Sound.Groups)
local copy = TableUtil.deepCopy(require(precipitation._Config))
copy.MAX_VOLUME = 1
local v = module.new(script.Name, copy)
local soundGroup = Instance.new("SoundGroup")
soundGroup.Name = ("Environment:%s"):format(script.Name)
soundGroup.Volume = 1
local sound = Instance.new("Sound")
sound.Looped = true
sound.SoundId = ""
sound.Volume = 0
sound.SoundGroup = soundGroup
sound.Parent = soundGroup
soundGroup.Parent = game:GetService("SoundService")
Groups.registerSatellite(soundGroup, "LowPriority")
v.sound = sound
table.insert(v.prepareEffects, function()
	sound.SoundId = "rbxassetid://6670092634"
end)
local splashAttachments = {}
local occludedAttachments = {}
v.occludedAttachments = occludedAttachments
v.splashAttachments = splashAttachments
local clone = script.ColorCorrection:Clone()
clone:SetAttribute("ActiveColor", clone.TintColor)
clone.TintColor = Color3.new(1, 1, 1)
clone.Enabled = false
clone.Parent = game.Lighting
v.colorCorrection = clone
local v4 = CFrame.new(-1.15, 1.15, 0) * CFrame.Angles(0, 0, 0.6108652381980153)
local v5 = CFrame.new(-1.15, 1.15, 0) * CFrame.Angles(0, 0, 0.6108652381980153)
local cframe = CFrame.new(0, 0, -0.5)
local clones = {}

for i = 1, 3 do
	local clone2 = script["CameraFocus" .. i]:Clone()

	for _, child in pairs(clone2:GetChildren()) do
		child:SetAttribute("OriginalRate", child.Rate)
		child:SetAttribute("OriginalSpeedMin", child.Speed.Min)
		child:SetAttribute("OriginalSpeedMax", child.Speed.Max)
	end

	table.insert(v.prepareEffects, function()
		clone2.Parent = workspace._WorldOrigin
	end)
	clones[i] = clone2
end

v.occludedAttachments = occludedAttachments
v.splashAttachments = splashAttachments
v.cameraFocus = {
	{ clones[1], function(p)
			return CFrame.new(p.Position) * v4
		end },
	{ clones[2], function(cframe2: CFrame)
			return CFrame.new(cframe2 * createVector(0, 0, -4)) * v5
		end },
	{ clones[3], function(cframe2: CFrame)
			return cframe2 * cframe
		end }
}
return v:_Init()