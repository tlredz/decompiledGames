local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local _ = UserInputService.GamepadEnabled
local SwordList = require(ReplicatedStorage:WaitForChild("Chest").Modules.SwordList)
local DFTier = require(ReplicatedStorage:WaitForChild("Chest").Modules.DFTier)
local CustomNames = require(ReplicatedStorage:WaitForChild("Chest").Modules.CustomNames)
local TopbarPlus = require(ReplicatedStorage:WaitForChild("Chest").Modules.TopbarPlus)
task.spawn(function()
	local WorldsId = require(ReplicatedStorage.Chest.Modules:WaitForChild("WorldsId"))

	if ({
		[WorldsId.Testing.GoldenArena] = true,
		[WorldsId.KingLegacy.GoldenArena] = true
	})[game.PlaceId] then
		local localPlayer = game.Players.LocalPlayer

		repeat
			wait(1)
		until localPlayer.Character and localPlayer.Character:IsDescendantOf(workspace.PlayerCharacters)

		script.Parent.Enabled = true
	end
end)
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.ExperienceShop, false)
local count = 0
local v = TopbarPlus.new()
v:setImage(113600033182187):setOrder(1):oneClick()
v:setCaption("Backpack")
v:bindEvent("selected", function(_)
	if _G.ChestOpening then
		return
	end

	OpenAndCloseInventory()
end)
v:setNotify(count)
local currentCamera = workspace.CurrentCamera
local v2 = 60
local v3 = 4
local flag = nil
local v4 = nil

repeat
	task.wait(0.1)
until currentCamera and currentCamera.ViewportSize.Magnitude > 0

local parent = script.Parent

if not _G.UIVisible then
	parent.Enabled = false
end

task.spawn(function()
	while true do
		if parent.InventoryFrame.Visible then
			local v5 = task.wait() * 60
			parent.InventoryFrame.Background.UIGradient.Rotation = (parent.InventoryFrame.Background.UIGradient.Rotation + v5 / 2) % 360
			parent.InventoryFrame.BackgroundTop.UIGradient.Rotation = (parent.InventoryFrame.BackgroundTop.UIGradient.Rotation + v5 / 2) % 360
			parent.InventoryFrame.SearchFrame.UIGradient.Rotation = (parent.InventoryFrame.SearchFrame.UIGradient.Rotation + v5 / math.random(
				1,
				5
			)) % 360
		else
			task.wait()
			parent.InventoryFrame:GetPropertyChangedSignal("Visible"):Wait()
		end
	end
end)
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local backpack = localPlayer.Backpack
local mouse = localPlayer:GetMouse()
local v5 = localPlayer:FindFirstChild("HotbarSlots")

if not v5 then
	v5 = Instance.new("StringValue")
	v5.Name = "HotbarSlots"
	v5.Value = "[]"
	v5.Parent = localPlayer
end

local jSONDecode = HttpService:JSONDecode(v5.Value)
local v6 = {}
local v7 = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.Five] = 5,
	[Enum.KeyCode.Six] = 6,
	[Enum.KeyCode.Seven] = 7,
	[Enum.KeyCode.Eight] = 8,
	[Enum.KeyCode.Nine] = 9
}
local v8 = {}
v8.NoRemoveUpdate = nil
local v9 = {
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9"
}
local touchEnabled = UserInputService.TouchEnabled
local gamepadEnabled = UserInputService.GamepadEnabled
local viewportSize = currentCamera.ViewportSize
local v10 = math.min(viewportSize.X, viewportSize.Y)

if touchEnabled then
	v9 = {
		"1",
		"2",
		"3",
		"4"
	}
	v3 = 2

	if v10 >= 550 then
		v2 = 60
	else
		v2 = 50
	end
end

local v11 = v10 >= 1000 and 70 or v2
UserInputService.GamepadConnected:Connect(function()
	gamepadEnabled = UserInputService.GamepadEnabled
	parent.Slots.OpenBackpack.Visible = true
end)
UserInputService.GamepadDisconnected:Connect(function()
	gamepadEnabled = UserInputService.GamepadEnabled

	if not (gamepadEnabled or parent.InventoryFrame.Visible) then
		parent.Slots.OpenBackpack.Visible = false
	end
end)
local v12 = currentCamera.ViewportSize.X >= 1000 and currentCamera.ViewportSize.X <= 1280 and {
	"1",
	"2",
	"3",
	"4",
	"5",
	"6"
} or v9
local moveConnection = nil
local flag2 = nil
local clone = nil

function UpdateAddButton() end

function UpdateHUD()
	parent.Slots.UIGridLayout.CellPadding = UDim2.new(0, 3, 0, 0)
	parent.InventoryFrame.ScrollingFrame.UIGridLayout.CellPadding = UDim2.new(0, 3, 0, 1)
	local _ = workspace.CurrentCamera.ViewportSize
	parent.Slots.Size = UDim2.new(0, (#v12 + 1) * (v11 + 3) + 3, 0, v11)
	parent.Slots.Position = UDim2.new(0.5, -parent.Slots.Size.X.Offset / 2, 1, -parent.Slots.Size.Y.Offset - 3)
	parent.InventoryFrame.Size = UDim2.new(0, parent.Slots.Size.X.Offset + 15, 0, (v11 + 1) * v3 + 15)
	parent.InventoryFrame.Position = UDim2.new(0.5, 0, 1, -(v11 + 5))
	UpdateAddButton()
	parent.Slots.UIGridLayout.CellSize = UDim2.new(0, v11, 0, v11)
	parent.InventoryFrame.ScrollingFrame.UIGridLayout.CellSize = UDim2.new(0, v11, 0, v11)
end

parent.InventoryFrame.ScrollingFrame.UIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	task.wait()
	parent.InventoryFrame.ScrollingFrame.CanvasSize = UDim2.new(
		0,
		0,
		0,
		parent.InventoryFrame.ScrollingFrame.UIGridLayout.AbsoluteContentSize.Y
	)
end)
UpdateHUD()
local v13 = {}
local clones = {}
local textBox = parent.InventoryFrame.SearchFrame:WaitForChild("TextBox")
parent.Slots.UIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	wait()
	UpdateAddButton()
end)
parent.Slots.OpenBackpack.Visible = true
parent.Slots.OpenBackpack.MouseButton1Click:Connect(function()
	OpenAndCloseInventory()
end)
local _ = { "PrimaryWeapon", "SecondaryWeapon" }

function UpdateSecondaryIcon(instance)
	if typeof(instance) ~= "Instance" or not instance:GetAttribute("IsWeapon") then
		return
	end

	local v14 = v13[instance]

	if not v14 then
		return
	end

	local frame = v14.Frame

	if not frame then
		return
	end

	local etcDataClient = _G.GetEtcDataClient(localPlayer, "PrimaryWeapon")
	local etcDataClient2 = _G.GetEtcDataClient(localPlayer, "SecondaryWeapon")

	if etcDataClient == "None" or not etcDataClient then
		etcDataClient = nil
	end

	if etcDataClient2 == "None" or not etcDataClient2 then
		etcDataClient2 = nil
	end

	local primaryGradient = frame:FindFirstChild("ImageLabel") and frame.ImageLabel:FindFirstChild("PrimaryGradient")
	local secondaryGroup = frame:FindFirstChild("SecondaryGroup")

	if etcDataClient and etcDataClient2 then
		if not secondaryGroup then
			secondaryGroup = script.SecondaryGroup:Clone()
			secondaryGroup.Parent = frame
		end

		if not primaryGradient and frame:FindFirstChild("ImageLabel") then
			local clone = script.PrimaryGradient:Clone()
			clone.Parent = frame.ImageLabel
		end

		local value = localPlayer.PlayerStats.SwordName.Value

		if value == etcDataClient and etcDataClient2 then
			etcDataClient = etcDataClient2
		elseif value ~= etcDataClient2 then
			etcDataClient = false
		end

		local v15 = etcDataClient and SwordList[etcDataClient] or {}
		secondaryGroup.ImageLabel.Image = v15.Image or ""
	else
		if secondaryGroup then
			secondaryGroup:Destroy()
		end

		if primaryGradient then
			primaryGradient:Destroy()
		end
	end
end

function ClearFakeSlots()
	for _, v14 in pairs(clones) do
		v14:Destroy()
	end
end

function IsSlotFree(p)
	for _, v14 in pairs(v13) do
		if v14.Slot == p then
			return
		end
	end

	return true
end

function FakeAvailableSlots()
	ClearFakeSlots()

	for i = 1, #v12 do
		if not IsSlotFree(i) then
			continue
		end

		local clone2 = script.SlotFrame:Clone()
		clone2.Name = i
		clone2.LayoutOrder = i
		clone2.SlotNumber.Text = i
		clone2.Parent = parent.Slots
		table.insert(clones, clone2)
	end
end

function UpdateFocusTool(p)
	for _, button in pairs(parent.Slots:GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		local realName = button:GetAttribute("RealName")

		if not (realName and (ReplicatedStorage.Chest.Modules.SkillData.Styles:FindFirstChild(realName .. "_Data") or ReplicatedStorage.Chest.Modules.SkillData.Swords:FindFirstChild(realName .. "_Data"))) then
			continue
		end

		if p then
			button.ImageLabel.ImageTransparency = 0.7

			if button:FindFirstChild("SecondaryGroup") then
				button.SecondaryGroup.GroupTransparency = 0.7
			end

			if not button:GetAttribute("Lock") then
				button:SetAttribute("Lock", true)
			end
		else
			button.ImageLabel.ImageTransparency = 0

			if button:FindFirstChild("SecondaryGroup") then
				button.SecondaryGroup.GroupTransparency = 0
			end

			if button:GetAttribute("Lock") then
				button:SetAttribute("Lock", nil)
			end
		end
	end

	for _, button in pairs(parent.InventoryFrame.ScrollingFrame:GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		local realName = button:GetAttribute("RealName")

		if not (realName and (ReplicatedStorage.Chest.Modules.SkillData.Styles:FindFirstChild(realName .. "_Data") or ReplicatedStorage.Chest.Modules.SkillData.Swords:FindFirstChild(realName .. "_Data"))) then
			continue
		end

		if p then
			button.ImageLabel.ImageTransparency = 0.7

			if not button:GetAttribute("Lock") then
				button:SetAttribute("Lock", true)
			end
		else
			button.ImageLabel.ImageTransparency = 0

			if button:GetAttribute("Lock") then
				button:SetAttribute("Lock", nil)
			end
		end
	end
end

function UpdateFocusToolDriving(p)
	for _, button in pairs(parent.Slots:GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		local name = button:GetAttribute("Name")

		if not name then
			continue
		end

		if not (ReplicatedStorage.Chest.Modules.SkillData.Styles:FindFirstChild(name .. "_Data") or ReplicatedStorage.Chest.Modules.SkillData.Swords:FindFirstChild(name .. "_Data") or ReplicatedStorage.Chest.Modules.SkillData.Fruits:FindFirstChild(name .. "_Data") or string.find(
			name,
			"Fruit"
		)) then
			continue
		end

		if p then
			button.ImageLabel.ImageTransparency = 0.7

			if not button:GetAttribute("Lock") then
				button:SetAttribute("Lock", true)
			end
		else
			button.ImageLabel.ImageTransparency = 0

			if button:GetAttribute("Lock") then
				button:SetAttribute("Lock", nil)
			end
		end
	end

	for _, button in pairs(parent.InventoryFrame.ScrollingFrame:GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		local name = button:GetAttribute("Name")

		if not (name and (ReplicatedStorage.Chest.Modules.SkillData.Styles:FindFirstChild(name .. "_Data") or ReplicatedStorage.Chest.Modules.SkillData.Swords:FindFirstChild(name .. "_Data"))) then
			continue
		end

		if p then
			button.ImageLabel.ImageTransparency = 0.7

			if not button:GetAttribute("Lock") then
				button:SetAttribute("Lock", true)
			end
		else
			button.ImageLabel.ImageTransparency = 0

			if button:GetAttribute("Lock") then
				button:SetAttribute("Lock", nil)
			end
		end
	end
end

function Close()
	parent.InventoryFrame.Visible = false
	parent.Slots.Visible = true
	UpdateBackpackImage()
	ClearFakeSlots()
	ReplicatedStorage.Chest.Remotes.Bindables.ClientBeckUI:Fire("BaseFrame", {
		VisibleType = true
	})
end

function Open()
	parent.InventoryFrame.Visible = true
	parent.Slots.Visible = true
	parent.Slots.OpenBackpack.Visible = true
	FakeAvailableSlots()
	ReplicatedStorage.Chest.Remotes.Bindables.ClientBeckUI:Fire("BaseFrame", {
		VisibleType = nil
	})
end

function OpenAndCloseInventory()
	if parent.InventoryFrame.Visible then
		Close()
		return "Close"
	end

	Open()
	count = 0
	v:setNotify(count)
	return "Open"
end

function GetAvailableSlot()
	for i = 1, #v12 do
		if IsSlotFree(i) then
			return i
		end
	end
end

function GetHighestToolNumber()
	local slot = 0

	for i = 1, #v12 do
		if IsSlotFree(i) then
			return i
		end
	end

	for _, v14 in pairs(v13) do
		if slot < v14.Slot then
			slot = v14.Slot
		end
	end

	return slot + 1
end

function GetHighestInventoryNumber()
	local slot = #v12

	for _, v14 in pairs(v13) do
		if v14.Slot > #v12 and slot < v14.Slot then
			slot = v14.Slot
		end
	end

	return slot + 1
end

function GetHoldingTool(p)
	local tool = character:FindFirstChildOfClass("Tool")

	if tool and p == tool then
		return true
	end

	return nil
end

function UpdateBorder(p)
	ResetBorder()
	local v14 = tostring(p)
	local v15 = parent.InventoryFrame.ScrollingFrame:FindFirstChild(v14) or parent.InventoryFrame:FindFirstChild(v14) or parent.Slots:FindFirstChild(v14)

	if v15 then
		v15.Background.ImageColor3 = Color3.fromRGB(255, 255, 0)
		v15.Background.Image = "rbxassetid://114182551103039"
		v15.Background.ImageTransparency = 0
		v15.Border.BackgroundTransparency = 0.5
		v15:SetAttribute("Holding", true)
	end
end

function UpdateBorder2(instance)
	ResetBorder()

	if instance then
		instance.Background.ImageColor3 = Color3.fromRGB(255, 255, 0)
		instance.Background.Image = "rbxassetid://114182551103039"
		instance.Background.ImageTransparency = 0
		instance.Border.BackgroundTransparency = 0.5
		instance:SetAttribute("Holding", true)
	end
end

function ResetBorder()
	local IMAGE_ID = "rbxassetid://17017690851"

	for _, button in pairs(parent.InventoryFrame.ScrollingFrame:GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		button.Background.ImageColor3 = Color3.fromRGB(255, 255, 255)
		button.Background.Image = IMAGE_ID
		button.Background.ImageTransparency = 0.4
		button.Border.BackgroundTransparency = 1

		if button:GetAttribute("Holding") then
			button:SetAttribute("Holding", nil)
		end
	end

	for _, button in pairs(parent.InventoryFrame:GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		button.Background.ImageColor3 = Color3.fromRGB(255, 255, 255)
		button.Background.Image = IMAGE_ID
		button.Background.ImageTransparency = 0.4
		button.Border.BackgroundTransparency = 1

		if button:GetAttribute("Holding") then
			button:SetAttribute("Holding", nil)
		end
	end

	for _, button in pairs(parent.Slots:GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		button.Background.ImageColor3 = Color3.fromRGB(255, 255, 255)
		button.Background.Image = IMAGE_ID
		button.Background.ImageTransparency = 0.4
		button.Border.BackgroundTransparency = 1

		if button:GetAttribute("Holding") then
			button:SetAttribute("Holding", nil)
		end
	end
end

function IsToolAdded(p)
	for k, _ in pairs(v13) do
		if k == p then
			return true
		end
	end
end

function GetToolDataBySlot(p)
	for k, v14 in pairs(v13) do
		if v14.Slot ~= p then
			continue
		end

		if typeof(k) == "string" and v14.Tools and #v14.Tools > 0 then
			return v14.Tools[1], v14
		end

		return k, v14
	end
end

function GetDataBySlot(p)
	for _, v14 in pairs(v13) do
		if v14.Slot == p then
			return v14
		end
	end
end

function GetToolData(p)
	for k, _ in pairs(v13) do
		if k == p then
			return k
		end
	end
end

function IsButtons(p)
	for i = 1, #v12 do
		if i == p then
			return true
		end
	end
end

function ToolChangedEffect(instance)
	if instance then
		local clone2 = instance:Clone()
		_G.PU:Dust(clone2, 0.5)
		clone2.ZIndex = 10
		clone2.Parent = instance.Parent
		game.TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = UDim2.new(2.8499999999999996, 0, 2.325, 0),
			ImageTransparency = 1
		}):Play()
	end
end

function GetAddedStackTool(p)
	for k, v14 in pairs(v13) do
		if v14.Stacks and p.Name == k then
			return v14
		end
	end

	return nil
end

function StackableTool(instance)
	if instance:GetAttribute("LegacyFruit") then
		return true
	end
end

function AddTool(instance)
	if v13[instance] and not StackableTool(instance) then
		if GetHoldingTool(instance) then
			UpdateBorder(v13[instance].Slot)
		end
	else
		local v14 = GetAddedStackTool(instance)

		if v14 and #v14.Tools > 0 then
			if not table.find(v14.Tools, instance) then
				table.insert(v14.Tools, instance)

				if v14.Slot and v14.Slot > #v12 and not parent.InventoryFrame.Visible then
					count += 1
					v:setNotify(count)
				end
			end

			if GetHoldingTool(instance) then
				UpdateBorder(v14.Slot)
			end

			Update()
		elseif StackableTool(instance) then
			local v15 = GetHighestToolNumber()
			local v16 = {
				Slot = v15,
				Connects = {},
				Stacks = true,
				Tools = {}
			}
			table.insert(v16.Tools, instance)
			local clone2 = script.SlotFrame:Clone()
			clone2.SlotNumber.Text = v15
			clone2.ImageLabel.Image = instance.TextureId
			clone2.Size = parent.InventoryFrame.ScrollingFrame.UIGridLayout.CellSize
			clone2.LayoutOrder = v15
			clone2.Name = v15
			clone2.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
			clone2.Background.ImageTransparency = 0.4
			clone2:SetAttribute("RealName", instance.Name)
			clone2:SetAttribute("Name", CustomNames[instance.Name] or instance.Name)
			clone2.ToolName.Visible = true
			clone2.ToolName.Text = instance.Name

			if instance.TextureId ~= "" then
				clone2.ToolName.Visible = false
				clone2.ImageLabel.Image = instance.TextureId
				ToolChangedEffect(clone2.ImageLabel)
			end

			v16.Connects[#v16.Connects + 1] = clone2.MouseButton1Click:Connect(function()
				if flag2 or character.Humanoid.Health <= 0 or clone2:GetAttribute("Lock") then
					return
				end

				local tool = v16.Tools[1]

				if not tool then
					return
				end

				if GetHoldingTool(tool) then
					character.Humanoid:UnequipTools()
					ResetBorder()
				else
					character.Humanoid:EquipTool(tool)
					UpdateBorder(v16.Slot)
				end
			end)
			v16.Connects[#v16.Connects + 1] = clone2.MouseButton1Down:Connect(function()
				if not parent.InventoryFrame.Visible or flag2 or clone2:GetAttribute("Lock") then
					return
				end

				if clone2:IsDescendantOf(parent.Slots) then
					if moveConnection and moveConnection.Connected then
						moveConnection:Disconnect()
					end

					local count2 = 0
					moveConnection = mouse.Move:Connect(function()
						count2 += 1

						if not flag2 and count2 > 2 then
							flag2 = true
							local v17 = clone2.AbsolutePosition - parent.InventoryFrame.AbsolutePosition + clone2.AbsoluteSize / 2
							clone2.Position = UDim2.new(0, v17.X + 0.5, 0, v17.Y)
							clone2.Parent = parent.InventoryFrame

							if clone then
								clone:Destroy()
							end

							clone = script.FakeSlot:Clone()
							clone.Name = "Fake" .. clone2.Name
							clone.LayoutOrder = clone2.LayoutOrder
							clone.Parent = parent.Slots

							if moveConnection and moveConnection.Connected then
								moveConnection:Disconnect()
							end
						end
					end)
					local v17 = nil

					while task.wait() and (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsGamepadButtonDown(
						Enum.UserInputType.Gamepad1,
						Enum.KeyCode.ButtonA
					)) and (not v17 or flag2) do
						if not flag2 then
							continue
						end

						local v18 = UserInputService:GetMouseLocation() - parent.InventoryFrame.AbsolutePosition - clone2.AbsoluteSize * Vector2.new(
							0,
							1
						) / 2
						clone2.Position = UDim2.new(0, v18.X + 0.5, 0, v18.Y)
						v17 = true
					end

					flag2 = nil
					local guiObjectsAtPosition = localPlayer.PlayerGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y)
					local name = nil
					local v18 = nil

					for _, v19 in pairs(guiObjectsAtPosition) do
						v18 = v19.Name == "InventoryFrame" or v18

						if not ((v19:IsDescendantOf(parent.InventoryFrame) or v19:IsDescendantOf(parent.Slots)) and tonumber(v19.Name) and v19 ~= clone2) then
							continue
						end

						name = tonumber(v19.Name)
					end

					if moveConnection and moveConnection.Connected then
						moveConnection:Disconnect()
					end

					if clone then
						clone:Destroy()
					end

					local v19 = (not name and v18 and true or false) and GetDataBySlot((tonumber(clone2.Name)))

					if v19 then
						v19.Slot = GetHighestInventoryNumber()
						Update2()
					else
						local v20 = name and GetDataBySlot((tonumber(clone2.Name)))

						if v20 then
							local v21 = GetDataBySlot(name)
							v20.Slot = name

							if v21 then
								v21.Slot = tonumber(clone2.Name)
							end

							Update2()
						elseif clone2 and clone2.Parent then
							clone2.Parent = parent.Slots
						end
					end
				elseif clone2:IsDescendantOf(parent.InventoryFrame) then
					if moveConnection and moveConnection.Connected then
						moveConnection:Disconnect()
					end

					local count2 = 0
					moveConnection = mouse.Move:Connect(function()
						count2 += 1

						if not flag2 and count2 > 2 then
							flag2 = true
							local v17 = clone2.AbsolutePosition - parent.InventoryFrame.AbsolutePosition + clone2.AbsoluteSize / 2
							clone2.Position = UDim2.new(0, v17.X + 0.5, 0, v17.Y)
							clone2.Parent = parent.InventoryFrame

							if clone then
								clone:Destroy()
							end

							clone = script.FakeSlot:Clone()
							clone.Name = "Fake" .. clone2.Name
							clone.LayoutOrder = clone2.LayoutOrder
							clone.Parent = parent.InventoryFrame.ScrollingFrame

							if moveConnection and moveConnection.Connected then
								moveConnection:Disconnect()
							end
						end
					end)
					local v17 = nil

					while task.wait() and (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsGamepadButtonDown(
						Enum.UserInputType.Gamepad1,
						Enum.KeyCode.ButtonA
					)) and (not v17 or flag2) do
						if not flag2 then
							continue
						end

						local v18 = UserInputService:GetMouseLocation() - parent.InventoryFrame.AbsolutePosition - clone2.AbsoluteSize * Vector2.new(
							0,
							1
						) / 2
						clone2.Position = UDim2.new(0, v18.X + 0.5, 0, v18.Y)
						v17 = true
					end

					flag2 = nil
					local guiObjectsAtPosition = localPlayer.PlayerGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y)
					local name = nil

					for _, v18 in pairs(guiObjectsAtPosition) do
						if not ((v18:IsDescendantOf(parent.InventoryFrame) or v18:IsDescendantOf(parent.Slots)) and tonumber(v18.Name) and v18 ~= clone2) then
							continue
						end

						if not IsButtons((tonumber(v18.Name))) then
							continue
						end

						name = tonumber(v18.Name)
					end

					if moveConnection and moveConnection.Connected then
						moveConnection:Disconnect()
					end

					if clone then
						clone:Destroy()
					end

					local v18 = name and GetDataBySlot((tonumber(clone2.Name)))

					if v18 then
						local v19 = GetDataBySlot(name)
						v18.Slot = name

						if v19 then
							v19.Slot = tonumber(clone2.Name)
						end

						Update2()
					elseif clone2 and clone2.Parent then
						clone2.Parent = parent.InventoryFrame.ScrollingFrame
					end
				end
			end)

			if #v12 < v15 then
				clone2.Parent = parent.InventoryFrame.ScrollingFrame
				clone2.SlotNumber.Text = ""
			else
				clone2.Parent = parent.Slots
			end

			v16.Frame = clone2
			v13[instance.Name] = v16
			Update()

			if GetHoldingTool(instance) then
				UpdateBorder(v16.Slot)
			end

			if v16.Slot and v16.Slot > #v12 and not parent.InventoryFrame.Visible then
				count += 1
				v:setNotify(count)
			end
		else
			local v15 = GetHighestToolNumber()

			for k, v16 in pairs(jSONDecode) do
				if v16 ~= instance.Name or v6[k] then
					continue
				end

				v6[k] = true
				local v17 = tonumber((string.gsub(k, "%D", "")))

				if not v17 or not (v17 > 0) or not (v17 <= #v12) or GetDataBySlot(v17) then
					continue
				end

				v15 = v17
			end

			local v16 = {
				Slot = v15,
				Connects = {}
			}
			local clone2 = script.SlotFrame:Clone()
			clone2.SlotNumber.Text = v15
			clone2.ImageLabel.Image = instance.TextureId
			clone2.Size = parent.InventoryFrame.ScrollingFrame.UIGridLayout.CellSize
			clone2.LayoutOrder = v15
			clone2.Name = v15
			clone2.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
			clone2.Background.ImageTransparency = 0.4
			clone2:SetAttribute("RealName", instance.Name)
			clone2:SetAttribute("Name", CustomNames[instance.Name] or instance.Name)
			clone2.ToolName.Visible = true
			clone2.ToolName.Text = instance.Name

			if instance.TextureId ~= "" then
				clone2.ToolName.Visible = false
				clone2.ImageLabel.Image = instance.TextureId
				ToolChangedEffect(clone2.ImageLabel)
			end

			v16.Connects[#v16.Connects + 1] = instance.Changed:Connect(function()
				clone2.ToolName.Visible = true
				clone2.ToolName.Text = instance.Name

				if instance.TextureId ~= "" then
					clone2.ToolName.Visible = false
					clone2.ImageLabel.Image = instance.TextureId
				end
			end)
			v16.Connects[#v16.Connects + 1] = clone2.MouseButton1Click:Connect(function()
				if flag2 or character.Humanoid.Health <= 0 or clone2:GetAttribute("Lock") then
					return
				end

				if GetHoldingTool(instance) then
					character.Humanoid:UnequipTools()
					ResetBorder()
				else
					character.Humanoid:EquipTool(instance)
					UpdateBorder(v16.Slot)
				end
			end)
			v16.Connects[#v16.Connects + 1] = clone2.MouseButton1Down:Connect(function()
				if SwordList[instance.Name] and instance:GetAttribute("IsWeapon") then
					local etcDataClient = _G.GetEtcDataClient(localPlayer, "PrimaryWeapon")
					local etcDataClient2 = _G.GetEtcDataClient(localPlayer, "SecondaryWeapon")
					local v17

					if etcDataClient ~= "None" then
						v17 = etcDataClient or nil
					end

					if etcDataClient2 == "None" or not etcDataClient2 then
						etcDataClient2 = nil
					end

					if not flag and v17 and etcDataClient2 then
						flag = true
						task.spawn(function()
							local lastTime = tick()
							local clone3 = script.SwappingFrame:Clone()
							clone3.Parent = clone2

							while tick() - lastTime < 0.75 do
								task.wait(0.016666666666666666)
								clone3.Size = UDim2.fromScale(1, (tick() - lastTime) / 0.75)

								if flag2 or not (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsGamepadButtonDown(
									Enum.UserInputType.Gamepad1,
									Enum.KeyCode.ButtonA
								)) then
									break
								end
							end

							flag = nil
							clone3:Destroy()

							if tick() - lastTime >= 0.75 and not flag2 then
								ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("SwapWeapon")
							end
						end)
					end
				end

				if not parent.InventoryFrame.Visible or flag2 or clone2:GetAttribute("Lock") then
					return
				end

				if clone2:IsDescendantOf(parent.Slots) then
					if moveConnection and moveConnection.Connected then
						moveConnection:Disconnect()
					end

					local count2 = 0
					moveConnection = mouse.Move:Connect(function()
						count2 += 1

						if not flag2 and count2 > 2 then
							flag2 = true
							local v17 = clone2.AbsolutePosition - parent.InventoryFrame.AbsolutePosition + clone2.AbsoluteSize / 2
							clone2.Position = UDim2.new(0, v17.X + 0.5, 0, v17.Y)
							clone2.Parent = parent.InventoryFrame

							if clone then
								clone:Destroy()
							end

							clone = script.FakeSlot:Clone()
							clone.Name = "Fake" .. clone2.Name
							clone.LayoutOrder = clone2.LayoutOrder
							clone.Parent = parent.Slots

							if moveConnection and moveConnection.Connected then
								moveConnection:Disconnect()
							end
						end
					end)
					local v17 = nil

					while task.wait() and (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsGamepadButtonDown(
						Enum.UserInputType.Gamepad1,
						Enum.KeyCode.ButtonA
					)) and (not v17 or flag2) do
						if not flag2 then
							continue
						end

						local v18 = UserInputService:GetMouseLocation() - parent.InventoryFrame.AbsolutePosition - clone2.AbsoluteSize * Vector2.new(
							0,
							1
						) / 2
						clone2.Position = UDim2.new(0, v18.X + 0.5, 0, v18.Y)
						v17 = true
					end

					flag2 = nil
					local guiObjectsAtPosition = localPlayer.PlayerGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y)
					local name = nil
					local v18 = nil

					for _, v19 in pairs(guiObjectsAtPosition) do
						v18 = v19.Name == "InventoryFrame" or v18

						if not ((v19:IsDescendantOf(parent.InventoryFrame) or v19:IsDescendantOf(parent.Slots)) and tonumber(v19.Name) and v19 ~= clone2) then
							continue
						end

						name = tonumber(v19.Name)
					end

					if moveConnection and moveConnection.Connected then
						moveConnection:Disconnect()
					end

					if clone then
						clone:Destroy()
					end

					local v19 = (not name and v18 and true or false) and GetDataBySlot((tonumber(clone2.Name)))

					if v19 then
						v19.Slot = GetHighestInventoryNumber()
						Update2()
					else
						local v20 = name and GetDataBySlot((tonumber(clone2.Name)))

						if v20 then
							local v21 = GetDataBySlot(name)
							v20.Slot = name

							if v21 then
								v21.Slot = tonumber(clone2.Name)
							end

							Update2()
						elseif clone2 and clone2.Parent then
							clone2.Parent = parent.Slots
						end
					end
				elseif clone2:IsDescendantOf(parent.InventoryFrame) then
					if moveConnection and moveConnection.Connected then
						moveConnection:Disconnect()
					end

					local count2 = 0
					moveConnection = mouse.Move:Connect(function()
						count2 += 1

						if not flag2 and count2 > 2 then
							flag2 = true
							local v17 = clone2.AbsolutePosition - parent.InventoryFrame.AbsolutePosition + clone2.AbsoluteSize / 2
							clone2.Position = UDim2.new(0, v17.X + 0.5, 0, v17.Y)
							clone2.Parent = parent.InventoryFrame

							if clone then
								clone:Destroy()
							end

							clone = script.FakeSlot:Clone()
							clone.Name = "Fake" .. clone2.Name
							clone.LayoutOrder = clone2.LayoutOrder
							clone.Parent = parent.InventoryFrame.ScrollingFrame

							if moveConnection and moveConnection.Connected then
								moveConnection:Disconnect()
							end
						end
					end)
					local v17 = nil

					while task.wait() and (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsGamepadButtonDown(
						Enum.UserInputType.Gamepad1,
						Enum.KeyCode.ButtonA
					)) and (not v17 or flag2) do
						if not flag2 then
							continue
						end

						local v18 = UserInputService:GetMouseLocation() - parent.InventoryFrame.AbsolutePosition - clone2.AbsoluteSize * Vector2.new(
							0,
							1
						) / 2
						clone2.Position = UDim2.new(0, v18.X + 0.5, 0, v18.Y)
						v17 = true
					end

					flag2 = nil
					local guiObjectsAtPosition = localPlayer.PlayerGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y)
					local name = nil

					for _, v18 in pairs(guiObjectsAtPosition) do
						if not ((v18:IsDescendantOf(parent.InventoryFrame) or v18:IsDescendantOf(parent.Slots)) and tonumber(v18.Name) and v18 ~= clone2) then
							continue
						end

						if not IsButtons((tonumber(v18.Name))) then
							continue
						end

						name = tonumber(v18.Name)
					end

					if moveConnection and moveConnection.Connected then
						moveConnection:Disconnect()
					end

					if clone then
						clone:Destroy()
					end

					local v18 = name and GetDataBySlot((tonumber(clone2.Name)))

					if v18 then
						local v19 = GetDataBySlot(name)
						v18.Slot = name

						if v19 then
							v19.Slot = tonumber(clone2.Name)
						end

						Update2()
					elseif clone2 and clone2.Parent then
						clone2.Parent = parent.InventoryFrame.ScrollingFrame
					end
				end
			end)

			if #v12 < v15 then
				clone2.Parent = parent.InventoryFrame.ScrollingFrame
				clone2.SlotNumber.Text = ""
			else
				clone2.Parent = parent.Slots
			end

			v16.Frame = clone2
			v13[instance] = v16
			Update()

			if GetHoldingTool(instance) then
				UpdateBorder(v16.Slot)
			end

			if v16.Slot and v16.Slot > #v12 and not parent.InventoryFrame.Visible then
				count += 1
				v:setNotify(count)
			end
		end
	end
end

function RemoveTool(instance, _)
	if not (v13[instance] or StackableTool(instance)) then
		return
	end

	if instance.Parent ~= character and instance.Parent ~= backpack then
		local v14 = GetAddedStackTool(instance)

		if v14 then
			local tools = v14.Tools

			for i = #tools, 1, -1 do
				if tools[i] ~= instance then
					continue
				end

				table.remove(tools, i)
				break
			end

			if #tools > 0 then
				character.Humanoid:UnequipTools()
				ResetBorder()
			else
				if v14.Connects then
					for _, connect in pairs(v14.Connects) do
						if connect.Connected then
							connect:Disconnect()
						end
					end
				end

				v14.Frame:Destroy()
				v13[instance.Name] = nil
			end

			Update()
		else
			if v13[instance].Connects then
				for _, connect in pairs(v13[instance].Connects) do
					if connect.Connected then
						connect:Disconnect()
					end
				end
			end

			v13[instance].Frame:Destroy()
			v13[instance] = nil
			Update()
		end
	end
end

function UpdateBackpackImage()
	if not (touchEnabled or gamepadEnabled or parent.InventoryFrame.Visible) then
		local count2 = 0

		for i = 1, #v12 do
			if not IsSlotFree(i) then
				count2 += 1
			end
		end

		if count2 <= 2 then
			parent.Slots.OpenBackpack.Visible = true
		else
			parent.Slots.OpenBackpack.Visible = false
		end
	end
end

local v14 = {
	Common = 50000,
	Uncommon = 40000,
	Rare = 30000,
	Epic = 20000,
	Legendary = 10000,
	Mythical = 5000
}

function GetFruitRarity(p)
	for k, list in pairs(DFTier) do
		if string.find(table.concat(list, ","), p) then
			return k
		end
	end
end

function GetBaseLayout(p)
	if not p then
		return 5000
	end

	if ReplicatedStorage.Chest.Modules.SkillData.Fruits:FindFirstChild(p .. "_Data") or ReplicatedStorage.Chest.Modules.SkillData.Swords:FindFirstChild(p .. "_Data") or ReplicatedStorage.Chest.Modules.SkillData.Styles:FindFirstChild(p .. "_Data") then
		return 50
	end

	local v15 = GetFruitRarity(p)

	if v15 then
		return (v14[v15] or 50000) + (_G.Layouts[v15] or 0)
	end

	return 100
end

function UpdateLayout()
	local v15 = {}

	for k, v16 in pairs(v13) do
		if v16.Slot > #v12 then
			table.insert(v15, { v16, k })
		end
	end

	if v15[1] then
		table.sort(v15, function(a, b)
			return a[1].Slot < b[1].Slot
		end)
	end

	for i = 1, #v15 do
		if not v15[i] then
			continue
		end

		local v16 = v15[i]
		local v17 = v16[1]
		local v18 = v16[2]
		v17.Slot = #v12 + i

		if v17.Frame.Name == #v12 + i then
			continue
		end

		v17.Frame.Name = #v12 + i
		v17.Frame.LayoutOrder = #v12 + i + GetBaseLayout(typeof(v18) == "string" and v18 or v18.Name)
	end
end

function UpdateHotbar() end

function Update()
	local v15 = {}

	for i = 1, #v12 do
		v15[i] = true
	end

	local v16 = {}

	for k, v17 in pairs(v13) do
		if v17.Slot > 0 and v17.Slot <= #v12 then
			if v15[v17.Slot] then
				v15[v17.Slot] = nil
				local v18 = typeof(k) == "string" and k or k.Name
				v16["Slot:" .. v17.Slot] = v18
			else
				v17.Slot = GetHighestToolNumber()
			end
		end

		if v17.Tools and #v17.Tools > 0 then
			v17.Frame.Stacks.Text = "x" .. tostring(#v17.Tools)
		else
			v17.Frame.Stacks.Text = ""
		end

		UpdateSecondaryIcon(k)
	end

	if flag2 then
		flag2 = nil
	end

	UpdateLayout()

	if parent.InventoryFrame.Visible then
		FakeAvailableSlots()
	end

	UpdateBackpackImage()
	v5.Value = HttpService:JSONEncode(v16)
	CheckTransfrom()
end

function Update2()
	local v15 = {}

	for i = 1, #v12 do
		v15[i] = true
	end

	for _, v16 in pairs(v13) do
		if not (v16.Slot > 0 and v16.Slot <= #v12) then
			continue
		end

		if v15[v16.Slot] then
			v15[v16.Slot] = nil
		else
			v16.Slot = GetHighestToolNumber()
		end
	end

	UpdateLayout()

	if flag2 then
		flag2 = nil
	end

	local v16 = {}

	for k, v17 in pairs(v13) do
		if v12[v17.Slot] then
			local v18 = typeof(k) == "string" and k or k.Name
			v16["Slot:" .. v17.Slot] = v18
			v17.Frame.Name = v17.Slot
			v17.Frame.SlotNumber.Text = v17.Slot
			v17.Frame.LayoutOrder = v17.Slot

			if not v17.Frame:IsDescendantOf(parent.Slots) then
				v17.Frame.Parent = parent.Slots
			end

			UpdateSecondaryIcon(k)
		else
			v17.Frame.Name = v17.Slot
			v17.Frame.SlotNumber.Text = ""

			if not v17.Frame:IsDescendantOf(parent.InventoryFrame.ScrollingFrame) then
				v17.Frame.Parent = parent.InventoryFrame.ScrollingFrame
			end

			UpdateSecondaryIcon(k)
		end

		if v17.Tools and #v17.Tools > 0 then
			v17.Frame.Stacks.Text = "x" .. tostring(#v17.Tools)
		else
			v17.Frame.Stacks.Text = ""
		end
	end

	local tool = character:FindFirstChildOfClass("Tool")

	if tool and v13[tool] then
		UpdateBorder(v13[tool].Slot)
	end

	if parent.InventoryFrame.Visible then
		FakeAvailableSlots()
	end

	UpdateBackpackImage()
	v5.Value = HttpService:JSONEncode(v16)
	CheckTransfrom()
end

function ItemSearchCheck(value, value2, _)
	if value == "" then
		return true
	end

	local v15 = string.lower(value)
	local v16 = string.lower(value2)

	for i = 1, #v16 do
		if string.sub(v15, 1, #v15) == string.sub(v16, 1, i) or string.sub(v15, 1, #v15) == string.sub(
			v16,
			i,
			i + (#v15 - 1)
		) then
			return true
		end
	end
end

function Searching()
	local text = textBox.Text

	for _, button in pairs(parent.InventoryFrame.ScrollingFrame:GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		local name = button:GetAttribute("Name")

		if not name then
			continue
		end

		if ItemSearchCheck(text, name) then
			button.Visible = true
		else
			button.Visible = false
		end
	end
end

textBox.FocusLost:Connect(function()
	wait()
	Searching()
end)
textBox:GetPropertyChangedSignal("Text"):Connect(function()
	wait()
	Searching()
end)
backpack.ChildAdded:Connect(function(tool)
	if tool:IsA("Tool") then
		AddTool(tool)
	end
end)
backpack.ChildRemoved:Connect(function(tool)
	if v8.NoRemoveUpdate or not tool:IsA("Tool") then
		return
	end

	RemoveTool(tool)
end)

function CheckTransfrom()
	if not _G.AntiMobSkill then
		return
	end

	local antiMobSkill = _G.AntiMobSkill()
	UpdateFocusTool(antiMobSkill)
end

character.ChildAdded:Connect(function(tool)
	CheckTransfrom()

	if tool:IsA("Tool") then
		AddTool(tool)
	end
end)
character.ChildRemoved:Connect(function(tool)
	if v8.NoRemoveUpdate then
		return
	end

	CheckTransfrom()

	if tool:IsA("Tool") then
		RemoveTool(tool, "Character")
	end
end)

for _, tool in pairs(backpack:GetChildren()) do
	if tool:IsA("Tool") then
		AddTool(tool)
	end
end

local v15 = {
	[Enum.KeyCode.ButtonR1] = function()
		if not v4 then
			v4 = 0
			character.Humanoid:UnequipTools()
			ResetBorder()
		end

		v4 += 1

		if v4 > #v12 then
			v4 = nil
			character.Humanoid:UnequipTools()
			ResetBorder()
		end

		if v4 then
			if not GetToolDataBySlot(v4) then
				for i = v4, #v12 do
					if not GetToolDataBySlot(i) then
						continue
					end

					v4 = i
					break
				end
			end

			local v16, v17 = GetToolDataBySlot(v4)

			if v16 and v17 then
				if v16 and v17 then
					if v17.Frame and v17.Frame:GetAttribute("Lock") then
						return
					end

					if GetHoldingTool(v16) then
						character.Humanoid:UnequipTools()
						ResetBorder()
					else
						character.Humanoid:EquipTool(v16)
						UpdateBorder(v4)
					end
				end
			else
				v4 = nil
				character.Humanoid:UnequipTools()
				ResetBorder()
			end
		else
			character.Humanoid:UnequipTools()
			ResetBorder()
		end
	end,
	[Enum.KeyCode.ButtonL1] = function()
		if not v4 then
			v4 = #v12 + 1
		end

		v4 -= 1

		if v4 < 1 then
			v4 = nil
			character.Humanoid:UnequipTools()
			ResetBorder()
		end

		if v4 then
			if not GetToolDataBySlot(v4) then
				for i = v4, 0, -1 do
					if not GetToolDataBySlot(i) then
						continue
					end

					v4 = i
					break
				end
			end

			local v16, v17 = GetToolDataBySlot(v4)

			if v16 and v17 then
				if v16 and v17 then
					if v17.Frame and v17.Frame:GetAttribute("Lock") then
						return
					end

					if GetHoldingTool(v16) then
						character.Humanoid:UnequipTools()
						ResetBorder()
					else
						character.Humanoid:EquipTool(v16)
						UpdateBorder(v4)
					end
				end
			else
				v4 = nil
				character.Humanoid:UnequipTools()
				ResetBorder()
			end
		else
			character.Humanoid:UnequipTools()
			ResetBorder()
		end
	end
}
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if v15[input.KeyCode] then
		v15[input.KeyCode]()
	elseif input.KeyCode == Enum.KeyCode.ButtonX then
		local guiObjectsAtPosition = localPlayer.PlayerGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y)
		local v16 = nil

		for _, v17 in pairs(guiObjectsAtPosition) do
			if not ((v17:IsDescendantOf(parent.InventoryFrame) or v17:IsDescendantOf(parent.Slots)) and tonumber(v17.Name)) then
				continue
			end

			v16 = v17
		end

		if v16 then
			if v16:IsDescendantOf(parent.Slots) then
				local v17 = GetDataBySlot((tonumber(v16.Name)))

				if v17 then
					v17.Slot = GetHighestInventoryNumber()
					Update2()
				end
			elseif v16:IsDescendantOf(parent.InventoryFrame) then
				local v17 = GetDataBySlot((tonumber(v16.Name)))
				local slot = v17 and GetAvailableSlot()

				if slot then
					v17.Slot = slot
					Update2()
				end
			end
		end
	elseif input.KeyCode == Enum.KeyCode.Backquote then
		OpenAndCloseInventory()
	elseif v7[input.KeyCode] then
		if character.Humanoid.Health <= 0 then
			return
		end

		local v16 = v7[input.KeyCode]
		local v17, v18 = GetToolDataBySlot(v16)

		if v17 and v18 then
			if v18.Frame and v18.Frame:GetAttribute("Lock") then
				return
			end

			if StackableTool(v17) then
				local tool = character:FindFirstChildWhichIsA("Tool")

				if tool and tool.Name == v17.Name then
					character.Humanoid:UnequipTools()
					ResetBorder()
				else
					character.Humanoid:EquipTool(v17)
					UpdateBorder(v16)
				end
			else
				if GetHoldingTool(v17) then
					character.Humanoid:UnequipTools()
					ResetBorder()
				else
					character.Humanoid:EquipTool(v17)
					UpdateBorder(v16)
				end

				if SwordList[v17.Name] and v17:GetAttribute("IsWeapon") then
					local etcDataClient = _G.GetEtcDataClient(localPlayer, "PrimaryWeapon")
					local etcDataClient2 = _G.GetEtcDataClient(localPlayer, "SecondaryWeapon")

					if etcDataClient == "None" or not etcDataClient then
						etcDataClient = nil
					end

					if etcDataClient2 == "None" or not etcDataClient2 then
						etcDataClient2 = nil
					end

					if not (etcDataClient and etcDataClient2) or flag then
						return
					end

					flag = true
					local lastTime = tick()
					local clone2 = script.SwappingFrame:Clone()
					clone2.Parent = v18.Frame

					while tick() - lastTime < 0.75 do
						task.wait(0.016666666666666666)
						clone2.Size = UDim2.fromScale(1, (tick() - lastTime) / 0.75)

						if not UserInputService:IsKeyDown(input.KeyCode) then
							break
						end
					end

					flag = nil
					clone2:Destroy()

					if tick() - lastTime >= 0.75 then
						ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("SwapWeapon")
					end
				end
			end
		end
	end
end)

function ForceDeleteUpdate()
	local count2 = 0
	local flag3 = nil

	while true do
		local flag4 = true

		for k, v17 in pairs(v13) do
			local tool = v17.Tool

			if not (tool.Parent ~= character and tool.Parent ~= backpack) then
				continue
			end

			table.remove(v13, k)
			flag4 = nil
			flag3 = true
			break
		end

		if flag4 then
			if flag3 then
				Update()
			end

			break
		else
			count2 += 1

			if count2 % 50 == 1 then
				task.wait()
			end
		end
	end
end

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonA or input.UserInputType == Enum.UserInputType.Touch then
		if moveConnection and moveConnection.Connected then
			moveConnection:Disconnect()
		end

		if flag2 then
			flag2 = nil
		end
	end
end)
ReplicatedStorage:WaitForChild("Chest").Remotes.Events.BackpackUpdater.OnClientEvent:Connect(function(p)
	if p == "NoRemoveUpdate" then
		v8.NoRemoveUpdate = true
	elseif p == "Normal/Update" then
		v8 = {}
		ForceDeleteUpdate()
	elseif p == "Update2" then
		return Update2()
	end
end)
character:WaitForChild("Humanoid").Died:Connect(function()
	character.Humanoid:UnequipTools()
	ResetBorder()
end)

while not localPlayer:FindFirstChild("DataLoaded") do
	task.wait(0.1)
end

local playerStats = localPlayer:WaitForChild("PlayerStats")
local etcData = playerStats:WaitForChild("EtcData")
local swordName = playerStats:WaitForChild("SwordName")
local jSONDecode2 = HttpService:JSONDecode(etcData.Value)
etcData.Changed:Connect(function()
	local jSONDecode3 = HttpService:JSONDecode(etcData.Value)

	if jSONDecode3.PrimaryWeapon ~= jSONDecode2.PrimaryWeapon or jSONDecode3.SecondaryWeapon ~= jSONDecode2.SecondaryWeapon then
		Update2()
	end

	jSONDecode2 = jSONDecode3
end)
swordName.Changed:Connect(Update2)