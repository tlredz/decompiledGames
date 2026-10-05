local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.Utils.Utilities.Icons)
local UpdateLogs = {
	{
		Date = DateTime.fromUniversalTime(2026, 5, 24, 17),
		Title = "⚔️ Strike Tournament! 🦀",
		Description = [[
		🦀 Limited Quantity Emote: Crab Rave
		⚔️ Strike Tournament
		💎 Prismatic Gem Pack
		🗡️ 2 Swords
		💥 2 Explosions
		🕺 2 Emotes
		🐛 Bug Fixes
		]],
		Thumbnail = v:GetEmoteIcon("Crab Rave"),
		ItemIcons = {
			v:GetEmoteIcon("Crab Rave"),
			v:GetSwordIcon("Dual Prismatic Gem Scythe"),
			v:GetExplosionIcon("Pastel Prism Explosion")
		},
		SubDescription = "Can you get #1 in our Strike Tournament?",
		Subtext = "<font color=\"rgb(255, 215, 0)\">STRIKE TOURNAMENT</font>"
	},
	{
		Date = DateTime.fromUniversalTime(2026, 5, 2, 17),
		Title = "🤠 Sheriffs vs Outlaws!",
		Description = [[
		🤠 Sheriffs vs Outlaws LTM
		⭐ Sheriffs: Protect the Gold
		💨 Outlaws: Steal the Gold
		🗡️ 12 Swords
		💥 3 Explosions
		🕺 5 Emotes
		🗺️ 1 Map
		🐛 Bug Fixes
		]],
		Thumbnail = v:GetSwordIcon("Nebula Implosion"),
		ItemIcons = {
			v:GetSwordIcon("Sheriff Sword"),
			v:GetExplosionIcon("Nebula Implosion"),
			v:GetSwordIcon("Outlaw Sword")
		},
		SubDescription = "Sheriffs protect the gold, Outlaws steal it — whoever has the most wins!",
		Subtext = "<font color=\"rgb(255, 215, 0)\">SHERIFFS VS OUTLAWS</font>"
	},
	{
		Date = DateTime.fromUniversalTime(2026, 4, 25, 17),
		Title = "🤠 Wild West Battlepass!",
		Description = [[
		🤠 Wild West Battlepass
		🎯 NEW Bounty System
		⚙️ Performance Improvements
		🗡️ 32 Swords
		💥 12 Explosions
		🕺 8 Emotes
		🗺️ 2 Maps
		🐛 Bug Fixes
		]],
		Thumbnail = v:GetSwordIcon("Sheriff's Revolver"),
		ItemIcons = {
			v:GetSwordIcon("Sheriff's Revolver"),
			v:GetAbilityIcon("Fracture"),
			v:GetAbilityIcon("Time Hole")
		},
		SubDescription = "Saddle up! Complete the Wild West Battlepass for the Sheriff's Revolver!",
		Subtext = "<font color=\"rgb(255, 180, 80)\">WILD WEST BATTLEPASS</font>"
	},
	{
		Date = DateTime.fromUniversalTime(2026, 4, 18, 17),
		Title = "⚔️ Strike Tournament!",
		Description = [[
		⚔️ Strike Tournament
		🍀 48H Battlepass Luck
		⚙️ Lag Fixes
		🗡️ 6 Swords
		💥 5 Explosions
		🕺 4 Emotes
		🐛 Bug Fixes
		]],
		Thumbnail = v:GetSwordIcon("Cyborg Blade"),
		ItemIcons = { v:GetSwordIcon("Cyborg Blade") },
		SubDescription = "Can you get #1 in our Strike Tournament?",
		Subtext = "<font color=\"rgb(255, 215, 0)\">STRIKE TOURNAMENT</font>"
	},
	{
		Date = DateTime.fromUniversalTime(2026, 4, 12, 17),
		Title = "🐣 Easter Event!",
		Description = [[
		🥚 Egg Hunt
		🐰 Bunny Leap is Back!
		🐇 FREE Bunny UGC
		🔢 Limited Quantities
		🗡️ 12 Swords
		💥 15 Explosions
		🕺 8 Emotes
		🐛 Bug Fixes
		]],
		Thumbnail = v:GetSwordIcon("Easter Staff"),
		ItemIcons = {
			v:GetSwordIcon("Wolf Greatsword"),
			v:GetSwordIcon("Regret Blades"),
			v:GetSwordIcon("Higanbana Katana")
		},
		SubDescription = "Find 10 golden eggs and unlock the Easter Staff!",
		Subtext = "<font color=\"rgb(179, 218, 241)\">EASTER EVENT</font>"
	},
	{
		Date = DateTime.fromUniversalTime(2026, 4, 5, 17),
		Title = "⚡ Zeus' Storm!",
		Description = [[
		⚡ Mythology Battlepass
		🆕 New Ability: Zeus' Storm
		🗡️ 32 Swords
		💥 15 Explosions
		🕺 8 Emotes
		🗺️ 3 Maps
		🐛 Bug Fixes
		]],
		Thumbnail = v:GetAbilityIcon("Zeus' Storm"),
		ItemIcons = { v:GetAbilityIcon("Phantom"), v:GetAbilityIcon("Death Slash"), v:GetAbilityIcon("Necromancer") },
		SubDescription = "Freeze and stun everyone in place with the new Zeus' Storm ability!",
		Subtext = "<font color=\"rgb(255, 215, 0)\">MYTHOLOGY BATTLEPASS</font>"
	},
	{
		Date = DateTime.fromUniversalTime(2026, 3, 28, 17),
		Title = "🏷️ Tag! LTM",
		Description = [[
		🏷️ Tag! Limited Time Mode
		🎁 LTM Crate
		💃 Limited Quantity Emote
		🍀 7 Days Battlepass Luck
		🗡️ 5 Swords
		💥 3 Explosions
		🕺 6 Emotes
		🐛 Bug Fixes
		]],
		Thumbnail = v:GetEmoteIcon("Montagem Miau"),
		ItemIcons = { v:GetEmoteIcon("Montagem Miau"), v:GetExplosionIcon("Tag"), v:GetSwordIcon("Tag Sword") },
		SubDescription = "Eliminate others to grow your team — don't be left as the last solo standing!",
		Subtext = "<font color=\"rgb(255, 100, 100)\">TAG! LTM</font>"
	},
	{
		Date = DateTime.fromUniversalTime(2026, 3, 14, 17),
		Title = "⚔️ Item Duels!",
		Description = [[
		⚔️ Item Duels
		🏆 Strike Tournament
		🍀 48H Battlepass Luck
		🗡️ 9 Swords
		💥 5 Explosions
		🕺 4 Emotes
		🐛 Bug Fixes
		]],
		Thumbnail = v:GetSwordIcon("Whitefire Cleaver"),
		ItemIcons = {
			v:GetSwordIcon("Golden Crescent Bow"),
			v:GetSwordIcon("Whitefire Cleaver"),
			v:GetExplosionIcon("Item Duels")
		},
		SubDescription = "Put your items on the line in 1v1 Item Duels — winner takes all!",
		Subtext = "<font color=\"rgb(255, 215, 0)\">ITEM DUELS</font>"
	},
	{
		Date = DateTime.fromUniversalTime(2026, 3, 7, 17),
		Title = "🚀 Squad Royale!",
		Description = [[
		🚀 Squad Royale LTM
		👥 50 Player Mode
		🔢 Limited Quantities
		🗡️ 12 Swords
		💥 10 Explosions
		🕺 8 Emotes
		🐛 Bug Fixes
		]],
		Thumbnail = v:GetSwordIcon("Gravelight"),
		ItemIcons = { v:GetSwordIcon("Phantom Pact"), v:GetSwordIcon("Night Raver"), v:GetSwordIcon("Gravelight") },
		SubDescription = "Team up with friends, dodge 2 balls and a closing storm to claim victory!",
		Subtext = "<font color=\"rgb(100, 180, 255)\">SQUAD ROYALE</font>"
	},
	{
		Date = DateTime.fromUniversalTime(2026, 2, 22, 17),
		Title = "🤖 Overdrive LTM!",
		Description = [[
		🤖 Overdrive (Juggernaut) LTM
		🎰 Title Crate
		🗡️ 8 Swords
		🏷️ 6 Titles
		💥 5 Explosions
		🕺 5 Emotes
		🐛 Bug Fixes
		]],
		Thumbnail = v:GetSwordIcon("Overdrive"),
		ItemIcons = {
			v:GetSwordIcon("Overdrive"),
			v:GetExplosionIcon("Overdrive Explosion"),
			v:GetEmoteIcon("Mech Overdrive")
		},
		SubDescription = "Control a mech suit and destroy your enemies, or team up to take it down!",
		Subtext = "<font color=\"rgb(200, 100, 255)\">OVERDRIVE LTM</font>"
	},
	{
		Date = DateTime.fromUniversalTime(2026, 2, 14, 17),
		Title = "🏮 Chinese New Year!",
		Description = [[
		🏮 Chinese New Year Event
		💃 Limited Quantity Emote
		💝 20% off Gifts
		🗡️ 16 Swords
		💥 8 Explosions
		🕺 8 Emotes
		🐛 Bug Fixes
		]],
		Thumbnail = v:GetEmoteIcon("Love For You"),
		ItemIcons = {
			v:GetEmoteIcon("Love For You"),
			v:GetSwordIcon("Chinese New Year Sword"),
			v:GetExplosionIcon("Lantern Explosion")
		},
		SubDescription = "Locate the Chinese New Year NPC in the lobby and collect daily rewards!",
		Subtext = "<font color=\"rgb(255, 80, 80)\">CHINESE NEW YEAR</font>"
	},
	{
		Date = DateTime.fromUniversalTime(2026, 2, 9, 17),
		Title = "🌌 Infinite Battlepass!",
		Description = [[
		♾️ Galactic Battlepass
		💥 DUO Strike Tournament
		🆕 New Ability: Event Horizon
		💝 Valentine's Quest
		🔢 Limited Stocks
		🗡️ 48 Swords
		💥 26 Explosions
		🕺 23 Emotes
		🗺️ 4 Maps
		🐛 Bug Fixes
		]],
		Thumbnail = v:GetAbilityIcon("Event Horizon"),
		ItemIcons = {
			v:GetSwordIcon("Cosmic Wraithclaws"),
			v:GetAbilityIcon("Event Horizon"),
			v:GetSwordIcon("Angelic Cleaver")
		},
		SubDescription = "The Galactic Battlepass is now endless — and a black hole pulls everyone in!",
		Subtext = "<font color=\"rgb(100, 180, 255)\">GALACTIC BATTLEPASS</font>"
	},
	{
		Date = DateTime.fromUniversalTime(2026, 1, 24, 17),
		Title = "⚖️ Ability Changes",
		Description = [[
		⚖️ Ability Balancing
		🔵 Phase Bypass
		💀 Necromancer
		🌀 Singularity
		🦾 Titan
		🔮 Quantum Arena
		🐰 Bunny Leap
		🍀 2x Battlepass Luck
		]],
		Thumbnail = v:GetAbilityIcon("Singularity"),
		ItemIcons = { v:GetAbilityIcon("Necromancer"), v:GetAbilityIcon("Titan"), v:GetAbilityIcon("Bunny Leap") },
		SubDescription = "Major ability changes — check the full breakdown in our Discord!",
		Subtext = "<font color=\"rgb(179, 218, 241)\">ABILITY BALANCING</font>"
	},
	{
		Date = DateTime.fromUniversalTime(2026, 1, 17, 17),
		Title = "❓ Mystery Ball is Back!",
		Description = [[
		❓ Mystery Ball LTM
		⚡ Fast Ball
		🌀 Curve Ball
		👻 Fake Ball
		2️⃣ 2 Ball
		💣 Bomb Ball
		🔷 Geometry Ball
		🍀 2x Battlepass Luck
		]],
		Thumbnail = v:GetSwordIcon("Holy Blade"),
		ItemIcons = {
			v:GetSwordIcon("Holy Blade"),
			v:GetExplosionIcon("Mystery Ball"),
			v:GetSwordIcon("Mystery Sword")
		},
		SubDescription = "Mystery Ball is back with new effects — what will the ball do next?",
		Subtext = "<font color=\"rgb(255, 215, 0)\">MYSTERY BALL</font>"
	},
	{
		Date = DateTime.fromUniversalTime(2026, 1, 3, 17),
		Title = "🎆 2026 Event!",
		Description = [[
		🎆 2026 New Year Quest
		🦠 New Ability: Virus
		🔑 Trade Pin Reset
		🐛 Bug Fixes
		]],
		Thumbnail = v:GetSwordIcon("Afterglow"),
		ItemIcons = { v:GetSwordIcon("Afterglow"), v:GetAbilityIcon("Virus"), v:GetExplosionIcon("2026") },
		SubDescription = "Happy New Year! Complete all quests to obtain the Afterglow sword!",
		Subtext = "<font color=\"rgb(179, 218, 241)\">HAPPY NEW YEAR</font>"
	}
}
table.sort(UpdateLogs, function(a, b)
	return a.Date.UnixTimestamp > b.Date.UnixTimestamp
end)
return UpdateLogs