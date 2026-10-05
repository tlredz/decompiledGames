local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RankedSignalController = require(ReplicatedStorage.Controllers.Ranked.RankedSignalController)
local ServerInfo = require(ReplicatedStorage.ServerInfo)
local GuiHandler = require(ReplicatedStorage.ClientGameModules.GuiHandler)
local Utils = require(ReplicatedStorage.Common.Utils)
local rankType = ServerInfo:GetRankType()
local updateRankedMenuSignal = RankedSignalController:GetUpdateRankedMenuSignal()
local leaderboard = script.Parent.Parent.Page.Windows.Leaderboard
local timer = script.Parent.Parent.Page.LeaderboardRewards.TimerBox.List.Timer
local list = leaderboard.List
local options = leaderboard.List.Options
local regionSelector = options.RegionSelector
local modeSelector = options.ModeSelector
local template = script.Template
local region = script.Region
local hoverInfo = script.HoverInfo
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
leaderboard.Loading.Visible = ServerInfo.isRankedLobbyServer()
local v = {
	"GLOBAL",
	"NA",
	"EU",
	"LATAM",
	"MENA",
	"OCE",
	"ASEAN",
	"ASIA",
	"AF",
	game.LocalizationService:GetCountryRegionForPlayerAsync(localPlayer)
}
local v2 = { "FFA", "2v2 Duos", "1v1s" }
local LeaderboardManager = {}
local v3 = {
	Normal = {
		FFA = {},
		["2v2 Duos"] = {},
		["1v1s"] = {}
	},
	NoAbility = {
		FFA = {},
		["2v2 Duos"] = {},
		["1v1s"] = {}
	}
}
local RegionIcons = require(script.RegionIcons)
local RankedSeasonData = require(game.ReplicatedStorage.Shared.RankedSeasonData)
local PlayerData = require(game.ReplicatedStorage.Shared.PlayerData)
local name = "GLOBAL"
local text = "FFA"
local object = setmetatable({}, {
	__index = function(p, p2)
		rawset(p, p2, 0)
		return 0
	end
})
local v5 = 0
local flag = false
local parent = script.Parent.Parent
local v6 = false
local v7 = "FFA"

-- equivalent calls inferred from this helper; original call sites unknown
local function IsLeaderboardVisible()
	return parent.Enabled and leaderboard.Visible
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RequestRender(p)
	v7 = p or v7

	if IsLeaderboardVisible() then
		v6 = false
		LeaderboardManager.Render(v7)
	else
		v6 = true
	end
end

local function OnVisibilityChanged()
	if v6 and IsLeaderboardVisible() then
		v7 = v7 or v7

		if IsLeaderboardVisible() then
			v6 = false
			LeaderboardManager.Render(v7)
		else
			v6 = true
		end
	end
end

parent:GetPropertyChangedSignal("Enabled"):Connect(OnVisibilityChanged)
leaderboard:GetPropertyChangedSignal("Visible"):Connect(OnVisibilityChanged)

function LeaderboardManager.LoadPlayerList(p, p2: string, p3)
	v3[p3][p2] = p
	table.sort(v3[p3][p2], PlayerData.Sorter)
	v5 -= 1

	if v5 <= 0 then
		RequestRender(p2) -- equivalent call inferred; original call site unknown
	end
end

function LeaderboardManager.AwaitLoad()
	v5 = 2
end

function LeaderboardManager.InitiateTimer()
	local rankedType = RankedSeasonData.GetRankedType()
	task.spawn(function()
		while true do
			local v8 = RankedSeasonData.GetSeasonEndTime(rankedType) - workspace:GetServerTimeNow()
			timer.Text = Utils.ValueConvertor:FormatTimeWithDaysFull(v8, true)
			task.wait(10)
		end
	end)
end

local v8 = {
	GLOBALFFA = list.GLOBALFFA,
	["GLOBAL2v2 Duos"] = list["GLOBAL2v2 Duos"],
	GLOBAL1v1s = list.GLOBAL1v1s,
	Main = list.Main
}

-- equivalent calls inferred from this helper; original call sites unknown
local function GetLeaderboardFrame(p)
	return v8[name .. p] or v8.Main
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ToggleFrame(p)
	for _, v9 in next, v8, nil do
		v9.Visible = v9 == p
	end
end

local _ = {
	FFA = false,
	["2v2 Duos"] = false,
	["1v1s"] = false
}

local function Clear(p)
	local children = (v8[name .. (p or text)] or v8.Main):GetChildren()

	for _, frame in children do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end
end

local function Render(p, p2)
	if flag then
		return
	end

	flag = true
	local now = os.clock()
	local parent2 = GetLeaderboardFrame(p) -- equivalent call inferred; original call site unknown
	ToggleFrame(parent2) -- equivalent call inferred; original call site unknown

	if not p2 and now < object[parent2] then
		flag = false
		return
	end

	hoverInfo.Parent = script
	Clear("Main")
	object[parent2] = 9000000000
	hoverInfo.Parent = nil
	local v10 = rankType
	local count = 0

	for _, v11 in v3[rankType][p] do
		if count == 100 then
			break
		end

		if not (p == text and PlayerData.MatchToRegion(v11, name)) then
			continue
		end

		if rankType ~= v10 then
			break
		end

		count += 1
		local child = parent2:FindFirstChild(v11.UserId)

		if child then
			child:Destroy()
		end

		local createLabelFrom = PlayerData.CreateLabelFrom(v11, count, template, hoverInfo)
		createLabelFrom.Parent = parent2
	end

	leaderboard.Loading.Visible = false

	for _ = 1, 3 do
		local clone = template:Clone()
		clone:ClearAllChildren()
		clone.BackgroundTransparency = 1
		clone.Parent = parent2
		clone.LayoutOrder = 501
	end

	object[parent2] = 0
	flag = false
end

for k, name2 in next, v, nil do
	local clone = region:Clone()
	clone.Name = name2
	clone.LayoutOrder = k
	clone.Text.Text = RegionIcons[name2] .. name2
	clone.Size = UDim2.fromScale(1, 1 / #v)
	clone.Activated:Connect(function()
		name = clone.Name
		regionSelector.Text.Text = clone.Text.Text
		regionSelector.Dropdown.Visible = false
		Render(text)
	end)
	clone.Parent = regionSelector.Dropdown
end

regionSelector.Dropdown.Size = UDim2.new(1, 0, #v, 16)
regionSelector.Activated:Connect(function()
	regionSelector.Dropdown.Visible = not regionSelector.Dropdown.Visible
end)

for k, v9 in next, v2, nil do
	local clone = region:Clone()
	clone.Name = v9
	clone.LayoutOrder = k
	clone.Text.Text = v9
	clone.Size = UDim2.fromScale(1, 1 / #v2)
	local v10 = v9
	clone.Activated:Connect(function()
		text = v10
		modeSelector.Text.Text = text
		modeSelector.Dropdown.Visible = false
		Render(text)
	end)
	clone.Parent = modeSelector.Dropdown
end

modeSelector.Dropdown.Size = UDim2.new(1, 0, #v2, 16)
modeSelector.Activated:Connect(function()
	modeSelector.Dropdown.Visible = not modeSelector.Dropdown.Visible
end)
playerGui:WaitForChild("RankedSelection")
Clear()
LeaderboardManager.Render = Render
LeaderboardManager.Clear = Clear
updateRankedMenuSignal:Connect(function(p)
	if rankType ~= p then
		Clear()
	end

	rankType = p
end)
leaderboard.RankList.Activated:Connect(function()
	GuiHandler:Open("RankedRewardList")
end)
return LeaderboardManager