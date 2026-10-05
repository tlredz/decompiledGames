local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadUI = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadUI"))
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
game:GetService("ContextActionService")
local GamepadAim = require(game.ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadAim"))
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local click = SoundService:WaitForChild("SFX"):FindFirstChild("Click")
local game2 = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")
local pickupPet = game2:WaitForChild("PickupPet")
local placePet = game2:WaitForChild("PlacePet")
local mounting = game2:WaitForChild("Mounting")
game2:WaitForChild("PetDismount")
local feedPet = game2:WaitForChild("FeedPet")
local PetRenderer = require(localPlayer:WaitForChild("PlayerScripts"):WaitForChild("Game"):WaitForChild("Pets"):WaitForChild("PetRenderer"))
local parent = script.Parent
local selectPet = parent:WaitForChild("SelectPet")
local frame = parent:WaitForChild("Frame")
local close = frame:WaitForChild("Close")
local feed = frame:WaitForChild("Feed")
local ride = frame:WaitForChild("Ride")
local view = frame:WaitForChild("View")
local size = frame.Size
local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local tween = TweenService:Create(frame, tweenInfo, {
	Size = size
})
local tween2 = TweenService:Create(frame, tweenInfo, {
	Size = UDim2.new(0, 0, 0, 0)
})
local actions = {}
local textsByAction = {}

for _, child in frame:GetChildren() do
	local action = child:FindFirstChild("Action")

	if not (action and action:IsA("TextLabel")) then
		continue
	end

	table.insert(actions, action)
	textsByAction[action] = action.Text
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearActionText()
	for _, v in actions do
		v.Text = ""
	end
end

local function RestoreActionText()
	for _, v in actions do
		v.Text = textsByAction[v]
	end
end

local v = nil
local ancestryChangedConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function PlayClick()
	if click then
		click:Play()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowMessage(p)
	pcall(function()
		local Handler = require(localPlayer.PlayerGui.Reusable.GameMessages.Handler)
		Handler:AddMessage(p)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RemoveHighlight(instance)
	local child = instance and instance:FindFirstChild(selectPet.Name)

	if child then
		child:Destroy()
	end
end

local function ClosePetManager()
	local v2 = v
	v = nil

	if ancestryChangedConnection then
		ancestryChangedConnection:Disconnect()
		ancestryChangedConnection = nil
	end

	RemoveHighlight(v2) -- equivalent call inferred; original call site unknown
	tween2:Play()
	task.delay(0.1, function()
		if not v then
			parent.Adornee = nil
			parent.Enabled = false
		end
	end)
end

local function OpenPetManager(instance)
	if v == instance then
		return
	end

	if v then
		RemoveHighlight(v) -- equivalent call inferred; original call site unknown

		if ancestryChangedConnection then
			ancestryChangedConnection:Disconnect()
			ancestryChangedConnection = nil
		end
	end

	v = instance
	local primaryPart = instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)

	if not primaryPart then
		v = nil
		return
	end

	if not instance:FindFirstChild(selectPet.Name) then
		local clone = selectPet:Clone()
		clone.Adornee = instance
		clone.Parent = instance
	end

	ancestryChangedConnection = instance.AncestryChanged:Connect(function(_, parent2)
		if not parent2 and v == instance then
			ClosePetManager()
		end
	end)
	parent.Adornee = primaryPart
	frame.Size = UDim2.new(0, 0, 0, 0)
	parent.Enabled = true
	ClearActionText() -- equivalent call inferred; original call site unknown
	tween.Completed:Once(RestoreActionText)
	tween:Play()
	PlayClick() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function OnClose()
	PlayClick() -- equivalent call inferred; original call site unknown
	ClosePetManager()
end

close.Activated:Connect(OnClose)
local v2 = false

local function FindPetTool(p)
	for _, v3 in { localPlayer.Character, localPlayer:FindFirstChildOfClass("Backpack") } do
		if not v3 then
			continue
		end

		for _, tool in v3:GetChildren() do
			if tool:IsA("Tool") and tool:GetAttribute("PetKey") == p then
				return tool
			end
		end
	end

	return nil
end

local function WaitForPetTool(petKey, p)
	local v3 = os.clock() + p

	while true do
		for _, v4 in { localPlayer.Character, localPlayer:FindFirstChildOfClass("Backpack") } do
			if not v4 then
				continue
			end

			for _, tool in v4:GetChildren() do
				if tool:IsA("Tool") and tool:GetAttribute("PetKey") == petKey then
					return tool
				end
			end
		end

		task.wait()

		if v3 < os.clock() then
			return nil
		end
	end
end

local function WaitForRidingState(p, p2)
	local v3 = os.clock() + p2

	while localPlayer:GetAttribute("IsRiding") == true ~= p and os.clock() < v3 do
		task.wait()
	end

	return localPlayer:GetAttribute("IsRiding") == true == p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RiddenPetKey()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local petMountJoint = humanoidRootPart and humanoidRootPart:FindFirstChild("PetMountJoint")
	local parent2 = petMountJoint and petMountJoint.Part1 and petMountJoint.Part1.Parent
	return parent2 and parent2:GetAttribute("PetKey") or nil
end

local function WaitForRidingPet(instance, p)
	local petKey = instance:GetAttribute("PetKey")
	local v3 = os.clock() + p

	while true do
		if localPlayer:GetAttribute("IsRiding") == true and RiddenPetKey() == petKey then
			return true
		end

		task.wait()

		if v3 < os.clock() then
			return false
		end
	end
end

local function RidePet(instance)
	local petKey = instance and instance:GetAttribute("PetKey")
	ClosePetManager()

	if not petKey or v2 then
		return
	end

	if localPlayer:GetAttribute("IsPassenger") == true then
		ShowMessage("Dismount First") -- equivalent call inferred; original call site unknown
	else
		PlayClick() -- equivalent call inferred; original call site unknown
		local position = instance and instance:GetPivot().Position
		local v3

		if localPlayer:GetAttribute("IsRiding") == true then
			v3 = RiddenPetKey()
		else
			v3 = nil
		end

		PetRenderer.Remove(localPlayer.UserId, petKey)
		pickupPet:FireServer(petKey)
		v2 = true
		task.spawn(function()
			if not pcall(function()
				local waitForPetTool = WaitForPetTool(petKey, 5)

				if not waitForPetTool then
					return
				end

				local character = localPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if not humanoid or humanoid.Health <= 0 then
					return
				end

				local v5 = false

				for _ = 1, 5 do
					if waitForPetTool.Parent ~= character then
						humanoid:EquipTool(waitForPetTool)
					end

					mounting:FireServer()

					if not WaitForRidingPet(waitForPetTool, 0.6) then
						continue
					end

					v5 = true
					break
				end

				if not v5 then
					return
				end

				local v6 = v3 and position and FindPetTool(v3)

				if v6 then
					humanoid:EquipTool(v6)
					local v7 = os.clock() + 2

					while v6.Parent ~= character and os.clock() < v7 do
						task.wait()
					end

					if v6.Parent == character then
						placePet:FireServer(v3, position)
						task.delay(0.35, function()
							if humanoid.Parent then
								humanoid:UnequipTools()
							end
						end)
					end
				end
			end) then
				ShowMessage("Couldn't Ride That Pet") -- equivalent call inferred; original call site unknown
			end

			v2 = false
		end)
	end
end

ride.Activated:Connect(function()
	RidePet(v)
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function RefreshMenuRide()
	ride.Visible = localPlayer:GetAttribute("IsPassenger") ~= true
end

localPlayer:GetAttributeChangedSignal("IsPassenger"):Connect(RefreshMenuRide)
RefreshMenuRide() -- equivalent call inferred; original call site unknown
local ride2 = game.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Prompts"):FindFirstChild("Ride")
local PetNameRules = require(game.ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PetNameRules"))
local v3 = {}

local function HoldingNameTag()
	local character = localPlayer.Character
	local tool = character and character:FindFirstChildOfClass("Tool")
	return tool ~= nil and (tool.Name == "NameTag" or tool:HasTag("NameTag"))
end

local function RefreshRidePrompts()
	local isPassenger = localPlayer:GetAttribute("IsPassenger") == true
	local setting_ViewYourPets = localPlayer:GetAttribute("Setting_ViewYourPets") ~= false
	local character = localPlayer.Character
	local tool = character and character:FindFirstChildOfClass("Tool")
	local v4

	if tool == nil then
		v4 = false
	else
		v4 = tool.Name == "NameTag" or tool:HasTag("NameTag")
	end

	local v5 = {}

	for _, v6 in pairs(PetRenderer.GetAll()) do
		if not setting_ViewYourPets or (isPassenger or v4) or v6.OwnerUserId ~= localPlayer.UserId then
			continue
		end

		if not (v6.Model and v6.Model.Parent and v6.Model.PrimaryPart) then
			continue
		end

		v5[v6.PetKey] = true
		local hiddenAnchor = v6.HiddenAnchor or v6.Model.PrimaryPart
		local v7 = v3[v6.PetKey]

		if v7 and v7.Parent then
			if v7.Parent ~= hiddenAnchor then
				v7.Parent = hiddenAnchor
			end
		else
			if ride2 then
				v7 = ride2:Clone()
			else
				v7 = Instance.new("ProximityPrompt")
				v7.HoldDuration = 0.5
				v7.MaxActivationDistance = 12
			end

			v7.Name = "RidePrompt"
			v7.ActionText = "Ride"
			v7.RequiresLineOfSight = false
			v7.Enabled = true
			v7.Parent = hiddenAnchor
			v3[v6.PetKey] = v7
			local model = v6.Model
			v7.Triggered:Connect(function()
				if localPlayer:GetAttribute("Setting_ViewYourPets") == false then
					return
				end

				RidePet(model)
			end)
		end

		if not v7 then
			continue
		end

		local petName = v6.Model:GetAttribute("PetName") or v6.Model.Name
		local display = PetNameRules.Display(PetNameRules.GetNickname(localPlayer, v6.PetKey), petName)

		if v7.ObjectText ~= display then
			v7.ObjectText = display
		end
	end

	for k, v6 in pairs(v3) do
		if v5[k] then
			continue
		end

		v3[k] = nil
		v6:Destroy()
	end
end

if PetRenderer.Added then
	PetRenderer.Added.Event:Connect(RefreshRidePrompts)
end

if PetRenderer.Removed then
	PetRenderer.Removed.Event:Connect(RefreshRidePrompts)
end

localPlayer:GetAttributeChangedSignal("IsPassenger"):Connect(RefreshRidePrompts)
localPlayer:GetAttributeChangedSignal("Setting_ViewYourPets"):Connect(RefreshRidePrompts)

local function HookRideCharacter(character)
	character.ChildAdded:Connect(function()
		task.defer(pcall, RefreshRidePrompts)
	end)
	character.ChildRemoved:Connect(function()
		task.defer(pcall, RefreshRidePrompts)
	end)
end

localPlayer.CharacterAdded:Connect(HookRideCharacter)

if localPlayer.Character then
	HookRideCharacter(localPlayer.Character)
end

task.spawn(function()
	while true do
		pcall(RefreshRidePrompts)
		task.wait(1)
	end
end)

local function OnFeed()
	local petKey = v and v:GetAttribute("PetKey")
	PlayClick() -- equivalent call inferred; original call site unknown

	if not petKey then
		return
	end

	local character = localPlayer.Character
	local tool = character and character:FindFirstChildOfClass("Tool")

	if tool and tool:HasTag("Food") then
		ClosePetManager()
		feedPet:FireServer(petKey, tool.Name)
	else
		ShowMessage("Hold A Food To Feed") -- equivalent call inferred; original call site unknown
	end
end

feed.Activated:Connect(OnFeed)

local function OnView()
	local petKey = v and v:GetAttribute("PetKey")
	OnClose() -- equivalent call inferred; original call site unknown

	if not petKey then
		return
	end

	local main = localPlayer.PlayerGui:FindFirstChild("Main")
	local petsTracker = main and main:FindFirstChild("PetsTracker")

	if not petsTracker then
		return
	end

	local openRequest = petsTracker:FindFirstChild("OpenRequest")

	if openRequest then
		openRequest:Fire()
	end

	local focusPet = petsTracker:FindFirstChild("FocusPet")

	if focusPet then
		focusPet:Fire(petKey)
	end
end

view.Activated:Connect(OnView)
GamepadAim.Register(close, OnClose)
GamepadAim.Register(ride, OnRide)
GamepadAim.Register(feed, OnFeed)
GamepadAim.Register(view, OnView)
GamepadUI.Watch(parent, OnClose, close, -1)

local function GetPetFromTarget(parent2)
	while parent2 and parent2 ~= workspace do
		if parent2:IsA("Model") and parent2:HasTag("Pet") then
			return parent2
		else
			parent2 = parent2.Parent
		end
	end

	return nil
end

local function TryOpenAt()
	local v4 = GetPetFromTarget(mouse.Target)

	if not (v4 and v4:GetAttribute("OwnerUserId") == localPlayer.UserId) then
		return false
	end

	OpenPetManager(v4)
	return true
end

local v4 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function SetAimedPet(instance)
	if v4 == instance then
		return
	end

	local aimPet = v4 and v4:FindFirstChild("AimPet")

	if aimPet then
		aimPet:Destroy()
	end

	v4 = instance

	if instance and instance ~= v and not instance:FindFirstChild("AimPet") then
		local clone = selectPet:Clone()
		clone.Name = "AimPet"
		clone.Adornee = instance
		clone.FillTransparency = math.min(clone.FillTransparency + 0.3, 1)
		clone.OutlineColor = Color3.fromRGB(255, 255, 255)
		clone.Parent = instance
	end
end

local function AimedOwnPet()
	local petFromTarget = GetPetFromTarget(mouse.Target)

	if petFromTarget and petFromTarget:GetAttribute("OwnerUserId") == localPlayer.UserId then
		return petFromTarget
	end

	return nil
end

local function TooFarFromManagedPet()
	local v5 = v

	if not v5 then
		return false
	end

	if not v5.Parent then
		return true
	end

	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return false
	end

	local success, result = pcall(function()
		return v5:GetPivot().Position
	end)

	if success then
		return (result - humanoidRootPart.Position).Magnitude > 200
	end

	return false
end

local total = 0
RunService.RenderStepped:Connect(function(dt)
	total += dt

	if total < 0.05 then
		return
	end

	total = 0

	if TooFarFromManagedPet() then
		ClosePetManager()
	end

	if string.sub(UserInputService:GetLastInputType().Name, 1, 7) == "Gamepad" and not GamepadAim.AimedButton() then
		local petFromTarget = GetPetFromTarget(mouse.Target)

		if not petFromTarget or petFromTarget:GetAttribute("OwnerUserId") ~= localPlayer.UserId then
			petFromTarget = nil
		end

		SetAimedPet(petFromTarget)
		return
	end

	SetAimedPet(nil) -- equivalent call inferred; original call site unknown
end)
GamepadAim.RegisterWorld(function()
	local petFromTarget = GetPetFromTarget(mouse.Target)

	if not petFromTarget or petFromTarget:GetAttribute("OwnerUserId") ~= localPlayer.UserId then
		petFromTarget = nil
	end

	if not petFromTarget then
		return false
	end

	SetAimedPet(nil) -- equivalent call inferred; original call site unknown
	local v6 = GetPetFromTarget(mouse.Target)

	if not (v6 and v6:GetAttribute("OwnerUserId") == localPlayer.UserId) then
		return false
	end

	OpenPetManager(v6)
	return true
end)
local v5 = nil
local now = 0

local function ClickedThroughGui(position)
	local guiObjectsAtPosition = localPlayer.PlayerGui:GetGuiObjectsAtPosition(position.X, position.Y)

	for _, button in ipairs(guiObjectsAtPosition) do
		if button.Active or button:IsA("GuiButton") then
			return true
		end
	end

	return false
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if ClickedThroughGui(input.Position) then
			return
		end

		local v6 = GetPetFromTarget(mouse.Target)

		if not (v6 and v6:GetAttribute("OwnerUserId") == localPlayer.UserId) then
			return
		end

		OpenPetManager(v6)
	elseif input.UserInputType == Enum.UserInputType.Touch and not v5 then
		if ClickedThroughGui(input.Position) then
			return
		end

		v5 = input
		now = os.clock()
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input == v5 then
		v5 = nil

		if os.clock() - now < 0.5 then
			local v6 = GetPetFromTarget(mouse.Target)

			if not (v6 and v6:GetAttribute("OwnerUserId") == localPlayer.UserId) then
				return
			end

			OpenPetManager(v6)
		end
	end
end)