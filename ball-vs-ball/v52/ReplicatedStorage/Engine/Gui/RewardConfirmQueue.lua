local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Net = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))
local remoteEvent = Net:RemoteEvent("NewbieBallDialogHandled")
local remoteEvent2 = Net:RemoteEvent("FirstRaceBallDialogHandled")
local PlayerThumbnail = require(ReplicatedStorage.Engine.Service.PlayerThumbnail)
local RewardRollQueue = require(script.Parent.RewardRollQueue)
local ConfirmDialogController = require(script.Parent.ConfirmDialogController)
local RewardConfirmQueue = {}
local v = {
	newbie = "新手小球面板",
	firstRace = "首次对战小球面板",
	group = "群组奖励小球面板",
	friendInvite = "邀请好友小球面板",
	friendInvitee = "被邀请小球面板",
	invitePrompt = "邀请好友面板"
}
TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.In)
TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local flag = false
local v2 = false
local flag2 = false
local v3 = false
local v4 = false

local function scaleUDim2(udim: UDim2, p: number)
	return UDim2.new(udim.X.Scale * p, udim.X.Offset * p, udim.Y.Scale * p, udim.Y.Offset * p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showRecord(p: string, data)
	ConfirmDialogController.Enqueue(p, {
		category = "RewardConfirm",
		onShown = function(instance, callback)
			local _ = instance.Size
			instance.Size = UDim2.new(0, 0, 0, 0)
			local v5 = instance:WaitForChild("确定按钮")
			local size = v5.Size
			v5.Active = true
			local mouseEnterConnection = v5.MouseEnter:Connect(function()
				local size2 = size
				TweenService:Create(v5, tweenInfo, {
					Size = UDim2.new(
						size2.X.Scale * 1.05,
						size2.X.Offset * 1.05,
						size2.Y.Scale * 1.05,
						size2.Y.Offset * 1.05
					)
				}):Play()
			end)
			local mouseLeaveConnection = v5.MouseLeave:Connect(function()
				TweenService:Create(v5, tweenInfo, {
					Size = size
				}):Play()
			end)
			local flag3 = false
			local connection = nil
			local connection2 = nil
			local v6

			if p == "邀请好友面板" then
				v6 = instance:WaitForChild("关闭按钮")
			else
				v6 = nil
			end

			if v6 then
				v6.Active = true
			end

			local function finish(flag4: boolean)
				if flag3 then
					return
				end

				flag3 = true
				connection:Disconnect()

				if connection2 then
					connection2:Disconnect()
				end

				mouseEnterConnection:Disconnect()
				mouseLeaveConnection:Disconnect()
				v5.Active = false

				if v6 then
					v6.Active = false
				end

				if p == "邀请好友面板" then
					flag2 = false
				end

				if flag4 then
					if data.source == "newbie" then
						remoteEvent:FireServer()
					elseif data.source == "firstRace" then
						remoteEvent2:FireServer()
					end

					if data.onConfirm then
						data.onConfirm()
					end

					if data.results and data.crateCnId and data.source then
						RewardRollQueue.enqueue(data.results, data.crateCnId, data.source)
					end
				end

				callback()
			end

			connection = ConfirmDialogController.BindButton(v5, "A", function()
				if p ~= "邀请好友面板" then
					finish(true)
				elseif data.onConfirm then
					data.onConfirm()
				end
			end)

			if v6 then
				connection2 = ConfirmDialogController.BindButton(v6, "B", function()
					if flag3 then
						return
					end

					flag3 = true
					connection:Disconnect()

					if connection2 then
						connection2:Disconnect()
					end

					mouseEnterConnection:Disconnect()
					mouseLeaveConnection:Disconnect()
					v5.Active = false

					if v6 then
						v6.Active = false
					end

					if p == v.invitePrompt then
						flag2 = false
					end

					callback()
				end)
			end
		end
	})
end

function RewardConfirmQueue.enqueue(results, crateCnId: string, source: string)
	local v5 = v[source]

	if typeof(crateCnId) ~= "string" or not v5 then
		warn("[RewardConfirmQueue] 确认框缺少箱子或预制面板")
		return
	end

	showRecord(v5, {
		results = results,
		crateCnId = crateCnId,
		source = source
	}) -- equivalent call inferred; original call site unknown
end

function RewardConfirmQueue.enqueueCoinLimitReached()
	if v4 or v3 then
		return
	end

	v3 = true
	local v5 = {
		onConfirm = function()
			v4 = true
			v3 = false
		end
	}
	local v7 = "金币上限面板"
	ConfirmDialogController.Enqueue("金币上限面板", {
		category = "RewardConfirm",
		onShown = function(self, callback)
			local _ = self.Size
			self.Size = UDim2.new(0, 0, 0, 0)
			local v8 = self:WaitForChild("确定按钮")
			local size = v8.Size
			v8.Active = true
			local mouseEnterConnection = v8.MouseEnter:Connect(function()
				local size2 = size
				TweenService:Create(v8, tweenInfo, {
					Size = UDim2.new(
						size2.X.Scale * 1.05,
						size2.X.Offset * 1.05,
						size2.Y.Scale * 1.05,
						size2.Y.Offset * 1.05
					)
				}):Play()
			end)
			local mouseLeaveConnection = v8.MouseLeave:Connect(function()
				TweenService:Create(v8, tweenInfo, {
					Size = size
				}):Play()
			end)
			local flag3 = false
			local connection = nil
			local connection2 = nil
			local v9

			if v7 == "邀请好友面板" then
				v9 = self:WaitForChild("关闭按钮")
			else
				v9 = nil
			end

			if v9 then
				v9.Active = true
			end

			local function finish(flag4: boolean)
				if flag3 then
					return
				end

				flag3 = true
				connection:Disconnect()

				if connection2 then
					connection2:Disconnect()
				end

				mouseEnterConnection:Disconnect()
				mouseLeaveConnection:Disconnect()
				v8.Active = false

				if v9 then
					v9.Active = false
				end

				if v7 == "邀请好友面板" then
					flag2 = false
				end

				if flag4 then
					if v5.source == "newbie" then
						remoteEvent:FireServer()
					elseif v5.source == "firstRace" then
						remoteEvent2:FireServer()
					end

					if v5.onConfirm then
						v5.onConfirm()
					end

					if v5.results and v5.crateCnId and v5.source then
						RewardRollQueue.enqueue(v5.results, v5.crateCnId, v5.source)
					end
				end

				callback()
			end

			connection = ConfirmDialogController.BindButton(v8, "A", function()
				if v7 ~= "邀请好友面板" then
					finish(true)
				elseif v5.onConfirm then
					v5.onConfirm()
				end
			end)

			if v9 then
				connection2 = ConfirmDialogController.BindButton(v9, "B", function()
					if flag3 then
						return
					end

					flag3 = true
					connection:Disconnect()

					if connection2 then
						connection2:Disconnect()
					end

					mouseEnterConnection:Disconnect()
					mouseLeaveConnection:Disconnect()
					v8.Active = false

					if v9 then
						v9.Active = false
					end

					if v7 == v.invitePrompt then
						flag2 = false
					end

					callback()
				end)
			end
		end
	})
end

function RewardConfirmQueue.enqueueInvitePrompt(onConfirm)
	if flag2 then
		return
	end

	flag2 = true
	local v5 = {
		onConfirm = onConfirm
	}
	local v7 = "邀请好友面板"
	ConfirmDialogController.Enqueue("邀请好友面板", {
		category = "RewardConfirm",
		onShown = function(self, callback)
			local _ = self.Size
			self.Size = UDim2.new(0, 0, 0, 0)
			local v8 = self:WaitForChild("确定按钮")
			local size = v8.Size
			v8.Active = true
			local mouseEnterConnection = v8.MouseEnter:Connect(function()
				local size2 = size
				TweenService:Create(v8, tweenInfo, {
					Size = UDim2.new(
						size2.X.Scale * 1.05,
						size2.X.Offset * 1.05,
						size2.Y.Scale * 1.05,
						size2.Y.Offset * 1.05
					)
				}):Play()
			end)
			local mouseLeaveConnection = v8.MouseLeave:Connect(function()
				TweenService:Create(v8, tweenInfo, {
					Size = size
				}):Play()
			end)
			local flag3 = false
			local connection = nil
			local connection2 = nil
			local v9

			if v7 == "邀请好友面板" then
				v9 = self:WaitForChild("关闭按钮")
			else
				v9 = nil
			end

			if v9 then
				v9.Active = true
			end

			local function finish(flag4: boolean)
				if flag3 then
					return
				end

				flag3 = true
				connection:Disconnect()

				if connection2 then
					connection2:Disconnect()
				end

				mouseEnterConnection:Disconnect()
				mouseLeaveConnection:Disconnect()
				v8.Active = false

				if v9 then
					v9.Active = false
				end

				if v7 == "邀请好友面板" then
					flag2 = false
				end

				if flag4 then
					if v5.source == "newbie" then
						remoteEvent:FireServer()
					elseif v5.source == "firstRace" then
						remoteEvent2:FireServer()
					end

					if v5.onConfirm then
						v5.onConfirm()
					end

					if v5.results and v5.crateCnId and v5.source then
						RewardRollQueue.enqueue(v5.results, v5.crateCnId, v5.source)
					end
				end

				callback()
			end

			connection = ConfirmDialogController.BindButton(v8, "A", function()
				if v7 ~= "邀请好友面板" then
					finish(true)
				elseif v5.onConfirm then
					v5.onConfirm()
				end
			end)

			if v9 then
				connection2 = ConfirmDialogController.BindButton(v9, "B", function()
					if flag3 then
						return
					end

					flag3 = true
					connection:Disconnect()

					if connection2 then
						connection2:Disconnect()
					end

					mouseEnterConnection:Disconnect()
					mouseLeaveConnection:Disconnect()
					v8.Active = false

					if v9 then
						v9.Active = false
					end

					if v7 == v.invitePrompt then
						flag2 = false
					end

					callback()
				end)
			end
		end
	})
end

function RewardConfirmQueue.SetSuppressed(flag3: boolean)
	v2 = flag3

	if flag then
		ConfirmDialogController.SetCategorySuppressed("RewardConfirm", v2)
	end
end

function RewardConfirmQueue.Init()
	if flag then
		return
	end

	flag = true
	ConfirmDialogController.Init()
	local v5 = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("通用确认框"):WaitForChild("背景"):WaitForChild("邀请好友面板"):WaitForChild("玩家头像")
	local _, image = PlayerThumbnail.fetchLocalPlayerAsync()
	v5.Image = image
	ConfirmDialogController.SetCategorySuppressed("RewardConfirm", v2)
end

return RewardConfirmQueue