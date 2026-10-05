local v = {
	[5] = "FirstSteps",
	[10] = "QuickFeet",
	[15] = "CornerArtist",
	[20] = "Untouchable",
	[25] = "ValleyVeteran",
	[30] = "ValleyElite"
}
local v2 = {
	[10] = "NightRunner",
	[20] = "CrownChaser",
	[30] = "ValleyRoyalty"
}
local JourneySeason1Rewards = {}

for i = 1, 30 do
	JourneySeason1Rewards[i] = {
		Free = {
			Key = "free_" .. i,
			Gems = i % 5 == 0 and 50 or 15,
			Badge = v[i]
		},
		Premium = {
			Key = "premium_" .. i,
			Gems = i % 5 == 0 and 100 or 35,
			Coins = i % 5 == 0 and 150 or 0,
			Badge = v2[i]
		}
	}
end

for _, v3 in { 10, 20, 30 } do
	JourneySeason1Rewards[v3].Free.KnifeSlot = "DAGGER · COMING LATER"
end

for _, v3 in {
	5,
	10,
	15,
	20,
	25,
	30
} do
	JourneySeason1Rewards[v3].Premium.KnifeSlot = "DAGGER · COMING LATER"
end

JourneySeason1Rewards[30].Premium.SkinId = "IceCreamDagger"
JourneySeason1Rewards[30].Premium.KnifeSlot = nil
return JourneySeason1Rewards