local createVector = vector.create
local Robot4thM1 = {}
local MechCache = require(game.ReplicatedStorage.Resources.MechCache)
local libraryNew = require(script.Parent.libraryNew)
local playAttachment = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local _ = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local dtwait = libraryNew.dtwait
local _ = libraryNew.EFP
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
local vfx = script.vfx
require(game.ReplicatedStorage.Utility)
local class = {}
class.__index = class
Random.new()
game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
local Meshh = require(game.ReplicatedStorage.Resources.Meshh)

function Robot4thM1.FirstEvent(p)
	local data = p.Data
	local char = data.Char
	local primaryPart = char.PrimaryPart
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

	local mech = char.Mech
	task.delay(6, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	if data.HitMove then
		local part = data.Part
		vfx = script.vfx2
		local FX = quickFX({
			FX = vfx.Slash,
			Maid = object._maid,
			Anchor = primaryPart.CFrame * CFrame.new(0, -14, 0)
		})
		task.delay(5, function()
			if FX and FX.Parent then
				FX:Destroy()
			end
		end)
		local freeze = mech.Parent:FindFirstChild("Freeze")

		if not (mech.Parent:FindFirstChild("RootAnchor") or freeze and freeze:GetAttribute("MechStun")) then
			able({
				FX = FX,
				On = true
			})
		end

		local FX2 = quickFX({
			FX = vfx.JustMeshes,
			Maid = object._maid,
			Anchor = primaryPart.CFrame * CFrame.new(0, -14, 0) * CFrame.Angles(0, 1.5707963267948966, 0)
		})
		able({
			FX = FX2,
			On = true
		})
		task.delay(5, function()
			if FX2 and FX2.Parent then
				FX2:Destroy()
			end
		end)
		local _ = char.PrimaryPart
		tick()
		part.ChildAdded:Once(function()
			if not shared.OnScreen(part.Position) then
				return
			end

			local v4 = quickFX({
				FX = script.vfx2.My6thBetterTemp,
				Maid = object._maid,
				Anchor = primaryPart.CFrame * CFrame.new(0, -14, -20) * CFrame.Angles(-3.141592653589793, 0, 0)
			})
			task.delay(5, function()
				if v4 and v4.Parent then
					v4:Destroy()
				end
			end)
			v4:PivotTo(FX.PrimaryPart.CFrame * CFrame.new(0, 8, 0))
			playAttachment(v4);
			(function(_, p2)
				local _6th = v4["6th"]
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Built }
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				local raycastResult = workspace:Raycast(_6th.Position, createVector(0, -100, 0), raycastParams)

				if raycastResult then
					for _, emitter in pairs(p2 or _6th:GetDescendants()) do
						if not (emitter:IsA("ParticleEmitter") and tostring(emitter) == "Smoke" or tostring(emitter) == "AshForward") then
							continue
						end

						emitter.Color = ColorSequence.new(raycastResult.Instance.Color)
					end
				end
			end)()
			local v5 = quickFX({
				FX = vfx.ParticlesEmit,
				Maid = object._maid,
				Anchor = FX.PrimaryPart.CFrame * CFrame.new(0, 8, -5)
			})
			v5:ScaleTo(0.8)
			playAttachment(v5)
			able({
				FX = FX,
				On = false
			})
			able({
				FX = FX2,
				On = false
			})
		end)

		for _, folder in pairs({ FX, FX2 }) do
			folder.PrimaryPart.Anchored = false
			folder.PrimaryPart.Massless = true

			for _, part2 in pairs(folder:GetDescendants()) do
				if not part2:IsA("BasePart") then
					continue
				end

				part2.Anchored = false
				part2.CanCollide = false
				part2.Massless = true
			end

			local weld = Instance.new("Weld")
			weld.Parent = folder
			weld.Part0 = part
			weld.Part1 = folder.PrimaryPart
			weld.C0 = CFrame.new(0, 0, 9) * CFrame.Angles(-1.5707963267948966, 0, 0)
		end

		dtwait(0.6)
		able({
			FX = FX,
			On = false
		})
		able({
			FX = FX2,
			On = false
		})
	else
		if data.HitMove then
			return
		end

		local v2 = MechCache.Get(char)
		local _ = {
			Toe = v2.Toe,
			["Sole R"] = v2["Sole R"],
			["Sole L"] = v2["Sole L"],
			["Extra R"] = v2["Extra R"],
			["Extra L"] = v2["Extra L"],
			["LowerlegBackPropulsor L1"] = v2["LowerlegBackPropulsor L1"],
			["LowerlegBackPropulsor L2"] = v2["LowerlegBackPropulsor L2"],
			["LowerlegBackPropulsor R1"] = v2["LowerlegBackPropulsor R1"],
			["LowerlegBackPropulsor R2"] = v2["LowerlegBackPropulsor R2"]
		}
		local decrease = data.Decrease

		local function FirstEvent()
			local folder = nil
			local folder2 = nil
			spawn(function()
				dtwait(0.1)
				folder = MechCache.GetVFX(char, "Robot4thM1.Bone", script.vfx.Attachments.Bone, v2.Bone)
				folder2 = MechCache.GetVFX(
					char,
					"Robot4thM1.Bone034",
					script.vfx.Attachments["Bone.034"],
					v2["Bone.034"]
				)

				for _, emitter in pairs(folder2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter:Emit(emitter:GetAttribute("EmitCount"))
					emitter.Enabled = true
				end
			end)
			dtwait(0.31000000000000005)
			dtwait(0.15500000000000003)
			able({
				FX = folder2,
				On = false
			})
			local freeze = mech.Parent:FindFirstChild("Freeze")

			if mech.Parent:FindFirstChild("RootAnchor") or freeze and freeze:GetAttribute("MechStun") then
				return
			end

			for _, emitter in pairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			dtwait(0.07750000000000001)
			dtwait(0.5425)
			dtwait(0.096875)
			local freeze2 = mech.Parent:FindFirstChild("Freeze")

			if mech.Parent:FindFirstChild("RootAnchor") or freeze2 and freeze2:GetAttribute("MechStun") then
				return
			end

			if shared.OnScreen(primaryPart.Position) then
				local freeze3 = mech.Parent:FindFirstChild("Freeze")

				if mech.Parent:FindFirstChild("RootAnchor") or freeze3 and freeze3:GetAttribute("MechStun") then
					return
				end

				local v3 = object._maid:give(script.vfx.MN2:Clone())

				for _, child in pairs(v3:GetChildren()) do
					child:PivotTo(primaryPart.CFrame * CFrame.new(0, 0, 0) * child:GetAttribute("Offset"):Inverse())
					Meshh(child)
				end

				local folder3 = quickFX({
					FX = script.vfx.SlashFx,
					Maid = object._maid,
					Anchor = primaryPart.CFrame * script.vfx.SlashFx:GetAttribute("Offset"):Inverse()
				})

				for _, emitter in pairs(folder3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitCount") then
						emitter:Emit(emitter:GetAttribute("EmitCount") / (1.35 + decrease))
					end
				end

				dtwait(0.07750000000000001)
				dtwait(0.19375)
				local freeze4 = mech.Parent:FindFirstChild("Freeze")

				if mech.Parent:FindFirstChild("RootAnchor") or freeze4 and freeze4:GetAttribute("MechStun") then
					return
				end

				for _, emitter in pairs(folder2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v4 = emitter
					task.delay(0.485, function()
						if tostring(v4) == "Wave" then
							v4:Emit(v4:GetAttribute("EmitCount") / decrease)
						end
					end)
					emitter.Enabled = false
				end

				for _, descendant in pairs(folder:GetDescendants()) do
					if descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
						descendant.Enabled = false
					end
				end
			else
				for _, emitter in pairs(folder2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				return Clean()
			end
		end

		local function FirstEvent2()
			dtwait(0.19375)
			local freeze = mech.Parent:FindFirstChild("Freeze")

			if mech.Parent:FindFirstChild("RootAnchor") or freeze and freeze:GetAttribute("MechStun") then
				return
			end

			local vfx2 = script.vfx2
			local mechSlice = v2.MechSlice
			local mechStuff = vfx2.MechStuff
			local v3 = {}

			for _, child in pairs(mechStuff:GetChildren()) do
				if mechSlice[child.Name] then
					MechCache.GetVFXChildren(char, "Robot4thM1.MechStuff." .. child.Name, child, mechSlice[child.Name])

					if not v3[child.Name] then
						v3[child.Name] = mechSlice[child.Name]
					end
				else
					warn(child.Name .. " NOT FOUND")
				end
			end

			local TweenService = game:GetService("TweenService")
			local v4 = true
			task.delay(1.15, function()
				v4 = false
			end)

			for _, folder in pairs(v3) do
				for _, descendant in pairs(folder:GetDescendants()) do
					if descendant:IsA("Trail") then
						local v5 = descendant
						task.spawn(function()
							if v5:GetAttribute("EmitDelay") then
								task.wait(v5:GetAttribute("EmitDelay"))
							end

							if v5:GetAttribute("EmitDuration") then
								v5.Enabled = true
								task.wait(v5:GetAttribute("EmitDuration"))
								v5.Enabled = false
							end
						end)
					end

					if descendant:IsA("ParticleEmitter") and v4 then
						local v5 = descendant
						task.spawn(function()
							if v5:GetAttribute("EmitDelay") then
								task.wait(v5:GetAttribute("EmitDelay"))
							end

							if not v4 then
								return
							end

							v5:Emit(v5:GetAttribute("EmitCount"))

							if v5:GetAttribute("EmitDuration") then
								v5.Enabled = true
								task.wait(v5:GetAttribute("EmitDuration") / 1.8)
								v5.Enabled = false
							end
						end)
					end

					if descendant:IsA("Beam") then
						TweenService:Create(
							descendant,
							TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Brightness = 5
							}
						):Play()
						local v5 = descendant
						task.delay(0.7, function()
							TweenService:Create(
								v5,
								TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
								{
									Brightness = 0
								}
							):Play()
						end)
					end

					if not descendant:IsA("PointLight") then
						continue
					end

					descendant.Brightness = 5
					TweenService:Create(
						descendant,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Brightness = 1.5
						}
					):Play()
					local v5 = descendant
					task.delay(0.7, function()
						TweenService:Create(v5, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
							Brightness = 0
						}):Play()
					end)
				end
			end
		end

		task.spawn(FirstEvent)
		wait(10)
		Clean() -- equivalent call inferred; original call site unknown
	end
end

return Robot4thM1