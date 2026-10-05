local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Trove)
local v2 = require3(ReplicatedStorage2.ServerInfo)
local v3 = require3(ReplicatedStorage2.Packages.Replion)
local v4 = require3(ReplicatedStorage2.Shared.PlayerUtility)
local v5 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v6 = require3(ReplicatedStorage2.Shared.TournamentEvent.TournamentEventData)
local tournamentEventBrackets = Players.LocalPlayer.PlayerGui:WaitForChild("TournamentEventBrackets")
return {
	Start = function(_)
		if not ((v2.isTournamentEventServer() or v2.isMedalTournamentMatch()) and v6.ShowBrackets) then
			return
		end

		tournamentEventBrackets.Close.Activated:Connect(function()
			v5:Close(tournamentEventBrackets.Name)
		end)
		local v7 = v.new()

		local function updateBracketBox(child, p: string?)
			local v8 = tonumber(p) or -1
			local visible = v8 >= 1
			child.Headshot.Visible = visible
			child.Headshot.Image = not visible and "" or `rbxthumb://type=AvatarHeadShot&id={v8}&w=420&h=420`

			if not visible then
				child.Label.Text = "N/A"
				return
			end

			child.Label.Text = "Loading"
			local playerByUserId = Players:GetPlayerByUserId(v8)

			if playerByUserId then
				child.Label.Text = playerByUserId.Name
			else
				v7:AddPromise(v4:GetUsername(v8)):andThen(function(value: string)
					child.Label.Text = value or "Failed to load"
				end):catch(function()
					child.Label.Text = "Failed to load"
				end)
			end
		end

		local function updateGroup(instance, items)
			if not (instance and items) then
				return
			end

			for k, item in items do
				for k2, v8 in item do
					local child = instance:FindFirstChild((`{k}_{k2}`))

					if child then
						updateBracketBox(child, tostring(v8))
					else
						warn((`Player frame for "{child}"" not found\n{v8}`))
					end
				end
			end
		end

		local v8 = v3.Client:WaitReplion("TournamentEvent")

		local function updateBrackets()
			v7:Destroy()
			local expect = v8:GetExpect("Groups")

			for i = 1, v6.GroupsPerTournament do
				updateGroup(tournamentEventBrackets.Brackets.Left:FindFirstChild(i), expect[i])
			end

			updateGroup(tournamentEventBrackets.Brackets.Left.GroupWinners, v8:Get("GroupWinners"))
			updateGroup(tournamentEventBrackets.Brackets.Left.Winners, { v8:Get("Winners") or {} })
		end

		v8:OnChange("Groups", updateBrackets)
		v8:OnChange("GroupWinners", updateBrackets)
		v8:OnChange("Winners", updateBrackets)
		task.spawn(updateBrackets)
	end
}