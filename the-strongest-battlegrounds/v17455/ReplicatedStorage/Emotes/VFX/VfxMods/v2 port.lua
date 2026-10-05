local createVector = vector.create
local V2Port = {}
local library = require(game.ReplicatedStorage.library)
local playAttachment = library.PlayAttachment
local maid = library.Maid
local playTween = library.PlayTween
local dtwait = library.dtwait
local EFP = library.EFP
local playMesh = library.PlayMesh
local able = library.Able
local lifeScale = library.LifeScale
local quickFX = library.QuickFX
local vfx = script:WaitForChild("vfx")
local class = {}
class.__index = class
local HttpService = game:GetService("HttpService")
local random = Random.new()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local renderStepped = RunService.RenderStepped
local heartbeat = RunService.Heartbeat
local camera = game.Workspace.Camera
local TweenSequence = require(script.TweenSequence)
local FrameMarker = require(game.ReplicatedStorage.Resources.FrameMarker)
local MoonEmitter = require(game.ReplicatedStorage.Resources.MoonEmitter)
local object = setmetatable({}, {
	__index = function(offsetsByInstance, instance)
		local offset = instance:GetAttribute("Offset")
		offsetsByInstance[instance] = offset
		return offset
	end
})
local object2 = setmetatable({}, {
	__index = function(inverses, p)
		local inverse = object[p]:Inverse()
		inverses[p] = inverse
		return inverse
	end
})
local exploig = vfx.exploig
local burn = vfx.Burn
local v = CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(0, 0.1, 0)
local color = Color3.fromRGB(2129, 152, 50)
local color2 = Color3.new(0, 0, 0)
local v2 = {
	122733844687581,
	119401203271516,
	105234991826061,
	74539653497570,
	75038578500638,
	106893765840612,
	127419942476165,
	80607808820628,
	131082833396756,
	128840341828365,
	90083498712583,
	121949681263938,
	100454198072264
}

local function PreloadGammaSfx()
	local v3 = {}

	for _, v4 in pairs(v2) do
		v3[#v3 + 1] = v4
	end

	v3[#v3 + 1] = 86645208465330
	v3[#v3 + 1] = 138337274369584
	local v4 = {}

	for _, v5 in pairs(v3) do
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://" .. v5
		sound.Volume = 0
		sound.Parent = game:GetService("SoundService")
		Debris:AddItem(sound, 20)
		v4[#v4 + 1] = sound
	end

	pcall(function()
		local ContentProvider = game:GetService("ContentProvider")
		ContentProvider:PreloadAsync(v4)
	end)
end

local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine)
local tweenInfo2 = TweenInfo.new(4, Enum.EasingStyle.Sine)
local cframe = CFrame.Angles(1.5707963267948966, 0, 0)
CFrame.Angles(0, 0, 1.5707963267948966)
local cframe2 = CFrame.Angles(0, 1.5707963267948966, 0)
local cframe3 = CFrame.Angles(1.5707963267948966, -0.3342305517569141, 0)
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(99, 82, 152)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(52, 143, 255))
})
local numberSequence = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0) })
local v3 = {
	Outer2 = 3,
	Outer4 = 2,
	Outer3 = 1.5
}
local v4 = {
	"rbxassetid://139316595488096",
	"rbxassetid://139982099777570",
	"rbxassetid://81035705106619",
	"rbxassetid://139860210570092",
	"rbxassetid://97394582427486",
	"rbxassetid://113848683503773",
	"rbxassetid://132789816984453",
	"rbxassetid://113336883203413",
	"rbxassetid://111566065250697",
	"rbxassetid://140577834509817",
	"rbxassetid://105667437960054",
	"rbxassetid://108656052359237",
	"rbxassetid://125297074191432",
	"rbxassetid://135630569407247",
	"rbxassetid://110504886316813",
	"rbxassetid://131565021914714",
	"rbxassetid://131565021914714",
	"rbxassetid://110043295702515",
	"rbxassetid://140032445764194",
	"rbxassetid://101781610590220",
	"rbxassetid://92682416984264",
	"rbxassetid://120524858831063",
	"rbxassetid://76823771384784",
	"rbxassetid://83866159290901",
	"rbxassetid://108595877272258",
	"rbxassetid://80688898015388",
	"rbxassetid://125715123311689",
	"rbxassetid://98780442138924",
	"rbxassetid://76613368918180",
	"rbxassetid://87439210134406",
	"rbxassetid://72646384709386",
	"rbxassetid://77764989864880",
	"rbxassetid://118088497675725",
	"rbxassetid://92273018967298",
	"rbxassetid://117924002502163",
	"rbxassetid://101623865782215",
	"rbxassetid://114852337166803",
	"rbxassetid://125255014602647",
	"rbxassetid://129980751311031",
	"rbxassetid://105700991935708",
	"rbxassetid://120690339315321",
	"rbxassetid://98097370882456",
	"rbxassetid://73733410979989",
	"rbxassetid://105697588081709",
	"rbxassetid://128315863764015",
	"rbxassetid://94353247428135",
	"rbxassetid://74580357201366",
	"rbxassetid://131641602463699",
	"rbxassetid://108065051280526",
	"rbxassetid://74558543296051",
	"rbxassetid://120033826888107",
	"rbxassetid://140565298950697",
	"rbxassetid://91850802837190",
	"rbxassetid://139962477737871",
	"rbxassetid://122429010702212",
	"rbxassetid://79145095808567",
	"rbxassetid://78651901470426",
	"rbxassetid://122798928858158",
	"rbxassetid://108983696217760",
	"rbxassetid://101921321747986",
	"rbxassetid://87925260719870",
	"rbxassetid://96864084967237",
	"rbxassetid://104341309720827",
	"rbxassetid://86433681715209",
	"rbxassetid://134303168330551",
	"rbxassetid://89427092866839"
}
local v5 = {
	"https://assetgame.roblox.com/asset/?id=139162279786523&assetName=0011 %281%29",
	"https://assetgame.roblox.com/asset/?id=99850399400414&assetName=0012 %281%29",
	"https://assetgame.roblox.com/asset/?id=137571101456637&assetName=0013 %281%29",
	"https://assetgame.roblox.com/asset/?id=108605337651494&assetName=0014 %281%29",
	"https://assetgame.roblox.com/asset/?id=97294867253288&assetName=0015 %281%29",
	"https://assetgame.roblox.com/asset/?id=134233926395828&assetName=0016 %281%29",
	"https://assetgame.roblox.com/asset/?id=87851838572617&assetName=0017 %281%29",
	"https://assetgame.roblox.com/asset/?id=115953576098871&assetName=0018 %281%29",
	"https://assetgame.roblox.com/asset/?id=116199241115838&assetName=0019 %281%29",
	"https://assetgame.roblox.com/asset/?id=95694860854384&assetName=0020 %281%29",
	"https://assetgame.roblox.com/asset/?id=73137991011198&assetName=0021 %281%29",
	"https://assetgame.roblox.com/asset/?id=81643078662417&assetName=0022 %281%29",
	"https://assetgame.roblox.com/asset/?id=80996928742800&assetName=0023 %281%29",
	"https://assetgame.roblox.com/asset/?id=98376628741986&assetName=0024 %281%29",
	"https://assetgame.roblox.com/asset/?id=137835431642243&assetName=0025 %281%29",
	"https://assetgame.roblox.com/asset/?id=110252124120783&assetName=0026 %281%29",
	"https://assetgame.roblox.com/asset/?id=99731409221936&assetName=0027 %281%29",
	"https://assetgame.roblox.com/asset/?id=138569587129869&assetName=0028 %281%29",
	"https://assetgame.roblox.com/asset/?id=120442197747109&assetName=0029 %281%29",
	"https://assetgame.roblox.com/asset/?id=110052475109692&assetName=0030 %281%29",
	"https://assetgame.roblox.com/asset/?id=139070004115934&assetName=0031 %281%29",
	"https://assetgame.roblox.com/asset/?id=91038215552778&assetName=0032 %281%29",
	"https://assetgame.roblox.com/asset/?id=87155954086133&assetName=0033 %281%29",
	"https://assetgame.roblox.com/asset/?id=77311449651934&assetName=0034 %281%29",
	"https://assetgame.roblox.com/asset/?id=76823117997450&assetName=0035 %281%29",
	"https://assetgame.roblox.com/asset/?id=123884734273967&assetName=0036",
	"https://assetgame.roblox.com/asset/?id=98555243319684&assetName=0037",
	"https://assetgame.roblox.com/asset/?id=134268362461884&assetName=0038",
	"https://assetgame.roblox.com/asset/?id=97851542065868&assetName=0039",
	"https://assetgame.roblox.com/asset/?id=97537771792355&assetName=0040",
	"https://assetgame.roblox.com/asset/?id=90091712346144&assetName=0041",
	"https://assetgame.roblox.com/asset/?id=112060506773005&assetName=0042",
	"https://assetgame.roblox.com/asset/?id=117498503692396&assetName=0043",
	"https://assetgame.roblox.com/asset/?id=123479384631135&assetName=0044",
	"https://assetgame.roblox.com/asset/?id=99644133044265&assetName=0045",
	"https://assetgame.roblox.com/asset/?id=74263574233062&assetName=0046",
	"https://assetgame.roblox.com/asset/?id=120621176767746&assetName=0047",
	"https://assetgame.roblox.com/asset/?id=102174574722945&assetName=0048",
	"https://assetgame.roblox.com/asset/?id=75688864271891&assetName=0049",
	"https://assetgame.roblox.com/asset/?id=73916742897834&assetName=0050",
	"https://assetgame.roblox.com/asset/?id=112357700674630&assetName=0051",
	"https://assetgame.roblox.com/asset/?id=96482647134517&assetName=0052",
	"https://assetgame.roblox.com/asset/?id=107142167745809&assetName=0053",
	"https://assetgame.roblox.com/asset/?id=75833917496513&assetName=0054",
	"https://assetgame.roblox.com/asset/?id=114111062169850&assetName=0055"
}
local _ = {
	"https://assetgame.roblox.com/asset/?id=133449036626981&assetName=0088",
	"https://assetgame.roblox.com/asset/?id=95234096655778&assetName=0089",
	"https://assetgame.roblox.com/asset/?id=125036527145601&assetName=0090",
	"https://assetgame.roblox.com/asset/?id=98277003178215&assetName=0091",
	"https://assetgame.roblox.com/asset/?id=77413908777664&assetName=0092",
	"https://assetgame.roblox.com/asset/?id=100366961229038&assetName=0093",
	"https://assetgame.roblox.com/asset/?id=104077613266631&assetName=0094",
	"https://assetgame.roblox.com/asset/?id=91486449108026&assetName=0095",
	"https://assetgame.roblox.com/asset/?id=129894529688199&assetName=0096",
	"https://assetgame.roblox.com/asset/?id=117715870042634&assetName=0097 %281%29"
}

local function textureflipbookLoop(instance, list, p: number)
	if not (instance and (instance:IsA("Decal") or instance:IsA("Beam") or instance:IsA("ParticleEmitter"))) then
		return
	end

	if type(list) ~= "table" or #list == 0 or p <= 0 then
		return
	end

	local count = #list
	local v6 = count / p
	local v7 = {
		_running = true,
		Stop = function(p2)
			p2._running = false
		end
	}
	task.spawn(function()
		local v8 = 0
		local v9 = 1

		while v7._running do
			v8 += heartbeat:Wait()
			local v10 = math.floor(v8 * v6)

			if not (v10 > 0) then
				continue
			end

			v9 += v10
			v8 -= v10 / v6

			if count < v9 then
				v9 = (v9 - 1) % count + 1
			end

			instance.Texture = list[v9]
		end
	end)
	return v7
end

local function textureflipbook(beam, list, p: number)
	if not (beam and (beam:IsA("Decal") or beam:IsA("Beam") or beam:IsA("ParticleEmitter"))) then
		return
	end

	if type(list) ~= "table" or #list == 0 or p <= 0 then
		return
	end

	local lastTime = os.clock()
	local count = #list
	local v6 = p / count
	local v7 = nil
	task.spawn(function()
		while true do
			local v8 = os.clock() - lastTime

			if p <= v8 then
				break
			end

			local v9 = math.floor(v8 / v6) + 1

			if v9 ~= v7 then
				v7 = v9
				beam.Texture = list[v9]
			end

			task.wait(0.01)
		end

		beam.Texture = list[count]
	end)
end

local function beamcrescent2(folder, _: CFrame, duration: number, p: number, p2: number)
	local descendants = folder:GetDescendants()
	local tweenInfo3 = TweenInfo.new(duration, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)

	for _, instance in descendants do
		if instance:IsA("Beam") then
			TweenService:Create(instance, tweenInfo3, {
				Width0 = instance.Width0 * p,
				Width1 = instance.Width1 * p,
				CurveSize0 = instance.CurveSize0 * p,
				CurveSize1 = instance.CurveSize1 * p
			}):Play()
		elseif instance:IsA("Attachment") then
			TweenService:Create(instance, tweenInfo3, {
				CFrame = CFrame.new(instance.CFrame.Position * p)
			}):Play()
		end
	end

	TweenService:Create(folder, tweenInfo3, {
		CFrame = folder.CFrame * CFrame.Angles(0, math.rad(p2), 0)
	}):Play()
	Debris:AddItem(folder, 5)
end

local function randomUnitVector()
	local v6, v7, v8, v9

	repeat
		v6 = random:NextNumber(-1, 1)
		v7 = random:NextNumber(-1, 1)
		v8 = random:NextNumber(-1, 1)
		v9 = v6 * v6 + v7 * v7 + v8 * v8
	until v9 > 0.0001

	local v10 = math.sqrt(v9)
	return (Vector3.new(v6 / v10, v7 / v10, v8 / v10))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateScale(instance, p)
	instance:ScaleTo((math.clamp(p.Transform.Position.y / 2 + 1, 0.0001, 100)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateTransparncy(p, p2)
	p.Transparency = math.clamp(p2.Transform.Position.y / 2, 0.02, 1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function MeshRenderPrioty(p, instance, p2, position)
	local v6 = (position - instance.Position).Unit * p2
	p.Offset = instance.CFrame:VectorToObjectSpace(v6)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function turnOnParticle(instance)
	for _, emitter in ipairs(instance:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function turnOffParticle(instance)
	for _, emitter in ipairs(instance:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end
end

function V2Port.FirstEvent(p)
	local object3 = setmetatable({}, class)
	object3._maid = maid.new()
	local _maid = object3._maid
	local v6 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v6 then
			v6 = true
			_maid:doCleaning()
		end
	end

	local data = p.Data
	local bind = data.bind

	if not bind then
		return
	end

	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local v7 = _maid:give(Instance.new("Part"))
	v7.CFrame = humanoidRootPart.CFrame
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { game.Workspace.Map }
	local raycastResult = game.Workspace:Raycast(humanoidRootPart.Position, createVector(0, -50, 0), raycastParams)

	if raycastResult then
		v7.CFrame = CFrame.new(raycastResult.Position + createVector(0, 5.3, 0))
	end

	v7.CanCollide = false
	v7.Anchored = true
	v7.Transparency = 1
	v7.Parent = EFP

	local function FirstEvent()
		task.spawn(PreloadGammaSfx)

		local function og()
			local v8 = _maid:give(vfx["GammaRayBurst MeshEmitter"]:Clone())
			v8:PivotTo(humanoidRootPart.CFrame * object2[v8])
			local v9 = MoonEmitter.new(v8)
			v9:Play()
			object3.modelgroup = v9.Model
			task.delay(0.075, function()
				v8.Parent = EFP
			end)
			return FrameMarker.new({
				Framerate = 60
			}):Chain({
				[40] = function() end,
				[63] = function()
					local v10 = quickFX({
						FX = vfx.WIndStart,
						Maid = object3._maid,
						Anchor = CFrame.new((Vector3.new(
							humanoidRootPart.Position.X,
							data.pos,
							humanoidRootPart.Position.Z
						))) * vfx.WIndStart:GetAttribute("Offset") * CFrame.new(0, -21, 0)
					})
					shared.vfx.emit(v10)
				end,
				[98] = function()
					local spinModel1 = vfx.SpinModel1
					local v10 = quickFX({
						FX = spinModel1,
						Maid = object3._maid,
						Anchor = CFrame.new((Vector3.new(
							humanoidRootPart.Position.X,
							data.pos,
							humanoidRootPart.Position.Z
						))) * spinModel1:GetAttribute("Offset") * CFrame.new(0, 15, 0)
					})
					shared.vfx.emit(v10)
				end
			})
		end

		og()
		local v8 = _maid:give(script.VFX3:Clone())
		v8:PivotTo(humanoidRootPart.CFrame)
		local track = v8.AnimationController:LoadAnimation(v8:FindFirstChildOfClass("Animation"))
		track:Play()
		_maid:giveTask(track:GetMarkerReachedSignal("itshappening"):Connect(function()
			shared.repfire({
				Effect = "JustMod",
				Mod = "v2 port",
				Event = "AgainEvent",
				Char = char,
				bind = bind
			})
		end))
		_maid:giveTask(track:GetMarkerReachedSignal("shoot"):Connect(function()
			shared.repfire({
				Effect = "JustMod",
				Mod = "v2 port",
				Event = "ShootEvent",
				Char = char,
				bind = bind
			})
		end))
		v8.Parent = EFP
		local v9 = _maid:give(Instance.new("ObjectValue"))
		v9.Name = "GammaRig"
		v9.Value = v8
		v9.Parent = char
		local v10 = quickFX({
			FX = vfx.NukePart,
			Maid = _maid,
			Anchor = v7.CFrame
		})
		local FX = quickFX({
			FX = vfx.ComeIN,
			Maid = _maid,
			Anchor = v7.CFrame
		})
		TweenSequence.fromAttribute(v10, "ScaleSequence", 3.5, false, 0.6):Start()
		task.delay(0.3, function()
			task.delay(0.35, function()
				local clone = vfx.BigRing:Clone()
				clone:ScaleTo(0.5)
				clone.Start.Color = Color3.new(0.156863, 0.117647, 0.258824)
				playMesh({
					Model = clone,
					EndT = 0,
					Anchor = humanoidRootPart.CFrame * CFrame.new(0, -1 * v10:GetScale(), 0),
					Info = TweenInfo.new(2, Enum.EasingStyle.Exponential)
				})
				Debris:AddItem(clone, 1)
				task.delay(0.9, function()
					TweenService:Create(clone.Start, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
						Transparency = 1
					}):Play()
				end)
			end)
			local clone = vfx.BigRing:Clone()
			clone:ScaleTo(0.3)
			clone.Start.Color = Color3.fromRGB(30, 45, 90)
			playMesh({
				Model = clone,
				EndT = 0,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -1 * v10:GetScale(), 0),
				Info = TweenInfo.new(3, Enum.EasingStyle.Exponential)
			})
			Debris:AddItem(clone, 0.9)
			task.delay(0.8, function()
				TweenService:Create(clone.Start, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
					Transparency = 1
				}):Play()
			end)
		end)
		local v12 = quickFX({
			FX = vfx.Bottom,
			Maid = _maid,
			Anchor = v7.CFrame * CFrame.new(0, -4.3, 0) * cframe3
		})
		local v13 = _maid:give(Instance.new("NumberValue"))
		v12:ScaleTo(0.01)
		_maid:giveTask(v13.Changed:Connect(function()
			v12:ScaleTo(v13.Value)
		end))
		v13.Value = v12:GetScale()
		TweenService:Create(v13, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
			Value = 2
		}):Play()
		task.delay(0.5, function()
			TweenService:Create(v13, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Value = 0.01
			}):Play()
			Debris:AddItem(v12, 0.5)
		end)
		local v14 = quickFX({
			FX = vfx.BottomSecondary,
			Maid = _maid,
			Anchor = v7.CFrame * CFrame.new(0, -4.8, 0) * cframe3
		})
		local v15 = _maid:give(Instance.new("NumberValue"))
		v14:ScaleTo(0.01)
		_maid:giveTask(v15.Changed:Connect(function()
			v14:ScaleTo(v15.Value)
		end))
		v15.Value = v14:GetScale()
		TweenService:Create(v15, TweenInfo.new(0.7, Enum.EasingStyle.Bounce), {
			Value = 3
		}):Play()
		task.delay(0.5, function()
			TweenService:Create(v15, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Value = 0.01
			}):Play()
			Debris:AddItem(v14, 0.5)
		end)
		local v16 = object3._maid:give(Instance.new("NumberValue"))
		v16.Value = 0
		local v17 = _maid:give(Instance.new("Part"))
		v17.Transparency = 1
		v17.CanCollide = false
		v17.CFrame = v7.CFrame * CFrame.new(0, -30, 0)
		v17.Parent = EFP
		task.spawn(function()
			local lastTime = tick()
			local v18 = {}

			local function beamcrescent(p2, p3)
				for _ = 1, p3 do
					local clone = vfx.beamcrescent:Clone()
					local v19 = math.rad((math.random(-10, 10)))
					local v20 = math.rad((math.random(-360, 360)))
					local v21 = math.rad((math.random(-10, 10)))
					clone.CFrame = p2 * CFrame.Angles(v19, v20, v21)
					clone.Parent = EFP
					local v22 = math.random(500, 1000) / 1000 * 0.3
					beamcrescent2(clone, CFrame.new(), v22, math.random(2, 3), math.rad((math.random(-179, 179))))
					textureflipbook(clone.Beams.Beam, v4, v22)
					Debris:AddItem(clone, v22)
					v18[clone] = {}
				end
			end

			local v19 = _maid:give(Instance.new("NumberValue"))
			v19.Value = 0.1
			TweenService:Create(v19, TweenInfo.new(3, Enum.EasingStyle.Sine), {
				Value = 8.5
			}):Play()
			local v20 = _maid:give(Instance.new("NumberValue"))
			v20.Value = 0.3
			TweenService:Create(v20, TweenInfo.new(2, Enum.EasingStyle.Sine), {
				Value = 0.01
			}):Play()
			local v21 = _maid:give(Instance.new("NumberValue"))
			v21.Value = 0.2
			TweenService:Create(v21, TweenInfo.new(3, Enum.EasingStyle.Linear), {
				Value = 2
			}):Play()
			local v22 = _maid:give(Instance.new("NumberValue"))
			v22.Value = -1
			TweenService:Create(v22, TweenInfo.new(1.7, Enum.EasingStyle.Linear), {
				Value = -0.2
			}):Play()
			local pivot = v12:GetPivot()
			local now = tick()
			task.delay(2.75, function()
				able({
					FX = FX,
					On = false
				})
				task.wait(0.2)
				local FX2 = quickFX({
					FX = vfx.Done2,
					Maid = _maid,
					Anchor = v10:GetPivot()
				})
				FX2:ScaleTo(0.5)
				lifeScale({
					FX = FX2,
					Scale = 0.5
				})
				able({
					FX = FX2,
					On = false
				})
				playAttachment(FX2)
			end)
			local count = 0
			local children = nil
			local v23 = {}

			while tick() - lastTime < 5.6 do
				count += 1
				local v24 = tick() - lastTime
				local value = v20.Value
				local v25 = random:NextNumber(-1, 1) * value
				local v26 = random:NextNumber(-1, 1) * value
				local v27 = random:NextNumber(-1, 1) * value
				local cFrame = humanoidRootPart.CFrame
				v8:PivotTo(cFrame)
				v10:PivotTo(cFrame * CFrame.new(v25, v26, v27))
				v12:PivotTo(pivot * CFrame.new(v25 * 1.1, v26 * 1.1, v27 * 1.1))
				local pivot2 = v10:GetPivot()
				FX:PivotTo(pivot2)
				local raycastResult2 = game.Workspace:Raycast(
					humanoidRootPart.Position,
					createVector(0, -50, 0),
					raycastParams
				)

				if raycastResult2 then
					v7.CFrame = CFrame.new(raycastResult2.Position + createVector(0, 5.3, 0))
					v14:PivotTo(v7.CFrame * CFrame.new(0, -4.8, 0) * cframe3)
					v12:PivotTo(v7.CFrame * CFrame.new(0, -4.3, 0) * cframe3)
				end

				if v17.Parent then
					v17.CFrame = v7.CFrame * CFrame.new(0, -30 + 105 * v16.Value, 0)
				end

				if v10.Parent then
					if not children then
						children = {}

						for _, child in pairs(v10.Model:GetChildren()) do
							if v3[child.Name] then
								children[#children + 1] = child
							end
						end
					end

					local value2 = v19.Value

					for i = 1, #children do
						local v28 = children[i]
						v28:PivotTo(v28:GetPivot() * CFrame.Angles(0, math.rad(v3[v28.Name] * value2), 0))
					end
				end

				if count % 10 == 0 and v24 < 0.9 then
					local v28 = _maid:give(vfx.Ring:Clone())
					local v29 = math.rad((random:NextNumber(-360, 360)))
					local scale = v10:GetScale()
					local v30 = 0.2 * v21.Value
					v28:ScaleTo(0.01)
					v28:PivotTo(pivot2 * CFrame.new(0, -1.3 * scale, 0) * CFrame.Angles(0, v29, 0))
					TweenSequence.fromAttribute(v28, "ScaleSequence", v30, false, 1 * scale):Start()
					v28.Parent = EFP
					TweenService:Create(v28.PrimaryPart, TweenInfo.new(v30, Enum.EasingStyle.Linear), {
						CFrame = pivot2 * CFrame.new(0, 1.3 * scale, 0) * CFrame.Angles(0, v29, 0)
					}):Play()
					Debris:AddItem(v28, 0.15 * v21.Value)
				end

				if count % 20 == 0 and v24 < 2 and v24 > 1 then
					local folder = _maid:give(vfx.Part3:Clone())
					folder.Parent = EFP

					for _, descendant in pairs(folder:GetDescendants()) do
						if descendant:IsA("PointLight") then
							TweenService:Create(descendant, TweenInfo.new(3.5, Enum.EasingStyle.Sine), {
								Brightness = 0
							}):Play()
						elseif descendant:IsA("Trail") then
							descendant.Lifetime *= 0.3
							descendant.Color = colorSequence
						end
					end

					local distance = _maid:give(Instance.new("NumberValue"))
					distance.Value = 20
					folder:PivotTo(pivot2)
					local orbitSpeed = _maid:give(Instance.new("NumberValue"))
					orbitSpeed.Value = random:NextNumber(0.5, 1) * 15
					local v30 = _maid:give(Instance.new("NumberValue"))
					v30.Value = 1
					_maid:giveTask(v30.Changed:Connect(function()
						folder:ScaleTo(v30.Value)
					end))
					TweenService:Create(orbitSpeed, TweenInfo.new(2, Enum.EasingStyle.Sine), {
						Value = 32
					}):Play()
					local number = random:NextNumber(0.4, 1)
					local tiltAxis = randomUnitVector()
					local number2 = random:NextNumber(0, 6.283185307179586)
					local number3 = random:NextNumber(0, 6.283185307179586)
					TweenService:Create(distance, TweenInfo.new(1.4000000000000001, Enum.EasingStyle.Sine), {
						Value = 5
					}):Play()
					local folder2 = folder
					task.delay(1.05, function()
						TweenService:Create(distance, TweenInfo.new(1.75, Enum.EasingStyle.Sine), {
							Value = 0.1
						}):Play()

						for i, trail in pairs(folder2:GetDescendants()) do
							if trail:IsA("Trail") then
								playTween(trail, {
									EasingStyle = "Sine",
									Time = 1.05,
									Goal = {
										WidthScale = numberSequence
									}
								})
							end
						end

						TweenService:Create(orbitSpeed, TweenInfo.new(0.7000000000000001, Enum.EasingStyle.Sine), {
							Value = 5
						}):Play()
					end)
					Debris:AddItem(folder, 3.5)
					v23[folder] = {
						Distance = distance,
						OrbitSpeed = orbitSpeed,
						OrbitAngle = number2,
						TiltSpeed = number,
						TiltAxis = tiltAxis,
						TiltAngle = number3,
						Origin = folder:GetPivot()
					}
				end

				local now2 = tick()
				local v28 = now2 - now
				local cframe4 = CFrame.new(humanoidRootPart.Position)
				now = now2

				for k, v29 in pairs(v23) do
					if k.Parent then
						v29.OrbitAngle += (v29.OrbitSpeed.Value or 0) * v28
						v29.TiltAngle += (v29.TiltSpeed or 0) * v28
						local cframe5 = CFrame.fromAxisAngle(v29.TiltAxis, v29.TiltAngle)
						local cframe6 = CFrame.fromAxisAngle(createVector(0, 1, 0), v29.OrbitAngle)
						v29.Origin = cframe4
						k:PivotTo(cframe4 * cframe5 * cframe6 * CFrame.new(0, 0, v29.Distance.Value))
					else
						v23[k] = nil
					end
				end

				for k, _ in pairs(v18) do
					k:PivotTo(k:GetPivot() * CFrame.Angles(0, 0.20943951023931956, 0))
				end

				dtwait(0.01)
			end
		end)
		Debris:AddItem(v10, 3)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Tornado(p2)
			task.spawn(function()
				local lastTime = tick()
				local count = 0
				local v18 = {}
				local object4 = setmetatable({}, class)
				object4._maid = maid.new()
				local _maid2 = object4._maid
				local v19 = false

				-- equivalent calls inferred from this helper; original call sites unknown
				local function Clean2()
					if not v19 then
						v19 = true
						_maid2:doCleaning()
					end
				end

				task.delay(15, function()
					Clean2() -- equivalent call inferred; original call site unknown
				end)
				local parent = _maid2:give(Instance.new("Part"))
				parent.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 20, 0)
				parent.Anchored = true
				parent.Transparency = 1
				parent.Parent = EFP
				local v21 = _maid2:give(vfx.Inner:Clone())
				local pointLight = Instance.new("PointLight")
				pointLight.Brightness = 5
				pointLight.Color = Color3.fromRGB(185, 114, 255)
				pointLight.Range = 25
				pointLight.Parent = parent
				local v22 = _maid2:give(Instance.new("NumberValue"))
				v22.Value = 8
				TweenService:Create(v22, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					Value = 1
				}):Play()
				local v23 = _maid2:give(Instance.new("NumberValue"))
				v23.Value = 11
				TweenService:Create(v23, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					Value = 5
				}):Play()
				local v24 = _maid2:give(Instance.new("NumberValue"))
				v24.Value = 0.1
				TweenService:Create(v24, TweenInfo.new(4, Enum.EasingStyle.Sine), {
					Value = 5.6
				}):Play()
				local v25 = _maid2:give(Instance.new("NumberValue"))
				v25.Value = 6
				TweenService:Create(v25, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					Value = 12
				}):Play()
				local v26 = _maid2:give(Instance.new("NumberValue"))
				v26.Value = 0
				TweenService:Create(v26, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
					Value = 0.05
				}):Play()
				local v27 = _maid2:give(Instance.new("NumberValue"))
				v27.Value = 3
				TweenService:Create(v27, TweenInfo.new(3, Enum.EasingStyle.Sine), {
					Value = 0.1
				}):Play()
				task.delay(1.5, function()
					TweenService:Create(v24, TweenInfo.new(4, Enum.EasingStyle.Bounce), {
						Value = 0.1
					}):Play()
				end)

				while tick() - lastTime < 1.6 do
					count += 1
					local v28 = tick() - lastTime > 1
					local cFrame = p2.CFrame
					local v29 = cFrame * CFrame.new(0, v23.Value, 0)

					if count % 2 == 0 and not v28 then
						local v30 = _maid2:give(vfx.New:Clone())
						local decal = v30.PrimaryPart.Decal
						local color3 = decal.Color3
						local value = v27.Value
						decal.Color3 = Color3.fromRGB(55 * value, 150 * value, 855 * value)
						local angle = select(1, CFrame.new(parent.Position, v29.Position):ToOrientation()) * v26.Value
						v30:PivotTo(parent.CFrame * CFrame.Angles(angle, 0, 0))
						v30.Parent = EFP
						TweenService:Create(decal, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {
							Color3 = color3
						}):Play()
						local scale = _maid2:give(Instance.new("NumberValue"))
						scale.Value = 0.2
						TweenService:Create(scale, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
							Value = random:NextNumber(1, 1.5)
						}):Play()
						local progress = _maid2:give(Instance.new("NumberValue"))
						progress.Value = 0.9
						TweenService:Create(progress, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
							Value = 1
						}):Play()
						local spinSpeed = _maid2:give(Instance.new("NumberValue"))
						spinSpeed.Value = 15
						TweenService:Create(spinSpeed, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							Value = 1
						}):Play()
						_maid2:giveTask(scale.Changed:Connect(function()
							v30:ScaleTo(scale.Value * v24.Value)
						end))
						v18[v30] = {
							Scale = scale,
							Rot = random:NextNumber(0, 360),
							Progress = progress,
							Original = v30:GetPivot(),
							SpinSpeed = spinSpeed,
							Angle = angle
						}
					end

					for k, v30 in pairs(v18) do
						local value = v30.Progress.Value
						k:PivotTo(v30.Original:Lerp(v29, value) * CFrame.Angles(0, v30.Rot, 0) * CFrame.Angles(
							v30.Angle,
							math.rad(v30.SpinSpeed.Value * count),
							0
						))

						if not (value >= 1) then
							continue
						end

						if v28 then
							if not v30.Finishing then
								v30.Finishing = true
								local mesh = k.PrimaryPart.Mesh
								TweenService:Create(mesh, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
									Scale = Vector3.new(mesh.Scale.X, 0, mesh.Scale.Z)
								}):Play()
								Debris:AddItem(k, 0.1)
							end
						else
							k:Destroy()
							v18[k] = nil
						end
					end

					parent:PivotTo(cFrame * CFrame.Angles(0, math.rad(v25.Value * count), 0) * CFrame.new(
						0,
						0,
						v22.Value
					))
					v21:PivotTo(CFrame.new(parent.Position, v29.Position) * cframe2 * CFrame.Angles(
						math.rad(v25.Value * count * 3),
						0,
						0
					) * CFrame.new(v23.Value * 0.3, 0, 0))
					v21:ScaleTo(math.clamp(v24.Value, 0.01, 1e999) * random:NextNumber(1.2, 2.4))
					dtwait(0.001)
				end

				task.wait(1)
				Clean2() -- equivalent call inferred; original call site unknown
			end)
		end

		TweenService:Create(v16, TweenInfo.new(11.75, Enum.EasingStyle.Exponential), {
			Value = 1
		}):Play()
		Tornado(v17) -- equivalent call inferred; original call site unknown
	end

	task.spawn(FirstEvent)
	task.wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function V2Port.AgainEvent2(p)
	local data = p.Data

	if not data.bind then
		return
	end

	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local object3 = setmetatable({}, class)
	object3._maid = maid.new()
	local _maid = object3._maid
	local v6 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v6 then
			v6 = true
			_maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function AgainEvent()
		local gammaRig = char:FindFirstChild("GammaRig")

		if not (gammaRig and gammaRig.Value) then
			return
		end

		local value = gammaRig.Value
		local v7 = _maid:give(Instance.new("Highlight"))
		v7.DepthMode = Enum.HighlightDepthMode.Occluded
		v7.OutlineTransparency = 1
		v7.FillTransparency = 0
		v7.FillColor = Color3.new(0, 0, 0)
		TweenService:Create(v7, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
			FillTransparency = 1
		}):Play()
		v7.Parent = char
		value:PivotTo(humanoidRootPart:GetPivot())
		local FX = quickFX({
			FX = vfx.Close,
			Maid = _maid,
			Anchor = humanoidRootPart.CFrame
		})
		local ballInnerModel = value:WaitForChild("BallInnerModel")
		local ballOuterModel = value:WaitForChild("BallOuterModel")
		local lastTime = tick()
		local v9 = _maid:give(Instance.new("NumberValue"))
		v9.Value = 1
		TweenService:Create(v9, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			Value = 0.1
		}):Play()
		local folder = quickFX({
			FX = vfx.FinalHit,
			Maid = _maid,
			Anchor = value:GetPivot() * CFrame.new(0, 0, 10)
		})
		folder:ScaleTo(1.5)
		playAttachment(folder)
		local v10 = quickFX({
			FX = vfx.ez,
			Maid = _maid,
			Anchor = value:GetPivot()
		})
		v10:ScaleTo(0.5)
		playAttachment(v10)
		local v11 = quickFX({
			FX = vfx.Transition,
			Maid = _maid,
			Anchor = value:GetPivot()
		})
		v11:ScaleTo(1.5)
		playAttachment(v11)
		local emitters = {}

		for _, emitter in pairs(folder:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitters[#emitters + 1] = emitter
			TweenService:Create(emitter, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				TimeScale = 0.01
			}):Play()
		end

		task.spawn(function()
			while tick() - lastTime < 2 do
				local value2 = v9.Value
				value:PivotTo(humanoidRootPart.CFrame * CFrame.new(
					random:NextNumber(-value2, value2),
					random:NextNumber(-value2, value2),
					random:NextNumber(-value2, value2)
				))
				folder:PivotTo(value:GetPivot())
				dtwait(0.01)
			end
		end)
		local scales = value.RootPart.Root.Scales
		local part = ballOuterModel.Part
		local part2 = ballInnerModel.Part
		local ballOuterPart = part.BallOuterPart
		local ballOuterInnerFaces = part.BallOuterInnerFaces
		local ballInnerPart = part2.BallInnerPart
		local ballInner2Part = part2.BallInner2Part
		local opacityMask = part2.OpacityMask
		local part3 = value.FlamesModel.Part
		local flamesModel = value.FlamesModel
		local neonModel = value.NeonModel
		local sphereRocks = value.SphereRocks
		local mesh = ballOuterInnerFaces.Mesh
		local mesh2 = ballOuterPart.Mesh
		local mesh3 = ballInnerPart.Mesh
		local mesh4 = ballInner2Part.Mesh
		local mesh5 = opacityMask.Mesh
		local mesh6 = part3.OuterFlame.Mesh
		local mesh7 = part3.InnerFlame.Mesh
		local ballInnerOuterScale = scales.BallInnerOuterScale
		local neonInsideScale = scales.NeonInsideScale
		local outerFlameScale = scales.OuterFlameScale
		local ballInnerTransparency = scales.BallInnerTransparency
		local ballInner2Transparency = scales.BallInner2Transparency
		local textures = {}
		local FX2 = nil

		for _, texture in pairs(sphereRocks:GetDescendants()) do
			if texture:IsA("Texture") then
				textures[#textures + 1] = texture
			end
		end

		task.delay(0.08, function()
			ballOuterInnerFaces.Transparency = 0.02
			ballOuterPart.Transparency = 0.02

			for _, textureId in ipairs(v5) do
				mesh.TextureId = textureId
				mesh2.TextureId = textureId
				task.wait(0.014)
			end

			ballOuterInnerFaces.Transparency = 1
			ballOuterPart.Transparency = 1
		end)
		task.delay(0.46, function()
			sphereRocks.Transparency = 0
			neonModel.Neon.Transparency = 0

			for i = 1, #textures do
				textures[i].Transparency = 0
			end

			able({
				FX = FX,
				On = false
			})
			task.wait(0.3)
			FX2 = quickFX({
				FX = vfx.Close3,
				Maid = _maid,
				Anchor = humanoidRootPart.CFrame
			})
		end)
		task.delay(1.5583, function()
			sphereRocks.Transparency = 1

			for i = 1, #textures do
				textures[i].Transparency = 1
			end
		end)
		task.delay(0.865, function()
			turnOnParticle(neonModel.Particle)
		end)
		task.delay(1.55, function()
			turnOnParticle(value.ParticleSmoke)
		end)
		task.delay(1.475, function()
			turnOffParticle(neonModel.Particle)

			for i = 1, #emitters do
				TweenService:Create(emitters[i], TweenInfo.new(1, Enum.EasingStyle.Sine), {
					TimeScale = 1
				}):Play()
			end

			able({
				FX = FX2,
				On = false
			})
			local FX3 = quickFX({
				FX = vfx.FinalHit,
				Maid = _maid,
				Anchor = value:GetPivot()
			})
			lifeScale({
				FX = FX3,
				Scale = 1.5
			})
			FX3:ScaleTo(3.5)
			playAttachment(FX3)
		end)
		task.delay(1.7, function()
			turnOffParticle(value.ParticleSmoke)
		end)
		local connection = renderStepped:Connect(function()
			local position = camera.CFrame.Position
			UpdateScale(ballInnerModel, ballInnerOuterScale) -- equivalent call inferred; original call site unknown
			UpdateScale(ballOuterModel, ballInnerOuterScale) -- equivalent call inferred; original call site unknown
			UpdateScale(neonModel, neonInsideScale) -- equivalent call inferred; original call site unknown
			UpdateScale(flamesModel, outerFlameScale) -- equivalent call inferred; original call site unknown
			MeshRenderPrioty(mesh, part, -0.25, position) -- equivalent call inferred; original call site unknown
			MeshRenderPrioty(mesh4, part2, -0.03, position) -- equivalent call inferred; original call site unknown
			MeshRenderPrioty(mesh3, part2, -0.2, position) -- equivalent call inferred; original call site unknown
			MeshRenderPrioty(mesh5, part2, -0.3, position) -- equivalent call inferred; original call site unknown
			MeshRenderPrioty(mesh6, part, -0.3, position) -- equivalent call inferred; original call site unknown
			MeshRenderPrioty(mesh7, part, -0.05, position) -- equivalent call inferred; original call site unknown
			UpdateTransparncy(opacityMask, ballInnerTransparency) -- equivalent call inferred; original call site unknown
			UpdateTransparncy(ballInnerPart, ballInnerTransparency) -- equivalent call inferred; original call site unknown
			UpdateTransparncy(ballInner2Part, ballInner2Transparency) -- equivalent call inferred; original call site unknown
		end)
		task.delay(15, function()
			if connection then
				return connection:Disconnect()
			end
		end)
		_maid:giveTask(connection)
		task.wait(2.15)
		neonModel.Neon.Transparency = 1
		connection:Disconnect()
	end

	task.spawn(AgainEvent)
	task.wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function V2Port.AgainEvent(p)
	local data = p.Data

	if not data.bind then
		return
	end

	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local object3 = setmetatable({}, class)
	object3._maid = maid.new()
	local v6 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v6 then
			v6 = true
			object3._maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)

	local function AgainEvent()
		local gammaRig = char:FindFirstChild("GammaRig")

		if not (gammaRig and gammaRig.Value) then
			return
		end

		local value = gammaRig.Value
		local v7 = object3._maid:give(Instance.new("Highlight"))
		v7.DepthMode = Enum.HighlightDepthMode.Occluded
		v7.OutlineTransparency = 1
		v7.FillTransparency = 0
		v7.FillColor = Color3.new(0, 0, 0)
		TweenService:Create(v7, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
			FillTransparency = 1
		}):Play()
		v7.Parent = char
		value:PivotTo(humanoidRootPart:GetPivot())
		local FX = quickFX({
			FX = vfx.Close,
			Maid = object3._maid,
			Anchor = humanoidRootPart.CFrame
		})
		local ballInnerModel = value:WaitForChild("BallInnerModel")
		local ballOuterModel = value:WaitForChild("BallOuterModel")
		local lastTime = tick()
		local v9 = object3._maid:give(Instance.new("NumberValue"))
		v9.Value = 1
		TweenService:Create(v9, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			Value = 0.1
		}):Play()
		local folder = quickFX({
			FX = vfx.FinalHit,
			Maid = object3._maid,
			Anchor = value:GetPivot() * CFrame.new(0, 0, 10)
		})
		folder:ScaleTo(1.5)
		playAttachment(folder)
		local v10 = quickFX({
			FX = vfx.ez,
			Maid = object3._maid,
			Anchor = value:GetPivot() * CFrame.new(0, 0, 0)
		})
		v10:ScaleTo(0.5)
		playAttachment(v10)
		local v11 = quickFX({
			FX = vfx.Transition,
			Maid = object3._maid,
			Anchor = value:GetPivot() * CFrame.new(0, 0, 0)
		})
		v11:ScaleTo(1.5)
		playAttachment(v11)

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				TweenService:Create(emitter, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					TimeScale = 0.01
				}):Play()
			end
		end

		local count = 0
		task.spawn(function()
			while tick() - lastTime < 2 do
				count += 1
				value:PivotTo(humanoidRootPart.CFrame * CFrame.new(
					random:NextNumber(-1, 1) * v9.Value,
					random:NextNumber(-1, 1) * v9.Value,
					random:NextNumber(-1, 1) * v9.Value
				) * CFrame.Angles(0, 0, 0))
				folder:PivotTo(value:GetPivot())
				dtwait(0.01)
			end
		end)
		local v12 = {
			"https://assetgame.roblox.com/asset/?id=139162279786523&assetName=0011 %281%29",
			"https://assetgame.roblox.com/asset/?id=99850399400414&assetName=0012 %281%29",
			"https://assetgame.roblox.com/asset/?id=137571101456637&assetName=0013 %281%29",
			"https://assetgame.roblox.com/asset/?id=108605337651494&assetName=0014 %281%29",
			"https://assetgame.roblox.com/asset/?id=97294867253288&assetName=0015 %281%29",
			"https://assetgame.roblox.com/asset/?id=134233926395828&assetName=0016 %281%29",
			"https://assetgame.roblox.com/asset/?id=87851838572617&assetName=0017 %281%29",
			"https://assetgame.roblox.com/asset/?id=115953576098871&assetName=0018 %281%29",
			"https://assetgame.roblox.com/asset/?id=116199241115838&assetName=0019 %281%29",
			"https://assetgame.roblox.com/asset/?id=95694860854384&assetName=0020 %281%29",
			"https://assetgame.roblox.com/asset/?id=73137991011198&assetName=0021 %281%29",
			"https://assetgame.roblox.com/asset/?id=81643078662417&assetName=0022 %281%29",
			"https://assetgame.roblox.com/asset/?id=80996928742800&assetName=0023 %281%29",
			"https://assetgame.roblox.com/asset/?id=98376628741986&assetName=0024 %281%29",
			"https://assetgame.roblox.com/asset/?id=137835431642243&assetName=0025 %281%29",
			"https://assetgame.roblox.com/asset/?id=110252124120783&assetName=0026 %281%29",
			"https://assetgame.roblox.com/asset/?id=99731409221936&assetName=0027 %281%29",
			"https://assetgame.roblox.com/asset/?id=138569587129869&assetName=0028 %281%29",
			"https://assetgame.roblox.com/asset/?id=120442197747109&assetName=0029 %281%29",
			"https://assetgame.roblox.com/asset/?id=110052475109692&assetName=0030 %281%29",
			"https://assetgame.roblox.com/asset/?id=139070004115934&assetName=0031 %281%29",
			"https://assetgame.roblox.com/asset/?id=91038215552778&assetName=0032 %281%29",
			"https://assetgame.roblox.com/asset/?id=87155954086133&assetName=0033 %281%29",
			"https://assetgame.roblox.com/asset/?id=77311449651934&assetName=0034 %281%29",
			"https://assetgame.roblox.com/asset/?id=76823117997450&assetName=0035 %281%29",
			"https://assetgame.roblox.com/asset/?id=123884734273967&assetName=0036",
			"https://assetgame.roblox.com/asset/?id=98555243319684&assetName=0037",
			"https://assetgame.roblox.com/asset/?id=134268362461884&assetName=0038",
			"https://assetgame.roblox.com/asset/?id=97851542065868&assetName=0039",
			"https://assetgame.roblox.com/asset/?id=97537771792355&assetName=0040",
			"https://assetgame.roblox.com/asset/?id=90091712346144&assetName=0041",
			"https://assetgame.roblox.com/asset/?id=112060506773005&assetName=0042",
			"https://assetgame.roblox.com/asset/?id=117498503692396&assetName=0043",
			"https://assetgame.roblox.com/asset/?id=123479384631135&assetName=0044",
			"https://assetgame.roblox.com/asset/?id=99644133044265&assetName=0045",
			"https://assetgame.roblox.com/asset/?id=74263574233062&assetName=0046",
			"https://assetgame.roblox.com/asset/?id=120621176767746&assetName=0047",
			"https://assetgame.roblox.com/asset/?id=102174574722945&assetName=0048",
			"https://assetgame.roblox.com/asset/?id=75688864271891&assetName=0049",
			"https://assetgame.roblox.com/asset/?id=73916742897834&assetName=0050",
			"https://assetgame.roblox.com/asset/?id=112357700674630&assetName=0051",
			"https://assetgame.roblox.com/asset/?id=96482647134517&assetName=0052",
			"https://assetgame.roblox.com/asset/?id=107142167745809&assetName=0053",
			"https://assetgame.roblox.com/asset/?id=75833917496513&assetName=0054",
			"https://assetgame.roblox.com/asset/?id=114111062169850&assetName=0055"
		}
		local _ = {
			"https://assetgame.roblox.com/asset/?id=133449036626981&assetName=0088",
			"https://assetgame.roblox.com/asset/?id=95234096655778&assetName=0089",
			"https://assetgame.roblox.com/asset/?id=125036527145601&assetName=0090",
			"https://assetgame.roblox.com/asset/?id=98277003178215&assetName=0091",
			"https://assetgame.roblox.com/asset/?id=77413908777664&assetName=0092",
			"https://assetgame.roblox.com/asset/?id=100366961229038&assetName=0093",
			"https://assetgame.roblox.com/asset/?id=104077613266631&assetName=0094",
			"https://assetgame.roblox.com/asset/?id=91486449108026&assetName=0095",
			"https://assetgame.roblox.com/asset/?id=129894529688199&assetName=0096",
			"https://assetgame.roblox.com/asset/?id=117715870042634&assetName=0097 %281%29"
		}

		local function UpdateScale2(instance, p2)
			UpdateScale(instance, p2) -- equivalent call inferred; original call site unknown
		end

		local function UpdateTransparncy2(p2, p3)
			UpdateTransparncy(p2, p3) -- equivalent call inferred; original call site unknown
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function MeshRenderPrioty2(mesh, part, p2)
			MeshRenderPrioty(mesh, part, p2, camera.CFrame.Position) -- equivalent call inferred; original call site unknown
		end

		local function turnOnParticle2(instance)
			turnOnParticle(instance) -- equivalent call inferred; original call site unknown
		end

		local function turnOffParticle2(instance)
			turnOffParticle(instance) -- equivalent call inferred; original call site unknown
		end

		local FX2 = nil
		local scales = value.RootPart.Root.Scales
		local ballOuterPart = ballOuterModel.Part.BallOuterPart
		local ballOuterInnerFaces = ballOuterModel.Part.BallOuterInnerFaces
		local ballInnerPart = ballInnerModel.Part.BallInnerPart
		local ballInner2Part = ballInnerModel.Part.BallInner2Part
		local part = value.FlamesModel.Part
		local neonModel = value.NeonModel
		task.delay(0.08, function()
			ballOuterInnerFaces.Transparency = 0.02
			ballOuterPart.Transparency = 0.02

			for _, textureId in ipairs(v12) do
				ballOuterInnerFaces.Mesh.TextureId = textureId
				ballOuterPart.Mesh.TextureId = textureId
				task.wait(0.014)
			end

			ballOuterInnerFaces.Transparency = 1
			ballOuterPart.Transparency = 1
		end)
		task.delay(0.46, function()
			value.SphereRocks.Transparency = 0
			neonModel.Neon.Transparency = 0

			for _, texture in pairs(value.SphereRocks:GetDescendants()) do
				if texture:IsA("Texture") then
					texture.Transparency = 0
				end
			end

			able({
				FX = FX,
				On = false
			})
			task.wait(0.3)
			FX2 = quickFX({
				FX = vfx.Close3,
				Maid = object3._maid,
				Anchor = humanoidRootPart.CFrame
			})
		end)
		task.delay(1.5583, function()
			value.SphereRocks.Transparency = 1

			for _, texture in pairs(value.SphereRocks:GetDescendants()) do
				if texture:IsA("Texture") then
					texture.Transparency = 1
				end
			end
		end)
		task.delay(0.865, function()
			turnOnParticle2(neonModel.Particle)
			TweenInfo.new(0.05835, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
			local _ = {
				Transparency = 0.02
			}
		end)
		task.delay(1.55, function()
			turnOnParticle2(value.ParticleSmoke)
			TweenInfo.new(0.075, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
			local _ = {
				Transparency = 0.999
			}
		end)
		task.delay(1.475, function() end)
		task.delay(1.475, function()
			turnOffParticle2(neonModel.Particle)

			for _, emitter in pairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					TweenService:Create(emitter, TweenInfo.new(1, Enum.EasingStyle.Sine), {
						TimeScale = 1
					}):Play()
				end
			end

			able({
				FX = FX2,
				On = false
			})
			local FX3 = quickFX({
				FX = vfx.FinalHit,
				Maid = object3._maid,
				Anchor = value:GetPivot() * CFrame.new(0, 0, 0)
			})
			lifeScale({
				FX = FX3,
				Scale = 1.5
			})
			FX3:ScaleTo(3.5)
			playAttachment(FX3)
		end)
		task.delay(1.7, function()
			turnOffParticle2(value.ParticleSmoke)
			value:Destroy()
		end)
		local renderSteppedConnection = nil
		local RunService2 = game:GetService("RunService")
		renderSteppedConnection = RunService2.RenderStepped:Connect(function()
			if not value.Parent then
				renderSteppedConnection:Disconnect()
				return
			end

			UpdateScale(ballInnerModel, scales.BallInnerOuterScale) -- equivalent call inferred; original call site unknown
			UpdateScale(ballOuterModel, scales.BallInnerOuterScale) -- equivalent call inferred; original call site unknown
			UpdateScale(neonModel, scales.NeonInsideScale) -- equivalent call inferred; original call site unknown
			value.FlamesModel:ScaleTo((math.clamp(scales.OuterFlameScale.Transform.Position.y / 2 + 1, 0.0001, 100)))
			MeshRenderPrioty2(ballOuterInnerFaces.Mesh, ballOuterModel.Part, -0.25) -- equivalent call inferred; original call site unknown
			MeshRenderPrioty2(ballInner2Part.Mesh, ballInnerModel.Part, -0.03) -- equivalent call inferred; original call site unknown
			MeshRenderPrioty2(ballInnerPart.Mesh, ballInnerModel.Part, -0.2) -- equivalent call inferred; original call site unknown
			MeshRenderPrioty2(ballInnerModel.Part.OpacityMask.Mesh, ballInnerModel.Part, -0.3) -- equivalent call inferred; original call site unknown
			MeshRenderPrioty2(part.OuterFlame.Mesh, ballOuterModel.Part, -0.3) -- equivalent call inferred; original call site unknown
			MeshRenderPrioty2(part.InnerFlame.Mesh, ballOuterModel.Part, -0.05) -- equivalent call inferred; original call site unknown
			ballInnerModel.Part.OpacityMask.Transparency = math.clamp(
				scales.BallInnerTransparency.Transform.Position.y / 2,
				0.02,
				1
			)
			UpdateTransparncy(ballInnerPart, scales.BallInnerTransparency) -- equivalent call inferred; original call site unknown
			UpdateTransparncy(ballInner2Part, scales.BallInner2Transparency) -- equivalent call inferred; original call site unknown
		end)
		task.wait(2.15)
		renderSteppedConnection:Disconnect()
	end

	task.spawn(AgainEvent)
	wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

function V2Port.ShootEvent(p)
	local data = p.Data
	local bind = data.bind

	if not bind then
		return
	end

	local char = data.Char
	local humanoidRootPart = char.HumanoidRootPart
	local _ = char.Humanoid
	local object3 = setmetatable({}, class)
	object3._maid = maid.new()
	local _maid = object3._maid
	local v6 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v6 then
			v6 = true
			_maid:doCleaning()
		end
	end

	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	local v7 = false
	local v8 = {}

	local function PickSfx()
		local clone = {}

		for _, v9 in ipairs(v2) do
			local v10 = false

			for _, v12 in ipairs(v8) do
				if v12 ~= v9 then
					continue
				end

				v10 = true
				break
			end

			if not v10 then
				table.insert(clone, v9)
			end
		end

		if #clone == 0 then
			clone = table.clone(v2)
		end

		local v9 = clone[math.random(1, #clone)]
		table.insert(v8, v9)

		if #v8 > 3 then
			table.remove(v8, 1)
		end

		return v9
	end

	local function ShootEvent()
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { game.Workspace.Map, workspace.Built }
		local v9 = 0
		local v10 = nil
		local clone = table.clone(v2)
		table.clone(clone)
		local random2 = Random.new()
		local v11 = -1e999
		local v12 = 0.03
		local v13 = true
		local count = 0

		local function SpawnExplo(cframe4, p2, value, p3, p4)
			local now = tick()
			local primaryPart, v14, v15, v16, v17, v18, rollOffMaxDistance, rollOffMinDistance, v21, sfx, v22, v23, v24, v25, v26

			if p3 then
				v11 = now
				v12 = 0.025
				primaryPart = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.PrimaryPart
				v14 = cframe4.Position + createVector(0, 0.15, 0)
				v15 = not primaryPart and 0 or (v14 - primaryPart.Position).Magnitude or 0
				v16 = primaryPart and (cframe4.Position - primaryPart.Position):Dot(primaryPart.CFrame.LookVector) < 0
				v17 = v13 and 1.25 or 1
				v18 = math.clamp((p2 - 2.5) * 0.12, 0, 0.35) + 1
				rollOffMaxDistance = math.clamp(80 + v15 * 3, 50, 400)
				rollOffMinDistance = math.clamp(8 + v15 * 0.7, 8, 60)
				v21 = math.max(1, random2:NextNumber(4.5, 6) - v15 * 0.018) / (math.max(1, 1 + v15 / 380) * 1.1)

				if p3 then
					sfx = shared.sfx
					v22 = {
						SoundId = "rbxassetid://86645208465330",
						CFrame = CFrame.new(v14 + createVector(0, 0.1, 0)),
						Volume = 6,
						RollOffMaxDistance = 0,
						RollOffMinDistance = 0,
						RollOffMode = 0
					}

					if char == game.Players.LocalPlayer.Character then
						rollOffMaxDistance = rollOffMaxDistance + 650 or rollOffMaxDistance
					end

					v22.RollOffMaxDistance = rollOffMaxDistance
					v22.RollOffMinDistance = rollOffMinDistance
					v22.RollOffMode = Enum.RollOffMode.Linear
					v23 = sfx(v22)
					v23:Play()
					task.delay(2.5, function()
						local TweenService2 = game:GetService("TweenService")
						TweenService2:Create(v23, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Volume = 0.5,
							RollOffMaxDistance = v23.RollOffMaxDistance / 2
						}):Play()
					end)
				elseif char == game.Players.LocalPlayer.Character then
					if v16 then
						print("ye")
					else
						v24 = PickSfx()
						v25 = shared.sfx({
							SoundId = "rbxassetid://" .. tostring(v24),
							CFrame = CFrame.new(v14 + createVector(0, 0.1, 0)),
							Volume = random2:NextNumber(4.5, 5.5) * v17 * v18 / (random2:NextNumber(1.6, 2) * (v15 <= 120 and 1.3 or 1.1)),
							PlaybackSpeed = random2:NextNumber(1, 1.2),
							RollOffMaxDistance = 1150,
							RollOffMinDistance = 40,
							RollOffMode = Enum.RollOffMode.Linear
						})
						v25:Play()

						if math.random(1, 2) == 2 then
							task.delay(random2:NextNumber(0.5, 1), function()
								local volume = v25.Volume
								local playbackSpeed = v25.PlaybackSpeed
								local number = random2:NextNumber(0, 0.15)
								local number2 = random2:NextNumber(0.25, 2)
								local v28, v29

								if math.random(1, 2) == 2 then
									v28 = volume - number2
									v29 = playbackSpeed - number
								else
									v28 = volume + number2
									v29 = playbackSpeed + number
								end

								local TweenService2 = game:GetService("TweenService")
								TweenService2:Create(
									v25,
									TweenInfo.new(
										random2:NextNumber(0.35, 1),
										Enum.EasingStyle.Quad,
										Enum.EasingDirection.Out
									),
									{
										Volume = math.max(v28, 0),
										PlaybackSpeed = v29
									}
								):Play()
							end)
						end

						if count == math.random(2, 3) then
							v13 = false
						end

						count += 1
					end
				else
					v26 = PickSfx()
					shared.sfx({
						SoundId = "rbxassetid://" .. tostring(v26),
						CFrame = CFrame.new(v14 + createVector(0, 0.1, 0)),
						Volume = v21 * v17 * v18 + 6,
						PlaybackSpeed = random2:NextNumber(1, 1.2),
						RollOffMaxDistance = rollOffMaxDistance + 550,
						RollOffMinDistance = rollOffMinDistance,
						RollOffMode = Enum.RollOffMode.Inverse
					}):Play()
					v13 = false
				end
			else
				local v27 = now - v11

				if v12 <= v27 then
					v11 = now
					v12 = 0.025
					primaryPart = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.PrimaryPart
					v14 = cframe4.Position + createVector(0, 0.15, 0)
					v15 = not primaryPart and 0 or (v14 - primaryPart.Position).Magnitude or 0
					v16 = primaryPart and (cframe4.Position - primaryPart.Position):Dot(primaryPart.CFrame.LookVector) < 0
					v17 = v13 and 1.25 or 1
					v18 = math.clamp((p2 - 2.5) * 0.12, 0, 0.35) + 1
					rollOffMaxDistance = math.clamp(80 + v15 * 3, 50, 400)
					rollOffMinDistance = math.clamp(8 + v15 * 0.7, 8, 60)
					v21 = math.max(1, random2:NextNumber(4.5, 6) - v15 * 0.018) / (math.max(1, 1 + v15 / 380) * 1.1)

					if p3 then
						sfx = shared.sfx
						v22 = {
							SoundId = "rbxassetid://86645208465330",
							CFrame = CFrame.new(v14 + createVector(0, 0.1, 0)),
							Volume = 6,
							RollOffMaxDistance = 0,
							RollOffMinDistance = 0,
							RollOffMode = 0
						}

						if char == game.Players.LocalPlayer.Character then
							rollOffMaxDistance = rollOffMaxDistance + 650 or rollOffMaxDistance
						end

						v22.RollOffMaxDistance = rollOffMaxDistance
						v22.RollOffMinDistance = rollOffMinDistance
						v22.RollOffMode = Enum.RollOffMode.Linear
						v23 = sfx(v22)
						v23:Play()
						task.delay(2.5, function()
							local TweenService2 = game:GetService("TweenService")
							TweenService2:Create(
								v23,
								TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Volume = 0.5,
									RollOffMaxDistance = v23.RollOffMaxDistance / 2
								}
							):Play()
						end)
					elseif char == game.Players.LocalPlayer.Character then
						if v16 then
							print("ye")
						else
							v24 = PickSfx()
							v25 = shared.sfx({
								SoundId = "rbxassetid://" .. tostring(v24),
								CFrame = CFrame.new(v14 + createVector(0, 0.1, 0)),
								Volume = random2:NextNumber(4.5, 5.5) * v17 * v18 / (random2:NextNumber(1.6, 2) * (v15 <= 120 and 1.3 or 1.1)),
								PlaybackSpeed = random2:NextNumber(1, 1.2),
								RollOffMaxDistance = 1150,
								RollOffMinDistance = 40,
								RollOffMode = Enum.RollOffMode.Linear
							})
							v25:Play()

							if math.random(1, 2) == 2 then
								task.delay(random2:NextNumber(0.5, 1), function()
									local volume = v25.Volume
									local playbackSpeed = v25.PlaybackSpeed
									local number = random2:NextNumber(0, 0.15)
									local number2 = random2:NextNumber(0.25, 2)
									local v28, v29

									if math.random(1, 2) == 2 then
										v28 = volume - number2
										v29 = playbackSpeed - number
									else
										v28 = volume + number2
										v29 = playbackSpeed + number
									end

									local TweenService2 = game:GetService("TweenService")
									TweenService2:Create(
										v25,
										TweenInfo.new(
											random2:NextNumber(0.35, 1),
											Enum.EasingStyle.Quad,
											Enum.EasingDirection.Out
										),
										{
											Volume = math.max(v28, 0),
											PlaybackSpeed = v29
										}
									):Play()
								end)
							end

							if count == math.random(2, 3) then
								v13 = false
							end

							count += 1
						end
					else
						v26 = PickSfx()
						shared.sfx({
							SoundId = "rbxassetid://" .. tostring(v26),
							CFrame = CFrame.new(v14 + createVector(0, 0.1, 0)),
							Volume = v21 * v17 * v18 + 6,
							PlaybackSpeed = random2:NextNumber(1, 1.2),
							RollOffMaxDistance = rollOffMaxDistance + 550,
							RollOffMinDistance = rollOffMinDistance,
							RollOffMode = Enum.RollOffMode.Inverse
						}):Play()
						v13 = false
					end
				end
			end

			if p4 or not (p3 or shared.OnScreen(cframe4.Position)) then
				return
			end

			local v27 = _maid:give(exploig:Clone())

			if p2 > 4.3 then
				cframe4 *= CFrame.new(0, 2.5 * (p2 - 4.3), 0)
			end

			v27:PivotTo(cframe4)
			v27:ScaleTo(p2)
			local v28 = p2 * 0.1

			if char ~= game.Players.LocalPlayer.Character and (game.Players.LocalPlayer.Character.PrimaryPart.Position - cframe4.Position).Magnitude <= 110 then
				shared.repfire({
					Effect = "Camshake",
					Intensity = math.random(1, 4)
				})
			end

			local v29 = value or 0
			local attachment = v27.Part.Attachment
			attachment.Glow.Color = ColorSequence.new(Color3.fromRGB(255, 110, 26):Lerp(
				Color3.fromRGB(255, 23, 26),
				v29
			))
			attachment.Fire_1_Toon.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 140, 39):Lerp(Color3.fromRGB(255, 60, 34), v29)),
				ColorSequenceKeypoint.new(0.424, Color3.fromRGB(207, 30, 17)),
				ColorSequenceKeypoint.new(0.706, Color3.fromRGB(21, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
			})
			attachment.Fire_4_Realistic_Contrast.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 140, 39):Lerp(Color3.fromRGB(255, 42, 42), v29)),
				ColorSequenceKeypoint.new(0.433, Color3.fromRGB(207, 51, 19)),
				ColorSequenceKeypoint.new(0.711, Color3.fromRGB(0, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
			})
			playAttachment(v27)
			shared.repfire({
				Effect = "Ground Crater",
				Seed = math.random(1, 2000000000),
				start = cframe4.Position,
				["end"] = cframe4.UpVector * -100,
				amount = random:NextNumber(4, 7),
				nosound = true,
				sizemult = 4.75 * v28,
				size = 15 * v28
			})
			v27.Parent = EFP
			return v27
		end

		task.spawn(function()
			local gammaExplo = char:WaitForChild("GammaExplo", 10)

			if not gammaExplo then
				return
			end

			local v14 = 3
			local v15 = nil
			local v16 = 0
			local v17 = 0
			_maid:giveTask(gammaExplo.ChildAdded:Connect(function(child)
				local v18 = (child and child:GetAttribute("Last") and v14 or random:NextNumber(1.2, 3.9)) * (1 + (child:GetAttribute("Heavy") or 0) * 0.5) * (1 + (child:GetAttribute("Grow") or 0))

				if not child:GetAttribute("Last") then
					local v19 = math.min(v18, 10)
					local v20 = child.Value.UpVector.Y < 0.5
					local v21 = char.PrimaryPart and (child.Value.Position - char.PrimaryPart.Position).Magnitude >= 100

					if v20 and v21 then
						v18 = v19 * Random.new():NextNumber(1.2, 1.4)
					else
						v18 = v19 / Random.new():NextNumber(1.05, 1.55)
					end
				end

				local grow = child:GetAttribute("Grow") or 0

				if not child:GetAttribute("Last") then
					v18 /= 1.05

					if v15 and v16 < grow and v18 <= v15 then
						v18 = v15 + 0.05
					end

					v15 = v18
					v16 = grow
				end

				if child:GetAttribute("Cluster") then
					v18 *= Random.new():NextNumber(0.6, 1.6)
				end

				if not child:GetAttribute("Last") then
					v18 /= child:GetAttribute("Contact") and 1.235 or 1.15

					if child:GetAttribute("Object") then
						v18 /= 2
					end
				end

				if v14 < v18 and not child:GetAttribute("Last") then
					v14 = v18
				end

				if child:GetAttribute("Last") then
					v18 = math.max(v14 + 1, 6)
				end

				local v19 = math.clamp(grow, 0, 1)

				if v17 < v19 then
					v17 = v19
				end

				if child:GetAttribute("Last") then
					v19 = math.max(v19, v17)
				end

				SpawnExplo(child.Value, v18, v19, child:GetAttribute("Last"))
			end))
		end)
		local v14 = _maid:give(vfx.BlackCenter:Clone())
		v14:PivotTo(humanoidRootPart.CFrame)
		v14:ScaleTo(0.1)
		local FX = quickFX({
			FX = vfx.Shooting,
			Maid = object3._maid,
			Anchor = humanoidRootPart.CFrame
		})
		lifeScale({
			FX = FX,
			Scale = 0.5
		})
		FX:ScaleTo(3)

		if game.Players.LocalPlayer.Character ~= char then
			able({
				FX = FX,
				On = false
			})
		end

		local v16 = _maid:give(Instance.new("NumberValue"))
		v16.Value = v14:GetScale()
		_maid:giveTask(v16.Changed:Connect(function()
			v14:ScaleTo((math.clamp(v16.Value, 0.001, 1e999)))
		end))
		TweenService:Create(v16, TweenInfo.new(0.2, Enum.EasingStyle.Bounce), {
			Value = 1.2
		}):Play()
		v14.Parent = EFP
		task.delay(0.2, function()
			local lastTime = tick()

			while tick() - lastTime < 5 do
				local flag

				if v7 or not bind or not bind.Parent or bind:GetAttribute("finished") then
					v7 = true
					flag = true
				else
					flag = false
				end

				if flag then
					break
				end

				v14:PivotTo(humanoidRootPart.CFrame)
				v14:ScaleTo(random:NextNumber(1, 1.2))
				FX:PivotTo(humanoidRootPart.CFrame)
				dtwait(0.02)
			end

			TweenService:Create(v16, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
				Value = 0.01
			}):Play()
			Debris:AddItem(v14, 0.5)
			able({
				FX = FX,
				On = false
			})
		end)

		local function og()
			local v17 = _maid:give(vfx["GammaRayBurst MeshEmitter2"]:Clone())
			local v18 = object2[v17]
			v17:PivotTo(humanoidRootPart.CFrame * v18 * CFrame.new(0, -65, 0))
			local v19 = MoonEmitter.new(v17)
			v19:Play()
			task.delay(0.1, function()
				v19:SetSpeed(0.82)
			end)
			v19:AddFrameEvent(function()
				v17:Destroy()
				v19:Destroy()
			end, 441)
			local v20 = humanoidRootPart.CFrame * CFrame.new(0, -63.9896550179, 0)
			local identity = CFrame.identity
			_maid:giveTask(bind:GetAttributeChangedSignal("Shot"):Connect(function()
				local cFrame = humanoidRootPart.CFrame
				local _, v21, _ = cFrame:ToOrientation()
				local cframe4 = CFrame.Angles(0, v21, 0)
				local v22 = CFrame.new(v20.Position) * cframe4 * v18 * identity
				v20 = cFrame
				identity = (CFrame.new(v20.Position) * cframe4 * v18):Inverse() * v22
			end))
			local folders = {}
			task.spawn(function()
				local lastTime = tick()
				local parent = nil
				local v22 = nil
				local v23 = 0.016666666666666666
				local lastTime2 = nil

				while tick() - lastTime < 5 and bind.Parent do
					local flag

					if v7 or not bind or not bind.Parent or bind:GetAttribute("finished") then
						v7 = true
						flag = true
					else
						flag = false
					end

					if flag then
						break
					end

					local cFrame = humanoidRootPart.CFrame
					local position = cFrame.Position
					local orientation, v24, _ = cFrame:ToOrientation()
					local lookVector = cFrame.LookVector
					local v25 = math.acos((math.clamp((v22 or lookVector):Dot(lookVector), -1, 1))) / math.max(
						v23,
						0.001
					)

					if v25 < 0.15 then
						v9 = math.min(v9 + v23 / 0.8, 1)
					else
						v9 = math.max(v9 - v23 / 0.6, 0)
					end

					local shot = bind:GetAttribute("Shot")

					if not lastTime2 and shot then
						lastTime2 = tick()
						v9 = 0
						parent = _maid:give(Instance.new("Part"))
						parent.Anchored = true
						parent.CanCollide = false
						parent.CanQuery = false
						parent.CanTouch = false
						parent.Transparency = 1
						parent.Size = createVector(1, 1, 1)
						parent.CFrame = humanoidRootPart.CFrame
						parent.Parent = EFP
						local sound = Instance.new("Sound")
						sound.SoundId = "rbxassetid://104444908855246"
						sound.Volume = 0
						local TweenService2 = game:GetService("TweenService")
						TweenService2:Create(
							sound,
							TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Volume = 3.25
							}
						):Play()
						sound.RollOffMinDistance = 25
						sound.RollOffMaxDistance = 140
						sound.RollOffMode = Enum.RollOffMode.Inverse
						sound.Parent = parent
						sound:Play()
						local sound2 = Instance.new("Sound")
						sound2.SoundId = "rbxassetid://83909974396311"
						sound2.Volume = 0
						local TweenService3 = game:GetService("TweenService")
						TweenService3:Create(
							sound2,
							TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Volume = 3
							}
						):Play()
						sound2.RollOffMinDistance = 25
						sound2.RollOffMaxDistance = 220
						sound2.RollOffMode = Enum.RollOffMode.Inverse
						sound2.Parent = parent
						sound2:Play()

						if char ~= game.Players.LocalPlayer.Character then
							sound2.RollOffMode = Enum.RollOffMode.LinearSquare
							sound2.RollOffMaxDistance = 600
						end
					end

					bind:SetAttribute("Heavy", v9)
					bind:SetAttribute("Rate", v25)
					local v26 = 1

					if lastTime2 then
						local v27 = tick() - lastTime2

						if v27 < 0.035 then
							v26 = 5
						elseif v27 < 0.175 then
							v26 = 1 + 3 * (1 - (v27 - 0.025) / 0.15)
						end
					end

					local v27 = v23 * (1 - v9 * 0.7) * v26
					local _ = CFrame.new(position.X, char.PrimaryPart.Position.Y, position.Z) * CFrame.Angles(0, v24, 0) * CFrame.Angles(
						not shot and 0 or orientation,
						0,
						0
					) * identity
					v19:SetAnchor(v19:GetAnchor():Lerp(humanoidRootPart:GetPivot(), 1 - 3.84e-6 ^ v27))

					if parent then
						local anchor = v19:GetAnchor()
						local v28 = math.clamp(
							(workspace.CurrentCamera.CFrame.Position - anchor.Position):Dot(anchor.LookVector),
							-1874,
							1874
						)
						parent.Position = anchor.Position + anchor.LookVector * v28
					end

					v22 = lookVector

					for i = 1, #folders do
						local v28 = folders[i]

						if v28.Name == "Shoot" then
							v28:PivotTo(humanoidRootPart.CFrame * cframe)
						elseif v28.Name == "Explosion" then
							v28:PivotTo(v28:GetPivot():lerp(
								humanoidRootPart.CFrame * v28:GetAttribute("Offset"):Inverse(),
								1 - 3.84e-6 ^ v27
							))
						else
							v28:PivotTo(cFrame * object2[v28])
						end
					end

					v23 = renderStepped:Wait()
				end

				if parent then
					game.Debris:AddItem(parent, 0.6)

					if parent:FindFirstChildOfClass("Sound") then
						for _, sound in pairs(parent:GetChildren()) do
							if not sound:IsA("Sound") then
								continue
							end

							local TweenService2 = game:GetService("TweenService")
							TweenService2:Create(
								sound,
								TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Volume = 0
								}
							):Play()
						end
					end
				end
			end)
			object3.modelgroup = v19.Model
			v17.Parent = EFP
			v19:SetTime(4.45)
			return FrameMarker.new({
				Framerate = 60
			}):Chain({
				[1] = function()
					local folder = quickFX({
						FX = vfx.Explosion,
						Maid = _maid,
						Anchor = humanoidRootPart.CFrame
					})

					for _, emitter in pairs(folder:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:SetAttribute("EmitDuration", emitter:GetAttribute("EmitDuration") + 0.65)
						end
					end

					shared.vfx.emit(folder)
					folders[#folders + 1] = folder
					v10 = true
					task.delay(3.25, function()
						v10 = false
					end)
					task.spawn(function()
						local lastTime = tick()
						local lastTime2 = tick()
						local v21 = {}
						local v22 = nil
						local clone2 = nil
						local lastTime3 = nil
						local count2 = 0
						local now = 0
						local number = random:NextNumber(0.015, 0.03)

						local function boom(p2)
							lastTime3 = tick()

							if p2 then
							end
						end

						local function fade(instance)
							local v23 = v21[instance]

							if v23 and not v23.Fading then
								TweenService:Create(instance.PrimaryPart.Decal, tweenInfo, {
									Color3 = color2
								}):Play()
								v23.Pending = true
								task.delay(2, function()
									if v23.Pending == true and not v23.Fading then
										local GUID = HttpService:GenerateGUID()
										v23.Fading = GUID
										TweenService:Create(instance.PrimaryPart.Decal, tweenInfo2, {
											Transparency = 1
										}):Play()
										task.wait(4)

										if v21[instance] and v23.Fading == GUID then
											instance:Destroy()
										end
									end
								end)
							end
						end

						task.wait(0.085)
						local flag

						if v7 or not bind or not bind.Parent or bind:GetAttribute("finished") then
							v7 = true
							flag = true
						else
							flag = false
						end

						if flag then
							return
						end

						while tick() - lastTime2 < 5 and v10 do
							local anchor = v19:GetAnchor()
							local raycastResult = game.Workspace:Raycast(
								anchor.Position,
								anchor.LookVector * 550,
								raycastParams
							)

							if raycastResult and shared.OnScreen(anchor.Position) then
								local position = raycastResult.Position
								local vector2 = v22 and v22 - position
								local v23 = vector2 and vector2:Dot(vector2)

								if v22 and not (v23 >= 400) then
									if clone2 then
										clone2:ScaleTo((math.clamp(clone2:GetScale() + 0.035, 1, 3.5)))
										clone2.PrimaryPart.Decal.Color3 = color
										clone2:PivotTo(clone2:GetPivot() * CFrame.Angles(
											0,
											math.rad((random:NextNumber(-4, 4))),
											0
										))
									end
								else
									if v22 and v23 >= 1600 then
										lastTime3 = tick()
									end

									local normal = raycastResult.Normal
									clone2 = burn:Clone()
									clone2:PivotTo(CFrame.new(position, position + normal) * v * CFrame.Angles(
										0,
										random:NextNumber(-4, 4),
										0
									))
									clone2:ScaleTo(random:NextNumber(1.5, 2))
									clone2.Parent = EFP
									v21[clone2] = {
										Time = tick()
									}
									count2 += 1

									if tick() - lastTime <= 0.0365 and tick() - lastTime >= 0.055 then
										SpawnExplo(CFrame.new(position, position + normal), 1, 0, false, true)
									end

									local Y = normal.Y

									if Y ~= 1 and Y ~= 0 then
										clone2.PrimaryPart.Decal.Transparency = 1
									end

									v22 = position
								end

								if tick() - lastTime2 < 0.3 and number <= tick() - now then
									now = tick()
									number = random:NextNumber(0.03, 0.05)
									local normal = raycastResult.Normal
									local v24 = position + normal * 3

									if normal.Y > 0.5 then
										v24 -= createVector(0, 2, 0)
									end

									SpawnExplo(
										CFrame.new(v24, v24 + normal) * CFrame.Angles(-1.5707963267948966, 0, 0),
										math.min(
											random:NextNumber(1.2, 3.9) / random:NextNumber(1.05, 1.55) / 1.05 / 1.15,
											4.3
										),
										0,
										false
									)
								end

								if not lastTime3 or tick() - lastTime3 > 0.3 then
									lastTime3 = tick()
								end

								local v24 = clone2 and math.clamp(clone2:GetScale() + 0.035, 1, 3.5)

								for k, v25 in pairs(v21) do
									local vector3 = position - k:GetPivot().Position

									if vector3:Dot(vector3) <= 900 then
										v25.Pending = nil
										v25.Fading = nil
										v25.Time = tick()
										k:ScaleTo(v24)
										k.PrimaryPart.Decal.Color3 = color
										k:PivotTo(k:GetPivot() * CFrame.Angles(
											0,
											math.rad((random:NextNumber(-4, 4))),
											0
										))
									elseif not v25.Pending then
										fade(k)
									end
								end
							else
								for k in pairs(v21) do
									fade(k)
								end
							end

							dtwait(0.03)
						end

						for k in pairs(v21) do
							fade(k)
						end

						if clone2 then
							lastTime3 = tick()
							local decal = clone2.PrimaryPart.Decal
							TweenService:Create(decal, tweenInfo, {
								Color3 = color2
							}):Play()
							task.delay(2, function()
								TweenService:Create(decal, tweenInfo2, {
									Transparency = 1
								}):Play()
								Debris:AddItem(clone2, 4)
							end)
						end
					end)
				end,
				[4] = function() end
			})
		end

		og()
	end

	task.spawn(ShootEvent)
	task.wait(10)
	Clean() -- equivalent call inferred; original call site unknown
end

return V2Port