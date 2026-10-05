local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Network = require(ReplicatedStorage.Modules.Network)
local Janitor = require(ReplicatedStorage.Modules.Janitor)
local ScreenTextController = require(ReplicatedStorage.Modules.ScreenTextController)
local v = ScreenTextController:Init(
	localPlayer.PlayerGui:WaitForChild("Tools"):WaitForChild("GiggleSpray"),
	script.TextLabel
)
local maid = nil
local v2 = {
	[Enum.HumanoidStateType.Jumping] = true,
	[Enum.HumanoidStateType.Freefall] = true,
	[Enum.HumanoidStateType.Landed] = true,
	[Enum.HumanoidStateType.Seated] = true
}
local v3 = {
	"Ha!",
	"HA!",
	"HA! HA!",
	"HEH!"
}
Network:listen("Tool/GiggleSprayed", function(duration)
	if maid then
		maid:Destroy()
		maid = nil
	end

	if not localPlayer.Character then
		return
	end

	v:BurstForDuration(duration, v3, { Color3.new(0, 0, 0), Color3.new(1, 0, 0), Color3.new(0, 1, 0) }, 40, 72, 1, 0.3)
	local humanoid = localPlayer.Character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChild("Animator")
	local track = animator and animator:LoadAnimation(script.Animations.LaughWalk)
	local track2 = animator and animator:LoadAnimation(script.Animations.LaughIdle)
	track:AdjustSpeed(4)
	track2:AdjustSpeed(4)

	if not (humanoid and animator and track) then
		return
	end

	maid = Janitor.new()
	track2:Play(0.1)

	local function updateWalkAnimation()
		local state = humanoid:GetState()
		local v4

		if humanoid.MoveDirection.Magnitude > 0.5 then
			v4 = not v2[state]
		else
			v4 = false
		end

		if track.IsPlaying ~= v4 then
			if v4 then
				track2:Stop(0.1)
				track:Play(0.1)
			else
				track2:Play(0.1)
				track:Stop(0.1)
			end
		end
	end

	updateWalkAnimation()
	maid:Add(humanoid.StateChanged:Connect(updateWalkAnimation))
	maid:Add(humanoid.Running:Connect(updateWalkAnimation))
	maid:Add(track, "Stop")
	maid:Add(track2, "Stop")
	task.delay(duration, function()
		if maid then
			maid:Destroy()
			maid = nil
		end
	end)
end)