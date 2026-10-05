local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local CopyText = require(game.ReplicatedStorage.Osiris.Widgets.CopyText)
local parentModule = require(script.Parent)
local Profiles = require(script.Parent.Profiles)
local StoryTarget = require(script.Parent.StoryTarget)
local StoryTeleporter = require(script.Parent.StoryTeleporter)
local v = {}
local v2 = {
	Label = "Tint Alpha",
	Field = "TintAlpha",
	Min = 0,
	Max = 1,
	Increment = 0.01
}
local v3 = {
	Pulse = {
		{
			Label = "Pulse Amplitude",
			Field = "Amplitude",
			Min = 0,
			Max = 1,
			Increment = 0.01
		},
		{
			Label = "Pulse Period",
			Field = "Period",
			Min = 0.05,
			Max = 10,
			Increment = 0.05
		}
	},
	GlobalMotion = {
		{
			Label = "Rise Damping",
			Field = "RiseDamping",
			Min = 0,
			Max = 2,
			Increment = 0.01
		},
		{
			Label = "Rise Frequency (Hz)",
			Field = "RiseFrequency",
			Min = 0.1,
			Max = 8,
			Increment = 0.1
		},
		{
			Label = "Fall Damping",
			Field = "FallDamping",
			Min = 0,
			Max = 2,
			Increment = 0.01
		},
		{
			Label = "Fall Frequency (Hz)",
			Field = "FallFrequency",
			Min = 0.1,
			Max = 8,
			Increment = 0.1
		}
	},
	Motion = {
		{
			Label = "Rise Damping x",
			Field = "RiseDamping",
			Min = 0,
			Max = 3,
			Increment = 0.05
		},
		{
			Label = "Rise Frequency x",
			Field = "RiseFrequency",
			Min = 0.05,
			Max = 3,
			Increment = 0.05
		},
		{
			Label = "Fall Damping x",
			Field = "FallDamping",
			Min = 0,
			Max = 3,
			Increment = 0.05
		},
		{
			Label = "Fall Frequency x",
			Field = "FallFrequency",
			Min = 0.05,
			Max = 3,
			Increment = 0.05
		}
	}
}
local v4 = {
	{
		Label = "Brightness",
		Field = "Brightness",
		Min = 0,
		Max = 3,
		Increment = 0.05
	},
	{
		Label = "Opacity",
		Field = "Opacity",
		Min = 0,
		Max = 2,
		Increment = 0.05
	},
	{
		Label = "Speed",
		Field = "Speed",
		Min = 0,
		Max = 4,
		Increment = 0.05
	},
	{
		Label = "Height",
		Field = "Height",
		Min = 0,
		Max = 2,
		Increment = 0.01
	}
}
local v5 = {
	{
		Label = "Opacity",
		Field = "Opacity",
		Min = 0,
		Max = 2,
		Increment = 0.05
	},
	{
		Label = "Height",
		Field = "Height",
		Min = 0,
		Max = 2,
		Increment = 0.01
	},
	{
		Label = "Scroll Speed",
		Field = "ScrollSpeed",
		Min = 0,
		Max = 4,
		Increment = 0.05
	},
	{
		Label = "Scroll Angle",
		Field = "ScrollAngle",
		Min = -180,
		Max = 180,
		Increment = 5
	},
	{
		Label = "Spin Speed (deg/s)",
		Field = "SpinSpeed",
		Min = -180,
		Max = 180,
		Increment = 1
	}
}
local v6 = {
	{
		Label = "Brightness",
		Field = "Brightness",
		Min = 0,
		Max = 3,
		Increment = 0.05
	},
	{
		Label = "Width",
		Field = "Width",
		Min = 0,
		Max = 3,
		Increment = 0.05
	},
	{
		Label = "Height",
		Field = "Height",
		Min = 0,
		Max = 2,
		Increment = 0.01
	},
	{
		Label = "Opacity",
		Field = "Opacity",
		Min = 0,
		Max = 2,
		Increment = 0.05
	},
	{
		Label = "Texture Speed",
		Field = "TextureSpeed",
		Min = 0,
		Max = 4,
		Increment = 0.05
	},
	{
		Label = "Light Emission",
		Field = "LightEmission",
		Min = 0,
		Max = 2,
		Increment = 0.05
	}
}
local v7 = {
	{
		Label = "Rate",
		Field = "Rate",
		Min = 0,
		Max = 4,
		Increment = 0.05
	},
	{
		Label = "Brightness",
		Field = "Brightness",
		Min = 0,
		Max = 3,
		Increment = 0.05
	},
	{
		Label = "Size",
		Field = "Size",
		Min = 0,
		Max = 3,
		Increment = 0.05
	},
	{
		Label = "Height",
		Field = "Height",
		Min = 0,
		Max = 2,
		Increment = 0.01
	},
	{
		Label = "Opacity",
		Field = "Opacity",
		Min = 0,
		Max = 2,
		Increment = 0.05
	},
	{
		Label = "Speed",
		Field = "Speed",
		Min = 0,
		Max = 4,
		Increment = 0.05
	},
	{
		Label = "Lifetime",
		Field = "Lifetime",
		Min = 0,
		Max = 4,
		Increment = 0.05
	},
	{
		Label = "Time Scale (max 1)",
		Field = "TimeScale",
		Min = 0,
		Max = 1,
		Increment = 0.01
	},
	{
		Label = "Light Emission",
		Field = "LightEmission",
		Min = 0,
		Max = 2,
		Increment = 0.05
	}
}
local v8 = {
	{
		Label = "Brightness",
		Field = "Brightness",
		Min = 0,
		Max = 3,
		Increment = 0.05
	},
	{
		Label = "Range",
		Field = "Range",
		Min = 0,
		Max = 3,
		Increment = 0.05
	}
}

for _, v9 in Profiles.MESH_KEYS do
	table.insert(v, {
		Kind = "Meshes",
		Key = v9
	})
end

for _, v9 in Profiles.BEAM_GROUP_KEYS do
	table.insert(v, {
		Kind = "Beams",
		Key = v9
	})
end

for _, v9 in Profiles.PARTICLE_GROUP_KEYS do
	table.insert(v, {
		Kind = "Particles",
		Key = v9
	})
end

table.insert(v, {
	Kind = "Lights"
})
local widget = Osiris.Widget

function loadProfile()
	local currentCamera = workspace.CurrentCamera
	local profile__WORLD_TELEPORTER = currentCamera:GetAttribute("Profile__WORLD_TELEPORTER")
	local preset__WORLD_TELEPORTER = currentCamera:GetAttribute("Preset__WORLD_TELEPORTER")

	if typeof(preset__WORLD_TELEPORTER) ~= "string" or not Profiles.PRESETS[preset__WORLD_TELEPORTER] then
		preset__WORLD_TELEPORTER = Profiles.PRESET_ORDER[1]
	end

	local v9

	if typeof(profile__WORLD_TELEPORTER) == "string" then
		v9 = Profiles.deserialize(profile__WORLD_TELEPORTER)
	end

	return v9 or Profiles.copy(Profiles.PRESETS[preset__WORLD_TELEPORTER]), preset__WORLD_TELEPORTER
end

function saveProfile(state)
	local currentCamera = workspace.CurrentCamera
	currentCamera:SetAttribute("Profile__WORLD_TELEPORTER", Profiles.serialize(state.Profile))
	currentCamera:SetAttribute("Preset__WORLD_TELEPORTER", state.PresetName)
	state.ExportText = Profiles.toLuau(state.Profile)
end

function isGroupVisible(data, p)
	if p.Kind == "Meshes" then
		return data.Meshes[p.Key]
	end

	if p.Kind == "Beams" then
		return data.Beams[p.Key]
	end

	if p.Kind == "Particles" then
		return data.Particles[p.Key]
	end

	return data.Lights
end

function setGroupVisible(state, p, lights: boolean)
	if p.Kind == "Meshes" then
		state.Meshes[p.Key] = lights
	elseif p.Kind == "Beams" then
		state.Beams[p.Key] = lights
	elseif p.Kind == "Particles" then
		state.Particles[p.Key] = lights
	else
		state.Lights = lights
	end
end

function refsOfKind(p: string)
	local result = {}

	for _, v9 in v do
		if v9.Kind == p then
			table.insert(result, v9)
		end
	end

	return result
end

function countHidden(p, p2)
	local count = 0

	for _, v9 in p2 or v do
		if not isGroupVisible(p, v9) then
			count += 1
		end
	end

	return count
end

function setRefsVisible(p, items, flag: boolean)
	for _, item in items do
		setGroupVisible(p.Visibility, item, flag)
	end

	p.IsVisibilityDirty = true
end

function isIsolated(p, list)
	return countHidden(p, list) == 0 and countHidden(p) == #v - #list
end

function setAllVisible(p, flag: boolean)
	setRefsVisible(p, v, flag)
end

function hiddenSuffix(p, list)
	local v9 = countHidden(p, list)

	if v9 == 0 then
		return ""
	end

	if v9 == #list then
		return " - hidden"
	end

	return (` - {v9} hidden`)
end

function visibilityControls(p, p2)
	local v9 = countHidden(p.Visibility, p2) == 0
	widget.SameLine({}, function()
		if widget.SmallButton({
			Arguments = {
				Text = v9 and "Hide" or "Show"
			}
		}).clicked() then
			setRefsVisible(p, p2, not v9)
		end

		if widget.SmallButton({
			Arguments = {
				Text = isIsolated(p.Visibility, p2) and "Un-isolate" or "Isolate"
			}
		}).clicked() then
			local isolated = isIsolated(p.Visibility, p2)
			setAllVisible(p, isolated)

			if not isolated then
				setRefsVisible(p, p2, true)
			end
		end
	end)
end

function loadPreset(p, presetName: string)
	p.Profile = Profiles.copy(Profiles.PRESETS[presetName])
	p.PresetName = presetName
	p.SyncFromProfile = true
	p.IsDirty = true
end

function numberKnob(p, p2, data)
	local state = Osiris.State(p2[data.Field])

	if p.SyncFromProfile then
		state:set(p2[data.Field])
	end

	widget.SliderNum({
		Arguments = {
			Text = data.Label,
			Min = data.Min,
			Max = data.Max,
			Increment = data.Increment,
			Format = "%.2f"
		},
		States = {
			number = state
		}
	})

	if state:get() ~= p2[data.Field] then
		p2[data.Field] = state:get()
		p.IsDirty = true
	end
end

function tintKnobs(p, p2)
	local state = Osiris.State(p2.Tint)

	if p.SyncFromProfile then
		state:set(p2.Tint)
	end

	widget.InputColor3({
		Arguments = {
			Text = "Tint"
		},
		States = {
			color = state
		}
	})

	if state:get() ~= p2.Tint then
		p2.Tint = state:get()
		p.IsDirty = true
	end

	numberKnob(p, p2, v2)
end

function subKnobs(p, p2, p3: string, p4: string)
	local v9 = p2[p3]

	if type(v9) ~= "table" then
		return
	end

	for _, v10 in v3[p4] do
		numberKnob(p, v9, v10)
	end
end

function groupSection(p, text: string, p3, items, p4: number?, p5)
	if p4 then
		text = `{text} ({p4})`
	end

	if p5 then
		text ..= hiddenSuffix(p.Visibility, { p5 })
	end

	widget.CollapsingHeader({
		Arguments = {
			Text = text,
			DefaultOpen = false
		}
	}, function()
		widget.Indent({}, function()
			if p5 then
				visibilityControls(p, { p5 })
			end

			for _, item in items do
				numberKnob(p, p3, item)
			end

			tintKnobs(p, p3)
			subKnobs(p, p3, "Pulse", "Pulse")
			subKnobs(p, p3, "Motion", "Motion")
		end)
	end)
end

function categoryHeader(p, p2: string, p3: string, callback)
	local v9 = refsOfKind(p2)
	widget.CollapsingHeader({
		Arguments = {
			Text = p3 .. hiddenSuffix(p.Visibility, v9),
			DefaultOpen = false
		}
	}, function()
		widget.Indent({}, function()
			visibilityControls(p, v9)
			callback()
		end)
	end)
end

function presetControls(p)
	local state = Osiris.State(p.PresetName)
	widget.ComboArray({
		Arguments = {
			Text = "Preset"
		},
		States = {
			index = state
		},
		Extra = {
			selectionArray = Profiles.PRESET_ORDER
		}
	})

	if state:get() ~= p.PresetName then
		loadPreset(p, state:get())
	end

	if widget.Button({
		Arguments = {
			Text = "Reload Preset"
		}
	}).clicked() then
		loadPreset(p, p.PresetName)
	end
end

function fireControls(p, object, p2)
	if p.FireCleanUp then
		widget.Text({
			Arguments = {
				Text = "firing..."
			}
		})
		return
	end

	if not widget.Button({
		Arguments = {
			Text = "Fire Teleport Once"
		}
	}).clicked() then
		return
	end

	local v9, v10 = StoryTarget.get(p2)
	local v11 = nil
	local finish

	finish = function()
		if p.FireCleanUp ~= finish then
			return
		end

		p.FireCleanUp = nil

		if v11 then
			v11()
		end

		v10()
	end

	v11 = object:Teleport(v9, function()
		task.delay(2, finish)
	end)
	p.FireCleanUp = finish
end

function placementControls(p)
	local state = Osiris.State(StoryTeleporter.DEFAULT_DISTANCE)
	widget.SliderNum({
		Arguments = {
			Text = "Camera Distance",
			Min = StoryTeleporter.MIN_DISTANCE,
			Max = StoryTeleporter.MAX_DISTANCE,
			Increment = 5,
			Format = "%.0f"
		},
		States = {
			number = state
		}
	})

	if widget.Button({
		Arguments = {
			Text = "Recenter On Camera"
		}
	}).clicked() then
		StoryTeleporter.placeInFrontOfCamera(p, state:get())
	end
end

function renderWindow(state, object, p)
	local counts = object:GetCounts()
	widget.Window({
		Arguments = {
			Title = "World Teleporter Effects"
		}
	}, function()
		presetControls(state)
		local profile = state.Profile
		local state2 = Osiris.State(false)
		widget.Checkbox({
			Arguments = {
				Text = "Freeze Animation"
			},
			States = {
				isChecked = state2
			}
		})

		if state2:changed() then
			object:SetPaused(state2:get())
		end

		widget.SeparatorText({
			Arguments = {
				Text = "Debug"
			}
		})
		fireControls(state, object, p)
		placementControls(p)

		if widget.Button({
			Arguments = {
				Text = "Replay Grow From Floor"
			}
		}).clicked() then
			object:CollapseHeights(0)
		end

		local v9 = countHidden(state.Visibility)

		if v9 > 0 and widget.Button({
			Arguments = {
				Text = `Show All ({v9} hidden)`
			}
		}).clicked() then
			setAllVisible(state, true)
		end

		widget.CollapsingHeader({
			Arguments = {
				Text = "Global",
				DefaultOpen = false
			}
		}, function()
			widget.Indent({}, function()
				for _, v10 in v4 do
					numberKnob(state, profile.Global, v10)
				end

				tintKnobs(state, profile.Global)
				subKnobs(state, profile.Global, "Pulse", "Pulse")
				subKnobs(state, profile.Global, "Motion", "GlobalMotion")
			end)
		end)
		categoryHeader(state, "Meshes", `Meshes ({counts.Meshes})`, function()
			for _, v10 in Profiles.MESH_KEYS do
				groupSection(state, v10, profile.Meshes[v10], v5, nil, {
					Kind = "Meshes",
					Key = v10
				})
			end
		end)
		categoryHeader(state, "Beams", "Beams", function()
			for _, v10 in Profiles.BEAM_GROUP_KEYS do
				groupSection(state, v10, profile.Beams[v10], v6, counts.Beams[v10], {
					Kind = "Beams",
					Key = v10
				})
			end
		end)
		categoryHeader(state, "Particles", "Particles", function()
			for _, v10 in Profiles.PARTICLE_GROUP_KEYS do
				groupSection(state, v10, profile.Particles[v10], v7, counts.Particles[v10], {
					Kind = "Particles",
					Key = v10
				})
			end
		end)
		categoryHeader(state, "Lights", `Lights ({counts.Lights})`, function()
			groupSection(state, "All Lights", profile.Lights, v8, counts.Lights, {
				Kind = "Lights"
			})
		end)
		widget.CollapsingHeader({
			Arguments = {
				Text = "Export",
				DefaultOpen = false
			}
		}, function()
			widget.Indent({}, function()
				if widget.Button({
					Arguments = {
						Text = "Print Profile"
					}
				}).clicked() then
					print(state.ExportText)
				end

				CopyText({
					Arguments = {
						Text = state.ExportText,
						Wrapped = true
					}
				})
			end)
		end)
	end)
	state.SyncFromProfile = false

	if state.IsDirty then
		state.IsDirty = false
		object:SetProfile(state.Profile)
		saveProfile(state)
	end

	if state.IsVisibilityDirty then
		state.IsVisibilityDirty = false
		object:SetVisibility(state.Visibility)
	end
end

return function()
	local source = StoryTeleporter.findSource()

	if not source then
		return function() end
	end

	local init = Osiris.Init
	local CoreGui = game:GetService("CoreGui")
	init(CoreGui, nil, true)
	local v9, v10 = StoryTeleporter.create(source, StoryTeleporter.DEFAULT_DISTANCE)
	local profile, presetName = loadProfile()
	local v13 = {
		Profile = profile,
		PresetName = presetName,
		IsDirty = false,
		SyncFromProfile = false,
		ExportText = Profiles.toLuau(profile),
		FireCleanUp = nil,
		Visibility = parentModule.allVisible(),
		IsVisibilityDirty = false
	}
	local v14 = nil
	local connection = nil
	task.spawn(function()
		local v15 = parentModule.new(v9, v13.Profile)
		v14 = v15
		connection = Osiris:Connect(function()
			renderWindow(v13, v15, v9)
		end)
	end)
	return function()
		if v13.FireCleanUp then
			v13.FireCleanUp()
			v13.FireCleanUp = nil
		end

		if connection then
			connection()
		end

		if v14 then
			v14:Destroy()
		end

		v10()
	end
end