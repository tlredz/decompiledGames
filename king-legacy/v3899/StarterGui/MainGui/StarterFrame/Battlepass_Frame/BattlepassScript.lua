local localPlayer = game.Players.LocalPlayer

repeat
	wait()
until localPlayer:FindFirstChild("DataLoaded")

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerStats = localPlayer:WaitForChild("PlayerStats")
game.ReplicatedStorage:WaitForChild("Battlepass")
local battlepass = playerStats:WaitForChild("Battlepass")
local battlepassExp = playerStats:WaitForChild("BattlepassExp")
local battlepassLevel = playerStats:WaitForChild("BattlepassLevel")
local parent = script.Parent
local bTPFrame = parent:WaitForChild("BTPFrame")
local scrollingFrame = bTPFrame:WaitForChild("Grid"):WaitForChild("ScrollingFrame")
local bTPButton = parent:WaitForChild("BTPButton")
local easterEggButton = parent:WaitForChild("EasterEggButton")
local easterEggFrame = parent:WaitForChild("EasterEggFrame")
local TweenService = game:GetService("TweenService")
local v = true

function ButtonClick(instance, p)
	if not (instance and p and v) then
		return
	end

	v = nil
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
		v = true
	end)
end

bTPButton.MouseButton1Click:Connect(function()
	parent.TopicFrame.TopicName.Text = "Legacypass SS2"

	if playerStats.Language.Value == "TH" then
		parent.TopicFrame.TopicName.Text = "เลกาซี่พาส SS2"
	end

	_G.ClickFrameEffect({
		Sound = true
	})
	ButtonClick(bTPButton, bTPFrame)
end)
easterEggButton.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true
	})
	parent.TopicFrame.TopicName.Text = "Easter Pass"

	if playerStats.Language.Value == "TH" then
		parent.TopicFrame.TopicName.Text = "อีสเตอร์พาส"
	end

	ButtonClick(easterEggButton, easterEggFrame)
end)

for _, child in pairs(parent:GetChildren()) do
	if not child:GetAttribute("FirstButton") then
		continue
	end

	local parent2 = child
	child.MouseEnter:Connect(function()
		_G.ShineGui({
			Parent = parent2
		})
		parent2.TextLabel.Visible = true
	end)
	local v3 = child
	child.MouseLeave:Connect(function()
		v3.TextLabel.Visible = false
	end)
end

local BattlepassReward = require(game.ReplicatedStorage.Chest.Modules.BattlepassReward)
local AccessoriesList = require(game.ReplicatedStorage.Chest.Modules.AccessoriesList)
local TierColor = require(game.ReplicatedStorage.Chest.Modules.TierColor)
local SwordList = require(game.ReplicatedStorage.Chest.Modules.SwordList)
local CollectibleList = require(game.ReplicatedStorage.Chest.Modules.CollectibleList)
local MaterialList = require(ReplicatedStorage.Chest.Modules.MaterialList)
local clones = {}
local clones2 = {}
local clones3 = {}
local product = ReplicatedStorage.Chest.Remotes.Functions.Product

function UpdateExpbar()
	local value = math.floor(battlepassExp.Value)
	local v2 = math.floor(500 + (battlepassLevel.Value * 500) ^ 1.15)
	local v3 = value / v2
	local TweenService2 = game:GetService("TweenService")
	TweenService2:Create(bTPFrame.EXP.Line, TweenInfo.new(0.1), {
		Size = UDim2.new(v3, 0, 1, 0)
	}):Play()
	bTPFrame.EXP.TextLabel.Text = "EXP " .. value .. "/" .. v2
	bTPFrame.EXP.LevelLabel.Text = "LEVEL " .. battlepassLevel.Value
	bTPFrame.EXP.NextLevelLabel.Text = "LEVEL " .. battlepassLevel.Value + 1
end

function UpdateViewing()
	local X = scrollingFrame.CanvasPosition.X
	local X2 = scrollingFrame.AbsoluteSize.X

	for _, v2 in ipairs(clones) do
		local offset = v2.Position.X.Offset
		v2.Visible = X <= offset + v2.AbsoluteSize.X and offset <= X + X2
	end

	for _, v2 in ipairs(clones3) do
		local offset = v2.Position.X.Offset
		v2.Visible = X <= offset + v2.AbsoluteSize.X and offset <= X + X2
	end

	for _, v2 in ipairs(clones2) do
		local offset = v2.Position.X.Offset
		v2.Visible = X <= offset + v2.AbsoluteSize.X and offset <= X + X2
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
		task.wait(0.06666666666666667)

		if os.clock() - lastTime > 0.1 then
			break
		end

		UpdateViewing()
	end

	flag = nil
	UpdateViewing()
end

scrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(BeginScrolling)

function UpdateGrid()
	local absoluteSize = scrollingFrame.AbsoluteSize
	local v2 = absoluteSize.X * 0.14 + 5
	local _ = absoluteSize.Y

	for i, v3 in ipairs(clones) do
		v3.Size = UDim2.fromOffset(v2, v2)
		v3.Position = UDim2.fromOffset((i - 1) * v2, 0)
	end

	for i, v3 in ipairs(clones3) do
		v3.Size = UDim2.fromOffset(v2, scrollingFrame.Level.AbsoluteSize.Y)
		v3.Position = UDim2.fromOffset((i - 1) * v2, 0)
	end

	for i, v3 in ipairs(clones2) do
		v3.Size = UDim2.fromOffset(v2, v2)
		v3.Position = UDim2.fromOffset((i - 1) * v2, 0)
	end

	scrollingFrame.CanvasSize = UDim2.fromOffset(#clones3 * v2, 0)
	UpdateViewing()
end

function ShowUnlockFrames(visible)
	for _, child in pairs(bTPFrame.Grid.UnlockFrame:GetChildren()) do
		child.Visible = visible
	end
end

function UpdateBattlepass()
	wait()
	UpdateExpbar()
	local jSONDecode = HttpService:JSONDecode(battlepass.Value)
	local freeClaim = jSONDecode.FreeClaim or {}
	local goldClaim = jSONDecode.GoldClaim or {}
	local goldPass = jSONDecode.GoldPass

	local function IsClaimed(items, p, p2)
		if BattlepassReward[p2]["Tier" .. p].Type == "Empty" then
			return nil
		end

		for _, item in pairs(items) do
			if item == p then
				return true
			end
		end

		return nil
	end

	local visible = nil

	for i = 1, 50 do
		local child = scrollingFrame.Free:FindFirstChild("Tier" .. i)
		local child2 = scrollingFrame.Gold:FindFirstChild("Tier" .. i)
		local child3 = scrollingFrame.Level:FindFirstChild("Level" .. i)

		if not (child and child2 and child3) then
			continue
		end

		if i <= battlepassLevel.Value then
			child3.ImageColor3 = Color3.fromRGB(255, 255, 255)
			child.ImageColor3 = Color3.fromRGB(255, 255, 255)

			if jSONDecode.GoldPass then
				child2.ImageColor3 = Color3.fromRGB(255, 217, 65)
				child2.ItemImage.ImageTransparency = 0
				child2.Reward.TextTransparency = 0
				child2.Reward.TextStrokeTransparency = 0
			else
				child2.ImageColor3 = Color3.fromRGB(83, 70, 21)
				child2.ItemImage.ImageTransparency = 0.5
				child2.Reward.TextTransparency = 0.5
				child2.Reward.TextStrokeTransparency = 0.5
			end

			child.ItemImage.ImageTransparency = 0
			child.Reward.TextTransparency = 0
			child.Reward.TextStrokeTransparency = 0

			if BattlepassReward.Free["Tier" .. i] and BattlepassReward.Free["Tier" .. i].Type ~= "Empty" then
				local flag2

				if BattlepassReward.Free["Tier" .. i].Type ~= "Empty" then
					local flag3 = true

					for _, v3 in pairs(freeClaim) do
						if v3 ~= i then
							continue
						end

						flag2 = true
						flag3 = false
						break
					end

					if flag3 then
						flag2 = nil
					end
				end

				if flag2 then
					child.Claim.Visible = false
					child.Claimed.Visible = true
				else
					child.Claim.Visible = true
					child.Claimed.Visible = false
					visible = true
				end
			end

			if BattlepassReward.Gold["Tier" .. i] and BattlepassReward.Gold["Tier" .. i].Type ~= "Empty" then
				if jSONDecode.GoldPass then
					local flag2

					if BattlepassReward.Gold["Tier" .. i].Type ~= "Empty" then
						local flag3 = true

						for _, v3 in pairs(goldClaim) do
							if v3 ~= i then
								continue
							end

							flag2 = true
							flag3 = false
							break
						end

						if flag3 then
							flag2 = nil
						end
					end

					if flag2 then
						child2.Claim.Visible = false
						child2.Claimed.Visible = true
						child2.Claimed.ImageColor3 = Color3.fromRGB(255, 235, 15)
					else
						child2.Claim.Visible = true
						child2.Claimed.Visible = false
						visible = true
					end
				else
					child2.Claim.Visible = false
					child2.Claimed.Visible = false
					child2.Claimed.ImageColor3 = Color3.fromRGB(255, 235, 15)
				end
			end
		else
			child.ImageColor3 = Color3.fromRGB(91, 91, 91)
			child2.ImageColor3 = Color3.fromRGB(83, 70, 21)
			child3.ImageColor3 = Color3.fromRGB(91, 91, 91)
			child.ItemImage.ImageTransparency = 0.5
			child.Reward.TextTransparency = 0.5
			child.Reward.TextStrokeTransparency = 0.5
			child2.ItemImage.ImageTransparency = 0.5
			child2.Reward.TextTransparency = 0.5
			child2.Reward.TextStrokeTransparency = 0.5
			child.Claim.Visible = false
			child.Claimed.Visible = false
			child2.Claim.Visible = false
			child2.Claimed.Visible = false
		end
	end

	if goldPass then
		bTPFrame.ConfirmFrame.Visible = nil
		bTPFrame.Grid.UnlockFrame.Visible = nil
	else
		ShowUnlockFrames(true)
		bTPFrame.ConfirmFrame.Visible = nil
		bTPFrame.Grid.UnlockFrame.Visible = true
	end

	bTPFrame.ButtonFrame.ClaimAll.Visible = visible
end

for i = 1, 50 do
	local clone = script.ImageLabel:Clone()
	clone.LayoutOrder = i
	clone.Name = "Tier" .. i
	local v2 = i
	clone.Claim.MouseButton1Click:Connect(function()
		if game.ReplicatedStorage.Chest.Remotes.Functions.ClaimBattlepass:InvokeServer("Free", v2) then
			UpdateBattlepass()
			parent.FreeReward:Play()
		end
	end)
	local v3 = BattlepassReward.Free["Tier" .. i]

	if v3 then
		if v3.Type == "Beli" then
			local amt = tonumber(v3.Amt)
			local image

			if amt >= 5000 and amt < 10000 then
				image = "rbxassetid://108273888550234"
			elseif amt >= 10000 and amt < 15000 then
				image = "rbxassetid://107380114629649"
			elseif amt >= 15000 and amt < 20000 then
				image = "rbxassetid://78518053739256"
			elseif amt >= 20000 then
				image = "rbxassetid://76440874344864"
			else
				image = "rbxassetid://125177784195562"
			end

			clone.Reward.TextColor3 = Color3.fromRGB(255, 220, 23)
			clone.Reward.Text = _G.Suffix_Comma(amt)
			clone.ItemImage.Image = image
		end

		local v4 = (v3.Type == "PermanentFruit" or v3.Type == "Collectible" or v3.Type == "InstantUseCollectible") and CollectibleList[v3.ItemName]

		if v4 then
			clone.Reward.Text = v4.Name or v3.ItemName
			clone.ItemImage.Image = v4.Image

			if v3.Type == "InstantUseCollectible" then
				clone.Reward.Text = "Auto-Use"
			elseif v3.Amt then
				clone.Reward.Text = "x" .. _G.Suffix_Comma(v3.Amt)
			end
		end

		if v3.Type == "Gem" then
			local amt = tonumber(v3.Amt)
			local image

			if amt >= 5 and amt < 10 then
				image = "rbxassetid://86210177389251"
			elseif amt >= 10 and amt < 20 then
				image = "rbxassetid://75913161559538"
			elseif amt >= 20 and amt < 30 then
				image = "rbxassetid://106547378840571"
			elseif amt >= 30 then
				image = "rbxassetid://112630312321366"
			else
				image = "rbxassetid://88515569255432"
			end

			clone.Reward.TextColor3 = Color3.fromRGB(229, 32, 255)
			clone.Reward.Text = "x" .. _G.Suffix_Comma(amt)
			clone.ItemImage.Image = image
		end

		if v3.Type == "RandomMaterial" then
			local rarity = v3.Rarity
			local image

			if rarity == "Uncommon" then
				image = "http://www.roblox.com/asset/?id=11961523908"
			elseif rarity == "Rare" then
				image = "http://www.roblox.com/asset/?id=11961523484"
			elseif rarity == "Epic" then
				image = "http://www.roblox.com/asset/?id=11961521994"
			elseif rarity == "Legendary" then
				image = "http://www.roblox.com/asset/?id=11961520465"
			else
				image = "http://www.roblox.com/asset/?id=11961524728"
			end

			clone.Reward.TextColor3 = Color3.fromRGB(255, 255, 255)
			clone.Reward.Text = rarity .. " Material"
			clone.ItemImage.Image = image
		end

		if v3.Type == "RandomFruit" then
			local rarity = v3.Rarity
			local image

			if rarity == "Uncommon" then
				image = "rbxassetid://9170466907"
			elseif rarity == "Rare" then
				image = "rbxassetid://9170467299"
			elseif rarity == "Epic" then
				image = "rbxassetid://9170467728"
			elseif rarity == "Legendary" then
				image = "rbxassetid://9170468009"
			else
				image = "rbxassetid://8704131464"
			end

			clone.Reward.TextColor3 = Color3.fromRGB(255, 255, 255)
			clone.Reward.Text = rarity .. " Fruit"
			clone.ItemImage.Image = image
		end

		if v3.Type == "Accessory" then
			local itemName = v3.ItemName

			if AccessoriesList[itemName] then
				local image = AccessoriesList[itemName].Image
				local textColor = TierColor[AccessoriesList[itemName].Tier] or Color3.fromRGB(255, 255, 255)
				clone.Reward.TextColor3 = textColor
				clone.Reward.Text = itemName
				clone.ItemImage.Image = image
			end
		end

		if v3.Type == "Sword" and SwordList[v3.ItemName] then
			local image = SwordList[v3.ItemName].Image
			local textColor = TierColor[SwordList[v3.ItemName].Tier] or Color3.fromRGB(255, 255, 255)
			clone.Reward.TextColor3 = textColor
			clone.Reward.Text = v3.ItemName
			clone.ItemImage.Image = image
		end

		if v3.Type == "Material" and MaterialList[v3.ItemName] then
			local image = MaterialList[v3.ItemName].Image
			local textColor = TierColor[MaterialList[v3.ItemName].Tier]
			clone.Reward.TextColor3 = textColor
			clone.Reward.Text = v3.ItemName
			clone.ItemImage.Image = image

			if v3.Amt then
				clone.Reward.Text = "x" .. _G.Suffix_Comma(v3.Amt)
			end
		end
	end

	clone.Parent = scrollingFrame.Free
	table.insert(clones, clone)
end

for i = 1, 50 do
	local clone = script.ImageLabel:Clone()
	clone.LayoutOrder = i
	clone.Name = "Tier" .. i
	clone.ImageColor3 = Color3.fromRGB(255, 217, 65)
	local v2 = i
	clone.Claim.MouseButton1Click:Connect(function()
		if game.ReplicatedStorage.Chest.Remotes.Functions.ClaimBattlepass:InvokeServer("Gold", v2) then
			UpdateBattlepass()
			parent.GoldReward:Play()
		end
	end)
	local v3 = BattlepassReward.Gold["Tier" .. i]

	if v3 then
		if v3.Type == "Beli" then
			local amt = tonumber(v3.Amt)
			local image

			if amt >= 5000 and amt < 10000 then
				image = "rbxassetid://108273888550234"
			elseif amt >= 10000 and amt < 15000 then
				image = "rbxassetid://107380114629649"
			elseif amt >= 15000 and amt < 20000 then
				image = "rbxassetid://78518053739256"
			elseif amt >= 20000 then
				image = "rbxassetid://76440874344864"
			else
				image = "rbxassetid://125177784195562"
			end

			clone.Reward.TextColor3 = Color3.fromRGB(255, 220, 23)
			clone.Reward.Text = _G.Suffix_Comma(amt)
			clone.ItemImage.Image = image
		end

		local v4 = (v3.Type == "PermanentFruit" or v3.Type == "Collectible" or v3.Type == "InstantUseCollectible") and CollectibleList[v3.ItemName]

		if v4 then
			clone.Reward.Text = v4.Name or v3.ItemName
			clone.ItemImage.Image = v4.Image

			if v3.Type == "InstantUseCollectible" then
				clone.Reward.Text = "Auto-Use"
			elseif v3.Amt then
				clone.Reward.Text = "x" .. _G.Suffix_Comma(v3.Amt)
			end
		end

		if v3.Type == "Gem" then
			local amt = tonumber(v3.Amt)
			local image

			if amt >= 5 and amt < 10 then
				image = "rbxassetid://86210177389251"
			elseif amt >= 10 and amt < 20 then
				image = "rbxassetid://75913161559538"
			elseif amt >= 20 and amt < 30 then
				image = "rbxassetid://106547378840571"
			elseif amt >= 30 then
				image = "rbxassetid://112630312321366"
			else
				image = "rbxassetid://88515569255432"
			end

			clone.Reward.TextColor3 = Color3.fromRGB(229, 32, 255)
			clone.Reward.Text = "x" .. _G.Suffix_Comma(amt)
			clone.ItemImage.Image = image
		end

		if v3.Type == "RandomMaterial" then
			local rarity = v3.Rarity
			local image

			if rarity == "Uncommon" then
				image = "http://www.roblox.com/asset/?id=11961523908"
			elseif rarity == "Rare" then
				image = "http://www.roblox.com/asset/?id=11961523484"
			elseif rarity == "Epic" then
				image = "http://www.roblox.com/asset/?id=11961521994"
			elseif rarity == "Legendary" then
				image = "http://www.roblox.com/asset/?id=11961520465"
			else
				image = "http://www.roblox.com/asset/?id=11961524728"
			end

			clone.Reward.TextColor3 = Color3.fromRGB(255, 255, 255)
			clone.Reward.Text = rarity .. " Material"
			clone.ItemImage.Image = image
		end

		if v3.Type == "RandomFruit" then
			local rarity = v3.Rarity
			local image

			if rarity == "Uncommon" then
				image = "rbxassetid://9170466907"
			elseif rarity == "Rare" then
				image = "rbxassetid://9170467299"
			elseif rarity == "Epic" then
				image = "rbxassetid://9170467728"
			elseif rarity == "Legendary" then
				image = "rbxassetid://9170468009"
			else
				image = "rbxassetid://8704131464"
			end

			clone.Reward.TextColor3 = Color3.fromRGB(255, 255, 255)
			clone.Reward.Text = rarity .. " Fruit"
			clone.ItemImage.Image = image
		end

		if v3.Type == "Accessory" then
			local itemName = v3.ItemName

			if AccessoriesList[itemName] then
				local image = AccessoriesList[itemName].Image
				local textColor = TierColor[AccessoriesList[itemName].Tier] or Color3.fromRGB(255, 255, 255)
				clone.Reward.TextColor3 = textColor
				clone.Reward.Text = itemName
				clone.ItemImage.Image = image
			end
		end

		if v3.Type == "Sword" and SwordList[v3.ItemName] then
			local image = SwordList[v3.ItemName].Image
			local textColor = TierColor[SwordList[v3.ItemName].Tier] or Color3.fromRGB(255, 255, 255)
			clone.Reward.TextColor3 = textColor
			clone.Reward.Text = v3.ItemName
			clone.ItemImage.Image = image
		end

		if v3.Type == "Material" and MaterialList[v3.ItemName] then
			local image = MaterialList[v3.ItemName].Image
			local textColor = TierColor[MaterialList[v3.ItemName].Tier]
			clone.Reward.TextColor3 = textColor
			clone.Reward.Text = v3.ItemName
			clone.ItemImage.Image = image

			if v3.Amt then
				clone.Reward.Text = "x" .. _G.Suffix_Comma(v3.Amt)
			end
		end
	end

	clone.Parent = scrollingFrame.Gold
	table.insert(clones2, clone)
end

for i = 1, 50 do
	local clone = script.LevelLabel:Clone()
	clone.LayoutOrder = i
	clone.Tier.Text = i
	clone.Name = "Level" .. i
	clone.ImageColor3 = Color3.fromRGB(255, 255, 255)
	clone.Parent = scrollingFrame.Level
	table.insert(clones3, clone)
end

bTPFrame.ButtonFrame.ClaimAll.MouseButton1Click:Connect(function()
	if game.ReplicatedStorage.Chest.Remotes.Functions.ClaimAllBattlepass:InvokeServer() then
		UpdateBattlepass()
		parent.RewardAll:Play()
	end
end)
bTPFrame.Grid.UnlockFrame.UnlockProduct.MouseButton1Click:Connect(function()
	product:InvokeServer({
		ProductName = "Battlepass",
		PurchaseType = "Transfer"
	})
end)
bTPFrame.Grid.UnlockFrame.UnlockGem.MouseButton1Click:Connect(function()
	if HttpService:JSONDecode(battlepass.Value).GoldPass then
		return
	end

	bTPFrame.ConfirmFrame.Visible = true
	ShowUnlockFrames(nil)
end)
bTPFrame.ConfirmFrame.Close.MouseButton1Click:Connect(function()
	bTPFrame.ConfirmFrame.Visible = false
	ShowUnlockFrames(true)
end)
bTPFrame.ConfirmFrame.Unlock.MouseButton1Click:Connect(function()
	if game.ReplicatedStorage.Chest.Remotes.Functions.BuyBattlepass:InvokeServer() then
		UpdateBattlepass()
	end
end)
UpdateBattlepass()
UpdateExpbar()
battlepassExp.Changed:Connect(UpdateBattlepass)
battlepassLevel.Changed:Connect(UpdateBattlepass)
battlepass.Changed:Connect(UpdateBattlepass)
scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateGrid)
wait(1)
UpdateGrid()