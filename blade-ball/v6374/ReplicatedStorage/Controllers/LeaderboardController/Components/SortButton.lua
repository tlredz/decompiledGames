local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("Players")
local packages = ReplicatedStorage2.Packages
local v = require3(packages.Net)
local v2 = require3(packages.Promise)
local v3 = require3(packages.Freeze)
local v4 = require3(packages.Replion)
local v5 = require3(packages.Reliever)
local parent = script.Parent.Parent
require3(parent.Types)
local v6 = require3(ReplicatedStorage2.Shared.UseNewLobby)()
local v7 = require3(ReplicatedStorage2.ServerInfo)
local v8 = require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
local v9 = require3(ReplicatedStorage2.Shared.PlayerUtility)
require3(parent)
local v10 = require3(ReplicatedStorage2.Shared.LTMLeaderboardRewards)
local v11 = require3(ReplicatedStorage2.Common.Utils)
local v12 = require3(ReplicatedStorage2.Shared.CountriesToRegions)
local leaderboard = ReplicatedStorage2.Assets.UI.Leaderboard
local v13 = require3(parent.Info)
local SortButton = {}

local function getUserId(value)
	local v14, v15 = string.match(value, "(%d+)-?(%u*)")
	return tonumber(v14), v15
end

function SortButton:Request(p: string, p2: string, p3: string)
	return v2.new(function(callback, callback2)
		if _G.LeaderboardEnabled[p .. p2 .. p3] == false then
			callback2("Waiting for previous leaderboard to finish!")
			return
		end

		local v14

		if p == "Country" then
			v14 = v:Invoke(string.format("GetTopCountryFunction.%s", p3))
		end

		if v14 then
			callback(v14)
		else
			callback2("Failed to retrieve data for " .. p)
		end
	end)
end

function SortButton:FormatPlayerName(p: string, p2: string?, p3: string?)
	local v14 = {}
	local v15

	if p2 then
		v15 = v12[p2]
	end

	if v15 then
		table.insert(v14, (`[{v15}]`))
	end

	if p3 and p3 ~= "" then
		table.insert(v14, (`[{p3}]`))
	end

	table.insert(v14, (`@{p}`))
	return table.concat(v14, " ")
end

function SortButton:Click(p, _: string)
	local section = p.Container:GetAttribute("Section")
	p.SortFrame:SetAttribute("CurrentSection", section)
end

function SortButton:GetCurrentPage(p)
	return p.SortFrame:GetAttribute("CurrentPage") or "AllTime"
end

function SortButton:Update(data)
	local leaderboardName = data.SortFrame:GetAttribute("LeaderboardName")
	local currentSection = data.SortFrame:GetAttribute("CurrentSection")
	local section = data.Container:GetAttribute("Section")
	local currentPage = SortButton:GetCurrentPage(data)

	if table.find(v13.Monthly, leaderboardName) then
		v:RemoteEvent("SetMonthlyLeaderboardReplication"):FireServer(
			leaderboardName,
			currentPage == "Monthly" and currentSection == section,
			section
		)
	end

	data.Container.Visible = true
	local colorPalette = v13.ColorPalettes[leaderboardName]

	if colorPalette then
		if v6 or v7.isDuelLobbyServer() or v7.isRankedLobbyServer() or v7.isTradingPlazaServer() or v7.isFiftyPlayersServer() then
			local container = data.Container
			local imageColor

			if section == currentSection then
				imageColor = colorPalette.Active
			else
				imageColor = colorPalette.Selected
			end

			container.ImageColor3 = imageColor
			local container2 = data.Container
			local image

			if section == currentSection then
				image = colorPalette.UnselectedImage
			else
				image = colorPalette.SelectedImage
			end

			container2.Image = image
		else
			local textLabel = data.Container:FindFirstChildOfClass("TextLabel")

			if textLabel then
				local textColor

				if section == currentSection then
					textColor = colorPalette.Inactive
				else
					textColor = colorPalette.Active
				end

				textLabel.TextColor3 = textColor
			end

			if data.Container:IsA("ImageButton") then
				local container = data.Container
				local imageColor

				if section == currentSection then
					imageColor = colorPalette.Active
				else
					imageColor = colorPalette.Inactive
				end

				container.ImageColor3 = imageColor
			else
				local container = data.Container
				local backgroundColor

				if section == currentSection then
					backgroundColor = colorPalette.Active
				else
					backgroundColor = colorPalette.Inactive
				end

				container.BackgroundColor3 = backgroundColor
			end
		end
	end

	for k, page in pairs(data.Pages) do
		for _, v14 in page do
			v14.Visible = currentSection == section and k == currentPage
		end
	end
end

local function isEmpty(items)
	return next(items) == nil
end

function SortButton:GenerateData(p, items, p2, childName: string, p3: string, p4: string, p5, p6)
	local v14 = p3 .. p4 .. childName

	if _G.LeaderboardEnabled[v14] == false then
		return
	end

	for _, page in pairs(p.Pages) do
		for _, v15 in page do
			v15.Visible = false
		end
	end

	local child = leaderboard:FindFirstChild(childName)

	if items == nil or next(items) == nil then
		return
	end

	_G.LeaderboardEnabled[v14] = false
	local scrollingFrame = p.SortFrame.Parent:FindFirstChild("ScrollingFrame")

	for k, item in items do
		if not item.key then
			continue
		end

		v5.relieve()
		local clone = p.Pages[p4][k]

		if not clone then
			if v6 or v7.isDuelLobbyServer() or v7.isRankedLobbyServer() or v7.isTradingPlazaServer() or v7.isFiftyPlayersServer() then
				local formatted = ("Rank%d"):format(k)
				local v15

				if (tonumber(k) or 0) < 4 then
					v15 = scrollingFrame:FindFirstChild(formatted)
				else
					v15 = scrollingFrame:FindFirstChild("Rank4")
				end

				child = v15 or child
			end

			clone = child:Clone()
			clone.Visible = false
			clone.Parent = scrollingFrame
			p.Pages[p4][k] = clone
		end

		local key = item.key
		local v15, v16 = string.match(key, "(%d+)-?(%u*)")
		local v17 = tonumber(v15)
		local v18

		if p5 then
			v18 = p5[k]
		end

		local v19

		if p2 and v17 then
			v19 = p2[tostring(v17)]
		end

		local v20

		if p6 and v17 then
			v20 = p6[tostring(v17)]
		end

		local rank = clone:FindFirstChild("Rank", true)

		if rank then
			rank.Text = k
		end

		local value = clone:FindFirstChild("Value", true)

		if value then
			local _ = v13.ScorePrefixes[childName]
			local v21

			if item.value < 1000000 then
				v21 = v8:AddCommas(item.value)
			else
				v21 = v8:ShrinkNumber(item.value)
			end

			value.Text = ` {v21} `
		end

		clone.LayoutOrder = k
		local visible

		if p.SortFrame:GetAttribute("CurrentSection") == p3 then
			visible = SortButton:GetCurrentPage(p) == p4
		else
			visible = false
		end

		clone.Visible = visible

		if not (not clone or not v18 or not v3.Dictionary.equals(v18, item) or v20 ~= v19) then
			continue
		end

		if v17 then
			local playerName = clone:FindFirstChild("PlayerName", true)

			if playerName then
				playerName.Text = "Loading..."
			end

			local v22 = v16
			local v23 = v19
			v9:GetUsername(v17):andThen(function(value2)
				local v24 = value2 or "Loading..."
				local playerName2 = clone:FindFirstChild("PlayerName", true)

				if playerName2 then
					playerName2.Text = SortButton:FormatPlayerName(v24, v22, v23)
				end
			end)
			v9:GetPlayerHeadshot(v17):andThen(function(image)
				local picture = clone:FindFirstChild("Picture", true)

				if picture then
					picture.Image = image
				end
			end):catch(warn)

			if childName == "LTMWins" and #v10 > 0 then
				local reward = clone:FindFirstChild("Reward", true)
				local icon = reward and reward:FindFirstChild("Icon")

				if icon then
					local v24 = nil

					for _, v26 in v10 do
						if not (k <= v26.Rank) then
							continue
						end

						v24 = v26
						break
					end

					icon.Image = v24 and v24.Reward.Icon or ""
				end
			elseif childName == "StPatricks" then
				local reward = clone:FindFirstChild("Reward", true)
				local icon = reward and reward:FindFirstChild("Icon")

				if icon then
					icon.Image = v11.Icons:GetExplosionIcon("4th July") or v11.Icons.DEFAULT_ICONS
				end
			end
		else
			clone:Destroy()
			p.Pages[p4][k] = nil
		end
	end

	_G.LeaderboardEnabled[v14] = true
end

function SortButton:Hook(p)
	local section = p.Container:GetAttribute("Section")
	local leaderboardName = p.SortFrame:GetAttribute("LeaderboardName")

	if section == "Global" then
		local v14 = v4.Client:WaitReplion(leaderboardName)
		local main = v14.Data.Main
		local clansTag = v14.Data.ClansTag
		SortButton:GenerateData(p, main, clansTag, leaderboardName, section, "AllTime", nil, nil)
		v14:OnDataChange(function(p2)
			SortButton:GenerateData(p, p2.Main, p2.ClansTag, leaderboardName, section, "AllTime", main, clansTag)
			main = p2.Main
			clansTag = p2.ClansTag
		end)

		if table.find(v13.Monthly, leaderboardName) then
			local formatted = `Monthly{leaderboardName}`
			local v15 = v4.Client:WaitReplion(formatted)
			local main2 = v15.Data.Main
			local v16 = {}
			SortButton:GenerateData(p, main2, v16, leaderboardName, section, "Monthly", nil, nil)
			v15:OnDataChange(function(p2)
				SortButton:GenerateData(p, p2.Main, {}, leaderboardName, section, "Monthly", main2, v16)
				main2 = p2.Main
				v16 = {}
			end)
		end
	else
		if table.find(v13.Monthly, leaderboardName) then
			local formatted = `Monthly{leaderboardName}-{v12[v4.Client:WaitReplion("Data"):GetExpect("Country")] or "NA"}`
			local v14 = v4.Client:WaitReplion(formatted)
			local main = v14.Data.Main
			local v15 = {}
			SortButton:GenerateData(p, main, v15, leaderboardName, section, "Monthly", nil, nil)
			v14:OnDataChange(function(p2)
				SortButton:GenerateData(p, p2.Main, {}, leaderboardName, section, "Monthly", main, v15)
				main = p2.Main
				v15 = {}
			end)
		end

		SortButton:Request(section, "AllTime", leaderboardName):andThen(function(p2)
			SortButton:GenerateData(p, p2, {}, leaderboardName, section, "AllTime", nil, nil)
		end):catch(function(p2)
			warn((`Error while requesting {section}{leaderboardName} data: {p2}`))
		end):await()
	end

	task.defer(function()
		workspace:WaitForChild("Spawn")
		p.SortFrame:GetAttributeChangedSignal("CurrentSection"):Connect(function()
			SortButton:Update(p)
		end)
		p.SortFrame:GetAttributeChangedSignal("CurrentPage"):Connect(function()
			SortButton:Update(p)
		end)
	end)
	SortButton:Update(p)
	p.Container.Activated:Connect(function()
		SortButton:Click(p, leaderboardName)
	end)
end

function SortButton.Init(_, container)
	local v14 = {
		Container = container,
		Data = {},
		Pages = {
			Monthly = {},
			AllTime = {}
		},
		SortFrame = 0
	}
	local sortFrame

	if container.Parent.Name == "Sort" then
		sortFrame = container.Parent
	else
		sortFrame = container.Parent.Parent
	end

	v14.SortFrame = sortFrame
	task.spawn(function()
		SortButton:Hook(v14)
	end)
	return v14
end

return SortButton