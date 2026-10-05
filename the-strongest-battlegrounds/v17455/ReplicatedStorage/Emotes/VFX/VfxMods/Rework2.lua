local createVector = vector.create
local Rework2 = {}
local library = require(script.Parent.library)
local playAttachment = library.PlayAttachment
local maid = library.Maid
local _ = library.PlayTween
local _ = library.CamShake
local _ = library.PlayFlipBook
local dtwait = library.dtwait
local EFP = library.EFP
local _ = library.PlayMesh
local _ = library.Impact
local _ = library.GlassLight
local _ = library.RaiseZIndex
local _ = library.Able
local lifeScale = library.LifeScale
local quickFX = library.QuickFX
local _ = library.QuickWeld
local _ = library.Yield
local _ = library.ProcessPart
local _ = library.WeldObject
local _ = library.Bezier
local vfx = script.vfx
local class = {}
class.__index = class
local random = Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera
local RunService = game:GetService("RunService")

-- equivalent calls inferred from this helper; original call sites unknown
local function RaycastDown(p)
	local raycastResult = workspace:Raycast(p + createVector(0, 200, 0), createVector(0, -500, 0))

	if raycastResult then
		return raycastResult.Position.Y
	end

	return nil
end

function Rework2.FirstEvent(_)
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

	local function FirstEvent() end

	task.spawn(FirstEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

local function GenerateCubicPoints(cframe, p)
	local v = cframe.Position + Vector3.new(math.random(-0.1, 0.1), 0, math.random(-0.1, 0.1))
	local X = v.X
	local raycastDown = RaycastDown(v) -- equivalent call inferred; original call site unknown
	local vector2 = Vector3.new(X, raycastDown, v.Z)
	local orientation, v3, v4 = cframe:ToOrientation()
	local v5 = CFrame.new((Vector3.new(
		vector2.X + math.random(-12, 12),
		vector2.Y + random:NextNumber(-12, 12),
		vector2.Z + math.random(-12, 12)
	))) * CFrame.Angles(orientation, v3, v4) * CFrame.new(0, 0, -20).Position
	return
		vector2,
		v5,
		CFrame.new((Vector3.new(v5.X + math.random(-1, 1), v5.Y, v5.Z + math.random(-1, 1)))) * CFrame.Angles(
			orientation,
			v3,
			v4
		) * CFrame.new(0, 0, 40).Position,
		p
end

function cubicBezier(p, p2, p3, p4, p5)
	return (1 - p) ^ 3 * p2 + 3 * (1 - p) ^ 2 * p * p3 + 3 * (1 - p) * p ^ 2 * p4 + p ^ 3 * p5
end

function Rework2.BarrageEvent(p)
	local data = p.Data
	local char = data.Char
	local victim = data.Victim
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
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
	local Vfxmodule = require(game.ReplicatedStorage.Resources.Vfxmodule)

	local function BarrageEvent()
		local v2 = {
			"rbxassetid://80094963642636",
			"rbxassetid://77191568770956",
			"rbxassetid://131834225033644",
			"rbxassetid://96074836555221",
			"rbxassetid://130653565024280",
			"rbxassetid://117255163919608",
			"rbxassetid://90758989309618",
			"rbxassetid://140607388233648",
			"rbxassetid://133064565876159",
			"rbxassetid://97689513161208",
			"rbxassetid://74727979343799",
			"rbxassetid://86206635490637",
			"rbxassetid://85243741373505",
			"rbxassetid://132657985569475",
			"rbxassetid://95634520563353",
			"rbxassetid://77553159093769",
			"rbxassetid://118678487788583",
			"rbxassetid://140199460590695",
			"rbxassetid://126878148276558",
			"rbxassetid://88243407352278",
			"rbxassetid://89047892256469",
			"rbxassetid://91808589119171",
			"rbxassetid://84340146384458",
			"rbxassetid://113527243486045",
			"rbxassetid://89407445071636",
			"rbxassetid://89585202517260",
			"rbxassetid://118765909234791",
			"rbxassetid://96594009804683",
			"rbxassetid://105031383843109",
			"rbxassetid://83311423168054",
			"rbxassetid://132120241975221",
			"rbxassetid://76461066076084",
			"rbxassetid://112787615192584",
			"rbxassetid://100315427202524",
			"rbxassetid://109818030675534",
			"rbxassetid://122355126192622",
			"rbxassetid://91356719905547",
			"rbxassetid://137285920916197",
			"rbxassetid://92202015753019",
			"rbxassetid://131399161980219",
			"rbxassetid://135136687187468",
			"rbxassetid://116112256303651",
			"rbxassetid://133268356405971",
			"rbxassetid://93898145445736",
			"rbxassetid://72974831361931",
			"rbxassetid://74974088163922",
			"rbxassetid://84050002937523",
			"rbxassetid://114420538496140",
			"rbxassetid://73793823578413",
			"rbxassetid://95651548021098",
			"rbxassetid://139176284243401",
			"rbxassetid://89406871690932",
			"rbxassetid://85657882022356",
			"rbxassetid://124635101995775",
			"rbxassetid://136533001139571",
			"rbxassetid://80290863721668",
			"rbxassetid://83328973181320",
			"rbxassetid://134393613781673",
			"rbxassetid://87414506625753",
			"rbxassetid://122243525541300",
			"rbxassetid://133470877235705",
			"rbxassetid://117275333359949",
			"rbxassetid://123381830357499",
			"rbxassetid://104977788281495",
			"rbxassetid://127995633548231",
			"rbxassetid://124738728328642",
			"rbxassetid://75981423985567",
			"rbxassetid://91182287717473",
			"rbxassetid://107395808461741",
			"rbxassetid://89055422729833",
			"rbxassetid://109475564601190",
			"rbxassetid://98059650826528",
			"rbxassetid://86434460487978",
			"rbxassetid://125872151247664",
			"rbxassetid://94212830328880",
			"rbxassetid://83241209809465",
			"rbxassetid://128798307001952",
			"rbxassetid://127780550373414",
			"rbxassetid://117275690992236",
			"rbxassetid://113657699206730",
			"rbxassetid://117734185071687",
			"rbxassetid://127310383454496",
			"rbxassetid://83057762099284",
			"rbxassetid://111657605750257",
			"rbxassetid://79411719622289",
			"rbxassetid://93294935284581",
			"rbxassetid://99848775669913",
			"rbxassetid://70396436439056",
			"rbxassetid://85669558579559",
			"rbxassetid://128096215703595",
			"rbxassetid://84978451977469",
			"rbxassetid://96438688552146",
			"rbxassetid://116165000652831",
			"rbxassetid://108224899180004",
			"rbxassetid://83431768912251",
			"rbxassetid://124030876975837",
			"rbxassetid://95225318206089",
			"rbxassetid://118843178952981",
			"rbxassetid://95477612622720",
			"rbxassetid://84256023637653"
		}

		local function firstslash(_)
			local clone = vfx.firstslash:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(
				math.rad((random:NextNumber(-40, 40))),
				-1.0471975511965976,
				0.6981317007977318
			)
			clone.Parent = EFP
			TweenService:Create(
				clone,
				TweenInfo.new(1.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, false, 0),
				{
					CFrame = clone.CFrame * CFrame.Angles(0, 2.9670597283903604, 0)
				}
			)
			Vfxmodule.textureflipbook(clone.Decal, v2, 0.2)
			local vfxrotate = clone:FindFirstChild("Vfxrotate")
			local v4 = {
				CFrame = vfxrotate.CFrame * CFrame.Angles(0, 3.12413936106985, 0)
			}
			local tween = TweenService:Create(
				vfxrotate,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
				v4
			)
			tween:Play()
			tween.Completed:Connect(function()
				for _, emitter in vfxrotate:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
		end

		local function Slash(p2)
			local anchor = humanoidRootPart.CFrame * CFrame.new(0, 0, random:NextNumber(1, 2)) * CFrame.Angles(
				0,
				0,
				(math.rad((random:NextNumber(-90, 90))))
			)
			local FX

			if p2 then
				FX = quickFX({
					FX = vfx.Slash2,
					Maid = object._maid,
					Anchor = anchor
				})
			else
				FX = quickFX({
					FX = vfx.Slash,
					Maid = object._maid,
					Anchor = anchor
				})
			end

			local v5 = quickFX({
				FX = vfx.SlashBeam,
				Maid = object._maid,
				Anchor = anchor
			})
			game.Debris:AddItem(v5, 0.3)
			v5:ScaleTo(random:NextNumber(0.5, 1))
			FX:ScaleTo(random:NextNumber(0.5, 1))
			lifeScale({
				FX = FX,
				Scale = 0.2
			})
			local slash1 = FX.Model.Slash1
			local TweenService2 = game:GetService("TweenService")

			for _, effect in pairs(slash1:GetDescendants()) do
				local emitCount = effect:GetAttribute("EmitCount") or 0
				local emitDelay = effect:GetAttribute("EmitDelay") or 0
				local emitDuration = effect:GetAttribute("EmitDuration") or 0

				if effect:IsA("Beam") then
					local v6 = emitDuration
					local v7 = effect

					local function EnableBeams()
						if v6 > 0 then
							local clone = v7:Clone()
							clone.Parent = v5.Model.SP10.R.yoo
							clone.Enabled = true
							TweenService2:Create(
								clone,
								TweenInfo.new(
									0.08000000000000002,
									Enum.EasingStyle.Quad,
									Enum.EasingDirection.Out,
									0,
									false
								),
								{
									Width0 = 0,
									Width1 = 0
								}
							):Play()
							task.delay(0.2, function()
								clone:Destroy()
								FX:Destroy()
							end)
						end
					end

					if emitDelay == 0 then
						EnableBeams()
					else
						local EnableBeams2 = EnableBeams
						task.delay(emitDelay, function()
							EnableBeams2()
						end)
					end
				elseif effect:IsA("ParticleEmitter") then
					-- equivalent calls inferred from this helper; original call sites unknown
					local v6 = emitDuration
					local v7 = effect

					local function EnableFX()
						if v6 > 0 then
							v7.Enabled = true
							task.delay(v6, function()
								v7.Enabled = false
							end)
						end
					end

					if emitDelay == 0 then
						effect:Emit(emitCount)

						if emitDuration > 0 then
							effect.Enabled = true
							local v8 = effect
							task.delay(emitDuration, function()
								v8.Enabled = false
							end)
						end
					else
						local v8 = effect
						local v9 = emitCount
						local v10 = emitDuration
						task.delay(emitDelay, function()
							v8:Emit(v9)
							EnableFX() -- equivalent call inferred; original call site unknown
						end)
					end
				end
			end

			local attach0 = FX.Part.attach0
			local TweenService3 = game:GetService("TweenService")

			for _, effect in pairs(attach0:GetDescendants()) do
				local emitCount = effect:GetAttribute("EmitCount") or 0
				local emitDelay = effect:GetAttribute("EmitDelay") or 0
				local emitDuration = effect:GetAttribute("EmitDuration") or 0

				if effect:IsA("Beam") then
					local v6 = emitDuration
					local v7 = effect

					local function EnableBeams()
						if v6 > 4 then
							v7.Width1 = 10
							v7.Width0 = 10
							v7.Enabled = true
							TweenService3:Create(
								v7,
								TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false),
								{
									Width1 = 0,
									Width0 = 0
								}
							):Play()
							task.delay(1, function()
								v7.Enabled = false
							end)
						end
					end

					if emitDelay == 0 then
						EnableBeams()
					else
						local EnableBeams2 = EnableBeams
						task.delay(emitDelay, function()
							EnableBeams2()
						end)
					end
				elseif effect:IsA("ParticleEmitter") then
					-- equivalent calls inferred from this helper; original call sites unknown
					local v6 = emitDuration
					local v7 = effect

					local function EnableFX()
						if v6 > 0 then
							v7.Enabled = true
							task.delay(v6, function()
								v7.Enabled = false
							end)
						end
					end

					if emitDelay == 0 then
						effect:Emit(emitCount)

						if emitDuration > 0 then
							effect.Enabled = true
							local v8 = effect
							task.delay(emitDuration, function()
								v8.Enabled = false
							end)
						end
					else
						local v8 = effect
						local v9 = emitCount
						local v10 = emitDuration
						task.delay(emitDelay, function()
							v8:Emit(v9)
							EnableFX() -- equivalent call inferred; original call site unknown
						end)
					end
				end
			end
		end

		local v3 = object._maid:give(Instance.new("NumberValue"))
		v3.Value = 1
		TweenService:Create(v3, TweenInfo.new(2, Enum.EasingStyle.Sine), {
			Value = 0.5
		}):Play()
		local count = 0

		local function PunchShockwave()
			local clone = vfx.PunchShockwave:Clone()
			clone.Parent = workspace.Effects
			task.delay(1, function()
				clone:Destroy()
			end)
			local number = Random.new():NextNumber(3, -3)
			clone:SetPrimaryPartCFrame(CFrame.new(char.HumanoidRootPart.CFrame.Position + Vector3.new(
				Random.new():NextNumber(3, -3),
				Random.new():NextNumber(1, -1),
				Random.new():NextNumber(-3.5, -0.5)
			)) * CFrame.Angles(math.rad(number), math.rad(number), (math.rad(number))) * CFrame.new(0, 0, 0))
			clone:ScaleTo(0.8)
			TweenService:Create(clone.Start, TweenInfo.new(0.06, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Size = clone.End.Size,
				CFrame = clone.End.CFrame,
				Transparency = 1
			}):Play()
			task.delay(0.001, function()
				if math.random(1, 2) == 1 then
				end
			end)
			task.spawn(function()
				local shockwave = clone.Shockwave
				shockwave:SetPrimaryPartCFrame(shockwave.PrimaryPart.CFrame * CFrame.Angles(
					math.rad((math.random(0, 360))),
					0,
					0
				))
				local start = clone.Shockwave.Start
				local v4 = clone.Shockwave.End
				TweenService:Create(start, TweenInfo.new(0.045, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					CFrame = v4.CFrame
				}):Play()
				TweenService:Create(
					start.Mesh,
					TweenInfo.new(0.045, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						Scale = v4.Mesh.Scale
					}
				):Play()
				TweenService:Create(
					start.Decal,
					TweenInfo.new(0.045, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
			task.spawn(function()
				local shockwaveThin = clone.ShockwaveThin
				shockwaveThin:SetPrimaryPartCFrame(shockwaveThin.PrimaryPart.CFrame * CFrame.Angles(
					0,
					math.rad((math.random(0, 360))),
					0
				))
				local start = shockwaveThin.Start
				local v4 = shockwaveThin.End
				TweenService:Create(start, TweenInfo.new(0.06, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					CFrame = v4.CFrame
				}):Play()
				TweenService:Create(start.Mesh, TweenInfo.new(0.06, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Scale = v4.Mesh.Scale
				}):Play()
				TweenService:Create(
					start.Decal,
					TweenInfo.new(0.06, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
			playAttachment(clone)
			local clone2 = vfx.wallBarrage:Clone()
			clone2:PivotTo(humanoidRootPart.CFrame * CFrame.new(
				random:NextNumber(2.5, -2.5),
				random:NextNumber(2.5, -2.5),
				random:NextNumber(2.3, -2.3)
			))
			task.delay(6, function()
				clone2:Destroy()
			end)
			clone2.Parent = vfx
			lifeScale({
				FX = clone2,
				Scale = v3.Value
			})
		end

		local function throw(cframe, p2)
			local v4, v5, v6, v7 = GenerateCubicPoints(cframe, p2)
			local folder

			if count % 2 == 0 then
				folder = object._maid:give(vfx.trail1:Clone())
			else
				folder = object._maid:give(vfx.trail2:Clone())
			end

			folder:SetPrimaryPartCFrame(cframe)
			folder.Parent = EFP
			folder:ScaleTo(random:NextNumber(0.9, 1))
			lifeScale({
				FX = folder,
				Scale = 0.2
			})

			for _, trail in pairs(folder.trail1["1"]:GetChildren()) do
				if not trail:IsA("Trail") then
					continue
				end

				local _ = trail.Lifetime
				trail.Lifetime *= v3.Value
			end

			local v8 = nil
			local v9 = random:NextNumber(0.2, 0.15) * v3.Value
			local v10 = 0
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
				v10 = math.min(v10 + dt / v9, 1)
				local v11 = cubicBezier(v10, v4, v5, v6, v7)
				local v12 = cubicBezier(math.min(v10 + 0.1, 1), v4, v5, v6, v7)
				folder:SetPrimaryPartCFrame(CFrame.lookAt(v11, v12))

				if v10 >= 0.95 and not v8 then
					v8 = true
				end

				if v10 >= 1 then
					renderSteppedConnection:Disconnect()
				end
			end)
			object._maid:give(renderSteppedConnection)
			task.wait(v9)
			lifeScale({
				FX = folder,
				Scale = 1.5
			})
			dtwait(v9)

			for _, emitter in folder:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Destroy()
				end
			end
		end

		task.spawn(function()
			local lastTime = tick()
			local v4 = false

			while tick() - lastTime < 2.5 do
				count += 1

				for _ = 1, tick() - lastTime > 1.7 and 2 or 1 do
					task.spawn(function()
						throw(
							humanoidRootPart.CFrame * CFrame.new(0, 0, random:NextNumber(9, 15)) * CFrame.new(
								random:NextNumber(-30, 30),
								random:NextNumber(-30, 30),
								random:NextNumber(-30, 30)
							) * CFrame.new(
								random:NextNumber(-16, 16) * 1,
								random:NextNumber(-0.3, 0.3) * 1,
								random:NextNumber(15, 8) * 1
							),
							victim.HumanoidRootPart.CFrame * CFrame.new(
								random:NextNumber(-1, 1) * 1,
								random:NextNumber(-1, 1) * 1,
								random:NextNumber(0.1, 0.2) * 1
							).Position
						)
					end)
				end

				if count % 2 == 0 then
					v4 = not v4
				end

				dtwait(0.05 * v3.Value)
			end
		end)
	end

	task.spawn(BarrageEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return Rework2