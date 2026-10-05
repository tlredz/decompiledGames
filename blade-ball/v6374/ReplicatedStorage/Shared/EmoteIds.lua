local ReplicatedStorage = game:GetService("ReplicatedStorage")
local emoteNamesByName = {
	Emote1 = "Kick n' Clap",
	Emote2 = "Griddle Slide",
	Emote3 = "Eat the L!",
	Emote4 = "Jump Shuffle n' Slide!",
	Emote5 = "Twistin' & Turnin'",
	Emote6 = "Victory Vibe",
	Emote7 = "Clappin' Wheel",
	Emote8 = "Menacing",
	Emote9 = "Wavelight",
	Emote10 = "Skeleton Dance",
	Emote11 = "Ghost Walk",
	Emote12 = "Zombie Slide",
	Emote13 = "Headless Trix",
	Emote14 = "Oyesh Bounce",
	Emote15 = "Godlike",
	Emote16 = "Backflip",
	Emote17 = "Petty Clap",
	Emote18 = "Witch Ride",
	Emote19 = "Headless Dribble",
	Emote20 = "Ascend",
	Emote21 = "Breeze Commander",
	Emote22 = "Wave Rider",
	Emote23 = "Thunder Controller",
	Emote25 = "Thai Pride",
	Emote26 = "VIP Sit",
	Emote27 = "Cheering",
	Emote24 = "Dance Moves",
	Emote98 = "Firework"
}

for _, child in ipairs(ReplicatedStorage.Misc.Emotes:GetChildren()) do
	local emoteName = child:GetAttribute("EmoteName") or emoteNamesByName[child.Name]
	emoteNamesByName[child.Name] = emoteName
end

local emotesToIds = {}

for k, v2 in emoteNamesByName do
	emotesToIds[v2] = k
end

return {
	EmotesToIds = emotesToIds,
	IdsToEmotes = emoteNamesByName
}