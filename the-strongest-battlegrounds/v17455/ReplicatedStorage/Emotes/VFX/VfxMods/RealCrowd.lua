local RealCrowd = {}
local libraryNew = require(script.Parent.libraryNew)
local _ = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local _ = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local _ = libraryNew.dtwait
local EFP = libraryNew.EFP
local _ = libraryNew.PlayMesh
local _ = libraryNew.Impact
local _ = libraryNew.GlassLight
local _ = libraryNew.RaiseZIndex
local _ = libraryNew.Able
local _ = libraryNew.LifeScale
local quickFX = libraryNew.QuickFX
local _ = libraryNew.QuickWeld
local _ = libraryNew.Yield
local _ = libraryNew.ProcessPart
local _ = libraryNew.WeldObject
local _ = libraryNew.Bezier
local vfx2 = script.vfx2
local class = {}
class.__index = class
Random.new()
game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
local v = {
	"rbxassetid://73547558362204",
	"rbxassetid://73121403294583",
	"rbxassetid://72094469082505",
	"rbxassetid://136670889890763",
	"rbxassetid://89072505497688",
	"rbxassetid://131543263928211",
	"rbxassetid://89198501028549",
	"rbxassetid://76896548215817",
	"rbxassetid://91316859715273",
	"rbxassetid://88583130192629",
	"rbxassetid://70939813084762",
	"rbxassetid://106501838279836",
	"rbxassetid://99655989783939",
	"rbxassetid://74068493064559"
}
local v2 = {
	"rbxassetid://73547558362204",
	"rbxassetid://73121403294583",
	"rbxassetid://72094469082505",
	"rbxassetid://136670889890763",
	"rbxassetid://89072505497688",
	"rbxassetid://131543263928211",
	"rbxassetid://89198501028549",
	"rbxassetid://76896548215817",
	"rbxassetid://91316859715273",
	"rbxassetid://88583130192629",
	"rbxassetid://70939813084762",
	"rbxassetid://106501838279836",
	"rbxassetid://99655989783939",
	"rbxassetid://74068493064559"
}
local MoonEmitter = require(game.ReplicatedStorage.Resources.MoonEmitter)

function RealCrowd.FirstEvent(p)
	local data = p.Data
	local char = data.Char
	local hit = data.hit
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v3 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v3 then
			v3 = true
			object._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function FirstEvent()
		local function MrCoolbest()
			local v4 = char
			local v5 = nil
			task.delay(10, function()
				v5 = true
			end)
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = 0
			local clone = vfx2["Move MeshEmitter"]:Clone()
			game.Debris:AddItem(clone, 10)
			clone:PivotTo(v4.PrimaryPart.CFrame * clone:GetAttribute("Offset"):Inverse())
			local v6 = MoonEmitter.new(clone)
			v6:Play()
			task.delay(0.05, function()
				clone.Parent = game.Workspace.Thrown
			end)
			task.spawn(function()
				local clone2 = vfx2["Move MeshEmitter"]:Clone()
				game.Debris:AddItem(clone2, 12)
				clone2:PivotTo(v4.PrimaryPart.CFrame * clone2:GetAttribute("Offset"):Inverse())
				local v7 = MoonEmitter.new(clone2)
				v7:Play()
				local v8 = object._maid:give(Instance.new("Part"))
				v8.Anchored = true
				v8.Transparency = 1
				v8.CanCollide = false
				v8.Parent = game.Workspace
				v7:AssignExternal("R6", v8)
				v7:AddFrameEvent(function()
					local lastTime = tick()
					local cFrame = v8.CFrame

					while tick() - lastTime < 10 do
						numberValue.Value = (cFrame.Position - v8.Position).Magnitude
						v6:SetAnchor(v4.PrimaryPart.CFrame * clone2:GetAttribute("Offset"):Inverse() * CFrame.new(
							0,
							numberValue.Value,
							0
						))
						local RunService = game:GetService("RunService")
						RunService.RenderStepped:Wait()
					end
				end, 1)
			end)
			v6:AddFrameEvent(function()
				local impact1 = vfx2.Impact1
				local folder = quickFX({
					FX = impact1,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * impact1:GetAttribute("Offset"):Inverse()
				})

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end, 4)
			v6:AddFrameEvent(function()
				local smoke1Garou = vfx2.smoke1Garou
				local folder = quickFX({
					FX = smoke1Garou,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * smoke1Garou:GetAttribute("Offset"):Inverse()
				})

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end, 12)
			v6:AddFrameEvent(function()
				local impactWall = vfx2.ImpactWall
				local folder = quickFX({
					FX = impactWall,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * impactWall:GetAttribute("Offset"):Inverse()
				})

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end, 29)
			v6:AddFrameEvent(function()
				object.CharStuff = {}
				local v7 = object._maid:give(vfx2.Template:Clone())

				for _, child in pairs(v7:GetChildren()) do
					local child2 = char:FindFirstChild(child.Name)

					if not child2 then
						continue
					end

					object.CharStuff[child.Name] = {}

					for _, child3 in pairs(child:GetChildren()) do
						object._maid:give(child3)
						child3.Parent = child2
						table.insert(object.CharStuff[child.Name], child3)
					end
				end

				for _, v8 in pairs(object.CharStuff) do
					for _, emitter in pairs(v8) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end
				end
			end, 43)
			v6:AddFrameEvent(function()
				local superDash = vfx2.SuperDash
				local folder = quickFX({
					FX = superDash,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * superDash:GetAttribute("Offset"):Inverse()
				})

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				for _, v7 in pairs(object.CharStuff) do
					for _, attachment in pairs(v7) do
						if not attachment:IsA("Attachment") then
							continue
						end

						for _, trail in pairs(attachment:GetChildren()) do
							if trail:IsA("Trail") then
								trail.Enabled = true
							end
						end
					end
				end
			end, 50)
			v6:AddFrameEvent(function()
				for _, v7 in pairs(object.CharStuff) do
					for _, emitter in pairs(v7) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end
			end, 56)
			v6:AddFrameEvent(function()
				for _, v7 in pairs(object.CharStuff) do
					for _, attachment in pairs(v7) do
						if not attachment:IsA("Attachment") then
							continue
						end

						for _, trail in pairs(attachment:GetChildren()) do
							if trail:IsA("Trail") then
								trail.Enabled = false
							end
						end
					end
				end

				local impact2 = vfx2.Impact2
				local folder = quickFX({
					FX = impact2,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * impact2:GetAttribute("Offset"):Inverse()
				})

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				local impactWall2 = vfx2.ImpactWall2
				local folder2 = quickFX({
					FX = impactWall2,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * impactWall2:GetAttribute("Offset"):Inverse()
				})

				for _, emitter in pairs(folder2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end, 95)
			v6:AddFrameEvent(function()
				local impactWall3 = vfx2.ImpactWall3
				local folder = quickFX({
					FX = impactWall3,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * impactWall3:GetAttribute("Offset"):Inverse()
				})

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end, 109)
			v6:AddFrameEvent(function()
				local step = vfx2.Step
				local folder = quickFX({
					FX = step,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * step:GetAttribute("Offset"):Inverse()
				})

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end, 125)
			v6:AddFrameEvent(function()
				local step2 = vfx2.Step2
				local folder = quickFX({
					FX = step2,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * step2:GetAttribute("Offset"):Inverse()
				})

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end, 146)
			v6:AddFrameEvent(function()
				local step3 = vfx2.Step3
				local folder = quickFX({
					FX = step3,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * step3:GetAttribute("Offset"):Inverse()
				})

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end, 154)
			v6:AddFrameEvent(function()
				local step4 = vfx2.Step4
				local folder = quickFX({
					FX = step4,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * step4:GetAttribute("Offset"):Inverse()
				})

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end, 164)
			v6:AddFrameEvent(function()
				local grabVFX = vfx2.GrabVFX
				local folder = quickFX({
					FX = grabVFX,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * grabVFX:GetAttribute("Offset"):Inverse()
				})

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end, 172)
			v6:AddFrameEvent(function()
				local slamIMPACT = vfx2.SlamIMPACT
				local folder = quickFX({
					FX = slamIMPACT,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * slamIMPACT:GetAttribute("Offset"):Inverse()
				})

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				local hitmesh1 = v6.Model.Hitmesh1

				for _, texture in pairs(v2) do
					hitmesh1.Decal.Texture = texture
					task.wait(0.01)
				end

				object.Trail2 = object._maid:give(vfx2.Trail2:Clone())
				local weld = Instance.new("Weld")
				weld.Part0 = object.Trail2
				weld.Part1 = char["Right Arm"]
				weld.Parent = object.Trail2
				object.Trail2.Parent = EFP
				local trail2 = object.Trail2

				for _, trail in pairs(trail2:GetDescendants()) do
					if trail:IsA("Trail") then
						trail.Enabled = true
					end
				end
			end, 234)
			v6:AddFrameEvent(function()
				local slideFace = v6.Model.SlideFace

				for _, emitter in pairs(slideFace:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end, 237)
			v6:AddFrameEvent(function()
				local windDash = v6.Model.WindDash

				for _, beam in ipairs(windDash:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					local TweenService = game:GetService("TweenService")
					TweenService:Create(beam, TweenInfo.new(0.25), {
						Width0 = 3,
						Width1 = 8
					}):Play()
				end
			end, 246)
			v6:AddFrameEvent(function()
				local windDash = v6.Model.WindDash

				for _, beam in ipairs(windDash:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					local TweenService = game:GetService("TweenService")
					TweenService:Create(beam, TweenInfo.new(0.25), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end
			end, 276)
			v6:AddFrameEvent(function()
				local slideFace = v6.Model.SlideFace

				for _, emitter in pairs(slideFace:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end, 278)
			v6:AddFrameEvent(function()
				local swing = v6.Model.swing

				for _, emitter in pairs(swing:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end, 285)
			v6:AddFrameEvent(function()
				local trail2 = object.Trail2

				for _, trail in pairs(trail2:GetDescendants()) do
					if trail:IsA("Trail") then
						trail.Enabled = false
					end
				end
			end, 294)
			v6:AddFrameEvent(function()
				local swing = v6.Model.swing

				for _, emitter in pairs(swing:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				local throw = vfx2.Throw
				local folder = quickFX({
					FX = throw,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * throw:GetAttribute("Offset"):Inverse()
				})

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				object.VictimStuff = {}
				local v7 = object._maid:give(vfx2.VictimTemplate:Clone())

				for _, child in pairs(v7:GetChildren()) do
					local child2 = hit:FindFirstChild(child.Name)

					if not child2 then
						continue
					end

					object.VictimStuff[child.Name] = {}

					for _, child3 in pairs(child:GetChildren()) do
						object._maid:give(child3)
						child3.Parent = child2
						table.insert(object.VictimStuff[child.Name], child3)
					end
				end

				for _, v8 in pairs(object.VictimStuff) do
					for _, emitter in pairs(v8) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end
				end
			end, 310)
			v6:AddFrameEvent(function()
				local step5 = vfx2.Step5
				local folder = quickFX({
					FX = step5,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * step5:GetAttribute("Offset"):Inverse()
				})

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end, 342)
			v6:AddFrameEvent(function()
				for _, v7 in pairs(object.VictimStuff) do
					for _, folder in pairs(v7) do
						for _, emitter in pairs(folder:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					end
				end
			end, 410)
			v6:AddFrameEvent(function()
				local lastAura3 = vfx2.LastAura3
				local folder = quickFX({
					FX = lastAura3,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * lastAura3:GetAttribute("Offset"):Inverse()
				})

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				object.LastAura3 = folder

				for _, emitter in pairs(folder:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local TweenService = game:GetService("TweenService")
					TweenService:Create(emitter, TweenInfo.new(0.05), {
						TimeScale = 0
					}):Play()
				end

				local windCharge = vfx2.WindCharge
				local folder2 = quickFX({
					FX = windCharge,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * windCharge:GetAttribute("Offset"):Inverse()
				})

				for _, beam in pairs(folder2:GetDescendants()) do
					if beam:IsA("Beam") then
						beam.Enabled = true
					end
				end

				object.WindCharge = folder2

				for _, beam in pairs(folder2:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					local TweenService = game:GetService("TweenService")
					TweenService:Create(beam, TweenInfo.new(0.01), {
						TextureSpeed = 1
					}):Play()
				end

				task.wait(0.15)

				for _, beam in pairs(folder2:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					local TweenService = game:GetService("TweenService")
					TweenService:Create(beam, TweenInfo.new(0.8), {
						TextureSpeed = 10
					}):Play()
				end
			end, 412)
			v6:AddFrameEvent(function()
				local hitmesh2 = vfx2.Hitmesh2
				local mesh = quickFX({
					FX = hitmesh2,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * hitmesh2:GetAttribute("Offset"):Inverse()
				})
				object.mesh2 = mesh

				for _, texture in pairs(v) do
					mesh.Decal.Texture = texture
					task.wait(0.01)
				end
			end, 419)
			v6:AddFrameEvent(function()
				local hitmesh1 = v6.Model.Hitmesh1

				for _, texture in pairs(v2) do
					hitmesh1.Decal.Texture = texture
					task.wait(0.008)
				end
			end, 444)
			v6:AddFrameEvent(function()
				local mesh2 = object.mesh2

				for _, texture in pairs(v) do
					mesh2.Decal.Texture = texture
					task.wait(0.005)
				end
			end, 445)
			v6:AddFrameEvent(function()
				local lastAura3 = object.LastAura3

				for _, emitter in pairs(lastAura3:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local TweenService = game:GetService("TweenService")
					TweenService:Create(emitter, TweenInfo.new(1), {
						TimeScale = 1
					}):Play()
				end
			end, 447)
			v6:AddFrameEvent(function()
				local slide3 = v6.Model.Slide3

				for _, emitter in pairs(slide3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end, 449)
			v6:AddFrameEvent(function()
				local windCharge = object.WindCharge

				for _, beam in pairs(windCharge:GetDescendants()) do
					if beam:IsA("Beam") then
						beam.Enabled = false
					end
				end
			end, 453)
			v6:AddFrameEvent(function()
				local lastImpact = vfx2.LastImpact
				local folder = quickFX({
					FX = lastImpact,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * lastImpact:GetAttribute("Offset"):Inverse()
				})

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end, 454)
			v6:AddFrameEvent(function()
				local windDash2 = vfx2.WindDash2
				local folder = quickFX({
					FX = windDash2,
					Maid = object._maid,
					Anchor = humanoidRootPart.CFrame * windDash2:GetAttribute("Offset"):Inverse()
				})

				for _, beam in ipairs(folder:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					local TweenService = game:GetService("TweenService")
					TweenService:Create(beam, TweenInfo.new(0.1), {
						Width0 = 1,
						Width1 = 100
					}):Play()
				end

				for _, beam in ipairs(folder:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					local TweenService = game:GetService("TweenService")
					TweenService:Create(beam, TweenInfo.new(0.5), {
						Brightness = 1
					}):Play()
				end

				task.wait(0.2)

				for _, beam in ipairs(folder:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					local TweenService = game:GetService("TweenService")
					TweenService:Create(beam, TweenInfo.new(0.5), {
						Brightness = 0
					}):Play()
				end
			end, 456)
			v6:AddFrameEvent(function()
				local slide3 = v6.Model.Slide3

				for _, emitter in pairs(slide3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end, 485)
		end

		MrCoolbest()
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return RealCrowd