local localPlayer = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local bestiary = legacyLocalPlayerData.fetch():WaitForChild("Bestiary")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local fish = require(ReplicatedStorage2.shared.modules:WaitForChild("library"):WaitForChild("fish"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local fx = require(ReplicatedStorage3.shared.modules:WaitForChild("fx"))
local ViewportModule = require(game.ReplicatedStorage.client.modules.ViewportModule)
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local animatedgradient = require(ReplicatedStorage4.shared.modules:WaitForChild("fx"):WaitForChild("animatedgradient"))
local Net = require(game.ReplicatedStorage.packages.Net)
local ReplicatedStorage5 = game:GetService("ReplicatedStorage")
local maid = require(ReplicatedStorage5.packages.Trove).new()
local ReplicatedStorage6 = game:GetService("ReplicatedStorage")
local locations = require(ReplicatedStorage6.shared.modules:WaitForChild("library"):WaitForChild("locations"))
local assets = require(ReplicatedStorage.shared.utils.assets)
local rarities = require(ReplicatedStorage.shared.modules.library.rarities)
local legacyControllers = ReplicatedStorage:WaitForChild("client").legacyControllers
local WorldController = require(legacyControllers.WorldController)
local currentWorldIndex = WorldController:GetCurrentWorldIndex()

function GetRealName(value)
	if fish[value:sub(4)] then
		return (value:sub(4))
	end

	return (value:sub(3))
end

function EnableUI(instance, items, _)
	local v = fish[GetRealName(instance.Name)]
	instance.fishname.Text = GetRealName(instance.Name)
	local connections = {}

	if items then
		for _, part in pairs(items) do
			if part:IsA("BasePart") then
				part.Material = Enum.Material.Neon
			end
		end
	end

	instance.vp.Image = v.Icon or ""
	instance.hidden.Visible = false

	if not bestiary:FindFirstChild(GetRealName(instance.Name)) then
		return connections
	end

	local function UpdateDiscoveredBy()
		local discoveredBy = instance:WaitForChild("discoveredBy")
		discoveredBy.Visible = false

		if not bestiary:FindFirstChild(GetRealName(instance.Name)):FindFirstChild("GivenBy") then
			local discoveredBy_2 = instance:WaitForChild("discoveredBy")
			discoveredBy_2.Visible = false
			return
		end

		local discoveredBy_3 = instance:WaitForChild("discoveredBy")
		discoveredBy_3.Visible = true
		local discoveredBy_4 = instance:WaitForChild("discoveredBy")
		discoveredBy_4.Text = "Discovered By: " .. tostring(game.Players:GetNameFromUserIdAsync(bestiary:FindFirstChild(GetRealName(instance.Name)):FindFirstChild("GivenBy").Value)) .. ""
	end

	local function UpdateSpecials()
		if bestiary:FindFirstChild(GetRealName(instance.Name)):FindFirstChild("Shiny") or bestiary:FindFirstChild(GetRealName(instance.Name)):FindFirstChild("Sparkling") then
			local sparkles = instance:WaitForChild("sparkles")
			sparkles.Enabled = true
		else
			local sparkles_2 = instance:WaitForChild("sparkles")
			sparkles_2.Enabled = false
		end
	end

	connections[1] = bestiary:FindFirstChild(GetRealName(instance.Name)).ChildAdded:Connect(function(child)
		if child.Name == "GivenBy" then
			UpdateDiscoveredBy()
			UpdateSpecials()
		end
	end)
	connections[2] = bestiary:FindFirstChild(GetRealName(instance.Name)).ChildRemoved:Connect(function(child)
		if child.Name == "GivenBy" then
			UpdateDiscoveredBy()
			UpdateSpecials()
		end
	end)

	repeat
		task.wait()
	until localPlayer:WaitForChild("DoneLoading").Value == true

	UpdateDiscoveredBy()
	UpdateSpecials()
	return connections
end

function UpdateCanvasSize(p, p2)
	p.CanvasSize = UDim2.new(0, p2.AbsoluteContentSize.X, 0, p2.AbsoluteContentSize.Y + 20)
end

local timeevents = require(game.ReplicatedStorage.shared.modules.library.timeevents)

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

local function runBestiaryLoading()
	local location = locations[script.Parent.Parent.Parent.currentHabitat.Value]

	if location then
		if timeevents.Events[location.Name] then
			local duration = {}
			local start, stop = Net:RemoteFunction("TimeEvent/GetEventTime"):InvokeServer(location.Name)

			if start then
				duration.Start = start
			end

			if stop then
				duration.Stop = stop
			end

			if duration == {} then
				duration = nil
			end

			location.Duration = duration
		end

		if location.Duration then
			local start = location.Duration.Start
			local stop = location.Duration.Stop
			local unixTimestamp = start.UnixTimestamp
			local unixTimestamp2 = stop.UnixTimestamp
			local ReplicatedStorage7 = game:GetService("ReplicatedStorage")
			local v = require(ReplicatedStorage7:WaitForChild("packages"):WaitForChild("Timer")).new(1)
			maid:Add(v.Tick:Connect(function()
				local serverTimeNow = workspace:GetServerTimeNow()

				if serverTimeNow < unixTimestamp then
					local v2 = math.clamp(unixTimestamp - serverTimeNow, 0, 1e999)
					script.Parent.Parent.Parent.timer.Text = `Starting in {ToTime(v2)}`
				elseif serverTimeNow < unixTimestamp2 then
					local v2 = math.clamp(unixTimestamp2 - serverTimeNow, 0, 1e999)
					script.Parent.Parent.Parent.timer.Text = `Leaving in {ToTime(v2)}`
				else
					script.Parent.Parent.Parent.timer.Text = "Expired"
				end
			end))
			maid:Add(v, "Destroy")
			v:StartNow()
			script.Parent.Parent.Parent.timer.Visible = true
		else
			script.Parent.Parent.Parent.timer.Visible = false
		end
	else
		script.Parent.Parent.Parent.timer.Visible = true
	end

	local v = { "Sea 1" }

	for childName, v2 in pairs(fish) do
		if v2.HideInBestiary or not table.find(v2.Worlds or v, currentWorldIndex) then
			continue
		end

		if script.Parent.Parent.Parent.currentHabitat.Value == "All" then
			if script.Parent.Parent.Parent.currentHabitat.Value == "All" then
				if fish[childName].Rarity == "Limited" or fish[childName].IsLimitedBestiary then
					continue
				end
			end
		elseif fish[childName].FromLimited then
			if fish[childName].FromLimited ~= script.Parent.Parent.Parent.currentHabitat.Value then
				continue
			end
		elseif fish[childName].From and fish[childName].From ~= script.Parent.Parent.Parent.currentHabitat.Value then
			continue
		end

		if not script.Parent.Parent.Parent.Visible then
			continue
		end

		local clone = script:WaitForChild("fish"):Clone()
		maid:Add(clone)
		local order = rarities.Rarities[fish[childName].Rarity].Order
		clone.Name = order .. " " .. childName
		clone.LayoutOrder = order
		clone.Parent = script.Parent
		clone.hidden.Visible = true
		local v3 = {}

		if bestiary:FindFirstChild(childName) then
			for _, v4 in pairs(EnableUI(clone, v3, childName)) do
				if v4 then
					maid:Add(v4)
				end
			end
		end

		local TweenService = game:GetService("TweenService")
		local tween = TweenService:Create(
			clone.hover,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{
				Size = UDim2.new(1.13, 0, 1.13, 0)
			}
		)
		tween:Play()
		maid:Add(function()
			tween:Cancel()
		end)
		clone.hover.ImageColor3 = rarities.StaticColors[fish[childName].Rarity]
		clone.fishname.TextColor3 = rarities.StaticColors[fish[childName].Rarity]

		if rarities.Rarities[fish[childName].Rarity].ColorGradient then
			clone.hover.ImageColor3 = Color3.new(1, 1, 1)
			clone.fishname.TextColor3 = Color3.new(1, 1, 1)
			local new = animatedgradient.new(rarities.Rarities[fish[childName].Rarity].ColorGradient)
			new.Parent = clone.hover
			local new_2 = animatedgradient.new(rarities.Rarities[fish[childName].Rarity].ColorGradient)
			new_2.Parent = clone.fishname
			local new_3 = animatedgradient.new(rarities.Rarities[fish[childName].Rarity].ColorGradient)
			new_3.Parent = clone.stroke
		end

		local v6 = childName
		clone.MouseEnter:Connect(function()
			local ReplicatedStorage7 = game:GetService("ReplicatedStorage")
			fx:PlaySound(
				ReplicatedStorage7:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("itemhover"),
				script.Parent,
				true
			)
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(clone.stroke, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Color = rarities.Rarities[fish[v6].Rarity].Color
			}):Play()
			local TweenService3 = game:GetService("TweenService")
			TweenService3:Create(clone.hover, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				ImageTransparency = 0
			}):Play()
		end)
		local v7 = clone
		clone.MouseLeave:Connect(function()
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(v7.stroke, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Color = Color3.fromRGB(0, 0, 0)
			}):Play()
			local TweenService3 = game:GetService("TweenService")
			TweenService3:Create(v7.hover, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				ImageTransparency = 1
			}):Play()
		end)
		local v8 = childName
		local v9 = clone
		maid:Add(bestiary.ChildAdded:Connect(function(child)
			if child.Name == v8 then
				for k, v11 in pairs(EnableUI(v9, v3, v8)) do
					if v11 then
						maid:Add(v11)
					end
				end
			end
		end))
		local v11 = clone
		local v12 = script:FindFirstAncestor("bestiary"):WaitForChild("select"):WaitForChild("frame")
		local v13 = childName
		clone:WaitForChild("button").MouseButton1Click:Connect(function()
			if v11.fishname.Text == "???" or v11.fishname.Text ~= GetRealName(v11.Name) then
				v12.stats.Visible = false
				v12.desc.Text = fish[v13].Hint
				v12.fishname.Text = "???"
				v12.rarity.Text = fish[v13].Rarity
				v12.discoveredBy.Visible = false

				if fish[v13].From == "None" or fish[v13].From == nil then
					v12.location.Visible = false
					v12.desc.Position = UDim2.new(0.5, 0, 0.757, 0)
				else
					v12.location.Visible = true
					v12.location.Text = "Location: " .. fish[v13].From
					v12.desc.Position = UDim2.new(0.5, 0, 0.807, 0)
				end

				local color = rarities.Rarities[fish[v13].Rarity].Color

				if fish[v13].Rarity == "Exotic" or fish[v13].Rarity == "Secret" then
					color = Color3.new(1, 1, 1)
				end

				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(
					v12.fishname,
					TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						TextColor3 = color
					}
				):Play()
				local TweenService3 = game:GetService("TweenService")
				TweenService3:Create(
					v12.rarity,
					TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						TextColor3 = color
					}
				):Play()
				local TweenService4 = game:GetService("TweenService")
				TweenService4:Create(
					v12.vpbg.stroke,
					TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						Color = color
					}
				):Play()
				local TweenService5 = game:GetService("TweenService")
				TweenService5:Create(
					v12.vpbg.hover,
					TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						ImageColor3 = color
					}
				):Play()
				animatedgradient.clearold(v12.fishname)
				animatedgradient.clearold(v12.rarity)
				animatedgradient.clearold(v12.vpbg.stroke)
				animatedgradient.clearold(v12.vpbg.hover)

				if fish[v13].Rarity == "Exotic" then
					v12.vpbg.stroke.UIGradient.Enabled = false
					local new = animatedgradient.new(animatedgradient._presets.Rainbow)
					new.Parent = v12.fishname
					local new_2 = animatedgradient.new(animatedgradient._presets.Rainbow)
					new_2.Parent = v12.rarity
					local new_3 = animatedgradient.new(animatedgradient._presets.Rainbow)
					new_3.Parent = v12.vpbg.stroke
					local new_4 = animatedgradient.new(animatedgradient._presets.Rainbow)
					new_4.Parent = v12.vpbg.hover
				elseif fish[v13].Rarity == "Secret" then
					v12.vpbg.stroke.UIGradient.Enabled = false
					local new_5 = animatedgradient.new(animatedgradient._presets.Secret)
					new_5.Parent = v12.fishname
					local new_6 = animatedgradient.new(animatedgradient._presets.Secret)
					new_6.Parent = v12.rarity
					local new_7 = animatedgradient.new(animatedgradient._presets.Secret)
					new_7.Parent = v12.vpbg.stroke
					local new_8 = animatedgradient.new(animatedgradient._presets.Secret)
					new_8.Parent = v12.vpbg.hover
				else
					v12.vpbg.stroke.UIGradient.Enabled = true
				end

				v12.vpbg.vp.ImageColor3 = Color3.fromRGB(0, 0, 0)
				v12.vpbg.hidden.Visible = true
				v12.vpbg.vp.Ambient = Color3.fromRGB(218, 218, 218)
				v12.vpbg.vp.LightColor = Color3.fromRGB(140, 140, 140)

				if v12.vpbg.vp:FindFirstChildWhichIsA("Camera") then
					v12.vpbg.vp:FindFirstChildWhichIsA("Camera"):Destroy()
				end

				if v12.vpbg.vp:FindFirstChild("viewmodel") then
					v12.vpbg.vp:FindFirstChild("viewmodel"):Destroy()
				end

				local camera = Instance.new("Camera")
				camera.Parent = v12.vpbg.vp
				v12.vpbg.vp.CurrentCamera = camera
				v12.Visible = true
				local none = script:FindFirstAncestor("bestiary"):WaitForChild("select"):WaitForChild("none")
				none.Visible = false
				local clone2 = assets.getAsync("fish", v13):Clone()
				clone2.Name = "viewmodel"
				clone2.Parent = v12.vpbg.vp

				for i, part in pairs(clone2:GetDescendants()) do
					if part:IsA("BasePart") and part.Material == Enum.Material.Neon then
						part.Material = Enum.Material.Plastic
					end
				end

				local v14 = ViewportModule.new(v12.vpbg.vp, camera)
				local boundingBox, v15 = clone2:GetBoundingBox()
				v14:SetModel(clone2)
				local total = 0
				local cframe = CFrame.new()
				local v16 = not fish[v13].ViewportSizeOffset and 1 or fish[v13].ViewportSizeOffset
				local v17 = v14:GetFitDistance(boundingBox.Position) * v16
				local renderSteppedConnection = nil
				local RunService = game:GetService("RunService")
				renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
					if not clone2 or v12.fishname.Text ~= "???" or clone2 == nil then
						renderSteppedConnection:Disconnect()
						return
					end

					if clone2.Parent ~= v12.vpbg.vp then
						renderSteppedConnection:Disconnect()
						return
					end

					total += math.rad(20 * dt)
					cframe = CFrame.fromEulerAnglesYXZ(0, total, 0.4363323129985824)
					camera.CFrame = CFrame.new(boundingBox.Position) * cframe * CFrame.new(0, 0, v17)
				end)
				maid:Add(renderSteppedConnection)
			else
				v12.stats.Visible = true

				if fish[v13].FavouriteBait == "None" then
					v12.stats.Bait.Visible = false
				else
					v12.stats.Bait.Visible = true
					v12.stats.Bait.Text = "☆  Bait: " .. (fish[v13].FavouriteBait or "")
				end

				if fish[v13].FavouriteTime then
					v12.stats.DTime.Visible = true
					v12.stats.DTime.Text = "☆  Time: " .. (fish[v13].FavouriteTime or "")
				else
					v12.stats.DTime.Visible = false
				end

				if fish[v13].Weather[1] == "None" then
					v12.stats.CWeather.Visible = false
				else
					v12.stats.CWeather.Visible = true

					if #fish[v13].Seasons > 1 then
						v12.stats.CWeather.Text = "☆  Weathers: " .. table.concat(fish[v13].Weather, ", ")
					else
						v12.stats.CWeather.Text = "☆  Weather: " .. table.concat(fish[v13].Weather, ", ")
					end
				end

				if fish[v13].Seasons[1] == "None" then
					v12.stats.ZSeason.Visible = false
				else
					v12.stats.ZSeason.Visible = true

					if #fish[v13].Seasons > 1 then
						v12.stats.ZSeason.Text = "☆  Seasons: " .. table.concat(fish[v13].Seasons, ", ")
					else
						v12.stats.ZSeason.Text = "☆  Season: " .. table.concat(fish[v13].Seasons, ", ")
					end
				end

				if fish[v13].From == "None" or fish[v13].From == nil then
					v12.location.Visible = false
					v12.desc.Position = UDim2.new(0.5, 0, 0.757, 0)
				else
					v12.location.Visible = true
					v12.location.Text = "Location: " .. fish[v13].From
					v12.desc.Position = UDim2.new(0.5, 0, 0.807, 0)
				end

				if bestiary:FindFirstChild(v13) then
					if bestiary:FindFirstChild(v13):FindFirstChild("HighestWeight") then
						v12.stats.AHighestSeen.Visible = true
						v12.stats.AHighestSeen.Text = "Largest Caught: " .. bestiary:FindFirstChild(v13):FindFirstChild("HighestWeight").Value .. "kg"
					else
						v12.stats.AHighestSeen.Visible = false
					end

					if bestiary:FindFirstChild(v13):FindFirstChild("GivenBy") then
						v12.discoveredBy.Visible = true
						v12.discoveredBy.Text = "Discovered By: " .. tostring(game.Players:GetNameFromUserIdAsync(bestiary:FindFirstChild(v13):FindFirstChild("GivenBy").Value)) .. ""
					else
						v12.discoveredBy.Visible = false
					end

					if bestiary:FindFirstChild(v13).Value == nil or bestiary:FindFirstChild(v13) == 0 then
						v12.stats.AHighestSeen.Visible = false
					else
						v12.stats.AHighestSeen.Visible = true
						local v14 = os.date("!*t", bestiary:FindFirstChild(v13).Value)
						v12.stats.ADate.Text = "Date Discovered: " .. ("%02i"):format(v14.month) .. "/" .. ("%02i"):format(v14.day) .. "/" .. v14.year
					end

					if bestiary:FindFirstChild(v13):FindFirstChild("Shiny") then
						if bestiary:FindFirstChild(v13):FindFirstChild("Shiny").Value == nil or bestiary:FindFirstChild(v13):FindFirstChild("Shiny").Value == 0 then
							v12.stats.AShiny.Visible = false
						else
							v12.stats.AShiny.Visible = true
							local v14 = os.date("!*t", bestiary:FindFirstChild(v13).Value)
							v12.stats.AShiny.Text = "Shiny: " .. ("%02i"):format(v14.month) .. "/" .. ("%02i"):format(v14.day) .. "/" .. v14.year
						end
					else
						v12.stats.AShiny.Visible = false
					end

					if bestiary:FindFirstChild(v13):FindFirstChild("Sparkling") then
						if bestiary:FindFirstChild(v13):FindFirstChild("Sparkling").Value == nil or bestiary:FindFirstChild(v13):FindFirstChild("Sparkling").Value == 0 then
							v12.stats.ASparkling.Visible = false
						else
							v12.stats.ASparkling.Visible = true
							local v14 = os.date("!*t", bestiary:FindFirstChild(v13).Value)
							v12.stats.ASparkling.Text = "Sparkling: " .. ("%02i"):format(v14.month) .. "/" .. ("%02i"):format(v14.day) .. "/" .. v14.year
						end
					else
						v12.stats.ASparkling.Visible = false
					end
				end

				v12.desc.Text = fish[v13].Description
				v12.fishname.Text = GetRealName(v11.Name)
				v12.rarity.Text = fish[v13].Rarity
				local color = rarities.Rarities[fish[v13].Rarity].Color

				if rarities.Rarities[fish[v13].Rarity].ColorGradient ~= nil then
					color = Color3.new(1, 1, 1)
				end

				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(
					v12.fishname,
					TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						TextColor3 = color
					}
				):Play()
				local TweenService3 = game:GetService("TweenService")
				TweenService3:Create(
					v12.rarity,
					TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						TextColor3 = color
					}
				):Play()
				local TweenService4 = game:GetService("TweenService")
				TweenService4:Create(
					v12.vpbg.stroke,
					TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						Color = color
					}
				):Play()
				local TweenService5 = game:GetService("TweenService")
				TweenService5:Create(
					v12.vpbg.hover,
					TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						ImageColor3 = color
					}
				):Play()
				animatedgradient.clearold(v12.fishname)
				animatedgradient.clearold(v12.rarity)
				animatedgradient.clearold(v12.vpbg.stroke)
				animatedgradient.clearold(v12.vpbg.hover)

				if fish[v13].Rarity == "Exotic" then
					v12.vpbg.stroke.UIGradient.Enabled = false
					local new_9 = animatedgradient.new(animatedgradient._presets.Rainbow)
					new_9.Parent = v12.fishname
					local new_10 = animatedgradient.new(animatedgradient._presets.Rainbow)
					new_10.Parent = v12.rarity
					local new_11 = animatedgradient.new(animatedgradient._presets.Rainbow)
					new_11.Parent = v12.vpbg.stroke
					local new_12 = animatedgradient.new(animatedgradient._presets.Rainbow)
					new_12.Parent = v12.vpbg.hover
				elseif fish[v13].Rarity == "Secret" then
					v12.vpbg.stroke.UIGradient.Enabled = false
					local new_13 = animatedgradient.new(animatedgradient._presets.Secret)
					new_13.Parent = v12.fishname
					local new_14 = animatedgradient.new(animatedgradient._presets.Secret)
					new_14.Parent = v12.rarity
					local new_15 = animatedgradient.new(animatedgradient._presets.Secret)
					new_15.Parent = v12.vpbg.stroke
					local new_16 = animatedgradient.new(animatedgradient._presets.Secret)
					new_16.Parent = v12.vpbg.hover
				else
					v12.vpbg.stroke.UIGradient.Enabled = true
				end

				v12.vpbg.vp.ImageColor3 = Color3.fromRGB(255, 255, 255)
				v12.vpbg.hidden.Visible = false
				v12.vpbg.vp.Ambient = Color3.fromRGB(218, 218, 218)
				v12.vpbg.vp.LightColor = Color3.fromRGB(140, 140, 140)

				if v12.vpbg.vp:FindFirstChildWhichIsA("Camera") then
					v12.vpbg.vp:FindFirstChildWhichIsA("Camera"):Destroy()
				end

				if v12.vpbg.vp:FindFirstChild("viewmodel") then
					v12.vpbg.vp:FindFirstChild("viewmodel"):Destroy()
				end

				local camera = Instance.new("Camera")
				camera.Parent = v12.vpbg.vp
				v12.vpbg.vp.CurrentCamera = camera
				local clone2 = assets.getAsync("fish", v13):Clone()
				clone2.Name = "viewmodel"
				clone2.Parent = v12.vpbg.vp
				local v14 = ViewportModule.new(v12.vpbg.vp, camera)
				local boundingBox, v15 = clone2:GetBoundingBox()
				v14:SetModel(clone2)
				local total = 0
				local cframe = CFrame.new()
				local v16 = not fish[v13].ViewportSizeOffset and 1 or fish[v13].ViewportSizeOffset
				local v17 = v14:GetFitDistance(boundingBox.Position) * v16
				local renderSteppedConnection = nil
				local RunService = game:GetService("RunService")
				renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
					if not clone2 or v12.fishname.Text ~= v13 or clone2 == nil then
						renderSteppedConnection:Disconnect()
						return
					end

					if clone2.Parent ~= v12.vpbg.vp then
						renderSteppedConnection:Disconnect()
						return
					end

					total += math.rad(20 * dt)
					cframe = CFrame.fromEulerAnglesYXZ(0, total, 0.4363323129985824)
					camera.CFrame = CFrame.new(boundingBox.Position) * cframe * CFrame.new(0, 0, v17)
				end)
				maid:Add(renderSteppedConnection)
				v12.Visible = true
				local none_2 = script:FindFirstAncestor("bestiary"):WaitForChild("select"):WaitForChild("none")
				none_2.Visible = false
			end
		end)

		if fish[childName].Rarity == "Secret" then
			clone.Visible = bestiary:FindFirstChild(childName)
		end

		local v14 = script.Parent.Parent.Parent:WaitForChild("currentHabitat")
		local v15 = childName
		local v16 = clone
		maid:Add(script.Parent.Parent:WaitForChild("search").Changed:Connect(function()
			local search = script.Parent.Parent:WaitForChild("search")
			local text = string.lower(search.Text)

			if text == "" or text == nil or text == " " then
				if v14.Value == "All" or fish[v15].From == v14.Value then
					if fish[v15].Rarity == "Secret" then
						v16.Visible = bestiary:FindFirstChild(v15)
					else
						v16.Visible = true
					end
				end
			else
				if v14.Value ~= "All" and fish[v15].From ~= v14.Value then
					v16.Visible = false
					return
				end

				local visible = string.find(string.lower(v16.fishname.Text), text)

				if fish[v15].Rarity == "Secret" then
					v16.Visible = visible and bestiary:FindFirstChild(v15)
				else
					v16.Visible = visible
				end
			end
		end))
	end
end

script.Parent.Parent.Parent.currentHabitat:GetPropertyChangedSignal("Value"):Connect(function()
	maid:Clean()
	runBestiaryLoading()
end)
script.Parent.Parent.Parent.Changed:Connect(function()
	if script.Parent.Parent.Parent.Visible == false then
		local frame = script:FindFirstAncestor("bestiary"):WaitForChild("select"):WaitForChild("frame")
		frame.Visible = false
		local none = script:FindFirstAncestor("bestiary"):WaitForChild("select"):WaitForChild("none")
		none.Visible = true
		local search = script.Parent.Parent:WaitForChild("search")
		search.Text = ""
		maid:Destroy()
	end
end)
script.Parent.ChildRemoved:Connect(function()
	UpdateCanvasSize(script.Parent, script.Parent.UIGridLayout)
end)
script.Parent.ChildAdded:Connect(function()
	UpdateCanvasSize(script.Parent, script.Parent.UIGridLayout)
end)
local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
	UpdateCanvasSize(script.Parent, script.Parent.UIGridLayout)
end)