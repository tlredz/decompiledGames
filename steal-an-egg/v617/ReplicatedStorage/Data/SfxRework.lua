local SfxRework = {
	NewAnimalSfx = true,
	NewCherryBlossomSfx = true
}
local frozen = table.freeze({
	Jump = "rbxassetid://129309431169075",
	GreetingRun = "rbxassetid://79491420286619",
	GreetingLove = "rbxassetid://77676139105429"
})
local frozen2 = table.freeze({
	Jump = "rbxassetid://109053220376598",
	GreetingRun = "rbxassetid://80470347388552",
	GreetingLove = "rbxassetid://82103733277956"
})
local frozen3 = table.freeze({
	["Alabaster Whale"] = table.freeze({
		Idle = 109084013864839
	}),
	["Alien Skeleton Boss"] = table.freeze({
		Walk = 85892053481113,
		Idle = 98648905921986
	}),
	Ankylosaurus = table.freeze({
		Walk = 87539099304537,
		Idle = 91147897361155
	}),
	["Ascended Vermilion Phoenix"] = table.freeze({
		Walk = 85249941990373,
		Idle = 116162430890513
	}),
	["Ash Gecko"] = table.freeze({
		Walk = 122588221392543,
		Idle = 139340174291871
	}),
	["Baby Aurora Dragon"] = table.freeze({
		Walk = 95640392463828,
		Idle = 99271197379717
	}),
	["Bananita Dolphinita"] = table.freeze({
		Walk = 124578818661623,
		Idle = 140355694088112
	}),
	Basilisk = table.freeze({
		Idle = 81960453819318
	}),
	Bear = table.freeze({
		Walk = 98962076190481,
		Idle = 127207447045739
	}),
	["Belula Beluga"] = table.freeze({
		Walk = 118667471602135,
		Idle = 90413578033778
	}),
	["Bomboclat Crocolat"] = table.freeze({
		Walk = 97704959570533,
		Idle = 71126963498892
	}),
	Bronto = table.freeze({
		Walk = 87512139889151,
		Idle = 75758812305276
	}),
	["Brr Brr Patapim"] = table.freeze({
		Walk = 87776860556516,
		Idle = 113732812225664
	}),
	["Burrowing Owl"] = table.freeze({
		Walk = 75259005316072,
		Idle = 92414641075249
	}),
	Camel = table.freeze({
		Walk = 75763741236219
	}),
	Catfish = table.freeze({
		Idle = 87747919169770
	}),
	["Cave Dragon"] = table.freeze({
		Walk = 139724850248238,
		Idle = 84365701151321
	}),
	Centapede = table.freeze({
		Walk = 97943735213732
	}),
	Cerberus = table.freeze({
		Walk = 103736662890224,
		Idle = 112652966180684
	}),
	Chicken = table.freeze({
		Walk = 77569052979374
	}),
	["Chillin Chilli"] = table.freeze({
		Walk = 118667471602135,
		Idle = 104388767547534
	}),
	Chimpanzee = table.freeze({
		Walk = 102126706547517,
		Idle = 140380957391871
	}),
	["Colossal Mammoth"] = table.freeze({
		Walk = 73924753601037,
		Idle = 109052627263741
	}),
	Crane = table.freeze({
		Walk = 89415448274930
	}),
	Crocodile = table.freeze({
		Walk = 97704959570533,
		Idle = 71126963498892
	}),
	["Cyclops Gorilla"] = table.freeze({
		Walk = 92160997537319,
		Idle = 104088414306613
	}),
	DeathstalkerScorpion = table.freeze({
		Walk = 137682861871003,
		Idle = 90970709685819
	}),
	DesertLark = table.freeze({
		Walk = 84310341547585,
		Idle = 129056410182887
	}),
	Dodo = table.freeze({
		Walk = 116675021133679,
		Idle = 91917802939931
	}),
	Dog = table.freeze({
		Walk = 109859077831837
	}),
	Dragon = table.freeze({
		Walk = 85249941990373,
		Idle = 99271197379717
	}),
	["Dream Axolotl"] = table.freeze({
		Walk = 82252285582806,
		Idle = 138943450824966
	}),
	Duckling = table.freeze({
		Walk = 84639143672331,
		Idle = 87598259027411
	}),
	["El Maja"] = table.freeze({
		Idle = 88927188226844
	}),
	["Ember Dragon"] = table.freeze({
		Walk = 95640392463828,
		Idle = 99271197379717
	}),
	["Eternal Lunar Dragon"] = table.freeze({
		Walk = 71370919924821,
		Idle = 109543717701603
	}),
	FennecFox = table.freeze({
		Walk = 75830491774531,
		Idle = 95694784081534
	}),
	["Finned Thresher"] = table.freeze({
		Idle = 92586563973540
	}),
	["Flaming Bull"] = table.freeze({
		Walk = 123565424234895,
		Idle = 73942787332078
	}),
	Frog = table.freeze({
		Walk = 98592829152488,
		Idle = 110446822397054
	}),
	["Galaxy Gecko"] = table.freeze({
		Walk = 122588221392543,
		Idle = 139340174291871
	}),
	Gorilla = table.freeze({
		Walk = 92160997537319,
		Idle = 104088414306613
	}),
	["Ice Dragon"] = table.freeze({
		Walk = 93258675255690,
		Idle = 77733562549629
	}),
	Irihorus = table.freeze({
		Walk = 95217113025089,
		Idle = 124949844244934
	}),
	Jerboa = table.freeze({
		Walk = 135431282574136,
		Idle = 129498646783866
	}),
	Kitsune = table.freeze({
		Walk = 130410188254836
	}),
	Koi = table.freeze({
		Walk = 91336069879459
	}),
	Kraken = table.freeze({
		Walk = 136575457054802,
		Idle = 95615102125339
	}),
	["La Vacca Saturno Saturnita"] = table.freeze({
		Walk = 121275249192606,
		Idle = 124578818661623
	}),
	["Lava Iguana"] = table.freeze({
		Walk = 132145651741965,
		Idle = 88149843107998
	}),
	["Lava frog"] = table.freeze({
		Walk = 98592829152488,
		Idle = 110446822397054
	}),
	Mammoth = table.freeze({
		Walk = 73924753601037,
		Idle = 109052627263741
	}),
	["Mangolini Parrochini"] = table.freeze({
		Walk = 118667471602135
	}),
	["Mire Fox"] = table.freeze({
		Walk = 72733661023288,
		Idle = 93011701238042
	}),
	Mosasaurus = table.freeze({
		Idle = 81960453819318
	}),
	["Oni Tiger"] = table.freeze({
		Walk = 114350383012530
	}),
	["Orangutini Ananassini"] = table.freeze({
		Walk = 136703842556018,
		Idle = 119425637805679
	}),
	Orca = table.freeze({
		Idle = 72265202988047
	}),
	Parrotfish = table.freeze({
		Idle = 87747919169770
	}),
	Penguin = table.freeze({
		Walk = 118893161321883,
		Idle = 126342128456953
	}),
	["Polar Bear"] = table.freeze({
		Walk = 98962076190481,
		Idle = 127207447045739
	}),
	Pterodactyl = table.freeze({
		Walk = 129027332074939,
		Idle = 91501424120077
	}),
	Raccoon = table.freeze({
		Walk = 93247766618772,
		Idle = 99003636968368
	}),
	Rattlesnake = table.freeze({
		Walk = 96852920499596,
		Idle = 86273497689098
	}),
	["Red Panda"] = table.freeze({
		Walk = 80776140827842
	}),
	["Sabertooth Tiger"] = table.freeze({
		Walk = 106128665613743,
		Idle = 76228157397099
	}),
	Salamander = table.freeze({
		Walk = 98528087932516
	}),
	["Sand Spider"] = table.freeze({
		Walk = 116105360458227,
		Idle = 108765457146691
	}),
	ScorchedDragon = table.freeze({
		Walk = 140401695659406,
		Idle = 99271197379717
	}),
	["Shadow Dragon"] = table.freeze({
		Walk = 95640392463828,
		Idle = 99271197379717
	}),
	["Snowy Owl"] = table.freeze({
		Walk = 96920277869957
	}),
	Spider = table.freeze({
		Walk = 95492669493151,
		Idle = 86585082706748
	}),
	Stag = table.freeze({
		Walk = 86323278444941
	}),
	["Strawberry Elephant"] = table.freeze({
		Walk = 73924753601037,
		Idle = 98860262183478
	}),
	Swan = table.freeze({
		Walk = 84639143672331,
		Idle = 124101960931522
	}),
	Swordfish = table.freeze({
		Idle = 72092807529166
	}),
	Tiger = table.freeze({
		Walk = 106128665613743,
		Idle = 76228157397099
	}),
	["Tob Tobi Tob Tob"] = table.freeze({
		Walk = 132784244995896,
		Idle = 103713074753122
	}),
	Toucan = table.freeze({
		Walk = 84310341547585
	}),
	Tralaledon = table.freeze({
		Walk = 111656068182484,
		Idle = table.freeze({ 85318836335134, 119220966165422 })
	}),
	Triceratops = table.freeze({
		Walk = 114321426046280,
		Idle = 89022502511741
	}),
	["Trulimero Trulicina"] = table.freeze({
		Idle = 89324287675790
	}),
	["Tung Tung Sahur"] = table.freeze({
		Walk = 87776860556516,
		Idle = 127535170649609
	}),
	Turtle = table.freeze({
		Walk = 96543613394996
	}),
	TyrannosaurusRex = table.freeze({
		Walk = 86392397661742,
		Idle = table.freeze({ 88194339648259, 106670433570032 })
	}),
	Unicorn = table.freeze({
		Walk = 93124590164789,
		Idle = 116297838397212
	}),
	["Void Dragon"] = table.freeze({
		Walk = 95640392463828,
		Idle = 99271197379717
	}),
	Walrus = table.freeze({
		Walk = 110863031812081
	}),
	Warden = table.freeze({
		Walk = 96852920499596,
		Idle = 86273497689098
	}),
	["Whale Shark"] = table.freeze({
		Idle = 109084013864839
	}),
	Yeti = table.freeze({
		Walk = 86923272173832,
		Idle = 140562418935008
	})
})
local frozen4 = table.freeze({
	Kitsune = true,
	["Snowy Owl"] = true,
	Koi = true,
	Salamander = true,
	["Oni Tiger"] = true,
	Stag = true,
	["Red Panda"] = true,
	["Baby Aurora Dragon"] = true,
	["Shadow Dragon"] = true,
	["Ember Dragon"] = true,
	["Void Dragon"] = true,
	ScorchedDragon = true
})
local frozen5 = table.freeze({
	Crane = 84639143672331
})
SfxRework.GuardFootstepLegacy = "rbxassetid://85892053481113"
SfxRework.GuardFootstepNew = "rbxassetid://114350383012530"

local function withId(p, soundId)
	if soundId == nil or p == nil then
		return nil
	end

	if soundId == p.SoundId then
		return p
	end

	return table.freeze({
		Data = p.Data,
		SoundId = soundId
	})
end

function SfxRework.Global(p: string)
	local v

	if SfxRework.NewAnimalSfx then
		v = frozen
	else
		v = frozen2
	end

	return v[p]
end

function SfxRework.Resolve(p: string?, p2: string, p3)
	if p == nil then
		return p3
	end

	local frozen6

	if SfxRework.NewAnimalSfx then
		frozen6 = p3
	else
		local v = frozen3[p]
		local soundId

		if v then
			soundId = v[p2]
		end

		if not (soundId == nil or p3 == nil) then
			if soundId == p3.SoundId then
				frozen6 = p3
			else
				frozen6 = table.freeze({
					Data = p3.Data,
					SoundId = soundId
				})
			end
		end
	end

	if SfxRework.NewCherryBlossomSfx or p2 ~= "Walk" then
		return frozen6
	end

	if frozen4[p] then
		return nil
	end

	if frozen5[p] == nil then
		return frozen6
	end

	local soundId2 = frozen5[p]

	if soundId2 == nil or p3 == nil then
		return nil
	end

	if soundId2 == p3.SoundId then
		return p3
	end

	frozen6 = table.freeze({
		Data = p3.Data,
		SoundId = soundId2
	})
	return frozen6
end

return SfxRework