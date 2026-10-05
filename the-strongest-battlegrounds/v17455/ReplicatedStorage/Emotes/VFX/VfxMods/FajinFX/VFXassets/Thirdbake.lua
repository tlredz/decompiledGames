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
		ForwardWind1 = fajinFX.VFXassets.BeamFireMeshes.ForwardWind1,
		ForwardWind2 = fajinFX.VFXassets.BeamFireMeshes.ForwardWind2,
		Ringwind = fajinFX.VFXassets.BeamFireMeshes.Ringwind,
		Whitering = fajinFX.VFXassets.BeamFireMeshes.Whitering,
		ForwardSharp = fajinFX.VFXassets.BeamFireMeshes.ForwardSharp,
		SidesOutmulti = fajinFX.VFXassets.BeamFireMeshes.SidesOutmulti,
		ReverseBulletWind = fajinFX.VFXassets.BeamFireMeshes.ReverseBulletWind,
		cylwind = fajinFX.VFXassets.BeamFireMeshes.cylwind,
		ForwardWind3 = fajinFX.VFXassets.BeamFireMeshes.ForwardWind3,
		BlackLines = fajinFX.VFXassets.BeamFireMeshes.BlackLines,
		Darkthing = fajinFX.VFXassets.BeamFireMeshes.Darkthing,
		blackconewindforward = fajinFX.VFXassets.BeamFireMeshes.blackconewindforward,
		benwind = fajinFX.VFXassets.BeamFireMeshes.benwind
	}
	local v3 = {
		[v2.SidesOutmulti] = {
			General = {
				Offset = CFrame.new(-0.0000615987447, -7.86534474e-6, 46.5763512, 1, 0, 0, 0, 0, 1, -0, -1, 0),
				Tween_Duration = 0.3,
				Transparency = 0
			},
			BasePart = {
				Property = {
					Size = createVector(0.001, 115, 0.001),
					CFrame = v * CFrame.new(-0.0000615987447, -7.86534474e-6, 1.50235808, 1, 0, 0, 0, 0, 1, -0, -1, 0),
					Color = Color3.new(1, 0.494118, 0.494118),
					Transparency = 0
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Exponential
				}
			}
		},
		[v2.ForwardSharp] = {
			General = {
				Offset = CFrame.new(-0.0000615987447, -7.86534474e-6, 49.2581139, -1, 0, 0, 0, 0, 1, 0, 1, 0),
				Tween_Duration = 0.3,
				Transparency = 0
			},
			BasePart = {
				Property = {
					Size = createVector(0.001, 110, 0.001),
					CFrame = v * CFrame.new(-0.0000615987447, -7.86534474e-6, 6.37729025, -1, 0, 0, 0, 0, 1, 0, 1, 0),
					Color = Color3.new(1, 0.486275, 0.45098),
					Transparency = 0
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Circular
				}
			}
		},
		[v2.ForwardWind3] = {
			General = {
				Offset = CFrame.new(-0.0000522556111, 0.000152079534, 47.8238602, 1, -0, 0, 0, 0, -1, -0, 1, 0),
				Tween_Duration = 2.5,
				Transparency = 0
			},
			BasePart = {
				Property = {
					Size = createVector(46.05156, 117.20247, 23.02578),
					CFrame = v * CFrame.new(
						-0.000113409449,
						0.000151830609,
						-12.3958445,
						-0.998298287,
						0,
						0.0583154038,
						0.0583154038,
						0,
						0.998298287,
						0,
						1,
						-0
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
					Scale = createVector(11.512891, 117.20246, 11.512891),
					VertexColor = createVector(1, 1, 1)
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Exponential
				}
			},
			Decal = {
				Property = {
					Color3 = Color3.new(1.17647, 1.17647, 1.17647),
					Transparency = 1
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Exponential
				}
			}
		},
		[v2.BlackLines] = {
			General = {
				Offset = CFrame.new(-0.0000615987447, -7.86534474e-6, 42.9908867, -1, 0, 0, 0, 0, 1, 0, 1, 0),
				Tween_Duration = 1,
				Transparency = 0
			},
			BasePart = {
				Property = {
					Size = createVector(9.801126, 89.6492, 9.25),
					CFrame = v * CFrame.new(
						0,
						0,
						-10.309124,
						0.994982183,
						-0,
						-0.100052647,
						-0.100052647,
						0,
						-0.994982183,
						0,
						1,
						0
					),
					Color = Color3.new(0, 0, 0),
					Transparency = 1
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Exponential
				}
			}
		},
		[v2.ForwardWind1] = {
			General = {
				Offset = CFrame.new(-0.0000615987447, -7.86534474e-6, 53.6304359, 1, -0, 0, 0, 0, -1, -0, 1, 0),
				Tween_Duration = 0.3,
				Transparency = 0
			},
			BasePart = {
				Property = {
					Size = createVector(15.574091, 55.700577, 15.574091),
					CFrame = v * CFrame.new(-0.0000615987447, -7.86534474e-6, -10.9642248, 1, -0, 0, 0, 0, -1, -0, 1, 0),
					Color = Color3.new(0.862745, 0.862745, 0.862745),
					Transparency = 1
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Exponential
				}
			}
		},
		[v2.ForwardWind2] = {
			General = {
				Offset = CFrame.new(-0.0000522556111, 0.000152079534, 47.8238602, 1, -0, 0, 0, 0, -1, -0, 1, 0),
				Tween_Duration = 1.2,
				Transparency = 0.5
			},
			BasePart = {
				Property = {
					Size = createVector(37.475513, 98.0789, 18.737757),
					CFrame = v * CFrame.new(
						-0.000113409449,
						0.000151830609,
						-2.83416128,
						-0.998298287,
						0,
						0.0583154038,
						0.0583154038,
						0,
						0.998298287,
						0,
						1,
						-0
					),
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
					Scale = createVector(9.368878, 98.078896, 9.368878),
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
		},
		[v2.ReverseBulletWind] = {
			General = {
				Offset = CFrame.new(0.0000102329568, 0.000175177716, 54.8037262, -1, 0, 0, 0, 0, -1, 0, -1, 0),
				Tween_Duration = 3,
				Transparency = 0.5
			},
			BasePart = {
				Property = {
					Size = createVector(80.843216, 90.328926, 40.421608),
					CFrame = v * CFrame.new(
						-0.000289529911,
						0.000276754814,
						9.79107857,
						-0.998298287,
						0,
						-0.0583153144,
						0.0583153144,
						0,
						-0.998298287,
						0,
						-1,
						0
					),
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
					Scale = createVector(20.210804, 90.32891, 20.210804),
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
		},
		[v2.cylwind] = {
			General = {
				Offset = CFrame.new(0.0000100105008, 0.000171369509, 57.5400505, -1, 0, 0, 0, 0, -1, 0, -1, 0),
				Tween_Duration = 3,
				Transparency = 0.9
			},
			BasePart = {
				Property = {
					Size = createVector(74.62338, 29.593338, 37.31169),
					CFrame = v * CFrame.new(
						0.0000709418819,
						0.000167810213,
						35.0434952,
						0.923879564,
						0,
						-0.382683396,
						0.382683426,
						0,
						0.923879564,
						-0,
						-1,
						0
					),
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
					Scale = createVector(18.655846, 29.593338, 18.655846),
					VertexColor = createVector(1, 1, 1)
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Exponential
				}
			},
			Decal = {
				Property = {
					Color3 = Color3.new(2.7451, 2.7451, 2.7451),
					Transparency = 1
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Exponential
				}
			}
		},
		[v2.benwind] = {
			General = {
				Offset = CFrame.new(-0.0000615987447, -7.86534474e-6, 43.4373665, -1, 0, 0, 0, 0, 1, 0, 1, 0),
				Tween_Duration = 2,
				Transparency = 0.8
			},
			BasePart = {
				Property = {
					Size = createVector(33.193832, 20.746803, 31.054735),
					CFrame = v * CFrame.new(
						0,
						0,
						-7.29210377,
						0.994982183,
						-0,
						-0.100052647,
						-0.100052647,
						0,
						-0.994982183,
						0,
						1,
						0
					),
					Color = Color3.new(0.666667, 0.666667, 0.666667),
					Transparency = 1
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Exponential
				}
			}
		},
		[v2.Whitering] = {
			General = {
				Offset = CFrame.new(-0.0000615987447, -7.86534474e-6, 51.8807373, 1, -0, 0, 0, 0, -1, -0, 1, 0),
				Tween_Duration = 0.3,
				Transparency = 0
			},
			BasePart = {
				Property = {
					Size = createVector(53.310646, 0.060653687, 53.310646),
					CFrame = v * CFrame.new(-0.0000615987447, -7.86534474e-6, -32.4943428, 1, -0, 0, 0, 0, -1, -0, 1, 0),
					Color = Color3.new(0.862745, 0.862745, 0.862745),
					Transparency = 1
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Exponential
				}
			}
		},
		[v2.blackconewindforward] = {
			General = {
				Offset = CFrame.new(9.34313448e-6, 0.000159944873, 59.0614738, -1, 0, 0, 0, 0, -1, 0, -1, 0),
				Tween_Duration = 1,
				Transparency = 0
			},
			BasePart = {
				Property = {
					Size = createVector(55.299877, 61.788467, 27.649939),
					CFrame = v * CFrame.new(
						-0.000291309552,
						0.000246289128,
						-4.47888422,
						0.968822122,
						0,
						-0.247757688,
						0.247757703,
						0,
						0.968822122,
						-0,
						-1,
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
					Scale = createVector(13.824969, 61.78846, 13.824969),
					VertexColor = createVector(1, 1, 1)
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Cubic
				}
			},
			Decal = {
				Property = {
					Color3 = Color3.new(0, 0, 0),
					Transparency = 1
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Cubic
				}
			}
		},
		[v2.Darkthing] = {
			General = {
				Offset = CFrame.new(-0.0000613762895, -4.05713308e-6, 50.2335739, 1, -0, 0, 0, 0, -1, -0, 1, 0),
				Tween_Duration = 1,
				Transparency = 0
			},
			BasePart = {
				Property = {
					Size = createVector(7.382347, 88.02216, 7.23744),
					CFrame = v * CFrame.new(
						-0.0000613762895,
						-4.05713308e-6,
						2.62205458,
						-0.999110639,
						0,
						-0.0421653204,
						-0.0421653241,
						0,
						0.999110639,
						0,
						1,
						0
					),
					Color = Color3.new(0, 0, 0),
					Transparency = 1
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Exponential
				}
			}
		},
		[v2.Ringwind] = {
			General = {
				Offset = CFrame.new(-0.0000615987447, -7.86534474e-6, 50.2721329, 1, -0, 0, 0, 0, -1, -0, 1, 0),
				Tween_Duration = 3,
				Transparency = 0.8
			},
			BasePart = {
				Property = {
					Size = createVector(105.912964, 20.700195, 99.08765),
					CFrame = v * CFrame.new(
						-4.44911166e-7,
						-7.61642241e-6,
						60.6463432,
						-0.966957271,
						0,
						0.254938602,
						0.254938602,
						0,
						0.966957271,
						0,
						1,
						-0
					),
					Color = Color3.new(0.862745, 0.862745, 0.862745),
					Transparency = 1
				},
				Tween = {
					Easing_Direction = Enum.EasingDirection.Out,
					Easing_Style = Enum.EasingStyle.Quart
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