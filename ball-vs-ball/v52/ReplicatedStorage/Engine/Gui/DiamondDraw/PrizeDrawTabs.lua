local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local CurrencyService = require(ReplicatedStorage.Engine.Service.CurrencyService)

local function formatNumber(p: number)
	return (tostring((math.floor(p))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

return {
	Init = function(instance)
		local v = instance:WaitForChild("实物抽奖")
		local v2 = instance:WaitForChild("钻石奖池")
		local v3 = instance:WaitForChild("活动页签栏")
		v3.Visible = false
		local v4 = v:WaitForChild("内容区域")
		local v5 = v4:WaitForChild("当前页面")
		local v6 = v4:WaitForChild("历史页面")
		local v7 = v4:WaitForChild("页签栏")
		local v8 = instance:WaitForChild("玩家货币栏")
		local v9 = v8:WaitForChild("金币"):WaitForChild("数量")
		local v10 = v8:WaitForChild("钻石"):WaitForChild("数量")
		local v11 = v3:WaitForChild("实物抽奖页签")
		local v12 = v3:WaitForChild("钻石奖池页签")
		local color = v11:WaitForChild("渐变").Color
		local color2 = v12:WaitForChild("渐变").Color
		local color3 = v11:WaitForChild("描边").Color
		local color4 = v12:WaitForChild("描边").Color

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setSelected(instance2, isSelected: boolean)
			local v13 = instance2:WaitForChild("渐变")
			local color5

			if isSelected then
				color5 = color
			else
				color5 = color2
			end

			v13.Color = color5
			local v15 = instance2:WaitForChild("描边")
			local color6

			if isSelected then
				color6 = color3
			else
				color6 = color4
			end

			v15.Color = color6
			instance2:SetAttribute("IsSelected", isSelected)
		end

		local v13 = {
			SetActivity = function(_: string)
				v.Visible = false
				v2.Visible = true
				local v14 = v11
				local waitForChild = v14:WaitForChild("渐变")
				waitForChild.Color = color2
				local waitForChild_2 = v14:WaitForChild("描边")
				waitForChild_2.Color = color4
				v14:SetAttribute("IsSelected", false)
				local v15 = v12
				local waitForChild_3 = v15:WaitForChild("渐变")
				waitForChild_3.Color = color
				local waitForChild_4 = v15:WaitForChild("描边")
				waitForChild_4.Color = color3
				v15:SetAttribute("IsSelected", true)
			end
		}

		local function showHistory(visible: boolean)
			v5.Visible = not visible
			v6.Visible = visible
			setSelected(v7:WaitForChild("当前页签"), not visible) -- equivalent call inferred; original call site unknown
			setSelected(v7:WaitForChild("历史页签"), visible) -- equivalent call inferred; original call site unknown
			local waitForChild = v:WaitForChild("开奖信息栏")
			waitForChild.Visible = not visible
			v4.Size = UDim2.fromScale(0.748, visible and 1 or 0.878)
		end

		ButtonActions.Bind(v11, function()
			v13.SetActivity("raffle")
		end)
		ButtonActions.Bind(v12, function()
			v13.SetActivity("diamond")
		end)
		ButtonActions.Bind(v7:WaitForChild("当前页签"), function()
			showHistory(false)
		end)
		ButtonActions.Bind(v7:WaitForChild("历史页签"), function()
			showHistory(true)
		end)
		local v14 = v5:WaitForChild("本期奖品")
		local v15 = v5:WaitForChild("下期奖品")
		local v16 = {}

		for i = 1, 2 do
			local v17

			if i == 1 then
				v17 = v14
			else
				v17 = v15
			end

			local v18 = {}

			for i2 = 1, 3 do
				local child = v17:WaitForChild("奖品" .. i2)
				v18[i2] = {
					image = child:WaitForChild("奖品图片").Image,
					name = child:WaitForChild("奖品名称").Text
				}
			end

			v16[i] = v18
		end

		local v17 = v5:WaitForChild("奖券输入框")
		local v18 = v5:WaitForChild("参与按钮")

		for i = 1, 3 do
			local child = v:WaitForChild("活动列表"):WaitForChild("活动按钮" .. i)
			local v19 = i
			ButtonActions.Bind(child, function()
				setSelected(v["活动列表"]["活动按钮" .. 1], v19 == 1) -- equivalent call inferred; original call site unknown
				setSelected(v["活动列表"]["活动按钮" .. 2], v19 == 2) -- equivalent call inferred; original call site unknown
				setSelected(v["活动列表"]["活动按钮" .. 3], v19 == 3) -- equivalent call inferred; original call site unknown

				for i2 = 1, 3 do
					local v26 = v19 == 3 and 2 or 1
					local v27

					if v19 == 2 then
						v27 = i2 % 3 + 1
					else
						v27 = i2
					end

					local v28 = v16[v26][v27]
					local v29 = v14["奖品" .. i2]
					v29["奖品图片"].Image = v28.image
					v29["奖品名称"].Text = v28.name
				end

				v17.Text = ""
				v18["文字"].Text = "Join!"
				local waitForChild = v6:WaitForChild("开奖记录列表")
				waitForChild.CanvasPosition = Vector2.zero
			end)
		end

		ButtonActions.Bind(v18, function()
			local waitForChild = v18:WaitForChild("文字")
			waitForChild.Text = "Coming Soon"
		end)
		v9.Text = tostring((math.floor((client.coins())))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
		v10.Text = tostring((math.floor((client.diamonds())))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
			"^,",
			""
		)
		CurrencyService.client.onChanged(function(p, _, p2)
			if p == CurrencyService.ref.Coins then
				v9.Text = tostring((math.floor(p2))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
			elseif p == CurrencyService.ref.Diamonds then
				v10.Text = tostring((math.floor(p2))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
			end
		end)
		v13.SetActivity("diamond")
		showHistory(false)
		return v13
	end
}