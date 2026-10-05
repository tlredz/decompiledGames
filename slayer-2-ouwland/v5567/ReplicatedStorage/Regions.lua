local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local Shop = require(ReplicatedStorage.CAM.Global.Shop)
local ItemRequirements = require(ReplicatedStorage.CAM.Global.Collectibles.ItemRequirements)
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
local Dialogue = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("GamePlay"):WaitForChild("Dialogue"))
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local RotatingShop = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.RotatingShop)
local TimedVendor = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.TimedVendor)
local Locator = require(ReplicatedStorage.CAM.Global.Subsets.Areas.AreaLocator.Locator)
local DayAndNightHandler = require(ReplicatedStorage.CAM.Global.DayAndNightHandler)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local isServer = game["Run Service"]:IsServer()

local function find()
	for _, folder in ReplicatedStorage:GetChildren() do
		if folder:IsA("Folder") and folder:FindFirstChild("Content") then
			return folder
		end
	end

	return nil
end

local v = find()
local lastTime = os.clock()
local v2 = nil
local v3 = false

while v == nil do
	if workspace:GetAttribute("MinigameKey") ~= nil then
		v2 = v2 or os.clock()

		if os.clock() - v2 > 3 then
			break
		end
	end

	if not v3 and os.clock() - lastTime > 60 then
		warn("Regions: still no place folder with a 'Content' child under ReplicatedStorage — minigame content not staged in yet?")
		v3 = true
	end

	task.wait(0.5)
	v = find()
end

local soundTracks = game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Areas"):WaitForChild("AreaLocator"):WaitForChild("SoundTracks")
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include
local Regions = {
	Regions = {},
	Spawns = {},
	Shrines = {},
	Situations = {},
	Biomes = {}
}

if v ~= nil then
	local defaultCombatThemes = v:FindFirstChild("DefaultCombatThemes")

	if defaultCombatThemes ~= nil then
		defaultCombatThemes.Parent = soundTracks
	end

	local defaultTracks = v:FindFirstChild("DefaultTracks")

	if defaultTracks ~= nil then
		defaultTracks.Parent = soundTracks
	end

	local biomes = v:FindFirstChild("Biomes")

	if biomes ~= nil then
		Regions.Biomes = require(biomes)
	end
end

Regions.NpcIcons = {}
Regions.NpcRequirements = require(ReplicatedStorage.CAM.Global.NpcRequirements)
Regions.NpcSpawns = {}
local moduleScripts = {}
local CollectContent

CollectContent = function(instance)
	for _, moduleScript in ipairs(instance:GetChildren()) do
		if moduleScript:IsA("ModuleScript") then
			table.insert(moduleScripts, moduleScript)
		else
			CollectContent(moduleScript)
		end
	end
end

if v ~= nil then
	CollectContent(v:WaitForChild("Content"))
end

for _, moduleScript in ipairs(moduleScripts) do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local regions = Regions.Regions
	local name = moduleScript.Name
	local module = require(moduleScript)
	regions[name] = module
	Regions.Regions[moduleScript.Name].Name = moduleScript.Name
	local npcs = Regions.Regions[moduleScript.Name].Npcs

	if npcs ~= nil then
		for _, npc in ipairs(npcs) do
			if npc.Name ~= nil and npc.Icon ~= nil and npc.Icon ~= "" then
				Regions.NpcIcons[npc.Name] = npc.Icon
			end

			if npc.Name ~= nil and npc.Requirements ~= nil then
				Regions.NpcRequirements[npc.Name] = npc.Requirements
			end

			if npc.Name == nil or npc.Spawns == nil or npc.Spawns[1] == nil or npc.Type ~= Menum.npcType.Stationary and npc.Type ~= Menum.npcType.Idle then
				if npc.Name ~= nil and npc.Type == Menum.npcType.Active and npc.SendOver ~= nil and npc.SendOver.Spawning ~= nil and npc.SendOver.Spawning.Locations ~= nil and npc.SendOver.Spawning.Locations[1] ~= nil then
					local position = npc.SendOver.Spawning.Locations[1]
					local npcSpawns = Regions.NpcSpawns
					local name2 = npc.Name

					if typeof(position) == "CFrame" then
						position = position.Position
					end

					npcSpawns[name2] = position
				end
			else
				local position = npc.Spawns[1]
				local npcSpawns = Regions.NpcSpawns
				local name2 = npc.Name

				if typeof(position) == "CFrame" then
					position = position.Position
				end

				npcSpawns[name2] = position
			end
		end
	end

	if isServer then
		if moduleScript:FindFirstChild("SoundTracks") then
			for _, child in ipairs(moduleScript.SoundTracks:GetChildren()) do
				if soundTracks:FindFirstChild(moduleScript.Name) ~= nil then
					continue
				end

				child.Parent = soundTracks
				child.Name = moduleScript.Name
			end
		end
	else
		local dialogues = Regions.Regions[moduleScript.Name].Dialogues

		if dialogues ~= nil then
			for k, dialogue in pairs(dialogues) do
				Dialogue.Diagloues[k] = dialogue
			end
		end

		local dialogueFunctions = Regions.Regions[moduleScript.Name].DialogueFunctions

		if dialogueFunctions ~= nil then
			for k, dialogueFunction in pairs(dialogueFunctions) do
				Dialogue.Functions[k] = dialogueFunction
			end
		end

		local npcs2 = Regions.Regions[moduleScript.Name].Npcs

		if npcs2 ~= nil then
			for _, npc in ipairs(npcs2) do
				local shop = npc.Shop

				if shop ~= nil then
					for k, v4 in shop do
						Shop.RegisterItem(k, {
							Price = v4.Price,
							Type = v4.Type or Menum.ShopItemType.IngameItem,
							Grant = v4.Grant,
							Icon = v4.Icon,
							NoSave = v4.NoSave,
							RequiresQuestDone = npc.RequiresQuestDone,
							Requirements = npc.Requirements
						})
					end
				end

				if npc.RotatingShop ~= nil then
					npc.RotatingShop.RequiresQuestDone = npc.RotatingShop.RequiresQuestDone or npc.RequiresQuestDone
					RotatingShop.BindClient(npc.RotatingShop)
				end

				if npc.TimedVendor == nil then
					continue
				end

				npc.TimedVendor.RequiresQuestDone = npc.TimedVendor.RequiresQuestDone or npc.RequiresQuestDone
				TimedVendor.BindClient(npc.TimedVendor)
			end
		end
	end

	local quests = Regions.Regions[moduleScript.Name].Quests

	if quests == nil then
		continue
	end

	for k, quest in pairs(quests) do
		Quests.Holder[k] = quest
	end
end

function Regions.GetNpcIcon(p: string)
	return Regions.NpcIcons[p]
end

function Regions.GetNpcSpawn(p: string)
	return Regions.NpcSpawns[p]
end

if not isServer then
	return Regions
end

local WorldEvents = require(game.ServerStorage.SAM.Utility.WorldEvents)

for k, region in Regions.Regions do
	if region.Area ~= nil then
		Locator.Areas[k] = region.Area
	end
end

for k, biome in Regions.Biomes do
	Locator.Biomes[k] = biome
end

local folder_2 = Instance.new("Folder", workspace.Debree)
folder_2.Name = "Regions"
local folder_3 = Instance.new("Folder", workspace.Map)
folder_3.Name = "Regions"
local folder_4 = Instance.new("Folder", workspace.Humanoids)
folder_4.Name = "Regions"
local spawnCrystal = game.ReplicatedStorage.Assets.SpawnCrystal
local v4 = spawnCrystal.Root.Size.Y / 2
local shrineModel = game.ReplicatedStorage.Assets:FindFirstChild("ShrineModel")

function PrepareRegion(data, region: string)
	local folder = Instance.new("Folder", workspace.Debree.Regions)
	folder.Name = data.Name
	local folder2 = Instance.new("Folder", workspace.Map.Regions)
	folder2.Name = data.Name
	local folder3 = Instance.new("Folder", workspace.Humanoids.Regions)
	folder3.Name = data.Name

	for _, parent in { folder } do
		local folder4 = Instance.new("Folder")
		folder4.Name = "StationaryNpcs"
		folder4.Parent = parent
		local folder5 = Instance.new("Folder")
		folder5.Name = "ActiveNpcs"
		folder5.Parent = parent
	end

	for _, parent in { folder3 } do
		local folder4 = Instance.new("Folder")
		folder4.Name = "ActiveNpcs"
		folder4.Parent = parent
	end

	for _, v5 in data.Shrines or {} do
		local name = v5.Name

		if typeof(name) == "string" and name ~= "" and typeof(v5.At) == "CFrame" then
			if Regions.Shrines[name] == nil then
				local at = v5.At
				Regions.Shrines[name] = {
					Name = name,
					Region = region,
					At = at,
					Price = v5.Price
				}

				if shrineModel == nil then
					warn((`[Regions] {region}: shrine "{name}" registered with nothing stood for it, Assets.ShrineModel is missing`))
				else
					if shrineModel:IsA("Model") and shrineModel.PrimaryPart == nil then
						warn((`[Regions] Assets.ShrineModel has no PrimaryPart, shrine "{name}" cannot be placed`))
					end

					local clone = shrineModel:Clone()
					clone.Name = `Shrine - {name}`
					clone:SetAttribute("Shrine", name)
					local grass = clone:FindFirstChild("Grass")

					if grass ~= nil and grass:IsA("BasePart") then
						local raycastResult = Workspace:Raycast(at.Position, at.UpVector * -20, RaycastHelper.Crater)
						local instance

						if raycastResult ~= nil then
							instance = raycastResult.Instance
						end

						if instance ~= nil and instance:IsA("BasePart") then
							grass.Color = instance.Color
							grass.Material = instance.Material
							grass.MaterialVariant = instance.MaterialVariant

							for _, child in instance:GetChildren() do
								if not (child:IsA("SurfaceAppearance") or child:IsA("Texture")) then
									continue
								end

								local clone_2 = child:Clone()
								clone_2.Parent = grass
							end
						end
					end

					clone.Parent = folder2
					clone:PivotTo(at)
					local root = clone:FindFirstChild("Root")
					local proxHolder

					if root ~= nil then
						proxHolder = root:FindFirstChild("ProxHolder")
					end

					if proxHolder == nil then
						warn((`[Regions] Assets.ShrineModel has no Root.ProxHolder, shrine "{name}" gets no prompt`))
					else
						local proximityPrompt = Instance.new("ProximityPrompt")
						proximityPrompt.ActionText = "Unlock Shrine"
						proximityPrompt.ObjectText = name
						proximityPrompt.HoldDuration = 1
						proximityPrompt.KeyboardKeyCode = Enum.KeyCode.T
						proximityPrompt.RequiresLineOfSight = false
						proximityPrompt.Name = name
						proximityPrompt:AddTag("ShrineProximityPrompt")
						proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
						proximityPrompt.Parent = proxHolder
					end
				end
			else
				warn((`[Regions] {region}: shrine "{name}" is already declared by {Regions.Shrines[name].Region}, skipped`))
			end
		else
			warn((`[Regions] {region}: a shrine needs a Name and an At CFrame, one was skipped`))
		end
	end

	local v5 = {}

	if data.CrystalAt ~= nil then
		v5[region] = data
	end

	if data.Area ~= nil then
		for _, v6 in data.Area.Grid do
			for k, v7 in v6.ChildAreas or {} do
				if v7.CrystalAt ~= nil then
					v5[k] = v7
				end
			end
		end
	end

	for k, v6 in v5 do
		local crystalAt = v6.CrystalAt
		local raycastResult = Workspace:Raycast(crystalAt.Position, crystalAt.upVector * -20, RaycastHelper.Crater)
		local clone = spawnCrystal:Clone()

		if raycastResult ~= nil and raycastResult.Instance ~= nil then
			clone.Root.Color = raycastResult.Instance.Color
			clone.Root.Material = raycastResult.Instance.Material
			clone.Root.MaterialVariant = raycastResult.Instance.MaterialVariant

			for _, child in raycastResult.Instance:GetChildren() do
				if not (child.ClassName == "SurfaceAppearance" or child.ClassName == "Texture") then
					continue
				end

				local clone_3 = child:Clone()
				clone_3.Parent = clone.Root
			end

			crystalAt = CFrame.new(raycastResult.Position + vector.create(0, v4, 0)) * crystalAt.Rotation
		end

		if k ~= region then
			clone.Name = `SpawnCrystal - {k}`
		end

		clone:SetAttribute("SpawnArea", k)
		clone.Parent = folder
		clone.Root.PS2pinkrockAMBLOOP:Play()
		clone:PivotTo(crystalAt)

		if v6.Spawns ~= nil then
			Regions.Spawns[k] = {}

			for _, spawn in v6.Spawns do
				table.insert(Regions.Spawns[k], spawn)
			end
		end

		local proximityPrompt = Instance.new("ProximityPrompt")
		proximityPrompt.ActionText = "Set Spawn"
		proximityPrompt.KeyboardKeyCode = Enum.KeyCode.T
		proximityPrompt.ObjectText = k
		proximityPrompt.RequiresLineOfSight = false
		proximityPrompt.Name = k
		proximityPrompt:AddTag("SpawnCrystalProximityPrompt")
		proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
		proximityPrompt.Parent = clone.Root.At
		proximityPrompt.HoldDuration = 1
		proximityPrompt.MaxActivationDistance = 10
		proximityPrompt.MaxIndicatorDistance = proximityPrompt.MaxActivationDistance + gameSettings.indicatorAdditionalDistance
	end

	if data.Situations ~= nil then
		for _, situation in data.Situations do
			table.insert(Regions.Situations, situation)
		end
	end

	for _, npc in ipairs(data.Npcs) do
		if (npc.Type == Menum.npcType.Stationary or npc.Type == Menum.npcType.Idle) and gameSettings.DisableNpcSpawns ~= true then
			local v6 = npc.Type == Menum.npcType.Idle
			local clone = (npc.Appearance or game.StarterPlayer.StarterCharacter):Clone()

			if clone.Humanoid.ClassName == "Humanoid" then
				if v6 then
					if clone.Humanoid:FindFirstChild("Animator") == nil then
						local animator = Instance.new("Animator", clone.Humanoid)
						animator.Name = "Animator"
					end

					clone.Humanoid.WalkSpeed = npc.WalkSpeed or 8
				else
					clone.Humanoid:Destroy()
					local animationController = Instance.new("AnimationController")
					animationController.Name = "Humanoid"
					local animator_2 = Instance.new("Animator", animationController)
					animator_2.Name = "Animator"
					animationController.Parent = clone
				end
			end

			clone.HumanoidRootPart.Anchored = not v6
			clone:RemoveTag("Humanoids")
			clone:RemoveTag("Players")
			clone.Parent = folder.StationaryNpcs
			clone:SetAttribute("Marker", npc.Marker)
			clone:SetAttribute("Icon", npc.Icon)

			if npc.ModelAttributes ~= nil then
				for k, modelAttribute in npc.ModelAttributes do
					clone:SetAttribute(k, modelAttribute)
				end
			end

			if npc.NameTag ~= false then
				local billboardGui = Instance.new("BillboardGui", clone.HumanoidRootPart)
				billboardGui.Size = UDim2.new(3, 0, 0.6, 0)
				billboardGui.AlwaysOnTop = false
				billboardGui.LightInfluence = 0
				billboardGui.MaxDistance = 250
				billboardGui.StudsOffset = createVector(0, 2.8, 0)
				local textLabel = Instance.new("TextLabel")
				textLabel.Parent = billboardGui
				textLabel.Size = UDim2.new(1, 0, 1, 0)
				textLabel.TextScaled = true
				textLabel.BackgroundTransparency = 1
				textLabel.Font = Enum.Font.SourceSansSemibold
				textLabel.Text = npc.Name
				textLabel.TextColor3 = Color3.new(1, 1, 1)
				local uIStroke = Instance.new("UIStroke")
				uIStroke.Thickness = 2
				uIStroke.Transparency = 0.55
				uIStroke.Parent = textLabel

				if npc.Requirements ~= nil then
					billboardGui.Size = UDim2.new(3, 0, 1.05, 0)
					billboardGui.StudsOffset = createVector(0, 3.025, 0)
					textLabel.Size = UDim2.new(1, 0, 0.5, 0)
					textLabel.Position = UDim2.new(0, 0, 0.5, 0)
					local textLabel2 = Instance.new("TextLabel")
					textLabel2.Name = "Requirement"
					textLabel2.Size = UDim2.new(1, 0, 0.5, 0)
					textLabel2.Position = UDim2.new(0, 0, 0, 0)
					textLabel2.TextScaled = true
					textLabel2.BackgroundTransparency = 1
					textLabel2.Font = Enum.Font.SourceSansSemibold
					textLabel2.TextColor3 = Color3.new(1, 0, 0)
					local uIStroke2 = Instance.new("UIStroke")
					uIStroke2.Thickness = 2
					local uIGradient = Instance.new("UIGradient", textLabel2)
					uIGradient.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 0.75)
					})
					uIGradient.Parent = uIStroke2
					uIGradient.Rotation = 90
					uIStroke2.Parent = textLabel2
					textLabel2.Text = ItemRequirements.Describe(npc.Requirements)
					textLabel2:SetAttribute("Npc", npc.Name)
					textLabel2:AddTag("RequirementGate")
					textLabel2.Parent = billboardGui
				end
			end

			if npc.Dialogue ~= false then
				local proximityPrompt = Instance.new("ProximityPrompt")
				proximityPrompt.ActionText = "Chat"
				proximityPrompt.KeyboardKeyCode = Enum.KeyCode.T
				proximityPrompt.ObjectText = npc.Name
				proximityPrompt.RequiresLineOfSight = false
				proximityPrompt.Name = npc.Dialogue or npc.Name
				proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
				proximityPrompt:AddTag("Dialogue")
				proximityPrompt.Parent = clone.HumanoidRootPart
				proximityPrompt.MaxActivationDistance = 10
				proximityPrompt.MaxIndicatorDistance = proximityPrompt.MaxActivationDistance + gameSettings.indicatorAdditionalDistance

				if npc.Icon ~= nil then
					proximityPrompt:SetAttribute("Icon", npc.Icon)
				end

				if npc.Requirements ~= nil then
					proximityPrompt:SetAttribute("Npc", npc.Name)
					proximityPrompt:AddTag("RequirementGate")
				end
			end

			local v7 = nil
			local spawns = npc.Spawns
			local v9 = npc

			local function PlaceAtRandomSpawn(p2: number?)
				if v6 and v9.Spawns.Multiple == true then
					spawns = v9.Spawns[math.random(1, #v9.Spawns)]

					if v7 ~= nil then
						v7.SetRoute(clone, spawns)
					end
				end

				local spawn = spawns[p2 or math.random(1, #spawns)]
				local v11 = typeof(spawn) == "CFrame" and spawn or CFrame.new(spawn) * CFrame.Angles(
					0,
					math.random(-50, 50) / 50 * 3.141592653589793,
					0
				)
				local raycastResult = workspace:Raycast(
					v11.Position + createVector(0, 3, 0),
					createVector(0, -15, 0),
					raycastParams
				)

				if raycastResult and raycastResult.Instance then
					v11 = CFrame.new(raycastResult.Position) * v11.Rotation
				end

				clone:SetPrimaryPartCFrame(v11)
				local v12 = v11.Position.Y - (clone.RightFoot.Position.Y - clone.RightFoot.Size.Y / 2)
				local v13 = v11 * CFrame.new(0, v12, 0)

				if v9.SpawnOffset ~= nil then
					v13 *= v9.SpawnOffset
				end

				clone:SetPrimaryPartCFrame(v13)
				clone:SetAttribute("Top", clone.Head.Position + createVector(0, 1, 0))
			end

			PlaceAtRandomSpawn()
			clone.Name = npc.Name
			local clone2 = game.ReplicatedStorage.Assets.Animations.DefaultNpcAnims:Clone()
			local clone3 = game.ReplicatedStorage.Assets.ClientAnimatorServer:Clone()
			clone2.Parent = clone3
			clone2.Name = "Anims"
			clone3.Parent = clone

			if npc.Animations ~= nil then
				for childName, animation in npc.Animations do
					local child = clone2:FindFirstChild(childName)

					if child == nil then
						continue
					end

					if typeof(animation) == "table" then
						animation = animation[1] or animation
					end

					child.AnimationId = animation
					child:SetAttribute("Custom", true)
				end
			end

			if npc.CustomIdle then
				local child = game.ReplicatedStorage.Assets.Animations.Default_Core.Default:FindFirstChild(npc.CustomIdle)

				if child == nil then
					clone2.idle.AnimationId = npc.CustomIdle
				else
					clone2.idle:Destroy()
					local clone4 = child:Clone()
					clone4.Name = "idle"
					clone4.Parent = clone2
				end

				clone2.idle:SetAttribute("Custom", true)
			end

			if v6 then
				clone:SetAttribute("IdleNpc", true)
				local parent = clone
				pcall(function()
					parent.HumanoidRootPart:SetNetworkOwner(nil)
				end)
				local IdleNpcs = require(game.ServerStorage.SAM.Services.IdleNpcs)
				v7 = IdleNpcs
				v7.Register(clone, npc, spawns)
			end

			local shop = npc.Shop

			if shop ~= nil then
				local folder4 = Instance.new("Folder", clone)
				folder4.Name = npc.Name .. "'s Shop"

				for k, v11 in shop do
					Shop.RegisterItem(k, {
						Price = v11.Price,
						Type = v11.Type or Menum.ShopItemType.IngameItem,
						Seller = { npc.Name, table.unpack(v11.AlsoSoldBy or {}) },
						Grant = v11.Grant,
						Icon = v11.Icon,
						NoSave = v11.NoSave,
						RequiresQuestDone = npc.RequiresQuestDone,
						RequiresSide = v11.RequiresSide,
						Requirements = npc.Requirements
					})
					local model = v11.Model

					if model == nil then
						continue
					end

					local clone4 = model:Clone()
					clone4.Parent = folder4
					local proximityPrompt = Instance.new("ProximityPrompt")
					proximityPrompt.ActionText = "Purchase"
					proximityPrompt.KeyboardKeyCode = Enum.KeyCode.T
					proximityPrompt.ObjectText = k
					proximityPrompt.RequiresLineOfSight = false
					proximityPrompt.Name = k
					proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
					proximityPrompt:AddTag("Dialogue")
					proximityPrompt:SetAttribute("IndicatorStyle", "Blue")
					proximityPrompt:SetAttribute("DialogueName", "ShopDialogue")
					proximityPrompt:SetAttribute("Name", npc.Name)
					proximityPrompt.Parent = clone4.PromptPart
					proximityPrompt.MaxActivationDistance = 10
					proximityPrompt.MaxIndicatorDistance = proximityPrompt.MaxActivationDistance + gameSettings.indicatorAdditionalDistance

					if npc.Icon ~= nil then
						proximityPrompt:SetAttribute("Icon", npc.Icon)
					end

					if v11.SuccessDialogue ~= nil then
						proximityPrompt:SetAttribute("SuccessDialogue", v11.SuccessDialogue)
					end

					if v11.FailDialogue ~= nil then
						proximityPrompt:SetAttribute("FailDialogue", v11.FailDialogue)
					end

					if v11.RequiresSide ~= nil then
						proximityPrompt:SetAttribute("Side", v11.RequiresSide)
						proximityPrompt:AddTag("RequirementGate")
					end

					if npc.RequiresQuestDone == nil then
						continue
					end

					proximityPrompt:AddTag("QuestGate")
					proximityPrompt:SetAttribute("RequiresQuestDone", npc.RequiresQuestDone)
				end
			end

			if npc.RotatingShop ~= nil then
				npc.RotatingShop.Icon = npc.RotatingShop.Icon or npc.Icon
				npc.RotatingShop.RequiresQuestDone = npc.RotatingShop.RequiresQuestDone or npc.RequiresQuestDone
				local RotatingShops = require(game.ServerStorage.SAM.Services.RotatingShops)
				RotatingShops.Register(npc.RotatingShop, folder)
			end

			if npc.TimedVendor ~= nil then
				if npc.NightOnly == true then
					warn((`Regions: {npc.Name} sets both NightOnly and TimedVendor — both own the rig's Parent and will fight over it; keep one`))
				end

				npc.TimedVendor.RequiresQuestDone = npc.TimedVendor.RequiresQuestDone or npc.RequiresQuestDone
				local TimedVendors = require(game.ServerStorage.SAM.Services.TimedVendors)
				TimedVendors.Register(npc.TimedVendor, clone, #npc.Spawns, PlaceAtRandomSpawn, Regions.Situations)
			end

			if npc.NightOnly == true and DayAndNightHandler.IsEnabled() then
				local parent = clone.Parent
				local v11 = npc.DespawnAtDaytime == false
				local hasTag = clone:HasTag("HiddenNpc")

				if not DayAndNightHandler.IsNight() then
					clone.Parent = nil
				end

				if not v11 or clone.Parent == nil then
					local phaseChangedConnection = nil
					local v12 = v6
					local PlaceAtRandomSpawn2 = PlaceAtRandomSpawn
					local parent2 = clone
					local parent3 = parent
					local v15 = hasTag
					local v16 = v11
					phaseChangedConnection = DayAndNightHandler.PhaseChanged:Connect(function(p2)
						if p2 then
							if v12 then
								PlaceAtRandomSpawn2()
							end

							parent2.Parent = parent3

							if not v15 then
								local humanoidRootPart = parent2:FindFirstChild("HumanoidRootPart")
								EffectsEvent.ToAllInRange(
									humanoidRootPart or parent2,
									"Appear_Effect",
									humanoidRootPart ~= nil and humanoidRootPart.CFrame or parent2:GetPivot(),
									humanoidRootPart
								)
							end

							if v16 then
								phaseChangedConnection:Disconnect()
							end
						elseif not v16 then
							local pivot = parent2:GetPivot()
							parent2.Parent = nil

							if not v15 then
								EffectsEvent.ToAllInRange(pivot, "DeathEffect", pivot)
							end
						end
					end)
				end
			end

			if npc.TrackedBy ~= nil then
				local SpawnTrackers = require(game.ServerStorage.SAM.Services.SpawnTrackers)
				SpawnTrackers.Watch(npc.TrackedBy, npc.Name, npc.Icon, clone)
			end
		end

		if npc.Type == Menum.npcType.Active then
			for _ = 1, npc.Quantity or 1 do
				local sendOver = npc.SendOver or {}
				local clone = game.ServerStorage.SAM.NpcFile:Clone()
				clone.Name = npc.Name
				local bindableFunction = Instance.new("BindableFunction")
				bindableFunction.Name = "GetDataBindable"
				bindableFunction.Parent = clone

				function bindableFunction.OnInvoke()
					bindableFunction.OnInvoke = nil
					return sendOver
				end

				clone.Parent = (npc.ParentToDebree and folder or folder3).ActiveNpcs
			end
		end

		if npc.WorldEvent == nil then
			continue
		end

		local v6 = WorldEvents.Get(npc.WorldEvent.Name)

		if v6 == nil then
			warn((`Regions: WorldEvent "{npc.WorldEvent.Name}" not found in this place's WorldEvents or SAM's`))
		else
			v6.Register(npc)
		end
	end
end

for k, region in pairs(Regions.Regions) do
	PrepareRegion(region, k)
end

return Regions