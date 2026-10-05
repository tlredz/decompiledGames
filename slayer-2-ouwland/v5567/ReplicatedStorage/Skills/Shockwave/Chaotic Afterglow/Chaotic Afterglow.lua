local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = ReplicatedStorage.CAM
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local ChaoticAfterglow = {
	Id = 0
}
local skill_stand_still = skills.holder.skill_stand_still
local chaoticAfterglowStartup = script.ChaoticAfterglowStartup
local chaoticAfterglowLoop = script.ChaoticAfterglowLoop
local chaoticAfterglowFinish = script.ChaoticAfterglowFinish

function ChaoticAfterglow.Hold(player)
	v:Clean()
	local humanoid = player.Character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local animator = humanoid:FindFirstChild("Animator")
	local id = ChaoticAfterglow.Id
	local clone = skill_stand_still:Clone()
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	v:Add(clone)
	clone.Parent = rootPart
	local track = animator:LoadAnimation(chaoticAfterglowStartup)
	v:Add(track)
	track:Play()
	task.wait(0.92)

	if id ~= ChaoticAfterglow.Id then
		return
	end

	local track2 = animator:LoadAnimation(chaoticAfterglowLoop)
	v:Add(track2)
	track2:Play()
	track2:AdjustSpeed(0.1)
	task.wait(0.8)

	if id ~= ChaoticAfterglow.Id then
		return
	end

	track2:AdjustSpeed(1)
end

function ChaoticAfterglow.UnHold(player)
	v:Clean()
	local animator = player.Character:FindFirstChild("Humanoid"):FindFirstChild("Animator")
	local id = ChaoticAfterglow.Id
	animator:LoadAnimation(chaoticAfterglowFinish):Play()
	task.wait(0.93)

	if id ~= ChaoticAfterglow.Id then
		return
	end

	ChaoticAfterglow.Cancel(player)
end

function ChaoticAfterglow.Cancel(_)
	v:Clean()
end

return ChaoticAfterglow