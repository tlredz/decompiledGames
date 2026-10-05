local createVector = vector.create
local TBLunge = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")

if not RunService:IsClient() then
	return TBLunge
end

local Network = require(ReplicatedStorage.SharedUtils.Network)
local TowerLUT = require(ReplicatedStorage.SharedUtils:WaitForChild("TowerLUT"))
local TBSounds = require(ReplicatedStorage.Parts.RenderModules.TBSounds)
local v = {}
local v2 = {}
local v3 = nil
local characterRemovingConnection = nil

local function playAnimOn(clone, p, p2, priority)
	if not clone then
		return nil
	end

	local animationController = clone:FindFirstChildWhichIsA("AnimationController") or clone:FindFirstChildWhichIsA("Humanoid")

	if not animationController then
		warn(("[TBLunge] %s has no AnimationController or Humanoid; cannot play anim %s"):format(
			clone.Name,
			(tostring(p))
		))
		return nil
	end

	local v4 = animationController:FindFirstChildWhichIsA("Animator")

	if not v4 then
		v4 = Instance.new("Animator")
		v4.Parent = animationController
	end

	for _, v5 in ipairs(v4:GetPlayingAnimationTracks()) do
		v5:Stop()
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://" .. tostring(p)
	local track = v4:LoadAnimation(animation)

	if priority then
		track.Priority = priority
	end

	track.Looped = p2 == true
	track:Play()
	return track
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getTargetCFrame(character, latchedAttachment)
	if latchedAttachment and latchedAttachment.Parent then
		return latchedAttachment.WorldCFrame
	end

	local primaryPart = character and character.PrimaryPart

	if primaryPart and primaryPart.Parent then
		return primaryPart.CFrame
	end

	return nil
end

local function bindTBToLatch(clone, character, latchedAttachment, p)
	local v4 = p or createVector(0, 0, 0.65)

	if latchedAttachment and latchedAttachment.Parent then
		local attachment = Instance.new("Attachment")
		attachment.Name = "WeldAnchor"
		attachment.CFrame = CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(v4.X, v4.Y, v4.Z)
		attachment.Parent = clone.PrimaryPart
		local rigidConstraint = Instance.new("RigidConstraint")
		rigidConstraint.Attachment0 = latchedAttachment
		rigidConstraint.Attachment1 = attachment
		rigidConstraint.Parent = clone
		return rigidConstraint
	else
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = character.PrimaryPart
		weldConstraint.Part1 = clone.PrimaryPart
		weldConstraint.Parent = clone
		return weldConstraint
	end
end

local function setLaunchBeams(instance, enabled)
	for _, childName in ipairs({ "Beam1", "Beam2" }) do
		local child = instance:FindFirstChild(childName, true)
		local beam = child and child:FindFirstChild("Beam")

		if beam and beam:IsA("Beam") then
			beam.Enabled = enabled
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setLaunchTrail(clone, enabled)
	local trail1 = clone:FindFirstChild("Trail1", true)
	local trail = trail1 and trail1:FindFirstChild("Trail")

	if trail and trail:IsA("Trail") then
		trail.Enabled = enabled
	end
end

local function emitImpact(clone)
	local impact = clone:FindFirstChild("Impact", true)

	if not impact then
		return
	end

	for _, emitter in ipairs(impact:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(1)
		end
	end
end

local function dbg(...) end

local _ = {
	EyeStrength = 30,
	AggroStrength = 50
}
local v4 = {
	Normal = true,
	Blink = true,
	Attack = true
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getInfo()
	return workspace:FindFirstChild("Info")
end

local function blackoutActive()
	local info = getInfo() -- equivalent call inferred; original call site unknown
	local blackOut = info and info:FindFirstChild("BlackOut")
	return blackOut ~= nil and blackOut.Value == true
end

local function currentEyeStrength()
	local info = getInfo() -- equivalent call inferred; original call site unknown

	if not info then
		return 0
	end

	if info:GetAttribute("EmissiveBlackoutOnly") ~= false then
		local info2 = getInfo() -- equivalent call inferred; original call site unknown
		local blackOut = info2 and info2:FindFirstChild("BlackOut")
		local v5

		if blackOut == nil then
			v5 = false
		else
			v5 = blackOut.Value == true
		end

		if not v5 then
			return 0
		end
	end

	local v5

	if info:GetAttribute("EmissiveAggroBoost") then
		v5 = info:GetAttribute("EmissiveAggroStrength") or 50
	else
		v5 = info:GetAttribute("EmissiveEyeStrength") or 30
	end

	return v5 * 2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setTBGlow(folder, emissiveStrength, duration)
	for _, surfaceAppearance in ipairs(folder:GetDescendants()) do
		if not (surfaceAppearance:IsA("SurfaceAppearance") and v4[surfaceAppearance.Name]) then
			continue
		end

		if duration and duration > 0 then
			TweenService:Create(
				surfaceAppearance,
				TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					EmissiveStrength = emissiveStrength
				}
			):Play()
		else
			surfaceAppearance.EmissiveStrength = emissiveStrength
		end
	end
end

local function bindTBGlow(clone)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function refresh(p)
		setTBGlow(clone, currentEyeStrength(), p)
	end

	setTBGlow(clone, (currentEyeStrength())) -- equivalent call inferred; original call site unknown
	local connections = {}
	local info = getInfo() -- equivalent call inferred; original call site unknown
	local blackOut = info and info:FindFirstChild("BlackOut")

	if blackOut then
		connections[#connections + 1] = blackOut:GetPropertyChangedSignal("Value"):Connect(function()
			refresh(0.4) -- equivalent call inferred; original call site unknown
		end)
	end

	if info then
		for _, v6 in ipairs({
			"EmissiveBlackoutOnly",
			"EmissiveEyeStrength",
			"EmissiveAggroStrength",
			"EmissiveAggroBoost"
		}) do
			connections[#connections + 1] = info:GetAttributeChangedSignal(v6):Connect(function()
				refresh(0.4) -- equivalent call inferred; original call site unknown
			end)
		end
	end

	local function disconnectAll()
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end

		table.clear(connections)
	end

	clone.Destroying:Once(disconnectAll)
	return disconnectAll
end

local function prewarmFaceGlow(folder)
	local surfaceAppearances = {}

	for _, surfaceAppearance in ipairs(folder:GetDescendants()) do
		if surfaceAppearance:IsA("SurfaceAppearance") and v4[surfaceAppearance.Name] then
			surfaceAppearances[#surfaceAppearances + 1] = surfaceAppearance
		end
	end

	if #surfaceAppearances == 0 then
		return
	end

	local v5 = false
	task.spawn(function()
		pcall(function()
			ContentProvider:PreloadAsync(surfaceAppearances)
		end)
		v5 = true
	end)
	local v6 = os.clock() + 0.4

	while not v5 and os.clock() < v6 do
		task.wait()
	end
end

local function runLunge(player, p, cframe, value)
	dbg("[TBDBG] runLunge BEGIN")
	local v5 = math.max(0, p - workspace:GetServerTimeNow())

	if v5 > 0 then
		task.wait(v5)
	end

	if not (player and player.Parent) then
		dbg("[TBDBG] ABORT: targetPlayer gone after wait")
		return
	end

	local character = player.Character

	if not character then
		dbg("[TBDBG] ABORT: no character after wait")
	elseif p and v2[p] then
		v2[p] = nil
		dbg("[TBDBG] ABORT: cancelledBeforeLand (early TBLungeEnd)")
	else
		local latchedAttachment = TowerLUT:FindOrCreateLatchedAttachment(character)
		dbg(string.format(
			"[TBDBG] attachment=%s | PrimaryPart=%s",
			latchedAttachment and "FOUND" or "nil",
			not character.PrimaryPart and "nil" or character.PrimaryPart.Name or "nil"
		))

		-- equivalent call inferred; original call site unknown
		if not getTargetCFrame(character, latchedAttachment) then
			dbg("[TBDBG] ABORT: getTargetCFrame nil (no attachment + no PrimaryPart)")
			return
		end

		local tBarnaby_v3 = ReplicatedStorage.Parts:FindFirstChild("TBarnaby_v3")

		if tBarnaby_v3 then
			local clone = tBarnaby_v3:Clone()

			if clone.PrimaryPart then
				for _, descendant in ipairs(clone:GetDescendants()) do
					if descendant:IsA("BasePart") then
						descendant.Anchored = true
						descendant.CanCollide = false
						descendant.CanQuery = false
						descendant.CanTouch = false
						descendant.Massless = true
					elseif descendant:IsA("Attachment") and descendant.Name == "TailSplash" then
						descendant:Destroy()
					end
				end

				prewarmFaceGlow(clone)
				clone:PivotTo(cframe)
				clone.Parent = workspace
				local count = 0
				local count2 = 0
				local transparency = 1
				local transparency2 = 0

				for _, part in ipairs(clone:GetDescendants()) do
					if not part:IsA("BasePart") then
						continue
					end

					count += 1

					if part.Transparency < 1 then
						count2 += 1
					end

					if part.Transparency < transparency then
						transparency = part.Transparency
					end

					if transparency2 < part.Transparency then
						transparency2 = part.Transparency
					end
				end

				dbg(string.format(
					"[TBDBG] clone PARENTED to workspace | parts=%d | visible(T<1)=%d | T range=[%.2f..%.2f] | pivot=%s",
					count,
					count2,
					transparency,
					transparency2,
					(tostring(clone:GetPivot().Position))
				))
				playAnimOn(clone, 73718027558794, true, Enum.AnimationPriority.Action3)
				local v6 = bindTBGlow(clone)
				TBSounds.playOneShot(clone, "Attack1_Lunge")
				TBSounds.setLoop(clone, nil)
				setLaunchTrail(clone, true) -- equivalent call inferred; original call site unknown
				local position = cframe.Position
				local total = 0

				while total < 0.35 and clone.Parent and character.Parent do
					if p and v2[p] then
						v2[p] = nil
						dbg("[TBDBG] ABORT mid-arc: cancelledBeforeLand (early TBLungeEnd)")
						clone:Destroy()
						return
					else
						local targetCFrame = getTargetCFrame(character, latchedAttachment) -- equivalent call inferred; original call site unknown

						if not targetCFrame then
							break
						end

						local v7 = math.min(total / 0.35, 1)
						local position2 = targetCFrame.Position
						local v8 = (position + position2) * 0.5 + createVector(0, 8, 0)
						local v9 = (1 - v7) * (1 - v7) * position + (1 - v7) * 2 * v7 * v8 + v7 * v7 * position2
						clone:PivotTo(CFrame.new(v9))
						total += RunService.Heartbeat:Wait()
					end
				end

				if clone.Parent and character.Parent then
					local targetCFrame = getTargetCFrame(character, latchedAttachment) -- equivalent call inferred; original call site unknown

					if targetCFrame then
						if p and v2[p] then
							v2[p] = nil
							dbg("[TBDBG] ABORT pre-weld: cancelledBeforeLand (early TBLungeEnd)")
							clone:Destroy()
						else
							clone:PivotTo(targetCFrame)
							local v7 = bindTBToLatch(clone, character, latchedAttachment)
							dbg(string.format(
								"[TBDBG] LANDED + bound | bindType=%s | landedPos=%s | tbStillParented=%s",
								not v7 and "nil" or v7.ClassName or "nil",
								tostring(targetCFrame.Position),
								(tostring(clone.Parent ~= nil))
							))

							for _, part in ipairs(clone:GetDescendants()) do
								if part:IsA("BasePart") then
									part.Anchored = false
								end
							end

							if latchedAttachment and latchedAttachment.Parent and player == Players.LocalPlayer then
								task.spawn(function()
									local tBarnabyRemovePrompt = latchedAttachment:WaitForChild(
										"TBarnabyRemovePrompt",
										2
									)

									if tBarnabyRemovePrompt and tBarnabyRemovePrompt:IsA("ProximityPrompt") then
										tBarnabyRemovePrompt.MaxActivationDistance = 0
									end
								end)
							end

							TBSounds.setLoop(clone, "Attack2_Gnawing_Loop")
							setLaunchTrail(clone, false) -- equivalent call inferred; original call site unknown
							emitImpact(clone)
							local flag = false
							local runDespawn

							runDespawn = function()
								if flag then
									return
								end

								flag = true

								if not clone.Parent then
									return
								end

								if v7 and v7.Parent then
									v7:Destroy()
								end

								for _, part in ipairs(clone:GetDescendants()) do
									if part:IsA("BasePart") then
										part.Anchored = true
									end
								end

								playAnimOn(clone, 94592822431998, false, Enum.AnimationPriority.Action4)
								TBSounds.setLoop(clone, "FloppingOnFloor_Loop")
								local position2 = clone:GetPivot().Position
								local raycastParams = RaycastParams.new()
								raycastParams.FilterType = Enum.RaycastFilterType.Exclude
								raycastParams.FilterDescendantsInstances = { clone, character }
								local raycastResult = workspace:Raycast(
									position2,
									createVector(0, -50, 0),
									raycastParams
								)
								local v8

								if raycastResult then
									v8 = raycastResult.Position + createVector(0, 0.5, 0) or nil
								end

								if v8 then
									local total2 = 0

									while total2 < 0.4 and clone.Parent do
										local v9 = math.min(total2 / 0.4, 1)
										local v10 = v9 * v9
										clone:PivotTo(CFrame.new(position2:Lerp(v8, v10)))
										total2 += RunService.Heartbeat:Wait()
									end

									if clone.Parent then
										clone:PivotTo(CFrame.new(v8))
									end

									task.wait(1.3000000000000003)
								else
									task.wait(1.7000000000000002)
								end

								if not (clone and clone.Parent) then
									return
								end

								TBSounds.playOneShot(clone, "Jump_Up")
								TBSounds.fadeLoop(clone, "FloppingOnFloor_Loop", 1, 0)
								task.wait(1)

								if not (clone and clone.Parent) then
									return
								end

								local ichorSplash = ReplicatedStorage.Parts:FindFirstChild("IchorSplash")

								if ichorSplash and ichorSplash:IsA("Attachment") then
									local part = Instance.new("Part")
									part.Name = "TBLungeSplashAnchor"
									part.Size = createVector(0.1, 0.1, 0.1)
									part.Transparency = 1
									part.Anchored = true
									part.CanCollide = false
									part.CanQuery = false
									part.CanTouch = false
									part.CFrame = raycastResult and CFrame.new(raycastResult.Position + createVector(
										0,
										-0.5,
										0
									)) or clone:GetPivot()
									part.Parent = workspace
									local clone2 = ichorSplash:Clone()
									clone2.Parent = part
									local particleEmitter = clone2:FindFirstChild("ParticleEmitter")

									if particleEmitter and particleEmitter:IsA("ParticleEmitter") then
										particleEmitter.Enabled = false
										particleEmitter:Emit(1)
									end

									local Debris = game:GetService("Debris")
									Debris:AddItem(part, 3)
								end

								TBSounds.playOneShot(clone, "Jump_Land")
								v6()
								setTBGlow(clone, 0, 0.5)
								local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)

								for _, descendant in ipairs(clone:GetDescendants()) do
									if not (descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture")) then
										continue
									end

									TweenService:Create(descendant, tweenInfo, {
										Transparency = 1
									}):Play()
								end

								task.wait(0.5)

								if clone and clone.Parent then
									clone:Destroy()
								end

								if v[p] == runDespawn then
									v[p] = nil
								end
							end

							if p ~= nil then
								v[p] = runDespawn
							end

							task.delay(value or 10, runDespawn)
						end
					else
						dbg("[TBDBG] ABORT post-arc: landedCF nil")
						clone:Destroy()
					end
				else
					dbg("[TBDBG] ABORT post-arc: tb or character no longer parented")

					if clone.Parent then
						clone:Destroy()
					end
				end
			else
				warn("[TBLunge] TB clone has no PrimaryPart; cannot run lunge")
				dbg("[TBDBG] ABORT: clone has no PrimaryPart")
				clone:Destroy()
			end
		else
			warn("[TBLunge] TBarnaby_v3 missing from ReplicatedStorage.Parts")
			dbg("[TBDBG] ABORT: TBarnaby_v3 template missing")
		end
	end
end

Network:AddAction("TBLungeEnd", function(p)
	if p == nil then
		local v5 = {}

		for k, v6 in pairs(v) do
			v5[#v5 + 1] = v6
			v[k] = nil
		end

		for _, callback in ipairs(v5) do
			task.spawn(callback)
		end
	else
		local v5 = v[p]

		if v5 then
			v[p] = nil
			task.spawn(v5)
		else
			v2[p] = true
			task.delay(5, function()
				v2[p] = nil
			end)
		end
	end
end)
Network:AddAction("TBLungeStart", function(p, p2, p3, p4)
	dbg(string.format(
		"[TBDBG] TBLungeStart RECEIVED on %s | target=%s | ts=%s | latchDur=%s",
		Players.LocalPlayer and Players.LocalPlayer.Name or "?",
		not p and "nil" or p.Name or "nil",
		tostring(p2),
		(tostring(p4))
	))
	task.spawn(runLunge, p, p2, p3, p4)
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function clearLatchPreview()
	if characterRemovingConnection then
		characterRemovingConnection:Disconnect()
		characterRemovingConnection = nil
	end

	if v3 then
		if v3.Parent then
			v3:Destroy()
		end

		v3 = nil
	end
end

Network:AddAction("TBLungePreview", function(player, p, p2)
	clearLatchPreview() -- equivalent call inferred; original call site unknown

	if not (p and (player and player.Parent)) then
		return
	end

	local character = player.Character or workspace:FindFirstChild("InGamePlayers") and workspace.InGamePlayers:FindFirstChild(player.Name)

	if not character then
		return
	end

	local tBarnaby_v3 = ReplicatedStorage.Parts:FindFirstChild("TBarnaby_v3")

	if not tBarnaby_v3 then
		warn("[TBLunge] TBarnaby_v3 missing from ReplicatedStorage.Parts")
		return
	end

	local latchedAttachment = TowerLUT:FindOrCreateLatchedAttachment(character)
	local targetCFrame = getTargetCFrame(character, latchedAttachment) -- equivalent call inferred; original call site unknown

	if not targetCFrame then
		return
	end

	local clone = tBarnaby_v3:Clone()

	if clone.PrimaryPart then
		for _, descendant in ipairs(clone:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.Anchored = true
				descendant.CanCollide = false
				descendant.CanQuery = false
				descendant.CanTouch = false
				descendant.Massless = true
			elseif descendant:IsA("Attachment") and descendant.Name == "TailSplash" then
				descendant:Destroy()
			end
		end

		clone:PivotTo(targetCFrame)
		clone.Parent = workspace
		bindTBToLatch(clone, character, latchedAttachment, typeof(p2) == "Vector3" and p2 or nil)

		for _, part in ipairs(clone:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = false
			end
		end

		playAnimOn(clone, 73718027558794, true, Enum.AnimationPriority.Action3)
		bindTBGlow(clone)
		v3 = clone
		characterRemovingConnection = player.CharacterRemoving:Connect(clearLatchPreview)
	else
		warn("[TBLunge] preview TB clone has no PrimaryPart; cannot weld")
		clone:Destroy()
	end
end)
return TBLunge