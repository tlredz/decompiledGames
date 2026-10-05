local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.NPCManager.Types)
local v = {
	["robotmega superfan"] = {
		Mark = CFrame.new(
			-1056.83826,
			29.3944054,
			1683.52185,
			0.242966741,
			0.0349480771,
			-0.969404936,
			-0,
			0.999350846,
			0.0360276587,
			0.970034599,
			-0.00875352323,
			0.242809027
		),
		MarkForward = 2,
		TeleportPlayer = true,
		FirstPersonCamera = true
	}
}
return table.freeze(v)