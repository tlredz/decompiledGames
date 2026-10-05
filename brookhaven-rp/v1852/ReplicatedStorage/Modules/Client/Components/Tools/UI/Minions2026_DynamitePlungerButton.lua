local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local v = Component.new({
	Tag = "Minions2026_DynamitePlungerButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	local screenGui = instance:FindFirstAncestorOfClass("ScreenGui")

	if screenGui == nil then
		warn("Minions2026_DynamitePlungerButton:Start() - no ScreenGui ancestor")
		return
	end

	local toolReference = screenGui:WaitForChild("ToolReference")
	local value = toolReference.Value

	if value == nil then
		warn("Minions2026_DynamitePlungerButton:Start() - ToolReference has no Value")
		return
	end

	local component = toolReference:GetAttribute("Component")
	local waitForComponent = ComponentUtil.FindAndWaitForComponentByTag(value, component, false)

	if waitForComponent == nil then
		warn("Minions2026_DynamitePlungerButton:Start() - Component class not found:", component)
		return
	end

	local component2 = ComponentUtil.GetComponentFromInstance(value, waitForComponent, 10)

	if component2 == nil then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refreshVisibility()
		instance.Visible = value:GetAttribute("DynamitePlaced") == true
	end

	refreshVisibility() -- equivalent call inferred; original call site unknown
	self._Janitor:Add(value:GetAttributeChangedSignal("DynamitePlaced"):Connect(refreshVisibility))
	self._Janitor:Add(instance.Activated:Connect(function()
		component2:Detonate()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v