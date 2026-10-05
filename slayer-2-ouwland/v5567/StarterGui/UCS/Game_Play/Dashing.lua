local localPlayer = game.Players.LocalPlayer
local Skill_Controller = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Skill_Controller"))
local Combat_presets = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Combat_presets"))
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local UserInputService = game:GetService("UserInputService")
local InputHandler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Components"):WaitForChild("Client"):WaitForChild("InputHandler"))
local Dash_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("GamePlay"):WaitForChild("Dash_Handler"))
local cleanit = require(game.ReplicatedStorage.Packages.cleanit)
local DataValue = require(game.ReplicatedStorage.CAM.Client.Modules.DataValue)
local SettingsKeys = require(game.ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
local Run_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("GamePlay"):WaitForChild("Run_Handler"))

if Dash_Handler.LifeCleaner ~= nil then
	Dash_Handler.LifeCleaner:Clean()
end

local maid = cleanit.new()
Dash_Handler.LifeCleaner = maid
local humanoid = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")
local Skill_Info = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("PlayerProfile"):WaitForChild("Skill_Info"))
local Stats = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("SkillService"):WaitForChild("Stats"))
local v = false
local doubleJump = Skill_Info["Double Jump"]
local skillTreeUnlockedList = Utility.GetData(localPlayer, true):WaitForChild("SkillTreeUnlockedList")

-- equivalent calls inferred from this helper; original call sites unknown
local function refresh()
	v = Stats.IsSkillUnlocked(localPlayer, "Double Jump")
end

local child = skillTreeUnlockedList:FindFirstChild(doubleJump.Category)

if child then
	child.Changed:Connect(refresh)
else
	skillTreeUnlockedList.ChildAdded:Connect(function(child2)
		if child2.Name == doubleJump.Category then
			child2.Changed:Connect(refresh)
			refresh() -- equivalent call inferred; original call site unknown
		end
	end)
end

refresh() -- equivalent call inferred; original call site unknown
local tick2 = tick
local now = 0
local v2 = false
humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
	if humanoid.FloorMaterial ~= Enum.Material.Air then
		v2 = false
	end
end)
maid:Add(InputHandler.ListenTo("Jump", function(p, p2)
	if p ~= "Down" or p2 then
		return
	end

	if tick2() - now < 1 and tick2() - now > 0.1 and (humanoid.FloorMaterial == nil or humanoid.FloorMaterial == Enum.Material.Air) and v2 == false then
		doDoubleJump()
	else
		now = tick2()
	end
end))
local find = table.find
local v3 = {
	Enum.KeyCode.W,
	Enum.KeyCode.A,
	Enum.KeyCode.S,
	Enum.KeyCode.D
}

function doDoubleJump()
	if not v then
		return
	end

	if Skill_Controller.Attempt_Hold("Double Jump", "Space") == true then
		Skill_Controller.StopHold("Double Jump")
	end

	Dash_Handler.LastDid = tick2()
	v2 = true
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed == false then
		if InputHandler.IsBlocked() then
			return
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.Q) and find(v3, input.KeyCode) or input.KeyCode == Enum.KeyCode.Q then
			local v4

			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				v4 = "A"
			elseif UserInputService:IsKeyDown(Enum.KeyCode.S) then
				v4 = "S"
			elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
				v4 = "D"
			elseif UserInputService:IsKeyDown(Enum.KeyCode.W) then
				v4 = "W"
			else
				v4 = nil
			end

			if v4 ~= nil then
				Dash_Handler.Perform(v4)
			end
		end
	end
end)

function cancel_dash()
	if tick2() - Dash_Handler.LastDid > 0.5 then
		return
	end

	if localPlayer.Character ~= nil and localPlayer.Character:FindFirstChild("HumanoidRootPart") ~= nil then
		if localPlayer.Character.HumanoidRootPart:FindFirstChild("dash_thang_123asd") ~= nil then
			for _, child2 in pairs(localPlayer.Character.HumanoidRootPart:GetChildren()) do
				if child2.Name == "dash_thang_123asd" then
					child2:Destroy()
				end
			end
		end

		localPlayer.Character.HumanoidRootPart.Velocity = Vector3.new()
	end
end

local child2 = game.ReplicatedStorage:WaitForChild("Player_Service"):WaitForChild("Values"):WaitForChild(localPlayer.Name)
local Utility2 = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
child2.ChildAdded:Connect(function(child3)
	if Utility2.Cancel_Values[child3.Name] ~= nil then
		cancel_dash()
	end

	if child3.Name == "DMG" then
		cancel_dash()
		child3:GetAttributeChangedSignal("LastEngaged"):Connect(function()
			if tick2() - Combat_presets.Last_Punched <= Combat_presets.slow_walk_duration then
				cancel_dash()
			end
		end)
	end
end)
local v4 = maid:Add(DataValue.new(
	SettingsKeys.PadDirectionalDash.Path,
	SettingsKeys.PadDirectionalDash.Default,
	SettingsKeys.Scope
))

local function directional()
	return v4:Get() == true
end

local v5 = false
local count = 0
local inputChangedConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function disarm()
	v5 = false
	Run_Handler.DashArmed = false

	if inputChangedConnection ~= nil then
		inputChangedConnection:Disconnect()
		inputChangedConnection = nil
	end
end

maid:Add(disarm)
v4.Changed:Connect(disarm)
maid:Add(InputHandler.ListenTo("Dash", function(p, p2)
	if v4:Get() == true then
		if p == "Up" then
			if not v5 then
				return
			end

			local v6 = "W"

			for _, v7 in UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1) do
				if v7.KeyCode ~= Enum.KeyCode.Thumbstick1 then
					continue
				end

				local vector = Vector2.new(v7.Position.X, -v7.Position.Y)

				if vector.Magnitude >= 0.5 then
					v6 = Dash_Handler.Letter(vector)
				end
			end

			disarm() -- equivalent call inferred; original call site unknown
			Dash_Handler.Perform(v6)
		else
			if p ~= "Down" or p2 or v5 then
				return
			end

			v5 = true
			count += 1
			local v6 = count
			local v7 = nil

			for _, v8 in UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1) do
				if v8.KeyCode ~= Enum.KeyCode.Thumbstick1 then
					continue
				end

				local vector = Vector2.new(v8.Position.X, -v8.Position.Y)

				if vector.Magnitude >= 0.5 then
					v7 = Dash_Handler.Letter(vector)
				end
			end

			Run_Handler.DashArmed = true
			task.delay(0.3, function()
				if not v5 or v6 ~= count then
					return
				end

				disarm() -- equivalent call inferred; original call site unknown
				Dash_Handler.Perform(v7 or "W")
			end)
			inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
				if input.KeyCode ~= Enum.KeyCode.Thumbstick1 then
					return
				end

				local vector = Vector2.new(input.Position.X, -input.Position.Y)

				if vector.Magnitude < 0.5 then
					return
				end

				local letter = Dash_Handler.Letter(vector)

				if letter == v7 then
					return
				end

				disarm() -- equivalent call inferred; original call site unknown
				Dash_Handler.Perform(letter)
			end)
		end
	else
		if p ~= "Down" or p2 then
			return
		end

		Dash_Handler.Perform(Dash_Handler.MovementLetter())
	end
end))