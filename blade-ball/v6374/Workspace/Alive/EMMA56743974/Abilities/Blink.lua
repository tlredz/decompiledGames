local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local SettingsController = require(ReplicatedStorage2:WaitForChild("Controllers"):WaitForChild("SettingsController"))
local _ = workspace.CurrentCamera.FieldOfView
local mouseButton2 = Enum.UserInputType.MouseButton2
local v = 3
local flag = false
local playerGui = localPlayer:WaitForChild("PlayerGui")
local vector2 = playerGui:WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")
local module = require(game.ReplicatedStorage.Shared.Abilities[script.Name])
vector2.Image = module and module.iconId or ""

local function updateRemainingLabel(p)
	local counts = playerGui:WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("ready"):WaitForChild("counts")

	if counts then
		counts.Text = tostring(p)
	end
end

task.defer(updateRemainingLabel, v)
workspace.Dead.ChildAdded:Connect(function(child)
	if child == game.Players.LocalPlayer.Character then
		v = 3
	end
end)

local function ability()
	if v <= 0 then
		ReplicatedStorage2.Misc.error:Play()
		return
	end

	if localPlayer.Character.Parent ~= workspace.Alive or localPlayer.PlayerGui.Hotbar.Ability.Red.Visible ~= false then
		return
	end

	if humanoid.MoveDirection == createVector(0, 0, 0) then
		ReplicatedStorage2.Misc.error:Play()
		return
	end

	if localPlayer.Character.PrimaryPart:FindFirstChild("FREEZER") then
		ReplicatedStorage2.Misc.error:Play()
		return
	end

	v -= 1
	task.defer(updateRemainingLabel, v)
	task.spawn(function()
		while flag do
			task.wait(0.1)
		end

		flag = true
		task.wait(5.5)
		flag = false
		v += 1
		v = math.clamp(v, 0, 3)
		task.defer(updateRemainingLabel, v)
		ReplicatedStorage2.Remotes.VisualBindableCD:Fire(false, true, 0.01)
	end)
	local v2 = 16 + 5 * localPlayer.Upgrades[script.Name].Value
	local position = character.HumanoidRootPart.Position
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {
		workspace.Runtime,
		workspace.Alive,
		workspace.Dead,
		workspace.Balls
	}
	local v3 = {
		character.Head.CFrame,
		character["Left Arm"].CFrame,
		character["Right Arm"].CFrame,
		character["Right Leg"].CFrame,
		character["Left Leg"].CFrame,
		character.Torso.CFrame
	}
	ReplicatedStorage2.Remotes.Blinked:FireServer(position, v3)
	local raycastResult = workspace:Raycast(position, humanoid.MoveDirection.Unit * v2, raycastParams)

	if raycastResult and raycastResult.Instance then
		character.HumanoidRootPart.CFrame = CFrame.new(raycastResult.Position)
		return
	end

	character.HumanoidRootPart.CFrame += humanoid.MoveDirection.Unit * v2
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if SettingsController:UseBind(input, "Ability") then
		ability()
	end
end)
ReplicatedStorage2.Remotes.AbilityButtonPress.Event:Connect(function()
	ability()
end)
ReplicatedStorage2.Remotes.KeybindM2.OnClientEvent:Connect(function(p)
	if p then
		mouseButton2 = nil
	else
		mouseButton2 = Enum.UserInputType.MouseButton2
	end
end)