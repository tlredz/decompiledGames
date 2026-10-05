local v = 30
game:GetService("RunService")
game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(game.ReplicatedStorage.Util)
local _ = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local character = localPlayer.Character
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character.HumanoidRootPart
local flag = false
local v2 = false
humanoid.StateChanged:Connect(function(_, p)
	if p == Enum.HumanoidStateType.Landed or p == Enum.HumanoidStateType.Running and humanoid.FloorMaterial ~= Enum.Material.Air then
		v2 = false
		flag = false
	elseif p == Enum.HumanoidStateType.Freefall or p == Enum.HumanoidStateType.Jumping then
		v2 = true
	end
end)
humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
	if humanoid.FloorMaterial == Enum.Material.Air then
		v2 = true
		return
	end

	v2 = false
	flag = false
end)

local function jumped()
	game.ReplicatedStorage.PlayerJumpAttempted:Fire()

	if not v2 or flag then
		return
	end

	local value

	if localPlayer.Data.Race.Value == "Cyborg" and localPlayer.Character and localPlayer.Character:FindFirstChild("RaceTransformed") and localPlayer.Character.RaceTransformed.Value and localPlayer.Data.Race:FindFirstChild("A") and localPlayer.Data.Race.A.Value >= 1 then
		value = localPlayer.Data.Race.A.Value
	else
		value = false
	end

	local v3 = Util.Ray(
		humanoidRootPart.Position,
		Vector3.new(0, -humanoidRootPart.Size.Y * 1.5 * 2 - 10),
		{ workspace.Characters, workspace.Enemies }
	) and true or false
	local v4 = value and value > 1 and 1 or 0.825
	local v5 = false

	if value then
		local Global = require(game.ReplicatedStorage.Global)

		if (Global.OM.active or value > 1) and v3 then
			local now = tick()
			local Global2 = require(game.ReplicatedStorage.Global)
			v5 = now - (Global2.lastCyborgJump or 0) > 1.666 or false
		end
	end

	local v6 = humanoid.JumpPower ^ 2 / 392.4
	local v7 = 3 + (character:FindFirstChild("HydraRig") and 8 or 0)
	local ray = Util.Ray(
		humanoidRootPart.Position,
		Vector3.new(0, -v6 + v7 - humanoid.HipHeight - humanoidRootPart.Size.Y / 2, 0),
		{ character }
	)

	if ray then
		local _ = ray.CanCollide
	end

	if localPlayer.Data.Race.Value == "Skypiea" and localPlayer.Data.Race:FindFirstChild("Evolved") then
		v = 10
	else
		v = 30
	end

	if localPlayer.Character.Humanoid.Health <= 0 or humanoid.Sit or character.Busy.Value and not character:GetAttribute("NoTransform") then
		return
	end

	local Global = require(game.ReplicatedStorage.Global)

	if not Global.Swimming then
		local Global2 = require(game.ReplicatedStorage.Global)

		if not (Global2.Dodging or character.Stun.Value > 0) then
			if not character:FindFirstChild("DoorMode") and (character:FindFirstChild("Phoenix") or humanoidRootPart:FindFirstChild("MagnetEnableFlight") or character:FindFirstChild("GravityFlight") or character:FindFirstChild("FalconFlight") or character:FindFirstChild("Dragon") or character:FindFirstChild("Flamingo")) then
				return
			end

			if character.Energy.Value < v then
				return
			end

			flag = true
			game.ReplicatedStorage.Remotes.CommE:FireServer("DoubleJump", v5)
			game.ReplicatedStorage.PlayerDoubleJumped:Fire()
			Util.Anims:Get(character, "DoubleJump"):Play()

			if v5 then
				humanoid.JumpPower += v4 * 125
				Effect.new("RaceAwakenings.CyborgJump"):replicate({
					ID = 1,
					CFrame = humanoidRootPart.CFrame,
					RootPart = humanoidRootPart,
					Strong = value > 1
				})
				local Global3 = require(game.ReplicatedStorage.Global)
				Global3.lastCyborgJump = tick()
				local Global4 = require(game.ReplicatedStorage.Global)
				Global4.mobilityCooldown = tick()
			end

			humanoidRootPart.Velocity = Vector3.new(
				humanoidRootPart.Velocity.X,
				humanoid.JumpPower * 1.4,
				humanoidRootPart.Velocity.Z
			)

			if v5 then
				humanoid.JumpPower -= v4 * 125
			end
		end
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed and not UserInputService.GamepadEnabled then
		return
	end

	if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then
		jumped()
	end
end)
wait(1)
wait(0.5)
local touchGui = UserInputService.TouchEnabled and playerGui:WaitForChild("TouchGui", 10)

if touchGui then
	touchGui:WaitForChild("TouchControlFrame"):WaitForChild("JumpButton").MouseButton1Down:connect(jumped)
end