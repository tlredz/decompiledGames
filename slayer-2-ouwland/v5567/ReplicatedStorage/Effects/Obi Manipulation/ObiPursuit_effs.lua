local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local debree = workspace.Debree
local assets = script:FindFirstChild("Assets")
local sounds = script:FindFirstChild("Sounds")
local CAM = ReplicatedStorage.CAM
local modules = CAM.Client.Modules
local DebrisModule = require(CAM.DebrisModule)
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local currentCamera = workspace.CurrentCamera
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include

function BlurEffect(value)
	local blurEffect = Instance.new("BlurEffect")
	local lighting = game.Lighting
	blurEffect.Size = 5
	blurEffect.Parent = lighting
	DebrisModule:AddItem(blurEffect, value or 0.08333333333333333)
end

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

local function PlayFlipbook(p, items, value)
	local v = value or 60
	task.spawn(function()
		for _, item in items do
			p.Image = item
			task.wait(1 / v)
		end
	end)
end

local tweenInfo = TweenInfo.new(0.25)
return function(instance, p: string, cframe)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or not table.find({ "Cancel", "Release" }, p) and (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	local name = string.format("%s Obi_Pursuit_Effects", instance.Name)
	local ribbons = instance:FindFirstChild("Accessories") and instance:FindFirstChild("Accessories"):FindFirstChild("Ribbons")
	local parent = debree:FindFirstChild(name)

	-- [DEDUP] synthesized from 2 duplicated terminal regions
	local function deduplicatedTail()
		local clone, clone2, cFrame, raycastResult, v3, child, hrp, dust

		if p == "Release" then
			child = workspace.Debree:FindFirstChild(name)

			if not child then
				return
			end

			child:SetAttribute("Active", false)
			hrp = child:FindFirstChild("Hrp")

			if hrp then
				vfxUtility.EnableAll(hrp, false)
				DebrisModule:AddItem(hrp, 1.5)
			end

			dust = child:FindFirstChild("Dust")

			if dust then
				vfxUtility.EnableAll(dust, false)
				DebrisModule:AddItem(dust, 1.5)
			end

			vfxUtility.EnableAll(ribbons, false)
		elseif p == "Slash" then
			vfxUtility.PlaySound(sounds, "PS2FleshManiFurtherSliceSLASH", humanoidRootPart, true)
			vfxUtility.EnableAll(ribbons, false)
			clone2 = assets.MewSlash:Clone()
			clone2.Parent = parent
			clone2:PivotTo(humanoidRootPart.CFrame)
			DebrisModule:AddItem(clone2, 3)
			cFrame = humanoidRootPart.CFrame
			raycastResult = workspace:Raycast(
				cFrame.Position + createVector(0, 5, 0),
				createVector(-0, -15, -0),
				RaycastHelper.Crater
			)
			v3 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
			Ouwmit.Emit(clone2, Ouwmit.Owned(instance, v3))
			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.06,
				SustainTime = 0.5,
				FadeOutTime = 0.2,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(1, 1, 1)
			})
		elseif p == "Hit" then
			vfxUtility.EnableAll(ribbons, false)
			clone = assets.Hitfx:Clone()
			clone.Parent = parent
			clone:PivotTo(cframe)
			vfxUtility.EmitAll(clone:GetDescendants(), vfxUtility.Owned(instance))
			DebrisModule:AddItem(clone, 2)
			Cam_Shaker(clone.Position, {
				FadeInTime = 0,
				Frequency = 0.05,
				Amplitude = 0.1,
				SustainTime = 0.1,
				FadeOutTime = 0.2,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(3.5, 3.5, 3.5)
			})
		elseif p == "Cancel" then
			vfxUtility.EnableAll(ribbons, false)

			if parent then
				parent.Name = "_"
				parent:SetAttribute("Active", false)
				vfxUtility.EnableAll(parent, false)
				DebrisModule:AddItem(parent, 2)
			end
		end
	end

	local _, _, _, _, _, _, _, _

	if p == "Start" then
		vfxUtility.PlaySound(sounds, "PS2FleshManiFurtherSliceSTART", humanoidRootPart, true)

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
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.02,
			SustainTime = 0.5,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(1, 1, 1)
		})
		task.wait(0.2)

		if not (parent:GetAttribute("Active") and parent:IsDescendantOf(workspace)) then
			return
		end

		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.06,
			SustainTime = 0.5,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(1, 1, 1)
		})
		local clone2 = assets.Dash:Clone()
		clone2.Parent = parent
		clone2:PivotTo(humanoidRootPart.CFrame)
		DebrisModule:AddItem(clone2, 3)
		local cFrame = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v3 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Ouwmit.Emit(clone2, Ouwmit.Owned(instance, v3))
		task.wait(0.1)

		if parent:GetAttribute("Active") then
			local workspace2 = workspace

			if parent:IsDescendantOf(workspace2) then
				vfxUtility.PlaySound(sounds, "PS2FleshManiFurtherSliceDARTDASH", clone2.HumanoidRootPart, true)

				if ribbons then
					local rootPart = ribbons.RootPart
					local wrapAR009 = rootPart:FindFirstChild("WrapA.R.009", true)
					local wrapAL009 = rootPart:FindFirstChild("WrapA.L.009", true)
					local clone3 = assets.Part.regLeft:Clone()
					clone3.Parent = wrapAR009
					DebrisModule:AddItem(clone3, 2)
					local clone4 = assets.Part.regRight:Clone()
					clone4.Parent = wrapAL009
					DebrisModule:AddItem(clone4, 2)
				end

				local clone3 = assets.Dust:Clone()
				clone3.Parent = parent
				clone3.CFrame = humanoidRootPart.CFrame * CFrame.new(
					2.35772705078125,
					-2.5828161239624023,
					2.021240234375
				)
				vfxUtility.EnableAll(clone3, true, vfxUtility.Owned(instance))
				DebrisModule:AddItem(clone3, 2)
				local v4 = vfxUtility.PlaySound(sounds, "PS2FleshManiFurtherSliceDRAGloop", humanoidRootPart, false)
				local attributeChangedConnection = nil
				attributeChangedConnection = parent.AttributeChanged:Connect(function(_: string)
					if parent:GetAttribute("Active") then
						return
					end

					attributeChangedConnection:Disconnect()
					TweenService:Create(v4, tweenInfo, {
						Volume = 0
					}):Play()
					DebrisModule:AddItem(v4, tweenInfo.Time)
				end)
				local weld = Instance.new("Weld")
				weld.Part0 = humanoidRootPart
				weld.Part1 = clone3
				weld.Parent = humanoidRootPart
				weld.C0 = CFrame.new(2.35772705078125, -2.5828161239624023, 2.021240234375)
				local clone4 = assets.Hrp:Clone()
				clone4.Parent = parent
				clone4.CFrame = humanoidRootPart.CFrame * CFrame.new(0.51, -1.39, 4.63)
				vfxUtility.EnableAll(clone4, true, vfxUtility.Owned(instance))
				DebrisModule:AddItem(clone4, 2)
				local weld2 = Instance.new("Weld")
				weld2.Part0 = humanoidRootPart
				weld2.Part1 = clone4
				weld2.Parent = humanoidRootPart
				weld2.C0 = CFrame.new(0.51, -1.39, 4.63)
				task.delay(0.5, function()
					vfxUtility.EnableAll(clone4, false)
				end)
				return deduplicatedTail()
			end
		end
	else
		if parent == nil then
			return
		end

		return deduplicatedTail()
	end
end