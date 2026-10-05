local createVector = vector.create
local PingClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local textChannels = nil
local mouse = localPlayer:GetMouse()
local v = 1
local v2 = false
local v3 = nil
local flag = false
local v4 = nil
local pingHighlight = workspace.Highlights.PingHighlight
local pingButton = nil
local position = nil
local v5 = false
local v6 = {}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
PingClient.PingActive = false
local v7 = {
	"rbxassetid://105496397815913",
	"rbxassetid://128931610513277",
	"rbxassetid://123748694890073",
	"rbxassetid://118596655016902",
	"rbxassetid://73863118861384",
	"rbxassetid://114218761852561",
	"rbxassetid://114161560120459"
}
local uDim = UDim2.new(0.87, 0, 0.99, 0)
local v8 = { Enum.KeyCode.Q, Enum.KeyCode.DPadUp }

function SendSystemMessage(p, p2)
	Client.Sound.Play("Ping", {
		Volume = 0.06
	})

	if p2 == "" then
		return
	end

	local v9 = "🔔 " .. p.DisplayName .. ": " .. p2
	textChannels.RBXSystem:DisplaySystemMessage(v9)
end

Client.Events.BroadcastPing:Connect(function(p, p2, p3)
	SendSystemMessage(p, p3)
	CreatePingBillboard(p2)
end)

function CreatePingBillboard(data)
	if not data.Position then
		return
	end

	local position2 = data.Position
	local position3 = localPlayer.Character and localPlayer.Character:GetPivot().Position

	if position3 == nil then
		position3 = workspace.CurrentCamera.CFrame.Position
	end

	if math.abs(position3.Y - position2.Y) > 100 and not data.MapPing then
		return
	end

	if v6[data.Player] then
		for k, v9 in pairs(v6[data.Player]) do
			v9:Destroy()
		end

		v6[data.Player] = nil
	end

	local v9 = {}
	local attachment = Instance.new("Attachment")
	attachment.WorldCFrame = CFrame.new(data.Position)
	attachment.Parent = workspace.Terrain
	table.insert(v9, attachment)
	local clone = game.ReplicatedStorage.Assets.Interface.Pings.Default:Clone()
	clone.Frame.NameLabel.Text = data.Player.DisplayName
	clone.Adornee = attachment
	clone.Parent = localPlayer.PlayerGui
	table.insert(v9, clone)
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	local clone_2 = clone.Frame:Clone()
	clone_2.Parent = frame
	local clone_3 = clone.Radar:Clone()
	clone_3.Parent = frame
	table.insert(v9, frame)
	Client.MapDrawClient.AddPingFrameToMap(frame, data.Position)
	local v10 = Client.CompassClient.AddIconToCompass(
		"Ping" .. data.Player.UserId,
		clone.Frame.ImageLabel.Image,
		position2
	)
	v10.ImageColor3 = clone.Frame.ImageLabel.ImageColor3
	table.insert(v9, v10)
	task.spawn(function()
		local radar = clone.Radar
		local radar2 = frame.Radar
		local v11 = #v7 * 0.08 + 1.75
		local v12 = time()
		local v13 = nil

		while clone.Parent do
			local v14 = math.floor((time() - v12) % v11 / 0.08) + 1
			local v15 = #v7 < v14 and 0 or v14

			if v15 ~= v13 then
				local image = v7[v15] or ""
				radar.Image = image

				if radar2 then
					radar2.Image = image
				end

				v13 = v15
			end

			RunService.RenderStepped:Wait()
		end
	end)
	task.spawn(function()
		local position4 = data.Position

		while clone.Parent do
			local magnitude = math.round((workspace.CurrentCamera.Focus.Position - position4).Magnitude)
			clone.Frame.DistLabel.Text = magnitude .. "m"
			clone.Frame.DistLabel.Visible = true
			frame.Frame.DistLabel.Text = magnitude .. "m"
			frame.Frame.DistLabel.Visible = true
			task.wait()
		end
	end)
	task.delay(12, function()
		if v6[data.Player] == v9 then
			for k, v11 in pairs(v9) do
				v11:Destroy()
			end

			v6[data.Player] = nil
		end
	end)
	v6[data.Player] = v9
	v += 1
	local v11 = "PingUpdate" .. v
	RunService:BindToRenderStep(v11, Enum.RenderPriority.Last.Value, function(p)
		if attachment.Parent == nil then
			RunService:UnbindFromRenderStep(v11)
			return
		end

		local worldToScreenPoint, v12 = workspace.CurrentCamera:WorldToScreenPoint(position2)
		local magnitude = (position2 - workspace.CurrentCamera.CFrame.Position).Magnitude
		local viewportSize = workspace.CurrentCamera.ViewportSize
		local X = worldToScreenPoint.X

		if not v12 then
			local unit = (workspace.CurrentCamera.CFrame.LookVector * createVector(1, 0, 1)).Unit
			local unit2 = ((position2 - workspace.CurrentCamera.CFrame.Position) * createVector(1, 0, 1)).Unit
			local angleBetweenVectors, v13 = Client.Utility.GetAngleBetweenVectors(unit, unit2)
			X = v13 > 0 and -500 or viewportSize.X + 500
		end

		local v13 = viewportSize.X * 0.04
		local v14 = viewportSize.Y * 0.1
		local v15 = viewportSize.Y * 0.1
		local v16 = math.clamp(X, v13, viewportSize.X - v13)
		local v17 = math.clamp(worldToScreenPoint.Y, v14, viewportSize.Y - v14)

		if not v12 then
			v17 = math.clamp(worldToScreenPoint.Y, v15, viewportSize.Y - v15)
		end

		local screenPointToRay = workspace.CurrentCamera:ScreenPointToRay(v16, v17)
		local v18 = screenPointToRay.Origin + screenPointToRay.Direction * magnitude
		attachment.WorldCFrame = CFrame.new(v18)
	end)
end

RecentPings = 0

function PingClient:Ping()
	if RecentPings >= 4 then
		textChannels.RBXSystem:DisplaySystemMessage("<i>Please wait before sending more pings</i>")
	else
		RecentPings += 1
		task.delay(15, function()
			RecentPings -= 1
		end)

		if time() - 0 > 1 then
			task.spawn(function()
				self.Player = localPlayer
				local pingMessage, v9 = Client.PingUtil.GetPingMessage(self, localPlayer)

				if pingMessage then
					Client.Events.RequestBroadcastPing:FireServer(self)
					SendSystemMessage(localPlayer, pingMessage)
					CreatePingBillboard(self)
				else
					warn("NO PING MESSAGE EXISTS:", v9)
					warn(self)
				end
			end)
		end
	end

	DeactivatePingMode()
end

function GetMapIconAtPosition(p)
	local guiObjectsAtPosition = localPlayer.PlayerGui:GetGuiObjectsAtPosition(p.X, p.Y)

	for k, v9 in pairs(guiObjectsAtPosition) do
		if v9.Visible and v9:GetAttribute("StructureName") then
			return v9
		end
	end
end

function GetMapIconDisplayName(value)
	if value == "LargeStructure" then
		return "Structure"
	end

	if value == "HardModeCrate" or string.find(value, "Chest") then
		return "Chest"
	end

	return value
end

function BuildMapPingData(p, p2, p3)
	local map = workspace:FindFirstChild("Map")
	local iconName = nil
	local v10, v11

	if p3 then
		local v12 = GetMapIconAtPosition(p3)
		local structureName = v12 and v12:GetAttribute("StructureName")
		local v13 = structureName and GetMapIconDisplayName(structureName)

		if v13 then
			v10, v11 = Client.MapDrawClient.ScaleToWorld(v12.Position.X.Scale, v12.Position.Y.Scale)
			iconName = v13
		else
			v11 = p2
			v10 = p
		end
	else
		v11 = p2
		v10 = p
	end

	local landmarks = map and map:FindFirstChild("Landmarks")

	if landmarks and iconName ~= "Chest" and iconName ~= "Structure" then
		local raycastParams2 = RaycastParams.new()
		raycastParams2.FilterType = Enum.RaycastFilterType.Include
		raycastParams2.FilterDescendantsInstances = { landmarks }
		local raycastResult = workspace:Raycast(Vector3.new(v10, 5000, v11), createVector(0, -10000, 0), raycastParams2)
		local model = raycastResult and GetPingModelFromPart(raycastResult.Instance)

		if model then
			local v13 = {
				Position = Vector3.new(p, raycastResult.Position.Y, p2),
				Model = model,
				MapPing = true
			}

			if Client.PingUtil.GetPingMessage(v13, localPlayer) then
				return v13
			end
		end
	end

	local Y = nil
	local ground = map and map:FindFirstChild("Ground")

	if ground then
		local raycastParams2 = RaycastParams.new()
		raycastParams2.FilterType = Enum.RaycastFilterType.Include
		raycastParams2.FilterDescendantsInstances = { ground }
		local raycastResult = workspace:Raycast(Vector3.new(p, 5000, p2), createVector(0, -10000, 0), raycastParams2)

		if raycastResult then
			Y = raycastResult.Position.Y
		end
	end

	if not Y then
		local campground = map and map:FindFirstChild("Campground")
		local mainFire = campground and campground:FindFirstChild("MainFire")
		Y = mainFire and mainFire:GetPivot().Position.Y or 0
	end

	if iconName then
		return {
			Position = Vector3.new(p, Y, p2),
			PingTree = "MapIcon",
			IconName = iconName,
			MapPing = true
		}
	end

	return {
		Position = Vector3.new(p, Y, p2),
		PingTree = "Ground",
		MapPing = true
	}
end

function StartHoldMouse(p)
	if not PingClient.PingActive then
		return
	end

	local v9 = nil

	if p and Client.MapDrawClient.IsSurfaceMapOpen() then
		local mapPixelToWorld, v10 = Client.MapDrawClient.MapPixelToWorld(p)

		if mapPixelToWorld then
			v9 = BuildMapPingData(mapPixelToWorld, v10, p)
		end
	else
		v9 = GetPingData()
	end

	v3 = v9
	v2 = true

	if v9 then
		task.wait(1)

		if v9 ~= v3 then
			return
		end

		print("open ping menu")
	end
end

PingClient.StartHoldMouse = StartHoldMouse

function EndHoldMouse()
	if not PingClient.PingActive then
		return
	end

	v2 = false

	if v3 then
		local v9 = v3
		v3 = nil
		PingClient.Ping(v9)
	end
end

PingClient.EndHoldMouse = EndHoldMouse

function LoadConnections()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonR2 then
			StartHoldMouse(input.Position)
		end
	end)
	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonR2 then
			EndHoldMouse()
		end
	end)
	UserInputService.TouchStarted:Connect(function(p, p2)
		StartHoldMouse(p.Position)
	end)
	UserInputService.TouchEnded:Connect(function(otherPart, p)
		EndHoldMouse()
	end)
	ContextActionService:BindActionAtPriority("ClickToPing", function(p, p2)
		if PingClient.PingActive then
			return Enum.ContextActionResult.Sink
		end

		return Enum.ContextActionResult.Pass
	end, false, Enum.ContextActionPriority.High.Value + 12, Enum.UserInputType.MouseButton1)
	ContextActionService:BindActionAtPriority("TogglePing", function(p, p2)
		if p2 ~= Enum.UserInputState.Begin then
			return
		end

		TogglePingMode()
		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value, unpack(v8))
end

function PingClient.HighlightFocusModel(p)
	local v9 = GetPingData(p)
	local model = v9 and v9.Model

	if v9 and v9.Interface then
		model = nil
	end

	if model then
		local pingMessage, v10 = Client.PingUtil.GetPingMessage(v9, localPlayer)

		if v10 == "Landmark" or v10 == "Trap" then
			model = nil
		end
	end

	if model then
		pingHighlight.Adornee = model
	else
		pingHighlight.Adornee = nil
	end
end

function GetHoveredButton()
	local guiObjectsAtPosition = localPlayer.PlayerGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y)

	for k, v9 in pairs(guiObjectsAtPosition) do
		if v9.Visible and v9:GetAttribute("PingId") then
			return v9
		end
	end
end

local v9 = {
	RifleAmmo = true,
	RevolverAmmo = true,
	ShotgunAmmo = true
}

function GetPingDataForInterface(instance)
	local pingId = instance:GetAttribute("PingId")
	local v10 = {
		PingTree = "Interface:" .. pingId,
		Interface = true
	}

	if pingId == "HotbarButton" then
		local v11 = string.sub(instance.Name, 7)
		local storedItem = Client.InventoryUI.GetStoredItem(v11)

		if storedItem then
			v10.HotbarItem = storedItem
		end

		local child = localPlayer:FindFirstChild("Inventory") and localPlayer.Inventory:FindFirstChild(v11)

		if child and child:HasTag("ItemBag") and not child:GetAttribute("EasterBasket") then
			local itemBag = localPlayer:FindFirstChild("ItemBag")
			v10.BagLabel = (itemBag and #itemBag:GetChildren() or 0) .. "/" .. Client.Utility.GetItemBagSpace(
				child,
				localPlayer
			)
		end
	end

	if pingId == "CraftingButton" then
		local name = instance.Parent.Name
		v10.RecipeFolder = game.ReplicatedStorage["Crafting Table"]:FindFirstChild(name)
		local craftingBench = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Campground") and workspace.Map.Campground:FindFirstChild("CraftingBench")

		if craftingBench then
			v10.Model = craftingBench
			v10.Position = craftingBench:GetPivot().Position
		end
	end

	if pingId == "BeekeeperButton" then
		v10.ShopItem = game.ReplicatedStorage.Shops.Beekeeper:FindFirstChild(instance.Name)
		local beekeeper = CollectionService:GetTagged("BeekeeperHouse")[1]
		local functional = beekeeper and beekeeper:FindFirstChild("Functional")

		if functional then
			beekeeper = functional:FindFirstChild("Beekeeper") or beekeeper
		end

		if beekeeper then
			v10.Model = beekeeper
			v10.Position = beekeeper:GetPivot().Position
		end
	end

	if pingId == "FairyButton" then
		local v11

		if instance.Name == "CraftButton" then
			v11 = instance.Parent
		else
			v11 = instance
		end

		v10.ShopItem = game.ReplicatedStorage.Shops.Fairy:FindFirstChild(v11.Name)
		local model = Client.FairyClient.GetFairy() or CollectionService:GetTagged("Fairy House")[1]

		if model then
			v10.Model = model
			v10.Position = model:GetPivot().Position
		end
	end

	if pingId == "Ammo" then
		local toolEquipped = Client.InventoryHandler.ToolEquipped()
		local tool = toolEquipped and toolEquipped.Tool

		if tool then
			v10.Reloading = tool.Reloading
			local ammo

			if tool.MagazineSize then
				ammo = tool.Ammo .. "/" .. tool.MagazineSize
			else
				ammo = tool.Ammo
			end

			if tool.AmmoType then
				local ammoType = tool.AmmoType or "RifleAmmo"
				local attribute = localPlayer:GetAttribute(ammoType)
				local v11 = attribute == nil and v9[ammoType] and 0 or attribute

				if v11 then
					ammo ..= " (" .. v11 .. ")"
				end
			end

			v10.AmmoLabel = ammo
			v10.WeaponName = toolEquipped and toolEquipped.Model and toolEquipped.Model.Name
		end
	end

	if pingId == "ToolSmithButton" then
		local parent

		if instance.Name == "CraftButton" then
			parent = instance.Parent
		else
			parent = instance
		end

		v10.ShopItemName = parent.Name
		v10.Purchased = parent.PurchasedLabel.Visible
		local model = CollectionService:GetTagged("ToolSmith")[1]

		if model then
			v10.Model = model
			v10.Position = model:GetPivot().Position
		end
	end

	local model2 = pingId == "WorkshopRecipe" and CollectionService:GetTagged("ToolWorkshop")[1]

	if model2 then
		local recipes = model2:FindFirstChild("Recipes")
		v10.RecipeFolder = recipes and recipes:FindFirstChild(instance.Name)
		v10.Model = model2
		v10.Position = model2:GetPivot().Position
	end

	if pingId == "CraftingMaterial" then
		local v12 = string.gsub(instance.Name, "Amount$", "")
		v10.Material = string.gsub(v12, "Image$", "")
	end

	if pingId == "CraftingPreview" or pingId == "CraftingIngredient" or pingId == "CraftingCraftButton" then
		local previewFrame = Client.Interface.CraftingTable.PreviewFrame
		v10.RecipeFolder = game.ReplicatedStorage["Crafting Table"]:FindFirstChild(previewFrame.TitleFrame.TextLabel.Text)

		if pingId == "CraftingIngredient" then
			v10.Material = string.gsub(instance.Name, "Frame$", "")
		end

		local craftingBench = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Campground") and workspace.Map.Campground:FindFirstChild("CraftingBench")

		if craftingBench then
			v10.Model = craftingBench
			v10.Position = craftingBench:GetPivot().Position
		end
	end

	if pingId == "CraftingBenchTitle" then
		v10.BenchNumber = string.match(instance.TextLabel.Text, "%d+")
	end

	return v10
end

local v10 = {
	Head = "Head",
	UpperTorso = "Torso",
	LowerTorso = "Torso",
	LeftFoot = "Foot",
	RightFoot = "Foot",
	LeftLowerLeg = "Foot",
	RightLowerLeg = "Foot"
}

function GetOwnArmourPing(p, p2)
	local character = localPlayer.Character

	if character == nil then
		return
	end

	local raycastParams2 = RaycastParams.new()
	raycastParams2.FilterType = Enum.RaycastFilterType.Include
	raycastParams2.FilterDescendantsInstances = { character }
	local raycastResult = workspace:Raycast(p.Origin, p.Direction * 100, raycastParams2)

	if raycastResult == nil then
		return
	end

	local magnitude = (raycastResult.Position - p.Origin).Magnitude

	if magnitude < 2 then
		return
	end

	if p2 and (p2.Position - p.Origin).Magnitude < magnitude then
		return
	else
		return {
			Position = raycastResult.Position,
			Model = character,
			PingTree = "OwnArmour",
			ArmourSlot = v10[raycastResult.Instance.Name]
		}
	end
end

function GetPingData(p)
	local v11 = GetHoveredButton()
	local v12 = nil
	local v13

	if v11 then
		v13 = GetPingDataForInterface(v11)
	else
		local v14 = p or mouse.UnitRay
		local raycastResult = workspace:Raycast(
			v14.Origin,
			v14.Direction * 100,
			Client.CollisionUtility.InteractionParams
		)
		raycastParams.FilterDescendantsInstances = CollectionService:GetTagged("PingZone")
		local raycastResult2 = workspace:Raycast(v14.Origin, v14.Direction * 100, raycastParams)

		if raycastResult2 and (raycastResult == nil or raycastResult2.Distance < raycastResult.Distance) then
			raycastResult = raycastResult2
		end

		if raycastResult then
			local model = GetPingModelFromPart(raycastResult.Instance)
			v12 = {
				Position = raycastResult.Position,
				Model = model
			}
		end

		v13 = GetOwnArmourPing(v14, raycastResult) or v12
	end

	local v14

	if v13 and v13.Model then
		local v15
		v15, v14 = Client.PingUtil.GetPingMessage(v13, localPlayer)
		_ = v15
	end

	if v14 == "Landmark" or not (v13 and v13.Model) then
		return v13
	end

	local v15 = v13.Model:GetPivot() + createVector(0, 2, 0)

	if v13.Model:GetAttribute("PingOffset") then
		v15 *= v13.Model:GetAttribute("PingOffset")
	end

	v13.Position = v15.Position
	return v13
end

function GetPingModelFromPart(p)
	local parent = p.Parent

	while parent ~= workspace do
		local pingTree = Client.PingUtil.GetPingTree(parent)

		if pingTree and pingTree ~= "Ground" then
			return parent
		else
			parent = parent.Parent
		end
	end
end

function BuildPingGrid()
	local frame = Instance.new("Frame")
	frame.Name = "Grid"
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.Size = UDim2.fromScale(3, 1)
	frame.SizeConstraint = Enum.SizeConstraint.RelativeYY
	frame.BackgroundTransparency = 1
	frame.Parent = Client.Interface.PingMode

	local function addLine(position2, size)
		local frame2 = Instance.new("Frame")
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		frame2.Position = position2
		frame2.Size = size
		frame2.BackgroundColor3 = Color3.new(1, 1, 1)
		frame2.BackgroundTransparency = 1
		frame2.BorderSizePixel = 0
		frame2.Parent = frame
	end

	for i = -12, 12 do
		addLine(UDim2.fromScale(i / 24 + 0.5, 0.5), UDim2.new(0, 4, 1, 0))
	end

	for i = 1, 7 do
		addLine(UDim2.fromScale(0.5, i / 8), UDim2.new(1, 0, 0, 4))
	end

	return frame
end

function FlashScreenBorder()
	local function setAllTransparency(children, backgroundTransparency)
		for k, item in children do
			item.BackgroundTransparency = backgroundTransparency
			TweenService:Create(item, TweenInfo.new(0.0001), {
				BackgroundTransparency = backgroundTransparency
			}):Play()
		end
	end

	local function tweenAllTransparency(children, backgroundTransparency, duration)
		local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

		for k, item in children do
			TweenService:Create(item, tweenInfo, {
				BackgroundTransparency = backgroundTransparency
			}):Play()
		end

		task.wait(duration)
	end

	local children = Client.Interface.PingMode:GetChildren()

	if flag then
		return
	end

	flag = true
	task.spawn(function()
		while PingClient.PingActive do
			tweenAllTransparency(children, 0.5, 0.3)

			for i = 1, 3 do
				if not PingClient.PingActive then
					break
				end

				tweenAllTransparency(children, 0.75, 0.15)

				if not PingClient.PingActive then
					break
				end

				tweenAllTransparency(children, 0.5, 0.15)
			end

			if not PingClient.PingActive then
				continue
			end

			tweenAllTransparency(children, 1, 0.3)
			task.wait(0.2)
		end

		flag = false
		setAllTransparency(children, 1)
		task.spawn(function()
			wait(1)

			if not PingClient.PingActive then
				setAllTransparency(children, 1)
			end
		end)
	end)
end

function GetPlatform()
	local lastInputType = UserInputService:GetLastInputType()

	if lastInputType.Value >= Enum.UserInputType.Gamepad1.Value and lastInputType.Value <= Enum.UserInputType.Gamepad8.Value then
		return "Console"
	end

	return "PC"
end

function PositionPingButtons()
	local pingButtons = Client.Interface.PingButtons

	if position == nil then
		position = pingButtons.Position
	end

	if Client.MapDrawClient.IsSurfaceMapOpen() then
		pingButtons.Position = uDim
	else
		pingButtons.Position = position
	end
end

function DisplayPingInterface()
	mouse.Icon = "rbxassetid://111937535246479"

	if GetPlatform() == "Console" then
		Client.Interface.PingButtons.TextLabel1.Text = "🔔 R2 to ping"
	else
		Client.Interface.PingButtons.TextLabel1.Text = "🔔 tap to ping"
	end

	PositionPingButtons()
	Client.Interface.PingButtons.Visible = true
	v4 = v4 or BuildPingGrid()
	v4.Visible = true
end

function HidePingInterface()
	Client.Interface.PingButtons.Visible = false

	if v4 then
		v4.Visible = false
	end

	mouse.Icon = ""
end

function ActivatePingMode()
	PingClient.PingActive = true
	v5 = true
	Client.GuiButtonHandler.HideButton("Ping")
	DisplayPingInterface()
end

function DeactivatePingMode()
	PingClient.PingActive = false
	HidePingInterface()
	v3 = nil
	pingHighlight.Adornee = nil
end

function TogglePingMode()
	if PingClient.PingActive then
		DeactivatePingMode()
	else
		ActivatePingMode()
	end
end

function InitializeButtons()
	Client.Interface.PingButtons.CloseButton.Activated:Connect(function()
		if not PingClient.PingActive then
			return
		end

		DeactivatePingMode()
	end)
	task.spawn(function()
		pingButton = localPlayer:WaitForChild("PlayerGui"):WaitForChild("MobileButtons"):WaitForChild("Frame"):WaitForChild("PingButton")
		pingButton.MouseButton1Click:Connect(function()
			TogglePingMode()
		end)
	end)
end

function PingClient.Init()
	task.spawn(function()
		textChannels = TextChatService:WaitForChild("TextChannels", 1e999)
		InitializeButtons()
		task.spawn(function()
			Client.UtilityAlec.preload(v7)
		end)
	end)
	LoadConnections()
end

return PingClient