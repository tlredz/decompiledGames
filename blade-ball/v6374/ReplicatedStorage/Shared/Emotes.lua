local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local emoteTypes = ReplicatedStorage2.Shared.EmoteTypes
return {
	Emote265_Duo = {
		VFX = "Emote265_Duo",
		Emote = ReplicatedStorage2.Misc.Emotes.Emote265,
		Play = require3(emoteTypes.EnableAndEmit)
	},
	Emote266_Duo = {
		VFX = "Emote266_Duo",
		Emote = ReplicatedStorage2.Misc.Emotes.Emote266,
		Play = require3(emoteTypes.EnableAndEmit)
	},
	Emote372_Duo = {
		VFX = "Emote372_Duo",
		Emote = ReplicatedStorage2.Misc.Emotes.Emote372,
		Play = require3(emoteTypes.EnableAndEmit)
	},
	Emote373_Duo = {
		VFX = "Emote373_Duo",
		Emote = ReplicatedStorage2.Misc.Emotes.Emote373,
		Play = require3(emoteTypes.EnableAndEmit)
	},
	Emote374_Duo = {
		VFX = "Emote374_Duo",
		Emote = ReplicatedStorage2.Misc.Emotes.Emote374,
		Play = require3(emoteTypes.EnableAndEmit)
	},
	Emote424_Duo = {
		VFX = "Emote424_Duo",
		Emote = ReplicatedStorage2.Misc.Emotes.Emote424,
		Play = require3(emoteTypes.EnableAndEmit)
	},
	Emote536_Duo = {
		VFX = "Emote536_Duo",
		Emote = ReplicatedStorage2.Misc.Emotes.Emote536,
		Play = require3(emoteTypes.EnableAndEmit)
	},
	Emote618_Duo = {
		VFX = "Emote618",
		Emote = ReplicatedStorage2.Misc.Emotes.Emote618,
		Play = require3(emoteTypes.EnableAndEmit)
	},
	Emote199 = {
		Emote = ReplicatedStorage2.Misc.Emotes.Emote199,
		VFX = "PhoenixRebirth",
		Play = require3(emoteTypes.Passive)
	},
	Emote216 = {
		Emote = ReplicatedStorage2.Misc.Emotes.Emote216,
		VFX = "MythicalEnchanter",
		Play = require3(emoteTypes.Passive)
	},
	Emote207 = {
		Emote = ReplicatedStorage2.Misc.Emotes.Emote207,
		VFX = "CelestialLevitation",
		Play = require3(emoteTypes.EnableAndEmit)
	},
	Emote648 = {
		Emote = ReplicatedStorage2.Misc.Emotes.Emote648,
		VFX = "Emote648",
		Play = require3(emoteTypes.Passive)
	},
	Emote695 = {
		Emote = ReplicatedStorage2.Misc.Emotes.Emote695,
		VFX = "Emote695",
		Play = require3(emoteTypes.Passive)
	},
	Emote696 = {
		Emote = ReplicatedStorage2.Misc.Emotes.Emote696,
		VFX = "Emote696",
		Play = require3(emoteTypes.Passive)
	},
	Emote697 = {
		Emote = ReplicatedStorage2.Misc.Emotes.Emote697,
		VFX = "Emote697",
		Play = require3(emoteTypes.Passive)
	}
}