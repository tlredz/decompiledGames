local Iris = require(game.ReplicatedStorage.Packages.Iris)
local MaterialIcons = require(game.ReplicatedStorage.Packages.MaterialIcons)
local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local parentModule = require(script.Parent)
local v = {
	Children = {
		Fruits = {
			Children = {
				Logia = {
					Children = {
						Magu = {
							Icon = MaterialIcons.local_florist,
							Value = 42
						},
						Goro = {
							Value = 31
						},
						Hie = {
							Value = 24
						}
					}
				},
				Paramecia = {
					Children = {
						Ope = {
							Value = 38
						},
						Gura = {
							Value = 29
						},
						Bari = {
							Value = 9
						}
					}
				},
				Zoan = {
					Children = {
						Tori = {
							Value = 18
						},
						Inu = {
							Value = 12
						}
					}
				}
			}
		},
		Swords = {
			Children = {
				Legendary = {
					Children = {
						Yoru = {
							Icon = MaterialIcons.hardware,
							Value = 34
						},
						Shusui = {
							Value = 21
						}
					}
				},
				Common = {
					Children = {
						Katana = {
							Value = 14
						},
						Cutlass = {
							Value = 11
						},
						Dagger = {
							Value = 6
						}
					}
				}
			}
		},
		Guns = {
			Children = {
				Flintlock = {
					Icon = MaterialIcons.gps_fixed,
					Value = 17
				},
				Cannon = {
					Value = 13
				},
				Musket = {
					Value = 8
				}
			}
		}
	}
}
return (UILabs.CreateIrisStory({
	name = "Treemap",
	summary = "Nested squarified treemap with headers and click to drill down.",
	controls = {
		Label = "Inventory",
		Height = 340,
		MaxDepth = 2,
		Padding = 2,
		HeaderHeight = 15,
		ShowLabels = true,
		ShowValues = false,
		MinLabelSize = 28,
		LegendOnBottom = false,
		LegendIconSize = 16
	},
	iris = Iris
}, function(p)
	local controls = p.controls
	local state = Osiris.State(v)
	local state2 = Osiris.State({})
	local state3 = Osiris.State(nil)
	local state4 = Osiris.State(nil)
	local connection = Osiris:Connect(function()
		Osiris.Widget.Window({
			Arguments = {
				Title = "Treemap Widget"
			}
		}, function()
			local v2 = state2:get()
			Osiris.Widget.Text({
				Arguments = {
					Text = not (#v2 > 0) and "viewing: / (root)" or `viewing: / {table.concat(v2, " / ")}`
				}
			})

			if Osiris.Widget.Button({
				Arguments = {
					Text = "Up one level"
				}
			}).clicked() and #v2 > 0 then
				local clone = table.clone(v2)
				table.remove(clone)
				state2:set(clone)
			end

			if parentModule({
				Id = "StoryTreemap",
				Arguments = {
					Text = controls.Label:get(),
					Height = math.floor((controls.Height:get())),
					MaxDepth = math.floor((controls.MaxDepth:get())),
					Padding = controls.Padding:get(),
					HeaderHeight = controls.HeaderHeight:get(),
					ShowLabels = controls.ShowLabels:get() == true,
					ShowValues = controls.ShowValues:get() == true,
					MinLabelSize = controls.MinLabelSize:get(),
					LegendOnBottom = controls.LegendOnBottom:get() == true,
					LegendIconSize = math.floor((controls.LegendIconSize:get())),
					ValueFormat = "%.0f"
				},
				States = {
					root = state,
					path = state2,
					hoveredMark = state3,
					clickedMark = state4
				}
			}).clicked() then
				local v3 = state4:get()

				if v3 ~= nil and not v3.IsLeaf then
					state2:set(v3.Path)
				end
			end

			local v3 = state3:get()
			Osiris.Widget.Text({
				Arguments = {
					Text = v3 == nil and "hovered: none" or `hovered: {table.concat(v3.Path, " / ")} = {string.format("%.0f", v3.Value)} ({string.format("%.1f", v3.Share * 100)}%)`
				}
			})
		end)
	end)
	return function()
		connection()
	end
end))