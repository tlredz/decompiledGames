local VectorViewer = {}
local RunService = game:GetService("RunService")
local v = {}
local count = 0

function SetVector(p, p2, p3, color)
	if not v[p + 1] then
		return warn("set vector invalid count", p, count, #v)
	end

	v[p + 1].Size = Vector3.new(0.1, 0.1, p2.magnitude)
	v[p + 1].CFrame = CFrame.new(p3 + p2 / 2, p3 + p2)

	if color then
		v[p + 1].Color = color
	end

	return v[p + 1]
end

function NewVector(p, p2, p3)
	local part = Instance.new("Part")
	part.Color = p3 or Color3.new(1, 0, 0)
	part.Anchored = true
	part.CanCollide = false
	part.Parent = workspace
	count += 1
	v[count] = part
	SetVector(count, p, p2, p3)
end

function VectorViewer.View(_, p, p2, p3)
	if count == #v then
		return NewVector(p, p2, p3)
	end

	local v2 = SetVector(count, p, p2, p3)
	count += 1
	return v2
end

function VectorViewer.Perma(_, p, p2, p3)
	local part = Instance.new("Part")
	part.Color = p3 or Color3.new(1, 0, 0)
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(0.1, 0.1, p.magnitude)
	part.Name = "VectorViewer"
	part.CFrame = CFrame.new(p2 + p / 2, p2 + p)
	part.Parent = workspace
	return part
end

local heartbeat, RunService2

if RunService:IsServer() then
	local RunService3 = game:GetService("RunService")
	heartbeat = RunService3.Heartbeat

	if not heartbeat then
		RunService2 = game:GetService("RunService")
		heartbeat = RunService2.RenderStepped
	end
else
	RunService2 = game:GetService("RunService")
	heartbeat = RunService2.RenderStepped
end

heartbeat:Connect(function()
	count = 0
end)
return VectorViewer