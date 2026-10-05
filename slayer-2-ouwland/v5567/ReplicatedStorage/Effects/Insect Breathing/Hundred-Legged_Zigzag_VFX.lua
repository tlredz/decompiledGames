local createVector = vector.create
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.CAM.Client.Modules
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
require(modules.Effects.Craters.CraterHandler)
require(modules.Effects.Craters.CraterEffects)
local _ = Players.LocalPlayer
local assets = script:FindFirstChild("Assets")
local debree = workspace.Debree
local sounds = script:FindFirstChild("Sounds")
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(game.ReplicatedStorage.CAM.DebrisModule)
require(modules.Effects.BoatTween)
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include
local _ = game.Players.LocalPlayer
local _ = workspace.CurrentCamera
local raycastParams2 = RaycastParams.new()
raycastParams2.FilterType = Enum.RaycastFilterType.Include
raycastParams2.FilterDescendantsInstances = { workspace.Map }

local function SpawnSwordAura(instance)
	local sword_At_A = instance:FindFirstChild("Sword_At_A", true)

	if sword_At_A == nil then
		return
	end

	local parent = sword_At_A.Parent
	local clone = script.Parent.SwordAura:Clone()
	clone.CFrame = parent.CFrame
	clone.Parent = debree
	vfxUtility.EnableAll(clone, true, vfxUtility.Owned(instance))
	vfxUtility.WeldConstraint(clone, parent)
	DebrisModule:AddItem(clone, 10)
	return clone
end

local function Random_Number(p, p2)
	return Random.new():NextNumber(p, p2)
end

return function(instance, p, value)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local upperTorso = instance:FindFirstChild("UpperTorso")
	local leftFoot = instance:FindFirstChild("LeftFoot")
	local rightFoot = instance:FindFirstChild("RightFoot")
	local humanoid = instance:FindFirstChild("Humanoid")

	if not (humanoidRootPart and upperTorso and leftFoot and rightFoot) then
		return
	end

	if not humanoid then
		return
	end

	local name = string.format("%s_%s_Effects", instance.Name, script.Name)

	if p ~= "Cancel" and (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	local child = debree:FindFirstChild(name)

	if p == "Dashing" then
		if child ~= nil then
			child:Destroy()
		end

		local folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = debree
		folder:SetAttribute("Active", true)
		DebrisModule:AddItem(folder, 5)
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			createVector(0, -20, 0),
			vfxUtility.RayParams.Map
		)
		local instance2

		if raycastResult then
			instance2 = raycastResult.Instance
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function SetPartCFrame(p2, p3)
			return humanoidRootPart.CFrame * p2.CFrame:ToObjectSpace(p3.CFrame)
		end

		local spawnSwordAura = SpawnSwordAura(instance)
		spawnSwordAura.Parent = folder
		local v2 = vfxUtility.PlaySound(sounds, "PS2insectHLZstart", humanoidRootPart, true)
		task.wait(0.35)

		if folder:GetAttribute("Active") ~= true then
			return
		end

		local clone = assets.Grab.StartSlash:Clone()
		clone:PivotTo(SetPartCFrame(assets.Grab.Root, assets.Grab.StartSlash.PrimaryPart))
		clone.Parent = debree
		vfxUtility.ChangeDustColor(
			instance2,
			{ clone.GroundFX.raycastdust, clone.GroundFX.raycastdust2, clone.GroundFX.raycastdust3 }
		)
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 2)
		Cam_Shaker(upperTorso, {
			FadeInTime = 0,
			Frequency = 0.05,
			Amplitude = 0.1,
			SustainTime = 0.16,
			FadeOutTime = 0.3,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(0.15, 0.15, 0.15),
			MinDistance = 6,
			DistanceStretch = 2
		})
		local clone2 = assets.Grab.BeamSlash:Clone()
		clone2.CFrame = SetPartCFrame(assets.Grab.Root, assets.Grab.BeamSlash)
		clone2.Parent = debree
		DebrisModule:AddItem(clone2, 1)
		TweenService:Create(
			clone2.SpinAttachment,
			TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = clone2.SpinAttachment.CFrame * CFrame.Angles(0, 3.12413936106985, 0)
			}
		)

		for _, beam in clone2.SpinAttachment:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			local v3 = beam
			task.delay(0.05, function()
				TweenService:Create(v3, TweenInfo.new(0.1), {
					TextureLength = 1
				}):Play()
				task.wait(0.03)
				TweenService:Create(v3, TweenInfo.new(0.1), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end)
		end

		local v3 = value + 0.15

		if v3 > 0.75 then
			task.wait(0.4)

			if folder:GetAttribute("Active") ~= true then
				return
			end

			vfxUtility.PlaySound(sounds, "PS2insectFSland", humanoidRootPart, true)
			task.wait(v3 - 0.75)

			if folder:GetAttribute("Active") ~= true then
				return
			end
		else
			task.wait(v3 - 0.35)

			if folder:GetAttribute("Active") ~= true then
				return
			end

			if v2 then
				TweenService:Create(v2, TweenInfo.new(0.15), {
					Volume = 0
				}):Play()
			end
		end

		local lastTime = os.clock()
		vfxUtility.PlaySound(sounds, "PS2insectHLZdash", humanoidRootPart, true)

		local function SpawnClone()
			local clone3 = game.ReplicatedStorage.Assets.StarterCharacterCloneable:Clone()
			clone3.Name = "Clone"

			for _, tag in pairs(clone3:GetTags()) do
				clone3:RemoveTag(tag)
			end

			for _, part in pairs(clone3:GetDescendants()) do
				if part:IsA("BasePart") then
					local child2 = instance:FindFirstChild(part.Name)

					if child2 == nil then
						part:Destroy()
					else
						part.CFrame = child2.CFrame
						part.Anchored = true
						TweenService:Create(part, TweenInfo.new(0.45), {
							Color = Color3.new(0.929412, 0.164706, 1)
						}):Play()
						TweenService:Create(part, TweenInfo.new(0.85), {
							Transparency = 1
						}):Play()
					end
				else
					part:Destroy()
				end
			end

			clone3.Parent = debree
			DebrisModule:AddItem(clone3, 0.85)
		end

		local clone3 = script.Sounds.PS2insectCEHloop:Clone()
		clone3.Parent = humanoidRootPart
		clone3:Play()

		while os.clock() - lastTime < 8 and folder ~= nil and folder.Parent ~= nil and folder:GetAttribute("Active") and folder:GetAttribute("Active") do
			local raycastResult2 = workspace:Raycast(
				upperTorso.Position,
				createVector(0, -10, 0),
				vfxUtility.RayParams.Map
			)
			local instance3

			if raycastResult2 then
				instance3 = raycastResult2.Instance
			end

			local clone4 = assets.Jump:Clone()
			clone4.CFrame = humanoidRootPart.CFrame * CFrame.new(-3, -3, 0) * CFrame.Angles(0, 1.5707963267948966, 0)
			clone4.Parent = debree
			vfxUtility.ChangeDustColor(instance3, { clone4.raycastdust, clone4.raycastdust2 })
			vfxUtility.EmitAll(clone4, vfxUtility.Owned(instance))
			DebrisModule:AddItem(clone4, 2)
			Cam_Shaker(upperTorso, "punch_shake")
			SpawnClone()
			task.wait(0.15)

			if not folder:GetAttribute("Active") then
				break
			end

			local raycastResult3 = workspace:Raycast(
				upperTorso.Position,
				createVector(0, -10, 0),
				vfxUtility.RayParams.Map
			)
			local instance4

			if raycastResult3 then
				instance4 = raycastResult3.Instance
			end

			local clone5 = assets.Jump:Clone()
			clone5.CFrame = humanoidRootPart.CFrame * CFrame.new(3, -3, 0) * CFrame.Angles(0, 3.141592653589793, 0)
			clone5.Parent = debree
			vfxUtility.ChangeDustColor(instance4, { clone5.raycastdust, clone5.raycastdust2 })
			vfxUtility.EmitAll(clone5, vfxUtility.Owned(instance))
			DebrisModule:AddItem(clone5, 2)
			Cam_Shaker(upperTorso, "punch_shake")
			SpawnClone()
			task.wait(0.33)

			if not folder:GetAttribute("Active") then
				break
			end
		end

		clone3:Stop()
		clone3:Destroy()
	elseif p == "Grab" then
		local timePosition = value or 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function waitBeat(p2)
			local v3 = p2 - timePosition
			timePosition = math.max(timePosition - p2, 0)

			if v3 > 0 then
				task.wait(v3)
			end
		end

		local v3 = vfxUtility.PlaySound(sounds, "PS2insectHLZcineFULLSTART", humanoidRootPart, true)

		if v3 then
			v3.TimePosition = timePosition
		end

		local pS2insectHLZstart = humanoidRootPart:FindFirstChild("PS2insectHLZstart")

		if pS2insectHLZstart then
			pS2insectHLZstart:Destroy()
		end

		if child ~= nil then
			child:SetAttribute("Active", nil)
			child:Destroy()
		end

		local folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = debree
		folder:SetAttribute("Active", true)
		DebrisModule:AddItem(folder, 5)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function SetPartCFrame(p2, p3)
			return humanoidRootPart.CFrame * p2.CFrame:ToObjectSpace(p3.CFrame)
		end

		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			createVector(0, -20, 0),
			vfxUtility.RayParams.Map
		)
		local instance2

		if raycastResult then
			instance2 = raycastResult.Instance
		end

		waitBeat(0.05) -- equivalent call inferred; original call site unknown

		if not folder:GetAttribute("Active") then
			return
		end

		local spawnSwordAura = SpawnSwordAura(instance)
		local clone = assets.Grab.Startup:Clone()
		clone.CFrame = SetPartCFrame(assets.Grab.Root, assets.Grab.Startup)
		clone.Parent = debree
		vfxUtility.ChangeDustColor(instance2, { clone.raycastdust, clone.raycastdust2 })
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 2)
		waitBeat(0.233) -- equivalent call inferred; original call site unknown

		if not folder:GetAttribute("Active") then
			return
		end

		local clone2 = assets.Grab.StartSlash:Clone()
		clone2:PivotTo(SetPartCFrame(assets.Grab.Root, assets.Grab.StartSlash.PrimaryPart))
		clone2.Parent = debree
		vfxUtility.ChangeDustColor(
			instance2,
			{ clone2.GroundFX.raycastdust, clone2.GroundFX.raycastdust2, clone2.GroundFX.raycastdust3 }
		)
		vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone2, 2)
		Cam_Shaker(upperTorso, {
			FadeInTime = 0,
			Frequency = 0.05,
			Amplitude = 0.1,
			SustainTime = 0.16,
			FadeOutTime = 0.3,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(0.15, 0.15, 0.15),
			MinDistance = 6,
			DistanceStretch = 2
		})
		waitBeat(0.084) -- equivalent call inferred; original call site unknown

		if not folder:GetAttribute("Active") then
			return
		end

		local clone3 = assets.Grab.BeamSlash:Clone()
		clone3.CFrame = SetPartCFrame(assets.Grab.Root, assets.Grab.BeamSlash)
		clone3.Parent = debree
		DebrisModule:AddItem(clone3, 1)
		TweenService:Create(
			clone3.SpinAttachment,
			TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = clone3.SpinAttachment.CFrame * CFrame.Angles(0, 3.12413936106985, 0)
			}
		)

		for _, beam in clone3.SpinAttachment:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			local v5 = beam
			task.delay(0.05, function()
				TweenService:Create(v5, TweenInfo.new(0.1), {
					TextureLength = 1
				}):Play()
				task.wait(0.03)
				TweenService:Create(v5, TweenInfo.new(0.1), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end)
		end

		waitBeat(0.666) -- equivalent call inferred; original call site unknown

		if not folder:GetAttribute("Active") then
			return
		end

		local clone4 = assets.Grab.RightFootStep:Clone()
		clone4.CFrame = SetPartCFrame(assets.Grab.Root, assets.Grab.RightFootStep)
		clone4.Parent = debree
		vfxUtility.ChangeDustColor(instance2, { clone4.raycastdust, clone4.raycastdust2 })
		vfxUtility.EmitAll(clone4, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone4, 2)
		Cam_Shaker(upperTorso, "punch_shake")
		waitBeat(0.184) -- equivalent call inferred; original call site unknown

		if not folder:GetAttribute("Active") then
			return
		end

		local clone5 = assets.Grab.LeftSideJump:Clone()
		clone5.CFrame = SetPartCFrame(assets.Grab.Root, assets.Grab.LeftSideJump)
		clone5.Parent = debree
		vfxUtility.ChangeDustColor(instance2, { clone5.raycastdust, clone5.raycastdust2 })
		vfxUtility.EmitAll(clone5, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone5, 2)
		Cam_Shaker(upperTorso, "punch_shake")
		waitBeat(0.1) -- equivalent call inferred; original call site unknown

		if not folder:GetAttribute("Active") then
			return
		end

		local clone6 = assets.Grab.RightSideJump:Clone()
		clone6.CFrame = SetPartCFrame(assets.Grab.Root, assets.Grab.RightSideJump)
		clone6.Parent = debree
		vfxUtility.ChangeDustColor(instance2, { clone6.raycastdust, clone6.raycastdust2 })
		vfxUtility.EmitAll(clone6, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone6, 2)
		Cam_Shaker(upperTorso, "punch_shake")
		waitBeat(0.15) -- equivalent call inferred; original call site unknown

		if not folder:GetAttribute("Active") then
			return
		end

		local clone7 = assets.Grab.PoisonThrust1:Clone()
		clone7:PivotTo(SetPartCFrame(assets.Grab.Root, assets.Grab.PoisonThrust1.PrimaryPart))
		clone7.Parent = debree
		vfxUtility.ChangeDustColor(instance2, { clone7.GroundFX.raycastdust, clone7.GroundFX.raycastdust2 })
		vfxUtility.EmitAll(clone7, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone7, 2)
		Cam_Shaker(upperTorso, {
			FadeInTime = 0,
			Frequency = 0.05,
			Amplitude = 0.1,
			SustainTime = 0.16,
			FadeOutTime = 0.3,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(0.15, 0.15, 0.15),
			MinDistance = 6,
			DistanceStretch = 2
		})
		waitBeat(0.55) -- equivalent call inferred; original call site unknown

		if not folder:GetAttribute("Active") then
			return
		end

		local clone8 = assets.Grab.PoisonExplosion:Clone()
		clone8:PivotTo(SetPartCFrame(assets.Grab.Root, assets.Grab.PoisonExplosion.PrimaryPart))
		clone8.Parent = debree
		vfxUtility.ChangeDustColor(instance2, { clone8.GroundFX.raycastdust })
		vfxUtility.EmitAll(clone8, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone8, 2)
		vfxUtility.EnableAll(spawnSwordAura, false)
		DebrisModule:AddItem(spawnSwordAura, 2)
		Cam_Shaker(upperTorso, {
			FadeInTime = 0,
			Frequency = 0.055,
			Amplitude = 0.5,
			SustainTime = 0.16,
			FadeOutTime = 0.3,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(3, 3, 3),
			MinDistance = 9,
			DistanceStretch = 1.5
		})
	elseif child == nil then
		return
	end

	if p == "Miss Success" then
		local child2 = debree:FindFirstChild(name)

		if child2 then
			child2.Name = "_"
			child2:SetAttribute("Active", nil)
			DebrisModule:AddItem(child2, 2)
			vfxUtility.EnableAll(child2, false)
			vfxUtility.TweenLight(child2, {
				Time = 0.01,
				Off = true
			})
		end

		task.wait(0.1)
		vfxUtility.PlaySound(sounds, "PS2insectHLZsuccess", humanoidRootPart, true)
		local raycastResult = workspace:Raycast(upperTorso.Position, createVector(0, -10, 0), vfxUtility.RayParams.Map)
		local instance2

		if raycastResult then
			instance2 = raycastResult.Instance
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function SetPartCFrame(p2, p3)
			return humanoidRootPart.CFrame * p2.CFrame:ToObjectSpace(p3.CFrame)
		end

		local clone = assets.Grab.PoisonThrust1:Clone()
		clone:PivotTo(SetPartCFrame(assets.Grab.Root, assets.Grab.PoisonThrust1.PrimaryPart))
		clone.Parent = debree
		vfxUtility.ChangeDustColor(instance2, { clone.GroundFX.raycastdust, clone.GroundFX.raycastdust2 })
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 2)
		Cam_Shaker(upperTorso, {
			FadeInTime = 0,
			Frequency = 0.05,
			Amplitude = 0.1,
			SustainTime = 0.16,
			FadeOutTime = 0.3,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(0.15, 0.15, 0.15),
			MinDistance = 6,
			DistanceStretch = 2
		})
		task.wait(0.3)
		local clone2 = assets.Grab.PoisonExplosion:Clone()
		clone2:PivotTo(SetPartCFrame(assets.Grab.Root, assets.Grab.PoisonExplosion.PrimaryPart))
		clone2.Parent = debree
		vfxUtility.ChangeDustColor(instance2, { clone2.GroundFX.raycastdust })
		vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone2, 2)
		Cam_Shaker(upperTorso, {
			FadeInTime = 0,
			Frequency = 0.055,
			Amplitude = 0.5,
			SustainTime = 0.16,
			FadeOutTime = 0.3,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(3, 3, 3),
			MinDistance = 9,
			DistanceStretch = 1.5
		})
	else
		local child2 = p == "Cancel" and debree:FindFirstChild(name)

		if child2 then
			child2.Name = "_"
			child2:SetAttribute("Active", nil)
			DebrisModule:AddItem(child2, 2)
			vfxUtility.EnableAll(child2, false)
			vfxUtility.TweenLight(child2, {
				Time = 0.01,
				Off = true
			})
		end
	end
end