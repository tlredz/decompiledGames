local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local ValleyPanels = require(chickenOrHero.Presentation.ValleyPanels)
local EquipmentHudLayout = require(chickenOrHero.Presentation:WaitForChild("EquipmentHudLayout"))
local ControlGate = require(chickenOrHero.Movement.ControlGate)
local GearCatalog = require(chickenOrHero.Gear.GearCatalog)
local gearEvent = chickenOrHero.Gear:WaitForChild("GearEvent")
local GearPredictionClient = require(chickenOrHero.Gear:WaitForChild("GearPredictionClient"))
local screen = ValleyPanels.screen(localPlayer, "GearControls", 63)
local button = ValleyPanels.button(screen, "Use", "", 0, 0, 226, 88, ValleyPanels.Ink)
button.AnchorPoint = Vector2.new(1, 0.5)
button.Position = UDim2.new(1, -24, 0.58, 0)
button.AutoButtonColor = false
ValleyPanels.stroke(button, ValleyPanels.Gold, 0.25)
local outline = button:FindFirstChild("Outline")
local v = ValleyPanels.make("UIScale", button, "Scale", {})
EquipmentHudLayout.register(button, v, 3)
local v2 = ValleyPanels.make("UIGradient", button, "Gradient", {
	Rotation = 25,
	Color = ColorSequence.new(Color3.fromRGB(49, 65, 73), ValleyPanels.Ink)
})
local parent = ValleyPanels.make("ViewportFrame", button, "Item", {
	Position = UDim2.fromOffset(1, 2),
	Size = UDim2.fromOffset(80, 78),
	BackgroundTransparency = 1,
	Ambient = Color3.fromRGB(210, 210, 210),
	LightColor = Color3.new(1, 1, 1),
	LightDirection = vector.create(-1, -2, -2)
})
local camera = Instance.new("Camera")
camera.Parent = parent
parent.CurrentCamera = camera
local worldModel = Instance.new("WorldModel")
worldModel.Parent = parent
local text = ValleyPanels.text(button, "Title", "", 80, 11, 138, 35, 15, ValleyPanels.Paper)
text.Font = Enum.Font.GothamBold
local text2 = ValleyPanels.text(button, "Hint", "", 81, 48, 137, 18, 11, ValleyPanels.Gold)
text2.Font = Enum.Font.GothamBold
local text3 = ValleyPanels.text(button, "Charges", "", 8, 6, 48, 17, 11, ValleyPanels.Paper)
text3.Font = Enum.Font.GothamBold
text3.TextStrokeTransparency = 0.3
local v4 = ValleyPanels.make("Frame", button, "Track", {
	Position = UDim2.fromOffset(12, 77),
	Size = UDim2.fromOffset(202, 4),
	BorderSizePixel = 0,
	BackgroundColor3 = Color3.fromRGB(48, 65, 76)
})
ValleyPanels.corner(v4, 4)
local v5 = ValleyPanels.make("Frame", v4, "Fill", {
	Size = UDim2.fromScale(1, 1),
	BorderSizePixel = 0,
	BackgroundColor3 = ValleyPanels.Gold
})
ValleyPanels.corner(v5, 4)
local text4 = ValleyPanels.text(screen, "Notice", "", 0, 0, 380, 45, 14, ValleyPanels.Gold)
text4.AnchorPoint = Vector2.new(0.5, 0.5)
text4.Position = UDim2.fromScale(0.5, 0.76)
text4.TextXAlignment = Enum.TextXAlignment.Center
text4.TextStrokeTransparency = 0.4
local v6 = {
	gear = 0
}
v6.gear = {}
local v7 = 0
local v8 = 0
local equippedGear = nil
local total = 0
local connections = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function on(activated, request)
	table.insert(connections, activated:Connect(request))
end

local function active()
	local v9 = GearCatalog.get(v6.equippedGear)
	local loaded

	if v9 then
		if v9.Kind == "Ability" or not ((v6.gear[v6.equippedGear] or 0) > 0) then
			loaded = false
		else
			loaded = v6.loaded

			if loaded then
				if localPlayer:GetAttribute("InMatch") == true and (v6.equippedGear == "RescueKit" and localPlayer:GetAttribute("RunState") == "Caught" and localPlayer.Character and localPlayer.Character:GetAttribute("RescueAvailable") == true or v6.equippedGear ~= "RescueKit" and localPlayer:GetAttribute("RunState") == "Active") and (not v9.UseRole or localPlayer:GetAttribute("GameRole") == v9.UseRole) and (not ControlGate.reason(localPlayer) or v6.equippedGear == "RescueKit" and ControlGate.reason(localPlayer) == "Spectating") then
					loaded = not (chickenOrHero.Game.Session:GetAttribute("GlobalPaused") or chickenOrHero.Game.Session:GetAttribute("MapChanging"))
				else
					loaded = false
				end
			end
		end
	else
		loaded = v9
	end

	return loaded
end

local function pop()
	TweenService:Create(button, TweenInfo.new(0.08), {
		Rotation = -3
	}):Play()
	task.delay(0.08, function()
		if button.Parent then
			TweenService:Create(button, TweenInfo.new(0.22, Enum.EasingStyle.Back), {
				Rotation = 0
			}):Play()
		end
	end)
end

local function request()
	if not active() or os.clock() < v7 or workspace:GetServerTimeNow() < (localPlayer:GetAttribute("GearReadyAt") or 0) then
		return
	end

	v7 = os.clock() + 0.6
	pop()
	GearPredictionClient.request(v6.equippedGear, nil, "Use")
end

local function preview(p)
	worldModel:ClearAllChildren()
	local child = chickenOrHero.Gear.Assets:FindFirstChild(p.Preview or v6.equippedGear)

	if not child then
		return
	end

	local model = Instance.new("Model")
	local clone = child:Clone()

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("LuaSourceContainer") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
		end
	end

	if clone:IsA("BasePart") then
		clone.Anchored = true
	end

	clone.Parent = model
	model.Parent = worldModel
	local boundingBox, v9 = model:GetBoundingBox()
	local v10 = math.max(v9.X, v9.Y, v9.Z) * 1.8
	camera.CFrame = CFrame.lookAt(boundingBox.Position + Vector3.new(v10 * 0.65, v10 * 0.35, v10), boundingBox.Position)
	camera.FieldOfView = 40
end

on(button.Activated, request) -- equivalent call inferred; original call site unknown
table.insert(connections, button.MouseEnter:Connect(function()
	TweenService:Create(v2, TweenInfo.new(0.2), {
		Rotation = 65
	}):Play()
end))
table.insert(connections, button.MouseLeave:Connect(function()
	TweenService:Create(v2, TweenInfo.new(0.2), {
		Rotation = 25
	}):Play()
end))
table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and not UserInputService:GetFocusedTextBox() and (input.KeyCode == Enum.KeyCode.C or input.KeyCode == Enum.KeyCode.ButtonB) then
		request()
	end
end))
table.insert(connections, chickenOrHero.Weapons.ArmoryEvent.OnClientEvent:Connect(function(p, p2)
	if p == "State" and type(p2) == "table" then
		v6 = p2
		v6.gear = v6.gear or {}
	end
end))
table.insert(connections, gearEvent.OnClientEvent:Connect(function(p, text5)
	if p == "Notice" and type(text5) == "string" then
		text4.Text = text5
		v8 = os.clock() + 4
		v7 = 0
	end
end))
local v9 = false
table.insert(connections, RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total < 0.05 then
		return
	end

	total = 0
	local v10 = GearCatalog.get(v6.equippedGear)
	local v11 = localPlayer:GetAttribute("InMatch") ~= true
	local v12 = button
	local visible

	if v10 == nil or v10.Kind == "Ability" or v6.loaded ~= true or localPlayer:GetAttribute("ClientReady") ~= true then
		visible = false
	else
		visible = not ControlGate.reason(localPlayer)

		if not visible then
			if v6.equippedGear == "RescueKit" then
				visible = ControlGate.reason(localPlayer) == "Spectating"
			else
				visible = false
			end
		end
	end

	v12.Visible = visible
	local v14 = math.max(0, (localPlayer:GetAttribute("GearReadyAt") or 0) - workspace:GetServerTimeNow())
	local v15 = active()

	if v15 then
		if v14 == 0 then
			local now = os.clock()
			v15 = v7 <= now
		else
			v15 = false
		end
	end

	button.Active = v15 and true or false

	if v10 then
		if equippedGear ~= v6.equippedGear then
			equippedGear = v6.equippedGear
			preview(v10)
		end

		local v16 = UserInputService.PreferredInput == Enum.PreferredInput.Gamepad and "B" or UserInputService.PreferredInput == Enum.PreferredInput.Touch and "TAP" or "C"
		text.Text = string.upper(v10.Name)
		text3.Text = "×" .. tostring(v6.gear[v6.equippedGear] or 0)
		local v17 = v10.UseRole and v10.UseRole ~= localPlayer:GetAttribute("GameRole")
		text2.Text = v11 and "EQUIPPED · ITEM" or v17 and (v10.UseRole == "Catcher" and "CHASERS" or "RUNNERS") .. " ONLY" or v14 > 0 and string.format(
			"READY IN %.1fs",
			v14
		) or v6.equippedGear == "RescueKit" and v15 and v16 .. "  ·  REVIVE YOURSELF" or v6.equippedGear == "RescueKit" and localPlayer:GetAttribute("RunState") == "Active" and "USE WHEN DOWNED" or v15 and v16 .. "  ·  LET’S GO!" or "NOT READY"
		local accent = v10.Accent or ValleyPanels.Gold
		text2.TextColor3 = accent
		v5.BackgroundColor3 = accent
		outline.Color = accent
		v5.Size = UDim2.fromScale(math.clamp(1 - v14 / (v10.Cooldown or 12), 0, 1), 1)
	end

	if v15 and not v9 and button.Visible then
		pop()
	end

	v9 = v15
	outline.Transparency = v15 and math.sin(os.clock() * 3) * 0.12 + 0.25 or 0.65
	text.TextTransparency = v15 and 0 or 0.3
	parent.ImageTransparency = v15 and 0 or 0.35
	text4.Visible = os.clock() < v8
	EquipmentHudLayout.update(localPlayer.PlayerGui)
end))
script.Destroying:Connect(function()
	for _, connection in connections do
		connection:Disconnect()
	end

	screen:Destroy()
end)
chickenOrHero.Weapons.ArmoryEvent:FireServer("Get")