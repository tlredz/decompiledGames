local MenuHandler = {}
local gUIs = script.Parent.GUIs
local Players = game:GetService("Players")
local playerGui = (Players:GetPlayers()[1] or Players.PlayerAdded:Wait()):WaitForChild("PlayerGui")
local GuiService = game:GetService("GuiService")
local guiInset, _ = GuiService:GetGuiInset()
MenuHandler.toggles = {
	Interpolation = true,
	TweenCursor = true,
	SelectInvisible = false,
	ShowTooltips = true
}
MenuHandler.selectedImage = "http://www.roblox.com/asset/?id=620778172"
MenuHandler.deselectedImage = "http://www.roblox.com/asset/?id=620791039"
MenuHandler.toggleTrigger = false
MenuHandler.clickTrigger = false
MenuHandler.tooltips = {}
MenuHandler.activeWindow = nil
MenuHandler.mouse = nil
MenuHandler.cleanup = {}
MenuHandler.killFunction = nil
MenuHandler.space = nil
MenuHandler.menuHover = false

function MenuHandler.CreateTip()
	MenuHandler.tip = Instance.new("TextLabel")
	MenuHandler.tip.Size = UDim2.new(0, 100, 0, 30)
	MenuHandler.tip.Parent = MenuHandler.space
	MenuHandler.tip.BackgroundTransparency = 1
	MenuHandler.tip.TextXAlignment = Enum.TextXAlignment.Left
	MenuHandler.tip.Text = ""
	MenuHandler.tip.TextColor3 = Color3.new(1, 1, 1)
	MenuHandler.tip.ZIndex = 9
	MenuHandler.tip.FontSize = Enum.FontSize.Size12
	MenuHandler.tip.TextStrokeTransparency = 0.6
end

MenuHandler.CreateTip()

function MenuHandler.Quit()
	for i = #MenuHandler.cleanup, 1, -1 do
		MenuHandler.cleanup[i]:disconnect()
	end

	if MenuHandler.activeWindow then
		MenuHandler.activeWindow:Destroy()
	end

	if MenuHandler.killFunction then
		MenuHandler.killFunction()
		MenuHandler.killFunction = nil
	end

	MenuHandler.tooltips = {}
	MenuHandler.tip.Text = ""
	MenuHandler.tip.Parent = nil
	MenuHandler.activeWindow = nil
end

function MenuHandler.HasActiveWindow()
	return MenuHandler.activeWindow ~= nil
end

function MenuHandler:SetEasingStyle(callback)
	if MenuHandler.activeWindow == nil then
		local clone = gUIs.EasingStyle:Clone()
		local _ = self.EasingStyle.Name
		local name = self.EasingStyle.Name
		local _ = self.EasingDirection.Name
		local name2 = self.EasingDirection.Name

		local function updateColors()
			local v = tostring(name) == "nil" and "Linear" or name

			for _, button in pairs(clone.Styles:GetChildren()) do
				if not button:IsA("TextButton") then
					continue
				end

				if v == button.Name then
					button.BackgroundColor3 = clone.Styles.SelectedColor.Value
				else
					button.BackgroundColor3 = clone.Styles.DeselectedColor.Value
				end
			end

			local v2 = tostring(name2) == "nil" and "In" or name2

			for _, button in pairs(clone.Directions:GetChildren()) do
				if not button:IsA("TextButton") then
					continue
				end

				if v2 == button.Name then
					button.BackgroundColor3 = clone.Directions.SelectedColor.Value
				else
					button.BackgroundColor3 = clone.Directions.DeselectedColor.Value
				end
			end
		end

		for _, button in pairs(clone.Styles:GetChildren()) do
			if not button:IsA("TextButton") then
				continue
			end

			local v = button
			button.MouseButton1Click:Connect(function()
				name = v.Name
				updateColors()
			end)
		end

		for _, button in pairs(clone.Directions:GetChildren()) do
			if not button:IsA("TextButton") then
				continue
			end

			local v = button
			button.MouseButton1Click:Connect(function()
				name2 = v.Name
				updateColors()
			end)
		end

		clone.Submit.MouseButton1Click:Connect(function()
			clone:Destroy()
			MenuHandler.activeWindow = nil

			if self then
				self.EasingStyle = Enum.PoseEasingStyle[name]
				self.EasingDirection = Enum.PoseEasingDirection[name2]
			end

			if callback then
				callback()
			end
		end)
		clone.Cancel.MouseButton1Click:Connect(function()
			clone:Destroy()
			MenuHandler.activeWindow = nil

			if callback then
				callback()
			end
		end)
		updateColors()
		clone.Parent = MenuHandler.space
		MenuHandler.activeWindow = clone
	end
end

function MenuHandler.PromptInput(text, p)
	local text3 = p == nil and "<input>" or p

	if MenuHandler.activeWindow ~= nil then
		return
	end

	local clone = script.Parent.GUIs.InputTemplate:Clone()
	clone.Parent = MenuHandler.space
	MenuHandler.activeWindow = clone
	clone.Title.Text = text
	clone.Input.Text = text3
	local flag = false
	clone.Submit.MouseButton1Click:Connect(function()
		flag = true
	end)
	clone.Cancel.MouseButton1Click:Connect(function()
		clone.Input.Text = ""
		flag = true
	end)

	repeat
		task.wait()
	until flag

	local text2 = clone.Input.Text
	MenuHandler.activeWindow = nil
	clone:Destroy()
	return text2
end

function MenuHandler.PromptOkCancel(text)
	if MenuHandler.activeWindow ~= nil then
		return
	end

	local clone = script.Parent.GUIs.OkCancelTemplate:Clone()
	clone.Parent = MenuHandler.space
	MenuHandler.activeWindow = clone
	clone.Title.Text = text
	local flag = false
	local v = false
	clone.Submit.MouseButton1Click:Connect(function()
		flag = true
		v = true
	end)
	clone.Cancel.MouseButton1Click:Connect(function()
		flag = true
		v = false
	end)

	repeat
		task.wait()
	until flag

	MenuHandler.activeWindow = nil
	clone:Destroy()
	return v
end

function MenuHandler.PromptHelpOk()
	if MenuHandler.activeWindow ~= nil then
		return
	end

	local clone = script.Parent.GUIs.HelpFrame:Clone()
	clone.Position = UDim2.new(
		clone.Position.X.Scale,
		clone.Position.X.Offset,
		clone.Position.Y.Scale,
		clone.Position.Y.Offset - guiInset.Y
	)
	clone.Parent = MenuHandler.space
	MenuHandler.activeWindow = clone
	local flag = false
	local v = false
	clone.Submit.Activated:Connect(function()
		flag = true
		v = true
	end)

	repeat
		task.wait(0.1)
	until flag

	MenuHandler.activeWindow = nil
	clone:Destroy()
	return v
end

function MenuHandler.GetPriority(_, callback)
	if MenuHandler.activeWindow == nil then
		local clone = script.Parent.GUIs.Priority:Clone()
		clone.Parent = MenuHandler.space

		local function setupBtn(data)
			MenuHandler.RegisterTooltip(data, data.Tooltip.Value)
			data.MouseButton1Click:Connect(function()
				MenuHandler.activeWindow = nil
				clone:Destroy()
				callback(data.Name)
			end)
		end

		local core = clone.Core
		MenuHandler.RegisterTooltip(core, core.Tooltip.Value)
		core.MouseButton1Click:Connect(function()
			MenuHandler.activeWindow = nil
			clone:Destroy()
			callback(core.Name)
		end)
		local idle = clone.Idle
		MenuHandler.RegisterTooltip(idle, idle.Tooltip.Value)
		idle.MouseButton1Click:Connect(function()
			MenuHandler.activeWindow = nil
			clone:Destroy()
			callback(idle.Name)
		end)
		local movement = clone.Movement
		MenuHandler.RegisterTooltip(movement, movement.Tooltip.Value)
		movement.MouseButton1Click:Connect(function()
			MenuHandler.activeWindow = nil
			clone:Destroy()
			callback(movement.Name)
		end)
		local action = clone.Action
		MenuHandler.RegisterTooltip(action, action.Tooltip.Value)
		action.MouseButton1Click:Connect(function()
			MenuHandler.activeWindow = nil
			clone:Destroy()
			callback(action.Name)
		end)
		MenuHandler.activeWindow = clone
	end
end

function MenuHandler.GetLoop(_, callback)
	if MenuHandler.activeWindow == nil then
		local clone = script.Parent.GUIs.Looping:Clone()
		clone.Parent = MenuHandler.space
		clone.Yes.MouseButton1Click:Connect(function()
			MenuHandler.activeWindow = nil
			clone:Destroy()
			callback(true)
		end)
		clone.No.MouseButton1Click:Connect(function()
			MenuHandler.activeWindow = nil
			clone:Destroy()
			callback(false)
		end)
		MenuHandler.RegisterTooltip(clone.Yes, clone.Yes.Tooltip.Value)
		MenuHandler.RegisterTooltip(clone.No, clone.No.Tooltip.Value)
		MenuHandler.activeWindow = clone
	end
end

local text4 = ""

function MenuHandler.GetSaveName(instance, callback)
	if MenuHandler.activeWindow == nil then
		local rigType = instance:WaitForChild("Humanoid").RigType
		local clone = script.Parent.GUIs.Save:Clone()
		local descendants = {}
		local count = 0

		for _, descendant in pairs(workspace:GetDescendants()) do
			if descendant.ClassName == "KeyframeSequence" then
				table.insert(descendants, descendant)
			end
		end

		local ss = _G.ss

		if not ss then
			ss = game.ReplicatedStorage
			print("No access to ServerStorage. Using ReplicatedStorage instead.")
		end

		for _, descendant in pairs(ss:GetDescendants()) do
			if descendant.ClassName == "KeyframeSequence" then
				table.insert(descendants, descendant)
			end
		end

		for _, folder in pairs(descendants) do
			local flag = true

			for _, descendant in pairs(folder:GetDescendants()) do
				if descendant.ClassName ~= "Pose" then
					continue
				end

				if rigType == Enum.HumanoidRigType.R15 then
					if ("Torso,Left Arm,Left Leg,Right Arm,Right Leg"):find(descendant.Name, 1, true) then
						flag = false
						break
					end
				elseif ("LeftFoot,LeftHand,RightFoot,RightHand"):find(descendant.Name, 1, true) or descendant.Name:find("Upper") or descendant.Name:find("Lower") then
					flag = false
					break
				end
			end

			if not flag then
				continue
			end

			local clone2 = clone.Template:Clone()
			clone2.Text = folder:GetFullName()
			clone2.Name = clone2.Text
			clone2.Parent = clone.ScrollingFrame
			clone2.Visible = true
			clone2.MouseButton1Click:Connect(function()
				clone.TextBox.Text = clone2.Text
			end)
			count += 1
		end

		if text4 == "" then
			clone.TextBox.Text = "ServerStorage.RBX_ANIMSAVES.<enter name>"
		else
			clone.TextBox.Text = text4
		end

		clone.Save.MouseButton1Click:Connect(function()
			local text = clone.TextBox.Text

			if text:sub(-12) == "<enter name>" or text:sub(-1) == "." or text == "" then
				warn("You have to type a name, or overwrite an existing animations in the list.")
				warn("Roblox recommends new animations go into ServerStorage.RBX_ANIMSAVES, if no path is specified.")
			else
				text4 = text
				callback(text, clone.AnimScriptCheckboxImageButton.Image:sub(-8) == "48138491")
				MenuHandler.activeWindow = nil
				clone:Destroy()
			end
		end)
		clone.Cancel.MouseButton1Click:Connect(function()
			callback(nil, false)
			MenuHandler.activeWindow = nil
			clone:Destroy()
		end)
		clone.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, count * 25)
		clone.Parent = MenuHandler.space
		MenuHandler.activeWindow = clone
	end
end

function MenuHandler.GetLoadObj(instance, callback)
	if MenuHandler.activeWindow == nil then
		text4 = ""
		local rigType = instance:WaitForChild("Humanoid").RigType
		local clone = script.Parent.GUIs.Load:Clone()
		local descendants = {}
		local count = 0

		for _, descendant in pairs(workspace:GetDescendants()) do
			if descendant.ClassName == "KeyframeSequence" then
				table.insert(descendants, descendant)
			end
		end

		local ss = _G.ss

		if not ss then
			ss = game.ReplicatedStorage
			print("No access to ServerStorage. Using ReplicatedStorage instead.")
		end

		for _, descendant in pairs(ss:GetDescendants()) do
			if descendant.ClassName == "KeyframeSequence" then
				table.insert(descendants, descendant)
			end
		end

		for _, folder in pairs(descendants) do
			local clone2 = clone.Template:Clone()
			clone2.Text = folder:GetFullName()

			for _, descendant in pairs(folder:GetDescendants()) do
				if descendant.ClassName ~= "Pose" then
					continue
				end

				if rigType == Enum.HumanoidRigType.R15 then
					if ("Torso,Left Arm,Left Leg,Right Arm,Right Leg"):find(descendant.Name, 1, true) then
						clone2.Text = "{R6} " .. clone2.Text
						break
					end
				elseif ("LeftFoot,LeftHand,RightFoot,RightHand"):find(descendant.Name, 1, true) or descendant.Name:find("Upper") or descendant.Name:find("Lower") then
					clone2.Text = "{R15} " .. clone2.Text
					break
				end
			end

			clone2.Name = clone2.Text
			clone2.Parent = clone.ScrollingFrame
			clone2.Visible = true
			local v3 = folder
			clone2.MouseButton1Click:Connect(function()
				clone.LoadTitle.Text = clone2.Text
				clone.Obj.Value = v3
			end)
			count += 1
		end

		clone.Load.MouseButton1Click:Connect(function()
			local text = clone.LoadTitle.Text

			if #text == 0 then
				callback(nil)
			else
				if text ~= "{R" then
					text4 = text
				end

				callback(clone.Obj.Value)
			end

			MenuHandler.activeWindow = nil
			clone:Destroy()
		end)
		clone.Cancel.MouseButton1Click:Connect(function()
			callback(nil)
			MenuHandler.activeWindow = nil
			clone:Destroy()
		end)
		clone.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, count * 25)
		clone.Parent = MenuHandler.space
		MenuHandler.activeWindow = clone
	end
end

function MenuHandler.SelectRig(mouse, _, callback)
	if MenuHandler.activeWindow == nil then
		local studioGui = playerGui:WaitForChild("StudioGui")
		MenuHandler.mouse = mouse
		local clone = script.Parent.GUIs.StartScreen:Clone()
		local selectionBox = Instance.new("SelectionBox", studioGui)
		local selectionBox2 = Instance.new("SelectionBox", studioGui)
		local v2 = true
		selectionBox.Color = BrickColor.new("Teal")
		selectionBox.LineThickness = 0.1
		selectionBox2.LineThickness = 0.09
		local v3 = nil
		local button1DownConnections = {}

		local function cleanup()
			for _, v4 in pairs(button1DownConnections) do
				v4:disconnect()
			end

			selectionBox:Destroy()
			selectionBox2:Destroy()
			clone:Destroy()
			MenuHandler.activeWindow = nil
		end

		local function fn(parent)
			for _, child in pairs(parent:GetChildren()) do
				if child:IsA("Humanoid") or child:IsA("AnimationController") then
					return true
				end
			end

			return false
		end

		local function getRoot(object)
			if object then
				local rootPart = object:GetRootPart()

				if rootPart and fn(rootPart.Parent) then
					return rootPart
				end
			end

			return nil
		end

		local function fn2(target)
			if not target then
				return nil
			end

			local rootPart = target:GetRootPart()
			local part0 = nil
			local fn3

			fn3 = function(instance)
				for _, child in pairs(instance:GetChildren()) do
					if child:IsA("Motor6D") and child.Part1 == rootPart and fn(child.Parent.Parent) then
						part0 = child.Part0
					elseif child:IsA("BasePart") or child:IsA("Model") then
						fn3(child)
					end
				end
			end

			if rootPart and not fn(rootPart.Parent) then
				rootPart = nil
			else
				fn3(rootPart.Parent)
			end

			return part0 or rootPart
		end

		local button1DownConnection = mouse.Button1Down:Connect(function()
			local adornee = fn2(mouse.Target)
			v3 = adornee
			clone.AnchorWarning.Visible = false

			if v3 and clone:WaitForChild("RigName").Text ~= v3.Parent.Name then
				selectionBox.Adornee = adornee
				local select = clone:WaitForChild("Select")
				select.Visible = true
				local cancel = clone:WaitForChild("Cancel")
				cancel.Visible = true
				local rigName = clone:WaitForChild("RigName")
				rigName.Text = v3.Parent.Name
			else
				selectionBox.Adornee = nil
				local select_2 = clone:WaitForChild("Select")
				select_2.Visible = false
				local rigName_2 = clone:WaitForChild("RigName")
				rigName_2.Text = "<No Rig Selected>"
			end
		end)
		v3 = nil
		selectionBox.Adornee = nil

		if v3 then
			clone.Select.Visible = true
			clone.RigName.Text = v3.Parent.Name
		else
			clone.Select.Visible = false
			clone.RigName.Text = "<No Rig Selected>"
		end

		table.insert(button1DownConnections, button1DownConnection)
		clone.Cancel.MouseButton1Click:Connect(function()
			v2 = false
			cleanup()
			callback(nil)
		end)
		clone.Select.MouseButton1Click:Connect(function()
			v2 = false

			if v3 then
				for _, part in pairs(v3.Parent:GetDescendants()) do
					if part.Name == "HumanoidRootPart" then
						part.Anchored = true
						part.CanCollide = true
						part:SetAttribute("SL_Anchored", true)
						part:SetAttribute("SL_CanCollide", true)
					elseif part:IsA("BasePart") then
						part.Anchored = false
						part.CanCollide = false
						part:SetAttribute("SL_Anchored", false)
						part:SetAttribute("SL_CanCollide", false)
					end
				end
			end

			MenuHandler.killFunction = nil
			cleanup()
			callback(v3)
		end)
		clone.Parent = studioGui
		MenuHandler.activeWindow = clone

		function MenuHandler.killFunction()
			cleanup()
		end
	end
end

function MenuHandler.GetStopRequest(callback)
	local clone = script.Parent.GUIs.PlayFrame:Clone()
	clone.Parent = MenuHandler.space

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stop()
		clone:Destroy()
	end

	clone.Cancel.MouseButton1Click:Connect(function()
		stop() -- equivalent call inferred; original call site unknown
		callback()
	end)
	return stop
end

function MenuHandler.RegisterTooltip(btn, tip)
	table.insert(MenuHandler.tooltips, {
		btn = btn,
		tip = tip
	})
end

function MenuHandler.InitializeTooltips()
	local UserInputService = game:GetService("UserInputService")
	local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and MenuHandler.toggles.ShowTooltips == true then
			local X = input.Position.X
			local Y = input.Position.Y
			local tooltips = {}

			for i = #MenuHandler.tooltips, 0, -1 do
				local tooltip = MenuHandler.tooltips[i]

				if tooltip and tooltip.btn ~= nil and tooltip.btn.Parent ~= nil then
					if tooltip.btn.Visible and (tooltip.btn.Parent:IsA("ScreenGui") == true or tooltip.btn.Parent.Visible) then
						local X2 = tooltip.btn.AbsolutePosition.X
						local Y2 = tooltip.btn.AbsolutePosition.Y
						local v2 = X2 + tooltip.btn.AbsoluteSize.X
						local v3 = Y2 + tooltip.btn.AbsoluteSize.Y

						if X2 <= X and X <= v2 and Y2 <= Y and Y <= v3 then
							table.insert(tooltips, tooltip)
						end
					end
				else
					table.remove(MenuHandler.tooltips, i)
				end
			end

			MenuHandler.tip.Position = UDim2.new(0, X, 0, Y)

			if #tooltips == 1 then
				local tip = tooltips[1].tip
				MenuHandler.tip.Text = tip
				MenuHandler.tip.BackgroundTransparency = 0
				local v2 = MenuHandler.tip.TextBounds.X + 5
				local v3 = X + 15

				if v3 + v2 > game.Workspace.CurrentCamera.ViewportSize.X then
					v3 -= v3 + v2 - game.Workspace.CurrentCamera.ViewportSize.X
				end

				MenuHandler.tip.Size = UDim2.new(0, v2, 0, MenuHandler.tip.TextBounds.Y + 5)
				MenuHandler.tip.Position = UDim2.new(0, v3, 0, Y + 15)
				return
			end
		end

		MenuHandler.tip.Text = ""
		MenuHandler.tip.BackgroundTransparency = 1
	end)
	table.insert(MenuHandler.cleanup, inputChangedConnection)
end

function MenuHandler.InitializeSettings(items)
	for k, item in pairs(items) do
		MenuHandler.toggles[k] = item
	end
end

function MenuHandler.InitializeTopbar(parent, _, _, _, callback, callback2)
	MenuHandler.space = Instance.new("Frame")
	MenuHandler.space.BackgroundTransparency = 1
	MenuHandler.space.Name = "AnimationEditorMenuModule"
	MenuHandler.space.Size = UDim2.new(1, 0, 1, 0)
	MenuHandler.space.Parent = parent.Parent
	local clone = script.Parent.GUIs.Topbar:Clone()
	clone.Parent = parent

	if MenuHandler.tip.Parent == nil then
		MenuHandler.CreateTip()
	else
		MenuHandler.tip.Parent = parent
	end

	local function updateSettingToggles()
		for k, toggle in pairs(MenuHandler.toggles) do
			clone.SettingsFrame[k].ImageLabel.Image = toggle == true and MenuHandler.selectedImage or MenuHandler.deselectedImage
		end
	end

	local function updateValues()
		for _, child in pairs(clone.FileFrame:GetChildren()) do
			if child:findFirstChild("CurrentValue") then
				child.CurrentValue.Text = "[" .. tostring(callback2(child.Name)) .. "]"
			end
		end

		for _, child in pairs(clone.EditFrame:GetChildren()) do
			if child:findFirstChild("CurrentValue") then
				child.CurrentValue.Text = "[" .. tostring(callback2(child.Name)) .. "]"
			end
		end

		for _, child in pairs(clone.SettingsFrame:GetChildren()) do
			if child:findFirstChild("CurrentValue") then
				child.CurrentValue.Text = "[" .. tostring(callback2(child.Name)) .. "]"
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function quit()
		if clone:findFirstChild("FileFrame") then
			clone.FileFrame.Visible = false
		end

		if clone:findFirstChild("EditFrame") then
			clone.EditFrame.Visible = false
		end

		if clone:findFirstChild("SettingsFrame") then
			clone.SettingsFrame.Visible = false
		end

		MenuHandler.activeWindow = nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isToggle(p)
		for k, _ in pairs(MenuHandler.toggles) do
			if p.Name == k then
				return true
			end
		end

		return false
	end

	local function fireCommands()
		for _, child in pairs(clone.FileFrame:GetChildren()) do
			if child.ClassName ~= "TextButton" then
				continue
			end

			local v2 = child
			child.MouseButton1Down:Connect(function()
				quit() -- equivalent call inferred; original call site unknown
				spawn(function()
					MenuHandler.clickTrigger = true
					callback(v2.Name)
				end)
			end)

			if child:findFirstChild("Tooltip") then
				MenuHandler.RegisterTooltip(child, child.Tooltip.Value)
			end
		end

		for _, child in pairs(clone.EditFrame:GetChildren()) do
			local v2 = child
			child.MouseButton1Down:Connect(function()
				quit() -- equivalent call inferred; original call site unknown
				spawn(function()
					MenuHandler.clickTrigger = true
					callback(v2.Name)
				end)
			end)

			if child:findFirstChild("Tooltip") then
				MenuHandler.RegisterTooltip(child, child.Tooltip.Value)
			end
		end

		for _, child in pairs(clone.SettingsFrame:GetChildren()) do
			local v2 = child

			local function fn()
				-- equivalent call inferred; original call site unknown
				if isToggle(v2) then
					MenuHandler.toggles[v2.Name] = not MenuHandler.toggles[v2.Name]
					MenuHandler.toggleTrigger = true
					updateSettingToggles()
					spawn(function()
						callback(v2.Name, MenuHandler.toggles[v2.Name])
					end)
				else
					quit() -- equivalent call inferred; original call site unknown
					spawn(function()
						MenuHandler.clickTrigger = true
						callback(v2.Name)
					end)
				end
			end

			child.MouseButton1Down:Connect(function()
				fn()
			end)

			if child:findFirstChild("Tooltip") then
				MenuHandler.RegisterTooltip(child, child.Tooltip.Value)
			end
		end

		local playImageButton = clone:WaitForChild("PlayImageButton")
		playImageButton.MouseButton1Down:Connect(function()
			if playImageButton.Image ~= "rbxassetid://87351486351798" then
				playImageButton.Image = "rbxassetid://87351486351798"
				return
			end

			playImageButton.Image = "rbxassetid://4458862490"
			spawn(function()
				MenuHandler.clickTrigger = true
				callback("Play")
			end)
		end)
	end

	clone.File.MouseButton1Click:Connect(function()
		updateValues()

		if clone.FileFrame.Visible then
			MenuHandler.activeWindow = nil
			clone.FileFrame.Visible = false
		else
			quit() -- equivalent call inferred; original call site unknown
			MenuHandler.activeWindow = clone.FileFrame
			clone.FileFrame.Visible = true
		end
	end)
	clone.Edit.MouseButton1Click:Connect(function()
		updateValues()

		if clone.EditFrame.Visible then
			MenuHandler.activeWindow = nil
			clone.EditFrame.Visible = false
		else
			quit() -- equivalent call inferred; original call site unknown
			MenuHandler.activeWindow = clone.EditFrame
			clone.EditFrame.Visible = true
		end
	end)
	clone.Settings.MouseButton1Click:Connect(function()
		updateValues()

		if clone.SettingsFrame.Visible then
			MenuHandler.activeWindow = nil
			clone.SettingsFrame.Visible = false
		else
			quit() -- equivalent call inferred; original call site unknown
			MenuHandler.activeWindow = clone.SettingsFrame
			clone.SettingsFrame.Visible = true
		end
	end)
	fireCommands()
	updateSettingToggles()
end

return MenuHandler