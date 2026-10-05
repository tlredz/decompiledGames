local localPlayer = game.Players.LocalPlayer
local parent = script.Parent
local remotes = game.ReplicatedStorage.Remotes
game:GetService("MarketplaceService")
local SFX = game.SoundService.SFX
local Functions = require(game.ReplicatedStorage.Functions)
local TweenService = game:GetService("TweenService")
require(game.ReplicatedStorage.GameData.Monetization)
localPlayer:WaitForChild("SavedData"):WaitForChild("Cash")
local ownedWeapons = localPlayer:WaitForChild("SavedData"):WaitForChild("OwnedWeapons")
local normalCrate = workspace:WaitForChild("NormalCrate")
local premiumCrate = workspace:WaitForChild("PremiumCrate")
local buyPrompt = normalCrate:WaitForChild("Base"):WaitForChild("BuyPrompt")
local buyPrompt2 = premiumCrate:WaitForChild("Base"):WaitForChild("BuyPrompt")
local spinWeaponFrame = script:WaitForChild("SpinWeaponFrame")
local spinFrame = parent:WaitForChild("SpinFrame")
local PolicyService = game:GetService("PolicyService")
local _ = PolicyService:GetPolicyInfoForPlayerAsync(localPlayer).ArePaidRandomItemsRestricted

function OpenCrate(data, p, p2, p3)
	local ownedItems = data.OwnedItems
	local itemFolder = data.ItemFolder
	local rarityTable = data.rarityTable
	buyPrompt.Enabled = false
	buyPrompt2.Enabled = false
	local v = {}

	for _, v2 in pairs(rarityTable) do
		if p[v2.Name] == nil then
			continue
		end

		for _, child in pairs(v2:GetChildren()) do
			if string.find(ownedItems.Value, child.Name) then
				continue
			end

			table.insert(v, { v2.Name, p[v2.Name] })
			break
		end
	end

	table.sort(v, function(a, b)
		return a[2] < b[2]
	end)
	local total = 0

	for _, list in pairs(v) do
		local _, v2 = table.unpack(list)
		total += v2
	end

	local v2 = math.random(1, total * 100)
	local total2 = 0
	local v3 = nil

	for _, list in pairs(v) do
		local v5, v6 = table.unpack(list)
		total2 += v6 * 100

		if not (v2 <= total2) then
			continue
		end

		v3 = v5
		break
	end

	local child = itemFolder:FindFirstChild(v3)
	local children = {}

	for _, child2 in pairs(child:GetChildren()) do
		if not string.find(ownedWeapons.Value, child2.Name) then
			table.insert(children, child2)
		end
	end

	local v5 = children[math.random(1, #children)]
	local children2 = {}

	for _, list in pairs(v) do
		local v6, _ = table.unpack(list)
		local child2 = itemFolder:FindFirstChild(v6)

		for _, child3 in pairs(child2:GetChildren()) do
			if not string.find(ownedWeapons.Value, child3.Name) then
				table.insert(children2, child3)
			end
		end
	end

	task.wait()

	for i = 1, 50 do
		local total3 = 0
		local total4 = 0
		local v6 = nil

		for _, list in pairs(v) do
			local v7, _ = table.unpack(list)

			if i >= 45 then
				total3 += p3[v7]
			else
				total3 += p2[v7]
			end
		end

		local v7 = math.random(1, total3 * 10)

		for _, v9 in pairs(v) do
			local v10 = v9[1]
			local v11

			if i >= 45 then
				v11 = p3[v10]
			else
				v11 = p2[v10]
			end

			total4 += v11 * 10

			if not (v7 <= total4) then
				continue
			end

			v6 = v10
			break
		end

		local v9

		if i == 48 then
			v9 = v5
		else
			local v10 = {}

			for _, v11 in pairs(children2) do
				local child2 = itemFolder:FindFirstChild(v6)

				if v11.Parent == child2 then
					table.insert(v10, v11)
				end
			end

			v9 = v10[math.random(1, #v10)]
		end

		local clone = spinWeaponFrame:Clone()
		clone.Name = v9.Name

		if v9:FindFirstChild("CameraPos") then
			Functions.ShowWeaponInFrame(v9, clone.WeaponImageHolder, true)
		else
			clone.PictureHolder.Image = v9.WeaponData.WeaponImage.Value
		end

		clone.LayoutOrder = i
		local weaponName = clone.WeaponName
		clone.WeaponName.Text = string.upper(v9.Name)
		clone.Parent = spinFrame
		local uIStroke = clone:FindFirstChildOfClass("UIStroke")

		if v9.Parent == Unknown then
			uIStroke.Color = Color3.fromRGB(0, 0, 0)
			clone.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			weaponName.TextColor3 = Color3.fromRGB(0, 0, 0)
			weaponName.UIStroke.Color = Color3.fromRGB(255, 255, 255)
			weaponName.UIStroke.Thickness = 3
		elseif v9.Parent == Legendary then
			uIStroke.Color = Color3.fromRGB(255, 170, 0)
			weaponName.Legendary.Enabled = true
			clone.BackgroundColor3 = Color3.fromRGB(255, 218, 155)
		elseif v9.Parent == Epic then
			uIStroke.Color = Color3.fromRGB(170, 85, 255)
			clone.BackgroundColor3 = Color3.fromRGB(230, 205, 255)
			weaponName.Epic.Enabled = true
		elseif v9.Parent == Common then
			uIStroke.Color = Color3.fromRGB(255, 255, 255)
			weaponName.TextColor3 = Color3.fromRGB(126, 126, 126)
		else
			warn("Cannot find the parent of a weapon")
		end
	end

	parent.Visible = true
	local tween = TweenService:Create(
		spinFrame,
		TweenInfo.new(7, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
		{
			CanvasPosition = Vector2.new(spinFrame.AbsoluteCanvasSize.X - spinFrame.AbsoluteSize.X, 0)
		}
	)
	SFX.SpinWheel:Play()
	tween:Play()
	local completedConnection = nil
	completedConnection = tween.Completed:Connect(function()
		SFX.Reward:Play()
		completedConnection:Disconnect()
		local unlockedWeaponReveal = parent:WaitForChild("UnlockedWeaponReveal")
		local unlockedWeaponName = unlockedWeaponReveal:WaitForChild("UnlockedWeaponName")
		local unlockedWeaponRarity = unlockedWeaponName:WaitForChild("UnlockedWeaponRarity")
		unlockedWeaponName.Text = string.upper(v5.Name)

		if v5.Parent == Unknown then
			unlockedWeaponName.TextColor3 = Color3.fromRGB(0, 0, 0)
			unlockedWeaponName.UIStroke.Color = Color3.fromRGB(255, 255, 255)
			unlockedWeaponName.UIStroke.Thickness = 3
			unlockedWeaponRarity.TextColor3 = Color3.fromRGB(0, 0, 0)
			unlockedWeaponRarity.UIStroke.Color = Color3.fromRGB(255, 255, 255)
			unlockedWeaponRarity.UIStroke.Thickness = 3
			unlockedWeaponRarity.Text = "???"
			unlockedWeaponReveal.Unknown.Enabled = true
		elseif v5.Parent == Legendary then
			unlockedWeaponName.Legendary.Enabled = true
			unlockedWeaponRarity.Legendary.Enabled = true
			unlockedWeaponRarity.Text = "LEGENDARY"
			unlockedWeaponReveal.Legendary.Enabled = true
		elseif v5.Parent == Epic then
			unlockedWeaponName.Epic.Enabled = true
			unlockedWeaponRarity.Epic.Enabled = true
			unlockedWeaponRarity.Text = "EPIC"
			unlockedWeaponReveal.Epic.Enabled = true
		elseif v5.Parent == Common then
			unlockedWeaponName.TextColor3 = Color3.fromRGB(250, 250, 250)
			unlockedWeaponRarity.TextColor3 = Color3.fromRGB(250, 250, 250)
			unlockedWeaponRarity.Text = "COMMON"
			unlockedWeaponReveal.Common.Enabled = true
		end

		unlockedWeaponReveal.Visible = true
		remotes.UnlockWeapon:FireServer(v5.Name)
		task.wait(3)
		parent.Visible = false
		unlockedWeaponReveal.Visible = false

		for _, v6 in pairs({ unlockedWeaponName, unlockedWeaponRarity, unlockedWeaponReveal }) do
			for _, uIGradient in pairs(v6:GetChildren()) do
				if uIGradient:IsA("UIGradient") then
					uIGradient.Enabled = false
				end
			end
		end

		for _, frame in pairs(spinFrame:GetChildren()) do
			if frame:IsA("Frame") then
				frame:Destroy()
			end
		end

		buyPrompt.Enabled = true
		buyPrompt2.Enabled = true
	end)
end

local _ = {
	Unknown = 0.02,
	Legendary = 1,
	Epic = 10,
	Common = 89
}
local _ = {
	Unknown = 1,
	Legendary = 3,
	Epic = 10,
	Common = 86
}
local _ = {
	Unknown = 1,
	Legendary = 10,
	Epic = 30,
	Common = 59
}
localPlayer.PlayerGui:WaitForChild("Main")
local v = {
	Unknown = 0.8,
	Legendary = 10,
	Epic = 90
}
local v2 = {
	Unknown = 1,
	Legendary = 9,
	Epic = 90
}
local v3 = {
	Unknown = 10,
	Legendary = 40,
	Epic = 50
}
remotes.PremiumCrate.OnClientEvent:Connect(function()
	SFX.Purchase:Play()
	task.wait(0.1)
	OpenCrate(v, v2, v3)
end)