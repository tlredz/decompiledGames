return {
	Performance = {
		FpsBad = 38,
		FpsGood = 57,
		JitterGood = 1.6,
		JitterBad = 4,
		HeartbeatGoodMs = 16,
		HeartbeatBadMs = 30,
		FpsWeight = 0.55,
		JitterWeight = 0.25,
		HeartbeatWeight = 0.2,
		ExpectedFps = {
			[0] = 60,
			[4] = 59,
			[8] = 57,
			[12] = 54,
			[16] = 50
		}
	},
	Memory = {
		MemOkMb = 3000,
		MemCritMb = 7000,
		HeapOkMb = 1200,
		HeapCritMb = 3000,
		InstancesOk = 60000,
		InstancesCrit = 140000,
		MemWeight = 0.45,
		HeapWeight = 0.4,
		InstanceWeight = 0.15
	},
	Stability = {
		ErrorsOkPerMin = 2,
		ErrorsCritPerMin = 25,
		DatastoreFailOk = 0.02,
		DatastoreFailCrit = 0.2,
		BounceOk = 0.15,
		BounceCrit = 0.5,
		ErrorWeight = 0.3,
		DatastoreWeight = 0.35,
		BounceWeight = 0.25,
		WarningWeight = 0.1
	},
	Gates = {
		LatencyGoodMs = 45,
		LatencyBadMs = 180,
		LatencyFloor = 0.05,
		PerfFloor = 0.15,
		StabilityFloor = 0.3,
		MemoryFloor = 0.5,
		PopulatedFloor = 0.3,
		FreshFloor = 0.4,
		PopulatedLow = 1,
		PopulatedHigh = 6,
		FreshGoodSeconds = 45,
		FreshBadSeconds = 150
	},
	Desirability = {
		FillPeak = 0.72,
		FillSpread = 0.2,
		FriendCurve = 1.6,
		ReadySeconds = 90,
		MomentumSpan = 4,
		UptimeWarmupStart = 60,
		UptimeWarmupEnd = 240,
		UptimeDecayStart = 10800,
		UptimeDecayEnd = 28800,
		UptimeDecayAmount = 0.4,
		PopulationWeight = 0.34,
		SocialWeight = 0.28,
		ReadyWeight = 0.16,
		MomentumWeight = 0.12,
		AgeWeight = 0.1
	},
	Herd = {
		PoolSize = 5,
		Temperature = 0.005
	},
	RecentlyLeftPenalty = 0.35,
	RecentlyLeftSeconds = 600,
	OldBuildPenalty = 0.5,
	OldBuildExcludeRatio = 0.4
}