game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Net = require(game.ReplicatedStorage.Modules.Net)
local remoteFunction = Net:RemoteFunction("EnchantInvoke")
local _ = UserInputService.TouchEnabled
local FruitSpritesheets = require(game.ReplicatedStorage.FruitSpritesheets)
local Flags = require(game.ReplicatedStorage.Modules.Flags)
local Textures = require(game.ReplicatedStorage.Textures)
local _ = Flags.ENCHANT_USES_NEW_SERVICE

local function fruitName(value)
	local v = value:match("^Permanent %a+%-%a+") and "Permanent " or ""
	local v2 = string.match(value, "(((%u)%-?)([^-.]+))$")

	if v2 then
		return v .. v2
	end

	return value
end

local v = {
	[0] = { "Common", Color3.fromRGB(179, 179, 179) },
	[1] = { "Uncommon", Color3.fromRGB(92, 140, 211) },
	[2] = { "Rare", Color3.fromRGB(140, 82, 255) },
	[3] = { "Legendary", Color3.fromRGB(213, 43, 228) },
	[4] = { "Mythical", Color3.fromRGB(238, 47, 50), true },
	[5] = { "Premium", Color3.fromRGB(221, 188, 0), true }
}

function ApplySprite(instance, value, value2)
	instance.Icon.Image = "rbxasset://textures/ui/PlayerList/Block@3x.png"
	instance.IconOutline.Visible = false
	local v2 = value:gsub("'", ""):gsub(":", "") .. "1.png"
	local v3 = value:gsub("'", ""):gsub(":", "") .. "2.png"
	local v4 = true
	local v5 = nil
	local v6 = nil

	for k, fruitSpritesheet in pairs(FruitSpritesheets) do
		if not v4 then
			break
		end

		for k2, v8 in pairs(fruitSpritesheet) do
			if k2 == v2 then
				v5 = { k, v8 }
			elseif k2 == v3 then
				v6 = { k, v8 }
			end

			if not (v5 and v6) then
				continue
			end

			v4 = false
			break
		end
	end

	if v5 then
		instance.Icon.Image = v5[1]
		instance.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		instance.Icon.ImageTransparency = 0
		instance.Icon.ImageRectOffset = Vector2.new(v5[2][1] / (v5[2][3] and 1 or 2), v5[2][2] / (v5[2][3] and 1 or 2))
		instance.Icon.ImageRectSize = Vector2.new(v5[2][3] or 150, v5[2][4] or 150)

		if v6 then
			instance.IconOutline.Image = v6[1]
			instance.IconOutline.ImageColor3 = Color3.fromRGB(0, 0, 0)
			instance.IconOutline.ImageTransparency = 0
			instance.IconOutline.ImageRectOffset = Vector2.new(
				v6[2][1] / (v6[2][3] and 1 or 2),
				v6[2][2] / (v6[2][3] and 1 or 2)
			)
			instance.IconOutline.ImageRectSize = Vector2.new(v6[2][3] or 150, v6[2][4] or 150)
			instance.IconOutline.Visible = true
		else
			instance.IconOutline.Visible = false
		end
	end

	instance.Background.UIStroke.Color = v[value2 or 0][2]
	instance.Background.BackgroundColor3 = v[value2 or 0][2]

	if instance:FindFirstChild("OutlineGlow") then
		if v[value2 or 0][3] then
			instance.OutlineGlow.Visible = true
			instance.OutlineGlow.ImageColor3 = v[value2 or 0][2]
		else
			instance.OutlineGlow.Visible = false
		end
	end
end

local enchant = script.Parent.Parent.Parent:WaitForChild("Popups"):WaitForChild("EnchantUI"):WaitForChild("Enchant")
local content = enchant.Main.Content
local content2 = enchant.Confirm.Content
local example = content.ScrollingFrame.Example
example.Parent = script
local example2 = content2.Left.ScrollingFrame.Example
example2.Parent = script

function ApplyItem(data, p)
	ApplySprite(content.Top.Item, data.Name, data.Rarity)
	content2.Right.TextLabel.Text = "Select a scroll to apply.<br/><font color=\"#ff0000\"><b>This will replace your current enchants, and can't be undone!</b></font>"
	content.Top.Frame.ItemName.Text = data.Name
	content.Top.Frame.ItemRarity.Text = v[data.Rarity or 0][1] .. " " .. p .. ", Grade " .. data.Upgrades
	content.Top.Frame.ItemRarity.TextColor3 = v[data.Rarity or 0][2]
	content2.Right.Confirm.BackgroundColor3 = Color3.fromRGB(255, 214, 49)
	content2.Right.Confirm.Trans.BackgroundColor3 = Color3.fromRGB(255, 241, 87)
	content2.Right.Confirm.BorderColor3 = Color3.fromRGB(255, 240, 69)

	for _, guiObject in pairs(content.ScrollingFrame:GetChildren()) do
		if guiObject:IsA("Frame") or guiObject:IsA("TextLabel") then
			guiObject:Destroy()
		end
	end

	if next(data.Modifiers) == nil then
		local clone = example.ItemName:Clone()
		clone.Text = "No modifiers applied"
		clone.Parent = content.ScrollingFrame
	else
		local modifiers = {}

		for _, modifier in pairs(data.Modifiers) do
			table.insert(modifiers, modifier)
		end

		table.sort(modifiers, function(a, b)
			if (a.Curse or a.Blessing) ~= (b.Curse or b.Blessing) then
				return not (b.Curse or b.Blessing)
			end

			if a.Unique ~= b.Unique then
				return not b.Unique
			end

			if (a.ModifierType and a.ModifierType.SortOrder) == (b.ModifierType and b.ModifierType.SortOrder) then
				return a.Name < b.Name
			end

			return not (b.ModifierType and b.ModifierType.SortOrder) or a.ModifierType.SortOrder < b.ModifierType.SortOrder
		end)

		for _, v2 in pairs(modifiers) do
			local clone = example.ItemName:Clone()
			local clone2 = example.ItemRarity:Clone()
			clone.Text = v2.Name
			clone2.Text = v2.Description

			if v2.Curse then
				clone.Text ..= " (CURSE)"
				clone.TextColor3 = Color3.fromRGB(234, 0, 255)
			elseif v2.Blessing then
				clone.Text ..= " (BLESSING)"
				clone.TextColor3 = Color3.fromRGB(255, 157, 0)
			elseif v2.Unique then
				clone.Text ..= " (UNIQUE)"
				clone.TextColor3 = Color3.fromRGB(255, 240, 178)
			elseif v2.ModifierType and v2.ModifierType.SpecialText then
				clone.Text ..= ` {v2.ModifierType.SpecialText}`
				clone.TextColor3 = v2.ModifierType.Color3 or Color3.fromRGB(130, 205, 255)
			else
				clone.Text ..= " Lvl. " .. v2.Level

				if v2.MaxLevel and v2.MaxLevel == v2.Level then
					clone.Text ..= " <font color=\"#666666\">(Max)</font>"
				end
			end

			clone.Parent = content.ScrollingFrame
			clone2.Parent = content.ScrollingFrame
			clone2.TextSize = clone.AbsoluteSize.Y * 0.7
		end
	end

	content.ScrollingFrame.CanvasSize = UDim2.fromOffset(
		0,
		content.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y + 12
	)

	for _, button in pairs(content2.Left.ScrollingFrame:GetChildren()) do
		if button:IsA("TextButton") then
			button:Destroy()
		end
	end

	local v2 = {}

	for k, scroll in pairs(data.Scrolls) do
		table.insert(v2, { k, scroll })
	end

	table.sort(v2, function(a, b)
		if a[2][2] == b[2][2] then
			return a[1] < b[1]
		end

		return a[2][2] > b[2][2]
	end)

	for _, v3 in pairs(v2) do
		local text = v3[1]
		local v5 = v3[2]
		local _ = v3[3]
		local clone = example2:Clone()
		ApplySprite(clone.Item, text, v5[2])
		clone.Right.ItemName.Text = text
		clone.Right.ItemRarity.Text = v5[1] .. " in Inventory"

		local function applySelection()
			if v5[1] > 0 then
				content2.Right.Confirm.TextLabel.Text = "Confirm"
			else
				content2.Right.Confirm.TextLabel.Text = "Buy"
			end

			if v5[3] > (data.Upgrades or 0) then
				content2.Right.Confirm.TextLabel.Text = "Locked"
				content2.Right.Confirm.BackgroundColor3 = Color3.new(0.611765, 0.611765, 0.611765)
				content2.Right.Confirm.BorderColor3 = Color3.new(0.290196, 0.290196, 0.290196)
				content2.Right.Confirm.Trans.BackgroundColor3 = Color3.new(0.65098, 0.65098, 0.65098)
				content2.Right.TextLabel.Text = "This scroll would <br/><font color=\"#ff0000\"><b>break</b></font> your weapon. Consider upgrading it first."
			else
				content2.Right.Confirm.BackgroundColor3 = Color3.fromRGB(255, 214, 49)
				content2.Right.Confirm.BorderColor3 = Color3.fromRGB(255, 240, 69)
				content2.Right.TextLabel.Text = "Select a scroll to apply.<br/><font color=\"#ff0000\"><b>This will replace your current enchants, and can't be undone!</b></font>"
				content2.Right.Confirm.Trans.BackgroundColor3 = Color3.fromRGB(255, 241, 87)
			end

			for i, button in pairs(content2.Left.ScrollingFrame:GetChildren()) do
				if button:IsA("TextButton") and button ~= clone then
					button.BackgroundColor3 = Color3.fromRGB(81, 81, 81)
				end
			end

			clone.BackgroundColor3 = Color3.fromRGB(115, 115, 115)
		end

		local applySelection2 = applySelection
		clone.Activated:Connect(function()
			content2:SetAttribute("SelectedScroll", text)
			applySelection2()
		end)

		if content2:GetAttribute("SelectedScroll") == text then
			applySelection()
		end

		clone.Parent = content2.Left.ScrollingFrame
		content2.Left.ScrollingFrame.CanvasSize = UDim2.fromOffset(
			0,
			content2.Left.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y
		)
	end
end

local v2 = {}
local activatedConnection = nil

for k, v3 in Textures.item do
	if typeof(v3) ~= "string" then
		continue
	end

	assert(typeof(k) == "string", (`bad key type: "{typeof(k)}"`))
	local v4 = k:split(".png")[1]
	assert(v4, (`bad key: "{v4}"`))
	v2[v4] = v3
end

game:GetService("SoundService")
local Sound = require(game.ReplicatedStorage.Util.Sound)

function OpenScroll(p: string?, p2)
	local enchant_2 = script.Parent.Parent.Parent:WaitForChild("Popups"):WaitForChild("EnchantUI"):WaitForChild("Enchant")
	enchant_2.Visible = false

	if p2 then
		game.Players.LocalPlayer.Character.Humanoid:UnequipTools()
		pcall(function()
			script.Parent.Parent.Parent.Backpack.Enabled = false
		end)
	end

	for _, guiObject in pairs(content.ScrollingFrame:GetChildren()) do
		if guiObject:IsA("Frame") or guiObject:IsA("TextLabel") then
			guiObject:Destroy()
		end

		content.Close.Selectable = true
		content.Close.Active = true
		content.Close.AutoButtonColor = true
	end

	enchant.Confirm.Visible = false
	enchant.Main.Locked.Visible = false
	local TweenService = game:GetService("TweenService")
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 1
	numberValue.Parent = script
	local scrollRoll = script.Parent.Parent.Parent:WaitForChild("Popups"):WaitForChild("ScrollRollUI"):WaitForChild("ScrollRoll")
	scrollRoll.ImageRectOffset = Vector2.zero
	scrollRoll.ImageRectSize = Vector2.zero

	if p then
		local formatted = `{p}1`

		if not v2[formatted] then
			error((`No image found for scroll: "{formatted}"`))
		end

		local formatted2 = `{p}2`
		scrollRoll.Image = v2[formatted]

		if v2[formatted2] then
			scrollRoll.Glow.Image = v2[formatted2]
			scrollRoll.Glow.Visible = true
		else
			scrollRoll.Glow.Visible = false
		end
	else
		scrollRoll.Image = ""
		scrollRoll.Glow.Image = ""
		scrollRoll.Glow.Visible = true
	end

	scrollRoll.Glow.ImageTransparency = 0.999
	scrollRoll.ImageTransparency = 0
	scrollRoll.Size = UDim2.fromScale(0, 0)
	scrollRoll.Position = UDim2.fromScale(0.5, 0.5)
	scrollRoll.Visible = true

	if p then
		local flag = false
		local ContentProvider = game:GetService("ContentProvider")
		ContentProvider:PreloadAsync({ scrollRoll.Image }, function()
			flag = true
		end)

		repeat
			task.wait()
		until flag
	end

	scrollRoll.Size = UDim2.fromScale(0.7, 0.7)
	scrollRoll.Position = UDim2.fromScale(0.5, -1)
	TweenService:Create(scrollRoll, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Position = UDim2.fromScale(0.5, 0.5)
	}):Play()

	if p then
		Sound:Play("ChopTackle2", game.Players.LocalPlayer)
		Sound:Preload("Unboxing.ChestOpen")
		Sound:Preload("Unboxing.Shuttering")
		task.wait(0.3)
	end

	while p do
		local UserInputService2 = game:GetService("UserInputService")
		local v3, _ = UserInputService2.InputEnded:Wait()
		local v4 = v3.UserInputType == Enum.UserInputType.MouseButton1 or v3.UserInputType == Enum.UserInputType.Touch

		if not v4 and (v3.KeyCode == Enum.KeyCode.ButtonA or v3.KeyCode == Enum.KeyCode.ButtonB or v3.KeyCode == Enum.KeyCode.ButtonX or v3.KeyCode == Enum.KeyCode.ButtonY) or v4 then
			break
		end
	end

	TweenService:Create(scrollRoll, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
		Size = UDim2.fromScale(0.8, 0.8)
	}):Play()

	if p then
		task.wait(0.4)
	end

	local v3 = Sound:Play("Unboxing.Shuttering", game.Players.LocalPlayer)
	numberValue.Changed:Connect(function(p3)
		scrollRoll.Rotation = math.pow(2.71828, -p3 / 4) * math.cos(6.283185307179586 * p3) * 40
	end)
	scrollRoll:GetPropertyChangedSignal("ImageTransparency"):Connect(function()
		scrollRoll.Glow.ImageTransparency = 1 - scrollRoll.ImageTransparency * 2
	end)
	numberValue.Value = 8.26
	TweenService:Create(numberValue, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {
		Value = 0.2499
	}):Play()
	TweenService:Create(
		scrollRoll,
		TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 1.5),
		{
			ImageTransparency = 1
		}
	):Play()
	TweenService:Create(scrollRoll, TweenInfo.new(1.2, Enum.EasingStyle.Linear), {
		Size = UDim2.fromScale(0.73, 0.73)
	}):Play()

	if p then
		wait(1.5)
	end

	TweenService:Create(scrollRoll, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		Size = UDim2.fromScale(5, 5),
		BackgroundTransparency = 0
	}):Play()
	content.ScrollingFrame.CanvasSize = UDim2.fromScale(0, 0)
	Sound:FadeOut(v3, 0.1)
	Sound:Play("Unboxing.ChestOpen", game.Players.LocalPlayer)
	wait(0.3)

	if p2 then
		local enchant_3 = script.Parent.Parent.Parent:WaitForChild("Popups"):WaitForChild("EnchantUI"):WaitForChild("Enchant")
		enchant_3.Visible = true
	end

	scrollRoll.Glow.ImageTransparency = 1
	TweenService:Create(scrollRoll, TweenInfo.new(1.2, Enum.EasingStyle.Linear), {
		BackgroundTransparency = 1
	}):Play()
	numberValue:Destroy()

	if not p2 then
		return
	end

	wait(0.7)
	local modifiers = {}

	for _, modifier in pairs(p2.Modifiers) do
		table.insert(modifiers, modifier)
	end

	table.sort(modifiers, function(a, b)
		if (a.Curse or a.Blessing) ~= (b.Curse or b.Blessing) then
			return b.Curse or b.Blessing
		end

		if a.Unique ~= b.Unique then
			return b.Unique
		end

		if (a.ModifierType and a.ModifierType.SortOrder) == (b.ModifierType and b.ModifierType.SortOrder) then
			return a.Name < b.Name
		end

		return b.ModifierType and b.ModifierType.SortOrder and (not (a.ModifierType and a.ModifierType.SortOrder) or a.ModifierType.SortOrder > b.ModifierType.SortOrder)
	end)

	for _, v4 in pairs(modifiers) do
		local clone = example.ItemName:Clone()
		local clone2 = example.ItemRarity:Clone()
		clone.Text = v4.Name
		clone2.Text = v4.Description

		if v4.Curse then
			clone.Text ..= " (CURSE)"
			clone.TextColor3 = Color3.fromRGB(234, 0, 255)
		elseif v4.Blessing then
			clone.Text ..= " (BLESSING)"
			clone.TextColor3 = Color3.fromRGB(255, 157, 0)
		elseif v4.Unique then
			clone.Text ..= " (UNIQUE)"
			clone.TextColor3 = Color3.fromRGB(255, 240, 178)
		elseif v4.ModifierType and v4.ModifierType.SpecialText then
			clone.Text ..= ` {v4.ModifierType.SpecialText}`
			clone.TextColor3 = v4.ModifierType.Color3 or Color3.fromRGB(130, 205, 255)
		else
			clone.Text ..= " Lvl. " .. v4.Level

			if v4.MaxLevel and v4.MaxLevel == v4.Level then
				clone.Text ..= " <font color=\"#666666\">(Max)</font>"
			end
		end

		clone.Parent = content.ScrollingFrame
		clone2.Parent = content.ScrollingFrame
		clone2.TextSize = clone.AbsoluteSize.Y * 0.7
		clone2.TextTransparency = 1
		clone.TextTransparency = 1
		clone2.TextStrokeTransparency = 1
		clone.TextStrokeTransparency = 1
		local clone3 = clone:Clone()
		clone3.Size = UDim2.fromScale(1, 1)
		clone3.SizeConstraint = Enum.SizeConstraint.RelativeXY
		clone3.TextColor3 = Color3.new(1, 1, 1)
		clone3.Text = clone3.Text:gsub("<font color=\".+\">(.+)</font>", "%1")
		clone3.Parent = clone
		clone3.RichText = false
		clone3.TextStrokeTransparency = 0
		local uIStroke = Instance.new("UIStroke", clone3)
		uIStroke.Color = Color3.new(1, 1, 1)
		uIStroke.Thickness = 0
		uIStroke.Transparency = 1
		local clone4 = clone2:Clone()
		clone4.Size = UDim2.fromScale(1, 1)
		clone4.SizeConstraint = Enum.SizeConstraint.RelativeXY
		clone4.TextColor3 = Color3.new(1, 1, 1)
		clone4.Text = clone4.Text:gsub("<font color=\".+\">(.+)</font>", "%1")
		clone4.Parent = clone2
		clone4.RichText = false
		clone4.TextStrokeTransparency = 0
		local uIStroke2 = Instance.new("UIStroke", clone4)
		uIStroke2.Color = Color3.new(1, 1, 1)
		uIStroke2.Thickness = 0
		uIStroke2.Transparency = 1
		task.wait()
		local tweens = {}
		local v5 = nil
		local Y = content.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y
		local inputEndedConnection = nil
		local UserInputService2 = game:GetService("UserInputService")
		inputEndedConnection = UserInputService2.InputEnded:Connect(function(input)
			local v12 = input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch

			if not v12 and (input.KeyCode == Enum.KeyCode.ButtonA or input.KeyCode == Enum.KeyCode.ButtonB or input.KeyCode == Enum.KeyCode.ButtonX or input.KeyCode == Enum.KeyCode.ButtonY) or v12 then
				inputEndedConnection:Disconnect()
				v5 = true

				for k, v13 in pairs(tweens) do
					v13:Cancel()
				end

				content.ScrollingFrame.CanvasSize = UDim2.fromOffset(0, Y + 12)
				content.ScrollingFrame.CanvasPosition = Vector2.new(0, Y + 12)
				clone3.Visible = false
				clone4.Visible = false
				clone2.TextTransparency = 0
				clone.TextTransparency = 0
				clone2.TextStrokeTransparency = 0.8
				clone.TextStrokeTransparency = 0.8
			end
		end)
		local tween = TweenService:Create(content.ScrollingFrame, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
			CanvasSize = UDim2.fromOffset(0, Y + 12),
			CanvasPosition = Vector2.new(0, Y + 12)
		})
		tween:Play()
		table.insert(tweens, tween)
		local v13 = Sound:Play("CoolThing", game.Players.LocalPlayer)
		task.delay(0.75, function()
			Sound:FadeOut(v13, 0.5)
		end)

		repeat
			task.wait()
		until v5 or tween.PlaybackState ~= Enum.PlaybackState.Playing

		if v5 then
			continue
		end

		local tween2 = TweenService:Create(uIStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Transparency = 0,
			Thickness = 2
		})
		tween2:Play()
		table.insert(tweens, tween2)
		local tween3 = TweenService:Create(uIStroke2, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Transparency = 0,
			Thickness = 2
		})
		tween3:Play()
		table.insert(tweens, tween3)
		local v14 = os.clock() + 0.2

		repeat
			task.wait()
		until v14 <= os.clock() or v5

		if v5 then
			continue
		end

		clone2.TextTransparency = 0
		clone.TextTransparency = 0
		clone2.TextStrokeTransparency = 0.8
		clone.TextStrokeTransparency = 0.8
		local tween4 = TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			TextTransparency = 0,
			TextStrokeTransparency = 0.8
		})
		tween4:Play()
		table.insert(tweens, tween4)
		local tween5 = TweenService:Create(uIStroke, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			Transparency = 1,
			Thickness = 0
		})
		tween5:Play()
		table.insert(tweens, tween5)
		local tween6 = TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			TextTransparency = 0,
			TextStrokeTransparency = 0.8
		})
		tween6:Play()
		table.insert(tweens, tween6)
		local tween7 = TweenService:Create(uIStroke2, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			Transparency = 1,
			Thickness = 0
		})
		tween7:Play()
		table.insert(tweens, tween7)
		local v15 = os.clock() + 0.8

		repeat
			task.wait()
		until v15 <= os.clock() or v5

		inputEndedConnection:Disconnect()

		if not enchant.Visible then
			break
		end
	end

	content.Roll.Selectable = true
	content.Roll.Active = true
	content.Roll.AutoButtonColor = true
	pcall(function()
		script.Parent.Parent.Parent.Backpack.Enabled = true
	end)
end

local refreshGui

refreshGui = function()
	local currentItem = enchant:GetAttribute("CurrentItem")

	if not currentItem then
		return
	end

	local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")

	if not tool or tool.Name ~= currentItem then
		for _, tool2 in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
			if not (tool2:IsA("Tool") and tool2.Name == currentItem) then
				continue
			end

			tool = tool2
			break
		end
	end

	local ENCHANT_USES_NEW_SERVICE = Flags.ENCHANT_USES_NEW_SERVICE
	local v3

	if ENCHANT_USES_NEW_SERVICE then
		v3 = remoteFunction:InvokeServer("Check", tool)
	else
		v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("EnchantItem", "Check", tool)
	end

	if not v3 then
		return enchant:SetAttribute("CurrentItem", false)
	end

	local toolTip = tool.ToolTip

	if toolTip == "JobTool" then
		local JobToolsInfo = require(game.ReplicatedStorage.JobsReplicated.JobToolsInfo)
		toolTip = JobToolsInfo.GenericToolNames[tool:GetAttribute("JobId")]
	end

	ApplyItem(v3, toolTip)
	local flag = false

	if activatedConnection then
		activatedConnection:Disconnect()
		activatedConnection = nil
	end

	activatedConnection = content2.Right.Confirm.Activated:Connect(function()
		if flag then
			return
		end

		flag = true
		local selectedScroll = content2:GetAttribute("SelectedScroll")

		if selectedScroll then
			if content2.Right.Confirm.TextLabel.Text == "Buy" then
				game.ReplicatedStorage.Remotes.CommF_:InvokeServer("buyRobuxShop", selectedScroll)
				flag = false
				return
			else
				if content2.Right.Confirm.TextLabel.Text == "Locked" then
					flag = false
					return
				end

				pcall(function()
					game.Players.LocalPlayer.Character.Busy.Value = true
				end)
				local v4

				if ENCHANT_USES_NEW_SERVICE then
					v4 = remoteFunction:InvokeServer("Enchant", tool, selectedScroll)
				else
					v4 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
						"EnchantItem",
						"Enchant",
						tool,
						selectedScroll
					)
				end

				refreshGui()

				if v4 then
					OpenScroll(selectedScroll, v4)
					pcall(function()
						game.Players.LocalPlayer.Character.Busy.Value = false
					end)
				else
					flag = false
					pcall(function()
						game.Players.LocalPlayer.Character.Busy.Value = false
					end)
					return enchant:SetAttribute("CurrentItem", false)
				end
			end
		end

		flag = false
	end)
end

enchant:GetAttributeChangedSignal("CurrentItem"):Connect(function()
	if enchant:GetAttribute("CurrentItem") then
		if script.Parent.Parent.InventoryContainer:GetAttribute("itemsVisible") then
			enchant:SetAttribute("CurrentItem", false)
			return
		end

		refreshGui()
		enchant.Visible = true
	else
		content2.Right.Confirm.TextLabel.Text = "Confirm"
		content2:SetAttribute("SelectedScroll", nil)
		enchant.Visible = false
		enchant.Confirm.Visible = false
		enchant.Main.Locked.Visible = false

		if activatedConnection then
			activatedConnection:Disconnect()
			activatedConnection = nil
		end

		content.Roll.Selectable = true
		content.Roll.Active = true
		content.Roll.AutoButtonColor = true
		content.Close.Selectable = true
		content.Close.Active = true
		content.Close.AutoButtonColor = true
	end
end)
content2:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	content2.Left.ScrollingFrame.CanvasSize = UDim2.fromOffset(
		0,
		content2.Left.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y
	)
	content.ScrollingFrame.CanvasSize = UDim2.fromOffset(
		0,
		content.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y + 12
	)
end)
content2.Right.Cancel.Activated:Connect(function()
	enchant.Confirm.Visible = false
	enchant.Main.Locked.Visible = false
	content.Roll.Selectable = true
	content.Roll.Active = true
	content.Roll.AutoButtonColor = true
	content.Close.Selectable = true
	content.Close.Active = true
	content.Close.AutoButtonColor = true
end)
content.Roll.Activated:Connect(function()
	if not content.Roll.Selectable then
		return
	end

	content.Roll.Selectable = false
	content.Roll.Active = false
	content.Roll.AutoButtonColor = false
	content.Close.Selectable = false
	content.Close.Active = false
	content.Close.AutoButtonColor = false
	content.Parent.Locked.Visible = true
	enchant.Confirm.Visible = true
end)
script.Parent.Parent.InventoryContainer:GetAttributeChangedSignal("itemsVisible"):Connect(function()
	enchant:SetAttribute("CurrentItem", false)
end)
enchant.Main.Exit.Activated:Connect(function()
	enchant:SetAttribute("CurrentItem", false)
end)
content.Close.Activated:Connect(function()
	enchant:SetAttribute("CurrentItem", false)
end)
game.Players.LocalPlayer.ChildAdded:Connect(function(child)
	if child.Name == "__RefreshScrolls" then
		if not enchant.Visible then
			return
		end

		refreshGui()
	end
end)
return OpenScroll