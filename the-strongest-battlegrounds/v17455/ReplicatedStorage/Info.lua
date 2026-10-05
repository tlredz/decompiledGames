local createVector = vector.create
local clones = {}

if not game.Players.LocalPlayer then
	local DataStoreService = game:GetService("DataStoreService")
	DataStoreService:GetDataStore("build_savesA")
end

local v = { createVector(32.069, 20, 2.727), createVector(32.069, 5, 2.727), (createVector(5, 5, 5)) }

local function parse_visible(gUIStackable)
	if gUIStackable:sub(1, 7) ~= "visible" then
		return nil
	end

	local result = {}

	for k2 in gUIStackable:sub(9):gmatch("[^.]+") do
		table.insert(result, k2)
	end

	return result
end

local v2 = nil
v2 = {
	VCserver = 131048399685555,
	KJserver = 0,
	EarlyAccess = "Zombie",
	UFWrequirement = 750,
	BuildModeStorage = 33,
	DodgeAnimations = {
		133094662049155,
		134711731729986,
		76963965406296,
		92546791251633,
		128188725134114,
		109088632860488,
		78339272602733,
		127015697036075
	},
	GUIStackables = {
		["Cape Customization"] = "delete",
		["Kill Sound"] = "delete",
		["Awakening Outfit"] = "delete",
		Emotes = "visible",
		Gifting = "visible",
		Cosmetics = "visible.GUI",
		GlobalCatalogueGui = "visible.MainPanel",
		Ranked = "visible.Container.RankedOther",
		serverlist = "visible.Serverlist",
		charcreator = "visible.MainPanel"
	},
	hideGUI = function(caller)
		local localPlayer = game.Players.LocalPlayer
		local children = localPlayer.PlayerGui:GetChildren()
		localPlayer.Character.Communicate:FireServer({
			Goal = "Delete Guis",
			guis = children,
			caller = caller
		})

		for _, child in pairs(children) do
			local gUIStackable = v2.GUIStackables[child.Name]

			if not gUIStackable then
				continue
			end

			local v3 = parse_visible(gUIStackable)

			if gUIStackable == "delete" then
				local Debris = game:GetService("Debris")
				Debris:AddItem(child, 0)
			elseif v3 and child ~= caller then
				if #v3 == 0 then
					local imageLabel = child:FindFirstChild("ImageLabel") or child:FindFirstChild("Frame")

					if imageLabel then
						imageLabel.Visible = true
						imageLabel.Visible = false
					end
				elseif v3[1] == "GUI" then
					child.Enabled = true
					child.Enabled = false
				else
					for _, childName in pairs(v3) do
						child = child:FindFirstChild(childName)
					end

					if child then
						child.Visible = true
						child.Visible = false
					end
				end
			end
		end
	end,
	section = function(value)
		local count = #value
		local v3 = 0
		local result = {}

		for i = 1, rawget(v2, "BuildModeStorage") do
			local v4 = count <= v3 + 1 and 1 or 3000000
			local v5 = string.sub(value, math.clamp(v3 + 1, 0, count), (math.clamp(v3 + v4, 0, count)))
			v3 = math.clamp(v3 + v4, 0, count)
			result[i] = v5

			if #value <= v3 then
				break
			end
		end

		return result
	end,
	formatNumber = function(p)
		local v3 = tostring(p)

		repeat
			local v4
			v3, v4 = v3:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
			k = v4
		until k == 0

		return v3
	end,
	getSI = function(p)
		local v3 = {
			"B",
			"KB",
			"MB",
			"GB",
			"TB",
			"PB",
			"EB"
		}
		local v4 = 1

		while p >= 1000 and v4 < #v3 do
			p /= 1000
			v4 += 1
		end

		return string.format("%.2f %s", p, v3[v4])
	end,
	Badges = {
		[1] = 3057416426456972,
		[10] = 3114670201603542,
		[100] = 3006399776257311,
		[1000] = 268490457371003,
		[10000] = 341084106898320,
		[100000] = 2724124286915993,
		[1000000] = 1257999597959356
	},
	KeyOffsets = {
		CFrame.new(
			0.0000667572021484375,
			2.384185791015625e-7,
			-3.6912670135498047,
			-0.965471088886261,
			-8.742277657347586e-8,
			0.26051023602485657,
			0.26051023602485657,
			-4.371138828673793e-8,
			0.965471088886261,
			-7.301689919358978e-8,
			1,
			6.497661075854921e-8
		),
		CFrame.new(
			0.0000667572021484375,
			1.2685961723327637,
			-3.01324462890625,
			1,
			0,
			0,
			0,
			-4.371138828673793e-8,
			1,
			0,
			-1,
			-4.371138828673793e-8
		),
		CFrame.new(0.120067596, 0.759999752, -2.7800312, 1, 0, 0, 0, -4.37113883e-8, 1, 0, -1, -4.37113883e-8),
		CFrame.new(
			0.0000667572021484375,
			0,
			-2.071981430053711,
			1,
			0,
			0,
			0,
			-4.371138828673793e-8,
			1,
			0,
			-1,
			-4.371138828673793e-8
		),
		CFrame.new(0.0000667572021, 0.271313667, -2.80003071, 1, 0, 0, 0, -4.37113883e-8, 1, 0, -1, -4.37113883e-8),
		CFrame.new(
			0.0000667572021,
			0.589999676,
			-2.11003113,
			0.979179561,
			-0.150505424,
			0.136218935,
			-0.134637803,
			0.0206945483,
			0.990678728,
			-0.151921526,
			-0.988392532,
			-4.33039418e-8
		),
		CFrame.new(
			0.0000667572021484375,
			-0.3000001907348633,
			-3.000030517578125,
			1,
			0,
			0,
			0,
			-4.371138828673793e-8,
			1,
			0,
			-1,
			-4.371138828673793e-8
		),
		CFrame.new(
			6.7572022999229375e-6,
			-1.5006359815597534,
			-2.6260547637939453,
			1,
			0,
			0,
			0,
			-4.371138828673793e-8,
			1,
			0,
			-1,
			-4.371138828673793e-8
		),
		CFrame.new(
			0.0000667572021484375,
			0.09999966621398926,
			-2.9592037200927734,
			1,
			0,
			0,
			0,
			-4.371138828673793e-8,
			1,
			0,
			-1,
			-4.371138828673793e-8
		),
		(CFrame.new(
			0.0000667572021,
			-0.839160442,
			-2.38934708,
			-1,
			-8.74227766e-8,
			8.74227695e-8,
			8.74227766e-8,
			-4.37113883e-8,
			1,
			-8.74227695e-8,
			1,
			4.37113954e-8
		))
	},
	DonationProducts = {
		["1"] = 1774570749,
		["10"] = 1774570799,
		["100"] = 1774570910,
		["1,000"] = 1774570961,
		["10,000"] = 1774571012,
		["100,000"] = 1774571302,
		["1,000,000"] = 1774571398
	},
	GetSerial = function(p)
		local integer = Random.new():NextInteger(-10000000000, 10000000000)
		local v3 = math.floor(p.Position.X) + math.floor(p.Position.Y) + math.floor(p.Position.Z)
		local v4 = math.random(-100, 100)
		local v5 = ""

		for _ = 1, Random.new():NextNumber(1, 5) do
			local v6 = string.char(math.random(97, 122))

			if math.random(1, 2) == 1 then
				v6 = v6:upper()
			end

			v5 ..= v6
		end

		if math.random(1, 2) == 1 then
			return tostring(integer + v3 + v4) .. v5
		end

		return v5 .. tostring(integer + v3 + v4)
	end,
	ValidKeys = {
		Enum.KeyCode.Q,
		Enum.KeyCode.B,
		Enum.KeyCode.ButtonX,
		Enum.KeyCode.ButtonY,
		Enum.KeyCode.ButtonB,
		Enum.KeyCode.ButtonA,
		Enum.KeyCode.DPadUp,
		Enum.KeyCode.Space,
		Enum.KeyCode.W,
		Enum.KeyCode.A,
		Enum.KeyCode.S,
		Enum.KeyCode.D,
		Enum.KeyCode.F,
		Enum.KeyCode.G,
		Enum.KeyCode.V
	},
	ValidProperties = {
		"Text",
		"MeshID",
		"MeshScale",
		"MeshTextureID",
		"TextSize",
		"TextFont",
		"TextColor",
		"TextTransparency",
		"TextOutline",
		"EmitLight",
		"Range",
		"Brightness",
		"Anchored",
		"Collision",
		"Deadly",
		"Destructible",
		"Fragile",
		"Transparency",
		"CurrentMoves",
		"CurrentGears",
		"Bouncy",
		"Heals",
		"ResetsCooldowns",
		"GivesAwakening",
		"Shape",
		"Checkpoint",
		"Shadow",
		"NoAttack"
	},
	ValidClasses = { "SpawnLocation", "Part" },
	Limited = {
		{
			ID = 2461465333,
			Name = "Final Stand"
		},
		{
			ID = 2461465736,
			Name = "Boundless Rage"
		},
		{
			ID = 2662391516,
			Name = "Eternal Seal"
		},
		{
			ID = 3234349672,
			Name = "The Strongest"
		},
		{
			ID = 3234351421,
			Name = "The Fallen"
		},
		{
			ID = 3234350785,
			Name = "Divine Form"
		},
		{
			ID = 3234352091,
			Name = "My Brother"
		},
		{
			ID = 3234382059,
			Name = "Inner Rage"
		},
		{
			ID = 3290611874,
			Name = "Emerge"
		},
		{
			ID = 3290612178,
			Name = "Final Spark"
		},
		{
			ID = 3290612035,
			Name = "True Aura"
		},
		{
			ID = 3291156759,
			Name = "Last Will"
		},
		{
			ID = 3290611947,
			Name = "Shadow Eruption"
		},
		{
			ID = 3296113569,
			Name = "Wombo Combo"
		},
		{
			ID = 3593568642,
			Name = "Lifeform"
		},
		{
			ID = 3593568382,
			Name = "Pocket Dimension"
		},
		{
			ID = 3606576943,
			Name = "Speedster"
		},
		{
			ID = 3606577024,
			Name = "Beast Form"
		},
		{
			ID = 3606576903,
			Name = "Lifetime Barrage"
		},
		{
			ID = 3710452900,
			Name = "Nuclear Impact"
		},
		{
			ID = 3710453083,
			Name = "Final Bomb"
		},
		{
			ID = 3606576857,
			Name = "Lightning Blitz"
		}
	},
	TitleDescriptions = {
		["Rank Title"] = "A symbol of your standing, determining your rank from C-Class to the elite S-Class.",
		["Duel Title"] = "Are you a mere champion or an entire legend? Find out in duels!",
		["[The Red Monarch]"] = "Ruler of all things crimson, probably has a throne made of pure vibes.",
		["[The Clown]"] = "Master of chaos and bad jokes—step into their circus at your own risk.",
		["[oatmeal 🐐]"] = "The undisputed oatmeal champion, the GOAT of breakfast and beyond.",
		["awesome programmer"] = "Probably spends more time coding than sleeping—respect!",
		["ohio animator"] = "Bringing animations straight outta ohio.",
		Archangel = "Might smite you or bless you—depends on their mood.",
		["Top G"] = "Certified alpha energy, no debate.",
		GOOBER = "The biggest goober around, but in the best way possible.",
		ANIMATOR = "A title for the one who makes limbs move beautifully.",
		["[Dragon Sin🐉]"] = "A true beast, but probably still sleeps like a lazy lizard.",
		brah = "brah...",
		["🐟"] = "Just keep swimming, just keep swimming...",
		["🐧"] = "Waddles into battle like an absolute legend.",
		["The Strongest Penguin"] = "If there was a penguin fight club, this one would run it.",
		["The Holy One"] = "Radiates divine energy... or just really likes medieval titles.",
		["[The White Heart]"] = "A heart so pure, even snow is jealous.",
		["[Moonlights Illumination]"] = "Shining bright in the night, but probably sleeps all day.",
		["GOLDEN ARROW"] = "Shoots for the stars—probably never misses.",
		["News Caster"] = "Breaking news: This person is awesome.",
		["The Shadow Monarch"] = "Commanding an army of shadows, but still afraid of the dark.",
		thug = "A true gangster... but only in video games.",
		["🐒"] = "Monkey.",
		["[The Perfect Lifeform]"] = "Too perfect for this world—probably an alien.",
		["🧟"] = "Might be undead, but still cooler than most people.",
		["funny guy"] = "Certified comedian or just someone who laughs at their own jokes.",
		["Restless Gambler"] = "Always rolling the dice, even when they shouldn’t.",
		["3 - 0"] = "Losing so hard, it had to be their title.",
		["[ANIMATOR]"] = "Another animator? Y’all are multiplying.",
		["Guy with Cool Shades"] = "Probably owns at least five pairs of sunglasses.",
		["[THE SCULPTOR]"] = "Chiseling masterpieces or just sculpting chaos—who knows?",
		["[BEST VFX ARTIST]"] = "If your screen is exploding, blame this one.",
		OWNER = "The one and only...🍟",
		["Court of the Crimson King"] = "Majestic and probably listens to way too much prog rock.",
		["[TESTER]"] = "Breaking things so you don’t have to.",
		["[Yao Ming]"] = "Towering over the competition, probably dunks on noobs for fun.",
		["[🎸]"] = "Strumming through life, one epic riff at a time.",
		["[🦋]"] = "Flutters into chaos with grace—don’t underestimate the wings.",
		["[Strongest Sorcerer Available]"] = "Casting spells so strong, even the game lags.",
		["[🥀]"] = "Beautifully tragic, like a rose that stabs back.",
		["[NERF BOI ✅]"] = "Got nerfed but still flexing that checkmark like a champ.",
		["♦️"] = "A rare gem, sparkling under pressure.",
		["Reaper of the Arcane Moon"] = "Sounds mysterious, probably just likes edgy names.",
		["[CONTRIBUTOR]"] = "They did something cool, and now they have a title to flex.",
		["[SFX DEVELOPER]"] = "If it makes a noise in-game, blame this genius.",
		["[😎CABEZÓN😎]"] = "Big brain or big head? Only one way to find out.",
		["Warrior In White"] = "Fights with style and probably never stains their clothes.",
		["The Strongest"] = "Not just strong, but <b>the</b> strongest—don’t test it.",
		["Maestro del Caos"] = "Chaos follows them like a loyal pet.",
		["woodstock 🙏🙏"] = "A hippie at heart, spreading peace and good vibes.",
		["[SFX DESIGNER]"] = "Crafting booms and zaps that make your ears fall in love.",
		["[ANIMATOR 👽]"] = "An animator from another planet—Earth isn’t ready.",
		["[DEVELOPER ⚒️]"] = "The ones who keep the game up and running.",
		["[THE ILLUSTRATOR]"] = "If they can see it, they can draw it—probably.",
		fooly = "Not a fool, just fooly—big difference.",
		["[MODELLER]"] = "Making 3D magic happen, one polygon at a time.",
		["[BUILDER]"] = "They build, they conquer, they probably have 100+ projects unfinished.",
		["[EL NIÑO MAS FUERTE]"] = "The strongest kid, but also the most humble (probably).",
		["🌟"] = "A star handpicked from the very night sky just for people who have earned it.",
		["✨"] = "A star handpicked from the very night sky just for people who have earned it.",
		["⭐"] = "A star handpicked from the very night sky just for people who have earned it.",
		["💫"] = "A star handpicked from the very night sky just for people who have earned it.",
		["[BEST SCRIPTER OAT]"] = "A decent tiny small contribution that partially improved tsbs camera system, arigato."
	},
	RigHelper = {
		["Machine Gun Blows"] = "Cyborg",
		["Ignition Burst"] = "Cyborg",
		["Blitz Shot"] = "Cyborg",
		["Jet Dive"] = "Cyborg",
		["Thunder Kick"] = "Cyborg",
		["Speedblitz Dropkick"] = "Cyborg",
		["Flamewave Cannon"] = "Cyborg",
		Incinerate = "Cyborg",
		["Flash Strike"] = "Ninja",
		["Whirlwind Kick"] = "Ninja",
		Scatter = "Ninja",
		["Explosive Shuriken"] = "Ninja",
		["Twinblade Rush"] = "Ninja",
		["Straight On"] = "Ninja",
		Carnage = "Ninja",
		["Fourfold Flashstrike"] = "Ninja",
		Homerun = "Batter",
		Beatdown = "Batter",
		["Grand Slam"] = "Batter",
		["Foul Ball"] = "Batter",
		["Savage Tornado"] = "Batter",
		["Brutal Beatdown"] = "Batter",
		["Strength Difference"] = "Batter",
		["Death Blow"] = "Batter",
		["Quick Slice"] = "Blade",
		["Atmos Cleave"] = "Blade",
		["Pinpoint Cut"] = "Blade",
		["Split Second Counter"] = "Blade",
		Sunset = "Blade",
		["Solar Cleave"] = "Blade",
		Sunrise = "Blade",
		["Atomic Slash"] = "Blade"
	},
	PrefabAnimations = {
		72451715583225,
		93546004428904,
		129945907044125,
		132259592388175,
		95575238948327,
		106755459092436,
		102814369422840,
		75502010126640,
		85813428590588,
		95000469063288,
		100558589307006,
		137561511768861,
		100558589307006,
		112620365240235,
		108974035701442,
		111487401271653,
		88023704984538,
		99451623559327,
		110898544937927,
		75547590335774,
		77727115892579,
		77727115892579,
		72568536674783,
		127774996303290,
		132024680948340,
		137624104134020,
		76530443909428,
		88677394781901,
		105811521074269,
		120992533725535,
		96865367566704,
		73060755698819,
		79761806706382,
		79761806706382,
		140164642047188,
		71377448806509,
		90072892650917,
		74844382738532,
		136370737633649,
		113166426814229,
		105405781808472,
		98542310119798,
		77509627104305,
		114586157428274,
		108041907008692,
		75318228407422,
		110655522279647,
		87635036278859,
		107265753683839,
		137356827034236,
		88314459925577,
		85669941767645,
		116753755471636,
		116153572280464,
		114095570398448,
		138443750790136,
		94395585475029,
		86490931396573,
		77727115892579,
		113625763890269,
		70512853043908,
		116005409979614,
		81827172076105,
		111448301389216,
		85551337049240,
		115069536837221,
		95063930300078,
		135277252555463,
		70497007064436,
		88314459925577,
		85669941767645,
		137356827034236,
		110655522279647,
		87635036278859,
		107265753683839,
		75318228407422,
		108041907008692,
		114586157428274,
		94722254043682,
		77509627104305,
		92964863598742,
		123218368431425,
		90802412666561,
		128934660661875,
		18182456608,
		18182425133,
		18897115785,
		18897116845,
		18897118507,
		18897119503,
		18897120868,
		18897121931,
		18170032354,
		18896229321,
		18896222853,
		18464351556,
		18464353914,
		18464356233,
		18464358704,
		18464372850,
		17857880283,
		17799224866,
		17838619895,
		17838006839,
		17464644182,
		17466449380,
		18440398084,
		18440406788,
		17889458563,
		17889461810,
		17889471098,
		17889290569,
		17278415853,
		17275798442,
		17275150809,
		17275795209,
		17857788598,
		17889083042,
		17858878027,
		17858878027,
		17859015788,
		17859055671,
		17363256069,
		16571461202,
		16572107136,
		16737255386,
		16571909908,
		15124858806,
		15123665491,
		15123914491,
		15129887320,
		16708190748,
		16699717165,
		14900168720,
		16734584478,
		15391323441,
		15487418517,
		16515503507,
		16515520431,
		16515448089,
		16552234590,
		15436465829,
		16062712948,
		15676072469,
		14920779925,
		16139708727,
		16139000053,
		16139002631,
		16139402582,
		16139108718,
		17824510628,
		17824512914,
		17824514728,
		17824518620,
		14901894832,
		15436218047,
		15436668469,
		16057411888,
		16082123712,
		15271263467,
		15145462680,
		15510840258,
		15520132233,
		15290930205,
		14004222985,
		13997092940,
		15279910941,
		15334974550,
		14001963401,
		15295895753,
		15295336270,
		15259161390,
		15240216931,
		15240176873,
		15162694192,
		14136436157,
		14003607057,
		14798721934,
		14798608838,
		14705929107,
		13380255751,
		14875667895,
		14048285180,
		14048349132,
		14712547902,
		14048336539,
		14719290328,
		14701242661,
		14809854900,
		14809836765,
		12983333733,
		14351441234,
		13556985475,
		14374357351,
		13927612951,
		13643152947,
		13634395775,
		14542032218,
		13639700348,
		14057231976,
		14046756619,
		14004235777,
		14527225892,
		14733282425,
		14351441234,
		14348269600,
		14347157007,
		14967219354,
		14348708797,
		14349470649,
		14299135500,
		14346824304,
		13876406148,
		13814873045,
		13813450889,
		125863680384625,
		13813448561,
		13814919604,
		13813955149,
		13632347366,
		13632671563,
		13875769358,
		13881335713,
		13875169992,
		13633468484,
		13037862984,
		13560306510,
		13146710762,
		13309500827,
		13377153603,
		13497875049,
		13630786846,
		13631554970,
		13499771836,
		13370310513,
		13390230973,
		13378751717,
		13378708199,
		13501296372,
		13379003796,
		13362587853,
		13376962659,
		13309500827,
		13376869471,
		13362587853,
		13365849295,
		13083332742,
		13491635433,
		13296577783,
		13295919399,
		13295936866,
		13532562418,
		13532600125,
		13532604085,
		13294471966,
		13294790250,
		123005629431309,
		100059874351664,
		104895379416342,
		134775406437626,
		12510170988,
		10468665991,
		10479335397,
		10466974800,
		10471478869,
		12772543293,
		12684390285,
		12296882427,
		12272894215,
		12342141464,
		10471336737,
		10470104242,
		10503381238,
		11365563255,
		10469493270,
		10469630950,
		10469639222,
		10469643643,
		10480796021,
		10480793962,
		10491993682,
		11343318134,
		13785666020,
		12832023590,
		12832505612,
		12830917034,
		12296882427,
		12296113986,
		12307656616,
		12309835105,
		12447247483,
		13784794366,
		13813099821,
		12273188754,
		12272894215,
		12618271998,
		12463072679,
		12467789963,
		12460977270,
		13603396939,
		12461540679,
		71060716968719,
		114763770211803,
		105811521074269,
		88677394781901,
		12502664044,
		12509505723,
		12534735382,
		12971270638
	},
	Vaulted = {
		"Freezing Path",
		"Frost Forge",
		"Multi Ice Slash",
		"Permafrost",
		"Judgement Chain",
		"Double Trouble",
		"Snowball",
		"Flame M1",
		"Downslam Finisher",
		"Forward Dash Attack",
		"Trashcan",
		"Seismic Fist",
		"Rising Fist",
		"Ice Hammer",
		"Last BreathOld",
		"Ice HammerOld",
		"Pinpoint Cut Air Variation Finisher"
	},
	Skillsets = {
		Pirate = {
			Base = {
				"Sweep",
				"Shatter",
				"Blast Clutch",
				"Tremmor",
				"Spine Splitter"
			},
			Ultimate = {},
			Glow = Color3.new(0.0745098, 0.521569, 1),
			Order = 1,
			ID = 134261571085995,
			Name = "The Strongest Pirate",
			UltimateName = "YOU'RE ALL DOOMED!",
			Hero = true
		},
		KJ = {
			Base = {
				"Ravage",
				"Swift Sweep",
				"Collateral Ruin",
				"Spiraling Storm"
			},
			Ultimate = {
				"Stoic Bomb",
				"20-20-20 Dropkick",
				"Five Seasons",
				"Unlimited Flex Works"
			},
			Glow = Color3.new(1, 0.4, 0.411765),
			Order = 1,
			ID = 17140853847,
			Name = "KJ",
			UltimateName = "20 SERIES",
			Hero = true
		},
		Royale = {
			Base = {},
			Ultimate = {},
			Indicator = {
				Sound = "rbxassetid://14405177812",
				Volume = 1
			},
			UltimateName = "CLASSLESS",
			Exclude = true
		},
		Bald = {
			Base = {
				"Normal Punch",
				"Consecutive Punches",
				"Shove",
				"Uppercut"
			},
			Ultimate = {
				"Death Counter",
				"Table Flip",
				"Serious Punch",
				"Omni Directional Punch"
			},
			Indicator = {
				Sound = "rbxassetid://14405177812",
				Volume = 1
			},
			Glow = Color3.new(1, 0.52549, 0.533333),
			Order = 1,
			ID = 15114667107,
			UltimateTime = nil,
			UltimateName = "SERIOUS MODE",
			Name = "The Strongest Hero",
			Hero = true
		},
		Hunter = {
			Base = {
				"Flowing Water",
				"Lethal Whirlwind Stream",
				"Hunter's Grasp",
				"Prey's Peril"
			},
			Ultimate = {
				"Water Stream Cutting Fist",
				"The Final Hunt",
				"Rock Splitting Fist",
				"Crushed Rock"
			},
			Indicator = {
				Sound = "rbxassetid://14405177437",
				Volume = 0.75
			},
			Mastery = { "Monster" },
			Glow = Color3.new(0.364706, 0.745098, 1),
			Order = 2,
			ID = 15124465439,
			UltimateTime = 42.5,
			UltimateName = "RAMPAGE",
			Name = "Hero Hunter",
			Hero = false
		},
		Monster = {
			Base = {
				"Doom Dive",
				"Crowd Buster",
				"Hammer Heel",
				"Binding Cloth"
			},
			Ultimate = {
				"Hunter's Mark",
				"Great Fajin",
				"God Slayer",
				"Sky Ripping Fist"
			},
			CosmicUltimate = {
				"Nuclear Fission",
				"Singularity",
				"Gamma Ray Burst",
				"Great Fajin"
			},
			Indicator = {
				Sound = "rbxassetid://14405177437",
				Volume = 0.75
			},
			Glow = Color3.new(1, 0.0823529, 0.219608),
			IsMastery = true,
			Order = 15,
			ID = 92669838586269,
			UltimateTime = 42.5,
			UltimateName = "LIMIT BREAKER",
			Name = "Monster Form",
			Hero = false
		},
		Zombie = {
			Base = {
				"Grave Maker",
				"Blast Breaker",
				"Point Blank",
				"Crossfire"
			},
			Ultimate = {
				"Phantom Frenzy",
				"Blast Breaker",
				"Point Blank",
				"Crossfire"
			},
			Indicator = {
				Sound = "rbxassetid://14405177437",
				Volume = 0
			},
			Glow = Color3.new(0.75, 0.05, 0.08),
			Order = 16,
			ID = 105242594360882,
			UltimateTime = 42.5,
			UltimateName = "UNKILLABLE",
			Name = "Undying Hero",
			Hero = true
		},
		Purple = {
			Base = {
				"Bullet Barrage",
				"Vanishing Kick",
				"Whirlwind Drop",
				"Head First"
			},
			Ultimate = {
				"Grand Fissure",
				"Twin Fangs",
				"Earth Splitting Strike",
				"Last Breath"
			},
			Indicator = {
				Sound = "rbxassetid://18435612327",
				Volume = 0.75
			},
			Glow = Color3.new(0.6, 0.564706, 1),
			Order = 8,
			ID = 18434673438,
			UltimateTime = 42.5,
			UltimateName = "DRAGON 'S DESCENT",
			Name = "Martial Artist",
			Hero = true
		},
		Cyborg = {
			Base = {
				"Machine Gun Blows",
				"Ignition Burst",
				"Blitz Shot",
				"Jet Dive"
			},
			Ultimate = {
				"Thunder Kick",
				"Speedblitz Dropkick",
				"Flamewave Cannon",
				"Incinerate"
			},
			Indicator = {
				Sound = "rbxassetid://14405177937",
				Volume = 0.75
			},
			Glow = Color3.new(1, 0.4, 0.411765),
			Order = 3,
			ID = 15143528856,
			UltimateTime = 43,
			UltimateName = "MAXIMUM ENERGY OUTPUT",
			Name = "Destructive Cyborg",
			Hero = true
		},
		Ninja = {
			Base = {
				"Flash Strike",
				"Whirlwind Kick",
				"Scatter",
				"Explosive Shuriken"
			},
			Ultimate = {
				"Twinblade Rush",
				"Straight On",
				"Carnage",
				"Fourfold Flashstrike"
			},
			Indicator = {
				Sound = "rbxassetid://14405177701",
				Volume = 0.75
			},
			Glow = Color3.new(0.6, 0.564706, 1),
			Order = 4,
			ID = 15114672498,
			UltimateTime = 43,
			UltimateName = "CAN YOU EVEN SEE ME?",
			Name = "Deadly Ninja",
			Hero = false
		},
		Batter = {
			Base = {
				"Homerun",
				"Beatdown",
				"Grand Slam",
				"Foul Ball"
			},
			Ultimate = {
				"Savage Tornado",
				"Brutal Beatdown",
				"Strength Difference",
				"Death Blow"
			},
			Order = 5,
			Indicator = {
				Sound = "rbxassetid://14405177575",
				Volume = 1
			},
			Glow = Color3.new(1, 1, 1),
			ID = 15143529209,
			UltimateTime = 43,
			UltimateName = "PUMPED UP",
			Name = "Brutal Demon",
			Hero = true
		},
		Blade = {
			Base = {
				"Quick Slice",
				"Atmos Cleave",
				"Pinpoint Cut",
				"Split Second Counter"
			},
			Ultimate = {
				"Sunset",
				"Solar Cleave",
				"Sunrise",
				"Atomic Slash"
			},
			Indicator = {
				Sound = "rbxassetid://15398355537",
				Volume = 1
			},
			Glow = Color3.new(1, 0.235294, 0),
			Order = 6,
			ID = 15143528539,
			UltimateTime = 43,
			UltimateName = "SCORCHING BLADE",
			Name = "Blade Master",
			Hero = true
		},
		Esper = {
			Base = {
				"Crushing Pull",
				"Windstorm Fury",
				"Stone Coffin",
				"Expulsive Push"
			},
			Ultimate = {
				"Cosmic Strike",
				"Psychic Ricochet",
				"Terrible Tornado",
				"Sky Snatcher"
			},
			Indicator = {
				Sound = "rbxassetid://16136683894",
				Volume = 1
			},
			Glow = Color3.new(0.490196, 1, 0.52549),
			Order = 7,
			ID = 16136325038,
			UltimateTime = 43,
			UltimateName = "BERSERK",
			Name = "Wild Psychic",
			Hero = true
		},
		Tech = {
			Base = {
				"Weboom",
				"Plasma Cannon",
				"Trinity Tear",
				"Twin Burst"
			},
			Ultimate = {
				"Photon Edge",
				"Photon Dive",
				"Conquest",
				"Missiles"
			},
			Indicator = {
				Sound = "rbxassetid://16136683894",
				Volume = 1
			},
			Glow = Color3.new(1, 0.65098, 0.666667),
			Order = 8,
			ID = 113596928331434,
			UltimateTime = 43,
			UltimateName = "IRON GIANT",
			Name = "Tech Prodigy",
			Hero = true
		},
		["Crab Boss"] = {
			Base = {},
			Ultimate = {},
			Glow = Color3.new(1, 0.52549, 0.533333),
			Order = 9,
			ID = 18906334004,
			Name = "Crab Boss",
			UltimateName = "?",
			Hero = true
		},
		Sorcerer = {
			Base = {
				"Infinity",
				"Repulse",
				"Erase",
				"Attract"
			},
			Ultimate = {},
			Glow = Color3.new(0.364706, 0.745098, 1),
			Order = 10,
			ID = 15143528348,
			Name = "Sorcerer",
			UltimateName = "SORCERER",
			Hero = true
		}
	},
	BaseM1 = {
		Fist = {
			10469493270,
			10469630950,
			10469639222,
			10469643643
		},
		Bat = {
			14004222985,
			13997092940,
			14001963401,
			14136436157
		},
		Ninjato = {
			13370310513,
			13390230973,
			13378751717,
			13378708199
		},
		Katana = {
			15259161390,
			15240216931,
			15240176873,
			15162694192
		},
		LightningFist = {
			89044067797964,
			74334194837918,
			94353845974131,
			80601239139774
		},
		HunterFist = {
			13532562418,
			13532600125,
			13532604085,
			13294471966
		},
		ZombieFist = {
			Axe = {
				125361499827663,
				105701432344953,
				104293439261333,
				114460992057353
			},
			Deagles = {
				111644455066361,
				112778933066374,
				80488470577181,
				117726521294150
			},
			Shotgun = {
				97702234977209,
				136834606687014,
				137556620675474,
				115406134600395
			}
		},
		CyborgFist = {
			13491635433,
			13296577783,
			13295919399,
			13295936866
		},
		EsperFist = {
			16515503507,
			16515520431,
			16515448089,
			16552234590
		},
		KJFist = {
			17325510002,
			17325513870,
			17325522388,
			17325537719
		},
		PurpleFist = {
			17889458563,
			17889461810,
			17889471098,
			17889290569
		},
		Uppercut = { 13379003796, 10503381238 },
		Downslam = { 10470104242 },
		Tech = {
			123005629431309,
			100059874351664,
			104895379416342,
			134775406437626
		},
		Monster = {
			122482492364036,
			125882667406347,
			134822631853770,
			76602138940033
		}
	},
	PirateWhitelist = { 747447782, 3350014406, 1001242712 },
	ConceptWhitelist = { 747447782, 3350014406 },
	Admins = {
		0,
		8874560414,
		4041635170,
		1241352401,
		3350014406,
		3891230967,
		681405668,
		7832903582,
		1001242712,
		138249029,
		3414432341,
		339633571,
		1059541187,
		1148708686,
		33963357,
		58214194,
		747447782,
		2039323684,
		430966809,
		202693941,
		3673381374
	},
	Intros = {
		Ninja = {
			id = 15957361339,
			sound = { "rbxassetid://15956555583", 1 }
		},
		Monster = {
			id = 71448437747168,
			sound = { "rbxassetid://122693032940811", 1 }
		},
		Purple = {
			id = 18435303746,
			sound = { "rbxassetid://18435468901", 1 }
		},
		KJ = {
			id = 17325160621,
			sound = { "rbxassetid://17325174223", 1 }
		},
		Batter = {
			id = 15957371124,
			sound = { "rbxassetid://15956568211", 1 }
		},
		Hunter = {
			id = 15957376722,
			sound = { "rbxassetid://15956575080", 0.75 }
		},
		Cyborg = {
			id = 15957374019,
			sound = { "rbxassetid://15958081297", 2 }
		},
		Bald = {
			id = 15957366251,
			sound = { "rbxassetid://15956666275", 3 }
		},
		Blade = {
			id = 15983615423,
			sound = { "rbxassetid://15983408349", 1 }
		},
		Esper = {
			id = 16136144568,
			sound = { "rbxassetid://16136569377", 2 }
		},
		Tech = {
			id = 119169968232874,
			sound = { "rbxassetid://89798295291739", 3 }
		}
	},
	Special = {
		[138249029] = "CursedArmParticle",
		[747447782] = "SpecOutline",
		[3350014406] = "SpecOutline",
		[994994173] = "CursedArmParticle",
		[1001242712] = "SpecOutline",
		[2039323684] = "BlackWhiteAura"
	},
	Cosmetics = {
		{
			"Special Stuff",
			10000000000,
			"rbxassetid://17140774329",
			"aura"
		},
		{
			"Custom Cape",
			2000000000,
			"rbxassetid://17140755709",
			"cosmetic"
		},
		{
			"Guild Cape",
			1000000,
			"rbxassetid://17139038442",
			"cosmetic"
		},
		{
			"Void Aura",
			35700,
			"rbxassetid://90444878605558",
			"aura"
		},
		{
			"Frozen Aura",
			33500,
			"rbxassetid://91279017187121",
			"aura"
		},
		{
			"Love Aura",
			32750,
			"rbxassetid://137099752355413",
			"aura"
		},
		{
			"Flower Aura",
			31500,
			"rbxassetid://107246440880503",
			"aura"
		},
		{
			"Shadow Aura",
			20000,
			"rbxassetid://17855955602",
			"aura"
		},
		{
			"Gold Aura",
			30000,
			"rbxassetid://83245974392432",
			"aura"
		},
		{
			"Midnight Aura",
			25000,
			"rbxassetid://75022935096767",
			"aura"
		},
		{
			"Burning Aura",
			10000,
			"rbxassetid://17855957730",
			"aura"
		},
		{
			"Crimson Aura",
			9500,
			"rbxassetid://115711460384947",
			"aura"
		},
		{
			"Graceful Aura",
			9000,
			"rbxassetid://17855866639",
			"aura"
		},
		{
			"Glitch Aura",
			8250,
			"rbxassetid://88754428841002",
			"aura"
		},
		{
			"Colorful Aura",
			7500,
			"rbxassetid://116175503488055",
			"aura"
		},
		{
			"Error Aura",
			6700,
			"rbxassetid://102105195737574",
			"aura"
		},
		{
			"Stench Aura",
			5900,
			"rbxassetid://17855866449",
			"aura"
		},
		{
			"Slinky",
			20000,
			"rbxassetid://18183755570",
			"cosmetic"
		},
		{
			"Ruler Cape",
			17500,
			"rbxassetid://70455910113728",
			"cosmetic"
		},
		{
			"Webbed Cape",
			15000,
			"rbxassetid://82572097923242",
			"cosmetic"
		},
		{
			"Warden Cape",
			12500,
			"rbxassetid://100803534854178",
			"cosmetic"
		},
		{
			"Desert Cape",
			10500,
			"rbxassetid://18182263066",
			"cosmetic"
		},
		{
			"Divine Wheel",
			10000,
			"rbxassetid://17824308335",
			"cosmetic"
		},
		{
			"Spiky Cape",
			9500,
			"rbxassetid://18182263573",
			"cosmetic"
		},
		{
			"Fur Cape",
			9000,
			"rbxassetid://18182263767",
			"cosmetic"
		},
		{
			"Blood Scarf",
			8500,
			"rbxassetid://18182262939",
			"cosmetic"
		},
		{
			"Torn Headband",
			8000,
			"rbxassetid://18182263365",
			"cosmetic"
		},
		{
			"Headband",
			7500,
			"rbxassetid://18182263961",
			"cosmetic"
		},
		{
			"Bandage Wrap",
			7000,
			"rbxassetid://17824222445",
			"cosmetic"
		},
		{
			"Waist Sash",
			6600,
			"rbxassetid://17838057309",
			"cosmetic"
		},
		{
			"Leg Iron",
			6200,
			"rbxassetid://17846070680",
			"cosmetic"
		},
		{
			"White Scarf",
			900,
			"rbxassetid://17856005701",
			"cosmetic"
		},
		{
			"Spiral Cloth",
			0,
			"rbxassetid://82034185336002",
			"cosmetic"
		},
		{
			"Ki Aura",
			4000,
			"rbxassetid://17140585525",
			"aura",
			true
		},
		{
			"Dark Aura",
			5600,
			"rbxassetid://17140578572",
			"aura",
			true
		},
		{
			"Lightning Aura",
			4600,
			"rbxassetid://17140620713",
			"aura",
			true
		},
		{
			"Worn Cape",
			5200,
			"rbxassetid://17139121832",
			"cosmetic",
			true
		},
		{
			"Tattered Cape",
			4300,
			"rbxassetid://17138954104",
			"cosmetic",
			true
		},
		{
			"Torn Cape",
			3600,
			"rbxassetid://17138960792",
			"cosmetic",
			true
		},
		{
			"White Cape",
			3200,
			"rbxassetid://17138990307",
			"cosmetic",
			true
		},
		{
			"Conqueror Cape",
			2800,
			"rbxassetid://17138970538",
			"cosmetic",
			true
		},
		{
			"Jagged Cape",
			2000,
			"rbxassetid://17139003111",
			"cosmetic",
			true
		},
		{
			"Royal Cape",
			1200,
			"rbxassetid://17139029983",
			"cosmetic",
			true
		},
		{
			"Purple Scarf",
			600,
			"rbxassetid://17139021808",
			"cosmetic",
			true
		},
		{
			"Bandages",
			300,
			"rbxassetid://17139537917",
			"cosmetic",
			true
		},
		{
			"Long Sash",
			150,
			"rbxassetid://17139017721",
			"cosmetic",
			true
		},
		{
			"Short Sash",
			75,
			"rbxassetid://17139012868",
			"cosmetic",
			true
		},
		{
			"Red Gloves",
			25,
			"rbxassetid://17138543887",
			"cosmetic",
			true
		},
		{
			"Blocky Body",
			-1,
			"rbxassetid://17140578733",
			"cosmetic"
		}
	},
	EmoteProducts = {
		{
			id = 1556594193,
			count = 1
		},
		{
			id = 1816926141,
			count = 5
		},
		{
			id = 1816926292,
			count = 10
		},
		{
			id = 1816928543,
			count = 50
		}
	},
	CosmeticProducts = {
		{
			id = 1849123672,
			count = 1
		},
		{
			id = 1849161369,
			count = 3
		},
		{
			id = 1849161479,
			count = 5
		}
	},
	GiftableGamepasses = {
		[128278127] = { 1615573088, 1 },
		[229966673] = { 1615575224, 10 },
		[136459121] = { 1615574560, 2 },
		[267162259] = { 1661543978, 3 },
		[267169928] = { 1661547676, 9 },
		[793925178] = { 1816898588, 8 },
		[810906533] = { 1827272891, 6 },
		[1556594193] = { 1669040587, 7, true },
		[1816926141] = { 2023218528, 4, true },
		[1816926292] = { 2023240526, 5, true },
		[1816928543] = { 2675879684, 11, true }
	},
	VIPServerButtons = {
		"Command Target",
		"Respawn",
		"Bring",
		"Heal",
		"Spawn Dummy",
		"Spawn Attacking Dummy",
		"Spawn Blocking Dummy",
		"Spawn Advanced Dummy",
		"Spawn Intelligent Dummy",
		"Spawn Outsider",
		"Spawn Crab",
		"Spawn Meteor",
		"Clear Entities",
		"Build Mode",
		"Skill Builder",
		"Start Round",
		"End Round",
		"Round Teams",
		"Round Type",
		"Give Awakening",
		"Give Burst",
		"Remove Awakening",
		"Activate Awakening",
		"Gravity Multiplier",
		"Damage Multiplier",
		"Health Multiplier",
		"Regen Multiplier",
		"Speed Multiplier",
		"Storm Speed Multiplier",
		"Storm Damage Multiplier",
		"Reset Storm",
		"Remove Leaderboards",
		"Shutdown Server",
		"Refresh Server"
	},
	Order = {
		"-- PRIVATE SERVER+ --",
		"Users",
		"Command Targets",
		"Effects Apply To",
		"-- GENERAL --",
		"Godmode",
		"Heal",
		"Respawn",
		"Bring",
		"-- DUMMIES --",
		"Spawn Attacking Dummy",
		"Spawn Blocking Dummy",
		"Spawn Advanced Dummy",
		"Spawn Intelligent Dummy",
		"Spawn Dummy",
		"Spawn Outsider",
		"Spawn Crab",
		"Spawn Meteor",
		"Clear Entities",
		"-- TOGGLES --",
		"Teleport Dash",
		"No Respawn",
		"No Dash Cooldown",
		"No Burst Cooldown",
		"No Movement",
		"No Cooldown",
		"No Ragdoll",
		"No Fatigue",
		"No Attack",
		"No Stun",
		"No Block",
		"No Reset",
		"No Burst",
		"-- AWAKENING --",
		"Give Awakening",
		"Give Burst",
		"Remove Awakening",
		"Activate Awakening",
		"Infinite Awakening",
		"Instant Awakening",
		"No Awakening",
		"-- MULTIPLIERS --",
		"Attack Speed Multiplier",
		"Health Multiplier",
		"Damage Multiplier",
		"Regen Multiplier",
		"Speed Multiplier",
		"Gravity Multiplier",
		"-- MOVESET --",
		"Random Moveset",
		"Dual Moveset",
		"Finishers Only",
		"-- MAP --",
		"Build Mode",
		"Skill Builder",
		"Hide Map",
		"-- GAMEMODE --",
		"Round Type",
		"Round Teams",
		"Start Round",
		"End Round",
		"-- MISC --",
		"Storm Active",
		"Reset Storm",
		"Storm Speed Multiplier",
		"Storm Damage Multiplier",
		"-- SERVER --",
		"Lock Server",
		"Kick On Death",
		"Shutdown Server",
		"Refresh Server"
	},
	VIPServerPowers = {
		["Build Mode"] = function(_, instance)
			local CollectionService = game:GetService("CollectionService")
			local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

			if instance:FindFirstChild("buildingg") then
				for _, v3 in pairs(CollectionService:GetTagged("VisibleFF" .. playerFromCharacter.Name)) do
					v3:Destroy()
				end

				game.ReplicatedStorage.Replication:FireClient(playerFromCharacter, {
					Effect = "Fly End",
					buildend = true
				})
			else
				local forceField = Instance.new("ForceField")
				forceField:SetAttribute("Infinity", true)
				local forceField2 = Instance.new("ForceField")
				forceField2.Name = "AbsoluteImmortal"
				forceField2.Visible = false
				forceField2:SetAttribute("Infinity", true)
				forceField.Name = "VisibleFFfluy"
				forceField.Visible = false
				CollectionService:AddTag(forceField, "VisibleFF" .. playerFromCharacter.Name)
				forceField.Parent = playerFromCharacter.Character
				forceField2.Parent = playerFromCharacter.Character
				shared.bindDeletion(forceField2, forceField)
				local folder = Instance.new("Folder")
				folder.Name = "buildingg"
				folder.Parent = playerFromCharacter.Character
				CollectionService:AddTag(folder, "VisibleFF" .. playerFromCharacter.Name)
				local highlight = Instance.new("Highlight")
				highlight.Name = "flyhighlight"
				highlight.FillColor = Color3.fromRGB(1, 175, 255)
				highlight.FillTransparency = 0.8
				highlight.OutlineTransparency = 1
				CollectionService:AddTag(highlight, "VisibleFF" .. playerFromCharacter.Name)
				highlight.Parent = playerFromCharacter.Character
				playerFromCharacter:SetAttribute("oppedbefore", true)
				game.ReplicatedStorage.Replication:FireClient(playerFromCharacter, {
					Effect = "Fly Start",
					build = true
				})
			end
		end,
		["Skill Builder"] = function(_, character)
			local playerFromCharacter = game.Players:GetPlayerFromCharacter(character)
			local craft = playerFromCharacter.PlayerGui:FindFirstChild("Craft")

			if craft then
				craft:Destroy()
			else
				local clone = game.ServerStorage.Craft:Clone()
				clone.Parent = playerFromCharacter.PlayerGui
			end
		end,
		["Start Round"] = function(_)
			workspace:SetAttribute("RoundOngoing", true)
		end,
		["End Round"] = function(_)
			workspace:SetAttribute("RoundOngoing", false)
		end,
		["Storm Speed Multiplier"] = function(stormSpeedMultiplier)
			workspace:SetAttribute("StormSpeedMultiplier", stormSpeedMultiplier)
		end,
		["Reset Storm"] = function(_)
			shared.stormreset()
		end,
		["Storm Damage Multiplier"] = function(stormDamageMultiplier)
			workspace:SetAttribute("StormDamageMultiplier", stormDamageMultiplier)
		end,
		["Storm Active"] = function(stormActive)
			workspace:SetAttribute("StormActive", stormActive)
		end,
		["Refresh Server"] = function(_, _)
			local TeleportService = game:GetService("TeleportService")
			local reserveServer = TeleportService:ReserveServer(game.PlaceId)
			local TeleportService2 = game:GetService("TeleportService")
			local placeId = game.PlaceId
			local Players = game:GetService("Players")
			TeleportService2:TeleportToPrivateServer(
				placeId,
				reserveServer,
				Players:GetPlayers(),
				nil,
				{ "newps " .. os.time() .. " " .. 3350014406 }
			)
		end,
		["Hide Map"] = function(hideMap, _)
			workspace:SetAttribute("HideMap", hideMap)

			for _, childName in pairs({ "Map", "Summermap" }) do
				local child = workspace:FindFirstChild(childName)

				if #child:GetChildren() == 0 then
					local Debris = game:GetService("Debris")
					Debris:AddItem(child, 0)
					game.Lighting[childName].Parent = workspace
				else
					child.Parent = game.Lighting
					local folder = Instance.new("Folder")
					folder.Name = childName
					folder.Parent = workspace
				end
			end
		end,
		["Give Awakening"] = function(_, character)
			local commandTarget = workspace:GetAttribute("CommandTarget")
			local players = game.Players:GetPlayers()

			if commandTarget == 2 then
				table.remove(players, table.find(players, game.Players:GetPlayerFromCharacter(character)))
			else
				players = commandTarget == 3 and { game.Players:GetPlayerFromCharacter(character) } or players
			end

			for _, player in pairs(players) do
				player:SetAttribute("DamageNeed", 1000)
				player:SetAttribute("Ultimate", 100)
			end
		end,
		["Give Burst"] = function(_, character)
			local commandTarget = workspace:GetAttribute("CommandTarget")
			local players = game.Players:GetPlayers()

			if commandTarget == 2 then
				table.remove(players, table.find(players, game.Players:GetPlayerFromCharacter(character)))
			else
				players = commandTarget == 3 and { game.Players:GetPlayerFromCharacter(character) } or players
			end

			for _, player in pairs(players) do
				player:SetAttribute("Burst", 100)
			end
		end,
		Heal = function(_, p)
			local commandTarget = workspace:GetAttribute("CommandTarget")
			local children = workspace.Live:GetChildren()

			if commandTarget == 2 then
				table.remove(children, table.find(children, p))
			else
				children = commandTarget == 3 and { p } or children
			end

			for _, v3 in pairs(children) do
				local humanoid = v3:FindFirstChildOfClass("Humanoid")

				if humanoid then
					humanoid.Health = 2000000000
				end
			end
		end,
		["Remove Awakening"] = function(_, character)
			local commandTarget = workspace:GetAttribute("CommandTarget")
			local players = game.Players:GetPlayers()

			if commandTarget == 2 then
				table.remove(players, table.find(players, game.Players:GetPlayerFromCharacter(character)))
			else
				players = commandTarget == 3 and { game.Players:GetPlayerFromCharacter(character) } or players
			end

			for _, player in pairs(players) do
				player:SetAttribute("Ultimate", 0)
			end
		end,
		["Activate Awakening"] = function(_, character)
			local commandTarget = workspace:GetAttribute("CommandTarget")
			local players = game.Players:GetPlayers()

			if commandTarget == 2 then
				table.remove(players, table.find(players, game.Players:GetPlayerFromCharacter(character)))
			else
				players = commandTarget == 3 and { game.Players:GetPlayerFromCharacter(character) } or players
			end

			for _, player in pairs(players) do
				if player.Character then
					shared.cfolder({
						Name = "ULTNOW",
						Parent = player.Character
					})
				end
			end
		end,
		Respawn = function(_, character)
			if tick() - (game:GetAttribute("RACD") or 0) < 0.5 then
				return
			end

			game:SetAttribute("RACD", tick())
			local commandTarget = workspace:GetAttribute("CommandTarget")
			local players = game.Players:GetPlayers()

			if commandTarget == 2 then
				table.remove(players, table.find(players, game.Players:GetPlayerFromCharacter(character)))
			else
				players = commandTarget == 3 and { game.Players:GetPlayerFromCharacter(character) } or players
			end

			for _, player in pairs(players) do
				player:LoadCharacter()
			end
		end,
		Bring = function(_, instance)
			local commandTarget = workspace:GetAttribute("CommandTarget")
			local children = workspace.Live:GetChildren()

			if commandTarget == 2 then
				table.remove(children, table.find(children, instance))
			else
				children = commandTarget == 3 and { instance } or children
			end

			for _, v3 in pairs(children) do
				if v3.PrimaryPart and v3:FindFirstChildOfClass("Humanoid") then
					v3:SetPrimaryPartCFrame(instance.PrimaryPart.CFrame)
				end
			end
		end,
		["Shutdown Server"] = function(_, _)
			for _, v3 in pairs(game.Players:players()) do
				v3:Kick("server shut down by the private server owner")
			end
		end,
		["Teleport Dash"] = function(teleportDash)
			workspace:SetAttribute("TeleportDash", teleportDash)
		end,
		["Random Moveset"] = function(randomMoveset)
			workspace:SetAttribute("RandomMoveset", randomMoveset)
		end,
		["Dual Moveset"] = function(dualMoveset)
			workspace:SetAttribute("DualMoveset", dualMoveset)
		end,
		["Kick On Death"] = function(kickOnDeath)
			workspace:SetAttribute("KickOnDeath", kickOnDeath)
		end,
		["Attack Speed Multiplier"] = function(attackSpeedMultiplier)
			workspace:SetAttribute("AttackSpeedMultiplier", attackSpeedMultiplier)
		end,
		["Gravity Multiplier"] = function(p)
			workspace.Gravity = 196.1999969482422 * p
		end,
		["Health Multiplier"] = function(healthMultiplier)
			workspace:SetAttribute("HealthMultiplier", healthMultiplier)
		end,
		["Damage Multiplier"] = function(damageMultiplier)
			workspace:SetAttribute("DamageMultiplier", damageMultiplier)
		end,
		["Regen Multiplier"] = function(regenMultiplier)
			workspace:SetAttribute("RegenMultiplier", regenMultiplier)
		end,
		["Speed Multiplier"] = function(speedMultiplier)
			workspace:SetAttribute("SpeedMultiplier", speedMultiplier)
		end,
		["Infinite Awakening"] = function(infiniteAwakening)
			workspace:SetAttribute("InfiniteAwakening", infiniteAwakening)
		end,
		["Finishers Only"] = function(finishersOnly)
			workspace:SetAttribute("FinishersOnly", finishersOnly)

			for _, child in pairs(workspace.Live:GetChildren()) do
				local humanoid = child:FindFirstChildOfClass("Humanoid")

				if not humanoid then
					continue
				end

				humanoid.MaxHealth = finishersOnly and 7 or 100
				humanoid.Health = humanoid.MaxHealth
			end
		end,
		["Instant Awakening"] = function(instantAwakening)
			workspace:SetAttribute("InstantAwakening", instantAwakening)
		end,
		["No Dash Cooldown"] = function(noDashCooldown)
			workspace:SetAttribute("NoDashCooldown", noDashCooldown)
		end,
		["No Movement"] = function(noMovement)
			workspace:SetAttribute("NoMovement", noMovement)

			for _, child in pairs(workspace.Live:GetChildren()) do
				if child:FindFirstChildOfClass("Humanoid") then
					shared.cfolder({
						Name = "Freeze",
						Parent = child
					}, 0.5)
				end

				child:SetAttribute("_upd", math.random(1, 2000000000))
			end
		end,
		["No Respawn"] = function(noRespawn)
			workspace:SetAttribute("NoRespawn", noRespawn)
			game.Players.CharacterAutoLoads = not noRespawn
		end,
		["No Burst Cooldown"] = function(noBurstCooldown)
			workspace:SetAttribute("NoBurstCooldown", noBurstCooldown)

			for _, child in pairs(workspace.Live:GetChildren()) do
				if child.Name == "BurstCD" then
					child:Destroy()
				end
			end
		end,
		["No Cooldown"] = function(noCooldown)
			workspace:SetAttribute("NoCooldown", noCooldown)

			for _, v3 in pairs(game.Players:GetPlayers()) do
				if not skills then
					local Skills = require(game.ServerStorage.Skills)
					skills = Skills
				end

				skills:ResetCooldowns(v3, true)
			end
		end,
		["No Fatigue"] = function(noFatigue)
			workspace:SetAttribute("NoFatigue", noFatigue)
		end,
		["No Awakening"] = function(noAwakening)
			workspace:SetAttribute("NoAwakening", noAwakening)
		end,
		["No Ragdoll"] = function(noRagdoll)
			workspace:SetAttribute("NoRagdoll", noRagdoll)
		end,
		["No Attack"] = function(noAttack)
			workspace:SetAttribute("NoAttack", noAttack)
		end,
		["No Reset"] = function(noReset)
			workspace:SetAttribute("NoReset", noReset)
		end,
		["No Burst"] = function(noBurst)
			workspace:SetAttribute("NoBurst", noBurst)
		end,
		["No Stun"] = function(noStun)
			workspace:SetAttribute("NoStun", noStun)
		end,
		["No Block"] = function(noBlock)
			workspace:SetAttribute("NoBlock", noBlock)

			if noBlock then
				task.wait()

				for _, child in pairs(workspace.Live:GetChildren()) do
					shared.cfolder({
						Name = "a",
						Parent = child
					}, 0.2)
				end
			end
		end,
		["Lock Server"] = function(lockServer)
			workspace:SetAttribute("LockServer", lockServer)
		end,
		Godmode = function(godmode, parent)
			local CollectionService = game:GetService("CollectionService")

			if godmode then
				local forceField = Instance.new("ForceField")
				forceField.Visible = true
				forceField.Name = "AbsoluteImmortal"
				CollectionService:AddTag(forceField, "godmodeff" .. parent.Name)
				forceField.Parent = parent
			else
				for _, v3 in pairs(CollectionService:GetTagged("godmodeff" .. parent.Name)) do
					v3:Destroy()
				end
			end

			workspace:SetAttribute("Godmode", godmode)
		end,
		["Spawn Attacking Dummy"] = function(_, instance)
			local clone = shared.DummyClone:Clone()
			clone:SetAttribute("DontClone", true)
			local clone2 = script.Attack:Clone()
			clone2.Parent = clone
			clone.Parent = workspace.Live
			clone:SetPrimaryPartCFrame(instance.PrimaryPart.CFrame)
			clone2.Enabled = true
		end,
		["Spawn Blocking Dummy"] = function(_, instance)
			local clone = shared.DummyClone:Clone()
			clone:SetAttribute("DontClone", true)
			local clone2 = script.Blocking:Clone()
			clone2.Parent = clone
			clone.Parent = workspace.Live
			clone:SetPrimaryPartCFrame(instance.PrimaryPart.CFrame)
			clone2.Enabled = true
		end,
		["Spawn Advanced Dummy"] = function(_, character)
			local clone = shared.DummyClone:Clone()
			clone:SetAttribute("DontClone", true)
			local clone2 = script.Disguise:Clone()
			clone2.Parent = clone
			clone.Parent = workspace.Live
			clone:SetPrimaryPartCFrame(character.PrimaryPart.CFrame)
			clone2.Enabled = true
			task.delay(0.1, function()
				local billboardGui = clone2:FindFirstChild("BillboardGui")

				if billboardGui then
					billboardGui.Parent = game.Players:GetPlayerFromCharacter(character).PlayerGui
					billboardGui.Adornee = clone.HumanoidRootPart
				end
			end)
		end,
		["Spawn Dummy"] = function(_, instance)
			local clone = shared.DummyClone:Clone()
			clone.Parent = workspace.Live
			clone:SetPrimaryPartCFrame(instance.PrimaryPart.CFrame)
		end,
		["Spawn Meteor"] = function()
			shared.SpawnIce()
		end,
		["Spawn Crab"] = function()
			local v3 = {
				createVector(377.20624, 438.16537, -64.807),
				createVector(370.0957, 438.61694, 149.87962),
				createVector(212.38956, 438.61652, -236.30598),
				createVector(-37.52899, 438.12604, -115.18038),
				createVector(-69.72504, 438.65683, 88.80044),
				createVector(90.86868, 438.12604, 270.82904),
				createVector(226.17392, 438.105, -3.2757206),
				createVector(69.11408, 438.105, 61.779724)
			}

			for _ = 1, 1 do
				local clone = game.ServerStorage["Crab Boss"]:Clone()
				clone:PivotTo(CFrame.new(v3[math.random(#v3)]))
				clone.Parent = workspace.Live
			end
		end,
		["Spawn Outsider"] = function(_, _)
			local v3 = {
				createVector(156.678, 440.756, 24.687),
				createVector(400.24, 440.506, 155.093),
				createVector(169.397, 440.506, 283.151),
				createVector(-62.474, 440.506, 195.781),
				createVector(-107.589, 440.506, -91.591),
				createVector(181.218, 440.506, -169.909)
			}
			shared.SpawnOutsider(v3[math.random(#v3)])
		end,
		["Clear Entities"] = function(_, _)
			for _, child in pairs(workspace.Live:GetChildren()) do
				if not (child.Name == "Weakest Dummy" or child:GetAttribute("OmniImmunity") and not child:GetAttribute("IceBoss")) then
					continue
				end

				child:Destroy()
			end
		end
	}
}
v2.spawnables = {
	Trashcan = { function(_, instance, p)
			local clone = shared.trashcan:Clone()
			clone:SetAttribute("Name", "Trashcan")
			clone.PrimaryPart = clone.Trashcan
			clone.Parent = workspace.Map.Trash
			local CollectionService = game:GetService("CollectionService")
			CollectionService:AddTag(clone, "ps_spawned")
			table.insert(clones, clone)
			clone.Trashcan.CFrame = p or instance.PrimaryPart.CFrame * CFrame.new(0, -0.925, 0)
			local CollectionService2 = game:GetService("CollectionService")
			CollectionService2:AddTag(clone.Trashcan, "Interactable")
			local interactables = shared.interactables
			local CollectionService3 = game:GetService("CollectionService")
			interactables.FilterDescendantsInstances = CollectionService3:GetTagged("Interactable")
		end, 5 },
	Brick = { function(_, instance, p, list)
			if not list then
				local v3 = v[workspace:GetAttribute("SpawnShape") or 1]
				list = { v3.X, v3.Y, v3.Z }
			end

			local clone = script.Block:Clone()
			clone:SetAttribute("Name", "Brick")
			clone.Size = Vector3.new(unpack(list))
			clone.Parent = workspace
			table.insert(clones, clone)
			local CollectionService = game:GetService("CollectionService")
			CollectionService:AddTag(clone, "ps_spawned")
			clone.CFrame = p or instance.PrimaryPart.CFrame * CFrame.new(0, clone.Size.Y / 2 - 3, -10)
		end, 1 },
	["Fragile Brick"] = { function(_, instance, p, list)
			if not list then
				local v3 = v[workspace:GetAttribute("SpawnShape") or 1]
				list = { v3.X, v3.Y, v3.Z }
			end

			local clone = script.Block:Clone()
			local CollectionService = game:GetService("CollectionService")
			CollectionService:AddTag(clone, "fragilebrick")
			local CollectionService2 = game:GetService("CollectionService")
			CollectionService2:AddTag(clone, "ps_spawned")
			clone:SetAttribute("Name", "Fragile Brick")
			clone.Size = Vector3.new(unpack(list))
			clone.Parent = workspace
			table.insert(clones, clone)
			clone.CFrame = p or instance.PrimaryPart.CFrame * CFrame.new(0, clone.Size.Y / 2 - 3, -10)
		end, 2 },
	Steel = { function(_, instance, p, list)
			if not list then
				local v3 = v[workspace:GetAttribute("SpawnShape") or 1]
				list = { v3.X, v3.Y, v3.Z }
			end

			local clone = script.Block:Clone()
			clone.Material = Enum.Material.DiamondPlate
			clone:SetAttribute("Breakable", false)
			clone.Color = Color3.fromRGB(112, 107, 111)
			clone:SetAttribute("Name", "Steel")
			clone.Size = Vector3.new(unpack(list))
			clone.Parent = workspace
			table.insert(clones, clone)
			local CollectionService = game:GetService("CollectionService")
			CollectionService:AddTag(clone, "ps_spawned")
			clone.CFrame = p or instance.PrimaryPart.CFrame * CFrame.new(0, clone.Size.Y / 2 - 3, -10)
		end, 3 },
	["Kill Block"] = { function(_, instance, p, list)
			if not list then
				local v3 = v[workspace:GetAttribute("SpawnShape") or 1]
				list = { v3.X, v3.Y, v3.Z }
			end

			local clone = script.Block:Clone()
			clone:SetAttribute("Breakable", false)
			clone:SetAttribute("Name", "Kill Block")
			clone.Material = Enum.Material.SmoothPlastic
			clone.Size = Vector3.new(unpack(list))
			clone.Transparency = 0.5
			clone.BrickColor = BrickColor.new("Really red")
			clone.CanCollide = false
			clone.Parent = workspace
			table.insert(clones, clone)
			local CollectionService = game:GetService("CollectionService")
			CollectionService:AddTag(clone, "ps_spawned")
			local CollectionService2 = game:GetService("CollectionService")
			CollectionService2:AddTag(clone, "killbrick")
			clone.CFrame = p or instance.PrimaryPart.CFrame * CFrame.new(0, clone.Size.Y / 2 - 3, -10)
		end, 4 }
}

function v2.IsCosmeticProduct(_, p)
	local v3 = tonumber(p)

	for _, cosmeticProduct in pairs(v2.CosmeticProducts) do
		if tonumber(cosmeticProduct.id) == v3 then
			return cosmeticProduct.count
		end
	end
end

function v2.IsEmoteProduct(_, p)
	local v3 = tonumber(p)

	for _, emoteProduct in pairs(v2.EmoteProducts) do
		if tonumber(emoteProduct.id) == v3 then
			return emoteProduct.count
		end
	end
end

function v2.CanGiveMoveset(_, p, p2)
	if p == "Sorcerer" then
		p2 = false
	elseif p ~= v2.EarlyAccess or p2 then
		if p == "KJ" or p == "Pirate" then
			p2 = false
		else
			p2 = p ~= "Crab Boss"
		end
	end

	return p2
end

for _, v3 in pairs(v2.Order) do
	if string.sub(v3, 0, 3) ~= "-- " then
		continue
	end

	v2.VIPServerPowers[v3] = function() end

	table.insert(v2.VIPServerButtons, v3)
end

table.sort(v2.Cosmetics, function(a, b)
	return a[2] > b[2]
end)
v2.UpdateLog = [[
## ✶ **<font color="#FFA6AA">Tech Prodigy</font>** is now free !!
* new move: **Conquest**
* new move: **Missiles**
* new move: **Photon Dive**

* **Mech vs Mech** combat added
* **Mech parrying** added
* **Mech side dash** reworked
* Polished mech M1s and improved them
* Added proper animations for mech
* Added victim mech animations for: Sunset, Twinblade Rush, Sky Snatcher, Final Hunt
* **Final Hunt** — added new finisher
* **Mech vs Mech** — added new finisher interaction

## ✶ **<font color="#ff5c5c">Hero Hunter — Monster Form</font>** 👹
-# 3 new Hero Hunter Monster Form ultimate moves
* **God Slayer** — added new ultimate move <i>(has a variant)</i>
* **Skyripping Fist** — added new ultimate move
* **Great Fajin** — added new ultimate move

## ✶ **<font color="#FFB3FF">Hero Hunter — Cosmic Form</font>** 💫
* **Nuclear Fission** — added cosmic first move
* **Singularity** — added cosmic second move
-# <i>will become the first move's variant after he gets more moves</i>

* **Hammer Heel** — added new finisher
* **Crowd Buster** — added new finisher
* more accurate block detection and now has a proper block animation
* added **Monster Form** wall combo
* added **Monster Form** spawn animation

## ✶ **New <font color="#FFD813">Early Access</font> Character** 🌟
* **<font color="#E81E2C">Undying Hero</font>**
	* **Blast Breaker** — added new move
	* **Point Blank** — added new move
	* **Grave Maker** — added new move
	* **Crossfire** — added new move

## ✶ **<font color="#80FFD9">Character Creator V1</font>** ✨
**Build your own characters with base moves + ultimate moves**
-# more features coming soon — couldn't fit them all in this update

* **Skill Builder** — completely reworked
	* **Complete** timeline-based skill builder added
	* **70**+ blocks added
	* added a **custom** animator
-# <i>expect bugs — this is a WIP and will receive fixes and upgrades each update</i>

## ✶ **General**
* new main game map — added
* **Custom Leaderboard** — added
	* **ELO** is now visible on it
	* click an entry to see ping and device
	* added ranked icon to leaderboard entries
* **New ELO system** — added
	* **3v3s** — added
	* **Global Matchmaking** — added
	* **Server List + Custom Servers** — added

## ✶ **Interactions** 🥊
* added **Suiryu × Garou** interaction
* added **Saitama × Genos** ultimate clash interaction
-# ⓘ use ult at the same time near each other

## ✶ **Build Mode** 🔨
* added X storage
* added model level scale + capture box fixes
* notification system + save menu less cluttered
* build slots can be renamed
* more save file corruption prevention
* prefabs can now change part shape
* added advanced dummy

## ✶ **Emotes & Misc** 💃
* **37**+ new emotes
* added option to skip long emotes
* **Atomic** can now counter **trashcan** at close range

## 🛠️
* trees don't block the camera anymore
* hovering over emotes shows them in preview
* added camera smoothing when returning back to a move
* polished **Earth Splitting Strike** more
* added **Consecutive Punches** outside-finisher VFX
* added **Quick Slice** outside-finisher VFX
]]
return v2