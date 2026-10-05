local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("StarterGui")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Packages.Signal)
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.Controllers.ShowRoomController)
require3(ReplicatedStorage2.Controllers.UI.UIStateController)
local v4 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v5 = require3(ReplicatedStorage2.Shared.BattlepassEventData)
local battlepassEvent = Players.LocalPlayer.PlayerGui:WaitForChild("BattlepassEvent")
local welcome = battlepassEvent.Welcome
local rewards = battlepassEvent.Rewards
local template = rewards.WinnerRewards.Template
template.Parent = nil
local v6 = nil
return {
	Start = function(_)
		v4:WaitForData()
		v6 = v.Client:WaitReplion("Data")
		local v7 = v.Client:WaitReplion("GlobalNumbers")
		rewards.Close.Activated:Connect(function()
			v3:Close(battlepassEvent.Name)
		end)
		welcome.Close.Activated:Connect(function()
			v3:Close(battlepassEvent.Name)
		end)
		welcome.Selection.Team1.Activated:Connect(function()
			if welcome.Selection.Team1.TeamFull.Visible or welcome.Loading.Visible then
				return
			end

			local v8, v9 = v5.Remotes.JoinTeam:InvokeServer(v5.Teams[1])

			if not v8 then
				warn(v9)
				ReplicatedStorage2.Misc.error:Play()
			end
		end)
		welcome.Selection.Team2.Activated:Connect(function()
			if welcome.Selection.Team2.TeamFull.Visible or welcome.Loading.Visible then
				return
			end

			local v8, v9 = v5.Remotes.JoinTeam:InvokeServer(v5.Teams[2])

			if not v8 then
				warn(v9)
				ReplicatedStorage2.Misc.error:Play()
			end
		end)
		local v8 = {}

		for k, reward in v5.Rewards do
			local frame = rewards.WinnerRewards:FindFirstChild((tostring(k))) or template:Clone()
			frame.Name = tostring(k)
			frame.LayoutOrder = k
			frame.ClaimedOverlay.Visible = false
			frame.LockedOverlay.Visible = false

			if reward.Type ~= "TeamReward" then
				frame.Label.Text = reward.DisplayName
				frame.Vector.Image = reward.Icon or v2.Icons:GetIcon("DEFAULT_MISSING")
			end

			if not frame.Parent then
				frame.Parent = rewards.WinnerRewards
			end

			v8[k] = {
				Reward = reward,
				Frame = frame
			}
		end

		local function updateTimer()
			local key = v4:GetKey(v5.GetFFlagKey("EndTime")) or 0
			local serverTimeNow = workspace:GetServerTimeNow()

			if key <= serverTimeNow then
				battlepassEvent.Timer.Text = "ENDED"
			else
				battlepassEvent.Timer.Text = `{v2.ValueConvertor:FormatTimeWithDays((math.max(key - serverTimeNow, 0)))}`
			end
		end

		local function update()
			if workspace:GetAttribute("BattlepassEventEnabled") then
				local v9 = v6:Get(v5.GetPath("Team"))
				local v10 = v6:Get(v5.GetPath((`{v5.Stat}OnJoin`)))
				local loaded = v7:Get("Loaded")
				rewards.Loading.Visible = not loaded
				welcome.Loading.Visible = not loaded
				local v11 = rewards

				if v9 == nil then
					loaded = false
				end

				v11.Visible = loaded
				welcome.Visible = not rewards.Visible
				local key = v4:IsDataReady() and v4:GetKey(v5.GetFFlagKey("Milestones")) or {}
				local v12 = type(key) ~= "table" and {} or key
				local formatted = `<stroke color="rgb(67, 32, 94)" joins="round" thickness="2">The <font color="rgb(255, 213, 124)">first team</font> to get <font color="rgb(255, 213, 124)">{v2.ValueConvertor:ShrinkNumber((v12[v5.WinnerReward] or 0) * 1000)} {v5.StatDisplayPlural}</font> wins</stroke>`
				local v13 = v7:Get("Loaded") and v7:Get({ "Values", v5.GetGlobalNumberKey(v5.Teams[1]) }) or 0
				local v14 = v7:Get("Loaded") and v7:Get({ "Values", v5.GetGlobalNumberKey(v5.Teams[2]) }) or 0
				local v15 = math.max(v13, 1)
				local v16 = v15 / (v15 + math.max(v14, 1))

				if v9 then
					rewards.ProgressBar.Fill.Size = UDim2.fromScale(v16, 1)
					rewards.ProgressBar.Vector.Position = UDim2.fromScale(v16, 0.5)
					rewards.ProgressBar.KillCounter1.Text = `{v5.StatDisplayPlural}: {not v13 and "???" or v2.ValueConvertor:ShrinkNumber(v13) or "???"}`
					rewards.ProgressBar.KillCounter2.Text = `{v5.StatDisplayPlural}: {not v14 and "???" or v2.ValueConvertor:ShrinkNumber(v14) or "???"}`
					rewards.Selection.Team1.YourTeam.Visible = v9 == v5.Teams[1]
					rewards.Selection.Team2.YourTeam.Visible = v9 == v5.Teams[2]
					rewards.Desc2.Text = formatted

					if v10 and v7:Get("Loaded") then
						rewards.WinnerRewards.Visible = true

						if v9 == v5.Teams[1] then
							v14 = v13
						end

						local v17 = v14 or 0

						for k, v18 in v8 do
							local layoutOrder = (v12[k] or 0) * 1000
							v18.Frame.LayoutOrder = layoutOrder

							if v18.Reward.Type == "TeamReward" then
								local v20 = v18.Reward[v9]
								v18.Frame.ImageColor3 = v5.Colors[v9] or Color3.fromRGB(255, 255, 255)
								v18.Frame.Label.Text = v20.DisplayName
								v18.Frame.Vector.Image = v20.Icon or v2.Icons:GetIcon("DEFAULT_MISSING")
							end

							if layoutOrder < v10 then
								v18.Frame.LockedOverlay.Visible = true
							elseif layoutOrder <= v17 then
								v18.Frame.ClaimedOverlay.Visible = v6:Find(v5.GetPath("Claims"), k) ~= nil
							end

							local v20 = math.min(v17, layoutOrder)
							local v21 = math.min(v20 / layoutOrder, 1)
							v18.Frame.ProgressBar.StarterBorderFiller.Visible = v21 >= 0.3
							v18.Frame.ProgressBar.FinalBorderFiller.Visible = v21 >= 1
							v18.Frame.ProgressBar.Holder:TweenPosition(
								UDim2.fromScale(v21, 0.5),
								Enum.EasingDirection.Out,
								Enum.EasingStyle.Sine,
								0.4,
								true
							)
							v18.Frame.ProgressBar.Holder.Fill:TweenPosition(
								UDim2.fromScale(1 - v21, 0.5),
								Enum.EasingDirection.Out,
								Enum.EasingStyle.Sine,
								0.4,
								true
							)
							v18.Frame.ProgressBar.Label.Text = `{v2.ValueConvertor:ShrinkNumber(v20)}/{v2.ValueConvertor:ShrinkNumber(layoutOrder)}`
						end
					else
						rewards.WinnerRewards.Visible = false
					end
				else
					welcome.Selection.Team1.TeamFull.Visible = 1 - v16 < 0.5 - v5.TeamLockPercentage / 100
					welcome.Selection.Team2.TeamFull.Visible = v16 < 0.5 - v5.TeamLockPercentage / 100
					welcome.Desc2.Text = formatted
				end

				updateTimer()
			else
				rewards.Visible = false
				welcome.Visible = true
			end
		end

		workspace:GetAttributeChangedSignal("BattlepassEventEnabled"):Connect(update)
		v6:OnChange(v5.GetPath("Kills"), update)
		v6:OnChange(v5.GetPath("KillsOnJoin"), update)
		v6:OnChange(v5.GetPath("Wins"), update)
		v6:OnChange(v5.GetPath("WinsOnJoin"), update)
		v6:OnChange(v5.GetPath("Team"), update)
		v6:OnChange(v5.GetPath(), update)
		v7:OnChange("Values", update)
		v7:OnChange("Loaded", update)
		v4.DataUpdatedEvent:Connect(update)
		v2.Thread.Every(1, updateTimer)
		task.spawn(update)
		local top = welcome.Loading.RadialBar.Top
		local top2 = rewards.Loading.RadialBar.Top
		local postSimulationConnection = RunService.PostSimulation:Connect(function(dt: number)
			local v9 = dt * 60 * 3
			top.Rotation += v9
			top2.Rotation += v9
		end)
		local connection = nil
		connection = v3:OnGuiOpen(battlepassEvent.Name, function()
			if not (v6:Get(v5.GetPath("Team")) or v7:Get("Loaded")) then
				if connection.Connected then
					connection:Disconnect()
				end

				v5.Remotes.OpenedUI:FireServer()
			end
		end)

		if v7:Get("Loaded") then
			postSimulationConnection:Disconnect()
			connection:Disconnect()
		else
			v7:OnChange("Loaded", function(p)
				if p then
					postSimulationConnection:Disconnect()

					if connection.Connected then
						connection:Disconnect()
					end
				end
			end)
		end
	end
}