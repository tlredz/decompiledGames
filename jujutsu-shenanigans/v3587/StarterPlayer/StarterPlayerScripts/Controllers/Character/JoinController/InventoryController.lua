local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
game:GetService("Debris")
game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local _ = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "InventoryController"
})
local color = Color3.fromRGB(85, 170, 255)
local color2 = Color3.new(1, 1, 1)

function controller.KnitStart(_)
	local menus = localPlayer.PlayerGui:WaitForChild("Menus")
	local inventory = menus.Group.Inventory
	inventory:SetAttribute("Loaded", true)
	localPlayer:WaitForChild("leaderstats")
	local v4 = nil

	for _, button in inventory.Categories:GetChildren() do
		if not button:IsA("TextButton") then
			continue
		end

		if button.Name == "Skins" and localPlayer.Name == "imed2004" then
			button.Visible = true
		end

		local v5 = button
		button.MouseButton1Down:Connect(function()
			for i, button2 in inventory.Categories:GetChildren() do
				if button2:IsA("TextButton") then
					button2.Select.Visible = button2 == v5
				end
			end

			v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

			for i, child in inventory.Items:GetChildren() do
				child.Visible = child.Name == v5.Name
			end
		end)
	end

	local function updateEmoteListSize()
		local list = inventory.Items.Emotes.List
		local offset = list.UIListLayout.Padding.Offset
		local v5 = -offset

		for _, frame in inventory.Items.Emotes.List:GetChildren() do
			if frame:IsA("Frame") and frame.Visible then
				v5 += frame.AbsoluteSize.Y + offset
			end
		end

		list.CanvasSize = UDim2.fromOffset(0, v5)
	end

	local textBox = inventory.Items.Emotes.TextBox
	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		inventory.Items.Emotes.List.CanvasPosition = Vector2.zero

		for _, frame in inventory.Items.Emotes.List:GetChildren() do
			if frame:IsA("Frame") then
				frame.Visible = frame.Name:lower():find(textBox.Text:lower())
			end
		end

		updateEmoteListSize()
	end)
	local v5 = {
		[Enum.SortOrder.LayoutOrder] = Enum.SortOrder.Name,
		[Enum.SortOrder.Name] = Enum.SortOrder.LayoutOrder
	}
	local v6 = {
		[Enum.SortOrder.Name] = "NEW",
		[Enum.SortOrder.LayoutOrder] = "A-Z"
	}
	local uIListLayout = inventory.Items.Emotes.List.UIListLayout
	textBox.SortAZ.MouseButton1Click:Connect(function()
		uIListLayout.SortOrder = v5[uIListLayout.SortOrder]
		textBox.SortAZ.Text = v6[uIListLayout.SortOrder]
	end)

	local function updateInventory(list)
		local list2 = inventory.Items.Emotes.List

		for _, frame in list2:GetChildren() do
			if not frame:IsA("Frame") or table.find(list, frame.Name) then
				continue
			end

			frame:Destroy()
		end

		for k, childName in list do
			if list2:FindFirstChild(childName) then
				continue
			end

			local clone = menus.Preset.Emote:Clone()
			clone.EmoteName.Text = childName
			clone.Name = childName
			clone.Visible = childName:lower():find(textBox.Text:lower())
			clone.LayoutOrder = -k
			clone.Parent = list2
			local v7 = childName
			clone.EmoteName.MouseButton1Down:Connect(function()
				v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

				if v4 then
					local text = v3.EmoteCache[tonumber(v4.Name)]

					if text == v7 then
						v4.Text = text
						v4 = nil
					else
						v.Equip:Fire(v3.Page == 2 and tonumber(v4.Name) + 8 or tonumber(v4.Name), v7)
						v4 = nil
					end
				end
			end)
		end

		updateEmoteListSize()
	end

	inventory.Items.Emotes.Equipped.Switch.MouseButton1Down:Connect(function()
		if v3.Page == 1 then
			v3.Page = 2
		else
			v3.Page = 1
		end

		local v7 = 8 * (v3.Page - 1)
		v4 = nil

		for i = 1, 8 do
			local findFirstChild = inventory.Items.Emotes.Equipped:FindFirstChild(i)
			findFirstChild.Text = v3.EmoteCache[i + v7]
		end

		v2:PlaySound(sounds.Misc.UI.Switch, workspace, game.SoundService.Effect)
	end)

	local function updateTitles(list)
		local list2 = inventory.Items.Titles.List

		for _, frame in list2:GetChildren() do
			if not frame:IsA("Frame") or table.find(list, frame.Name) then
				continue
			end

			frame:Destroy()
		end

		for _, childName in list do
			if list2:FindFirstChild(childName) then
				local findFirstChild = list2:FindFirstChild(childName)
				findFirstChild.BackgroundColor3 = childName == localPlayer:GetAttribute("Title") and color or color2
			else
				local clone = menus.Preset.Emote:Clone()
				clone.EmoteName.Text = childName
				clone.Name = childName
				clone.Size = UDim2.new(1, 0, 0.05, 15)
				clone.BackgroundColor3 = childName == localPlayer:GetAttribute("Title") and color or color2
				clone.Parent = list2
				local v7 = childName
				clone.EmoteName.MouseButton1Down:Connect(function()
					v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
					v.ChangeInv:Fire(v7)
				end)
			end
		end
	end

	local function updateVictories(list)
		local list2 = inventory.Items.MVP.List

		for _, frame in list2:GetChildren() do
			if not frame:IsA("Frame") or table.find(list, frame.Name) then
				continue
			end

			frame:Destroy()
		end

		for _, childName in list do
			if list2:FindFirstChild(childName) then
				local findFirstChild = list2:FindFirstChild(childName)
				findFirstChild.BackgroundColor3 = childName == localPlayer:GetAttribute("MVP") and color or color2
			else
				local clone = menus.Preset.Emote:Clone()
				clone.EmoteName.Text = childName
				clone.Name = childName
				clone.Size = UDim2.new(1, 0, 0.05, 15)
				clone.BackgroundColor3 = childName == localPlayer:GetAttribute("MVP") and color or color2
				clone.Parent = list2
				local v7 = childName
				clone.EmoteName.MouseButton1Down:Connect(function()
					v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
					v.ChangeMVP:Fire(v7)
				end)
			end
		end
	end

	local function updateSkins(list)
		local v7 = list[1]
		local v8 = list[2]
		local list2 = inventory.Items.Skins.List

		for _, frame in list2:GetChildren() do
			if not frame:IsA("Frame") or v7[frame.Name] then
				continue
			end

			frame:Destroy()
		end

		for childName, v9 in v7 do
			local clone = list2:FindFirstChild(childName)

			if not clone then
				clone = inventory.Items.Skins.Preset.Category:Clone()
				clone.Name = childName
				clone.Dropdown.Title.Text = childName
				clone.Parent = list2
				local icon = clone.Dropdown.Icon
				clone.Dropdown.MouseButton1Click:Connect(function()
					icon.Text = icon.Text == "v" and ">" or "v"
					clone.List.Visible = icon.Text == "v"
				end)
				local v11 = childName
				clone.List.Default.MouseButton1Click:Connect(function()
					v.ChangeSkin:Fire(v11)
				end)
			end

			local list3 = clone.List

			for k, childName2 in v9 do
				local clone2 = list3:FindFirstChild(childName2)

				if not clone2 then
					clone2 = inventory.Items.Skins.Preset.Skin:Clone()
					clone2.Name = childName2
					clone2.Text = childName2
					clone2.LayoutOrder = k
					clone2.Parent = list3
					local v10 = childName
					local v11 = childName2
					clone2.MouseButton1Click:Connect(function()
						v.ChangeSkin:Fire(v10, v11)
					end)
				end

				clone2.BackgroundColor3 = v8[childName] == childName2 and color or color2
			end

			list3.Default.BackgroundColor3 = v8[childName] and color2 or color
		end
	end

	local preview = inventory.Items.Skins.Preview
	local viewportFrame = preview.ViewportFrame
	local slider = preview.Slider
	local camera = Instance.new("Camera", viewportFrame)
	viewportFrame.CurrentCamera = camera
	local handle = slider.Bar.Handle
	local uIDragDetector = handle.UIDragDetector
	local currentPreview = viewportFrame.CurrentPreview
	local v7 = 0.01231
	currentPreview:PivotTo(CFrame.new() * CFrame.Angles(0, math.rad(v7), 0))
	uIDragDetector.DragContinue:Connect(function()
		v7 = math.map(handle.Position.X.Scale, 0, 1, -1, 1) * 90
		currentPreview:PivotTo(CFrame.new() * CFrame.Angles(0, math.rad(v7), 0))
	end)
	local noPreview = viewportFrame.NoPreview
	v.ChangeSkin:Connect(function(p)
		currentPreview:ClearAllChildren()

		if not p then
			noPreview.Visible = true
			return
		end

		noPreview.Visible = false
		p.Parent = currentPreview
		local basePart = currentPreview:FindFirstChildWhichIsA("BasePart", true)
		local model = Instance.new("Model", currentPreview)

		if basePart.Parent == p then
			basePart.Parent = model
		else
			basePart.Parent.Parent = model
		end

		model:PivotTo(CFrame.new() * CFrame.Angles(0, math.rad(v7), 0))
		local _, v8 = model:GetBoundingBox()
		camera.CFrame = CFrame.lookAt(CFrame.new(0, 0, -v8.Magnitude * 0.8).Position, basePart.Position)
	end)
	v.ChangeInv:Connect(function(p, p2)
		if p2 == 1 then
			updateInventory(p)
		elseif p2 == 2 then
			updateVictories(p)
		elseif p2 == 3 then
			updateSkins(p)
		else
			updateTitles(p)
		end
	end)

	for _, child in inventory.Items.Emotes.Equipped:GetChildren() do
		if child.Name == "Switch" then
			continue
		end

		local v8 = child
		child.MouseButton1Down:Connect(function()
			v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

			if v4 == nil then
				v4 = v8
				v8.Text = "..."
			elseif v4 == v8 then
				v4 = nil
				v8.Text = v3.EmoteCache[v3.Page == 2 and tonumber(v8.Name) + 8 or tonumber(v8.Name)]
			end
		end)
	end
end

function controller.KnitInit(_)
	v = Knit.GetService("EmoteService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("EmoteController")
end

return controller