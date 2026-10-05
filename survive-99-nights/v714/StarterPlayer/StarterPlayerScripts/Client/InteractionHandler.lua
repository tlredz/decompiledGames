local createVector = vector.create
local InteractionHandler = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local mouse = localPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local random = Random.new()
local v = false
local v2 = 0
local v3 = { Enum.KeyCode.E, Enum.KeyCode.ButtonX }
local _ = { Enum.KeyCode.E, Enum.KeyCode.ButtonX }
local interactionHighlight = workspace.Highlights.InteractionHighlight
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil
local v8 = "Mouse"
InteractionHandler.Interactions = {}
local v9 = 0
InteractionHandler.FlowerHover = nil
InteractionHandler.HasOpenedChest = false
local v10 = {
	Item = true,
	Tool = true,
	AnimalTrap = true,
	Armour = true,
	Currency = true,
	DeerAntler = true,
	TNT = true
}

function InteractionHandler.Interactions.HardModeVote(p)
	Client.ResearchOutpostClient.PullLever(p)
end

function InteractionHandler.Interactions.SantaSack(_)
	Client.SantaSackShopClient.OpenShop()
end

function InteractionHandler.Interactions.AlienScanner(p)
	Client.AlienScannerClient.OpenScanner(p)
end

function InteractionHandler.Interactions.OpenAlienTrader(p)
	Client.AlienTraderClient.OpenShop(p)
end

function InteractionHandler.Interactions.HelpElf(p)
	Client.HelpElfClient.AttemptHelpElf(p)
end

function InteractionHandler.Interactions.ThanksgivingGlass(p)
	Client.ThanksgivingDishClient.RefillGlass(p)
end

function InteractionHandler.Interactions.BerryJuice(instance)
	if instance.PrimaryPart and instance.PrimaryPart:FindFirstChild("ProximityAttachment") then
		instance:Destroy()
	end

	Client.Events.RequestPitcher:FireServer()
end

function InteractionHandler.Interactions.ThanksgivingPlaceDish(p)
	Client.ThanksgivingDishClient.AttemptPlaceDish(p)
end

function InteractionHandler.Interactions.CaveDetonator(p)
	Client.CaveInstanceClient.TriggerDetonator(p)
end

function InteractionHandler.Interactions.SelectBlessing(p)
	local parent = p.Parent
	task.spawn(function()
		Client.BlessingsClient.ViewStatues(parent)
	end)
end

function InteractionHandler.Interactions.CaveTeleport(instance)
	local destination = instance:GetAttribute("Destination")
	Client.CaveInstanceClient.TeleportTo(destination)
end

function InteractionHandler.Interactions.ResetShootingGallery(p)
	local parent = p.Parent.Parent
	Client.ShootingGalleryClient.ResetGallery(parent)
end

function InteractionHandler.Interactions.NightPlant(_)
	Client.Events.SetPopUpMessage:Fire("You can only pick this at night", "night")
end

function InteractionHandler.Interactions.HalloweenDoor(instance)
	task.spawn(function()
		if instance:FindFirstChild("Main") then
		end
	end)
	Client.TrickOrTreatClient.KnockOnDoor(instance)
end

function InteractionHandler.Interactions.HalloweenCandy(p)
	Client.CandyClient.TakeClient(p)
end

function InteractionHandler.Interactions.ChristmasCandyCane(p)
	Client.CandyCaneClient.TakeClient(p)
end

function InteractionHandler.Interactions.WriteableSign(p)
	Client.StructureInterfaceClient.OpenSignGui(p)
end

function InteractionHandler.Interactions.ExitFrogCave(_)
	Client.FrogWhirlpoolClient.ExitFrogCave()
end

function InteractionHandler.Interactions.ToolUpgradeBench(p)
	local currentlyEquipped = Client.InventoryHandler.GetCurrentlyEquipped()

	if currentlyEquipped == nil then
		Client.PopUpUI.AddPopUp("you are not holding a tool you can upgrade", "warning")
	elseif currentlyEquipped:GetAttribute("ToolName") == "Fishing Rod" then
		Client.FishingUpgradeClient.RequestUpgradeRod(p)
	elseif currentlyEquipped:GetAttribute("ToolName") == "Taming Flute" then
		Client.FluteUpgradeClient.RequestUpgradeFlute(p)
	else
		Client.PopUpUI.AddPopUp("you are not holding a tool you can upgrade", "warning")
	end
end

function InteractionHandler.Interactions.FishingRodUpgrade(p)
	Client.FishingUpgradeClient.RequestUpgradeRod(p)
end

function InteractionHandler.Interactions.TamingFluteUpgrade(p)
	print("flute")
	Client.FluteUpgradeClient.RequestUpgradeFlute(p)
end

function InteractionHandler.Interactions.NightSkipMachine(p)
	Client.NightSkipMachineClient.OpenActivationMenu(p)
end

function InteractionHandler.Interactions.RespawnBeacon(p)
	Client.RespawnBeaconClient.OpenRespawnBeaconMenu(p)
end

function InteractionHandler.Interactions.WeatherMachine(p)
	Client.WeatherMachineClient.OpenWeatherMachineMenu(p)
end

function InteractionHandler.Interactions.Recycler(p)
	Client.RecyclerClient.OpenRecyclerMenu(p)
end

function InteractionHandler.Interactions.OpenRadar(p)
	Client.RadarClient.OpenRadarMenu(p)
end

function InteractionHandler.Interactions.ToolBench(p)
	Client.Interface.WorkshopRecipes.Visible = not Client.Interface.WorkshopRecipes.Visible

	if Client.Interface.WorkshopRecipes.Visible then
		Client.ToolWorkshopClient.OpenWindow(p.Parent.Parent)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
	else
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
		Client.Sound.Play("CloseButton")
	end
end

function InteractionHandler.Interactions.OpenFurnitureShop(_)
	Client.CompassClient.ShopFound("FurnitureTrader")
	Client.Interface.Furniture.Visible = not Client.Interface.Furniture.Visible

	if Client.Interface.Furniture.Visible then
		GuiService.TouchControlsEnabled = false
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
	else
		GuiService.TouchControlsEnabled = true
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
		Client.Sound.Play("CloseButton")
	end
end

function InteractionHandler.Interactions.QuickExit(instance)
	local exitLocation = instance.PrimaryPart:FindFirstChild("ExitLocation")

	if exitLocation then
		local v11 = v6
		local v12 = v11 and localPlayer.Character:GetPivot():ToObjectSpace(v11:GetPivot())
		local v13 = random:NextNumber() - 0.5
		local v14 = exitLocation.WorldCFrame + Vector3.new(v13 * 5, 0, 0)
		localPlayer.Character:PivotTo(v14)

		if v11 then
			v11:PivotTo(v14 * v12)
		end
	end
end

function InteractionHandler.Interactions.CanBeBagged(instance)
	local currentlyEquippedClass = Client.InventoryHandler.GetCurrentlyEquippedClass()

	if currentlyEquippedClass and currentlyEquippedClass.Model and currentlyEquippedClass.Model:HasTag("ItemBag") then
		currentlyEquippedClass.Tool:BagItem(instance)
		return
	end

	local v11 = nil

	for _, child in pairs(localPlayer.Inventory:GetChildren()) do
		if not child:HasTag("ItemBag") then
			continue
		end

		v11 = child
		break
	end

	if v11 then
		local kidCrying = instance:FindFirstChild("Head") and instance.Head:FindFirstChild("KidCrying")

		if Client.Events.RequestBagStoreItem:InvokeServer(v11, instance) and kidCrying then
			Client.Sound.Play("KidInBag", {
				Replicate = true,
				ReplicationProperties = {
					Position = instance.Head.Position
				}
			})
		end
	end
end

function InteractionHandler.Interactions.Revive(p, p2)
	if p2 == "Click" or p2 == "Touch" then
		StartDragging(p)
		return
	end

	print("Attempt revive")

	if localPlayer.Inventory:FindFirstChild("Bandage") or localPlayer.Inventory:FindFirstChild("MedKit") then
		Client.Events.RequestRevivePlayer:FireServer(p)
		return
	end

	Client.Events.RequestPayToRevivePlayer:FireServer(p)
	Client.Events.SetPopUpMessage:Fire("You need bandages or a medkit to revive", "warning")
end

function InteractionHandler.Interactions.BoostpadCharge(instance)
	if instance:GetAttribute("IsCharging") then
		Client.Events.ChargeBoostpad:FireServer(instance)
	else
		Client.Events.UseBoostpad:FireServer(instance)
	end
end

function InteractionHandler.Interactions.TeleporterCharge(instance)
	if instance:GetAttribute("IsCharging") then
		Client.Events.ChargeTeleporter:FireServer(instance)
	elseif localPlayer.Character and localPlayer.Character:HasTag("CarryingEasterBunnyEgg") then
		Client.PopUpUI.AddPopUp("you can't teleport right now", "easterbunny")
	else
		Client.Events.UseTeleporter:FireServer(instance)
	end
end

function InteractionHandler.Interactions.CraftingBench(_)
	Client.CraftingTableClient.OpenCraftingBench()
end

function InteractionHandler.Interactions.Fairy(p)
	Client.FairyClient.ToggleShop(p)
end

function InteractionHandler.Interactions.IngredientsBook(_)
	Client.CauldronClient.ToggleBook()
end

function InteractionHandler.Interactions.ToyShelf()
	Client.ToyShelfClient.ToggleToyShelf()
end

function InteractionHandler.Interactions.NoticeBoard(_)
	Client.MissingPosterClient.ZoomToBoard()
end

function InteractionHandler.Interactions.AmmoCrate(p)
	Client.AmmoCrateClient.OpenBox(p)
end

function InteractionHandler.Interactions.LeafPile(p)
	Client.LeafPileClient.PileDug(p)
end

function InteractionHandler.RegisterInteraction(p, p2)
	InteractionHandler.Interactions[p] = p2
end

function DoGamblerParticles(instance, p)
	local clone = ReplicatedStorage.Assets.Particles.GamblerChestParticles:Clone()

	if instance and instance:FindFirstChild("Main") then
		clone.Parent = workspace.Particles
		clone:PivotTo(instance.Main:GetPivot())
	end

	if p == "Bad" then
		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant.Name == "Roll6" then
				descendant:Destroy()
			end
		end
	else
		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant.Name == "Roll1" then
				descendant:Destroy()
			end
		end
	end

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v11 = emitter
		task.spawn(function()
			task.wait(v11:GetAttribute("EmitDelay") or 0)

			if v11:GetAttribute("EmitDuration") then
				v11.Enabled = true
				task.spawn(function()
					wait(v11:GetAttribute("EmitDuration"))
					v11.Enabled = false
				end)
			end

			if v11:GetAttribute("EmitCount") then
				v11:Emit(v11:GetAttribute("EmitCount"))
			end
		end)
	end

	task.spawn(function()
		wait(3.5)

		if clone then
			clone:Destroy()
		end
	end)
end

Client.Events.GamblerParticles:Connect(DoGamblerParticles)

function ChestOpened(instance, p)
	if instance:GetAttribute("Locked") then
		if instance:GetAttribute("LockedMessage") then
			Client.Events.SetPopUpMessage:Fire(instance:GetAttribute("LockedMessage"), "warning")
		end
	else
		if instance:GetAttribute("LocalOpened") then
			return
		end

		instance:SetAttribute("LocalOpened", true)
		instance:SetAttribute(math.abs(localPlayer.UserId) .. "Opened", true)
		instance.PrimaryPart.ProximityAttachment:Destroy()
		instance:RemoveTag("Interaction")

		if instance:GetAttribute("ThanksgivingChest") then
			Client.ThanksgivingChestClient.OpenChest(instance, p)
			Client.Sound.Play("LidReveal")
		else
			if instance:GetAttribute("ChristmasPresent") then
				Client.ChristmasPresentClient.OpenChest(instance, p)
				return
			end

			if instance:GetAttribute("RandomBox") then
				Client.GamblerChestClient.OpenChest(instance, p)
				return
			end

			if instance:HasTag("HardModeCrate") then
				Client.ResearchOutpostClient.OpenCrate(instance, p)
				return
			end

			if not p then
				Client.Sound.Play("ChestToggle")
				Client.Events.RequestOpenItemChest:FireServer(instance)
				InteractionHandler.HasOpenedChest = true

				if Client.TutorialClient.ChestTutorialActive then
					Client.TutorialClient.ChestTutorialActive = false

					for _, tutorialCircle in pairs(Client.MapDrawClient.TutorialCircles) do
						tutorialCircle.Visible = false
					end
				end
			end

			local pivot = instance.ChestLid:GetPivot()
			instance.ChestLid:PivotTo(pivot * CFrame.Angles(-1.7453292519943295, 0, 0))

			if instance:FindFirstChild("Highlight") then
				instance.Highlight:Destroy()
			end

			if not p and instance:FindFirstChild("Platform") and instance.Platform:FindFirstChild("BG") then
				instance.Platform.BG:Emit(instance.Platform.BG:GetAttribute("EmitCount"))
				instance.Platform.Front:Emit(instance.Platform.Front:GetAttribute("EmitCount"))

				if localPlayer.Character and localPlayer.Character:FindFirstChild("Head") then
					Client.Sound.Play("Chest6Open", {
						Volume = 0.85,
						Replicate = true,
						ReplicationProperties = {
							Instance = localPlayer.Character.Head,
							Volume = 0.35
						}
					})
				end
			end
		end
	end
end

function InteractionHandler.Interactions.ItemChest(p)
	ChestOpened(p)
end

function InteractionHandler.Interactions.AnimalTrap(p, p2)
	if p2 == "Click" or p2 == "Touch" then
		StartDragging(p)
	else
		Client.Events.RequestSetTrap:FireServer(p)
	end
end

function InteractionHandler.Interactions.BunnyTrap(p, p2)
	if p2 == "Click" or p2 == "Touch" then
		StartDragging(p)
	else
		Client.Events.RequestSetBunnyTrap:FireServer(p)
	end
end

function InteractionHandler.Interactions.TNT(p, p2)
	if p2 == "Click" or p2 == "Touch" then
		StartDragging(p)
	else
		task.spawn(function()
			Client.ExplosivesClient.LightTNT(p)
		end)
	end
end

function InteractionHandler.Interactions.Item(p)
	StartDragging(p)
end

function InteractionHandler.Interactions.Armour(p)
	StartDragging(p)
end

function InteractionHandler.Interactions.Currency(p)
	StartDragging(p)
end

function InteractionHandler.Interactions.Tool(instance)
	if instance:GetAttribute("AutoEquip") then
		AttemptHotbarItem(instance)
	else
		StartDragging(instance)
	end
end

function InteractionHandler.Interactions.Door(instance)
	if instance:GetAttribute("ChristmasWorkshopLocked") then
		Client.PopUpUI.AddPopUp("You must make the Christmas biome safe before you can enter", "warning")
	elseif instance:GetAttribute("ChristmasWorkshopEndDoor") then
		Client.PopUpUI.AddPopUp("It's not safe to open this yet", "warning")
	else
		Client.DoorModule.ToggleDoor(instance)
	end
end

function InteractionHandler.CheckCollectCurrency(instance, _)
	if instance:GetAttribute("Destroyed") then
		return
	end

	if instance:GetAttribute("QueuedToTake") then
		return true
	end

	if instance:HasTag("Coins") then
		instance:SetAttribute("QueuedToTake", true)
		task.spawn(function()
			Client.FlowerAndCoinsClient.PickupCoins(instance)
		end)
	elseif instance:HasTag("Flower") then
		instance:SetAttribute("QueuedToTake", true)
		task.spawn(function()
			Client.FlowerAndCoinsClient.PullFlower(instance)
			instance:Destroy()
			Client.Events.RequestPickFlower:InvokeServer(instance)
		end)
	elseif instance:GetAttribute("Diamonds") then
		instance:SetAttribute("QueuedToTake", true)
		task.spawn(function()
			Client.DiamondsClient.DiamondEffect(instance)
		end)
		Client.Events.RequestTakeDiamonds:FireServer(instance)
		instance:Destroy()
	elseif instance:GetAttribute("Interaction") == "HalloweenCandy" then
		instance:SetAttribute("QueuedToTake", true)
		Client.CandyClient.TakeClient(instance)
	else
		if instance:GetAttribute("Interaction") ~= "ChristmasCandyCane" then
			return
		end

		instance:SetAttribute("QueuedToTake", true)
		Client.CandyCaneClient.TakeClient(instance)
	end

	return true
end

function PreOpenedChestAdded(instance)
	if (instance:GetAttribute(localPlayer.UserId .. "Opened") or instance:GetAttribute("ChestEmpty") and not instance:GetAttribute("ChristmasPresent")) and not instance:GetAttribute("LocalOpened") then
		ChestOpened(instance, true)
	end
end

task.spawn(function()
	Client.Utility.ForAllTagged("PreOpenedChest", PreOpenedChestAdded)
end)

function InteractionHandler.GetDraggingItem()
	return v6
end

function InteractionHandler.GetFocusItem(p, p2)
	if not Client.PlayerHandler.Alive then
		return
	end

	if v6 then
		return v6, "Dragging"
	end

	local v11, v12 = CheckMouseTarget(p2)

	if v11 then
		return v11, v12
	end

	if v7 and not p then
		return v7, "LastTapped"
	end
end

function IsToolDowngrade(instance)
	local v11 = instance:GetAttribute("Interaction") == "Armour"
	local armourSlot = v11 and instance:GetAttribute("ArmourSlot") or instance:GetAttribute("LockedHotbarSlot")

	if armourSlot then
		if v11 then
			for _, child in pairs(localPlayer.Armour:GetChildren()) do
				if child:GetAttribute("ArmourSlot") == armourSlot and Client.Utility.IsToolDowngrade(child, instance) then
					return true
				end
			end
		else
			for _, child in pairs(localPlayer.Inventory:GetChildren()) do
				if child:GetAttribute("LockedHotbarSlot") == armourSlot and Client.Utility.IsToolDowngrade(
					child,
					instance
				) then
					return true
				end
			end
		end
	elseif instance:GetAttribute("UniqueToolType") then
		local uniqueToolType = instance:GetAttribute("UniqueToolType")

		for _, child in pairs(localPlayer.Inventory:GetChildren()) do
			if child:GetAttribute("UniqueToolType") == uniqueToolType and Client.Utility.IsToolDowngrade(
				child,
				instance
			) then
				return true
			end
		end
	end
end

function IsToolUnique(instance)
	local child = localPlayer.Inventory:FindFirstChild(instance.Name)

	if child and (child:GetAttribute("OnePerPlayer") or instance:GetAttribute("OnePerPlayer")) or child and (child:GetAttribute("LockedHotbarSlot") or instance:GetAttribute("LockedHotbarSlot")) then
		return true
	end

	local toolName = instance:GetAttribute("ToolName")

	if toolName then
		for _, child2 in pairs(localPlayer.Inventory:GetChildren()) do
			if child2:GetAttribute("ToolName") == toolName and (child2:GetAttribute("OneToolPerPlayer") or instance:GetAttribute("OneToolPerPlayer")) then
				return true
			end
		end
	end
end

function AttemptHotbarItem(instance)
	if not Client.PlayerHandler.Alive then
		return
	end

	if localPlayer:GetAttribute("Class") == "Brawler" and (instance:GetAttribute("ToolName") == "Firearm" or instance:GetAttribute("ToolName") == "ThrownWeapon") and instance.Name ~= "Air Rifle" then
		Client.Events.SetPopUpMessage:Fire("Brawler class can't use ranged weapons", "warning")
		return
	end

	if localPlayer:GetAttribute("Class") == "Woodsman" and (instance:GetAttribute("ToolName") == "GenericAxe" or instance:GetAttribute("ToolName") == "Chainsaw") and instance.Name ~= "Woodsman's Axe" then
		Client.Events.SetPopUpMessage:Fire("Woodsman class can only use their own axe", "warning")
		return
	end

	if instance:GetAttribute("Interaction") ~= "Tool" or instance:GetAttribute("Owner") and instance:GetAttribute("Owner") ~= localPlayer.UserId then
		return
	end

	if IsToolDowngrade(instance) then
		Client.Events.SetPopUpMessage:Fire("You already have a tool better than this", "warning")
		return
	end

	if IsToolUnique(instance) then
		Client.Events.SetPopUpMessage:Fire("You already have this tool", "warning")
		return
	end

	if instance == v6 then
		Client.Events.StopDraggingItem:Fire()
	end

	if instance:GetAttribute("FloatingPotion") then
		Client.CauldronClient.TakePotion(instance)
	end

	if InteractionHandler.CheckCollectCurrency(instance, "Hotbar") then
		return
	end

	local parent = instance.Parent
	instance.Parent = game.ReplicatedStorage.TempStorage
	task.spawn(function()
		local v11 = Client.Events.RequestHotbarItem:InvokeServer(instance)

		if v11 and v11.Success then
			Client.Sound.Play("BagGet", {
				Duplicate = true,
				PitchShift = 1
			})

			if instance.Name == "Basketball" or instance:GetAttribute("AutoEquip") then
				task.delay(0.1, function()
					Client.InventoryHandler.RequestEquipItem(instance)
				end)
			end
		elseif instance.Parent ~= nil then
			instance.Parent = parent
		end
	end)
	return true
end

InteractionHandler.AttemptHotbarItem = AttemptHotbarItem

function AttemptEquipArmour(instance)
	if not Client.PlayerHandler.Alive or instance:GetAttribute("Interaction") ~= "Armour" or instance:GetAttribute("Owner") and instance:GetAttribute("Owner") ~= localPlayer.UserId then
		return
	end

	if IsToolDowngrade(instance) then
		Client.Events.SetPopUpMessage:Fire("You already have armour better than this", "warning")
		return
	end

	if instance == v6 then
		Client.Events.StopDraggingItem:Fire()
	end

	local parent = instance.Parent
	instance.Parent = localPlayer.Armour
	task.spawn(function()
		local v11 = Client.Events.RequestEquipArmour:InvokeServer(instance)

		if v11 and v11.Success then
			Client.Sound.Play("ArmorWear", {
				Volume = 0.5,
				Replicate = true,
				ReplicationProperties = {
					Instance = localPlayer.Character.Head,
					Volume = 0.5
				}
			})
		else
			instance.Parent = parent
		end
	end)
	return true
end

InteractionHandler.AttemptEquipArmour = AttemptEquipArmour

function HealEffects(p)
	if localPlayer.Character and localPlayer.Character.PrimaryPart then
		if p and (p == "Bandage" or p == "MedKit") then
			print("ITEM NAME")
			Client.Sound.Play("HealBandage", {
				Volume = 0.4,
				Replicate = true,
				Duplicate = true,
				ReplicationProperties = {
					Instance = localPlayer.Character.Head,
					Volume = 0.45
				}
			})
		end

		local clone = Client.Interface.HealGlow:Clone()
		clone.Parent = Client.Interface.HealGlow.Parent
		clone.Visible = true
		local clone2 = ReplicatedStorage.Assets.Particles.Heal.HealHearts:Clone()
		clone2.Parent = localPlayer.Character.PrimaryPart
		TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			ImageTransparency = 0.25
		}):Play()
		task.spawn(function()
			wait(0.15)
			clone2:Emit(5)
			wait(0.25)
			TweenService:Create(clone, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				ImageTransparency = 1
			}):Play()
			wait(0.6)
			clone:Destroy()

			if clone2 then
				clone2:Destroy()
			end
		end)
	end
end

Client.Events.HealEffects:Connect(function(p)
	HealEffects(p)
end)

function AttemptConsumeItem(instance)
	if not Client.PlayerHandler.Alive or instance:GetAttribute("Owner") and instance:GetAttribute("Owner") ~= localPlayer.UserId then
		return
	end

	local v11

	if instance.Name == "Fuel Canister" or instance.Name == "Oil Barrel" then
		v11 = localPlayer:GetAttribute("Class") == "Pyromaniac"
	else
		v11 = false
	end

	if v11 and localPlayer:GetAttribute("FlamethrowerFuel") >= 100 then
		Client.Events.SetPopUpMessage:Fire("your fuel is full", "warning")
		return
	end

	if instance:GetAttribute("Interaction") ~= "Item" and instance:GetAttribute("Interaction") ~= "Tool" then
		return
	end

	if localPlayer:GetAttribute("Class") == "Bunny" and instance:GetAttribute("HasMeat") then
		Client.PopUpUI.AddPopUp("Bunny class can't eat meat", "easter")
		return
	end

	if not (instance:GetAttribute("RestoreHunger") or instance:GetAttribute("RestoreHealth") or instance:GetAttribute("RifleAmmo") or instance:GetAttribute("AmmoType") or instance:GetAttribute("RevolverAmmo") or instance:GetAttribute("ShotgunAmmo") or v11) then
		return
	end

	local v14 = instance:GetAttribute("RestoreHunger") and true or false
	local v15 = (instance:GetAttribute("RifleAmmo") or instance:GetAttribute("RevolverAmmo") or instance:GetAttribute("ShotgunAmmo") or instance:GetAttribute("AmmoType")) and true or false
	local parent = instance.Parent
	instance.Parent = game.ReplicatedStorage.TempStorage
	task.spawn(function()
		local v16 = Client.Events.RequestConsumeItem:InvokeServer(instance)

		if not (v16 and v16.Success) then
			instance.Parent = parent
		elseif v14 then
			Client.Sound.Play("Eat", {
				Volume = 0.2,
				Replicate = true,
				Duplicate = true,
				ReplicationProperties = {
					Instance = localPlayer.Character.Head,
					Volume = 0.15
				}
			})
		elseif v15 then
			Client.Sound.Play("BagGet", {
				Duplicate = true
			})
		elseif v11 then
			Client.Sound.Play("FuelGet", {
				Duplicate = true
			})
		end
	end)
	return true
end

InteractionHandler.AttemptConsumeItem = AttemptConsumeItem

function FindGrassBlock(p)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { workspace.Map.Ground, workspace.Map:FindFirstChild("Snow") }
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.IgnoreWater = true
	local raycastResult = workspace:Raycast(p, createVector(0, -55, 0), raycastParams)

	if raycastResult then
		return raycastResult.Position, raycastResult
	end

	return nil
end

function AttemptPlantItem(instance)
	if not Client.PlayerHandler.Alive or instance:GetAttribute("Owner") and instance:GetAttribute("Owner") ~= localPlayer.UserId then
		return
	end

	if instance:GetAttribute("Interaction") ~= "Item" and instance:GetAttribute("Interaction") ~= "Tool" then
		return
	end

	if instance:HasTag("Acorn") then
		Client.TreeRootClient.PlantAcorn(instance)
		return true
	end

	if not instance:HasTag("Plantable") then
		return
	end

	local v11 = FindGrassBlock(instance.PrimaryPart.Position)

	if not v11 then
		return
	end

	local v12 = 40

	if instance.Name == "Giant Sapling" then
		v12 *= 1.3
	end

	if workspace.Map.Campground.MainFire.PrimaryPart and (workspace.Map.Campground.MainFire.PrimaryPart.Position - v11).Magnitude < v12 then
		Client.PopUpUI.AddPopUp("can't plant this close to fire", "warning")
		return
	end

	local parent = instance.Parent
	instance.Parent = game.ReplicatedStorage.TempStorage
	task.spawn(function()
		local v13 = Client.Events.RequestPlantItem:InvokeServer(instance, v11)

		if not (v13 and v13.Success) then
			instance.Parent = parent
		end
	end)
	return true
end

InteractionHandler.AttemptPlantItem = AttemptPlantItem

function AttemptPlantSeeds(instance)
	if not Client.PlayerHandler.Alive or instance:GetAttribute("Owner") and instance:GetAttribute("Owner") ~= localPlayer.UserId then
		return
	end

	if instance:GetAttribute("Interaction") ~= "Item" and instance:GetAttribute("Interaction") ~= "Tool" or not (instance:HasTag("SeedBox") and instance:GetAttribute("SeedType")) then
		return
	end

	local seedType = instance:GetAttribute("SeedType")
	local parent = instance.Parent
	instance.Parent = game.ReplicatedStorage.TempStorage
	Client.PopUpUI.AddPopUp(`planted {string.lower(seedType)} all around the map`, nil, 11)
	Client.CameraCutscenesClient.OpenSeedBox(seedType)
	task.spawn(function()
		local v11 = Client.Events.RequestPlantSeeds:InvokeServer(instance)

		if not (v11 and v11.Success) then
			instance.Parent = parent
		end
	end)
	return true
end

InteractionHandler.AttemptPlantSeeds = AttemptPlantSeeds

function AttemptPickItem(instance)
	if not Client.PlayerHandler.Alive or instance:GetAttribute("Owner") and instance:GetAttribute("Owner") ~= localPlayer.UserId or instance:GetAttribute("Interaction") ~= "Flower" then
		return
	end

	if not instance:HasTag("Flower") then
		return
	end

	Client.FlowerAndCoinsClient.PullFlower(instance)
	local parent = instance.Parent
	instance.Parent = game.ReplicatedStorage.TempStorage
	task.spawn(function()
		local v11 = Client.Events.RequestPickFlower:InvokeServer(instance)

		if not (v11 and v11.Success) then
			instance.Parent = parent
		end
	end)
	return true
end

InteractionHandler.AttemptPickItem = AttemptPickItem

function GetBodyArmour()
	for _, child in pairs(localPlayer.Armour:GetChildren()) do
		if child:GetAttribute("ArmourSlot") == "Torso" then
			return child
		end
	end
end

function AttemptUseGoldTrimKit(instance)
	if not Client.PlayerHandler.Alive or instance:GetAttribute("Owner") and instance:GetAttribute("Owner") ~= localPlayer.UserId or not instance:GetAttribute("GoldTrimKit") then
		return
	end

	local v11 = nil
	local goldTrimKit = instance:GetAttribute("GoldTrimKit")

	if goldTrimKit == "Tool" then
		v11 = Client.InventoryHandler.GetCurrentlyEquipped()

		if not v11 then
			Client.PopUpUI.AddPopUp("You must equip a tool to gold trim", "warning")
			return
		end

		if v11:GetAttribute("GoldTrimmed") then
			Client.PopUpUI.AddPopUp("This tool is already gold trimmed", "warning")
			return
		end

		if not v11:GetAttribute("CanTrim") then
			Client.PopUpUI.AddPopUp("You can't gold trim this tool", "warning")
			return
		end
	elseif goldTrimKit == "Armour" then
		v11 = GetBodyArmour()

		if not v11 then
			Client.PopUpUI.AddPopUp("You aren't wearing any armour to gold trim", "warning")
			return
		end

		if v11:GetAttribute("GoldTrimmed") then
			Client.PopUpUI.AddPopUp("Your armour is already gold trimmed", "warning")
			return
		end

		if not v11:GetAttribute("CanTrim") then
			Client.PopUpUI.AddPopUp("You can't gold trim this armour", "warning")
			return
		end
	end

	local parent = instance.Parent
	instance.Parent = game.ReplicatedStorage.TempStorage
	local clone = nil
	task.spawn(function()
		local v12 = Client.Events.RequestUseGoldTrimKit:InvokeServer(instance, v11)

		if not (v12 and v12.Success) then
			instance.Parent = parent
			return
		end

		if instance.PrimaryPart then
			clone = ReplicatedStorage.Assets.Particles.Main:Clone()
			clone.Parent = instance.PrimaryPart

			for _, child in pairs(clone:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount") or 2)
			end
		end

		task.spawn(function()
			wait(5)

			if clone then
				clone:Destroy()
			end
		end)
	end)
	return true
end

function CheckPrimaryInteraction(_, p)
	if p ~= Enum.UserInputState.Begin then
		return
	end

	local focusItem = InteractionHandler.GetFocusItem()

	if focusItem then
		if InteractionHandler.CheckCollectCurrency(focusItem, "Take") or AttemptHotbarItem(focusItem) or AttemptEquipArmour(focusItem) or AttemptConsumeItem(focusItem) then
			return
		end

		if AttemptUseGoldTrimKit(focusItem) or AttemptPlantItem(focusItem) or AttemptPlantSeeds(focusItem) then
			return
		end
	end
end

InteractionHandler.CheckPrimaryInteraction = CheckPrimaryInteraction
ContextActionService:BindActionAtPriority(
	"CheckPrimaryInteraction",
	CheckPrimaryInteraction,
	false,
	Enum.ContextActionPriority.Medium.Value,
	unpack(v3)
)
ContextActionService:BindActionAtPriority("DraggingBegin", function(_, p)
	if p == Enum.UserInputState.Begin then
		v = true
	else
		v = false
	end

	return Enum.ContextActionResult.Pass
end, false, Enum.ContextActionPriority.High.Value + 10, Enum.UserInputType.MouseButton1)

function InteractionHandler.StopDragging()
	v = false
end

UserInputService.TouchTapInWorld:Connect(function(p, p2)
	if p2 or Client.PingClient.PingActive then
		return
	end

	local viewportPointToRay = workspace.CurrentCamera:ViewportPointToRay(p.X, p.Y)
	local focusItem, v11 = InteractionHandler.GetFocusItem(true, viewportPointToRay)

	if not Client.StructurePlacementClient.PlacementActive and (v11 == "MouseTarget" or v11 == "TapZone") then
		v = true
		local interaction = focusItem:GetAttribute("Interaction")

		if InteractionHandler.Interactions[interaction] then
			v8 = "Touch"
			InteractionHandler.ProcessInteraction(focusItem, interaction, nil, "Touch")
		end
	end

	local currentlyEquipped = Client.InventoryHandler.GetCurrentlyEquipped()

	if v11 ~= "MouseTarget" and v11 ~= "TapZone" then
		if currentlyEquipped == nil or currentlyEquipped.Name ~= "Bandage" and currentlyEquipped.Name ~= "MedKit" and not currentlyEquipped:GetAttribute("Automatic") then
			if not currentlyEquipped or not Client.FirstPersonModule.IsVisible() or currentlyEquipped:GetAttribute("ToolName") ~= "Firearm" then
				Client.InventoryHandler.ActivateTool(viewportPointToRay)
			end
		else
			print("reject tap")
		end
	end

	v7 = focusItem
end)
UserInputService.TouchStarted:Connect(function(_, p)
	if p then
		return
	end

	local currentlyEquipped = Client.InventoryHandler.GetCurrentlyEquipped()

	if currentlyEquipped and currentlyEquipped:GetAttribute("Automatic") then
		Client.InventoryHandler.ActivateTool()
	end
end)
UserInputService.TouchEnded:Connect(function(_, p)
	if p then
		return
	end

	Client.InventoryHandler.DeactivateTool()
end)

function InteractionHandler.FirstInteractParticles(instance)
	local particlePos = instance.PrimaryPart:FindFirstChild("ParticlePos")

	if particlePos then
		local worldCFrame = particlePos.WorldCFrame
		Client.Sound.Play("TwigSnap", {
			Duplicate = true
		})
		local firstParticleName = instance:GetAttribute("FirstParticleName") or "Interact" .. instance.Name
		Client.Utility.SpawnParticles(firstParticleName, worldCFrame)
	end
end

Client.Events.FirstInteractParticles:Connect(function(p)
	InteractionHandler.FirstInteractParticles(p)
end)

function OnFirstInteraction(instance)
	if instance.Name == "Carnival Ticket" then
		Client.Sound.Play("TicketRip", {
			Position = instance:GetPivot().Position,
			Replicate = true
		})
	end

	if instance:HasTag("JungleKey") then
		Client.Utility.SpawnParticles("TempleSkullPickup", instance:GetPivot())
	end
end

local v11 = 0

function StartDragging(instance)
	if not Client.PlayerHandler.Alive or Client.SledClient.IsSledding() then
		return
	end

	if instance:GetAttribute("EasterDraggingLocked") then
		local easterDraggingLocked = instance:GetAttribute("EasterDraggingLocked")
		Client.PopUpUI.AddPopUp(easterDraggingLocked, "easter")
		Client.EggEffectClient.FlashRed(instance)
	else
		if instance:GetAttribute("Locked") and instance:GetAttribute("LockedMessage") then
			Client.PopUpUI.AddPopUp(instance:GetAttribute("LockedMessage"), "warning")
			return
		end

		if v6 and v6 == instance then
			return
		end

		local v12 = v11 + 1
		v11 = v12
		Client.Events.StopDraggingItem:Fire(nil, v12)

		if InteractionHandler.CheckCollectCurrency(instance) then
			return
		end

		local owner = instance:GetAttribute("Owner")

		if owner ~= nil and owner ~= localPlayer.UserId then
			return
		end

		if instance:GetAttribute("InteractedWith") == nil then
			OnFirstInteraction(instance)

			if instance:GetAttribute("FirstParticleName") then
				task.spawn(function()
					InteractionHandler.FirstInteractParticles(instance)
				end)
			end
		end

		instance:SetAttribute("InteractedWith", true)

		if instance:GetAttribute("FloatingPotion") then
			Client.CauldronClient.TakePotion(instance)
		end

		if instance:GetAttribute("SqueakyToy") then
			Client.Sound.Play("Toy")
		end

		Client.Events.RequestStartDraggingItem:FireServer(instance)
		local alignPosition = Instance.new("AlignPosition")
		alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
		alignPosition.Attachment0 = instance.PrimaryPart.DraggingAttachment
		alignPosition.MaxForce = 10000
		alignPosition.Responsiveness = 50
		alignPosition.Parent = instance.PrimaryPart
		local angularVelocity = Instance.new("AngularVelocity")
		angularVelocity.Attachment0 = instance.PrimaryPart.DraggingAttachment
		angularVelocity.MaxTorque = 1e999
		angularVelocity.Parent = instance.PrimaryPart
		local parent = instance.Parent
		local pivot = instance:GetPivot()
		local v13 = (workspace.CurrentCamera.CFrame.Position - pivot.Position).Magnitude - 1.5
		workspace.CurrentCamera.CFrame:ToObjectSpace(pivot)
		local humanoid = instance:GetAttribute("Ragdoll") and instance:FindFirstChildWhichIsA("Humanoid")

		if humanoid then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
			humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
		end

		local v14 = true
		local stopDraggingItemConnection = nil

		local function cancelDragging(p)
			alignPosition:Destroy()
			angularVelocity:Destroy()
			task.spawn(function()
				if p then
					wait(p)
				end

				Client.Events.StopDraggingItem:FireServer(instance)
			end)
			v14 = false
			v6 = nil
			stopDraggingItemConnection:Disconnect()
			Client.GuiButtonHandler.HideButton("Undrag")
			Client.Events.ItemDraggingEnded:Fire(instance)
		end

		stopDraggingItemConnection = Client.Events.StopDraggingItem:Connect(function(p, p2)
			if p2 and p2 <= v12 then
				return
			end

			cancelDragging(p)
		end)
		v6 = instance
		Client.GuiButtonHandler.HideButton("Drag")
		Client.GuiButtonHandler.ShowButton("Undrag")

		if v8 == "Touch" then
			Client.GuiButtonHandler.CreateTouchDeviceStoreButton()
		end

		Client.Events.StartDraggingItem:Fire(v6)
		task.spawn(function()
			while true do
				if not v then
					cancelDragging()
				end

				if instance.Parent ~= parent then
					cancelDragging()
				end

				if not Client.PlayerHandler.Alive then
					cancelDragging()
				end

				if not instance:HasTag("Interaction") then
					cancelDragging()
				end

				local character = localPlayer.Character

				if character then
					if (instance:GetPivot().Position - character:GetPivot().Position).Magnitude > 30 then
						cancelDragging()
					end
				else
					cancelDragging()
				end

				if not v14 then
					break
				end

				if Client.FirstPersonModule.IsVisible() then
					alignPosition.Position = (workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -v13)).Position
				elseif UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
					local v15 = workspace.CurrentCamera.CFrame.LookVector * createVector(1, 0.5, 1)
					alignPosition.Position = (CFrame.lookAlong(Client.PlayerHandler.HumanoidRootPart.Position, v15) * CFrame.new(
						1,
						1,
						-6
					)).Position
				elseif v8 == "Touch" then
					alignPosition.Position = (CFrame.lookAlong(
						Client.PlayerHandler.HumanoidRootPart.Position,
						workspace.CurrentCamera.CFrame.LookVector * createVector(1, 0, 1)
					) * CFrame.new(3, 0, -3)).Position
				else
					alignPosition.Position = mouse.UnitRay.Origin + mouse.UnitRay.Direction * v13
				end

				CFrame.lookAt(alignPosition.Position, workspace.CurrentCamera.CFrame.Position)
				RunService.Stepped:Wait()
			end
		end)
	end
end

Client.Events.PlayerDied:Connect(function()
	if v6 then
		Client.Events.StopDraggingItem:Fire()
	end
end)
localPlayer.CharacterRemoving:Connect(function()
	if v6 then
		Client.Events.StopDraggingItem:Fire()
	end
end)
local _ = {
	PotionMaking = "🧪",
	Burnable = "🔥",
	Edible = "🍴",
	Valuable = "💎",
	Scrappable = "🔩",
	Speed = "⚡",
	Flower = "🌺",
	Toy = "🧸",
	EasterEgg = "🐰"
}

function MakeHoverLabel(parent)
	local clone = ReplicatedStorage.Assets.Billboards.HoverLabel:Clone()
	clone.ItemName.Text = parent.Name
	local text = ""
	clone.Adornee = parent.PrimaryPart.DraggingAttachment

	if parent:GetAttribute("BurnFuel") and parent:GetAttribute("BurnFuel") > 5 then
		for _ = 1, parent:GetAttribute("BurnFuel") >= 500 and 4 or parent:GetAttribute("BurnFuel") >= 270 and 3 or parent:GetAttribute("BurnFuel") >= 90 and 2 or 1 do
			text ..= "🔥"
		end
	end

	if parent:GetAttribute("SpeedBoost") then
		text ..= "⚡"
	elseif parent:GetAttribute("RestoreHunger") and parent:GetAttribute("RestoreHunger") > 0 then
		for _ = 1, parent:GetAttribute("RestoreHunger") >= 100 and 4 or parent:GetAttribute("RestoreHunger") >= 70 and 3 or parent:GetAttribute("RestoreHunger") >= 30 and 2 or parent:GetAttribute("RestoreHunger") >= 0 and 1 or 1 do
			text ..= "🍴"
		end
	end

	if parent:GetAttribute("EasterEggId") then
		text ..= "🐰"
	end

	if parent:GetAttribute("Scrappable") then
		for _ = 1, parent:GetAttribute("Scrappable") >= 8 and 4 or parent:GetAttribute("Scrappable") >= 5 and 3 or parent:GetAttribute("Scrappable") >= 3 and 2 or 1 do
			text ..= "🔩"
		end
	end

	if parent:HasTag("Flower") then
		text ..= "🌺"
	end

	if parent:HasTag("PotionIngredient") then
		text ..= "🧪"
	end

	if parent:HasTag("Toy") then
		text ..= "🧸"
	end

	clone.Emojis.Text = text
	clone.Parent = parent
	v5 = clone
end

function InteractionHandler.BlockClickInteractions(p)
	v9 = time() + p
end

function CheckClickInteraction(_, p, _)
	if Client.StructurePlacementClient.PlacementActive or p ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	if time() < v9 then
		return
	end

	local v12, v13 = CheckMouseTarget()

	if not v12 then
		return Enum.ContextActionResult.Pass
	end

	local interaction = v12:GetAttribute("Interaction")

	if InteractionHandler.Interactions[interaction] then
		v8 = "Mouse"
		InteractionHandler.ProcessInteraction(v12, interaction, nil, "Click")

		if UserInputService.PreferredInput ~= Enum.PreferredInput.Gamepad and v13 == "Zone" then
			return Enum.ContextActionResult.Sink
		end
	end

	return Enum.ContextActionResult.Pass
end

ContextActionService:BindActionAtPriority(
	"CheckClickInteraction",
	CheckClickInteraction,
	false,
	Enum.ContextActionPriority.High.Value + 5,
	Enum.UserInputType.MouseButton1,
	Enum.KeyCode.ButtonR2
)

function CheckToggleShiftlock(_, p, _)
	if p == Enum.UserInputState.Begin then
		Client.WalkspeedController.ToggleShiftLock()
	end
end

ContextActionService:BindActionAtPriority(
	"CheckToggleShiftlock",
	CheckToggleShiftlock,
	false,
	Enum.ContextActionPriority.High.Value + 5,
	Enum.KeyCode.ButtonL2
)

function InteractionHandler.CheckMobileFirstPersonInteraction()
	if Client.StructurePlacementClient.PlacementActive then
		return Enum.ContextActionResult.Pass
	end

	if time() < v9 then
		return
	end

	local v12 = CheckMouseTarget()

	if v12 then
		local interaction = v12:GetAttribute("Interaction")

		if InteractionHandler.Interactions[interaction] then
			v = true
			v8 = "Touch"
			InteractionHandler.ProcessInteraction(v12, interaction, nil, "Touch")
			return Enum.ContextActionResult.Sink
		end
	end
end

function CanTake(instance)
	if (instance:GetAttribute("Interaction") == "Tool" or instance:GetAttribute("Interaction") == "Armour") and not IsToolDowngrade(instance) then
		return "Take"
	end

	if instance:HasTag("Plantable") or instance:HasTag("Acorn") then
		return "Plant"
	end

	if instance:HasTag("Flower") then
		return "Pick"
	end

	if instance:GetAttribute("Interaction") == "Currency" or (instance:GetAttribute("Interaction") == "HalloweenCandy" or instance:GetAttribute("Interaction") == "ChristmasCandyCane") then
		return "Take"
	end

	if instance:GetAttribute("RestoreHunger") then
		return "Eat"
	end

	if instance:GetAttribute("GoldTrimKit") then
		return "Use"
	end

	if instance:HasTag("SeedBox") then
		return "Plant Seeds"
	end

	if (instance.Name == "Fuel Canister" or instance.Name == "Oil Barrel") and localPlayer:GetAttribute("Class") == "Pyromaniac" then
		return "Take"
	end

	if instance:GetAttribute("RestoreHealth") or instance:GetAttribute("RifleAmmo") or instance:GetAttribute("RevolverAmmo") or instance:GetAttribute("ShotgunAmmo") or instance:GetAttribute("AmmoType") then
		return "Take"
	end

	return nil
end

InteractionHandler.CanTake = CanTake
task.spawn(function()
	RunService.RenderStepped:Connect(function()
		debug.profilebegin("GetMouseTarget")
		local v12 = v6 or CheckMouseTarget()
		debug.profileend()

		if Client.StructurePlacementClient.PlacementActive then
			v12 = nil
		end

		if Client.PingClient.PingActive then
			task.spawn(function()
				Client.PingClient.HighlightFocusModel()
			end)
			v12 = nil
		end

		UpdateReticle()

		if v12 then
			if UserInputService.PreferredInput ~= Enum.PreferredInput.Gamepad then
				mouse.Icon = "http://www.roblox.com/asset/?id=6846661576"
			end

			interactionHighlight.Adornee = v12
			interactionHighlight.Enabled = true

			if v12:HasTag("Flower") then
				InteractionHandler.FlowerHover = v12
			end
		else
			if mouse.Icon == "http://www.roblox.com/asset/?id=6846661576" then
				if localPlayer.Character and localPlayer.Character:FindFirstChild("ToolHandle") and localPlayer.Character.ToolHandle:GetAttribute("ToolName") == "Firearm" then
					mouse.Icon = "rbxassetid://107221172731109"
				else
					mouse.Icon = ""
				end
			end

			interactionHighlight.Adornee = nil
			interactionHighlight.Enabled = false
			debug.profilebegin("ToggleMobileDragButton1")
			Client.GuiButtonHandler.HideButton("Drag")
			debug.profileend()
			InteractionHandler.FlowerHover = nil
		end

		debug.profilebegin("CheckCanTake")
		local v13 = v12 and CanTake(v12)
		debug.profileend()
		debug.profilebegin("ToggleMobileButtons")

		if v13 then
			if v13 == "Take" then
				Client.GuiButtonHandler.ShowButton("Take")
				Client.GuiButtonHandler.HideButton("Eat")
				Client.GuiButtonHandler.HideButton("Plant")
				Client.GuiButtonHandler.HideButton("Pick")
				Client.GuiButtonHandler.HideButton("Plant Seeds")
			elseif v13 == "Eat" then
				Client.GuiButtonHandler.ShowButton("Eat")
				Client.GuiButtonHandler.HideButton("Take")
				Client.GuiButtonHandler.HideButton("Plant")
				Client.GuiButtonHandler.HideButton("Pick")
				Client.GuiButtonHandler.HideButton("Plant Seeds")
			elseif v13 == "Plant" then
				Client.GuiButtonHandler.ShowButton("Plant")
				Client.GuiButtonHandler.HideButton("Take")
				Client.GuiButtonHandler.HideButton("Eat")
				Client.GuiButtonHandler.HideButton("Pick")
				Client.GuiButtonHandler.HideButton("Plant Seeds")
			elseif v13 == "Pick" then
				Client.GuiButtonHandler.ShowButton("Pick")
				Client.GuiButtonHandler.HideButton("Plant")
				Client.GuiButtonHandler.HideButton("Take")
				Client.GuiButtonHandler.HideButton("Eat")
				Client.GuiButtonHandler.HideButton("Plant Seeds")
			elseif v13 == "Plant Seeds" then
				Client.GuiButtonHandler.ShowButton("Plant Seeds")
				Client.GuiButtonHandler.HideButton("Pick")
				Client.GuiButtonHandler.HideButton("Plant")
				Client.GuiButtonHandler.HideButton("Take")
				Client.GuiButtonHandler.HideButton("Eat")
			elseif v13 == "Use" then
				Client.GuiButtonHandler.ShowButton("Use")
				Client.GuiButtonHandler.HideButton("Pick")
				Client.GuiButtonHandler.HideButton("Plant")
				Client.GuiButtonHandler.HideButton("Take")
				Client.GuiButtonHandler.HideButton("Eat")
			end
		else
			Client.GuiButtonHandler.HideButton("Take")
			Client.GuiButtonHandler.HideButton("Eat")
			Client.GuiButtonHandler.HideButton("Plant")
			Client.GuiButtonHandler.HideButton("Pick")
			Client.GuiButtonHandler.HideButton("Plant Seeds")
			Client.GuiButtonHandler.HideButton("Use")
		end

		debug.profileend()
		debug.profilebegin("ToggleMobileStoreButton")
		local currentlyEquipped = Client.InventoryHandler.GetCurrentlyEquipped()

		if currentlyEquipped and currentlyEquipped:HasTag("ItemBag") and (not v12 or v12:GetAttribute("Interaction") ~= "Tool" and v12:GetAttribute("Interaction") ~= "Armour") then
			local countedItems = currentlyEquipped:GetAttribute("CountedItems") or currentlyEquipped:GetAttribute("NumberItems") or 0
			local numberItems = currentlyEquipped:GetAttribute("NumberItems") or countedItems
			local itemBagSpace = Client.Utility.GetItemBagSpace(currentlyEquipped, localPlayer)

			if v12 then
				if countedItems < itemBagSpace or not Client.Utility.ItemNeedsBagSpace(v12, localPlayer) then
					Client.GuiButtonHandler.ShowButton("Store")
				else
					Client.GuiButtonHandler.HideButton("Store")
				end

				Client.GuiButtonHandler.HideButton("Unstore")
			else
				if numberItems > 0 then
					Client.GuiButtonHandler.ShowButton("Unstore")
				else
					Client.GuiButtonHandler.HideButton("Unstore")
				end

				Client.GuiButtonHandler.HideButton("Store")
			end
		else
			Client.GuiButtonHandler.HideButton("Store")
			Client.GuiButtonHandler.HideButton("Unstore")
		end

		debug.profileend()
		debug.profilebegin("CreateHoverLabel")

		if v6 and v8 ~= "Touch" then
			if v5 then
				v5:Destroy()
				v5 = nil
			end
		elseif v12 ~= v4 then
			if v5 then
				v5:Destroy()
				v5 = nil
			end

			v4 = v12

			if v12 and v10[v12:GetAttribute("Interaction")] then
				MakeHoverLabel(v12)
			end

			debug.profilebegin("ToggleMobileDragButton2")
			Client.GuiButtonHandler.ShowButton("Drag")
			debug.profileend()
		end

		debug.profileend()
	end)
end)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace.Particles }

function GetInteractionFromPart(p)
	local parent = p.Parent

	for _ = 1, 3 do
		if parent == nil or parent:GetAttribute("Interaction") then
			break
		else
			parent = parent.Parent
		end
	end

	if parent and parent:GetAttribute("Interaction") and parent:HasTag("Interaction") and Client.PlayerHandler.HumanoidRootPart and (Client.PlayerHandler.HumanoidRootPart.Position - parent:GetPivot().Position).Magnitude <= Client.GlobalSettings.InteractionDistance + 1 and (parent:GetAttribute("Owner") == nil or parent:GetAttribute("Owner") == localPlayer.UserId) then
		if parent:GetAttribute("Interaction") == "CanBeBagged" then
			local currentlyEquipped = Client.InventoryHandler.GetCurrentlyEquipped()

			if currentlyEquipped == nil or not currentlyEquipped:HasTag("ItemBag") then
				return
			end
		end

		if parent:GetAttribute("InteractOnCooldown") == nil and parent:GetAttribute("NotClickable") == nil then
			return parent
		end
	end
end

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { workspace.Items, workspace.Map, workspace.Structures }

function CheckGamepadZone()
	local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local v12 = humanoidRootPart.CFrame * CFrame.new(0, 0, -2)
		local partBoundsInBox = workspace:GetPartBoundsInBox(v12, createVector(6, 7, 7), overlapParams)
		local v13 = {}

		for _, v14 in pairs(partBoundsInBox) do
			local v15 = GetInteractionFromPart(v14)

			if v15 then
				v13[v15] = true
			end
		end

		local position = humanoidRootPart.Position
		local v14 = 1e999
		local v15 = nil

		for k in pairs(v13) do
			local magnitude = (k:GetPivot().Position - position).Magnitude

			if not (magnitude < v14) then
				continue
			end

			v15 = k
			v14 = magnitude
		end

		if v15 then
			return v15
		end
	end
end

function CheckTapAssist(p)
	if p == nil then
		return
	end

	local position = p.Position
	local v12 = 1e999
	local v13 = nil

	for _, v14 in pairs(workspace:GetPartBoundsInRadius(
		position,
		Client.GlobalSettings.MaxTapAssistRadius,
		overlapParams
	)) do
		local v15 = GetInteractionFromPart(v14)

		if not v15 then
			continue
		end

		local tapAssist = v15:GetAttribute("TapAssist")

		if not tapAssist then
			continue
		end

		local magnitude = (v14.Position - position).Magnitude

		if not (magnitude <= tapAssist and magnitude < v12) then
			continue
		end

		v13 = v15
		v12 = magnitude
	end

	return v13
end

function UpdateReticle()
	local currentlyEquipped = Client.InventoryHandler.GetCurrentlyEquipped()
	local currentPlatform = Client.GuiButtonHandler.GetCurrentPlatform()
	local v12 = currentPlatform == "Touch" and not Client.FirstPersonModule.IsVisible() and currentlyEquipped and currentlyEquipped:GetAttribute("Automatic") and 4 or 0
	InteractionHandler.SetCameraOffset(v12)
	local visible = currentPlatform == "Touch" and not Client.FirstPersonModule.IsVisible() and currentlyEquipped and currentlyEquipped:GetAttribute("Automatic") and true or false
	Client.Interface.MobileCursor.Crosshairs.Visible = visible

	if UserInputService.TouchEnabled and (Client.FirstPersonModule.IsVisible() or currentlyEquipped and currentlyEquipped:GetAttribute("Automatic")) then
		Client.Interface.MobileCursor.Visible = true
	else
		Client.Interface.MobileCursor.Visible = false
	end
end

InteractionHandler.UpdateReticle = UpdateReticle
local v12 = nil

function InteractionHandler.SetCameraOffset(p)
	if v2 == p then
		return
	end

	if v12 then
		v12:Stop()
		v12 = nil
	end

	local v13 = v2
	local v14 = p - v13
	local tweenModule = Client.TweenModule.new(function(p2)
		v2 = v13 + v14 * p2
	end, 0.25, "Quad")
	v12 = tweenModule
	tweenModule:Play()
end

RunService:BindToRenderStep("UpdateCameraOffset", Enum.RenderPriority.Camera.Value - 1, function(_)
	local currentCamera = workspace.CurrentCamera
	local cameraSubject = currentCamera and currentCamera.CameraSubject

	if v2 == 0 or (cameraSubject == nil or not cameraSubject:IsA("Humanoid")) then
		return
	end

	local rootPart = cameraSubject.RootPart

	if rootPart == nil then
		return
	end

	local rightVector = currentCamera.CFrame.RightVector
	local vector2 = Vector3.new(rightVector.X, 0, rightVector.Z)

	if vector2.Magnitude < 0.0001 then
		return
	end

	local cameraOffset = rootPart.CFrame:VectorToObjectSpace(vector2.Unit) * v2

	if v2 > 0 then
		cameraOffset += Vector3.new(0, v2 / 4, 0)
	end

	cameraSubject.CameraOffset = cameraOffset
end)

function CheckMouseTarget(p)
	if localPlayer:GetAttribute("Undead") then
		return nil
	end

	local guiObjectsAtPosition = localPlayer.PlayerGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y)

	for _, v13 in pairs(guiObjectsAtPosition) do
		if v13.Transparency < 1 and v13.Active then
			return nil
		end
	end

	local v13 = p or mouse.UnitRay
	local currentlyEquipped = Client.InventoryHandler.GetCurrentlyEquipped()

	if p == nil then
		UpdateReticle()
	end

	if p == nil and UserInputService.TouchEnabled and (Client.FirstPersonModule.IsVisible() or currentlyEquipped and currentlyEquipped:GetAttribute("Automatic")) then
		local viewportSize = workspace.CurrentCamera.ViewportSize
		local GuiService2 = game:GetService("GuiService")
		local guiInset = GuiService2:GetGuiInset()
		v13 = workspace.CurrentCamera:ScreenPointToRay(viewportSize.X / 2, viewportSize.Y / 2 - guiInset.Y)
	end

	local raycastResult = workspace:Raycast(v13.Origin, v13.Direction * 100, Client.CollisionUtility.InteractionParams)
	local v14 = nil
	local v15

	if raycastResult and raycastResult.Instance then
		v15 = GetInteractionFromPart(raycastResult.Instance)

		if v15 then
			v14 = "MouseTarget"
		end
	end

	if v15 == nil and p ~= nil then
		v15 = CheckTapAssist(raycastResult)

		if v15 then
			v14 = "TapZone"
		end
	end

	local toolEquipped = Client.InventoryHandler.ToolEquipped()

	if (not toolEquipped or not toolEquipped.Model or toolEquipped.Model:GetAttribute("ToolName") ~= "Item Bag") and v15 == nil and UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
		v15 = CheckGamepadZone()

		if v15 then
			v14 = "Zone"
		end
	end

	return v15, v14
end

function InteractionHandler.ProcessInteraction(p, p2, _, value)
	if not Client.PlayerHandler.Alive or localPlayer:GetAttribute("Undead") then
		return
	end

	local interaction = InteractionHandler.Interactions[p2]

	if not interaction then
		warn("No interaction for", p2)
		return
	end

	Client.PromptHandler.CheckInteractionCooldown(p)
	interaction(p, value or "Prompt")
end

function InteractionHandler.Init()
	task.spawn(function()
		localPlayer:GetAttributeChangedSignal("Undead"):Connect(function()
			Client.Events.StopDraggingItem:Fire()
		end)
		localPlayer:GetAttributeChangedSignal("HalloweenTransformed"):Connect(function()
			Client.Events.StopDraggingItem:Fire()
		end)
	end)
end

return InteractionHandler