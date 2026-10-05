local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local SettingsKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
local areaLocator = ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Areas"):WaitForChild("AreaLocator")
local module = require(areaLocator)
local DayAndNightHandler = require(ReplicatedStorage.CAM.Global.DayAndNightHandler)
local v = DataValue.new(SettingsKeys.AmbienceVolume.Path, SettingsKeys.AmbienceVolume.Default, SettingsKeys.Scope)

-- equivalent calls inferred from this helper; original call sites unknown
local function VolumeShare()
	local v2 = v:Get()

	if type(v2) == "number" then
		return (math.clamp(v2, 0, 1))
	end

	return 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CategoryFor()
	local areaEquipped = module.AreaEquipped

	if areaEquipped.Cave then
		return "Cave"
	end

	if areaEquipped.Village then
		return "Village"
	end

	if DayAndNightHandler.IsEnabled() and DayAndNightHandler.IsNight() then
		return "Night"
	end

	return "Outside"
end

local sounds = {}

for _, v2 in {
	"Cave",
	"Village",
	"Outside",
	"Night"
} do
	local sound = script:FindFirstChild(v2 .. "_Ambience")

	if sound == nil or not sound:IsA("Sound") then
		warn("[Ambience] no " .. v2 .. "_Ambience Sound under this script")
	else
		if sound:GetAttribute("DV") == nil then
			sound:SetAttribute("DV", sound.Volume)
		end

		sounds[v2] = sound
	end
end

local v2 = nil
local v3 = nil

local function Swap(p: string)
	if v3 == p then
		return
	end

	v3 = p
	local v4 = v2
	local v5 = sounds[p]
	v2 = v5

	if v4 ~= nil and v4 ~= v5 then
		TweenService:Create(v4, TweenInfo.new(1), {
			Volume = 0
		}):Play()
		task.delay(1, function()
			if v2 ~= v4 then
				v4:Stop()
			end
		end)
	end

	if v5 == nil or v4 == v5 then
		return
	end

	v5.Looped = true
	v5.Volume = 0
	v5:Play()
	local tweenInfo = TweenInfo.new(1)
	local DV = v5:GetAttribute("DV") or 1
	TweenService:Create(v5, tweenInfo, {
		Volume = DV * VolumeShare()
	}):Play()
end

v.Changed:Connect(function()
	if v2 ~= nil and v2.IsPlaying then
		local v4 = v2
		local DV = v2:GetAttribute("DV") or 1
		v4.Volume = DV * VolumeShare()
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function Update()
	Swap(CategoryFor())
end

Swap(CategoryFor())
module.AreaEquipped.Update:Connect(Update)

if DayAndNightHandler.IsEnabled() then
	task.spawn(function()
		while true do
			task.wait((math.max(DayAndNightHandler.SecondsUntilPhaseChange(), 1)))
			Update() -- equivalent call inferred; original call site unknown
		end
	end)
end