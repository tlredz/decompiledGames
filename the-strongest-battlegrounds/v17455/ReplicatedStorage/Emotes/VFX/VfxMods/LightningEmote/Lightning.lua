local createVector = vector.create
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- equivalent calls inferred from this helper; original call sites unknown
local function scheduleDestroy(instance)
	task.delay(15, function()
		if instance and instance.Parent then
			instance:Destroy()
		end
	end)
end

local random = Random.new()
local thrown = workspace.Thrown
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Built }
return function(data)
	local segments = data.segments
	local offset = data.offset or 1
	local move_offset = data.move_offset or 1
	local move_dur = data.move_dur or 0.1
	local animate_dur = data.animate_dur or 0.1
	local dur = data.dur
	local size = data.size
	local mode = data.mode or "part"
	local start_pos = data.start_pos
	local end_pos = data.end_pos
	local outline_transparency = data.outline_transparency or 1
	local outline_color = data.outline_color
	local material = data.material or Enum.Material.SmoothPlastic
	local start_color = data.start_color or Color3.fromRGB(255, 255, 255)
	local end_color = data.end_color or Color3.fromRGB(255, 255, 255)
	local ground_chance = data.ground_chance or 0
	local model = Instance.new("Model", thrown)
	scheduleDestroy(model) -- equivalent call inferred; original call site unknown
	local v = {}
	local v2 = {}

	if random:NextInteger(0, 100) < ground_chance then
		local v3 = start_pos + Vector3.new(random:NextInteger(-1, 1), -1, random:NextInteger(-1, 1))
		local lookVector = CFrame.new(start_pos, v3).LookVector
		local magnitude = (start_pos - end_pos).Magnitude
		local raycastResult = workspace:Raycast(start_pos, lookVector * magnitude, raycastParams)

		if raycastResult then
			end_pos = raycastResult.Position
		end
	end

	for i = 0, segments do
		local vector2 = Vector3.new(
			random:NextInteger(-offset, offset),
			random:NextInteger(-offset, offset),
			random:NextInteger(-offset, offset)
		)
		local v3 = start_pos + (end_pos - start_pos).Unit * i * (end_pos - start_pos).Magnitude / segments
		local v4 = (i == 0 or i == segments) and createVector(0, 0, 0) or vector2
		table.insert(v, v3 + v4)
		table.insert(v2, v3 + v4 * (move_offset * (math.random(1, 2) == 1 and 1 or -1)))
	end

	for i = 1, #v do
		local v3 = v[i]
		local v4 = v[i + 1] or end_pos
		local v5 = v2[i]
		local v6 = v2[i + 1] or end_pos
		local magnitude = (v3 - v4).Magnitude
		local magnitude2 = (v5 - v6).Magnitude

		if mode == "part" then
			local lerped = start_color:Lerp(end_color, i / #v)
			local part = Instance.new("Part", model)
			scheduleDestroy(part) -- equivalent call inferred; original call site unknown
			part.Anchored = true
			part.CFrame = CFrame.new(v3, v4)
			part.Size = Vector3.new(size, size, 0)
			part.Material = material
			part.Color = lerped
			part.Locked = true
			part.Transparency = 1
			local magnitude3 = magnitude
			local v9 = v3
			local v10 = v4
			task.delay(animate_dur * (i / #v), function()
				part.Transparency = 0
				TweenService:Create(part, TweenInfo.new(animate_dur * (1 / #v) / 2), {
					Size = Vector3.new(size, size, magnitude3 + 1),
					CFrame = CFrame.new((v9 + v10) / 2, v10)
				}):Play()
			end)
			local v11 = part
			local v12 = v5
			local v13 = v6
			local magnitude4 = magnitude2
			local v15 = i
			task.delay(animate_dur * (i / #v) * 2, function()
				TweenService:Create(v11, TweenInfo.new(move_dur, Enum.EasingStyle.Sine), {
					CFrame = CFrame.new((v12 + v13) / 2, v13),
					Size = Vector3.new(size, size, magnitude4 + 1)
				}):Play()
				task.delay(dur * (v15 / #v), function()
					TweenService:Create(v11, TweenInfo.new(0.5), {
						Size = v11.Size * createVector(0, 0, 1)
					}):Play()
				end)
			end)
		elseif mode == "beam" then
			local lerped = start_color:Lerp(end_color, (i - 1) / #v)
			local lerped2 = start_color:Lerp(end_color, i / #v)
			local colorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, lerped),
				ColorSequenceKeypoint.new(1, lerped2)
			})
			local width = (size - 0) * (i - 1) / #v + 0
			local width2 = (size - 0) * i / #v + 0
			local clone = script.Beam:Clone()
			scheduleDestroy(clone) -- equivalent call inferred; original call site unknown
			local A1 = clone.A1
			local beam = A1.Beam
			clone.Anchored = true
			clone.CFrame = CFrame.new(v3, v4)
			clone.Material = material
			clone.Locked = false
			clone.Transparency = 1
			clone.Parent = model
			beam.Color = colorSequence
			beam.Width0 = width
			beam.Width1 = width2
			local magnitude3 = magnitude
			task.delay(move_dur * (i / #v), function()
				TweenService:Create(A1, TweenInfo.new(move_dur / #v), {
					CFrame = CFrame.new(0, 0, -(magnitude3 + 0.5)) * CFrame.Angles(0, -0, 0)
				}):Play()
			end)
			local v12 = v5
			local v13 = v6
			local A12 = A1
			local magnitude4 = magnitude2
			task.delay(animate_dur + move_dur, function()
				TweenService:Create(clone, TweenInfo.new(animate_dur / #v, Enum.EasingStyle.Sine), {
					CFrame = CFrame.new(v12, v13)
				}):Play()
				TweenService:Create(A12, TweenInfo.new(animate_dur / #v, Enum.EasingStyle.Sine), {
					CFrame = CFrame.new(0, 0, -(magnitude4 + 0.5)) * CFrame.Angles(0, -0, 0)
				}):Play()
				TweenService:Create(beam, TweenInfo.new(animate_dur / #v, Enum.EasingStyle.Sine), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end)
		end
	end

	if outline_color and mode == "part" then
		local highlight = Instance.new("Highlight", model)
		scheduleDestroy(highlight) -- equivalent call inferred; original call site unknown
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.FillTransparency = 1
		highlight.OutlineColor = outline_color
		highlight.OutlineTransparency = outline_transparency
	end

	Debris:AddItem(model, dur + move_dur + animate_dur + 0.5)
end