local createVector = vector.create
game:GetService("Players")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local debree = workspace.Debree
local assets = script:FindFirstChild("Assets")
local sounds = script:FindFirstChild("Sounds")
script:FindFirstChild("Rigs")
local CAM = ReplicatedStorage.CAM
local modules = CAM.Client.Modules
local DebrisModule = require(CAM.DebrisModule)
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
require(modules.Effects.Craters.CraterExtension)
local token = modules.Effects.Token
local TokenKit = require(token.TokenKit)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local _ = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include

local function PlaySlash(p, items, value)
	local v = value or 60
	task.spawn(function() end)
	task.spawn(function()
		for _, item in items do
			p.Decal.Texture = item
			task.wait(1 / v)
		end
	end)
end

local tweenInfo = TweenInfo.new(0.5)
return function(instance, p: string, _: boolean)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local upperTorso = instance:FindFirstChild("UpperTorso")

	if humanoidRootPart == nil or upperTorso == nil or not table.find({ "Cancel" }, p) and (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	local name = string.format("%s Obi_Charge_Effects", instance.Name)
	local ribbons = instance:FindFirstChild("Accessories") and instance:FindFirstChild("Accessories"):FindFirstChild("Ribbons")
	local parent = debree:FindFirstChild(name)

	if p == "Start" then
		if parent ~= nil then
			parent:Destroy()
		end

		parent = Instance.new("Folder")
		parent.Name = name
		parent.Parent = workspace.Debree
		DebrisModule:AddItem(parent, 12)
		parent:SetAttribute("Active", true)
		local clone = assets.SkillInitialFX:Clone()
		clone.Parent = parent
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -1, 0)
		vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 6)
		vfxUtility.PlaySound(sounds, "PS2FLESHMANIspinbombSTART", clone, true)
		task.delay(0.1, function()
			if not ribbons then
				return
			end

			local descendants = ribbons:GetDescendants()

			for _, bone in ipairs(descendants) do
				if not bone:IsA("Bone") then
					continue
				end

				local clone2 = assets.Thingies.ParticleEmitter:Clone()
				clone2.Parent = bone
				vfxUtility.EnableAll(clone2, true, vfxUtility.Owned(instance))
				DebrisModule:AddItem(clone2, 10)
			end

			parent.AttributeChanged:Wait()

			if not (ribbons and ribbons:IsDescendantOf(workspace)) then
				return
			end

			local clone2 = assets.Thingies.Highlight:Clone()
			clone2.Parent = ribbons
			task.wait(0.1)
			TweenService:Create(clone2, TweenInfo.new(1), {
				OutlineTransparency = 1
			}):Play()
			DebrisModule:AddItem(clone2, 1)
			local descendants2 = ribbons:GetDescendants()

			for _, emitter in ipairs(descendants2) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = false
				DebrisModule:AddItem(emitter, 1)
			end
		end)
		task.wait(0.35)

		if not parent:GetAttribute("Active") then
			return
		end

		local clone2 = assets.Jump:Clone()
		clone2.Parent = parent
		clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(-0.100616455078125, -2.5, 0.5013885498046875)
		vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone2, 6)
		local clone3 = assets.NewStuff.Jump:Clone()
		clone3.Parent = debree
		clone3:PivotTo(humanoidRootPart.CFrame)
		local clone4 = assets.NewStuff["Side Lines Screen FX"]:Clone()
		clone4.Parent = debree
		Ouwmit.Emit(clone4, Ouwmit.Owned(instance))
		DebrisModule:AddItem(clone4, 3)
		local cFrame = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v3 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Ouwmit.Emit(clone3, Ouwmit.Owned(instance, v3))
		DebrisModule:AddItem(clone3, 4)
		task.delay(1, function()
			if not parent:GetAttribute("Active") then
				return
			end

			vfxUtility.PlaySound(sounds, "PS2FLESHMANIspinbombBOOST", humanoidRootPart, true)
			local clone5 = assets.InitialSpin.locked:Clone()
			clone5.Parent = upperTorso
			vfxUtility.EmitAll(clone5, vfxUtility.Owned(instance))
			DebrisModule:AddItem(clone5, 1)
			local clone6 = assets.NewStuff.AirDash:Clone()
			clone6.Parent = debree
			clone6:PivotTo(humanoidRootPart.CFrame)
			local cFrame2 = humanoidRootPart.CFrame
			local raycastResult2 = workspace:Raycast(
				cFrame2.Position + createVector(0, 5, 0),
				createVector(-0, -15, -0),
				RaycastHelper.Crater
			)
			local v4 = raycastResult2 and vfxUtility.GetDustColorSettings(raycastResult2.Instance) or nil
			Ouwmit.Emit(clone6, Ouwmit.Owned(instance, v4))
			DebrisModule:AddItem(clone6, 4)
			task.wait(0.2)

			if not parent:GetAttribute("Active") then
				return
			end

			vfxUtility.PlaySound(sounds, "PS2FLESHMANIspinbombSPINSTART", humanoidRootPart, true)
			local clone7 = assets.Vfx:Clone()
			clone7.Parent = parent
			clone7:PivotTo(humanoidRootPart.CFrame)
			vfxUtility.EnableAll(clone7, true, vfxUtility.Owned(instance))
			local weld = Instance.new("Weld")
			weld.Part0 = humanoidRootPart
			weld.Part1 = clone7.PrimaryPart
			weld.Parent = humanoidRootPart
			DebrisModule:AddItem(clone7, 9)
			task.delay(1, function()
				if not ((clone7 or parent) and parent:GetAttribute("Active")) then
					return
				end

				local v5 = vfxUtility.PlaySound(sounds, "PS2FLESHMANIspinbombLOOP", humanoidRootPart, false)
				v5.Parent = clone7
				DebrisModule:AddItem(v5, 8)
				parent.AttributeChanged:Wait()
				DebrisModule:AddItem(v5, tweenInfo.Time)
				TweenService:Create(v5, tweenInfo, {
					Volume = 0
				}):Play()
			end)
		end)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.3,
			SustainTime = 0.1,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	elseif parent == nil then
		return
	end

	if p == "Hit" then
		local clone = assets.Hitfx:Clone()
		clone.Parent = parent
		clone.CFrame = humanoidRootPart.CFrame
		vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 3)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.05,
			Amplitude = 0.02,
			SustainTime = 0.1,
			FadeOutTime = 0.1,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		vfxUtility.PlaySound(sounds, "Punched5", humanoidRootPart, true)
	elseif p == "Charge" then
		local clone = assets.AmpedCharge:Clone()
		clone.Parent = parent
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2, 0)
		vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 3)
	elseif p == "Final" then
		if humanoidRootPart == nil or humanoidRootPart.Parent == nil or parent == nil or parent.Parent == nil then
			return
		end

		parent.Name = "_"
		parent:SetAttribute("Active", false)
		vfxUtility.EnableAll(parent, false)
		DebrisModule:AddItem(parent, 5)
		task.wait(0.5)
		local clone = assets.AmpedCharge:Clone()
		clone.Parent = parent
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2, 0)
		vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 3)
		local clone2 = assets.NewStuff.Chargeup:Clone()
		clone2.Parent = debree
		clone2:PivotTo(humanoidRootPart.CFrame)
		local clone3 = assets.NewStuff["Side Lines Screen FX"]:Clone()
		clone3.Parent = debree
		Ouwmit.Emit(clone3, Ouwmit.Owned(instance))
		DebrisModule:AddItem(clone3, 3)
		local cFrame = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v3 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Ouwmit.Emit(clone2, Ouwmit.Owned(instance, v3))
		DebrisModule:AddItem(clone2, 4)
		task.wait(0.2)

		if humanoidRootPart == nil or humanoidRootPart.Parent == nil or parent == nil or parent.Parent == nil then
			return
		end

		vfxUtility.EnableAll(ribbons, false)
		local clone4 = assets.Final:Clone()
		clone4.Parent = parent
		clone4.CFrame = humanoidRootPart.CFrame * CFrame.new(0.77081298828125, -2.596467018127441, 0)
		DebrisModule:AddItem(clone4, 6.5)
		local clone5 = assets.NewStuff.Explosion:Clone()
		clone5.Parent = debree
		clone5:PivotTo(humanoidRootPart.CFrame)
		local cFrame2 = humanoidRootPart.CFrame
		local raycastResult2 = workspace:Raycast(
			cFrame2.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v4 = raycastResult2 and vfxUtility.GetDustColorSettings(raycastResult2.Instance) or nil
		Ouwmit.Emit(clone5, Ouwmit.Owned(instance, v4))
		DebrisModule:AddItem(clone5, 4)
		local clone6 = assets.NewStuff["Dagger Slashes Transition"]:Clone()
		clone6.Parent = debree
		local v5 = {
			Owner = instance
		}

		if v4 ~= nil then
			for k, v6 in v4 do
				v5[k] = v6
			end
		end

		Ouwmit.Emit(clone6, Ouwmit.Owned(instance, v5))
		DebrisModule:AddItem(clone6, 3)
		vfxUtility.PlaySound(sounds, "PS2FLESHMANIspinbombEXPLODE", clone4, true)
		task.spawn(TokenKit.GroundRocks, {
			CF = clone4.CFrame,
			InnerRadius = 1,
			OuterRadius = 90,
			Velocity = {
				Min = 20,
				Max = 60
			},
			Size = {
				Min = 1,
				Max = 3
			}
		})
		Cam_Shaker(clone4.Position, {
			FadeInTime = 0,
			Frequency = 0.2,
			Amplitude = 0.7,
			SustainTime = 0.5,
			FadeOutTime = 0.8,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	elseif p == "Cancel" then
		vfxUtility.EnableAll(ribbons, false)
		local child = debree:FindFirstChild(name)

		if child then
			child.Name = "_"
			child:SetAttribute("Active", false)
			vfxUtility.EnableAll(child, false)
			DebrisModule:AddItem(child, 2)
		end
	end
end