local char = script:WaitForChild("playa").Value
game:GetService("TweenService")
local humanoid = char:WaitForChild("Humanoid", 1)
local humanoidRootPart = char:WaitForChild("HumanoidRootPart", 1)
local v = game.Players.LocalPlayer.Name == char.Name
tick()

local function fn(items)
	local sound = Instance.new("Sound")
	local SoundService = game:GetService("SoundService")
	sound.SoundGroup = SoundService.Sounds
	sound.Played:connect(function()
		sound.Ended:connect(function()
			local Debris = game:GetService("Debris")
			Debris:AddItem(sound, 0)
		end)
	end)

	for k, item in pairs(items) do
		sound[k] = item
	end

	return sound
end

Random.new()
local v2 = {
	[Enum.Material.Grass] = {
		id = { 7456850767, 7456850856, 7456850976 },
		volume = 0.16,
		add = 0.8,
		default = 1
	},
	[Enum.Material.LeafyGrass] = {
		id = { 7455224448, 7455224380, 7455224324 },
		volume = 0.1,
		add = 0.8,
		default = 1
	},
	[Enum.Material.Mud] = {
		id = { 7807902004, 7807902091, 7807902210 },
		volume = 0.12,
		add = 0.8,
		default = 1
	},
	[Enum.Material.WoodPlanks] = {
		id = { 7278039716, 7278039763, 7278039806 },
		volume = 0.2,
		default = 0.9,
		add = 1
	},
	[Enum.Material.Slate] = {
		id = { 7455224144, 7455246815, 7455224490 },
		volume = 0.12,
		default = 1,
		add = 1
	},
	[Enum.Material.Sand] = {
		id = { 7278083537, 7278083583, 7278083623 },
		volume = 0.75,
		default = 0.7,
		add = 0.9
	},
	[Enum.Material.Ground] = {
		id = { 6540746817, 549000724, 6441160246 },
		volume = 0.3,
		default = 0.7,
		add = 0.9
	}
}
v2[Enum.Material.Wood] = v2[Enum.Material.WoodPlanks]
v2[Enum.Material.Concrete] = v2[Enum.Material.Slate]
v2[Enum.Material.SmoothPlastic] = v2[Enum.Material.Slate]
v2[Enum.Material.Pavement] = v2[Enum.Material.Slate]
v2[Enum.Material.Rock] = v2[Enum.Material.Slate]
v2[Enum.Material.Plastic] = v2[Enum.Material.Slate]
local sound = Instance.new("Sound")
sound.RollOffMaxDistance = 50
sound.Volume = 0.45
sound.Looped = true
sound.Parent = humanoidRootPart
local clone = sound:Clone()
clone.Volume = 0.35
clone.SoundId = "rbxassetid://6659974418"
clone.Parent = humanoidRootPart
local v3 = 0
local v4 = {}
local now = 0
local now2 = 0
local v5 = {}
local v6 = {
	["16515503507"] = 1,
	["16515520431"] = 2,
	["16515448089"] = 3,
	["16552234590"] = 4
}
local v7 = {
	["17889458563"] = 1,
	["17889461810"] = 2,
	["17889471098"] = 3,
	["17889290569"] = 4
}
local now3 = 0
local v8 = {}
humanoid.AnimationPlayed:connect(function(object)
	local animation = object.Animation

	if not animation then
		return
	end

	local match = animation.AnimationId:match("[/=](%d+)")
	local count = v6[match]

	if count and not v5[match] and char:GetAttribute("Character") == "Esper" then
		local lastTime = tick()
		v5[match] = true
		object:GetMarkerReachedSignal("swingreg"):Connect(function()
			if tick() - lastTime < 0.2 then
				return
			end

			lastTime = tick()
			shared.repfire({
				Effect = "Psychic Light",
				Count = count,
				root = char.PrimaryPart,
				char = char
			})
		end)
	end

	local count2 = v7[match]

	if count2 and char:GetAttribute("Character") == "Purple" and tick() - now3 > 0.15 then
		now3 = tick()
		shared.repfire({
			Effect = "Purple Light",
			Count = count2,
			root = char.PrimaryPart,
			char = char
		})
	end

	if match == "16749129340" and not v then
		object:Stop()
	end

	if match == "89642715363301" and not snowwalk then
		snowwalk = object:GetMarkerReachedSignal("walk"):Connect(function()
			if not char:FindFirstChild("HasSnowball") then
				return
			end

			shared.sfx({
				SoundId = ({
					"rbxassetid://112045313585919",
					"rbxassetid://140236416603097",
					"rbxassetid://98185091770065",
					"rbxassetid://138688928896743"
				})[math.random(1, 4)],
				Parent = char["Left Leg"],
				Volume = 0.25,
				RollOffMaxDistance = 40
			}):Play()
		end)
	end

	local v11 = { "79741533269101", "7815618175", "131585091153240" }

	if match == "7807831448" and not char:GetAttribute("HoldingSpace") or table.find(v11, match) and not v4[match] then
		local flag = false

		if match == "7807831448" then
			flag = true
		elseif table.find(v11, match) then
			v4[match] = true
		end

		table.insert(flag and v8 or {}, object.KeyframeReached:connect(function(p)
			local running = char:GetAttribute("Running")

			if p == "runfootstep" and not running or p ~= "runfootstep" and running or p ~= "walkfootstep" and p ~= "runfootstep" then
				return
			end

			local doingEmote = char:FindFirstChild("DoingEmote") or char:FindFirstChild("Freeze") or char:FindFirstChild("HasSnowball")
			local canWalk = char:FindFirstChild("CanWalk")

			if doingEmote and doingEmote.Name == "DoingEmote" then
				canWalk = nil
			end

			if v3 > 5 and tick() - now2 > 0.125 and (not doingEmote or canWalk) and (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).magnitude <= 50 then
				now2 = tick()
				local v12 = rawget(v2, humanoid.FloorMaterial)

				if v12 then
					now = tick()
					fn({
						Volume = v12.volume,
						PlaybackSpeed = 1 + (running and 0.35 or 0),
						SoundId = "rbxassetid://" .. v12.id[math.random(#v12.id)],
						RollOffMaxDistance = 40,
						Parent = humanoidRootPart
					}):Play()
				end
			end
		end))

		if flag then
			object.Stopped:Once(function()
				for _, connection in pairs(v8) do
					connection:Disconnect()
				end

				table.clear(v8)
			end)
		end
	end
end)
workspace:FindFirstChild("Ambience")

local function fn2(p)
	v3 = p
end

humanoid.Running:connect(fn2)
char.AttributeChanged:connect(function(p)
	if p == "Running" then
		v3 = v3
	end
end)
humanoid:GetPropertyChangedSignal("FloorMaterial"):connect(function()
	v3 = v3
end)
local v9 = 0
local floorMaterialChangedConnection = nil
humanoid.Jumping:connect(function()
	if (workspace.CurrentCamera.CFrame.Position - char.HumanoidRootPart.Position).magnitude > 20 and not v then
		return
	end

	local now4 = tick()

	if now4 - v9 < 0.2 then
		return
	end

	v9 = now4
	fn({
		SoundId = "rbxassetid://7005105940",
		Parent = char.HumanoidRootPart,
		Volume = 0.125,
		RollOffMaxDistance = 30
	}):Play()
	wait(0.03)

	if floorMaterialChangedConnection then
		floorMaterialChangedConnection:disconnect()
	end

	if humanoid.FloorMaterial == Enum.Material.Air then
		fn({
			SoundId = "rbxassetid://7005105964",
			Parent = char.HumanoidRootPart,
			Volume = 0.175,
			RollOffMaxDistance = 30
		}):Play()
	else
		floorMaterialChangedConnection = humanoid:GetPropertyChangedSignal("FloorMaterial"):connect(function(_)
			if humanoid.FloorMaterial == Enum.Material.Air then
				return
			end

			fn({
				SoundId = "rbxassetid://7005105964",
				Parent = char.HumanoidRootPart,
				Volume = 0.175,
				RollOffMaxDistance = 30
			}):Play()
			return floorMaterialChangedConnection:disconnect()
		end)
	end
end)
char:GetPropertyChangedSignal("Parent"):connect(function()
	if not (char and char.Parent) then
		script:Destroy()
	end
end)