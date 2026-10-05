local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local v2 = require3(ReplicatedStorage3.Shared.VRService)
local v3 = require3(ReplicatedStorage3.Packages.Replion)
local v4 = require3(ReplicatedStorage3.Packages.Net)
local v5 = require3(ReplicatedStorage3.Common.SettingsInfo)
local v6 = require3(ReplicatedStorage3.ClientGameModules.GuiHandler)
local v7 = require3(script.SliderNode)
local v8 = require3(ReplicatedStorage3.Controllers.GamepadIconController)
require3(ReplicatedStorage3.Shared.ReplicatedInstances.Swords)
local v9 = require3(script.Parent.UI.TopBarController)
local v10 = require3(script.Parent.UI.TooltipController)
local v11 = require3(ReplicatedStorage3.Shared.FrameCap)
local v12 = require3(ReplicatedStorage3.ServerInfo)
local v13 = require3(ReplicatedStorage3.Shared.ReplionUtils)
local v14 = require3(ReplicatedStorage3.Packages.Observers)
local v15 = require3(ReplicatedStorage3.Shared.LTM)
local v16 = require3(ReplicatedStorage3.Shared.FastUtils)
local v17 = require3(ReplicatedStorage3.ClientGameModules.Color)
local v18 = require3(ReplicatedStorage3.Shared.Statable)
local v19 = require3(ReplicatedStorage3.Shared.TitleData)
local v20 = require3(ReplicatedStorage3.Controllers.PromptController)
local v21 = nil
local serverInfo = ReplicatedStorage3.ServerInfo
local localPlayer = Players.LocalPlayer
local mouse = Players.LocalPlayer:GetMouse()
local terrain = workspace.Terrain
local waterWaveSize = terrain.WaterWaveSize
local waterWaveSpeed = terrain.WaterWaveSpeed
local waterReflectance = terrain.WaterReflectance
local waterTransparency = terrain.WaterTransparency
workspace:WaitForChild("Runtime")
local v22 = {}
v11(250)
local v23 = {
	MouseButton1 = "rbxassetid://127900005477571",
	MouseButton2 = "rbxassetid://140199660699461",
	MouseButton3 = "rbxassetid://84550204392976"
}

local function getHotbarMouseIcon(parent)
	local mouseIcon = parent:FindFirstChild("MouseIcon")

	if mouseIcon then
		return mouseIcon
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "MouseIcon"
	imageLabel.BackgroundTransparency = 1
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel.Size = UDim2.fromScale(0.78, 0.78)
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Visible = false
	imageLabel.ZIndex = parent.ZIndex + 1
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.AspectRatio = 1
	uIAspectRatioConstraint.Parent = imageLabel
	imageLabel.Parent = parent
	return imageLabel
end

local function applyHotbarBind(parent, p2, text: string, mappedImageForKeyCode: string?, p3: string?, flag: boolean)
	local controllerIcon = parent.ControllerIcon
	local hotbarMouseIcon = getHotbarMouseIcon(parent)
	local image

	if p3 then
		image = v23[p3]
	end

	local visible

	if mappedImageForKeyCode == nil then
		visible = false
	else
		visible = mappedImageForKeyCode ~= ""
	end

	local visible2 = not visible and image ~= nil
	p2.Text = text
	p2.Visible = not (visible or visible2)
	controllerIcon.Visible = visible
	controllerIcon.Position = UDim2.fromScale(0.5, 0.5)
	parent.ImageTransparency = 0

	if visible then
		parent.ImageTransparency = 1
		controllerIcon.Position = UDim2.fromScale(0.628, 0.366)
		controllerIcon.Size = UDim2.new(1.035, 0, 1.019, 0)
		controllerIcon.Image = mappedImageForKeyCode
	end

	hotbarMouseIcon.Visible = visible2

	if visible2 then
		hotbarMouseIcon.Image = image
	end

	parent.Visible = not flag
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setBindDisplay(instance, p: string?, text: string)
	if not instance then
		return
	end

	local textBox = instance:FindFirstChild("TextBox")
	local mouseIcon = instance:FindFirstChild("MouseIcon")
	local v24

	if p then
		v24 = v23[p]
	end

	if mouseIcon then
		mouseIcon.Image = v24 or ""
		mouseIcon.Visible = v24 ~= nil
	end

	if textBox then
		textBox.Text = text
		textBox.Visible = v24 == nil
	end
end

local function decToColor3(p: number)
	return Color3.fromHex(string.format("%06x", p))
end

local function isSettingBlocked(p: string, p2: string)
	local v24 = v5[p] and v5[p][p2]

	if v24 and v24.BlockedBy and v21 then
		return v21:Get({
			"Settings",
			p,
			v24.BlockedBy,
			"Enabled"
		}) == true
	end

	return false
end

local function settingDisplayValue(p: string, p2: string)
	local v24 = v5[p] and v5[p][p2]

	if not v24 then
		return nil
	end

	if isSettingBlocked(p, p2) then
		return v24.Default
	end

	return v21 and v21:Get({
		"Settings",
		p,
		p2,
		"Current"
	}) or v24.Default
end

local function refreshSettingRow(instance, p: string, p2: string)
	local settingBlocked = isSettingBlocked(p, p2)
	instance.Interactable = not settingBlocked
	local textLabel = instance:FindFirstChild("TextLabel")

	if textLabel then
		textLabel.TextTransparency = settingBlocked and 0.6 or 0
	end

	local v24 = v22[p2]

	if v24 then
		local v25 = settingDisplayValue(p, p2)

		if v25 ~= nil then
			v24:Update(v25, p2)
		end
	end

	local button = instance:FindFirstChild("Button", true)

	if button then
		button.AutoButtonColor = not settingBlocked
		button.BackgroundTransparency = settingBlocked and 0.6 or 0
		local icon = button:FindFirstChild("Icon")

		if icon then
			icon.Visible = not settingBlocked and (v21 and v21:Get({
				"Settings",
				p,
				p2,
				"Enabled"
			})) ~= false
			icon.ImageTransparency = settingBlocked and 0.6 or 0
		end
	end
end

local function getHighlight()
	local color = Color3.fromRGB(255, 30, 30)

	if not v21 then
		return color
	end

	local v24 = v21:Get("Settings.Accessibility.Highlight Color.Current")

	if v24 then
		return decToColor3(v24)
	end

	return color
end

local v24 = {}
local SettingsController = {}
local inputBeganConnection = nil
local v25 = nil
local v26 = {
	MouseWheel = "Scroll",
	MouseButton1 = "Mouse 1",
	MouseButton2 = "Mouse 2",
	MouseButton3 = "Mouse 3"
}
local playerGui = nil
local v27 = {
	PC = {
		Ability = "Q",
		Block = "F"
	}
}
local v28 = false
local v29 = true
local v30 = true
local v31 = false
local header = nil
local frame = nil
local v32 = { "VR Parry Sensitivity", "VR Hand Switch Sensitivity" }
local v33 = { "Max Zoom" }
local settingSlider = nil
local settingColor = nil
local settingSubSlider = nil
local settingTimeOfDay = nil
local v34 = nil
local settings = nil
local v35 = nil
local clones = {}
local v36 = {}
local clones2 = {}
local v37 = nil
local v38 = { "Tap Screen To Block", "Button Layouts" }
local v39 = { "Hide UI During Match" }
local v40 = nil
local v41 = nil
local v42 = nil
local v43 = nil
local v44 = nil
local HUD = nil
local frame2 = nil
local uIListLayout = nil
local settingKeybind = nil
local settingToggle = nil
local closeButton = nil
local creatorCode = nil
local cancel = nil
local v45 = {
	["Button Layouts"] = "EditButtonLayout"
}

for _, v46 in Enum.UserInputType:GetEnumItems() do
	v24[v46.Name] = v46
end

local v46 = {}

for _, v47 in Enum.KeyCode:GetEnumItems() do
	v46[v47.Name] = v47
end

function SettingsController.IsType(_, p)
	return v24[p] or v46[p] or ""
end

local stringForKeyCodes = {}

local function GetStringForKeyCode(p)
	local stringForKeyCode = stringForKeyCodes[p]

	if stringForKeyCode == nil then
		stringForKeyCode = v:GetStringForKeyCode(p)
		stringForKeyCodes[p] = stringForKeyCode
	end

	return stringForKeyCode
end

function SettingsController:CanGetStringForKeyCode(p)
	local stringForKeyCode = stringForKeyCodes[p]

	if stringForKeyCode == nil then
		stringForKeyCode = v:GetStringForKeyCode(p)
		stringForKeyCodes[p] = stringForKeyCode
	end

	return stringForKeyCode ~= ""
end

function SettingsController:CustomGetStringForKeyCode(p)
	local stringForKeyCode = stringForKeyCodes[p]

	if stringForKeyCode == nil then
		stringForKeyCode = v:GetStringForKeyCode(p)
		stringForKeyCodes[p] = stringForKeyCode
	end

	if stringForKeyCode == "" or not stringForKeyCode then
		stringForKeyCode = p.Name
	end

	return stringForKeyCode
end

function SettingsController:GetDefault(p)
	local lastInputType = v:GetLastInputType()
	local default = v5.Keybinds[p].Default
	return string.find(lastInputType.Name, "Gamepad") and default.Console or default.PC
end

function SettingsController:GetBinds(p)
	debug.profilebegin("SettingsController:GetBinds")

	if not v21 then
		debug.profileend()
		return
	end

	local lastInputType = v:GetLastInputType()
	local settings2 = v21.Data.Settings

	if not settings2 then
		debug.profileend()
		return
	end

	local keybind = settings2.Keybinds[p]

	if not keybind then
		debug.profileend()
		return
	end

	if lastInputType ~= Enum.UserInputType.Focus then
		debug.profileend()
		return string.find(lastInputType.Name, "Gamepad") and keybind.Console or keybind.PC
	end

	debug.profileend()

	if #v:GetConnectedGamepads() >= 1 or GuiService:IsTenFootInterface() then
		return keybind.Console
	end

	return keybind.PC
end

function SettingsController:BindConnection(p, p2, p3)
	if inputBeganConnection then
		inputBeganConnection:Disconnect()
	end

	p3.Parent.Active = false
	task.wait()
	inputBeganConnection = v.InputBegan:Connect(function(input, _: boolean)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			v25:FireServer("PC", p, p2, input.KeyCode.Name)
		elseif v26[input.UserInputType.Name] then
			v25:FireServer("PC", p, p2, input.UserInputType.Name)
		end

		if inputBeganConnection then
			inputBeganConnection:Disconnect()
			p3.Parent.Active = true
		end
	end)
end

function SettingsController.GetBindButton(_, tag)
	for _, v47 in CollectionService:GetTagged(tag) do
		if v47:IsDescendantOf(playerGui) then
			return v47
		end
	end
end

function SettingsController:GetBindButtons(tag)
	debug.profilebegin("GetBindButtons")
	local result = {}

	for _, v47 in CollectionService:GetTagged(tag) do
		if v47:IsDescendantOf(playerGui) then
			table.insert(result, v47)
		end
	end

	debug.profileend()
	return result
end

function SettingsController:UpdateHotbar(p, p2)
	debug.profilebegin("UpdateHotbar")
	local default = self:GetDefault(p)

	if p2 == "" then
		p2 = default
	end

	local v47 = v46[p2]
	local v48 = v47 ~= nil
	local v49 = v48 and self:CanGetStringForKeyCode(v47)
	local stringForKeyCode

	if v48 and v49 then
		stringForKeyCode = stringForKeyCodes[v47]

		if stringForKeyCode == nil then
			stringForKeyCode = v:GetStringForKeyCode(v47)
			stringForKeyCodes[v47] = stringForKeyCode
		end

		if not stringForKeyCode then
			stringForKeyCode = v27[p] or default
		end
	else
		stringForKeyCode = v27[p] or default
	end

	local mappedImageForKeyCode = v48 and v8:GetMappedImageForKeyCode(v47) or ""
	local v50 = v48 and mappedImageForKeyCode ~= ""
	local v51 = v.TouchEnabled and not v.KeyboardEnabled and not (v.GamepadEnabled or GuiService:IsTenFootInterface())

	if not v23[p2] then
		p2 = nil
	end

	if not v50 then
		mappedImageForKeyCode = nil
	end

	if p == "Block" then
		for _, v52 in self:GetBindButtons("UI_BlockBind") do
			applyHotbarBind(v52, v52.F, stringForKeyCode, mappedImageForKeyCode, p2, v51)
		end
	elseif p == "Ability" then
		for _, v52 in self:GetBindButtons("UI_AbilityBind") do
			applyHotbarBind(v52, v52.Q, stringForKeyCode, mappedImageForKeyCode, p2, v51)
		end

		for _, v52 in self:GetBindButtons("UI_TradingSignBind") do
			applyHotbarBind(v52, v52.Q, "1", mappedImageForKeyCode, nil, v51)
		end
	end

	debug.profileend()
end

local object = setmetatable({}, {
	__mode = "k"
})

function SettingsController:SetType(part)
	if object[part] ~= nil then
		return
	end

	local className = part.ClassName

	if part:IsA("BasePart") and part.Material ~= Enum.Material.Neon then
		object[part] = part.Material.Name
	elseif className == "ParticleEmitter" or className == "Trail" then
		object[part] = part.Lifetime
	elseif className == "Beam" then
		object[part] = part.Enabled
	end
end

local function shouldUpdateObject(instance)
	return instance:IsDescendantOf(workspace)
end

function SettingsController:UpdateObject(flag: boolean, flag2: boolean)
	debug.profilebegin("SettingsController.UpdateObject")

	if self:GetAttribute("IgnoreLowGraphics") then
		debug.profileend()
		return
	end

	if not v21 then
		debug.profileend()
		return
	end

	SettingsController:SetType(self)
	local v47 = object[self]

	if v47 == nil then
		debug.profileend()
		return
	end

	local className = self.ClassName

	if self:IsA("BasePart") and self.Material ~= Enum.Material.Neon then
		if v47 == nil then
			debug.profileend()
			return
		end

		local material

		if v28 then
			material = Enum.Material.SmoothPlastic
		else
			material = Enum.Material[v47]
		end

		self.Material = material
	elseif className == "ParticleEmitter" or className == "Trail" then
		if v47 == nil then
			debug.profileend()
			return
		end

		if v28 and not flag2 or flag then
			self.Lifetime = className == "Trail" and 0 or NumberRange.new(0)

			if className == "ParticleEmitter" then
				self:Clear()
			end
		else
			self.Lifetime = v47
		end
	elseif className == "Beam" then
		if v28 and not flag2 or flag then
			self.Enabled = false
		else
			self.Enabled = v47
		end
	end

	debug.profileend()
end

function SettingsController:RefreshSword(folder)
	local hasTag = folder:HasTag("ExceptionVFX")

	for _, descendant in folder:GetDescendants() do
		SettingsController.UpdateObject(descendant, not v29, hasTag)
	end
end

function SettingsController:RefreshSwords()
	for _, v47 in CollectionService:GetTagged("SwordModel") do
		if v47:IsDescendantOf(workspace) then
			SettingsController:RefreshSword(v47)
		end
	end
end

function SettingsController:RefreshParryFX(folder)
	local v47 = folder:GetAttribute("FXName") == "ParticleShine"

	for _, descendant in folder:GetDescendants() do
		SettingsController.UpdateObject(descendant, not v29, v47)
	end
end

function SettingsController:RefreshParryFXs()
	for _, v47 in CollectionService:GetTagged("ParryFX") do
		if v47:IsDescendantOf(workspace) then
			SettingsController:RefreshParryFX(v47)
		end
	end
end

function SettingsController:RefreshExplosion(folder)
	for _, descendant in folder:GetDescendants() do
		SettingsController.UpdateObject(descendant, not v30, false)
	end
end

function SettingsController:RefreshExplosions()
	for _, v47 in CollectionService:GetTagged("ExplosionVFX") do
		if v47:IsDescendantOf(workspace) then
			SettingsController:RefreshExplosion(v47)
		end
	end
end

function SettingsController:RefreshTerrainQuality()
	if not v21 then
		return
	end

	local v47 = v21:Get({
		"Settings",
		"Misc",
		"Gray Sky",
		"Enabled"
	}) or false
	terrain.WaterWaveSize = v28 and 0 or waterWaveSize or 0
	terrain.WaterWaveSpeed = v28 and 0 or waterWaveSpeed or 0
	terrain.WaterReflectance = v47 and 0.02 or v28 and 0 or waterReflectance or 0
	terrain.WaterTransparency = v47 and 0.05 or v28 and 0 or waterTransparency or 0
end

function SettingsController:RefreshQuality()
	if not v21 then
		return
	end

	self:RefreshTerrainQuality()
	self:RefreshSwords()
	self:RefreshParryFXs()
	self:RefreshExplosions()
end

function SettingsController:LoadSettings()
	if not v21 then
		return
	end

	local settings2 = v21:Get("Settings")

	if not settings2 or v31 or not next(settings2) then
		return
	end

	if not (settings2.Keybinds and settings2.Misc) then
		return
	end

	v31 = true
	local remoteEvent = v4:RemoteEvent("AdjustMusicVolume")

	for k, v47 in v5 do
		local clone = header:Clone()
		clone.LayoutOrder = v47.LayoutOrder
		clone.TextLabel.Text = k
		clone.Parent = frame

		for k2, v48 in v47 do
			if k2 == "LayoutOrder" or v48.DoNotDisplay then
				continue
			end

			local index = table.find(v32, k2)
			local index2 = table.find(v33, k2)
			local v49 = index or index2 or v48.TemplateType == "Slider"
			local clone2 = v49 and settingSlider:Clone() or v48.Type == "Color" and settingColor:Clone() or v48.TemplateType == "SubSlide" and settingSubSlider:Clone() or v48.TemplateType == "TimeOfDay" and settingTimeOfDay:Clone() or v34[k]:Clone()
			clone2.Name = `{k}/{k2}`
			clone2.LayoutOrder = v48.LayoutOrder

			if v48.TemplateType and string.find(v48.TemplateType, "Sub") then
				clone2.Frame.TextLabel.Text = v48.DisplayName or k2
			else
				clone2.TextLabel.Text = v48.DisplayName or k2
			end

			if v48.Type then
				if v48.Type == "Color" then
					local v50 = nil
					local finishedConnection = nil
					local canceledConnection = nil

					-- equivalent calls inferred from this helper; original call sites unknown
					local function disconnect()
						if finishedConnection then
							finishedConnection:Disconnect()
							finishedConnection = nil
						end

						if canceledConnection then
							canceledConnection:Disconnect()
							canceledConnection = nil
						end

						if v50 then
							v50:Destroy()
							v50 = nil
						end
					end

					local v51 = k
					local v52 = k2
					clone2.Button.Activated:Connect(function()
						if not v21 then
							return
						end

						v50 = v17.New(settings, mouse, {
							Position = UDim2.new(0.35, 0, 0.35, 0)
						})
						v50.Instance.Parent.ZIndex = 999999
						v50:SetColor(decToColor3(v21:Get({
							"Settings",
							v51,
							v52,
							"Current"
						}) or 16711680))
						finishedConnection = v50.Finished:Connect(function(p)
							v35:FireServer(v51, v52, p)
							disconnect() -- equivalent call inferred; original call site unknown
						end)
						canceledConnection = v50.Canceled:Connect(function()
							disconnect() -- equivalent call inferred; original call site unknown
						end)
					end)
					local v53 = k
					local v54 = k2
					clone2.ResetButton.Activated:Connect(function()
						v35:FireServer(v53, v54, nil)
					end)
					local v55 = k
					local v56 = k2
					local v57 = clone2
					v3.Client:AwaitReplion("Data", function(object3)
						local function update()
							local v58 = object3:Get({
								"Settings",
								v55,
								v56,
								"Current"
							})
							v57.Button.BackgroundColor3 = Color3.fromHex(string.format("%06x", v58 or 16711680))
							v57.ResetButton.Visible = v58 and true or false
						end

						object3:OnChange({
							"Settings",
							v55,
							v56,
							"Current"
						}, update)
						update()
					end)
					v6:OnGuiClose("Settings", function()
						if v50 then
							disconnect() -- equivalent call inferred; original call site unknown
						end
					end)
				end
			elseif k == "Volume" then
				local v50 = k2
				local v51 = v7.new(clone2, k2, function(p)
					remoteEvent:FireServer(v50, p)
				end, v5.Volume[k2].Max)
				v51:Update(settings2.Volume[k2].Current, k2)
				v22[k2] = v51
			elseif k == "Keybinds" then
				clone2.Visible = v:GetLastInputType() ~= Enum.UserInputType.Touch
				clone.Visible = clone2.Visible
				local v50 = clone2
				local v51 = clone
				v.LastInputTypeChanged:Connect(function(p)
					v50.Visible = p ~= Enum.UserInputType.Touch
					v51.Visible = v50.Visible
				end)
				local binds = SettingsController:GetBinds(k2)
				local bind1 = binds.Bind1
				local bind2 = binds.Bind2
				local bind3 = binds.Bind3
				local default = self:GetDefault(k2)
				clones[k2] = clone2
				self:UpdateHotbar(k2, bind1)

				if bind1 ~= "" then
					default = bind1
				end

				setBindDisplay(clone2.Keybind1, default, v26[default] or default) -- equivalent call inferred; original call site unknown
				local v53 = k2
				local v54 = clone2
				clone2.Keybind1.Activated:Connect(function()
					self:BindConnection("Bind1", v53, v54.Keybind1.TextBox)
				end)
				local v55 = k2
				clone2.Keybind1.SelectionGained:Connect(function()
					v36 = { "Bind1", v55 }
				end)
				clone2.Keybind1.SelectionLost:Connect(function()
					table.clear(v36)
				end)
				setBindDisplay(clone2.Keybind2, bind2, v26[bind2] or bind2) -- equivalent call inferred; original call site unknown
				local v57 = k2
				local v58 = clone2
				clone2.Keybind2.Activated:Connect(function()
					self:BindConnection("Bind2", v57, v58.Keybind2.TextBox)
				end)
				local v59 = k2
				clone2.Keybind2.SelectionGained:Connect(function()
					v36 = { "Bind2", v59 }
				end)
				clone2.Keybind2.SelectionLost:Connect(function()
					table.clear(v36)
				end)

				if bind3 and k2 == "Block" then
					clone2.Keybind3.Visible = true
					setBindDisplay(clone2.Keybind3, bind3, v26[bind3] or bind3) -- equivalent call inferred; original call site unknown
					local v61 = "Block"
					local v62 = clone2
					clone2.Keybind3.Activated:Connect(function()
						self:BindConnection("Bind3", v61, v62.Keybind3.TextBox)
					end)
					local v63 = "Block"
					clone2.Keybind3.SelectionGained:Connect(function()
						v36 = { "Bind3", v63 }
					end)
					clone2.Keybind3.SelectionLost:Connect(function()
						table.clear(v36)
					end)
				else
					clone2.Keybind3.Visible = false
				end

				local v60 = k2
				clone2.ResetButton.Activated:Connect(function()
					local lastInputType = v:GetLastInputType()
					local default2 = self:GetDefault(v60)

					if string.find(lastInputType.Name, "Gamepad") then
						v25:FireServer("Console", "Reset", v60, default2)
					else
						v25:FireServer("PC", "Reset", v60, default2)
					end
				end)
			elseif k == "Misc" then
				clones2[k2] = clone2
				local misc = settings2.Misc or {}
				local button

				if v49 or v48.TemplateType == "SubSlide" then
					button = nil
				else
					button = clone2.Button
					button.Position = UDim2.new(
						clone2.TextLabel.Position.X.Scale,
						clone2.TextLabel.TextBounds.X + button.AbsoluteSize.X / 2 + 12,
						button.Position.Y.Scale,
						0
					)
					local enabled = (misc[k2] or {}).Enabled
					button.Icon.Visible = enabled == nil or enabled
					local v50 = k2
					button.Activated:Connect(function()
						v37:FireServer(v50)
					end)
					local v51 = clone2
					clone2.TextLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
						button.Position = UDim2.new(
							v51.TextLabel.Position.X.Scale,
							v51.TextLabel.TextBounds.X + button.AbsoluteSize.X / 2 + 12,
							button.Position.Y.Scale,
							0
						)
					end)
					clone2.Tooltip.Visible = v48.Tooltip ~= nil

					if v48.Tooltip then
						clone2.ZIndex = 10
						v10:New(clone2.Tooltip, v48.Tooltip)
					end
				end

				if table.find(v38, k2) == nil then
					if table.find(v39, k2) then
						local v50 = clone2
						v.LastInputTypeChanged:Connect(function(p)
							v50.Visible = p ~= Enum.UserInputType.Touch
						end)
					elseif index then
						local v50 = k2
						v22[k2] = v7.new(clone2, k2, function(p)
							remoteEvent:FireServer(v50, p)
						end, v5.Misc[k2].Max, { "", "http://www.roblox.com/asset/?id=14892548930" })
						clone2.Visible = v2.VREnabled
						local v52 = clone2
						v2.VREnabledChanged:Connect(function()
							v52.Visible = v2.VREnabled
						end)
					elseif index2 then
						local v50 = k2
						local v51 = v7.new(clone2, k2, function(p)
							remoteEvent:FireServer(v50, p)
						end, v5.Misc[k2].Max, {
							"rbxasset://textures/ui/ScreenshotHud/Camera.png",
							"rbxasset://textures/ui/ScreenshotHud/Camera.png"
						})
						v22[k2] = v51
						clone2.Visible = v.GamepadEnabled
						v51:Update(settings2.Misc[k2] and settings2.Misc[k2].Current or v5.Misc[k2].Default, k2)
						local v52 = clone2
						v.LastInputTypeChanged:Connect(function(p)
							v52.Visible = p.Name:find("Gamepad") ~= nil
						end)

						if k2 == "Max Zoom" then
							-- equivalent calls inferred from this helper; original call sites unknown
							local function updateMaxZoom(p)
								workspace.CurrentCamera:SetAttribute("GamepadZoomSteps", 3 + (tonumber(p) or 1))
							end

							v21:OnChange({
								"Settings",
								"Misc",
								"Max Zoom",
								"Current"
							}, updateMaxZoom)
							local v53 = "Max Zoom"
							workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
								updateMaxZoom(v21:Get({
									"Settings",
									"Misc",
									v53,
									"Current"
								})) -- equivalent call inferred; original call site unknown
							end)
							updateMaxZoom(v21:Get({
								"Settings",
								"Misc",
								"Max Zoom",
								"Current"
							})) -- equivalent call inferred; original call site unknown
						end
					elseif v48.TemplateType == "SubSlide" or v48.TemplateType == "Slider" then
						if v48.RequireSettingEnable then
							clone2.Visible = false
							-- equivalent calls inferred from this helper; original call sites unknown
							local v50 = clone2
							local v51 = "Misc"
							local v52 = v48

							local function updateVisibility()
								v50.Visible = v21:Get({
									"Settings",
									v51,
									v52.RequireSettingEnable,
									"Enabled"
								})
							end

							updateVisibility() -- equivalent call inferred; original call site unknown
							v21:OnChange({
								"Settings",
								"Misc",
								v48.RequireSettingEnable,
								"Enabled"
							}, updateVisibility)
						end

						local frame3

						if v48.TemplateType == "SubSlide" then
							frame3 = clone2.Frame
						else
							frame3 = clone2
						end

						local v50 = k2
						local v51 = v7.new(frame3, k2, function(p)
							remoteEvent:FireServer(v50, p)
						end, v5.Misc[k2].Max, { "", "http://www.roblox.com/asset/?id=14892548930" })
						v22[k2] = v51
						v51:Update(settings2.Misc[k2] and settings2.Misc[k2].Current or v5.Misc[k2].Default, k2)
						frame3.Tooltip.Visible = v48.Tooltip ~= nil

						if v48.Tooltip then
							v10:New(frame3.Tooltip, v48.Tooltip)
						end
					elseif v48.TemplateType == "TimeOfDay" then
						local v50 = v7.new(clone2, k2, function(p: number)
							v4:RemoteEvent("SetTimeOfDay"):FireServer("Misc", "Time Of Day", p)
						end, 144, { "", "http://www.roblox.com/asset/?id=14892548930" })
						v22[k2] = v50
						v50:Update(settings2.Misc[k2] and settings2.Misc[k2].Current or v5.Misc[k2].Default, k2)
					elseif k2 == "Server Region" then
						button:Destroy()
						clone2.TextLabel.Text = "Server Region: " .. serverInfo.Region.Value
					elseif k2 == "Server Version" then
						button:Destroy()
						clone2.TextLabel.Text = "Server Version: " .. serverInfo.ServerVersion.Value
					end
				else
					local v50 = clone2
					v.LastInputTypeChanged:Connect(function(p)
						v50.Visible = p == Enum.UserInputType.Touch
					end)
				end
			end

			if v48.BlockedBy then
				-- equivalent calls inferred from this helper; original call sites unknown
				local v50 = clone2
				local v51 = k
				local v52 = k2

				local function updateBlocked()
					refreshSettingRow(v50, v51, v52)
				end

				updateBlocked() -- equivalent call inferred; original call site unknown
				v21:OnChange({
					"Settings",
					k,
					v48.BlockedBy,
					"Enabled"
				}, updateBlocked)
			end

			clone2.Parent = frame
		end
	end
end

function SettingsController.UpdateAllSliders()
	if not v21 then
		return
	end

	for k, v47 in v22 do
		local v48 = v5.Volume[k] or v5.Misc[k]

		if not v48 then
			continue
		end

		local v50 = settingDisplayValue(v5.Volume[k] == nil and "Misc" or "Volume", k) or v48.Default
		local default = v48.Default
		v47:Update(v50, k)

		if k == "Music" then
			SoundService.Music.Volume = 0.5 * v50 / default
		elseif k == "SFX" then
			SoundService.SFX.Volume = 0.5 * v50 / default
			SoundService.UI.Volume = 0.5 * v50 / default
		end
	end
end

function SettingsController.UpdateAllKeybinds()
	if not v21 then
		return
	end

	for k, v47 in clones do
		local binds = SettingsController:GetBinds(k)
		local default = SettingsController:GetDefault(k)
		local bind1 = binds.Bind1
		local bind2 = binds.Bind2
		local bind3 = binds.Bind3
		local v48 = v46[bind1] or default
		local text = v46[bind1] ~= nil and SettingsController:CustomGetStringForKeyCode(v48) or v26[bind1] and v26[bind1] or v26[default] or default
		local v50 = v46[bind2] or ""
		local text2 = v46[bind2] ~= nil and SettingsController:CustomGetStringForKeyCode(v50) or not v26[bind2] and "" or v26[bind2] or ""
		local v52 = v46[bind3] or ""
		local text3 = v46[bind3] ~= nil and SettingsController:CustomGetStringForKeyCode(v52) or not v26[bind3] and "" or v26[bind3] or ""
		SettingsController:UpdateHotbar(k, bind1)
		local keybind1 = v47.Keybind1

		if bind1 ~= "" then
			default = bind1
		end

		setBindDisplay(keybind1, default, text) -- equivalent call inferred; original call site unknown
		setBindDisplay(v47.Keybind2, bind2, text2) -- equivalent call inferred; original call site unknown
		setBindDisplay(v47.Keybind3, bind3, text3) -- equivalent call inferred; original call site unknown
	end
end

local thread = nil

function SettingsController.ScheduleUpdateAllKeybinds()
	if thread then
		task.cancel(thread)
		thread = nil
	end

	thread = task.delay(0.1, function()
		thread = nil
		SettingsController.UpdateAllKeybinds()
	end)
end

function SettingsController.UpdateAllMisc()
	if not v21 then
		return
	end

	local settings2 = v21:Get("Settings")

	for k, v47 in clones2 do
		local v48 = false
		local v49

		if k ~= "Time Of Day" then
			v49 = v22[k]
		end

		if v49 then
			v49:Update(settingDisplayValue("Misc", k) or v5.Misc[k].Default, k)
			v48 = true
		end

		if v48 then
			continue
		end

		local button = v47:FindFirstChild("Button", true)

		if button and settings2.Misc[k] then
			button.Icon.Visible = settings2.Misc[k].Enabled and not isSettingBlocked("Misc", k)
		end
	end
end

function SettingsController.ResetSettingsToDefault()
	for k, v47 in v5.Volume do
		if typeof(v47) == "table" then
			v40:FireServer(k, v47.Default)
		end
	end

	for k, keybind in v5.Keybinds do
		if typeof(keybind) ~= "table" then
			continue
		end

		v25:FireServer("PC", "Reset", k, keybind.Default.PC)
		v25:FireServer("Console", "Reset", k, keybind.Default.Console)
	end

	for k, v47 in v5.Accessibility do
		if typeof(v47) == "table" and v47.Type == "Color" then
			v35:FireServer("Accessibility", k, nil)
		end
	end

	for k, v47 in v5.Misc do
		if typeof(v47) ~= "table" or not v47.Validate or v47.ResetIgnore then
			continue
		end

		local v48 = string.match(k, "^(.+)ButtonPosition$")
		local v49 = string.match(k, "^(.+)ButtonScale$")

		if v48 then
			v41:FireServer(v48, v47.Default)
		elseif v49 then
			v42:FireServer(v49, v47.Default)
		elseif k == "Time Of Day" then
			v43:FireServer("Misc", "Time Of Day", v47.Default)
			v37:FireServer("Time Of Day", v47.Enabled == true)
		elseif v47.Max == nil then
			v37:FireServer(k, v47.Enabled == true)
		else
			v40:FireServer(k, v47.Default)
		end
	end
end

function SettingsController.UseBind(_, p, p2: string)
	if not v21 then
		return
	end

	debug.profilebegin("SettingsController:Usebind")
	local _ = v21.Data.Settings
	local binds = SettingsController:GetBinds(p2)
	local default = SettingsController:GetDefault(p2)

	if binds.Bind1 ~= "" then
		default = binds.Bind1 or default
	end

	local userInputType = p.UserInputType
	local keyCode = p.KeyCode
	local binds2 = SettingsController:GetBinds("Block")
	local v48

	if v.MouseBehavior == Enum.MouseBehavior.LockCenter and userInputType == Enum.UserInputType.MouseButton2 and binds2.Bind1 ~= Enum.UserInputType.MouseButton2.Name and binds2.Bind2 ~= Enum.UserInputType.MouseButton2.Name and binds2.Bind3 ~= Enum.UserInputType.MouseButton2.Name then
		v48 = p2 == "Ability"
	else
		v48 = false
	end

	local v49 = (keyCode.Name == default or keyCode.Name == binds.Bind2 or keyCode.Name == binds.Bind3 or userInputType.Name == default or userInputType.Name == binds.Bind2 or userInputType.Name == binds.Bind3 or v48) and true or false
	debug.profileend()
	return v49
end

function SettingsController.Init(_) end

function SettingsController:Start()
	local v47 = #v:GetConnectedGamepads() >= 1 or GuiService:IsTenFootInterface()
	self:UpdateHotbar("Block", v47 and "ButtonR1" or nil)
	self:UpdateHotbar("Ability", v47 and "ButtonX" or nil)
	v21 = v3.Client:WaitReplion("Data")

	if not v21 then
		return
	end

	v21:OnChange({
		"Settings",
		"Misc",
		"Low Graphics",
		"Enabled"
	}, function(p)
		v28 = p == true
		self:RefreshQuality()
	end)
	v28 = v21:Get({
		"Settings",
		"Misc",
		"Low Graphics",
		"Enabled"
	}) == true
	v21:OnChange({
		"Settings",
		"Misc",
		"Weapon VFX",
		"Enabled"
	}, function(p)
		v29 = p ~= false
		self:RefreshSwords()
		self:RefreshParryFXs()
	end)
	v29 = v21:Get({
		"Settings",
		"Misc",
		"Weapon VFX",
		"Enabled"
	}) ~= false
	v21:OnChange({
		"Settings",
		"Misc",
		"Explosion VFX",
		"Enabled"
	}, function(p)
		v30 = p ~= false
		self:RefreshExplosions()
	end)
	v30 = v21:Get({
		"Settings",
		"Misc",
		"Explosion VFX",
		"Enabled"
	}) ~= false
	v40 = v4:RemoteEvent("AdjustMusicVolume")
	v25 = v4:RemoteEvent("ToggleKeybind")
	v37 = v4:RemoteEvent("ToggleMisc")
	v44 = v4:RemoteEvent("ToggleDevice")
	v35 = v4:RemoteEvent("SetColor")
	v43 = v4:RemoteEvent("SetTimeOfDay")
	v41 = v4:RemoteEvent("SetButtonPosition")
	v42 = v4:RemoteEvent("SetButtonScale")
	playerGui = localPlayer:WaitForChild("PlayerGui")
	HUD = playerGui:WaitForChild("HUD")
	settings = playerGui:WaitForChild("Settings")
	frame2 = settings:WaitForChild("Frame")
	frame = frame2:WaitForChild("Frame")
	uIListLayout = frame:WaitForChild("UIListLayout")
	header = uIListLayout:WaitForChild("Header")
	settingSlider = uIListLayout:WaitForChild("SettingSlider")
	settingKeybind = uIListLayout:WaitForChild("SettingKeybind")
	settingToggle = uIListLayout:WaitForChild("SettingToggle")
	closeButton = frame2:WaitForChild("CloseButton")
	creatorCode = frame2:WaitForChild("CreatorCode")
	cancel = creatorCode:WaitForChild("Cancel")
	settingColor = uIListLayout:WaitForChild("SettingColor")
	settingSubSlider = uIListLayout:WaitForChild("SettingSubSlider")
	settingTimeOfDay = uIListLayout:WaitForChild("SettingTimeOfDay")
	v34 = {
		Volume = settingSlider,
		Keybinds = settingKeybind,
		Misc = settingToggle
	}
	self:LoadSettings()
	self.UpdateAllSliders()
	self:RefreshQuality()
	task.delay(3, self.RefreshQuality, self)
	self.UpdateAllMisc()
	v21:OnDescendantChange("Settings", function()
		SettingsController:LoadSettings()
	end)
	v21:OnDescendantChange("Settings.Volume", self.UpdateAllSliders)
	v21:OnDescendantChange("Settings.Keybinds", self.ScheduleUpdateAllKeybinds)
	v21:OnDescendantChange("Settings.Misc", self.UpdateAllMisc)
	v.LastInputTypeChanged:Connect(self.ScheduleUpdateAllKeybinds)
	closeButton.Activated:Connect(function()
		v6:Close("Settings")
	end)
	creatorCode.Activated:Connect(function()
		v6:Open("CreatorCodes")
	end)
	cancel.Activated:Connect(function()
		v4:Invoke("ClearCreatorCode")
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateCreatorCode()
		cancel.Visible = v21:Get("CreatorCodes.Active") ~= nil
		creatorCode.Label.Text = `SUPPORT-A-CREATOR: {v21:Get("CreatorCodes.Active") or "NONE"}`
	end

	v21:OnChange("CreatorCodes.Active", updateCreatorCode)
	updateCreatorCode() -- equivalent call inferred; original call site unknown
	local settings2 = v9:WaitForIcon("Settings")
	settings2.toggled:Connect(function(_, p)
		if p ~= "User" then
			return
		end

		if v6:IsOpen("Settings") then
			v6:Close("Settings")
		else
			v6:Open("Settings")
		end
	end)
	v6:OnClose(function(p)
		if p == settings then
			settings2:deselect()
		end
	end)
	v6:OnOpen(function(p)
		if p == settings then
			settings2:select()
		end
	end)
	v.InputBegan:Connect(function(input, _: boolean)
		if not v6:IsOpen("Settings") then
			return
		end

		if string.find(input.UserInputType.Name, "Gamepad") and v36[1] and v36[2] then
			v25:FireServer("Console", v36[1], v36[2], input.KeyCode.Name)
		end
	end)
	local layoutOrder = 99

	for _, v48 in v5.Misc do
		if typeof(v48) == "table" and v48.LayoutOrder and layoutOrder < v48.LayoutOrder then
			layoutOrder = v48.LayoutOrder
		end
	end

	for k, v48 in pairs(v45) do
		local clone = uIListLayout:FindFirstChild("SettingOpenMenu"):Clone()
		clone.LayoutOrder = layoutOrder
		clone.TextLabel.Text = k
		local v49 = v48
		clone.Button.Activated:Connect(function()
			v6:Open(v49)
		end)
		clone.Parent = frame

		if table.find(v38, k) == nil then
			continue
		end

		local v50 = clone
		v.LastInputTypeChanged:Connect(function(p)
			v50.Visible = p == Enum.UserInputType.Touch
		end)
	end

	local clone = uIListLayout:FindFirstChild("SettingTitles"):Clone()
	clone.LayoutOrder = layoutOrder + 1
	local clone2 = table.clone(v19)
	table.insert(clone2, 1, {
		Name = "None",
		Tag = {
			Text = "None",
			Color = Color3.new(1, 1, 1)
		}
	})
	local updateSizes = {}
	local updates = {}

	for k, v48 in clone2 do
		local clone3 = clone.TitleList.UIListLayout.Template:Clone()
		clone3.LayoutOrder = k
		clone3.TextLabel.Text = v48.Tag.Text
		clone3.TextLabel.TextColor3 = v48.Tag.Color
		local v50 = v48
		local v51 = clone3:FindFirstChild("Selected")

		local function update()
			clone3.Visible = v50.Name == "None" or v21:Get({ "Titles", v50.Name })
			local visible

			if v50.Name == "None" then
				visible = v21:Get("EquippedTitle") == nil
			else
				visible = v21:Get("EquippedTitle") == v50.Name
			end

			v51.Visible = visible

			if visible then
				clone3.Image = "rbxassetid://101973108838865"
				clone3.HoverImage = "rbxassetid://72246188791319"
			else
				clone3.Image = "rbxassetid://137266342109996"
				clone3.HoverImage = "rbxassetid://75518436288869"
			end
		end

		local v52 = clone3

		local function updateSize()
			v52.Size = UDim2.fromScale(0.962, 0) + UDim2.fromOffset(0, 0.12605042016806722 * frame.AbsoluteSize.Y)
		end

		table.insert(updateSizes, updateSize)
		table.insert(updates, update)
		clone3.Parent = clone.TitleList
		local v53 = v48
		clone3.Activated:Connect(function()
			if v53.Name == "None" then
				if v21:Get("EquippedTitle") == nil then
					return
				end

				v4:Invoke("EquipTitle", nil)
			else
				if not v21:Get({ "Titles", v53.Name }) or v21:Get("EquippedTitle") == v53.Name then
					return
				end

				v4:Invoke("EquipTitle", v53.Name)
			end
		end)
	end

	local function updateAllTitles()
		for _, v48 in updates do
			v48()
		end
	end

	local function updateAllTitleSizes()
		for _, v48 in updateSizes do
			v48()
		end
	end

	frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateAllTitleSizes)
	v21:OnChange("Titles", updateAllTitles)
	v21:OnChange("EquippedTitle", updateAllTitles)
	task.spawn(function()
		for _, v48 in updates do
			v48()
		end

		for _, v48 in updateSizes do
			v48()
		end
	end)

	local function updateSize()
		local v48 = 0.09243697478991597 * frame.AbsoluteSize.Y
		clone.Header.Size = UDim2.fromScale(0.98, 0) + UDim2.fromOffset(0, v48)
		clone.TitleList.Position = UDim2.fromScale(0.505, 0) + UDim2.fromOffset(0, v48)
	end

	frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSize)
	task.spawn(updateSize)
	clone.Parent = frame
	local clone3 = uIListLayout:FindFirstChild("SettingOpenMenu"):Clone()
	clone3.Name = "ResetToDefault"
	clone3.LayoutOrder = layoutOrder + 2
	clone3.TextLabel.Visible = false
	clone3.Button.AnchorPoint = Vector2.new(0.5, 0.5)
	clone3.Button.Position = UDim2.fromScale(0.5, 0.5)
	clone3.Button.Size = UDim2.fromScale(0.38, 1)
	local textLabel = clone3.Button:FindFirstChild("TextLabel")

	if textLabel then
		textLabel.Text = "RESET TO DEFAULT"
		textLabel.TextWrapped = false
	end

	local flag = false
	clone3.Button.Activated:Connect(function()
		if flag then
			return
		end

		flag = true
		v20:CreatePrompt({
			PromptType = "Confirm",
			Title = "RESET SETTINGS",
			Description = "Restore every setting to its default? This clears your volume, keybinds, highlight color and mobile button layout, and cannot be undone."
		}, function(flag2: boolean)
			flag = false

			if not flag2 then
				return
			end

			SettingsController.ResetSettingsToDefault()
		end)
	end)
	clone3.Parent = frame
	v14.observeTag("ObjectVFX", function(instance)
		if instance:IsDescendantOf(workspace) then
			SettingsController.UpdateObject(instance, false, false)
		end

		return nil
	end)
	v14.observeTag("SwordModel", function(instance)
		self:RefreshSword(instance)
		local hasTag = instance:HasTag("ExceptionVFX")
		local descendantAddedConnection = instance.DescendantAdded:Connect(function(descendant)
			SettingsController.UpdateObject(descendant, not v29, hasTag)
		end)
		return function()
			descendantAddedConnection:Disconnect()
		end
	end, { workspace })
	v14.observeTag("ExplosionVFX", function(instance)
		self:RefreshExplosion(instance)
		local descendantAddedConnection = instance.DescendantAdded:Connect(function(descendant)
			SettingsController.UpdateObject(descendant, not v30, false)
		end)
		return function()
			descendantAddedConnection:Disconnect()
		end
	end, { workspace })
	CollectionService:GetInstanceAddedSignal("ParryFX"):Connect(function(instance)
		if instance:IsDescendantOf(workspace) then
			self:RefreshParryFX(instance)
		end
	end)

	local function updateFov(flag2: boolean?)
		local fieldOfView = 70 + ((v21:Get({
			"Settings",
			"Misc",
			"FOV",
			"Current"
		}) or 0) - 50) / 2.5

		if not flag2 then
			workspace.CurrentCamera.FieldOfView = fieldOfView
			return
		end

		local _ = workspace.CurrentCamera.FieldOfView
		v16.fastTween(workspace.CurrentCamera, TweenInfo.new(1), {
			FieldOfView = fieldOfView
		})
	end

	task.spawn(updateFov)
	v13.observeReplionPath(v21, "Settings.Misc.FOV.Current", updateFov)
	ReplicatedStorage3.Remotes.ResetFOV.Event:Connect(updateFov)
	local currentLTM = v15.getCurrentLTM()

	if not v12.isLTMServer() or not currentLTM or currentLTM.getGameMode() ~= "SquadRoyale" then
		v14.observeCharacters(function(parent)
			local v48 = nil

			local function update()
				if v21:Get("Settings.Misc.Highlight Players.Enabled") and not parent:GetAttribute("IsFocusedByBall") then
					if v48 then
						return
					end

					local highlight = Instance.new("Highlight")
					highlight.Name = "GrayHighlight"
					highlight.DepthMode = Enum.HighlightDepthMode.Occluded
					highlight.FillColor = Color3.fromRGB(158, 158, 158)
					highlight.FillTransparency = 0.75
					highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
					highlight.OutlineTransparency = 0.5
					highlight.Parent = parent
					v48 = highlight
				elseif v48 then
					v48:Destroy()
					v48 = nil
				end
			end

			update()
			local isFocusedByBallChangedConnection = parent:GetAttributeChangedSignal("IsFocusedByBall"):Connect(update)
			local connection = v21:OnChange("Settings.Misc.Highlight Players.Enabled", update)
			local parentChangedConnection = parent:GetPropertyChangedSignal("Parent"):Connect(function()
				if v48 then
					v48.Parent = parent
				end
			end)
			return function()
				isFocusedByBallChangedConnection:Disconnect()
				connection:Disconnect()
				parentChangedConnection:Disconnect()

				if v48 then
					v48:Destroy()
					v48 = nil
				end
			end
		end)
	end

	v14.observeTag("ColoredHighlight", function(p)
		local color = Color3.fromRGB(255, 30, 30)

		if v21 then
			local v48 = v21:Get("Settings.Accessibility.Highlight Color.Current")

			if v48 then
				color = Color3.fromHex(string.format("%06x", v48))
			end
		end

		p.FillColor = color
		return nil
	end, { workspace })
	v14.observeTag("PlayerTargetHighlight", function(p)
		local parent = p.Parent
		parent:SetAttribute("IsFocusedByBall", true)
		return function()
			parent:SetAttribute("IsFocusedByBall", false)
		end
	end)
	local atmosphere = Lighting:FindFirstChild("Atmosphere")

	if not atmosphere then
		local childAddedConnection = nil
		childAddedConnection = Lighting.ChildAdded:Connect(function(child)
			if child.Name == "Atmosphere" then
				atmosphere = child
				childAddedConnection:Disconnect()
			end
		end)
	end

	local clouds = workspace.Terrain:FindFirstChild("Clouds")
	local fakeSky = ReplicatedStorage3.Misc.FakeSky
	fakeSky.Parent = nil
	local humanoidRootPart = nil
	local renderSteppedConnection = nil

	local function updateFakeSkyTracking()
		local v48

		if fakeSky.Parent == nil then
			v48 = false
		else
			v48 = humanoidRootPart ~= nil
		end

		if v48 == (renderSteppedConnection ~= nil) then
			return
		end

		if v48 then
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local v49 = humanoidRootPart

				if v49 and v49.Parent then
					fakeSky.Position = v49.Position
				end
			end)
		elseif renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end
	end

	local v48 = {
		"Ambient",
		"Brightness",
		"ClockTime",
		"ColorShift_Bottom",
		"ColorShift_Top",
		"EnvironmentDiffuseScale",
		"EnvironmentSpecularScale",
		"FogColor",
		"FogStart",
		"FogEnd",
		"GeographicLatitude",
		"OutdoorAmbient"
	}
	local v49 = {}

	for _, v50 in v48 do
		v49[v50] = Lighting[v50]
	end

	local v50 = {
		Ambient = Color3.fromRGB(100, 100, 100),
		Brightness = 1.5,
		ClockTime = 12,
		ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
		ColorShift_Top = Color3.fromRGB(0, 0, 0),
		EnvironmentDiffuseScale = 0,
		EnvironmentSpecularScale = 0,
		FogColor = Color3.fromRGB(0, 0, 0),
		FogStart = 1000000,
		FogEnd = 1000000,
		GeographicLatitude = 0,
		OutdoorAmbient = Color3.fromRGB(70, 70, 70)
	}

	local function updateLighting()
		if v21:Get({
			"Settings",
			"Misc",
			"Gray Sky",
			"Enabled"
		}) then
			return
		end

		if workspace:GetAttribute("InTheRisingEvent") then
			Lighting.ClockTime = 22
			return
		end

		if workspace:GetAttribute("DoNotChangeNight") then
			return
		end

		local clockTime = workspace:GetAttribute("ForceNight") == true and 20.8 or v21:Get("Settings.Misc.Time Of Day.Enabled") and (v21:Get("Settings.Misc.Time Of Day.Current") or 0) / 6 or 11.2
		local v52 = Lighting
		local color

		if (clockTime > 20 or clockTime < 6) and Color3.fromRGB(100, 100, 100) then
			if v12.isBossFightServer() then
				color = Color3.fromRGB(140, 140, 140)
			else
				color = Color3.fromRGB(111, 111, 111)
			end

			if not color then
				color = Color3.new()
			end
		else
			color = Color3.new()
		end

		v52.Ambient = color
		Lighting.ClockTime = clockTime
	end

	local function updateGraySky()
		local v51 = v21:Get({
			"Settings",
			"Misc",
			"Gray Sky",
			"Enabled"
		})

		for _, attributeName in v48 do
			local attribute = Lighting:GetAttribute(attributeName) or v49[attributeName]
			local v53 = attributeName
			local v54 = v50[attributeName]
			pcall(function()
				Lighting[v53] = v51 and v54 or attribute
			end)
		end

		Lighting.Brightness = v51 and 1.5 or 1.35
		Lighting.GlobalShadows = not v51
		local terrain2 = workspace.Terrain
		local waterColor

		if v51 then
			waterColor = Color3.fromRGB(130, 130, 130)
		else
			waterColor = Color3.fromRGB(8, 39, 54)
		end

		terrain2.WaterColor = waterColor
		self:RefreshTerrainQuality()
		local v53 = fakeSky
		local parent

		if v51 then
			parent = workspace
		end

		v53.Parent = parent
		updateFakeSkyTracking()

		if atmosphere then
			atmosphere.Density = v51 and 0 or 0.35
		end

		if clouds then
			clouds.Enabled = not v51
		end

		updateLighting()
	end

	v14.observeCharacter(localPlayer, function(_, instance)
		humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
		updateFakeSkyTracking()
		return function()
			humanoidRootPart = nil
			updateFakeSkyTracking()
		end
	end)
	v13.observeReplionPath(v21, "Settings.Misc.Time Of Day.Enabled", updateLighting)
	v13.observeReplionPath(v21, "Settings.Misc.Time Of Day.Current", updateLighting)
	v13.observeReplionPath(v21, "Settings.Misc.Gray Sky.Enabled", updateGraySky)
	workspace:GetAttributeChangedSignal("ForceNight"):Connect(updateLighting)
	workspace:GetAttributeChangedSignal("DoNotChangeNight"):Connect(updateLighting)
	workspace:GetAttributeChangedSignal("InTheRisingEvent"):Connect(updateLighting)
	task.spawn(updateGraySky)
	workspace.Map.ChildAdded:Connect(function(_)
		task.wait(0.1)
		updateGraySky()
	end)

	local function observeBall(part)
		if not (part.Name ~= "Collider" and part:IsA("BasePart")) then
			return
		end

		local function setColor(color: Color3)
			if part.Color ~= color then
				part.Color = color
			end

			local highlight = part:FindFirstChildWhichIsA("Highlight")

			if highlight and highlight.FillColor ~= color then
				highlight.FillColor = color
			end

			local trail = part:FindFirstChildWhichIsA("Trail")

			if trail and trail.Color.Keypoints[1].Value ~= color then
				trail.Color = ColorSequence.new(color)
			end
		end

		local function update()
			if not part:GetAttribute("realBall") and part:GetAttribute("highlighted") then
				if localPlayer:GetAttribute("RainbowBall") then
					local v51 = math.round(os.clock() * 10) / 100
					setColor(Color3.fromHSV(v51 % 1, 1, 1))
				else
					local color = Color3.fromRGB(255, 30, 30)

					if v21 then
						local v51 = v21:Get("Settings.Accessibility.Highlight Color.Current")

						if v51 then
							color = Color3.fromHex(string.format("%06x", v51))
						end
					end

					if part:GetAttribute("DribbleActive") then
						color = color:Lerp(Color3.new(), 0.1)
					end

					setColor(color)
				end
			end
		end

		local highlightedChangedConnection = part:GetAttributeChangedSignal("highlighted"):Connect(update)
		local realBallChangedConnection = part:GetAttributeChangedSignal("realBall"):Connect(update)
		local dribbleActiveChangedConnection = part:GetAttributeChangedSignal("DribbleActive"):Connect(update)
		local colorChangedConnection = part:GetPropertyChangedSignal("Color"):Connect(update)
		local connection = v13.observeReplionPath(v21, "Settings.Accessibility.Highlight Color.Current", update)
		local connection2 = v21:BeforeDestroy(function()
			connection:Disconnect()
		end)
		local v51 = v14.observeChildren(part, function(instance)
			if instance:IsA("Highlight") then
				local fillColorChangedConnection = instance:GetPropertyChangedSignal("FillColor"):Connect(update)
				update()
				return function()
					fillColorChangedConnection:Disconnect()
				end
			else
				if not instance:IsA("Trail") then
					return
				end

				local colorChangedConnection2 = instance:GetPropertyChangedSignal("Color"):Connect(update)
				update()
				return function()
					colorChangedConnection2:Disconnect()
				end
			end
		end)
		local renderSteppedConnection2 = nil
		local v52 = v14.observeAttribute(localPlayer, "RainbowBall", function()
			if localPlayer:GetAttribute("RainbowBall") and not renderSteppedConnection2 then
				renderSteppedConnection2 = RunService.RenderStepped:Connect(update)
			end

			return function()
				if not localPlayer:GetAttribute("RainbowBall") and renderSteppedConnection2 then
					renderSteppedConnection2:Disconnect()
					renderSteppedConnection2 = nil
				end
			end
		end)
		return function()
			highlightedChangedConnection:Disconnect()
			realBallChangedConnection:Disconnect()
			dribbleActiveChangedConnection:Disconnect()
			colorChangedConnection:Disconnect()
			connection2:Disconnect()
			connection:Disconnect()
			v51()

			if renderSteppedConnection2 then
				renderSteppedConnection2:Disconnect()
			end

			v52()
		end
	end

	v14.observeDescendants(workspace:WaitForChild("Balls"), observeBall)
	v14.observeDescendants(workspace:WaitForChild("TrainingBalls"), observeBall)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateBallColorAtt()
		localPlayer:SetAttribute(
			"DisableBallColor",
			(localPlayer:GetAttribute("RainbowBall") or v21:Get("Settings.Accessibility.Highlight Color.Current")) and true or false
		)
	end

	v13.observeReplionPath(v21, "Settings.Accessibility.Highlight Color.Current", updateBallColorAtt)
	updateBallColorAtt() -- equivalent call inferred; original call site unknown
	localPlayer:GetAttributeChangedSignal("RainbowBall"):Connect(updateBallColorAtt)
	local v51 = false
	local accessibilityHighlightColor = frame:FindFirstChild("Accessibility/Highlight Color")

	if accessibilityHighlightColor then
		accessibilityHighlightColor.TextLabel.MouseEnter:Connect(function()
			v51 = true
		end)
		accessibilityHighlightColor.TextLabel.MouseMoved:Connect(function()
			v51 = true
		end)
		accessibilityHighlightColor.TextLabel.MouseLeave:Connect(function()
			v51 = false
		end)
	end

	frame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		v51 = false
	end)
	local count = 0
	local v52 = 0
	v.InputBegan:Connect(function(input, _)
		if not v51 then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonA or input.KeyCode == Enum.KeyCode.ButtonX then
			local now = os.clock()

			if now - v52 > 1 then
				count = 0
			end

			count += 1
			v52 = now

			if count == 10 then
				localPlayer:SetAttribute("RainbowBall", not localPlayer:GetAttribute("RainbowBall"))
			end
		end
	end)
	v14.observeTag("EmoteSFX", function(instance)
		local computed = v18.Computed(function(callback)
			if callback((v18.getReplionPathState(v21, "Settings.Misc.Remove Emotes SFX.Enabled"))) then
				instance:SetAttribute("RemoveSFX_Save", instance.Volume)
				instance.Volume = 0
			else
				local removeSFX_Save = instance:GetAttribute("RemoveSFX_Save")

				if removeSFX_Save then
					instance.Volume = removeSFX_Save
					instance:SetAttribute("RemoveSFX_Save", nil)
				end
			end

			return nil
		end)
		return function()
			computed:Destroy()
		end
	end, { workspace })
end

return SettingsController