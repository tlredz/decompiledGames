local createVector = vector.create
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
return {
	new = function(instance, onActivated)
		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		local v = {}
		local v2 = {}
		local freecamControls = instance:WaitForChild("FreecamControls")
		local DisguiseCamera = require(instance:WaitForChild("DisguiseCamera"))
		local v3 = DisguiseCamera.Start()

		local function hideUI()
			local enabledsByScreenGui = {}
			local connections = {}

			local function hide(screenGui)
				if screenGui:IsA("ScreenGui") and screenGui ~= instance then
					enabledsByScreenGui[screenGui] = screenGui.Enabled
					screenGui.Enabled = false
					table.insert(connections, screenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
						if screenGui.Enabled then
							screenGui.Enabled = false
						end
					end))
				end
			end

			local coreGuiEnableds = {}

			for _, child in playerGui:GetChildren() do
				hide(child)
			end

			local childAddedConnection = playerGui.ChildAdded:Connect(hide)

			for _, v4 in Enum.CoreGuiType:GetEnumItems() do
				if v4 == Enum.CoreGuiType.All then
					continue
				end

				local v5 = v4
				pcall(function()
					coreGuiEnableds[v5] = StarterGui:GetCoreGuiEnabled(v5)
					StarterGui:SetCoreGuiEnabled(v5, false)
				end)
			end

			return function()
				childAddedConnection:Disconnect()

				for _, connection in connections do
					connection:Disconnect()
				end

				for k, enabled in enabledsByScreenGui do
					if k.Parent then
						k.Enabled = enabled
					end
				end

				for k, v4 in coreGuiEnableds do
					local v5 = k
					local v6 = v4
					pcall(function()
						StarterGui:SetCoreGuiEnabled(v5, v6)
					end)
				end
			end
		end

		local function hideNameplates()
			local v4 = {}
			local connections = {}

			-- equivalent calls inferred from this helper; original call sites unknown
			local function hide(descendant)
				if v4[descendant] ~= nil then
					return
				end

				if descendant:IsA("Humanoid") then
					v4[descendant] = descendant.DisplayDistanceType
					descendant.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
				elseif descendant:IsA("BillboardGui") then
					v4[descendant] = descendant.Enabled
					descendant.Enabled = false
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function character(folder)
				for _, descendant in folder:GetDescendants() do
					hide(descendant) -- equivalent call inferred; original call site unknown
				end

				table.insert(connections, folder.DescendantAdded:Connect(hide))
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function watch(player)
				if player.Character then
					character(player.Character) -- equivalent call inferred; original call site unknown
				end

				table.insert(connections, player.CharacterAdded:Connect(character))
			end

			for _, v5 in Players:GetPlayers() do
				watch(v5) -- equivalent call inferred; original call site unknown
			end

			table.insert(connections, Players.PlayerAdded:Connect(watch))
			return function()
				for _, connection in connections do
					connection:Disconnect()
				end

				for instance2, v5 in v4 do
					if not instance2.Parent then
						continue
					end

					if instance2:IsA("Humanoid") then
						instance2.DisplayDistanceType = v5
					elseif instance2:IsA("BillboardGui") then
						instance2.Enabled = v5
					end
				end
			end
		end

		local function freecam()
			local v4 = assert(workspace.CurrentCamera)
			local v5 = {
				Type = v4.CameraType,
				Subject = v4.CameraSubject,
				CFrame = v4.CFrame,
				Focus = v4.Focus,
				Fov = v4.FieldOfView,
				Mouse = UserInputService.MouseBehavior,
				Icon = UserInputService.MouseIconEnabled
			}
			local position = v4.CFrame.Position
			local orientation, v6 = v4.CFrame:ToOrientation()
			local v7 = createVector(0, 0, 0)
			local v8 = {}
			local v9 = {}
			local zero = Vector2.zero
			local zero2 = Vector2.zero
			local v10 = 0
			local v11 = 0
			local v12 = nil
			local selectedObject = GuiService.SelectedObject
			GuiService.SelectedObject = nil
			freecamControls.Visible = true
			freecamControls.Hint.Text = UserInputService.TouchEnabled and "FREECAM  •  Drag to look" or "FREECAM  •  WASD / sticks · Q/E rise · Shift boost"

			local function action(_, p, p2)
				local v13 = UserInputService:GetFocusedTextBox() ~= nil or instance.Root.Visible

				if p2.KeyCode == Enum.KeyCode.Thumbstick1 then
					local v14

					if v13 then
						v14 = Vector2.zero
					else
						v14 = Vector2.new(p2.Position.X, p2.Position.Y)
					end

					zero = v14
				elseif p2.KeyCode == Enum.KeyCode.Thumbstick2 then
					local v14

					if v13 then
						v14 = Vector2.zero
					else
						v14 = Vector2.new(p2.Position.X, p2.Position.Y)
					end

					zero2 = v14
				elseif p2.KeyCode == Enum.KeyCode.ButtonR2 then
					v10 = v13 and 0 or p2.Position.Z
				elseif p2.KeyCode == Enum.KeyCode.ButtonL2 then
					v11 = v13 and 0 or p2.Position.Z
				else
					local v14 = v8
					local keyCode = p2.KeyCode
					local v15 = not v13

					if v15 then
						if p == Enum.UserInputState.End then
							v15 = false
						else
							v15 = p ~= Enum.UserInputState.Cancel
						end
					end

					v14[keyCode] = v15
				end

				if v13 then
					return Enum.ContextActionResult.Pass
				end

				return Enum.ContextActionResult.Sink
			end

			ContextActionService:BindActionAtPriority(
				"CreatorFreecamMove",
				action,
				false,
				3000,
				Enum.KeyCode.W,
				Enum.KeyCode.A,
				Enum.KeyCode.S,
				Enum.KeyCode.D,
				Enum.KeyCode.Q,
				Enum.KeyCode.E,
				Enum.KeyCode.LeftShift,
				Enum.KeyCode.Thumbstick1,
				Enum.KeyCode.Thumbstick2,
				Enum.KeyCode.ButtonL2,
				Enum.KeyCode.ButtonR2
			)
			local connections = {}

			for _, v13 in {
				"Forward",
				"Back",
				"Left",
				"Right",
				"Up",
				"Down"
			} do
				local freecamControl = freecamControls[v13]
				local v14 = v13
				table.insert(connections, freecamControl.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
						v9[v14] = true
					end
				end))
				local v15 = v13
				table.insert(connections, freecamControl.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
						v9[v15] = nil
					end
				end))
			end

			table.insert(connections, freecamControls.Exit.Activated:Connect(onActivated))
			table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then
					return
				end

				if input.UserInputType == Enum.UserInputType.Touch then
					v12 = input
				end

				if input.UserInputType == Enum.UserInputType.MouseButton2 then
					UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
				end

				if input.KeyCode == Enum.KeyCode.ButtonB then
					onActivated()
				end
			end))
			table.insert(connections, UserInputService.InputEnded:Connect(function(input)
				if input == v12 then
					v12 = nil
				end

				if input.UserInputType == Enum.UserInputType.MouseButton2 then
					UserInputService.MouseBehavior = v5.Mouse
				end
			end))
			table.insert(connections, UserInputService.WindowFocusReleased:Connect(function()
				table.clear(v8)
				table.clear(v9)
				zero = Vector2.zero
				zero2 = Vector2.zero
				v10 = 0
				v11 = 0
				UserInputService.MouseBehavior = v5.Mouse
			end))
			table.insert(connections, UserInputService.InputChanged:Connect(function(input, gameProcessed)
				if instance.Root.Visible then
					return
				end

				if input == v12 or input.UserInputType == Enum.UserInputType.MouseMovement and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
					v6 -= input.Delta.X * 0.003
					orientation = math.clamp(orientation - input.Delta.Y * 0.003, -1.5, 1.5)
				elseif not gameProcessed and input.UserInputType == Enum.UserInputType.MouseWheel then
					v4.FieldOfView = math.clamp(v4.FieldOfView - input.Position.Z * 4, 20, 100)
				end
			end))

			-- equivalent calls inferred from this helper; original call sites unknown
			local function pressed(p, p2: string)
				if v8[p] or v9[p2] then
					return 1
				end

				return 0
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function deadzone(p: number)
				if math.abs(p) > 0.15 then
					return p
				end

				return 0
			end

			v4.CameraType = Enum.CameraType.Scriptable
			RunService:BindToRenderStep("CreatorFreecam", Enum.RenderPriority.Camera.Value + 1, function(p)
				local v13 = math.min(p, 0.1)
				local visible = instance.Root.Visible

				if not visible then
					local v14 = v6
					v6 = v14 - deadzone(zero2.X) * v13 * 2
					local v15 = orientation
					local Y = zero2.Y
					orientation = math.clamp(v15 + deadzone(Y) * v13 * 2, -1.5, 1.5)
				end

				local vector2

				if visible then
					vector2 = createVector(0, 0, 0)
				else
					local v14 = pressed(Enum.KeyCode.D, "Right") -- equivalent call inferred; original call site unknown
					local v16 = v14 - ((v8[Enum.KeyCode.A] or v9.Left) and 1 or 0) + deadzone(zero.X)
					local v17 = pressed(Enum.KeyCode.E, "Up") -- equivalent call inferred; original call site unknown
					local v18 = v17 - ((v8[Enum.KeyCode.Q] or v9.Down) and 1 or 0) + v10 - v11
					local v19 = pressed(Enum.KeyCode.S, "Back") -- equivalent call inferred; original call site unknown
					local v20 = v19 - ((v8[Enum.KeyCode.W] or v9.Forward) and 1 or 0)
					local Y = zero.Y
					vector2 = Vector3.new(v16, v18, v20 - deadzone(Y))
				end

				if vector2.Magnitude > 1 then
					vector2 = vector2.Unit
				end

				local cframe = CFrame.fromOrientation(orientation, v6, 0)
				v7 = v7:Lerp(
					cframe:VectorToWorldSpace(vector2) * (v8[Enum.KeyCode.LeftShift] and 90 or 32),
					1 - math.exp(-12 * v13)
				)
				position += v7 * v13
				v4.CFrame = CFrame.new(position) * cframe
				v4.Focus = v4.CFrame * CFrame.new(0, 0, -30)
			end)
			return function()
				RunService:UnbindFromRenderStep("CreatorFreecam")
				ContextActionService:UnbindAction("CreatorFreecamMove")

				for _, connection in connections do
					connection:Disconnect()
				end

				freecamControls.Visible = false
				local v13 = v4
				local v14 = v4
				local type = v5.Type
				local subject = v5.Subject
				v13.CameraType = type
				v14.CameraSubject = subject
				local v15 = v4
				local v16 = v4
				local v17 = v4
				local cFrame = v5.CFrame
				local focus = v5.Focus
				local fov = v5.Fov
				v15.CFrame = cFrame
				v16.Focus = focus
				v17.FieldOfView = fov
				local v18 = UserInputService
				local v19 = UserInputService
				local mouse = v5.Mouse
				local icon = v5.Icon
				v18.MouseBehavior = mouse
				v19.MouseIconEnabled = icon
				local v20 = GuiService
				local selectedObject2

				if selectedObject and selectedObject.Parent then
					selectedObject2 = selectedObject
				end

				v20.SelectedObject = selectedObject2
			end
		end

		local v4 = {
			hideUI = false,
			freecam = false
		}
		local v5 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function reconcileUI()
			if v4.hideUI or v4.freecam then
				if not v5 then
					v5 = hideUI()
				end
			elseif v5 then
				v5()
				v5 = nil
			end
		end

		function v2.SetFreecamSettings(p)
			v4.freecam = v.freecam ~= nil and p.HideOtherUI == true
			freecamControls.Visible = v.freecam ~= nil and p.HideControls ~= true
			reconcileUI() -- equivalent call inferred; original call site unknown
		end

		function v2.Set(p: string, hideUI2: boolean, flag: boolean?, flag2: boolean?)
			if p == "hideUI" then
				v4.hideUI = hideUI2
				reconcileUI() -- equivalent call inferred; original call site unknown
			else
				if p == "freecam" then
					v4.freecam = hideUI2 and flag == true
					reconcileUI() -- equivalent call inferred; original call site unknown
				end

				if v[p] then
					v[p]()
					v[p] = nil
				end

				if not hideUI2 then
					return
				end

				if p == "freecam" then
					v.freecam = freecam()
					freecamControls.Visible = flag2 ~= true
				elseif p == "hideNameplates" then
					v.hideNameplates = hideNameplates()
				end
			end
		end

		function v2.Destroy()
			local v6 = v4
			v4.hideUI = false
			v6.freecam = false
			reconcileUI() -- equivalent call inferred; original call site unknown

			for k in v do
				v2.Set(k, false)
			end

			v3()
		end

		return v2
	end
}