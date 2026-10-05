local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("ProfileData"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local PerkService = require(ReplicatedStorage3:WaitForChild("ClientServices"):WaitForChild("PerkService"))
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage4:WaitForChild("ClientServices"):WaitForChild("WeaponService"))
local ReplicatedStorage5 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage5:WaitForChild("ClientServices"):WaitForChild("DeviceService"))
local ReplicatedStorage6 = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage6:WaitForChild("Remotes")
local parent = script.Parent
local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local gameplayContext = playerGui:WaitForChild("InputContext"):WaitForChild("GameplayContext")
local GameplayButton = require(script:WaitForChild("GameplayButton"))
Vector2.new(50, 90)
Vector2.new(25, 20)
local touchGui = nil
local v = false
local touchControls = parent:WaitForChild("TouchControls")
local rightBar = touchControls:WaitForChild("RightBar")
local bottomBar = touchControls:WaitForChild("BottomBar")
local v2 = parent:WaitForChild("_")
local v3 = nil
local equipWeapon = rightBar:WaitForChild("EquipWeapon")
local throw = rightBar:WaitForChild("Throw")
local perk = bottomBar:WaitForChild("Perk")
local v4 = { equipWeapon, perk, throw }
local v5 = GameplayButton.new(throw)
local v6 = GameplayButton.new(equipWeapon)
local v7 = GameplayButton.new(perk)

local function isWeaponEquipped()
	local character = game.Players.LocalPlayer.Character

	if not character then
		return false
	end

	for _, tool in character:GetChildren() do
		if (tool:HasTag("Weapon_Knife") or tool:HasTag("Weapon_Gun")) and tool:IsA("Tool") then
			return true
		end
	end

	return false
end

local function onWeaponGiven(p: string)
	if p == "Knife" then
		local knife = ProfileData.Weapons.Equipped.Knife
		equipWeapon.ControlIcon.Image = Sync.Weapons[knife].Image
		v5:SetEnabled((isWeaponEquipped()))
		equipWeapon.Visible = true
		throw.Visible = true
		perk.Visible = true
	elseif p == "Gun" then
		local gun = ProfileData.Weapons.Equipped.Gun
		equipWeapon.ControlIcon.Image = Sync.Weapons[gun].Image
		equipWeapon.Visible = true
	else
		for _, v8 in v4 do
			v8.Visible = false
		end
	end

	equipWeapon.Equipped.Visible = isWeaponEquipped()
end

local function equipWeapon2()
	local backpack = game.Players.LocalPlayer.Backpack

	if not backpack then
		return
	end

	local character = game.Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	for _, tool in backpack:GetChildren() do
		if not ((tool:HasTag("Weapon_Knife") or tool:HasTag("Weapon_Gun")) and tool:IsA("Tool")) then
			continue
		end

		humanoid:EquipTool(tool)
		return
	end

	if not isWeaponEquipped() then
		return
	end

	humanoid:UnequipTools()
end

local function onEquipButtonActivated()
	local backpack = game.Players.LocalPlayer.Backpack

	if not backpack then
		return
	end

	local character = game.Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	for _, tool in backpack:GetChildren() do
		if not ((tool:HasTag("Weapon_Knife") or tool:HasTag("Weapon_Gun")) and tool:IsA("Tool")) then
			continue
		end

		humanoid:EquipTool(tool)
		v5:SetEnabled(true)
		equipWeapon.Equipped.Visible = true
		return
	end

	if isWeaponEquipped() then
		v5:SetEnabled(false)
		equipWeapon.Equipped.Visible = false
		humanoid:UnequipTools()
	elseif GuiService:IsTenFootInterface() then
		humanoid:UnequipTools()
	end
end

local function intializeTouchControls()
	v = true
	touchGui = playerGui:WaitForChild("TouchGui")

	if touchGui:WaitForChild("TouchControlFrame"):WaitForChild("JumpButton").Size == UDim2.new(0, 120, 0, 120) then
		local uIScale = bottomBar:WaitForChild("UIScale")
		uIScale.Scale = 1.21
		local uIScale_2 = rightBar:WaitForChild("UIScale")
		uIScale_2.Scale = 1.21
		rightBar.Position = UDim2.new(1, -15, 1, -215, 0)
		bottomBar.Position = UDim2.new(1, -145, 1, -15)
	end

	touchControls.Visible = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onPreferredInputChanged()
	if UserInputService.PreferredInput ~= Enum.PreferredInput.Touch then
		touchControls.Visible = false
		return
	end

	if not v then
		intializeTouchControls()
	end

	PerkService.PerkButton = perk
	perk.Visible = PerkService.PerkIsActive
	touchControls.Visible = true
end

local function onInitialize()
	touchControls.Visible = false
	remotes:WaitForChild("Gameplay"):WaitForChild("GiveWeapon").OnClientEvent:Connect(onWeaponGiven)

	for _, v8 in v4 do
		v8.Visible = false
	end

	if GuiService:IsTenFootInterface() then
		for _, child in script:WaitForChild("EquipAction"):GetChildren() do
			child.Parent = gameplayContext:WaitForChild("EquipWeapon")
		end
	end

	v6.Activated.Event:Connect(onEquipButtonActivated)
	v7.Activated.Event:Connect(function()
		PerkService:ActivatePerk()
	end)
	local touchBinding = gameplayContext:WaitForChild("Throw"):WaitForChild("TouchBinding")
	touchBinding.UIButton = throw
	local backpack = localPlayer.Backpack
	backpack.ChildAdded:Connect(function(child)
		if not child:HasTag("Weapon") then
			return
		end

		v3 = child
		local ancestryChangedConnection = nil
		ancestryChangedConnection = child.AncestryChanged:Connect(function()
			if backpack.Parent == nil then
				ancestryChangedConnection:Disconnect()
				v3 = nil
			elseif child.Parent == localPlayer.Backpack then
				v5:SetEnabled(false)
				equipWeapon.Equipped.Visible = false
			elseif child.Parent == localPlayer.Character then
				v5:SetEnabled(true)
				equipWeapon.Equipped.Visible = true
			else
				ancestryChangedConnection:Disconnect()
				v3 = nil
			end
		end)
	end)

	for _, v8 in v4 do
		v8.Visible = false
	end

	equipWeapon.Equipped.Visible = isWeaponEquipped()
	onPreferredInputChanged() -- equivalent call inferred; original call site unknown
	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(onPreferredInputChanged)
	v2.Visible = false
end

onInitialize()