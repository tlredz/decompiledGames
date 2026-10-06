local localPlayer = game.Players.LocalPlayer

repeat
	wait()
until localPlayer:FindFirstChild("DataLoaded")

if not localPlayer:FindFirstChild("DataLoaded") then
	script.Parent:Destroy()
	return
end

local tradeWith = localPlayer:WaitForChild("TradeWith")
local TweenService = game:GetService("TweenService")
localPlayer:GetMouse()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Remotes")
local TierImage = require(ReplicatedStorage.Chest.Modules.TierImage)
local TierColor = require(ReplicatedStorage.Chest.Modules.TierColor)
local CustomNames = require(ReplicatedStorage.Chest.Modules.CustomNames)
local mainFrame = script.Parent:WaitForChild("TradingFrame"):WaitForChild("MainFrame")
local itemFrame = mainFrame:WaitForChild("ItemFrame")
local accept = mainFrame:WaitForChild("Accept")
local cancel = mainFrame:WaitForChild("Cancel")
local fruits = mainFrame:WaitForChild("Fruits")
local accessories = mainFrame:WaitForChild("Accessories")
local swords = mainFrame:WaitForChild("Swords")
local material = mainFrame:WaitForChild("Material")
local collectible = mainFrame:WaitForChild("Collectible")
local information = mainFrame:WaitForChild("Information")
local WorldsId = require(ReplicatedStorage.Chest.Modules.WorldsId)
local v = {
	[WorldsId.Testing.GoldenArena] = true,
	[WorldsId.KingLegacy.GoldenArena] = true
}
local player1_Offer = mainFrame:WaitForChild("Player1_Offer")
local player2_Offer = mainFrame:WaitForChild("Player2_Offer")
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local connections = {}
local FruitList = require(ReplicatedStorage.Chest.Modules.FruitList)
local SwordList = require(ReplicatedStorage.Chest.Modules.SwordList)
local AccessoriesList = require(ReplicatedStorage.Chest.Modules.AccessoriesList)
local TradeItemLevel = require(ReplicatedStorage.Chest.Modules.TradeItemLevel)
local Untradable = require(ReplicatedStorage.Chest.Modules.TradeItemLevel.Untradable)
local MaterialList = require(ReplicatedStorage.Chest.Modules.MaterialList)
local CollectibleList = require(ReplicatedStorage.Chest.Modules.CollectibleList)
local DFTier = require(ReplicatedStorage.Chest.Modules.DFTier)

function GetFruitRarity(p)
	for k, list in pairs(DFTier) do
		if string.find(table.concat(list, ","), p) then
			return k
		end
	end
end

function Click(p, add, amt)
	if ReplicatedStorage.Trades[localPlayer.Name]:FindFirstChild(p.Name) or add and not add then
		if ReplicatedStorage.Trades[localPlayer.Name]:FindFirstChild(p.Name) and add then
			local v7 = ReplicatedStorage.Chest.Remotes.Functions.TradeFunction:InvokeServer("PutItem", {
				ItemName = p.Name,
				Add = add,
				Amt = amt
			})

			if v7 ~= true and type(v7) == "string" then
				ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Trade Error", { v7 })
			end
		elseif ReplicatedStorage.Trades[localPlayer.Name]:FindFirstChild(p.Name) and not add then
			ReplicatedStorage.Chest.Remotes.Functions.TradeFunction:InvokeServer("RemoveItem", {
				ItemName = p.Name
			})
		end
	else
		local v7 = ReplicatedStorage.Chest.Remotes.Functions.TradeFunction:InvokeServer("PutItem", {
			ItemName = p.Name,
			Add = add,
			Amt = amt
		})

		if v7 ~= true and type(v7) == "string" then
			ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Trade Error", { v7 })
		end
	end
end

information.Add.MouseButton1Click:Connect(function()
	if v5 then
		Click(v5)
		task.spawn(function()
			_G.ClickFrameEffect({
				Sound = true
			})
		end)
		information.Visible = nil
		v5 = nil
	else
		if not v4 then
			return
		end

		local text = information.FunctionFrame.TextBox.Text

		if not tonumber(text) then
			return
		end

		Click(v4, true, text)
		task.spawn(function()
			_G.ClickFrameEffect({
				Sound = true
			})
		end)
		information.Visible = nil
		v4 = nil
	end
end)
information.Add.MouseEnter:Connect(function()
	information.Add.Size = UDim2.new(0.65, 0, 0.115, 0)
	TweenService:Create(information.Add, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.8125, 0, 0.14375000000000002, 0)
	}):Play()
end)
information.Add.MouseLeave:Connect(function()
	TweenService:Create(information.Add, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.65, 0, 0.115, 0)
	}):Play()
end)

function Get()
	local child = game.Players:FindFirstChild(tradeWith.Value)

	if not child then
		return
	end

	if child:FindFirstChild("DataLoaded") then
		return child
	end
end

function ClearOffer()
	for _, button in pairs(player1_Offer:GetChildren()) do
		if button:IsA("ImageButton") or button:IsA("TextButton") then
			button:Destroy()
		end
	end

	for _, button in pairs(player2_Offer:GetChildren()) do
		if button:IsA("ImageButton") or button:IsA("TextButton") then
			button:Destroy()
		end
	end
end

local layouts = _G.Layouts

function ClearTradeFrame(p)
	information.Visible = false

	for _, button in pairs(itemFrame:GetChildren()) do
		if button:IsA("ImageButton") or button:IsA("TextButton") then
			button:Destroy()
		end
	end
end

function UpdateInformation(data)
	local icon = data.Icon or nil

	if not icon then
		return
	end

	local getTier = data.GetTier or nil
	local dataName = data.DataName or nil
	local int = data.Int
	information.FunctionFrame.TextBox.Visible = int

	if int then
		v5 = nil
	else
		v4 = nil
	end

	information.Visible = true
	information.TierText.Text = getTier
	information.TierText.TextColor3 = TierColor[getTier]
	information.NameText.Text = icon.SwordName.Text
	information.Icon.Image = icon.ImageLabel.Image

	if v6 then
		v6:Destroy()
		v6 = nil
	end

	information.Icon.Size = UDim2.new(0, 0, 0, 0)
	information.Icon.Rotation = 180
	v6 = game.TweenService:Create(information.Icon, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
		Size = UDim2.new(0.4, 0, 0.367, 0),
		Rotation = 360
	})
	v6:Play()
	local child = game.Players:FindFirstChild(tradeWith.Value)
	local tradeStatus = information.FunctionFrame.TradeStatus

	if TradeItemLevel[dataName] and child then
		tradeStatus.Visible = true
		tradeStatus.Text = "[Require Lv. " .. TradeItemLevel[dataName] .. "]"

		if child.PlayerStats.lvl.Value >= TradeItemLevel[dataName] then
			tradeStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
		else
			tradeStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
		end
	else
		tradeStatus.Visible = nil
	end

	if MaterialList[dataName] or FruitList[dataName] then
		tradeStatus.Visible = true
		tradeStatus.Text = "[Require Lv. " .. 300 .. "]"

		if child.PlayerStats.lvl.Value >= 300 then
			tradeStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
		else
			tradeStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
		end
	end

	if Untradable[dataName] or MaterialList[dataName] and MaterialList[dataName].Fish then
		tradeStatus.Visible = true
		tradeStatus.Text = "Untradable"
		tradeStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
	end
end

function GetPlayerFruits(p)
	if not Get() then
		return
	end

	local HttpService = game:GetService("HttpService")
	local jSONDecode = HttpService:JSONDecode(localPlayer.PlayerStats.FruitStore.Value)
	local _ = localPlayer.Fruits

	if p ~= "Player2" then
		v2 = "Fruit"
	end

	for childName, v7 in pairs(jSONDecode) do
		if not FruitList[childName] then
			continue
		end

		local clone = script.TextButton:Clone()
		clone.Name = childName

		if FruitList[childName] then
			clone.ImageLabel.Image = FruitList[childName]
		end

		local getTier = GetFruitRarity(childName) or "Common"
		local image = TierImage[getTier]
		local v10

		if CustomNames[childName] then
			v10 = CustomNames[childName]
		else
			v10 = childName
		end

		clone.SwordName.Text = tostring(v10):gsub("Fruit", " Fruit")
		clone.Amount.Text = "x" .. v7
		clone.LayoutOrder = layouts[getTier]
		clone.TierImage.Image = image
		clone.ImageLabel.BackgroundColor3 = TierColor[getTier]

		if p == "Player1" then
			local icon = clone
			local getTier2 = getTier
			local dataName = childName
			clone.MouseButton1Click:Connect(function()
				task.spawn(function()
					_G.ClickFrameEffect({
						Sound = true
					})
					icon.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
					TweenService:Create(
						icon.ImageLabel,
						TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
						{
							ImageColor3 = Color3.fromRGB(0, 0, 0)
						}
					):Play()
				end)

				if v4 == icon then
					information.Visible = nil
					v4 = nil
				else
					v4 = icon
					UpdateInformation({
						GetTier = getTier2,
						Icon = icon,
						Int = true,
						DataName = dataName
					})
				end
			end)
		end

		clone.Parent = itemFrame

		if not ReplicatedStorage.Trades[localPlayer.Name]:FindFirstChild(childName) then
			continue
		end

		local v11 = v7 - ReplicatedStorage.Trades[localPlayer.Name][childName].Value
		clone.Amount.Text = "x" .. v11

		if v11 <= 0 then
			clone:Destroy()
		end
	end
end

function GetPlayerSword(p)
	if not Get() then
		return
	end

	local inventory = localPlayer.Inventory

	if p ~= "Player2" then
		v2 = "Sword"
	end

	for _, child in pairs(inventory:GetChildren()) do
		if not SwordList[child.Name] then
			continue
		end

		local clone = script.TextButton:Clone()
		clone.Name = child.Name
		local image = TierImage[SwordList[child.Name].Tier]
		local backgroundColor = TierColor[SwordList[child.Name].Tier]
		local name = child.Name

		if CustomNames[name] then
			name = CustomNames[name]
		end

		clone.SwordName.Text = name
		clone.Amount.Text = ""
		clone.LayoutOrder = layouts[SwordList[child.Name].Tier]
		clone.TierImage.Image = image
		clone.ImageLabel.BackgroundColor3 = backgroundColor

		if SwordList[child.Name].TierImage then
			clone.TierImage.Image = SwordList[child.Name].TierImage
		end

		if SwordList[child.Name] then
			clone.ImageLabel.Image = SwordList[child.Name].Image
		end

		if p == "Player1" then
			local icon = clone
			local v10 = child
			clone.MouseButton1Click:Connect(function()
				task.spawn(function()
					_G.ClickFrameEffect({
						Sound = true
					})
					icon.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
					TweenService:Create(
						icon.ImageLabel,
						TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
						{
							ImageColor3 = Color3.fromRGB(0, 0, 0)
						}
					):Play()
				end)

				if v5 == icon then
					v5 = nil
					information.Visible = nil
				else
					v5 = icon
					UpdateInformation({
						GetTier = SwordList[v10.Name].Tier,
						Icon = icon,
						DataName = v10.Name
					})
				end
			end)
		end

		if p == "Player1" and not ReplicatedStorage.Trades[localPlayer.Name]:FindFirstChild(child.Name) then
			clone.Parent = itemFrame
		elseif p == "Player2" then
			ReplicatedStorage.Trades[tradeWith.Value]:FindFirstChild(child.Name)
		end
	end
end

function GetPlayerAccessory(p)
	if not Get() then
		return
	end

	local accessories2 = localPlayer.Accessories

	if p ~= "Player2" then
		v2 = "Accessory"
	end

	for _, child in pairs(accessories2:GetChildren()) do
		if not AccessoriesList[child.Name] then
			continue
		end

		local clone = script.TextButton:Clone()
		clone.Name = child.Name

		if AccessoriesList[child.Name] then
			clone.ImageLabel.Image = AccessoriesList[child.Name].Image
		end

		local image = TierImage[AccessoriesList[child.Name].Tier]
		local backgroundColor = TierColor[AccessoriesList[child.Name].Tier]
		local name = child.Name

		if CustomNames[name] then
			name = CustomNames[name]
		end

		clone.SwordName.Text = name
		clone.Amount.Text = ""
		clone.LayoutOrder = layouts[AccessoriesList[child.Name].Tier]
		clone.TierImage.Image = image
		clone.ImageLabel.BackgroundColor3 = backgroundColor

		if AccessoriesList[child.Name].TierImage then
			clone.TierImage.Image = AccessoriesList[child.Name].TierImage
		end

		if p == "Player1" then
			local icon = clone
			local v10 = child
			clone.MouseButton1Click:Connect(function()
				task.spawn(function()
					_G.ClickFrameEffect({
						Sound = true
					})
					icon.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
					TweenService:Create(
						icon.ImageLabel,
						TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
						{
							ImageColor3 = Color3.fromRGB(0, 0, 0)
						}
					):Play()
				end)

				if v5 == icon then
					v5 = nil
					information.Visible = nil
				else
					v5 = icon
					UpdateInformation({
						GetTier = AccessoriesList[v10.Name].Tier,
						Icon = icon,
						DataName = v10.Name
					})
				end
			end)
		end

		if p == "Player1" and not ReplicatedStorage.Trades[localPlayer.Name]:FindFirstChild(child.Name) then
			clone.Parent = itemFrame
		elseif p == "Player2" then
			ReplicatedStorage.Trades[tradeWith.Value]:FindFirstChild(child.Name)
		end
	end
end

function GetPlayerMaterial(p)
	if not Get() then
		return
	end

	local HttpService = game:GetService("HttpService")
	local jSONDecode = HttpService:JSONDecode(localPlayer.PlayerStats.Material.Value)

	if p ~= "Player2" then
		v2 = "Material"
	end

	for childName, v7 in pairs(jSONDecode) do
		if not MaterialList[childName] then
			continue
		end

		local clone = script.TextButton:Clone()
		clone.Name = childName

		if MaterialList[childName] then
			clone.ImageLabel.Image = MaterialList[childName].Image
		end

		local tier = MaterialList[childName].Tier
		local image = TierImage[MaterialList[childName].Tier]
		local fixedName = MaterialList[childName].FixedName or childName

		if CustomNames[fixedName] then
			fixedName = CustomNames[fixedName]
		end

		clone.SwordName.Text = fixedName
		clone.Amount.Text = "x" .. v7
		clone.LayoutOrder = layouts[MaterialList[childName].Tier]
		clone.TierImage.Image = image
		clone.ImageLabel.BackgroundColor3 = TierColor[MaterialList[childName].Tier]

		if MaterialList[childName].TierImage then
			clone.TierImage.Image = MaterialList[childName].TierImage
		end

		if p == "Player1" then
			local icon = clone
			local getTier = tier
			local dataName = childName
			clone.MouseButton1Click:Connect(function()
				task.spawn(function()
					_G.ClickFrameEffect({
						Sound = true
					})
					icon.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
					TweenService:Create(
						icon.ImageLabel,
						TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
						{
							ImageColor3 = Color3.fromRGB(0, 0, 0)
						}
					):Play()
				end)

				if v4 == icon then
					information.Visible = nil
					v4 = nil
				else
					v4 = icon
					UpdateInformation({
						GetTier = getTier,
						Icon = icon,
						Int = true,
						DataName = dataName
					})
				end
			end)
		end

		clone.Parent = itemFrame

		if not ReplicatedStorage.Trades[localPlayer.Name]:FindFirstChild(childName) then
			continue
		end

		local v9 = v7 - ReplicatedStorage.Trades[localPlayer.Name][childName].Value
		clone.Amount.Text = "x" .. v9

		if v9 <= 0 then
			clone:Destroy()
		end
	end
end

function GetPlayerCollectible(p)
	if not Get() then
		return
	end

	local HttpService = game:GetService("HttpService")
	local jSONDecode = HttpService:JSONDecode(localPlayer.PlayerStats.Collectible.Value)

	if p ~= "Player2" then
		v2 = "Collectible"
	end

	for childName, v7 in pairs(jSONDecode) do
		if not CollectibleList[childName] then
			continue
		end

		local clone = script.TextButton:Clone()
		clone.Name = childName

		if CollectibleList[childName] then
			clone.ImageLabel.Image = CollectibleList[childName].Image
		end

		local tier = CollectibleList[childName].Tier
		local image = TierImage[CollectibleList[childName].Tier]
		local name = CollectibleList[childName].Name or childName

		if CustomNames[name] then
			name = CustomNames[name]
		end

		clone.SwordName.Text = name
		clone.Amount.Text = "x" .. v7
		clone.LayoutOrder = layouts[CollectibleList[childName].Tier]
		clone.ImageLabel.BackgroundColor3 = TierColor[CollectibleList[childName].Tier]
		clone.TierImage.Image = image

		if p == "Player1" then
			local icon = clone
			local getTier = tier
			local dataName = childName
			clone.MouseButton1Click:Connect(function()
				task.spawn(function()
					_G.ClickFrameEffect({
						Sound = true
					})
					icon.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
					TweenService:Create(
						icon.ImageLabel,
						TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
						{
							ImageColor3 = Color3.fromRGB(0, 0, 0)
						}
					):Play()
				end)

				if v4 == icon then
					information.Visible = nil
					v4 = nil
				else
					v4 = icon
					UpdateInformation({
						GetTier = getTier,
						Icon = icon,
						Int = true,
						DataName = dataName
					})
				end
			end)
		end

		clone.Parent = itemFrame

		if not ReplicatedStorage.Trades[localPlayer.Name]:FindFirstChild(childName) then
			continue
		end

		local v9 = v7 - ReplicatedStorage.Trades[localPlayer.Name][childName].Value
		clone.Amount.Text = "x" .. v7

		if v9 <= 0 then
			clone:Destroy()
		end
	end
end

function UpdateTrade(p)
	if p.Type == "Accessory" then
		ClearTradeFrame("Player1")
		GetPlayerAccessory("Player1")
	elseif p.Type == "Fruit" then
		ClearTradeFrame("Player1")
		GetPlayerFruits("Player1")
	elseif p.Type == "Sword" then
		ClearTradeFrame("Player1")
		GetPlayerSword("Player1")
	end
end

function BeingTrade()
	if tradeWith.Value == "" then
		return
	end

	local child = game.Players:FindFirstChild(tradeWith.Value)

	if not child then
		return
	end

	mainFrame.Visible = true
	information.Visible = false

	for _, connection in pairs(connections) do
		if connection.Connected then
			connection:Disconnect()
		end
	end

	v3 = nil
	ClearOffer()
	mainFrame.Ready1.Visible = false
	mainFrame.Ready2.Visible = false
	mainFrame.Ready3.Visible = false
	accept.Visible = true
	mainFrame.CountLabel.Text = ""
	task.spawn(function()
		local message = "You're trading with <font color='#55ff00'>" .. tradeWith.Value .. "</font>"

		if localPlayer.PlayerStats.Language.Value == "TH" then
			message = "คุณกำลังแลกเปลี่ยนกับ <font color='#55ff00'>" .. tradeWith.Value .. "</font>"
		end

		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Custom Text", {
			Name = "Trading With",
			Overlay = true,
			Message = message,
			Color = Color3.fromRGB(255, 255, 255)
		})
	end)
	mainFrame.TradingWith.Text = "Trading with " .. tradeWith.Value .. " [Lvl. " .. child.PlayerStats.lvl.Value .. "]"
	ClearTradeFrame("Player1")
	ClearTradeFrame("Player2")
	table.insert(connections, fruits.MouseButton1Click:Connect(function()
		ClearTradeFrame("Player1")
		GetPlayerFruits("Player1")
		task.spawn(function()
			_G.ClickFrameEffect({
				Sound = true
			})
			fruits.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
			TweenService:Create(
				fruits.ImageLabel,
				TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
				{
					ImageColor3 = Color3.fromRGB(0, 0, 0)
				}
			):Play()
		end)
	end))
	table.insert(connections, swords.MouseButton1Click:Connect(function()
		ClearTradeFrame("Player1")
		GetPlayerSword("Player1")
		task.spawn(function()
			_G.ClickFrameEffect({
				Sound = true
			})
			swords.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
			TweenService:Create(
				swords.ImageLabel,
				TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
				{
					ImageColor3 = Color3.fromRGB(0, 0, 0)
				}
			):Play()
		end)
	end))
	table.insert(connections, collectible.MouseButton1Click:Connect(function()
		ClearTradeFrame("Player1")
		GetPlayerCollectible("Player1")
		task.spawn(function()
			_G.ClickFrameEffect({
				Sound = true
			})
			collectible.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
			TweenService:Create(
				collectible.ImageLabel,
				TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
				{
					ImageColor3 = Color3.fromRGB(0, 0, 0)
				}
			):Play()
		end)
	end))
	table.insert(connections, material.MouseButton1Click:Connect(function()
		ClearTradeFrame("Player1")
		GetPlayerMaterial("Player1")
		task.spawn(function()
			_G.ClickFrameEffect({
				Sound = true
			})
			material.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
			TweenService:Create(
				material.ImageLabel,
				TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
				{
					ImageColor3 = Color3.fromRGB(0, 0, 0)
				}
			):Play()
		end)
	end))
	local humanoid = child.Character and child.Character:FindFirstChild("Humanoid")
	local humanoid2 = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")

	if humanoid2 then
		table.insert(connections, humanoid2.Died:Connect(function()
			ReplicatedStorage.Chest.Remotes.Functions.TradeFunction:InvokeServer("Decline")
		end))
	end

	if humanoid then
		table.insert(connections, humanoid.Died:Connect(function()
			ReplicatedStorage.Chest.Remotes.Functions.TradeFunction:InvokeServer("Decline")
		end))
	end

	table.insert(connections, accessories.MouseButton1Click:Connect(function()
		ClearTradeFrame("Player1")
		GetPlayerAccessory("Player1")
		task.spawn(function()
			_G.ClickFrameEffect({
				Sound = true
			})
			accessories.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
			TweenService:Create(
				accessories.ImageLabel,
				TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
				{
					ImageColor3 = Color3.fromRGB(0, 0, 0)
				}
			):Play()
		end)
	end))
	local connections2 = {}
	ReplicatedStorage.Trades:WaitForChild(localPlayer.Name).ChildAdded:Connect(function(child2)
		local clone = script.TextButton:Clone()
		clone.Name = child2.Name
		local image = nil
		local tier = nil
		local name = child2.Name

		if CustomNames[name] then
			name = CustomNames[name]
		end

		clone.SwordName.Text = name

		if FruitList[child2.Name] then
			clone.ImageLabel.Image = FruitList[child2.Name]
			tier = GetFruitRarity(child2.Name) or "Common"
			image = TierImage[tier]
			clone.LayoutOrder = layouts[tier]
			local name2 = child2.Name

			if CustomNames[name2] then
				name2 = CustomNames[name2]
			end

			clone.SwordName.Text = tostring(name2):gsub("Fruit", " Fruit")
		end

		if MaterialList[child2.Name] then
			clone.ImageLabel.Image = MaterialList[child2.Name].Image
			image = TierImage[MaterialList[child2.Name].Tier]
			clone.LayoutOrder = layouts[MaterialList[child2.Name].Tier]
			tier = MaterialList[child2.Name].Tier
		end

		if SwordList[child2.Name] then
			clone.ImageLabel.Image = SwordList[child2.Name].Image
			image = TierImage[SwordList[child2.Name].Tier]
			clone.LayoutOrder = layouts[SwordList[child2.Name].Tier]
			tier = SwordList[child2.Name].Tier
		end

		if AccessoriesList[child2.Name] then
			clone.ImageLabel.Image = AccessoriesList[child2.Name].Image
			image = TierImage[AccessoriesList[child2.Name].Tier]
			clone.LayoutOrder = layouts[AccessoriesList[child2.Name].Tier]
			tier = AccessoriesList[child2.Name].Tier
		end

		if CollectibleList[child2.Name] then
			clone.ImageLabel.Image = CollectibleList[child2.Name].Image
			clone.LayoutOrder = layouts[CollectibleList[child2.Name].Tier]
			local name2 = CollectibleList[child2.Name].Name or child2.Name

			if CustomNames[name2] then
				name2 = CustomNames[name2]
			end

			clone.SwordName.Text = name2
			image = TierImage[CollectibleList[child2.Name].Tier]
			tier = CollectibleList[child2.Name].Tier
		end

		if tier then
			clone.ImageLabel.BackgroundColor3 = TierColor[tier]
		end

		if image then
			clone.TierImage.Image = image
		end

		clone.MouseButton1Click:Connect(function()
			Click(child2)
			task.spawn(function()
				_G.ClickFrameEffect({
					Sound = true
				})
			end)
		end)
		clone.Parent = player1_Offer
		local v8 = MaterialList[child2.Name] or FruitList[child2.Name] or CollectibleList[child2.Name]

		if v8 then
			clone.Amount.Text = "x" .. child2.Value
			connections2[child2] = child2.Changed:Connect(function()
				clone.Amount.Text = "x" .. child2.Value
				local HttpService = game:GetService("HttpService")
				local jSONDecode = HttpService:JSONDecode(localPlayer.PlayerStats.FruitStore.Value)
				local HttpService2 = game:GetService("HttpService")
				local jSONDecode2 = HttpService2:JSONDecode(localPlayer.PlayerStats.Material.Value)
				local HttpService3 = game:GetService("HttpService")
				local jSONDecode3 = HttpService3:JSONDecode(localPlayer.PlayerStats.Collectible.Value)
				local v9 = jSONDecode[child2.Name] or jSONDecode2[child2.Name] or jSONDecode3[child2.Name]

				if not v9 then
					return
				end

				local v10 = v9 - child2.Value
				itemFrame[child2.Name].Amount.Text = "x" .. v10

				if v10 <= 0 then
					itemFrame[child2.Name]:Destroy()
				end
			end)
		end

		if v8 and itemFrame:FindFirstChild(child2.Name) then
			local HttpService = game:GetService("HttpService")
			local jSONDecode = HttpService:JSONDecode(localPlayer.PlayerStats.FruitStore.Value)
			local HttpService2 = game:GetService("HttpService")
			local jSONDecode2 = HttpService2:JSONDecode(localPlayer.PlayerStats.Material.Value)
			local HttpService3 = game:GetService("HttpService")
			local jSONDecode3 = HttpService3:JSONDecode(localPlayer.PlayerStats.Collectible.Value)
			local v9 = jSONDecode[child2.Name] or jSONDecode2[child2.Name] or jSONDecode3[child2.Name]

			if not v9 then
				return
			end

			local v10 = v9 - child2.Value
			itemFrame[child2.Name].Amount.Text = "x" .. v10

			if v10 <= 0 then
				itemFrame[child2.Name]:Destroy()
			end
		elseif itemFrame:FindFirstChild(child2.Name) then
			itemFrame[child2.Name]:Destroy()
		end
	end)
	ReplicatedStorage.Trades:WaitForChild(tradeWith.Value).ChildAdded:Connect(function(child2)
		local clone = script.TextButton:Clone()
		clone.Name = child2.Name
		local image = nil
		local tier = nil
		local name = child2.Name

		if CustomNames[name] then
			name = CustomNames[name]
		end

		clone.SwordName.Text = name

		if FruitList[child2.Name] then
			clone.ImageLabel.Image = FruitList[child2.Name]
			tier = GetFruitRarity(child2.Name) or "Common"
			image = TierImage[tier]
			clone.LayoutOrder = layouts[tier]
			local name2 = child2.Name

			if CustomNames[name2] then
				name2 = CustomNames[name2]
			end

			clone.SwordName.Text = tostring(name2):gsub("Fruit", " Fruit")
		end

		if MaterialList[child2.Name] then
			clone.ImageLabel.Image = MaterialList[child2.Name].Image
			tier = MaterialList[child2.Name].Tier
			image = TierImage[MaterialList[child2.Name].Tier]
			clone.LayoutOrder = layouts[MaterialList[child2.Name].Tier]
		end

		if SwordList[child2.Name] then
			clone.ImageLabel.Image = SwordList[child2.Name].Image
			tier = SwordList[child2.Name].Tier
			image = TierImage[SwordList[child2.Name].Tier]
			clone.LayoutOrder = layouts[SwordList[child2.Name].Tier]
		end

		if AccessoriesList[child2.Name] then
			clone.ImageLabel.Image = AccessoriesList[child2.Name].Image
			tier = AccessoriesList[child2.Name].Tier
			image = TierImage[AccessoriesList[child2.Name].Tier]
			clone.LayoutOrder = layouts[AccessoriesList[child2.Name].Tier]
		end

		if CollectibleList[child2.Name] then
			clone.ImageLabel.Image = CollectibleList[child2.Name].Image
			clone.LayoutOrder = layouts[CollectibleList[child2.Name].Tier]
			local name2 = CollectibleList[child2.Name].Name or child2.Name

			if CustomNames[name2] then
				name2 = CustomNames[name2]
			end

			clone.SwordName.Text = name2
			tier = CollectibleList[child2.Name].Tier
			image = TierImage[CollectibleList[child2.Name].Tier]
		end

		if tier then
			clone.ImageLabel.BackgroundColor3 = TierColor[tier]
		end

		if image then
			clone.TierImage.Image = image
		end

		clone.Parent = player2_Offer

		if MaterialList[child2.Name] or FruitList[child2.Name] or CollectibleList[child2.Name] then
			clone.Amount.Text = "x" .. child2.Value
			connections2[child2] = child2.Changed:Connect(function()
				clone.Amount.Text = "x" .. child2.Value
			end)
		end
	end)
	ReplicatedStorage.Trades:WaitForChild(localPlayer.Name).ChildRemoved:Connect(function(child2)
		local HttpService = game:GetService("HttpService")
		local jSONDecode = HttpService:JSONDecode(localPlayer.PlayerStats.Material.Value)
		local HttpService2 = game:GetService("HttpService")
		local jSONDecode2 = HttpService2:JSONDecode(localPlayer.PlayerStats.FruitStore.Value)
		local HttpService3 = game:GetService("HttpService")
		local jSONDecode3 = HttpService3:JSONDecode(localPlayer.PlayerStats.Collectible.Value)
		local v7 = FruitList[child2.Name] and "Fruit" or nil
		local v8 = SwordList[child2.Name] and "Sword" or v7
		local v9 = AccessoriesList[child2.Name] and "Accessory" or v8
		local v10 = MaterialList[child2.Name] and "Material" or v9
		local v11 = CollectibleList[child2.Name] and "Collectible" or v10

		if player1_Offer:FindFirstChild(child2.Name) then
			player1_Offer[child2.Name]:Destroy()
		end

		if v2 == v11 and v11 ~= nil then
			if itemFrame:FindFirstChild(child2.Name) then
				local v12 = MaterialList[child2.Name]
				local v13 = FruitList[child2.Name]

				if CollectibleList[child2.Name] and itemFrame:FindFirstChild(child2.Name) then
					local HttpService4 = game:GetService("HttpService")
					local jSONDecode4 = HttpService4:JSONDecode(localPlayer.PlayerStats.Collectible.Value)

					if not jSONDecode4[child2.Name] then
						return
					end

					local v14 = jSONDecode4[child2.Name]
					itemFrame[child2.Name].Amount.Text = "x" .. v14
				elseif v12 and itemFrame:FindFirstChild(child2.Name) then
					local HttpService4 = game:GetService("HttpService")
					local jSONDecode4 = HttpService4:JSONDecode(localPlayer.PlayerStats.Material.Value)

					if not jSONDecode4[child2.Name] then
						return
					end

					local v14 = jSONDecode4[child2.Name]
					itemFrame[child2.Name].Amount.Text = "x" .. v14
				elseif v13 and itemFrame:FindFirstChild(child2.Name) then
					local HttpService4 = game:GetService("HttpService")
					local jSONDecode4 = HttpService4:JSONDecode(localPlayer.PlayerStats.FruitStore.Value)

					if not jSONDecode4[child2.Name] then
						return
					end

					local v14 = jSONDecode4[child2.Name]
					itemFrame[child2.Name].Amount.Text = "x" .. v14
				end
			else
				local clone = script.TextButton:Clone()
				clone.Name = child2.Name
				local name = child2.Name

				if CustomNames[name] then
					name = CustomNames[name]
				end

				clone.SwordName.Text = name
				local tier = GetFruitRarity(child2.Name) or "Common"
				local image, tier2

				if FruitList[child2.Name] then
					clone.ImageLabel.Image = FruitList[child2.Name]
					image = TierImage[tier]
					clone.LayoutOrder = layouts[tier]
					tier2 = tier
				end

				if MaterialList[child2.Name] then
					clone.ImageLabel.Image = MaterialList[child2.Name].Image
					tier2 = MaterialList[child2.Name].Tier
					image = TierImage[MaterialList[child2.Name].Tier]
					tier = MaterialList[child2.Name].Tier
					clone.LayoutOrder = layouts[MaterialList[child2.Name].Tier]
				end

				if SwordList[child2.Name] then
					clone.ImageLabel.Image = SwordList[child2.Name].Image
					tier2 = SwordList[child2.Name].Tier
					image = TierImage[SwordList[child2.Name].Tier]
					clone.LayoutOrder = layouts[SwordList[child2.Name].Tier]
					tier = SwordList[child2.Name].Tier
				end

				if AccessoriesList[child2.Name] then
					clone.ImageLabel.Image = AccessoriesList[child2.Name].Image
					tier2 = AccessoriesList[child2.Name].Tier
					image = TierImage[AccessoriesList[child2.Name].Tier]
					clone.LayoutOrder = layouts[AccessoriesList[child2.Name].Tier]
					tier = AccessoriesList[child2.Name].Tier
				end

				if CollectibleList[child2.Name] then
					clone.ImageLabel.Image = CollectibleList[child2.Name].Image
					local name2 = CollectibleList[child2.Name].Name or child2.Name

					if CustomNames[name2] then
						name2 = CustomNames[name2]
					end

					clone.SwordName.Text = name2
					tier2 = CollectibleList[child2.Name].Tier
					image = TierImage[CollectibleList[child2.Name].Tier]
					clone.LayoutOrder = layouts[CollectibleList[child2.Name].Tier]
					tier = CollectibleList[child2.Name].Tier
				end

				local flag

				if jSONDecode[child2.Name] then
					clone.Amount.Text = "x" .. jSONDecode[child2.Name]
					flag = true
				else
					flag = nil
				end

				if jSONDecode2[child2.Name] then
					clone.Amount.Text = "x" .. jSONDecode2[child2.Name]
					flag = true
				end

				if jSONDecode3[child2.Name] then
					clone.Amount.Text = "x" .. jSONDecode3[child2.Name]
					flag = true
				end

				if tier2 then
					clone.ImageLabel.BackgroundColor3 = TierColor[tier2]
				end

				if image then
					clone.TierImage.Image = image
				end

				clone.MouseButton1Click:Connect(function()
					task.spawn(function()
						_G.ClickFrameEffect({
							Sound = true
						})
						clone.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
						TweenService:Create(
							clone.ImageLabel,
							TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
							{
								ImageColor3 = Color3.fromRGB(0, 0, 0)
							}
						):Play()
					end)

					if flag then
						if v4 == child2 then
							information.Visible = nil
							v4 = nil
						else
							v4 = child2
							UpdateInformation({
								GetTier = tier,
								Icon = clone,
								Int = true,
								DataName = child2.Name
							})
						end
					elseif v5 == clone then
						v5 = nil
						information.Visible = nil
					else
						v5 = clone
						UpdateInformation({
							GetTier = tier,
							Icon = clone,
							DataName = child2.Name
						})
					end
				end)
				clone.Parent = itemFrame
			end
		end
	end)
	ReplicatedStorage.Trades:WaitForChild(tradeWith.Value).ChildRemoved:Connect(function(child2)
		local _ = FruitList[child2.Name]
		local _ = SwordList[child2.Name]
		local _ = AccessoriesList[child2.Name]

		if player2_Offer:FindFirstChild(child2.Name) then
			player2_Offer[child2.Name]:Destroy()
		end
	end)
end

function Count()
	accept.Visible = false
	v3 = true

	for i = 10, 0, -1 do
		mainFrame.CountLabel.Text = i
		task.spawn(function()
			local clone = mainFrame.CountLabel:Clone()
			_G.PU:Dust(clone, 1)
			game.TweenService:Create(clone, TweenInfo.new(0.5), {
				Size = UDim2.new(0.504, 0, 0.333, 0),
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}):Play()
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 10000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://2610939724",
				Volume = 2
			})
			_G.PU:Dust(sound, 1)
			sound.Parent = clone
			sound:Play()
		end)

		if not v3 then
			break
		end

		wait(1)
	end
end

function CancelTrade(p)
	if not mainFrame.Visible then
		return
	end

	mainFrame.Visible = false
	information.Visible = false

	for _, connection in pairs(connections) do
		if connection.Connected then
			connection:Disconnect()
		end
	end

	ClearOffer()
	v3 = nil
	mainFrame.Ready1.Visible = false
	mainFrame.Ready2.Visible = false
	accept.Visible = true
	mainFrame.CountLabel.Text = ""

	if not p then
		ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Trade Cancel")
	end

	ClearTradeFrame("Player1")
	ClearTradeFrame("Player2")
end

function TradeSuccess()
	CancelTrade(true)
	ReplicatedStorage.Chest.Remotes.Bindables.TextAlert:Fire("Trade Success")
end

function Ready_Show(p)
	mainFrame.Ready1.Visible = p.Player1
	mainFrame.Ready2.Visible = p.Player2
	mainFrame.Ready3.Visible = p.Player1
end

accept.MouseButton1Click:Connect(function()
	if tradeWith.Value == "" then
		return
	end

	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true
		})
	end)

	if ReplicatedStorage.Chest.Remotes.Functions.TradeFunction:InvokeServer("Ready") == "Fail" then
		v3 = nil
		accept.Visible = true
		mainFrame.CountLabel.Text = ""
	end
end)
accept.MouseEnter:Connect(function()
	accept.Size = UDim2.new(0.147, 0, 0.077, 0)
	TweenService:Create(accept, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.18375, 0, 0.09625, 0)
	}):Play()
end)
accept.MouseLeave:Connect(function()
	TweenService:Create(accept, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.147, 0, 0.077, 0)
	}):Play()
end)
cancel.MouseButton1Click:Connect(function()
	ReplicatedStorage.Chest.Remotes.Functions.TradeFunction:InvokeServer("Decline")
	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true
		})
	end)
end)
cancel.MouseEnter:Connect(function()
	cancel.Size = UDim2.new(0.147, 0, 0.077, 0)
	TweenService:Create(cancel, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.18375, 0, 0.09625, 0)
	}):Play()
end)
cancel.MouseLeave:Connect(function()
	TweenService:Create(cancel, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.147, 0, 0.077, 0)
	}):Play()
end)
ReplicatedStorage.Chest.Remotes.Events.TradeEvent.OnClientEvent:Connect(function(p, p2)
	if p == "BeingTrade" then
		BeingTrade()
		return
	elseif p == "CancelTrade" then
		CancelTrade()
		return
	elseif p == "Count" then
		Count()
		return
	elseif p == "Ready" then
		Ready_Show(p2)
		return
	end

	if p ~= "TradeSuccess" then
		return
	end

	TradeSuccess()
end)

ReplicatedStorage.Chest.Remotes.Functions.SendTrade.OnClientInvoke = function(p)
	if script.Parent:FindFirstChild("TradeRequest") then
		return
	end

	local v7 = nil
	local v8 = nil
	local lastTime = tick()
	local clone = script.TradeRequest:Clone()
	clone.TextLabel.Text = p.SentName .. " wants to trade with you"
	clone.Accept.MouseButton1Click:Connect(function()
		v7 = true
		v8 = true
		task.spawn(function()
			_G.ClickFrameEffect({
				Sound = true
			})
		end)
	end)
	clone.Decline.MouseButton1Click:Connect(function()
		v8 = true
		task.spawn(function()
			_G.ClickFrameEffect({
				Sound = true
			})
		end)
	end)
	clone.Parent = script.Parent

	repeat
		wait()
	until v8 or tick() - lastTime >= 10 or localPlayer.TradeWith.Value ~= ""

	clone:Destroy()
	return v7
end