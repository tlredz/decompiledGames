game:GetService("TweenService")
local Component = require(game.ReplicatedStorage.Modules.Component)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local TextUtil = require(game.ReplicatedStorage.Modules.Util.TextUtil)
local v = Component.new({
	Tag = "BossHealthBar"
})

local function commaValueRounded(p: number)
	return TextUtil.commaValue((math.round(p)))
end

local v2 = {
	{
		Color3.fromRGB(39, 202, 28):Lerp(Color3.fromRGB(255, 255, 255), 0.4),
		Color3.fromRGB(39, 202, 28),
		Color3.fromRGB(39, 202, 28):Lerp(Color3.fromRGB(0, 0, 0), 0.3)
	},
	{
		Color3.fromRGB(135, 41, 43):Lerp(Color3.fromRGB(255, 255, 255), 0.3),
		Color3.fromRGB(135, 41, 43),
		Color3.fromRGB(135, 41, 43):Lerp(Color3.fromRGB(0, 0, 0), 0.3)
	},
	{
		Color3.fromRGB(56, 56, 56):Lerp(Color3.fromRGB(255, 255, 255), 0.2),
		Color3.fromRGB(56, 56, 56),
		Color3.fromRGB(56, 56, 56):Lerp(Color3.fromRGB(0, 0, 0), 0.3)
	}
}

function v:GetRatio()
	local humanoid = self.humanoid
	local health = nil
	local maxHealth = nil

	if humanoid:IsA("Humanoid") then
		health = humanoid.Health
		maxHealth = humanoid.MaxHealth
	elseif humanoid:IsA("IntConstraintedValue") then
		health = humanoid.Value
		maxHealth = humanoid.MaxValue
	elseif humanoid:IsA("IntValue") then
		health = humanoid.Value
		maxHealth = humanoid.Parent:GetAttribute("MaxHealth")
	end

	return health / maxHealth, health, maxHealth
end

function v:GetHumanoidName()
	return self.humanoid.Parent.Name
end

function v:UpdateHealthText()
	local _, v3, v4 = self:GetRatio()

	if self.displayNameInline then
		self.healthLabel.Text = string.format(
			"%s (%s/%s)",
			self:GetHumanoidName(),
			TextUtil.commaValue((math.round(v3))),
			commaValueRounded(v4)
		)
	else
		self.healthLabel.Text = string.format("%s/%s", TextUtil.commaValue((math.round(v3))), commaValueRounded(v4))
	end
end

function v:UpdateRatio()
	local ratio, _, _ = self:GetRatio()
	self:UpdateHealthText()
	local v3 = ratio - self.currentRatio

	if v3 < 0 then
		local v4 = 0.2 * (1 + v3) + 0.2
		table.insert(self.values, {
			v3 / v4,
			v4,
			os.clock(),
			0,
			os.clock() + v4 * 1.5
		})
	else
		self.fakeRatio += v3
	end

	self.currentRatio = ratio
	self:UpdateRender()
end

function v:UpdateRender(p)
	local lastValues = self.lastValues
	local fakeRatio = self.fakeRatio
	local currentRatio = self.currentRatio

	if lastValues[1] == currentRatio and lastValues[2] == fakeRatio and not p then
		return
	end

	local _ = { currentRatio, fakeRatio }
	local v3

	if math.min(currentRatio, 1) >= math.min(fakeRatio, 1) or math.sqrt(fakeRatio ^ 2 - currentRatio ^ 2) <= 0.001 then
		if not (currentRatio < 0.999) then
			v3 = {
				{ 0, 1 },
				{ 1, 1 }
			}
		elseif currentRatio < 0.001 then
			v3 = {
				{ 0, 3 },
				{ 1, 3 }
			}
		else
			v3 = {
				{ 0, 1 },
				{ currentRatio, 1 },
				{ currentRatio + 0.001, 3 },
				{ 1, 3 }
			}
		end
	elseif fakeRatio < 0.999 then
		if currentRatio < 0.001 then
			v3 = {
				{ 0, 2 }
			}
		else
			v3 = {
				{ 0, 1 },
				{ currentRatio, 1 }
			}

			if currentRatio + 0.001 < fakeRatio then
				table.insert(v3, { currentRatio + 0.001, 2 })
			end
		end

		if not (fakeRatio < 0.001) then
			table.insert(v3, { fakeRatio, 2 })
			table.insert(v3, { fakeRatio + 0.001, 3 })
		end

		table.insert(v3, { 1, 3 })
	else
		v3 = currentRatio < 0.999 and {
			{ 0, 1 },
			{ currentRatio, 1 },
			{ currentRatio + 0.001, 2 },
			{ 1, 2 }
		} or {
			{ 0, 1 },
			{ 1, 1 }
		}
	end

	local bar = self.Instance.Border.Bar
	local v4 = { "AccentTop", "Fill", "AccentBottom" }

	for i = 1, 3 do
		local colorSequenceKeypoints = {}

		for _, v5 in pairs(v3) do
			table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(v5[1], v2[v5[2]][i]))
		end

		local v5 = i
		local _, _ = pcall(function()
			bar[v4[v5]].UIGradient.Color = ColorSequence.new(colorSequenceKeypoints)
		end)
	end
end

function v:ResetProperties()
	self.values = {}
	self.lastValues = { 1, 1 }
	self.currentRatio = 1
	self.fakeRatio = 1
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

function v:SetHumanoid(instance)
	local instance2 = self.Instance

	if self.humanoid == instance then
		return
	end

	if not instance then
		self:Close()
		return
	end

	self.humanoid = instance
	self.trove = Trove.new()

	local function healthChanged()
		self:UpdateRatio()
	end

	local nameLabel = instance2.NameLabel
	nameLabel.Visible = not self.displayNameInline

	if not self.displayNameInline then
		nameLabel.Text = self:GetHumanoidName()
	end

	local parent = instance.Parent

	if instance:IsA("Humanoid") then
		nameLabel.Text = instance.DisplayName
		self.trove:Add(instance:GetPropertyChangedSignal("Health"):Connect(healthChanged))
		self.trove:Add(instance:GetPropertyChangedSignal("MaxHealth"):Connect(healthChanged))
	elseif instance:IsA("IntConstraintedValue") then
		self.trove:Add(instance:GetPropertyChangedSignal("Value"):Connect(healthChanged))
		self.trove:Add(parent:GetAttributeChangedSignal("MaxValue"):Connect(healthChanged))
	elseif instance:IsA("IntValue") then
		self.trove:Add(instance:GetPropertyChangedSignal("Value"):Connect(healthChanged))
		self.trove:Add(parent:GetAttributeChangedSignal("MaxHealth"):Connect(healthChanged))

		if not parent:GetAttribute("MaxHealth") then
			warn("HealthBar parent does not have a MaxHealth Attribute!", parent:GetFullName())
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function reflectHealthEnabled()
		if instance.Parent:GetAttribute("HealthEnabled") == false then
			instance2.GroupTransparency = 1
		else
			instance2.GroupTransparency = 0
		end
	end

	reflectHealthEnabled() -- equivalent call inferred; original call site unknown
	self.trove:Add(instance.Parent:GetAttributeChangedSignal("HealthEnabled"):Connect(reflectHealthEnabled))
	local ratio, _, _ = self:GetRatio()
	self.fakeRatio = ratio
	self.currentRatio = ratio
	self:UpdateHealthText()
	instance2.Visible = true
end

function v:Construct()
	local instance = self.Instance
	self.healthLabel = instance.Border.HealthLabel
	self.displayNameInline = instance:GetAttribute("DisplayNameInline") == true
	self:ResetProperties()
end

function v:Start()
	local instance = self.Instance
	self:SetHumanoid(nil)
	local nameLabel = instance.NameLabel
	local shadow = nameLabel.Shadow
	nameLabel:GetPropertyChangedSignal("Text"):Connect(function()
		shadow.Text = nameLabel.Text
	end)
end

function v.Stop(_) end

function v:RenderSteppedUpdate(_)
	local humanoid = self.humanoid

	if not humanoid then
		return
	end

	if humanoid and not humanoid.Parent then
		return self:Close()
	end

	local values = {}
	local v4 = false

	for _, value in self.values do
		v4 = true

		if os.clock() < value[5] then
			value[3] = os.clock()
			table.insert(values, value)
		else
			local v5 = math.min(value[2] - value[4], os.clock() - value[3])

			if not (v5 < 0) then
				self.fakeRatio += value[1] * v5
				value[3] = os.clock()
				value[4] += v5
				table.insert(values, value)
			end
		end
	end

	if not v4 then
		self.fakeRatio = self.currentRatio
	end

	self.values = values
	self:UpdateRender(true)
end

return v