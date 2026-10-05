local createVector = vector.create
return function(cframe: CFrame?, parent)
	if cframe then
		if typeof(cframe) == "Vector3" then
			cframe = CFrame.new(cframe)
		elseif typeof(cframe) ~= "CFrame" then
			cframe = nil
		end
	end

	local v = cframe or CFrame.new(0, 0, 0)
	local fajinFX = game.ReplicatedStorage.Emotes.VFX.VfxMods.FajinFX
	local v2 = {
		WindSidesOut2 = fajinFX.VFXassets.ChargeEmitMeshes.WindSidesOut2,
		RingDown = fajinFX.VFXassets.ChargeEmitMeshes.RingDown,
		ImpactIN = fajinFX.VFXassets.ChargeEmitMeshes.ImpactIN,
		ImpactDownSpread = fajinFX.VFXassets.ChargeEmitMeshes.ImpactDownSpread,
		RedSpikyout = fajinFX.VFXassets.ChargeEmitMeshes.RedSpikyout,
		WindSidesOut = fajinFX.VFXassets.ChargeEmitMeshes.WindSidesOut
	}
	local v3 = {
		[v2.WindSidesOut] = {
			General = {
				Offset = CFrame.new(0.499969482, -16.5294781, 0.25, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				Tween_Duration = 0.5,
				Transparency = 0
			},
			BasePart = {
				Property = {
					Size = createVector(15.140306, 3.2084162, 15.140306),
					CFrame = v * CFrame.new(
						0.5,
						-17.2718716,
						0.25,
						-0.923235893,
						0,
						0.384233654,
						0,
						1,
						0,
						-0.384233654,
						0,
						-0.923235893
					),
					Color = Color3.new(0.639216, 0.635294, 0.647059),
					Transparency = 1
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Circular
				}
			},
			Mesh = {
				Property = {
					Offset = createVector(0, 0, 0),
					Scale = createVector(15.140307, 3.2084162, 15.140307),
					VertexColor = createVector(1, 1, 1)
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Circular
				}
			},
			Decal = {
				Property = {
					Color3 = Color3.new(1.96078, 1.96078, 1.96078),
					Transparency = 1
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Circular
				}
			}
		},
		[v2.ImpactDownSpread] = {
			General = {
				Offset = CFrame.new(0.0714416504, 1.90734863e-6, 0.135575294, -1, 0, 0, 0, 1, 0, 0, 0, -1),
				Tween_Duration = 0.2,
				Transparency = 0
			},
			BasePart = {
				Property = {
					Size = createVector(0.0010000467, 4.0025187, 0.0010846853),
					CFrame = v * CFrame.new(0.0714416504, -17.3158951, 0.135575294, -1, 0, 0, 0, 1, 0, 0, 0, -1),
					Color = Color3.new(0.337255, 0, 0.00392157),
					Transparency = 0
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Circular
				}
			}
		},
		[v2.ImpactIN] = {
			General = {
				Offset = CFrame.new(0, -15.2184057, 0, -1, 0, 0, 0, 1, 0, 0, 0, -1),
				Tween_Duration = 0.2,
				Transparency = 0
			},
			BasePart = {
				Property = {
					Size = createVector(0.0014166668, 17, 0.0014166668),
					CFrame = v * CFrame.new(0, -10.3760834, 0, -1, 0, 0, 0, 1, 0, 0, 0, -1),
					Color = Color3.new(1, 0.309804, 0.321569),
					Transparency = 0
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Exponential
				}
			}
		},
		[v2.WindSidesOut2] = {
			General = {
				Offset = CFrame.new(0.499969482, -9.90991497, 0.25, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				Tween_Duration = 0.7,
				Transparency = 0
			},
			BasePart = {
				Property = {
					Size = createVector(8.992663, 9.54768, 8.992663),
					CFrame = v * CFrame.new(0.5, -15.6022396, 0.25, 1, 0, 0, 0, 1, 0, 0, 0, 1),
					Color = Color3.new(0.639216, 0.635294, 0.647059),
					Transparency = 1
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Cubic
				}
			},
			Mesh = {
				Property = {
					Offset = createVector(0, 0, 0),
					Scale = createVector(8.992664, 9.54768, 8.992664),
					VertexColor = createVector(1, 1, 1)
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Cubic
				}
			},
			Decal = {
				Property = {
					Color3 = Color3.new(1.96078, 1.96078, 1.96078),
					Transparency = 1
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Cubic
				}
			}
		},
		[v2.RingDown] = {
			General = {
				Offset = CFrame.new(0.103820801, -16.3303814, 0.249743462, -1, 0, 0, 0, 1, 0, 0, 0, -1),
				Tween_Duration = 0.3,
				Transparency = 0.3
			},
			BasePart = {
				Property = {
					Size = createVector(9.004215, 0.8122597, 9.004217),
					CFrame = v * CFrame.new(0.103820801, -18.6988983, 0.249743462, -1, 0, 0, 0, 1, 0, 0, 0, -1),
					Color = Color3.new(0.705882, 0.705882, 0.705882),
					Transparency = 1
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Exponential
				}
			}
		},
		[v2.RedSpikyout] = {
			General = {
				Offset = CFrame.new(0.499969482, -19.2849121, 0.25, 1, 0, 0, 0, 1, 0, 0, 0, 1),
				Tween_Duration = 1,
				Transparency = 0.8
			},
			BasePart = {
				Property = {
					Size = createVector(13.75, 11.292545, 13.75),
					CFrame = v * CFrame.new(0.5, -13.7298069, 0.25, 1, 0, 0, 0, 1, 0, 0, 0, 1),
					Color = Color3.new(0.639216, 0.635294, 0.647059),
					Transparency = 1
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Exponential
				}
			},
			Mesh = {
				Property = {
					Offset = createVector(0, 0, 0),
					Scale = createVector(13.750851, 11.292544, 13.750851),
					VertexColor = createVector(1, 1, 1)
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Exponential
				}
			},
			Decal = {
				Property = {
					Color3 = Color3.new(1.96078, 1.96078, 1.96078),
					Transparency = 1
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Exponential
				}
			}
		}
	}

	for k, v4 in pairs(v3) do
		if not (k and k:FindFirstChild("Start")) then
			continue
		end

		local v5 = k
		local v6 = v4

		local function Emit()
			local clone = v5.Start:Clone()
			game.Debris:AddItem(clone, 10)
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

			if v6.Decal then
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(
					clone:FindFirstChildOfClass("Decal"),
					TweenInfo.new(
						v6.General.Tween_Duration,
						v6.Decal.Tween.Easing_Style,
						v6.Decal.Tween.Easing_Direction
					),
					v6.Decal.Property
				):Play()
			end

			if v6.Mesh then
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(
					clone:FindFirstChildOfClass("SpecialMesh"),
					TweenInfo.new(v6.General.Tween_Duration, v6.Mesh.Tween.Easing_Style, v6.Mesh.Tween.Easing_Direction),
					v6.Mesh.Property
				):Play()
			end

			task.delay(v6.General.Tween_Duration, clone.Destroy, clone)
		end

		task.spawn(Emit)
	end
end