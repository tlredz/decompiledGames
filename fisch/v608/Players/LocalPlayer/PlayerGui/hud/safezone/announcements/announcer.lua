local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local items = require(ReplicatedStorage.shared.modules.library.items)
local rods = require(ReplicatedStorage.shared.modules.library.rods)
local WitcherPotions = require(ReplicatedStorage.shared.modules.WitcherPotions)
local GeneralUIModule = require(ReplicatedStorage.shared.modules.GeneralUIModule)
require(game.ReplicatedStorage.client.modules.ViewportModule)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local mutations = require(ReplicatedStorage2.shared.modules:WaitForChild("fishing"):WaitForChild("mutations"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local animatedgradient = require(ReplicatedStorage3.shared.modules:WaitForChild("fx"):WaitForChild("animatedgradient"))
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local bait = require(ReplicatedStorage4.shared.modules:WaitForChild("library"):WaitForChild("bait"))
local rarities = require(ReplicatedStorage.shared.modules:WaitForChild("library"):WaitForChild("rarities"))
local assets = require(ReplicatedStorage.shared.utils.assets)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local NotificationController = require(ReplicatedStorage.client.legacyControllers.NotificationController)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local fx = require(ReplicatedStorage.shared.modules:WaitForChild("fx"))
local debris = require(ReplicatedStorage.shared.modules:WaitForChild("fx"):WaitForChild("debris"))
local sfx = ReplicatedStorage.resources.sounds.sfx
local Net = require(ReplicatedStorage.packages.Net)
local remoteEvent = Net:RemoteEvent("ChangeChanceDisplayStyle")
local events = ReplicatedStorage:WaitForChild("events")
local v = "Minimal"

-- equivalent calls inferred from this helper; original call sites unknown
local function toHex(color: Color3)
	return "#" .. color:ToHex()
end

local function fitSphereToCamera(p, p2, p3)
	local v2 = math.rad(p2) * 0.5

	if p3 < 1 then
		v2 = math.atan(p3 * math.tan(v2))
	end

	return p / math.sin(v2)
end

local function getCubeoidDiameter(data)
	return (math.sqrt(data.x ^ 2 + data.y ^ 2 + data.z ^ 2))
end

local function fitBoundingBoxToCamera(data, p, p2)
	local v2 = math.sqrt(data.x ^ 2 + data.y ^ 2 + data.z ^ 2) / 2
	local v3 = math.rad(p) * 0.5

	if p2 < 1 then
		v3 = math.atan(p2 * math.tan(v3))
	end

	return v2 / math.sin(v3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fastTween(p, tweenInfo, p2)
	local tween = TweenService:Create(p, tweenInfo, p2)
	tween:Play()
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	return tween
end

local v2 = "None"
events:WaitForChild("anno_equip").OnClientEvent:Connect(function(p)
	if p ~= v2 and rods[p] then
		v2 = p

		if localPlayer:GetAttribute("StopBottomAnnounces") or not SettingsController:GetSettingValue("announcesBottom") then
			return
		end

		NotificationController:AwaitReady()
		local clone = script:WaitForChild("rodequipped"):Clone()
		clone.Main.TextTransparency = 1
		clone.Main.TextStrokeTransparency = 1
		clone.Shine.ImageTransparency = 1
		clone.Main.Position = UDim2.new(0.5, 0, -0.3, 0)
		local hex = toHex(rods[p].Color) -- equivalent call inferred; original call site unknown
		clone.Main.Text = "Equipped <font color='" .. hex .. "'><i><b>" .. p .. "</b></i></font>!"
		clone.Parent = script.Parent
		clone.Visible = true
		fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.popup, script.Parent, false)
		fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.equip, script.Parent, true)
		fastTween(clone.Main, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			TextTransparency = 0,
			Position = UDim2.new(0.5, 0, 0, 0),
			TextStrokeTransparency = 0.58
		}) -- equivalent call inferred; original call site unknown
		fastTween(clone.Shine, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			ImageTransparency = 0.1
		}) -- equivalent call inferred; original call site unknown
		task.wait(5)
		fastTween(clone.Main, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			TextTransparency = 1,
			Position = UDim2.new(0.5, 0, -0.3, 0),
			TextStrokeTransparency = 1
		}) -- equivalent call inferred; original call site unknown
		fastTween(clone.Shine, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			ImageTransparency = 1
		}) -- equivalent call inferred; original call site unknown
		debris:AddItem(clone, 0.5)
	end
end)
events:WaitForChild("anno_unlock").OnClientEvent:Connect(function(p)
	if localPlayer:GetAttribute("StopBottomAnnounces") then
		return
	end

	NotificationController:AwaitReady()
	local clone = script:WaitForChild("unlocked"):Clone()
	clone.Main.TextTransparency = 1
	clone.Main.TextStrokeTransparency = 1
	clone.Shine.ImageTransparency = 1
	clone.Main.Position = UDim2.new(0.5, 0, -0.3, 0)

	if rods[p] then
		local hex = toHex(rods[p].Color) -- equivalent call inferred; original call site unknown
		clone.Main.Text = "You have unlocked  <font color='" .. hex .. "'><i>" .. p .. "</i></font>!"
	else
		clone.Main.Text = "You have unlocked <font color='#ff7577'><i>" .. p .. "</i></font>!"
	end

	animatedgradient.clearold(clone.Main)
	local rarity = rods[p].Rarity or "Rare"
	local rarity2 = rarities.Rarities[rarity]

	if rarity2 and rarity2.ColorGradient then
		clone.Main.Text = "You have unlocked <i>" .. p .. "</i>!"
		local new = animatedgradient.new(rarity2.ColorGradient)
		new.Parent = clone.Main
	end

	clone.Parent = script.Parent
	clone.Visible = true
	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.popup, script.Parent, false)
	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.unlock2, script.Parent, false)
	fastTween(clone.Main, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 0,
		Position = UDim2.new(0.5, 0, 0, 0),
		TextStrokeTransparency = 0.58
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}) -- equivalent call inferred; original call site unknown
	task.wait(7)
	fastTween(clone.Main, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 1,
		Position = UDim2.new(0.5, 0, -0.3, 0),
		TextStrokeTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	debris:AddItem(clone, 0.5)
end)
events:WaitForChild("anno_titleunlock").OnClientEvent:Connect(function(p)
	if localPlayer:GetAttribute("StopBottomAnnounces") then
		return
	end

	NotificationController:AwaitReady()
	local clone = script:WaitForChild("unlocked"):Clone()
	clone.Main.TextTransparency = 1
	clone.Main.TextStrokeTransparency = 1
	clone.Shine.ImageTransparency = 1
	clone.Main.Position = UDim2.new(0.5, 0, -0.3, 0)
	local ReplicatedStorage5 = game:GetService("ReplicatedStorage")
	local v3 = require(ReplicatedStorage5.shared.modules:WaitForChild("character"):WaitForChild("titles"))[p]
	local _ = toHex(v3.StrokeColor) -- equivalent call inferred; original call site unknown
	local textColor

	if typeof(v3.TextColor) == "ColorSequence" then
		textColor = v3.TextColor
	else
		textColor = "#" .. v3.TextColor:ToHex()
	end

	if typeof(textColor) == "ColorSequence" then
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Color = textColor
		uIGradient.Rotation = 0
		uIGradient.Parent = clone.Main
		clone.Main.Text = "Received title - <font color='" .. ("#" .. v3.TextColor.Keypoints[1].Value:ToHex()) .. "'><i><b>" .. v3.Text .. "</b></i></font>!"
	else
		clone.Main.Text = "Received title - <font color='" .. textColor .. "'><i><b>" .. v3.Text .. "</b></i></font>!"
	end

	clone.Parent = script.Parent
	clone.Visible = true
	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.unlock1, script.Parent, false)
	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.popup, script.Parent, false)
	fastTween(clone.Main, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 0,
		Position = UDim2.new(0.5, 0, 0, 0),
		TextStrokeTransparency = 0.58
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}) -- equivalent call inferred; original call site unknown
	task.wait(7)
	fastTween(clone.Main, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 1,
		Position = UDim2.new(0.5, 0, -0.3, 0),
		TextStrokeTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	debris:AddItem(clone, 0.5)
end)
local v3 = 0
local v4 = 0
events:WaitForChild("anno_bait").OnClientEvent:Connect(function(p, p2)
	if localPlayer:GetAttribute("StopBottomAnnounces") then
		return
	end

	NotificationController:AwaitReady()
	local now = tick()
	local v5 = v3 - now
	local v6 = 0

	if v5 > 0 then
		v4 += 1
		v6 = v4
		v3 += 0.1
		task.wait(v5)
		v4 -= 1
	else
		v3 = now + 0.1
	end

	local clone = script:WaitForChild("unlocked"):Clone()
	clone.Main.TextTransparency = 1
	clone.Main.TextStrokeTransparency = 1
	clone.Shine.ImageTransparency = 1
	clone.Main.Position = UDim2.new(0.5, 0, -0.3, 0)
	local v7 = bait[p]
	local rarity = v7 and v7.Rarity or "Trash"
	local v8 = string.lower("#" .. rarities.Rarities[rarity].Color:ToHex())
	clone.Main.Text = "Received x" .. tostring(p2) .. " <font color='" .. v8 .. "'><i>" .. p .. "</i></font>!"
	clone.Parent = script.Parent
	clone.Visible = true
	animatedgradient.clearold(clone.Main)
	local rarity2 = rarities.Rarities[rarity]

	if rarity2 and rarity2.ColorGradient then
		clone.Main.Text = "Received x" .. tostring(p2) .. " <i>" .. p .. "</i>!"
		local new = animatedgradient.new(rarity2.ColorGradient)
		new.Parent = clone.Main
	end

	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.unlock3, script.Parent, v6 / 10 + 1.5)
	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.popup, script.Parent, false)
	fastTween(clone.Main, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 0,
		Position = UDim2.new(0.5, 0, 0, 0),
		TextStrokeTransparency = 0.58
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}) -- equivalent call inferred; original call site unknown
	task.wait(5)
	fastTween(clone.Main, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 1,
		Position = UDim2.new(0.5, 0, -0.3, 0),
		TextStrokeTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	debris:AddItem(clone, 0.5)
end)
local v5 = nil
local v6 = nil
local now = 0
local v7 = 0

function anno_thought(instance, text, image, p, p2, p3, p4, duration)
	if localPlayer:GetAttribute("StopBottomAnnounces") or not SettingsController:GetSettingValue("announcesBottom") then
		return
	end

	NotificationController:AwaitReady()

	if duration then
		task.wait(duration)
	end

	now = tick()

	if v5 == text and v6 then
		v7 += 1
		v6.Main.Text = `{text} <font color="#b0b0b0">(×{v7})</font>`
		fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.popup2, script.Parent, false)
		v6.Parent = nil
		v6.Parent = script.Parent
	else
		local v8 = p == nil and 0 or p
		local clone = instance:Clone()
		clone.Main.TextTransparency = 1
		clone.Main.TextStrokeTransparency = 1
		clone.Shine.ImageTransparency = 1
		clone.Main.Position = UDim2.new(0.5, 0, -0.3, 0)

		if image ~= nil then
			clone.Icon.Image = image
			clone.Icon.ImageTransparency = 1
			clone.Icon.Visible = true
		end

		clone.Main.Text = text
		clone.Parent = script.Parent
		clone.Visible = true
		v5 = text
		v6 = clone
		v7 = 1
		animatedgradient.clearold(clone.Main)

		if p3 and rarities.Rarities[p3] and rarities.Rarities[p3].ColorGradient then
			local new = animatedgradient.new(rarities.Rarities[p3].ColorGradient)
			new.Parent = clone.Main
		end

		fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.popup2, script.Parent, false)

		if p2 then
			fx:PlaySound(p2, script.Parent, false)
		end

		fastTween(clone.Icon, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			ImageTransparency = 0.1
		}) -- equivalent call inferred; original call site unknown
		fastTween(clone.Main, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			TextTransparency = 0,
			Position = UDim2.new(0.5, 0, 0, 0),
			TextStrokeTransparency = 0.58
		}) -- equivalent call inferred; original call site unknown
		fastTween(clone.Shine, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			ImageTransparency = 0.1
		}) -- equivalent call inferred; original call site unknown

		repeat
			local v10 = now
			task.wait(now + 8 + v8 - tick())
		until v5 ~= text or v6 ~= clone or now == v10

		if v6 == clone then
			v5 = nil
			v6 = nil
			v7 = 1
		end

		fastTween(clone.Main, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			TextTransparency = 1,
			Position = UDim2.new(0.5, 0, -0.3, 0),
			TextStrokeTransparency = 1
		}) -- equivalent call inferred; original call site unknown
		fastTween(clone.Shine, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			ImageTransparency = 1
		}) -- equivalent call inferred; original call site unknown
		fastTween(clone.Icon, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			ImageTransparency = 1
		}) -- equivalent call inferred; original call site unknown
		debris:AddItem(clone, p4 and 0.5 or 1)
	end
end

function anno_catch(state, value: number)
	if localPlayer:GetAttribute("StopBottomAnnounces") then
		return
	end

	NotificationController:AwaitReady()
	local now2 = tick()
	local v8 = v3 - now2
	local v9 = 0
	local v10 = (state.SubValues and state.SubValues.Fast or state.Fast) and 0.1 or 0.25

	if v8 > 0 then
		v4 += 1
		v9 = v4
		v3 += v10
		task.wait(v8)
		v4 -= 1
	else
		v3 = now2 + v10
	end

	if not SettingsController:GetSettingValue("catchNotifications") then
		return
	end

	local settingValue = SettingsController:GetSettingValue("fishChancesMode")
	local v11 = settingValue == "Percentage"
	local v12

	if settingValue == "Disabled" or typeof(value) ~= "number" then
		v12 = false
	else
		v12 = value > 0
	end

	if value and value < 0.01 then
		v11 = false
	end

	state.SubValues = state.SubValues or {}

	if localPlayer:GetAttribute("AB_FishingConfetti") then
		local value2 = legacyLocalPlayerData.fetch().Stats.tracker_fishcaught.Value
		local currentCamera = workspace.CurrentCamera

		if value2 < 4 then
			local clone = ReplicatedStorage.resources.models.ConfettiSplash:Clone()
			clone.CFrame = CFrame.new(currentCamera.Focus.Position - createVector(0, 2.5, 0))
			clone.Parent = workspace

			for _, child in clone.Attachment:GetChildren() do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			task.delay(10, clone.Destroy, clone)

			if value2 == 1 then
				anno_thought(
					script:WaitForChild("thought"),
					"You caught your 1st fish! Congratulations, do it again!",
					nil,
					nil,
					sfx.fishing.confetti
				)
			elseif value2 == 2 then
				anno_thought(
					script:WaitForChild("thought"),
					"You're on a roll! That's two, try and catch a third!",
					nil,
					nil,
					sfx.fishing.confetti
				)
			elseif value2 == 3 then
				anno_thought(
					script:WaitForChild("thought"),
					"That's three, nice work!",
					nil,
					nil,
					sfx.fishing.confetti2
				)
			end
		end
	end

	if state.NotCaught then
		fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.unlock3, script.Parent, v9 / 10 + 1.5)
	else
		local itemget = ReplicatedStorage.resources.sounds.sfx.ui.itemget

		if state.Drop and not state.IsCommon then
			itemget = ReplicatedStorage.resources.sounds.sfx.ui.itemget2
		end

		fx:PlaySound(itemget, script.Parent, v9 / 10 + 1)
	end

	local clone = script:WaitForChild("catch"):Clone()
	clone.Main.TextTransparency = 1
	clone.Main.TextStrokeTransparency = 1
	clone.Shine.ImageTransparency = 1
	clone.fih.vp.ImageTransparency = 1
	clone.fih.vp.Visible = false
	clone.fih.icon.ImageTransparency = 1
	clone.fih.icon.Visible = false
	clone.fih.Rotation = 25
	clone.fih.Position = UDim2.new(0.5, 0, 1, 0)
	clone.fih.Shine.ImageTransparency = 1
	clone.fih.sparkle.ImageTransparency = 1
	clone.fih.sparkle2.ImageTransparency = 1
	clone.Main.Position = UDim2.new(0.5, 0, -0.3, 0)
	local total = 8
	local shiny = state.Shiny
	local sparkling = state.Sparkling

	if shiny or sparkling then
		clone.sparkles:AddTag("UIEmitter")
		clone.sparkles.Enabled = true
		total += (state.SubValues.Fast or state.Fast) and 0 or 5
	end

	local v13 = state.NotCaught and "got" or "caught"
	local v14 = fish[state.Name] or items.Items[state.Name]
	local v15 = fish[state.Name] ~= nil
	local rarity = rarities.Rarities[v14.Rarity]
	local v16

	if v12 and v == "Minimal" and value > 0 then
		local v17 = math.clamp(value / 100, 0, 1)
		v16 = ` (<b><font color="#{Color3.fromRGB(255, 246, 178):Lerp(Color3.fromRGB(255, 27, 19), v17):ToHex()}">{v11 and string.format("%.2f%%", value) or `1/{NumberUtils:Comma((math.ceil(100 / value)))}`}</font></b>)`
	else
		v16 = ""
	end

	local itemDisplay = FischUtils.ItemDisplay(state, {
		rich = true,
		disable_color = rarity.ColorGradient ~= nil,
		disable_newlines = true,
		rarity_color = true
	})
	local v17 = ""

	local function addPrefix(p: string, p2: string)
		if rarity.ColorGradient == nil then
			v17 = `<font color='#{p2}'>{p}</font> {v17}`
		else
			v17 = p .. " " .. v17
		end
	end

	if state.Duplicate then
		if rarity.ColorGradient == nil then
			v17 = `<font color='#ff9b53'><b>Duplicate!</b></font> {v17}`
		else
			v17 = "<b>Duplicate!</b>" .. " " .. v17
		end
	elseif state.Extra then
		if rarity.ColorGradient == nil then
			v17 = `<font color='#c8ff49'><b>Extra!</b></font> {v17}`
		else
			v17 = "<b>Extra!</b>" .. " " .. v17
		end
	elseif state.Drop and state.IsCommon then
		if rarity.ColorGradient == nil then
			v17 = `<font color='#00e5ff'><b>Extra Find!</b></font> {v17}`
		else
			v17 = "<b>Extra Find!</b>" .. " " .. v17
		end
	elseif state.Drop then
		if rarity.ColorGradient == nil then
			v17 = `<font color='#00e5ff'><b>Rare Find!</b></font> {v17}`
		else
			v17 = "<b>Rare Find!</b>" .. " " .. v17
		end
	end

	local v18 = not state.CreditTo and "You just" or `<b>{state.CreditTo}</b>`
	local v19 = not state.Weight and "" or ` at <font color='#b3b3b3'><b>{NumberUtils:Comma(state.Weight)}</b></font>kg` or ""
	local v20 = (typeof(state.Count) ~= "number" or not (state.Count > 1)) and "a" or NumberUtils:Comma(state.Count) .. "×"
	clone.fih.sparkle.ImageColor3 = rarity.Color
	clone.fih.vp.BackgroundColor3 = rarity.Color
	clone.Main.Text = `{v17}{v18} {v13} {v20} <b>{itemDisplay}</b>{v19}!{v16}`
	animatedgradient.clearold(clone.Main)
	animatedgradient.clearold(clone.fih.sparkle)

	if rarity.ColorGradient then
		local v21 = not state.Weight and "" or ` at <b>{NumberUtils:Comma(state.Weight)}</b>kg` or ""
		clone.Main.Text = `{v17}{v18} {v13} {v20} <b>{itemDisplay}</b>{v21}!{v16}`
		clone.fih.sparkle.ImageColor3 = Color3.new(1, 1, 1)
		clone.fih.BackgroundColor3 = Color3.new(1, 1, 1)
		local new = animatedgradient.new(rarity.ColorGradient)
		new.Parent = clone.Main
		local new_2 = animatedgradient.new(rarity.ColorGradient)
		new_2.Parent = clone.fih.sparkle
	end

	local icon = nil
	local folder = nil

	if v15 then
		if not state.Shiny and not state.Sparkling and (not state.Mutation or state.Mutation == "Unsellable") then
			icon = fish[state.Name] and fish[state.Name].Icon

			if icon and fish[state.Name].HoldAnimation and fish[state.Name].HoldAnimation.Name == "heavy" then
				clone.fih.icon.Size = UDim2.fromScale(2, 2)
			end
		end
	elseif WitcherPotions.Potions[state.Name] and state.Tier then
		icon = WitcherPotions.Potions[state.Name].ItemIcons[state.Tier]
	else
		icon = items.Items[state.Name] and items.Items[state.Name].Icon
	end

	if icon == "" or icon == "rbxassetid://" or icon == "rbxassetid://0" or icon == "rbxassetid://-1" or icon == "rbxassetid://1" then
		icon = nil
	end

	if icon then
		clone.fih.icon.Image = icon
		clone.fih.icon.Visible = true
	end

	clone.Visible = true

	if not icon then
		clone.Parent = script.Parent

		if v15 then
			folder = assets.getCloneAsync("fish", (`{v15 and state.Shiny and "Shiny_" or ""}{state.Name}`))
		elseif WitcherPotions.Potions[state.Name] then
			folder = assets.getCloneAsync("potion", (`{state.Name}/Tier{state.Tier or 1}`))
		else
			folder = assets.getCloneAsync("item", state.Name)
		end

		if folder and folder:IsA("Folder") then
			folder = folder:FindFirstChild(state.Name) or folder:FindFirstChildOfClass("Model") or folder
		end

		if folder then
			local v21 = false

			for _, v23 in folder:QueryDescendants("BasePart, Decal") do
				if not (v23.Transparency < 1) then
					continue
				end

				v21 = true
				break
			end

			if not v21 then
				folder:Destroy()
				folder = nil
			end
		end

		if folder then
			if v15 and state.Mutation ~= nil then
				mutations:MutateModel(folder, state.Mutation, state)
			end

			folder.Name = "viewmodel"
			folder.Parent = clone.fih.vp
			local camera = Instance.new("Camera")
			camera.FieldOfView = 20
			local cFrame, size

			if folder:FindFirstChild("Hitbox") then
				cFrame = folder.Hitbox.CFrame
				size = folder.Hitbox.Size
			else
				cFrame, size = folder:GetBoundingBox()
			end

			local v21 = math.sqrt(size.x ^ 2 + size.y ^ 2 + size.z ^ 2) / 2 / math.sin(0.1308996938995747)
			camera.CFrame = CFrame.new(cFrame.p) * CFrame.Angles(0, 4.1887902047863905, 0) * CFrame.Angles(
				0.39269908169872414,
				0,
				0
			) * CFrame.new(0, 0, v21)
			camera.Focus = cFrame
			camera.Parent = clone.fih.vp
			clone.fih.vp.CurrentCamera = camera
			clone.fih.vp.Visible = true
		else
			warn((`Failed to get model or icon for {state.name}`))
		end
	end

	if not (icon or folder) then
		clone.fih.Visible = false
	end

	if v12 and v == "Big" then
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Odds"
		textLabel.Size = UDim2.fromScale(1, (math.clamp(value / 100 + 0.15, 0, 0.65)))
		textLabel.Position = UDim2.fromScale(0.5, 0.075)
		textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = v11 and string.format("%.2f%%", value) or `1 in {NumberUtils:Comma((math.ceil(100 / value)))}`
		textLabel.TextStrokeTransparency = 0.35
		textLabel.TextScaled = true
		textLabel.ZIndex = 200
		textLabel.FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold)
		textLabel.Parent = clone.fih
		local lerped = Color3.fromRGB(255, 246, 178):Lerp(Color3.fromRGB(255, 27, 19), value / 100)
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, lerped),
			ColorSequenceKeypoint.new(0.4, lerped),
			ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(0.6, lerped),
			ColorSequenceKeypoint.new(1, lerped)
		})
		uIGradient.Rotation = 35
		uIGradient.Parent = textLabel
		task.spawn(function()
			while textLabel and textLabel.Parent do
				uIGradient.Offset = Vector2.new(-1.5, 0)
				fastTween(uIGradient, TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Offset = Vector2.new(1.5, 0)
				}) -- equivalent call inferred; original call site unknown
				task.wait(2.4)
			end
		end)
		task.delay(total - 2, function()
			fastTween(textLabel, TweenInfo.new(0.5), {
				TextTransparency = 1
			}) -- equivalent call inferred; original call site unknown
		end)
	end

	clone.Parent = script.Parent
	fastTween(clone.Main, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 0,
		Position = UDim2.new(0.5, 0, 0, 0),
		TextStrokeTransparency = 0.58
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}) -- equivalent call inferred; original call site unknown

	if icon then
		local tween = TweenService:Create(
			clone.fih.icon,
			TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
			{
				ImageTransparency = 0
			}
		)
		tween:Play()
		tween.Completed:Once(function()
			tween:Destroy()
		end)
	elseif folder then
		local tween = TweenService:Create(
			clone.fih.vp,
			TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
			{
				ImageTransparency = 0
			}
		)
		tween:Play()
		tween.Completed:Once(function()
			tween:Destroy()
		end)
	end

	if icon or folder then
		fastTween(clone.fih, TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.new(0.5, 0, -1, 0),
			Rotation = 0
		}) -- equivalent call inferred; original call site unknown
		fastTween(clone.fih.Shine, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			ImageTransparency = 0
		}) -- equivalent call inferred; original call site unknown
		fastTween(clone.fih.sparkle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			ImageTransparency = 0.1
		}) -- equivalent call inferred; original call site unknown
		fastTween(clone.fih.sparkle2, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			ImageTransparency = 0
		}) -- equivalent call inferred; original call site unknown
		fastTween(
			clone.fih.sparkle2,
			TweenInfo.new(18, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, -1, true),
			{
				Rotation = -365
			}
		) -- equivalent call inferred; original call site unknown
		local tween = TweenService:Create(
			clone.fih.sparkle,
			TweenInfo.new(30, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, -1, false),
			{
				Rotation = 365
			}
		)
		tween:Play()
		tween.Completed:Once(function()
			tween:Destroy()
		end)
	end

	if shiny or sparkling then
		task.delay(0.7, function()
			fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.shineloud, script.Parent, false)

			if localPlayer.Character then
				local clone2 = ReplicatedStorage.resources.replicated.fx.specialcaught:Clone()
				clone2.Parent = localPlayer.Character:FindFirstChild("HumanoidRootPart")
				clone2:Emit(math.random(30, 50))
				debris:AddItem(clone2, 4)
				local color = Color3.fromRGB(253, 255, 130)

				if sparkling then
					color = Color3.fromRGB(255, 184, 126)
				end

				if shiny then
					color = Color3.fromRGB(255, 225, 134)
				end

				GeneralUIModule:FadedBorder(color, 0.5, 2)
			end
		end)
	elseif v14.AnnounceInChat or rarity.AnnounceInChat then
		fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.shine, script.Parent, false)
		local fx2 = ReplicatedStorage.resources.replicated.fx
		local v22 = fx2:FindFirstChild((`{rarity.Name:lower()}_Caught`)) or fx2.exotic_Caught
		v22.Color = rarity.ColorGradient or ColorSequence.new(rarity.Color)
		fx:EmitParticles(v22, localPlayer.Character:FindFirstChild("HumanoidRootPart"), 30)
		GeneralUIModule:FadedBorder(rarity.ColorGradient or rarity.Color, 0.7, 7)
	else
		GeneralUIModule:FadedBorder(Color3.fromRGB(119, 203, 255), 0.8, 7)
		local clone2 = ReplicatedStorage.resources.replicated.fx.caught:Clone()
		clone2.Parent = localPlayer.Character:FindFirstChild("HumanoidRootPart")
		clone2:Emit(math.random(15, 18))
		debris:AddItem(clone2, 4)
	end

	task.wait(total - 2)
	clone.sparkles.Enabled = false
	task.wait(2)
	fastTween(clone.Main, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 1,
		Position = UDim2.new(0.5, 0, -0.3, 0),
		TextStrokeTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}) -- equivalent call inferred; original call site unknown

	if icon or folder then
		if icon then
			local tween = TweenService:Create(
				clone.fih.icon,
				TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					ImageTransparency = 1
				}
			)
			tween:Play()
			tween.Completed:Once(function()
				tween:Destroy()
			end)
		else
			local tween = TweenService:Create(
				clone.fih.vp,
				TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					ImageTransparency = 1
				}
			)
			tween:Play()
			tween.Completed:Once(function()
				tween:Destroy()
			end)
		end

		fastTween(clone.fih.Shine, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			ImageTransparency = 1
		}) -- equivalent call inferred; original call site unknown
		fastTween(clone.fih.sparkle, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			ImageTransparency = 1
		}) -- equivalent call inferred; original call site unknown
		local tween = TweenService:Create(
			clone.fih.sparkle2,
			TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				ImageTransparency = 1
			}
		)
		tween:Play()
		tween.Completed:Once(function()
			tween:Destroy()
		end)
	end

	debris:AddItem(clone, 0.5)
end

events:WaitForChild("anno_thought").OnClientEvent:Connect(function(p, p2, p3, p4, p5, p6, p7)
	anno_thought(script:WaitForChild("thought"), p, p2, p3, p4, p5, p6, p7)
end)
events:WaitForChild("anno_thought_big").OnClientEvent:Connect(function(p, p2, p3, p4, p5, p6, p7)
	anno_thought(script:WaitForChild("thoughtbig"), p, p2, p3, p4, p5, p6, p7)
end)
events:WaitForChild("anno_localthought").Event:Connect(function(p, p2, p3, p4, p5, p6, p7)
	anno_thought(script:WaitForChild("thought"), p, p2, p3, p4, p5, p6, p7)
end)
events:WaitForChild("anno_localthoughtbig").Event:Connect(function(p, p2, p3, p4, p5, p6, p7)
	anno_thought(script:WaitForChild("thoughtbig"), p, p2, p3, p4, p5, p6, p7)
end)
events:WaitForChild("anno_catch").OnClientEvent:Connect(anno_catch)
events:WaitForChild("debug_catch").Event:Connect(anno_catch)
events:WaitForChild("anno_bestiary").OnClientEvent:Connect(function(p, p2)
	if localPlayer:GetAttribute("StopBottomAnnounces") then
		return
	end

	NotificationController:AwaitReady()
	local clone = script:WaitForChild("bestiary"):Clone()
	clone.Main.TextTransparency = 1
	clone.Main.TextStrokeTransparency = 1
	clone.Shine.ImageTransparency = 1
	clone.Main.Position = UDim2.new(0.5, 0, -0.3, 0)
	clone.Icon.ImageTransparency = 1
	clone.Icon.Visible = true
	local rarity = rarities.Rarities[fish[p].Rarity]
	clone.Main.Text = `Bestiary: <font color='#{rarity.Color:ToHex()}'><i><b>New {p2}</b></i></font>!`
	clone.Parent = script.Parent
	clone.Visible = true
	animatedgradient.clearold(clone.Main)

	if rarity.ColorGradient then
		clone.Main.Text = "Bestiary: <i><b>New " .. tostring(p2) .. "</b></i>!"
		local new = animatedgradient.new(rarity.ColorGradient)
		new.Parent = clone.Main
	end

	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.player.bestiaryUpdate, script.Parent, true)
	fastTween(clone.Main, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 0,
		Position = UDim2.new(0.5, 0, 0, 0),
		TextStrokeTransparency = 0.58
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}) -- equivalent call inferred; original call site unknown
	task.wait(8)
	fastTween(clone.Main, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 1,
		Position = UDim2.new(0.5, 0, -0.3, 0),
		TextStrokeTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	debris:AddItem(clone, 0.5)
end)
events:WaitForChild("nuke_spawned").OnClientEvent:Connect(function(p)
	if localPlayer:GetAttribute("StopBottomAnnounces") or not SettingsController:GetSettingValue("announcesBottom") then
		return
	end

	NotificationController:AwaitReady()
	local clone = script:WaitForChild("thought"):Clone()
	clone.Main.TextTransparency = 1
	clone.Main.TextStrokeTransparency = 1
	clone.Shine.ImageTransparency = 1
	clone.Main.Position = UDim2.new(0.5, 0, -0.3, 0)
	clone.Main.Text = "A <font color='#2FA401'>Nuke</font> exploded around <font color='#2FA401'><i><b>" .. tostring(p) .. "</b></i></font>!"
	clone.Parent = script.Parent
	clone.Visible = true
	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.popup2, script.Parent, false)
	fastTween(clone.Icon, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Main, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 0,
		Position = UDim2.new(0.5, 0, 0, 0),
		TextStrokeTransparency = 0.58
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}) -- equivalent call inferred; original call site unknown
	task.wait(5)
	fastTween(clone.Main, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 1,
		Position = UDim2.new(0.5, 0, -0.3, 0),
		TextStrokeTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Icon, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	debris:AddItem(clone, 1)
end)
events:WaitForChild("cursed_nuke_spawned").OnClientEvent:Connect(function(p)
	if localPlayer:GetAttribute("StopBottomAnnounces") or not SettingsController:GetSettingValue("announcesBottom") then
		return
	end

	NotificationController:AwaitReady()
	local clone = script:WaitForChild("thought"):Clone()
	clone.Main.TextTransparency = 1
	clone.Main.TextStrokeTransparency = 1
	clone.Shine.ImageTransparency = 1
	clone.Main.Position = UDim2.new(0.5, 0, -0.3, 0)
	clone.Main.Text = "A <font color='#2FA401'>Cursed Nuke</font> exploded around <font color='#2FA401'><i><b>" .. tostring(p) .. "</b></i></font>!"
	clone.Parent = script.Parent
	clone.Visible = true
	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.popup2, script.Parent, false)
	fastTween(clone.Icon, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Main, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 0,
		Position = UDim2.new(0.5, 0, 0, 0),
		TextStrokeTransparency = 0.58
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}) -- equivalent call inferred; original call site unknown
	task.wait(5)
	fastTween(clone.Main, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 1,
		Position = UDim2.new(0.5, 0, -0.3, 0),
		TextStrokeTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Icon, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	debris:AddItem(clone, 1)
end)
events:WaitForChild("atomic_nuke_spawned").OnClientEvent:Connect(function(p)
	if localPlayer:GetAttribute("StopBottomAnnounces") or not SettingsController:GetSettingValue("announcesBottom") then
		return
	end

	NotificationController:AwaitReady()
	local clone = script:WaitForChild("thought"):Clone()
	clone.Main.TextTransparency = 1
	clone.Main.TextStrokeTransparency = 1
	clone.Shine.ImageTransparency = 1
	clone.Main.Position = UDim2.new(0.5, 0, -0.3, 0)
	clone.Main.Text = "An <font color='#ffff00'>Atomic Nuke</font> exploded around <font color='#ffff00'><i><b>" .. tostring(p) .. "</b></i></font>!"
	clone.Parent = script.Parent
	clone.Visible = true
	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.popup2, script.Parent, false)
	fastTween(clone.Icon, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Main, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 0,
		Position = UDim2.new(0.5, 0, 0, 0),
		TextStrokeTransparency = 0.58
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}) -- equivalent call inferred; original call site unknown
	task.wait(5)
	fastTween(clone.Main, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 1,
		Position = UDim2.new(0.5, 0, -0.3, 0),
		TextStrokeTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Icon, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	debris:AddItem(clone, 1)
end)
events:WaitForChild("love_nuke_spawned").OnClientEvent:Connect(function(p)
	if localPlayer:GetAttribute("StopBottomAnnounces") or not SettingsController:GetSettingValue("announcesBottom") then
		return
	end

	NotificationController:AwaitReady()
	local clone = script:WaitForChild("thought"):Clone()
	clone.Main.TextTransparency = 1
	clone.Main.TextStrokeTransparency = 1
	clone.Shine.ImageTransparency = 1
	clone.Main.Position = UDim2.new(0.5, 0, -0.3, 0)
	clone.Main.Text = "A <font color='#ff00ae'>Love Nuke</font> exploded around <font color='#ff00ae'><i><b>" .. tostring(p) .. "</b></i></font>!"
	clone.Parent = script.Parent
	clone.Visible = true
	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.popup2, script.Parent, false)
	fastTween(clone.Icon, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Main, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 0,
		Position = UDim2.new(0.5, 0, 0, 0),
		TextStrokeTransparency = 0.58
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}) -- equivalent call inferred; original call site unknown
	task.wait(5)
	fastTween(clone.Main, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 1,
		Position = UDim2.new(0.5, 0, -0.3, 0),
		TextStrokeTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Icon, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	debris:AddItem(clone, 1)
end)
events:WaitForChild("shady_nuke_spawned").OnClientEvent:Connect(function(p)
	if localPlayer:GetAttribute("StopBottomAnnounces") or not SettingsController:GetSettingValue("announcesBottom") then
		return
	end

	NotificationController:AwaitReady()
	local clone = script:WaitForChild("thought"):Clone()
	clone.Main.TextTransparency = 1
	clone.Main.TextStrokeTransparency = 1
	clone.Shine.ImageTransparency = 1
	clone.Main.Position = UDim2.new(0.5, 0, -0.3, 0)
	clone.Main.Text = "A <font color='#805e5e'>Shady Nuke</font> exploded around <font color='#805e5e'><i><b>" .. tostring(p) .. "</b></i></font>!"
	clone.Parent = script.Parent
	clone.Visible = true
	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.popup2, script.Parent, false)
	fastTween(clone.Icon, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Main, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 0,
		Position = UDim2.new(0.5, 0, 0, 0),
		TextStrokeTransparency = 0.58
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}) -- equivalent call inferred; original call site unknown
	task.wait(5)
	fastTween(clone.Main, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 1,
		Position = UDim2.new(0.5, 0, -0.3, 0),
		TextStrokeTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Icon, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	debris:AddItem(clone, 1)
end)
events:WaitForChild("treasure_map_unlock").OnClientEvent:Connect(function(value)
	if localPlayer:GetAttribute("StopBottomAnnounces") or not SettingsController:GetSettingValue("announcesBottom") then
		return
	end

	NotificationController:AwaitReady()
	local clone = script:WaitForChild("thought"):Clone()
	clone.Main.TextTransparency = 1
	clone.Main.TextStrokeTransparency = 1
	clone.Shine.ImageTransparency = 1
	clone.Main.Position = UDim2.new(0.5, 0, -0.3, 0)
	clone.Main.Text = `You have received a <font color='#a41f1f'>Treasure Map</font>! [{value or "1/200"}]`
	clone.Parent = script.Parent
	clone.Visible = true
	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.popup2, script.Parent, false)
	fastTween(clone.Icon, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Main, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 0,
		Position = UDim2.new(0.5, 0, 0, 0),
		TextStrokeTransparency = 0.58
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}) -- equivalent call inferred; original call site unknown
	task.wait(5)
	fastTween(clone.Main, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 1,
		Position = UDim2.new(0.5, 0, -0.3, 0),
		TextStrokeTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Icon, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	debris:AddItem(clone, 1)
end)
events:WaitForChild("anno_boat").OnClientEvent:Connect(function(p, p2, p3)
	if localPlayer:GetAttribute("StopBottomAnnounces") then
		return
	end

	NotificationController:AwaitReady()
	local clone = script:WaitForChild("thought"):Clone()
	clone.Main.TextTransparency = 1
	clone.Main.TextStrokeTransparency = 1
	clone.Shine.ImageTransparency = 1
	clone.Main.Position = UDim2.new(0.5, 0, -0.3, 0)
	task.spawn(function()
		local child = p or workspace.active.boats:WaitForChild(localPlayer.Name, 10)

		if p3 and child and child:GetAttribute("SpawnId") ~= p3 then
			child.AncestryChanged:Wait()
			child = workspace.active.boats:WaitForChild(localPlayer.Name, 10)
		end

		if child then
			local highlight = Instance.new("Highlight")
			highlight.FillColor = Color3.fromRGB(255, 253, 198)
			highlight.FillTransparency = 0.75
			highlight.OutlineColor = Color3.fromRGB(255, 253, 198)
			highlight.OutlineTransparency = 0
			highlight.Parent = child
			;(fastTween(highlight, TweenInfo.new(8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				OutlineTransparency = 1,
				FillTransparency = 1
			})).Completed:Once(function()
				highlight:Destroy()
			end)
		end
	end)
	clone.Main.Text = "Spawned <font color='#ffee90'><i><b>" .. tostring(p2) .. "</b></i></font>!"
	clone.Parent = script.Parent
	clone.Visible = true
	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.popup2, script.Parent, false)
	fastTween(clone.Icon, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Main, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 0,
		Position = UDim2.new(0.5, 0, 0, 0),
		TextStrokeTransparency = 0.58
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}) -- equivalent call inferred; original call site unknown
	task.wait(5)
	fastTween(clone.Main, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 1,
		Position = UDim2.new(0.5, 0, -0.3, 0),
		TextStrokeTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Icon, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	debris:AddItem(clone, 1)
end)
events:WaitForChild("anno_give_boat").OnClientEvent:Connect(function(p, _)
	if localPlayer:GetAttribute("StopBottomAnnounces") then
		return
	end

	NotificationController:AwaitReady()
	local clone = script:WaitForChild("unlocked"):Clone()
	clone.Main.TextTransparency = 1
	clone.Main.TextStrokeTransparency = 1
	clone.Shine.ImageTransparency = 1
	clone.Main.Position = UDim2.new(0.5, 0, -0.3, 0)
	clone.Main.Text = "Received <font color='#ffee90'><i><b>" .. tostring(p) .. "</b></i></font>!"
	clone.Parent = script.Parent
	clone.Visible = true
	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.unlock1, script.Parent, false)
	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.popup, script.Parent, false)
	fastTween(clone.Main, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 0,
		Position = UDim2.new(0.5, 0, 0, 0),
		TextStrokeTransparency = 0.58
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}) -- equivalent call inferred; original call site unknown
	task.wait(5)
	fastTween(clone.Main, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 1,
		Position = UDim2.new(0.5, 0, -0.3, 0),
		TextStrokeTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	debris:AddItem(clone, 0.5)
end)
events:WaitForChild("anno_quest").OnClientEvent:Connect(function(text)
	if localPlayer:GetAttribute("StopBottomAnnounces") then
		return
	end

	NotificationController:AwaitReady()
	local clone = script:WaitForChild("quest"):Clone()
	clone.Main.TextTransparency = 1
	clone.Main.TextStrokeTransparency = 1
	clone.Shine.ImageTransparency = 1
	clone.Main.Position = UDim2.new(0.5, 0, -0.3, 0)
	print(text)
	clone.Main.Text = text
	clone.Parent = script.Parent
	clone.Visible = true
	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.topnotify, script.Parent, false)
	fastTween(clone.Main, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 0,
		Position = UDim2.new(0.5, 0, 0, 0),
		TextStrokeTransparency = 0.58
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}) -- equivalent call inferred; original call site unknown
	task.wait(8)
	fastTween(clone.Main, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 1,
		Position = UDim2.new(0.5, 0, -0.3, 0),
		TextStrokeTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	fastTween(clone.Shine, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	debris:AddItem(clone, 1)
end)

local function anno_persistent(text, value)
	local clone = script:WaitForChild("popupNotif"):Clone()
	clone.UIScale.Scale = 0

	if text then
		clone.notifContent.header.Text = text
	else
		clone.notifContent.header.Visible = false
	end

	if value then
		clone.notifContent.body.Text = value:gsub("\t", ""):gsub("^%s+", ""):gsub("%s+$", "")
	else
		clone.notifContent.body.Visible = false
	end

	clone.Parent = script.Parent.Parent.right
	clone.notifContent.dismissButton.Activated:Once(function()
		fastTween(clone.UIScale, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			Scale = 0
		}) -- equivalent call inferred; original call site unknown
		task.wait(0.25)
		clone:Destroy()
	end)
	fastTween(clone.UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
		Scale = 1
	}) -- equivalent call inferred; original call site unknown
end

events:WaitForChild("anno_persistent").OnClientEvent:Connect(anno_persistent)
events:WaitForChild("anno_localpersistent").Event:Connect(anno_persistent)
remoteEvent.OnClientEvent:Connect(function(p: string)
	if not table.find({ "Minimal", "Big" }, p) then
		return
	end

	v = p
end)
local playerGui = script:FindFirstAncestorWhichIsA("PlayerGui")

if not playerGui then
	repeat
		script.AncestryChanged:Wait()
		playerGui = script:FindFirstAncestorWhichIsA("PlayerGui")
	until playerGui
end

local inventory = playerGui:WaitForChild("backpack"):WaitForChild("inventory")

-- equivalent calls inferred from this helper; original call sites unknown
local function updateOffset()
	local uDim = UDim2.new(0.5, 0, 0.9, -90)

	if inventory.Visible then
		uDim -= UDim2.fromOffset(0, inventory.AbsoluteSize.Y)
	end

	script.Parent.Position = uDim
end

inventory:GetPropertyChangedSignal("Visible"):Connect(updateOffset)
updateOffset() -- equivalent call inferred; original call site unknown

-- equivalent calls inferred from this helper; original call sites unknown
local function updateScale(settingValue)
	script.Parent.UIScale.Scale = settingValue
end

SettingsController:GetSettingChangedSignal("announcesBottomScale"):Connect(updateScale)
updateScale(SettingsController:GetSettingValue("announcesBottomScale")) -- equivalent call inferred; original call site unknown