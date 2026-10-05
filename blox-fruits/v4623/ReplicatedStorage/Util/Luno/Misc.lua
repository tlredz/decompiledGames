local Misc = {}

function Misc:lerp(p2, p3)
	return self + (p2 - self) * p3
end

function Misc:cflerp(cframe2: CFrame, p: number)
	return self:lerp(cframe2, p)
end

function Misc.cubicBezier(p: number, vector: Vector3, vector2: Vector3, vector3: Vector3, vector4: Vector3)
	return vector * (1 - p) ^ 3 + vector2 * 3 * p * (1 - p) ^ 2 + vector3 * 3 * (1 - p) * p ^ 2 + vector4 * p ^ 3
end

function Misc.charInRange(vector: Vector3, p: number)
	local character = game.Players.LocalPlayer.Character
	local humanoidRootPart = character ~= nil and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local magnitude = (humanoidRootPart.Position - vector).magnitude

		if magnitude <= p then
			return magnitude
		end
	end

	return false
end

function Misc.cameraInRange(vector: Vector3, p: number)
	local magnitude = (workspace.CurrentCamera.CFrame.p - vector).Magnitude
	return magnitude <= p and magnitude
end

function Misc.scaleParticle(state, p: number, flag: boolean)
	local v = {
		Size = state.Size.Keypoints,
		Speed = state.Speed,
		Acceleration = state.Acceleration
	}

	for i = 1, #v.Size do
		v.Size[i] = NumberSequenceKeypoint.new(v.Size[i].Time, v.Size[i].Value * p, v.Size[i].Envelope * p)
	end

	state.Size = NumberSequence.new(v.Size)
	state.Speed = NumberRange.new(state.Speed.Min * p, state.Speed.Max * p)

	if flag then
		state.Acceleration = Vector3.new(v.Acceleration.X * p, v.Acceleration.Y * p, v.Acceleration.Z * p)
	end
end

function Misc.modAngles(cframe: CFrame, p: number, p2: number, p3: number)
	local orientation, v, v2 = cframe:ToOrientation()
	return CFrame.new(cframe.Position) * CFrame.fromOrientation(orientation * p, v * p2, v2 * p3)
end

return Misc