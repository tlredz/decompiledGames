local createVector = vector.create
local Missiles = {}
local libraryNew = require(script.Parent.libraryNew)
local playAttachment = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local _ = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local dtwait = libraryNew.dtwait
local EFP = libraryNew.EFP
local _ = libraryNew.PlayMesh
local _ = libraryNew.Impact
local _ = libraryNew.GlassLight
local _ = libraryNew.RaiseZIndex
local able = libraryNew.Able
local _ = libraryNew.LifeScale
local quickFX = libraryNew.QuickFX
local _ = libraryNew.QuickWeld
local _ = libraryNew.Yield
local _ = libraryNew.ProcessPart
local _ = libraryNew.WeldObject
local _ = libraryNew.Bezier
local scriptvfx = script.scriptvfx
local class = {}
class.__index = class
Random.new()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local MoonEmitter = require(game.ReplicatedStorage.Resources.MoonEmitter)

local function countOtherMechs(char)
	local count = 0
	local live = workspace:FindFirstChild("Live")

	if not live then
		return 0
	end

	local children = live:GetChildren()

	for i = 1, #children do
		local v = children[i]

		if not (v ~= char and v:FindFirstChild("Mech") and v:FindFirstChild("missileusage")) then
			continue
		end

		count += 1
	end

	return count
end

local function countOtherMechsOnscreen(p)
	local count = 0
	local live = workspace:FindFirstChild("Live")

	if not live then
		return 0
	end

	local children = live:GetChildren()
	local onScreen = shared.OnScreen

	for i = 1, #children do
		local v = children[i]

		if not (v ~= p and v:FindFirstChild("Mech") and v.PrimaryPart and onScreen(v.PrimaryPart.Position)) then
			continue
		end

		if not v:FindFirstChild("missileusage") then
			continue
		end

		count += 1
	end

	return count
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PlaceVFX(instance, pivot)
	instance:PivotTo(pivot * instance:GetAttribute("Offset"):Inverse())
end

function Missiles.JumpEvent(p)
	local data = p.Data
	local char = data.Char
	local primaryPart = char.PrimaryPart

	if countOtherMechs(char) >= 2 then
		return
	end

	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, Clean)
	local v2 = {}
	data.bind.Destroying:Once(function()
		task.delay(1, Clean)

		for i = 1, #v2 do
			local folder = v2[i]
			able({
				FX = folder,
				On = false
			})
			local descendants = folder:GetDescendants()

			for i2 = 1, #descendants do
				local instance = descendants[i2]

				if instance:IsA("Beam") then
					instance.Enabled = false
				elseif instance:IsA("BasePart") and instance.Material == Enum.Material.Neon then
					TweenService:Create(instance, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
						Transparency = 1
					}):Play()
				end
			end
		end
	end)

	local function JumpEvent()
		local _ = primaryPart.MasterBone.Root.Waist
		local bind = data.bind
		local clone = scriptvfx:WaitForChild("missile MeshEmitter"):Clone()
		clone.Parent = workspace.Thrown
		local v3 = MoonEmitter.new(clone)
		v3:Play()
		v3:SetTime(1)
		game.Debris:AddItem(clone, 3)
		task.delay(0.2, function()
			if bind and bind.Parent then
				shared.vfx.emit(clone.Cframe3_Assembly.windmeshfollow)
			end
		end)
		local cframe = CFrame.new(-3, 4, 3)
		task.spawn(function()
			local lastTime = tick()
			local renderStepped = RunService.RenderStepped

			while tick() - lastTime < 2 and bind and bind.Parent do
				v3:SetAnchor(primaryPart.CFrame * cframe)
				renderStepped:Wait()
			end
		end)

		local function Boostersss()
			local v4 = object._maid:give(scriptvfx.boosters:Clone())
			v4.Parent = EFP
			local waist = primaryPart.MasterBone.Root.Waist
			local v5 = {
				["Foot.L"] = waist["UpperLeg.L"]["LowerLeg.L"]["Foot.L"],
				["Foot.R"] = waist["UpperLeg.R"]["LowerLeg.R"]["Foot.R"]
			}
			local children = scriptvfx.ats:GetChildren()

			for i = 1, #children do
				local v6 = children[i]
				local v7 = object._maid:give(v6:Clone())
				v7.Parent = v5[v7.Name]
				v7.Name = "Attachment"
			end

			local children2 = v4:GetChildren()
			local v6 = {}

			for i = 1, #children2 do
				local v7 = children2[i]
				local bone = v7:GetAttribute("Bone")

				if not v5[bone] then
					continue
				end

				v6[v7] = {
					Offset = v7:GetAttribute("Offset"),
					Bone = v5[bone],
					IsFoot = string.match(string.lower(v7.Name), "foot") ~= nil
				}
				v2[#v2 + 1] = v7
			end

			local cframe2 = CFrame.new(0, 0.13, 0)
			local _ = CFrame.identity
			task.spawn(function()
				local lastTime = tick()

				while tick() - lastTime < 4 do
					if not (bind and bind.Parent) then
						v4:Destroy()
						break
					end

					for k, v7 in pairs(v6) do
						local worldCFrame = v7.Bone.Attachment.WorldCFrame
						local inverse = v7.Offset:Inverse()

						if v7.IsFoot then
							k:PivotTo(worldCFrame * cframe2 * inverse)
						else
							k:PivotTo(worldCFrame * inverse)
						end
					end

					dtwait(0.01)
				end

				v4:Destroy()
			end)
			local upperTorso = primaryPart.MasterBone.Root.UpperTorso
			local v7 = {
				["LowerLeg.L"] = waist["UpperLeg.L"]["LowerLeg.L"],
				["LowerLeg.R"] = waist["UpperLeg.R"]["LowerLeg.R"],
				["Jetpack.Main"] = upperTorso["Jetpack.Main"]
			}
			local children3 = script.BoosterFolder:GetChildren()

			for i = 1, #children3 do
				local v8 = children3[i]
				local parent = v7[v8.Name]

				if not parent then
					continue
				end

				local v10 = object._maid:give(v8:Clone())
				v10.Parent = parent
				local children4 = v10:GetChildren()

				for i2 = 1, #children4 do
					local emitter = children4[i2]

					if emitter:IsA("ParticleEmitter") then
						emitter.LockedToPart = true
					end
				end

				v2[#v2 + 1] = v10
			end

			task.delay(2.4, function()
				if not (bind and bind.Parent) then
					return
				end

				for i = 1, #v2 do
					local folder = v2[i]
					able({
						FX = folder,
						On = false
					})
					local descendants = folder:GetDescendants()

					for i2 = 1, #descendants do
						local instance = descendants[i2]

						if instance:IsA("Beam") then
							instance.Enabled = false
						elseif instance:IsA("BasePart") and instance.Material == Enum.Material.Neon then
							TweenService:Create(instance, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
								Transparency = 1
							}):Play()
						end
					end
				end
			end)
		end

		Boostersss()

		if not (bind and bind.Parent) then
			return
		end

		local folder = quickFX({
			FX = scriptvfx.ez.Float,
			Maid = object._maid,
			Anchor = primaryPart.CFrame
		})
		local descendants = folder:GetDescendants()

		for i = 1, #descendants do
			local objectValue = descendants[i]

			if not objectValue:IsA("ObjectValue") then
				continue
			end

			local emitDuration = objectValue:GetAttribute("EmitDuration")

			if emitDuration then
				objectValue:SetAttribute("EmitDuration", emitDuration * 5)
			end
		end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Built }
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		local FX = object._maid:give(scriptvfx.GroundSmoke:Clone())
		FX.Parent = EFP
		able({
			FX = FX,
			On = false
		})
		local pointLight = FX.Part.PointLight
		pointLight.Range = 0
		task.delay(1, function()
			if not (bind and bind.Parent) then
				return
			end

			playAttachment(folder)
			libraryNew.MeshEmit.Emit(folder)
			able({
				FX = FX,
				On = true
			})
			TweenService:Create(pointLight, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				Range = 20
			}):Play()
		end)
		local v5 = object._maid:give(Instance.new("NumberValue"))
		v5.Value = 25
		TweenService:Create(v5, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
			Value = 0
		}):Play()
		local cframe2 = CFrame.new(0, 5, 0)
		local cframe3 = CFrame.new(0, 0, 4)
		task.spawn(function()
			local lastTime = tick()

			while tick() - lastTime < 2.4 do
				if bind and bind.Parent then
					local _, v6, _ = primaryPart.CFrame:ToOrientation()
					local raycastResult = workspace:Raycast(
						primaryPart.Position,
						createVector(0, -40, 0),
						raycastParams
					)

					if raycastResult then
						local cframe4 = CFrame.new(raycastResult.Position)
						folder:PivotTo(cframe4 * cframe2 * CFrame.Angles(0, v6, 0) * cframe3 * CFrame.Angles(
							math.rad(v5.Value),
							0,
							0
						))
						FX:PivotTo(cframe4)
					end

					dtwait(0.01)
				else
					able({
						FX = FX,
						On = false
					})
					TweenService:Create(pointLight, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
						Range = 0
					}):Play()
					break
				end
			end

			able({
				FX = FX,
				On = false
			})
			TweenService:Create(pointLight, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
				Range = 0
			}):Play()
			task.wait(4)
			Clean() -- equivalent call inferred; original call site unknown
		end)
		task.wait(0.03)

		if not (bind and bind.Parent) then
			return
		end

		local raycastResult = workspace:Raycast(primaryPart.Position, createVector(0, -40, 0), raycastParams)

		if raycastResult then
			if not (bind and bind.Parent) then
				return
			end

			playAttachment((quickFX({
				FX = scriptvfx.ez.Bounce,
				Maid = object._maid,
				Anchor = CFrame.new(raycastResult.Position) * CFrame.new(0, 7, 0)
			})))
			local folder2 = object._maid:give(scriptvfx.jUMP:Clone())
			local pivot = primaryPart:GetPivot()
			local descendants2 = folder2:GetDescendants()

			for i = 1, #descendants2 do
				local instance = descendants2[i]

				if not (instance:IsA("Model") or instance:IsA("BasePart")) then
					continue
				end

				PlaceVFX(instance, pivot) -- equivalent call inferred; original call site unknown
			end

			folder2.Parent = EFP
			shared.vfx.emit(folder2)
		end
	end

	task.spawn(JumpEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function Missiles.FirstEvent(p)
	local data = p.Data
	local char = data.Char
	local primaryPart = char.PrimaryPart

	if countOtherMechs(char) >= 2 then
		return
	end

	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v then
			v = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, Clean)

	local function FirstEvent()
		local bind = data.bind
		bind.Destroying:Once(Clean)
		local clone = scriptvfx:WaitForChild("NextEmitter"):Clone()
		clone.Parent = workspace.Thrown
		local v2 = MoonEmitter.new(clone)
		v2:Play()
		v2:SetTime(1.4)
		game.Debris:AddItem(clone, 3)
		local v3 = object._maid:give(Instance.new("CFrameValue"))
		v3.Value = CFrame.new(0, 0, 0)
		TweenService:Create(v3, TweenInfo.new(2, Enum.EasingStyle.Sine), {
			Value = CFrame.new(0, 0, -6)
		}):Play()
		local cframe = CFrame.new(-3, 4, 3)
		task.spawn(function()
			local lastTime = tick()
			local renderStepped = RunService.RenderStepped

			while tick() - lastTime < 2 do
				if bind and bind.Parent then
					v2:SetAnchor(primaryPart.CFrame * cframe * v3.Value)
					renderStepped:Wait()
				else
					if v2.Parent then
						v2:Destroy()
					end

					if clone.Parent then
						clone:Destroy()
					end

					if not v3.Parent then
						break
					end

					v3:Destroy()
					break
				end
			end
		end)
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return Missiles