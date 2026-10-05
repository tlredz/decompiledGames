local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local MonetizationLibrary = require(ReplicatedStorage.Modules.MonetizationLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local LobbyController = require(Players.LocalPlayer.PlayerScripts.Controllers.LobbyController)
local LobbyElement = require(Players.LocalPlayer.PlayerScripts.Modules.LobbyElement)
local v = {
	"starter_bundle",
	"medkit_bundle",
	"exogun_bundle",
	"heavyduty_bundle",
	"classic_bundle",
	"standardweapons_bundle",
	"energy_bundle",
	"rpg_bundle"
}
local physicalBundles = Players.LocalPlayer.PlayerScripts.Assets:WaitForChild("PhysicalBundles")
local object = setmetatable({}, LobbyElement)
object.__index = object

function object._new(...)
	local self = setmetatable(LobbyElement.new(...), object)
	self._bundles_pool = {}
	self._current_index = 1
	self._bundle_display_model = nil
	self._bundle_display_pivot = nil
	self:_Init()
	return self
end

function object:SetIndex(p)
	self._current_index = #self._bundles_pool == 0 and 1 or (p - 1) % #self._bundles_pool + 1
	self._bundle_display_pivot = self._bundle_display_pivot or CollectionService:GetTagged("LobbyBundleDisplay")[1] and CollectionService:GetTagged("LobbyBundleDisplay")[1].CFrame or nil

	if self._bundle_display_model then
		self._bundle_display_model:Destroy()
		self._bundle_display_model = nil
	end

	local v2 = self._bundles_pool[self._current_index] or "keybundle_3"
	self._bundle_display_model = physicalBundles:WaitForChild(v2):Clone()
	self._bundle_display_model.PrimaryPart = self._bundle_display_model.Prompt
	self._bundle_display_model.Prompt.CFrame += createVector(0, 2, 0)

	for _, part in pairs(self._bundle_display_model:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Massless = true
	end

	self._bundle_display_model.Parent = workspace

	for _, part in pairs(self._bundle_display_model:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Anchored = true
	end

	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.ActionText = "View"
	proximityPrompt.ClickablePrompt = true
	proximityPrompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
	proximityPrompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	proximityPrompt.HoldDuration = 0
	proximityPrompt.MaxActivationDistance = 16
	proximityPrompt.KeyboardKeyCode = Enum.KeyCode.Q
	proximityPrompt.ObjectText = "Special Offer"
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	proximityPrompt:AddTag("LobbyOpenPagePrompt")
	proximityPrompt:SetAttribute("PageName", "Shop")
	proximityPrompt:SetAttribute("ShopViewBundleName", v2)
	proximityPrompt.Parent = self._bundle_display_model.Prompt
end

function object:Update(_)
	if not self._bundle_display_model then
		return
	end

	local v2 = math.sin(tick() * 0.25) ^ 30 * 1
	local v3 = tick() * 0.1 % 6.283185307179586
	local v4 = CFrame.new(0, v2, 0) * CFrame.Angles(0, v3, 0)
	self._bundle_display_model:PivotTo((self._bundle_display_pivot or CFrame.identity) * v4)
end

function object:_UpdatePool()
	for k in pairs(PlayerDataController:Get("GamepassBundlesClaimed")) do
		local gamepass = MonetizationLibrary.Gamepasses[k]

		if not (gamepass and gamepass.BundleName) then
			continue
		end

		local index = table.find(self._bundles_pool, gamepass.BundleName)

		if index then
			table.remove(self._bundles_pool, index)
		end
	end

	self:SetIndex(1)
end

function object:_Setup()
	for _, v2 in pairs(v) do
		table.insert(self._bundles_pool, math.random(1, #self._bundles_pool + 1), v2)
	end
end

function object:_Init()
	LobbyController.LocalFighter:GetDataChangedSignal("IsInDuel"):Connect(function()
		if not LobbyController.LocalFighter:Get("IsInDuel") then
			self:SetIndex(self._current_index + 1)
		end
	end)
	PlayerDataController:GetDataChangedSignal("GamepassBundlesClaimed"):Connect(function()
		self:_UpdatePool()
	end)
	PlayerDataController:GetDataChangedSignal("StatisticDuelsPlayed"):Connect(function()
		self:_UpdatePool()
	end)
	self:_Setup()
	self:_UpdatePool()
	self:SetIndex(1)
end

return object._new()