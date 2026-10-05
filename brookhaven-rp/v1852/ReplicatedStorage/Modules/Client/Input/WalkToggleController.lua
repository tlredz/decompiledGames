local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Input = require(ReplicatedStorage.Packages.Input)
local Observers = require(ReplicatedStorage.Packages.Observers)
local keyboard = Input.Keyboard
local v = false

local function getCharacterHumanoid()
	local character = Players.LocalPlayer.Character

	if not character then
		return nil, nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		return character, humanoid
	end

	return nil, nil
end

local function canChangeMoveSpeed(instance, p)
	if p.WalkSpeed == 0 or instance:FindFirstChild(Players.LocalPlayer.Name .. "Horse") then
		return false
	end

	return not instance:FindFirstChild("NoMotorVehicleModel")
end

local function applyDesiredSpeed()
	local character = Players.LocalPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")

		if not humanoid then
			character = nil
			humanoid = nil
		end
	else
		character = nil
	end

	if not (character and humanoid) then
		return
	end

	local v2

	if humanoid.WalkSpeed == 0 or character:FindFirstChild(Players.LocalPlayer.Name .. "Horse") then
		v2 = false
	else
		v2 = not character:FindFirstChild("NoMotorVehicleModel")
	end

	if not v2 then
		return
	end

	if v then
		if humanoid.WalkSpeed > 4 then
			humanoid.WalkSpeed = 4
		end
	elseif humanoid.WalkSpeed == 4 then
		humanoid.WalkSpeed = 16
	end
end

local WalkToggleController = {}

function WalkToggleController.IsWalking()
	return v
end

function WalkToggleController.StopWalking()
	if v ~= true then
		return
	end

	v = false
	local character = Players.LocalPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")

		if not humanoid then
			character = nil
			humanoid = nil
		end
	else
		character = nil
	end

	if character then
		if not humanoid then
			return
		end

		local v2

		if humanoid.WalkSpeed == 0 or character:FindFirstChild(Players.LocalPlayer.Name .. "Horse") then
			v2 = false
		else
			v2 = not character:FindFirstChild("NoMotorVehicleModel")
		end

		if not v2 then
			return
		end

		if v then
			if humanoid.WalkSpeed > 4 then
				humanoid.WalkSpeed = 4
			end
		elseif humanoid.WalkSpeed == 4 then
			humanoid.WalkSpeed = 16
		end
	end
end

function WalkToggleController.FrameworkStart()
	keyboard.new().KeyDown:Connect(function(p, flag: boolean)
		if flag or p ~= Enum.KeyCode.LeftControl then
			return
		end

		local character = Players.LocalPlayer.Character
		local humanoid

		if character then
			humanoid = character:FindFirstChildOfClass("Humanoid")

			if not humanoid then
				character = nil
				humanoid = nil
			end
		else
			character = nil
		end

		if not (character and humanoid) then
			return
		end

		local v2

		if humanoid.WalkSpeed == 0 or character:FindFirstChild(Players.LocalPlayer.Name .. "Horse") then
			v2 = false
		else
			v2 = not character:FindFirstChild("NoMotorVehicleModel")
		end

		if not v2 then
			return
		end

		v = humanoid.WalkSpeed > 4
		local character2 = Players.LocalPlayer.Character
		local humanoid2

		if character2 then
			humanoid2 = character2:FindFirstChildOfClass("Humanoid")

			if not humanoid2 then
				character2 = nil
				humanoid2 = nil
			end
		else
			character2 = nil
		end

		if character2 then
			if not humanoid2 then
				return
			end

			local v3

			if humanoid2.WalkSpeed == 0 or character2:FindFirstChild(Players.LocalPlayer.Name .. "Horse") then
				v3 = false
			else
				v3 = not character2:FindFirstChild("NoMotorVehicleModel")
			end

			if not v3 then
				return
			end

			if v then
				if humanoid2.WalkSpeed > 4 then
					humanoid2.WalkSpeed = 4
				end
			elseif humanoid2.WalkSpeed == 4 then
				humanoid2.WalkSpeed = 16
			end
		end
	end)
	Observers.observeLocalCharacter(function(instance)
		instance:WaitForChild("Humanoid")
		local character = Players.LocalPlayer.Character
		local humanoid

		if character then
			humanoid = character:FindFirstChildOfClass("Humanoid")

			if not humanoid then
				character = nil
				humanoid = nil
			end
		else
			character = nil
		end

		if character then
			if not humanoid then
				return
			end

			local v2

			if humanoid.WalkSpeed == 0 or character:FindFirstChild(Players.LocalPlayer.Name .. "Horse") then
				v2 = false
			else
				v2 = not character:FindFirstChild("NoMotorVehicleModel")
			end

			if not v2 then
				return
			end

			if v then
				if humanoid.WalkSpeed > 4 then
					humanoid.WalkSpeed = 4
				end
			elseif humanoid.WalkSpeed == 4 then
				humanoid.WalkSpeed = 16
			end
		end
	end)
end

return WalkToggleController