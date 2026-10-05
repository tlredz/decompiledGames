local StatsUI = {}
local localPlayer = game.Players.LocalPlayer
local _ = localPlayer.PlayerGui
local Client = require(localPlayer.PlayerScripts.Client)
local statBars = Client.Interface.StatBars
local hungerBar = statBars.HungerBar
local batteryBar = statBars.BatteryBar
local v = false
local count = 0

function FlashRedBar(p)
	if p and not v then
		v = true
		count += 1
		local v2 = count
		hungerBar.Bar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		task.spawn(function()
			while v and count == v2 do
				wait(1.75)

				if v and count == v2 then
					hungerBar.Bar.Visible = false
				end

				wait(0.25)

				if count == v2 then
					hungerBar.Bar.Visible = true
				end
			end
		end)
	elseif not p and v then
		v = false
		hungerBar.Bar.BackgroundColor3 = Color3.fromRGB(255, 123, 57)

		if localPlayer:GetAttribute("Temperature") and localPlayer:GetAttribute("Temperature") <= 0 then
			hungerBar.Bar.BackgroundColor3 = Color3.fromRGB(102, 165, 247)
		end
	end
end

function UpdateHunger()
	local hunger = localPlayer:GetAttribute("Hunger") or 100
	local v2 = math.clamp(hunger / 200, 0, 1)
	hungerBar.Bar.Size = UDim2.new(v2, 0, 1, 0)

	if hungerBar.Bar.Size.X.Scale <= 0.15 then
		FlashRedBar(true)
	else
		FlashRedBar(false)
	end

	if localPlayer:GetAttribute("Class") == "Feaster" then
		local v3 = 200 * Client.GlobalSettings.FeasterMaxHunger
		local v4 = math.clamp((hunger - 200) / (v3 - 200), 0, 1)
		hungerBar.OverEatBackground.Visible = true

		local function setBarFill(p)
			local v5 = math.clamp(p * 0.145, 0.001, 1)
			hungerBar.OverEatBar.ClipsDescendants = true
			hungerBar.OverEatBar.Size = UDim2.new(v5, 0, 1, 0)
			hungerBar.OverEatBar.Fill.Size = UDim2.new(1 / v5, 0, 1, 0)
		end

		if v4 > 0 then
			setBarFill(v4)
			hungerBar.OverEatBar.Visible = true
			hungerBar.OverEatBackground.ImageColor3 = Color3.fromRGB(255, 0, 0)
			hungerBar.OverEatBackground.ImageTransparency = 0
			hungerBar.Bar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		else
			hungerBar.OverEatBar.Visible = false
			hungerBar.OverEatBackground.ImageColor3 = Color3.fromRGB(255, 72, 0)
			hungerBar.OverEatBackground.ImageTransparency = 0.5
			hungerBar.Bar.BackgroundColor3 = Color3.fromRGB(255, 123, 57)
		end
	end
end

localPlayer:GetAttributeChangedSignal("Hunger"):Connect(UpdateHunger)
UpdateHunger()

function StatsUI.HideBar()
	batteryBar.Visible = false
end

function UpdateBattery()
	local battery = localPlayer:GetAttribute("Battery") or 60

	if (localPlayer:GetAttribute("MaxBattery") or 60) > 65 then
		local v2 = battery / 100
		batteryBar.DeadSpace.Visible = false
		batteryBar.Bar.Size = UDim2.new(math.clamp(v2, 0, 1), 0, 1, 0)
	else
		batteryBar.DeadSpace.Visible = true
		local v2 = battery / 60
		batteryBar.Bar.Size = UDim2.new(math.clamp(v2 * 0.6, 0, 1), 0, 1, 0)
	end
end

function FakeUpdateBattery(p, p2)
	if p2 > 65 then
		local v2 = p / 100
		batteryBar.DeadSpace.Visible = false
		batteryBar.Bar.Size = UDim2.new(math.clamp(v2, 0, 1), 0, 1, 0)
	else
		batteryBar.DeadSpace.Visible = true
		local v2 = p / 60
		batteryBar.Bar.Size = UDim2.new(math.clamp(v2 * 0.6, 0, 1), 0, 1, 0)
	end
end

Client.Events.ShowFlashlight:Connect(function(p, p2, p3)
	if p or not p and batteryBar.Visible then
		FakeUpdateBattery(p2, p3)
		batteryBar.Visible = true
	end
end)
Client.Events.HideFlashlight:Connect(function()
	if not Client.InventoryHandler.GetCurrentlyEquipped() or Client.InventoryHandler.GetCurrentlyEquipped() and Client.InventoryHandler.GetCurrentlyEquipped():GetAttribute("ToolName") ~= "Flashlight" then
		batteryBar.Visible = false
	end
end)
localPlayer:GetAttributeChangedSignal("Battery"):Connect(UpdateBattery)
localPlayer:GetAttributeChangedSignal("MaxBattery"):Connect(UpdateBattery)
UpdateBattery()
return StatsUI