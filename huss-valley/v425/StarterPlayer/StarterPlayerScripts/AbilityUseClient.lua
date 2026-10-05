local createVector = vector.create
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

local function dashDirection()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local moveDirection = humanoid and humanoid.MoveDirection or createVector(0, 0, 0)

	if moveDirection.Magnitude > 0.05 then
		return moveDirection.Unit
	end

	local currentCamera = workspace.CurrentCamera
	local lookVector = currentCamera and currentCamera.CFrame.LookVector or createVector(0, 0, 0)
	local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)

	if vector2.Magnitude > 0.01 then
		return vector2.Unit
	end

	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	return humanoidRootPart and humanoidRootPart.CFrame.LookVector or createVector(0, 0, 1)
end

local screen = ValleyPanels.screen(localPlayer, "AbilityControls", 63)
local button = ValleyPanels.button(screen, "Use", "", 0, 0, 226, 88, ValleyPanels.Ink)
button.AnchorPoint = Vector2.new(1, 0.5)
button.Position = UDim2.new(1, -24, 0.58, 0)
button.AutoButtonColor = false
ValleyPanels.stroke(button, ValleyPanels.Gold, 0.25)
local outline = button:FindFirstChild("Outline")
local v = ValleyPanels.make("UIScale", button, "Scale", {})
EquipmentHudLayout.register(button, v, 1)
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
	LightDirection = createVector(-1, -2, -2)
})
local v4 = ValleyPanels.make("ImageLabel", button, "AbilityIcon", {
	Position = parent.Position,
	Size = parent.Size,
	BackgroundTransparency = 1,
	ScaleType = Enum.ScaleType.Fit,
	Visible = false
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
local v5 = ValleyPanels.make("Frame", button, "Track", {
	Position = UDim2.fromOffset(12, 77),
	Size = UDim2.fromOffset(202, 4),
	BorderSizePixel = 0,
	BackgroundColor3 = Color3.fromRGB(48, 65, 76)
})
ValleyPanels.corner(v5, 4)
local v6 = ValleyPanels.make("Frame", v5, "Fill", {
	Size = UDim2.fromScale(1, 1),
	BorderSizePixel = 0,
	BackgroundColor3 = ValleyPanels.Gold
})
ValleyPanels.corner(v6, 4)
local text4 = ValleyPanels.text(screen, "Notice", "", 0, 0, 380, 45, 14, ValleyPanels.Gold)
text4.AnchorPoint = Vector2.new(0.5, 0.5)
text4.Position = UDim2.fromScale(0.5, 0.76)
text4.TextXAlignment = Enum.TextXAlignment.Center
text4.TextStrokeTransparency = 0.4
local v7 = {
	abilities = 0
}
v7.abilities = {}
local v8 = 0
local v9 = 0
local v10 = nil
local total = 0
local connections = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function on(activated, request)
	table.insert(connections, activated:Connect(request))
end

local function active()
	local v11 = GearCatalog.get(GearCatalog.equippedForRole(v7, localPlayer:GetAttribute("GameRole")))
	local loaded

	if v11 then
		if v11.Kind == "Ability" and v7.abilities[GearCatalog.equippedForRole(v7, localPlayer:GetAttribute("GameRole"))] == true then
			loaded = v7.loaded

			if loaded then
				if localPlayer:GetAttribute("InMatch") == true and localPlayer:GetAttribute("RunState") == "Active" and (not v11.UseRole or localPlayer:GetAttribute("GameRole") == v11.UseRole) then
					loaded = not (ControlGate.reason(localPlayer) or chickenOrHero.Game.Session:GetAttribute("GlobalPaused") or chickenOrHero.Game.Session:GetAttribute("MapChanging"))
				else
					loaded = false
				end
			end
		else
			loaded = false
		end
	else
		loaded = v11
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
	if not active() or os.clock() < v8 or workspace:GetServerTimeNow() < (localPlayer:GetAttribute("AbilityReadyAt") or 0) then
		return
	end

	v8 = os.clock() + 0.6
	pop()
	GearPredictionClient.request(
		GearCatalog.equippedForRole(v7, localPlayer:GetAttribute("GameRole")),
		dashDirection(),
		"UseAbility"
	)
end

local function preview(data)
	worldModel:ClearAllChildren()
	v4.Visible = data.IconImage ~= nil
	parent.Visible = not v4.Visible
	v4.Image = data.IconImage or ""
	v4.ImageRectOffset = data.IconRectOffset or Vector2.zero
	v4.ImageRectSize = data.IconRectSize or Vector2.zero

	if v4.Visible then
		return
	end

	local child = chickenOrHero.Gear.Assets:FindFirstChild(data.Preview or GearCatalog.equippedForRole(
		v7,
		localPlayer:GetAttribute("GameRole")
	))

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
	local boundingBox, v11 = model:GetBoundingBox()
	local v12 = math.max(v11.X, v11.Y, v11.Z) * 1.8
	camera.CFrame = CFrame.lookAt(boundingBox.Position + Vector3.new(v12 * 0.65, v12 * 0.35, v12), boundingBox.Position)
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
	if not gameProcessed and not UserInputService:GetFocusedTextBox() and (input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.ButtonR1) then
		request()
	end
end))
table.insert(connections, chickenOrHero.Weapons.ArmoryEvent.OnClientEvent:Connect(function(p, p2)
	if p == "State" and type(p2) == "table" then
		v7 = p2
		v7.abilities = v7.abilities or {}
	end
end))
table.insert(connections, gearEvent.OnClientEvent:Connect(function(p, value)
	if p == "Notice" and type(value) == "string" then
		text4.Text = ""
		v9 = 0
		v8 = 0
	end
end))
local clone = button:Clone()
clone.Name = "ChaserEquipped"
clone.Visible = false
clone.Active = false
clone.Selectable = false
clone.Parent = screen
EquipmentHudLayout.register(clone, clone.Scale, 2)
local v11 = false
table.insert(connections, RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total < 0.05 then
		return
	end

	total = 0
	local v12 = localPlayer:GetAttribute("InMatch") ~= true
	local v13 = v12 and "Runner" or localPlayer:GetAttribute("GameRole")
	local equippedForRole = GearCatalog.equippedForRole(v7, v13)
	local v14 = GearCatalog.get(equippedForRole)
	local visible

	if v7.loaded == true and localPlayer:GetAttribute("ClientReady") == true then
		visible = not ControlGate.reason(localPlayer)
	else
		visible = false
	end

	local v16 = button
	local visible2

	if visible then
		if v14 == nil then
			visible2 = false
		else
			visible2 = v14.Kind == "Ability"
		end
	else
		visible2 = visible
	end

	v16.Visible = visible2
	local v18 = v12 and GearCatalog.get(GearCatalog.equippedForRole(v7, "Catcher")) or nil
	local v19 = clone

	if visible then
		if v18 == nil then
			visible = false
		else
			visible = v18.Kind == "Ability"
		end
	end

	v19.Visible = visible

	if v18 then
		clone.Title.Text = string.upper(v18.Name)
		clone.Hint.Text = "EQUIPPED · CHASER"
		clone.Hint.TextColor3 = v18.Accent or ValleyPanels.Gold
		clone.Charges.Text = "ABILITY"
		clone.Item.Visible = false
		clone.AbilityIcon.Visible = true
		clone.AbilityIcon.Image = v18.IconImage or ""
		clone.AbilityIcon.ImageRectOffset = v18.IconRectOffset or Vector2.zero
		clone.AbilityIcon.ImageRectSize = v18.IconRectSize or Vector2.zero
		clone.Outline.Color = v18.Accent or ValleyPanels.Gold
		clone.Track.Fill.BackgroundColor3 = v18.Accent or ValleyPanels.Gold
	end

	local v20 = math.max(0, (localPlayer:GetAttribute("AbilityReadyAt") or 0) - workspace:GetServerTimeNow())
	local v21 = active()

	if v21 then
		if v20 == 0 then
			local now = os.clock()
			v21 = v8 <= now
		else
			v21 = false
		end
	end

	button.Active = v21 and true or false

	if v14 then
		if v10 ~= equippedForRole then
			v10 = equippedForRole
			preview(v14)
		end

		local v22 = UserInputService.PreferredInput == Enum.PreferredInput.Gamepad and "R1" or UserInputService.PreferredInput == Enum.PreferredInput.Touch and "TAP" or "Q"
		text.Text = string.upper(v14.Name)
		text3.Text = "ABILITY"
		local v23 = v14.UseRole and v14.UseRole ~= localPlayer:GetAttribute("GameRole")
		text2.Text = v12 and "EQUIPPED · RUNNER" or v23 and (v14.UseRole == "Catcher" and "CHASERS" or "RUNNERS") .. " ONLY" or v20 > 0 and string.format(
			"READY IN %.1fs",
			v20
		) or v21 and v22 .. "  ·  LET’S GO!" or localPlayer:GetAttribute("RunState") == "Caught" and "CAUGHT" or localPlayer:GetAttribute("RunState") == "Active" and "NOT READY" or "WAIT FOR ROUND"
		local accent = v14.Accent or ValleyPanels.Gold
		text2.TextColor3 = accent
		v6.BackgroundColor3 = accent
		outline.Color = accent
		v6.Size = UDim2.fromScale(math.clamp(1 - v20 / (v14.Cooldown or 12), 0, 1), 1)
	end

	if v21 and not v11 and button.Visible then
		pop()
	end

	v11 = v21
	outline.Transparency = v21 and math.sin(os.clock() * 3) * 0.12 + 0.25 or 0.65
	text.TextTransparency = v21 and 0 or 0.3
	parent.ImageTransparency = v21 and 0 or 0.35
	v4.ImageTransparency = v21 and 0 or 0.35
	text4.Visible = os.clock() < v9
	EquipmentHudLayout.update(localPlayer.PlayerGui)
end))
script.Destroying:Connect(function()
	for _, connection in connections do
		connection:Disconnect()
	end

	screen:Destroy()
end)
chickenOrHero.Weapons.ArmoryEvent:FireServer("Get")