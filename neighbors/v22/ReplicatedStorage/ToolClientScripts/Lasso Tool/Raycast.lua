game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Raycast = {}
Raycast.__index = Raycast

function Raycast.new()
	local v = {
		Params = RaycastParams.new(),
		Camera = workspace.CurrentCamera
	}
	v.Params.FilterType = Enum.RaycastFilterType.Exclude
	setmetatable(v, Raycast)
	return v
end

function Raycast.UpdateParams(p, filterDescendantsInstances)
	p.Params.FilterDescendantsInstances = filterDescendantsInstances
end

function Raycast:Cast(vector: Vector3, vector2: Vector3)
	return workspace:Raycast(vector, vector2, self.Params)
end

function Raycast:Eyetrace(p: number)
	if not RunService:IsClient() then
		return
	end

	local camera = self.Camera
	return self:Cast(camera.CFrame.Position, camera.CFrame.LookVector.Unit * p)
end

function Raycast:TraceMouse(p: number)
	local camera = self.Camera
	local mouseLocation = UserInputService:GetMouseLocation()
	local viewportPointToRay = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y, 0)
	return self:Cast(viewportPointToRay.Origin, viewportPointToRay.Direction.Unit * p)
end

return Raycast