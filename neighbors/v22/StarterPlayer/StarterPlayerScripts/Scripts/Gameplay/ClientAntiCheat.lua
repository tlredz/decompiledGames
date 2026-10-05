local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local places = workspace.Places

local function IsVector3InRegion3(vector2: Vector3, region)
	local cFrame = region.CFrame
	local _ = region.Size
	local halfSize = region.Size / 2
	local v2 = cFrame - halfSize
	local v3 = cFrame + halfSize
	return vector2.X <= v2.X and vector2.X >= v3.X and vector2.Y >= v2.Y and vector2.Y <= v3.Y and vector2.Z <= v2.Z and vector2.Z >= v3.Z
end

function RegionCheck(vector2: Vector3, instance)
	local upperCorner = instance:GetAttribute("UpperCorner")
	local lowerCorner = instance:GetAttribute("LowerCorner")
	local v = upperCorner + instance:GetPivot().Position
	local v2 = lowerCorner + instance:GetPivot().Position
	return (IsVector3InRegion3(vector2, Region3.new(v2, v)))
end

local flag = false
RunService.Heartbeat:Connect(function()
	if flag or (not localPlayer or localPlayer:GetAttribute("ExemptFromAntiCheat")) then
		return
	end

	local character = localPlayer.Character

	if not (character and character.PrimaryPart) then
		return
	end

	local primaryPart = character.PrimaryPart
	local position = primaryPart.CFrame.Position

	if primaryPart.Anchored or localPlayer:GetAttribute("State") ~= 3 or localPlayer.Character:GetAttribute("Carried") then
		return
	end

	local child = places:FindFirstChild(localPlayer:GetAttribute("CurrentInternalMap") or "")

	if child and not RegionCheck(position, child) then
		flag = true
		task.delay(0.05, function()
			if primaryPart and not RegionCheck(primaryPart.CFrame.Position, child) then
				character:PivotTo(child:GetPivot() * CFrame.new(0, 30, 0))
				primaryPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			end

			flag = false
		end)
	end
end)