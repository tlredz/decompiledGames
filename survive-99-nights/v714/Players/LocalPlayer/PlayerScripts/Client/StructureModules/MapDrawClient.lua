local createVector = vector.create
local MapDrawClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
game:GetService("ReplicatedStorage")
game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
Color3.fromRGB(10, 111, 44)
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(130, 130, 130)
local position = Client.ZoneModule.GetZoneCFrame("Cave").Position
local v = {
	145,
	390,
	605,
	830,
	1154,
	1400
}
local v2 = 145
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = {}
local v10 = {}
local v11 = {}
CFrame.lookAt(createVector(0, 0, -4.3), createVector(0, 0, 0))
local color3 = Color3.fromRGB(248, 191, 16)
local v12 = {}
local visible2 = false
local showAvatars = {}
local v14 = {}
local v15 = {}
MapDrawClient.TutorialCircles = {}
local boardPart = nil
local v16 = false
local flag = false
local v17 = {
	Campfire = {
		Image = "rbxassetid://102941548238667",
		Size = UDim2.new(0.05, 0, 0.06, 0)
	},
	FurnitureTrader = {
		Image = "rbxassetid://82029259276917",
		Size = UDim2.new(0.045, 0, 0.045, 0)
	},
	ToolSmith = {
		Image = "rbxassetid://124332924792942",
		Size = UDim2.new(0.045, 0, 0.045, 0)
	},
	Stronghold = {
		Image = "rbxassetid://129988047144115",
		Size = UDim2.new(0.045, 0, 0.045, 0)
	},
	ToolWorkshop = {
		Image = "rbxassetid://113634060738289",
		Size = UDim2.new(0.045, 0, 0.045, 0)
	},
	Clinic = {
		Image = "rbxassetid://87669003400065",
		Size = UDim2.new(0.035, 0, 0.035, 0)
	},
	["Jail Cellar1"] = {
		Image = "rbxassetid://90629697164070",
		Size = UDim2.new(0.045, 0, 0.045, 0)
	},
	["Jail Cellar2"] = {
		Image = "rbxassetid://90629697164070",
		Size = UDim2.new(0.045, 0, 0.045, 0)
	},
	["Jail Cellar3"] = {
		Image = "rbxassetid://90629697164070",
		Size = UDim2.new(0.045, 0, 0.045, 0)
	},
	["Jail Cellar4"] = {
		Image = "rbxassetid://90629697164070",
		Size = UDim2.new(0.045, 0, 0.045, 0)
	},
	Pond = {
		Image = "rbxassetid://84329393800517",
		Size = UDim2.new(0.025, 0, 0.025, 0),
		ImageTransparency = 0.3
	},
	LargeStructure = {
		Image = "rbxassetid://137718423898395"
	},
	LargeStructureVisited = {
		Image = "rbxassetid://127009461387822"
	},
	["Fairy Tree"] = {
		Image = "rbxassetid://127596849991136",
		Size = UDim2.new(0.052, 0, 0.052, 0)
	},
	["Fairy House"] = {
		Image = "rbxassetid://100416865309538",
		Size = UDim2.new(0.045, 0, 0.045, 0)
	},
	["Snow Clothing Shop"] = {
		Image = "rbxassetid://88739855381066",
		Size = UDim2.new(0.04, 0, 0.04, 0)
	},
	["Ice Temple"] = {
		Image = "rbxassetid://84582364292702",
		Size = UDim2.new(0.04, 0, 0.04, 0)
	},
	["Polar Bear Den1"] = {
		Image = "rbxassetid://74928836917329",
		Size = UDim2.new(0.035, 0, 0.035, 0)
	},
	["Polar Bear Den2"] = {
		Image = "rbxassetid://74928836917329",
		Size = UDim2.new(0.035, 0, 0.035, 0)
	},
	["Mammoth Spawn"] = {
		Image = "rbxassetid://96296179979649",
		Size = UDim2.new(0.035, 0, 0.035, 0)
	},
	["Owl Nest"] = {
		Image = "rbxassetid://110918391723412",
		Size = UDim2.new(0.052, 0, 0.052, 0)
	},
	Volcano = {
		Image = "rbxassetid://70911474207510",
		Size = UDim2.new(0.052, 0, 0.052, 0)
	},
	["Kings Palace"] = {
		Image = "rbxassetid://130695703267662",
		Size = UDim2.new(0.04, 0, 0.04, 0)
	},
	["Cultist Generator Base"] = {
		Image = "rbxassetid://101599775301305",
		Size = UDim2.new(0.035, 0, 0.035, 0)
	},
	["Hellephant Spawn"] = {
		Image = "rbxassetid://96296179979649",
		Size = UDim2.new(0.035, 0, 0.035, 0)
	},
	ToolWorkshopMeteorShower = {
		Image = "rbxassetid://103116935034337",
		Size = UDim2.new(0.045, 0, 0.045, 0)
	},
	["Thanksgiving Plot"] = {
		Image = "rbxassetid://106417175203432",
		Size = UDim2.new(0.055, 0, 0.055, 0)
	},
	["Halloween House"] = {
		Image = "rbxassetid://81985296240735",
		Size = UDim2.new(0.05, 0, 0.05, 0)
	},
	["Halloween Carnival"] = {
		Image = "rbxassetid://81985296240735",
		Size = UDim2.new(0.05, 0, 0.05, 0)
	},
	HappyHalloweenPlot1 = {
		Image = "rbxassetid://131759252902415",
		Size = UDim2.new(0.05, 0, 0.05, 0)
	},
	HappyHalloweenPlot2 = {
		Image = "rbxassetid://131759252902415",
		Size = UDim2.new(0.05, 0, 0.05, 0)
	},
	HappyHalloweenPlot3 = {
		Image = "rbxassetid://131759252902415",
		Size = UDim2.new(0.05, 0, 0.05, 0)
	},
	HappyHalloweenPlot4 = {
		Image = "rbxassetid://131759252902415",
		Size = UDim2.new(0.05, 0, 0.05, 0)
	},
	HappyHalloweenPlot5 = {
		Image = "rbxassetid://131759252902415",
		Size = UDim2.new(0.05, 0, 0.05, 0)
	},
	HappyHalloweenPlot6 = {
		Image = "rbxassetid://131759252902415",
		Size = UDim2.new(0.05, 0, 0.05, 0)
	},
	["Research Outpost"] = {
		Image = "rbxassetid://129477947076695",
		Size = UDim2.new(0.045, 0, 0.045, 0)
	},
	["Corrupted Tree Rift"] = {
		Image = "rbxassetid://134896537251897",
		Size = UDim2.new(0.045, 0, 0.045, 0)
	},
	["Corrupted Wolf Rift"] = {
		Image = "rbxassetid://134896537251897",
		Size = UDim2.new(0.045, 0, 0.045, 0)
	},
	UFOCrash1 = {
		Image = "rbxassetid://109617420876862"
	},
	UFOCrash2 = {
		Image = "rbxassetid://109617420876862"
	},
	UFOCrash3 = {
		Image = "rbxassetid://109617420876862"
	},
	UFOCrash4 = {
		Image = "rbxassetid://109617420876862"
	},
	["Jungle Temple"] = {
		Image = "rbxassetid://91940283925264",
		Size = UDim2.new(0.052, 0, 0.052, 0)
	},
	["Jungle MiniTemple1"] = {
		Image = "rbxassetid://91625195241326",
		Size = UDim2.new(0.04, 0, 0.04, 0)
	},
	["Jungle MiniTemple2"] = {
		Image = "rbxassetid://91625195241326",
		Size = UDim2.new(0.04, 0, 0.04, 0)
	},
	["Jungle MiniTemple3"] = {
		Image = "rbxassetid://91625195241326",
		Size = UDim2.new(0.04, 0, 0.04, 0)
	},
	["Jungle MiniTemple4"] = {
		Image = "rbxassetid://91625195241326",
		Size = UDim2.new(0.04, 0, 0.04, 0)
	},
	["Jungle Fight Pit"] = {
		Image = "rbxassetid://98353112743668",
		Size = UDim2.new(0.04, 0, 0.04, 0)
	},
	["Jungle Mammoth Ruins"] = {
		Image = "rbxassetid://96296179979649",
		Size = UDim2.new(0.035, 0, 0.035, 0)
	},
	["Cave Entrance1"] = {
		Image = "rbxassetid://134957731651405",
		Size = UDim2.new(0.04, 0, 0.04, 0)
	},
	["Cave Entrance2"] = {
		Image = "rbxassetid://134957731651405",
		Size = UDim2.new(0.04, 0, 0.04, 0)
	},
	["Cave Entrance3"] = {
		Image = "rbxassetid://134957731651405",
		Size = UDim2.new(0.04, 0, 0.04, 0)
	},
	["Cave Entrance4"] = {
		Image = "rbxassetid://134957731651405",
		Size = UDim2.new(0.04, 0, 0.04, 0)
	},
	["Cave Entrance5"] = {
		Image = "rbxassetid://134957731651405",
		Size = UDim2.new(0.04, 0, 0.04, 0)
	},
	LightCrystal = {
		Image = "rbxassetid://76604122454019",
		Size = UDim2.new(0.04, 0, 0.04, 0)
	},
	BlessingStatues = {
		Image = "rbxassetid://74324603349337",
		Size = UDim2.new(0.04, 0, 0.04, 0)
	},
	TotemPole = {
		Image = "rbxassetid://111645847536316",
		Size = UDim2.new(0.05, 0, 0.05, 0)
	},
	["Elf Ice Lake"] = {
		Image = "rbxassetid://99828721885986",
		Size = UDim2.new(0.04, 0, 0.04, 0)
	},
	["Elf Ice Race"] = {
		Image = "rbxassetid://99828721885986",
		Size = UDim2.new(0.04, 0, 0.04, 0)
	},
	["Elf In Snow"] = {
		Image = "rbxassetid://99828721885986",
		Size = UDim2.new(0.04, 0, 0.04, 0)
	},
	["Elf Tree"] = {
		Image = "rbxassetid://99828721885986",
		Size = UDim2.new(0.04, 0, 0.04, 0)
	},
	["Easter Bunny's Safe"] = {
		Image = "rbxassetid://133906878654009",
		Size = UDim2.new(0.035, 0, 0.035, 0)
	},
	["Alien Crates"] = {
		Image = "rbxassetid://75504583591016",
		Size = UDim2.new(0.05, 0, 0.05, 0)
	},
	["Alien Satellite Dish"] = {
		Image = "rbxassetid://75504583591016",
		Size = UDim2.new(0.05, 0, 0.05, 0)
	},
	["Alien Scanning Station"] = {
		Image = "rbxassetid://75504583591016",
		Size = UDim2.new(0.05, 0, 0.05, 0)
	},
	["Alien Water Hole"] = {
		Image = "rbxassetid://75504583591016",
		Size = UDim2.new(0.05, 0, 0.05, 0)
	},
	["Crop Circle"] = {
		Image = "rbxassetid://75504583591016",
		Size = UDim2.new(0.05, 0, 0.05, 0)
	},
	["Alien Watch Tower"] = {
		Image = "rbxassetid://75504583591016",
		Size = UDim2.new(0.05, 0, 0.05, 0)
	},
	["Giant Beehive"] = {
		Image = "rbxassetid://97667708882457",
		Size = UDim2.new(0.052, 0, 0.052, 0)
	},
	["Beehive Birch Tree"] = {
		Image = "",
		Size = UDim2.new(0.023, 0, 0.023, 0)
	},
	["Beekeepers House"] = {
		Image = "rbxassetid://97500529690076",
		Size = UDim2.new(0.045, 0, 0.045, 0)
	}
}
local v18 = {
	[0] = {
		Image = "",
		Size = UDim2.new(0.023, 0, 0.023, 0)
	},
	[1] = {
		Image = "rbxassetid://90162046463167",
		Size = UDim2.new(0.023, 0, 0.023, 0)
	},
	[2] = {
		Image = "rbxassetid://102680351003649",
		Size = UDim2.new(0.028, 0, 0.028, 0)
	},
	[3] = {
		Image = "rbxassetid://116899195050590",
		Size = UDim2.new(0.033, 0, 0.033, 0)
	}
}
local v19 = {
	["Elf Ice Lake"] = true,
	["Elf Ice Race"] = true,
	["Elf In Snow"] = true,
	["Elf Tree"] = true
}
local v20 = {
	["Produce Store"] = true,
	["Gun Hut"] = true,
	Pipeline = true,
	["Flashlight Tower"] = true
}
local v21 = {
	["Alien Crates"] = true,
	["Alien Satellite Dish"] = true,
	["Alien Scanning Station"] = true,
	["Alien Water Hole"] = true,
	["Alien Watch Tower"] = true,
	["Crop Circle"] = true
}
local v22 = {
	ItemChest1 = {
		Open = "rbxassetid://107635109030148",
		Closed = "rbxassetid://128427487775339"
	},
	ItemChest2 = {
		Open = "rbxassetid://74047389217108",
		Closed = "rbxassetid://105645521950468"
	},
	ItemChest3 = {
		Open = "rbxassetid://138817649040947",
		Closed = "rbxassetid://121059936485711"
	},
	ItemChest4 = {
		Open = "rbxassetid://97332724131282",
		Closed = "rbxassetid://116595070263979"
	},
	ItemChest5 = {
		Open = "rbxassetid://97585693677319",
		Closed = "rbxassetid://94684935034586"
	},
	ItemChest6 = {
		Open = "rbxassetid://119310969949674",
		Closed = "rbxassetid://124257783039433"
	},
	SnowChest1 = {
		Open = "rbxassetid://137882146977708",
		Closed = "rbxassetid://108997894062556"
	},
	SnowChest2 = {
		Open = "rbxassetid://72752767980135",
		Closed = "rbxassetid://72446536397608"
	},
	VolcanicChest1 = {
		Open = "rbxassetid://137726751237230",
		Closed = "rbxassetid://74807493249956"
	},
	VolcanicChest2 = {
		Open = "rbxassetid://136329460194685",
		Closed = "rbxassetid://77927573099488"
	},
	ObsidironChest = {
		Open = "rbxassetid://105642756162761",
		Closed = "rbxassetid://103436025695313"
	},
	JungleChest1 = {
		Open = "rbxassetid://91160109734626",
		Closed = "rbxassetid://72988591595721"
	},
	JungleChest2 = {
		Open = "rbxassetid://120474821748244",
		Closed = "rbxassetid://130470176335180"
	},
	ChristmasChest1 = {
		Open = "",
		Closed = "rbxassetid://93612098939018"
	},
	ChristmasChest2 = {
		Open = "",
		Closed = "rbxassetid://131312337759379"
	},
	CorruptedChest = {
		Open = "rbxassetid://123468551222524",
		Closed = "rbxassetid://84241532616437"
	},
	HardModeCrate = {
		Open = "rbxassetid://132149540154447",
		Closed = "rbxassetid://88465593037411"
	},
	AlienChest = {
		Open = "rbxassetid://107616898611244",
		Closed = "rbxassetid://84137819887941"
	},
	AlienChestSmall = {
		Open = "rbxassetid://73816593864519",
		Closed = "rbxassetid://138829801546427"
	}
}

function ReplaceLandmarkIcon(p, image)
	v17[p].Image = image

	if v7[p] then
		for _, v23 in pairs(v7[p]) do
			v23.Image = image
		end
	end
end

Client.Events.ReplaceLandmarkIcon:Connect(ReplaceLandmarkIcon)

function worldToCell(p, p2)
	local v23 = math.floor((p + 1400) / 40)
	return math.floor((p2 + 1400) / 40), v23
end

function cellToWorld(p, p2)
	return p2 * 40 - 1400, p * 40 - 1400
end

function cellToScale(p, p2)
	return p2 / 71 + 0.007142857142857143, p / 71 + 0.007142857142857143
end

function worldToScale(p, p2)
	return p / 2800 + 0.5, p2 / 2800 + 0.5
end

MapDrawClient.WorldToScale = worldToScale

function scaleToWorld(p, p2)
	return (p - 0.5) * 2800, (p2 - 0.5) * 2800
end

MapDrawClient.ScaleToWorld = scaleToWorld

function MapDrawClient.IsSurfaceMapOpen()
	return MapFrame ~= nil and Client.Interface.MapHolder.Visible and MapFrame.Parent == Client.Interface.MapHolder
end

function MapDrawClient.GetMapFrame()
	return MapFrame
end

function MapDrawClient.MapPixelToWorld(p)
	if not MapDrawClient.IsSurfaceMapOpen() then
		return nil
	end

	local closeButton = Client.Interface.MapHolder:FindFirstChild("CloseButton")

	if closeButton then
		local v23 = (Vector2.new(p.X, p.Y) - closeButton.AbsolutePosition) / closeButton.AbsoluteSize

		if v23.X >= 0 and v23.X <= 1 and v23.Y >= 0 and v23.Y <= 1 then
			return nil
		end
	end

	local v23 = (Vector2.new(p.X, p.Y) - MapFrame.AbsolutePosition) / MapFrame.AbsoluteSize

	if v23.X < 0 or v23.X > 1 or v23.Y < 0 or v23.Y > 1 then
		return nil
	end

	return scaleToWorld(v23.X, v23.Y)
end

function ForTilesInRadius(p, callback)
	local v23 = p ^ 2

	for i = 0, 70 do
		for i2 = 0, 70 do
			local v24, v25 = cellToWorld(i, i2)

			if v24 ^ 2 + v25 ^ 2 <= v23 then
				callback(i, i2)
			end
		end
	end
end

function UpdateMapRange()
	local v23 = workspace:GetAttribute("MapRange") + 25

	if v2 < v23 then
		v2 = v23
		ForTilesInRadius(v2, function(p, p2)
			if v3[p] and v3[p][p2] == "Boundary" then
				v3[p][p2] = "Fog"
			end
		end)
		FullUpdateMap()
	end
end

function PrepareCaveMap()
	local caveMap = game.ReplicatedStorage:WaitForChild("Caves"):WaitForChild("CaveMap")
	local children = caveMap:GetChildren()
	caveMap:Destroy()

	for _, v23 in pairs(children) do
		local position2 = v23.Position
		local v24, v25 = worldToCell(position2.X, position2.Z)

		if v4[v24] == nil then
			v4[v24] = {}
		end

		v4[v24][v25] = "Undiscovered"
	end

	FullUpdateCaveMap()
end

function PrepareMap()
	local biomes = workspace:WaitForChild("Map"):WaitForChild("Biomes")

	if not biomes:GetAttribute("BiomesLoaded") then
		biomes:GetAttributeChangedSignal("BiomesLoaded"):Wait()
	end

	if Client.GlobalSettings.ChristmasMap then
		MapFrame.Background.Grass.BackgroundColor3 = color
	end

	Client.BiomesClient.ReloadBiomes()
	local unlockMap = game.ReplicatedStorage:GetAttribute("UnlockMap")

	for i = 0, 70 do
		local v23 = nil

		for i2 = 0, 71 do
			local v24, v25 = cellToWorld(i, i2)
			local v26 = v24 ^ 2 + v25 ^ 2

			if i2 <= 70 then
				if v3[i] == nil then
					v3[i] = {}
				end

				if v26 > 1988100 then
					v3[i][i2] = "Boundary"
				elseif v26 <= 11025 or unlockMap then
					v3[i][i2] = "Discovered"
				elseif v26 <= v2 then
					v3[i][i2] = "Fog"
				else
					v3[i][i2] = "Boundary"
				end
			end

			local biomeXZ, biome = Client.BiomesClient.GetBiomeXZ(v24, v25)

			if v23 ~= nil and (biomeXZ ~= v23.BiomeName or i2 == 71) then
				local column = v23.Column
				local v28 = i2 - 1
				local _, v29 = cellToScale(i, column)
				cellToScale(i, v28)
				local frame = Instance.new("Frame")
				frame.AnchorPoint = Vector2.new(0, 0.5)
				frame.BorderSizePixel = 0
				frame.ZIndex = 2
				frame.Parent = MapFrame.Background
				frame.BackgroundColor3 = v23.Biome.GroundColour
				frame.Name = "Biome" .. i
				local v30 = v28 - column + 1
				frame.Size = UDim2.new(v30 / 71, 0, 0.014285714285714285, 0)
				local v31 = cellToScale(i, column)
				frame.Position = UDim2.new(v31 - 0.007142857142857143, 0, v29, 0)
				v23 = nil
			end

			if biomeXZ and v23 == nil then
				v23 = {
					Column = i2,
					Biome = biome,
					BiomeName = biomeXZ
				}
			end
		end
	end

	workspace:GetAttributeChangedSignal("MapRange"):Connect(function()
		UpdateMapRange()
	end)
	UpdateMapRange()
	TrackMapIcons()
	FullUpdateMap()
	CreateIcon("Campfire", 0, 0, {
		Visible = true
	})
end

function FullUpdateMap()
	for i = 0, 70 do
		UpdateRow(i)
	end
end

function FullUpdateCaveMap()
	for i = 0, 70 do
		UpdateCaveRow(i)
	end
end

function UpdateCaveRow(p)
	if not v4[p] then
		return
	end

	local v23 = v15[p]

	if v23 == nil then
		v23 = {}
		v15[p] = v23
	end

	math.floor(CaveMapFrame.AbsoluteSize.X / 70)
	local v24 = nil
	local v25 = 1

	for i = 0, 71 do
		local v26 = v4[p][i]

		if v24 ~= nil and v26 ~= v24.Type then
			local column = v24.Column
			local v27 = i - 1
			local _, v28 = cellToScale(p, column)
			cellToScale(p, v27)
			local v29 = v23[v25]

			if not v29 then
				v29 = Instance.new("Frame")
				table.insert(v23, v29)
				v29.AnchorPoint = Vector2.new(0, 0.5)
				v29.Name = p .. "_" .. i
				v29.BorderSizePixel = 0
				v29.ZIndex = 5
				v29.Parent = CaveMapFrame.Tiles
			end

			if v24.Type == "Discovered" then
				v29.BackgroundColor3 = Color3.fromRGB(124, 124, 124)
			elseif v24.Type == "Boundary" then
				v29.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			elseif v24.Type == "Fog" then
				v29.BackgroundColor3 = color2
			end

			v25 += 1
			local v30 = v27 - column + 1
			v29.Size = UDim2.new(v30 / 71, 0, 0.014285714285714285, 0)
			local v31 = cellToScale(p, column)
			v29.Position = UDim2.new(v31 - 0.007142857142857143, 0, v28, 0)
			v24 = nil
		end

		if v26 and v26 ~= "Undiscovered" and v24 == nil then
			v24 = {
				Column = i,
				Type = v26
			}
		end
	end

	while v25 <= #v23 do
		table.remove(v23, v25):Destroy()
	end
end

function UpdateRow(p)
	if not v3[p] then
		print("no row", p)
		return
	end

	local v23 = v14[p]

	if v23 == nil then
		v23 = {}
		v14[p] = v23
	end

	math.floor(MapFrame.AbsoluteSize.X / 70)
	local v24 = nil
	local v25 = 1

	for i = 0, 71 do
		local v26 = v3[p][i]

		if v24 ~= nil and v26 ~= v24.Type then
			local column = v24.Column
			local v27 = i - 1
			local _, v28 = cellToScale(p, column)
			cellToScale(p, v27)
			local v29 = v23[v25]

			if not v29 then
				v29 = Instance.new("Frame")
				table.insert(v23, v29)
				v29.AnchorPoint = Vector2.new(0, 0.5)
				v29.Name = p .. "_" .. i
				v29.BorderSizePixel = 0
				v29.ZIndex = 5
				v29.Parent = MapFrame.Tiles
			end

			if v24.Type == "Boundary" then
				v29.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			elseif v24.Type == "Fog" then
				v29.BackgroundColor3 = color2
			end

			v25 += 1
			local v30 = v27 - column + 1
			v29.Size = UDim2.new(v30 / 71, 0, 0.014285714285714285, 0)
			local v31 = cellToScale(p, column)
			v29.Position = UDim2.new(v31 - 0.007142857142857143, 0, v28, 0)
			v24 = nil
		end

		if v26 and v26 ~= "Discovered" and v24 == nil then
			v24 = {
				Column = i,
				Type = v26
			}
		end
	end

	while v25 <= #v23 do
		table.remove(v23, v25):Destroy()
	end
end

function MapDrawClient.MakeTeleporterIcon(p, p2)
	local clone = MapFrame.TeleporterTemplate:Clone()
	clone.Name = "teleportericon"
	clone.ZIndex = 19
	local v23, v24 = worldToScale(p, p2)
	clone.Position = UDim2.new(v23, 0, v24, 0)
	clone.Visible = true
	clone.Parent = Client.Interface.MapHolder
	return clone
end

function CreateIcon(structureName, p, p2, options, p3)
	local v23 = options or {}
	local v24, v25 = worldToCell(p, p2)
	local v26, v27 = worldToScale(p, p2)
	local v28 = v3[v24] and v3[v24][v25]

	if p3 then
		v28 = v4[v24] and v4[v24][v25]
	end

	local halloweenHouse = v17[structureName] or {}

	if string.sub(structureName, 1, 15) == "Halloween House" then
		halloweenHouse = v17["Halloween House"]
	end

	if string.sub(structureName, 1, 12) == "LightCrystal" then
		halloweenHouse = v17.LightCrystal
	end

	if string.sub(structureName, 1, 15) == "BlessingStatues" then
		halloweenHouse = v17.BlessingStatues
	end

	local v29 = v5[v24] and v5[v24][v25]

	if p3 then
		v29 = v9[v24] and v9[v24][v25]
	end

	local dynamic = v23.Dynamic
	local visible = v23.Visible
	local visible3 = v28 == "Discovered" or visible

	if v29 and v29[structureName] then
		if v22[structureName] and v23.Open then
			v29[structureName].Image = v22[structureName].Open

			if v28 and v28.Icon and v28.Icon:FindFirstChild("circle") then
				v28.Icon.circle:Destroy()
			end
		end

		return v29[structureName]
	else
		local image = halloweenHouse.Image

		if v22[structureName] then
			image = v23.Open and v22[structureName].Open or v22[structureName].Closed
		end

		if image == nil then
			local itemChest1 = v22.ItemChest1
			image = v23.Open and itemChest1.Open or itemChest1.Closed
		end

		local clone

		if dynamic and v6[structureName] then
			clone = v6[structureName]
		else
			if not MapFrame then
				repeat
					task.wait()
				until MapFrame
			end

			clone = MapFrame.Template:Clone()
			clone.Name = structureName .. "Icon"
			clone.Image = image
			clone.ZIndex = 15
			clone:SetAttribute("StructureName", structureName)
		end

		if structureName == "Campfire" then
			clone.ZIndex = 25
		elseif structureName == "TotemPole" then
			clone.ZIndex = 24
		elseif structureName == "Pond" then
			clone.ZIndex = 10
		elseif structureName == "Beehive Birch Tree" then
			clone.ZIndex = 12
		elseif structureName == "LargeStructure" then
			clone.ZIndex = 11
		end

		if halloweenHouse.ImageTransparency then
			clone.ImageTransparency = halloweenHouse.ImageTransparency
		end

		clone.Position = UDim2.new(v26, 0, v27, 0)
		clone.Size = v23.Size or halloweenHouse.Size or UDim2.new(0.035, 0, 0.035, 0)

		if v22[structureName] then
			if not v23.Open then
				local clone2 = MapFrame.Template:Clone()
				clone2.Name = "circle"
				clone2.Parent = clone
				clone2.Image = "rbxassetid://86105377806715"
				clone2.ImageColor3 = Color3.fromRGB(255, 255, 0)
				clone2.Size = UDim2.new(3, 0, 3, 0)
				clone2.Visible = Client.TutorialClient.ChestTutorialActive
				Client.TutorialClient.SomeoneHasOpenedChest = true
				table.insert(MapDrawClient.TutorialCircles, clone2)
			end

			clone.ZIndex = 16
			clone.Size = UDim2.new(0.031, 0, 0.031, 0)
		end

		if dynamic then
			v6[structureName] = clone
		else
			local v31 = v5

			if p3 then
				v31 = v9
			end

			if v31[v24] == nil then
				v31[v24] = {}
			end

			if v31[v24][v25] == nil then
				v31[v24][v25] = {}
			end

			v31[v24][v25][structureName] = clone
		end

		if structureName == "LargeStructure" and v20[v23.Structure] then
			if v23.Visited then
				clone.Image = v17.LargeStructureVisited.Image
			else
				v8[clone] = Vector3.new(p, 0, p2)
			end
		end

		clone.Visible = visible3

		if p3 then
			clone.Parent = CaveMapFrame.Icons
			return clone
		end

		clone.Parent = MapFrame.Icons
		return clone
	end
end

Client.Events.MakeIconOnMap:Connect(CreateIcon)

function MapDrawClient:AddPingFrameToMap(data)
	local v23, v24 = worldToScale(data.X, data.Z)
	self.Position = UDim2.new(v23, 0, v24, 0)
	self.ZIndex = 25
	self.Size = UDim2.new(0.1, 0, 0.1, 0)

	if data.Y > -100 then
		self.Parent = MapFrame.Icons
	else
		self.Parent = CaveMapFrame.Icons
	end
end

local v23 = {
	["Cave Entrance"] = {
		"Cave Entrance1",
		"Cave Entrance2",
		"Cave Entrance3",
		"Cave Entrance4",
		"Cave Entrance5"
	},
	UFOCrash = {
		"UFOCrash1",
		"UFOCrash2",
		"UFOCrash3",
		"UFOCrash4",
		"UFOCrash5"
	},
	["Jungle MiniTemple"] = {
		"Jungle MiniTemple1",
		"Jungle MiniTemple2",
		"Jungle MiniTemple3",
		"Jungle MiniTemple4"
	}
}

function TrackMapIcons()
	task.spawn(function()
		local map = game.ReplicatedStorage:WaitForChild("Map")
		local radar = game.ReplicatedStorage:WaitForChild("Shops"):WaitForChild("Radar")

		local function updateLandmark(child)
			if type(child) == "string" then
				child = map:FindFirstChild(child)
			end

			if child == nil then
				return
			end

			local position2 = child:GetAttribute("Position")
			local iconType = child:GetAttribute("IconType")
			local name = child.Name
			local cave = child:GetAttribute("Cave")

			if not iconType then
				return
			end

			local v24 = nil
			local v25 = string.split(name, ".")

			if #v25 > 1 then
				name = v25[1]

				if v25[2] then
					v24 = tonumber(v25[2])
				end
			end

			local halloweenHouse = v17[name]

			if string.sub(name, 1, 15) == "Halloween House" then
				halloweenHouse = v17["Halloween House"]
			end

			if string.sub(name, 1, 12) == "LightCrystal" then
				halloweenHouse = v17.LightCrystal
			end

			if string.sub(name, 1, 15) == "BlessingStatues" then
				halloweenHouse = v17.BlessingStatues
			end

			if halloweenHouse == nil then
				return
			end

			if position2 == nil and v7[name] then
				if name == "Corrupted Wolf Rift" or name == "Corrupted Tree Rift" then
					return
				end

				for i = #v7[name], 1, -1 do
					local v26 = v7[name][i]

					if v26:GetAttribute("UID") ~= v24 then
						continue
					end

					local v27, v28 = scaleToWorld(v26.Position.X.Scale, v26.Position.Y.Scale)
					local v29, v30 = worldToCell(v27, v28)

					if v5[v29] and v5[v29][v30] and v5[v29][v30][name] == v26 then
						v5[v29][v30][name] = nil
					end

					if v9[v29] and v9[v29][v30] and v9[v29][v30][name] == v26 then
						v9[v29][v30][name] = nil
					end

					v26:Destroy()
					table.remove(v7[name], i)
				end

				if #v7[name] == 0 then
					v7[name] = nil
				end

				if v6[name] and v6[name].Parent then
					v6[name]:Destroy()
				end

				v6[name] = nil
			else
				if position2 == nil and v6[name] then
					v6[name] = nil
				end

				if position2 == nil then
					return
				end

				if name == "ToolWorkshopMeteorShower" and v7.ToolWorkshop then
					for _, v26 in pairs(v7.ToolWorkshop) do
						v26:Destroy()
					end

					v7.ToolWorkshop = nil
				elseif name == "ToolWorkshop" and (v7.ToolWorkshopMeteorShower or map:FindFirstChild("ToolWorkshopMeteorShower")) then
					if v7.ToolWorkshop then
						for _, v26 in pairs(v7.ToolWorkshop) do
							v26:Destroy()
						end

						v7.ToolWorkshop = nil
					end

					return
				end

				local visible = (Client.GlobalSettings.UpdateLandmarks[name] or game.ReplicatedStorage:GetAttribute("UnlockMap") or game.ReplicatedStorage:GetAttribute("ElfScanner") and v19[name] or v16 and name == "Beehive Birch Tree" or radar:GetAttribute(name) or radar:GetAttribute(string.gsub(
					name,
					" ",
					"_"
				))) and true or child:GetAttribute("Reveal") and true or false
				local v27 = CreateIcon(name, position2.X, position2.Z, {
					Visible = visible,
					Dynamic = iconType == "Dynamic",
					UserId = child:GetAttribute("BuiltBy")
				}, cave)

				if v24 then
					v27:SetAttribute("UID", v24)
				end

				task.spawn(function()
					if name == "Corrupted Wolf Rift" or name == "Corrupted Tree Rift" then
						local function update()
							local state = child:GetAttribute("State")

							if state == 0 then
								v27.Image = "rbxassetid://104790147481536"
							elseif state == 1 then
								v27.Image = "rbxassetid://134896537251897"
							else
								v27.Image = "rbxassetid://109217835678947"
							end
						end

						child:GetAttributeChangedSignal("State"):Connect(update)
						local state = child:GetAttribute("State")

						if state == 0 then
							v27.Image = "rbxassetid://104790147481536"
						elseif state == 1 then
							v27.Image = "rbxassetid://134896537251897"
						else
							v27.Image = "rbxassetid://109217835678947"
						end
					end

					if name == "Beehive Birch Tree" then
						-- equivalent calls inferred from this helper; original call sites unknown
						local function update()
							local v28 = v18[child:GetAttribute("State")] or v18[0]
							v27.Image = v28.Image
							v27.Size = v28.Size
						end

						child:GetAttributeChangedSignal("State"):Connect(update)
						update() -- equivalent call inferred; original call site unknown
					end
				end)

				if v7[name] == nil then
					v7[name] = {}
				end

				if not table.find(v7[name], v27) then
					table.insert(v7[name], v27)
				end
			end
		end

		map.ChildAdded:Connect(function(child)
			updateLandmark(child)
			child:GetAttributeChangedSignal("Position"):Connect(function()
				updateLandmark(child)
			end)
			child:GetAttributeChangedSignal("Reveal"):Connect(function()
				updateLandmark(child)
			end)
		end)
		map.ChildRemoved:Connect(function(child)
			updateLandmark(child)
		end)

		for _, child in pairs(map:GetChildren()) do
			updateLandmark(child)
			local v24 = child
			child:GetAttributeChangedSignal("Position"):Connect(function()
				updateLandmark(v24)
			end)
			local v25 = child
			child:GetAttributeChangedSignal("Reveal"):Connect(function()
				updateLandmark(v25)
			end)
		end

		radar.AttributeChanged:Connect(function(attributeName)
			if radar:GetAttribute(attributeName) == true then
				local v24 = string.gsub(attributeName, "_", " ")

				if v23[v24] then
					for _, v25 in pairs(v23[v24]) do
						updateLandmark(v25)

						if not v7[v25] then
							continue
						end

						for _, v26 in pairs(v7[v25]) do
							v26.Visible = true
						end
					end
				end

				updateLandmark(v24)

				if v7[v24] then
					for _, v25 in pairs(v7[v24]) do
						v25.Visible = true
					end
				end
			end
		end)
	end)
end

function UncoverTilesAroundPlayer()
	local v24 = {}
	local v25 = {}
	local v26 = {}
	local v27 = {}

	for _, child in pairs(game.Players:GetChildren()) do
		local primaryPart = child.Character and child.Character.PrimaryPart

		if not primaryPart then
			continue
		end

		local position2 = primaryPart.Position

		if child:GetAttribute("InCave") then
			position2 -= position
		end

		local v28, v29 = worldToCell(position2.X, position2.Z)

		for i = v28 - 4, v28 + 4 do
			for i2 = v29 - 4, v29 + 4 do
				if child:GetAttribute("InCave") then
					local v30 = v4[i] and v4[i][i2]

					if v30 and v30 == "Undiscovered" then
						local v31, v32 = cellToWorld(i, i2)

						if (v31 - position2.X) ^ 2 + (v32 - position2.Z) ^ 2 < 5625 then
							v24[i] = true
							v4[i][i2] = "Discovered"
							table.insert(v25, {
								Row = i,
								Col = i2
							})

							if v9[i] and v9[i][i2] then
								for _, v33 in pairs(v9[i][i2]) do
									v33.Visible = true
								end
							end
						end
					end
				else
					local v30 = v3[i] and v3[i][i2]

					if v30 and v30 == "Fog" then
						local v31, v32 = cellToWorld(i, i2)

						if (v31 - position2.X) ^ 2 + (v32 - position2.Z) ^ 2 < 5625 then
							v26[i] = true
							v3[i][i2] = "Discovered"
							table.insert(v27, {
								Row = i,
								Col = i2
							})
							local radar = game.ReplicatedStorage:WaitForChild("Shops"):WaitForChild("Radar")

							if v5[i] and v5[i][i2] then
								for _, v33 in pairs(v5[i][i2]) do
									local structureName = v33:GetAttribute("StructureName")

									if structureName and radar:GetAttribute((string.gsub(
										string.gsub(structureName, "%d", ""),
										" ",
										"_"
									))) == false then
										Client.Events.FoundLandmark:FireServer(structureName)
									end

									v33.Visible = true
								end
							end
						end
					end
				end
			end
		end
	end

	for k in pairs(v26) do
		UpdateRow(k)
	end

	for k in pairs(v24) do
		UpdateCaveRow(k)
	end

	if #v27 > 0 or #v25 > 0 then
		Client.Events.MapCellsDiscovered:FireServer(v27, v25)
	end
end

function UpdateVisitedStructureIcons()
	local primaryPart = localPlayer.Character and localPlayer.Character.PrimaryPart

	if not primaryPart or localPlayer:GetAttribute("InCave") then
		return
	end

	for k, v24 in pairs(v8) do
		local v25 = primaryPart.Position - v24

		if not (math.abs(v25.X) <= 20 and math.abs(v25.Z) <= 20) then
			continue
		end

		k.Image = v17.LargeStructureVisited.Image
		v8[k] = nil
		Client.Events.StructureIconVisited:FireServer(v24.X, v24.Z)
	end
end

function UpdatePlayerLocations()
	for _, child in pairs(game.Players:GetChildren()) do
		if not v10[child] then
			local clone = MapFrame.Players.Template:Clone()
			clone.Name = child.Name
			clone.ZIndex = 28
			clone.Avatar.Visible = true

			if child == localPlayer then
				clone.Image = "rbxassetid://78479305709062"
				clone.Size = UDim2.new(0.095, 0, 0.095, 0)
				clone.Avatar.Size = UDim2.new(0.387, 0, 0.418, 0)
				clone.Avatar.Position = UDim2.new(0.487, 0, 0.502, 0)
				clone.ZIndex = 30
			else
				clone.Avatar.Size = UDim2.new(1, 0, 1, 0)
				clone.Avatar.Position = UDim2.new(0.5, 0, 0.5, 0)
			end

			ShowAvatarHeadshot(clone, child)
			ShowAvatarHead(clone, child)
			clone.Visible = true
			clone.Parent = MapFrame.Players
			v10[child] = clone
		end

		local v24 = v10[child]
		local pivot = child.Character and child.Character:GetPivot()

		if pivot then
			if child:GetAttribute("InCave") then
				pivot -= position
			end

			local v25, v26 = worldToScale(pivot.X, pivot.Z)
			v24.Position = UDim2.new(v25, 0, v26, 0)
		end

		if child == localPlayer then
			local unit = (workspace.CurrentCamera.CFrame.LookVector * createVector(1, 0, 1)).Unit
			local angleBetweenVectors, v25 = Client.Utility.GetAngleBetweenVectors(unit, createVector(0, 0, -1))
			v24.Rotation = math.deg(angleBetweenVectors) * v25
		end

		if child:GetAttribute("InCave") and child ~= localPlayer then
			v24.Visible = false
		else
			v24.Visible = true
		end

		UpdateAvatarPeek(v24, child)
	end
end

local v24 = {}

function UpdatePlayerCaveLocations()
	for _, child in pairs(game.Players:GetChildren()) do
		if not v24[child] then
			local clone = CaveMapFrame.Players.Template:Clone()
			clone.Name = child.Name
			clone.ZIndex = 28
			clone.Avatar.Visible = true

			if child == localPlayer then
				clone.Image = "rbxassetid://78479305709062"
				clone.Size = UDim2.new(0.095, 0, 0.095, 0)
				clone.Avatar.Size = UDim2.new(0.387, 0, 0.418, 0)
				clone.Avatar.Position = UDim2.new(0.487, 0, 0.502, 0)
				clone.ZIndex = 30
			else
				clone.Avatar.Size = UDim2.new(1, 0, 1, 0)
				clone.Avatar.Position = UDim2.new(0.5, 0, 0.5, 0)
			end

			ShowAvatarHeadshot(clone, child)
			ShowAvatarHead(clone, child)
			clone.Visible = true
			clone.Parent = CaveMapFrame.Players
			v24[child] = clone
		end

		local v25 = v24[child]
		local pivot = child.Character and child.Character:GetPivot()

		if pivot then
			if child:GetAttribute("InCave") then
				pivot -= position
			end

			local v26, v27 = worldToScale(pivot.X, pivot.Z)
			v25.Position = UDim2.new(v26, 0, v27, 0)
		end

		if child == localPlayer then
			local unit = (workspace.CurrentCamera.CFrame.LookVector * createVector(1, 0, 1)).Unit
			local angleBetweenVectors, v26 = Client.Utility.GetAngleBetweenVectors(unit, createVector(0, 0, -1))
			v25.Rotation = math.deg(angleBetweenVectors) * v26
		end

		if child:GetAttribute("InCave") or child == localPlayer then
			v25.Visible = true
		else
			v25.Visible = false
		end

		UpdateAvatarPeek(v25, child)
	end
end

function MakeHeadModel(instance, instance2)
	local model = Instance.new("Model")
	local cFrame = instance2.CFrame
	local clone = instance2:Clone()
	clone.Color = color3
	clone.Parent = model
	model.PrimaryPart = clone
	local specialMesh = clone:FindFirstChildOfClass("SpecialMesh")

	if specialMesh and specialMesh.TextureId ~= "" then
		for _, decal in pairs(clone:GetChildren()) do
			if decal:IsA("Decal") then
				decal:Destroy()
			end
		end

		local clone2 = clone:Clone()
		clone2.Transparency = 0.01
		local specialMesh2 = clone2:FindFirstChildOfClass("SpecialMesh")
		specialMesh2.Scale *= 1.01
		clone2.Parent = model
		specialMesh.TextureId = ""
	end

	for _, accessory in pairs(instance:GetChildren()) do
		local handle = accessory:IsA("Accessory") and accessory:FindFirstChild("Handle")

		if handle then
			handle:FindFirstChild("AccessoryWeld")
		end
	end

	for _, descendant in pairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CFrame = cFrame:ToObjectSpace(descendant.CFrame)
			descendant.Anchored = true
		elseif not (descendant:IsA("DataModelMesh") or descendant:IsA("Decal") or descendant:IsA("SurfaceAppearance")) then
			descendant:Destroy()
		end

		if not descendant.Parent then
			continue
		end

		for _, tag in pairs(CollectionService:GetTags(descendant)) do
			CollectionService:RemoveTag(descendant, tag)
		end
	end

	return model
end

function ShowAvatarHeadshot(state, p)
	local avatar = state.Avatar
	avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. p.UserId .. "&w=150&h=150"
	avatar.ScaleType = Enum.ScaleType.Crop
	avatar.BackgroundColor3 = color3
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0.25, 0)
	uICorner.Parent = avatar
	local uIStroke = Instance.new("UIStroke")
	uIStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
	uIStroke.Thickness = 0.05
	uIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
	uIStroke.Color = Color3.fromRGB(10, 19, 25)
	uIStroke.Parent = avatar
	state.Image = p == localPlayer and "rbxassetid://103357833626912" or ""
	local v25 = {
		Headshot = avatar.Image,
		Stroke = uIStroke,
		Arrow = state.Image,
		Smiley = p == localPlayer and "rbxassetid://78479305709062" or "rbxassetid://82805377636599",
		DeadSmiley = p == localPlayer and "rbxassetid://128289209058935" or "rbxassetid://118534684831798",
		Hovered = false,
		Pressed = false,
		Until = 0
	}
	v12[state] = v25
	state.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			v25.Hovered = true
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			v25.Pressed = true
		end
	end)
	state.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			v25.Hovered = false
		end
	end)
end

function ShowAvatarHead(_, p)
	local _ = v11[p]
end

function UpdateAvatarPeek(p, player)
	local v25 = v12[p]
	local v26 = player.Character == nil
	local v27 = visible2 or v25.Hovered or v25.Pressed or time() < v25.Until
	local v28 = not v27 and false
	local avatar = p.Avatar
	p.Image = (v27 or v28) and v25.Arrow or v26 and v25.DeadSmiley or v25.Smiley
	avatar.Image = not v27 and "" or v25.Headshot or ""
	avatar.BackgroundTransparency = v28 and 0 or 1
	avatar.Head.Visible = v28
	avatar.Dead.Visible = v26 and (v27 or v28)
	v25.Stroke.Enabled = v28
end

function ToggleShowAvatars()
	visible2 = not visible2

	for _, v25 in pairs(showAvatars) do
		v25.Box.Tick.Visible = visible2
	end
end

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		for _, v25 in pairs(v12) do
			if not v25.Pressed then
				continue
			end

			v25.Pressed = false
			v25.Until = time() + 5
		end
	end
end)

function GetHeadLook(instance, instance2)
	local specialMesh = instance2:FindFirstChildOfClass("SpecialMesh")
	local v25 = tostring(instance2.Color) .. (specialMesh and specialMesh.MeshId .. specialMesh.TextureId or "")

	for _, accessory in pairs(instance:GetChildren()) do
		local handle = accessory:IsA("Accessory") and accessory:FindFirstChild("Handle")
		local accessoryWeld = handle and handle:FindFirstChild("AccessoryWeld")

		if accessoryWeld and accessoryWeld.Part1 == instance2 then
			v25 ..= accessory.Name
		end
	end

	return v25
end

function WatchAvatarHead(player)
	local v25 = nil

	while player.Parent do
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local head = character and character:FindFirstChild("Head")

		if head and humanoid and humanoid.Health > 0 and character.Parent then
			local v26 = GetHeadLook(character, head)

			if v26 ~= v25 then
				v11[player] = MakeHeadModel(character, head)
				v25 = v26

				for _, v28 in pairs({ v10, v24 }) do
					if v28[player] then
						ShowAvatarHead(v28[player], player)
					end
				end
			end
		end

		task.wait(2)
	end
end

game.Players.PlayerRemoving:Connect(function(player)
	v11[player] = nil

	if v10[player] then
		v12[v10[player]] = nil
		v10[player]:Destroy()
		v10[player] = nil
	end

	if v24[player] then
		v12[v24[player]] = nil
		v24[player]:Destroy()
		v24[player] = nil
	end
end)

function MapDrawClient.GetIcon(p)
	if p and v17[p] then
		return v17[p].Image
	end
end

function MapDrawClient.GetAlienMapIcons()
	local children = {}

	if not MapFrame then
		return children
	end

	for _, child in pairs(MapFrame.Icons:GetChildren()) do
		local structureName = child:GetAttribute("StructureName")

		if structureName and v21[structureName] then
			table.insert(children, child)
		end
	end

	return children
end

function MapDrawClient.IsAlienIconFound(p)
	local v25, v26 = scaleToWorld(p.Position.X.Scale, p.Position.Y.Scale)
	local v27, v28 = worldToCell(v25, v26)
	return (v3[v27] and v3[v27][v28] == "Discovered") == true
end

function MapDrawClient:RevealAlienSpot()
	local v25, v26 = scaleToWorld(self.Position.X.Scale, self.Position.Y.Scale)
	local v27, v28 = worldToCell(v25, v26)

	if v3[v27] and v3[v27][v28] ~= "Discovered" then
		v3[v27][v28] = "Discovered"
		UpdateRow(v27)
	end

	self.Visible = true
	self.ImageTransparency = 0
end

function MapDrawClient.GetIconZone(p)
	local v25, v26 = scaleToWorld(p.Position.X.Scale, p.Position.Y.Scale)
	local v27 = math.sqrt(v25 * v25 + v26 * v26)

	for i = 1, #v do
		if v27 <= v[i] then
			return i
		end
	end

	return #v
end

function MapStructureAdded(instance)
	if instance:IsDescendantOf(workspace.Structures) then
		local TEMPORARY = instance.Board:WaitForChild("BoardPart"):FindFirstChild("TEMPORARY")

		if TEMPORARY then
			TEMPORARY:Destroy()
		end

		local surfaceGui = instance.Board:WaitForChild("BoardPart"):WaitForChild("SurfaceGui")
		surfaceGui.Enabled = true
		AssignMapModel(instance)
		MapFrame.Parent = instance.Board.BoardPart.SurfaceGui
		boardPart = instance.Board.BoardPart
	end
end

function MapStructureRemoved(_)
	MapFrame.Parent = game.ReplicatedStorage.TempStorage
	boardPart = nil
	AssignMapModel(nil)
	Client.Events.MapRemoved:Fire()
end

function AssignMapModel(p)
	MapModel = p
	MapSurfaceGui = MapModel and MapModel:WaitForChild("Board"):WaitForChild("BoardPart"):WaitForChild("SurfaceGui")
	local topRight = Client.Interface.TopRight

	if MapModel then
		topRight:SetAttribute("EnabledSoFar", topRight:GetAttribute("EnabledSoFar") + 1)
		topRight.Frame.Map.LayoutOrder = topRight:GetAttribute("EnabledSoFar")
		topRight.Visible = true
		topRight.Frame.Map.Visible = true
	else
		if topRight:GetAttribute("EnabledSoFar") and topRight:GetAttribute("EnabledSoFar") < 2 then
			topRight.Visible = false
		end

		topRight.Frame.Map.Visible = false
		CloseMap()
	end
end

function IsInCave()
	return Client.BiomesClient.GetCurrentBiome() == "Cave"
end

function OpenMap()
	MapOpen = true

	if flag or not MapModel then
		return
	end

	Client.Sound.Play("PosterOpen")
	Client.Interface.TopRight.Frame.Map.TutorialLabel.Visible = false
	MapModel.Board.BoardPart.SurfaceGui.Notif.Visible = false

	if MainFire and (MainFire:GetAttribute("FuelRemaining") or 0) > 0 then
		MapFrame.Parent = Client.Interface.MapHolder
	end

	if IsInCave() then
		Client.Interface.CaveMapHolder.Visible = true
	else
		Client.Interface.MapHolder.Visible = true
	end
end

MapDrawClient.OpenMap = OpenMap

function MapDrawClient.OpenAlienScanner()
	if not MapFrame then
		return
	end

	flag = true
	MapOpen = true
	Client.Sound.Play("PosterOpen")
	MapFrame.Parent = Client.Interface.MapHolder
	Client.Interface.MapHolder.Visible = true
	Client.Interface.MapHolder.AliensRevenge.AlienScanButton.Visible = true
end

function CloseMap()
	MapOpen = false

	if flag then
		flag = false
		Client.Interface.MapHolder.AliensRevenge.AlienScanButton.Visible = false
		Client.AlienScannerClient.CloseScannerView()

		if not MapModel then
			MapFrame.Parent = game.ReplicatedStorage.TempStorage
		end
	end

	if MapModel then
		MapFrame.Parent = MapSurfaceGui
	end

	Client.Interface.MapHolder.Visible = false
	Client.Interface.CaveMapHolder.Visible = false

	for _, v25 in pairs(v12) do
		v25.Hovered = false
	end

	Client.Sound.Play("CloseButton")
	Client.Events.MapClosed:Fire()
end

MapDrawClient.CloseMap = CloseMap
Client.Events.CloseMap:Connect(function()
	if MapOpen then
		CloseMap()
	end
end)

function ToggleMap()
	if not MapFrame or flag then
		return
	end

	if MapOpen then
		CloseMap()
	else
		OpenMap()
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.M then
		ToggleMap()
	elseif input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.DPadRight then
		ToggleMap()
	end
end)

function ElfScannerAdded()
	for k in pairs(v19) do
		if not v7[k] then
			continue
		end

		for _, v25 in pairs(v7[k]) do
			v25.Visible = true
		end
	end
end

function MapDrawClient.RevealBeehiveTreeIcons()
	v16 = true

	if v7["Beehive Birch Tree"] then
		for _, v25 in pairs(v7["Beehive Birch Tree"]) do
			v25.Visible = true
		end
	end
end

function FlashToolSmith(p)
	for _, parent in pairs(v7.ToolSmith or {}) do
		local upgradeRing = parent:FindFirstChild("UpgradeRing")

		if p then
			if not upgradeRing then
				upgradeRing = MapFrame.Template:Clone()
				upgradeRing.Name = "UpgradeRing"
				upgradeRing.Image = "rbxassetid://86105377806715"
				upgradeRing.ImageColor3 = Color3.fromRGB(255, 191, 0)
				upgradeRing.Size = UDim2.new(1.6, 0, 1.6, 0)
				upgradeRing.Visible = true
				upgradeRing.Parent = parent
			end

			parent.Visible = true
			upgradeRing.ImageTransparency = 1
			TweenService:Create(upgradeRing, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				ImageTransparency = 0
			}):Play()
			task.delay(0.8, function()
				TweenService:Create(
					upgradeRing,
					TweenInfo.new(1.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						ImageTransparency = 1
					}
				):Play()
			end)
		elseif upgradeRing then
			upgradeRing:Destroy()
		end
	end
end

Client.Events.ToolUpgradeFlash:Connect(FlashToolSmith)
Client.Events.RequestPlayerMapProgress:OnClientInvoke(function()
	print("server requested map progress")
	local result = {}

	for k, v25 in pairs(v3) do
		for k2, _ in pairs(v25) do
			if (v3[k] and v3[k][k2]) ~= "Discovered" then
				continue
			end

			if result[tostring(k)] == nil then
				result[tostring(k)] = {}
			end

			result[tostring(k)][tostring(k2)] = "Discovered"
		end
	end

	return result
end)

function LoadReplayedIcons()
	local v25 = Client.Events.RequestMapIconReplay:InvokeServer()

	if v25 then
		for _, v26 in pairs(v25) do
			CreateIcon(v26.Name, v26.X, v26.Z, {
				Visible = v26.Visible,
				Open = v26.Open,
				Structure = v26.Structure,
				Visited = v26.Visited
			})
		end
	end
end

function LoadMapOnRejoin()
	print("LOAD MAP ON REJOIN")
	task.wait(5)
	local v25, v26 = Client.Events.RequestServerMapProgress:InvokeServer(localPlayer)

	if v25 then
		local v27 = {}

		for k, v28 in pairs(v25) do
			local v29 = tonumber(k)

			for k2, _ in pairs(v28) do
				local v30 = tonumber(k2)

				if (v3[v29] and v3[v29][v30]) ~= "Fog" then
					continue
				end

				v27[v29] = true
				v3[v29][v30] = "Discovered"
				game.ReplicatedStorage:WaitForChild("Shops"):WaitForChild("Radar")

				if not (v5[v29] and v5[v29][v30]) then
					continue
				end

				for _, v31 in pairs(v5[v29][v30]) do
					v31.Visible = true
				end
			end
		end

		for k in pairs(v27) do
			UpdateRow(k)
		end
	end

	if v26 then
		local v27 = {}

		for k, v28 in pairs(v26) do
			local v29 = tonumber(k)

			for k2, _ in pairs(v28) do
				local v30 = tonumber(k2)

				if (v4[v29] and v4[v29][v30]) ~= "Undiscovered" then
					continue
				end

				v27[v29] = true
				v4[v29][v30] = "Discovered"

				if not (v9[v29] and v9[v29][v30]) then
					continue
				end

				for _, v31 in pairs(v9[v29][v30]) do
					v31.Visible = true
				end
			end
		end

		for k in pairs(v27) do
			UpdateCaveRow(k)
		end
	end
end

function MapDrawClient.Init()
	task.spawn(function()
		MainFire = workspace.Map.Campground:WaitForChild("MainFire")
		MapFrame = game.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Alec"):WaitForChild("MapClient"):WaitForChild("Map")
		CaveMapFrame = Client.Interface.CaveMapHolder.CaveMap
		PrepareMap()
		PrepareCaveMap()
		task.spawn(function()
			LoadReplayedIcons()
		end)
		Client.Interface.MapHolder.CloseButton.MouseButton1Down:Connect(function()
			CloseMap()
		end)
		Client.Interface.CaveMapHolder.CloseButton.MouseButton1Down:Connect(function()
			CloseMap()
		end)

		for _, v25 in pairs({ Client.Interface.MapHolder, Client.Interface.CaveMapHolder }) do
			local showAvatars2 = v25:FindFirstChild("ShowAvatars")

			if not showAvatars2 then
				continue
			end

			table.insert(showAvatars, showAvatars2)
			showAvatars2.Activated:Connect(ToggleShowAvatars)
		end

		Client.Interface.TopRight.Frame.Map.MouseButton1Down:Connect(function()
			ToggleMap()
		end)
		task.spawn(function()
			game.ReplicatedStorage:GetAttributeChangedSignal("ElfScanner"):Connect(function()
				ElfScannerAdded()
			end)
		end)
		task.spawn(function()
			MainFire:GetAttributeChangedSignal("FuelRemaining"):Connect(function()
				if flag then
					return
				end

				if MapOpen then
					if MainFire:GetAttribute("FuelRemaining") <= 0 then
						if MapModel then
							MapFrame.Parent = MapSurfaceGui
						else
							MapFrame.Parent = game.ReplicatedStorage.TempStorage
						end
					else
						MapFrame.Parent = Client.Interface.MapHolder
					end
				end
			end)
		end)
		task.spawn(function()
			if not localPlayer:GetAttribute("Rejoined") then
				localPlayer:GetAttributeChangedSignal("Rejoined"):Wait()
			end

			if localPlayer:GetAttribute("Rejoined") then
				LoadMapOnRejoin()
			end
		end)
		task.spawn(function()
			while true do
				task.wait()

				if IsInCave() then
					UpdatePlayerCaveLocations()
				else
					UpdatePlayerLocations()
				end
			end
		end)
		task.spawn(function()
			while true do
				task.wait(0.5)
				UncoverTilesAroundPlayer()
				UpdateVisitedStructureIcons()
			end
		end)
		Client.Utility.ForAllTagged("MapDraw", MapStructureAdded, MapStructureRemoved)
	end)
end

return MapDrawClient