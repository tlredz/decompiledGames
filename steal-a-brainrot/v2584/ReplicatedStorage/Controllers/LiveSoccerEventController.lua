local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local CountryFlagIcons = require(ReplicatedStorage.Shared.CountryFlagIcons)
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local HudController = require(ReplicatedStorage.Controllers.HudController)
local Net = require(ReplicatedStorage.Packages.Net)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Traits = require(ReplicatedStorage.Datas.Traits)
local remoteEvent = Net:RemoteEvent("LiveSoccerEvent/Burst")
local remoteEvent2 = Net:RemoteEvent("LiveSoccerEvent/MiniEvent")
local liveSoccerMatches = ReplicatorClient.get("LiveSoccerMatches")
local replicated = FastFlags.Replicated("LiveSoccerEvent.ScoreBoardHidden", Asserts.Boolean, false)
local v = {}

local function resolveFlagIcon(p: string, flag: boolean?)
	local v2 = v[p]

	if v2 == nil then
		v2 = FastFlags.Replicated("LiveSoccerEvent.FlagIconOverride." .. p, Asserts.String, "")
		v[p] = v2
	end

	local v3 = v2:Get()

	if v3 ~= "" then
		return v3
	end

	if flag then
		local trait = Traits[p]

		if trait then
			return trait.Icon
		end

		return ""
	else
		local v4 = CountryFlagIcons.Normal[p]

		if v4 then
			return (`rbxassetid://{v4}`)
		end

		return ""
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function localDayKey(startUtcSeconds: number)
	local localTime = DateTime.fromUnixTimestamp(startUtcSeconds):ToLocalTime()
	return string.format("%04d-%02d-%02d", localTime.Year, localTime.Month, localTime.Day)
end

local function formatLocalKickoff(startUtcSeconds: number)
	local localTime = DateTime.fromUnixTimestamp(startUtcSeconds):ToLocalTime()
	local v2 = localTime.Hour >= 12 and "PM" or "AM"
	local v3 = localTime.Hour % 12
	local v4 = v3 == 0 and 12 or v3
	return string.format("%d:%02d %s", v4, localTime.Minute, v2)
end

local function formatCountdown(p: number)
	local v2 = math.max(p, 0)
	local v3 = math.floor(v2 / 86400)
	local v4 = math.floor(v2 % 86400 / 3600)
	local v5 = math.floor(v2 % 3600 / 60)

	if v3 > 0 then
		return string.format("STARTING IN: %dd %dh", v3, v4)
	end

	if v4 > 0 then
		return string.format("STARTING IN: %dh %dm", v4, v5)
	end

	return string.format("STARTING IN: %dm", v5)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isInPlay(status: string)
	return status == "live" or status == "halftime"
end

local function selectDisplayMatches(items)
	local v2 = {}
	local v3 = {}

	for _, item in items do
		if item.status == "finished" then
			continue
		end

		if isInPlay(item.status) then
			table.insert(v2, item)
		else
			table.insert(v3, item)
		end
	end

	local v4 = nil

	for _, v5 in v3 do
		local v6 = localDayKey(v5.startUtcSeconds) -- equivalent call inferred; original call site unknown

		if v4 == nil or v6 < v4 then
			v4 = v6
		end
	end

	local result = {}
	local v5 = {}

	for _, v6 in v2 do
		table.insert(result, v6)
	end

	for _, v6 in v3 do
		if v4 ~= nil and localDayKey(v6.startUtcSeconds) == v4 then
			table.insert(result, v6)
			continue
		end

		table.insert(v5, v6)
	end

	table.sort(v5, function(a, b)
		return a.startUtcSeconds < b.startUtcSeconds
	end)
	local startUtcSeconds = nil

	for _, v6 in v5 do
		local v7 = #result >= 2
		local v8 = v6.startUtcSeconds == startUtcSeconds

		if v7 and not v8 then
			break
		end

		startUtcSeconds = v6.startUtcSeconds
		table.insert(result, v6)
	end

	return result
end

return {
	Start = function(_)
		remoteEvent.OnClientEvent:Connect(function(p: string, p2: string, flag: boolean?)
			local v2

			if flag then
				v2 = ReplicatedStorage.Sounds.Events.Brazil.Hit
			else
				v2 = ReplicatedStorage.Sounds.Events.LiveSoccer.Burst
			end

			ClientEventUtils.playBurst(ReplicatedStorage.Vfx.LiveSoccerBursts[p2], p, { v2 })
		end)
		remoteEvent2.OnClientEvent:Connect(function(p: string, p2: number)
			local v4 = v[p]

			if v4 == nil then
				v4 = FastFlags.Replicated("LiveSoccerEvent.FlagIconOverride." .. p, Asserts.String, "")
				v[p] = v4
			end

			local v5 = v4:Get()

			if v5 == "" then
				local trait = Traits[p]
				v5 = not trait and "" or trait.Icon
			end

			HudController:ShowFakeEvent("LiveSoccer", p2, v5)
		end)
		Observers.observeTag("SoccerScoreBoard", function(folder)
			local maid = Trove.new()
			local main = folder.Main
			local soccerScoreBoard = main.SoccerScoreBoard
			soccerScoreBoard.Adornee = main
			soccerScoreBoard.Parent = Players.LocalPlayer.PlayerGui
			maid:Add(soccerScoreBoard)
			local container = soccerScoreBoard.Container
			local template = container.UIListLayout.Template
			local upcoming = container.Upcoming
			local liveNow = container.LiveNow
			template.Visible = false
			upcoming.Visible = false
			liveNow.Visible = false

			for _, child in container:GetChildren() do
				if child.Name == "Match" then
					child:Destroy()
				end
			end

			local extended = maid:Extend()
			local v2 = {}
			local v3 = false

			local function updateRow(clone, data)
				local trait = Traits[data.homeName]
				local trait2 = Traits[data.awayName]
				local country1 = clone.Country1
				local text

				if trait then
					text = trait.Display
				else
					text = data.homeName
				end

				country1.Text = text
				local country2 = clone.Country2
				local text2

				if trait2 then
					text2 = trait2.Display
				else
					text2 = data.awayName
				end

				country2.Text = text2
				local country1Flag = clone.Country1Flag
				local homeName = data.homeName
				local v6 = v[homeName]

				if v6 == nil then
					v6 = FastFlags.Replicated("LiveSoccerEvent.FlagIconOverride." .. homeName, Asserts.String, "")
					v[homeName] = v6
				end

				local image = v6:Get()

				if image == "" then
					local v8 = CountryFlagIcons.Normal[homeName]
					image = not v8 and "" or `rbxassetid://{v8}`
				end

				country1Flag.Image = image
				local country2Flag = clone.Country2Flag
				local awayName = data.awayName
				local v8 = v[awayName]

				if v8 == nil then
					v8 = FastFlags.Replicated("LiveSoccerEvent.FlagIconOverride." .. awayName, Asserts.String, "")
					v[awayName] = v8
				end

				local image2 = v8:Get()

				if image2 == "" then
					local v10 = CountryFlagIcons.Normal[awayName]
					image2 = not v10 and "" or `rbxassetid://{v10}`
				end

				country2Flag.Image = image2
				local inPlay = isInPlay(data.status) -- equivalent call inferred; original call site unknown
				clone.Timer.Visible = inPlay
				clone.Score.Visible = inPlay
				clone.Time.Visible = not inPlay

				if not inPlay then
					clone.Time.Text = formatLocalKickoff(data.startUtcSeconds)
					return
				end

				clone.Timer.Text = data.status == "halftime" and "HT" or tostring(data.matchMinute)
				clone.Score.Text = string.format("%d - %d", data.homeScore, data.awayScore)
			end

			local function redraw()
				if v3 then
					return
				end

				extended:Clean()
				local v4 = liveSoccerMatches:TryIndex({ "matches" })
				local v5 = not v4 and {} or selectDisplayMatches(v4)

				if #v5 == 0 then
					for k, v6 in v2 do
						v6:Destroy()
						v2[k] = nil
					end

					local clone = extended:Clone(upcoming)
					clone.Text = "Loading Matches.."
					clone.LayoutOrder = 0
					clone.Visible = true
					clone.Parent = container
				else
					table.sort(v5, function(a, b)
						if a.startUtcSeconds == b.startUtcSeconds then
							return a.matchId < b.matchId
						end

						return a.startUtcSeconds < b.startUtcSeconds
					end)
					local now = os.time()
					local v6 = 1
					local count = 0
					local v7 = {}

					while v6 <= #v5 do
						local startUtcSeconds = v5[v6].startUtcSeconds
						local v8 = {}
						local v9 = false

						while v6 <= #v5 and v5[v6].startUtcSeconds == startUtcSeconds do
							local v10 = v5[v6]
							table.insert(v8, v10)
							v9 = isInPlay(v10.status) and true or v9
							v6 += 1
						end

						if v9 then
							local clone = extended:Clone(liveNow)
							clone.Visible = true
							clone.LayoutOrder = count
							clone.Parent = container
						else
							local clone = extended:Clone(upcoming)
							clone.Text = formatCountdown(startUtcSeconds - now)
							clone.Visible = true
							clone.LayoutOrder = count
							clone.Parent = container
						end

						count += 1

						for _, v10 in v8 do
							v7[v10.matchId] = true
							local clone = v2[v10.matchId]

							if not clone then
								clone = template:Clone()
								clone.Visible = true
								clone.Parent = container
								v2[v10.matchId] = clone
							end

							clone.LayoutOrder = count
							count += 1
							updateRow(clone, v10)
						end
					end

					for k, v8 in v2 do
						if v7[k] then
							continue
						end

						v8:Destroy()
						v2[k] = nil
					end
				end
			end

			local function applyHidden()
				v3 = replicated:Get()
				soccerScoreBoard.Enabled = not v3

				for _, part in folder:GetDescendants() do
					if part:IsA("BasePart") then
						part.LocalTransparencyModifier = v3 and 1 or 0
					end
				end

				if not v3 then
					redraw()
				end
			end

			local changedConnection = replicated.Changed:Connect(applyHidden)
			maid:Add(function()
				changedConnection:Disconnect()
			end)
			maid:Add(liveSoccerMatches:Listen({ "matches" }, redraw))
			maid:Add(task.spawn(function()
				while true do
					redraw()
					task.wait(1)
				end
			end))
			applyHidden()
			return maid:WrapClean()
		end, { workspace })
	end
}