local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local config = ReplicatedStorage:WaitForChild("Config")
require(config)
local Galaxies = require(config:WaitForChild("Galaxies"))
local Janitor = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Janitor"))
local currentCamera = workspace.CurrentCamera
local galaxyAscensions = {}
local ClientState = {}

for _, v2 in ipairs(Galaxies.getOrdered()) do
	galaxyAscensions[v2.INDEX] = 0
end

ClientState.Data = {
	Level = 0,
	XP = 0,
	XPRequired = 100,
	TotalXP = 0,
	Wins = 0,
	Rebirths = 0,
	Multiplier = 1,
	StepBonus = 1,
	onTreadmill = false,
	GiftClaimed = false,
	GalaxyAscensions = galaxyAscensions,
	GoldTreadmillActive = false,
	DiamondTreadmillActive = false,
	CandyTreadmillActive = false,
	AdminTreadmillActive = false,
	SpeedBoostActive = false,
	WinsBoostActive = false,
	CurrentSpeedTier = 0,
	ExtraSpeedBoostTier = 0,
	SpeedBoostMultiplier = 1,
	CustomWalkSpeed = nil,
	World3Stage15Beaten = false,
	Stage15SpeedBoost = 0,
	BonusXPMultiplier = 1,
	BonusWinsMultiplier = 1,
	OwnedTrails = {},
	EquippedTrail = "None",
	TrailSkin = "None",
	OwnedAuras = {},
	EquippedAura = "None",
	AuraSkin = "None",
	Items = {},
	EquippedItems = {},
	OwnedTreadmillSkins = {},
	EquippedTreadmillSkin = "DefaultTreadmill"
}
ClientState.ActiveModal = nil
ClientState.ActiveSystem = nil
ClientState.ModalListeners = {}
ClientState.WinsTrophyAnimationsEnabled = false

function ClientState.RegisterModalListener(p, p2)
	table.insert(p.ModalListeners, p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fireModalListeners(p)
	for _, modalListener in ipairs(ClientState.ModalListeners) do
		modalListener(p)
	end
end

local menuBlur = Lighting:FindFirstChild("MenuBlur") or Instance.new("BlurEffect")
menuBlur.Name = "MenuBlur"
menuBlur.Size = 0
menuBlur.Parent = Lighting
local v2 = Janitor.new()
local v3 = nil

local function playTrackedTween(p, tweenInfo, p2)
	local tween = TweenService:Create(p, tweenInfo, p2)
	tween.Completed:Once(function()
		v2:RemoveNoClean(tween)
	end)
	tween:Play()
	v2:Add(tween, "Cancel", tween)
	return tween
end

function ClientState.Get(p)
	return p.Data
end

function ClientState.Update(p, items)
	for k, item in pairs(items) do
		p.Data[k] = item
	end
end

local uDim = UDim2.new(0.5, 0, 1.5, 0)
local uDim2 = UDim2.new(0.5, 0, 0.5, 0)

-- equivalent calls inferred from this helper; original call sites unknown
local function getVisiblePosition(activeModal)
	local modalVisibleY = activeModal:GetAttribute("ModalVisibleY")

	if typeof(modalVisibleY) == "number" then
		return UDim2.new(0.5, 0, modalVisibleY, 0)
	end

	return uDim2
end

function ClientState:ToggleModal(activeModal, activeSystem)
	if not activeModal then
		return
	end

	if self.ActiveModal == activeModal then
		self:CloseCurrentModal()
		return
	end

	if self.ActiveModal ~= nil then
		self:CloseCurrentModal()
	end

	self.ActiveModal = activeModal
	self.ActiveSystem = activeSystem
	v3 = activeModal
	activeModal.AnchorPoint = Vector2.new(0.5, 0.5)
	activeModal.Position = uDim
	activeModal.Visible = true
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local visiblePosition = getVisiblePosition(activeModal) -- equivalent call inferred; original call site unknown
	playTrackedTween(activeModal, tweenInfo, {
		Position = visiblePosition
	})
	playTrackedTween(menuBlur, TweenInfo.new(0.4), {
		Size = 20
	})
	playTrackedTween(currentCamera, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
		FieldOfView = 50
	})
	fireModalListeners(true) -- equivalent call inferred; original call site unknown
end

function ClientState:CloseCurrentModal()
	local activeModal = self.ActiveModal

	if not activeModal then
		return
	end

	if self.ActiveSystem and self.ActiveSystem.OnClose then
		self.ActiveSystem:OnClose()
	end

	self.ActiveModal = nil
	self.ActiveSystem = nil
	fireModalListeners(false) -- equivalent call inferred; original call site unknown
	local v4 = playTrackedTween(activeModal, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
		Position = uDim
	})
	playTrackedTween(menuBlur, TweenInfo.new(0.3), {
		Size = 0
	})
	playTrackedTween(currentCamera, TweenInfo.new(0.3), {
		FieldOfView = 70
	})
	v4.Completed:Once(function(p)
		if p == Enum.PlaybackState.Completed then
			activeModal.Visible = false

			if v3 == activeModal then
				v3 = nil
			end
		end
	end)
end

function ClientState:ForceResetModal()
	local activeModal = self.ActiveModal or v3
	local activeSystem = self.ActiveSystem
	self.ActiveModal = nil
	self.ActiveSystem = nil
	v3 = nil
	v2:Cleanup()

	if activeSystem and activeSystem.OnClose then
		activeSystem:OnClose()
	end

	if activeModal and activeModal.Parent then
		activeModal.Visible = false
		activeModal.Position = uDim
	end

	menuBlur.Size = 0
	currentCamera.FieldOfView = 70
	fireModalListeners(false) -- equivalent call inferred; original call site unknown
end

return ClientState