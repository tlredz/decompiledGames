require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Character_info_provider"))
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local equipped = localPlayer:WaitForChild("Items_Config", 999):WaitForChild("Equipped")
local Over_Written_Animation_Player = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("GamePlay"):WaitForChild("Over_Written_Animation_Player"))
local stringValue = Instance.new("StringValue", script)
stringValue.Name = "current_run_anim"
game.ReplicatedStorage.Player_Service:WaitForChild("Values"):WaitForChild(localPlayer.Name)
local child = game.ReplicatedStorage:WaitForChild("Player_Service"):WaitForChild("Data"):WaitForChild(
	game.Players.LocalPlayer.Name,
	9999
)
local child2 = child.slots:FindFirstChild("Slot" .. child.slotEquipped.Value)
local Character_info_provider = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Character_info_provider"))

function upd()
	task.wait()

	for k, v in pairs(Over_Written_Animation_Player.Curernt_Anims_Playing.Run) do
		v:Stop()
		Over_Written_Animation_Player.Curernt_Anims_Playing.Run[k] = nil
	end

	if stringValue ~= nil and stringValue.Value ~= "" then
		local get_core_anim = Character_info_provider.get_core_anim(localPlayer, "run", true)

		if get_core_anim ~= nil then
			if get_core_anim == nil then
				return
			end

			local track = humanoid.Animator:LoadAnimation(get_core_anim)
			track.Priority = Enum.AnimationPriority.Idle
			track:Play()
			table.insert(Over_Written_Animation_Player.Curernt_Anims_Playing.Run, track)
		end
	end
end

stringValue.Changed:Connect(upd)
character.ChildAdded:Connect(function(child3)
	if child3.Name == "Mode" then
		upd()
	end
end)
equipped.Changed:Connect(upd)

for _, child3 in pairs(child2.Inventory.Toolbar:GetChildren()) do
	local v2

	if child3.Name == "One" then
		v2 = 1
	elseif child3.Name == "Two" then
		v2 = 2
	elseif child3.Name == "Three" then
		v2 = 3
	elseif child3.Name == "Four" then
		v2 = 4
	elseif child3.Name == "Five" then
		v2 = 5
	else
		v2 = false
	end

	child3.Changed:Connect(function()
		if v2 == equipped.Value then
			upd()
		end
	end)
end

character.ChildRemoved:Connect(function(child3)
	if child3.Name == "Mode" then
		upd()
	end
end)

while true do
	local state = humanoid:GetState()
	stringValue.Value = humanoid ~= nil and state ~= Enum.HumanoidStateType.FallingDown and humanoidRootPart ~= nil and humanoidRootPart.Velocity.Magnitude > 5 and humanoid.MoveDirection.Magnitude >= 0.1 and state ~= Enum.HumanoidStateType.Freefall and state ~= Enum.HumanoidStateType.Jumping and Over_Written_Animation_Player.Get_movement_anim_eq() or ""
	task.wait()
end