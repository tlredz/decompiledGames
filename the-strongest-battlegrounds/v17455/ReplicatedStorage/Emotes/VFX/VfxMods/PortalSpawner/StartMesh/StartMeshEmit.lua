local createVector = vector.create
return function(cframe: CFrame?, parent)
	if cframe then
		if typeof(cframe) == "Vector3" then
			cframe = CFrame.new(cframe)
		elseif typeof(cframe) ~= "CFrame" then
			cframe = nil
		end
	end

	if not parent then
		parent = workspace:FindFirstChild("MeshCache")

		if not parent then
			parent = Instance.new("Folder")
			parent.Name = "MeshCache"
			parent.Parent = workspace
		end
	end

	local v = cframe or CFrame.new(0, 0, 0)
	local v2 = {
		Sidering1 = script.Parent.Sidering1,
		fastglass = script.Parent.fastglass,
		glassIN = script.Parent.glassIN
	}
	local v3 = {
		[v2.Sidering1] = {
			General = {
				Offset = CFrame.new(0, 0, 0, 0.999999464, 0, 0, 0, 1, 0, 0, 0, 0.999999464),
				Tween_Duration = 0.5,
				Transparency = 0
			},
			BasePart = {
				Property = {
					Size = createVector(20, 0.001, 20),
					CFrame = v * CFrame.new(0, 0, 0, 0.999999464, 0, 0, 0, 1, 0, 0, 0, 0.999999464),
					Color = Color3.new(0.666667, 0.333333, 1),
					Transparency = 0
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Circular
				}
			}
		},
		[v2.fastglass] = {
			General = {
				Offset = CFrame.new(0, 0, 0, 0.470561028, 0, -0.882366598, 0, 1, 0, 0.882366598, 0, 0.470561028),
				Tween_Duration = 0.2,
				Transparency = 4
			},
			BasePart = {
				Property = {
					Size = createVector(20, 0.001, 20),
					CFrame = v * CFrame.new(
						0.0000152362973,
						0,
						8.28109876e-7,
						0.054270979,
						0,
						0.998525441,
						0,
						1,
						0,
						-0.998525441,
						0,
						0.054270979
					),
					Color = Color3.new(0.666667, 0.333333, 1),
					Transparency = 8
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Quad
				}
			}
		},
		[v2.glassIN] = {
			General = {
				Offset = CFrame.new(0, 0, 0, 0.999999464, 0, 0, 0, 1, 0, 0, 0, 0.999999464),
				Tween_Duration = 0.15,
				Transparency = 4
			},
			BasePart = {
				Property = {
					Size = createVector(15, 0.001, 15),
					CFrame = v * CFrame.new(0, 0, 0, 0.999999464, 0, 0, 0, 1, 0, 0, 0, 0.999999464),
					Color = Color3.new(0.666667, 0.333333, 1),
					Transparency = 8
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Circular
				}
			}
		}
	}

	for k, v4 in pairs(v3) do
		if not (k and k:IsDescendantOf(game) and k:FindFirstChild("Start")) then
			continue
		end

		local v5 = k
		local v6 = v4

		local function Emit()
			local clone = v5.Start:Clone()
			clone.Name = v5.Name
			clone.Transparency = v6.General.Transparency

			if clone:FindFirstChildOfClass("Decal") then
				local decal = clone:FindFirstChildOfClass("Decal")
				decal.Transparency = v6.General.Transparency
				clone.Transparency = 1
			end

			clone.Anchored = true
			clone.CanCollide = false
			clone.CanQuery = false
			clone.CanTouch = false
			clone.Locked = true
			clone.CFrame = v * v6.General.Offset
			clone.Parent = parent
			local TweenService = game:GetService("TweenService")
			TweenService:Create(
				clone,
				TweenInfo.new(
					v6.General.Tween_Duration,
					v6.BasePart.Tween.Easing_Style,
					v6.BasePart.Tween.Easing_Direction
				),
				v6.BasePart.Property
			):Play()
			task.delay(v6.General.Tween_Duration, clone.Destroy, clone)
		end

		task.spawn(Emit)
	end
end