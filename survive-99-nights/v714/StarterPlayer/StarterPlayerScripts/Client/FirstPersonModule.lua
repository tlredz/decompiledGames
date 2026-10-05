local createVector = vector.create
local FirstPersonModule = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local RunService = game:GetService("RunService")
local tracksByName = {}
local clone = nil
local v = nil
local cFrame = nil
local v2 = {
	MovementSway = CFrame.new()
}
local spring = Client.Spring.new((Vector3.new()))
spring.Speed = 10
local total = 0

function Update(p)
	CheckFirstPerson()

	if clone == nil or clone.Parent ~= workspace.Particles then
		return
	end

	local cFrame2 = workspace.CurrentCamera.CFrame
	local unit = (cFrame.LookVector * createVector(1, 0, 1)).Unit
	local unit2 = (cFrame2.LookVector * createVector(1, 0, 1)).Unit
	local dot = (unit2 - unit).Unit:Dot(workspace.CurrentCamera.CFrame.RightVector)
	local v3 = (IsNaN(dot) or dot >= 0) and 1 or -1
	local v4 = math.deg((math.acos((unit:Dot(unit2))))) * v3
	local v5 = IsNaN(v4) and 0 or v4
	local v6 = -math.deg((math.asin(cFrame2.LookVector.Y - cFrame.LookVector.Y)))
	local v7 = IsNaN(v6) and 0 or v6
	local v8 = math.clamp(v5, -25, 25)
	local v9 = math.clamp(v7, -25, 25)
	spring.Velocity += Vector3.new(v8 / 3, v9 / 1, 0)
	local humanoid = Client.PlayerHandler.Humanoid

	if humanoid.MoveDirection.Magnitude > 0.2 and humanoid.FloorMaterial and humanoid.FloorMaterial ~= Enum.Material.Air then
		total += p
		local v11 = 2 + humanoid.WalkSpeed / 30
		local v12 = math.sin(total * 3.141592653589793 * v11)
		local v13 = math.sin(total * 3.141592653589793 * v11 * 2)
		spring.Velocity += Vector3.new(v12 * 2, v13 * 4, 0)
	end

	v2.MovementSway = CFrame.Angles(
		math.rad(spring.Position.Y),
		math.rad(spring.Position.X),
		math.rad(spring.Position.X) / 2
	)
	local v11 = workspace.CurrentCamera.CFrame * CFrame.new(0, -0.5, 0.1)

	for _, v12 in pairs(v2) do
		v11 *= v12
	end

	clone:PivotTo(v11)
	cFrame = cFrame2
end

function IsNaN(p)
	return p ~= p
end

function CheckFirstPerson()
	if workspace.CurrentCamera.CameraType ~= Enum.CameraType.Custom then
		HideArms()
	elseif v.GetZoomRadius() < 0.6 and Client.PlayerHandler.Alive then
		ShowArms()
	else
		HideArms()
	end
end

function FirstPersonModule.GetTool()
	return clone:FindFirstChild("ToolModel")
end

function FirstPersonModule.IsVisible()
	return clone.Parent == workspace.Particles
end

function FirstPersonModule.AddTool(instance, value)
	FirstPersonModule.ClearTool()
	local clone2 = instance:Clone()

	for _, descendant in pairs(clone2:GetDescendants()) do
		if descendant:IsA("Weld") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.Massless = true
			descendant.CollisionGroup = "Particles"
			descendant.RootPriority = 0
			descendant.CastShadow = false
		end
	end

	clone2.Name = "ToolModel"
	clone2.Parent = clone
	Client.Utility.AttachTool(clone, clone2)
	PlayAnimation(value or "ToolHold")
	Client.Events.FirstPersonToggled:Fire()
end

function FirstPersonModule.ClearTool(value)
	local toolModel = clone:FindFirstChild("ToolModel")

	if toolModel then
		toolModel:Destroy()
	end

	StopAnimation(value or "ToolHold")
	Client.Events.FirstPersonToggled:Fire()
end

function PlayAnimation(p, ...)
	if tracksByName[p] then
		if clone.Parent ~= workspace.Particles and not tracksByName[p].Looped then
			return
		end

		tracksByName[p]:Play(...)
	end
end

FirstPersonModule.PlayAnimation = PlayAnimation

function StopAnimation(p)
	if tracksByName[p] then
		tracksByName[p]:Stop()
	end
end

FirstPersonModule.StopAnimation = StopAnimation

function BuildFirstPersonArms()
	clone = game.ReplicatedStorage.Assets.FirstPerson.FirstPersonArms:Clone()
	clone.Parent = game.ReplicatedStorage.TempStorage
	local animations = clone:WaitForChild("Animations")
	local animator = clone:WaitForChild("AnimationController"):WaitForChild("Animator")

	for _, animation in pairs(animations:GetChildren()) do
		tracksByName[animation.Name] = animator:LoadAnimation(animation)
	end
end

function HideArms()
	if clone.Parent ~= game.ReplicatedStorage.TempStorage then
		clone.Parent = game.ReplicatedStorage.TempStorage
		Client.Events.FirstPersonToggled:Fire()
		Client.GuiButtonHandler.HideButton("Shoot")
	end
end

function ShowArms()
	if clone.Parent ~= workspace.Particles then
		cFrame = workspace.CurrentCamera.CFrame
		clone.Parent = workspace.Particles
		Client.Events.FirstPersonToggled:Fire()
		local currentlyEquipped = Client.InventoryHandler.GetCurrentlyEquipped()

		if currentlyEquipped and currentlyEquipped:GetAttribute("ToolName") == "Firearm" then
			Client.GuiButtonHandler.HideButton("Shoot")
			Client.GuiButtonHandler.ShowButton("Shoot")
		end
	end
end

localPlayer.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.Jumping:Connect(function()
		spring.Velocity += createVector(0, -80, 0)
	end)
	task.spawn(function()
		if character and character:WaitForChild("Left Arm") and character:WaitForChild("Right Arm") then
			wait(0.5)
			clone["Left Arm"].Color = character["Left Arm"].Color
			clone["Right Arm"].Color = character["Right Arm"].Color
		end
	end)
	local air = Enum.Material.Air
	humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
		local floorMaterial = humanoid.FloorMaterial

		if Client.PlayerHandler.HumanoidRootPart and floorMaterial ~= Enum.Material.Air and air == Enum.Material.Air then
			local Y = math.abs(Client.PlayerHandler.HumanoidRootPart.AssemblyLinearVelocity.Y)

			if Y > 10 then
				local v3 = math.clamp(Y * 1.5, 10, 120)
				spring.Velocity -= Vector3.new(0, v3, 0)
			end
		end

		air = floorMaterial
	end)
end)

function FirstPersonModule.Init()
	task.spawn(function()
		local ZoomController = require(localPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("ZoomController"))
		v = ZoomController
		BuildFirstPersonArms()
		RunService:BindToRenderStep("UpdateFPArms", Enum.RenderPriority.Character.Value + 1, Update)
	end)
end

return FirstPersonModule