local RobuxGamepassUnlockedController = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local PopupQueue = require(ReplicatedStorage.Modules.Client.UI.PopupQueue)
local Remotes = require(ReplicatedStorage.Packages.Remotes)

function RobuxGamepassUnlockedController.FrameworkInit() end

function RobuxGamepassUnlockedController.FrameworkStart()
	local expect = ReplicatedDataController.GetReplicatedDataPromise():expect()

	if expect.plus or not Players.LocalPlayer.HasRobloxSubscription then
		if expect.plus ~= Players.LocalPlayer.HasRobloxSubscription then
			Remotes.fireServer("SetPlus")
		end
	else
		PopupQueue.RegisterHandler("MainGUIHandler", "RobuxGamepassUnlocked", function()
			TelemetryController.SendClientInteraction("robuxPassPopupShown")
			Remotes.fireServer("SetPlus")
			local purchaseSFX = Players.LocalPlayer.PlayerGui:FindFirstChild("PurchaseSFX")

			if purchaseSFX ~= nil then
				purchaseSFX:Play()
			end
		end)
		PopupQueue.Dispatch("MainGUIHandler", "RobuxGamepassUnlocked")
	end
end

function RobuxGamepassUnlockedController.HandlePlus()
	PopupQueue.RegisterHandler("MainGUIHandler", "RobuxGamepassUnlocked", function()
		TelemetryController.SendClientInteraction("robuxPassPopupShown")
		Remotes.fireServer("SetPlus")
		local purchaseSFX = Players.LocalPlayer.PlayerGui:FindFirstChild("PurchaseSFX")

		if purchaseSFX ~= nil then
			purchaseSFX:Play()
		end

		purchaseSFX:Play()
	end)
	PopupQueue.Dispatch("MainGUIHandler", "RobuxGamepassUnlocked")
end

return RobuxGamepassUnlockedController