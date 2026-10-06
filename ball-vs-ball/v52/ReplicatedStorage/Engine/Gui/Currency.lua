local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local NumberFormat = require(ReplicatedStorage.Packages.NumberFormat)
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local CoinFx = require(script.CoinFx)
local BoostDisplay = require(script.BoostDisplay)
local CurrencyService = require(ReplicatedStorage.Engine.Service.CurrencyService)
local UIManager = require(script.Parent.UIManager)
local OnlineRewardConfig = require(ReplicatedStorage.Engine.Service.OnlineRewardConfig)
local v = {}
local Currency = {}

for _, v2 in OnlineRewardConfig.getTiers() do
	v[v2.rewardCnId] = true
end

local function setupButtonFeedback(data, fn)
	local size = data.Size
	data.MouseEnter:Connect(function()
		TweenService:Create(data, TweenInfo.new(0.1), {
			Size = UDim2.new(size.X.Scale * 1.05, 0, size.Y.Scale * 1.05, 0)
		}):Play()
	end)
	data.MouseLeave:Connect(function()
		TweenService:Create(data, TweenInfo.new(0.1), {
			Size = size
		}):Play()
	end)
	ButtonActions.Bind(data, function()
		TweenService:Create(data, TweenInfo.new(0.05), {
			Size = UDim2.new(size.X.Scale * 0.95, 0, size.Y.Scale * 0.95, 0)
		}):Play()
		task.delay(0.05, function()
			TweenService:Create(data, TweenInfo.new(0.1), {
				Size = size
			}):Play()
		end)

		if fn then
			fn()
		end
	end)
end

local v2 = {
	recharge = true,
	exchange = true,
	duelReward = true,
	duelLoserReward = true,
	dailyQuest = true,
	reward = true,
	boothSale = true
}

local function needsFlight(p)
	return p ~= nil and v2[p.type] == true
end

local v3 = {}

local function flightSourceKey(p: string, p2: string)
	return p .. ":" .. p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function consumeFlightSource(p)
	if not p or typeof(p.arg) ~= "string" then
		return nil
	end

	local v4 = p.type .. ":" .. p.arg
	local v5 = v3[v4]
	v3[v4] = nil
	return v5
end

local function bindCurrencyBar(instance, childName: string, p: number)
	local v4 = instance:WaitForChild(childName):WaitForChild("数值")
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = p
	v4.Text = NumberFormat.commaFormat(numberValue.Value)
	local v5 = nil
	local v6 = p
	local v7 = 0
	numberValue.Changed:Connect(function()
		v4.Text = NumberFormat.commaFormat((math.floor(numberValue.Value + 0.5)))
	end)

	local function scrollToTarget()
		if v5 then
			v5:Cancel()
		end

		local v8 = math.clamp(math.abs(v6 - numberValue.Value) / 400, 0.2, 0.8)
		v5 = TweenService:Create(numberValue, TweenInfo.new(v8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Value = v6
		})
		v5:Play()
	end

	local function onCurrencyChanged(p2: number, p3: number, p4)
		v6 = p3
		local v8

		if p4 == nil then
			v8 = false
		else
			v8 = v2[p4.type] == true
		end

		if v8 then
			v7 += 1
			local v9 = math.clamp(math.floor(p2 / 10 + 0.5), 1, 100)
			local v10 = consumeFlightSource(p4) -- equivalent call inferred; original call site unknown

			local function playFlight()
				local v11 = v10

				if v11 and not v11.Parent then
					v11 = nil
				end

				CoinFx.play(v9, childName, v4, nil, function()
					v7 -= 1

					if v7 == 0 then
						scrollToTarget()
					end
				end, v11)
			end

			if p4.type == "reward" and v[p4.arg] then
				local RewardNotification = require(script.Parent.RewardNotification)
				RewardNotification.EnqueueCurrencyEffect(playFlight)
			else
				if v10 and not v10.Parent then
					v10 = nil
				end

				CoinFx.play(v9, childName, v4, nil, function()
					v7 -= 1

					if v7 == 0 then
						scrollToTarget()
					end
				end, v10)
			end
		elseif v7 == 0 then
			scrollToTarget()
		end
	end

	return onCurrencyChanged
end

function Currency.registerFlightSource(p: string, p2: string, p3)
	local v4 = p .. ":" .. p2
	v3[v4] = p3
	task.delay(10, function()
		if v3[v4] == p3 then
			v3[v4] = nil
		end
	end)
end

function Currency.Init()
	local v4 = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("货币"):WaitForChild("货币栏")
	v4.Visible = true
	local v5 = v4:WaitForChild("金币"):WaitForChild("购买按钮")
	local v6 = v4:WaitForChild("钻石"):WaitForChild("购买按钮")
	setupButtonFeedback(v5, function()
		UIManager.Get("Store").OpenToSection("金币")
	end)
	setupButtonFeedback(v6, function()
		UIManager.Get("Store").OpenToSection("钻石")
	end)
	BoostDisplay.Init(v4)
	local v7 = bindCurrencyBar(v4, "金币", client.coins())
	local v8 = bindCurrencyBar(v4, "钻石", client.diamonds())
	local v9 = {
		[CurrencyService.ref.Coins] = v7,
		[CurrencyService.ref.Diamonds] = v8
	}
	CurrencyService.client.onChanged(function(p, p2, p3, p4)
		local v10 = v9[p]

		if v10 then
			v10(p2, p3, p4)
		end
	end)
end

return Currency