local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
local ABTest = require(GameSdkShared.Modules.ABTest)
local InteractionPrompt = require(ReplicatedStorage.Modules.Client.Components.Interactions.InteractionPrompt)
local LotRoot = require(ReplicatedStorage.Modules.Shared.Components.Housing.LotRoot)
local LotController = require(ReplicatedStorage.Modules.Client.Lot.LotController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "ClaimableLot"
})
local flag = false
local v2 = false
local v3 = false

local function isConsolePlotUIEnabled()
	if flag then
		return v3
	end

	while v2 and flag ~= true do
		task.wait()
	end

	if flag then
		return v3
	end

	v2 = true
	local v4, v5 = ABTest.GetExperimentVariable("console-controls", "plotUi"):timeout(7):await()

	if v4 and v5 == true then
		v3 = true
	end

	flag = true
	v2 = false
	return v3
end

function v:Construct()
	self._Janitor = Janitor.new()
	self.debounce = nil
	self.clickDetector = nil
	self.interactionPrompt = nil
end

function v:TryClaim()
	if self.debounce ~= nil and tick() < self.debounce then
		return
	end

	self.debounce = tick() + 0.5
	local id = self.lotRoot:GetId()

	if LotUtil.IsClaimed(id) then
		if LotUtil.GetLotType(id) == "Landmark" then
			if LotUtil.GetOwner(id) == localPlayer then
				return
			else
				LotController.TryClaim(id)
			end
		end
	else
		local houseOwn = localPlayer.PlayersBag:FindFirstChild("HouseOwn")

		if houseOwn == nil or houseOwn.Value == true then
			NotificationController.Notify("Already own House!")
		else
			LotController.TryClaim(id)
		end
	end
end

function v:EnsureInteractionPrompt(p)
	if self.interactionPrompt ~= nil then
		return
	end

	self.Instance:SetAttribute("Type", "ClaimableLot")
	self.Instance:SetAttribute("InteractDistance", p.MaxActivationDistance)
	self.Instance:SetAttribute("HideInteractionUI", true)
	self.Instance:AddTag(InteractionPrompt.Tag)
	self._Janitor:AddPromise(InteractionPrompt:WaitForInstance(self.Instance):andThen(function(interactionPrompt)
		self.interactionPrompt = interactionPrompt
		self.interactionPrompt:SetEnabled(Platform.IsConsole())
		self._Janitor:Add(self.interactionPrompt.Interacted:Connect(function()
			self:TryClaim()
		end))
	end))
end

function v:UpdateConsoleInteractionState()
	if self.clickDetector == nil then
		return
	end

	local v4 = Platform.IsConsole() and isConsolePlotUIEnabled()

	if v4 then
		self:EnsureInteractionPrompt(self.clickDetector)
	end

	if self.interactionPrompt ~= nil then
		self.interactionPrompt:SetEnabled(v4)
	end
end

function v:Start()
	while not self.lotRoot do
		self.lotRoot = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "LotRoot", LotRoot)
		task.wait(3)
	end

	local clickDetector = self.Instance:FindFirstChild("ClickDetector")

	if not (clickDetector ~= nil and clickDetector:IsA("ClickDetector")) then
		return
	end

	self.clickDetector = clickDetector
	self._Janitor:Add(clickDetector.MouseClick:Connect(function(p)
		if p ~= localPlayer then
			return
		end

		self:TryClaim()
	end))

	if not isConsolePlotUIEnabled() then
		return
	end

	self._Janitor:Add(CollectionService:GetInstanceRemovedSignal(InteractionPrompt.Tag):Connect(function(p)
		if p ~= self.Instance then
			return
		end

		self.interactionPrompt = nil
		self:UpdateConsoleInteractionState()
	end))
	self:UpdateConsoleInteractionState()
	self._Janitor:Add(Platform.PlatformChangedSignal:Connect(function()
		self:UpdateConsoleInteractionState()
	end))
end

function v:Stop()
	if self.interactionPrompt ~= nil then
		self.interactionPrompt:SetEnabled(false)
	end

	self._Janitor:Destroy()
	self.Instance:RemoveTag(InteractionPrompt.Tag)
	self.Instance:SetAttribute("Type", nil)
	self.Instance:SetAttribute("InteractDistance", nil)
	self.Instance:SetAttribute("HideInteractionUI", nil)
	self.interactionPrompt = nil
end

return v