local ReplicatedStorage = game:GetService("ReplicatedStorage")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local DataController = require(legacyControllers.DataController)
local HudController = require(legacyControllers.HudController)
local SettingsController = require(legacyControllers.SettingsController)
local BindCanvasToLayout = require(script.Parent.Parent:WaitForChild("BindCanvasToLayout"))
local modules = script:WaitForChild("Modules")
local playerDataReplicator = DataController.PlayerDataReplicator
local right = HudController:GetSafeZone().equipment.Right
local container = right.Container
local defaultList = right.Top.DefaultList
local legacyList = right.LegacyList
local v = "Baits"
local color = Color3.fromRGB(161, 255, 192)
local color2 = Color3.fromRGB(34, 45, 33)

-- equivalent calls inferred from this helper; original call sites unknown
local function createSearchBar(search, scrollingFrame)
	local textBox = search:WaitForChild("TextBox")

	local function updateSearch()
		local lower = textBox.Text:match("^%s*(.-)%s*$"):lower()

		for _, frame in ipairs(scrollingFrame:GetChildren()) do
			if frame:IsA("Frame") then
				frame.Visible = (frame:GetAttribute("SearchName") or frame.Name):lower():find(lower, 1, true) ~= nil
			end
		end
	end

	textBox:GetPropertyChangedSignal("Text"):Connect(updateSearch)
end

return {
	Init = function(self)
		playerDataReplicator:WaitForLoaded()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function connectModule(moduleScript)
			if not moduleScript:IsA("ModuleScript") then
				return
			end

			local success, result = pcall(require, moduleScript)

			if not success then
				warn(result)
			elseif result.Init then
				result:Init()
			end
		end

		for _, child in modules:GetChildren() do
			connectModule(child) -- equivalent call inferred; original call site unknown
		end

		modules.ChildAdded:Connect(connectModule)

		local function updateTab(text: string)
			local v2 = v
			v = text

			if v2 ~= text then
				local child = defaultList:FindFirstChild(v2)
				local child2 = legacyList:FindFirstChild(v2)
				child.UIStroke.Color = Color3.fromRGB(255, 255, 255)
				child.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				child.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
				child.Label.TextTransparency = 0.6
				child2.UIStroke.Color = Color3.fromRGB(255, 255, 255)
				child2.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
				child2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

				if container:FindFirstChild(v2) then
					local findFirstChild = container:FindFirstChild(v2)
					findFirstChild.Visible = false
				end
			end

			local child = defaultList:FindFirstChild(text)
			local child2 = legacyList:FindFirstChild(text)
			child.UIStroke.Color = color
			child.BackgroundColor3 = color2
			child.Label.TextColor3 = color
			child.Label.TextTransparency = 0
			child2.UIStroke.Color = color
			child2.Label.TextColor3 = color
			child2.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			defaultList.Parent.Label.Text = text

			if container:FindFirstChild(text) then
				local findFirstChild_2 = container:FindFirstChild(text)
				findFirstChild_2.Visible = true
			end
		end

		updateTab(v)

		for _, button in defaultList:GetChildren() do
			if not button:IsA("GuiButton") then
				continue
			end

			local child = container:FindFirstChild(button.Name)

			if child then
				BindCanvasToLayout(child.ScrollingFrame, child.ScrollingFrame.UIListLayout)
				createSearchBar(child.Search, child.ScrollingFrame) -- equivalent call inferred; original call site unknown
			end

			local v2 = button
			button.Activated:Connect(function()
				if v == v2.Name then
					return
				end

				updateTab(v2.Name)
			end)
			local child2 = legacyList:FindFirstChild(button.Name)

			if not child2 then
				continue
			end

			local v3 = button
			child2.Activated:Connect(function()
				if v == v3.Name then
					return
				end

				updateTab(v3.Name)
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setTabStyle()
			local settingValue = SettingsController:GetSettingValue("newEquipment")
			defaultList.Visible = settingValue
			legacyList.Visible = not settingValue
			defaultList.Parent.Label.Visible = not settingValue
		end

		setTabStyle() -- equivalent call inferred; original call site unknown
		SettingsController:GetSettingChangedSignal("newEquipment"):Connect(setTabStyle)
	end
}