local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = { Enum.KeyCode.R, Enum.KeyCode.DPadLeft }
local _ = {
	Enum.KeyCode.ButtonA,
	Enum.KeyCode.ButtonR2,
	Enum.UserInputType.MouseButton1,
	Enum.UserInputType.Touch
}
local RadialMenu = require(ReplicatedStorage.packages.RadialMenu)
local fx = require(ReplicatedStorage.shared.modules.fx)
local module = require("./SettingsController")
local module2 = require("./HudController")
local module3 = require("@self/TargetHandlers")
local ui = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui")
local QuickAccessController = {
	Menu = nil,
	Segments = {},
	Enabled = false,
	Gui = nil
}
local blurEffect = Instance.new("BlurEffect")
blurEffect.Name = "quickAccessBlur"
blurEffect.Enabled = false
blurEffect.Size = 32
blurEffect.Parent = game:GetService("Lighting")

function QuickAccessController:UpdateTooltip(p: number?, p2: number?)
	local gui = QuickAccessController.Gui
	local menu = QuickAccessController.Menu

	if not (gui and menu) then
		return
	end

	local settingValue = module:GetSettingValue((`qaSlot{p}`))
	local v2 = module3[settingValue.type]

	if v2 and settingValue.target ~= "" then
		gui.container.nameLabel.Text = v2.GetDescription(settingValue.target)
	else
		gui.container.nameLabel.Text = "Customize the Quick Access menu in Settings"
	end

	local radial = p2 and menu:GetRadial(p2)
	local radial2 = p and menu:GetRadial(p)

	if radial then
		radial.ImageColor3 = Color3.new(0, 0, 0)
		radial.ImageTransparency = 0.75
	end

	if radial2 then
		radial2.ImageColor3 = Color3.fromRGB(255, 255, 255)
		radial2.ImageTransparency = 0.5
		fx:PlaySound(ui.select, gui, false)
	end
end

function QuickAccessController:BuildWheel()
	local clone = script.quickAccess:Clone()
	clone.Enabled = false
	QuickAccessController.Gui = clone
	local menu = RadialMenu.new(8, 0.4, 0)
	menu.Enabled = false
	menu.DeadZoneIn = 0.25
	menu:SetRadialProps({
		ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = 0.75
	})
	menu:SetDialProps({
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		ImageTransparency = 0.5
	})
	menu.Frame.Parent = clone.container
	QuickAccessController.Menu = menu
	menu.Clicked:Connect(function(p)
		QuickAccessController:Select(p)
	end)
	clone:GetPropertyChangedSignal("Enabled"):Connect(function()
		if clone.Enabled and not menu.Enabled then
			QuickAccessController:Open()
		elseif not clone.Enabled and menu.Enabled then
			QuickAccessController:Close()
		end
	end)
	menu.Hover:Connect(function(p, p2)
		QuickAccessController:UpdateTooltip(p2, p)
	end)
	clone.Parent = module2:GetPlayerGui()
end

function QuickAccessController:UpdateWheelContents()
	if not QuickAccessController.Enabled then
		return
	end

	for i = 1, 8 do
		if QuickAccessController.Segments[i] then
			QuickAccessController.Segments[i]:Destroy()
		end

		local settingValue = module:GetSettingValue((`qaSlot{i}`))
		local v2 = module3[settingValue.type]

		if not (v2 and settingValue.target ~= "") then
			continue
		end

		local display, v3 = v2.GetDisplay(settingValue.target)

		if display == "Icon" or display == "IconSmall" then
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Image = v3
			imageLabel.BackgroundTransparency = 1
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.Position = UDim2.fromScale(0.5, 0.5)
			imageLabel.Size = display == "IconSmall" and UDim2.fromScale(0.5, 0.5) or UDim2.fromScale(1, 1)
			imageLabel.ScaleType = Enum.ScaleType.Fit
			imageLabel.Parent = QuickAccessController.Menu:GetAttachment(i)
			QuickAccessController.Segments[i] = imageLabel
		elseif display == "Text" then
			local textLabel = Instance.new("TextLabel")
			textLabel.Text = v3
			textLabel.BackgroundTransparency = 1
			textLabel.Size = UDim2.fromScale(1, 1)
			textLabel.TextScaled = true
			textLabel.FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.SemiBold)
			textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			local uIStroke = Instance.new("UIStroke")
			uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
			uIStroke.Thickness = 1
			uIStroke.Transparency = 0.2
			uIStroke.Color = Color3.new(0, 0, 0)
			uIStroke.Parent = textLabel
			local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
			uITextSizeConstraint.MaxTextSize = 16
			uITextSizeConstraint.Parent = textLabel
			textLabel.Parent = QuickAccessController.Menu:GetAttachment(i)
			QuickAccessController.Segments[i] = textLabel
		end
	end

	if QuickAccessController.Menu and QuickAccessController.Menu._LastHoverIndex then
		QuickAccessController:UpdateTooltip(QuickAccessController.Menu._LastHoverIndex)
	end
end

function QuickAccessController:Select(p: number)
	local settingValue = module:GetSettingValue((`qaSlot{p}`))
	local v2 = module3[settingValue.type]

	if v2 and settingValue.target ~= "" then
		task.spawn(v2.Select, settingValue.target)
	end

	QuickAccessController:Close()
end

function QuickAccessController:IsOpen()
	return QuickAccessController.Gui and QuickAccessController.Gui.Enabled or QuickAccessController.Menu and QuickAccessController.Menu.Enabled or false
end

function QuickAccessController:Open()
	if not (QuickAccessController.Enabled and (module2:GetHud().Enabled and module2:GetBackpackGui().Enabled)) then
		return
	end

	QuickAccessController:UpdateWheelContents()

	if QuickAccessController.Gui then
		QuickAccessController.Gui.Enabled = true
		fx:PlaySound(ui.popup, QuickAccessController.Gui, false)
	end

	if QuickAccessController.Menu then
		QuickAccessController.Menu.Enabled = true
	end

	blurEffect.Enabled = true
end

function QuickAccessController:Close()
	if QuickAccessController.Gui and QuickAccessController.Gui.Enabled then
		QuickAccessController.Gui.Enabled = false
		fx:PlaySound(ui.open, QuickAccessController.Gui, false)
	end

	if QuickAccessController.Menu then
		QuickAccessController.Menu.Enabled = false
	end

	blurEffect.Enabled = false
end

function QuickAccessController:Toggle()
	if QuickAccessController:IsOpen() then
		QuickAccessController:Close()
	else
		QuickAccessController:Open()
	end
end

function QuickAccessController._HandleOpenInput(_, p, p2)
	if not (module2:GetHud().Enabled and module2:GetBackpackGui().Enabled) then
		return Enum.ContextActionResult.Pass
	end

	if p2.UserInputType.Name:find("^Gamepad") then
		if p == Enum.UserInputState.Begin then
			QuickAccessController:Toggle()
		end
	elseif p == Enum.UserInputState.Begin then
		QuickAccessController:Open()
	elseif p == Enum.UserInputState.End or p == Enum.UserInputState.Cancel then
		local theta = QuickAccessController.Menu:GetTheta(Enum.UserInputType.MouseMovement)

		if theta and QuickAccessController:IsOpen() then
			QuickAccessController:Select(QuickAccessController.Menu:PickIndex(theta))
		end

		QuickAccessController:Close()
	end

	return Enum.ContextActionResult.Sink
end

function QuickAccessController:Enable()
	if QuickAccessController.Enabled then
		return
	end

	QuickAccessController.Enabled = true
	QuickAccessController:BuildWheel()
	QuickAccessController:UpdateWheelContents()
	ContextActionService:BindActionAtPriority(
		"OpenQuickAccess",
		QuickAccessController._HandleOpenInput,
		false,
		Enum.ContextActionPriority.Medium.Value,
		table.unpack(v)
	)
end

function QuickAccessController:Disable()
	if not QuickAccessController.Enabled then
		return
	end

	QuickAccessController.Enabled = false

	if QuickAccessController.Menu then
		QuickAccessController.Menu:Destroy()
		QuickAccessController.Menu = nil
	end

	if QuickAccessController.Gui then
		QuickAccessController.Gui:Destroy()
		QuickAccessController.Gui = nil
	end

	ContextActionService:UnbindAction("OpenQuickAccess")
end

function QuickAccessController.Start(_)
	local hud = module2:GetHud()
	hud:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not hud.Enabled then
			QuickAccessController:Close()
		end
	end)
	local backpackGui = module2:GetBackpackGui()
	backpackGui:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not backpackGui.Enabled then
			QuickAccessController:Close()
		end
	end)
	module:GetSettingChangedSignal("quickAccessEnabled"):Connect(function(p)
		if p then
			QuickAccessController:Enable()
		else
			QuickAccessController:Disable()
		end
	end)

	if module:GetSettingValue("quickAccessEnabled") then
		QuickAccessController:Enable()
	end
end

return QuickAccessController