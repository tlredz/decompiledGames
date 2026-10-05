local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)
return {
	FuseSlots = 4,
	FuseTime = {
		Common = 900,
		Rare = 900,
		Epic = 900,
		Legendary = 1800,
		Mythic = 1800,
		["Brainrot God"] = 1800,
		Secret = 5400
	},
	LuckMultipliers = { 1, 4 },
	RevealNowProductId = 3354160217,
	FuseLuckProductId = 3483927303,
	FFlagDefaults = {
		["FuseMachine/Disabled"] = false,
		["FuseMachine/CanStealBrainrot"] = true,
		["FuseMachine/CostMultiplier"] = 1.25
	},
	Remotes = {
		RemoveBrainrot = Net:RemoteFunction("FuseMachine/RemoveBrainrot"),
		ClaimBrainrot = Net:RemoteFunction("FuseMachine/ClaimBrainrot"),
		ConfirmFusion = Net:RemoteFunction("FuseMachine/ConfirmFusion"),
		Delivery = Net:RemoteFunction("FuseMachine/Delivery"),
		RevealNow = Net:RemoteEvent("FuseMachine/RevealNow"),
		FuseAnimation = Net:RemoteEvent("FuseMachine/FuseAnimation"),
		ForceUpdate = Net:RemoteEvent("FuseMachine/ForceUpdate")
	}
}