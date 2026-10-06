local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local service = ReplicatedStorage.Engine.Service
local Config = require(service.Config)
local PlayerData = require(service.PlayerData)
local client = PlayerData.client
local LevelRewardRules = require(service.LevelRewardRules)
local ExperienceService = require(service.ExperienceService)
local flag = false
return {
	Init = function()
		if flag then
			return
		end

		flag = true
		local localPlayer = Players.LocalPlayer
		local playerGui = localPlayer:WaitForChild("PlayerGui")
		local v = playerGui:WaitForChild("下方按钮区"):WaitForChild("区域"):WaitForChild("等级奖励框")
		local v2 = playerGui:WaitForChild("经验条"):WaitForChild("经验条框")
		local v3 = v2:WaitForChild("等级奖励按钮")
		local parent = v:WaitForChild("等级奖励按钮")
		local v5 = parent:WaitForChild("物品图片")
		local v6 = parent:FindFirstChildWhichIsA("UIScale")

		if not v6 then
			v6 = Instance.new("UIScale")
			v6.Name = "动效缩放"
			v6.Parent = parent
		end

		local scale = v6.Scale
		local v7 = false
		local count = 0
		local v8 = nil
		parent.AutoButtonColor = false

		local function animate(p, duration, p2)
			if v8 then
				v8:Cancel()
			end

			v8 = TweenService:Create(v6, TweenInfo.new(duration, p2, Enum.EasingDirection.Out), {
				Scale = scale * p
			})
			v8:Play()
		end

		parent.MouseEnter:Connect(function()
			v7 = true
			count += 1
			animate(1.06, 0.12, Enum.EasingStyle.Quad)
		end)
		parent.MouseLeave:Connect(function()
			v7 = false
			count += 1
			animate(1, 0.12, Enum.EasingStyle.Quad)
		end)
		v:GetPropertyChangedSignal("Visible"):Connect(function()
			if not v.Visible then
				v7 = false
				count += 1

				if v8 then
					v8:Cancel()
				end

				v6.Scale = scale
			end
		end)
		ButtonActions.Bind(parent, function()
			if v.Visible and localPlayer:GetAttribute("InDuelTable") ~= true then
				count += 1
				local v9 = count
				animate(0.9, 0.07, Enum.EasingStyle.Quad)
				task.delay(0.07, function()
					if count == v9 and v.Visible then
						animate(v7 and 1.06 or 1, 0.2, Enum.EasingStyle.Back)
					end
				end)
				local PlayerPanel = require(script.Parent.PlayerPanel)
				PlayerPanel.OpenSelf()
			end
		end)
		ButtonActions.Bind(v3, function()
			local PlayerPanel = require(script.Parent.PlayerPanel)
			PlayerPanel.OpenSelf()
		end)
		local v9 = v:WaitForChild("当前等级")
		local v10 = v3:WaitForChild("物品图片")
		local v11 = v3:WaitForChild("奖励条件"):WaitForChild("文字")
		local v12 = v3:WaitForChild("名字")
		local entries = LevelRewardRules.buildEntries(Config.lvl.list, Config.ball.byCnId, Config.reward.byCnId)

		local function render()
			local state = LevelRewardRules.normalizeState(client.levelRewards())
			local ownedUntradable = LevelRewardRules.ownedUntradable(client.items())
			local level = ExperienceService.getLevelInfo(client.exp.total()).level
			local v13 = nil

			for _, entry in entries do
				if not (level < entry.level) then
					continue
				end

				local level2 = tostring(entry.level)
				local describe = LevelRewardRules.describe(entry, state, Config)
				local v15

				if entry.rewardId then
					v15 = state.grantedRewards[level2] == nil
				else
					v15 = describe and not ownedUntradable[describe.cnId] and (#entry.pool == 1 or state.grantedRandom[level2] ~= describe.cnId)
				end

				if not (describe and v15) then
					continue
				end

				v13 = {
					level = entry.level,
					display = describe
				}
				break
			end

			local visible

			if v13 == nil then
				visible = false
			else
				visible = localPlayer:GetAttribute("InDuelTable") ~= true
			end

			v.Visible = visible
			v3.Visible = visible and v2.Visible

			if v13 then
				local text = "Lv " .. tostring(v13.level) .. " Reward"
				v9.Text = text
				v11.Text = text
				v5.Image = v13.display.image
				v10.Image = v13.display.image
				v12.Text = v13.display.name
			else
				v5.Image = ""
				v10.Image = ""
				v9.Text = ""
				v11.Text = ""
				v12.Text = ""
			end
		end

		client.levelRewards.Changed(render)
		client.exp.total.Changed(render)
		client.items.Changed(render)
		localPlayer:GetAttributeChangedSignal("InDuelTable"):Connect(render)
		v2:GetPropertyChangedSignal("Visible"):Connect(render)
		render()
	end
}