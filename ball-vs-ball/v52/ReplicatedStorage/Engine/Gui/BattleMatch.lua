local flag = false
return {
	Init = function()
		if flag then
			return
		end

		flag = true
		local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
		local TweenService = game:GetService("TweenService")
		local Players = game:GetService("Players")
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local Workspace = game:GetService("Workspace")
		local GuiService = game:GetService("GuiService")
		game:GetService("UserInputService")
		local GamepadSupport = require(ReplicatedStorage.Engine.Service.GamepadSupport)
		local packages = ReplicatedStorage:WaitForChild("Packages")
		local Net = require(packages:WaitForChild("Net"))
		local HpDisplayFreeze = require(ReplicatedStorage:WaitForChild("BattleDemo"):WaitForChild("HpDisplayFreeze"))
		local DuelBallBadge = require(ReplicatedStorage:WaitForChild("BattleDemo"):WaitForChild("DuelBallBadge"))
		local Config = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("Config"))
		local FriendInviteRewardService = require(ReplicatedStorage.Engine.Service.FriendInviteRewardService)
		local PlayerThumbnail = require(ReplicatedStorage.Engine.Service.PlayerThumbnail)
		local BallCardQuality = require(ReplicatedStorage.Engine.Service.BallCardQuality)
		local BallQualityTextStyle = require(ReplicatedStorage.Engine.Service.BallQualityTextStyle)

		local function getAssetTemplate(p: string, p2: string)
			local byCnId = Config.asset.byCnId

			if byCnId then
				local v = byCnId[p]

				if v and typeof(v.txt) == "string" then
					return v.txt
				end
			end

			if Config.asset and Config.asset.list then
				for _, v in ipairs(Config.asset.list) do
					if v.cnId == p and typeof(v.txt) == "string" then
						return v.txt
					end
				end
			end

			return p2
		end

		local assetTemplate = getAssetTemplate("调整发射方向", "SET LAUNCH DIRECTION %ds")
		local assetTemplate2 = getAssetTemplate("等待对手操作", "WAITING FOR OPPONENT - %ds")
		local assetTemplate3 = getAssetTemplate("本地显示等待对手", "等待玩家")
		local background = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("战斗匹配UI"):WaitForChild("Background")
		local v = background:WaitForChild("按钮容器")
		local v2 = v:WaitForChild("邀请按钮")
		local v3 = v:WaitForChild("离开按钮")
		local localPlayer = Players.LocalPlayer
		local v4 = background:WaitForChild("对战信息层")
		local v5 = background:WaitForChild("红方信息")
		local v6 = background:WaitForChild("蓝方信息")
		local v7 = v4:WaitForChild("时间文本")
		local offsets = {}

		for _, v8 in { v5, v6 } do
			offsets[v8] = v8.Position.Y.Offset
		end

		local function applyTopbarInset()
			local Y = GuiService:GetGuiInset().Y

			for _, v8 in { v5, v6 } do
				local position = v8.Position
				v8.Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, offsets[v8] + Y)
			end
		end

		GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(applyTopbarInset)
		applyTopbarInset()
		local v8 = {}

		local function setPlayerAvatar(instance, userId)
			local image = instance:FindFirstChild("头像")

			if not (image and image:IsA("ImageLabel")) then
				return
			end

			local v9 = typeof(userId) == "number" and userId or nil

			if v8[instance] == v9 then
				return
			end

			v8[instance] = v9
			image.Image = PlayerThumbnail.DefaultPlaceholder

			if not v9 then
				return
			end

			task.spawn(function()
				local async, image2 = PlayerThumbnail.fetchAsync(v9)

				if async and v8[instance] == v9 then
					image.Image = image2
				end
			end)
		end

		local function updatePlayerPanel(instance, data, value, p, visible)
			local label = instance:FindFirstChild("玩家名称")
			local label2 = instance:FindFirstChild("球种")
			local label3 = instance:FindFirstChild("生命")
			local userId = data and data.userId

			if label and label:IsA("TextLabel") then
				label.Text = data and (data.name or data.username or assetTemplate3) or assetTemplate3
			end

			local roleId = data and data.roleId

			if visible then
				if typeof(roleId) == "string" then
					visible = roleId ~= ""
				else
					visible = false
				end
			end

			if label2 and label2:IsA("TextLabel") then
				local v9 = visible and Config.ball and Config.ball.byCnId and Config.ball.byCnId[roleId]
				label2.Text = not visible and "" or v9 and v9.displayName or roleId or ""
				label2.Visible = visible

				if visible then
					BallQualityTextStyle.apply(label2, BallCardQuality.kind(data, v9))
				end
			end

			local image = instance:FindFirstChild("球图标")

			if image and image:IsA("ImageLabel") then
				local v9

				if typeof(userId) == "number" then
					v9 = userId
				end

				local killCount

				if data and typeof(data.killCount) == "number" then
					killCount = data.killCount
				end

				local v10

				if v9 then
					v10 = HpDisplayFreeze.resolveKills(v9, killCount, HpDisplayFreeze.isAnyFrozen(p))
				end

				local apply = DuelBallBadge.apply

				if not visible then
					roleId = nil
				end

				apply(image, roleId, v10)
			end

			if label3 and label3:IsA("TextLabel") then
				label3.Text = data and table.concat(table.create(math.max(0, value or 0), "❤"), " ") or ""
			end

			setPlayerAvatar(instance, userId)
		end

		local function seatActionBlocked()
			if GamepadSupport.IsBlocked() then
				return true
			end

			local playerGui = localPlayer:FindFirstChild("PlayerGui")

			if not playerGui then
				return true
			end

			for _, childName in { "通用确认框", "战斗3选1" } do
				local child = playerGui:FindFirstChild(childName)
				local v9 = child and child:FindFirstChild("背景")

				if child and child.Enabled and v9 and v9.Visible then
					return true
				end
			end

			return false
		end

		local GamepadPages = require(ReplicatedStorage.Engine.Service.GamepadSupport.GamepadPages)
		local ButtonHints = require(ReplicatedStorage.Engine.Service.GamepadSupport.ButtonHints)
		GamepadPages.Observe(v, {
			available = function()
				return not seatActionBlocked()
			end
		})
		ButtonHints.Shortcut(v2, "Y")
		ButtonHints.Shortcut(v3, "B")

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

			local function activate()
				if not GamepadSupport.CanActivate(data) or seatActionBlocked() then
					return
				end

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
			end

			ButtonActions.Bind(data, activate)
			return activate
		end

		setupButtonFeedback(v2, function()
			FriendInviteRewardService.client.promptNativeInvite()
		end)
		local remoteEvent = Net:RemoteEvent("DuelTableLeaveRequest")
		local count = 0
		setupButtonFeedback(v3, function()
			remoteEvent:FireServer()
		end)
		background.Visible = false
		local fn = nil
		HpDisplayFreeze.onUnfreeze(function()
			if fn then
				fn()
			end
		end)
		Net:RemoteEvent("DuelTableState").OnClientEvent:Connect(function(p)
			if type(p) ~= "table" then
				return
			end

			local tables = p.tables

			if type(tables) ~= "table" then
				return
			end

			local flag2 = false
			fn = nil
			v4.Visible = false
			v5.Visible = false
			v6.Visible = false
			v7.Visible = false
			count += 1
			local v9 = count

			for _, table2 in tables do
				if type(table2) ~= "table" then
					continue
				end

				local seats = table2.seats

				if type(seats) ~= "table" then
					continue
				end

				for _, seat in seats do
					if not (type(seat) == "table" and seat.userId == localPlayer.UserId) then
						continue
					end

					local players = table2.players or {}
					local hp = table2.hp or {}
					local userId = players.Blue and players.Blue.userId
					local userId2 = players.Yellow and players.Yellow.userId
					local v12 = {}

					for _, v13 in { userId, userId2 } do
						if typeof(v13) == "number" then
							table.insert(v12, v13)
						end
					end

					local function resolveHp(value, value2)
						if typeof(value) == "number" and typeof(value2) == "number" then
							return HpDisplayFreeze.resolve(value, value2)
						end

						return value2
					end

					local v17 = DuelBallBadge.shouldShowBall(table2.state)

					fn = function()
						local blue = players.Blue
						local v21 = userId
						local resolved = hp[tostring(userId)]

						if typeof(v21) == "number" and typeof(resolved) == "number" then
							resolved = HpDisplayFreeze.resolve(v21, resolved)
						end

						updatePlayerPanel(v5, blue, resolved, v12, v17)
						local yellow = players.Yellow
						local v24 = userId2
						local resolved2 = hp[tostring(userId2)]

						if typeof(v24) == "number" and typeof(resolved2) == "number" then
							resolved2 = HpDisplayFreeze.resolve(v24, resolved2)
						end

						updatePlayerPanel(v6, yellow, resolved2, v12, v17)
					end

					fn()
					v4.Visible = true
					local v19

					if typeof(table2.teamSize) == "number" then
						v19 = table2.teamSize > 1
					else
						v19 = false
					end

					v5.Visible = not v19
					v6.Visible = not v19

					if table2.state == "Waiting" or table2.state == "Countdown" then
						flag2 = true
					elseif table2.state == "Aiming" and typeof(table2.countdownEndsAt) == "number" then
						local countdownEndsAt = table2.countdownEndsAt
						v7.Visible = true
						task.spawn(function()
							while count == v9 do
								local v21 = math.max(0, (math.ceil(countdownEndsAt - Workspace:GetServerTimeNow())))
								local firstChild = v4:FindFirstChild("发射按钮")
								local v22

								if firstChild and firstChild:GetAttribute("AimLocked") == true then
									v22 = assetTemplate2
								else
									v22 = assetTemplate
								end

								v7.Text = string.format(v22, v21)

								if v21 <= 0 then
									break
								else
									task.wait(0.25)
								end
							end
						end)
					end

					break
				end

				if flag2 then
					break
				end
			end

			background.Visible = flag2 or v4.Visible
			v.Visible = flag2
		end)
		Net:RemoteEvent("DuelTableStateRequest"):FireServer()
	end
}