local Players = game:GetService("Players")
local OutfitCodec = require(game.ReplicatedStorage.OutfitCodec)
local v = {}
local v2 = 0

local function visible(parent)
	if not parent.Parent or parent.AbsoluteSize.X < 1 or parent.AbsoluteSize.Y < 1 then
		return false
	end

	local absolutePosition = parent.AbsolutePosition
	local absoluteSize = parent.AbsoluteSize

	while parent do
		if parent:IsA("GuiObject") then
			if not parent.Visible then
				return false
			end

			if parent:IsA("ScrollingFrame") or parent.ClipsDescendants then
				local absolutePosition2 = parent.AbsolutePosition
				local absoluteSize2 = parent.AbsoluteSize

				if absolutePosition.Y + absoluteSize.Y < absolutePosition2.Y or absolutePosition.Y > absolutePosition2.Y + absoluteSize2.Y or absolutePosition.X + absoluteSize.X < absolutePosition2.X or absolutePosition.X > absolutePosition2.X + absoluteSize2.X then
					return false
				end
			end
		elseif parent:IsA("ScreenGui") then
			return parent.Enabled
		end

		parent = parent.Parent
	end

	return false
end

local function fit(data)
	if not (data.model and data.model.Parent) then
		return
	end

	local boundingBox, v3 = data.model:GetBoundingBox()
	local v4 = math.max(0.25, data.frame.AbsoluteSize.X / math.max(1, data.frame.AbsoluteSize.Y))
	local v5 = (math.max(v3.Y, v3.X / v4) / 0.630597577757967 + v3.Z * 0.65) * data.zoom
	local v6 = math.cos(data.pitch) * v5
	data.camera.CFrame = CFrame.lookAt(
		boundingBox.Position + Vector3.new(
			math.sin(data.angle) * v6,
			math.sin(data.pitch) * v5,
			-math.cos(data.angle) * v6
		),
		boundingBox.Position
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clear(state)
	if state.world then
		state.world:Destroy()
		state.world = nil
	end

	if state.camera then
		state.camera:Destroy()
		state.camera = nil
	end

	state.model = nil
	state.ready = false

	if state.message and state.message.Parent then
		state.message.Text = "Loading preview…"
		state.message.Visible = true
	end
end

task.spawn(function()
	while true do
		task.wait(0.2)

		for k in pairs(v) do
			if k.alive and k.frame.Parent then
				if visible(k.frame) then
					k.lastVisible = os.clock()

					if not k.ready and not k.loading and not k.failed and v2 < 2 then
						k.loading = true
						v2 += 1
						local v3 = k
						task.spawn(function()
							local decoded = nil
							local folder = nil
							local v4 = pcall(function()
								decoded = OutfitCodec.decode(v3.appearance)
								folder = Players:CreateHumanoidModelFromDescriptionAsync(
									decoded,
									v3.rig == "R6" and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15
								)
							end)

							if decoded then
								decoded:Destroy()
							end

							if v4 and folder and v3.alive and v3.frame.Parent and visible(v3.frame) then
								for i, descendant in folder:GetDescendants() do
									if descendant:IsA("LuaSourceContainer") or descendant:IsA("Sound") then
										descendant:Destroy()
									elseif descendant:IsA("BasePart") then
										descendant.CanCollide = false
									end
								end

								local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

								if humanoidRootPart then
									humanoidRootPart.Anchored = true
								end

								folder:PivotTo(CFrame.new())
								v3.world = Instance.new("WorldModel")
								v3.world.Parent = v3.frame
								folder.Parent = v3.world
								v3.model = folder
								v3.camera = Instance.new("Camera")
								v3.camera.FieldOfView = 35
								v3.camera.Parent = v3.frame
								v3.frame.CurrentCamera = v3.camera
								v3.ready = true
								v3.message.Visible = false
								fit(v3)
							elseif folder then
								folder:Destroy()
							end

							if not v4 then
								v3.failed = true

								if v3.alive and v3.message.Parent then
									v3.message.Text = "Preview unavailable. You can still wear this outfit."
								end
							end

							v3.loading = false
							v2 -= 1
						end)
					end
				elseif k.ready and os.clock() - k.lastVisible > 5 then
					clear(k) -- equivalent call inferred; original call site unknown
				end
			else
				clear(k) -- equivalent call inferred; original call site unknown
				v[k] = nil
			end
		end
	end
end)
return {
	Mount = function(parent, appearance, rig, p3)
		local v3 = {
			frame = parent,
			appearance = appearance,
			rig = rig,
			angle = 0,
			pitch = 0,
			zoom = 1,
			alive = true,
			lastVisible = os.clock()
		}
		local v4

		if p3 then
			local OutfitOrbitControls = require(game.ReplicatedStorage.OutfitOrbitControls)
			v4 = OutfitOrbitControls.Bind(parent, function(angle, pitch, zoom)
				v3.angle = angle
				v3.pitch = pitch
				v3.zoom = zoom
				fit(v3)
			end)
		else
			v4 = nil
		end

		v[v3] = true
		local absoluteSizeChangedConnection = parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			fit(v3)
		end)
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "PreviewStatus"
		textLabel.BackgroundTransparency = 1
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.Text = "Loading preview…"
		textLabel.TextColor3 = Color3.fromRGB(157, 168, 184)
		textLabel.Font = Enum.Font.GothamMedium
		textLabel.TextSize = 12
		textLabel.TextWrapped = true
		textLabel.ZIndex = parent.ZIndex + 1
		textLabel.Parent = parent
		v3.message = textLabel
		local class = {}
		local destroyingConnection = nil

		function class.Rotate(_, p4)
			v3.angle += p4
			fit(v3)
		end

		function class:Destroy()
			if not v3.alive then
				return
			end

			v3.alive = false
			v[v3] = nil
			absoluteSizeChangedConnection:Disconnect()

			if v4 then
				v4()
				v4 = nil
			end

			if destroyingConnection then
				destroyingConnection:Disconnect()
			end

			clear(v3) -- equivalent call inferred; original call site unknown
			textLabel:Destroy()
		end

		destroyingConnection = parent.Destroying:Once(function()
			class:Destroy()
		end)
		return class
	end
}