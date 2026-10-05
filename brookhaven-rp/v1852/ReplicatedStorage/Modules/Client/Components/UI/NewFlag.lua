local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ProfileFlagController = require(ReplicatedStorage.Modules.Client.PlayerData.ProfileFlagController)
require(ReplicatedStorage.Modules.Client.PlayerFlags.PlayerFlag)
local ProfileFlags = require(ReplicatedStorage.Modules.Shared.PlayerData.ProfileFlags)
local NewUserDataController = require(ReplicatedStorage.Modules.Client.Util.NewUserDataController)
local newFlag = ReplicatedStorage.UiClone.NewFlag
local v = Component.new({
	Tag = "NewFlag"
})

local function validateSecondsAttribute(instance, p: string, value)
	if value == nil then
		return nil
	end

	if typeof(value) ~= "number" then
		warn((`NewFlag on {instance:GetFullName()}: attribute "{p}" must be a number, got {typeof(value)}`))
		return nil
	end

	if value > 32503680000 then
		warn((`NewFlag on {instance:GetFullName()}: attribute "{p}" value {value} looks like milliseconds; expected Unix seconds`))
		return nil
	else
		return value
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._indicator = nil
	self.time = 0
end

function v:_resolveFlag()
	local flag = self.Instance:GetAttribute("Flag")

	if typeof(flag) ~= "string" then
		warn((`NewFlag on {self.Instance:GetFullName()}: missing or invalid "Flag" attribute`))
		return nil
	end

	local v2 = ProfileFlags.GetByKey(flag)

	if v2 == nil then
		warn((`NewFlag on {self.Instance:GetFullName()}: unknown ProfileFlag key "{flag}"`))
		return nil
	end

	if ProfileFlags.IsClientClaimable(v2) then
		return v2
	end

	warn((`NewFlag on {self.Instance:GetFullName()}: ProfileFlag "{flag}" is not clientClaimable`))
	return nil
end

function v:_resolveParent()
	local target = self.Instance:FindFirstChild("Target")

	if target == nil or not target:IsA("ObjectValue") or target.Value == nil then
		return self.Instance
	end

	return target.Value
end

function v:_shouldShow(p2)
	if ProfileFlagController.IsCompleted(p2) then
		return false
	end

	local now = os.time()
	local v2 = validateSecondsAttribute(self.Instance, "ExpiresAt", self.Instance:GetAttribute("ExpiresAt"))

	if v2 ~= nil and v2 <= now then
		return false
	end

	local v3 = validateSecondsAttribute(self.Instance, "MinInstallDate", self.Instance:GetAttribute("MinInstallDate"))

	if v3 == nil then
		return true
	end

	local newUserData, _, v4 = NewUserDataController.GetNewUserData()
	return not not newUserData and v4 ~= nil and not (v3 < v4 / 1000)
end

function v:RenderSteppedUpdate(p)
	if self._indicator == nil then
		return
	end

	self.time += p
	local v2 = 0

	if self.time >= 3 then
		while self.time >= 3 do
			self.time -= 3
		end
	elseif self.time >= 2.9 then
		v2 = 1 - TweenService:GetValue((self.time - 2.9) / 0.1, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
	elseif self.time >= 2.7 then
		v2 = TweenService:GetValue((self.time - 2.7) / 0.2, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut) * 2 - 1
	elseif self.time >= 2.6 then
		v2 = -TweenService:GetValue((self.time - 2.6) / 0.1, Enum.EasingStyle.Circular, Enum.EasingDirection.In)
	end

	self._indicator.TextLabel.Position = UDim2.fromScale(v2 * 0.1 + 0.5, 0)
end

function v:_buildIndicator()
	local clone = newFlag:Clone()
	local showAbove = self.Instance:GetAttribute("ShowAbove")

	if (showAbove == nil or showAbove) == true then
		clone.AnchorPoint = Vector2.new(0.5, 1)
		clone.Position = UDim2.new(0.5, 0, 0, 0)
		clone.Bottom.Position = UDim2.new(0, 0, 0, 0)
		clone.Bottom.AnchorPoint = Vector2.new(0, 0)
		clone.Top.Position = UDim2.new(0, 0, 0.25, 0)
	else
		clone.AnchorPoint = Vector2.new(0.5, 0)
		clone.Position = UDim2.new(0.5, 0, 1, 0)
	end

	clone.Parent = self:_resolveParent()
	self._Janitor:Add(clone)
	self._indicator = clone
end

function v:_hideIndicator()
	local _indicator = self._indicator

	if _indicator == nil then
		return
	end

	self._indicator = nil
	local tween = TweenService:Create(
		_indicator,
		TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		{
			Size = UDim2.new(_indicator.Size.X.Scale, _indicator.Size.X.Offset, 0, 0)
		}
	)
	tween:Play()
	tween.Completed:Connect(function()
		_indicator:Destroy()
	end)
end

function v:Start()
	if not (self.Instance:IsA("TextButton") or self.Instance:IsA("ImageButton")) then
		warn((`NewFlag on {self.Instance:GetFullName()}: instance must be a GuiButton (TextButton or ImageButton)`))
		return
	end

	local _resolveFlag = self:_resolveFlag()

	if not (_resolveFlag ~= nil and self:_shouldShow(_resolveFlag)) then
		return
	end

	self:_buildIndicator()
	local instance = self.Instance
	self._Janitor:Add(instance.Activated:Connect(function()
		if self._indicator == nil then
			return
		end

		ProfileFlagController.Complete(_resolveFlag)
		self:_hideIndicator()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
	self._indicator = nil
end

return v