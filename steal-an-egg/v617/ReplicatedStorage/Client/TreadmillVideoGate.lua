local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Policy = require(ReplicatedStorage.Client.Policy)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TreadmillFlags = require(ReplicatedStorage.Shared.Flags.TreadmillFlags)
local TreadmillVideoGate = {
	Changed = Signal.new(),
	IsVideoPlayerDisabled = function()
		if TreadmillFlags.VideoPlayerDisabled:Get() then
			return true
		end

		if TreadmillFlags.PolicyServiceVideoEnabled:Get() then
			return not Policy.IsEndlessContentLoadAllowed()
		end

		return false
	end
}
local isVideoPlayerDisabled = TreadmillVideoGate.IsVideoPlayerDisabled()

local function update()
	local isVideoPlayerDisabled2 = TreadmillVideoGate.IsVideoPlayerDisabled()

	if isVideoPlayerDisabled2 == isVideoPlayerDisabled then
		return
	end

	isVideoPlayerDisabled = isVideoPlayerDisabled2
	TreadmillVideoGate.Changed:Fire(isVideoPlayerDisabled2)
end

TreadmillFlags.VideoPlayerDisabled.Changed:Connect(update)
TreadmillFlags.PolicyServiceVideoEnabled.Changed:Connect(update)
Policy.Loaded:Connect(update)
return TreadmillVideoGate