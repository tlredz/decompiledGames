local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local Config = require(script.Parent.Config)
local DeadCalm = {
	Id = 0
}
local v = {}

function DeadCalm.Hold(player)
	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not (humanoid.RootPart and humanoid) then
		return
	end

	local animator = humanoid:FindFirstChild("Animator")

	if not animator then
		return
	end

	v.Stage = "Hold"
	local v2 = maid:Add(animator:LoadAnimation(script.Startup), "Stop")
	v2:Play()
	task.wait(Config.STARTUP_DUR)
	v2:Stop()
end

function DeadCalm.UnHold(p)
	DeadCalm.Cancel(p)
end

function DeadCalm.Cancel(_)
	maid:Clean()
	v.Stage = "Cancel"
end

return DeadCalm