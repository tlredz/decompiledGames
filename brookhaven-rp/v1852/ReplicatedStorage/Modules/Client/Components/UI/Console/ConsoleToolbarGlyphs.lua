local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local ConsoleControlsConstructGate = require(ReplicatedStorage.Modules.Client.Components.UI.Console.ConsoleControlsConstructGate)
local BackpackVisibilityController = require(ReplicatedStorage.Modules.Client.Player.BackpackVisibilityController)
local v = Component.new({
	Tag = "ConsoleToolbarGlyphs",
	Extensions = { ConsoleControlsConstructGate }
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._playerJanitor = Janitor.new()
	self._characterJanitor = Janitor.new()
	self._backpackJanitor = Janitor.new()
	self._localPlayer = Players.LocalPlayer
	self._layout = nil
	self._leftImage = nil
	self._rightImage = nil
	self._originalSize = nil
	self._toolSlotWidthPx = 60
	self._toolbarCenterFromBottomPx = 30
	self._isRefreshQueued = false
end

function v:_queueRefresh()
	if self._isRefreshQueued then
		return
	end

	self._isRefreshQueued = true
	task.defer(function()
		self._isRefreshQueued = false
		self:_refresh()
	end)
end

function v:_configureGlyphImages()
	self._leftImage:SetAttribute("ConsoleGlyphKeyCode", "ButtonL1")
	self._rightImage:SetAttribute("ConsoleGlyphKeyCode", "ButtonR1")

	if not self._leftImage:HasTag("ConsoleGlyphImage") then
		self._leftImage:AddTag("ConsoleGlyphImage")
	end

	if not self._rightImage:HasTag("ConsoleGlyphImage") then
		self._rightImage:AddTag("ConsoleGlyphImage")
	end
end

function v:_applyGlyphSizing()
	local uDim = UDim2.fromOffset(50, 50)
	self._leftImage.Size = uDim
	self._rightImage.Size = uDim
end

function v:_getToolbarToolCount()
	local v2 = {}
	local count = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function addTool(tool)
		if not tool:IsA("Tool") or v2[tool] then
			return
		end

		v2[tool] = true
		count += 1
	end

	local backpack = self._localPlayer:FindFirstChildOfClass("Backpack")

	if backpack then
		for _, child in backpack:GetChildren() do
			addTool(child) -- equivalent call inferred; original call site unknown
		end
	end

	local character = self._localPlayer.Character

	if character then
		for _, child in character:GetChildren() do
			addTool(child) -- equivalent call inferred; original call site unknown
		end
	end

	return (math.clamp(count, 0, 10))
end

function v:_bindBackpack(instance)
	self._backpackJanitor:Cleanup()

	if not instance then
		self:_queueRefresh()
		return
	end

	self._backpackJanitor:Add(instance.ChildAdded:Connect(function()
		self:_queueRefresh()
	end))
	self._backpackJanitor:Add(instance.ChildRemoved:Connect(function()
		self:_queueRefresh()
	end))
	self._backpackJanitor:Add(BackpackVisibilityController.VisibilityChanged:Connect(function()
		self:_queueRefresh()
	end))
	self:_queueRefresh()
end

function v:_applyGlyphLayout(p: number)
	local v2 = math.max(0, p * self._toolSlotWidthPx + math.max(0, p - 1) * 5 + 0 + 40)
	local X = self._leftImage.AbsoluteSize.X > 0 and self._leftImage.AbsoluteSize.X or self._leftImage.Size.X.Offset
	local X2 = self._rightImage.AbsoluteSize.X > 0 and self._rightImage.AbsoluteSize.X or self._rightImage.Size.X.Offset
	local v3 = math.max(0, X + v2 + X2)
	local instance = self.Instance
	self._layout.Padding = UDim.new(0, 0)
	instance.Size = UDim2.new(0, v3, self._originalSize.Y.Scale, self._originalSize.Y.Offset)
end

function v:_applyToolbarVerticalAlignment()
	local instance = self.Instance
	local _, v2 = GuiService:GetGuiInset()
	local _toolbarCenterFromBottomPx = self._toolbarCenterFromBottomPx
	instance.AnchorPoint = Vector2.new(0.5, 0.5)
	instance.Position = UDim2.fromScale(0.5, 1) + UDim2.fromOffset(0, -(v2.Y + _toolbarCenterFromBottomPx) + 0)
end

function v:_refresh()
	local _getToolbarToolCount = self:_getToolbarToolCount()
	self:_applyGlyphLayout(_getToolbarToolCount)
	self:_applyToolbarVerticalAlignment()
	local isConsole = Platform.IsConsole()

	if isConsole then
		if _getToolbarToolCount >= 1 then
			isConsole = BackpackVisibilityController.GetIsVisible()
		else
			isConsole = false
		end
	end

	self.Instance.Visible = isConsole
end

function v:_bindCharacter(instance)
	self._characterJanitor:Cleanup()

	if not instance then
		self:_queueRefresh()
		return
	end

	self._characterJanitor:Add(instance.ChildAdded:Connect(function()
		self:_queueRefresh()
	end))
	self._characterJanitor:Add(instance.ChildRemoved:Connect(function()
		self:_queueRefresh()
	end))
	self:_queueRefresh()
end

function v:Start()
	if not self.Instance:IsA("GuiObject") then
		warn((`[ConsoleToolbarGlyphs] Expected GuiObject, got {self.Instance.ClassName} at {self.Instance:GetFullName()}`))
		return
	end

	local leftImage = self.Instance:FindFirstChild("LeftImage")
	local rightImage = self.Instance:FindFirstChild("RightImage")
	local uIListLayout = self.Instance:FindFirstChildWhichIsA("UIListLayout")

	if not (leftImage and (leftImage:IsA("ImageLabel") or leftImage:IsA("ImageButton"))) then
		warn((`[ConsoleToolbarGlyphs] Missing LeftImage ImageLabel/ImageButton at {self.Instance:GetFullName()}`))
		return
	end

	if not (rightImage and (rightImage:IsA("ImageLabel") or rightImage:IsA("ImageButton"))) then
		warn((`[ConsoleToolbarGlyphs] Missing RightImage ImageLabel/ImageButton at {self.Instance:GetFullName()}`))
		return
	end

	if not uIListLayout then
		warn((`[ConsoleToolbarGlyphs] Missing UIListLayout at {self.Instance:GetFullName()}`))
		return
	end

	self._leftImage = leftImage
	self._rightImage = rightImage
	self._layout = uIListLayout
	self._originalSize = self.Instance.Size

	if GuiService:IsTenFootInterface() then
		self._toolSlotWidthPx = 100
		self._toolbarCenterFromBottomPx = 56
	end

	self:_configureGlyphImages()
	self:_applyGlyphSizing()
	self._Janitor:Add(Platform.PlatformChangedSignal:Connect(function()
		self:_queueRefresh()
	end))
	self._playerJanitor:Add(self._localPlayer.ChildAdded:Connect(function(backpack)
		if not backpack:IsA("Backpack") then
			return
		end

		self:_bindBackpack(backpack)
	end))
	self._playerJanitor:Add(self._localPlayer.ChildRemoved:Connect(function(backpack)
		if not backpack:IsA("Backpack") then
			return
		end

		self:_bindBackpack(self._localPlayer:FindFirstChildOfClass("Backpack"))
	end))
	self._Janitor:Add(self._localPlayer.CharacterAdded:Connect(function(character)
		self:_bindCharacter(character)
		self:_bindBackpack(self._localPlayer:FindFirstChildOfClass("Backpack"))
	end))
	self:_bindBackpack(self._localPlayer:FindFirstChildOfClass("Backpack"))
	self:_bindCharacter(self._localPlayer.Character)
	self:_queueRefresh()
end

function v:Stop()
	if self.Instance:IsA("GuiObject") and self._originalSize then
		self.Instance.Size = self._originalSize
	end

	self._backpackJanitor:Destroy()
	self._characterJanitor:Destroy()
	self._playerJanitor:Destroy()
	self._Janitor:Destroy()
end

return v