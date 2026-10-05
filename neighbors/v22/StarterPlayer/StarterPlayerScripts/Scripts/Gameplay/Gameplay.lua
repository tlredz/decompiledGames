local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
game:GetService("UserInputService")
local localPlayer = game.Players.LocalPlayer
local mouse = localPlayer:GetMouse()
require(ReplicatedStorage.Modules.ReplicatedTween)
require(ReplicatedStorage.Modules.Server)
local Network = require(ReplicatedStorage.Modules.Network)
local Component = require(ReplicatedStorage.Modules.Component)
require(ReplicatedStorage.Modules.Neighbors.House)
local Rocks = require(script.Rocks)
local jumpscareRig = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Tools"):WaitForChild("JumpscareRig")
local jumpscare = script.Jumpscare
local vfx = jumpscare.Vfx
vfx.Parent = workspace.Terrain
vfx.CFrame = CFrame.new(0, 10000, 0)
task.spawn(function()
	ContentProvider:PreloadAsync({ jumpscareRig })
	ContentProvider:PreloadAsync({ script:WaitForChild("Jumpscare"):WaitForChild("JumpscareAnimation") })
end)

local function jumpscare2(instance)
	if localPlayer:GetAttribute("Jumpscared") then
		return
	end

	localPlayer:SetAttribute("Jumpscared", true)
	local currentCamera = workspace.CurrentCamera
	local vignette = localPlayer.PlayerGui.Jumpscare:WaitForChild("Vignette")
	local numberValue = Instance.new("NumberValue")
	local clone

	if instance == nil then
		jumpscareRig.Archivable = true
		clone = jumpscareRig:Clone()
	else
		instance.Archivable = true
		clone = instance:Clone()
		clone:FindFirstChild("DisplayName", true).Group:Destroy()
	end

	for _, descendant in clone:GetDescendants() do
		if descendant:GetAttribute("ToolItem") then
			descendant:Destroy()
		end

		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
			descendant.CollisionGroup = "Carried"
			descendant.Massless = true

			if descendant.Name ~= "HumanoidRootPart" and descendant.Parent and descendant.Parent.Name ~= "LocalRagdollCollision" then
				descendant.Transparency = 0
			end
		elseif descendant:IsA("BaseScript") then
			descendant:Destroy()
		elseif descendant:IsA("Decal") then
			descendant.Transparency = 0
		elseif descendant:IsA("Tool") then
			descendant:Destroy()
		elseif descendant:IsA("Weld") or descendant:IsA("WeldConstraint") then
			descendant:Destroy()
		elseif descendant:IsA("WrapLayer") and descendant.Parent then
			descendant.Enabled = false

			if descendant.Parent:IsA("BasePart") then
				descendant.Parent.Transparency = 1
			end
		end
	end

	clone.Parent = currentCamera
	local track = clone:FindFirstChildOfClass("Humanoid"):LoadAnimation(jumpscare:FindFirstChild("JumpscareAnimation"))
	track:Play(0)
	clone:PivotTo(CFrame.new(0, 1000, 0))
	task.delay(0.008333333333333333, function()
		repeat
			task.wait()
		until track.Length > 0

		SoundService:PlayLocalSound(jumpscare.Sound)
		SoundService.AmbientReverb = Enum.ReverbType.Hangar
		TweenService:Create(
			numberValue,
			TweenInfo.new(track.Length * 4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				Value = 1
			}
		):Play()
		task.spawn(function()
			TweenService:Create(vignette, TweenInfo.new(0.25), {
				ImageTransparency = 0
			}):Play()
		end)
		RunService:BindToRenderStep("GameplayJumpscare", Enum.RenderPriority.Camera.Value + 1, function()
			local v = numberValue.Value * 8
			currentCamera.CFrame *= CFrame.Angles(
				math.rad((math.random(-3, 3))),
				math.rad((math.random(-3, 3))),
				(math.rad((math.random(-3, 3))))
			)
			clone:PivotTo(currentCamera.CFrame * CFrame.fromOrientation(
				math.rad((math.random(-10, 10))),
				3.141592653589793,
				(math.rad((math.random(-10, 10))))
			) * CFrame.new(0, -1.25, 8 - v))
			vfx.CFrame = clone.HumanoidRootPart.CFrame

			if math.random(1, 3) == 1 then
				vignette.ImageColor3 = Color3.fromRGB(9, 9, 9)
			else
				vignette.ImageColor3 = Color3.fromRGB(0, 0, 0)
			end
		end)
	end)
	jumpscare.Heartbeat:Stop()
	jumpscare.Heartbeat.Volume = 0.5
	track.Stopped:Connect(function()
		jumpscare.Heartbeat:Play()
		TweenService:Create(jumpscare.Heartbeat, TweenInfo.new(jumpscare.Heartbeat.TimeLength), {
			Volume = 0
		}):Play()
		RunService:UnbindFromRenderStep("GameplayJumpscare")
		clone:Destroy()
		SoundService.AmbientReverb = Enum.ReverbType.NoReverb
		numberValue:Destroy()
		vfx.CFrame = CFrame.new(0, 10000, 0)
		vignette.ImageTransparency = 0
		vignette.ImageColor3 = Color3.fromRGB(0, 0, 0)
		TweenService:Create(vignette, TweenInfo.new(jumpscare.Heartbeat.TimeLength), {
			ImageTransparency = 1
		}):Play()
		localPlayer:SetAttribute("Jumpscared", false)

		while jumpscare.Heartbeat.IsPlaying do
			currentCamera.CFrame *= CFrame.Angles(
				math.rad(math.random(-3, 3) * jumpscare.Heartbeat.Volume),
				math.rad(math.random(-3, 3) * jumpscare.Heartbeat.Volume),
				(math.rad(math.random(-3, 3) * jumpscare.Heartbeat.Volume))
			)
			task.wait()
		end
	end)
end

local v = Component.new({
	Tag = "FANSPIN",
	Ancestors = { workspace }
})

function v:Start()
	self.Origin = self.Instance:GetAttribute("Origin")
end

Network:listen("PromptJumpscare", function(p)
	jumpscare2(p)
end)
Network:listen("BonkHammer", function(instance)
	local clone = script.Rocks.Part:Clone()
	local hipHeight = instance.Humanoid.HipHeight
	local size = instance.HumanoidRootPart.Size
	clone.Transparency = 1
	clone.Position = instance.HumanoidRootPart.Position - Vector3.new(0, hipHeight + size.Y / 2, 0)
	clone.Parent = workspace
	Rocks.Spawn(clone)
end)
Network:listen("Bomb/GroundRocks", function(position)
	local clone = script.Rocks.Part:Clone()
	clone.Transparency = 1
	clone.CFrame = CFrame.new(position)
	clone.Parent = workspace
	Rocks.Spawn(clone)
end)
Network:listen("Bomb/Throw", function(p, vector: Vector3)
	if not p then
		return
	end

	local lastTime = os.clock()

	while p.Parent and os.clock() - lastTime < 0.35 do
		local v2 = os.clock() - lastTime
		p.AssemblyLinearVelocity = vector - Vector3.new(0, workspace.Gravity * v2, 0)
		task.wait()
	end
end)
Network:listen("VehicleHandler", function(instance)
	local clone = instance:Clone()
	clone.Parent = localPlayer.Character
	clone.Enabled = true
	local object = clone:WaitForChild("Object")

	if not object.Value then
		object:GetPropertyChangedSignal("Value"):Wait()
	end

	if object.Value then
		object.Value.Destroying:Connect(function()
			task.wait()
			clone:Destroy()
		end)
	end
end)
Network:listen("SetCameraSubject", function(p)
	local cameraSubject = p or localPlayer.Character.Humanoid
	workspace.CurrentCamera.CameraSubject = cameraSubject
end)
local renderSteppedConnection = nil
Network:listen("UpdateMemoryTilesCamera", function(cameraSubject, p)
	if p then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	else
		local currentCamera = workspace.CurrentCamera
		currentCamera.CameraSubject = cameraSubject
		currentCamera.CameraType = Enum.CameraType.Scriptable
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			currentCamera.CFrame = cameraSubject.CFrame
		end)
	end
end)
Network:listen("GetMousePosition", function()
	return mouse.Hit.Position
end)
Network:listen("GetPlayerOnMouse", function()
	mouse.TargetFilter = localPlayer.Character
	local target = mouse.Target

	if target then
		local model = target:FindFirstAncestorOfClass("Model")
		local playerFromCharacter = model and model:FindFirstChild("Humanoid") and game.Players:GetPlayerFromCharacter(model)

		if playerFromCharacter then
			mouse.TargetFilter = nil
			return playerFromCharacter, target
		end
	end

	mouse.TargetFilter = nil
end)
Network:listen("GetCharacterOnMouse", function()
	mouse.TargetFilter = localPlayer.Character
	local target = mouse.Target

	if target then
		local model = target:FindFirstAncestorOfClass("Model")

		if model and model:FindFirstChild("Humanoid") then
			mouse.TargetFilter = nil
			return model, target
		end
	end

	mouse.TargetFilter = nil
end)
Network:listen("ManageControls", function(p)
	local playerScripts = localPlayer:WaitForChild("PlayerScripts")
	local PlayerModule = require(playerScripts:WaitForChild("PlayerModule"))
	local controls = PlayerModule:GetControls()

	if p == "Enable" then
		controls:Enable()
	else
		controls:Disable()
	end
end)
CollectionService:GetInstanceAddedSignal("NeonLasso"):Connect(function(instance)
	TweenService:Create(instance, TweenInfo.new(2, Enum.EasingStyle.Bounce, Enum.EasingDirection.InOut, 1e999, true), {
		Brightness = instance:GetAttribute("LowestBrightness")
	}):Play()
end)
RunService.Heartbeat:Connect(function(dt: number)
	for _, v2 in v:GetAll() do
		local instance = v2.Instance
		instance.CastShadow = false
		instance.CFrame = instance:GetPivot() * CFrame.Angles(0, 0, dt * 4.1887902047863905) * instance.PivotOffset:Inverse()
	end
end)