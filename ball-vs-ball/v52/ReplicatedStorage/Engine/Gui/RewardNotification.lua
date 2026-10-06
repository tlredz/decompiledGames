local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Net = require(ReplicatedStorage.Packages.Net)
local Config = require(ReplicatedStorage.Engine.Service.Config)
local OnlineRewardConfig = require(ReplicatedStorage.Engine.Service.OnlineRewardConfig)
local BoostService = require(ReplicatedStorage.Engine.Service.BoostService)
local RewardRollQueue = require(script.Parent.RewardRollQueue)
local RewardNotification = {}
local v = true
local v2 = false
local flag = false
local v3 = nil
local v4 = nil
local v5 = {}
local v6 = {}

function RewardNotification.EnqueueCurrencyEffect(callback)
	table.insert(v6, callback)
end

local v7 = nil
local v8 = 0
local uDim = UDim2.fromScale(0.5, 0.035)
local v9 = nil

local function animate(p)
	if v9 then
		v9:Cancel()
	end

	if v4 then
		v9 = TweenService:Create(v4, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p)
		v9:Play()
	end
end

function RewardNotification.SetEnabled(flag2: boolean)
	v = flag2

	if not flag2 and v4 then
		if v9 then
			v9:Cancel()
		end

		v4.Visible = false
	end
end

function RewardNotification.SetSimulationActive(flag2: boolean)
	v2 = flag2

	if flag2 and v4 then
		if v9 then
			v9:Cancel()
		end

		v4.Visible = false
	end
end

function RewardNotification.Enqueue(title: string, text: string, value: string?, color: Color3?, roll)
	table.insert(v5, {
		title = title,
		text = text,
		image = value or "",
		color = color or Color3.fromRGB(255, 186, 48),
		roll = roll
	})
end

local function rewardText(data, p)
	if not p or typeof(p.txt) ~= "string" then
		return (tostring(data.itemId))
	end

	local count = data.count

	if data.itemType == "加成" then
		local _, v10 = BoostService.parseRewardArgs(data.extraArgs, data.count)
		count = math.floor((v10 or 0) / 60)
	end

	local success, result = pcall(string.format, p.txt, count)

	if success then
		return result
	end

	return p.txt
end

function RewardNotification.Init()
	if flag then
		return
	end

	flag = true
	v3 = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("奖励领取通知")
	v3.Enabled = true
	v4 = v3:WaitForChild("通知卡片")
	v4.Visible = false
	local v10 = v4:WaitForChild("领取标题")
	local v11 = v4:WaitForChild("奖励内容")
	local v12 = v4:WaitForChild("奖励图标")
	RunService.Heartbeat:Connect(function(dt)
		if not v4 or (not v or v2) then
			return
		end

		local v13 = table.remove(v6, 1)

		if v13 then
			v13()
		end

		if not v7 then
			v7 = table.remove(v5, 1)

			if not v7 then
				return
			end

			v8 = 5

			if v7.roll then
				RewardRollQueue.Init()
				RewardRollQueue.enqueue(v7.roll.results, v7.roll.crateCnId, "onlineReward")
			end

			v10.Text = v7.title
			v11.Text = v7.text
			v11.TextColor3 = v7.color
			v12.Image = v7.image
			v12.Visible = v7.image ~= ""
			v11.Position = UDim2.fromScale(v12.Visible and 0.315 or 0.21, 0.55)
		end

		if not v4.Visible then
			v4.Visible = true
			v4.Position = uDim - UDim2.fromOffset(0, 12)
			v4.GroupTransparency = 1
			animate({
				Position = uDim,
				GroupTransparency = 0
			})
		end

		v8 -= dt

		if v8 <= 0 then
			if v9 then
				v9:Cancel()
			end

			v4.Visible = false
			v7 = nil
		elseif v8 <= 0.4 and v4.GroupTransparency == 0 then
			animate({
				GroupTransparency = 1
			})
		end
	end)
	local GameFlags = require(ReplicatedStorage.GameFlags)

	if GameFlags.feature["在线奖励"] ~= true then
		return
	end

	task.spawn(function()
		local remoteFunction = Net:RemoteFunction("OnlineRewardNotifications")

		while v3 and v3.Parent do
			local success, result = pcall(function()
				return remoteFunction:InvokeServer()
			end)

			if success and typeof(result) == "table" then
				for _, v13 in result do
					local tier = OnlineRewardConfig.getTier(v13.index)

					if not tier then
						continue
					end

					local count = 0

					for _, v14 in Config.reward.byCnId[tier.rewardCnId] or { tier.reward } do
						local v15 = nil

						if v14.itemType == "小球" or v14.itemType == "皮肤" or v14.itemType == "箱子" then
							count += 1
							local results

							if typeof(v13.results) == "table" then
								results = v13.results[count]
							end

							if v14.itemType == "箱子" and typeof(results) == "table" then
								v15 = {
									results = results,
									crateCnId = v14.itemId
								}
							end
						end

						local v16 = Config.asset.byCnId[v14.assetCnId]
						local v17 = (not v16 or typeof(v16.image) ~= "string") and "" or v16.image
						local enqueue = RewardNotification.Enqueue
						local v18 = tostring(tier.minutes) .. " Mins Online Reward Claimed"
						local v19 = rewardText(v14, v16)
						local v20

						if v14.itemId == "钻石" then
							v20 = Color3.fromRGB(96, 211, 255)
						end

						enqueue(v18, v19, v17, v20, v15)
					end
				end
			elseif not success then
				warn("[RewardNotification] " .. tostring(result))
			end

			task.wait(1)
		end
	end)
end

return RewardNotification