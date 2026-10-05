local createVector = vector.create
local Emotes = {}
local ActionCheck = require(game.ReplicatedStorage.ActionCheck)
local VFX = require(script.VFX)
local rollOffMaxDistance = workspace:FindFirstChild("Duel Choice") and 37.5 or 85
local friendcache = {}
local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()
local Info = require(game.ReplicatedStorage.Info)

if isStudio then
	shared.friendcache = friendcache
end

local v3 = {}

local function fn(folder)
	if v3[folder] then
		local v4 = v3[folder]
		local destroy = v4.destroy
		local hairs = v4.hairs

		for _, v5 in pairs(destroy) do
			v5.Transparency = 1
			game.Debris:AddItem(v5, 0.5)
		end

		for _, hair in pairs(hairs) do
			if not folder:GetAttribute("InMech") and folder.Head.Transparency < 1 then
				hair.Transparency = 0
			end

			for _, child in pairs(hair:GetChildren()) do
				if child:IsA("SpecialMesh") or child:IsA("MeshPart") then
					child.TextureId = child:GetAttribute("basetext")
				end
			end
		end

		v3[folder] = nil
	end

	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:GetAttribute("EmoteEffect") then
			descendant:Destroy("")
		end

		if descendant:IsA("Sound") and tostring(descendant) == "CrushEmoteAmbience" then
			local TweenService = game:GetService("TweenService")
			TweenService:Create(descendant, TweenInfo.new(0.75), {
				Volume = 0
			}):Play()
			local v4 = descendant
			task.delay(0.756, function()
				if v4 and v4.Parent then
					v4:Destroy()
				end
			end)
		end

		if (descendant:IsA("Part") or descendant:IsA("Folder")) and (descendant:GetAttribute("LimAura") or descendant:GetAttribute("LimitedAura")) then
			game.Debris:AddItem(descendant, 3)
		end

		if not ((descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Attachment")) and descendant:GetAttribute("LimitedAura")) then
			continue
		end

		if descendant:IsA("Part") then
			for _, effect in pairs(descendant:GetDescendants()) do
				if not (effect:IsA("Trail") or effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
					continue
				end

				effect.Enabled = false
			end
		end

		if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
			descendant.Enabled = false
		elseif descendant:IsA("Attachment") and #descendant:GetChildren() > 0 then
			for _, effect in pairs(descendant:GetChildren()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
					effect.Enabled = false
				end
			end
		end

		local v4 = descendant
		task.delay(3, function()
			if v4 and v4.Parent then
				v4:Destroy()
			end
		end)
	end
end

local function fn2(folder, options)
	local v4 = options or {}
	local v5 = not v4.Multiplier and 1 or v4.Multiplier

	for _, emitter in pairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit((emitter:GetAttribute("EmitCount") or 1) * v5)
		end
	end
end

local function fn3(folder)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") or descendant:IsA("Decal") then
			descendant.Transparency = 1

			if descendant:IsA("BasePart") then
				descendant.CollisionGroup = "untouchable"
			end
		elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Texture") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("BillboardGui") then
			descendant:Destroy()
		end

		if not descendant:IsA("Humanoid") then
			continue
		end

		descendant.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		descendant.HealthDisplayDistance = 0
		descendant.NameDisplayDistance = 0
	end
end

local function fn4(items, intensity, p2)
	for _, item in pairs(items) do
		if shared.p(item) then
			game.ReplicatedStorage.Replication:FireClient(shared.p(item), {
				Effect = "Camshake",
				Intensity = intensity,
				Last = p2 or nil
			})
		end
	end
end

local function fn5(folder)
	local v4 = {
		[2] = folder.Torso.Neck
	}
	local C0 = v4[2].C0
	task.spawn(function()
		for _ = 1, 10 do
			v4[2].C0 = C0 * CFrame.new(1e-8, 0, 0)
			wait()
			v4[2].C0 = C0
			task.wait(0.05)
		end
	end)
end

local function fn6(folder, p)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
			descendant.Enabled = p or false
		end
	end
end

local CollectionService = game:GetService("CollectionService")

local function fn7(data)
	local child = script.NewAssets:FindFirstChild(data.name)
	local char = data.char
	local cleanup = data.cleanup

	if not child then
		return
	end

	local parts = child.Parts
	local welds = child.Welds
	local clones = {}
	local v4 = {}

	for _, child2 in pairs(parts:GetChildren()) do
		local clone = nil

		if child2:IsA("Model") then
			clone = child2:Clone()
			clone.Parent = char
		elseif child2:IsA("Part") or child2:IsA("MeshPart") or child2:IsA("UnionOperation") then
			clone = child2:Clone()
			clone.Parent = char
			clone.Anchored = false
			clone.Massless = true
		end

		table.insert(clones, clone)
		table.insert(v4, clone)
		clone:SetAttribute("EmoteProperty", true)
		table.insert(cleanup, clone)
		CollectionService:AddTag(clone, "emoteendstuff" .. char.Name)
	end

	for _, child2 in pairs(welds:GetChildren()) do
		local clone = child2:Clone()
		clone:SetAttribute("EmoteProperty", true)
		table.insert(cleanup, clone)
		CollectionService:AddTag(clone, "emoteendstuff" .. char.Name)
		spawn(function()
			for i, descendant in pairs(char:GetDescendants()) do
				if tostring(descendant) == clone:GetAttribute("Parent") then
					clone.Parent = descendant
				end

				if tostring(descendant) == clone:GetAttribute("Part0") and not descendant:IsA("Model") and (descendant:IsA("Part") or descendant:IsA("MeshPart") or descendant:IsA("UnionOperation")) then
					clone.Part0 = descendant
				end

				if tostring(descendant) ~= clone:GetAttribute("Part1") or descendant:IsA("Model") then
					continue
				end

				if not (descendant:IsA("Part") or descendant:IsA("MeshPart") or descendant:IsA("UnionOperation")) then
					continue
				end

				clone.Part1 = descendant
			end
		end)
		table.insert(clones, clone)
	end

	return clones
end

local function fn8(data)
	local cleanup = data.cleanup
	local clone = data.object:Clone()
	local char = data.char
	local mind = data.mind
	local part1 = data.part1
	clone:SetAttribute("EmoteProperty", true)
	table.insert(cleanup, clone)
	mind.Handle = clone
	local motor6D = clone:FindFirstChildOfClass("Motor6D")
	motor6D:SetAttribute("EmoteProperty", true)
	table.insert(cleanup, motor6D)
	mind.md = motor6D

	if tostring(clone) == part1 then
		part1 = clone
	else
		for _, part in pairs(clone:GetChildren()) do
			if not ((part:IsA("Part") or part:IsA("MeshPart")) and tostring(part) == part1) then
				continue
			end

			part1 = part
			break
		end
	end

	motor6D.Part0 = data.part0
	motor6D.Part1 = part1
	motor6D.Parent = data.Parent or char.PrimaryPart
	clone.Parent = char
end

local soundIds = {
	120987205824015,
	119422029266465,
	107235614642450,
	138473894696129,
	1836516704,
	94111019811702,
	86534796182153,
	89602445023226,
	138053801157608,
	89336760165611,
	85014831722660,
	121415300327083,
	104462985877801,
	120670260583671,
	1836261338,
	80255365354899,
	1839850227,
	1837571829,
	1845742329,
	9038380332,
	1839444520,
	140238630247057,
	9045031823,
	1839312938,
	1838577168,
	83119347007476,
	9045590571,
	9112871516,
	124934820850788,
	1841681029,
	83958053624885,
	1837934932,
	1840161104,
	129084829698643,
	9048376021,
	1843650812,
	120837088679745,
	1845480621,
	1839850337,
	9047358509,
	9048185180,
	1836681160,
	1846637439,
	1842122622,
	1842179370,
	1838846993,
	9047820458,
	1838611838,
	1846329169,
	1839850227,
	9048435290,
	9040183974,
	1839850402,
	1840511111,
	1842247841,
	1845593645,
	1842922954,
	9038895603,
	1839850699,
	1845843249,
	9045588592,
	1845194026,
	1841361703,
	1846564205,
	1837871067,
	1843071445,
	1841610903,
	1835969978,
	1837768352,
	1847692872,
	9038367768,
	1837768517,
	1841726277,
	1842792928,
	1845508064,
	1847530262,
	9042542555,
	1844765268,
	1842104602,
	9046712764,
	1842188443,
	1836112668,
	35930009,
	9114013375,
	1837226630,
	9042800221,
	1835904215,
	1836308391,
	1836019934,
	1847180622,
	9043379206,
	9046189833,
	1838868548,
	1837365487,
	14145625078,
	1840374054,
	1836256328,
	9042798921,
	1847479242,
	1841061037,
	9043916958,
	1835906503,
	9043851073,
	1837682925,
	17086479927,
	9043114637,
	1842190005,
	9045473815,
	1842247132,
	1846971107,
	1847362131,
	9044565954,
	1846628364,
	1836270048,
	1837711983,
	1837664271,
	17096893930,
	1845732793,
	1835443210,
	1840135136,
	17097078338,
	1848254940,
	1842892976,
	1840019043,
	17086664493,
	1839643165,
	14145620056,
	9125652432,
	9048378262,
	1845023041,
	1841647421,
	9042785151,
	1837322223,
	1842772099,
	1839181441,
	9039548001,
	1845910020,
	1835831314,
	1836402463,
	9046455305,
	1846943603,
	1846187476,
	128350847155039,
	1846012134,
	1839918500,
	1837904676,
	1839918500,
	1836253240,
	9120974708,
	9045623796,
	9047324264,
	1841573938,
	9120973886,
	1836640331,
	1839209784,
	1847174988,
	1842188426,
	1843699308,
	1842188393,
	1840489462,
	13772555886,
	1847840594,
	9044612350,
	1841609664,
	9046628228,
	1837528258,
	9044565954,
	1842190166,
	1836736766,
	1848269635,
	9046379730,
	1846079994,
	1839021706,
	9042719219,
	1844612112,
	1837911163,
	1836440339,
	1836860450,
	1844765268,
	1839270703,
	1842976958,
	1837644729,
	1841319934,
	1835606556,
	79813014158048,
	108268388574452,
	139544862276913,
	123965451318755,
	115280107968027,
	99295350859531,
	130768197175219,
	135768204851321,
	93655305990112,
	9042544497,
	9045395415,
	1842612601,
	13935204860,
	9040601928,
	1846808425,
	1840434670
}

local function fn9(folder)
	local children = {}

	for _, child in pairs(workspace.Live:GetChildren()) do
		if not (tostring(child) ~= tostring(folder) and child:FindFirstChild("Humanoid") and child:FindFirstChild("HumanoidRootPart")) then
			continue
		end

		local humanoid = child:FindFirstChild("Humanoid")
		local humanoidRootPart = child:FindFirstChild("HumanoidRootPart")

		if child:FindFirstChild("nozombieawakening") or not (humanoid.Health <= 0) or not ((humanoidRootPart.Position - folder.PrimaryPart.Position).Magnitude <= 10) or child:FindFirstChild("KillEmoteFinished") then
			continue
		end

		if not child:FindFirstChild("Torso") or child:FindFirstChild("Torso").Transparency == 1 or (child:GetAttribute("KillEmoteBegan") or child:GetAttribute("BreakJointed")) then
			continue
		end

		local playerFromCharacter = game.Players:GetPlayerFromCharacter(child)

		if not (playerFromCharacter and (playerFromCharacter:GetAttribute("DiedTime") or 0) >= 2) then
			table.insert(children, child)
		end
	end

	local v4 = 20
	local v5 = nil

	for _, v6 in pairs(children) do
		local magnitude = (v6:FindFirstChild("HumanoidRootPart").Position - folder.PrimaryPart.Position).Magnitude

		if not (magnitude < v4) then
			continue
		end

		v5 = v6
		v4 = magnitude
	end

	if workspace:GetAttribute("RoyaleCustom") then
		return nil
	end

	if v5 then
		return v5
	end
end

local CollectionService2 = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local function fn10(p)
	p.Name = "EmoteSFX"
	p.RollOffMaxDistance = rollOffMaxDistance
	local sfx, v4, v5 = shared.sfx(p)
	local v6 = string.gsub(sfx.SoundId, "rbxassetid://", "")

	if v6 and table.find(soundIds, (tonumber(v6))) then
		CollectionService2:AddTag(sfx, "EmoteMusic")
	end

	sfx:SetAttribute("EmoteProperty", true)
	return sfx, v4, v5
end

local function fn11(data)
	local orig = data.orig
	local dir = data.dir
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = data.Whitelist or data.Ignore or { workspace.Thrown, workspace.Live }

	if data.Whitelist then
		raycastParams.FilterType = Enum.RaycastFilterType.Include
	else
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	end

	if data.Blockcast then
		local blockcast = workspace:Blockcast(orig, data.Blockcast, dir, raycastParams)

		if blockcast then
			return blockcast.Instance, blockcast.Position, blockcast.Material, blockcast.Normal
		end
	else
		local raycastResult = workspace:Raycast(orig, dir, raycastParams)

		if raycastResult then
			return raycastResult.Instance, raycastResult.Position, raycastResult.Material, raycastResult.Normal
		end
	end
end

local random = Random.new()

local function fn12(p, p2, p3)
	if not p2 and p then
		p2 = p
		p = 1
	end

	if not (p2 or p) then
		p = 0
		p2 = 1
	end

	if p3 then
		return random:NextInteger(p, p2)
	end

	return random:NextNumber(p, p2)
end

local function fn13(p, list, folder)
	local clone = script[p .. "Handle"]:Clone()
	clone:SetAttribute("EmoteProperty", true)
	table.insert(list, clone)
	local m6d = clone.m6d
	m6d:SetAttribute("EmoteProperty", true)
	table.insert(list, m6d)
	m6d.Part1 = clone[p .. "HandleMain"]
	m6d.Part0 = folder[p .. " Arm"]
	m6d.Parent = m6d.Part1

	for _, part in pairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Color = m6d.Part0.Color

		if folder:FindFirstChild("Left ArmL") then
			part.Color = Color3.fromRGB(49, 48, 51)
			part.Reflectance = 0.1
		elseif folder:FindFirstChild("Red Gloves") then
			part.Color = Color3.fromRGB(145, 65, 65)
		end
	end

	clone.Parent = folder
	return clone
end

function Emotes:Play(folder, p, p2, instance, p3)
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(folder)
	local v4 = p == "2v1" and "Wombo Combo" or p
	local object = setmetatable({}, {
		__tostring = v4
	})
	local fn14
	local result = nil

	function object:GetColor()
		if not playerFromCharacter then
			return Color3.new(1, 1, 1)
		end

		local v5 = game.ServerStorage.Data[playerFromCharacter.UserId]
		local HttpService = game:GetService("HttpService")
		local v6 = HttpService:JSONDecode(v5.EmoteColors.Value)[v4]

		if v6 then
			return Color3.fromRGB(unpack(v6))
		end
	end

	function object:GetExtraOption(p4)
		local v5 = not result or not result.extraoptions or not result.extraoptions[p4] or result.extraoptions[p4].defaultenabled ~= false

		if not playerFromCharacter then
			return v5
		end

		local v6 = game.ServerStorage.Data[playerFromCharacter.UserId]

		if not (v6 and v6:FindFirstChild("EmoteExtraOptions")) then
			return v5
		end

		local HttpService = game:GetService("HttpService")
		local jSONDecode = HttpService:JSONDecode(v6.EmoteExtraOptions.Value)

		if jSONDecode[v4] and jSONDecode[v4][p4] ~= nil then
			return jSONDecode[v4][p4]
		end

		return v5
	end

	local v5 = {
		Blink = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://118341941379862",
					Volume = 2
				},
				[0.5] = {
					SoundId = "rbxassetid://118100641167521",
					Volume = 2,
					Looped = true,
					ParentTorso = true
				}
			},
			Animation = 0,
			Idle = 0,
			HideWeapon = true,
			Stun = "Slowed",
			Looped = true,
			StunAttribute = 0.65,
			Startup = function(list, _, _, _, p4, instance2)
				if game.Players:GetPlayerFromCharacter(folder) then
					local cfolder = shared.cfolder({
						Name = "BlinkBind",
						Parent = folder
					})
					table.insert(list, cfolder)
					game.ReplicatedStorage.Replication:FireAllClients({
						Effect = "Blink Emote",
						bind = cfolder,
						char = folder
					})
					task.spawn(function()
						local v6 = fn14(99643081415160)
						table.insert(list, v6)
						local primaryPart = folder.PrimaryPart
						local humanoid = folder.Humanoid

						while task.wait() do
							if p4.interrupted then
								v6:Stop()
								break
							end

							local v7 = primaryPart.CFrame:Inverse() * (primaryPart.Position + primaryPart.Velocity)
							local v8 = math.ceil(math.deg((math.atan2(v7.X, -v7.Z))) - 0.5)
							local v9 = humanoid.MoveDirection ~= createVector(0, 0, 0)
							local v10

							if math.abs(v8) >= 130 and math.abs(v8) <= 181 then
								v10 = true
								v9 = false
							else
								v10 = false
							end

							local v11 = v10 and 1 or 0.65
							local div = instance2:GetAttribute("Div")
							instance2:SetAttribute("Div", v11)

							if div ~= v11 then
								shared.cfolder({
									Name = "a",
									Parent = folder
								}, 0.1)
							end

							if v9 then
								if not v6.IsPlaying then
									v6:Play()
								end
							else
								v6:Stop()
							end
						end
					end)
				end
			end
		},
		["Aka Stance"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://81330852490415",
					Volume = 2
				}
			},
			Idle = 118383042869348,
			Animation = 131177495882827,
			HideWeapon = true,
			Stun = "Freeze",
			Keyframes = {
				start = function(clones, _, _, _, _)
					fn4({ folder }, 1)
					fn10({
						SoundId = "rbxassetid://91565431637142",
						Parent = folder.Torso,
						Looped = true,
						Volume = 0.5
					}):Play()
					local rightArm = folder["Right Arm"]

					for _ = 1, 2 do
						local clone = script.cursedEnergy2:Clone()
						clone.Parent = folder
						clone:SetAttribute("EmoteProperty", true)
						table.insert(clones, clone)
						CollectionService2:AddTag(
							clone,
							"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
						)
						local weld = Instance.new("Weld")
						weld.Part0 = rightArm
						weld.Part1 = clone
						weld.Parent = clone
						weld.C0 = CFrame.new(0, -1, 0)
						rightArm = folder["Left Arm"]
					end
				end
			}
		},
		["Waiting Game"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://82159691260897",
					Volume = 0.85,
					Looped = false,
					ParentTorso = true
				}
			},
			Startup = function(list, _, _, _)
				if instance then
					return
				end

				local clone = script.WaitingGame.ShadeHandle:Clone()
				clone.Parent = folder
				local motor6D = clone:FindFirstChildOfClass("Motor6D")
				motor6D.Part0 = folder["Right Arm"]
				motor6D.Parent = folder["Right Arm"]
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				motor6D:SetAttribute("EmoteProperty", true)
				table.insert(list, motor6D)
			end,
			Animation = 92923174594620,
			Idle = 83076312996826,
			Stun = "Freeze",
			HideWeapon = true
		},
		["Ao Stance"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://107531870259193",
					Volume = 2
				}
			},
			Idle = 113201609340793,
			Animation = 104243341468337,
			HideWeapon = true,
			Stun = "Freeze",
			Keyframes = {
				start = function(clones, _, _, _, _)
					fn4({ folder }, 1)
					fn10({
						SoundId = "rbxassetid://91565431637142",
						Parent = folder.Torso,
						Looped = true,
						Volume = 0.5
					}):Play()
					local rightArm = folder["Right Arm"]

					for _ = 1, 2 do
						local clone = script.cursedEnergy:Clone()
						clone.Parent = folder
						clone:SetAttribute("EmoteProperty", true)
						table.insert(clones, clone)
						CollectionService2:AddTag(
							clone,
							"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
						)
						local weld = Instance.new("Weld")
						weld.Part0 = rightArm
						weld.Part1 = clone
						weld.Parent = clone
						weld.C0 = CFrame.new(0, -1, 0)
						rightArm = folder["Left Arm"]
					end
				end
			}
		},
		Amplify = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://112089323132965",
					Volume = 2
				}
			},
			Animation = 106778226674700,
			HideWeapon = true,
			Stun = "Freeze",
			MeleeEffects = true,
			Keyframes = {
				first = function(clones, _, _, _, _)
					local amplifyVfx = script.AmplifyVfx
					local emitters = {}
					local emitters2 = {}

					local function fn15(p4, p5)
						local clone = amplifyVfx[p4]:Clone()
						clone.Parent = p5
						game.Debris:AddItem(clone, 5)
						clone:SetAttribute("EmoteProperty", true)
						table.insert(clones, clone)
						CollectionService2:AddTag(
							clone,
							"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
						)
						local motor6D = clone:FindFirstChildOfClass("Motor6D")

						if motor6D then
							clone.CanCollide = false
							clone.Massless = true
							clone.Anchored = false
							motor6D.Part0 = p5
							motor6D.Part1 = clone
						else
							clone.CFrame = folder.PrimaryPart.CFrame * CFrame.new(0, 0, -2)
						end

						for _, emitter in pairs(clone:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							emitter:Emit(emitter:GetAttribute("EmitCount"))

							if motor6D then
								emitter.Enabled = true
								table.insert(emitters2, emitter)
							end

							if tostring(p4) == "head" then
								table.insert(emitters, emitter)
							end
						end
					end

					fn4({ folder }, 1)
					fn15("arm", folder["Right Arm"])
					fn15("head", folder.Head)
					wait(1.1)

					for _, v6 in pairs(emitters) do
						v6.Enabled = false
					end

					for _, v6 in pairs(emitters2) do
						v6.Enabled = false
						game.Debris:AddItem(v6, 1)
					end
				end,
				sec = function(clones, _, _, _, _)
					local amplifyVfx = script.AmplifyVfx

					local function fn15(p4, leftArm)
						local clone = amplifyVfx[p4]:Clone()
						clone.Parent = leftArm
						game.Debris:AddItem(clone, 5)
						clone:SetAttribute("EmoteProperty", true)
						table.insert(clones, clone)
						CollectionService2:AddTag(
							clone,
							"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
						)
						local motor6D = clone:FindFirstChildOfClass("Motor6D")

						if motor6D then
							clone.CanCollide = false
							clone.Massless = true
							clone.Anchored = false
							motor6D.Part0 = leftArm
							motor6D.Part1 = clone
						else
							clone.CFrame = folder.PrimaryPart.CFrame * CFrame.new(0, 0, -2)
						end

						for _, emitter in pairs(clone:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							emitter:Emit(emitter:GetAttribute("EmitCount"))

							if motor6D then
								emitter.Enabled = true
							end
						end
					end

					fn4({ folder }, 3)
					fn15("arm2", folder["Left Arm"])
					fn15("auraoff", folder["Left Arm"])
					shared.MeleeEffects({
						Char = folder,
						Effect = "Amplify",
						time = 30
					})
				end
			}
		},
		["Celestial Banisher"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://125543979037675",
					Volume = 3
				}
			},
			Startup = function(clones, _, _)
				local clone = script.StrikeThing.StrikeAttachment:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(clones, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				game.Debris:AddItem(clone, 15)
				game.Debris:AddItem(clone, 5)
				clone.Parent = folder["Right Arm"]
			end,
			Animation = 77002367518293,
			HideWeapon = true,
			Stun = "Freeze",
			KillEmote = true
		},
		["Lethal Beam"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://92080703823458",
					Volume = 2
				}
			},
			Animation = 116931318187769,
			HideWeapon = true,
			Stun = "Freeze",
			KillEmote = true
		},
		["Beneath Me"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://106138436425034",
					Volume = 2
				}
			},
			Animation = 134934729128196,
			HideWeapon = true,
			Stun = "Freeze",
			KillEmote = true
		},
		["STILL FUNNY?"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://106138436425034",
					Volume = 0
				}
			},
			Animation = 77586961719115,
			HideWeapon = true,
			Stun = "Freeze",
			KillEmote = true
		},
		["Time Shift"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://78909185953598",
					Volume = 3
				}
			},
			Animation = 114451374603244,
			HideWeapon = true,
			Stun = "Freeze",
			KillEmote = true
		},
		["Energy Release"] = {
			Sounds = {
				[0] = {
					SoundId = ({ "rbxassetid://132683371495025", "rbxassetid://128900017804077" })[math.random(1, 2)],
					Volume = 2
				}
			},
			Animation = 120953105100764,
			HideWeapon = true,
			Stun = "Freeze",
			Startup = function(clones, _, _, _, p4)
				local clone = script["PowerupT Hing"]:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(clones, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				clone.Parent = folder
				local weld = Instance.new("Weld")
				weld.Parent = clone
				weld.Part0 = folder.PrimaryPart
				weld.Part1 = clone
				wait(0.25)

				local function fn15(intensity)
					local playerFromCharacter2 = game.Players:GetPlayerFromCharacter(folder)

					if playerFromCharacter2 then
						game.ReplicatedStorage.Replication:FireClient(playerFromCharacter2, {
							Effect = "Camshake",
							Intensity = intensity
						})
					end
				end

				if p4.interrupted then
					return
				end

				fn15(1)
				clone.BurstAir.Burst:Emit(1)

				for _, child in pairs(clone.Floor:GetChildren()) do
					if tostring(child) ~= "Crack" then
						child.Enabled = true
					end
				end

				task.delay(0.85, function()
					if p4.interrupted then
						return
					end

					for i = 1, 3 do
						if p4.interrupted then
							break
						end

						for i2, child in pairs(clone.Lightning:GetChildren()) do
							if i2 == 3 then
								child.Enabled = true
							else
								fn15(1)
								child:Emit(math.random(2, 5))
							end
						end

						wait(i == 2 and 1.75 or 1)
					end
				end)
				task.delay(4, function()
					if p4.interrupted then
						return
					end

					fn15(2)
					clone.Floor.Crack:Emit(1)

					for _, child in pairs(clone.Lightning:GetChildren()) do
						child.Enabled = false
					end

					for _, child in pairs(clone.BurstAir:GetChildren()) do
						if tostring(child) ~= "Burst" then
							child:Emit(child:GetAttribute("EmitCount") * 1.2)
						end
					end

					for _, child in pairs(clone.Floor:GetChildren()) do
						if tostring(child) ~= "Crack" then
							child.Enabled = false
						end
					end
				end)
			end
		},
		["Boxed Up"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://90314606305113",
					Volume = 2
				}
			},
			Animation = 111810635064735,
			HideWeapon = true,
			Stun = "Freeze",
			KillEmote = true,
			Startup = function(list, _, p4)
				local clone = script.Present:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local masterM = clone.MasterM
				masterM:SetAttribute("EmoteProperty", true)
				table.insert(list, masterM)
				p4.md = masterM
				masterM.Part0 = folder.PrimaryPart
				masterM.Name = "Master"
				masterM.Part1 = clone.Master
				masterM.Parent = folder.PrimaryPart
				clone.Parent = folder.PrimaryPart
				fn10({
					SoundId = "rbxassetid://113981806904179",
					Parent = clone.Master.Top,
					Volume = 2
				}):Play()
			end
		},
		Ruthless = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://108336805340224",
					ParentTorso = true,
					Volume = 2
				}
			},
			Animation = 129295156336675,
			HideWeapon = true,
			Stun = "Freeze",
			KillEmote = true,
			Startup = function(clones, _, _)
				local part = script.Ruthless.Part
				local rightArm = folder["Right Arm"]

				for _ = 1, 2 do
					local clones2 = {}
					local v6 = nil

					for _, child in pairs(part:GetChildren()) do
						local clone = child:Clone()
						clone:SetAttribute("EmoteProperty", true)
						table.insert(clones, clone)
						CollectionService2:AddTag(
							clone,
							"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
						)
						clone.Parent = rightArm

						if clone:FindFirstChildOfClass("Trail") then
							v6 = clone
						end

						clones2[tostring(clone):find("1") and 1 or 2] = clone
					end

					for _, child in pairs(v6:GetChildren()) do
						child.Attachment0 = clones2[1]
						child.Attachment1 = clones2[2]
					end

					rightArm = folder["Left Arm"]
				end
			end
		},
		["Explosive Stomps"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://89576671264720",
					Volume = 1.85
				}
			},
			Animation = 83249039916902,
			HideWeapon = true,
			Stun = "Freeze",
			KillEmote = true
		},
		Weak = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://128113260968190",
					Volume = 3
				}
			},
			Animation = 93125757361125,
			HideWeapon = true,
			Stun = "Freeze",
			KillEmote = true
		},
		["Energy Barrage"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://82169026724146",
					Volume = 2
				}
			},
			Animation = 101680746241828,
			HideWeapon = true,
			Stun = "Freeze",
			KillEmote = true
		},
		Insect = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://95402001280762",
					Volume = 2
				}
			},
			Animation = 139229122563753,
			HideWeapon = true,
			Stun = "Freeze",
			KillEmote = true,
			Startup = function(p4, _, _)
				fn13("Right", p4, folder)
			end
		},
		["Dragon Combo"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://131083520587944",
					ParentTorso = true,
					Volume = 2
				}
			},
			Animation = 136363608783208,
			HideWeapon = true,
			Stun = "Freeze",
			KillEmote = true
		},
		["Heart Strike"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://131308069692843",
					Volume = 2
				}
			},
			Animation = 77053316619185,
			HideWeapon = true,
			Stun = "Freeze",
			KillEmote = true,
			Startup = function(list, _, p4)
				fn13("Left", list, folder)
				fn13("Right", list, folder)
				local clone = script.bookHeart:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				local bookBinderM = clone["Book BinderM"]
				bookBinderM:SetAttribute("EmoteProperty", true)
				table.insert(list, bookBinderM)
				p4.md = bookBinderM
				bookBinderM.Part0 = folder["Left Arm"]
				bookBinderM.Part1 = clone["Book Binder"]
				bookBinderM.Parent = folder["Left Arm"]
				clone.Parent = folder
				bookBinderM.Name = "Book Binder"
			end
		},
		Wipe = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://120656055302454",
					Volume = 2
				}
			},
			Startup = function(list, _, _)
				local wipe = script.Wipe
				local clone = wipe.Glasses:Clone()
				clone.Parent = folder.Head
				local motor6D = clone:FindFirstChildOfClass("Motor6D")
				motor6D.Part0 = folder.Head
				motor6D.Part1 = clone
				motor6D.Parent = folder.Head
				local clone2 = wipe["forget device"]:Clone()
				clone2.Parent = folder
				local mm = clone2.Mm
				mm.Part0 = folder["Right Arm"]
				mm.Part1 = clone2["memory stick"]
				mm.Parent = folder["Right Arm"]
				mm.Name = "memory stick"

				for _, v6 in pairs({
					clone,
					motor6D,
					mm,
					clone2
				}) do
					v6:SetAttribute("EmoteProperty", true)
					table.insert(list, v6)
					CollectionService2:AddTag(v6, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				end
			end,
			Animation = 101859186770986,
			HideWeapon = true,
			Stun = "Freeze",
			KillEmote = true
		},
		Telekinesis = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://137599530392999",
					Volume = 3
				}
			},
			Startup = function(_, _, _) end,
			Animation = 109608173870373,
			HideWeapon = true,
			Stun = "Freeze",
			KillEmote = true
		},
		["Fly High"] = {
			Sounds = {},
			Startup = function(list, _, _)
				fn10({
					SoundId = "rbxassetid://78462595468736",
					Parent = folder.Torso,
					Volume = 2
				}):Play()
				local v6 = fn10({
					SoundId = "rbxassetid://93204259658665",
					CFrame = folder.PrimaryPart.CFrame * CFrame.new(-0.591, 1, 8.396),
					Volume = 2
				})
				v6:Play()
				table.insert(list, v6)
			end,
			Animation = 80293430011221,
			HideWeapon = true,
			Stun = "Freeze",
			KillEmote = true
		},
		["Flower Bomb"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://114401044865713",
					Volume = 4.5
				}
			},
			Startup = function(list, _, _)
				local clone = script.Rose:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local sapplingE = clone.SapplingE
				sapplingE:SetAttribute("EmoteProperty", true)
				table.insert(list, sapplingE)
				CollectionService2:AddTag(
					sapplingE,
					"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
				)
				sapplingE.Part0 = folder.HumanoidRootPart
				sapplingE.Part1 = clone.Sappling
				sapplingE.Parent = folder.HumanoidRootPart
				sapplingE.Name = "Sappling"
				clone.Parent = folder
			end,
			Animation = 77962117984938,
			HideWeapon = true,
			Stun = "Freeze",
			KillEmote = true
		},
		["Sure Hit"] = {
			Sounds = {},
			Startup = function(list, _, _)
				local v6 = fn10({
					SoundId = "rbxassetid://133870782945226",
					Volume = 2,
					Parent = folder["Right Arm"]
				})
				v6:Play()
				table.insert(list, v6)
			end,
			Animation = 140145728452253,
			HideWeapon = true,
			Stun = "Freeze",
			KillEmote = true
		},
		Embers = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://94529938730886",
					Volume = 3.45,
					ParentTorso = true
				}
			},
			Startup = function(clones, _, _)
				local part = script.CinderAssets.Part
				local clone = nil

				for _, child in pairs(part:GetChildren()) do
					clone = child:Clone()
					clone:SetAttribute("EmoteProperty", true)
					table.insert(clones, clone)
					CollectionService2:AddTag(
						clone,
						"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
					)
					game.Debris:AddItem(clone, 15)
					clone.Parent = folder.Head
				end

				local function cloneBeamsAndTrails(instance2, parent)
					local clonesByName = {}

					for _, attachment in ipairs(instance2:GetChildren()) do
						if not attachment:IsA("Attachment") then
							continue
						end

						local clone2 = attachment:Clone()
						clone2:SetAttribute("EmoteProperty", true)
						table.insert(clones, clone2)
						CollectionService2:AddTag(
							clone2,
							"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
						)
						game.Debris:AddItem(clone2, 15)
						clone2:SetAttribute("canme", true)
						clone2.Parent = parent
						clonesByName[attachment.Name] = clone2
					end

					for _, trail in ipairs(instance2:GetChildren()) do
						if not trail:IsA("Trail") then
							continue
						end

						local clone2 = trail:Clone()
						clone2:SetAttribute("EmoteProperty", true)
						table.insert(clones, clone2)
						CollectionService2:AddTag(
							clone2,
							"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
						)
						game.Debris:AddItem(clone2, 15)
						clone2.Attachment0 = clonesByName[trail.Attachment0.Name]
						clone2.Attachment1 = clonesByName[trail.Attachment1.Name]
						clone2.Parent = parent
					end

					for _, attachment in ipairs(parent:GetChildren()) do
						if not (attachment:IsA("Attachment") and attachment:GetAttribute("canme")) then
							continue
						end

						for _, beam in ipairs(attachment:GetChildren()) do
							if not beam:IsA("Beam") then
								continue
							end

							local child = instance2:FindFirstChild(beam.Attachment0.Name)
							local child2 = instance2:FindFirstChild(beam.Attachment1.Name)

							if not (child and child2) then
								continue
							end

							beam.Attachment0 = clonesByName[child.Name]
							beam.Attachment1 = clonesByName[child2.Name]
						end
					end
				end

				cloneBeamsAndTrails(part.Parent.Head, folder.Head)
				task.delay(0.25, function()
					if clone and clone.Parent then
						cloneBeamsAndTrails(part.Parent["Right Arm"], folder["Right Arm"])
						cloneBeamsAndTrails(part.Parent["Left Arm"], folder["Left Arm"])
					end
				end)
			end,
			Animation = 83905432418191,
			HideWeapon = true,
			Stun = "Freeze",
			KillEmote = true
		},
		["Ban Hammer"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://120472586857703",
					ParentTorso = true,
					Volume = 2
				}
			},
			Startup = function(list, _, _)
				local clone = script.BanHammer:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local motor6D = clone:FindFirstChildOfClass("Motor6D")
				motor6D:SetAttribute("EmoteProperty", true)
				table.insert(list, motor6D)
				CollectionService2:AddTag(motor6D, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local rightArm = folder["Right Arm"]
				motor6D.Part0 = rightArm
				motor6D.Part1 = clone
				motor6D.Parent = rightArm
				clone.Parent = folder["Right Arm"]
				motor6D.Parent = folder["Right Arm"]
				clone.Name = "Handle"
			end,
			Animation = 71063727733290,
			HideWeapon = true,
			Stun = "Freeze",
			KillEmote = true
		},
		Death = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://125713401851477",
					Volume = 2,
					Looped = true
				}
			},
			Keyframes = {
				stop = function()
					for _, child in pairs(folder.PrimaryPart:GetChildren()) do
						if child:GetAttribute("Wolf") then
							fn6(child)
						end
					end
				end,
				clang = function()
					fn4({ folder }, 2, 0.5)
					local sparks2 = folder:FindFirstChild("Sparks2")

					if not sparks2 then
						sparks2 = script.BadWolf.Sparks2:Clone()
						sparks2.Parent = folder
						local motor6D = sparks2:FindFirstChildOfClass("Motor6D")
						motor6D.Part0 = folder.PrimaryPart
						motor6D.Part1 = sparks2
						motor6D.Parent = folder.PrimaryPart
					end

					fn2(sparks2, {
						Multiplier = 2
					})
				end,
				restart = function()
					for _, child in pairs(folder.PrimaryPart:GetChildren()) do
						if child:GetAttribute("Wolf") then
							fn6(child, true)
						end
					end
				end,
				spin = function(_, clones, _)
					for _, child in pairs(folder.PrimaryPart:GetChildren()) do
						if child:GetAttribute("Wolf") then
							fn6(child)
						end
					end

					local spinL = folder:FindFirstChild("SpinL")
					local spinR = folder:FindFirstChild("SpinR")

					if not (spinL or spinR) then
						local badWolf = script.BadWolf

						for _, v6 in pairs({ badWolf.SpinL, badWolf.SpinR }) do
							local clone = v6:Clone()
							clone:SetAttribute("EmoteProperty", true)
							table.insert(clones, clone)
							CollectionService2:AddTag(
								clone,
								"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
							)
							clone.Parent = folder
							local motor6D = clone:FindFirstChildOfClass("Motor6D")
							motor6D.Parent = tostring(v6) == "SpinL" and folder["Left Arm"] or folder["Right Arm"]
							motor6D.Part0 = tostring(v6) == "SpinL" and folder["Left Arm"] or folder["Right Arm"]
							motor6D.Part1 = clone
						end
					end

					local v6 = { folder:FindFirstChild("SpinL"), (folder:FindFirstChild("SpinR")) }

					local function fn15(folder2)
						for _, emitter in pairs(folder2:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v7 = emitter
							task.spawn(function()
								v7.Enabled = true
								task.wait(v7:GetAttribute("EmitDuration"))

								if v7 and v7.Parent then
									v7.Enabled = false
								end
							end)
						end
					end

					for _, v7 in pairs(v6) do
						fn15(v7)
					end
				end
			},
			Startup = function(list, _, _)
				local badWolf = script.BadWolf

				local function fn15(data)
					for _, thing in pairs(data.things) do
						local clone = thing:Clone()
						clone:SetAttribute("EmoteProperty", true)
						table.insert(list, clone)
						CollectionService2:AddTag(
							clone,
							"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
						)
						clone.Parent = folder
						local motor6D = clone:FindFirstChildOfClass("Motor6D")
						motor6D:SetAttribute("EmoteProperty", true)
						table.insert(list, motor6D)
						CollectionService2:AddTag(
							motor6D,
							"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
						)
						local rightArm = folder["Right Arm"]

						if thing.Name == data.Left then
							rightArm = folder["Left Arm"]
						end

						if data.Parent then
							rightArm = data.Parent
						end

						motor6D.Part0 = rightArm
						motor6D.Part1 = clone
						motor6D.Parent = rightArm
						clone.Parent = data.Parent or folder

						if data.set then
							clone:SetAttribute("Wolf", true)
						end
					end
				end

				fn15({
					things = { badWolf.HandleL, badWolf.HandleR },
					Left = "HandleL"
				})
				fn15({
					things = { badWolf.Left, badWolf.Right },
					Left = "Left",
					Parent = folder.PrimaryPart,
					set = true
				})
			end,
			Animation = 74441004296237,
			HideWeapon = true,
			Stun = "Slowed",
			Looped = true,
			Infinite = true,
			DontDisconnectMarkers = true
		},
		["Blades Of Jade"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://82078299414169",
					Volume = 1,
					Looped = true
				}
			},
			Keyframes = {
				floorhit = function()
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					raycastParams.FilterDescendantsInstances = { workspace.Thrown, workspace.Live }

					local function fn15(folder2)
						for _, emitter in pairs(folder2:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local raycastResult = tostring(emitter) == "smoke" and workspace:Raycast(
								folder.PrimaryPart.Position,
								folder.PrimaryPart.Position,
								raycastParams
							)

							if raycastResult then
								emitter.Color = ColorSequence.new(raycastResult.Instance.Color)
							end

							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end

					for _, model in pairs(folder:GetDescendants()) do
						if not ((tostring(model) == "JadeL" or tostring(model) == "JadeR") and model:IsA("Model")) then
							continue
						end

						fn15(model)
					end
				end,
				touchfloor = function()
					local clashVFX = folder.PrimaryPart:FindFirstChild("ClashVFX")

					if clashVFX then
						fn2(clashVFX)
					end
				end
			},
			Startup = function(list, _, _)
				local bladesOfJade = script.BladesOfJade

				for _, child in pairs(bladesOfJade.Attach:GetChildren()) do
					local clone = child:Clone()
					clone.Parent = folder.Head
					clone:SetAttribute("EmoteProperty", true)
					table.insert(list, clone)
					CollectionService2:AddTag(
						clone,
						"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
					)
				end

				for _, v6 in pairs({ bladesOfJade.JadeL, bladesOfJade.JadeR }) do
					local clone = v6:Clone()
					clone:SetAttribute("EmoteProperty", true)
					table.insert(list, clone)
					CollectionService2:AddTag(
						clone,
						"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
					)
					local motor6D = clone:FindFirstChildOfClass("Motor6D")
					motor6D:SetAttribute("EmoteProperty", true)
					table.insert(list, motor6D)
					CollectionService2:AddTag(
						motor6D,
						"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
					)
					local rightArm = folder["Right Arm"]

					if v6.Name == "JadeL" then
						rightArm = folder["Left Arm"]
					end

					motor6D.Part0 = rightArm
					motor6D.Part1 = clone.ChainPart1
					motor6D.Parent = rightArm
					clone.Parent = folder
					motor6D.Name = "ChainPart1"
				end

				local clone = bladesOfJade.Part.ClashVFX:Clone()
				clone.Parent = folder.PrimaryPart
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			end,
			Animation = 121440687354239,
			HideWeapon = true,
			Stun = "Slowed",
			Looped = true,
			Infinite = true,
			DontDisconnectMarkers = true
		},
		["Cymbal Walk"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://137380821099041",
					Volume = 1,
					Looped = true
				}
			},
			Startup = function(list, _, _)
				for _, v6 in pairs({ script.Circle1, script.Circle2 }) do
					local clone = v6:Clone()
					clone:SetAttribute("EmoteProperty", true)
					table.insert(list, clone)
					CollectionService2:AddTag(
						clone,
						"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
					)
					local motor6D = clone:FindFirstChildOfClass("Motor6D")
					motor6D:SetAttribute("EmoteProperty", true)
					table.insert(list, motor6D)
					CollectionService2:AddTag(
						motor6D,
						"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
					)
					local rightArm = folder["Right Arm"]

					if v6.Name == "Circle2" then
						rightArm = folder["Left Arm"]
					end

					motor6D.Part0 = rightArm
					motor6D.Part1 = clone
					motor6D.Parent = rightArm
					clone.Parent = folder
				end
			end,
			Animation = 81416134930511,
			HideWeapon = true,
			Stun = "Slowed",
			Looped = true
		},
		Cymbals = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://120045687952609",
					Volume = 1,
					Looped = true
				}
			},
			Startup = function(list, _, _)
				for _, v6 in pairs({ script.Circle1, script.Circle2 }) do
					local clone = v6:Clone()
					clone:SetAttribute("EmoteProperty", true)
					table.insert(list, clone)
					CollectionService2:AddTag(
						clone,
						"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
					)
					local motor6D = clone:FindFirstChildOfClass("Motor6D")
					motor6D:SetAttribute("EmoteProperty", true)
					table.insert(list, motor6D)
					CollectionService2:AddTag(
						motor6D,
						"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
					)
					local rightArm = folder["Right Arm"]

					if v6.Name == "Circle2" then
						rightArm = folder["Left Arm"]
					end

					motor6D.Part0 = rightArm
					motor6D.Part1 = clone
					motor6D.Parent = rightArm
					clone.Parent = folder
				end
			end,
			Animation = 95156811398036,
			HideWeapon = true,
			Stun = "Freeze"
		},
		["Send Backup"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://117092445671019",
					Volume = 2,
					Looped = true
				}
			},
			Startup = function(list, _, _)
				local clone = script.WalkieTalkie:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local motor6D = clone.Motor6D
				motor6D:SetAttribute("EmoteProperty", true)
				table.insert(list, motor6D)
				CollectionService2:AddTag(motor6D, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				clone.Name = "Handle"
				motor6D.Part0 = folder["Left Arm"]
				motor6D.Part1 = clone
				motor6D.Parent = folder.PrimaryPart
				clone.Parent = folder.PrimaryPart
			end,
			Animation = 102938209711074,
			HideWeapon = true,
			Stun = "Slowed"
		},
		["Chalice Play"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://89041127733848",
					Volume = 1,
					Looped = true
				}
			},
			Startup = function(list, _, _)
				local clone = script.chalice:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local motor = clone.Motor
				motor:SetAttribute("EmoteProperty", true)
				table.insert(list, motor)
				CollectionService2:AddTag(motor, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				motor.Part0 = folder["Left Arm"]
				motor.Part1 = clone.Handle
				motor.Parent = folder["Left Arm"]
				motor.Name = "Handle"
				clone.Parent = folder
			end,
			Idle = 108719443641457,
			Animation = 102159604911972,
			HideWeapon = true,
			Stun = "Freeze",
			Looped = true
		},
		["By My Sword"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://114386873150174",
					Volume = 1
				}
			},
			Startup = function(list, _, _)
				local clone = script.Maniac.MeshPart:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local motor = clone.Motor
				motor:SetAttribute("EmoteProperty", true)
				table.insert(list, motor)
				CollectionService2:AddTag(motor, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				motor.Part0 = folder["Right Arm"]
				motor.Part1 = clone.Handle
				motor.Parent = folder["Right Arm"]
				motor.Name = "Handle"
				clone.Parent = folder
			end,
			Idle = 102174454129081,
			Animation = 110359958284400,
			HideWeapon = true,
			Stun = "Freeze"
		},
		["Begone!"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://84487824273978",
					Volume = 1.25,
					Looped = false
				}
			},
			Animation = 134823032473116,
			Stun = "Slowed",
			HideWeapon = true
		},
		Flight = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://121935201003728",
					Volume = 1,
					Looped = true
				}
			},
			Animation = 78547941116306,
			Stun = "Slowed",
			StunAttribute = 0.7,
			HideWeapon = true,
			Looped = true
		},
		["Doodle Dance"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://120837088679745",
					Volume = 0.65,
					Looped = true
				}
			},
			Startup = function(p4, _, _)
				fn13("Left", p4, folder)
				fn13("Right", p4, folder)
			end,
			Animation = 133225663180459,
			Stun = "Slowed",
			StunAttribute = 1,
			HideWeapon = true,
			Looped = true
		},
		["Foul Smell"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://87571878180836",
					Volume = 1,
					Looped = false
				}
			},
			Startup = function(p4, _, _)
				fn13("Left", p4, folder)
				fn13("Right", p4, folder)
			end,
			Animation = 139039401196042,
			Stun = "Slowed",
			StunAttribute = 1,
			HideWeapon = true
		},
		["Be Quiet"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://116993830219499",
					Volume = 0.75,
					Looped = false
				}
			},
			Startup = function(list, _, _)
				local clone = script.PhoneBeQuiet:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local planeMotor = clone.PlaneMotor
				planeMotor:SetAttribute("EmoteProperty", true)
				table.insert(list, planeMotor)
				CollectionService2:AddTag(
					planeMotor,
					"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
				)
				planeMotor.Part0 = folder["Right Arm"]
				planeMotor.Part1 = clone.Plane
				planeMotor.Parent = folder["Right Arm"]
				planeMotor.Name = "Plane"
				clone.Parent = folder
				fn13("Left", list, folder)
			end,
			Animation = 104651529417410,
			Stun = "Freeze",
			HideWeapon = true
		},
		["Not Human"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://93844955761839",
					Volume = 1.25,
					Looped = false
				}
			},
			Startup = function(p4, _, _)
				fn13("Left", p4, folder)
				fn13("Right", p4, folder)
			end,
			Animation = 102201408849991,
			Stun = "Freeze",
			HideWeapon = true
		},
		Torch = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://86669386299202",
					Volume = 0.35,
					Looped = true
				}
			},
			Startup = function(list, _, _)
				local clone = script.Torch:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local handle = clone.Handle
				handle:SetAttribute("EmoteProperty", true)
				table.insert(list, handle)
				CollectionService2:AddTag(handle, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				handle.Part0 = folder["Right Arm"]
				handle.Part1 = clone
				handle.Parent = folder["Right Arm"]
				clone.Parent = folder
			end,
			Animation = 94311488918867,
			HideWeapon = true,
			Stun = "Slowed",
			StunAttribute = 1.5,
			Looped = true
		},
		["Pitchfork Protest!"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://72343803536395",
					Volume = 1,
					Looped = true
				}
			},
			Startup = function(list, _, _)
				local clone = script.pitchfork:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local pitchfork = clone.pitchfork
				pitchfork:SetAttribute("EmoteProperty", true)
				table.insert(list, pitchfork)
				CollectionService2:AddTag(
					pitchfork,
					"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
				)
				pitchfork.Part0 = folder["Left Arm"]
				pitchfork.Part1 = clone
				pitchfork.Parent = folder["Left Arm"]
				clone.Parent = folder
			end,
			Animation = 84608123283347,
			HideWeapon = true,
			Stun = "Slowed",
			Looped = true
		},
		Broomstick = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://138154662255338",
					Volume = 0.5,
					Looped = true
				}
			},
			Startup = function(cleanup, _, _)
				fn7({
					name = "Witch Flight",
					char = folder,
					cleanup = cleanup
				})
			end,
			Animation = 84303828924826,
			HideWeapon = true,
			Stun = "Slowed",
			Looped = true,
			StunAttribute = 0.9
		},
		["We want KJ!"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://103072512876625",
					Volume = 1,
					Looped = true
				}
			},
			Startup = function(list, _, _)
				local clone = script.signkj:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local sign = clone.sign
				sign:SetAttribute("EmoteProperty", true)
				table.insert(list, sign)
				CollectionService2:AddTag(sign, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				clone.Name = "sign"
				sign.Part0 = folder["Right Arm"]
				sign.Part1 = clone
				sign.Parent = folder["Right Arm"]
				clone.Parent = folder
			end,
			Animation = 131920426725963,
			HideWeapon = true,
			Stun = "Slowed",
			Looped = true
		},
		Disguise = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://80454452438876",
					Volume = 2,
					Looped = true
				}
			},
			Startup = function(list, _, _)
				local clone = script.Lamp:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local lampheadm = clone.lampheadm
				lampheadm:SetAttribute("EmoteProperty", true)
				table.insert(list, lampheadm)
				CollectionService2:AddTag(
					lampheadm,
					"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
				)
				clone.Name = "sign"
				lampheadm.Part0 = folder.Head
				lampheadm.Part1 = clone.lamphead
				lampheadm.Parent = folder.Head
				lampheadm.Name = "lamphead"
				clone.Parent = folder
			end,
			Animation = 96185673945954,
			HideWeapon = true,
			Stun = "Freeze",
			Looped = true
		},
		["Fly Pose"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://131682934847578",
					Volume = 0.7,
					Looped = true
				}
			},
			Animation = 121381453450722,
			Stun = "Slowed",
			HideWeapon = true,
			StunAttribute = 1.5,
			Looped = true
		},
		Sleigh = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://74795975600529",
					Volume = 2
				}
			},
			Startup = function(list, _, _, _, p4)
				local clone = script.Sleigh:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local motor6D = clone:FindFirstChildOfClass("Motor6D")
				motor6D:SetAttribute("EmoteProperty", true)
				table.insert(list, motor6D)
				CollectionService2:AddTag(motor6D, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				motor6D.Part0 = folder.PrimaryPart
				motor6D.Part1 = clone.Main
				motor6D.Parent = folder.PrimaryPart
				clone.Parent = folder
				task.delay(0.65, function()
					if p4.interrupted then
						return
					end

					local v6 = fn10({
						SoundId = "rbxassetid://103153234346526",
						Volume = 2,
						Looped = true,
						Parent = folder.PrimaryPart
					})
					v6:Play()
					v6:SetAttribute("EmoteProperty", true)
					table.insert(list, v6)
				end)
			end,
			Animation = 104031205817566,
			Idle = 119811670686735,
			HideWeapon = true,
			Stun = "Slowed"
		},
		["Hunter Pose"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://117253563855238",
					Volume = 2,
					ParentTorso = true
				}
			},
			Startup = function(clones, _, _)
				local clone = script.RockBig:Clone()
				clone.Parent = folder
				clone.Anchored = true
				clone:SetAttribute("EmoteProperty", true)
				table.insert(clones, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				spawn(function()
					local lastTime = tick()

					while task.wait() and not (tick() - lastTime >= 0.5) and clone do
						if not clone.Parent then
							break
						end

						clone.CFrame = folder.PrimaryPart.CFrame * CFrame.new(0, -1.5, 4)
					end
				end)
			end,
			Animation = 78615192673057,
			Idle = 123794818363362,
			HideWeapon = true,
			Stun = "Freeze",
			NoRotate = true
		},
		["No Food"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://111126885447675",
					Volume = 1.35
				}
			},
			Startup = function(list, _, _)
				local function fn15(clone)
					game.Debris:AddItem(clone, 10)
					clone:SetAttribute("EmoteProperty", true)
					table.insert(list, clone)
					CollectionService2:AddTag(
						clone,
						"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
					)
					clone.Parent = workspace.Thrown
				end

				local clone = script.Fridge:Clone()
				fn15(clone)
				clone:SetPrimaryPartCFrame(folder.PrimaryPart.CFrame)
				shared.sfx({
					Parent = clone.PrimaryPart,
					SoundId = "rbxassetid://78599170612031",
					Volume = 1.5
				}):Play()
				local weld = Instance.new("Weld")
				weld.Parent = clone
				weld.Part0 = folder.PrimaryPart
				weld.Part1 = clone.PrimaryPart
				weld.C0 = CFrame.new(-0.0510409996, -0.0289990902, -7.0736084, 1, 0, 0, 0, 1, 0, 0, 0, 1)
				local animation = Instance.new("Animation")
				animation.AnimationId = "rbxassetid://103093875701281"
				game.Debris:AddItem(animation, 5)
				clone.AnimationController:LoadAnimation(animation):Play()
				table.insert(list, (task.delay(3, function()
					if clone and clone.Parent then
						game.Debris:AddItem(clone, 1.15)

						if weld and weld.Parent then
							weld:Destroy("")
						end

						clone:SetAttribute("EmoteProperty", false)
						table.remove(list, table.find(list, clone))
					end
				end)))
			end,
			Animation = 78471208835198,
			HideWeapon = true,
			Stun = "Freeze"
		},
		["Vibin'"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://124934820850788",
					Volume = 0.6,
					Looped = true
				}
			},
			Looped = true,
			Animation = 93316268189441,
			Stun = "Freeze",
			Startup = function(p4, _, _)
				fn13("Left", p4, folder)
				fn13("Right", p4, folder)
			end
		},
		["Pro Artist"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://121117309929969",
					Volume = 2
				}
			},
			Startup = function(list, _, _)
				local clone = script.Pencil:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local motor6D = clone:FindFirstChildOfClass("Motor6D")
				motor6D:SetAttribute("EmoteProperty", true)
				table.insert(list, motor6D)
				CollectionService2:AddTag(motor6D, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				motor6D.Part0 = folder.PrimaryPart
				motor6D.Part1 = clone.Cylinder
				motor6D.Parent = folder.PrimaryPart
				clone.Parent = folder
				local clone2 = script.Paper:Clone()
				clone2:SetAttribute("EmoteProperty", true)
				table.insert(list, clone2)
				CollectionService2:AddTag(clone2, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local motor6D2 = clone2:FindFirstChildOfClass("Motor6D")
				local person = clone2.Person
				person.Texture = ""
				person.Transparency = 1
				motor6D2:SetAttribute("EmoteProperty", true)
				table.insert(list, motor6D2)
				CollectionService2:AddTag(motor6D2, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				motor6D2.Part0 = folder.PrimaryPart
				motor6D2.Part1 = clone2
				motor6D2.Parent = folder.PrimaryPart
				clone2.Parent = folder
				local primaryPart = folder.PrimaryPart
				local v6 = 1000
				local v7 = nil

				for _, v8 in pairs(game.Players:GetPlayers()) do
					local character = v8.Character

					if not (character and character ~= folder and folder:FindFirstChild("HumanoidRootPart")) then
						continue
					end

					local magnitude = (character.PrimaryPart.Position - primaryPart.Position).Magnitude

					if not (magnitude < v6) then
						continue
					end

					v7 = v8
					v6 = magnitude
				end

				local v8 = v7 or game.Players:GetPlayerFromCharacter(folder)

				if v8 then
					person.Texture = "rbxthumb://type=AvatarHeadShot&id=" .. v8.UserId .. "&w=420&h=420"
					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(person, TweenInfo.new(3), {
						Transparency = 0
					}):Play()
				end
			end,
			Animation = 108591985511918,
			Idle = 135563445002852,
			HideWeapon = true,
			Stun = "Freeze"
		},
		["Locked In"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://131221493098961",
					Volume = 2,
					Looped = true
				}
			},
			Startup = function(list, _, _)
				local clone = script.SumWater:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local sumWater = clone.SumWater
				sumWater:SetAttribute("EmoteProperty", true)
				table.insert(list, sumWater)
				CollectionService2:AddTag(sumWater, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				sumWater.Part0 = folder.Head
				sumWater.Part1 = clone
				sumWater.Parent = folder.Head
				clone.Parent = folder
				local clone2 = script.AuraRen:Clone()
				clone2:SetAttribute("EmoteProperty", true)
				table.insert(list, clone2)
				CollectionService2:AddTag(clone2, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local motor6D = clone2.Motor6D
				motor6D:SetAttribute("EmoteProperty", true)
				table.insert(list, motor6D)
				CollectionService2:AddTag(motor6D, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				motor6D.Part0 = folder.PrimaryPart
				motor6D.Part1 = clone2
				motor6D.Parent = clone2
				clone2.Parent = folder
				local clone3 = script.tounge:Clone()
				clone3:SetAttribute("EmoteProperty", true)
				table.insert(list, clone3)
				CollectionService2:AddTag(clone3, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local tounge = clone3.tounge
				tounge:SetAttribute("EmoteProperty", true)
				table.insert(list, tounge)
				CollectionService2:AddTag(tounge, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				tounge.Part0 = folder.Head
				tounge.Part1 = clone3
				tounge.Parent = folder.Head
				clone3.Parent = folder
			end,
			Animation = 132769857103497,
			Looped = true,
			HideWeapon = true,
			Stun = "Freeze"
		},
		["Perfect Concentration"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://124276204137474",
					Volume = 2
				}
			},
			Startup = function(list, _, _, _, p4)
				local concentration = script.Concentration
				task.delay(0.35, function()
					if p4.interrupted then
						return
					end

					fn4({ folder }, 2)
					local clone = concentration.Impact:Clone()
					clone.Parent = workspace.Thrown
					clone:SetAttribute("EmoteProperty", true)
					table.insert(list, clone)
					CollectionService2:AddTag(
						clone,
						"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
					)
					fn2(clone)
					clone.CFrame = folder.PrimaryPart.CFrame * clone:GetAttribute("Offset")
					local weldConstraint = Instance.new("WeldConstraint")
					weldConstraint.Part0 = folder.PrimaryPart
					weldConstraint.Part1 = clone
					weldConstraint.Parent = clone
					local highlight = Instance.new("Highlight")
					highlight.Parent = folder
					highlight:SetAttribute("EmoteProperty", true)
					table.insert(list, highlight)
					CollectionService2:AddTag(
						highlight,
						"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
					)
					highlight.OutlineColor = Color3.fromRGB(84, 255, 113)
					highlight.FillTransparency = 1
					highlight.OutlineTransparency = 1
					highlight.DepthMode = Enum.HighlightDepthMode.Occluded
					highlight.FillTransparency = 1
					highlight.FillColor = Color3.fromRGB(255, 255, 255)
					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(highlight, TweenInfo.new(0.125, Enum.EasingStyle.Quint), {
						FillTransparency = 0.55,
						OutlineTransparency = 0
					}):Play()
					task.delay(0.2, function()
						if highlight and highlight.Parent then
							local TweenService3 = game:GetService("TweenService")
							TweenService3:Create(highlight, TweenInfo.new(0.35, Enum.EasingStyle.Quart), {
								FillTransparency = 1,
								OutlineTransparency = 1
							}):Play()
						end
					end)
				end)
				task.delay(0.43, function()
					if p4.interrupted then
						return
					end

					for _, part in pairs(concentration.Puzzle:GetDescendants()) do
						if not part:IsA("Part") then
							continue
						end

						local clone = part:Clone()
						clone.Parent = workspace.Thrown
						clone:SetAttribute("EmoteProperty", true)
						table.insert(list, clone)
						CollectionService2:AddTag(
							clone,
							"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
						)
						clone.CFrame = folder.PrimaryPart.CFrame * clone:GetAttribute("Offset")
						fn2(clone)
						local weldConstraint = Instance.new("WeldConstraint")
						weldConstraint.Part0 = folder.PrimaryPart
						weldConstraint.Part1 = clone
						weldConstraint.Parent = clone
					end
				end)
			end,
			Animation = 120577018823573,
			Idle = 102959457211902,
			HideWeapon = true,
			Stun = "Freeze"
		},
		["In Charge"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://132557895221925",
					Volume = 0.65,
					Looped = true
				}
			},
			Startup = function(list, _, _)
				local v6 = {
					"rbxassetid://120987205824015",
					"rbxassetid://119422029266465",
					"rbxassetid://107235614642450"
				}
				local v8 = fn10({
					SoundId = v6[math.random(1, #v6)],
					Volume = 2,
					Looped = true,
					Parent = folder.PrimaryPart
				})
				table.insert(list, v8)
				v8:Play()
				local cfolder = shared.cfolder({
					Name = "SBind",
					Parent = folder
				})
				cfolder:SetAttribute("EmoteProperty", true)
				table.insert(list, cfolder)

				if playerFromCharacter then
					tick()
					local v10 = playerFromCharacter
					local v11

					if friendcache[v10] then
						v11 = friendcache[v10]
					end

					local ids = v11 or {}

					if #ids == 0 then
						local function iterPageItems(object2)
							return coroutine.wrap(function()
								local v12 = 1

								while true do
									for _, v13 in ipairs(object2:GetCurrentPage()) do
										coroutine.yield(v13, v12)
									end

									if object2.IsFinished then
										break
									end

									object2:AdvanceToNextPageAsync()
									v12 += 1
								end
							end)
						end

						local Players = game:GetService("Players")
						local friendsAsync = Players:GetFriendsAsync(playerFromCharacter.UserId)

						for k, _ in coroutine.wrap(function()
							local v12 = 1

							while true do
								for _, v13 in ipairs(friendsAsync:GetCurrentPage()) do
									coroutine.yield(v13, v12)
								end

								if friendsAsync.IsFinished then
									break
								end

								friendsAsync:AdvanceToNextPageAsync()
								v12 += 1
							end
						end) do
							table.insert(ids, k.Id)
						end

						if #ids > 0 then
							friendcache[playerFromCharacter] = ids
						end
					end

					local friends = {}

					for _ = 1, 2 do
						if not (#ids > 0) then
							continue
						end

						local v13 = math.random(#ids)
						table.insert(friends, ids[v13])
						table.remove(ids, v13)
					end

					game.ReplicatedStorage.Replication:FireAllClients({
						Type = "EmoteFriends",
						Character = folder,
						InCharge = true,
						Friends = friends,
						AnimSent = 105328436798330,
						Bind = cfolder
					})
				end
			end,
			StunAttribute = 1.5,
			Animation = 132132848099103,
			HideWeapon = true,
			Looped = true,
			Stun = "Slowed"
		},
		Overtime = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://114806220109865",
					Volume = 2,
					Looped = true
				}
			},
			Startup = function(list, _, _)
				for _, v6 in pairs({ script.ChairDD, script.gamersetup }) do
					local clone = v6:Clone()

					if tostring(clone) == "ChairDD" then
						clone.Name = "Chair"
					end

					clone.Parent = folder
					clone:SetAttribute("EmoteProperty", true)
					table.insert(list, clone)
					CollectionService2:AddTag(
						clone,
						"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
					)

					for _, motor6D in pairs(clone:GetDescendants()) do
						if not (motor6D:IsA("Motor6D") and motor6D:GetAttribute("real")) then
							continue
						end

						motor6D:SetAttribute("EmoteProperty", true)
						table.insert(list, motor6D)
						CollectionService2:AddTag(
							motor6D,
							"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
						)
						motor6D.Part0 = folder.PrimaryPart
						motor6D.Part1 = motor6D.Parent
						motor6D.Parent = folder.PrimaryPart
					end
				end
			end,
			Animation = 74861323886379,
			HideWeapon = true,
			Looped = true,
			Stun = "Freeze"
		},
		Lumberjack = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://101458069909807",
					Volume = 2,
					Looped = true
				}
			},
			Startup = function(list, _, _)
				local clone = script["Meshes/axe"]:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local motor6D = clone:FindFirstChildOfClass("Motor6D")
				motor6D:SetAttribute("EmoteProperty", true)
				table.insert(list, motor6D)
				CollectionService2:AddTag(motor6D, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				motor6D.Part0 = folder["Right Arm"]
				motor6D.Part1 = clone
				motor6D.Parent = folder["Right Arm"]
				clone.Parent = folder
				local clone2 = script["Wood Log"]:Clone()
				clone2:SetAttribute("EmoteProperty", true)
				table.insert(list, clone2)
				CollectionService2:AddTag(clone2, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				clone2.Parent = folder
				local weld = Instance.new("Weld")
				weld.Part0 = folder.PrimaryPart
				weld.Part1 = clone2
				weld.Parent = clone2
				weld.C0 = CFrame.new(0, 1, -5) * CFrame.Angles(1.5707963267948966, 0, 0)
			end,
			Animation = 94964377173355,
			HideWeapon = true,
			Looped = true,
			Stun = "Freeze"
		},
		["Butterfly Tricks"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://114786701726765",
					Volume = 2
				}
			},
			Startup = function(list, _, _)
				local clone = script.knife:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local motor6D = clone:FindFirstChildOfClass("Motor6D")
				motor6D:SetAttribute("EmoteProperty", true)
				table.insert(list, motor6D)
				CollectionService2:AddTag(motor6D, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				motor6D.Part0 = folder["Left Arm"]
				motor6D.Parent = folder["Left Arm"]
				motor6D.Part1 = clone.KnifeHandle2
				clone.Parent = folder["Left Arm"]
			end,
			Animation = 117808978646423,
			Idle = 127088655247683,
			HideWeapon = true,
			Stun = "Slowed"
		},
		["OUT!"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://81881477062696",
					Volume = 2
				}
			},
			Startup = function(clones, _, _)
				local clone = script.EXIT:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(clones, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local clone2 = clone.Motor6D:Clone()
				clone2:SetAttribute("EmoteProperty", true)
				table.insert(clones, clone2)
				CollectionService2:AddTag(clone2, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				clone2.Part0 = folder["Left Arm"]
				clone2.Part1 = clone.Cube
				clone2.Parent = folder["Left Arm"]
				clone.Parent = folder["Left Arm"]
			end,
			Animation = 72015241487310,
			HideWeapon = true,
			Stun = "Slowed"
		},
		["OBJECTION!"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://118729435940431",
					Volume = 2,
					Looped = true
				}
			},
			Startup = function(list, _, _)
				local clone = script.objection:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local objection = clone.objection
				objection:SetAttribute("EmoteProperty", true)
				table.insert(list, objection)
				CollectionService2:AddTag(
					objection,
					"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
				)
				objection.Part0 = folder.PrimaryPart
				objection.Part1 = clone
				objection.Parent = folder.PrimaryPart
				clone.Parent = folder
			end,
			Animation = 91110779676867,
			HideWeapon = true,
			Stun = "Freeze"
		},
		Borgir = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://77582360503674",
					Volume = 2,
					Looped = true
				}
			},
			Startup = function(list, _, _)
				local clone = script.Borgir:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local motor = clone.Motor
				motor:SetAttribute("EmoteProperty", true)
				table.insert(list, motor)
				CollectionService2:AddTag(motor, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				motor.Part0 = folder["Right Arm"]
				motor.Part1 = clone
				motor.Parent = folder["Right Arm"]
				motor.Name = "Borgir"
				clone.Parent = folder
			end,
			Animation = 127304623515480,
			HideWeapon = true,
			Stun = "Slowed"
		},
		["Dance Party"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://130703142976519",
					Volume = 2,
					Looped = true
				}
			},
			Startup = function(list, _, _)
				local clone = script.Booth:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local boothh = clone.Boothh
				boothh:SetAttribute("EmoteProperty", true)
				table.insert(list, boothh)
				CollectionService2:AddTag(boothh, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				boothh.Part0 = folder.HumanoidRootPart
				boothh.Part1 = clone.PrimaryPart
				boothh.Parent = folder.HumanoidRootPart
				boothh.Name = "Booth"
				clone.Parent = folder.PrimaryPart

				for _, part in pairs(clone:GetDescendants()) do
					if part:IsA("BasePart") and part.Anchored then
						warn(part)
					end
				end
			end,
			Animation = 101501716447658,
			HideWeapon = true,
			Looped = true,
			Stun = "Freeze"
		},
		["Odd Apple"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://80723452180580",
					Volume = 2
				}
			},
			Startup = function(list, _, _)
				local clone = script.Apple:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local apple = clone.Apple
				apple:SetAttribute("EmoteProperty", true)
				table.insert(list, apple)
				CollectionService2:AddTag(apple, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				apple.Part0 = folder.PrimaryPart
				apple.Part1 = clone
				apple.Parent = folder.PrimaryPart
				clone.Parent = folder
			end,
			Animation = 137363237552306,
			HideWeapon = true,
			Stun = "Freeze"
		},
		Assault = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://1845843249",
					Volume = 0.3,
					Looped = true
				}
			},
			Infinite = true,
			Animation = 88354179157575,
			Looped = true,
			Stun = "Slowed",
			StunAttribute = 1.5,
			HideWeapon = true,
			DontDisconnectMarkers = true,
			Keyframes = {
				clap = function(_, _, _)
					local rightArm = folder["Right Arm"]
					local clashEmit = rightArm:FindFirstChild("ClashEmit")

					if not clashEmit then
						clashEmit = script.ClashEmit.ClashEmit:Clone()
						clashEmit.Parent = rightArm
					end

					fn4({ folder }, math.random(1, 2))
					fn2(clashEmit)
				end
			},
			Startup = function(list, _, _)
				local clone = script.PowerfulFist:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local fistM = clone.FistM
				fistM:SetAttribute("EmoteProperty", true)
				table.insert(list, fistM)
				CollectionService2:AddTag(fistM, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				fistM.Part0 = folder["Left Arm"]
				fistM.Part1 = clone.Fist
				fistM.Parent = folder["Left Arm"]
				fistM.Name = "Fist"
				clone.Parent = folder
			end
		},
		Speciality = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://125915996063620",
					Volume = 2
				},
				[1] = {
					SoundId = "rbxassetid://140297441659064",
					Volume = 2,
					Looped = true
				}
			},
			Startup = function(list, _, _)
				local clone = script.Food:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local motor6D = clone:FindFirstChildOfClass("Motor6D")
				motor6D:SetAttribute("EmoteProperty", true)
				table.insert(list, motor6D)
				CollectionService2:AddTag(motor6D, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				motor6D.Part0 = folder["Left Arm"]
				motor6D.Part1 = clone
				motor6D.Parent = folder["Left Arm"]
				clone.Parent = folder["Left Arm"]
			end,
			Animation = 90760942344050,
			Idle = 124162115547826,
			HideWeapon = true,
			Stun = "Slowed"
		},
		["Fine Drink"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://80723452180580",
					Volume = 0
				}
			},
			Startup = function(list, _, _)
				local clone = script.ArmChair:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local motor6D = clone:FindFirstChildOfClass("Motor6D")
				motor6D:SetAttribute("EmoteProperty", true)
				table.insert(list, motor6D)
				CollectionService2:AddTag(motor6D, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				motor6D.Part0 = folder.PrimaryPart
				motor6D.Part1 = clone.ArmChair
				motor6D.Parent = folder.PrimaryPart
				motor6D.Name = "ArmChairz"
				clone.Parent = folder
				local clone2 = script.Glass:Clone()
				clone2:SetAttribute("EmoteProperty", true)
				table.insert(list, clone2)
				CollectionService2:AddTag(clone2, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local motor6D2 = clone2:FindFirstChildOfClass("Motor6D")
				motor6D2:SetAttribute("EmoteProperty", true)
				table.insert(list, motor6D2)
				CollectionService2:AddTag(motor6D2, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				motor6D2.Parent = folder.PrimaryPart
				motor6D2.Part0 = folder.PrimaryPart
				motor6D2.Part1 = clone2.Wine
				clone2.Parent = folder
			end,
			Animation = 92219871615475,
			Idle = 114499085231058,
			HideWeapon = true,
			Stun = "Freeze"
		},
		["Magical Sword"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://80723452180580",
					Volume = 0
				}
			},
			Startup = function(list, _, _)
				local clone = script.SwordHandle:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local handle = clone.Handle
				handle:SetAttribute("EmoteProperty", true)
				table.insert(list, handle)
				CollectionService2:AddTag(handle, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				handle.Part0 = folder.PrimaryPart
				handle.Part1 = clone
				handle.Parent = folder.PrimaryPart
				clone.Parent = folder
				clone.Name = "Handle"
			end,
			Animation = 94975523583657,
			HideWeapon = true,
			Looped = true,
			Stun = "Slowed"
		},
		EZ = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://75267063621706",
					Volume = 1
				}
			},
			Startup = function(list, _, _)
				local clone = script.PlacaSoPraAnimar:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local placaSoPraAnimar = clone.PlacaSoPraAnimar
				placaSoPraAnimar:SetAttribute("EmoteProperty", true)
				table.insert(list, placaSoPraAnimar)
				CollectionService2:AddTag(
					placaSoPraAnimar,
					"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
				)
				placaSoPraAnimar.Part0 = folder["Right Arm"]
				placaSoPraAnimar.Part1 = clone
				placaSoPraAnimar.Parent = folder["Right Arm"]
				clone.Parent = folder
			end,
			Keyframes = {
				freeze = function(_, _, object2)
					object2:AdjustSpeed(0)
				end
			},
			Animation = 92883107669654,
			HideWeapon = true,
			Stun = "Freeze"
		},
		Maniac = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://73879474716638",
					Volume = 1.5,
					Looped = true
				}
			},
			Startup = function(list, _, _)
				local clone = script.Maniac.MeshPart:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local motor = clone.Motor
				motor:SetAttribute("EmoteProperty", true)
				table.insert(list, motor)
				CollectionService2:AddTag(motor, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				motor.Part0 = folder["Right Arm"]
				motor.Part1 = clone.Handle
				motor.Parent = folder["Right Arm"]
				motor.Name = "Handle"
				clone.Parent = folder
			end,
			Looped = true,
			Animation = 124337193780872,
			HideWeapon = true,
			Stun = "Slowed"
		},
		["League Oath"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://80178845592358",
					Volume = 1.5
				}
			},
			Startup = function(list, _, _)
				local clone = script.Maniac.MeshPart:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local motor = clone.Motor
				motor:SetAttribute("EmoteProperty", true)
				table.insert(list, motor)
				CollectionService2:AddTag(motor, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				motor.Part0 = folder["Right Arm"]
				motor.Part1 = clone.Handle
				motor.Parent = folder["Right Arm"]
				motor.Name = "Handle"
				clone.Parent = folder
			end,
			Animation = 78851551917642,
			Idle = 71163641460855,
			HideWeapon = true,
			Stun = "Freeze"
		},
		Mid = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://126631832022361",
					Volume = 2
				}
			},
			Animation = 84359348423275,
			Stun = "Slowed",
			StunAttribute = 1,
			HideWeapon = true,
			Startup = function(p4, _, _)
				fn13("Left", p4, folder)
				fn13("Right", p4, folder)
			end
		},
		Calculating = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://114224288259949",
					Volume = 2
				}
			},
			Animation = 104956990421479,
			Stun = "Freeze",
			HideWeapon = true,
			Startup = function(p4, _, _)
				fn13("Left", p4, folder)
				fn13("Right", p4, folder)
			end
		},
		["All Me"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://137124741132218",
					Volume = 2
				}
			},
			Animation = 110694817344709,
			Stun = "Slowed",
			StunAttribute = 1,
			HideWeapon = true,
			Startup = function(p4, _, _)
				fn13("Left", p4, folder)
				fn13("Right", p4, folder)
			end
		},
		["Clean Fight"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://139711598002213",
					Volume = 2
				}
			},
			Animation = 133121061492478,
			Stun = "Freeze",
			HideWeapon = true,
			Startup = function(p4, _, _)
				fn13("Left", p4, folder)
				fn13("Right", p4, folder)
			end
		},
		Yapper = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://137138220384381",
					Volume = 2
				}
			},
			Animation = 85271812976018,
			Stun = "Slowed",
			StunAttribute = 1,
			HideWeapon = true,
			Startup = function(p4, _, _)
				fn13("Left", p4, folder)
				fn13("Right", p4, folder)
			end
		},
		["Self Hate"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://102327892747347",
					Volume = 2
				}
			},
			Animation = 98491634200850,
			Stun = "Slowed",
			StunAttribute = 1
		},
		["War Cry"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://91755545882744",
					Volume = 2,
					Looped = true
				}
			},
			Animation = 127113883473285,
			Stun = "Freeze"
		},
		["Fire In Me"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://93396994882536",
					Volume = 2,
					Looped = true
				}
			},
			Animation = 92116312846822,
			Looped = true,
			Stun = "Freeze"
		},
		Delight = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://134481671165609",
					Volume = 1,
					Looped = true
				}
			},
			Animation = 134228716476620,
			Looped = true,
			Stun = "Freeze"
		},
		["Triumphant Delight"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://72674553555470",
					Volume = 2
				}
			},
			Animation = 124645358602106,
			Stun = "Freeze"
		},
		["Curl Up"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://86176537548647",
					Volume = 2
				}
			},
			Animation = 134273575464340,
			Idle = 85758455402628,
			Stun = "Freeze"
		},
		Crashout = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://134407182653763",
					Volume = 1
				},
				[0.00001] = {
					SoundId = "rbxassetid://117722877981575",
					Volume = 1
				}
			},
			Animation = 106400765698758,
			Idle = 103362214977039,
			Stun = "Freeze",
			Keyframes = {
				vfx = function(list, _, _, _, _)
					local clone = script.BackgroundCrashoutVfx:Clone()
					table.insert(list, clone)
					clone.Parent = folder
					clone.Anchored = true
					clone:SetAttribute("EmoteProperty", true)
					table.insert(list, clone)
					CollectionService2:AddTag(
						clone,
						"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
					)
					clone.CFrame = folder.PrimaryPart.CFrame * CFrame.new(0, -0.5, 0)
					task.delay(0.1, function()
						if clone and clone.Parent then
							local v6 = fn10({
								SoundId = "rbxassetid://94069267034673",
								Volume = 2,
								Looped = true,
								Parent = folder.PrimaryPart
							})
							local v7 = fn10({
								SoundId = "rbxassetid://85346361575494",
								Volume = 2,
								Looped = true,
								Parent = folder.PrimaryPart
							})
							v7:Play()
							v6:Play()
							table.insert(list, v7)
							table.insert(list, v6)
						end
					end)
					local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
					colorCorrectionEffect.Enabled = true
					colorCorrectionEffect.Parent = game.Lighting
					colorCorrectionEffect:SetAttribute("EmoteProperty", true)
					table.insert(list, colorCorrectionEffect)
					CollectionService2:AddTag(
						colorCorrectionEffect,
						"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
					)

					if shared.p(folder) then
						game.ReplicatedStorage.Replication:FireClient(game.Players:GetPlayerFromCharacter(folder), {
							Type = "RageCcEmote",
							Cc = colorCorrectionEffect
						})
					end

					for _, v6 in pairs({ clone.Eye, clone.Shade }) do
						v6.Parent = folder.Head
						v6:SetAttribute("EmoteProperty", true)
						table.insert(list, v6)
						CollectionService2:AddTag(
							v6,
							"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
						)
					end

					tick()

					local function fn15(intensity)
						local playerFromCharacter2 = game.Players:GetPlayerFromCharacter(folder)

						if playerFromCharacter2 then
							game.ReplicatedStorage.Replication:FireClient(playerFromCharacter2, {
								Effect = "Camshake",
								Intensity = intensity
							})
						end
					end

					fn15(3)
					wait(0.1)

					while clone do
						if not clone.Parent then
							break
						end

						fn15(1)
						task.wait(0.1)
					end
				end
			}
		},
		["The Shadow"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://140523806098392",
					Volume = 2
				},
				[1.25] = {
					SoundId = "rbxassetid://72724090837907",
					Volume = 2,
					Looped = true
				}
			},
			Animation = 100667788888119,
			Idle = 84711944358577,
			Stun = "Freeze",
			Startup = function(clones, _, _, _, p4)
				task.delay(0.65, function()
					if not p4.interrupted then
						local clone = script.AllParticles.FaceShade:Clone()
						clone.Parent = folder.Head
						clone:SetAttribute("EmoteProperty", true)
						table.insert(clones, clone)
						CollectionService2:AddTag(
							clone,
							"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
						)
						local clone2 = script.AllParticles.Star:Clone()
						clone2.Parent = folder.Torso
						clone2:SetAttribute("EmoteProperty", true)
						table.insert(clones, clone2)
						CollectionService2:AddTag(
							clone2,
							"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
						)
					end
				end)
			end
		},
		["Take Me On"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://77696812615768",
					Volume = 1
				}
			},
			Animation = 106128760138039,
			Idle = 128334295101396,
			Stun = "Freeze",
			End = {
				108557346368699,
				0.35,
				{}
			}
		},
		Backwards = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://1839850227",
					Volume = 1,
					Looped = true
				}
			},
			HideWeapon = true,
			Animation = 17863082627,
			Looped = true,
			Stun = "Slowed"
		},
		["Side To Side"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://1845742329",
					Volume = 1,
					Looped = true
				}
			},
			HideWeapon = true,
			Animation = 17861884104,
			Looped = true,
			Stun = "Freeze"
		},
		Celebration = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://9048376021",
					Volume = 1,
					Looped = true,
					TimePosition = 23.5
				}
			},
			HideWeapon = true,
			Animation = 17863041811,
			Looped = true,
			Stun = "Freeze"
		},
		["Hitting It"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://1839850337",
					Volume = 1,
					Looped = true,
					TimePosition = 23.5
				}
			},
			Animation = 124040557048936,
			Looped = true,
			Stun = "Freeze"
		},
		["Ohio Dance"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://9047358509",
					Volume = 1,
					Looped = true,
					TimePosition = 60
				}
			},
			HideWeapon = true,
			Animation = 17861841334,
			Looped = true,
			Stun = "Freeze"
		},
		Laughable = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://18828378634",
					Volume = 1,
					Looped = false,
					ParentTorso = true
				},
				[1] = {
					SoundId = "rbxassetid://9116239157",
					Volume = 2,
					Looped = false,
					ParentTorso = true
				}
			},
			Keyframes = {},
			Infinite = true,
			HideWeapon = true,
			Animation = 18897661505,
			Stun = "Slowed",
			StunAttribute = 1.5
		},
		["You Hear This?"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://18828322371",
					Volume = 1,
					Looped = false,
					ParentTorso = true
				}
			},
			Keyframes = {},
			Infinite = true,
			HideWeapon = true,
			Animation = 18897631758,
			Stun = "Slowed",
			StunAttribute = 1.5
		},
		["Dramatic Kick"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://18829050749",
					Volume = 1,
					Looped = false,
					ParentTorso = true
				}
			},
			Keyframes = {},
			Animation = 18897648446,
			Stun = "Freeze"
		},
		Leg = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://9040183974",
					Volume = 1,
					Looped = true,
					ParentTorso = true
				}
			},
			Keyframes = {},
			Looped = true,
			Animation = 18897664299,
			Stun = "Slowed",
			StunAttribute = 1.75
		},
		Dodge = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://18843747132",
					Volume = 1,
					Looped = false,
					ParentTorso = true
				}
			},
			Keyframes = {},
			Animation = 18897560632,
			Stun = "Freeze"
		},
		Emote = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://18828144688",
					Volume = 2,
					Looped = false,
					ParentTorso = true
				}
			},
			Keyframes = {},
			HideWeapon = true,
			Animation = 18897531388,
			Stun = "Slowed",
			StunAttribute = 1.5
		},
		["Exercise 2"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://18843268995",
					Volume = 1,
					TimePosition = 0.2,
					Looped = true,
					ParentTorso = true
				}
			},
			Keyframes = {},
			HideWeapon = true,
			Animation = 18897643802,
			Looped = true,
			Stun = "Slowed"
		},
		Burpee = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://18828186356",
					Volume = 1,
					Looped = true,
					ParentTorso = true
				}
			},
			Keyframes = {},
			HideWeapon = true,
			Animation = 18897501714,
			Looped = true,
			Stun = "Freeze"
		},
		Forever = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://18828925553",
					Volume = 1,
					Looped = false,
					ParentTorso = true
				}
			},
			Keyframes = {},
			HideWeapon = true,
			Animation = 18897617695,
			Idle = 18897615186,
			Stun = "Freeze"
		},
		Unimpressed = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://18827957735",
					Volume = 1,
					Looped = true,
					ParentTorso = true
				}
			},
			Keyframes = {},
			Infinite = true,
			HideWeapon = true,
			Animation = 18897731065,
			Looped = true,
			Stun = "Slowed"
		},
		Headbanger = {
			Sounds = {},
			Keyframes = {},
			Startup = function()
				fn10({
					SoundId = "rbxassetid://1836270048",
					Volume = 1,
					TimePosition = 0.25,
					Looped = true,
					Parent = folder.Head
				}):Resume()
			end,
			HideWeapon = true,
			Animation = 18897492506,
			Looped = true,
			Stun = "Freeze"
		},
		Daydream = {
			Sounds = {},
			Keyframes = {},
			Startup = function()
				fn10({
					SoundId = "rbxassetid://1842247841",
					Volume = 1,
					TimePosition = 5,
					Parent = folder.Head
				}):Resume()
			end,
			Infinite = true,
			HideWeapon = true,
			Animation = 18897563773,
			Looped = true,
			Stun = "Freeze"
		},
		["Clear My Head"] = {
			Sounds = {},
			Keyframes = {},
			Startup = function()
				fn10({
					SoundId = "rbxassetid://18827980294",
					Volume = 1,
					TimePosition = 0.1,
					Parent = folder.Head
				}):Resume()
			end,
			HideWeapon = true,
			Animation = 18897628831,
			Looped = false,
			Stun = "Freeze"
		},
		Forwards = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://1839850227",
					Volume = 1,
					Looped = true
				}
			},
			Keyframes = {
				clap = function()
					fn10({
						SoundId = "rbxassetid://2704706975",
						Volume = 1,
						Parent = folder.Head
					}):Play()
				end
			},
			Infinite = true,
			HideWeapon = true,
			Animation = 17862100862,
			Looped = true,
			Stun = "Slowed"
		},
		Kicks = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://1842418969",
					Volume = 1,
					Looped = true,
					TimePosition = 1
				}
			},
			HideWeapon = true,
			Animation = 17861870996,
			Looped = true,
			Stun = "Slowed"
		},
		["Stepping Shuffle"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://1839850402",
					Volume = 1,
					Looped = true,
					TimePosition = 1
				}
			},
			HideWeapon = true,
			Animation = 17861898789,
			Looped = true,
			Stun = "Freeze"
		},
		["Speedy Legs"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://9038895603",
					Volume = 1,
					Looped = true,
					TimePosition = 1
				}
			},
			HideWeapon = true,
			Animation = 17863047324,
			Looped = true,
			Stun = "Slowed"
		},
		["Excited Shuffle"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://1839850699",
					Volume = 1,
					Looped = true
				}
			},
			HideWeapon = true,
			Animation = 17863091228,
			Looped = true,
			Stun = "Slowed"
		},
		["Arm Sway"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://1846564205",
					Volume = 0.4,
					Looped = true
				}
			},
			HideWeapon = true,
			Animation = 17861898147,
			Looped = true,
			Stun = "Freeze"
		},
		["Low Snaps"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://1837871067",
					Volume = 1,
					Looped = true
				}
			},
			Animation = 17861881962,
			Looped = true,
			Stun = "Freeze"
		},
		["Blood Swipe"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://93497864837958",
					Volume = 1,
					Looped = true
				}
			},
			Animation = 122647124825700,
			Stun = "Slowed"
		},
		["Great Escape"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://1845843249",
					Volume = 0.3,
					Looped = true
				}
			},
			Infinite = true,
			Animation = 17861862787,
			Looped = true,
			Stun = "Slowed",
			StunAttribute = 1.5
		},
		Beatdown = {
			Keyframes = {
				clap = function()
					fn10({
						SoundId = "rbxassetid://18835607404",
						Parent = folder.Torso,
						Volume = 1,
						PlaybackSpeed = 1
					}):Play()
				end
			},
			Sounds = {},
			Startup = function(list, _, p4)
				local clone = script.Sunflower:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local sunflower = clone.Sunflower
				sunflower:SetAttribute("EmoteProperty", true)
				table.insert(list, sunflower)
				p4.md = sunflower
				sunflower.Part0 = folder.PrimaryPart
				sunflower.Part1 = clone
				sunflower.Parent = folder.PrimaryPart

				if math.random(1, 2) == 1 then
					clone.Handle:Destroy()
				else
					clone.Handle2:Destroy()
				end

				clone.Parent = folder
			end,
			Infinite = true,
			HideWeapon = true,
			Animation = 18897695481,
			Looped = true,
			Stun = "Slowed"
		},
		Run = {
			Keyframes = {
				clap = function(p4)
					if not p4.x then
						p4.x = 1
					end

					fn10({
						SoundId = ({
							"rbxassetid://18844121515",
							"rbxassetid://18844121774",
							"rbxassetid://18844122004",
							"rbxassetid://18844122195"
						})[math.random(1, 4)],
						Parent = p4.x % 2 == 0 and folder["Left Leg"] or folder["Right Leg"],
						Volume = 0.3,
						PlaybackSpeed = 1
					}):Play()
					p4.x += 1
				end
			},
			Sounds = {},
			Startup = function(_, _, _) end,
			Infinite = true,
			Animation = 18897700236,
			Looped = true,
			Stun = "Slowed",
			StunAttribute = 0.825
		},
		Watch = {
			Keyframes = {},
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://9047820458",
					Volume = 1.35,
					Looped = true
				}
			},
			Startup = function(list, _, p4)
				local clone = script.clock:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local rig006 = clone["Rig.006"]
				rig006:SetAttribute("EmoteProperty", true)
				table.insert(list, rig006)
				p4.md = rig006
				rig006.Part0 = folder["Left Arm"]
				rig006.Part1 = clone
				rig006.Parent = folder["Left Arm"]
				clone.Name = "Rig.006"
				clone.Parent = folder
			end,
			Animation = 18897733312,
			Looped = true,
			Stun = "Freeze"
		},
		DJ = {
			Keyframes = {},
			Sounds = {},
			Startup = function(list, _, p4)
				local clone = script.dj_Pad:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local base = clone.Base.Base
				base:SetAttribute("EmoteProperty", true)
				table.insert(list, base)
				p4.md = base
				base.Part0 = folder.PrimaryPart
				base.Part1 = clone.Base
				base.Parent = folder.PrimaryPart
				clone.Parent = folder
				fn10({
					SoundId = "rbxassetid://18844058756",
					Parent = clone.Base,
					Volume = 1
				}):Play()
				task.delay(1.2, function()
					if not clone.Parent then
						return
					end

					fn10({
						SoundId = "rbxassetid://1836681160",
						Parent = clone.Base,
						Volume = 1,
						Looped = true
					}):Play()
				end)
			end,
			Animation = 18897558226,
			Idle = 18897555962,
			Stun = "Slowed",
			StunAttribute = 1.25
		},
		Horn = {
			Keyframes = {},
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://18844027402",
					ParentTorso = true,
					Volume = 1.85
				}
			},
			Startup = function(list, _, p4)
				local clone = script.horn:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local horn = clone.horn
				horn:SetAttribute("EmoteProperty", true)
				table.insert(list, horn)
				p4.md = horn
				horn.Part0 = folder["Right Arm"]
				horn.Part1 = clone
				horn.Parent = folder["Right Arm"]
				clone.Parent = folder
			end,
			Animation = 18897636555,
			Stun = "Slowed",
			StunAttribute = 1.5
		},
		["Big Shoe"] = {
			Keyframes = {},
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://1843650812",
					ParentTorso = true,
					Volume = 1.85,
					TimePosition = 15,
					Looped = true
				}
			},
			Startup = function(list, _, p4)
				local clone = script["big shoe lol"]:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local bigshoelol = clone["big shoe lol"]
				bigshoelol:SetAttribute("EmoteProperty", true)
				table.insert(list, bigshoelol)
				p4.md = bigshoelol
				bigshoelol.Part0 = folder["Right Leg"]
				bigshoelol.Part1 = clone
				bigshoelol.Parent = folder["Right Leg"]
				clone.Parent = folder["Right Leg"]
				fn10({
					SoundId = "rbxassetid://18843835286",
					Parent = clone,
					Volume = 2,
					Looped = true
				}):Play()
			end,
			Animation = 18897707539,
			Looped = true,
			Stun = "Freeze"
		},
		Bhop = {
			Keyframes = {},
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://18844493172",
					ParentTorso = true,
					Volume = 0.5,
					Looped = true
				}
			},
			Startup = function(list, _, p4)
				local clone = script.Plane:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local plane = clone.Plane
				plane:SetAttribute("EmoteProperty", true)
				table.insert(list, plane)
				p4.md = plane
				plane.Part0 = folder["Right Arm"]
				plane.Part1 = clone
				plane.Parent = folder["Right Arm"]
				clone.Parent = folder
			end,
			Fix = true,
			HideWeapon = true,
			Looped = true,
			Animation = 18897499721,
			Stun = "Slowed",
			StunAttribute = 1
		},
		Lollipop = {
			Keyframes = {},
			Sounds = {},
			Startup = function(list, _, p4)
				local clone = script.LeftHandlecand:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				clone.Name = "LeftHandle"
				local leftHandle = clone.LeftHandle
				leftHandle:SetAttribute("EmoteProperty", true)
				table.insert(list, leftHandle)
				p4.md = leftHandle
				leftHandle.Part0 = folder["Left Arm"]
				leftHandle.Part1 = clone
				leftHandle.Parent = folder["Left Arm"]
				clone.Parent = folder
				fn10({
					SoundId = "rbxassetid://18844183460",
					Parent = clone,
					Volume = 1
				}):Play()
			end,
			HideWeapon = true,
			Animation = 18897505064,
			Idle = 18897508344,
			Stun = "Slowed",
			StunAttribute = 1.5
		},
		Treadmill = {
			Keyframes = {
				clap = function(p4)
					if not p4.x then
						p4.x = 1
					end

					shared.sfx({
						SoundId = ({
							"rbxassetid://18844324520",
							"rbxassetid://18844324837",
							"rbxassetid://18844325082"
						})[math.random(1, 3)],
						Parent = p4.x % 2 == 0 and folder["Left Leg"] or folder["Right Leg"],
						Volume = 0.85,
						RollOffMaxDistance = rollOffMaxDistance,
						PlaybackSpeed = 1
					}):Play()
					p4.x += 1
				end
			},
			Sounds = {},
			Startup = function(list, _, p4)
				local clone = script.Treadmill:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local treadmill = clone.Treadmill
				treadmill:SetAttribute("EmoteProperty", true)
				table.insert(list, treadmill)
				p4.md = treadmill
				treadmill.Part0 = folder.PrimaryPart
				treadmill.Part1 = clone
				treadmill.Parent = folder.PrimaryPart
				clone.Parent = folder
				fn10({
					SoundId = "rbxassetid://18844323927",
					Parent = clone,
					Volume = 1
				}):Play()
				fn10({
					SoundId = "rbxassetid://18844324232",
					Parent = clone,
					Volume = 1,
					Looped = true
				}):Play()
				task.spawn(function()
					local v6 = fn14(18897724289)
					local total = 1

					repeat
						task.wait()

						if v6.IsPlaying then
							total += 1e-6
							v6:AdjustSpeed((math.clamp(total, 0, 10)))
						end
					until not clone.Parent
				end)
			end,
			IdleKeyframes = true,
			Infinite = true,
			HideWeapon = true,
			Animation = 18897726542,
			Idle = 18897724289,
			Stun = "Freeze"
		},
		Bear = {
			Keyframes = {
				clap = function(state)
					if not state.x then
						state.x = 1
					end

					fn10({
						SoundId = ({
							"rbxassetid://18846632392",
							"rbxassetid://18846632707",
							"rbxassetid://18846633000",
							"rbxassetid://18846633359"
						})[math.random(1, 4)],
						Parent = state.x % 2 == 0 and state.b["BRight Leg"] or state.b["BLeft Leg"],
						Volume = 0.3,
						PlaybackSpeed = 1
					}):Play()
					state.x += 1

					if state.x % 5 == 0 then
						fn10({
							SoundId = ({
								"rbxassetid://18846691304",
								"rbxassetid://18846691736",
								"rbxassetid://18846692037"
							})[math.random(1, 3)],
							Parent = state.b.Head,
							Volume = 1,
							PlaybackSpeed = 1
						}):Play()
					end
				end
			},
			Sounds = {},
			Startup = function(list, _, p4)
				local clone = script.Bear:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local body = clone.Body.Body
				body:SetAttribute("EmoteProperty", true)
				table.insert(list, body)
				p4.md = body
				body.Part0 = folder.PrimaryPart
				body.Part1 = clone.Body
				body.Parent = folder.PrimaryPart
				clone.Parent = folder
				p4.b = clone
				fn10({
					SoundId = ({ "rbxassetid://18846691304", "rbxassetid://18846691736", "rbxassetid://18846692037" })[math.random(
						1,
						3
					)],
					Parent = p4.b.Head,
					Volume = 1,
					PlaybackSpeed = 1
				}):Play()
			end,
			Infinite = true,
			HideWeapon = true,
			Fix = true,
			Animation = 18897495704,
			Looped = true,
			Stun = "Slowed"
		},
		Cooked = {
			Keyframes = {},
			Sounds = {},
			Startup = function(list, _, p4)
				local clone = script.PanTwo:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local pan = clone.Pan
				pan:SetAttribute("EmoteProperty", true)
				table.insert(list, pan)
				p4.md = pan
				pan.Part0 = folder["Right Arm"]
				pan.Part1 = clone
				pan.Parent = folder["Right Arm"]
				clone.Name = "Pan"
				clone.Parent = folder
				fn10({
					SoundId = "rbxassetid://18829100753",
					Parent = clone,
					Volume = 1,
					Looped = true
				}):Play()
				local clone2 = script.Pancake:Clone()
				clone2:SetAttribute("EmoteProperty", true)
				table.insert(list, clone2)
				p4.Handle = clone2
				local meshesPancake = clone["Meshes/Pancake"]
				meshesPancake:SetAttribute("EmoteProperty", true)
				table.insert(list, meshesPancake)
				p4.md = meshesPancake
				meshesPancake.Part0 = clone
				meshesPancake.Part1 = clone2
				meshesPancake.Parent = clone
				clone2.Parent = folder
			end,
			HideWeapon = true,
			Animation = 18897548874,
			Looped = true,
			Stun = "Freeze"
		},
		["English or Spanish"] = {
			Keyframes = {},
			Sounds = {},
			Startup = function(list, _, p4)
				for _, v6 in pairs({ "English", "Spanish", "TextHandle" }) do
					local clone = script[v6]:Clone()
					clone:SetAttribute("EmoteProperty", true)
					table.insert(list, clone)
					p4.Handle = clone
					local md = clone[v6]
					md:SetAttribute("EmoteProperty", true)
					table.insert(list, md)
					p4.md = md
					md.Part0 = folder.PrimaryPart
					md.Part1 = clone
					md.Parent = folder.PrimaryPart
					clone.Parent = folder
				end

				fn10({
					SoundId = "rbxassetid://18835721216",
					Parent = folder.PrimaryPart,
					Volume = 1
				}):Play()
				fn10({
					SoundId = "rbxassetid://9045031823",
					Parent = folder.PrimaryPart,
					Looped = true,
					Volume = 0.3
				}):Play()
			end,
			HideWeapon = true,
			Animation = 18897604359,
			Idle = 18897610765,
			Stun = "Freeze"
		},
		["Mad Skills"] = {
			Keyframes = {},
			Sounds = {},
			Startup = function(list, _, p4)
				local clone = script.boombox:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local m6d = clone.m6d
				m6d:SetAttribute("EmoteProperty", true)
				table.insert(list, m6d)
				p4.md = m6d
				m6d.Part0 = folder.PrimaryPart
				m6d.Part1 = clone
				m6d.Parent = folder.PrimaryPart
				m6d.Name = "Motor6D"
				clone.Name = "Part"
				clone.Parent = folder.PrimaryPart
				fn10({
					SoundId = "rbxassetid://1846329169",
					Parent = clone,
					Volume = 1,
					Looped = true
				}):Play()
			end,
			HideWeapon = true,
			Animation = 18897639790,
			Looped = true,
			Stun = "Freeze"
		},
		["Around My Way"] = {
			Keyframes = {},
			Sounds = {},
			Startup = function(_, _, _)
				local clone = script.BoomBox:Clone()
				clone:SetAttribute("EmoteProperty", true)
				local boomBox = clone.BoomBox
				boomBox:SetAttribute("EmoteProperty", true)
				boomBox.Part0 = folder.PrimaryPart
				boomBox.Part1 = clone
				boomBox.Parent = folder.PrimaryPart
				clone.Parent = folder
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				task.delay(0.25, function()
					if clone.Parent then
						fn10({
							SoundId = "rbxassetid://18843532846",
							Parent = clone,
							Volume = 1
						}):Play()
					end
				end)
				task.spawn(function()
					local v6 = fn14(18897676267)

					repeat
						task.wait()
					until v6.IsPlaying or not clone.Parent

					if v6.IsPlaying then
						task.wait(2.51)

						if not clone.Parent then
							return
						end

						fn10({
							SoundId = "rbxassetid://18843484198",
							CFrame = clone.CFrame,
							TimePosition = 2.51,
							Volume = 1
						}):Resume()
					end
				end)
				fn10({
					SoundId = "rbxassetid://1843676441",
					Parent = clone,
					Volume = 1,
					Looped = true
				}):Play()
			end,
			HideWeapon = true,
			End = {
				18897676267,
				3.217,
				{
					SoundId = "rbxassetid://18843483804",
					Volume = 1,
					Looped = false
				}
			},
			Idle = 18897673759,
			Animation = 18897679922,
			Looped = false,
			Stun = "Freeze"
		},
		Bindle = {
			Keyframes = {
				clap = function()
					fn10({
						SoundId = "rbxassetid://17849634815",
						Parent = folder.HumanoidRootPart,
						Volume = 1,
						PlaybackSpeed = 1
					}):Play()
				end,
				claploop = function()
					fn10({
						SoundId = "rbxassetid://17849634537",
						Parent = folder.HumanoidRootPart,
						Volume = 1,
						PlaybackSpeed = 1
					}):Play()
				end
			},
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://1838846993",
					Volume = 0.7,
					Looped = true
				}
			},
			Startup = function(list, _, p4)
				local clone = script.Stick:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local stick = clone.Stick
				stick:SetAttribute("EmoteProperty", true)
				table.insert(list, stick)
				p4.md = stick
				stick.Part0 = folder["Right Arm"]
				stick.Part1 = clone
				stick.Parent = folder["Right Arm"]
				clone.Parent = folder
				local clone2 = script.Bag:Clone()
				clone2:SetAttribute("EmoteProperty", true)
				table.insert(list, clone2)
				p4.Handle = clone2
				local bag = clone.Bag
				bag:SetAttribute("EmoteProperty", true)
				table.insert(list, bag)
				p4.md = bag
				bag.Part0 = clone
				bag.Part1 = clone2
				bag.Parent = clone
				clone2.Parent = folder["Right Arm"]
			end,
			HideWeapon = true,
			Animation = 17861837529,
			Looped = true,
			Infinite = true,
			Stun = "Slowed"
		},
		Demon = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://17848180129",
					Volume = 1,
					Looped = false,
					TimePosition = 0.3
				}
			},
			Startup = function(clones, _, clones2)
				local clone = script.DemonParticles.RootAttachment:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(clones, clone)
				table.insert(clones2, clone)
				clone.Parent = folder.HumanoidRootPart
				local Debris = game:GetService("Debris")
				Debris:AddItem(clone, 2)

				for _, child in pairs(clone:GetChildren()) do
					child:Emit(1)
				end
			end,
			Animation = 17861844708,
			Stun = "Freeze",
			HideWeapon = true
		},
		["Sacred Summoning"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://17842803002",
					Volume = 1,
					Looped = false
				}
			},
			IdleSound = {
				SoundId = "rbxassetid://17842803226",
				Volume = 1,
				Looped = true
			},
			Startup = function(p4, _, _)
				fn13("Left", p4, folder)
				fn13("Right", p4, folder)
			end,
			Idle = 17862993552,
			Animation = 17862992081,
			Stun = "Freeze",
			HideWeapon = true
		},
		Frisbee = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://17837903508",
					Volume = 1,
					Looped = false
				}
			},
			Startup = function(list, _, p4)
				local clone = script.Frisbee:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Frisbee = clone
				local frisbee = clone.Frisbee
				frisbee:SetAttribute("EmoteProperty", true)
				table.insert(list, frisbee)
				p4.md = frisbee
				frisbee.Part0 = folder["Right Arm"]
				frisbee.Part1 = clone
				frisbee.Parent = folder["Right Arm"]
				clone.Parent = folder
			end,
			Keyframes = {
				Toss = function(p4)
					p4.Frisbee.Transparency = 1
					local clone = script.Frisbee:Clone()
					CollectionService2:AddTag(clone, "emotestuff" .. folder.Name)
					local Debris = game:GetService("Debris")
					Debris:AddItem(clone, 5)
					clone.CanCollide = true
					clone.CanTouch = true
					clone.CanQuery = false
					clone.Massless = false
					clone.CollisionGroup = "nocol"
					clone.CFrame = folder:GetPivot() * CFrame.new(0, 0, -2.5)
					clone.CustomPhysicalProperties = PhysicalProperties.new(nil, nil, 1, nil, 1)
					clone.Parent = workspace.Thrown
					clone:SetNetworkOwner(playerFromCharacter)
					local now = 0
					clone.AssemblyAngularVelocity = createVector(0, 480, 0)
					clone.AssemblyLinearVelocity = folder:GetPivot().LookVector * 120 + folder:GetPivot().UpVector * 40
					local touchedConnection = clone.Touched:Connect(function(otherPart)
						if otherPart:IsDescendantOf(workspace.Live) or tick() - now < 0.075 or math.abs(clone.Velocity.Y) < 4 then
							return
						end

						now = tick()
						fn10({
							SoundId = "rbxassetid://9114538213",
							Parent = clone,
							Volume = 1,
							PlaybackSpeed = Random.new():NextNumber(0.99, 2)
						}):Play()
					end)
					task.delay(5, function()
						touchedConnection:Disconnect()
					end)
				end
			},
			HideWeapon = true,
			Animation = 17862066234,
			Looped = false,
			Stun = "Slowed"
		},
		["Controller Rage"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://17837716532",
					Volume = 1,
					Looped = false
				}
			},
			Startup = function(list, _, p4)
				local clone = script.Controller:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				clone.Name = "Retopo_Cube.001"
				local retopo_Cube001 = clone["Retopo_Cube.001"]
				retopo_Cube001:SetAttribute("EmoteProperty", true)
				table.insert(list, retopo_Cube001)
				p4.md = retopo_Cube001
				retopo_Cube001.Part0 = folder.HumanoidRootPart
				retopo_Cube001.Part1 = clone
				retopo_Cube001.Parent = folder.HumanoidRootPart
				clone.Parent = folder
			end,
			HideWeapon = true,
			Animation = 17861843594,
			Looped = false,
			Stun = "Freeze"
		},
		["Spare Change"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://17862020768",
					Volume = 1,
					Looped = true
				}
			},
			Startup = function(list, _, p4)
				local clone = script.SpareChangeCup:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				clone.Name = "Handle"
				local handle = clone.Handle
				handle:SetAttribute("EmoteProperty", true)
				table.insert(list, handle)
				p4.md = handle
				handle.Part0 = folder["Right Arm"]
				handle.Part1 = clone
				handle.Parent = folder["Right Arm"]
				clone.Parent = folder
				local clone2 = script.Box:Clone()
				clone2:SetAttribute("EmoteProperty", true)
				table.insert(list, clone2)
				p4.Handle = clone2
				clone2.Name = "RBX"
				local cube002 = clone2["Cube.002"]["Cube.002"]
				cube002:SetAttribute("EmoteProperty", true)
				table.insert(list, cube002)
				p4.md = cube002
				cube002.Part0 = folder.HumanoidRootPart
				cube002.Part1 = clone2["Cube.002"]
				cube002.Parent = folder.HumanoidRootPart
				clone2.Parent = folder
			end,
			HideWeapon = true,
			Animation = 17861773600,
			Looped = true,
			Stun = "Freeze"
		},
		["Boo! Tomato"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://17837284253",
					Volume = 1,
					Looped = false
				}
			},
			Startup = function(list, _, p4)
				local clone = script.TSB_tomato:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.TSB_tomato = clone
				clone.Transparency = 1
				local tSB_tomato = clone.TSB_tomato
				tSB_tomato:SetAttribute("EmoteProperty", true)
				table.insert(list, tSB_tomato)
				p4.md = tSB_tomato
				tSB_tomato.Part0 = folder.HumanoidRootPart
				tSB_tomato.Part1 = clone
				tSB_tomato.Parent = folder.HumanoidRootPart
				clone.Parent = folder
			end,
			Keyframes = {
				TomatoAppear = function(p4)
					p4.TSB_tomato.Transparency = 0
				end,
				Tomato = function(p4)
					p4.TSB_tomato.Transparency = 1
					local clone = script.TSB_tomato:Clone()
					CollectionService2:AddTag(clone, "emotestuff" .. folder.Name)
					local Debris = game:GetService("Debris")
					Debris:AddItem(clone, 5)
					clone.CanCollide = true
					clone.CanTouch = true
					clone.CanQuery = false
					clone.Massless = false
					clone.CollisionGroup = "nocol"
					clone.CFrame = p4.TSB_tomato.CFrame
					clone.CustomPhysicalProperties = PhysicalProperties.new(nil, nil, 1, nil, 1)
					clone.Parent = workspace.Thrown
					clone:SetNetworkOwner(playerFromCharacter)
					local v6 = folder.PrimaryPart.CFrame + folder.PrimaryPart.CFrame.lookVector * 40
					local vector2 = Vector3.new(0, -workspace.Gravity + 70, 0)
					local v7 = folder.PrimaryPart.CFrame * CFrame.new(0, 0, -2)
					local now = 0
					clone.Velocity = (v6.Position - v7.Position - vector2 * 0.5 * 1 * 1) / 1
					local touchedConnection = clone.Touched:Connect(function(otherPart)
						if otherPart:IsDescendantOf(workspace.Live) or tick() - now < 0.075 or math.abs(clone.Velocity.Y) < 4 then
							return
						end

						now = tick()
						fn10({
							SoundId = "rbxassetid://9120112840",
							Parent = clone,
							Volume = 3,
							PlaybackSpeed = Random.new():NextNumber(1.5, 2)
						}):Play()
					end)
					task.delay(5, function()
						if touchedConnection then
							touchedConnection:Disconnect()
						end
					end)
				end
			},
			HideWeapon = true,
			Animation = 17863116997,
			Looped = false,
			Stun = "Freeze"
		},
		["Bottle Flip"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://17837070780",
					Volume = 1,
					Looped = false
				}
			},
			Startup = function(list, _, p4)
				local clone = script.TSB_waterbottle:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.WaterBottle = clone
				local tSB_waterbottle = clone.TSB_waterbottle
				tSB_waterbottle:SetAttribute("EmoteProperty", true)
				table.insert(list, tSB_waterbottle)
				p4.md = tSB_waterbottle
				tSB_waterbottle.Part0 = folder.HumanoidRootPart
				tSB_waterbottle.Part1 = clone
				tSB_waterbottle.Parent = folder.HumanoidRootPart
				clone.Parent = folder
			end,
			Keyframes = {
				Flip = function(p4)
					p4.WaterBottle.Transparency = 1
					local clone = script.TSB_waterbottle:Clone()
					CollectionService2:AddTag(clone, "emotestuff" .. folder.Name)
					local Debris = game:GetService("Debris")
					Debris:AddItem(clone, 5)
					clone.CanCollide = true
					clone.CanTouch = true
					clone.CanQuery = false
					clone.Massless = false
					clone.CollisionGroup = "nocol"
					clone.CFrame = p4.WaterBottle.CFrame
					clone.CustomPhysicalProperties = PhysicalProperties.new(nil, nil, 1, nil, 1)
					clone.Parent = workspace.Thrown
					clone:SetNetworkOwner(playerFromCharacter)
					local v6 = folder.PrimaryPart.CFrame + folder.PrimaryPart.CFrame.lookVector * 20
					local vector2 = Vector3.new(0, -workspace.Gravity, 0)
					local v7 = folder.PrimaryPart.CFrame * createVector(0, 0, -2)
					local now = 0
					clone.Velocity = (v6.Position - v7 - vector2 * 0.5 * 1 * 1) / 1
					clone.AssemblyAngularVelocity = createVector(15, 0, 0)
					local touchedConnection = clone.Touched:Connect(function(otherPart)
						if otherPart:IsDescendantOf(workspace.Live) or tick() - now < 0.075 or math.abs(clone.Velocity.Y) < 4 then
							return
						end

						now = tick()
						fn10({
							SoundId = "rbxassetid://9125743366",
							Parent = clone,
							Volume = 3,
							PlaybackSpeed = Random.new():NextNumber(1.5, 2)
						}):Play()
					end)
					task.delay(5, function()
						touchedConnection:Disconnect()
					end)
				end
			},
			HideWeapon = true,
			Animation = 17863045150,
			Looped = false,
			Stun = "Freeze"
		},
		Golfing = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://17835937472",
					Volume = 1,
					Looped = false
				}
			},
			Startup = function(list, _, p4)
				local clone = script.golfball:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.GolfBall = clone
				local golfball = clone.golfball
				golfball:SetAttribute("EmoteProperty", true)
				table.insert(list, golfball)
				p4.md = golfball
				golfball.Part0 = folder.HumanoidRootPart
				golfball.Part1 = clone
				golfball.Parent = folder.HumanoidRootPart
				clone.Parent = folder
				local clone2 = script.golfclub:Clone()
				clone2:SetAttribute("EmoteProperty", true)
				table.insert(list, clone2)
				p4.Handle = clone2
				local golfclub = clone2.golfclub
				golfclub:SetAttribute("EmoteProperty", true)
				table.insert(list, golfclub)
				p4.md = golfclub
				golfclub.Part0 = folder["Right Arm"]
				golfclub.Part1 = clone2
				golfclub.Parent = folder["Right Arm"]
				clone2.Parent = folder
			end,
			Keyframes = {
				GolfBall = function(p4)
					p4.GolfBall.Transparency = 1
					local clone = script.golfball:Clone()
					CollectionService2:AddTag(clone, "emotestuff" .. folder.Name)
					local Debris = game:GetService("Debris")
					Debris:AddItem(clone, 5)
					clone.CanCollide = true
					clone.CanTouch = true
					clone.CanQuery = false
					clone.Massless = false
					clone.CollisionGroup = "nocol"
					clone.CFrame = p4.GolfBall.CFrame
					clone.CustomPhysicalProperties = PhysicalProperties.new(nil, nil, 1, nil, 1)
					clone.Parent = workspace.Thrown
					clone:SetNetworkOwner(playerFromCharacter)
					local v6 = folder.PrimaryPart.CFrame + folder.PrimaryPart.CFrame.lookVector * 50
					local vector2 = Vector3.new(0, -workspace.Gravity, 0)
					local v7 = folder.PrimaryPart.CFrame * createVector(0, 0, -2)
					local now = 0
					clone.Velocity = (v6.Position - v7 - vector2 * 0.5 * 1 * 1) / 1
					local touchedConnection = clone.Touched:Connect(function(otherPart)
						if otherPart:IsDescendantOf(workspace.Live) or tick() - now < 0.075 or math.abs(clone.Velocity.Y) < 4 then
							return
						end

						now = tick()
						fn10({
							SoundId = "rbxassetid://9114625926",
							Parent = clone,
							Volume = 3,
							PlaybackSpeed = Random.new():NextNumber(0.9, 1.1)
						}):Play()
					end)
					task.delay(5, function()
						touchedConnection:Disconnect()
					end)
				end
			},
			HideWeapon = true,
			Animation = 17863077772,
			Looped = false,
			Stun = "Freeze"
		},
		["Random Dance"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://1844612112",
					Volume = 1,
					Looped = true
				}
			},
			HideWeapon = true,
			Animation = 17861893708,
			Looped = true,
			Stun = "Freeze"
		},
		["Left n' Right"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://9044565954",
					Volume = 1,
					Looped = true
				}
			},
			HideWeapon = true,
			Animation = 17861844224,
			Looped = true,
			Stun = "Freeze"
		},
		["I WILL FEINT"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://17830548577",
					Volume = 1,
					Looped = false
				}
			},
			Startup = function(list, _, p4)
				local clone = script.KickChair:Clone()
				clone.Name = "Chair"
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local chair = clone.Chair
				chair:SetAttribute("EmoteProperty", true)
				table.insert(list, chair)
				p4.md = chair
				chair.Part0 = folder.HumanoidRootPart
				chair.Part1 = clone
				chair.Parent = folder.HumanoidRootPart
				clone.Parent = folder
			end,
			Animation = 17861869602,
			HideWeapon = true,
			Looped = false,
			Stun = "Freeze",
			Fix = true
		},
		["Cat Dancey"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://1841610903",
					Volume = 1,
					Looped = false,
					TimePosition = 5
				}
			},
			HideWeapon = true,
			Animation = 17861842039,
			Looped = true,
			Stun = "Slowed"
		},
		Fresh = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://1843071445",
					Volume = 1,
					Looped = true
				}
			},
			HideWeapon = true,
			Animation = 17863085690,
			Looped = true,
			Stun = "Freeze"
		},
		["Cute Spin"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://1835969978",
					Volume = 1,
					Looped = true
				}
			},
			HideWeapon = true,
			Animation = 17861849696,
			Looped = true,
			Stun = "Freeze"
		},
		["Leapin'"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://1837768352",
					Volume = 1,
					Looped = true
				}
			},
			HideWeapon = true,
			Animation = 17863299880,
			Looped = true,
			Stun = "Slowed"
		},
		["Clubbin'"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://1847692872",
					Volume = 1,
					Looped = true
				}
			},
			HideWeapon = true,
			Animation = 17861870429,
			Looped = true,
			Stun = "Freeze"
		},
		Puzzled = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://17824312884",
					Volume = 1.5,
					Looped = false
				}
			},
			Startup = function(list, _, p4)
				local clone = script.LeftEyebrow:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local leftEyebrow = clone.LeftEyebrow
				leftEyebrow:SetAttribute("EmoteProperty", true)
				table.insert(list, leftEyebrow)
				p4.md = leftEyebrow
				leftEyebrow.Part0 = folder.Head
				leftEyebrow.Part1 = clone
				leftEyebrow.Parent = folder.Head
				clone.Parent = folder.Head
				local clone2 = script.RightEyebrow:Clone()
				clone2:SetAttribute("EmoteProperty", true)
				table.insert(list, clone2)
				p4.Handle = clone2
				local rightEyebrow = clone2.RightEyebrow
				rightEyebrow:SetAttribute("EmoteProperty", true)
				table.insert(list, rightEyebrow)
				p4.md = rightEyebrow
				rightEyebrow.Part0 = folder.Head
				rightEyebrow.Part1 = clone2
				rightEyebrow.Parent = folder.Head
				clone2.Parent = folder.Head
				local clone3 = script.shades:Clone()
				clone3:SetAttribute("EmoteProperty", true)
				table.insert(list, clone3)
				p4.Handle = clone3
				local shades = clone3.shades
				shades:SetAttribute("EmoteProperty", true)
				table.insert(list, shades)
				p4.md = shades
				shades.Part0 = folder.Head
				shades.Part1 = clone3
				shades.Parent = folder.Head
				clone3.Parent = folder
				local clone4 = script.mic:Clone()
				clone4:SetAttribute("EmoteProperty", true)
				table.insert(list, clone4)
				p4.Handle = clone4
				local mic = clone4.mic
				mic:SetAttribute("EmoteProperty", true)
				table.insert(list, mic)
				p4.md = mic
				mic.Part0 = folder["Left Arm"]
				mic.Part1 = clone4
				mic.Parent = folder["Left Arm"]
				clone4.Parent = folder
			end,
			HideWeapon = true,
			Animation = 17862419034,
			Looped = false,
			Stun = "Slowed"
		},
		["Hair Dryer"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://17824222206",
					Volume = 1,
					Looped = false
				}
			},
			Startup = function(list, _, p4)
				local v6 = folder.Head:FindFirstChild("afro") and true or false
				local clone = script.afro:Clone()

				if v6 then
					clone:SetAttribute("EmoteProperty", true)
					table.insert(list, clone)
					p4.Handle = clone
				end

				local afro = clone.afro

				if v6 then
					afro:SetAttribute("EmoteProperty", true)
					table.insert(list, afro)
					p4.md = afro
				end

				afro.Part0 = folder.Head
				afro.Part1 = clone
				afro.Parent = folder.Head
				clone.Parent = folder.Head
				local clone2 = script.HairDryer:Clone()
				clone2:SetAttribute("EmoteProperty", true)
				table.insert(list, clone2)
				p4.Handle = clone2
				local hairDryer = clone2.HairDryer
				hairDryer:SetAttribute("EmoteProperty", true)
				table.insert(list, hairDryer)
				p4.md = hairDryer
				hairDryer.Part0 = folder["Left Arm"]
				hairDryer.Part1 = clone2
				hairDryer.Parent = folder["Left Arm"]
				clone2.Parent = folder
			end,
			HideWeapon = true,
			Animation = 17862799431,
			Looped = false,
			Stun = "Slowed"
		},
		["Club Dance"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://9042719219",
					Volume = 1,
					Looped = true
				}
			},
			HideWeapon = true,
			Animation = 17861842605,
			Stun = "Freeze",
			Looped = true
		},
		["Signature Shuffle"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://78643048115190",
					Volume = 1,
					Looped = true
				}
			},
			HideWeapon = true,
			Looped = true,
			Animation = 17877281437,
			Stun = "Slowed"
		},
		["Shoo!"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://95918662439189",
					Volume = 1,
					Looped = true
				}
			},
			HideWeapon = true,
			Animation = 120410055632356,
			Stun = "Slowed",
			StunAttribute = 1,
			Looped = true
		},
		["Sharp Shooter"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://17824113419",
					Volume = 1,
					Looped = false
				}
			},
			HideWeapon = true,
			Animation = 17861840167,
			Stun = "Freeze"
		},
		Tornado = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://1845194026",
					Volume = 1,
					Looped = true
				}
			},
			Animation = 18459285150,
			Stun = "Slowed",
			Looped = true
		},
		Weakling = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://18459323373",
					Volume = 2,
					Looped = true,
					ParentTorso = true
				}
			},
			Animation = 18459317750,
			Stun = "Freeze",
			Looped = true
		},
		Kitchen = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://18459227961",
					Volume = 4.5
				}
			},
			Startup = function(p4, _, _)
				fn13("Left", p4, folder)
				fn13("Right", p4, folder)
			end,
			IdleSound = {
				SoundId = "rbxassetid://18459227438",
				Volume = 0.5,
				Looped = true
			},
			Idle = 18459220516,
			Animation = 18459215845,
			Stun = "Slowed",
			HideWeapon = true
		},
		Shadow = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://18835841306",
					Volume = 2
				}
			},
			Startup = function(p4, _, _)
				fn13("Left", p4, folder)
				fn13("Right", p4, folder)
			end,
			Idle = 18897705219,
			Animation = 18897703230,
			Stun = "Slowed",
			HideWeapon = true
		},
		Luck = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://18843324948",
					Volume = 1.5
				},
				[0.5] = {
					SoundId = "rbxassetid://18843324678",
					Volume = 0.95,
					Looped = true
				}
			},
			Startup = function(p4, _, _)
				fn13("Left", p4, folder)
				fn13("Right", p4, folder)
			end,
			Idle = 18897669629,
			Animation = 18897667042,
			Stun = "Slowed",
			HideWeapon = true
		},
		Void = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://18459160241",
					Volume = 4.5
				}
			},
			Startup = function(p4, _, _)
				fn13("Right", p4, folder)
			end,
			IdleSound = {
				SoundId = "rbxassetid://18459159579",
				Volume = 0.5,
				Looped = true
			},
			Idle = 18459183268,
			Animation = 18459178353,
			Stun = "Slowed",
			HideWeapon = true
		},
		Four = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://18835391294",
					Volume = 1.25,
					ParentTorso = true
				}
			},
			Startup = function(p4, _, _)
				fn13("Right", p4, folder)
			end,
			Animation = 18897621181,
			Stun = "Slowed",
			StunAttribute = 1.5,
			HideWeapon = true
		},
		["Heart Hands"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://18844562542",
					Volume = 1.25,
					ParentTorso = true
				}
			},
			Startup = function(p4, _, _)
				fn13("Left", p4, folder)
				fn13("Right", p4, folder)
			end,
			Animation = 18897634229,
			Stun = "Freeze",
			HideWeapon = true
		},
		Cheese = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://18828832074",
					Volume = 1.25
				}
			},
			Startup = function(p4, _, _)
				fn13("Left", p4, folder)
				fn13("Right", p4, folder)
			end,
			Animation = 18897523693,
			Stun = "Freeze",
			HideWeapon = true
		},
		["I love TSB"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://18450377533",
					Volume = 1.25
				}
			},
			Startup = function(p4, _, _)
				fn13("Left", p4, folder)
				fn13("Right", p4, folder)
			end,
			Animation = 18450373829,
			Stun = "Slowed",
			HideWeapon = true
		},
		Thinking = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://17862530320",
					Volume = 0.98,
					Looped = true
				}
			},
			Startup = function(list, _, _)
				fn13("Left", list, folder)
				fn13("Right", list, folder)

				for i = 1, 3 do
					local clone = script.HmmDot:Clone()
					clone.Name = i
					clone.Parent = folder
					local motor6D = Instance.new("Motor6D")
					motor6D.C0 = CFrame.new(-1.493, 1.17, -0.086) * CFrame.Angles(0, 3.141592653589793, 0)
					motor6D.Name = i
					motor6D.Part0 = folder.Torso
					motor6D.Part1 = clone
					motor6D.Parent = folder.Torso
					clone:SetAttribute("EmoteProperty", true)
					motor6D:SetAttribute("EmoteProperty", true)
					table.insert(list, clone)
					table.insert(list, motor6D)
				end
			end,
			Animation = 17862470017,
			Looped = true,
			Stun = "Slowed",
			HideWeapon = true
		},
		Stroll = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://9048435290",
					Volume = 0.75,
					Looped = true,
					ParentTorso = true
				}
			},
			Startup = function(list, _, p4)
				local clone = script.yoyorig:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local m6d = clone.m6d
				m6d:SetAttribute("EmoteProperty", true)
				table.insert(list, m6d)
				p4.md = m6d
				m6d.Part0 = folder.HumanoidRootPart
				m6d.Part1 = clone.main
				m6d.Name = "main"
				m6d.Parent = folder.HumanoidRootPart
				local m6d2 = clone.m6d2
				m6d2:SetAttribute("EmoteProperty", true)
				table.insert(list, m6d2)
				p4.md = m6d2
				m6d2.Part0 = folder.HumanoidRootPart
				m6d2.Part1 = clone.yoyostring
				m6d2.Name = "yoyostring"
				m6d2.Parent = folder.HumanoidRootPart
				clone.Parent = folder
			end,
			Animation = 18459518606,
			Stun = "Slowed",
			HideWeapon = true,
			Looped = true
		},
		Guided = {
			Sounds = {},
			Startup = function(list, _, p4)
				local clone = script.BlindGlasses:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local blindGlasses = clone.BlindGlasses
				blindGlasses.Part0 = folder.Head
				blindGlasses.Part1 = clone
				clone.Parent = folder
				local clone2 = script.BlindWalkerThing:Clone()
				clone2:SetAttribute("EmoteProperty", true)
				table.insert(list, clone2)
				p4.Handle = clone2
				local blindWalkerThing = clone2.BlindWalkerThing
				blindWalkerThing:SetAttribute("EmoteProperty", true)
				table.insert(list, blindWalkerThing)
				p4.md = blindWalkerThing
				blindWalkerThing.Part0 = folder["Right Arm"]
				blindWalkerThing.Part1 = clone2
				blindWalkerThing.Parent = folder["Right Arm"]
				clone2.Parent = folder
				fn10({
					SoundId = "rbxassetid://18459664775",
					Volume = 1,
					Looped = true,
					Parent = clone2
				}):Play()
			end,
			Keyframes = {
				clap = function(_, _, _)
					fn10({
						SoundId = "rbxassetid://" .. ({ 7455224144, 7455246815, 7455224490 })[math.random(1, 3)],
						Parent = folder["Left Leg"],
						PlaybackSpeed = 1,
						Volume = 0.8,
						RollOffMaxDistance = rollOffMaxDistance
					}):Play()
				end
			},
			Looped = true,
			Animation = 18459646696,
			Stun = "Slowed",
			HideWeapon = true
		},
		Jello = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://18459375906",
					Volume = 1,
					Looped = false,
					ParentTorso = true
				}
			},
			Startup = function(list, _, p4)
				local clone = script.catjello:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local m6d = clone.m6d
				m6d:SetAttribute("EmoteProperty", true)
				table.insert(list, m6d)
				p4.md = m6d
				m6d.Part0 = folder.HumanoidRootPart
				m6d.Part1 = clone.main
				m6d.Parent = folder.HumanoidRootPart
				clone.Parent = folder
			end,
			Animation = 18459402335,
			Stun = "Slowed",
			HideWeapon = true
		},
		["Knife Trick"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://17862349589",
					Volume = 0.98,
					Looped = true
				}
			},
			Startup = function(list, _, p4)
				local clone = script.Knife:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local knife = clone.Knife
				knife:SetAttribute("EmoteProperty", true)
				table.insert(list, knife)
				p4.md = knife
				knife.Part0 = folder.HumanoidRootPart
				knife.Part1 = clone
				knife.Parent = folder.HumanoidRootPart
				clone.Parent = folder
			end,
			Animation = 17862340094,
			Looped = true,
			Stun = "Slowed",
			HideWeapon = true
		},
		Awe = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://17822653772",
					Volume = 1,
					Looped = true
				}
			},
			Startup = function(list, _, p4)
				local clone = script.Cube:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local cube = clone.Cube
				cube:SetAttribute("EmoteProperty", true)
				table.insert(list, cube)
				p4.md = cube
				clone.Name = "Cube"
				cube.Part0 = folder["Right Arm"]
				cube.Part1 = clone
				cube.Parent = folder["Right Arm"]
				clone.Parent = folder
			end,
			Animation = 17863040703,
			Looped = false,
			Stun = "Slowed",
			HideWeapon = true
		},
		["Rough Snack"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://17862187721",
					Volume = 0.98,
					Looped = true
				}
			},
			Startup = function(list, _, p4)
				local clone = script.Brick:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local handle = clone.Handle
				handle:SetAttribute("EmoteProperty", true)
				table.insert(list, handle)
				p4.md = handle
				clone.Name = "Brick"
				handle.Part0 = folder["Right Arm"]
				handle.Part1 = clone
				handle.Parent = folder["Right Arm"]
				clone.Parent = folder
			end,
			Animation = 17862170658,
			Looped = true,
			Stun = "Slowed",
			HideWeapon = true
		},
		["Eureka!"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://17822481294",
					Volume = 0.76,
					Looped = false
				}
			},
			Startup = function(list, _, p4)
				local clone = script.Lightbulb:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local handle = clone.Handle
				handle:SetAttribute("EmoteProperty", true)
				table.insert(list, handle)
				p4.md = handle
				clone.Name = "Lightbulb"
				handle.Part0 = folder.HumanoidRootPart
				handle.Part1 = clone
				handle.Parent = folder.HumanoidRootPart
				clone.Parent = folder
			end,
			HideWeapon = true,
			Animation = 17861846501,
			Looped = false,
			Stun = "Freeze"
		},
		["Road Trip"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://17837049421",
					Volume = 1,
					Looped = false
				}
			},
			IdleSound = {
				SoundId = "rbxassetid://17862032072",
				Volume = 0.35,
				Looped = true
			},
			Startup = function(list, _, p4)
				local clone = script.Car:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local handle = clone.Handle
				handle:SetAttribute("EmoteProperty", true)
				table.insert(list, handle)
				p4.md = handle
				clone.Name = "Car"
				handle.Part0 = folder.HumanoidRootPart
				handle.Part1 = clone
				clone.Parent = folder
			end,
			Idle = 17863104140,
			Animation = 17861887753,
			Stun = "Slowed",
			StunAttribute = 1,
			HideWeapon = true
		},
		["Point Shuffle"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://1840434670",
					Volume = 1,
					Looped = true
				}
			},
			HideWeapon = true,
			Animation = 17861883497,
			Looped = true,
			Stun = "Freeze"
		},
		["Watermelon Spin"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://17863074688",
					Volume = 1,
					Looped = true
				}
			},
			Startup = function(list, _, p4)
				local clone = script.WatermelonSpin:Clone()
				clone.Name = "WaterMelon"
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local handle = clone.Handle
				handle:SetAttribute("EmoteProperty", true)
				table.insert(list, handle)
				p4.md = handle
				clone.Name = "Watermelon"
				handle.Part0 = folder["Right Arm"]
				handle.Part1 = clone
				handle.Parent = folder["Right Arm"]
				clone.Parent = folder
			end,
			Animation = 17863063827,
			Stun = "Slowed",
			Looped = true,
			HideWeapon = true
		},
		Livin = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://1837768517",
					Volume = 1,
					Looped = true
				}
			},
			Animation = 17861873461,
			Stun = "Freeze",
			Looped = true,
			HideWeapon = true
		}
	}
	local sounds = {
		[0] = {
			SoundId = "rbxassetid://17849425726",
			Volume = 0.8,
			Looped = true
		}
	}
	sounds[0] = {
		SoundId = "rbxassetid://1841726277",
		Volume = 1,
		Looped = true
	}
	v5.Sassy = {
		Sounds = sounds,
		Startup = function(list, _, _)
			local clone = script.Purse:Clone()
			clone:SetAttribute("EmoteProperty", true)
			CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			local motor6D = Instance.new("Motor6D")
			motor6D:SetAttribute("EmoteProperty", true)
			CollectionService2:AddTag(motor6D, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			motor6D.C0 = CFrame.new(0.011, -0.531, 0)
			motor6D.Part0 = folder["Left Arm"]
			motor6D.Part1 = clone.PrimaryPart
			motor6D.Parent = folder["Left Arm"]
			clone.Parent = folder
			table.insert(list, clone)
			table.insert(list, motor6D)
		end,
		Animation = 17861893094,
		Looped = true,
		Stun = "Slowed",
		HideWeapon = true
	}
	v5["Drum Major"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1846943603",
				Volume = 1,
				Looped = true
			}
		},
		Startup = function(list, _, _)
			local clone = script.Rbx:Clone()
			clone:SetAttribute("EmoteProperty", true)
			CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			clone.Parent = folder
			local motor6D = Instance.new("Motor6D")
			motor6D:SetAttribute("EmoteProperty", true)
			CollectionService2:AddTag(motor6D, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			motor6D.C0 = CFrame.new(-0.325, -0.891, -0.064)
			motor6D.C1 = CFrame.new(0, 0, 0.604)
			motor6D.Part0 = folder["Right Arm"]
			motor6D.Part1 = clone.PrimaryPart
			motor6D.Parent = folder["Right Arm"]
			table.insert(list, clone)
			table.insert(list, motor6D)
		end,
		Animation = 18418313278,
		Stun = "Slowed",
		HideWeapon = true,
		Looped = true
	}
	v5.Helicopter = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://9114024539",
				Volume = 1,
				Looped = false
			}
		},
		IdleSound = {
			SoundId = "rbxassetid://9100684862",
			Volume = 0.25,
			Looped = true
		},
		Idle = 17862998594,
		Animation = 17862997402,
		Stun = "Slowed",
		HideWeapon = true
	}
	v5["Club Shuffle"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1839270703",
				Volume = 0.6,
				Looped = true
			}
		},
		Animation = 17861834531,
		Looped = true,
		Stun = "Slowed",
		HideWeapon = true
	}
	v5["Head Tap"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1845508064",
				Volume = 1,
				Looped = true
			}
		},
		Animation = 17863050431,
		Looped = true,
		Stun = "Freeze",
		HideWeapon = true
	}
	v5.Listen = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://9047324264",
				Volume = 0.85,
				Looped = true,
				TimePosition = 10,
				ParentTorso = true
			}
		},
		Looped = true,
		Animation = 17861894459,
		Stun = "Slowed",
		HideWeapon = true
	}
	v5["Can't See Me"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17813330585",
				Volume = 1,
				Looped = false,
				ParentTorso = true
			}
		},
		HideWeapon = true,
		Startup = function(p4, _, _)
			fn13("Left", p4, folder)
			fn13("Right", p4, folder)
		end,
		Animation = 17862366649,
		Stun = "Slowed"
	}
	v5.Rest = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15443862609",
				Volume = 1,
				Looped = false,
				ParentTorso = true
			}
		},
		End = {
			15443689801,
			3.7,
			{
				SoundId = "rbxassetid://15443922202",
				Volume = 1,
				Looped = false
			}
		},
		Idle = 15443688094,
		Animation = 15443682006,
		Stun = "Freeze"
	}
	v5["Show 'Em"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://140238630247057",
				Volume = 0.4,
				Looped = true,
				ParentTorso = true
			}
		},
		Looped = true,
		Animation = 137797933797894,
		Stun = "Slowed"
	}
	v5.Groove = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1842772099",
				Volume = 0.85,
				TimePosition = 12,
				Looped = true,
				ParentTorso = true
			}
		},
		Looped = true,
		Animation = 16525536622,
		Stun = "Slowed"
	}
	v5["Party Lover"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1840463359",
				Volume = 0.6,
				TimePosition = 2.75,
				Looped = true,
				ParentTorso = true
			}
		},
		Looped = true,
		Animation = 16528092313,
		Stun = "Freeze"
	}
	v5.Giant = {
		Sounds = {},
		Keyframes = {
			clap = function(_)
				fn10({
					SoundId = "rbxassetid://16526736324",
					Volume = 0.8,
					Parent = folder.Torso
				}):Play()
			end
		},
		Infinite = true,
		Looped = true,
		Animation = 16526624122,
		Stun = "Slowed"
	}
	v5.Phonk = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://14145620056",
				Volume = 0.85,
				Looped = true,
				TimePosition = 5,
				ParentTorso = true
			}
		},
		Keyframes = {
			clap = function(p4)
				fn10({
					SoundId = "rbxassetid://2704706975",
					Volume = p4.first and 0.65 or 1,
					Parent = folder.Head
				}):Play()

				if not p4.first then
					p4.first = true
				end
			end
		},
		Infinite = true,
		Looped = true,
		Animation = 16526164064,
		Stun = "Freeze"
	}
	v5.Angel = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://0",
				Volume = 0.5,
				Looped = true,
				ParentTorso = true
			}
		},
		Startup = function(_, _, _)
			local clone = script.untitled:Clone()
			clone:SetAttribute("EmoteProperty", true)
			CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			local m6d = clone.m6d
			m6d:SetAttribute("EmoteProperty", true)
			CollectionService2:AddTag(m6d, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			m6d.Name = "Cube.007"
			m6d.Part1 = clone["Cube.007"]
			m6d.Part0 = folder.Torso
			m6d.Parent = folder.Torso
			clone.Parent = folder
		end,
		Keyframes = {
			clap = function()
				fn10({
					SoundId = ({
						"rbxassetid://137024005187459",
						"rbxassetid://76278400824030",
						"rbxassetid://94509235587766"
					})[math.random(1, 3)],
					Volume = 0.4,
					PlaybackSpeed = 1.15,
					Parent = folder.Torso
				}):Play()
			end
		},
		Animation = 136571320124330,
		Looped = true,
		Infinite = true,
		Stun = "Slowed",
		StunAttribute = 1
	}
	v5.Soccer = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1845023041",
				Volume = 0.5,
				Looped = true,
				TimePosition = 0.5
			}
		},
		Startup = function(_, _, _)
			local clone = script.soccer:Clone()
			clone:SetAttribute("EmoteProperty", true)
			CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			local ball = clone.Handle.Ball
			ball:SetAttribute("EmoteProperty", true)
			CollectionService2:AddTag(ball, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			ball.Name = "Ball"
			ball.Part0 = clone.Handle
			ball.Part1 = clone.Ball
			local m6d = clone.m6d
			m6d:SetAttribute("EmoteProperty", true)
			CollectionService2:AddTag(m6d, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			m6d.Name = "Handle"
			m6d.Part0 = folder.Torso
			m6d.Part1 = clone.Handle
			m6d.Parent = folder.Torso
			clone.Parent = folder
			shared.sfx({
				SoundId = "rbxassetid://16592084595",
				Parent = clone.Ball,
				RollOffMaxDistance = rollOffMaxDistance,
				Volume = 1,
				Looped = true
			}):Play()
		end,
		Animation = 16592100518,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Red Card"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16591667187",
				Volume = 0,
				Looped = false,
				ParentTorso = true
			}
		},
		Startup = function(_, _, p4)
			local clone = script.whistlecard:Clone()
			clone:SetAttribute("EmoteProperty", true)
			CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			local m6d = clone.m6d
			m6d:SetAttribute("EmoteProperty", true)
			CollectionService2:AddTag(m6d, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			m6d.Name = "Handle"
			m6d.Part0 = folder["Left Arm"]
			m6d.Part1 = clone.Handle
			m6d.Parent = folder["Left Arm"]
			clone.Parent = folder["Left Arm"]
			p4.whistle = clone.whistle
			p4.card = clone.redcard
		end,
		Keyframes = {
			whistle = function(p4, _, _)
				TweenService:Create(p4.whistle, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = Vector3.new()
				}):Play()
			end,
			card = function(p4, _, _)
				TweenService:Create(p4.card, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = Vector3.new()
				}):Play()
			end
		},
		Animation = 16591707771,
		HideWeapon = true,
		Stun = "Freeze"
	}
	v5["Your Grave"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16599031707",
				Volume = 1,
				Looped = true,
				ParentTorso = true
			}
		},
		Startup = function(list, _, _)
			local clone = script.Dig.Handle:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			local m6d = clone.m6d
			m6d:SetAttribute("EmoteProperty", true)
			table.insert(list, m6d)
			CollectionService2:AddTag(m6d, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			m6d.Name = "Handle"
			m6d.Part0 = folder["Right Arm"]
			m6d.Part1 = clone
			m6d.Parent = folder["Right Arm"]
			clone.Parent = folder
			local clone2 = script.Dig.Grave:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(list, clone2)
			local weld = Instance.new("Weld")
			weld:SetAttribute("EmoteProperty", true)
			table.insert(list, weld)
			weld.Part0 = folder.PrimaryPart
			weld.Part1 = clone2.Headstone
			weld.Parent = clone2
			weld.C0 = CFrame.new(
				1.59004211,
				-1.53838396,
				-5.02381897,
				-0.999934554,
				-0.0114461109,
				0,
				-0.0114019588,
				0.996077538,
				-0.0877478421,
				0.00100437133,
				-0.0877420902,
				-0.996142864
			)
			clone2.Parent = folder
		end,
		Looped = true,
		Animation = 16598916589,
		HideWeapon = true,
		Stun = "Freeze"
	}
	v5.Slingshot = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16598662412",
				Volume = 1,
				Looped = false,
				ParentTorso = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.slingshot:Clone()
			clone:SetAttribute("EmoteProperty", true)
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			local m6d = clone.m6d
			m6d:SetAttribute("EmoteProperty", true)
			m6d:SetAttribute("EmoteProperty", true)
			table.insert(list, m6d)
			CollectionService2:AddTag(m6d, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			m6d.Name = "Handle"
			m6d.Part0 = folder["Right Arm"]
			m6d.Part1 = clone.Handle
			m6d.Parent = folder["Right Arm"]
			clone.Parent = folder["Right Arm"]
			p4.rock = clone.rock
			p4.rock.Trail.Enabled = false
		end,
		Keyframes = {
			go = function(p4, _, _)
				local clone = p4.rock:Clone()
				CollectionService2:AddTag(clone, "emotestuff" .. folder.Name)
				local Debris = game:GetService("Debris")
				Debris:AddItem(clone, 5)
				clone.CanCollide = false
				clone.CanTouch = true
				clone.CanQuery = false
				clone.Massless = false
				clone.CollisionGroup = "nocol"
				clone.CFrame = p4.rock.CFrame
				clone.Trail.Enabled = true
				p4.rock:Destroy()
				clone.Parent = workspace.Thrown
				shared.sfx({
					SoundId = "rbxassetid://9120435415",
					Parent = clone,
					Volume = 2
				}):Play()
				local attachment = Instance.new("Attachment", clone)
				attachment.Position = createVector(0, 0, 0)
				local linearVelocity = Instance.new("LinearVelocity", attachment)
				linearVelocity.MaxForce = 40000
				linearVelocity.VectorVelocity = folder.PrimaryPart.CFrame.lookVector * 200 + createVector(0, 20, 0)
				linearVelocity.Attachment0 = attachment
				local Debris2 = game:GetService("Debris")
				Debris2:AddItem(linearVelocity, 0.15)
				clone:SetNetworkOwner(playerFromCharacter)
			end
		},
		Animation = 16598695404,
		HideWeapon = true,
		Stun = "Freeze"
	}
	v5.Paddleball = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16523730144",
				Volume = 1,
				Looped = false,
				ParentTorso = true
			},
			[0.45] = {
				SoundId = "rbxassetid://16523118734",
				Volume = 1,
				Looped = true,
				ParentTorso = true
			}
		},
		Startup = function(_, _, _)
			local clone = script.paddle:Clone()
			clone:SetAttribute("EmoteProperty", true)
			CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			local m6d = clone.m6d
			m6d:SetAttribute("EmoteProperty", true)
			CollectionService2:AddTag(m6d, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			m6d.Name = "Wood"
			m6d.Part0 = folder["Right Arm"]
			m6d.Part1 = clone.Wood
			m6d.Parent = folder["Right Arm"]
			clone.Parent = folder["Right Arm"]
		end,
		End = {
			16523235955,
			1.583,
			{
				SoundId = "rbxassetid://16523118347",
				Volume = 1,
				Looped = false
			}
		},
		Idle = 16523084292,
		Animation = 16523080348,
		HideWeapon = true,
		Stun = "Slowed"
	}
	v5["Show Me"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16038705978",
				Volume = 0.75,
				Looped = false,
				ParentTorso = true
			}
		},
		Fix = true,
		Animation = 16039093008,
		Stun = "Freeze"
	}
	v5.Sneak = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16746897032",
				Volume = 0.75,
				Looped = true,
				ParentTorso = true
			}
		},
		Looped = true,
		Animation = 16746892678,
		Stun = "Slowed"
	}
	v5["What'd You Say"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://9042800221",
				Volume = 0.75,
				Looped = true,
				ParentTorso = true
			}
		},
		Looped = true,
		Animation = 17266193826,
		Stun = "Freeze"
	}
	v5.Robot = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17086745893",
				Volume = 0.75,
				Looped = true,
				ParentTorso = true
			},
			[0.01] = {
				SoundId = "rbxassetid://1841609664",
				Volume = 0.45,
				Looped = true
			}
		},
		Looped = true,
		Animation = 17086754292,
		Stun = "Slowed"
	}
	v5["Bye Bye"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1835831314",
				Volume = 0.65,
				Looped = false,
				ParentTorso = true
			}
		},
		Startup = function(p4, _, _)
			fn13("Left", p4, folder)
			fn13("Right", p4, folder)
		end,
		Keyframes = {
			slow = function(_, _, object2)
				object2:AdjustSpeed(0.135)
			end,
			back = function(_, _, object2)
				object2:AdjustSpeed(1)
			end
		},
		HideWeapon = true,
		Animation = 16047480326,
		Stun = "Slowed"
	}
	v5.Fidget = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16524816499",
				Volume = 0.15,
				Looped = true,
				TimePosition = 0.033,
				ParentTorso = true
			}
		},
		Startup = function(p4, _, _)
			fn13("Left", p4, folder)
			fn13("Right", p4, folder)
		end,
		Looped = true,
		HideWeapon = true,
		Animation = 16524848169,
		Stun = "Slowed"
	}
	v5["Thumbs Up"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16524556850",
				Volume = 1.5,
				Looped = false,
				ParentTorso = true
			}
		},
		Startup = function(p4, _, _)
			fn13("Left", p4, folder)
		end,
		HideWeapon = true,
		Animation = 16524522673,
		Stun = "Freeze"
	}
	v5["Nah, I'd win."] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16746854243",
				Volume = 1.5,
				Looped = false,
				ParentTorso = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.dialogue:Clone()
			table.insert(list, clone)
			clone:SetAttribute("EmoteProperty", true)
			p4.rock = clone
			clone.Name = "Handle"
			table.insert(list, clone)
			local m6d = clone.m6d
			table.insert(list, m6d)
			m6d:SetAttribute("EmoteProperty", true)
			m6d.Name = "Handle"
			m6d.Part0 = folder.HumanoidRootPart
			m6d.Part1 = clone
			m6d.Parent = folder.HumanoidRootPart

			for _, part in pairs(clone:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Transparency = 1
				end
			end

			clone.Parent = folder
		end,
		Keyframes = {
			visible = function(p4, _, _)
				if p4.rock then
					for _, part in pairs(p4.rock:GetDescendants()) do
						if part:IsA("BasePart") then
							part.Transparency = 0
						end
					end
				end
			end
		},
		Animation = 16746843881,
		Stun = "Freeze"
	}
	v5.Bang = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16746816646",
				Volume = 1.5,
				Looped = false,
				ParentTorso = true
			}
		},
		Startup = function(p4, _, _)
			fn13("Right", p4, folder)
			fn13("Left", p4, folder)
		end,
		HideWeapon = true,
		Animation = 16746824621,
		Stun = "Slowed"
	}
	v5["Thumbs Down"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16524473840",
				Volume = 1.5,
				Looped = false,
				ParentTorso = true
			}
		},
		Startup = function(p4, _, _)
			fn13("Right", p4, folder)
		end,
		HideWeapon = true,
		Animation = 16524478599,
		Stun = "Freeze"
	}
	v5["Nuh uh"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16054202674",
				Volume = 1,
				Looped = false,
				ParentTorso = true
			}
		},
		Startup = function(p4, _, _)
			fn13("Left", p4, folder)
			fn13("Right", p4, folder)
		end,
		Animation = 16054192884,
		Stun = "Slowed"
	}
	v5["Found You"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://111853897255351",
				Volume = 1,
				Looped = false,
				ParentTorso = true
			}
		},
		Startup = function(p4, _, _)
			fn13("Left", p4, folder)
			fn13("Right", p4, folder)
		end,
		HideWeapon = true,
		Idle = 124365816989281,
		Animation = 136211118072154,
		Stun = "Freeze"
	}
	v5["I'll Win"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16039057960",
				Volume = 1,
				Looped = false,
				ParentTorso = true
			}
		},
		Startup = function(p4, _, p5)
			fn13("Left", p4, folder)
			local rThumb2 = fn13("Right", p4, folder):FindFirstChild("RThumb2", true)

			if rThumb2 then
				local clone = script.QuickStar:Clone()
				clone.Parent = rThumb2
				p5.p = clone
			end
		end,
		Keyframes = {
			star = function(p4, _, _)
				if p4.p then
					p4.p:Emit(1)
					fn10({
						SoundId = "rbxassetid://16039062716",
						Parent = p4.p.Parent,
						Volume = 0.75
					}):Play()
				end
			end
		},
		HideWeapon = true,
		Animation = 16039070113,
		Stun = "Freeze"
	}
	v5["Am Dead"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16002440477",
				Volume = 2,
				TimePosition = 0.125,
				Looped = false,
				ParentTorso = true
			}
		},
		Startup = function(_, _, _)
			local clone = script.Coffin:Clone()
			CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			local coffin = clone.Coffin
			CollectionService2:AddTag(coffin, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			coffin.Part0 = folder.PrimaryPart
			coffin.Part1 = clone
			coffin.Parent = folder.PrimaryPart
			clone.Parent = folder
		end,
		End = {
			16002450289,
			1.767,
			{
				SoundId = "rbxassetid://16002440403",
				Volume = 2,
				Looped = false
			}
		},
		HideWeapon = true,
		Idle = 16002449836,
		Animation = 16002448046,
		FixRotation = true,
		Stun = "Freeze"
	}
	v5.Footwork = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16599237654",
				Volume = 2,
				Looped = false,
				ParentTorso = true
			},
			[0.01] = {
				SoundId = "rbxassetid://1846142716",
				Volume = 0.9,
				Looped = true
			}
		},
		Startup = function(list, _, _)
			local clone = script.hat:Clone()
			table.insert(list, clone)
			clone:SetAttribute("EmoteProperty", true)
			clone.Name = "Handle"
			CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			local handle = clone.Handle
			table.insert(list, handle)
			handle:SetAttribute("EmoteProperty", true)
			handle.Part0 = folder["Left Arm"]
			handle.Part1 = clone
			handle.Parent = folder["Left Arm"]
			clone.Parent = folder
		end,
		Idle = 16599253604,
		Animation = 16599248351,
		Stun = "Slowed",
		StunAttribute = 2
	}
	v5.Footrest = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15968669383",
				Volume = 1,
				Looped = false,
				ParentTorso = true
			}
		},
		Startup = function(_, _, _)
			local clone = script.RockMesh:Clone()
			CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			clone.Rock.Part0 = folder.PrimaryPart
			clone.Rock.Part1 = clone
			clone.Parent = folder
		end,
		End = {
			15968735423,
			1.767,
			{
				SoundId = "rbxassetid://15968669594",
				Volume = 1,
				Looped = false
			}
		},
		Idle = 15968655778,
		Animation = 15968649951,
		FixRotation = true,
		Stun = "Freeze"
	}
	v5["Sit 4"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17122085420",
				Volume = 1,
				ParentTorso = true
			}
		},
		End = {
			17121885697,
			2.217,
			{
				SoundId = "rbxassetid://17122185340",
				Volume = 1,
				Looped = false
			}
		},
		Idle = 17121883892,
		Animation = 17121881258,
		FixRotation = true,
		Stun = "Freeze"
	}
	v5["Sit 3"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15443950040",
				Volume = 1,
				Looped = false,
				ParentTorso = true
			}
		},
		End = {
			15443958574,
			3.7,
			{
				SoundId = "rbxassetid://15443949954",
				Volume = 1,
				Looped = false
			}
		},
		Idle = 15443956544,
		Animation = 15443954093,
		FixRotation = true,
		Stun = "Freeze"
	}
	v5.Chosen = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://18843153605",
				Volume = 1.2,
				Looped = false,
				ParentTorso = true
			},
			[0.5] = {
				SoundId = "rbxassetid://1838611838",
				Volume = 0.5,
				Looped = true,
				TimePosition = 33,
				Smooth = true
			}
		},
		Startup = function(list)
			local cfolder = shared.cfolder({
				Name = "Freeze"
			}, 2.067)
			table.insert(list, cfolder)
			cfolder:SetAttribute("DontInterrupt", true)
			cfolder:SetAttribute("NoStop", true)
			cfolder:SetAttribute("EmoteProperty", true)
			task.delay(0, function()
				cfolder.Parent = folder
			end)
			local clone = script.chosenparticles:Clone()
			clone:SetAttribute("EmoteProperty", true)
			CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			local v8 = {}

			for _, beam in pairs(clone:GetChildren()) do
				if not (beam:IsA("Beam") and beam.Enabled) then
					continue
				end

				table.insert(v8, { beam, beam.Width1 })
				beam.Enabled = false
				beam.Width1 = 0
			end

			local weld = Instance.new("Weld")
			weld.Part0 = folder.PrimaryPart
			weld.Part1 = clone
			weld.C0 = CFrame.new(
				-1.32054138,
				4.14816093,
				1.88685989,
				1,
				0,
				0,
				0,
				0.965925872,
				0.258818984,
				0,
				-0.258818984,
				0.965925872
			)
			weld.Parent = clone
			clone.Parent = folder
			task.delay(2, function()
				for _, v9 in pairs(v8) do
					local v10 = v9[1]
					v10.Enabled = true
					TweenService:Create(
						v10,
						TweenInfo.new(1 + math.random(), Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{
							Width1 = v9[2]
						}
					):Play()
				end
			end)
		end,
		Idle = 18897538537,
		Animation = 18897534746,
		FixAnimations = { 18897538537, 18897534746, 18897540724 },
		End = {
			18897540724,
			2.133,
			{
				SoundId = "rbxassetid://15443922202",
				Volume = 1,
				Looped = false
			}
		},
		Fix = true,
		Stun = "Slowed"
	}
	v5.Attack = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://18843637571",
				Volume = 1.2,
				Looped = false,
				ParentTorso = true
			}
		},
		Startup = function(_) end,
		Idle = 18897713456,
		Animation = 18897711135,
		Stun = "Freeze"
	}
	v5.Honored = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15503052959",
				Volume = 1.2,
				Looped = false,
				ParentTorso = true
			},
			[0.1] = {
				SoundId = "rbxassetid://1839209784",
				Volume = 0.5,
				Looped = false,
				ParentTorso = true
			},
			[4.627] = {
				SoundId = "rbxassetid://1836640331",
				Volume = 0.5,
				Looped = true,
				TimePosition = 33,
				Smooth = true
			}
		},
		Startup = function(list)
			local cfolder = shared.cfolder({
				Name = "Freeze"
			}, 3.922)
			table.insert(list, cfolder)
			cfolder:SetAttribute("DontInterrupt", true)
			cfolder:SetAttribute("NoStop", true)
			cfolder:SetAttribute("EmoteProperty", true)
			task.delay(0, function()
				cfolder.Parent = folder
			end)
		end,
		Idle = 15503060948,
		Animation = 15503060232,
		Fix = true,
		Stun = "Slowed"
	}
	v5.Disgraced = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15503840444",
				Volume = 1.2,
				Looped = false,
				ParentTorso = true
			},
			[2.183] = {
				SoundId = "rbxassetid://1836253240",
				Volume = 0.35,
				Looped = true,
				ParentTorso = true
			}
		},
		Startup = function(list)
			local cfolder = shared.cfolder({
				Name = "Freeze"
			}, 1.856)
			table.insert(list, cfolder)
			cfolder:SetAttribute("DontInterrupt", true)
			cfolder:SetAttribute("NoStop", true)
			cfolder:SetAttribute("EmoteProperty", true)
			task.delay(0, function()
				cfolder.Parent = folder
			end)
		end,
		Idle = 15507138928,
		Animation = 15507137974,
		Fix = true,
		Stun = "Slowed"
	}
	v5["360"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16002725651",
				Volume = 0.75,
				ParentTorso = true,
				Looped = false
			}
		},
		HideWeapon = true,
		Animation = 16002726844,
		Looped = false,
		Stun = "Freeze"
	}
	v5["Jumping Jacks"] = {
		Sounds = {},
		Keyframes = {
			clap = function(_, _, _)
				fn10({
					SoundId = "rbxassetid://16002741222",
					Parent = folder.Torso,
					Volume = 1
				}):Play()
			end
		},
		HideWeapon = true,
		Animation = 16002745906,
		Looped = true,
		Stun = "Freeze",
		Infinite = true
	}
	v5.Calculated = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16002706827",
				Volume = 1,
				ParentTorso = true,
				Looped = false
			}
		},
		Keyframes = {
			start = function(_, list, _)
				local attachment = Instance.new("Attachment")
				attachment:SetAttribute("EmoteProperty", true)
				table.insert(list, attachment)
				attachment.Parent = folder.PrimaryPart
				attachment.Position = createVector(0.554, 3.069, -0.744)
				local clone = script.Iq:Clone()
				clone.Parent = attachment
				clone:Emit(1)
				fn10({
					SoundId = "rbxassetid://16002767572",
					Volume = 0.25,
					Parent = attachment,
					Looped = false
				}):Play()
			end
		},
		HideWeapon = true,
		Animation = 16002681909,
		Looped = false,
		Stun = "Freeze"
	}
	v5["Huh?"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16524017206",
				Volume = 0.75,
				ParentTorso = true,
				Looped = false
			}
		},
		Keyframes = {
			question = function(_, list, _)
				local attachment = Instance.new("Attachment")
				attachment:SetAttribute("EmoteProperty", true)
				table.insert(list, attachment)
				attachment.Parent = folder.PrimaryPart
				attachment.CFrame = CFrame.new(
					0.635131836,
					1.59469604,
					-1.50006104,
					0.873728812,
					0.4864133,
					-0,
					-0.4864133,
					0.873728812,
					0,
					0,
					0,
					0.99999994
				)
				local clone = script.Question:Clone()
				clone.Parent = attachment
				clone:Emit(1)
				fn10({
					SoundId = "rbxassetid://16524026100",
					Volume = 0.75,
					Parent = attachment,
					Looped = false
				}):Play()
			end
		},
		Startup = function(list, _, p4)
			local clone = script.teacup:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local clone2 = clone.LeftHandle:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(list, clone2)
			clone2["Meshes/teacup_Circle"].Part0 = clone2
			clone2["Meshes/teacup_Circle"].Part1 = clone["Meshes/teacup_Circle"]
			clone2.Parent = folder
			local m6d = clone.m6d
			m6d:SetAttribute("EmoteProperty", true)
			table.insert(list, m6d)
			p4.md = m6d
			m6d.Part0 = folder["Left Arm"]
			m6d.Name = "LeftHandle"
			m6d.Part1 = clone2
			m6d.Parent = folder["Left Arm"]
			clone.Parent = folder
		end,
		HideWeapon = true,
		Animation = 16523856701,
		Looped = false,
		Stun = "Slowed"
	}
	v5["8 Bit"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1839918500",
				Volume = 0.75,
				TimePosition = 1,
				ParentTorso = true,
				Looped = false
			}
		},
		Keyframes = {
			shoot = function(_, list, _)
				local attachment = Instance.new("Attachment")
				attachment:SetAttribute("EmoteProperty", true)
				table.insert(list, attachment)
				attachment.Parent = folder.PrimaryPart
				attachment.Position = createVector(1.75, 0.25, -3.75)
				local clone = script.Shoot:Clone()
				clone.Parent = attachment
				clone:Emit(1)
				fn10({
					SoundId = "rbxassetid://15684595588",
					Volume = 1.85,
					Parent = folder["Right Arm"],
					Looped = false
				}):Play()
			end,
			heart = function(_, list, _)
				local attachment = Instance.new("Attachment")
				attachment:SetAttribute("EmoteProperty", true)
				table.insert(list, attachment)
				attachment.Parent = folder.PrimaryPart
				attachment.Position = createVector(1.75, 0, -1.75)
				local clone = script.Heart:Clone()
				clone.Parent = attachment
				clone:Emit(1)
				fn10({
					SoundId = "rbxassetid://15684812583",
					Volume = 0.75,
					Parent = attachment,
					Looped = false
				}):Play()
			end
		},
		HideWeapon = true,
		Animation = 15684759074,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Car = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15684912289",
				Volume = 1,
				Looped = false
			},
			[2.133] = {
				SoundId = "rbxassetid://15684912898",
				Volume = 1,
				Looped = false
			}
		},
		Startup = function(list)
			local cfolder = shared.cfolder({
				Name = "Freeze"
			}, 3.5)
			table.insert(list, cfolder)
			cfolder:SetAttribute("DontInterrupt", true)
			cfolder:SetAttribute("NoStop", true)
			cfolder:SetAttribute("EmoteProperty", true)
			task.delay(0, function()
				cfolder.Parent = folder
			end)
		end,
		Animation = 15684890301,
		Idle = 15684902941,
		IdleSound = {
			SoundId = "rbxassetid://15684953841",
			Volume = 1,
			Looped = true
		},
		Stun = "Slowed"
	}
	v5.March = {
		Keyframes = {
			clap = function(p4)
				if not p4.turn then
					p4.turn = 0
				end

				p4.turn += 1
				fn10({
					SoundId = ({ "rbxassetid://15962454798", "rbxassetid://15962454626", "rbxassetid://15962454516" })[math.random(
						1,
						3
					)],
					Parent = p4.turn % 2 == 0 and folder["Left Leg"] or folder["Right Leg"],
					PlaybackSpeed = 1,
					Volume = 0.5,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
				game.ReplicatedStorage.Replication:FireAllClients({
					Effect = "Ninja Sprint Step",
					Emote = true,
					Type = p4.turn % 2 == 0 and "Left" or "Right",
					Char = folder,
					Root = root
				})
			end
		},
		Infinite = true,
		Animation = 15962443652,
		Looped = true,
		Stun = "Slowed",
		StunAttribute = 2
	}
	v5.Hunter = {
		Keyframes = {
			clap = function(p4)
				if not p4.turn then
					p4.turn = 0
				end

				p4.turn += 1
				fn10({
					SoundId = ({
						"rbxassetid://15962163599",
						"rbxassetid://15962163752",
						"rbxassetid://15962163891",
						"rbxassetid://15962164060"
					})[math.random(1, 4)],
					Parent = p4.turn % 2 == 0 and folder["Left Leg"] or folder["Right Leg"],
					PlaybackSpeed = 1,
					Volume = 0.5,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end
		},
		Infinite = true,
		Animation = 15962326593,
		Looped = true,
		Stun = "Slowed",
		StunAttribute = 2
	}
	v5.Hunted = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15958273667",
				Volume = 1,
				Looped = true,
				ParentTorso = true
			}
		},
		Animation = 15958281277,
		Looped = true,
		Stun = "Slowed",
		StunAttribute = 2
	}
	v5.Cmere = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16746777651",
				Volume = 3,
				Looped = false
			}
		},
		Animation = 16746746641,
		Looped = false,
		Stun = "Slowed"
	}
	v5.Come = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15958230853",
				Volume = 1,
				Looped = false
			}
		},
		Animation = 15958227342,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Fall = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17107935019",
				Volume = 1.5,
				ParentTorso = true
			}
		},
		HideWeapon = true,
		Animation = 17107937300,
		Stun = "Freeze"
	}
	v5.Surge = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17120757989",
				Volume = 0.85,
				ParentTorso = true,
				TimePosition = 0.1
			}
		},
		Animation = 17120750680,
		Stun = "Freeze"
	}
	v5.Celebrate = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17122167872",
				Volume = 2,
				ParentTorso = true
			}
		},
		Animation = 17122171961,
		Stun = "Freeze"
	}
	v5.Joy = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17120725506",
				Volume = 0.85,
				ParentTorso = true
			}
		},
		Animation = 17120709682,
		Stun = "Freeze"
	}
	v5.Dab = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17121232992",
				Volume = 0.85,
				ParentTorso = true
			}
		},
		Animation = 17121243447,
		Stun = "Freeze"
	}
	v5["Infinite Dabs"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17121285783",
				Volume = 1,
				Looped = true
			},
			[0.01] = {
				SoundId = "rbxassetid://9043916958",
				Volume = 0.4,
				Looped = true
			}
		},
		Animation = 17121290432,
		Looped = true,
		Stun = "Freeze"
	}
	v5.Spin = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17120739791",
				Volume = 0.6,
				ParentTorso = true
			}
		},
		Animation = 17120734491,
		Stun = "Freeze"
	}
	v5["Rock n' Roll"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1846187476",
				Volume = 1,
				Looped = true
			}
		},
		Animation = 15992808444,
		Looped = true,
		Stun = "Freeze"
	}
	v5["Party Is Life"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1836308391",
				Volume = 0.9,
				TimePosition = 0.3,
				Looped = true
			}
		},
		Animation = 17121045260,
		Looped = true,
		Stun = "Freeze"
	}
	v5["Moon Dance"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1836261338",
				Volume = 0.85,
				TimePosition = 0,
				ParentTorso = true,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.FedoraProp:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local m6d = clone.m6d
			m6d:SetAttribute("EmoteProperty", true)
			table.insert(list, m6d)
			m6d.Name = "FedoraHolder"
			m6d.Parent = folder.Head
			m6d.Part0 = folder.Head
			m6d.Part1 = clone.FedoraHolder
			clone.Parent = folder
		end,
		Animation = 86991820101391,
		Looped = true,
		Stun = "Slowed",
		Fix = true
	}
	v5["Domino Dance"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://80255365354899",
				Volume = 0.75,
				ParentTorso = true,
				Looped = true
			}
		},
		Animation = 81390187491088,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Kawaii Dance"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://138053801157608",
				Volume = 0.65,
				ParentTorso = true,
				Looped = true
			}
		},
		Animation = 72269473928027,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Cat Dance"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1847362131",
				Volume = 0.45,
				TimePosition = 0.15,
				Looped = true
			}
		},
		Animation = 17121145590,
		Looped = true,
		Stun = "Freeze"
	}
	v5["Hood Jam"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1839120667",
				Volume = 0.45,
				TimePosition = 0.6,
				Looped = true
			}
		},
		Animation = 17096456977,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Wave = {
		Sounds = {
			[0.017] = {
				SoundId = "rbxassetid://15684014240",
				Volume = 0.0875,
				Looped = true
			}
		},
		Animation = 15684011459,
		Looped = true,
		Stun = "Freeze"
	}
	v5["Gun Shot"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1836402463",
				Volume = 1,
				TimePosition = 19,
				Looped = true
			}
		},
		Startup = function(list)
			local clone = script.Microphone:Clone()
			local microphone = clone.Microphone
			microphone:SetAttribute("EmoteProperty", true)
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			table.insert(list, microphone)
			microphone.Part0 = folder["Left Arm"]
			microphone.Part1 = clone
			microphone.Parent = folder["Left Arm"]
			clone.Parent = folder
		end,
		Keyframes = {
			clap = function(p4)
				if not p4.turn then
					p4.turn = 0
				end

				p4.turn += 1
				fn10({
					SoundId = "rbxassetid://" .. ({ 7455224144, 7455246815, 7455224490 })[math.random(1, 3)],
					Parent = p4.turn % 2 == 0 and folder["Left Leg"] or folder["Right Leg"],
					PlaybackSpeed = 1,
					Volume = 0.5,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end
		},
		Infinite = true,
		Animation = 15956876217,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Flex = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15673780114",
				Volume = 2
			}
		},
		Animation = 15673779407,
		Stun = "Freeze"
	}
	v5.Robotic = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17097791389",
				Volume = 1.5,
				Looped = true
			}
		},
		Looped = true,
		Animation = 17097794422,
		Stun = "Freeze"
	}
	v5.Hurricane = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1837711983",
				Volume = 0.8,
				Looped = true
			}
		},
		Keyframes = {
			clap = function()
				fn10({
					SoundId = "rbxassetid://17097894260",
					Volume = 1.2,
					Parent = folder.Torso
				}):Play()
			end
		},
		Infinite = true,
		Looped = true,
		Animation = 17097909230,
		Stun = "Slowed"
	}
	v5["All Around"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1846628364",
				Volume = 1,
				TimePosition = 0.3,
				Looped = true
			}
		},
		Looped = true,
		HideWeapon = true,
		Animation = 17097820306,
		Stun = "Freeze"
	}
	v5["Snow Angel"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://75313492388562",
				Volume = 1,
				TimePosition = 0,
				Looped = true
			}
		},
		Looped = true,
		HideWeapon = true,
		Animation = 91705970671914,
		Stun = "Freeze"
	}
	v5["Go Go Go"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://86895841616707",
				Volume = 1,
				TimePosition = 0,
				Looped = true
			}
		},
		Looped = true,
		HideWeapon = true,
		Animation = 118364371117769,
		Stun = "Freeze"
	}
	v5["Think!"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17097709271",
				Volume = 1
			}
		},
		Animation = 17097712387,
		Stun = "Freeze"
	}
	v5["Knocked Out"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17097750060",
				Volume = 1,
				ParentTorso = true,
				TimePosition = 0.25
			}
		},
		Animation = 17097745294,
		Stun = "Freeze"
	}
	v5.Respect = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17106854447",
				Volume = 1,
				ParentTorso = true
			}
		},
		HideWeapon = true,
		Animation = 17106858586,
		Stun = "Freeze"
	}
	v5["Hunter Salute"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15673640988",
				Volume = 1.5
			},
			[0.1] = {
				SoundId = math.random(1, 3) == 1 and "rbxassetid://9114013375" or "rbxassetid://9120974708",
				Volume = 0.75
			}
		},
		Animation = 15673641958,
		Stun = "Freeze"
	}
	v5["Bow of Respect"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15673682013",
				Volume = 1.5
			},
			[0.25] = {
				SoundId = "rbxassetid://9120973886",
				Volume = 1
			}
		},
		Animation = 15673683215,
		Stun = "Freeze"
	}
	v5.Yay = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15673586398",
				Volume = 1
			},
			[0.01] = {
				SoundId = "rbxassetid://1841573938",
				Volume = 1,
				TimePosition = 0.5
			}
		},
		Animation = 15673595096,
		Stun = "Freeze"
	}
	v5.Expendable = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1845732793",
				Volume = 0.5,
				TimePosition = 0.35,
				Looped = true
			}
		},
		Animation = 15488510937,
		Looped = true,
		Stun = "Freeze"
	}
	v5.Griddy = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://9040601928",
				Volume = 0.874,
				Looped = true
			}
		},
		Animation = 13715326691,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Levitate = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1837911163",
				Volume = 0.1,
				Looped = true
			}
		},
		Fix = true,
		Animation = 15099756132,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Stay Down"] = {
		Sounds = {},
		Startup = function()
			fn10({
				SoundId = "rbxassetid://15290124285",
				Volume = 0.7,
				Parent = folder["Right Arm"],
				Looped = false
			}):Play()
		end,
		Animation = 15290114868,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Energized = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1847840594",
				Volume = 0.4,
				TimePosition = 0.15,
				Looped = true
			}
		},
		Animation = 15099686953,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Warmup = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://14611894554",
				Volume = 4,
				Looped = false
			}
		},
		Animation = 14611879113,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Gravity = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17106165427",
				Volume = 1
			}
		},
		Animation = 17106169665,
		Stun = "Freeze"
	}
	v5["Groovy Swing"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1835906503",
				Volume = 0.5,
				Looped = true
			}
		},
		Animation = 17096779665,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Crawl = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17106185985",
				Volume = 0.25,
				Looped = true
			}
		},
		Animation = 17106188784,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Get Down"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1840374054",
				Volume = 0.7,
				TimePosition = 0.25,
				Looped = true
			}
		},
		Animation = 17266358630,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Tweak = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1836256328",
				Volume = 0.4,
				Looped = true
			}
		},
		Animation = 17266410350,
		Looped = true,
		Stun = "Slowed",
		StunAttribute = 1
	}
	v5["Eyes On Me"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1842976958",
				Volume = 0.4,
				Looped = true
			}
		},
		Animation = 17266385960,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Sigh."] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://9043114637",
				Volume = 0.3,
				Looped = true
			}
		},
		Animation = 17266265770,
		Looped = true,
		Stun = "Freeze"
	}
	v5["Get It"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1847479242",
				Volume = 0.45,
				Looped = true
			}
		},
		Animation = 17266330796,
		Looped = true,
		Stun = "Freeze"
	}
	v5.Sway = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1847180622",
				Volume = 0.45,
				ParentTorso = true,
				Looped = true
			}
		},
		Animation = 17268390209,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Wild = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://14145625078",
				Volume = 0.45,
				Looped = true
			}
		},
		Animation = 17266311371,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Cross Step"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1840019043",
				Volume = 0.5,
				Looped = true
			}
		},
		Animation = 17096590136,
		Looped = true,
		Stun = "Slowed"
	}
	v5["One Hand Pushup"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17086681497",
				Volume = 0.5,
				Looped = true
			}
		},
		Animation = 17086698204,
		Looped = true,
		Stun = "Freeze"
	}
	v5["Two Hand Pushup"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17086681649",
				Volume = 0.5,
				Looped = true
			}
		},
		Animation = 17086696468,
		Looped = true,
		Stun = "Freeze"
	}
	v5.Brush = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://14611940867",
				Volume = 1.75,
				Looped = false
			}
		},
		Animation = 14611931363,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Mad = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17086521999",
				Volume = 1,
				TimePosition = 0.033
			},
			[0.083] = {
				SoundId = "rbxassetid://9113987614",
				TimePosition = 0.7,
				Volume = 2
			}
		},
		Animation = 17086333563,
		Stun = "Freeze"
	}
	v5.Jumpscared = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17086303118",
				Volume = 0.5
			},
			[0.01] = {
				SoundId = "rbxassetid://9125652432",
				Volume = 0.9
			}
		},
		Animation = 17086298638,
		Stun = "Freeze"
	}
	v5.Disconnect = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17086432258",
				Volume = 0.4
			}
		},
		Animation = 17086423985,
		Stun = "Freeze"
	}
	v5.Snap = {
		Sounds = {
			[0.25] = {
				SoundId = "rbxassetid://17097072874",
				Volume = 0.4
			}
		},
		Animation = 17097068597,
		Stun = "Slowed"
	}
	v5.Freaky = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17086541392",
				Volume = 0.4
			}
		},
		Animation = 17086544068,
		Stun = "Freeze"
	}
	v5.Shrug = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17108871591",
				Volume = 1.24
			}
		},
		Animation = 17108883110,
		Stun = "Slowed"
	}
	v5["Gun Flex"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17108676936",
				Volume = 1.24
			}
		},
		Animation = 17108683768,
		HideWeapon = true,
		Stun = "Freeze"
	}
	v5["Point Forward"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17097152088",
				Volume = 0.9
			},
			[2.3] = {
				SoundId = "rbxassetid://7455246815",
				Volume = 0.25
			}
		},
		Animation = 17097146599,
		Stun = "Freeze"
	}
	v5.Shiver = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17097111258",
				Volume = 0.4
			},
			[6.4] = {
				SoundId = "rbxassetid://7455246815",
				Volume = 0.25
			}
		},
		Animation = 17097114800,
		Stun = "Freeze"
	}
	v5["Shuffle Steps"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17086664493",
				Volume = 0.8,
				Looped = true
			}
		},
		Keyframes = {
			clap = function() end
		},
		Infinite = true,
		Looped = true,
		Animation = 17086507535,
		Stun = "Slowed"
	}
	v5["Smooth Vibe"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://9044565954",
				Volume = 0.3,
				Looped = true
			}
		},
		Looped = true,
		Animation = 17097177356,
		Stun = "Freeze"
	}
	v5["Ohio Walk"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://138473894696129",
				Volume = 0.45,
				Looped = true
			}
		},
		Looped = true,
		Animation = 128926901747116,
		Stun = "Slowed",
		StunAttribute = 2
	}
	v5["Ohio Run"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://121415300327083",
				Volume = 0.45,
				Looped = true
			}
		},
		Looped = true,
		Animation = 123412880883396,
		Stun = "Slowed",
		StunAttribute = 2
	}
	v5["TSB Board"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://125166946405745",
				Volume = 0.75,
				Looped = false
			},
			[2] = {
				SoundId = "rbxassetid://99157886801241",
				Volume = 0.4,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			fn13("Left", list, folder)
			fn13("Right", list, folder)
			local clone = script["TSB BOARD"]:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local ticTacToe = clone["Tic Tac Toe"]["Tic Tac Toe"]
			ticTacToe:SetAttribute("EmoteProperty", true)
			table.insert(list, ticTacToe)
			p4.md = ticTacToe
			ticTacToe.Part0 = folder["Right Arm"]
			ticTacToe.Part1 = clone["Tic Tac Toe"]
			ticTacToe.Parent = ticTacToe.Part0
			clone.Parent = folder
		end,
		Animation = 97128919301050,
		Idle = 82033098803825,
		Stun = "Freeze"
	}
	v5["Cute Dance"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://85014831722660",
				Volume = 0.45,
				Looped = true
			}
		},
		Looped = true,
		Animation = 123420436612768,
		Stun = "Slowed"
	}
	v5["Soft Moves"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://94111019811702",
				Volume = 0.45,
				Looped = true
			}
		},
		Looped = true,
		Animation = 77366695973257,
		Stun = "Slowed"
	}
	v5.Dawg = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://120670260583671",
				Volume = 0.45,
				Looped = true
			}
		},
		Looped = true,
		Animation = 123881279991554,
		Stun = "Slowed"
	}
	v5["Tuff Dance"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1836516704",
				Volume = 0.45,
				Looped = true
			}
		},
		Looped = true,
		Animation = 114527440152087,
		Stun = "Slowed"
	}
	v5["Trap Dance"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1842892976",
				Volume = 0.45,
				Looped = true
			}
		},
		Looped = true,
		Animation = 17097225104,
		Stun = "Slowed"
	}
	v5.Breakdown = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1837682925",
				Volume = 0.45,
				Looped = true
			}
		},
		HideWeapon = true,
		Looped = true,
		Animation = 17097275344,
		Stun = "Slowed"
	}
	v5.Worm = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1835443210",
				Volume = 0.45,
				Looped = true,
				TimePosition = 10
			}
		},
		Looped = true,
		Animation = 17097313490,
		Stun = "Slowed"
	}
	v5.Frenzy = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1847412527",
				Volume = 0.75,
				Looped = true,
				TimePosition = 2
			}
		},
		Keyframes = {
			clap = function()
				fn10({
					SoundId = "rbxassetid://2704706975",
					Volume = 0.5,
					Parent = folder.Head
				}):Play()
			end
		},
		Infinite = true,
		Looped = true,
		Animation = 17097370518,
		Stun = "Slowed"
	}
	v5["Down Low"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17097078338",
				Volume = 0.3,
				Looped = true
			}
		},
		Looped = true,
		Animation = 17096931722,
		Stun = "Freeze"
	}
	v5["Shake A Leg"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://9046189833",
				Volume = 0.3,
				Looped = true
			}
		},
		Looped = true,
		Animation = 17106937938,
		Stun = "Slowed"
	}
	v5.Crouch = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17097032574",
				Volume = 0.15,
				Looped = true
			}
		},
		Looped = true,
		Animation = 17097035602,
		Stun = "Slowed"
	}
	v5.Idk = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://9042785151",
				Volume = 0.4,
				Looped = true
			}
		},
		Looped = true,
		Animation = 17086440627,
		Stun = "Slowed"
	}
	v5.Vibe = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://9048378262",
				Volume = 0.4,
				Looped = true
			}
		},
		Looped = true,
		Animation = 17086321064,
		Stun = "Freeze"
	}
	v5.Happy = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1837528258",
				Volume = 0.6,
				TimePosition = 0.4,
				Looped = true
			}
		},
		Animation = 14496508275,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Cheery = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://9043851073",
				Volume = 0.6,
				Looped = true
			}
		},
		Animation = 17097940507,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Victory Dance"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1841647421",
				Volume = 1,
				TimePosition = 19,
				Looped = true
			}
		},
		Fix = true,
		Animation = 15089788940,
		Looped = true,
		Stun = "Freeze"
	}
	v5.Backflip = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15089505622",
				Volume = 1,
				Looped = false
			}
		},
		HideWeapon = true,
		Fix = true,
		Animation = 15089520783,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Boxing = {
		HideWeapon = true,
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15090130621",
				Volume = 1,
				Looped = true
			}
		},
		Animation = 15090141089,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Comical = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1836440339",
				Volume = 0.75,
				TimePosition = 0.35,
				Looped = true
			}
		},
		Animation = 15090301130,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Jiggy = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1845593645",
				Volume = 0.75,
				Looped = true
			}
		},
		Animation = 18450480375,
		Looped = true,
		Stun = "Slowed"
	}
	v5[":D"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://18450602521",
				Volume = 0.75,
				Looped = true
			},
			[0.01] = {
				SoundId = "rbxassetid://1842122622",
				Volume = 0.75,
				TimePosition = 0,
				Looped = true
			}
		},
		Animation = 18450597765,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Free Flow"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1841361703",
				Volume = 0.75,
				Looped = true
			}
		},
		Animation = 18450531343,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Let's Go"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://9045588592",
				Volume = 0.75,
				Looped = true
			}
		},
		Keyframes = {
			clap = function()
				fn10({
					SoundId = "rbxassetid://2704706975",
					Volume = 1,
					Parent = folder.Head
				}):Play()
			end
		},
		Infinite = true,
		Animation = 18450770138,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Silly Dance"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1842922954",
				Volume = 0.75,
				Looped = true
			}
		},
		Animation = 18450448457,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Throne = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://18450718148",
				Volume = 1,
				ParentTorso = true
			},
			[0.65] = {
				SoundId = "rbxassetid://18450718643",
				Volume = 0.4,
				ParentTorso = true,
				Looped = true
			}
		},
		Startup = function(list, _, _)
			local clone = script.Throne:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			local m6d = clone.m6d
			m6d:SetAttribute("EmoteProperty", true)
			table.insert(list, m6d)
			m6d.Name = "Throne"
			m6d.Part0 = folder.HumanoidRootPart
			m6d.Part1 = clone
			m6d.Parent = folder.HumanoidRootPart
			clone.Parent = folder
		end,
		Keyframes = {},
		HideWeapon = true,
		Fix = true,
		Idle = 18450698238,
		Animation = 18450697195,
		Stun = "Freeze"
	}
	v5.WHAT = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://18450667599",
				Volume = 1,
				ParentTorso = true
			}
		},
		Startup = function(list, _, _)
			local clone = script["bad to the bone"]:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			local m6d = clone.m6d
			m6d:SetAttribute("EmoteProperty", true)
			table.insert(list, m6d)
			m6d.Name = "Top"
			m6d.Part0 = folder.HumanoidRootPart
			m6d.Part1 = clone.Top
			m6d.Parent = folder.HumanoidRootPart
			clone.Parent = folder
		end,
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		Animation = 18450685221,
		Stun = "Freeze"
	}
	v5["Stay Back"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://18828870694",
				Volume = 1,
				ParentTorso = true
			}
		},
		Startup = function(list, _, _)
			local clone = script.Sword:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			local m6d = clone.m6d
			m6d:SetAttribute("EmoteProperty", true)
			table.insert(list, m6d)
			m6d.Name = "Handle"
			m6d.Part0 = folder["Right Arm"]
			m6d.Part1 = clone.Handle
			m6d.Parent = folder["Right Arm"]
			clone.Parent = folder
		end,
		Animation = 18897715873,
		Stun = "Slowed"
	}
	v5["All Yours"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://18450418495",
				Volume = 1,
				ParentTorso = true
			}
		},
		Startup = function(list, _, _)
			local clone = script.Sword:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			local m6d = clone.m6d
			m6d:SetAttribute("EmoteProperty", true)
			table.insert(list, m6d)
			m6d.Name = "Handle"
			m6d.Part0 = folder["Right Arm"]
			m6d.Part1 = clone.Handle
			m6d.Parent = folder["Right Arm"]
			clone.Parent = folder
		end,
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		Animation = 18450406917,
		Stun = "Freeze"
	}
	v5["Do A Flip"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17292863583",
				Volume = 1,
				TimePosition = 0.15,
				ParentTorso = true
			}
		},
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		Fix = true,
		FixRotation = true,
		Animation = 17292855624,
		Stun = "Freeze"
	}
	v5["Slick Back"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16746806682",
				Volume = 1.25,
				ParentTorso = true
			}
		},
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		Animation = 16746808371,
		Stun = "Slowed"
	}
	v5["Power Up"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17292499081",
				Volume = 1.25,
				ParentTorso = true
			}
		},
		Keyframes = {
			start = function(p4, clones, _)
				local clone = script.powerupaura.Attachment:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(clones, clone)
				p4.att = clone
				local color = object:GetColor() or Color3.new(math.random(), math.random(), math.random())

				if folder.Name == "Weakest Dummy" then
					color = ({
						BrickColor.new("Bright red").Color,
						BrickColor.new("Bright yellow").Color,
						BrickColor.new("Electric blue").Color,
						BrickColor.new("White").Color
					})[math.random(1, 4)]
				end

				for _, child in pairs(clone:GetChildren()) do
					child.Color = ColorSequence.new(color)
				end

				clone.Parent = folder.PrimaryPart
				clone.big:Emit(5)
				clone.ParticleEmitter.Enabled = true
			end,
			["end"] = function(p4, _, _)
				p4.att.ParticleEmitter.Enabled = false
			end
		},
		CanColor = true,
		Animation = 17292505729,
		Stun = "Freeze"
	}
	v5.Flop = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16522115283",
				Volume = 1.25,
				ParentTorso = true
			}
		},
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		FixRotation = true,
		Animation = 16522110024,
		Stun = "Freeze"
	}
	v5.Shy = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1837934932",
				Volume = 0.5,
				Looped = true
			}
		},
		Animation = 83257080238678,
		Stun = "Freeze",
		Looped = true
	}
	v5["Scary Crawl"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://78377770965429",
				Volume = 0.25,
				TimePosition = 0.3,
				Looped = true
			}
		},
		Animation = 129232331588541,
		Stun = "Slowed",
		Looped = true,
		StunAttribute = 2
	}
	v5.Relaxed = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15684856602",
				Volume = 1.25
			}
		},
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		Animation = 15684849948,
		Stun = "Slowed",
		StunAttribute = 1.5
	}
	v5.Salute = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15674156835",
				Volume = 0.65
			}
		},
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		Animation = 15674141176,
		Stun = "Freeze"
	}
	v5["Angel Sit"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1842179370",
				Volume = 0.65,
				Looped = true
			}
		},
		FixRotation = true,
		Animation = 99277885325374,
		Looped = true,
		Stun = "Freeze"
	}
	v5.Pie = {
		Sounds = {},
		Startup = function(list, _, p4)
			local clone = script.Pie:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local pie = clone.Pie
			pie:SetAttribute("EmoteProperty", true)
			table.insert(list, pie)
			p4.md = pie
			pie.Part0 = folder.PrimaryPart
			pie.Part1 = clone
			pie.Parent = pie.Part0
			clone.Parent = folder
			fn10({
				SoundId = "rbxassetid://102809211589234",
				Parent = clone,
				Volume = 2
			}):Play()
		end,
		Keyframes = {
			show = function(p4, _, _)
				local handle = p4.Handle

				for _, v8 in pairs({ handle, handle["Meshes/pie_Circle"] }) do
					v8.Transparency = 0
				end
			end,
			["end"] = function(p4, _, _)
				p4.Handle:Destroy()
			end
		},
		Animation = 100120756694061,
		Stun = "Slowed"
	}
	v5.ROFL = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://72680012098533",
				Volume = 0.8,
				ParentTorso = true,
				Looped = false
			}
		},
		Startup = function(_, _, _) end,
		Animation = 92009592408067,
		Stun = "Freeze"
	}
	v5.Eggceleration = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://127734089249377",
				Volume = 0.4,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script["Hard Boiled Roadster"]:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone

			for _, childName in pairs({
				"1Wheel",
				"2Wheel",
				"3Wheel",
				"4Wheel",
				"Base"
			}) do
				local child = clone:FindFirstChild(childName):FindFirstChild(childName)

				if not child then
					continue
				end

				child:SetAttribute("EmoteProperty", true)
				table.insert(list, child)
				p4.md = child
				child.Parent = folder.PrimaryPart
				child.Part0 = folder.PrimaryPart
				child.Part1 = clone:FindFirstChild(childName)
			end

			clone.Parent = folder
		end,
		Animation = 136339706043215,
		Stun = "Slowed",
		StunAttribute = 1
	}
	v5["Far Lands"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://130102260263347",
				Volume = 0.75,
				Looped = false
			},
			[0.01] = {
				SoundId = "rbxassetid://9112871516",
				Volume = 0.1,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Telescope:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local telescope = clone.Telescope
			telescope:SetAttribute("EmoteProperty", true)
			table.insert(list, telescope)
			p4.md = telescope
			telescope.Part0 = folder["Left Arm"]
			telescope.Part1 = clone
			telescope.Parent = telescope.Part0
			clone.Parent = folder
			local clone2 = script.RockModel:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(list, clone2)
			p4.Handle = clone2
			local motor6D = Instance.new("Motor6D")
			motor6D:SetAttribute("EmoteProperty", true)
			table.insert(list, motor6D)
			p4.md = motor6D
			motor6D.Part0 = folder.PrimaryPart
			motor6D.Part1 = clone2.Rock
			motor6D.C0 = CFrame.new(0.518783569, -2.77656937, -1.6493988, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			motor6D.Parent = motor6D.Part0
			clone2.Parent = folder
		end,
		Animation = 95188093937721,
		Idle = 123472525620412,
		Stun = "Freeze"
	}
	v5["Brick Wall"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://82109086143085",
				Volume = 0.8,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local part = Instance.new("Part")
			part:SetAttribute("EmoteProperty", true)
			table.insert(list, part)
			p4.Handle = part
			part.Color = Color3.fromRGB(165, 91, 91)
			part.Material = Enum.Material.Brick
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Massless = true
			part.Size = createVector(14, 10, 2)
			local weld = Instance.new("Weld")
			weld.Part0 = folder.PrimaryPart
			weld.Part1 = part
			weld.C0 = CFrame.new(
				-0.0000152587891,
				1.99996948,
				-5.00027466,
				1.00000024,
				-5.55111512e-17,
				0.0000116825104,
				-5.55111645e-17,
				1,
				-6.485096e-22,
				-0.0000116825104,
				0,
				1.00000024
			)
			weld.Parent = part
			part.Parent = folder
		end,
		HideWeapon = true,
		Looped = true,
		Animation = 82845057792209,
		Stun = "Freeze"
	}
	v5.Poet = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://73094641303819",
				Volume = 0.5,
				Looped = false
			},
			[2.25] = {
				SoundId = "rbxassetid://80725552338935",
				Volume = 0.2,
				Looped = true
			},
			[1] = {
				SoundId = "rbxassetid://1838577168",
				Volume = 0.8,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.poet.Book:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			handle.Part0 = folder["Left Arm"]
			handle.Part1 = clone.Handle
			handle.Parent = handle.Part0
			clone.Parent = folder
			local clone2 = script.poet.feather:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(list, clone2)
			p4.Handle = clone2
			local handle2 = clone2.Handle.Handle
			handle2:SetAttribute("EmoteProperty", true)
			table.insert(list, handle2)
			p4.md = handle2
			handle2.Part0 = folder["Right Arm"]
			handle2.Part1 = clone2.Handle
			handle2.Parent = handle2.Part0
			clone2.Parent = folder
			local clone3 = script.poet["studious chair"]:Clone()
			clone3:SetAttribute("EmoteProperty", true)
			table.insert(list, clone3)
			p4.Handle = clone3
			local motor6D = Instance.new("Motor6D")
			motor6D:SetAttribute("EmoteProperty", true)
			table.insert(list, motor6D)
			p4.md = motor6D
			motor6D.Part0 = folder.PrimaryPart
			motor6D.Part1 = clone3.mainpiece
			motor6D.C0 = CFrame.new(
				-1.39691925,
				1.01877403,
				1.46870232,
				0.707105875,
				0,
				-0.707105875,
				0,
				1,
				0,
				0.707105875,
				0,
				0.707105875
			)
			motor6D.Parent = motor6D.Part0
			clone3.Parent = folder
		end,
		Animation = 91228869240203,
		Idle = 83196818755529,
		Stun = "Freeze"
	}
	v5["Virtual Reality"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://122501421229323",
				Volume = 1,
				Looped = false
			}
		},
		Startup = function(list, _, p4)
			local clone = script.vr:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			handle.Part0 = folder.Head
			handle.Part1 = clone
			handle.Parent = folder.Head
			clone.Name = "Handle"
			clone.Parent = folder.Head
		end,
		Animation = 84734676175472,
		Looped = false,
		Stun = "Slowed"
	}
	v5.Candy = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1837571829",
				Volume = 0.5,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Lollipop:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local lollipop = clone.Lollipop
			lollipop:SetAttribute("EmoteProperty", true)
			table.insert(list, lollipop)
			p4.md = lollipop
			lollipop.Part0 = folder["Left Arm"]
			lollipop.Part1 = clone
			lollipop.Parent = folder["Left Arm"]
			clone.Parent = folder
		end,
		Animation = 136634205715198,
		Looped = true,
		Stun = "Freeze"
	}
	v5["Kicking My Feet"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://121331882801594",
				Volume = 1,
				ParentTorso = true
			},
			[1.167] = {
				SoundId = "rbxassetid://95578909033022",
				Volume = 0.3,
				Looped = true,
				ParentTorso = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Laptop:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local m6d = clone.m6d
			m6d:SetAttribute("EmoteProperty", true)
			table.insert(list, m6d)
			p4.md = m6d
			m6d.Part0 = folder.PrimaryPart
			m6d.Name = "MainLaptop"
			m6d.Part1 = clone.MainLaptop
			m6d.Parent = folder.PrimaryPart
			clone.Parent = folder
		end,
		Animation = 122143558846408,
		Idle = 135379415562839,
		Looped = false,
		FixRotation = true,
		Stun = "Freeze"
	}
	v5["Dancey Dance"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1839444520",
				Volume = 0.5,
				Looped = true
			}
		},
		Animation = 126505536768184,
		HideWeapon = true,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Transform = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://94428920940989",
				Volume = 1,
				ParentTorso = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Watch:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local watch = clone.Watch
			watch:SetAttribute("EmoteProperty", true)
			table.insert(list, watch)
			p4.md = watch
			watch.Part0 = folder["Left Arm"]
			watch.Part1 = clone
			watch.Parent = folder["Left Arm"]
			clone.Parent = folder
		end,
		Keyframes = {
			disguise = function(_, _, _)
				local clone = script.CloneGlow:Clone()
				clone.Parent = folder.PrimaryPart
				clone:Emit(10)
				shared.cfolder({
					Name = "randomdisguise#",
					Parent = folder
				}, 0.2)
			end
		},
		Cooldown = 5,
		Animation = 95977571599797,
		HideWeapon = true,
		Stun = "Slowed",
		StunAttribute = 1.25
	}
	v5.Hypnotize = {
		Sounds = {},
		Startup = function(list, _, p4)
			local clone = script["hypnotize coin"]:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local rotate = clone.rotate
			rotate:SetAttribute("EmoteProperty", true)
			table.insert(list, rotate)
			local rotate2 = rotate.rotate
			rotate2:SetAttribute("EmoteProperty", true)
			table.insert(list, rotate2)
			p4.md = rotate2
			rotate2.Part0 = folder["Right Arm"]
			rotate2.Part1 = rotate
			rotate2.Parent = folder["Right Arm"]
			rotate.Parent = folder["Right Arm"]
			rotate["hypnotize coin"].Part0 = rotate
			rotate["hypnotize coin"].Part1 = clone
			clone.Beam.Attachment0 = rotate.a
			clone.Beam.Attachment1 = clone.b
			clone.Parent = folder
			fn10({
				SoundId = "rbxassetid://128826289918429",
				Parent = clone,
				Volume = 1
			}):Play()
			fn10({
				SoundId = "rbxassetid://96767567204088",
				Parent = clone,
				Looped = true,
				Volume = 0.5
			}):Play()
			fn10({
				SoundId = "rbxassetid://84603081336467",
				Parent = clone,
				Looped = true,
				Volume = 1
			}):Play()
		end,
		Animation = 83122498060756,
		Looped = true,
		HideWeapon = true,
		Fix = true,
		Stun = "Slowed",
		StunAttribute = 1.25
	}
	v5.Anteater = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://85846521324149",
				Volume = 0.6
			}
		},
		Startup = function(list, _, p4)
			local clone = script.TongueThree:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			clone.Name = "Tongue"
			local tongue = clone.Tongue
			tongue:SetAttribute("EmoteProperty", true)
			table.insert(list, tongue)
			p4.md = tongue
			tongue.Part0 = folder.Head
			tongue.Part1 = clone
			tongue.Parent = folder.Head
			clone.Parent = folder
		end,
		Animation = 126729542613743,
		Looped = false,
		Stun = "Slowed",
		StunAttribute = 1
	}
	v5["Dolphin Laugh"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://84584488257531",
				Volume = 0.6
			},
			[0.01] = {
				SoundId = "rbxassetid://107717554139419",
				Volume = 1
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Tongue:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local tongue = clone.Tongue
			tongue:SetAttribute("EmoteProperty", true)
			table.insert(list, tongue)
			p4.md = tongue
			tongue.Part0 = folder.Head
			tongue.Part1 = clone
			tongue.Parent = folder.Head
			clone.Parent = folder
		end,
		Animation = 90429111193022,
		Looped = false,
		Stun = "Slowed",
		StunAttribute = 1
	}
	v5["Tactical Roll"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://136421083782203",
				Volume = 0.75,
				ParentTorso = true
			},
			[0.667] = {
				SoundId = "rbxassetid://109487141252928",
				Volume = 0.25,
				ParentTorso = true,
				Looped = true
			}
		},
		Startup = function(list, _, _)
			local cfolder = shared.cfolder({
				Name = "Freeze"
			}, 0.6)
			table.insert(list, cfolder)
			cfolder:SetAttribute("DontInterrupt", true)
			cfolder:SetAttribute("NoStop", true)
			cfolder:SetAttribute("EmoteProperty", true)
			task.delay(0, function()
				cfolder.Parent = folder
			end)
		end,
		Keyframes = {},
		Infinite = true,
		Animation = 95582164547526,
		Idle = 129959128025296,
		End = {
			97763083185838,
			1.167,
			{
				SoundId = "rbxassetid://101300402631347",
				Volume = 1
			}
		},
		Looped = false,
		Stun = "Slowed",
		StunAttribute = 1
	}
	v5.Snowball = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://123492905764821",
				ParentTorso = true,
				Volume = 1
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Snowball:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local snowball = clone.Snowball
			snowball:SetAttribute("EmoteProperty", true)
			table.insert(list, snowball)
			p4.md = snowball
			snowball.Part0 = folder.PrimaryPart
			snowball.Part1 = clone
			snowball.Parent = folder.PrimaryPart
			clone.Parent = folder
			fn10({
				SoundId = "rbxassetid://127749554517948",
				Parent = clone,
				Volume = 2
			}):Play()
			fn10({
				SoundId = "rbxassetid://84849690170635",
				Parent = clone,
				Looped = true,
				Volume = 0.65
			}):Play()
			local cfolder = shared.cfolder({
				Name = "Freeze"
			}, 0.567)
			table.insert(list, cfolder)
			cfolder:SetAttribute("DontInterrupt", true)
			cfolder:SetAttribute("NoStop", true)
			cfolder:SetAttribute("EmoteProperty", true)
			task.delay(0, function()
				cfolder.Parent = folder
			end)
		end,
		Keyframes = {},
		Infinite = true,
		Animation = 93094222682042,
		Idle = 108144977825967,
		Looped = false,
		Stun = "Slowed",
		StunAttribute = 1
	}
	v5["Pull Ups"] = {
		Sounds = {},
		Startup = function(list, _, p4)
			local clone = script.bar:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local bar = clone.bar
			bar:SetAttribute("EmoteProperty", true)
			table.insert(list, bar)
			p4.md = bar
			bar.Part0 = folder.PrimaryPart
			bar.Part1 = clone
			bar.Parent = folder.PrimaryPart
			clone.Parent = folder
		end,
		Keyframes = {
			clap = function(_, _, _)
				shared.sfx({
					SoundId = "rbxassetid://77085840183045",
					Parent = folder.Torso,
					RollOffMaxDistance = rollOffMaxDistance,
					Volume = 0.2
				}):Play()
			end
		},
		Infinite = true,
		Animation = 75393073390365,
		Looped = true,
		Stun = "Freeze"
	}
	v5["Come At Me"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://116197705597433",
				Volume = 2,
				Looped = false
			}
		},
		Startup = function(p4, _, _)
			fn13("Left", p4, folder)
			fn13("Right", p4, folder)
		end,
		Animation = 74414832949656,
		Looped = false,
		Stun = "Freeze"
	}
	v5["Crush His Skull"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://98776091220732",
				Volume = 2,
				Looped = false
			}
		},
		Startup = function(p4, _, _)
			fn13("Left", p4, folder)
			fn13("Right", p4, folder)
		end,
		Animation = 78773506399466,
		Looped = false,
		Stun = "Slowed"
	}
	v5["Tear To My Eye"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://82594146296970",
				Volume = 0.65,
				Looped = false
			}
		},
		Startup = function(p4, _, _)
			fn13("Left", p4, folder)
		end,
		Animation = 134468557091532,
		Looped = false,
		Stun = "Slowed"
	}
	v5["Iconic Salute"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://104425695752871",
				Volume = 0.65,
				Looped = false
			}
		},
		Startup = function(p4, _, _)
			fn13("Left", p4, folder)
		end,
		Animation = 80518687127249,
		Looped = false,
		Stun = "Slowed",
		StunAttribute = 1
	}
	v5["Happy Run"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://76952189090658",
				Volume = 0.3,
				Looped = true
			},
			[0.1] = {
				SoundId = "rbxassetid://1846637439",
				Volume = 0.8,
				Looped = true
			}
		},
		Animation = 137202650654919,
		Looped = true,
		Stun = "Slowed",
		StunAttribute = 1.25
	}
	v5["I HATE THIS"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://119365921426629",
				Volume = 1,
				ParentTorso = true
			}
		},
		Animation = 112380819900693,
		Stun = "Freeze"
	}
	v5["Closer Look"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://109152804297772",
				Volume = 1,
				Looped = false
			}
		},
		Startup = function(list, _, p4)
			local clone = script.mag:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local motor6D = clone["Meshes/magnifying glass_Magnifying glass"].Motor6D
			motor6D:SetAttribute("EmoteProperty", true)
			table.insert(list, motor6D)
			p4.md = motor6D
			motor6D.Part0 = folder["Right Arm"]
			motor6D.Part1 = clone["Meshes/magnifying glass_Magnifying glass"]
			motor6D.Parent = folder["Right Arm"]
			clone.Parent = folder
		end,
		Animation = 110165153895915,
		Stun = "Slowed"
	}
	v5["Wait what?"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://78427074444157",
				Volume = 0.8
			}
		},
		Startup = function(list, _, p4)
			local clone = script.burger:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local burger = clone.burger
			burger:SetAttribute("EmoteProperty", true)
			table.insert(list, burger)
			p4.md = burger
			burger.Part0 = folder["Right Arm"]
			burger.Part1 = clone
			burger.Parent = folder["Right Arm"]
			clone.Parent = folder
		end,
		HideWeapon = true,
		Animation = 118344836569256,
		Stun = "Slowed"
	}
	v5.Spider = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://98010853317105",
				ParentTorso = true,
				Volume = 1
			},
			[1.25] = {
				SoundId = "rbxassetid://96737293385093",
				ParentTorso = true,
				Volume = 0.75,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local cfolder = shared.cfolder({
				Name = "Freeze"
			}, 1.25)
			table.insert(list, cfolder)
			cfolder:SetAttribute("DontInterrupt", true)
			cfolder:SetAttribute("NoStop", true)
			cfolder:SetAttribute("EmoteProperty", true)
			task.delay(0, function()
				cfolder.Parent = folder
			end)
			local clone = script["Left Arm2"]:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local motor6D = clone:FindFirstChildOfClass("Motor6D")
			motor6D:SetAttribute("EmoteProperty", true)
			table.insert(list, motor6D)
			p4.md = motor6D
			motor6D.Part0 = folder.Torso
			motor6D.Part1 = clone
			motor6D.Parent = folder.Torso
			clone.Parent = folder
			local clone2 = script["Right Arm2"]:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(list, clone2)
			p4.Handle = clone2
			local motor6D2 = clone2:FindFirstChildOfClass("Motor6D")
			motor6D2:SetAttribute("EmoteProperty", true)
			table.insert(list, motor6D2)
			p4.md = motor6D2
			motor6D2.Part0 = folder.Torso
			motor6D2.Part1 = clone2
			motor6D2.Parent = folder.Torso
			clone2.Parent = folder

			for _, part in pairs({ clone, clone2 }) do
				local model = Instance.new("Model")
				model:SetAttribute("EmoteProperty", true)
				table.insert(list, model)
				local humanoid = Instance.new("Humanoid")
				humanoid.Parent = model
				local child = folder:FindFirstChild((string.sub(part.Name, 0, #part.Name - 1)))

				if child then
					local clone3 = child:Clone()
					clone3:ClearAllChildren()
					clone3.Parent = model
					local weld = Instance.new("Weld")
					weld.Part0 = part
					weld.Part1 = clone3
					weld.Parent = clone3
				end

				for _, child2 in pairs(folder:GetChildren()) do
					if not (child2:IsA("BodyColors") or child2:IsA("Shirt") or child2:IsA("CharacterMesh")) then
						continue
					end

					local clone_2 = child2:Clone()
					clone_2.Parent = model
				end

				part.Transparency = 1
				model.Parent = folder
			end
		end,
		HideWeapon = true,
		Animation = 84352551694194,
		Idle = 116556793266735,
		End = {
			128242451039706,
			3.417,
			{
				SoundId = "rbxassetid://136022219424831",
				Volume = 1
			}
		},
		Stun = "Slowed",
		StunAttribute = 1
	}
	v5["Gun Safety"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://130627465104635",
				Volume = 0.8
			}
		},
		Startup = function(list, _, p4)
			local clone = script.gun1:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local motor6D = clone.Motor6D
			motor6D:SetAttribute("EmoteProperty", true)
			table.insert(list, motor6D)
			p4.md = motor6D
			motor6D.Part0 = folder["Right Arm"]
			motor6D.Part1 = clone
			motor6D.Parent = folder["Right Arm"]
			clone.Parent = folder
			local clone2 = script.gun2:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(list, clone2)
			p4.Handle = clone2
			local motor6D2 = clone2.Motor6D
			motor6D2:SetAttribute("EmoteProperty", true)
			table.insert(list, motor6D2)
			p4.md = motor6D2
			motor6D2.Part0 = folder.PrimaryPart
			motor6D2.Part1 = clone2
			motor6D2.Parent = folder.PrimaryPart
			clone2.Parent = folder
		end,
		HideWeapon = true,
		Animation = 129722512665420,
		Stun = "Freeze"
	}
	v5["Our Hill"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://76078643902403",
				Volume = 1
			}
		},
		Startup = function(clones, _, p4)
			local clone = script.Flag:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone)
			p4.Handle = clone
			local flag = clone.Flag.Flag
			flag:SetAttribute("EmoteProperty", true)
			CollectionService2:AddTag(flag, "emotestuff" .. folder.Name)
			local Debris = game:GetService("Debris")
			Debris:AddItem(flag, 7.5)
			p4.md = flag
			flag.Part0 = folder.PrimaryPart
			flag.Part1 = clone.Flag
			flag.Parent = folder.PrimaryPart
			clone.Parent = folder
		end,
		Keyframes = {
			show = function(p4, _, _)
				local handle = p4.Handle

				for _, child in pairs(handle:GetChildren()) do
					child.Transparency = 0
				end
			end,
			place = function(p4, list, _)
				table.remove(list, table.find(list, p4.Handle))
				local handle = p4.Handle
				CollectionService2:AddTag(handle, "emotestuff" .. folder.Name)
				local Debris = game:GetService("Debris")
				Debris:AddItem(handle, 10)
				p4.md:Destroy()

				for _, child in pairs(handle:GetChildren()) do
					child.Anchored = true
				end

				handle.Parent = workspace.Thrown
			end
		},
		HideWeapon = true,
		Animation = 73523771913372,
		Stun = "Freeze"
	}
	v5["Cleaning The Dirt"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://127817333862539",
				Volume = 0.4,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Brush:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local brush = clone.Brush
			brush:SetAttribute("EmoteProperty", true)
			table.insert(list, brush)
			p4.md = brush
			brush.Part0 = folder["Right Arm"]
			brush.Part1 = clone
			brush.Parent = folder["Right Arm"]
			clone.Parent = folder
		end,
		Animation = 115179620616154,
		Looped = true,
		Stun = "Freeze"
	}
	v5.Greed = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://80873338449533",
				Volume = 0.25,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Chest:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local motor6D = clone.Motor6D
			motor6D:SetAttribute("EmoteProperty", true)
			table.insert(list, motor6D)
			p4.md = motor6D
			motor6D.Part0 = folder.PrimaryPart
			motor6D.Part1 = clone
			motor6D.Parent = folder.PrimaryPart
			clone.Parent = folder
		end,
		Animation = 122887697782216,
		Looped = true,
		Stun = "Slowed",
		StunAttribute = 1.6
	}
	v5.Map = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://90191250272746",
				Volume = 1,
				Looped = false
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Map:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local map = clone.Map
			map:SetAttribute("EmoteProperty", true)
			table.insert(list, map)
			p4.md = map
			map.Part0 = folder["Left Arm"]
			map.Part1 = clone
			map.Parent = folder["Left Arm"]
			clone.Parent = folder
		end,
		Animation = 107071225742389,
		Stun = "Slowed"
	}
	v5.Compass = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://136499300928500",
				Volume = 1.5,
				Looped = false
			}
		},
		Startup = function(list, _, p4)
			local clone = script.compass:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local compass = clone.compass
			compass:SetAttribute("EmoteProperty", true)
			table.insert(list, compass)
			p4.md = compass
			compass.Name = "compass"
			compass.Part0 = folder["Left Arm"]
			compass.Part1 = clone
			compass.Parent = folder["Left Arm"]
			clone.Parent = folder
		end,
		Animation = 80768814436661,
		Stun = "Freeze"
	}
	v5.Gamer = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://84400761601453",
				Volume = 1.5,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.gameboi:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local gameboi = clone.gameboi
			gameboi:SetAttribute("EmoteProperty", true)
			table.insert(list, gameboi)
			p4.md = gameboi
			gameboi.Part0 = folder["Left Arm"]
			gameboi.Part1 = clone
			gameboi.Parent = folder["Left Arm"]
			clone.Parent = folder
		end,
		Animation = 135067453512312,
		Stun = "Slowed",
		Looped = true
	}
	v5["Fancy Spin"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1845480621",
				Volume = 1.5,
				Looped = true
			}
		},
		FixRotation = true,
		Animation = 80454258581844,
		Idle = 75040627398852,
		Stun = "Slowed"
	}
	v5["Those Who Know"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://106095843660280",
				Volume = 1,
				Looped = false
			},
			[0.35] = {
				SoundId = "rbxassetid://129084829698643",
				Volume = 0.75,
				Looped = true
			}
		},
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		FixRotation = true,
		Animation = 78259177692699,
		Idle = 120789866363939,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Sit = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15090067278",
				Volume = 0.65,
				TimePosition = 0.125,
				Looped = false
			}
		},
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		FixRotation = true,
		Animation = 15090101157,
		Looped = false,
		Stun = "Freeze"
	}
	v5["WHY?"] = {
		Sounds = {},
		Startup = function()
			fn10({
				SoundId = "rbxassetid://15285526846",
				Volume = 0.65,
				Parent = folder["Right Arm"],
				Looped = false
			}):Play()
			fn10({
				SoundId = "rbxassetid://1840489462",
				Volume = 0.4,
				Parent = folder.Torso,
				TimePosition = 0.5,
				Looped = true
			}):Resume()
		end,
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		Fix = true,
		Animation = 15285521399,
		Looped = false,
		Stun = "Freeze"
	}
	v5["Sit 2"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15099895974",
				Volume = 0.785,
				TimePosition = 0,
				Looped = false
			}
		},
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		Animation = 15099893403,
		Looped = false,
		Stun = "Freeze"
	}
	v5.T = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15503011741",
				Volume = 0.4,
				TimePosition = 0,
				Looped = false
			}
		},
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		Animation = 15503004900,
		Looped = false,
		Stun = "Slowed"
	}
	v5["Point Down"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15453955288",
				Volume = 0.785,
				TimePosition = 0,
				Looped = false
			}
		},
		Animation = 15446959450,
		Looped = false,
		Stun = "Freeze"
	}
	v5["Head Spin"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15089965760",
				Volume = 0.65,
				Looped = false
			}
		},
		Keyframes = {
			start = function()
				fn10({
					SoundId = "rbxassetid://1846628770",
					Volume = 0.65,
					TimePosition = 25.55,
					Looped = false,
					Parent = folder.PrimaryPart
				}):Resume()
			end
		},
		Animation = 15090032390,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Hologram = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15090888419",
				Volume = 2.5,
				Looped = true
			}
		},
		Startup = function(list, _, _)
			for _, model in pairs(script.Hologram:GetChildren()) do
				if not model:IsA("Model") then
					continue
				end

				local clone = model:Clone()
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emotestuff" .. folder.Name)

				for _, child in pairs(clone:GetChildren()) do
					child:SetAttribute("EmoteProperty", true)
					table.insert(list, child)
					CollectionService2:AddTag(child, "emotestuff" .. folder.Name)
					local child2 = script.Hologram:FindFirstChild(child.Name)
					child.Material = Enum.Material.Glass
					child:SetAttribute("Exempt", true)
					child.Transparency = 0.25
					child.Size = createVector(1.2, 1.15, 0)
					child.Parent = workspace.Thrown

					if not child2 then
						continue
					end

					local clone2 = child2:Clone()
					table.insert(list, clone2)
					clone2:SetAttribute("EmoteProperty", true)
					clone2.Part0 = folder.PrimaryPart
					clone2.Part1 = child
					clone2.Parent = folder.PrimaryPart
					local v8 = {
						15090670461,
						15090671388,
						15090674168,
						15090675904,
						15090677327,
						15090678837,
						15090680066,
						15090681663
					}
					local v9 = v8[math.random(#v8)]

					for i = 1, 2 do
						local decal = Instance.new("Decal")
						decal.Color3 = Color3.fromRGB(450, 450, 450)
						decal.Transparency = 0.35
						decal.Texture = "rbxthumb://type=Asset&id=" .. v9 .. "&w=420&h=420"
						decal.Face = i == 1 and Enum.NormalId.Front or Enum.NormalId.Back
						decal.Parent = child
					end
				end

				clone:SetAttribute("EmoteProperty", true)
				clone.Parent = folder
			end
		end,
		Animation = 15090734317,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Ramen = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15503358454",
				Volume = 2,
				Looped = false
			},
			[0.01] = {
				SoundId = "rbxassetid://1842247132",
				Volume = 0.15,
				Looped = true
			}
		},
		Keyframes = {
			clap = function(p4, _, p5)
				task.delay(0.2, function()
					if not p5.IsPlaying then
						return
					end

					for _, v8 in pairs({ p4.stickRight, p4.stickLeft }) do
						if not v8:GetAttribute("OG4") then
							continue
						end

						v8.Attachment1.Position = v8:GetAttribute("OG")
						v8.Attachment0.Position = v8:GetAttribute("OG4")
					end

					p4.stickRight.Enabled = true
					p4.stickLeft.Enabled = true
				end)
				task.delay(1.15, function()
					if not p5.IsPlaying then
						return
					end

					for _, v8 in pairs({ p4.stickRight, p4.stickLeft }) do
						if not v8:GetAttribute("OG") then
							v8:SetAttribute("OG", v8.Attachment1.Position)
						end

						if not v8:GetAttribute("OG4") then
							v8:SetAttribute("OG4", v8.Attachment0.Position)
						end

						v8.Attachment1.Position = v8:GetAttribute("OG")
						v8.Attachment0.Position = v8:GetAttribute("OG4")
						v8.Enabled = true
						TweenService:Create(
							v8.Attachment1,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								WorldPosition = v8.Attachment0.WorldPosition
							}
						):Play()

						if not v8:GetAttribute("OG2") then
							v8:SetAttribute("OG2", v8.Width1)
						end

						if not v8:GetAttribute("OG3") then
							v8:SetAttribute("OG3", v8.Width0)
						end

						TweenService:Create(v8, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Width1 = 0,
							Width0 = 0
						}):Play()
					end
				end)
				fn10({
					SoundId = "rbxassetid://15503358374",
					Parent = folder.PrimaryPart,
					Volume = 2
				}):Play()
			end,
			claploop = function(data, _, p4)
				task.delay(0.4, function()
					if not p4.IsPlaying then
						return
					end

					for _, v8 in pairs({ data.stickRight, data.stickLeft }) do
						TweenService:Create(
							v8.Attachment1,
							TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Position = v8:GetAttribute("OG")
							}
						):Play()
						TweenService:Create(v8, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Width1 = v8:GetAttribute("OG2"),
							Width0 = v8:GetAttribute("OG3")
						}):Play()
					end

					task.delay(2.89, function()
						if not p4.IsPlaying then
							return
						end

						for _, v8 in pairs({ data.stickRight, data.stickLeft }) do
							TweenService:Create(
								v8.Attachment0,
								TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									WorldPosition = v8.Attachment1.WorldPosition
								}
							):Play()
							fn10({
								SoundId = "rbxassetid://344167846",
								Parent = data.Handle,
								Volume = 0.08
							}):Play()
							local v9 = v8
							task.delay(0.5, function()
								if not p4.IsPlaying then
									return
								end

								v9.Enabled = false
							end)
						end
					end)
				end)
				data.stickRight.Enabled = true
				data.stickLeft.Enabled = true
				fn10({
					SoundId = "rbxassetid://15503358531",
					Parent = folder.PrimaryPart,
					Volume = 2
				}):Play()
			end
		},
		Startup = function(list, _, beams)
			local clone = script.Ramen.Handle:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			beams.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			beams.md = handle
			handle.Part0 = folder["Left Arm"]
			handle.Part1 = clone
			handle.Parent = folder["Left Arm"]
			clone.Parent = folder

			for _, v8 in pairs({ "stickLeft", "stickRight" }) do
				local clone2 = script.Ramen[v8]:Clone()
				clone2:SetAttribute("EmoteProperty", true)
				table.insert(list, clone2)
				clone2.Parent = folder["Right Arm"]
				local v9 = clone2[v8]
				v9:SetAttribute("EmoteProperty", true)
				table.insert(list, v9)
				v9.Part0 = folder["Right Arm"]
				v9.Part1 = clone2
				v9.Parent = folder["Right Arm"]
				clone2.Beam.Attachment0 = clone2.Attachment
				clone2.Beam.Attachment1 = clone.Bowl.Noodles[string.gsub(clone2.Name, "stick", "")]
				clone2.Beam.Enabled = false
				beams[v8] = clone2.Beam
			end
		end,
		HideWeapon = true,
		Infinite = true,
		IdleKeyframes = true,
		Idle = 15503362953,
		Animation = 15503201875,
		Looped = false,
		Stun = "Freeze"
	}
	v5["Wallet Check"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16592761699",
				Volume = 2,
				Looped = false
			}
		},
		Startup = function(list, _, p4)
			local clone = script.wollet:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local clone2 = clone.LeftHandle:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(list, clone2)
			clone2.Cube.Part0 = clone2
			clone2.Cube.Part1 = clone.Cube
			local m6d = clone.m6d
			m6d:SetAttribute("EmoteProperty", true)
			table.insert(list, m6d)
			p4.md = m6d
			m6d.Part0 = folder["Left Arm"]
			m6d.Part1 = clone2
			m6d.Name = "LeftHandle"
			clone2.Parent = folder
			clone.Parent = folder
			m6d.Parent = folder["Left Arm"]
		end,
		HideWeapon = true,
		Animation = 16592787958,
		Stun = "Slowed"
	}
	v5["Nerf This"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15502973035",
				Volume = 1,
				Looped = false
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Clipboard.LeftHandle:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local leftHandle = clone.LeftHandle
			leftHandle:SetAttribute("EmoteProperty", true)
			table.insert(list, leftHandle)
			p4.md = leftHandle
			leftHandle.Part0 = folder["Left Arm"]
			leftHandle.Part1 = clone
			leftHandle.Parent = folder["Left Arm"]
			local decal = clone:FindFirstChild("Decal", true)
			decal.Texture = "rbxassetid://" .. ({
				15114667107,
				15124465439,
				15143528856,
				15114672498,
				15143529209,
				15143528539,
				16136325038
			})[math.random(1, 7)]
			clone.Parent = folder
			local clone2 = script.Clipboard.RightHandle:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(list, clone2)
			p4.Handle = clone2
			local rightHandle = clone2.RightHandle
			rightHandle:SetAttribute("EmoteProperty", true)
			table.insert(list, rightHandle)
			p4.md = rightHandle
			rightHandle.Part0 = folder["Right Arm"]
			rightHandle.Part1 = clone2
			rightHandle.Parent = folder["Right Arm"]
			clone2.Parent = folder
		end,
		HideWeapon = true,
		Idle = 15502977193,
		Animation = 15502978256,
		Looped = false,
		Stun = "Slowed"
	}
	v5["Party Blower"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://12332077418",
				Volume = 1
			}
		},
		Startup = function(list, _, p4)
			local clone = script.blower:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local cylinder = clone.Cylinder.Cylinder
			cylinder:SetAttribute("EmoteProperty", true)
			table.insert(list, cylinder)
			p4.md = cylinder
			cylinder.Part0 = folder.Head
			cylinder.Part1 = clone.Cylinder
			cylinder.Name = "Cylinder"
			cylinder.Parent = folder.Head
			clone.Parent = folder
		end,
		Keyframes = {
			clap = function()
				fn10({
					SoundId = "rbxassetid://16599449151",
					Parent = folder.Head,
					Volume = 1.5
				}):Play()
			end
		},
		IdleKeyframes = true,
		Infinite = true,
		Idle = 16599398107,
		Animation = 16599412902,
		Stun = "Slowed",
		StunAttribute = 1
	}
	v5["Eye Pop"] = {
		HideWeapon = true,
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17097414525",
				Volume = 1,
				ParentTorso = true,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Leye1:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local m6d = clone.m6d
			m6d:SetAttribute("EmoteProperty", true)
			table.insert(list, m6d)
			p4.md = m6d
			m6d.Part0 = folder.Head
			m6d.Part1 = clone
			m6d.Name = "Leye1"
			m6d.Parent = folder.Head
			clone.Parent = folder
			local clone2 = script.Reye1:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(list, clone2)
			p4.Handle = clone2
			local m6d2 = clone2.m6d
			m6d2:SetAttribute("EmoteProperty", true)
			table.insert(list, m6d2)
			p4.md = m6d2
			m6d2.Part0 = folder.Head
			m6d2.Part1 = clone2
			m6d2.Name = "Reye1"
			m6d2.Parent = folder.Head
			clone2.Parent = folder
		end,
		Fix = true,
		Animation = 17097409396,
		Stun = "Freeze"
	}
	v5.Brooming = {
		HideWeapon = true,
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15297645043",
				Volume = 1,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Broom:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local m6d = clone.m6d
			m6d:SetAttribute("EmoteProperty", true)
			table.insert(list, m6d)
			p4.md = m6d
			clone.Name = "Part"
			m6d.Part0 = folder["Left Arm"]
			m6d.Part1 = clone
			m6d.Name = "Part"
			m6d.Parent = folder["Left Arm"]
			clone.Parent = folder
		end,
		Infinite = true,
		Animation = 15297647499,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Kitty Cat"] = {
		HideWeapon = true,
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15099918372",
				Volume = 0.35,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Maxwell:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local m6d = clone.m6d
			m6d:SetAttribute("EmoteProperty", true)
			table.insert(list, m6d)
			p4.md = m6d
			m6d.Part0 = folder["Left Arm"]
			m6d.Part1 = clone.maxwell
			m6d.Name = "maxwell"
			m6d.Parent = folder["Left Arm"]
			clone.Parent = folder
		end,
		Keyframes = {
			clap = function()
				if math.random(1, 3) == 1 then
					fn10({
						SoundId = ({
							"rbxassetid://15099947619",
							"rbxassetid://15099947876",
							"rbxassetid://15099948214"
						})[math.random(1, 3)],
						Parent = folder.PrimaryPart,
						Volume = 0.4
					}):Play()
				end
			end
		},
		Infinite = true,
		Animation = 15099900787,
		Looped = true,
		Stun = "Slowed"
	}
	v5["The Strongest Rocks"] = {
		HideWeapon = true,
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15438805005",
				Volume = 1,
				Looped = false
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Guitar:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			clone.Name = "Handle"
			handle.Part0 = folder["Left Arm"]
			handle.Part1 = clone
			handle.Parent = folder["Left Arm"]
			clone.Parent = folder
		end,
		Keyframes = {
			["end"] = function(p4)
				p4.Handle:Destroy()
			end
		},
		Infinite = true,
		Animation = 15438891684,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Party = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15100051516",
				Volume = 1,
				Looped = false
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Popper:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			clone.Name = "Handle"
			handle.Part0 = folder["Left Arm"]
			handle.Part1 = clone
			handle.Parent = folder["Left Arm"]
			clone.Parent = folder
		end,
		Keyframes = {
			pop = function(p4, attachments, _)
				local attachment = p4.Handle.Attachment
				attachment:SetAttribute("EmoteProperty", true)
				attachment.Parent = folder.PrimaryPart
				table.insert(attachments, attachment)

				for _, child in pairs(attachment:GetChildren()) do
					shared.resizeparticle(child, 1.25)
					child:Emit(25 / #attachment:GetChildren())
				end
			end,
			["end"] = function(p4)
				p4.Handle:Destroy()
			end
		},
		Animation = 15100081900,
		Looped = false,
		Stun = "Slowed"
	}
	v5.Skull = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15271585302",
				Volume = 0.4,
				Looped = false
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Skull:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			clone.Name = "Handle"
			handle.Part0 = folder["Left Arm"]
			handle.Part1 = clone
			handle.Parent = folder["Left Arm"]
			clone.Parent = folder
		end,
		Keyframes = {
			["end"] = function(p4)
				p4.Handle:Destroy()
			end
		},
		Animation = 15271569844,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Cross = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16524227044",
				Volume = 2,
				Looped = false
			}
		},
		HideWeapon = true,
		Idle = 16524243757,
		Animation = 16524237104,
		Looped = false,
		Stun = "Freeze"
	}
	v5["Cross 2"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://18828346536",
				Volume = 1.25,
				Looped = false
			}
		},
		HideWeapon = true,
		Idle = 18897553669,
		Animation = 18897551628,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Situp = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15673857335",
				Volume = 2,
				Looped = false
			}
		},
		HideWeapon = true,
		Infinite = true,
		Idle = 15674164857,
		IdleSound = {
			SoundId = "rbxassetid://15674129833",
			Volume = 1,
			Looped = true
		},
		Animation = 15674077481,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Superhero = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://9042798921",
				TimePosition = 1,
				Volume = 1
			},
			[0.01] = {
				SoundId = "rbxassetid://17109047369",
				Volume = 1
			}
		},
		End = {
			17109013631,
			0.933,
			{
				SoundId = "rbxassetid://17109047546",
				Volume = 1
			}
		},
		IdleSound = {
			SoundId = "rbxassetid://9114663740",
			Volume = 0.25,
			Looped = true
		},
		HideWeapon = true,
		Idle = 17109012516,
		Animation = 17109009771,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Sleep = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17108967672",
				Volume = 1
			}
		},
		HideWeapon = true,
		End = {
			17108974875,
			2.533,
			{
				SoundId = "rbxassetid://17108967908",
				Volume = 1
			}
		},
		IdleSound = {
			SoundId = "rbxassetid://9114663740",
			Volume = 0.25,
			Looped = true
		},
		FixRotation = true,
		Idle = 17108973561,
		Animation = 17108971736,
		Looped = false,
		Stun = "Freeze"
	}
	v5["Stylish Flip"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17086578816",
				Volume = 1,
				TimePosition = 0.1,
				Looped = false
			}
		},
		HideWeapon = true,
		End = {
			17086594393,
			1.183,
			{
				SoundId = "rbxassetid://17086578943",
				Volume = 1,
				Looped = false
			}
		},
		Idle = 17086601693,
		Animation = 17086569715,
		Looped = false,
		Stun = "Freeze"
	}
	v5["Sincere Apology"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://76131937398399",
				Volume = 1,
				ParentTorso = true,
				Looped = false
			}
		},
		HideWeapon = true,
		Idle = 131394881582474,
		Animation = 118382652729061,
		Stun = "Freeze"
	}
	v5.Pushup = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15673857335",
				Volume = 2,
				Looped = false
			}
		},
		HideWeapon = true,
		Infinite = true,
		Idle = 15673865087,
		IdleSound = {
			SoundId = "rbxassetid://15673857667",
			Volume = 1,
			Looped = true
		},
		Animation = 15673860575,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Gang = {
		Sounds = {},
		Startup = function(list, _, _)
			local cfolder = shared.cfolder({
				Name = "SBind",
				Parent = folder
			})
			cfolder:SetAttribute("EmoteProperty", true)
			table.insert(list, cfolder)
			local v8, music = fn10({
				SoundId = "rbxassetid://83080858871410",
				Volume = 1,
				Parent = folder.Torso,
				Looped = false
			})
			v8:Play()

			if playerFromCharacter then
				tick()
				local v11 = playerFromCharacter
				local v12

				if friendcache[v11] then
					v12 = friendcache[v11]
				end

				local ids = v12 or {}

				if #ids == 0 then
					local function iterPageItems(object2)
						return coroutine.wrap(function()
							local v13 = 1

							while true do
								for _, v14 in ipairs(object2:GetCurrentPage()) do
									coroutine.yield(v14, v13)
								end

								if object2.IsFinished then
									break
								end

								object2:AdvanceToNextPageAsync()
								v13 += 1
							end
						end)
					end

					local Players = game:GetService("Players")
					local friendsAsync = Players:GetFriendsAsync(playerFromCharacter.UserId)

					for k, _ in coroutine.wrap(function()
						local v13 = 1

						while true do
							for _, v14 in ipairs(friendsAsync:GetCurrentPage()) do
								coroutine.yield(v14, v13)
							end

							if friendsAsync.IsFinished then
								break
							end

							friendsAsync:AdvanceToNextPageAsync()
							v13 += 1
						end
					end) do
						table.insert(ids, k.Id)
					end

					if #ids > 0 then
						friendcache[playerFromCharacter] = ids
					end
				end

				local friends = {}

				for _ = 1, 4 do
					if not (#ids > 0) then
						continue
					end

					local v14 = math.random(#ids)
					table.insert(friends, ids[v14])
					table.remove(ids, v14)
				end

				game.ReplicatedStorage.Replication:FireAllClients({
					Effect = "GANG",
					Character = folder,
					Friends = friends,
					Bind = cfolder,
					Music = music
				})
			end
		end,
		Cooldown = 5,
		HideWeapon = true,
		Infinite = true,
		Idle = 112138009997034,
		Animation = 119293848229043,
		Looped = false,
		Stun = "Freeze"
	}
	v5["Best Friends"] = {
		Sounds = {},
		Startup = function(list, _, _)
			local cfolder = shared.cfolder({
				Name = "SBind",
				Parent = folder
			})
			cfolder:SetAttribute("EmoteProperty", true)
			table.insert(list, cfolder)
			local v8, _ = fn10({
				SoundId = "rbxassetid://83119347007476",
				Volume = 0.5,
				Parent = folder.PrimaryPart,
				Looped = true
			})
			local attachment = Instance.new("Attachment")
			attachment.Parent = folder.PrimaryPart
			attachment.Position = createVector(-2.443, 0, 0)
			v8.Parent = attachment
			table.insert(list, v8)
			v8:Play()

			if playerFromCharacter then
				tick()
				local v10 = playerFromCharacter
				local v11

				if friendcache[v10] then
					v11 = friendcache[v10]
				end

				local ids = v11 or {}

				if #ids == 0 then
					local function iterPageItems(object2)
						return coroutine.wrap(function()
							local v12 = 1

							while true do
								for _, v13 in ipairs(object2:GetCurrentPage()) do
									coroutine.yield(v13, v12)
								end

								if object2.IsFinished then
									break
								end

								object2:AdvanceToNextPageAsync()
								v12 += 1
							end
						end)
					end

					local Players = game:GetService("Players")
					local friendsAsync = Players:GetFriendsAsync(playerFromCharacter.UserId)

					for k, _ in coroutine.wrap(function()
						local v12 = 1

						while true do
							for _, v13 in ipairs(friendsAsync:GetCurrentPage()) do
								coroutine.yield(v13, v12)
							end

							if friendsAsync.IsFinished then
								break
							end

							friendsAsync:AdvanceToNextPageAsync()
							v12 += 1
						end
					end) do
						table.insert(ids, k.Id)
					end

					if #ids > 0 then
						friendcache[playerFromCharacter] = ids
					end
				end

				local friends = {}

				for _ = 1, 3 do
					if not (#ids > 0) then
						continue
					end

					local v13 = math.random(#ids)
					table.insert(friends, ids[v13])
					table.remove(ids, v13)
				end

				game.ReplicatedStorage.Replication:FireAllClients({
					Effect = "BFFS",
					Character = folder,
					Friends = friends,
					Bind = cfolder,
					Music = attachment
				})
			end
		end,
		Cooldown = 5,
		HideWeapon = true,
		Infinite = true,
		Animation = 105494624349321,
		Looped = true,
		Stun = "Slowed"
	}
	v5["First Rule"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15503520699",
				Volume = 1.85,
				Looped = false
			}
		},
		Startup = function(list, _, p4)
			local cfolder = shared.cfolder({
				Name = "SBind",
				Parent = folder
			})
			cfolder:SetAttribute("EmoteProperty", true)
			table.insert(list, cfolder)
			local v8, _ = fn10({
				SoundId = "rbxassetid://1837904676",
				Volume = 0.25,
				Parent = root,
				Looped = true
			})
			local attachment = Instance.new("Attachment")
			attachment.Parent = folder.PrimaryPart
			v8.Parent = attachment
			table.insert(list, v8)
			v8:Play()
			local clone = script.ColaFight:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			clone.Name = "Handle"
			handle.Part0 = folder["Right Arm"]
			handle.Part1 = clone
			handle.Parent = folder["Right Arm"]
			clone.Parent = folder

			if playerFromCharacter then
				game.ReplicatedStorage.Replication:FireClient(playerFromCharacter, {
					Effect = "FightC",
					Character = folder,
					Bind = cfolder,
					Music = attachment
				})
			end
		end,
		Keyframes = {
			claploop = function()
				fn10({
					SoundId = "rbxassetid://15503520430",
					Parent = folder.PrimaryPart,
					Volume = 1.5
				}):Play()
			end
		},
		HideWeapon = true,
		Infinite = true,
		Idle = 15503546989,
		IdleKeyframes = true,
		Animation = 15503532950,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Countdown = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15283152008",
				Volume = 1.85,
				Looped = false
			},
			[4.033] = {
				SoundId = "rbxassetid://15283155687",
				Volume = 5,
				Looped = false
			}
		},
		Startup = function(list, _, clonesByName)
			local ok = fn10({
				SoundId = "rbxassetid://1842188426",
				Volume = 0.4,
				Parent = folder.PrimaryPart
			})
			ok:Play()
			clonesByName.ok = ok

			for _, child in pairs(script.Revolvers:GetChildren()) do
				if child.Name ~= "Handle" then
					continue
				end

				local clone = child:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				clonesByName[clone.Name] = clone
				local handle = clone.Handle
				handle:SetAttribute("EmoteProperty", true)
				table.insert(list, handle)
				clonesByName.md = handle
				clone.Name = "Handle"
				handle.Part0 = folder["Left Arm"]
				handle.Part1 = clone
				handle.Parent = folder["Left Arm"]
				clone.Parent = folder
			end
		end,
		Keyframes = {
			shoot = function(p4)
				if playerFromCharacter then
					game.ReplicatedStorage.Replication:FireClient(playerFromCharacter, {
						Effect = "Camshake",
						Intensity = 8
					})
				end

				TweenService:Create(p4.ok, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Volume = 0
				}):Play()
				p4.Handle.Gun.Attachment.ParticleEmitter:Emit(2)
			end,
			["end"] = function(p4)
				p4.Handle:Destroy()
			end
		},
		Animation = 15284324734,
		Looped = false,
		Stun = "Slowed"
	}
	v5["New Sheriff"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15311093430",
				Volume = 1.5,
				Looped = false
			},
			[0.1] = {
				SoundId = "rbxassetid://1842190166",
				Volume = 0.3,
				Looped = false
			},
			[4.2] = {
				SoundId = "rbxassetid://9114701864",
				Volume = 0.5,
				Looped = false
			},
			[2.49] = {
				SoundId = "rbxassetid://9113593647",
				Volume = 3.6
			}
		},
		Startup = function(list, _, clonesByName)
			local clone = script.Revolver:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			clonesByName[clone.Name] = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			clonesByName.md = handle
			clone.Name = "Handle"
			handle.Part0 = folder["Right Arm"]
			handle.Part1 = clone
			handle.Parent = folder["Right Arm"]
			clone.Parent = folder
		end,
		Keyframes = {
			shoot = function(p4)
				if playerFromCharacter then
					game.ReplicatedStorage.Replication:FireClient(playerFromCharacter, {
						Effect = "Camshake",
						Intensity = 8
					})
				end

				fn10({
					SoundId = "rbxassetid://15310981185",
					Parent = folder.PrimaryPart,
					TimePosition = 0.11,
					Volume = 2.5
				}):Resume()

				for _, child in pairs(p4.Revolver.Shoot:GetChildren()) do
					child.Enabled = true
				end

				task.delay(0.05, function()
					p4.Revolver.Shoot:Destroy()
				end)

				if not hitbox then
					local Hitbox = require(game.ServerStorage.Hitbox)
					hitbox = Hitbox
				end

				if not force then
					local Force = require(game.ServerStorage.Force)
					force = Force
				end

				local hit = hitbox:GetHit(playerFromCharacter or true, 7, {
					side = 5
				}, false, -3)
				local v8 = 2000000000
				local v9 = nil

				for _, v10 in pairs(hit) do
					local magnitude = (v10.PrimaryPart.Position - folder.PrimaryPart.Position).magnitude

					if not (magnitude < v8 and v10.Humanoid.Health <= 0) then
						continue
					end

					v9 = v10
					v8 = magnitude
				end

				local v10 = { v9 }
				task.delay(0.045, function()
					for _, hit2 in pairs(v10) do
						force:CreateForce({
							char = folder,
							hit = hit2,
							pushback = 0,
							up = createVector(0, 1.75, 0)
						})
						shared.sfx({
							SoundId = "rbxassetid://15311018533",
							Parent = hit2.PrimaryPart,
							Volume = 3
						}):Play()
					end
				end)
			end,
			["end"] = function(p4)
				p4.Revolver:Destroy()
			end
		},
		HideWeapon = true,
		Animation = 15310973900,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Fool = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15283205480",
				Volume = 1.85,
				Looped = false
			},
			[0.01] = {
				SoundId = "rbxassetid://1842188443",
				Volume = 0.6,
				Looped = false
			},
			[6.62] = {
				SoundId = "rbxassetid://15283205587",
				Volume = 1.85,
				Looped = false
			}
		},
		Startup = function(list, _, clonesByName)
			for _, child in pairs(script.Revolvers:GetChildren()) do
				if child.Name ~= "Handle2" then
					continue
				end

				local clone = child:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				clonesByName[clone.Name] = clone
				local handle = clone.Handle
				handle:SetAttribute("EmoteProperty", true)
				table.insert(list, handle)
				clonesByName.md = handle
				handle.C0 = CFrame.new(-0.0250015259, -0.999999762, 0.00322246552, 1, 0, 0, 0, 1, 0, 0, 0, 1)
				handle.C1 = CFrame.new(-0.0500030518, -0.0202150345, 0.0032453537, 1, 0, 0, 0, 1, 0, 0, 0, 1)
				clone.Name = "Handle"
				handle.Part0 = folder["Right Arm"]
				handle.Part1 = clone
				handle.Parent = folder["Right Arm"]
				clone.Parent = folder
			end
		end,
		Keyframes = {
			["end"] = function(p4)
				p4.Handle2:Destroy()
			end
		},
		HideWeapon = true,
		Animation = 15283197429,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Snake = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15271610757",
				Volume = 1.85,
				Looped = false
			},
			[0.01] = {
				SoundId = "rbxassetid://1842190005",
				Volume = 0.6,
				Looped = false
			}
		},
		Startup = function(list, _, clonesByName)
			for _, child in pairs(script.Revolvers:GetChildren()) do
				local v8 = child.Name == "Handle2" and "Right Arm" or "Left Arm"
				local clone = child:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				clonesByName[clone.Name] = clone
				local handle = clone.Handle
				handle:SetAttribute("EmoteProperty", true)
				table.insert(list, handle)
				clonesByName.md = handle
				clone.Name = "Handle"
				handle.Part0 = folder[v8]
				handle.Part1 = clone
				handle.Parent = folder[v8]
				clone.Parent = folder
			end
		end,
		Keyframes = {
			["end"] = function(p4)
				p4.Handle:Destroy()
				p4.Handle2:Destroy()
			end,
			slow = function(_, _, object2)
				object2:AdjustSpeed(0.4)
			end,
			away = function(_, _, object2)
				object2:AdjustSpeed(1)
				fn10({
					SoundId = "rbxassetid://15271610473",
					Volume = 1.85,
					Looped = false,
					Parent = folder.PrimaryPart
				}):Play()
			end
		},
		Animation = 15271677861,
		Looped = false,
		Stun = "Slowed",
		HideWeapon = true
	}
	v5["Lean Back"] = {
		Sounds = {},
		Startup = function(list, _, p4)
			local clone = script.CHAIR:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			clone.Name = "CHAIR"
			handle.Part0 = folder.Torso
			handle.Part1 = clone
			handle.Parent = folder.Torso
			clone.Parent = folder
			fn10({
				SoundId = "rbxassetid://17106914725",
				Parent = folder.Torso,
				Volume = 1
			}):Play()
		end,
		Fix = true,
		Animation = 17106924052,
		Stun = "Freeze"
	}
	v5["Taco Time"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1846971107",
				Volume = 0.4,
				Looped = true,
				TimePosition = 0.1,
				ParentTorso = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.TACO1:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local TACO1 = clone.TACO1
			TACO1:SetAttribute("EmoteProperty", true)
			table.insert(list, TACO1)
			p4.md = TACO1
			TACO1.Part0 = folder["Right Arm"]
			TACO1.Part1 = clone
			TACO1.Parent = folder["Right Arm"]
			clone.Parent = folder
			local clone2 = script.TACO2:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(list, clone2)
			p4.Handle = clone2
			local TACO2 = clone2.TACO2
			TACO2:SetAttribute("EmoteProperty", true)
			table.insert(list, TACO2)
			p4.md = TACO2
			TACO2.Part0 = folder["Left Arm"]
			TACO2.Part1 = clone2
			TACO2.Parent = folder["Left Arm"]
			clone2.Parent = folder
		end,
		Looped = true,
		HideWeapon = true,
		Animation = 17107076756,
		Stun = "Freeze"
	}
	v5.Card = {
		Sounds = {},
		Startup = function(list, _, p4)
			local clone = script["Meshes/cARD"]:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local meshescARD = clone["Meshes/cARD"]
			meshescARD:SetAttribute("EmoteProperty", true)
			table.insert(list, meshescARD)
			p4.md = meshescARD
			meshescARD.Part0 = folder["Right Arm"]
			meshescARD.Part1 = clone
			meshescARD.Parent = folder["Right Arm"]
			clone.Parent = folder
			fn10({
				SoundId = "rbxassetid://17120974824",
				Parent = clone,
				Volume = 1
			}):Play()
		end,
		HideWeapon = true,
		Animation = 17120966975,
		Stun = "Freeze"
	}
	v5.Plank = {
		Sounds = {},
		Startup = function(list, _, p4)
			local clone = script.Plank:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			clone.Name = "Handle"
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			clone.Name = "Handle"
			handle.Part0 = folder["Right Arm"]
			handle.Part1 = clone
			handle.Parent = folder["Right Arm"]
			clone.Parent = folder
			fn10({
				SoundId = "rbxassetid://17107178506",
				Parent = clone,
				Volume = 1
			}):Play()
		end,
		Idle = 17107199838,
		IdleSound = {
			SoundId = "rbxassetid://17107178615",
			Volume = 1,
			Looped = true
		},
		HideWeapon = true,
		Animation = 17107197570,
		Stun = "Slowed"
	}
	v5.Cola = {
		Sounds = {},
		Startup = function(list, _, p4)
			local clone = script.ColaTwo:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			clone.Name = "Handle"
			handle.Part0 = folder["Right Arm"]
			handle.Part1 = clone
			handle.Parent = folder["Right Arm"]
			clone.Parent = folder
			p4.mesh = clone.Mesh
			fn10({
				SoundId = "rbxassetid://17120785426",
				Parent = clone,
				Volume = 1
			}):Play()
		end,
		Keyframes = {
			["end"] = function(p4, _)
				TweenService:Create(p4.mesh, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Scale = Vector3.new()
				}):Play()
			end
		},
		HideWeapon = true,
		Animation = 17120842242,
		Stun = "Slowed"
	}
	v5.Bread = {
		Sounds = {},
		Startup = function(list, _, p4)
			p4.breads = {}
			local v8 = {
				Bread1 = CFrame.new(
					-0.9290413856506348,
					-0.3216838836669922,
					-0.9804582595825195,
					-1,
					0,
					0,
					0,
					1,
					0,
					0,
					0,
					-1
				),
				Bread2 = CFrame.new(
					-0.9290413856506348,
					-0.41446352005004883,
					-0.9804582595825195,
					-1,
					0,
					0,
					0,
					1,
					0,
					0,
					0,
					-1
				),
				Bread3 = CFrame.new(
					-0.9290413856506348,
					-0.5068368911743164,
					-0.9804582595825195,
					-1,
					0,
					0,
					0,
					1,
					0,
					0,
					0,
					-1
				),
				Bread4 = CFrame.new(
					-0.9290413856506348,
					-0.599616527557373,
					-0.9804582595825195,
					-1,
					0,
					0,
					0,
					1,
					0,
					0,
					0,
					-1
				)
			}

			for k, C0 in pairs(v8) do
				local clone = script.Bread1:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				clone.Name = k
				local motor6D = Instance.new("Motor6D")
				motor6D:SetAttribute("EmoteProperty", true)
				table.insert(list, motor6D)
				p4.md = motor6D
				clone.Name = k
				motor6D.Part0 = folder.Torso
				motor6D.Part1 = clone
				motor6D.Parent = folder.Torso
				motor6D.C0 = C0
				clone.Parent = folder
				table.insert(p4.breads, clone)
			end

			fn10({
				SoundId = "rbxassetid://17121814784",
				Parent = folder["Right Arm"],
				Volume = 1
			}):Play()
		end,
		Keyframes = {
			["end"] = function(p4, _)
				for _, bread in pairs(p4.breads) do
					for _, v8 in pairs({ bread, bread.Crust }) do
						TweenService:Create(v8, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Size = Vector3.new()
						}):Play()
					end
				end
			end
		},
		HideWeapon = true,
		Animation = 17121769642,
		Stun = "Slowed"
	}
	v5.Flashlight = {
		Sounds = {},
		Startup = function(_, _, p4)
			local clone = script.Flashlight:Clone()
			CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			local handle = clone.Handle
			CollectionService2:AddTag(handle, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			clone.Name = "Handle"
			handle.Part0 = folder["Right Arm"]
			handle.Part1 = clone
			handle.Parent = folder["Right Arm"]
			clone.Parent = folder
			p4.mesh = clone.SurfaceLight
			fn10({
				SoundId = "rbxassetid://17120880738",
				Parent = clone,
				Volume = 1
			}):Play()
		end,
		Keyframes = {
			start = function(p4, _)
				p4.mesh.Enabled = true
			end
		},
		HideWeapon = true,
		Idle = 17120870445,
		End = {
			17120873919,
			0.983,
			{
				SoundId = "rbxassetid://12981981352",
				Volume = 1,
				Looped = false
			}
		},
		Animation = 17120866178,
		Stun = "Slowed"
	}
	v5.Rainy = {
		Sounds = {},
		Startup = function(clones, _, p4)
			local clone = script.Cloud:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone)
			p4.Handle = clone
			local weld = Instance.new("Weld")
			weld.Part0 = folder.PrimaryPart
			weld.Part1 = clone
			weld.C0 = CFrame.new(0, 6.6855607, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			weld.Parent = clone
			clone.Parent = folder
			fn10({
				SoundId = "rbxassetid://17121715447",
				Parent = clone,
				Volume = 1,
				Looped = true
			}):Play()
		end,
		Looped = true,
		HideWeapon = true,
		Animation = 17121695329,
		Stun = "Freeze"
	}
	v5.Box = {
		Sounds = {},
		Startup = function(list, _, p4, _, p5)
			local clone = script.Carboard:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			clone.Name = "Base"
			handle.Part0 = folder.PrimaryPart
			handle.Part1 = clone.Base
			handle.Parent = folder.PrimaryPart
			clone.Parent = folder
			fn10({
				SoundId = "rbxassetid://17122337086",
				Parent = clone.Base,
				Volume = 1,
				TimePosition = 0.25
			}):Resume()
			task.spawn(function()
				local v8 = fn14(17122265672)
				v8:AdjustWeight(35)
				table.insert(list, v8)
				local v9 = fn10({
					SoundId = "rbxassetid://17122337244",
					Parent = clone.Base,
					Volume = 0.15,
					Looped = true
				})

				while task.wait() and not p5.interrupted do
					if p5.interrupted or not folder.Parent then
						v8:Stop()
						break
					end

					if folder.Humanoid.MoveDirection == Vector3.new() then
						if v8.IsPlaying then
							v8:Stop(0.3)
						end

						v9:Stop()
					else
						v9:Resume()

						if not v8.IsPlaying then
							v8:Play(0.3)
						end
					end
				end

				v8:AdjustWeight(0.01)
				v8:Stop()
			end)
		end,
		HideWeapon = true,
		Idle = 17122254184,
		Animation = 17122214043,
		Stun = "Slowed"
	}
	v5["Air Horn"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17292689498",
				ParentTorso = true,
				Volume = 1
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Airhorn:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			handle.Name = "Airhorn"
			handle.Part0 = folder["Right Arm"]
			handle.Part1 = clone.Airhorn
			handle.Parent = folder["Right Arm"]
			clone.Parent = folder
		end,
		HideWeapon = true,
		Animation = 17292579443,
		Stun = "Slowed"
	}
	v5.Owl = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17292555531",
				ParentTorso = true,
				Volume = 1
			}
		},
		HideWeapon = true,
		Animation = 17292549897,
		Stun = "Freeze"
	}
	v5["Mic Drop"] = {
		Sounds = {},
		Startup = function(list, _, p4)
			local clone = script.MIC:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			clone.Name = "MIC"
			handle.Part0 = folder.PrimaryPart
			handle.Part1 = clone
			handle.Parent = folder.PrimaryPart
			clone.Parent = folder
			fn10({
				SoundId = "rbxassetid://17106346778",
				Parent = clone,
				Volume = 1
			}):Play()
		end,
		HideWeapon = true,
		Animation = 17106365733,
		Stun = "Freeze"
	}
	v5["Luv This Game"] = {
		Sounds = {},
		Startup = function(list, _, p4)
			local clone = script.HeartTSB:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local main2 = clone.Main2
			main2:SetAttribute("EmoteProperty", true)
			table.insert(list, main2)
			p4.md = main2
			main2.Name = "Main"
			main2.Part0 = folder.PrimaryPart
			main2.Part1 = clone.Main
			main2.Parent = folder.PrimaryPart
			clone.Parent = folder
			fn10({
				SoundId = "rbxassetid://17269138016",
				Parent = folder.PrimaryPart,
				Volume = 1
			}):Play()
		end,
		HideWeapon = true,
		Animation = 17269134625,
		Stun = "Slowed"
	}
	v5.Mango = {
		Sounds = {},
		Startup = function(list, _, p4)
			local clone = script.MangoFork:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local fork2 = clone.Fork2
			fork2:SetAttribute("EmoteProperty", true)
			table.insert(list, fork2)
			p4.md = fork2
			fork2.Name = "Fork"
			fork2.Part0 = folder["Right Arm"]
			fork2.Part1 = clone.Fork
			fork2.Parent = folder["Right Arm"]
			clone.Parent = folder
			fn10({
				SoundId = "rbxassetid://17269071380",
				Parent = clone.Fork,
				Volume = 1
			}):Play()
		end,
		Keyframes = {
			dead = function(p4, _, _)
				p4.Handle.Mango:Destroy()
				p4.Handle.mangopart:Destroy()
			end
		},
		HideWeapon = true,
		Animation = 17269079177,
		Stun = "Slowed"
	}
	v5.Action = {
		Sounds = {},
		Startup = function(list, _, p4)
			local clone = script.Clapboard:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			handle.Name = "Bottom"
			handle.Part0 = folder["Left Arm"]
			handle.Part1 = clone.Bottom
			handle.Parent = folder["Left Arm"]
			clone.Parent = folder
			fn10({
				SoundId = "rbxassetid://17268545081",
				Parent = clone.Bottom,
				Volume = 1
			}):Play()
		end,
		HideWeapon = true,
		Animation = 17268549637,
		Stun = "Slowed"
	}
	v5["Sad Times"] = {
		Sounds = {
			[2.5] = {
				SoundId = "rbxassetid://1836112668",
				ParentTorso = true,
				Volume = 0.175
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Phone2:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local phone2 = clone.Phone2
			phone2:SetAttribute("EmoteProperty", true)
			table.insert(list, phone2)
			p4.md = phone2
			phone2.Name = "Phone"
			clone.Name = "Phone"
			phone2.Part0 = folder["Right Arm"]
			phone2.Part1 = clone.Phone
			phone2.Parent = folder["Right Arm"]
			clone.Parent = folder
			fn10({
				SoundId = "rbxassetid://17268986804",
				Parent = clone.Phone,
				Volume = 1
			}):Play()
		end,
		Keyframes = {
			clap = function()
				fn10({
					SoundId = "rbxassetid://" .. ({ 7455224144, 7455246815, 7455224490 })[math.random(1, 3)],
					Parent = folder["Left Leg"],
					PlaybackSpeed = 1,
					Volume = 0.2,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end
		},
		HideWeapon = true,
		Animation = 17268991944,
		Idle = 17269023470,
		IdleKeyframes = true,
		Stun = "Slowed"
	}
	v5["Me Reading The Book That"] = {
		Sounds = {},
		Startup = function(list, _, p4)
			local clone = script.Bookk:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local bookk = clone.Bookk
			bookk:SetAttribute("EmoteProperty", true)
			table.insert(list, bookk)
			p4.md = bookk
			clone.Name = "Book"
			bookk.Name = "Base"
			bookk.Part0 = folder.PrimaryPart
			bookk.Part1 = clone.Base
			bookk.Parent = folder.PrimaryPart
			clone.Parent = folder
			p4.handle = clone
			fn10({
				SoundId = "rbxassetid://17268616635",
				Parent = clone.Base,
				Volume = 1
			}):Play()
			shared.s = fn10({
				SoundId = "rbxassetid://9043379206",
				Parent = folder.Torso,
				Volume = 1
			})
			shared.s:Play()
		end,
		Keyframes = {
			stop = function(_, _, _)
				shared.s:Stop()
			end,
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		Fix = true,
		HideWeapon = true,
		Looped = true,
		Animation = 17268619636,
		Stun = "Freeze"
	}
	v5.UFO = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1835904215",
				Volume = 0.5,
				ParentTorso = true,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.UFO:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local UFO = clone.UFO
			UFO:SetAttribute("EmoteProperty", true)
			table.insert(list, UFO)
			p4.md = UFO
			UFO.Part0 = folder.PrimaryPart
			UFO.Part1 = clone
			UFO.Parent = folder.PrimaryPart
			clone.Parent = folder
			p4.handle = clone
		end,
		HideWeapon = true,
		Looped = true,
		Animation = 17268633540,
		Stun = "Slowed",
		StunAttribute = 1
	}
	v5["Pizza Delivery"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://122292723",
				Volume = 0.5,
				ParentTorso = true,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Pizza:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local pizza = clone.Pizza
			pizza:SetAttribute("EmoteProperty", true)
			table.insert(list, pizza)
			p4.md = pizza
			pizza.Part0 = folder.PrimaryPart
			pizza.Name = "Base"
			pizza.Part1 = clone.Base
			pizza.Parent = folder.PrimaryPart
			clone.Parent = folder
			p4.handle = clone
		end,
		HideWeapon = true,
		Looped = true,
		Animation = 17268742277,
		Stun = "Slowed",
		StunAttribute = 1
	}
	v5["Angry Riff"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1836019934",
				Volume = 1,
				ParentTorso = true,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Guitar2:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local guitar = clone.Guitar
			guitar:SetAttribute("EmoteProperty", true)
			table.insert(list, guitar)
			p4.md = guitar
			guitar.Part0 = folder["Right Arm"]
			guitar.Part1 = clone
			clone.Name = "Guitar"
			guitar.Parent = folder["Right Arm"]
			clone.Parent = folder
			p4.handle = clone
		end,
		HideWeapon = true,
		Looped = true,
		Animation = 17268926242,
		Stun = "Slowed"
	}
	v5.Flute = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1838868548",
				Volume = 1,
				ParentTorso = true,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.flute:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			handle.Part0 = folder["Right Arm"]
			handle.Part1 = clone
			clone.Name = "Handle"
			handle.Parent = folder["Right Arm"]
			clone.Parent = folder
			p4.handle = clone
		end,
		Keyframes = {
			clap = function()
				fn10({
					SoundId = "rbxassetid://" .. ({ 7455224144, 7455246815, 7455224490 })[math.random(1, 3)],
					Parent = folder["Left Leg"],
					PlaybackSpeed = 1,
					Volume = 0.15,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end
		},
		HideWeapon = true,
		Looped = true,
		Animation = 17268859608,
		Stun = "Slowed"
	}
	v5["Magic Carpet"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1837365487",
				Volume = 0.5,
				TimePosition = 0.5,
				ParentTorso = true,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.carpet:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local carpet = clone.carpet
			carpet:SetAttribute("EmoteProperty", true)
			table.insert(list, carpet)
			p4.md = carpet
			carpet.Part0 = folder.PrimaryPart
			carpet.Part1 = clone
			carpet.Parent = folder.PrimaryPart
			clone.Parent = folder
			p4.handle = clone
		end,
		HideWeapon = true,
		Looped = true,
		Animation = 17268716692,
		Stun = "Slowed",
		StunAttribute = 1
	}
	v5.Dribble = {
		Sounds = {},
		Startup = function(list, _, p4)
			local clone = script.basklektball:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local basklektball = clone.basklektball
			basklektball:SetAttribute("EmoteProperty", true)
			table.insert(list, basklektball)
			p4.md = basklektball
			basklektball.Part0 = folder.PrimaryPart
			basklektball.Part1 = clone
			basklektball.Parent = folder.PrimaryPart
			clone.Parent = folder
			p4.handle = clone
		end,
		Keyframes = {
			clap = function(p4, _, _)
				shared.sfx({
					SoundId = "rbxassetid://14404844095",
					PlaybackSpeed = Random.new():NextNumber(0.9, 1.1),
					Parent = p4.handle,
					RollOffMaxDistance = rollOffMaxDistance,
					Volume = 1
				}):Play()
			end
		},
		HideWeapon = true,
		Looped = true,
		Infinite = true,
		Animation = 17268369862,
		Stun = "Slowed",
		StunAttribute = 1
	}
	v5["Yummy Watermelon"] = {
		Sounds = {},
		Startup = function(list, _, p4)
			fn10({
				SoundId = "rbxassetid://17268447339",
				Parent = folder.Head,
				Volume = 1,
				Looped = true
			}):Play()
			local clone = script.watermelon:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local watermelon = clone.Watermelon
			watermelon:SetAttribute("EmoteProperty", true)
			table.insert(list, watermelon)
			p4.md = watermelon
			watermelon.Part0 = folder["Right Arm"]
			clone.Name = "Watermelon"
			watermelon.Part1 = clone
			watermelon.Parent = folder["Right Arm"]
			clone.Parent = folder
			p4.handle = clone
		end,
		HideWeapon = true,
		Looped = true,
		Infinite = true,
		Animation = 17268468485,
		Stun = "Freeze"
	}
	v5["Dry Lips"] = {
		Sounds = {
			[0.7330000000000001] = {
				SoundId = "rbxassetid://9120086770",
				Volume = 0.25
			},
			[2.017] = {
				SoundId = "rbxassetid://9120087000",
				Volume = 0.25
			}
		},
		Startup = function(list, _, p4)
			local clone = script.tang:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local part = clone.Part
			part:SetAttribute("EmoteProperty", true)
			table.insert(list, part)
			p4.md = part
			clone.Name = "Part"
			part.Part0 = folder.Head
			part.Part1 = clone
			part.Parent = folder.Head
			clone.Parent = folder
		end,
		Animation = 104081288316829,
		StunAttribute = 1.5,
		Stun = "Slowed"
	}
	v5.Surrender = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17106985996",
				Volume = 0.85
			}
		},
		Startup = function(list, _, p4)
			local clone = script.surrender_Flag:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			handle.Name = "Pole"
			handle.Part0 = folder["Right Arm"]
			handle.Part1 = clone.Pole
			handle.Parent = folder["Right Arm"]
			clone.Parent = folder
		end,
		HideWeapon = true,
		Animation = 17107015056,
		Idle = 17107016598,
		IdleSound = {
			SoundId = "rbxassetid://17106985885",
			Volume = 0.35,
			Looped = true
		},
		Stun = "Slowed"
	}
	v5.Watermelon = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17105975829",
				Volume = 0.065,
				Looped = true
			},
			[0.01] = {
				SoundId = "rbxassetid://1841061037",
				Volume = 0.3,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Watermelon:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			clone.Name = "Watermelon"
			handle.Part0 = folder["Right Arm"]
			handle.Part1 = clone
			handle.Parent = folder["Right Arm"]
			clone.Parent = folder
		end,
		HideWeapon = true,
		Animation = 17105983229,
		Looped = true,
		Stun = "Slowed"
	}
	v5["WATERMELON "] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://9045473815",
				Volume = 0.4,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Watermelon2:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			clone.Name = "Watermelon"
			handle.Part0 = folder.HumanoidRootPart
			handle.Part1 = clone
			handle.Parent = folder.HumanoidRootPart
			clone.Parent = folder
		end,
		Animation = 17137575195,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Log = {
		Sounds = {},
		Startup = function(list, _, p4)
			local clone = script.Log:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			clone.Name = "Handle"
			handle.Part0 = folder["Right Arm"]
			handle.Part1 = clone
			handle.Parent = folder["Right Arm"]
			clone.Parent = folder
			fn10({
				SoundId = "rbxassetid://9120937669",
				Parent = folder.PrimaryPart,
				Volume = 0.5
			}):Play()
			fn10({
				SoundId = "rbxassetid://9120823421",
				Parent = folder.PrimaryPart,
				Volume = 0.075,
				Looped = true
			}):Play()
		end,
		Keyframes = {
			clap = function()
				fn10({
					SoundId = "rbxassetid://15090365735",
					Parent = folder.PrimaryPart,
					Volume = 0.75
				}):Play()
			end
		},
		Infinite = true,
		Animation = 15090459593,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Rolling = {
		Sounds = {},
		Startup = function(list, _, p4)
			local clone = script.Film:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			clone.Name = "Handle"
			handle.Part0 = folder["Right Arm"]
			handle.Part1 = clone
			handle.Parent = folder["Right Arm"]
			clone.Parent = folder
			fn10({
				SoundId = "rbxassetid://15310783637",
				Parent = clone,
				Volume = 0.5,
				Looped = true
			}):Play()
		end,
		Keyframes = {
			claploop = function()
				fn10({
					SoundId = "rbxassetid://15310800059",
					Parent = folder.PrimaryPart,
					Volume = 1.5
				}):Play()
			end
		},
		HideWeapon = true,
		Infinite = true,
		Animation = 15310866392,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Cook = {
		Sounds = {},
		Startup = function(list, _, p4)
			local clone = script.Pan:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			clone.Name = "Handle"
			handle.Part0 = folder["Left Arm"]
			handle.Part1 = clone
			handle.Parent = folder["Left Arm"]
			clone.Parent = folder
			fn10({
				SoundId = "rbxassetid://15283317649",
				Parent = clone,
				Looped = true
			}):Play()
			fn10({
				SoundId = "rbxassetid://160247625",
				Parent = folder.PrimaryPart,
				Volume = 0.5
			}):Play()
		end,
		Keyframes = {
			clap = function()
				fn10({
					SoundId = "rbxassetid://15283317709",
					Parent = folder.PrimaryPart,
					Volume = 2
				}):Play()
			end
		},
		Infinite = true,
		Animation = 15283329867,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Coffee = {
		Sounds = {},
		Startup = function(list, _, p4)
			local clone = script.Coffee:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local m6d = clone.m6d
			m6d:SetAttribute("EmoteProperty", true)
			table.insert(list, m6d)
			p4.md = m6d
			clone.Name = "Handle"
			m6d.Part0 = folder["Left Arm"]
			m6d.Part1 = clone
			m6d.Parent = folder["Left Arm"]
			clone.Parent = folder
		end,
		Keyframes = {
			claploop = function()
				fn10({
					SoundId = "rbxassetid://15487197007",
					Parent = folder.PrimaryPart,
					Volume = 1
				}):Play()
			end
		},
		Infinite = true,
		Animation = 15487200157,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Scooter = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17292925358",
				Volume = 0.1,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Scooter:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local motor6D = clone.Motor6D
			motor6D:SetAttribute("EmoteProperty", true)
			table.insert(list, motor6D)
			p4.md = motor6D
			motor6D.Part0 = folder.PrimaryPart
			motor6D.Part1 = clone.Base
			motor6D.Parent = folder.PrimaryPart
			clone.Parent = folder
			local forceField = folder:FindFirstChildOfClass("ForceField")
			local v8 = (workspace:GetAttribute("GameStarted") or not workspace:GetAttribute("RankedOnes")) and true or false

			if forceField and forceField:GetAttribute("Emote") then
				v8 = false
			end

			if v8 then
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity:SetAttribute("EmoteProperty", true)
				table.insert(list, bodyVelocity)
				p4.BV = bodyVelocity
				bodyVelocity.Name = "moveme"
				bodyVelocity.MaxForce = createVector(10000, 0, 10000)
				bodyVelocity:SetAttribute("Speed", 12)
				bodyVelocity:SetAttribute("Goto", 12)
				bodyVelocity:SetAttribute("RayCheck", true)
				bodyVelocity:SetAttribute("End", 1)
				bodyVelocity:SetAttribute("Fallout", 0.991)
				bodyVelocity.Parent = folder.PrimaryPart
			end
		end,
		Keyframes = {
			clap = function(p4)
				task.delay(0.417, function()
					if p4.BV and p4.BV.Parent then
						local BV = p4.BV
						local v10 = -0.01
						local v11 = 0.01

						if not v11 and v10 then
							v11 = v10
							v10 = 1
						end

						if not (v11 or v10) then
							v10 = 0
							v11 = 1
						end

						BV:SetAttribute("Speed", 45 + random:NextNumber(v10, v11))
					end
				end)
				fn10({
					SoundId = "rbxassetid://17292932603",
					Parent = folder.PrimaryPart,
					Volume = 0.3
				}):Play()
			end
		},
		Infinite = true,
		Animation = 17292934579,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Skateboard = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15090263539",
				Volume = 0.825,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Skateboard:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local m6d = clone.m6d
			m6d:SetAttribute("EmoteProperty", true)
			table.insert(list, m6d)
			p4.md = m6d
			m6d.Name = "Handle"
			m6d.Part0 = folder.PrimaryPart
			m6d.Part1 = clone.Handle
			m6d.Parent = folder.PrimaryPart
			clone.Parent = folder
			local forceField = folder:FindFirstChildOfClass("ForceField")
			local v8 = (workspace:GetAttribute("GameStarted") or not workspace:GetAttribute("RankedOnes")) and true or false

			if forceField and forceField:GetAttribute("Emote") then
				v8 = false
			end

			if v8 then
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity:SetAttribute("EmoteProperty", true)
				table.insert(list, bodyVelocity)
				p4.BV = bodyVelocity
				bodyVelocity.Name = "moveme"
				bodyVelocity.MaxForce = createVector(10000, 0, 10000)
				bodyVelocity:SetAttribute("Speed", 12)
				bodyVelocity:SetAttribute("Goto", 12)
				bodyVelocity:SetAttribute("RayCheck", true)
				bodyVelocity:SetAttribute("End", 1)
				bodyVelocity:SetAttribute("Fallout", 0.991)
				bodyVelocity.Parent = folder.PrimaryPart
			end
		end,
		Keyframes = {
			clap = function(p4)
				task.delay(2.184, function()
					if p4.BV and p4.BV.Parent then
						local BV = p4.BV
						local v10 = -0.01
						local v11 = 0.01

						if not v11 and v10 then
							v11 = v10
							v10 = 1
						end

						if not (v11 or v10) then
							v10 = 0
							v11 = 1
						end

						BV:SetAttribute("Speed", 45 + random:NextNumber(v10, v11))
					end
				end)
				fn10({
					SoundId = "rbxassetid://15090244072",
					Parent = folder.PrimaryPart,
					Volume = 0.75
				}):Play()
			end
		},
		Infinite = true,
		Animation = 15090273850,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Pls = {
		Sounds = {},
		Startup = function(list, _, p4)
			local clone = script.Sign:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			clone.Name = "Handle"
			handle.Part0 = folder["Left Arm"]
			handle.Part1 = clone
			handle.Parent = folder["Left Arm"]
			clone.Parent = folder
			fn10({
				SoundId = "rbxassetid://9126280354",
				Parent = folder.PrimaryPart,
				Volume = 0.5
			}):Play()
		end,
		Keyframes = {
			clap = function()
				fn10({
					SoundId = "rbxassetid://15092688139",
					Parent = folder.PrimaryPart,
					Volume = 0.1
				}):Play()
			end,
			claploop = function()
				fn10({
					SoundId = "rbxassetid://15092688069",
					Parent = folder.PrimaryPart,
					Volume = 0.1
				}):Play()
			end,
			snap = function()
				fn10({
					SoundId = "rbxassetid://15092714389",
					Parent = folder.PrimaryPart,
					Volume = 0.1
				}):Play()
			end
		},
		Infinite = true,
		Animation = 15092699174,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Square Up"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://72334795012520",
				Volume = 1,
				Looped = false
			}
		},
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end,
			armsinvis = function()
				for _, childName in pairs({ "Left Arm", "Right Arm" }) do
					local child = folder:FindFirstChild(childName)

					if child then
						child.Transparency = 1
					end
				end
			end,
			legsinvis = function()
				for _, childName in pairs({ "Left Leg", "Right Leg" }) do
					local child = folder:FindFirstChild(childName)

					if child then
						child.Transparency = 1
					end
				end
			end
		},
		Startup = function(list, _, _, _, _, instance2)
			local cfolder = shared.cfolder({
				Name = "Freeze"
			}, 1.75)
			table.insert(list, cfolder)
			cfolder:SetAttribute("DontInterrupt", true)
			cfolder:SetAttribute("NoStop", true)
			cfolder:SetAttribute("EmoteProperty", true)

			if instance2 then
				instance2:GetPropertyChangedSignal("Parent"):Connect(function()
					shared.cfolder({
						Name = "RestoreVisibility",
						Parent = folder
					}, 0.25)
				end)
			end

			task.delay(0, function()
				cfolder.Parent = folder
			end)
		end,
		Fix = true,
		HideWeapon = true,
		Animation = 95561134536060,
		Stun = "Slowed"
	}
	v5["Heartful Salute"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17097492489",
				Volume = 1,
				TimePosition = 0.1,
				Looped = false
			}
		},
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		HideWeapon = true,
		Animation = 17097486020,
		Stun = "Freeze"
	}
	v5.Juggler = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://121999038626924",
				Volume = 1,
				Looped = true
			}
		},
		Startup = function(cleanup, _, mind)
			for _, child in pairs(script.Juggling:GetChildren()) do
				fn8({
					cleanup = cleanup,
					char = folder,
					object = child,
					part0 = folder.Torso,
					part1 = tostring(child),
					mind = mind,
					parent = folder.Torso
				})
			end
		end,
		Animation = 119367166308066,
		Looped = true,
		Stun = "Slowed",
		StunAttribute = 1
	}
	v5.Thinker = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15090345405",
				Volume = 1,
				Looped = false
			},
			[0.01] = {
				SoundId = "rbxassetid://1841319934",
				Volume = 0.65,
				Looped = true
			}
		},
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		Startup = function(list, _, p4)
			local clone = script.ThinkerRock:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			clone.Name = "Handle"
			handle.Part0 = folder.PrimaryPart
			handle.Part1 = clone
			handle.Parent = folder.PrimaryPart
			clone.Parent = folder
		end,
		Animation = 15089930092,
		Looped = true,
		Stun = "Freeze"
	}
	v5["Look!"] = {
		Sounds = {},
		Keyframes = {
			clap = function(_)
				fn10({
					SoundId = "rbxassetid://17086269758",
					RollOffMaxDistance = rollOffMaxDistance,
					Parent = folder.Head,
					Volume = 0.85
				}):Play()
			end
		},
		Infinite = true,
		Animation = 17086291067,
		Looped = true,
		Stun = "Freeze"
	}
	v5.Munch = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15018666363",
				Volume = 1.5,
				Looped = false
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Steak:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			clone.Name = "Handle"
			handle.Name = "Handle"
			handle.Part0 = folder["Left Arm"]
			handle.Part1 = clone
			handle.Parent = folder["Left Arm"]
			local attachment = clone.Attachment
			attachment:SetAttribute("EmoteProperty", true)
			table.insert(list, attachment)
			p4.att = attachment
			clone.Parent = folder
		end,
		Keyframes = {
			["end"] = function(p4)
				p4.Handle["Meshes/steak2_Cube"].Transparency = 1
				p4.att.Popcorn.Enabled = false
				task.delay(0.3, function()
					fn10({
						SoundId = "rbxassetid://9113414870",
						Parent = folder.Head,
						Volume = 1
					}):Play()
				end)
			end,
			start = function(p4)
				p4.att.Popcorn.Enabled = true
			end
		},
		Animation = 15018688063,
		Looped = false,
		Stun = "Slowed"
	}
	v5.Salt = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17086202883",
				Volume = 0.85,
				TimePosition = 0.2,
				Looped = false
			},
			[2.45] = {
				SoundId = "rbxassetid://14065053293",
				Volume = 0.4
			}
		},
		Startup = function(list, _, p4)
			local attachment = Instance.new("Attachment")
			table.insert(list, attachment)
			attachment:SetAttribute("EmoteProperty", true)
			attachment.Parent = folder["Right Arm"]
			attachment.Position = createVector(-0.407, -0.9, 0)
			local clone = script.Salt:Clone()
			clone.Enabled = false
			clone.Parent = attachment
			p4.salt = clone
		end,
		Keyframes = {
			["end"] = function(p4)
				p4.salt.Enabled = false
			end,
			start = function(p4)
				p4.salt.Enabled = true
			end
		},
		HideWeapon = true,
		Animation = 17086225519,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Smile = {
		Sounds = {
			[2] = {
				SoundId = "rbxassetid://15310427179",
				Volume = 1.5,
				Looped = false
			},
			[0.8] = {
				SoundId = "rbxassetid://12981981352",
				Volume = 0.35
			},
			[0] = {
				SoundId = "rbxassetid://12982203916",
				Volume = 0.5
			}
		},
		Startup = function(list, _, p4)
			fn10({
				SoundId = "rbxassetid://7244593699",
				Parent = folder.PrimaryPart,
				Volume = 0.75
			}):Play()
			fn10({
				SoundId = "rbxassetid://13726870246",
				Parent = folder.PrimaryPart,
				Volume = 0.75
			}):Play()
			local clone = script.Camera.Handle:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.camera = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			clone.Name = "Handle"
			handle.Name = "Handle"
			handle.Part0 = folder["Left Arm"]
			handle.Part1 = clone
			handle.Parent = folder["Left Arm"]
			clone.Parent = folder
			local clone2 = script.Camera.SmallHandle:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(list, clone2)
			p4.picture = clone2
			local smallHandle = clone2.SmallHandle
			smallHandle:SetAttribute("EmoteProperty", true)
			table.insert(list, smallHandle)
			p4.md = smallHandle
			smallHandle.Part0 = folder["Right Arm"]
			smallHandle.Part1 = clone2
			smallHandle.Parent = folder["Right Arm"]
			clone2.Parent = folder

			for _, descendant in pairs(p4.picture.Photo:GetDescendants()) do
				if descendant:IsA("BasePart") or descendant:IsA("Decal") then
					descendant.Transparency = 1
				end
			end
		end,
		Keyframes = {
			flash = function(p4)
				local attachment = Instance.new("Attachment")
				CollectionService2:AddTag(attachment, "emotestuff" .. folder.Name)
				attachment.Parent = p4.camera.Camera["Camera Low"].Lends
				local Debris = game:GetService("Debris")
				Debris:AddItem(attachment, 5)
				local clone = script.ImpactGlow:Clone()
				clone.Parent = attachment
				shared.resizeparticle(clone, fn12(1, 1.2))
				clone:Emit(1)
				local createlight = shared.createlight
				local v8 = {
					Position = attachment.WorldPosition,
					Color = Color3.new(1, 1, 1),
					Brightness = 0,
					Fade = 0,
					Range = 0
				}
				local v9 = 7
				local v10 = 10

				if not v10 and v9 then
					v10 = v9
					v9 = 1
				end

				if not (v10 or v9) then
					v9 = 0
					v10 = 1
				end

				v8.Brightness = random:NextNumber(v9, v10)
				local v11 = 0.3
				local v12 = 0.5

				if not v12 and v11 then
					v12 = v11
					v11 = 1
				end

				if not (v12 or v11) then
					v11 = 0
					v12 = 1
				end

				v8.Fade = random:NextNumber(v11, v12)
				local v13 = 10
				local v14 = 12

				if not v14 and v13 then
					v14 = v13
					v13 = 1
				end

				if not (v14 or v13) then
					v13 = 0
					v14 = 1
				end

				v8.Range = random:NextNumber(v13, v14)
				createlight(v8)
			end,
			visible = function(p4)
				for _, descendant in pairs(p4.picture.Photo:GetDescendants()) do
					if descendant:IsA("BasePart") or descendant:IsA("Decal") then
						descendant.Transparency = 0
					end
				end
			end,
			end1 = function(p4)
				p4.camera:Destroy()
			end,
			end2 = function(p4)
				p4.picture:Destroy()
			end
		},
		HideWeapon = true,
		Animation = 15310466614,
		Looped = false,
		Stun = "Slowed"
	}
	v5.Score = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://14678100852",
				Volume = 1.25,
				Looped = false
			}
		},
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end,
			score = function(p4, _, _)
				local text = nil

				for _, v8 in pairs(CollectionService2:GetTagged("notepad")) do
					if not (v8 ~= p4.Handle and (v8.pages.Position - p4.Handle.pages.Position).magnitude <= 25) then
						continue
					end

					local textLabel = v8:FindFirstChildWhichIsA("TextLabel", true)

					if textLabel then
						text = textLabel.Text
					end
				end

				local surfaceGui = p4.Handle.pages.SurfaceGui
				surfaceGui.TextLabel.Text = text or math.random(-1, 10)
				surfaceGui.Enabled = true
			end
		},
		Startup = function(clones, _, p4)
			local clone = script.Notepad.Model:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone)
			p4.Handle = clone
			CollectionService2:AddTag(clone, "notepad")

			for _, motor6D in pairs(script.Notepad:GetChildren()) do
				if not motor6D:IsA("Motor6D") then
					continue
				end

				local clone2 = motor6D:Clone()
				clone2:SetAttribute("EmoteProperty", true)
				table.insert(clones, clone2)
				p4.md = clone2
				clone2.Part0 = folder["Left Arm"]
				clone2.Part1 = clone[motor6D.Name]
				clone2.Parent = folder["Left Arm"]
			end

			clone.Parent = folder
		end,
		Animation = 14678167232,
		Looped = false,
		Stun = "Slowed"
	}
	v5.Crowbar = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://14697227297",
				Volume = 1.5,
				TimePosition = 0,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.crowbar:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local M6D = clone.M6D
			M6D:SetAttribute("EmoteProperty", true)
			table.insert(list, M6D)
			p4.md = M6D
			M6D.Name = "Handle"
			M6D.Part0 = folder["Left Arm"]
			M6D.Part1 = clone.Handle
			M6D.Parent = folder["Left Arm"]
			clone.Parent = folder
		end,
		Animation = 14697228259,
		Looped = true,
		Stun = "Freeze"
	}
	v5.Popcorn = {
		HideWeapon = true,
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15018377297",
				Volume = 3,
				TimePosition = 0,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Popcorn:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			clone.Name = "Handle"
			handle.Name = "Handle"
			handle.Part0 = folder["Left Arm"]
			handle.Part1 = clone
			handle.Parent = folder["Left Arm"]
			local attachment = clone.Attachment
			attachment.Popcorn.Enabled = true
			attachment:SetAttribute("EmoteProperty", true)
			table.insert(list, attachment)
			p4.att = attachment
			attachment.Parent = folder["Right Arm"]
			clone.Parent = folder
		end,
		Animation = 15018466007,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Mop = {
		HideWeapon = true,
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://14520228185",
				Volume = 0.9,
				TimePosition = 0,
				Looped = true
			}
		},
		Startup = function(clones, _, p4)
			local clone = script.Mop.Handle:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone)
			p4.Handle = clone
			local clone2 = script.Mop.M6D:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone2)
			p4.md = clone2
			clone2.Name = "Handle"
			clone2.Part0 = folder["Left Arm"]
			clone2.Part1 = clone
			clone2.Parent = folder["Left Arm"]
			clone.Parent = folder
		end,
		Animation = 14520410356,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Bouncy = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://14659137741",
				Volume = 0.9,
				TimePosition = 0,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Bounce.Sphere:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			clone.BrickColor = BrickColor.Random()
			local motor6D = clone:FindFirstChildOfClass("Motor6D")
			motor6D:SetAttribute("EmoteProperty", true)
			table.insert(list, motor6D)
			p4.md = motor6D
			motor6D.Name = "Sphere"
			motor6D.Part0 = folder.PrimaryPart
			motor6D.Part1 = clone
			motor6D.Parent = folder.PrimaryPart
			clone.Parent = folder
		end,
		Fix = true,
		Animation = 14659143045,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Wiggle = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1835606556",
				Volume = 0.3,
				TimePosition = 0.25,
				Looped = true
			}
		},
		Animation = 14495337027,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Gleeful Jumping"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://109463610060222",
				Volume = 1,
				Looped = true
			}
		},
		Animation = 136460538117500,
		Looped = true,
		Stun = "Slowed",
		StunAttribute = 1.15
	}
	v5.Crazy = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://14492925439",
				Volume = 2.75,
				Looped = false
			}
		},
		Keyframes = {
			start = function(p4, list)
				local clone = script.Confused:Clone()
				local weld = Instance.new("Weld")
				p4.crazy = clone
				p4.particle = clone.Attachment.Swirl

				for _, v8 in pairs({ clone, weld }) do
					v8:SetAttribute("EmoteProperty", true)
					table.insert(list, v8)
				end

				weld.Parent = clone
				weld.Part0 = folder.PrimaryPart
				weld.Part1 = clone
				weld.C0 = CFrame.new(0, 2.75, 0)
				clone.Transparency = 1
				clone.Parent = workspace.Thrown
				game.ReplicatedStorage.Replication:FireAllClients({
					Effect = "Rotate",
					Weld = weld,
					Crazy = clone
				})
			end,
			["end"] = function(p4, _)
				local crazy = p4.crazy
				local particle = p4.particle
				crazy.Transparency = 0
				TweenService:Create(crazy, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
				task.spawn(function()
					for _ = 1, 25 do
						if not particle.Parent then
							break
						end

						local numberSequenceKeypoints = {}

						for _, keypoint in pairs(particle.Transparency.Keypoints) do
							table.insert(
								numberSequenceKeypoints,
								NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * 1.1, keypoint.Envelope)
							)
						end

						particle.Transparency = NumberSequence.new(numberSequenceKeypoints)
						task.wait()
					end
				end)
			end
		},
		Animation = 14494902453,
		Looped = false,
		Stun = "Slowed"
	}
	v5["Traditional Duel"] = {
		Keyframes = {
			ready = function(_, items)
				local v10 = 1.9
				local v11 = 2.1

				if not v11 and v10 then
					v11 = v10
					v10 = 1
				end

				if not (v11 or v10) then
					v10 = 0
					v11 = 1
				end

				fn10({
					SoundId = "rbxassetid://15502708435",
					Volume = random:NextNumber(v10, v11),
					Parent = folder.Torso
				}):Play()

				for _, sound in pairs(items) do
					if not (typeof(sound) == "Instance" and sound:IsA("Sound") and sound.SoundId == "rbxassetid://1843699308") then
						continue
					end

					TweenService:Create(sound, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
						Volume = 0
					}):Play()
				end
			end,
			shoot = function(p4)
				for _, child in pairs(p4.Revolver.Shoot:GetChildren()) do
					child.Enabled = true
				end

				task.delay(0.05, function()
					p4.Revolver.Shoot:Destroy()
				end)
			end,
			away = function(p4)
				TweenService:Create(
					p4.Revolver.Gun.Mesh,
					TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Scale = Vector3.new()
					}
				):Play()
			end
		},
		Startup = function(list, _, clonesByName)
			local clone = script.Revolver:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			clonesByName[clone.Name] = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			clonesByName.md = handle
			clone.Name = "Handle"
			handle.Part0 = folder["Right Arm"]
			handle.Part1 = clone
			handle.C0 = CFrame.new(0, -1, -0.01)
			handle.C1 = CFrame.new(0, 0, 0)
			local weld = clone:FindFirstChildOfClass("Weld")
			weld.C0 = CFrame.new(-0.245002747, -0.67500329, 0.100135803, 1, 0, -0, 0, 0, 1, 0, -1, 0)
			handle.Parent = folder["Right Arm"]
			clone.Parent = folder
		end,
		Dual = {
			DoBoth = false,
			Dist = 16,
			NoRotate = 10.3,
			Callback = function(instance2, p4, list, p5)
				local _, _ = fn10({
					SoundId = "rbxassetid://15502708235",
					Parent = instance2.Torso,
					Volume = 1
				}):Play()
				local _, _ = fn10({
					SoundId = "rbxassetid://15502708235",
					Parent = p4.Torso,
					Volume = 1
				}):Play()
				local v8, parent = fn10({
					SoundId = "rbxassetid://1843699308",
					CFrame = CFrame.new(),
					Volume = 1
				})
				table.insert(list, v8)
				v8:Play()
				parent.Parent = instance2.PrimaryPart
				parent.WorldPosition = (instance2.PrimaryPart.CFrame * CFrame.new(0, 0, -p5 / 2)).Position
				fn10({
					SoundId = "rbxassetid://1842188393",
					Parent = parent,
					Volume = 1
				}):Play()
			end
		},
		HideWeapon = true,
		FixRotation = true,
		Fix = true,
		Tag = "duelgun",
		Animation = 15502751480,
		Looped = false,
		Stun = "Freeze"
	}
	v5["Clap Clap"] = {
		Keyframes = {
			clap = function(p4, _, object2)
				if not p4.speed then
					p4.speed = 1
				end

				object2:AdjustSpeed((math.clamp(p4.speed, 1, 10)))
				p4.speed += 0.025
				shared.sfx({
					SoundId = "rbxassetid://9099667351",
					Parent = folder.PrimaryPart,
					RollOffMaxDistance = rollOffMaxDistance,
					Volume = 0.2
				}):Play()
			end,
			claploop = function()
				shared.sfx({
					SoundId = "rbxassetid://16038515606",
					Parent = folder.PrimaryPart,
					RollOffMaxDistance = rollOffMaxDistance,
					Volume = 0.2
				}):Play()
			end,
			snap = function()
				shared.sfx({
					SoundId = "rbxassetid://9099667351",
					Parent = folder.PrimaryPart,
					Volume = 0.2,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end
		},
		Startup = function() end,
		Dual = {
			DoBoth = false,
			Dist = 3.5,
			Callback = function(instance2, _, _, p4)
				local _, v8 = fn10({
					SoundId = "rbxassetid://14519690317",
					CFrame = CFrame.new(),
					Volume = 1.5
				})
				v8.Parent = instance2.PrimaryPart
				v8.WorldPosition = (instance2.PrimaryPart.CFrame * CFrame.new(0, 0, -p4 / 2)).Position
			end
		},
		HideWeapon = true,
		Infinite = true,
		Tag = "ptycake",
		Animation = 16038562573,
		Looped = true,
		Stun = "Freeze"
	}
	v5["Rock Paper Scissor"] = {
		Keyframes = {
			show = function(_, clones)
				local clone = script.RPS:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(clones, clone)
				clone.ImageLabel.Image = ({
					"rbxassetid://14519869178",
					"rbxassetid://14519869488",
					"rbxassetid://14519869787"
				})[math.random(1, 3)]
				clone.Parent = folder["Left Arm"]
				clone.Enabled = true
				task.delay(1, function()
					TweenService:Create(
						clone.ImageLabel,
						TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							Size = UDim2.new(0, 0, 0, 0)
						}
					):Play()
				end)
			end
		},
		Startup = function() end,
		Dual = {
			DoBoth = false,
			Dist = 7.2,
			Callback = function(instance2, _, _, p4)
				local v8, v9 = fn10({
					SoundId = "rbxassetid://14519690317",
					CFrame = CFrame.new(),
					Volume = 1.5
				})
				task.delay(0.15, function()
					if v8.Parent then
						v8:Play()
					end
				end)
				v9.Parent = instance2.PrimaryPart
				v9.WorldPosition = (instance2.PrimaryPart.CFrame * CFrame.new(0, 0, -p4 / 2)).Position
			end
		},
		Tag = "rps",
		Animation = 14519894954,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Steel = {
		Dual = {
			DoBoth = false,
			Dist = 8,
			NoRotate = 18.3,
			Callback = function(instance2, _, list, _)
				if list.done then
					return
				end

				list.done = true
				local AnimationPlayer = require(instance2.CharacterHandler:WaitForChild("AnimationPlayer"))
				local v8 = (function(p4)
					return AnimationPlayer.playAnimation(instance2:FindFirstChild("Humanoid"), p4)
				end)(15963617746)
				v8.Priority = Enum.AnimationPriority.Action4
				v8:AdjustWeight(1)
				v8:Play()
				table.insert(list, v8)
				local v9, v10 = fn10({
					SoundId = "rbxassetid://15963599920",
					CFrame = CFrame.new(),
					Volume = 1
				})
				table.insert(list, v9)
				v9:Play()
				v10.Parent = instance2["Left Arm"]
			end
		},
		Startup = function() end,
		Fix = true,
		HideWeapon = true,
		Tag = "steel",
		Animation = 15963602367,
		AnimationTwo = 15963617746,
		Stun = "Freeze"
	}
	v5["Friendly Hug"] = {
		Startup = function(_, _, _, _)
			if instance then
			end
		end,
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17097669113",
				Volume = 1
			}
		},
		Dual = {
			DoBoth = false,
			NoRotate = 0,
			Freeze = false,
			Attach = true,
			RotateCheck = true,
			Callback = function(parent, instance2, list, _)
				if list.done then
					return
				end

				list.done = true
				local cfolder = shared.cfolder({
					Name = "RootAnchor"
				})
				cfolder.Parent = parent
				table.insert(list, cfolder)
				CollectionService2:AddTag(cfolder, "RemoveOnLeave" .. (instance or playerFromCharacter or parent).Name)
				local v8 = {}
				local parts = {}

				for _, folder2 in pairs({ parent }) do
					table.insert(v8, folder2.DescendantAdded:connect(function(part)
						if part:IsA("BasePart") then
							part.CollisionGroup = "nocol"
							table.insert(parts, part)
						end
					end))

					for _, part in pairs(folder2:GetDescendants()) do
						if not part:IsA("BasePart") then
							continue
						end

						part.CollisionGroup = "nocol"
						local v9 = part
						local collisionGroupChangedConnection = part:GetPropertyChangedSignal("CollisionGroup"):Connect(function()
							if v9.CollisionGroup ~= "nocol" then
								v9.CollisionGroup = "nocol"
							end
						end)
						table.insert(v8, collisionGroupChangedConnection)
						task.delay(2, function()
							if collisionGroupChangedConnection then
								return collisionGroupChangedConnection:Disconnect()
							end
						end)
						table.insert(parts, part)
					end
				end

				cfolder:GetPropertyChangedSignal("Parent"):Connect(function()
					if not cfolder.Parent then
						for _, connection in pairs(v8) do
							connection:Disconnect()
						end

						for _, v9 in pairs(parts) do
							v9.CollisionGroup = "playercol"
						end
					end
				end)
				CollectionService2:AddTag(cfolder, instance2.Name .. "carry")
				local AnimationPlayer = require(parent.CharacterHandler:WaitForChild("AnimationPlayer"))
				local AnimationPlayer2 = require(instance2.CharacterHandler:WaitForChild("AnimationPlayer"))

				local function fn15(p4)
					return AnimationPlayer2.playAnimation(instance2:FindFirstChild("Humanoid"), p4)
				end

				local v9 = fn15(17097648428)
				v9.Priority = Enum.AnimationPriority.Action4
				v9:AdjustWeight(1)
				v9:Play()
				table.insert(list, v9)
				fn15(17096821069):AdjustWeight(0.01)
				table.insert(list, v9.Stopped:Once(function()
					fn15(17097627771):Stop()
				end))
				local v10 = (function(p4)
					return AnimationPlayer.playAnimation(parent:FindFirstChild("Humanoid"), p4)
				end)(17097651485)
				v10.Priority = Enum.AnimationPriority.Action4
				v10:AdjustWeight(1)
				v10:Play()
				table.insert(list, v10)
				fn10({
					SoundId = "rbxassetid://17097669243",
					Parent = instance2.Torso,
					Volume = 1
				}):Play()
				game.ReplicatedStorage.Replication:FireAllClients({
					Effect = "Smooth Grab",
					CanBypass = true,
					Hit = parent,
					StartOffset = parent.PrimaryPart.CFrame,
					From = instance2.PrimaryPart,
					Offset = CFrame.new(0, 0, -3),
					Anchor = cfolder
				})
			end
		},
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		HideWeapon = true,
		Fix = true,
		Looped = true,
		Tag = "hug1",
		Animation = 17097627771,
		AnimationTwo = 17097651485,
		Stun = "Freeze"
	}
	v5["Fresh Cut"] = {
		Startup = function(list, _, p4, _)
			if instance then
				return
			end

			fn10({
				SoundId = "rbxassetid://17106578615",
				Parent = folder.PrimaryPart,
				Volume = 1
			}):Play()
			local clone = script.CHAIRBASE:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			clone.Name = "CHAIRBASE"
			handle.Part0 = folder.PrimaryPart
			handle.Part1 = clone
			handle.Parent = folder.PrimaryPart
			clone.Parent = folder
			local clone2 = script.Clipper:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(list, clone2)
			p4.Handle = clone2
			local handle2 = clone2.Handle
			handle2:SetAttribute("EmoteProperty", true)
			table.insert(list, handle2)
			p4.md = handle2
			clone2.Name = "Clipper"
			handle2.Part0 = folder["Right Arm"]
			handle2.Part1 = clone2
			handle2.Parent = folder["Right Arm"]
			clone2.Parent = folder
		end,
		Dual = {
			DoBoth = false,
			NoRotate = 0,
			Freeze = false,
			Attach = true,
			RotateCheck = true,
			Callback = function(folder2, instance2, list, _)
				if list.done then
					return
				end

				list.done = true
				local cfolder = shared.cfolder({
					Name = "RootAnchor"
				})
				cfolder.Parent = folder2
				table.insert(list, cfolder)
				CollectionService2:AddTag(cfolder, "RemoveOnLeave" .. (instance or playerFromCharacter or folder2).Name)
				local connections = {}
				local parts = {}

				for _, folder3 in pairs({ folder2 }) do
					table.insert(connections, folder3.DescendantAdded:connect(function(part)
						if part:IsA("BasePart") then
							part.CollisionGroup = "nocol"
							table.insert(parts, part)
						end
					end))

					for _, part in pairs(folder3:GetDescendants()) do
						if not part:IsA("BasePart") then
							continue
						end

						part.CollisionGroup = "nocol"
						table.insert(parts, part)
					end
				end

				cfolder:GetPropertyChangedSignal("Parent"):Connect(function()
					if not cfolder.Parent then
						for _, connection in pairs(connections) do
							connection:Disconnect()
						end

						for _, v8 in pairs(parts) do
							v8.CollisionGroup = "playercol"
						end
					end
				end)
				CollectionService2:AddTag(cfolder, instance2.Name .. "barber")
				fn10({
					SoundId = "rbxassetid://17106662871",
					Parent = folder2.Head,
					TimePosition = 0.15,
					Volume = 0.5
				}):Resume()
				local AnimationPlayer = require(folder2.CharacterHandler:WaitForChild("AnimationPlayer"))

				local function fn15(p4)
					return AnimationPlayer.playAnimation(folder2:FindFirstChild("Humanoid"), p4)
				end

				local AnimationPlayer2 = require(instance2.CharacterHandler:WaitForChild("AnimationPlayer"))

				local function fn16(p4)
					return AnimationPlayer2.playAnimation(instance2:FindFirstChild("Humanoid"), p4)
				end

				local v8 = fn16(17106475377)
				v8.Priority = Enum.AnimationPriority.Action4
				v8:AdjustWeight(1)
				v8:Play(0)
				table.insert(list, v8)
				fn16(17106466215):AdjustWeight(0.001)
				fn15(17106466215):AdjustWeight(0.001)
				local v9 = false
				table.insert(list, v8.Stopped:Once(function()
					fn16(17106466215):Stop(0)
					fn15(17106466215):Stop(0)
					v9 = true
				end))
				task.delay(9.3, function()
					if v9 or not v8.IsPlaying then
						return
					end

					for _, accessory in pairs(folder2:GetDescendants()) do
						if accessory:IsA("Accessory") and accessory:FindFirstChild("HairAttachment", true) then
							accessory:Destroy()
						end
					end

					local children = game.ReplicatedStorage.Emotes.Hairs:GetChildren()
					local clone = children[math.random(#children)]:Clone()
					folder2.Humanoid:AddAccessory(clone)
				end)
				local v10 = fn15(17106484670)
				v10.Priority = Enum.AnimationPriority.Action4
				v10:AdjustWeight(1)
				v10:Play(0)
				table.insert(list, v10)
				game.ReplicatedStorage.Replication:FireAllClients({
					Effect = "Smooth Grab",
					CanBypass = true,
					Hit = folder2,
					StartOffset = folder2.PrimaryPart.CFrame,
					From = instance2.PrimaryPart,
					NoLook = true,
					Offset = CFrame.new(-3, 0, 0),
					Anchor = cfolder
				})
			end
		},
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		HideWeapon = true,
		Fix = true,
		Looped = true,
		Tag = "barber1",
		Animation = 17106466215,
		AnimationTwo = 17106475377,
		Stun = "Freeze"
	}
	v5["Ping Pong"] = {
		Startup = function(list, _, p4, _)
			local clone = script.Racket:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local m6d = clone.m6d
			m6d:SetAttribute("EmoteProperty", true)
			table.insert(list, m6d)
			p4.md = m6d
			m6d.Name = "Handle"
			m6d.Part0 = folder["Right Arm"]
			m6d.Part1 = clone.Handle
			m6d.Parent = folder["Right Arm"]
			clone.Parent = folder
		end,
		Dual = {
			DoBoth = false,
			NoRotate = 0,
			Attach = true,
			RotateCheck = true,
			Callback = function(parent, parent2, list, _, p4)
				if list.done then
					return
				end

				list.done = true
				local cfolder = shared.cfolder({
					Name = "RootAnchor"
				})
				cfolder.Parent = parent
				table.insert(list, cfolder)
				CollectionService2:AddTag(cfolder, "RemoveOnLeave" .. (instance or playerFromCharacter or parent).Name)
				local clone = script.TablePP:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				clone.Name = "Table"
				CollectionService2:AddTag(clone, "RemoveOnLeave" .. parent2.Name)
				local table2 = clone.Table
				table2:SetAttribute("EmoteProperty", true)
				table.insert(list, table2)
				p4.md = table2
				table2.Part0 = parent2.PrimaryPart
				table2.Part1 = clone
				table2.Parent = parent2.PrimaryPart
				CollectionService2:AddTag(table2, "RemoveOnLeave" .. parent2.Name)
				clone.Parent = parent2
				fn10({
					SoundId = "rbxassetid://1837226630",
					Parent = clone,
					Volume = 0.5
				}):Play()
				local clone2 = script.Ball:Clone()
				clone2:SetAttribute("EmoteProperty", true)
				table.insert(list, clone2)
				p4.Handle = clone2
				CollectionService2:AddTag(clone2, "RemoveOnLeave" .. parent2.Name)
				local ball = clone2.Ball
				ball:SetAttribute("EmoteProperty", true)
				table.insert(list, ball)
				p4.md = ball
				ball.Part0 = parent2.PrimaryPart
				ball.Part1 = clone2
				ball.Parent = parent2.PrimaryPart
				CollectionService2:AddTag(ball, "RemoveOnLeave" .. parent2.Name)
				clone2.Parent = parent2
				local connections = {}
				local parts = {}

				for _, folder2 in pairs({ parent }) do
					table.insert(connections, folder2.DescendantAdded:connect(function(part)
						if part:IsA("BasePart") then
							part.CollisionGroup = "nocol"
							table.insert(parts, part)
						end
					end))

					for _, part in pairs(folder2:GetDescendants()) do
						if not part:IsA("BasePart") then
							continue
						end

						part.CollisionGroup = "nocol"
						table.insert(parts, part)
					end
				end

				cfolder:GetPropertyChangedSignal("Parent"):Connect(function()
					if not cfolder.Parent then
						for _, connection in pairs(connections) do
							connection:Disconnect()
						end

						for _, v8 in pairs(parts) do
							v8.CollisionGroup = "playercol"
						end
					end
				end)
				CollectionService2:AddTag(cfolder, parent2.Name .. "barber")
				local AnimationPlayer = require(parent.CharacterHandler:WaitForChild("AnimationPlayer"))

				local function fn15(p5)
					return AnimationPlayer.playAnimation(parent:FindFirstChild("Humanoid"), p5)
				end

				local AnimationPlayer2 = require(parent2.CharacterHandler:WaitForChild("AnimationPlayer"))

				local function fn16(p5)
					return AnimationPlayer2.playAnimation(parent2:FindFirstChild("Humanoid"), p5)
				end

				local v8 = fn16(17108522793)
				local v9 = 1
				table.insert(list, v8:GetMarkerReachedSignal("clap"):Connect(function()
					shared.sfx({
						SoundId = ({
							"rbxassetid://17108510911",
							"rbxassetid://17108511010",
							"rbxassetid://17108511153"
						})[math.random(1, 3)],
						Volume = 0.75,
						Parent = clone2,
						RollOffMaxDistance = rollOffMaxDistance
					}):Play()
					v9 = math.clamp(v9 + 0.005, 1, 10)
					fn16(17108522793):AdjustSpeed(v9)
					fn15(17108399691):AdjustSpeed(v9)
				end))
				v8.Priority = Enum.AnimationPriority.Action4
				v8:AdjustWeight(1)
				v8:Play(0)
				table.insert(list, v8)
				fn16(17108345170):AdjustWeight(0.001)
				fn15(17108345170):AdjustWeight(0.001)
				local v10 = fn15(17108399691)
				v10.Priority = Enum.AnimationPriority.Action4
				v10:AdjustWeight(1)
				v10:Play(0)
				table.insert(list, v10)
				game.ReplicatedStorage.Replication:FireAllClients({
					Effect = "Smooth Grab",
					CanBypass = true,
					Hit = parent,
					StartOffset = parent.PrimaryPart.CFrame,
					From = parent2.PrimaryPart,
					Offset = CFrame.new(0, 0, -11.304),
					Anchor = cfolder
				})
			end
		},
		HideWeapon = true,
		Fix = true,
		Looped = true,
		Tag = "pingpong1",
		Animation = 17108345170,
		AnimationTwo = 17108399691,
		Stun = "Freeze"
	}
	v5["Duel Request"] = {
		Startup = function(_, _, _, _)
			if instance then
			end
		end,
		Sounds = {
			[0] = {
				SoundId = instance and "rbxassetid://17466175687" or "rbxassetid://17466175395",
				ParentTorso = true,
				Volume = 1.5
			}
		},
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		Dual = {
			DoBoth = false,
			NoRotate = 0,
			Freeze = false,
			Attach = true,
			CallOnAccept = true,
			RotateCheck = true,
			Callback = function(parent, instance2, list, _)
				if list.done then
					return
				end

				list.done = true
				local cfolder = shared.cfolder({
					Name = "RootAnchor"
				})
				cfolder.Parent = parent
				table.insert(list, cfolder)
				CollectionService2:AddTag(cfolder, "RemoveOnLeave" .. (instance or playerFromCharacter or parent).Name)
				local connections = {}
				local parts = {}

				for _, folder2 in pairs({ parent }) do
					table.insert(connections, folder2.DescendantAdded:connect(function(part)
						if part:IsA("BasePart") then
							part.CollisionGroup = "nocol"
							table.insert(parts, part)
						end
					end))

					for _, part in pairs(folder2:GetDescendants()) do
						if not part:IsA("BasePart") then
							continue
						end

						part.CollisionGroup = "nocol"
						table.insert(parts, part)
					end
				end

				cfolder:GetPropertyChangedSignal("Parent"):Connect(function()
					if not cfolder.Parent then
						for _, connection in pairs(connections) do
							connection:Disconnect()
						end

						for _, v8 in pairs(parts) do
							v8.CollisionGroup = "playercol"
						end
					end
				end)
				CollectionService2:AddTag(cfolder, instance2.Name .. "carry")
				local AnimationPlayer = require(parent.CharacterHandler:WaitForChild("AnimationPlayer"))
				local AnimationPlayer2 = require(instance2.CharacterHandler:WaitForChild("AnimationPlayer"))
				local v8 = (function(p4)
					return AnimationPlayer2.playAnimation(instance2:FindFirstChild("Humanoid"), p4)
				end)(17465453123)
				v8.Priority = Enum.AnimationPriority.Action4
				v8:AdjustWeight(1)
				v8:Play()
				table.insert(list, v8)
				task.delay(1.2, function()
					if v8.IsPlaying then
						shared.sfx({
							SoundId = "rbxassetid://17466175248",
							CFrame = CFrame.new((parent.PrimaryPart.Position + instance2.PrimaryPart.Position) / 2),
							Volume = 2
						}):Play()
					end
				end)
				local v9 = (function(p4)
					return AnimationPlayer.playAnimation(parent:FindFirstChild("Humanoid"), p4)
				end)(17465871318)
				v9.Priority = Enum.AnimationPriority.Action4
				v9:AdjustWeight(1)
				v9:Play()
				table.insert(list, v9)
				task.delay(2.833, function()
					local numberValue = Instance.new("NumberValue")
					numberValue.Value = 1
					table.insert(list, numberValue)
					table.insert(list, numberValue:GetPropertyChangedSignal("Value"):Connect(function()
						v8:AdjustSpeed(numberValue.Value)
						v9:AdjustSpeed(numberValue.Value)
					end))
					TweenService:Create(
						numberValue,
						TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Value = 0
						}
					):Play()
				end)
				game.ReplicatedStorage.Replication:FireAllClients({
					Effect = "Smooth Grab",
					CanBypass = true,
					Hit = parent,
					StartOffset = parent.PrimaryPart.CFrame,
					From = instance2.PrimaryPart,
					Offset = CFrame.new(0, 0, -4.5),
					Anchor = cfolder
				})
			end
		},
		HideWeapon = true,
		Fix = true,
		Looped = true,
		Tag = "duelreq",
		Animation = 17464923657,
		AnimationTwo = 17465871318,
		Stun = "Freeze"
	}
	v5.Swerve = {
		Startup = function(_, _, _, _)
			if instance then
			end
		end,
		Dual = {
			DoBoth = false,
			NoRotate = 0,
			Freeze = false,
			Attach = true,
			Distance = 3,
			RotateCheck = true,
			Callback = function(instance2, instance3, list, _)
				if list.done then
					return
				end

				list.done = true
				CollectionService2:AddTag(anchor, instance3.Name .. "carry")
				local AnimationPlayer = require(instance2.CharacterHandler:WaitForChild("AnimationPlayer"))

				local function fn15(p4)
					return AnimationPlayer.playAnimation(instance2:FindFirstChild("Humanoid"), p4)
				end

				local AnimationPlayer2 = require(instance3.CharacterHandler:WaitForChild("AnimationPlayer"))

				local function fn16(p4)
					return AnimationPlayer2.playAnimation(instance3:FindFirstChild("Humanoid"), p4)
				end

				local v8 = fn16(72439513503134)
				v8.Priority = Enum.AnimationPriority.Action4
				v8:AdjustWeight(1)
				v8:Play()
				table.insert(list, v8)
				fn15(83001379083977):AdjustWeight(0.01)
				fn16(83001379083977):AdjustWeight(0.01)
				table.insert(list, v8.Stopped:Once(function()
					fn16(83001379083977):Stop(0)
				end))
				local v9 = fn15(90129590700134)
				v9.Priority = Enum.AnimationPriority.Action4
				v9:AdjustWeight(1)
				v9:Play()
				table.insert(list, v9)
				fn10({
					SoundId = "rbxassetid://94760577993598",
					Parent = instance3.Torso,
					Volume = 1
				}):Play()
			end
		},
		HideWeapon = true,
		Fix = true,
		Looped = true,
		Tag = "swerveee",
		Animation = 83001379083977,
		AnimationTwo = 17096829509,
		Stun = "Freeze"
	}
	v5["Bizarre Duo"] = {
		Startup = function(_, _, _, _)
			if instance then
			end
		end,
		Dual = {
			DoBoth = false,
			NoRotate = 0,
			Freeze = false,
			Dist = CFrame.new(3.75712967, 0, 0.85508728),
			NoLook = true,
			Attach = true,
			RotateCheck = true,
			Callback = function(instance2, parent, list, _, _, p4)
				if list.done then
					return
				end

				list.done = true
				local AnimationPlayer = require(instance2.CharacterHandler:WaitForChild("AnimationPlayer"))

				local function fn15(p5)
					return AnimationPlayer.playAnimation(instance2:FindFirstChild("Humanoid"), p5)
				end

				local AnimationPlayer2 = require(parent.CharacterHandler:WaitForChild("AnimationPlayer"))

				local function fn16(p5)
					return AnimationPlayer2.playAnimation(parent:FindFirstChild("Humanoid"), p5)
				end

				local v8 = fn16(114351492594331)
				v8.Priority = Enum.AnimationPriority.Action4
				v8:AdjustWeight(1)
				v8:Play()
				table.insert(list, v8)
				fn15(109864108341281):AdjustWeight(0.01)
				fn16(109864108341281):AdjustWeight(0.01)
				table.insert(list, v8.Stopped:Once(function()
					local v9 = fn16(114307604981653)
					table.insert(list, v9)
					v9:Play()
					local v10 = fn15(119026456567237)
					table.insert(list, v10)
					v10:Play()
				end))
				local v9 = fn15(136739918287439)
				v9.Priority = Enum.AnimationPriority.Action4
				v9:AdjustWeight(1)
				v9:Play()
				table.insert(list, v9)
				task.delay(0.917, function()
					if p4.interrupted then
						return
					end

					local attachment = Instance.new("Attachment")
					attachment:SetAttribute("EmoteProperty", true)
					table.insert(list, attachment)
					attachment.Parent = parent["Right Arm"]
					attachment.Position = createVector(0.5, -1, -0)

					for _, child in pairs(script.FistTouch:GetChildren()) do
						local clone = child:Clone()
						clone.Parent = attachment
					end

					for _, child in pairs(attachment:GetChildren()) do
						child:Emit(child:GetAttribute("EmitCount"))
					end
				end)
				task.delay(1.667, function()
					if p4.interrupted then
						return
					end

					local clone = script.Menacing:Clone()
					clone:SetAttribute("EmoteProperty", true)
					table.insert(list, clone)
					local weld = Instance.new("Weld")
					weld.Part0 = parent.PrimaryPart
					weld.Part1 = clone
					weld.C0 = CFrame.new(1.75713348, 0.5, 1.35508728)
					weld.Parent = clone
					clone.Parent = parent

					for _, emitter in pairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end
				end)
				local attachment = Instance.new("Attachment")
				attachment:SetAttribute("EmoteProperty", true)
				table.insert(list, attachment)
				attachment.Parent = parent.PrimaryPart
				attachment.Position = createVector(2.325, 0, 0.209)
				fn10({
					SoundId = "rbxassetid://76338639500620",
					Parent = attachment,
					Volume = 0.5
				}):Play()
			end
		},
		HideWeapon = true,
		Fix = true,
		Looped = true,
		Tag = "dance1",
		Animation = 109864108341281,
		AnimationTwo = 1,
		Stun = "Freeze"
	}
	v5.Dance = {
		Startup = function(_, _, _, _)
			if instance then
			end
		end,
		Dual = {
			DoBoth = false,
			NoRotate = 0,
			Freeze = false,
			Attach = true,
			RotateCheck = true,
			Callback = function(parent, instance2, list, _)
				if list.done then
					return
				end

				list.done = true
				local cfolder = shared.cfolder({
					Name = "RootAnchor"
				})
				cfolder.Parent = parent
				table.insert(list, cfolder)
				CollectionService2:AddTag(cfolder, "RemoveOnLeave" .. (instance or playerFromCharacter or parent).Name)
				local connections = {}
				local parts = {}

				for _, folder2 in pairs({ parent }) do
					table.insert(connections, folder2.DescendantAdded:connect(function(part)
						if part:IsA("BasePart") then
							part.CollisionGroup = "nocol"
							table.insert(parts, part)
						end
					end))

					for _, part in pairs(folder2:GetDescendants()) do
						if not part:IsA("BasePart") then
							continue
						end

						part.CollisionGroup = "nocol"
						table.insert(parts, part)
					end
				end

				cfolder:GetPropertyChangedSignal("Parent"):Connect(function()
					if not cfolder.Parent then
						for _, connection in pairs(connections) do
							connection:Disconnect()
						end

						for _, v8 in pairs(parts) do
							v8.CollisionGroup = "playercol"
						end
					end
				end)
				CollectionService2:AddTag(cfolder, instance2.Name .. "carry")
				fn10({
					SoundId = "rbxassetid://17096532969",
					Parent = instance2.PrimaryPart,
					Looped = true,
					Volume = 0.5
				}):Play()
				local AnimationPlayer = require(parent.CharacterHandler:WaitForChild("AnimationPlayer"))

				local function fn15(p4)
					return AnimationPlayer.playAnimation(parent:FindFirstChild("Humanoid"), p4)
				end

				local AnimationPlayer2 = require(instance2.CharacterHandler:WaitForChild("AnimationPlayer"))

				local function fn16(p4)
					return AnimationPlayer2.playAnimation(instance2:FindFirstChild("Humanoid"), p4)
				end

				local v8 = fn16(17096828632)
				v8.Priority = Enum.AnimationPriority.Action4
				v8:AdjustWeight(1)
				v8:Play()
				table.insert(list, v8)
				fn15(17096821069):AdjustWeight(0.01)
				fn16(17096821069):AdjustWeight(0.01)
				table.insert(list, v8.Stopped:Once(function()
					fn16(17096821069):Stop(0)
				end))
				local v9 = fn15(17096829509)
				v9.Priority = Enum.AnimationPriority.Action4
				v9:AdjustWeight(1)
				v9:Play()
				table.insert(list, v9)
				fn10({
					SoundId = "rbxassetid://17096893930",
					Parent = instance2.Torso,
					Volume = 1
				}):Play()
				game.ReplicatedStorage.Replication:FireAllClients({
					Effect = "Smooth Grab",
					CanBypass = true,
					Hit = parent,
					StartOffset = parent.PrimaryPart.CFrame,
					From = instance2.PrimaryPart,
					Offset = CFrame.new(0, 0, -3),
					Anchor = cfolder
				})
			end
		},
		HideWeapon = true,
		Fix = true,
		Looped = true,
		Tag = "dance1",
		Animation = 17096821069,
		AnimationTwo = 17096829509,
		Stun = "Freeze"
	}
	v5.Drag = {
		Startup = function(list, _, p4, _)
			if instance then
				return
			end

			local cfolder = shared.cfolder({
				Name = "Freeze"
			})

			if not p4.stun then
				p4.stun = {}
			end

			table.insert(p4.stun, cfolder)
			table.insert(list, cfolder)
			cfolder:SetAttribute("DontInterrupt", true)
			cfolder:SetAttribute("NoStop", true)
			cfolder:SetAttribute("EmoteProperty", true)
			CollectionService2:AddTag(cfolder, "Startupstun" .. folder.Name)
			task.delay(0, function()
				cfolder.Parent = folder
			end)
		end,
		Dual = {
			DoBoth = false,
			NoRotate = 0,
			CanRotate = 0,
			Attach = true,
			Dead = true,
			RotateCheck = true,
			Callback = function(parent, instance2, list, _, _)
				task.delay(0.03, function()
					for _, v8 in pairs(CollectionService2:GetTagged("Startupstun" .. instance2.Name)) do
						local Debris = game:GetService("Debris")
						Debris:AddItem(v8, 0)
					end
				end)

				if list.done then
					return
				end

				list.done = true
				local cfolder = shared.cfolder({
					Name = "RootAnchor"
				})
				cfolder.Parent = parent
				table.insert(list, cfolder)
				CollectionService2:AddTag(cfolder, "RemoveOnLeave" .. (instance or playerFromCharacter or parent).Name)
				local connections = {}
				local parts = {}

				for _, folder2 in pairs({ parent }) do
					table.insert(connections, folder2.DescendantAdded:connect(function(part)
						if part:IsA("BasePart") then
							part.CollisionGroup = "nocol"
							table.insert(parts, part)
						end
					end))

					for _, part in pairs(folder2:GetDescendants()) do
						if not part:IsA("BasePart") then
							continue
						end

						part.CollisionGroup = "nocol"
						table.insert(parts, part)
					end
				end

				cfolder:GetPropertyChangedSignal("Parent"):Connect(function()
					if not cfolder.Parent then
						for _, connection in pairs(connections) do
							connection:Disconnect()
						end

						for _, v8 in pairs(parts) do
							v8.CollisionGroup = "playercol"
						end
					end
				end)
				CollectionService2:AddTag(cfolder, instance2.Name .. "carry")
				local v8 = fn10({
					SoundId = "rbxassetid://17120622268",
					Parent = parent.Torso,
					Looped = true,
					Volume = 0.2
				})
				v8:Play()
				CollectionService2:AddTag(v8, "RemoveOnLeave" .. parent.Name)
				CollectionService2:AddTag(v8, "RemoveOnLeave" .. instance2.Name)
				local AnimationPlayer = require(parent.CharacterHandler:WaitForChild("AnimationPlayer"))
				local v9 = (function(p4)
					return AnimationPlayer.playAnimation(parent:FindFirstChild("Humanoid"), p4)
				end)(17120643504)
				v9.Priority = Enum.AnimationPriority.Action4
				v9:AdjustWeight(1)
				v9:Play()
				table.insert(list, v9)
				game.ReplicatedStorage.Replication:FireAllClients({
					Effect = "Smooth Grab",
					CanBypass = true,
					Hit = parent,
					NoLook = true,
					From = instance2.PrimaryPart,
					Offset = CFrame.new(-0.5, 0, -0.025),
					Anchor = cfolder
				})
			end
		},
		Keyframes = {
			clap = function()
				if not instance then
					return
				end

				fn10({
					SoundId = "rbxassetid://" .. ({ 7455224144, 7455246815, 7455224490 })[math.random(1, 3)],
					Parent = instance["Left Leg"],
					PlaybackSpeed = 1,
					Volume = 0.6,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end
		},
		HideWeapon = true,
		Fix = true,
		Tag = "drag1",
		Animation = 17120635926,
		AnimationTwo = 17120643504,
		Infinite = true,
		Looped = true,
		Stun = "Slowed",
		StunAttribute = 1.5
	}
	v5.Carry = {
		Startup = function(list, _, p4, _)
			if instance then
				return
			end

			local cfolder = shared.cfolder({
				Name = "Freeze"
			})

			if not p4.stun then
				p4.stun = {}
			end

			table.insert(p4.stun, cfolder)
			table.insert(list, cfolder)
			cfolder:SetAttribute("DontInterrupt", true)
			cfolder:SetAttribute("NoStop", true)
			cfolder:SetAttribute("EmoteProperty", true)
			CollectionService2:AddTag(cfolder, "Startupstun" .. folder.Name)
			print(folder)
			task.delay(0, function()
				cfolder.Parent = folder
			end)
		end,
		Dual = {
			DoBoth = false,
			NoRotate = 0,
			CanRotate = 0,
			Attach = true,
			Dead = true,
			RotateCheck = true,
			Callback = function(parent, instance2, list, _, _)
				task.delay(0.03, function()
					for _, v8 in pairs(CollectionService2:GetTagged("Startupstun" .. instance2.Name)) do
						local Debris = game:GetService("Debris")
						Debris:AddItem(v8, 0)
					end
				end)

				if list.done then
					return
				end

				list.done = true
				local cfolder = shared.cfolder({
					Name = "RootAnchor"
				})
				cfolder.Parent = parent
				table.insert(list, cfolder)
				CollectionService2:AddTag(cfolder, "RemoveOnLeave" .. (instance or playerFromCharacter or parent).Name)
				local connections = {}
				local parts = {}

				for _, folder2 in pairs({ parent }) do
					table.insert(connections, folder2.DescendantAdded:connect(function(part)
						if part:IsA("BasePart") then
							part.CollisionGroup = "nocol"
							table.insert(parts, part)
						end
					end))

					for _, part in pairs(folder2:GetDescendants()) do
						if not part:IsA("BasePart") then
							continue
						end

						part.CollisionGroup = "nocol"
						table.insert(parts, part)
					end
				end

				cfolder:GetPropertyChangedSignal("Parent"):Connect(function()
					if not cfolder.Parent then
						for _, connection in pairs(connections) do
							connection:Disconnect()
						end

						for _, v8 in pairs(parts) do
							v8.CollisionGroup = "playercol"
						end
					end
				end)
				CollectionService2:AddTag(cfolder, instance2.Name .. "carry")
				fn10({
					SoundId = "rbxassetid://17096532969",
					Parent = instance2.PrimaryPart,
					Looped = true,
					Volume = 0.5
				}):Play()
				local AnimationPlayer = require(parent.CharacterHandler:WaitForChild("AnimationPlayer"))
				local v8 = (function(p4)
					return AnimationPlayer.playAnimation(parent:FindFirstChild("Humanoid"), p4)
				end)(17096487990)
				v8.Priority = Enum.AnimationPriority.Action4
				v8:AdjustWeight(1)
				v8:Play()
				table.insert(list, v8)
				game.ReplicatedStorage.Replication:FireAllClients({
					Effect = "Smooth Grab",
					CanBypass = true,
					Hit = parent,
					From = instance2.PrimaryPart,
					Offset = CFrame.new(0, 0, -3),
					Anchor = cfolder
				})
			end
		},
		Keyframes = {},
		HideWeapon = true,
		Fix = true,
		Tag = "carry1",
		Animation = 17096486393,
		AnimationTwo = 17096487990,
		Infinite = true,
		Looped = true,
		Stun = "Slowed",
		StunAttribute = 1.5
	}
	v5["Cart Ride"] = {
		Startup = function(list, _, p4, _)
			if instance then
				return
			end

			local clone = script.cart:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local cart = clone.cart
			cart:SetAttribute("EmoteProperty", true)
			table.insert(list, cart)
			p4.md = cart
			clone.Name = "cart"
			cart.Part0 = folder.PrimaryPart
			cart.Part1 = clone
			cart.Parent = folder.PrimaryPart
			clone.Parent = folder
			shared.sfx({
				SoundId = "rbxassetid://15989599068",
				Parent = clone,
				Looped = true,
				Volume = 0.5,
				RollOffMaxDistance = rollOffMaxDistance
			}):Play()
			local forceField = folder:FindFirstChildOfClass("ForceField")
			local v8 = (workspace:GetAttribute("GameStarted") or not workspace:GetAttribute("RankedOnes")) and true or false

			if forceField and forceField:GetAttribute("Emote") then
				v8 = false
			end

			if v8 then
				p4.first = 0
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity:SetAttribute("EmoteProperty", true)
				table.insert(list, bodyVelocity)
				p4.BV = bodyVelocity
				bodyVelocity.Name = "moveme"
				bodyVelocity.MaxForce = createVector(40000, 0, 40000)
				bodyVelocity:SetAttribute("Speed", 6)
				bodyVelocity:SetAttribute("Goto", 6)
				bodyVelocity:SetAttribute("RayCheck", true)
				bodyVelocity:SetAttribute("End", 1)
				bodyVelocity:SetAttribute("Fallout", 0.995)
				bodyVelocity.Parent = folder.PrimaryPart
			end
		end,
		Dual = {
			DoBoth = false,
			NoRotate = 0,
			Freeze = false,
			Attach = true,
			RotateCheck = true,
			Callback = function(parent, instance2, list, _)
				if list.done then
					return
				end

				list.done = true
				local cfolder = shared.cfolder({
					Name = "RootAnchor"
				})
				cfolder.Parent = parent
				table.insert(list, cfolder)
				CollectionService2:AddTag(cfolder, "RemoveOnLeave" .. (instance or playerFromCharacter or parent).Name)
				local connections = {}
				local parts = {}

				for _, folder2 in pairs({ parent }) do
					table.insert(connections, folder2.DescendantAdded:connect(function(part)
						if part:IsA("BasePart") then
							part.CollisionGroup = "nocol"
							table.insert(parts, part)
						end
					end))

					for _, part in pairs(folder2:GetDescendants()) do
						if not part:IsA("BasePart") then
							continue
						end

						part.CollisionGroup = "nocol"
						table.insert(parts, part)
					end
				end

				cfolder:GetPropertyChangedSignal("Parent"):Connect(function()
					if not cfolder.Parent then
						for _, connection in pairs(connections) do
							connection:Disconnect()
						end

						for _, v8 in pairs(parts) do
							v8.CollisionGroup = "playercol"
						end
					end
				end)
				CollectionService2:AddTag(cfolder, instance2.Name .. "cartride")
				local AnimationPlayer = require(parent.CharacterHandler:WaitForChild("AnimationPlayer"))

				local function fn15(p4)
					return AnimationPlayer.playAnimation(parent:FindFirstChild("Humanoid"), p4)
				end

				local v8 = fn15(15685170827)
				v8.Priority = Enum.AnimationPriority.Core
				v8:AdjustWeight(0.001)
				table.insert(list, v8)
				local v9 = fn15(15685307415)
				v9.Priority = Enum.AnimationPriority.Action4
				v9:AdjustWeight(1)
				v9:Play()
				table.insert(list, v9)
				game.ReplicatedStorage.Replication:FireAllClients({
					Effect = "Smooth Grab",
					CanBypass = true,
					Hit = parent,
					From = instance2.PrimaryPart,
					NoLook = true,
					Offset = CFrame.new(0, 0, 0),
					Anchor = cfolder
				})
			end
		},
		Keyframes = {
			clap = function(state)
				if instance then
					return
				end

				fn10({
					SoundId = "rbxassetid://15685183097",
					Parent = folder.Torso,
					Volume = 1
				}):Play()

				if state.first == 0 then
					state.first += 1
					return
				end

				local tagged = CollectionService2:GetTagged(folder.Name .. "cartride")

				if #tagged > 0 then
					fn10({
						SoundId = "rbxassetid://15685183294",
						Parent = tagged[1].Parent.Torso,
						Volume = 1
					}):Play()
				end

				if state.BV and state.BV.Parent then
					local BV = state.BV
					BV:SetAttribute("Goto", 12)
					local v10 = -0.01
					local v11 = 0.01

					if not v11 and v10 then
						v11 = v10
						v10 = 1
					end

					if not (v11 or v10) then
						v10 = 0
						v11 = 1
					end

					BV:SetAttribute("Speed", 45 + random:NextNumber(v10, v11))
				end
			end
		},
		HideWeapon = true,
		Tag = "cartride",
		Animation = 15685170827,
		AnimationTwo = 15685307415,
		Infinite = true,
		Looped = true,
		Stun = "Freeze"
	}
	v5["Pretty Please"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1839643165",
				Volume = 0.3
			}
		},
		Startup = function(list, p4, _, _, p5)
			local clones = {}

			for i = 1, 2 do
				local v8 = i == 2 and -1 or 1
				local attachment = Instance.new("Attachment")
				table.insert(list, attachment)
				attachment:SetAttribute("EmoteProperty", true)
				local clone = script.eye:Clone()
				clone.Parent = attachment
				attachment.Parent = folder.Head
				clone.Enabled = true
				attachment.Position = Vector3.new(v8 * 0.23, 0.164, -0.75)
				table.insert(clones, clone)
			end

			task.spawn(function()
				Random.new()

				while wait(0.06) and p4.IsPlaying and not p5.interrupted do
					for _, v8 in pairs(clones) do
						if not v8.Parent then
							break
						end

						local v9 = -0.01
						local v10 = 0.01

						if not v10 and v9 then
							v10 = v9
							v9 = 1
						end

						if not (v10 or v9) then
							v9 = 0
							v10 = 1
						end

						local number = random:NextNumber(v9, v10)
						local v11 = -0.01
						local v12 = 0.01

						if not v12 and v11 then
							v12 = v11
							v11 = 1
						end

						if not (v12 or v11) then
							v11 = 0
							v12 = 1
						end

						v8.StudsOffset = Vector3.new(number, random:NextNumber(v11, v12), fn12(-0.01, 0.01)) / 2
					end
				end
			end)
		end,
		Animation = 16584277208,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Face Grab"] = {
		Startup = function() end,
		Dual = {
			DoBoth = false,
			Dist = 1.85,
			Attach = true,
			NoRotate = 1e999,
			RotateCheck = true,
			Callback = function(instance2, instance3, list, _)
				local v8, _ = fn10({
					SoundId = "rbxassetid://18829223347",
					Parent = instance2.Head,
					Looped = false,
					Volume = 1.5
				})
				v8:Play()
				local AnimationPlayer = require(instance2.CharacterHandler:WaitForChild("AnimationPlayer"))
				local AnimationPlayer2 = require(instance3.CharacterHandler:WaitForChild("AnimationPlayer"))
				local v9 = (function(p4)
					return AnimationPlayer2.playAnimation(instance3:FindFirstChild("Humanoid"), p4)
				end)(18897624255)
				local v10 = (function(p4)
					return AnimationPlayer.playAnimation(instance2:FindFirstChild("Humanoid"), p4)
				end)(18897625847)
				v10.Priority = Enum.AnimationPriority.Action4
				v10.Looped = true
				v10:AdjustWeight(1)
				v10:Play()
				table.insert(list, v10)
				task.spawn(function()
					local lastTime = tick()

					repeat
						task.wait()
					until tick() - lastTime > 4.117 or not v10.IsPlaying

					if not v10.IsPlaying then
						return
					end

					for _, v12 in pairs({ v9, v10 }) do
						if v12.IsPlaying then
							v12:AdjustSpeed(0)
						end
					end
				end)
			end
		},
		Tag = "grabface",
		HideWeapon = true,
		Animation = 18897624255,
		AnimationFixes = { 18897624255, 18897625847 },
		Looped = true,
		Stun = "Freeze"
	}
	v5.Picnic = {
		Startup = function(list, _, p4, _)
			if instance then
				local clone = script.Sandwich:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local sandwich = clone.Sandwich
				sandwich:SetAttribute("EmoteProperty", true)
				table.insert(list, sandwich)
				p4.md = sandwich
				sandwich.Part0 = folder["Right Arm"]
				sandwich.Part1 = clone
				sandwich.Parent = folder["Right Arm"]
				clone.Parent = folder
			else
				local clone = script.Blanket:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local blanket = clone.Blanket
				blanket:SetAttribute("EmoteProperty", true)
				table.insert(list, blanket)
				p4.md = blanket
				blanket.Part0 = folder.PrimaryPart
				blanket.Part1 = clone
				blanket.Parent = folder.PrimaryPart
				clone.Parent = folder
				fn10({
					SoundId = "rbxassetid://1841681029",
					Parent = clone,
					Looped = true,
					Volume = 0.5
				}):Play()
				fn10({
					SoundId = "rbxassetid://83896975323570",
					Parent = folder.Torso,
					Looped = false,
					Volume = 0.75
				}):Play()
				local clone2 = script.Picnick:Clone()
				clone2:SetAttribute("EmoteProperty", true)
				table.insert(list, clone2)
				p4.Handle = clone2
				clone2.Name = "Model"
				local base = clone2.Base
				base:SetAttribute("EmoteProperty", true)
				table.insert(list, base)
				p4.md = base
				base.Part0 = folder["Right Arm"]
				base.Part1 = clone2.PicnicBasket.Base
				base.Parent = folder["Right Arm"]
				clone2.Parent = folder
			end
		end,
		Dual = {
			DoBoth = false,
			Dist = CFrame.new(0, 0, -5),
			Attach = true,
			Freeze = false,
			NoRotate = 1e999,
			RotateCheck = true,
			Callback = function(instance2, instance3, list, _)
				local AnimationPlayer = require(instance2.CharacterHandler:WaitForChild("AnimationPlayer"))

				local function fn15(p4)
					return AnimationPlayer.playAnimation(instance2:FindFirstChild("Humanoid"), p4)
				end

				local AnimationPlayer2 = require(instance3.CharacterHandler:WaitForChild("AnimationPlayer"))

				local function fn16(p4)
					return AnimationPlayer2.playAnimation(instance3:FindFirstChild("Humanoid"), p4)
				end

				fn16(139619595225529):AdjustWeight(0.001)
				fn10({
					SoundId = "rbxassetid://120033833303346",
					Parent = instance3["Right Arm"],
					Volume = 1
				}):Play()
				local v8 = fn16(114257381413858)
				v8.Priority = Enum.AnimationPriority.Action4
				v8:AdjustWeight(1)
				v8:Play()
				table.insert(list, v8.Stopped:Once(function()
					local v9 = fn16(114413870666811)
					table.insert(list, v9)
					v9.Priority = Enum.AnimationPriority.Action4
					v9.Looped = true
					v9:AdjustWeight(1)
					table.insert(list, v9:GetMarkerReachedSignal("clap"):Connect(function()
						fn10({
							SoundId = "rbxassetid://109123564480693",
							Parent = instance3["Right Arm"],
							Volume = 1
						}):Play()
					end))
					v9:Play()
				end))
				table.insert(list, v8)
				fn10({
					SoundId = "rbxassetid://111931707991797",
					Parent = instance2["Right Arm"],
					Volume = 1
				}):Play()
				local v9 = fn15(111355299827059)
				v9.Priority = Enum.AnimationPriority.Action4
				v9:AdjustWeight(1)
				v9:Play()
				table.insert(list, v9.Stopped:Once(function()
					local v10 = fn15(72956068899498)
					table.insert(list, v10)
					v10.Priority = Enum.AnimationPriority.Action4
					v10.Looped = true
					table.insert(list, v10:GetMarkerReachedSignal("clap"):Connect(function()
						fn10({
							SoundId = "rbxassetid://101684470526234",
							Parent = instance2["Right Arm"],
							Volume = 1
						}):Play()
					end))
					v10:AdjustWeight(1)
					v10:Play()
				end))
				table.insert(list, v9)
			end
		},
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		Tag = "paint",
		HideWeapon = true,
		Fix = true,
		Animation = 140367976090553,
		AnimationFixes = { 18897684855, 18897682478, 18897686619 },
		Looped = true,
		Stun = "Freeze"
	}
	v5.Masterpiece = {
		Startup = function(list, _, p4, _)
			if instance then
				local clone = script.Frame:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local m6d = clone.m6d
				m6d:SetAttribute("EmoteProperty", true)
				table.insert(list, m6d)
				p4.md = m6d
				m6d.Part0 = folder.PrimaryPart
				m6d.Part1 = clone
				m6d.Name = "Frame"
				m6d.Parent = folder.PrimaryPart
				clone.Parent = folder
			else
				fn10({
					SoundId = "rbxassetid://1840161104",
					Parent = folder.PrimaryPart,
					Looped = true,
					Volume = 0.4
				}):Play()
				local clone = script.brush:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				local brush = clone.brush
				brush:SetAttribute("EmoteProperty", true)
				table.insert(list, brush)
				p4.md = brush
				brush.Part0 = folder.PrimaryPart
				brush.Part1 = clone
				brush.Parent = folder.PrimaryPart
				clone.Parent = folder
				fn10({
					SoundId = "rbxassetid://18835321626",
					Parent = clone,
					Volume = 1.5
				}):Play()
				local clone2 = script.palette:Clone()
				clone2:SetAttribute("EmoteProperty", true)
				table.insert(list, clone2)
				p4.Handle = clone2
				local palette = clone2.palette
				palette:SetAttribute("EmoteProperty", true)
				table.insert(list, palette)
				p4.md = palette
				palette.Part0 = folder.PrimaryPart
				palette.Part1 = clone2
				palette.Parent = folder.PrimaryPart
				clone2.Parent = folder
			end
		end,
		Dual = {
			DoBoth = false,
			NoLook = true,
			Dist = CFrame.new(4, 0, 0),
			Attach = true,
			Freeze = false,
			NoRotate = 1e999,
			RotateCheck = true,
			Callback = function(instance2, instance3, list, _)
				local v8, _ = fn10({
					SoundId = "rbxassetid://18835337426",
					Parent = instance3["Right Arm"],
					Looped = true,
					Volume = 1.5
				})
				v8:Play()
				local AnimationPlayer = require(instance2.CharacterHandler:WaitForChild("AnimationPlayer"))
				local AnimationPlayer2 = require(instance3.CharacterHandler:WaitForChild("AnimationPlayer"))
				local v9 = (function(p4)
					return AnimationPlayer2.playAnimation(instance3:FindFirstChild("Humanoid"), p4)
				end)(18897682478)
				v9.Priority = Enum.AnimationPriority.Action4
				v9.Looped = true
				v9:AdjustWeight(1)
				v9:Play()
				table.insert(list, v9)
				local v10 = (function(p4)
					return AnimationPlayer.playAnimation(instance2:FindFirstChild("Humanoid"), p4)
				end)(18897686619)
				v10.Priority = Enum.AnimationPriority.Action4
				v10.Looped = true
				v10:AdjustWeight(1)
				v10:Play()
				table.insert(list, v10)
			end
		},
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		Tag = "paint",
		HideWeapon = true,
		Fix = true,
		Animation = 18897684855,
		AnimationFixes = { 18897684855, 18897682478, 18897686619 },
		Looped = true,
		Stun = "Freeze"
	}
	v5["Think!!!"] = {
		Startup = function(_, _, _)
			if instance then
			end
		end,
		Sounds = {},
		Keyframes = {},
		Dual = {
			DoBoth = false,
			Dist = -0.01,
			Attach = true,
			NoRotate = 3.417,
			Callback = function(instance2, p4, list, _, _)
				local AnimationPlayer = require(instance2.CharacterHandler:WaitForChild("AnimationPlayer"))
				require(p4.CharacterHandler:WaitForChild("AnimationPlayer"))
				fn10({
					SoundId = "rbxassetid://18836260464",
					Parent = p4.Torso,
					Volume = 1
				}):Play()
				local v8 = (function(p5)
					return AnimationPlayer.playAnimation(instance2:FindFirstChild("Humanoid"), p5)
				end)(18897721681)
				v8.Priority = Enum.AnimationPriority.Action4
				v8:AdjustWeight(1)
				v8:Play()
				table.insert(list, v8)
			end
		},
		Tag = "thnk",
		Animation = 18897718868,
		Fix = true,
		AnimationFixes = { 18897718868, 18897721681 },
		Looped = false,
		Stun = "Freeze"
	}
	v5["Carry 2"] = {
		Startup = function(list, _, p4)
			if instance then
				return
			end

			local cfolder = shared.cfolder({
				Name = "Freeze"
			}, 3.922)
			table.insert(list, cfolder)
			CollectionService2:AddTag(cfolder, "blah" .. (instance or playerFromCharacter or folder).Name)
			cfolder:SetAttribute("DontInterrupt", true)
			cfolder:SetAttribute("NoStop", true)
			cfolder:SetAttribute("EmoteProperty", true)
			task.delay(0, function()
				cfolder.Parent = folder
			end)
			p4.frz = cfolder
		end,
		Sounds = {},
		Keyframes = {},
		Dual = {
			DoBoth = false,
			Dist = 3.179,
			Attach = true,
			CanRotate = true,
			RotateCheck = true,
			Callback = function(instance2, instance3, list, _, _)
				local AnimationPlayer = require(instance2.CharacterHandler:WaitForChild("AnimationPlayer"))

				local function fn15(p4)
					return AnimationPlayer.playAnimation(instance2:FindFirstChild("Humanoid"), p4)
				end

				local AnimationPlayer2 = require(instance3.CharacterHandler:WaitForChild("AnimationPlayer"))

				local function fn16(p4)
					return AnimationPlayer2.playAnimation(instance3:FindFirstChild("Humanoid"), p4)
				end

				local v8 = fn15(18897899497)
				v8.Priority = Enum.AnimationPriority.Action4
				v8:AdjustWeight(1)
				v8:Play()
				local v9 = fn10({
					SoundId = "rbxassetid://18846119968",
					Parent = instance2.Torso,
					Volume = 1
				})
				v9:SetAttribute("EmoteProperty", true)
				v9:Play()
				table.insert(list, v9)
				table.insert(list, v8)
				table.insert(list, v8.Stopped:Once(function()
					local v10 = fn16(18897885015)
					v10.Priority = Enum.AnimationPriority.Action4
					v10.Looped = true
					v10:AdjustWeight(1)
					v10:Play()
					table.insert(list, v10)
					local v11 = fn15(18897893429)
					v11.Priority = Enum.AnimationPriority.Action4
					v11.Looped = true
					v11:AdjustWeight(1)
					v11:Play()
					table.insert(list, v11)

					for _, v12 in pairs(CollectionService2:GetTagged("blah" .. (instance or playerFromCharacter or instance2).Name)) do
						v12:Destroy()
					end

					local v12 = fn10({
						SoundId = "rbxassetid://18846302530",
						Parent = instance3.Torso,
						Looped = true,
						Volume = 0.25
					})
					v12:SetAttribute("EmoteProperty", true)
					v12:Play()
					table.insert(list, v12)
				end))
				local v10 = fn16(18897896476)
				v10.Priority = Enum.AnimationPriority.Action4
				v10:AdjustWeight(1)
				v10:Play()
				table.insert(list, v10)
			end
		},
		Tag = "backcarry",
		Animation = 18897896476,
		AnimationFixes = {
			18897896476,
			18897899497,
			18897893429,
			18897885015
		},
		Looped = true,
		Stun = "Slowed",
		StunAttribute = 1
	}
	v5.Piggyback = {
		Startup = function()
			if instance then
				return
			end

			fn10({
				SoundId = "rbxassetid://18835998166",
				Volume = 1,
				Looped = true,
				Parent = folder["Left Leg"]
			}):Play()
		end,
		Sounds = {},
		Keyframes = {},
		Dual = {
			DoBoth = false,
			Dist = -0.01,
			Freeze = false,
			Attach = true,
			CanRotate = true,
			RotateCheck = true,
			Callback = function(instance2, p4, list, _)
				local AnimationPlayer = require(instance2.CharacterHandler:WaitForChild("AnimationPlayer"))
				require(p4.CharacterHandler:WaitForChild("AnimationPlayer"))
				local v8 = (function(p5)
					return AnimationPlayer.playAnimation(instance2:FindFirstChild("Humanoid"), p5)
				end)(18897690248)
				v8.Priority = Enum.AnimationPriority.Action4
				v8.Looped = true
				v8:AdjustWeight(1)
				v8:Play()
				table.insert(list, v8)
			end
		},
		Tag = "piggyback",
		Animation = 18897692607,
		AnimationFixes = { 18897692607, 18897690248 },
		Looped = true,
		Stun = "Slowed",
		StunAttribute = 1
	}
	v5.Lalala = {
		Startup = function() end,
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://17097669113",
				Volume = 1
			}
		},
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		Dual = {
			DoBoth = false,
			Dist = 3.8,
			Freeze = false,
			Attach = true,
			NoRotate = 1e999,
			RotateCheck = true,
			Callback = function(instance2, instance3, list, _)
				local v8, _ = fn10({
					SoundId = "rbxassetid://18828726970",
					Looped = true,
					Volume = 1
				})
				v8.Parent = instance2.PrimaryPart
				v8:Play()
				local v9, _ = fn10({
					SoundId = "rbxassetid://9038380332",
					Looped = true,
					Volume = 0.2
				})
				v9.Parent = instance2.PrimaryPart
				v9:Play()
				local AnimationPlayer = require(instance2.CharacterHandler:WaitForChild("AnimationPlayer"))
				local AnimationPlayer2 = require(instance3.CharacterHandler:WaitForChild("AnimationPlayer"))
				local v10 = (function(p4)
					return AnimationPlayer2.playAnimation(instance3:FindFirstChild("Humanoid"), p4)
				end)(18897652035)
				v10.Priority = Enum.AnimationPriority.Action4
				v10.Looped = true
				v10:AdjustWeight(1)
				v10:Play()
				table.insert(list, v10)
				local v11 = (function(p4)
					return AnimationPlayer.playAnimation(instance2:FindFirstChild("Humanoid"), p4)
				end)(18897657904)
				v11.Priority = Enum.AnimationPriority.Action4
				v11.Looped = true
				v11:AdjustWeight(1)
				v11:Play()
				table.insert(list, v11)
				task.spawn(function()
					local total = 1

					repeat
						task.wait(0.5)
						total += 0.0071428571428571435
						v8.PlaybackSpeed = total
						v11:AdjustSpeed(total)
						v10:AdjustSpeed(total)
					until not (v11.IsPlaying and v10.IsPlaying)
				end)
			end
		},
		Tag = "lalala",
		Animation = 18897655615,
		AnimationFixes = { 18897652035, 18897657904 },
		Looped = true,
		Stun = "Freeze"
	}
	v5["Moonlight Blade"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://131885679205734",
				Volume = 1.25
			},
			[6] = {
				SoundId = "rbxassetid://128405033807309",
				Volume = 1.25,
				Looped = true
			},
			[1] = {
				SoundId = "rbxassetid://120830407661030",
				Volume = 0.5,
				Looped = true
			}
		},
		Startup = function(list, _, _)
			local clone = script.clonedsword:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			local handleM = clone.HandleM
			handleM:SetAttribute("EmoteProperty", true)
			table.insert(list, handleM)
			CollectionService2:AddTag(handleM, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
			handleM.Part0 = folder["Right Arm"]
			handleM.Part1 = clone.Handle
			handleM.Parent = folder["Right Arm"]
			handleM.Name = "Handle"
			clone.Parent = folder
		end,
		Keyframes = {
			swap = function()
				local v8 = nil

				for _, descendant in pairs(folder:GetDescendants()) do
					if tostring(descendant) ~= "ice dagger" then
						continue
					end

					v8 = descendant
					break
				end

				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(v8, TweenInfo.new(0.35), {
					Transparency = 0
				}):Play()

				if v8 and v8.Parent:IsA("MeshPart") then
					local TweenService3 = game:GetService("TweenService")
					TweenService3:Create(v8.Parent, TweenInfo.new(0.35), {
						Transparency = 1
					}):Play()
				end
			end,
			swapback = function()
				local v8 = nil

				for _, descendant in pairs(folder:GetDescendants()) do
					if tostring(descendant) ~= "ice dagger" then
						continue
					end

					v8 = descendant
					break
				end

				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(v8, TweenInfo.new(0.065), {
					Transparency = 1
				}):Play()

				if v8 and v8.Parent:IsA("MeshPart") then
					local TweenService3 = game:GetService("TweenService")
					TweenService3:Create(v8.Parent, TweenInfo.new(0.065), {
						Transparency = 0
					}):Play()
				end
			end
		},
		StunAttribute = 1.5,
		Animation = 128517914413709,
		Looped = false,
		Stun = "Slowed"
	}
	v5["Respectful Bow"] = {
		Startup = function() end,
		Keyframes = {},
		Dual = {
			DoBoth = false,
			Dist = 7,
			NoRotate = 1.45,
			Callback = function(instance2, _, _, p4)
				local v8, v9 = fn10({
					SoundId = "rbxassetid://16584014240",
					CFrame = CFrame.new(),
					Volume = 1
				})
				v9.Parent = instance2.PrimaryPart
				v9.WorldPosition = (instance2.PrimaryPart.CFrame * CFrame.new(0, 0, -p4 / 2)).Position
				v8:Play()
			end
		},
		Tag = "respbow",
		Animation = 16584194737,
		Looped = false,
		Stun = "Freeze"
	}
	v5["Body Swap"] = {
		Startup = function(list, _, _, _, _)
			if instance == nil then
				local clone = script["Body Swapping Potion"]:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				local bodySwappingPotion = clone["Body Swapping Potion"]
				bodySwappingPotion:SetAttribute("EmoteProperty", true)
				table.insert(list, bodySwappingPotion)
				CollectionService2:AddTag(
					bodySwappingPotion,
					"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
				)
				bodySwappingPotion.Part0 = folder["Right Arm"]
				bodySwappingPotion.Part1 = clone
				bodySwappingPotion.Parent = folder["Right Arm"]
				clone.Parent = folder
			end
		end,
		Dual = {
			DoBoth = false,
			Freeze = false,
			RotateCheck = true,
			Dist = 5,
			NoRotate = 5,
			Callback = function(parent, instance2, list, p4, _, _, _, _)
				if list.done then
					return
				end

				list.done = true
				local v8, v9 = fn10({
					SoundId = "rbxassetid://87033764847973",
					CFrame = CFrame.new(),
					Volume = 3
				})
				v9.Parent = parent.PrimaryPart
				v9.WorldPosition = (parent.PrimaryPart.CFrame * CFrame.new(0, 0, -p4 / 2)).Position
				v8:Play()
				local accessory = Instance.new("Accessory")
				accessory.Parent = parent
				accessory.Name = "Bindage"
				game.Debris:AddItem(accessory, 10)
				table.insert(list, accessory)
				local AnimationPlayer = require(parent.CharacterHandler:WaitForChild("AnimationPlayer"))

				local function fn15(p5)
					return AnimationPlayer.playAnimation(parent:FindFirstChild("Humanoid"), p5)
				end

				local AnimationPlayer2 = require(instance2.CharacterHandler:WaitForChild("AnimationPlayer"))

				local function fn16(p5)
					return AnimationPlayer2.playAnimation(instance2:FindFirstChild("Humanoid"), p5)
				end

				local v10 = fn15(101029815600455)
				v10.Priority = Enum.AnimationPriority.Action4
				v10:AdjustWeight(1)
				v10:Play()
				table.insert(list, v10)
				local v11 = fn16(108099734894805)
				v11.Priority = Enum.AnimationPriority.Action4
				v11:AdjustWeight(1)
				v11:Play()
				table.insert(list, v11)
				table.insert(list, v11:GetMarkerReachedSignal("swap"):Once(function()
					for _, parent2 in pairs({ instance2, parent }) do
						local v14 = parent2
						task.delay(4.1, function()
							if accessory and accessory.Parent then
								local humanoid = v14.Humanoid

								for k, v15 in pairs(humanoid:GetPlayingAnimationTracks()) do
									if tostring(v15.Animation.AnimationId) == "rbxassetid://85371585232532" then
										v15:Stop(0)
									end
								end
							end
						end)
						local objectValue = Instance.new("ObjectValue")
						objectValue.Value = parent2 == instance2 and parent or instance2
						objectValue.Name = "swapavatar"
						objectValue.Parent = parent2
						game.Debris:AddItem(objectValue, 0.5)
					end
				end))
			end
		},
		Looped = true,
		Tag = "bodyswap",
		Animation = 85371585232532,
		Stun = "Freeze"
	}
	v5.Cheers = {
		Startup = function(list, _, p4, _)
			fn10({
				SoundId = "rbxassetid://3929467449",
				Parent = folder.PrimaryPart,
				Volume = 0.5,
				PlaybackSpeed = 1.5
			}):Play()
			local clone = script.Colaa:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			clone.Name = "Handle"
			handle.Part0 = folder["Right Arm"]
			handle.Part1 = clone
			handle.Parent = folder["Right Arm"]
			clone.Parent = folder
		end,
		Dual = {
			DoBoth = false,
			Dist = 3.5,
			NoRotate = 3.15,
			Callback = function(instance2, _, _, p4)
				local v8, v9 = fn10({
					SoundId = "rbxassetid://15486190633",
					CFrame = CFrame.new(),
					Volume = 1
				})
				v9.Parent = instance2.PrimaryPart
				v9.WorldPosition = (instance2.PrimaryPart.CFrame * CFrame.new(0, 0, -p4 / 2)).Position
				v8:Play()
			end
		},
		Keyframes = {
			["end"] = function(p4)
				TweenService:Create(
					p4.Handle["Bloxy Cola Decoration"].Mesh,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Scale = Vector3.new()
					}
				):Play()
			end
		},
		HideWeapon = true,
		Tag = "chers",
		Animation = 15486180872,
		Looped = false,
		Stun = "Freeze"
	}
	v5["Bizarre Handshake"] = {
		Startup = function(_, _, _, _)
			fn10({
				SoundId = "rbxassetid://3929467449",
				Parent = folder.PrimaryPart,
				Volume = 0.5,
				PlaybackSpeed = 1.5
			}):Play()
		end,
		Dual = {
			DoBoth = false,
			Dist = 3.5,
			NoRotate = 8.3,
			Callback = function(instance2, _, _, p4)
				local v8, v9 = fn10({
					SoundId = "rbxassetid://15018915276",
					CFrame = CFrame.new(),
					Volume = 1
				})
				v9.Parent = instance2.PrimaryPart
				v9.WorldPosition = (instance2.PrimaryPart.CFrame * CFrame.new(0, 0, -p4 / 2)).Position
				v8:Play()
			end
		},
		Tag = "bizzarehandshake",
		Animation = 15018853350,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Highfive = {
		Startup = function(_, _, _, _)
			fn10({
				SoundId = "rbxassetid://3929467449",
				Parent = folder.PrimaryPart,
				Volume = 0.5,
				PlaybackSpeed = 1.5
			}):Play()
		end,
		Dual = {
			DoBoth = false,
			Dist = 3.5,
			NoRotate = 3,
			Callback = function(instance2, _, _, p4)
				local v8, v9 = fn10({
					SoundId = "rbxassetid://15091001878",
					CFrame = CFrame.new(),
					TimePosition = 0.15,
					Volume = 2
				})
				v9.Parent = instance2.PrimaryPart
				v9.WorldPosition = (instance2.PrimaryPart.CFrame * CFrame.new(0, 0, -p4 / 2)).Position
				v8:Resume()
			end
		},
		Tag = "highfive",
		Animation = 15223422794,
		Looped = false,
		Stun = "Freeze"
	}
	v5["Fist Bump"] = {
		HideWeapon = true,
		Startup = function(_, _, _, _)
			fn10({
				SoundId = "rbxassetid://3929467449",
				Parent = folder.PrimaryPart,
				Volume = 0.5,
				PlaybackSpeed = 1.5
			}):Play()
		end,
		Dual = {
			DoBoth = false,
			Dist = 4.8,
			Callback = function(instance2, _, _, p4)
				local v8, v9 = fn10({
					SoundId = "rbxassetid://15290318024",
					CFrame = CFrame.new(),
					Volume = 1.5
				})
				v9.Parent = instance2.PrimaryPart
				v9.WorldPosition = (instance2.PrimaryPart.CFrame * CFrame.new(0, 0, -p4 / 2)).Position
				v8:Play()
			end
		},
		Tag = "fistbupm",
		Animation = 15290322193,
		Looped = false,
		Stun = "Freeze"
	}
	v5["Dap Me Up"] = {
		Startup = function(_, _, _, _)
			fn10({
				SoundId = "rbxassetid://3929467449",
				Parent = folder.PrimaryPart,
				Volume = 0.5,
				PlaybackSpeed = 1.5
			}):Play()
		end,
		Dual = {
			DoBoth = false,
			Dist = 3.5,
			Callback = function(instance2, _, _, p4)
				local v8, v9 = fn10({
					SoundId = "rbxassetid://14407585440",
					CFrame = CFrame.new(),
					Volume = 1.5
				})
				v9.Parent = instance2.PrimaryPart
				v9.WorldPosition = (instance2.PrimaryPart.CFrame * CFrame.new(0, 0, -p4 / 2)).Position
				v8:Play()
			end
		},
		Tag = "dap",
		Animation = 15007878015,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Bully = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1847174988",
				Volume = 0.6,
				TimePosition = 0.6,
				Looped = true
			}
		},
		Keyframes = {
			claploop = function()
				fn10({
					SoundId = "rbxassetid://2704706975",
					Volume = 1,
					Parent = folder.Head
				}):Play()
			end
		},
		Infinite = true,
		Animation = 14014580605,
		Looped = true,
		Stun = "Freeze"
	}
	v5.Exercise = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1843271056",
				Volume = 0.6,
				TimePosition = 3,
				Looped = true
			}
		},
		Keyframes = {
			clap = function()
				fn10({
					SoundId = "rbxassetid://9114760154",
					Volume = 0.25,
					Parent = folder.Head
				}):Play()
			end
		},
		Infinite = true,
		Animation = 15017946867,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Chrono = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://9046628228",
				Volume = 0.4,
				TimePosition = 1.5,
				Looped = true
			}
		},
		Animation = 13935172019,
		Looped = true,
		Stun = "Freeze"
	}
	v5.Moves = {
		Startup = function(list)
			local v8 = math.random(1, 2)
			local v9 = fn10({
				SoundId = v8 == 1 and "rbxassetid://1836736766" or "rbxassetid://9044612350",
				Volume = 0.75,
				TimePosition = v8 == 1 and 19 or 1,
				Looped = true,
				Parent = folder.PrimaryPart
			})
			v9:SetAttribute("EmoteProperty", true)
			table.insert(list, v9)
			v9:Play()
		end,
		Animation = 13874517117,
		Looped = true,
		Stun = "Freeze"
	}
	v5["You Hear That?"] = {
		HideWeapon = true,
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15018202933",
				Volume = 3.25,
				Looped = true
			}
		},
		Animation = 15018219692,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Boogie = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1846808425",
				Volume = 0.75,
				Looped = true
			}
		},
		Animation = 15017959263,
		Looped = true,
		Stun = "Freeze"
	}
	v5.Shuffle = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1842612601",
				Volume = 0.75,
				Looped = true
			}
		},
		Animation = 13874572427,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Salt Shaker"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15453864958",
				Volume = 1,
				Looped = true
			}
		},
		Startup = function(list, _, p4)
			local clone = script["Salt shaker"]:Clone()
			p4.bb = clone
			table.insert(list, clone)
			clone:SetAttribute("EmoteProperty", true)
			local motor6D = clone:FindFirstChildOfClass("Motor6D")
			table.insert(list, motor6D)
			motor6D:SetAttribute("EmoteProperty", true)
			motor6D.Part0 = folder["Left Arm"]
			motor6D.Name = "Handle"
			motor6D.Part1 = clone.Handle
			motor6D.Parent = folder["Left Arm"]
			clone.Parent = folder
		end,
		Keyframes = {
			claploop = function(p4)
				p4.bb.Salt.Attachment.ParticleEmitter:Emit(5)
			end
		},
		Infinite = true,
		Animation = 15453855128,
		Looped = true,
		Stun = "Freeze"
	}
	v5["You Alright?"] = {
		HideWeapon = true,
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://14612768785",
				Volume = 2,
				Looped = false
			}
		},
		Startup = function(list, _, p4)
			local clone = script.basketball:Clone()
			p4.bb = clone
			table.insert(list, clone)
			clone:SetAttribute("EmoteProperty", true)
			local motor6D = clone:FindFirstChildOfClass("Motor6D")
			table.insert(list, motor6D)
			motor6D:SetAttribute("EmoteProperty", true)
			motor6D.Part0 = folder["Left Arm"]
			motor6D.Parent = folder["Left Arm"]
			motor6D.C0 = CFrame.new(-0.035, -1.542, -0.006)
			motor6D.Part1 = clone.Handle
			clone.Parent = folder
			fn10({
				SoundId = "rbxassetid://14612801058",
				Parent = clone.Handle,
				Volume = 0.4
			}):Play()
		end,
		Keyframes = {
			["end"] = function(p4)
				p4.bb:Destroy()
			end
		},
		Animation = 14612894074,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Guilty = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15092639799",
				Volume = 1,
				Looped = false
			}
		},
		Startup = function(list, _, p4)
			local clone = script.sign:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local m6d = clone.m6d
			m6d:SetAttribute("EmoteProperty", true)
			table.insert(list, m6d)
			p4.md = m6d
			clone.Name = "Handle"
			m6d.Part0 = folder["Left Arm"]
			m6d.Part1 = clone.Handle
			m6d.Parent = folder["Left Arm"]
			clone.Parent = folder
		end,
		Keyframes = {
			claploop = function(_, _, _, _)
				local attachment = Instance.new("Attachment")
				CollectionService2:AddTag(attachment, "emotestuff" .. folder.Name)
				attachment.Parent = workspace.Terrain
				local Debris = game:GetService("Debris")
				Debris:AddItem(attachment, 5)
				local primaryPart = folder.PrimaryPart
				attachment.WorldPosition = (primaryPart.CFrame + primaryPart.CFrame.lookVector * 10).Position + createVector(
					0,
					2,
					0
				)
				local clone = script.ImpactGlow:Clone()
				clone.Parent = attachment
				shared.resizeparticle(clone, fn12(1, 1.2))
				clone:Emit(1)
				local createlight = shared.createlight
				local v8 = {
					Position = attachment.WorldPosition,
					Color = Color3.new(1, 1, 1),
					Brightness = 0,
					Fade = 0,
					Range = 0
				}
				local v9 = 7
				local v10 = 10

				if not v10 and v9 then
					v10 = v9
					v9 = 1
				end

				if not (v10 or v9) then
					v9 = 0
					v10 = 1
				end

				v8.Brightness = random:NextNumber(v9, v10)
				local v11 = 0.3
				local v12 = 0.5

				if not v12 and v11 then
					v12 = v11
					v11 = 1
				end

				if not (v12 or v11) then
					v11 = 0
					v12 = 1
				end

				v8.Fade = random:NextNumber(v11, v12)
				local v13 = 10
				local v14 = 12

				if not v14 and v13 then
					v14 = v13
					v13 = 1
				end

				if not (v14 or v13) then
					v13 = 0
					v14 = 1
				end

				v8.Range = random:NextNumber(v13, v14)
				createlight(v8)
				fn10({
					SoundId = ({
						"rbxassetid://14616094683",
						"rbxassetid://14616213070",
						"rbxassetid://14616213367",
						"rbxassetid://14616213705",
						"rbxassetid://14616214083"
					})[math.random(1, 5)],
					Parent = attachment,
					Volume = 0.5
				}):Play()
			end,
			["end"] = function(p4, _, _)
				local sign = p4.Handle.sign
				local Debris = game:GetService("Debris")
				Debris:AddItem(sign, 5)
				p4.Handle.Handle.sign:Destroy()
				sign.Parent = workspace.Thrown
				TweenService:Create(sign, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = Vector3.new()
				}):Play()
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(40000, 40000, 40000)
				bodyVelocity.Velocity = folder.PrimaryPart.CFrame.RightVector * -20
				bodyVelocity.Velocity += createVector(0, 8, 0)
				bodyVelocity.Parent = sign
				local Debris2 = game:GetService("Debris")
				Debris2:AddItem(bodyVelocity, 0.15)
			end
		},
		Animation = 15092657164,
		Looped = false,
		Stun = "Freeze"
	}
	v5["Table Flip"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15438974600",
				Volume = 1,
				Looped = false
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Table:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			clone.Name = "Handle"
			handle.Part0 = folder.HumanoidRootPart
			handle.Part1 = clone
			handle.Parent = folder.HumanoidRootPart
			clone.Parent = folder
		end,
		Keyframes = {
			go = function(p4, _, _, _)
				local v8 = 0
				local clone = script.Table:Clone()
				CollectionService2:AddTag(clone, "emotestuff" .. folder.Name)
				local Debris = game:GetService("Debris")
				Debris:AddItem(clone, 5)
				clone.CanCollide = true
				clone.CanTouch = true
				clone.CanQuery = false
				clone.Massless = false
				clone.CollisionGroup = "nocol"
				clone.CFrame = p4.Handle.CFrame
				p4.Handle:Destroy()
				clone.Parent = workspace.Thrown
				local attachment = Instance.new("Attachment", clone)
				attachment.Position = createVector(0, -0.25, 0.25)
				local linearVelocity = Instance.new("LinearVelocity", attachment)
				linearVelocity.MaxForce = 40000
				linearVelocity.VectorVelocity = folder.PrimaryPart.CFrame.lookVector * 35 + createVector(0, 60, 0)
				linearVelocity.Attachment0 = attachment
				local Debris2 = game:GetService("Debris")
				Debris2:AddItem(linearVelocity, 0.15)
				clone:SetNetworkOwner(playerFromCharacter)
				local touchedConnection = clone.Touched:Connect(function(otherPart)
					if otherPart:IsDescendantOf(workspace.Live) or tick() - v8 < 0.075 or math.abs(clone.Velocity.Y) < 2 then
						return
					end

					v8 = 1e999
					fn10({
						SoundId = "rbxassetid://15438974803",
						Parent = clone,
						Volume = 2
					}):Play()
					fn10({
						SoundId = "rbxassetid://9120957636",
						Parent = clone,
						Volume = 1
					}):Play()
				end)
				task.delay(5, function()
					touchedConnection:Disconnect()
				end)
			end
		},
		Animation = 15438946008,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Ls = {
		Sounds = {},
		Startup = function(list, _, p4)
			local clone = script.Letter:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			p4.md = handle
			clone.Name = "Handle"
			handle.Part0 = folder["Right Arm"]
			handle.Part1 = clone
			handle.Parent = folder["Right Arm"]
			clone.Parent = folder
		end,
		Keyframes = {
			clap = function(p4)
				TweenService:Create(
					p4.Handle.Part.Mesh,
					TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						Scale = createVector(0.24, 0.24, 0.24)
					}
				):Play()
				fn10({
					SoundId = "rbxassetid://9117842014",
					Parent = p4.Handle.Part,
					Volume = 0.25
				}):Play()
			end,
			claploop = function(p4, _, _, _)
				local now = tick()
				local clone = script.Letter.Part:Clone()
				CollectionService2:AddTag(clone, "emotestuff" .. folder.Name)
				local Debris = game:GetService("Debris")
				Debris:AddItem(clone, 5)
				clone.CanCollide = true
				clone.CanTouch = true
				clone.CanQuery = false
				clone.Massless = false
				clone.CollisionGroup = "nocol"
				clone.CFrame = p4.Handle.Part.CFrame
				p4.Handle.Part.Mesh.Scale = Vector3.new()
				clone.Parent = workspace.Thrown
				local v9 = {
					SoundId = "rbxassetid://15453510339",
					Parent = clone,
					Volume = 0.75,
					PlaybackSpeed = 0,
					TimePosition = 0.1
				}
				local v10 = 0.95
				local v11 = 1.25

				if not v11 and v10 then
					v11 = v10
					v10 = 1
				end

				if not (v11 or v10) then
					v10 = 0
					v11 = 1
				end

				v9.PlaybackSpeed = random:NextNumber(v10, v11)
				fn10(v9):Resume()
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(40000, 40000, 40000)
				local cFrame = folder.PrimaryPart.CFrame
				local v13 = -15
				local v14 = 15

				if not v14 and v13 then
					v14 = v13
					v13 = 1
				end

				if not (v14 or v13) then
					v13 = 0
					v14 = 1
				end

				local lookVector = (cFrame * CFrame.Angles(0, math.rad((random:NextNumber(v13, v14))), 0)).lookVector
				local v15 = 30
				local v16 = 40

				if not v16 and v15 then
					v16 = v15
					v15 = 1
				end

				if not (v16 or v15) then
					v15 = 0
					v16 = 1
				end

				local v17 = lookVector * random:NextNumber(v15, v16)
				local v19 = 5
				local v20 = 7.5

				if not v20 and v19 then
					v20 = v19
					v19 = 1
				end

				if not (v20 or v19) then
					v19 = 0
					v20 = 1
				end

				bodyVelocity.Velocity = v17 + Vector3.new(0, random:NextNumber(v19, v20), 0)
				bodyVelocity.Parent = clone
				local Debris2 = game:GetService("Debris")
				Debris2:AddItem(bodyVelocity, 0.15)
				clone:SetNetworkOwner(playerFromCharacter)
				local mesh = clone.Mesh
				local touchedConnection = clone.Touched:Connect(function(otherPart)
					if otherPart:IsDescendantOf(workspace.Live) or tick() - now < 0.075 or math.abs(clone.Velocity.Y) < 2 then
						return
					end

					now = 1e999
					local v22 = {
						SoundId = "rbxassetid://9118172318",
						Parent = clone,
						Volume = 0.5,
						PlaybackSpeed = 0
					}
					local v23 = 1
					local v24 = 1.5

					if not v24 and v23 then
						v24 = v23
						v23 = 1
					end

					if not (v24 or v23) then
						v23 = 0
						v24 = 1
					end

					v22.PlaybackSpeed = random:NextNumber(v23, v24)
					fn10(v22):Play()
					task.delay(0.75, function()
						TweenService:Create(mesh, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Scale = createVector(0, 0, 0)
						}):Play()
						task.delay(0.5, function()
							clone:Destroy()
						end)
					end)
				end)
				task.delay(1, function()
					touchedConnection:Disconnect()
				end)
			end
		},
		Infinite = true,
		Animation = 15453677841,
		Looped = true,
		Stun = "Slowed"
	}
	v5["And One"] = {
		HideWeapon = true,
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://14615768920",
				Volume = 1,
				Looped = false
			}
		},
		Startup = function(list, _, p4)
			local clone = script.basketball:Clone()
			p4.bb = clone
			table.insert(list, clone)
			clone:SetAttribute("EmoteProperty", true)
			local motor6D = clone:FindFirstChildOfClass("Motor6D")
			table.insert(list, motor6D)
			motor6D:SetAttribute("EmoteProperty", true)
			motor6D.Part0 = folder.PrimaryPart
			motor6D.Name = "Handle"
			motor6D.Parent = folder.PrimaryPart
			motor6D.C0 = CFrame.new(-1.5, -1.375, 0)
			motor6D.Part1 = clone.Handle
			clone.Parent = folder
		end,
		Keyframes = {
			jump = function(_, _, _, p4)
				task.spawn(function()
					local v9 = 3
					local v10 = 4

					if not v10 and v9 then
						v10 = v9
						v9 = 1
					end

					if not (v10 or v9) then
						v9 = 0
						v10 = 1
					end

					for _ = 1, random:NextInteger(v9, v10) do
						if p4.interrupted then
							break
						end

						local attachment = Instance.new("Attachment")
						CollectionService2:AddTag(attachment, "emotestuff" .. folder.Name)
						attachment.Parent = folder.PrimaryPart
						local Debris = game:GetService("Debris")
						Debris:AddItem(attachment, 5)
						local primaryPart = folder.PrimaryPart
						local position = primaryPart.Position
						local v11 = -10
						local v12 = 10

						if not v12 and v11 then
							v12 = v11
							v11 = 1
						end

						if not (v12 or v11) then
							v11 = 0
							v12 = 1
						end

						local v13 = position + Vector3.new(random:NextNumber(v11, v12), 0, fn12(-10, 10))
						attachment.WorldPosition = primaryPart.Position + (v13 - primaryPart.Position).Unit * 10
						local worldPosition = attachment.WorldPosition
						local v15 = 1
						local v16 = 3

						if not v16 and v15 then
							v16 = v15
							v15 = 1
						end

						if not (v16 or v15) then
							v15 = 0
							v16 = 1
						end

						attachment.WorldPosition = worldPosition + Vector3.new(0, random:NextNumber(v15, v16), 0)
						local clone = script.ImpactGlow:Clone()
						clone.Parent = attachment
						shared.resizeparticle(clone, fn12(1, 1.2))
						clone:Emit(1)
						local createlight = shared.createlight
						local v17 = {
							Position = attachment.WorldPosition,
							Color = Color3.new(1, 1, 1),
							Brightness = 0,
							Fade = 0,
							Range = 0
						}
						local v18 = 7
						local v19 = 10

						if not v19 and v18 then
							v19 = v18
							v18 = 1
						end

						if not (v19 or v18) then
							v18 = 0
							v19 = 1
						end

						v17.Brightness = random:NextNumber(v18, v19)
						local v20 = 0.3
						local v21 = 0.5

						if not v21 and v20 then
							v21 = v20
							v20 = 1
						end

						if not (v21 or v20) then
							v20 = 0
							v21 = 1
						end

						v17.Fade = random:NextNumber(v20, v21)
						local v22 = 10
						local v23 = 12

						if not v23 and v22 then
							v23 = v22
							v22 = 1
						end

						if not (v23 or v22) then
							v22 = 0
							v23 = 1
						end

						v17.Range = random:NextNumber(v22, v23)
						createlight(v17)
						fn10({
							SoundId = ({
								"rbxassetid://14616094683",
								"rbxassetid://14616213070",
								"rbxassetid://14616213367",
								"rbxassetid://14616213705",
								"rbxassetid://14616214083"
							})[math.random(1, 5)],
							Parent = attachment,
							Volume = 0.5
						}):Play()
						task.wait(fn12(0, 0.175))
					end
				end)
			end,
			throw = function(p4, _, _, _)
				p4.bb["B-Ball"].Transparency = 1
				local clone = script.basketball["B-Ball"]:Clone()
				CollectionService2:AddTag(clone, "emotestuff" .. folder.Name)
				local Debris = game:GetService("Debris")
				Debris:AddItem(clone, 5)
				clone.CanCollide = true
				clone.CanTouch = true
				clone.CanQuery = false
				clone.Massless = false
				clone.CollisionGroup = "nocol"
				clone.CFrame = p4.bb["B-Ball"].CFrame
				clone.CustomPhysicalProperties = PhysicalProperties.new(nil, nil, 1, nil, 1)
				clone.Parent = workspace.Thrown
				clone:SetNetworkOwner(playerFromCharacter)
				local v8 = folder.PrimaryPart.CFrame + folder.PrimaryPart.CFrame.lookVector * 50
				local vector2 = Vector3.new(0, -workspace.Gravity, 0)
				local v9 = folder.PrimaryPart.CFrame * createVector(0, 0, -2)
				local now = 0
				clone.Velocity = (v8.Position - v9 - vector2 * 0.5 * 1 * 1) / 1
				local touchedConnection = clone.Touched:Connect(function(otherPart)
					if otherPart:IsDescendantOf(workspace.Live) or tick() - now < 0.075 or math.abs(clone.Velocity.Y) < 4 then
						return
					end

					now = tick()
					fn10({
						SoundId = "rbxassetid://14404844095",
						Parent = clone,
						Volume = 2,
						PlaybackSpeed = Random.new():NextNumber(0.9, 1.1)
					}):Play()
				end)
				task.delay(5, function()
					touchedConnection:Disconnect()
				end)
			end
		},
		Animation = 14616272668,
		Fix = true,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Millionare = {
		HideWeapon = true,
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://14613168242",
				Volume = 1,
				Looped = false
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Briefcase:Clone()
			p4.bb = clone
			table.insert(list, clone)
			clone:SetAttribute("EmoteProperty", true)
			local M6D = clone.M6D
			table.insert(list, M6D)
			M6D:SetAttribute("EmoteProperty", true)
			M6D.Part0 = folder.PrimaryPart
			M6D.Name = "Root"
			M6D.Part1 = clone.Root
			M6D.Parent = folder.PrimaryPart
			clone.Parent = folder
			local v8 = fn10({
				SoundId = "rbxassetid://9042544497",
				Volume = 0,
				TimePosition = 1.15,
				Looped = false,
				Parent = folder.PrimaryPart
			})
			v8:SetAttribute("EmoteProperty", true)
			v8:Resume()
			TweenService:Create(v8, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Volume = 0.3
			}):Play()
		end,
		Keyframes = {
			["end"] = function(p4)
				p4.bb:Destroy()
			end
		},
		Animation = 14613239786,
		Looped = false,
		Stun = "Slowed"
	}
	v5.RAHHH = {
		HideWeapon = true,
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://14399836732",
				Volume = 1,
				Looped = false
			}
		},
		Keyframes = {
			slam = function(p4)
				local clone = script.basketball["B-Ball"]:Clone()
				CollectionService2:AddTag(clone, "emotestuff" .. folder.Name)
				local Debris = game:GetService("Debris")
				Debris:AddItem(clone, 5)
				clone.CanCollide = true
				clone.CanTouch = true
				clone.CanQuery = false
				clone.Massless = false
				clone.CollisionGroup = "nocol"
				clone.CFrame = p4.bb["B-Ball"].CFrame
				clone.Velocity = createVector(0, -75, 0)
				clone.CustomPhysicalProperties = PhysicalProperties.new(nil, nil, 1, nil, 1)
				clone.Parent = workspace.Thrown
				clone:SetNetworkOwner(playerFromCharacter)
				local now = 0
				local touchedConnection = clone.Touched:Connect(function(otherPart)
					if otherPart:IsDescendantOf(workspace.Live) or tick() - now < 0.075 or math.abs(clone.Velocity.Y) < 4 then
						return
					end

					now = tick()
					fn10({
						SoundId = "rbxassetid://14404844095",
						Parent = clone,
						Volume = 2,
						PlaybackSpeed = Random.new():NextNumber(0.9, 1.1)
					}):Play()
				end)
				task.delay(5, function()
					touchedConnection:Disconnect()
				end)
				p4.bb:Destroy()
				fn10({
					SoundId = "rbxassetid://14405165735",
					Parent = p4.hoop,
					Volume = 1
				}):Play()
				fn10({
					SoundId = "rbxassetid://14404816151",
					Parent = folder:FindFirstChild("Torso"),
					Volume = 2
				}):Play()
			end
		},
		Startup = function(list, _, p4)
			local clone = script.basketball:Clone()
			p4.bb = clone
			table.insert(list, clone)
			clone:SetAttribute("EmoteProperty", true)
			local clone2 = script.hoop:Clone()
			local weld = Instance.new("Weld")
			weld.Part0 = folder.PrimaryPart
			weld.Part1 = clone2.Main
			weld.Parent = clone2
			weld.C0 = CFrame.new(
				0.0489730835,
				5.62188959,
				-4.88491774,
				-2.98023224e-8,
				1.49011612e-8,
				0.99999994,
				0,
				1,
				1.49011612e-8,
				-1,
				0,
				2.98023224e-8
			)
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(list, clone2)
			clone2.Parent = folder
			p4.hoop = clone2.Main
			local motor6D = clone:FindFirstChildOfClass("Motor6D")
			table.insert(list, motor6D)
			motor6D:SetAttribute("EmoteProperty", true)
			motor6D.Part0 = folder["Left Arm"]
			motor6D.Parent = folder["Left Arm"]
			motor6D.C0 = CFrame.new(0, -1.375, 0)
			motor6D.Part1 = clone.Handle
			clone.Parent = folder
		end,
		Fix = true,
		Animation = 14403375793,
		Looped = false,
		Stun = "Freeze"
	}
	v5["Pipe Down"] = {
		HideWeapon = true,
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://14406939515",
				Volume = 2,
				Looped = false
			}
		},
		Keyframes = {
			["end"] = function(p4)
				p4.pipe.Transparency = 1
			end
		},
		Startup = function(list, _, p4)
			local clone = script["metal pipe"]:Clone()
			local part = clone.Part
			part.Part0 = folder["Right Arm"]
			part.Part1 = clone["Metal pipe"].Part
			p4.pipe = clone["Metal pipe"]

			for _, v8 in pairs({ clone, part }) do
				v8:SetAttribute("EmoteProperty", true)
				table.insert(list, v8)
			end

			part.Parent = folder["Right Arm"]
			clone.Parent = folder
		end,
		Animation = 14406991505,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Weight = {
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		Startup = function(list, _, p4)
			local clone = script.Weight:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local motor6D = clone:FindFirstChildOfClass("Motor6D")
			motor6D:SetAttribute("EmoteProperty", true)
			table.insert(list, motor6D)
			p4.md = motor6D
			motor6D.Name = "Handle"
			motor6D.Part0 = folder["Left Arm"]
			motor6D.Part1 = clone.Handle
			motor6D.Parent = folder["Left Arm"]
			clone.Parent = folder
			fn10({
				SoundId = "rbxassetid://15674264465",
				Parent = folder.Torso,
				Volume = 2
			}):Play()
		end,
		HideWeapon = true,
		Animation = 15674270929,
		Looped = false,
		Stun = "Freeze"
	}
	v5["Take My Money"] = {
		Keyframes = {
			coins = function(_, _, _)
				game.ReplicatedStorage.Replication:FireAllClients({
					Effect = "Coins",
					root = folder.PrimaryPart
				})
			end
		},
		Startup = function(list, _, p4)
			local clone = script.TakeMoney["Meshes/Card_model"]:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local motor6D = clone:FindFirstChildOfClass("Motor6D")
			motor6D:SetAttribute("EmoteProperty", true)
			table.insert(list, motor6D)
			p4.md = motor6D
			motor6D.Name = "Meshes/Card_model"
			motor6D.Part0 = folder["Left Arm"]
			motor6D.Part1 = clone
			motor6D.Parent = folder["Left Arm"]
			clone.Parent = folder
			local clone2 = script.TakeMoney.Counter:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(list, clone2)
			clone2.Name = "asjdaiosdjasjd"
			local weld = Instance.new("Weld")
			weld.Part0 = folder.PrimaryPart
			weld.Part1 = clone2.Bottom
			weld.C0 = CFrame.new(
				0.320178986,
				-1.92516398,
				-2.43821144,
				-2.60999286e-7,
				3.78694926e-6,
				-1.00000024,
				4.02372007e-6,
				1.00000262,
				1.25370036e-6,
				1.00000143,
				-1.38620999e-6,
				-9.6974091e-8
			)
			weld.Parent = clone2.Bottom
			clone2.Parent = folder
			task.delay(0, function()
				for _, child in pairs(clone2:GetChildren()) do
					child.CollisionGroup = "nocol"
				end
			end)
		end,
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16593642774",
				Volume = 2,
				Looped = false
			}
		},
		Animation = 16593648830,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Garbage = {
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		Startup = function(list, _, p4)
			local clone = script.trashbag:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local motor6D = clone:FindFirstChildOfClass("Motor6D")
			motor6D:SetAttribute("EmoteProperty", true)
			table.insert(list, motor6D)
			p4.md = motor6D
			motor6D.Name = "Sphere"
			motor6D.Part0 = folder.PrimaryPart
			motor6D.Part1 = clone.Sphere
			motor6D.Parent = folder.PrimaryPart
			clone.Parent = folder
			fn10({
				SoundId = "rbxassetid://14498158970",
				Parent = clone.Sphere,
				Volume = 1
			}):Play()
		end,
		Animation = 14498295360,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Silence = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://14498550793",
				Volume = 0.75,
				Looped = false
			}
		},
		Keyframes = {
			deaf = function(_, list)
				local cfolder = shared.cfolder({
					Name = "#Deafened",
					Parent = folder
				})
				cfolder:SetAttribute("EmoteProperty", true)
				table.insert(list, cfolder)
			end,
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		Startup = function(list, _, p4)
			local silence = script.Silence
			local clone = silence["Earplug Handle"]:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			p4.Handle = clone
			local md = clone[clone.Name]
			md:SetAttribute("EmoteProperty", true)
			table.insert(list, md)
			p4.md = md
			md.Name = "Handle"
			md.Part0 = folder["Right Arm"]
			md.Part1 = clone
			md.Parent = folder["Right Arm"]
			clone.Parent = folder
			local clone2 = silence["Earplug Handle2"]:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(list, clone2)
			p4.Handle = clone2
			local md2 = clone2[clone2.Name]
			md2:SetAttribute("EmoteProperty", true)
			table.insert(list, md2)
			p4.md = md2
			md2.Name = "Handle"
			md2.Part0 = folder["Left Arm"]
			md2.Part1 = clone2
			md2.Parent = folder["Left Arm"]
			clone2.Parent = folder
		end,
		Animation = 14498033288,
		Looped = false,
		Stun = "Slowed"
	}
	v5["Fresh Fries"] = {
		HideWeapon = true,
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://14406845410",
				Volume = 2,
				Looped = false
			}
		},
		Keyframes = {
			appear = function(p4)
				for _, child in pairs(p4.fries:GetChildren()) do
					if child.Name ~= "primary" then
						child.Transparency = 0
					end
				end
			end,
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end,
			gone = function(p4)
				p4.box:Destroy()
			end
		},
		Startup = function(clones, _, p4)
			local clone = script.Fries.Fries:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone)
			p4.fries = clone
			local clone2 = script.Fries.primary:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone2)
			clone2.Part0 = folder.PrimaryPart
			clone2.Part1 = clone.primary
			clone2.Parent = folder.PrimaryPart
			clone.Parent = folder
			local clone3 = script.Fries.Model:Clone()
			clone3:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone3)
			local clone4 = script.Fries["primary part"]:Clone()
			clone4:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone4)
			clone4.Part0 = folder["Right Arm"]
			clone4.Part1 = clone3["primary part"]
			clone4.Parent = folder["Right Arm"]
			clone3.Parent = folder
			p4.box = clone3
			local clone5 = script.Fries.Chair:Clone()
			clone5:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone5)
			local weld = Instance.new("Weld")
			weld.Part0 = folder.PrimaryPart
			weld.Part1 = clone5
			weld.C0 = CFrame.new(
				-0.0262451172,
				-0.944903374,
				0.946708679,
				1,
				4.04431057e-6,
				-1.05499259e-6,
				-4.04430102e-6,
				1,
				8.92530261e-6,
				1.05502875e-6,
				-8.92529806e-6,
				1
			)
			weld.Parent = clone5
			clone5.Parent = folder
			local clone6 = script.Fries.Table:Clone()
			clone6:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone6)
			local weld2 = Instance.new("Weld")
			weld2.Part0 = folder.PrimaryPart
			weld2.Part1 = clone6
			weld2.C0 = CFrame.new(
				-0.0000152587891,
				-1.70007861,
				-2.60010529,
				1,
				4.04431057e-6,
				-1.05499259e-6,
				-4.04430102e-6,
				1,
				8.92530261e-6,
				1.05502875e-6,
				-8.92529806e-6,
				1
			)
			weld2.Parent = clone6
			clone6.Parent = folder
		end,
		Animation = 14406679583,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Spread = {
		HideWeapon = true,
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://14056281965",
				Volume = 3.5,
				Looped = false
			}
		},
		Keyframes = {
			gone = function(items)
				for _, item in pairs(items) do
					item:Destroy()
				end
			end
		},
		Startup = function(clones, _, p4)
			local v8 = fn10({
				SoundId = "rbxassetid://1837644729",
				Volume = 0,
				TimePosition = 1.1,
				Looped = false,
				Parent = folder.PrimaryPart
			})
			v8:SetAttribute("EmoteProperty", true)
			v8:Resume()
			TweenService:Create(v8, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Volume = 0.75
			}):Play()
			local clone = script.Money.Handle:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone)
			p4.Handle = clone
			local clone2 = script.Money.M6D:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone2)
			p4.md = clone2
			clone2.Name = "Handle"
			clone2.Part0 = folder["Left Arm"]
			clone2.Part1 = clone
			clone2.Parent = folder["Left Arm"]
			clone.Parent = folder
		end,
		Animation = 14056341330,
		Looped = false,
		Stun = "Slowed"
	}
	v5["Keyboard Warrior"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://14357786890",
				Volume = 1.25,
				Looped = true
			}
		},
		Startup = function(clones)
			local clone = script.Keyboard.Handle:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone)
			local clone2 = script.Keyboard.M6D:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone2)
			clone2.Name = "Handle"
			clone2.Part0 = folder.HumanoidRootPart
			clone2.Part1 = clone
			clone2.Parent = folder.HumanoidRootPart
			clone.Parent = folder
		end,
		Animation = 14357783332,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Rage = {
		Sounds = {},
		Startup = function(clones, _, p4)
			local clone = script.Keyboard.Handle:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone)
			p4.kb = clone.Keyboard
			local clone2 = script.Keyboard.M6D:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone2)
			clone2.Name = "Handle"
			clone2.Part0 = folder.HumanoidRootPart
			clone2.Part1 = clone
			clone2.Parent = folder.HumanoidRootPart
			clone.Parent = folder
			local v8 = fn10({
				SoundId = "rbxassetid://15290205166",
				Parent = clone,
				TimePosition = 0.25,
				Volume = 2
			})
			v8:Resume()
			p4.s = v8
		end,
		Keyframes = {
			["end"] = function(p4, _, _)
				local clone = p4.kb:Clone()
				CollectionService2:AddTag(clone, "emotestuff" .. folder.Name)
				p4.kb.Transparency = 1
				local Debris = game:GetService("Debris")
				Debris:AddItem(clone, 5)
				clone.CanCollide = true
				clone.CanTouch = true
				clone.CanQuery = false
				clone.Massless = false
				clone.CollisionGroup = "nocol"
				clone.CFrame = p4.kb.CFrame
				clone.CustomPhysicalProperties = PhysicalProperties.new(nil, nil, 1, nil, 1)
				clone.Parent = workspace.Thrown

				if p4.s then
					p4.s.Parent = clone
				end

				clone:SetNetworkOwner(playerFromCharacter)
				clone.Velocity = createVector(0, -50, 0)
				clone.AssemblyAngularVelocity = Vector3.new(
					math.random(-90, 90),
					math.random(-90, 90),
					math.random(-90, 90)
				)
			end
		},
		Animation = 15290188901,
		Looped = false,
		Stun = "Slowed"
	}
	v5.Chair = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://14056074389",
				Volume = 2.25,
				Looped = false
			}
		},
		Startup = function(clones)
			local clone = script.Chair.Handle:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone)
			local clone2 = script.Chair.M6D:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone2)
			clone2.Name = "Handle"
			clone2.Part0 = folder.HumanoidRootPart
			clone2.Part1 = clone
			clone2.Parent = folder.HumanoidRootPart
			clone.Parent = folder
		end,
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		Animation = 14056032417,
		Looped = false,
		Stun = "Freeze"
	}
	v5.RIP = {
		HideWeapon = true,
		Startup = function(clones, _, p4)
			local clone = script.Grave.Grave:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone)
			local clone2 = script.Grave.M6D:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone2)
			clone2.Name = "Handle"
			clone2.Part0 = folder.HumanoidRootPart
			clone2.Part1 = clone
			clone2.Parent = folder.HumanoidRootPart
			clone.Parent = folder
			p4.handle = clone
			fn10({
				SoundId = "rbxassetid://14399156027",
				Volume = 1,
				TimePosition = 0.12,
				Parent = folder.PrimaryPart
			}):Resume()
		end,
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end,
			smash = function(p4)
				p4.handle.Attachment.Dust:Emit(10)
				fn10({
					SoundId = "rbxassetid://14399155774",
					Parent = p4.handle,
					Volume = 1.25,
					TimePosition = 0.047
				}):Resume()
			end
		},
		Fix = true,
		Animation = 14399170033,
		Looped = false,
		Stun = "Freeze"
	}
	v5["RK Coin Trick"] = {
		HideWeapon = true,
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://14056453575",
				Volume = 1,
				Looped = false
			}
		},
		Startup = function(clones)
			local clone = script.Coin.Handle:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone)
			local clone2 = script.Coin.M6D:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone2)
			clone2.Name = "Handle"
			clone2.Part0 = folder["Left Arm"]
			clone2.Part1 = clone
			clone2.Parent = folder["Left Arm"]
			clone.Parent = folder
		end,
		Animation = 14055990256,
		Looped = false,
		Stun = "Slowed"
	}
	v5.Think = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://9046379730",
				Volume = 0.75,
				Looped = true
			}
		},
		Keyframes = {
			claploop = function()
				fn10({
					SoundId = "rbxassetid://9114456730",
					Volume = 0.85,
					Parent = folder.Head
				}):Play()
			end
		},
		Startup = function(clones, _)
			local clone = script.Think.Attachment:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone)
			clone.Parent = folder.HumanoidRootPart
		end,
		Infinite = true,
		Animation = 13801090462,
		Looped = true,
		Stun = "Freeze"
	}
	v5["No Limit"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://9042542555",
				Volume = 0.75,
				Looped = true
			}
		},
		Animation = 13777338337,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Soul = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1836860450",
				Volume = 0.75,
				Looped = true
			}
		},
		Animation = 13777407704,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Chill = {
		Animation = 13736115009,
		Looped = true,
		Stun = "Freeze"
	}
	v5.Penguin = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1839021706",
				Volume = 0.5,
				Looped = true
			}
		},
		Animation = 13735821189,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Laugh = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://9056830251",
				Volume = 1.75,
				Looped = false
			}
		},
		Animation = 8887084105,
		Stun = "Slowed"
	}
	v5.Sturdy = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1848269635",
				Volume = 1,
				Looped = true
			}
		},
		Animation = 13720956493,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Sleek = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://83043479303821",
				Volume = 1,
				Looped = true
			}
		},
		Infinite = true,
		Animation = 129164425146782,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Backflip Burpee"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://103284507403423",
				Volume = 2,
				Looped = true
			}
		},
		Animation = 71807960635362,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Stepper = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://104462985877801",
				Volume = 2,
				Looped = true
			}
		},
		Infinite = true,
		Animation = 97890323260663,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Internet Angel"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://77791690624447",
				Volume = 2,
				Looped = true
			}
		},
		Infinite = true,
		Animation = 95846384467857,
		Looped = true,
		Stun = "Slowed"
	}
	v5["True Love"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://99295350859531",
				Volume = 2,
				Looped = true
			}
		},
		Infinite = true,
		Animation = 76028780100288,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Unmatched Flow"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://115280107968027",
				Volume = 2,
				Looped = true
			}
		},
		Infinite = true,
		Animation = 108400543598907,
		Looped = true,
		Stun = "Slowed"
	}
	v5[":3"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://123965451318755",
				Volume = 2.65,
				Looped = true
			}
		},
		Infinite = true,
		Animation = 75129111723915,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Kawaii = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://108268388574452",
				Volume = 2,
				Looped = true
			}
		},
		Infinite = true,
		Animation = 84955596359069,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Happy Hour"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://135768204851321",
				Volume = 1,
				Looped = true
			}
		},
		Infinite = true,
		Animation = 134748346257293,
		Idle = 119965736870157,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Smooth Moves"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://139544862276913",
				Volume = 2,
				Looped = true
			}
		},
		Infinite = true,
		Animation = 113810252754559,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Jolly Jumps"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://79813014158048",
				Volume = 2,
				Looped = true
			}
		},
		Infinite = true,
		Animation = 100696757841526,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Specialist = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://93655305990112",
				Volume = 1,
				Looped = true
			}
		},
		Infinite = true,
		Animation = 90012230573313,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Mesmerizer = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://130768197175219",
				Volume = 2,
				Looped = true
			}
		},
		Infinite = true,
		Animation = 91526812005666,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Happy Time"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://122123156310442",
				Volume = 0,
				Looped = true
			}
		},
		Infinite = true,
		Animation = 102484010197347,
		Looped = true,
		Stun = "Slowed",
		Startup = function(list, _, _)
			local cfolder = shared.cfolder({
				Name = "SBind",
				Parent = folder
			})
			cfolder:SetAttribute("EmoteProperty", true)
			table.insert(list, cfolder)

			if playerFromCharacter then
				tick()
				local v9 = playerFromCharacter
				local v10

				if friendcache[v9] then
					v10 = friendcache[v9]
				end

				local ids = v10 or {}

				if #ids == 0 then
					local function iterPageItems(object2)
						return coroutine.wrap(function()
							local v11 = 1

							while true do
								for _, v12 in ipairs(object2:GetCurrentPage()) do
									coroutine.yield(v12, v11)
								end

								if object2.IsFinished then
									break
								end

								object2:AdvanceToNextPageAsync()
								v11 += 1
							end
						end)
					end

					local Players = game:GetService("Players")
					local friendsAsync = Players:GetFriendsAsync(playerFromCharacter.UserId)

					for k, _ in coroutine.wrap(function()
						local v11 = 1

						while true do
							for _, v12 in ipairs(friendsAsync:GetCurrentPage()) do
								coroutine.yield(v12, v11)
							end

							if friendsAsync.IsFinished then
								break
							end

							friendsAsync:AdvanceToNextPageAsync()
							v11 += 1
						end
					end) do
						table.insert(ids, k.Id)
					end

					if #ids > 0 then
						friendcache[playerFromCharacter] = ids
					end
				end

				local friends = {}

				for _ = 1, 2 do
					if not (#ids > 0) then
						continue
					end

					local v12 = math.random(#ids)
					table.insert(friends, ids[v12])
					table.remove(ids, v12)
				end

				game.ReplicatedStorage.Replication:FireAllClients({
					Type = "EmoteFriends",
					Character = folder,
					Friends = friends,
					Animation = 102484010197347,
					Bind = cfolder,
					WeldOffset = { CFrame.new(5, 0, 0), (CFrame.new(-5, 0, 0)) }
				})
			end
		end
	}
	v5.Tweaker = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://122123156310442",
				Volume = 2,
				Looped = true
			}
		},
		Infinite = true,
		Animation = 132607058366525,
		Looped = true,
		Stun = "Slowed"
	}
	v5["Ding Ding"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://126591092485893",
				Volume = 2,
				Looped = true
			}
		},
		Infinite = true,
		Animation = 89336760165611,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Down = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://89602445023226",
				Volume = 2,
				Looped = true
			}
		},
		Infinite = true,
		Animation = 115011464525848,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Goodbye = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://73131405937867",
				Volume = 2,
				Looped = true
			}
		},
		Infinite = true,
		Animation = 80024118486867,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Boppin = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://13772555886",
				Volume = 1,
				Looped = true
			}
		},
		Infinite = true,
		Animation = 13796404333,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Untouchable = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15019328411",
				Volume = 3,
				Looped = false
			},
			[0.01] = {
				SoundId = "rbxassetid://3750949270",
				Volume = 0.2,
				Looped = true
			}
		},
		Startup = function(list)
			local cfolder = shared.cfolder({
				Name = "InfinityDebris",
				Parent = folder
			})
			CollectionService2:AddTag(cfolder, "InfinityDebris")
			table.insert(list, cfolder)
		end,
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		Animation = 15020965094,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Sweat = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15502557516",
				Volume = 1.5,
				Looped = false
			},
			[2.6] = {
				SoundId = "rbxassetid://15502591598",
				Volume = 0.5,
				Looped = false
			}
		},
		Startup = function(list, _, p4)
			local attachment = Instance.new("Attachment")
			table.insert(list, attachment)
			attachment.Parent = folder.Head
			attachment.Position = createVector(-0.189, -0.007, 0.457)
			local clone = script.Sweating:Clone()
			p4.Crying = clone
			table.insert(list, clone)
			clone.Parent = attachment
			local attachment2 = Instance.new("Attachment")
			table.insert(list, attachment2)
			attachment2.Parent = folder.Head
			attachment2.Position = createVector(0.19, 0.5, -0.464)
			local clone2 = script.Sweated:Clone()
			p4.Crying2 = clone2
			table.insert(list, clone2)
			clone2.Parent = attachment2
		end,
		Keyframes = {
			sweat = function(p4)
				p4.Crying.Enabled = false
				p4.Crying2:Emit(10)
			end
		},
		HideWeapon = true,
		Animation = 15488553333,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Cry = {
		HideWeapon = true,
		Startup = function(list, _)
			local clone = script.Crying:Clone()
			table.insert(list, clone)
			clone.Parent = folder.Head
			local v8 = fn10({
				SoundId = "rbxassetid://9113234042",
				Parent = folder.Head,
				TimePosition = 1,
				Looped = true,
				Volume = 7
			})
			v8:Resume()
			table.insert(list, v8)
		end,
		Animation = 13874287198,
		Looped = true,
		Stun = "Freeze"
	}
	v5["We Ball"] = {
		HideWeapon = true,
		Sounds = {
			[0.03] = {
				SoundId = "rbxassetid://13874113188",
				Volume = 2.75,
				Looped = false
			}
		},
		Startup = function(list)
			local clone = script.basketball:Clone()
			table.insert(list, clone)
			clone:SetAttribute("EmoteProperty", true)
			local motor6D = clone:FindFirstChildOfClass("Motor6D")
			table.insert(list, motor6D)
			motor6D:SetAttribute("EmoteProperty", true)
			motor6D.Part0 = folder.PrimaryPart
			motor6D.Parent = folder.PrimaryPart
			motor6D.Part1 = clone.Handle
			clone.Parent = folder
			task.delay(5.233, function()
				if clone then
					clone:Destroy()
				end
			end)
			local v8 = fn10({
				SoundId = "rbxassetid://9046712764",
				Volume = 0,
				TimePosition = 0.4,
				Looped = false,
				Parent = folder.PrimaryPart
			})
			v8:SetAttribute("EmoteProperty", true)
			v8:Resume()
			TweenService:Create(v8, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Volume = 0.4
			}):Play()
			table.insert(list, v8)
		end,
		Animation = 13874117043,
		Looped = false,
		Stun = "Freeze"
	}
	v5["Bring It"] = {
		Keyframes = {
			start = function()
				fn10({
					SoundId = "rbxassetid://12981991293",
					Parent = folder.PrimaryPart,
					PlaybackSpeed = 1,
					Volume = 0.4
				}):Play()
				fn10({
					SoundId = "rbxassetid://12332220659",
					Volume = 0.45,
					PlaybackSpeed = 1,
					Parent = folder.PrimaryPart
				}):Play()
			end,
			one = function()
				fn10({
					SoundId = "rbxassetid://9117373365",
					Volume = 0.75,
					PlaybackSpeed = 1.45,
					Parent = folder.PrimaryPart
				}):Play()
			end,
			two = function()
				fn10({
					SoundId = "rbxassetid://12332220659",
					Volume = 1.35,
					PlaybackSpeed = 1.9,
					Parent = folder.PrimaryPart
				}):Play()
			end
		},
		Animation = 13801083337,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Applause = {
		Keyframes = {
			claploop = function()
				local v8 = fn10({
					SoundId = "rbxassetid://1840084272",
					PlaybackSpeed = 1,
					Volume = 0.5,
					Parent = folder.PrimaryPart
				})
				v8:Play()
				game:service("TweenService"):Create(
					v8,
					TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{
						Volume = 0
					}
				):Play()
			end
		},
		Infinite = true,
		Animation = 14056379526,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Heh = {
		Keyframes = {
			start = function(p4, list)
				local clone = script.Glasses:Clone()
				clone:SetAttribute("EmoteProperty", true)
				clone.Parent = folder
				table.insert(list, clone)
				local motor6D = Instance.new("Motor6D")
				motor6D:SetAttribute("EmoteProperty", true)
				table.insert(list, motor6D)
				motor6D.Part0 = folder["Left Arm"]
				motor6D.C0 = CFrame.new(
					0.00482857227,
					-0.974339962,
					-0.0985401124,
					0.99999547,
					1.35184547e-27,
					-3.3606216e-28,
					1.00842308e-27,
					-0.0216581449,
					0.999762356,
					0,
					-0.999764025,
					-0.0216580443
				)
				motor6D.Part1 = clone.Handle
				motor6D.Parent = folder["Left Arm"]
				local v8 = fn10({
					SoundId = "rbxassetid://13773962010",
					Volume = 1.5,
					PlaybackSpeed = 1.15,
					Parent = clone.Handle
				})
				v8:Play()
				task.delay(0.5, function()
					game:service("TweenService"):Create(
						v8,
						TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Volume = 0
						}
					):Play()
				end)
				p4.glasses = clone
				fn10({
					SoundId = "rbxassetid://3929467229",
					Parent = folder.Head,
					PlaybackSpeed = 1.5,
					Volume = 0.4
				}):Play()
			end,
			vfx = function(p4, list)
				fn10({
					SoundId = "rbxassetid://13773869254",
					Parent = folder.Head,
					PlaybackSpeed = 1,
					Volume = 0.9
				}):Play()
				fn10({
					SoundId = "rbxassetid://12332220659",
					Parent = folder.Head,
					Volume = 0.35,
					PlaybackSpeed = 1.35
				}):Play()
				local attachment = Instance.new("Attachment")
				attachment:SetAttribute("EmoteProperty", true)
				attachment.CFrame = CFrame.new(
					-0.239279747,
					0.309562922,
					-0.575252533,
					-0.0331349373,
					-0.72963804,
					-0.683030546,
					-0.989827991,
					-0.0706492513,
					0.123488307,
					-0.138357326,
					0.68017441,
					-0.719875157
				)
				attachment.Parent = folder.Head
				table.insert(list, attachment)

				for _, child in pairs(script.Shine:GetChildren()) do
					local clone = child:Clone()
					clone.Parent = attachment
					shared.resizeparticle(clone, 1.5)
					clone:Emit(1)
				end

				if p4.glasses then
					local glasses = p4.glasses

					for _, v8 in pairs({ glasses.Glass1, glasses.Glass2 }) do
						v8.Material = Enum.Material.Neon
						v8.Color = Color3.new(1, 1, 1)
						v8.Transparency = 0
						local v9 = v8
						task.delay(0.5, function()
							game:service("TweenService"):Create(
								v9,
								TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Color = Color3.fromRGB(105, 102, 92),
									Transparency = 0.75
								}
							):Play()
						end)
					end
				end
			end,
			gone = function(p4)
				if p4.glasses then
					p4.glasses:Destroy()
				end
			end,
			away = function()
				fn10({
					SoundId = "rbxassetid://12981991293",
					Parent = folder.Head,
					PlaybackSpeed = 1.5,
					Volume = 0.4
				}):Play()
			end
		},
		Animation = 13773978314,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Facepalm = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://10456925537",
				Volume = 0.25
			}
		},
		Keyframes = {
			facepalm = function()
				fn10({
					SoundId = "rbxassetid://511340819",
					Parent = folder.Head,
					TimePosition = 0.1,
					Volume = 1.5
				}):Resume()
				task.delay(1, function()
					fn10({
						SoundId = "rbxassetid://3848835272",
						Parent = folder.Head,
						Volume = 0.4,
						PlaybackSpeed = 1.25
					}):Play()
				end)
			end,
			sway = function()
				fn10({
					SoundId = "rbxassetid://3929467229",
					Parent = folder.Head,
					PlaybackSpeed = 1.5,
					Volume = 0.5
				}):Play()
			end
		},
		Animation = 14056367009,
		Looped = false,
		Stun = "Slowed"
	}
	v5.Crack = {
		HideWeapon = true,
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://12332220659",
				Volume = 0.375,
				PlaybackSpeed = 1.5
			}
		},
		Keyframes = {
			crack1 = function()
				fn10({
					SoundId = "rbxassetid://9113541085",
					Parent = folder.Head,
					Volume = 0.75
				}):Play()
				fn10({
					SoundId = "rbxassetid://12332220659",
					Volume = 0.375,
					PlaybackSpeed = 2,
					Parent = folder.Head
				}):Play()
			end,
			crack2 = function()
				fn10({
					SoundId = "rbxassetid://9113538220",
					Parent = folder.Head,
					Volume = 0.75
				}):Play()
				fn10({
					SoundId = "rbxassetid://12981991293",
					Parent = folder.PrimaryPart,
					PlaybackSpeed = 1.5,
					Volume = 0.375,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end,
			crack3 = function()
				fn10({
					SoundId = "rbxassetid://6930015332",
					Parent = folder.PrimaryPart,
					Volume = 0.75
				}):Play()
			end,
			crack4 = function(_, _, object2)
				fn10({
					SoundId = "rbxassetid://9113538216",
					Parent = folder.PrimaryPart,
					Volume = 0.75
				}):Play()
				object2:AdjustSpeed(1.5)
				fn10({
					SoundId = "rbxassetid://12981991293",
					Parent = folder.PrimaryPart,
					PlaybackSpeed = 1.25,
					Volume = 0.375,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end,
			fist = function()
				fn10({
					SoundId = "rbxassetid://7543903290",
					Parent = folder.PrimaryPart,
					Volume = 0.9
				}):Play()
				fn10({
					SoundId = "rbxassetid://296072089",
					Parent = folder.PrimaryPart,
					Volume = 0.9
				}):Play()
				fn10({
					SoundId = "rbxassetid://8595975458",
					Parent = folder.PrimaryPart,
					Volume = 0.9
				}):Play()
				fn10({
					SoundId = "rbxassetid://12332220659",
					Volume = 0.5,
					PlaybackSpeed = 1.5,
					Parent = folder.PrimaryPart,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end,
			fist2 = function()
				fn10({
					SoundId = "rbxassetid://7515452875",
					Parent = folder.PrimaryPart,
					Volume = 0.75
				}):Play()
			end
		},
		Animation = 14056370647,
		Looped = false,
		Stun = "Slowed"
	}
	v5["Fancy Reading"] = {
		HideWeapon = true,
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16583992179",
				Volume = 1
			},
			[0.01] = {
				SoundId = "rbxassetid://9046455305",
				Volume = 0.4,
				Looped = true
			}
		},
		Startup = function(list, _, _)
			local clone = script.book:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			clone.Parent = folder
			local leftHandle = clone.LeftHandle
			leftHandle:SetAttribute("EmoteProperty", true)
			table.insert(list, leftHandle)
			leftHandle.RootPart.Part0 = leftHandle
			leftHandle.RootPart.Part1 = clone.RootPart
			leftHandle.Parent = folder
			local clone2 = script.monocle:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(list, clone2)
			local m6d = clone2.m6d
			m6d:SetAttribute("EmoteProperty", true)
			table.insert(list, m6d)
			m6d.Name = "Meshes/monocle_Cylinder.002"
			m6d.Part0 = folder.Head
			m6d.Part1 = clone2[m6d.Name]
			m6d.Parent = folder.Head
			clone2.Parent = folder.Head
			local m6d2 = clone.m6d
			m6d2:SetAttribute("EmoteProperty", true)
			table.insert(list, m6d2)
			m6d2.Name = "LeftHandle"
			m6d2.Part0 = folder["Left Arm"]
			m6d2.Part1 = leftHandle
			m6d2.Parent = folder["Left Arm"]
			clone.Parent = folder["Left Arm"]
		end,
		Animation = 16583901798,
		Idle = 16583918087,
		Looped = false,
		Stun = "Slowed"
	}
	v5["Rocket Ride"] = {
		HideWeapon = true,
		Sounds = {
			[0.01] = {
				SoundId = "rbxassetid://1837322223",
				Volume = 0.4,
				TimePosition = 0.5,
				Looped = true
			}
		},
		Startup = function(clones, _, _)
			local clone = script.rocket:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone)
			clone.Parent = folder

			for _, part in pairs(clone:GetChildren()) do
				if part.Name ~= "Rocket" and part:IsA("BasePart") then
					part.Transparency = 1
				end
			end

			local weld = Instance.new("Weld")
			weld.Part0 = folder.PrimaryPart
			weld.Part1 = clone.Base
			weld.C0 = CFrame.new(-0.0188751221, -2.70935678, 0.0000305175781, 0, 0, 1, 0, 1, 0, -1, 0, 0)
			weld.Parent = clone
			fn10({
				SoundId = "rbxassetid://9119414082",
				Parent = clone.Rocket,
				Volume = 0.3,
				Looped = true
			}):Play()
			local animation = Instance.new("Animation")
			animation.AnimationId = "rbxassetid://16584484676"
			clone.AnimationController:LoadAnimation(animation):Play()
		end,
		Animation = 16584466961,
		Looped = true,
		Stun = "Slowed",
		StunAttribute = 1
	}
	v5.Read = {
		Keyframes = {
			book = function()
				fn10({
					SoundId = "rbxassetid://7244593699",
					Parent = folder.PrimaryPart,
					Volume = 0.75
				}):Play()
				fn10({
					SoundId = "rbxassetid://4458782689",
					Parent = folder.PrimaryPart,
					Volume = 0.75
				}):Play()
			end,
			start = function(p4, clones)
				local clone = script.Book.BookRig:Clone()
				local clone2 = script.Book.MiddleCover:Clone()
				clone2.Part0 = folder["Left Arm"]
				clone2.Part1 = clone.MiddleCover
				clone2.Parent = folder["Left Arm"]
				clone.LeftCover.SurfaceGui.TextLabel.Text = folder.Name
				clone:SetAttribute("EmoteProperty", true)
				clone2:SetAttribute("EmoteProperty", true)
				clone.Parent = folder
				table.insert(clones, clone)
				table.insert(clones, clone2)
				p4.book = clone
				fn10({
					SoundId = "rbxassetid://12332220659",
					Volume = 0.3333333333333333,
					PlaybackSpeed = 1.5,
					Parent = folder.PrimaryPart,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
				fn10({
					SoundId = "rbxassetid://12981991293",
					Parent = folder.PrimaryPart,
					PlaybackSpeed = 1.25,
					Volume = 0.39999999999999997,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
				fn10({
					SoundId = "rbxassetid://13726870246",
					Parent = folder.PrimaryPart,
					Volume = 0.39999999999999997,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end,
			up = function()
				fn10({
					SoundId = "rbxassetid://4458775948",
					Parent = folder.PrimaryPart,
					Volume = 0.6
				}):Play()
			end,
			close = function()
				fn10({
					SoundId = "rbxassetid://3763472732",
					Parent = folder.PrimaryPart,
					Volume = 0.7
				}):Play()
			end,
			away = function()
				fn10({
					SoundId = "rbxassetid://3848838070",
					Parent = folder.PrimaryPart,
					Volume = 0.39999999999999997,
					PlaybackSpeed = 1.5
				}):Play()
			end,
			gone = function(p4)
				if p4.book then
					p4.book:Destroy()
				end
			end,
			swish1 = function()
				fn10({
					SoundId = "rbxassetid://4458759938",
					Parent = folder.PrimaryPart,
					Volume = 0.5,
					PlaybackSpeed = 1.15
				}):Play()
			end,
			swish2 = function()
				fn10({
					SoundId = "rbxassetid://3929467449",
					Parent = folder.PrimaryPart,
					Volume = 0.5,
					PlaybackSpeed = 1.35
				}):Play()
			end,
			swish3 = function()
				fn10({
					SoundId = "rbxassetid://3929467229",
					Parent = folder.PrimaryPart,
					Volume = 0.5,
					PlaybackSpeed = 1.25
				}):Play()
			end,
			swish4 = function()
				fn10({
					SoundId = "rbxassetid://4458759938",
					Parent = folder.PrimaryPart,
					Volume = 0.5,
					PlaybackSpeed = 1.25
				}):Play()
			end,
			step = function()
				fn10({
					SoundId = "rbxassetid://" .. ({ 7455224144, 7455246815, 7455224490 })[math.random(1, 3)],
					Parent = folder["Left Leg"],
					PlaybackSpeed = 1,
					Volume = 0.2,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end,
			step2 = function()
				fn10({
					SoundId = "rbxassetid://" .. ({ 7455224144, 7455246815, 7455224490 })[math.random(1, 3)],
					Parent = folder["Left Leg"],
					PlaybackSpeed = 1,
					Volume = 0.2,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end
		},
		Animation = 13735596559,
		Looped = false,
		Stun = "Freeze"
	}
	v5["4K"] = {
		Keyframes = {
			start = function(_, _, object2)
				object2:AdjustSpeed(2.25)
				fn10({
					SoundId = "rbxassetid://12332220659",
					Volume = 0.25,
					PlaybackSpeed = 1.85,
					Parent = folder.PrimaryPart,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end,
			pull = function(p4, clones, object2)
				object2:AdjustSpeed(1)
				fn10({
					SoundId = "rbxassetid://12981991293",
					Parent = folder.PrimaryPart,
					PlaybackSpeed = 1.25,
					Volume = 0.3,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
				fn10({
					SoundId = "rbxassetid://13726870246",
					Parent = folder.PrimaryPart,
					Volume = 0.3,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
				fn10({
					SoundId = "rbxassetid://873073853",
					Parent = folder.PrimaryPart,
					PlaybackSpeed = 1.25,
					Volume = 0.35,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
				local clone = script.Phone:Clone()
				table.insert(clones, clone)
				clone.Name = "PhoneEmote"
				clone:SetAttribute("EmoteProperty", true)
				clone.Parent = folder
				local weld = Instance.new("Weld")
				weld.Part0 = folder["Left Arm"]
				weld.Part1 = clone
				weld.C0 = CFrame.new(
					0.135000005,
					-1,
					-0.460000008,
					4.37113883e-8,
					3.82137093e-15,
					-1,
					8.74227766e-8,
					-1,
					0,
					-1,
					-8.74227766e-8,
					-4.37113883e-8
				)
				weld.Parent = clone
				p4.phone = clone
			end,
			away = function(p4, _, _)
				if p4.phone then
					p4.phone:Destroy()
				end
			end,
			done = function()
				fn10({
					SoundId = "rbxassetid://12332220659",
					Volume = 0.3333333333333333,
					PlaybackSpeed = 2,
					Parent = folder.PrimaryPart
				}):Play()
			end,
			snap = function(p4)
				if p4.phone then
					fn10({
						SoundId = "rbxassetid://8550763922",
						Parent = p4.phone.Attachment2,
						Volume = 0.5,
						PlaybackSpeed = 1.5,
						RollOffMaxDistance = rollOffMaxDistance
					}):Play()

					for _, emitter in pairs(p4.phone.Attachment2:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(1)
						end
					end
				end
			end
		},
		Animation = 13735352472,
		Looped = false,
		Stun = "Freeze"
	}
	v5["Hold On"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://16522927439",
				Volume = 1,
				PlaybackSpeed = 1
			}
		},
		Startup = function(list, _, p4)
			local clone = script.Phone:Clone()
			table.insert(list, clone)
			clone.Name = "Handle"
			clone.Transparency = 1
			clone:SetAttribute("EmoteProperty", true)
			clone.Parent = folder
			local motor6D = Instance.new("Motor6D")
			motor6D:SetAttribute("EmoteProperty", true)
			table.insert(list, motor6D)
			motor6D.Name = "Meshes/IPHONE12 MESH "
			motor6D.Part0 = folder["Right Arm"]
			motor6D.Part1 = clone
			motor6D.C0 = CFrame.new(
				-0.134792328,
				-0.986119986,
				-0.459802628,
				2.98023224e-8,
				-1.49011585e-8,
				1,
				2.98023224e-8,
				-1,
				-1.49011594e-8,
				1,
				2.98023224e-8,
				-2.98023224e-8
			)
			motor6D.Parent = folder["Right Arm"]
			p4.phone = clone
		end,
		Keyframes = {
			appear = function(p4)
				p4.phone.Transparency = 0
			end,
			disappear = function(p4)
				p4.phone:Destroy()
			end
		},
		Animation = 16522919821,
		Stun = "Freeze"
	}
	v5["On That Day"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://133608543934609",
				Volume = 1,
				PlaybackSpeed = 1
			}
		},
		Startup = function(clones, _, _)
			local clone = script.ArmSlap:Clone()
			clone.Parent = folder
			clone:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone)
			CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)

			for _, child in pairs(script.kjphone:GetChildren()) do
				local clone2 = child:Clone()
				clone2.Parent = folder.PrimaryPart
				clone2.Part0 = folder.PrimaryPart
				local v8 = tostring(child)
				local part = nil

				for _, descendant in pairs(clone:GetDescendants()) do
					if tostring(descendant) ~= v8 then
						continue
					end

					part = descendant
					break
				end

				clone2.Part1 = part
			end

			local Debris = game:GetService("Debris")
			Debris:AddItem(clone, 6.983)
		end,
		HideWeapon = true,
		Animation = 84515101199811,
		Looped = false,
		Stun = "Freeze"
	}
	v5["Selfie In Style"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://15091441859",
				Volume = 1,
				PlaybackSpeed = 1
			}
		},
		Startup = function(clones, _, p4)
			local clone = script.Phone:Clone()
			table.insert(clones, clone)
			clone.Name = "PhoneEmote"
			clone:SetAttribute("EmoteProperty", true)
			clone.Parent = folder
			local weld = Instance.new("Weld")
			weld.Part0 = folder["Left Arm"]
			weld.Part1 = clone
			weld.C0 = CFrame.new(
				0.135000005,
				-1,
				-0.460000008,
				4.37113883e-8,
				3.82137093e-15,
				-1,
				8.74227766e-8,
				-1,
				0,
				-1,
				-8.74227766e-8,
				-4.37113883e-8
			)
			weld.Parent = clone
			p4.phone = clone
		end,
		Keyframes = {
			selfie = function(p4)
				if p4.phone then
					fn10({
						SoundId = "rbxassetid://8550763922",
						Parent = p4.phone.Attachment,
						PlaybackSpeed = 1.2,
						Volume = 0.5,
						RollOffMaxDistance = rollOffMaxDistance
					}):Play()

					for _, emitter in pairs(p4.phone.Attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(1)
						end
					end
				end
			end,
			["end"] = function(p4)
				p4.phone:Destroy()
			end
		},
		Fix = true,
		Animation = 15091452031,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Selfie = {
		Keyframes = {
			start = function(_, _, object2)
				object2:AdjustSpeed(2.25)
				fn10({
					SoundId = "rbxassetid://12332220659",
					Volume = 0.5,
					PlaybackSpeed = 1.85,
					Parent = folder.PrimaryPart,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end,
			phone = function()
				fn10({
					SoundId = "rbxassetid://13726870246",
					Parent = folder.PrimaryPart,
					Volume = 0.6,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end,
			pull = function(p4, clones, object2)
				object2:AdjustSpeed(1)
				fn10({
					SoundId = "rbxassetid://12981991293",
					Parent = folder.PrimaryPart,
					PlaybackSpeed = 1.25,
					Volume = 0.6,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
				fn10({
					SoundId = "rbxassetid://873073853",
					Parent = folder.PrimaryPart,
					PlaybackSpeed = 1.25,
					Volume = 0.7,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
				local clone = script.Phone:Clone()
				table.insert(clones, clone)
				clone.Name = "PhoneEmote"
				clone:SetAttribute("EmoteProperty", true)
				clone.Parent = folder
				local weld = Instance.new("Weld")
				weld.Part0 = folder["Left Arm"]
				weld.Part1 = clone
				weld.C0 = CFrame.new(
					0.135000005,
					-1,
					-0.460000008,
					4.37113883e-8,
					3.82137093e-15,
					-1,
					8.74227766e-8,
					-1,
					0,
					-1,
					-8.74227766e-8,
					-4.37113883e-8
				)
				weld.Parent = clone
				p4.phone = clone
			end,
			away = function(_, _, object2)
				object2:AdjustSpeed(1.5)
			end,
			["2away"] = function(p4)
				if p4.phone then
					p4.phone:Destroy()
				end
			end,
			step = function()
				fn10({
					SoundId = "rbxassetid://" .. ({ 7455224144, 7455246815, 7455224490 })[math.random(1, 3)],
					Parent = folder["Left Leg"],
					PlaybackSpeed = 1,
					Volume = 0.2,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end,
			picture = function(p4)
				if p4.phone then
					fn10({
						SoundId = "rbxassetid://8550763922",
						Parent = p4.phone.Attachment,
						Volume = 0.5,
						PlaybackSpeed = 1.2,
						RollOffMaxDistance = rollOffMaxDistance
					}):Play()

					for _, emitter in pairs(p4.phone.Attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(1)
						end
					end
				end
			end
		},
		Animation = 13727204855,
		Looped = false,
		Stun = "Freeze"
	}
	v5.Fork = {
		Startup = function(list, _)
			local clone = script.Fork.RightGrip:Clone()
			table.insert(list, clone)
			local motor6D = Instance.new("Motor6D")
			motor6D.C0 = CFrame.new(
				-0.000549316406,
				-1.00001884,
				0.000057220459,
				-1.1920929e-7,
				1.00000012,
				0,
				1.00000012,
				-1.1920929e-7,
				0,
				0,
				0,
				-1.00000024
			)
			motor6D.Part0 = folder["Left Arm"]
			motor6D.Part1 = clone
			motor6D.Parent = clone
			clone.Parent = folder
			local clone2 = script.Fork.Fork:Clone()
			table.insert(list, clone2)
			clone.Fork.Part0 = clone
			clone:SetAttribute("EmoteProperty", true)
			clone.Fork.Part1 = clone2
			clone2:SetAttribute("EmoteProperty", true)
			clone2.Parent = folder
			local v8 = fn10({
				SoundId = "rbxassetid://13727102947",
				Volume = 0.4,
				Looped = true,
				Parent = clone2
			})
			table.insert(list, v8)
			v8:Play()
		end,
		Stun = "Slowed",
		Looped = true,
		Animation = 13727117367
	}
	v5.OK = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://13722809593",
				Volume = 1
			}
		},
		Startup = function()
			local clone = script.BillboardGui:Clone()
			clone.Enabled = true
			clone.Parent = folder.Head
			task.delay(2, function()
				game:service("TweenService"):Create(
					clone.ImageLabel,
					TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{
						ImageTransparency = 1
					}
				):Play()
			end)
			local Debris = game:GetService("Debris")
			Debris:AddItem(clone, 3)
		end,
		Animation = 0
	}
	v5.Sheathe = {
		Sounds = {},
		Startup = function()
			for _ = 1, 10 do
				local grabWeapon = folder:FindFirstChild("GrabWeapon")

				if grabWeapon then
					grabWeapon:Destroy()
				end
			end
		end,
		Cooldown = 7.5,
		Animation = 0
	}
	v5.L = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1846079994",
				Volume = 1,
				Looped = true
			},
			[0.01] = {
				SoundId = "rbxassetid://6906260279",
				Volume = 0.5
			}
		},
		Animation = 18231574269,
		Looped = true,
		Stun = "Slowed"
	}
	v5.Umbrella = {
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end,
			open = function(p4, _, _)
				local umbrella = p4.umbrella

				if not umbrella then
					return
				end

				game:service("TweenService"):Create(
					umbrella.TopUmbrella.Mesh,
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{
						Scale = createVector(1.1, 0.75, 1.1),
						Offset = createVector(0, 1, 0)
					}
				):Play()
			end
		},
		Startup = function(list, _, p4)
			fn10({
				SoundId = "rbxassetid://13875814315",
				Parent = folder.PrimaryPart,
				Volume = 2.5
			}):Play()
			local clone = script.Umbrella:Clone()
			table.insert(list, clone)
			clone:SetAttribute("EmoteProperty", true)
			local motor6D = clone:FindFirstChildOfClass("Motor6D")
			table.insert(list, motor6D)
			motor6D:SetAttribute("EmoteProperty", true)
			motor6D.Part0 = folder["Right Arm"]
			motor6D.Parent = folder["Right Arm"]
			motor6D.Part1 = clone.Handle
			clone.TopUmbrella.Mesh.Offset = createVector(0, 0, 0)
			clone.TopUmbrella.Mesh.Scale = createVector(0.1, 1.5, 0.1)
			clone.Parent = folder
			p4.umbrella = clone
		end,
		HideWeapon = true,
		Animation = 14056388573,
		Looped = false,
		Stun = "Slowed"
	}
	v5.Relax = {
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end,
			start = function()
				fn10({
					SoundId = "rbxassetid://12332099688",
					Volume = 1,
					Parent = folder.PrimaryPart
				}):Play()
				fn10({
					SoundId = "rbxassetid://13631231525",
					PlaybackSpeed = 1.25,
					Volume = 0.9
				}):Play()
				task.delay(0.4, function()
					fn10({
						SoundId = "rbxassetid://12332220659",
						Volume = 0.95,
						PlaybackSpeed = 1.85,
						Parent = folder.PrimaryPart,
						RollOffMaxDistance = rollOffMaxDistance
					}):Play()
					fn10({
						SoundId = "rbxassetid://4953436541",
						Volume = 1.15,
						PlaybackSpeed = 1.85,
						Parent = folder.PrimaryPart,
						RollOffMaxDistance = rollOffMaxDistance
					}):Play()
				end)
			end,
			step = function()
				fn10({
					SoundId = "rbxassetid://" .. ({ 7455224144, 7455246815, 7455224490 })[math.random(1, 3)],
					Parent = folder["Left Arm"],
					PlaybackSpeed = 1,
					Volume = 0.5,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end
		},
		Animation = 13736196609,
		Stun = "Freeze"
	}
	v5.Sleepy = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://14348081142",
				PlaybackSpeed = 1,
				Volume = 1.75
			}
		},
		Looped = false,
		Animation = 14348083862,
		Stun = "Freeze"
	}
	v5.Steps = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://9045623796",
				PlaybackSpeed = 1,
				Volume = 0.35,
				Looped = true
			}
		},
		Keyframes = {
			claploop = function(p4, _, _)
				if not p4.turn then
					p4.turn = 1
				end

				fn10({
					SoundId = p4.turn % 2 == 0 and "rbxassetid://14351823273" or "rbxassetid://14351823038",
					Parent = folder["Left Leg"],
					PlaybackSpeed = 1,
					Volume = 0.25,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
				p4.turn += 1
			end
		},
		Infinite = true,
		Looped = true,
		Animation = 14351868272,
		Stun = "Slowed"
	}
	v5.Saunter = {
		Sounds = {},
		Keyframes = {
			clap = function(_, _, _)
				fn10({
					SoundId = "rbxassetid://" .. ({ 7455224144, 7455246815, 7455224490 })[math.random(1, 3)],
					Parent = folder["Left Leg"],
					PlaybackSpeed = 1.25,
					Volume = 0.3,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end,
			claploop = function(_, _, _)
				fn10({
					SoundId = "rbxassetid://" .. ({ 7455224144, 7455246815, 7455224490 })[math.random(1, 3)],
					Parent = folder["Right Leg"],
					PlaybackSpeed = 1.25,
					Volume = 0.3,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end
		},
		HideWeapon = true,
		Infinite = true,
		Looped = true,
		Animation = 17086054994,
		Stun = "Slowed",
		StunAttribute = 1.5
	}
	v5["Silly Walk"] = {
		Sounds = {},
		Keyframes = {
			clap = function(p4, _, _)
				if not p4.num or p4.num > 2 then
					p4.num = 1
				end

				fn10({
					SoundId = "rbxassetid://" .. ({ 16584838006, 16584838984 })[p4.num],
					Parent = folder["Left Leg"],
					PlaybackSpeed = 1,
					Volume = 0.11
				}):Play()
				p4.num += 1
			end
		},
		Infinite = true,
		Looped = true,
		Animation = 16585974532,
		Stun = "Slowed",
		StunAttribute = 2
	}
	v5.Skewed = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1844765268",
				PlaybackSpeed = 1,
				Volume = 0.25,
				Looped = true
			}
		},
		Keyframes = {
			claploop = function(_, _, _)
				fn10({
					SoundId = "rbxassetid://" .. ({ 7455224144, 7455246815, 7455224490 })[math.random(1, 3)],
					Parent = folder["Left Leg"],
					PlaybackSpeed = 1,
					Volume = 0.8,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end
		},
		Startup = function()
			fn10({
				SoundId = "rbxassetid://" .. ({ 7455224144, 7455246815, 7455224490 })[math.random(1, 3)],
				Parent = folder["Left Leg"],
				PlaybackSpeed = 1,
				Volume = 0.8,
				RollOffMaxDistance = rollOffMaxDistance
			}):Play()
		end,
		Infinite = true,
		Looped = true,
		Animation = 14405440932,
		Stun = "Slowed"
	}
	v5.Groceries = {
		Sounds = {},
		Keyframes = {
			claploop = function(_, _, p4)
				fn10({
					SoundId = "rbxassetid://" .. ({ 7455224144, 7455246815, 7455224490 })[math.random(1, 3)],
					Parent = folder["Left Leg"],
					PlaybackSpeed = 1.25,
					Volume = 0.4,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
				task.delay(0.5, function()
					if p4.IsPlaying then
						fn10({
							SoundId = ({
								"rbxassetid://9125595581",
								"rbxassetid://9114663061",
								"rbxassetid://9114663248",
								"rbxassetid://9114662567"
							})[math.random(1, 4)],
							Volume = 0.2,
							Parent = folder["Left Arm"]
						}):Play()
					end
				end)
			end
		},
		Startup = function(list, _, _)
			local clone = script.Grocery:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			clone.Name = "Handle"
			local handle = clone.Handle
			handle:SetAttribute("EmoteProperty", true)
			table.insert(list, handle)
			handle.Name = "Handle"
			handle.Part0 = folder["Left Arm"]
			handle.Part1 = clone
			handle.Parent = folder["Left Arm"]
			clone.Parent = folder["Left Arm"]
		end,
		Infinite = true,
		Looped = true,
		Animation = 15237948811,
		Stun = "Slowed"
	}
	v5["Happy Steps"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1846012134",
				Volume = 0.35,
				Looped = true
			}
		},
		Keyframes = {
			clap = function(_, _, _)
				fn10({
					SoundId = ({ "rbxassetid://16002610872", "rbxassetid://16002610798", "rbxassetid://16002610939" })[math.random(
						1,
						3
					)],
					Parent = folder["Left Leg"],
					Volume = 0.25
				}):Play()
			end
		},
		Startup = function(clones, _, _)
			local clone = script.Stars:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone)
			clone.Parent = folder.Torso
		end,
		Infinite = true,
		Looped = true,
		Animation = 16021093085,
		Stun = "Slowed",
		StunAttribute = 1.75
	}
	v5.Soda = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://1844765268",
				PlaybackSpeed = 1,
				Volume = 0.25,
				Looped = true
			}
		},
		Keyframes = {
			claploop = function(_, _, _)
				fn10({
					SoundId = "rbxassetid://" .. ({ 7455224144, 7455246815, 7455224490 })[math.random(1, 3)],
					Parent = folder["Left Leg"],
					PlaybackSpeed = 1,
					Volume = 0.8,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end
		},
		Startup = function(clones)
			local clone = script.Cola.Handle:Clone()
			clone:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone)
			local clone2 = script.Cola.M6D:Clone()
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(clones, clone2)
			clone2.Name = "Handle"
			clone2.Part0 = folder["Left Arm"]
			clone2.Part1 = clone
			clone2.Parent = folder["Left Arm"]
			clone.Parent = folder
			fn10({
				SoundId = "rbxassetid://" .. ({ 7455224144, 7455246815, 7455224490 })[math.random(1, 3)],
				Parent = folder["Left Leg"],
				PlaybackSpeed = 1,
				Volume = 0.8,
				RollOffMaxDistance = rollOffMaxDistance
			}):Play()
			fn10({
				SoundId = ({ "rbxassetid://10721950", "rbxassetid://10722059" })[math.random(1, 2)],
				Parent = folder.PrimaryPart,
				Volume = 0.35
			}):Play()
		end,
		Infinite = true,
		Looped = true,
		Animation = 14352383313,
		Stun = "Slowed"
	}
	v5["Anything To Look Cool"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://131225278629242",
				Volume = 1
			}
		},
		Keyframes = {},
		Animation = 82694531595019,
		Stun = "Freeze"
	}
	v5["K.O"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://116622800082209",
				Volume = 1
			}
		},
		Keyframes = {},
		Animation = 113991685821848,
		Stun = "Freeze"
	}
	v5.Train = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://92097736113843",
				Volume = 1
			}
		},
		Keyframes = {},
		Animation = 87360104656237,
		Stun = "Freeze"
	}
	v5.Behold = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://84936624374846",
				Volume = 1
			}
		},
		Keyframes = {},
		Animation = 119727504197041,
		Idle = 121985820220625,
		Stun = "Freeze"
	}
	v5.Bow = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://12332099688",
				PlaybackSpeed = 0.8,
				Volume = 1
			},
			[0.5] = {
				SoundId = "rbxassetid://12981991293",
				Volume = 0.5,
				PlaybackSpeed = 0.8
			}
		},
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		Animation = 13773998974,
		Stun = "Freeze"
	}
	v5.Kneel = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://12332099688",
				Volume = 1
			},
			[0.25] = {
				SoundId = "rbxassetid://12332220659",
				Volume = 0.5,
				PlaybackSpeed = 2
			},
			[0.26] = {
				SoundId = "rbxassetid://13631231525",
				PlaybackSpeed = 1.25,
				Volume = 0.9
			}
		},
		Keyframes = {
			freeze = function(_, _, object2)
				object2:AdjustSpeed(0)
			end
		},
		Animation = 13721154327,
		Stun = "Freeze"
	}
	v5.Confused = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://12332099688",
				Volume = 0.6,
				PlaybackSpeed = 0.9
			}
		},
		Keyframes = {
			look = function()
				fn10({
					SoundId = "rbxassetid://5031986894",
					Parent = folder.PrimaryPart,
					Volume = 0.65,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end,
			step = function()
				fn10({
					SoundId = "rbxassetid://" .. ({ 7455224144, 7455246815, 7455224490 })[math.random(1, 3)],
					Parent = folder["Left Leg"],
					PlaybackSpeed = 1,
					Volume = 0.2,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end,
			step2 = function()
				fn10({
					SoundId = "rbxassetid://" .. ({ 7455224144, 7455246815, 7455224490 })[math.random(1, 3)],
					Parent = folder["Left Leg"],
					PlaybackSpeed = 1,
					Volume = 0.3,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end,
			step3 = function()
				fn10({
					SoundId = "rbxassetid://" .. ({ 7455224144, 7455246815, 7455224490 })[math.random(1, 3)],
					Parent = folder["Left Leg"],
					PlaybackSpeed = 1,
					Volume = 0.3,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end,
			cloth = function()
				fn10({
					SoundId = "rbxassetid://12982203916",
					Parent = folder.PrimaryPart,
					Volume = 0.35,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end,
			cloth2 = function()
				fn10({
					SoundId = "rbxassetid://12981981352",
					Parent = folder.PrimaryPart,
					Volume = 0.35,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end
		},
		Animation = 13735938143,
		Stun = "Freeze",
		Looped = false
	}
	v5.Crush = {
		Keyframes = {
			start = function()
				fn10({
					SoundId = "rbxassetid://12981991293",
					Parent = folder.PrimaryPart,
					Volume = 0.3,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end,
			point = function()
				fn10({
					SoundId = "rbxassetid://13631231525",
					Parent = folder.PrimaryPart,
					Volume = 0.9,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end,
			cloth2 = function()
				fn10({
					SoundId = "rbxassetid://12982203916",
					Parent = folder.PrimaryPart,
					Volume = 0.3,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
				task.delay(0.5, function()
					fn10({
						SoundId = "rbxassetid://13716998561",
						Parent = folder.PrimaryPart,
						Volume = 2,
						RollOffMaxDistance = rollOffMaxDistance
					}):Play()
				end)
			end,
			distort = function() end,
			snap = function()
				fn10({
					SoundId = "rbxassetid://9125818080",
					Parent = folder.PrimaryPart,
					Volume = 0.9,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
				fn10({
					SoundId = "rbxassetid://9113542363",
					Parent = folder.PrimaryPart,
					Volume = 0.8,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
				fn10({
					SoundId = "rbxassetid://13717046717",
					Parent = folder.PrimaryPart,
					Volume = 1,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end,
			step = function()
				fn10({
					SoundId = "rbxassetid://" .. ({ 7455224144, 7455246815, 7455224490 })[math.random(1, 3)],
					Parent = folder["Left Leg"],
					PlaybackSpeed = 1,
					Volume = 0.2,
					RollOffMaxDistance = rollOffMaxDistance
				}):Play()
			end
		},
		Animation = 13716964686,
		Looped = false,
		Stun = "Freeze"
	}
	v5["Great Sun"] = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://98894698386316",
				Volume = 1.2
			}
		},
		Animation = 136339287971184,
		Idle = 88169856864853,
		Looped = false,
		Stun = "Freeze",
		Startup = function(list, _, p4)
			local clone = script.GreatSun.floorpart:Clone()
			clone.CFrame = folder:GetPivot() * CFrame.new(0, -2.9, 0)
			clone.Parent = workspace.Thrown
			local clone2 = script.GreatSun.cruelsun:Clone()
			clone2.fx.PointLight.Brightness = 0
			clone2.fx.PointLight.Range = 0
			clone2.Size = createVector(0, 0, 0)
			clone2.CFrame = folder:GetPivot() * CFrame.new(-2.137481689453125, 10.601249694824219, 0.0050048828125)
			clone2.Parent = workspace.Thrown
			clone2.Anchored = false
			local weld = Instance.new("Weld")
			weld.Part0 = folder.PrimaryPart
			weld.Part1 = clone2
			weld.C0 = CFrame.new(-2.137481689453125, 10.601249694824219, 0.0050048828125)
			weld.Parent = clone2
			table.insert(list, weld)
			clone:SetAttribute("EmoteProperty", true)
			table.insert(list, clone)
			clone2:SetAttribute("EmoteProperty", true)
			table.insert(list, clone2)
			p4.Sun = clone2
			p4.Floor = clone
		end,
		Keyframes = {
			startup = function(p4)
				p4.Sun.SunLoop:Play()
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(p4.Sun.SunLoop, TweenInfo.new(1), {
					Volume = 1
				}):Play()
				local TweenService3 = game:GetService("TweenService")
				TweenService3:Create(p4.Sun, TweenInfo.new(1), {
					Size = createVector(11.403, 11.403, 11.403)
				}):Play()
				local TweenService4 = game:GetService("TweenService")
				TweenService4:Create(p4.Sun.fx.PointLight, TweenInfo.new(1), {
					Brightness = 4,
					Range = 25
				}):Play()

				for _, emitter in pairs(p4.Sun:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				for _, emitter in pairs(p4.Floor:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end
		}
	}
	v5.Jersey = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://73760246801573",
				Volume = 0.85,
				Looped = true,
				ParentTorso = true
			}
		},
		Looped = true,
		Animation = 122201836324869,
		Stun = "Slowed",
		StunAttribute = 3,
		HideWeapon = true
	}
	v5.Tbot = {
		Sounds = {
			[0] = {
				SoundId = "rbxassetid://86534796182153",
				Volume = 0.85,
				Looped = true,
				ParentTorso = true
			}
		},
		Looped = true,
		Animation = 140261722754960,
		Stun = "Slowed",
		StunAttribute = 2,
		HideWeapon = true
	}
	result = v5
	local v8 = {
		BigSlash = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://103835306879590",
					Volume = 3,
					Looped = true
				}
			},
			Startup = function(list)
				shared.cfolder({
					Name = "SlashCd",
					Parent = folder
				}, 15)
				local accessory = Instance.new("Accessory")
				accessory.Name = "#EmoteHolder_" .. math.random(1, 100000)
				accessory.Parent = folder
				accessory:SetAttribute("EmoteProperty", true)
				table.insert(list, accessory)
				game.ReplicatedStorage.Replication:FireAllClients({
					Type = "ReplicateEmoteVfx",
					Character = folder,
					vfxName = "HugeSlash",
					EmoteBind = accessory,
					AnimSent = result.Animation,
					CanRotate = true
				})
				local connection = result.RealAnimation:GetMarkerReachedSignal("fifth"):Once(function()
					if not (accessory and accessory.Parent) then
						return
					end

					local cFrame = folder.PrimaryPart.CFrame
					folder:SetAttribute("ForcedCFrame", cFrame)
					local part = Instance.new("Part")
					game.Debris:AddItem(part, 1)
					part.Size = createVector(55, 35, 10)
					part.Transparency = 1
					part.BrickColor = BrickColor.new("Really red")
					part.Parent = workspace.Thrown
					part.Anchored = true
					part.CanCollide = false
					part.CanQuery = false
					part.CanTouch = false
					part.CFrame = cFrame * CFrame.new(0, -10, -4)
					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(part, TweenInfo.new(0.19, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
						CFrame = cFrame * CFrame.new(0, -10, -114)
					}):Play()
					local parents = {}
					local parents2 = {}

					local function fn15(_)
						local partsInPart = workspace:GetPartsInPart(part, OverlapParams.new())
						local parents3 = {}

						for _, original in pairs(partsInPart) do
							if original.Parent.Name == "Bench" or original.Parent.Name == "Trashcan" or original:GetAttribute("Destructible") then
								shared.BreakModel({
									Effect = "Break Model",
									Original = original,
									Velocity = math.random(12, 22) * 1.25
								})
							end

							if (original:GetAttribute("IsTree") or original.Name == "TreeRoot") and not table.find(
								parents2,
								original.Parent.Parent
							) then
								shared.BreakModel({
									Effect = "Break Model",
									Original = original.Parent.Parent,
									Velocity = math.random(50, 70)
								})
								table.insert(parents2, original.Parent.Parent)
							end

							local humanoid = original.Parent:FindFirstChildOfClass("Humanoid")
							local forceField = original.Parent:FindFirstChildOfClass("ForceField")

							if not humanoid or humanoid.Name == "FakeHumanoid" or (forceField or table.find(
								parents3,
								humanoid.Parent
							)) then
								continue
							end

							if humanoid == folder.Humanoid or table.find(parents, humanoid.Parent) then
								continue
							end

							table.insert(parents3, humanoid.Parent)
							table.insert(parents, humanoid.Parent)
						end

						return parents3
					end

					local lastTime = tick()

					while task.wait() and part and part.Parent and accessory and accessory.Parent and tick() - lastTime <= 1 do
						local v9 = fn15()

						if not v9 then
							continue
						end

						for _, folder2 in pairs(v9) do
							local humanoid = folder2:FindFirstChild("Humanoid")
							local humanoidRootPart = folder2:FindFirstChild("HumanoidRootPart")

							if not (humanoid.Health <= 0) then
								continue
							end

							folder2:SetAttribute("LimbsExploded", true)
							local v10 = {}

							for _, accessory2 in pairs(folder2:GetDescendants()) do
								if not (accessory2:IsA("Accessory") and accessory2.Parent:IsA("Part")) then
									continue
								end

								local handle = accessory2:FindFirstChild("Handle")

								if handle then
									v10[handle] = folder2.Head.CFrame:toObjectSpace(handle.CFrame)
								end
							end

							shared.sfx({
								SoundId = "rbxassetid://74053599625174",
								Volume = 5,
								CFrame = humanoidRootPart.CFrame
							}):Play()

							if shared.p(folder2) then
								game.ReplicatedStorage.Replication:FireClient(shared.p(folder2), {
									Effect = "Camshake",
									Intensity = 5,
									Last = 0.15
								})
							end

							for _, descendant in pairs(folder2:GetDescendants()) do
								if descendant:IsA("BallSocketConstraint") or descendant:IsA("Weld") then
									descendant:Destroy()
								end
							end

							for k, C0 in pairs(v10) do
								local weld = Instance.new("Weld")
								weld.Part0 = folder2.Head
								weld.Part1 = k
								weld.C0 = C0
								weld.Parent = k
							end

							for _, part2 in pairs(folder2:GetChildren()) do
								if not part2:IsA("Part") then
									continue
								end

								local bodyVelocity = Instance.new("BodyVelocity")
								bodyVelocity.MaxForce = createVector(40000, 40000, 40000)
								local v11 = -25
								local v12 = 25

								if not v12 and v11 then
									v12 = v11
									v11 = 1
								end

								if not (v12 or v11) then
									v11 = 0
									v12 = 1
								end

								local number = random:NextNumber(v11, v12)
								local v13 = 3
								local v14 = 10

								if not v14 and v13 then
									v14 = v13
									v13 = 1
								end

								if not (v14 or v13) then
									v13 = 0
									v14 = 1
								end

								bodyVelocity.Velocity = Vector3.new(
									number,
									random:NextNumber(v13, v14) * 5,
									fn12(-25, 25)
								)
								bodyVelocity.Parent = part2
								local Debris = game:GetService("Debris")
								Debris:AddItem(bodyVelocity, 0.15)
								local parent = part2
								task.delay(0.25, function()
									if parent.Name:find("Head") or parent.Name:find("Leg") or parent.Name:find("Arm") or parent.Name == "Torso" then
										local lastTime2 = tick()

										repeat
											task.wait()
										until tick() - lastTime2 > 5 or fn11({
											orig = parent.Position,
											dir = createVector(0, -2, 0)
										})

										if tick() - lastTime2 > 5 then
											return
										end

										parent.Velocity = Vector3.new()
										shared.sfx({
											SoundId = ({
												"rbxassetid://11714811219",
												"rbxassetid://11714811286",
												"rbxassetid://11714811320"
											})[math.random(1, 3)],
											Volume = 0.9,
											Parent = parent
										}):Play()
									end
								end)
							end
						end
					end
				end)
				table.insert(list, connection)
				task.delay(4, function()
					if connection then
						return connection:Disconnect()
					end
				end)
			end,
			Animation = 120001337057214,
			Stun = "Freeze"
		},
		["slice combo"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://113267998039039",
					Volume = 1.65,
					ParentTorso = true
				}
			},
			Startup = function(_, _, _) end,
			Animation = 95171537920426,
			HideWeapon = true,
			CanRotate = true,
			Stun = "Freeze",
			KillEmote = true
		},
		["My Brother"] = {
			Preview = 139398292577347,
			Cooldown = 10,
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://104813362309681",
					ParentTorso = true,
					Volume = 1
				},
				[0.01] = {
					SoundId = "rbxassetid://103206475338370",
					ParentTorso = true,
					Volume = 0.8
				}
			},
			Startup = function(list, _, p4)
				local clone = script.RockThrow:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.rock = clone
				clone.Name = "Rock"
				local rock = clone.Rock
				rock:SetAttribute("EmoteProperty", true)
				table.insert(list, rock)
				rock.Name = clone.Name
				rock.Part0 = folder.PrimaryPart
				rock.Part1 = clone
				rock.Parent = folder.PrimaryPart
				clone.Parent = folder
				task.delay(0.573, function()
					if not clone.Parent then
						return
					end

					fn10({
						SoundId = "rbxassetid://91571189388577",
						Parent = clone,
						Volume = 1,
						RollOffMaxDistance = rollOffMaxDistance
					}):Play()
				end)
				spawn(function()
					if playerFromCharacter then
						tick()
						local ids = {}
						local v9 = playerFromCharacter
						local v10

						if friendcache[v9] then
							v10 = friendcache[v9]
						end

						if not v10 and #ids == 0 then
							local function iterPageItems(object2)
								return coroutine.wrap(function()
									local v11 = 1

									while true do
										for _, v12 in ipairs(object2:GetCurrentPage()) do
											coroutine.yield(v12, v11)
										end

										if object2.IsFinished then
											break
										end

										object2:AdvanceToNextPageAsync()
										v11 += 1
									end
								end)
							end

							local Players = game:GetService("Players")
							local friendsAsync = Players:GetFriendsAsync(playerFromCharacter.UserId)

							for k, _ in coroutine.wrap(function()
								local v11 = 1

								while true do
									for _, v12 in ipairs(friendsAsync:GetCurrentPage()) do
										coroutine.yield(v12, v11)
									end

									if friendsAsync.IsFinished then
										break
									end

									friendsAsync:AdvanceToNextPageAsync()
									v11 += 1
								end
							end) do
								table.insert(ids, k.Id)
							end

							if #ids > 0 then
								friendcache[playerFromCharacter] = ids
							end
						end
					end
				end)
			end,
			Keyframes = {
				swap = function(p4, _, _, _)
					local v9 = playerFromCharacter
					local v10

					if friendcache[v9] then
						v10 = friendcache[v9]
					end

					local id

					if v10 then
						id = v10[math.random(1, #v10)]
					end

					game.ReplicatedStorage.Replication:FireAllClients({
						Effect = "Best Brother",
						char = folder,
						Id = id
					})
					p4.rock.Transparency = 1
				end
			},
			MeleeEffects = true,
			Limited = true,
			Idle = 118178916008905,
			HideWeapon = true,
			Animation = 123464270068243,
			Stun = "Freeze"
		},
		["The Strongest"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://117787451950766",
					Volume = 2
				},
				[0.01] = {
					SoundId = "rbxassetid://97998065677521",
					Volume = 1.85
				},
				[2.29] = {
					SoundId = "rbxassetid://99535007576182",
					Looped = true,
					Volume = 2
				}
			},
			Idle = 122796282584425,
			Preview = 122083813038650,
			Animation = 86505219150915,
			HideWeapon = true,
			Stun = "Freeze",
			Limited = true,
			MeleeEffects = true,
			Startup = function(list, _, _, _, _)
				fn(folder)
				local cfolder = shared.cfolder({
					Name = "PrideBind",
					Parent = folder
				})
				cfolder:SetAttribute("EmoteProperty", true)
				table.insert(list, cfolder)
				game.ReplicatedStorage.Replication:FireAllClients({
					Type = "ReplicateEmoteVfx",
					Character = folder,
					EmoteBind = cfolder,
					vfxName = "Boss Raid",
					AnimSent = result.Animation,
					CanRotate = true
				})
				cfolder.Destroying:Once(function()
					local sfxes = {}

					for _, parent in pairs({ folder["Right Arm"], folder["Left Arm"] }) do
						local sfx = shared.sfx({
							SoundId = "rbxassetid://85969902040488",
							Volume = 0.1,
							Parent = parent,
							Looped = true,
							PlaybackSpeed = Random.new():NextNumber(0.9, 1.1)
						})
						sfx:Play("")
						table.insert(sfxes, sfx)
					end

					for _, child in pairs(script.TheStrongestEmote:GetChildren()) do
						local parent = folder[tostring(child)]
						local count = 0
						local v10 = false

						for _, child2 in pairs(child:GetChildren()) do
							local clone = child2:Clone()
							clone.Parent = parent

							if count < 2 then
								count += 1
								clone:GetPropertyChangedSignal("Parent"):Once(function()
									for _, v11 in pairs(sfxes) do
										v11:Destroy("")
									end
								end)
							end

							if not (not v10 and clone:IsA("Attachment") and tostring(child) == "Left Arm" or tostring(child) == "Right Arm") then
								continue
							end

							v10 = true
						end
					end

					local dismantleEffect = folder:FindFirstChild("DismantleEffect")

					if dismantleEffect then
						dismantleEffect:Destroy()
					end

					local accessory = Instance.new("Accessory")
					accessory.Name = "DismantleEffect"
					accessory.Parent = folder
					accessory:SetAttribute("EmoteEffect", true)
					accessory:SetAttribute("Custom", "Divergence")
				end)
			end
		},
		["The Fallen"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://93369149563360",
					Volume = 2,
					ParentTorso = true
				}
			},
			MeleeEffects = true,
			Idle = 120130979195929,
			Animation = 133818134745501,
			Preview = 117269959657192,
			HideWeapon = true,
			Stun = "Freeze",
			Limited = true,
			Startup = function(list, _, _)
				local dismantleEffect = folder:FindFirstChild("DismantleEffect")

				if dismantleEffect and dismantleEffect:GetAttribute("Interactable") then
					Emotes:Play(folder, "BigSlash", nil, nil, true)
					dismantleEffect:SetAttribute("Interactable", false)
				else
					fn(folder)
					local cfolder = shared.cfolder({
						Name = "PrideBind",
						Parent = folder
					})
					cfolder:SetAttribute("EmoteProperty", true)
					table.insert(list, cfolder)
					game.ReplicatedStorage.Replication:FireAllClients({
						Type = "ReplicateEmoteVfx",
						Character = folder,
						vfxName = "Pride",
						EmoteBind = cfolder,
						AnimSent = result.Animation,
						CanRotate = true
					})
					local dismantleEffect2 = folder:FindFirstChild("DismantleEffect")

					if dismantleEffect2 then
						dismantleEffect2:Destroy()
					end

					local accessory = Instance.new("Accessory")
					accessory.Name = "DismantleEffect"
					accessory:SetAttribute("Interactable", true)
					accessory:SetAttribute("EmoteEffect", true)
					accessory:SetAttribute("Fallen", true)
					accessory.Parent = folder
				end
			end
		},
		Nightchild = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://89198363635558",
					Volume = 1,
					Looped = true
				},
				[0.01] = {
					SoundId = "rbxassetid://107426550092076",
					Volume = 1,
					Looped = true
				}
			},
			Startup = function(list, _, _)
				local clone = script.GlitcherModel:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				clone.Parent = workspace.Thrown
				clone.Parent = folder
				local primary1 = clone.Primary1
				primary1:SetAttribute("EmoteProperty", true)
				table.insert(list, primary1)
				CollectionService2:AddTag(primary1, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				primary1.Parent = workspace.Thrown
				primary1.Part0 = folder.Torso
				primary1.Part1 = clone.PrimaryPart
				primary1.Parent = folder.Torso
				primary1.Name = "Primary"
				local clone2 = script.AuraBox:Clone()
				clone2:SetAttribute("EmoteProperty", true)
				table.insert(list, clone2)
				CollectionService2:AddTag(clone2, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				clone2.Parent = workspace.Thrown
				clone2.Anchored = false
				local weld = Instance.new("Weld")
				weld.C0 = CFrame.new(-0.0500144958, 3.30000019, 0.250011444, 1, 0, 0, 0, 1, 0, 0, 0, 1)
				weld.Part0 = folder.PrimaryPart
				weld.Part1 = clone2
				weld.Parent = clone2

				for _, part in pairs(folder:GetChildren()) do
					if not part:IsA("BasePart") then
						continue
					end

					for _, child in pairs(script.StartGlitch:GetChildren()) do
						local clone3 = child:Clone()
						clone3.Parent = part
						clone3:SetAttribute("EmoteProperty", true)
						table.insert(list, clone3)
						CollectionService2:AddTag(
							clone3,
							"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
						)
						clone3.Parent = workspace.Thrown
					end
				end
			end,
			Keyframes = {
				burst = function()
					local clone = script.BurstEffect:Clone()
					game.Debris:AddItem(clone, 3)
					clone.Parent = workspace.Thrown
					clone.CFrame = folder.PrimaryPart.CFrame * CFrame.new(
						-0.0000133514404,
						2.79999971,
						-0.199993134,
						1,
						0,
						0,
						0,
						1,
						0,
						0,
						0,
						1
					)
					fn2(clone)
				end
			},
			Animation = 73949048256257,
			HideWeapon = true,
			Stun = "Slowed",
			StunAttribute = 1.5,
			Looped = true,
			Infinite = true,
			DontDisconnectMarkers = true
		},
		["Eternal Seal"] = {
			Preview = 88190176825744,
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://79605009444651",
					ParentTorso = true,
					Volume = 2
				}
			},
			Keyframes = {
				one = function(p4, _, _, _)
					p4.sound.Parent = p4.strings:FindFirstChild("1_001", true)
				end,
				two = function(p4, _, _, _)
					p4.sound.Parent = p4.realmp.RealmPrismPart
				end
			},
			Startup = function(list, _, p4)
				local clone = script.PrisonRealmRig:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				CollectionService2:AddTag(clone, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				clone.Parent = workspace.Thrown
				local clone2 = script.RealmPrism:Clone()
				clone2:SetAttribute("EmoteProperty", true)
				table.insert(list, clone2)
				CollectionService2:AddTag(clone2, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				clone2.Parent = workspace.Thrown
				local clone3 = script.Strings:Clone()
				clone3:SetAttribute("EmoteProperty", true)
				table.insert(list, clone3)
				CollectionService2:AddTag(clone3, "emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
				clone3.Parent = workspace.Thrown

				for _, v9 in pairs({ clone, clone2, unpack(clone3:GetChildren()) }) do
					v9.PrimaryPart.Anchored = false
					local weld = Instance.new("Weld")
					weld.Part0 = folder.PrimaryPart
					weld.Part1 = v9.PrimaryPart
					weld.C0 = v9:GetAttribute("Offset")
					weld.Parent = v9.PrimaryPart
				end

				p4.realmp = clone2
				p4.strings = clone3
				local sound = fn10({
					SoundId = "rbxassetid://116434570262349",
					Parent = clone:FindFirstChild("Bone_L", true),
					Volume = 2
				})
				p4.sound = sound
				sound:Play()
				local animation = Instance.new("Animation")
				animation.AnimationId = "rbxassetid://132931842051377"
				local track = clone.AnimationController:LoadAnimation(animation)
				track:Play()
				table.insert(list, track)
				local animation2 = Instance.new("Animation")
				animation2.AnimationId = "rbxassetid://73313263538976"
				local track2 = clone2.Humanoid:LoadAnimation(animation2)
				track2:Play()
				table.insert(list, track2)

				for k, v10 in pairs({
					115400109213203,
					129152881643120,
					116148929833466,
					106613129685108,
					85535076926939,
					136688312702757
				}) do
					local animation3 = Instance.new("Animation")
					animation3.AnimationId = "rbxassetid://" .. v10
					local track3 = clone3["String" .. k].AnimationController:LoadAnimation(animation3)
					track3:Play()
					table.insert(list, track3)
				end

				local cube_2 = clone.Cube_2
				local cube_finals = clone.Cube_finals
				local OPEN = clone.OPEN
				local CIRCLE_001 = clone.CIRCLE_001
				local sphere_001 = clone.Sphere_001
				local realmPrismPart = clone2.RealmPrismPart
				local eye_014 = clone3.String4.Eye_014
				local cube_001 = clone3.String2.Cube_001
				local cube_0012 = clone3.String6.Cube_001
				local eye_0142 = clone3.String6.Eye_014
				local eye_0143 = clone3.String1.Eye_014
				local cube_0013 = clone3.String3.Cube_001
				local cube_0014 = clone3.String1.Cube_001
				local eye_0144 = clone3.String2.Eye_014
				local eye_0145 = clone3.String3.Eye_014
				local cube_0015 = clone3.String4.Cube_001
				local cube_0016 = clone3.String5.Cube_001
				local eye_0146 = clone3.String5.Eye_014
				local talismanmesh = clone.Talismanmesh
				task.delay(3.667, function()
					if not clone.Parent then
						return
					end

					clone.RootPart.PrismRootPart.Talisman.ParticleEmitter:Emit(1)
				end)
				realmPrismPart.Transparency = 1
				realmPrismPart.Size = createVector(0.01, 0.01, 0.01)
				eye_014.Transparency = 1
				eye_014.Size = createVector(0.01, 0.01, 0.01)
				cube_001.Transparency = 1
				cube_001.Size = createVector(0.01, 0.01, 0.01)
				eye_0143.Transparency = 1
				eye_0143.Size = createVector(0.01, 0.01, 0.01)
				eye_0142.Transparency = 1
				cube_0013.Transparency = 1
				cube_0013.Size = createVector(0.01, 0.01, 0.01)
				eye_0146.Transparency = 1
				eye_0146.Size = createVector(0.01, 0.01, 0.01)
				cube_0012.Transparency = 1
				eye_0145.Transparency = 1
				eye_0145.Size = createVector(0.01, 0.01, 0.01)
				cube_0016.Transparency = 1
				cube_0016.Size = createVector(0.01, 0.01, 0.01)
				eye_0144.Transparency = 1
				eye_0144.Size = createVector(0.01, 0.01, 0.01)
				cube_0014.Transparency = 1
				cube_0014.Size = createVector(0.01, 0.01, 0.01)
				cube_0015.Transparency = 1
				cube_0015.Size = createVector(0.01, 0.01, 0.01)
				OPEN.Transparency = 1
				OPEN.Size = createVector(1.1759775, 1.1805156, 0.5182548)
				cube_finals.Transparency = 1
				cube_finals.Size = createVector(1.5681943, 1.5681939, 0.40960672)
				cube_2.Transparency = 1
				cube_2.Size = createVector(1.5681942, 1.5681938, 0.66054153)
				sphere_001.Transparency = 1
				sphere_001.Size = createVector(0.54944634, 0.54944646, 0.54944646)
				CIRCLE_001.Transparency = 1
				CIRCLE_001.Size = createVector(0.4889227, 0.43917945, 0.20095001)
				realmPrismPart.Size = createVector(0.01, 0.01, 0.01)
				task.delay(9.15, function()
					TweenService:Create(
						realmPrismPart,
						TweenInfo.new(0.01666666666666572, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					):Play()
				end)
				task.delay(9.166666666666666, function()
					TweenService:Create(
						realmPrismPart,
						TweenInfo.new(0.016666666666667496, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(3.34, 3.312, 3.316)
						}
					):Play()
				end)
				task.delay(9.183333333333334, function()
					TweenService:Create(
						realmPrismPart,
						TweenInfo.new(0.049999999999998934, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(1.6697042, 1.6561147, 1.6576525)
						}
					):Play()
				end)
				task.delay(9.233333333333333, function()
					TweenService:Create(
						realmPrismPart,
						TweenInfo.new(0.11666666666666714, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(1.063, 2, 1.057)
						}
					):Play()
				end)
				task.delay(9.35, function()
					TweenService:Create(
						realmPrismPart,
						TweenInfo.new(0.2833333333333332, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(0.5, 0.5, 0.5)
						}
					):Play()
				end)
				task.delay(9.633333333333333, function()
					TweenService:Create(
						realmPrismPart,
						TweenInfo.new(3.6500000000000004, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					):Play()
				end)
				task.delay(13.283333333333333, function()
					TweenService:Create(
						realmPrismPart,
						TweenInfo.new(0.016666666666667496, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end)
				task.delay(6.85, function()
					TweenService:Create(
						eye_014,
						TweenInfo.new(0.016666666666666607, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
					TweenService:Create(
						cube_001,
						TweenInfo.new(0.016666666666666607, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
					TweenService:Create(
						eye_0143,
						TweenInfo.new(0.016666666666666607, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
					TweenService:Create(
						eye_0142,
						TweenInfo.new(0.016666666666666607, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
					TweenService:Create(
						cube_0013,
						TweenInfo.new(0.016666666666666607, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
					TweenService:Create(
						eye_0146,
						TweenInfo.new(0.016666666666666607, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
					TweenService:Create(
						cube_0012,
						TweenInfo.new(0.016666666666666607, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
					TweenService:Create(
						eye_0145,
						TweenInfo.new(0.016666666666666607, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
					TweenService:Create(
						cube_0016,
						TweenInfo.new(0.016666666666666607, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
					TweenService:Create(
						eye_0144,
						TweenInfo.new(0.016666666666666607, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
					TweenService:Create(
						cube_0014,
						TweenInfo.new(0.016666666666666607, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
					TweenService:Create(
						cube_0015,
						TweenInfo.new(0.016666666666666607, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
				end)
				task.delay(6.866666666666666, function()
					TweenService:Create(
						eye_014,
						TweenInfo.new(0.3166666666666673, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(1.7093806, 1.6954684, 1.6970426)
						}
					):Play()
					TweenService:Create(
						cube_001,
						TweenInfo.new(0.3166666666666673, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(6.3459573, 0.60056186, 1.4169755)
						}
					):Play()
					TweenService:Create(
						eye_0143,
						TweenInfo.new(0.3166666666666673, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(1.7093806, 1.6954684, 1.6970426)
						}
					):Play()
					TweenService:Create(
						eye_0142,
						TweenInfo.new(0.3166666666666673, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(1.7093806, 1.6954684, 1.6970426)
						}
					):Play()
					TweenService:Create(
						cube_0013,
						TweenInfo.new(0.3166666666666673, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(6.3459573, 0.60056186, 1.4169755)
						}
					):Play()
					TweenService:Create(
						eye_0146,
						TweenInfo.new(0.3166666666666673, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(1.7093806, 1.6954684, 1.6970426)
						}
					):Play()
					TweenService:Create(
						cube_0012,
						TweenInfo.new(0.3166666666666673, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(6.3459573, 0.60056186, 1.4169755)
						}
					):Play()
					TweenService:Create(
						eye_0145,
						TweenInfo.new(0.3166666666666673, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(1.7093806, 1.6954684, 1.6970426)
						}
					):Play()
					TweenService:Create(
						cube_0016,
						TweenInfo.new(0.3166666666666673, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(6.3459573, 0.60056186, 1.4169755)
						}
					):Play()
					TweenService:Create(
						eye_0144,
						TweenInfo.new(0.3166666666666673, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(1.7093806, 1.6954684, 1.6970426)
						}
					):Play()
					TweenService:Create(
						cube_0014,
						TweenInfo.new(0.3166666666666673, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(6.3459573, 0.60056186, 1.4169755)
						}
					):Play()
					TweenService:Create(
						cube_0015,
						TweenInfo.new(0.3166666666666673, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(6.3459573, 0.60056186, 1.4169755)
						}
					):Play()
				end)
				task.delay(7.183333333333334, function()
					TweenService:Create(
						eye_014,
						TweenInfo.new(1.916666666666666, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(1.7093806, 1.6954684, 1.6970426)
						}
					):Play()
					TweenService:Create(
						cube_001,
						TweenInfo.new(1.916666666666666, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(6.3459573, 0.60056186, 1.4169755)
						}
					):Play()
					TweenService:Create(
						eye_0143,
						TweenInfo.new(1.916666666666666, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(1.7093806, 1.6954684, 1.6970426)
						}
					):Play()
					TweenService:Create(
						eye_0142,
						TweenInfo.new(1.916666666666666, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(1.7093806, 1.6954684, 1.6970426)
						}
					):Play()
					TweenService:Create(
						cube_0013,
						TweenInfo.new(1.916666666666666, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(6.3459573, 0.60056186, 1.4169755)
						}
					):Play()
					TweenService:Create(
						eye_0146,
						TweenInfo.new(1.916666666666666, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(1.7093806, 1.6954684, 1.6970426)
						}
					):Play()
					TweenService:Create(
						cube_0012,
						TweenInfo.new(1.916666666666666, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(6.3459573, 0.60056186, 1.4169755)
						}
					):Play()
					TweenService:Create(
						eye_0145,
						TweenInfo.new(1.916666666666666, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(1.7093806, 1.6954684, 1.6970426)
						}
					):Play()
					TweenService:Create(
						cube_0016,
						TweenInfo.new(1.916666666666666, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(6.3459573, 0.60056186, 1.4169755)
						}
					):Play()
					TweenService:Create(
						eye_0144,
						TweenInfo.new(1.916666666666666, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(1.7093806, 1.6954684, 1.6970426)
						}
					):Play()
					TweenService:Create(
						cube_0014,
						TweenInfo.new(1.916666666666666, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(6.3459573, 0.60056186, 1.4169755)
						}
					):Play()
					TweenService:Create(
						cube_0015,
						TweenInfo.new(1.916666666666666, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(6.3459573, 0.60056186, 1.4169755)
						}
					):Play()
				end)
				task.delay(9.1, function()
					TweenService:Create(
						eye_014,
						TweenInfo.new(0.11666666666666714, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					):Play()
					TweenService:Create(
						cube_001,
						TweenInfo.new(0.11666666666666714, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					):Play()
					TweenService:Create(
						eye_0143,
						TweenInfo.new(0.11666666666666714, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					):Play()
					TweenService:Create(
						eye_0142,
						TweenInfo.new(0.11666666666666714, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					):Play()
					TweenService:Create(
						cube_0013,
						TweenInfo.new(0.11666666666666714, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					):Play()
					TweenService:Create(
						eye_0146,
						TweenInfo.new(0.11666666666666714, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					):Play()
					TweenService:Create(
						cube_0012,
						TweenInfo.new(0.11666666666666714, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					):Play()
					TweenService:Create(
						eye_0145,
						TweenInfo.new(0.11666666666666714, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					):Play()
					TweenService:Create(
						cube_0016,
						TweenInfo.new(0.11666666666666714, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					):Play()
					TweenService:Create(
						eye_0144,
						TweenInfo.new(0.11666666666666714, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					):Play()
					TweenService:Create(
						cube_0014,
						TweenInfo.new(0.11666666666666714, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					):Play()
					TweenService:Create(
						cube_0015,
						TweenInfo.new(0.11666666666666714, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					):Play()
				end)
				task.delay(9.216666666666667, function()
					TweenService:Create(
						eye_014,
						TweenInfo.new(0.01666666666666572, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
					TweenService:Create(
						cube_001,
						TweenInfo.new(0.01666666666666572, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
					TweenService:Create(
						eye_0143,
						TweenInfo.new(0.01666666666666572, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
					TweenService:Create(
						eye_0142,
						TweenInfo.new(0.01666666666666572, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
					TweenService:Create(
						cube_0013,
						TweenInfo.new(0.01666666666666572, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
					TweenService:Create(
						eye_0146,
						TweenInfo.new(0.01666666666666572, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
					TweenService:Create(
						cube_0012,
						TweenInfo.new(0.01666666666666572, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
					TweenService:Create(
						eye_0145,
						TweenInfo.new(0.01666666666666572, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
					TweenService:Create(
						cube_0016,
						TweenInfo.new(0.01666666666666572, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
					TweenService:Create(
						eye_0144,
						TweenInfo.new(0.01666666666666572, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
					TweenService:Create(
						cube_0014,
						TweenInfo.new(0.01666666666666572, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
					TweenService:Create(
						cube_0015,
						TweenInfo.new(0.01666666666666572, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1,
							Size = createVector(0.01, 0.01, 0.01)
						}
					):Play()
				end)
				task.delay(0.4, function()
					TweenService:Create(
						OPEN,
						TweenInfo.new(0.016666666666666663, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					):Play()
					TweenService:Create(
						cube_finals,
						TweenInfo.new(0.016666666666666663, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					):Play()
					TweenService:Create(
						cube_2,
						TweenInfo.new(0.016666666666666663, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					):Play()
					TweenService:Create(
						sphere_001,
						TweenInfo.new(0.016666666666666663, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					):Play()
					TweenService:Create(
						CIRCLE_001,
						TweenInfo.new(0.016666666666666663, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					):Play()
				end)
				task.delay(0.4166666666666667, function()
					TweenService:Create(
						OPEN,
						TweenInfo.new(4.133333333333333, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(1.1759775, 1.1805156, 0.5182548)
						}
					):Play()
					TweenService:Create(
						cube_finals,
						TweenInfo.new(4.133333333333333, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(1.5681943, 1.5681939, 0.40960672)
						}
					):Play()
					TweenService:Create(
						cube_2,
						TweenInfo.new(4.133333333333333, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(1.5681942, 1.5681938, 0.66054153)
						}
					):Play()
					TweenService:Create(
						sphere_001,
						TweenInfo.new(4.133333333333333, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(0.54944634, 0.54944646, 0.54944646)
						}
					):Play()
					TweenService:Create(
						CIRCLE_001,
						TweenInfo.new(4.133333333333333, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(0.4889227, 0.43917945, 0.20095001)
						}
					):Play()
				end)
				task.delay(4.55, function()
					TweenService:Create(
						talismanmesh,
						TweenInfo.new(0.016666666666666607, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
					TweenService:Create(
						OPEN,
						TweenInfo.new(0.31666666666666643, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(7.461335, 7.493675, 2.7742624)
						}
					):Play()
					TweenService:Create(
						cube_finals,
						TweenInfo.new(0.31666666666666643, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(10.256355, 10.256352, 2.0000129)
						}
					):Play()
					TweenService:Create(
						cube_2,
						TweenInfo.new(0.31666666666666643, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(10.256354, 10.256351, 3.7882278)
						}
					):Play()
					TweenService:Create(
						sphere_001,
						TweenInfo.new(0.31666666666666643, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(2.9965398, 2.9965405, 2.996541)
						}
					):Play()
					TweenService:Create(
						CIRCLE_001,
						TweenInfo.new(0.31666666666666643, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(2.5652354, 2.2107546, 0.51308066)
						}
					):Play()
				end)
				task.delay(4.866666666666666, function()
					TweenService:Create(
						OPEN,
						TweenInfo.new(1.4500000000000002, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(7.461335, 7.493675, 2.7742624)
						}
					):Play()
					TweenService:Create(
						cube_finals,
						TweenInfo.new(1.4500000000000002, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(10.256355, 10.256352, 2.0000129)
						}
					):Play()
					TweenService:Create(
						cube_2,
						TweenInfo.new(1.4500000000000002, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(10.256354, 10.256351, 3.7882278)
						}
					):Play()
					TweenService:Create(
						sphere_001,
						TweenInfo.new(1.4500000000000002, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(2.9965398, 2.9965405, 2.996541)
						}
					):Play()
					TweenService:Create(
						CIRCLE_001,
						TweenInfo.new(1.4500000000000002, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(2.5652354, 2.2107546, 0.51308066)
						}
					):Play()
				end)
				task.delay(6.316666666666666, function()
					TweenService:Create(
						OPEN,
						TweenInfo.new(0.35000000000000053, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0,
							Size = createVector(0.1, 0.1, 0.1)
						}
					):Play()
					TweenService:Create(
						cube_finals,
						TweenInfo.new(0.35000000000000053, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0,
							Size = createVector(0.1, 0.1, 0.1)
						}
					):Play()
					TweenService:Create(
						cube_2,
						TweenInfo.new(0.35000000000000053, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0,
							Size = createVector(0.1, 0.1, 0.1)
						}
					):Play()
					TweenService:Create(
						sphere_001,
						TweenInfo.new(0.35000000000000053, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0,
							Size = createVector(0.1, 0.1, 0.1)
						}
					):Play()
					TweenService:Create(
						CIRCLE_001,
						TweenInfo.new(0.35000000000000053, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0,
							Size = createVector(0.1, 0.1, 0.1)
						}
					):Play()
				end)
				task.delay(6.666666666666667, function()
					TweenService:Create(
						OPEN,
						TweenInfo.new(0.016666666666666607, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
					TweenService:Create(
						cube_finals,
						TweenInfo.new(0.016666666666666607, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
					TweenService:Create(
						cube_2,
						TweenInfo.new(0.016666666666666607, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
					TweenService:Create(
						sphere_001,
						TweenInfo.new(0.016666666666666607, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
					TweenService:Create(
						CIRCLE_001,
						TweenInfo.new(0.016666666666666607, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end)
			end,
			Animation = 100255267749203,
			HideWeapon = true,
			Limited = true,
			Stun = "Freeze",
			KillEmote = true
		},
		["Final Stand"] = {
			Sounds = {},
			Cooldown = 20,
			Limited = true,
			AuraEffect = true,
			Preview = 109527502104358,
			Animation = 113876851900426,
			Stun = "Freeze",
			Startup = function(list, _, _)
				fn(folder)
				local accessory = Instance.new("Accessory")
				accessory.Name = "#EmoteHolder_" .. math.random(1, 100000)
				accessory.Parent = folder
				accessory:SetAttribute("EmoteProperty", true)
				table.insert(list, accessory)
				game.ReplicatedStorage.Replication:FireAllClients({
					Type = "ReplicateEmoteVfx",
					Character = folder,
					vfxName = v4,
					SpecificModule = script.VFX,
					AnimSent = 113876851900426,
					RealBind = accessory
				})
				task.delay(9, function()
					if not (accessory and accessory.Parent and workspace.Live:FindFirstChild((tostring(folder)))) then
						return
					end

					local sfxes = {}

					for k, soundId in pairs({ "rbxassetid://112446641141594", "rbxassetid://98080224862986" }) do
						local sfx = shared.sfx({
							SoundId = soundId,
							Parent = folder.Torso,
							Name = "CrushEmoteAmbience",
							Volume = k == 2 and 0.3 or 1,
							Looped = true
						})
						sfx:Play()
						table.insert(sfxes, sfx)
					end

					local v9 = folder
					local clone = script.VFX.VfxMods.FS.vfx.Aura:Clone()

					for _, child in pairs(clone:GetChildren()) do
						local torso = v9:FindFirstChild(child.Name)

						if not torso then
							continue
						end

						for _, emitter in pairs(child:GetChildren()) do
							if child.Name == "HumanoidRootPart" then
								torso = v9.Torso
							end

							if emitter:IsA("ParticleEmitter") then
								emitter.LockedToPart = true
							end

							emitter.Parent = torso
							emitter:SetAttribute("LimitedAura", true)
							local v10 = emitter
							task.delay(65, function()
								if v10 and v10.Parent then
									v10:Destroy()
								end
							end)
							local emitter2 = emitter
							task.delay(60, function()
								for k, v11 in pairs(sfxes) do
									local TweenService2 = game:GetService("TweenService")
									TweenService2:Create(v11, TweenInfo.new(0.5), {
										Volume = 0
									}):Play()
									local v12 = v11
									task.delay(0.75, function()
										if v12 and v12.Parent then
											v12:Destroy()
										end
									end)
								end

								if emitter2:IsA("ParticleEmitter") then
									emitter2.Enabled = false
									return
								end

								for i, child2 in pairs(emitter2:GetChildren()) do
									child2.Enabled = false
								end
							end)
						end
					end

					clone:Destroy()
				end)
			end
		},
		Emerge = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://125543979037675",
					Volume = 0
				}
			},
			Preview = 116657827922671,
			Animation = 76857454472003,
			HideWeapon = true,
			Stun = "Freeze",
			Cooldown = 10,
			KillEmote = true,
			Limited = true
		},
		["Inner Rage"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://117425361961655",
					ParentTorso = true,
					Volume = 3
				}
			},
			Cooldown = 10,
			CanRotate = true,
			AuraEffect = true,
			Animation = 96993907314948,
			Preview = 104557346054564,
			Idle = 127234845846317,
			Limited = true,
			End = {
				117177504280717,
				0.35,
				{}
			},
			HideWeapon = true,
			CanColor = true,
			Stun = "Freeze",
			Startup = function(_, _, _)
				fn(folder)
				local color = object:GetColor() or math.random(1, 2) == 2 and Color3.fromRGB(1, 1, 1) or Color3.fromRGB(
					255,
					255,
					255
				)
				local accessory = Instance.new("Accessory")
				accessory.Name = "#EmoteHolder_" .. math.random(1, 100000)
				accessory.Parent = folder
				CollectionService2:AddTag(
					accessory,
					"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
				)
				game.ReplicatedStorage.Replication:FireAllClients({
					Type = "ReplicateEmoteVfx",
					Character = folder,
					vfxName = "Energy Explosion",
					AnimSent = 96993907314948,
					RealBind = accessory,
					NoInsertion = true,
					Colour = color
				})
				local clones = {}
				local handles = {}
				local descendants = {}
				task.delay(1.3, function()
					if accessory and accessory.Parent then
						(function()
							for _, accessory2 in pairs(folder.FakeHead:GetChildren()) do
								if not (accessory2:IsA("Accessory") and accessory2:FindFirstChild("Handle") and accessory2:FindFirstChild("Handle"):FindFirstChild("HairAttachment")) then
									continue
								end

								local handle = accessory2:FindFirstChild("Handle")
								table.insert(handles, handle)

								for _, specialMesh in pairs(handle:GetChildren()) do
									if specialMesh:IsA("SpecialMesh") then
										specialMesh:SetAttribute("basetext", specialMesh.TextureId)
									end
								end
							end

							for _, part in pairs(handles) do
								local clone = part:Clone()
								table.insert(clones, clone)
								local weld = Instance.new("Weld")
								weld.Part0 = clone
								weld.Part1 = part
								weld.Parent = clone
								clone.Parent = game.Workspace.Thrown
								part.Transparency = 1
								TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
									Transparency = 0
								}):Play()
								local specialMesh = part:FindFirstChildOfClass("SpecialMesh")

								if not specialMesh then
									continue
								end

								specialMesh.TextureId = ""
								local clone2 = game.ReplicatedStorage.Resources.DeathEffect.Template:Clone()
								clone2.Color3 = Color3.new(color.R * 5, color.G * 5, color.B * 5)
								clone2.Parent = clone
							end

							v3[folder] = {
								hairs = handles,
								destroy = clones
							}
						end)()
						task.delay(600, function()
							for _, v9 in pairs(clones) do
								local TweenService2 = game:GetService("TweenService")
								TweenService2:Create(v9, TweenInfo.new(0.1), {
									Transparency = 1
								}):Play()
								game.Debris:AddItem(v9, 0.5)
							end

							for _, v9 in pairs(handles) do
								if not folder:GetAttribute("InMech") then
									local TweenService2 = game:GetService("TweenService")
									TweenService2:Create(v9, TweenInfo.new(0.1), {
										Transparency = 0
									}):Play()
								end

								for _, child in pairs(v9:GetChildren()) do
									if child:IsA("SpecialMesh") or child:IsA("MeshPart") then
										child.TextureId = child:GetAttribute("basetext")
									end
								end
							end
						end)
						local folder2 = Instance.new("Folder")
						folder2.Name = "AuraHolder"
						folder2:SetAttribute("LimAura", true)
						folder2:SetAttribute("EmoteEffect", true)
						folder2.Parent = folder
						task.delay(603, function()
							if folder2 then
								folder2:Destroy()
							end
						end)
						local v9 = {}

						for _, child in pairs(script.AuraReal:GetChildren()) do
							local clone = child:Clone()
							clone:SetAttribute("LimAura", true)
							table.insert(v9, clone)
							task.delay(603, function()
								if clone then
									clone:Destroy()
								end
							end)

							if clone:IsA("Attachment") or clone:IsA("PointLight") then
								clone.Parent = folder.PrimaryPart
							else
								local weld = Instance.new("Weld")
								weld.Part0 = folder.PrimaryPart
								weld.Part1 = clone
								weld.Parent = clone
							end

							for _, descendant in pairs(clone:GetDescendants()) do
								if not (descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight")) then
									continue
								end

								descendant.Enabled = false
								table.insert(descendants, descendant)
								descendant:SetAttribute("LimitedAura", true)
								descendant:SetAttribute("InnerRageAura", true)

								if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
									descendant.Color = ColorSequence.new(Color3.new(color.R, color.G, color.B))
								end

								if descendant:IsA("PointLight") or descendant:IsA("SpotLight") or descendant:IsA("SurfaceLight") then
									descendant.Brightness *= 1.3
									descendant.Color = Color3.new(color.R * 1.3, color.G * 1.3, color.B * 1.3)
								end

								local v11 = descendant
								task.delay(600, function()
									v11.Enabled = false
								end)
							end
						end
					end
				end)
				task.delay(5.3, function()
					if not (accessory and accessory.Parent) then
						return
					end

					for _, v9 in pairs(descendants) do
						v9.Enabled = true
					end

					wait(0.05)

					for _, v9 in pairs(folder.Humanoid:GetPlayingAnimationTracks()) do
						if v9.Animation.AnimationId == "rbxassetid://127234845846317" then
							v9:Stop()
						end
					end
				end)
			end
		},
		["Shadow Eruption"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://117425361961655",
					ParentTorso = true,
					Volume = 0
				}
			},
			CanRotate = true,
			AuraEffect = true,
			Preview = 104041899061636,
			Animation = 121032789756540,
			Limited = true,
			Cooldown = 20,
			HideWeapon = true,
			Stun = "Freeze",
			Startup = function(_, _, _)
				fn(folder)
				local accessory = Instance.new("Accessory")
				accessory.Name = "#EmoteHolder_" .. math.random(1, 100000)
				accessory.Parent = folder
				CollectionService2:AddTag(
					accessory,
					"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
				)
				game.ReplicatedStorage.Replication:FireAllClients({
					Type = "ReplicateEmoteVfx",
					Character = folder,
					vfxName = "Shadow Eruption",
					AnimSent = 121032789756540,
					RealBind = accessory,
					NoInsertion = true
				})
				task.delay(8.1, function()
					if not (accessory and accessory.Parent and workspace.Live:FindFirstChild((tostring(folder)))) then
						return
					end

					local v9 = folder
					local v10 = {}

					local function parent(child, p4)
						local parent4 = p4[tostring(child)]

						if not parent4 then
							return
						end

						for _, child2 in pairs(child:GetChildren()) do
							local clone = child2:Clone()
							clone.Parent = parent4
							clone:SetAttribute("LimitedAura", true)

							for _, effect in pairs(clone:GetDescendants()) do
								if not ((effect:IsA("Trail") or effect:IsA("Beam")) and effect.Attachment0 and effect.Attachment1) then
									continue
								end

								v10[effect] = {
									Attachment0 = effect.Attachment0.CFrame,
									Attachment1 = effect.Attachment1.CFrame
								}
							end
						end

						if next(v10) then
							for k, v12 in pairs(v10) do
								local attachment0 = v12.Attachment0
								local attachment1 = v12.Attachment1
								local parent2 = k.Parent.Parent

								for _, attachment in pairs(folder:GetDescendants()) do
									if not attachment:IsA("Attachment") then
										continue
									end

									local parent3 = attachment.Parent

									if not (parent3 and parent3:IsA("BasePart") and parent3 == parent2) then
										continue
									end

									local cFrame = attachment.CFrame

									if cFrame == attachment0 then
										k.Attachment0 = attachment
									elseif cFrame == attachment1 then
										k.Attachment1 = attachment
									end
								end
							end
						end
					end

					for _, child in pairs(script.auraNew:GetChildren()) do
						local child2 = script.auraNew:FindFirstChild((tostring(child)))

						if child2 then
							parent(child2, v9)
						end
					end

					local sfx = shared.sfx({
						Looped = true,
						SoundId = "rbxassetid://128082194939921",
						Volume = 1,
						Parent = folder.Torso
					})
					game.Debris:AddItem(sfx, 80)
				end)
			end
		},
		["Divine Form"] = {
			Sounds = {},
			AuraEffect = true,
			Limited = true,
			NoHeadLerp = true,
			Preview = 110962684776643,
			Cooldown = 20,
			HideWeapon = true,
			Animation = 116187503451999,
			Stun = "Freeze",
			Startup = function(list, _, _)
				fn(folder)
				local accessory = Instance.new("Accessory")
				accessory.Name = "#EmoteHolder_" .. math.random(1, 100000)
				accessory.Parent = folder
				accessory:SetAttribute("EmoteProperty", true)
				table.insert(list, accessory)
				game.ReplicatedStorage.Replication:FireAllClients({
					Type = "ReplicateEmoteVfx",
					Character = folder,
					vfxName = "Divine Form",
					SpecificModule = script.VFX,
					AnimSent = 116187503451999,
					RealBind = accessory
				})
				local cfolder = shared.cfolder({
					Name = "NoRotate",
					Parent = folder
				}, 10)
				cfolder:SetAttribute("EmoteProperty", true)
				table.insert(list, cfolder)
				task.delay(7.21, function()
					if not (accessory and accessory.Parent and workspace.Live:FindFirstChild((tostring(folder)))) then
						return
					end

					local v9 = folder
					local folder2 = script.VFX.VfxMods.Evolved.vfx.Folder
					local folder3 = Instance.new("Folder")
					folder3.Name = "AuraHolder"
					folder3:SetAttribute("DivineForm", true)
					folder3:SetAttribute("LimAura", true)
					folder3:SetAttribute("EmoteEffect", true)
					folder3.Parent = folder
					task.spawn(function()
						for _, part in pairs(folder2:GetChildren()) do
							if not part:IsA("BasePart") then
								continue
							end

							local child = v9:FindFirstChild(part.Name)

							if not child then
								continue
							end

							local clone = part:Clone()
							clone:SetAttribute("LimAura", true)
							clone.Transparency = 1
							clone.Massless = true
							local weld = Instance.new("Weld")
							weld.Part0 = child
							weld.Part1 = clone
							weld.Parent = clone
							clone.Name = math.random(1, 1000)
							clone.Parent = folder3

							for _, effect in pairs(clone:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
									effect:SetAttribute("LimitedAura", true)
								end
							end
						end
					end)
				end)
			end
		},
		["Final Spark"] = {
			Sounds = {},
			Animation = 129361308786827,
			Preview = 123088732998622,
			HideWeapon = true,
			Stun = "Freeze",
			KillEmote = true,
			Limited = true
		},
		["Wombo Combo"] = {
			Sounds = {},
			Animation = 89772127095146,
			HideWeapon = true,
			Stun = "Freeze",
			KillEmote = true,
			Limited = true,
			Startup = function(list, _, p4)
				p4.Position = folder.PrimaryPart.Position
				shared.cfolder({
					Name = "RootAnchor",
					Parent = folder
				}, 0.35)
				local table2 = {}
				local clone = script.Star:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				clone.Parent = folder
				table.insert(table2, clone)
				local cam = clone.Cam
				cam.Parent = folder.PrimaryPart
				cam:SetAttribute("EmoteProperty", true)
				table.insert(list, cam)
				table.insert(table2, cam)
				local cam2 = cam.Cam
				cam2.Part0 = folder.PrimaryPart
				cam2.Part1 = cam
				cam2.Parent = folder.PrimaryPart
				table.insert(table2, cam2)
				local total = 3

				for _, child in pairs(clone:GetChildren()) do
					child.Transparency = 1
					local motor6D = Instance.new("Motor6D")
					motor6D:SetAttribute("EmoteProperty", true)
					table.insert(list, motor6D)
					motor6D.Parent = folder.PrimaryPart
					motor6D.Part0 = folder.PrimaryPart
					motor6D.Part1 = child
					motor6D.C0 = CFrame.new(0, 0, total)
					table.insert(table2, motor6D)
					total += 2
				end

				local clone2 = game.ReplicatedStorage.Resources.CloneRigEm:Clone()
				clone2:SetAttribute("EmoteProperty", true)
				table.insert(list, clone2)
				table.insert(table2, clone2)
				game.Debris:AddItem(clone2, 20)
				clone2.Parent = folder
				clone2.Name = "DUALEMOTECLONE"
				clone2.PrimaryPart.Anchored = true
				clone2.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

				local function fn15()
					for _, descendant in pairs(clone2:GetDescendants()) do
						if descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
							descendant:Destroy("")
						end

						if not descendant:IsA("BasePart") then
							continue
						end

						descendant.CollisionGroup = "untouchable"
						descendant.Massless = true
						descendant.CanCollide = false
						descendant.CanTouch = false
						descendant.CanQuery = false
						descendant.Anchored = false
					end
				end

				spawn(function()
					if playerFromCharacter then
						tick()
						local v11 = playerFromCharacter
						local v12

						if friendcache[v11] then
							v12 = friendcache[v11]
						end

						local ids = v12 or {}

						if #ids == 0 then
							local function iterPageItems(object2)
								return coroutine.wrap(function()
									local v13 = 1

									while true do
										for _, v14 in ipairs(object2:GetCurrentPage()) do
											coroutine.yield(v14, v13)
										end

										if object2.IsFinished then
											break
										end

										object2:AdvanceToNextPageAsync()
										v13 += 1
									end
								end)
							end

							local Players = game:GetService("Players")
							local friendsAsync = Players:GetFriendsAsync(playerFromCharacter.UserId)

							for k, _ in coroutine.wrap(function()
								local v13 = 1

								while true do
									for _, v14 in ipairs(friendsAsync:GetCurrentPage()) do
										coroutine.yield(v14, v13)
									end

									if friendsAsync.IsFinished then
										break
									end

									friendsAsync:AdvanceToNextPageAsync()
									v13 += 1
								end
							end) do
								table.insert(ids, k.Id)
							end

							if #ids > 0 then
								friendcache[playerFromCharacter] = ids
							end
						end

						local v13 = ids[math.random(1, #ids)]
						local humanoidDescriptionFromUserId = game.Players:GetHumanoidDescriptionFromUserId(v13)
						clone2.Humanoid:ApplyDescription(humanoidDescriptionFromUserId)
						fn15()
					end
				end)
				local weld = Instance.new("Weld")
				weld.Part0 = folder.PrimaryPart
				weld.Part1 = clone2.PrimaryPart
				weld.Parent = clone2.PrimaryPart
				table.insert(table2, weld)

				for i = 1, 2 do
					local clone3 = script.RockNew:Clone()
					table.insert(table2, clone3)
					clone3.Name = "Rock"
					clone3:SetAttribute("EmoteProperty", true)
					table.insert(list, clone3)

					if i == 1 then
						clone3.Parent = clone2.PrimaryPart
					else
						clone3.Parent = clone2["Right Arm"]
					end

					local motor6D = Instance.new("Motor6D")
					motor6D:SetAttribute("EmoteProperty", true)
					table.insert(list, motor6D)
					table.insert(table2, motor6D)
					motor6D.Parent = clone3.Parent
					motor6D.Part0 = clone3.Parent
					motor6D.Part1 = clone3
					motor6D.C0 = CFrame.new(0, clone3.Parent == clone2["Right Arm"] and -1 or false, 0)
				end

				local animation = Instance.new("Animation")
				game.Debris:AddItem(animation, 20)
				animation.AnimationId = "rbxassetid://133729834760596"
				clone2.Humanoid:LoadAnimation(animation):Play()
				table.insert(list, shared.cfolder({
					Name = "RootAnchor",
					Parent = folder
				}, 20))
				game.ReplicatedStorage.Replication:FireAllClients({
					Type = "DestroyEmoteData",
					Table = table2,
					Char = folder
				})
			end
		},
		["Pocket Dimension"] = {
			Sounds = {},
			Animation = 103086076309134,
			HideWeapon = true,
			Preview = 126033249793452,
			Stun = "Freeze",
			KillEmote = true,
			Limited = true,
			Startup = function(_, _, _) end
		},
		Lifeform = {
			Sounds = {},
			Animation = 71308731679724,
			Stun = "Freeze",
			Limited = true,
			Preview = 76084431152851,
			Startup = function(_, _, _)
				fn(folder)
				local accessory = Instance.new("Accessory")
				accessory.Name = "#EmoteHolder_" .. math.random(1, 100000)
				accessory.Parent = folder
				CollectionService2:AddTag(
					accessory,
					"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
				)
				game.ReplicatedStorage.Replication:FireAllClients({
					Type = "ReplicateEmoteVfx",
					Character = folder,
					vfxName = "Lifeform",
					AnimSent = 71308731679724,
					RealBind = accessory
				})
				local parent4 = folder
				local primaryPart = folder.PrimaryPart
				folder:FindFirstChild("Head")
				local leftArm = folder["Left Arm"]
				local rightArm = folder["Right Arm"]
				local lifeformassets = script.Lifeformassets
				local clone = lifeformassets.Mask:Clone()
				clone:SetAttribute("EmoteEffect", true)
				clone.Parent = parent4
				local motor6D = clone:FindFirstChildOfClass("Motor6D")
				motor6D:SetAttribute("EmoteEffect", true)
				motor6D.Part0 = folder.PrimaryPart
				motor6D.Parent = folder.PrimaryPart
				motor6D.Part1 = clone.Mask
				local flag = false
				local parentChangedConnection = nil

				local function fn15(p4)
					if not (accessory and (accessory.Parent or p4)) or flag then
						return
					end

					flag = true

					if parentChangedConnection then
						parentChangedConnection:Disconnect()
					end

					if clone and clone.Parent then
						clone:Destroy()
					end

					if motor6D and motor6D.Parent then
						motor6D:Destroy()
					end

					local clone2 = lifeformassets.Mask:Clone()
					clone2:SetAttribute("EmoteEffect", true)
					clone2.Parent = parent4
					local motor6D2 = clone2:FindFirstChildOfClass("Motor6D")
					motor6D2:SetAttribute("EmoteEffect", true)
					motor6D2.Parent = folder.Head
					motor6D2.Part0 = folder.Head
					motor6D2.Part1 = clone2.Mask
					motor6D2.CurrentAngle = 0
					motor6D2.C0 = CFrame.new(0, 0.025, -0.513)
					local sfx = shared.sfx({
						SoundId = "rbxassetid://123572830176617",
						Parent = clone2.Mask,
						Volume = 0.04,
						RollOffMaxDistance = 30,
						PlaybackSpeed = 1,
						Looped = true
					})
					sfx:Play()
					local sfx2 = shared.sfx({
						SoundId = "rbxassetid://81973993022826",
						Parent = folder.Torso,
						Volume = 0.35,
						RollOffMaxDistance = 40,
						PlaybackSpeed = 1.1,
						Looped = true
					})
					sfx2:Play()

					for _, v10 in pairs({ sfx2, sfx }) do
						v10:SetAttribute("EmoteEffect", true)
					end

					local function fn16(attachment)
						for _, emitter in pairs(attachment:GetChildren()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							emitter.Enabled = true
							emitter.Rate /= 1.35
						end
					end

					for _, attachment in pairs(clone2:GetDescendants()) do
						if not attachment:IsA("Attachment") then
							continue
						end

						if tostring(attachment) == "eyeflare" then
							fn16(attachment)
						elseif not attachment:FindFirstChild("glow") then
							attachment:Destroy("")
						end
					end

					motor6D2.CurrentAngle = 0
					local lifeformaura = script.lifeformaura
					local v10 = folder
					local v11 = {}

					local function parent(child, p5)
						local parent5 = p5[tostring(child)]

						if not parent5 then
							return
						end

						for _, child2 in pairs(child:GetChildren()) do
							local clone3 = child2:Clone()
							clone3.Parent = parent5
							clone3:SetAttribute("LimitedAura", true)

							for _, effect in pairs(clone3:GetDescendants()) do
								if not ((effect:IsA("Trail") or effect:IsA("Beam")) and effect.Attachment0 and effect.Attachment1) then
									continue
								end

								v11[effect] = {
									Attachment0 = effect.Attachment0.CFrame,
									Attachment1 = effect.Attachment1.CFrame
								}
							end
						end

						if next(v11) then
							for k, v13 in pairs(v11) do
								local attachment0 = v13.Attachment0
								local attachment1 = v13.Attachment1
								local parent2 = k.Parent.Parent

								for _, attachment in pairs(folder:GetDescendants()) do
									if not attachment:IsA("Attachment") then
										continue
									end

									local parent3 = attachment.Parent

									if not (parent3 and parent3:IsA("BasePart") and parent3 == parent2) then
										continue
									end

									local cFrame = attachment.CFrame

									if cFrame == attachment0 then
										k.Attachment0 = attachment
									elseif cFrame == attachment1 then
										k.Attachment1 = attachment
									end
								end
							end
						end
					end

					for _, child in pairs(lifeformaura:GetChildren()) do
						local child2 = lifeformaura:FindFirstChild((tostring(child)))

						if child2 then
							parent(child2, v10)
						end
					end
				end

				task.delay(13, function()
					if not flag then
						fn15()
					end
				end)
				parentChangedConnection = accessory:GetPropertyChangedSignal("Parent"):Once(function()
					fn15(true)
				end)
				local clone2 = lifeformassets.Blades:Clone()
				clone2.Parent = parent4
				clone2:PivotTo(primaryPart.CFrame * CFrame.new(0, -3, 0))
				local weld = Instance.new("Weld")
				local arm002 = clone2["Arm.002"]
				weld.Part0 = leftArm
				weld.Part1 = arm002
				weld.Name = "Arm.002"
				weld.C0 = CFrame.new(-0.38418591, 0.2967906, -0.00624084473, 1, 0, 0, 0, 1, 0, 0, 0, 1)
				weld.Parent = leftArm
				local weld2 = Instance.new("Weld")
				local arm001 = clone2["Arm.001"]
				weld2.Part0 = rightArm
				weld2.Part1 = arm001
				weld2.Name = "Arm.001"
				weld2.C0 = CFrame.new(0.384193301, 0.2967906, -0.00624084473, 1, 0, 0, 0, 1, 0, 0, 0, 1)
				weld2.Parent = rightArm

				for _, v10 in pairs({
					motor6D,
					weld2,
					weld,
					clone2
				}) do
					v10:SetAttribute("EmoteEffect", true)
				end
			end
		},
		Speedster = {
			Sounds = {},
			AuraEffect = true,
			Limited = true,
			Preview = 82535683894728,
			Cooldown = 20,
			HideWeapon = true,
			Animation = 116013799321855,
			Stun = "Freeze",
			Startup = function(list, _, _)
				fn(folder)
				local accessory = Instance.new("Accessory")
				accessory.Name = "#EmoteHolder_" .. math.random(1, 100000)
				accessory.Parent = folder
				accessory:SetAttribute("EmoteProperty", true)
				table.insert(list, accessory)
				game.ReplicatedStorage.Replication:FireAllClients({
					Type = "ReplicateEmoteVfx",
					Character = folder,
					vfxName = "Speedster",
					SpecificModule = script.VFX,
					AnimSent = 116013799321855,
					RealBind = accessory
				})
				local cfolder = shared.cfolder({
					Name = "NoRotate",
					Parent = folder
				}, 17)
				cfolder:SetAttribute("EmoteProperty", true)
				table.insert(list, cfolder)
				local clone = script.cheekymask:Clone()
				clone:SetAttribute("EmoteEffect", true)
				clone.Parent = folder
				local motor6D = clone:FindFirstChildOfClass("Motor6D")
				motor6D.Parent = folder.Head
				motor6D.Part0 = folder.Head
				motor6D.Part1 = clone.RootPart
				motor6D:SetAttribute("EmoteEffect", true)
				cfolder:SetAttribute("EmoteProperty", true)
				table.insert(list, cfolder)
				local animation = Instance.new("Animation")
				animation.AnimationId = "rbxassetid://71755044809098"
				game.Debris:AddItem(animation, 15)
				local animationController = Instance.new("AnimationController")
				animationController.Parent = clone
				local track = animationController:LoadAnimation(animation)
				track.Looped = false

				local function fn15(p4)
					for _, part in pairs(clone:GetDescendants()) do
						if part:IsA("MeshPart") then
							part.Transparency = 0
						end
					end

					local aurarignew = game.ReplicatedStorage.Resources.aurarignew

					if aurarignew then
						for _, part in pairs(aurarignew:GetChildren()) do
							if not part:IsA("BasePart") then
								continue
							end

							local child = folder:FindFirstChild(part.Name)

							if not child then
								continue
							end

							for _, child2 in pairs(part:GetChildren()) do
								if not (child2:IsA("Attachment") or child2:IsA("ParticleEmitter") or child2:IsA("Beam") or child2:IsA("Trail") or child2:IsA("PointLight")) then
									continue
								end

								local clone2 = child2:Clone()
								clone2.Parent = child
								clone2:SetAttribute("LimitedAura", true)
								clone2:SetAttribute("EmoteEffect", true)

								if child2:IsA("ParticleEmitter") then
									child2.Enabled = true
								end

								for _, descendant in pairs(clone2:GetDescendants()) do
									if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("PointLight")) then
										continue
									end

									descendant:SetAttribute("LimitedAura", true)
									descendant:SetAttribute("EmoteEffect", true)

									if descendant:IsA("ParticleEmitter") then
										descendant.Enabled = true
									end
								end
							end
						end
					end

					if p4 then
						return
					end

					track:Play()
				end

				local thread = nil
				accessory.Destroying:Once(function()
					if thread then
						task.cancel(thread)
					end

					fn15(true)
				end)
				thread = task.delay(14.35, function()
					fn15()
				end)
			end
		},
		["Lifetime Barrage"] = {
			Animation = 94105258532295,
			Stun = "Freeze",
			KillEmote = true,
			Limited = true,
			Cooldown = 8,
			Preview = 97332443582360,
			Startup = function(list, _, _)
				local cfolder = shared.cfolder({
					Name = "RootAnchor",
					Parent = folder
				}, 15)
				cfolder:SetAttribute("EmoteProperty", true)
				table.insert(list, cfolder)
				local table2 = {}
				local clone = script.WoodGolden:Clone()
				table.insert(table2, clone)
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				task.delay(4.25, function()
					if clone and clone.Parent then
						clone:Destroy()
					end
				end)
				clone.Parent = workspace.Thrown
				local weld = Instance.new("Weld")
				weld.Part0 = folder.PrimaryPart
				weld.Part1 = clone.Rootpart
				weld.C0 = CFrame.new(0, -3, 0)
				weld.Parent = clone
				local animator = clone:FindFirstChildOfClass("AnimationController"):FindFirstChildOfClass("Animator")
				local animation = Instance.new("Animation")
				animation.AnimationId = "rbxassetid://122859438121673"
				game.Debris:AddItem(animation, 5)
				local track = animator:LoadAnimation(animation)
				track:Play()
				track.Looped = false
				local clone2 = game.ReplicatedStorage.Resources.CloneRigEm:Clone()
				clone2:SetAttribute("EmoteProperty", true)
				table.insert(list, clone2)
				table.insert(table2, clone2)
				game.Debris:AddItem(clone2, 25)
				clone2.Parent = folder
				clone2.Name = "StandClone" .. playerFromCharacter.UserId
				clone2.PrimaryPart.Anchored = true
				clone2.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

				local function fn15()
					for _, descendant in pairs(clone2:GetDescendants()) do
						if descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
							descendant:Destroy("")
						end

						if not descendant:IsA("BasePart") then
							continue
						end

						descendant.CollisionGroup = "untouchable"
						descendant.CanCollide = false
						descendant.CanTouch = false
						descendant.CanQuery = false
						descendant.Anchored = false
					end
				end

				fn15()
				local weld2 = Instance.new("Weld")
				weld2.Part0 = folder.PrimaryPart
				weld2.Part1 = clone2.PrimaryPart
				weld2.Parent = clone2.PrimaryPart
				table.insert(table2, weld2)
				local animation2 = Instance.new("Animation")
				game.Debris:AddItem(animation2, 20)
				animation2.AnimationId = "rbxassetid://109310118212791"
				clone2.Humanoid:LoadAnimation(animation2):Play()
				game.ReplicatedStorage.Replication:FireAllClients({
					Type = "DestroyEmoteData",
					Table = table2,
					Char = folder
				})

				if playerFromCharacter then
					tick()
					local v11 = playerFromCharacter
					local v12

					if friendcache[v11] then
						v12 = friendcache[v11]
					end

					local ids = v12 or {}

					if #ids == 0 then
						local function iterPageItems(object2)
							return coroutine.wrap(function()
								local v13 = 1

								while true do
									for _, v14 in ipairs(object2:GetCurrentPage()) do
										coroutine.yield(v14, v13)
									end

									if object2.IsFinished then
										break
									end

									object2:AdvanceToNextPageAsync()
									v13 += 1
								end
							end)
						end

						local Players = game:GetService("Players")
						local friendsAsync = Players:GetFriendsAsync(playerFromCharacter.UserId)

						for k, _ in coroutine.wrap(function()
							local v13 = 1

							while true do
								for _, v14 in ipairs(friendsAsync:GetCurrentPage()) do
									coroutine.yield(v14, v13)
								end

								if friendsAsync.IsFinished then
									break
								end

								friendsAsync:AdvanceToNextPageAsync()
								v13 += 1
							end
						end) do
							table.insert(ids, k.Id)
						end

						if #ids > 0 then
							friendcache[playerFromCharacter] = ids
						end
					end

					local v13 = ids[math.random(1, #ids)]
					local humanoidDescriptionFromUserId = game.Players:GetHumanoidDescriptionFromUserId(v13)
					clone2.Humanoid:ApplyDescription(humanoidDescriptionFromUserId)
					fn15()
				end

				fn15()
			end
		},
		["Nuclear Impact"] = {
			Animation = 81764031798103,
			DelayTime = 40,
			Stun = "Freeze",
			KillEmote = true,
			Limited = true,
			Preview = 80527003220550,
			Cooldown = 11,
			Startup = function(list, _, p4)
				local parent = folder
				local shadowSwordMesh = script.VFX.VfxMods.Atomic.Misc.ShadowSwordMesh

				if not (parent and shadowSwordMesh and shadowSwordMesh:IsA("BasePart")) then
					return nil
				end

				local clone = shadowSwordMesh:Clone()
				clone.Name = "Meshes/Shadow sword"
				clone.Anchored = false
				clone.CanCollide = false
				clone.Massless = true
				clone.Parent = parent
				local rightArm = folder["Right Arm"]
				local motor6D = clone:FindFirstChildOfClass("Motor6D")
				motor6D.Part1 = clone
				motor6D.Parent = rightArm

				if not (rightArm and rightArm:IsA("BasePart")) then
					rightArm = nil
				end

				motor6D.Part0 = rightArm
				motor6D:SetAttribute("EmoteProperty", true)
				table.insert(list, motor6D)
				p4.Handle = motor6D
				task.delay(50, function()
					if clone and clone.Parent then
						clone:Destroy()
					end
				end)
				table.insert(list, clone)
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				p4.Handle = clone
				task.delay(24.8, function()
					if clone and clone.Parent then
						for _, v10 in pairs(folder.Humanoid:GetPlayingAnimationTracks()) do
							if v10.Animation.AnimationId == "rbxassetid://81764031798103" then
								v10:Stop(0.6)
							end
						end
					end
				end)
				local cfolder = shared.cfolder({
					Name = "RootAnchor",
					Parent = folder
				}, 35)
				cfolder:SetAttribute("EmoteProperty", true)
				table.insert(list, cfolder)
			end
		},
		["Final Bomb"] = {
			Animation = 86437995118613,
			Stun = "Freeze",
			KillEmote = true,
			Limited = true,
			Cooldown = 11,
			Preview = 132667596929569,
			Startup = function(list, _, _)
				local cfolder = shared.cfolder({
					Name = "RootAnchor",
					Parent = folder
				}, 15)
				cfolder:SetAttribute("EmoteProperty", true)
				table.insert(list, cfolder)
				task.delay(10.725, function()
					if cfolder and cfolder.Parent then
						for _, v9 in pairs(folder.Humanoid:GetPlayingAnimationTracks()) do
							if v9.Animation.AnimationId == "rbxassetid://86437995118613" then
								v9:Stop(0.5)
							end
						end
					end
				end)
			end
		},
		["Last Will"] = {
			Sounds = {},
			Animation = 113450724032380,
			HideWeapon = true,
			Preview = 100033514259680,
			Stun = "Freeze",
			KillEmote = true,
			Limited = true,
			Startup = function(_, _, _) end
		},
		["True Aura"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://83049960731792",
					Volume = 3
				}
			},
			Limited = true,
			AuraEffect = true,
			Preview = 72889503319833,
			Cooldown = 20,
			Idle = 104862750267967,
			HideWeapon = true,
			Animation = 103668868712897,
			Stun = "Freeze",
			Startup = function(_, _, _)
				fn(folder)
				local accessory = Instance.new("Accessory")
				accessory.Name = "#EmoteHolder_" .. math.random(1, 100000)
				accessory.Parent = folder
				CollectionService2:AddTag(
					accessory,
					"emoteendstuff" .. (instance or playerFromCharacter or folder).Name
				)
				game.ReplicatedStorage.Replication:FireAllClients({
					Type = "ReplicateEmoteVfx",
					Character = folder,
					vfxName = "True Aura",
					AnimSent = 103668868712897,
					RealBind = accessory
				})
				local primaryPart = folder.PrimaryPart
				local v9 = {}

				if tostring(folder) == "YungCrepetics" then
					task.delay(6.3, function()
						if accessory and accessory.Parent then
							local v10 = {}
							local v11 = {}

							for _, v12 in pairs(workspace:GetPartBoundsInRadius(primaryPart.Position, 40)) do
								if (v12:GetAttribute("IsTree") or v12.Name == "TreeRoot") and not table.find(
									v9,
									v12.Parent
								) then
									game.ReplicatedStorage.Replication:FireAllClients({
										Effect = "Shake Tree",
										Tree = v12.Parent,
										Intensity = Random.new():NextNumber(5, 10),
										From = primaryPart.Position
									})
								end

								local humanoid = v12.Parent:FindFirstChildOfClass("Humanoid")

								if not humanoid or humanoid.Name == "FakeHumanoid" or table.find(v10, humanoid) or humanoid == folder.Humanoid then
									continue
								end

								table.insert(v11, v12.Parent)
							end
						end
					end)
				end
			end
		},
		["Beast Form"] = {
			Sounds = {},
			Preview = 72385565295818,
			Cooldown = 15,
			Animation = 129750616972225,
			Stun = "Freeze",
			Limited = true,
			AuraEffect = true,
			extraoptions = {
				Tail = {
					defaultenabled = true
				}
			},
			Startup = function(list, _, _)
				fn(folder)
				tick()
				local accessory = Instance.new("Accessory")
				accessory.Name = "#EmoteHolder_" .. math.random(1, 100000)
				accessory.Parent = folder
				accessory:SetAttribute("EmoteProperty", true)
				table.insert(list, accessory)
				local beastEffect = folder:FindFirstChild("BeastEffect")

				if beastEffect then
					beastEffect:Destroy()
				end

				local accessory2 = Instance.new("Accessory")
				accessory2.Name = "DismantleEffect"
				accessory2:SetAttribute("EmoteEffect", true)
				accessory2:SetAttribute("Custom", "BeastEffect")
				accessory2.Parent = folder
				local beastFormAura = script:FindFirstChild("BeastFormAura")

				if beastFormAura then
					for _, part in pairs(beastFormAura:GetChildren()) do
						if not part:IsA("BasePart") then
							continue
						end

						local child = folder:FindFirstChild(part.Name)

						if not child then
							continue
						end

						warn(child)

						for _, child2 in pairs(part:GetChildren()) do
							if not (child2:IsA("Attachment") or child2:IsA("ParticleEmitter") or child2:IsA("Beam") or child2:IsA("Trail") or child2:IsA("PointLight")) then
								continue
							end

							local clone = child2:Clone()
							clone.Parent = child
							clone:SetAttribute("LimitedAura", true)
							clone:SetAttribute("EmoteEffect", true)

							for _, descendant in pairs(clone:GetDescendants()) do
								if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("PointLight")) then
									continue
								end

								descendant:SetAttribute("LimitedAura", true)
								descendant:SetAttribute("EmoteEffect", true)
							end
						end
					end
				end

				if object:GetExtraOption("Tail") then
					local clone = script.tails:Clone()
					clone.Parent = folder
					clone.RootPart.Torso.Part1 = folder.Torso
					clone:SetAttribute("EmoteEffect", true)
					local animation = Instance.new("Animation")
					animation.AnimationId = "rbxassetid://73100251351770"
					animation.Parent = clone
					local track = clone.AnimationController:LoadAnimation(animation)
					track.Looped = false
					track:Play()
					accessory.Destroying:Once(function()
						if not (clone and clone.Parent) then
							return
						end

						if clone and clone.Parent then
							clone:Destroy("")
						end

						local clone2 = script.tails:Clone()
						clone2.Parent = folder
						clone2.RootPart.Torso.Part1 = folder.Torso
						clone2:SetAttribute("EmoteEffect", true)
						local animation2 = Instance.new("Animation")
						animation2.AnimationId = "rbxassetid://119426299039398"
						animation2.Parent = clone2
						clone2.AnimationController:LoadAnimation(animation2):Play(0)
					end)
				end

				game.ReplicatedStorage.Replication:FireAllClients({
					Type = "ReplicateEmoteVfx",
					Character = folder,
					vfxName = v4,
					SpecificModule = script.VFX,
					AnimSent = 129750616972225,
					RealBind = accessory
				})
			end
		},
		["Lightning Blitz"] = {
			Sounds = {},
			Animation = 101532381158436,
			HideWeapon = true,
			Preview = 97599293604082,
			Stun = "Freeze",
			KillEmote = true,
			Limited = true,
			Startup = function(list, _, _)
				table.insert(list, shared.cfolder({
					Name = "RootAnchor",
					Parent = folder
				}))
			end
		},
		["Boundless Rage"] = {
			Sounds = {},
			AuraEffect = true,
			Limited = true,
			Cooldown = 20,
			Preview = 80531366520745,
			Animation = 107649573628906,
			Stun = "Freeze",
			Startup = function(list, _, _)
				fn(folder)
				local accessory = Instance.new("Accessory")
				accessory.Name = "#EmoteHolder_" .. math.random(1, 100000)
				accessory.Parent = folder
				accessory:SetAttribute("EmoteProperty", true)
				table.insert(list, accessory)
				game.ReplicatedStorage.Replication:FireAllClients({
					Type = "ReplicateEmoteVfx",
					Character = folder,
					vfxName = v4,
					SpecificModule = script.VFX,
					AnimSent = 107649573628906,
					RealBind = accessory
				})
				local cfolder = shared.cfolder({
					Name = "NoRotate",
					Parent = folder
				}, 10)
				cfolder:SetAttribute("EmoteProperty", true)
				table.insert(list, cfolder)
				task.delay(4, function()
					if not (accessory and accessory.Parent and workspace.Live:FindFirstChild((tostring(folder)))) then
						return
					end

					local v9 = folder
					local clone = script.VFX.VfxMods.Boundless.vfx.AuraChar:Clone()
					game.Debris:AddItem(clone, 5)
					local sfx = shared.sfx({
						SoundId = "rbxassetid://81055990581650",
						Parent = v9.Torso,
						Name = "CrushEmoteAmbience",
						Volume = 1,
						Looped = true
					})
					sfx:Play()

					for _, part in pairs(clone:GetChildren()) do
						if not part:IsA("BasePart") then
							continue
						end

						local child = v9:FindFirstChild(part.Name)

						for _, child2 in pairs(part:GetChildren()) do
							if not (child and (child2:IsA("Attachment") or child2:IsA("ParticleEmitter"))) then
								continue
							end

							local clone2 = child2:Clone()
							clone2.Parent = child
							clone2:SetAttribute("LimitedAura", true)
							local emitter = clone2
							task.delay(60, function()
								local TweenService2 = game:GetService("TweenService")
								TweenService2:Create(sfx, TweenInfo.new(0.5), {
									Volume = 0
								}):Play()
								task.delay(0.75, function()
									if sfx and sfx.Parent then
										sfx:Destroy()
									end
								end)

								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
									return
								end

								for i, child3 in pairs(emitter:GetChildren()) do
									child3.Enabled = false
								end
							end)
							task.delay(65, function()
								if clone2 and clone2.Parent then
									clone2:Destroy()
								end
							end)
						end
					end

					clone:Destroy()
				end)
			end
		},
		["The Hunt"] = {
			Startup = function(_, _, _)
				fn10({
					SoundId = "rbxassetid://16749048896",
					Parent = folder.PrimaryPart,
					Volume = 0.65
				}):Play()
			end,
			Keyframes = {},
			Animation = 16719053698
		},
		["Eighth Key"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://16719111858",
					Volume = 1.5,
					Looped = false,
					ParentTorso = true
				}
			},
			Startup = function(list, _, _)
				local clone = script.Keys[8]:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				local m6d = clone.m6d
				m6d:SetAttribute("EmoteProperty", true)
				table.insert(list, m6d)
				m6d.Name = clone.Name
				m6d.Part0 = folder.PrimaryPart
				m6d.Part1 = clone
				m6d.Parent = folder.PrimaryPart
				clone.Parent = folder
			end,
			Animation = 16719107050
		},
		["Tenth Key"] = {
			Startup = function(list, _, _)
				local clone = script.Keys[10]:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				local m6d = clone.m6d
				m6d:SetAttribute("EmoteProperty", true)
				table.insert(list, m6d)
				m6d.Name = clone.Name
				m6d.Part0 = folder.PrimaryPart
				m6d.Part1 = clone
				m6d.Parent = folder.PrimaryPart
				clone.Parent = folder
				shared.sfx({
					SoundId = "rbxassetid://16725117208",
					Parent = clone,
					Volume = 1.5
				}):Play()
			end,
			Animation = 16725121777
		},
		["Sixth Key"] = {
			Startup = function(list, _, _)
				local clone = script.Keys[6]:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				local m6d = clone.m6d
				m6d:SetAttribute("EmoteProperty", true)
				table.insert(list, m6d)
				m6d.Name = clone.Name
				m6d.Part0 = folder.PrimaryPart
				m6d.Part1 = clone
				m6d.Parent = folder.PrimaryPart
				clone.Parent = folder
				shared.sfx({
					SoundId = "rbxassetid://16725146789",
					Parent = clone,
					Volume = 1.5
				}):Play()
			end,
			Animation = 16725167915
		},
		["Ninth Key"] = {
			Startup = function(list, _, _)
				local clone = script.Keys[9]:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				local m6d = clone.m6d
				m6d:SetAttribute("EmoteProperty", true)
				table.insert(list, m6d)
				m6d.Name = clone.Name
				m6d.Part0 = folder.PrimaryPart
				m6d.Part1 = clone
				m6d.Parent = folder.PrimaryPart
				clone.Parent = folder
				shared.sfx({
					SoundId = "rbxassetid://16719157711",
					Parent = clone,
					Volume = 1.5
				}):Play()
			end,
			Animation = 16719149848
		},
		["First Key"] = {
			Startup = function(list, _, _)
				local clone = script.Keys[1]:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				local m6d = clone.m6d
				m6d:SetAttribute("EmoteProperty", true)
				table.insert(list, m6d)
				m6d.Name = clone.Name
				m6d.Part0 = folder.PrimaryPart
				m6d.Part1 = clone
				m6d.Parent = folder.PrimaryPart
				clone.Parent = folder
				shared.sfx({
					SoundId = "rbxassetid://16719180495",
					Parent = clone,
					TimePosition = 0.075,
					Volume = 1.5
				}):Resume()
			end,
			Animation = 16719183472
		},
		["Seventh Key"] = {
			Startup = function(list, _, _)
				local clone = script.Keys[7]:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				local m6d = clone.m6d
				m6d:SetAttribute("EmoteProperty", true)
				table.insert(list, m6d)
				m6d.Name = clone.Name
				m6d.Part0 = folder.PrimaryPart
				m6d.Part1 = clone
				m6d.Parent = folder.PrimaryPart
				clone.Parent = folder
				shared.sfx({
					SoundId = "rbxassetid://16719202700",
					Parent = clone,
					TimePosition = 0,
					Volume = 1.5
				}):Resume()
			end,
			Animation = 16719205513
		},
		["Third Key"] = {
			Startup = function(list, _, _)
				local clone = script.Keys[3]:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				local m6d = clone.m6d
				m6d:SetAttribute("EmoteProperty", true)
				table.insert(list, m6d)
				m6d.Name = clone.Name
				m6d.Part0 = folder.PrimaryPart
				m6d.Part1 = clone
				m6d.Parent = folder.PrimaryPart
				clone.Parent = folder
				shared.sfx({
					SoundId = "rbxassetid://16725331724",
					Parent = clone,
					Volume = 1.5
				}):Resume()
			end,
			Animation = 16725337143
		},
		["Fourth Key"] = {
			Startup = function(list, _, _)
				local clone = script.Keys[4]:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				local m6d = clone.m6d
				m6d:SetAttribute("EmoteProperty", true)
				table.insert(list, m6d)
				m6d.Name = clone.Name
				m6d.Part0 = folder.PrimaryPart
				m6d.Part1 = clone
				m6d.Parent = folder.PrimaryPart
				clone.Parent = folder
				shared.sfx({
					SoundId = "rbxassetid://16719261316",
					Parent = clone,
					TimePosition = 0.2,
					Volume = 1.5
				}):Resume()
			end,
			Animation = 16719220174
		},
		["Fifth Key"] = {
			Startup = function(list, _, _)
				local clone = script.Keys[5]:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				local m6d = clone.m6d
				m6d:SetAttribute("EmoteProperty", true)
				table.insert(list, m6d)
				m6d.Name = clone.Name
				m6d.Part0 = folder.PrimaryPart
				m6d.Part1 = clone
				m6d.Parent = folder.PrimaryPart
				clone.Parent = folder
				shared.sfx({
					SoundId = "rbxassetid://16725540436",
					Parent = clone,
					Volume = 1.5
				}):Resume()
			end,
			Animation = 16725350277
		},
		["Second Key"] = {
			Startup = function(list, _, _)
				local clone = script.Keys[2]:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(list, clone)
				local m6d = clone.m6d
				m6d:SetAttribute("EmoteProperty", true)
				table.insert(list, m6d)
				m6d.Name = clone.Name
				m6d.Part0 = folder.PrimaryPart
				m6d.Part1 = clone
				m6d.Parent = folder.PrimaryPart
				clone.Parent = folder
				task.delay(0.3, function()
					if clone.Parent then
						shared.sfx({
							SoundId = "rbxassetid://16719230370",
							Parent = clone,
							TimePosition = 0,
							Volume = 1.5
						}):Resume()
					end
				end)
			end,
			Animation = 16719226293
		},
		["Monster Mash Potion"] = {
			Sounds = {
				[0] = {
					SoundId = "rbxassetid://35930009",
					Looped = true,
					Volume = 0.25,
					ParentTorso = true
				}
			},
			Startup = function(list, _, _)
				local clone = script.potion:Clone()
				clone.Parent = folder
				local weld = Instance.new("Weld")
				weld.Part0 = folder["Right Arm"]
				weld.Part1 = clone
				weld.C0 = CFrame.new(
					-0.100006104,
					-1,
					0.499969482,
					1,
					0,
					0,
					0,
					-1.00000012,
					-2.79396772e-9,
					0,
					-2.79396772e-9,
					-1
				)
				weld.Parent = clone

				for _, v9 in pairs({ weld, clone }) do
					v9:SetAttribute("EmoteProperty", true)
					table.insert(list, v9)
				end
			end,
			HideWeapon = true,
			Looped = true,
			Animation = 35654637,
			Stun = "Slowed"
		}
	}

	if p3 then
		for k, _ in pairs(v8) do
			if not (string.split(k, " ")[2] == "Key" or k == "The Hunt") then
				continue
			end

			v8[k].HideWeapon = true
			v8[k].Stun = "Freeze"
			v8[k].Ease = 0
			v8[k].CantCancel = true
			v8[k].Key = true
			v8[k].NoRotate = true
			v8[k].Keyframes = {
				["end"] = function() end
			}
		end

		for k, v9 in pairs(v8) do
			result[k] = v9
		end
	end

	if p2 then
		return result
	end

	if tick() - (folder:GetAttribute("EmoteCD") or 0) < 0 or not result[v4] then
		return
	end

	result = result[v4]

	if not shared.intcheck then
		return
	end

	if result.KillEmote then
		local forceField = folder:FindFirstChildOfClass("ForceField")

		if forceField and forceField:GetAttribute("Emote") then
			return
		end
	end

	if folder:FindFirstChild("KillEmoteInProgress") or result.KillEmote and not fn9(folder) or result.KillEmote and workspace:GetAttribute("RoyaleCustom1") then
		return
	end

	if result.Limited and workspace:GetAttribute("RoyaleCustom1") then
		return
	end

	local module = require(folder.CharacterHandler:FindFirstChild("AnimationPlayer") or folder.CharacterHandler:WaitForChild("AnimationPlayer"))

	fn14 = function(p4)
		return module.playAnimation(folder:FindFirstChild("Humanoid"), p4)
	end

	local total = 0

	if v4 == "OK" or v4 == "And One" then
		total += 2
	end

	if v4 == "Cart Ride" then
		total += 1.5
	end

	if v4 == "Untouchable" or v4 == "Hologram" or v4 == "Party" then
		total += 2
	end

	folder:SetAttribute("EmoteCD", tick() + total)
	local realAnimation = fn14(result.Animation)
	local v10 = { realAnimation }
	realAnimation.Looped = result.Looped
	result.RealAnimation = realAnimation
	shared.cfolder({
		Name = "CancelEmote2",
		Parent = folder
	}, 0.1)
	local cfolder = shared.cfolder({
		Name = "DoingEmote"
	})
	cfolder:SetAttribute("Name", v4)
	cfolder:SetAttribute("FixRotation", result.FixRotation)
	CollectionService2:AddTag(cfolder, "emotestun" .. (instance or playerFromCharacter or folder).Name)
	cfolder.Parent = folder

	if result.Tag then
		CollectionService2:AddTag(cfolder, result.Tag)
		CollectionService2:AddTag(cfolder, "interactableEmote")
	end

	table.insert(v10, cfolder)
	local v11

	if result.Stun then
		v11 = shared.cfolder({
			Name = result.Stun
		})

		if result.StunAttribute then
			v11:SetAttribute("Div", result.StunAttribute)
		end

		v11:SetAttribute("EmoteStun", true)
		CollectionService2:AddTag(v11, "emotestun" .. (instance or playerFromCharacter or folder).Name)
		v11.Parent = folder
		table.insert(v10, v11)
	end

	if result.CanWalk then
		local cfolder2 = shared.cfolder({
			Name = "CanWalk"
		})
		CollectionService2:AddTag(cfolder2, "emotestun" .. (instance or playerFromCharacter or folder).Name)
		cfolder2.Parent = folder
		table.insert(v10, cfolder2)
	end

	if result.NoRotate then
		local cfolder2 = shared.cfolder({
			Name = "NoRotate"
		})
		CollectionService2:AddTag(cfolder2, "emotestun" .. (instance or playerFromCharacter or folder).Name)
		cfolder2.Parent = folder
		table.insert(v10, cfolder2)
	end

	if result.HideWeapon and folder:GetAttribute("WeaponHolding") then
		local cfolder2 = shared.cfolder({
			Name = "GrabWeapon"
		})
		cfolder2:SetAttribute("inf", true)
		cfolder2.Parent = folder
		local cfolder3 = shared.cfolder({
			Name = "HideWeapon",
			Parent = folder
		})
		CollectionService2:AddTag(cfolder3, "emotestun" .. (instance or playerFromCharacter or folder).Name)
		CollectionService2:AddTag(cfolder2, "emotestun" .. (instance or playerFromCharacter or folder).Name)
		table.insert(v10, cfolder3)
		table.insert(v10, cfolder2)
	end

	if result.Heavy then
		table.insert(v10, shared.cfolder({
			Name = "HeavyBody",
			Parent = folder
		}))
	end

	if folder:FindFirstChild("NoCancel") then
		result.CantCancel = true
	end

	local intcheck = shared.intcheck(folder, v10, function() end, result.CantCancel)

	if intcheck.interrupted then
		return
	end

	if result.CantCancel then
		for _ = 1, 5 do
			local absoluteImmortal = folder:FindFirstChild("AbsoluteImmortal")

			if not absoluteImmortal then
				break
			end

			absoluteImmortal:Destroy()
		end

		local forceField = Instance.new("ForceField")
		forceField.Visible = false
		forceField.Name = "AbsoluteImmortal"
		forceField:SetAttribute("Emote", true)
		forceField:SetAttribute("EmoteProperty", true)
		table.insert(v10, forceField)
		forceField.Parent = folder
	end

	table.insert(v10, folder.DescendantAdded:Connect(function(sound)
		task.wait()

		if sound.Name == "EmoteSFX" and sound:IsA("Sound") then
			table.insert(v10, sound)
			local parentChangedConnection = nil
			parentChangedConnection = sound:GetPropertyChangedSignal("Parent"):Connect(function()
				if sound.Parent then
					return
				end

				table.remove(v10, table.find(v10, sound))
				return parentChangedConnection:Disconnect()
			end)
			table.insert(v10, parentChangedConnection)
		end
	end))

	if v4 == "Boppin" then
		local v12 = {
			smear2 = CFrame.new(
				-0.791710854,
				1.84644032,
				-0.135307789,
				0.9807778,
				-0.0889977589,
				0.173650175,
				0.0903706253,
				0.995908499,
				4.47683476e-7,
				-0.172939673,
				0.0156924464,
				0.984807432
			),
			smear22 = CFrame.new(
				-0.745628357,
				1.85068655,
				-0.143433571,
				0.9807778,
				-0.0889977589,
				0.173650175,
				0.0903706253,
				0.995908499,
				4.47683476e-7,
				-0.172939673,
				0.0156924464,
				0.984807432
			),
			smear23 = CFrame.new(
				-0.481506348,
				1.87502241,
				-0.190005302,
				0.98077774,
				-0.0889983475,
				0.173649952,
				0.0903712064,
				0.995908439,
				3.92749484e-7,
				-0.172939405,
				0.0156925842,
				0.984807491
			),
			smear3 = CFrame.new(
				-1.09635735,
				2.04136896,
				-0.893452168,
				0.975248516,
				-0.220937833,
				0.00918622315,
				0.218309477,
				0.968592405,
				0.119048409,
				-0.035201937,
				-0.114095852,
				0.992848933
			),
			smear24 = CFrame.new(
				-0.481506348,
				1.87502241,
				-0.190005302,
				0.98077774,
				-0.0889983475,
				0.173649952,
				0.0903712064,
				0.995908439,
				3.92749484e-7,
				-0.172939405,
				0.0156925842,
				0.984807491
			),
			smear25 = CFrame.new(
				-0.481506348,
				1.87502241,
				-0.190005302,
				0.98077774,
				-0.0889983475,
				0.173649952,
				0.0903712064,
				0.995908439,
				3.92749484e-7,
				-0.172939405,
				0.0156925842,
				0.984807491
			),
			smear32 = CFrame.new(
				-1.09635735,
				2.04136896,
				-0.893452168,
				0.975248516,
				-0.220937833,
				0.00918622315,
				0.218309477,
				0.968592405,
				0.119048409,
				-0.035201937,
				-0.114095852,
				0.992848933
			),
			smear26 = CFrame.new(
				1.28601265,
				-10.2580585,
				-0.501669407,
				0.969846249,
				-0.171009481,
				0.173649028,
				0.173647553,
				0.984808147,
				1.73008459e-7,
				-0.171010911,
				0.030153567,
				0.984807611
			),
			smear33 = CFrame.new(
				-1.09635735,
				2.04136896,
				-0.893452168,
				0.975248516,
				-0.220937833,
				0.00918622315,
				0.218309477,
				0.968592405,
				0.119048409,
				-0.035201937,
				-0.114095852,
				0.992848933
			),
			smear1 = CFrame.new(
				-0.528757095,
				1.55774784,
				-1.00612593,
				0.981060326,
				-0.0858316347,
				0.173648164,
				0.087155737,
				0.99619472,
				-2.22650054e-9,
				-0.172987401,
				0.0151344342,
				0.984807789
			)
		}
		result.Keyframes = {}

		for k, v13 in pairs(v12) do
			local v14 = k
			local C0 = v13

			result.Keyframes[k] = function(clones)
				local clone = script.Smear[string.sub(v14, 1, 6)]:Clone()
				clone:SetAttribute("EmoteProperty", true)
				table.insert(v10, clone)
				local weld = Instance.new("Weld")
				weld.Parent = clone
				weld.Part0 = folder.PrimaryPart
				weld.Part1 = clone
				weld.C0 = C0
				clones[v14] = clone
				clone.Parent = folder
			end

			local v16 = k

			result.Keyframes[k .. "end"] = function(p4)
				local v17 = p4[v16]

				if v17 then
					v17:Destroy()
				end
			end
		end
	end

	local v12 = {}

	if result.Animation ~= 0 then
		folder:SetAttribute("SideDashDisable", true)
		realAnimation:Play(result.Ease)
	end

	if result.KillEmote then
		local v13 = fn9(folder)
		local primaryPart = folder.PrimaryPart
		local folder2 = nil
		local grabOffset = nil
		local v14 = {}
		local v15 = nil
		local flag = false
		local v16 = nil

		local function fn15(data)
			game.ReplicatedStorage.Replication:FireAllClients({
				Effect = "Smooth Grab",
				CanBypass = true,
				Hit = data.hit,
				From = folder.PrimaryPart,
				NoLook = true,
				Offset = data.offset,
				Anchor = data.anchor
			})
		end

		local function fn16(p4)
			for _, animation in pairs(v14) do
				if animation:IsA("Animation") then
					animation:Stop(p4.speed or 0)
				end

				animation:Destroy()
			end
		end

		local function fn17(p4)
			if not workspace.Live:FindFirstChild((tostring(folder2))) then
				return
			end

			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = createVector(40000, 40000, 40000)
			bodyVelocity.Velocity = p4.Velocity
			bodyVelocity.Parent = folder2.PrimaryPart
			game.Debris:AddItem(bodyVelocity, p4.DeletionTime)
		end

		local v17 = {}

		local function fn18(data)
			for _, v18 in pairs(v17) do
				v18:Destroy()
			end

			local bodyVelocity = Instance.new("BodyVelocity")
			table.insert(v10, bodyVelocity)
			table.insert(v17, bodyVelocity)
			bodyVelocity.Name = "moveme"
			bodyVelocity.MaxForce = createVector(40000, 0, 40000)
			bodyVelocity:SetAttribute("Speed", data.speed or 100)
			bodyVelocity:SetAttribute("Fallout", data.fallout or 0.95)
			bodyVelocity:SetAttribute("End", data.endd or 5)
			bodyVelocity.Parent = folder.PrimaryPart
			game.Debris:AddItem(bodyVelocity, data.deletiontime or 5)
		end

		local function fn19(data)
			local v18 = {
				Effect = "Ground Crater",
				Seed = math.random(1, 2000000000),
				start = data.startpos,
				["end"] = createVector(0, -14, 0),
				amount = data.amount,
				size = data.size,
				nosound = data.nosound
			}
			game.ReplicatedStorage.Replication:FireAllClients(v18)
		end

		local known = 0

		local function fn20(_)
			local v19 = folder2

			for _, child in pairs(v19:GetChildren()) do
				if child.Name == "RootAnchor" then
					child:Destroy("")
				end
			end
		end

		local v19 = nil
		local v20 = {
			["Final Spark"] = {
				VictimAnim = 105725109678703,
				GrabOffset = CFrame.new(0, 0, -3) * CFrame.Angles(0, 3.141592653589793, 0),
				ForceStopAnim = true,
				DontCFrame = true,
				Markers = {
					hit = function()
						local hit = folder2
						v15:Stop(0)
						folder2:SetPrimaryPartCFrame(folder.PrimaryPart.CFrame * CFrame.new(
							0,
							0,
							-3,
							-1,
							0,
							0,
							0,
							1,
							0,
							0,
							0,
							-1
						))
						fn16()
						fn20()
						folder2:SetPrimaryPartCFrame(folder.PrimaryPart.CFrame * CFrame.new(3.5, 20, -40))
						hit.PrimaryPart.Velocity = Vector3.new()
						local Force = require(game.ServerStorage.Force)
						Force:CreateForce({
							char = folder,
							hit = hit,
							up = createVector(0, 30, 0),
							pushback = 350
						})
						task.delay(0.1, function()
							local Hitbox = require(game.ServerStorage.Hitbox)
							Hitbox:CheckCollision({
								hit = hit,
								dmg = 0,
								time = 2,
								breaktrees = true,
								stronger = true,
								AccurateCheck = true,
								camshake = { folder.Name, hit.Name },
								GlobalSound = { folder, hit },
								caller = folder
							})
						end)
					end
				}
			},
			["Lifetime Barrage"] = {
				DontRagdoll = true,
				VictimAnim = 136997220068848,
				GrabOffset = CFrame.new(0, 0, 0),
				ForceStopAnim = true,
				DontCFrame = true,
				DontStopVicAnimationOnAnchorDeletion = true,
				EndOffset = CFrame.new(0, 0, -11, -1, 0, 0, 0, 1, 0, 0, 0, -1),
				DontRestoreVictimCollisions = true,
				Tasks = {
					[16.975] = function()
						local folder3 = folder2
						v15:AdjustSpeed(0)
						local v21 = {}

						for _, accessory in pairs(folder2:GetDescendants()) do
							if not (accessory:IsA("Accessory") and accessory.Parent:IsA("Part")) then
								continue
							end

							local handle = accessory:FindFirstChild("Handle")

							if handle then
								v21[handle] = folder2.Head.CFrame:toObjectSpace(handle.CFrame)
							end
						end

						shared.sfx({
							SoundId = "rbxassetid://5868574236",
							Parent = folder3.PrimaryPart,
							TimePosition = 0.35,
							Volume = 4
						}):Resume()
						task.delay(0, function()
							if shared.checkjointbreaker(folder3) then
								return
							end

							for _, ballSocketConstraint in pairs(folder3:GetDescendants()) do
								if ballSocketConstraint:IsA("BallSocketConstraint") then
									ballSocketConstraint:Destroy()
								end
							end

							folder3:SetAttribute("BreakJointed", true)
							folder3:BreakJoints()
							fn20()
							task.wait()

							for _, descendant in pairs(folder3:GetDescendants()) do
								if descendant:IsA("BallSocketConstraint") or descendant:IsA("Weld") then
									descendant:Destroy()
								end
							end

							for _, part in pairs(folder3:GetChildren()) do
								if not part:IsA("Part") then
									continue
								end

								local bodyVelocity = Instance.new("BodyVelocity")
								bodyVelocity.MaxForce = createVector(40000, 40000, 40000)
								bodyVelocity.Velocity = primaryPart.CFrame.lookVector * 90 + createVector(25, 155, 0)
								bodyVelocity.Parent = part
								local Debris = game:GetService("Debris")
								Debris:AddItem(bodyVelocity, 0.15)
							end

							for k, C0 in pairs(v21) do
								local weld = Instance.new("Weld")
								weld.Part0 = folder2.Head
								weld.Part1 = k
								weld.C0 = C0
								weld.Parent = k
							end

							folder3.Humanoid.Health = 0
						end)
						task.delay(0.16, function()
							for _, character in pairs({ folder3, folder }) do
								local playerFromCharacter2 = game.Players:GetPlayerFromCharacter(character)

								if playerFromCharacter2 then
									game.ReplicatedStorage.Replication:FireClient(playerFromCharacter2, {
										Effect = "Camshake",
										Intensity = 15,
										Last = 0.5
									})
								end
							end
						end)
						folder3:SetAttribute("Finisherd", true)
						task.delay(0.25, function()
							local Hitbox = require(game.ServerStorage.Hitbox)
							Hitbox:CheckCollision({
								hit = folder3,
								dmg = 0,
								breaktrees = true,
								time = 4.4,
								stronger = {
									sound = "rbxassetid://14900616018"
								},
								AccurateCheck = true,
								camshake = { folder.Name, folder3.Name },
								caller = folder
							})
						end)
					end
				}
			},
			["Final Bomb"] = {
				VictimAnim = 104844166908417,
				GrabOffset = CFrame.new(0, 0, 0),
				DontRagdoll = true,
				ForceStopAnim = true,
				DontCFrame = true,
				DontStopVicAnimationOnAnchorDeletion = true,
				EndOffset = CFrame.new(0, 0, -11, -1, 0, 0, 0, 1, 0, 0, 0, -1),
				Tasks = {
					[9] = function()
						local folder3 = folder2
						v15:AdjustSpeed(0)
						warn("yo")
						local v21 = {}

						for _, accessory in pairs(folder2:GetDescendants()) do
							if not (accessory:IsA("Accessory") and accessory.Parent:IsA("Part")) then
								continue
							end

							local handle = accessory:FindFirstChild("Handle")

							if handle then
								v21[handle] = folder2.Head.CFrame:toObjectSpace(handle.CFrame)
							end
						end

						task.delay(0, function()
							if shared.checkjointbreaker(folder3) then
								return
							end

							shared.burn({
								hit = folder3
							})

							for _, ballSocketConstraint in pairs(folder3:GetDescendants()) do
								if ballSocketConstraint:IsA("BallSocketConstraint") then
									ballSocketConstraint:Destroy()
								end
							end

							folder3:SetAttribute("BreakJointed", true)
							folder3:BreakJoints()
							fn20()
							task.wait()

							for _, descendant in pairs(folder3:GetDescendants()) do
								if descendant:IsA("BallSocketConstraint") or descendant:IsA("Weld") then
									descendant:Destroy()
								end
							end

							for _, part in pairs(folder3:GetChildren()) do
								if not part:IsA("Part") then
									continue
								end

								local bodyVelocity = Instance.new("BodyVelocity")
								bodyVelocity.MaxForce = createVector(40000, 40000, 40000)
								bodyVelocity.Velocity = primaryPart.CFrame.lookVector * 180 + createVector(25, 33, 0)
								bodyVelocity.Parent = part
								local Debris = game:GetService("Debris")
								Debris:AddItem(bodyVelocity, 0.125)
							end

							for k, C0 in pairs(v21) do
								local weld = Instance.new("Weld")
								weld.Part0 = folder2.Head
								weld.Part1 = k
								weld.C0 = C0
								weld.Parent = k
							end

							folder3.Humanoid.Health = 0
						end)
						folder3:SetAttribute("Finisherd", true)
					end
				}
			},
			["Lightning Blitz"] = {
				VictimAnim = 140174099052607,
				GrabOffset = CFrame.new(0, 0, 0),
				ForceStopAnim = true,
				DontCFrame = true,
				DontRestoreVictimCollisions = true,
				Tasks = {
					[10.6] = function()
						local _ = folder2.Torso.CFrame
						local cFrame = folder2.Torso.CFrame
						fn16()
						folder2:SetPrimaryPartCFrame(cFrame)
						fn20()
						local folder3 = folder2
						local bodyColors = folder3:FindFirstChildOfClass("BodyColors")

						if bodyColors then
							bodyColors:Destroy()
						end

						for _, descendant in pairs(folder3:GetDescendants()) do
							if descendant:IsA("BasePart") then
								local v22 = 0.2
								local v23 = 0.3

								if not v23 and v22 then
									v23 = v22
									v22 = 1
								end

								if not (v23 or v22) then
									v22 = 0
									v23 = 1
								end

								TweenService:Create(
									descendant,
									TweenInfo.new(
										random:NextNumber(v22, v23),
										Enum.EasingStyle.Quad,
										Enum.EasingDirection.Out
									),
									{
										Color = Color3.new(0, 0, 0)
									}
								):Play()
							elseif descendant:IsA("SpecialMesh") then
								descendant.TextureId = ""
							elseif descendant:IsA("Decal") or descendant:IsA("Pants") or descendant:IsA("Shirt") then
								local v22 = 0.2
								local v23 = 0.3

								if not v23 and v22 then
									v23 = v22
									v22 = 1
								end

								if not (v23 or v22) then
									v22 = 0
									v23 = 1
								end

								TweenService:Create(
									descendant,
									TweenInfo.new(
										random:NextNumber(v22, v23),
										Enum.EasingStyle.Quad,
										Enum.EasingDirection.Out
									),
									{
										Color3 = Color3.new(0, 0, 0)
									}
								):Play()
							end
						end

						task.delay(0.75, function()
							local clone = script.BurnSmoke:Clone()
							clone.Parent = folder3:FindFirstChild("Torso") or folder3.PrimaryPart
						end)
						shared.sfx({
							SoundId = "rbxassetid://5868574236",
							Parent = folder3.PrimaryPart,
							TimePosition = 0.35,
							Volume = 4
						}):Resume()
						shared.cfolder({
							Name = "RootAnchor",
							Parent = folder3
						}, 1.4)
						folder2:SetPrimaryPartCFrame(cFrame)
						folder2:SetPrimaryPartCFrame(cFrame)
						folder2:SetPrimaryPartCFrame(cFrame)
						folder2:SetPrimaryPartCFrame(cFrame)
						folder2:SetPrimaryPartCFrame(cFrame)
					end
				}
			},
			["Pocket Dimension"] = {
				VictimAnim = 77525576385535,
				GrabOffset = CFrame.identity,
				ForceStopAnim = true,
				DontRestoreVictimCollisions = true,
				Tasks = {
					[9.35] = function()
						local folder3 = folder2
						fn16()
						folder2:SetPrimaryPartCFrame(primaryPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(
							0,
							3.141592653589793,
							0
						))
						fn20()
						local bodyColors = folder3:FindFirstChildOfClass("BodyColors")

						if bodyColors then
							bodyColors:Destroy()
						end

						for _, descendant in pairs(folder3:GetDescendants()) do
							if descendant:IsA("BasePart") then
								local v22 = 0.2
								local v23 = 0.3

								if not v23 and v22 then
									v23 = v22
									v22 = 1
								end

								if not (v23 or v22) then
									v22 = 0
									v23 = 1
								end

								TweenService:Create(
									descendant,
									TweenInfo.new(
										random:NextNumber(v22, v23),
										Enum.EasingStyle.Quad,
										Enum.EasingDirection.Out
									),
									{
										Color = Color3.new(0, 0, 0)
									}
								):Play()
							elseif descendant:IsA("SpecialMesh") then
								descendant.TextureId = ""
							elseif descendant:IsA("Decal") or descendant:IsA("Pants") or descendant:IsA("Shirt") then
								local v22 = 0.2
								local v23 = 0.3

								if not v23 and v22 then
									v23 = v22
									v22 = 1
								end

								if not (v23 or v22) then
									v22 = 0
									v23 = 1
								end

								TweenService:Create(
									descendant,
									TweenInfo.new(
										random:NextNumber(v22, v23),
										Enum.EasingStyle.Quad,
										Enum.EasingDirection.Out
									),
									{
										Color3 = Color3.new(0, 0, 0)
									}
								):Play()
							end
						end

						task.delay(0.15, function()
							local clone = script.BurnSmoke:Clone()
							clone.Parent = folder3:FindFirstChild("Torso") or folder3.PrimaryPart
						end)
						shared.sfx({
							SoundId = "rbxassetid://5868574236",
							Parent = folder3.PrimaryPart,
							TimePosition = 0.35,
							Volume = 4
						}):Resume()
					end
				}
			},
			["Last Will"] = {
				VictimAnim = 109860472243834,
				GrabOffset = CFrame.new(0, 0, 0),
				ForceStopAnim = true,
				DontCFrame = true,
				DontRestoreVictimCollisions = true,
				Markers = {
					send = function()
						fn16()
						folder2:SetPrimaryPartCFrame(primaryPart.CFrame * CFrame.new(0, -0.35, -10) * CFrame.Angles(
							0,
							3.141592653589793,
							0
						))
						fn20()
						wait(0.1)
						game.ReplicatedStorage.Replication:FireAllClients({
							Effect = "Debris Line",
							Part = primaryPart,
							Times = 25,
							NoParticles = true
						})
						local folder3 = folder2
						task.delay(0, function()
							if shared.checkjointbreaker(folder3) then
								return
							end

							for _, ballSocketConstraint in pairs(folder3:GetDescendants()) do
								if ballSocketConstraint:IsA("BallSocketConstraint") then
									ballSocketConstraint:Destroy()
								end
							end

							folder3:SetAttribute("BreakJointed", true)
							folder3:BreakJoints()
							task.wait()

							for _, descendant in pairs(folder3:GetDescendants()) do
								if descendant:IsA("BallSocketConstraint") or descendant:IsA("Weld") then
									descendant:Destroy()
								end
							end

							for _, part in pairs(folder3:GetChildren()) do
								if not part:IsA("Part") then
									continue
								end

								local bodyVelocity = Instance.new("BodyVelocity")
								bodyVelocity.MaxForce = createVector(40000, 40000, 40000)
								bodyVelocity.Velocity = primaryPart.CFrame.lookVector * 300 + createVector(0, 75, 0)
								bodyVelocity.Parent = part
								local Debris = game:GetService("Debris")
								Debris:AddItem(bodyVelocity, 0.15)
							end

							folder3.Humanoid.Health = 0
						end)

						for _, character in pairs({ folder3, folder }) do
							local playerFromCharacter2 = game.Players:GetPlayerFromCharacter(character)

							if playerFromCharacter2 then
								game.ReplicatedStorage.Replication:FireClient(playerFromCharacter2, {
									Effect = "Camshake",
									Intensity = 10
								})
							end
						end

						folder3:SetAttribute("Finisherd", true)
						task.delay(0.25, function()
							local Hitbox = require(game.ServerStorage.Hitbox)
							Hitbox:CheckCollision({
								hit = folder3,
								dmg = 0,
								breaktrees = true,
								time = 4.4,
								stronger = {
									sound = "rbxassetid://14900616018"
								},
								AccurateCheck = true,
								camshake = { folder.Name, folder3.Name },
								caller = folder
							})
						end)
					end
				}
			},
			["Wombo Combo"] = {
				VictimAnim = 138962769294666,
				GrabOffset = CFrame.new(0, 0, -3) * CFrame.Angles(0, 3.141592653589793, 0),
				ForceStopAnim = true,
				DontCFrame = true,
				Markers = {
					kick = function()
						local folder3 = folder2
						fn16()
						folder2:SetPrimaryPartCFrame(primaryPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(
							0,
							3.141592653589793,
							0
						))
						fn20()
						task.delay(0, function()
							if shared.checkjointbreaker(folder3) then
								return
							end

							for _, ballSocketConstraint in pairs(folder3:GetDescendants()) do
								if ballSocketConstraint:IsA("BallSocketConstraint") then
									ballSocketConstraint:Destroy()
								end
							end

							folder3:SetAttribute("BreakJointed", true)
							folder3:BreakJoints()
							task.wait()

							for _, descendant in pairs(folder3:GetDescendants()) do
								if descendant:IsA("BallSocketConstraint") or descendant:IsA("Weld") then
									descendant:Destroy()
								end
							end

							for _, part in pairs(folder3:GetChildren()) do
								if not part:IsA("Part") then
									continue
								end

								local bodyVelocity = Instance.new("BodyVelocity")
								bodyVelocity.MaxForce = createVector(40000, 40000, 40000)
								bodyVelocity.Velocity = primaryPart.CFrame.lookVector * 300 + createVector(0, 75, 0)
								bodyVelocity.Parent = part
								local Debris = game:GetService("Debris")
								Debris:AddItem(bodyVelocity, 0.15)
							end

							folder3.Humanoid.Health = 0
						end)

						for _, character in pairs({ folder3, folder }) do
							local playerFromCharacter2 = game.Players:GetPlayerFromCharacter(character)

							if playerFromCharacter2 then
								game.ReplicatedStorage.Replication:FireClient(playerFromCharacter2, {
									Effect = "Camshake",
									Intensity = 10
								})
							end
						end

						folder3:SetAttribute("Finisherd", true)
						local Hitbox = require(game.ServerStorage.Hitbox)
						Hitbox:CheckCollision({
							hit = folder3,
							dmg = 0,
							breaktrees = true,
							time = 4.4,
							stronger = {
								sound = "rbxassetid://14900616018"
							},
							AccurateCheck = true,
							camshake = { folder.Name, folder3.Name },
							caller = folder
						})
					end
				}
			},
			["slice combo"] = {
				CanRotate = true,
				VictimAnim = 84382675318505,
				DontDisconnectMarkers = true,
				GrabOffset = CFrame.new(0, 0, -3, -1, 0, 0, 0, 1, 0, 0, 0, -1),
				VictimSfx = "rbxassetid://87401852788032",
				Markers = {
					slice = function()
						known += 1
						local fallout, deletiontime

						if known == 5 then
							fallout = 0.93
							deletiontime = 1.2115
						else
							fallout = 0.875
							deletiontime = 0.725
						end

						fn18({
							speed = known == 5 and 60 or 50,
							fallout = fallout,
							endd = 1,
							deletiontime = deletiontime
						})
					end,
					chop = function()
						fn4({ folder, folder2 }, 8, 0.35)
						folder2:SetPrimaryPartCFrame(primaryPart.CFrame * CFrame.new(
							0,
							0,
							-3,
							-1,
							0,
							0,
							0,
							1,
							0,
							0,
							0,
							-1
						))
						fn16()
						fn20()
						local v21 = {}

						for _, accessory in pairs(folder2:GetDescendants()) do
							if not (accessory:IsA("Accessory") and accessory.Parent:IsA("Part")) then
								continue
							end

							local handle = accessory:FindFirstChild("Handle")

							if handle then
								v21[handle] = folder2.Head.CFrame:toObjectSpace(handle.CFrame)
							end
						end

						for _, descendant in pairs(folder2:GetDescendants()) do
							if not ((descendant:IsA("BallSocketConstraint") or descendant:IsA("Weld")) and descendant.Parent.Name == "Head") then
								continue
							end

							descendant:Destroy()
						end

						task.wait()

						for _, part in pairs(folder2:GetDescendants()) do
							if not (tostring(part) == "Head" and part:IsA("Part")) then
								continue
							end

							local cFrame = folder2.HumanoidRootPart.CFrame
							local bodyVelocity = Instance.new("BodyVelocity")
							bodyVelocity.MaxForce = createVector(40000, 40000, 40000)
							local v22 = -cFrame.RightVector
							local v23 = 50
							local v24 = 75

							if not v24 and v23 then
								v24 = v23
								v23 = 1
							end

							if not (v24 or v23) then
								v23 = 0
								v24 = 1
							end

							bodyVelocity.Velocity = v22 * random:NextNumber(v23, v24)
							bodyVelocity.Velocity *= createVector(1, 0, 1)
							bodyVelocity.Velocity += createVector(0, 25, 0)
							bodyVelocity.Parent = part
							local Debris = game:GetService("Debris")
							Debris:AddItem(bodyVelocity, 0.15)
						end

						for k, C0 in pairs(v21) do
							local weld = Instance.new("Weld")
							weld.Part0 = folder2.Head
							weld.Part1 = k
							weld.C0 = C0
							weld.Parent = k
						end
					end
				}
			},
			["Time Shift"] = {
				VictimAnim = 113625501003066,
				GrabOffset = CFrame.new(-4.76837158e-7, 0, -6.61999893, -1, 0, 0, 0, 1, 0, 0, 0, -1),
				ForceStopAnim = true,
				DontCFrame = true,
				DontRagdoll = true,
				Markers = {
					DelayedBarrage = function()
						task.delay(0.3, function()
							if not (folder2 and workspace.Live:FindFirstChild((tostring(folder2)))) then
								return
							end

							folder2:SetPrimaryPartCFrame(folder.PrimaryPart.CFrame * CFrame.new(0, 1, -15) * CFrame.Angles(
								0,
								3.141592653589793,
								0
							))
							fn16()
							v15:Stop(0)
							shared.ragdoll({
								hit = folder2,
								time = 10
							})
							fn20(folder2)
							local bodyVelocity = Instance.new("BodyVelocity")
							bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
							bodyVelocity.Velocity = folder.PrimaryPart.CFrame.lookVector * math.random(110, 130) + createVector(
								0,
								10,
								0
							)
							bodyVelocity.Parent = folder2.PrimaryPart
							game.Debris:AddItem(bodyVelocity, 0.15)
							local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
							bodyAngularVelocity.Name = "BAV"
							bodyAngularVelocity.AngularVelocity = Vector3.new(
								math.random(5, 10),
								math.random(1, 5),
								math.random(2, 6)
							)
							bodyAngularVelocity.MaxTorque = createVector(40000, 40000, 40000)
							bodyAngularVelocity.Parent = folder2.PrimaryPart
							game:service("Debris"):AddItem(bodyAngularVelocity, 0.15)
						end)
					end
				}
			},
			["Iron Combo"] = {
				VictimAnim = 78859491728288,
				GrabOffset = CFrame.new(0, 0, 0),
				ForceStopAnim = true,
				VictimSfx = "rbxassetid://72067766402768",
				DontCFrame = true,
				Markers = {
					Hit5 = function()
						v15:Stop(0)
						folder2:SetPrimaryPartCFrame(folder.Torso.CFrame * CFrame.new(
							0,
							0,
							-3,
							-1,
							0,
							0,
							0,
							1,
							0,
							0,
							0,
							-1
						))
						fn16()
						fn20()
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.MaxForce = createVector(40000, 40000, 40000)
						bodyVelocity.Velocity = folder.PrimaryPart.CFrame.lookVector * 100 + createVector(0, 5, 0)
						bodyVelocity.Parent = folder2.PrimaryPart
						game.Debris:AddItem(bodyVelocity, 0.2)
						local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
						bodyAngularVelocity.Name = "BAV"
						bodyAngularVelocity.AngularVelocity = Vector3.new(
							math.random(5, 10),
							math.random(1, 5),
							math.random(2, 6)
						)
						bodyAngularVelocity.MaxTorque = createVector(40000, 40000, 40000)
						bodyAngularVelocity.Parent = folder2.PrimaryPart
						game:service("Debris"):AddItem(bodyAngularVelocity, 0.15)
					end
				}
			},
			["STILL FUNNY?"] = {
				VictimAnim = 85778791969923,
				GrabOffset = CFrame.new(0, 0, -3) * CFrame.Angles(0, 3.141592653589793, 0),
				ForceStopAnim = true,
				DontDisconnectMarkers = true,
				Markers = {
					headbutt = function()
						known += 1

						if known == 6 then
							flag = true
							shared.cfolder({
								Name = "RootAnchor",
								Parent = folder2
							})
							local forceField = Instance.new("ForceField")
							forceField.Visible = false
							forceField.Name = "AbsoluteImmortal"
							forceField.Parent = folder2
							v15:AdjustSpeed(0)
							fn19({
								startpos = folder2.Head.Position,
								["end"] = createVector(0, -24, 0),
								amount = 6,
								nosound = true,
								size = 0.45
							})
							fn19({
								["end"] = createVector(0, -24, 0),
								amount = 8,
								nosound = true,
								nosmoke = true,
								size = 1.5,
								startpos = folder2.Head.Position,
								sizemult = 2.35
							})
						end
					end
				}
			},
			["Beneath Me"] = {
				VictimAnim = 74811458332755,
				GrabOffset = CFrame.new(0, 0, 0),
				ForceStopAnim = true,
				Markers = {
					stomp = function()
						fn4({ folder, folder2 }, 3)
					end,
					stomp2 = function()
						fn4({ folder, folder2 }, 8)
						fn16()
						shared.ragdoll({
							hit = folder2,
							time = 20
						})
						fn20()
						fn17({
							Velocity = Vector3.new(0, math.random(100, 125), 0),
							DeletionTime = Random.new():NextNumber(0.1, 0.125)
						})
						fn19({
							startpos = folder2.PrimaryPart.Position,
							["end"] = createVector(0, -24, 0),
							amount = 6,
							nosound = true,
							size = 0.3
						})
						fn19({
							["end"] = createVector(0, -24, 0),
							amount = 9,
							nosound = true,
							nosmoke = true,
							size = 1.34,
							startpos = folder2.PrimaryPart.Position,
							sizemult = 2
						})
					end
				}
			},
			Sword = {
				GrabOffset = CFrame.new(0, 0, -8) * CFrame.Angles(0, 3.141592653589793, 0),
				Markers = {
					hit = function() end
				}
			},
			Embers = {
				VictimAnim = 92638342824234,
				DontDisconnectMarkers = true,
				GrabOffset = CFrame.new(
					-0.0000305175781,
					0,
					-3.00003052,
					-0.999999881,
					0,
					-2.98023224e-8,
					0,
					1,
					0,
					-2.98023224e-8,
					0,
					-1.00000024
				),
				Markers = {
					hit = function() end,
					heavy = function()
						folder2:SetPrimaryPartCFrame(folder.PrimaryPart.CFrame * CFrame.new(
							-0.0000305175781,
							0,
							-3.00003052,
							-0.999999881,
							0,
							-2.98023224e-8,
							0,
							1,
							0,
							-2.98023224e-8,
							0,
							-1.00000024
						))
						fn16()
						v15:Stop(0)
						shared.ragdoll({
							hit = folder2,
							time = 10
						})
						fn20()
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
						bodyVelocity.Velocity = folder.PrimaryPart.CFrame.lookVector * (math.random(170, 200) * Random.new():NextNumber(
							1.75,
							2
						)) + createVector(0, 80, 0)
						bodyVelocity.Parent = folder2.PrimaryPart
						game.Debris:AddItem(bodyVelocity, 0.15)
						fn4({ folder, folder2 }, 9, 0.35)
						local hit = folder2
						local Hitbox = require(game.ServerStorage.Hitbox)
						Hitbox:CheckCollision({
							hit = hit,
							dmg = 0,
							time = 3,
							NoCrater = true,
							nosound = true,
							AccurateCheck = true,
							IgnoreRankedWalls = true,
							CraterTime = 3,
							callback = function(_, p4)
								local v22, v23 = fn11({
									orig = hit.PrimaryPart.Position,
									dir = createVector(0, -37.5, 0)
								})

								if not v22 or p4 or not (hit.Parent and hit.PrimaryPart and hit.PrimaryPart.Parent) then
									return
								end

								for _, character in pairs({ hit, folder }) do
									local playerFromCharacter2 = game.Players:GetPlayerFromCharacter(character)

									if playerFromCharacter2 then
										game.ReplicatedStorage.Replication:FireClient(playerFromCharacter2, {
											Effect = "Camshake",
											Intensity = 8,
											Last = 0.75
										})
									end
								end

								task.spawn(function()
									hit.PrimaryPart.AssemblyLinearVelocity = createVector(0, -250, 0)

									for _, part in pairs(hit:GetChildren()) do
										if part:IsA("BasePart") then
											part.AssemblyLinearVelocity = createVector(0, -250, 0)
										end
									end

									local RunService2 = game:GetService("RunService")
									RunService2.Heartbeat:Wait()
									hit.PrimaryPart.AssemblyLinearVelocity = createVector(0, -250, 0)

									for _, part in pairs(hit:GetChildren()) do
										if part:IsA("BasePart") then
											part.AssemblyLinearVelocity = createVector(0, -250, 0)
										end
									end
								end)
								shared.sfx({
									SoundId = "rbxassetid://14700241589",
									CFrame = CFrame.new(v23),
									Volume = 3
								}):Play()
								game.ReplicatedStorage.Replication:FireAllClients({
									Effect = "Ground Crater",
									Seed = math.random(1, 2000000000),
									start = v23 + createVector(0, 0.1, 0),
									["end"] = createVector(0, -24, 0),
									amount = 6,
									size = 0.3
								})
								game.ReplicatedStorage.Replication:FireAllClients({
									Effect = "Ground Crater",
									Seed = math.random(1, 2000000000),
									start = v23 + createVector(0, 0.1, 0),
									["end"] = createVector(0, -14, 0),
									amount = 6,
									sizemult = 1.35,
									size = 2
								})
								game.ReplicatedStorage.Replication:FireAllClients({
									Effect = "Ground Crater",
									Seed = math.random(1, 2000000000),
									start = v23 + createVector(0, 0.1, 0),
									["end"] = createVector(0, -14, 0),
									amount = 9,
									nosound = true,
									sizemult = 1.75,
									size = 3
								})
							end,
							caller = folder
						})
					end
				}
			},
			Emerge = {
				VictimAnim = 80959191469176,
				GrabOffset = CFrame.new(0, 0, -3) * CFrame.Angles(0, 3.141592653589793, 0),
				Tasks = {
					[5] = function()
						if table.find(v10, known) then
							table.remove(v10, table.find(v10, known))
						end

						known:SetPrimaryPartCFrame(primaryPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(
							0,
							3.141592653589793,
							0
						))
						fn4({ folder, folder2 }, 2, 0.35)
						fn3(folder2)
						shared.cfolder({
							Name = "ConfirmedEmerge",
							Parent = folder
						}, 2)
						task.wait()
						local v21 = nil

						for _, v23 in pairs(known:FindFirstChildOfClass("Humanoid"):GetPlayingAnimationTracks()) do
							if v23.Animation.AnimationId ~= "rbxassetid://79286058656616" then
								continue
							end

							v21 = v23
							break
						end

						local v23 = false

						if v19 then
							v19.Stopped:Once(function()
								known.PrimaryPart.Anchored = false
								known:SetAttribute("Moved", true)
								v21:Stop(0)
								game.ReplicatedStorage.Replication:FireAllClients({
									Effect = "Best Brother",
									char = folder,
									Known = known,
									custom = "Emerge",
									ExtraData = {
										TimePosition = v23 and v21.TimePosition or nil,
										Distance = primaryPart.CFrame:ToObjectSpace(known.Torso.CFrame).Z
									}
								})
								task.wait()
								game.Debris:AddItem(known, 0)
							end)
						end

						task.delay(6.5, function()
							v23 = true

							if v21 then
								v21:AdjustSpeed(0)
							end

							task.delay(0.5, function()
								v19:AdjustSpeed(0)
							end)
						end)
					end
				},
				Startup = function()
					local v21 = nil

					for _, v23 in pairs(folder:FindFirstChildOfClass("Humanoid"):GetPlayingAnimationTracks()) do
						if v23.Animation.AnimationId ~= "rbxassetid://76857454472003" then
							continue
						end

						v21 = v23
						break
					end

					if v21 then
						v21:AdjustSpeed(1.0725)
						task.delay(6, function()
							v21:AdjustSpeed(0.6)
						end)
						v19 = v21
					end

					local clone = script.VFX.RealAssets.Emerge.VictimCLone:Clone()
					local forceField = Instance.new("ForceField")
					forceField.Visible = false
					forceField.Name = "AbsoluteImmortal"
					forceField.Parent = clone
					game.Debris:AddItem(clone, 100)
					clone:SetAttribute("DeletionTime", 100)
					known = clone
					clone.PrimaryPart.Anchored = true
					clone.Parent = workspace.Thrown
					clone:SetPrimaryPartCFrame(primaryPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(
						0,
						3.141592653589793,
						0
					))
					table.insert(v10, clone)
					spawn(function()
						local child = game.Players:FindFirstChild((tostring(v16)))
						local humanoidDescriptionFromUserId = child and game.Players:GetHumanoidDescriptionFromUserId(child.UserId)

						if humanoidDescriptionFromUserId then
							for _, descendant in pairs(clone:GetDescendants()) do
								if descendant:IsA("Accessory") or descendant:IsA("Shirt") or descendant:IsA("Pants") then
									descendant:Destroy("")
								end

								if not (descendant:IsA("Decal") and string.lower(descendant.Name):find("face")) then
									continue
								end

								descendant:Destroy("")
							end

							clone.Humanoid:ApplyDescription(humanoidDescriptionFromUserId)
						end
					end)
					clone:SetAttribute("EmoteProperty", true)
					clone.Name = "EmergeClone_" .. tostring(folder2)
					local animation = Instance.new("Animation")
					game.Debris:AddItem(animation, 15)
					animation.AnimationId = "rbxassetid://79286058656616"
					clone.Humanoid:LoadAnimation(animation):Play()
				end
			},
			["Celestial Banisher"] = {
				VictimAnim = 100470788107007,
				GrabOffset = CFrame.new(0, 0, -5, -1, 0, 0, 0, 1, 0, 0, 0, -1),
				Markers = {
					strike = function()
						local strikeAttachment = folder["Right Arm"]:FindFirstChild("StrikeAttachment")

						if strikeAttachment then
							for _, child in pairs(strikeAttachment:GetChildren()) do
								child.Enabled = false
							end

							game.Debris:AddItem(strikeAttachment, 1)
						end

						local clone = script.StrikeThing:Clone()
						clone.Parent = workspace.Thrown
						clone.StrikeAttachment:Destroy("")
						game.Debris:AddItem(clone, 5)
						clone.CFrame = primaryPart.CFrame * CFrame.new(
							-0.0829162598,
							0.475000024,
							-6.14273071,
							1,
							0,
							0,
							0,
							1,
							0,
							0,
							0,
							1
						)
						fn2(clone)
						fn4({ folder, folder2 }, 10, 0.35)
						local startpos = folder.PrimaryPart.Position + folder.PrimaryPart.CFrame.lookVector * 5
						fn19({
							startpos = startpos,
							["end"] = createVector(0, -24, 0),
							amount = 6,
							size = 0.5
						})
						fn19({
							["end"] = createVector(0, -24, 0),
							amount = 9,
							nosmoke = true,
							size = 1.34,
							startpos = startpos,
							sizemult = 1.65,
							nosound = true
						})
						fn16()
						shared.ragdoll({
							hit = folder2,
							time = 20
						})
						fn20()
						fn17({
							Velocity = Vector3.new(0, math.random(100, 125), 0),
							DeletionTime = Random.new():NextNumber(0.1, 0.125)
						})
					end
				}
			},
			["Lethal Beam"] = {
				VictimAnim = 115156884318391,
				GrabOffset = CFrame.new(0, 0, 0),
				DontCFrame = true,
				DontRestoreVictimCollisions = true,
				Markers = {
					start = function()
						task.delay(Random.new():NextNumber(0.054, 0.1), function()
							local head = folder2.Head
							local decal = head:FindFirstChildOfClass("Decal")

							if decal then
								decal:Destroy()
							end

							head.Transparency = 1
							local parents = {}

							for _, weld in pairs(folder2:GetDescendants()) do
								if weld:IsA("Weld") and weld.Part0 == head then
									table.insert(parents, weld.Parent)
								end
							end

							for _, accessory in pairs(parents) do
								if accessory:IsA("Accessory") then
									accessory:Destroy()
								elseif accessory.Parent:IsA("Accessory") then
									accessory.Parent:Destroy()
								end
							end
						end)
						task.delay(2, function()
							flag = true
							local forceField = Instance.new("ForceField")
							forceField.Visible = false
							forceField.Name = "AbsoluteImmortal"
							forceField.Parent = folder2
							shared.cfolder({
								Name = "RootAnchor",
								Parent = folder2
							})
							fn16()
							v15:AdjustSpeed(0)
						end)
					end
				}
			},
			["Flower Bomb"] = {
				VictimAnim = 102465732893336,
				GrabOffset = CFrame.new(0, 0, 0),
				DontRestoreVictimCollisions = true,
				VictimSfx = "rbxassetid://93992210449674",
				VictimSfxVolume = 4.5,
				Markers = {
					f = function()
						folder2.Head.Transparency = 1
						local decal = folder2.Head:FindFirstChildOfClass("Decal")

						if decal then
							decal.Transparency = 1
						end

						for _, accessory in pairs(folder2:GetDescendants()) do
							if not accessory:IsA("Accessory") then
								continue
							end

							local weldConstraint = accessory:FindFirstChildOfClass("WeldConstraint")

							if weldConstraint and weldConstraint.Part0 == folder2.Head then
								accessory:Destroy("")
							end
						end

						if tostring(folder2) == "Weakest Dummy" then
							folder2.Hair.Handle.Transparency = 1
						end

						task.delay(0.8, function()
							fn16()
							shared.ragdoll({
								hit = folder2,
								time = 15
							})
						end)
					end
				}
			},
			["Sure Hit"] = {
				VictimAnim = 85149748400452,
				GrabOffset = CFrame.new(0, 0, -2),
				DontStopVicAnimationOnAnchorDeletion = true,
				StartTime = 0.7,
				Markers = {
					rip = function()
						folder2:SetAttribute("NoHeadLerp", true)
						local forceField = Instance.new("ForceField")
						forceField.Visible = false
						forceField.Name = "AbsoluteImmortal"
						forceField.Parent = folder2
						shared.cfolder({
							Name = "RootAnchor",
							Parent = folder2
						})
						local forceField2 = Instance.new("ForceField")
						forceField2.Parent = folder2
						forceField2.Visible = false
						folder2.Torso.Neck:Destroy()
						local head = folder2.Head
						head.Anchored = false
						head.CanCollide = false
						head.Massless = true
						head.Parent = workspace.Thrown

						for _, billboardGui in pairs(head:GetDescendants()) do
							if billboardGui:IsA("BillboardGui") then
								billboardGui:Destroy()
							end
						end

						local weld = Instance.new("Weld")

						for _, v21 in pairs({ head, weld }) do
							table.insert(v10, v21)
							game.Debris:AddItem(v21, 15)
						end

						head.CanQuery = false
						head.CanTouch = false
						head.Anchored = false
						head.Massless = true
						warn(head)
						weld.Parent = folder
						weld.Part0 = folder["Right Arm"]
						weld.Part1 = head
						weld.C1 = CFrame.new(0, 1.5, 0) * CFrame.Angles(0, 1.5707963267948966, 0)
						task.delay(1.85, function()
							fn16()
							v15:AdjustSpeed(0)
						end)
						shared.ragdoll({
							hit = folder2,
							time = 20
						})
						task.delay(1.5, function()
							if head and head.Parent then
								local function fadeOut(p4)
									local TweenService2 = game:GetService("TweenService")
									TweenService2:Create(p4, TweenInfo.new(0.65), {
										Transparency = 1
									}):Play()
								end

								local function fadeOutDescendants(folder3)
									for _, descendant in pairs(folder3:GetDescendants()) do
										if not (descendant:IsA("Part") or descendant:IsA("MeshPart") or descendant:IsA("Decal")) then
											continue
										end

										fadeOut(descendant)
									end
								end

								for _, accessory in pairs(folder2:GetDescendants()) do
									if accessory:IsA("Accessory") then
										fadeOutDescendants(accessory)
									end
								end

								fadeOut(head)
								fadeOutDescendants(head)
							end
						end)
					end
				}
			},
			["Eternal Seal"] = {
				VictimAnim = 74819612786417,
				GrabOffset = CFrame.new(0, 0, 0),
				DontStopVicAnimationOnAnchorDeletion = true,
				EndOffset = CFrame.new(
					-1.01794529,
					-0.614216805,
					-26.8296661,
					-0.993651807,
					0.0824780315,
					0.0765090287,
					0.105090812,
					0.923230588,
					0.369596004,
					-0.0401519351,
					0.375290096,
					-0.926037431
				),
				Markers = {
					two = function()
						local forceField = Instance.new("ForceField")
						forceField.Visible = false
						forceField.Name = "AbsoluteImmortal"
						forceField.Parent = folder2
						shared.cfolder({
							Name = "RootAnchor",
							Parent = folder2
						})
						fn3(folder2)
						v15:AdjustSpeed(0)
						fn16()
						local name = v16.Name
						local playerFromCharacter2 = game.Players:GetPlayerFromCharacter(v16)

						if playerFromCharacter2 then
							name = playerFromCharacter2.DisplayName
						end

						game.ReplicatedStorage.Replication:FireAllClients({
							Effect = "System Message",
							Info = {
								Text = string.format("• %s has been sealed.", name),
								Color = Color3.fromRGB(205, 84, 75),
								Font = Enum.Font.SourceSansBold,
								FontSize = Enum.FontSize.Size24
							}
						})
					end
				}
			},
			["Ban Hammer"] = {
				VictimAnim = 88611791573910,
				GrabOffset = CFrame.new(0, 0, 0),
				DontStopVicAnimationOnAnchorDeletion = true,
				EndOffset = CFrame.new(0, -2, -8) * CFrame.Angles(-1.5707963267948966, 3.141592653589793, 0),
				Markers = {
					slam = function()
						local forceField = Instance.new("ForceField")
						forceField.Visible = false
						forceField.Name = "AbsoluteImmortal"
						forceField.Parent = folder2
						shared.cfolder({
							Name = "RootAnchor",
							Parent = folder2
						})
						game.ReplicatedStorage.Replication:FireAllClients({
							Effect = "Death FX",
							Character = folder2
						})
						fn4({ folder, folder2 }, 8)
						v15:Stop(0)
						fn16()
						shared.ragdoll({
							hit = folder2,
							time = 20
						})
						local name

						if v16 then
							name = v16.Name
						else
							name = folder2.Name
						end

						if name then
							game.ReplicatedStorage.Replication:FireAllClients({
								Effect = "System Message",
								Info = {
									Text = string.format(
										"• %s has been banned from the game <font size=\"10\" color=\"rgb(255, 255, 255)\">just kidding!!!</font>",
										name
									),
									Color = Color3.fromRGB(205, 84, 75),
									Font = Enum.Font.SourceSansBold,
									FontSize = Enum.FontSize.Size24
								}
							})
						end

						fn19({
							startpos = folder2.PrimaryPart.Position,
							["end"] = createVector(0, -24, 0),
							amount = 6,
							nosound = true,
							size = 0.45
						})
						fn19({
							["end"] = createVector(0, -24, 0),
							amount = 8,
							nosound = true,
							nosmoke = true,
							size = 1.5,
							startpos = folder2.PrimaryPart.Position,
							sizemult = 2.35
						})
					end
				}
			},
			["Heart Strike"] = {
				VictimAnim = 98112252644080,
				GrabOffset = CFrame.new(0, 0, 0),
				EndOffset = CFrame.new(0, 0, 10) * CFrame.Angles(0, 3.141592653589793, 0),
				VictimAnimStopped = true,
				DontStopVicAnimationOnAnchorDeletion = true,
				DontCFrame = true,
				Markers = {
					die = function()
						local forceField = Instance.new("ForceField")
						forceField.Visible = false
						forceField.Name = "AbsoluteImmortal"
						forceField.Parent = folder2
						local v21 = folder.Torso.CFrame * CFrame.new(4, 0, -4) * CFrame.Angles(
							0,
							-0.6981317007977318,
							0
						)
						fn16()
						folder2:SetPrimaryPartCFrame(v21)
					end
				}
			},
			["Boxed Up"] = {
				DontRestoreVictimCollisions = true,
				VictimAnim = 109129404577713,
				GrabOffset = CFrame.new(0, 0, -3.5) * CFrame.Angles(0, 3.141592653589793, 0),
				Markers = {
					down = function()
						shared.cfolder({
							Name = "RootAnchor",
							Parent = folder2
						})
						fn3(folder2)
						wait(0.2)

						if folder.PrimaryPart:FindFirstChild("Present") then
							table.remove(v10, table.find(v10, folder.PrimaryPart:FindFirstChild("Present")))

							for _, part in pairs(folder.PrimaryPart:FindFirstChild("Present"):GetDescendants()) do
								if not (part:IsA("Part") or part:IsA("MeshPart")) then
									continue
								end

								local TweenService2 = game:GetService("TweenService")
								TweenService2:Create(part, TweenInfo.new(0.25), {
									Transparency = 1
								}):Play()
							end
						end
					end,
					up = function()
						fn4({ folder, folder2 }, 3)
					end,
					axekick = function()
						fn4({ folder, folder2 }, 6, 0.15)
					end
				}
			},
			["Dragon Combo"] = {
				CanRotate = true,
				VictimAnim = 105042527798191,
				GrabOffset = CFrame.new(0, 0, -3) * CFrame.Angles(0, 3.141592653589793, 0),
				EndOffset = CFrame.new(-5, 0, -3) * CFrame.Angles(0, 3.141592653589793, 0),
				Markers = {
					kick = function()
						fn4({ folder, folder2 }, 4, 0.1)
						fn18({
							speed = 80,
							fallout = 0.9,
							endd = 5,
							deletiontime = 0.25
						})
					end,
					move2 = function()
						fn18({
							speed = 30,
							fallout = 0.935,
							endd = 5,
							deletiontime = 0.5
						})
					end,
					move = function()
						fn18({
							speed = 25,
							fallout = 0.935,
							endd = 5,
							deletiontime = 0.5
						})
					end,
					move3 = function()
						fn18({
							speed = 25,
							fallout = 0.935,
							endd = 5,
							deletiontime = 0.5
						})
					end,
					before = function()
						fn18({
							speed = 60,
							fallout = 0.95,
							endd = 5,
							deletiontime = 0.5
						})
					end,
					knee = function()
						fn4({ folder, folder2 }, 4, 0.1)
						fn18({
							speed = 80,
							fallout = 0.9,
							endd = 5,
							deletiontime = 0.25
						})
					end,
					elbow = function()
						fn18({
							speed = 80,
							fallout = 0.95,
							endd = 5,
							deletiontime = 1
						})

						for i = 1, 2 do
							if not realAnimation.IsPlaying then
								break
							end

							fn4({ folder, folder2 }, 2, i == 2 and 0.5 or 0.1)
							task.wait(0.25)
						end
					end,
					here = function()
						folder2:SetPrimaryPartCFrame(folder.PrimaryPart.CFrame * CFrame.new(-5, 0, -3) * CFrame.Angles(
							0,
							3.141592653589793,
							0
						))
					end,
					connect = function() end,
					finished = function()
						fn4({ folder, folder2 }, 8, 0.5)
						fn16()
						fn20()
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
						bodyVelocity.Velocity = -folder.PrimaryPart.CFrame.RightVector * 10 + createVector(0, -50, 0)
						bodyVelocity.Parent = folder2.PrimaryPart
						task.delay(0.1, function()
							bodyVelocity.Velocity = createVector(0, 150, 0)
						end)
						game.Debris:AddItem(bodyVelocity, 0.15)
						local position = folder2.PrimaryPart.Position
						fn10({
							SoundId = "rbxassetid://126972610957117",
							CFrame = CFrame.new(position),
							TimePosition = 1,
							Volume = 4
						}):Resume()
						fn19({
							startpos = position,
							["end"] = createVector(0, -24, 0),
							amount = 6,
							size = 0.3
						})
						fn19({
							["end"] = createVector(0, -24, 0),
							amount = 9,
							nosmoke = true,
							size = 1.34,
							startpos = position,
							sizemult = 2,
							nosound = true
						})
					end
				}
			},
			Ruthless = {
				VictimAnim = 90695671597431,
				GrabOffset = CFrame.new(0, 0, 0),
				VictimSfx = "rbxassetid://75797337808333",
				DontCFrame = true,
				DontRagdoll = true,
				DontStopVicAnimationOnAnchorDeletion = true,
				Markers = {
					heavypunch = function()
						fn10({
							SoundId = "rbxassetid://81685116276323",
							CFrame = folder.Torso.CFrame,
							Volume = 2
						}):Play()
						folder2:SetPrimaryPartCFrame(folder.PrimaryPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(
							0,
							3.141592653589793,
							0
						))
						fn16()
						v15:Stop(0)
						shared.ragdoll({
							hit = folder2,
							time = 10
						})
						fn20()
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
						bodyVelocity.Velocity = folder.PrimaryPart.CFrame.lookVector * math.random(110, 130) + createVector(
							0,
							10,
							0
						)
						bodyVelocity.Parent = folder2.PrimaryPart
						game.Debris:AddItem(bodyVelocity, 0.15)
						fn4({ folder, folder2 }, 8, 0.35)
					end
				}
			},
			["Explosive Stomps"] = {
				VictimAnim = 106851865870767,
				GrabOffset = CFrame.new(0, 0, -4) * CFrame.Angles(0, 3.141592653589793, 0),
				CanRotate = true,
				VictimSfx = "rbxassetid://76659395557193",
				Markers = {
					laststomp = function()
						fn4({ folder, folder2 }, 8)
						folder2:SetPrimaryPartCFrame(primaryPart.CFrame * CFrame.new(0, 0, -4) * CFrame.Angles(
							0,
							3.141592653589793,
							0
						))
						fn16()
						fn20()
						shared.ragdoll({
							hit = folder2,
							time = 20
						})
						fn17({
							Velocity = Vector3.new(0, math.random(100, 125), 0),
							DeletionTime = Random.new():NextNumber(0.1, 0.125)
						})
						fn19({
							startpos = folder2.PrimaryPart.Position,
							["end"] = createVector(0, -24, 0),
							amount = 4,
							nosound = true,
							size = 0.3
						})
						fn19({
							["end"] = createVector(0, -24, 0),
							amount = 12,
							nosound = true,
							nosmoke = true,
							size = 1.5,
							startpos = folder2.PrimaryPart.Position,
							sizemult = 2.15
						})
					end
				}
			},
			Weak = {
				VictimAnim = 119807482462660,
				GrabOffset = CFrame.new(0, -0.1, -2.9) * CFrame.Angles(0, 3.141592653589793, 0),
				CanRotate = true,
				VictimSfx = "rbxassetid://115534752820424",
				Markers = {
					crack = function()
						folder2:SetPrimaryPartCFrame(primaryPart.CFrame * CFrame.new(0, -0.1, -2.9) * CFrame.Angles(
							0,
							3.141592653589793,
							0
						))
						task.delay(0.91, function()
							fn16()
							v15:Stop(0)
						end)
						fn4({ folder, folder2 }, 6, 0.065)
					end
				}
			},
			["Energy Barrage"] = {
				VictimAnim = 96013088878070,
				GrabOffset = CFrame.new(0, 0, -3.15) * CFrame.Angles(0, 3.141592653589793, 0),
				DontCFrame = true,
				DontRagdoll = true,
				DontStopVicAnimationOnAnchorDeletion = true,
				DontRestoreVictimCollisions = true,
				Markers = {
					start = function()
						tick()
						folder2:SetPrimaryPartCFrame(primaryPart.CFrame * CFrame.new(0, 0, -3.15) * CFrame.Angles(
							0,
							3.141592653589793,
							0
						))
						task.delay(1.2, function()
							shared.cfolder({
								Name = "RootAnchor",
								Parent = folder2
							}, 0.35)
							fn16()
							v15:Stop(0)
							shared.ragdoll({
								hit = folder2,
								time = 25
							})
							folder2:SetPrimaryPartCFrame(primaryPart.CFrame * CFrame.new(0, -2, -3.75) * CFrame.Angles(
								-1.5707963267948966,
								0,
								0
							))
							folder2.PrimaryPart.Velocity = createVector(0, 0, 0)
						end)
					end
				}
			},
			Yaiba = {
				VictimAnim = 136858325228865,
				GrabOffset = CFrame.new(0, 0, 0),
				DontRagdoll = true,
				ForceStopAnim = true,
				DontCFrame = true,
				DontStopVicAnimationOnAnchorDeletion = true,
				EndOffset = CFrame.new(0, 3, -8, -1, 0, 0, 0, 1, 0, 0, 0, -1),
				DontRestoreVictimCollisions = true,
				Tasks = {
					[8.55] = function()
						local folder3 = folder2
						v15:AdjustSpeed(0)
						local v21 = {}

						for _, accessory in pairs(folder2:GetDescendants()) do
							if not (accessory:IsA("Accessory") and accessory.Parent:IsA("Part")) then
								continue
							end

							local handle = accessory:FindFirstChild("Handle")

							if handle then
								v21[handle] = folder2.Head.CFrame:toObjectSpace(handle.CFrame)
							end
						end

						shared.sfx({
							SoundId = "rbxassetid://5868574236",
							Parent = folder3.PrimaryPart,
							TimePosition = 0.35,
							Volume = 4
						}):Resume()
						task.delay(0, function()
							if shared.checkjointbreaker(folder3) then
								return
							end

							for _, ballSocketConstraint in pairs(folder3:GetDescendants()) do
								if ballSocketConstraint:IsA("BallSocketConstraint") then
									ballSocketConstraint:Destroy()
								end
							end

							folder3:SetAttribute("BreakJointed", true)
							folder3:BreakJoints()
							fn20()
							task.wait()

							for _, descendant in pairs(folder3:GetDescendants()) do
								if descendant:IsA("BallSocketConstraint") or descendant:IsA("Weld") then
									descendant:Destroy()
								end
							end

							for _, part in pairs(folder3:GetChildren()) do
								if not part:IsA("Part") then
									continue
								end

								local bodyVelocity = Instance.new("BodyVelocity")
								bodyVelocity.MaxForce = createVector(40000, 40000, 40000)
								bodyVelocity.Velocity = primaryPart.CFrame.lookVector * 110 + createVector(25, 90, 0)
								bodyVelocity.Parent = part
								local Debris = game:GetService("Debris")
								Debris:AddItem(bodyVelocity, 0.15)
							end

							for k, C0 in pairs(v21) do
								local weld = Instance.new("Weld")
								weld.Part0 = folder2.Head
								weld.Part1 = k
								weld.C0 = C0
								weld.Parent = k
							end

							folder3.Humanoid.Health = 0
						end)
						task.delay(0.065, function()
							for _, character in pairs({ folder3, folder }) do
								local playerFromCharacter2 = game.Players:GetPlayerFromCharacter(character)

								if playerFromCharacter2 then
									game.ReplicatedStorage.Replication:FireClient(playerFromCharacter2, {
										Effect = "Camshake",
										Intensity = 15,
										Last = 0.5
									})
								end
							end
						end)
						folder3:SetAttribute("Finisherd", true)
						task.delay(0.25, function()
							local Hitbox = require(game.ServerStorage.Hitbox)
							Hitbox:CheckCollision({
								hit = folder3,
								dmg = 0,
								breaktrees = true,
								time = 4.4,
								AccurateCheck = true,
								caller = folder
							})
						end)
					end
				}
			},
			["Nuclear Impact"] = {
				VictimAnim = 73060038714979,
				GrabOffset = CFrame.new(0, 0, 0),
				DontRagdoll = true,
				ForceStopAnim = true,
				DontCFrame = true,
				DontStopVicAnimationOnAnchorDeletion = true,
				EndOffset = CFrame.new(0, 0, -11, -1, 0, 0, 0, 1, 0, 0, 0, -1),
				DontRestoreVictimCollisions = true,
				Tasks = {
					[21.42] = function()
						local folder3 = folder2
						v15:AdjustSpeed(0)
						local v21 = {}

						for _, accessory in pairs(folder2:GetDescendants()) do
							if not (accessory:IsA("Accessory") and accessory.Parent:IsA("Part")) then
								continue
							end

							local handle = accessory:FindFirstChild("Handle")

							if handle then
								v21[handle] = folder2.Head.CFrame:toObjectSpace(handle.CFrame)
							end
						end

						task.delay(0, function()
							if shared.checkjointbreaker(folder3) then
								return
							end

							for _, ballSocketConstraint in pairs(folder3:GetDescendants()) do
								if ballSocketConstraint:IsA("BallSocketConstraint") then
									ballSocketConstraint:Destroy()
								end
							end

							folder3:SetAttribute("BreakJointed", true)
							folder3:BreakJoints()
							fn20()
							task.wait()

							for _, descendant in pairs(folder3:GetDescendants()) do
								if descendant:IsA("BallSocketConstraint") or descendant:IsA("Weld") then
									descendant:Destroy()
								end
							end

							for _, part in pairs(folder3:GetChildren()) do
								if not part:IsA("Part") then
									continue
								end

								local bodyVelocity = Instance.new("BodyVelocity")
								bodyVelocity.MaxForce = createVector(40000, 40000, 40000)
								bodyVelocity.Velocity = primaryPart.CFrame.lookVector * 110 + createVector(25, 90, 0)
								bodyVelocity.Parent = part
								local Debris = game:GetService("Debris")
								Debris:AddItem(bodyVelocity, 0.15)
							end

							for k, C0 in pairs(v21) do
								local weld = Instance.new("Weld")
								weld.Part0 = folder2.Head
								weld.Part1 = k
								weld.C0 = C0
								weld.Parent = k
							end

							folder3.Humanoid.Health = 0
						end)
						task.delay(0.065, function()
							for _, character in pairs({ folder3, folder }) do
								local playerFromCharacter2 = game.Players:GetPlayerFromCharacter(character)

								if playerFromCharacter2 then
									game.ReplicatedStorage.Replication:FireClient(playerFromCharacter2, {
										Effect = "Camshake",
										Intensity = 15,
										Last = 0.5
									})
								end
							end
						end)
						folder3:SetAttribute("Finisherd", true)
						task.delay(0.25, function()
							local Hitbox = require(game.ServerStorage.Hitbox)
							Hitbox:CheckCollision({
								hit = folder3,
								dmg = 0,
								breaktrees = true,
								time = 4.4,
								AccurateCheck = true,
								caller = folder
							})
						end)
					end
				}
			},
			Insect = {
				VictimAnim = 70500126966316,
				GrabOffset = CFrame.new(0, 0, -4) * CFrame.Angles(0, 3.141592653589793, 0),
				Markers = {
					flick = function()
						fn16()
						fn4({ folder, folder2 }, 6, 0.15)
						fn20()
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.MaxForce = createVector(40000, 40000, 40000)
						bodyVelocity.Velocity = folder.PrimaryPart.CFrame.lookVector * 500 + createVector(0, 50, 0)
						bodyVelocity.Parent = folder2.PrimaryPart
						game.Debris:AddItem(bodyVelocity, 0.2)
						local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
						bodyAngularVelocity.Name = "BAV"
						bodyAngularVelocity.AngularVelocity = Vector3.new(
							math.random(5, 10),
							math.random(1, 5),
							math.random(2, 6)
						)
						bodyAngularVelocity.MaxTorque = createVector(40000, 40000, 40000)
						bodyAngularVelocity.Parent = folder2.PrimaryPart
						game:service("Debris"):AddItem(bodyAngularVelocity, 0.15)
						local hit = folder2
						shared.sfx({
							SoundId = "rbxassetid://74450756836645",
							Parent = hit.Torso,
							Volume = 3
						}):Play()
						local Hitbox = require(game.ServerStorage.Hitbox)
						Hitbox:CheckCollision({
							hit = hit,
							dmg = 0,
							time = 3,
							NoCrater = true,
							nosound = true,
							AccurateCheck = true,
							IgnoreRankedWalls = true,
							CraterTime = 3,
							callback = function(_, p4)
								local v22, v23 = fn11({
									orig = hit.PrimaryPart.Position,
									dir = createVector(0, -37.5, 0)
								})

								if not v22 or p4 or not (hit.Parent and hit.PrimaryPart and hit.PrimaryPart.Parent) then
									return
								end

								for _, character in pairs({ hit, folder }) do
									local playerFromCharacter2 = game.Players:GetPlayerFromCharacter(character)

									if playerFromCharacter2 then
										game.ReplicatedStorage.Replication:FireClient(playerFromCharacter2, {
											Effect = "Camshake",
											Intensity = 8,
											Last = 0.75
										})
									end
								end

								task.spawn(function()
									hit.PrimaryPart.AssemblyLinearVelocity = createVector(0, -250, 0)

									for _, part in pairs(hit:GetChildren()) do
										if part:IsA("BasePart") then
											part.AssemblyLinearVelocity = createVector(0, -250, 0)
										end
									end

									local RunService2 = game:GetService("RunService")
									RunService2.Heartbeat:Wait()
									hit.PrimaryPart.AssemblyLinearVelocity = createVector(0, -250, 0)

									for _, part in pairs(hit:GetChildren()) do
										if part:IsA("BasePart") then
											part.AssemblyLinearVelocity = createVector(0, -250, 0)
										end
									end
								end)
								shared.sfx({
									SoundId = "rbxassetid://14700241589",
									CFrame = CFrame.new(v23),
									Volume = 5
								}):Play()
								shared.sfx({
									SoundId = "rbxassetid://14392660963",
									CFrame = CFrame.new(v23),
									Volume = 7
								}):Play()
								game.ReplicatedStorage.Replication:FireAllClients({
									Effect = "Ground Crater",
									Seed = math.random(1, 2000000000),
									start = v23 + createVector(0, 0.1, 0),
									["end"] = createVector(0, -24, 0),
									amount = 6,
									nosound = true,
									size = 0.3
								})
								game.ReplicatedStorage.Replication:FireAllClients({
									Effect = "Ground Crater",
									Seed = math.random(1, 2000000000),
									start = v23 + createVector(0, 0.1, 0),
									["end"] = createVector(0, -14, 0),
									amount = 6,
									nosound = true,
									sizemult = 1.35,
									size = 2
								})
								game.ReplicatedStorage.Replication:FireAllClients({
									Effect = "Ground Crater",
									Seed = math.random(1, 2000000000),
									start = v23 + createVector(0, 0.1, 0),
									["end"] = createVector(0, -14, 0),
									amount = 9,
									nosound = true,
									sizemult = 1.75,
									size = 3
								})
							end,
							caller = folder
						})
					end
				}
			},
			["Fly High"] = {
				VictimAnim = 136857536023148,
				GrabOffset = CFrame.new(0, 0, 0),
				EndOffset = CFrame.new(0, 0, 0),
				DontRestoreVictimCollisions = true,
				Startup = function(p4)
					fn10({
						SoundId = "rbxassetid://93273930314761",
						Parent = p4.Torso,
						Volume = 2
					}):Play()
				end,
				Markers = {
					throw = function()
						for _, descendant in pairs(folder2:GetDescendants()) do
							if descendant:IsA("Decal") or descendant:IsA("BillboardGui") then
								descendant:Destroy()
							end

							if not (descendant:IsA("Part") or descendant:IsA("MeshPart") or descendant:IsA("UnionOperation")) then
								continue
							end

							descendant.Transparency = 1
							descendant.CollisionGroup = "untouchable"
						end

						local forceField = Instance.new("ForceField")
						forceField.Visible = false
						forceField.Name = "AbsoluteImmortal"
						forceField.Parent = folder2
						shared.ragdoll({
							hit = folder2,
							time = 30
						})
					end
				}
			},
			Telekinesis = {
				VictimAnim = 132014753376350,
				GrabOffset = CFrame.new(0, 0, -3),
				DontCFrame = true,
				DontRagdoll = true,
				Markers = {
					crack = function()
						fn4({ folder, folder2 }, 3)
					end,
					send = function()
						fn4({ folder, folder2 }, 6)
						local v21 = folder.PrimaryPart.CFrame * CFrame.new(0, 3, -11) * CFrame.Angles(
							0,
							3.141592653589793,
							0
						)
						v15:Stop(0)
						fn16()
						folder2:PivotTo(v21)
						task.delay(0.065, function()
							shared.ragdoll({
								hit = folder2,
								time = 20
							})
						end)
						fn20()
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.MaxForce = createVector(40000, 40000, 40000)
						bodyVelocity.Velocity = -folder.PrimaryPart.CFrame.RightVector * 150 + createVector(0, 60, 0)
						bodyVelocity.Parent = folder2.PrimaryPart
						game.Debris:AddItem(bodyVelocity, 0.15)
						local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
						bodyAngularVelocity.Name = "BAV"
						bodyAngularVelocity.AngularVelocity = Vector3.new(
							math.random(5, 10),
							math.random(1, 5),
							math.random(2, 6)
						)
						bodyAngularVelocity.MaxTorque = createVector(40000, 40000, 40000)
						bodyAngularVelocity.Parent = folder2.PrimaryPart
						game:service("Debris"):AddItem(bodyAngularVelocity, 0.15)
						local hit = folder2
						local Hitbox = require(game.ServerStorage.Hitbox)
						Hitbox:CheckCollision({
							hit = hit,
							dmg = 0,
							time = 3,
							NoCrater = true,
							nosound = true,
							AccurateCheck = true,
							IgnoreRankedWalls = true,
							CraterTime = 3,
							callback = function(_, p4)
								local v23, v24 = fn11({
									orig = hit.PrimaryPart.Position,
									dir = createVector(0, -37.5, 0)
								})

								if not v23 or p4 or not (hit.Parent and hit.PrimaryPart and hit.PrimaryPart.Parent) then
									return
								end

								for _, character in pairs({ hit, folder }) do
									local playerFromCharacter2 = game.Players:GetPlayerFromCharacter(character)

									if playerFromCharacter2 then
										game.ReplicatedStorage.Replication:FireClient(playerFromCharacter2, {
											Effect = "Camshake",
											Intensity = 8,
											Last = 0.75
										})
									end
								end

								task.spawn(function()
									hit.PrimaryPart.AssemblyLinearVelocity = createVector(0, -250, 0)

									for _, part in pairs(hit:GetChildren()) do
										if part:IsA("BasePart") then
											part.AssemblyLinearVelocity = createVector(0, -250, 0)
										end
									end

									local RunService2 = game:GetService("RunService")
									RunService2.Heartbeat:Wait()
									hit.PrimaryPart.AssemblyLinearVelocity = createVector(0, -250, 0)

									for _, part in pairs(hit:GetChildren()) do
										if part:IsA("BasePart") then
											part.AssemblyLinearVelocity = createVector(0, -250, 0)
										end
									end
								end)
								shared.sfx({
									SoundId = "rbxassetid://14700241589",
									CFrame = CFrame.new(v24),
									Volume = 5
								}):Play()
								shared.sfx({
									SoundId = "rbxassetid://14392660963",
									CFrame = CFrame.new(v24),
									Volume = 7
								}):Play()
								game.ReplicatedStorage.Replication:FireAllClients({
									Effect = "Ground Crater",
									Seed = math.random(1, 2000000000),
									start = v24 + createVector(0, 0.1, 0),
									["end"] = createVector(0, -24, 0),
									amount = 6,
									nosound = true,
									size = 0.3
								})
								game.ReplicatedStorage.Replication:FireAllClients({
									Effect = "Ground Crater",
									Seed = math.random(1, 2000000000),
									start = v24 + createVector(0, 0.1, 0),
									["end"] = createVector(0, -14, 0),
									amount = 6,
									nosound = true,
									sizemult = 1.35,
									size = 2
								})
								game.ReplicatedStorage.Replication:FireAllClients({
									Effect = "Ground Crater",
									Seed = math.random(1, 2000000000),
									start = v24 + createVector(0, 0.1, 0),
									["end"] = createVector(0, -14, 0),
									amount = 9,
									nosound = true,
									sizemult = 1.75,
									size = 3
								})
							end,
							caller = folder
						})
					end
				}
			},
			Wipe = {
				VictimAnim = 77697087877839,
				GrabOffset = CFrame.new(0, 0, -6) * CFrame.Angles(0, 3.141592653589793, 0),
				EndOffset = CFrame.new(0, -1.5, -6) * CFrame.Angles(1.5707963267948966, 3.141592653589793, 0),
				Markers = {
					laser = function()
						if v16 and shared.p(v16) then
							game.ReplicatedStorage.Replication:FireClient(shared.p(v16), {
								Type = "FlashTemp"
							})
						end

						v15:AdjustSpeed(0.5)
						task.delay(1.35, function()
							fn16()
							shared.cfolder({
								Name = "RootAnchor",
								Parent = folder2
							}, 0.1)

							for _, part in pairs(folder2:GetChildren()) do
								if not part:IsA("BasePart") then
									continue
								end

								local v21 = part
								spawn(function()
									local lastTime = tick()

									while tick() - lastTime <= 0.15 and task.wait() do
										v21.Velocity = createVector(0, 0, 0)
									end
								end)
							end
						end)
					end
				}
			},
			["Sumo Slap"] = {
				VictimAnim = 139896484333492,
				GrabOffset = CFrame.new(0, 0, -3) * CFrame.Angles(0, 3.141592653589793, 0),
				ForceStopAnim = true,
				Tasks = {
					[5.65] = function()
						fn4({ folder, folder2 }, 8)
						fn16()
						shared.ragdoll({
							hit = folder2,
							time = 20
						})
						fn20()
						fn17({
							Velocity = Vector3.new(0, math.random(50, 80), 0),
							DeletionTime = Random.new():NextNumber(0.1, 0.125)
						})
					end
				}
			}
		}

		if v13 and not v13:GetAttribute("KillEmoteBegan") and v13 and not v13:FindFirstChild("KillEmoteFinished") then
			v13:FindFirstChild("Humanoid")
			v13:FindFirstChild("HumanoidRootPart")
			local v21 = v20[v4]

			if not v21 then
				return warn("no data")
			end

			for _, child in pairs(v13:GetChildren()) do
				if tostring(child) == "RootAnchor" then
					child:Destroy("")
				end
			end

			shared.cfolder({
				Name = "KillEmoteFinished",
				Parent = v13
			})
			v13:SetAttribute("KillEmoteBegan", true)
			local _ = primaryPart.CFrame
			local parent = v13
			local v23 = parent
			parent = v23
			local parts = {}
			local descendantAddedConnections = {}

			for _, folder3 in pairs({ v13 }) do
				for _, part in pairs(folder3:GetDescendants()) do
					if not part:IsA("BasePart") then
						continue
					end

					part.CollisionGroup = "nocol"
					table.insert(parts, part)
				end
			end

			local v25 = math.random(1, 100000)
			local objectValue = Instance.new("ObjectValue")
			objectValue.Value = folder
			objectValue.Name = "#PLAYERBIND"
			objectValue:SetAttribute("Person", (tostring(v23)))
			objectValue:SetAttribute("Random", v25)
			objectValue.Parent = game.ServerStorage.Replication
			table.insert(v10, objectValue)
			v23.Archivable = true
			shared.unragdoll({
				hit = v23,
				deadbypass = true
			})
			shared.cfolder({
				Name = "Freeze",
				Parent = parent
			}, 30)
			local clone = nil
			local thread = nil
			local flag2 = false
			local v26 = { "Wombo Combo" }

			if v23:GetAttribute("NPC") then
				v23:SetAttribute("Respawn", (tostring(folder)))
			end

			v16 = v23
			local forceField = Instance.new("ForceField")
			forceField.Visible = false
			forceField.Name = "AbsoluteImmortal"
			forceField.Parent = v23
			local cfolder2 = shared.cfolder({
				Name = "KillEmoteInProgress",
				Parent = folder
			}, 30)
			table.insert(v10, cfolder2)

			if not v23:GetAttribute("NPC") and not table.find(v26, v4) and v4 ~= "Wombo Combo" and not (workspace:GetAttribute("RankedOnes") or workspace:GetAttribute("RankedTwos")) then
				wait()

				for _, child in pairs(workspace.Live:GetChildren()) do
					if not (child:GetAttribute("NPC") and child.Name ~= "Weakest Dummy" and child:GetAttribute("Person") == tostring(v23)) then
						continue
					end

					child:Destroy()
				end

				v23:SetAttribute("ClonedChar", true)

				if shared.p(v23) then
					shared.p(v23):SetAttribute("ClonedChar", true)
					shared.p(v23):SetAttribute("Random", (tostring(v25)))
				end

				clone = v23:Clone()
				local forceField2 = clone:FindFirstChildOfClass("ForceField")

				if forceField2 then
					table.insert(v10, forceField2)
				end

				task.delay(30, function()
					if clone and clone.Parent then
						clone:Destroy()
					end
				end)
				local v27 = false

				local function fn21()
					if not v27 then
						v27 = true

						if flag2 or flag then
							return
						end

						for _, child in pairs(clone:GetChildren()) do
							if tostring(child) == "RootAnchor" then
								child:Destroy("")
							end
						end

						wait()
						shared.ragdoll({
							hit = clone,
							time = 10
						})
						task.delay(5, function()
							if clone then
								clone:Destroy()
							end
						end)
					end
				end

				if not (cfolder2 and cfolder2.Parent) then
					fn21()
					return warn("fired on purpose")
				end

				cfolder2.Destroying:Once(function()
					warn("fired")
					fn21()
				end)

				if shared.p(v23) then
					local v28 = shared.p(v23)
					local destroyingConnection = clone.Destroying:Once(function()
						if (playerFromCharacter:GetAttribute("DiedTime") or 0) < 2 and v28:GetAttribute("ClonedChar") and v28:GetAttribute("Random") == tostring(v25) then
							v28:LoadCharacter("")
						end
					end)
					task.delay(30, function()
						if destroyingConnection then
							destroyingConnection:Disconnect()
						end
					end)
				end

				clone:SetAttribute("NPC", true)
				clone:SetAttribute("EmoteThing", true)
				local v28 = tostring(v23)
				clone:SetAttribute("Person", v28)
				clone.Parent = workspace.Live
				game.ReplicatedStorage.Replication:FireClient(shared.p(v23), {
					Type = "HideHumanoidProperties",
					Humanoid = clone:FindFirstChildOfClass("Humanoid")
				})
				local cFrame = v23.PrimaryPart.CFrame
				clone:PivotTo(cFrame)
				clone.Name = tostring(clone) .. "_Clone"
				v23:SetAttribute("CloneOwner", (tostring(clone)))
				local objectValue2 = Instance.new("ObjectValue")
				objectValue2.Name = "NewCam"
				objectValue2.Value = clone
				objectValue2.Parent = v23;
				(function()
					for _, descendant in pairs(clone:GetDescendants()) do
						if descendant:IsA("Script") or descendant:IsA("LocalScript") then
							descendant.Enabled = false
						end

						if descendant:IsA("Accessory") and descendant:GetAttribute("Cfoldered") then
							descendant:Destroy()
						end

						if descendant:IsA("BodyMover") then
							descendant:Destroy("")
						end

						if tostring(descendant) == "RagdollRootWeld" and descendant:IsA("Weld") then
							descendant:Destroy("")
						end
					end
				end)()
				v16 = v23
				tostring(v23)
				local forceField3 = Instance.new("ForceField")
				forceField3.Name = "AbsoluteImmortal"
				forceField3.Visible = false
				forceField3.Parent = v16
				fn3(v16)
				task.delay(0.5, function()
					if v16 and v16.Parent then
						v16:SetPrimaryPartCFrame(CFrame.new(40000, 40000, 40000))
					end
				end)
				v23.PrimaryPart.Anchored = true
				v13 = clone
				v13:FindFirstChild("Humanoid")
				v13:FindFirstChild("HumanoidRootPart")
				v23 = clone
			end

			local cfolders = {}

			if not v21.CanRotate then
				local cfolder3 = shared.cfolder({
					Name = "NoRotate",
					Parent = folder
				}, 30)
				table.insert(cfolders, cfolder3)
				table.insert(v10, cfolder3)
			end

			table.insert(cfolders, cfolder2)

			if v21.VictimSfx then
				local v27 = fn10({
					SoundId = v21.VictimSfx,
					Parent = v13.Torso,
					Volume = v21.VictimSfxVolume or 2
				})
				v27:Play()
				table.insert(v10, v27)
			end

			if table.find(v26, v4) then
				local forceField2 = Instance.new("ForceField")
				forceField2.Name = "AbsoluteImmortal"
				forceField2.Visible = false
				forceField2.Parent = v16
			end

			task.delay(0.1, function()
				if v16 and v16.Parent and not table.find(v26, v4) and cfolder2 and cfolder2.Parent then
					v16:SetAttribute("DiedEmote", tick())
					local v27 = ({
						["Final Spark"] = 12
					})[v4] or 6

					if not workspace:GetAttribute("SkipTime") then
						workspace:SetAttribute("SkipTime", v27 - 1)
					end

					local v28 = shared.p(v16)

					if v28 then
						thread = task.delay(v27, function()
							if flag2 then
								return
							end

							game.ReplicatedStorage.Replication:FireClient(v28, {
								Type = "CanSkip"
							})
						end)
					end
				end
			end)
			local cfolder3 = shared.cfolder({
				Name = "DelayRespawn",
				Parent = v16 or v23
			}, 30)
			table.insert(v10, cfolder3)
			cfolder3:SetAttribute("Owner", (tostring(folder)))
			cfolder3:SetAttribute("Custom", true)
			table.insert(v14, cfolder3)
			local forceField2 = Instance.new("ForceField")
			forceField2.Visible = false
			game.Debris:AddItem(forceField2, 25)
			table.insert(v10, forceField2)
			folder2 = v13
			local v27 = folder2
			local AnimationPlayer = require(v13.CharacterHandler:WaitForChild("AnimationPlayer"))

			local function fn21(victimAnim)
				return AnimationPlayer.playAnimation(v13:FindFirstChild("Humanoid"), victimAnim)
			end

			local _ = { "Sword" }

			if VFX[v4] then
				local accessory = Instance.new("Accessory")
				accessory.Name = "#EmoteHolder_" .. math.random(1, 100000)
				accessory.Parent = folder
				accessory:SetAttribute("EmoteProperty", true)
				table.insert(v10, accessory)
				game.ReplicatedStorage.Replication:FireAllClients({
					Type = "ReplicateEmoteVfx",
					Character = folder,
					Victim = v13,
					CutsceneBind = v16,
					RealBind = accessory,
					vfxName = v4,
					SpecificModule = nil,
					AnimSent = result.Animation
				})
			end

			if v21.StartTime then
				realAnimation:AdjustSpeed(0)
				task.delay(v21.StartTime, function()
					realAnimation:AdjustSpeed(1)
				end)
			end

			if v21.Startup then
				v21.Startup(v13)
			end

			if v21.Markers then
				for k, marker in pairs(v21.Markers) do
					local connection = nil
					local v28 = marker
					connection = realAnimation:GetMarkerReachedSignal(k):Connect(function()
						if intcheck.interrupted or not workspace.Live:FindFirstChild((tostring(v27))) then
							return
						end

						if connection and not v21.DontDisconnectMarkers then
							connection:Disconnect()
						end

						return v28()
					end)
					table.insert(v10, connection)
					task.delay(22, function()
						if connection then
							return connection:Disconnect()
						end
					end)
				end
			end

			if v21.Tasks then
				for duration, task2 in pairs(v21.Tasks) do
					local thread2 = nil
					local v28 = task2
					thread2 = task.delay(duration, function()
						if intcheck.interrupted or not workspace.Live:FindFirstChild((tostring(v27))) then
							return
						end

						if table.find(v10, thread2) then
							table.remove(v10, table.find(v10, thread2))
						end

						v28()
					end)
					table.insert(v10, thread2)
				end
			end

			local v28

			if v21.VictimAnim then
				v28 = fn21(v21.VictimAnim)
				v28:Play()
				v15 = v28
				task.delay(0.15, function()
					if not v21.StartTime then
						v28.TimePosition = 0.15
						realAnimation.TimePosition = 0.15
						wait(0.1)
						v28.TimePosition = 0.25
						realAnimation.TimePosition = 0.25
					end
				end)

				if v21.ForceStopAnim then
					table.insert(v14, v28)
				end
			else
				v28 = nil
			end

			local cfolder4 = shared.cfolder({
				Name = "RootAnchor",
				Parent = v13
			})
			game.Debris:AddItem(cfolder4, 30)
			table.insert(v14, cfolder4)
			table.insert(v10, cfolder4)

			if v21.GrabOffset then
				fn15({
					offset = v21.GrabOffset,
					hit = v13,
					anchor = cfolder4
				})
				grabOffset = v21.GrabOffset
				v27:SetPrimaryPartCFrame(primaryPart.CFrame * grabOffset)
			end

			task.delay(1, function()
				if folder:FindFirstChild("KillEmoteInProgress") then
					return
				else
					return intcheck(true)
				end
			end)
			spawn(function()
				local v29 = { v13 }

				for _, folder3 in pairs(v29) do
					local descendantAddedConnection = folder3.DescendantAdded:connect(function(part)
						if part:IsA("BasePart") then
							part.CollisionGroup = "nocol"
							warn("changed", part)
							table.insert(parts, part)
						end
					end)
					task.delay(30, function()
						if descendantAddedConnection then
							return descendantAddedConnection:Disconnect()
						end
					end)
					table.insert(descendantAddedConnections, descendantAddedConnection)
					table.insert(v10, descendantAddedConnection)

					for _, part in pairs(folder3:GetDescendants()) do
						if not part:IsA("BasePart") then
							continue
						end

						part.CollisionGroup = "nocol"
						table.insert(parts, part)
					end
				end

				local v30 = math.random(1, 1000)

				if v16 then
					v16:SetAttribute("NumeroRandomGen", v30)
				end

				local function fn22()
					if flag2 then
						return warn("double fire")
					end

					flag2 = true

					if cfolder3 then
						cfolder3:Destroy("")
					end

					for _, v31 in pairs(cfolders) do
						v31:Destroy("")
					end

					if thread then
						task.cancel(thread)
					end

					if workspace.Live:FindFirstChild((tostring(folder))) then
						fn5(folder)
					end

					local absoluteImmortal = clone and clone:FindFirstChild("AbsoluteImmortal")

					if absoluteImmortal then
						absoluteImmortal:Destroy("")
					end

					if clone and v16 then
						local v32 = 5.5

						for _, child in pairs(workspace.Live:GetChildren()) do
							if tostring(child) ~= tostring(v16) then
								continue
							end

							if child:GetAttribute("NumeroRandomGen") == v30 then
								local parentChangedConnection = child:GetPropertyChangedSignal("Parent"):Once(function()
									game.Debris:AddItem(clone, 3.5)
								end)
								task.delay(v32 - 0.5, function()
									if parentChangedConnection then
										return parentChangedConnection:Disconnect()
									end
								end)
							else
								v32 = 2
							end
						end

						game.Debris:AddItem(clone, v32)
					end

					if flag or not workspace.Live:FindFirstChild((tostring(folder2))) then
						return
					end

					if v21.EndOffset then
						grabOffset = v21.EndOffset
					end

					if not v21.DontCFrame and folder2.PrimaryPart then
						folder2:SetPrimaryPartCFrame(folder.PrimaryPart.CFrame * grabOffset)
					end

					if v28 then
						if v28 and not v21.DontStopVicAnimationOnAnchorDeletion then
							v28:Stop(0)
						end

						if intcheck.interrupted then
							v28:Stop(0)
						end
					end

					if not v21.DontRagdoll or v21.DontRagdoll and intcheck.interrupted then
						shared.ragdoll({
							hit = folder2,
							time = 15
						})
					end

					if not v21.DontRestoreVictimCollisions then
						folder2.DescendantAdded:Connect(function(part)
							if part:IsA("BasePart") then
								part.CollisionGroup = part.Name:find("Hitbox_") and "limbs" or "Invisible"
							end
						end)

						for _, part in pairs(folder2:GetDescendants()) do
							if part:IsA("BasePart") then
								part.CollisionGroup = part.Name:find("Hitbox_") and "limbs" or "Invisible"
							end
						end
					end

					table.clear(parts)

					for _, connection in pairs(descendantAddedConnections) do
						connection:Disconnect()
					end
				end

				task.delay(0.1, function()
					if not cfolder4.Parent then
						fn22()
					end
				end)
				cfolder4:GetPropertyChangedSignal("Parent"):Connect(function()
					if not cfolder4.Parent then
						fn22()
					end
				end)
			end)
		end
	end

	if result.Startup and not intcheck.interrupted then
		result.Startup(v10, realAnimation, v12, result, intcheck, v11)

		if result.Key and v4 ~= "The Hunt" then
			local index = table.find({
				"First",
				"Second",
				"Third",
				"Fourth",
				"Fifth",
				"Sixth",
				"Seventh",
				"Eighth",
				"Ninth",
				"Tenth"
			}, string.gsub(v4, " Key", ""))
			local keyOffset = Info.KeyOffsets[index]
			local attachment = Instance.new("Attachment")
			attachment:SetAttribute("EmoteProperty", true)
			table.insert(v10, attachment)
			attachment.Parent = folder.PrimaryPart
			attachment.CFrame = keyOffset
			local clone = script.ImpactGlow2:Clone()
			clone.Parent = attachment
			clone:Emit(5)
			shared.sfx({
				SoundId = "rbxassetid://16748459318",
				Parent = attachment,
				Volume = 0.85
			}):Play()
		end

		if result.Dual then
			if result.Dual.Freeze == nil then
				realAnimation:AdjustSpeed(0)
				realAnimation.TimePosition = 0
			end

			local v13 = false
			local tagged = CollectionService2:GetTagged(result.Tag)

			if instance then
				table.insert(tagged, instance:FindFirstChild("DoingEmote"))
			end

			local _ = result.Dual.Dead
			local v14 = false

			for _, child in pairs(workspace.Live:GetChildren()) do
				local humanoid = child:FindFirstChildOfClass("Humanoid")
				local primaryPart = child.PrimaryPart

				if not (humanoid and child ~= folder and humanoid.Health == 0 and child:FindFirstChild("Ragdoll")) then
					continue
				end

				if not primaryPart or not ((primaryPart.Position - folder.PrimaryPart.Position).magnitude <= 16) or table.find(
					tagged,
					child.PrimaryPart
				) then
					continue
				end

				local _ = { child.PrimaryPart }
				shared.unragdoll({
					hit = child,
					deadbypass = true
				})
				Emotes:Play(child, v4, nil, folder)
				return
			end

			for _, v15 in pairs(tagged) do
				local parent = v15.Parent

				if not (parent ~= folder and parent) then
					continue
				end

				local cFrame = folder.PrimaryPart.CFrame
				local position = parent.PrimaryPart.Position
				local unit = (Vector3.new(position.X, cFrame.p.Y, position.Z) - cFrame.p).unit

				if not (math.deg((math.acos((cFrame.LookVector:Dot(unit))))) <= 90 and (parent.PrimaryPart.Position - folder.PrimaryPart.Position).magnitude <= 8 or parent == instance or v14) then
					continue
				end

				if not ((not folder:FindFirstChild("Ragdoll") or result.Dual.Dead) and (parent == instance or not instance)) then
					continue
				end

				local _ = result.Dual.Dead

				for _, instance2 in pairs(CollectionService2:GetTagged(result.Tag)) do
					local parent2 = instance2.Parent

					if parent2 == folder or parent2 == parent then
						CollectionService2:RemoveTag(instance2, result.Tag)
					end
				end

				local stoppedConnections = {}
				local v16 = nil

				for _, parent2 in pairs({ parent, folder }) do
					for _, v19 in pairs(CollectionService2:GetTagged(parent2.Name .. "syncui")) do
						local Debris = game:GetService("Debris")
						Debris:AddItem(v19, 0)
					end

					local cfolder2 = shared.cfolder({
						Name = "NoRotate",
						Parent = parent2
					})
					v16 = cfolder2
					CollectionService2:AddTag(cfolder2, "RemoveOnLeave" .. parent.Name)
					CollectionService2:AddTag(cfolder2, "RemoveOnLeave" .. folder.Name)

					if result.Dual.CanRotate == true then
						cfolder2.Name = "a"
						shared.cfolder({
							Name = "",
							Parent = parent2
						}, 0.1)
					elseif (not result.Looped or v4 == "Cart Ride" or result.Dual.CanRotate) and result.Dual.NoRotate ~= 1e999 then
						local Debris = game:GetService("Debris")
						Debris:AddItem(cfolder2, result.Dual.CanRotate or result.Dual.NoRotate or 3)
					end

					cfolder2:SetAttribute("EmoteProperty", true)
					table.insert(v10, cfolder2)

					if parent2 == folder and not result.Dual.RotateCheck then
						local parentChangedConnection = nil
						local v19 = cfolder2
						local v20 = stoppedConnections
						parentChangedConnection = cfolder2:GetPropertyChangedSignal("Parent"):Once(function()
							if v19.Parent then
								return
							end

							for k, connection in pairs(v20) do
								connection:Disconnect()
							end

							for k, v21 in pairs(v10) do
								if typeof(v21) == "Instance" and v21.Name == "NoRotate" and v21.Parent then
									v21:Destroy()
								end
							end

							return parentChangedConnection:Disconnect()
						end)
						table.insert(v10, parentChangedConnection)
					end

					local parentChangedConnection = nil
					local v19 = parent2
					local parent3 = parent
					parentChangedConnection = parent2:GetPropertyChangedSignal("Parent"):Once(function()
						if v19.Parent then
							return
						end

						for k, parent4 in pairs({ parent3, folder }) do
							shared.cfolder({
								Name = "CancelEmote",
								Parent = parent4
							}, 0.1)
						end

						return parentChangedConnection:Disconnect()
					end)
					table.insert(v10, parentChangedConnection)
					local v21 = nil

					for _, v22 in pairs(parent2.Humanoid:GetPlayingAnimationTracks()) do
						local animation = result.Animation
						local v23

						if typeof(animation) == "Instance" then
							local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
							v23 = KeyframeSequenceProvider:RegisterKeyframeSequence(animation)
						else
							v23 = "rbxassetid://" .. animation
						end

						local animationTwo = result.AnimationTwo

						if animationTwo then
							if typeof(animationTwo) == "Instance" then
								local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
								KeyframeSequenceProvider:RegisterKeyframeSequence(v23)
								animationTwo = v23
							else
								animationTwo = "rbxassetid://" .. animationTwo
							end
						end

						if v22.Animation.AnimationId == v23 or animationTwo and v22.Animation.AnimationId == animationTwo then
							v21 = v22
						end
					end

					if v21 then
						if cfolder2.Parent then
							local stoppedConnection = nil
							local parent4 = parent
							stoppedConnection = v21.Stopped:Once(function()
								for k, parent5 in pairs({ parent4, folder }) do
									shared.cfolder({
										Name = "CancelEmote",
										Parent = parent5
									}, 0.1)
								end

								return stoppedConnection:Disconnect()
							end)
							table.insert(stoppedConnections, stoppedConnection)
							table.insert(v10, stoppedConnection)
						end

						v21:AdjustSpeed(1)

						if not result.Dual.CallOnAccept then
							v21.TimePosition = 0
						end

						if (parent2 == folder or result.Dual.DoBoth) and result.Dual.Callback then
							if result.Dual.CallOnAccept then
								local parent4 = parent
								local v23 = cfolder2
								task.spawn(function()
									for k, v25 in pairs({ folder, parent4 }) do
										local animation = Instance.new("Animation")
										animation.AnimationId = "rbxassetid://17465544429"
										local track = v25.Humanoid:LoadAnimation(animation)
										track:Play()
										table.insert(v10, track)
									end

									if game.PlaceId == 12360882630 or workspace:GetAttribute("RankedOnes") and game.PlaceId ~= 13635175275 then
										return
									end

									local clone = script.inv:Clone()
									clone:SetAttribute("EmoteProperty", true)
									table.insert(v10, clone)
									local playerFromCharacter2 = game.Players:GetPlayerFromCharacter(folder)
									local playerFromCharacter3 = game.Players:GetPlayerFromCharacter(parent4)
									local inv = playerFromCharacter2.PlayerGui:FindFirstChild("inv")

									if inv then
										inv:Destroy()
									end

									local text = not playerFromCharacter3 and "?" or playerFromCharacter3.DisplayName or "?"
									CollectionService2:AddTag(
										clone,
										"RemoveOnLeave" .. (not playerFromCharacter2 and "?" or playerFromCharacter2.Name or "?")
									)
									local cfolder3 = shared.cfolder({
										Name = "RootAnchor"
									})
									shared.bindDeletion(cfolder3, v23)
									cfolder3.Parent = folder
									table.insert(v10, cfolder3)
									CollectionService2:AddTag(
										cfolder3,
										"RemoveOnLeave" .. (instance or playerFromCharacter3 or folder).Name
									)
									local connections = {}
									local parts = {}

									for k, folder2 in pairs({ folder, parent4 }) do
										table.insert(connections, folder2.DescendantAdded:connect(function(part)
											if part:IsA("BasePart") then
												part.CollisionGroup = "nocol"
												table.insert(parts, part)
											end
										end))

										for i, part in pairs(folder2:GetDescendants()) do
											if not part:IsA("BasePart") then
												continue
											end

											part.CollisionGroup = "nocol"
											table.insert(parts, part)
										end
									end

									cfolder3:GetPropertyChangedSignal("Parent"):Connect(function()
										if not cfolder3.Parent then
											for k, connection in pairs(connections) do
												connection:Disconnect()
											end

											for k, v27 in pairs(parts) do
												v27.CollisionGroup = "playercol"
											end
										end
									end)
									CollectionService2:AddTag(cfolder3, parent4.Name .. "carry")
									game.ReplicatedStorage.Replication:FireAllClients({
										Effect = "Smooth Grab",
										Hit = folder,
										StartOffset = folder.PrimaryPart.CFrame,
										From = parent4.PrimaryPart,
										CanBypass = true,
										Offset = CFrame.new(0, 0, -4.5),
										Anchor = cfolder3
									})
									clone.Parent = playerFromCharacter2.PlayerGui
									local frame = clone.Frame.Frame
									frame.Name = "Invitation" .. text
									frame.TextLabel.TextLabel.Text = text
									frame.LayoutOrder = 1
									local textLabel = frame.TextLabel
									textLabel.Deny.MouseButton1Click:Connect(function()
										shared.sfx({
											SoundId = "rbxassetid://6895079853",
											Parent = playerFromCharacter2.PlayerGui,
											Volume = 1.5
										}):Resume()
										frame:Destroy()
										shared.cfolder({
											Name = "Freeze",
											Parent = folder
										}, 0)
									end)
									textLabel.Accept.MouseButton1Click:Connect(function()
										shared.sfx({
											SoundId = "rbxassetid://6895079853",
											Parent = playerFromCharacter2.PlayerGui,
											Volume = 1.5
										}):Resume()

										if not (playerFromCharacter2.Character and playerFromCharacter3.Character) then
											frame:Destroy()
											return
										end

										if playerFromCharacter2.Character:GetAttribute("donealr") or playerFromCharacter3.Character:GetAttribute("donealr") then
											frame:Destroy()
											return
										end

										local v27 = {
											{
												playerFromCharacter2.UserId,
												playerFromCharacter3.UserId,
												false,
												false
											}
										}

										for k, v29 in pairs({ playerFromCharacter2, playerFromCharacter3 }) do
											if v29.Character then
												v29.Character:SetAttribute("donealr", true)
											end
										end

										local v29 = playerFromCharacter2
										local v30 = playerFromCharacter3
										local v31 = {
											"Ones",
											playerFromCharacter2.UserId,
											v30.UserId,
											0,
											false,
											0,
											true
										}

										for k, v32 in pairs({ v29, v30 }) do
											local sound = Instance.new("Sound")
											sound.SoundId = "rbxassetid://5153734236"
											sound.Volume = 2
											sound.Parent = v32.PlayerGui
											sound:Play()
											v32:SetAttribute("Enemy", v32 == v29 and v30.Name or v29.Name)

											if v32.Character then
												v32.Character:SetAttribute("donealr", true)
											end
										end

										task.spawn(function()
											local TeleportService = game:GetService("TeleportService")
											local reserveServer = TeleportService:ReserveServer(game.PlaceId)
											task.wait(1.75)
											local TeleportService2 = game:GetService("TeleportService")
											TeleportService2:TeleportToPrivateServer(
												game.PlaceId,
												reserveServer,
												{ playerFromCharacter2, playerFromCharacter3 },
												nil,
												v31
											)
										end)
										frame:Destroy()
									end)
									shared.sfx({
										SoundId = "rbxassetid://7116606826",
										Parent = playerFromCharacter2.PlayerGui,
										Volume = 0.75
									}):Play()

									repeat
										task.wait()
									until folder:GetAttribute("donealr") or not clone.Parent

									if clone.Parent or folder:GetAttribute("donealr") then
										result.Dual.Callback(folder, parent4, v10, result.Dual.Dist, v12, intcheck)
									end
								end)
							else
								result.Dual.Callback(folder, parent, v10, result.Dual.Dist, v12, intcheck)
							end
						end
					else
						for _, parent4 in pairs({ parent, folder }) do
							shared.cfolder({
								Name = "CancelEmote",
								Parent = parent4
							}, 0.1)
						end

						break
					end
				end

				if result.Dual.Dist then
					local cfolder2 = shared.cfolder({
						Name = "RootAnchor"
					})

					if v16 then
						shared.bindDeletion(cfolder2, v16)
					end

					cfolder2.Parent = folder
					table.insert(v10, cfolder2)
					CollectionService2:AddTag(cfolder2, "RemoveOnLeave" .. parent.Name)
					CollectionService2:AddTag(cfolder2, "RemoveOnLeave" .. folder.Name)
					local connections = {}
					local parts = {}

					for _, folder2 in pairs({ folder }) do
						local parts2 = parts
						table.insert(connections, folder2.DescendantAdded:connect(function(part)
							if part:IsA("BasePart") then
								part.CollisionGroup = "nocol"
								table.insert(parts2, part)
							end
						end))

						for _, part in pairs(folder2:GetDescendants()) do
							if not part:IsA("BasePart") then
								continue
							end

							part.CollisionGroup = "nocol"
							table.insert(parts, part)
						end
					end

					cfolder2:GetPropertyChangedSignal("Parent"):Connect(function()
						if not cfolder2.Parent then
							for k, connection in pairs(connections) do
								connection:Disconnect()
							end

							for k, v21 in pairs(parts) do
								v21.CollisionGroup = "playercol"
							end
						end
					end)
					game.ReplicatedStorage.Replication:FireAllClients({
						Effect = "Smooth Grab",
						CanBypass = true,
						Hit = folder,
						StartOffset = folder.PrimaryPart.CFrame,
						From = parent.PrimaryPart,
						NoLook = result.Dual.NoLook,
						Offset = typeof(result.Dual.Dist) == "CFrame" and result.Dual.Dist or CFrame.new(
							0,
							0,
							-result.Dual.Dist
						),
						Anchor = cfolder2
					})
				end

				v13 = true
			end

			if not v13 then
				task.spawn(function()
					local lastTime = tick()
					local v15 = result.Dual.Freeze == false and 2 or 0.1

					if v15 < realAnimation.Speed or not realAnimation.IsPlaying or intcheck.interrupted then
						return
					end

					repeat
						task.wait()
					until tick() - lastTime > 1 or not realAnimation.IsPlaying or v15 < realAnimation.Speed or intcheck.interrupted

					if v15 < realAnimation.Speed or not realAnimation.IsPlaying or intcheck.interrupted then
						return
					end

					local flag = false
					local clones = {}

					for _, v16 in pairs(game.Players:GetPlayers()) do
						if not v16.Character then
							continue
						end

						local clone = script.Sync:Clone()
						CollectionService2:AddTag(clone, (playerFromCharacter or folder).Name .. "syncui")
						table.insert(v10, clone)

						if v4 == "Duel Request" then
							clone.Frame.TextButton.Text = "FRIENDLY DUEL"
						end

						clone.PlayerToHideFrom = playerFromCharacter
						CollectionService2:AddTag(clone, "EmoteSync")
						clone:SetAttribute("EmoteProperty", true)
						clone.Adornee = folder["Left Arm"]
						clone.Parent = v16.PlayerGui
						local mouseButton1ClickConnection = nil
						local v17 = v16
						mouseButton1ClickConnection = clone.Frame.Button.MouseButton1Click:Connect(function()
							local character = v17.Character

							if character:GetAttribute("InMech") then
								return
							end

							if flag then
								return mouseButton1ClickConnection:Disconnect()
							end

							local v18 = tick() - (character:GetAttribute("LastDamage") or 0)

							if not (character:FindFirstChild("DoingEmote") or ActionCheck:Check(character, { "Emote" })) or v18 < 1 or (character.PrimaryPart.Position - folder.PrimaryPart.Position).magnitude > 25 then
								return
							end

							mouseButton1ClickConnection:Disconnect()
							flag = true

							for k, v19 in pairs(clones) do
								v19:Destroy()
							end

							Emotes:Play(character, v4, nil, folder)
						end)
						table.insert(clones, clone)
					end
				end)
			end
		end
	end

	if typeof(realAnimation) == "table" then
		return warn("f")
	end

	local fn15
	local stoppedConnection = nil
	stoppedConnection = realAnimation.Stopped:Connect(function()
		if intcheck.interrupted then
			for _, v13 in pairs(CollectionService2:GetTagged("emoteendstuff" .. (instance or playerFromCharacter or folder).Name)) do
				v13:Destroy()
			end
		elseif result.Idle then
			local v13 = fn14(result.Idle)
			table.insert(v10, v13)
			v13:Play()

			if result.IdleKeyframes and fn15 then
				fn15(v13)
			end

			if result.IdleSound then
				local v14 = fn10(result.IdleSound)
				v14.Parent = folder.Torso
				v14:Play()
				table.insert(v10, v14)
			end

			local stoppedConnection2 = nil
			stoppedConnection2 = v13.Stopped:Once(function()
				if intcheck.interrupted and intcheck.interrupted ~= "CancelEmote" or not result.End then
					for _, v14 in pairs(CollectionService2:GetTagged("emoteendstuff" .. (instance or playerFromCharacter or folder).Name)) do
						v14:Destroy()
					end
				else
					local cfolder2 = shared.cfolder({
						Name = "Freeze",
						Parent = folder
					}, result.End[2] or 3.7)
					local v14 = nil
					task.delay(0.25, function()
						if cfolder2.Parent then
							local cfolder3 = shared.cfolder({
								Name = "DoingEmote",
								Parent = folder
							})
							shared.bindDeletion(cfolder3, cfolder2)
							local cfolder4 = shared.cfolder({
								Name = "DoingEmote1",
								Parent = folder
							})
							cfolder4:GetPropertyChangedSignal("Name"):Once(function()
								if cfolder4.Name == "Done" then
									cfolder2:Destroy()
								end
							end)
							shared.bindDeletion(cfolder4, cfolder2)
							shared.bindDeletion(cfolder3, cfolder4)
						end
					end)
					cfolder2:GetPropertyChangedSignal("Name"):Once(function()
						if cfolder2.Name == "Done" then
							fn14(result.End[1]):Stop()
						end
					end)
					cfolder2:GetPropertyChangedSignal("Parent"):Once(function()
						for _, v15 in pairs(CollectionService2:GetTagged("emoteendstuff" .. (instance or playerFromCharacter or folder).Name)) do
							v15:Destroy()
						end

						if v14 then
							TweenService:Create(
								v14,
								TweenInfo.new(0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Volume = 0
								}
							):Play()
						end
					end)

					if result.End[3] then
						v14 = fn10(result.End[3])
						v14.Parent = folder.Torso
						v14:Play()
					end

					cfolder2:SetAttribute("EmoteEnding", true)
					fn14(result.End[1]):Play()

					if v4 == "Am Dead" then
						local tagged = CollectionService2:GetTagged("emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
						task.delay(1.55, function()
							for _, v15 in pairs(tagged) do
								v15:Destroy()
							end
						end)
					elseif v4 == "Paddleball" then
						local tagged = CollectionService2:GetTagged("emoteendstuff" .. (instance or playerFromCharacter or folder).Name)
						task.delay(1.183, function()
							for _, v15 in pairs(tagged) do
								v15:Destroy()
							end
						end)
					elseif v4 == "Chosen" then
						local tagged = CollectionService2:GetTagged("emoteendstuff" .. (instance or playerFromCharacter or folder).Name)

						for _, folder2 in pairs(tagged) do
							if not (typeof(folder2) == "Instance" and folder2.Name == "chosenparticles") then
								continue
							end

							for _, beam in pairs(folder2:GetDescendants()) do
								if beam:IsA("Beam") then
									TweenService:Create(
										beam,
										TweenInfo.new(
											1 + math.random(),
											Enum.EasingStyle.Quad,
											Enum.EasingDirection.InOut
										),
										{
											Width1 = 0,
											Width0 = 0
										}
									):Play()
								end
							end
						end
					end
				end

				stoppedConnection2:Disconnect()
				intcheck(true)
			end)
			table.insert(v10, stoppedConnection2)
			return
		end

		stoppedConnection:Disconnect()
		intcheck(true)
	end)
	table.insert(v10, stoppedConnection)

	if result.Keyframes then
		fn15 = function(object2)
			for k, keyframe in pairs(result.Keyframes) do
				local now = tick()
				local v13 = result.Infinite and 1e999 or 15
				local connection = nil
				local v15 = k
				local v16 = keyframe
				connection = object2:GetMarkerReachedSignal(k):Connect(function()
					if v13 < tick() - now then
						return connection:Disconnect()
					end

					if v15 ~= "snap" and v15 ~= "clap" and v15 ~= "claploop" and v4 ~= "Boppin" and not result.DontDisconnectMarkers then
						connection:Disconnect()
					end

					v16(v12, v10, object2, intcheck)
				end)
				table.insert(v10, connection)
			end
		end

		fn15(realAnimation)
	end

	if result.Sounds and not intcheck.interrupted then
		for duration, sound in pairs(result.Sounds) do
			if intcheck.interrupted then
				break
			else
				local v13 = sound
				task.delay(duration, function()
					local v14 = {
						Name = "EmoteSFX",
						Parent = folder.PrimaryPart,
						RollOffMaxDistance = rollOffMaxDistance
					}
					local volume = nil

					if v13.ParentTorso then
						v14.Parent = folder.Torso
						v13.ParentTorso = nil
					end

					if v13.IsMusic and not table.find(soundIds, v13.SoundId) then
						table.insert(soundIds, v13.SoundId)
					end

					if v13.Smooth then
						volume = v13.Volume or 0.5
						v13.Volume = 0
						v13.Smooth = nil
					end

					for k, v15 in pairs(v13) do
						v14[k] = v15
					end

					if intcheck.interrupted then
						return
					end

					local v15 = fn10(v14)
					v15:SetAttribute("EmoteProperty", true)
					table.insert(v10, v15)

					if volume then
						v15.Volume = 0
					end

					if intcheck.interrupted then
						return v15
					end

					v15:Resume()

					if volume then
						TweenService:Create(v15, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Volume = volume
						}):Play()
					end
				end)
			end
		end
	end
end

function Emotes.Get(_)
	return require(script:FindFirstChild("EmoteData") or script:WaitForChild("EmoteData", 15))
end

function Emotes:GetTable(p)
	return Emotes:Play(nil, nil, true, nil, p)
end

function Emotes.IsLimited(_, p)
	return Emotes:GetTable(true)[p].Limited
end

return Emotes