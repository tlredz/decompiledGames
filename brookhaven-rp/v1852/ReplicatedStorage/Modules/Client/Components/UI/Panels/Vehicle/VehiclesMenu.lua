local createVector = vector.create
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LoadableEntriesItem = require(ReplicatedStorage.Modules.Client.Components.UI.Utils.Loadables.LoadableEntriesItem)
require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local BackActionRouter = require(ReplicatedStorage.Modules.Client.UI.BackActionRouter)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local HorsesController = require(ReplicatedStorage.Modules.Client.Vehicles.HorsesController)
local NoMotorAnimationController = require(ReplicatedStorage.Modules.Client.Vehicles.NoMotorAnimationController)
local NoMotorVehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.NoMotorVehicleController)
require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local VehicleEvents = require(ReplicatedStorage.Modules.Shared.Game.Vehicles.VehicleEvents)
local CategoryItem = require(ReplicatedStorage.Modules.Shared.Item.CategoryItem)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local LegacyGame8Settings = require(ReplicatedStorage.Modules.Client.UI.LegacyGame8Settings)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Component = require(ReplicatedStorage.Packages.Component)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "VehiclesMenu"
})
local noMotorVehicles = LegacyGame8Settings.NoMotorVehicles
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local PlayerFlag = require(ReplicatedStorage.Modules.Client.PlayerFlags.PlayerFlag)
local VehicleSaveStates = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Vehicle.VehicleSaveStates)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
require(ReplicatedStorage.Modules.Shared.Item.Items.DevProductItem)
local VehicleMiddleware = require(ReplicatedStorage.Modules.Shared.Item.Middleware.VehicleMiddleware)
local Object = require(ReplicatedStorage.Modules.Shared.Item.Object)
local Players2 = game:GetService("Players")
local localPlayer = Players2.LocalPlayer

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	local categoryTabs = instance.Catalog.Header.CategoryTabs

	for _, button in categoryTabs:GetChildren() do
		if button:IsA("TextButton") or button:IsA("ImageButton") then
			button.SelectionOrder = 2000
		end
	end

	local component = ComponentUtil.GetComponentFromInstance(
		instance.Catalog.Container.ScrollingFrame,
		LoadableEntriesItem
	)
	local backButton = instance.Catalog.Header.CategoryTabs.BackButton
	local v2 = nil

	local function unbindBackAction()
		if not v2 then
			return
		end

		v2()
		v2 = nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function bindBackAction()
		if v2 then
			return
		end

		v2 = BackActionRouter.Bind(function()
			component:SetCategory(nil)
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateBackActionBinding()
		if instance.Visible and backButton.Visible then
			bindBackAction() -- equivalent call inferred; original call site unknown
		else
			if not v2 then
				return
			end

			v2()
			v2 = nil
		end
	end

	self._Janitor:Add(unbindBackAction)
	local mainGUIHandler = nil
	local mainAudio = nil
	local noCarsRegions = nil
	local player8Handler = nil
	local carTimer = nil
	local child = nil
	local humanoid = nil
	local noMotorControlHolder = nil
	local horseControl = nil
	local horseControlButtons = nil
	local horseButtons = nil

	local function setVariables()
		mainGUIHandler = Players.LocalPlayer.PlayerGui:WaitForChild("MainGUIHandler")
		mainAudio = mainGUIHandler:WaitForChild("MainAudio")
		noCarsRegions = ReplicatedStorage:WaitForChild("NoCarsRegions")
		player8Handler = Players.LocalPlayer.PlayerGui:WaitForChild("Player8Handler")
		carTimer = player8Handler:WaitForChild("CarTimer")
		local Players3 = game:GetService("Players")
		localPlayer = Players3.LocalPlayer
		child = workspace:WaitForChild(localPlayer.Name)
		humanoid = child:WaitForChild("Humanoid")
		noMotorControlHolder = mainGUIHandler:WaitForChild("NoMotorControlHolder")
		horseControl = noMotorControlHolder:WaitForChild("HorseControl")
		horseControlButtons = horseControl:WaitForChild("HorseControlButtons")
		horseButtons = horseControlButtons:WaitForChild("HorseButtons")
	end

	local function checkPlayerInNoCarsRegion()
		for _, descendant in noCarsRegions:GetDescendants(), nil, nil do
			if not (descendant.className == "Part" and descendant.Spawnable.Value == false) then
				continue
			end

			local region = Region3.new(
				descendant.Position - descendant.Size / 2,
				descendant.Position + descendant.Size / 2
			)
			local partsInRegion3 = game.Workspace:FindPartsInRegion3WithWhiteList(region, { localPlayer.Character }, 1)

			for _, v3 in partsInRegion3 do
				if v3:FindFirstAncestor(game.Players.LocalPlayer.Name) then
					return true
				end
			end
		end

		return false
	end

	setVariables()
	localPlayer.CharacterAdded:Connect(setVariables)
	self.secondarySkin = horseButtons:WaitForChild("SecondaryHorse")
	self.defaultSkin = horseButtons:WaitForChild("DefaultHorse")
	local maid = Janitor.new()
	local v3 = false
	local v4 = false
	local v5 = false
	local v6 = true

	local function CarTimerEvent()
		if carTimer.Value == true then
			mainAudio.Catalog.Header.ButtonsList.PausePlay.Image = "rbxassetid://118117426385847"

			if player8Handler:FindFirstChild("CarTimerWait") then
				if GamepassController.IsOwned(Gamepasses.VIP) then
					player8Handler.CarTimerWait.Value = LegacyGame8Settings.VIPHouseTimer
				else
					player8Handler.CarTimerWait.Value = LegacyGame8Settings.CarCoolDown
				end

				while player8Handler.CarTimerWait.Value > 0 do
					player8Handler.CarTimerWait.Value = player8Handler.CarTimerWait.Value - 1
					local v7 = math.floor(player8Handler.CarTimerWait.Value % 60)
					local formatted = ("%i:%.2i"):format(math.floor(player8Handler.CarTimerWait.Value / 60), v7)
					instance.Catalog.Header.CategoryTabs.Cooldown.InnerFrame.CarTimer1.Text = "Please wait: " .. formatted .. ""
					wait(1)

					if player8Handler.CarTimerWait.Value <= 0 then
						carTimer.Value = false
						instance.Catalog.Header.CategoryTabs.Cooldown.Visible = false
					else
						instance.Catalog.Header.CategoryTabs.Cooldown.Visible = true
					end
				end
			else
				carTimer.Value = false
				instance.Catalog.Header.CategoryTabs.Cooldown.Visible = false
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function endConsoleSelection()
		local v7, v8 = ABTest.GetExperimentVariables("console-controls"):timeout(7):await()

		if v7 and v8.enabled and not v8.dpadNavigation then
			Platform.EndSelection()
		end
	end

	local NoMotorVehicleRequest

	NoMotorVehicleRequest = function(_, _, _)
		ContextActionService:UnbindAction("NoMotorVehicleRequest", NoMotorVehicleRequest, false, Enum.KeyCode.E)
		PanelController.Close("MainGUIHandler", "NoMotorVehicleControl")
		endConsoleSelection() -- equivalent call inferred; original call site unknown
		mainAudio.Catalog.Header.ButtonsList.PausePlay.Image = "rbxassetid://118117426385847"
		mainAudio.Visible = false
		noMotorVehicles:FireServer("Delete NoMotorVehicle")
		humanoid.HipHeight = player8Handler.TempHIP.Value
		NoMotorAnimationController.StopAll()
		humanoid.WalkSpeed = 16
	end

	local function canSpawnVehicle()
		return localPlayer ~= nil and humanoid.Sit == false and localPlayer.Character and not localPlayer.Character.HumanoidRootPart:FindFirstChild("Drone") and not (localPlayer.Character:FindFirstChild(localPlayer.Name .. "Horse") or localPlayer.Character:FindFirstChild("ClientToClient") or localPlayer.Character:FindFirstChild("Chute") or localPlayer.Character:FindFirstChild("NoMotorVehicleModel"))
	end

	local function VehicleButtonAdded(button)
		if button:GetAttribute("AttachedConnection") ~= nil then
			return
		end

		button:SetAttribute("AttachedConnection", true)

		if not button:IsA("ImageButton") then
			return
		end

		local item = ItemRegistry.GetItem(button.Name, VehicleMiddleware.VehicleItem)

		if not item then
			return
		end

		maid:Add(button.MouseButton1Click:Connect(function()
			player8Handler.TempHIP.Value = humanoid.HipHeight
			local filterDescendantsInstances = { localPlayer.Character }
			local overlapParams = OverlapParams.new()
			overlapParams.FilterType = Enum.RaycastFilterType.Include
			overlapParams.FilterDescendantsInstances = filterDescendantsInstances

			for _, child2 in workspace.Helicopters:GetChildren() do
				local playerArea = child2:FindFirstChild("PlayerArea")

				if not (playerArea and #workspace:GetPartBoundsInBox(playerArea.CFrame, playerArea.Size, overlapParams) > 0) then
					continue
				end

				NotificationController.Notify("Cannot spawn at location")
				return
			end

			local currentFilter = component.Instance:GetAttribute("CurrentFilter")

			if Object.InstanceOf(item, CategoryItem) and item:GetCategory() == "HorseCategory" then
				local function trySpawnHorse()
					if button.Parent == nil or not PanelController.IsOpen("MainGUIHandler", "MainVehicleMenu") then
						return
					end

					if HorsesController.TrySpawnVehicle(button.Name, currentFilter) then
						self.defaultSkin.Icon.Image = item:GetIcon()
						self.secondarySkin.Icon.Image = item.VehicleImpl.SecondarySkinIcon
					end
				end

				if not item:IsUnlockedClient() then
					item:OnDenied(NotificationController.NotifyCenter, "VehiclesMenu", trySpawnHorse)
					return
				end

				TelemetryController.SendClientInteraction("filterClick", {
					filter = currentFilter,
					itemType = button.Parent:GetAttribute("ItemType"),
					name = button.Name
				})
				trySpawnHorse()
			elseif Object.InstanceOf(item, CategoryItem) and item:IsCategory() then
				component:SetCategory(item:GetName())
			elseif v3 == false and canSpawnVehicle() then
				v3 = true
				task.delay(1, function()
					v3 = false
				end)
				local name = button.Name
				local v8 = button:FindFirstChild("NoMotor") ~= nil

				local function trySpawnVehicle()
					if v8 then
						local noMotorVehicle = NoMotorVehicleController.RequestNoMotorVehicle(name, currentFilter)

						if noMotorVehicle then
							endConsoleSelection() -- equivalent call inferred; original call site unknown
						end

						return noMotorVehicle
					elseif v8 or item.VehicleImpl.Type == "boat" or item.VehicleImpl.Type == "hybrid" or child:FindFirstChild("NoMotorVehicleModel") then
						if item.VehicleImpl.Type == "boat" and not child:FindFirstChild("NoMotorVehicleModel") then
							local filterDescendantsInstances2 = { localPlayer.Character }
							local overlapParams2 = OverlapParams.new()
							overlapParams2.FilterType = Enum.RaycastFilterType.Include
							overlapParams2.FilterDescendantsInstances = filterDescendantsInstances2
							local partBoundsInBox = workspace:GetPartBoundsInBox(
								workspace.WorkspaceCom["001_OceanSpawns"].OceanWest.CFrame,
								createVector(7029, 400, 1987),
								overlapParams2
							)
							local v10 = false

							for _, v11 in partBoundsInBox do
								local parent = v11.Parent

								if parent ~= nil and parent:FindFirstChild("Humanoid") then
									v10 = true
								end
							end

							local partBoundsInBox2 = workspace:GetPartBoundsInBox(
								workspace.WorkspaceCom["001_OceanSpawns"].OceanEast.CFrame,
								createVector(7029, 400, 1987),
								overlapParams2
							)

							for _, v11 in partBoundsInBox2 do
								local parent = v11.Parent

								if parent ~= nil and parent:FindFirstChild("Humanoid") then
									v10 = true
								end
							end

							local partBoundsInBox3 = workspace:GetPartBoundsInBox(
								workspace.WorkspaceCom["001_OceanSpawns"].OceanNorth.CFrame,
								createVector(7029, 400, 1987),
								overlapParams2
							)

							for _, v11 in partBoundsInBox3 do
								local parent = v11.Parent

								if parent ~= nil and parent:FindFirstChild("Humanoid") then
									v10 = true
								end
							end

							local partBoundsInBox4 = workspace:GetPartBoundsInBox(
								workspace.WorkspaceCom["001_OceanSpawns"].OceanSouth.CFrame,
								createVector(7029, 400, 1987),
								overlapParams2
							)

							for _, v11 in partBoundsInBox4 do
								local parent = v11.Parent

								if parent ~= nil and parent:FindFirstChild("Humanoid") then
									v10 = true
								end
							end

							local _35 = game.ReplicatedStorage.GetPropertyRegions:FindFirstChild("35")

							if _35 ~= nil and _35.Spawnable.Value == false then
								local partBoundsInBox5 = workspace:GetPartBoundsInBox(
									_35.CFrame,
									createVector(243, 341, 216),
									overlapParams2
								)

								for _, v11 in partBoundsInBox5 do
									local parent = v11.Parent

									if parent ~= nil and parent:FindFirstChild("Humanoid") then
										v10 = false
									end
								end
							end

							local _36 = game.ReplicatedStorage.GetPropertyRegions:FindFirstChild("36")

							if _36 ~= nil and _36.Spawnable.Value == false then
								local partBoundsInBox5 = workspace:GetPartBoundsInBox(
									_36.CFrame,
									createVector(264, 585, 332),
									overlapParams2
								)

								for _, v11 in partBoundsInBox5 do
									local parent = v11.Parent

									if parent ~= nil and parent:FindFirstChild("Humanoid") then
										v10 = false
									end
								end
							end

							local _37 = game.ReplicatedStorage.GetPropertyRegions:FindFirstChild("37")

							if _37 ~= nil and _37.Spawnable.Value == false then
								local partBoundsInBox5 = workspace:GetPartBoundsInBox(
									_37.CFrame,
									createVector(612.8, 274.8, 650.2),
									overlapParams2
								)

								for _, v11 in partBoundsInBox5 do
									local parent = v11.Parent

									if parent ~= nil and parent:FindFirstChild("Humanoid") then
										v10 = false
									end
								end
							end

							local _37A = game.ReplicatedStorage.GetPropertyRegions:FindFirstChild("37A")

							if _37A ~= nil and _37A.Spawnable.Value == false then
								local partBoundsInBox5 = workspace:GetPartBoundsInBox(
									_37A.CFrame,
									createVector(268.8, 45.7, 544.2),
									overlapParams2
								)

								for _, v11 in partBoundsInBox5 do
									local parent = v11.Parent

									if parent ~= nil and parent:FindFirstChild("Humanoid") then
										v10 = false
									end
								end
							end

							local _37B = game.ReplicatedStorage.GetPropertyRegions:FindFirstChild("37B")

							if _37B ~= nil and _37B.Spawnable.Value == false then
								local partBoundsInBox5 = workspace:GetPartBoundsInBox(
									_37B.CFrame,
									createVector(208.8, 47.7, 268.2),
									overlapParams2
								)

								for _, v11 in partBoundsInBox5 do
									local parent = v11.Parent

									if parent ~= nil and parent:FindFirstChild("Humanoid") then
										v10 = false
									end
								end
							end

							if v10 ~= true then
								task.spawn(function()
									NotificationController.Notify("Go to the ocean to spawn a Boat!")
								end)
								return
							end

							if carTimer.Value ~= false then
								instance.Catalog.Header.CategoryTabs.Cooldown.Visible = true
								return
							end

							LegacyGame8Settings.Car:FireServer("PickingBoat", name, currentFilter)
							carTimer.Value = true
							PanelController.Close("MainGUIHandler", "MainVehicleMenu")
							endConsoleSelection() -- equivalent call inferred; original call site unknown
							task.spawn(CarTimerEvent)
						elseif item.VehicleImpl.Type == "hybrid" and not child:FindFirstChild("NoMotorVehicleModel") then
							if checkPlayerInNoCarsRegion() then
								NotificationController.Notify("Cannot spawn at location.")
							elseif carTimer.Value == false then
								LegacyGame8Settings.Car:FireServer("PickingBoat", name, currentFilter)
								carTimer.Value = true
								PanelController.Close("MainGUIHandler", "MainVehicleMenu")
								endConsoleSelection() -- equivalent call inferred; original call site unknown
								task.spawn(CarTimerEvent)
							else
								instance.Catalog.Header.CategoryTabs.Cooldown.Visible = true
							end
						end
					else
						v6 = true

						if checkPlayerInNoCarsRegion() then
							NotificationController.Notify("Cannot spawn at location.")
							return
						end

						local filterDescendantsInstances2 = { localPlayer.Character }
						local overlapParams2 = OverlapParams.new()
						overlapParams2.FilterType = Enum.RaycastFilterType.Include
						overlapParams2.FilterDescendantsInstances = filterDescendantsInstances2
						local partBoundsInBox = workspace:GetPartBoundsInBox(
							workspace.WorkspaceCom["001_OceanSpawns"].OceanWest.CFrame,
							createVector(7029, 400, 1987),
							overlapParams2
						)
						local v10 = true

						for _, v11 in partBoundsInBox do
							local parent = v11.Parent

							if parent ~= nil and parent:FindFirstChild("Humanoid") then
								v10 = false
							end
						end

						local partBoundsInBox2 = workspace:GetPartBoundsInBox(
							workspace.WorkspaceCom["001_OceanSpawns"].OceanEast.CFrame,
							createVector(7029, 400, 1987),
							overlapParams2
						)

						for _, v11 in partBoundsInBox2 do
							local parent = v11.Parent

							if parent ~= nil and parent:FindFirstChild("Humanoid") then
								v10 = false
							end
						end

						local partBoundsInBox3 = workspace:GetPartBoundsInBox(
							workspace.WorkspaceCom["001_OceanSpawns"].OceanNorth.CFrame,
							createVector(7029, 400, 1987),
							overlapParams2
						)

						for _, v11 in partBoundsInBox3 do
							local parent = v11.Parent

							if parent ~= nil and parent:FindFirstChild("Humanoid") then
								v10 = false
							end
						end

						local partBoundsInBox4 = workspace:GetPartBoundsInBox(
							workspace.WorkspaceCom["001_OceanSpawns"].OceanSouth.CFrame,
							createVector(7029, 400, 1987),
							overlapParams2
						)

						for _, v11 in partBoundsInBox4 do
							local parent = v11.Parent

							if parent ~= nil and parent:FindFirstChild("Humanoid") then
								v10 = false
							end
						end

						if v10 == false then
							spawn(function()
								NotificationController.Notify("Cannot spawn at location.")
							end)
						end

						if carTimer.Value ~= false then
							instance.Catalog.Header.CategoryTabs.Cooldown.Visible = true
							return
						end

						LegacyGame8Settings.Car:FireServer("PickingCar", name, currentFilter)
						carTimer.Value = true
						PanelController.Close("MainGUIHandler", "MainVehicleMenu")
						endConsoleSelection() -- equivalent call inferred; original call site unknown
						spawn(CarTimerEvent)
					end
				end

				if item:IsUnlockedClient() then
					TelemetryController.SendClientInteraction("filterClick", {
						filter = currentFilter,
						itemType = button.Parent:GetAttribute("ItemType"),
						name = button.Name
					})
					trySpawnVehicle()
				else
					item:OnDenied(function(text)
						local vehicleDeniedPopup = instance.Catalog.Header.VehicleDeniedPopup
						vehicleDeniedPopup.Label.Text = text
						vehicleDeniedPopup.Visible = true
						task.wait(3)
						vehicleDeniedPopup.Visible = false
					end, "VehiclesMenu", function()
						if button.Parent ~= nil and PanelController.IsOpen("MainGUIHandler", "MainVehicleMenu") and canSpawnVehicle() then
							trySpawnVehicle()
						end
					end)
				end
			end
		end))
	end

	component.Loaded:Connect(function()
		for _, child2 in instance.Catalog.Container.ScrollingFrame:GetChildren() do
			VehicleButtonAdded(child2)
		end

		maid:Add(instance.Catalog.Container.ScrollingFrame.ChildAdded:Connect(VehicleButtonAdded))
	end)

	if component:IsLoaded() then
		for _, child2 in instance.Catalog.Container.ScrollingFrame:GetChildren() do
			child2:SetAttribute("AttachedConnection", nil)
			VehicleButtonAdded(child2)
		end

		maid:Add(instance.Catalog.Container.ScrollingFrame.ChildAdded:Connect(VehicleButtonAdded))
	end

	component.Added:Connect(function(items)
		for _, item in items do
			VehicleButtonAdded(item)
		end
	end)
	component.Unloaded:Connect(function()
		maid:Cleanup()

		for _, child2 in instance.Catalog.Container.ScrollingFrame:GetChildren() do
			child2:SetAttribute("AttachedConnection", nil)
		end
	end)
	instance.Catalog.Header.CategoryTabs.NoCar.MouseButton1Click:connect(function()
		if v4 == false then
			v4 = true
			LegacyGame8Settings.Car:FireServer("DeleteAllVehicles")
			mainAudio.Visible = false
			wait(2)
			v4 = false
		end
	end)
	instance.Catalog.Header.CategoryTabs.KeyFab.MouseButton1Click:connect(function()
		if v5 == false then
			v5 = true
			player8Handler.Chirp:Play()

			if LegacyGame8Settings.KeyFab:InvokeServer("LockUnlockVehicles") == true then
				local greenCheckMark = instance.Catalog.Header.CategoryTabs.KeyFab:WaitForChild("GreenCheckMark")
				greenCheckMark.Visible = true
			else
				local greenCheckMark_2 = instance.Catalog.Header.CategoryTabs.KeyFab:WaitForChild("GreenCheckMark")
				greenCheckMark_2.Visible = false
			end

			wait(0.5)
			v5 = false
		end
	end)
	self._Janitor:Add(component.CategoryChanged:Connect(function(p)
		instance.Catalog.Header.CategoryTabs.BackButton.Visible = p ~= nil
		updateBackActionBinding() -- equivalent call inferred; original call site unknown
	end))
	self._Janitor:Add(instance:GetPropertyChangedSignal("Visible"):Connect(function()
		updateBackActionBinding() -- equivalent call inferred; original call site unknown
		instance.Catalog.Container.ScrollingFrame.CanvasPosition = Vector2.new(0, 0)
		local saveCatalog = instance:FindFirstChild("SaveCatalog")

		if saveCatalog ~= nil and instance.Visible then
			instance.Catalog.Visible = true
			saveCatalog.Visible = false
		end
	end))

	if instance.Visible and backButton.Visible then
		if not v2 then
			v2 = BackActionRouter.Bind(function()
				component:SetCategory(nil)
			end)
		end
	elseif v2 then
		v2()
		v2 = nil
	end

	instance.Catalog.Header.CategoryTabs.BackButton.MouseButton1Click:Connect(function()
		component:SetCategory(nil)
	end)
	Remotes.connect(VehicleEvents.PLAYER_SPAWNED_VEHICLE, function(_)
		carTimer.Value = true
		task.spawn(function()
			CarTimerEvent()
		end)
	end)
	VehicleController.OnNoMotorVehicleExited:Connect(function()
		NoMotorVehicleRequest()
	end)
	local saveCatalog = instance:FindFirstChild("SaveCatalog")
	local saveStates = categoryTabs:FindFirstChild("SaveStates")

	if PlayerFlag.IsEnabled("vehicle-save-catalog") and saveCatalog ~= nil and saveStates ~= nil then
		saveStates.Visible = true
		saveCatalog.Visible = false
		self._Janitor:Add(saveStates.Activated:Connect(function()
			self:ShowSaves()
		end))
		VehicleSaveStates:WaitForInstance(saveCatalog.Container.ScrollingFrame):andThen(function(object2)
			object2:SetReturnCallback(function()
				instance.Catalog.Visible = true
				saveCatalog.Visible = false
			end)
			object2:SetSource("MainButton")
		end)
		local categoryTabs2 = saveCatalog.Header.CategoryTabs
		local teleportHome = categoryTabs2:FindFirstChild("TeleportHome")

		if teleportHome ~= nil then
			teleportHome:RemoveTag("HouseTeleportHome")
			teleportHome:AddTag("VehicleTeleportHome")
			teleportHome.Visible = true
		end

		local viewProps = categoryTabs2:FindFirstChild("ViewProps")

		if viewProps ~= nil then
			viewProps:SetAttribute("TargetPanel", "VehicleProps")
			viewProps.Visible = true
		end

		local subtleSaleButton = categoryTabs2:FindFirstChild("SubtleSaleButton")

		if subtleSaleButton ~= nil then
			subtleSaleButton.Visible = false
		end

		self._Janitor:Add(categoryTabs2.BackButton.Activated:Connect(function()
			instance.Catalog.Visible = true
			saveCatalog.Visible = false
		end))
		local close = categoryTabs2:FindFirstChild("Close")

		if close ~= nil then
			self._Janitor:Add(close.Activated:Connect(function()
				PanelController.Close("MainGUIHandler", "MainVehicleMenu")
			end))
		end
	else
		if saveCatalog ~= nil then
			saveCatalog:Destroy()
		end

		if saveStates ~= nil then
			saveStates.Visible = false
		end

		local vehicleSavePicker = instance:FindFirstChild("VehicleSavePicker")

		if vehicleSavePicker ~= nil then
			vehicleSavePicker:Destroy()
		end
	end
end

function v:ShowSaves(p2)
	local saveCatalog = self.Instance:FindFirstChild("SaveCatalog")

	if saveCatalog == nil then
		return
	end

	VehicleSaveStates:WaitForInstance(saveCatalog.Container.ScrollingFrame):andThen(function(object)
		if p2 ~= nil then
			object:SetSource(p2)
		end

		object:Refresh()
	end)
	self.Instance.Catalog.Visible = false
	saveCatalog.Visible = true
end

function v:Stop()
	self._Janitor:Destroy()
end

return v