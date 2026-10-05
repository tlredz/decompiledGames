local MazeEntranceClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local ContentProvider = game:GetService("ContentProvider")
local flag = false
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://118898793065399"

function OpenGate(instance)
	if instance:GetAttribute("GateOpen") then
		return
	end

	instance:SetAttribute("GateOpen", true)
	local enterMaze = instance:WaitForChild("Functional"):WaitForChild("EnterMaze")
	enterMaze:AddTag("Interaction")
	enterMaze.PrimaryPart.ProximityAttachment.ProximityInteraction.Enabled = true
	local leftGate = instance:WaitForChild("Functional"):WaitForChild("Gates"):WaitForChild("LeftGate")
	local rightGate = instance:WaitForChild("Functional"):WaitForChild("Gates"):WaitForChild("RightGate")
	local pivot = leftGate:GetPivot()
	local pivot2 = rightGate:GetPivot()
	Client.TweenModule.new(function(p)
		local v = 50 * p
		leftGate:PivotTo(pivot * CFrame.Angles(0, math.rad(v), 0))
		rightGate:PivotTo(pivot2 * CFrame.Angles(0, math.rad(-v * 0.6), 0))
	end, 2, "Quad"):Play()
end

function RunCutscene(data)
	if flag or not (localPlayer.Character and localPlayer.Character.PrimaryPart) then
		return
	end

	local _ = data.Parent
	print("enter maze")
	local animator = localPlayer.Character:WaitForChild("Humanoid"):WaitForChild("Animator")
	local humanoidRootPart = localPlayer.Character:WaitForChild("HumanoidRootPart")
	local track = animator:LoadAnimation(animation)
	flag = true
	task.spawn(function()
		local cFrame = data.CameraPart.CFrame
		local total = 0

		while flag do
			local v = total / 5
			workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
			workspace.CurrentCamera.CFrame = cFrame * CFrame.Angles(math.rad(v * 15), 0, 0)
			workspace.CurrentCamera.FieldOfView = 40
			total += task.wait()
		end

		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		workspace.CurrentCamera.FieldOfView = 70
	end)
	local cFrame = data.PlayerPart.CFrame
	localPlayer.Character:PivotTo(cFrame)
	humanoidRootPart.Anchored = true
	Client.Sound.Play("Carnival4")
	track:Play()
	Client.TeleportingClient.Teleport("Halloween Maze", 5.5, {
		CoverType = "Halloween Maze",
		FadeDelay = 4.2,
		FadeDuration = 0.8
	})
	task.wait(5)
	track:Stop()
	task.wait(0.5)

	if humanoidRootPart then
		humanoidRootPart.Anchored = false
	end

	task.wait(0.5)
	flag = false
end

function MazeEntranceClient.EnterMaze(instance)
	local proximityInteraction = instance.PrimaryPart.ProximityAttachment.ProximityInteraction
	proximityInteraction.Enabled = false
	local parent = instance.Parent
	RunCutscene(parent)
	task.delay(2, function()
		proximityInteraction.Enabled = true
	end)
end

Client.InteractionHandler.RegisterInteraction("ExitMaze", function(_)
	if localPlayer.Character then
		Client.TeleportingClient.Teleport("MazeExit", nil, {
			CoverType = "Forest"
		})
	end
end)
Client.InteractionHandler.RegisterInteraction("EnterMaze", function(p)
	MazeEntranceClient.EnterMaze(p)
end)

function MazeEntranceAdded(instance)
	if not instance:IsDescendantOf(workspace) then
		return
	end

	task.spawn(function()
		if not workspace:GetAttribute("MazeUnlocked") then
			workspace:GetAttributeChangedSignal("MazeUnlocked"):Wait()
		end

		OpenGate(instance)
	end)
end

function MazeEntranceClient.Init()
	Client.Utility.ForAllTagged("MazeEntrance", MazeEntranceAdded)
	task.spawn(function()
		ContentProvider:PreloadAsync({ animation })
	end)
end

return MazeEntranceClient