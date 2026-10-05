local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local GroupService = game:GetService("GroupService")
game:GetService("Players")
local v = require3(ReplicatedStorage2.Shared.PlayerUtility)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v2 = require3(ReplicatedStorage2.Shared.Statable)
require3(ReplicatedStorage2.Shared.DynArgs)
require3(ReplicatedStorage2.Shared.Action)
require3(ReplicatedStorage2.Packages.Trove)
local v3 = require3(ReplicatedStorage2.Common.Utils)
local v4 = require3(ReplicatedStorage2.Shared.AdminPanel)
local v5 = require3(ReplicatedStorage2.Controllers.AdminPanel.AdminPanelUIController)
local userInfo = v5.AdminPanelUI.Window.UserInfo
local stats = userInfo.Stats
return {
	Start = function(_)
		v5.LoadUserAction.Signal:Connect(function(p)
			userInfo.Username.Text = "Loading..."
			userInfo.GroupRank.Text = "Loading..."
			userInfo.UserId.Text = p.UserId
			userInfo.ProfileImage.Icon.Image = `rbxthumb://type=AvatarHeadShot&id={p.UserId}&w=420&h=420`
			local state = v2.State({
				Active = false
			})

			local function updateStats()
				stats.Coins.Amount.Text = `{v3.ValueConvertor:AddCommas(p.Replion:Get("Data.Credits") or 0)} Coins`
				stats.Tokens.Amount.Text = `{v3.ValueConvertor:AddCommas(p.Replion:Get("Inventory.Tokens") or 0)} Tokens`
				stats.RAP.Amount.Text = `{v3.ValueConvertor:ShrinkNumber(p.Replion:Get("Data.LastSavedRAP") or 0)} RAP`
				stats.Kills.Amount.Text = `{v3.ValueConvertor:AddCommas(p.Replion:Get("Data.TotalStats.Kills") or 0)} Kills`
				stats.Wins.Amount.Text = `{v3.ValueConvertor:AddCommas(p.Replion:Get("Data.TotalStats.Wins") or 0)} Wins`
				stats.RobuxSpent.Amount.Text = `{v3.ValueConvertor:AddCommas(p.Replion:Get("Data.TotalRobuxSpent") or 0)} Spent`
				local v6 = p.Replion:Get("Data.TimePlayed") or 0
				local v7 = v6 // 3600
				local v8 = v6 // 60 - v7 * 60
				stats.Playtime.Amount.Text = `{not (v7 > 0) and "" or `{v7}h `}{v8}m Playtime`
				state:Set(p.Replion:Get("Data.Banned") or {
					Active = false
				})
			end

			if p.Replion:Get("Loaded") then
				v5.UserTrove:Add(task.spawn(updateStats))
			else
				for _, frame in stats:GetChildren() do
					if not frame:IsA("Frame") then
						continue
					end

					local amount = frame:FindFirstChild("Amount")

					if amount then
						amount.Text = "Loading..."
					end
				end

				v5.UserTrove:Add(p.Replion:OnChange("Loaded", updateStats))
			end

			v5.UserTrove:Add(stats.Tokens.Grant.Activated:Connect(function()
				if v5:HasPermission("Inventory.GrantTokens") then
					v5.CurrentPage:Set("Home.GrantTokens")
				else
					v5:PromptError("Not enough permission to Grant Tokens")
				end
			end))
			v5.UserTrove:Add(userInfo.Banned.Activated:Connect(function()
				v5.CurrentPage:Set("Home.Moderation")
			end))
			local computed = v2.Computed(function(callback)
				return callback((v2.getReplionPathState(p.Replion, "Session.InSession"))) == true
			end)
			v5.UserTrove:Add(v2.setPropertyComputed(userInfo.JoinPlayer, "Visible", function(callback)
				if callback(state).Active == false then
					return callback(computed)
				end

				return false
			end))
			v5.UserTrove:Add(v2.setPropertyComputed(userInfo.Banned, "Visible", function(callback)
				local v6 = callback(state)
				return v6 ~= nil and v6.Active ~= false
			end))
			v5.UserTrove:Add(v2.setPropertyComputed(userInfo.Location, "Text", function(callback)
				local v6 = callback(state)

				if v6.Active == false then
					return (`Location: {callback(computed) and "In-Game" or "Offline"}`)
				end

				local v7

				if v6.Until then
					v7 = v3.ValueConvertor:FormatTime(v6.Until - v6.Timestamp)
				else
					v7 = type(v6.Active) ~= "number" and "Permanent" or v6.Active == 1e999 and "Permanent" or v3.ValueConvertor:FormatTime(v6.Active)
				end

				return (`Ban Duration: {v7}`)
			end))
			v5.UserTrove:Add(v3.Thread.Every(1, function()
				local v6 = state:Get()

				if v6.Active ~= false then
					userInfo.Time.Text = `Moderator: {v6.Moderator or "???"}`
					return
				end

				if computed:Get() then
					userInfo.Time.Text = "Online Now"
					return
				end

				local v7 = p.Replion:Get("Data.LastSession")

				if v7 then
					userInfo.Time.Text = `Last Played: {v3.ValueConvertor:FormatTimeWithDays(workspace:GetServerTimeNow() - v7)}`
				else
					userInfo.Time.Text = "Loading..."
				end
			end))
			v5.UserTrove:Add(userInfo.JoinPlayer.Activated:Connect(function()
				v4.Actions.Follow:Call()
			end))
			v5.UserTrove:Add(task.spawn(function()
				local expect = v:GetUser(p.UserId):expect()
				local username = expect.Username

				if expect.DisplayName and expect.DisplayName ~= username then
					username = `{expect.DisplayName} (@{username})`
				end

				if expect.HasVerifiedBadge then
					username = " " .. username
				end

				userInfo.Username.Text = username
				v5.UserTrove:Add(task.spawn(function()
					local success, result = pcall(function()
						local groupsAsync = GroupService:GetGroupsAsync(p.UserId)

						for _, v7 in groupsAsync do
							if v7.Id == 12836673 then
								return v7.Role
							end
						end

						return "Guest"
					end)
					userInfo.GroupRank.Text = `Group Rank: {success and result or "[Failed to load]"}`
				end))
			end))
		end)
		userInfo.Refresh.Activated:Connect(function()
			if v5.CurrentPage:Get() == "Home.ExistCounter" then
				return
			end

			if v5._currentUserId then
				v5:LoadUser(v5._currentUserId)
			else
				v5:PromptError("Can't refresh: no UserId loaded!")
			end
		end)
	end
}