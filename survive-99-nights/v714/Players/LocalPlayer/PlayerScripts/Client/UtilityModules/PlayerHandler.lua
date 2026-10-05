local createVector = vector.create
local PlayerHandler = {}
local localPlayer = game.Players.LocalPlayer
require(localPlayer.PlayerScripts.Client)
local _ = localPlayer.PlayerGui
game:GetService("PhysicsService")

function PlayerHandler.ReliableApplyImpulse(p)
	task.spawn(function()
		local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			local humanoid = localPlayer.Character.Humanoid
			local _ = humanoidRootPart.AssemblyMass
			local v = false

			while v == false do
				humanoid:ChangeState(Enum.HumanoidStateType.Flying)

				for _, part in pairs(localPlayer.Character:GetChildren()) do
					if part:IsA("BasePart") then
						part.Velocity = createVector(0, 0, 0)
					end
				end

				humanoidRootPart.AssemblyLinearVelocity = Vector3.new()
				humanoidRootPart:ApplyImpulse(p)
				task.wait()
				v = true
			end
		end
	end)
end

function PlayerHandler.Init()
	ConfigureHandler()
end

function ConfigureHandler()
	if localPlayer.Character then
		UpdateCharacterProperties()
	end

	localPlayer.CharacterAdded:Connect(function()
		UpdateCharacterProperties()
	end)
	localPlayer.CharacterRemoving:Connect(function(character)
		UpdateCharacterProperties(character)
	end)
end

function UpdateCharacterProperties(p)
	PlayerHandler.Alive = false
	PlayerHandler.Humanoid = nil
	PlayerHandler.HumanoidRootPart = nil

	if localPlayer.Character and localPlayer.Character ~= p then
		local character = localPlayer.Character
		task.spawn(function()
			local humanoid = localPlayer.Character:WaitForChild("Humanoid", 10)

			if humanoid and localPlayer.Character == character then
				PlayerHandler.Alive = true
				PlayerHandler.Humanoid = humanoid
				local diedConnection = nil
				diedConnection = humanoid.Died:Connect(function()
					diedConnection:Disconnect()

					if not localPlayer.Character or localPlayer.Character == character then
						PlayerHandler.Alive = false
					end
				end)
			end
		end)
		task.spawn(function()
			local humanoidRootPart = localPlayer.Character:WaitForChild("HumanoidRootPart", 10)

			if humanoidRootPart and localPlayer.Character == character then
				PlayerHandler.HumanoidRootPart = humanoidRootPart
				local ancestryChangedConnection = nil
				ancestryChangedConnection = humanoidRootPart.AncestryChanged:Connect(function()
					ancestryChangedConnection:Disconnect()

					if not humanoidRootPart.Parent and PlayerHandler.HumanoidRootPart == humanoidRootPart then
						PlayerHandler.HumanoidRootPart = nil
					end
				end)
			end
		end)
	end
end

return PlayerHandler