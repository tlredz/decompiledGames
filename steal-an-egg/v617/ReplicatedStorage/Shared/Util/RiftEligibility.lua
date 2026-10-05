local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LiveEventFlags = require(ReplicatedStorage.Shared.Flags.LiveEventFlags)
local RiftFlags = require(ReplicatedStorage.Shared.Flags.RiftFlags)
local RiftMachineSchedule = require(ReplicatedStorage.Shared.Util.RiftMachineSchedule)
local v = {
	OpenAttribute = LiveEventFlags.Directory.RiftOpen.AttributeName,
	CutsceneSeenAttribute = "RiftCutscene2Seen",
	IsFeatureLive = function()
		return not (RiftMachineSchedule.IsLaboratoryTime() or RiftFlags.Retired:Get())
	end,
	IsEligible = function(p: number)
		return RiftFlags.SpeedPowerRequirement:Get() <= p
	end,
	HasSeenReveal = function(instance)
		return instance:GetAttribute("RiftCutscene2Seen") == true
	end
}

function v.IsRevealed(p, p2: number, p3: number)
	if v.IsFeatureLive() then
		return RiftFlags.SpeedPowerRequirement:Get() <= p2 or (p3 ~= 0 or v.HasSeenReveal(p))
	end

	return false
end

return table.freeze(v)