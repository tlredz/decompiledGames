local knife = script.Parent:WaitForChild("Game"):WaitForChild("Knife")
local gun = script.Parent:WaitForChild("Game"):WaitForChild("Gun")

local function toggleWeaponEquip(tag: string)
	local backpack = game.Players.LocalPlayer.Backpack

	if not backpack then
		return
	end

	local character = game.Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	for _, tool in backpack:GetChildren() do
		if not (tool:HasTag(tag) and tool:IsA("Tool")) then
			continue
		end

		humanoid:EquipTool(tool)
		return
	end

	for _, tool in character:GetChildren() do
		if not (tool:HasTag(tag) and tool:IsA("Tool")) then
			continue
		end

		humanoid:UnequipTools()
		break
	end
end

knife.MouseButton1Down:Connect(function()
	toggleWeaponEquip("Weapon_Knife")
end)
gun.MouseButton1Down:Connect(function()
	toggleWeaponEquip("Weapon_Gun")
end)