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
	local fajinFX = game.ReplicatedStorage.Emotes.VFX.VfxMods.FajinFX
	local v2 = {
		back2 = fajinFX.VFXassets.DashMeshes.back2,
		BackWindAlpha = fajinFX.VFXassets.DashMeshes.BackWindAlpha,
		forwardimpact = fajinFX.VFXassets.DashMeshes.forwardimpact,
		CircleForward = fajinFX.VFXassets.DashMeshes.CircleForward,
		WindImpactfast = fajinFX.VFXassets.DashMeshes.WindImpactfast,
		back1 = fajinFX.VFXassets.DashMeshes.back1
	}
	local v3 = {
		[v2.forwardimpact] = {
			General = {
				Offset = CFrame.new(0.0001371658, -0.00225971499, 30.0935974, -1, 0, 0, 0, 0, 1, 0, 1, 0),
				Tween_Duration = 0.3,
				Transparency = 0.3
			},
			BasePart = {
				Property = {
					Size = createVector(0.001, 115.75, 0.001),
					CFrame = v * CFrame.new(0.0001371658, -0.00225971499, -5.16384888, -1, 0, 0, 0, 0, 1, 0, 1, 0),
					Color = Color3.new(0.705882, 0.705882, 0.705882),
					Transparency = 1
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Cubic
				}
			}
		},
		[v2.back1] = {
			General = {
				Offset = CFrame.new(
					0.0001371658,
					-0.00225971499,
					-17.2719269,
					0.998524547,
					0,
					-0.0543023348,
					-0.0543023348,
					0,
					-0.998524547,
					0,
					1,
					0
				),
				Tween_Duration = 1,
				Transparency = 0.7
			},
			BasePart = {
				Property = {
					Size = createVector(58.961674, 30.339443, 55.51838),
					CFrame = v * CFrame.new(
						0.000257503649,
						-0.00223922194,
						19.9747314,
						-0.975736916,
						0,
						0.218946189,
						0.218946189,
						0,
						0.975736916,
						0,
						0.99999994,
						0
					),
					Color = Color3.new(0.705882, 0.705882, 0.705882),
					Transparency = 1
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Circular
				}
			}
		},
		[v2.back2] = {
			General = {
				Offset = CFrame.new(
					0.0001371658,
					-0.00225971499,
					11.9984131,
					0.999996424,
					0,
					-0.00267346203,
					-0.00267346203,
					0,
					-0.999996424,
					0,
					1,
					0
				),
				Tween_Duration = 2.5,
				Transparency = 0.88
			},
			BasePart = {
				Property = {
					Size = createVector(80.495445, 52.738983, 77.47171),
					CFrame = v * CFrame.new(
						0.0000347151072,
						-0.00183989527,
						76.4619141,
						-0.999637127,
						0,
						-0.0269395411,
						-0.0269395411,
						0,
						0.999637127,
						0,
						1,
						0
					),
					Color = Color3.new(0.705882, 0.705882, 0.705882),
					Transparency = 1
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Exponential
				}
			}
		},
		[v2.CircleForward] = {
			General = {
				Offset = CFrame.new(0.0001371658, -0.00225971499, -8.32484436, -1, 0, 0, 0, 0, 1, 0, 1, 0),
				Tween_Duration = 0.6,
				Transparency = 0.3
			},
			BasePart = {
				Property = {
					Size = createVector(23.478455, 0.12980652, 23.478458),
					CFrame = v * CFrame.new(0.0001371658, -0.00225971499, -43.0989532, -1, 0, 0, 0, 0, 1, 0, 1, 0),
					Color = Color3.new(0.705882, 0.705882, 0.705882),
					Transparency = 1
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Quint
				}
			}
		},
		[v2.WindImpactfast] = {
			General = {
				Offset = CFrame.new(0.000405379076, -0.00238043279, 20.455719, 1, 0, 0, 0, 0, -1, 0, 1, 0),
				Tween_Duration = 0.25,
				Transparency = 0
			},
			BasePart = {
				Property = {
					Size = createVector(31.498941, 123.30646, 15.749471),
					CFrame = v * CFrame.new(0.000405379076, -0.00238043279, -41.1781921, 1, 0, 0, 0, 0, -1, 0, 1, 0),
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
					Scale = createVector(7.8747354, 123.30646, 7.8747354),
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
		[v2.BackWindAlpha] = {
			General = {
				Offset = CFrame.new(0.000405379076, -0.00238043279, 8.33016968, 1, 0, 0, 0, 0, -1, 0, 1, 0),
				Tween_Duration = 2,
				Transparency = 0
			},
			BasePart = {
				Property = {
					Size = createVector(131.52893, 104.55983, 65.764465),
					CFrame = v * CFrame.new(
						0.000405379076,
						-0.00238043279,
						23.9484863,
						-0.985807538,
						0,
						-0.167879447,
						-0.167879447,
						0,
						0.985807538,
						0,
						1,
						0
					),
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
					Scale = createVector(32.882233, 104.55983, 32.882233),
					VertexColor = createVector(1, 1, 1)
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Cubic
				}
			},
			Decal = {
				Property = {
					Color3 = Color3.new(1.17647, 1.17647, 1.17647),
					Transparency = 1
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Cubic
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
			task.delay(10, function()
				if clone and clone.Parent then
					clone:Destroy("")
				end
			end)
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