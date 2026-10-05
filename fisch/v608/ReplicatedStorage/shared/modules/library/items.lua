require("./sharedTypes")
local Items = {
	Items = {
		["Zodiac Glider"] = {
			Icon = "rbxassetid://100521212031727",
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true,
			Untradeable = true
		},
		["Cloud Glider"] = {
			Icon = "rbxassetid://112394553934028",
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true,
			Untradeable = true
		},
		["Siren's Tear"] = {
			Icon = "rbxassetid://79792935578478",
			Rarity = "Exotic",
			CustomDescription = "Mella would like to see this...",
			Price = 1e999,
			Unpurchasable = true
		},
		["Golden Firefly"] = {
			Icon = "rbxassetid://107569533127366",
			Rarity = "Exotic",
			Price = 1e999
		},
		["Lighthouse Sky Crystal"] = {
			Icon = "rbxassetid://110950085252888",
			Rarity = "Gemstone",
			Unpurchasable = true,
			BlockStorage = true,
			OnlyBuyOne = true
		},
		["Aquatic Sky Crystal"] = {
			Icon = "rbxassetid://78843350600994",
			Rarity = "Gemstone",
			Unpurchasable = true,
			BlockStorage = true,
			OnlyBuyOne = true
		},
		["Campfire Sky Crystal"] = {
			Icon = "rbxassetid://79141304383420",
			Rarity = "Gemstone",
			Unpurchasable = true,
			BlockStorage = true,
			OnlyBuyOne = true
		},
		["Icy Sky Crystal"] = {
			Icon = "rbxassetid://80985497982909",
			Rarity = "Gemstone",
			Unpurchasable = true,
			BlockStorage = true,
			OnlyBuyOne = true
		},
		["Skull Sky Crystal"] = {
			Icon = "rbxassetid://75488620003565",
			Rarity = "Gemstone",
			Unpurchasable = true,
			BlockStorage = true,
			OnlyBuyOne = true
		},
		["Living Sky Crystal"] = {
			Icon = "rbxassetid://104297012423430",
			Rarity = "Gemstone",
			Unpurchasable = true,
			BlockStorage = true,
			OnlyBuyOne = true
		},
		["Mountain Sky Crystal"] = {
			Icon = "rbxassetid://75048313913492",
			Rarity = "Gemstone",
			Unpurchasable = true,
			BlockStorage = true,
			OnlyBuyOne = true
		},
		["Prismatic Sky Crystal"] = {
			Icon = "rbxassetid://94735014183846",
			Rarity = "Gemstone",
			Unpurchasable = true,
			BlockStorage = true,
			OnlyBuyOne = true
		},
		["Divine Sky Crystal"] = {
			Icon = "rbxassetid://93157832210838",
			Rarity = "Gemstone",
			Unpurchasable = true,
			BlockStorage = true,
			OnlyBuyOne = true
		},
		["Infernal Sky Crystal"] = {
			Icon = "rbxassetid://80556504729369",
			Rarity = "Gemstone",
			Unpurchasable = true,
			BlockStorage = true,
			OnlyBuyOne = true
		},
		["Crest Amulet"] = {
			Icon = "rbxassetid://130571763013507",
			Rarity = "Mythical",
			CustomDescription = "Interact to open the Charms Menu",
			Unpurchasable = true,
			OnlyBuyOne = true,
			Untradeable = true,
			BlockStorage = true
		},
		["Crimson Tides"] = {
			Icon = "rbxassetid://91847089550956",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true,
			Untradeable = true,
			OnlyBuyOne = true
		},
		["Stardust Candy"] = {
			Icon = "rbxassetid://128885801976616",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true
		},
		["Dyson Sphere"] = {
			Icon = "rbxassetid://118188558797549",
			Rarity = "Unusual",
			Price = 1e999,
			Unpurchasable = true
		},
		["Disturbance Catalyst"] = {
			Icon = "rbxassetid://94839820895323",
			Rarity = "Apex",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Throw to immediately accumulate 1,000 Risk at the target location"
		},
		["Empowered Disturbance Catalyst"] = {
			Icon = "rbxassetid://107803977039164",
			Rarity = "Apex",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Throw to immediately accumulate 100,000 Risk at the target location"
		},
		["Chitin Plate"] = {
			Icon = "rbxassetid://92088013209563",
			Rarity = "Unusual",
			Price = 1e999,
			DeepMerchantSellValue = 500,
			Unpurchasable = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Hardened Chitin"] = {
			Icon = "rbxassetid://103956597188704",
			Rarity = "Legendary",
			Price = 1e999,
			DeepMerchantSellValue = 7500,
			Unpurchasable = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Prism Scale"] = {
			Icon = "rbxassetid://80046620979259",
			Rarity = "Unusual",
			Price = 1e999,
			DeepMerchantSellValue = 500,
			Unpurchasable = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Radiant Prism Scale"] = {
			Icon = "rbxassetid://77798282361673",
			Rarity = "Legendary",
			Price = 1e999,
			DeepMerchantSellValue = 7500,
			Unpurchasable = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Bio-Fluid"] = {
			Icon = "rbxassetid://108883721635820",
			Rarity = "Unusual",
			Price = 1e999,
			DeepMerchantSellValue = 500,
			Unpurchasable = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Abyssal Bio-Fluid"] = {
			Icon = "rbxassetid://107604272756657",
			Rarity = "Legendary",
			Price = 1e999,
			DeepMerchantSellValue = 7500,
			Unpurchasable = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Bone Shard"] = {
			Icon = "rbxassetid://111080455697525",
			Rarity = "Unusual",
			Price = 1e999,
			DeepMerchantSellValue = 500,
			Unpurchasable = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Ancient Bone"] = {
			Icon = "rbxassetid://130739677810434",
			Rarity = "Legendary",
			Price = 1e999,
			DeepMerchantSellValue = 7500,
			Unpurchasable = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Salvage Scrap"] = {
			Icon = "rbxassetid://129606824093132",
			Rarity = "Unusual",
			Price = 1e999,
			DeepMerchantSellValue = 500,
			Unpurchasable = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Refined Scrap"] = {
			Icon = "rbxassetid://99333660427936",
			Rarity = "Legendary",
			Price = 1e999,
			DeepMerchantSellValue = 7500,
			Unpurchasable = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Monstrous Cusk Tooth"] = {
			Icon = "rbxassetid://95485216191716",
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Hydro-Core"] = {
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Beacon core for Sector 1P-1"
		},
		["Abyssal Lens"] = {
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Beacon core for Sector 1P-2"
		},
		["Bioluminescent Battery"] = {
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Beacon core for Sector 1P-3"
		},
		["Reinforced Housing"] = {
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Beacon core for Sector 1P-4"
		},
		["Heat-Proof Metal"] = {
			Icon = "rbxassetid://80359605656397",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Part for the Titanic Scalder"
		},
		["Thermal Harpoon"] = {
			Icon = "rbxassetid://133858804812259",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Part for the Titanic Scalder"
		},
		["Line of the Deep"] = {
			Icon = "rbxassetid://116541478441587",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Part for the Cusk Purger"
		},
		["Line of the Skies"] = {
			Icon = "rbxassetid://129207887540191",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Part for Abaia's Spite"
		},
		["Titanium Shaft"] = {
			Icon = "rbxassetid://91984758540935",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Part for the Titanium Rod"
		},
		["Titanium Reel"] = {
			Icon = "rbxassetid://111806992922023",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Part for the Titanium Rod"
		},
		["The Deep Commissary Badge"] = {
			Rarity = "Exotic",
			Price = 1e999,
			OnlyBuyOne = true,
			Unpurchasable = true,
			CustomDescription = "Deep City buys your Deep fish at a 25% premium while owned"
		},
		["Deep Survey Device (Inactive)"] = {
			Rarity = "Trash",
			Price = 1e999,
			OnlyBuyOne = true,
			Unpurchasable = true,
			CustomDescription = "Seems to be broken...",
			Icon = "rbxassetid://136557746044768"
		},
		["Deep Survey Device MK I"] = {
			Rarity = "Mythical",
			Price = 1e999,
			OnlyBuyOne = true,
			Unpurchasable = true,
			CustomDescription = "Allows walking on the ocean floor and provies a persistent fish radar",
			Icon = "rbxassetid://104948977982239"
		},
		["Deep Survey Device MK II"] = {
			Rarity = "Exotic",
			Price = 1e999,
			OnlyBuyOne = true,
			Unpurchasable = true,
			CustomDescription = "Allows walking on the ocean floor and provies a persistent advanced fish radar",
			Icon = "rbxassetid://140698196054134"
		},
		Newspaper = {
			Rarity = "Unique",
			Price = 1e999,
			OnlyBuyOne = true,
			Unpurchasable = true,
			CustomDescription = "Hold to view recent updates"
		},
		["Double Cheezburger"] = {
			Icon = "rbxassetid://74102143018959",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "mmm cheezburger but EVILLLL"
		},
		["Awakening Serum"] = {
			Icon = "rbxassetid://129911199703164",
			Rarity = "Unique",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Throw in the Sunken Reservoir to summon a Photic Terrosunder"
		},
		["Unrefined Magnetite Core"] = {
			Icon = "rbxassetid://105743424715475",
			Rarity = "Rare",
			Price = 15000,
			OnlyBuyOne = true,
			CustomDescription = "Paleontologist Petri might know something about this..."
		},
		["Mysterious Skull"] = {
			Icon = "rbxassetid://86813108202354",
			Rarity = "Rare",
			Price = 150000,
			OnlyBuyOne = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Mysterious Spine"] = {
			Icon = "rbxassetid://135934504296765",
			Rarity = "Legendary",
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Mysterious Fang"] = {
			Icon = "rbxassetid://139617237787029",
			Rarity = "Mythical",
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Sandy Rod Shaft"] = {
			Icon = "rbxassetid://71728606519676",
			Rarity = "Limited",
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Sandy Handle"] = {
			Rarity = "Limited",
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Tropical Squall Totem"] = {
			Icon = "rbxassetid://77961898049955",
			Rarity = "Legendary",
			Price = 1e999
		},
		["Raging Squall Totem"] = {
			Icon = "rbxassetid://138556569975315",
			Rarity = "Mythical",
			Price = 1e999
		},
		["Tropical Sun Totem"] = {
			Icon = "rbxassetid://95668369300599",
			Rarity = "Limited",
			Price = 1e999
		},
		Watermelon = {
			Icon = "rbxassetid://83162366202402",
			Rarity = "Limited",
			Price = 1e999,
			OnlyBuyOne = true
		},
		["Red Message in a Bottle"] = {
			Icon = "rbxassetid://74133285109645",
			Rarity = "Limited",
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Where stone rises above the tides, the final mark watches the horizon."
		},
		["Orange Message in a Bottle"] = {
			Icon = "rbxassetid://119286510729692",
			Rarity = "Limited",
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Warmth gathers stories. Search where the weary sit and the fire glows."
		},
		["Yellow Message in a Bottle"] = {
			Icon = "rbxassetid://77631076538548",
			Rarity = "Limited",
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "The sea leaves gifts where few bother looking. Walk the opposite shore."
		},
		["Green Message in a Bottle"] = {
			Icon = "rbxassetid://104470206587526",
			Rarity = "Limited",
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "A giant’s walls hold more than sand. Look inward, not upward."
		},
		["Blue Message in a Bottle"] = {
			Icon = "rbxassetid://110760465822507",
			Rarity = "Limited",
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "After refreshments, check beneath where people linger the longest."
		},
		["Purple Message in a Bottle"] = {
			Icon = "rbxassetid://112331727730835",
			Rarity = "Limited",
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Among cargo and clutter, one container remembers something important."
		},
		["Red Conch"] = {
			Icon = "rbxassetid://106387713331367",
			Rarity = "Limited",
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "The Sand Castle is calling your name..."
		},
		["Orange Conch"] = {
			Icon = "rbxassetid://94806602029459",
			Rarity = "Limited",
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "The Sand Castle is calling your name..."
		},
		["Yellow Conch"] = {
			Icon = "rbxassetid://96400574038143",
			Rarity = "Limited",
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "The Sand Castle is calling your name..."
		},
		["Green Conch"] = {
			Icon = "rbxassetid://135156693574368",
			Rarity = "Limited",
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "The Sand Castle is calling your name..."
		},
		["Blue Conch"] = {
			Icon = "rbxassetid://131808800264814",
			Rarity = "Limited",
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "The Sand Castle is calling your name..."
		},
		["Purple Conch"] = {
			Icon = "rbxassetid://107279481134676",
			Rarity = "Limited",
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "The Sand Castle is calling your name..."
		},
		["Pink Conch"] = {
			Icon = "rbxassetid://83981814675641",
			Rarity = "Limited",
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "The Sand Castle is calling your name..."
		},
		["Coconut Cooler"] = {
			Icon = "rbxassetid://76089149787529",
			Rarity = "Limited",
			Unpurchasable = true,
			CustomDescription = "Consumable"
		},
		["Pineapple Punch"] = {
			Icon = "rbxassetid://97567044867261",
			Rarity = "Limited",
			Unpurchasable = true,
			CustomDescription = "Consumable"
		},
		["Sunset Smoothie"] = {
			Icon = "rbxassetid://133207200789490",
			Rarity = "Limited",
			Unpurchasable = true,
			CustomDescription = "Consumable"
		},
		["Lagoon Lemonade"] = {
			Icon = "rbxassetid://111446616050843",
			Rarity = "Limited",
			Unpurchasable = true,
			CustomDescription = "Consumable"
		},
		["Sunburst Soda"] = {
			Icon = "rbxassetid://130089010016891",
			Rarity = "Limited",
			Unpurchasable = true,
			CustomDescription = "Consumable"
		},
		["Reef Refresher"] = {
			Icon = "rbxassetid://127563717243009",
			Rarity = "Limited",
			Unpurchasable = true,
			CustomDescription = "Consumable"
		},
		["Corrupted Disc"] = {
			Icon = "rbxassetid://107838453826348",
			Rarity = "Unique",
			Price = 1e999,
			Unpurchasable = true,
			BlockStorage = true
		},
		["Crow Feather Charm"] = {
			Rarity = "Unusual",
			Price = 1e999,
			Unpurchasable = true,
			Icon = "rbxassetid://133385807756540"
		},
		["Brine Storm Totem"] = {
			Rarity = "Limited",
			Price = 1e999,
			Icon = "rbxassetid://83758816591077"
		},
		["Soulreaper Bonds"] = {
			Icon = "rbxassetid://114887029453684",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true
		},
		["Soulreaper Blade"] = {
			Icon = "rbxassetid://112176907623849",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true
		},
		["Soulreaper Handle"] = {
			Icon = "rbxassetid://84230060194452",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true
		},
		["Time Machine"] = {
			Icon = "rbxassetid://97986314244615",
			Rarity = "Unique",
			Price = 1e999,
			Unpurchasable = true
		},
		["Developer Gift"] = {
			Icon = "rbxassetid://132870058839438",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			Untradeable = true,
			OnlyBuyOne = true,
			CustomDescription = "A thank-you from the Fisch team. Open it whenever you're ready."
		},
		["Companion Candy"] = {
			Icon = "rbxassetid://104923123061555",
			Rarity = "Legendary",
			Price = 1e999,
			CustomDescription = "Grants 1,500 XP to your equipped companion."
		},
		Shell = {
			Icon = "rbxassetid://92504474154034",
			Rarity = "Rare",
			Price = 1e999,
			CustomDescription = "Offer at Calyra's Altar for a random shell buff."
		},
		["Shell of Swiftness"] = {
			Icon = "rbxassetid://110733060845882",
			Rarity = "Unique",
			Price = 1e999,
			Unpurchasable = true
		},
		["Shell of Endurance"] = {
			Icon = "rbxassetid://119420111715632",
			Rarity = "Unique",
			Price = 1e999,
			Unpurchasable = true
		},
		["Shell of Fortune"] = {
			Icon = "rbxassetid://127359823102523",
			Rarity = "Unique",
			Price = 1e999,
			Unpurchasable = true
		},
		["Shell of Depth"] = {
			Icon = "rbxassetid://105234450830090",
			Rarity = "Unique",
			Price = 1e999,
			Unpurchasable = true
		},
		["Shell of Wrath"] = {
			Icon = "rbxassetid://86674841332555",
			Rarity = "Unique",
			Price = 1e999,
			Unpurchasable = true
		},
		["Corrupt Shell"] = {
			Icon = "rbxassetid://120028649653090",
			Rarity = "Unique",
			Price = 1e999,
			Unpurchasable = true
		},
		["Royal Helmet"] = {
			Icon = "rbxassetid://123717690141272",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true
		},
		["Bellona Sword"] = {
			Icon = "rbxassetid://139850712603591",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "A misplaced sword... perhaps this has a use?"
		},
		["Shattered Aegis Shard"] = {
			Icon = "rbxassetid://73371104471316",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true
		},
		["Cracked Aegis Shard"] = {
			Icon = "rbxassetid://93644535633882",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true
		},
		["Sunken Aegis Shard"] = {
			Icon = "rbxassetid://115979616376423",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true
		},
		["Bloodied Aegis Shard"] = {
			Icon = "rbxassetid://120226533558950",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true
		},
		["Legionnaire's Aegis Shard"] = {
			Icon = "rbxassetid://109988959096801",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true
		},
		["Egg Basket"] = {
			Icon = "rbxassetid://76209640167112",
			Rarity = "Limited",
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Hold this out to collect Egg Hunt 2026 Eggs!"
		},
		["Crimson Rhythm Handle"] = {
			Icon = "rbxassetid://123822970886373",
			Rarity = "Limited",
			Unpurchasable = true,
			OnlyBuyOne = true
		},
		["Melody Bridge Neck"] = {
			Icon = "rbxassetid://74759730795706",
			Rarity = "Limited",
			Unpurchasable = true,
			OnlyBuyOne = true
		},
		["Pitchshift Reel"] = {
			Icon = "rbxassetid://133698010681591",
			Rarity = "Limited",
			Unpurchasable = true,
			OnlyBuyOne = true
		},
		["Strange Guitar"] = {
			Icon = "rbxassetid://86583930827938",
			Rarity = "Limited",
			Unpurchasable = true,
			OnlyBuyOne = true
		},
		["Broken Phone"] = {
			Icon = "rbxassetid://97965082472690",
			Rarity = "Limited",
			Unpurchasable = true
		},
		["Bouka Phone"] = {
			Icon = "rbxassetid://115482213900009",
			Rarity = "Limited",
			Unpurchasable = true,
			OnlyBuyOne = true
		},
		["Magical Leek"] = {
			Icon = "rbxassetid://128947596305438",
			Rarity = "Limited",
			Unpurchasable = true,
			OnlyBuyOne = true
		},
		["Everturn Cloak"] = {
			Rarity = "Legendary",
			Icon = "rbxassetid://83206888630120",
			Price = 1e999,
			CustomDescription = "Reduces Evil Oakling Visibility Range",
			Unpurchasable = true,
			OnlyBuyOne = true
		},
		["Noise-Cancelling Headphones"] = {
			Icon = "rbxassetid://95672609306250",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Disables fish from Admin Events",
			OnlyBuyOne = true
		},
		["Shamrock Coil"] = {
			Icon = "rbxassetid://111194433992692",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Shamrock Seas Exclusive]",
			OnlyBuyOne = true
		},
		["Clover Glider"] = {
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Shamrock Seas Exclusive]",
			OnlyBuyOne = true,
			Untradeable = true,
			Icon = "rbxassetid://106879248060016"
		},
		["Gold Coin"] = {
			Icon = "rbxassetid://129284065601043",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Consume for +25% sell rate for 30 seconds"
		},
		["Four Leaf Clover"] = {
			Icon = "rbxassetid://108163456424411",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Consume for 5 minutes of 2× Server Luck"
		},
		["Five Leaf Clover"] = {
			Icon = "rbxassetid://72973006319200",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Consume for 10 minutes of 16× Server Luck"
		},
		["One Leaf Clover"] = {
			Icon = "rbxassetid://135832617596304",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "???"
		},
		["Prototype Noxious Catalyst"] = {
			Icon = "rbxassetid://109470488546938",
			Rarity = "Unique",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Throw to summon a Toxic Boil"
		},
		["Noxious Catalyst"] = {
			Icon = "rbxassetid://130311165670159",
			Rarity = "Unique",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Throw to summon a Toxic Boil"
		},
		["Toxinburst Line"] = {
			Icon = "rbxassetid://124755464843158",
			Rarity = "Rare",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Toxinburst Shaft"] = {
			Icon = "rbxassetid://73863942879438",
			Rarity = "Rare",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Toxinburst Handle"] = {
			Icon = "rbxassetid://81616289309415",
			Rarity = "Rare",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Gas Mask"] = {
			Icon = "rbxassetid://110405297360184",
			Rarity = "Legendary",
			Price = 75000,
			OnlyBuyOne = true,
			CustomDescription = "Required for Toxic Grove",
			BestiaryRequirement = {
				{
					Island = "Lost Jungle",
					Requirement = 50
				}
			}
		},
		["Flower Glider"] = {
			Rarity = "Limited",
			Price = 1e999,
			OnlyBuyOne = true,
			Unpurchasable = true,
			CustomDescription = "Obtained from Oliver",
			Icon = "rbxassetid://95443395823893",
			Untradeable = true
		},
		["Mysterious Seed"] = {
			Icon = "rbxassetid://129127285125420",
			Rarity = "Limited",
			Price = 1e999,
			OnlyBuyOne = true,
			Unpurchasable = true,
			CustomDescription = "Obtained from Oliver"
		},
		["Cyan Lotus"] = {
			Icon = "rbxassetid://106337719789956",
			Rarity = "Common",
			Price = 1e999,
			OnlyBuyOne = true,
			Unpurchasable = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Violet Lotus"] = {
			Icon = "rbxassetid://97788394383215",
			Rarity = "Rare",
			Price = 1e999,
			OnlyBuyOne = true,
			Unpurchasable = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Canary Lotus"] = {
			Icon = "rbxassetid://79510504021141",
			Rarity = "Legendary",
			Price = 1e999,
			OnlyBuyOne = true,
			Unpurchasable = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Dream Orchid"] = {
			Icon = "rbxassetid://115736409944772",
			Rarity = "Limited",
			Price = 1e999,
			OnlyBuyOne = true,
			Unpurchasable = true,
			CustomDescription = "Used to upgrade Bloomspire"
		},
		["Toxic Lotus"] = {
			Icon = "rbxassetid://132751810089456",
			Rarity = "Gemstone",
			Price = 1e999,
			OnlyBuyOne = true,
			Unpurchasable = true,
			CustomDescription = "Used to upgrade Bloomspire"
		},
		["Living Lotus"] = {
			Icon = "rbxassetid://110441038598863",
			Rarity = "Uncommon",
			Price = 1e999,
			OnlyBuyOne = true,
			Unpurchasable = true,
			CustomDescription = "Used to upgrade Bloomspire"
		},
		["Hang Glider"] = {
			Rarity = "Unique",
			OnlyBuyOne = true,
			Unpurchasable = true,
			Untradeable = true,
			Icon = "rbxassetid://134607965485473"
		},
		["Wings of Harmony"] = {
			Rarity = "Exotic",
			Icon = "rbxassetid://100768970532192",
			OnlyBuyOne = true,
			Unpurchasable = true,
			Untradeable = true
		},
		["Wings of Lament"] = {
			Rarity = "Limited",
			Icon = "rbxassetid://71087877567214",
			OnlyBuyOne = true,
			Unpurchasable = true,
			Untradeable = true
		},
		Boombox = {
			Icon = "rbxassetid://114715420293017",
			Rarity = "Unique",
			Price = 1e999,
			OnlyBuyOne = true,
			Unpurchasable = true
		},
		["Heartbreak Cake"] = {
			Rarity = "Limited",
			Icon = "rbxassetid://122309182988008",
			OnlyBuyOne = true,
			Unpurchasable = true,
			Price = 1000,
			LocalCurrency = "Chocolates"
		},
		["Penny's Love Letter"] = {
			Icon = "rbxassetid://95547980927734",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "A love letter from Penny to Oddie."
		},
		["Cupid's Core"] = {
			Icon = "rbxassetid://77418067716363",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Cupid's Wings"] = {
			Icon = "rbxassetid://85160025302937",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Cupid's Handle"] = {
			Icon = "rbxassetid://76984657294013",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Red Blossom"] = {
			Icon = "rbxassetid://136627573420608",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true
		},
		["Pink Blossom"] = {
			Icon = "rbxassetid://97872586600362",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true
		},
		["White Blossom"] = {
			Icon = "rbxassetid://132100260414864",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true
		},
		["Candle of Compassion"] = {
			Icon = "rbxassetid://95943564692135",
			Rarity = "Limited",
			Price = 214,
			OnlyBuyOne = true,
			Unpurchasable = true,
			CustomDescription = "???"
		},
		["Tidemourner Head"] = {
			Icon = "rbxassetid://135023653559115",
			Rarity = "Secret",
			Price = 750000,
			OnlyBuyOne = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Abyssal Tonic"] = {
			Icon = "rbxassetid://94292787709861",
			Rarity = "Rare",
			Price = 500,
			Requirements = {
				DataInstanceRequiriment = {
					"Cache.LostDiverSaved",
					true,
					"You can't purchase this yet. Rescue the lost diver first."
				}
			}
		},
		["Requiem Core"] = {
			Icon = "rbxassetid://117391514817974",
			Rarity = "Secret",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Thalass Essence"] = {
			Icon = "rbxassetid://109258942766326",
			Rarity = "Secret",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "???"
		},
		["Tide Essence"] = {
			Icon = "rbxassetid://109182489673923",
			Rarity = "Secret",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "???"
		},
		["Requis Essence"] = {
			Icon = "rbxassetid://135107200532865",
			Rarity = "Secret",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "???"
		},
		["Dripstone Collapse Totem"] = {
			Icon = "rbxassetid://139789538352340",
			Rarity = "Secret",
			Price = 7500000,
			LogEconomy = true
		},
		["New Years Firework"] = {
			Icon = "rbxassetid://110688395531677",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true
		},
		["New Years Firework Rocket"] = {
			Icon = "rbxassetid://116859688611539",
			Rarity = "Limited",
			Price = 1e999,
			Untradeable = true
		},
		["Astronomical Fretboard"] = {
			Icon = "rbxassetid://114607534235105",
			Rarity = "Secret",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "To play into the void",
			OnlyBuyOne = true
		},
		["Twilight Pegs"] = {
			Icon = "rbxassetid://98579377910130",
			Rarity = "Secret",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "To tune what's lost",
			OnlyBuyOne = true
		},
		["Cryogenic Crystal"] = {
			Icon = "rbxassetid://137504891172962",
			Rarity = "Unusual",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true
		},
		["Winter Boots"] = {
			Rarity = "Legendary",
			Icon = "rbxassetid://91123414018061",
			OnlyBuyOne = true
		},
		["Water Shoes"] = {
			Rarity = "Limited",
			Icon = "rbxassetid://125250933368310",
			OnlyBuyOne = true
		},
		["Dune Boots"] = {
			Rarity = "Unique",
			Icon = "rbxassetid://136882076441102",
			OnlyBuyOne = true
		},
		["Dune Goggles"] = {
			Rarity = "Unique",
			Icon = "rbxassetid://80519379490082",
			OnlyBuyOne = true
		},
		["Dunehaven Wraps"] = {
			Price = 40000,
			Rarity = "Unique",
			Icon = "rbxassetid://71313421385367",
			CustomDescription = "Various improvements in Dust Storms",
			OnlyBuyOne = true
		},
		["Dead Man's Tentacle"] = {
			Icon = "rbxassetid://139726710177171",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Dead Man's Treasure"] = {
			Icon = "rbxassetid://99668163904014",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Dead Man's Wood"] = {
			Icon = "rbxassetid://93463070324660",
			Rarity = "Secret",
			Price = 1000,
			OnlyBuyOne = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Bloop Whistle"] = {
			Icon = "rbxassetid://94676791624616",
			Rarity = "Secret",
			Price = 1e999,
			Unpurchasable = true,
			BlockStorage = true
		},
		Translator = {
			Icon = "rbxassetid://94058361936525",
			Rarity = "Unusual",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Used to understand Glorp's language",
			OnlyBuyOne = true
		},
		["Jingle Wings"] = {
			Rarity = "Limited",
			OnlyBuyOne = true,
			Icon = "rbxassetid://140306863545085"
		},
		["Christmas Music Box"] = {
			Icon = "rbxassetid://77789768088975",
			Rarity = "Limited",
			OnlyBuyOne = true
		},
		Frostbreaker = {
			Icon = "rbxassetid://90538079167604",
			Rarity = "Limited",
			OnlyBuyOne = true
		},
		["Winter Gloves"] = {
			Rarity = "Limited",
			Icon = "rbxassetid://70780842648508",
			OnlyBuyOne = true
		},
		["Lucky Gloves"] = {
			Rarity = "Limited",
			Icon = "rbxassetid://114854302737451",
			OnlyBuyOne = true
		},
		Snowshoes = {
			Rarity = "Limited",
			Icon = "rbxassetid://125820626395484",
			OnlyBuyOne = true
		},
		["Ugly Sweater"] = {
			Rarity = "Limited",
			Icon = "rbxassetid://80420220076376",
			OnlyBuyOne = true
		},
		["Wrapping Paper"] = {
			Icon = "rbxassetid://138648574577781",
			Rarity = "Limited",
			MaxCount = 5,
			NonPersistent = true
		},
		Ribbon = {
			Icon = "rbxassetid://98317254831061",
			Rarity = "Limited",
			MaxCount = 3,
			NonPersistent = true
		},
		["Elf Hat"] = {
			Icon = "rbxassetid://127967036988284",
			Rarity = "Limited",
			OnlyBuyOne = true,
			NonPersistent = true
		},
		Stocking = {
			Icon = "rbxassetid://90389195312112",
			Rarity = "Limited",
			MaxCount = 5,
			NonPersistent = true
		},
		["Someone's Present"] = {
			Icon = "rbxassetid://117794683745807",
			Rarity = "Limited",
			MaxCount = 20
		},
		["Everfrost Key"] = {
			Icon = "rbxassetid://87491479529831",
			Rarity = "Limited",
			OnlyBuyOne = true
		},
		["Essence of Starfrost"] = {
			Icon = "rbxassetid://129705084281273",
			Rarity = "Limited"
		},
		["Essence of Winter"] = {
			Icon = "rbxassetid://87053315443009",
			Rarity = "Limited"
		},
		["The Rough Geode"] = {
			Icon = "rbxassetid://112983014960453",
			Rarity = "Legendary",
			Price = 1e999,
			OnlyBuyOne = true
		},
		["The Cut Gem"] = {
			Icon = "rbxassetid://111175067301987",
			Rarity = "Legendary",
			Price = 1e999,
			OnlyBuyOne = true
		},
		["Mystic Mirror"] = {
			Icon = "rbxassetid://91712670273451",
			Rarity = "Mirror",
			Price = 1e999,
			OnlyBuyOne = true
		},
		["Shard of Nebulas"] = {
			Icon = "rbxassetid://92959271284770",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true
		},
		["Shard of Embers"] = {
			Icon = "rbxassetid://90187315975277",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true
		},
		["Shard of Roots"] = {
			Icon = "rbxassetid://126660606304828",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true
		},
		["Shard of Tides"] = {
			Icon = "rbxassetid://93145995991736",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true
		},
		["Shard of Time"] = {
			Icon = "rbxassetid://80118524685243",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true
		},
		["Varn's Amulet Fragment"] = {
			Icon = "rbxassetid://121850568691361",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true
		},
		["Kareth's Amulet Fragment"] = {
			Icon = "rbxassetid://122659482177938",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true
		},
		["Sythra's Amulet Fragment"] = {
			Icon = "rbxassetid://132305502524473",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true
		},
		["Maelira's Amulet Fragment"] = {
			Icon = "rbxassetid://74019219900928",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true
		},
		["Eldran's Amulet Fragment"] = {
			Icon = "rbxassetid://132558853204311",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true
		},
		["Lucid Reel"] = {
			Icon = "rbxassetid://103902883687423",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Crafting Ingredient"
		},
		["Sea Traveler Note"] = {
			Icon = "rbxassetid://94506651387251",
			Rarity = "Unusual",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Leads to a secret during foggy nights",
			OnlyBuyOne = true
		},
		["Scylla Mask"] = {
			Rarity = "Limited",
			Icon = "rbxassetid://138856893622573",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Boosts 'Treat' in trick or treat by 20%",
			OnlyBuyOne = true
		},
		["Megalodon Mask"] = {
			Rarity = "Limited",
			Icon = "rbxassetid://131793240574895",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Boosts trick or treat candy by 20%",
			OnlyBuyOne = true
		},
		["Candy Bucket"] = {
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Trick or Treat!"
		},
		["Frightful Mirror"] = {
			Icon = "rbxassetid://134249767441210",
			Rarity = "Limited",
			Unpurchasable = true,
			NonPersistent = true,
			Price = 1e999
		},
		["Dreamer's Amulet"] = {
			Icon = "rbxassetid://138365042612391",
			Rarity = "Secret",
			Price = 1e999,
			Unpurchasable = true
		},
		["Sythra’s Wick"] = {
			Icon = "rbxassetid://105853240648549",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true
		},
		Wisp = {
			Icon = "rbxassetid://93171262443447",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true
		},
		["Blazed Handle"] = {
			Icon = "rbxassetid://107336411827448",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true
		},
		["Haunted Candle"] = {
			Icon = "rbxassetid://86650804842437",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true
		},
		["Frightful Pool Totem"] = {
			Rarity = "Limited",
			Price = 1e999,
			Icon = "rbxassetid://106831363999140"
		},
		["Blue Frightful Skull"] = {
			Icon = "rbxassetid://121332356915265",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true
		},
		["Orange Frightful Skull"] = {
			Icon = "rbxassetid://93000721437061",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true
		},
		["Green Frightful Skull"] = {
			Icon = "rbxassetid://128751246905664",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true
		},
		["Purple Frightful Skull"] = {
			Icon = "rbxassetid://84906019193971",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true
		},
		["Red Frightful Skull"] = {
			Icon = "rbxassetid://126405638576080",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true
		},
		["Fluffy Unicorn"] = {
			Icon = "rbxassetid://85777258064556",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Fire Extinguisher"] = {
			Icon = "rbxassetid://100251432613225",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		Skelefriend = {
			Icon = "rbxassetid://135895999666696",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Dance Potion"] = {
			Icon = "rbxassetid://118470492401215",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Pogo Stick"] = {
			Icon = "rbxassetid://113062075002615",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Hot Chocolate"] = {
			Icon = "rbxassetid://109455008424218",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Regeneration Coil"] = {
			Icon = "rbxassetid://90977106916021",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Snowy Gravity Coil"] = {
			Icon = "rbxassetid://125169865851915",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Moonwalk Dance Potion"] = {
			Icon = "rbxassetid://75856334904368",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Holiday Ham"] = {
			Icon = "rbxassetid://73295974208937",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Chocolate Milk"] = {
			Icon = "rbxassetid://112758527438865",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Bunch of Balloons"] = {
			Icon = "rbxassetid://102479822585272",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Skipper Seal"] = {
			Icon = "rbxassetid://129385555940394",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		Pizza = {
			Icon = "rbxassetid://99616360077947",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Bag of Chips"] = {
			Icon = "rbxassetid://123642399315271",
			Rarity = "Unique",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Crunchy, orange, and loud. Somebody out there needs these more than you do."
		},
		["Rusted Bunker Key"] = {
			Icon = "rbxassetid://110505632473030",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Old iron, orange with rust. Fits something on Birch Cay."
		},
		["Slateskin Potion"] = {
			Icon = "rbxassetid://74365593414490",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Alpaca Plushie"] = {
			Icon = "rbxassetid://92842403510645",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		Hyperbike = {
			Icon = "rbxassetid://117320614640220",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Witches Brew"] = {
			Icon = "rbxassetid://86067717319060",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Mr. Bones"] = {
			Icon = "rbxassetid://118554153837474",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Halloween Roped"] = {
			Icon = "rbxassetid://98682688126442",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Ghost Elixir"] = {
			Icon = "rbxassetid://85617052099837",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Halloween Sparkler"] = {
			Icon = "rbxassetid://84994817074594",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		Moneybag = {
			Icon = "rbxassetid://109050732520516",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Semi-Speed Coil"] = {
			Icon = "rbxassetid://117809767003224",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Teddy Bear"] = {
			Icon = "rbxassetid://112579219695563",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Lightblox Jar"] = {
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true,
			Icon = "rbxassetid://122344314971632"
		},
		["Cuddly Cat"] = {
			Icon = "rbxassetid://74197916958013",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Race the Sunset"] = {
			Icon = "rbxassetid://140253753348273",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Lunar Lander"] = {
			Icon = "rbxassetid://94250255165138",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Gravity Coil"] = {
			Icon = "rbxassetid://109382735218808",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Velocity Coil"] = {
			Icon = "rbxassetid://103268792776880",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Ro-torcycle"] = {
			Icon = "rbxassetid://112487196150522",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		Cake = {
			Icon = "rbxassetid://82997270574372",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "A toast to Fisch's anniversary!"
		},
		["Poisonous Spearhead"] = {
			Icon = "rbxassetid://118569556506210",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "A spearhead covered in poison."
		},
		["Toxic Core"] = {
			Icon = "rbxassetid://75730033258780",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Crafting Ingredient\nA corrupted core, pulsing with venom."
		},
		["Mossy Core"] = {
			Icon = "rbxassetid://74356743861333",
			Rarity = "Secret",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Crafting Ingredient\nAncient power buried in mossy growth."
		},
		["Barbed Spearhead"] = {
			Icon = "rbxassetid://114923720903661",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Crafting Ingredient\nA spearhead with sharp barbs."
		},
		["Vine Line"] = {
			Icon = "rbxassetid://74276296709203",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Crafting Ingredient\nRoots of age hardened into thread.",
			BlockStorage = true
		},
		["Murky Thread"] = {
			Icon = "rbxassetid://111671458973783",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Crafting Ingredient\nA line that reeks of murk and time."
		},
		["Temple Eye"] = {
			Icon = "rbxassetid://125245700736776",
			Rarity = "Secret",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Used to return to the center of the Forgotten Temple."
		},
		["Glyph Rune"] = {
			Icon = "rbxassetid://76168470039902",
			Rarity = "Secret",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "A rune earned from a puzzle."
		},
		["Toxic Rune"] = {
			Icon = "rbxassetid://127683006072575",
			Rarity = "Secret",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "A rune earned from a puzzle."
		},
		["Spike Rune"] = {
			Icon = "rbxassetid://81851951779236",
			Rarity = "Secret",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "A rune earned from a puzzle."
		},
		["Vine Rune"] = {
			Icon = "rbxassetid://100951877350242",
			Rarity = "Secret",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "A rune earned from a puzzle."
		},
		["Water Rune"] = {
			Icon = "rbxassetid://73678019183090",
			Rarity = "Secret",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "A rune earned from a puzzle."
		},
		["Evil Sigil"] = {
			Icon = "rbxassetid://122534180733367",
			Rarity = "Secret",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Crafting Ingredient\nA Sigil from the Crimson King."
		},
		["Rokko's Fragment"] = {
			Icon = "rbxassetid://139182164414517",
			Rarity = "Secret",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "A fragment you got from Rokko."
		},
		["Vimble's Fragment"] = {
			Icon = "rbxassetid://136256197704396",
			Rarity = "Secret",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "A fragment you got from Vimble."
		},
		["Tilli's Fragment"] = {
			Icon = "rbxassetid://117687423340791",
			Rarity = "Secret",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "A fragment you got from Tilli."
		},
		["Wixie's Fragment"] = {
			Icon = "rbxassetid://84109287052221",
			Rarity = "Secret",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "A fragment you got from Wixie."
		},
		["Cepo's Fragment"] = {
			Icon = "rbxassetid://139074570937765",
			Rarity = "Secret",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "A fragment you got from Cepo."
		},
		["Mushroom Keystone"] = {
			Icon = "rbxassetid://101694285708490",
			Rarity = "Unusual",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "A keystone of unknown purpose."
		},
		["Snowflake Keystone"] = {
			Icon = "rbxassetid://125226423917215",
			Rarity = "Unusual",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "A keystone of unknown purpose."
		},
		["Turtle Keystone"] = {
			Icon = "rbxassetid://80149005861313",
			Rarity = "Unusual",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "A keystone of unknown purpose."
		},
		["Sun Keystone"] = {
			Icon = "rbxassetid://131726544513117",
			Rarity = "Unusual",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "A keystone of unknown purpose."
		},
		["Volcano Keystone"] = {
			Rarity = "Unusual",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "A keystone of unknown purpose."
		},
		["Lightning Keystone"] = {
			Icon = "rbxassetid://101751033766235",
			Rarity = "Unusual",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "A keystone of unknown purpose."
		},
		["Skull Keystone"] = {
			Icon = "rbxassetid://105655351392953",
			Rarity = "Unusual",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "A keystone of unknown purpose."
		},
		["Cliff Keystone"] = {
			Icon = "rbxassetid://120898260423969",
			Rarity = "Unusual",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "A keystone of unknown purpose."
		},
		["Fossil Keystone"] = {
			Icon = "rbxassetid://94349298210630",
			Rarity = "Unusual",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "A keystone of unknown purpose."
		},
		["Meteor Shard"] = {
			Icon = "rbxassetid://76232829502329",
			Rarity = "Limited",
			Price = 1e999
		},
		["Shiny Totem"] = {
			Rarity = "Unique",
			Price = 1e999,
			Icon = "rbxassetid://106831363999140"
		},
		["Kraken Hunt Totem"] = {
			Rarity = "Unique",
			Price = 1e999,
			Icon = "rbxassetid://133450882930307"
		},
		["Megalodon Hunt Totem"] = {
			Rarity = "Unique",
			Price = 1e999,
			Icon = "rbxassetid://74841041569222"
		},
		["Colossal Dragon Hunt Totem"] = {
			Rarity = "Unique",
			Price = 1e999,
			Icon = "rbxassetid://85067071133552"
		},
		["Scylla Hunt Totem"] = {
			Rarity = "Unique",
			Price = 1e999,
			Icon = "rbxassetid://92270118461292"
		},
		["Sparkling Totem"] = {
			Rarity = "Unique",
			Price = 1e999,
			Icon = "rbxassetid://79683245166829"
		},
		["Mutation Totem"] = {
			Rarity = "Unique",
			Price = 1e999,
			Icon = "rbxassetid://101542449415928"
		},
		["Shop Key"] = {
			Icon = "rbxassetid://81644029459811",
			Rarity = "Unique",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Grants 1 random paid item!\n[UNIQUE]"
		},
		["Eternal Fuel"] = {
			Icon = "rbxassetid://96277978133035",
			Rarity = "Mythical",
			Price = 1e999,
			Unpurchasable = true
		},
		["Hourglass Hull"] = {
			Icon = "rbxassetid://131569778303349",
			Rarity = "Mythical",
			Price = 1e999,
			Unpurchasable = true
		},
		["Ethereal Glass"] = {
			Icon = "rbxassetid://122680454709128",
			Rarity = "Mythical",
			Price = 1e999,
			Unpurchasable = true
		},
		["Mythical Essence"] = {
			Icon = "rbxassetid://70907367112719",
			Rarity = "Mythical",
			Price = 1e999,
			Unpurchasable = true
		},
		["1000-Year-Old Wood"] = {
			Icon = "rbxassetid://131398238119200",
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true
		},
		["Hourglass Lantern"] = {
			Icon = "rbxassetid://96253804691434",
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true
		},
		["Sand Of Time"] = {
			Icon = "rbxassetid://124598432669539",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true
		},
		["Timeless Threading"] = {
			Icon = "rbxassetid://117848022465901",
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true
		},
		["Physpax Gun"] = {
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			DEV = true
		},
		["Shrimp Slinger"] = {
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			DEV = true
		},
		["Ban Hammer"] = {
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			Untradeable = true,
			CustomDescription = "PS2 was here.",
			DEV = true
		},
		["The Nanner"] = {
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "woops i sli-",
			DEV = true
		},
		["Whirlpool Flush"] = {
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			Untradeable = true,
			CustomDescription = "Flush them down the drain.",
			DEV = true
		},
		Substrike = {
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "BOOM",
			DEV = true
		},
		["Rocket Launcher"] = {
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			Untradeable = true,
			CustomDescription = "If fighting is sure to result in victory, then you must fight!",
			DEV = true
		},
		["Strong Steampunk Glove"] = {
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "MOVEEEEEE",
			DEV = true
		},
		Starscraper = {
			Icon = "rbxassetid://109247021565454",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			Untradeable = true,
			DEV = true,
			CustomDescription = "⭐💫"
		},
		Stardancer = {
			Icon = "rbxassetid://109247021565454",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			Untradeable = true,
			DEV = true,
			CustomDescription = "⭐lea will touch the stars one day...💫"
		},
		["Nico Potion"] = {
			Icon = "rbxassetid://137336508868748",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true
		},
		["Keepers Torch"] = {
			Icon = "rbxassetid://76137992177769",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true
		},
		["Portable Photobooth"] = {
			Icon = "rbxassetid://95829587799318",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true
		},
		["Kraken Egg"] = {
			Icon = "rbxassetid://97343392569921",
			Rarity = "Mythical",
			Price = 1e999,
			Unpurchasable = true
		},
		["Megalodon Egg"] = {
			Icon = "rbxassetid://76051791890870",
			Rarity = "Mythical",
			Price = 1e999,
			Unpurchasable = true
		},
		["Orca Egg"] = {
			Icon = "rbxassetid://139995749757570",
			Rarity = "Mythical",
			Price = 1e999,
			Unpurchasable = true
		},
		["Whale Egg"] = {
			Icon = "rbxassetid://76424918105543",
			Rarity = "Mythical",
			Price = 1e999,
			Unpurchasable = true
		},
		["Faberge Egg"] = {
			Icon = "rbxassetid://130278741432543",
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true
		},
		["Cursed Egg"] = {
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true
		},
		["Kraken Egg Premium"] = {
			Icon = "rbxassetid://109801868155039",
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true
		},
		["Megalodon Egg Premium"] = {
			Icon = "rbxassetid://86174334955905",
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true
		},
		["Orca Egg Premium"] = {
			Icon = "rbxassetid://74953553282373",
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true
		},
		["Whale Egg Premium"] = {
			Icon = "rbxassetid://120224765062821",
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true
		},
		["Cosmetic Egg"] = {
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true
		},
		["Golden Egg Trophy Bobber"] = {
			Icon = "rbxassetid://115781267710424",
			Rarity = "Limited",
			Price = 1e999
		},
		["Silver Egg Trophy Bobber"] = {
			Icon = "rbxassetid://125710369754420",
			Rarity = "Limited",
			Price = 1e999
		},
		["Crab Cage"] = {
			Icon = "rbxassetid://75745544665436",
			Rarity = "Unusual",
			Price = 45,
			LogEconomy = true
		},
		["Reinforced Crab Cage"] = {
			Icon = "rbxassetid://91742437348732",
			Rarity = "Rare",
			Price = 1000,
			LogEconomy = true
		},
		["Coral Crab Cage"] = {
			Icon = "rbxassetid://137472122052849",
			Rarity = "Rare",
			Price = 1500,
			LogEconomy = true
		},
		["Relic Crab Cage"] = {
			Icon = "rbxassetid://104977918590065",
			Rarity = "Rare",
			Price = 2000,
			LogEconomy = true
		},
		["Golden Crab Cage"] = {
			Icon = "rbxassetid://118208628410722",
			Rarity = "Legendary",
			Price = 25000,
			LogEconomy = true
		},
		Firework = {
			Icon = "rbxassetid://123163377915248",
			Rarity = "Common",
			Price = 130
		},
		["Magic Mirror"] = {
			Icon = "rbxassetid://82242879151044",
			Rarity = "Mirror",
			Price = 50000,
			OnlyBuyOne = true
		},
		["Magic Conch"] = {
			Icon = "rbxassetid://90990045240576",
			Rarity = "Limited",
			NonPersistent = true,
			Price = 1e999
		},
		["Beach Ball"] = {
			Icon = "rbxassetid://107525245508470",
			Rarity = "Limited",
			Price = 1e999
		},
		["Ice Cream"] = {
			Icon = "rbxassetid://111660800765328",
			Rarity = "Limited",
			Price = 1e999
		},
		["Shark Whistle"] = {
			Icon = "rbxassetid://109352035434752",
			Rarity = "Whistle",
			Price = 1e999,
			BlockStorage = true
		},
		["Traveler's Whistle"] = {
			Icon = "rbxassetid://82086176853873",
			Rarity = "Whistle",
			Price = 250000,
			OnlyBuyOne = true,
			BlockStorage = true
		},
		["Conception Conch"] = {
			Icon = "rbxassetid://123642846664138",
			Rarity = "Rare",
			Price = 444
		},
		Glider = {
			Rarity = "Rare",
			Price = 900,
			Icon = "rbxassetid://75649587806150",
			OnlyBuyOne = true,
			Untradeable = true
		},
		["Advanced Glider"] = {
			Rarity = "Legendary",
			Price = 10000,
			Icon = "rbxassetid://83927761551417",
			OnlyBuyOne = true,
			Untradeable = true
		},
		["Elite Glider"] = {
			Rarity = "Mythical",
			Price = 1e999,
			Icon = "rbxassetid://93427501789754",
			Unpurchasable = true,
			OnlyBuyOne = true,
			Untradeable = true
		},
		["Bat Glider"] = {
			Rarity = "Limited",
			Icon = "rbxassetid://85116231134635",
			OnlyBuyOne = true
		},
		["Wings of Wrath"] = {
			Rarity = "Exotic",
			Icon = "rbxassetid://119667766536099",
			OnlyBuyOne = true,
			Unpurchasable = true,
			Untradeable = true
		},
		["Sweet Picnic Glider"] = {
			Rarity = "Limited",
			Icon = "rbxassetid://109266086856454",
			OnlyBuyOne = true
		},
		["Sakura Soarer"] = {
			Rarity = "Limited",
			Icon = "rbxassetid://113184874509185",
			OnlyBuyOne = true
		},
		["Patchy Glider"] = {
			Rarity = "Limited",
			Icon = "rbxassetid://72979844194276",
			OnlyBuyOne = true
		},
		["Pinky Parcel"] = {
			Rarity = "Limited",
			Icon = "rbxassetid://98997814548120",
			OnlyBuyOne = true
		},
		["Blue Bonsai"] = {
			Rarity = "Limited",
			Icon = "rbxassetid://70549819137342",
			OnlyBuyOne = true
		},
		["Mew-FO"] = {
			Rarity = "Limited",
			Icon = "rbxassetid://109006373674636",
			OnlyBuyOne = true
		},
		Silkwings = {
			Rarity = "Limited",
			Icon = "rbxassetid://96856363692968",
			OnlyBuyOne = true
		},
		["Crested Dragon Wings"] = {
			Rarity = "Limited",
			Icon = "rbxassetid://71391632699285",
			OnlyBuyOne = true
		},
		["Citrus Sail"] = {
			Rarity = "Limited",
			Icon = "rbxassetid://92968151247016",
			OnlyBuyOne = true
		},
		Poyastar = {
			Rarity = "Limited",
			Icon = "rbxassetid://71470768742382",
			OnlyBuyOne = true
		},
		Polarastar = {
			Rarity = "Limited",
			Icon = "rbxassetid://76132986076590",
			OnlyBuyOne = true
		},
		Speakerwings = {
			Rarity = "Limited",
			Icon = "rbxassetid://129222264253078",
			OnlyBuyOne = true
		},
		["Jelly Cascade"] = {
			Rarity = "Limited",
			Icon = "rbxassetid://107727719529205",
			OnlyBuyOne = true
		},
		["Joyous Hat"] = {
			Rarity = "Limited",
			Icon = "rbxassetid://97557043143486",
			OnlyBuyOne = true
		},
		["Paper Plane"] = {
			Rarity = "Limited",
			Icon = "rbxassetid://127947776359104",
			OnlyBuyOne = true
		},
		Illuma = {
			Rarity = "Limited",
			Icon = "rbxassetid://134748987062680",
			OnlyBuyOne = true
		},
		["Gliding Thru Time"] = {
			Rarity = "Limited",
			Icon = "rbxassetid://108228422378760",
			OnlyBuyOne = true
		},
		["Cash Cruisin'"] = {
			Rarity = "Limited",
			Icon = "rbxassetid://121429439537617",
			OnlyBuyOne = true
		},
		["Radio (Legacy)"] = {
			Icon = "rbxassetid://91470454206677",
			Rarity = "Unique",
			Price = 1e999,
			OnlyBuyOne = true,
			Unpurchasable = true,
			BlockStorage = true
		},
		["Celestial Waders"] = {
			Rarity = "Unique",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Celestial Speed",
			Icon = "rbxassetid://122571276809006"
		},
		["Developer Boots"] = {
			Rarity = "Unique",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Walk on water, fish anywhere, move fast, and bypass all the pesky checks.",
			Icon = "rbxassetid://103391584370533",
			DEV = true
		},
		["The Accessory With Every Passive"] = {
			Rarity = "Unique",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "The Accessory With Every Passive",
			Icon = "rbxassetid://99837676797929",
			DEV = true
		},
		["The Instant Lure Accessory"] = {
			Rarity = "Unique",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			Icon = "rbxassetid://110832626149715",
			DEV = true
		},
		["The Instant Catch Accessory"] = {
			Rarity = "Unique",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			Icon = "rbxassetid://96379439743558",
			DEV = true
		},
		["Voided Glove"] = {
			Rarity = "Unique",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Rarely Duplicates Fish",
			Icon = "rbxassetid://85523037540474"
		},
		["Fish Radar"] = {
			Rarity = "Legendary",
			Icon = "rbxassetid://132119413174655",
			Price = 8000,
			OnlyBuyOne = true
		},
		GPS = {
			Rarity = "Uncommon",
			Icon = "rbxassetid://92660360174055",
			Price = 100,
			OnlyBuyOne = true
		},
		["Tempest Totem"] = {
			Icon = "rbxassetid://111420828878620",
			Rarity = "Rare",
			Price = 2000,
			LogEconomy = "Weather Totems"
		},
		["Stormbringer Totem"] = {
			Rarity = "Legendary",
			LogEconomy = "Weather Totems"
		},
		["Cursed Storm Totem"] = {
			Icon = "rbxassetid://136790393947471",
			Rarity = "Limited",
			Requirements = {
				DataInstanceRequiriment = {
					"Cache.CanPurchaseCursedTotem",
					true,
					"You need to unlock the item before purchasing!"
				}
			},
			Price = 1e999,
			Unpurchasable = true
		},
		["Blue Moon Totem"] = {
			Icon = "rbxassetid://137502747099470",
			Rarity = "Legendary",
			Price = 1200000,
			LogEconomy = true
		},
		["Windset Totem"] = {
			Icon = "rbxassetid://136991552523352",
			Rarity = "Rare",
			Price = 2000,
			LogEconomy = "Weather Totems"
		},
		["Sundial Totem"] = {
			Icon = "rbxassetid://92312729429964",
			Rarity = "Rare",
			Price = 2000,
			LogEconomy = true
		},
		["Smokescreen Totem"] = {
			Icon = "rbxassetid://83188252951749",
			Rarity = "Rare",
			Price = 2000,
			LogEconomy = "Weather Totems"
		},
		["Clearcast Totem"] = {
			Icon = "rbxassetid://119950785825004",
			Rarity = "Unusual",
			Price = 1000,
			LogEconomy = "Weather Totems"
		},
		["Aurora Totem"] = {
			Icon = "rbxassetid://118395203119312",
			Rarity = "Mythical",
			Price = 500000,
			LogEconomy = true
		},
		["Bloom Totem"] = {
			Icon = "rbxassetid://88878133394040",
			Rarity = "Mythical",
			Price = 1e999
		},
		["Meteor Totem"] = {
			Icon = "rbxassetid://115355936516601",
			Rarity = "Legendary",
			Price = 75000,
			LogEconomy = true
		},
		["Eclipse Totem"] = {
			Icon = "rbxassetid://129901654310517",
			Rarity = "Mythical",
			Price = 200000
		},
		["Starfall Totem"] = {
			Rarity = "Exotic",
			Price = 1e999,
			Icon = "rbxassetid://76652003542297"
		},
		["Blizzard Totem"] = {
			Icon = "rbxassetid://85704781083596",
			Rarity = "Mythical",
			Price = 150000,
			LogEconomy = true
		},
		["Rainbow Totem"] = {
			Rarity = "Exotic",
			Price = 1e999,
			Icon = "rbxassetid://122276989950222"
		},
		["Avalanche Totem"] = {
			Icon = "rbxassetid://92327910493662",
			Rarity = "Mythical",
			Price = 150000,
			LogEconomy = true
		},
		["Frost Moon Totem"] = {
			Icon = "rbxassetid://123757940172733",
			Rarity = "Limited",
			Price = 1e999
		},
		["Witches Ingredient"] = {
			Icon = "rbxassetid://119362054429925",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true
		},
		["Water Bubble"] = {
			Rarity = "Legendary",
			Icon = "rbxassetid://107429720771970",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true
		},
		["Basic Diving Gear"] = {
			Rarity = "Uncommon",
			Price = 3000,
			OnlyBuyOne = true,
			Icon = "rbxassetid://136442884304026"
		},
		["Advanced Diving Gear"] = {
			Rarity = "Unusual",
			Price = 15000,
			OnlyBuyOne = true,
			Icon = "rbxassetid://96303671606480"
		},
		["Basic Oxygen Tank"] = {
			Rarity = "Uncommon",
			Price = 1000,
			OnlyBuyOne = true,
			Icon = "rbxassetid://83639249054971"
		},
		["Beginner Oxygen Tank"] = {
			Rarity = "Unusual",
			Price = 3500,
			OnlyBuyOne = true,
			Icon = "rbxassetid://99510312809127"
		},
		["Intermediate Oxygen Tank"] = {
			Rarity = "Rare",
			Price = 10000,
			OnlyBuyOne = true,
			Icon = "rbxassetid://97662450942936"
		},
		["Advanced Oxygen Tank"] = {
			Rarity = "Legendary",
			Price = 25000,
			OnlyBuyOne = true,
			Icon = "rbxassetid://92171141146233"
		},
		["Winter Cloak"] = {
			Rarity = "Unusual",
			Icon = "rbxassetid://126260764220918",
			Price = 7500,
			OnlyBuyOne = true
		},
		["Glimmerfin Suit Lvl 1"] = {
			Icon = "rbxassetid://107405457740294",
			Rarity = "Uncommon",
			Price = 7500,
			OnlyBuyOne = true
		},
		["Glimmerfin Suit Lvl 2"] = {
			Icon = "rbxassetid://120382468340755",
			Rarity = "Rare",
			Price = 7500,
			OnlyBuyOne = true
		},
		["Glimmerfin Suit Lvl 3"] = {
			Icon = "rbxassetid://137334347694202",
			Rarity = "Exotic",
			Price = 7500,
			OnlyBuyOne = true
		},
		Flippers = {
			Rarity = "Unusual",
			Price = 9000,
			OnlyBuyOne = true,
			Icon = "rbxassetid://106541783599899"
		},
		["Super Flippers"] = {
			Rarity = "Legendary",
			Price = 30000,
			OnlyBuyOne = true,
			Icon = "rbxassetid://77150830165801"
		},
		Tidebreaker = {
			Icon = "rbxassetid://96313790284278",
			Rarity = "Mythical",
			Price = 40000,
			OnlyBuyOne = true
		},
		["Scoria Armor"] = {
			Icon = "rbxassetid://118576033360101",
			Rarity = "Secret",
			Price = 75000,
			BestiaryRequirement = {
				{
					Island = "Scoria Reach",
					Requirement = 20
				}
			},
			OnlyBuyOne = true
		},
		["Ancient Thread"] = {
			Icon = "rbxassetid://95024981046293",
			Rarity = "Legendary",
			Price = 1e999,
			CustomDescription = "Crafting Ingredient"
		},
		["Magic Thread"] = {
			Icon = "rbxassetid://100660194324054",
			Rarity = "Unusual",
			Price = 1e999,
			CustomDescription = "Crafting Ingredient"
		},
		["Lunar Thread"] = {
			Icon = "rbxassetid://128612131926926",
			Rarity = "Exotic",
			Price = 1e999,
			CustomDescription = "Crafting Ingredient"
		},
		["Dune Thread"] = {
			Icon = "rbxassetid://83195256581639",
			Rarity = "Mythical",
			Price = 1e999,
			CustomDescription = "Crafting Ingredient"
		},
		["Dusky Thread"] = {
			Icon = "rbxassetid://78219016897083",
			CustomDescription = "Woven from dusk's immortal glow...",
			Rarity = "Secret",
			Price = 1e999
		},
		Pickaxe = {
			Icon = "rbxassetid://127282783024970",
			Rarity = "Rare",
			Price = 5000,
			OnlyBuyOne = true
		},
		Nuke = {
			Icon = "rbxassetid://90159563024911",
			Rarity = "Nuclear",
			Price = 1e999
		},
		["Shady Nuke"] = {
			Icon = "rbxassetid://105128903195810",
			Rarity = "Nuclear",
			Price = 1e999
		},
		["Cursed Nuke"] = {
			Rarity = "Nuclear",
			Price = 1e999,
			Icon = "rbxassetid://94082809377060"
		},
		["Atomic Nuke"] = {
			Icon = "rbxassetid://132342769574799",
			Rarity = "Nuclear",
			Price = 1e999
		},
		["Love Nuke"] = {
			Icon = "rbxassetid://73719864449829",
			Rarity = "Limited",
			Price = 1e999
		},
		Fillionaire = {
			Rarity = "Unusual",
			Price = 1e999
		},
		["Treasure Map"] = {
			Rarity = "Rare",
			Price = 1e999,
			Icon = "rbxassetid://108306100605633",
			MaxCount = 50
		},
		["Handwritten Note"] = {
			Icon = "rbxassetid://77882688016637",
			Rarity = "Legendary",
			Price = 1e999
		},
		["Crossbow Bow"] = {
			Icon = "rbxassetid://83547928133882",
			NonPersistent = true,
			Rarity = "Legendary",
			Price = 1e999
		},
		["Crossbow Arrow"] = {
			Icon = "rbxassetid://123308681996974",
			NonPersistent = true,
			Rarity = "Legendary",
			Price = 1e999
		},
		["Crossbow Base"] = {
			Icon = "rbxassetid://75726507558155",
			NonPersistent = true,
			Rarity = "Legendary",
			Price = 1e999
		},
		TNT = {
			Icon = "rbxassetid://114043387788055",
			Rarity = "Rare",
			Price = 1e999
		},
		["Heart Of Zeus"] = {
			Icon = "rbxassetid://121068321385440",
			Rarity = "Mythical",
			Price = 1e999
		},
		["Zeus Storm Totem"] = {
			Icon = "rbxassetid://135887190150340",
			Rarity = "Legendary",
			Price = 150000,
			LogEconomy = true
		},
		["Poseidon Wrath Totem"] = {
			Icon = "rbxassetid://120192513435244",
			Rarity = "Legendary",
			Price = 150000,
			LogEconomy = true
		},
		["Regular Token"] = {
			Icon = "rbxassetid://79024189673715",
			Rarity = "Limited",
			Price = 1e999
		},
		["Elite Token"] = {
			Icon = "rbxassetid://124471048610523",
			Rarity = "Limited",
			Price = 1e999
		},
		["Bag of Presents"] = {
			Icon = "rbxassetid://128585825412229",
			Rarity = "Limited",
			Price = 1e999
		},
		["Skin Crate"] = {
			Rarity = "Exotic",
			Price = 1e999
		},
		Drill = {
			Icon = "rbxassetid://135265469589179",
			Rarity = "Rare",
			Price = 1e999,
			OnlyBuyOne = true
		},
		["GlimmerSuit Boots"] = {
			Rarity = "Exotic",
			Price = 1e999,
			OnlyBuyOne = true,
			Icon = "rbxassetid://119318778904147"
		},
		["Jack's Treads"] = {
			Rarity = "Limited",
			Price = 1e999,
			OnlyBuyOne = true,
			Icon = "rbxassetid://92808298804249"
		},
		["Amphibian Boots"] = {
			Rarity = "Limited",
			Price = 1e999,
			CustomDescription = "Provides increased speed on the ground, but does not boost gliders",
			OnlyBuyOne = true,
			Icon = "rbxassetid://97519202558062"
		},
		Soulwalker = {
			Rarity = "Limited",
			Price = 1e999,
			CustomDescription = "Higher acceleration & max walk speed",
			OnlyBuyOne = true,
			Icon = "rbxassetid://140506058237821"
		},
		["Angler's Glove"] = {
			Rarity = "Mythical",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Boosts all bait stats, 50% chance to not consume bait",
			Icon = "rbxassetid://117738201128302"
		},
		["Volcanic Gauntlets"] = {
			Rarity = "Mythical",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Periodically slashes the hooked fish, burning it for bonus Progress Speed",
			Icon = "rbxassetid://138218149779031"
		},
		["Challenger's Gauntlets"] = {
			Rarity = "Mythical",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Small chance to briefly freeze the fish whenever it moves",
			Icon = "rbxassetid://91515538159901"
		},
		["Abyssal Gauntlets"] = {
			Rarity = "Mythical",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Reveals the hooked fish's mutation at the start of the catch, +10% Universal Mutation Chance",
			Icon = "rbxassetid://116161659627235"
		},
		["Calm Gauntlets"] = {
			Rarity = "Mythical",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Increases Shiny & Sparkling chances, +25% Luck",
			Icon = "rbxassetid://76137678036860"
		},
		["Veiled Gauntlets"] = {
			Rarity = "Mythical",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Converts part of your Progress Speed into Forced Progress Speed on hunt fish",
			Icon = "rbxassetid://90996651289329"
		},
		["Mariana's Gauntlets"] = {
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "Holds a weaker echo of every layer's gauntlet",
			Icon = "rbxassetid://116171184131630"
		},
		["Weather Matrix"] = {
			Icon = "rbxassetid://105091683236350",
			Rarity = "Unique",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true
		},
		["Side Fins"] = {
			Icon = "rbxassetid://115173331612604",
			Rarity = "Rare",
			Price = 1e999
		},
		["Metal Panels"] = {
			Icon = "rbxassetid://114433909258088",
			Rarity = "Rare",
			Price = 1e999
		},
		["Back Fins"] = {
			Icon = "rbxassetid://121824409319025",
			Rarity = "Rare",
			Price = 1e999
		},
		Windows = {
			Icon = "rbxassetid://95488287599158",
			Rarity = "Rare",
			Price = 1e999
		},
		["Submarine Top"] = {
			Icon = "rbxassetid://83237600846092",
			Rarity = "Rare",
			Price = 1e999
		},
		["Ice Crystal"] = {
			Icon = "rbxassetid://87113404726717",
			Rarity = "Legendary",
			Price = 1e999
		},
		["Lava Crystal"] = {
			Icon = "rbxassetid://94081558964669",
			Rarity = "Legendary",
			Price = 1e999
		},
		["Magnifying Glass"] = {
			Icon = "rbxassetid://127487029816682",
			Rarity = "Legendary",
			Price = 1e999
		},
		["Bunker Key"] = {
			Icon = "rbxassetid://110505632473030",
			Rarity = "Legendary",
			Price = 1e999
		},
		["Sea 1 Conch"] = {
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true
		},
		["Mermaid’s Favor"] = {
			Icon = "rbxassetid://130292720571156",
			Rarity = "Legendary",
			Price = 1e999
		},
		Amulet = {
			Rarity = "Legendary",
			Icon = "rbxassetid://120571293392022",
			Price = 1e999,
			OnlyBuyOne = true
		},
		["Sporey's Soup"] = {
			Icon = "rbxassetid://138715887297191",
			Rarity = "Legendary",
			Price = 1e999
		},
		["Consumable XP"] = {
			Rarity = "Exotic",
			Price = 1e999
		},
		["Lobster Roll"] = {
			Icon = "rbxassetid://78264286273829",
			Rarity = "Rare",
			Price = 1e999
		},
		["Luck Potion"] = {
			Icon = "rbxassetid://92382493002977",
			Rarity = "Legendary",
			Price = 1e999
		},
		["Lure Speed Potion"] = {
			Icon = "rbxassetid://111978961667800",
			Rarity = "Legendary",
			Price = 1e999
		},
		["All Season Potion"] = {
			Icon = "rbxassetid://91163615704045",
			Rarity = "Legendary",
			Price = 1e999
		},
		["Glitched Potion"] = {
			Icon = "rbxassetid://109287553368574",
			Rarity = "Exotic",
			Price = 1e999
		},
		["Cleansing Potion"] = {
			Icon = "rbxassetid://70726344664820",
			CustomDescription = "Removes all buffs. Not consumed on use.",
			Rarity = "Unique",
			OnlyBuyOne = true,
			Price = 25,
			LocalCurrency = "Dark Wisps"
		},
		["Tasty Turkey Leg"] = {
			Icon = "rbxassetid://120609411597017",
			Rarity = "Limited",
			CustomDescription = "Eating will grant +50% Lure Speed",
			Price = 1e999,
			Unpurchasable = true
		},
		["Sunstone Present"] = {
			Icon = "rbxassetid://135637899580649",
			Rarity = "Limited",
			Price = 1e999,
			Unpurchasable = true
		},
		["Anglerfish Totem"] = {
			Icon = "rbxassetid://103572313678765",
			Rarity = "Divine Secret",
			Price = 1e999,
			Unpurchasable = true
		},
		["Puad Launcher"] = {
			Icon = "rbxassetid://83563670897836",
			Rarity = "Special",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "[Black Market Exclusive]",
			OnlyBuyOne = true
		},
		["Deep Lens"] = {
			Icon = "rbxassetid://134866303487266",
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "A telescope lens ground from abyssal materials. Unlocks the Abyssal Alignment anomaly."
		},
		["Stellar Lens"] = {
			Icon = "rbxassetid://96264549512663",
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "A telescope lens that glimmers with starlight. Unlocks the Celestial Congregation anomaly."
		},
		["Seasonal Lens"] = {
			Icon = "rbxassetid://75254272933115",
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "A telescope lens that shifts hue with the seasons. Unlocks the Evershifting Eclipse anomaly."
		},
		["Experimental Lens"] = {
			Icon = "rbxassetid://89452533540969",
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "An unstable telescope lens of questionable design. Unlocks the Meteoric Outburst anomaly."
		},
		["Moonlit Lens"] = {
			Icon = "rbxassetid://91015620173300",
			Rarity = "Exotic",
			Price = 1e999,
			Unpurchasable = true,
			OnlyBuyOne = true,
			CustomDescription = "A telescope lens bathed in blue moonlight. Unlocks the Lunar Eclipse anomaly."
		},
		Battery = {
			Icon = "rbxassetid://120328447494939",
			Rarity = "Rare",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Powers the Observatory telescope for 5 uses. Dr. Vega can recharge it with an Enchant Relic."
		},
		["Reinforced Battery"] = {
			Icon = "rbxassetid://97891862302025",
			Rarity = "Legendary",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Dr. Crookspine's improved battery. Powers the Observatory telescope for 20 uses."
		},
		["Battery Casing"] = {
			Icon = "rbxassetid://119138960830414",
			Rarity = "Common",
			Price = 1e999,
			Unpurchasable = true,
			CustomDescription = "Crafting Ingredient"
		}
	},
	KeyItems = {
		Bestiary = {
			Icon = "rbxassetid://111050495583456",
			Rarity = nil
		},
		["Equipment Bag"] = {
			Icon = "rbxassetid://121889271959208",
			Rarity = nil
		},
		Boats = {
			Icon = "rbxassetid://102498027167551",
			Rarity = nil
		},
		["Quest Book"] = {
			Icon = "rbxassetid://71412937179203",
			Rarity = nil
		},
		["Companion Satchel"] = {
			Icon = "rbxassetid://72228887858503",
			Rarity = nil
		},
		["Fischer's Journal"] = {
			Icon = "rbxassetid://71412937179203",
			Rarity = nil
		},
		["Magical Snow Globe"] = {
			Icon = "rbxassetid://91629455433400",
			Rarity = "Limited",
			Removed = true
		},
		["Magical Conch"] = {
			Icon = "rbxassetid://113698715110076",
			Rarity = "Limited",
			Removed = true
		}
	}
}

if game.GameId == 5750914919 then
	Items.Items["The Instant Lure Accessory"] = nil
	Items.Items["The Instant Catch Accessory"] = nil
end

return Items