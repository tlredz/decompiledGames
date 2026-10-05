local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
game:GetService("ReplicatedStorage")
return function(list)
	local v, part, _, v3 = unpack(list)
	local rightHand = v:WaitForChild("RightHand", 1)
	local clone = script.Pesado:Clone()
	clone.Name = v.Name .. "SandForearm"
	clone.Anchored = false
	clone.CFrame = rightHand.CFrame * CFrame.new(0, 1, 0)
	clone.Mesh.Scale = Vector3.new()
	local weld = Instance.new("Weld", clone)
	weld.C0 = CFrame.new(0, 1, 0)
	weld.Part0 = clone
	weld.Part1 = part
	clone.Parent = _WorldOrigin
	TweenService:Create(clone.Mesh, TweenInfo.new(v3), {
		Scale = createVector(1, 1, 1)
	}):Play()
end