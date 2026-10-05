local Players = game:GetService("Players")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local localPlayer = Players.LocalPlayer
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local modules = ReplicatedStorage:WaitForChild("Modules")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local sound_Effect = ReplicatedStorage:WaitForChild("Sound_Effect")
local guiEvents = otherEvent:WaitForChild("GuiEvents")
local buyEvents = otherEvent:WaitForChild("BuyEvents")
local shopAssets = ReplicatedStorage:WaitForChild("GuiTemplate"):WaitForChild("ShopAssets")
local Setting = require(moduleScript:WaitForChild("Setting"))
local Gamepass_Assets = require(moduleScript:WaitForChild("Gamepass_Assets"))
local Abbreviate = require(moduleScript:WaitForChild("Abbreviate"))
local SetText = require(moduleScript:WaitForChild("SetText"))
require(moduleScript:WaitForChild("Setting"))
local FadeModule = require(modules:WaitForChild("FadeModule"))
localPlayer:WaitForChild("PlayerData", 60)
local playerSpecial = localPlayer:WaitForChild("PlayerSpecial", 60)
local doubleExp = playerSpecial:WaitForChild("DoubleExp")
local doubleMoney = playerSpecial:WaitForChild("DoubleMoney")
local lucky = playerSpecial:WaitForChild("Lucky")
local capybara = playerSpecial:WaitForChild("Capybara")
local noob = playerSpecial:WaitForChild("Noob")
local doubleGem = playerSpecial:WaitForChild("DoubleGem")
local doubleDrop = playerSpecial:WaitForChild("DoubleDrop")
local parent = script.Parent.Parent.Parent.Parent
local parent2 = script.Parent
local container = parent2:WaitForChild("Container")
local allMenu = parent2.Parent.Parent.AllMenu
local gamepass_Container = container:WaitForChild("Gamepass_Container")
local giftGamepass_Container = container:WaitForChild("GiftGamepass_Container")
local _ = container.Heading
local buyFrame = parent2.BuyFrame
local playerListFrame = parent2:WaitForChild("PlayerListFrame")
local player_Container = playerListFrame.Frame:WaitForChild("Player_Container")
local giftText = playerListFrame.Frame:WaitForChild("GiftText")
local uIGridLayout = player_Container:WaitForChild("UIGridLayout")
local connections = {}
local template = script:WaitForChild("Template")
local giftTemplate = script:WaitForChild("GiftTemplate")
local gifting_Template = shopAssets:WaitForChild("Gifting_Template")
local buyProduct = buyEvents:WaitForChild("BuyProduct")
local guiEvent = guiEvents:WaitForChild("GuiEvent")
local v = {
	[62333932] = doubleMoney,
	[62333681] = doubleExp,
	[86944271] = doubleGem,
	[62334017] = lucky,
	[135099474] = capybara,
	[830466630] = noob,
	[876020870] = doubleDrop
}
local gamepasses_Cost = Setting.Setting.Gamepasses_Cost
local connections2 = {}
local v2 = {
	[62333932] = "DoubleMoney",
	[62333681] = "DoubleExp",
	[86944271] = "DoubleGem",
	[62334017] = "Lucky",
	[135099474] = "Capybara",
	[830466630] = "Noob",
	[876020870] = "DoubleDrop"
}
local v3 = {
	DoubleMoney = "Double Money",
	DoubleExp = "Double Exp",
	DoubleGem = "Double Gem",
	Lucky = "Lucky",
	Capybara = "Capybara",
	Noob = "Noob",
	DoubleDrop = "2x Item Drops"
}
local v4 = {
	[62333932] = {
		Name = "Double Money",
		Description = {
			English = "Gain 2x money from quests and NPC rewards",
			Thai = "ได้รับเงิน x2 จากภารกิจและรางวัล จากการสังหาร Npc"
		},
		Gradient_Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(85, 255, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 229, 92))
		})
	},
	[62333681] = {
		Name = "Double Exp",
		Description = {
			English = "Gain 2x exp from quests and NPC rewards",
			Thai = [[
ได้รับค่าประสบการณ์ x2 จากภารกิจ
และรางวัลจากการสังหาร Npc]]
		},
		Gradient_Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(228, 233, 93)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(232, 157, 31))
		})
	},
	[86944271] = {
		Name = "Double Gem",
		Description = {
			English = "Gain 2x gem from NPC rewards",
			Thai = "ได้รับเพชรมากกว่าเดิม x2 จากการสังหาร Npc"
		},
		Gradient_Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(217, 0, 255))
		})
	},
	[62334017] = {
		Name = "Lucky",
		Description = {
			English = "Gain +1x luck for better luck on power gacha.",
			Thai = "ได้รับโชค +1 สำหรับโชคที่ดีขึ้น จากการสุ่มกาชาพลังพิเศษ"
		},
		Gradient_Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(7, 200, 249)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 75, 255))
		})
	},
	[135099474] = {
		Name = "Capybara",
		Description = {
			English = "Unlock the Capybara Boat",
			Thai = "ปลดล็อคเรือสุดเร็วแรงอย่างเรือ Capybara ด้วยการซื้อเกมพาสนี้"
		},
		Gradient_Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(247, 154, 211)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(247, 190, 255))
		})
	},
	[830466630] = {
		Name = "Noob Boat",
		Description = {
			English = "Unlock access to the Noob Boat",
			Thai = "ปลดล็อคเรือ Noob สุดเท่ และมีประโยชน์ด้วยการซื้อเกมพาสนี้"
		},
		Gradient_Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(246, 252, 156)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(234, 248, 24))
		})
	},
	[876020870] = {
		Name = "2x Item Drops",
		Description = {
			English = "Double your chances of getting item drops from NPC rewards",
			Thai = "เพิ่มโอกาสดรอปไอเทม 2 เท่าจากการสังหาร Npc "
		},
		Gradient_Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 191, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(71, 200, 255))
		})
	}
}

local function OpeningThisFrame()
	return parent.Visible == true and parent.Position == UDim2.new(0.5, 0, 0.5, 0) and allMenu:GetAttribute("CurrentOpen") == parent2.Name
end

local function TextColor(p, p2)
	if p and p2 then
		return (`<font color="rgb({p2})">{p}</font>`)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetContentSize()
	player_Container.CanvasSize = UDim2.new(
		0,
		uIGridLayout.AbsoluteContentSize.X,
		0,
		uIGridLayout.AbsoluteContentSize.Y
	)
end

local function GeneratePlayer()
	for _, button in ipairs(player_Container:GetChildren()) do
		if button:IsA("GuiButton") then
			button:Destroy()
		end
	end

	for _, connection in ipairs(connections) do
		if connection then
			connection:Disconnect()
		end
	end

	table.clear(connections)

	for _, v5 in ipairs(Players:GetPlayers()) do
		local clone = gifting_Template:Clone()
		clone.Name = v5.Name
		clone.Player_Name.Text = `{v5.DisplayName} (@{v5.Name})`
		clone.LayoutOrder = 1

		if localPlayer:IsFriendsWith(v5.UserId) then
			clone.LayoutOrder -= 1
		elseif localPlayer.UserId == v5.UserId then
			clone.LayoutOrder -= 2
		end

		clone.Parent = player_Container
		clone.Visible = true
		local v6 = v5
		connections[#connections + 1] = clone.Activated:Connect(function()
			if Players:FindFirstChild(v6.Name) then
				script:SetAttribute("Gifting", v6.Name)

				if playerListFrame.Visible then
					Active_GiftFrame(false)
				end
			else
				script:SetAttribute("Gifting", "None")

				if playerListFrame.Visible then
					Active_GiftFrame(false)
				end
			end
		end)
	end
end

local function RemoveSpace(value)
	return value:gsub(" ", "")
end

local function GetNameFrom_PassID(p)
	return v2[p]
end

local function GenerateGiftGamepass()
	for _, frame in ipairs(giftGamepass_Container:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	for _, connection in ipairs(connections2) do
		if connection then
			connection:Disconnect()
		end
	end

	table.clear(connections2)
	local _, result = pcall(function()
		for _, gamepass_Asset in ipairs(Gamepass_Assets) do
			local gamepassId = gamepass_Asset.GamepassId
			local productId = gamepass_Asset.ProductId
			local asset_Name = gamepass_Asset.Asset_Name
			local productInfo = MarketplaceService:GetProductInfo(gamepassId, Enum.InfoType.GamePass)

			if not (productInfo and productInfo.IsForSale) then
				continue
			end

			local v5 = v4[gamepassId]

			if not v5 then
				continue
			end

			local clone = giftTemplate:Clone()
			clone.Name = v2[productInfo.TargetId]
			clone.Title.Text = v3[clone.Name]
			local description = clone.Description
			local text

			if localPlayer:GetAttribute("TH") then
				text = v5.Description.Thai
			else
				text = v5.Description.English
			end

			description.Text = text
			clone.UIGradient.Color = v5.Gradient_Color
			clone.UIStroke.UIGradient.Color = v5.Gradient_Color
			clone.Colour.UIGradient.Color = v5.Gradient_Color
			clone.Title.UIGradient.Color = v5.Gradient_Color
			clone.Title.UIStroke.UIGradient.Color = v5.Gradient_Color
			clone.Logo.Image = `rbxassetid://{productInfo.IconImageAssetId}`
			clone:SetAttribute("RobuxPrice", productInfo.PriceInRobux)
			clone:SetAttribute("TH_Description", v5.Description.Thai)
			clone:SetAttribute("ENG_Description", v5.Description.English)
			clone.Price.Text = ` {clone:GetAttribute("RobuxPrice")}`
			clone.Visible = true
			clone.Parent = giftGamepass_Container
			local productName = asset_Name
			local productId2 = productId
			connections2[#connections2 + 1] = clone.Buy_Robux.Activated:Connect(function()
				local child = Players:FindFirstChild(script:GetAttribute("Gifting"))

				if script:GetAttribute("Gifting") == "None" or script:GetAttribute("Gifting") == localPlayer.Name then
					giftGamepass_Container.Visible = false
					gamepass_Container.Visible = true
					script:SetAttribute("Gifting", "None")
				elseif child then
					if child:GetAttribute("LoadedData") == true then
						local playerSpecial2 = child:FindFirstChild("PlayerSpecial")

						if playerSpecial2 then
							local child2 = playerSpecial2:FindFirstChild(productName)

							if child2 and child2.Value == false then
								buyProduct:FireServer({
									Action = "Gift_Gamepass",
									Target = child.Name,
									ProductName = productName,
									ProductId = productId2
								})
							elseif localPlayer:GetAttribute("TH") then
								SetText.SetText(localPlayer, "CustomMessage", {
									Message = `{child.Name} เป็นเจ้าของเกมพาสนี้อยู่แล้ว!`,
									MessageColor = "Red"
								})
							else
								SetText.SetText(localPlayer, "CustomMessage", {
									Message = `{child.Name} already owns this gamepass!`,
									MessageColor = "Red"
								})
							end
						end
					elseif localPlayer:GetAttribute("TH") then
						local setText = SetText.SetText
						local gifting = script:GetAttribute("Gifting")
						local v13

						if gifting then
							v13 = `<font color="rgb(255,100,100)">{gifting}</font>`
						end

						setText(localPlayer, "CustomMessage", {
							Message = `{v13} ยังโหลดไม่เสร็จ!`,
							MessageColor = "White"
						})
					else
						local setText = SetText.SetText
						local gifting = script:GetAttribute("Gifting")
						local v13

						if gifting then
							v13 = `<font color="rgb(255,100,100)">{gifting}</font>`
						end

						setText(localPlayer, "CustomMessage", {
							Message = `{v13} hasn't loaded yet!`,
							MessageColor = "White"
						})
					end
				else
					if localPlayer:GetAttribute("TH") then
						local setText = SetText.SetText
						local gifting = script:GetAttribute("Gifting")
						local v13

						if gifting then
							v13 = `<font color="rgb(255,100,100)">{gifting}</font>`
						end

						setText(localPlayer, "CustomMessage", {
							Message = `{v13} ไม่ได้อยู่ในเซิร์ฟเวอร์แล้ว!`,
							MessageColor = "White"
						})
					else
						local setText = SetText.SetText
						local gifting = script:GetAttribute("Gifting")
						local v13

						if gifting then
							v13 = `<font color="rgb(255,100,100)">{gifting}</font>`
						end

						setText(localPlayer, "CustomMessage", {
							Message = `{v13} is no longer on the server!`,
							MessageColor = "White"
						})
					end

					script:SetAttribute("Gifting", "None")
				end
			end)
		end
	end)

	if result then
		warn(result)
	end
end

local function GenerateGamepass()
	for _, frame in ipairs(gamepass_Container:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	for _, connection in ipairs(connections2) do
		if connection then
			connection:Disconnect()
		end
	end

	table.clear(connections2)
	local _, result = pcall(function()
		for _, gamepass_Asset in ipairs(Gamepass_Assets) do
			local gamepassId = gamepass_Asset.GamepassId
			local productInfo = MarketplaceService:GetProductInfo(gamepassId, Enum.InfoType.GamePass)

			if not (productInfo and productInfo.IsForSale) then
				continue
			end

			local v5 = v4[gamepassId]

			if not v5 then
				continue
			end

			local clone = template:Clone()
			clone.Name = v2[productInfo.TargetId]
			clone.Title.Text = v3[clone.Name]
			local description = clone.Description
			local text

			if localPlayer:GetAttribute("TH") then
				text = v5.Description.Thai
			else
				text = v5.Description.English
			end

			description.Text = text
			clone.UIGradient.Color = v5.Gradient_Color
			clone.UIStroke.UIGradient.Color = v5.Gradient_Color
			clone.Colour.UIGradient.Color = v5.Gradient_Color
			clone.Title.UIGradient.Color = v5.Gradient_Color
			clone.Title.UIStroke.UIGradient.Color = v5.Gradient_Color
			clone.Logo.Image = `rbxassetid://{productInfo.IconImageAssetId}`
			clone:SetAttribute("RobuxPrice", productInfo.PriceInRobux)
			clone:SetAttribute("GemPrice", gamepasses_Cost[clone.Name])
			clone:SetAttribute("TH_Description", v5.Description.Thai)
			clone:SetAttribute("ENG_Description", v5.Description.English)
			clone.Buy_Robux.Price_Frame.Textlabel.Text = ` {clone:GetAttribute("RobuxPrice")}`
			clone.Buy_Gem.Price_Frame.Textlabel.Text = `{Abbreviate.Comma(clone:GetAttribute("GemPrice"))}`
			clone.Visible = true
			clone.Parent = gamepass_Container
			local gamepassId2 = gamepassId
			connections2[#connections2 + 1] = clone.Buy_Robux.Activated:Connect(function()
				if buyFrame.Visible == false then
					buyFrame:SetAttribute("GamepassId", gamepassId2)
					buyFrame:SetAttribute("Type", "Robux")
					buyFrame:SetAttribute("Price", clone:GetAttribute("RobuxPrice"))
					Active_BuyFrame(true, clone)
				end
			end)
			local gamepassId3 = gamepassId
			local v10 = clone
			connections2[#connections2 + 1] = clone.Buy_Gem.Activated:Connect(function()
				if buyFrame.Visible == false then
					buyFrame:SetAttribute("GamepassId", gamepassId3)
					buyFrame:SetAttribute("Type", "Gem")
					buyFrame:SetAttribute("Price", v10:GetAttribute("GemPrice"))
					Active_BuyFrame(true, v10)
				end
			end)
		end
	end)

	if result then
		warn(result)
	end
end

function Active_BuyFrame(p, p2)
	if p == true and buyFrame.Visible == false and p2 then
		if buyFrame:GetAttribute("Type") == "Robux" then
			if localPlayer:GetAttribute("TH") then
				local title = buyFrame.Frame.Title
				local formatted = `{Abbreviate.Comma(buyFrame:GetAttribute("Price"))} โรบัค`
				local v6

				if formatted then
					v6 = `<font color="rgb(75,230,75)">{formatted}</font>`
				end

				title.Text = `คุณต้องการที่จะซื้อเกมพาส\nชิ้นนี้ในราคา {v6} หรือไม่?`
			else
				local title = buyFrame.Frame.Title
				local formatted = `{Abbreviate.Comma(buyFrame:GetAttribute("Price"))} Robux?`
				local v6

				if formatted then
					v6 = `<font color="rgb(75,230,75)">{formatted}</font>`
				end

				title.Text = `Would you like to purchase this gamepass for {v6}`
			end
		elseif buyFrame:GetAttribute("Type") == "Gem" then
			if localPlayer:GetAttribute("TH") then
				local title = buyFrame.Frame.Title
				local formatted = `{Abbreviate.Comma(buyFrame:GetAttribute("Price"))} เพชร`
				local v6

				if formatted then
					v6 = `<font color="rgb(175,125,255)">{formatted}</font>`
				end

				title.Text = `คุณต้องการที่จะซื้อเกมพาสชิ้นนี้ในราคา {v6} หรือไม่?`
			else
				local title = buyFrame.Frame.Title
				local formatted = `{Abbreviate.Comma(buyFrame:GetAttribute("Price"))} Gem?`
				local v6

				if formatted then
					v6 = `<font color="rgb(175,125,255)">{formatted}</font>`
				end

				title.Text = `Would you like to purchase this gamepass for\n{v6}`
			end
		end

		buyFrame.Visible = true
		FadeModule.FadeIn(buyFrame, 0.25)
	elseif p == false and buyFrame.Visible == true then
		FadeModule.FadeOut(buyFrame, 0.25)
		task.wait(0.25)
		buyFrame.Visible = false
	end
end

function Active_GiftFrame(p)
	if p == true and playerListFrame.Visible == false then
		playerListFrame.Visible = true
		FadeModule.FadeIn(playerListFrame, 0.25)
		GeneratePlayer()
	elseif p == false and playerListFrame.Visible == true then
		FadeModule.FadeOut(playerListFrame, 0.25)
		task.wait(0.25)
		playerListFrame.Visible = false
	end
end

function GiftingChange()
	if script:GetAttribute("Gifting") == "None" or script:GetAttribute("Gifting") == localPlayer.Name then
		if localPlayer:GetAttribute("TH") then
			giftText.Text = "เลือกผู้เล่น"
		else
			giftText.Text = "Select a player"
		end

		giftGamepass_Container.Visible = false
		gamepass_Container.Visible = true
	else
		giftText.Text = (script:GetAttribute("Gifting") == "None" or not Players:FindFirstChild(script:GetAttribute("Gifting"))) and "None" or script:GetAttribute("Gifting")
		gamepass_Container.Visible = false
		giftGamepass_Container.Visible = true
		GenerateGiftGamepass()
	end
end

function Purchase_Product()
	if v[buyFrame:GetAttribute("GamepassId")].Value == false then
		if buyFrame:GetAttribute("Type") == "Robux" then
			MarketplaceService:PromptGamePassPurchase(localPlayer, buyFrame:GetAttribute("GamepassId"))
		else
			buyProduct:FireServer({
				Action = "Buy_Gamepass",
				GamepassId = buyFrame:GetAttribute("GamepassId")
			})
		end
	else
		sound_Effect.Error:Play()

		if localPlayer:GetAttribute("TH") then
			SetText.SetText(localPlayer, "CustomMessage", {
				Message = "คุณเป็นเจ้าของเกมพาสนี้อยู่แล้ว.",
				MessageColor = "Red"
			})
		else
			SetText.SetText(localPlayer, "CustomMessage", {
				Message = "You already own this gamepass.",
				MessageColor = "Red"
			})
		end
	end

	Active_BuyFrame(false)
end

function Language_Changed()
	for _, frame in ipairs(gamepass_Container:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		if localPlayer:GetAttribute("TH") then
			frame.Description.Text = frame:GetAttribute("TH_Description") or "จะพิมพ์อะไรต่อนะลืม?"
		else
			frame.Description.Text = frame:GetAttribute("ENG_Description") or "No description given."
		end
	end

	for _, frame in ipairs(giftGamepass_Container:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		if localPlayer:GetAttribute("TH") then
			frame.Description.Text = frame:GetAttribute("TH_Description") or "จะพิมพ์อะไรต่อนะลืม?"
		else
			frame.Description.Text = frame:GetAttribute("ENG_Description") or "No description given."
		end
	end
end

local function BuyProduct_Client(p: string)
	if p == "Buy_Success" then
		sound_Effect.Buy_Success:Play()
	elseif p == "SendGift_Success" then
		sound_Effect.Notification:Play()
	end
end

buyFrame.Frame.BuyFrame.Button.Activated:Connect(Purchase_Product)
buyFrame.Frame.CloseFrame.Button.Activated:Connect(function()
	sound_Effect.ClickSound:Play()
	Active_BuyFrame(false)
end)
playerListFrame.Frame.Close.Activated:Connect(function()
	sound_Effect.ClickSound:Play()
	Active_GiftFrame(false)
end)
container.Heading.Gift.Activated:Connect(function()
	sound_Effect.ClickSound:Play()
	Active_GiftFrame(true)
end)
uIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(SetContentSize)
script:GetAttributeChangedSignal("Gifting"):Connect(GiftingChange)
localPlayer:GetAttributeChangedSignal("TH"):Connect(Language_Changed)
buyProduct.OnClientEvent:Connect(BuyProduct_Client)
SetContentSize() -- equivalent call inferred; original call site unknown
GenerateGamepass()
GenerateGiftGamepass()
guiEvent.Event:Connect(function(p)
	local menuName = p.MenuName
	local action = p.Action

	if menuName == "Shop" and action == "Open" then
		if gamepass_Container.Visible == true then
			GenerateGamepass()
		end

		if playerListFrame.Visible == true then
			GeneratePlayer()
		end
	end
end)