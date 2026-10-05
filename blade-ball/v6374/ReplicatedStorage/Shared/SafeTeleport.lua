local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Shared.FreezeSwordConstraints)

local function SafeTeleport(character, cframe, p: string?)
	if character == nil then
		return
	end

	if typeof(character) == "Instance" then
		if character:IsA("Player") then
			character = character.Character
		else
			Players:GetPlayerFromCharacter(character)
		end
	else
		character = character.Character
	end

	if not character then
		return
	end

	local v2 = v(character)

	if typeof(cframe) ~= "CFrame" then
		cframe = character:GetPivot().Rotation * CFrame.new(cframe)
	end

	if p == "Displace" then
		local v3 = cframe.Position + createVector(0, 10, 0)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = CollectionService:GetTagged("SAFE_TELEPORT_FIX")
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		local raycastResult = workspace:Raycast(v3, createVector(-0, -100, -0), raycastParams)

		if raycastResult then
			local vector2 = Vector3.new(cframe.X, raycastResult.Position.Y + 3, cframe.Z)
			cframe = CFrame.new(vector2, cframe.LookVector + vector2)
		end
	end

	character:PivotTo(cframe)
	task.delay(1, v2)
end

return SafeTeleport