local createVector = vector.create
local Aim = {
	fromMouse = function(object)
		local hit = object.mouse and object.mouse.Hit

		if typeof(hit) == "CFrame" then
			return hit.Position
		end

		return object:aim()
	end,
	lookAt = function(vector2: Vector3, vector3: Vector3, vector4: Vector3?)
		if (vector3 - vector2).Magnitude > 0.001 then
			return CFrame.new(vector2, vector3)
		end

		if vector4 and vector4.Magnitude > 0.001 then
			return CFrame.new(vector2, vector2 + vector4.Unit)
		end

		return CFrame.new(vector2, vector2 - createVector(0, 0, 1))
	end
}

function Aim.lookFrom(instance, vector2: Vector3)
	return Aim.lookAt(instance.Position, vector2, instance.CFrame.LookVector)
end

function Aim.flatLookFrom(p, vector2: Vector3)
	return Aim.lookFrom(p, (Vector3.new(vector2.X, p.Position.Y, vector2.Z)))
end

function Aim.horizontal(p, vector2: Vector3)
	return (Vector3.new(vector2.X, p.Position.Y, vector2.Z))
end

function Aim.raiseLowAim(vector2: Vector3, vector3: Vector3, p: number, p2: number)
	if vector2.Y < vector3.Y - p then
		return (Vector3.new(vector2.X, vector2.Y + p2, vector2.Z))
	end

	return vector2
end

return Aim