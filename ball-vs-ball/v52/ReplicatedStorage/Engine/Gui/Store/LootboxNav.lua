local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Config = require(ReplicatedStorage.Engine.Service.Config)
local GachaService = require(ReplicatedStorage.Engine.Service.GachaService)
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local DiamondTopUpService = require(ReplicatedStorage.Engine.Service.DiamondTopUpService)
local RewardRollQueue = require(script.Parent.Parent.RewardRollQueue)
local ConfirmDialogController = require(script.Parent.Parent.ConfirmDialogController)
local PoolDisplay = require(script.PoolDisplay)
local GachaPool = require(ReplicatedStorage.Engine.Service.GachaPool)
local v = {
	["小球"] = {
		coins = "金币小球箱子",
		diamonds = "钻石小球箱子"
	},
	["爆炸特效"] = {
		coins = "金币爆炸宝箱",
		diamonds = "钻石爆炸宝箱"
	},
	["飞行器"] = {
		coins = "金币飞行器宝箱",
		diamonds = "钻石飞行器宝箱"
	}
}

local function stripCountSuffix(value: string)
	return (value:gsub("%s*[xX]%d+$", ""))
end

local function active(parent)
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

local function choices(p)
	local result = {}

	for _, v2 in Config.crate.list do
		if not (v2.isForSale and v2.gachaCnId == p) then
			continue
		end

		local drawCount = v2.drawCount or 1

		if not (drawCount == 1 or drawCount == 10 or drawCount == 100) then
			continue
		end

		for _, v3 in { "coins", "diamonds" } do
			local v4 = v2[v3 .. "Price"]

			if typeof(v4) == "number" and v4 > 0 then
				result[v3 .. drawCount] = v2
			end
		end
	end

	return result
end

return {
	Init = function(instance)
		local v2 = instance:WaitForChild("通用宝箱抽奖页面")
		local v3 = instance:WaitForChild("查看全部页面")
		local v4 = v3:WaitForChild("奖池")
		local template = PoolDisplay.template(v4)
		local v5 = {}
		local v6 = nil
		local v7 = v2
		local count = 0
		local v8 = {}
		local v9 = {}

		local function refreshButtons()
			for _, v10 in v9 do
				local choices2 = v10.getChoices()
				local visible = choices2.coins100 ~= nil or choices2.diamonds100 ~= nil

				if not visible then
					v10.advanced = false
				end

				if not v10.arrow then
					continue
				end

				v10.arrow.Visible = visible
				v10.arrow["箭头"].Text = v10.advanced and "<" or ">"
			end

			for _, v10 in v8 do
				local crate = v10.getCrate()
				v10.button.Visible = crate ~= nil

				if not crate then
					continue
				end

				local v11 = crate[v10.currency .. "Price"]
				v10.price.Text = tostring(v11)
				v10.button["次数"].Text = "Open " .. tostring(crate.drawCount or 1)
				local button = v10.button
				local backgroundColor

				if v11 <= client[v10.currency]() then
					backgroundColor = v10.color
				else
					backgroundColor = v10.gray
				end

				button.BackgroundColor3 = backgroundColor
				local firstChild = v10.button:FindFirstChild("折扣")

				if not firstChild then
					continue
				end

				local single = v10.getSingle()
				local v13

				if single then
					v13 = single[v10.currency .. "Price"] * (crate.drawCount or 1) or v11
				else
					v13 = v11
				end

				local v14 = not (v13 > 0) and 0 or 1 - v11 / v13
				firstChild.Visible = v14 > 0.0001
				firstChild.Text = string.format("%d%% OFF", (math.floor(v14 * 100 + 0.5)))
			end
		end

		local function denied(state)
			if state.shaking then
				return
			end

			state.shaking = true
			local button = state.button
			local position = button.Position
			local backgroundColor3 = button.BackgroundColor3
			button.BackgroundColor3 = Color3.fromRGB(255, 76, 76)
			task.spawn(function()
				for _, v10 in {
					6,
					-6,
					6,
					0
				} do
					local tween = TweenService:Create(button, TweenInfo.new(0.06), {
						Position = position + UDim2.fromOffset(v10, 0)
					})
					tween:Play()
					tween.Completed:Wait()
				end

				button.Position = position
				button.BackgroundColor3 = backgroundColor3
				state.shaking = false
				refreshButtons()
			end)
		end

		local function bindButtons(instance2, fn)
			local v10 = instance2:WaitForChild("购买灰色状态")
			v10.Visible = false
			local v11 = {
				advanced = false,
				arrow = instance2:FindFirstChild("抽数切换按钮"),
				getChoices = fn
			}
			table.insert(v9, v11)

			if v11.arrow then
				v11.arrow:SetAttribute("StoreGamepadAction", true)
				ButtonActions.Bind(v11.arrow, function()
					if not v11.arrow.Visible then
						return
					end

					v11.advanced = not v11.advanced
					refreshButtons()
				end)
			end

			for _, currency in { "coins", "diamonds" } do
				local v13 = currency == "coins" and "金币" or "钻石"

				for _, v14 in { 1, 10 } do
					local child = instance2:FindFirstChild(v13 .. "抽" .. v14 .. "次")

					if not child then
						continue
					end

					child:SetAttribute("StoreGamepadAction", true)
					local v15 = v14
					local v16 = currency
					local v17 = currency
					local v18 = {
						button = child,
						currency = currency,
						color = child.BackgroundColor3,
						gray = v10.BackgroundColor3,
						price = child:WaitForChild("价格"),
						getCrate = function()
							local v19

							if v11.advanced then
								v19 = v15 == 1 and 10 or 100
							else
								v19 = v15
							end

							return fn()[v16 .. v19]
						end,
						getSingle = function()
							return fn()[v17 .. "1"]
						end
					}
					table.insert(v8, v18)
					local v20 = currency
					ButtonActions.Bind(child, function()
						local crate = v18.getCrate()

						if not crate then
							return
						end

						local v21 = count
						local success, result = pcall(GachaService.client.roll, crate.cnId, v20)

						if success and result and result.ok then
							local results = result.results or { result }
							RewardRollQueue.enqueue(results, crate.cnId, "store")

							if v21 ~= count or not active(instance2) then
								RewardRollQueue.skipCurrentSource("store")
							end
						elseif success and result and result.reason == "insufficient" then
							denied(v18)

							if v20 == "diamonds" then
								DiamondTopUpService.promptIfInsufficient(crate.diamondsPrice)
							end
						elseif not success or result and result.reason ~= "cooldown" then
							if success and result then
								result = result.reason
							end

							warn("[LootboxNav] 开箱失败: " .. tostring(result))
						end

						refreshButtons()
					end)
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function hidePage()
			count += 1
			RewardRollQueue.skipCurrentSource("store")
			v3.Visible = false
		end

		local renderPool

		renderPool = function(p)
			local v10 = count
			local entries, v11 = PoolDisplay.entries(p)
			PoolDisplay.grid(v4, template, entries, v11, function()
				if v10 == count then
					renderPool(p)
				end
			end)
			PoolDisplay.probability(v3["概率"], entries, v11)
			v3["数量"].Text = string.format("%d Items", #entries)
			v3["文字"].Text = "All Prizes  /  " .. PoolDisplay.tradeText(entries)
		end

		local function showPool(p, p2, p3, imageLabel)
			count += 1
			v7 = p2
			v6 = p
			v5 = choices(p)
			renderPool(p)
			v3["宝箱图标"].ImageLabel.Image = imageLabel.Image
			local firstChild = v3["宝箱图标"]:FindFirstChild("名称")

			if firstChild and firstChild:FindFirstChild("文字") then
				firstChild["文字"].Text = p3 and p3.name or "Crate"
			end

			refreshButtons()
			p2.Visible = false
			v3.Visible = true
		end

		bindButtons(v3, function()
			return v5
		end)
		local v10 = {
			coins = v2:WaitForChild("金币宝箱抽奖页面"),
			diamonds = v2:WaitForChild("钻石宝箱抽奖页面")
		}
		local v11 = {
			coins = {},
			diamonds = {}
		}
		local v12 = {
			coins = nil,
			diamonds = nil
		}
		local openPools = {}
		local v13 = "小球"
		local v14 = {
			coins = nil,
			diamonds = nil
		}

		for _, v15 in { "coins", "diamonds" } do
			local v16 = v10[v15]
			local v17 = v15
			bindButtons(v16, function()
				return v11[v17]
			end)
			v16["查看全部"]:SetAttribute("StoreGamepadAction", true)
			local v19 = v15

			local function openPool()
				if not (active(v16) and v12[v19]) then
					return
				end

				local v20 = v11[v19]
				local v21 = v20[v19 .. "1"] or v20[v19 .. "10"]
				showPool(v12[v19], v2, v21, v16["宝箱图标"].ImageLabel)
			end

			openPools[v15] = openPool
			ButtonActions.Bind(v16["查看全部"], openPool)
		end

		local function refreshHome()
			v2["说明按钮"].Visible = v13 == "小球"
			local v15 = v[v13]
			local entries = {}
			local v16 = {}

			for _, v17 in { "coins", "diamonds" } do
				local entries2, v18 = PoolDisplay.entries(v15[v17])
				entries[v17] = entries2
				v16[v17] = v18
			end

			for _, v17 in { "coins", "diamonds" } do
				local v18 = v10[v17]
				local v19 = v15[v17]
				v12[v17] = v19
				local v20 = choices(v19)
				v11[v17] = v20
				local v21 = entries[v17]
				local v22 = v16[v17]
				local entries2 = PoolDisplay.newEntries(v21, entries[v17 == "coins" and "diamonds" or "coins"])
				PoolDisplay.probability(v18["概率"], v21, v22)

				if v14[v17] then
					v14[v17](v21, v22, entries2)
				else
					v14[v17] = PoolDisplay.preview(v18["奖池"], v21, v22, entries2, openPools[v17])
				end

				local tradeText = PoolDisplay.tradeText(v21)
				local firstChild = v18:FindFirstChild("可交易标记")

				if firstChild then
					firstChild.Visible = tradeText ~= "Not Tradable"
					local firstChild2 = firstChild:FindFirstChild("文字")

					if firstChild2 then
						firstChild2.Text = tradeText
					end
				end

				local v23 = v20[v17 .. "1"] or v20[v17 .. "10"]

				if v23 then
					v18["宝箱图标"].ImageLabel.Image = v23.image
					v18["宝箱名称"].Text = v23.name:gsub("%s*[xX]%d+$", "")
				else
					warn((`[LootboxNav] 品类 {v13} 的 {v19} 在 Config.crate 里没有可卖的箱子`))
				end
			end

			refreshButtons()
		end

		local function setItemType(p: string)
			if not v[p] then
				warn((`[LootboxNav] 未知的宝箱品类: {p}`))
				return
			end

			v13 = p
			refreshHome()
		end

		local function back()
			hidePage() -- equivalent call inferred; original call site unknown
			v7.Visible = true
		end

		v3["返回按钮"]:SetAttribute("StoreGamepadAction", true)
		ButtonActions.Bind(v3["返回按钮"], back)
		local flag = false
		local firstChild = v2:FindFirstChild("说明")

		if firstChild then
			firstChild.Visible = false
		end

		v2["说明按钮"]:SetAttribute("StoreGamepadAction", true)
		ButtonActions.Bind(v2["说明按钮"], function()
			if flag then
				return
			end

			flag = true
			ConfirmDialogController.Enqueue("小球规则面板", {
				category = "BallRules",
				onShown = function(p, callback)
					local connection = nil
					connection = ConfirmDialogController.BindButton(p["关闭按钮"], "B", function()
						connection:Disconnect()
						flag = false
						callback()
					end)
				end
			})
		end)
		local v15 = GachaPool.observeLocalUnlocks(function()
			refreshHome()

			if v3.Visible and v6 then
				renderPool(v6)
			end
		end)
		instance.Destroying:Connect(v15)
		client.coins.Changed(refreshButtons)
		client.diamonds.Changed(refreshButtons)
		refreshHome()
		v3.Visible = false
		return {
			hidePage = hidePage,
			back = back,
			setItemType = setItemType,
			showCrate = function(p, p2, p3)
				showPool(p.gachaCnId, p3, p, p2.ImageLabel)
			end
		}
	end
}