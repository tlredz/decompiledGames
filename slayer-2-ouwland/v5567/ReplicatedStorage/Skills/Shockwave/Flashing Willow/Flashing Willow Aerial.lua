local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = ReplicatedStorage.CAM
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
local Config = require(script.Parent.Config)
local FlashingWillowAerial = {
	Id = 0
}
local v2 = {
	startupTrack = nil
}
local flashingWillowAirVariantUserStartup = script.FlashingWillowAirVariantUserStartup

function FlashingWillowAerial.Hold(player)
	local humanoid = player.Character:FindFirstChild("Humanoid")
	local animator = humanoid:FindFirstChild("Animator")
	Combat_presets.stop_extra_anims(humanoid, { "Swing_6", "Swing_5", "Swing_7" })
	local id = FlashingWillowAerial.Id
	v2.startupTrack = animator:LoadAnimation(flashingWillowAirVariantUserStartup)
	v:Add(v2.startupTrack)
	v2.startupTrack:Play()
	task.wait(Config.AERIAL_FREEZE_MARK)

	if id ~= FlashingWillowAerial.Id then
		return
	end

	v2.startupTrack:AdjustSpeed(0)
end

function FlashingWillowAerial.UnHold(p)
	FlashingWillowAerial.Cancel(p)
end

function FlashingWillowAerial.Cancel(_)
	v:Clean()
end

return FlashingWillowAerial