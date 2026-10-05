local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local Health = {}
Health.__index = Health

function Health.new(fighterInterface)
	local self = setmetatable({}, Health)
	self.FighterInterface = fighterInterface
	self.DamageVignette = self.FighterInterface.Frame:WaitForChild("DamageVignette")
	self.DamageVignettePermanent = self.DamageVignette:WaitForChild("Permanent")
	self.HealVignette = self.FighterInterface.Frame:WaitForChild("HealVignette")
	self.Frame = self.FighterInterface.BottomRight.Container:WaitForChild("Health")
	self.ContainerFrame = self.Frame:WaitForChild("Container")
	self.ContainerBackground = self.ContainerFrame:WaitForChild("Background")
	self.ContainerBar = self.ContainerFrame:WaitForChild("Bar")
	self.ContainerBarText = self.ContainerBar:WaitForChild("Value"):WaitForChild("Title")
	self._last_health_tween = nil
	self._last_health_alpha = nil
	self._hurt_effect_hash = 0
	self._heal_effect_hash = 0
	self:_Init()
	return self
end

function Health:HurtEffect(p)
	if not self.FighterInterface:IsActive() then
		return
	end

	local v = p[utf8.char(0)] / self.FighterInterface.ClientFighter.Entity.Humanoid.Health

	if v == 0 then
		return
	end

	task.spawn(function()
		self.FighterInterface.DamageIndicators:Create(p)
	end)
	self._hurt_effect_hash += 1
	local _hurt_effect_hash = self._hurt_effect_hash
	local v2 = 0.5 - 0.5 * v
	task.spawn(Utility.RenderstepForLoop, Utility, 0, 100, 4, function(p2)
		if _hurt_effect_hash ~= self._hurt_effect_hash then
			return true
		end

		local v3 = p2 / 100
		self.DamageVignette.ImageTransparency = v2 + (1 - v2) * v3
	end)
end

function Health:HealEffect(p)
	if not self.FighterInterface:IsActive() then
		return
	end

	self._heal_effect_hash += 1
	local _heal_effect_hash = self._heal_effect_hash
	local v = math.clamp(p / 10, 0, 1)
	self.FighterInterface:CreateSound("rbxassetid://17138490999", v * 0.5, 1, script, true, 10)
	local v2 = 1 - v * 1
	task.spawn(Utility.RenderstepForLoop, Utility, 0, 100, 4, function(p2)
		if _heal_effect_hash ~= self._heal_effect_hash then
			return true
		end

		local v3 = p2 / 100
		self.HealVignette.ImageTransparency = v2 + (1 - v2) * v3
	end)
end

function Health:UpdateParent()
	task.defer(pcall, function()
		self.Frame.Visible = PlayerDataController:GetSetting("Health Bar Display") ~= "Disabled"
		self.Frame.Parent = PlayerDataController:GetSetting("Health Bar Display") == "Bottom Center" and self.FighterInterface.BottomCenter.Container or PlayerDataController:GetSetting("Health Bar Display") == "Bottom Left" and self.FighterInterface.BottomLeft.Container or self.FighterInterface.BottomRight.Container
	end)
end

function Health:Refresh()
	if self.FighterInterface.BottomLeft.Frame.Visible then
		self:_Update()
	else
		self.DamageVignettePermanent.ImageTransparency = 1
	end
end

function Health:Destroy()
	self._hurt_effect_hash += 1
	self._heal_effect_hash += 1
end

function Health:_Update(p)
	if self._last_health_tween then
		self._last_health_tween:Pause()
		self._last_health_tween = nil
	end

	local isAprilFools = self.FighterInterface.ClientFighter:Get("IsAprilFools")
	local maxHealth = self.FighterInterface.ClientFighter:GetMaxHealth()
	local health

	if isAprilFools then
		health = math.max(math.min(1, maxHealth), maxHealth * math.random())
	else
		health = self.FighterInterface.ClientFighter:GetHealth()
	end

	local last_health_alpha = math.clamp(health / maxHealth, 0, 1)
	local lerped = Color3.fromRGB(255, 50, 50):Lerp(
		Color3.fromRGB(255, 215, 0):Lerp(Color3.fromRGB(100, 255, 50), last_health_alpha),
		last_health_alpha
	)
	local color = Color3.new(lerped.R / 2, lerped.G / 2, lerped.B / 2)
	local color2 = Color3.new(lerped.R / 3, lerped.G / 3, lerped.B / 3)
	self.DamageVignettePermanent.ImageTransparency = last_health_alpha > 0.5 and 1 or last_health_alpha * 2
	self.ContainerFrame.BackgroundColor3 = color
	self.ContainerBackground.BackgroundColor3 = color2
	self.ContainerBar.BackgroundColor3 = lerped
	self.ContainerBar.Visible = last_health_alpha > 0
	self.ContainerBarText.Text = health >= 1 and Utility:PrettyNumber((math.ceil(health))) or ""
	local uDim = UDim2.new(math.max(0.073, last_health_alpha), 0, 1, 0)

	if p then
		self.ContainerBar.Size = uDim
	else
		local v2 = self._last_health_alpha and not (last_health_alpha < self._last_health_alpha) and 0.5 or 1
		self._last_health_tween = TweenService:Create(
			self.ContainerBar,
			TweenInfo.new(0.5 / v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				Size = uDim
			}
		)
		self._last_health_tween:Play()
	end

	self._last_health_alpha = last_health_alpha
end

function Health:_Setup()
	local uDim = UDim2.new(1, 0, 1, GuiService:GetGuiInset().Y)
	self.HealVignette.Size = uDim
	self.DamageVignette.Size = uDim
end

function Health:_Init()
	self.FighterInterface.BottomLeft.Frame:GetPropertyChangedSignal("Visible"):Connect(function()
		self:Refresh()
	end)
	self:_Setup()
	self:_Update(true)
	self:UpdateParent()
end

return Health