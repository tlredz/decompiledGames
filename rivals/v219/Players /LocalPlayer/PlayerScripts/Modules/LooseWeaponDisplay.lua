local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.MonetizationLibrary)
local Spring = require(ReplicatedStorage.Modules.Spring)
local StaticViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("StaticModel"):WaitForChild("StaticViewModel"))
local Equipment = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Equipment"))
local looseWeaponDisplayParticles = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("LooseWeaponDisplayParticles")
local LooseWeaponDisplay = {}
LooseWeaponDisplay.__index = LooseWeaponDisplay

function LooseWeaponDisplay.new(model)
	local self = setmetatable({}, LooseWeaponDisplay)
	self.Model = model
	self.CurrentWeapon = nil
	self._primary = self.Model:WaitForChild("Primary")
	self._owned_model = self.Model:WaitForChild("Owned")
	self._origin = self._primary.CFrame
	self._static_viewmodel = nil
	self._proximity_prompt = Instance.new("ProximityPrompt")
	self._is_animating = nil
	self._animation_tick = 0
	self._spin_spring = Spring.new(1, 1, 5)
	self._return_to_normal_progress = 1
	self._return_to_normal_start = self._origin
	self._scale = 1
	self._proximity_prompt_object_text = nil
	self._proximity_prompt_action_text = nil
	self._proximity_prompt_next_update = 0
	self._is_locked = false
	self:_Init()
	return self
end

function LooseWeaponDisplay:SetScale(scale)
	self._scale = scale

	if self._static_viewmodel then
		self._static_viewmodel:ScaleTo(3 * self._scale)
	end
end

function LooseWeaponDisplay:SetProximityPromptData(proximity_prompt_object_text, proximity_prompt_action_text)
	self._proximity_prompt_object_text = proximity_prompt_object_text
	self._proximity_prompt_action_text = proximity_prompt_action_text
	self:_UpdateProximityPrompt()
end

function LooseWeaponDisplay:SetLocked(is_locked)
	if is_locked == self._is_locked then
		return
	end

	self._is_locked = is_locked

	if self._static_viewmodel then
		self._static_viewmodel:SetLocked(self._is_locked)
	end
end

function LooseWeaponDisplay:ChangeWeapon(p)
	self.CurrentWeapon = self.Model:GetAttribute("PriorityWeapon") or p or nil

	if self._static_viewmodel then
		self._static_viewmodel:Destroy()
		self._static_viewmodel = nil
	end

	self._owned_model.Parent = self.Model
	self._proximity_prompt.Parent = nil
	self._proximity_prompt:RemoveTag("LobbyOpenPagePrompt")
	self._proximity_prompt:SetAttribute("PageName", nil)
	self._proximity_prompt:SetAttribute("ShopViewBundleName", nil)

	if not self.CurrentWeapon then
		self:_SetAnimating(false)
		return
	end

	self._owned_model.Parent = nil
	self._static_viewmodel = StaticViewModel.new(self.CurrentWeapon)
	self._static_viewmodel:DeleteAnimationContextSubModels("ShowInEquipment")
	self._static_viewmodel:ScaleTo(3 * self._scale)
	self._static_viewmodel:SetLocked(self._is_locked)
	self._static_viewmodel:PivotTo(self._origin)
	self._static_viewmodel:SetParent(self.Model)
	self:_SetAnimating(false)
	self._proximity_prompt.Parent = self._primary
	self:_UpdateProximityPrompt()
end

function LooseWeaponDisplay:Update(p)
	if self._is_animating then
		self._animation_tick += p * 0.5
		local cframe = CFrame.Angles(
			0,
			self._spin_spring.Value * 3.141592653589793 * 2 + self._animation_tick % 6.283185307179586,
			0
		)
		local vector2 = Vector3.new(0, self._spin_spring.Value, 0)
		self._static_viewmodel:PivotTo(self._origin * self._primary.CFrame.Rotation:Inverse() * cframe * self._primary.CFrame.Rotation + vector2)

		if self._static_viewmodel then
			self._static_viewmodel:Update(p)
		end

		if tick() > self._proximity_prompt_next_update then
			self._proximity_prompt_next_update = tick() + 1
			self:_UpdateProximityPrompt()
		end
	elseif self._static_viewmodel and self._return_to_normal_progress < 1 then
		self._return_to_normal_progress = math.min(1, self._return_to_normal_progress + p * 0.25)
		self._static_viewmodel:PivotTo(self._return_to_normal_start:Lerp(
			self._origin,
			TweenService:GetValue(self._return_to_normal_progress, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		))
	end
end

function LooseWeaponDisplay:_UpdateProximityPrompt()
	self._proximity_prompt.ObjectText = typeof(self._proximity_prompt_object_text) == "function" and self._proximity_prompt_object_text() or self._proximity_prompt_object_text or self.CurrentWeapon or ""
	self._proximity_prompt.ActionText = typeof(self._proximity_prompt_action_text) == "function" and self._proximity_prompt_action_text() or self._proximity_prompt_action_text or "View"
end

function LooseWeaponDisplay:_SetAnimating(p)
	self._is_animating = p

	if p then
		self._spin_spring.Value = 0
		self._animation_tick = 0
	else
		self._return_to_normal_progress = 0
		self._return_to_normal_start = self._static_viewmodel and self._static_viewmodel:GetPivot() or CFrame.identity
	end

	for _, emitter in pairs(self._primary:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = p
		end
	end

	self:_UpdateProximityPrompt()
end

function LooseWeaponDisplay:_Setup()
	self._proximity_prompt.ClickablePrompt = true
	self._proximity_prompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
	self._proximity_prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	self._proximity_prompt.HoldDuration = 0
	self._proximity_prompt.MaxActivationDistance = 10
	self._proximity_prompt.KeyboardKeyCode = Enum.KeyCode.Q
	self._proximity_prompt.RequiresLineOfSight = false
	self._proximity_prompt.Style = Enum.ProximityPromptStyle.Custom
	self._primary.CFrame += createVector(0, 2.5, 0)

	for _, child in pairs(looseWeaponDisplayParticles:GetChildren()) do
		local clone = child:Clone()
		clone.Parent = self._primary
	end
end

function LooseWeaponDisplay:_Init()
	self._proximity_prompt.Triggered:Connect(function()
		Equipment:Open()
		Equipment:SelectWeapon(self.CurrentWeapon)
	end)
	self._proximity_prompt.PromptShown:Connect(function()
		self:_SetAnimating(true)
	end)
	self._proximity_prompt.PromptHidden:Connect(function()
		self:_SetAnimating(false)
	end)
	self:_Setup()
	self:_UpdateProximityPrompt()
	self:ChangeWeapon(nil)
end

return LooseWeaponDisplay