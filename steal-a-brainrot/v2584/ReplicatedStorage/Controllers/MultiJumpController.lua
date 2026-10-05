local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local NotificationController = require(ReplicatedStorage.Controllers.NotificationController)
local Trove = require(ReplicatedStorage.Packages.Trove)
local VFX = require(ReplicatedStorage.Shared.VFX)
local localPlayer = Players.LocalPlayer
local count = 0
local v = false
local flag = false
local v2 = false
local v3 = false
local v4 = 1
local now = 0
local flag2 = false
local now2 = 0
local v5 = 0
local v6 = 0
local v7 = {}
local v8 = {}
local v9 = {}
local v10 = {}
local thread = nil

local function showJumpCount(p: number)
	NotificationController:Notify(`Jumps Left: {p}`, 9999, nil, nil, nil, "MultiJumpCount")

	if thread then
		task.cancel(thread)
	end

	thread = task.delay(3, function()
		thread = nil
		NotificationController:Notify("", nil, nil, nil, nil, "MultiJumpCount", true)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideJumpCount()
	if thread then
		task.cancel(thread)
		thread = nil
	end

	NotificationController:Notify("", nil, nil, nil, nil, "MultiJumpCount", true)
end

local function loadAnimationSets(animator, list)
	local tracks = table.create(#list)

	for k, _ in list do
		tracks[k] = animator:LoadAnimation(list[k])
	end

	return tracks
end

local function stopTracks(items, value: number?)
	for _, item in items do
		if item.IsPlaying then
			item:Stop(value or 0.2)
		end
	end
end

local function damp(p: number, p2: number, p3: number)
	local v11 = 1 - 0.1608066690215766 ^ p3
	return p + (p2 - p) * v11
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPlayerExtraJumps()
	return localPlayer:GetAttribute("ExtraJumps") or 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resetJumps()
	count = 0
	v = false
	flag = false
	v5 = 0
	v6 = 0
end

local MultiJumpController = {
	RefillJumps = function(_)
		count = 0
		flag = false
		hideJumpCount() -- equivalent call inferred; original call site unknown
	end
}

local function tryMultiJump(humanoid)
	if localPlayer:GetAttribute("StealingPlayer") then
		return
	end

	local playerExtraJumps = getPlayerExtraJumps() -- equivalent call inferred; original call site unknown

	if playerExtraJumps <= 0 or not v or playerExtraJumps <= count - 1 or os.clock() - now2 < 0.3 then
		return
	end

	count += 1

	if count <= 1 then
		now2 = os.clock() - 0.3 + 0.1
		return
	end

	v4 = 2 - count % 2
	v3 = true
	now2 = os.clock()
	showJumpCount(playerExtraJumps - (count - 1))

	if playerExtraJumps > 0 then
		local v12 = v7[v4]

		if v12 then
			local timePosition = nil

			for _, v14 in v7 do
				if not v14.IsPlaying then
					continue
				end

				timePosition = v14.TimePosition
				break
			end

			v12:Play(0.2, 1, 0.75)

			if timePosition and timePosition < 0.2 then
				v12.TimePosition = timePosition
			elseif timePosition and timePosition >= 0.2 then
				for _, v14 in v7 do
					if v14.IsPlaying then
						v14:Stop(0.2)
					end
				end
			end
		end
	end

	SoundController:PlaySound("Sounds.Sfx.DoubleJump", nil, false)
	local clone = script.DoubleJumpVFX:Clone()
	clone.Parent = humanoid.RootPart
	VFX.emit(clone)
	task.delay(3, function()
		clone:Destroy()
	end)
	local rootPart = humanoid.RootPart

	if rootPart then
		local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity
		rootPart.AssemblyLinearVelocity = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z)
	end

	humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

	if rootPart then
		task.defer(function()
			local v12 = math.sqrt(2 * workspace.Gravity * humanoid.JumpHeight * 6.5)
			local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity

			if humanoid.MoveDirection.Magnitude > 0.01 then
				v5 = 1
			end

			rootPart.AssemblyLinearVelocity = Vector3.new(assemblyLinearVelocity.X, v12, assemblyLinearVelocity.Z) + humanoid.MoveDirection * 80
		end)
	end
end

function MultiJumpController.Start(_)
	local maid = Trove.new()

	local function onCharacterAdded(instance)
		maid:Clean()
		resetJumps() -- equivalent call inferred; original call site unknown
		v3 = false
		v4 = 1
		now = 0
		flag2 = false
		local humanoid = instance:WaitForChild("Humanoid")

		if not humanoid then
			return
		end

		local animator = humanoid:WaitForChild("Animator", 5)

		if animator then
			local v11 = { script.DoubleJump1, script.DoubleJump2 }
			local tracks = table.create(#v11)

			for k, _ in v11 do
				tracks[k] = animator:LoadAnimation(v11[k])
			end

			v7 = tracks
			local v12 = { script.Fall1, script.Fall2 }
			local tracks2 = table.create(#v12)

			for k, _ in v12 do
				tracks2[k] = animator:LoadAnimation(v12[k])
			end

			v8 = tracks2
			local v13 = { script.LightLand1, script.LightLand2 }
			local tracks3 = table.create(#v13)

			for k, _ in v13 do
				tracks3[k] = animator:LoadAnimation(v13[k])
			end

			v9 = tracks3
			local v14 = { script.HeavyLand1, script.HeavyLand2 }
			local tracks4 = table.create(#v14)

			for k, _ in v14 do
				tracks4[k] = animator:LoadAnimation(v14[k])
			end

			v10 = tracks4

			for _, v15 in v7 do
				v15.Priority = Enum.AnimationPriority.Action2
			end

			for _, v15 in v9 do
				v15.Priority = Enum.AnimationPriority.Action
			end

			for _, v15 in v10 do
				v15.Priority = Enum.AnimationPriority.Action
			end

			for _, v15 in v8 do
				v15.Looped = true
			end
		end

		local v11 = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateFallFlingProtection()
			local v12 = v

			if v12 then
				if getPlayerExtraJumps() > 0 then
					v12 = v6 >= 150
				else
					v12 = false
				end
			end

			if v12 == v11 then
				return
			end

			v11 = v12
			humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not v12)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not v12)
		end

		maid:Add(function()
			if v11 then
				humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
			end
		end)
		maid:Add(humanoid.StateChanged:Connect(function(_, p)
			if p == Enum.HumanoidStateType.Freefall then
				v = true

				if now == 0 then
					now = os.clock()
				end

				local rootPart = humanoid.RootPart

				if rootPart then
					local Y = rootPart.Position.Y

					if v6 < Y then
						v6 = Y
					end
				end

				updateFallFlingProtection() -- equivalent call inferred; original call site unknown

				if v3 and getPlayerExtraJumps() > 0 then
					for _, v12 in v8 do
						if v12.IsPlaying then
							v12:Stop(0.2)
						end
					end

					local v12 = v8[v4]

					if v12 then
						v12:Play(0.2)
					end
				end
			elseif p == Enum.HumanoidStateType.Landed or p == Enum.HumanoidStateType.Running then
				local rootPart = humanoid.RootPart
				local v12 = rootPart and rootPart.AssemblyLinearVelocity.Y <= -200

				if v11 and rootPart then
					local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity
					rootPart.AssemblyLinearVelocity = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z)
				end

				if (v3 or v12) and rootPart and getPlayerExtraJumps() > 0 then
					for _, v13 in v8 do
						if v13.IsPlaying then
							v13:Stop(0.2)
						end
					end

					for _, v13 in v7 do
						if v13.IsPlaying then
							v13:Stop(0.2)
						end
					end

					local v13 = not (now > 0) and 0 or os.clock() - now

					if v12 then
						local v14 = v10[v4]

						if v14 then
							flag2 = true
							local jumpPower = humanoid.JumpPower
							local jumpHeight = humanoid.JumpHeight
							humanoid.WalkSpeed = 0
							humanoid.JumpPower = 0
							humanoid.JumpHeight = 0
							SoundController:PlaySound("Sounds.Sfx.GroundSmash", nil, false)
							local raycastParams = RaycastParams.new()
							raycastParams.FilterType = Enum.RaycastFilterType.Exclude
							raycastParams.RespectCanCollide = true
							raycastParams.FilterDescendantsInstances = { instance }
							local raycastResult = workspace:Raycast(
								rootPart.CFrame.Position,
								createVector(0, -100, 0),
								raycastParams
							)
							local orientation = rootPart.CFrame.Rotation:ToOrientation()
							local cFrame

							if raycastResult then
								cFrame = CFrame.new(raycastResult.Position) * CFrame.fromOrientation(0, orientation, 0)
							else
								cFrame = rootPart.CFrame + Vector3.new(
									0,
									-(humanoid.HipHeight + 0.5 * rootPart.Size.Y),
									0
								)
							end

							local clone = script.CrackVFX:Clone()
							clone.CFrame = cFrame
							clone.Parent = workspace
							VFX.emit(clone)
							task.delay(3, function()
								clone:Destroy()
							end)
							v14:Play(0.1)
							task.delay(0.4, function()
								if humanoid and humanoid.Parent then
									humanoid.WalkSpeed = humanoid:GetAttribute("_speed") or 36
									humanoid.JumpPower = jumpPower
									humanoid.JumpHeight = jumpHeight
								end

								flag2 = false
							end)
						end
					else
						local v14 = v13 >= 1.5 and v9[v4]

						if v14 then
							v14:Play(0.1)
						end
					end
				end

				v3 = false
				v5 = 0.5
				hideJumpCount() -- equivalent call inferred; original call site unknown
				resetJumps() -- equivalent call inferred; original call site unknown
				now = 0

				for _, v13 in v8 do
					if v13.IsPlaying then
						v13:Stop(0.2)
					end
				end

				for _, v13 in v7 do
					if v13.IsPlaying then
						v13:Stop(0.2)
					end
				end
			end
		end))
		maid:Add(UserInputService.JumpRequest:Connect(function()
			v2 = true

			if flag or flag2 or humanoid.Health <= 0 or not v then
				return
			end

			if humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
				return
			end

			flag = true
			tryMultiJump(humanoid)
		end))
		maid:Add(RunService.PostSimulation:Connect(function(dt: number)
			if flag and not v2 then
				flag = false
			end

			v2 = false

			if v5 < 0.5 or not v3 then
				if v5 ~= -1 then
					v5 = -1
					local _speed = humanoid:GetAttribute("_speed") or 36

					if _speed < humanoid.WalkSpeed then
						humanoid.WalkSpeed = _speed
					end
				end
			else
				local rootPart = humanoid.RootPart

				if not rootPart then
					v5 = 0.5
					return
				end

				local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity
				v5 *= 0.995 ^ (dt * 60)
				local _speed = humanoid:GetAttribute("_speed") or 36
				humanoid.WalkSpeed = _speed * 2
				local moveDirection = humanoid.MoveDirection
				local v12 = moveDirection.X * (v5 * 80 + _speed)
				local v13 = moveDirection.Z * (v5 * 80 + _speed)
				local X = assemblyLinearVelocity.X
				local v14 = 1 - 0.1608066690215766 ^ dt
				local v15 = X + (v12 - X) * v14
				local Y = assemblyLinearVelocity.Y
				local Z = assemblyLinearVelocity.Z
				local v16 = 1 - 0.1608066690215766 ^ dt
				rootPart.AssemblyLinearVelocity = Vector3.new(v15, Y, Z + (v13 - Z) * v16)
			end
		end))
	end

	localPlayer.CharacterAdded:Connect(onCharacterAdded)

	if localPlayer.Character then
		task.spawn(onCharacterAdded, localPlayer.Character)
	end
end

return MultiJumpController