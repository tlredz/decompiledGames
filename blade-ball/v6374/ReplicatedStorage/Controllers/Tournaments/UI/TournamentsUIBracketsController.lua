local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
game:GetService("GuiService")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Net)
local v = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Common.Utils)
local v2 = require3(ReplicatedStorage2.ServerInfo)
local v3 = require3(ReplicatedStorage2.Shared.ReplionUtils)
local v4 = require3(ReplicatedStorage2.Shared.PlayerUtility)
local v5 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.Controllers.Tournaments.TournamentsController)
local tournamentBrackets = Players.LocalPlayer.PlayerGui:WaitForChild("TournamentBrackets")

local function fastTween(p, p2, p3)
	local tween = TweenService:Create(p, p2, p3)
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	tween:Play()
	return tween
end

return {
	Start = function(_)
		if not v2.isTournamentMatchServer() then
			return
		end

		tournamentBrackets.Close.Activated:Connect(function()
			v5:Close(tournamentBrackets.Name)
		end)
		local v6 = {
			[4] = tournamentBrackets.Variants["4"],
			[8] = tournamentBrackets.Variants["8"],
			[12] = tournamentBrackets.Variants["12"],
			[16] = tournamentBrackets.Variants["16"]
		}
		local v7 = v.new()

		local function setBracketBox(p: string?, data)
			local v8 = tonumber(p) or -1
			local visible = v8 and v8 >= 1
			data.NA.Visible = not visible
			data.Headshot.Visible = visible
			data.Headshot.Image = not visible and "" or `rbxthumb://type=AvatarHeadShot&id={v8}&w=420&h=420`
			data.Label.Visible = visible

			if visible then
				data.Label.Text = "Loading"
				local playerByUserId = Players:GetPlayerByUserId(v8)

				if playerByUserId then
					data.Label.Text = playerByUserId.Name
				else
					v7:AddPromise(v4:GetUsername(v8)):andThen(function(value: string)
						data.Label.Text = value or "Failed to load"
					end):catch(function()
						data.Label.Text = "Failed to load"
					end)
				end
			end
		end

		v3.observeClientReplion("Tournament", function(object)
			-- equivalent calls inferred from this helper; original call sites unknown
			local function brackets4(list)
				local v8 = v6[4]
				local v9 = list[1]
				setBracketBox(v9[1], v8.Left.BoxTop)
				setBracketBox(v9[2], v8.Left.BoxBtm)
				setBracketBox(v9[3], v8.Right.BoxTop)
				setBracketBox(v9[4], v8.Right.BoxBtm)
			end

			local function brackets8(list, bracketWinners)
				local v8 = v6[8]
				local v9 = list[1]
				setBracketBox(v9[1], v8.Left.List.Box1)
				setBracketBox(v9[2], v8.Left.List.Box2)
				setBracketBox(v9[3], v8.Left.List.Box3)
				setBracketBox(v9[4], v8.Left.List.Box4)
				setBracketBox(bracketWinners["1"], v8.Right.Box)
				local v10 = list[2]
				setBracketBox(v10[1], v8.Right.List.Box1)
				setBracketBox(v10[2], v8.Right.List.Box2)
				setBracketBox(v10[3], v8.Right.List.Box3)
				setBracketBox(v10[4], v8.Right.List.Box4)
				setBracketBox(bracketWinners["2"], v8.Left.Box)
			end

			local function brackets12(list, bracketWinners)
				local v8 = v6[12]
				local v9 = list[1]
				setBracketBox(v9[1], v8.Left.BottomList.Box1)
				setBracketBox(v9[2], v8.Left.BottomList.Box2)
				setBracketBox(v9[3], v8.Left.BottomList.Box3)
				setBracketBox(v9[4], v8.Left.BottomList.Box4)
				setBracketBox(bracketWinners["1"], v8.Left.BoxBtm)
				local v10 = list[2]
				setBracketBox(v10[1], v8.Left.TopList.Box1)
				setBracketBox(v10[2], v8.Left.TopList.Box2)
				setBracketBox(v10[3], v8.Left.TopList.Box3)
				setBracketBox(v10[4], v8.Left.TopList.Box4)
				setBracketBox(bracketWinners["2"], v8.Left.BoxTop)
				local v11 = list[3]
				setBracketBox(v11[1], v8.Right.List.Box1)
				setBracketBox(v11[2], v8.Right.List.Box2)
				setBracketBox(v11[3], v8.Right.List.Box3)
				setBracketBox(v11[4], v8.Right.List.Box4)
				setBracketBox(bracketWinners["3"], v8.Right.Box)
			end

			local function brackets16(list, bracketWinners)
				local v8 = v6[16]
				local v9 = list[1]
				setBracketBox(v9[1], v8.Left.BottomList.Box1)
				setBracketBox(v9[2], v8.Left.BottomList.Box2)
				setBracketBox(v9[3], v8.Left.BottomList.Box3)
				setBracketBox(v9[4], v8.Left.BottomList.Box4)
				setBracketBox(bracketWinners["1"], v8.Left.BoxBtm)
				local v10 = list[2]
				setBracketBox(v10[1], v8.Left.TopList.Box1)
				setBracketBox(v10[2], v8.Left.TopList.Box2)
				setBracketBox(v10[3], v8.Left.TopList.Box3)
				setBracketBox(v10[4], v8.Left.TopList.Box4)
				setBracketBox(bracketWinners["2"], v8.Left.BoxTop)
				local v11 = list[3]
				setBracketBox(v11[1], v8.Right.BottomList.Box1)
				setBracketBox(v11[2], v8.Right.BottomList.Box2)
				setBracketBox(v11[3], v8.Right.BottomList.Box3)
				setBracketBox(v11[4], v8.Right.BottomList.Box4)
				setBracketBox(bracketWinners["3"], v8.Right.BoxBtm)
				local v12 = list[4]
				setBracketBox(v12[1], v8.Right.TopList.Box1)
				setBracketBox(v12[2], v8.Right.TopList.Box2)
				setBracketBox(v12[3], v8.Right.TopList.Box3)
				setBracketBox(v12[4], v8.Right.TopList.Box4)
				setBracketBox(bracketWinners["4"], v8.Right.BoxTop)
			end

			local function updateBrackets()
				v7:Destroy()
				local playersBracket = object:Get("PlayersBracket") or {}
				local bracketWinners = object:Get("BracketWinners") or {}
				print("Players Bracket:", HttpService:JSONEncode(playersBracket))
				print("Winners Bracket:", HttpService:JSONEncode(bracketWinners))
				local v8 = {}
				local count = 0

				for k, v9 in playersBracket do
					if not v8[v9] then
						v8[v9] = {}
					end

					count += 1
					table.insert(v8[v9], k)
				end

				for _, list in v8 do
					table.sort(list)
				end

				local v9 = v6[count]

				if not v9 then
					local v10 = count

					for k, v11 in v6 do
						local v12 = math.abs(k - count)

						if not (v12 < v10) then
							continue
						end

						v9 = v11
						v10 = v12
					end
				end

				for _, v10 in v6 do
					v10.Visible = v10 == v9
				end

				if v9 == v6[4] then
					brackets4(v8) -- equivalent call inferred; original call site unknown
				elseif v9 == v6[8] then
					brackets8(v8, bracketWinners)
				elseif v9 == v6[12] then
					brackets12(v8, bracketWinners)
				elseif v9 == v6[16] then
					brackets16(v8, bracketWinners)
				end
			end

			local connection = object:OnChange("PlayersBracket", updateBrackets)
			local connection2 = object:OnChange("BracketWinners", updateBrackets)
			task.spawn(updateBrackets)
			local tournamentType = string.upper(object:Get("TournamentType") or "EVENT")
			tournamentBrackets.Title.TournamentType.Text = `<stroke color="rgb(0,0,0)" joins="round" thickness="2">Tournament Type: <font color="rgb(255, 17, 17)">{tournamentType}</font></stroke>`
			return function()
				connection:Disconnect()
				connection2:Disconnect()
			end
		end)
	end
}