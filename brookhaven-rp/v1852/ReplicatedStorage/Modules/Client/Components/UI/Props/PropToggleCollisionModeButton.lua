local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local LoadableEntriesFilter = require(ReplicatedStorage.Modules.Client.Components.UI.Utils.Loadables.LoadableEntriesFilter)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local TagsUtil = require(ReplicatedStorage.Modules.Shared.Utils.TagsUtil)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
local v = Component.new({
	Tag = "PropToggleCollisionModeButton"
})
local _ = {
	TOGGLE_COLLISION_MODE = "ToggleCollisionMode"
}
local v2 = {
	SELECTED = {
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		Checked = true
	},
	DESELECTED = {
		ImageColor3 = Color3.fromRGB(62, 63, 63),
		Checked = false
	}
}
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local props = nil
local stateSelected = true

function v.IsCollisionEnabled()
	if GameUtil.IsPrivateServer() then
		return stateSelected
	end

	return false
end

function v.SetCollisionEnabled(flag: boolean)
	if not GameUtil.IsPrivateServer() then
		return
	end

	stateSelected = flag
end

function v.ToggleCollisionMode()
	if not GameUtil.IsPrivateServer() then
		return
	end

	stateSelected = not stateSelected
	props:FireServer("ToggleCollisionMode", stateSelected)
end

local function tweenButtonAppearance(p, p2)
	local instance = p.Instance
	local icon = p.Instance:FindFirstChild("Icon")

	if instance then
		TweenService:Create(instance, tweenInfo, {
			BackgroundColor3 = p2.ImageColor3
		}):Play()
	end

	if icon then
		TweenService:Create(icon, tweenInfo, {
			ImageColor3 = p2.ImageColor3
		}):Play()
	end

	if p2.Checked == true then
		p.Instance:AddTag("Checked")
	else
		p.Instance:RemoveTag("Checked")
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyVisibility(p, p2: string?)
	local v4 = p2 == "Building Basics" or p2 == "Building"
	p.Instance.Visible = v4 and GameUtil.IsPrivateServer()
end

function v:Construct()
	self._Janitor = Janitor.new()
	props = ReplicatedStorage.RE:WaitForChild("Props")
end

function v:Start()
	if not self.Instance:IsA("ImageButton") then
		return
	end

	self.stateSelected = stateSelected
	self.Instance:SetAttribute("Selected", self.stateSelected)
	local v4

	if self.stateSelected == true then
		v4 = v2.SELECTED
	else
		v4 = v2.DESELECTED
	end

	tweenButtonAppearance(self, v4)
	self.Instance.Visible = false
	local ancestor = TagsUtil.FindAncestorByTag(self.Instance, "PropsMenu")

	if ancestor ~= nil then
		local scrollingFrame = ancestor:WaitForChild("Catalog"):WaitForChild("Container"):WaitForChild("ScrollingFrame")
		local component = ComponentUtil.GetComponentFromInstance(scrollingFrame, LoadableEntriesFilter)

		if component ~= nil then
			applyVisibility(self, component:GetCurrentCategory()) -- equivalent call inferred; original call site unknown
			self._Janitor:Add(component.CategoryChanged:Connect(function(p: string?)
				applyVisibility(self, p) -- equivalent call inferred; original call site unknown
			end))
		end
	end

	self._Janitor:Add(self.Instance.Activated:Connect(function()
		if not GameUtil.IsPrivateServer() then
			return
		end

		for _, v5 in v:GetAll() do
			v5.stateSelected = not v5.stateSelected
			v5.Instance:SetAttribute("Selected", v5.stateSelected)
			local v6

			if v5.stateSelected == true then
				v6 = v2.SELECTED
			else
				v6 = v2.DESELECTED
			end

			tweenButtonAppearance(v5, v6)
		end

		v.ToggleCollisionMode()
		local v5 = stateSelected and "Placed props will have collision enabled" or "Placed props will have collision disabled"
		NotificationController.Notify(v5)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v