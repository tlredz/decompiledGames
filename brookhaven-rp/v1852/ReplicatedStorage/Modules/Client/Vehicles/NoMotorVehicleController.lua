local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local LegacyGame8Settings = require(ReplicatedStorage.Modules.Client.UI.LegacyGame8Settings)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local NoMotorAnimationController = require(ReplicatedStorage.Modules.Client.Vehicles.NoMotorAnimationController)
local noMotorVehicles = LegacyGame8Settings.NoMotorVehicles
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local VehicleMiddleware = require(ReplicatedStorage.Modules.Shared.Item.Middleware.VehicleMiddleware)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local VehicleEvents = require(ReplicatedStorage.Modules.Shared.Game.Vehicles.VehicleEvents)
local localPlayer = Players.LocalPlayer
local NoMotorVehicleController = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getMainGUIHandler()
	return Players.LocalPlayer.PlayerGui:WaitForChild("MainGUIHandler")
end

local function NoMotorVehicleRequest(_, p)
	if p == Enum.UserInputState.Begin then
		NoMotorVehicleController.RemoveNoMotorVehicle()
	end
end

function NoMotorVehicleController.FrameworkInit() end

function NoMotorVehicleController.FrameworkStart()
	local function setVariables() end

	localPlayer.CharacterAdded:Connect(setVariables)
	Remotes.connect(VehicleEvents.NO_MOTOR_VEHICLE_SPAWN_FROM_UPSELL, function(p: string)
		local character = localPlayer.Character

		if character ~= nil then
			local humanoid = character:FindFirstChild("Humanoid")
			local player8Handler = localPlayer.PlayerGui:FindFirstChild("Player8Handler")
			local tempHIP = player8Handler and player8Handler:FindFirstChild("TempHIP")

			if humanoid ~= nil and tempHIP ~= nil then
				tempHIP.Value = humanoid.HipHeight
			end
		end

		NoMotorVehicleController.RequestNoMotorVehicle(p)
	end)
end

function NoMotorVehicleController.RemoveNoMotorVehicle()
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not (humanoid and character:FindFirstChild("NoMotorVehicleModel")) then
		return
	end

	local player8Handler = Players.LocalPlayer.PlayerGui:WaitForChild("Player8Handler")
	ContextActionService:UnbindAction("NoMotorVehicleRequest")
	PanelController.Close("MainGUIHandler", "NoMotorVehicleControl")
	local mainAudio = Players.LocalPlayer.PlayerGui:WaitForChild("MainGUIHandler"):WaitForChild("MainAudio")
	mainAudio.Catalog.Header.ButtonsList.PausePlay.Image = "rbxassetid://118117426385847"
	mainAudio.Visible = false
	noMotorVehicles:FireServer("Delete NoMotorVehicle")
	humanoid.HipHeight = player8Handler.TempHIP.Value
	NoMotorAnimationController.StopAll()
	humanoid.WalkSpeed = 16
end

function NoMotorVehicleController.RequestNoMotorVehicle(p: string, p2: string?, color: Color3?)
	local mainGUIHandler = getMainGUIHandler() -- equivalent call inferred; original call site unknown
	local client2ClientAccept = mainGUIHandler:WaitForChild("Client2Client"):WaitForChild("Client2ClientAccept")
	local player8Handler = Players.LocalPlayer.PlayerGui:WaitForChild("Player8Handler")
	local chatAnimationPlaying = player8Handler:WaitForChild("ChatAnimationPlaying")
	local animationPlaying = player8Handler:WaitForChild("AnimationPlaying")
	local character = localPlayer.Character

	if not character then
		return false
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid or humanoid.WalkSpeed < 1 or animationPlaying.Value or chatAnimationPlaying.Value then
		return false
	end

	if client2ClientAccept.Visible then
		return false
	end

	local item = ItemRegistry.GetItem(p, VehicleMiddleware.VehicleItem)

	if not item then
		return false
	end

	local speedPassNoMotorVehicle = localPlayer.PlayersBag:FindFirstChild("SpeedPassNoMotorVehicle")

	if not speedPassNoMotorVehicle then
		return false
	end

	local noMotor = item.VehicleImpl.NoMotor
	local noMotorAnimated = item.VehicleImpl.NoMotorAnimated == true

	if item:IsUnlockedClient() then
		for _, tool in character:GetChildren() do
			if not (tool:IsA("Tool") and tool:HasTag("PreventNoMotorVehicle")) then
				continue
			end

			NotificationController.Notify("Unequip your tool first!")
			return
		end

		noMotorVehicles:FireServer(p, p2, color)
		NoMotorAnimationController.StopAll()
		local mainAudio = mainGUIHandler:WaitForChild("MainAudio")
		mainAudio.Catalog.Header.ButtonsList.PausePlay.Image = "rbxassetid://118117426385847"

		if noMotor == "BikeAnimation" then
			NoMotorAnimationController.StartSpeedControl("BikeAnimation")
		elseif noMotor == "UnicycleAnimation" then
			NoMotorAnimationController.StartSpeedControl("UnicycleAnimation")
		elseif noMotor == "GirlBikeAnimation" then
			NoMotorAnimationController.StartSpeedControl("GirlBikeAnimation")
		elseif noMotor == "SegwaySmallAnimation" then
			NoMotorAnimationController.Play("SegwaySmallAnimation")
		elseif noMotorAnimated then
			NoMotorAnimationController.StartSpeedControl(noMotor)
		end

		if NoMotorAnimationController.HasAnimation(noMotor) then
			NoMotorAnimationController.Play(noMotor)
		end

		PanelController.Open("MainGUIHandler", "NoMotorVehicleControl")
		humanoid.WalkSpeed = speedPassNoMotorVehicle.Value
		ContextActionService:BindAction(
			"NoMotorVehicleRequest",
			NoMotorVehicleRequest,
			false,
			Enum.KeyCode.E,
			Enum.KeyCode.ButtonX
		)
		LegacyGame8Settings.Car:FireServer("NoMotorVehicleDeleteCar")
		PanelController.Close("MainGUIHandler", "MainVehicleMenu")
	else
		item:OnDenied(NotificationController.NotifyCenter, "NoMotorVehicleController", function()
			NoMotorVehicleController.RequestNoMotorVehicle(p, p2, color)
		end)
	end

	return true
end

return NoMotorVehicleController