local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PurchaseCue = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PurchaseCue"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local playersHolder = parent:WaitForChild("PlayersHolder")
local giftPlayerFrame = script:WaitForChild("GiftPlayerFrame")
local products = parent.Parent:WaitForChild("Products")
local giftingMode = products:WaitForChild("GiftingMode")
local search = parent:WaitForChild("Search")
local productId = parent:WaitForChild("Data"):WaitForChild("ProductId")
local productName = parent:WaitForChild("Header"):WaitForChild("ProductName")
local SFX = game.SoundService:WaitForChild("SFX")
local UIController = require(game.ReplicatedStorage:WaitForChild("UIController"))
local updatePlayerToGift = ReplicatedStorage2:WaitForChild("Remotes"):WaitForChild("Reusable"):WaitForChild("UpdatePlayerToGift")
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function ThumbnailFor(p: number)
	if v[p] then
		return v[p]
	end

	local success, result = pcall(function()
		return Players:GetUserThumbnailAsync(p, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)
	local v2 = success and result or ""
	v[p] = v2
	return v2
end

local function EnsureThumbnail(instance)
	if instance:GetAttribute("ThumbRequested") then
		return
	end

	instance:SetAttribute("ThumbRequested", true)
	local name = tonumber(instance.Name)

	if not name then
		return
	end

	task.spawn(function()
		local image = ThumbnailFor(name) -- equivalent call inferred; original call site unknown
		local playerImage = instance:FindFirstChild("PlayerImage")

		if image ~= "" and playerImage and instance.Parent then
			playerImage.Image = image
		end
	end)
end

local function StartGifting(recipientUserId: number, text: string, image: string)
	SFX.Click:Play()
	updatePlayerToGift:FireServer(recipientUserId)
	giftingMode:SetAttribute("RecipientUserId", recipientUserId)
	giftingMode:SetAttribute("RecipientName", text)
	local playerName = giftingMode:FindFirstChild("PlayerName")

	if playerName then
		playerName.Text = text
	end

	local playerImage = giftingMode:FindFirstChild("PlayerImage")

	if playerImage and image ~= "" then
		playerImage.Image = image
	end

	UIController.close(parent)
	UIController.open(giftingMode)
	UIController.open(products)
end

local function RowMatches(instance, text: string)
	if text == "" then
		return true
	end

	local displayName = string.lower(instance:GetAttribute("DisplayName") or "")
	local username = string.lower(instance:GetAttribute("Username") or "")
	return string.find(displayName, text, 1, true) ~= nil or string.find(username, text, 1, true) ~= nil
end

local AddRow

local function ApplyFilter()
	local text = string.lower(search.Text)
	local count = 0

	for _, guiObject in playersHolder:GetChildren() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local visible = RowMatches(guiObject, text)
		guiObject.Visible = visible

		if not visible then
			continue
		end

		count += 1
		EnsureThumbnail(guiObject)
	end

	return count
end

local count = 0

local function ScheduleLookup()
	count += 1
	local v2 = count
	local text = search.Text

	if #text < 3 then
		return
	end

	task.delay(0.5, function()
		if v2 ~= count or search.Text ~= text then
			return
		end

		local success, result = pcall(function()
			return Players:GetUserIdFromNameAsync(text)
		end)

		if not success or not result or v2 ~= count then
			return
		end

		local v3 = text
		local nameFromUserIdAsync = nil

		if pcall(function()
			nameFromUserIdAsync = Players:GetNameFromUserIdAsync(result)
		end) then
			v3 = nameFromUserIdAsync or v3
		end

		AddRow(result, v3, text, 3)
		ApplyFilter()
	end)
end

search:GetPropertyChangedSignal("Text"):Connect(function()
	if ApplyFilter() == 0 then
		count += 1
		local v2 = count
		local text = search.Text

		if #text < 3 then
			return
		else
			task.delay(0.5, function()
				if v2 ~= count or search.Text ~= text then
					return
				end

				local success, result = pcall(function()
					return Players:GetUserIdFromNameAsync(text)
				end)

				if not success or not result or v2 ~= count then
					return
				end

				local v3 = text
				local nameFromUserIdAsync = nil

				if pcall(function()
					nameFromUserIdAsync = Players:GetNameFromUserIdAsync(result)
				end) then
					v3 = nameFromUserIdAsync or v3
				end

				AddRow(result, v3, text, 3)
				ApplyFilter()
			end)
		end
	end
end)

AddRow = function(p: number, text: string, username: string, layoutOrder: number)
	if p == localPlayer.UserId or playersHolder:FindFirstChild((tostring(p))) then
		return
	end

	local clone = giftPlayerFrame:Clone()
	clone.Name = tostring(p)
	clone.LayoutOrder = layoutOrder
	clone:SetAttribute("DisplayName", text)
	clone:SetAttribute("Username", username)
	clone.Visible = RowMatches(clone, string.lower(search.Text))
	clone.Parent = playersHolder
	local playerName = clone:FindFirstChild("PlayerName")

	if playerName then
		playerName.Text = text
	end

	local username2 = clone:FindFirstChild("Username")

	if username2 then
		username2.Text = "@" .. username
	end

	if clone.Visible then
		EnsureThumbnail(clone)
	end

	local gift = clone:FindFirstChild("Gift")

	if gift then
		gift.Activated:Connect(function()
			local value = tonumber(productId.Value)

			if value and value > 0 then
				SFX.Click:Play()
				updatePlayerToGift:FireServer(p, value)
				UIController.close(parent)
				PurchaseCue.Play()
				MarketplaceService:PromptProductPurchase(localPlayer, value)
			else
				local image = ThumbnailFor(p) -- equivalent call inferred; original call site unknown
				StartGifting(p, text, image)
			end
		end)
	end
end

local flag = false

local function Rebuild()
	if flag then
		return
	end

	flag = true

	for _, guiObject in playersHolder:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	for _, v2 in Players:GetPlayers() do
		AddRow(v2.UserId, v2.DisplayName, v2.Name, 1)
	end

	task.spawn(function()
		local success, result = pcall(function()
			return Players:GetFriendsAsync(localPlayer.UserId)
		end)

		if not (success and result) then
			flag = false
			return
		end

		local count2 = 0

		while count2 < 400 do
			for _, v3 in result:GetCurrentPage() do
				AddRow(v3.Id, v3.DisplayName or v3.Username, v3.Username, 2)
				count2 += 1

				if count2 >= 400 then
					break
				end
			end

			if result.IsFinished or count2 >= 400 or not pcall(function()
				result:AdvanceToNextPageAsync()
			end) then
				break
			end
		end

		ApplyFilter()
		flag = false
	end)
	flag = false
end

parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if parent.Visible then
		search.Text = ""
		Rebuild()
	else
		productId.Value = ""
		productName.Text = ""
	end
end)

if parent.Visible then
	Rebuild()
end