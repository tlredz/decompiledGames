local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local globalGiftFrame = script.Parent:WaitForChild("GlobalGiftFrame")
local giftButton = script.Parent:WaitForChild("GiftButton")
local bindableEvent = Instance.new("BindableEvent")
Instance.new("BindableEvent")
local scrollingClaim = globalGiftFrame.Frame.ScrollingClaim
local scrollingHistory = globalGiftFrame.Frame.ScrollingHistory
ReplicatedStorage:WaitForChild("Chest")
local transactions = ReplicatedStorage.Chest.Remotes.Functions.Transactions
local CollectibleList = require(ReplicatedStorage.Chest.Modules.CollectibleList)
local v = {}
local v2 = nil
local thread = nil

function GetGiftCount()
	local count = 0

	for _, button in pairs(scrollingClaim:GetChildren()) do
		if button:IsA("TextButton") then
			count += 1
		end
	end

	return count
end

function GetHistoryCount()
	local count = 0

	for _, button in pairs(scrollingHistory:GetChildren()) do
		if button:IsA("TextButton") then
			count += 1
		end
	end

	return count
end

function ClearGiftFrame()
	for _, button in pairs(scrollingClaim:GetChildren()) do
		if button:IsA("TextButton") then
			button:Destroy()
		end
	end
end

function ClearHistoryFrame()
	for _, button in pairs(scrollingHistory:GetChildren()) do
		if not button:IsA("TextButton") or button:GetAttribute("LoadButton") then
			continue
		end

		button:Destroy()
	end
end

function CreateProfile(p)
	local success, result = pcall(function()
		return game.Players:GetUserThumbnailAsync(p, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size150x150)
	end)
	local v3 = success and result or ""
	v[p] = v3
	return v3
end

function UpdateTransactions()
	ClearGiftFrame()
	local v3 = transactions:InvokeServer("GetTransactions")
	giftButton.Alert.Visible = nil
	globalGiftFrame.Frame.GiftInfo.Text = "You have 0 unclaimed gift!"

	if not v3 then
		return
	end

	table.sort(v3, function(a, b)
		return a.SentTime > b.SentTime
	end)
	local count = 0
	local visible = nil

	for i = 1, #v3 do
		local v5 = v3[i]

		if not v5 then
			continue
		end

		local giftItem = v5.GiftItem
		local v6 = giftItem and CollectibleList[giftItem]

		if not v6 then
			continue
		end

		local giftID = v5.GiftID
		local _ = v5.GiftType
		local message = v5.Message
		local sender = v5.Sender
		local senderId = v5.SenderId
		local sentTime = v5.SentTime
		local image = v[senderId] or CreateProfile(senderId)
		local text = os.date("%b %d, %Y, %I:%M %p", sentTime)
		local clone = script.ClaimButton:Clone()
		clone.LayoutOrder = i
		clone.Name = giftID
		clone.ItemImage.Image = v6.Image or ""
		clone.Logo.Image = image
		clone.TimeStamp.Text = text
		clone.Message.Text = message or ""
		clone.SentLabel.Text = "@" .. sender .. " sent you <font color = \"#00ff00\">" .. (v6.Name or giftItem) .. "</font>"
		clone.MouseButton1Click:Connect(function()
			if transactions:InvokeServer("ReceiveGift", {
				GiftID = giftID
			}) == "Success" then
				clone:Destroy()
				globalGiftFrame.Frame.GiftInfo.Text = "You have " .. GetGiftCount() .. " unclaimed gift!"
			end
		end)
		local parent = clone
		clone.MouseEnter:Connect(function()
			_G.ShineGui({
				Parent = parent,
				ZIndex = 5
			})
		end)
		clone.Parent = scrollingClaim
		count += 1
		visible = true
	end

	giftButton.Alert.Visible = visible
	globalGiftFrame.Frame.GiftInfo.Text = "You have " .. tostring(count) .. " unclaimed gift!"
end

function UpdateHistory()
	ClearHistoryFrame()
	local v3 = transactions:InvokeServer("GetHistoryTransactions")

	if not v3 then
		return
	end

	v2 = #v3
	table.sort(v3, function(a, b)
		return a.ClaimedTime > b.ClaimedTime
	end)

	if scrollingHistory.Visible then
		globalGiftFrame.Frame.GiftInfo.Text = #v3 .. " Gifts Claimed!"
	end

	if thread then
		task.cancel(thread)
		thread = nil
	end

	thread = task.spawn(function()
		for i = 1, #v3 do
			local v4 = v3[i]

			if not v4 then
				continue
			end

			local giftItem = v4.GiftItem
			local v5 = giftItem and CollectibleList[giftItem]

			if not v5 then
				continue
			end

			local giftID = v4.GiftID
			local _ = v4.GiftType
			local message = v4.Message
			local sender = v4.Sender
			local senderId = v4.SenderId
			local sentTime = v4.SentTime
			local image = v[senderId] or CreateProfile(senderId)
			local text = os.date("%b %d, %Y, %I:%M %p", sentTime)
			local clone = script.ClaimButton:Clone()
			clone.Interactable = false
			clone.LayoutOrder = i
			clone.Name = giftID
			clone.BG.ImageColor3 = Color3.fromRGB(129, 129, 129)
			clone.ItemImage.Image = v5.Image or ""
			clone.Logo.Image = image
			clone.TimeStamp.Text = text
			clone.Message.Text = message or ""
			clone.SentLabel.Text = "@" .. sender .. " sent you <font color = \"#00ff00\">" .. (v5.Name or giftItem) .. "</font>"
			clone.Parent = scrollingHistory

			if scrollingHistory.Visible then
				globalGiftFrame.Frame.GiftInfo.Text = #v3 .. " Gifts Claimed!"
			end

			if i % 25 == 0 then
				bindableEvent.Event:Wait()
			end

			if i % 2 == 0 then
				RunService.Heartbeat:Wait()
			end
		end
	end)
end

local function GetLeastestLayoutOrder(scrollingHistory2)
	local layoutOrder = 1e999

	for _, button in pairs(scrollingHistory2:GetChildren()) do
		if button:IsA("TextButton") and button.LayoutOrder < layoutOrder then
			layoutOrder = button.LayoutOrder
		end
	end

	return layoutOrder - 1
end

function NewReceivedHistory(data)
	if not data then
		return
	end

	local giftItem = data.GiftItem
	local v3 = giftItem and CollectibleList[giftItem]

	if not v3 then
		return
	end

	local giftID = data.GiftID

	if scrollingHistory:FindFirstChild(giftID) then
		return
	end

	local _ = data.GiftType
	local message = data.Message
	local sender = data.Sender
	local senderId = data.SenderId
	local sentTime = data.SentTime
	local image = v[senderId] or CreateProfile(senderId)
	local text = os.date("%b %d, %Y, %I:%M %p", sentTime)
	local clone = script.ClaimButton:Clone()
	clone.Interactable = false
	clone.LayoutOrder = GetLeastestLayoutOrder(scrollingHistory)
	clone.Name = giftID
	clone.BG.ImageColor3 = Color3.fromRGB(129, 129, 129)
	clone.ItemImage.Image = v3.Image or ""
	clone.Logo.Image = image
	clone.TimeStamp.Text = text
	clone.Message.Text = message or ""
	clone.SentLabel.Text = "@" .. sender .. " sent you <font color = \"#00ff00\">" .. (v3.Name or giftItem) .. "</font>"
	clone.Parent = scrollingHistory
end

UpdateTransactions()
UpdateHistory()
scrollingClaim:GetPropertyChangedSignal("Visible"):Connect(function()
	if not scrollingClaim.Visible then
		return
	end

	task.wait()
	globalGiftFrame.Frame.GiftInfo.Text = "You have " .. GetGiftCount() .. " unclaimed gift!"
end)
scrollingHistory:GetPropertyChangedSignal("Visible"):Connect(function()
	wait()

	if not scrollingHistory.Visible then
		return
	end

	globalGiftFrame.Frame.GiftInfo.Text = (v2 or GetHistoryCount()) .. " Gifts Claimed!"
end)
scrollingHistory:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
	wait()

	if scrollingHistory.CanvasPosition.Y + scrollingHistory.AbsoluteSize.Y / 0.99 >= scrollingHistory.UIListLayout.AbsoluteContentSize.Y then
		bindableEvent:Fire()
	end
end)
ReplicatedStorage.Chest.Remotes.Events.GiftUpdater.OnClientEvent:Connect(function(p, ...)
	if p == "NewReceivedHistory" then
		return NewReceivedHistory(...)
	elseif p == "UpdateTransactions" then
		return UpdateTransactions(...)
	elseif p == "UpdateHistory" then
		return UpdateHistory(...)
	end
end)