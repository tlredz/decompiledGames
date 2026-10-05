local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local ContentProvider = game:GetService("ContentProvider")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
Players = Players.LocalPlayer
local weathers = require(ReplicatedStorage.shared.modules.library.weathers)
local localizedevents = require(ReplicatedStorage.shared.modules.library.localizedevents)
local SharedWeather = require(ReplicatedStorage.shared.modules.SharedWeather)
require(ReplicatedStorage.shared.utils.FischUtils)
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local ZoneController = require(ReplicatedStorage.client.legacyControllers.ZoneController)
local worldstatuses = HudController:GetSafeZone():WaitForChild("worldstatuses")
local world = ReplicatedStorage:WaitForChild("world")
local event = world:WaitForChild("event")
local cycle = world:WaitForChild("cycle")
local season = world:WaitForChild("season")
local v = {
	["Mutation Surge"] = {
		Icon = "rbxassetid://18997116922",
		IconColor = Color3.fromRGB(88, 255, 102),
		Name = "Mutation Surge",
		Tooltip = "+15% Natural Mutation chance"
	},
	["Shiny Surge"] = {
		Icon = "rbxassetid://18997116922",
		IconColor = Color3.fromRGB(255, 238, 143),
		Name = "Shiny Surge",
		Tooltip = "+3% Shiny chance"
	},
	["Night of the Luminous"] = {
		Icon = "rbxassetid://18997116922",
		IconColor = Color3.fromRGB(162, 255, 184),
		Name = "Night of the Luminous",
		Tooltip = "+10% Sparkling chance"
	},
	["Night of the Fireflies"] = {
		Icon = "rbxassetid://18997116922",
		IconColor = Color3.fromRGB(168, 133, 255),
		Name = "Night of the Fireflies",
		Tooltip = "2× Nocturnal fish catch rate"
	}
}
local v2 = {}
local WorldStatus = {}
local v3 = {
	adminEvent = 100,
	localizedEvent = 200,
	event = 300,
	weather = 400,
	cycle = 500,
	season = 600
}
local v4 = {
	"astral",
	"squall",
	"sovereign",
	"meteorological",
	"main"
}
local v5 = {
	Day = "rbxassetid://16956671093",
	Night = "rbxassetid://16956670840"
}
local v6 = {
	Spring = "rbxassetid://17746816696",
	Summer = "rbxassetid://17746817125",
	Autumn = "rbxassetid://17746816954",
	Winter = "rbxassetid://17746816531"
}

for _, localizedevent in localizedevents do
	v2[localizedevent.AttributeName] = true
end

local v7 = {}
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart)

function WorldStatus.removeBadge(p)
	if not p then
		return
	end

	TweenService:Create(p.iconContainer.nextIcon, tweenInfo, {
		Position = UDim2.fromScale(0, -1)
	}):Play()
	task.delay(0.5, p.Destroy, p)
end

function WorldStatus.updateBadge(p, data)
	local iconColor = data.IconColor or Color3.new(1, 1, 1)

	if data.Tooltip then
		p.tooltip:SetAttribute(
			"CurrentText",
			(`<font color="#{iconColor:ToHex()}"><b>{data.Name}</b></font>\n{data.Tooltip}`)
		)
	else
		p.tooltip:SetAttribute("CurrentText", (`<font color="#{iconColor:ToHex()}">{data.Name}</font>`))
	end

	if p.iconContainer.nextIcon.Image ~= data.Icon or p.iconContainer.nextIcon.ImageColor3 ~= iconColor then
		p.iconContainer.currentIcon.Image = p.iconContainer.nextIcon.Image
		p.iconContainer.currentIcon.ImageColor3 = p.iconContainer.nextIcon.ImageColor3
		p.iconContainer.currentIcon.Position = UDim2.fromScale(0, 0)
		p.iconContainer.nextIcon.Position = UDim2.fromScale(0, 1)
		p.iconContainer.nextIcon.Image = data.Icon
		p.iconContainer.nextIcon.ImageColor3 = iconColor
		task.spawn(function()
			ContentProvider:PreloadAsync({ p.iconContainer.nextIcon })
			TweenService:Create(p.iconContainer.currentIcon, tweenInfo, {
				Position = UDim2.fromScale(0, -1)
			}):Play()
			TweenService:Create(p.iconContainer.nextIcon, tweenInfo, {
				Position = UDim2.fromScale(0, 0)
			}):Play()
		end)
	end
end

function WorldStatus.createBadge(layoutOrder: number)
	local clone = script.iconTemplate:Clone()
	clone.LayoutOrder = layoutOrder
	clone.MouseEnter:Connect(function()
		for _, guiObject in CollectionService:GetTagged("WorldStatusTooltip") do
			if guiObject:IsA("GuiObject") then
				guiObject.Visible = false
			end
		end

		clone.tooltip.Text = clone.tooltip:GetAttribute("CurrentText") or ""
		clone.tooltip.Visible = true
	end)
	clone.MouseLeave:Connect(function()
		clone.tooltip.Visible = false
	end)
	clone.tooltip:GetAttributeChangedSignal("CurrentText"):Connect(function()
		if clone.tooltip.Visible then
			clone.tooltip.Text = clone.tooltip:GetAttribute("CurrentText") or ""
		end
	end)
	clone.Parent = worldstatuses
	return clone
end

function WorldStatus.updateCategory(p: string, list)
	if not v7[p] then
		v7[p] = {}
	end

	local v8 = v7[p]
	local v9 = v3[p]

	if #v8 > #list then
		for i = #list + 1, #v8 do
			WorldStatus.removeBadge(v8[i])
			v8[i] = nil
		end
	end

	for i = 1, #list do
		if list[i] == nil then
			WorldStatus.removeBadge(v8[i])
			v8[i] = nil
		else
			local v10 = v8[i] or WorldStatus.createBadge(v9 + i)
			v8[i] = v10
			v10.Name = p .. i
			WorldStatus.updateBadge(v10, list[i])
		end
	end
end

function WorldStatus.updateAdminEvents()
	local adminEventIcon = world:FindFirstChild("AdminEventIcon")
	local adminEventText = world:FindFirstChild("AdminEventText")

	if adminEventIcon and adminEventIcon:IsA("StringValue") and adminEventText and adminEventText:IsA("StringValue") then
		WorldStatus.updateCategory("adminEvent", {
			{
				Icon = adminEventIcon.Value,
				Name = adminEventText.Value
			}
		})
	else
		WorldStatus.updateCategory("adminEvent", {})
	end
end

function WorldStatus.updateServerEvent()
	local clone = v[event.Value]

	if not clone then
		WorldStatus.updateCategory("event", {})
		return
	end

	if event:GetAttribute("EndTime") then
		clone = table.clone(clone)
		local v8 = math.max(event:GetAttribute("EndTime") - workspace:GetServerTimeNow(), 0)
		clone.Tooltip ..= string.format("\n%02d:%02d remaining", v8 // 60, v8 % 60)
	end

	WorldStatus.updateCategory("event", { clone })
end

local flag = false

function WorldStatus.updateLocalizedEvents()
	debug.profilebegin("updateLocalizedEvents")
	local v8 = {}
	local currentZoneName = ZoneController.CurrentZoneName
	flag = false

	for _, localizedevent in localizedevents do
		local attribute = workspace:GetAttribute(localizedevent.AttributeName)

		if not (attribute and table.find(localizedevent.ActiveZones, currentZoneName)) then
			continue
		end

		local tooltip = localizedevent.Tooltip

		if typeof(attribute) == "number" then
			flag = true
			local v9 = math.max(attribute - workspace:GetServerTimeNow(), 0)
			local v10 = string.format("%02d:%02d remaining", v9 // 60, v9 % 60)

			if tooltip then
				tooltip ..= "\n" .. v10
			else
				tooltip = v10
			end
		end

		table.insert(v8, {
			Icon = localizedevent.Icon,
			IconColor = localizedevent.IconColor,
			Name = localizedevent.DisplayName,
			Tooltip = tooltip
		})
	end

	WorldStatus.updateCategory("localizedEvent", v8)
	debug.profileend()
end

function WorldStatus.weatherToBadge(p: string)
	if p == "None" then
		return nil
	end

	local weather = weathers[p]

	if weather then
		return {
			Icon = weather.Icon,
			IconColor = weather.IconColor,
			Name = weather.DisplayName or weather.Name,
			Tooltip = weather.Tooltip
		}
	end

	return nil
end

function WorldStatus.updateWeather()
	local v8 = table.create(#v4)

	for k, v9 in v4 do
		v8[k] = WorldStatus.weatherToBadge(SharedWeather.GetActiveGroupWeather(v9))
	end

	WorldStatus.updateCategory("weather", v8)
end

function WorldStatus.updateCycle()
	local name = cycle.Value
	local minutesAfterMidnight = Lighting:GetAttribute("MinutesAfterMidnight") or 0
	local v8 = minutesAfterMidnight // 60
	local v9 = math.floor(minutesAfterMidnight % 60)
	local v10

	if v8 >= 12 then
		v8 -= 12
		v10 = "PM"
	else
		v10 = "AM"
	end

	local v11 = v8 == 0 and 12 or v8
	WorldStatus.updateCategory("cycle", {
		{
			Icon = v5[name],
			Name = name,
			Tooltip = string.format("%d:%02d %s", v11, v9, v10)
		}
	})
end

function WorldStatus.updateSeason()
	local name = season.Value
	WorldStatus.updateCategory("season", {
		{
			Icon = v6[name],
			Name = name
		}
	})
end

function WorldStatus.init()
	world.ChildAdded:Connect(function(child)
		if child.Name == "AdminEventIcon" or child.Name == "AdminEventText" then
			WorldStatus.updateAdminEvents()
		end
	end)
	world.ChildRemoved:Connect(function(child)
		if child.Name == "AdminEventIcon" or child.Name == "AdminEventText" then
			WorldStatus.updateAdminEvents()
		end
	end)
	event.Changed:Connect(WorldStatus.updateServerEvent)
	SharedWeather.WeatherChanged:Connect(WorldStatus.updateWeather)
	cycle.Changed:Connect(WorldStatus.updateCycle)
	Lighting:GetAttributeChangedSignal("MinutesAfterMidnight"):Connect(WorldStatus.updateCycle)
	season.Changed:Connect(WorldStatus.updateSeason)
	workspace.AttributeChanged:Connect(function(p)
		if v2[p] then
			WorldStatus.updateLocalizedEvents()
		end
	end)
	WorldStatus.updateAdminEvents()
	WorldStatus.updateServerEvent()
	WorldStatus.updateWeather()
	WorldStatus.updateCycle()
	WorldStatus.updateSeason()
	ZoneController:ObserveZone(WorldStatus.updateLocalizedEvents)
	task.spawn(function()
		while task.wait(1) do
			if flag then
				task.spawn(WorldStatus.updateLocalizedEvents)
			end

			if event:GetAttribute("EndTime") then
				task.spawn(WorldStatus.updateServerEvent)
			end
		end
	end)
end

return WorldStatus