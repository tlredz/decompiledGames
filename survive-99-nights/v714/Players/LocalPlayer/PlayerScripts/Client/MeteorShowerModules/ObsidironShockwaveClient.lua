local ObsidironShockwaveClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local meteorBar = nil
local images = {}
local inventory = nil
local armour = nil
local v = false
local TweenService = game:GetService("TweenService")

function IsObsidironActive()
	for _, child in pairs(armour:GetChildren()) do
		if child:GetAttribute("ShockwaveChargeRatio") then
			return true
		end
	end

	local currentlyEquipped = Client.InventoryHandler.GetCurrentlyEquipped()

	if currentlyEquipped and currentlyEquipped:GetAttribute("ShockwaveChargeRatio") then
		return true
	end

	return false
end

function RefreshIcons()
	if not meteorBar then
		return
	end

	local v2 = { inventory, armour }
	local v3 = {}

	for _, v4 in pairs(v2) do
		for _, child in pairs(v4:GetChildren()) do
			if child:GetAttribute("ShockwaveChargeRatio") then
				v3[child.Name] = true
			end
		end
	end

	for k, v4 in pairs(images) do
		v4.Visible = v3[k] == true
	end

	meteorBar.Visible = IsObsidironActive()
end

function FlashBar()
	v = true

	while localPlayer:GetAttribute("ShockwaveCharge") >= 100 do
		TweenService:Create(meteorBar.Bar, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			BackgroundColor3 = Color3.fromRGB(255, 81, 0)
		}):Play()
		task.wait(0.1)

		if localPlayer:GetAttribute("ShockwaveCharge") < 100 then
			break
		end

		TweenService:Create(meteorBar.Bar, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			BackgroundColor3 = Color3.fromRGB(255, 213, 0)
		}):Play()
		task.wait(0.1)
	end

	meteorBar.Bar.BackgroundColor3 = Color3.fromRGB(255, 213, 0)
	v = false
end

function UpdateChargeBar()
	local shockwaveCharge = localPlayer:GetAttribute("ShockwaveCharge") or 0
	local v2 = math.clamp(shockwaveCharge / 100, 0, 1)
	meteorBar.Bar.Size = UDim2.new(v2, 0, 1, 0)

	if shockwaveCharge >= 100 and not v then
		task.spawn(function()
			FlashBar()
		end)
	end
end

function ObsidironShockwaveClient.Init()
	task.spawn(function()
		meteorBar = Client.Interface.StatBars.ExtraBars.MeteorBar

		for _, image in pairs(meteorBar.IconHolder:GetChildren()) do
			if not (image:IsA("ImageLabel") and image.Name:sub(1, 4) == "Icon") then
				continue
			end

			images[image.Name:sub(5)] = image
		end

		inventory = localPlayer:WaitForChild("Inventory")
		armour = localPlayer:WaitForChild("Armour")
		local v2 = { inventory, armour }

		for _, v3 in pairs(v2) do
			v3.ChildAdded:Connect(RefreshIcons)
			v3.ChildRemoved:Connect(RefreshIcons)
		end

		Client.Events.EquippedItemChanged:Connect(RefreshIcons)
		RefreshIcons()
		localPlayer:GetAttributeChangedSignal("ShockwaveCharge"):Connect(UpdateChargeBar)
		UpdateChargeBar()
	end)
end

return ObsidironShockwaveClient