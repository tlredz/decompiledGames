local createVector = vector.create
local ConsecutiveOutside = {}
local libraryNew = require(script.Parent.libraryNew)
local _ = libraryNew.PlayAttachment
local maid = libraryNew.Maid
local _ = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local dtwait = libraryNew.dtwait
local EFP = libraryNew.EFP
local playMesh = libraryNew.PlayMesh
local _ = libraryNew.Impact
local _ = libraryNew.GlassLight
local _ = libraryNew.RaiseZIndex
local able = libraryNew.Able
local _ = libraryNew.LifeScale
local quickFX = libraryNew.QuickFX
local quickWeld = libraryNew.QuickWeld
local _ = libraryNew.Yield
local _ = libraryNew.ProcessPart
local _ = libraryNew.WeldObject
local _ = libraryNew.Bezier
local vfx = script.vfx
local class = {}
class.__index = class
Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
local MoonEmitter = require(game.ReplicatedStorage.Resources.MoonEmitter)

function ConsecutiveOutside.FirstEvent(p)
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

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	print(p)
	local char = p.char
	local hit = p.hit
	local primaryPart = char.PrimaryPart

	local function FirstEvent()
		local v2 = object._maid:give(vfx["Untitled WITH FX MeshEmitter"]:Clone())
		v2:PivotTo(primaryPart.CFrame * v2:GetAttribute("Offset"):Inverse())
		local v3 = MoonEmitter.new(v2)
		v3:Play()

		for _, child in pairs(v2["Consecutive Punches Finisher"].SMEARS:GetChildren()) do
			if math.random(1, 2) == 1 then
				child.Color = char["Right Arm"].Color
			else
				child.Color = char["Left Arm"].Color
			end
		end

		task.delay(0.05, function()
			v2.Parent = EFP
		end)
		local folder = object._maid:give(vfx.new:Clone())

		local function Reposition()
			for _, child in pairs(folder:GetChildren()) do
				child:PivotTo(primaryPart.CFrame * child:GetAttribute("Offset"):Inverse())
			end
		end

		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant.Name ~= "ColorArm" then
				continue
			end

			descendant.Color = char["Right Arm"].Color
			descendant.CFrame *= CFrame.new(0, 1000, 0)
		end

		Reposition()
		folder.Parent = EFP
		v3:AddFrameEvent(function()
			Reposition()
		end, 77)
		v3:AddFrameEvent(function()
			Reposition()
			shared.vfx.emit(folder.Barrage2)
			shared.vfx.emit(folder.Stage2)
		end, 111)
		v3:AddFrameEvent(function()
			Reposition()
			shared.vfx.emit(folder.Barrage3)
			shared.vfx.emit(folder.Stage3)
			shared.vfx.emit(folder.Blackline3)
		end, 153)
		v3:AddFrameEvent(function()
			Reposition()
			shared.vfx.emit(folder.EX)
		end, 246)
		local v4 = char

		local function RealSkill()
			local barrageFinisher = game.ReplicatedStorage.Resources.BarrageFinisher
			local clone = game.ReplicatedStorage.Resources["Consecutive Punches Finisher"].HandClones:Clone()
			clone.Parent = workspace.Thrown
			game.Debris:AddItem(clone, 10)
			local shirt = v4:FindFirstChildOfClass("Shirt")
			local children = {}
			task.spawn(function()
				local lastTime = tick()

				while tick() - lastTime < 3 do
					for _, v5 in pairs(children) do
						v5:SetPrimaryPartCFrame(v4.PrimaryPart.CFrame * v5:GetAttribute("Offset"))
					end

					local RunService = game:GetService("RunService")
					RunService.RenderStepped:Wait()
				end
			end)
			local v5 = {
				CLONE01 = 92432218846822,
				CLONE02 = 98163208515018,
				CLONE03 = 103865966061809,
				CLONE04 = 108530799554990,
				CLONE05 = 131081420344204
			}
			local v6 = {
				CLONE01 = 0.5,
				CLONE02 = 1,
				CLONE03 = 0.5,
				CLONE04 = 2.4,
				CLONE05 = 1
			}

			for _, child in pairs(clone:GetChildren()) do
				child:ScaleTo(1)
				child:SetPrimaryPartCFrame(v4.PrimaryPart.CFrame * child:GetAttribute("Offset"))
				table.insert(children, child)

				for _, child2 in pairs(child:GetChildren()) do
					local animator = child2
					local v7 = child
					task.delay(1, function()
						if animator.Name == "Humanoid" then
							local animation = Instance.new("Animation")
							animation.AnimationId = "rbxassetid://" .. v5[tostring(v7)]
							local track = animator:LoadAnimation(animation)
							track:Play()
							track.TimePosition = 1
						end
					end)

					if not (child2.Name == "Left Arm" or child2.Name == "Right Arm") then
						continue
					end

					if shirt then
						local clone_2 = shirt:Clone()
						clone_2.Parent = child2.Parent
					end

					child2.Transparency = 1

					if child2.Name == "Left Arm" then
						child2.Color = char["Left Arm"].Color
					else
						child2.Color = char["Right Arm"].Color
					end
				end
			end

			local v7 = {}
			local v8 = {
				[1] = function()
					for _, folder2 in pairs(clone:GetChildren()) do
						if not v6[folder2.Name] then
							continue
						end

						for _, descendant in pairs(folder2:GetDescendants()) do
							if descendant.Name == "Left Arm" or descendant.Name == "Right Arm" then
								descendant.Size = createVector(1, 2, 1) * v6[folder2.Name]
							end
						end
					end
				end,
				[10] = function()
					local clone2 = barrageFinisher.CamWind:Clone()
					clone2.Start.Transparency = 0
					clone2:ScaleTo(1.4)
					playMesh({
						Model = clone2,
						T = 0.8,
						Anchor = primaryPart.CFrame * clone2.Start:GetAttribute("Offset"),
						Info = TweenInfo.new(4, Enum.EasingStyle.Quint)
					})
					local FX = quickFX({
						FX = barrageFinisher.WINDFX,
						Maid = object._maid,
						Anchor = primaryPart.CFrame * barrageFinisher.WINDFX:GetAttribute("Offset")
					})
					able({
						FX = FX,
						On = true
					})
					dtwait(1)
					able({
						FX = FX,
						On = false
					})
				end,
				[16] = function()
					for _, folder2 in pairs(clone:GetChildren()) do
						for _, part in pairs(folder2:GetDescendants()) do
							if part:IsA("BasePart") and part.Name ~= "Torso" and part.Name ~= "HumanoidRootPart" then
								part.Transparency = 1
							end
						end
					end

					local CLONE01 = clone.CLONE01

					for _, part in pairs(CLONE01:GetDescendants()) do
						if part:IsA("BasePart") and part.Name ~= "Torso" and part.Name ~= "HumanoidRootPart" then
							TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
								Transparency = 0
							}):Play()
						end
					end
				end,
				[24] = function()
					local CLONE02 = clone.CLONE02

					for _, part in pairs(CLONE02:GetDescendants()) do
						if part:IsA("BasePart") and part.Name ~= "Torso" and part.Name ~= "HumanoidRootPart" then
							TweenService:Create(part, TweenInfo.new(0.383, Enum.EasingStyle.Linear), {
								Transparency = 0.2
							}):Play()
						end
					end
				end,
				[29] = function()
					local CLONE05 = clone.CLONE05

					for _, part in pairs(CLONE05:GetDescendants()) do
						if part:IsA("BasePart") and part.Name ~= "Torso" and part.Name ~= "HumanoidRootPart" then
							TweenService:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {
								Transparency = 0.4
							}):Play()
						end
					end
				end,
				[35] = function()
					local CLONE03 = clone.CLONE03

					for _, part in pairs(CLONE03:GetDescendants()) do
						if part:IsA("BasePart") and part.Name ~= "Torso" and part.Name ~= "HumanoidRootPart" then
							TweenService:Create(part, TweenInfo.new(0.267, Enum.EasingStyle.Linear), {
								Transparency = 0
							}):Play()
						end
					end

					local CLONE04 = clone.CLONE04

					for _, part in pairs(CLONE04:GetDescendants()) do
						if part:IsA("BasePart") and part.Name ~= "Torso" and part.Name ~= "HumanoidRootPart" then
							TweenService:Create(part, TweenInfo.new(0.367, Enum.EasingStyle.Linear), {
								Transparency = 0
							}):Play()
						end
					end
				end,
				[67] = function()
					for _, folder2 in pairs(clone:GetChildren()) do
						for _, descendant in pairs(folder2:GetDescendants()) do
							if descendant.Name == "Left Arm" or descendant.Name == "Right Arm" then
								descendant.Size = createVector(1, 2, 1)
							end
						end
					end

					local v9 = quickWeld({
						FX = barrageFinisher["Right Arm"],
						Maid = object._maid,
						P = char["Right Arm"]
					})
					v9.fullspeedwhite.Enabled = true
					v9.smears.Enabled = true
					local v10 = quickFX({
						FX = barrageFinisher.LIGHTBLOCK,
						Maid = object._maid,
						Anchor = primaryPart.CFrame * barrageFinisher.LIGHTBLOCK:GetAttribute("Offset")
					})
					v10.PointLight.Range = 8
					v10.PointLight2.Range = 0
					TweenService:Create(v10.PointLight2, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
						Brightness = 24,
						Range = 5
					}):Play()
					task.delay(0.2, function()
						TweenService:Create(v10.PointLight, TweenInfo.new(1.266, Enum.EasingStyle.Linear), {
							Brightness = 4,
							Color = Color3.fromRGB(255, 158, 122),
							Range = 14
						}):Play()
					end)
					dtwait(3)
					v9.fullspeedwhite.Enabled = false
					v9.smears.Enabled = false

					for _, light in pairs(v10:GetChildren()) do
						if light:IsA("PointLight") then
							TweenService:Create(light, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
								Brightness = 0
							}):Play()
						end
					end
				end,
				[81] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.009Real"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[83] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.009Real2"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[84] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.011Real"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[85] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.011Real2"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
					local v10 = quickFX({
						FX = barrageFinisher["llsmears.016Real"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v10.CFrame = primaryPart.CFrame * v10:GetAttribute("Offset")
					v10.Color = char["Right Arm"].Color
					game.Debris:AddItem(v10, 0.04)
				end,
				[86] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.016Real"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[87] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.017Real"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[88] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.017Real"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
					local v10 = quickFX({
						FX = barrageFinisher["llsmears.014Real"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v10.CFrame = primaryPart.CFrame * v10:GetAttribute("Offset")
					v10.Color = char["Right Arm"].Color
					game.Debris:AddItem(v10, 0.04)
					local v11 = quickFX({
						FX = barrageFinisher["llsmears.011Real3"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v11.CFrame = primaryPart.CFrame * v11:GetAttribute("Offset")
					v11.Color = char["Right Arm"].Color
					game.Debris:AddItem(v11, 0.04)
				end,
				[89] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.014Real"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
					local v10 = quickFX({
						FX = barrageFinisher["llsmears.011Real3"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v10.CFrame = primaryPart.CFrame * v10:GetAttribute("Offset")
					v10.Color = char["Right Arm"].Color
					game.Debris:AddItem(v10, 0.04)
				end,
				[93] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.012Real"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[97] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.011Real4"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[98] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.011Real5"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[101] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.011Real6"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[102] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.011Real6"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[107] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.011Real7"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[108] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.011Real7"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[109] = function()
					local folders = {}

					for _, child in pairs(barrageFinisher.Glows:GetChildren()) do
						local child2 = hit:FindFirstChild(child.Name)

						if not child2 then
							continue
						end

						local folder2 = object._maid:give(child:Clone())
						local weld = Instance.new("Weld")
						weld.Part0 = folder2
						weld.Part1 = child2
						weld.Parent = folder2
						folder2.Name = "uh"
						folder2.Parent = EFP

						for _, emitter in pairs(folder2:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							emitter.Rate = 4
							TweenService:Create(emitter, TweenInfo.new(0.584, Enum.EasingStyle.Sine), {
								Rate = 10
							}):Play()
							local v9 = emitter
							task.delay(1.1, function()
								TweenService:Create(v9, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
									Rate = 150
								}):Play()
							end)
						end

						table.insert(folders, folder2)
					end

					dtwait(1.6)

					for _, folder2 in pairs(folders) do
						for _, emitter in pairs(folder2:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							emitter.Enabled = false
							game.Debris:AddItem(emitter, 0.7)
						end
					end
				end,
				[111] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.013Real"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
					local v10 = quickFX({
						FX = barrageFinisher["llsmears.014Real2"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v10.CFrame = primaryPart.CFrame * v10:GetAttribute("Offset")
					v10.Color = char["Right Arm"].Color
					game.Debris:AddItem(v10, 0.04)
				end,
				[112] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.013Real"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[113] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.013Real"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[114] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.012Real2"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
					local v10 = quickFX({
						FX = barrageFinisher["llsmears.014Real3"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v10.CFrame = primaryPart.CFrame * v10:GetAttribute("Offset")
					v10.Color = char["Right Arm"].Color
					game.Debris:AddItem(v10, 0.04)
				end,
				[115] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.012Real2"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
					local v10 = quickFX({
						FX = barrageFinisher["llsmears.014Real4"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v10.CFrame = primaryPart.CFrame * v10:GetAttribute("Offset")
					v10.Color = char["Right Arm"].Color
					game.Debris:AddItem(v10, 0.04)
				end,
				[116] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.014Real4"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[117] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.015Real"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[118] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.014Real5"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[124] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.017Real2"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[125] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.017Real2"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
					local v10 = quickFX({
						FX = barrageFinisher["llsmears.014Real6"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v10.CFrame = primaryPart.CFrame * v10:GetAttribute("Offset")
					v10.Color = char["Right Arm"].Color
					game.Debris:AddItem(v10, 0.04)
				end,
				[126] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.014Real6"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[130] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.012Real3"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[141] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.011Real8"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[142] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.011Real8"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[148] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.013Real2"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
					local v10 = quickFX({
						FX = barrageFinisher["llsmears.014Real7"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v10.CFrame = primaryPart.CFrame * v10:GetAttribute("Offset")
					v10.Color = char["Right Arm"].Color
					game.Debris:AddItem(v10, 0.04)
				end,
				[149] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.013Real2"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[150] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.013Real2"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[151] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.009Real3"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[152] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.009Real3"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
					local v10 = quickFX({
						FX = barrageFinisher["llsmears.014Real8"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v10.CFrame = primaryPart.CFrame * v10:GetAttribute("Offset")
					v10.Color = char["Right Arm"].Color
					game.Debris:AddItem(v10, 0.04)
					local FX = quickWeld({
						FX = barrageFinisher.Glow,
						Maid = object._maid,
						P = hit.Torso
					})
					able({
						FX = FX,
						On = true
					})
					dtwait(1)
					able({
						FX = FX,
						On = false
					})
				end,
				[153] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.014Real9"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[155] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.014Real10"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[162] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.017Real3"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[163] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.017Real3"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
					local v10 = quickFX({
						FX = barrageFinisher["llsmears.014Real11"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v10.CFrame = primaryPart.CFrame * v10:GetAttribute("Offset")
					v10.Color = char["Right Arm"].Color
					game.Debris:AddItem(v10, 0.04)
				end,
				[164] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.014Real11"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[168] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.012Real4"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[188] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.013Real3"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[189] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.012Real5"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[190] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.012Real6"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
					local v10 = quickFX({
						FX = barrageFinisher["llsmears.014Real12"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v10.CFrame = primaryPart.CFrame * v10:GetAttribute("Offset")
					v10.Color = char["Right Arm"].Color
					game.Debris:AddItem(v10, 0.04)
				end,
				[191] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.014Real12"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[192] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.014Real13"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
				end,
				[193] = function()
					local v9 = quickFX({
						FX = barrageFinisher["llsmears.014Real14"],
						Maid = object._maid,
						Anchor = CFrame.new(10000, 1000, 10000)
					})
					v9.CFrame = primaryPart.CFrame * v9:GetAttribute("Offset")
					v9.Color = char["Right Arm"].Color
					game.Debris:AddItem(v9, 0.04)
					v2:Destroy()
				end
			}

			local function FrameTime()
				local total = 10
				local heartbeatConnection = nil
				local _ = workspace.CurrentCamera
				local untitledWITHFX = barrageFinisher["Untitled WITH FX"]
				tick()
				local _ = char.HumanoidRootPart
				game:GetService("TweenService")
				untitledWITHFX:FindFirstChild("FOV")
				local RunService = game:GetService("RunService")
				heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					local v9 = dt * 60
					total += v9

					if not (total < 241) then
						heartbeatConnection:Disconnect()
						return
					end

					for k, v10 in pairs(v8) do
						if not (k <= total) or v7[k] then
							continue
						end

						v7[k] = true
						v10()
					end
				end)
				task.delay(4, function()
					if heartbeatConnection then
						heartbeatConnection:Disconnect()
					end
				end)
			end

			FrameTime()
		end

		RealSkill()
	end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return ConsecutiveOutside