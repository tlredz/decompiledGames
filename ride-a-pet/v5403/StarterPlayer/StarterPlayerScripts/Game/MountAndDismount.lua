local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadUI = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadUI"))
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local actionsHolder = localPlayer.PlayerGui:WaitForChild("Main"):WaitForChild("ActionsHolder")
local ride = actionsHolder:WaitForChild("Ride")
local dismount = actionsHolder:WaitForChild("Dismount")
local feed = actionsHolder:WaitForChild("Feed")
local useRadar = actionsHolder:WaitForChild("UseRadar")
local GamepadGlyphs = require(ReplicatedStorage2:WaitForChild("GameServices"):WaitForChild("GamepadGlyphs"))
local PetRigService = require(ReplicatedStorage2:WaitForChild("GameServices"):WaitForChild("PetRigService"))

-- equivalent calls inferred from this helper; original call sites unknown
local function WarmHeldPet(tool)
	if tool:IsA("Tool") and CollectionService:HasTag(tool, "Pet") then
		PetRigService.WarmAnimations(tool:GetAttribute("PetName"))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function WatchCharacter(character)
	character.ChildAdded:Connect(WarmHeldPet)

	for _, child in character:GetChildren() do
		WarmHeldPet(child) -- equivalent call inferred; original call site unknown
	end
end

localPlayer.CharacterAdded:Connect(WatchCharacter)

if localPlayer.Character then
	WatchCharacter(localPlayer.Character) -- equivalent call inferred; original call site unknown
end

local click = game.SoundService:WaitForChild("SFX"):WaitForChild("Click")
local game2 = ReplicatedStorage2:WaitForChild("Remotes"):WaitForChild("Game")
local mounting = game2:WaitForChild("Mounting")
local petDismount = game2:WaitForChild("PetDismount")
local feedPet = game2:WaitForChild("FeedPet")
local Foods = require(ReplicatedStorage2:WaitForChild("GameData"):WaitForChild("Foods"))

local function GetEquippedToolWithTag(tag)
	local character = localPlayer.Character

	if not character then
		return nil
	end

	for _, tool in character:GetChildren() do
		if tool:IsA("Tool") and CollectionService:HasTag(tool, tag) then
			return tool
		end
	end

	return nil
end

local function GetEquippedPet()
	return (GetEquippedToolWithTag("Pet"))
end

local function GetEquippedFood()
	local equippedToolWithTag = GetEquippedToolWithTag("Food")

	if not (equippedToolWithTag and Foods[equippedToolWithTag.Name] and equippedToolWithTag) then
		return nil
	end

	return equippedToolWithTag
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetRiddenPetKey()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local petMountJoint = humanoidRootPart and humanoidRootPart:FindFirstChild("PetMountJoint")
	local parent = petMountJoint and petMountJoint.Part1 and petMountJoint.Part1.Parent
	return parent and parent:GetAttribute("PetKey") or nil
end

local function UpdateButtons()
	local isRiding = localPlayer:GetAttribute("IsRiding") == true
	local isPassenger = localPlayer:GetAttribute("IsPassenger") == true
	local visible = useRadar.Visible
	local v = GetEquippedToolWithTag("Pet") ~= nil
	local button = dismount
	local visible2

	if isRiding and not v or isPassenger then
		visible2 = not visible
	else
		visible2 = isPassenger
	end

	button.Visible = visible2
	ride.Visible = v and not visible and not isPassenger
	local button2 = feed

	if isRiding then
		local equippedToolWithTag = GetEquippedToolWithTag("Food")

		if not (equippedToolWithTag and Foods[equippedToolWithTag.Name] and equippedToolWithTag) then
			equippedToolWithTag = nil
		end

		isRiding = equippedToolWithTag ~= nil
	end

	button2.Visible = isRiding
end

localPlayer:GetAttributeChangedSignal("IsRiding"):Connect(UpdateButtons)
localPlayer:GetAttributeChangedSignal("IsPassenger"):Connect(UpdateButtons)
useRadar:GetPropertyChangedSignal("Visible"):Connect(UpdateButtons)

local function WatchCharacter2(character)
	character.ChildAdded:Connect(function(tool)
		if tool:IsA("Tool") then
			task.defer(UpdateButtons)
		end
	end)
	character.ChildRemoved:Connect(function(tool)
		if tool:IsA("Tool") then
			task.defer(UpdateButtons)
		end
	end)
	UpdateButtons()
end

localPlayer.CharacterAdded:Connect(WatchCharacter2)

if localPlayer.Character then
	WatchCharacter2(localPlayer.Character)
end

local function TryMount()
	if localPlayer:GetAttribute("IsPassenger") == true then
		return
	end

	if GetEquippedToolWithTag("Pet") then
		click:Play()
		mounting:FireServer()
	end
end

ride.Activated:Connect(TryMount)
ContextActionService:BindAction("PetMount", function(_, p)
	if GamepadUI.GameplayBlocked() then
		return Enum.ContextActionResult.Pass
	end

	if p == Enum.UserInputState.Begin and localPlayer:GetAttribute("IsPassenger") ~= true and GetEquippedToolWithTag("Pet") then
		click:Play()
		mounting:FireServer()
	end

	return Enum.ContextActionResult.Pass
end, false, Enum.KeyCode.ButtonY)
ContextActionService:BindAction("PetFeed", function(_, p)
	if GamepadUI.GameplayBlocked() or (p ~= Enum.UserInputState.Begin or not feed.Visible) then
		return Enum.ContextActionResult.Pass
	end

	local equippedToolWithTag = GetEquippedToolWithTag("Food")

	if not (equippedToolWithTag and Foods[equippedToolWithTag.Name] and equippedToolWithTag) then
		equippedToolWithTag = nil
	end

	local riddenPetKey = GetRiddenPetKey() -- equivalent call inferred; original call site unknown

	if equippedToolWithTag and riddenPetKey then
		click:Play()
		feedPet:FireServer(riddenPetKey, equippedToolWithTag.Name, true)
	end

	return Enum.ContextActionResult.Pass
end, false, Enum.KeyCode.ButtonX)
dismount.Activated:Connect(function()
	click:Play()
	petDismount:FireServer()
end)
local createBadge = GamepadGlyphs.CreateBadge
local v = {
	{
		Button = ride,
		Key = Enum.KeyCode.ButtonY,
		Name = "PetMount"
	},
	{
		Button = dismount,
		Key = Enum.KeyCode.ButtonB,
		Name = "PetDismountHUD"
	},
	{
		Button = feed,
		Key = Enum.KeyCode.ButtonX,
		Name = "PetFeed"
	},
	{
		Button = useRadar,
		Key = Enum.KeyCode.ButtonY,
		Name = "UseRadarAction"
	}
}

local function RefreshBadges()
	local gamepadEnabled = UserInputService.GamepadEnabled

	for _, v2 in v do
		local gamepadBadge = v2.Button:FindFirstChild("GamepadBadge")

		if gamepadEnabled and not gamepadBadge then
			createBadge(v2.Button, v2.Key)
		elseif not gamepadEnabled and gamepadBadge then
			gamepadBadge:Destroy()
		end
	end
end

RefreshBadges()
UserInputService.GamepadConnected:Connect(RefreshBadges)
UserInputService.GamepadDisconnected:Connect(RefreshBadges)
UserInputService.GamepadConnected:Connect(function()
	for _, v2 in v do
		local gamepadBadge = v2.Button:FindFirstChild("GamepadBadge")

		if gamepadBadge then
			gamepadBadge:Destroy()
		end
	end

	task.defer(RefreshBadges)
end)
feed.Activated:Connect(function()
	local equippedToolWithTag = GetEquippedToolWithTag("Food")

	if not (equippedToolWithTag and Foods[equippedToolWithTag.Name] and equippedToolWithTag) then
		equippedToolWithTag = nil
	end

	local riddenPetKey = GetRiddenPetKey() -- equivalent call inferred; original call site unknown

	if equippedToolWithTag and riddenPetKey then
		click:Play()
		feedPet:FireServer(riddenPetKey, equippedToolWithTag.Name, true)
	end
end)