local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local HudController = require(legacyControllers.HudController)
local SettingsController = require(legacyControllers.SettingsController)
local DropdownController = require(legacyControllers.DropdownController)
local components = script:WaitForChild("Components")
local safeZone = HudController:GetSafeZone()
local equipment = safeZone.equipment
local header = equipment.Header
local categories = header.Categories
local ignoreList = header.IgnoreList
local textBox = ignoreList.Search.TextBox
local layoutMode = ignoreList.LayoutMode
local localPlayer = game.Players.LocalPlayer
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
local defaultTab = "Rods"
local v2 = "List"
local v3 = DropdownController.new({
	Tabs = {
		{
			Name = "Rods",
			DisplayName = "Fishing Rods",
			Icon = "rbxassetid://116443856502229",
			Color = Color3.fromRGB(255, 243, 153)
		},
		{
			Name = "Harpoon Guns",
			Icon = "rbxassetid://126100986015670",
			Color = Color3.fromRGB(255, 158, 237)
		},
		{
			Name = "Spears",
			Icon = "rbxassetid://103196543061822",
			Color = Color3.fromRGB(172, 255, 153)
		}
	},
	DefaultTab = defaultTab,
	Parent = categories,
	ScaleWithParent = true
})
local v4 = {}
local v5 = nil
local visibleChangedConnection = nil

local function updatePositions()
	local guiInset, v6 = GuiService:GetGuiInset()
	local v7 = v6 + Vector2.new(0, 90)
	equipment.Size = UDim2.new(0.65, -guiInset.X - v7.X, 0.95, -guiInset.Y - v7.Y)
	equipment.Position = UDim2.new(0.5, guiInset.X / 2 - v7.X / 2, 0.475, guiInset.Y / 2 - v7.Y / 2)
	local absoluteSize = safeZone.AbsoluteSize
	equipment.UISizeConstraint.MaxSize = Vector2.new(
		math.max(800, (math.min(absoluteSize.X * 1, absoluteSize.Y * 0.55 * 1.71))),
		(math.max(800, absoluteSize.Y * 0.532))
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function syncHeaderWidgets()
	local visible

	if v5 == nil then
		visible = false
	else
		visible = v5.MainFrame.Visible
	end

	textBox.Parent.Visible = visible
	layoutMode.Visible = visible
end

local function switchMainTab(p: string)
	local v6 = v4[p]

	if not v6 then
		warn((`no equipment main tab registered for "{p}"`))
		return
	end

	categories.Label.Text = p == "Rods" and "Fishing Rods" or p

	if v6 == v5 then
		return
	end

	if v5 then
		v5.Container.Visible = false
		v5:SetActive(false)
	end

	if visibleChangedConnection then
		visibleChangedConnection:Disconnect()
		visibleChangedConnection = nil
	end

	v5 = v6
	defaultTab = p
	textBox.PlaceholderText = `Search {p}..`
	ignoreList.Search.HelpButton:SetAttribute("TooltipText", v6.SearchTip)
	v6:SetLayout(v2)
	v6:UpdateSearch(textBox.Text)
	v6.Container.Visible = true
	v6:SetActive(true)
	header.Complete.Visible = v6.ShowsCompletion

	if v6.UpdateHeader then
		v6:UpdateHeader()
	end

	visibleChangedConnection = v6.MainFrame:GetPropertyChangedSignal("Visible"):Connect(syncHeaderWidgets)
	syncHeaderWidgets() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setLayout(p: string)
	layoutMode.Image = p == "Grid" and "rbxassetid://86982304983859" or "rbxassetid://107365577833906"
	v2 = p

	if v5 then
		v5:SetLayout(p)
	end
end

return {
	Start = function(_)
		local assetsloaded = localPlayer:WaitForChild("assetsloaded")

		while not assetsloaded.Value do
			task.wait()
		end

		local function connectComponent(moduleScript)
			if not moduleScript:IsA("ModuleScript") then
				return
			end

			local success, result = pcall(require, moduleScript)

			if not success then
				warn(result)
				return
			end

			if typeof(result) == "table" and result.TabName then
				v4[result.TabName] = result
				result.Container.Visible = false
			end

			if result.Init then
				result:Init()
			end
		end

		for _, folder in components:GetChildren() do
			if folder:IsA("Folder") then
				for _, child in folder:GetChildren() do
					connectComponent(child)
				end
			else
				connectComponent(folder)
			end
		end

		components.DescendantAdded:Connect(connectComponent)
		equipment:GetPropertyChangedSignal("Visible"):Connect(updatePositions)
		safeZone:GetPropertyChangedSignal("AbsoluteSize"):Connect(updatePositions)
		updatePositions()
		local dropdownOverlay = equipment.DropdownOverlay

		local function toggleOverlay(flag: boolean)
			TweenService:Create(dropdownOverlay, tweenInfo, {
				BackgroundTransparency = flag and 0.15 or 1
			}):Play()
			local uIGradient = dropdownOverlay.UIGradient
			uIGradient.Offset = Vector2.new(0, flag and -0.5 or 0)
			TweenService:Create(uIGradient, tweenInfo, {
				Offset = Vector2.new(0, flag and 0 or -0.5)
			}):Play()
			dropdownOverlay.Active = flag
			dropdownOverlay.Selectable = flag
			dropdownOverlay.Interactable = flag
		end

		v3.Switched:Connect(function(p, p2)
			if p2 then
				v3:Hide()
			end

			switchMainTab(p)
		end)
		v3.Toggled:Connect(toggleOverlay)
		categories.Activated:Connect(function()
			v3:Toggle()
		end)
		dropdownOverlay.Activated:Connect(function()
			v3:Hide()
		end)
		textBox:GetPropertyChangedSignal("Text"):Connect(function()
			if v5 then
				v5:UpdateSearch(textBox.Text)
			end
		end)
		layoutMode.Activated:Connect(function()
			setLayout(v2 == "Grid" and "List" or "Grid") -- equivalent call inferred; original call site unknown
		end)

		local function applyLayoutSetting()
			local settingValue = SettingsController:GetSettingValue("rodLayoutMode")

			if settingValue == "Grid" or settingValue == "List" then
				setLayout(settingValue) -- equivalent call inferred; original call site unknown
			end
		end

		SettingsController:GetSettingChangedSignal("rodLayoutMode"):Connect(applyLayoutSetting)
		setLayout(v2) -- equivalent call inferred; original call site unknown
		task.defer(applyLayoutSetting)
		switchMainTab(defaultTab)
	end
}