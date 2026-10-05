local module = require("@self/lib")
local module2 = require("@self/slop")
local module3 = require("./EventConfig")
local v = {}

local function setEvent(p)
	v = p
end

local function quest(p)
	for k, v2 in v do
		if p[k] == nil then
			p[k] = v2
		end
	end

	return p
end

v = {
	Icon = "rbxassetid://18162767851",
	IconColor = Color3.fromRGB(25, 85, 149)
}
local SimpleFetchQuests = {
	_ = nil
}
local diverBilly = {
	QuestName = "Tidefall: Diver Billy",
	Location = "Collapsed Ruins",
	Objectives = { module.CatchFishAny({
			Fish = "Bigeye Houndshark",
			RequiredAttributes = {
				Mutation = "Mastered"
			},
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Tide Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = {
		"Been trying to improve my angling skills...",
		"But I kinda just gave up. Yet my mentor still expects me to show progress.",
		"Could you bring me a Mastered Bigeye Houndshark that I can show him?"
	},
	InProgressDialog = { "Did you get the Mastered Bigeye Houndshark?" },
	PostCompleteDialog = { module2.CollapsedRuins }
}

for k, v3 in v do
	if diverBilly[k] == nil then
		diverBilly[k] = v3
	end
end

SimpleFetchQuests["Diver Billy"] = diverBilly
local diverJimmy = {
	QuestName = "Tidefall: Diver Jimmy",
	Location = "Collapsed Ruins",
	Objectives = { module.CatchFishAny({
			Fish = "Black Scabbardfish",
			RequiredAmount = 3,
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Thalass Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = { "Could you catch and bring me some Black Scabbardfish? No particular reason." },
	InProgressDialog = { "Did you get the Black Scabbardfish?" },
	PostCompleteDialog = { module2.CollapsedRuins }
}

for k, v4 in v do
	if diverJimmy[k] == nil then
		diverJimmy[k] = v4
	end
end

SimpleFetchQuests["Diver Jimmy"] = diverJimmy
local diverTimmy = {
	QuestName = "Tidefall: Diver Timmy",
	Location = "Collapsed Ruins",
	Objectives = { module.CatchFishAny({
			Fish = "Pliosaur",
			RequiredAmount = 1
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Tide Essence",
			{},
			1
		},
		{ "Xp", 100000 }
	},
	InitialDialog = {
		"I don't believe the Pliosaur even exists!",
		"I've been trying to get one for <i>hours</i>...",
		"Please, could you try and catch one?",
		"You don't have to give it to me... I just want to make sure it's even real..."
	},
	InProgressDialog = { "Did you find a Pliosaur?" },
	PostCompleteDialog = { module2.CollapsedRuins }
}

for k, v5 in v do
	if diverTimmy[k] == nil then
		diverTimmy[k] = v5
	end
end

SimpleFetchQuests["Diver Timmy"] = diverTimmy
local diverTommy = {
	QuestName = "Tidefall: Diver Tommy",
	Location = "Collapsed Ruins",
	Objectives = { module.CatchFishAny({
			Fish = "Roughhead Grenadier",
			RequiredAmount = 2,
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Tide Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = { "Hey, could you catch 2 Roughhead Grenadiers for me? Preferably with Crab Cages..." },
	InProgressDialog = { "Did you catch the Roughhead Grenadiers?" },
	PostCompleteDialog = { module2.CollapsedRuins }
}

for k, v6 in v do
	if diverTommy[k] == nil then
		diverTommy[k] = v6
	end
end

SimpleFetchQuests["Diver Tommy"] = diverTommy
local diverSammy = {
	QuestName = "Tidefall: Diver Sammy",
	Location = "Collapsed Ruins",
	Objectives = { module.CatchFishAny({
			Fish = "Longnose Chimaera",
			RequiredAmount = 3,
			AndReturn = true
		}), module.CatchFishAny({
			Fish = "Shortnose Chimaera",
			RequiredAmount = 2,
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Tide Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = { "I love collecting Chimaeras of varying nose lengths! Could you catch some for me?" },
	InProgressDialog = { "Did you get the Chimaeras?" },
	PostCompleteDialog = { module2.CollapsedRuins }
}

for k, v7 in v do
	if diverSammy[k] == nil then
		diverSammy[k] = v7
	end
end

SimpleFetchQuests["Diver Sammy"] = diverSammy
local diverJohnny = {
	QuestName = "Tidefall: Diver Johnny",
	Location = "Coral Bastion",
	Objectives = { module.CatchFishAny({
			Fish = "Batfish",
			RequiredAmount = 1,
			AndReturn = true
		}), module.CatchFishAny({
			Fish = "Lizardfish",
			RequiredAmount = 1,
			AndReturn = true
		}), module.CatchFishAny({
			Fish = "Scorpionfish",
			RequiredAmount = 1,
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Tide Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = { "🦇🦎🦂?" },
	AcceptOption = "✅",
	DeclineOption = "❌",
	AcceptDialog = { "🦇🦎🦂!!" },
	InProgressDialog = { "🦇🦎🦂? ✅?" },
	GiveOption = "✅",
	CancelOption = "❌",
	CompleteDialog = { "🦇🦎🦂!! ❤️" },
	IncompleteDialog = { "🦇🦎🦂... 💔" },
	PostCompleteDialog = { "❤️" }
}

for k, v8 in v do
	if diverJohnny[k] == nil then
		diverJohnny[k] = v8
	end
end

SimpleFetchQuests["Diver Johnny"] = diverJohnny
local diverDanny = {
	QuestName = "Tidefall: Diver Danny",
	Location = "Coral Bastion",
	Objectives = { module.CatchFishAny({
			Fish = "Emperor Angelfish",
			RequiredAmount = 5,
			RequiredAttributes = {
				Mutation = "Heavenly"
			},
			AndReturn = true
		}), module.CatchFishAny({
			Fish = "Regal Angelfish",
			RequiredAmount = 5,
			RequiredAttributes = {
				Mutation = "Blessed"
			},
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Tide Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = { "I love the divine. Could you fetch me some divine Angelfish?" },
	InProgressDialog = { "Did you get the divine Angelfish?" },
	PostCompleteDialog = { module2.CoralBastion }
}

for k, v9 in v do
	if diverDanny[k] == nil then
		diverDanny[k] = v9
	end
end

SimpleFetchQuests["Diver Danny"] = diverDanny
local diverBobby = {
	QuestName = "Tidefall: Diver Bobby",
	Location = "Coral Bastion",
	Objectives = { module.CatchFishAny({
			Fish = "Reef Titan",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Coral"
			}
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Tide Essence",
			{},
			1
		},
		{ "Xp", 100000 }
	},
	InitialDialog = { "Coral Reef Titan. Can you do it?", "I dont need the fish. I just need to see you catch it." },
	InProgressDialog = { "Did you get the Coral Reef Titan?" },
	PostCompleteDialog = { module2.CoralBastion }
}

for k, v10 in v do
	if diverBobby[k] == nil then
		diverBobby[k] = v10
	end
end

SimpleFetchQuests["Diver Bobby"] = diverBobby
local diverRonnie = {
	QuestName = "Tidefall: Diver Ronnie",
	Location = "Coral Bastion",
	Objectives = { module.CatchFishAny({
			Fish = "Sand Tiger Shark",
			RequiredAmount = 3,
			RequiredAttributes = {
				Mutation = "Sandy"
			},
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Tide Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = { "mmmmmmmm sand", "can i get a Sandy Sand Tiger Shark?", "im hungry" },
	InProgressDialog = { "Did you get the Sandy Sand Tiger Shark?" },
	PostCompleteDialog = { module2.CoralBastion }
}

for k, v11 in v do
	if diverRonnie[k] == nil then
		diverRonnie[k] = v11
	end
end

SimpleFetchQuests["Diver Ronnie"] = diverRonnie
local diverSonny = {
	QuestName = "Tidefall: Diver Sonny",
	Location = "Coral Bastion",
	Objectives = { module.CatchFishAny({
			Fish = "Atlantic Goliath Grouper",
			RequiredAmount = 3,
			RequiredAttributes = {
				Mutation = "Atlantean"
			},
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Tide Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = { "Atlantean Atlantic Goliath Grouper. Sound doable?" },
	InProgressDialog = { "Did you get the Atlantean Atlantic Goliath Grouper?" },
	PostCompleteDialog = { module2.CoralBastion }
}

for k, v12 in v do
	if diverSonny[k] == nil then
		diverSonny[k] = v12
	end
end

SimpleFetchQuests["Diver Sonny"] = diverSonny
local diverBenny = {
	QuestName = "Tidefall: Diver Benny",
	Location = "Coral Bastion",
	Objectives = { module.CatchFishAny({
			Fish = "Emperor Angelfish",
			RequiredAmount = 5,
			RequiredAttributes = {
				Mutation = "Scorched"
			},
			AndReturn = true
		}), module.CatchFishAny({
			Fish = "Regal Angelfish",
			RequiredAmount = 5,
			RequiredAttributes = {
				Mutation = "Exploded"
			},
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Tide Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = { "I HATE the divine. Could you SCORCH and EXPLODE some angelfish for me?" },
	InProgressDialog = { "Did you SCORCH and EXPLODE those angelfish?" },
	PostCompleteDialog = { module2.CoralBastion }
}

for k, v13 in v do
	if diverBenny[k] == nil then
		diverBenny[k] = v13
	end
end

SimpleFetchQuests["Diver Benny"] = diverBenny
local diverLenny = {
	QuestName = "Tidefall: Diver Lenny",
	Location = "Coral Bastion",
	Objectives = { module.CatchFishAny({
			Fish = "Whale Shark",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Coral"
			},
			AndReturn = true
		}), module.CatchFishAny({
			Fish = "Great White Shark",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Coral"
			},
			AndReturn = true
		}), module.CatchFishAny({
			Fish = "Great Hammerhead Shark",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Coral"
			},
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Thalass Essence",
			{},
			1
		},
		{
			"ItemOrFish",
			"Shark Whistle",
			{},
			3
		},
		{ "Xp", 50000 }
	},
	InitialDialog = {
		"So I have this friend on the surface who likes collecting sharks with different Mutations...",
		"Could you help out catching some sharks with the Coral mutation?"
	},
	InProgressDialog = { "Did you get those Coral sharks?" },
	PostCompleteDialog = { module2.CoralBastion }
}

for k, v14 in v do
	if diverLenny[k] == nil then
		diverLenny[k] = v14
	end
end

SimpleFetchQuests["Diver Lenny"] = diverLenny
local diverKenny = {
	QuestName = "Tidefall: Diver Kenny",
	Location = "Crowned Ruins",
	Objectives = { module.CatchFishAny({
			Fish = "Small-Spotted Catshark",
			RequiredAmount = 10,
			AndReturn = true
		}), module.CatchFishAny({
			Fish = "Blackmouth Catshark",
			RequiredAmount = 10,
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Thalass Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = { "I love cats... and I love sharks...", "Please! Bring me some Catsharks!" },
	InProgressDialog = { "Did you get the Catsharks?" },
	PostCompleteDialog = { module2.CrownedRuins }
}

for k, v15 in v do
	if diverKenny[k] == nil then
		diverKenny[k] = v15
	end
end

SimpleFetchQuests["Diver Kenny"] = diverKenny
local diverMikey = {
	QuestName = "Tidefall: Diver Mikey",
	Location = "Crowned Ruins",
	Objectives = { module.CatchFishAny({
			Fish = "Warty Oreo",
			RequiredAmount = 5,
			RequiredAttributes = {
				Mutation = "Withered"
			},
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Thalass Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = { "\"Warty Oreo\"... I don't like how that sounds. Please Wither it." },
	AcceptOption = "what",
	InProgressDialog = { "Are they Withered?" },
	PostCompleteDialog = { module2.CrownedRuins }
}

for k, v16 in v do
	if diverMikey[k] == nil then
		diverMikey[k] = v16
	end
end

SimpleFetchQuests["Diver Mikey"] = diverMikey
local diverRicky = {
	QuestName = "Tidefall: Diver Ricky",
	Location = "Crowned Ruins",
	Objectives = { module.CatchFishAny({
			Fish = "Silver Roughy",
			RequiredAmount = 3,
			RequiredAttributes = {
				Mutation = "Silver"
			},
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Thalass Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = { "I like Silver things. Could you catch some Silver Roughy with the Silver mutation?" },
	InProgressDialog = { "Did you get the Silver Silver Roughy?" },
	PostCompleteDialog = { module2.CrownedRuins }
}

for k, v17 in v do
	if diverRicky[k] == nil then
		diverRicky[k] = v17
	end
end

SimpleFetchQuests["Diver Ricky"] = diverRicky
local diverJoey = {
	QuestName = "Tidefall: Diver Joey",
	Location = "Crowned Ruins",
	Objectives = { module.CatchFishAny({
			Fish = "Goldwraith",
			RequiredAmount = 1
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Thalass Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = {
		"The Goldwraith here threatened my family.",
		"Could you... deal with it?",
		"I don't need it myself. I just want it gone."
	},
	InProgressDialog = { "Is it gone?" },
	PostCompleteDialog = { module2.SunkenReliquary }
}

for k, v18 in v do
	if diverJoey[k] == nil then
		diverJoey[k] = v18
	end
end

SimpleFetchQuests["Diver Joey"] = diverJoey
local diverNicky = {
	QuestName = "Tidefall: Diver Nicky",
	Location = "Sunken Reliquary",
	Objectives = { module.CatchFishAny({
			Fish = "Captain's Goldfish",
			RequiredAmount = 10,
			RequiredAttributes = {
				Mutation = "Aurora"
			},
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Thalass Essence",
			{},
			1
		},
		{
			"ItemOrFish",
			"Pirate Captain's Goldfish",
			{
				Shiny = true,
				Mutation = "Unsellable",
				Weight = 1.5
			},
			1
		},
		{ "Xp", 50000 }
	},
	InitialDialog = { "Forget about this place. Return to tradition.", "Catch me 10 Aurora Captain's Goldfish." },
	InProgressDialog = { "Did you get the Aurora Captain's Goldfish?" },
	PostCompleteDialog = { module2.SunkenReliquary }
}

for k, v19 in v do
	if diverNicky[k] == nil then
		diverNicky[k] = v19
	end
end

SimpleFetchQuests["Diver Nicky"] = diverNicky
local diverCorey = {
	QuestName = "Tidefall: Diver Corey",
	Location = "Sunken Reliquary",
	Objectives = { module.CatchFishAny({
			Fish = "John Dory",
			RequiredAmount = 20,
			RequiredAttributes = {
				Mutation = "Aurora"
			},
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Thalass Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = { "What on earth is a John Dory.", "That's a pretty funny name.", "I want 20 of them." },
	InProgressDialog = { "Did you get the John Dory?" },
	PostCompleteDialog = { module2.SunkenReliquary }
}

for k, v20 in v do
	if diverCorey[k] == nil then
		diverCorey[k] = v20
	end
end

SimpleFetchQuests["Diver Corey"] = diverCorey
local diverTony = {
	QuestName = "Tidefall: Diver Tony",
	Location = "Sunken Reliquary",
	Objectives = { module.CatchFishAny({
			Fish = "Cusk Eel",
			RequiredAmount = 5,
			RequiredAttributes = {
				Mutation = "Forgotten"
			},
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Thalass Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = { "I forgot about my Cusk Eels.", "Please find them." },
	InProgressDialog = { "Did you find my Forgotten Cusk Eels?" },
	PostCompleteDialog = { module2.SunkenReliquary }
}

for k, v21 in v do
	if diverTony[k] == nil then
		diverTony[k] = v21
	end
end

SimpleFetchQuests["Diver Tony"] = diverTony
local diverJim = {
	QuestName = "Tidefall: Diver Jim",
	Location = "Sunken Reliquary",
	Objectives = { module.CatchFishAny({
			Fish = "Oilfish",
			RequiredAmount = 10,
			RequiredAttributes = {
				Shiny = true
			},
			AndReturn = true
		}), module.CatchFishAny({
			Fish = "Oil Sardine",
			RequiredAmount = 10,
			RequiredAttributes = {
				Sparkling = true
			},
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Thalass Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = {
		"My whole family was crushed by this pillar...",
		"Even my long lost brother, Shiny Sparkling Mastered Him...",
		"What's that look for? That was his name.",
		"Anyways, can I get some Shiny Oilfish and Sparkling Oil Sardines?"
	},
	AcceptOption = "Whatever man.",
	InProgressDialog = { "Did you find my oil?" },
	PostCompleteDialog = { module2.SunkenReliquary }
}

for k, v22 in v do
	if diverJim[k] == nil then
		diverJim[k] = v22
	end
end

SimpleFetchQuests["Diver Jim"] = diverJim
local diverManny = {
	QuestName = "Tidefall: Diver Manny",
	Location = "Sunken Reliquary",
	Objectives = { module.CatchFishAny({
			Fish = "Porcupinefish",
			RequiredAmount = 10,
			RequiredAttributes = {
				Mutation = "Nova"
			},
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Thalass Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = { "Nova Porcupinefish or something I guess." },
	AcceptOption = "Whatever man.",
	InProgressDialog = { "Did you get the Nova Porcupinefish?" },
	PostCompleteDialog = { module2.SunkenReliquary }
}

for k, v23 in v do
	if diverManny[k] == nil then
		diverManny[k] = v23
	end
end

SimpleFetchQuests["Diver Manny"] = diverManny
local diverFrankie = {
	QuestName = "Tidefall: Diver Frankie",
	Location = "Sunken Reliquary",
	Objectives = { module.CatchFishAny({
			Fish = "Escolar",
			RequiredAmount = 5,
			RequiredAttributes = {
				Shiny = true
			},
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Thalass Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = { "I wonder what a Shiny Escolar looks like...", "Could you catch some for me?" },
	InProgressDialog = { "Did you get the Shiny Escolar?" },
	PostCompleteDialog = { module2.SunkenReliquary }
}

for k, v24 in v do
	if diverFrankie[k] == nil then
		diverFrankie[k] = v24
	end
end

SimpleFetchQuests["Diver Frankie"] = diverFrankie
local diverEddie = {
	QuestName = "Tidefall: Diver Eddie",
	Location = "Sunken Reliquary",
	Objectives = { module.CatchFishCage({
			Fish = "Rock",
			RequiredAmount = 100,
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Tide Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = {
		"Hmm... seems like you're getting quite a lot of Rocks with those Crab Cages.",
		"Think you could get some more for me?"
	},
	AcceptOption = "...Fine.",
	InProgressDialog = { "Did you get the Rocks?" },
	PostCompleteDialog = { module2.SunkenReliquary }
}

for k, v25 in v do
	if diverEddie[k] == nil then
		diverEddie[k] = v25
	end
end

SimpleFetchQuests["Diver Eddie"] = diverEddie
local diverFreddie = {
	QuestName = "Tidefall: Diver Freddie",
	Location = "Tidefall",
	Objectives = { module.CatchFishAny({
			Fish = "Dripstone",
			RequiredAmount = 2,
			RequiredAttributes = {
				Mutation = "Spirit"
			},
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Tide Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = {
		"This Obelisk said something about spirits and dripstone...",
		"Could you fetch me some Spirit Dripstones for it?"
	},
	InProgressDialog = { "Did you get the Spirit Dripstone?" },
	PostCompleteDialog = { module2.Tidefall }
}

for k, v26 in v do
	if diverFreddie[k] == nil then
		diverFreddie[k] = v26
	end
end

SimpleFetchQuests["Diver Freddie"] = diverFreddie
local diverTeddy = {
	QuestName = "Tidefall: Diver Teddy",
	Location = "Tidefall",
	Objectives = { module.CatchFishCage({
			Fish = "Anchor",
			RequiredAmount = 1,
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Tide Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = {
		"Man... I am absolutely stacked from everyone buying my totems.",
		"I just bought a sick new cruise ship, but I need an anchor for it...",
		"Could you catch one for me?"
	},
	InProgressDialog = { "Did you get the Anchor?" },
	PostCompleteDialog = { module2.Tidefall }
}

for k, v27 in v do
	if diverTeddy[k] == nil then
		diverTeddy[k] = v27
	end
end

SimpleFetchQuests["Diver Teddy"] = diverTeddy
local diverBuddy = {
	QuestName = "Tidefall: Diver Buddy",
	Location = "Tidefall",
	Objectives = { module.CatchFishAny({
			Fish = { "Plesiosaur", "Pliosaur" },
			RequiredAmount = 1
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Requis Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = {
		"I can't remember whether the fish here is called Plesiosaur or Pliosaur...",
		"Could you catch one of them for me to figure it out?",
		"You can keep the fish, of course."
	},
	InProgressDialog = { "Did you figure it out?" },
	PostCompleteDialog = { module2.Tidefall }
}

for k, v28 in v do
	if diverBuddy[k] == nil then
		diverBuddy[k] = v28
	end
end

SimpleFetchQuests["Diver Buddy"] = diverBuddy
local diverRudy = {
	QuestName = "Tidefall: Diver Rudy",
	Location = "Tidefall",
	Objectives = { module.CatchFishAny({
			Fish = "Dripstone",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Fallen"
			},
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Requis Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = {
		"I can't get these Dripstones to fall...",
		"Do you think you could catch a Fallen Dripstone for me?"
	},
	InProgressDialog = { "Did you get the Fallen Dripstone?" },
	PostCompleteDialog = { module2.Tidefall }
}

for k, v29 in v do
	if diverRudy[k] == nil then
		diverRudy[k] = v29
	end
end

SimpleFetchQuests["Diver Rudy"] = diverRudy
local diverPercy = {
	QuestName = "Tidefall: Diver Percy",
	Location = "Tidefall",
	Objectives = { module.CatchFishAny({
			Fish = "Moray Eel",
			RequiredAmount = 25,
			RequiredAttributes = {
				Mutation = "Coral"
			},
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Requis Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = { "I gotta convince more people to use the Coral Spear.", "Could you catch me 25 Coral Moray Eel?" },
	InProgressDialog = { "Did you get the Coral Moray Eel?" },
	PostCompleteDialog = { module2.Tidefall }
}

for k, v30 in v do
	if diverPercy[k] == nil then
		diverPercy[k] = v30
	end
end

SimpleFetchQuests["Diver Percy"] = diverPercy
local diverPerry = {
	QuestName = "Tidefall: Diver Perry",
	Location = "Tidefall",
	Objectives = { module.CatchFishAny({
			Fish = "Moray Eel",
			RequiredAmount = 10,
			RequiredAttributes = {
				Mutation = "Royal"
			},
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Requis Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = { "I gotta convince more people to use the Royal Spear.", "Could you catch me 10 Royal Moray Eel?" },
	InProgressDialog = { "Did you get the Royal Moray Eel?" },
	PostCompleteDialog = { module2.Tidefall }
}

for k, v31 in v do
	if diverPerry[k] == nil then
		diverPerry[k] = v31
	end
end

SimpleFetchQuests["Diver Perry"] = diverPerry
local diverJerry = {
	QuestName = "Jerry",
	Location = "Tidefall",
	Objectives = { module.CatchFishCage({
			Fish = "Stalactite",
			RequiredAmount = 100
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Requis Essence",
			{},
			1
		},
		{ "Xp", 100000 }
	},
	InitialDialog = { "Jerry." },
	AcceptOption = "Jerry.",
	DeclineOption = "Jerry.",
	AcceptDialog = { "Jerry." },
	InProgressDialog = { "Jerry." },
	GiveOption = "Jerry.",
	CancelOption = "Jerry.",
	CompleteDialog = { "Jerry." },
	IncompleteDialog = { "Jerry." },
	PostCompleteDialog = { "Jerry." }
}

for k, v32 in v do
	if diverJerry[k] == nil then
		diverJerry[k] = v32
	end
end

SimpleFetchQuests["Diver Jerry"] = diverJerry
local diverTerry = {
	QuestName = "Tidefall: Diver Terry",
	Location = "Tidefall",
	Objectives = { module.CatchFish({
			Fish = "Scylla",
			RequiredAmount = 1,
			Rods = { "Requiem" },
			PerfectCatch = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Requis Essence",
			{},
			1
		},
		{ "Xp", 100000 }
	},
	InitialDialog = { "Think you can Perfect Catch a Scylla with Requiem?" },
	InProgressDialog = { "Did you pull it off?" },
	PostCompleteDialog = { module2.Tidefall }
}

for k, v33 in v do
	if diverTerry[k] == nil then
		diverTerry[k] = v33
	end
end

SimpleFetchQuests["Diver Terry"] = diverTerry
local diverLarry = {
	QuestName = "Tidefall: Diver Larry",
	Location = "Tidefall",
	Objectives = { module.CatchFish({
			Fish = "Leviathan",
			RequiredAmount = 1,
			Rods = { "Tidemourner" },
			PerfectCatch = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Requis Essence",
			{},
			1
		},
		{ "Xp", 100000 }
	},
	InitialDialog = { "Think you can Perfect Catch a Leviathan with Tidemourner?" },
	InProgressDialog = { "Did you pull it off?" },
	PostCompleteDialog = { module2.Tidefall }
}

for k, v34 in v do
	if diverLarry[k] == nil then
		diverLarry[k] = v34
	end
end

SimpleFetchQuests["Diver Larry"] = diverLarry
local diverBarry = {
	QuestName = "Tidefall: Diver Barry",
	Location = "Tidefall",
	Objectives = { module.CatchFish({
			Fish = { "Megalodon", "Ancient Megalodon", "Phantom Megalodon" },
			RequiredAmount = 1,
			Rods = { "Coral Rod" },
			PerfectCatch = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Requis Essence",
			{},
			1
		},
		{ "Xp", 100000 }
	},
	InitialDialog = { "Think you can Perfect Catch catch a Megalodon with Coral Rod?" },
	InProgressDialog = { "Did you pull it off?" },
	PostCompleteDialog = { module2.Tidefall }
}

for k, v35 in v do
	if diverBarry[k] == nil then
		diverBarry[k] = v35
	end
end

SimpleFetchQuests["Diver Barry"] = diverBarry
local diverGary = {
	QuestName = "Tidefall: Diver Gary",
	Location = "Tidefall",
	Objectives = { module.CatchFishAny({
			Fish = "Bumpy Snailfish",
			RequiredAmount = 25,
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Requis Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = { "I feel a strong connection with the \"Bumpy Snailfish\". Could you catch some for me?" },
	InProgressDialog = { "Did you get the Bumpy Snailfish?" },
	PostCompleteDialog = { module2.Tidefall }
}

for k, v36 in v do
	if diverGary[k] == nil then
		diverGary[k] = v36
	end
end

SimpleFetchQuests["Diver Gary"] = diverGary
local diverHenry = {
	QuestName = "Tidefall: Diver Henry",
	Location = "Tidefall",
	Objectives = { module.CatchFishAny({
			Fish = "Rock",
			RequiredAmount = 15,
			RequiredAttributes = {
				Mutation = "Rusty"
			},
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Requis Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = { "I want some Rusty Rocks. Don't ask why." },
	InProgressDialog = { "Did you get the Rusty Rocks?" },
	PostCompleteDialog = { module2.Tidefall }
}

for k, v37 in v do
	if diverHenry[k] == nil then
		diverHenry[k] = v37
	end
end

SimpleFetchQuests["Diver Henry"] = diverHenry
local diverWesley = {
	QuestName = "Tidefall: Diver Wesley",
	Location = "Tidefall",
	Objectives = { module.CatchFishAny({
			Fish = "Gnomefish",
			RequiredAmount = 30,
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Requis Essence",
			{},
			1
		},
		{ "Xp", 25000 }
	},
	InitialDialog = { "I want to gnome my friends. Could you catch me 30 Gnomefish?" },
	InProgressDialog = { "Did you get the Gnomefish?" },
	PostCompleteDialog = { module2.Tidefall }
}

for k, v38 in v do
	if diverWesley[k] == nil then
		diverWesley[k] = v38
	end
end

SimpleFetchQuests["Diver Wesley"] = diverWesley
v = {
	Icon = "rbxassetid://70822794044383",
	IconColor = Color3.fromRGB(255, 34, 133),
	ExpiresAt = module3.Valentides26.ExpiresAt
}
SimpleFetchQuests._ = nil
local seraphine = {
	QuestName = "Valentides 2026: Seraphine",
	Location = "Sweetheart Shores",
	Objectives = { module.CatchFishAny({
			Fish = "Dove",
			RequiredAmount = 5,
			RequiredAttributes = {
				Mutation = "Heavenly"
			},
			AndReturn = true
		}), module.ObtainItem({
			Item = "Dove",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Blessed"
			},
			ForNpc = "Seraphine"
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Cupid Relic",
			{
				Weight = 15,
				Mutation = "Blessed"
			},
			1
		},
		{ "LocalCurrency", "Chocolates", 250 },
		{ "Xp", 25000 }
	},
	InitialDialog = {
		"Be not afraid.",
		"We visit this realm only to reclaim a lost creature of the heavens.",
		(`Benevolent soul, could you help us find 5 <b>{module.mutationDisplay("Heavenly")} Doves</b> and 1 <b>{module.mutationDisplay("Blessed")} Dove</b>?`)
	},
	AcceptOption = "I-I'll see what I can do...",
	DeclineOption = "Uhh... Maybe later...",
	AcceptDialog = { "Thank you." },
	InProgressDialog = { "Have you found the lost Doves?" },
	GiveOption = "Here you go...",
	CancelOption = "Not yet...",
	CompleteDialog = {
		"Your good deed shall not go unrewarded.",
		"Take this divine relic, its power attuned to the season, and use it as you wish."
	},
	DeclineDialog = {
		"You need not rush.",
		"For one older than the soil you stand upon, this has been merely a brief moment."
	},
	IncompleteDialog = {
		"You have not yet fulfilled the full extent of our request.",
		"You need not rush.",
		"For one older than the soil you stand upon, this has been merely a brief moment."
	},
	PostCompleteDialog = { "The heavens shall not forget your selfless deeds." }
}

for k, v39 in v do
	if seraphine[k] == nil then
		seraphine[k] = v39
	end
end

SimpleFetchQuests.Seraphine = seraphine
local ethan = {
	QuestName = "Valentides 2026: Ethan",
	Location = "Sweetheart Shores",
	Objectives = { module.ObtainItem({
			Item = "Rose Bouquet",
			RequiredAmount = 3,
			RequiredAttributes = {
				WeightClass = "Giant"
			},
			ForNpc = "Ethan"
		}) },
	Rewards = {
		{ "Bait", "Fischversation Hearts", 10 },
		{ "LocalCurrency", "Chocolates", 250 },
		{ "Xp", 25000 }
	},
	InitialDialog = {
		"Psst, hey... my girl got me this huuuge bouquet, but uhh...",
		"...I kinda lost it...",
		"Please! You've gotta find me a new one!"
	},
	AcceptOption = "...Sure, I guess?",
	DeclineOption = "Good luck with that...",
	AcceptDialog = { "THANK YOU!!! I'm... gonna go back to hiding now..." },
	InProgressDialog = { "Did you get it?" },
	GiveOption = "Here you go... Just don't lose it again.",
	CancelOption = "Not yet...",
	CompleteDialog = {
		"Wow!! This is even bigger than the one she got me!",
		"Uhh... don't tell her I said that...",
		"Oh, wait... what if she notices...",
		"..."
	},
	DeclineDialog = { "Please, %DISPLAYNAME%, I need this..." },
	PostCompleteDialog = { "Surely she won't notice, right?" }
}

for k, v40 in v do
	if ethan[k] == nil then
		ethan[k] = v40
	end
end

SimpleFetchQuests.Ethan = ethan
local anna = {
	QuestName = "Valentides 2026: Anna",
	Location = "Sweetheart Shores",
	Objectives = { module.ObtainItem({
			Item = "Roseveil Koi",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Candy"
			},
			ForNpc = "Anna"
		}), module.ObtainItem({
			Item = "Pink Betta",
			RequiredAmount = 3,
			RequiredAttributes = {
				Mutation = "Candy"
			},
			ForNpc = "Anna"
		}), module.ObtainItem({
			Item = "Heartbreak Herring",
			RequiredAmount = 3,
			RequiredAttributes = {
				Mutation = "Candy"
			},
			ForNpc = "Anna"
		}) },
	Rewards = {
		{ "LocalCurrency", "Chocolates", 350 },
		{ "Xp", 35000 }
	},
	InitialDialog = {
		"Did you know that the power of <b>Fischversation Hearts</b> can turn <i>anything</i> into candy?",
		"I really wanna see what some of the fish here taste like... as candy!",
		(`Could you catch a <b>Roseveil Koi</b>, <b>Pink Betta</b>, and <b>Heartbreak Herring</b> with the {module.mutationDisplay("Candy")} Mutation?`)
	},
	AcceptOption = "Sure.",
	DeclineOption = "Maybe later...",
	AcceptDialog = { "Thanks!! Let me know once you got them all!" },
	InProgressDialog = { "Did you get my candy?" },
	GiveOption = "Here you go!",
	CancelOption = "Not yet...",
	CompleteDialog = { "Wow! Thank you!! These taste...", "...uh...", "These taste like fish." },
	DeclineDialog = { "Alright, no worries!" },
	PostCompleteDialog = { "I don't know what I expected..." }
}

for k, v41 in v do
	if anna[k] == nil then
		anna[k] = v41
	end
end

SimpleFetchQuests.Anna = anna
local dove = {
	QuestName = "Valentides 2026: \"Dove\"",
	Location = "Sweetheart Shores",
	Objectives = {
		module.ObtainItem({
			Item = "Rock",
			RequiredAmount = 20,
			RequiredAttributes = {
				Mutation = "Sweet"
			},
			ForNpc = "\"Dove\""
		}),
		module.ObtainItem({
			Item = "Rock",
			RequiredAmount = 20,
			RequiredAttributes = {
				Mutation = "Lovely"
			},
			ForNpc = "\"Dove\""
		}),
		module.ObtainItem({
			Item = "Rock",
			RequiredAmount = 20,
			RequiredAttributes = {
				Mutation = "Candy"
			},
			ForNpc = "\"Dove\""
		}),
		module.ObtainItem({
			Item = "Rock",
			RequiredAmount = 10,
			RequiredAttributes = {
				Mutation = "Rose"
			},
			ForNpc = "\"Dove\""
		}),
		module.ObtainItem({
			Item = "Rock",
			RequiredAmount = 10,
			RequiredAttributes = {
				Mutation = "Embraced"
			},
			ForNpc = "\"Dove\""
		}),
		module.ObtainItem({
			Item = "Rock",
			RequiredAmount = 20,
			RequiredAttributes = {
				Mutation = "Lovestruck"
			},
			ForNpc = "\"Dove\""
		}),
		module.ObtainItem({
			Item = "Rock",
			RequiredAmount = 10,
			RequiredAttributes = {
				Mutation = "Heartburst"
			},
			ForNpc = "\"Dove\""
		}),
		module.ObtainItem({
			Item = "Rose Rockfish",
			RequiredAmount = 10,
			ForNpc = "\"Dove\""
		})
	},
	Rewards = {
		{ "Skin", "Dove Rod" },
		{
			"ItemOrFish",
			"Valentine's Relic",
			{
				Weight = 35,
				Mutation = "Unsellable"
			},
			1
		},
		{ "LocalCurrency", "Chocolates", 2500 },
		{ "Xp", 100000 }
	},
	InitialDialog = {
		"STONE STONE STONE!",
		"ME LOVE ROCKS! WANT LOVELY ROCKS!",
		"SWEET ROCKS! CANDY ROCKS! ROSE ROCKS!",
		"ME WANT ALL ROCK!"
	},
	AcceptOption = "You again? Seriously?!",
	DeclineOption = "Absolutely not.",
	AcceptDialog = { "?", "ME NOT DAVE. ME <b>DOVE</b>.", "ME NO WANT BOULDER. ONLY ROCK." },
	InProgressDialog = { "WHERE ROCKS?" },
	GiveOption = "Here's your rocks...",
	CancelOption = "Still working on it...",
	CompleteDialog = { "LOVELY ROCK MOUNTAIN!" },
	IncompleteDialog = { "NO ROCK?" },
	PostCompleteDialog = { "HAVE ALL ROCK. HAPPY." }
}

for k, v42 in v do
	if dove[k] == nil then
		dove[k] = v42
	end
end

SimpleFetchQuests.Dove = dove
local amora = {
	QuestName = "Valentides 2026: Amora",
	Location = "Sweetheart Shores",
	Objectives = { module.CatchFishAny({
			Fish = {
				"Rose Bouquet",
				"Stuffed Bear",
				"Box of Chocolate",
				"Cupid Relic",
				"Valentine's Relic",
				"Fischversation Hearts Box",
				"Heart Balloon",
				"Heart Cookie",
				"Heart Sand Dollar"
			},
			PlayerZones = { "Sweetheart Shores" },
			RequiredAmount = 100
		}) },
	Rewards = {
		{ "LocalCurrency", "Chocolates", 500 },
		{ "Xp", 40000 }
	},
	InitialDialog = {
		"Who dumped all this stuff in the water...",
		"I'm pretty sure there's an equal number of fish and various items here...",
		"Could you catch some of that so the <i>actual</i> fish can thrive again?"
	},
	AcceptOption = "Sure thing.",
	DeclineOption = "Maybe later...",
	AcceptDialog = { "Good luck!" },
	InProgressDialog = { "Did you get the water cleaned up?" },
	GiveOption = "All done!",
	CancelOption = "Not yet...",
	CompleteDialog = { "Thank you! Hopefully this helps a little...", "Take this for your troubles!" },
	DeclineDialog = { "Alright, no worries!" },
	PostCompleteDialog = {
		"Ugh, looks like there's still a lot of junk left...",
		"Don't tell me it's just infinite..."
	}
}

for k, v43 in v do
	if amora[k] == nil then
		amora[k] = v43
	end
end

SimpleFetchQuests.Amora = amora
local valen = {
	QuestName = "Valentides 2026: Valen",
	Location = "Sweetheart Shores",
	Objectives = { module.ObtainItem({
			Item = { "Lovestorm Turtle", "Lovestorm Turtle Supercharged", "Sacred Lovestorm Turtle" },
			RequiredAmount = 1,
			ForNpc = "Valen"
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Cupid Relic",
			{
				Weight = 15,
				Mutation = "Unsellable"
			},
			1
		},
		{ "LocalCurrency", "Chocolates", 1000 },
		{ "Xp", 40000 }
	},
	InitialDialog = { "I like turtles.", "Bring me a turtle.", "A special turtle." },
	AcceptOption = "Okay?",
	DeclineOption = "Maybe later...",
	AcceptDialog = { "Yay" },
	InProgressDialog = { "Did you find a special turtle for me?" },
	GiveOption = "Here you go!",
	CancelOption = "Not yet...",
	CompleteDialog = { "Thank you for the turtle.", "I like turtles." },
	IncompleteDialog = { "I'm not seeing any special turtles." },
	PostCompleteDialog = { "I like turtles." }
}

for k, v44 in v do
	if valen[k] == nil then
		valen[k] = v44
	end
end

SimpleFetchQuests.Valen = valen
v = {}
SimpleFetchQuests._ = nil
local sprout = {
	QuestName = "Sprout & Friends",
	Location = "Lost Jungle",
	Type = "Major",
	Objectives = {
		module.ObtainItem({
			Item = "Clownfish",
			RequiredAmount = 3,
			RequiredAttributes = {
				Mutation = "Lunar"
			},
			ForNpc = "Sprout"
		}),
		module.ObtainItem({
			Item = "Clownfish",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Mythical"
			},
			ForNpc = "Sprout"
		}),
		module.ObtainItem({
			Item = "Blue Tang",
			RequiredAmount = 3,
			RequiredAttributes = {
				Mutation = "Lost"
			},
			ForNpc = "Sprout"
		}),
		module.ObtainItem({
			Item = "Great White Shark",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Exploded"
			},
			ForNpc = "Sprout"
		}),
		module.ObtainItem({
			Item = "Great Hammerhead Shark",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Silver"
			},
			ForNpc = "Sprout"
		}),
		module.ObtainItem({
			Item = "Shortfin Mako Shark",
			RequiredAmount = 3,
			RequiredAttributes = {
				Mutation = "Abyssal"
			},
			ForNpc = "Sprout"
		}),
		module.ObtainItem({
			Item = "Dumbo Octopus",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Aurora"
			},
			ForNpc = "Sprout"
		}),
		module.ObtainItem({
			Item = "Butterflyfish",
			RequiredAmount = 3,
			RequiredAttributes = {
				Sparkling = true
			},
			ForNpc = "Sprout"
		}),
		module.ObtainItem({
			Item = "Golden Seahorse",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Midas"
			},
			ForNpc = "Sprout"
		}),
		module.ObtainItem({
			Item = "Treble Bass",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Mythical"
			},
			ForNpc = "Sprout"
		}),
		module.ObtainItem({
			Item = "Trumpetfish",
			RequiredAmount = 2,
			RequiredAttributes = {
				Mutation = "Heavenly"
			},
			ForNpc = "Sprout"
		}),
		module.ObtainItem({
			Item = "Pufferflute",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Aurora"
			},
			ForNpc = "Sprout"
		}),
		module.ObtainItem({
			Item = "Stringed Grouper",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Lunar"
			},
			ForNpc = "Sprout"
		}),
		module.ObtainItem({
			Item = "Spotted Drum",
			RequiredAmount = 2,
			RequiredAttributes = {
				Mutation = "Midas"
			},
			ForNpc = "Sprout"
		}),
		module.ObtainItem({
			Item = "Siren Singer",
			RequiredAmount = 2,
			RequiredAttributes = {
				Mutation = "Heavenly"
			},
			ForNpc = "Sprout"
		}),
		module.ObtainItem({
			Item = "Hidden Pipefish",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Mythical"
			},
			ForNpc = "Sprout"
		})
	},
	Rewards = {
		{ "Rod", "Tranquility Rod" },
		{ "Xp", 100000 },
		{ "Coin", 50000 }
	},
	InitialDialog = {
		"Oh! A visitor!",
		"I've been so lonely out here... I just want some friends.",
		"You know what would be really cool?",
		`A <b>{module.mutationDisplay("Lunar")} Clownfish</b> and a <b>{module.mutationDisplay("Mythical")} Clownfish</b>! Like best buddy clownfish!`,
		`Oh! And a <b>{module.mutationDisplay("Lost")} Blue Tang</b> too! Every group needs a blue one!`,
		`Some tough friends would be nice... like a <b>{module.mutationDisplay("Exploded")} Great White Shark</b>, a <b>{module.mutationDisplay("Silver")} Great Hammerhead Shark</b>, and a <b>{module.mutationDisplay("Abyssal")} Shortfin Mako Shark</b>!`,
		`And the gentle ones! An <b>{module.mutationDisplay("Aurora")} Dumbo Octopus</b>, a <b>Sparkling Butterflyfish</b>, and a <b>{module.mutationDisplay("Midas")} Golden Seahorse</b>!`,
		"Wait wait wait... I just had the BEST idea.",
		"What if they had a BAND?!",
		`I'd need a <b>{module.mutationDisplay("Mythical")} Treble Bass</b> on keys and a <b>{module.mutationDisplay("Heavenly")} Trumpetfish</b> on brass!`,
		`An <b>{module.mutationDisplay("Aurora")} Pufferflute</b> on woodwinds and a <b>{module.mutationDisplay("Lunar")} Stringed Grouper</b> on guitar!`,
		`A <b>{module.mutationDisplay("Midas")} Spotted Drum</b> on percussion, a <b>{module.mutationDisplay("Heavenly")} Siren Singer</b> as the vocalist...`,
		`And an <b>{module.mutationDisplay("Mythical")} Hidden Pipefish</b> on the pipes! The perfect band!`,
		"So... think you could help me out?"
	},
	AcceptOption = "I'll find them all!",
	DeclineOption = "That's a lot... Maybe later.",
	AcceptDialog = { "Yay! Thank you so much! This is gonna be the best party ever!" },
	InProgressDialog = { "Did you find all my friends and band members?" },
	GiveOption = "Here they are!",
	CancelOption = "Not yet...",
	CompleteDialog = { "Oh my gosh! They're all here!", "Friends AND a band?! This is the best day of my life!" },
	IncompleteDialog = { "I don't think everyone's here yet..." },
	PostCompleteDialog = { "The band sounds amazing!", "We're all having the best time together!" }
}

for k, v45 in v do
	if sprout[k] == nil then
		sprout[k] = v45
	end
end

SimpleFetchQuests.Sprout = sprout
v = {}
SimpleFetchQuests._ = nil
local olivia = {
	QuestName = "Olivia's Dream",
	Location = "Toxic Grove",
	Type = "Major",
	Objectives = { module.ObtainItem({
			Item = { "Venom Maw", "Mycotide Serpent" },
			RequiredAmount = 1,
			ForNpc = "Olivia"
		}) },
	Rewards = {
		{ "Boat", "Toxic-Proof Raft" }
	},
	InitialDialog = {
		"Have you ever seen a <b>Venom Maw</b> up close?",
		"Or even a <b>Mycotide Serpent</b>?",
		"I've always wanted to study one myself.",
		"I'll give you a <b>Toxic-Proof Raft</b> to let you cross that dangerous river in return."
	},
	AcceptOption = "I could try to find one",
	DeclineOption = "Maybe another time",
	AcceptDialog = { "You would? I’d really appreciate that. Thank you." },
	InProgressDialog = { "Any luck finding one of those fish yet?" },
	GiveOption = "I found one",
	CancelOption = "Not yet",
	CompleteDialog = {
		"Incredible... You actually found one.",
		"Thank you. This means a lot to me.",
		"Here, take this <b>raft</b>. You'll be able to cross this river."
	},
	IncompleteDialog = { "I don't see the fish I mentioned. Are you sure you found the right one?" },
	PostCompleteDialog = { "I gave you a <b>raft</b> that allows you to cross this toxic river." }
}

for k, v46 in v do
	if olivia[k] == nil then
		olivia[k] = v46
	end
end

SimpleFetchQuests.Olivia = olivia
local caleb = {
	QuestName = "Widow Bloom Sample",
	Location = "Toxic Grove",
	Objectives = { module.ObtainItem({
			Item = { "Widow Bloom" },
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Toxic"
			},
			ForNpc = "Caleb"
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Toxinburst Handle",
			nil,
			1
		}
	},
	InitialDialog = {
		"Step soft in this grove, tall-walker.",
		"See the <b>Toxic Widow Blooms</b>? Bitter sap. Mean flowers.",
		"Bring one to me. Think you can manage?"
	},
	AcceptOption = "I'll get one",
	DeclineOption = "No thanks",
	AcceptDialog = { "Good. Keep nose closed. Spores bite." },
	InProgressDialog = { "You find <b>Toxic Widow Bloom</b> yet?" },
	GiveOption = "Here it is",
	CancelOption = "Still looking..",
	CompleteDialog = { "Yes... still infused with poison.", "Good bloom. Very good." },
	IncompleteDialog = { "No, no. That bloom wrong." },
	PostCompleteDialog = { "If you see more twisted plants… tell Caleb." }
}

for k, v47 in v do
	if caleb[k] == nil then
		caleb[k] = v47
	end
end

SimpleFetchQuests.Caleb = caleb
local felix = {
	QuestName = "Blight Specimen",
	Location = "Toxic Grove",
	Objectives = { module.ObtainItem({
			Item = { "Blight Pufferfish" },
			RequiredAttributes = {
				WeightClass = "Giant"
			},
			RequiredAmount = 1,
			ForNpc = "Felix"
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Toxinburst Shaft",
			nil,
			1
		}
	},
	InitialDialog = {
		"Oh! You come at good sun-time.",
		"Felix studies the <b>Blight Pufferfish</b> that swim in rot-water.",
		"If you bring one back, Felix will be very grateful."
	},
	AcceptOption = "I'll catch one",
	DeclineOption = "Maybe later.",
	AcceptDialog = { "Careful when fish puffs big. Spikes like thorns." },
	InProgressDialog = { "You catch <b>Giant Blight Pufferfish</b> yet?" },
	GiveOption = "Got one!",
	CancelOption = "Not yet.",
	CompleteDialog = { "Whoa... big one! Very big!", "Felix learns much from this fish." },
	IncompleteDialog = { "Hmm. That not the fish Felix asked for." },
	PostCompleteDialog = { "Still thinking about that huge puff-fish..." }
}

for k, v48 in v do
	if felix[k] == nil then
		felix[k] = v48
	end
end

SimpleFetchQuests.Felix = felix
local elijah = {
	QuestName = "Twisted Collection",
	Location = "Toxic Grove",
	Objectives = { module.ObtainItem({
			Item = { "Toxic Jellymass" },
			RequiredAmount = 1,
			ForNpc = "Elijah"
		}), module.CatchFishAny({
			Fish = { "Mire Krakenling" },
			RequiredAmount = 1,
			AndReturn = true
		}), module.CatchFishAny({
			Fish = { "Planterech" },
			RequiredAmount = 1,
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Twisted Relic",
			nil,
			3
		}
	},
	InitialDialog = {
		"This grove grows strange life.",
		"Elijah searches for three wriggling things.",
		"A <b>Toxic Jellymass</b>, a <b>Mire Krakenling</b>, and a <b>Planterech</b>."
	},
	AcceptOption = "I'll collect them",
	DeclineOption = "No thanks..",
	AcceptDialog = { "Bring all three. Roots and waters will guide you." },
	InProgressDialog = { "You carry the three creatures yet?" },
	GiveOption = "Yes",
	CancelOption = "Not yet",
	CompleteDialog = { "Excellent. Very good gathering.", "These will serve Elijah well." },
	IncompleteDialog = { "Hmm. Collection not finished." },
	PostCompleteDialog = { "The grove hides many more secrets beneath leaves." }
}

for k, v49 in v do
	if elijah[k] == nil then
		elijah[k] = v49
	end
end

SimpleFetchQuests.Elijah = elijah
local joseph = {
	QuestName = "Rotten Find",
	Location = "Toxic Grove",
	Objectives = { module.ObtainItem({
			Item = { "Rotted Seed" },
			RequiredAmount = 1,
			ForNpc = "Joseph"
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Blight Idol",
			nil,
			1
		}
	},
	InitialDialog = {
		"Heh... most folk walk away from rot.",
		"Joseph walks toward it.",
		"If you find a <b>Rotted Seed</b>, bring it here."
	},
	AcceptOption = "I'll look for it",
	DeclineOption = "That's disgusting.",
	AcceptDialog = { "Search the soggy, smelly corners." },
	InProgressDialog = { "You find <b>Rotted Seed</b> yet?" },
	GiveOption = "Here",
	CancelOption = "Not yet",
	CompleteDialog = { "Ahhh... see that crumble?", "Beautiful rot." },
	IncompleteDialog = { "Nope. Wrong seed." },
	PostCompleteDialog = { "Rot feeds new growth. Always." }
}

for k, v50 in v do
	if joseph[k] == nil then
		joseph[k] = v50
	end
end

SimpleFetchQuests.Joseph = joseph
local daisy = {
	QuestName = "Perfect Flower",
	Location = "Living Garden",
	Objectives = { module.CatchFishAny({
			Fish = { "Diamond Daisy" },
			RequiredAmount = 1,
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Bloom Totem",
			nil,
			1
		}
	},
	InitialDialog = {
		"Garden smells sweet today, yes?",
		"Daisy searches for special bloom… a <b>Diamond Daisy</b>.",
		"Rare flower. Shiny like morning dew."
	},
	AcceptOption = "I'll find one",
	DeclineOption = "Maybe later",
	AcceptDialog = { "No rush. Good flowers grow with patience." },
	InProgressDialog = { "You find <b>Diamond Daisy</b> yet?" },
	GiveOption = "Here it is",
	CancelOption = "Not yet",
	CompleteDialog = { "Ohhh... look at it sparkle!", "Beautiful bloom. Daisy thanks you." },
	IncompleteDialog = { "Hmm… that not the flower Daisy meant." },
	PostCompleteDialog = { "Garden always grows new wonders." }
}

for k, v51 in v do
	if daisy[k] == nil then
		daisy[k] = v51
	end
end

SimpleFetchQuests.Daisy = daisy
local mike = {
	QuestName = "Proof of Life",
	Location = "Living Garden",
	Objectives = { module.ObtainItem({
			Item = { "Living Seed" },
			RequiredAmount = 1
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Bloom Totem",
			nil,
			1
		}
	},
	InitialDialog = {
		"Hey, quick thing.",
		"Mike just wants to see a <b>Living Seed</b> with his own eyes.",
		"You keep it. Just show it to me."
	},
	AcceptOption = "Alright",
	DeclineOption = "Not interested..",
	AcceptDialog = { "Good. Come back if you find one." },
	InProgressDialog = { "You have <b>Living Seed</b> to show Mike?" },
	GiveOption = "Take a look.",
	CancelOption = "Still searching..",
	CompleteDialog = { "No way... it really alive.", "That... that is amazing." },
	IncompleteDialog = { "Hmm. That not Living Seed." },
	PostCompleteDialog = { "Still strange to think seeds can live like that..." }
}

for k, v52 in v do
	if mike[k] == nil then
		mike[k] = v52
	end
end

SimpleFetchQuests.Mike = mike
v = {
	Icon = "rbxassetid://82328659300693",
	IconColor = Color3.fromRGB(23, 40, 13),
	ExpiresAt = module3.StPatricks26.ExpiresAt,
	NoNavigate = true
}
SimpleFetchQuests._ = nil
local leprechaunLarry = {
	QuestName = "Larry's Lost Gold",
	Location = "Shamrock Seas",
	Objectives = { module.ObtainItem({
			Item = { "Gold Coin" },
			RequiredAmount = 3,
			ForNpc = "Leprechaun Larry"
		}) },
	Rewards = {
		{
			"DataInstanceValue",
			"Cache.LeprechaunQuestsDone",
			"add",
			1
		},
		{ "Bobber", "Golden Coin" },
		{
			"ItemOrFish",
			"Luck Potion",
			{
				Tier = 1
			},
			1
		},
		{ "Bait", "Clover Cluster", 15 }
	},
	InitialDialog = {
		"Ahh... me pockets feel a little light today.",
		"I dropped <b>three Gold Coins</b> somewhere in the water.",
		"Bring them back and I'll share a bit of luck with ye."
	},
	AcceptOption = "I'll find them",
	DeclineOption = "Maybe later..",
	AcceptDialog = { "Keep an eye out for the shine of gold!" },
	InProgressDialog = { "Found me three coins yet?" },
	GiveOption = "Here they are",
	CancelOption = "Still looking",
	CompleteDialog = { "Ahh, there's the shine I missed!", "A deal's a deal. Take these." },
	IncompleteDialog = { "Hmm... that's not right." },
	PostCompleteDialog = { "Gold always finds its way back to Larry." }
}

for k, v53 in v do
	if leprechaunLarry[k] == nil then
		leprechaunLarry[k] = v53
	end
end

SimpleFetchQuests["Leprechaun Larry"] = leprechaunLarry
local leprechaunLenny = {
	QuestName = "Ribbon of the Rainbow",
	Location = "Shamrock Seas",
	Objectives = { module.ObtainItem({
			Item = { "Rainbow Ribbonfish" },
			RequiredAmount = 5,
			ForNpc = "Leprechaun Lenny"
		}) },
	Rewards = {
		{
			"DataInstanceValue",
			"Cache.LeprechaunQuestsDone",
			"add",
			1
		},
		{ "Lantern", "Tiny Rainbow" },
		{ "Bait", "Clover Cluster", 5 }
	},
	InitialDialog = {
		"Ever seen a ribbon made of rainbow scales?",
		"They call them <b>Rainbow Ribbonfish</b>.",
		"Bring me five and I'll show you something pretty."
	},
	AcceptOption = "I'll catch them",
	DeclineOption = "Maybe later..",
	AcceptDialog = { "Follow the colors across the water!" },
	InProgressDialog = { "Got five ribbonfish yet?" },
	GiveOption = "Yes",
	CancelOption = "Not yet",
	CompleteDialog = { "Beautiful! Look how they shimmer.", "Here, a tiny rainbow for your travels." },
	IncompleteDialog = { "Not quite five yet." },
	PostCompleteDialog = { "Rainbows love the sea breeze." }
}

for k, v54 in v do
	if leprechaunLenny[k] == nil then
		leprechaunLenny[k] = v54
	end
end

SimpleFetchQuests["Leprechaun Lenny"] = leprechaunLenny
local leprechaunLucas = {
	QuestName = "Clover Carp Gathering",
	Location = "Shamrock Seas",
	Objectives = { module.ObtainItem({
			Item = { "Clover Carp" },
			RequiredAmount = 2,
			ForNpc = "Leprechaun Lucas"
		}), module.ObtainItem({
			Item = { "Four Leaf Clover" },
			RequiredAmount = 3,
			ForNpc = "Leprechaun Lucas"
		}) },
	Rewards = {
		{
			"DataInstanceValue",
			"Cache.LeprechaunQuestsDone",
			"add",
			1
		},
		{ "Bait", "Clover Cluster", 5 },
		{
			"ItemOrFish",
			"Clover Glider",
			nil,
			1
		},
		{
			"ItemOrFish",
			"Luck Potion",
			{
				Tier = 1
			},
			1
		}
	},
	InitialDialog = {
		"Clover Carp are nibbling all around today.",
		"I could use two of them... and three <b>Four Leaf Clovers</b> too.",
		"Bring them here and we'll share the luck."
	},
	AcceptOption = "I'll gather them",
	DeclineOption = "Maybe later..",
	AcceptDialog = { "Clovers hide in the strangest places." },
	InProgressDialog = { "Got the carp and clovers?" },
	GiveOption = "Yes",
	CancelOption = "Still searching",
	CompleteDialog = { "Lovely haul! The luck is strong today.", "Take these rewards with you." },
	IncompleteDialog = { "You're missing something still." },
	PostCompleteDialog = { "The clovers are smiling today." }
}

for k, v55 in v do
	if leprechaunLucas[k] == nil then
		leprechaunLucas[k] = v55
	end
end

SimpleFetchQuests["Leprechaun Lucas"] = leprechaunLucas
local leprechaunLogan = {
	QuestName = "Golden Fortune",
	Location = "Shamrock Seas",
	Objectives = { module.ObtainItem({
			Item = { "Fortune Flounder" },
			RequiredAttributes = {
				Mutation = "Lucky Gold"
			},
			RequiredAmount = 1,
			ForNpc = "Leprechaun Logan"
		}), module.ObtainItem({
			Item = { "Rainbow Leviathan" },
			RequiredAttributes = {
				Mutation = "Lucky Gold"
			},
			RequiredAmount = 1,
			ForNpc = "Leprechaun Logan"
		}) },
	Rewards = {
		{
			"DataInstanceValue",
			"Cache.LeprechaunQuestsDone",
			"add",
			1
		},
		{
			"ItemOrFish",
			"Luck Potion",
			{
				Tier = 1
			},
			1
		},
		{ "Bait", "Clover Cluster", 3 },
		{
			"ItemOrFish",
			"Lucky Gloves",
			nil,
			1
		}
	},
	InitialDialog = {
		"I'm searching for the rarest gold in the sea.",
		`A <b>{module.mutationDisplay("Lucky Gold")} Fortune Flounder</b> and a <b>{module.mutationDisplay("Lucky Gold")} Rainbow Leviathan</b>.`,
		"Bring them here if fortune favors you."
	},
	AcceptOption = "I'll hunt them",
	DeclineOption = "Maybe later..",
	AcceptDialog = { "Gold glitters even underwater." },
	InProgressDialog = { "Found the golden ones yet?" },
	GiveOption = "Here they are",
	CancelOption = "Still looking",
	CompleteDialog = { "Now that's true luck!", "Take these gloves and keep the fortune flowing." },
	IncompleteDialog = { "Hmm, not quite the golden ones." },
	PostCompleteDialog = { "Golden fish are the pride of the sea." }
}

for k, v56 in v do
	if leprechaunLogan[k] == nil then
		leprechaunLogan[k] = v56
	end
end

SimpleFetchQuests["Leprechaun Logan"] = leprechaunLogan
local leprechaunLawrence = {
	QuestName = "Grand Rainbow Collection",
	Location = "Shamrock Seas",
	Objectives = {
		module.ObtainItem({
			Item = { "Shamrock Salmon" },
			RequiredAmount = 3,
			ForNpc = "Leprechaun Lawrence"
		}),
		module.ObtainItem({
			Item = { "Clover Carp" },
			RequiredAmount = 3,
			ForNpc = "Leprechaun Lawrence"
		}),
		module.ObtainItem({
			Item = { "Rainbow Ribbonfish" },
			RequiredAmount = 3,
			ForNpc = "Leprechaun Lawrence"
		}),
		module.ObtainItem({
			Item = { "Fortune Flounder" },
			RequiredAmount = 3,
			ForNpc = "Leprechaun Lawrence"
		}),
		module.ObtainItem({
			Item = { "Rainbow Leviathan" },
			RequiredAmount = 1,
			ForNpc = "Leprechaun Lawrence"
		})
	},
	Rewards = {
		{
			"DataInstanceValue",
			"Cache.LeprechaunQuestsDone",
			"add",
			1
		},
		{ "Emote", "rainbownap" },
		{ "Bait", "Clover Cluster", 5 }
	},
	InitialDialog = {
		"I'm assembling the greatest rainbow catch ever seen.",
		"A mix of clover, shamrock, and fortune fish.",
		"Bring them all and the rainbow will be complete."
	},
	AcceptOption = "I'll gather them",
	DeclineOption = "Maybe later..",
	AcceptDialog = { "The rainbow awaits your rod!" },
	InProgressDialog = { "How goes the grand collection?" },
	GiveOption = "All here",
	CancelOption = "Still fishing",
	CompleteDialog = { "Magnificent! A perfect rainbow haul.", "Time for a well earned nap." },
	IncompleteDialog = { "The rainbow isn't finished yet." },
	PostCompleteDialog = { "Ahh... nothing like a rainbow nap." }
}

for k, v57 in v do
	if leprechaunLawrence[k] == nil then
		leprechaunLawrence[k] = v57
	end
end

SimpleFetchQuests["Leprechaun Lawrence"] = leprechaunLawrence
local leprechaunLandon = {
	QuestName = "Shamrock Scylla",
	Location = "Shamrock Seas",
	Objectives = { module.CatchFishAny({
			Fish = { "Shamrock Scylla" },
			RequiredAmount = 1,
			ForNpc = "Leprechaun Landon",
			AndReturn = true
		}) },
	Rewards = {
		{
			"DataInstanceValue",
			"Cache.LeprechaunQuestsDone",
			"add",
			1
		},
		{
			"ItemOrFish",
			"Luck Potion",
			{
				Tier = 1
			},
			5
		},
		{ "Bait", "Clover Cluster", 30 },
		{
			"ItemOrFish",
			"Four Leaf Clover",
			nil,
			1
		}
	},
	InitialDialog = {
		"A fierce creature swims the lucky waters.",
		"The mighty <b>Shamrock Scylla</b>.",
		"Catch one and show me the proof."
	},
	AcceptOption = "I'll catch it",
	DeclineOption = "Maybe later..",
	AcceptDialog = { "May your line hold strong!" },
	InProgressDialog = { "Did you battle the Scylla yet?" },
	GiveOption = "Yes",
	CancelOption = "Not yet",
	CompleteDialog = { "By the clovers! That's a mighty catch.", "Take these lucky supplies." },
	IncompleteDialog = { "That's not the Scylla." },
	PostCompleteDialog = { "Not many fishers face the Scylla." }
}

for k, v58 in v do
	if leprechaunLandon[k] == nil then
		leprechaunLandon[k] = v58
	end
end

SimpleFetchQuests["Leprechaun Landon"] = leprechaunLandon
local leprechaunLeo = {
	QuestName = "Lucky Megalodon",
	Location = "Shamrock Seas",
	Objectives = { module.CatchFishAny({
			Fish = { "Shamrock Megalodon" },
			RequiredAmount = 1,
			ForNpc = "Leprechaun Leo",
			AndReturn = true
		}) },
	Rewards = {
		{
			"DataInstanceValue",
			"Cache.LeprechaunQuestsDone",
			"add",
			1
		},
		{
			"ItemOrFish",
			"Luck Potion",
			{
				Tier = 1
			},
			3
		},
		{ "Bait", "Clover Cluster", 20 },
		{
			"ItemOrFish",
			"Four Leaf Clover",
			nil,
			1
		}
	},
	InitialDialog = {
		"They say a <b>Shamrock Megalodon</b> prowls these waters.",
		"A beast blessed with clover luck.",
		"Catch it and show me you’re the real deal."
	},
	AcceptOption = "I'll find it",
	DeclineOption = "Maybe later..",
	AcceptDialog = { "Mind your rod... that one's massive." },
	InProgressDialog = { "Seen the Megalodon yet?" },
	GiveOption = "Yes",
	CancelOption = "Still searching",
	CompleteDialog = { "Now that's a legendary catch!", "Take this luck with you." },
	IncompleteDialog = { "That's not the Megalodon." },
	PostCompleteDialog = { "A fisher who lands that beast deserves respect." }
}

for k, v59 in v do
	if leprechaunLeo[k] == nil then
		leprechaunLeo[k] = v59
	end
end

SimpleFetchQuests["Leprechaun Leo"] = leprechaunLeo
local leprechaunLuke = {
	QuestName = "Kraken of Clover",
	Location = "Shamrock Seas",
	Objectives = { module.CatchFishAny({
			Fish = { "Shamrock Kraken" },
			RequiredAmount = 1,
			ForNpc = "Leprechaun Luke",
			AndReturn = true
		}) },
	Rewards = {
		{
			"DataInstanceValue",
			"Cache.LeprechaunQuestsDone",
			"add",
			1
		},
		{
			"ItemOrFish",
			"Luck Potion",
			{
				Tier = 1
			},
			4
		},
		{ "Bait", "Clover Cluster", 25 },
		{
			"ItemOrFish",
			"Four Leaf Clover",
			nil,
			1
		}
	},
	InitialDialog = {
		"Deep below swims a tangled terror.",
		"The <b>Shamrock Kraken</b>.",
		"Catch one and show me if you're brave."
	},
	AcceptOption = "I'll try",
	DeclineOption = "Maybe later..",
	AcceptDialog = { "Watch those tentacles!" },
	InProgressDialog = { "Did the Kraken show itself?" },
	GiveOption = "Yes",
	CancelOption = "Not yet",
	CompleteDialog = { "Ha! You wrestled the Kraken itself.", "Luck clearly favors you." },
	IncompleteDialog = { "That's not the Kraken." },
	PostCompleteDialog = { "Kraken stories grow with every telling." }
}

for k, v60 in v do
	if leprechaunLuke[k] == nil then
		leprechaunLuke[k] = v60
	end
end

SimpleFetchQuests["Leprechaun Luke"] = leprechaunLuke
local leprechaunLevi = {
	QuestName = "Bloop of Luck",
	Location = "Shamrock Seas",
	Objectives = { module.CatchFishAny({
			Fish = { "Shamrock Bloop Fish" },
			RequiredAmount = 1,
			ForNpc = "Leprechaun Levi",
			AndReturn = true
		}) },
	Rewards = {
		{
			"DataInstanceValue",
			"Cache.LeprechaunQuestsDone",
			"add",
			1
		},
		{
			"ItemOrFish",
			"Luck Potion",
			{
				Tier = 1
			},
			5
		},
		{ "Bait", "Clover Cluster", 30 },
		{
			"ItemOrFish",
			"Four Leaf Clover",
			nil,
			1
		}
	},
	InitialDialog = {
		"Ever hear the sound... bloop...",
		"That's the call of the <b>Shamrock Bloop Fish</b>.",
		"Catch one and show it here."
	},
	AcceptOption = "I'll catch it",
	DeclineOption = "Maybe later..",
	AcceptDialog = { "Listen for the bloop..." },
	InProgressDialog = { "Hear the bloop yet?" },
	GiveOption = "Yes",
	CancelOption = "Not yet",
	CompleteDialog = { "That's the one! I knew that sound anywhere.", "Take this bundle of luck." },
	IncompleteDialog = { "Hmm... not the bloop fish." },
	PostCompleteDialog = { "Bloop echoes across lucky seas." }
}

for k, v61 in v do
	if leprechaunLevi[k] == nil then
		leprechaunLevi[k] = v61
	end
end

SimpleFetchQuests["Leprechaun Levi"] = leprechaunLevi
local leprechaunLouis = {
	QuestName = "Leviathan of Luck",
	Location = "Shamrock Seas",
	Objectives = { module.CatchFishAny({
			Fish = { "Shamrock Leviathan" },
			RequiredAmount = 1,
			ForNpc = "Leprechaun Louis",
			AndReturn = true
		}) },
	Rewards = {
		{
			"DataInstanceValue",
			"Cache.LeprechaunQuestsDone",
			"add",
			1
		},
		{
			"ItemOrFish",
			"Luck Potion",
			{
				Tier = 1
			},
			5
		},
		{ "Bait", "Clover Cluster", 30 },
		{
			"ItemOrFish",
			"Four Leaf Clover",
			nil,
			1
		}
	},
	InitialDialog = {
		"Only the luckiest anglers see it.",
		"The legendary <b>Shamrock Leviathan</b>.",
		"Catch one and show it to me."
	},
	AcceptOption = "I'll hunt it",
	DeclineOption = "Maybe later..",
	AcceptDialog = { "May the clovers guide your line." },
	InProgressDialog = { "Did the Leviathan appear?" },
	GiveOption = "Yes",
	CancelOption = "Still searching",
	CompleteDialog = { "Remarkable! That's a catch for the ages.", "You've earned this luck." },
	IncompleteDialog = { "That's not the Leviathan." },
	PostCompleteDialog = { "Few can claim that catch." }
}

for k, v62 in v do
	if leprechaunLouis[k] == nil then
		leprechaunLouis[k] = v62
	end
end

SimpleFetchQuests["Leprechaun Louis"] = leprechaunLouis
local leprechaunLachlan = {
	QuestName = "Golden Shamrock Catch",
	Location = "Shamrock Seas",
	Objectives = { module.CatchFishAny({
			Fish = {
				"Shamrock Scylla",
				"Shamrock Megalodon",
				"Shamrock Kraken",
				"Shamrock Bloop Fish",
				"Shamrock Leviathan"
			},
			RequiredAttributes = {
				Mutation = "Lucky Gold"
			},
			RequiredAmount = 1,
			AndReturn = true
		}) },
	Rewards = {
		{
			"DataInstanceValue",
			"Cache.LeprechaunQuestsDone",
			"add",
			1
		},
		{ "Boat", "Shamrock Express" }
	},
	InitialDialog = {
		"Only the rarest catch will do now.",
		`Any one of a <b>{module.mutationDisplay("Lucky Gold")} Shamrock hunt fish</b>.`,
		"Bring one back and I'll reward you grandly."
	},
	AcceptOption = "I'll hunt it",
	DeclineOption = "Maybe later..",
	AcceptDialog = { "May fortune shine bright!" },
	InProgressDialog = { "Found the golden shamrock fish?" },
	GiveOption = "Yes",
	CancelOption = "Not yet",
	CompleteDialog = { "Incredible! That's true fortune.", "Take the Shamrock Express and sail in style." },
	IncompleteDialog = { "That's not the golden one." },
	PostCompleteDialog = { "A fisher with that catch rides in style." }
}

for k, v63 in v do
	if leprechaunLachlan[k] == nil then
		leprechaunLachlan[k] = v63
	end
end

SimpleFetchQuests["Leprechaun Lachlan"] = leprechaunLachlan
local leprechaunLiam = {
	QuestName = "Shamrock Hunt",
	Location = "Shamrock Seas",
	Objectives = { module.CatchFishAny({
			Fish = {
				"Shamrock Scylla",
				"Shamrock Megalodon",
				"Shamrock Kraken",
				"Shamrock Bloop Fish",
				"Shamrock Leviathan"
			},
			RequiredAmount = 1,
			ForNpc = "Leprechaun Liam",
			AndReturn = true
		}) },
	Rewards = {
		{
			"DataInstanceValue",
			"Cache.LeprechaunQuestsDone",
			"add",
			1
		},
		{
			"ItemOrFish",
			"Shamrock Coil",
			nil,
			1
		},
		{
			"ItemOrFish",
			"Luck Potion",
			{
				Tier = 1
			},
			1
		}
	},
	InitialDialog = {
		"Hey... you like Coils?",
		"Ever heard of a Shamrock Coil?",
		"Fetch me ANY Shamrock Hunt Fish, and I'll hook you up."
	},
	AcceptOption = "Sure... man.",
	DeclineOption = "Maybe later..",
	AcceptDialog = { "Hehehe...." },
	InProgressDialog = { "Get me ANY of those FEISTY Shamrock Hunt fish..." },
	GiveOption = "This will do nicely!",
	CancelOption = "Alright then.",
	CompleteDialog = { "Very splendidly done chap!", "Make good use of that coil!" },
	IncompleteDialog = { "This is just not what I asked for." },
	PostCompleteDialog = { "Are you enjoying your Shamrock Coil?" }
}

for k, v64 in v do
	if leprechaunLiam[k] == nil then
		leprechaunLiam[k] = v64
	end
end

SimpleFetchQuests["Leprechaun Liam"] = leprechaunLiam
v = {
	Icon = "",
	IconColor = Color3.fromRGB(255, 146, 37),
	ExpiresAt = DateTime.fromUniversalTime(2026, 9, 12, 16)
}
SimpleFetchQuests._ = nil
local fischfestSide = {
	QuestName = "Fischfest 2026: Peter Grillin",
	Location = "Fischfest",
	DisplayObjectives = {
		{ "Custom", 3, "Return 3 fish that can Grill with Peter Grillin" }
	},
	Objectives = { module.ObtainItem({
			Item = "BBQ Bass",
			RequiredAttributes = {
				Shiny = true
			},
			RequiredAmount = 3,
			AndReturn = true
		}) },
	Rewards = {
		{ "LocalCurrency", "Sunshells", 250 },
		{ "Xp", 1500 }
	},
	InitialDialog = { "man i love grilling", "it would be so sick if there was a fish that could grill with me" },
	InProgressDialog = { "seen any fish that are good at grilling?" },
	PostCompleteDialog = { "man i love grilling" }
}

for k, v65 in v do
	if fischfestSide[k] == nil then
		fischfestSide[k] = v65
	end
end

SimpleFetchQuests.FischfestSide1 = fischfestSide
local fischfestSide2 = {
	QuestName = "Fischfest 2026: Summersweet Sam",
	Location = "Fischfest",
	DisplayObjectives = {
		{ "Custom", 1, "???" }
	},
	Objectives = { module.ObtainItem({
			Item = "Lemonade",
			RequiredAttributes = {
				Shiny = true
			},
			RequiredAmount = 1,
			AndReturn = true
		}) },
	Rewards = {
		{ "LocalCurrency", "Sunshells", -1 }
	},
	InitialDialog = {
		"Hey, <i>friend</i>! Long time no see!",
		"Could I get a ?̵̨̨͖͈̟̞̟͈͔̖͉̙̩̀̒͗̀?̷̡̡͈͍̹̻̏̃̏̇̽̉͊͊͑̅̃?̵̧͚͙̫̞͕̤͙̝̥̅̀̾͒͌́͋͒ͅ?̷̝͎͌̎͑͋́̈́͐̚͠͝?̷̡̺͈̝͕͐̅̆͜?̵̢̨̖̤͍͙̲͓̩̤͉̳̝͈͙͓͔́̈̎͌̒̄̋̚?̷̛̼̩̹̙̈̀͑̀̈́̒̆͝͝͝?̷̮͓͇͍̩̭͎̖̽?̴̧̛͓͎̣̘̳̪͉͇͍̹̗͙̳̟͚̠̌͗̐̕͝?̷̮̳͕̠͔̪̖͛̇̓̈́͐̓̌͐̿͋̂͂̀͊͠͝?̶̢͔̗̭̰̥̲̯̜͌͂͛̅͛̇́̿̒̓͝?̸̤̩̝̳͉̦̅͋͒?̴̛̲͇̲̳͇̥̲̦̝́̄̊̇̌?̴̥͔̫̀͒́̌̀̋̍͌̓̐̈́̆́̐̿̃?̷̧̡̡̖̳̦̪̠͙̺̹̬̖̫̆͂̏̄͗̎̈́̕͘͠͝?̸͔̺̟̇͌̃͛͑̇̉͛̌͝?̵̧̨̢̮̹͙̏̔͋̿̚͜?̷̢̲̙͔̮̮̳͚͕͕͌̍͆͆̕͠͝ͅ?̵̢̦͍̬̱͋̀̐͐͒̏͋̉̓̒̕͠?̷͚͚̓̈̋̅?̶̡̢͎͕͙͓̠̤͇͔͕̰̖̝̼̓́̓̌͝ͅ"
	},
	InProgressDialog = { "Did you get the ?̵̨̨͖͈̟̞̟͈͔̖͉̙̩̀̒͗̀?̷̡̡͈͍̹̻̏̃̏̇̽̉͊͊͑̅̃?̵̧͚͙̫̞͕̤͙̝̥̅̀̾͒͌́͋͒ͅ?̷̝͎͌̎͑͋́̈́͐̚͠͝?̷̡̺͈̝͕͐̅̆͜?̵̢̨̖̤͍͙̲͓̩̤͉̳̝͈͙͓͔́̈̎͌̒̄̋̚?̷̛̼̩̹̙̈̀͑̀̈́̒̆͝͝͝?̷̮͓͇͍̩̭͎̖̽?̴̧̛͓͎̣̘̳̪͉͇͍̹̗͙̳̟͚̠̌͗̐̕͝?̷̮̳͕̠͔̪̖͛̇̓̈́͐̓̌͐̿͋̂͂̀͊͠͝?̶̢͔̗̭̰̥̲̯̜͌͂͛̅͛̇́̿̒̓͝?̸̤̩̝̳͉̦̅͋͒?̴̛̲͇̲̳͇̥̲̦̝́̄̊̇̌?̴̥͔̫̀͒́̌̀̋̍͌̓̐̈́̆́̐̿̃?̷̧̡̡̖̳̦̪̠͙̺̹̬̖̫̆͂̏̄͗̎̈́̕͘͠͝?̸͔̺̟̇͌̃͛͑̇̉͛̌͝?̵̧̨̢̮̹͙̏̔͋̿̚͜?̷̢̲̙͔̮̮̳͚͕͕͌̍͆͆̕͠͝ͅ?̵̢̦͍̬̱͋̀̐͐͒̏͋̉̓̒̕͠?̷͚͚̓̈̋̅?̶̡̢͎͕͙͓̠̤͇͔͕̰̖̝̼̓́̓̌͝ͅ?" },
	PostCompleteDialog = { "What do you mean \"give it back\"? What did I take?" }
}

for k, v66 in v do
	if fischfestSide2[k] == nil then
		fischfestSide2[k] = v66
	end
end

SimpleFetchQuests.FischfestSide2 = fischfestSide2
local fischfestSide3 = {
	QuestName = "Fischfest 2026: Sandy Scott",
	Location = "Fischfest",
	Objectives = { module.ObtainItem({
			Item = "Sand Fort",
			RequiredAttributes = {
				Mutation = "Sandy"
			},
			RequiredAmount = 1,
			ForNpc = "Sandy Scott"
		}) },
	Rewards = {
		{ "LocalCurrency", "Sunshells", 250 },
		{ "Xp", 1500 }
	},
	InitialDialog = {
		"Hey, have you seen my Sand Fort?",
		"I left for a bit to get something to drink, but it seems to have run off while I was gone!",
		"They do that all the time, right?",
		"It was like.... super Sandy. A lot more Sandy than your average Sand Fort."
	},
	InProgressDialog = { "Did you find my Sandy Sand Fort?" },
	PostCompleteDialog = { "Hopefully it won't run off again..." }
}

for k, v67 in v do
	if fischfestSide3[k] == nil then
		fischfestSide3[k] = v67
	end
end

SimpleFetchQuests.FischfestSide3 = fischfestSide3
local fischfestSide4 = {
	QuestName = "Fischfest 2026: Groovin' Gavin",
	Location = "Fischfest",
	Objectives = { module.ObtainItem({
			Item = "Beach Radio",
			RequiredAttributes = {
				Sparkling = true
			},
			RequiredAmount = 1,
			ForNpc = "Groovin' Gavin"
		}) },
	Rewards = {
		{ "LocalCurrency", "Sunshells", 500 },
		{ "Xp", 2500 }
	},
	InitialDialog = {
		"Yo, I love collectin' Beach Radios!",
		"I love turning the volume up as loud as I can and annoying everyone in a 100m radius!",
		"Think you could help with my endeavors? Lookin' for a Sparkling one next."
	},
	InProgressDialog = { "Did you find a Sparkling Beach Radio?" },
	PostCompleteDialog = { "Sweeeet..." }
}

for k, v68 in v do
	if fischfestSide4[k] == nil then
		fischfestSide4[k] = v68
	end
end

SimpleFetchQuests.FischfestSide4 = fischfestSide4
local fischfestSide5 = {
	QuestName = "Fischfest 2026: Big Foot",
	Location = "Fischfest",
	Objectives = { module.ObtainItem({
			Item = "Flipflopper",
			RequiredAttributes = {
				Shiny = true,
				WeightClass = "Giant"
			},
			RequiredAmount = 2,
			ForNpc = "Big Foot"
		}) },
	Rewards = {
		{ "LocalCurrency", "Sunshells", 300 },
		{ "Xp", 1000 }
	},
	InitialDialog = {
		"Hey, have you seen my flip-flops?",
		"They, uh, have eyes...",
		"And they're kinda fishy...",
		"And veeery big..."
	},
	InProgressDialog = { "Did you find my missing flip-flops?" },
	PostCompleteDialog = { "Thanks for finding my flip-flops!" }
}

for k, v69 in v do
	if fischfestSide5[k] == nil then
		fischfestSide5[k] = v69
	end
end

SimpleFetchQuests.FischfestSide5 = fischfestSide5
local fischfestSide6 = {
	QuestName = "Fischfest 2026: Finn Carter",
	Location = "Fischfest",
	Objectives = { module.ObtainItem({
			Item = "Chillin' Crab",
			RequiredAmount = 5,
			ForNpc = "Finn Carter"
		}) },
	Rewards = {
		{ "LocalCurrency", "Sunshells", 100 },
		{ "Xp", 500 }
	},
	InitialDialog = { "hehe funny crab", "they kinda chill tho" },
	InProgressDialog = { "hehe funny crab", "they kinda chill tho" },
	PostCompleteDialog = { "hehe funny crab", "they kinda chill tho" }
}

for k, v70 in v do
	if fischfestSide6[k] == nil then
		fischfestSide6[k] = v70
	end
end

SimpleFetchQuests.FischfestSide6 = fischfestSide6
local fischfestSide7 = {
	QuestName = "Fischfest 2026: Hazel Moreno",
	Location = "Fischfest",
	Objectives = { module.ObtainItem({
			Item = "Beach Towel",
			RequiredAttributes = {
				WeightClass = "Giant"
			},
			RequiredAmount = 1,
			ForNpc = "Hazel Moreno"
		}) },
	Rewards = {
		{ "LocalCurrency", "Sunshells", 400 },
		{ "Xp", 2000 }
	},
	InitialDialog = {
		"I've been looking for an area to lay down on the beach, but it's way too crowded!",
		"Could you bring me a Giant Beach Towel so I can make myself a spot?"
	},
	InProgressDialog = { "Did you find a Giant Beach Towel?" },
	PostCompleteDialog = { "Thank you so much! I can finally give my legs a rest..." }
}

for k, v71 in v do
	if fischfestSide7[k] == nil then
		fischfestSide7[k] = v71
	end
end

SimpleFetchQuests.FischfestSide7 = fischfestSide7
local fischfestSide8 = {
	QuestName = "Fischfest 2026: Sammy Hark",
	Location = "Fischfest",
	Objectives = { module.ObtainItem({
			Item = "Sand-Sculpted Shark",
			RequiredAttributes = {
				Mutation = "Paradise"
			},
			RequiredAmount = 3,
			ForNpc = "Sammy Hark"
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Paradise Relic",
			{
				Weight = 20,
				Mutation = "Unsellable"
			},
			1
		},
		{ "LocalCurrency", "Sunshells", 500 },
		{ "Xp", 2500 }
	},
	InitialDialog = {
		"I've seen a lot of Sand-Sculpted Sharks swimming around...",
		"I really want to see a few of them up close! Could you bring me a few?"
	},
	InProgressDialog = { "Did you get some Sand-Sculpted Sharks?" },
	PostCompleteDialog = { "Thanks for the sharks!" }
}

for k, v72 in v do
	if fischfestSide8[k] == nil then
		fischfestSide8[k] = v72
	end
end

SimpleFetchQuests.FischfestSide8 = fischfestSide8
local fischfestSide9 = {
	QuestName = "Fischfest 2026: Alice Sands",
	Location = "Fischfest",
	Objectives = {
		module.ObtainItem({
			Item = "Tanning Oil",
			RequiredAmount = 1,
			ForNpc = "Alice Sands"
		}),
		module.ObtainItem({
			Item = "Portable Fan",
			RequiredAmount = 1,
			ForNpc = "Alice Sands"
		}),
		module.ObtainItem({
			Item = "Plastic Shovel",
			RequiredAmount = 1,
			ForNpc = "Alice Sands"
		}),
		module.ObtainItem({
			Item = "Disposable Camera",
			RequiredAmount = 1,
			ForNpc = "Alice Sands"
		}),
		module.ObtainItem({
			Item = "Sunscreen Spray",
			RequiredAmount = 1,
			ForNpc = "Alice Sands"
		}),
		module.ObtainItem({
			Item = "Beach Radio",
			RequiredAmount = 1,
			ForNpc = "Alice Sands"
		})
	},
	Rewards = {
		{
			"ItemOrFish",
			"Beached Relic",
			{
				Weight = 20,
				Mutation = "Unsellable"
			},
			1
		},
		{ "LocalCurrency", "Sunshells", 500 },
		{ "Xp", 2500 }
	},
	InitialDialog = {
		"I fell asleep by the beach and a wave washed all my things out...",
		"If you find them, can you bring them back?"
	},
	InProgressDialog = { "Did you find my lost items?" },
	PostCompleteDialog = { "Thanks for finding my lost stuff!" }
}

for k, v73 in v do
	if fischfestSide9[k] == nil then
		fischfestSide9[k] = v73
	end
end

SimpleFetchQuests.FischfestSide9 = fischfestSide9
local fischfestSide10 = {
	QuestName = "Fischfest 2026: Coral Bennett",
	Location = "Fischfest",
	Objectives = { module.ObtainItem({
			Item = "Lemonade",
			RequiredAmount = 6,
			ForNpc = "Coral Bennett"
		}), module.ObtainItem({
			Item = "Slushy",
			RequiredAmount = 6,
			ForNpc = "Coral Bennett"
		}) },
	Rewards = {
		{ "LocalCurrency", "Sunshells", 300 },
		{ "Xp", 1000 }
	},
	InitialDialog = {
		"I'm super thirsty, but I don't want to lose my seat at the beach to get to the Tiki Hut...",
		"If you come across some refreshing drinks, do you mind bringing me some?"
	},
	InProgressDialog = { "Did you find some drinks?" },
	PostCompleteDialog = { "Thanks for the refreshments!" }
}

for k, v74 in v do
	if fischfestSide10[k] == nil then
		fischfestSide10[k] = v74
	end
end

SimpleFetchQuests.FischfestSide10 = fischfestSide10
local fischfestSide11 = {
	QuestName = "Fischfest 2026: Wave",
	Location = "Fischfest",
	Objectives = {
		module.ObtainItem({
			Item = "Rock",
			RequiredAttributes = {
				Mutation = "Tanned"
			},
			RequiredAmount = 10,
			ForNpc = "Wave"
		}),
		module.ObtainItem({
			Item = "Rock",
			RequiredAttributes = {
				Mutation = "Super-Tanned"
			},
			RequiredAmount = 1,
			ForNpc = "Wave"
		}),
		module.ObtainItem({
			Item = "Rock",
			RequiredAttributes = {
				Mutation = "Beached"
			},
			RequiredAmount = 20,
			ForNpc = "Wave"
		}),
		module.ObtainItem({
			Item = "Rock",
			RequiredAttributes = {
				Mutation = "Tropical"
			},
			RequiredAmount = 20,
			ForNpc = "Wave"
		}),
		module.ObtainItem({
			Item = "Rock",
			RequiredAttributes = {
				Mutation = "Paradise"
			},
			RequiredAmount = 20,
			ForNpc = "Wave"
		}),
		module.ObtainItem({
			Item = "Rock",
			RequiredAttributes = {
				Mutation = "Splashed"
			},
			RequiredAmount = 20,
			ForNpc = "Wave"
		}),
		module.ObtainItem({
			Item = "Rock",
			RequiredAttributes = {
				Mutation = "Tiki"
			},
			RequiredAmount = 20,
			ForNpc = "Wave"
		}),
		module.ObtainItem({
			Item = "Rock",
			RequiredAttributes = {
				Mutation = "Creamsicle"
			},
			RequiredAmount = 20,
			ForNpc = "Wave"
		}),
		module.ObtainItem({
			Item = "Rock",
			RequiredAttributes = {
				Mutation = "Floatie"
			},
			RequiredAmount = 10,
			ForNpc = "Wave"
		}),
		module.ObtainItem({
			Item = "Rock",
			RequiredAttributes = {
				Mutation = "Beach Ball"
			},
			RequiredAmount = 10,
			ForNpc = "Wave"
		}),
		module.ObtainItem({
			Item = "Rock",
			RequiredAttributes = {
				Mutation = "Starshell"
			},
			RequiredAmount = 20,
			ForNpc = "Wave"
		}),
		module.ObtainItem({
			Item = "Rock",
			RequiredAttributes = {
				Mutation = "Sand Castled"
			},
			RequiredAmount = 20,
			ForNpc = "Wave"
		}),
		module.ObtainItem({
			Item = "Rock",
			RequiredAttributes = {
				Mutation = "Lemon"
			},
			RequiredAmount = 20,
			ForNpc = "Wave"
		})
	},
	Rewards = {
		{ "Skin", "Wave Rod" },
		{
			"ItemOrFish",
			"Tropical Relic",
			{
				Weight = 20,
				Mutation = "Unsellable"
			},
			1
		},
		{
			"ItemOrFish",
			"Tropical Sun Totem",
			nil,
			1
		},
		{ "LocalCurrency", "Sunshells", 5000 },
		{ "Xp", 100000 }
	},
	InitialDialog = {
		"STONE STONE STONE!",
		"ME LOVE ROCKS! WANT TROPICAL ROCKS!",
		"SPLASHED ROCKS! SANDY ROCKS! FLOATING ROCKS!",
		"ME WANT ALL ROCK!"
	},
	AcceptOption = "You again? Seriously?!",
	DeclineOption = "Absolutely not.",
	AcceptDialog = { "?", "ME NOT DAVE. ME <b>WAVE</b>.", "ME NO WANT BOULDER. ONLY ROCK." },
	InProgressDialog = { "WHERE ROCKS?" },
	GiveOption = "Here's your rocks...",
	CancelOption = "Still working on it...",
	CompleteDialog = { "TROPICAL ROCK MOUNTAIN!" },
	IncompleteDialog = { "NO ROCK?" },
	PostCompleteDialog = { "HAVE ALL ROCK. HAPPY." }
}

for k, v75 in v do
	if fischfestSide11[k] == nil then
		fischfestSide11[k] = v75
	end
end

SimpleFetchQuests.FischfestSide11 = fischfestSide11
local fischfestSide12 = {
	QuestName = "Fischfest 2026: Ice Cream Party",
	Location = "Fischfest",
	Objectives = { module.ObtainItem({
			Item = "Ice Cream Carp",
			RequiredAmount = 4,
			ForNpc = "Jake"
		}), module.ObtainItem({
			Item = "Popsicle Pike",
			RequiredAmount = 2,
			ForNpc = "Jake"
		}) },
	Rewards = {
		{ "LocalCurrency", "Sunshells", 300 },
		{ "Xp", 1000 }
	},
	InitialDialog = { "I shout for Ice Cream!!!" },
	InProgressDialog = { "I shout for Ice Cream!!!" },
	PostCompleteDialog = { "thanks dude I'm gonna eat this all at onc- AHH BRAINFREEZE" }
}

for k, v76 in v do
	if fischfestSide12[k] == nil then
		fischfestSide12[k] = v76
	end
end

SimpleFetchQuests.FischfestSide12 = fischfestSide12
local fischfestSide13 = {
	QuestName = "Fischfest 2026: Dylan Shore",
	Location = "Fischfest",
	Objectives = { module.ObtainItem({
			Item = "Water Balloon",
			RequiredAmount = 4,
			ForNpc = "Dylan Shore"
		}) },
	Rewards = {
		{ "LocalCurrency", "Sunshells", 300 },
		{ "Xp", 1000 }
	},
	InitialDialog = {
		"It sure is hot out today, isn't it?",
		"My friends and I want to have a water balloon fight.",
		"Have you seen any Water Balloons around?"
	},
	InProgressDialog = { "Did you find any Water Baloons?" },
	PostCompleteDialog = { "It sure is hot out today, isn't it?" }
}

for k, v77 in v do
	if fischfestSide13[k] == nil then
		fischfestSide13[k] = v77
	end
end

SimpleFetchQuests.FischfestSide13 = fischfestSide13
local fischfestSide14 = {
	QuestName = "Fischfest 2026: Pufferfish Collection",
	Location = "Fischfest",
	Objectives = {
		module.ObtainItem({
			Item = "Picnic Pufferfish",
			RequiredAmount = 1,
			ForNpc = "Nina"
		}),
		module.ObtainItem({
			Item = "Picnic Pufferfish",
			RequiredAttributes = {
				Shiny = true
			},
			RequiredAmount = 1,
			ForNpc = "Nina"
		}),
		module.ObtainItem({
			Item = "Floatie Fugu",
			RequiredAmount = 1,
			ForNpc = "Nina"
		}),
		module.ObtainItem({
			Item = "Floatie Fugu",
			RequiredAttributes = {
				Shiny = true
			},
			RequiredAmount = 1,
			ForNpc = "Nina"
		})
	},
	Rewards = {
		{ "LocalCurrency", "Sunshells", 300 },
		{ "Xp", 1000 }
	},
	InitialDialog = {
		"Hey, I'm here on behalf of Dr. Monty.",
		"I heard there is a new species that have swam in this summer.",
		"Can you help me collect a few?"
	},
	InProgressDialog = { "Did you get those pufferfish?" },
	PostCompleteDialog = { "I'll make sure to put in a good word for you with Monty.", "You may well need it..." }
}

for k, v78 in v do
	if fischfestSide14[k] == nil then
		fischfestSide14[k] = v78
	end
end

SimpleFetchQuests.FischfestSide14 = fischfestSide14
local fischfestSide15 = {
	QuestName = "Fischfest 2026: Tropical Troy",
	Location = "Fischfest",
	Objectives = { module.ObtainItem({
			Item = "Beach Bucket",
			RequiredAttributes = {
				Shiny = true
			},
			RequiredAmount = 1,
			ForNpc = "Tropical Troy"
		}) },
	Rewards = {
		{ "LocalCurrency", "Sunshells", 300 },
		{ "Xp", 1000 }
	},
	InitialDialog = {
		"Shoot, I spilled my water on the sand!",
		"This is bad! What if someone uh",
		"Gets wet! at the beach",
		"This is a real hazard! I need a warning sign ASAP!"
	},
	InProgressDialog = { "Did you get the hazard sign?" },
	PostCompleteDialog = { "Phew! Crisis averted!" }
}

for k, v79 in v do
	if fischfestSide15[k] == nil then
		fischfestSide15[k] = v79
	end
end

SimpleFetchQuests.FischfestSide15 = fischfestSide15
local fischfestSide16 = {
	QuestName = "Fischfest 2026: Cool and Cooler",
	Location = "Fischfest",
	Objectives = { module.ObtainItem({
			Item = "Catfish",
			RequiredAttributes = {
				Mutation = "Frozen"
			},
			RequiredAmount = 1,
			ForNpc = "Skye Palmer"
		}), module.ObtainItem({
			Item = "Cooler Catfish",
			RequiredAmount = 1,
			ForNpc = "Skye Palmer"
		}) },
	Rewards = {
		{ "LocalCurrency", "Sunshells", 300 },
		{ "Xp", 1000 }
	},
	InitialDialog = { "Yo, I'm lookin' for the Coolest Catfish around.", "Think you can get some?" },
	InProgressDialog = { "Did you get those Cool Catfish?" },
	PostCompleteDialog = { "These are some pretty Cool Catfish. Thanks." }
}

for k, v80 in v do
	if fischfestSide16[k] == nil then
		fischfestSide16[k] = v80
	end
end

SimpleFetchQuests.FischfestSide16 = fischfestSide16
local fischfestSide17 = {
	QuestName = "Fischfest 2026: Owen Drift",
	Location = "Fischfest",
	DisplayObjectives = {
		{ "Custom", 5, "Obtain 5 Tomatoes...?" }
	},
	Objectives = { module.ObtainItem({
			Item = "Water Balloon",
			RequiredAttributes = {
				Shiny = true
			},
			RequiredAmount = 5,
			ForNpc = "Owen Drift"
		}) },
	Rewards = {
		{ "LocalCurrency", "Sunshells", 500 },
		{ "Xp", 2500 }
	},
	InitialDialog = { "Psst. I need tomatoes. Don't ask why." },
	InProgressDialog = { "Got the tomatoes?" },
	PostCompleteDialog = { "Perfect, perfect... We never saw each other." }
}

for k, v81 in v do
	if fischfestSide17[k] == nil then
		fischfestSide17[k] = v81
	end
end

SimpleFetchQuests.FischfestSide17 = fischfestSide17
local fischfestSide18 = {
	QuestName = "Fischfest 2026: Lifeguard Lisa",
	Location = "Fischfest",
	DisplayObjectives = {
		{ "Custom", 5, "Retrieve the \"assistant lifeguards\"" }
	},
	Objectives = { module.ObtainItem({
			Item = "Lifeguard Lobster",
			RequiredAmount = 5,
			ForNpc = "Lifeguard Lisa"
		}) },
	Rewards = {
		{ "LocalCurrency", "Sunshells", 250 },
		{ "Xp", 1500 }
	},
	InitialDialog = {
		"Help! My Assistant Lifeguards scuttered off while I wasn't looking!",
		"This is really bad... What will I do without them?",
		"Please, could you help me find them?"
	},
	InProgressDialog = { "Did you find my assistants?" },
	PostCompleteDialog = { "Amazing! My assistants are all back!" }
}

for k, v82 in v do
	if fischfestSide18[k] == nil then
		fischfestSide18[k] = v82
	end
end

SimpleFetchQuests.FischfestSide18 = fischfestSide18
local fischfestSide19 = {
	QuestName = "Fischfest 2026: Sunslasher Hunting",
	Location = "Fischfest",
	Objectives = { module.CatchFishAny({
			Fish = "Sunslasher",
			RequiredAmount = 1
		}) },
	Rewards = {
		{ "LocalCurrency", "Sunshells", 250 },
		{ "Xp", 1500 }
	},
	InitialDialog = { "Sunslashers lurk in these waters...", "We must keep the people safe. Will you do your part?" },
	InProgressDialog = { "Got the Sunslasher?" },
	PostCompleteDialog = { "You've done well." }
}

for k, v83 in v do
	if fischfestSide19[k] == nil then
		fischfestSide19[k] = v83
	end
end

SimpleFetchQuests.FischfestSide19 = fischfestSide19
local fischfestSide20 = {
	QuestName = "Fischfest 2026: guy that wants a really big lemonade",
	Location = "Fischfest",
	Objectives = { module.ObtainItem({
			Item = "Lemonade",
			RequiredAttributes = {
				WeightClass = "Giant"
			},
			RequiredAmount = 1,
			ForNpc = "guy that wants a really big lemonade"
		}) },
	Rewards = {
		{ "LocalCurrency", "Sunshells", 150 },
		{ "Xp", 500 }
	},
	InitialDialog = { "im the guy that wants a really big lemonade" },
	InProgressDialog = { "did you get the really big lemonade" },
	PostCompleteDialog = { "thanks for the really big lemonade" }
}

for k, v84 in v do
	if fischfestSide20[k] == nil then
		fischfestSide20[k] = v84
	end
end

SimpleFetchQuests.FischfestSide20 = fischfestSide20
v = {
	Icon = "rbxassetid://18162767851"
}
SimpleFetchQuests._ = nil
local carbon = {
	QuestName = "Carbon's Snack Emergency",
	Location = "The Bunker",
	NoNavigate = true,
	IconColor = Color3.fromRGB(255, 138, 32),
	Type = "Major",
	QuestDescription = "Carbon knows exactly where the last Bag of Chips is. He is not going to get up. Grab it for him.",
	CompleteDescription = "You got the chips. Bring them back to Carbon.",
	Objectives = { module.ObtainItem({
			Item = "Bag of Chips",
			RequiredAmount = 1,
			ForNpc = "Carbon"
		}) },
	Rewards = {
		{ "Rod", "Cheeto Rod" },
		{ "Xp", 25000 }
	},
	InitialDialog = {
		"Oh... hey. Didn't expect visitors down here.",
		"Sorry about the mess. I've been taking a little break from making Fisch videos.",
		"Hey, uh... could I ask you for a small favor?",
		"There's one last <b>Bag of Chips</b>, somewhere around here...",
		"I think one of them no-clip'd through a wall?",
		"I've been thinking about it for three days.",
		"I'd get it myself, but... you know. I'm comfortable."
	},
	AcceptOption = "Sure, I'll find you some.",
	DeclineOption = "Maybe later.",
	AcceptDialog = { "Really? Thank you.", "Take your time. I'm not going anywhere." },
	DeclineDialog = { "No worries. I'll just... sit here." },
	InProgressDialog = { "It's still in the closet. I can feel it." },
	GiveOption = "Here you go.",
	CancelOption = "Not yet.",
	IncompleteDialog = { "Hmm... I don't see any chips on you.", "It's okay. Take your time." },
	CompleteDialog = {
		"Oh! You actually found some.",
		"*cronch*",
		"...",
		"That hit the spot. Thank you, seriously.",
		"Here, I want you to have something in return.",
		"It's a cheeto. Well... it's also a fishing rod.",
		"I made it myself. Don't worry about how.",
		"*yawn*... sorry... I get sleepy after I eat..."
	},
	PostCompleteDialog = { "Zzz...", "*snore*... five more minutes...", "Zzz..." }
}

for k, v85 in v do
	if carbon[k] == nil then
		carbon[k] = v85
	end
end

SimpleFetchQuests.Carbon = carbon
local doug = {
	QuestName = "Doug's Great \"Heist\"",
	Location = "The Labaratory",
	IconColor = Color3.fromRGB(255, 130, 130),
	Type = "Major",
	CompleteDescription = "You got everything Doug wanted... Hopefully he'll actually honor that agreement.",
	Objectives = {
		module.CatchFishAny({
			Fish = "Glass Diamond",
			RequiredAmount = 1,
			AndReturn = true
		}),
		module.ObtainItem({
			Item = "Opal",
			RequiredAmount = 1,
			ForNpc = "Doug"
		}),
		module.ObtainItem({
			Item = "Ruby",
			RequiredAmount = 1,
			ForNpc = "Doug"
		}),
		module.ObtainItem({
			Item = "Amethyst",
			RequiredAmount = 3,
			ForNpc = "Doug"
		}),
		module.CatchFishAny({
			Fish = "Scrap Metal",
			RequiredAmount = 2,
			RequiredAttributes = {
				Mutation = "Gravitas"
			},
			AndReturn = true
		})
	},
	Rewards = {
		{ "Rod", "Crowbar" },
		{ "Xp", 10000 }
	},
	InitialDialog = {
		"Turns out these Scientists are more broke than I am...",
		module.playerReply("That's saying something.", "Okay bye"),
		"Tell me about it. I tried robbing them and nearly walked out feeling guilty.",
		module.playerReply("How'd that happen?", "...I'm leaving."),
		"I snuck into their lab expecting something valuable...",
		"...but the only thing there was worth even looking at was just stupid nerd stuff.",
		module.playerReply("Who are these Scientists again?"),
		"Dr. Glimmerfin and Dr. Crookspine, brightest minds of the seas apparently.",
		"Uh... I've got a better idea.",
		"How about you bring me what I <i>thought</i> they would have?",
		"I'll call the robbery off, and I'll give you my <b>Crowbar</b>.",
		"Seems like a fair trade to me."
	},
	AcceptOption = "Deal.",
	DeclineOption = "I'm not helping a criminal.",
	AcceptDialog = { "Knew you'd see it my way." },
	DeclineDialog = { "...Fair enough. You're missing out, though." },
	InProgressDialog = { "You got the goods?" },
	GiveOption = "Here you go.",
	CancelOption = "Still looking.",
	IncompleteDialog = { "...Doesn't look like it.", "Come back when you've got what I wanted." },
	CompleteDialog = {
		"Well I'll be...",
		"You actually brought exactly what I wanted!",
		"Guess Dr. Glimmerfin and Dr. Crookspine get to keep the little that they own...",
		"..and I get to keep my dignity.",
		"Mostly.",
		module.playerReply("A deal's a deal."),
		"Right you are.",
		"Here's my <b>Crowbar</b>.",
		"It's opened a lot of doors... Mostly ones that weren't mine."
	},
	PostCompleteDialog = { "Who knew that our top scientists would be so broke..." }
}

for k, v86 in v do
	if doug[k] == nil then
		doug[k] = v86
	end
end

SimpleFetchQuests.Doug = doug
local astralCorvus = {
	QuestName = "Anomaly Investigation: Containing the Stellar Void",
	Location = "Abyssal Zenith",
	IconColor = Color3.fromRGB(207, 149, 255),
	Type = "Major",
	Objectives = {
		module.CatchFishAny({
			Fish = "Crowned Anglerfish",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Celestial",
				ShinyOrSparkling = true
			},
			AndReturn = true
		}),
		module.CatchFishAny({
			Fish = "Hardened Glass",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Nova"
			},
			AndReturn = true
		}),
		module.CatchFishAny({
			Fish = "Gold Piece",
			RequiredAmount = 12,
			RequiredAttributes = {
				Mutation = "Nova"
			},
			AndReturn = true
		}),
		module.CatchFishAny({
			Fish = "Scrap Metal",
			RequiredAmount = 12,
			RequiredAttributes = {
				Mutation = "Celestial"
			},
			AndReturn = true
		})
	},
	Rewards = {
		{
			"ItemOrFish",
			"Dyson Sphere",
			{},
			1
		}
	},
	InitialDialog = {
		"The abyss... isn't it quiet down here?",
		"Of course, no one person can ever hope of harnessing its power down here...",
		"But... What about from... <i>above</i>?"
	},
	AcceptOption = "I'm listening.",
	DeclineOption = "I'm not interested.",
	AcceptDialog = { "Then, let's find a way to harness it together." },
	DeclineDialog = { "Then we never met." },
	InProgressDialog = { "Is it done?" },
	GiveOption = "Here you go.",
	CancelOption = "Still working on it.",
	IncompleteDialog = { "No. There's something missing..." },
	CompleteDialog = {
		"Perfect... everything is perfectly aligned.",
		"The power of the Cosmic Abyss... in mortal hands.",
		"For your assistance, allow me to share this power with you."
	},
	PostCompleteDialog = { "The Cosmic Abyss... can you hear its calling too?" }
}

for k, v87 in v do
	if astralCorvus[k] == nil then
		astralCorvus[k] = v87
	end
end

SimpleFetchQuests.AstralCorvus = astralCorvus
v = {
	IconColor = Color3.fromRGB(198, 233, 255),
	Location = "Skycrest"
}
SimpleFetchQuests._ = nil
local hana = {
	QuestName = "Skycrest: Hana",
	Objectives = { module.CatchFishAny({
			Fish = "Celestial Pearl Danio",
			RequiredAmount = 3,
			AndReturn = true
		}) },
	Rewards = {
		{ "IdolFavor", 300 }
	},
	InitialDialog = {
		"My brother says the danios up here glow like little stars at night.",
		"I want to see for myself! Could you catch me three Celestial Pearl Danios?"
	},
	InProgressDialog = { "Did you find the Celestial Pearl Danios?" },
	CompleteDialog = { "They really do sparkle! Thank you!", "The idols would be pleased with you. Take this favor." },
	PostCompleteDialog = { "I keep them in a jar by my window now. They glow all night." }
}

for k, v88 in v do
	if hana[k] == nil then
		hana[k] = v88
	end
end

SimpleFetchQuests.Hana = hana
local oldBenzo = {
	QuestName = "Skycrest: Old Benzo",
	Objectives = { module.CatchFishAny({
			Fish = "Ruby Neon Eviota",
			RequiredAmount = 2,
			AndReturn = true
		}) },
	Rewards = {
		{ "IdolFavor", 350 }
	},
	InitialDialog = {
		"Wheat won't grow this high up. Believe me, I've tried for forty years.",
		"The fish, though... the fish grow just fine. Bring me two Ruby Neon Eviotas and I'll put in a good word with the idols."
	},
	InProgressDialog = { "Got my Ruby Neon Eviotas yet?" },
	CompleteDialog = { "Ha! Look at the red on those. Beats wheat any day." },
	PostCompleteDialog = { "Maybe I'll try growing fish instead. Can't be harder than wheat." }
}

for k, v89 in v do
	if oldBenzo[k] == nil then
		oldBenzo[k] = v89
	end
end

SimpleFetchQuests["Old Benzo"] = oldBenzo
local dockhandRin = {
	QuestName = "Skycrest: Dockhand Rin",
	Objectives = { module.CatchFishAny({
			Fish = "Moenkhausia Pitanga",
			RequiredAmount = 3,
			AndReturn = true
		}) },
	Rewards = {
		{ "IdolFavor", 400 }
	},
	InitialDialog = {
		"Vance has me hauling crates from sunrise to sunset. No time to fish.",
		"Could you bring me three Moenkhausia Pitangas? The crew's been asking for a proper meal."
	},
	InProgressDialog = { "Any luck with the Moenkhausia Pitangas?" },
	CompleteDialog = { "That's dinner sorted. The crew owes you one, and so do I." },
	PostCompleteDialog = { "Back to the crates. Always more crates." }
}

for k, v90 in v do
	if dockhandRin[k] == nil then
		dockhandRin[k] = v90
	end
end

SimpleFetchQuests["Dockhand Rin"] = dockhandRin
local tobi = {
	QuestName = "Skycrest: Tobi",
	Objectives = { module.CatchFishAny({
			Fish = "Dwarf Pea Puffer",
			RequiredAmount = 2,
			AndReturn = true
		}) },
	Rewards = {
		{ "IdolFavor", 450 }
	},
	InitialDialog = {
		"Kestrel bet me I couldn't catch a Dwarf Pea Puffer. I caught zero.",
		"If you bring me two, I can say I caught them. Please? I'll share the favor."
	},
	AcceptOption = "Your secret is safe.",
	InProgressDialog = { "Did you get the Dwarf Pea Puffers? Quietly?" },
	CompleteDialog = { "Two whole puffers! Kestrel is going to be so annoyed." },
	PostCompleteDialog = { "Kestrel still doesn't believe me. Worth it." }
}

for k, v91 in v do
	if tobi[k] == nil then
		tobi[k] = v91
	end
end

SimpleFetchQuests.Tobi = tobi
local wandererKestrel = {
	QuestName = "Skycrest: Wanderer Kestrel",
	Objectives = { module.CatchFishAny({
			Fish = "Populi Blind Catfish",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Gusty"
			},
			AndReturn = true
		}) },
	Rewards = {
		{ "IdolFavor", 900 }
	},
	InitialDialog = {
		"I've walked every island in the sea, and none of them have wind like this.",
		"They say the gusts get into the fish here. Bring me a Gusty Populi Blind Catfish and I'll believe it."
	},
	InProgressDialog = { "Found a Gusty Populi Blind Catfish yet?" },
	CompleteDialog = {
		"It's still twitching like it wants to fly. Incredible.",
		"You've earned some favor with the idols for this."
	},
	PostCompleteDialog = { "Maybe I'll stay a while. The wind suits me." }
}

for k, v92 in v do
	if wandererKestrel[k] == nil then
		wandererKestrel[k] = v92
	end
end

SimpleFetchQuests["Wanderer Kestrel"] = wandererKestrel
local scribeUme = {
	QuestName = "Skycrest: Scribe Ume",
	Objectives = { module.CatchFishAny({
			RequiredAmount = 3,
			RequiredAttributes = {
				Mutation = "Gusty"
			},
			FishingZones = "Skycrest"
		}) },
	Rewards = {
		{ "IdolFavor", 1000 }
	},
	InitialDialog = {
		"I'm cataloguing how the high winds change our fish. My notes are thin.",
		"Catch any three Gusty fish from Skycrest's pools and tell me what you find. Any species will do."
	},
	InProgressDialog = { "Have you gathered three Gusty fish?" },
	CompleteDialog = {
		"Three specimens! This chapter is finally complete.",
		"Take this favor. The idols reward those who help us understand them."
	},
	PostCompleteDialog = { "Chapter four is about the squalls. I'll need a braver assistant for that." }
}

for k, v93 in v do
	if scribeUme[k] == nil then
		scribeUme[k] = v93
	end
end

SimpleFetchQuests["Scribe Ume"] = scribeUme
local carpenterDoma = {
	QuestName = "Skycrest: Carpenter Doma",
	Objectives = { module.CatchFishAny({
			Fish = "African Butterflyfish",
			RequiredAmount = 2,
			AndReturn = true
		}), module.CatchFishAny({
			Fish = "Myloplus Sauron",
			RequiredAmount = 1,
			AndReturn = true
		}) },
	Rewards = {
		{ "IdolFavor", 1000 }
	},
	InitialDialog = {
		"Every fence on this island is mine. Every one. And the wind keeps knocking them down.",
		"I need a break. Two African Butterflyfish and a Myloplus Sauron would make a fine supper."
	},
	InProgressDialog = { "Got the butterflyfish and the Sauron?" },
	CompleteDialog = { "Now that's a meal worth putting the hammer down for." },
	PostCompleteDialog = { "Another fence went down last night. I'll get to it." }
}

for k, v94 in v do
	if carpenterDoma[k] == nil then
		carpenterDoma[k] = v94
	end
end

SimpleFetchQuests["Carpenter Doma"] = carpenterDoma
local inspectorHalden = {
	QuestName = "Skycrest: Inspector Halden",
	Objectives = { module.CatchFishAny({
			Fish = "Pink-Spotted Shrimpgoby",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Idol's Spirit"
			},
			AndReturn = true
		}) },
	Rewards = {
		{ "IdolFavor", 1200 }
	},
	InitialDialog = {
		"I'm investigating the idols. Officially. Don't ask who sent me.",
		"I need evidence they touch the fish. A Pink-Spotted Shrimpgoby carrying an Idol's Spirit should do."
	},
	AcceptOption = "I'll find your evidence.",
	DeclineOption = "I'd rather not get involved.",
	DeclineDialog = { "Wise. Or cowardly. I haven't decided." },
	InProgressDialog = { "Do you have the Idol's Spirit Shrimpgoby?" },
	CompleteDialog = {
		"Look at it. That's not natural. That's... something else.",
		"Case closed. Or opened. Either way, take this."
	},
	PostCompleteDialog = { "My report has been filed. Nobody has read it." }
}

for k, v95 in v do
	if inspectorHalden[k] == nil then
		inspectorHalden[k] = v95
	end
end

SimpleFetchQuests["Inspector Halden"] = inspectorHalden
local sunhatMio = {
	QuestName = "Skycrest: Sunhat Mio",
	ExpiresAt = DateTime.fromUniversalTime(2026, 9, 12, 16),
	Objectives = { module.CatchFishAny({
			Fish = "Pineapple Pufferfish",
			RequiredAmount = 1,
			AndReturn = true
		}), module.CatchFishAny({
			Fish = "Banana Eel",
			RequiredAmount = 1,
			AndReturn = true
		}) },
	Rewards = {
		{ "IdolFavor", 1200 }
	},
	InitialDialog = {
		"When the Tropical Sun comes out, the pools fill with the strangest fish. Fruit fish!",
		"I want a Pineapple Pufferfish and a Banana Eel for my fruit stand. Nobody will believe it otherwise."
	},
	InProgressDialog = { "Did the Tropical Sun bring you my fruit fish?" },
	CompleteDialog = { "A pufferfish that smells like pineapple! Frank is going to lose his mind." },
	PostCompleteDialog = { "Frank offered to buy them. I said no. They're display only." }
}

for k, v96 in v do
	if sunhatMio[k] == nil then
		sunhatMio[k] = v96
	end
end

SimpleFetchQuests["Sunhat Mio"] = sunhatMio
local lookoutSuzu = {
	QuestName = "Skycrest: Lookout Suzu",
	Objectives = { module.CatchFishAny({
			Fish = "Hawaiian Ventralis Anthias",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Squalled"
			},
			AndReturn = true
		}) },
	Rewards = {
		{ "IdolFavor", 2000 },
		{
			"ItemOrFish",
			"Tropical Squall Totem",
			{},
			1
		}
	},
	InitialDialog = {
		"From up here I can see the squalls coming hours before they hit.",
		"I've always wondered what they do to the fish. Bring me a Squalled Hawaiian Ventralis Anthias and I'll give you something to call a squall of your own."
	},
	InProgressDialog = { "Did you brave a squall for that Anthias?" },
	CompleteDialog = {
		"It's still crackling. You fished through a squall for this.",
		"Here. This totem calls a Tropical Squall. Use it wisely."
	},
	PostCompleteDialog = { "Clear skies today. Give it an hour." }
}

for k, v97 in v do
	if lookoutSuzu[k] == nil then
		lookoutSuzu[k] = v97
	end
end

SimpleFetchQuests["Lookout Suzu"] = lookoutSuzu
local stonecutterGaro = {
	QuestName = "Skycrest: Stonecutter Garo",
	Objectives = { module.CatchFishAny({
			RequiredAmount = 2,
			RequiredAttributes = {
				Mutation = "Petrified"
			},
			FishingZones = "Skycrest"
		}) },
	Rewards = {
		{ "IdolFavor", 2000 },
		{
			"ItemOrFish",
			"Crested Relic",
			{},
			1
		}
	},
	InitialDialog = {
		"I carved half the idols on this island. My hands know stone.",
		"But a fish turned to stone? That I've never seen. Catch two Petrified fish from Skycrest, show me, and I'll part with a relic I dug up years ago."
	},
	InProgressDialog = { "Have you found two Petrified fish?" },
	CompleteDialog = {
		"Solid through. Not a crack in them. The idols do fine work.",
		"A deal is a deal. This relic is yours."
	},
	PostCompleteDialog = { "I'm going to carve a fish next. Might as well." }
}

for k, v98 in v do
	if stonecutterGaro[k] == nil then
		stonecutterGaro[k] = v98
	end
end

SimpleFetchQuests["Stonecutter Garo"] = stonecutterGaro
local pilgrimSable = {
	QuestName = "Skycrest: Pilgrim Sable",
	Objectives = { module.CatchFishAny({
			Fish = "Vibranium Fairy Wrasse",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Idol's Spirit"
			},
			AndReturn = true
		}) },
	Rewards = {
		{ "IdolFavor", 2500 },
		{
			"ItemOrFish",
			"Raging Squall Totem",
			{},
			1
		}
	},
	InitialDialog = {
		"I climbed here to be closer to the idols. They have not spoken to me yet.",
		"Perhaps an offering. A Vibranium Fairy Wrasse carrying an Idol's Spirit. Bring me one and I will give you the storm I carried up the mountain."
	},
	InProgressDialog = { "Have the idols blessed a Vibranium Fairy Wrasse for you?" },
	CompleteDialog = {
		"I can feel it. They are listening now.",
		"This totem calls a Raging Squall. I no longer need it. You might."
	},
	PostCompleteDialog = { "The idols speak in the wind. I am learning to listen." }
}

for k, v99 in v do
	if pilgrimSable[k] == nil then
		pilgrimSable[k] = v99
	end
end

SimpleFetchQuests["Pilgrim Sable"] = pilgrimSable
local brotherKaede = {
	QuestName = "Skycrest: Brother Kaede",
	Objectives = { module.CatchFishAny({
			Fish = "Aphrodite Anthias",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Kaito's Blessing"
			},
			AndReturn = true
		}) },
	Rewards = {
		{ "IdolFavor", 3000 },
		{
			"ItemOrFish",
			"Empyrean Relic",
			{},
			1
		}
	},
	InitialDialog = {
		"Elder Kaito is my brother. He gets the shop, the blessing, the visitors. I get the quiet.",
		"Prove his blessing is real. Bring me an Aphrodite Anthias touched by Kaito's Blessing and I'll give you the one thing he never could."
	},
	InProgressDialog = { "Has my brother's blessing found an Aphrodite Anthias yet?" },
	CompleteDialog = {
		"So it is real. Good. He deserves it.",
		"This Empyrean Relic fell from the highest peak. Take it. It was never mine to keep."
	},
	PostCompleteDialog = { "I visited the shop today. He didn't recognize me at first." }
}

for k, v100 in v do
	if brotherKaede[k] == nil then
		brotherKaede[k] = v100
	end
end

SimpleFetchQuests["Brother Kaede"] = brotherKaede
local quartermasterBram = {
	QuestName = "Skycrest: Quartermaster Bram",
	Objectives = { module.CatchFishAny({
			Fish = "Rose-Veiled Fairy Wrasse",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Gusty"
			},
			AndReturn = true
		}), module.CatchFishAny({
			Fish = "Aphrodite Anthias",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Gusty"
			},
			AndReturn = true
		}) },
	Rewards = {
		{ "IdolFavor", 3500 }
	},
	InitialDialog = {
		"Kaito's shelves are bare and the Keeper wants a feast for the idols. Guess who has to source it.",
		"I need the finest the sky can offer. A Gusty Rose-Veiled Fairy Wrasse and a Gusty Aphrodite Anthias. Nothing less."
	},
	InProgressDialog = { "Do you have the Gusty Wrasse and the Gusty Anthias?" },
	CompleteDialog = {
		"Both of them. Both! The Keeper will be speechless, and that never happens.",
		"The idols will remember this. So will I."
	},
	PostCompleteDialog = { "The feast went well. The idols ate nothing, as usual." }
}

for k, v101 in v do
	if quartermasterBram[k] == nil then
		quartermasterBram[k] = v101
	end
end

SimpleFetchQuests["Quartermaster Bram"] = quartermasterBram

for k, _ in SimpleFetchQuests do
	if k == "_" then
		SimpleFetchQuests._ = nil
	end
end

return SimpleFetchQuests