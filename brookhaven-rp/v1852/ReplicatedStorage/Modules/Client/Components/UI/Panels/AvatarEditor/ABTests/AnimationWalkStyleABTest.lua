local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local AvatarEditorMenu = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.AvatarEditor.AvatarEditorMenu)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local v = Component.new({
	Tag = "AnimationWalkStyleABTest"
})
local v2 = {
	All = "Animations",
	Idle = "Idle",
	Walk = "Walk",
	Run = "Run",
	Jump = "Jump",
	Fall = "Fall",
	Climb = "Climb",
	Swim = "Swim"
}

function v:Construct()
	self._Janitor = Janitor.new()
	self._isTreatmentEnabled = false
	self._isStopped = false
end

function v:IsTreatmentEnabled()
	return self._isTreatmentEnabled == true
end

function v:ApplyControl(instance)
	local all = instance:FindFirstChild("All")

	if all and all:IsA("GuiObject") then
		all.Visible = false
		all:SetAttribute("DefaultSelected", nil)
	end

	for _, button in instance:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		button:SetAttribute("TargetPanel", "AnimationBundleList")
		button:SetAttribute("DisplayName", nil)
	end

	local idle = instance:FindFirstChild("Idle")

	if idle and idle:IsA("GuiButton") then
		idle:SetAttribute("DefaultSelected", true)
	end
end

function v:ApplyTreatment(instance)
	local all = instance:FindFirstChild("All")

	if all and all:IsA("GuiObject") then
		all.Visible = true
	end

	for _, button in instance:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		button:SetAttribute("TargetPanel", "CatalogClothesList")
		button:SetAttribute("DefaultSelected", nil)
		local v3 = v2[button.Name]

		if v3 ~= nil then
			button:SetAttribute("DisplayName", v3)
		end
	end

	if all and all:IsA("GuiButton") then
		all:SetAttribute("DefaultSelected", true)
	end
end

function v:Start()
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"AvatarEditorMenu",
		AvatarEditorMenu
	)
	local catalog = self.Instance:FindFirstChild("Catalog") or self.Instance
	local walkStyle = catalog:FindFirstChild("SubCategoryTabs") and catalog.SubCategoryTabs:FindFirstChild("WalkStyle")

	if walkStyle == nil then
		warn("AnimationWalkStyleABTest: WalkStyle subcategory tabs not found")
		return
	end

	self._isTreatmentEnabled = false

	if waitForAncestorComponent ~= nil and waitForAncestorComponent.SetAnimationCatalogSearchEnabled ~= nil then
		waitForAncestorComponent:SetAnimationCatalogSearchEnabled(false)
	end

	self:ApplyControl(walkStyle)
	local v3, v4 = ABTest.GetExperimentVariable("ae-ugc-animation-packs", "isEnabled"):timeout(7):await()

	if self._isStopped or walkStyle.Parent == nil then
		return
	end

	self._isTreatmentEnabled = v3 == true and v4 == true

	if waitForAncestorComponent ~= nil and waitForAncestorComponent.SetAnimationCatalogSearchEnabled ~= nil then
		waitForAncestorComponent:SetAnimationCatalogSearchEnabled(self._isTreatmentEnabled)
	end

	if self._isTreatmentEnabled then
		self:ApplyTreatment(walkStyle)
	else
		self:ApplyControl(walkStyle)
	end
end

function v:Stop()
	self._isStopped = true
	self._Janitor:Destroy()
end

return v