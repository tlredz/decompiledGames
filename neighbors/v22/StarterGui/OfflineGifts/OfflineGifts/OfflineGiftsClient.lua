local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local Players = game:GetService("Players")
local modules = ReplicatedStorage.Modules
local UI = require(modules.UI)
local Network = require(modules.Network)
require(modules.Icon)
local Date = require(modules.Date)
local Icon = require(modules.Icon)
local store = ReplicatedStorage.Assets.Data.Store
local Currency = require(store.Currency)
local Gamepasses = require(store.Gamepasses)
local Bundles = require(store.Bundles)
local WeeklyStore = require(store.Parent.WeeklyStore)
local parent = script.Parent
local uIScale = parent.Parent:WaitForChild("UIScale")
local success = parent.Sounds.Success
local v = Icon.new()
v:setEnabled(false):setImage("rbxassetid://13848209741"):setRight():setImageScale(0.7):setOrder(1):oneClick():bindEvent(
	"deselected",
	function()
		parent.Visible = not parent.Visible
	end
)
local v2 = false
local now = false
local lastTime = tick()

local function getNumberOfActiveGifts()
	local count = 0

	for _, frame in parent.Items:GetChildren() do
		if frame:IsA("Frame") then
			count += 1
		end
	end

	return count
end

-- equivalent calls inferred from this helper; original call sites unknown
local function displayGiftsNotification()
	task.delay(1, function()
		local numberOfActiveGifts = getNumberOfActiveGifts()

		if numberOfActiveGifts > 1 then
			_G.DisplayText("You have multiple gifts pending!", 8)
		elseif numberOfActiveGifts == 1 then
			_G.DisplayText("You have a gift pending!", 6)
		end
	end)
end

local function getProductName(productId: number, giftId: string)
	if string.find(giftId, "_banner#") then
		for k, allBanner in WeeklyStore.AllBanners do
			if giftId:split("#")[2]:split("#")[1] ~= `{k:lower()}_banner` then
				continue
			end

			for k2, productId2 in allBanner.ProductIds do
				if productId2 == productId then
					return (`{allBanner.Display} {k2}x`)
				end
			end
		end
	end

	for _, v3 in Currency do
		if v3.Display and (v3.Id == productId or v3.AdultId == productId) then
			return v3.Display
		end
	end

	for _, gamepass in Gamepasses do
		if gamepass.Display and (gamepass.Id == productId or gamepass.AdultGiftId == productId or gamepass.GiftId == productId) then
			return gamepass.Display
		end
	end

	for _, bundle in Bundles do
		if bundle.Display and (bundle.ProductId == productId or bundle.TestProductId == productId or bundle.AdultProductId == productId) then
			return bundle.Display
		end
	end

	return "Unknown"
end

local function renderPendingGift(items)
	if not v2 and tick() - lastTime < 15 then
		v2 = true
		displayGiftsNotification() -- equivalent call inferred; original call site unknown
	end

	for _, item in items do
		local clone = script.Entry:Clone()
		local giftMessage = item.giftMessage
		local productId = item.productId
		local giftedBy = item.giftedBy
		local giftDate = item.giftDate
		local giftId = item.giftId
		local productName = getProductName(productId, giftId)
		local success2, result = pcall(function()
			return Players:GetNameFromUserIdAsync(giftedBy)
		end)

		if not success2 then
			result = giftedBy
		end

		local v5 = giftedBy

		local function updateUserText()
			if not clone:FindFirstChild("Top") then
				return
			end

			local success3, result2 = pcall(function()
				return Players:GetUserThumbnailAsync(v5, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
			end)

			if success3 and result2 then
				clone.Top.Icon.Image = result2
			end

			clone.Top.User.Text = `@{result} ({Date:FormatDate(giftDate)}) <b>{productName}</b>`
		end

		local updateUserText2 = updateUserText
		parent:GetPropertyChangedSignal("Visible"):Connect(function()
			updateUserText2()
		end)
		updateUserText()
		clone.Content.Text = giftMessage
		local v8 = item
		clone.Accept.Button.Activated:Connect(function()
			if now and not (tick() - now > 5) then
				_G.DisplayError(`Wait {5 - math.floor(tick() - now)} seconds to accept.`, 3)
				return
			end

			now = tick()
			Network:fire("OfflineGifting", "AcceptGift", v8.giftId)
		end)
		UI:Bind(clone.Accept.Button)
		UI:AddShadowOnHover(clone.Accept.Button)
		clone:SetAttribute("time", giftDate)
		clone:SetAttribute("giftId", giftId)
		clone.LayoutOrder = -giftDate
		clone.Parent = parent.Items
	end
end

parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if parent.Visible then
		parent.Sounds.Open:Play()
	end
end)
parent.Items.ChildAdded:Connect(function()
	parent.Empty.Visible = not parent.Items:FindFirstChildOfClass("Frame")
	v:setEnabled(not parent.Empty.Visible)
	v:notify()
end)
parent.Items.ChildRemoved:Connect(function()
	parent.Empty.Visible = not parent.Items:FindFirstChildOfClass("Frame")
	v:setEnabled(not parent.Empty.Visible)
end)
parent.Close.Activated:Connect(function()
	parent.Visible = false
end)

if UI:GetDeviceType() == "Mobile" then
	UI:FillFrameToMaxHeight(parent, uIScale, 10)
else
	UI:RegisterUIScale(uIScale, {
		PC = 2,
		Mobile = 1.5,
		Tablet = 1.5
	})
end

Network:listen("OfflineGifting", function(p, p2)
	if p == "RenderGift" then
		renderPendingGift(p2)
	elseif p == "AcceptedGift" then
		for _, child in parent.Items:GetChildren() do
			if child:GetAttribute("giftId") ~= p2 then
				continue
			end

			if success.IsPlaying then
				success.PlaybackSpeed += 0.1
			else
				success.PlaybackSpeed = 1
			end

			child:Destroy()
			success:Play()
		end
	end
end)