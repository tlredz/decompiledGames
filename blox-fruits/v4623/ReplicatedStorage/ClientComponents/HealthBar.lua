local TweenService = game:GetService("TweenService")
local Component = require(game.ReplicatedStorage.Modules.Component)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local v = Component.new({
	Tag = "HealthBar"
})
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function isBoss(instance)
	local instanceModel = instance and instance:FindFirstAncestorWhichIsA("Model")
	return instanceModel ~= nil and instanceModel:GetAttribute("IsBoss") == true
end

function v:GetHumanoidName()
	if self.Instance:GetAttribute("DisplayNameDisabled") then
		return ""
	end

	return self.Instance:GetAttribute("DisplayName") or self.humanoid:GetAttribute("DisplayName") or self.humanoid.Parent.Name
end

function v:UpdateHealthText()
	local health, v2, _, _, _ = self:GetHealth()
	local text = string.format("%s/%s", health, v2)

	if not self.Instance:GetAttribute("DisplayNameDisabled") then
		text = self:GetHumanoidName() .. " " .. text
	end

	self.nameLabel.Text = text
end

function v:GetHealth()
	local humanoid = self.humanoid
	local health = 1
	local maxHealth = 1
	local originalMaxHealth

	if humanoid then
		if humanoid:IsA("Humanoid") then
			health = humanoid.Health
			maxHealth = humanoid.MaxHealth
		elseif humanoid:IsA("IntConstrainedValue") then
			health = humanoid.Value
			maxHealth = humanoid.MaxValue
		elseif humanoid:IsA("IntValue") then
			health = humanoid.Value
			maxHealth = humanoid.Parent:GetAttribute("MaxHealth")
		end

		originalMaxHealth = humanoid.Parent:GetAttribute("OriginalMaxHealth") or maxHealth
	else
		originalMaxHealth = 1
	end

	local v2 = math.max(0, 1 - maxHealth / originalMaxHealth)
	local v3 = math.max(0, (health - v2) / originalMaxHealth)
	return health, maxHealth, originalMaxHealth, v3 ~= v3 and 0 or v3, v2 ~= v2 and 0 or v2
end

function v:SetHumanoid(instance)
	local instance2 = self.Instance

	if instance then
		local instanceModel = instance2 and instance2:FindFirstAncestorWhichIsA("Model")
		local v2

		if instanceModel == nil then
			v2 = false
		else
			v2 = instanceModel:GetAttribute("IsBoss") == true
		end

		if v2 then
			self:Close()
			return
		end
	end

	if self.humanoid == instance then
		instance2.Visible = instance ~= nil
		return
	end

	if not instance then
		self:Close()
		return
	end

	self.humanoid = instance

	if self.trove then
		self.trove:Destroy()
		self.trove = nil
	end

	self.trove = Trove.new()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function healthChanged(p)
		if not self.humanoid then
			return
		end

		local _, _, _, v2, v3 = self:GetHealth()
		self:UpdateHealthText()
		local uDim = UDim2.fromScale(v2, 1)
		local uDim2 = UDim2.fromScale(v3, 1)

		if p then
			self.fill.Size = uDim
			self.lockedFill.Size = uDim2
		else
			TweenService:Create(self.fill, tweenInfo, {
				Size = uDim
			}):Play()
			TweenService:Create(self.lockedFill, tweenInfo, {
				Size = uDim2
			}):Play()
		end
	end

	local parent = instance.Parent

	if instance:IsA("Humanoid") then
		self.trove:Add(instance:GetPropertyChangedSignal("Health"):Connect(healthChanged))
		self.trove:Add(instance:GetPropertyChangedSignal("MaxHealth"):Connect(healthChanged))
		self.trove:Add(parent:GetAttributeChangedSignal("OriginalMaxHealth"):Connect(healthChanged))
	elseif instance:IsA("IntConstraintedValue") then
		self.trove:Add(instance:GetPropertyChangedSignal("Value"):Connect(healthChanged))
		self.trove:Add(parent:GetAttributeChangedSignal("MaxValue"):Connect(healthChanged))
		self.trove:Add(parent:GetAttributeChangedSignal("OriginalMaxHealth"):Connect(healthChanged))
	elseif instance:IsA("IntValue") then
		self.trove:Add(instance:GetPropertyChangedSignal("Value"):Connect(healthChanged))
		self.trove:Add(parent:GetAttributeChangedSignal("MaxHealth"):Connect(healthChanged))
		self.trove:Add(parent:GetAttributeChangedSignal("OriginalMaxHealth"):Connect(healthChanged))

		if not parent:GetAttribute("MaxHealth") then
			warn("HealthBar parent does not have a MaxHealth Attribute!", parent:GetFullName())
		end
	else
		warn("Unsupported class for HealthBar Component:", instance2:GetFullName())
	end

	healthChanged(true) -- equivalent call inferred; original call site unknown
	self:UpdateHealthText()
	local instanceModel = instance2 and instance2:FindFirstAncestorWhichIsA("Model")
	instance2.Visible = instanceModel == nil or instanceModel:GetAttribute("IsBoss") ~= true
end

function v:ResetProperties()
	self.humanoid = nil
end

function v:Close()
	self.Instance.Visible = false

	if self.trove then
		self.trove:Destroy()
		self.trove = nil
	end

	self:ResetProperties()
end

function v:Construct()
	local instance = self.Instance
	self.fill = instance.Fill
	self.lockedFill = instance:FindFirstChild("LockedFill", true)
	self.nameLabel = instance.TextLabel
	self:ResetProperties()
end

function v:Start()
	local _ = self.Instance
	self:SetHumanoid(nil)
end

function v:Stop()
	if self.trove then
		self.trove:Destroy()
		self.trove = nil
	end
end

return v