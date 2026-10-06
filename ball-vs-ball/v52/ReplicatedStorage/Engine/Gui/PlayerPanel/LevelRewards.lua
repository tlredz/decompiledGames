local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local service = ReplicatedStorage.Engine.Service
local Config = require(service.Config)
local PlayerData = require(service.PlayerData)
local client = PlayerData.client
local LevelRewardRules = require(service.LevelRewardRules)
local ExperienceService = require(service.ExperienceService)
return {
	new = function(instance)
		local parent = instance:WaitForChild("等级奖励")
		local _1 = parent:WaitForChild("1")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setVisible(visible)
			instance.Visible = visible
		end

		local entries = LevelRewardRules.buildEntries(Config.lvl.list, Config.ball.byCnId, Config.reward.byCnId)
		local v2 = nil
		local clonesByLevel = {}
		local count = 0
		local v3 = nil

		for _, guiObject in parent:GetChildren() do
			if guiObject:IsA("GuiObject") and guiObject.Name ~= "填充" then
				guiObject.Visible = false
			end
		end

		setVisible(false) -- equivalent call inferred; original call site unknown

		local function render()
			if v2 ~= Players.LocalPlayer.UserId then
				setVisible(false) -- equivalent call inferred; original call site unknown
				return
			end

			local state = LevelRewardRules.normalizeState(client.levelRewards())
			local level = ExperienceService.getLevelInfo(client.exp.total()).level
			local count2 = 0
			local v4 = {}

			for _, entry in entries do
				local level2 = tostring(entry.level)
				local describe = LevelRewardRules.describe(entry, state, Config)

				if not describe then
					continue
				end

				count2 += 1
				local clone = clonesByLevel[level2]

				if not clone then
					clone = _1:Clone()
					clone.Name = "等级奖励_" .. level2
					clone.Parent = parent
					clonesByLevel[level2] = clone
				end

				v4[level2] = true
				clone.LayoutOrder = entry.level
				clone.Visible = true
				clone:SetAttribute("RewardLevel", entry.level)
				clone:SetAttribute("RewardBall", describe.cnId)
				clone:SetAttribute("RewardId", describe.rewardId)
				clone["等级"].Text = "Lv." .. level2
				clone["图片"].Image = describe.image
				clone["名称"].Text = describe.name
				local visible = entry.level <= level
				clone["线段"].Visible = not visible
				clone["线段完成样式"].Visible = visible
			end

			for k, v5 in clonesByLevel do
				if not v4[k] then
					v5.Visible = false
				end
			end

			setVisible(count2 > 0) -- equivalent call inferred; original call site unknown
		end

		client.levelRewards.Changed(render)
		client.items.Changed(render)
		client.exp.total.Changed(render)
		return {
			setViewedPlayer = function(p)
				count += 1

				if v3 then
					v3:Cancel()
					v3 = nil
				end

				v2 = p
				render()
				parent.CanvasPosition = Vector2.zero
			end,
			scrollToNextReward = function()
				count += 1

				if v3 then
					v3:Cancel()
					v3 = nil
				end

				local v4 = count
				task.delay(0.35, function()
					RunService.Heartbeat:Wait()

					if v4 ~= count or v2 ~= Players.LocalPlayer.UserId or not instance.Visible then
						return
					end

					local state = LevelRewardRules.normalizeState(client.levelRewards())
					local ownedUntradable = LevelRewardRules.ownedUntradable(client.items())
					local level = ExperienceService.getLevelInfo(client.exp.total()).level
					local v5 = nil
					local v6 = nil

					for _, entry in entries do
						local level2 = tostring(entry.level)
						local v8 = clonesByLevel[level2]

						if not (v8 and v8.Visible) then
							continue
						end

						if level < entry.level then
							local describe = LevelRewardRules.describe(entry, state, Config)
							local v9

							if entry.rewardId then
								v9 = state.grantedRewards[level2] == nil
							else
								v9 = describe and not ownedUntradable[describe.cnId] and (#entry.pool == 1 or state.grantedRandom[level2] ~= describe.cnId)
							end

							if describe and v9 then
								v6 = v8
								v5 = v6
								v6 = v5
								break
							end
						end

						v6 = v8
					end

					local v8 = v5 or v6

					if not v8 or parent.AbsoluteSize.X <= 0 then
						return
					end

					local v9 = v8.AbsolutePosition.X - parent.AbsolutePosition.X + parent.CanvasPosition.X + v8.AbsoluteSize.X / 2 - parent.AbsoluteSize.X / 2
					local v10 = math.max(0, parent.AbsoluteCanvasSize.X - parent.AbsoluteSize.X)
					local vector = Vector2.new(math.clamp(v9, 0, v10), 0)
					v3 = TweenService:Create(
						parent,
						TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{
							CanvasPosition = vector
						}
					)
					v3:Play()
				end)
			end
		}
	end
}