local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local PerkService = require(game.ReplicatedStorage:WaitForChild("ClientServices"):WaitForChild("PerkService"))
local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local now = nil
local cooldown = nil
local activeTime = nil
local charges = nil
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function resetPerks()
	if workspace:FindFirstChild("Footsteps") then
		workspace:FindFirstChild("Footsteps"):Destroy()
	end

	_G.Sleight = false
	_G.Ninja = false
	_G.Haste = false
end

local function onPerkAdded(instance)
	local perkInfo = PerkService:GetPerkInfo(instance.Name)
	local perkButton = PerkService.PerkButton

	while perkButton == nil do
		perkButton = PerkService.PerkButton
		task.wait(0.1)
	end

	perkButton.ControlText.Text = perkInfo.DisplayName
	perkButton.ControlIcon.Image = perkInfo.Image

	if perkButton:FindFirstChild("PassiveLabel") then
		perkButton.PassiveLabel.Visible = perkInfo.Passive == true
	end

	if perkButton:FindFirstChild("UIGradient") then
		perkButton.UIGradient.Enabled = perkInfo.Passive ~= true
	end

	if perkButton:FindFirstChild("Keybind") then
		perkButton.Keybind.Visible = perkInfo.Passive ~= true
	end

	if instance.Name == "FakeGun" and GuiService:IsTenFootInterface() then
		perkButton.Keybind.Visible = true
	end

	perkButton.Charges.Visible = perkInfo.Charges ~= nil
	perkButton.ControlIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
	local ancestryChangedConnection = nil
	ancestryChangedConnection = instance.AncestryChanged:Connect(function()
		if not instance:IsDescendantOf(game) then
			ancestryChangedConnection:Disconnect()
			v = nil
			perkButton.Visible = false
			PerkService.PerkIsActive = false
			resetPerks() -- equivalent call inferred; original call site unknown
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updatePerk()
		activeTime = instance:GetAttribute("ActiveTime")
		cooldown = instance:GetAttribute("Cooldown")
		charges = instance:GetAttribute("Charges")
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateCharges()
		local charges2 = instance:GetAttribute("Charges")

		if not charges2 then
			return
		end

		perkButton.Charges.Text = "(" .. charges2 .. ")"

		if charges2 <= 0 then
			perkButton.ControlIcon.ImageColor3 = Color3.fromRGB(90, 90, 90)
		end

		updatePerk() -- equivalent call inferred; original call site unknown
	end

	instance:GetAttributeChangedSignal("ActiveTime"):Connect(updatePerk)
	instance:GetAttributeChangedSignal("Cooldown"):Connect(updatePerk)
	instance:GetAttributeChangedSignal("LastUse"):Connect(function()
		now = os.clock()
	end)
	instance:GetAttributeChangedSignal("Charges"):Connect(updateCharges)
	updateCharges() -- equivalent call inferred; original call site unknown
	updatePerk() -- equivalent call inferred; original call site unknown
	now = -100
	v = instance
	perkButton.Visible = true
	PerkService.PerkIsActive = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onPlayerGuiChildAdded(child)
	if child:HasTag("Perk") then
		onPerkAdded(child)
	end
end

local function onPreSimulation(_: number)
	if not (v and PerkService.PerkButton and PerkService.PerkButton.Visible) then
		return
	end

	local v2 = os.clock() - now

	if activeTime and v2 < activeTime then
		PerkService.PerkButton.Cooldown.Text = math.ceil(activeTime - v2)
		PerkService.PerkButton.Cooldown.Visible = true
		PerkService.PerkButton.Cooldown.TextColor3 = Color3.fromRGB(50, 200, 50)
		PerkService.PerkButton.Cooldown.BackgroundTransparency = 1
		PerkService.PerkButton.AutoButtonColor = false
	elseif cooldown and v2 < cooldown then
		local text = math.ceil(cooldown - v2)
		PerkService.PerkButton.Cooldown.Text = text
		PerkService.PerkButton.Cooldown.Visible = true
		PerkService.PerkButton.Cooldown.TextColor3 = Color3.fromRGB(200, 200, 200)
		PerkService.PerkButton.Cooldown.BackgroundTransparency = 0.5
		PerkService.PerkButton.AutoButtonColor = false
	else
		if charges and charges <= 0 then
			PerkService.PerkButton.AutoButtonColor = false
		else
			PerkService.PerkButton.AutoButtonColor = not v:GetAttribute("Passive")
		end

		PerkService.PerkButton.Cooldown.Visible = false
	end
end

local function onInitialize()
	resetPerks() -- equivalent call inferred; original call site unknown
	localPlayer.CharacterAdded:Connect(function(character)
		resetPerks() -- equivalent call inferred; original call site unknown
		character.ChildAdded:Connect(function(child)
			onPlayerGuiChildAdded(child) -- equivalent call inferred; original call site unknown
		end)
	end)
	RunService.PreSimulation:Connect(onPreSimulation)
	playerGui.ChildAdded:Connect(onPlayerGuiChildAdded)
end

onInitialize()