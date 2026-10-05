local createVector = vector.create
local parent = script.Parent
local busy = parent:WaitForChild("Busy")
local humanoidRootPart = parent:WaitForChild("HumanoidRootPart")
local humanoid = parent:WaitForChild("Humanoid")
local UserInputService = game:GetService("UserInputService")
local data = game.Players.LocalPlayer:WaitForChild("Data")
local devilFruit = data:WaitForChild("DevilFruit")
local race = data:WaitForChild("Race")
_G.Swimming = false
local now = 0
local v = false
UserInputService.JumpRequest:Connect(function()
	if tick() - now < 0.5 or humanoidRootPart.Position.Y > -humanoidRootPart.Size.Y - 0.5 then
		return
	end

	v = true
	now = tick()
end)
local Effect = require(game.ReplicatedStorage.Effect)
local sharedIceWalk = Effect.new("Shared.IceWalk", true)
local Util = require(game.ReplicatedStorage.Util)
local bodyMover = Util.BodyMover
local v2 = nil

while true do
	local RunService = game:GetService("RunService")

	if not RunService.Heartbeat:Wait() then
		break
	end

	local v3 = humanoidRootPart.Position.Y < -500

	if v2 and v then
		v = false
		humanoid.WalkSpeed = 16
		v2:Disable()
		v2:Destroy()
		wait()
		humanoidRootPart.Velocity += Vector3.new(0, humanoid.JumpPower * 1.5, 0)
		v2 = nil
	elseif tick() - now > 0.5 then
		if v3 == false and devilFruit.Value == "Ice-Ice" and humanoidRootPart.Position.Y < -humanoidRootPart.Size.Y + 9 and humanoidRootPart.Position.Y > -2 and Util.Ray(
			humanoidRootPart.CFrame * createVector(0, 0, -3),
			createVector(0, -10, 0)
		) == nil and parent.Energy.Value >= 4 then
			game.ReplicatedStorage.Remotes.CommE:FireServer("IceWalk", humanoidRootPart.CFrame * createVector(0, 0, -2))
			sharedIceWalk:replicate({
				Position = humanoidRootPart.CFrame * createVector(0, 0, -2)
			})
		elseif humanoidRootPart.Position.Y < -humanoidRootPart.Size.Y and v3 == false then
			v2 = v2 or bodyMover.new(parent):Create("BodyPosition", {
				MaxForce = createVector(0, 300000, 0),
				Position = Vector3.new(0, -humanoidRootPart.Size.Y - 3, 0),
				Priority = 100
			})

			if race.Value == "Fishman" then
				humanoid.WalkSpeed = 62
			elseif devilFruit.Value ~= "" then
				humanoid.WalkSpeed = 8
			end
		elseif v2 then
			humanoid.WalkSpeed = 16
			v2:Disable()
			v2:Destroy()
			v2 = nil
		end
	end

	_G.Swimming = v2 ~= nil

	if _G.Swimming == false and busy.Value == false then
		humanoid.WalkSpeed = (_G.Running and 32 or 16) * (race.Value == "Mink" and 1.7 or 1)
	end
end