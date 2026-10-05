local Signal = require(script.Parent.Parent.Signal)
local Trove = require(script.Parent.Parent.Trove)
local UserInputService = game:GetService("UserInputService")
local Mouse = {}
Mouse.__index = Mouse

function Mouse.new()
	local object = setmetatable({}, Mouse)
	object._trove = Trove.new()
	object.LeftDown = object._trove:Construct(Signal)
	object.LeftUp = object._trove:Construct(Signal)
	object.RightDown = object._trove:Construct(Signal)
	object.RightUp = object._trove:Construct(Signal)
	object.MiddleDown = object._trove:Construct(Signal)
	object.MiddleUp = object._trove:Construct(Signal)
	object.Scrolled = object._trove:Construct(Signal)
	object.Moved = object._trove:Construct(Signal)
	object._trove:Connect(UserInputService.InputBegan, function(p, p2)
		if p2 then
			return
		end

		if p.UserInputType == Enum.UserInputType.MouseButton1 then
			object.LeftDown:Fire()
		elseif p.UserInputType == Enum.UserInputType.MouseButton2 then
			object.RightDown:Fire()
		elseif p.UserInputType == Enum.UserInputType.MouseButton3 then
			object.MiddleDown:Fire()
		end
	end)
	object._trove:Connect(UserInputService.InputEnded, function(p, p2)
		if p2 then
			return
		end

		if p.UserInputType == Enum.UserInputType.MouseButton1 then
			object.LeftUp:Fire()
		elseif p.UserInputType == Enum.UserInputType.MouseButton2 then
			object.RightUp:Fire()
		elseif p.UserInputType == Enum.UserInputType.MouseButton3 then
			object.MiddleUp:Fire()
		end
	end)
	object._trove:Connect(UserInputService.InputChanged, function(p, p2)
		if p2 then
			return
		end

		if p.UserInputType == Enum.UserInputType.MouseMovement then
			local position = p.Position
			object.Moved:Fire(Vector2.new(position.X, position.Y))
		elseif p.UserInputType == Enum.UserInputType.MouseWheel then
			object.Scrolled:Fire(p.Position.Z)
		end
	end)
	return object
end

function Mouse.IsLeftDown(_)
	return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
end

function Mouse.IsRightDown(_)
	return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
end

function Mouse.IsMiddleDown(_)
	return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton3)
end

function Mouse.GetPosition(_)
	return UserInputService:GetMouseLocation()
end

function Mouse.GetDelta(_)
	return UserInputService:GetMouseDelta()
end

function Mouse:GetRay(point: Vector2?)
	local v = point or UserInputService:GetMouseLocation()
	return (workspace.CurrentCamera:ViewportPointToRay(v.X, v.Y))
end

function Mouse:Raycast(p, value: number?, point: Vector2?)
	local ray = self:GetRay(point)
	return (workspace:Raycast(ray.Origin, ray.Direction * (value or 1000), p))
end

function Mouse:Project(value: number?, point: Vector2?)
	local ray = self:GetRay(point)
	return ray.Origin + ray.Direction.Unit * (value or 1000)
end

function Mouse.Lock(_)
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
end

function Mouse.LockCenter(_)
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
end

function Mouse.Unlock(_)
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end

function Mouse:Destroy()
	self._trove:Destroy()
end

return Mouse