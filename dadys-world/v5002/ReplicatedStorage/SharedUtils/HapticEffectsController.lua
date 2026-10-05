local RunService = game:GetService("RunService")

if not RunService:IsClient() then
	return {}
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HapticEffects = require(ReplicatedStorage.SharedData.HapticEffects)
local HapticEffectsController = {
	Enabled = true,
	GlobalIntensity = 50
}
local v = 0
local modules = ReplicatedStorage.Modules
local module = require(modules:FindFirstChild("MyDataController") or modules:FindFirstChild("ClientUI"):WaitForChild("MyDataController"))
module:onReplicaReady(function(object)
	if not (object and object.Data) then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		v = (module:getDataFromPath("Settings.HapticSlider") or 0) / 100

		for _, hapticEffect in pairs(HapticEffects) do
			hapticEffect.NeedsRefresh = true
		end
	end

	object:ListenToChange("Settings.HapticSlider", update)
	update() -- equivalent call inferred; original call site unknown
end)

local function getStrengthSetting()
	return v
end

function HapticEffectsController:SetGlobalIntensity(p2: number)
	self.GlobalIntensity = math.clamp(tonumber(p2) or 0, 0, 200)

	for _, hapticEffect in pairs(HapticEffects) do
		hapticEffect.NeedsRefresh = true
	end
end

local function toFloatCurve(list, p)
	local v2 = HapticEffectsController.GlobalIntensity / 100 * (p or v)
	local floatCurveKeys = {}

	for _, v3 in ipairs(list) do
		local v4 = v3[1]
		local v5 = math.clamp(v3[2] * v2, 0, 1)
		table.insert(floatCurveKeys, FloatCurveKey.new(v4, v5, Enum.KeyInterpolationMode.Linear))
	end

	return floatCurveKeys
end

function HapticEffectsController:CloneWaveform(p, p2: number?)
	return (toFloatCurve(p, p2))
end

function HapticEffectsController:Create(name: string, p: number?)
	local hapticEffect = HapticEffects[name]

	if not (hapticEffect and hapticEffect.data) then
		print("Could not find haptic effect for style: " .. name)
		return
	end

	local effect = hapticEffect.Effect

	if not effect then
		effect = Instance.new("HapticEffect")
		effect.Type = Enum.HapticEffectType.Custom
		effect.Looped = false
		effect.Name = name
		effect.Parent = workspace
		hapticEffect.NeedsRefresh = true
		hapticEffect.Effect = effect
	end

	if hapticEffect.NeedsRefresh then
		effect:Stop()
		hapticEffect.NeedsRefresh = false
		effect:SetWaveformKeys(self:CloneWaveform(hapticEffect.data, p))
	end

	return effect
end

function HapticEffectsController:Play(p: string, p2: number?)
	if not HapticEffectsController.Enabled or (p2 or v) <= 0 then
		return
	end

	local v2 = self:Create(p, p2)

	if v2 then
		v2:Stop()
		v2:Play()
	end

	return v2
end

local function updatePreferredInput()
	if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
		HapticEffectsController:SetGlobalIntensity(80)
	elseif UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
		HapticEffectsController:SetGlobalIntensity(100)
	else
		HapticEffectsController:SetGlobalIntensity(0)
	end
end

UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(updatePreferredInput)
task.spawn(updatePreferredInput)
return HapticEffectsController