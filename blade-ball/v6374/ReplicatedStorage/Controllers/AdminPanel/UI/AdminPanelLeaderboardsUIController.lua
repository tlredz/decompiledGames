local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Shared.PlayerUtility)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v2 = require3(ReplicatedStorage2.Shared.Statable)
require3(ReplicatedStorage2.Packages.Charm)
require3(ReplicatedStorage2.Packages.Freeze)
require3(ReplicatedStorage2.Shared.Action)
require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.Common.MarketplaceService)
require3(ReplicatedStorage2.Shared.StatableCleaner)
require3(ReplicatedStorage2.Controllers.Trading.IndexController)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local _ = require3(ReplicatedStorage2.Shared.Inventory).Client
require3(ReplicatedStorage2.Shared.DataViewer)
local v4 = require3(ReplicatedStorage2.Shared.StatableCleaner)
local v5 = require3(ReplicatedStorage2.Shared.AdminPanel)
local v6 = require3(ReplicatedStorage2.Shared.RankedSeasonData)
require3(ReplicatedStorage2.Shared.TournamentEvent.TournamentEventData)
local v7 = require3(ReplicatedStorage2.Controllers.NotificationController)
local v8 = require3(ReplicatedStorage2.Controllers.AdminPanel.AdminPanelUIController)
local leaderboards = v8.AdminPanelUI.Window.Content.Pages.Leaderboards
local ranks = leaderboards.Ranks
local options = leaderboards.Options
local v9 = {}

for k, season in v6.Seasons do
	for k2 in season do
		for k3, mode in v6.Modes do
			if not (k3 ~= "Duel" or not (k2 < 13)) then
				continue
			end

			local v10 = {
				name = `Ranked {k} Season {k2} {mode.DisplayName}`,
				id = 0
			}
			local id

			if k == "Normal" then
				id = `Elo{k3}--{k2}-Lb`
			else
				id = `{k}-Elo{k3}--{k2}-Lb`
			end

			v10.id = id
			table.insert(v9, v10)
		end
	end
end

local function getDigitsBetweenAandB(p: number, p2: number, p3: number)
	return (math.floor(p % 10 ^ p3 / 10 ^ (p2 - 1)))
end

return {
	Start = function(_)
		v8.LoadUserAction.Signal:Connect(function(p)
			local _ = p.Replion
			local maid = v8.UserTrove:Extend()
			local maid2 = maid:Add(v4.new())
			local v10 = maid2:Add(v2.State())
			local v11 = maid2:Add(v2.State())
			local clones = {}
			local extended = maid:Extend()
			maid:Add(function()
				for _, v12 in clones do
					v12:Destroy()
				end

				clones = {}
			end)
			local flag = false
			maid2:Add(v2.Computed(function(callback)
				local v12 = callback(v10)

				if not v12 then
					return nil
				end

				leaderboards.SelectedLeaderboard.Text = v12.name
				flag = true
				v11:Set(nil)
				local v13, v14 = v5.Actions.Leaderboards.Get:Call(v12.id)
				flag = false

				if v13 then
					v11:Set(v14)
					return nil
				end

				v7:SendNotification("Something went wrong, try again later!")
				v11:Set(nil)
				ReplicatedStorage2.Misc.error:Play()
			end))
			maid2:Add(v2.Computed(function(callback)
				local v12 = callback(v11)
				local v13 = callback(v10)

				if not (v12 and v13) then
					return nil
				end

				if #clones - #v12 > 0 then
					for i = #v12 + 1, #clones do
						local v14 = clones[i]

						if v14 then
							v14.Visible = false
						end
					end
				end

				extended:Clean()
				local v14 = string.find(v13.name, "Ranked") ~= nil

				for k, v15 in v12 do
					local clone = clones[k]

					if not clone then
						clone = ranks.ScrollingFrame.UIListLayout.Template:Clone()
						clone.Parent = ranks.ScrollingFrame
						clones[k] = clone
					end

					local key = v15.key
					local value = v15.value

					if v14 then
						key = string.split(v15.key, ":")[1]
						value = math.floor(v15.value % 1e16 / 100000000000)
					end

					clone.Kills.Amount.Text = type(value) ~= "number" and "" or v3.ValueConvertor:AddCommas(value)
					clone.RankLabel.Text = `#{k}`
					clone.ProfilePicture.PlaceHolder.Image = `rbxthumb://type=AvatarHeadShot&id={key}&w=150&h=150`
					clone.PlayerName.Text = "Loading..."
					extended:AddPromise(v:GetUsername(key, 10):andThen(function(value2)
						clone.PlayerName.Text = value2 or "???"
					end))
					clone.Visible = true
				end

				return nil
			end))

			for _, v12 in v9 do
				local clone = maid:Clone(options.ScrollingFrame.UIListLayout.Template)
				clone.TextButton.Text = v12.name
				clone.Parent = options.ScrollingFrame
				local v13 = v12
				clone.Activated:Connect(function()
					if flag then
						v7:SendNotification("Already requesting a leaderboard, please wait!")
					else
						v10:Set(v13)
					end
				end)
			end

			maid:Add(options.ScrollingFrame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				options.ScrollingFrame.CanvasSize = UDim2.fromOffset(
					0,
					options.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y
				)
			end))
			maid:Add(ranks.ScrollingFrame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				ranks.ScrollingFrame.CanvasSize = UDim2.fromOffset(
					0,
					ranks.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y
				)
			end))
		end)
	end
}