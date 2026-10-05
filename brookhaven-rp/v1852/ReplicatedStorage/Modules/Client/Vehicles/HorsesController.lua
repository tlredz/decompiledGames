local createVector = vector.create
local HorsesController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local CategoryItem = require(ReplicatedStorage.Modules.Shared.Item.CategoryItem)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local VehicleMiddleware = require(ReplicatedStorage.Modules.Shared.Item.Middleware.VehicleMiddleware)
local Object = require(ReplicatedStorage.Modules.Shared.Item.Object)
local v = false
local v2 = false
local v3 = false
local v4 = false
local v5 = false
local v6 = false
local v7 = false
local _1Ca1r = nil
local v8 = false
local mainVehicleMenu = nil
local noCarsRegions = nil
local carTimer = nil
local carTimerWait = nil

function CarTimerEvent()
	if carTimer.Value == true then
		if v4.IsOwned(v6.VIP) then
			carTimerWait.Value = v5.VIPHouseTimer
		else
			carTimerWait.Value = v5.CarCoolDown
		end

		while carTimerWait.Value > 0 do
			carTimerWait.Value -= 1
			local v9 = math.floor(carTimerWait.Value % 60)
			local formatted = ("%i:%.2i"):format(math.floor(carTimerWait.Value / 60), v9)
			mainVehicleMenu.Catalog.Header.CategoryTabs.Cooldown.InnerFrame.CarTimer1.Text = "Please wait: " .. formatted .. ""
			task.wait(1)

			if not (carTimerWait.Value <= 0) then
				continue
			end

			carTimer.Value = false
			mainVehicleMenu.Catalog.Header.CategoryTabs.Cooldown.Visible = false
		end
	end
end

function HorsesController.FrameworkInit()
	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
	v = UnlockableController
	local RequirementBehaviors = require(ReplicatedStorage.Modules.Shared.RequirementBehaviors)
	v2 = RequirementBehaviors
	local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
	v3 = NotificationController
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
	v4 = GamepassController
	local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
	v6 = Gamepasses
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v7 = PanelController
end

function HorsesController.FrameworkStart()
	local LegacyGame8Settings = require(ReplicatedStorage.Modules.Client.UI.LegacyGame8Settings)
	v5 = LegacyGame8Settings
	_1Ca1r = ReplicatedStorage.RE:WaitForChild("1Ca1r")
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local mainGUIHandler = playerGui:WaitForChild("MainGUIHandler")
	noCarsRegions = ReplicatedStorage:WaitForChild("NoCarsRegions")
	mainVehicleMenu = mainGUIHandler:WaitForChild("MainVehicleMenu")
	local player8Handler = playerGui:WaitForChild("Player8Handler")
	carTimer = player8Handler:WaitForChild("CarTimer")
	carTimerWait = player8Handler:WaitForChild("CarTimerWait")
end

function HorsesController.IsOnStreet()
	for _, descendant in noCarsRegions:GetDescendants(), nil, nil do
		if not (descendant.className == "Part" and descendant.Spawnable.Value == false) then
			continue
		end

		local region = Region3.new(descendant.Position - descendant.Size / 2, descendant.Position + descendant.Size / 2)
		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Include
		overlapParams.FilterDescendantsInstances = { Players.LocalPlayer.Character }
		local partBoundsInBox = workspace:GetPartBoundsInBox(region.CFrame, region.Size, overlapParams)

		for _, v9 in partBoundsInBox do
			if v9:FindFirstAncestor(Players.LocalPlayer.Name) then
				return true
			end
		end
	end

	return false
end

function HorsesController.IsOnOcean()
	local filterDescendantsInstances = { Players.LocalPlayer.Character }
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = filterDescendantsInstances

	if #workspace:GetPartBoundsInBox(
		workspace.WorkspaceCom["001_OceanSpawns"].OceanWest.CFrame,
		createVector(7029, 400, 1987),
		overlapParams
	) > 0 or #workspace:GetPartBoundsInBox(
		workspace.WorkspaceCom["001_OceanSpawns"].OceanEast.CFrame,
		createVector(7029, 400, 1987),
		overlapParams
	) > 0 then
		return true
	end

	if #workspace:GetPartBoundsInBox(
		workspace.WorkspaceCom["001_OceanSpawns"].OceanNorth.CFrame,
		createVector(7029, 400, 1987),
		overlapParams
	) > 0 then
		return true
	end

	return #workspace:GetPartBoundsInBox(
		workspace.WorkspaceCom["001_OceanSpawns"].OceanSouth.CFrame,
		createVector(7029, 400, 1987),
		overlapParams
	) > 0
end

function HorsesController.TrySpawnVehicle(p: string, p2: string)
	if v8 or not (Players.LocalPlayer and Players.LocalPlayer.Character) then
		return false
	end

	v8 = true
	task.delay(2, function()
		v8 = false
	end)
	local character = Players.LocalPlayer.Character
	local humanoid = character:WaitForChild("Humanoid")

	if not humanoid or humanoid.Sit then
		return false
	end

	if character.HumanoidRootPart:FindFirstChild("Drone") or character:FindFirstChild(Players.LocalPlayer.Name .. "Horse") or Players.LocalPlayer.Character:FindFirstChild("ClientToClient") or character:FindFirstChild("Chute") or character:FindFirstChild("NoMotorVehicleModel") then
		return false
	end

	local item = ItemRegistry.GetItem(p, VehicleMiddleware.VehicleItem)

	if not Object.InstanceOf(item, CategoryItem) or item:GetCategory() ~= "HorseCategory" then
		warn("Only Horses were ported to use this spawner")
		return false
	end

	if HorsesController.IsOnStreet() then
		v3.Notify("Cannot spawn at location.")
		return false
	end

	if HorsesController.IsOnOcean() then
		v3.Notify("Cannot spawn at location.")
		return false
	end

	if carTimer.Value == true then
		mainVehicleMenu.Catalog.Header.CategoryTabs.Cooldown.Visible = true
		return false
	end

	_1Ca1r:FireServer("PickingCar", p, p2)
	carTimer.Value = true
	v7.Close("MainGUIHandler", "MainVehicleMenu")
	task.spawn(CarTimerEvent)
	return true
end

return HorsesController