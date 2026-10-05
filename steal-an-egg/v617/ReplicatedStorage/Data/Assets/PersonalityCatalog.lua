local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(script.Parent.Types)
local Numeric = require(ReplicatedStorage.Shared.Utils.Numeric)
local rollWeighted = Numeric.RollWeighted
local frozen = table.freeze({
	Normal = "Normal",
	Lazy = "Lazy",
	Loyal = "Loyal",
	Energetic = "Energetic",
	InvertedModel = "InvertedModel",
	Shy = "Shy",
	Scared = "Scared",
	ExtremelyEnergetic = "ExtremelyEnergetic",
	UltraLoyal = "UltraLoyal",
	JumpCrazy = "JumpCrazy"
})
local energetic = {
	_id = frozen.Energetic,
	RollWeight = 12,
	Movement = {
		WalkSpeedMin = 9,
		WalkSpeedMax = 20,
		IdleSecondsMin = 0.1,
		IdleSecondsMax = 0.75,
		NearOwnerPreference = 0.2,
		IsolationPreference = 0,
		CurvedWanderChance = 0.62,
		BurstChance = 0.42,
		FollowOwnerInPen = false,
		AmbientJumpRatePerSecond = 0,
		AmbientSpinJumpChance = 0
	},
	Greeting = {
		Chance = 1,
		FirstPlacementChance = 1,
		FirstPlacementNormalChance = 0,
		FirstPlacementNormalJumpCount = 4,
		ReturnOrbitChance = 0.6,
		ReturnNormalJumpCount = 3,
		RandomOrbitChance = 0.2,
		RandomOrbitIntervalSeconds = 45,
		DurationSeconds = 6,
		JumpChancePerSecond = 0.85,
		SpinJumpChance = 0.3,
		Texts = { "😊", "😄", "🥰" }
	},
	Affection = {
		Enabled = true,
		Chance = 0.125,
		IntervalSeconds = 5,
		DurationSeconds = 4.5,
		JumpCount = 5,
		Texts = {
			"😆",
			"😄",
			"😁",
			"😃",
			"🤪",
			"😝",
			"😜",
			"😋",
			"😹",
			"🙀",
			"😎"
		}
	}
}
local greeting = energetic.Greeting
local greeting2 = {
	Chance = greeting.Chance,
	FirstPlacementChance = greeting.FirstPlacementChance,
	FirstPlacementNormalChance = greeting.FirstPlacementNormalChance,
	FirstPlacementNormalJumpCount = greeting.FirstPlacementNormalJumpCount,
	ReturnOrbitChance = greeting.ReturnOrbitChance,
	ReturnNormalJumpCount = greeting.ReturnNormalJumpCount,
	RandomOrbitChance = greeting.RandomOrbitChance,
	RandomOrbitIntervalSeconds = greeting.RandomOrbitIntervalSeconds,
	DurationSeconds = greeting.DurationSeconds,
	JumpChancePerSecond = greeting.JumpChancePerSecond,
	SpinJumpChance = greeting.SpinJumpChance,
	Texts = {
		"//ERRsORijwoR//",
		"0x?#!@NLL",
		"01011010???",
		"▓▒░???░▒▓",
		"M4M4.EXE???",
		"##!%$@//",
		"<???:'aWsFE>",
		"1010_=249_0101",
		"??//V//#"
	}
}
local invertedModel = {
	_id = frozen.InvertedModel,
	RollWeight = 1.5,
	Movement = energetic.Movement,
	Greeting = greeting2,
	Affection = energetic.Affection
}
local configs = {
	Normal = {
		_id = frozen.Normal,
		RollWeight = 37,
		Movement = {
			WalkSpeedMin = 6.5,
			WalkSpeedMax = 12,
			IdleSecondsMin = 1.2,
			IdleSecondsMax = 3.2,
			NearOwnerPreference = 0.14,
			IsolationPreference = 0,
			CurvedWanderChance = 0.16,
			BurstChance = 0.035,
			FollowOwnerInPen = false,
			AmbientJumpRatePerSecond = 0,
			AmbientSpinJumpChance = 0
		},
		Greeting = {
			Chance = 1,
			FirstPlacementChance = 0,
			FirstPlacementNormalChance = 1,
			FirstPlacementNormalJumpCount = 3,
			ReturnOrbitChance = 0,
			ReturnNormalJumpCount = 2,
			RandomOrbitChance = 0,
			RandomOrbitIntervalSeconds = 45,
			DurationSeconds = 6,
			JumpChancePerSecond = 0.8,
			SpinJumpChance = 0.08,
			Texts = { "😊", "😄", "🥰" }
		},
		Affection = {
			Enabled = true,
			Chance = 0.16666666666666666,
			IntervalSeconds = 5,
			DurationSeconds = 4,
			JumpCount = 2,
			Texts = {
				"😊",
				"😄",
				"🙂",
				"☺️",
				"🥰",
				"😃",
				"😁",
				"🤗"
			}
		}
	},
	Lazy = {
		_id = frozen.Lazy,
		RollWeight = 15,
		Movement = {
			WalkSpeedMin = 2.5,
			WalkSpeedMax = 3.75,
			IdleSecondsMin = 6,
			IdleSecondsMax = 15,
			NearOwnerPreference = 0.025,
			IsolationPreference = 0.08,
			CurvedWanderChance = 0.025,
			BurstChance = 0,
			FollowOwnerInPen = false,
			AmbientJumpRatePerSecond = 0,
			AmbientSpinJumpChance = 0
		},
		Greeting = {
			Chance = 0,
			FirstPlacementChance = 0,
			FirstPlacementNormalChance = 0,
			FirstPlacementNormalJumpCount = 0,
			ReturnOrbitChance = 0,
			ReturnNormalJumpCount = 1,
			RandomOrbitChance = 0,
			RandomOrbitIntervalSeconds = 60,
			DurationSeconds = 3.5,
			JumpChancePerSecond = 0.08,
			SpinJumpChance = 0,
			Texts = { "😊", "😄", "🥰" }
		},
		Affection = {
			Enabled = false,
			Chance = 0,
			IntervalSeconds = 80,
			DurationSeconds = 0,
			JumpCount = 0,
			Texts = {
				"😴",
				"🥱",
				"😪",
				"😌",
				"😐",
				"😑",
				"😶",
				"🙃"
			}
		}
	},
	Loyal = {
		_id = frozen.Loyal,
		RollWeight = 10,
		Movement = {
			WalkSpeedMin = 7.5,
			WalkSpeedMax = 10,
			IdleSecondsMin = 0.35,
			IdleSecondsMax = 1.25,
			NearOwnerPreference = 0.9,
			IsolationPreference = 0,
			CurvedWanderChance = 0.08,
			BurstChance = 0.055,
			FollowOwnerInPen = true,
			AmbientJumpRatePerSecond = 0,
			AmbientSpinJumpChance = 0
		},
		Greeting = {
			Chance = 1,
			FirstPlacementChance = 1,
			FirstPlacementNormalChance = 0,
			FirstPlacementNormalJumpCount = 3,
			ReturnOrbitChance = 0.45,
			ReturnNormalJumpCount = 2,
			RandomOrbitChance = 0.08,
			RandomOrbitIntervalSeconds = 45,
			DurationSeconds = 6.5,
			JumpChancePerSecond = 0.55,
			SpinJumpChance = 0.06,
			Texts = { "Mama" }
		},
		Affection = {
			Enabled = true,
			Chance = 0.002976190476190476,
			IntervalSeconds = 5,
			DurationSeconds = 5,
			JumpCount = 2,
			Texts = {
				"🥰",
				"😍",
				"😊",
				"☺️",
				"🤗",
				"😚"
			}
		}
	},
	Energetic = energetic,
	InvertedModel = invertedModel,
	Shy = {
		_id = frozen.Shy,
		RollWeight = 10,
		Movement = {
			WalkSpeedMin = 3,
			WalkSpeedMax = 5,
			IdleSecondsMin = 5.5,
			IdleSecondsMax = 14,
			NearOwnerPreference = 0,
			IsolationPreference = 0.95,
			CurvedWanderChance = 0.035,
			BurstChance = 0,
			FollowOwnerInPen = false,
			AmbientJumpRatePerSecond = 0,
			AmbientSpinJumpChance = 0,
			Retreat = {
				TriggerDistance = 22,
				Chance = 0.85,
				MaxTravelDistance = 16
			}
		},
		Greeting = {
			Chance = 0,
			FirstPlacementChance = 0,
			FirstPlacementBubbleChance = 0,
			FirstPlacementNormalChance = 0,
			FirstPlacementNormalJumpCount = 0,
			ReturnOrbitChance = 0,
			ReturnNormalJumpCount = 0,
			RandomOrbitChance = 0,
			RandomOrbitIntervalSeconds = 30,
			DurationSeconds = 0,
			JumpChancePerSecond = 0,
			SpinJumpChance = 0,
			Texts = { "😊" }
		},
		Affection = {
			Enabled = false,
			Chance = 0,
			IntervalSeconds = 50,
			DurationSeconds = 0,
			JumpCount = 0,
			Texts = { "😊", "😄", "🥰" }
		}
	},
	Scared = {
		_id = frozen.Scared,
		RollWeight = 5,
		Movement = {
			WalkSpeedMin = 20,
			WalkSpeedMax = 40,
			IdleSecondsMin = 0.8,
			IdleSecondsMax = 4,
			NearOwnerPreference = 0,
			IsolationPreference = 1,
			CurvedWanderChance = 0.03,
			BurstChance = 0,
			FollowOwnerInPen = false,
			AmbientJumpRatePerSecond = 0,
			AmbientSpinJumpChance = 0,
			Retreat = {
				TriggerDistance = 20,
				Chance = 1
			},
			IdleTremble = {
				Amplitude = 0.1,
				CyclesPerSecond = 3
			}
		},
		Greeting = {
			Chance = 0,
			FirstPlacementChance = 0,
			FirstPlacementBubbleChance = 1,
			FirstPlacementNormalChance = 0,
			FirstPlacementNormalJumpCount = 0,
			ReturnOrbitChance = 0,
			ReturnNormalJumpCount = 0,
			RandomOrbitChance = 0,
			RandomOrbitIntervalSeconds = 30,
			DurationSeconds = 0,
			JumpChancePerSecond = 0,
			SpinJumpChance = 0,
			Texts = { "Where is MAMA 😰?" }
		},
		Affection = {
			Enabled = false,
			Chance = 0,
			IntervalSeconds = 50,
			DurationSeconds = 0,
			JumpCount = 0,
			Texts = { "😨", "😰" }
		}
	},
	ExtremelyEnergetic = {
		_id = frozen.ExtremelyEnergetic,
		RollWeight = 3.5,
		Movement = {
			WalkSpeedMin = 30,
			WalkSpeedMax = 70,
			IdleSecondsMin = 0.05,
			IdleSecondsMax = 0.2,
			NearOwnerPreference = 0.2,
			IsolationPreference = 0,
			CurvedWanderChance = 0.8,
			BurstChance = 0.7,
			FollowOwnerInPen = false,
			AmbientJumpRatePerSecond = 3.5,
			AmbientSpinJumpChance = 0.35
		},
		Greeting = {
			Chance = 1,
			FirstPlacementChance = 1,
			FirstPlacementNormalChance = 0,
			FirstPlacementNormalJumpCount = 5,
			ReturnOrbitChance = 0.75,
			ReturnNormalJumpCount = 5,
			RandomOrbitChance = 0.35,
			RandomOrbitIntervalSeconds = 30,
			DurationSeconds = 6,
			JumpChancePerSecond = 1.8,
			SpinJumpChance = 0.4,
			Texts = { "🤩", "🤪" }
		},
		Affection = {
			Enabled = true,
			Chance = 0.1,
			IntervalSeconds = 5,
			DurationSeconds = 4.5,
			JumpCount = 7,
			Texts = { "🤩", "😆", "🤪" }
		}
	},
	UltraLoyal = {
		_id = frozen.UltraLoyal,
		RollWeight = 2.5,
		Movement = {
			WalkSpeedMin = 10,
			WalkSpeedMax = 16,
			IdleSecondsMin = 0.1,
			IdleSecondsMax = 0.5,
			NearOwnerPreference = 0.98,
			IsolationPreference = 0,
			CurvedWanderChance = 0.12,
			BurstChance = 0.1,
			FollowOwnerInPen = true,
			AmbientJumpRatePerSecond = 0.35,
			AmbientSpinJumpChance = 0.1
		},
		Greeting = {
			Chance = 1,
			FirstPlacementChance = 1,
			FirstPlacementNormalChance = 0,
			FirstPlacementNormalJumpCount = 4,
			ReturnOrbitChance = 0.9,
			ReturnNormalJumpCount = 3,
			RandomOrbitChance = 0.9,
			RandomOrbitIntervalSeconds = 5,
			DurationSeconds = 6.5,
			JumpChancePerSecond = 0.8,
			SpinJumpChance = 0.1,
			Texts = { "Mama 🤗", "Mama 🥰" }
		},
		Affection = {
			Enabled = true,
			Chance = 0.15151515151515152,
			IntervalSeconds = 5,
			DurationSeconds = 5,
			JumpCount = 3,
			Texts = { "🥰", "🤗" }
		}
	},
	JumpCrazy = {
		_id = frozen.JumpCrazy,
		RollWeight = 3.5,
		Movement = {
			WalkSpeedMin = 10,
			WalkSpeedMax = 18,
			IdleSecondsMin = 0.05,
			IdleSecondsMax = 0.3,
			NearOwnerPreference = 0.2,
			IsolationPreference = 0,
			CurvedWanderChance = 0.25,
			BurstChance = 0.1,
			FollowOwnerInPen = false,
			AmbientJumpRatePerSecond = 12,
			AmbientSpinJumpChance = 0.5
		},
		Greeting = {
			Chance = 1,
			FirstPlacementChance = 0,
			FirstPlacementNormalChance = 1,
			FirstPlacementNormalJumpCount = 8,
			ReturnOrbitChance = 0,
			ReturnNormalJumpCount = 7,
			RandomOrbitChance = 0,
			RandomOrbitIntervalSeconds = 30,
			DurationSeconds = 6,
			JumpChancePerSecond = 2,
			SpinJumpChance = 0.5,
			Texts = {
				"😆",
				"😄",
				"😁",
				"😃",
				"🤪",
				"😝",
				"😜",
				"😋",
				"😹",
				"🙀",
				"😎"
			}
		},
		Affection = {
			Enabled = true,
			Chance = 0.1,
			IntervalSeconds = 5,
			DurationSeconds = 4,
			JumpCount = 8,
			Texts = {
				"😆",
				"😄",
				"😁",
				"😃",
				"🤪",
				"😝",
				"😜",
				"😋",
				"😹",
				"🙀",
				"😎"
			}
		}
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function freezeTable(list)
	if list ~= nil and not table.isfrozen(list) then
		table.freeze(list)
	end
end

for _, v5 in configs do
	freezeTable(v5.Movement.Retreat) -- equivalent call inferred; original call site unknown
	freezeTable(v5.Movement.IdleTremble) -- equivalent call inferred; original call site unknown
	freezeTable(v5.Movement) -- equivalent call inferred; original call site unknown
	freezeTable(v5.Greeting.Texts) -- equivalent call inferred; original call site unknown
	freezeTable(v5.Greeting) -- equivalent call inferred; original call site unknown
	freezeTable(v5.Affection.Texts) -- equivalent call inferred; original call site unknown
	freezeTable(v5.Affection) -- equivalent call inferred; original call site unknown
	freezeTable(v5) -- equivalent call inferred; original call site unknown
end

freezeTable(configs) -- equivalent call inferred; original call site unknown
local frozen2 = table.freeze({
	{
		Personality = frozen.Normal,
		Weight = configs[frozen.Normal].RollWeight
	},
	{
		Personality = frozen.Lazy,
		Weight = configs[frozen.Lazy].RollWeight
	},
	{
		Personality = frozen.Loyal,
		Weight = configs[frozen.Loyal].RollWeight
	},
	{
		Personality = frozen.Energetic,
		Weight = configs[frozen.Energetic].RollWeight
	},
	{
		Personality = frozen.InvertedModel,
		Weight = configs[frozen.InvertedModel].RollWeight
	},
	{
		Personality = frozen.Shy,
		Weight = configs[frozen.Shy].RollWeight
	},
	{
		Personality = frozen.Scared,
		Weight = configs[frozen.Scared].RollWeight
	},
	{
		Personality = frozen.ExtremelyEnergetic,
		Weight = configs[frozen.ExtremelyEnergetic].RollWeight
	},
	{
		Personality = frozen.UltraLoyal,
		Weight = configs[frozen.UltraLoyal].RollWeight
	},
	{
		Personality = frozen.JumpCrazy,
		Weight = configs[frozen.JumpCrazy].RollWeight
	}
})
local frozen3 = table.freeze({
	{ frozen.Normal, configs[frozen.Normal].RollWeight },
	{ frozen.Lazy, configs[frozen.Lazy].RollWeight },
	{ frozen.Loyal, configs[frozen.Loyal].RollWeight },
	{ frozen.Energetic, configs[frozen.Energetic].RollWeight },
	{ frozen.InvertedModel, configs[frozen.InvertedModel].RollWeight },
	{ frozen.Shy, configs[frozen.Shy].RollWeight },
	{ frozen.Scared, configs[frozen.Scared].RollWeight },
	{ frozen.ExtremelyEnergetic, configs[frozen.ExtremelyEnergetic].RollWeight },
	{ frozen.UltraLoyal, configs[frozen.UltraLoyal].RollWeight },
	{ frozen.JumpCrazy, configs[frozen.JumpCrazy].RollWeight }
})

for _, v5 in frozen2 do
	freezeTable(v5) -- equivalent call inferred; original call site unknown
end

for _, v5 in frozen3 do
	freezeTable(v5) -- equivalent call inferred; original call site unknown
end

local v5 = {
	Personalities = frozen,
	Configs = configs,
	RollTable = frozen2,
	IsPersonality = function(value)
		return typeof(value) == "string" and configs[value] ~= nil
	end,
	GetConfig = function(p: string?)
		return configs[p] or configs[frozen.Normal]
	end
}

function v5.Roll(p)
	local v6 = rollWeighted(frozen3, p)
	local v7

	if typeof(v6) == "string" then
		v7 = v5.IsPersonality(v6)
	else
		v7 = false
	end

	assert(v7, "Asset personality roll failed")
	return v6
end

function v5.CreateNewItemData(p)
	local clone = table.clone(p)
	clone.Mutations = table.clone(p.Mutations)

	if not v5.IsPersonality(clone.Personality) then
		clone.Personality = v5.Roll()
	end

	clone.HasBeenFirstPlaced = false
	return clone
end

function v5.ResetFirstPlacementForTransfer(p)
	local clone = table.clone(p)
	clone.Mutations = table.clone(p.Mutations)
	clone.HasBeenFirstPlaced = false
	return clone
end

return table.freeze(v5)