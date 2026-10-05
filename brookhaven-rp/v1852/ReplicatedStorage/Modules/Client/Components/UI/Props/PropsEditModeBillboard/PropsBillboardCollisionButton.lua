local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PropsBillboardCollisionButton"
})
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
local PropEditable = require(ReplicatedStorage.Modules.Client.Components.Props.PropEditable)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(62, 63, 63)

-- equivalent calls inferred from this helper; original call sites unknown
local function applyButtonAppearance(instance, flag: boolean)
	local v2

	if flag then
		v2 = color
	else
		v2 = color2
	end

	instance.BackgroundColor3 = v2
	instance.ImageColor3 = v2
	local icon = instance:FindFirstChild("Icon")

	if icon and (icon:IsA("ImageLabel") or icon:IsA("ImageButton")) then
		icon.ImageColor3 = v2
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance

	if not instance:IsA("ImageButton") then
		return
	end

	local currentSelectedPropEditable = PropEditable.GetCurrentSelectedPropEditable()

	if not currentSelectedPropEditable then
		return
	end

	local v2 = currentSelectedPropEditable.Instance:FindFirstChild("ChangeableCollision") ~= nil
	local isPrivateServer = GameUtil.IsPrivateServer()
	local v3 = v2 and isPrivateServer
	applyButtonAppearance(instance, v3) -- equivalent call inferred; original call site unknown
	local touch = currentSelectedPropEditable.Instance:FindFirstChild("Touch")

	local function updateCheckedState()
		if not v3 then
			instance:RemoveTag("Checked")
		elseif touch == nil or not (touch:IsA("BasePart") and touch.CanCollide) then
			instance:RemoveTag("Checked")
		else
			instance:AddTag("Checked")
		end
	end

	updateCheckedState()

	if v3 and touch ~= nil and touch:IsA("BasePart") then
		self._Janitor:Add(touch:GetPropertyChangedSignal("CanCollide"):Connect(updateCheckedState))
	end

	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		if v3 then
			if touch == nil or not touch:IsA("BasePart") then
				return
			end

			local v4 = not touch.CanCollide

			if v4 then
				instance:AddTag("Checked")
			else
				instance:RemoveTag("Checked")
			end

			currentSelectedPropEditable:ChangeCollision(v4)
		elseif isPrivateServer then
			NotificationController.NotifyCenter("This prop's collision cannot be changed")
		else
			NotificationController.NotifyCenter("Enabling Collision is only available on private servers")
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v