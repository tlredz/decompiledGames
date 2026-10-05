local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local FireworkConstants = require(ReplicatedStorage.Modules.Shared.Fireworks.FireworkConstants)
local FireworkController = require(ReplicatedStorage.Modules.Client.Fireworks.FireworkController)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "FireworkTool",
	Extensions = { OnlyRunOnPlayerHotbar }
})

local function findToolGui(instance, _toolGui)
	if _toolGui ~= nil and _toolGui.Parent ~= nil then
		return _toolGui
	end

	local toolGui = instance:FindFirstChild("ToolGui")

	if toolGui ~= nil and toolGui:IsA("ScreenGui") then
		return toolGui
	end

	local gunGUI = instance:FindFirstChild("GunGUI")

	if gunGUI ~= nil and gunGUI:IsA("ScreenGui") then
		return gunGUI
	end

	local parent = instance.Parent

	if parent == nil then
		return nil
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(parent)

	if playerFromCharacter == nil then
		return nil
	end

	local toolGui2 = playerFromCharacter.PlayerGui:FindFirstChild("ToolGui")

	if toolGui2 ~= nil and toolGui2:IsA("ScreenGui") then
		return toolGui2
	end

	local gunGUI2 = playerFromCharacter.PlayerGui:FindFirstChild("GunGUI")

	if gunGUI2 ~= nil and gunGUI2:IsA("ScreenGui") then
		return gunGUI2
	end

	return nil
end

local function setRemoteButtonVisible(p, visible: boolean)
	if p == nil then
		return
	end

	p.Visible = visible
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = Janitor.new()
	self._placedCount = 0
	self._isDetonating = false
	self._inventoryFireworkType = nil
	local instance = self.Instance
	local toolGui = instance:FindFirstChild("ToolGui")

	if toolGui ~= nil and toolGui:IsA("ScreenGui") then
		self._toolGui = toolGui
		return
	end

	local gunGUI = instance:FindFirstChild("GunGUI")

	if gunGUI ~= nil and gunGUI:IsA("ScreenGui") then
		self._toolGui = gunGUI
	end
end

function v:RefreshPlacedCount()
	self:OnPlacedCountChanged(FireworkController.GetPlacedCount())
end

function v:OnPlacedCountChanged(placedCount: number)
	self._placedCount = placedCount

	if self._remoteButton ~= nil then
		local _remoteButton = self._remoteButton

		if _remoteButton == nil then
			return
		else
			_remoteButton.Visible = true
		end
	end
end

function v:UpdateUsesCounter(p2: number)
	if self._usesCounterLabel == nil then
		return
	end

	if p2 == 1 then
		self._usesCounterLabel.Text = "1 USE LEFT"
	else
		self._usesCounterLabel.Text = `{p2} USES LEFT`
	end
end

function v:WireUsesCounter(instance, p)
	local uses = instance:FindFirstChild("Uses", true)

	if uses ~= nil and uses:IsA("GuiObject") then
		uses.Visible = p ~= nil and FireworkConstants.RequiresInventory(p)
	end

	self._usesCounterLabel = nil

	if p == nil or not FireworkConstants.RequiresInventory(p) then
		return
	end

	local fireworkCounter = instance:FindFirstChild("FireworkCounter", true)

	if fireworkCounter == nil then
		return
	end

	local counter = fireworkCounter:FindFirstChild("Counter")

	if counter == nil or not counter:IsA("TextLabel") then
		return
	end

	self._usesCounterLabel = counter
	self:UpdateUsesCounter(FireworkController.GetPaidRemainingUses(p))
	task.defer(function()
		if self._inventoryFireworkType == p and self._usesCounterLabel ~= nil then
			self:UpdateUsesCounter(FireworkController.GetPaidRemainingUses(p))
		end
	end)
end

function v:WireRemoteButton(instance)
	self._remoteButton = instance:FindFirstChild("FireworkRemote", true)

	if self._remoteButton == nil then
		return
	end

	local _remoteButton = self._remoteButton

	if _remoteButton ~= nil then
		_remoteButton.Visible = true
	end

	self._equipJanitor:Add(self._remoteButton.MouseButton1Click:Connect(function()
		if self._isDetonating then
			return
		end

		if self._placedCount <= 0 then
			NotificationController.NotifyCenter("Place a firework first.")
			return
		end

		self._isDetonating = true
		Remotes.fireServerComponent(self.Instance, "DetonateAll")
		task.delay(0.5, function()
			self._isDetonating = false
		end)
	end))
	self:RefreshPlacedCount()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findColorPicks(instance)
	local fireworkColor = instance:FindFirstChild("FireworkColor", true)

	if fireworkColor == nil then
		return nil
	end

	return fireworkColor:FindFirstChild("ColorPicks", true)
end

function v:WireColorPicker(instance)
	local instance2 = self.Instance
	local fireworkType = FireworkConstants.GetFireworkTypeFromTool(instance2)
	local visible

	if fireworkType == nil then
		visible = false
	else
		visible = FireworkConstants.CanRecolor(fireworkType)
	end

	local fireworkColor = instance:FindFirstChild("FireworkColor", true)

	if fireworkColor ~= nil and fireworkColor:IsA("GuiObject") then
		fireworkColor.Visible = visible
	end

	if not visible then
		return
	end

	local colorPicks = findColorPicks(instance) -- equivalent call inferred; original call site unknown

	if colorPicks == nil then
		return
	end

	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onColorSelected(p2: string)
		if flag then
			return
		end

		flag = true
		Remotes.fireServerComponent(self.Instance, "SetFireworkColor", p2)
		task.delay(0.1, function()
			flag = false
		end)
	end

	for _, button in colorPicks:GetChildren() do
		if not (button:IsA("GuiButton") and FireworkConstants.IsColorPickerButtonName(button.Name)) then
			continue
		end

		local name = button.Name
		self._equipJanitor:Add(button.Activated:Connect(function()
			onColorSelected(name) -- equivalent call inferred; original call site unknown
		end))
	end
end

function v:WireDeleteButton(instance)
	local frame = instance:FindFirstChild("Frame")

	if frame == nil then
		return
	end

	local delete = frame:FindFirstChild("Delete")

	if delete == nil or not delete:IsA("GuiButton") then
		return
	end

	self._equipJanitor:Add(delete.MouseButton1Click:Connect(function()
		Remotes.fireServerComponent(self.Instance, "QuickDelete")
	end))
end

function v:Start()
	local instance = self.Instance
	self:OnPlacedCountChanged(FireworkController.GetPlacedCount())
	self._Janitor:Add(FireworkController.PlacedCountChanged:Connect(function(p: number)
		self:OnPlacedCountChanged(p)
	end))
	self._Janitor:Add(FireworkController.PaidRemainingUsesUpdated:Connect(function(p, p2: number)
		if self._inventoryFireworkType == p then
			self:UpdateUsesCounter(p2)
		end
	end))
	self._Janitor:Add(instance.Equipped:Connect(function()
		if Players:GetPlayerFromCharacter(instance.Parent) ~= localPlayer then
			return
		end

		local toolGui = findToolGui(instance, self._toolGui)

		if toolGui then
			self._toolGui = toolGui
			local fireworkType = FireworkConstants.GetFireworkTypeFromTool(instance)
			self._inventoryFireworkType = fireworkType
			self:WireRemoteButton(toolGui)
			self:WireDeleteButton(toolGui)
			self:WireColorPicker(toolGui)
			self:WireUsesCounter(toolGui, fireworkType)
		end

		self._equipJanitor:Add(instance.Activated:Connect(function()
			local mouse = localPlayer:GetMouse()

			if mouse.Target == nil or mouse.Target:HasTag("ToolGiver") then
				return
			end

			local fireworkType = FireworkConstants.GetFireworkTypeFromTool(instance)

			if fireworkType == nil or not (FireworkConstants.RequiresInventory(fireworkType) and FireworkController.GetPaidRemainingUses(fireworkType) <= 0) then
				Remotes.fireServerComponent(self.Instance, "AttemptPlaceFirework", mouse.Hit.Position, mouse.Target)
				return
			end

			NotificationController.NotifyCenter(FireworkConstants.OUT_OF_USES_MSG)
			FireworkController.PromptPurchase(fireworkType, "FireworkTool")
		end))
	end))
	self._Janitor:Add(instance.Unequipped:Connect(function()
		self._equipJanitor:Cleanup()
		self._inventoryFireworkType = nil
		self._remoteButton = nil
		self._usesCounterLabel = nil
	end))
end

function v:Stop()
	self._equipJanitor:Cleanup()
	self._Janitor:Destroy()
end

return v