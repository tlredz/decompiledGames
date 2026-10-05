local createVector = vector.create
local color = Color3.fromRGB(255, 111, 102)
return {
	new = function(parent, instance)
		local v = {}
		local v2 = {}
		local v3 = {}
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "ScrambleDamageFeedback"
		screenGui.IgnoreGuiInset = true
		screenGui.ResetOnSpawn = false
		screenGui.DisplayOrder = 5
		screenGui.Parent = parent
		local object = setmetatable({}, {
			__mode = "k"
		})

		-- equivalent calls inferred from this helper; original call sites unknown
		local function remove(i: number)
			v2[i].Text:Destroy()
			table.remove(v2, i)
		end

		function v.Hit(p, vector2: Vector3, p2: number)
			if not p.Parent or p2 <= 0 then
				return
			end

			local v4 = v3[p]

			if not v4 then
				local highlight = Instance.new("Highlight")
				highlight.Name = "ScrambleDamageFlash"
				highlight.Adornee = p
				highlight.FillColor = Color3.fromRGB(255, 70, 63)
				highlight.OutlineColor = Color3.fromRGB(255, 166, 142)
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.Parent = p
				v4 = {
					Highlight = highlight,
					Age = 0
				}
				v3[p] = v4
			end

			v4.Age = 0
			v4.Highlight.FillTransparency = 0.62
			v4.Highlight.OutlineTransparency = 0.15

			while #v2 >= 20 do
				remove(1) -- equivalent call inferred; original call site unknown
			end

			local clone = instance:Clone()
			clone.Name = "Amount"
			clone.AnchorPoint = Vector2.new(0.5, 0.5)
			local uDim = UDim2.fromScale(0.5, 0.5)
			local uDim2 = UDim2.fromOffset(150, 64)
			clone.Position = uDim
			clone.Size = uDim2
			clone.AutomaticSize = Enum.AutomaticSize.None
			clone.TextScaled = false
			clone.TextWrapped = false
			clone.RichText = false
			clone.TextSize = 48
			clone.Text = "-" .. tostring((math.round(p2)))
			clone.TextColor3 = Color3.fromRGB(255, 243, 226)
			clone.TextTransparency = 0
			clone.BackgroundTransparency = 1
			clone.TextStrokeTransparency = 1
			clone.Visible = true
			clone.Parent = screenGui
			local uIScale = clone:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
			uIScale.Scale = 0.78
			uIScale.Parent = clone
			local descendants = {}

			for _, descendant in clone:GetDescendants() do
				if descendant:IsA("UIStroke") then
					descendant.StrokeSizingMode = Enum.StrokeSizingMode.FixedSize
					descendant.Thickness = 2.5
					descendant.Color = Color3.fromRGB(30, 13, 16)
					descendant.Transparency = 0
					table.insert(descendants, descendant)
				elseif descendant:IsA("UITextSizeConstraint") then
					descendant:Destroy()
				end
			end

			local side = -(object[p] or -1)
			object[p] = side
			local currentCamera = workspace.CurrentCamera
			local v6, v7

			if currentCamera then
				v6, v7 = currentCamera:WorldToViewportPoint(vector2)
			else
				v6 = createVector(0, 0, 0)
				v7 = false
			end

			clone.Position = UDim2.fromOffset(v6.X + side * 14, v6.Y - 5)
			clone.Visible = currentCamera ~= nil and v7 and (currentCamera.CFrame.Position - vector2).Magnitude <= 120
			table.insert(v2, {
				Origin = vector2,
				Text = clone,
				Scale = uIScale,
				Strokes = descendants,
				Age = 0,
				Side = side
			})
		end

		function v.Step(p: number)
			for k, v4 in v3 do
				v4.Age += p

				if k.Parent and not (v4.Age >= 0.6) then
					local v5 = math.clamp((v4.Age - 0.08) / 0.52, 0, 1)
					local v6 = v5 * v5 * (3 - v5 * 2)
					v4.Highlight.FillTransparency = v6 * 0.38 + 0.62
					v4.Highlight.OutlineTransparency = v6 * 0.85 + 0.15
				else
					v4.Highlight:Destroy()
					v3[k] = nil
				end
			end

			for i = #v2, 1, -1 do
				local v4 = v2[i]
				v4.Age += p
				local age = v4.Age

				if age >= 0.95 then
					remove(i) -- equivalent call inferred; original call site unknown
				else
					local v5 = 1 - math.exp(-4 * age)
					local currentCamera = workspace.CurrentCamera
					local v6, v7

					if currentCamera then
						v6, v7 = currentCamera:WorldToViewportPoint(v4.Origin)
					else
						v7 = false
						v6 = createVector(0, 0, 0)
					end

					local text = v4.Text
					text.Visible = currentCamera ~= nil and v7 and (currentCamera.CFrame.Position - v4.Origin).Magnitude <= 120
					v4.Text.Position = UDim2.fromOffset(
						v6.X + v4.Side * (v5 * 38 + 14),
						v6.Y - 5 - 76 * age + 28 * age * age
					)
					v4.Scale.Scale = 1 - math.exp(-14 * age) * 0.22 * math.cos(24 * age)
					v4.Text.Rotation = v4.Side * 12 * math.sin(math.min(age / 0.7, 1) * 3.141592653589793 / 2)
					v4.Text.TextColor3 = Color3.fromRGB(255, 243, 226):Lerp(color, (math.clamp(age / 0.16, 0, 1)))
					local v9 = math.clamp((age - 0.55) / 0.4, 0, 1)
					v4.Text.TextTransparency = v9

					for _, stroke in v4.Strokes do
						stroke.Transparency = v9
					end
				end
			end
		end

		function v.Destroy()
			for i = #v2, 1, -1 do
				remove(i) -- equivalent call inferred; original call site unknown
			end

			for k, v4 in v3 do
				v4.Highlight:Destroy()
				v3[k] = nil
			end

			screenGui:Destroy()
		end

		return v
	end
}