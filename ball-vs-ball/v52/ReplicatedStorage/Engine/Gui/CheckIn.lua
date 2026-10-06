local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Config = require(ReplicatedStorage.Engine.Service.Config)
local CheckInService = require(ReplicatedStorage.Engine.Service.CheckInService)
local Currency = require(ReplicatedStorage.Engine.Gui.Currency)
local ClaimQueue = require(ReplicatedStorage.Engine.Gui.ClaimQueue)
local RewardRollQueue = require(ReplicatedStorage.Engine.Gui.RewardRollQueue)
local GameFlags = require(ReplicatedStorage.GameFlags)
local TopbarPlus = require(ReplicatedStorage.Packages.TopbarPlus)
local UnifiedPanel = require(ReplicatedStorage.Engine.Service.GamepadSupport.UnifiedPanel)
local RewardAutoOpenQueue = require(ReplicatedStorage.Engine.Gui.RewardAutoOpenQueue)
local RewardBadge = require(ReplicatedStorage.Engine.Gui.RewardsMenu.RewardBadge)
local v = nil
local flag = false

local function fn() end

local function fn2() end

-- equivalent calls inferred from this helper; original call sites unknown
local function isValidImageValue(image)
	return typeof(image) == "string" and image ~= "" and string.match(image, "^%a+://") ~= nil
end

local function getReward(p: string?)
	if not p then
		return nil, nil
	end

	local v2 = Config.reward.byCnId[p]
	local v3 = v2 and v2[1]

	if v3 then
		return v3, v3.assetCnId and Config.asset.byCnId[v3.assetCnId]
	end

	return nil, nil
end

local function getRatingColor(rating)
	if typeof(rating) ~= "number" then
		return nil
	end

	for _, v2 in Config.rating.list do
		if v2.lvl ~= rating then
			continue
		end

		local success, result = pcall(Color3.fromHex, v2.colorHex)

		if success then
			return result
		end

		return nil
	end

	return nil
end

local function findRewardCnId(items, p: number)
	for _, item in items do
		if item.dayIndex == p then
			return item.rewardCnId
		end
	end

	return nil
end

local function getRewardDisplayText(p, p2)
	if not p then
		return ""
	end

	if not p2 or typeof(p2.txt) ~= "string" then
		return p.itemId
	end

	local success, result = pcall(string.format, p2.txt, p.count)

	if success then
		return result
	end

	return p2.txt
end

local function scaleUDim2(udim: UDim2, p: number)
	return UDim2.new(udim.X.Scale * p, udim.X.Offset * p, udim.Y.Scale * p, udim.Y.Offset * p)
end

local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)

local function setupButtonFeedback(data)
	local size = data.Size
	data.MouseEnter:Connect(function()
		local size2 = size
		TweenService:Create(data, TweenInfo.new(0.1), {
			Size = UDim2.new(size2.X.Scale * 1.05, size2.X.Offset * 1.05, size2.Y.Scale * 1.05, size2.Y.Offset * 1.05)
		}):Play()
	end)
	data.MouseLeave:Connect(function()
		TweenService:Create(data, TweenInfo.new(0.1), {
			Size = size
		}):Play()
	end)
end

local CheckIn = {
	SetTopbarEnabled = function(flag2: boolean)
		if not flag2 then
			fn2()
		end

		if v then
			v:setEnabled(flag2)
		end
	end
}

local function ensureIcon()
	if v then
		return v
	end

	if GameFlags.feature["每日签到"] ~= true then
		return nil
	end

	v = TopbarPlus.new()
	v:setImage(Config.misc.newbieCheckInIcon):setImageScale(0.8)
	v:setLabel("Daily Rewards")
	v:bindEvent("selected", function()
		fn()
	end)
	v:bindEvent("deselected", function()
		fn2()
	end)
	return v
end

function CheckIn.GetIcon()
	return (ensureIcon())
end

function CheckIn.Init()
	if GameFlags.feature["每日签到"] ~= true then
		RewardAutoOpenQueue.ResolveInitial("CheckIn")
		return
	end

	local v2 = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("每日签到"):WaitForChild("背景")
	local v3 = v2:WaitForChild("面板")
	local closeButton = v3:WaitForChild("关闭按钮")
	local v5 = v3:WaitForChild("签到进度")
	local v6 = v5:WaitForChild("进度文字")
	local v7 = v3:WaitForChild("奖励区域")
	local v8 = {}
	local colors = {}
	local v9 = {}

	for i = 1, 7 do
		v8[i] = v7:WaitForChild("第" .. i .. "天")
		local uIGradient = v8[i]:FindFirstChild("背景渐变")

		if uIGradient and uIGradient:IsA("UIGradient") then
			colors[i] = uIGradient.Color
		end

		v9[i] = v5:WaitForChild("第" .. i .. "格")
	end

	local size = v3.Size
	v2.Visible = false
	local v10 = UnifiedPanel.new(v2, {
		closeButton = closeButton,
		isOpen = function()
			return flag
		end
	})

	fn = function()
		if flag then
			return false
		end

		flag = true
		v2.Visible = true
		v3.Size = UDim2.new(0, 0, 0, 0)
		TweenService:Create(v3, tweenInfo, {
			Size = size
		}):Play()

		if v then
			v:select()
		end

		v10:Refresh()
		return true
	end

	fn2 = function()
		if not flag then
			return
		end

		flag = false
		TweenService:Create(v3, tweenInfo2, {
			Size = UDim2.new(0, 0, 0, 0)
		}):Play()
		task.delay(tweenInfo2.Time, function()
			if not flag then
				v2.Visible = false
			end
		end)

		if v then
			v:deselect()
		end

		v10:Refresh()
		RewardAutoOpenQueue.Finish("CheckIn")
	end

	local v11 = {}
	local v12 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateNotice()
		local count = 0

		for _, v13 in v11 do
			if v13.status == "claimable" then
				count += 1
			end
		end

		if v then
			RewardBadge.Set("dailyCheckIn", v, count)
		end
	end

	local function render()
		local statusesByDayIndex = {}
		local rewardCnIdsByDayIndex = {}
		local dayIndex = nil
		local count = 0

		for _, v13 in v11 do
			statusesByDayIndex[v13.dayIndex] = v13.status
			rewardCnIdsByDayIndex[v13.dayIndex] = v13.rewardCnId

			if v13.status == "claimed" then
				count += 1
			end

			if v13.status ~= "locked" or dayIndex then
				continue
			end

			dayIndex = v13.dayIndex
		end

		v6.Text = `{count}/{7}`

		for i = 1, 7 do
			local waitForChild = v9[i]:WaitForChild("已完成填充")
			waitForChild.Visible = statusesByDayIndex[i] == "claimed"
		end

		for i = 1, 7 do
			local v13 = v8[i]
			local v14 = statusesByDayIndex[i] or "locked"
			local v15 = rewardCnIdsByDayIndex[i]
			local v16, v17

			if v15 then
				local v18 = Config.reward.byCnId[v15]
				v16 = v18 and v18[1]

				if v16 then
					v17 = v16.assetCnId and Config.asset.byCnId[v16.assetCnId]
				else
					v16 = nil
				end
			end

			local v18 = v13:WaitForChild("领取按钮")
			local v19 = v13:WaitForChild("未解锁")
			local v20 = v13:WaitForChild("明日解锁")
			local v21 = v13:WaitForChild("已领取")
			local firstChild = v13:FindFirstChild("奖励名称")
			local firstChild2 = v13:FindFirstChild("奖励图片")

			if firstChild then
				local result

				if v16 then
					if v17 and typeof(v17.txt) == "string" then
						local success
						success, result = pcall(string.format, v17.txt, v16.count)

						if not success then
							result = v17.txt
						end
					else
						result = v16.itemId
					end
				else
					result = ""
				end

				firstChild.Text = result
			end

			if firstChild2 and v17 then
				-- equivalent call inferred; original call site unknown
				if isValidImageValue(v17.image) then
					firstChild2.Image = v17.image
				end
			end

			local ratingColor = getRatingColor(v16 and v16.rating)

			if ratingColor then
				local firstChild3 = v13:FindFirstChild("背景渐变")
				local firstChild4 = v13:FindFirstChild("边框")
				local v22 = colors[i]

				if firstChild3 and v22 then
					local HSV = ratingColor:ToHSV()
					local colorSequenceKeypoints = {}

					for _, keypoint in v22.Keypoints do
						local _, v23, v24 = keypoint.Value:ToHSV()
						table.insert(
							colorSequenceKeypoints,
							ColorSequenceKeypoint.new(keypoint.Time, Color3.fromHSV(HSV, v23, v24))
						)
					end

					firstChild3.Color = ColorSequence.new(colorSequenceKeypoints)
				end

				if firstChild4 then
					firstChild4.Color = ratingColor
				end
			end

			local visible

			if v14 == "locked" then
				visible = i == dayIndex
			else
				visible = false
			end

			v19.Visible = v14 == "locked" and not visible
			v20.Visible = visible
			v21.Visible = v14 == "claimed"
			v18.Visible = v14 == "claimable"
			v18.Active = v14 == "claimable"
			v18.Interactable = v14 == "claimable"
			v18.Selectable = v14 == "claimable"
			v18.AutoButtonColor = v14 == "claimable"

			if v12[v18] then
				continue
			end

			v12[v18] = true
			setupButtonFeedback(v18)
			local v24 = i
			local v25 = v18
			local v26 = firstChild2
			v10:Bind(v18, function()
				local v27 = v24
				local flag2 = true
				local rewardCnId

				for k, v28 in v11 do
					if v28.dayIndex ~= v27 then
						continue
					end

					rewardCnId = v28.rewardCnId
					flag2 = false
					break
				end

				if flag2 then
					rewardCnId = nil
				end

				local v28

				if rewardCnId then
					local v29 = Config.reward.byCnId[rewardCnId]
					v28 = v29 and v29[1]

					if v28 then
						if v28.assetCnId then
							local v30 = Config.asset.byCnId[v28.assetCnId]
						end
					else
						v28 = nil
					end
				end

				if v28 and v28.itemType == "货币" then
					Currency.registerFlightSource("reward", `每日签到-{v24}`, v25)
				end

				local success, result = pcall(function()
					return CheckInService.client.claim(v24)
				end)

				if not success then
					warn((`[CheckIn] 领取请求出错：day={v24}，error={result}`))
				elseif typeof(result) == "table" and result.ok == true then
					if v28 and v28.itemType == "小球" and v26 then
						ClaimQueue.flyToInventory(v26)
					elseif v28 and v28.itemType == "箱子" then
						local v29

						if typeof(result.results) == "table" then
							v29 = result.results[1]
						else
							v29 = false
						end

						if v29 then
							RewardRollQueue.enqueue(v29, v28.itemId, "dailyCheckIn")
						end
					end
				else
					if typeof(result) == "table" then
						result = result.reason
					end

					warn((`[CheckIn] 领取被拒绝：day={v24}，reason={result}`))
				end
			end, i, v14 == "claimable")
		end

		v10:Refresh()
		updateNotice() -- equivalent call inferred; original call site unknown
	end

	v10:Bind(closeButton, fn2, 100)
	ensureIcon()
	v11 = CheckInService.client.getState()
	render()
	local v13 = false

	for _, v15 in v11 do
		if v15.status ~= "claimable" then
			continue
		end

		v13 = true
		break
	end

	local v15 = RunService:IsStudio() and GameFlags.studioOnly["跳过每日签到"] == true

	if v13 and not v15 then
		RewardAutoOpenQueue.ResolveInitial("CheckIn", function()
			return fn()
		end)
	else
		RewardAutoOpenQueue.ResolveInitial("CheckIn")
	end

	CheckInService.client.onStateChanged(function(p)
		v11 = p
		render()
	end)
end

return CheckIn