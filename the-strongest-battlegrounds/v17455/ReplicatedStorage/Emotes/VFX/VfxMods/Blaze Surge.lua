local createVector = vector.create
game:GetService("Players")
local thrown = game.Workspace.Thrown
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Utility = require(ReplicatedStorage.Utility)

-- equivalent calls inferred from this helper; original call sites unknown
local function safeDestroy(clone, value)
	if not clone then
		return
	end

	task.delay(value or 10, function()
		pcall(function()
			if clone and clone.Parent then
				clone:Destroy()
			end
		end)
	end)
end

local function bindRenderStep(p, p2, p3)
	RunService:BindToRenderStep(p, p2, p3)
	task.delay(10, function()
		pcall(function()
			RunService:UnbindFromRenderStep(p)
		end)
	end)
end

local function destroyAfter(p, value)
	if not p then
		return
	end

	safeDestroy(true, value) -- equivalent call inferred; original call site unknown
end

local v = {
	Template = {
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		""
	},
	Smoke = {
		"rbxassetid://13735994555",
		"rbxassetid://13735994329",
		"rbxassetid://13735994088",
		"rbxassetid://13735993891",
		"rbxassetid://13735993653",
		"rbxassetid://13735993408",
		"rbxassetid://13735993175",
		"rbxassetid://13735992929",
		"rbxassetid://13735992652",
		"rbxassetid://13735992472",
		"rbxassetid://13735992275",
		"rbxassetid://13735992130",
		"rbxassetid://13735992021",
		"rbxassetid://13735991916",
		"rbxassetid://13735991803"
	},
	Wind = {
		"rbxassetid://13742829638",
		"rbxassetid://13742829390",
		"rbxassetid://13742829165",
		"rbxassetid://13742828951",
		"rbxassetid://13742828717",
		"rbxassetid://13742828516",
		"rbxassetid://13742828321",
		"rbxassetid://13742828082",
		"rbxassetid://13742827785",
		"rbxassetid://13742827447",
		"rbxassetid://13742827222",
		"rbxassetid://13742826910",
		"rbxassetid://13742826580",
		"rbxassetid://13742826259",
		"rbxassetid://13742825975",
		"rbxassetid://13742825732"
	},
	WindLoop = {
		"rbxassetid://13805669985",
		"rbxassetid://13805669908",
		"rbxassetid://13805669781",
		"rbxassetid://13805669577",
		"rbxassetid://13805669433",
		"rbxassetid://13805669336",
		"rbxassetid://13805669241",
		"rbxassetid://13805669109",
		"rbxassetid://13805668976",
		"rbxassetid://13805668841",
		"rbxassetid://13805668724",
		"rbxassetid://13805668578",
		"rbxassetid://13805668443",
		"rbxassetid://13805668253",
		"rbxassetid://13805668132",
		"rbxassetid://13805668032",
		"rbxassetid://13805667915"
	},
	Wind2 = {
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		""
	},
	Wind3 = {
		"rbxassetid://13816297914",
		"rbxassetid://13816297843",
		"rbxassetid://13816297756",
		"rbxassetid://13816297645",
		"rbxassetid://13816297535",
		"rbxassetid://13816297410",
		"rbxassetid://13816297304",
		"rbxassetid://13816297199",
		"rbxassetid://13816297107",
		"rbxassetid://13816297011",
		"rbxassetid://13816296882",
		"rbxassetid://13816296754",
		"rbxassetid://13816296647",
		"rbxassetid://13816296564",
		"rbxassetid://13816296367",
		"rbxassetid://13816296239",
		"rbxassetid://13816296108"
	},
	RadialCharge = {
		"rbxassetid://14865172329",
		"rbxassetid://14865171836",
		"rbxassetid://14865171296",
		"rbxassetid://14865170866",
		"rbxassetid://14865170494",
		"rbxassetid://14865170044",
		"rbxassetid://14865169629",
		"rbxassetid://14865169321",
		"rbxassetid://14865168985",
		"rbxassetid://14865168535",
		"rbxassetid://14865168119",
		"rbxassetid://14865167680",
		"rbxassetid://14865167367",
		"rbxassetid://14865167016",
		"rbxassetid://14865166635",
		"rbxassetid://14865166207",
		"rbxassetid://14865165861",
		"rbxassetid://14865165408",
		"rbxassetid://14865165069",
		"rbxassetid://14865164746",
		"rbxassetid://14865164380",
		"rbxassetid://14865163975",
		"rbxassetid://14865163588",
		"rbxassetid://14865163272"
	},
	RadialCharge2 = {
		"rbxassetid://14870367453",
		"rbxassetid://14870366710",
		"rbxassetid://14870366294",
		"rbxassetid://14870365808",
		"rbxassetid://14870365263",
		"rbxassetid://14870364775",
		"rbxassetid://14870364192",
		"rbxassetid://14870363807",
		"rbxassetid://14870362992",
		"rbxassetid://14870362589",
		"rbxassetid://14870362157",
		"rbxassetid://14870361548",
		"rbxassetid://14870360993",
		"rbxassetid://14870360357",
		"rbxassetid://14870359754",
		"rbxassetid://14870359204",
		"rbxassetid://14870358634",
		"rbxassetid://14870358002",
		"rbxassetid://14870357536",
		"rbxassetid://14870357089",
		"rbxassetid://14870356671",
		"rbxassetid://14870356209",
		"rbxassetid://14870356209",
		"rbxassetid://14870355338"
	},
	Slash = {
		"rbxassetid://14953159623",
		"rbxassetid://14953159136",
		"rbxassetid://14953158774",
		"rbxassetid://14953158458",
		"rbxassetid://14953158153",
		"rbxassetid://14953157758",
		"rbxassetid://14953157440",
		"rbxassetid://14953157019",
		"rbxassetid://14953156467",
		"rbxassetid://14953155971",
		"rbxassetid://14953155569",
		"rbxassetid://14953155328",
		"rbxassetid://14953155090"
	},
	SBWindRing = {
		"rbxassetid://15060477390",
		"rbxassetid://15060477211",
		"rbxassetid://15060477046",
		"rbxassetid://15060476918",
		"rbxassetid://15060476772",
		"rbxassetid://15060476587",
		"rbxassetid://15060476425",
		"rbxassetid://15060476227",
		"rbxassetid://15060475992",
		"rbxassetid://15060475789",
		"rbxassetid://15060475607",
		"rbxassetid://15060475461",
		"rbxassetid://15060475290"
	},
	SBGradWindRing = {
		"rbxassetid://15061587522",
		"rbxassetid://15061587101",
		"rbxassetid://15061586757",
		"rbxassetid://15061586410",
		"rbxassetid://15061586108",
		"rbxassetid://15061585751",
		"rbxassetid://15061585475",
		"rbxassetid://15061585138",
		"rbxassetid://15061584906",
		"rbxassetid://15061584637",
		"rbxassetid://15061584388",
		"rbxassetid://15061584150",
		"rbxassetid://15061583876",
		"rbxassetid://15061583632",
		"rbxassetid://15061583421",
		"rbxassetid://15061583250",
		"rbxassetid://15061583064",
		"rbxassetid://15061582885",
		"rbxassetid://15061582745",
		"rbxassetid://15061582564",
		"rbxassetid://15061582294",
		"rbxassetid://15061582148",
		"rbxassetid://15061582017",
		"rbxassetid://15061581873",
		"rbxassetid://15061581667"
	},
	WindRingGrad = {
		"rbxassetid://15090123805",
		"rbxassetid://15090123582",
		"rbxassetid://15090123292",
		"rbxassetid://15090123026",
		"rbxassetid://15090122812",
		"rbxassetid://15090122483",
		"rbxassetid://15090122275",
		"rbxassetid://15090122092",
		"rbxassetid://15090121872",
		"rbxassetid://15090121711",
		"rbxassetid://15090121515",
		"rbxassetid://15090121342",
		"rbxassetid://15090121110",
		"rbxassetid://15090120898",
		"rbxassetid://15090120750",
		"rbxassetid://15090120590",
		"rbxassetid://15090120408",
		"rbxassetid://15090120231",
		"rbxassetid://15090120032",
		"rbxassetid://15090119797",
		"rbxassetid://15090119647",
		"rbxassetid://15090119515",
		"rbxassetid://15090119390",
		"rbxassetid://15090119251"
	},
	GradientRing = {
		"rbxassetid://15090165930",
		"rbxassetid://15090165646",
		"rbxassetid://15090165373",
		"rbxassetid://15090165187",
		"rbxassetid://15090164937",
		"rbxassetid://15090164749",
		"rbxassetid://15090164564",
		"rbxassetid://15090164326",
		"rbxassetid://15090164086",
		"rbxassetid://15090163929",
		"rbxassetid://15090163779",
		"rbxassetid://15090163608",
		"rbxassetid://15090163385",
		"rbxassetid://15090163268",
		"rbxassetid://15090163081",
		"rbxassetid://15090162894",
		"rbxassetid://15090162651",
		"rbxassetid://15090162457",
		"rbxassetid://15090162325",
		"rbxassetid://15090162178",
		"rbxassetid://15090162030",
		"rbxassetid://15090161885",
		"rbxassetid://15090161738",
		"rbxassetid://15090161557"
	}
}
local BoatTween = require(game.ReplicatedStorage.BoatTween)
local blazeSurge = script["Blaze Surge"]
local _ = workspace.CurrentCamera
local BlazeSurge = {}

function BlazeSurge.Charge(p)
	local char = p.Data.Char
	local clone = blazeSurge.EnergyBall:Clone()
	clone.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 1, -2.5)
	clone.Parent = thrown
	local v2 = 15

	if clone then
		safeDestroy(true, v2) -- equivalent call inferred; original call site unknown
	end

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(1)
		end
	end

	local clone2 = blazeSurge.ElectricityGround:Clone()
	clone2.Parent = thrown
	local v3 = 15

	if clone2 then
		safeDestroy(true, v3) -- equivalent call inferred; original call site unknown
	end

	task.delay(1.5, function()
		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { thrown, char, clone2 }
	local raycastResult = workspace:Raycast(char.HumanoidRootPart.Position, createVector(0, -10, 0), raycastParams)

	if raycastResult and raycastResult.Position then
		clone2.Position = raycastResult.Position
	end

	RunService:BindToRenderStep("BeamSpin", Enum.RenderPriority.Camera.Value, function()
		if clone2 and clone2.Parent then
			clone2.CFrame *= CFrame.Angles(0, 0.08726646259971647, 0)
		else
			RunService:UnbindFromRenderStep("BeamSpin")
		end
	end)
	local v4 = "BeamSpin"
	task.delay(10, function()
		pcall(function()
			RunService:UnbindFromRenderStep(v4)
		end)
	end)
	local v5 = {}

	for _, beam in pairs(clone2:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		local attachment0 = beam.Attachment0
		local attachment1 = beam.Attachment1
		table.insert(v5, {
			TheAtch = attachment1,
			NewPos = attachment1.Position,
			FirstPos = attachment0.Position
		})
	end

	for _, v6 in pairs(v5) do
		v6.TheAtch.Position = v6.FirstPos
		TweenService:Create(v6.TheAtch, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Position = v6.NewPos
		}):Play()
	end

	for _, beam in pairs(clone2:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		beam.CurveSize0 = 0
		beam.CurveSize1 = 3
		local v6 = BoatTween:Create(beam, {
			Time = 2,
			EasingStyle = "Sine",
			EasingDirection = "Out",
			StepType = "RenderStepped",
			Goal = {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.936, 1),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Width0 = 5,
				CurveSize0 = -1,
				CurveSize1 = 3
			}
		})
		v6:Play()
		local v7 = 2

		if not v6 then
			continue
		end

		safeDestroy(true, v7) -- equivalent call inferred; original call site unknown
	end

	shared.sfx({
		SoundId = "rbxassetid://121324904492006",
		Parent = char.PrimaryPart,
		Volume = 2.85
	}):Play()
	task.wait(1)
	task.wait(1)

	if clone2 and clone2.Parent then
		clone2.Smoke.Enabled = false
		clone2.Smoke2.Enabled = false
		clone2.Smoke3.Enabled = false
		clone2.Smoke4.Enabled = false
	end

	RunService:UnbindFromRenderStep("BeamSpin")
	local v6 = 0.05

	if clone then
		safeDestroy(true, v6) -- equivalent call inferred; original call site unknown
	end

	safeDestroy(clone2, 2) -- equivalent call inferred; original call site unknown
end

function BlazeSurge.Shoot(p)
	local data = p.Data
	local anchor = data.Anchor
	local char = data.Char
	local _ = data.Bind
	local hitbox = data.Hitbox
	local _ = game.Players.LocalPlayer.Character == char
	shared.sfx({
		SoundId = "rbxassetid://94612607119590",
		Parent = char.PrimaryPart,
		Volume = 2.85
	}):Play()
	local clone = blazeSurge.EnergyShoot:Clone()
	local v2 = 15

	if clone then
		safeDestroy(true, v2) -- equivalent call inferred; original call site unknown
	end

	clone.CFrame = anchor * CFrame.Angles(0, 3.141592653589793, 0)
	clone.Parent = thrown
	Utility.EmitAllParticles(clone)
	task.wait(0.05)
	local clone2 = blazeSurge.EnergyBallProjectile:Clone()
	local v3 = 15

	if clone2 then
		safeDestroy(true, v3) -- equivalent call inferred; original call site unknown
	end

	task.delay(15, function()
		pcall(function()
			RunService:UnbindFromRenderStep("ProjectileBeam")
		end)
	end)
	clone2.CFrame = anchor * CFrame.Angles(0, 3.141592653589793, 0)
	clone2.Anchored = true
	clone2.Parent = thrown
	local objectValue = Instance.new("ObjectValue")
	objectValue.Value = clone2
	objectValue.Parent = char
	local v4 = 15

	if objectValue then
		safeDestroy(true, v4) -- equivalent call inferred; original call site unknown
	end

	local worldCFrame = clone2.Attachment1.WorldCFrame

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(1)
		end
	end

	RunService:BindToRenderStep("ProjectileBeam", Enum.RenderPriority.Camera.Value, function()
		if hitbox and hitbox.Parent then
			if clone2 and clone2.Parent and hitbox and hitbox.Parent and clone2:FindFirstChild("Attachment1") then
				clone2:PivotTo(clone2:GetPivot():Lerp(hitbox:GetPivot(), 0.1))
				clone2.Attachment1.WorldCFrame = worldCFrame
			else
				RunService:UnbindFromRenderStep("ProjectileBeam")
			end
		else
			RunService:UnbindFromRenderStep("ProjectileBeam")

			if clone2 and clone2.Parent then
				clone2:Destroy()
			end
		end
	end)
	local v5 = "ProjectileBeam"
	task.delay(10, function()
		pcall(function()
			RunService:UnbindFromRenderStep(v5)
		end)
	end)
	TweenService:Create(clone2.Attachment1.Beam, TweenInfo.new(1, Enum.EasingStyle.Linear), {
		Width1 = 2.5,
		TextureLength = 50
	}):Play()
	TweenService:Create(clone2.AttachmentA2, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		WorldCFrame = char.HumanoidRootPart.CFrame * CFrame.new(15, 5.25, 30)
	}):Play()
	TweenService:Create(clone2.AttachmentB2, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		WorldCFrame = char.HumanoidRootPart.CFrame * CFrame.new(-15, 5.25, 30)
	}):Play()
	BoatTween:Create(clone2.Attachment1.Beam, {
		Time = 1,
		EasingStyle = "Quad",
		EasingDirection = "In",
		StepType = "RenderStepped",
		Goal = {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.5, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
		}
	}):Play()
	BoatTween:Create(clone2.AttachmentA2.Beam1, {
		Time = 1.25,
		EasingStyle = "Quad",
		EasingDirection = "In",
		StepType = "RenderStepped",
		Goal = {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.5, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
		}
	}):Play()
	BoatTween:Create(clone2.AttachmentA2.Beam2, {
		Time = 1.25,
		EasingStyle = "Quad",
		EasingDirection = "In",
		StepType = "RenderStepped",
		Goal = {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.5, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
		}
	}):Play()
	BoatTween:Create(clone2.AttachmentB2.Beam1, {
		Time = 1.25,
		EasingStyle = "Quad",
		EasingDirection = "In",
		StepType = "RenderStepped",
		Goal = {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.5, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
		}
	}):Play()
	BoatTween:Create(clone2.AttachmentB2.Beam2, {
		Time = 1.25,
		EasingStyle = "Quad",
		EasingDirection = "In",
		StepType = "RenderStepped",
		Goal = {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.5, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
		}
	}):Play()

	if hitbox and hitbox.Parent then
		hitbox.Destroying:Wait()
	end

	RunService:UnbindFromRenderStep("ProjectileBeam")

	if clone and clone.Parent then
		clone:Destroy()
	end

	if clone2 and clone2.Parent then
		clone2.Anchored = true

		for _, effect in pairs(clone2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = false
			end

			if not (effect:IsA("Beam") and effect.Parent.Name ~= "Attachment1" and effect.Parent.Name ~= "AttachmentA2" and effect.Parent.Name ~= "AttachmentB2") then
				continue
			end

			effect.Enabled = false
		end

		local attachment1 = clone2:FindFirstChild("Attachment1")

		if attachment1 and attachment1:FindFirstChild("Beam") then
			attachment1.Beam.Enabled = false
		end

		clone2:Destroy()
	end
end

function BlazeSurge.Boom(p)
	local WAIT_INTERVAL = 0.1
	local DELAY_DURATION = 10
	local DISTANCE_THRESHOLD = 200
	local data = p.Data
	local char = data.Char
	local v2 = game.Players.LocalPlayer.Character == char
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { game.Workspace.Map, game.Workspace.Built }
	local pos = {
		Position = data.Pos
	}
	local clone = blazeSurge.Blast1:Clone()
	local v4 = 15

	if clone then
		safeDestroy(true, v4) -- equivalent call inferred; original call site unknown
	end

	clone:SetPrimaryPartCFrame(CFrame.new(pos.Position))
	clone.Parent = thrown
	shared.sfx({
		SoundId = "rbxassetid://85479042220223",
		CFrame = clone:GetPivot(),
		Volume = 1.85,
		RollOffMaxDistance = 1500,
		RollOffMinDistance = 100
	}):Play()
	shared.sfx({
		SoundId = "rbxassetid://124079780435118",
		CFrame = clone:GetPivot(),
		RollOffMaxDistance = 1500,
		RollOffMinDistance = 100,
		Volume = 1.85
	}):Play()
	local v5 = {
		sent = char,
		pos = pos
	}
	local sent = v5.sent
	local position = v5.pos.Position
	local character = game.Players.LocalPlayer.Character
	local v6

	if character and character.PrimaryPart then
		v6 = character == sent or ((character.PrimaryPart.Position - position).Magnitude < DISTANCE_THRESHOLD or nil)
	end

	if v6 then
		local v7 = {
			sent = char,
			pos = pos
		}
		local sent2 = v7.sent
		local position2 = v7.pos.Position
		local character2 = game.Players.LocalPlayer.Character
		local v8

		if character2 and character2.PrimaryPart then
			v8 = character2 == sent2 or ((character2.PrimaryPart.Position - position2).Magnitude < DISTANCE_THRESHOLD or nil)
		end

		if v8 then
			task.spawn(function()
				for _ = 1, 3 do
					shared.repfire({
						Effect = "Camshake",
						Intensity = 1,
						Last = 3
					})
					task.wait(0.4)
				end
			end)
		end
	end

	clone.Blast1.Layer3.CFrame = CFrame.lookAt(clone.Blast1.Layer3.Position, char.HumanoidRootPart.Position)
	clone.Blast1.Layer3.CFrame = clone.Blast1.Layer3.CFrame * CFrame.Angles(0, 0, -0.4363323129985824)
	clone.Blast1.Layer3.Transparency = 1

	for _, part in pairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local size = part.Size
		part.Size = Vector3.new(part.Size.X / 2, part.Size.Y * 3, part.Size.Z / 2)
		TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			Size = size
		}):Play()
	end

	Utility.EmitAllParticles(clone)
	clone.Blast1.Attachment.Star:Emit(5)
	local colorCorrectionEffect

	if v2 then
		colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Brightness = 1
		colorCorrectionEffect.Contrast = -5
		colorCorrectionEffect.Saturation = -1
		colorCorrectionEffect.TintColor = Color3.fromRGB(255, 25, 25)
		TweenService:Create(
			colorCorrectionEffect,
			TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				Brightness = 1,
				Contrast = -5,
				Saturation = -1,
				TintColor = Color3.fromRGB(255, 50, 50)
			}
		):Play()
		colorCorrectionEffect.Parent = game.Lighting
		local v7 = 15

		if colorCorrectionEffect then
			safeDestroy(true, v7) -- equivalent call inferred; original call site unknown
		end
	end

	task.wait(WAIT_INTERVAL)

	if colorCorrectionEffect then
		colorCorrectionEffect.Enabled = false
		colorCorrectionEffect.Brightness = 0
		colorCorrectionEffect.Contrast = 0
		colorCorrectionEffect.Saturation = 0
		colorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
	end

	clone.Blast1.Layer3.Transparency = 0.05
	RunService:BindToRenderStep("BlastSpin", Enum.RenderPriority.Camera.Value, function()
		if not (clone and clone.Parent) then
			RunService:UnbindFromRenderStep("BlastSpin")
			return
		end

		clone.Blast1.Layer3.CFrame = clone.Blast1.Layer3.CFrame * CFrame.Angles(0, 0.4363323129985824, 0)
		local number = Random.new():NextNumber(13, 25)
		clone.Blast1.Size = Vector3.new(number, number, number)
		local number2 = Random.new():NextNumber(33, 37)
		clone.Blast1.Layer2.Size = Vector3.new(number2, number2, number2)
		local number3 = Random.new():NextNumber(15, 19)
		clone.Blast1.Layer3.Mesh.Scale = Vector3.new(number3, number3, number3)
		local number4 = Random.new():NextNumber(38, 42)
		clone.Blast1.Layer4.Size = Vector3.new(number4, number4, number4)
	end)
	local v7 = "BlastSpin"
	task.delay(DELAY_DURATION, function()
		pcall(function()
			RunService:UnbindFromRenderStep(v7)
		end)
	end)
	task.wait(0.9)
	local clone2 = blazeSurge.Blast1ImpactFrame:Clone()
	local v8 = 15

	if clone2 then
		safeDestroy(true, v8) -- equivalent call inferred; original call site unknown
	end

	clone2.CFrame = clone.Blast1.CFrame
	clone2.Parent = thrown
	Utility.EmitAllParticles(clone2)

	if colorCorrectionEffect then
		colorCorrectionEffect.Enabled = true
		TweenService:Create(
			colorCorrectionEffect,
			TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				Brightness = 1,
				Contrast = -5,
				Saturation = -1,
				TintColor = Color3.fromRGB(255, 50, 50)
			}
		):Play()
	end

	RunService:UnbindFromRenderStep("BlastSpin")

	if clone and clone.Parent then
		clone:Destroy()
	end

	task.wait(WAIT_INTERVAL)

	if v2 and colorCorrectionEffect then
		colorCorrectionEffect.Enabled = false
		colorCorrectionEffect.Brightness = 0
		colorCorrectionEffect.Contrast = 0
		colorCorrectionEffect.Saturation = 0
		colorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
	end

	if clone2 and clone2.Parent then
		clone2:Destroy()
	end

	local clone3 = blazeSurge.Blast2:Clone()
	local v9 = 15

	if clone3 then
		safeDestroy(true, v9) -- equivalent call inferred; original call site unknown
	end

	clone3:SetPrimaryPartCFrame(CFrame.new(pos.Position) * CFrame.new(0, 20, 0))
	clone3.Layer5.CFrame = CFrame.lookAt(clone3.Layer5.Position, char.HumanoidRootPart.Position)
	clone3.Parent = thrown
	Utility.EmitAllParticles(clone3)
	local v10 = {
		sent = char,
		pos = pos
	}
	local sent2 = v10.sent
	local position2 = v10.pos.Position
	local character2 = game.Players.LocalPlayer.Character
	local v11

	if character2 and character2.PrimaryPart then
		v11 = character2 == sent2 or ((character2.PrimaryPart.Position - position2).Magnitude < DISTANCE_THRESHOLD or nil)
	end

	if v11 then
		task.spawn(function()
			for _ = 1, 3 do
				shared.repfire({
					Effect = "Camshake",
					Intensity = 10,
					Last = 3
				})
				task.wait(0.4)
			end
		end)
	end

	local clone4 = blazeSurge.GroundWinds1:Clone()
	local v12 = 15

	if clone4 then
		safeDestroy(true, v12) -- equivalent call inferred; original call site unknown
	end

	clone4.CFrame = clone3.Layer1.CFrame * CFrame.new(0, -10, 0) * CFrame.Angles(3.141592653589793, 0, 0)
	clone4.CFrame = CFrame.new(
		clone4.Position,
		(Vector3.new(char.HumanoidRootPart.Position.X, clone4.Position.Y, char.HumanoidRootPart.Position.Z))
	) * CFrame.Angles(3.141592653589793, 0, 0)
	clone4.Parent = thrown
	local clone5 = blazeSurge.WindMesh1:Clone()
	local v13 = 15

	if clone5 then
		safeDestroy(true, v13) -- equivalent call inferred; original call site unknown
	end

	clone5.CFrame = clone3.PrimaryPart.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(
		0,
		math.rad((Random.new():NextNumber(-180, 180))),
		0
	)
	clone5.Parent = thrown
	TweenService:Create(clone5, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		CFrame = clone5.CFrame * CFrame.new(0, 30, 0)
	}):Play()
	TweenService:Create(clone5.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = createVector(-80, -80, -80)
	}):Play()
	local clone6 = blazeSurge.WindMesh2:Clone()
	local v14 = 15

	if clone6 then
		safeDestroy(true, v14) -- equivalent call inferred; original call site unknown
	end

	clone6.CFrame = clone3.PrimaryPart.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(
		3.141592653589793,
		math.rad((Random.new():NextNumber(-180, 180))),
		0
	)
	clone6.Parent = thrown
	TweenService:Create(clone6, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		CFrame = clone6.CFrame * CFrame.new(0, -60, 0)
	}):Play()
	TweenService:Create(clone6.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = createVector(-50, -50, -50)
	}):Play()
	Utility.EmitAllParticles(clone4)
	task.spawn(function()
		local lastTime = os.clock()
		pcall(function()
			while clone4 and clone4.Parent and os.clock() - lastTime < 15 do
				for i = 1, #v.WindLoop do
					if not clone4 or not clone4.Parent or os.clock() - lastTime >= 15 then
						return
					end

					clone4.Mesh.TextureId = v.WindLoop[i]
					RunService.RenderStepped:Wait()
				end
			end
		end)
	end)

	for _, descendant in pairs(clone3:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local size = descendant.Size
			descendant.Size = Vector3.new(descendant.Size.X / 3, descendant.Size.Y * 5, descendant.Size.Z / 3)
			TweenService:Create(descendant, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = size
			}):Play()
		end

		if not descendant:IsA("SpecialMesh") then
			continue
		end

		local scale = descendant.Scale
		descendant.Scale = Vector3.new(descendant.Scale.X / 3, descendant.Scale.Y * 5, descendant.Scale.Z / 3)
		TweenService:Create(descendant, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = scale
		}):Play()
	end

	task.wait(WAIT_INTERVAL)
	TweenService:Create(clone5, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {
		CFrame = clone5.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(
			0,
			math.rad((Random.new():NextNumber(180, 360))),
			0
		)
	}):Play()
	TweenService:Create(clone6, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {
		CFrame = clone6.CFrame * CFrame.new(0, -15, 0) * CFrame.Angles(
			0,
			math.rad((Random.new():NextNumber(180, 360))),
			0
		)
	}):Play()
	TweenService:Create(clone5.Mesh, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {
		Scale = createVector(-100, -85, -100)
	}):Play()
	TweenService:Create(clone6.Mesh, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {
		Scale = createVector(-75, -50, -75)
	}):Play()
	RunService:BindToRenderStep("BlastSpin", Enum.RenderPriority.Camera.Value, function()
		if not (clone3 and clone3.Parent) then
			RunService:UnbindFromRenderStep("BlastSpin")
			return
		end

		clone3.Layer5.CFrame = clone3.Layer5.CFrame * CFrame.Angles(0.08726646259971647, 0, 0)
		local number = Random.new():NextNumber(37, 53)
		clone3.Layer1.Size = Vector3.new(number, number, number)
		local number2 = Random.new():NextNumber(84, 94)
		clone3.Layer2.Size = Vector3.new(number2, number2, number2)
		local number3 = Random.new():NextNumber(100, 110)
		clone3.Layer3.Size = Vector3.new(number3, number3, number3)
		local number4 = Random.new():NextNumber(103, 113)
		clone3.Layer4.Size = Vector3.new(number4, number4, number4)
		local number5 = Random.new():NextNumber(42, 48)
		clone3.Layer5.Mesh.Scale = Vector3.new(number5, number5, number5)
	end)
	local v15 = "BlastSpin"
	task.delay(DELAY_DURATION, function()
		pcall(function()
			RunService:UnbindFromRenderStep(v15)
		end)
	end)
	task.wait(0.8)

	if clone5 and clone5.Parent then
		clone5:Destroy()
	end

	if clone6 and clone6.Parent then
		clone6:Destroy()
	end

	RunService:UnbindFromRenderStep("BlastSpin")

	if colorCorrectionEffect then
		colorCorrectionEffect.Enabled = true
	end

	if clone3 and clone3.Parent then
		for _, descendant in pairs(clone3:GetDescendants()) do
			if descendant:IsA("BasePart") then
				TweenService:Create(descendant, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Size = Vector3.new(descendant.Size.X * 10, descendant.Size.Y * 25, descendant.Size.Z * 10)
				}):Play()
			end

			if descendant:IsA("SpecialMesh") then
				descendant.Parent:Destroy()
			end

			if descendant:IsA("Beam") then
				descendant.Enabled = false
			end
		end
	end

	if colorCorrectionEffect then
		TweenService:Create(
			colorCorrectionEffect,
			TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				Brightness = 1,
				Contrast = -5,
				Saturation = -1,
				TintColor = Color3.fromRGB(25, 0, 0)
			}
		):Play()
	end

	task.wait(WAIT_INTERVAL)

	if clone3 and clone3.Parent then
		clone3:Destroy()
	end

	if colorCorrectionEffect then
		colorCorrectionEffect.Enabled = false
		colorCorrectionEffect.Brightness = 0
		colorCorrectionEffect.Contrast = 0
		colorCorrectionEffect.Saturation = 0
		colorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
	end

	if clone4 and clone4.Parent then
		clone4:Destroy()
	end

	local v16 = {
		sent = char,
		pos = pos
	}
	local sent3 = v16.sent
	local position3 = v16.pos.Position
	local character3 = game.Players.LocalPlayer.Character
	local v17

	if character3 and character3.PrimaryPart then
		v17 = character3 == sent3 or ((character3.PrimaryPart.Position - position3).Magnitude < DISTANCE_THRESHOLD or nil)
	end

	if v17 then
		task.spawn(function()
			for _ = 1, 3 do
				shared.repfire({
					Effect = "Camshake",
					Intensity = 15,
					Last = 3
				})
				task.wait(0.4)
			end
		end)
	end

	local blurEffect

	if v2 then
		blurEffect = Instance.new("BlurEffect")
		blurEffect.Size = 10
		blurEffect.Parent = game.Lighting
		local v18 = 15

		if blurEffect then
			safeDestroy(true, v18) -- equivalent call inferred; original call site unknown
		end

		TweenService:Create(blurEffect, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = 0
		}):Play()
		local bloomEffect = Instance.new("BloomEffect")
		bloomEffect.Parent = game.Lighting
		bloomEffect.Intensity = 20
		local v19 = 15

		if bloomEffect then
			safeDestroy(true, v19) -- equivalent call inferred; original call site unknown
		end

		TweenService:Create(bloomEffect, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Intensity = 0
		}):Play()
		local v20 = 0.8

		if bloomEffect then
			safeDestroy(true, v20) -- equivalent call inferred; original call site unknown
		end
	end

	local clone7 = blazeSurge.HUGEBEAM:Clone()
	local v18 = 15

	if clone7 then
		safeDestroy(true, v18) -- equivalent call inferred; original call site unknown
	end

	clone7:SetPrimaryPartCFrame(CFrame.new(pos.Position) * CFrame.new(0, 500, 0) * CFrame.Angles(
		0,
		0,
		-1.5707963267948966
	))
	clone7.Parent = thrown

	for _, descendant in pairs(clone7:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local size = descendant.Size
			descendant.Size = Vector3.new(descendant.Size.X / 2, descendant.Size.Y * 3, descendant.Size.Z / 2)
			TweenService:Create(descendant, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = size
			}):Play()
		end

		if not descendant:IsA("Beam") then
			continue
		end

		descendant.Enabled = false
		local v19 = descendant
		task.delay(0.1, function()
			if v19 and v19.Parent then
				v19.Enabled = true
			end
		end)
	end

	local clone8 = blazeSurge.GroundWinds2:Clone()
	local v19 = 15

	if clone8 then
		safeDestroy(true, v19) -- equivalent call inferred; original call site unknown
	end

	clone8.CFrame = clone7.Layer0.CFrame * CFrame.new(499, 0, 0) * CFrame.Angles(3.141592653589793, 0, 0)
	local cframe = CFrame.new(
		clone8.Position,
		(Vector3.new(char.HumanoidRootPart.Position.X, clone4.Position.Y, char.HumanoidRootPart.Position.Z))
	) * CFrame.Angles(3.141592653589793, 0, 0)
	local _, v20, _ = cframe:ToOrientation()
	clone8.CFrame = CFrame.new(cframe.Position) * CFrame.Angles(0, v20, 0) * CFrame.Angles(3.141592653589793, 0, 0)
	clone8.Parent = thrown
	Utility.EmitAllParticles(clone8)
	task.spawn(function()
		local lastTime = os.clock()
		pcall(function()
			while clone8 and clone8.Parent and os.clock() - lastTime < 15 do
				for i = 1, #v.WindLoop do
					if not clone8 or not clone8.Parent or os.clock() - lastTime >= 15 then
						return
					end

					clone8.Mesh.TextureId = v.WindLoop[i]
					RunService.RenderStepped:Wait()
				end
			end
		end)
	end)
	local clone9 = blazeSurge.WindMesh3:Clone()
	local v21 = 15

	if clone9 then
		safeDestroy(true, v21) -- equivalent call inferred; original call site unknown
	end

	clone9.Transparency = 0.05
	clone9.Mesh.Scale = createVector(-100, -100, -100)
	clone9.Mesh.VertexColor = createVector(1, 1, 1)
	clone9.CFrame = clone7.Layer0.CFrame * CFrame.new(450, 0, 0)
	clone9.CFrame = clone9.CFrame * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.Angles(
		0,
		math.rad((Random.new():NextNumber(-180, 180))),
		0
	)
	clone9.Parent = thrown
	TweenService:Create(clone9.Mesh, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = createVector(-150, -100, -150)
	}):Play()
	TweenService:Create(clone9, TweenInfo.new(1, Enum.EasingStyle.Linear), {
		CFrame = clone9.CFrame * CFrame.Angles(0, math.rad((Random.new():NextNumber(-180, 180))), 0)
	}):Play()
	Utility.PlayFlipbook(clone9.Mesh, 1, v.Wind3)
	local clone10 = blazeSurge.WindMesh3:Clone()
	local v22 = 15

	if clone10 then
		safeDestroy(true, v22) -- equivalent call inferred; original call site unknown
	end

	clone10.Name = "WindMesh4"
	clone10.Transparency = 0.25
	clone10.CFrame = clone7.Layer0.CFrame * CFrame.new(100, 0, 0)
	clone10.CFrame = clone10.CFrame * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.Angles(
		0,
		math.rad((Random.new():NextNumber(-180, 180))),
		0
	)
	clone10.Mesh.Scale = createVector(-100, -120, -130)
	clone10.Mesh.VertexColor = createVector(1, 1, 1)
	clone10.Parent = thrown
	TweenService:Create(clone10.Mesh, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = createVector(-130, -110, -130)
	}):Play()
	TweenService:Create(clone10, TweenInfo.new(1, Enum.EasingStyle.Linear), {
		CFrame = clone10.CFrame * CFrame.new(-50, 0, 0) * CFrame.Angles(
			0,
			math.rad((Random.new():NextNumber(-180, 180))),
			0
		)
	}):Play()
	Utility.PlayFlipbook(clone10.Mesh, 1, v.Wind3)
	local clone11 = blazeSurge.WindMesh3:Clone()
	local v23 = 15

	if clone11 then
		safeDestroy(true, v23) -- equivalent call inferred; original call site unknown
	end

	clone11.Name = "WindMesh5"
	clone11.Transparency = 0.25
	clone11.CFrame = clone7.Layer0.CFrame * CFrame.new(150, 0, 0)
	clone11.CFrame = clone11.CFrame * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.Angles(
		0,
		math.rad((Random.new():NextNumber(-180, 180))),
		0
	)
	clone11.Mesh.Scale = createVector(-100, -100, -130)
	clone11.Mesh.VertexColor = createVector(1, 1, 1)
	clone11.Parent = thrown
	TweenService:Create(clone11.Mesh, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = createVector(-103, -103, -103)
	}):Play()
	TweenService:Create(clone11, TweenInfo.new(1, Enum.EasingStyle.Linear), {
		CFrame = clone11.CFrame * CFrame.new(-30, 0, 0) * CFrame.Angles(
			0,
			math.rad((Random.new():NextNumber(-180, 180))),
			0
		)
	}):Play()
	Utility.PlayFlipbook(clone11.Mesh, 1, v.Wind3)
	local clone12 = blazeSurge.WindMesh3:Clone()
	local v24 = 15

	if clone12 then
		safeDestroy(true, v24) -- equivalent call inferred; original call site unknown
	end

	clone12.Name = "WindMesh6"
	clone12.Transparency = 0.05
	clone12.CFrame = clone7.Layer0.CFrame * CFrame.new(200, 0, 0)
	clone12.CFrame = clone12.CFrame * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.Angles(
		0,
		math.rad((Random.new():NextNumber(-180, 180))),
		0
	)
	clone12.Mesh.Scale = createVector(-100, -100, -130)
	clone12.Mesh.VertexColor = createVector(1, 1, 1)
	clone12.Parent = thrown
	TweenService:Create(clone12.Mesh, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = createVector(-188, -188, -188)
	}):Play()
	TweenService:Create(clone12, TweenInfo.new(1, Enum.EasingStyle.Linear), {
		CFrame = clone12.CFrame * CFrame.Angles(0, math.rad((Random.new():NextNumber(-180, 180))), 0)
	}):Play()
	Utility.PlayFlipbook(clone12.Mesh, 1.01, v.Wind3, function()
		if clone9 and clone9.Parent then
			clone9:Destroy()
		end

		if clone10 and clone10.Parent then
			clone10:Destroy()
		end

		if clone11 and clone11.Parent then
			clone11:Destroy()
		end

		if clone12 and clone12.Parent then
			clone12:Destroy()
		end
	end)
	task.wait(WAIT_INTERVAL)
	RunService:BindToRenderStep("BeamSize", Enum.RenderPriority.Camera.Value, function()
		if not (clone7 and clone7.Parent) then
			RunService:UnbindFromRenderStep("BeamSize")
			return
		end

		local number = Random.new():NextNumber(38, 42)
		clone7.Layer0.Size = Vector3.new(clone7.Layer0.Size.X, number, number)
		local number2 = Random.new():NextNumber(93, 97)
		clone7.Layer2.Size = Vector3.new(clone7.Layer2.Size.X, number2, number2)
		local number3 = Random.new():NextNumber(98, 102)
		clone7.Layer3.Size = Vector3.new(clone7.Layer3.Size.X, number3, number3)
		local number4 = Random.new():NextNumber(78, 82)
		clone7.Layer1.Size = Vector3.new(clone7.Layer1.Size.X, number4, number4)
	end)
	local v25 = "BeamSize"
	task.delay(DELAY_DURATION, function()
		pcall(function()
			RunService:UnbindFromRenderStep(v25)
		end)
	end)
	task.wait(0.9)

	if clone7 and clone7.Parent then
		clone7.Layer3.Wind.Enabled = false
		clone7.Layer3.Wind1.Enabled = false
	end

	if blurEffect then
		TweenService:Create(
			blurEffect,
			TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
			{
				Size = 24
			}
		):Play()
	end

	if clone8 and clone8.Parent then
		for _, effect in pairs(clone8:GetDescendants()) do
			if effect:IsA("Beam") then
				if effect.Name == "Beam" then
					effect.TextureSpeed = 4
				end

				local numberSequenceKeypoints = {}

				for i = 1, #effect.Transparency.Keypoints do
					table.insert(
						numberSequenceKeypoints,
						NumberSequenceKeypoint.new(effect.Transparency.Keypoints[i].Time, 1)
					)
				end

				local numberSequence = NumberSequence.new(numberSequenceKeypoints)
				BoatTween:Create(effect, {
					Time = effect.Name == "CartoonSmoke" and 0.1 or 2,
					EasingStyle = "Sine",
					EasingDirection = "Out",
					StepType = "RenderStepped",
					Goal = {
						TextureSpeed = 0,
						TextureLength = 1,
						Transparency = numberSequence
					}
				}):Play()
			elseif effect:IsA("ParticleEmitter") then
				effect.Enabled = false
			end
		end
	end

	if clone7 and clone7.Parent then
		for _, descendant in pairs(clone7:GetDescendants()) do
			if descendant:IsA("BasePart") then
				TweenService:Create(descendant, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Size = Vector3.new(descendant.Size.X, descendant.Size.Y * 3, descendant.Size.Z * 3),
					Transparency = 1
				}):Play()
			end

			if not descendant:IsA("Beam") then
				continue
			end

			descendant.Texture = "rbxassetid://13815517149"
			TweenService:Create(descendant, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				TextureSpeed = 1
			}):Play()
		end

		clone7.Particles.P1.Lifetime = NumberRange.new(0.4, 0.4)
		clone7.Particles.P1.Enabled = false
		clone7.Particles.P2.Lifetime = NumberRange.new(0.4, 0.4)
		clone7.Particles.P2.Enabled = false

		for _, beam in pairs(clone7.Layer1:GetDescendants()) do
			if beam:IsA("Beam") then
				BoatTween:Create(beam, {
					Time = 1,
					EasingStyle = "Quart",
					EasingDirection = "Out",
					StepType = "RenderStepped",
					Goal = {
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(1, 1)
						})
					}
				}):Play()
			end
		end
	end

	if clone8 and clone8.Parent then
		TweenService:Create(clone8.Mesh, TweenInfo.new(0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Scale = createVector(-500, -300, -500)
		}):Play()
		TweenService:Create(clone8, TweenInfo.new(0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end

	local clone13 = blazeSurge.TH:Clone()
	local v26 = 15

	if clone13 then
		safeDestroy(true, v26) -- equivalent call inferred; original call site unknown
	end

	clone13.Parent = game.Workspace.Thrown
	clone13:ScaleTo(1.3)
	clone13:PivotTo(CFrame.new(pos.Position))
	local library = require(script.Parent.library)
	library.LifeScale({
		FX = clone13,
		Scale = 2
	})
	local library2 = require(script.Parent.library)
	library2.PlayAttachment(clone13)
	task.wait(0.4)

	if colorCorrectionEffect and colorCorrectionEffect.Parent then
		colorCorrectionEffect:Destroy()
	end

	if blurEffect and blurEffect.Parent then
		blurEffect:Destroy()
	end

	RunService:UnbindFromRenderStep("BeamSize")
	task.wait(2)

	if Explosion and Explosion.Parent then
		Explosion:Destroy()
	end

	if clone7 and clone7.Parent then
		clone7:Destroy()
	end

	if clone8 and clone8.Parent then
		clone8:Destroy()
	end
end

return BlazeSurge