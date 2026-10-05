local localPlayer = game.Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local character = localPlayer.Character
local VRService = game:GetService("VRService")
local v = true
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { character }
raycastParams.IgnoreWater = true

if not VRService.VREnabled then
	return
end

if workspace:FindFirstChild("VRLaser") then
	workspace.VRLaser:Destroy()
end

local clone = script.Laser:Clone()
clone.Name = "VRLaser"
clone.Size = vector.create(1, 0.02, 0.02)
clone.Parent = workspace

-- equivalent calls inferred from this helper; original call sites unknown
local function get_mouse_result()
	return (workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 100, raycastParams))
end

local function get_origin_cframe(raycastResult: RaycastResult)
	local cframe = CFrame.Angles(0, -1.5707963267948966, 0)

	if raycastResult then
		return CFrame.lookAt(character.RightHand.Position, raycastResult.Position) * cframe
	end

	return CFrame.lookAt(character.RightHand.Position, mouse.UnitRay.Origin + mouse.UnitRay.Direction * 500) * cframe
end

-- equivalent calls inferred from this helper; original call sites unknown
local function is_laser_enabled()
	local tool = character:FindFirstChildOfClass("Tool")

	if tool and tool:GetAttribute("VRLaserEnabled") then
		return true
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function update_laser_enabled()
	v = is_laser_enabled()
end

update_laser_enabled() -- equivalent call inferred; original call site unknown
character.ChildAdded:connect(function(tool)
	if tool:IsA("Tool") then
		return update_laser_enabled()
	end
end)
character.ChildRemoved:connect(function(tool)
	task.wait()

	if tool:IsA("Tool") then
		return update_laser_enabled()
	end
end)
local RunService = game:GetService("RunService")
RunService.Heartbeat:connect(function(_)
	if not (v and character:FindFirstChild("RightHand")) then
		clone.Transparency = 1
		return
	end

	local v2 = get_mouse_result() -- equivalent call inferred; original call site unknown
	local v3 = get_origin_cframe(v2)
	clone.Transparency = 0.8
	clone.Size = Vector3.new(not v2 and 100 or (v2.Position - v3.Position).Magnitude or 100, 0.02, 0.02)
	clone.CFrame = v3 * CFrame.new(-clone.Size.X * 0.5, 0, 0)
end)