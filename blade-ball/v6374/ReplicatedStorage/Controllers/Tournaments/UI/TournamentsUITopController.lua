local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Net)
local v = require3(ReplicatedStorage2.Common.Utils)
local v2 = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Shared.ReplionUtils)
local v4 = require3(ReplicatedStorage2.Packages.Observers)
require3(ReplicatedStorage2.Shared.TournamentData)
local tournaments = ReplicatedStorage2.Controllers.Tournaments
local v5 = require3(tournaments.TournamentsController)
require3(tournaments.UI.TournamentsUIController)
local localPlayer = Players.LocalPlayer
local tournamentsTop = localPlayer.PlayerGui:WaitForChild("TournamentsTop")
local RunService = game:GetService("RunService")
local fn = not RunService:IsStudio() and game.GameId == 4777817887 and function(...) end or print
local v6 = {
	"Red",
	"Blue",
	"Green",
	"Yellow"
}
local maid = v2.new()
return {
	Start = function(_)
		v5:ObserveReplion(function(object)
			maid:Clean()
			local alive = workspace:WaitForChild("Alive")

			local function update()
				fn("### updating tourney top")
				local playersWin = object:Get("PlayersWin")
				localPlayer.PlayerGui.announcer.UIPadding.PaddingTop = UDim.new()

				if not (playersWin and next(playersWin)) then
					tournamentsTop.Enabled = false
					return
				end

				local v7 = -1
				local v8 = {}
				local v9 = nil

				for childName, wins in playersWin do
					local child = Players:FindFirstChild(childName)

					if not child then
						continue
					end

					if v7 < wins then
						v9 = child
						v7 = wins
					end

					table.insert(v8, {
						Player = child,
						Wins = wins
					})
				end

				table.sort(v8, function(a, b)
					return a.Player.UserId < b.Player.UserId
				end)
				localPlayer.PlayerGui.announcer.UIPadding.PaddingTop = UDim.new(0.125, 0)
				tournamentsTop.Enabled = true
				local children = {}

				for k, v10 in v8 do
					local player = v10.Player
					local wins = v10.Wins
					local v11 = v6[k]

					if not v11 then
						continue
					end

					local child = tournamentsTop.Frame:FindFirstChild(v11)

					if not child then
						continue
					end

					table.insert(children, child)
					child.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=100&h=100`
					child.WinsAm.Text = v.ValueConvertor:AddCommas(wins)
					child.Dead.Visible = not (player.Character and player.Character:IsDescendantOf(alive))
					child.Crown.Visible = v9 == player

					for i = 1, 3 do
						local child2 = child.Wins:FindFirstChild((tostring(i)))

						if not child2 then
							continue
						end

						local backgroundColor

						if i <= wins then
							backgroundColor = Color3.new(1, 1, 1)
						else
							backgroundColor = Color3.new(0, 0, 0)
						end

						child2.BackgroundColor3 = backgroundColor
					end
				end

				for _, childName in v6 do
					local child = tournamentsTop.Frame:FindFirstChild(childName)

					if child then
						child.Visible = table.find(children, child) ~= nil
					end
				end
			end

			maid:Add(alive.AncestryChanged:Connect(update))
			maid:Add(alive.ChildAdded:Connect(update))
			maid:Add(alive.ChildRemoved:Connect(update))
			maid:Add(v3.observeReplionPath(object, "PlayersWin", update))
			maid:Add(v4.observePlayer(function(object2)
				local connection = maid:Add(object2:GetAttributeChangedSignal("IsSpectator"):Connect(update))
				return function()
					connection:Disconnect()
				end
			end))
			return function()
				maid:Clean()
			end
		end)
	end
}