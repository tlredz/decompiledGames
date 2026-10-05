return table.freeze({
	Shared = {
		ChaseDuration = 6.3,
		PreChaseSeaHoldTime = 0.6,
		BlackTransitionTime = 0.3,
		ScenePreRevealTime = 0.1,
		CameraPanTime = 2.2,
		CameraPanFrequency = 0.42,
		MarineEntranceMaxStartDelay = 0.12,
		Marine2DialogueDelay = 1.9,
		Marine2DialogueHoldTime = 0.75,
		FollowerCameraTrackingFrequency = 0.55,
		CrateApproachTime = 1.25,
		FollowerInspectDialogueHoldTime = 0.45,
		CratePickupTime = 0.55,
		CrateHandIKSmoothTime = 0.015,
		FollowerCrateCarryTime = 0.8,
		CrateInvertTime = 0.65,
		CrateShakeTime = 0.9,
		CrateTossTime = 0.75,
		FruitGrowTime = 0.55,
		FloppySettleTime = 0.45
	},
	Success = {
		FinaleHoldTime = 5.5,
		FollowerReactionPauseTime = 1,
		FollowerHeadTurnTime = 0.45,
		FollowerExpressionChangeTime = 0.5,
		PirateReactionDelay = 2.5,
		GrabFruitTimeout = 0.8,
		FruitPickupIKSmoothTime = 0.06,
		FruitPickupReachTime = 0.32,
		FollowerEatTime = 3,
		DragonTransformWaitTime = 0.3,
		DragonScaleTime = 0.33,
		DragonPostTransformHoldTime = 0.35
	},
	Failure = {
		FinaleHoldTime = 1.25,
		ChaseReplyDelay = 1.35,
		LookoutConcernDelay = 1.75,
		ChaseCameraTrackingFrequency = 3.5,
		ChaseFieldOfViewInFrequency = 2.5,
		ChaseFieldOfViewOutFrequency = 3,
		CrateItemLandingWaitTime = 1,
		CrateDialogueDelay = 0.5,
		CrateReactionHoldTimes = {
			Fisherman = 1.5,
			Doghouse = 0.5
		},
		BoxOpenerReactionDelay = 0.2,
		OtherMarineReactionDelay = 0.45,
		Fisherman = {
			LineHoldTime = 1.1,
			GrabFishTimeout = 1.2,
			FishPickupTime = 0.5,
			PainAuraAnchorGuardTime = 2,
			PreSlapDelay = 0.08,
			SlapImpactDelay = 0.22,
			SlapInterval = 0.45,
			SlapLaunchTime = 0.8,
			FinalHoldTime = 1.4
		},
		Doghouse = {
			BanCommandHoldTime = 1,
			BanCorrectionHoldTime = 1.1
		}
	}
})