local localPlayer = game.Players.LocalPlayer
local parent = script.Parent
local giftFrame = parent:WaitForChild("GiftFrame")
local TweenService = game:GetService("TweenService")
local UserService = game:GetService("UserService")
local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
local ProcessingModule = require(script.Parent.Parent:WaitForChild("ProcessingModule"))
local v = true
local name = nil
local v2 = nil
local playerToGift = nil
local name2 = nil
local fruitPrices = shared.FruitPrices
local localPlayer2 = game.Players.LocalPlayer
local scrollingFrame = parent.ScrollingFrame
local parent2 = scrollingFrame.Parent.Parent.Parent
local starterFrame = parent2.StarterFrame
local fruitFrame = starterFrame.FruitFrame
local confirmFrame = script.Parent:WaitForChild("ConfirmFrame")
local MarketplaceService = game:GetService("MarketplaceService")
local globalGiftMainFrame = starterFrame:WaitForChild("GlobalGiftMainFrame")
local _ = globalGiftMainFrame.GiftFrame.SearchFrame
localPlayer2:GetMouse()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
require(ReplicatedStorage.Chest.Modules.FruitList)
local DFROBUX = require(ReplicatedStorage.Chest.Modules.DFROBUX)
local CollectibleList = require(ReplicatedStorage.Chest.Modules.CollectibleList)
local SwordList = require(ReplicatedStorage.Chest.Modules.SwordList)
local WorldsId = require(ReplicatedStorage.Chest.Modules.WorldsId)
local CustomNames = require(ReplicatedStorage.Chest.Modules.CustomNames)
local LimitedBundles = require(ReplicatedStorage.Chest.Modules.LimitedBundles)
local product = ReplicatedStorage.Chest.Remotes.Functions.Product
local OwnedProduct = require(ReplicatedStorage.Chest.Assets.Modules.Features.OwnedProduct)
local TaskManager = require(ReplicatedStorage.Chest.Assets.Modules.TaskManager)
local v4 = {
	[WorldsId.Testing.FirstSea] = true,
	[WorldsId.KingLegacy.FirstSea] = true
}
local v5 = {
	[WorldsId.Testing.SecondSea] = true,
	[WorldsId.KingLegacy.SecondSea] = true
}
local v6 = {
	[WorldsId.Testing.ThirdSea] = true,
	[WorldsId.KingLegacy.ThirdSea] = true
}

if v4[game.PlaceId] then
	scrollingFrame.SpecialFrame.Frame["Emty Frame1"].Visible = true
	scrollingFrame.SpecialFrame.Frame["Emty Frame2"].Visible = true
	scrollingFrame.SpecialFrame.Frame["Emty Frame3"].Visible = true
	scrollingFrame.SpecialFrame.Frame["Emty Frame4"].Visible = true
	scrollingFrame.SpecialFrame.Frame["Emty Frame5"].Visible = true
	scrollingFrame.SpecialFrame.Frame["Emty Frame6"].Visible = true
	scrollingFrame.SpecialFrame.Frame["x5 Fortune Tales"].Visible = nil
	scrollingFrame.SpecialFrame.Frame["x5 Chronicles Lore"].Visible = nil
	scrollingFrame.SpecialFrame.Frame["Spawn GS"].Visible = nil
	scrollingFrame.SpecialFrame.Frame["Spawn SK"].Visible = nil
	scrollingFrame.SpecialFrame.Frame["Spawn HD"].Visible = nil
elseif v5[game.PlaceId] then
	scrollingFrame.SpecialFrame.Frame["Emty Frame1"].Visible = true
	scrollingFrame.SpecialFrame.Frame["x5 Fortune Tales"].Visible = true
	scrollingFrame.SpecialFrame.Frame["x5 Chronicles Lore"].Visible = true
elseif v6[game.PlaceId] then
	scrollingFrame.SpecialFrame.Frame["Emty Frame1"].Visible = true
	scrollingFrame.SpecialFrame.Frame["Emty Frame2"].Visible = true
	scrollingFrame.SpecialFrame.Frame["Emty Frame3"].Visible = true
	scrollingFrame.SpecialFrame.Frame["Emty Frame4"].Visible = true
	scrollingFrame.SpecialFrame.Frame["x5 Fortune Tales"].Visible = true
	scrollingFrame.SpecialFrame.Frame["x5 Chronicles Lore"].Visible = true
	scrollingFrame.SpecialFrame.Frame["Spawn GS"].Visible = nil
	scrollingFrame.SpecialFrame.Frame["Spawn SK"].Visible = nil
	scrollingFrame.SpecialFrame.Frame["Spawn HD"].Visible = nil
end

local v7 = {
	Common = 10000,
	Uncommon = 20000,
	Rare = 30000,
	Epic = 40000,
	Legendary = 50000,
	Mythical = 60000
}
local _ = {
	FruitNotifier = 7936106,
	Conqueror = 8287391,
	NightBlade = 7929804,
	BeliX2 = 8114853,
	CoffinBoat = 9876237,
	DropX2 = 18044132,
	LegacyPose = 18399361
}
local v8 = {
	["Spawn GS"] = true,
	["Spawn HD"] = true,
	["Spawn SK"] = true
}

function ClearSelectPlayer()
	task.spawn(function()
		for _, button in pairs(giftFrame.ScrollingFrame:GetChildren()) do
			if button:IsA("ImageButton") then
				button.BackgroundColor3 = Color3.fromRGB(108, 68, 28)
			end
		end
	end)
end

function GetProductInfo(p)
	local success, result = pcall(function()
		return MarketplaceService:GetProductInfoAsync(p, Enum.InfoType.Product)
	end)

	if success then
		warn(result)
	end
end

function SelecGiftMode(p)
	if p.Mode then
		ClearSelectPlayer()
		giftFrame.Buy.Visible = false
		giftFrame.Gift.Visible = true

		for _, button in pairs(giftFrame.ScrollingFrame:GetChildren()) do
			if not button:IsA("TextButton") then
				continue
			end

			button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			button.BackgroundTransparency = 0.65
		end

		if p.TextButton then
			p.TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
			p.TextButton.BackgroundTransparency = 0.3
		end
	else
		giftFrame.Buy.Visible = true
		giftFrame.Gift.Visible = false
		name2 = nil

		for _, button in pairs(giftFrame.ScrollingFrame:GetChildren()) do
			if not button:IsA("TextButton") then
				continue
			end

			button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			button.BackgroundTransparency = 0.65
		end

		ClearSelectPlayer()
	end
end

local frame = scrollingFrame.CodeFrame.Frame.Frame
local redeem = frame.Redeem
local codeBox = frame.CodeBox

function CheckCode(instance, p)
	if HttpService:JSONDecode(instance:WaitForChild("PlayerStats"):WaitForChild("CodeUsed").Value)[p] then
		return true
	end

	return false
end

local v9 = true
redeem.MouseButton1Click:Connect(function()
	if not v9 then
		return
	end

	v9 = nil
	local v10, v11 = ReplicatedStorage.Chest.Remotes.Functions.redeemcode:InvokeServer(codeBox.Text)

	if v10 then
		codeBox.TextColor3 = Color3.fromRGB(0, 255, 0)
	else
		codeBox.TextColor3 = Color3.fromRGB(255, 0, 0)
	end

	codeBox.Text = v11 or "ERROR!"
	task.spawn(function()
		wait(1)
		codeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		codeBox.Text = ""
		v9 = true
	end)
end)
redeem.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = redeem,
		ZIndex = 5
	})
end)
task.spawn(function()
	wait()

	local function UpdateScrollingShop()
		for _, frame2 in pairs(scrollingFrame:GetChildren()) do
			if not frame2:IsA("Frame") then
				continue
			end

			if not frame2:GetAttribute("YScale") then
				frame2:SetAttribute("YScale", frame2.Size.Y.Scale)
			end

			local yScale = frame2:GetAttribute("YScale")
			local _ = frame2.Size.Y.Offset
			local v10 = scrollingFrame.AbsoluteSize.Y * yScale
			frame2.Size = UDim2.new(frame2.Size.X.Scale, frame2.Size.X.Offset, 0, v10)
		end

		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, scrollingFrame.UIListLayout.AbsoluteContentSize.Y + 14)
	end

	UpdateScrollingShop()
	scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		UpdateScrollingShop()
	end)
	_G.UpdateScrollingShop = UpdateScrollingShop
end)

if localPlayer2.MembershipType == Enum.MembershipType.Premium then
	for _, descendant in pairs(scrollingFrame:GetDescendants()) do
		if descendant.Name == "Premium15Per" then
			descendant.Visible = true
		end
	end
else
	for _, descendant in pairs(scrollingFrame:GetDescendants()) do
		if descendant.Name == "Premium15Per" then
			descendant.Visible = false
		end
	end
end

function IsPlayerOwnGamepass(p, p2)
	local jSONDecode = HttpService:JSONDecode(p.PlayerStats.Misc.Value)

	for k, _ in pairs(jSONDecode) do
		if k == p2 then
			return true
		end
	end
end

local v10 = {}

function UpdateScrollingPlayer()
	local scrollingFrame2 = scrollingFrame.Parent.GiftFrame.ScrollingFrame
	local uIGridLayout = scrollingFrame2.UIGridLayout
	uIGridLayout.CellSize = UDim2.new(
		0,
		scrollingFrame2.AbsoluteSize.X * 1 - scrollingFrame2.ScrollBarThickness,
		0,
		scrollingFrame2.AbsoluteSize.Y * 0.2
	)
	scrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, uIGridLayout.AbsoluteContentSize.Y)
end

function UpdatePlayerList()
	for _, v11 in pairs(game.Players:GetPlayers()) do
		if v11.Name == game.Players.LocalPlayer.Name then
			if v11.Name == game.Players.LocalPlayer.Name then
				local clone = giftFrame.ScrollingFrame:FindFirstChild(v11.Name)

				if not clone then
					clone = script.TextButton:Clone()
					clone.Name = v11.Name
					clone.Visible = true
					clone.TextLabel.Text = "(Store in Inventory)"
					clone.LayoutOrder = -1
					clone.Parent = giftFrame.ScrollingFrame
					local textButton = clone
					clone.MouseButton1Click:Connect(function()
						if not v then
							return
						end

						v = false
						task.spawn(function()
							wait(0.1)
							v = true
						end)
						task.spawn(function()
							_G.ClickFrameEffect({
								Sound = true
							})
						end)

						if string.find(textButton.Name, "(Owned)") then
							if name2 == textButton.Name then
								name2 = nil
								SelecGiftMode({
									TextButton = textButton,
									Mode = nil
								})
							end
						elseif name2 == textButton.Name then
							name2 = nil
							SelecGiftMode({
								TextButton = textButton,
								Mode = nil
							})
						else
							name2 = textButton.Name
							SelecGiftMode({
								TextButton = textButton,
								Mode = textButton.Name
							})
						end
					end)
				end

				name = name and v10[name] or name

				if CollectibleList[name] then
					clone.Visible = true
				else
					clone.Visible = false
				end
			end
		elseif not giftFrame.ScrollingFrame:FindFirstChild(v11.Name) then
			local clone = script.TextButton:Clone()
			clone.Name = v11.Name
			clone.Visible = true
			clone.TextLabel.Text = v11.Name
			clone.Parent = giftFrame.ScrollingFrame
			clone.MouseButton1Click:Connect(function()
				if not v then
					return
				end

				v = false
				task.spawn(function()
					wait(0.1)
					v = true
				end)
				task.spawn(function()
					_G.ClickFrameEffect({
						Sound = true
					})
				end)

				if name2 == clone.Name then
					name2 = nil
					SelecGiftMode({
						TextButton = clone,
						Mode = nil
					})
				else
					SelecGiftMode({
						TextButton = clone,
						Mode = clone.Name
					})
					name2 = clone.Name
				end
			end)
		end
	end

	for _, button in pairs(giftFrame.ScrollingFrame:GetChildren()) do
		if not button:IsA("TextButton") or game.Players:FindFirstChild(button.Name) then
			continue
		end

		button:Destroy()
	end
end

function UpdateRegionalPrice(instance)
	for _, button in ipairs(instance:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		local robux = button:FindFirstChild("robux")

		if robux then
			robux.Text = `<font size="10"></font>{shared.ProductPrices[button.Name] and shared.ProductPrices[button.Name].RobuxPrice or "???"}`
		end
	end
end

task.spawn(function()
	while not shared.ProductLoaded do
		task.wait(0.1)
	end

	UpdateRegionalPrice(scrollingFrame.BundleFrame.Frame)
	UpdateRegionalPrice(scrollingFrame.ExpFrame.Frame)
	UpdateRegionalPrice(scrollingFrame.GamepassFrame.Frame)
	UpdateRegionalPrice(scrollingFrame.GemFrame.Frame)
	UpdateRegionalPrice(scrollingFrame.MoneyFrame.Frame)
	UpdateRegionalPrice(scrollingFrame.SpecialFrame.Frame)
end)
local permanent = scrollingFrame.Permanent

function UpdateConfirmFrame(p)
	if not name then
		confirmFrame.Visible = nil
		return
	end

	confirmFrame.Frame.GiftingFrame.NameLabel.Text = "<" .. (p or name) .. ">"
	confirmFrame.Frame.BackgroundBorder.Gift.TextLabel.Text = "GIFT"
	confirmFrame.Frame.BackgroundBorder.Buy.TextLabel.Text = "BUY"

	if LimitedBundles[name] then
		local etcDataClient, v11 = _G.GetEtcDataClient(localPlayer2, name)

		if v11 then
			confirmFrame.Frame.BackgroundBorder.Gift.TextLabel.Text = "GIFT (" .. (etcDataClient or 3) .. "/" .. 3 .. ")"
		end

		if _G.CheckAwakeClient(localPlayer2, name) then
			confirmFrame.Frame.BackgroundBorder.Buy.TextLabel.Text = "BUY (0/1)"
		else
			confirmFrame.Frame.BackgroundBorder.Buy.TextLabel.Text = "BUY (1/1)"
		end
	elseif OwnedProduct:IsOwned(localPlayer2, name) then
		confirmFrame.Frame.BackgroundBorder.Buy.TextLabel.Text = "OWNED"
	end

	confirmFrame.Visible = true
end

confirmFrame.Frame.Close.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})
	wait()
	name = nil
	v2 = nil
	confirmFrame.Visible = nil
end)
confirmFrame.Frame.Close.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = confirmFrame.Frame.Close,
		ZIndex = 5,
		Size = UDim2.fromScale(0.9, 0.9),
		Circle = true
	})
	confirmFrame.Frame.Close.Size = UDim2.fromScale(0.118, 0.188)
	TweenService:Create(confirmFrame.Frame.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.fromScale(0.177, 0.28200000000000003)
	}):Play()
end)
confirmFrame.Frame.Close.MouseLeave:Connect(function()
	TweenService:Create(confirmFrame.Frame.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.fromScale(0.118, 0.188)
	}):Play()
end)
confirmFrame.Frame.BackgroundBorder.Buy.MouseButton1Click:Connect(function()
	wait()
	_G.ClickFrameEffect({
		Sound = true
	})

	if not name or v2 and not v2:IsDescendantOf(parent2) or OwnedProduct:IsOwned(localPlayer2, name) then
		return
	end

	if v2:IsDescendantOf(permanent) and not ProcessConfirmGiftSelfShopFrame() then
		return
	end

	local processingModule = ProcessingModule()
	processingModule.Begin()
	local fruitName = name

	if v2 and v2:GetAttribute("FruitName") then
		fruitName = v2:GetAttribute("FruitName")
	end

	product:InvokeServer({
		ProductName = fruitName,
		PurchaseType = "Transfer"
	})
	confirmFrame.Visible = nil
	name = nil
	v2 = nil
	processingModule:Destroy()
end)

function UpdateGiftingTo()
	local robux = v2 and (v2:FindFirstChild("robux") or v2:FindFirstChild("Price"))
	local text = robux and robux.Text

	if not text and name and DFROBUX[name] then
		text = "<font size=\"10\"></font>" .. DFROBUX[name].robux
	end

	local v11 = v2 and ReplicatedStorage.Chest.Animation.CustomAnimations:FindFirstChild(v2.Name) and "<font size=\"10\"></font>100" or text
	globalGiftMainFrame.GiftFrame.Buy.TextLabel.Text = v11 or "???"

	if name and playerToGift then
		globalGiftMainFrame.GiftFrame.GiftingFrame.NameLabel.Text = string.format(
			"Gifting [%s] <%s>",
			playerToGift,
			CustomNames[name] or name
		)
		globalGiftMainFrame.GiftFrame.GiftingFrame.Visible = true
	else
		globalGiftMainFrame.GiftFrame.GiftingFrame.Visible = nil
		globalGiftMainFrame.GiftFrame.GiftingFrame.NameLabel.Text = ""
	end
end

confirmFrame.Frame.BackgroundBorder.Gift.MouseButton1Click:Connect(function()
	wait()
	_G.ClickFrameEffect({
		Sound = true
	})

	if not name or globalGiftMainFrame.GiftFrame.Visible then
		return
	end

	confirmFrame.Visible = false
	_G.ButtonClicked({
		Frame = globalGiftMainFrame.GiftFrame,
		Button = nil
	})
	UpdateGiftingTo()
end)
globalGiftMainFrame.GiftFrame.Close.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})
	name = nil
	v2 = nil
	_G.ButtonClicked()
end)
globalGiftMainFrame.GiftFrame.Close.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = globalGiftMainFrame.GiftFrame.Close,
		ZIndex = 5,
		Size = UDim2.fromScale(0.9, 0.9),
		Circle = true
	})
	globalGiftMainFrame.GiftFrame.Close.Size = UDim2.new(0.104, 0, 0.15, 0)
	TweenService:Create(globalGiftMainFrame.GiftFrame.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.156, 0, 0.22499999999999998, 0)
	}):Play()
end)
globalGiftMainFrame.GiftFrame.Close.MouseLeave:Connect(function()
	TweenService:Create(globalGiftMainFrame.GiftFrame.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.104, 0, 0.15, 0)
	}):Play()
end)

for _, button in pairs(scrollingFrame:GetDescendants()) do
	if not button:IsA("TextButton") then
		continue
	end

	local v11 = button
	button.MouseButton1Click:Connect(function()
		if not v then
			return
		end

		v = false
		task.spawn(function()
			wait(0.1)
			v = true
		end)
		task.spawn(function()
			_G.ClickFrameEffect({
				Sound = true
			})
			local imageLabel = v11:FindFirstChild("ImageLabel")

			if imageLabel then
				imageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
				TweenService:Create(
					imageLabel,
					TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
					{
						ImageColor3 = Color3.fromRGB()
					}
				):Play()
			end
		end)
		local name3 = v11.Name
		v11:IsDescendantOf(permanent)

		if name == v11.Name then
			name = nil
			v2 = nil
			UpdateConfirmFrame()
		else
			if confirmFrame.Visible then
				return
			end

			if v11.Name == "Gift" then
				if name == v11.Parent.Name then
					name = nil
					ClearSelectPlayer()
					giftFrame.Visible = false
					return
				end
			elseif v11.Name == "Permanent Fruit" then
				_G.ButtonClicked()
				name = nil
				ClearSelectPlayer()
				giftFrame.Visible = false
				_G.FruitFrameMode("Robux")
				return
			elseif v11.Name == "Redeem" then
				return
			end

			if v8[v11.Name] then
				local processingModule = ProcessingModule()
				processingModule.Begin()
				product:InvokeServer({
					ProductName = v11.Name,
					PurchaseType = "Transfer"
				})
				processingModule:Destroy()
			else
				name = v11.Name
				v2 = v11
				local productName = v11:FindFirstChild("ProductName")
				local text = productName and productName.Text or nil
				UpdateConfirmFrame(text)
			end
		end
	end)
	local parent3 = button
	button.MouseEnter:Connect(function()
		_G.ShineGui({
			Parent = parent3,
			ZIndex = 5
		})
	end)
end

for _, button in pairs(fruitFrame.ScrollingFrame:GetChildren()) do
	if not button:IsA("TextButton") then
		continue
	end

	local gift = button:FindFirstChild("Gift")

	if not gift then
		continue
	end

	local v11 = button
	gift.MouseButton1Click:Connect(function()
		if name == v11.Name then
			name = nil
			v2 = nil
		else
			name = v11.Name
			v2 = v11
			_G.ButtonClicked({
				Frame = globalGiftMainFrame.GiftFrame,
				Button = nil
			})
		end

		UpdateGiftingTo()
	end)
	local parent3 = gift
	gift.MouseEnter:Connect(function()
		_G.ShineGui({
			Parent = parent3,
			ZIndex = 5,
			Circle = true
		})
	end)
end

giftFrame.Buy.MouseButton1Click:Connect(function()
	if not (name and v) then
		return
	end

	v = false
	task.spawn(function()
		wait(0.1)
		v = true
	end)
	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true
		})
	end)
	local child = permanent.Frame:FindFirstChild(name)

	if child then
		local fruitName = child:GetAttribute("FruitName")

		if fruitName then
			local v11 = name2 or localPlayer2.Name
			ReplicatedStorage.Chest.Remotes.Events.Product:FireServer(fruitName, v11)
		end
	else
		ReplicatedStorage.Chest.Remotes.Events.Product:FireServer(name)
	end

	name = nil
	v2 = nil
	ClearSelectPlayer()
	giftFrame.Visible = false
end)
giftFrame.Gift.MouseButton1Click:Connect(function()
	if not (name2 and name and v) then
		return
	end

	v = false
	task.spawn(function()
		wait(0.1)
		v = true
	end)
	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true
		})
	end)
	local child = permanent.Frame:FindFirstChild(name)

	if child then
		local fruitName = child:GetAttribute("FruitName")

		if fruitName then
			local v11 = name2 or localPlayer2.Name
			ReplicatedStorage.Chest.Remotes.Events.Product:FireServer(fruitName, v11)
		end
	else
		ReplicatedStorage.Chest.Remotes.Events.Product:FireServer(name, name2)
	end

	name = nil
	v2 = nil
	ClearSelectPlayer()
	giftFrame.Visible = false
	name2 = nil
	SelecGiftMode({
		TextButton = nil,
		Mode = nil
	})
end)
giftFrame.Cancel.MouseButton1Click:Connect(function()
	if not (name and v) then
		return
	end

	v = false
	task.spawn(function()
		wait(0.1)
		v = true
	end)
	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true
		})
	end)
	name = nil
	v2 = nil
	ClearSelectPlayer()
	giftFrame.Visible = false
end)

function UpdatePlayers()
	for _, v11 in pairs(game.Players:GetPlayers()) do
		if giftFrame.ScrollingFrame:FindFirstChild(v11.Name) or v11.Name == game.Players.LocalPlayer.Name then
			continue
		end

		local clone = script.TextButton:Clone()
		clone.Name = v11.Name
		clone.Visible = true
		clone.TextLabel.Text = v11.Name
		clone.Parent = giftFrame.ScrollingFrame
		clone.MouseButton1Click:Connect(function()
			if not v then
				return
			end

			v = false
			task.spawn(function()
				wait(0.1)
				v = true
			end)
			task.spawn(function()
				_G.ClickFrameEffect({
					Sound = true
				})
			end)

			if string.find(clone.TextLabel.Text, "(Owned)") then
				if name2 == clone.Name then
					name2 = nil
					SelecGiftMode({
						TextButton = nil,
						Mode = nil
					})
				end
			elseif name2 == clone.Name then
				name2 = nil
				SelecGiftMode({
					TextButton = clone,
					Mode = nil
				})
			else
				name2 = clone.Name
				SelecGiftMode({
					TextButton = clone,
					Mode = clone.Name
				})
			end
		end)
	end
end

UpdatePlayers()
local CustomNames2 = require(ReplicatedStorage.Chest.Modules.CustomNames)

function UpdatePermanentStock()
	local v11 = ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("GetPermanentStocks")

	if not v11 then
		while wait(1) do
			v11 = ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("GetPermanentStocks")

			if v11 then
				break
			end
		end
	end

	for _, button in pairs(permanent.Frame:GetChildren()) do
		if button:IsA("TextButton") then
			button:SetAttribute("FruitName", nil)
		end
	end

	for childName, v12 in pairs(v11) do
		local child = permanent.Frame:FindFirstChild(childName)

		if not child then
			continue
		end

		local v13 = v12:sub(1, #v12 / 2) .. "Fruit"
		local v14 = not fruitPrices[v12] and "Loading" or fruitPrices[v12].RobuxPrice or "Loading"
		local v15 = v13:gsub("Fruit", "")
		child:SetAttribute("FruitName", v12)
		child.ProductName.Text = CustomNames2[v15] or v15
		child.robux.Text = "<font size=\"10\"></font>" .. v14
		child.LayoutOrder = v7[childName] + DFROBUX[v12].robux
		child.ImageLabel.Image = SwordList[v12].Image
	end

	local robuxPrice = fruitPrices.PterPter and fruitPrices.PterPter.RobuxPrice or "Loading"
	scrollingFrame.PermanentFruitFrame.Frame["Permanent Pter"].robux.Text = "<font size=\"10\"></font>" .. robuxPrice
end

game.Players.PlayerAdded:Connect(function()
	wait()
	UpdatePlayers()
	UpdateScrollingPlayer()
end)
UpdatePermanentStock()
game.Players.PlayerRemoving:Connect(function(player)
	wait()

	if giftFrame.ScrollingFrame:FindFirstChild(player.Name) then
		giftFrame.ScrollingFrame[player.Name]:Destroy()
	end
end)
ReplicatedStorage.Chest.Remotes.Events.DFUpdate.OnClientEvent:Connect(function()
	UpdatePermanentStock()
end)
task.spawn(function()
	while not shared.FruitsLoaded do
		task.wait(0.1)
	end

	UpdatePermanentStock()
end)
parent.Close.MouseButton1Click:Connect(function()
	_G.ButtonClicked()
	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})
end)
parent.Close.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = parent.Close,
		ZIndex = 5,
		Size = UDim2.fromScale(0.9, 0.9),
		Circle = true
	})
	parent.Close.Size = UDim2.new(0.082, 0, 0.139, 0)
	TweenService:Create(parent.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.123, 0, 0.20850000000000002, 0)
	}):Play()
end)
parent.Close.MouseLeave:Connect(function()
	TweenService:Create(parent.Close, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.082, 0, 0.139, 0)
	}):Play()
end)
localPlayer2.CharacterAdded:Connect(function()
	wait()
	UpdatePermanentStock()
end)
local v11 = true

function SearchCheck(value, value2)
	if value == "" then
		return true
	end

	local v12 = string.lower(value)
	local v13 = string.lower(value2)

	for i = 1, #v13 do
		if string.sub(v12, 1, #v12) == string.sub(v13, 1, i) or string.sub(v12, 1, #v12) == string.sub(
			v13,
			i,
			i + (#v12 - 1)
		) then
			return true
		end
	end
end

function ButtonClick(instance, p)
	if not (instance and p and v11) then
		return
	end

	v11 = nil
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
		v11 = true
	end)
end

parent.ShopButton.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true
	})
	ButtonClick(parent.ShopButton, parent.ScrollingFrame)
end)
parent.GiftButton.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true
	})
	ButtonClick(parent.GiftButton, parent.GlobalGiftFrame)
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
	local v13 = child
	child.MouseLeave:Connect(function()
		v13.TextLabel.Visible = false
	end)
end

parent.GlobalGiftFrame.Frame.HistoryButton.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true
	})

	if parent.GlobalGiftFrame.Frame.ScrollingHistory.Visible then
		parent.GlobalGiftFrame.Frame.ScrollingHistory.Visible = nil
		parent.GlobalGiftFrame.Frame.ScrollingClaim.Visible = true
		parent.GlobalGiftFrame.Frame.HistoryButton.Text = "History"
	else
		parent.GlobalGiftFrame.Frame.ScrollingHistory.Visible = true
		parent.GlobalGiftFrame.Frame.ScrollingClaim.Visible = nil
		parent.GlobalGiftFrame.Frame.HistoryButton.Text = "Gift"
	end
end)
parent.GlobalGiftFrame.Frame.HistoryButton.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = parent.GlobalGiftFrame.Frame.HistoryButton,
		ZIndex = 5,
		Circle = true
	})
end)
local clone = script:WaitForChild("MessageFrame"):Clone()
local scrollingFrame2 = globalGiftMainFrame.GiftFrame.ScrollingFrame
local connections = {}
local threads = {}
local v12 = {}
local ids = {}
local v13 = nil
local v14 = nil
local v15 = nil
local searchFrame = globalGiftMainFrame.GiftFrame.SearchFrame

function UpdateSizes(_, p)
	for _, frame2 in pairs(scrollingFrame2:GetChildren()) do
		if not frame2:IsA("Frame") then
			continue
		end

		local v16 = p * 0.25
		local messageFrame = frame2:FindFirstChild("MessageFrame")

		if messageFrame and (messageFrame.Visible or playerToGift == localPlayer2.Name) then
			v16 += p * 0.185
			messageFrame.Size = UDim2.new(1, 0, 0, -(p * 0.185))
			frame2.Frame.BackgroundColor3 = Color3.fromRGB(9, 159, 1)
		else
			frame2.Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		end

		frame2.Size = UDim2.new(1, 0, 0, v16)
		frame2.Frame.Size = UDim2.new(1, 0, 0, p * 0.25)
	end
end

function UpdateAbsoluteSize()
	local absoluteSize = scrollingFrame2.AbsoluteSize
	local X = absoluteSize.X
	local Y = absoluteSize.Y
	UpdateSizes(X, Y)
end

function CreateFriendCache()
	local friendsAsync = game.Players:GetFriendsAsync(localPlayer.UserId)
	v14 = friendsAsync
	return friendsAsync
end

function CreateProfile(data)
	local id = data.Id
	local username = data.Username
	local displayName = data.DisplayName
	local success, result = pcall(function()
		return game.Players:GetUserThumbnailAsync(id, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size150x150)
	end)
	local v16 = {
		Username = username,
		UserId = id,
		Thumbnail = success and result or "",
		DisplayName = displayName
	}
	v12[id] = v16
	return v16
end

function CreateProfileByUserId(p)
	local v16 = UserService:GetUserInfosByUserIdsAsync({ p })[1]

	if not v16 then
		return
	end

	local id = v16.Id
	local username = v16.Username
	local displayName = v16.DisplayName
	local success, result = pcall(function()
		return game.Players:GetUserThumbnailAsync(id, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size150x150)
	end)
	local v17 = {
		Username = username,
		UserId = id,
		Thumbnail = success and result or "",
		DisplayName = displayName
	}
	v12[id] = v17
	return v17
end

function Searching()
	for _, frame2 in pairs(scrollingFrame2:GetChildren()) do
		if not frame2:IsA("Frame") then
			continue
		end

		if SearchCheck(searchFrame.TextBox.Text, frame2.Name) then
			frame2.Visible = true
		else
			frame2.Visible = false
		end
	end
end

searchFrame.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
	wait()
	Searching()
end)

function CreateProfileByUsername(p)
	local success, result = pcall(function()
		return game.Players:GetUserIdFromNameAsync(p)
	end)

	if not (success and result) then
		return
	end

	local v16 = UserService:GetUserInfosByUserIdsAsync({ result })[1]

	if not v16 then
		return
	end

	local id = v16.Id
	local username = v16.Username
	local displayName = v16.DisplayName
	local success2, result2 = pcall(function()
		return game.Players:GetUserThumbnailAsync(id, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size150x150)
	end)
	local v17 = {
		Username = username,
		UserId = id,
		Thumbnail = success2 and result2 or "",
		DisplayName = displayName
	}
	v12[p] = v17
	return v17
end

function CacheFriends()
	local currentPage = (v14 or CreateFriendCache()):GetCurrentPage()

	for _, v16 in pairs(currentPage) do
		local id = v16.Id
		local _ = v16.Username
		local _ = v16.DisplayName

		if not v12[id] then
			CreateProfile(v16)
		end
	end
end

function CreatePlayerFrame(player)
	local userId = player.UserId
	local username = player.Username
	local displayName = player.DisplayName
	local thumbnail = player.Thumbnail
	local clone2 = script.PlayerFrame:Clone()
	clone2.Name = username

	if userId == localPlayer.UserId then
		clone2.Frame.DisplayName.Text = "Collectible Item"
		clone2.Frame.PlayerName.Text = "(STORE TO INVENTORY)"
		clone2.Frame.Logo.Image = "rbxassetid://111587438743309"
		clone2.LayoutOrder = -1
	else
		clone2.Frame.DisplayName.Text = displayName or ""
		clone2.Frame.PlayerName.Text = not username and "" or "@" .. username or ""
		clone2.Frame.Logo.Image = thumbnail
	end

	if table.find(ids, userId) then
		clone2.Frame.FriendIcon.Visible = true
	end

	table.insert(connections, clone2.Frame.Button.MouseButton1Click:Connect(function()
		wait()

		if playerToGift == username then
			clone.Visible = nil
			clone.Parent = nil
			playerToGift = nil
		else
			playerToGift = username
			clone.Frame.TextBox.Text = ""
			clone.Frame.TextBox.PlaceholderText = "Leave a gift note for [" .. username .. "]..."

			if localPlayer.UserId == userId then
				clone.Visible = nil
			else
				clone.Visible = true
			end

			clone.Parent = clone2
		end

		UpdateAbsoluteSize()
		UpdateGiftingTo()
	end))
	clone2.Parent = scrollingFrame2
	UpdateAbsoluteSize()
end

function LoadFriends()
	searchFrame.TextBox.Text = ""
	local currentPage = (v14 or CreateFriendCache()):GetCurrentPage()
	table.insert(threads, task.spawn(function()
		for k, v16 in pairs(currentPage) do
			local id = v16.Id
			local _ = v16.Username
			local _ = v16.DisplayName
			local v17 = v12[id] or CreateProfile(v16)
			CreatePlayerFrame(v17)

			if not table.find(ids, id) then
				table.insert(ids, id)
			end

			if k % 4 == 0 then
				RunService.Heartbeat:Wait()
			end
		end

		UpdateAbsoluteSize()
	end))
end

function LoadServers()
	searchFrame.TextBox.Text = ""

	for _, v16 in pairs(game.Players:GetPlayers()) do
		local v17 = v12[v16.UserId] or CreateProfileByUserId(v16.UserId)

		if v17 then
			CreatePlayerFrame(v17)
		end
	end
end

function ClearEventsAndThreads()
	for _, v16 in pairs(threads) do
		task.cancel(v16)
	end

	for _, connection in pairs(connections) do
		if not connection.Connected then
			connection:Disconnect()
		end
	end

	table.clear(threads)
	table.clear(connections)
end

function ClearPlayerFrames()
	for _, frame2 in pairs(scrollingFrame2:GetChildren()) do
		if frame2:IsA("Frame") then
			frame2:Destroy()
		end
	end

	UpdateAbsoluteSize()
end

function ClearPlayerIDAndMessage()
	v15 = nil
	playerToGift = nil
	clone.Parent = nil
end

function LoadServerFrame()
	ClearPlayerIDAndMessage()
	v13 = "ServerFrame"
	ClearEventsAndThreads()
	ClearPlayerFrames()
	LoadServers()
end

function LoadGlobalFrame()
	ClearPlayerIDAndMessage()
	v13 = "GlobalFrame"
	ClearEventsAndThreads()
	ClearPlayerFrames()
	LoadFriends()
end

function FindPlayer(value)
	if not value then
		return
	end

	for _, v16 in pairs(game.Players:GetPlayers()) do
		if string.lower((string.sub(v16.Name, 1, #value))) == string.lower(value) then
			return v16
		end
	end

	return nil
end

function SearchingGlobalPlayer(value)
	if v13 == "GlobalFrame" then
		local v16 = string.lower(value)
		local v17 = v12[v16] or CreateProfileByUsername(v16)

		if not v17 then
			return
		end

		ClearPlayerIDAndMessage()
		ClearEventsAndThreads()
		ClearPlayerFrames()
		CreatePlayerFrame(v17)
		UpdateGiftingTo()
	else
		if v13 ~= "ServerFrame" then
			return
		end

		local v16 = FindPlayer(value)

		if not v16 then
			return
		end

		local userId = v16.UserId
		local v17 = v12[userId] or CreateProfileByUserId(userId)

		if not v17 then
			return
		end

		ClearPlayerIDAndMessage()
		ClearEventsAndThreads()
		ClearPlayerFrames()
		CreatePlayerFrame(v17)
		UpdateGiftingTo()
	end
end

globalGiftMainFrame.GiftFrame.Global.MouseButton1Click:Connect(function()
	wait()
	LoadGlobalFrame()
end)
globalGiftMainFrame.GiftFrame.Global.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = globalGiftMainFrame.GiftFrame.Global,
		ZIndex = 5
	})
end)
globalGiftMainFrame.GiftFrame.Server.MouseButton1Click:Connect(function()
	wait()
	LoadServerFrame()
end)
globalGiftMainFrame.GiftFrame.Server.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = globalGiftMainFrame.GiftFrame.Server,
		ZIndex = 5
	})
end)
scrollingFrame2:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	wait()
	UpdateAbsoluteSize()
end)
local _ = globalGiftMainFrame.GiftFrame.Close
local buy = globalGiftMainFrame.GiftFrame.Buy
local productConfirmFrame = starterFrame.ProductConfirmFrame

function ProcessConfirmGiftSelfShopFrame()
	parent.Visible = nil
	productConfirmFrame.Visible = true
	local flag = true
	local v16 = nil
	local maid = TaskManager.new()
	maid:GiveTask(productConfirmFrame.Confirm.MouseButton1Click:Connect(function()
		v16 = true
		flag = nil
	end))
	maid:GiveTask(productConfirmFrame.Cancel.MouseButton1Click:Connect(function()
		flag = nil
	end))

	while flag do
		task.wait(0.03333333333333333)
	end

	productConfirmFrame.Visible = nil
	parent.Visible = true
	maid:Destroy()
	return v16
end

function ProcessConfirmGiftSelf()
	globalGiftMainFrame.Visible = nil
	productConfirmFrame.Visible = true
	local flag = true
	local v16 = nil
	local maid = TaskManager.new()
	maid:GiveTask(productConfirmFrame.Confirm.MouseButton1Click:Connect(function()
		v16 = true
		flag = nil
	end))
	maid:GiveTask(productConfirmFrame.Cancel.MouseButton1Click:Connect(function()
		flag = nil
	end))

	while flag do
		task.wait(0.03333333333333333)
	end

	productConfirmFrame.Visible = nil
	globalGiftMainFrame.Visible = true
	maid:Destroy()
	return v16
end

buy.MouseButton1Click:Connect(function()
	if not (playerToGift and name) or playerToGift == localPlayer.Name and not ProcessConfirmGiftSelf() then
		return
	end

	local processingModule = ProcessingModule()
	processingModule.Begin()
	local fruitName = name

	if v2 and v2:GetAttribute("FruitName") then
		fruitName = v2:GetAttribute("FruitName")
	end

	product:InvokeServer({
		ProductName = fruitName,
		PurchaseType = "Transfer",
		MessageToRecipient = clone.Visible and clone.Frame.TextBox.Text or nil,
		PlayerToGift = playerToGift
	})
	processingModule:Destroy()
end)
buy.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = buy,
		ZIndex = 5
	})
end)
searchFrame.TextBox.FocusLost:Connect(function(p)
	wait()

	if p then
		SearchingGlobalPlayer(searchFrame.TextBox.Text)
	end
end)

function UpdateMessageText()
	if #clone.Frame.TextBox.Text > 50 then
		clone.Frame.TextBox.Text = string.sub(clone.Frame.TextBox.Text, 1, 50)
	end

	clone.Frame.TotalCharacter.Text = string.format("Character (%d/%d)", #clone.Frame.TextBox.Text, 50)
end

clone.Frame.TextBox:GetPropertyChangedSignal("Text"):Connect(UpdateMessageText)
local connections2 = {}

function SetupAnimationStore(screenGui)
	if not (screenGui:IsA("ScreenGui") and screenGui.Name == "AnimationStore") then
		return
	end

	for _, connection in pairs(connections2) do
		if connection.Connected then
			connection:Disconnect()
		end
	end

	table.clear(connections2)
	local firstFrame = screenGui.FirstFrame

	for _, button in pairs(firstFrame.ScrollingFrame:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		local v16 = button
		table.insert(connections2, button.Gift.MouseButton1Click:Connect(function()
			wait()
			name = v16.Name
			v2 = v16
			_G.ButtonClicked({
				Frame = globalGiftMainFrame.GiftFrame,
				Button = nil
			})
			UpdateGiftingTo()
		end))
	end
end

if localPlayer2.PlayerGui:FindFirstChild("AnimationStore") then
	SetupAnimationStore(localPlayer2.PlayerGui.AnimationStore)
end

localPlayer2.PlayerGui.ChildAdded:Connect(function(child)
	wait()
	SetupAnimationStore(child)
end)
localPlayer2.PlayerGui.ChildRemoved:Connect(function(_)
	wait()
end)
UpdateAbsoluteSize()
CacheFriends()
LoadServerFrame()