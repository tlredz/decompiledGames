local createVector = vector.create

while not workspace:GetAttribute("ClientStarted") do
	workspace:GetAttributeChangedSignal("ClientStarted"):Wait()
end

game:GetService("RunService")
game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnalyticsController = require(ReplicatedStorage.Controllers.AnalyticsController)
local Replion = require(ReplicatedStorage.Packages.Replion)
local client = Replion.Client
local ShopController = require(ReplicatedStorage.Controllers.UI.ShopController)
local GuiHandler = require(ReplicatedStorage.ClientGameModules.GuiHandler)
local Signal = require(ReplicatedStorage.Packages.Signal)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local TweenService = game:GetService("TweenService")
local GamepadIconController = require(ReplicatedStorage.Controllers.GamepadIconController)
local Inventory = require(ReplicatedStorage.Shared.Inventory)
local client2 = Inventory.Client
local Freeze = require(ReplicatedStorage.Packages.Freeze)
local UseNewLobby = require(ReplicatedStorage.Shared.UseNewLobby)

if not UseNewLobby() then
	return
end

local spawn = workspace:WaitForChild("Spawn", 1000000)
local explosionCratesSign = spawn:WaitForChild("ExplosionCratesSign")
local swordCratesSign = spawn:WaitForChild("SwordCratesSign")
local crates = script.Parent.Parent.Parent:WaitForChild("Crates")
local flag = true
Signal.new()

local function showPart(billboardGui, flag2: boolean, visible: boolean)
	billboardGui.Main.Header.BottomBG.Visible = visible
	billboardGui.Main.Header.TopBG.Visible = visible
	local header = billboardGui.Main.Header
	local size

	if visible then
		size = UDim2.fromScale(1, 0.25)
	else
		size = UDim2.fromScale(1, 1)
	end

	header.Size = size
	local rates = billboardGui.Main.Rates

	if visible then
	end

	rates.Size = UDim2.fromScale(1, 0.75)
	local main = billboardGui.Main
	local uDim2

	if visible then
		uDim2 = UDim2.fromScale(0.9, 0.95)
	elseif flag2 then
		uDim2 = UDim2.fromScale(0.9, 0.333)
	else
		uDim2 = UDim2.fromScale(0.9, 0.25)
	end

	main.Size = uDim2
	billboardGui.Main.BackgroundTransparency = visible and 0.5 or 0.25
	billboardGui.Main.Rates.Visible = visible
	billboardGui.AlwaysOnTop = true
	local billboardGui2 = explosionCratesSign:FindFirstChildWhichIsA("BillboardGui", true)

	if billboardGui2 then
		billboardGui2.Enabled = not visible
	end

	local billboardGui3 = swordCratesSign:FindFirstChildWhichIsA("BillboardGui", true)

	if billboardGui3 then
		billboardGui3.Enabled = not visible
	end
end

local function moveCrateKeys(p, flag2: boolean, flag3: boolean)
	local v = flag2 and 5 or 7
	p.AlwaysOnTop = true
	local studsOffset

	if flag3 then
		studsOffset = createVector(0, 1, 0) * v
	else
		studsOffset = createVector(0, 1, 0) * (v * 0.5)
	end

	p.StudsOffset = studsOffset
end

local function hideCrateModel(folder)
	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			part.Transparency = 1
		end
	end
end

local function hideCrate(instance)
	instance:WaitForChild("Lock"):FindFirstChild("ProximityPrompt")
	instance.Name:find("Premium")
	local rateGUI = instance:WaitForChild("RateGUI")
	local crateKeys = instance:WaitForChild("CrateKeys")
	local billboardGui = rateGUI:WaitForChild("BillboardGui")
	instance:WaitForChild("Unlock")
	crateKeys.Enabled = false
	billboardGui.Enabled = false
end

local function showShop()
	local holder = game.Players.LocalPlayer.PlayerGui:WaitForChild("Shop"):WaitForChild("Holder")
	local pages = holder:WaitForChild("Pages")
	local abilities = pages:WaitForChild("Abilities")
	local invisibility = abilities:WaitForChild("Unowned"):WaitForChild("Invisibility")
	holder:WaitForChild("InfoBG"):WaitForChild("BuyButton")

	if not GuiHandler:IsOpen("Shop") then
		GuiHandler:Open("Shop")
	end

	ShopController:GoTo("Ability", true)
	local v = invisibility.AbsolutePosition.Y - invisibility.AbsoluteSize.Y - abilities.AbsolutePosition.Y
	pages.Abilities.CanvasPosition += Vector2.new(0, v)
end

local function showCrate(model)
	local proximityPrompt = model:WaitForChild("Lock"):FindFirstChild("ProximityPrompt")
	local v = model.Name:find("Premium") and true or false
	local rateGUI = model:WaitForChild("RateGUI")
	local crateKeys = model:WaitForChild("CrateKeys")
	local billboardGui = rateGUI:WaitForChild("BillboardGui")
	local unlock = game.Players.LocalPlayer.PlayerGui:WaitForChild("Unlock")
	local uIGradient = unlock.Frame.Go.Key.ImageLabel.UIGradient
	unlock.Enabled = false

	if proximityPrompt then
		proximityPrompt.HoldDuration = 0.5
		proximityPrompt:SetAttribute("NoCustomTheme", flag)
		proximityPrompt:SetAttribute("Disabled", flag)
		local promptShownConnection = proximityPrompt.PromptShown:Connect(function()
			if flag then
				unlock.Adornee = model
				unlock.Enabled = true
			else
				showPart(billboardGui, v, true)
				local v2 = crateKeys
				v2.AlwaysOnTop = true
				v2.StudsOffset = createVector(0, 1, 0) * (v and 5 or 7)
			end
		end)

		if flag then
			local tween = TweenService:Create(uIGradient, TweenInfo.new(proximityPrompt.HoldDuration), {
				Offset = Vector2.new(0, 0.4)
			})
			proximityPrompt.PromptButtonHoldBegan:Connect(function()
				tween:Cancel()
				uIGradient.Offset = Vector2.new(0, -1)
				tween:Play()
			end)
			proximityPrompt.PromptButtonHoldEnded:Connect(function()
				tween:Cancel()
				uIGradient.Offset = Vector2.new(0, 1)
			end)
			proximityPrompt.Triggered:Connect(function()
				showShop()
			end)
		end

		local promptHiddenConnection = proximityPrompt.PromptHidden:Connect(function()
			if flag then
				unlock.Adornee = nil
				unlock.Enabled = false
			else
				showPart(billboardGui, v, false)
				local v2 = crateKeys
				v2.AlwaysOnTop = true
				v2.StudsOffset = createVector(0, 1, 0) * ((v and 5 or 7) * 0.5)
			end
		end)
		model.Destroying:Once(function()
			promptShownConnection:Disconnect()
			promptHiddenConnection:Disconnect()
		end)
	end

	crateKeys.Enabled = not flag
	billboardGui.Enabled = not flag
	showPart(billboardGui, v, false)
	crateKeys.AlwaysOnTop = true
	crateKeys.StudsOffset = createVector(0, 1, 0) * ((v and 5 or 7) * 0.5)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onCrateAdded(model)
	if not model:IsA("Model") then
		return
	end

	showCrate(model)
end

AnalyticsController:GetRemoteConfigValue("NewUserHideCrateEnabled", false):andThen(function(flag2: boolean)
	if not client:GetReplion("Data") then
		return
	end

	local v = Freeze.Dictionary.count(client2:Get("Ability") or {}) > 1
	local v2

	if flag2 then
		v2 = not v
	else
		v2 = false
	end

	flag = v2

	if flag then
		local unlock = game.Players.LocalPlayer.PlayerGui:WaitForChild("Unlock")
		unlock.Frame.Go.Activated:Connect(function()
			showShop()
		end)
		UserInputService.InputChanged:Connect(function(input, _: boolean)
			local flag3 = string.find(input.UserInputType.Name, "Gamepad") and true or false
			unlock.Frame.Go.Key.Visible = flag3
			unlock.Frame.HOLD.Visible = flag3

			if flag3 then
				unlock.Frame.Go.Key.Image = GamepadIconController:GetMappedImageForKeyCode(Enum.KeyCode.ButtonX)
			end
		end)
		client2:OnChange("Ability", function()
			flag = false

			for _, child in crates:GetChildren(), nil, nil do
				onCrateAdded(child) -- equivalent call inferred; original call site unknown
			end
		end)
	end

	for _, child in ipairs(crates:GetChildren()) do
		onCrateAdded(child) -- equivalent call inferred; original call site unknown
	end

	crates.ChildAdded:Connect(onCrateAdded)
end)