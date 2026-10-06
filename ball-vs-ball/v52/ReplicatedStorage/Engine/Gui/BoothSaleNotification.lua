local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Engine.Service.Config)
local BoothService = require(ReplicatedStorage.Engine.Service.BoothService)
local ClaimQueue = require(script.Parent.ClaimQueue)
local ConfirmDialogController = require(script.Parent.ConfirmDialogController)
local NumberFormat = require(ReplicatedStorage.Packages.NumberFormat)
local flag = false
local v = {}
local v2 = {}

local function accept(data, p: string)
	if typeof(data) ~= "table" or typeof(data.transactionId) ~= "string" or typeof(data.itemType) ~= "string" or typeof(data.itemId) ~= "string" or typeof(data.buyerName) ~= "string" or typeof(data.netIncome) ~= "number" or data.netIncome <= 0 then
		return false
	end

	local userId = Players.LocalPlayer.UserId

	if p == "buyer" and data.buyerUserId ~= userId or p == "seller" and data.sellerUserId ~= userId then
		return false
	end

	local v3 = p .. ":" .. data.transactionId

	if v[v3] then
		return false
	end

	v[v3] = true
	table.insert(v2, v3)

	if #v2 > 256 then
		v[table.remove(v2, 1)] = nil
	end

	return true
end

local function resolveDisplay(data)
	local displayName

	if data.itemType == "Ball" then
		displayName = Config.ball.byCnId[data.itemId]
	else
		displayName = Config.skin.byCnId[data.itemId]
	end

	local colorHex = "#FFFFFF"

	if displayName then
		for _, v4 in Config.rating.list do
			if v4.lvl ~= displayName.rating then
				continue
			end

			colorHex = v4.colorHex
			break
		end
	end

	local image = displayName and displayName.image

	if displayName then
		if data.itemType == "Ball" then
			displayName = displayName.displayName
		else
			displayName = displayName.name
		end
	end

	local v3 = {
		name = displayName or data.itemId,
		image = (typeof(image) ~= "string" or not string.match(image, "^%a+://")) and "" or image,
		colorHex = colorHex,
		serial = 0
	}
	local serial

	if typeof(data.serial) == "number" then
		serial = data.serial
	end

	v3.serial = serial
	return v3
end

local BoothSaleNotification = {
	ShowPurchase = function(p, instance)
		if not accept(p, "buyer") then
			return
		end

		local display = resolveDisplay(p)

		if not instance.Visible then
			ClaimQueue.enqueue(display)
			return
		end

		local visibleChangedConnection = nil
		visibleChangedConnection = instance:GetPropertyChangedSignal("Visible"):Connect(function()
			if instance.Visible then
				return
			end

			if visibleChangedConnection then
				visibleChangedConnection:Disconnect()
				visibleChangedConnection = nil
			end

			ClaimQueue.enqueue(display)
		end)
	end
}

local function showSold(p)
	if not accept(p, "seller") then
		return
	end

	local display = resolveDisplay(p)
	local connection = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cleanup()
		if connection then
			connection:Disconnect()
			connection = nil
		end
	end

	ConfirmDialogController.Enqueue("摆摊售出提示面板", {
		category = "BoothSale",
		onShown = function(instance, callback)
			cleanup() -- equivalent call inferred; original call site unknown
			local v3 = instance:WaitForChild("买家提示")
			local v4 = instance:WaitForChild("物品卡片")
			local v5 = v4:WaitForChild("名称")
			local v6 = v5:WaitForChild("文字")
			local v7 = v4:WaitForChild("物品图标")
			local v8 = v4:WaitForChild("唯一编号")
			local v9 = instance:WaitForChild("到账钻石"):WaitForChild("数量")
			v3.Text = p.buyerName .. " bought your"
			v6.Text = display.name
			v7.Image = display.image
			v8.Visible = display.serial ~= nil
			v8.Text = not display.serial and "" or "#" .. NumberFormat.commaFormat(display.serial)
			v9.Text = "+" .. NumberFormat.commaFormat(p.netIncome)
			local color = Color3.fromHex(display.colorHex)
			local uIStroke = v4:FindFirstChildOfClass("UIStroke")
			local uIStroke2 = v5:FindFirstChildOfClass("UIStroke")

			if uIStroke then
				uIStroke.Color = color
			end

			if uIStroke2 then
				uIStroke2.Color = color
			end

			local v10 = instance:WaitForChild("确定按钮")
			connection = ConfirmDialogController.BindButton(v10, "A", callback)
		end,
		onHidden = cleanup
	})
end

function BoothSaleNotification.Init()
	if flag then
		return
	end

	flag = true
	ConfirmDialogController.Init()
	BoothService.client.onSold(showSold)
end

return BoothSaleNotification