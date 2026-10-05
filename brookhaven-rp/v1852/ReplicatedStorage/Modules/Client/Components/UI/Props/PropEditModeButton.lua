local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PropEditModeButton"
})
local TweenService = game:GetService("TweenService")
local _ = {
	TOGGLE_EDIT_MODE = "ToggleEditMode",
	PROP_ON_PROP_ON = "PropOnPropOn",
	PROP_ON_PROP_OFF = "PropOnPropOff"
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
local v3 = true

function v.IsSelectionMode()
	return v3
end

function v.SetSelectionMode(flag: boolean)
	v3 = flag
end

function v.ToggleSelectionMode()
	v3 = not v3
	props:FireServer("ToggleEditMode")

	if v3 then
		props:FireServer("PropOnPropOff")
	else
		props:FireServer("PropOnPropOn")
	end
end

local function tweenButtonAppearance(p, SELECTED)
	local instance = p.Instance
	local icon = p.Instance:FindFirstChild("Icon")

	if instance then
		TweenService:Create(instance, tweenInfo, {
			BackgroundColor3 = SELECTED.ImageColor3
		}):Play()
	end

	if icon then
		TweenService:Create(icon, tweenInfo, {
			ImageColor3 = SELECTED.ImageColor3
		}):Play()
	end

	if SELECTED.Checked then
		p.Instance:AddTag("Checked")
	else
		p.Instance:RemoveTag("Checked")
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
	props = ReplicatedStorage.RE:WaitForChild("Props")
end

function v:Start()
	if not self.Instance:IsA("ImageButton") then
		return
	end

	self.stateSelected = self.Instance:GetAttribute("Selected")
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		for _, v4 in v:GetAll() do
			v4.Instance:SetAttribute("Selected", not v4.stateSelected)
			v4.stateSelected = not v4.stateSelected
			local SELECTED = v4.stateSelected == true and v2.SELECTED or v2.DESELECTED
			tweenButtonAppearance(v4, SELECTED)
		end

		v.ToggleSelectionMode()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v