local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local DebrisModule = require(CAM.DebrisModule)

local function fadeStuck(part)
	if part:GetAttribute("Fading") == true then
		return
	end

	part:SetAttribute("Fading", true)
	part.Name ..= "_Fading"
	vfxUtility.EnableAll(part, false)

	if part:IsA("BasePart") then
		TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end

	DebrisModule:AddItem(part, 0.35)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scheduleStuckFade(clone)
	task.delay(5, function()
		if clone.Parent ~= nil then
			fadeStuck(clone)
		end
	end)
end

local function stuckName(p)
	return (`{p.Name} TantoStuck`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearStuck(instance)
	local child = workspace.Debree:FindFirstChild((`{instance.Name} TantoStuck`))

	if child ~= nil then
		fadeStuck(child)
	end
end

local v = {
	Dash1 = "Dash1",
	Dash2 = "Dash2",
	Dash3 = "Dash3",
	Grab = "TantoGrab",
	Kick = "Jump"
}
local v2 = {
	Dash1 = "PS2tantoTANTODESCENTstep1",
	Dash2 = "PS2tantoTANTODESCENTstep2",
	Dash3 = "PS2tantoTANTODESCENTstep3"
}
return function(instance, p: string, model)
	if not (instance ~= nil and p ~= "Start") then
		return
	end

	if p == "Cancel" then
		clearStuck(instance) -- equivalent call inferred; original call site unknown
	else
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart == nil then
			return
		end

		if p == "Stick" then
			clearStuck(instance) -- equivalent call inferred; original call site unknown

			if typeof(model) ~= "Instance" or not model:IsA("Model") then
				return
			end

			local upperTorso = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso") or model:FindFirstChild("HumanoidRootPart")

			if upperTorso == nil then
				return
			end

			local blade = assets:FindFirstChild("Blade")

			if blade == nil then
				return
			end

			local clone = blade:Clone()
			clone.Name = `{instance.Name} TantoStuck`
			clone.Anchored = false
			clone.CanCollide = false
			clone.CanQuery = false
			clone.CanTouch = false
			clone.Massless = true
			local weld = clone:FindFirstChildWhichIsA("Weld")

			if weld == nil then
				return
			end

			weld.Part0 = upperTorso
			weld.Part1 = clone
			clone.Parent = workspace.Debree
			vfxUtility.EnableAll(clone, true, vfxUtility.Owned(instance))
			scheduleStuckFade(clone) -- equivalent call inferred; original call site unknown
		elseif p == "Throw" then
			local cFrame = humanoidRootPart.CFrame
			Cam_Shaker(cFrame.Position, "activate_shake")
			vfxUtility.PlaySound(script.Sounds, "PS2tantoTANTODESCENTthrow", humanoidRootPart, true)
			local raycastResult = workspace:Raycast(
				cFrame.Position + createVector(0, 5, 0),
				createVector(-0, -15, -0),
				RaycastHelper.Crater
			)
			local v3 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
			Ouwmit.Emit(
				vfxUtility.cloneAsset(assets, workspace.Debree, "TantoThrow", cFrame, 4),
				Ouwmit.Owned(instance, v3)
			)

			if not model then
				return
			end

			local part = (workspace.Debree:FindFirstChild("Projectiles") or workspace.Debree):WaitForChild(model, 1)

			if not (part and part:IsA("BasePart")) then
				return
			end

			local part2 = Instance.new("Part")
			part2.Name = `{instance.Name} TantoDescentCarrier`
			part2.Size = createVector(1, 1, 1)
			part2.Transparency = 1
			part2.CanCollide = false
			part2.CanQuery = false
			part2.CanTouch = false
			part2.Massless = true
			part2.Anchored = false
			part2.CFrame = part.CFrame
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = part
			weldConstraint.Part1 = part2
			weldConstraint.Parent = part2
			part2.Parent = workspace.Debree
			local tantoDuration = assets:FindFirstChild("TantoDuration")

			if tantoDuration then
				local clone = tantoDuration:Clone()
				clone:PivotTo(part2.CFrame)
				clone.Parent = part2

				for _, part3 in clone:GetDescendants() do
					if not part3:IsA("BasePart") then
						continue
					end

					part3.Anchored = false
					vfxUtility.WeldConstraint(part2, part3)
				end

				vfxUtility.EnableAll(clone, true, vfxUtility.Owned(instance))
			end

			local tantoTrail = assets:FindFirstChild("TantoTrail")

			if tantoTrail then
				local clone = tantoTrail:Clone()

				for _, child in clone:GetChildren() do
					child.Parent = part2
				end

				clone:Destroy()
			end

			local flag = false

			-- equivalent calls inferred from this helper; original call sites unknown
			local function release()
				if flag then
					return
				end

				flag = true

				if part2.Parent == nil then
					return
				end

				weldConstraint:Destroy()
				part2.Anchored = true
				part2.AssemblyLinearVelocity = createVector(0, 0, 0)
				vfxUtility.EnableAll(part2, false)
				DebrisModule:AddItem(part2, 2)
			end

			part.AncestryChanged:Connect(function(_, parent)
				if parent == nil then
					release() -- equivalent call inferred; original call site unknown
				end
			end)
			task.delay(3, release)
		else
			local v3 = v[p]

			if v3 == nil then
				return
			end

			local upperTorso = instance:FindFirstChild("UpperTorso") or instance:FindFirstChild("Torso")
			local position = upperTorso and upperTorso.Position or humanoidRootPart.Position
			local cframe

			if p == "Dash1" or p == "Dash2" or p == "Dash3" then
				if typeof(model) ~= "Vector3" then
					model = position + humanoidRootPart.CFrame.LookVector
				end

				cframe = CFrame.lookAt(position, (Vector3.new(model.X, position.Y, model.Z)))
				Cam_Shaker(cframe.Position, "Medium_tiny_shake_preset2")
			else
				cframe = CFrame.new(position) * humanoidRootPart.CFrame.Rotation

				if p == "Kick" then
					Cam_Shaker(cframe.Position, {
						FadeInTime = 0,
						Frequency = 0.15,
						Amplitude = 0.5,
						SustainTime = 0.15,
						FadeOutTime = 0.5,
						RotationInfluence = createVector(0.25, 0.25, 0.25),
						PositionInfluence = createVector(1, 1, 1)
					})
				elseif p == "Grab" then
					clearStuck(instance) -- equivalent call inferred; original call site unknown
					vfxUtility.PlaySound(script.Sounds, "PS2tantoTANTODESCENTconnect", humanoidRootPart, true)
				end
			end

			local v4 = v2[p]

			if v4 then
				vfxUtility.PlaySound(script.Sounds, v4, humanoidRootPart, true)
			end

			local raycastResult = workspace:Raycast(
				cframe.Position + createVector(0, 5, 0),
				createVector(-0, -15, -0),
				RaycastHelper.Crater
			)
			local v5 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
			Ouwmit.Emit(vfxUtility.cloneAsset(assets, workspace.Debree, v3, cframe, 4), Ouwmit.Owned(instance, v5))
		end
	end
end