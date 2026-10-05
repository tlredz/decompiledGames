local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local packages = ReplicatedStorage.packages
local modules = ReplicatedStorage.shared.modules
local utils = ReplicatedStorage.shared.utils
local parent = script.Parent
local parent2 = parent.Parent
local DataController = require(legacyControllers.DataController)
local HudController = require(legacyControllers.HudController)
local SettingsController = require(legacyControllers.SettingsController)
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local patch = require(packages.patch)
local rods = require(modules.library.rods)
local RodSkins = require(modules.RodSkins)
local QuestShared = require(modules.QuestShared)
local enchants = require(modules.library.rods.enchants)
local mastery = require(modules.library.rods.mastery)
local fishing = require(modules.fishing)
local SharedWish = require(modules.SharedWish)
local NumberUtils = require(utils.NumberUtils)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local HuntNames = require(ReplicatedStorage.shared.data.HuntNames)
local RodSkinsEquipment = require(parent.RodSkinsEquipment)
local RodMasteryEquipment = require(parent.RodMasteryEquipment)
local VirtualEquipmentList = require(parent2:WaitForChild("VirtualEquipmentList"))
local UpdateRodSearch = require(script:WaitForChild("UpdateRodSearch"))
local stats = legacyLocalPlayerData.fetch():WaitForChild("Stats")
local rod = stats:WaitForChild("rod")
local realLevel = stats:WaitForChild("realLevel")
local remoteFunction = Net:RemoteFunction("Rod/Equip", -1)
local remoteFunction2 = Net:RemoteFunction("Rod/Favorite", -1)
local remoteFunction3 = Net:RemoteFunction("Rod/ChangeVariant", -1)
local remoteFunction4 = Net:RemoteFunction("Rod/ChangeMode", -1)
local anno_localthought = ReplicatedStorage.events.anno_localthought
local localPlayer = game.Players.LocalPlayer
local playerDataReplicator = DataController.PlayerDataReplicator
local equipment = HudController:GetSafeZone().equipment
local container = equipment.Container
local header = equipment.Header
local rods2 = container.Rods
local main = rods2.Main
local scrollingFrame = main.ScrollingFrame
local skins = rods2.Skins
local mastery2 = rods2.Mastery
local UI = script.UI
local powerFrame = UI:WaitForChild("powerFrame")
local color = Color3.fromRGB(175, 175, 175)
local color2 = Color3.fromRGB(190, 150, 150)
local color3 = Color3.fromRGB(255, 111, 111)
local v = {
	LureSpeed = "Lure Speed",
	Luck = "Luck",
	Control = "Control",
	Resilience = "Resilience",
	Strength = "Max KG",
	ProgressSpeed = "Progress Speed",
	Disturbance = "Disturbance",
	PreferredDisturbance = "Hunt Focus",
	Caught = "Caught"
}
local v2 = {
	Luck = {
		key = "Luck",
		display = "Luck",
		suffix = "%"
	},
	LureSpeed = {
		key = "Lure",
		display = "Lure Speed",
		suffix = "%"
	},
	Resilience = {
		key = "Resilience",
		display = "Resilience",
		suffix = "%"
	},
	Control = {
		key = "Control",
		display = "Control",
		suffix = ""
	},
	Strength = {
		key = "Strength",
		display = "Max Kg",
		suffix = "kg"
	},
	ProgressSpeed = {
		key = "ProgressSpeed",
		display = "Progress Speed",
		suffix = "%"
	},
	Disturbance = {
		key = "Disturbance",
		display = "Disturbance",
		suffix = ""
	}
}
local v3 = {
	Luck = {
		statKey = "Luck",
		format = function(p, _, callback)
			return (`Luck: {p.Luck}%{callback("Luck", true)}`)
		end,
		colorBands = {
			{
				threshold = 0,
				color = color2
			},
			{
				threshold = 1e999,
				color = color
			}
		}
	},
	LureSpeed = {
		statKey = "Lure",
		format = function(p, _, callback)
			return (`Lure Speed: {p.Lure}%{callback("Lure", true)}`)
		end,
		colorBands = {
			{
				threshold = 0,
				color = color2
			},
			{
				threshold = 1e999,
				color = color
			}
		}
	},
	Control = {
		statKey = "Control",
		format = function(p, _, callback)
			return (`Control: {math.round(p.Control * 1000) / 1000}{callback("Control", false)}`)
		end,
		colorBands = {
			{
				threshold = -0.3,
				color = color3
			},
			{
				threshold = 0,
				color = color2
			},
			{
				threshold = 1e999,
				color = color
			}
		}
	},
	Strength = {
		statKey = "Strength",
		format = function(p, _, callback)
			return (`Max Kg: {NumberUtils:Comma(p.Strength)}kg{callback("Strength", false)}`)
		end,
		colorBands = {
			{
				threshold = 0.001,
				color = color3
			},
			{
				threshold = 1e999,
				color = color
			}
		}
	},
	Resilience = {
		statKey = "Resilience",
		format = function(p, _, callback)
			return (`Resilience: {p.Resilience}%{callback("Resilience", true)}`)
		end,
		colorBands = {
			{
				threshold = -200,
				color = color3
			},
			{
				threshold = 0,
				color = color2
			},
			{
				threshold = 1e999,
				color = color
			}
		}
	},
	ProgressSpeed = {
		statKey = "ProgressSpeed",
		format = function(p, _, callback)
			return string.format("%+.0f%%", p.ProgressSpeed) .. callback("ProgressSpeed", true)
		end,
		visibleIf = function(p)
			return p.ProgressSpeed and p.ProgressSpeed ~= 0
		end,
		colorBands = {
			{
				threshold = 0,
				color = color2
			},
			{
				threshold = 1e999,
				color = color
			}
		}
	},
	Disturbance = {
		statKey = "Disturbance",
		format = function(p, _, callback)
			return (`+{p.Disturbance or 0}{callback("Disturbance", false)}`)
		end,
		visibleIf = function(p)
			return p.Disturbance and p.Disturbance ~= 0
		end,
		colorBands = {
			{
				threshold = 1e999,
				color = color
			}
		}
	},
	PreferredDisturbance = {
		statKey = "PreferredDisturbance",
		format = function(_, p, _)
			local preferredDisturbance = p.PreferredDisturbance
			return (`{HuntNames[preferredDisturbance.Event] or preferredDisturbance.Event} (+{preferredDisturbance.Risk})`)
		end,
		visibleIf = function(p)
			local preferredDisturbance = p.PreferredDisturbance
			return preferredDisturbance ~= nil and preferredDisturbance.Risk ~= 0 and preferredDisturbance.Event ~= ""
		end,
		colorBands = {
			{
				threshold = 1e999,
				color = color
			}
		}
	}
}
local color4 = Color3.fromRGB(161, 255, 192)
local color5 = Color3.fromRGB(81, 81, 81)
local settingValue = "Names"
local v4 = nil
local v5 = 0
local v6 = ""
local folder = Instance.new("Folder")
folder.Name = "the evil rod zone"
folder.Parent = script
local v7 = {}

local function runEntryUpdate(data, p: string)
	local v8 = v7[data.key]

	if not (v8 and data.Frame) then
		return
	end

	if p == "stats" then
		v8.updateStats()
	elseif p == "enchant" then
		v8.updateEnchant()
	elseif p == "favorited" then
		v8.updateFavorited()
	elseif p == "mastery" then
		v8.updateMastery()
	elseif p == "display" then
		data.changeStatDisplay(settingValue)
	end
end

local function compareEntries(p, p2)
	local v8 = p.Frame and p.Frame.RodOptions.favorite.ImageTransparency == 0.25

	if v8 == (p2.Frame and p2.Frame.RodOptions.favorite.ImageTransparency == 0.25) then
		return p.key < p2.key
	end

	return v8
end

local v8 = VirtualEquipmentList.new({
	MainFrame = main,
	ScrollingFrame = scrollingFrame,
	OffscreenParent = folder,
	ListItemWidthScale = 0.31,
	ListAnchorYScale = 0.485,
	GridItemWidthScale = 0.157,
	GridItemHeightScale = 0.27,
	GridColumns = 6,
	Compare = compareEntries,
	RunUpdate = runEntryUpdate
})
local entries = v8:GetEntries()

-- equivalent calls inferred from this helper; original call sites unknown
local function scheduleRodUpdate(p: string, p2: string)
	v8:ScheduleUpdate(p, p2)
end

local function resolveKey(variantGroup: string)
	local rod2 = rods[variantGroup]

	if rod2 then
		variantGroup = rod2.VariantGroup or variantGroup
	end

	return variantGroup
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isRodValid(p: string)
	return rods[p] and playerDataReplicator:TryIndex({ "Rods", p }) and (not entries[p] or rods[p].VariantGroup)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSymbol(p: string)
	local enchant = enchants.Enchants[p]

	if not enchant then
		return "★"
	end

	if enchant.Keeperbound then
		return "◆"
	end

	if enchant.RelicGroup == "Exalted" then
		return "❖"
	end

	if enchant.Secondary then
		return "♦"
	end

	return "★"
end

local function addBoostIndicator(p, p2, p3: string, flag: boolean?)
	if p.FixedStats and p.FixedStats[p3] then
		return ""
	end

	local v9 = math.round(((p2[p3] or 0) - (p[p3] or 0)) * 1000) / 1000
	local v10 = v9 > 0 and "+" or ""

	if v9 == 0 or v9 ~= v9 then
		return ""
	end

	return (` <font color="#ffd43a">({v10}{v9}{flag and "%" or ""})</font>`)
end

local function updateAllEquipped()
	local value = rod.Value

	if v4 and entries[v4.key] then
		local v9 = v4

		if v9.Frame then
			v9.Frame.Equip.UIStroke.Color = color4
			v9.Frame.Equip.Label.TextColor3 = color4
			v9.Frame.Equip.Label.Text = "[Equip]"
		end

		if v9.gridFrame then
			v9.gridFrame.Equipped.Enabled = false
		end
	end

	v4 = nil
	local rod2 = rods[value]

	if rod2 then
		value = rod2.VariantGroup or value
	end

	local entry = entries[value]

	if entry then
		if entry.Frame then
			entry.Frame.Equip.UIStroke.Color = color5
			entry.Frame.Equip.Label.TextColor3 = color5
			entry.Frame.Equip.Label.Text = "[Equipped]"
		end

		if entry.gridFrame then
			entry.gridFrame.Equipped.Enabled = true
		end

		v4 = entry
	end
end

local function updatePercent(flag: boolean?)
	if not (flag or rods2.Visible) then
		return
	end

	local v9 = math.clamp(math.round(v5 / rods.RegisteredNumberOfRods * 1000 / 10), 0, 100)
	local v10 = v5 >= rods.RegisteredNumberOfRods
	header.Complete.Text = `{v9}% Unlocked`
	header.Complete.TextColor3 = v10 and Color3.fromRGB(255, 243, 153) or Color3.fromRGB(255, 255, 255)
end

local function playVariantAnimation(color6: Color3, button)
	if not equipment.Visible or button:IsA("GuiButton") and v8:GetLayout() ~= "Grid" then
		return
	end

	local clone = UI.variantSwitchOverlay:Clone()
	clone.ImageColor3 = color6
	clone.inner.BackgroundColor3 = color6:Lerp(Color3.new(0, 0, 0), 0.5)
	clone.Visible = true
	clone.Parent = button
	local tween = TweenService:Create(clone.UIGradient, TweenInfo.new(3, Enum.EasingStyle.Exponential), {
		Offset = Vector2.new(0, 1)
	})
	clone.SliceScale = 2
	TweenService:Create(clone, TweenInfo.new(3, Enum.EasingStyle.Quint), {
		SliceScale = 0.1
	}):Play()
	TweenService:Create(clone.inner.UIGradient, TweenInfo.new(1.5, Enum.EasingStyle.Quint), {
		Offset = Vector2.new(0, 1)
	}):Play()
	tween:Play()
	tween.Completed:Once(function()
		clone:Destroy()
	end)
	clone.changeVariant:Play()
end

local function findNextCycleItem(list, p: string?, fn)
	if #list == 0 then
		return nil
	end

	local v9 = 0

	for k, v11 in list do
		if v11 ~= p then
			continue
		end

		v9 = k
		break
	end

	for i = 1, #list do
		local v11 = list[(v9 - 1 + i) % #list + 1]

		if fn(v11) and v11 ~= p then
			return v11
		end
	end

	return nil
end

local function refreshVariantCycle(data)
	local gridFrame = data.gridFrame

	if not gridFrame then
		return
	end

	local variantCycle = gridFrame.RodOptions:FindFirstChild("variantCycle")

	if not variantCycle then
		return
	end

	if #data.variantList < 2 then
		variantCycle.Visible = false
		return
	end

	local rod2 = rods[data.rodName]

	if not (rod2 and rod2.VariantGroup) then
		variantCycle.Visible = false
		return
	end

	local v9 = playerDataReplicator:TryIndex({ "VariantGroups", rod2.VariantGroup, "ActiveVariant" }) or data.rodName
	local rod3 = rods[v9]

	if not rod3 then
		variantCycle.Visible = false
		return
	end

	local nextCycleItem = findNextCycleItem(data.variantList, v9, function()
		return true
	end)
	variantCycle:SetAttribute(
		"TooltipText",
		(`Switch to <b><font color="#{rods[nextCycleItem or v9].Color:ToHex()}">{nextCycleItem or v9}</font></b>`)
	)
	variantCycle:SetAttribute("TooltipColor", rod3.Color)
	variantCycle.Image = rod3.VariantIcon or "rbxassetid://18162767851"
	variantCycle.Visible = true
end

local function isModeUnlocked(rodName: string, p: string)
	local v9 = rods[rodName] and rods[rodName].Modes and rods[rodName].Modes[p]

	if not v9 then
		return false
	end

	return not v9.RequiresUnlock or playerDataReplicator:TryIndex({ "RodModesUnlocked", rodName, p }) == true
end

local function refreshModeCycle(data)
	local gridFrame = data.gridFrame

	if not gridFrame then
		return
	end

	local modeCycle = gridFrame.RodOptions:FindFirstChild("modeCycle")

	if not modeCycle then
		return
	end

	local rodName = data.rodName
	local count = 0

	for _, v9 in data.modeList do
		if isModeUnlocked(rodName, v9) then
			count += 1
		end
	end

	if count < 2 then
		modeCycle.Visible = false
		return
	end

	local v9 = playerDataReplicator:TryIndex({ "Rods", rodName, "mode" })

	if not (v9 and isModeUnlocked(rodName, v9)) then
		for _, v11 in data.modeList do
			if not isModeUnlocked(rodName, v11) then
				continue
			end

			v9 = v11
			break
		end
	end

	local v10 = v9 and rods[rodName].Modes[v9]
	modeCycle.Image = v10 and v10.Icon or "rbxassetid://18162767851"
	modeCycle.Visible = true
	local nextCycleItem = findNextCycleItem(data.variantList, v9, function(p)
		return (isModeUnlocked(rodName, p))
	end)
	local mode = rods[rodName].Modes[nextCycleItem or v9]
	local formatted = `Switch to <b><font color="#{mode.Color:ToHex()}">{mode.DisplayName or nextCycleItem or v9}</font></b>`

	if mode.Description then
		formatted ..= `\n{mode.Description}`
	end

	modeCycle:SetAttribute("TooltipText", formatted)
	modeCycle:SetAttribute("TooltipColor", mode.Color)
end

local function ensureVariantCycleButton(data)
	local gridFrame = data.gridFrame

	if not gridFrame or gridFrame.RodOptions:FindFirstChild("variantCycle") then
		refreshVariantCycle(data)
		return
	end

	local clone = UI.variantButton:Clone()
	clone.Name = "variantCycle"
	clone.LayoutOrder = 100
	clone.Visible = false
	clone:AddTag("HoverTooltip")

	if clone:FindFirstChild("lock") then
		clone.lock.Visible = false
	end

	clone.Activated:Connect(function()
		local rod2 = rods[data.rodName]

		if not (rod2 and rod2.VariantGroup) then
			return
		end

		local v9 = playerDataReplicator:TryIndex({ "VariantGroups", rod2.VariantGroup, "ActiveVariant" }) or data.rodName
		local nextCycleItem = findNextCycleItem(data.variantList, v9, function()
			return true
		end)

		if not nextCycleItem then
			return
		end

		remoteFunction3:InvokeServer(nextCycleItem)
	end)
	clone.Parent = gridFrame.RodOptions
	refreshVariantCycle(data)
end

local function ensureModeCycleButton(data)
	local gridFrame = data.gridFrame

	if not gridFrame or gridFrame.RodOptions:FindFirstChild("modeCycle") then
		refreshModeCycle(data)
		return
	end

	local clone = UI.variantButton:Clone()
	clone.Name = "modeCycle"
	clone.LayoutOrder = 200
	clone.Visible = false
	clone:AddTag("HoverTooltip")

	if clone:FindFirstChild("lock") then
		clone.lock.Visible = false
	end

	clone.Activated:Connect(function()
		local rodName = data.rodName
		local v9 = playerDataReplicator:TryIndex({ "Rods", rodName, "mode" })
		local nextCycleItem = findNextCycleItem(data.modeList, v9, function(p)
			return (isModeUnlocked(rodName, p))
		end)

		if not nextCycleItem then
			return
		end

		local v10, v11 = remoteFunction4:InvokeServer(rodName, nextCycleItem)

		if not v10 then
			anno_localthought:Fire(v11)
		end
	end)
	clone.Parent = gridFrame.RodOptions
	refreshModeCycle(data)
end

local function newVariantButton(p: string, p2)
	local formatted = `variant_{p}`
	local rod2 = rods[p]

	if not (rod2 and rod2.VariantGroup) then
		return
	end

	if p2.Frame and not p2.Frame.RodOptions:FindFirstChild(formatted) then
		local clone = UI.variantButton:Clone()
		clone.Image = rod2.VariantIcon or "rbxassetid://18162767851"
		clone.LayoutOrder = 100 + (rod2.VariantOrder or 0)
		clone.Name = formatted
		clone:SetAttribute("TooltipText", (`Switch to <b><font color="#{rod2.Color:ToHex()}">{p}</font></b>`))
		clone:SetAttribute("TooltipColor", rod2.Color)
		clone:AddTag("HoverTooltip")
		clone.Activated:Connect(function()
			if playerDataReplicator:TryIndex({ "VariantGroups", rod2.VariantGroup, "ActiveVariant" }) == p then
				playVariantAnimation(rod2.Color, p2.Frame)
			else
				remoteFunction3:InvokeServer(p)
			end
		end)
		clone.Parent = p2.Frame.RodOptions
	end

	if not table.find(p2.variantList, p) then
		table.insert(p2.variantList, p)
		table.sort(p2.variantList, function(a, b)
			return (rods[a] and rods[a].VariantOrder or 0) < (rods[b] and rods[b].VariantOrder or 0)
		end)
	end

	ensureVariantCycleButton(p2)
end

local function newModeButton(p: string, k: string, p2)
	local formatted = `mode_{k}`
	local rod2 = rods[p]
	local v9 = rod2 and rod2.Modes and rod2.Modes[k]

	if not (rod2 and v9) then
		return
	end

	local clone

	if p2.Frame and not p2.Frame.RodOptions:FindFirstChild(formatted) then
		clone = UI.variantButton:Clone()
		clone.Image = v9.Icon or "rbxassetid://18162767851"
		clone.LayoutOrder = 200 + (v9.Order or 0)
		clone.Name = formatted
		clone:SetAttribute("TooltipColor", v9.Color)
		clone:AddTag("HoverTooltip")
		clone.Activated:Connect(function()
			if playerDataReplicator:TryIndex({ "Rods", p, "mode" }) == k then
				playVariantAnimation(v9.Color, p2.Frame)
				return
			end

			local v10, v11 = remoteFunction4:InvokeServer(p, k)

			if not v10 then
				anno_localthought:Fire(v11)
			end
		end)
		clone.Parent = p2.Frame.RodOptions
	else
		clone = nil
	end

	if not table.find(p2.modeList, k) then
		table.insert(p2.modeList, k)
		table.sort(p2.modeList, function(a, b)
			return (rod2.Modes[a] and rod2.Modes[a].Order or 0) < (rod2.Modes[b] and rod2.Modes[b].Order or 0)
		end)
	end

	ensureModeCycleButton(p2)

	if clone then
		local function updateState()
			local v10 = not v9.RequiresUnlock or playerDataReplicator:TryIndex({ "RodModesUnlocked", p, k })
			clone.lock.Visible = not v10
			clone.ImageTransparency = v10 and 0 or 0.5
			refreshModeCycle(p2)
			local _, _, v11 = v9.Color:ToHSV()

			if v10 then
				local formatted2 = `<b><font color="#{v9.Color:ToHex()}" size="20">{v9.DisplayName or k}</font></b>`

				if v11 < 0.5 then
					formatted2 = `<stroke th="2" color="#ffffff">{formatted2}</stroke>`
				end

				if v9.Description then
					formatted2 ..= `\n{v9.Description}`
				end

				clone:SetAttribute("TooltipText", formatted2)
			else
				local formatted2 = `<b><font color="#{v9.Color:ToHex()}" size="20">???</font></b>`

				if v11 < 0.5 then
					formatted2 = `<stroke th="2" color="#ffffff">{formatted2}</stroke>`
				end

				if v9.Hint then
					formatted2 ..= `\n{v9.Hint}`
				end

				clone:SetAttribute("TooltipText", formatted2)
			end
		end

		updateState()

		if v9.RequiresUnlock then
			local v10 = playerDataReplicator:Listen({ "RodModesUnlocked", p, k }, updateState)
			clone.Destroying:Connect(v10)
		end
	end
end

local function createRodVisualHandlers(data, fn, _, fn2)
	local frame = data.Frame
	local stats2 = frame.Stats
	local favorite = frame.RodOptions.favorite
	local _ = frame.Rod.RodInfo.modify

	local function GetStatLabel(childName: string, text: string?)
		local child = stats2:FindFirstChild(childName)

		if not child then
			return
		end

		if text then
			child.Label.Text = text
		end

		return child
	end

	return {
		updateStats = function()
			local v9 = fn()
			local clone = table.clone(rods[v9])
			local clone2 = table.clone(fishing:GetRodStats(localPlayer, v9))
			clone.Lure = (clone.Lure or 0) + (100 - clone.LureSpeed)
			clone2.Lure = (clone2.Lure or 0) + (100 - clone2.LureSpeed)
			local statBoostsForPlayer = enchants:GetStatBoostsForPlayer(localPlayer, v9)

			for k, v10 in statBoostsForPlayer do
				if typeof(v10) == "number" then
					clone2[k] = (clone2[k] or 0) + v10
				end
			end

			clone.ProgressSpeed = (clone.ProgressSpeed or 0) + (clone.ProgressEfficiency or 0) * 100 + (clone.ForcedProgressEfficiency or 0) * 100 + (clone.ForcedProgressSpeed or 0)
			clone2.ProgressSpeed = (clone2.ProgressSpeed or 0) + (clone2.ProgressEfficiency or 0) * 100 + (clone2.ForcedProgressEfficiency or 0) * 100 + (clone2.ForcedProgressSpeed or 0)

			local function bothOfDaBoosts(p: string, flag: boolean)
				local v10 = clone

				if v10.FixedStats and v10.FixedStats[p] then
					return ""
				end

				local v12 = math.round(((clone2[p] or 0) - (v10[p] or 0)) * 1000) / 1000
				local v13 = v12 > 0 and "+" or ""

				if v12 == 0 or v12 ~= v12 then
					return ""
				end

				return (` <font color="#ffd43a">({v13}{v12}{flag and "%" or ""})</font>`)
			end

			for childName, v10 in v3 do
				local child = stats2:FindFirstChild(childName)

				if not child then
					continue
				end

				local visible = not v10.visibleIf or v10.visibleIf(clone2)
				child.Visible = visible

				if not visible then
					continue
				end

				child.Label.Text = v10.format(clone, clone2, bothOfDaBoosts)
				local v12 = clone2[v10.statKey] or 0
				local color6 = color

				if typeof(v12) == "number" then
					for _, colorBand in v10.colorBands do
						if not (v12 < colorBand.threshold) then
							continue
						end

						color6 = colorBand.color
						break
					end
				end

				child.Label.TextColor3 = color6
				child.Icon.ImageColor3 = color6
			end

			data.changeStatDisplay(settingValue)
		end,
		updateEnchant = function()
			local v9 = fn()
			local _ = rods[v9]
			local v10 = playerDataReplicator:TryIndex({ "Rods", v9 })

			if not v10 then
				return
			end

			local enchants2 = frame.Rod.Enchants
			local enchant = enchants2.enchant
			local secondary = enchants2.detail.secondary
			local mella = enchants2.detail.mella
			local keeperboundEnchant = v10.keeperboundActive and v10.keeperboundEnchant or v10.enchant
			local enchant2 = enchants.Enchants[keeperboundEnchant]

			if keeperboundEnchant == "none" or keeperboundEnchant == nil or not enchant2 then
				enchant.Visible = false
				enchant.Text = "★ x ★"
			else
				local symbol = getSymbol(keeperboundEnchant) -- equivalent call inferred; original call site unknown
				enchant.RichText = true
				enchant.Text = `{symbol} {enchants:GetRichDisplayName(keeperboundEnchant)} {symbol}`
				enchant.TextColor3 = enchant2.Color
				local bg = enchant:WaitForChild("bg")
				bg.ImageColor3 = enchant.TextColor3
				local bg2 = enchant:WaitForChild("bg2")
				bg2.ImageColor3 = enchant.TextColor3
				enchant.Visible = true
			end

			local affix_line = enchants2.detail:FindFirstChild("affix_line")

			if affix_line then
				affix_line:Destroy()
			end

			if v10.keeperboundActive and v10.keeperboundEnchant then
				secondary.Visible = false

				if v10.keeperboundAffixes and #v10.keeperboundAffixes > 0 then
					local richDisplayNames = {}

					for _, keeperboundAffix in v10.keeperboundAffixes do
						if enchants.Enchants[keeperboundAffix] then
							table.insert(richDisplayNames, enchants:GetRichDisplayName(keeperboundAffix))
						end
					end

					if #richDisplayNames > 0 then
						local clone = secondary:Clone()
						clone.Name = "affix_line"
						clone.Visible = true
						clone.RichText = true
						clone.Text = table.concat(richDisplayNames, ", ")
						clone.TextColor3 = Color3.fromRGB(255, 255, 255)
						clone.AutomaticSize = Enum.AutomaticSize.None
						clone.TextWrapped = false
						clone.TextScaled = true
						clone.Size = UDim2.new(1, 0, 0, secondary.Size.Y.Offset)
						local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
						uITextSizeConstraint.MinTextSize = 6
						uITextSizeConstraint.MaxTextSize = secondary.TextSize
						uITextSizeConstraint.Parent = clone
						clone.Parent = enchants2.detail
					end
				end
			else
				local secondaryEnchant = v10.secondaryEnchant

				if secondaryEnchant then
					local enchant3 = enchants.Enchants[secondaryEnchant]

					if secondaryEnchant == "none" or secondaryEnchant == nil or not enchant3 then
						secondary.Visible = false
						secondary.Text = "★ x ★"
					else
						local symbol = getSymbol(secondaryEnchant) -- equivalent call inferred; original call site unknown
						secondary.Text = `{symbol} {secondaryEnchant} {symbol}`
						secondary.TextColor3 = enchant3.Color
						secondary.Visible = true
					end
				end
			end

			local powerFrame2 = enchants2:FindFirstChild("powerFrame")
			local power = powerFrame2 and powerFrame2:FindFirstChild("power")
			local bar = power and power:FindFirstChild("bar")
			local amount = power and power:FindFirstChild("amount")

			if powerFrame2 and bar and bar:IsA("Frame") then
				if v10.keeperboundActive and v10.keeperboundEnchant then
					local v11 = math.clamp((v10.power or 0) / 100, 0, 1)
					powerFrame2.Visible = true
					local size = powerFrame.power.bar.Size
					TweenService:Create(bar, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
						Size = UDim2.new(size.X.Scale * v11, size.X.Offset * v11, size.Y.Scale, size.Y.Offset)
					}):Play()

					if amount and amount:IsA("TextLabel") then
						amount.Text = `Power: {math.floor(v11 * 100)}%`
					end
				else
					powerFrame2.Visible = false
				end
			end

			local buffs = frame.Rod.RodInfo:FindFirstChild("buffs")

			if buffs then
				local v11 = not (v10.keeperboundActive and v10.keeperboundEnchant) and {} or enchants:GetStatBoostsForPlayer(
					localPlayer,
					v9
				)

				for _, label in buffs:GetChildren() do
					if not label:IsA("TextLabel") then
						continue
					end

					local v12 = v2[label.Name]
					local v13 = v12 and v11[v12.key]

					if typeof(v13) == "number" and v13 ~= 0 then
						local v14 = v13 > 0 and "+" or ""
						local v15

						if v13 == 1e999 then
							v15 = "inf"
						elseif v13 == -1e999 then
							v15 = "-inf"
						else
							local v16 = math.round(v13 * 1000) / 1000

							if math.abs(v16) >= 1000 then
								v15 = NumberUtils:Comma(v16)
							else
								v15 = tostring(v16)
							end
						end

						label.Text = `{v12.display}: {v14}{v15}{v12.suffix}`
						label.Visible = true
					else
						label.Visible = false
					end
				end
			end

			local index = playerDataReplicator:Index({ "RodUpgrades", v9 })
			local luck = index and index.Luck

			if typeof(luck) ~= "number" or luck == 0 then
				mella.Visible = false
				return
			end

			mella.Text = string.format("%+d%%", luck * 100)

			if luck < 0 then
				mella.TextColor3 = Color3.fromRGB(255, 52, 72)
			elseif luck < 0.15 then
				mella.TextColor3 = Color3.fromRGB(255, 149, 0):Lerp(Color3.fromRGB(255, 238, 0), luck / 0.15)
			elseif luck < 0.25 then
				mella.TextColor3 = Color3.fromRGB(255, 234, 0):Lerp(Color3.fromRGB(65, 255, 55), (luck - 0.15) / 0.1)
			elseif luck >= 0.25 then
				mella.TextColor3 = Color3.fromRGB(207, 124, 255)
			end

			mella.UIStroke.Color = mella.TextColor3:Lerp(Color3.new(), 0.75)
			mella.Visible = true
		end,
		updateFavorited = function()
			local v9 = fn2()

			if not v9 then
				return
			end

			local favorited = v9.favorited
			local color6 = favorited and Color3.fromRGB(255, 162, 0) or Color3.fromRGB(255, 255, 255)
			favorite.Image = favorited and "rbxassetid://104522512885034" or "rbxassetid://85452306516270"
			favorite.ImageTransparency = favorited and 0.25 or 0.5
			favorite.ImageColor3 = color6
			frame.Rod.RodInfo.rodTitle.TextColor3 = color6
			local gridFrame = data.gridFrame

			if gridFrame then
				local favorite2 = gridFrame.RodOptions:FindFirstChild("favorite")

				if favorite2 then
					favorite2.Image = favorited and "rbxassetid://104522512885034" or "rbxassetid://85452306516270"
					favorite2.ImageTransparency = favorited and 0.25 or 0.5
					favorite2.ImageColor3 = color6
				end

				gridFrame.rodTitle.TextColor3 = color6
			end
		end,
		updateMastery = function() end
	}
end

local function loadRod(p: string)
	local SOUND_ID = "rbxassetid://873617644"

	if not isRodValid(p) then
		return
	end

	local rod2 = rods[p]

	if not rod2 or type(rod2) ~= "table" then
		return
	end

	local v9 = playerDataReplicator:TryIndex({ "Rods", p })

	if not v9 then
		return
	end

	local v10 = p
	local variantGroup = rod2.VariantGroup or v10
	local maid = Trove.new()
	local maid2 = maid:Extend()
	local v11 = "Less"
	local v12 = {
		trove = maid,
		key = variantGroup,
		rodName = v10,
		mounted = false,
		searchVisible = true,
		cachedIndex = nil,
		variantList = {},
		modeList = {}
	}

	if not (rod2.Unregistered or rod2.DEV) then
		v5 += 1
	end

	if rod2.VariantGroup and entries[rod2.VariantGroup] then
		UI.variantSwitchOverlay.changeVariant.SoundId = SOUND_ID
		task.spawn(ContentProvider.PreloadAsync, ContentProvider, { UI.variantSwitchOverlay })
		newVariantButton(v10, entries[rod2.VariantGroup])
	else
		if rod2.VariantGroup then
			UI.variantSwitchOverlay.changeVariant.SoundId = SOUND_ID
			task.spawn(ContentProvider.PreloadAsync, ContentProvider, { UI.variantSwitchOverlay })
			local v13 = playerDataReplicator:TryIndex({ "VariantGroups", rod2.VariantGroup, "ActiveVariant" })

			if typeof(v13) == "string" and rods[v13] then
				if v13 ~= v10 then
					rod2 = rods[v13]
					v10 = v13
				end
			else
				remoteFunction3:InvokeServer(v10)
			end

			v12.rodName = v10
			local icons = {}

			for _, rod3 in rods do
				if typeof(rod3) == "table" and rod3.VariantGroup == rod2.VariantGroup and rod3.Icon then
					table.insert(icons, rod3.Icon)
				end
			end

			task.spawn(ContentProvider.PreloadAsync, ContentProvider, icons)
		end

		local clone = UI.Template:Clone()
		clone.AnchorPoint = Vector2.new(0, 0.5)
		clone.Parent = folder
		v12.Frame = clone
		local clone2 = UI.GridTemplate:Clone()
		clone2.AnchorPoint = Vector2.new(0, 0)
		clone2.Parent = folder
		v12.gridFrame = clone2
		local clone3 = powerFrame:Clone()
		clone3.Visible = false
		clone3.Parent = clone.Rod.Enchants
		local bar = clone3:FindFirstChild("power") and clone3.power:FindFirstChild("bar")

		if bar then
			bar.Size = UDim2.new(0, 0, bar.Size.Y.Scale, bar.Size.Y.Offset)
		end

		local buffs = clone.Rod.RodInfo:FindFirstChild("buffs")

		if buffs then
			buffs.Visible = false
		end

		function v12.changeStatDisplay(p2, childName)
			local frame = v12.Frame

			if not frame then
				return
			end

			local stats2 = frame.Stats

			local function apply(data)
				local text = string.match(data.Label.Text, ":%s*(.+)") or data.Label.Text
				data.Label.Position = UDim2.fromScale(p2 == "Icons" and 0.18 or 0, 0.5)
				data.Label.Visible = p2 ~= "Disabled"
				data.Icon.Visible = p2 == "Icons"

				if p2 == "Names" then
					data.Label.Text = `{v[data.Name] or data.Name}: {text}`
				else
					data.Label.Text = text
				end
			end

			if childName and stats2:FindFirstChild(childName) then
				apply(stats2:FindFirstChild(childName))
				return
			end

			for _, frame2 in stats2:GetChildren() do
				if frame2:IsA("Frame") and frame2:FindFirstChild("Label") then
					apply(frame2)
				end
			end
		end

		function v12.updateRodIcon()
			local rodName = v12.rodName
			local v13 = playerDataReplicator:TryIndex({ "Rods", rodName })

			if not v13 then
				return
			end

			local icon = fishing:GetRodStats(localPlayer, rodName).Icon or ""
			local v14 = nil

			if SettingsController:GetSettingValue("rodSkinImage") and v13.skin and v13.skin ~= "" then
				local skin = RodSkins.Skins[v13.skin]

				if skin and skin.Icon then
					icon = skin.Icon
					v14 = skin
				end
			end

			if v12.Frame then
				v12.Frame.RodImage.Image = icon

				if v14 then
					v12.Frame.Rod.RodInfo.skinTitle.Text = `[{v14.DisplayText or v13.skin}]`
				end

				v12.Frame.Rod.RodInfo.skinTitle.Visible = v14 ~= nil
			end

			if v12.gridFrame then
				v12.gridFrame.RodImage.Image = icon
			end
		end

		local mastery3 = clone.RodOptions.mastery
		local modify = clone.Rod.RodInfo.modify
		local favorite = clone.RodOptions.favorite
		local rodVisualHandlers = createRodVisualHandlers(v12, function()
			return v10
		end, function()
			return rod2
		end, function()
			return playerDataReplicator:TryIndex({ "Rods", v10 })
		end)
		v7[variantGroup] = rodVisualHandlers

		local function updateDescriptionMode(p2: string)
			local description = rod2.Description

			if p2 == "Less" then
				description = string.sub(description, 1, 75) .. "..."
			end

			clone.Rod.RodInfo.desc.Text = description
			modify.Text = p2 == "Less" and "[More]" or "[Less]"
			clone.RodImage.ImageTransparency = (p2 == "Less" or not modify.Visible) and 0 or 0.75
			clone.Stats.Visible = p2 == "Less" or not modify.Visible
		end

		if clone3:IsA("GuiButton") and buffs then
			local uIListLayout = clone.Rod.RodInfo:FindFirstChildOfClass("UIListLayout")
			maid:Add(clone3.Activated:Connect(function()
				if buffs.Visible then
					buffs.Visible = false
					clone.Rod.RodInfo.desc.Visible = true
					modify.Visible = #rod2.Description > 75
					clone.Stats.Visible = v11 == "Less"

					if uIListLayout then
						uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
					end
				else
					buffs.Visible = true
					clone.Rod.RodInfo.desc.Visible = false
					modify.Visible = false
					clone.Stats.Visible = false

					if uIListLayout then
						uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
					end
				end
			end))
		end

		local function updateWished()
			local wished = clone:FindFirstChild("Wished")

			if not wished then
				return
			end

			local v13 = playerDataReplicator:TryIndex({ "Rods", v10 })
			local v14 = v13.wished ~= nil and SharedWish.GetWishTypeInfo(v13.wished)

			if v14 then
				wished.Image = v14.Icon
				wished.ImageColor3 = v14.Color
				wished:SetAttribute("TooltipColor", v14.Color)
				wished:SetAttribute(
					"TooltipText",
					(`<b>Wished</b> via <b><font color="#{v14.Color:ToHex()}">{v14.DisplayName}</font></b>`)
				)
			end

			wished.Visible = v13 ~= nil and v13.wished ~= nil
		end

		local function updateVariant()
			maid2:Clean()
			rod2 = rods[v10]
			v12.rodName = v10
			v9 = playerDataReplicator:TryIndex({ "Rods", v10 })

			if not v9 then
				return
			end

			clone.Name = v10
			clone.Rod.RodInfo.rodTitle.Text = `[{v10}]`
			updateWished()
			fishing:GetRodStats(localPlayer, v10)
			v12.updateRodIcon()
			clone.UIStroke.Color = rod2.Color
			clone.Gradient.BackgroundColor3 = rod2.Color
			clone2.Name = v10
			clone2.rodTitle.Text = `[{v10}]`
			clone2.UIStroke.Color = rod2.Color
			clone2.Gradient.BackgroundColor3 = rod2.Color
			local v13 = #rod2.Description <= 75
			modify.Visible = not v13
			updateDescriptionMode(v13 and "More" or "Less")
			local caught = clone.Stats:FindFirstChild("Caught")

			if caught then
				caught.Label.Text = `{NumberUtils:Comma(tonumber(v9.caught) or 0)}`
			end

			local v14 = { "Rods", v10 }
			local clone4 = table.clone(playerDataReplicator:Index(v14))
			maid2:Add(playerDataReplicator:Listen({ "Rods", v10 }, function(p2)
				local diff = patch.diff(clone4, p2)
				clone4 = table.clone(p2)

				if diff.caught ~= nil and caught then
					caught.Label.Text = `{NumberUtils:Comma(tonumber(diff.caught) or 0)}`

					if v12.mounted then
						v12.changeStatDisplay(settingValue, "Caught")
					else
						scheduleRodUpdate(variantGroup, "display") -- equivalent call inferred; original call site unknown
					end
				end

				if diff.favorited ~= nil then
					scheduleRodUpdate(variantGroup, "favorited") -- equivalent call inferred; original call site unknown
					v8:Rebuild()
				end

				if diff.skin ~= nil then
					v12.updateRodIcon()
				end

				updateWished()
				updateAllEquipped()
				scheduleRodUpdate(variantGroup, "stats") -- equivalent call inferred; original call site unknown
				scheduleRodUpdate(variantGroup, "enchant") -- equivalent call inferred; original call site unknown
			end))
		end

		v8:AddEntry(variantGroup, v12)
		updateVariant()
		rodVisualHandlers.updateStats()
		rodVisualHandlers.updateFavorited()
		rodVisualHandlers.updateEnchant()
		updatePercent()

		if rod2.VariantGroup then
			newVariantButton(v10, v12)

			if p ~= v10 then
				newVariantButton(p, v12)
			end
		end

		if rod2.Modes then
			UI.variantSwitchOverlay.changeVariant.SoundId = SOUND_ID

			for k in rod2.Modes do
				newModeButton(v10, k, v12)
			end

			maid:Add(playerDataReplicator:Listen({ "Rods", v10, "mode" }, function(p2)
				local activeTemplate = v8:GetActiveTemplate(v12) or clone
				playVariantAnimation(rod2.Modes[p2] and rod2.Modes[p2].Color or rod2.Color, activeTemplate)
				updateVariant()
				refreshModeCycle(v12)
				scheduleRodUpdate(variantGroup, "stats") -- equivalent call inferred; original call site unknown
			end))
		end

		maid:Add(playerDataReplicator:Listen({ "RodUpgrades", v10 }, function()
			updateAllEquipped()
			scheduleRodUpdate(variantGroup, "stats") -- equivalent call inferred; original call site unknown
			scheduleRodUpdate(variantGroup, "enchant") -- equivalent call inferred; original call site unknown
		end))

		if rod2.VariantGroup then
			maid:Add(playerDataReplicator:Listen({ "VariantGroups", rod2.VariantGroup, "ActiveVariant" }, function(p2)
				v10 = p2
				local activeTemplate = v8:GetActiveTemplate(v12) or clone
				playVariantAnimation(rods[p2].Color, activeTemplate)
				updateVariant()
				refreshVariantCycle(v12)
				scheduleRodUpdate(variantGroup, "stats") -- equivalent call inferred; original call site unknown
				scheduleRodUpdate(variantGroup, "enchant") -- equivalent call inferred; original call site unknown
			end))
		end

		local function tryEquip()
			if rod.Value == v10 or localPlayer:GetAttribute("RodEquipInProgress") then
				return
			end

			localPlayer:SetAttribute("RodEquipInProgress", true)
			clone.Equip.UIStroke.Color = color5
			clone.Equip.Label.TextColor3 = color5
			clone.Equip.Label.Text = "..."
			remoteFunction:InvokeServer(v10)
			localPlayer:SetAttribute("RodEquipInProgress", false)
		end

		maid:Connect(clone.Equip.Activated, tryEquip)
		maid:Connect(clone2.Activated, tryEquip)

		local function skinActivated()
			RodSkinsEquipment:UpdateSkins(v10)
			main.Visible = false
			skins.Visible = true
		end

		maid:Connect(clone.RodOptions.skin.Activated, skinActivated)
		local skin = clone2.RodOptions:FindFirstChild("skin")

		if skin then
			maid:Connect(skin.Activated, skinActivated)
		end

		local flag = false

		local function tryFavorite()
			if flag then
				anno_localthought:Fire("<font color=\"#ff5858\">You're trying to favorite this way too fast pal...</font>")
				return
			end

			flag = true
			favorite.ImageColor3 = Color3.fromRGB(255, 255, 255)
			favorite.ImageTransparency = 0.75
			remoteFunction2:InvokeServer(v10)
			task.delay(0.25, function()
				flag = false
			end)
		end

		maid:Connect(favorite.Activated, tryFavorite)
		local favorite2 = clone2.RodOptions.favorite

		if favorite2 then
			maid:Connect(favorite2.Activated, tryFavorite)
		end

		local v13 = mastery.Mastery[v10]
		mastery3.ImageTransparency = v13 and 0.5 or 0.9
		local mastery4 = clone2.RodOptions:FindFirstChild("mastery")

		if v13 then
			local minimumLevel = v13.MinimumLevel

			local function masteryActivated()
				if v9.enchanted == "Restricted" then
					anno_localthought:Fire("<font color=\"#ff5858\">You must lift this rod's Restriction before starting its Mastery.</font>")
					return
				end

				if minimumLevel and minimumLevel > realLevel.Value then
					anno_localthought:Fire((`<font color="#ff5858">You must reach <b>Level {minimumLevel}</b> to start this rod's Mastery.</font>`))
					return
				end

				RodMasteryEquipment:UpdateMastery(v10)
				main.Visible = false
				mastery2.Visible = true
			end

			maid:Connect(mastery3.Activated, masteryActivated)

			if mastery4 then
				mastery4.Visible = true
				maid:Connect(mastery4.Activated, masteryActivated)
			end

			local color6 = Color3.fromRGB(255, 243, 153)
			local objectiveInstances = {}

			function rodVisualHandlers.updateMastery()
				if #objectiveInstances == 0 then
					return
				end

				local v14 = true

				for _, v16 in objectiveInstances do
					if v16.Value == -2 then
						continue
					end

					v14 = false
					break
				end

				local imageColor = v14 and color6 or Color3.fromRGB(255, 255, 255)
				mastery3.ImageColor3 = imageColor

				if mastery4 then
					mastery4.ImageColor3 = imageColor
				end
			end

			for k in v13.Quests do
				local objectiveInstance = QuestShared:GetObjectiveInstance(localPlayer, `{v10}/{k}-MASTERY`, 1)

				if not objectiveInstance then
					continue
				end

				table.insert(objectiveInstances, objectiveInstance)
				maid:Add(objectiveInstance:GetPropertyChangedSignal("Value"):Connect(function()
					scheduleRodUpdate(variantGroup, "mastery") -- equivalent call inferred; original call site unknown
				end))
			end

			scheduleRodUpdate(variantGroup, "mastery") -- equivalent call inferred; original call site unknown
		end

		maid:Connect(modify.Activated, function()
			v11 = v11 == "Less" and "More" or "Less"
			updateDescriptionMode(v11)
		end)
	end
end

local function removeRod(p: string)
	if not entries[p] then
		return
	end

	local entry = entries[p]
	entry.trove:Destroy()

	if entry.Frame then
		entry.Frame:Destroy()
	end

	if entry.gridFrame then
		entry.gridFrame:Destroy()
	end

	v8:RemoveEntry(p)
	v7[p] = nil
	local rod2 = rods[p]

	if rod2 and not rod2.Unregistered then
		v5 -= 1
	end

	updateAllEquipped()
	updatePercent()
	v8:Rebuild()
end

local RodsEquipment = {}
RodsEquipment.TabName = "Rods"
RodsEquipment.SearchTip = [[
Example rod queries:
• <b>luck</b>:&gt;100 - show results with more than 100% luck
• <b>lurespeed</b>:&gt;=30 - show results with 30% lure speed or more
• <b>favorited</b>:yes - show only favorited results
• <b>mastery</b>:yes - show results with mastery
• <b>enchant</b>:hasty - find results with the hasty enchant
• <b>secondaryenchant</b>:wise - find results with the wise secondary enchant
• <b>from</b>:moosewood - find results from moosewood
• use <b>commas</b> to combine searches - fav: yes, luck: &gt;50
• use &gt; &gt;= &lt;= = != to compare numbers]]
RodsEquipment.Container = rods2
RodsEquipment.MainFrame = main
RodsEquipment.ShowsCompletion = true

function RodsEquipment.UpdateHeader(_)
	updatePercent(true)
end

function RodsEquipment:SetActive(flag: boolean)
	v8:SetActive(flag)
end

function RodsEquipment:SetLayout(p: string)
	v8:SetLayout(p)
end

function RodsEquipment.UpdateSearch(_, value: string)
	v6 = value or ""
	UpdateRodSearch(entries, v6)
	v8:Rebuild()
end

function RodsEquipment.Init(_)
	local flag = false
	playerDataReplicator:ObserveKeys({ "Rods" }, function(p, p2)
		(p2 and loadRod or removeRod)(p)

		if flag then
			task.spawn(function()
				UpdateRodSearch(entries, v6)
				v8:Rebuild()
			end)
		end
	end)
	v8:Rebuild()
	flag = true
	rod:GetPropertyChangedSignal("Value"):Connect(function()
		updateAllEquipped()

		if v4 then
			scheduleRodUpdate(v4.key, "enchant") -- equivalent call inferred; original call site unknown
		end
	end)

	local function updateStatAllDisplayTypes()
		if SettingsController:GetSettingValue("rodStatDisplay") == settingValue then
			return
		end

		settingValue = SettingsController:GetSettingValue("rodStatDisplay")

		for k, entry in entries do
			if entry.mounted then
				task.spawn(entry.changeStatDisplay, settingValue)
			else
				scheduleRodUpdate(k, "display") -- equivalent call inferred; original call site unknown
			end
		end
	end

	SettingsController:GetSettingChangedSignal("rodStatDisplay"):Connect(updateStatAllDisplayTypes)

	local function updateAllRodIcons()
		for _, entry in entries do
			if entry.updateRodIcon then
				entry.updateRodIcon()
			end
		end
	end

	SettingsController:GetSettingChangedSignal("rodSkinImage"):Connect(updateAllRodIcons)
	task.defer(updateAllEquipped)
	task.defer(updateStatAllDisplayTypes)
	task.defer(updateAllRodIcons)
	task.defer(updatePercent)
end

return RodsEquipment