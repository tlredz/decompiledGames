local v = {
	EventDisplayName = "Capture The Egg Event",
	EggDisplayName = "Event Egg",
	CarryCategory = "Baby Aurora Dragon",
	RewardCategory = "Baby Aurora Dragon",
	EggScale = 2,
	RewardScale = 1,
	CutsceneFallSeconds = 4,
	LandingSinkStuds = 0.35,
	LandingRotationDegrees = vector.create(-5, 28, 4),
	StarterRigName = "CaptureTheEggStarterRig",
	EggUidAttribute = "Event_CaptureTheEggUid",
	EggHighlightColor = Color3.fromRGB(255, 214, 89),
	BroadcastIconImage = "rbxassetid://116524274262912",
	SpawnMarkerName = "CaptureTheEggSpawn",
	FallbackMarkerName = "AdminAbuseEggSpawn",
	DanceAnimationId = "rbxassetid://507771019",
	R6DanceAnimationId = "rbxassetid://182435998",
	ScoreboardVisibleRows = 3
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
return (require(ReplicatedStorage.Shared.Flags.BalanceConfig).Bind("Game.Balance.CaptureTheEgg", v, {
	EggScale = true,
	RewardScale = true
}, false, function(p)
	local v2

	if p.EggScale > 0 then
		v2 = p.RewardScale > 0
	else
		v2 = false
	end

	assert(v2)
end))