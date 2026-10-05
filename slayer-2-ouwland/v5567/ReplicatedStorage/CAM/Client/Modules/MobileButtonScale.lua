local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SettingsKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local min = SettingsKeys.MobileScaleRange.Min
local max = SettingsKeys.MobileScaleRange.Max
local MobileButtonScale = {
	Range = SettingsKeys.MobileScaleRange,
	Changed = simplesignal.new(),
	Of = function(value)
		local v

		if type(value) == "number" then
			v = math.clamp(value, 0, 1)
		else
			v = SettingsKeys.MobileScale.Default
		end

		return min + v * (max - min)
	end
}
local v = MobileButtonScale.Of(SettingsKeys.MobileScale.Default)

function MobileButtonScale.Get()
	return v
end

if not RunService:IsClient() then
	return MobileButtonScale
end

local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local v2 = DataValue.new(SettingsKeys.MobileScale.Path, SettingsKeys.MobileScale.Default, SettingsKeys.Scope)
v = MobileButtonScale.Of(v2:Get())
v2.Changed:Connect(function(p)
	local v3 = v
	v = MobileButtonScale.Of(p)

	if v == v3 then
		return
	end

	MobileButtonScale.Changed:Fire(v)
end)
return MobileButtonScale