local GemActivateClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local gemActivateMenu = nil
local totalGems = 0
local mouseButton1DownConnection = nil
local v = {
	["Weather Machine"] = function(p)
		if os.time() - Client.WeatherMachineClient.LastScan < Client.WeatherMachineClient.TimeBetweenScans then
			return
		end

		local v2 = Client.Events.RequestClearWeather:InvokeServer(p)

		if v2 and v2.Success then
			Client.WeatherMachineClient.LastScan = os.time()
			Client.WeatherMachineClient.onScanSuccess(p)
		end
	end,
	["Respawn Capsule"] = function(p)
		Client.Events.RequestRechargeRespawnBeacon:FireServer(p)
		Client.RespawnBeaconClient.PlayGemAddedParticles(p)
	end,
	["Temporal Accelerometer"] = function(p)
		Client.Events.RequestActivateNightSkipMachine:FireServer(p)
	end
}
local flag = true

function DoErrorMessage(p, p2)
	if flag then
		Client.PopUpUI.AddPopUp(p2, "warning")
		flag = false
		task.spawn(function()
			for _ = 1, 3 do
				p.TextColor3 = Color3.fromRGB(255, 0, 0)
				wait(0.3)
				p.TextColor3 = Color3.fromRGB(255, 255, 255)
				wait(0.3)
			end

			p.TextColor3 = Color3.fromRGB(255, 0, 0)
		end)
		task.spawn(function()
			wait(2.1)
			p.TextColor3 = Color3.fromRGB(255, 255, 255)
			flag = true
		end)
	end
end

function AttemptPurchase(p, p2)
	local totalGems2 = workspace.Map.Campground:GetAttribute("TotalGems")

	if not (p2 <= totalGems2) then
		DoErrorMessage(gemActivateMenu.Amount.GemAmount, "not enough gems")
		return
	end

	workspace.Map.Campground:SetAttribute("TotalGems", totalGems2 - p2)
	v[p.Name](p)
	CloseWindow()
end

function CloseWindow()
	gemActivateMenu.Visible = false

	if mouseButton1DownConnection then
		mouseButton1DownConnection:Disconnect()
	end
end

function GemActivateClient.OpenMenu(instance, value)
	gemActivateMenu.Visible = true
	local gemPrice = instance:GetAttribute("GemPrice") or instance:GetAttribute("RechargeCost") or instance:GetAttribute("UseCost") or value or 1
	gemActivateMenu.Amount.Frame.BuyButton.PriceLabel.Text = gemPrice == 1 and "( " .. gemPrice .. " gem )" or "( " .. gemPrice .. " gems )"

	if mouseButton1DownConnection then
		mouseButton1DownConnection:Disconnect()
	end

	mouseButton1DownConnection = gemActivateMenu.Amount.Frame.BuyButton.MouseButton1Down:Connect(function()
		Client.Sound.Play("KeyPress", {
			Duplicate = true
		})
		AttemptPurchase(instance, gemPrice)
	end)
end

Client.Events.DeclineGem:Connect(function(totalGems2)
	workspace.Map.Campground:SetAttribute("TotalGems", totalGems2)
end)

function GemActivateClient.Init()
	task.spawn(function()
		gemActivateMenu = Client.Interface.GemActivateMenu
		workspace.Map.Campground:GetAttributeChangedSignal("TotalGems"):Connect(function()
			gemActivateMenu.Amount.GemAmount.Text = workspace.Map.Campground:GetAttribute("TotalGems")
		end)
		totalGems = workspace.Map.Campground:GetAttribute("TotalGems") or 0
		gemActivateMenu.Amount.GemAmount.Text = totalGems
		gemActivateMenu.CloseButton.MouseButton1Down:Connect(function()
			Client.Sound.Play("CloseButton", {
				Duplicate = true
			})
			CloseWindow()
		end)
	end)
end

return GemActivateClient