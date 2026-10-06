local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local studioLiteFolder = ReplicatedStorage:WaitForChild("StudioLiteFolder")
local serverFunctions = studioLiteFolder:WaitForChild("ServerFunctions")
local setSelection = script.Parent.Parent:WaitForChild("ExplorerPanel"):WaitForChild("SetSelection")
local getSelection = script.Parent.Parent:WaitForChild("ExplorerPanel"):WaitForChild("GetSelection")
local catalogSearchFrame = script.Parent.Parent:WaitForChild("CatalogSearchFrame")
local explorerPanel = script.Parent.Parent:WaitForChild("ExplorerPanel")
local localPlayer = game.Players.LocalPlayer
Models = {
	{
		"Door",
		8222709011,
		"Door (auto open)",
		"ScottSpiritWalker"
	},
	{
		"Window",
		988657385,
		"Window",
		"yxsinnn"
	},
	{
		"TeleportParts",
		7842906172,
		"Teleport parts",
		"ilxsxmu"
	},
	{
		"KillBrick",
		848208793,
		"KillBrick ",
		"RupturedRampage"
	},
	{
		"Checkpoints",
		16785047186,
		"Checkpoints (see script inside)",
		"ScottSpiritWalker"
	},
	{
		"Conveyor",
		6121196773,
		"Conveyor with beam",
		"BeamGoosty"
	},
	{
		"Jetpack",
		9969729848,
		"Jetpack (run to fly)",
		"sok2176"
	},
	{
		"TableChairsByStudsWorthy",
		5638343804,
		"Cafe Table and Chairs",
		"YxZus"
	},
	{
		"TableChairsSet",
		1458975532,
		"Wooden Table and Chair set",
		"FunkyGreenJean"
	},
	{
		"House",
		7627790722,
		"small vibe house",
		"xk_llz"
	},
	{
		"SofaChair",
		5434052748,
		"Pastel sofa chair",
		"G1ST4R"
	},
	{
		"sofa",
		5639313880,
		"sofa",
		"pwupui"
	},
	{
		"CoffeeTable",
		7087839653,
		"Coffee Table",
		"Furniture build"
	},
	{
		"Bed",
		8505794349,
		"Realistic Bed",
		"QanterGaming"
	},
	{
		"ChestofDrawers",
		360914966,
		"Large Dresser",
		"EndoredModel"
	},
	{
		"SideTableWithLamp",
		5033756967,
		"Night Stand with Lamp",
		"Rayneh2008"
	},
	{
		"WorkingSink",
		2726188501,
		"Working Sink",
		"Golocule"
	},
	{
		"Stove",
		136507972,
		"Stove",
		"Sedwert_Bird"
	},
	{
		"PottedPlant",
		8704290264,
		"Potted Plant",
		"d_ytme"
	},
	{
		"HousePlant",
		10728134719,
		"Potted Plant",
		"UnknownX Ultimate"
	},
	{
		"Palm_1",
		9428540624,
		"preppy palm tree!",
		"0BV10USLYNESSA"
	},
	{
		"MeshPineTree",
		4456156506,
		"Mesh Pine Tree",
		"Java8198"
	},
	{
		"PineTree",
		5392132809,
		"Realistic Pine Tree",
		"GabeQZ"
	},
	{
		"Tree",
		4498245334,
		"tree",
		"Umbrouse"
	},
	{
		"ForestRock",
		5670667237,
		"Rock PBR",
		"vx0rn"
	},
	{
		"Meshes/hill",
		2762612477,
		"Snow Hill",
		"ThyCompany"
	},
	{
		"RockWall",
		6296100580,
		"Rock/Wall",
		"SlightlyBurntSteak"
	},
	{
		"R8_E_Tron",
		8689278799,
		"Fast Audi",
		"ColdTRUSTie"
	},
	{
		"DuneBuggy",
		5161157874,
		"Dune Buggy",
		"Kethan_V"
	},
	{
		"ClassicSword",
		47433,
		"Classic Sword",
		"Roblox"
	},
	{
		"HyperlaserGun",
		6880366374,
		"Fast Hyper laser Gun",
		"Ossalac"
	},
	{
		"Zombie",
		3924238625,
		"Drooling Zombie (attacks you)",
		"Roblox"
	},
	{
		"Soldiers",
		3924234975,
		"Soldiers (attacks zombies)",
		"Roblox"
	},
	{
		"ClassicTimebomb",
		47586,
		"Tool: Tick tick boom!",
		"Roblox"
	},
	{
		"SkyTropical",
		169210648,
		"Tropical Sunset",
		"BuilderAtWork"
	},
	{
		"SkyPurpleNebula",
		230057997,
		"Purple Nebula Skybox",
		"Rootie_Groot"
	},
	{
		"SkyCanyon",
		1318113454,
		"Tropical Skybox Canyon",
		"mocrews1"
	}
}
Images = {
	{
		"DecalArrow",
		6914010536,
		"Basic Arrow",
		"Reditect"
	},
	{
		"DecalHeart",
		8941506186,
		"Heart",
		"LTheJedi"
	},
	{
		"DecalWater",
		81475937,
		"preview water 03",
		"Roblox"
	},
	{
		"DecalSeamlessWater",
		5722422984,
		"Tile Seamless Water",
		"ThatBrazillianNoob"
	},
	{
		"DecalScenmo",
		11065536410,
		"scenmo pattern 3",
		"ForbiddenApproach"
	},
	{
		"DecalDarkBluePlaid",
		6704050352,
		"Dark Blue Plaid",
		"itsR1LO"
	},
	{
		"DecalBeigePlaid",
		7524492073,
		"Beige Plaid",
		"GrvngePiistol"
	},
	{
		"DecalRoyalWallpaper",
		12680213846,
		"royal wallpaper",
		"xxbrandexxx"
	},
	{
		"DecalGreyWallpaper",
		179945645,
		"Grey Wallpaper",
		"hetebro"
	},
	{
		"DecalScallop",
		6300205346,
		"scallop scales",
		"Blackwidoww"
	},
	{
		"DecalSunflower",
		3524111829,
		"Sunflower Pattern",
		"laepis"
	},
	{
		"DecalTilesGrey",
		7085973702,
		"TilesGrey",
		"Schmiggle"
	},
	{
		"DecalTiles",
		1213422374,
		"Tiles",
		"R3N3KO"
	},
	{
		"DecalRainbow",
		6406460929,
		"Rainbow",
		"Vizc7"
	},
	{
		"DecalBamboo",
		7242819112,
		"Bamboo",
		"Paveeezo"
	},
	{
		"DecalTreeBranch",
		4736895894,
		"Tree Branch",
		"Silentsniper_7097"
	},
	{
		"DecalSpruceBranch",
		5709519542,
		"Spruce Branch",
		"HexBloxx"
	},
	{
		"DecalSakuraBlossom",
		6294547246,
		"Sakura Blossom",
		"iHasCuteName"
	},
	{
		"DecalBark",
		7750557,
		"Bark Texture",
		"spork890"
	},
	{
		"DecalHappyFace",
		1338788087,
		"Happy Face",
		"ofxsad"
	},
	{
		"DecalEMOJI",
		860151950,
		"EMOJI",
		"Zoez0e"
	},
	{
		"DecalHeartEye",
		6766521362,
		"Heart Eye Emoji",
		"rervar"
	},
	{
		"DecalThinking",
		1664931187,
		"Thinking",
		"8hein"
	},
	{
		"DecalCrying",
		1435503770,
		"Crying",
		"koboversary"
	},
	{
		"DecalSkull",
		12070829375,
		"skull",
		"OwOrolf_e"
	},
	{
		"DecalThumbsUp",
		4964921310,
		"Thumbs up",
		"killer179000698"
	}
}
Audio = {
	{
		"Fire Crackling Sound",
		516449725,
		"Fire Crackling",
		"KittyNebulaPlays"
	},
	{
		"explosion",
		5801257793,
		"explosion",
		"deadstickdoom"
	},
	{
		"Night Forest Ambience Sound",
		7274920568,
		"Night Forest Ambience Sound",
		"thebadbadger"
	},
	{
		"Car Engine",
		532147820,
		"Car Engine",
		"IggyTheBonker"
	},
	{
		"Wood Breaking",
		6629890936,
		"Wood Breaking",
		"PolyMahma"
	},
	{
		"Punch Swing ",
		5835032207,
		"Punch Swing ",
		"Rover845"
	},
	{
		"Alarm Sound",
		5348162330,
		"Alarm Sound",
		"Reset42227920"
	},
	{
		"Electric Shock",
		157325701,
		"Electric Shock",
		"Siccity"
	},
	{
		"Money",
		3020841054,
		"Money",
		"Z_Nac"
	},
	{
		"Clock Ticking",
		4940109913,
		"Clock Ticking",
		"OverpricedTomatoes"
	},
	{
		"heartbeat",
		17619474123,
		"heartbeat",
		"NOTHINGNEWTODAY"
	},
	{
		"Coin Collect - SFX",
		1169755927,
		"Coin Collect - SFX",
		"Everyedit"
	},
	{
		"victory.wav",
		12222253,
		"victory.wav",
		"Roblox"
	},
	{
		"troll cut",
		8389041427,
		"troll cut",
		"ChimpyNut800"
	},
	{
		"metal pipe falling sound effect but its louder",
		6729922069,
		"metal pipe falling sound effect but its louder",
		"Captain_Spade"
	},
	{
		"[SCP] Inside Nuke Alarm",
		7570226921,
		"[SCP] Inside Nuke Alarm",
		"XQantasX"
	},
	{
		"Glass Break 2",
		7140152893,
		"Glass Break 2",
		"bartfxp"
	},
	{
		"Pop Sound!",
		1289263994,
		"Pop Sound!",
		"superlaser60"
	},
	{
		"meow",
		1091083826,
		"meow",
		"TheLucario88725"
	},
	{
		"Bruh Sound Effect",
		8435092314,
		"Bruh Sound Effect",
		"HashtagBlu_YT"
	},
	{
		"bass.wav",
		12221944,
		"bass.wav",
		"Roblox"
	},
	{
		"Magic Twirling Small High Pitch Spinning Chi (SFX)",
		9125644911,
		"Magic Twirling Small High Pitch Spinning Chi (SFX)",
		"Roblox"
	},
	{
		"Magic sound effect",
		3356359494,
		"Magic sound effect",
		"warnoob326"
	},
	{
		"Magic Acceleration Musical Phasey Tones 1 (SFX)",
		9116378941,
		"Magic Acceleration Musical Phasey Tones 1 (SFX)",
		"Roblox"
	},
	{
		"Magic_Sprinkle",
		2609981431,
		"Magic_Sprinkle",
		"leanop"
	},
	{
		"Life in an Elevator 60",
		1841647553,
		"Life in an Elevator 60",
		"Roblox"
	},
	{
		"Leisure Simulation Game",
		1836058507,
		"Leisure Simulation Game",
		"Roblox"
	},
	{
		"Hotel Lobby (a 30)",
		1840097324,
		"Hotel Lobby (a 30)",
		"Roblox"
	},
	{
		"Mexico City a 30",
		1839909817,
		"Mexico City a 30",
		"Roblox"
	},
	{
		"Beach Beats",
		9041861752,
		"Beach Beats",
		"Roblox"
	},
	{
		"Easy Life",
		1842613971,
		"Easy Life",
		"Roblox"
	},
	{
		"Hide N Seek - 30 Second Alternative",
		1842791717,
		"Hide N Seek - 30 Second Alternative",
		"Roblox"
	},
	{
		"Next Century Panoramic (b) (30)",
		9046625805,
		"Next Century Panoramic (b) (30)",
		"Roblox"
	},
	{
		"Flying High",
		1837076705,
		"Flying High",
		"Roblox"
	},
	{
		"Edm Euphoria D",
		9044012469,
		"Edm Euphoria D",
		"Roblox"
	},
	{
		"Scaling a Universe (b) (30)",
		9046626178,
		"Scaling a Universe (b) (30)",
		"Roblox"
	},
	{
		"One Hundred Percent Edm B",
		9040445992,
		"One Hundred Percent Edm B",
		"Roblox"
	},
	{
		"Chicks B",
		1847855435,
		"Chicks B",
		"Roblox"
	},
	{
		"Psychotic Ravers",
		9046947560,
		"Psychotic Ravers",
		"Roblox"
	},
	{
		"Take Me (b 60)",
		1837998824,
		"Take Me (b 60)",
		"Roblox"
	},
	{
		"One Decade Early (b) (60)",
		9046622602,
		"One Decade Early (b) (60)",
		"Roblox"
	}
}
Meshes = {
	{
		"Apple",
		923453688,
		"Apple",
		"Michickaela"
	},
	{
		"Panda",
		891369375,
		"Panda",
		"Michickaela"
	},
	{
		"WDex",
		430059162,
		"WDex",
		"WDex"
	},
	{
		"builderman",
		2711196870,
		"builderman",
		"B739"
	},
	{
		"B739",
		6574746141,
		"B739",
		"B739"
	},
	{
		"Plutia",
		760922441,
		"Plutia",
		"Natej89"
	},
	{
		"Banana",
		923469164,
		"Banana",
		"Michickaela"
	},
	{
		"Pizza",
		923476265,
		"Pizza",
		"Michickaela"
	},
	{
		"Shark",
		2750740954,
		"Shortfin Mako Shark",
		"AubreyKitsune"
	},
	{
		"Bear",
		2752695670,
		"Grizzly Bear (2)",
		"AubreyKitsune"
	},
	{
		"EasterEgg",
		478307409,
		"Easter Egg",
		"HunterTheCoder"
	},
	{
		"toilet",
		6602412592,
		"toilet",
		"RealgrumpyKitten1"
	},
	{
		"Sofa",
		6031790920,
		"Sofa V2 Low Poly 2k Texture",
		"DartanyanTheCat"
	},
	{
		"fridge",
		6602263591,
		"fridge",
		"RealgrumpyKitten1"
	},
	{
		"Penguin",
		5136636498,
		"Penguin",
		"bubblegal112"
	},
	{
		"Bloxy",
		2770710471,
		"Bloxy",
		"B739"
	}
}
local v = false
local workingImageLabel1 = script.Parent.Parent:WaitForChild("WorkingImageLabel1")
local workingImageLabel2 = script.Parent.Parent:WaitForChild("WorkingImageLabel2")

function WorkingWaiting()
	spawn(function()
		v = true

		for _ = 1, 100 do
			if not v then
				break
			end

			if workingImageLabel1.Visible then
				workingImageLabel1.Visible = false
				workingImageLabel2.Visible = true
			else
				workingImageLabel1.Visible = true
				workingImageLabel2.Visible = false
			end

			task.wait(0.1)
		end

		v = false
		workingImageLabel1.Visible = false
		workingImageLabel2.Visible = false
	end)
end

local twoImagesFrameTemplate = script.Parent.TwoImagesFrameTemplate
local clone = nil

function PlaceAssetInLocalWorkspace(childName)
	if not v then
		WorkingWaiting()
		serverFunctions:InvokeServer("LoadAssetToPlayerGui", childName)
		local child = localPlayer.PlayerGui:FindFirstChild(childName)

		if child then
			local flag, model

			if child.ClassName == "Model" then
				flag = false
			else
				model = Instance.new("Model")
				child.Parent = model
				child = model
				flag = true
			end

			local boundingBox, v2 = child:GetBoundingBox()
			local v3 = not child.PrimaryPart and 0 or child.PrimaryPart.Position.Y - v2.Y / 2
			local cFrame = workspace.Camera.CFrame
			local vector2 = Vector3.new(
				math.floor((cFrame.X + cFrame.lookVector.X * 30) * 2) / 2,
				v2.Y / 2 + v3,
				math.floor((cFrame.Z + cFrame.lookVector.Z * 30) * 2) / 2
			)
			local raycastResult = workspace:Raycast(
				Vector3.new(vector2.X, cFrame.Y, vector2.Z),
				(Vector3.new(0, -cFrame.Y, 0))
			)

			if raycastResult then
				vector2 = Vector3.new(
					vector2.X,
					raycastResult.Instance.Position.Y + raycastResult.Instance.Size.Y / 2 + v2.Y / 2 + v3,
					vector2.Z
				)
			end

			child:PivotTo(CFrame.new(vector2) * boundingBox.Rotation)
			local clone2

			if flag then
				clone2 = child:GetChildren()[1]:Clone()
				clone2.Parent = workspace

				if model then
					model:Destroy()
				end
			else
				clone2 = child:Clone()
				clone2.Parent = workspace
			end

			v = false
			task.wait(0.2)
			setSelection:Invoke({ clone2 })
			serverFunctions:InvokeServer("ClearAssetFromPlayerGui", childName)
		else
			local _ = childName:sub(1, 3) == "Sky"
		end

		v = false
	end
end

function ModelsFillToolboxScrollFrame(items, p)
	local v2 = 1

	for k, item in pairs(items) do
		if v2 == 1 then
			clone = twoImagesFrameTemplate:Clone()
			clone.Parent = script.Parent[p .. "ScrollingFrame"]
			clone.Visible = true
		end

		local waitForChild = clone:WaitForChild("ImageButton" .. v2)
		waitForChild.Image = "rbxthumb://type=Asset&id=" .. item[2] .. "&w=150&h=150"
		local waitForChild_2 = clone:WaitForChild("TextButton" .. v2)
		waitForChild_2.Text = item[3] .. "  by " .. item[4]
		local waitForChild_3 = clone:WaitForChild("ImageButton" .. v2)
		waitForChild_3.Visible = true
		local waitForChild_4 = clone:WaitForChild("TextButton" .. v2)
		waitForChild_4.Visible = true
		clone.LayoutOrder = k
		local v3 = item
		clone["ImageButton" .. v2].MouseButton1Click:Connect(function()
			PlaceAssetInLocalWorkspace(v3[1])
		end)
		local v4 = item
		clone["TextButton" .. v2].MouseButton1Click:Connect(function()
			PlaceAssetInLocalWorkspace(v4[1])
		end)
		v2 += 1

		if v2 > 2 then
			v2 = 1
		end
	end
end

ModelsFillToolboxScrollFrame(Models, "Models")
ModelsFillToolboxScrollFrame(Meshes, "Meshes")

function PlaceAssetInLocalSelected(childName)
	if not v then
		WorkingWaiting()
		serverFunctions:InvokeServer("LoadAssetToPlayerGui", childName)
		local child = localPlayer.PlayerGui:FindFirstChild(childName)

		if child then
			local clone2 = child:Clone()
			local v2 = getSelection:Invoke()

			if v2 and typeof(v2) == "table" and #v2 >= 1 then
				clone2.Parent = v2[1]
			else
				clone2.Parent = workspace
			end

			task.wait(0.2)
			setSelection:Invoke({ clone2 })
			serverFunctions:InvokeServer("ClearAssetFromPlayerGui", childName)
		end

		v = false
	end
end

function ImagesFillToolboxScrollFrame()
	local v2 = 1

	for k, v3 in pairs(Images) do
		if v2 == 1 then
			clone = twoImagesFrameTemplate:Clone()
			clone.Parent = script.Parent.ImagesScrollingFrame
			clone.Visible = true
		end

		local waitForChild = clone:WaitForChild("ImageButton" .. v2)
		waitForChild.Image = "rbxthumb://type=Asset&id=" .. v3[2] .. "&w=150&h=150"
		local waitForChild_2 = clone:WaitForChild("TextButton" .. v2)
		waitForChild_2.Text = v3[3] .. "  by " .. v3[4]
		local waitForChild_3 = clone:WaitForChild("ImageButton" .. v2)
		waitForChild_3.Visible = true
		local waitForChild_4 = clone:WaitForChild("TextButton" .. v2)
		waitForChild_4.Visible = true
		clone.LayoutOrder = k
		local v4 = v3
		clone["ImageButton" .. v2].MouseButton1Click:Connect(function()
			PlaceAssetInLocalSelected(v4[1])
		end)
		local v5 = v3
		clone["TextButton" .. v2].MouseButton1Click:Connect(function()
			PlaceAssetInLocalSelected(v5[1])
		end)
		v2 += 1

		if v2 > 2 then
			v2 = 1
		end
	end
end

ImagesFillToolboxScrollFrame()
local audioFrameTemplate = script.Parent.AudioFrameTemplate
local sound = Instance.new("Sound")
sound.Parent = workspace:WaitForChild("ExplorerSelectionChanged", 9)

function AudioFillToolboxScrollFrame()
	for k, v2 in pairs(Audio) do
		local clone2 = audioFrameTemplate:Clone()
		clone2.Parent = script.Parent:WaitForChild("AudioScrollingFrame")
		clone2.Visible = true
		local textButton = clone2:WaitForChild("TextButton")
		textButton.Text = v2[3] .. "  by " .. v2[4]
		clone2.TextButton.Visible = true
		clone2.LayoutOrder = k
		local v4 = v2
		clone2:WaitForChild("PlayAudioButton").Activated:Connect(function(p)
			for i, child in pairs(script.Parent.AudioScrollingFrame:GetChildren()) do
				if child:FindFirstChild("PlayAudioButton") then
					child.PlayAudioButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
				end
			end

			clone2.PlayAudioButton.ImageColor3 = Color3.fromRGB(120, 255, 120)

			if sound.IsPlaying and sound.SoundId == "rbxassetid://" .. v4[2] then
				sound:Stop()
				return
			end

			sound.SoundId = "rbxassetid://" .. v4[2]
			sound:Play()
		end)
		local v5 = v2
		clone2:WaitForChild("InsertAudioButton").MouseButton1Click:Connect(function()
			sound.SoundId = "rbxassetid://" .. v5[2]
			local clone3 = sound:Clone()
			clone3.Name = v5[1]
			local v6 = getSelection:Invoke()

			if v6 and typeof(v6) == "table" and #v6 >= 1 then
				clone3.Parent = v6[1]
			else
				clone3.Parent = workspace
			end

			if sound.IsPlaying then
				sound:Stop()
			end

			clone3.Playing = true
			task.wait(0.2)
			setSelection:Invoke({ clone3 })
		end)
	end
end

AudioFillToolboxScrollFrame()
Rigs = {
	{ "i_", 1, "Yourself" },
	{ "i_", 2, "blocky" },
	{ "i_", 1, "Top Donor, see Vote menu" },
	{ "i_", 1, "Top Donor, see Vote menu" },
	{ "i_", 1, "Top Donor, see Vote menu" },
	{ "i_", 1, "Top Donor, see Vote menu" },
	{ "i_", 121823922, "Youtuber DenisDaily" },
	{ "i_", 3991272, "Youtuber Pokediger1" },
	{ "i_", 141039383, "Youtuber Funnehcake" },
	{ "i_", 155361651, "Youtuber inquisitormaster" },
	{ "i_", 339310190, "Youtuber mrflimflam" },
	{ "i_", 120846783, "Youtuber KevinEdwardsJr" },
	{ "i_", 197807548, "Youtuber Lanaraee" },
	{ "i_", 273090581, "Youtuber NotLeah" },
	{
		"o_",
		131830047,
		"John by Roblox",
		126
	},
	{
		"o_",
		131830049,
		"Claire by Roblox",
		128
	},
	{
		"o_",
		131830046,
		"Oakley by Roblox",
		125
	},
	{
		"o_",
		12182335689,
		"Piggy by MiniToon",
		998
	},
	{
		"o_",
		131929547,
		"Penguin by Roblox",
		284
	},
	{
		"o_",
		20232850872,
		"Mermaid by Soulskor",
		7109
	},
	{
		"o_",
		153458887246,
		"Modern Woman by polixman",
		622799
	},
	{
		"o_",
		2463114765640859,
		"It-Girl Baddie Doll by polarberrys",
		601902
	},
	{
		"o_",
		3792238257278809,
		"Athletic muscle man by Inf1n1tylt",
		594501
	},
	{
		"o_",
		150308079194,
		"Woman boy by ryzieisq",
		393839
	},
	{
		"o_",
		4812089296,
		"Daniel Seavey by Roblox",
		726
	},
	{
		"o_",
		703808863,
		"Star-Mist Fairy by Roblox",
		443
	}
}
local rigsScrollingFrame = script.Parent:WaitForChild("RigsScrollingFrame")
local rigsEditScrollingFrame = script.Parent:WaitForChild("RigsEditScrollingFrame")
local child = nil

function GetRig(childName)
	if not v then
		WorkingWaiting()
		serverFunctions:InvokeServer("LoadRigToPlayerGui", childName)
		child = localPlayer.PlayerGui:FindFirstChild(childName)

		if child then
			local clone2 = child:Clone()
			clone2.Parent = workspace
			local boundingBox, v2 = clone2:GetBoundingBox()
			local v3 = not clone2.PrimaryPart and 0 or clone2.PrimaryPart.Position.Y - boundingBox.Position.Y
			local cFrame = workspace.Camera.CFrame
			local vector2 = Vector3.new(
				math.floor((cFrame.X + cFrame.lookVector.X * 30) * 2) / 2,
				v2.Y / 2 + v3,
				math.floor((cFrame.Z + cFrame.lookVector.Z * 30) * 2) / 2
			)
			local raycastResult = workspace:Raycast(
				Vector3.new(vector2.X, cFrame.Y, vector2.Z),
				(Vector3.new(0, -cFrame.Y, 0))
			)

			if raycastResult then
				vector2 = Vector3.new(
					vector2.X,
					raycastResult.Instance.Position.Y + raycastResult.Instance.Size.Y / 2 + v2.Y / 2 + v3,
					vector2.Z
				)
			end

			clone2:PivotTo(CFrame.new(vector2) * boundingBox.Rotation)
			task.wait(0.2)
			setSelection:Invoke({ clone2 })
			serverFunctions:InvokeServer("ClearRigFromPlayerGui", childName)
			rigsScrollingFrame.Visible = false
			rigsEditScrollingFrame.Visible = true
			local humanoid = clone2:WaitForChild("Humanoid")
			FillRigsEditScrollingFrame(humanoid)
		end

		v = false
	end
end

local rigTypeDescTextLabel = rigsScrollingFrame:WaitForChild("RigTypeFrame"):WaitForChild("RigTypeDescTextLabel")
local nameFromUserIdAsyncsByMatch = {}

function RigsFillToolboxScrollFrame()
	Rigs[1][2] = localPlayer.UserId
	studioLiteFolder.RefreshDonation:FireServer(4)
	local donators = localPlayer.PlayerGui:WaitForChild("StudioGui", 9):WaitForChild("VoteFrame"):WaitForChild("VoteLeftFrame"):WaitForChild("MainFrame"):WaitForChild("Donators")
	local donators2 = localPlayer.PlayerGui:WaitForChild("StudioGui", 9):WaitForChild("VoteFrame"):WaitForChild("VoteRightFrame"):WaitForChild("MainFrame"):WaitForChild("Donators")

	for _ = 1, 7 do
		if #donators2:GetChildren() < 4 and #donators:GetChildren() < 4 then
			task.wait(1)
		else
			break
		end
	end

	local v2 = 3

	for _, child2 in pairs(donators:GetChildren()) do
		if child2.Name ~= "Donator" then
			continue
		end

		Rigs[v2][2] = child2.UserIdValue.Value
		Rigs[v2][3] = child2.Username.Text .. " Top Donors, see Vote menu"
		v2 += 1

		if v2 == 5 then
			break
		end
	end

	for _, child2 in pairs(donators2:GetChildren()) do
		if not (child2.Name == "Donator" and child2.UserIdValue.Value ~= Rigs[3][2] and child2.UserIdValue.Value ~= Rigs[4][2]) then
			continue
		end

		Rigs[v2][2] = child2.UserIdValue.Value
		Rigs[v2][3] = child2.Username.Text .. " Top Donors, see Vote menu"
		v2 += 1

		if v2 == 7 then
			break
		end
	end

	local v4 = 1

	for k, v5 in pairs(Rigs) do
		if v4 == 1 then
			clone = twoImagesFrameTemplate:Clone()
			clone.Parent = rigsScrollingFrame
			clone.Visible = true
		end

		if v5[1] == "i_" then
			local waitForChild = clone:WaitForChild("ImageButton" .. v4)
			waitForChild.Image = game.Players:GetUserThumbnailAsync(
				v5[2],
				Enum.ThumbnailType.AvatarThumbnail,
				Enum.ThumbnailSize.Size150x150
			)
		elseif v5[1] == "b_" then
			local waitForChild_2 = clone:WaitForChild("ImageButton" .. v4)
			waitForChild_2.Image = "rbxthumb://type=Outfit&id=" .. v5[4] .. "&w=150&h=150"
		else
			local waitForChild_3 = clone:WaitForChild("ImageButton" .. v4)
			waitForChild_3.Image = "rbxthumb://type=Outfit&id=" .. v5[2] .. "&w=150&h=150"
		end

		local waitForChild_4 = clone:WaitForChild("TextButton" .. v4)
		waitForChild_4.Text = v5[3]
		local waitForChild_5 = clone:WaitForChild("ImageButton" .. v4)
		waitForChild_5.Visible = true
		local waitForChild_6 = clone:WaitForChild("TextButton" .. v4)
		waitForChild_6.Visible = true
		clone.LayoutOrder = k + 2
		local stringValue = Instance.new("StringValue")
		stringValue.Name = "rigRequestValue"
		stringValue.Parent = clone["ImageButton" .. v4]
		local name = ""

		if v5[3] == "Yourself" then
			if localPlayer.DisplayName == "" then
				name = localPlayer.Name
			else
				name = localPlayer.DisplayName
			end
		elseif v5[3] == "blocky" then
			name = "blocky"
		else
			local v6 = v5[3]:find(" Top Donors, see Vote menu", 1, true)

			if v6 and v6 > 1 then
				name = v5[3]:sub(1, v6 - 1)
			elseif v5[3]:sub(1, 8) == "Youtuber" then
				name = v5[3]:sub(10)
			else
				local v7 = v5[3]:find(" by ", 1, true)

				if v7 and v7 > 1 then
					name = v5[3]:sub(1, v7 - 1)
				end
			end
		end

		local v6 = v5
		clone["ImageButton" .. v4].MouseButton1Click:Connect(function()
			GetRig(rigTypeDescTextLabel.Text .. v6[1] .. tostring(v6[2]) .. "_" .. name)
		end)
		local v7 = v5
		clone["TextButton" .. v4].MouseButton1Click:Connect(function()
			GetRig(rigTypeDescTextLabel.Text .. v7[1] .. tostring(v7[2]) .. "_" .. name)
		end)
		local v8 = v4 + 1
		v4 = v8 > 2 and 1 or v8
	end
end

RigsFillToolboxScrollFrame()
local rigAppearanceFrame = rigsScrollingFrame:WaitForChild("RigAppearanceFrame")
local rigAppearanceTextBox = rigAppearanceFrame:WaitForChild("RigAppearanceTextBox")
local rigsSearchChoicesButton = rigAppearanceFrame:WaitForChild("RigsSearchChoicesButton")
rigAppearanceFrame:WaitForChild("RigAppearanceTextButton").Activated:Connect(function()
	if rigAppearanceTextBox.Text:sub(1, 1) == "@" then
		rigAppearanceTextBox.Text = rigAppearanceTextBox.Text:sub(2)
	end

	if not (#rigAppearanceTextBox.Text > 0) then
		warn("Expected", rigsSearchChoicesButton.Text)
		return
	end

	if rigsSearchChoicesButton.Text == "Player Name" then
		GetRig(rigTypeDescTextLabel.Text .. "n_" .. rigAppearanceTextBox.Text)
		return
	end

	local match = rigAppearanceTextBox.Text:match("%d+")

	if not match then
		warn(
			"Expected a number for",
			rigsSearchChoicesButton.Text,
			". Tip: you can find bundle Ids here: roblox.com/catalog?Category=17"
		)
	elseif rigsSearchChoicesButton.Text == "Player UserId" then
		local nameFromUserIdAsync = ""
		local success, _ = pcall(function()
			nameFromUserIdAsync = game.Players:GetNameFromUserIdAsync(match)
		end)

		if not success then
			warn("UserId not found.")
			return
		end

		nameFromUserIdAsyncsByMatch[match] = nameFromUserIdAsync
		GetRig(rigTypeDescTextLabel.Text .. "i_" .. match .. "_" .. nameFromUserIdAsync)
	elseif rigsSearchChoicesButton.Text == "Bundle ID" then
		GetRig(rigTypeDescTextLabel.Text .. "b_" .. match)
	elseif rigsSearchChoicesButton.Text == "Outfit ID" then
		GetRig(rigTypeDescTextLabel.Text .. "o_" .. match)
	else
		warn("Unexpected search type:", rigsSearchChoicesButton.Text)
	end
end)
rigsEditScrollingFrame:WaitForChild("RigEditTitleFrame"):WaitForChild("GoRigBuildTextButton").Activated:Connect(function()
	rigsEditScrollingFrame.Visible = false
	rigsScrollingFrame.Visible = true
end)
rigsEditScrollingFrame:WaitForChild("CatalogSearchButtonFrame"):WaitForChild("CatalogSearchTextButton").Activated:Connect(function()
	catalogSearchFrame.Visible = true
end)
local rigEditSkinColorFrame = rigsEditScrollingFrame:WaitForChild("RigEditSkinColorFrame")
local colorPalette = script.Parent.Parent:WaitForChild("ColorPalette")
local v2 = {
	rigEditSkinColorFrame:WaitForChild("RigHeadColorTextButton"),
	rigEditSkinColorFrame:WaitForChild("RigRightArmColorTextButton"),
	rigEditSkinColorFrame:WaitForChild("RigLeftArmColorTextButton"),
	rigEditSkinColorFrame:WaitForChild("RigRightLegColorTextButton"),
	rigEditSkinColorFrame:WaitForChild("RigLeftLegColorTextButton"),
	rigEditSkinColorFrame:WaitForChild("RigTorsoColorTextButton"),
	rigEditSkinColorFrame:WaitForChild("RigSkinColorTextButton")
}

for _, v3 in pairs(v2) do
	local v4 = v3
	v3.Activated:Connect(function()
		local selectedColor = colorPalette:WaitForChild("SelectedColor")
		local selectedColorText = colorPalette:WaitForChild("SelectedColorText")
		local selectedBrickColorText = colorPalette:WaitForChild("SelectedBrickColorText")
		local colorPaletteCrosshairs = colorPalette:WaitForChild("Palette"):WaitForChild("ColorPaletteCrosshairs")
		local darknessPointer = colorPalette:WaitForChild("DarknessAppearance"):WaitForChild("DarknessPointer")
		local uIGradient = colorPalette:WaitForChild("DarknessAppearance"):WaitForChild("UIGradient")
		selectedColor.BackgroundColor3 = v4.BackgroundColor3
		selectedColor.Text = "Color"
		selectedColorText.Text = "r,g,b:  " .. math.round(v4.BackgroundColor3.R * 256) .. "," .. math.round(v4.BackgroundColor3.G * 256) .. "," .. math.round(v4.BackgroundColor3.B * 256)
		selectedBrickColorText.Text = tostring(BrickColor.new(v4.BackgroundColor3))
		local HSV, v5, v6 = v4.BackgroundColor3:ToHSV()
		colorPaletteCrosshairs.Position = UDim2.new(0, 220 - HSV * 220 - 14, 0, 200 - v5 * 200 - 14)
		darknessPointer.Position = UDim2.new(0, 14, 0, 200 - v6 * 200 - 6)
		uIGradient.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(HSV, v5, 1))
		colorPalette.Visible = true
		local okButton = colorPalette:WaitForChild("OkButton")
		local mouseButton1ClickConnection = nil
		local mouseButton1ClickConnection2 = nil
		mouseButton1ClickConnection = colorPalette:WaitForChild("CancelButton").MouseButton1Click:Connect(function()
			colorPalette.Visible = false
			mouseButton1ClickConnection:disconnect()
			mouseButton1ClickConnection2:disconnect()
		end)
		mouseButton1ClickConnection2 = okButton.MouseButton1Click:Connect(function()
			local v7 = explorerPanel.GetSelection:Invoke()[1]

			if v7 then
				local humanoid = v7:FindFirstChild("Humanoid") or v7.Parent and (v7.Parent:FindFirstChild("Humanoid") or v7.Parent.Parent and (v7.Parent.Parent:FindFirstChild("Humanoid") or v7.Parent.Parent.Parent and v7.Parent.Parent.Parent:FindFirstChild("Humanoid")))

				if humanoid and humanoid:WaitForChild("HumanoidDescription", 1) then
					local humanoidDescription = humanoid.HumanoidDescription

					if v4.Name == "RigSkinColorTextButton" then
						for k, v8 in pairs(v2) do
							if v8.Name ~= "RigSkinColorTextButton" then
								humanoidDescription[v8.Name:sub(4, -11)] = selectedColor.BackgroundColor3
							end

							v8.BackgroundColor3 = selectedColor.BackgroundColor3
						end
					else
						v4.BackgroundColor3 = selectedColor.BackgroundColor3
						humanoidDescription[v4.Name:sub(4, -11)] = selectedColor.BackgroundColor3
					end

					humanoid:ApplyDescription(humanoidDescription)
				else
					warn("(14)Select a rig, or build one.")
				end
			else
				warn("(15)Select a rig, or build one.")
			end

			colorPalette.Visible = false
			mouseButton1ClickConnection:disconnect()
			mouseButton1ClickConnection2:disconnect()
		end)
	end)
end

local flag = false
local displayNameTextBox = rigsEditScrollingFrame:WaitForChild("DisplayNameFrame"):WaitForChild("DisplayNameTextBox")

function FillRigsEditScrollingFrame(instance)
	flag = false
	local humanoidDescription = instance:FindFirstChild("HumanoidDescription")
	local rigSkinColorTextButton = rigEditSkinColorFrame:WaitForChild("RigSkinColorTextButton")
	rigSkinColorTextButton.BackgroundColor3 = humanoidDescription.HeadColor
	local rigHeadColorTextButton = rigEditSkinColorFrame:WaitForChild("RigHeadColorTextButton")
	rigHeadColorTextButton.BackgroundColor3 = humanoidDescription.HeadColor
	local rigRightArmColorTextButton = rigEditSkinColorFrame:WaitForChild("RigRightArmColorTextButton")
	rigRightArmColorTextButton.BackgroundColor3 = humanoidDescription.RightArmColor
	local rigLeftArmColorTextButton = rigEditSkinColorFrame:WaitForChild("RigLeftArmColorTextButton")
	rigLeftArmColorTextButton.BackgroundColor3 = humanoidDescription.LeftArmColor
	local rigRightLegColorTextButton = rigEditSkinColorFrame:WaitForChild("RigRightLegColorTextButton")
	rigRightLegColorTextButton.BackgroundColor3 = humanoidDescription.RightLegColor
	local rigLeftLegColorTextButton = rigEditSkinColorFrame:WaitForChild("RigLeftLegColorTextButton")
	rigLeftLegColorTextButton.BackgroundColor3 = humanoidDescription.LeftLegColor
	local rigTorsoColorTextButton = rigEditSkinColorFrame:WaitForChild("RigTorsoColorTextButton")
	rigTorsoColorTextButton.BackgroundColor3 = humanoidDescription.TorsoColor

	if instance.DisplayDistanceType == Enum.HumanoidDisplayDistanceType.None then
		displayNameTextBox.Text = ""
	elseif instance.DisplayName == "" then
		displayNameTextBox.Text = instance.Parent.Name
	else
		displayNameTextBox.Text = instance.DisplayName
		instance.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	end

	local rigEditScriptsFrame = rigsEditScrollingFrame:FindFirstChild("RigEditScriptsFrame")

	for _, child2 in pairs(rigEditScriptsFrame:GetChildren()) do
		if child2.Name:sub(-19) ~= "CheckboxImageButton" then
			continue
		end

		if instance.Parent:FindFirstChild(child2.Name:sub(1, -20)) then
			child2.Image = "rbxassetid://48138491"
		else
			child2.Image = "rbxassetid://48138474"
		end
	end

	local rigEditScaleFrame = rigsEditScrollingFrame:FindFirstChild("RigEditScaleFrame")

	for _, child2 in pairs(rigEditScaleFrame:GetChildren()) do
		if child2.ClassName == "TextBox" then
			child2.Text = math.round(tonumber(humanoidDescription[child2.Name:sub(1, -8)]) * 1000) / 1000
		end
	end
end

displayNameTextBox.FocusLost:Connect(function()
	local v3 = explorerPanel.GetSelection:Invoke()[1]

	if not v3 then
		warn("(17)Select a rig, or build one.")
		return
	end

	local humanoid = v3:FindFirstChild("Humanoid") or v3.Parent and (v3.Parent:FindFirstChild("Humanoid") or v3.Parent.Parent and (v3.Parent.Parent:FindFirstChild("Humanoid") or v3.Parent.Parent.Parent and v3.Parent.Parent.Parent:FindFirstChild("Humanoid")))

	if not humanoid then
		warn("(16)Select a rig, or build one.")
		return
	end

	if displayNameTextBox.Text == "" then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		return
	end

	humanoid.DisplayName = displayNameTextBox.Text
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
end)
rigsScrollingFrame:WaitForChild("RigTypeFrame"):WaitForChild("GoRigEditTextButton").Activated:Connect(function()
	local v3 = explorerPanel.GetSelection:Invoke()[1]

	if not v3 then
		warn("(11)Select a rig, or build one.")
		return
	end

	local humanoid = v3:FindFirstChild("Humanoid") or v3.Parent and (v3.Parent:FindFirstChild("Humanoid") or v3.Parent.Parent and (v3.Parent.Parent:FindFirstChild("Humanoid") or v3.Parent.Parent.Parent and v3.Parent.Parent.Parent:FindFirstChild("Humanoid")))

	if not humanoid then
		warn("(10)Select a rig, or build one.")
		return
	end

	if not humanoid:FindFirstChild("HumanoidDescription") then
		warn("Can't edit this rig. No HumanoidDescription found.")
		return
	end

	FillRigsEditScrollingFrame(humanoid)
	rigsEditScrollingFrame.Visible = true
	rigsScrollingFrame.Visible = false
end)
local position = createVector(0, 0, 0)

while task.wait(0.5) do
	if not rigsEditScrollingFrame.Visible then
		continue
	end

	local v3 = explorerPanel.GetSelection:Invoke()[1]

	if v3 then
		local humanoid = v3:FindFirstChild("Humanoid") or v3.Parent and (v3.Parent:FindFirstChild("Humanoid") or v3.Parent.Parent and (v3.Parent.Parent:FindFirstChild("Humanoid") or v3.Parent.Parent.Parent and v3.Parent.Parent.Parent:FindFirstChild("Humanoid")))

		if humanoid then
			if flag then
				FillRigsEditScrollingFrame(humanoid)
			elseif humanoid.Parent.HumanoidRootPart.Position ~= position then
				if position ~= createVector(0, 0, 0) then
					FillRigsEditScrollingFrame(humanoid)
				end

				position = humanoid.Parent.HumanoidRootPart.Position
			end
		elseif not flag then
			flag = true
		end
	elseif not flag then
		flag = true
	end
end