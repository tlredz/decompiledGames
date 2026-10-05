local localPlayer = game.Players.LocalPlayer
local frame = script.Frame
local imageButton = script.ImageButton
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local scrollingFrame = script.Parent.ScrollingFrame
local scrollingFrame2 = script.Parent.ReceiverMagic.Receiver.ScrollingFrame
local parent = script.Parent
local v = false
local Info = require(game.ReplicatedStorage.Info)
local giftData = {}
local giftableGamepasses = Info.GiftableGamepasses
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, scrollingFrame.UIGridLayout.AbsoluteContentSize.Y)
scrollingFrame.UIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, scrollingFrame.UIGridLayout.AbsoluteContentSize.Y)
end)
local receiver = parent.ReceiverMagic.Receiver
receiver:GetPropertyChangedSignal("Visible"):Connect(function()
	TweenService:Create(parent, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		Position = UDim2.new(receiver.Visible and 0.599 or 0.5, 0, 0.5, 0)
	}):Play()
end)
MarketplaceService.PromptProductPurchaseFinished:Connect(function(p)
	if p == localPlayer.UserId then
		v = false
	end
end)
local v3 = {}

local function iterPageItems(object)
	return coroutine.wrap(function()
		local v4 = 1

		while true do
			for _, v5 in ipairs(object:GetCurrentPage()) do
				coroutine.yield(v5, v4)
			end

			if object.IsFinished then
				break
			end

			object:AdvanceToNextPageAsync()
			v4 += 1
		end
	end)
end

pcall(function()
	local Players = game:GetService("Players")
	local friendsAsync = Players:GetFriendsAsync(localPlayer.UserId)
	local Players2 = game:GetService("Players")

	for _, v4 in pairs(Players2:GetPlayers()) do
		if v4 ~= localPlayer then
			table.insert(v3, { v4.Name, v4.DisplayName, v4.UserId })
		end
	end

	local ids = {}

	for k, _ in coroutine.wrap(function()
		local v4 = 1

		while true do
			for _, v5 in ipairs(friendsAsync:GetCurrentPage()) do
				coroutine.yield(v5, v4)
			end

			if friendsAsync.IsFinished then
				break
			end

			friendsAsync:AdvanceToNextPageAsync()
			v4 += 1
		end
	end) do
		table.insert(ids, k.Id)

		if k.IsOnline or math.random(1, 5) == 1 then
			table.insert(v3, { k.Username, k.DisplayName, k.Id })
		end
	end

	shared.friends = ids
end)
local v4 = nil

local function fn(gamepassid, devproduct)
	local productInfo = MarketplaceService:GetProductInfo(
		gamepassid,
		devproduct and Enum.InfoType.Product or Enum.InfoType.GamePass
	)

	if not productInfo.Name then
		return
	end

	local clone = frame:Clone()
	clone.ImageLabel.Image = "rbxassetid://" .. productInfo.IconImageAssetId
	clone.TextLabel.Text = productInfo.Name:upper():gsub(" RANDOM EMOTES", " EMOTES"):gsub(" SPINS", " COSMETICS")
	clone.ImageLabel.ImageColor3 = Color3.new(0.2, 0.2, 0.2)
	clone.TextLabel.TextLabel.Text = (productInfo.PriceInRobux or "N/A") .. " ROBUX"
	clone.Parent = scrollingFrame
	clone.Btn.MouseButton1Click:Connect(function()
		if v4 and v4 == clone then
			return
		end

		if v4 and not v4.Parent then
			v4 = nil
		end

		if not parent.ReceiverMagic.Receiver.Visible then
			shared.sfx({
				SoundId = "rbxassetid://10066914500",
				Parent = workspace,
				Volume = 0.5
			}):Play()
			parent.ReceiverMagic.Receiver.Position = UDim2.new(1.5, 0, 0.5, 0)
			TweenService:Create(
				parent.ReceiverMagic.Receiver,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{
					Position = UDim2.new(0.5, 0, 0.5, 0)
				}
			):Play()
		end

		parent.ReceiverMagic.Receiver.Visible = true
		giftData.Gamepass = gamepassid
		shared.sfx({
			SoundId = "rbxassetid://6895079853",
			Parent = workspace,
			Volume = 0.5
		}):Play()

		if v4 then
			TweenService:Create(v4.ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				ImageColor3 = Color3.new(0.2, 0.2, 0.2)
			}):Play()
		end

		v4 = clone
		TweenService:Create(clone.ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			ImageColor3 = Color3.new(1, 1, 1)
		}):Play()
	end)
end

local function fn2()
	local v5 = {}

	for k, giftableGamepass in pairs(giftableGamepasses) do
		table.insert(v5, {
			gamepassid = k,
			giftid = giftableGamepass[1],
			order = giftableGamepass[2],
			devproduct = giftableGamepass[3]
		})
	end

	for k, cosmeticProduct in pairs(Info.CosmeticProducts) do
		table.insert(v5, {
			gamepassid = cosmeticProduct.id,
			giftid = cosmeticProduct.id,
			order = 11 + k,
			devproduct = true
		})
	end

	local limited = workspace:GetAttribute("Limited")

	if limited then
		local HttpService = game:GetService("HttpService")
		local jSONDecode = HttpService:JSONDecode(limited)

		for k, item in pairs(jSONDecode.items) do
			table.insert(v5, {
				gamepassid = item.ID,
				giftid = item.ID,
				order = 14 + k,
				devproduct = true
			})
		end
	end

	for _, frame2 in pairs(scrollingFrame:GetChildren()) do
		if frame2:IsA("Frame") then
			frame2:Destroy()
		end
	end

	table.sort(v5, function(a, b)
		return b.order > a.order
	end)

	for _, v6 in pairs(v5) do
		fn(v6.gamepassid, v6.devproduct)
	end
end

workspace:GetAttributeChangedSignal("Limited"):Connect(fn2)
fn2()
local userThumbnailAsync = game.Players:GetUserThumbnailAsync(
	1001242712,
	Enum.ThumbnailType.HeadShot,
	Enum.ThumbnailSize.Size420x420
)
local v5 = {}
local v6 = nil

local function fn3(list)
	local clone = imageButton:Clone()
	clone.Avatar.Image = string.gsub(userThumbnailAsync, 1001242712, list[3])
	clone.Avatar.ImageColor3 = Color3.new(0.2, 0.2, 0.2)
	clone.TextLabel.Text = list[2]
	clone.TextLabel.TextLabel.Text = string.format("(@%s)", list[1])
	clone.MouseButton1Click:Connect(function()
		if v6 and v6 == clone then
			return
		end

		if v6 then
			TweenService:Create(v6.Avatar, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				ImageColor3 = Color3.new(0.2, 0.2, 0.2)
			}):Play()
			TweenService:Create(v6, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1
			}):Play()
		end

		shared.sfx({
			SoundId = "rbxassetid://6895079853",
			Parent = workspace,
			Volume = 0.5
		}):Play()

		if not parent.Send.Visible then
			parent.Send.Size = UDim2.new(0, 0, 0.094, 0)
			parent.Send.TextTransparency = 1.75
			TweenService:Create(parent.Send, TweenInfo.new(0.62, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Size = UDim2.new(1.552, 0, 0.094, 0),
				TextTransparency = 0
			}):Play()
			shared.sfx({
				SoundId = "rbxassetid://9114157527",
				Parent = workspace,
				PlaybackSpeed = 1.6,
				Volume = 0.3
			}):Play()
		end

		giftData.Receiver = list[3]
		parent.Send.Visible = true
		v6 = clone
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.75
		}):Play()
		TweenService:Create(clone.Avatar, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			ImageColor3 = Color3.new(1, 1, 1)
		}):Play()
	end)
	clone.Parent = scrollingFrame2
	table.insert(v5, clone)
	return clone
end

local v7 = 500

-- equivalent calls inferred from this helper; original call sites unknown
local function fn4()
	local Y = scrollingFrame2.UIListLayout.AbsoluteContentSize.Y

	if v7 < Y then
		v7 = Y
	end

	local v8 = math.max(Y, v7)
	scrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, v8)
end

fn4() -- equivalent call inferred; original call site unknown
scrollingFrame2.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(fn4)
local v8 = {}

for _, v9 in pairs(v3) do
	if v8[v9[3]] then
		continue
	end

	v8[v9[3]] = true
	fn3(v9)
end

local function fn5(p, value)
	if string.sub(string.lower(p.Name), 1, (string.len(value))) == string.lower(value) or string.sub(
		string.lower(p.DisplayName),
		1,
		(string.len(value))
	) == string.lower(value) then
		return true
	end
end

local textBox = scrollingFrame2.Parent.TextBox
local now = 0

local function fn6(p)
	scrollingFrame2.CanvasPosition = Vector2.new(0, 0)
	local v9 = 1

	if p == "" then
		for k, v10 in pairs(v5) do
			if v10.Parent then
				if v6 ~= v10 then
					v10.BackgroundTransparency = 0
					TweenService:Create(
						v10,
						TweenInfo.new(v9 * 0.15 + 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							BackgroundTransparency = 1
						}
					):Play()
				end

				v10.Visible = true
				v9 += 1
			else
				v5[k] = nil
			end
		end

		shared.sfx({
			SoundId = "rbxassetid://9114642939",
			Parent = workspace,
			Volume = 0.15
		}):Play()
	else
		for k, v10 in pairs(v5) do
			if v10.Parent then
				if fn5({
					Name = string.sub(v10.TextLabel.TextLabel.Text, 3, #v10.TextLabel.TextLabel.Text - 1),
					DisplayName = v10.TextLabel.Text
				}, p) or v10 == v6 then
					if v6 ~= v10 then
						v10.BackgroundTransparency = 0
						TweenService:Create(
							v10,
							TweenInfo.new(v9 * 0.15 + 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								BackgroundTransparency = 1
							}
						):Play()
					end

					v10.Visible = true
					v9 += 1
				else
					v10.Visible = false
				end
			else
				v5[k] = nil
			end
		end

		if v9 > 1 then
			shared.sfx({
				SoundId = "rbxassetid://9114642939",
				Parent = workspace,
				Volume = 0.15
			}):Play()
		end
	end
end

parent.Send.MouseButton1Click:Connect(function()
	shared.sfx({
		SoundId = "rbxassetid://6895079853",
		Parent = workspace,
		Volume = 0.5
	}):Play()
	local character = localPlayer.Character

	if not character then
		return
	end

	local communicate = character:FindFirstChild("Communicate")

	if not communicate then
		return
	end

	communicate:FireServer({
		Goal = "Gift Gamepass",
		GiftData = giftData
	})
	parent.Visible = false
end)
parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if not parent.Visible then
		parent.ReceiverMagic.Receiver.Visible = false
		parent.Send.Visible = false
		giftData = {}
		TweenService:Create(parent.Send, TweenInfo.new(0, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Size = UDim2.new(0, 0, 0.094, 0)
		}):Play()
		TweenService:Create(parent, TweenInfo.new(0, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}):Play()
		TweenService:Create(
			parent.ReceiverMagic.Receiver,
			TweenInfo.new(0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Position = UDim2.new(0.5, 0, 0.5, 0)
			}
		):Play()

		if v6 then
			TweenService:Create(v6.Avatar, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				ImageColor3 = Color3.new(0.2, 0.2, 0.2)
			}):Play()
			TweenService:Create(v6, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1
			}):Play()
			v6 = nil
		end

		if v4 then
			TweenService:Create(v4.ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				ImageColor3 = Color3.new(0.2, 0.2, 0.2)
			}):Play()
			v4 = nil
		end
	end
end)
textBox.Focused:Connect(function()
	shared.sfx({
		SoundId = "rbxassetid://6052548458",
		Parent = workspace,
		Volume = 0.2
	}):Play()
end)
textBox:GetPropertyChangedSignal("Text"):Connect(function()
	now = tick()
	shared.sfx({
		SoundId = "rbxassetid://147982968",
		Parent = workspace,
		Volume = 0.2,
		PlaybackSpeed = 2
	}):Play()
	task.delay(0.3, function()
		if tick() - now > 0.3 then
			local v9 = nil
			pcall(function()
				local userIdFromNameAsync = game.Players:GetUserIdFromNameAsync(textBox.Text)

				if userIdFromNameAsync then
					local UserService = game:GetService("UserService")
					local v10 = UserService:GetUserInfosByUserIdsAsync({ userIdFromNameAsync })[1]

					if v10 then
						local v11 = { v10.Username, v10.DisplayName, v10.Id }

						if not v8[v11[3]] and v11[3] ~= localPlayer.UserId then
							v8[v11[3]] = true
							fn3(v11)
							v9 = v11[1]
						end
					end
				end
			end)
			fn6(v9 or textBox.Text)
		end
	end)
end)
textBox.Visible = true
textBox.Parent.Frame.Visible = true
game.Players.PlayerAdded:Connect(function(player)
	local v9 = { player.Name, player.DisplayName, player.UserId }

	if not v8[v9[3]] and v9[3] ~= localPlayer.UserId then
		v8[v9[3]] = true
		local v10 = fn3(v9)
		player:GetPropertyChangedSignal("Parent"):Connect(function()
			if not player.Parent then
				if v6 == v10 then
					v6 = nil
				end

				table.remove(v5, table.find(v5, v10))
				v10:Destroy()
				v8[v9[3]] = nil
			end
		end)
	end
end)

function shared.giftgui()
	if not parent.Visible then
		Info.hideGUI(script.Parent.Parent)
		shared.virtualcursor(script.Parent.Parent)
	end

	parent.Visible = not parent.Visible
end