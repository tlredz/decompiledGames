local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent

if not parent:IsA("Tool") then
	return
end

local v = false
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local clone = nil
local v2 = false
local GeneralUIModule = require(ReplicatedStorage.shared.modules.GeneralUIModule)
require(ReplicatedStorage.shared.modules.library.fish.zones.crabzone)
local assets = require(ReplicatedStorage.shared.utils.assets)

function DeleteCage()
	if clone then
		clone:Destroy()
	end

	clone = nil
	v2 = false
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.active.boats, workspace.world.map, workspace.Terrain }
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { workspace.active, workspace.world }
game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character2)
		overlapParams:AddToFilter(character2)
	end)
end)
local v3 = nil
local v4 = false

for _, v5 in game.Players:GetPlayers() do
	v5.CharacterAdded:Connect(function(character2)
		overlapParams:AddToFilter(character2)
	end)

	if v5.Character then
		overlapParams:AddToFilter(v5.Character)
	end
end

local function GetFlattenedCamera()
	local v5 = workspace.CurrentCamera.CFrame.LookVector * createVector(1, 0, 1)

	if v5.Magnitude <= 0 then
		v5 = workspace.CurrentCamera.CFrame.UpVector * createVector(1, 0, 1)
	end

	return v5.Unit
end

parent.Equipped:Connect(function()
	v = true
	character = localPlayer.Character
	local humanoid = localPlayer.Character:FindFirstChild("Humanoid")
	v3 = GeneralUIModule:GiveToolTip(localPlayer, "[Interact to place a " .. parent.Name .. "]")

	if humanoid and character and humanoid.Health > 0 then
		if clone then
			clone:Destroy()
		end

		clone = assets.getAsync("item", "Coral Crab Cage"):WaitForChild("Cage"):Clone()
		clone.hitbox.Transparency = 1
		clone.handle.Anchored = true
		clone.Parent = workspace.CurrentCamera

		while v and character and humanoid.Health > 0 and character:FindFirstChild("HumanoidRootPart") do
			if not clone then
				continue
			end

			local position = character:FindFirstChild("HumanoidRootPart").Position
			local v5 = workspace.CurrentCamera.CFrame.LookVector * createVector(1, 0, 1)

			if v5.Magnitude <= 0 then
				v5 = workspace.CurrentCamera.CFrame.UpVector * createVector(1, 0, 1)
			end

			local cframe = CFrame.new(position, position + v5.Unit)
			local position2 = (cframe * CFrame.new(0, 0, -6)).Position
			local raycastResult = workspace:Raycast(position2, createVector(0, -11, 0), raycastParams)
			local v6 = not raycastResult and 1 or position2.Y - raycastResult.Position.Y

			if humanoid:GetState() == Enum.HumanoidStateType.Swimming or not raycastResult then
				clone.Parent = nil
			else
				clone.Parent = workspace.CurrentCamera
			end

			clone.PrimaryPart.CFrame = cframe * CFrame.new(0, -v6, -6) * CFrame.Angles(
				0,
				clone.handle.CFrame.Rotation.Y,
				0
			)

			if raycastResult and (raycastResult.Instance == workspace.Terrain or raycastResult.Instance:HasTag("PartWater")) then
				if humanoid:GetState() == Enum.HumanoidStateType.Swimming then
					v2 = false
				elseif #workspace:GetPartsInPart(clone.hitbox, overlapParams) <= 0 then
					v2 = true
				else
					v2 = false
				end
			else
				v2 = false
			end

			if v2 == true then
				for _, part in pairs(clone:GetChildren()) do
					if part:IsA("BasePart") then
						part.Color = Color3.fromRGB(125, 255, 105)
					end
				end

				clone.hitbox.light.Enabled = true
			else
				for _, part in pairs(clone:GetChildren()) do
					if part:IsA("BasePart") then
						part.Color = Color3.fromRGB(33, 33, 33)
					end
				end

				clone.hitbox.light.Enabled = false
			end

			local RunService = game:GetService("RunService")
			RunService.PreRender:Wait()
		end

		DeleteCage()
	end
end)
parent.Unequipped:Connect(function()
	v = false
	DeleteCage()

	if v3 then
		v3:Remove()
	end
end)
parent.Activated:Connect(function()
	if v2 == true and clone and v and clone.Parent == workspace.CurrentCamera then
		if v4 == true then
			return
		end

		v4 = true
		task.delay(0.1, function()
			v4 = false
		end)
		local position = character:FindFirstChild("HumanoidRootPart").Position
		local v5 = workspace.CurrentCamera.CFrame.LookVector * createVector(1, 0, 1)

		if v5.Magnitude <= 0 then
			v5 = workspace.CurrentCamera.CFrame.UpVector * createVector(1, 0, 1)
		end

		local cframe = CFrame.new(position, position + v5.Unit)
		script.Parent:WaitForChild("Deploy"):FireServer(cframe)
	end
end)