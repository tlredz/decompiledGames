local result = {}
local RunService = game:GetService("RunService")
result.MaxTags = 8
local tags3 = {
	{
		Name = "Personality",
		Tags = {
			"🐢 #introvert",
			"🦁 #extrovert",
			"🌧️ #depressed",
			"🌈 #lgbtq",
			"🔥 #ambitious",
			"💭 #overthinker",
			"💀 #sarcastic",
			"🤡 #goofy",
			"🧊 #chill",
			"🕵️‍ #mysterious",
			"🦋 #sensitive",
			"😎 #coolvibes",
			"👽 #weirdo",
			"🐺 #lonewolf",
			"🧠 #intellectual",
			"🦉 #nightthinker",
			"🔒 #secretive",
			"🧙 #oldsouled",
			"🌀 #chaoticneutral",
			"🧠 #selfaware",
			"😐 #blankinside",
			"👁️ #observer",
			"🖤 #idontfitin",
			"💖 #kind",
			"😂 #funny",
			"🤝 #loyal",
			"😎 #confident",
			"🌪️ #chaotic",
			"🙈 #shy",
			"🌊 #calm",
			"🤫 #honest",
			"😊 #friendly",
			"🙇 #humble",
			"🧠 #smart",
			"🎨 #creative",
			"♟️ #strategic",
			"🧭 #leader",
			"🌟 #talented",
			"⚡ #fast-learner",
			"🧩 #problem-solver",
			"🖌️ #artsy",
			"🏃 #athletic",
			"🎬 #main-character",
			"🐶 #golden-retriever",
			"👻 #lurker",
			"🧠 #debater",
			"🤫 #quiet",
			"🎤 #talkative",
			"😅 #awkward",
			"📢 #loud",
			"💬 #chatty",
			"🍃 #nonchalant",
			"💅 #diva",
			"📈 #aurafarmer",
			"🤡 #incompetent",
			"🤢 #stinky",
			"🙄 #annoying",
			"🏚️ #hood",
			"😑 #bored"
		}
	},
	{
		Name = "Misc",
		ClientOrder = 0,
		Tags = {
			"⚡ #adhd",
			"🧩 #autism",
			"🔤 #dyslexia",
			"🔄 #ocd",
			"😰 #anxiety",
			"🎭 #ptsd",
			"🌗 #bipolar",
			"😰 #socialanxiety",
			"🌀 #bpd",
			"🦆 #duck",
			"🤑 #rich",
			"🥣 #broke"
		}
	},
	{
		Name = "Zodiac",
		Unique = true,
		Order = 2,
		Tags = {
			"♈ #aries",
			"♌ #leo",
			"♐ #sagittarius",
			"♋ #cancer",
			"♏ #scorpio",
			"♓ #pisces",
			"♊ #gemini",
			"♎ #libra",
			"♒ #aquarius",
			"♉ #taurus",
			"♍ #virgo",
			"♑ #capricorn"
		}
	},
	{
		Name = "Mood",
		Tags = {
			"🌞 #positivevibes",
			"🌧️ #sad",
			"☕ #moody",
			"🛌 #burntout",
			"💫 #dreamy",
			"🤬 #ragequit",
			"😴 #sleepy",
			"🤔 #deepthoughts",
			"🕳️ #inmyhead",
			"🧸 #clingy",
			"💔 #heartbroken",
			"🙃 #numb",
			"🩹 #healing",
			"🧍‍♂️ #lonely",
			"🔮 #manifesting",
			"😵‍ #mentalmess",
			"😳 #regretting",
			"🕳️ #foggybrain",
			"📦 #boxedfeelings",
			"🤯 #overstimulated",
			"😐 #mentallyblank",
			"😶‍ #dissociating",
			"😰 #panicmode",
			"⚫ #boba"
		}
	},
	{
		Name = "MBTI",
		Unique = true,
		Order = 1,
		Tags = {
			"🧠 #INTJ",
			"🌀 #INTP",
			"🦁 #ENTJ",
			"🎭 #ENTP",
			"🕯️ #INFJ",
			"🧸 #INFP",
			"🌞 #ENFJ",
			"🦋 #ENFP",
			"🧱 #ISTJ",
			"🧼 #ISFJ",
			"🦾 #ESTJ",
			"🎉 #ESFJ",
			"🧰 #ISTP",
			"🐚 #ISFP",
			"🕶️ #ESTP",
			"🎤 #ESFP"
		}
	},
	{
		Name = "Fashion",
		Tags = {
			"🌸 #cottagecore",
			"🧚 #fairycore",
			"👑 #princesscore",
			"🏰 #royalcore",
			"😇 #angelcore",
			"🖤 #grungestyle",
			"🕸️ #gothfashion",
			"😔 #emoaesthetic",
			"📚 #darkacademia",
			"💣 #punkstyle",
			"🎧 #indiestyle",
			"👁️‍🗨️ #altfashion",
			"💿 #y2k",
			"👟 #streetwear",
			"🧥 #highfashion",
			"💎 #luxurystyle",
			"🧼 #cleangirlaesthetic",
			"🥂 #oldmoney",
			"⚪ #minimal",
			"🍬 #kawaii",
			"🍭 #harajuku",
			"🕴️ #businesscasual",
			"👔 #preppystyle",
			"🎩 #vintagefashion",
			"🕰️ #retrostyle",
			"📸 #oldschoolfashion",
			"🧵 #tailoredlook",
			"💃 #beautiful",
			"🧸 #cute",
			"👗 #stylish",
			"💫 #gorgeous",
			"😎 #cool",
			"🖤 #edgy",
			"🌑 #dark-aesthetic",
			"⚪ #minimalist"
		}
	},
	{
		Name = "Music",
		Tags = {
			"🎸 #rock",
			"🎧 #lofi",
			"💥 #edm",
			"🎻 #classical",
			"🎤 #rap",
			"🎷 #jazz",
			"🎵 #pop",
			"🪕 #folk",
			"💿 #indie",
			"🥁 #alt",
			"🎼 #instrumental",
			"👑 #rnb",
			"🔥 #trap",
			"🧘 #ambient",
			"🦇 #emo",
			"📻 #oldschool",
			"🌈 #hyperpop",
			"💔 #sad-music",
			"🕯️ #acoustic",
			"🤘 #metal",
			"✨ #kpop"
		}
	},
	{
		Name = "Sports",
		Tags = {
			"🏀 #basketball",
			"⚽ #soccer",
			"🏐 #volleyball",
			"🏈 #football",
			"⚾ #baseball",
			"🏓 #pingpong",
			"🎾 #tennis",
			"🥋 #martialarts",
			"🏃 #trackstar",
			"🚴 #cycling",
			"🏊 #swimmer",
			"⛷️ #skiing",
			"🛹 #skater",
			"⛸️ #iceskating",
			"🥍 #lacrosse",
			"🥅 #hockey",
			"🤸 #gymnast",
			"🧗 #climber",
			"🌀 #rollerskater",
			"🥊 #boxing",
			"🎯 #archery",
			"🥌 #curlingcrew",
			"🧘 #yoga",
			"🛶 #paddle",
			"🥏 #frisbee",
			"🤾 #handball",
			"🏋️ #gym",
			"🏸 #badminton"
		}
	},
	{
		Name = "Games",
		Tags = {
			"⚔️ #rpg",
			"🔫 #fps",
			"🧱 #sandbox",
			"🎲 #strategy",
			"🧩 #puzzles",
			"🧟 #zombie",
			"🚗 #racing",
			"🧗 #platformer",
			"🏰 #fantasy",
			"🧃 #farming",
			"🧙 #storyfirst",
			"🕵️ #mystery",
			"👻 #horror",
			"🎮 #console",
			"🌐 #mmo",
			"🧍 #soloplayer",
			"🤝 #teambased",
			"🏆 #competitive",
			"💤 #idleplayer",
			"⚔️ #moba",
			"🎯 #obby",
			"🎮 #valorant",
			"⌨️ #leagueoflegends",
			"⛏️ #minecraft",
			"🚌 #fortnite"
		}
	},
	{
		Name = "Hobbies",
		Tags = {
			"✍️ #poetry",
			"🎨 #paint",
			"🎭 #theater",
			"🧵 #sewing",
			"🎧 #producer",
			"🧝 #cosplay",
			"🎮 #gamer",
			"🏀 #sports",
			"🎨 #art",
			"📚 #bookworm",
			"🎧 #music",
			"🧘 #meditation",
			"🛠️ #diy",
			"🧵 #crafts",
			"✍️ #writer",
			"🎬 #movies",
			"📷 #photography",
			"🧗 #outdoors",
			"🛍️ #shopping",
			"🎭 #drama",
			"📖 #reading",
			"🍳 #cooking",
			"🧦 #collecting",
			"💻 #techie",
			"🎤 #singing",
			"🎮 #consolegamer",
			"⛹️ #active",
			"🎲 #boardgames",
			"🌍 #traveling",
			"🏎️ #cars",
			"♟️ #chess",
			"💻 #gamedev",
			"🛌 #bedrotting",
			"🧟 #brainrot",
			"🎼 #musician",
			"🏜️ #unemployed",
			"🎭 #influencer"
		}
	},
	{
		Name = "Art",
		Tags = {
			"✏️ #drawing",
			"🎨 #painting",
			"✍️ #sketcher",
			"🖌️ #watercolor",
			"🧵 #textileart",
			"🧶 #fiberartist",
			"🖼️ #illustrator",
			"🧊 #digitalart",
			"🖋️ #inkartist",
			"🧷 #collageart",
			"📦 #3dart"
		}
	},
	{
		Name = "Aesthetic",
		Tags = {
			"☁️ #soft",
			"🌊 #oceanvibes",
			"🔮 #mysticenergy",
			"📼 #retro",
			"🌌 #spacecore",
			"🌙 #moonchild",
			"🍓 #strawberry",
			"💻 #digitaldream",
			"📖 #bookishvibes",
			"🐚 #seashellcore",
			"🧺 #picniccore",
			"🦋 #dreamycore",
			"🍵 #teaaesthetic",
			"🎧 #audiovibe",
			"🌻 #sunnylook",
			"🧣 #cozycore",
			"🌃 #nightaesthetic",
			"🌸 #springmood",
			"💫 #celestialvibes"
		}
	},
	{
		Name = "TV Genres",
		Tags = {
			"💥 #action",
			"😂 #comedy",
			"🎭 #k-drama",
			"👽 #science-fiction",
			"🤠 #western",
			"🧛 #supernatural",
			"🕵️ #crime",
			"🚓 #cop",
			"🧠 #mindbender",
			"👩‍⚖️ #legaldrama",
			"⚔️ #historical",
			"🐉 #epicsaga",
			"💖 #romcom",
			"😭 #tearjerker",
			"🎥 #realitytv",
			"📺 #sitcom",
			"🎤 #talentshow",
			"👑 #royaldrama",
			"🧃 #slowburn",
			"🔪 #truecrime",
			"🧪 #sci-docuseries",
			"🧒 #kidsclassic",
			"🧞 #animated",
			"🔁 #rewatchable",
			"🌍 #travel",
			"🧬 #documentary",
			"🎌 #anime"
		}
	},
	{
		Name = "Anime Genres",
		Tags = {
			"⚔️ #shonen",
			"🧃 #sliceoflife",
			"😵 #psychological",
			"🤖 #mecha",
			"🧙 #isekai",
			"💥 #battleanime",
			"👹 #supernaturalanime",
			"🌸 #romance",
			"🧸 #cuteanime",
			"😭 #sadending",
			"👻 #horroranime",
			"📚 #schoolsetting",
			"🐱 #animalanime",
			"🎤 #idolanime",
			"🌀 #trippyvibes",
			"🎮 #gameanime",
			"🚴 #sportsanime"
		}
	}
}
local count = 0
local v2 = {}
local tags = {}

for _, v3 in next, tags3, nil do
	for _, tag in next, v3.Tags, nil do
		v2[tag] = tostring(count)
		tags[tostring(count)] = tag
		count += 1
	end
end

local v3 = RunService:IsServer() and "Order" or "ClientOrder"
local v4 = {}
local tags2 = {}

for _, v5 in next, tags3, nil do
	if v5[v3] and v5[v3] <= 0 then
		v5[v3] = #tags3 + v5[v3]
	end
end

while true do
	local flag = true

	for k, v6 in next, tags3, nil do
		if not (v6[v3] and k ~= v6[v3]) then
			continue
		end

		table.remove(tags3, k)
		table.insert(tags3, v6[v3], v6)
		flag = false
		break
	end

	if not flag then
		continue
	end

	for _, v6 in next, tags3, nil do
		table.sort(v6.Tags, function(a, b)
			return a:gsub("[^a-zA-Z]", "") < b:gsub("[^a-zA-Z]", "")
		end)

		for _, tag in next, v6.Tags, nil do
			local v7 = tag:gsub("[^a-zA-Z]", "")

			if v4[v7] then
				print((`Duplicate tag found: {v7}! (In: {v6.Name})`))
			end

			table.insert(tags2, tag)
			v4[v7] = true
		end
	end

	function result.GetLayoutOrder(_, p: string)
		return table.find(result.Dump, p) or 1000000
	end

	function result.GetTagId(_, p: string)
		return v2[p]
	end

	function result.GetTagFromId(_, p: string)
		return tags[tostring(p)]
	end

	result.Tags = tags3
	result.Dump = tags2
	return result
end