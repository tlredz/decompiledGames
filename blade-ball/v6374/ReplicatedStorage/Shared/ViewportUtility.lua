game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("Workspace")
game:GetService("PhysicsService")
local v = {}
local ViewportUtility = {
	GetViewport = function(p)
		if p ~= "Weapon" then
			return
		end

		local clone = script.Rig:Clone()
		clone:SetPrimaryPartCFrame(CFrame.new(0, 1.5, -9) * CFrame.Angles(0.2, 3.041592653589793, 0))
		clone.DescendantAdded:Connect(function(part)
			if part:IsA("BasePart") then
				part.CollisionGroup = "ViewportCharacter"
			end
		end)

		for _, part in clone:GetChildren() do
			if part:IsA("BasePart") then
				part.CollisionGroup = "ViewportCharacter"
			end
		end

		return clone
	end
}

function ViewportUtility.GiveWeapon(_, parent, object)
	if parent:FindFirstChild("Sword") then
		parent:FindFirstChild("Sword"):Destroy()
	end

	object.Parent = parent
	object:SetPrimaryPartCFrame(parent.Torso.CFrame * CFrame.new(-1.025, -1.2, 1.016) * CFrame.Angles(121.3, 0, 0))
	local motor6D = Instance.new("Motor6D")
	motor6D.Parent = parent.Torso
	motor6D.Part0 = motor6D.Parent
	motor6D.Part1 = object.sord
	ViewportUtility:PlayAnimation(parent, "Idle")
end

function ViewportUtility:PlayAnimation(instance, childName)
	local animator = instance:FindFirstChild("Humanoid"):FindFirstChildOfClass("Animator")

	if not v[instance] then
		v[instance] = {}
	end

	for _, v2 in v[instance] do
		v2:Stop()
	end

	if v[instance][childName] then
		v[instance][childName]:Play()
		return
	end

	local v2 = script:FindFirstChild(childName) or game.ReplicatedStorage.Misc.Emotes:FindFirstChild(childName)

	if not v2 then
		return
	end

	local count = 0

	for _ in v[instance] do
		count += 1
	end

	if count >= 24 then
		for k, v3 in v[instance] do
			if v3.IsPlaying then
				continue
			end

			v[instance][k] = nil
			v3:Destroy()
		end
	end

	local track = animator:LoadAnimation(v2)
	v[instance][childName] = track
	track:Play()
end

function ViewportUtility.StopAnimation(_, p, p2)
	if v[p] and v[p][p2] then
		v[p][p2]:Stop()
	end

	ViewportUtility:PlayAnimation(p, "Idle")
end

local camera = Instance.new("Camera")
camera.Name = "Camera"
camera.CameraType = Enum.CameraType.Scriptable
camera.FieldOfView = 40
camera.CFrame = CFrame.new()
camera.Parent = workspace
ViewportUtility.Camera = camera
return ViewportUtility