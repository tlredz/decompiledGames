local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NumberFormat = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NumberFormat"))
local engine = ReplicatedStorage:WaitForChild("Engine")
local Config = require(engine:WaitForChild("Service"):WaitForChild("Config"))
local TimedPurchaseService = require(engine:WaitForChild("Service"):WaitForChild("TimedPurchaseService"))
local DevProductService = require(engine:WaitForChild("Market"):WaitForChild("DevProductService"))
local ConfirmDialogController = require(script.Parent:WaitForChild("ConfirmDialogController"))
local ClaimQueue = require(script.Parent:WaitForChild("ClaimQueue"))
local StarterPackOffer = {}
local flag = false
local v = nil
local updateButtons = {}
local v2 = nil
local v3 = nil

local function isOfferActive(p)
	return p ~= nil and not p.purchased and p.remaining > 0
end

local function broadcastState(p)
	v = p

	for _, v4 in updateButtons do
		v4(p)
	end

	if v2 then
		v2(p)
	end

	local v4

	if p == nil then
		v4 = false
	else
		v4 = not p.purchased and p.remaining > 0
	end

	if not v4 and v3 then
		ConfirmDialogController.Complete(v3)
		v3 = nil
	end
end

local function popBallToInventory()
	local v4 = Config.reward.byCnId["新手礼包"]

	if not v4 then
		return
	end

	for _, v5 in v4 do
		if v5.itemType ~= "小球" then
			continue
		end

		local v6 = Config.ball.byCnId[v5.itemId]

		if not v6 then
			break
		end

		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.BackgroundTransparency = 1
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Position = UDim2.fromScale(0.5, 0.5)
		imageLabel.Size = UDim2.fromOffset(120, 120)
		imageLabel.Image = v6.image
		imageLabel.Parent = playerGui
		ClaimQueue.flyToInventory(imageLabel)
		imageLabel:Destroy()
		break
	end
end

function StarterPackOffer.open()
	if not v3 then
		local v4 = v
		local v5

		if v4 == nil then
			v5 = false
		else
			v5 = not v4.purchased and v4.remaining > 0
		end

		if v5 then
			v3 = ConfirmDialogController.Enqueue("24H新手礼包面板", {
				category = "StarterPackOffer",
				onShown = function(instance, callback)
					local v6 = instance:WaitForChild("倒计时")
					local v7 = instance:WaitForChild("购买按钮")
					local v8 = v7:WaitForChild("价格")
					local v9 = instance:WaitForChild("关闭按钮")
					local starterPack = DevProductService.products.byProductKey["Starter Pack"]
					v8.Text = DevProductService.robuxEmoji .. tostring(starterPack and starterPack.PriceInRobux or "?")

					-- equivalent calls inferred from this helper; original call sites unknown
					local function updatePanel(p)
						v6.Text = "Remaining Time: " .. NumberFormat.toLongRemainingTime(p.remaining)
					end

					if v then
						updatePanel(v) -- equivalent call inferred; original call site unknown
					end

					v2 = updatePanel
					local flag2 = false
					local connection = nil
					local connection2 = nil

					local function finish()
						if flag2 then
							return
						end

						flag2 = true

						if connection then
							connection:Disconnect()
						end

						if connection2 then
							connection2:Disconnect()
						end

						v2 = nil
						v3 = nil
						callback()
					end

					connection = ConfirmDialogController.BindButton(v7, "A", function()
						DevProductService.client.promptPurchase("Starter Pack")
					end)
					connection2 = ConfirmDialogController.BindButton(v9, "B", finish)
				end
			})
		end
	end
end

function StarterPackOffer:bindEntryButton(callback)
	local v4 = self:WaitForChild("价格")
	local v5 = self:WaitForChild("倒计时")
	local starterPack = DevProductService.products.byProductKey["Starter Pack"]
	v4.Text = DevProductService.robuxEmoji .. tostring(starterPack and starterPack.PriceInRobux or "?")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateButton(p)
		local visible

		if p == nil then
			visible = false
		else
			visible = not p.purchased and p.remaining > 0
		end

		self.Visible = visible

		if visible then
			v5.Text = NumberFormat.toLongRemainingTime(p.remaining)
		end
	end

	table.insert(updateButtons, updateButton)

	if v then
		updateButton(v) -- equivalent call inferred; original call site unknown
	else
		self.Visible = false
	end

	ButtonActions.Bind(self, function()
		if callback then
			callback()
		end

		StarterPackOffer.open()
	end)
end

function StarterPackOffer.Init()
	if flag then
		return
	end

	flag = true
	ConfirmDialogController.Init()
	TimedPurchaseService.client.sync("starterPack", broadcastState)
	DevProductService.client.onPurchaseGranted("Starter Pack", popBallToInventory)
end

return StarterPackOffer