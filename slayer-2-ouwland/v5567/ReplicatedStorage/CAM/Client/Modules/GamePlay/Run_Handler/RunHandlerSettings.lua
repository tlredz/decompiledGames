local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.cleanit)
return {
	LifeCleaner = nil,
	SkillBeingPerformed = false,
	Shift_lock = 0,
	IsWalking = false,
	ActualShiftlockMode = 0,
	Is_Running = false,
	Toggled = false,
	RunToggles = false,
	DashArmed = false,
	run_speed = 25,
	shallow_water_run_speed = 20
}