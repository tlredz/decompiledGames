local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Config = require(ReplicatedStorage.Engine.Service.Config)
local OnlineRewardConfig = require(ReplicatedStorage.Engine.Service.OnlineRewardConfig)
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local RewardAutoOpenQueue = require(ReplicatedStorage.Engine.Gui.RewardAutoOpenQueue)
local RewardBadge = require(ReplicatedStorage.Engine.Gui.RewardsMenu.RewardBadge)
local Currency = require(ReplicatedStorage.Engine.Gui.Currency)
local BoostDisplay = require(ReplicatedStorage.Engine.Gui.Currency.BoostDisplay)
local BoostService = require(ReplicatedStorage.Engine.Service.BoostService)
local RewardRollQueue = require(ReplicatedStorage.Engine.Gui.RewardRollQueue)
local ClaimQueue = require(ReplicatedStorage.Engine.Gui.ClaimQueue)
local UnifiedPanel = require(ReplicatedStorage.Engine.Service.GamepadSupport.UnifiedPanel)
local TopbarPlus = require(ReplicatedStorage.Packages.TopbarPlus)
local Net = require(ReplicatedStorage.Packages.Net)
local GameFlags = require(ReplicatedStorage.GameFlags)
local v = GameFlags.feature["在线奖励"] == true
local remoteFunction = Net:RemoteFunction("OnlineRewardClaim")
local v2 = nil
local flag = false
local v3 = true
local v4 = {}
local dayKey = nil

local function fn(_: boolean?) end

local function fn2() end

local function fn3() end

local OnlineReward = {
	SetTopbarEnabled = function(flag2: boolean)
		v3 = flag2

		if v2 then
			v2:setEnabled(flag2)
		end

		if flag2 then
			fn3()
		else
			fn2()
		end
	end
}

local function ensureIcon()
	if v2 then
		return v2
	end

	v2 = TopbarPlus.new()
	v2:setImage("rbxassetid://127726312818102"):setImageScale(0.8)
	v2:setLabel("Online Rewards")
	v2:bindEvent("selected", function()
		fn(false)
	end)
	v2:bindEvent("deselected", function()
		fn2()
	end)
	return v2
end

function OnlineReward.GetIcon()
	if v then
		return (ensureIcon())
	end

	return nil
end

local function ratingColor(rating)
	for _, v5 in Config.rating.list do
		if v5.lvl ~= rating then
			continue
		end

		local success, result = pcall(Color3.fromHex, v5.colorHex)

		if success then
			return result
		end
	end

	return nil
end

local function displayText(reward, asset)
	if not asset or typeof(asset.txt) ~= "string" then
		return (tostring(reward.itemId))
	end

	local count = reward.count

	if reward.itemType == "加成" then
		local _, v5 = BoostService.parseRewardArgs(reward.extraArgs, reward.count)
		count = math.floor((v5 or 0) / 60)
	end

	local success, result = pcall(string.format, asset.txt, count)

	if success then
		return result
	end

	return asset.txt
end

local function claimableCount(p)
	local count = 0

	for _, v5 in OnlineRewardConfig.getTiers() do
		if not (p.onlineSeconds >= v5.seconds) or p.claimed[tostring(v5.index)] then
			continue
		end

		count += 1
	end

	return count
end

local function hasNewClaimable(data)
	if data.dayKey ~= dayKey then
		return claimableCount(data) > 0
	end

	if typeof(data.claimed) ~= "table" then
		return false
	end

	for _, v5 in OnlineRewardConfig.getTiers() do
		local index = tostring(v5.index)

		if data.onlineSeconds >= v5.seconds and not (data.claimed[index] or v4[index]) then
			return true
		end
	end

	return false
end

local function markClaimableShown(data)
	if data.dayKey ~= dayKey then
		dayKey = data.dayKey
		table.clear(v4)
	end

	if typeof(data.claimed) ~= "table" then
		return
	end

	for _, v5 in OnlineRewardConfig.getTiers() do
		local index = tostring(v5.index)

		if not (data.onlineSeconds >= v5.seconds) or data.claimed[index] then
			continue
		end

		v4[index] = true
	end
end

function OnlineReward.Init()
	local v5 = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("在线奖励")

	if v then
		local v6 = v5:WaitForChild("背景")
		local v7 = v6:WaitForChild("面板")
		local v8 = v7:WaitForChild("奖励区域")
		local parent = v7:WaitForChild("在线进度条")
		local v10 = v7:WaitForChild("在线时长")
		local closeButton = v7:WaitForChild("关闭按钮")
		local tiers = OnlineRewardConfig.getTiers()
		local size = v7.Size
		local v12 = UnifiedPanel.new(v6, {
			closeButton = closeButton,
			isOpen = function()
				return flag
			end
		})
		local children = {}
		local children2 = {}
		local colors = {}
		local v13 = parent:FindFirstChild("在线填充")

		if not v13 then
			v13 = Instance.new("Frame")
			v13.Name = "在线填充"
			v13.BorderSizePixel = 0
			v13.BackgroundColor3 = Color3.fromRGB(78, 159, 246)
			v13.Size = UDim2.fromScale(0, 1)
			v13.ZIndex = parent.ZIndex + 1
			v13.Parent = parent
		end

		for i = 1, 5 do
			local child = v8:WaitForChild("奖励项" .. i)
			local child2 = parent:WaitForChild("进度节点" .. i)
			children[i] = child
			children2[i] = child2
			child.Visible = i <= #tiers
			child2.Visible = i <= #tiers
			local firstChild = child:FindFirstChild("背景渐变")

			if firstChild then
				colors[i] = firstChild.Color
			end

			if not (i <= #tiers) then
				continue
			end

			local tier = tiers[i]
			local count = #tiers
			local v14 = (1 - (count - 1) * 0.015) / count
			child.Position = UDim2.fromScale((i - 1) * (v14 + 0.015), 0)
			child.Size = UDim2.fromScale(v14, 1)
			local waitForChild = child:WaitForChild("时长")
			waitForChild.Text = tostring(tier.minutes) .. " min"
			local waitForChild_2 = child:WaitForChild("奖励名称")
			waitForChild_2.Text = displayText(tier.reward, tier.asset)
			local v15 = child:WaitForChild("奖励图片")

			if tier.asset and typeof(tier.asset.image) == "string" and string.match(tier.asset.image, "^%a+://") then
				v15.Image = tier.asset.image
			end

			local color = ratingColor(tier.reward.rating)

			if color then
				local firstChild2 = child:FindFirstChild("边框")

				if firstChild2 then
					firstChild2.Color = color
				end

				if firstChild and colors[i] then
					local HSV = color:ToHSV()
					local colorSequenceKeypoints = {}

					for _, keypoint in colors[i].Keypoints do
						local _, v17, v18 = keypoint.Value:ToHSV()
						table.insert(
							colorSequenceKeypoints,
							ColorSequenceKeypoint.new(keypoint.Time, Color3.fromHSV(HSV, v17, v18))
						)
					end

					firstChild.Color = ColorSequence.new(colorSequenceKeypoints)
				end
			end

			local v17 = child.Position.X.Scale + (0.5 - child.AnchorPoint.X) * child.Size.X.Scale
			local v18 = v8.Position.X.Scale - v8.AnchorPoint.X * v8.Size.X.Scale
			local v19 = parent.Position.X.Scale - parent.AnchorPoint.X * parent.Size.X.Scale
			local v20 = (v18 + v8.Size.X.Scale * v17 - v19) / parent.Size.X.Scale
			child2.Position = UDim2.fromScale(v20, 0.5)
			local v21 = child:WaitForChild("领取按钮")
			local v24 = i
			v12:Bind(v21, function()
				if tier.reward.itemType == "货币" then
					Currency.registerFlightSource("reward", tier.rewardCnId, v21)
				end

				local v26

				if tier.reward.itemType == "加成" then
					v26 = BoostDisplay.HoldReveal(tier.reward.itemId)
				end

				local success, result = pcall(function()
					return remoteFunction:InvokeServer(v24)
				end)

				if success and typeof(result) == "table" and result.ok == true then
					if v26 then
						v26(v15)
					elseif tier.reward.itemType == "小球" or tier.reward.itemType == "皮肤" then
						ClaimQueue.flyToInventory(v15)
					elseif tier.reward.itemType == "箱子" then
						local v27

						if typeof(result.results) == "table" then
							v27 = result.results[1]
						else
							v27 = false
						end

						if v27 then
							RewardRollQueue.enqueue(v27, tier.reward.itemId, "onlineReward")
						end
					end
				else
					if v26 then
						v26(nil)
					end

					if success and typeof(result) == "table" then
						result = result.reason
					end

					warn("[OnlineReward] 领取失败: " .. tostring(result))
				end
			end, i)
		end

		v6.Visible = false
		v12:Bind(closeButton, function()
			fn2()
		end)

		fn = function(_: boolean?)
			if flag or not v3 then
				return false
			end

			flag = true
			v6.Visible = true
			v7.Size = UDim2.fromScale(0, 0)
			TweenService:Create(v7, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = size
			}):Play()

			if v2 then
				v2:select()
			end

			v12:Refresh()
			local onlineReward = client.onlineReward()

			if typeof(onlineReward) == "table" then
				markClaimableShown(onlineReward)
			end

			return true
		end

		fn2 = function()
			if not flag then
				return
			end

			flag = false
			TweenService:Create(v7, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Size = UDim2.fromScale(0, 0)
			}):Play()
			task.delay(0.3, function()
				if not flag then
					v6.Visible = false
				end
			end)

			if v2 then
				v2:deselect()
			end

			v12:Refresh()
			RewardAutoOpenQueue.Finish("OnlineReward")
		end

		local function render()
			local onlineReward = client.onlineReward()

			if typeof(onlineReward) ~= "table" then
				return
			end

			onlineReward.claimed = typeof(onlineReward.claimed) ~= "table" and {} or onlineReward.claimed
			local v14 = typeof(onlineReward.onlineSeconds) ~= "number" and 0 or onlineReward.onlineSeconds
			v10.Text = string.format("%dm %02ds", v14 // 60, v14 % 60)
			local v15 = not (#tiers > 0) and 0 or tiers[1].seconds
			local v16 = not (#tiers > 0) and 0 or tiers[#tiers].seconds
			local v17 = 0

			if v16 > 0 then
				if v16 <= v14 then
					v17 = 1
				elseif v14 < v15 then
					v17 = children2[1].Position.X.Scale * math.clamp(v14 / v15, 0, 1)
				else
					for i = 2, #tiers do
						local seconds = tiers[i - 1].seconds
						local seconds2 = tiers[i].seconds

						if not (v14 < seconds2) then
							continue
						end

						local v18 = math.clamp((v14 - seconds) / math.max(seconds2 - seconds, 1), 0, 1)
						local scale = children2[i - 1].Position.X.Scale
						v17 = scale + (children2[i].Position.X.Scale - scale) * v18
						break
					end
				end
			end

			v13.Size = UDim2.fromScale(v17, 1)

			for k, tier in tiers do
				local v18 = children[k]
				local v19 = tostring(k)
				local visible = onlineReward.claimed[v19] == true
				local v21

				if tier.seconds <= v14 then
					v21 = not visible
				else
					v21 = false
				end

				local v22 = tier.seconds - v14
				local visible2 = not visible and not v21 and v22 > 0 and (k == 1 or tiers[k - 1].seconds <= v14)
				local waitForChild = v18:WaitForChild("已领取")
				waitForChild.Visible = visible
				local waitForChild_2 = v18:WaitForChild("未解锁")
				waitForChild_2.Visible = not (visible or v21 or visible2)
				local v25 = v18:WaitForChild("倒计时")
				v25.Visible = visible2

				if visible2 then
					local waitForChild_3 = v25:WaitForChild("状态文字")
					waitForChild_3.Text = string.format("%02d:%02d Left", v22 // 60, v22 % 60)
				end

				local v26 = v18:WaitForChild("领取按钮")
				v26.Visible = v21
				v26.Active = v21
				v26.Interactable = v21
				v26.Selectable = v21
				local v27 = children2[k]
				local color

				if visible then
					color = Color3.fromRGB(60, 225, 15)
				elseif tier.seconds <= v14 then
					color = Color3.fromRGB(78, 159, 246)
				else
					color = Color3.fromRGB(22, 35, 57)
				end

				v27.BackgroundColor3 = color
				local guiObject = v27:FindFirstChild("完成标记")

				if guiObject and guiObject:IsA("GuiObject") then
					guiObject.Visible = visible
				end
			end

			v12:Refresh()

			if flag then
				markClaimableShown(onlineReward)
			end

			RewardBadge.Set("onlineReward", ensureIcon(), (claimableCount(onlineReward)))
			fn3()
		end

		fn3 = function() end

		RewardAutoOpenQueue.ResolveInitial("OnlineReward", nil)
		ensureIcon()
		client.onlineReward.Changed(function()
			render()
		end)
		render()
	else
		v5.Enabled = false
		RewardAutoOpenQueue.ResolveInitial("OnlineReward", nil)
	end
end

return OnlineReward