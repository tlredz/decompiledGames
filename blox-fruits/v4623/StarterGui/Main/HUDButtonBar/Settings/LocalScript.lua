local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TextChatService")
local AnalyticsUtil = require(ReplicatedStorage.Util.AnalyticsUtil)
local LastInput = require(ReplicatedStorage.Modules.LastInput)
LastInput = LastInput.IsMobile
local Flags = require(ReplicatedStorage.Modules.Flags)
local MobileUIController = require(ReplicatedStorage.Controllers.UI.MobileUIController)
local LastInput2 = require(ReplicatedStorage.Modules.LastInput)
local Global = require(game.ReplicatedStorage.Global)
local Groups = require(ReplicatedStorage.Util.Sound.Groups)
local HUD = require(game.ReplicatedStorage.Controllers.UI.HUD)
local parent = script.Parent
local settingsMenu = parent.Parent.Parent:WaitForChild("SettingsMenu")
local close = settingsMenu.Title:WaitForChild("Close")
local changeSetting = ReplicatedStorage.Remotes:WaitForChild("ChangeSetting")
local getSetting = ReplicatedStorage.Remotes:WaitForChild("GetSetting")
local v = {
	ANIMATION_TIME = 0.15,
	OPEN_POSITION = UDim2.fromScale(0.5, 0.5),
	CLOSE_POSITION = UDim2.fromScale(0.5, 0.6)
}
local v2 = nil
local background = script:WaitForChild("Background")

if workspace.Map:FindFirstChild("Dressrosa") then
	background.SoundId = "rbxassetid://9165234682"
else
	background.SoundId = "rbxassetid://2874697725"
end

Groups.assign(background, "LowPriority")
local v3 = false
local Global2 = require(game.ReplicatedStorage.Global)
Global2.MusicMutedChanged = Global2.MusicMutedChanged or Instance.new("BindableEvent")

function Global2.isMusicMuted()
	return v3
end

local v4 = nil
local currentCamera = workspace.CurrentCamera
local uISizeConstraint = settingsMenu:WaitForChild("UISizeConstraint")
local localPlayer = game.Players.LocalPlayer
local maxSize = uISizeConstraint.MaxSize

local function UpdateMenuSize()
	local viewportSize = currentCamera.ViewportSize

	if viewportSize.X < 1920 or viewportSize.Y < 1080 then
		uISizeConstraint.MaxSize = maxSize
		return
	end

	local v5 = math.floor(viewportSize.X * 0.7)
	local v6 = math.floor(viewportSize.Y * 0.6)
	uISizeConstraint.MaxSize = Vector2.new(v5, v6)
end

local viewportSize = currentCamera.ViewportSize

if viewportSize.X < 1920 or viewportSize.Y < 1080 then
	uISizeConstraint.MaxSize = maxSize
else
	local v5 = math.floor(viewportSize.X * 0.7)
	local v6 = math.floor(viewportSize.Y * 0.6)
	uISizeConstraint.MaxSize = Vector2.new(v5, v6)
end

currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateMenuSize)

local function UpdateMusic(p)
	v3 = p
	Global2.MusicMutedChanged:Fire(v3)

	if v4 then
		v4.SetState(not v3)
	end

	local v5 = v3 and 0 or 1
	Groups.setSettingFactor("LowPriority", v5)
	return v3
end

local v5 = nil

function Global.updateMusic2(flag: boolean)
	if flag then
		if not v5 then
			v5 = Groups.duck({
				LowPriority = 0
			})
		end
	elseif v5 then
		v5:Release()
		v5 = nil
	end
end

game.ReplicatedStorage.Events.ToggleMusic.Event:Connect(function(p)
	v3 = p
	Global2.MusicMutedChanged:Fire(v3)

	if v4 then
		v4.SetState(not v3)
	end

	local v6 = v3 and 0 or 1
	Groups.setSettingFactor("LowPriority", v6)
end)
game.Players.LocalPlayer.CharacterAdded:Connect(function()
	v3 = v3
	Global2.MusicMutedChanged:Fire(v3)

	if v4 then
		v4.SetState(not v3)
	end

	local v6 = v3 and 0 or 1
	Groups.setSettingFactor("LowPriority", v6)
end)

local function GetButton(childName: string)
	local child = settingsMenu:FindFirstChild(childName, true)

	if not child then
		warn("[SettingsMenu] Row not found:", childName)
		return nil
	end

	local firstButton = child:FindFirstChild("FirstButton")
	local secondButton = child:FindFirstChild("SecondButton")

	if firstButton and secondButton then
		local trans = firstButton:FindFirstChild("Trans")
		local trans2 = secondButton:FindFirstChild("Trans")
		return {
			Row = child,
			First = firstButton,
			Second = secondButton,
			SetState = function(flag: boolean)
				local color = Color3.fromRGB(158, 158, 158)
				local color2 = Color3.fromRGB(191, 191, 191)
				local color3 = Color3.fromRGB(128, 128, 128)

				if flag then
					firstButton.BackgroundColor3 = Color3.fromRGB(50, 185, 65)
					firstButton.BorderColor3 = Color3.fromRGB(27, 112, 36)

					if trans then
						trans.BackgroundColor3 = Color3.fromRGB(76, 214, 90)
					end

					secondButton.BackgroundColor3 = color
					secondButton.BorderColor3 = color3

					if trans2 then
						trans2.BackgroundColor3 = color2
					end
				else
					secondButton.BackgroundColor3 = Color3.fromRGB(255, 79, 79)
					secondButton.BorderColor3 = Color3.fromRGB(76, 34, 32)

					if trans2 then
						trans2.BackgroundColor3 = Color3.fromRGB(255, 112, 112)
					end

					firstButton.BackgroundColor3 = color
					firstButton.BorderColor3 = color3

					if trans then
						trans.BackgroundColor3 = color2
					end
				end
			end
		}
	else
		warn("[SettingsMenu] Invalid row structure for:", childName)
		return nil
	end
end

local v6 = false

local function Tweenin(flag: boolean)
	if v6 == flag then
		return
	end

	v6 = flag

	if v2 then
		v2:Cancel()
		v2 = nil
	end

	local tweenInfo = TweenInfo.new(v.ANIMATION_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

	if flag then
		settingsMenu.Visible = true
		settingsMenu.Position = v.CLOSE_POSITION
		v2 = TweenService:Create(settingsMenu, tweenInfo, {
			Position = v.OPEN_POSITION,
			Visible = true
		})
	else
		v2 = TweenService:Create(settingsMenu, tweenInfo, {
			Position = v.CLOSE_POSITION,
			Visible = false
		})
	end

	v2:Play()
end

function Global.closeSettingsMenu()
	if not v6 then
		return
	end

	Tweenin(false)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function openSettingsMenu()
	if v6 then
		return
	end

	Tweenin(true)
	AnalyticsUtil.reportActivity("HUD/Button/Settings")
end

local function Toggle()
	local v7 = not settingsMenu.Visible

	if v7 and Global.closeOthers then
		pcall(Global.closeOthers, "Settings")
	end

	if not v7 then
		Global.closeSettingsMenu()
		return
	end

	openSettingsMenu() -- equivalent call inferred; original call site unknown
end

Global.ToggleSettingsWindow = Toggle
task.spawn(function()
	while not HUD.IsInitialized do
		task.wait()
	end

	assert(HUD.IsInitialized, "bad HUD")
	HUD:RegisterPage("Settings", function()
		return openSettingsMenu()
	end, function(...)
		return Global.closeSettingsMenu(...)
	end, function()
		return v6
	end)
end)
parent.Activated:Connect(Toggle)
close.Activated:Connect(Toggle)

local function FastModeToggle(flag: boolean)
	if flag then
		if Global.FastMode or Global.reducing then
			return
		end

		Global.reducing = true
		Global.FastMode = true
		Global.FastModeCache = {}
		local map = workspace:WaitForChild("Map")
		local unloaded = game.ReplicatedStorage:WaitForChild("Unloaded")
		local clock = os.clock
		local wait = task.wait
		local smoothPlastic = Enum.Material.SmoothPlastic

		local function fn(descendants)
			local now = clock()

			for _, instance in next, descendants, nil do
				if instance:IsA("BasePart") then
					Global.FastModeCache[instance] = instance.Material
					instance.Material = smoothPlastic

					if clock() - now > 0.008333333333333333 then
						wait()
						now = clock()
					end
				elseif instance:IsA("Texture") and not instance:GetAttribute("Offset") then
					instance:Destroy()
				end
			end
		end

		fn(map:GetDescendants())
		fn(unloaded:GetDescendants())
		local optimizerClientActor = game.Players.LocalPlayer.PlayerScripts:FindFirstChild("OptimizerClientActor")

		if optimizerClientActor and optimizerClientActor.SendMessage then
			optimizerClientActor:SendMessage("Optimize", true)
		end
	else
		Global.FastMode = false
		Global.reducing = false

		if Global.FastModeCache then
			for k, material in pairs(Global.FastModeCache) do
				if k and k.Parent then
					k.Material = material
				end
			end
		end

		Global.FastModeCache = nil
		local optimizerClientActor = game.Players.LocalPlayer.PlayerScripts:FindFirstChild("OptimizerClientActor")

		if optimizerClientActor and optimizerClientActor.SendMessage then
			optimizerClientActor:SendMessage("Optimize", false)
		end
	end
end

local function SetCameraShake(flag: boolean)
	local CameraShake = require(game.ReplicatedStorage.Util.CameraShake)

	if CameraShake.SetEnabled then
		CameraShake:SetEnabled(flag)
	end

	local CameraShaker = require(game.ReplicatedStorage.Util.CameraShaker)

	if CameraShaker.SetEnabled then
		CameraShaker:SetEnabled(flag)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ReduceMotionToggle(REDUCE_MOTION: boolean)
	Global.REDUCE_MOTION = REDUCE_MOTION
end

v4 = GetButton("BackgroundMusic")

if v4 then
	local v7 = true
	local success, result = pcall(function() end)

	if success and typeof(result) == "boolean" then
		v7 = result
	end

	v3 = not v7
	Global2.MusicMutedChanged:Fire(v3)

	if v4 then
		v4.SetState(not v3)
	end

	local v8 = v3 and 0 or 1
	Groups.setSettingFactor("LowPriority", v8)
	v4.SetState(v7)
	v4.First.Activated:Connect(function()
		AnalyticsUtil.reportActivity("HUD/Button/Mute")
		v3 = false
		Global2.MusicMutedChanged:Fire(v3)

		if v4 then
			v4.SetState(not v3)
		end

		local v9 = v3 and 0 or 1
		Groups.setSettingFactor("LowPriority", v9)
	end)
	v4.Second.Activated:Connect(function()
		AnalyticsUtil.reportActivity("HUD/Button/Mute")
		v3 = true
		Global2.MusicMutedChanged:Fire(v3)

		if v4 then
			v4.SetState(not v3)
		end

		local v9 = v3 and 0 or 1
		Groups.setSettingFactor("LowPriority", v9)
	end)
end

local button = GetButton("AllyVFX")

if button then
	button.SetState(true)
	button.First.Activated:Connect(function()
		button.SetState(true)
		AnalyticsUtil.reportActivity("HUD/Button/Settings/DisableAllyEffects")
		game.Players.LocalPlayer:SetAttribute("DisableAllyEffects", false)
	end)
	button.Second.Activated:Connect(function()
		button.SetState(false)
		AnalyticsUtil.reportActivity("HUD/Button/Settings/DisableAllyEffects")
		game.Players.LocalPlayer:SetAttribute("DisableAllyEffects", true)
	end)
end

local button2 = GetButton("FastMode")

if button2 then
	button2.SetState(false)
	button2.First.Activated:Connect(function()
		if Global.reducing then
			return
		end

		AnalyticsUtil.reportActivity("HUD/Button/Settings/FastMode")
		button2.SetState(true)
		FastModeToggle(true)
	end)
	button2.Second.Activated:Connect(function()
		AnalyticsUtil.reportActivity("HUD/Button/Settings/FastMode")
		button2.SetState(false)
		Global.FastMode = false
		Global.reducing = false

		if Global.FastModeCache then
			for k, material in pairs(Global.FastModeCache) do
				if k and k.Parent then
					k.Material = material
				end
			end
		end

		Global.FastModeCache = nil
		local optimizerClientActor = game.Players.LocalPlayer.PlayerScripts:FindFirstChild("OptimizerClientActor")

		if optimizerClientActor and optimizerClientActor.SendMessage then
			optimizerClientActor:SendMessage("Optimize", false)
		end
	end)
end

local button3 = GetButton("ReduceMotion")

if button3 then
	button3.SetState(false)
	button3.First.Activated:Connect(function()
		AnalyticsUtil.reportActivity("HUD/Button/Settings/ReduceMotion")
		button3.SetState(true)
		ReduceMotionToggle(true) -- equivalent call inferred; original call site unknown
	end)
	button3.Second.Activated:Connect(function()
		AnalyticsUtil.reportActivity("HUD/Button/Settings/ReduceMotion")
		button3.SetState(false)
		ReduceMotionToggle(false) -- equivalent call inferred; original call site unknown
	end)
end

local button4 = GetButton("CameraShake")

if button4 then
	local v11 = true
	local success, result = pcall(function() end)

	if success and typeof(result) == "boolean" then
		v11 = result
	end

	button4.SetState(v11)
	SetCameraShake(v11)
	button4.First.Activated:Connect(function()
		AnalyticsUtil.reportActivity("HUD/Button/Settings/CameraShake")
		button4.SetState(true)
		SetCameraShake(true)
		changeSetting:FireServer("CameraShake", true)
	end)
	button4.Second.Activated:Connect(function()
		AnalyticsUtil.reportActivity("HUD/Button/Settings/CameraShake")
		button4.SetState(false)
		SetCameraShake(false)
		changeSetting:FireServer("CameraShake", false)
	end)
end

local button5 = GetButton("DamageCounter")

if button5 then
	local success, result = pcall(function()
		return getSetting:InvokeServer("DmgCounter")
	end)

	if not success or typeof(result) ~= "boolean" then
		result = false
	end

	task.spawn(function()
		if workspace:GetAttribute("MAP") == "Dungeons" then
			result = true
			button5.SetState(true)
		end
	end)

	while not Global.dmgCounter do
		task.wait()
	end

	Global.dmgCounter.Enabled = result
	button5.SetState(result)
	button5.First.Activated:Connect(function()
		AnalyticsUtil.reportActivity("HUD/Button/Settings/DamageCounter")
		Global.dmgCounter.Enabled = true
		button5.SetState(true)
		changeSetting:FireServer("DmgCounter", true)
	end)
	button5.Second.Activated:Connect(function()
		AnalyticsUtil.reportActivity("HUD/Button/Settings/DamageCounter")
		Global.dmgCounter.Enabled = false
		button5.SetState(false)
		changeSetting:FireServer("DmgCounter", false)
	end)
end

local enablePvP = settingsMenu.Content.ScrollingFrame:FindFirstChild("EnablePvP", true)

if enablePvP then
	local enablePvPButton = localPlayer.PlayerGui.Topbar.Frame.Buttons.EnablePvPButton
	local toggleButton = enablePvP:WaitForChild("ToggleButton")
	local pvPButton = parent.Parent:WaitForChild("PvPButton")

	local function fn()
		local trans = toggleButton:FindFirstChild("Trans")
		local textLabel = toggleButton:FindFirstChild("TextLabel")

		if localPlayer:GetAttribute("PvpDisabled") then
			toggleButton.BackgroundColor3 = Color3.fromRGB(158, 158, 158)
			toggleButton.BorderColor3 = Color3.fromRGB(128, 128, 128)

			if trans then
				trans.BackgroundColor3 = Color3.fromRGB(191, 191, 191)
			end

			if textLabel then
				textLabel.Text = "Enable"

				if textLabel:FindFirstChild("TextLabel") then
					textLabel.TextLabel.Text = "Enable"
				end
			end
		end
	end

	localPlayer:GetAttributeChangedSignal("PvpDisabled"):Connect(function()
		local pvpDisabled = localPlayer:GetAttribute("PvpDisabled") or false
		pvPButton:SetAttribute("IsEnabled", pvpDisabled == true)
		enablePvPButton:SetAttribute("IsEnabled", pvpDisabled == true)
		pvPButton.Visible = pvpDisabled == true
		enablePvPButton.Visible = pvpDisabled == true
		enablePvP.Visible = pvpDisabled == true
		fn()
	end)
	fn()
	local pvpDisabled = localPlayer:GetAttribute("PvpDisabled") or false
	pvPButton:SetAttribute("IsEnabled", pvpDisabled == true)
	enablePvPButton:SetAttribute("IsEnabled", pvpDisabled == true)
	pvPButton.Visible = pvpDisabled == true
	enablePvPButton.Visible = pvpDisabled == true
	enablePvP.Visible = pvpDisabled == true
	fn()
	toggleButton.Activated:Connect(function()
		AnalyticsUtil.reportActivity("HUD/Button/Settings/EnablePvP")
		Global.closeSettingsMenu()

		if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("EnablePvp") then
			fn()
		end
	end)

	local function fn2()
		if not pvPButton:GetAttribute("IsEnabled") then
			return
		end

		AnalyticsUtil.reportActivity("HUD/Button/PvPShortcut")
		Global.closeSettingsMenu()

		if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("EnablePvp") then
			pvPButton:SetAttribute("IsEnabled", false)
			enablePvPButton:SetAttribute("IsEnabled", false)
			localPlayer:SetAttribute("PvpDisabled", false)
		end
	end

	pvPButton.Activated:Connect(fn2)
	ReplicatedStorage.Events.EnablePvP.Event:Connect(fn2)
end

local function styleButton(instance, flag: boolean)
	local color = Color3.fromRGB(255, 214, 49)
	local color2 = Color3.fromRGB(136, 61, 0)
	local color3 = Color3.fromRGB(255, 241, 87)
	local color4 = Color3.fromRGB(158, 158, 158)
	local color5 = Color3.fromRGB(128, 128, 128)
	local color6 = Color3.fromRGB(191, 191, 191)
	local trans = instance:FindFirstChild("Trans")

	if flag then
		instance.BackgroundColor3 = color
		instance.BorderColor3 = color2

		if trans then
			trans.BackgroundColor3 = color3
		end
	else
		instance.BackgroundColor3 = color4
		instance.BorderColor3 = color5

		if trans then
			trans.BackgroundColor3 = color6
		end
	end
end

local v12 = false
local skillMode = settingsMenu.Content.ScrollingFrame:FindFirstChild("SkillMode")

-- equivalent calls inferred from this helper; original call sites unknown
local function reflectSkillModeRowVisibility()
	skillMode.Visible = LastInput2:IsMobile() and v12
end

local controlScheme = settingsMenu.Content.ScrollingFrame:FindFirstChild("ControlScheme")

if controlScheme then
	if not Flags.NEW_MOBILE_CONTROLS_OPTION_ENABLED then
		controlScheme.Visible = false
		return
	end

	controlScheme.Visible = true
	local firstButton = controlScheme:WaitForChild("FirstButton")
	local secondButton = controlScheme:WaitForChild("SecondButton")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyVisual()
		styleButton(firstButton, not v12)
		styleButton(secondButton, v12)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setScheme(result: boolean)
		if v12 == result then
			return
		end

		v12 = result
		applyVisual() -- equivalent call inferred; original call site unknown
		reflectSkillModeRowVisibility() -- equivalent call inferred; original call site unknown
		MobileUIController:SetNewUIEnabled(result)
		changeSetting:FireServer("MobileSchemeMode", result)
	end

	local _, result = pcall(function()
		return getSetting:InvokeServer("MobileSchemeMode")
	end)
	setScheme(result) -- equivalent call inferred; original call site unknown
	firstButton.Activated:Connect(function()
		AnalyticsUtil.reportActivity("HUD/Button/Settings/MobileLayoutLegacy")
		setScheme(false) -- equivalent call inferred; original call site unknown
	end)
	secondButton.Activated:Connect(function()
		AnalyticsUtil.reportActivity("HUD/Button/Settings/MobileLayoutModern")
		setScheme(true) -- equivalent call inferred; original call site unknown
	end)
end

local skillMode2 = settingsMenu.Content.ScrollingFrame:FindFirstChild("SkillMode")

if skillMode2 then
	if not Flags.NEW_MOBILE_CONTROLS_OPTION_ENABLED then
		controlScheme.Visible = false
		return
	end

	local firstButton = skillMode2.FirstButton
	local secondButton = skillMode2.SecondButton
	local v13 = 1

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyVisual()
		styleButton(firstButton, v13 == 1)
		styleButton(secondButton, v13 == 2)
	end

	local function setScheme(p)
		if p == v13 then
			return
		end

		v13 = p
		applyVisual() -- equivalent call inferred; original call site unknown
		MobileUIController:SetMobileSkillMode(p)
		changeSetting:FireServer("MobileSkillMode", p)
	end

	local success, result = pcall(function()
		return getSetting:InvokeServer("MobileSkillMode")
	end)

	if success and typeof(result) == "number" then
		v13 = result
	else
		v13 = 1
	end

	applyVisual() -- equivalent call inferred; original call site unknown
	MobileUIController:SetMobileSkillMode(v13)
	firstButton.Activated:Connect(function()
		if v13 == 1 then
			return
		end

		v13 = 1
		applyVisual() -- equivalent call inferred; original call site unknown
		MobileUIController:SetMobileSkillMode(1)
		changeSetting:FireServer("MobileSkillMode", 1)
	end)
	secondButton.Activated:Connect(function()
		if v13 == 2 then
			return
		end

		v13 = 2
		applyVisual() -- equivalent call inferred; original call site unknown
		MobileUIController:SetMobileSkillMode(2)
		changeSetting:FireServer("MobileSkillMode", 2)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function reflectLastInput()
	local isMobile = LastInput2:IsMobile()

	if controlScheme then
		controlScheme.Visible = isMobile
	end

	if skillMode2 then
		reflectSkillModeRowVisibility() -- equivalent call inferred; original call site unknown
	end
end

reflectLastInput() -- equivalent call inferred; original call site unknown
LastInput2.Changed:Connect(reflectLastInput)

if workspace:GetAttribute("MAP") == "Dungeons" then
	local v13

	if workspace:GetAttribute("MAP") == "Dungeons" and game.PrivateServerId ~= "" then
		v13 = game.PrivateServerOwnerId == 0
	else
		v13 = false
	end

	local v14

	if workspace:GetAttribute("MAP") == "Dungeons" then
		v14 = not v13
	else
		v14 = false
	end

	if v14 then
		if button then
			button.SetState(false)
		end
	elseif v13 and v4 then
		v4.SetState(true)
	end
end