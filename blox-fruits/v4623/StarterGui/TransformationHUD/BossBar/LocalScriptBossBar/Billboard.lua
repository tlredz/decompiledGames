local createVector = vector.create
local v = {}
local renderSteppedConnection = nil

function run()
	if renderSteppedConnection then
		return
	end

	local RunService = game:GetService("RunService")
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		for k, v2 in pairs(v) do
			if k.Parent then
				local vector2 = workspace.CurrentCamera:WorldToScreenPoint(k.CFrame.Position)
				local worldToScreenPoint = workspace.CurrentCamera:WorldToScreenPoint(k.CFrame.Position + workspace.CurrentCamera.CFrame.RightVector)

				if vector2.Z < 0 then
					v2.BackgroundTransparency = 1
				else
					local magnitude = (vector2 * createVector(1, 1, 0) - worldToScreenPoint * createVector(1, 1, 0)).Magnitude
					local vector3 = Vector2.new(magnitude * 25 + 50, magnitude * 2.5 + 5)

					if vector2.Y < vector3.Y / 2 + 10 then
						if vector2.Y > vector3.Y * -1.5 then
							vector2 = Vector3.new(vector2.X, vector3.Y / 2 + 10, vector2.Z)
						else
							v2.BackgroundTransparency = 1
							continue
						end
					end

					if vector2.X < vector3.X / 2 then
						if vector2.X > -vector3.X then
							vector2 = Vector3.new(vector3.X / 2 + 5, vector2.Y, vector2.Z)
						else
							v2.BackgroundTransparency = 1
							continue
						end
					elseif vector2.X > script.Parent.Parent.Parent.AbsoluteSize.X then
						if vector2.X < script.Parent.Parent.Parent.AbsoluteSize.X + vector3.X then
							vector2 = Vector3.new(
								script.Parent.Parent.Parent.AbsoluteSize.X - vector3.X / 2 - 5,
								vector2.Y,
								vector2.Z
							)
						else
							v2.BackgroundTransparency = 1
							continue
						end
					end

					v2.Size = UDim2.fromOffset(vector3.X, vector3.Y)
					v2.Position = UDim2.fromOffset(vector2.X, vector2.Y)
					v2.BackgroundTransparency = math.min((vector2.Z - 600) / 900, 0.6)

					if vector2.Z > 2000 then
						v2.BackgroundTransparency = 1
					end
				end
			else
				v[k] = nil
				v2:Destroy()
			end
		end
	end)
end

return function(p)
	if v[p] then
		return v[p], true
	end

	v[p] = script.Fill:Clone()
	v[p].Parent = script.Parent.Parent.Parent
	run()
	return v[p]
end