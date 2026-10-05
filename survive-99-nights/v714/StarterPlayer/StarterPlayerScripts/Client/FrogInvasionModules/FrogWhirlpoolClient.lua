local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local flag = false
local flag2 = false

function ExitFrogCave()
	print("exit frog cave")
	Client.TeleportingClient.Teleport("FrogWhirlpoolCF", 1, {
		CoverType = "Forest"
	})
	task.wait(1.2)
	Client.Sound.Play("Splash", {
		Volume = 0.6,
		Replicate = true,
		Duplicate = true,
		ReplicationProperties = {
			Instance = localPlayer.Character.Head,
			Volume = 0.5
		}
	})
	Client.Events.FrogCaveTeleportDone:FireServer()
end

local FrogWhirlpoolClient = {
	ExitFrogCave = ExitFrogCave
}

function RunWhirlpoolTeleportAnim()
	Client.Sound.Play("Whirlpool", {
		Volume = 0.6,
		Replicate = true,
		Duplicate = true,
		ReplicationProperties = {
			Instance = localPlayer.Character.Head,
			Volume = 0.5
		}
	})
	task.spawn(function()
		local fieldOfView = workspace.CurrentCamera.FieldOfView
		local tweenModule = Client.TweenModule.new(function(p)
			if not flag2 then
				return true
			end

			workspace.CurrentCamera.FieldOfView = fieldOfView + p * 50
		end, 1, "Quad", "Out")
		tweenModule:BindToComplete(function()
			workspace.CurrentCamera.FieldOfView = fieldOfView
		end)
		tweenModule:Play()
	end)
	task.spawn(function()
		local total = 0

		while flag2 do
			local v = task.wait()
			total += v

			if not flag2 then
				break
			end

			workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * CFrame.Angles(
				math.rad(200 * v),
				math.rad(-300 * v),
				0
			)
		end

		Client.Sound.Play("EnteredFrogCave", {
			Volume = 0.6,
			Replicate = true,
			Duplicate = true,
			ReplicationProperties = {
				Instance = localPlayer.Character.Head,
				Volume = 0.5
			}
		})
	end)
end

function ConnectTouchZone(instance)
	local function teleport()
		if flag then
			return
		end

		flag = true
		task.delay(2, function()
			flag = false
		end)
		flag2 = true
		RunWhirlpoolTeleportAnim()
		Client.TeleportingClient.Teleport("FrogCaveCF", 1.44, {
			CoverType = "Frog Cave",
			FadeDelay = 0.25,
			FadeDuration = 1
		})
		task.spawn(function()
			task.wait(1.44)
			flag2 = false
			workspace.CurrentCamera.CFrame = localPlayer.Character:GetPivot() * CFrame.new(0.5235987755982988, 0, 0) * CFrame.new(
				0,
				0,
				10
			)
			Client.Events.FrogCaveTeleportDone:FireServer()
		end)
	end

	instance.Parent = workspace.Particles

	for _, child in pairs(instance:GetChildren()) do
		child.Touched:Connect(function(otherPart)
			if not localPlayer.Character then
				return
			end

			if otherPart and otherPart == localPlayer.Character:FindFirstChild("HumanoidRootPart") then
				teleport()
			end
		end)
	end
end

function WhirlpoolAdded(instance)
	local whirlpool = instance:WaitForChild("Whirlpool"):WaitForChild("Whirlpool")
	local pivot = whirlpool:GetPivot()
	local touchZone = instance:WaitForChild("Whirlpool"):WaitForChild("TouchZone")
	ConnectTouchZone(touchZone)
	task.spawn(function()
		instance:WaitForChild("Whirlpool"):WaitForChild("Whirlpool"):WaitForChild("SoundMesh"):WaitForChild("Sound"):Play()
	end)
	task.spawn(function()
		local total = 0

		while true do
			total += task.wait()
			local v = total * -400
			whirlpool:PivotTo(pivot * CFrame.Angles(0, math.rad(v), 0))
		end
	end)
end

function FrogWhirlpoolClient.Init()
	Client.Utility.ForAllTagged("FrogWhirlpool", WhirlpoolAdded)
end

return FrogWhirlpoolClient