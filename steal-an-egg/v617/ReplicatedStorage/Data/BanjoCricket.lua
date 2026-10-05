local v = {
	Tags = {
		Mushroom = "BanjoCricketMushroom",
		Roots = "BanjoCricketRoots",
		Door = "BanjoCricketDoor",
		Npc = "BanjoCricketNpc",
		Music = "BanjoCricketMusic"
	},
	Attributes = {
		MushroomIndex = "MushroomIndex",
		RevealOffset = "RevealOffset",
		DoorOpenAngle = "DoorOpenAngleDegrees"
	},
	InteractionPoint = "InteractionPoint",
	NpcName = "Banjo Cricket",
	TalkDistance = 10,
	MaxStages = 10,
	RewardTitle = "SECRET DISCOVERED!",
	Mushrooms = {
		{
			Color = Color3.fromRGB(170, 85, 255),
			Sound = "rbxassetid://102552141386469",
			Speed = 1
		},
		{
			Color = Color3.fromRGB(60, 150, 255),
			Sound = "rbxassetid://104876683752369",
			Speed = 1
		},
		{
			Color = Color3.fromRGB(255, 70, 70),
			Sound = "rbxassetid://119845624347952",
			Speed = 0.994
		},
		{
			Color = Color3.fromRGB(80, 210, 90),
			Sound = "rbxassetid://83109976640084",
			Speed = 1.125
		},
		{
			Color = Color3.fromRGB(255, 200, 50),
			Sound = "rbxassetid://100776802447610",
			Speed = 1.122
		}
	},
	Timing = {
		StartPause = 1,
		Note = 0.45,
		NoteGap = 0.2,
		StagePause = 1,
		WrongPause = 1.2,
		ListenTimeout = 20
	},
	Reveal = {
		LightsAt = 0.5,
		HarmonyAt = 1,
		MusicAt = 2,
		RootsAt = 2.5,
		RootsSeconds = 0.5,
		DoorAt = 4,
		DoorSeconds = 1.2,
		LightsOffAt = 5
	},
	Sounds = {
		Creak = "rbxassetid://9125407239",
		Band = "rbxassetid://1839110349"
	},
	Textures = {
		Spore = "rbxasset://textures/particles/sparkles_main.dds",
		Note = "rbxassetid://253828517"
	},
	Volume = {
		Note = 0.8,
		Muted = 0.35,
		Soft = 0.4,
		Sour = 0.5,
		Strum = 0.45,
		Creak = 0.6,
		BandFaint = 0.12,
		Band = 0.5
	},
	Lines = {
		Reward = {
			"Well, howdy! Nobody's found our little hideout in ages.",
			"Those mushrooms only sing for folks with a real ear for music.",
			"Every band needs a new member... here, take these!"
		},
		Encore = { "Back for an encore? The band never stops playing!" }
	}
}

function v.PlaybackSeconds(p: number)
	local timing = v.Timing
	return p * timing.Note + math.max(p - 1, 0) * timing.NoteGap
end

return table.freeze(v)