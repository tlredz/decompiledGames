local GuiButtonHandler = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local TextChatService = game:GetService("TextChatService")
local checkTable = require(ReplicatedStorage.Modules.UtilityAlec.checkTable)
require(ReplicatedStorage.Modules.UtilityAlec.removeTable)
require(ReplicatedStorage.Modules.UtilityAlec)
GuiButtonHandler.ActiveButtons = {}
local v = {
	Enum.KeyCode.ButtonA,
	Enum.KeyCode.ButtonB,
	Enum.KeyCode.ButtonX,
	Enum.KeyCode.ButtonY,
	Enum.KeyCode.ButtonL1,
	Enum.KeyCode.ButtonL2,
	Enum.KeyCode.ButtonL3,
	Enum.KeyCode.ButtonR1,
	Enum.KeyCode.ButtonR2,
	Enum.KeyCode.ButtonR3,
	Enum.KeyCode.ButtonStart,
	Enum.KeyCode.ButtonSelect,
	Enum.KeyCode.DPadUp,
	Enum.KeyCode.DPadDown,
	Enum.KeyCode.DPadLeft,
	Enum.KeyCode.DPadRight,
	Enum.KeyCode.Thumbstick1,
	Enum.KeyCode.Thumbstick2
}
local v2 = {}

for _, v5 in pairs(v) do
	v2[v5] = true
end

local v5 = {}

for _, v6 in pairs({
	"ButtonA",
	"ButtonB",
	"ButtonX",
	"ButtonY",
	"ButtonLB",
	"ButtonLT",
	"ButtonLS",
	"ButtonRB",
	"ButtonRT",
	"ButtonRS",
	"ButtonStart",
	"ButtonSelect"
}) do
	v5[v6] = true
end

local v6 = {}

for _, v7 in pairs({
	"ButtonCross",
	"ButtonCircle",
	"ButtonSquare",
	"ButtonTriangle",
	"ButtonL1",
	"ButtonL2",
	"ButtonL3",
	"ButtonR1",
	"ButtonR2",
	"ButtonR3",
	"ButtonOptions",
	"ButtonTouchpad",
	"ButtonShare"
}) do
	v6[v7] = true
end

local v7 = UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonA) == "ButtonCross" and "PlayStation" or "Xbox"
local v8 = {
	E = "rbxassetid://136703416305074",
	F = "rbxassetid://126568717219318",
	R = "rbxassetid://101976264854500",
	Q = "rbxassetid://108690389127733",
	LeftMouse = "rbxassetid://99020046841021",
	Backspace = "rbxassetid://129301379972292",
	Ctrl = "rbxassetid://100416518463032",
	Shft = "rbxassetid://106381807530988"
}
local v9 = {
	RightTrigger = "rbxassetid://84116671582110",
	LeftDPad = "rbxassetid://90394679513072",
	Y = "rbxassetid://88611156896758",
	X = "rbxassetid://101265929766660",
	B = "rbxassetid://74432608286656",
	L3 = "rbxassetid://115304342581046"
}
local v10 = {
	Drag = "LeftMouse",
	Undrag = "LeftMouse",
	Drop = "Backspace",
	Store = "F",
	Unstore = "F",
	Reload = "R",
	Take = "E",
	Use = "E",
	Eat = "E",
	Sprint = "Shft",
	Plant = "E",
	Pick = "E",
	["Plant Seeds"] = "E",
	Shoot = "nothing",
	Flame = "nothing",
	Off = "nothing",
	Swing = "nothing",
	Cast = "nothing",
	Play = "nothing",
	Reel = "nothing",
	Light = "nothing",
	["Heal (HOLD)"] = "nothing",
	Rotate = "R",
	Place = "LeftMouse",
	Ping = "Q",
	["Auto Fire"] = "nothing"
}
local v11 = {
	Drag = "RightTrigger",
	Undrag = "RightTrigger",
	Drop = "LeftDPad",
	Store = "Y",
	Unstore = "Y",
	Reload = "Y",
	Take = "X",
	Use = "X",
	Eat = "X",
	Sprint = "L3",
	Plant = "X",
	Pick = "X",
	["Plant Seeds"] = "X",
	Shoot = "nothing",
	Flame = "nothing",
	Off = "nothing",
	Swing = "nothing",
	Cast = "nothing",
	Play = "nothing",
	Reel = "nothing",
	Light = "nothing",
	["Heal (HOLD)"] = "nothing",
	["Auto Fire"] = "nothing",
	Rotate = "B",
	Place = "RightTrigger"
}
local v12 = {
	"Shoot",
	"Flame",
	"Off",
	"Swing",
	"Cast",
	"Play",
	"Reel",
	"Light",
	"Heal (HOLD)"
}
local v13 = {
	Drag = 30,
	Drop = 10,
	Reload = 5,
	Undrag = 30,
	Store = 99,
	Unstore = 35,
	Shoot = 60,
	Flame = 60,
	Off = 60,
	Take = 40,
	Use = 40,
	Eat = 50,
	Sprint = 4,
	Ping = 4,
	Plant = 50,
	Pick = 50,
	Rotate = 30,
	Place = 40,
	["Plant Seeds"] = 55
}
local v14 = { "Sprint", "Ping" }
local v15 = {
	"Shoot",
	"Flame",
	"Off",
	"Swing",
	"Cast",
	"Play",
	"Reel",
	"Light",
	"Heal",
	"Heal (HOLD)",
	"Place",
	"Auto Fire"
}
local v16 = {}
local v17 = {}
local v18 = {}
local v19 = nil
local count = 0
local v20 = false

function HoldBar(p, duration, value)
	local dropBar = Client.Interface.DropBar
	dropBar.Visible = true
	local fill = dropBar:FindFirstChild("Fill")
	dropBar.TextLabel.Text = value or "dropping..."

	if v19 then
		v19:Cancel()
	end

	fill.Size = UDim2.new(0, 0, 0.9, 0)
	v19 = TweenService:Create(fill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0.95, 0, 0.8, 0)
	})
	v19:Play()
	task.spawn(function()
		wait(duration)

		if p == count then
			v20 = true
			dropBar.Visible = false
			fill.Size = UDim2.new(0, 0, 0.9, 0)
		end
	end)
end

function v16.Drag()
	Client.InteractionHandler.CheckMobileFirstPersonInteraction()
end

function v16.Undrag()
	Client.InteractionHandler.StopDragging()
end

function v16.Take()
	Client.InteractionHandler.CheckPrimaryInteraction(nil, Enum.UserInputState.Begin)
end

function v16.Use()
	Client.InteractionHandler.CheckPrimaryInteraction(nil, Enum.UserInputState.Begin)
end

v16["Plant Seeds"] = function()
	Client.InteractionHandler.CheckPrimaryInteraction(nil, Enum.UserInputState.Begin)
end

function v16.Eat()
	Client.InteractionHandler.CheckPrimaryInteraction(nil, Enum.UserInputState.Begin)
end

function v16.Plant()
	Client.InteractionHandler.CheckPrimaryInteraction(nil, Enum.UserInputState.Begin)
end

function v16.Pick()
	Client.InteractionHandler.CheckPrimaryInteraction("Pick", Enum.UserInputState.Begin)
end

function v16.Store()
	Client.Events.RequestStoreItem:Fire()
end

function v16.Unstore()
	Client.Events.RequestUnstoreItem:Fire()
end

function v18.Unstore()
	Client.Events.RequestUnstoreAll:Fire()
end

function v16.Drop(p)
	count += 1
	local v21 = count
	local currentlyEquipped = Client.InventoryHandler.GetCurrentlyEquipped()

	if Client.InventoryHandler.ToolEquipped() then
		HoldBar(v21, 0.85, "dropping...")

		repeat
			wait()
		until v20 or v21 ~= count or p.UserInputState == Enum.UserInputState.End

		if v21 ~= count then
			return
		end
	end

	v20 = false

	if p.UserInputState == Enum.UserInputState.End or Client.InventoryHandler.GetCurrentlyEquipped() ~= currentlyEquipped then
		v17.Drop()
	else
		Client.InventoryHandler.DropEquippedItem()
	end
end

function v16.Reload()
	Client.Events.RequestReloadWeapon:Fire()
end

function v16.Rotate(p)
	Client.StructurePlacementClient.StartRotating(p)
end

function v16.Place()
	Client.InventoryHandler.ActivateTool()
end

function v16.Shoot()
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local GuiService = game:GetService("GuiService")
	local guiInset = GuiService:GetGuiInset()
	Client.Interface.MobileCursor.Visible = true
	local screenPointToRay = workspace.CurrentCamera:ScreenPointToRay(
		viewportSize.X / 2,
		viewportSize.Y / 2 - guiInset.Y
	)
	Client.InventoryHandler.ActivateTool(screenPointToRay, "MobileButton")
end

v16["Auto Fire"] = function()
	local currentlyEquippedClass = Client.InventoryHandler.GetCurrentlyEquippedClass()
	local tool = currentlyEquippedClass and currentlyEquippedClass.Tool

	if tool then
		tool:ToggleAutoFire()
	end
end

function v16.Flame()
	Client.InventoryHandler.ActivateTool()
end

function v16.Off()
	Client.InventoryHandler.DeactivateTool()
end

function v16.Light()
	Client.InventoryHandler.ActivateTool()
end

function v16.Swing()
	Client.InventoryHandler.ActivateTool()
end

function v16.Play()
	Client.InventoryHandler.ActivateTool()
end

function v16.Reel()
	Client.InventoryHandler.ActivateTool()
end

v16["Heal (HOLD)"] = function()
	Client.InventoryHandler.ActivateTool()
end

v17["Heal (HOLD)"] = function()
	Client.InventoryHandler.DeactivateTool()
end

function v17.Shoot()
	Client.InventoryHandler.DeactivateTool("MobileButton")
end

function v17.Drop()
	Client.Interface.DropBar.Visible = false
	count += 1
end

function v17.Rotate()
	Client.StructurePlacementClient.StopRotating()
end

local v21 = nil

function GuiButtonHandler.CreateTouchDeviceStoreButton()
	local _ = localPlayer.PlayerGui.AvailableInputList.AvailableInputList.AvailableInputList.AvailableInputList
	local button1 = localPlayer.PlayerGui.MobileButtons.Frame.Button1

	if v21 then
		v21:Destroy()
	end

	local clone = button1:Clone()
	v21 = clone
	clone.Parent = localPlayer.PlayerGui.Interface
	clone.TextLabel.Text = "Store"
	clone.AnchorPoint = Vector2.new(0.5, 0.5)
	clone.Size = UDim2.new(0.1, 0, 0.1, 0)
	Instance.new("UIAspectRatioConstraint", clone)
	clone.Visible = false
	local v22 = "Store"
	local v23 = 0
	clone.MouseButton1Click:Connect(function()
		if v22 == "Store" then
			Client.Events.RequestStoreItem:Fire()
			return
		end

		local now = tick()

		if v23 <= now then
			Client.InteractionHandler.CheckPrimaryInteraction(nil, Enum.UserInputState.Begin)
		end
	end)
	local _ = workspace.CurrentCamera.ViewportSize.Y
	local GuiService = game:GetService("GuiService")
	local guiInset = GuiService:GetGuiInset()
	local draggingItem = Client.InteractionHandler.GetDraggingItem()
	task.spawn(function()
		while Client.InteractionHandler.GetDraggingItem() == draggingItem and clone.Parent do
			pcall(function()
				local worldToScreenPoint, _ = workspace.CurrentCamera:WorldToScreenPoint(draggingItem:GetPivot().Position)
				clone.Position = UDim2.new(0, worldToScreenPoint.X, 0, worldToScreenPoint.Y + guiInset.Y)
				local currentlyEquipped = Client.InventoryHandler.GetCurrentlyEquipped()
				local v24 = currentlyEquipped and currentlyEquipped:HasTag("ItemBag")
				local v25 = not v24 and 0 or Client.Utility.GetItemBagSpace(currentlyEquipped, localPlayer) or 0
				local v26 = v24 and ((currentlyEquipped:GetAttribute("CountedItems") or currentlyEquipped:GetAttribute("NumberItems") or 0) < v25 or not Client.Utility.ItemNeedsBagSpace(
					draggingItem,
					localPlayer
				))
				local interaction = draggingItem:GetAttribute("Interaction")
				local v27 = interaction == "Tool" or interaction == "Armour"
				local text, visible

				if Client.GlobalSettings.FloatingItemActions and (v27 or not v26) then
					local canTake = Client.InteractionHandler.CanTake(draggingItem)
					text = v27 and canTake == "Take" and "Equip" or canTake

					if text == nil then
						visible = false
					else
						visible = true
					end
				else
					text = "Store"
					visible = v26 and not v27
				end

				if text ~= v22 then
					v22 = text
					v23 = tick() + 0.35

					if text then
						clone.TextLabel.Text = text
					end
				end

				clone.Visible = visible
			end)
			RunService.RenderStepped:Wait()
		end

		clone:Destroy()

		if v21 == clone then
			v21 = nil
		end
	end)
end

Client.Events.PlayerDied:Connect(function()
	if v21 then
		v21:Destroy()
		v21 = nil
	end
end)
local UserInputService2 = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

function initialGetPlatform()
	if GuiService:IsTenFootInterface() then
		return "Controller"
	end

	if UserInputService2.TouchEnabled and not UserInputService2.MouseEnabled or UserInputService2.TouchEnabled and not UserInputService2.KeyboardEnabled or UserInputService2.TouchEnabled and workspace.CurrentCamera.ViewportSize.Y < 800 then
		return "Touch"
	end

	if UserInputService2.GamepadEnabled and not UserInputService2.KeyboardEnabled then
		return "Controller"
	end

	return "PC"
end

function PlaceBackpackAboveHotbar()
	local backpack = Client.Interface.Backpack
	local hotbar = Client.Interface.Hotbar
	local v22 = hotbar.Position.Y.Scale - hotbar.Size.Y.Scale
	backpack.Position = UDim2.new(0.5, 0, v22 - 0.01, -backpack.AbsoluteSize.Y * 0.0825)
end

function MakeMobile()
	Client.Interface.Hotbar.Size = UDim2.new(0.5, 0, 0.12, 0)
	Client.Interface.StatBars.Size = UDim2.new(0.167, 0, 0.092, 0)
	Client.Interface.Backpack.Size = UDim2.new(0.5, 0, 0.5, 0)
	PlaceBackpackAboveHotbar()
	Client.Interface.TopRight.Frame.Map.Marker.Pointer.Visible = true
	Client.Interface.TopRight.Frame.Map.Marker.TextLabel.Visible = false
	Client.Interface.TopRight.Frame.Map.Marker.Controller.Visible = false

	for _, v22 in pairs(CollectionService:GetTagged("PlaystationInvis")) do
		v22.Visible = false
	end

	for _, v22 in pairs(CollectionService:GetTagged("XboxInvis")) do
		v22.Visible = false
	end

	for _, v22 in pairs(CollectionService:GetTagged("MobileInvis")) do
		v22.Visible = false
	end

	for _, v22 in pairs(CollectionService:GetTagged("TouchInvis")) do
		v22.Visible = false
	end

	task.spawn(function()
		local notificationsMenu = localPlayer:WaitForChild("PlayerGui"):WaitForChild("NotificationsMenu"):WaitForChild("NotificationsMenu"):WaitForChild("NotificationsMenu")
		notificationsMenu.Background.NoteTemplate.Size = UDim2.new(1, 0, 0.724, 0)
	end)
end

function MakeNotMobile(p)
	Client.Interface.Hotbar.Size = UDim2.new(0.5, 0, 0.08, 0)
	Client.Interface.StatBars.Size = UDim2.new(0.15, 0, 0.08, 0)
	Client.Interface.Backpack.Size = UDim2.new(0.3, 0, 0.3, 0)
	PlaceBackpackAboveHotbar()
	Client.Interface.TopRight.Frame.Map.Marker.Pointer.Visible = false

	if p then
		Client.Interface.TopRight.Frame.Map.Marker.Controller.Visible = true

		for _, v22 in pairs(CollectionService:GetTagged("MobileInvis")) do
			v22.Visible = false
		end

		Client.Interface.TopRight.Frame.Map.Marker.TextLabel.Visible = false

		if v7 == "PlayStation" then
			print("SETTING PLAYSTATION")

			for _, v22 in pairs(CollectionService:GetTagged("PlayStationInvis")) do
				v22.Visible = true
			end

			for _, v22 in pairs(CollectionService:GetTagged("XboxInvis")) do
				v22.Visible = false
			end
		else
			for _, v22 in pairs(CollectionService:GetTagged("XboxInvis")) do
				v22.Visible = true
			end

			for _, v22 in pairs(CollectionService:GetTagged("PlayStationInvis")) do
				v22.Visible = false
			end
		end
	else
		Client.Interface.TopRight.Frame.Map.Marker.Controller.Visible = false
		Client.Interface.TopRight.Frame.Map.Marker.TextLabel.Visible = true

		for _, v22 in pairs(CollectionService:GetTagged("XboxInvis")) do
			v22.Visible = false
		end

		for _, v22 in pairs(CollectionService:GetTagged("PlaystationInvis")) do
			v22.Visible = false
		end

		for _, v22 in pairs(CollectionService:GetTagged("MobileInvis")) do
			v22.Visible = true
		end
	end

	for _, v22 in pairs(CollectionService:GetTagged("TouchInvis")) do
		v22.Visible = true
	end

	task.spawn(function()
		local notificationsMenu = localPlayer:WaitForChild("PlayerGui"):WaitForChild("NotificationsMenu"):WaitForChild("NotificationsMenu"):WaitForChild("NotificationsMenu")
		notificationsMenu.Background.NoteTemplate.Size = UDim2.new(1, 0, 0.624, 0)
	end)
end

local v22 = initialGetPlatform()

function DetectPlatformFromLastInput()
	local lastInputType = UserInputService:GetLastInputType()

	if lastInputType == Enum.UserInputType.Touch then
		return "Touch"
	end

	if lastInputType == Enum.UserInputType.Keyboard or lastInputType == Enum.UserInputType.MouseButton1 or lastInputType == Enum.UserInputType.MouseButton2 or lastInputType == Enum.UserInputType.MouseButton3 or lastInputType == Enum.UserInputType.MouseMovement or lastInputType == Enum.UserInputType.MouseWheel then
		return "PC"
	end

	if lastInputType.Value >= Enum.UserInputType.Gamepad1.Value and lastInputType.Value <= Enum.UserInputType.Gamepad8.Value then
		return "Controller"
	end

	return v22
end

function ApplyPlatform()
	if v22 == "Touch" then
		MakeMobile()
	else
		MakeNotMobile(v22 == "Controller")
	end
end

function UpdatePlatform(p)
	local v23 = DetectPlatformFromLastInput()
	local v24 = v7

	if p and v2[p.KeyCode] then
		local stringForKeyCode = UserInputService:GetStringForKeyCode(p.KeyCode)
		v24 = v5[stringForKeyCode] and "Xbox" or v6[stringForKeyCode] and "PlayStation" or v24
	end

	if v23 == v22 and v24 == v7 then
		return
	end

	v22 = v23
	v7 = v24
	ApplyPlatform()
end

UserInputService.InputBegan:Connect(function(input)
	UpdatePlatform(input)
end)
ApplyPlatform()

function GuiButtonHandler.GetCurrentPlatform()
	return v22
end

UserInputService.LastInputTypeChanged:Connect(function()
	UpdatePlatform(nil)
end)
task.spawn(function()
	wait(5)

	if v22 == "PC" and UserInputService.KeyboardEnabled and UserInputService.MouseEnabled and not UserInputService.TouchEnabled then
		TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXSystem"):DisplaySystemMessage("<font color='#FFFF00'>Press Q to ping 🔔 [BETA]</font>")
	elseif v22 == "Controller" then
		TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXSystem"):DisplaySystemMessage("<font color='#FFFF00'>Press <b>DPAD UP</b> to ping 🔔 [BETA]</font>")
	end
end)

function getButtonInfo(p)
	local v23 = false

	for _, activeButton in pairs(GuiButtonHandler.ActiveButtons) do
		if activeButton.Name == p then
			v23 = activeButton
		end
	end

	return v23
end

local v23 = nil
local v24 = nil
local v25 = nil
local connections = {}

function hideOnMobile(p)
	if checkTable(v14, p) or p == "Drag" and (Client.InteractionHandler.GetDraggingItem() or not Client.FirstPersonModule.IsVisible()) then
		return true
	end

	if p == "Shoot" then
		local currentlyEquipped = Client.InventoryHandler.GetCurrentlyEquipped()

		if not (Client.FirstPersonModule.IsVisible() or currentlyEquipped and currentlyEquipped:GetAttribute("Automatic")) then
			return true
		end
	end
end

local v26 = {
	Unstore = true
}
local v27 = {}

local function InputIsOverButton(p, p2)
	local absolutePosition = p.AbsolutePosition
	local v28 = absolutePosition + p.AbsoluteSize
	local position = p2.Position
	return position.X >= absolutePosition.X and position.X <= v28.X and position.Y >= absolutePosition.Y and position.Y <= v28.Y
end

function ConnectButtonEvents(p, p2)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function cancelPress()
		if not v27[p] then
			return
		end

		v27[p] = nil

		if v26[p2.Name] then
			if p2.Name == "Unstore" then
				Client.Interface.DropBar.Visible = false
				count += 1
			end
		elseif v17[p2.Name] then
			v17[p2.Name]()
		end
	end

	table.insert(connections, p.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 or input.UserInputState ~= Enum.UserInputState.Begin or v27[p] then
			return
		end

		local v28 = {
			holdStart = tick(),
			input = input
		}
		v27[p] = v28

		if v26[p2.Name] then
			task.delay(0.75, function()
				if v27[p] ~= v28 then
					return
				end

				if p2.Name == "Unstore" then
					count += 1
					local v29 = count

					if Client.InventoryHandler.ToolEquipped() then
						HoldBar(v29, 0.75, "dropping all...")
					end
				end
			end)
			task.delay(1.5, function()
				if v27[p] ~= v28 then
					return
				end

				if p2.Name == "Unstore" then
					Client.Interface.DropBar.Visible = false
					count += 1

					if v18[p2.Name] then
						v18[p2.Name]()
					end
				end

				v27[p] = nil
			end)
		elseif v16[p2.Name] then
			v16[p2.Name](input)
		end
	end))
	table.insert(connections, UserInputService.InputChanged:Connect(function(input)
		local v28 = v27[p]

		if not v28 or v28.input ~= input then
			return
		end

		local v29 = p
		local absolutePosition = v29.AbsolutePosition
		local v30 = absolutePosition + v29.AbsoluteSize
		local position = input.Position
		local v31

		if position.X >= absolutePosition.X and position.X <= v30.X and position.Y >= absolutePosition.Y then
			v31 = position.Y <= v30.Y
		else
			v31 = false
		end

		if not v31 then
			cancelPress() -- equivalent call inferred; original call site unknown
		end
	end))
	table.insert(connections, UserInputService.InputEnded:Connect(function(input)
		local v28 = v27[p]

		if not v28 or v28.input ~= input then
			return
		end

		local v29 = tick() - v28.holdStart >= 1.5
		v27[p] = nil

		if v26[p2.Name] then
			if not v29 then
				if p2.Name == "Unstore" then
					Client.Interface.DropBar.Visible = false
					count += 1
				end

				if v16[p2.Name] then
					v16[p2.Name]()
				end
			end
		elseif v17[p2.Name] then
			v17[p2.Name]()
		end
	end))
end

function GetTouchControlFrame()
	local touchGui = localPlayer.PlayerGui:FindFirstChild("TouchGui")

	if touchGui then
		return touchGui:FindFirstChild("TouchControlFrame")
	end

	return nil
end

function UpdateMobileButtonScale()
	local frame = localPlayer.PlayerGui.MobileButtons.Frame
	local v28 = GetTouchControlFrame()
	local absoluteSize = v28 and v28.AbsoluteSize or frame.Screen.AbsoluteSize
	local v29 = math.min(absoluteSize.X, absoluteSize.Y) <= 500
	local v30 = v29 and 70 or 120
	frame.Size = UDim2.new(0, v30, 0, v30)
	frame.Position = v29 and UDim2.new(1, -(v30 * 1.5 - 10), 1, -v30 - 20) or UDim2.new(
		1,
		-(v30 * 1.5 - 10),
		1,
		-v30 * 1.75
	)
	ApplyMobileButtonLayout(frame, v30, v29)
end

function ApplyMobileButtonLayout(instance, p, p2)
	local setting = Client.Settings[p2 and "MobileButtonLayoutPhone" or "MobileButtonLayoutTablet"]
	local absoluteSize = instance.Parent.AbsoluteSize

	if not Client.GlobalSettings.MobileButtonEditor or not setting or absoluteSize.X == 0 then
		return
	end

	local vector = Vector2.new(
		absoluteSize.X * instance.Position.X.Scale + instance.Position.X.Offset,
		absoluteSize.Y * instance.Position.Y.Scale + instance.Position.Y.Offset
	)
	local v28 = -vector / p
	local v29 = (absoluteSize - vector) / p

	for childName, v30 in pairs(setting) do
		local child = instance:FindFirstChild(childName)

		if not child then
			continue
		end

		local halfSize = v30.Size / 2
		child.AnchorPoint = Vector2.new(0.5, 0.5)
		child.Size = UDim2.fromScale(v30.Size, v30.Size)
		child.Position = UDim2.fromScale(
			math.clamp(v30.X, v28.X + halfSize, v29.X - halfSize),
			(math.clamp(v30.Y, v28.Y + halfSize, v29.Y - halfSize))
		)
	end
end

local v28 = {}
local color = Color3.fromRGB(255, 255, 255)

function GuiButtonHandler.RefreshButtonStyles()
	local frame = localPlayer.PlayerGui.MobileButtons.Frame
	local v29 = {
		{ v23, frame.Button1 },
		{ v24, frame.Button2 },
		{ v25, frame.Button3 }
	}

	for _, v30 in pairs(v29) do
		local v31 = v30[1]
		local v32 = v30[2]
		v32.ImageColor3 = color
		v32.TextLabel.TextColor3 = color

		if not v31 then
			continue
		end

		v32.TextLabel.Text = v31.Name
		local v33 = v28[v31.Name]

		if v33 then
			v33(v32, v31)
		end
	end
end

v28["Auto Fire"] = function(p, _)
	local currentlyEquippedClass = Client.InventoryHandler.GetCurrentlyEquippedClass()
	local tool = currentlyEquippedClass and currentlyEquippedClass.Tool

	if tool and tool.AutoFire then
		p.TextLabel.TextColor3 = Color3.fromRGB(90, 255, 120)
		p.ImageColor3 = Color3.fromRGB(90, 255, 120)
	end
end

function sortMobileButtons()
	debug.profilebegin("SortButtons")
	debug.profilebegin("SetPriority")
	v27 = {}
	local v29 = v22
	v23 = nil
	v24 = nil
	v25 = nil
	local priority = -999

	for i = 1, #GuiButtonHandler.ActiveButtons do
		local activeButton = GuiButtonHandler.ActiveButtons[i]

		if checkTable(v12, activeButton.Name) or hideOnMobile(activeButton.Name) or not (priority < activeButton.Priority) then
			continue
		end

		priority = activeButton.Priority
		v23 = activeButton
	end

	if v23 then
		local priority2 = -999

		for i = 1, #GuiButtonHandler.ActiveButtons do
			local activeButton = GuiButtonHandler.ActiveButtons[i]

			if checkTable(v12, activeButton.Name) or activeButton.Name == v23.Name or hideOnMobile(activeButton.Name) or not (priority2 < activeButton.Priority) then
				continue
			end

			priority2 = activeButton.Priority
			v24 = activeButton
		end
	end

	for i = 1, #GuiButtonHandler.ActiveButtons do
		local activeButton = GuiButtonHandler.ActiveButtons[i]

		if not checkTable(v12, activeButton.Name) or hideOnMobile(activeButton.Name) then
			continue
		end

		local _ = activeButton.Priority
		v25 = activeButton
	end

	if not v25 and v23 and v24 then
		for i = 1, #GuiButtonHandler.ActiveButtons do
			local activeButton = GuiButtonHandler.ActiveButtons[i]

			if activeButton.Name == v23.Name or activeButton.Name == v24.Name or hideOnMobile(activeButton.Name) then
				continue
			end

			local _ = activeButton.Priority
			v25 = activeButton
		end
	end

	debug.profileend()
	debug.profilebegin("CreateButtons")
	local frame = localPlayer.PlayerGui.MobileButtons.Frame
	local availableInputList = localPlayer.PlayerGui.AvailableInputList.AvailableInputList.AvailableInputList.AvailableInputList
	local button1 = frame.Button1
	local button2 = frame.Button2
	local button3 = frame.Button3

	if v29 == "Touch" then
		frame.Visible = true
		availableInputList.Visible = false
	else
		frame.Visible = false
		availableInputList.Visible = true
	end

	UpdateMobileButtonScale()

	for _, connection in pairs(connections) do
		connection:Disconnect()
	end

	connections = {}

	if v25 then
		button3.Visible = true
		button3.TextLabel.Text = v25.Name
		ConnectButtonEvents(button3, v25)
	else
		button3.Visible = false
	end

	if v24 then
		button2.Visible = true
		button2.TextLabel.Text = v24.Name
		ConnectButtonEvents(button2, v24)
	else
		button2.Visible = false
	end

	if v23 then
		button1.Visible = true
		button1.TextLabel.Text = v23.Name
		ConnectButtonEvents(button1, v23)
	else
		button1.Visible = false
	end

	debug.profileend()
	GuiButtonHandler.RefreshButtonStyles()
	debug.profileend()
end

function CreateButton(p, layoutOrder, p2)
	if table.find(v15, p) then
		return
	end

	local availableInputList = localPlayer.PlayerGui.AvailableInputList.AvailableInputList.AvailableInputList.AvailableInputList
	local clone = availableInputList.Template:Clone()

	if v22 == "Controller" then
		assert(v9[p2], "No icon set for " .. p2)
		clone.ImageLabel.Image = v9[p2]
	else
		assert(v8[p2], "No icon set for " .. p2)
		clone.ImageLabel.Image = v8[p2]
	end

	if p == "Sprint" or p == "Ping" then
		clone.ImageLabel.ImageColor3 = Color3.fromRGB(220, 220, 0)
	end

	clone.Frame.TextLabel.Text = p
	clone.LayoutOrder = 10000 + layoutOrder
	clone.Name = p

	if checkTable(v12, p) then
		clone.LayoutOrder = layoutOrder
	end

	local buttonInfo = getButtonInfo(p)
	buttonInfo.Gui = clone
	clone.Parent = availableInputList
	clone.Visible = true
end

function RemoveButton(p)
	if p.Gui then
		p.Gui:Destroy()
	end
end

function ReplaceButtons() end

local v29 = {}

function UpdatePrompts()
	if v29.E then
		Client.PromptHandler.HideAllPrompts()
	else
		Client.PromptHandler.ShowAllPrompts()
	end
end

function GuiButtonHandler.ShowButton(name, p2, p3)
	local priority = p2 or v13[name] or 1
	local v31 = p3 or v10[name]

	if v22 == "Controller" then
		v31 = v11[name]
	end

	debug.profilebegin("GetButtonInfo")
	local buttonInfo = getButtonInfo(name)
	debug.profileend()

	if not buttonInfo then
		v29[v31] = name
		table.insert(GuiButtonHandler.ActiveButtons, {
			Name = name,
			Priority = priority,
			Key = v31
		})
		debug.profilebegin("CreateButton")
		CreateButton(name, priority, v31)
		debug.profileend()
		sortMobileButtons()
		debug.profilebegin("UpdatePrompts")
		UpdatePrompts()
		debug.profileend()
	end
end

function GuiButtonHandler.HideButton(p)
	debug.profilebegin("HideButtons")

	if #GuiButtonHandler.ActiveButtons > 0 then
		for i = #GuiButtonHandler.ActiveButtons, 1, -1 do
			if GuiButtonHandler.ActiveButtons[i].Name ~= p then
				continue
			end

			local activeButton = GuiButtonHandler.ActiveButtons[i]
			RemoveButton(activeButton)

			if v29[activeButton.Key] == activeButton.Name then
				v29[activeButton.Key] = nil
			end

			table.remove(GuiButtonHandler.ActiveButtons, i)
			sortMobileButtons()
			UpdatePrompts()
		end
	end

	debug.profileend()
end

local imageColor3 = nil
local textColor3 = nil

function ToggleSprint(p)
	if Client.WalkspeedController.GetSprinting() then
		p.TextLabel.Text = "SPRINT"
		p.ImageColor3 = imageColor3
		p.TextLabel.TextColor3 = textColor3
		Client.WalkspeedController.StopSprint()
	else
		p.TextLabel.Text = "STOP SPRINT"
		p.TextLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
		Client.WalkspeedController.StartSprint()
		p.ImageColor3 = Color3.fromRGB(255, 0, 0)
	end
end

local v30 = true

function GuiButtonHandler.Init()
	Client.Interface.Backpack:GetPropertyChangedSignal("AbsoluteSize"):Connect(PlaceBackpackAboveHotbar)
	local v31 = true
	task.spawn(function()
		Client.Interface.TopBarFrame.Visible = true
		local sprintButton = localPlayer:WaitForChild("PlayerGui"):WaitForChild("MobileButtons"):WaitForChild("Frame").SprintButton
		imageColor3 = sprintButton.ImageColor3
		textColor3 = sprintButton.TextLabel.TextColor3
		sprintButton.MouseButton1Down:Connect(function()
			v31 = false
			ToggleSprint(sprintButton)
			task.spawn(function()
				wait(0.6)
				v31 = true
			end)
		end)
		localPlayer:WaitForChild("PlayerGui"):WaitForChild("MobileButtons"):WaitForChild("Frame").ShiftlockButton.MouseButton1Down:Connect(function()
			v30 = false
			Client.WalkspeedController.ToggleShiftLock()
			task.spawn(function()
				wait(0.35)
				v30 = true
			end)
		end)
		localPlayer.PlayerGui.MobileButtons.Frame.Screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateMobileButtonScale)
		Client.Events.MobileButtonLayoutPhoneChanged:Connect(UpdateMobileButtonScale)
		Client.Events.MobileButtonLayoutTabletChanged:Connect(UpdateMobileButtonScale)
		task.spawn(function()
			local touchGui = localPlayer.PlayerGui:WaitForChild("TouchGui", 30)

			if not touchGui then
				return
			end

			local touchControlFrame = touchGui:WaitForChild("TouchControlFrame", 30)

			if not touchControlFrame then
				return
			end

			touchControlFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateMobileButtonScale)
			UpdateMobileButtonScale()
		end)
		v22 = initialGetPlatform()
		ApplyPlatform()
		sortMobileButtons()
		UpdatePrompts()
	end)
end

return GuiButtonHandler