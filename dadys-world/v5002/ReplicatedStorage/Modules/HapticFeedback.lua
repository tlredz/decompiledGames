local HapticService = game:GetService("HapticService")
local HapticFeedback = {}
local v = true
local v2 = {
	Damage = {
		motor = Enum.VibrationMotor.Small,
		intensity = 0.4,
		duration = 0.15
	},
	HeavyDamage = {
		motor = Enum.VibrationMotor.Large,
		intensity = 0.5,
		duration = 0.25
	},
	Death = {
		motor = Enum.VibrationMotor.Large,
		intensity = 0.7,
		duration = 0.4
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function isVibrationSupported()
	local success, result = pcall(function()
		return HapticService:IsVibrationSupported(Enum.UserInputType.Gamepad1)
	end)
	return success and result == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isMotorSupported(p)
	local success, result = pcall(function()
		return HapticService:IsMotorSupported(Enum.UserInputType.Gamepad1, p)
	end)
	return success and result == true
end

local function triggerPulse(motor, intensity: number, duration: number)
	print("[HapticFeedback] triggerPulse called - enabled:", v)

	if not v then
		print("[HapticFeedback] Disabled, skipping")
		return
	end

	local vibrationSupported = isVibrationSupported() -- equivalent call inferred; original call site unknown
	print("[HapticFeedback] Vibration supported:", vibrationSupported)

	if not vibrationSupported then
		return
	end

	local motorSupported = isMotorSupported(motor) -- equivalent call inferred; original call site unknown
	print("[HapticFeedback] Motor supported:", motorSupported)

	if not motorSupported then
		return
	end

	local success, result = pcall(function()
		HapticService:SetMotor(Enum.UserInputType.Gamepad1, motor, intensity)
	end)
	print("[HapticFeedback] SetMotor result:", success, result)
	task.delay(duration, function()
		pcall(function()
			HapticService:SetMotor(Enum.UserInputType.Gamepad1, motor, 0)
		end)
	end)
end

function HapticFeedback.OnDamage()
	print("[HapticFeedback] OnDamage called!")
	local damage = v2.Damage
	triggerPulse(damage.motor, damage.intensity, damage.duration)
end

function HapticFeedback.OnHeavyDamage()
	local heavyDamage = v2.HeavyDamage
	triggerPulse(heavyDamage.motor, heavyDamage.intensity, heavyDamage.duration)
end

function HapticFeedback.OnDeath()
	local death = v2.Death
	triggerPulse(death.motor, death.intensity, death.duration)
end

function HapticFeedback.StopAll()
	if not isVibrationSupported() then
		return
	end

	pcall(function()
		HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0)
		HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large, 0)
	end)
end

function HapticFeedback.SetEnabled(flag: boolean)
	v = flag

	if not v then
		HapticFeedback.StopAll()
	end
end

function HapticFeedback.IsEnabled()
	return v
end

return HapticFeedback