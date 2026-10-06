local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Config = require(ReplicatedStorage.Engine.Service.Config)
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local GachaPool = require(ReplicatedStorage.Engine.Service.GachaPool)
local DailyShopService = require(ReplicatedStorage.Engine.Service.DailyShopService)
local DevProductService = require(ReplicatedStorage.Engine.Market.DevProductService)
local DiamondTopUpService = require(ReplicatedStorage.Engine.Service.DiamondTopUpService)
local ClaimQueue = require(script.Parent.Parent.ClaimQueue)
local v = {
	["金币"] = "金币购买按钮",
	["钻石"] = "钻石购买按钮",
	Robux = "Robux购买按钮",
	sold = "已售出按钮"
}
local _ = {
	["金币"] = "coins",
	["钻石"] = "diamonds"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function isImage(value)
	return typeof(value) == "string" and string.match(value, "^%a+://") ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ratingColorHex(rating: number?)
	for _, v2 in Config.rating.list do
		if v2.lvl == rating then
			return v2.colorHex
		end
	end

	return "#FFFFFF"
end

local function isShown(parent)
	while parent do
		if parent:IsA("GuiObject") and not parent.Visible then
			return false
		end

		if parent:IsA("ScreenGui") and not parent.Enabled then
			return false
		else
			parent = parent.Parent
		end
	end

	return true
end

local function showClaim(result)
	if typeof(result) ~= "table" or not result.ok or typeof(result.cnId) ~= "string" then
		return
	end

	local v2

	if result.itemType == "Ball" then
		v2 = Config.ball.byCnId[result.cnId]
	else
		v2 = Config.skin.byCnId[result.cnId]
	end

	if not v2 then
		return
	end

	local enqueue = ClaimQueue.enqueue
	local v3 = {
		image = not isImage(v2.image) and "" or v2.image,
		name = v2.displayName or v2.name,
		colorHex = 0,
		serial = 0
	}
	local colorHex = ratingColorHex(v2.rating) -- equivalent call inferred; original call site unknown
	v3.colorHex = colorHex
	v3.serial = result.serial
	enqueue(v3)
end

return {
	Init = function(instance, callback)
		local v2 = instance:WaitForChild("每日商店")
		local v3 = v2:WaitForChild("商品列表")
		local v4 = v2:WaitForChild("刷新倒计时")
		local v5 = v3:WaitForChild("按钮样式预览")
		local clones = {}

		for k, childName in v do
			local clone = v5:WaitForChild(childName):Clone()
			clone.Parent = nil
			clones[k] = clone
		end

		v5.Visible = false
		local v6 = {}
		local flag = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function currentRow(p: string)
			local dailyShop = client.dailyShop()
			return DailyShopService.getSlotRow(p, dailyShop.slots[p])
		end

		local function denied(state)
			local button = state.button

			if not button or state.shaking then
				return
			end

			state.shaking = true
			local position = button.Position
			local backgroundColor3 = button.BackgroundColor3
			button.BackgroundColor3 = Color3.fromRGB(255, 76, 76)
			task.spawn(function()
				for _, v7 in {
					6,
					-6,
					6,
					0
				} do
					local tween = TweenService:Create(button, TweenInfo.new(0.06), {
						Position = position + UDim2.fromOffset(v7, 0)
					})
					tween:Play()
					tween.Completed:Wait()
				end

				if button.Parent then
					button.Position = position
					button.BackgroundColor3 = backgroundColor3
				end

				state.shaking = false
			end)
		end

		local function onActivated(p: string)
			local v7 = v6[p]
			local v8 = currentRow(p) -- equivalent call inferred; original call site unknown
			local v9 = v8 and DailyShopService.getOffer(p, v8.itemType, v8.rating)

			if not v9 or client.dailyShop().purchased[p] then
				return
			end

			if v9.currency == "Robux" then
				DailyShopService.client.promptRobux(v9.productKey)
				return
			end

			if flag then
				return
			end

			flag = true
			local success, result = pcall(DailyShopService.client.buy, p)
			flag = false

			if success and result and result.ok then
				showClaim(result.result)
			elseif success and result and result.reason == "insufficient" then
				denied(v7)

				if v9.currency == "钻石" then
					DiamondTopUpService.promptIfInsufficient(v9.price)
				end
			elseif not success or result and result.reason ~= "busy" and result.reason ~= "sold_out" then
				if success and result then
					result = result.reason
				end

				warn("[DailyShop] 购买失败: " .. tostring(result))
			end
		end

		local function setButton(p: string, state, style: string)
			if state.style == style and state.button and state.button.Parent then
				return state.button
			end

			local button = state.button or state.frame:FindFirstChild("购买按钮")
			local clone = clones[style]:Clone()
			clone.Name = "购买按钮"

			if button then
				clone.Size = button.Size
				clone.Position = button.Position
				clone.AnchorPoint = button.AnchorPoint
				clone.LayoutOrder = button.LayoutOrder
			end

			if style == "sold" then
				clone.Active = false
				clone.AutoButtonColor = false
				clone.Selectable = false
			else
				callback(clone)
				ButtonActions.Bind(clone, function()
					onActivated(p)
				end)
			end

			clone.Parent = state.frame

			if button then
				button:Destroy()
			end

			state.button = clone
			state.style = style
			state.shaking = false
			return clone
		end

		local function findIcon(instance2, itemType: string)
			local image = instance2:FindFirstChild(itemType .. "图标")

			if image and image:IsA("ImageLabel") then
				return image
			end

			for _, image2 in instance2:GetChildren() do
				if image2:IsA("ImageLabel") and string.sub(image2.Name, -6) == "图标" then
					return image2
				end
			end

			return nil
		end

		local function renderSlot(k: string)
			local v7 = v6[k]
			local dailyShop = client.dailyShop()
			local slotRow = DailyShopService.getSlotRow(k, dailyShop.slots[k])
			local v8 = slotRow and GachaPool.getDefinition(slotRow)
			local v9 = v8 and DailyShopService.getOffer(k, slotRow.itemType, v8.rating)
			v7.frame.Visible = v9 ~= nil

			if not v9 then
				return
			end

			local firstChild = v7.frame:FindFirstChild("商品展示")

			if firstChild then
				local icon = findIcon(firstChild, slotRow.itemType)

				if icon then
					icon.Image = not isImage(v8.image) and "" or v8.image
				end

				local firstChild2 = firstChild:FindFirstChild("商品名称")

				if firstChild2 then
					firstChild2.Text = v8.displayName or v8.name or slotRow.targetId
				end

				local firstChild3 = firstChild:FindFirstChild("品质描边")

				if firstChild3 then
					local v10 = ratingColorHex(v8.rating) -- equivalent call inferred; original call site unknown
					firstChild3.Color = Color3.fromHex(v10)
				end
			end

			if dailyShop.purchased[k] then
				setButton(k, v7, "sold")
				return
			end

			local firstChild2 = setButton(k, v7, v9.currency):FindFirstChild("价格")

			if firstChild2 then
				local price = v9.price

				if v9.currency == "Robux" then
					local v10 = DevProductService.products.byProductKey[v9.productKey]

					if v10 then
						price = v10.PriceInRobux
					else
						price = v9.price
					end
				end

				firstChild2.Text = tostring(price)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function render()
			for k in v6 do
				renderSlot(k)
			end
		end

		for _, childName in DailyShopService.SLOT_IDS do
			local child = v3:FindFirstChild(childName)

			if child then
				v6[childName] = {
					frame = child,
					style = nil,
					button = child:FindFirstChild("购买按钮"),
					shaking = false
				}
			else
				warn((`[DailyShop] 商品列表下找不到格子 {childName}（需与 Config.dailyShop 的 cnId 同名），该格不显示`))
			end
		end

		render() -- equivalent call inferred; original call site unknown
		client.dailyShop.Changed(render)
		DailyShopService.client.onGranted(showClaim)
		local total = 0
		RunService.Heartbeat:Connect(function(dt)
			total += dt

			if total < 0.25 then
				return
			end

			total = 0

			if not isShown(v4) then
				return
			end

			local v7 = math.floor((DailyShopService.secondsUntilRefresh()))
			v4.Text = string.format("Refreshes in  %02d:%02d:%02d", v7 // 3600, v7 % 3600 // 60, v7 % 60)
		end)
	end
}