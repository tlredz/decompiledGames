local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Part_Icles = require(ReplicatedStorage:WaitForChild("Part_Icles"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local v = false
local v2 = nil

local function getGroup()
	if v2 and v2.Parent then
		return v2
	end

	local meshGroup1 = script:FindFirstChild("MeshGroup1")

	if not meshGroup1 then
		warn("GorillaKing.GroundSlam: no MeshGroup1 under the effect module")
		return nil
	end

	if not (meshGroup1:IsA("BasePart") or meshGroup1:IsA("Model") or meshGroup1:IsA("Attachment")) then
		local model = Instance.new("Model")
		model.Name = meshGroup1.Name

		for _, child in meshGroup1:GetChildren() do
			child.Parent = model
		end

		model.Parent = meshGroup1.Parent
		meshGroup1:Destroy()
		meshGroup1 = model
	end

	v2 = meshGroup1
	return meshGroup1
end

return function(data)
	local char = data.char
	local origin = data.origin
	local shakeStrength = data.shakeStrength or 25

	if not origin and char and char:FindFirstChild("HumanoidRootPart") then
		local ray = Util.Ray
		local position = char.HumanoidRootPart.Position
		local v3 = { workspace.Characters, workspace.Enemies }
		local v4
		v4, origin = ray(position, createVector(0, -12.5, 0), v3)
	end

	if not origin then
		return
	end

	local v3 = typeof(origin) == "CFrame" and origin or CFrame.new(origin)
	local currentCamera = workspace.CurrentCamera
	local v4 = not currentCamera and 1e999 or (v3.Position - currentCamera.CFrame.Position).Magnitude or 1e999

	if v4 > 1000 then
		return
	end

	local group = getGroup()

	if not group then
		return
	end

	if not v then
		v = true
		Part_Icles:Activate()
	end

	if v4 < 240 then
		Util.CameraShaker:ShakeOnce(shakeStrength, 25, 0.1, 0.8)
	end

	Part_Icles:AbsoluteEmitAt(group, v3)
end