local TweenService = game:GetService("TweenService")
local services = game.ReplicatedStorage.Services
require(services:WaitForChild("Table"))
local Player = require(services:WaitForChild("Player"))
local SFX = game.SoundService:WaitForChild("SFX")
local _ = game.ReplicatedStorage.Remotes
local Roulette = {}

function Roulette.RollPlayers(_, p)
	local main = game.Players.LocalPlayer.PlayerGui:WaitForChild("Main")
	local clone = script:WaitForChild("Roullette"):Clone()
	clone.PlayerRollingHeadline.Visible = true
	local spinFrame = script:WaitForChild("SpinFrame")

	for i = 1, 50 do
		local total = 0

		for _, v in game.Players:GetPlayers() do
			local noSaveData = v:FindFirstChild("NoSaveData")

			if not noSaveData then
				continue
			end

			local oPChance = noSaveData:FindFirstChild("OPChance")

			if oPChance then
				total += oPChance.Value
			end
		end

		local v = math.random(1, total)
		local total2 = 0
		local localPlayer = nil

		for _, v2 in game.Players:GetPlayers() do
			local noSaveData = v2:FindFirstChild("NoSaveData")

			if not noSaveData then
				continue
			end

			local oPChance = noSaveData:FindFirstChild("OPChance")

			if not oPChance then
				continue
			end

			total2 += oPChance.Value

			if v <= total2 then
				localPlayer = v2
			end
		end

		if i == 48 then
			localPlayer = p
		elseif i == 47 and math.random(1, 100) <= 60 then
			localPlayer = game.Players.LocalPlayer
		end

		local clone2 = spinFrame:Clone()
		clone2.Name = localPlayer.DisplayName
		clone2.PictureHolder.Image = Player:FetchPlayerPFP(localPlayer.UserId)
		clone2.LayoutOrder = i
		clone2.ItemName.Text = string.upper(localPlayer.DisplayName)
		clone2.Parent = clone.SpinFrame
		clone2:FindFirstChildOfClass("UIStroke")
		local uIStroke = clone2.ItemName.UIStroke
		uIStroke.Transparency = 0
		uIStroke.Color = Color3.fromRGB(0, 0, 0)
	end

	clone.Parent = main
	local spinFrame2 = clone.SpinFrame
	local tween = TweenService:Create(
		spinFrame2,
		TweenInfo.new(9, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
		{
			CanvasPosition = Vector2.new(spinFrame2.AbsoluteCanvasSize.X - spinFrame2.AbsoluteSize.X, 0)
		}
	)
	SFX.SpinWheel:Play()
	tween:Play()
	tween.Completed:Connect(function()
		task.wait(0.2)
		SFX.DeepBoom:Play()
		SFX.EvilLaugh:Play()
		task.wait(2)
		clone:Destroy()
	end)
end

function Roulette.Roll(_, instance, data)
	if not data then
		warn("No rolling data")
		return
	end

	local main = game.Players.LocalPlayer.PlayerGui:WaitForChild("Main")
	local chance = data.Chance
	local normalShowup = data.NormalShowup
	local nearShowup = data.NearShowup
	local ownedItems = data.OwnedItems
	local dupeAllowed = data.DupeAllowed or true
	local unlockedItem = data.UnlockedItem
	local default = data.Default
	local clone = script:WaitForChild("Roullette"):Clone()
	local spinFrame = script:WaitForChild("SpinFrame")
	local v = {}

	for _, child in pairs(instance:GetChildren()) do
		if chance[child.Name] == nil then
			warn(string.format("there's no rarity folder named %s for %s", child.Name, instance.Name))
		else
			for _, child2 in pairs(child:GetChildren()) do
				if not (child2.Name ~= default and (not string.find(ownedItems.Value, child2.Name) or dupeAllowed == true)) then
					continue
				end

				table.insert(v, { child.Name, chance[child.Name] })
				break
			end
		end
	end

	table.sort(v, function(a, b)
		return a[2] < b[2]
	end)
	local total = 0

	for _, v2 in pairs(v) do
		total += v2[2]
	end

	local v2 = math.random(1, total * 100)
	local total2 = 0

	for _, v3 in pairs(v) do
		total2 += v3[2] * 100

		if not (v2 <= total2) then
			continue
		end

		local _ = v3[1]
		break
	end

	local children = {}

	for _, v3 in pairs(v) do
		local child = instance:FindFirstChild(v3[1])

		for _, child2 in pairs(child:GetChildren()) do
			if not (child2.Name ~= default and (not string.find(ownedItems.Value, child2.Name) or dupeAllowed == true)) then
				continue
			end

			table.insert(children, child2)
		end
	end

	task.wait()

	for i = 1, 50 do
		local total3 = 0

		for _, v3 in pairs(v) do
			local v4 = v3[1]

			if i >= 45 then
				total3 += nearShowup[v4]
			else
				total3 += normalShowup[v4]
			end
		end

		local v3 = math.random(1, total3 * 10)
		local total4 = 0
		local v4 = nil

		for _, v6 in pairs(v) do
			local v7 = v6[1]
			total4 += (i >= 45 and nearShowup or normalShowup)[v7] * 10

			if not (v3 <= total4) then
				continue
			end

			v4 = v7
			break
		end

		local v6

		if i == 48 then
			v6 = unlockedItem
		else
			local v7 = {}

			for _, v8 in pairs(children) do
				if v8.Parent == instance:FindFirstChild(v4) then
					table.insert(v7, v8)
				end
			end

			v6 = v7[math.random(1, #v7)]
		end

		local clone2 = spinFrame:Clone()
		clone2.Name = v6.Name
		local data2 = v6:FindFirstChild("Data")

		if data2 then
			local imageId = data2:FindFirstChild("ImageId")
			clone2.PictureHolder.Image = imageId and imageId.Value or ""
		end

		clone2.LayoutOrder = i
		clone2.ItemName.Text = string.upper(v6.Name)
		clone2.Parent = clone.SpinFrame
		local uIStroke = clone2:FindFirstChildOfClass("UIStroke")
		local itemName = clone2.ItemName
		local name = v6.Parent.Name

		if name == "Mythical" then
			uIStroke.Color = Color3.fromRGB(255, 85, 255)
			itemName.Mythical.Enabled = true
			clone2.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
		elseif name == "Legendary" then
			uIStroke.Color = Color3.fromRGB(255, 170, 0)
			itemName.Legendary.Enabled = true
			clone2.BackgroundColor3 = Color3.fromRGB(255, 218, 155)
		elseif name == "Rare" then
			uIStroke.Color = Color3.fromRGB(0, 170, 255)
			itemName.Rare.Enabled = true
			clone2.BackgroundColor3 = Color3.fromRGB(155, 222, 255)
		elseif name == "Common" then
			uIStroke.Color = Color3.fromRGB(255, 255, 255)
			itemName.TextColor3 = Color3.fromRGB(126, 126, 126)
		else
			warn("Unknown rarity folder")
		end
	end

	clone.Parent = main
	local spinFrame2 = clone.SpinFrame
	local tween = TweenService:Create(
		spinFrame2,
		TweenInfo.new(7, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
		{
			CanvasPosition = Vector2.new(spinFrame2.AbsoluteCanvasSize.X - spinFrame2.AbsoluteSize.X, 0)
		}
	)
	SFX.SpinWheel:Play()
	tween:Play()
	tween.Completed:Connect(function()
		SFX.Reward:Play()
		local unlockedWeaponReveal = clone:WaitForChild("UnlockedWeaponReveal")
		local unlockedWeaponName = unlockedWeaponReveal:WaitForChild("UnlockedWeaponName")
		local unlockedWeaponRarity = unlockedWeaponName:WaitForChild("UnlockedWeaponRarity")
		unlockedWeaponName.Text = string.upper(unlockedItem.Name)
		local name = unlockedItem.Parent.Name

		if name == "Mythical" then
			unlockedWeaponName.Mythical.Enabled = true
			unlockedWeaponRarity.Mythical.Enabled = true
			unlockedWeaponRarity.Text = "MYTHICAL"
			unlockedWeaponReveal.Mythical.Enabled = true
		elseif name == "Legendary" then
			unlockedWeaponName.Legendary.Enabled = true
			unlockedWeaponRarity.Legendary.Enabled = true
			unlockedWeaponRarity.Text = "LEGENDARY"
			unlockedWeaponReveal.Legendary.Enabled = true
		elseif name == "Rare" then
			unlockedWeaponName.Rare.Enabled = true
			unlockedWeaponRarity.Rare.Enabled = true
			unlockedWeaponRarity.Text = "EPIC"
			unlockedWeaponReveal.Rare.Enabled = true
		elseif name == "Common" then
			unlockedWeaponName.TextColor3 = Color3.fromRGB(250, 250, 250)
			unlockedWeaponRarity.TextColor3 = Color3.fromRGB(250, 250, 250)
			unlockedWeaponRarity.Text = "COMMON"
			unlockedWeaponReveal.Common.Enabled = true
		end

		unlockedWeaponReveal.Visible = true
		task.wait(3)
		clone:Destroy()
		unlockedWeaponReveal.Visible = false

		for _, v3 in pairs({ unlockedWeaponName, unlockedWeaponRarity, unlockedWeaponReveal }) do
			for _, uIGradient in pairs(v3:GetChildren()) do
				if uIGradient:IsA("UIGradient") then
					uIGradient.Enabled = false
				end
			end
		end

		for _, frame in pairs(spinFrame2:GetChildren()) do
			if frame:IsA("Frame") then
				frame:Destroy()
			end
		end
	end)
end

return Roulette