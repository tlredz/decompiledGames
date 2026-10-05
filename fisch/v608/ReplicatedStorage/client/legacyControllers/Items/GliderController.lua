local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local Trove = require(packages.Trove)
local Observers = require(packages.Observers)
local Net = require(packages.Net)
local remoteEvent = Net:RemoteEvent("HangGlider/MaxSpeedReached", -1)
local gliderdata = require(ReplicatedStorage.shared.modules.library.items.gliderdata)
local fx = require(ReplicatedStorage.shared.modules.fx)
local module = require("../InventoryController")
local GliderController = {
	ActiveGliderName = nil,
	ActiveGlider = nil,
	GlidingSince = nil,
	LastGliding = nil,
	BodyVelocity = nil,
	AlignOrientation = nil,
	ActiveBoosts = {},
	LastMomentum = 0,
	ShouldResetMomentum = nil,
	DecayDisabled = 0,
	FovVelocity = 0,
	AtMaxMomentum = false,
	_DebouncedBoosts = {},
	_CharacterTrove = Trove.new(),
	_HoldAnim = nil
}
local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.RespectCanCollide = true
raycastParams.CollisionGroup = "Players"

function GliderController:IsGlider(name)
	if typeof(name) ~= "string" then
		if typeof(name) == "Instance" then
			name = name.Name
		elseif typeof(name) == "table" then
			name = name.name
		else
			return false
		end
	end

	if name then
		return gliderdata[name] ~= nil
	end

	return false
end

function GliderController:IsInAir(flag: boolean?)
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
	local rootPart = humanoid and humanoid.RootPart

	if not (character and humanoid and rootPart) then
		return false
	end

	if humanoid:GetState() == Enum.HumanoidStateType.Swimming or humanoid:GetState() == Enum.HumanoidStateType.Seated or humanoid:GetState() == Enum.HumanoidStateType.PlatformStanding or humanoid:GetAttribute("InFakeWater") then
		return false
	end

	if rootPart:IsGrounded() then
		print("grounded")
		return false
	end

	if localPlayer:GetAttribute("AntiGlider") then
		return false
	end

	local raycastResult = workspace:Raycast(rootPart.Position, Vector3.new(0, -(flag and 10 or 3.5), 0), raycastParams)
	return raycastResult == nil, raycastResult ~= nil and raycastResult.Material == Enum.Material.Water
end

function GliderController:UnequipGlider(flag: boolean?)
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
	local activeGlider = GliderController.ActiveGlider
	GliderController.ActiveGlider = nil
	table.clear(GliderController.ActiveBoosts)

	if GliderController.BodyVelocity then
		GliderController.BodyVelocity.MaxForce = createVector(0, 0, 0)
	end

	if GliderController.AlignOrientation then
		GliderController.AlignOrientation.Enabled = false
	end

	if GliderController.AtMaxMomentum then
		remoteEvent:FireServer(false)
		GliderController.AtMaxMomentum = false
	end

	GliderController.LastMomentum = 0
	GliderController.DecayDisabled = 0
	workspace.CurrentCamera.FieldOfView = 70
	task.delay(0.1, function()
		if not GliderController.ActiveGlider then
			GliderController.GlidingSince = nil
		end
	end)

	if humanoid then
		if GliderController.ActiveGliderName and character:FindFirstChild(GliderController.ActiveGliderName) then
			humanoid:UnequipTools()
		end

		humanoid.AutoRotate = true
		character:SetAttribute("GliderSpeed", nil)
		character:SetAttribute("GliderJump", nil)

		if activeGlider and activeGlider.HeadFirst and not flag then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end

	GliderController.ActiveGliderName = nil
	GliderController._HoldAnim:Stop()
end

function GliderController:OnEquipped(activeGliderName: string)
	if not GliderController:IsGlider(activeGliderName) then
		return
	end

	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
	local rootPart = humanoid and humanoid.RootPart

	if not (character and humanoid and rootPart) then
		return
	end

	local isInAir, v = GliderController:IsInAir(gliderdata[activeGliderName].UseCameraPhysics)

	if isInAir then
		if not GliderController.GlidingSince then
			GliderController.GlidingSince = tick()
		end

		GliderController.ActiveGliderName = activeGliderName
		GliderController.ActiveGlider = gliderdata[activeGliderName]
		GliderController.AlignOrientation.Enabled = gliderdata[activeGliderName].UseCameraPhysics
		GliderController.LastMomentum = 0
		GliderController.DecayDisabled = 0

		if gliderdata[activeGliderName].UseCameraPhysics then
			GliderController.BodyVelocity.Velocity = rootPart.AssemblyLinearVelocity
			humanoid.AutoRotate = false
		end

		character:SetAttribute("GliderJump", 0)
		character:SetAttribute("GliderSpeed", gliderdata[activeGliderName].SpeedBoost)
		local child = character:FindFirstChild(activeGliderName)
		local humanoid2 = child.Parent:WaitForChild("Humanoid")
		local holdAnim = child:WaitForChild("handle"):FindFirstChild("holdAnim")

		if holdAnim then
			GliderController._HoldAnim = GliderController._CharacterTrove:Add(humanoid2:WaitForChild("Animator"):LoadAnimation(holdAnim))
		else
			GliderController._HoldAnim = GliderController._CharacterTrove:Add(humanoid2:WaitForChild("Animator"):LoadAnimation(ReplicatedStorage:WaitForChild("resources"):WaitForChild("animations"):WaitForChild("items"):WaitForChild("gliderUse")))
		end

		GliderController._HoldAnim:Play()
	else
		GliderController.ActiveGliderName = activeGliderName
		GliderController:UnequipGlider(v)
		ReplicatedStorage.events.anno_localthought:Fire("Must be in the air to deploy a glider.")
	end
end

function GliderController:Tick(p: number)
	if not GliderController.BodyVelocity then
		return
	end

	local activeGlider = GliderController.ActiveGlider

	if not activeGlider then
		GliderController.BodyVelocity.MaxForce = createVector(0, 0, 0)
		return
	end

	if localPlayer.GameplayPaused then
		return
	end

	local parent = GliderController.BodyVelocity.Parent
	local isInAir, v = GliderController:IsInAir()

	if isInAir then
		if not parent then
			return
		end

		GliderController.LastGliding = tick()

		if activeGlider.UseCameraPhysics then
			local alignOrientation = GliderController.AlignOrientation
			alignOrientation.CFrame = workspace.CurrentCamera.CFrame
			alignOrientation.MaxTorque = parent.AssemblyMass * 10000
			local upVector = activeGlider.HeadFirst and parent.CFrame.UpVector or parent.CFrame.LookVector

			if not math.isfinite(upVector.Magnitude) then
				warn("LookVector is nan???? how???????")
				print(parent.CFrame)
				upVector = workspace.CurrentCamera.CFrame.LookVector
			end

			local magnitude = (GliderController.BodyVelocity.Velocity + Vector3.new(0, workspace.Gravity / 20, 0)).Magnitude

			if not math.isfinite(magnitude) then
				warn("bad current momentum!!!", magnitude)
				magnitude = 0
			end

			local v2 = upVector.Y * activeGlider.VerticalMomentumFactor

			if v2 > 0 then
				v2 *= activeGlider.AscensionPenalty
			end

			if GliderController.ShouldResetMomentum then
				magnitude = GliderController.ShouldResetMomentum.Magnitude

				if not math.isfinite(magnitude) then
					warn("bad reset momentum!!!", magnitude)
					magnitude = 0
				end

				parent.AssemblyLinearVelocity = GliderController.ShouldResetMomentum
				GliderController.ShouldResetMomentum = nil
			end

			if GliderController.DecayDisabled <= 0 then
				magnitude -= p * activeGlider.MomentumDecay

				if #GliderController.ActiveBoosts == 0 then
					magnitude = math.clamp(magnitude + -v2 * p, 0, activeGlider.MaxMomentum)
				end
			end

			local atMaxMomentum = activeGlider.MaxMomentum <= magnitude

			if GliderController.AtMaxMomentum ~= atMaxMomentum then
				remoteEvent:FireServer(atMaxMomentum)
				GliderController.AtMaxMomentum = atMaxMomentum
			end

			local v4 = createVector(0, 0, 0)
			local v5 = createVector(0, 0, 0)

			for _, v6 in table.clone(GliderController.ActiveBoosts) do
				if v6.RemainingTime <= 0 then
					local index = table.find(GliderController.ActiveBoosts, v6)

					if index then
						table.remove(GliderController.ActiveBoosts, index)
					end
				elseif math.isfinite((v6.Velocity * createVector(1, 0, 1)).Magnitude) then
					magnitude += (v6.Velocity * createVector(1, 0, 1)).Magnitude * v6.RemainingTime * p
					v4 += v6.Velocity * createVector(0, 1, 0) * v6.RemainingTime * p * 10
					v5 += v6.Velocity * v6.RemainingTime * p
					v6.RemainingTime -= p
				else
					warn("Bad boost", v6.Velocity)
				end
			end

			if #GliderController.ActiveBoosts > 0 and v5.Magnitude > 0 and math.isfinite(v5.Magnitude) then
				alignOrientation.CFrame = CFrame.lookAlong(createVector(0, 0, 0), v5)
			end

			if activeGlider.HeadFirst then
				alignOrientation.CFrame *= CFrame.fromOrientation(-1.5707963267948966, 0, 0)
			end

			local velocity = upVector * magnitude + v4 + Vector3.new(0, -workspace.Gravity / 20, 0)

			if not math.isfinite(velocity.Magnitude) then
				warn("nan!!!", velocity)
				print(upVector)
				print(magnitude)
				velocity = upVector * 100
			end

			GliderController.BodyVelocity.Velocity = velocity
			GliderController.BodyVelocity.MaxForce = Vector3.new(
				(math.abs(velocity.X) + 10) * parent.AssemblyMass * 100,
				1000000,
				(math.abs(velocity.Z) + 10) * parent.AssemblyMass * 100
			)
			GliderController.LastMomentum = magnitude
			GliderController.DecayDisabled -= p
		else
			local now = tick()
			local value = TweenService:GetValue(
				math.clamp((now - GliderController.GlidingSince) / activeGlider.DescendSpeedTime, 0, 1),
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.In
			)
			local vector2 = Vector3.new(
				0,
				-math.lerp(activeGlider.DescendSpeedMin, activeGlider.DescendSpeedMax, value),
				0
			)

			for _, v2 in table.clone(GliderController.ActiveBoosts) do
				if v2.RemainingTime <= 0 then
					local index = table.find(GliderController.ActiveBoosts, v2)

					if index then
						table.remove(GliderController.ActiveBoosts, index)
					end
				else
					local v3 = math.clamp(v2.RemainingTime / v2.TotalTime, 0, 1)
					vector2 += v2.Velocity * v3
					v2.RemainingTime -= p
				end
			end

			GliderController.BodyVelocity.Velocity = vector2
			GliderController.BodyVelocity.MaxForce = Vector3.new(
				math.abs(vector2.X) * parent.AssemblyMass * 10,
				100000 + math.abs(vector2.Y) * parent.AssemblyMass * 10,
				math.abs(vector2.Z) * parent.AssemblyMass * 10
			)
		end
	else
		GliderController:UnequipGlider(v)
		fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.item.gliderLand, parent, true)
	end
end

function GliderController:TickFrame(p)
	if GliderController.ActiveGlider and GliderController.ActiveGlider.UseCameraPhysics then
		local currentCamera = workspace.CurrentCamera
		local v = GliderController
		local smoothDamp, fovVelocity = TweenService:SmoothDamp(
			workspace.CurrentCamera.FieldOfView,
			70 + GliderController.LastMomentum / 5,
			GliderController.FovVelocity,
			0.1,
			nil,
			p
		)
		currentCamera.FieldOfView = smoothDamp
		v.FovVelocity = fovVelocity
	end
end

function GliderController:Boost(vector2: Vector3, p: number)
	if not GliderController.ActiveGlider then
		return false
	end

	table.insert(GliderController.ActiveBoosts, {
		Velocity = vector2,
		TotalTime = p,
		RemainingTime = p
	})
	return true
end

function GliderController:ClearBoosts()
	table.clear(GliderController.ActiveBoosts)
end

function GliderController:_OnCharacterTouched(p)
	if not (GliderController.ActiveGlider and p) then
		return
	end

	local parent = p.Parent

	if parent and parent:HasTag("GliderBoost") and not GliderController._DebouncedBoosts[parent] then
		local pivot = parent:GetPivot()

		if parent:GetAttribute("ClearOtherBoosts") then
			GliderController:ClearBoosts()
			GliderController.ShouldResetMomentum = pivot.LookVector * -(parent:GetAttribute("BoostVelocity") or 50)
		end

		if parent:GetAttribute("DisableDecay") then
			GliderController.DecayDisabled = math.max(
				GliderController.DecayDisabled,
				parent:GetAttribute("DisableDecay")
			)
		end

		if GliderController:Boost(
			pivot.LookVector * -(parent:GetAttribute("BoostVelocity") or 50),
			parent:GetAttribute("BoostTime") or 1
		) then
			GliderController._DebouncedBoosts[parent] = true
			task.delay(3, function()
				GliderController._DebouncedBoosts[parent] = nil
			end)
		end
	end
end

function GliderController:_SetupCharacter(instance)
	GliderController._CharacterTrove:Clean()
	local humanoid = instance:WaitForChild("Humanoid")
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	local attachment = Instance.new("Attachment")
	attachment.Name = "GliderAttach"
	attachment.Parent = humanoidRootPart
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Name = "GliderVelocity"
	bodyVelocity.MaxForce = createVector(0, 0, 0)
	bodyVelocity.P = 10000
	bodyVelocity.Velocity = createVector(0, 0, 0)
	bodyVelocity.Parent = humanoidRootPart
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Name = "GliderOrient"
	alignOrientation.AlignType = Enum.AlignType.AllAxes
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.ReactionTorqueEnabled = false
	alignOrientation.RigidityEnabled = false
	alignOrientation.MaxTorque = 0
	alignOrientation.Responsiveness = 50
	alignOrientation.Attachment0 = attachment
	alignOrientation.Enabled = false
	alignOrientation.Parent = humanoidRootPart
	GliderController.BodyVelocity = GliderController._CharacterTrove:Add(bodyVelocity)
	GliderController.AlignOrientation = GliderController._CharacterTrove:Add(alignOrientation)
	GliderController._HoldAnim = GliderController._CharacterTrove:Add(humanoid:WaitForChild("Animator"):LoadAnimation(ReplicatedStorage:WaitForChild("resources"):WaitForChild("animations"):WaitForChild("items"):WaitForChild("gliderUse")))
	GliderController._CharacterTrove:Connect(humanoid.Touched, function(p)
		GliderController:_OnCharacterTouched(p)
	end)
	GliderController._CharacterTrove:Connect(humanoid:GetPropertyChangedSignal("AutoRotate"), function()
		if GliderController.ActiveGlider and GliderController.ActiveGlider.UseCameraPhysics then
			humanoid.AutoRotate = false
		end
	end)
	GliderController._CharacterTrove:Connect(humanoidRootPart:GetPropertyChangedSignal("Anchored"), function()
		if humanoidRootPart:IsGrounded() and GliderController.ActiveGlider then
			GliderController:UnequipGlider()
		end
	end)
end

function GliderController.Start(_)
	RunService.Heartbeat:Connect(function(dt)
		GliderController:Tick(dt)
	end)
	RunService.RenderStepped:Connect(function(dt)
		GliderController:TickFrame(dt)
	end)
	Observers.observeCharacter(localPlayer, function(_, p)
		GliderController:_SetupCharacter(p)
	end)
	module.ToolEquipped:Connect(function(p)
		GliderController:OnEquipped(p.Name)
	end)
	module.ToolUnequipped:Connect(function(p)
		if GliderController:IsGlider(p) then
			GliderController:UnequipGlider()
		end
	end)
end

return GliderController