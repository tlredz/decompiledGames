local v = {}
local v2 = {}
local v3 = {
	{
		"Draw Internal Bone",
		"Draws a sphere with the specified radius of the bone around where SmartBone believes the bone is.",
		"DRAW_BONE"
	},
	{ "Draw Physical Bone", "Draws the actual bone objects CFrame with axis arrows.", "DRAW_PHYSICAL_BONE" },
	{ "Draw Root Part", "Draws a bounding box and fills in the root part.", "DRAW_ROOT_PART" },
	{ "Draw Bounding Box", "Draws the bounding box used for frustum culling.", "DRAW_BOUNDING_BOX" },
	{ "Draw Axis Limits", "Draws the axis limits for each bone.", "DRAW_AXIS_LIMITS" },
	{ "Draw Rotation Limits", "Draws the rotation limits for each bone.", "DRAW_ROTATION_LIMITS" },
	{
		"Draw Acceleration Info",
		"Draws the acceleration and the required values to derive it.",
		"DRAW_ACCELERATION_INFO"
	},
	{ "Draw Colliders", "Draws all the colliders this root object can collide with.", "DRAW_COLLIDERS" },
	{ "Draw Collider Influence", "Shows the sphere of influence around each collider.", "DRAW_COLLIDER_INFLUENCE" },
	{ "Draw Collider Awake", "Shows if a collider is awake or asleep.", "DRAW_COLLIDER_AWAKE" },
	{ "Draw Collider BroadPhase", "Shows if a collider isn't reaching NarrowPhase.", "DRAW_COLLIDER_BROADPHASE" },
	{ "Draw Fill Colliders", "Fills all colliders this root object can collide with.", "DRAW_FILL_COLLIDERS" },
	{
		"Draw Contacts",
		"Draws the position and normal of the points which bones collide with colliders.",
		"DRAW_CONTACTS"
	}
}

local function infoText(data, p)
	data.PushConfig({
		TextColor = data._config.TextDisabledColor
	})
	data.Text({ p })
	data.PopConfig()
end

local function helpMarker(data, p)
	data.PushConfig({
		TextColor = data._config.TextDisabledColor
	})
	local text = data.Text({ "(?)" })
	data.PopConfig()
	data.PushConfig({
		ContentWidth = UDim.new(0, 350)
	})

	if text.hovered() then
		data.Tooltip({ p })
	end

	data.PopConfig()
end

local function BoneEditor(data, state)
	local window = data.Window({ (`Editing bone: {state.Bone.Name}`) })
	window.isOpened.value = true
	state.Radius = data.InputNum({
		"Radius",
		0.1,
		0,
		1e999,
		"%.3f"
	}, {
		number = state.Radius
	}).number.value
	state.RotationLimit = data.InputNum({
		"Rotation Limit",
		0.1,
		0,
		180,
		"%.3f"
	}, {
		number = state.RotationLimit
	}).number.value
	state.Anchored = data.Checkbox({ "Anchored" }, {
		isChecked = state.Anchored
	}).isChecked.value
	data.Text("Axis Lock")
	data.Indent()
	data.SameLine()
	data.Text("X: ")
	local checkbox = data.Checkbox({ "" }, {
		isChecked = state.AxisLocked[1]
	})
	data.Text("Y: ")
	local checkbox2 = data.Checkbox({ "" }, {
		isChecked = state.AxisLocked[2]
	})
	data.Text("Z: ")
	local checkbox3 = data.Checkbox({ "" }, {
		isChecked = state.AxisLocked[3]
	})
	data.End()
	data.End()
	local state2 = data.State(Vector2.new(state.XAxisLimits.Min, state.XAxisLimits.Max))
	local state3 = data.State(Vector2.new(state.YAxisLimits.Min, state.YAxisLimits.Max))
	local state4 = data.State(Vector2.new(state.ZAxisLimits.Min, state.ZAxisLimits.Max))
	data.Text("Axis Limits")
	data.Indent()
	data.DragVector2({
		"X Axis Limit",
		0.05,
		nil,
		nil,
		{ "Min: %.2f", "Max: %.2f" }
	}, {
		number = state2
	})
	data.DragVector2({
		"Y Axis Limit",
		0.05,
		nil,
		nil,
		{ "Min: %.2f", "Max: %.2f" }
	}, {
		number = state3
	})
	data.DragVector2({
		"Z Axis Limit",
		0.05,
		nil,
		nil,
		{ "Min: %.2f", "Max: %.2f" }
	}, {
		number = state4
	})
	data.End()
	data.End()
	state.AxisLocked[1] = checkbox.isChecked.value
	state.AxisLocked[2] = checkbox2.isChecked.value
	state.AxisLocked[3] = checkbox3.isChecked.value
	state.XAxisLimits = NumberRange.new(state2:get().X, state2:get().Y)
	state.YAxisLimits = NumberRange.new(state3:get().X, state3:get().Y)
	state.ZAxisLimits = NumberRange.new(state4:get().X, state4:get().Y)

	if window.closed() then
		v[state] = nil
	end
end

local function ColliderEditor(data, state)
	local window = data.Window({ (`Editing collider of type: {state.Type}`) })
	window.isOpened.value = true
	local state2 = data.State(state.Type)
	local state3 = data.State(state.Scale)
	local state4 = data.State(state.Offset)
	local state5 = data.State(state.Rotation)
	data.Combo({ "Collider Type" }, {
		index = state2
	})
	data.Selectable({ "Box", "Box" }, {
		index = state2
	})
	data.Selectable({ "Sphere", "Sphere" }, {
		index = state2
	})
	data.Selectable({ "Capsule", "Capsule" }, {
		index = state2
	})
	data.End()
	data.DragVector3({
		"Scale",
		0.1,
		0,
		nil
	}, {
		number = state3
	})
	data.DragVector3({
		"Offset",
		0.1,
		nil,
		nil
	}, {
		number = state4
	})
	data.DragVector3({
		"Rotation",
		0.5,
		-180,
		180
	}, {
		number = state5
	})
	state.Type = state2:get()
	state.Scale = state3:get()
	state.Offset = state4:get()
	state.Rotation = state5:get()
	data.End()

	if window.closed() then
		v2[state] = nil
	end
end

return function(data, data2, p)
	local v4 = {}

	for _, boneTree in data2.BoneTrees do
		local rootPart = boneTree.RootPart
		local boneTrees = v4[rootPart]

		if not boneTrees then
			v4[rootPart] = {}
			boneTrees = v4[rootPart]
		end

		table.insert(boneTrees, boneTree)
	end

	for k, _ in v do
		local formatted = `{data2.ID} - {k.ParentIndex + 1}`
		data.PushId(formatted)
		BoneEditor(data, k)
		data.PopId()
	end

	for k, _ in v2 do
		local GUID = k.GUID
		data.PushId(GUID)
		ColliderEditor(data, k)
		data.PopId()
	end

	local count = #data2.BoneTrees
	local count2 = #data2.ColliderObjects
	local formatted = `{count} BoneTree{count == 1 and "" or "s"}`
	local formatted2 = `{count2} Collider{count2 == 1 and "" or "s"}`
	data.Window({
		`SmartBone Runtime Editor. {formatted}, {formatted2}`,
		[data.Args.Window.NoClose] = true
	})
	data.Tree({ "Debug Gizmos", true }, {
		isUncollapsed = true
	})

	for _, v6 in v3 do
		data.SameLine()
		data.Checkbox({ v6[1] }, {
			isChecked = p[v6[3]]
		})
		helpMarker(data, v6[2])
		data.End()
	end

	data.End()
	data.Separator()
	infoText(data, "Simulated Objects")

	for k, v6 in v4 do
		data.Tree((`{k.Name} - Root Part`))

		for k2, v7 in v6 do
			data.Tree((`BoneTree #{k2}`))
			infoText(
				data,
				`Throttled Update Rate: {string.format("%.1f", v7.UpdateRate)} / {string.format("%.1f", v7.Settings.UpdateRate)} fps`
			)
			infoText(data, `In View: {v7.InView}`)
			local state = data.State(v7.Settings.Constraint)
			local state2 = data.State(v7.Settings.WindType)
			local state3 = data.State(v7.Settings.UpdateRate)
			local state4 = data.State(v7.Settings.ActivationDistance)
			local state5 = data.State(v7.Settings.ThrottleDistance)
			data.SameLine()
			helpMarker(data, "The constraint used, distance is more flowy while spring is more rigid.")
			data.Combo({ "Constraint Type" }, {
				index = state
			})
			data.Selectable({ "Distance", "Distance" }, {
				index = state
			})
			data.Selectable({ "Spring", "Spring" }, {
				index = state
			})
			data.End()
			data.End()
			data.SameLine()
			helpMarker(
				data,
				"The wind solver used, sine is a smoother wind, noise is more chaotic and hybrid is a mix of the two."
			)
			data.Combo({ "Wind Type" }, {
				index = state2
			})
			data.Selectable({ "Sine", "Sine" }, {
				index = state2
			})
			data.Selectable({ "Noise", "Noise" }, {
				index = state2
			})
			data.Selectable({ "Hybrid", "Hybrid" }, {
				index = state2
			})
			data.End()
			data.End()
			data.SameLine()
			helpMarker(data, "The target update rate for the bone tree")
			data.SliderNum({
				"Update Rate",
				5,
				0,
				120
			}, {
				number = state3
			})
			data.End()
			data.SameLine()
			helpMarker(data, "The distance at which the bone tree stops updating")
			data.SliderNum({
				"Activation Distance",
				1,
				0,
				500
			}, {
				number = state4
			})
			data.End()
			data.SameLine()
			helpMarker(data, "The distance at which the bone tree starts throttling its update rate")
			data.SliderNum({
				"Throttle Distance",
				1,
				0,
				500
			}, {
				number = state5
			})
			data.End()
			v7.Settings.Constraint = state:get()
			v7.Settings.WindType = state2:get()
			v7.Settings.UpdateRate = state3:get()
			v7.Settings.ActivationDistance = state4:get()
			v7.Settings.ThrottleDistance = state5:get()
			data.Table({
				4,
				false,
				false,
				false
			})
			data.NextColumn()
			data.Text("Bone #")
			data.NextColumn()
			data.Text("Bone Name")
			data.NextColumn()
			data.Text("Parent #")
			data.NextColumn()
			data.Text("Edit")
			data.End()
			data.Table({ 4 })

			for k3, bone in v7.Bones do
				data.NextColumn()
				data.Text((tostring(k3)))
				data.NextColumn()
				data.Text(bone.Bone.Name)
				data.NextColumn()
				data.Text((tostring(bone.ParentIndex)))
				data.NextColumn()
				data.SameLine()
				data.Text("")

				if data.SmallButton({ "Edit" }).clicked() then
					v[bone] = true
				end

				data.End()
			end

			data.End()
			data.End()
		end

		data.End()
	end

	infoText(data, "Active Colliders")

	for _, colliderObject in data2.ColliderObjects do
		data.Tree({ colliderObject.m_Object.Name })
		infoText(data, "Colliders adorned to this object")
		data.Table({
			5,
			false,
			false,
			false
		})
		data.NextColumn()
		data.Text("Type")
		data.NextColumn()
		data.Text("Scale")
		data.NextColumn()
		data.Text("Offset")
		data.NextColumn()
		data.Text("Rotation")
		data.NextColumn()
		data.Text("Edit")
		data.End()
		data.Table({ 5 })

		for _, collider in colliderObject.Colliders do
			data.NextColumn()
			data.Text((tostring(collider.Type)))
			data.NextColumn()
			data.Text((tostring(collider.Scale)))
			data.NextColumn()
			data.Text((tostring(collider.Offset)))
			data.NextColumn()
			data.Text((tostring(collider.Rotation)))
			data.NextColumn()
			data.SameLine()
			data.Text("")

			if data.SmallButton({ "Edit" }).clicked() then
				v2[collider] = true
			end

			data.End()
		end

		data.End()
		data.End()
	end

	data.End()
end