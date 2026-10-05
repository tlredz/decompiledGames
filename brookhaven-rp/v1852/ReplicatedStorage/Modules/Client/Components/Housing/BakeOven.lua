local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local InteractionPrompt = require(ReplicatedStorage.Modules.Client.Components.Interactions.InteractionPrompt)
local GridSelection = require(ReplicatedStorage.Modules.Client.Components.Interactions.GridSelection.GridSelection)
local HouseInteractionTelemetry = require(ReplicatedStorage.Modules.Client.Telemetry.HouseInteractionTelemetry)
local v = Component.new({
	Tag = "BakeOven"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.menuOpen = false
	self.Instance:SetAttribute("TelemetrySource", "House Interaction")
end

function v:SetMenuOpen(menuOpen: boolean)
	if self.menuOpen == menuOpen then
		return
	end

	self.menuOpen = menuOpen
	Remotes.fireServerComponent(self.Instance, "SetMenuOpen", menuOpen)
end

function v:Start()
	local expect = InteractionPrompt:WaitForInstance(self.Instance):expect()
	local expect2 = GridSelection:WaitForInstance(self.Instance):expect()
	self._Janitor:Add(expect2.OptionSelected:Connect(function(p)
		HouseInteractionTelemetry.Fire(self.Instance, {
			interactionObject = "Oven",
			primaryAction = "Cooking",
			actionItem = p.Name
		})
	end))
	self._Janitor:Add(expect.Interacted:Connect(function()
		local bakeState = self.Instance:GetAttribute("BakeState")

		if bakeState == "Baking" then
			self:SetMenuOpen(not self.menuOpen)
			return
		end

		if bakeState ~= "Ready" and bakeState ~= "Warning" and bakeState ~= "Burning" and bakeState ~= "Burnt" then
			return
		end

		local bakeFoodId = self.Instance:GetAttribute("BakeFoodId")
		local fire = HouseInteractionTelemetry.Fire
		local instance = self.Instance

		if typeof(bakeFoodId) ~= "string" then
			bakeFoodId = nil
		end

		fire(instance, {
			interactionObject = "Oven",
			primaryAction = "GrabBaked",
			actionItem = bakeFoodId
		})
		Remotes.fireServerComponent(self.Instance, "GrabBaked")
	end))
	self._Janitor:Add(self.Instance:GetAttributeChangedSignal("HideInteractionUI"):Connect(function()
		local hideInteractionUI = self.Instance:GetAttribute("HideInteractionUI") == true
		self:SetMenuOpen(hideInteractionUI)
	end))

	if self.Instance:GetAttribute("HideInteractionUI") == true then
		self:SetMenuOpen(true)
	end
end

function v:Stop()
	if self.menuOpen then
		Remotes.fireServerComponent(self.Instance, "SetMenuOpen", false)
	end

	self._Janitor:Destroy()
end

return v