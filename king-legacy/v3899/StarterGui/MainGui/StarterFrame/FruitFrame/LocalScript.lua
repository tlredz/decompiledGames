local localPlayer = game.Players.LocalPlayer

repeat
	wait(0.5)
until localPlayer:FindFirstChild("DataLoaded")

wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("MarketplaceService")
local DFROBUX = require(ReplicatedStorage.Chest.Modules.DFROBUX)
require(ReplicatedStorage.Chest.Modules.DFGiftRobux)
local CustomNames = require(ReplicatedStorage.Chest.Modules.CustomNames)
local TierColor = require(ReplicatedStorage.Chest.Modules.TierColor)
local DFTier = require(ReplicatedStorage.Chest.Modules.DFTier)
local FruitList = require(ReplicatedStorage.Chest.Modules.FruitList)
local parent = script.Parent
local _ = parent.Parent.ShopFrame
local scrollingFrame = parent:WaitForChild("ScrollingFrame")
local fruitPrices = shared.FruitPrices
local frame = parent.Frame

function GetFruitRarity(p)
	for k, list in pairs(DFTier) do
		if string.find(table.concat(list, ","), p) then
			return k
		end
	end

	return "Common"
end

local buttons = {}
local v = {
	Common = 10000,
	Uncommon = 20000,
	Rare = 30000,
	Epic = 40000,
	Legendary = 50000,
	Mythical = 60000
}
local v2 = nil

for _, button in ipairs(parent.ScrollingFrame:GetChildren()) do
	if button:IsA("TextButton") then
		table.insert(buttons, button)
	end
end

table.sort(buttons, function(a, b)
	local formatted = `{string.sub(a.Name, 1, #a.Name / 2)}Fruit`
	local formatted2 = `{string.sub(b.Name, 1, #b.Name / 2)}Fruit`
	local v3 = v[GetFruitRarity(formatted)] or 10000
	local v4 = v[GetFruitRarity(formatted2)] or 10000
	local v5 = DFROBUX[a.Name]
	local v6 = DFROBUX[b.Name]

	if v5 and v5.robux then
		v3 += v5.robux / 10000
	end

	if v6 and v6.robux then
		v4 += v6.robux / 10000
	end

	return v3 < v4
end)
local v3 = nil

function UpdateLayout()
	for _, button in pairs(scrollingFrame:GetChildren()) do
		if not (button:IsA("TextButton") and v[button.Tier.Text]) then
			continue
		end

		button.LayoutOrder = v[button.Tier.Text]

		if CustomNames[button.TextLabel.Text] then
			button.TextLabel.Text = CustomNames[button.TextLabel.Text]
		end

		if DFROBUX[button.Name] then
			button.LayoutOrder += DFROBUX[button.Name].robux
		end
	end
end

function IsObjectMatched(p)
	if not v2 or v2 and string.find(string.lower(p.TextLabel.Text), string.lower(v2)) then
		return true
	end
end

function UpdateViewingFrame()
	local Y = scrollingFrame.CanvasPosition.Y
	local Y2 = scrollingFrame.AbsoluteSize.Y

	for _, v4 in ipairs(buttons) do
		if not IsObjectMatched(v4) then
			continue
		end

		local offset = v4.Position.Y.Offset
		v4.Visible = Y <= offset + v4.AbsoluteSize.Y and offset <= Y + Y2
	end
end

function UpdateScrolling()
	local v4 = scrollingFrame.AbsoluteSize.X - scrollingFrame.ScrollBarThickness
	local v5 = scrollingFrame.AbsoluteSize.Y / 2.5
	local total = 0

	for _, v6 in ipairs(buttons) do
		if IsObjectMatched(v6) then
			v6.Visible = true
			v6.Size = UDim2.fromOffset(v4, v5)
			v6.Position = UDim2.fromOffset(0, total)
			total += v5
		else
			v6.Visible = nil
		end
	end

	scrollingFrame.CanvasSize = UDim2.fromOffset(0, total)
	UpdateViewingFrame()
end

function UpdateScrollingPlayer()
	local scrollingFrame2 = parent.GiftFrame.ScrollingFrame
	local uIGridLayout = scrollingFrame2.UIGridLayout
	uIGridLayout.CellSize = UDim2.new(
		0,
		scrollingFrame2.AbsoluteSize.X * 1 - scrollingFrame2.ScrollBarThickness,
		0,
		scrollingFrame2.AbsoluteSize.Y * 0.2
	)
	scrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, uIGridLayout.AbsoluteContentSize.Y)
end

scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	UpdateScrolling()
end)
parent.GiftFrame.ScrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	UpdateScrollingPlayer()
end)
local textBox = parent.SearchImage.TextBox

function ItemSearchCheck(value, value2)
	if value == "" then
		return true
	end

	if CustomNames[value2] then
		value2 = CustomNames[value2]
	end

	local v4 = string.lower(value)
	local v5 = string.lower(value2)

	for i = 1, #v5 do
		if string.sub(v4, 1, #v4) == string.sub(v5, 1, i) or string.sub(v4, 1, #v4) == string.sub(v5, i, i + (#v4 - 1)) then
			return true
		end
	end
end

function Searching()
	local text = textBox.Text

	if text == "" or not text then
		text = nil
	end

	v2 = text
	UpdateScrolling()
end

textBox:GetPropertyChangedSignal("Text"):Connect(function()
	Searching()
end)
local flag = nil
local lastTime = os.clock()

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

		UpdateViewingFrame()
	end

	flag = nil
	UpdateViewingFrame()
end

scrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
	BeginScrolling()
end)
UpdateScrollingPlayer()
UpdateScrolling()
UpdateLayout()
local flag2 = false
local children = scrollingFrame:GetChildren()
parent:WaitForChild("ScrollingFrame")
scrollingFrame.Visible = false
local v4 = ReplicatedStorage.Chest.Remotes.Functions.GetDFShop:InvokeServer()
local TweenService = game:GetService("TweenService")
local giftFrame = parent:WaitForChild("GiftFrame")
local name = nil
local name2 = nil
local DFROBUX2 = require(ReplicatedStorage.Chest.Modules.DFROBUX)
local HttpService = game:GetService("HttpService")
local SwordList = require(ReplicatedStorage.Chest.Modules.SwordList)
local v5 = "Robux"
local textLabel = parent:WaitForChild("TextLabel")

function ChangeMode(mode)
	v5 = mode

	if mode == "Robux" then
		parent:SetAttribute("Mode", "Robux")
		_G.NPCTalk = false
		textLabel.Text = "VISIT BLACK MARKET TO SEE STOCK"

		if localPlayer:FindFirstChild("PlayerStats") and localPlayer.PlayerStats.Language.Value == "TH" then
			textLabel.Text = "คุยกับ Black Matket เพื่อดูสต็อคผล"
		end
	else
		parent:SetAttribute("Mode", mode)
		local value = ReplicatedStorage.TimeLeft.Value
		textLabel.Text = (localPlayer.PlayerStats.Language.Value == "TH" and "เวลาจนกว่าจะรีร้านค้า: " or "Time Until Restock: ") .. tostring(value)
	end

	Update()
end

function _G.FruitFrameMode(p)
	if not parent.Visible then
		_G.ButtonClicked({
			Frame = parent
		})
		ChangeMode(p)
	end
end

task.spawn(function()
	wait()

	local function UpdateImageStatus()
		for _, image in pairs(scrollingFrame:GetDescendants()) do
			if not (image:IsA("ImageLabel") and image.Name == "ImageLabel") then
				continue
			end

			local name3 = image.Parent.Name

			if SwordList[name3] and SwordList[name3].Image then
				image.Image = SwordList[name3].Image
			end
		end
	end

	UpdateImageStatus()
end)

function UpdatePlayerList()
	for _, v6 in pairs(game.Players:GetPlayers()) do
		if v6.Name == localPlayer.Name then
			if v6.Name == localPlayer.Name and not giftFrame.ScrollingFrame:FindFirstChild(v6.Name) then
				local clone = script.TextButton:Clone()
				clone.Name = v6.Name
				clone.Visible = true
				clone.TextLabel.Text = "(Store in Inventory)"
				clone.LayoutOrder = -1
				clone.Parent = giftFrame.ScrollingFrame
				clone.MouseButton1Click:Connect(function()
					_G.ClickFrameEffect({
						Sound = true,
						Parent = parent.Parent
					})

					if name2 == clone.Name then
						name2 = nil

						for i, button in pairs(giftFrame.ScrollingFrame:GetChildren()) do
							if button:IsA("ImageButton") then
								button.BackgroundColor3 = Color3.fromRGB(108, 68, 28)
							end
						end
					else
						name2 = clone.Name

						for i, button in pairs(giftFrame.ScrollingFrame:GetChildren()) do
							if button:IsA("ImageButton") then
								button.BackgroundColor3 = Color3.fromRGB(108, 68, 28)
							end
						end

						clone.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
					end
				end)
			end
		elseif not giftFrame.ScrollingFrame:FindFirstChild(v6.Name) then
			local clone = script.TextButton:Clone()
			clone.Name = v6.Name
			clone.Visible = true
			clone.TextLabel.Text = v6.Name
			clone.Parent = giftFrame.ScrollingFrame
			clone.MouseButton1Click:Connect(function()
				_G.ClickFrameEffect({
					Sound = true,
					Parent = parent.Parent
				})

				if name2 == clone.Name then
					name2 = nil

					for i, button in pairs(giftFrame.ScrollingFrame:GetChildren()) do
						if button:IsA("ImageButton") then
							button.BackgroundColor3 = Color3.fromRGB(108, 68, 28)
						end
					end
				else
					name2 = clone.Name

					for i, button in pairs(giftFrame.ScrollingFrame:GetChildren()) do
						if button:IsA("ImageButton") then
							button.BackgroundColor3 = Color3.fromRGB(108, 68, 28)
						end
					end

					clone.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
				end
			end)
		end
	end

	giftFrame.ScrollingFrame.CanvasSize = UDim2.new(
		0,
		0,
		0,
		giftFrame.ScrollingFrame.UIGridLayout.AbsoluteContentSize.Y
	)
end

giftFrame.Cancel.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true,
		Parent = parent.Parent
	})
	_G.ClickFrameEffect({
		Sound = true
	})
	name = nil
	giftFrame.Visible = false
	name2 = nil

	for _, button in pairs(giftFrame.ScrollingFrame:GetChildren()) do
		if button:IsA("ImageButton") then
			button.BackgroundColor3 = Color3.fromRGB(108, 68, 28)
		end
	end
end)
local text2 = localPlayer.PlayerStats.Language.Value == "TH" and "ใช้" or "Equip"
local v7 = nil
local v8 = nil
local v9 = nil
local v10 = nil
local flag3 = nil

function CloseBuyFrame()
	flag3 = true
	task.delay(0.15, function()
		v7 = TweenService:Create(frame, TweenInfo.new(0.1, Enum.EasingStyle.Quart), {
			Position = UDim2.new(0.75, 0, 0.5, 0)
		})
		v7:Play()
		task.wait(0.1)
		flag3 = nil
		frame.Visible = false
	end)
	task.spawn(function()
		if v8 then
			v8:Pause()
			v8 = nil
		end

		if v10 then
			v10:Pause()
			v10 = nil
		end

		if v9 then
			v9:Pause()
			v9 = nil
		end

		v9 = TweenService:Create(frame.Equip, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Position = UDim2.new(0.5, 0, 0.5, 0)
		})
		v9:Play()
		v8 = TweenService:Create(frame.Buy, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Position = UDim2.new(0.5, 0, 0.5, 0)
		})
		v8:Play()
		v10 = TweenService:Create(frame.Robux, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Position = UDim2.new(0.5, 0, 0.5, 0)
		})
		v10:Play()
	end)
	task.spawn(function()
		if v7 then
			v7:Pause()
			v7 = nil
		end

		v7 = TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
			Position = UDim2.new(0.75, 0, 0.5, 0)
		})
		v7:Play()
		task.delay(0.1, function()
			frame.Visible = false
		end)
	end)
end

for i = 1, #children do
	local button = children[i]

	if not button:IsA("TextButton") then
		continue
	end

	local v11 = button
	button.MouseButton1Click:Connect(function()
		if flag3 or flag2 then
			return
		end

		if frame.Visible and name == v11.Name then
			if v11:FindFirstChild("BG") and v3 and v3.Parent == v11 then
				v3.BackgroundTransparency = 1
				v3 = nil
			end

			CloseBuyFrame()
		else
			local robuxPrice = fruitPrices[v11.Name] and fruitPrices[v11.Name].RobuxPrice or "Loading..."
			frame.Robux.Text = "<font size=\"10\"></font>" .. robuxPrice
			_G.ClickFrameEffect({
				Sound = true,
				Parent = parent.Parent
			})
			local imageLabel = v11:FindFirstChild("ImageLabel")
			local image

			if imageLabel then
				image = imageLabel.Image
				imageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
				TweenService:Create(
					imageLabel,
					TweenInfo.new(0.075, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
					{
						ImageColor3 = Color3.fromRGB(0, 0, 0)
					}
				):Play()
			else
				image = ""
			end

			task.spawn(function()
				if v3 and v3.Parent then
					if v3.Parent == v11 then
					end

					v3.BackgroundTransparency = 1
				end

				local BG = v11:FindFirstChild("BG")

				if BG then
					BG.BackgroundTransparency = 0.75
					v3 = BG
				end
			end)
			name = v11.Name
			task.spawn(function()
				name2 = nil

				for i2, button2 in pairs(giftFrame.ScrollingFrame:GetChildren()) do
					if button2:IsA("ImageButton") then
						button2.BackgroundColor3 = Color3.fromRGB(108, 68, 28)
					end
				end
			end)
			local text = v4[v11.Name] and "Buy" or "Empty"
			frame.FruitName.Text = tostring((string.sub(name, 1, #name / 2)))

			if CustomNames[frame.FruitName.Text] then
				frame.FruitName.Text = CustomNames[frame.FruitName.Text]
			end

			frame.Buy.Text = text
			task.spawn(function()
				if v7 then
					v7:Pause()
					v7 = nil
				end

				if v8 then
					v8:Pause()
					v8 = nil
				end

				if v10 then
					v10:Pause()
					v10 = nil
				end

				if v9 then
					v9:Pause()
					v9 = nil
				end

				frame.Position = UDim2.new(0.75, 0, 0.5, 0)
				v7 = TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
					Position = UDim2.new(1.2, 0, 0.5, 0)
				})
				v7:Play()
				frame.Equip.Position = UDim2.new(0.5, 0, 0.5, 0)
				frame.Buy.Position = UDim2.new(0.5, 0, 0.5, 0)
				frame.Robux.Position = UDim2.new(0.5, 0, 0.5, 0)
				task.delay(0.15, function()
					v9 = TweenService:Create(frame.Equip, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
						Position = UDim2.new(0.5, 0, -0.3, 0)
					})
					v9:Play()
					v8 = TweenService:Create(frame.Buy, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
						Position = UDim2.new(0.5, 0, 1.3, 0)
					})
					v8:Play()
					v10 = TweenService:Create(frame.Robux, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
						Position = UDim2.new(0.5, 0, -0.3, 0)
					})
					v10:Play()
				end)
			end)
			local name3 = v11.Name
			local v13 = tostring((string.sub(name3, 1, #name3 / 2))) .. "Fruit"

			if FruitList[v13] then
				frame.FruitIcon1.Image = FruitList[v13]
				frame.FruitIcon2.Image = image
			end

			frame.Visible = true
			giftFrame.Visible = false
			local jSONDecode = HttpService:JSONDecode(localPlayer.PlayerStats.Misc.Value)

			if v5 == "Robux" then
				if localPlayer.fruitsbought:findFirstChild(name) or jSONDecode[name] then
					frame.Equip.Text = text2
					frame.Equip.Visible = true
					frame.Buy.Visible = false
					frame.Robux.Visible = false
				else
					frame.Equip.Visible = false
					frame.Buy.Visible = false
					frame.Robux.Visible = true
				end
			elseif localPlayer.fruitsbought:findFirstChild(name) or jSONDecode[name] then
				frame.Equip.Text = text2
				frame.Equip.Visible = true
				frame.Buy.Visible = true
				frame.Robux.Visible = false
			else
				frame.Robux.Visible = true
				frame.Buy.Visible = true
				frame.Equip.Visible = false
			end
		end
	end)
	local parent2 = button
	button.MouseEnter:Connect(function()
		_G.ShineGui({
			Parent = parent2,
			ZIndex = 5
		})
		local BG = parent2:FindFirstChild("BG")

		if BG then
			BG.ImageTransparency = 0
		end

		local imageLabel = parent2:FindFirstChild("ImageLabel")

		if imageLabel then
			imageLabel.Size = UDim2.new(0.21, 0, 0.9, 0)
			TweenService:Create(imageLabel, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
				Size = UDim2.new(0.24149999999999996, 0, 1.035, 0)
			}):Play()
		end

		local canvasGroup = parent2:FindFirstChild("CanvasGroup")

		if canvasGroup then
			canvasGroup:Destroy()
		end

		local clone = script.CanvasGroup:Clone()
		clone.Background.ImageTransparency = 1
		clone.LoopSpike.Enabled = true
		clone.Parent = parent2
		TweenService:Create(clone.Background, TweenInfo.new(0.5), {
			ImageTransparency = 0.5
		}):Play()
	end)
	local parent3 = button
	button.MouseLeave:Connect(function()
		local BG = parent3:FindFirstChild("BG")

		if BG then
			BG.ImageTransparency = 0.5
		end

		local imageLabel = parent3:FindFirstChild("ImageLabel")

		if imageLabel then
			TweenService:Create(imageLabel, TweenInfo.new(0.1, Enum.EasingStyle.Quart), {
				Size = UDim2.new(0.21, 0, 0.9, 0)
			}):Play()
		end

		local canvasGroup = parent3:FindFirstChild("CanvasGroup")

		if canvasGroup then
			if canvasGroup:FindFirstChild("Background") then
				TweenService:Create(canvasGroup.Background, TweenInfo.new(0.5), {
					ImageTransparency = 1
				}):Play()
			end

			_G.PU:Dust(canvasGroup, 0.5)
		end
	end)
	local parent4 = button
	button.Gift.MouseEnter:Connect(function()
		parent4.Gift.Size = UDim2.new(0.4, 0, 0.4, 0)
		TweenService:Create(parent4.Gift, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.45999999999999996, 0, 0.45999999999999996, 0)
		}):Play()
	end)
	local parent5 = button
	button.Gift.MouseLeave:Connect(function()
		TweenService:Create(parent5.Gift, TweenInfo.new(0.1, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.4, 0, 0.4, 0)
		}):Play()
	end)
end

function Update()
	pcall(function()
		v4 = ReplicatedStorage.Chest.Remotes.Functions.GetDFShop:InvokeServer()
	end)
	CloseBuyFrame()

	if name and localPlayer.fruitsbought:findFirstChild(name) then
		frame.Visible = true
		frame.FruitName.Text = tostring((string.sub(name, 1, #name / 2)))

		if CustomNames[frame.FruitName.Text] then
			frame.FruitName.Text = CustomNames[frame.FruitName.Text]
		end

		if v5 == "Robux" then
			frame.Buy.Visible = false
		else
			frame.Buy.Visible = true
		end

		frame.Robux.Visible = false
		frame.Equip.Visible = true
	end

	if not v4[name] then
		local text = localPlayer.PlayerStats.Language.Value == "TH" and "ว่าง" or "Empty"
		frame.Buy.Text = text
	end

	local jSONDecode = HttpService:JSONDecode(localPlayer.PlayerStats.Misc.Value)

	for i = 1, #children do
		local button = children[i]

		if not button:IsA("TextButton") then
			continue
		end

		local v11, text

		if localPlayer.PlayerStats.Language.Value == "TH" then
			v11 = " มณี"
			text = "สินค้าหมด"
		else
			v11 = " Gem"
			text = "Out of Stock"
		end

		local name3 = button.Name
		local v13 = tostring((string.sub(name3, 1, #name3 / 2))) .. "Fruit"
		local text3 = tostring((string.sub(button.Name, 1, #button.Name / 2)))

		for k, list in pairs(DFTier) do
			if not (string.find(table.concat(list, ","), v13) and TierColor[k]) then
				continue
			end

			local BG = button:FindFirstChild("BG")

			if BG then
				BG.ImageColor3 = TierColor[k]
				BG.BackgroundColor3 = TierColor[k]
			end

			local tier = button:FindFirstChild("Tier")

			if tier then
				tier.Text = k
				tier.TextColor3 = TierColor[k]
			end

			local textLabel2 = button:FindFirstChild("TextLabel")

			if textLabel2 then
				textLabel2.Text = text3
			end
		end

		UpdateLayout()

		if v5 == "Robux" then
			local _ = button.Name
			button.Status.RichText = true
			button.Status.TextColor3 = Color3.fromRGB(85, 255, 0)
			local v15 = not fruitPrices[button.Name] and "Loading..." or fruitPrices[button.Name].RobuxPrice or "Loading..."
			button.Status.Text = "<font size='15'></font>" .. v15
		elseif v4[button.Name] then
			local text4 = "$" .. tostring(_G.Suffix_Comma(DFROBUX2[button.Name].beli))

			if DFROBUX2[button.Name] and DFROBUX2[button.Name].gem then
				text4 = "$" .. tostring(_G.Suffix_Comma(DFROBUX2[button.Name].beli)) .. " + " .. tostring(DFROBUX2[button.Name].gem) .. v11
			end

			button.Status.TextColor3 = Color3.fromRGB(85, 255, 0)
			button.Status.Text = text4
		else
			button.Status.TextColor3 = Color3.fromRGB(255, 89, 89)
			button.Status.Text = text
		end

		if not (localPlayer.fruitsbought:FindFirstChild(button.Name) or jSONDecode[button.Name]) then
			continue
		end

		local v15 = string.sub(button.Name, 1, #button.Name / 2)

		if CustomNames[v15] then
			v15 = CustomNames[v15]
		end

		button.TextLabel.RichText = true
		button.TextLabel.Text = v15 .. " <font color=\"#00ff00\">(Owned)</font>"
	end

	scrollingFrame.Visible = true
end

Update()
frame.Robux.MouseButton1Click:Connect(function()
	if flag2 or not name then
		return
	end

	_G.ClickFrameEffect({
		Sound = true,
		Parent = parent.Parent
	})
	flag2 = true
	frame.Robux.Size = UDim2.new(0.75, 0, 0.55, 0)
	TweenService:Create(
		frame.Robux,
		TweenInfo.new(0.075, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
		{
			Size = UDim2.new(0.9375, 0, 0.6875, 0)
		}
	):Play()
	ReplicatedStorage.Chest.Remotes.Functions.Product:InvokeServer({
		ProductName = name,
		PurchaseType = "FruitPermanently"
	})
	ReplicatedStorage.Chest.Remotes.Events.Product:FireServer(name, localPlayer.Name, true)
	flag2 = false
end)
frame.Buy.MouseButton1Click:Connect(function()
	if flag2 or localPlayer.Character.Humanoid.Health <= 0 then
		return
	end

	_G.ClickFrameEffect({
		Sound = true,
		Parent = parent.Parent
	})
	frame.Buy.Size = UDim2.new(0.75, 0, 0.55, 0)
	TweenService:Create(
		frame.Buy,
		TweenInfo.new(0.075, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
		{
			Size = UDim2.new(0.9375, 0, 0.6875, 0)
		}
	):Play()
	flag2 = true

	if v4[name] then
		ReplicatedStorage.Chest.Remotes.Functions.BuyFruitStock:InvokeServer(name)
	else
		local text3 = localPlayer.PlayerStats.Language.Value == "TH" and "ไม่มี!" or "No Sale!"
		local text = frame.Buy.Text
		frame.Buy.Text = text3
		wait(1.5)
		frame.Buy.Text = text
	end

	flag2 = false
end)
local v11 = nil
frame.Equip.MouseButton1Click:Connect(function()
	if v11 or localPlayer.Character.Humanoid.Health <= 0 then
		return
	end

	_G.ClickFrameEffect({
		Sound = true,
		Parent = parent.Parent
	})
	frame.Equip.Size = UDim2.new(0.75, 0, 0.55, 0)
	TweenService:Create(
		frame.Equip,
		TweenInfo.new(0.075, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
		{
			Size = UDim2.new(0.9375, 0, 0.6875, 0)
		}
	):Play()
	frame.Equip.CooldownFrame.Size = UDim2.new(1, 0, 1, 0)
	frame.Equip.CooldownFrame.Visible = true
	TweenService:Create(frame.Equip.CooldownFrame, TweenInfo.new(7, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0, 0, 1, 0)
	}):Play()
	v11 = true
	ReplicatedStorage.Chest.Remotes.Functions.dfswitch:InvokeServer(name)
	task.delay(7, function()
		v11 = nil
		frame.Equip.CooldownFrame.Visible = nil
	end)
end)
local closeButton = parent.CloseButton
closeButton.MouseButton1Click:Connect(function()
	_G.ClickFrameEffect({
		Sound = true,
		Sound2 = true
	})
	local mode = parent:GetAttribute("Mode")

	if mode then
	end

	_G.NPCTalk = false

	if v3 and v3.Parent then
		v3.BackgroundTransparency = 1
		v3 = nil
	end

	_G.ButtonClosed({
		Frame = parent
	})
end)
closeButton.MouseEnter:Connect(function()
	_G.ShineGui({
		Parent = closeButton,
		ZIndex = 5,
		Size = UDim2.fromScale(0.9, 0.9),
		Circle = true
	})
	closeButton.Size = UDim2.new(0.104, 0, 0.15, 0)
	TweenService:Create(closeButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.11959999999999998, 0, 0.1725, 0)
	}):Play()
end)
closeButton.MouseLeave:Connect(function()
	TweenService:Create(closeButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.104, 0, 0.15, 0)
	}):Play()
end)
localPlayer:WaitForChild("fruitsbought").ChildAdded:Connect(function()
	Update()
end)
ReplicatedStorage.Chest.Remotes.Events.DFUpdate.OnClientEvent:Connect(function()
	Update()
end)
spawn(function()
	while true do
		if v5 == "Stock" then
			local value = ReplicatedStorage.TimeLeft.Value
			textLabel.Text = (localPlayer.PlayerStats.Language.Value == "TH" and "เวลาจนกว่าจะรีร้านค้า: " or "Time Until Restock: ") .. tostring(value)
		end

		wait(1)
	end
end)