local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networking = require(ReplicatedStorage.Packages.Networking)

local function scope(name: string, callback)
	Networking.namespace({
		name = name,
		env = "all"
	})
	return callback()
end

Networking.namespace({
	name = "Scramble",
	env = "all"
})
local Remotes = {
	Scramble = (function()
		return {
			Drones = Networking.remoteEvent("Drones"),
			Request = Networking.remoteFunction("Request"),
			Collect = Networking.remoteEvent("Collect"),
			State = Networking.remoteEvent("State"),
			Drops = Networking.remoteEvent("Drops"),
			RemoveDrops = Networking.remoteEvent("RemoveDrops"),
			Effect = Networking.remoteEvent("Effect")
		}
	end)()
}
Networking.namespace({
	name = "PenRoster",
	env = "all"
})
Remotes.PenRoster = (function()
	return {
		AskDoff = Networking.remoteFunction("AskDoff"),
		AskLiveSnapshot = Networking.remoteFunction("AskLiveSnapshot"),
		AskSale = Networking.remoteFunction("AskSale"),
		AskWear = Networking.remoteFunction("AskWear"),
		AskWearLimit = Networking.remoteFunction("AskWearLimit"),
		CoinsGathered = Networking.remoteEvent("CoinsGathered"),
		ConfirmEquipBestBadge = Networking.remoteFunction("ConfirmEquipBestBadge"),
		ConfirmPetsBadge = Networking.remoteFunction("ConfirmPetsBadge"),
		OwnerDropped = Networking.remoteEvent("OwnerDropped"),
		OwnerShifted = Networking.remoteEvent("OwnerShifted")
	}
end)()
Networking.namespace({
	name = "LiveEvents",
	env = "all"
})
Remotes.LiveEvents = (function()
	return {
		Began = Networking.remoteEvent("Began"),
		Ended = Networking.remoteEvent("Ended"),
		FetchCatalogue = Networking.remoteFunction("FetchCatalogue"),
		FetchRecurringEta = Networking.remoteFunction("FetchRecurringEta"),
		FetchRunning = Networking.remoteFunction("FetchRunning"),
		FetchScheduled = Networking.remoteFunction("FetchScheduled")
	}
end)()
Networking.namespace({
	name = "LightVsDarkness",
	env = "all"
})
Remotes.LightVsDarkness = (function()
	return {
		AskClaimMilestone = Networking.remoteEvent("AskClaimMilestone"),
		AskCollectPowerUp = Networking.remoteEvent("AskCollectPowerUp"),
		AskCollectRing = Networking.remoteEvent("AskCollectRing"),
		AskSelectTeam = Networking.remoteEvent("AskSelectTeam"),
		FetchPowerUps = Networking.remoteFunction("FetchPowerUps"),
		FetchRings = Networking.remoteFunction("FetchRings"),
		FetchScore = Networking.remoteFunction("FetchScore"),
		PowerUpCollected = Networking.remoteEvent("PowerUpCollected"),
		PowerUpsCleared = Networking.remoteEvent("PowerUpsCleared"),
		PowerUpsDropped = Networking.remoteEvent("PowerUpsDropped"),
		PowerUpsSky = Networking.remoteEvent("PowerUpsSky"),
		RingCollected = Networking.remoteEvent("RingCollected"),
		RingRespawned = Networking.remoteEvent("RingRespawned"),
		RingsCleared = Networking.remoteEvent("RingsCleared"),
		RingsSpawned = Networking.remoteEvent("RingsSpawned"),
		ScoreChanged = Networking.remoteEvent("ScoreChanged"),
		Struck = Networking.remoteEvent("Struck")
	}
end)()
Networking.namespace({
	name = "SammyEvent",
	env = "all"
})
Remotes.SammyEvent = (function()
	return {
		AskCollectPickup = Networking.remoteEvent("AskCollectPickup"),
		FetchPickups = Networking.remoteFunction("FetchPickups"),
		PickupCollected = Networking.remoteEvent("PickupCollected"),
		PickupRespawned = Networking.remoteEvent("PickupRespawned"),
		PickupsCleared = Networking.remoteEvent("PickupsCleared"),
		PickupsSpawned = Networking.remoteEvent("PickupsSpawned"),
		BomberRow = Networking.remoteEvent("BomberRow"),
		ElephantCharge = Networking.remoteEvent("ElephantCharge")
	}
end)()
Networking.namespace({
	name = "Broadcasts",
	env = "all"
})
Remotes.Broadcasts = {
	FlashUserId = Networking.remoteEvent("FlashUserId"),
	RaiseNotice = Networking.remoteEvent("RaiseNotice")
}
Networking.namespace({
	name = "StaffConsole",
	env = "all"
})
Remotes.StaffConsole = (function()
	return {
		GrantSelfEgg = Networking.remoteEvent("GrantSelfEgg"),
		GrantSelfPet = Networking.remoteEvent("GrantSelfPet"),
		GrantVerdict = Networking.remoteEvent("GrantVerdict"),
		ProbeStaffStatus = Networking.remoteEvent("ProbeStaffStatus"),
		SpeedPowerVerdict = Networking.remoteEvent("SpeedPowerVerdict"),
		StaffVerdict = Networking.remoteEvent("StaffVerdict"),
		WipeSelfProfile = Networking.remoteEvent("WipeSelfProfile"),
		WipeVerdict = Networking.remoteEvent("WipeVerdict"),
		WriteSpeedPower = Networking.remoteEvent("WriteSpeedPower"),
		WriteWalkSpeed = Networking.remoteEvent("WriteWalkSpeed")
	}
end)()
Networking.namespace({
	name = "Telemetry",
	env = "all"
})
Remotes.Telemetry = (function()
	return {
		AskIdleHopFlush = Networking.remoteFunction("AskIdleHopFlush"),
		SubmitIdleHop = Networking.remoteFunction("SubmitIdleHop"),
		SubmitIdleState = Networking.remoteEvent("SubmitIdleState")
	}
end)()
Networking.namespace({
	name = "PetSatchel",
	env = "all"
})
Remotes.PetSatchel = (function()
	return {
		SellEveryPet = Networking.remoteEvent("SellEveryPet"),
		SellSelection = Networking.remoteEvent("SellSelection"),
		SellPet = Networking.remoteEvent("SellPet"),
		WriteFavourite = Networking.remoteEvent("WriteFavourite")
	}
end)()
Networking.namespace({
	name = "SoundBus",
	env = "all"
})
Remotes.SoundBus = {
	EmitSound = Networking.remoteEvent("EmitSound")
}
Networking.namespace({
	name = "Haul",
	env = "all"
})
Remotes.Haul = (function()
	return {
		FetchAutoSell = Networking.remoteFunction("FetchAutoSell"),
		FetchWearBestStatus = Networking.remoteFunction("FetchWearBestStatus"),
		OfferFullSatchelSale = Networking.remoteFunction("OfferFullSatchelSale"),
		WearBest = Networking.remoteFunction("WearBest"),
		WriteAutoSell = Networking.remoteFunction("WriteAutoSell")
	}
end)()
Networking.namespace({
	name = "BatSwing",
	env = "all"
})
Remotes.BatSwing = {
	Trigger = Networking.remoteEvent("Trigger")
}
Networking.namespace({
	name = "SwapGadget",
	env = "all"
})
Remotes.SwapGadget = (function()
	return {
		AskSwap = Networking.remoteEvent("AskSwap"),
		EmitFx = Networking.remoteEvent("EmitFx"),
		EmitSfx = Networking.remoteEvent("EmitSfx")
	}
end)()
Networking.namespace({
	name = "DanceGadget",
	env = "all"
})
Remotes.DanceGadget = (function()
	return {
		AskDance = Networking.remoteEvent("AskDance"),
		AttachEffect = Networking.remoteEvent("AttachEffect"),
		DetachEffect = Networking.remoteEvent("DetachEffect"),
		EmitSfx = Networking.remoteEvent("EmitSfx")
	}
end)()
Networking.namespace({
	name = "ChatFeed",
	env = "all"
})
Remotes.ChatFeed = {
	Post = Networking.remoteEvent("Post")
}
Networking.namespace({
	name = "RigSync",
	env = "all"
})
Remotes.RigSync = (function()
	return {
		AskRigWipe = Networking.remoteEvent("AskRigWipe"),
		CorrectionBegan = Networking.remoteEvent("CorrectionBegan"),
		Primed = Networking.remoteEvent("Primed"),
		ProbeSatchel = Networking.remoteEvent("ProbeSatchel"),
		Reconcile = Networking.remoteFunction("Reconcile"),
		Refresh = Networking.remoteEvent("Refresh"),
		SeedSatchel = Networking.remoteEvent("SeedSatchel")
	}
end)()
Networking.namespace({
	name = "Toasts",
	env = "all"
})
Remotes.Toasts = {
	Line = Networking.remoteEvent("Line")
}
Networking.namespace({
	name = "Payouts",
	env = "all"
})
Remotes.Payouts = {
	Shower = Networking.remoteEvent("Shower")
}
Networking.namespace({
	name = "EggWorld",
	env = "all"
})
Remotes.EggWorld = (function()
	return {
		AskDoffTool = Networking.remoteFunction("AskDoffTool"),
		AskEggRecord = Networking.remoteFunction("AskEggRecord"),
		AskFieldEggCarry = Networking.remoteFunction("AskFieldEggCarry"),
		AskFieldEggDrop = Networking.remoteFunction("AskFieldEggDrop"),
		AskFieldEggRarityShows = Networking.remoteFunction("AskFieldEggRarityShows"),
		AskFieldEggSnapshot = Networking.remoteFunction("AskFieldEggSnapshot"),
		AskFinishHatch = Networking.remoteFunction("AskFinishHatch"),
		AskHatch = Networking.remoteFunction("AskHatch"),
		AskLiveSnapshot = Networking.remoteFunction("AskLiveSnapshot"),
		AskPlaceEgg = Networking.remoteFunction("AskPlaceEgg"),
		AskSkipGrowth = Networking.remoteFunction("AskSkipGrowth"),
		AskWearTool = Networking.remoteFunction("AskWearTool"),
		FieldEggBatchShifted = Networking.remoteEvent("FieldEggBatchShifted"),
		FieldEggCarry = Networking.remoteEvent("FieldEggCarry"),
		FieldEggCycleCountdown = Networking.remoteEvent("FieldEggCycleCountdown"),
		FieldEggGone = Networking.remoteEvent("FieldEggGone"),
		FieldEggRaritiesShown = Networking.remoteEvent("FieldEggRaritiesShown"),
		FieldEggRedeemVerdict = Networking.remoteEvent("FieldEggRedeemVerdict"),
		FieldEggShifted = Networking.remoteEvent("FieldEggShifted"),
		OwnerDropped = Networking.remoteEvent("OwnerDropped"),
		OwnerShifted = Networking.remoteEvent("OwnerShifted")
	}
end)()
Networking.namespace({
	name = "EggCapture",
	env = "all"
})
Remotes.EggCapture = {
	CutsceneBegan = Networking.remoteEvent("CutsceneBegan"),
	StandingsRefreshed = Networking.remoteEvent("StandingsRefreshed")
}
Networking.namespace({
	name = "IdleRescue",
	env = "all"
})
Remotes.IdleRescue = {
	AskRescueHop = Networking.remoteEvent("AskRescueHop"),
	SubmitIdleFlag = Networking.remoteEvent("SubmitIdleFlag")
}
Networking.namespace({
	name = "MonsterParasite",
	env = "all"
})
Remotes.MonsterParasite = (function()
	return {
		AskChestClaim = Networking.remoteFunction("AskChestClaim"),
		AskChestRevealComplete = Networking.remoteFunction("AskChestRevealComplete"),
		AskChestTake = Networking.remoteFunction("AskChestTake"),
		AskFeed = Networking.remoteFunction("AskFeed"),
		AskFullChargeReset = Networking.remoteEvent("AskFullChargeReset"),
		AskGrowthSwap = Networking.remoteEvent("AskGrowthSwap"),
		AskSnapshot = Networking.remoteFunction("AskSnapshot"),
		ChestOpened = Networking.remoteEvent("ChestOpened"),
		EventStateShifted = Networking.remoteEvent("EventStateShifted"),
		FeedSettled = Networking.remoteEvent("FeedSettled"),
		StateShifted = Networking.remoteEvent("StateShifted")
	}
end)()
Networking.namespace({
	name = "SeasonBanner",
	env = "all"
})
Remotes.SeasonBanner = {
	FetchState = Networking.remoteFunction("FetchState"),
	FlagSeen = Networking.remoteFunction("FlagSeen")
}
Networking.namespace({
	name = "ShopCta",
	env = "all"
})
Remotes.ShopCta = {
	FetchState = Networking.remoteFunction("FetchState"),
	FlagSeen = Networking.remoteFunction("FlagSeen")
}
Networking.namespace({
	name = "Trials",
	env = "all"
})
Remotes.Trials = {
	Fetch = Networking.remoteFunction("Fetch"),
	Refresh = Networking.remoteEvent("Refresh")
}
Networking.namespace({
	name = "FuseBiome",
	env = "all"
})
Remotes.FuseBiome = {
	PortalTransition = Networking.remoteEvent("PortalTransition")
}
Networking.namespace({
	name = "Fusery",
	env = "all"
})
Remotes.Fusery = (function()
	return {
		BeginFuse = Networking.remoteFunction("BeginFuse"),
		ConfirmBriefing = Networking.remoteFunction("ConfirmBriefing"),
		EjectPet = Networking.remoteFunction("EjectPet"),
		FinishReveal = Networking.remoteFunction("FinishReveal"),
		LoadPet = Networking.remoteFunction("LoadPet")
	}
end)()
Networking.namespace({
	name = "PassGrants",
	env = "all"
})
Remotes.PassGrants = {
	Awarded = Networking.remoteEvent("Awarded")
}
Networking.namespace({
	name = "GearSatchel",
	env = "all"
})
Remotes.GearSatchel = {
	Gained = Networking.remoteEvent("Gained"),
	Lost = Networking.remoteEvent("Lost")
}
Networking.namespace({
	name = "GroupPerk",
	env = "all"
})
Remotes.GroupPerk = {
	RedeemPerk = Networking.remoteFunction("RedeemPerk")
}
Networking.namespace({
	name = "GuardOnboarding",
	env = "all"
})
Remotes.GuardOnboarding = (function()
	return {
		AskLiveState = Networking.remoteFunction("AskLiveState"),
		AskProgressSync = Networking.remoteFunction("AskProgressSync"),
		LiveStateShifted = Networking.remoteEvent("LiveStateShifted")
	}
end)()
Networking.namespace({
	name = "GuardPatrol",
	env = "all"
})
Remotes.GuardPatrol = (function()
	return {
		AskEnabled = Networking.remoteFunction("AskEnabled"),
		EnabledShifted = Networking.remoteEvent("EnabledShifted"),
		ForestHandoff = Networking.remoteEvent("ForestHandoff"),
		ForestStrike = Networking.remoteEvent("ForestStrike"),
		Rouse = Networking.remoteEvent("Rouse"),
		SpeedTollOffer = Networking.remoteEvent("SpeedTollOffer"),
		SpeedTollWarning = Networking.remoteEvent("SpeedTollWarning")
	}
end)()
Networking.namespace({
	name = "GunGadget",
	env = "all"
})
Remotes.GunGadget = {
	AskDischarge = Networking.remoteEvent("AskDischarge"),
	DropCaster = Networking.remoteEvent("DropCaster")
}
Networking.namespace({
	name = "Codex",
	env = "all"
})
Remotes.Codex = (function()
	return {
		AskRedeem = Networking.remoteFunction("AskRedeem"),
		AskRedeemAll = Networking.remoteFunction("AskRedeemAll"),
		AskRedeemLimitedEgg = Networking.remoteFunction("AskRedeemLimitedEgg"),
		AskWearFieldBat = Networking.remoteFunction("AskWearFieldBat")
	}
end)()
Networking.namespace({
	name = "Referrals",
	env = "all"
})
Remotes.Referrals = {
	InviteLanded = Networking.remoteEvent("InviteLanded")
}
Networking.namespace({
	name = "LaserGadget",
	env = "all"
})
Remotes.LaserGadget = (function()
	return {
		AskDischarge = Networking.remoteEvent("AskDischarge"),
		EmitBeam = Networking.remoteEvent("EmitBeam"),
		EmitSfx = Networking.remoteEvent("EmitSfx")
	}
end)()
Networking.namespace({
	name = "MagnetGadget",
	env = "all"
})
Remotes.MagnetGadget = (function()
	return {
		AskTug = Networking.remoteEvent("AskTug"),
		EmitBeam = Networking.remoteEvent("EmitBeam"),
		EmitTargetFx = Networking.remoteEvent("EmitTargetFx"),
		HaltBeam = Networking.remoteEvent("HaltBeam"),
		HaltTargetFx = Networking.remoteEvent("HaltTargetFx")
	}
end)()
Networking.namespace({
	name = "MegaphoneGadget",
	env = "all"
})
Remotes.MegaphoneGadget = (function()
	return {
		CloseEffectWindow = Networking.remoteEvent("CloseEffectWindow"),
		EmitFx = Networking.remoteEvent("EmitFx"),
		EmitSfx = Networking.remoteEvent("EmitSfx"),
		OpenEffectWindow = Networking.remoteEvent("OpenEffectWindow"),
		Rouse = Networking.remoteEvent("Rouse")
	}
end)()
Networking.namespace({
	name = "Whodunnit",
	env = "all"
})
Remotes.Whodunnit = {
	RoundShifted = Networking.remoteEvent("RoundShifted")
}
Networking.namespace({
	name = "Alerts",
	env = "all"
})
Remotes.Alerts = {
	Raise = Networking.remoteEvent("Raise")
}
Networking.namespace({
	name = "RollbackRewards",
	env = "all"
})
Remotes.RollbackRewards = {
	ShowNotice = Networking.remoteEvent("ShowNotice")
}
Networking.namespace({
	name = "AwayEarnings",
	env = "all"
})
Remotes.AwayEarnings = (function()
	return {
		AskCollect = Networking.remoteFunction("AskCollect"),
		FetchSummary = Networking.remoteFunction("FetchSummary"),
		PendingCheck = Networking.remoteFunction("PendingCheck"),
		Redeemed = Networking.remoteEvent("Redeemed"),
		SummaryRefreshed = Networking.remoteEvent("SummaryRefreshed")
	}
end)()
Networking.namespace({
	name = "Homestead",
	env = "all"
})
Remotes.Homestead = (function()
	return {
		AskBaseTierRaise = Networking.remoteEvent("AskBaseTierRaise"),
		AskLobbyHop = Networking.remoteEvent("AskLobbyHop"),
		AskNearbyPurchase = Networking.remoteEvent("AskNearbyPurchase"),
		AskState = Networking.remoteFunction("AskState"),
		BaseTierRaised = Networking.remoteEvent("BaseTierRaised"),
		DimBaseOutline = Networking.remoteEvent("DimBaseOutline"),
		LitBaseOutline = Networking.remoteEvent("LitBaseOutline"),
		StateShifted = Networking.remoteEvent("StateShifted")
	}
end)()
Networking.namespace({
	name = "Gifting",
	env = "all"
})
Remotes.Gifting = (function()
	return {
		Received = Networking.remoteEvent("Received"),
		PromptFinished = Networking.remoteEvent("PromptFinished"),
		AskGift = Networking.remoteFunction("AskGift"),
		Completed = Networking.remoteEvent("Completed")
	}
end)()
Networking.namespace({
	name = "Storefront",
	env = "all"
})
Remotes.Storefront = (function()
	return {
		AllowPurchase = Networking.remoteFunction("AllowPurchase"),
		AskPurchaseOffer = Networking.remoteFunction("AskPurchaseOffer"),
		AskServerProbe = Networking.remoteFunction("AskServerProbe"),
		Awarded = Networking.remoteEvent("Awarded"),
		PurchaseRejected = Networking.remoteEvent("PurchaseRejected"),
		PurchaseSettled = Networking.remoteEvent("PurchaseSettled"),
		ReceiptCleared = Networking.remoteEvent("ReceiptCleared")
	}
end)()
Networking.namespace({
	name = "Limpness",
	env = "all"
})
Remotes.Limpness = {
	WriteLimpness = Networking.remoteEvent("WriteLimpness")
}
Networking.namespace({
	name = "ProfileMirror",
	env = "all"
})
Remotes.ProfileMirror = {
	FetchProfile = Networking.remoteFunction("FetchProfile"),
	ProfileDelta = Networking.remoteEvent("ProfileDelta")
}
Networking.namespace({
	name = "SharedFx",
	env = "all"
})
Remotes.SharedFx = {
	JoltOnce = Networking.remoteEvent("JoltOnce")
}
Networking.namespace({
	name = "Bloomery",
	env = "all"
})
Remotes.Bloomery = (function()
	return {
		AskBriefingConfirm = Networking.remoteFunction("AskBriefingConfirm"),
		AskCraneReturn = Networking.remoteFunction("AskCraneReturn"),
		AskEjectEgg = Networking.remoteFunction("AskEjectEgg"),
		AskGatherPetal = Networking.remoteFunction("AskGatherPetal"),
		AskHandoff = Networking.remoteFunction("AskHandoff"),
		AskLoadEgg = Networking.remoteFunction("AskLoadEgg"),
		AskMutate = Networking.remoteFunction("AskMutate"),
		AskStrikeTree = Networking.remoteEvent("AskStrikeTree"),
		CutsceneOpened = Networking.remoteEvent("CutsceneOpened"),
		PetalsGathered = Networking.remoteEvent("PetalsGathered")
	}
end)()
Networking.namespace({
	name = "LuckWindow",
	env = "all"
})
Remotes.LuckWindow = {
	FetchState = Networking.remoteFunction("FetchState"),
	StateRefreshed = Networking.remoteEvent("StateRefreshed")
}
Networking.namespace({
	name = "Preferences",
	env = "all"
})
Remotes.Preferences = {
	AskWrite = Networking.remoteFunction("AskWrite"),
	PreferenceShifted = Networking.remoteEvent("PreferenceShifted")
}
Networking.namespace({
	name = "MineTrap",
	env = "all"
})
Remotes.MineTrap = (function()
	return {
		AskPlace = Networking.remoteEvent("AskPlace"),
		AttachOutline = Networking.remoteEvent("AttachOutline"),
		TrapSet = Networking.remoteEvent("TrapSet")
	}
end)()
Networking.namespace({
	name = "Lifecycle",
	env = "all"
})
Remotes.Lifecycle = {
	BeginShutdown = Networking.remoteEvent("BeginShutdown")
}
Networking.namespace({
	name = "ToolTrigger",
	env = "all"
})
Remotes.ToolTrigger = {
	Trigger = Networking.remoteEvent("Trigger")
}
Networking.namespace({
	name = "Trailwear",
	env = "all"
})
Remotes.Trailwear = (function()
	return {
		AskChoose = Networking.remoteFunction("AskChoose"),
		AskDoff = Networking.remoteFunction("AskDoff"),
		AskPurchase = Networking.remoteFunction("AskPurchase"),
		AskWornSnapshot = Networking.remoteFunction("AskWornSnapshot"),
		WornTrailShifted = Networking.remoteEvent("WornTrailShifted")
	}
end)()
Networking.namespace({
	name = "TrapPlacement",
	env = "all"
})
Remotes.TrapPlacement = {
	AskPlace = Networking.remoteEvent("AskPlace")
}
Networking.namespace({
	name = "GravityDisruptor",
	env = "all"
})
Remotes.GravityDisruptor = {
	AskPlace = Networking.remoteEvent("AskPlace"),
	Burst = Networking.remoteEvent("Burst")
}
Networking.namespace({
	name = "Treadmill",
	env = "all"
})
Remotes.Treadmill = (function()
	return {
		AskClipFavour = Networking.remoteFunction("AskClipFavour"),
		AskDoff = Networking.remoteFunction("AskDoff"),
		AskFavourSnapshot = Networking.remoteFunction("AskFavourSnapshot"),
		AskFriendFavourSnapshot = Networking.remoteFunction("AskFriendFavourSnapshot"),
		AskPostReply = Networking.remoteFunction("AskPostReply"),
		AskRenderSnapshot = Networking.remoteFunction("AskRenderSnapshot"),
		AskReplyCounts = Networking.remoteFunction("AskReplyCounts"),
		AskReplyFavour = Networking.remoteFunction("AskReplyFavour"),
		AskReplyPage = Networking.remoteFunction("AskReplyPage"),
		AskSlowToggle = Networking.remoteFunction("AskSlowToggle"),
		AskSlowToggleSet = Networking.remoteFunction("AskSlowToggleSet"),
		AskTierRaise = Networking.remoteFunction("AskTierRaise"),
		AskWearStill = Networking.remoteFunction("AskWearStill"),
		AssignedBeltShifted = Networking.remoteEvent("AssignedBeltShifted"),
		GaugeClipLength = Networking.remoteFunction("GaugeClipLength"),
		OverlaySnapshot = Networking.remoteEvent("OverlaySnapshot"),
		RefreshClipCursor = Networking.remoteEvent("RefreshClipCursor"),
		RenderStateShifted = Networking.remoteEvent("RenderStateShifted"),
		SpeedGained = Networking.remoteEvent("SpeedGained"),
		SubmitClipView = Networking.remoteEvent("SubmitClipView"),
		ViewStateShifted = Networking.remoteEvent("ViewStateShifted")
	}
end)()
Networking.namespace({
	name = "ZoneProbe",
	env = "all"
})
Remotes.ZoneProbe = {
	AnchorForZone = Networking.remoteEvent("AnchorForZone")
}
Networking.namespace({
	name = "MonsterEvent",
	env = "all"
})
Remotes.MonsterEvent = (function()
	return {
		GetWins = Networking.remoteFunction("GetWins"),
		WinsUpdated = Networking.remoteEvent("WinsUpdated"),
		GetWinParts = Networking.remoteFunction("GetWinParts"),
		WinPartsUpdated = Networking.remoteEvent("WinPartsUpdated"),
		RequestTeleport = Networking.remoteFunction("RequestTeleport"),
		PlaySFX = Networking.remoteEvent("PlaySFX")
	}
end)()
Networking.namespace({
	name = "ShrineFusion",
	env = "all"
})
Remotes.ShrineFusion = (function()
	return {
		AskState = Networking.remoteFunction("AskState"),
		AskSubmit = Networking.remoteFunction("AskSubmit"),
		Feedback = Networking.remoteEvent("Feedback"),
		StateChanged = Networking.remoteEvent("StateChanged"),
		Ritual = Networking.remoteEvent("Ritual")
	}
end)()
Networking.namespace({
	name = "BanjoCricket",
	env = "all"
})
Remotes.BanjoCricket = (function()
	return {
		AskClaim = Networking.remoteFunction("AskClaim"),
		Aim = Networking.remoteEvent("Aim"),
		Effect = Networking.remoteEvent("Effect"),
		Squish = Networking.remoteEvent("Squish")
	}
end)()
Networking.namespace({
	name = "Rift",
	env = "all"
})
Remotes.Rift = (function()
	return {
		AskState = Networking.remoteFunction("AskState"),
		AskTradeIn = Networking.remoteFunction("AskTradeIn"),
		AskRefresh = Networking.remoteFunction("AskRefresh"),
		AskFinishReveal = Networking.remoteFunction("AskFinishReveal"),
		BannerRotated = Networking.remoteEvent("BannerRotated")
	}
end)()
Networking.namespace({
	name = "ScrambleTradeIn",
	env = "all"
})
Remotes.ScrambleTradeIn = (function()
	return {
		AskState = Networking.remoteFunction("AskState"),
		AskTradeIn = Networking.remoteFunction("AskTradeIn"),
		AskRefresh = Networking.remoteFunction("AskRefresh"),
		AskFinishReveal = Networking.remoteFunction("AskFinishReveal"),
		BannerRotated = Networking.remoteEvent("BannerRotated")
	}
end)()
Networking.namespace({
	name = "RewardScreen",
	env = "all"
})
Remotes.RewardScreen = {
	Show = Networking.remoteEvent("Show")
}
Networking.namespace({
	name = "OnboardingQuestline",
	env = "all"
})
Remotes.OnboardingQuestline = {
	AskAcknowledge = Networking.remoteFunction("AskAcknowledge"),
	AskClaim = Networking.remoteFunction("AskClaim")
}
Networking.namespace({
	name = "BossEvent",
	env = "all"
})
Remotes.BossEvent = (function()
	return {
		AskEnter = Networking.remoteFunction("AskEnter"),
		AskSnapshot = Networking.remoteFunction("AskSnapshot"),
		BlackHoleHit = Networking.remoteEvent("BlackHoleHit"),
		BossDamaged = Networking.remoteEvent("BossDamaged"),
		HazardHit = Networking.remoteEvent("HazardHit"),
		HealthShifted = Networking.remoteEvent("HealthShifted"),
		StateShifted = Networking.remoteEvent("StateShifted"),
		Vfx = Networking.remoteEvent("Vfx")
	}
end)()
Networking.namespace({
	name = "ScrambleBoss",
	env = "all"
})
Remotes.ScrambleBoss = (function()
	return {
		EnterArena = Networking.remoteFunction("EnterArena"),
		Fx = Networking.remoteEvent("Fx"),
		Hazard = Networking.remoteEvent("Hazard"),
		HazardHit = Networking.remoteEvent("HazardHit"),
		Transition = Networking.remoteEvent("Transition")
	}
end)()
Networking.namespace({
	name = "BossMastery",
	env = "all"
})
Remotes.BossMastery = (function()
	return {
		AskBuyShopItem = Networking.remoteFunction("AskBuyShopItem"),
		AskClaimMilestone = Networking.remoteFunction("AskClaimMilestone"),
		AskUseMutationConsumable = Networking.remoteFunction("AskUseMutationConsumable")
	}
end)()
Networking.namespace({
	name = "Leaderboards",
	env = "all"
})
Remotes.Leaderboards = {
	Fetch = Networking.remoteFunction("Fetch"),
	Updated = Networking.remoteEvent("Updated")
}
Networking.namespace({
	name = "Voting",
	env = "all"
})
Remotes.Voting = {
	Vote = Networking.remoteEvent("Vote")
}
Networking.namespace({
	name = "LimitedTimePopups",
	env = "all"
})
Remotes.LimitedTimePopups = {
	ShowLimitedTimePopup = Networking.remoteEvent("ShowLimitedTimePopup")
}
Networking.close()
return Remotes