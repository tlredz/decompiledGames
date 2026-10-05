game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Players2 = game:GetService("Players")
local TweenService = game:GetService("TweenService")
game:GetService("ContentProvider")
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
game:GetService("GuiService")
local GamepadService = game:GetService("GamepadService")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
require(packages.Signal)
local Trove = require(packages.Trove)
local modules = ReplicatedStorage.shared.modules
local charms = require(modules.library.charms)
local stats = require(modules.library.stats)
local SharedCharms = require(modules.SharedCharms)
local SharedIdolFavor = require(modules.SharedIdolFavor)
local fx = require(modules.fx)
local utils = ReplicatedStorage.shared.utils
require(utils.GeneralUtils)
local NumberUtils = require(utils.NumberUtils)
local FischUtils = require(utils.FischUtils)
local legacyControllers = ReplicatedStorage.client.legacyControllers
local HudController = require(legacyControllers.HudController)
local LightingController = require(legacyControllers.LightingController)
local CutsceneController = require(legacyControllers.CutsceneController)
local SettingsController = require(legacyControllers.SettingsController)
local WindowController = require(legacyControllers.WindowController)
local NotificationController = require(legacyControllers.NotificationController)
local DataController = require(legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local playerGui = HudController:GetPlayerGui()
local deviceInsetGui = HudController:GetDeviceInsetGui()
local charmMenu = playerGui:WaitForChild("CharmMenu")
local charmDetails = charmMenu:WaitForChild("charmDetails")
local detailContents = charmDetails:WaitForChild("detailContents")
local leveling = detailContents:WaitForChild("leveling")
local equipButton = detailContents:WaitForChild("equipButton")
local quest = detailContents:WaitForChild("navigate"):WaitForChild("quest")
local charmsScene = script:WaitForChild("CharmsScene")
local charmAmulet = charmsScene:WaitForChild("CharmAmulet")
SoundService:WaitForChild("music")
local remoteFunction = Net:RemoteFunction("Charms/Equip", -1)
local remoteFunction2 = Net:RemoteFunction("Charms/Unequip", -1)
local remoteFunction3 = Net:RemoteFunction("Charms/RequestNavigate", -1)
local constants = SharedCharms.Constants
local v = CFrame.new(-643.492, 3402.146, -118.039) * CFrame.fromOrientation(-0.2047794811364947, 2.572301158174283, 0)
local color = Color3.fromRGB(0, 0, 0)
local color2 = Color3.fromRGB(255, 255, 255)
local color3 = Color3.fromRGB(165, 165, 165)
local color4 = Color3.fromRGB(76, 76, 76)
local v2 = {
	hud = true,
	backpack = true,
	deviceInset = true,
	Return = false,
	quickAccess = false,
	TopbarCentered = true,
	TopbarCenteredClipped = true,
	TopbarStandard = true,
	TopbarStandardClipped = true
}
local CharmMenu = {
	activeCharm = nil,
	activeEquipped = false
}
local v3 = false
local v4 = false
local v5 = false
local v6 = false
local maid = Trove.new()
local maid2 = maid:Extend()

function CharmMenu.handleLighting(data)
	data.Lighting.ClockTime = 14.5
	data.Lighting.GeographicLatitude = 0
	data.BloomEffect.Intensity = 1
	data.BloomEffect.Size = 32
	data.BloomEffect.Threshold = 2
	data.ColorCorrectionEffect.Brightness = 0
	data.ColorCorrectionEffect.Contrast = 0
	data.ColorCorrectionEffect.Saturation = 0
	data.ColorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
	data.SunRaysEffect.Intensity = 0
	data.Clouds.Cover = 0
	data.Clouds.Density = 0
	data.BlurEffect.Size = 0
	return data
end

function CharmMenu:styleCharmButton(color5: Color3, flag: boolean)
	self.BackgroundColor3 = color5:Lerp(color, 0.8)
	self.UIStroke.Color = color5
	self.UIShadow.Color = color5
	local charmIcon = self.charmIcon
	local imageColor

	if flag then
		imageColor = color
	else
		imageColor = color2
	end

	charmIcon.ImageColor3 = imageColor
	self.corner.ImageColor3 = color5
	self.charmName.TextColor3 = color5
	self.level.TextColor3 = color5
	self.stat.TextColor3 = color5
end

function CharmMenu.createCharmButton(p: string)
	local charm = charms[p]

	if not charm then
		warn((`Unknown Charm "{p}"`))
		return nil
	end

	local stat = stats[charm.TargetStat]

	if not stat then
		warn((`Unknown stat "{charm.TargetStat}" boosted by "{p}"`))
		return nil
	end

	local v7 = maid:Add(script.charmTemplate:Clone())
	v7.LayoutOrder = charm.Order
	v7.charmIcon.Image = charm.Icon
	local v8 = false
	local v9 = false
	maid:Add(playerDataReplicator:Observe({ "Charms", "Equipped", p }, function(p2)
		v7.equipped.Visible = p2 ~= nil
		v8 = p2 ~= nil
	end))
	maid:Add(playerDataReplicator:Observe({ "Charms", "Owned", p }, function(p2)
		v9 = p2 ~= nil

		if p2 then
			CharmMenu.styleCharmButton(v7, charm.Color, false)
			v7.charmName.Text = charm.Name
			v7.stat.Text = stat.DisplayName
			v7.level.Text = `Lv. {p2.Level}`
			v7.level.Visible = true
		else
			CharmMenu.styleCharmButton(v7, color3, true)
			v7.charmName.Text = "???"
			v7.stat.Text = "Locked"
			v7.level.Visible = false
		end
	end))
	local flag = false
	maid:Add(v7.Activated:Connect(function(object, p2: number)
		if not v9 or not object:IsModifierKeyDown(Enum.ModifierKey.Shift) and (p2 + 1) % 2 ~= 0 then
			CharmMenu.loadCharmDetails(p)
			return
		end

		if flag then
			return
		end

		flag = true
		v6 = true

		if v8 then
			remoteFunction2:InvokeServer(p)
		else
			remoteFunction:InvokeServer(p)
		end

		flag = false
		v6 = false
	end))
	v7.Parent = charmMenu.charmList.charmList
	return v7
end

function CharmMenu.styleCharmDetails(color5: Color3)
	local HSV, v7, v8 = color5:ToHSV()

	if v8 < 0.5 then
		color5 = Color3.fromHSV(HSV, v7, 0.5)
	end

	local lerped = color5:Lerp(color, 0.8)
	local lerped2 = color5:Lerp(color, 0.25)
	local color6

	if v7 > 0.01 then
		color6 = Color3.fromHSV(HSV, 0.9, v8 * 0.9)
	else
		color6 = lerped2
	end

	charmDetails.BackgroundColor3 = lerped
	charmDetails.UIStroke.Color = color5
	charmDetails.UIShadow.Color = color5
	charmDetails.UIShadow2.Color = color6
	charmDetails.header.TextColor3 = color5
	charmDetails.corner.ImageColor3 = color5
	charmDetails.headerbg.BackgroundColor3 = lerped
	charmDetails.headerbg.UIStroke.Color = color5
	leveling.levelbar.BackgroundColor3 = color5:Lerp(color, 0.6)
	leveling.levelbar.fill.BackgroundColor3 = color5:Lerp(color2, 0.75)
	leveling.levelbar.fill.UIShadow.Color = color5
	leveling.levelbar.fill.UIShadow2.Color = color6
	leveling.levelframe.level.TextColor3 = color5
	leveling.levelframe.xp.TextColor3 = color5
	leveling.statboost.TextColor3 = color5
	equipButton.BackgroundColor3 = color5:Lerp(color, 0.9)
	equipButton.UIStroke.Color = color5
	equipButton.UIShadow.Color = color5
	equipButton.deco.BackgroundColor3 = color5
	equipButton.corner.ImageColor3 = color5
	equipButton.label.TextColor3 = color5
	detailContents.ascend.TextColor3 = lerped2
	detailContents.levelup.TextColor3 = lerped2
	detailContents.locked.TextColor3 = color5
	detailContents.maxlevel.TextColor3 = color5
	quest.BackgroundColor3 = color6
	quest.leftBorder.BackgroundColor3 = color5
	quest.questInfo.questName.UIStroke.Color = lerped
	quest.arrow.ImageColor3 = color5
	local clone = script.switchOverlay:Clone()
	clone.BackgroundColor3 = color5
	clone.outer.ImageColor3 = color5:Lerp(color, 0.5)
	clone.Visible = true
	clone.Parent = charmDetails
	local tween = TweenService:Create(clone.outer.UIGradient, TweenInfo.new(2, Enum.EasingStyle.Exponential), {
		Offset = Vector2.new(0, 1)
	})
	clone.outer.SliceScale = 2
	TweenService:Create(clone.outer, TweenInfo.new(2, Enum.EasingStyle.Quint), {
		SliceScale = 0.1
	}):Play()
	TweenService:Create(clone.UIGradient, TweenInfo.new(1, Enum.EasingStyle.Quint), {
		Offset = Vector2.new(0, 1)
	}):Play()
	tween:Play()
	tween.Completed:Once(function()
		clone:Destroy()
	end)
end

function CharmMenu.loadCharmDetails(activeCharm: string)
	maid2:Clean()
	CharmMenu.activeCharm = activeCharm
	local v7 = assert(charms[activeCharm], (`Unknown Charm "{activeCharm}"`))
	local v8 = assert(stats[v7.TargetStat], (`Unknown stat "{v7.TargetStat}" boosted by "{activeCharm}"`))
	local v9 = playerDataReplicator:TryIndex({ "Charms", "Owned", activeCharm })

	-- equivalent calls inferred from this helper; original call sites unknown
	local function statDisplay(statBoost: number)
		if v7.StatMultiply then
			return (`{NumberUtils:Comma(statBoost)}×`)
		end

		return (`+{NumberUtils:Comma(statBoost)}{v8.Suffix or ""}`)
	end

	if v9 then
		CharmMenu.styleCharmDetails(v7.Color)
		charmDetails.header.Text = v7.Name
		local v10 = v9.Level >= v9.MaxLevel
		local visible = v9.Level >= constants.MAX_LEVEL
		local visible2 = v10 and not visible
		detailContents.locked.Visible = false
		detailContents.equipButton.Visible = true
		detailContents.leveling.Visible = true
		detailContents.ascend.Visible = visible2
		detailContents.levelup.Visible = not v10
		detailContents.maxlevel.Visible = visible
		detailContents.navigate.Visible = visible2 and v7.IdolTag ~= nil

		local function updateEquipButton()
			local activeEquipped = playerDataReplicator:TryIndex({ "Charms", "Equipped", activeCharm }) ~= nil
			CharmMenu.activeEquipped = activeEquipped

			if activeEquipped then
				detailContents.cantequip.Visible = false
				detailContents.equipButton.label.Text = "Unequip"
				detailContents.equipButton.Visible = true
			elseif v7.IdolLevelRequirement and SharedIdolFavor.GetLevel(localPlayer) < v7.IdolLevelRequirement then
				detailContents.equipButton.Visible = false
				detailContents.cantequip.Text = `\nRequires Idol Level {v7.IdolLevelRequirement}`
				detailContents.cantequip.Visible = true
			elseif SharedCharms.countActiveCharms(localPlayer) >= SharedCharms.getMaxCharmsForPlayer(localPlayer) then
				detailContents.equipButton.Visible = false
				detailContents.cantequip.Text = [[
Your Crest Amulet can't hold any more Charms!
Increase your Idol Level or unequip other Charms first.]]
				detailContents.cantequip.Visible = true
			else
				detailContents.cantequip.Visible = false
				detailContents.equipButton.label.Text = "Equip"
				detailContents.equipButton.Visible = true
			end
		end

		maid2:Add(playerDataReplicator:Observe({ "Charms", "Equipped", activeCharm }, updateEquipButton))
		maid2:Add(playerDataReplicator:Listen({ "Skycrest", "Favor", "Level" }, updateEquipButton))
		leveling.levelframe.level.Text = `Lv. {v9.Level} <font color="#{v7.Color:Lerp(color, 0.25):ToHex()}">/ {v9.MaxLevel}</font>`
		local statBoost = SharedCharms.getStatBoost(activeCharm, v9.Level)

		if v10 then
			leveling.levelframe.xp.Text = visible and "MAX" or "Ascension Required"
			leveling.levelbar.fill.Size = UDim2.fromScale(1, 1)
			local statboost = leveling.statboost
			local displayName = v8.DisplayName
			local v14 = statDisplay(statBoost) -- equivalent call inferred; original call site unknown
			statboost.Text = `{displayName}: {v14}`
		else
			local requiredXp = SharedCharms.getRequiredXp(v9.Level + 1)
			leveling.levelframe.xp.Text = `{NumberUtils:Comma(v9.XP)}/{NumberUtils:Comma(requiredXp)} XP`
			leveling.levelbar.fill.Size = UDim2.fromScale(math.clamp(v9.XP / requiredXp, 0, 1), 1)
			local statBoost2 = SharedCharms.getStatBoost(activeCharm, v9.Level + 1)
			local statboost = leveling.statboost
			local displayName = v8.DisplayName
			local v14 = statDisplay(statBoost) -- equivalent call inferred; original call site unknown
			local v15 = statDisplay(statBoost2) -- equivalent call inferred; original call site unknown
			statboost.Text = `{displayName}: {v14} → {v15}`
		end

		if visible2 then
			local v13 = v9.MaxLevel == constants.LEVEL_CAP1 and "Tropical Squall" or "Raging Squall"

			if v7.IdolName then
				detailContents.ascend.Text = `Complete the <b><font color="#{v7.Color:ToHex()}">{v7.IdolName}</font></b>'s {v13} quests to increase this Charm's level cap`
			else
				detailContents.ascend.Text = `hi so this cant normally happen but it did because you used givecharm so just run "givecharm @s {v7.ShortName} 15" to fix that thanks`
			end
		end
	else
		CharmMenu.styleCharmDetails(color3)
		CharmMenu.activeEquipped = false
		charmDetails.header.Text = "???"
		detailContents.equipButton.Visible = false
		detailContents.cantequip.Visible = false
		detailContents.ascend.Visible = false
		detailContents.levelup.Visible = false
		detailContents.leveling.Visible = false
		detailContents.maxlevel.Visible = false
		detailContents.locked.Text = v7.Hint
		detailContents.locked.Visible = true
		detailContents.navigate.Visible = v7.IdolTag ~= nil
	end

	charmMenu.charmDetails.Visible = true
	fx:PlaySound(script.sfx.click, charmMenu, true)
end

local v7 = nil

function CharmMenu.updateSceneAmulet()
	local maxCharmsForPlayer = SharedCharms.getMaxCharmsForPlayer(localPlayer)
	local v8 = table.create(9)

	for k, v9 in playerDataReplicator:TryIndex({ "Charms", "Equipped" }), nil, nil do
		v8[v9] = k
	end

	local v9 = playerDataReplicator:TryIndex({ "Charms", "UniversalUnlocked" })

	for _, part in charmAmulet:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		if part.Name == "NecklaceThing" then
			local color5

			if v9 then
				color5 = Color3.fromRGB(58, 126, 91)
			else
				color5 = Color3.fromRGB(108, 88, 75)
			end

			part.Color = color5
		elseif part.Name == "Metal" then
			local color5

			if v9 then
				color5 = Color3.fromRGB(183, 157, 138)
			else
				color5 = Color3.fromRGB(163, 162, 165)
			end

			part.Color = color5
		end
	end

	for i = 1, 9 do
		local child = charmAmulet:FindFirstChild((`slot{i}`))

		if child then
			child.Transparency = maxCharmsForPlayer < i and 1 or 0

			if not (maxCharmsForPlayer < i) then
				if v8[i] then
					local charm = charms[v8[i]]

					if charm then
						local HSV, v10, v11 = charm.Color:ToHSV()
						local color5 = Color3.fromHSV(HSV, math.clamp(v10, 0.5, 0.8), (math.max(v11, 0.7)))

						if v7 and not v7[i] then
							if SettingsController:GetSettingValue("photosensitiveMode") then
								TweenService:Create(child, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
									Color = color5
								}):Play()
							else
								child.Color = color5
								TweenService:Create(child, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
									Color = color5
								}):Play()
								local colorSequence = ColorSequence.new(color5)

								for _, child2 in ipairs(child.activateParticles:GetChildren()) do
									child2.Color = colorSequence
									child2:Emit(child2:GetAttribute("EmitCount"))
								end
							end

							fx:PlaySound(script.sfx.equip, charmMenu, true)
						else
							child.Color = color5
						end
					else
						warn((`Unknown charm "{v8[i]}" equipped??`))
					end
				elseif v7 and v7[i] then
					TweenService:Create(child, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
						Color = color4
					}):Play()
					fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.equip, charmMenu, true)
				else
					child.Color = color4
				end
			end
		else
			warn((`Slot {i} not found in CharmAmulet!`))
		end
	end

	v7 = v8
	charmMenu.charmList.header.Text = `Available Charms ({SharedCharms.countActiveCharms(localPlayer)}/{SharedCharms.getMaxCharmsForPlayer(localPlayer)})`
end

function CharmMenu.open(p: string?)
	if v4 or v3 or v5 or not localPlayer.Character then
		return
	end

	if not DataController.HasItem("Crest Amulet", nil, true) then
		NotificationController:NavigateNotify(
			"Talk to the <b>Keeper of the Sky</b> to unlock the <b>Crest Amulet</b> first.",
			"KeeperOfTheSky"
		)
		return
	end

	if not (playerDataReplicator:TryIndex({ "Charms", "UniversalUnlocked" }) or table.find(
		FischUtils.GetZonesAt(localPlayer),
		"Skycrest"
	)) then
		NotificationController:NavigateNotify([[
My Crest Amulet seems to only work at <b>Skycrest</b> right now...
Maybe the <b>Keeper of the Sky</b> can help with that?]], "KeeperOfTheSky", nil, nil, 2)
		return
	end

	v4 = true
	v3 = true
	CharmMenu.activeCharm = nil
	WindowController:CloseActiveWindow()
	localPlayer.Character:SetAttribute("CharmMenu", 0)
	local humanoid = localPlayer.Character:FindFirstChildWhichIsA("Tool") and localPlayer.Character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid:UnequipTools()
	end

	maid:Clean()
	maid:Add(maid2)
	charmsScene.Parent = workspace.active
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		CFrame = workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -15),
		FieldOfView = 30
	}):Play()
	CutsceneController:FadeToggle(0.25, true)

	for _, screenGui in ipairs(playerGui:GetChildren()) do
		if not (screenGui:IsA("ScreenGui") and v2[screenGui.Name] ~= nil) then
			continue
		end

		screenGui.Enabled = false
		local v8 = screenGui
		maid:Add(screenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
			if v8.Enabled and v3 and not v5 then
				v8.Enabled = false
			end
		end))
	end

	deviceInsetGui.Enabled = false
	maid:Add(deviceInsetGui:GetPropertyChangedSignal("Enabled"):Connect(function()
		if deviceInsetGui.Enabled and v3 and not v5 then
			deviceInsetGui.Enabled = false
		end
	end))
	ProximityPromptService.Enabled = false

	for k, _ in charms do
		CharmMenu.createCharmButton(k)
	end

	playerDataReplicator:WaitForLoaded()
	maid:Add(playerDataReplicator:Observe({ "Charms", "Equipped" }, CharmMenu.updateSceneAmulet))
	maid:Add(playerDataReplicator:Observe({ "Skycrest", "Favor", "Level" }, CharmMenu.updateSceneAmulet))
	local success, result = pcall(function()
		local humanoid2 = localPlayer.Character and localPlayer.Character:FindFirstChildWhichIsA("Humanoid")
		local appliedDescription = humanoid2 and humanoid2:GetAppliedDescription() or Players2:GetHumanoidDescriptionFromUserIdAsync(localPlayer.UserId)
		appliedDescription.NeckAccessory = ""
		local v8 = maid:Add(Players2:CreateHumanoidModelFromDescriptionAsync(
			appliedDescription,
			Enum.HumanoidRigType.R6
		))
		local humanoid3 = v8:FindFirstChildWhichIsA("Humanoid")

		if humanoid3 then
			humanoid3.BreakJointsOnDeath = false
			humanoid3.EvaluateStateMachine = false
			humanoid3.RequiresNeck = false
			humanoid3.AutoRotate = false
			humanoid3.AutoJumpEnabled = false
			humanoid3.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			;(humanoid3:FindFirstChildWhichIsA("Animator") or Instance.new("Animator", humanoid3)):LoadAnimation(script.idle):Play(
				nil,
				nil,
				0.25
			)
		end

		for _, v9 in v8:QueryDescendants("BaseScript, Sound") do
			v9:Destroy()
		end

		local humanoidRootPart = v8:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
			humanoidRootPart.Anchored = true
		end

		local torso = v8:FindFirstChild("Torso")

		if torso and torso:IsA("BasePart") and charmAmulet.NecklaceThing:FindFirstChild("ATTACH") then
			charmAmulet.NecklaceThing.Anchored = false
			charmAmulet.NecklaceThing.ATTACH.Part0 = torso
		else
			charmAmulet.NecklaceThing.Anchored = true
		end

		v8.Parent = workspace.active
		v8:ScaleTo(charmsScene.Rig:GetScale())
		v8:PivotTo(charmsScene.Rig:GetPivot())

		for _, accessory in v8:GetChildren() do
			if not accessory:IsA("Accessory") then
				continue
			end

			maid:Add(accessory)
			accessory.Parent = workspace.active
		end
	end)

	if not success then
		warn((`Failed to load player rig: {result}`))
	end

	FischUtils.PreloadAsync({
		charmsScene,
		charmMenu,
		script.sfx,
		script.switchOverlay,
		script.idle
	})
	task.wait(0.25)
	maid:Add(LightingController.HookLighting:BindAtPriority(99999999, CharmMenu.handleLighting))
	LightingController.UpdateLighting(0)
	maid:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.KeyCode == Enum.KeyCode.ButtonB and not gameProcessed and v3 and not v4 then
			CharmMenu.close()
		end
	end))

	if p then
		CharmMenu.loadCharmDetails(p)
	else
		charmMenu.charmDetails.Visible = false
	end

	charmMenu.Enabled = true
	GamepadService:EnableGamepadCursor(charmMenu.charmList.charmList)
	workspace.CurrentCamera.CFrame = v * CFrame.new(0, 0, 10)
	workspace.CurrentCamera.Focus = v
	workspace.CurrentCamera.FieldOfView = 70
	TweenService:Create(workspace.CurrentCamera, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
		CFrame = v,
		FieldOfView = 40
	}):Play()
	CutsceneController:FadeToggle(0.25, false)
	v4 = false
end

function CharmMenu.close()
	if v4 or v5 or not v3 then
		return
	end

	v3 = false
	v5 = true
	CharmMenu.activeCharm = nil
	CutsceneController:FadeToggle(0.25, true)
	TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		CFrame = v * CFrame.new(0, 0, 10),
		FieldOfView = 70
	}):Play()
	task.wait(0.25)
	charmAmulet.NecklaceThing.Anchored = true
	maid:Clean()
	LightingController.UpdateLighting(0)
	charmsScene.Parent = script
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	workspace.CurrentCamera.FieldOfView = 30
	TweenService:Create(
		workspace.CurrentCamera,
		TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{
			FieldOfView = 70
		}
	):Play()
	charmMenu.Enabled = false

	for _, screenGui in playerGui:GetChildren() do
		if screenGui:IsA("ScreenGui") and v2[screenGui.Name] == true then
			screenGui.Enabled = true
		end
	end

	deviceInsetGui.Enabled = true
	CutsceneController:FadeToggle(0.25, false)
	task.wait(0.25)
	ProximityPromptService.Enabled = true

	if localPlayer.Character then
		localPlayer.Character:SetAttribute("CharmMenu", nil)
	end

	v5 = false
end

function CharmMenu.init()
	ReplicatedStorage:WaitForChild("events"):WaitForChild("opencharms").Event:Connect(CharmMenu.open)
	equipButton.Activated:Connect(function()
		if not v3 or v4 or not CharmMenu.activeCharm or v6 then
			return
		end

		v6 = true
		equipButton.label.Text = "..."
		local success, result = pcall(function()
			if CharmMenu.activeEquipped then
				return remoteFunction2:InvokeServer(CharmMenu.activeCharm)
			end

			return remoteFunction:InvokeServer(CharmMenu.activeCharm)
		end)
		v6 = false

		if not success then
			warn((`Error while equipping: {result}`))
		end

		if not (success and result) then
			equipButton.label.Text = CharmMenu.activeEquipped and "Unequip" or "Equip"
		end
	end)
	quest.Activated:Connect(function()
		if not v3 or v4 or not CharmMenu.activeCharm then
			return
		end

		local activeCharm = CharmMenu.activeCharm
		task.spawn(CharmMenu.close)
		remoteFunction3:InvokeServer(activeCharm)
	end)
	charmMenu.closeButton.Activated:Connect(function()
		if v3 and not (v4 or v5) then
			CharmMenu.close()
		end
	end)
end

return CharmMenu