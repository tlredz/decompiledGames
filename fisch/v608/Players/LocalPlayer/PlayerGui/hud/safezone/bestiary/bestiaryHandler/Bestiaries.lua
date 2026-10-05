local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local events = ReplicatedStorage.events
local packages = ReplicatedStorage.packages
local sounds = ReplicatedStorage.resources.sounds
local modules = ReplicatedStorage.shared.modules
local localPlayer = Players.LocalPlayer
local timer = script.Parent.Parent.timer
local header = script.Parent.Parent.header
local select = script.Parent.Parent.select
local title = script.Parent.Parent.title
local fish = script.Parent.Parent.fish
local scroll = fish.scroll
local percent = fish.percent
local shinypercent = fish.shinypercent
local sparklingpercent = fish.sparklingpercent
local search = fish.search
local WorldController = require(legacyControllers.WorldController)
local Net = require(packages.Net)
local Signal = require(packages.Signal)
local Timer = require(packages.Timer)
local Trove = require(packages.Trove)
require(script.Parent.Types)
local currentWorldIndex = WorldController:GetCurrentWorldIndex()
WorldController:GetCurrentWorldBestiary()
local Bestiary = require(modules.Bestiary)
local character = require(modules.character)
require(modules.library.fish)
local fx = require(modules.fx)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local locations = require(modules.library.locations)
local timeevents = require(modules.library.timeevents)
local playerDataReplicator = DataController.PlayerDataReplicator
local tracker_locationsdiscovered = legacyLocalPlayerData.fetch():WaitForChild("Stats"):WaitForChild("tracker_locationsdiscovered")
local remoteFunction = Net:RemoteFunction("TimeEvent/GetEventTime")
local Bestiaries = {
	bestiaryTrove = Trove.new(),
	categories = {},
	lastCategoryLocation = {},
	currentCategory = nil,
	currentBestiary = nil,
	currentType = "fish",
	onCategoryChange = Signal.new(),
	onLocationChange = Signal.new()
}

local function ToTime(p: number)
	local v = math.floor(p / 86400)
	local v2 = p % 86400
	local v3 = math.floor(v2 / 3600)
	local v4 = v2 % 3600
	local v5 = math.floor(v4 / 60)
	local v6 = v4 % 60
	local v7 = ""

	if v >= 1 then
		v7 ..= `{string.format("%02d", v)}d`
	end

	if v >= 1 or v3 >= 1 then
		v7 ..= `{v >= 1 and " " or ""}{string.format("%02d", v3)}h`
	end

	if v3 >= 1 or v5 >= 1 then
		v7 ..= `{v3 >= 1 and " " or ""}{string.format("%02d", v5)}m`
	end

	if v < 1 and v6 > 0 then
		return v7 .. `{v5 >= 1 and " " or ""}{string.format("%02d", v6)}s`
	end

	return v7
end

local v = { "Gloomy Crevice", "Lower Deep", "Outer Deep" }

local function getDeepCountedFish()
	local v2 = {}
	local result = {}

	for _, v3 in v do
		for _, v4 in Bestiary:GetCountedFishInBestiary(v3) do
			if v2[v4] then
				continue
			end

			v2[v4] = true
			table.insert(result, v4)
		end
	end

	return result
end

function Bestiaries:UpdateCanvasSize(p, p2)
	p.CanvasSize = UDim2.new(0, p2.AbsoluteContentSize.X, 0, p2.AbsoluteContentSize.Y + 20)
end

function Bestiaries:GetLocationData(p2)
	for _, category in self.categories do
		for k, location in category.locations do
			if k == p2 then
				return location
			end
		end
	end

	return nil
end

function Bestiaries:GetCategoryByLocation(p2)
	for k, category in self.categories do
		for k2, _ in category.locations do
			if k2 == p2 then
				return k
			end
		end
	end

	return nil
end

function Bestiaries:CheckEnabled(p)
	local v2 = p and locations[p]
	local locationData = p and self:GetLocationData(p)
	local categoryByLocation = p and self:GetCategoryByLocation(p)

	if not (v2 and locationData) then
		return
	end

	if tracker_locationsdiscovered:FindFirstChild(p .. "Discovered") or v2.Event ~= nil or v2.AutoDiscover == true or categoryByLocation == "Limited" then
		locationData.discovered = true

		if locationData.button then
			locationData.button.title.Text = v2.Name or p
			locationData.button.ImageColor3 = Color3.fromRGB(255, 255, 255)
		end
	else
		locationData.discovered = false

		if locationData.button then
			locationData.button.title.Text = "???"
			locationData.button.ImageColor3 = Color3.fromRGB(35, 35, 35)
		end
	end
end

function Bestiaries:LoadProgress()
	local currentBestiary = self.currentBestiary
	local v2 = currentBestiary and locations[currentBestiary]
	local locationData = currentBestiary and self:GetLocationData(currentBestiary)
	local categoryByLocation = currentBestiary and self:GetCategoryByLocation(currentBestiary)

	if currentBestiary and v2 and locationData and categoryByLocation then
		task.spawn(function()
			local discoveryPercentages, v3, v4

			if currentBestiary == "The Deep" then
				discoveryPercentages, v3, v4 = Bestiary:GetDiscoveryPercentages(
					localPlayer,
					getDeepCountedFish(),
					false
				)
			else
				discoveryPercentages, v3, v4 = character:GetBestiary(localPlayer, currentBestiary)
			end

			local v5 = tonumber(string.format("%.1f", discoveryPercentages))
			local v6 = tonumber(string.format("%.1f", v3))
			local v7 = tonumber(string.format("%.1f", v4))

			if self.currentBestiary == "All" or self.currentBestiary == nil then
				percent.Text = `   {v5}% Completed [All]`
			else
				percent.Text = `   {v5}% Completed [{v2.Name or currentBestiary}]`
			end

			shinypercent.Text = `{v6}% Shiny`
			sparklingpercent.Text = `{v7}% Sparkling`

			if v5 >= 100 then
				percent.TextColor3 = Color3.fromRGB(200, 192, 106)

				if not tracker_locationsdiscovered:FindFirstChild(currentBestiary) then
					events:WaitForChild("bestiarycomplete"):FireServer(currentBestiary)
				end
			else
				percent.TextColor3 = Color3.fromRGB(120, 120, 120)
			end

			percent.Visible = Bestiaries.currentType == "fish"
			shinypercent.Visible = Bestiaries.currentType == "fish"
			sparklingpercent.Visible = Bestiaries.currentType == "fish"
			return (tonumber(string.format("%.1f", v5 or 0)))
		end)
	end
end

function Bestiaries.LoadBestiaryEvent(p)
	local currentBestiary = p.currentBestiary
	local v2 = currentBestiary and locations[currentBestiary]

	if not v2 then
		timer.Visible = false
		return
	end

	if timeevents.Events[v2.Name] then
		local duration = {}
		local start2, stop2 = remoteFunction:InvokeServer(v2.Name)

		if start2 then
			duration.Start = start2
		end

		if stop2 then
			duration.Stop = stop2
		end

		if duration == {} then
			duration = nil
		end

		v2.Duration = duration
	elseif v2.StartTime and v2.EndTime then
		v2.Duration = {
			Start = v2.StartTime,
			Stop = v2.EndTime
		}
	end

	if not v2.Duration then
		timer.Visible = false
		return
	end

	local start = v2.Duration.Start
	local stop = v2.Duration.Stop
	local unixTimestamp = start.UnixTimestamp
	local unixTimestamp2 = stop.UnixTimestamp
	local v3 = Timer.new(1)
	p.bestiaryTrove:Connect(v3.Tick, function()
		if p.currentBestiary ~= currentBestiary then
			return
		end

		local serverTimeNow = workspace:GetServerTimeNow()

		if serverTimeNow < unixTimestamp then
			timer.Text = `Starting in {ToTime(math.clamp(unixTimestamp - serverTimeNow, 0, 1e999))}`
		elseif serverTimeNow < unixTimestamp2 then
			timer.Text = `Leaving in {ToTime(math.clamp(unixTimestamp2 - serverTimeNow, 0, 1e999))}`
		else
			timer.Text = `Expired {stop:FormatLocalTime("ll", localPlayer.LocaleId)}`
			v3:Stop()
		end
	end)
	p.bestiaryTrove:Add(v3, "Destroy")
	v3:StartNow()
	timer.Visible = true
end

function Bestiaries:LoadBestiaryCatagory()
	local currentBestiary = self.currentBestiary
	local v2 = currentBestiary and locations[currentBestiary]
	local locationData = currentBestiary and self:GetLocationData(currentBestiary)
	local categoryByLocation = currentBestiary and self:GetCategoryByLocation(currentBestiary)

	if not (v2 and locationData and categoryByLocation) then
		return
	end

	search.Text = ""

	if self.currentBestiary == "All" then
		title.Text = Bestiaries.currentType == "fish" and "Bestiary" or Bestiaries.currentType == "rod" and "Rod Journal" or false
		header.Image = "rbxassetid://17849803528"
	else
		title.Text = `{Bestiaries.currentType == "fish" and "Bestiary" or Bestiaries.currentType == "rod" and "Rod Journal" or false} [{v2.Name or currentBestiary}]`
		header.Image = v2.Banner or ""
	end

	Bestiaries:UpdateCanvasSize(scroll, scroll.UIGridLayout)
	local child = script.Parent.Parent:FindFirstChild(categoryByLocation .. "Category")

	if child then
		Bestiaries:UpdateCanvasSize(child.scroll, child.scroll.UIListLayout)
	end

	select.Parent.sections.Visible = Bestiaries.currentType == "fish"

	if Bestiaries.currentType ~= "fish" then
		Bestiaries:SwitchCategory("Normal")
	end

	select.fish_frame.Visible = false
	select.rod_frame.Visible = false
	select.none.Visible = true
	self.lastCategoryLocation[categoryByLocation] = currentBestiary
	self:LoadProgress()
end

function Bestiaries:CreateLocation(p, p2)
	local v2 = p2 and locations[p2]

	if not (self.categories[p] and v2) or self:GetLocationData(p2) or v2.Hide == true and p ~= "Limited" then
		return
	end

	if v2.UseChildrenFish then
		return
	end

	local semiHide = v2.SemiHide == true

	if v2.Worlds and not table.find(v2.Worlds, currentWorldIndex) then
		return
	end

	local child = script.Parent.Parent:FindFirstChild(p .. "Category")

	if not child then
		return
	end

	local v3 = {
		name = p2,
		button = nil,
		discovered = false,
		bestiary = {}
	}

	if not semiHide then
		local clone = script.categoryButtonTemplate:Clone()
		clone.Name = p2

		if p2 == "All" or p2 == "Limited" then
			clone.Name = "1 " .. p2
		else
			clone.Name = p2
		end

		if p2 == "Limited" then
			clone.Visible = false
		end

		clone.Image = v2.Banner
		clone.Parent = child.scroll
		v3.button = clone
		clone.MouseButton1Click:Connect(function()
			if not (v3.discovered ~= false and self.currentBestiary ~= p2) then
				return
			end

			self.currentBestiary = p2
			self:LoadBestiaryCatagory()
			self.onLocationChange:Fire()
			fx:PlaySound(sounds.sfx.player.bestiaryCatagory, script.Parent, true)
		end)
		clone.MouseEnter:Connect(function()
			fx:PlaySound(sounds.sfx.ui.itemhover, script.Parent, true)
		end)
		local timeEvent = ReplicatedStorage:GetAttribute("TimeEvent")

		if v2.Event and timeEvent then
			v3.discovered = true
			local timeEventChangedConnection = nil
			timeEventChangedConnection = ReplicatedStorage:GetAttributeChangedSignal("TimeEvent"):Connect(function(p3)
				if p3 == nil then
					timeEventChangedConnection:Disconnect()
					clone:Destroy()
					table.clear(v3)

					if self.categories[p].locations[p2] then
						self.categories[p].locations[p2] = nil
					end

					if self.currentBestiary == p2 then
						self.currentBestiary = "All"
						self.lastCategoryLocation[p] = "All"
						self:LoadBestiaryCatagory()
						self.onLocationChange:Fire()
					end
				end
			end)
		elseif v2.Event and not timeEvent then
			clone:Destroy()
			return
		end
	end

	self.categories[p].locations[p2] = v3

	if not self.lastCategoryLocation[p] then
		self.lastCategoryLocation[p] = p2
	end

	self:CheckEnabled(p2)
end

function Bestiaries.CreateCategory(p, name)
	if not name then
		return
	end

	p.categories[name] = {
		name = name,
		locations = {}
	}
end

function Bestiaries:SwitchCategory(currentCategory)
	if not currentCategory then
		return
	end

	local currentCategory2 = self.currentCategory

	if currentCategory2 == currentCategory then
		return
	end

	local child = currentCategory2 and script.Parent.Parent:FindFirstChild(currentCategory2 .. "Category")

	if child then
		child.Visible = false
	end

	local child2 = script.Parent.Parent:FindFirstChild(currentCategory .. "Category")

	if not child2 then
		return
	end

	child2.Visible = true
	self.currentCategory = currentCategory
	self.currentBestiary = self.lastCategoryLocation[currentCategory]
	self:LoadBestiaryCatagory()
	self.onCategoryChange:Fire()
end

playerDataReplicator:WaitForLoaded()
playerDataReplicator:Observe({ "Bestiary" }, function()
	Bestiaries:LoadProgress()
end)
tracker_locationsdiscovered.ChildAdded:Connect(function(child)
	Bestiaries:CheckEnabled((child.Name:gsub("Discovered", "")))
end)

for _, button in pairs(script.Parent.Parent.sections:GetChildren()) do
	local child = button:IsA("ImageButton") and script.Parent.Parent:FindFirstChild(button.Name .. "Category")

	if not child then
		continue
	end

	local v2 = child
	local v3 = button
	button.Activated:Connect(function()
		if v2 then
			Bestiaries:SwitchCategory(v3.Name)
		end
	end)
	button.MouseButton1Click:Connect(function()
		fx:PlaySound(sounds.sfx.player.bestiaryCatagory, script.Parent, true)
	end)
	button.MouseEnter:Connect(function()
		fx:PlaySound(sounds.sfx.ui.itemhover, script.Parent, true)
	end)
end

return Bestiaries