local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShopLibrary = require(ReplicatedStorage.Modules.ShopLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)

local function generate_weapon_note(p, list, ...)
	local timeUntilWeaponRelease = ShopLibrary:GetTimeUntilWeaponRelease(list)

	if timeUntilWeaponRelease > 0 then
		return {
			{ "Header", p .. ".   " .. string.rep("?", #list) },
			{ "Description", "⏰ Releases in " .. Utility:TimeFormat2(timeUntilWeaponRelease, 2) }
		}
	end

	local result = {
		{ "Header", p .. ".   " .. list },
		{ "Description", "🎊 RELEASED" }
	}

	for _, v in pairs({ ... }) do
		table.insert(result, { "Description", v })
	end

	return result
end

return {
	Name = script.Name,
	Date = "November 28, 2024",
	Title = "UPDATE 7 🔫",
	Image = math.random() < 0.5 and "rbxassetid://129689447476971" or "rbxassetid://128718997056742",
	Code = nil,
	Changes = {
		{ "Title", "🕹 NEW WEAPONS" },
		{
			"Description",
			"The massive Weapons Update is here! There will be nearly a dozen new weapons added to the game WEEKLY starting NOW!"
		},
		{
			generate_weapon_note,
			1,
			"Energy Rifle",
			"Shoot an ∞ amount of energy beams that bounce multiple times around walls!",
			"The \"Hacker Rifle\" skin is now available in the Skin Case!"
		},
		{
			generate_weapon_note,
			2,
			"Energy Pistols",
			"Melt your enemies with the newest, fastest, ∞ ammo weapon!",
			"The \"Hacker Pistols\" skin is now available in the Skin Case!"
		},
		{
			generate_weapon_note,
			3,
			"Crossbow",
			"A light-weight, hipfire-accurate sniper!",
			"The \"Pixel Crossbow\" skin is now available in the Skin Case!"
		},
		{
			generate_weapon_note,
			4,
			"Daggers",
			"Double jump and burst your enemies down like a ninja!",
			"The \"Aces\" skin is now available in the Skin Case!"
		},
		{
			generate_weapon_note,
			5,
			"Battle Axe",
			"This heavy-hitting, spin-attacking melee will crush your enemies!",
			"The \"The Shred\" skin is now available in the Skin Case!"
		},
		{
			generate_weapon_note,
			6,
			"Satchel",
			"The Grenade's cousin is here — throw multiple of these explosives and detonate them at will!",
			"The \"Advanced Satchel\" skin is now available in the Skin Case!"
		},
		{
			generate_weapon_note,
			7,
			"War Horn",
			"Empower your entire team and charge them into battle!",
			"The \"Trumpet\" skin is now available in the Skin Case!"
		},
		{
			generate_weapon_note,
			8,
			"Riot Shield",
			"Just a huge chunk of metal. Blocks most damage sources!",
			"The \"Door\" skin is now available in the Skin Case!"
		},
		{
			generate_weapon_note,
			9,
			"Spray",
			"This five-round burst secondary will either melt your enemies or get you in trouble with the law (or both)!",
			"The \"Lovely Spray\" skin is now available in the Skin Case!"
		},
		{
			generate_weapon_note,
			10,
			"Gunblade",
			"The final weapon in this massive Weapons Update - a gun that can also be used as a melee!",
			"The \"Hyper Gunblade\" skin is now available in the Skin Case!"
		},
		{ "Title", "⚡ ENERGY BUNDLE" },
		{ "Header", "Contains the following:" },
		{ "Description", "The brand new Energy Rifle weapon!" },
		{ "Description", "The brand new Energy Pistols weapon!" },
		{ "Description", "Apex Rifle skin for the Energy Rifle!" },
		{ "Description", "Apex Pistols skin for the Energy Pistols!" },
		{ "Description", "Exclusive Beacon finisher for all weapons!" },
		{ "Description", "Exclusive .dll wrap for all weapons!" },
		{ "Description", "Exclusive Energy Cell charm for all weapons!" },
		{ "Header", "Now available in the Shop!" },
		{ "Title", "🏡 MAPS" },
		{
			"Description",
			"Station changes — adjusted spawn points, extended back wall of the house, added forklift between trains, & changed up the interior flow for the center building"
		},
		{
			"Description",
			"Graveyard changes — adjusted spawn points, removed the underground & basement & steeple interior, & revamped the chapel"
		},
		{ "Description", "Dashing through the water in Splash & Big Splash will no longer eliminate you!" },
		{ "Description", "NEW Big Graveyard map — specifically designed for larger lobbies!" },
		{ "Description", "Big Splash, Big Graveyard, & Docks have been added to Free For All, Team Deathmatch!" },
		{ "Description", "Big Graveyard has been added to 1v1v1 & 2v2v2!" },
		{ "Title", "🔥 SHOP" },
		{ "Description", "NEW Energy Bundle - Contains the brand new Energy Rifle, Energy Pistols, & more!" },
		{
			"Description",
			"NEW Skin Case content - As the brand new weapons release weekly, a skin for each of them will also release inside of the Skin Case!"
		},
		{
			"Description",
			"The Damasucs & Black Damascus wraps have been replaced with the brand new, limited time Empress & Pixel Blight wraps!"
		},
		{ "Title", "🎨 COSMETICS" },
		{
			"Description",
			"New skins can be found in the new Energy Bundle & in the Skin Case as new weapons release every week!"
		},
		{ "Description", "NEW Shadore Wrap - Win with or against @ShadowTrojan to earn this brand new wrap!" },
		{ "Description", "NEW Brianore Wrap - Win with or against @Brian1KB to earn this brand new wrap!" },
		{ "Description", "NEW Boomore Wrap - Win with or against @GreatGuyBoom to earn this brand new wrap!" },
		{ "Description", "NEW ShadowTrojan Charm - Eliminate @ShadowTrojan to earn this brand new charm!" },
		{ "Description", "NEW Brian1KB Charm - Eliminate @Brian1KB to earn this brand new charm!" },
		{ "Description", "NEW GreatGuyBoom Charm - Eliminate @GreatGuyBoom to earn this brand new charm!" },
		{ "Description", "NEW Kaye Charm - Eliminate @swaglord_KAYE to earn this brand new charm!" },
		{ "Description", "NEW Karful Charm - Eliminate @Karfulol to earn this brand new charm!" },
		{ "Description", "NEW Khayri Charm - Eliminate @Khxyri to earn this brand new charm!" },
		{ "Title", "🔫 BALANCE CHANGES" },
		{ "Header", "Flamethrower" },
		{ "Description", "📝 \"The Flamethrower should keep it's current power but at a shorter distance\"" },
		{ "Description", "🔻 Range decreased from 27studs → 26studs" },
		{ "Header", "Revolver" },
		{ "Description", "📝 \"We're reducing the Revolver's overall power without changing basic interactions\"" },
		{ "Description", "🔻 Damage reduced from 33 → 30" },
		{ "Header", "Slingshot" },
		{ "Description", "📝 \"The projectile changes weakened the Slingshot and are being reverted\"" },
		{ "Description", "➖ Projectile speed increased from 150studs/s → 300studs/s" },
		{ "Description", "➖ Projectile elasticity decreased from 100% → 50%" },
		{ "Description", "💪 Projectile hitbox size increased from 0.75studs → 5studs" },
		{ "Header", "Grenade" },
		{
			"Description",
			"📝 \"This mechanic turned the Grenade into something completely different and should instead be fleshed out into a new weapon\""
		},
		{ "Description", "🔻 Can no longer be detonated on hit" },
		{ "Header", "Other" },
		{ "Description", "💪 Auto Shoot will no longer trigger while noscoping with Sniper" },
		{ "Description", "💪 All projectile-based weapons now have extremely consistent hitboxes" },
		{ "Title", "🛠 OTHER" },
		{ "Description", "You can now pick a weapon at random in a duel!" },
		{ "Description", "The Elimination Feed now displays assists!" },
		{ "Description", "You can now see the airborne effect under other players' feet!" },
		{
			"Description",
			"The following wraps have received visual improvements - Pink Glitter, Sensite, Nosnite, & Nekore!"
		},
		{ "Description", "The Water Uzi skin now has a blue muzzle flash!" },
		{
			"Description",
			"The Lasergun 3000 colors were changed to be more consistent with what we consider to be \"laser\" themed VS \"energy\" themed"
		},
		{
			"Description",
			"The Spooky Event is over — leftover candy has been converted into Haunted Chests, all of the Spooky shop items have been removed, & maps have been reverted back to normal"
		},
		{ "Title", "🐛 BUG FIXES" },
		{ "Description", "Fixed several user interface related bugs" },
		{
			"Description",
			"Fixed a bug where turning your HUD off prevented you from spinning viewmodels in the Weapons page"
		},
		{ "Description", "Fixed a bug where sometimes stepping off the duel pads wouldn't remove you from the queue" },
		{ "Description", "Fixed a bug with Revolver where you could cancel it's ability by simply shooting during it" },
		{
			"Description",
			"Fixed a bug with Mobile where the keyboard would get permanently stuck when chatting during the teleport screen"
		},
		{ "Description", "Fixed a bug where certain fire particles would obstruct vision" },
		{ "Description", "Fixed a bug where breaking windows/targets/other objects played finisher effects" },
		{ "Description", "Fixed a rare bug where some weapons would incorrectly display as MAX level" },
		{ "Description", "Fixed a rare bug that softlocked players that quick attacked right before being frozen" },
		{ "Description", "Fixed a rare bug that allowed you to run really fast" },
		{ "Title", "📜 A NOTE FROM THE DEVELOPERS" },
		{
			"Description",
			"Hey everyone, we hope you enjoy these next few weeks as we release a ton of brand new weapons for the first time in months!"
		},
		{
			"Description",
			"To be further transparent, our next update is planned to be the Winter/Festive update coming out in just a few weeks!"
		},
		{
			"Description",
			"Our plan for the highly anticipated Ranked mode has evolved into a much bigger update, which we now plan to release at the beginning of the new year."
		},
		{
			"Description",
			"We want to make sure Ranked is an amazing experience on release, but we've been backed up with these necessary holiday updates. We thank you all for understanding, it'll be worth the wait!"
		}
	}
}