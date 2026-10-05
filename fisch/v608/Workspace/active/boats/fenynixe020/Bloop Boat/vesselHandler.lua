local createVector = vector.create
local parent = script.Parent

repeat
	task.wait()
until parent:FindFirstChild("Base") ~= nil

local motor = parent:FindFirstChild("Base"):WaitForChild("Motor", 20)
local rot = parent.Base.Rot
local base = parent.Base
local owner = parent:WaitForChild("owner")
local plane0 = parent:WaitForChild("PlanePart"):WaitForChild("Plane0")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local Observers = require(ReplicatedStorage.packages.Observers)
local Net = require(ReplicatedStorage.packages.Net)
local Trove = require(ReplicatedStorage.packages.Trove)
local DeferredSignalHackaround = require(ReplicatedStorage.shared.modules.DeferredSignalHackaround)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local RayVisual = require(ReplicatedStorage.shared.utils.RayVisual)
local ZoneController = require(ReplicatedStorage.client.legacyControllers.ZoneController)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local rods = require(ReplicatedStorage2.shared.modules:WaitForChild("library"):WaitForChild("rods"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local vessels = require(ReplicatedStorage3.shared.modules:WaitForChild("vessels"))
local v = nil
local roslitBay = workspace.world.map:FindFirstChild("Roslit Bay")
local anglerMinigame = roslitBay and roslitBay:FindFirstChild("AnglerMinigame", true)
local remoteEvent = Net:RemoteEvent("ReturnToSurface")
local base0 = parent:WaitForChild("Base"):FindFirstChild("Base0")

if base0:FindFirstChild("idleSound") then
	local idleSound = parent:WaitForChild("Base"):FindFirstChild("Base0"):FindFirstChild("idleSound")
	idleSound.Playing = true
end

local v2 = {
	Unoccupied = nil,
	Idle = nil,
	Moving = nil
}
local animationController

if owner:FindFirstChildWhichIsA("AnimationController") then
	animationController = owner:FindFirstChildWhichIsA("AnimationController")
	v2.Unoccupied = animationController:LoadAnimation(animationController:FindFirstChild("Unoccupied"))
	v2.Idle = animationController:LoadAnimation(animationController:FindFirstChild("Idle"))
	v2.Active = animationController:LoadAnimation(animationController:FindFirstChild("Active"))
	task.wait()
else
	animationController = nil
end

local v3 = {}

for _, child in parent:GetChildren() do
	if child:IsA("Seat") or child:IsA("VehicleSeat") then
		Observers.observeProperty(child, "Occupant", function(instance)
			if not instance then
				return function() end
			end

			local parent2 = instance.Parent
			local playerFromCharacter = Players:GetPlayerFromCharacter(parent2)

			if not playerFromCharacter then
				return function() end
			end

			if playerFromCharacter == Players.LocalPlayer then
				return function() end
			end

			local maid = Trove.new()
			local maid2 = maid:Extend()

			-- equivalent calls inferred from this helper; original call sites unknown
			local function toggleHandler(value)
				if value == nil then
					value = false
				end

				instance.AutoRotate = not value
				instance:SetStateEnabled(Enum.HumanoidStateType.Jumping, not value)
				instance:SetAttribute("BoatJump", value and 0 or nil)
			end

			local function onRodAdded(tool)
				maid2:Clean()
				maid2:Add(tool.Unequipped:Once(function()
					maid2:Clean()
				end))
				local values = tool:WaitForChild("values", 4)
				local casted = values:WaitForChild("casted", 4)

				if values and casted then
					maid2:Add(casted:GetPropertyChangedSignal("Value"):Connect(function()
						toggleHandler(casted.Value) -- equivalent call inferred; original call site unknown
					end))
				else
					maid2:Clean()
				end
			end

			local tool = parent2:FindFirstChildOfClass("Tool")

			if tool and rods[tool.Name] then
				onRodAdded(tool)
			end

			maid:Add(parent2.ChildAdded:Connect(function(tool2)
				if tool2:IsA("Tool") and rods[tool2.Name] then
					onRodAdded(tool2)
				end
			end))
			return function()
				maid:Destroy()
				toggleHandler(nil) -- equivalent call inferred; original call site unknown
			end
		end)
	end
end

local function StopAllAnims(p)
	for _, v4 in pairs(v2) do
		if v4 ~= nil and tostring(v4) ~= p then
			v4:Stop()
		end
	end
end

local animationController2 = parent:FindFirstChildOfClass("AnimationController")
local track = nil

if animationController2 then
	local animator = animationController2:FindFirstChildOfClass("Animator")

	if animator then
		track = animator:LoadAnimation(animationController2:FindFirstChild("Active"))
		track:Play()
		track:AdjustSpeed(0.01)
	end
end

local v4 = 0
local v5 = 0
local v6 = 0
local v7 = 0
local v8 = 0
local v9 = vessels.library[parent:WaitForChild("Information"):WaitForChild("BoatType").Value]
local vector3Value = Instance.new("Vector3Value")
vector3Value.Value = Vector3.new(v9.Bobbing, 0, v9.Bobbing)
vector3Value.Name = "BobEffect"
vector3Value.Parent = parent
local TweenService2 = game:GetService("TweenService")
TweenService2:Create(
	vector3Value,
	TweenInfo.new(3 * v9.BobbingSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
	{
		Value = Vector3.new(-v9.Bobbing, 0, -v9.Bobbing)
	}
):Play()
rot.CFrame = base.CFrame
rot.MaxTorque = createVector(1e999, 1e999, 1e999)
local rotation = rot.CFrame.Rotation
local v10 = nil
local v11 = nil
local identity = CFrame.identity

local function driveBoat(p: number)
	if owner.Parent and owner.Parent:GetAttribute("MovementPaused") then
		motor.Velocity = createVector(0, 0, 0)
		return
	end

	local v12 = SettingsController:GetSettingValue("steeringMode") == "simple"
	local v13 = false

	if owner.Occupant == nil then
		if owner.Occupant == nil then
			if v4 ~= 0 then
				if v4 > 0 then
					v4 = math.clamp(v4 - v9.Accel * v9.StopEfficiency * p * 100, 0, 1e999)

					if track then
						track:AdjustSpeed((math.clamp(v4 * 0.025, 0.2, 1)))
					end
				elseif v4 < 0 then
					v4 = math.clamp(v4 + v9.Accel * v9.StopEfficiency * p * 100, -1e999, 0)

					if track then
						track:AdjustSpeed((math.clamp(v4 * 0.025, 0.2, 1)))
					end
				end
			end

			if v4 < 0.2 and v4 > -0.2 then
				v4 = 0
			end
		end
	else
		local child = game.Players:FindFirstChild(owner.Occupant.Parent.Name)

		if child and child.PlayerGui and child.PlayerGui.backpack.hotbar.Folder.Frame:FindFirstChild("speed") then
			local v14 = v4

			if v4 < 0 and v4 > -1 then
				v14 *= -1
			end

			local speed = child.PlayerGui.backpack.hotbar.Folder.Frame:FindFirstChild("speed")
			speed.Text = "Speed: " .. string.format("%.0f", v14) .. " S/ps"
			local speed_2 = child.PlayerGui.backpack.hotbar.Folder.Frame:FindFirstChild("speed")
			speed_2.bar.Size = UDim2.new(v4 / v9.MaxSpeed, 0, 0.2, 0)
		end

		local throttle = owner.Throttle

		if v12 then
			local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			throttle = humanoid and (humanoid.MoveDirection * createVector(1, 0, 1)).Magnitude or 0
		end

		if throttle > 0 then
			if v4 < 0 then
				v4 = math.clamp(v4 + v9.Accel * v9.StopEfficiency * p * 100, -1e999, 0)

				if track then
					track:AdjustSpeed((math.clamp(v4 * 0.025, 0.2, 1)))
				end
			end

			if v4 < v9.MaxSpeed then
				v4 += v9.Accel * p * 100
			end
		elseif throttle == 0 then
			if v4 > 0 then
				v4 = math.clamp(v4 - v9.Accel * v9.StopEfficiency * p * 100, 0, 1e999)

				if track then
					track:AdjustSpeed((math.clamp(v4 * 0.025, 0.2, 1)))
				end
			elseif v4 < 0 then
				v4 = math.clamp(v4 + v9.Accel * v9.StopEfficiency * p * 100, -1e999, 0)

				if track then
					track:AdjustSpeed((math.clamp(v4 * 0.025, 0.2, 1)))
				end
			end
		elseif throttle < 0 then
			if v4 > 0 then
				v4 = math.clamp(v4 - v9.Accel * v9.StopEfficiency * p * 100, 0, 1e999)

				if track then
					track:AdjustSpeed((math.clamp(v4 * 0.025, 0.2, 1)))
				end
			end

			if v4 > -v9.MaxSpeed then
				v4 -= v9.Accel * v9.BackwardsEfficiency * p * 100
				v13 = true
			end
		end
	end

	motor.Velocity = base.CFrame.LookVector * v4

	if v9.IsSubmarine then
		if owner.Occupant then
			v7 = v5 + v6
		else
			v7 = 0
		end

		local Players2 = game:GetService("Players")

		if Players2.LocalPlayer.GameplayPaused == true then
			return
		end

		if v7 == 0 then
			if v8 > 0 then
				v8 = math.clamp(v8 + -p, 0, 1)
			else
				v8 = math.clamp(v8 + p, -1, 0)
			end
		else
			v8 = math.clamp(v8 + v7 * p, -1, 1)
		end

		local v14 = v8 * p * (v9.SubmarineVerticalSpeed or 50)
		local v15

		if v14 ~= 0 then
			local position = plane0.Parent.Parent.HitBox.Position
			local vector2 = Vector3.new(0, (plane0.Parent.Parent.HitBox.Size.Y / 2 + 7) * (v14 > 0 and 1 or -1), 0)
			local raycastParams = RaycastParams.new()
			local filterDescendantsInstances = { plane0.Parent.Parent.Parent, workspace.zones }

			if anglerMinigame then
				table.insert(filterDescendantsInstances, anglerMinigame)
			end

			local plants = roslitBay and roslitBay:FindFirstChild("Cave") and roslitBay.Cave:FindFirstChild("Plants")

			if plants then
				table.insert(filterDescendantsInstances, plants)
			end

			raycastParams.FilterDescendantsInstances = filterDescendantsInstances
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.IgnoreWater = true
			raycastParams.RespectCanCollide = true
			v15 = RayVisual.raycast(position, vector2, raycastParams, nil)
		end

		local isFakeUnderwater = ZoneController.IsFakeUnderwater

		if isFakeUnderwater or plane0.Parent.Parent.HitBox.BuoyancySensor.FullySubmerged or plane0.Parent.Parent.HitBox.BuoyancySensor.TouchingSurface then
			if isFakeUnderwater or plane0.Parent.Parent.WaterChecker_Bottom.BuoyancySensor.FullySubmerged then
				if v15 then
					if v15.Instance then
						v8 = 0
					else
						plane0.Position += Vector3.new(0, v14, 0)
					end
				else
					plane0.Position += Vector3.new(0, v14, 0)
				end
			elseif v14 < 0 then
				plane0.Position += Vector3.new(0, v14, 0)
			else
				v8 = 0
			end
		elseif v14 < 0 then
			plane0.Position += Vector3.new(0, v14, 0)
		else
			v8 = 0
		end

		if v9.MaxHeight then
			plane0.Position = Vector3.new(
				plane0.Position.X,
				math.min(plane0.Position.Y, v9.MaxHeight),
				plane0.Position.Z
			)
		end

		if v9.MinHeight then
			plane0.Position = Vector3.new(
				plane0.Position.X,
				math.max(plane0.Position.Y, v9.MinHeight),
				plane0.Position.Z
			)
		end

		base.watertrail.Enabled = not plane0.Parent.Parent.HitBox.BuoyancySensor.FullySubmerged
		base.watertrail2.Enabled = not plane0.Parent.Parent.HitBox.BuoyancySensor.FullySubmerged
	end

	if SettingsController:GetSettingValue("steeringMode") == "standard" then
		v10 = (v13 and owner.Steer or -owner.Steer) * math.rad(v9.TurningSpeed * 100 * p * SettingsController:GetSettingValue("steeringSensitivity"))
		v11 = nil
		identity = CFrame.identity
	else
		local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

		if humanoid and owner.Occupant == humanoid then
			if not v11 then
				local _, v14 = base.CFrame:ToOrientation()
				v11 = v14
			end

			if workspace.CurrentCamera.CameraSubject == owner then
				workspace.CurrentCamera.CameraSubject = humanoid
			end

			local v14 = humanoid.MoveDirection * createVector(1, 0, 1)
			local cFrame = rot.CFrame

			if v14.Magnitude > 0.0001 then
				cFrame = CFrame.lookAlong(createVector(0, 0, 0), v14)
			end

			local cframe, _ = TweenService:SmoothDamp(rot.CFrame, cFrame, identity, 0.1, v9.TurningSpeed * 20, p)
			local _, v15 = cframe:ToOrientation()
			v11 = v15
			v10 = nil
		end
	end

	if not game.Players:FindFirstChild(parent:WaitForChild("Information"):WaitForChild("OwnedBy").Value) then
		for _, descendant in pairs(parent.Parent:GetDescendants()) do
			if not (descendant:IsA("Seat") or descendant:IsA("VehicleSeat")) then
				continue
			end

			if descendant.Occupant then
				descendant.Occupant.Sit = false
			end

			descendant.Disabled = true
		end

		task.wait(0.5)
		parent.Parent:Destroy()
	end
end

owner.Disabled = true
local sitprompt = owner:WaitForChild("sitprompt")
sitprompt.ObjectText = parent:WaitForChild("Information"):WaitForChild("OwnedBy").Value .. "'s Seat"

if game.Players:FindFirstChild(parent:WaitForChild("Information"):WaitForChild("OwnedBy").Value) and game.Players:FindFirstChild(parent:WaitForChild("Information"):WaitForChild("OwnedBy").Value) == game.Players.LocalPlayer then
	owner:WaitForChild("sitprompt").Triggered:Connect(function(player)
		if player.Name == parent:WaitForChild("Information"):WaitForChild("OwnedBy").Value and player.Character and owner.Occupant == nil then
			local ReplicatedStorage4 = game:GetService("ReplicatedStorage")

			if require(ReplicatedStorage4.shared.modules:WaitForChild("character")):Can(game.Players[parent:WaitForChild("Information"):WaitForChild("OwnedBy").Value]) == true then
				local tool = player.Character:FindFirstChildWhichIsA("Tool")

				if tool and tool:FindFirstChild("bobber") then
					return
				else
					owner:Sit(player.Character:FindFirstChildWhichIsA("Humanoid"))
				end
			end
		end
	end)
end

local v12 = true
local occupant = nil

function SeatChange()
	if owner.Occupant == nil then
		v5 = 0
		v6 = 0
		local sitprompt = owner:WaitForChild("sitprompt")
		sitprompt.Enabled = true
		task.spawn(function()
			task.wait(8)
			local _ = owner.Occupant == nil
		end)
	else
		occupant = owner.Occupant
		v12 = false
		local sitprompt_2 = owner:WaitForChild("sitprompt")
		sitprompt_2.Enabled = false
	end

	if occupant ~= nil then
		local child

		if owner.Occupant == nil then
			child = game.Players:FindFirstChild(occupant.Parent.Name)
		else
			child = game.Players:FindFirstChild(owner.Occupant.Parent.Name)
		end

		if child and child.Parent and child == game.Players.LocalPlayer then
			local _, v13 = script.Parent:GetBoundingBox()
			local v14 = (v13.X + v13.Y + v13.Z) / 3 / 4.5

			if child.PlayerGui then
				if owner.Occupant == nil then
					child.CameraMaxZoomDistance = 50

					if child.PlayerGui.backpack.hotbar.Folder.Frame:FindFirstChild("speed") then
						child.PlayerGui.backpack.hotbar.Folder.Frame:FindFirstChild("speed"):Destroy()
					end
				elseif not child.PlayerGui.backpack.hotbar.Folder.Frame:FindFirstChild("speed") then
					local clone = script:WaitForChild("speed"):Clone()
					clone.bar.Size = UDim2.new(0, 0, 0.2, 0)
					clone.Text = ""
					clone.Parent = child.PlayerGui.backpack.hotbar.Folder.Frame
					child.CameraMaxZoomDistance = v14 + 50
				end
			end
		end
	end
end

local total = 0

local function RenderBoat()
	if owner.Parent and owner.Parent:GetAttribute("MovementPaused") then
		base.AssemblyAngularVelocity = createVector(0, 0, 0)
		base.AssemblyLinearVelocity = createVector(0, 0, 0)
		v10 = 0
		total = 0
		local _, v13 = base.CFrame.Rotation:ToOrientation()
		rotation = CFrame.fromOrientation(0, v13, 0)
		rot.CFrame = rotation
	else
		if v11 then
			rot.CFrame = CFrame.fromOrientation(0, v11, 0)
		else
			local rot2 = rot
			local v14 = rotation
			local X = math.rad(vector3Value.Value.X)
			local v15

			if v10 then
				v15 = total + v10
			else
				v15 = base.CFrame.Rotation.Y
			end

			rot2.CFrame = v14 * CFrame.Angles(X, v15, (math.rad(vector3Value.Value.Z)))
		end

		if v10 then
			total += v10
		end

		if owner.ThrottleFloat > 0 then
			if base0:FindFirstChild("movingSound") then
				if v then
					v:Cancel()
				end

				local volume = not base0:FindFirstChild("movingSound"):FindFirstChild("Volume") and 0.6 or base0:FindFirstChild("movingSound"):FindFirstChild("Volume").Value
				local TweenService3 = game:GetService("TweenService")
				v = TweenService3:Create(
					base0:FindFirstChild("movingSound"),
					TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Volume = volume,
						PlaybackSpeed = base0.movingSound:GetAttribute("BasePlaybackSpeed") or 1
					}
				):Play()
			end

			if base0:FindFirstChild("waterSpray") then
				local waterSpray = base0:FindFirstChild("waterSpray")
				waterSpray.Enabled = true
			end
		elseif owner.ThrottleFloat < 0 then
			if base0:FindFirstChild("movingSound") then
				if v then
					v:Cancel()
				end

				local v13 = not base0:FindFirstChild("movingSound"):FindFirstChild("Volume") and 0.6 or base0:FindFirstChild("movingSound"):FindFirstChild("Volume").Value
				local TweenService3 = game:GetService("TweenService")
				v = TweenService3:Create(
					base0:FindFirstChild("movingSound"),
					TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Volume = v13 * 0.9,
						PlaybackSpeed = 0.8
					}
				):Play()
			end
		else
			if base0:FindFirstChild("movingSound") then
				if v then
					v:Cancel()
				end

				local TweenService3 = game:GetService("TweenService")
				v = TweenService3:Create(
					base0:FindFirstChild("movingSound"),
					TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Volume = 0,
						PlaybackSpeed = 0.6
					}
				):Play()
			end

			if base0:FindFirstChild("waterSpray") then
				local waterSpray_2 = base0:FindFirstChild("waterSpray")
				waterSpray_2.Enabled = false
			end
		end

		if animationController then
			if owner.Occupant == nil then
				if v2.Unoccupied == nil then
					StopAllAnims()
					v2.Unoccupied = animationController:LoadAnimation(animationController:FindFirstChild("Unoccupied"))
				end

				if v2.Unoccupied and not v2.Unoccupied.IsPlaying then
					v2.Unoccupied:Play(0)
				end

				StopAllAnims(v2.Unoccupied)
			elseif owner.ThrottleFloat == 0 then
				if v2.Idle == nil then
					StopAllAnims()
					v2.Idle = animationController:LoadAnimation(animationController:FindFirstChild("Idle"))
				end

				if v2.Idle and not v2.Idle.IsPlaying then
					v2.Idle:Play(0)
				end

				StopAllAnims(v2.Idle)
			else
				if v2.Active == nil then
					v2.Active = animationController:LoadAnimation(animationController:FindFirstChild("Active"))
				end

				if v2.Active and not v2.Active.IsPlaying then
					v2.Active:AdjustSpeed(owner.ThrottleFloat)
					v2.Active:Play(0)
				end

				StopAllAnims(v2.Active)
			end
		end
	end
end

local localPlayer = Players.LocalPlayer
owner.Changed:Connect(function()
	SeatChange()
end)
RunService.PreRender:Connect(RenderBoat)

if parent:WaitForChild("Information"):WaitForChild("OwnedBy").Value == localPlayer.Name then
	RunService.PostSimulation:Connect(driveBoat)

	if v9.IsSubmarine then
		parent:SetAttribute("IsSubmarine", true)
		local submarineTeleportRemote = parent:FindFirstChild("SubmarineTeleportRemote")

		if submarineTeleportRemote then
			submarineTeleportRemote.OnClientEvent:Connect(function(cframe: CFrame)
				if typeof(cframe) ~= "CFrame" then
					return
				end

				parent:PivotTo(cframe)
			end)
		end

		pcall(ContextActionService.UnbindAction, ContextActionService, "IncreaseSubmarineHeight")
		ContextActionService:BindActionAtPriority("IncreaseSubmarineHeight", function(_, p, p2)
			if p2.KeyCode.Name == "Unknown" or (not owner.Occupant or Players:GetPlayerFromCharacter(owner.Occupant.Parent) ~= localPlayer) then
				return Enum.ContextActionResult.Pass
			end

			if p == Enum.UserInputState.Begin then
				v5 = 1
				return Enum.ContextActionResult.Sink
			end

			if p ~= Enum.UserInputState.End and p ~= Enum.UserInputState.Cancel then
				return Enum.ContextActionResult.Pass
			end

			v5 = 0
			return Enum.ContextActionResult.Sink
		end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.E, Enum.KeyCode.ButtonR1)
		pcall(ContextActionService.UnbindAction, ContextActionService, "DecreaseSubmarineHeight")
		ContextActionService:BindActionAtPriority("DecreaseSubmarineHeight", function(_, p, p2)
			if p2.KeyCode.Name == "Unknown" or (not owner.Occupant or Players:GetPlayerFromCharacter(owner.Occupant.Parent) ~= localPlayer) then
				return Enum.ContextActionResult.Pass
			end

			if p == Enum.UserInputState.Begin then
				v6 = -1
				return Enum.ContextActionResult.Sink
			end

			if p ~= Enum.UserInputState.End and p ~= Enum.UserInputState.Cancel then
				return Enum.ContextActionResult.Pass
			end

			v6 = 0
			return Enum.ContextActionResult.Sink
		end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.Q, Enum.KeyCode.ButtonL1)
		local v13 = Observers.observeTagNoAncestry("SubmarineControls", function(p)
			local mouseButton1DownConnection = p.Up.MouseButton1Down:Connect(function()
				if v6 == 0 then
					v5 = 1
				end
			end)
			local mouseButton1UpConnection = p.Up.MouseButton1Up:Connect(function()
				v5 = 0
			end)
			local mouseButton1DownConnection2 = p.Down.MouseButton1Down:Connect(function()
				if v5 == 0 then
					v6 = -1
				end
			end)
			local mouseButton1UpConnection2 = p.Down.MouseButton1Up:Connect(function()
				v6 = 0
			end)
			return function()
				mouseButton1DownConnection:Disconnect()
				mouseButton1UpConnection:Disconnect()
				mouseButton1DownConnection2:Disconnect()
				mouseButton1UpConnection2:Disconnect()
			end
		end)
		local v14 = Observers.observeTagNoAncestry("ReturnToSurface", function(p)
			local flag = false
			local mouseButton1ClickConnection = p.Button.MouseButton1Click:Connect(function()
				if flag then
					return
				end

				flag = true
				local model = game.Workspace.active.boats[game.Players.LocalPlayer.Name]:FindFirstChildOfClass("Model")

				if model then
					local v15 = vessels.library[model.Name]

					if not (v15 and v15.IsSubmarine) then
						model = nil
					end
				end

				if not model then
					flag = false
					return
				end

				remoteEvent:FireServer(model)
				task.delay(10, function()
					flag = false
				end)
			end)
			return function()
				mouseButton1ClickConnection:Disconnect()
			end
		end)
		DeferredSignalHackaround.Once(script.Destroying, function()
			pcall(ContextActionService.UnbindAction, ContextActionService, "IncreaseSubmarineHeight")
			pcall(ContextActionService.UnbindAction, ContextActionService, "DecreaseSubmarineHeight")
			v13()
			v14()

			for _, v15 in v3 do
				v15()
			end
		end)
	elseif v9.FlyingBoat then
		print("Flying boat equipped")
		parent:SetAttribute("FlyingBoat", true)
		local maid = Trove.new()
		maid:AttachToInstance(script)
		local v13 = nil
		local v14 = nil
		local v15 = 0
		motor.MaxForce = createVector(1e999, 1e999, 1e999)
		parent.PlanePart.PlaneConstraint.Enabled = false
		pcall(ContextActionService.UnbindAction, ContextActionService, "IncreaseFlyingBoatHeight")
		ContextActionService:BindActionAtPriority("IncreaseFlyingBoatHeight", function(_, p, p2)
			if p2.KeyCode.Name == "Unknown" or (not owner.Occupant or Players:GetPlayerFromCharacter(owner.Occupant.Parent) ~= localPlayer) then
				return Enum.ContextActionResult.Pass
			end

			if p == Enum.UserInputState.Begin then
				v13 = true
				return Enum.ContextActionResult.Sink
			end

			if p ~= Enum.UserInputState.End and p ~= Enum.UserInputState.Cancel then
				return Enum.ContextActionResult.Pass
			end

			v13 = false
			return Enum.ContextActionResult.Sink
		end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.E, Enum.KeyCode.ButtonR1)
		pcall(ContextActionService.UnbindAction, ContextActionService, "DecreaseFlyingBoatHeight")
		ContextActionService:BindActionAtPriority("DecreaseFlyingBoatHeight", function(_, p, p2)
			if p2.KeyCode.Name == "Unknown" or (not owner.Occupant or Players:GetPlayerFromCharacter(owner.Occupant.Parent) ~= localPlayer) then
				return Enum.ContextActionResult.Pass
			end

			if p == Enum.UserInputState.Begin then
				v14 = true
				return Enum.ContextActionResult.Sink
			end

			if p ~= Enum.UserInputState.End and p ~= Enum.UserInputState.Cancel then
				return Enum.ContextActionResult.Pass
			end

			v14 = false
			return Enum.ContextActionResult.Sink
		end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.Q, Enum.KeyCode.ButtonL1)
		maid:Add(RunService.Heartbeat:Connect(function(dt)
			if parent.owner.Occupant and parent.owner.Occupant == localPlayer.Character:FindFirstChildOfClass("Humanoid") then
				local verticalAccel = v13 and v9.VerticalAccel or v14 and -v9.VerticalAccel or 0

				if parent.owner.Position.Y > (v9.MaxHeight or 1e999) then
					verticalAccel = -v9.VerticalAccel
				elseif verticalAccel == 0 and math.abs(v15) > 0.01 then
					verticalAccel = (v15 > 0 and -1 or 1) * v9.VerticalAccel * v9.VerticalStopEfficiency

					if v15 > 0 then
						verticalAccel = math.min(verticalAccel, 0)
					elseif v15 < 0 then
						verticalAccel = math.max(verticalAccel, 0)
					end
				end

				v15 = math.clamp(v15 + verticalAccel * 100 * dt, -v9.VerticalMaxSpeed, v9.VerticalMaxSpeed)
				motor.Velocity = Vector3.new(motor.Velocity.X, v15, motor.Velocity.Z)
			else
				v13 = false
				v14 = false
			end
		end))
		local v16 = Observers.observeTagNoAncestry("SubmarineControls", function(p)
			local mouseButton1DownConnection = p.Up.MouseButton1Down:Connect(function()
				v13 = true
			end)
			local mouseButton1UpConnection = p.Up.MouseButton1Up:Connect(function()
				v13 = false
			end)
			local mouseButton1DownConnection2 = p.Down.MouseButton1Down:Connect(function()
				v14 = true
			end)
			local mouseButton1UpConnection2 = p.Down.MouseButton1Up:Connect(function()
				v14 = false
			end)
			return function()
				mouseButton1DownConnection:Disconnect()
				mouseButton1UpConnection:Disconnect()
				mouseButton1DownConnection2:Disconnect()
				mouseButton1UpConnection2:Disconnect()
			end
		end)
		DeferredSignalHackaround.Once(script.Destroying, function()
			pcall(ContextActionService.UnbindAction, ContextActionService, "IncreaseFlyingBoatHeight")
			pcall(ContextActionService.UnbindAction, ContextActionService, "DecreaseFlyingBoatHeight")
			v16()

			for _, v17 in v3 do
				v17()
			end
		end)
	end
end