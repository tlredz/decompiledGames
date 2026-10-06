local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

repeat
	wait(0.1)
until localPlayer:FindFirstChild("PlayerStats")

local inventory = localPlayer:WaitForChild("Inventory", 30)
local accessories = localPlayer:WaitForChild("Accessories", 30)
local material = localPlayer:WaitForChild("PlayerStats"):WaitForChild("Material", 30)
local fruits = localPlayer:WaitForChild("Fruits", 30)
local collectible = localPlayer:WaitForChild("PlayerStats"):WaitForChild("Collectible", 30)
local HttpService = game:GetService("HttpService")
local parent = script.Parent
local parent2 = parent.Parent.Parent
local fruits2 = parent.Fruits
local material2 = parent.Material
local swords = parent.Swords
local accessories2 = parent.Accessories
local collectible2 = parent.Collectible
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SwordList = require(ReplicatedStorage.Chest.Modules.SwordList)
local AccessoriesList = require(ReplicatedStorage.Chest.Modules.AccessoriesList)
local FruitList = require(ReplicatedStorage.Chest.Modules.FruitList)
local CollectibleList = require(ReplicatedStorage.Chest.Modules.CollectibleList)
local DFTier = require(ReplicatedStorage.Chest.Modules.DFTier)
local MaterialList = require(ReplicatedStorage.Chest.Modules.MaterialList)
local CustomNames = require(ReplicatedStorage.Chest.Modules.CustomNames)
local RankUpgradeList = require(ReplicatedStorage.Chest.Modules.RankUpgradeList)
game:GetService("UserInputService")
local information = parent:WaitForChild("Information")
localPlayer:GetMouse()
local scrollingFrameSwords = parent.ScrollingFrameSwords
local scrollingFrameAccessories = parent.ScrollingFrameAccessories
local scrollingFrameFruits = parent.ScrollingFrameFruits
local scrollingFrameMaterial = parent.ScrollingFrameMaterial
local scrollingFrameCollectible = parent.ScrollingFrameCollectible
local playerStats = localPlayer:WaitForChild("PlayerStats", 30)
local fruitStore = playerStats:WaitForChild("FruitStore", 30)
local etcData = playerStats:WaitForChild("EtcData", 30)
local clone = nil
local clone2 = nil
local name = nil
local TierColor = require(ReplicatedStorage.Chest.Modules.TierColor)
local TierImage = require(ReplicatedStorage.Chest.Modules.TierImage)
local textBox = parent.FunctionBar.SearchBar:WaitForChild("TextBox")
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = "All"
local v7 = true
game:GetService("MarketplaceService")
local v8 = {}
local v9 = {}
local v10 = {}
local v11 = {}
local v12 = {}
local v13 = {
	Fruit = {},
	Sword = {},
	Material = {},
	Accessory = {},
	Collectible = {}
}

function GetFruitRarity(p)
	for k, list in pairs(DFTier) do
		if string.find(table.concat(list, ","), p) then
			return k
		end
	end
end

local v14 = nil
local v15 = nil
local tierFrame = parent.FunctionBar.TierFrame
local tierButton = parent.FunctionBar.TierButton

function UpdateItemCount()
	local sword = nil
	tierFrame.Fish.Visible = false

	if scrollingFrameSwords.Visible then
		sword = v13.Sword
	elseif scrollingFrameFruits.Visible then
		sword = v13.Fruit
	elseif scrollingFrameMaterial.Visible then
		sword = v13.Material
		tierFrame.Fish.Visible = true
	elseif scrollingFrameAccessories.Visible then
		sword = v13.Accessory
	elseif scrollingFrameCollectible.Visible then
		sword = v13.Collectible
	end

	if not sword then
		return
	end

	for _, button in ipairs(parent.FunctionBar.TierFrame:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		local v16 = sword[button.Name] or nil

		if v16 or button.Name == "All" then
			if v16 or button.Name ~= "All" then
				button.Text = `{button.Name} ({v16})`
			else
				local total = 0

				for _, v17 in pairs(sword) do
					total += v17
				end

				button.Text = `{button.Name} ({total})`
			end
		else
			button.Text = button.Name
		end

		if v15 == button.Name or button.Name == "All" and not v15 then
			parent.FunctionBar.TierButton.Text = button.Text
		end
	end
end

function GetRowsColmn()
	local value = localPlayer.PlayerStats.InventoryGridSize.Value
	local v16 = 3
	local v17 = 1.5

	if value == 0 then
		return 2, 1.13
	elseif value == 1 then
		return 3, 1.7
	elseif value == 2 then
		return 4, 2.27
	elseif value == 3 then
		return 5, 2.82
	elseif value == 4 then
		return 6, 3.4
	end

	if value == 5 then
		v16 = 7
		v17 = 4
	end

	return v16, v17
end

function IsObjectMatched(instance)
	local v16 = true

	if v15 then
		local v17 = SwordList[instance.Name] or AccessoriesList[instance.Name] or MaterialList[instance.Name]
		local tier

		if v17 then
			tier = v17.Tier or nil
		end

		if not tier and FruitList[instance.Name] then
			tier = GetFruitRarity(instance.Name)
		end

		local v18 = v15 == "Fish" and v17 and v17.Fish and "Fish" or tier

		if v18 and v18 ~= v15 then
			v16 = nil
		end
	end

	local name2 = instance.Name

	if instance:GetAttribute("FixedName") then
		name2 = instance:GetAttribute("FixedName")
	end

	if v14 and not string.find(string.lower(name2), string.lower(v14)) then
		return nil
	end

	return v16
end

function UpdateSwordViewing()
	local Y = scrollingFrameSwords.CanvasPosition.Y
	local Y2 = scrollingFrameSwords.AbsoluteSize.Y

	for _, v16 in ipairs(v9) do
		if not IsObjectMatched(v16) then
			continue
		end

		local offset = v16.Position.Y.Offset
		v16.Visible = Y <= offset + v16.AbsoluteSize.Y and offset <= Y + Y2
	end
end

function UpdateEquippingWeapons()
	local jSONDecode = HttpService:JSONDecode(etcData.Value)
	local primaryWeapon = jSONDecode.PrimaryWeapon
	local secondaryWeapon = jSONDecode.SecondaryWeapon

	if primaryWeapon == "None" or not primaryWeapon then
		primaryWeapon = nil
	end

	if secondaryWeapon == "None" or not secondaryWeapon then
		secondaryWeapon = nil
	end

	if primaryWeapon then
		local v16 = SwordList[primaryWeapon] or {
			Image = ""
		}
		information.Primary.Icon.Image = v16.Image
	else
		information.Primary.Icon.Image = ""
	end

	if not secondaryWeapon then
		information.Secondary.Icon.Image = ""
		return
	end

	local v16 = SwordList[secondaryWeapon] or {
		Image = ""
	}
	information.Secondary.Icon.Image = v16.Image
end

function UpdateSwordLayouts()
	local v16, v17 = GetRowsColmn()
	table.sort(v9, function(a, b)
		return (a:GetAttribute("LayoutOrder") or 1) < (b:GetAttribute("LayoutOrder") or 1)
	end)
	local v18 = (scrollingFrameSwords.AbsoluteSize.X - scrollingFrameSwords.ScrollBarThickness) / v16
	local v19 = scrollingFrameSwords.AbsoluteSize.Y / v17
	local Y = scrollingFrameSwords.CanvasPosition.Y
	local Y2 = scrollingFrameSwords.AbsoluteSize.Y
	local v20 = 1

	for _, v21 in ipairs(v9) do
		if IsObjectMatched(v21) then
			local v22 = math.floor((v20 - 1) / v16)
			local v23 = (v20 - 1) % v16
			v21.Size = UDim2.fromOffset(v18, v19)
			v21.Position = UDim2.fromOffset(v18 * v23, v19 * v22)
			local offset = v21.Position.Y.Offset
			v21.Visible = Y <= offset + v21.AbsoluteSize.Y and offset <= Y + Y2
			v20 += 1
		else
			v21.Visible = nil
		end
	end

	local v21 = v19 * math.ceil((v20 - 1) / v16)
	scrollingFrameSwords.CanvasSize = UDim2.fromOffset(0, v21)
	UpdateItemCount()
end

function UpdateAccessoryViewing()
	local Y = scrollingFrameAccessories.CanvasPosition.Y
	local Y2 = scrollingFrameAccessories.AbsoluteSize.Y

	for _, v16 in ipairs(v11) do
		if not IsObjectMatched(v16) then
			continue
		end

		local offset = v16.Position.Y.Offset
		v16.Visible = Y <= offset + v16.AbsoluteSize.Y and offset <= Y + Y2
	end
end

function UpdateAccessoryLayouts()
	local v16, v17 = GetRowsColmn()
	table.sort(v11, function(a, b)
		return (a:GetAttribute("LayoutOrder") or 1) < (b:GetAttribute("LayoutOrder") or 1)
	end)
	local v18 = (scrollingFrameAccessories.AbsoluteSize.X - scrollingFrameAccessories.ScrollBarThickness) / v16
	local v19 = scrollingFrameAccessories.AbsoluteSize.Y / v17
	local Y = scrollingFrameAccessories.CanvasPosition.Y
	local Y2 = scrollingFrameAccessories.AbsoluteSize.Y
	local v20 = 1

	for _, v21 in ipairs(v11) do
		if IsObjectMatched(v21) then
			local v22 = math.floor((v20 - 1) / v16)
			local v23 = (v20 - 1) % v16
			v21.Size = UDim2.fromOffset(v18, v19)
			v21.Position = UDim2.fromOffset(v18 * v23, v19 * v22)
			local offset = v21.Position.Y.Offset
			v21.Visible = Y <= offset + v21.AbsoluteSize.Y and offset <= Y + Y2
			v20 += 1
		else
			v21.Visible = nil
		end
	end

	local v21 = v19 * math.ceil((v20 - 1) / v16)
	scrollingFrameAccessories.CanvasSize = UDim2.fromOffset(0, v21)
	UpdateItemCount()
end

function UpdateFruitViewing()
	local Y = scrollingFrameFruits.CanvasPosition.Y
	local Y2 = scrollingFrameFruits.AbsoluteSize.Y

	for _, v16 in ipairs(v8) do
		if not IsObjectMatched(v16) then
			continue
		end

		local offset = v16.Position.Y.Offset
		v16.Visible = Y <= offset + v16.AbsoluteSize.Y and offset <= Y + Y2
	end
end

function UpdateFruitLayouts()
	local v16, v17 = GetRowsColmn()
	table.sort(v8, function(a, b)
		return (a:GetAttribute("LayoutOrder") or 1) < (b:GetAttribute("LayoutOrder") or 1)
	end)
	local v18 = (scrollingFrameFruits.AbsoluteSize.X - scrollingFrameFruits.ScrollBarThickness) / v16
	local v19 = scrollingFrameFruits.AbsoluteSize.Y / v17
	local Y = scrollingFrameFruits.CanvasPosition.Y
	local Y2 = scrollingFrameFruits.AbsoluteSize.Y
	local v20 = 1

	for _, v21 in ipairs(v8) do
		if IsObjectMatched(v21) then
			local v22 = math.floor((v20 - 1) / v16)
			local v23 = (v20 - 1) % v16
			v21.Size = UDim2.fromOffset(v18, v19)
			v21.Position = UDim2.fromOffset(v18 * v23, v19 * v22)
			local offset = v21.Position.Y.Offset
			v21.Visible = Y <= offset + v21.AbsoluteSize.Y and offset <= Y + Y2
			v20 += 1
		else
			v21.Visible = nil
		end
	end

	local v21 = v19 * math.ceil((v20 - 1) / v16)
	scrollingFrameFruits.CanvasSize = UDim2.fromOffset(0, v21)
	UpdateItemCount()
end

function UpdateMaterialViewing()
	local Y = scrollingFrameMaterial.CanvasPosition.Y
	local Y2 = scrollingFrameMaterial.AbsoluteSize.Y

	for _, v16 in ipairs(v10) do
		if not IsObjectMatched(v16) then
			continue
		end

		local offset = v16.Position.Y.Offset
		v16.Visible = Y <= offset + v16.AbsoluteSize.Y and offset <= Y + Y2
	end
end

function UpdateMaterialLayouts()
	local v16, v17 = GetRowsColmn()
	table.sort(v10, function(a, b)
		return (a:GetAttribute("LayoutOrder") or 1) < (b:GetAttribute("LayoutOrder") or 1)
	end)
	local v18 = (scrollingFrameMaterial.AbsoluteSize.X - scrollingFrameMaterial.ScrollBarThickness) / v16
	local v19 = scrollingFrameMaterial.AbsoluteSize.Y / v17
	local Y = scrollingFrameMaterial.CanvasPosition.Y
	local Y2 = scrollingFrameMaterial.AbsoluteSize.Y
	local v20 = 1

	for _, v21 in ipairs(v10) do
		if IsObjectMatched(v21) then
			local v22 = math.floor((v20 - 1) / v16)
			local v23 = (v20 - 1) % v16
			v21.Size = UDim2.fromOffset(v18, v19)
			v21.Position = UDim2.fromOffset(v18 * v23, v19 * v22)
			local offset = v21.Position.Y.Offset
			v21.Visible = Y <= offset + v21.AbsoluteSize.Y and offset <= Y + Y2
			v20 += 1
		else
			v21.Visible = nil
		end
	end

	local v21 = v19 * math.ceil((v20 - 1) / v16)
	scrollingFrameMaterial.CanvasSize = UDim2.fromOffset(0, v21)
	UpdateItemCount()
end

function UpdateCollectibleViewing()
	local Y = scrollingFrameCollectible.CanvasPosition.Y
	local Y2 = scrollingFrameCollectible.AbsoluteSize.Y

	for _, v16 in ipairs(v12) do
		if not IsObjectMatched(v16) then
			continue
		end

		local offset = v16.Position.Y.Offset
		v16.Visible = Y <= offset + v16.AbsoluteSize.Y and offset <= Y + Y2
	end
end

function UpdateCollectibleLayouts()
	local v16, v17 = GetRowsColmn()
	table.sort(v12, function(a, b)
		return (a:GetAttribute("LayoutOrder") or 1) < (b:GetAttribute("LayoutOrder") or 1)
	end)
	local v18 = (scrollingFrameCollectible.AbsoluteSize.X - scrollingFrameCollectible.ScrollBarThickness) / v16
	local v19 = scrollingFrameCollectible.AbsoluteSize.Y / v17
	local Y = scrollingFrameCollectible.CanvasPosition.Y
	local Y2 = scrollingFrameCollectible.AbsoluteSize.Y
	local v20 = 1

	for _, v21 in ipairs(v12) do
		if IsObjectMatched(v21) then
			local v22 = math.floor((v20 - 1) / v16)
			local v23 = (v20 - 1) % v16
			v21.Size = UDim2.fromOffset(v18, v19)
			v21.Position = UDim2.fromOffset(v18 * v23, v19 * v22)
			local offset = v21.Position.Y.Offset
			v21.Visible = Y <= offset + v21.AbsoluteSize.Y and offset <= Y + Y2
			v20 += 1
		else
			v21.Visible = nil
		end
	end

	local v21 = v19 * math.ceil((v20 - 1) / v16)
	scrollingFrameCollectible.CanvasSize = UDim2.fromOffset(0, v21)
	UpdateItemCount()
end

function UpdateAllLayouts()
	if scrollingFrameSwords.Visible then
		local success, result = pcall(UpdateSwordLayouts)

		if not success then
			warn(result)
		end
	end

	if scrollingFrameFruits.Visible then
		local success, result = pcall(UpdateFruitLayouts)

		if not success then
			warn(result)
		end
	end

	if scrollingFrameMaterial.Visible then
		local success, result = pcall(UpdateMaterialLayouts)

		if not success then
			warn(result)
		end
	end

	if scrollingFrameAccessories.Visible then
		local success, result = pcall(UpdateAccessoryLayouts)

		if not success then
			warn(result)
		end
	end

	if scrollingFrameCollectible.Visible then
		local success, result = pcall(UpdateCollectibleLayouts)

		if not success then
			warn(result)
		end
	end
end

function UpdateAllViewing()
	if scrollingFrameSwords.Visible then
		local success, result = pcall(UpdateSwordViewing)

		if not success then
			warn(result)
		end
	end

	if scrollingFrameFruits.Visible then
		local success, result = pcall(UpdateFruitViewing)

		if not success then
			warn(result)
		end
	end

	if scrollingFrameMaterial.Visible then
		local success, result = pcall(UpdateMaterialViewing)

		if not success then
			warn(result)
		end
	end

	if scrollingFrameAccessories.Visible then
		local success, result = pcall(UpdateAccessoryViewing)

		if not success then
			warn(result)
		end
	end

	if scrollingFrameCollectible.Visible then
		local success, result = pcall(UpdateCollectibleViewing)

		if not success then
			warn(result)
		end
	end
end

local lastTime = os.clock()
local flag = nil

function BeginScrolling()
	lastTime = os.clock()

	if flag then
		return
	end

	flag = true

	while true do
		task.wait(0.03333333333333333)

		if os.clock() - lastTime > 0.1 then
			break
		end

		UpdateAllViewing()
	end

	flag = nil
	UpdateAllViewing()
end

scrollingFrameSwords:GetPropertyChangedSignal("CanvasPosition"):Connect(BeginScrolling)
scrollingFrameFruits:GetPropertyChangedSignal("CanvasPosition"):Connect(BeginScrolling)
scrollingFrameMaterial:GetPropertyChangedSignal("CanvasPosition"):Connect(BeginScrolling)
scrollingFrameAccessories:GetPropertyChangedSignal("CanvasPosition"):Connect(BeginScrolling)
scrollingFrameCollectible:GetPropertyChangedSignal("CanvasPosition"):Connect(BeginScrolling)
local v16 = true

function ButtonClick(instance, p)
	if not (instance and p and v16) then
		return
	end

	v16 = nil
	local uDim = UDim2.new(0.15, 0, 0.22, 0)
	local uDim2 = UDim2.new(0.1725, 0, 0.253, 0)
	instance.Size = uDim
	TweenService:Create(
		instance,
		TweenInfo.new(0.075, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
		{
			Size = uDim2
		}
	):Play()

	if instance:FindFirstChild("ImageLabel") then
		instance.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
		TweenService:Create(
			instance.ImageLabel,
			TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
			{
				ImageColor3 = Color3.fromRGB(0, 0, 0)
			}
		):Play()
	end

	local _ = instance.Name == "Swords"

	for _, child in pairs(parent:GetChildren()) do
		if child:GetAttribute("FirstButton") then
			if child == instance then
				child.Position = UDim2.new(child.Position.X.Scale, -0.05, 0)
				TweenService:Create(child, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
					Position = UDim2.new(child.Position.X.Scale, 0, -0.065, 0)
				}):Play()
			else
				TweenService:Create(child, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
					Position = UDim2.new(child.Position.X.Scale, 0, -0.05, 0)
				}):Play()
			end
		elseif child:GetAttribute("FirstFrame") then
			if child == p then
				child.Visible = true
			else
				child.Visible = false
			end
		end
	end

	spawn(function()
		wait(0.1)
		v16 = true
	end)
end

local v17 = nil
local children = nil

function InventoryNewItemAlert(visible)
	parent.Swords.Alert.Visible = visible
end

function CollectibleNewItemAlert(visible)
	parent.Collectible.Alert.Visible = visible
end

local copy = nil

function MaterialNewItemAlert(visible)
	parent.Material.Alert.Visible = visible
end

local copy2 = nil

function FruitNewItemAlert(visible)
	fruits2.Alert.Visible = visible
end

local children2 = nil

function AccessoryNewItemAlert(visible)
	parent.Accessories.Alert.Visible = visible
end

local clone3 = nil
local v18 = nil
local enchantLabel = information.Icon.EnchantLabel
local rankUpgrade = information.Icon.RankUpgrade

function TweenColorIcon(instance)
	if not (instance and instance:FindFirstChild("ImageLabel")) then
		return
	end

	instance.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
	TweenService:Create(
		instance.ImageLabel,
		TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
		{
			ImageColor3 = Color3.fromRGB(0, 0, 0)
		}
	):Play()
end

local v19 = nil
local flag2 = nil

function CloseInformation()
	flag2 = true

	if v19 then
		v19:Pause()
		v19 = nil
	end

	v19 = TweenService:Create(information, TweenInfo.new(0.1, Enum.EasingStyle.Quart), {
		Position = UDim2.new(0.8, 0, 0.5, 0)
	})
	v19:Play()
	task.delay(0.15, function()
		v17 = nil
		information.Visible = nil
		flag2 = nil
	end)
end

function Select(value)
	if flag2 then
		return
	end

	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true
		})
	end)

	if clone3 then
		clone3:Destroy()
		clone3 = nil
	end

	rankUpgrade.Visible = nil
	enchantLabel.Visible = nil

	if v17 == value then
		CloseInformation()
		return
	end

	v17 = value

	if v19 then
		v19:Pause()
		v19 = nil
	end

	information.Position = UDim2.new(0.8, 0, 0.5, 0)
	information.Visible = true
	v19 = TweenService:Create(information, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
		Position = UDim2.new(1.17, 0, 0.5, 0)
	})
	v19:Play()
	local jSONDecode = HttpService:JSONDecode(localPlayer.PlayerStats.UpgradeData.Value)
	local jSONDecode2 = HttpService:JSONDecode(playerStats.EnchantWeapon.Value)

	if v18 then
		v18:Destroy()
		v18 = nil
	end

	information.Icon.Size = UDim2.new(0, 0, 0, 0)
	information.Icon.Rotation = 180
	v18 = TweenService:Create(information.Icon, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
		Size = UDim2.new(0.4, 0, 0.367, 0),
		Rotation = 360
	})
	v18:Play()
	information.Equip.Visible = true
	information.Primary.Visible = nil
	information.Secondary.Visible = nil
	information.InfoText.Size = UDim2.new(0.85, 0, 0.17, 0)
	information.NameText.Text = type(value) == "string" and value or value.Name

	if v[value] then
		information.Equip.Visible = nil
		information.Primary.Visible = true
		information.Secondary.Visible = true
		local v20 = jSONDecode[value.Name] or 0

		if v20 >= 1 then
			rankUpgrade.Image = RankUpgradeList[v20].Image
			rankUpgrade.Visible = true
			rankUpgrade:SetAttribute("ItemName", value.Name)
			rankUpgrade:SetAttribute("AccInfo", nil)
			rankUpgrade:SetAttribute("Name", RankUpgradeList[v20].Info)

			if playerStats.Language.Value == "TH" then
				rankUpgrade:SetAttribute("Name", RankUpgradeList[v20].InfoTH)
			end
		end

		if jSONDecode2[value.Name] then
			enchantLabel.Visible = true
			enchantLabel.Image = MaterialList[jSONDecode2[value.Name]].Image
			enchantLabel:SetAttribute("Name", jSONDecode2[value.Name])
		end

		clone3 = script.Highlight:Clone()
		clone3.Parent = v[value]
		v[value].Alert.Visible = false
		local info = SwordList[value.Name].Info or "None"

		if localPlayer.PlayerStats.Language.Value == "TH" then
			info = SwordList[value.Name].InfoTH or "None"
		end

		information.Icon.Image = SwordList[value.Name].Image
		information.TierText.Text = SwordList[value.Name].Tier
		information.TierText.TextColor3 = TierColor[SwordList[value.Name].Tier]
		information.InfoText.Text = info
		local _ = #info / 20 / 10
		local _ = localPlayer.PlayerStats.SwordName.Value == value.Name
	end

	if v2[value] then
		clone3 = script.Highlight:Clone()
		clone3.Parent = v2[value]
		local v20 = jSONDecode[value.Name] or 0
		local info = AccessoriesList[value.Name].Upgrade[v20].Info

		if localPlayer.PlayerStats.Language.Value == "TH" then
			info = AccessoriesList[value.Name].Upgrade[v20].InfoTH
		end

		if v20 >= 1 then
			rankUpgrade.Image = RankUpgradeList[v20].Image
			rankUpgrade.Visible = true
			rankUpgrade:SetAttribute("ItemName", nil)
			rankUpgrade:SetAttribute("AccInfo", info)
			rankUpgrade:SetAttribute("Name", RankUpgradeList[v20].Info)

			if playerStats.Language.Value == "TH" then
				rankUpgrade:SetAttribute("Name", RankUpgradeList[v20].InfoTH)
			end
		end

		information.TierText.Text = AccessoriesList[value.Name].Tier
		information.TierText.TextColor3 = TierColor[AccessoriesList[value.Name].Tier]
		information.InfoText.Text = info
		information.Icon.Image = AccessoriesList[value.Name].Image
		local _ = #info / 20 / 10
		local _ = localPlayer.PlayerStats.Accessory.Value == value.Name
	end

	if v4[value] then
		clone3 = script.Highlight:Clone()
		clone3.Parent = v4[value]
		v4[value].Alert.Visible = false
		local _ = localPlayer.PlayerStats.Language.Value == "TH"
		local text = "Max Storage: " .. playerStats.FruitStorage.Value
		information.TierText.Text = GetFruitRarity(value) or "Common"
		information.TierText.TextColor3 = TierColor[GetFruitRarity(value) or "Common"]
		information.InfoText.Text = text
		information.NameText.Text = tostring(value):gsub("Fruit", " Fruit")
		information.Icon.Image = FruitList[value]
		local _ = #text / 20 / 10
	end

	if v3[value] then
		if not (MaterialList[value].Redeemable or MaterialList[value].Fish) then
			information.Equip.Visible = false
			information.InfoText.Size = UDim2.new(0.85, 0, 0.31, 0)
		end

		local _ = MaterialList[value].Redeemable
		local _ = MaterialList[value].Fish

		if MaterialList[value] and MaterialList[value].FixedName then
			information.NameText.Text = MaterialList[value].FixedName
		end

		clone3 = script.Highlight:Clone()
		clone3.Parent = v3[value]
		v3[value].Alert.Visible = false
		local info = MaterialList[value].Info or "None"

		if localPlayer.PlayerStats.Language.Value == "TH" then
			info = MaterialList[value].InfoTH or "None"
		end

		information.TierText.Text = MaterialList[value].Tier or "Common"
		information.TierText.TextColor3 = TierColor[MaterialList[value].Tier or "Common"]
		information.InfoText.Text = info
		information.Icon.Image = MaterialList[value].Image
		local _ = #info / 20 / 10
	end

	if v5[value] then
		clone3 = script.Highlight:Clone()
		clone3.Parent = v5[value]
		v5[value].Alert.Visible = false
		local info = CollectibleList[value].Info or "None"

		if localPlayer.PlayerStats.Language.Value == "TH" then
			info = CollectibleList[value].InfoTH or "None"
		end

		information.TierText.Text = CollectibleList[value].Tier or "Common"
		information.TierText.TextColor3 = TierColor[CollectibleList[value].Tier or "Common"]
		information.InfoText.Text = info
		information.NameText.Text = CollectibleList[value].Name or "Collectible"
		information.Icon.Image = CollectibleList[value].Image
		local _ = #info / 20 / 10
	end

	if CustomNames[information.NameText.Text] then
		information.NameText.Text = CustomNames[information.NameText.Text]
	end

	CheckAlert()
end

local flag3 = nil
enchantLabel.MouseButton1Click:Connect(function()
	if flag3 then
		return
	end

	flag3 = true
	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})
	local name2 = enchantLabel:GetAttribute("Name")
	local passiveInfoFrame = parent2.StarterFrame.PassiveInfoFrame

	if name2 then
		enchantLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
		passiveInfoFrame.IconLabel.ImageLabel.Image = enchantLabel.Image
		passiveInfoFrame.NameLabel.Text = name2
		passiveInfoFrame.InfoLabel.Text = MaterialList[name2].Info

		if playerStats.Language.Value == "TH" then
			passiveInfoFrame.InfoLabel.Text = MaterialList[name2].InfoTH
		end

		passiveInfoFrame.Size = UDim2.new(0, 0, 0, 0)
		passiveInfoFrame.Visible = true
		TweenService:Create(
			enchantLabel,
			TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
			{
				ImageColor3 = Color3.fromRGB(0, 0, 0)
			}
		):Play()
		TweenService:Create(passiveInfoFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.323, 0, 0.222, 0)
		}):Play()
	end

	task.delay(0.02, function()
		flag3 = nil
	end)
end)
enchantLabel.MouseEnter:Connect(function()
	enchantLabel.Size = UDim2.new(0.4, 0, 0.4, 0)
	TweenService:Create(enchantLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.6000000000000001, 0, 0.6000000000000001, 0)
	}):Play()
end)
enchantLabel.MouseLeave:Connect(function()
	TweenService:Create(enchantLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.4, 0, 0.4, 0)
	}):Play()
end)
rankUpgrade.MouseButton1Click:Connect(function()
	if flag3 then
		return
	end

	flag3 = true
	local name2 = rankUpgrade:GetAttribute("Name")
	local itemName = rankUpgrade:GetAttribute("ItemName")
	local accInfo = rankUpgrade:GetAttribute("AccInfo")
	local jSONDecode = HttpService:JSONDecode(localPlayer.PlayerStats.UpgradeData.Value)
	local passiveInfoFrame = parent2.StarterFrame.PassiveInfoFrame
	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})

	if name2 then
		rankUpgrade.ImageColor3 = Color3.fromRGB(255, 255, 255)
		passiveInfoFrame.IconLabel.ImageLabel.Image = rankUpgrade.Image
		passiveInfoFrame.NameLabel.Text = name2

		if itemName then
			local v20 = SwordList[itemName] or nil
			local v21 = jSONDecode[itemName] or nil

			if v20 or v21 then
				local v22 = v20.Upgrade[v21]
				passiveInfoFrame.InfoLabel.Text = "+" .. v22.Damage .. "% Damage"
			end
		elseif accInfo then
			passiveInfoFrame.InfoLabel.Text = accInfo
		else
			passiveInfoFrame.InfoLabel.Text = ""
		end

		passiveInfoFrame.Size = UDim2.new(0, 0, 0, 0)
		passiveInfoFrame.Visible = true
		TweenService:Create(
			rankUpgrade,
			TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
			{
				ImageColor3 = Color3.fromRGB(0, 0, 0)
			}
		):Play()
		TweenService:Create(passiveInfoFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.323, 0, 0.222, 0)
		}):Play()
	end

	task.delay(0.02, function()
		flag3 = nil
	end)
end)
rankUpgrade.MouseEnter:Connect(function()
	rankUpgrade.Size = UDim2.new(0.4, 0, 0.27, 0)
	TweenService:Create(rankUpgrade, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.6000000000000001, 0, 0.405, 0)
	}):Play()
end)
rankUpgrade.MouseLeave:Connect(function()
	TweenService:Create(rankUpgrade, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.4, 0, 0.27, 0)
	}):Play()
end)
information.Primary.MouseButton1Click:Connect(function()
	if not v17 then
		return
	end

	local v20 = v17
	ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("EquipWeapon", {
		Type = "Primary",
		WeaponName = v20.Name
	})
end)
information.Secondary.MouseButton1Click:Connect(function()
	if not v17 then
		return
	end

	local v20 = v17
	ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("EquipWeapon", {
		Type = "Secondary",
		WeaponName = v20.Name
	})
end)
information.Equip.MouseButton1Click:Connect(function()
	if flag2 or not v17 then
		return
	end

	if clone3 then
		clone3:Destroy()
		clone3 = nil
	end

	if _G.CheckDoingClient(localPlayer) then
		local clone4 = ReplicatedStorage.Chest.Gui.Bounty:Clone()
		clone4.UIGradient:Destroy()
		clone4.Name = "Just a moment please"
		clone4.Size = UDim2.new(1, 0, 0.034, 0)
		clone4.TextColor3 = Color3.fromRGB(255, 255, 255)
		clone4.TextStrokeTransparency = 0
		clone4.TextTransparency = 0
		local text

		if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character.HumanoidRootPart.Position.Y <= -3.3 then
			text = localPlayer.PlayerStats.Language.Value == "TH" and "<คุณกำลังว่ายน้ำ>" or "<You are swimming>"
		else
			text = localPlayer.PlayerStats.Language.Value == "TH" and "<ไม่สามาถใช้ได้ตอนนี้>" or "<Not available now>"
		end

		clone4.Text = text
		clone4.Parent = localPlayer.PlayerGui.Popup.Frame
	else
		if not v7 then
			return
		end

		v7 = nil
		local v20 = v17
		information.Equip.CanvasGroup.CooldownFrame.Size = UDim2.new(1, 0, 1, 0)
		information.Equip.CanvasGroup.CooldownFrame.Visible = true
		TweenService:Create(information.Equip.CanvasGroup.CooldownFrame, TweenInfo.new(2, Enum.EasingStyle.Linear), {
			Size = UDim2.new(0, 0, 1, 0)
		}):Play()
		task.spawn(function()
			_G.ClickFrameEffect({
				Sound = true
			})
		end)

		if v2[v20] and ReplicatedStorage.Chest.Remotes.Functions.AccessoryEq:InvokeServer(v20.Name) then
			task.spawn(function()
				if clone2 then
					clone2:Destroy()
					clone2 = nil
				end

				local child = scrollingFrameAccessories:FindFirstChild(v2[v20].Name)

				if child and localPlayer.PlayerStats.Accessory.Value == child.Name then
					clone2 = script.EquippingNew:Clone()
					clone2.Parent = child
				end
			end)
		end

		if v[v20] and ReplicatedStorage.Chest.Remotes.Functions.InventoryEq:InvokeServer(v20.Name) then
			if clone then
				clone:Destroy()
				clone = nil
			end

			local child = scrollingFrameSwords:FindFirstChild(v[v20].Name)

			if child and localPlayer.PlayerStats.SwordName.Value == child.Name then
				clone = script.EquippingNew:Clone()
				clone.Parent = child
			end

			spawn(function()
				for _, frame in pairs(localPlayer.PlayerGui.MainGui.MobileMove:GetChildren()) do
					if not (string.find(frame.Name, "Sword") and frame:IsA("Frame")) then
						continue
					end

					frame.Visible = false
				end
			end)
			_G.StopAnimationClient(localPlayer.Character.Humanoid, {
				Idle = true,
				ZLoop = true
			})
		end

		if v4[v20] then
			ReplicatedStorage.Chest.Remotes.Events.CollectFruit:FireServer(v20)
		end

		if v5[v20] then
			ReplicatedStorage.Chest.Remotes.Events.UseCollectible:FireServer(v20)
		end

		if v3[v20] then
			if MaterialList[v20].Redeemable then
				ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("RedeemMaterial", {
					MaterialName = v20
				})
			elseif MaterialList[v20].Fish then
				ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("EquipFish", {
					FishName = v20
				})
			end
		end

		CloseInformation()
		task.spawn(function()
			wait(2)
			information.Equip.CanvasGroup.CooldownFrame.Visible = false
			v7 = true
		end)
	end
end)

function DeepCopy(items)
	local copies = {}

	for k, copy3 in pairs(items) do
		if type(copy3) == "table" then
			copy3 = DeepCopy(copy3)
		end

		copies[k] = copy3
	end

	return copies
end

function UpdateFruits()
	CloseInformation()
	local jSONDecode = HttpService:JSONDecode(fruitStore.Value)
	local v20 = copy2 and copy2 or DeepCopy(jSONDecode)
	local count = 0
	local v21 = {}

	for k, text in pairs(jSONDecode) do
		if v4[k] or not FruitList[k] then
			if v4[k] and FruitList[k] then
				v4[k].Amount.Text = text
			end
		else
			Color3.fromRGB(255, 255, 255)
			local v23 = GetFruitRarity(k) or "Common"
			local backgroundColor = TierColor[v23]
			local image = TierImage[v23]
			v4[k] = script.ItemButton2:Clone()
			v4[k].Name = k
			v4[k].LayoutOrder = _G.Layouts[v23]
			v4[k]:SetAttribute("LayoutOrder", v4[k].LayoutOrder + math.random())
			v4[k].ImageLabel.BackgroundColor3 = backgroundColor
			v4[k].TierImage.Image = image
			v4[k].Amount.Text = text
			v4[k].SwordName.Text = tostring(k):gsub("Fruit", "") or k

			if CustomNames[v4[k].SwordName.Text] then
				v4[k].SwordName.Text = CustomNames[v4[k].SwordName.Text]
			end

			if CustomNames[k] then
				v4[k]:SetAttribute("FixedName", CustomNames[k])
			end

			v4[k].ImageLabel.Image = FruitList[k]
			v13.Fruit[v23] = (v13.Fruit[v23] or 0) + 1
			v4[k].Parent = scrollingFrameFruits
			local v26 = k
			v4[k].MouseButton1Click:Connect(function()
				Select(v26)
				TweenColorIcon(v4[v26])
			end)
			local v27 = k
			v4[k].MouseEnter:Connect(function()
				_G.ShineGui({
					Parent = v4[v27],
					ZIndex = 5
				})
				local imageLabel = v4[v27]:FindFirstChild("ImageLabel")

				if imageLabel then
					imageLabel.BackgroundTransparency = 0.5
				end
			end)
			local v28 = k
			v4[k].MouseLeave:Connect(function()
				local imageLabel = v4[v28]:FindFirstChild("ImageLabel")

				if imageLabel then
					imageLabel.BackgroundTransparency = 0.8
				end

				if v4[v28].Alert.Visible then
					v4[v28].Alert.Visible = false
					CheckAlert()
				end
			end)
			table.insert(v8, v4[k])
		end

		count += 1
		v21[k] = true

		if v20[k] then
			if v20[k] and v20[k] < text then
				FruitNewItemAlert(true)
				v4[k].Alert.Visible = true
			end
		else
			FruitNewItemAlert(true)
			v4[k].Alert.Visible = true
		end
	end

	copy2 = DeepCopy(jSONDecode)

	for k, _ in pairs(v4) do
		if v21[k] or not v4[k] then
			continue
		end

		local index = table.find(v8, v4[k])

		if index then
			table.remove(v8, index)
		end

		v4[k]:Destroy()
		v4[k] = nil
		local v22 = GetFruitRarity(k) or "Common"

		if v13.Fruit[v22] then
			v13.Fruit[v22] = v13.Fruit[v22] - 1
		end
	end

	CheckAlert()
	UpdateFruitLayouts()
end

function UpdateEquipping(p)
	local child = p.Child
	local equipType = p.EquipType or nil

	if not equipType then
		return
	end

	if equipType == "AccessoryIcon_E" then
		if clone2 and clone2.Parent and clone2.Parent ~= v2[child] then
			clone2:Destroy()
			clone2 = nil
			clone2 = script.EquippingNew:Clone()
			clone2.Parent = v2[child]
		elseif not (clone2 or v2[child]:FindFirstChild("EquippingNew")) then
			clone2 = script.EquippingNew:Clone()
			clone2.Parent = v2[child]
		end
	elseif equipType == "SwordIcon_E" then
		if clone and clone.Parent and clone.Parent ~= v[child] then
			clone:Destroy()
			clone = nil
			clone = script.EquippingNew:Clone()
			clone.Parent = v[child]
		elseif not (clone or v[child]:FindFirstChild("EquippingNew")) then
			clone = script.EquippingNew:Clone()
			clone.Parent = v[child]
		end
	end
end

function UpdateSwords()
	CloseInformation()
	local v20 = children and children or inventory:GetChildren()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Get(name2)
		for _, v21 in pairs(v20) do
			if v21.Name == name2 then
				return true
			end
		end
	end

	table.clear(v13.Sword)
	local jSONDecode = HttpService:JSONDecode(localPlayer.PlayerStats.UpgradeData.Value)
	local jSONDecode2 = HttpService:JSONDecode(playerStats.EnchantWeapon.Value)
	local v21 = HttpService:JSONDecode(etcData.Value) or {}
	local primaryWeapon = v21.PrimaryWeapon
	local secondaryWeapon = v21.SecondaryWeapon

	for _, child in pairs(inventory:GetChildren()) do
		if v[child] then
			if v[child] and SwordList[child.Name] then
				v[child].EnchantLabel.Visible = nil

				if jSONDecode2[child.Name] then
					if type(jSONDecode2[child.Name]) == "table" then
						v[child].EnchantLabel.Visible = true
						v[child].EnchantLabel.Image = MaterialList[jSONDecode2[child.Name].Rune].Image
					else
						v[child].EnchantLabel.Visible = true
						v[child].EnchantLabel.Image = MaterialList[jSONDecode2[child.Name]].Image
					end
				end

				if jSONDecode[child.Name] and jSONDecode[child.Name] > 0 then
					v[child].RankUpgrade.Image = RankUpgradeList[jSONDecode[child.Name]].Image
					v[child].RankUpgrade.Visible = true
				end

				if primaryWeapon == child.Name or secondaryWeapon == child.Name then
					if not v[child]:FindFirstChild("EquippingIcon") then
						local clone4 = script.EquippingNew:Clone()
						clone4.Name = "EquippingIcon"
						clone4.Parent = v[child]
					end
				else
					local equippingIcon = v[child]:FindFirstChild("EquippingIcon")

					if equippingIcon then
						equippingIcon:Destroy()
					end
				end
			end
		else
			Color3.fromRGB()

			if SwordList[child.Name] then
				local image = TierImage[SwordList[child.Name].Tier]
				local backgroundColor = TierColor[SwordList[child.Name].Tier]
				v[child] = script.ItemButton:Clone()
				v[child].Name = child.Name

				if primaryWeapon == child.Name or secondaryWeapon == child.Name then
					if not v[child]:FindFirstChild("EquippingIcon") then
						local clone4 = script.EquippingNew:Clone()
						clone4.Name = "EquippingIcon"
						clone4.Parent = v[child]
					end
				else
					local equippingIcon = v[child]:FindFirstChild("EquippingIcon")

					if equippingIcon then
						equippingIcon:Destroy()
					end
				end

				v[child].SwordName.Text = child.Name

				if CustomNames[v[child].SwordName.Text] then
					v[child].SwordName.Text = CustomNames[v[child].SwordName.Text]
				end

				if image then
					v[child].TierImage.Image = image
				end

				if backgroundColor then
					v[child].ImageLabel.BackgroundColor3 = backgroundColor
				end

				if SwordList[child.Name].TierImage then
					v[child].TierImage.Image = SwordList[child.Name].TierImage
				end

				if SwordList[child.Name].FixedName then
					v[child]:SetAttribute("FixedName", SwordList[child.Name].FixedName)
				end

				v[child].LayoutOrder = _G.Layouts[SwordList[child.Name].Tier]
				v[child]:SetAttribute("LayoutOrder", v[child].LayoutOrder + math.random())
				v[child].EnchantLabel.Visible = nil

				if jSONDecode2[child.Name] then
					v[child].EnchantLabel.Visible = true
					v[child].EnchantLabel.Image = MaterialList[jSONDecode2[child.Name]].Image
				end

				v[child].ImageLabel.Image = SwordList[child.Name].Image

				if jSONDecode[child.Name] and jSONDecode[child.Name] > 0 then
					v[child].RankUpgrade.Image = RankUpgradeList[jSONDecode[child.Name]].Image
					v[child].RankUpgrade.Visible = true
				end

				v[child].Parent = scrollingFrameSwords
				local v24 = child
				v[child].MouseButton1Click:Connect(function()
					Select(v24)
					TweenColorIcon(v[v24])
				end)
				local v25 = child
				v[child].MouseEnter:Connect(function()
					_G.ShineGui({
						Parent = v[v25],
						ZIndex = 5
					})
					local imageLabel = v[v25]:FindFirstChild("ImageLabel")

					if imageLabel then
						imageLabel.BackgroundTransparency = 0.5
					end
				end)
				local v26 = child
				v[child].MouseLeave:Connect(function()
					local imageLabel = v[v26]:FindFirstChild("ImageLabel")

					if imageLabel then
						imageLabel.BackgroundTransparency = 0.8
					end

					if v[v26].Alert.Visible then
						v[v26].Alert.Visible = false
						CheckAlert()
					end
				end)
				table.insert(v9, v[child])
			end
		end

		local tier = SwordList[child.Name] and SwordList[child.Name].Tier

		if tier then
			v13.Sword[tier] = (v13.Sword[tier] or 0) + 1
		end

		local get = Get(child.Name) -- equivalent call inferred; original call site unknown

		if get or not v[child] then
			continue
		end

		v[child].Alert.Visible = true
		InventoryNewItemAlert(true)
	end

	children = inventory:GetChildren()
	CheckAlert()
	UpdateSwordLayouts()
end

function CheckAlert()
	local v20 = nil
	local v21 = nil
	local v22 = nil
	local v23 = nil
	local v24 = nil

	for _, v26 in pairs(v2) do
		if not v26.Alert.Visible then
			continue
		end

		v24 = true
		break
	end

	for _, v27 in pairs(v) do
		if not v27.Alert.Visible then
			continue
		end

		v23 = true
		break
	end

	for _, v28 in pairs(v4) do
		if not v28.Alert.Visible then
			continue
		end

		v22 = true
		break
	end

	for _, v29 in pairs(v3) do
		if not v29.Alert.Visible then
			continue
		end

		v21 = true
		break
	end

	for _, v30 in pairs(v5) do
		if not v30.Alert.Visible then
			continue
		end

		v20 = true
		break
	end

	AccessoryNewItemAlert(v24)
	FruitNewItemAlert(v22)
	MaterialNewItemAlert(v21)
	InventoryNewItemAlert(v23)
	CollectibleNewItemAlert(v20)

	if v24 or v22 or v21 or v23 or v20 then
		parent2.BaseFrame.ButtonFrame.InventoryButton.Alert.Visible = true
		parent2.BaseFrameOG.ButtonFrame.InventoryButton.Alert.Visible = true
		_G.MenuAlert(true)
	else
		parent2.BaseFrame.ButtonFrame.InventoryButton.Alert.Visible = false
		parent2.BaseFrameOG.ButtonFrame.InventoryButton.Alert.Visible = false
		_G.MenuAlert(false)
	end
end

function UpdateAccessories()
	CloseInformation()
	local jSONDecode = HttpService:JSONDecode(localPlayer.PlayerStats.UpgradeData.Value)
	local v20 = children2 and children2 or accessories:GetChildren()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Get(name2)
		for _, v21 in pairs(v20) do
			if v21.Name == name2 then
				return true
			end
		end
	end

	table.clear(v13.Accessory)

	for _, child in pairs(accessories:GetChildren()) do
		spawn(function()
			local bullitus = scrollingFrameAccessories:FindFirstChild("Bullitus")

			if bullitus and localPlayer.PlayerStats.Accessory.Value ~= "Bullitus" and clone2 and clone2.Parent == bullitus then
				clone2:Destroy()
				clone2 = nil
			end
		end)

		if v2[child] then
			if v2[child] and jSONDecode[child.Name] and jSONDecode[child.Name] > 0 then
				v2[child].RankUpgrade.Image = RankUpgradeList[jSONDecode[child.Name]].Image
				v2[child].RankUpgrade.Visible = true
			end
		else
			if not AccessoriesList[child.Name] then
				continue
			end

			Color3.fromRGB()
			local backgroundColor = TierColor[AccessoriesList[child.Name].Tier]
			local image = TierImage[AccessoriesList[child.Name].Tier]
			v2[child] = script.ItemButton:Clone()
			v2[child].Name = child.Name

			if child.Name == localPlayer.PlayerStats.Accessory.Value then
				UpdateEquipping({
					Child = child,
					EquipType = "AccessoryIcon_E"
				})
			end

			v2[child].LayoutOrder = _G.Layouts[AccessoriesList[child.Name].Tier]
			v2[child]:SetAttribute("LayoutOrder", v2[child].LayoutOrder + math.random())
			v2[child].SwordName.Text = child.Name

			if CustomNames[v2[child].SwordName.Text] then
				v2[child].SwordName.Text = CustomNames[v2[child].SwordName.Text]
			end

			if image then
				v2[child].TierImage.Image = image
			end

			if backgroundColor then
				v2[child].ImageLabel.BackgroundColor3 = backgroundColor
			end

			if AccessoriesList[child.Name].TierImage then
				v2[child].TierImage.Image = AccessoriesList[child.Name].TierImage
			end

			v2[child].ImageLabel.Image = AccessoriesList[child.Name].Image

			if v6 == "All" then
				v2[child].Visible = true
			elseif v6 == "All" or AccessoriesList[child.Name].Tier ~= v6 then
				v2[child].Visible = false
			else
				v2[child].Visible = true
			end

			if jSONDecode[child.Name] and jSONDecode[child.Name] > 0 then
				v2[child].RankUpgrade.Image = RankUpgradeList[jSONDecode[child.Name]].Image
				v2[child].RankUpgrade.Visible = true
			end

			v2[child].Parent = scrollingFrameAccessories
			local v23 = child
			v2[child].MouseButton1Click:Connect(function()
				Select(v23)
				TweenColorIcon(v2[v23])
			end)
			local v24 = child
			v2[child].MouseEnter:Connect(function()
				_G.ShineGui({
					Parent = v2[v24],
					ZIndex = 5
				})
				local imageLabel = v2[v24]:FindFirstChild("ImageLabel")

				if imageLabel then
					imageLabel.BackgroundTransparency = 0.5
				end
			end)
			local v25 = child
			v2[child].MouseLeave:Connect(function()
				local imageLabel = v2[v25]:FindFirstChild("ImageLabel")

				if imageLabel then
					imageLabel.BackgroundTransparency = 0.8
				end

				if v2[v25].Alert.Visible then
					v2[v25].Alert.Visible = false
					CheckAlert()
				end
			end)
			table.insert(v11, v2[child])
		end

		local tier = AccessoriesList[child.Name] and AccessoriesList[child.Name].Tier

		if tier then
			v13.Accessory[tier] = (v13.Accessory[tier] or 0) + 1
		end

		local get = Get(child.Name) -- equivalent call inferred; original call site unknown

		if get or not v2[child] then
			continue
		end

		AccessoryNewItemAlert(true)
		v2[child].Alert.Visible = true
	end

	children2 = accessories:GetChildren()
	CheckAlert()
	UpdateAccessoryLayouts()
end

function UpdateMaterial()
	CloseInformation()
	local jSONDecode = HttpService:JSONDecode(material.Value)
	local v20 = copy and copy or DeepCopy(jSONDecode)
	local v21 = {}

	for k, text in pairs(jSONDecode) do
		if v3[k] then
			if v3[k] then
				v3[k].Amount.Text = text
			end
		else
			if not MaterialList[k] then
				continue
			end

			Color3.fromRGB()
			local image = TierImage[MaterialList[k].Tier]
			local backgroundColor = TierColor[MaterialList[k].Tier]
			v3[k] = script.ItemButton2:Clone()

			if MaterialList[k].FixedName then
				v3[k]:SetAttribute("FixedName", MaterialList[k].FixedName)
			end

			v3[k].Name = k
			v3[k].LayoutOrder = _G.Layouts[MaterialList[k].Tier]
			v3[k]:SetAttribute("LayoutOrder", v3[k].LayoutOrder + math.random())
			v3[k].ImageLabel.Image = MaterialList[k].Image
			v3[k].SwordName.Text = MaterialList[k].FixedName or k
			v3[k].TierImage.Image = image
			v3[k].ImageLabel.BackgroundColor3 = backgroundColor
			v3[k].Amount.Text = text

			if MaterialList[k].TierImage then
				v3[k].TierImage.Image = MaterialList[k].TierImage
			end

			local tier = MaterialList[k].Tier
			v13.Material[tier] = (v13.Material[tier] or 0) + 1

			if MaterialList[k].Fish then
				v13.Material.Fish = (v13.Material.Fish or 0) + 1
			end

			v3[k].Parent = scrollingFrameMaterial
			local v25 = k
			v3[k].MouseButton1Click:Connect(function()
				Select(v25)
				TweenColorIcon(v3[v25])
			end)
			local v26 = k
			v3[k].MouseEnter:Connect(function()
				_G.ShineGui({
					Parent = v3[v26],
					ZIndex = 5
				})
				local imageLabel = v3[v26]:FindFirstChild("ImageLabel")

				if imageLabel then
					imageLabel.BackgroundTransparency = 0.5
				end
			end)
			local v27 = k
			v3[k].MouseLeave:Connect(function()
				local imageLabel = v3[v27]:FindFirstChild("ImageLabel")

				if imageLabel then
					imageLabel.BackgroundTransparency = 0.8
				end

				if v3[v27].Alert.Visible then
					v3[v27].Alert.Visible = false
					CheckAlert()
				end
			end)
			table.insert(v10, v3[k])
		end

		if v20[k] then
			local _ = v20[k]
		else
			MaterialNewItemAlert(true)
			v3[k].Alert.Visible = true
		end

		v21[k] = true
	end

	copy = DeepCopy(jSONDecode)

	for k, _ in pairs(v3) do
		if v21[k] or not v3[k] then
			continue
		end

		local index = table.find(v10, v3[k])

		if index then
			table.remove(v10, index)
		end

		v3[k]:Destroy()
		v3[k] = nil
		local tier = MaterialList[k] and MaterialList[k].Tier

		if tier and v13.Material[tier] then
			v13.Material[tier] = v13.Material[tier] - 1
		end

		if tier and MaterialList[k].Fish then
			v13.Material.Fish = v13.Material.Fish - 1
		end
	end

	CheckAlert()
	UpdateMaterialLayouts()
end

local copy3 = nil

function UpdateCollectible()
	CloseInformation()
	local jSONDecode = HttpService:JSONDecode(collectible.Value)
	local v20 = copy3 and copy3 or DeepCopy(jSONDecode)
	local v21 = {}

	for k, text in pairs(jSONDecode) do
		if v5[k] then
			if v5[k] then
				v5[k].Amount.Text = text
			end
		else
			if not CollectibleList[k] then
				continue
			end

			Color3.fromRGB()
			local image = TierImage[CollectibleList[k].Tier]
			local backgroundColor = TierColor[CollectibleList[k].Tier]
			v5[k] = script.ItemButton2:Clone()
			v5[k].Name = k
			v5[k].LayoutOrder = _G.Layouts[CollectibleList[k].Tier]
			v5[k]:SetAttribute("LayoutOrder", v5[k].LayoutOrder + math.random())
			v5[k].ImageLabel.Image = CollectibleList[k].Image
			v5[k].SwordName.Text = CollectibleList[k].Name or k
			v5[k].TierImage.Image = image
			v5[k].ImageLabel.BackgroundColor3 = backgroundColor
			v5[k].Amount.Text = text
			local tier = CollectibleList[k].Tier
			v13.Collectible[tier] = (v13.Collectible[tier] or 0) + 1

			if CollectibleList[k] and CollectibleList[k].Name then
				v5[k]:SetAttribute("FixedName", CollectibleList[k].Name)
			end

			v5[k].Parent = scrollingFrameCollectible
			local v25 = k
			v5[k].MouseButton1Click:Connect(function()
				Select(v25)
				TweenColorIcon(v5[v25])
			end)
			local v26 = k
			v5[k].MouseEnter:Connect(function()
				_G.ShineGui({
					Parent = v5[v26],
					ZIndex = 5
				})
				local imageLabel = v5[v26]:FindFirstChild("ImageLabel")

				if imageLabel then
					imageLabel.BackgroundTransparency = 0.5
				end
			end)
			local v27 = k
			v5[k].MouseLeave:Connect(function()
				local imageLabel = v5[v27]:FindFirstChild("ImageLabel")

				if imageLabel then
					imageLabel.BackgroundTransparency = 0.8
				end

				if v5[v27].Alert.Visible then
					v5[v27].Alert.Visible = false
					CheckAlert()
				end
			end)
			table.insert(v12, v5[k])
		end

		if v20[k] then
			if v20[k] and v20[k] < text then
				v5[k].Alert.Visible = true
				CollectibleNewItemAlert(true)
			end
		else
			CollectibleNewItemAlert(true)
			v5[k].Alert.Visible = true
		end

		v21[k] = true
	end

	copy3 = DeepCopy(jSONDecode)

	for k, _ in pairs(v5) do
		if v21[k] or not v5[k] then
			continue
		end

		local index = table.find(v12, v5[k])

		if index then
			table.remove(v12, index)
		end

		v5[k]:Destroy()
		v5[k] = nil
		local tier = CollectibleList[k] and CollectibleList[k].Tier

		if tier and v13.Collectible[tier] then
			v13.Collectible[tier] = v13.Collectible[tier] - 1
		end
	end

	CheckAlert()
	UpdateCollectibleLayouts()
end

function UpdateGrid()
	UpdateAllLayouts()
end

UpdateGrid()
local zoomIn = parent.FunctionBar.ZoomIn
local zoomOut = parent.FunctionBar.ZoomOut
local v20 = true
zoomIn.MouseButton1Click:Connect(function()
	if flag2 or not v20 then
		return
	end

	CloseInformation()
	v20 = false
	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true
		})
		zoomIn.Size = UDim2.new(0.9, 0, 0.9, 0)
		TweenService:Create(
			zoomIn,
			TweenInfo.new(0.075, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
			{
				Size = UDim2.new(1.125, 0, 1.125, 0)
			}
		):Play()
	end)
	local _, _ = pcall(function()
		ReplicatedStorage.Chest.Remotes.Functions.InventoryGridRemote:InvokeServer("ZoomIn")
	end)
	spawn(function()
		task.wait(0.075)
		v20 = true
	end)
end)
zoomIn.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = zoomIn,
		ZIndex = 5
	})
end)
zoomOut.MouseButton1Click:Connect(function()
	if flag2 or not v20 then
		return
	end

	CloseInformation()
	v20 = false
	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true
		})
		zoomOut.Size = UDim2.new(0.9, 0, 0.9, 0)
		TweenService:Create(
			zoomOut,
			TweenInfo.new(0.075, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
			{
				Size = UDim2.new(1.125, 0, 1.125, 0)
			}
		):Play()
	end)
	local _, _ = pcall(function()
		ReplicatedStorage.Chest.Remotes.Functions.InventoryGridRemote:InvokeServer("ZoomOut")
	end)
	spawn(function()
		task.wait(0.075)
		v20 = true
	end)
end)
zoomOut.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = zoomOut,
		ZIndex = 5
	})
end)
localPlayer.PlayerStats.InventoryGridSize.Changed:Connect(function()
	task.wait(0.03333333333333333)
	UpdateGrid()
end)
parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	task.wait(0.03333333333333333)
	UpdateGrid()
end)

function Remove(p)
	if v[p] then
		local index = table.find(v9, v[p])

		if index then
			table.remove(v9, index)
		end

		v[p]:Destroy()
		v[p] = nil
		children = inventory:GetChildren()
	end
end

function RemoveAccessories(p)
	if v2[p] then
		local index = table.find(v11, v2[p])

		if index then
			table.remove(v11, index)
		end

		v2[p]:Destroy()
		v2[p] = nil
		children2 = accessories:GetChildren()
	end
end

function RemoveFruit(p)
	if v4[p] then
		local index = table.find(v8, v4[p])

		if index then
			table.remove(v8, index)
		end

		v4[p]:Destroy()
		v4[p] = nil
	end
end

wait(0.5)
local lastTime2 = os.clock()
local flag4 = nil
inventory.ChildAdded:Connect(function(_)
	lastTime2 = os.clock()

	if flag4 then
		return
	end

	flag4 = true

	while os.clock() - lastTime2 < 0.03333333333333333 do
		task.wait(0.03333333333333333)
	end

	flag4 = nil
	UpdateSwords()
end)
local lastTime3 = os.clock()
local children3 = {}
inventory.ChildRemoved:Connect(function(child)
	lastTime3 = os.clock()

	if #children3 > 0 then
		table.insert(children3, child)
		return
	end

	table.insert(children3, child)

	while os.clock() - lastTime3 < 0.03333333333333333 do
		task.wait(0.03333333333333333)
	end

	local clone4 = table.clone(children3)
	table.clear(children3)

	for _, v21 in ipairs(clone4) do
		Remove(v21)
	end

	table.clear(clone4)
	UpdateSwords()
end)
local lastTime4 = os.clock()
local flag5 = nil
accessories.ChildAdded:Connect(function(_)
	lastTime4 = os.clock()

	if flag5 then
		return
	end

	flag5 = true

	while os.clock() - lastTime4 < 0.03333333333333333 do
		task.wait(0.03333333333333333)
	end

	flag5 = nil
	UpdateAccessories()
end)
local lastTime5 = os.clock()
local children4 = {}
accessories.ChildRemoved:Connect(function(child)
	lastTime5 = os.clock()

	if #children4 > 0 then
		table.insert(children4, child)
		return
	end

	table.insert(children4, child)

	while os.clock() - lastTime5 < 0.03333333333333333 do
		task.wait(0.03333333333333333)
	end

	local clone4 = table.clone(children4)
	table.clear(children4)

	for _, v21 in ipairs(clone4) do
		RemoveAccessories(v21)
	end

	table.clear(clone4)
	UpdateAccessories()
end)
localPlayer.PlayerStats.Accessory.Changed:Connect(function()
	wait(0.03333333333333333)
	UpdateAccessories()
	task.spawn(function()
		_G.UpdateMaxJump()
	end)
end)
localPlayer.PlayerStats.Material.Changed:Connect(function()
	wait(0.03333333333333333)
	UpdateMaterial()
end)
localPlayer.PlayerStats.Collectible.Changed:Connect(function()
	wait(0.03333333333333333)
	UpdateCollectible()
end)
fruitStore.Changed:Connect(function()
	wait(0.03333333333333333)
	UpdateFruits()
end)
localPlayer.PlayerStats.UpgradeData.Changed:Connect(function()
	wait(0.03333333333333333)
	UpdateSwords()
	UpdateAccessories()
end)
localPlayer.PlayerStats.EnchantWeapon.Changed:Connect(function()
	wait(0.03333333333333333)
	UpdateSwords()
end)
fruits.ChildAdded:Connect(function(_)
	wait(0.03333333333333333)
	UpdateFruits()
end)
fruits.ChildRemoved:Connect(function(child)
	wait(0.03333333333333333)
	RemoveFruit(child)
end)
UpdateEquippingWeapons()
UpdateSwords()
UpdateAccessories()
UpdateFruits()
UpdateMaterial()
UpdateCollectible()
etcData.Changed:Connect(function()
	task.spawn(UpdateSwords)
	UpdateEquippingWeapons()
end)
local v21 = true

function UpdateTierMode(value)
	local text = value or "All"
	CloseInformation()
	textBox.Text = ""
	local v23

	if not (text == "All" or not text) then
		v23 = text
	end

	v15 = v23

	if text then
		v6 = text
		tierButton.Text = text

		if text == "All" then
			tierButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		elseif text == "Common" then
			tierButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		elseif text == "Uncommon" then
			tierButton.TextColor3 = Color3.fromRGB(85, 170, 0)
		elseif text == "Rare" then
			tierButton.TextColor3 = Color3.fromRGB(170, 255, 255)
		elseif text == "Epic" then
			tierButton.TextColor3 = Color3.fromRGB(170, 0, 255)
		elseif text == "Legendary" then
			tierButton.TextColor3 = Color3.fromRGB(230, 0, 0)
		elseif text == "Limited" then
			tierButton.TextColor3 = Color3.fromRGB(255, 255, 0)
		elseif text == "Mythical" then
			tierButton.TextColor3 = Color3.fromRGB(235, 7, 144)
		elseif text == "Fish" then
			tierButton.TextColor3 = Color3.fromRGB(0, 255, 255)
		end
	end

	UpdateAllLayouts()
end

task.spawn(function()
	for _, button in pairs(tierFrame:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		local v22 = button
		button.MouseButton1Click:Connect(function()
			if not v21 then
				return
			end

			v21 = nil

			if tierFrame.Visible then
				TweenService:Create(tierFrame, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
					Size = UDim2.fromScale(0.425, 0)
				}):Play()
				task.delay(0.1, function()
					tierFrame.Visible = nil
				end)
			end

			UpdateTierMode(v22.Name)
			task.spawn(function()
				_G.ClickFrameEffect({
					Sound = true
				})
				tierButton.Size = UDim2.new(0.37, 0, 0.9, 0)
				TweenService:Create(
					tierButton,
					TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
					{
						Size = UDim2.new(0.40700000000000003, 0, 0, 0)
					}
				):Play()
			end)
			task.spawn(function()
				task.wait(0.11)
				v21 = true
			end)
		end)
		local parent3 = button
		button.MouseEnter:Connect(function()
			_G.ShineGui({
				Parent = parent3,
				ZIndex = 5,
				Circle = true,
				CornerRadius = UDim.new(0.15, 0)
			})
		end)
	end
end)
tierButton.MouseButton1Click:Connect(function()
	if not v21 then
		return
	end

	v21 = nil
	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true
		})
		tierButton.Size = UDim2.new(0.37, 0, 0.9, 0)
		TweenService:Create(
			tierButton,
			TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
			{
				Size = UDim2.new(0.40700000000000003, 0, 0.9, 0)
			}
		):Play()
	end)

	if tierFrame.Visible then
		TweenService:Create(tierFrame, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
			Size = UDim2.fromScale(0.35, 0)
		}):Play()
		task.delay(0.1, function()
			tierFrame.Visible = nil
		end)
	else
		tierFrame.Size = UDim2.fromScale(0.35, 0)
		tierFrame.Visible = true
		TweenService:Create(tierFrame, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
			Size = UDim2.fromScale(0.35, 8.75)
		}):Play()

		if scrollingFrameMaterial.Visible then
			tierFrame.Fish.Visible = true
		else
			tierFrame.Fish.Visible = false
		end
	end

	task.spawn(function()
		task.wait(0.11)
		v21 = true
	end)
end)
parent.FunctionBar.SearchBar.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = parent.FunctionBar.SearchBar,
		ZIndex = 5
	})
end)
tierButton.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = tierButton,
		ZIndex = 5
	})
end)
tierButton.MouseLeave:Connect(function()
	local uIStroke = tierButton:FindFirstChild("UIStroke")

	if uIStroke then
		uIStroke.Enabled = nil
	end
end)
swords.MouseButton1Click:Connect(function()
	if not (v16 and name ~= swords.Name) then
		return
	end

	name = swords.Name

	if clone3 then
		clone3:Destroy()
		clone3 = nil
	end

	ButtonClick(swords, scrollingFrameSwords)
	CheckAlert()
	UpdateTierMode()
	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true
		})
	end)
end)
accessories2.MouseButton1Click:Connect(function()
	if not (v16 and name ~= accessories2.Name) then
		return
	end

	name = accessories2.Name

	if clone3 then
		clone3:Destroy()
		clone3 = nil
	end

	ButtonClick(accessories2, scrollingFrameAccessories)
	CheckAlert()
	UpdateTierMode()
	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true
		})
	end)
end)
fruits2.MouseButton1Click:Connect(function()
	if not (v16 and name ~= fruits2.Name) then
		return
	end

	name = fruits2.Name

	if clone3 then
		clone3:Destroy()
		clone3 = nil
	end

	ButtonClick(fruits2, scrollingFrameFruits)
	CheckAlert()
	UpdateTierMode()
	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true
		})
	end)
end)
collectible2.MouseButton1Click:Connect(function()
	if not (v16 and name ~= collectible2.Name) then
		return
	end

	name = collectible2.Name

	if clone3 then
		clone3:Destroy()
		clone3 = nil
	end

	ButtonClick(collectible2, scrollingFrameCollectible)
	CheckAlert()
	UpdateTierMode()
	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true
		})
	end)
end)
material2.MouseButton1Click:Connect(function()
	if not (v16 and name ~= material2.Name) then
		return
	end

	name = material2.Name

	if clone3 then
		clone3:Destroy()
		clone3 = nil
	end

	ButtonClick(material2, scrollingFrameMaterial)
	CheckAlert()
	UpdateTierMode()
	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true
		})
	end)
end)

function ItemSearchCheck(value, value2, _)
	if value == "" then
		return true
	end

	if CustomNames[value2] then
		value2 = CustomNames[value2]
	end

	local v22 = string.lower(value)
	local v23 = string.lower(value2)

	for i = 1, #v23 do
		if string.sub(v22, 1, #v22) == string.sub(v23, 1, i) or string.sub(v22, 1, #v22) == string.sub(
			v23,
			i,
			i + (#v22 - 1)
		) then
			return true
		end
	end
end

function Searching()
	local text = textBox.Text

	if text == "" or not text then
		text = nil
	end

	v14 = text
	UpdateAllLayouts()
end

textBox.FocusLost:Connect(function()
	Searching()
end)
textBox:GetPropertyChangedSignal("Text"):Connect(function()
	Searching()
end)
parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if not parent.Visible then
		information.Visible = false
	end
end)

for _, child in pairs(parent:GetChildren()) do
	if not child:GetAttribute("FirstButton") then
		continue
	end

	local parent3 = child
	child.MouseEnter:Connect(function()
		_G.ShineGui({
			Parent = parent3
		})
		parent3.TextLabel.Visible = true
	end)
	local v23 = child
	child.MouseLeave:Connect(function()
		v23.TextLabel.Visible = false
	end)
end

parent.FunctionBar.Close.MouseButton1Click:Connect(function()
	if clone3 then
		clone3:Destroy()
		clone3 = nil
	end

	if tierFrame.Visible then
		tierFrame.Visible = nil
	end

	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})
	_G.ButtonClicked()
end)
parent.FunctionBar.Close.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = parent.FunctionBar.Close,
		ZIndex = 5,
		Circle = true,
		Size = UDim2.fromScale(0.9, 0.9)
	})
	parent.FunctionBar.Close.Size = UDim2.new(1.15, 0, 1.15, 0)
	TweenService:Create(parent.FunctionBar.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(1.7249999999999999, 0, 1.7249999999999999, 0)
	}):Play()
end)
parent.FunctionBar.Close.MouseLeave:Connect(function()
	TweenService:Create(parent.FunctionBar.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(1.15, 0, 1.15, 0)
	}):Play()
end)