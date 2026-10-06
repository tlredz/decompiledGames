local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local NumberFormat = require(ReplicatedStorage.Packages.NumberFormat)
local Net = require(ReplicatedStorage.Packages.Net)
local Config = require(ReplicatedStorage.Engine.Service.Config)
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local Currency = require(ReplicatedStorage.Engine.Gui.Currency)
local remoteFunction = Net:RemoteFunction("DailyQuestClaim")

local function getDayKey()
	return (math.floor(workspace:GetServerTimeNow() / 86400))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSecondsToNextReset()
	local serverTimeNow = workspace:GetServerTimeNow()
	return (math.max(0, (math.ceil((math.floor(serverTimeNow / 86400) + 1) * 86400 - serverTimeNow))))
end

local function scaleUDim2(udim: UDim2, p: number)
	return UDim2.new(udim.X.Scale * p, udim.X.Offset * p, udim.Y.Scale * p, udim.Y.Offset * p)
end

local function setupClaimButtonFeedback(data)
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

return {
	Init = function()
		local v = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("右侧菜单")
		local v2 = v:WaitForChild("右侧区域"):WaitForChild("每日任务")
		local v3 = v2:WaitForChild("倒计时")
		local scrollingFrame = v2:WaitForChild("ScrollingFrame")
		local backgroundColor3 = scrollingFrame:WaitForChild("1"):WaitForChild("领取按钮").BackgroundColor3
		local backgroundColor32 = scrollingFrame:WaitForChild("2"):WaitForChild("领取按钮").BackgroundColor3
		local _1 = scrollingFrame:WaitForChild("1")
		local v4 = {}

		local function getSlot(layoutOrder: number)
			local frame = scrollingFrame:FindFirstChild((tostring(layoutOrder)))

			if frame and frame:IsA("Frame") then
				return frame
			end

			local clone = _1:Clone()
			clone.Name = tostring(layoutOrder)
			clone.LayoutOrder = layoutOrder
			clone.Parent = scrollingFrame
			return clone
		end

		local function render()
			local dailyQuest = client.dailyQuest()
			local v5

			if typeof(dailyQuest.dayKey) == "number" then
				v5 = dailyQuest.dayKey >= math.floor(workspace:GetServerTimeNow() / 86400)
			else
				v5 = false
			end

			local v6 = (not v5 or typeof(dailyQuest.progress) ~= "table") and {} or dailyQuest.progress
			local v7 = (not v5 or typeof(dailyQuest.claimed) ~= "table") and {} or dailyQuest.claimed

			for i, v8 in ipairs(Config.dailyQuest.list) do
				local clone = scrollingFrame:FindFirstChild((tostring(i)))

				if not (clone and clone:IsA("Frame")) then
					clone = _1:Clone()
					clone.Name = tostring(i)
					clone.LayoutOrder = i
					clone.Parent = scrollingFrame
				end

				clone.Visible = true
				local v9 = math.min(v6[v8.cnId] or 0, v8.requireCount)
				local v10 = v7[v8.cnId] == true
				local v11 = not v10 and v8.requireCount <= v9
				local v12 = clone:WaitForChild("领取按钮")
				local text = v12:WaitForChild("text")
				local waitForChild = clone:WaitForChild("文本")
				waitForChild.Text = v8.desc
				local waitForChild_2 = clone:WaitForChild("进度")
				waitForChild_2.Text = string.format(
					"%s/%s",
					NumberFormat.commaFormat(v9),
					NumberFormat.commaFormat(v8.requireCount)
				)
				local waitForChild_3 = clone:WaitForChild("数量")
				waitForChild_3.Text = "X" .. NumberFormat.commaFormat(v8.rewardCoins)
				text.Text = v10 and "Claimed" or v11 and "Claim" or "Undone"
				local backgroundColor

				if v11 then
					backgroundColor = backgroundColor3
				else
					backgroundColor = backgroundColor32
				end

				v12.BackgroundColor3 = backgroundColor
				v12.Active = true
				v12.AutoButtonColor = true
				v12:SetAttribute("QuestCnId", v8.cnId)

				if v4[v12] then
					continue
				end

				v4[v12] = true
				setupClaimButtonFeedback(v12)
				local v14 = v12
				ButtonActions.Bind(v12, function()
					local questCnId = v14:GetAttribute("QuestCnId")

					if typeof(questCnId) ~= "string" then
						return
					end

					Currency.registerFlightSource("dailyQuest", questCnId, v14)
					local success, result = pcall(function()
						return remoteFunction:InvokeServer(questCnId)
					end)

					if not success then
						warn((`[DailyQuest] 领取请求出错：cnId={questCnId}，error={result}`))
					elseif typeof(result) ~= "table" or result.ok ~= true then
						if typeof(result) == "table" then
							result = result.reason
						end

						warn((`[DailyQuest] 领取被拒绝：cnId={questCnId}，reason={result}`))
					end
				end)
			end

			for i = #Config.dailyQuest.list + 1, 99 do
				local child = scrollingFrame:FindFirstChild((tostring(i)))

				if not child then
					break
				end

				child.Visible = false
			end
		end

		client.dailyQuest.Changed(render)
		render()
		task.spawn(function()
			while v.Parent do
				v3.Text = "Daily Quests (" .. NumberFormat.toLongRemainingTime(getSecondsToNextReset()) .. ")"
				task.wait(1)
			end
		end)
	end
}