local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local packages = ReplicatedStorage.packages
local resources = ReplicatedStorage.resources
local sounds = resources.sounds
local shared = ReplicatedStorage.shared
local modules = shared.modules
local localPlayer = Players.LocalPlayer
local select = script.Parent.Parent.select
local fish_frame = select.fish_frame
local stats = fish_frame.stats
local vpbg = fish_frame.vpbg
local rod_frame = select.rod_frame
local _ = rod_frame.stats
local vpbg2 = rod_frame.vpbg
local scroll = script.Parent.Parent.fish.scroll
local WorldController = require(legacyControllers.WorldController)
local Trove = require(packages.Trove)
local Replion = require(packages.Replion)
local GeneralUtils = require(shared.utils.GeneralUtils)
require(script.Parent.Types)
WorldController:GetCurrentWorldIndex()
WorldController:GetCurrentWorldBestiary()
local animatedgradient = require(modules.fx.animatedgradient)
local assets = require(shared.utils.assets)
local fish = require(modules.library.fish)
local rods = require(modules.library.rods)
local rarities = require(modules.library.rarities)
local fishing = require(modules.fishing)
local NumberUtils = require(modules.NumberUtils)
local fx = require(modules.fx)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local locations = require(modules.library.locations)
require(modules.library.timeevents)
local ViewportModule = require(ReplicatedStorage.client.modules.ViewportModule)
local DataController = require(legacyControllers.DataController)
local GeneralUIModule = require(shared.modules.GeneralUIModule)
local playerDataReplicator = DataController.PlayerDataReplicator
local bestiaryReplicator = DataController.BestiaryReplicator
playerDataReplicator:WaitForLoaded()
bestiaryReplicator:WaitForLoaded()
local index = bestiaryReplicator:Index({ "Bestiary" })
legacyLocalPlayerData.fetch()
local rods2 = playerDataReplicator.Data and playerDataReplicator.Data.Rods
local Net = require(packages.Net)
local remoteEvent = Net:RemoteEvent("RodJournal/ClaimRodReward")
local v = Replion.Client:WaitReplion("LimitedStockItems")
local v2 = {}
local mouseButton1ClickConnection = nil
local _ = ReplicatedStorage.resources
local sfx = resources.sounds.sfx
local FishInventory = {
	fishInventoryTrove = Trove.new(),
	currentSelected = nil,
	currentType = "fish"
}
local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateCanvasSize(p, uIGridLayout)
	p.CanvasSize = UDim2.new(0, uIGridLayout.AbsoluteContentSize.X, 0, uIGridLayout.AbsoluteContentSize.Y + 20)
end

function GetRealName(value)
	if fish[value:sub(4)] then
		return (value:sub(4))
	end

	return (value:sub(3))
end

DataController.PlayerDataReplicator:Observe({ "RodJournal" }, function(p)
	if not (p and p.ClaimedRods) then
		return
	end

	for k, v4 in v2 do
		if not table.find(p.ClaimedRods, k) then
			continue
		end

		local indicator = v4:FindFirstChild("indicator")

		if indicator then
			indicator.Visible = false
		end

		v2[k] = nil
	end
end)

function FishInventory:UpdateSearch(p, items, p2, p3)
	for _, item in items do
		for _, location in item.locations do
			for _, v4 in pairs(location.bestiary) do
				v4.frame.Parent = nil

				for _, connection in v4.connections do
					connection:Disconnect()
				end

				if v4.cleanCallback then
					v4.cleanCallback()
				end
			end
		end
	end

	local v4 = p2 and items[p2]

	if not v4 then
		return
	end

	local function searchInLocation(p4, flag: boolean?)
		if not (p4 and p4.bestiary) then
			return
		end

		local v5 = {}

		for k, v6 in pairs(p4.bestiary) do
			if v6.Type == "fish" and FishInventory.currentType == "fish" then
				local v7 = index[k]
				local v8 = not p or string.find(string.lower(k), p) ~= nil

				if flag ~= nil and flag then
					v8 = flag
				end

				local v9 = v6.frame.Parent == scroll
				local v10 = fish[k]

				if p == "" or p == nil or p == " " then
					if v10 and v10.HideInBestiary then
						v8 = false
					elseif v10 and v10.Rarity == "Secret" or v10.Rarity == "Special" or v10.Rarity == "Apex" or v10.Rarity == "Divine Secret" then
						v8 = v8 and v7 ~= nil
					end
				else
					v8 = v8 and v7 ~= nil
				end

				v5[v6.frame] = v8

				if v9 ~= true and v8 then
					if v7 then
						self:LoadFishFrameConnections(v6)
					end

					local colorGradient = rarities.Rarities[v10.Rarity] and rarities.Rarities[v10.Rarity].ColorGradient

					if colorGradient then
						local new = animatedgradient.new(colorGradient)
						new.Parent = v6.frame.fishname
						local new_2 = animatedgradient.new(colorGradient)
						new_2.Parent = v6.frame.stroke
						local new_3 = animatedgradient.new(colorGradient)
						new_3.Parent = v6.frame.hover
					else
						vpbg.stroke.UIGradient.Enabled = true
					end

					-- equivalent calls inferred from this helper; original call sites unknown
					local v11 = v6

					local function clear()
						animatedgradient.clearold(v11.frame.fishname)
						animatedgradient.clearold(v11.frame.stroke)
						animatedgradient.clearold(v11.frame.hover)

						if v11.cleanCallback then
							v11.cleanCallback = nil
						end
					end

					local v12 = v6

					function v6.cleanCallback()
						clear() -- equivalent call inferred; original call site unknown
					end

					if self.fishInventoryTrove then
						local v13 = v6
						self.fishInventoryTrove:Add(function()
							for k2, connection in v13.connections do
								connection:Disconnect()
							end

							clear() -- equivalent call inferred; original call site unknown
						end)
					end
				end
			elseif v6.Type == "rod" and FishInventory.currentType == "rod" then
				local v7 = rods2 and rods2[k]
				local v8 = not p or string.find(string.lower(k), p) ~= nil

				if flag ~= nil and flag then
					v8 = flag
				end

				local v9 = v6.frame.Parent == scroll
				local _ = fish[k]

				if p ~= "" and p ~= nil and p ~= " " then
					v8 = v8 and v7 ~= nil
				end

				v5[v6.frame] = v8

				if v9 ~= true and v8 then
					if v7 then
						v6.frame.vp.Visible = true
						v6.frame.hidden.Visible = false
						v6.frame.rodname.Text = k

						if rods[k].DiscoveryRewards and not v2[k] then
							local v10 = k
							local v11 = v6
							task.spawn(function()
								DataController.PlayerDataReplicator:WaitForLoaded()
								local v12 = DataController.PlayerDataReplicator:TryIndex({ "RodJournal", "ClaimedRods" })

								if not (v12 and table.find(v12, v10)) then
									v11.frame.indicator.Visible = true
									v2[v10] = v11.frame
								end
							end)
						end
					else
						v6.frame.vp.Visible = false
						v6.frame.hidden.Visible = true
						v6.frame.rodname.Text = "???"
					end

					-- equivalent calls inferred from this helper; original call sites unknown
					local v10 = v6

					local function clear()
						if v10.cleanCallback then
							v10.cleanCallback = nil
						end
					end

					local v11 = v6

					function v6.cleanCallback()
						clear() -- equivalent call inferred; original call site unknown
					end

					if self.fishInventoryTrove then
						local v12 = v6
						self.fishInventoryTrove:Add(function()
							for k2, connection in v12.connections do
								connection:Disconnect()
							end

							clear() -- equivalent call inferred; original call site unknown
						end)
					end
				end
			end
		end

		for k, v6 in v5 do
			if v6 then
				k.Parent = scroll
			end
		end
	end

	if p3 == "All" then
		for _, location in v4.locations do
			searchInLocation(location)
		end
	elseif p3 == "The Deep" then
		for _, v5 in { "Gloomy Crevice", "Lower Deep", "Outer Deep" } do
			searchInLocation(v4.locations[v5])
		end
	else
		local v5 = p3 and v4.locations[p3]

		if v5 then
			searchInLocation(v5)
		end
	end

	UpdateCanvasSize(scroll, scroll.UIGridLayout) -- equivalent call inferred; original call site unknown
end

function FishInventory:UpdateSelect(p, p2, p3, p4)
	if self.currentSelected and self.currentSelected == p2 and p4 ~= true then
		return
	end

	select.none.Visible = true
	select.none.Text = p == "fish" and "Select a fish to view its info" or p == "rod" and "Select a rod to view its info" or false
	rod_frame.Visible = false
	rod_frame.desc.Text = ""
	rod_frame.rodname.Text = ""
	fish_frame.Visible = false
	fish_frame.desc.Text = ""
	fish_frame.fishname.Text = ""
	fish_frame.rarity.Text = ""

	if self.selectedTrove then
		self.fishInventoryTrove:Remove(self.selectedTrove)
	end

	local camera = vpbg.vp:FindFirstChildWhichIsA("Camera")

	if camera then
		camera:Destroy()
	end

	local viewModel = vpbg.vp:FindFirstChild("viewModel")

	if viewModel then
		viewModel:Destroy()
	end

	self.currentSelected = p2

	if p == "fish" then
		local v4 = p2 and fish[p2]

		if not v4 then
			return
		end

		select.none.Visible = false
		local maid = self.fishInventoryTrove:Extend()
		self.selectedTrove = maid
		fish_frame.Visible = true
		fish_frame.discoveredBy.Visible = false
		fish_frame.desc.Text = v4.Hint
		fish_frame.fishname.Text = "???"
		stats.Visible = false
		vpbg.hidden.Visible = true
		vpbg.vp.ImageColor3 = Color3.fromRGB(0, 0, 0)
		vpbg.vp.Ambient = Color3.fromRGB(218, 218, 218)
		vpbg.vp.LightColor = Color3.fromRGB(140, 140, 140)
		fish_frame.rarity.Text = v4.Rarity

		if v4.From == "None" or v4.From == nil then
			fish_frame.location.Visible = false
			fish_frame.desc.Position = UDim2.new(0.5, 0, 0.757, 0)
		else
			fish_frame.location.Visible = true
			fish_frame.location.Text = "Location: " .. v4.From
			fish_frame.desc.Position = UDim2.new(0.5, 0, 0.807, 0)
		end

		local color = v4.Rarity and rarities.Rarities[v4.Rarity].Color or Color3.new(0, 0, 0)

		if rarities.Rarities[v4.Rarity].ColorGradient then
			color = Color3.new(1, 1, 1)
		end

		GeneralUtils.fastTween(
			fish_frame.fishname,
			TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				TextColor3 = color
			}
		)
		GeneralUtils.fastTween(
			fish_frame.rarity,
			TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				TextColor3 = color
			}
		)
		GeneralUtils.fastTween(vpbg.stroke, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Color = color
		})
		GeneralUtils.fastTween(vpbg.hover, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			ImageColor3 = color
		})
		vpbg.stroke.UIGradient.Enabled = false
		local colorGradient = rarities.Rarities[v4.Rarity] and rarities.Rarities[v4.Rarity].ColorGradient

		if colorGradient then
			local new = animatedgradient.new(colorGradient)
			new.Parent = fish_frame.fishname
			local new_2 = animatedgradient.new(colorGradient)
			new_2.Parent = fish_frame.rarity
			local new_3 = animatedgradient.new(colorGradient)
			new_3.Parent = vpbg.stroke
			local new_4 = animatedgradient.new(colorGradient)
			new_4.Parent = vpbg.hover
		else
			vpbg.stroke.UIGradient.Enabled = true
		end

		maid:Add(function()
			animatedgradient.clearold(fish_frame.fishname)
			animatedgradient.clearold(fish_frame.rarity)
			animatedgradient.clearold(vpbg.stroke)
			animatedgradient.clearold(vpbg.hover)
		end)
		local clone = maid:Clone(assets.getAsync("fish", p2))
		clone.Name = "viewModel"
		clone.Parent = vpbg.vp

		for _, part in pairs(clone:GetDescendants()) do
			if part:IsA("BasePart") and part.Material == Enum.Material.Neon then
				part.Material = Enum.Material.Plastic
			end
		end

		local currentCamera = maid:Add(Instance.new("Camera"))
		vpbg.vp.CurrentCamera = currentCamera
		currentCamera.Parent = vpbg.vp
		local v6 = ViewportModule.new(vpbg.vp, currentCamera)
		local boundingBox, _ = clone:GetBoundingBox()
		v6:SetModel(clone)
		local total = 0
		local cframe = CFrame.new()
		local v7 = not v4.ViewportSizeOffset and 1 or v4.ViewportSizeOffset
		local v8 = v6:GetFitDistance(boundingBox.Position) * v7
		local v9 = index[p2]
		maid:Connect(RunService.RenderStepped, function(p5)
			if clone and (fish_frame.fishname.Text == "???" or fish_frame.fishname.Text == p2) and clone ~= nil then
				if clone.Parent == vpbg.vp then
					total += math.rad(20 * p5)
					cframe = CFrame.fromEulerAnglesYXZ(0, total, 0.4363323129985824)
					currentCamera.CFrame = CFrame.new(boundingBox.Position) * cframe * CFrame.new(0, 0, v8)
				elseif self.selectedTrove then
					self.fishInventoryTrove:Remove(self.selectedTrove)
				end
			elseif self.selectedTrove then
				self.fishInventoryTrove:Remove(self.selectedTrove)
			end
		end)

		if p3 and p3.fishname.Text ~= "???" and p3.fishname.Text == p2 then
			stats.Visible = true

			if v4.FavouriteBait and v4.FavouriteBait ~= "None" then
				stats.Bait.Visible = true

				if typeof(v4.FavouriteBait) == "table" then
					stats.Bait.Text = "☆  Bait: " .. table.concat(v4.FavouriteBait, ", ")
				else
					stats.Bait.Text = "☆  Bait: " .. (v4.FavouriteBait or "")
				end
			else
				stats.Bait.Visible = false
			end

			if v4.FavouriteTime and v4.FavouriteTime ~= "None" then
				stats.DTime.Visible = true
				stats.DTime.Text = "☆  Time: " .. (v4.FavouriteTime or "")
			else
				stats.DTime.Visible = false
			end

			local weather = v4.Weather

			if weather[1] and weather[1] ~= "None" then
				stats.CWeather.Visible = true

				if #weather > 1 then
					stats.CWeather.Text = "☆  Weathers: " .. table.concat(weather, ", ")
				else
					stats.CWeather.Text = "☆  Weather: " .. table.concat(weather, ", ")
				end
			else
				stats.CWeather.Visible = false
			end

			local seasons = v4.Seasons

			if seasons and seasons[1] and seasons[1] ~= "None" then
				stats.ZSeason.Visible = true

				if #seasons > 1 then
					stats.ZSeason.Text = "☆  Seasons: " .. table.concat(seasons, ", ")
				else
					stats.ZSeason.Text = "☆  Season: " .. table.concat(seasons, ", ")
				end
			else
				stats.ZSeason.Visible = false
			end

			local v10 = v4.From and locations[v4.From]

			if v4.From == "None" or v4.From == nil or not v10 then
				fish_frame.location.Visible = false
				fish_frame.desc.Position = UDim2.new(0.5, 0, 0.757, 0)
			else
				fish_frame.location.Visible = true
				fish_frame.location.Text = "Location: " .. v10.Name
				fish_frame.desc.Position = UDim2.new(0.5, 0, 0.807, 0)
			end

			if v9 then
				local highestWeight = v9.HighestWeight

				if highestWeight then
					stats.AHighestSeen.Visible = true
					stats.AHighestSeen.Text = `Largest Caught: {highestWeight}kg`
				else
					stats.AHighestSeen.Visible = false
				end

				local givenBy = v9.GivenBy

				if givenBy then
					local v11 = v3[givenBy]

					if not v11 then
						local success, result = pcall(function()
							return Players:GetNameFromUserIdAsync(givenBy)
						end)

						if success and result then
							v3[givenBy] = result
							v11 = result
						end
					end

					fish_frame.discoveredBy.Visible = true
					fish_frame.discoveredBy.Text = `Discovered By: {v11}`
				else
					fish_frame.discoveredBy.Visible = false
				end

				if v9.Discovered == nil or v9.Discovered == 0 then
					stats.AHighestSeen.Visible = false
				else
					stats.AHighestSeen.Visible = true
					local v11 = os.date("!*t", v9.Discovered)
					stats.ADate.Text = "Date Discovered: " .. ("%02i"):format(v11.month) .. "/" .. ("%02i"):format(v11.day) .. "/" .. v11.year
				end

				local shiny = v9.Shiny

				if shiny then
					if shiny == nil or shiny == 0 then
						stats.AShiny.Visible = false
					else
						stats.AShiny.Visible = true
						local v11 = os.date("!*t", shiny)
						stats.AShiny.Text = "Shiny: " .. ("%02i"):format(v11.month) .. "/" .. ("%02i"):format(v11.day) .. "/" .. v11.year
					end
				else
					stats.AShiny.Visible = false
				end

				local sparkling = v9.Sparkling

				if sparkling then
					if sparkling == nil or sparkling == 0 then
						stats.ASparkling.Visible = false
					else
						stats.ASparkling.Visible = true
						local v11 = os.date("!*t", sparkling)
						stats.ASparkling.Text = "Sparkling: " .. ("%02i"):format(v11.month) .. "/" .. ("%02i"):format(v11.day) .. "/" .. v11.year
					end
				else
					stats.ASparkling.Visible = false
				end
			end

			if rarities.Rarities[v4.Rarity] and rarities.Rarities[v4.Rarity].HasSerial then
				stats.ASpecialExists.Text = "☆ Exists: .."
				stats.ASpecialExists.Visible = true
				local expect = nil
				local success, result = pcall(function()
					expect = v:GetExpect({ "Stocks", p2 })
				end)

				if result then
					warn(result)
				end

				local formatted = `☆  Exists: {expect}`
				stats.ASpecialExists.Text = not success and "☆  ?" or formatted
			else
				stats.ASpecialExists.Visible = false
			end

			fish_frame.fishname.Text = p2
			fish_frame.desc.Text = v4.Description
			fish_frame.rarity.Text = v4.Rarity
			vpbg.vp.ImageColor3 = Color3.fromRGB(255, 255, 255)
			vpbg.hidden.Visible = false
			vpbg.vp.Ambient = Color3.fromRGB(218, 218, 218)
			vpbg.vp.LightColor = Color3.fromRGB(140, 140, 140)
		end
	elseif p == "rod" then
		local v4 = p2 and rods[p2]

		if not v4 then
			return
		end

		select.none.Visible = false
		rod_frame.Visible = true
		rod_frame.desc.Text = v4.Hint or "???"
		rod_frame.rodname.Text = "???"
		rod_frame.stats.Visible = false
		vpbg2.hidden.Visible = true
		vpbg2.vp.Image = ""
		vpbg2.vp.ImageColor3 = Color3.fromRGB(0, 0, 0)
		rod_frame.location.Visible = true
		rod_frame.location.Text = `From: {(v4.From == "None" or v4.From == nil) and "Unspecified" or v4.From or "Unspecified"}`
		local color = v4.Color ~= Color3.fromRGB(0, 0, 0) and v4.Color or Color3.new(0, 0, 0)
		GeneralUtils.fastTween(
			rod_frame.rodname,
			TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				TextColor3 = color
			}
		)
		GeneralUtils.fastTween(vpbg2.stroke, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Color = color
		})
		GeneralUtils.fastTween(vpbg2.hover, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			ImageColor3 = color
		})
		local clone = table.clone(rods[p2])
		local clone2 = table.clone(fishing:GetRodStats(localPlayer, p2))
		clone.Lure = (clone.Lure or 0) + (100 - clone.LureSpeed)
		clone2.Lure = (clone2.Lure or 0) + (100 - clone2.LureSpeed)
		local v5 = rods2 and rods2[p2]
		local caught = v5 and v5.caught
		vpbg2.vp.Image = v4.Icon or ""
		local stats2 = rod_frame.stats
		rod_frame.claim.Visible = false

		if v5 then
			stats2.Caught.Visible = caught ~= nil

			if caught then
				stats2.Caught.Text = `Fish Caught: {NumberUtils:Comma(caught or 0)}`
			end

			stats2.Luck.Text = `Luck: {clone.Luck}%`
			stats2.LureSpeed.Text = `Lure Speed: {clone.Lure}%`
			stats2.Control.Text = `Control: {math.round(clone.Control * 1000) / 1000}`
			stats2.Strength.Text = `Max Kg: {NumberUtils:Comma(clone.Strength)}kg`
			stats2.Resilience.Text = `Resilience: {clone.Resilience}%`

			if clone2.ProgressSpeed and clone2.ProgressSpeed ~= 0 then
				stats2.ProgressSpeed.Text = string.format("Progress Speed: %+.0f%%", clone2.ProgressSpeed)
				stats2.ProgressSpeed.Visible = true
			else
				stats2.ProgressSpeed.Visible = false
			end

			stats2.Visible = true
			rod_frame.rodname.Text = p2
			vpbg2.hidden.Visible = false
			vpbg2.vp.ImageColor3 = Color3.fromRGB(255, 255, 255)
			DataController.PlayerDataReplicator:WaitForLoaded()
			local v6 = DataController.PlayerDataReplicator:TryIndex({ "RodJournal", "ClaimedRods" })
			local index2 = v6 and table.find(v6, p2)
			local discoveryRewards = clone.DiscoveryRewards

			if mouseButton1ClickConnection then
				mouseButton1ClickConnection:Disconnect()
				mouseButton1ClickConnection = nil
			end

			if discoveryRewards and not index2 then
				rod_frame.claim.title.Text = "Claim Rewards"
				rod_frame.claim.Visible = true
				rod_frame.vpbg.vp.ImageColor3 = Color3.fromRGB(84, 84, 84)
				mouseButton1ClickConnection = rod_frame.claim.MouseButton1Click:Once(function()
					remoteEvent:FireServer(p2)
					rod_frame.claim.Visible = false
					mouseButton1ClickConnection = nil
					TweenService:Create(rod_frame.vpbg.vp, TweenInfo.new(0.5), {
						ImageColor3 = Color3.fromRGB(255, 255, 255)
					}):Play()
					sfx.ui.claimReward:Play()
					GeneralUIModule:FadedBorder(Color3.fromRGB(60, 180, 75), 0.5, 1.2)
				end)
			else
				rod_frame.vpbg.vp.ImageColor3 = Color3.fromRGB(255, 255, 255)
				rod_frame.claim.Visible = false
			end
		end
	end
end

function FishInventory:LoadFishFrameConnections(p2)
	local frame = p2.frame
	local realName = frame and frame:GetAttribute("RealName")

	if not realName then
		return
	end

	local v4 = {}
	local v5 = fish[realName]
	frame.fishname.Text = realName
	frame.vp.Image = v5.Icon or ""
	frame.hidden.Visible = false
	local discoveredBy = frame.discoveredBy
	local v6 = index[realName]

	if not v6 then
		return v4
	end

	local function UpdateDiscoveredBy()
		discoveredBy.Visible = false
		local givenBy = v6.GivenBy

		if givenBy then
			local v7 = v3[givenBy]

			if not v7 then
				local success, result = pcall(function()
					return Players:GetNameFromUserIdAsync(givenBy)
				end)

				if success and result then
					v3[givenBy] = result
					v7 = result
				end
			end

			discoveredBy.Visible = true
			discoveredBy.Text = `Discovered By: {v7}`
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateSpecials()
		local shiny = v6.Shiny
		local sparkling = v6.Sparkling

		if shiny or sparkling then
			frame.sparkles.Enabled = true
		else
			frame.sparkles.Enabled = false
		end
	end

	v4[1] = self.fishInventoryTrove:Add(bestiaryReplicator:Listen({ "Bestiary", realName }, function(_)
		UpdateDiscoveredBy()
		UpdateSpecials() -- equivalent call inferred; original call site unknown
	end))

	if not localPlayer:WaitForChild("DoneLoading").Value then
		localPlayer:WaitForChild("DoneLoading").Changed:Wait()
	end

	UpdateDiscoveredBy()
	local shiny = v6.Shiny
	local sparkling = v6.Sparkling

	if shiny or sparkling then
		frame.sparkles.Enabled = true
		return v4
	end

	frame.sparkles.Enabled = false
	return v4
end

function FishInventory:LoadBestiary(items)
	if not items then
		return
	end

	local _ = { "Sea 1" }

	for k, v4 in pairs(fish) do
		if k == "Rarities" then
			continue
		end

		local v5 = nil
		local v6 = nil

		if not v4.From then
			continue
		end

		local flag = false

		for k2, item in items do
			for k3, _ in pairs(item.locations) do
				if v4.From ~= k3 then
					continue
				end

				v6 = k3
				v5 = k2
				flag = true
				break
			end
		end

		if not flag then
			continue
		end

		local index2 = table.find(rarities.OrderedRarityNames, fish[k].Rarity)
		local clone = script.fishTemplate:Clone()
		clone.Name = `{string.format("%02d", index2 or 0)} {k}`
		clone:SetAttribute("RealName", k)
		clone.LayoutOrder = index2
		clone.hidden.Visible = true
		clone.Parent = nil
		local v7 = {
			frame = clone,
			connections = {},
			Type = "fish"
		}
		items[v5].locations[v6].bestiary[k] = v7

		if index[k] then
			self:LoadFishFrameConnections(v7)
		end

		local size = clone.hover.Size
		local fastTween = GeneralUtils.fastTween(
			clone.hover,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{
				Size = UDim2.new(1.13, 0, 1.13, 0)
			},
			true
		)

		if fastTween then
			local v8 = fastTween
			self.fishInventoryTrove:Add(function()
				v8:Cancel()
			end)
		end

		local color = v4.Rarity and rarities.Rarities[v4.Rarity].Color or Color3.new(0, 0, 0)

		if rarities.Rarities[v4.Rarity].ColorGradient then
			Color3.new(1, 1, 1)
			color = Color3.new(1, 1, 1)
		end

		clone.hover.ImageColor3 = color
		clone.fishname.TextColor3 = color
		clone.MouseEnter:Connect(function()
			fx:PlaySound(sounds.sfx.ui.itemhover, script.Parent, true)
			GeneralUtils.fastTween(
				clone.stroke,
				TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Color = color
				}
			)
			GeneralUtils.fastTween(clone.hover, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				ImageTransparency = 0
			})

			if fastTween then
				fastTween:Cancel()
				clone.hover.Size = size
				fastTween:Play()
			end
		end)
		local frame = clone
		clone.MouseLeave:Connect(function()
			GeneralUtils.fastTween(
				frame.stroke,
				TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Color = Color3.fromRGB(0, 0, 0)
				}
			)
			GeneralUtils.fastTween(frame.hover, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				ImageTransparency = 1
			})
		end)
		local v12 = k
		local frame2 = clone
		local v14 = fastTween
		local size2 = size
		clone.button.MouseButton1Click:Connect(function()
			self:UpdateSelect("fish", v12, frame2)

			if v14 then
				v14:Cancel()
				frame2.hover.Size = size2
			end
		end)
	end

	for k, rod in pairs(rods) do
		if type(rod) ~= "table" then
			continue
		end

		local v4 = nil
		local v5 = nil

		if rod.DEV then
			continue
		end

		if rod.Unregistered and not rod.NotLimited then
			v4 = "Normal"
			v5 = "Limited"
		elseif rod.From then
			local v6 = false

			for k2, item in items do
				for k3, _ in pairs(item.locations) do
					if rod.From ~= k3 then
						continue
					end

					v5 = k3
					v4 = k2
					v6 = true
					break
				end
			end

			if not v6 then
				v4 = "Normal"
				v5 = "None"
			end
		else
			v4 = "Normal"
			v5 = "None"
		end

		local clone = script.rodTemplate:Clone()
		clone.Name = k
		clone:SetAttribute("RealName", k)
		clone.hidden.Visible = true
		clone.Parent = nil
		clone.vp.Image = rod.Icon or ""
		items[v4].locations[v5].bestiary[k] = {
			frame = clone,
			connections = {},
			Type = "rod"
		}
		local size = clone.hover.Size
		local fastTween = GeneralUtils.fastTween(
			clone.hover,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{
				Size = UDim2.new(1.13, 0, 1.13, 0)
			},
			true
		)
		local rod2 = rods[k]
		local v6 = rods2 and rods2[k]

		if v6 then
			DataController.PlayerDataReplicator:WaitForLoaded()
			local v7 = DataController.PlayerDataReplicator:TryIndex({ "RodJournal", "ClaimedRods" })
			local index2 = v7 and table.find(v7, k)

			if rod2.DiscoveryRewards and not index2 then
				clone.indicator.Visible = true
				v2[k] = clone
			else
				clone.indicator.Visible = false
			end
		end

		if v6 then
			clone.hidden.Visible = false
			clone.vp.Visible = true
			clone.rodname.Text = k
		else
			clone.hidden.Visible = true
			clone.vp.Visible = false
			clone.rodname.Text = "???"
		end

		if fastTween then
			local v7 = fastTween
			self.fishInventoryTrove:Add(function()
				v7:Cancel()
			end)
		end

		local color = rod.Color ~= Color3.fromRGB(0, 0, 0) and rod.Color or Color3.new(0, 0, 0)
		clone.hover.ImageColor3 = color
		clone.rodname.TextColor3 = color
		clone.MouseEnter:Connect(function()
			fx:PlaySound(sounds.sfx.ui.itemhover, script.Parent, true)
			GeneralUtils.fastTween(
				clone.stroke,
				TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Color = rarityColor
				}
			)
			GeneralUtils.fastTween(clone.hover, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				ImageTransparency = 0
			})

			if fastTween then
				fastTween:Cancel()
				clone.hover.Size = size
				fastTween:Play()
			end
		end)
		local frame = clone
		clone.MouseLeave:Connect(function()
			GeneralUtils.fastTween(
				frame.stroke,
				TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Color = Color3.fromRGB(0, 0, 0)
				}
			)
			GeneralUtils.fastTween(frame.hover, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				ImageTransparency = 1
			})
		end)
		local v11 = k
		local frame2 = clone
		local v13 = fastTween
		local size2 = size
		clone.button.MouseButton1Click:Connect(function()
			self:UpdateSelect("rod", v11, frame2)

			if v13 then
				v13:Cancel()
				frame2.hover.Size = size2
			end
		end)
	end
end

return FishInventory