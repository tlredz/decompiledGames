local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local game2 = game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Game")
local donkeyKongEvent = game2:WaitForChild("DonkeyKongEvent")
local DonkeyKongMotion = require(game2:WaitForChild("DonkeyKongMotion"))
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function clock()
	return v.clock + (v.paused and 0 or math.max(0, workspace:GetServerTimeNow() - v.serverAt))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clear()
	if v then
		v.folder:Destroy()
		v = nil
	end
end

local function spawnBarrel(barrel)
	if not v or v.barrels[barrel.id] then
		return
	end

	local clone = game.ReplicatedStorage:WaitForChild("Barrel"):Clone()
	clone.Name = "Barrel" .. barrel.id
	local _, v2 = clone:GetBoundingBox()
	clone:ScaleTo(clone:GetScale() * (DonkeyKongMotion.Radius * 2 / math.max(v2.Y, v2.Z)))
	local basePart = clone:FindFirstChildWhichIsA("BasePart", true)

	if not basePart then
		clone:Destroy()
		return
	end

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
		elseif descendant:IsA("LuaSourceContainer") then
			descendant:Destroy()
		end
	end

	local objectSpace = clone:GetBoundingBox():ToObjectSpace(clone:GetPivot())
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://9125752846"
	sound.Volume = 0.35
	sound.RollOffMaxDistance = 100
	sound.RollOffMinDistance = 5
	sound.Looped = true
	sound.PlaybackSpeed = 1.2
	sound.Parent = basePart
	clone.Parent = v.folder
	v.barrels[barrel.id] = {
		data = barrel,
		model = clone,
		pivotOffset = objectSpace,
		sound = sound
	}
end

local connections = {}
table.insert(connections, donkeyKongEvent.OnClientEvent:Connect(function(p, data)
	if p == "Clear" then
		if v and v.id == data and v then
			v.folder:Destroy()
			v = nil
		end
	else
		if type(data) ~= "table" then
			return
		end

		if p == "Begin" then
			clear() -- equivalent call inferred; original call site unknown
			local folder = Instance.new("Folder")
			folder.Name = "DonkeyKongBarrels"
			folder.Parent = workspace
			v = {
				id = data.id,
				origin = data.origin,
				clock = data.clock,
				serverAt = data.serverAt,
				paused = data.paused,
				folder = folder,
				barrels = {},
				lastHit = -1e999
			}

			for _, barrel in data.barrels do
				spawnBarrel(barrel)
			end
		elseif v and v.id == data.id then
			if p == "Spawn" then
				spawnBarrel(data.barrel)
			elseif p == "Clock" then
				v.clock = data.clock
				v.serverAt = data.serverAt
				v.paused = data.paused
			end
		end
	end
end))
table.insert(connections, RunService.RenderStepped:Connect(function()
	if not v then
		return
	end

	local v2 = clock() -- equivalent call inferred; original call site unknown
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local previous = v.previous
	local v3

	if humanoidRootPart then
		if localPlayer:GetAttribute("InMatch") == true and localPlayer:GetAttribute("RunState") == "Active" then
			v3 = not v.paused
		else
			v3 = false
		end
	else
		v3 = humanoidRootPart
	end

	for k, barrel in v.barrels do
		local data = barrel.data

		if data.expires < v2 then
			barrel.model:Destroy()
			v.barrels[k] = nil
		else
			local position = DonkeyKongMotion.position(v.origin, data, v2)
			local v4 = (v2 - data.born) * data.speed / DonkeyKongMotion.Radius * 1
			local v5 = CFrame.new(position) * v.origin.Rotation * CFrame.Angles(0, 0, v4) * CFrame.Angles(
				0,
				1.5707963267948966,
				0
			)
			barrel.model:PivotTo(v5 * barrel.pivotOffset)

			if v.paused then
				if barrel.sound.Playing then
					barrel.sound:Pause()
				end
			elseif not barrel.sound.Playing then
				if barrel.sound.TimePosition > 0 then
					barrel.sound:Resume()
				else
					barrel.sound:Play()
				end
			end

			if v3 and previous and previous.character == character and v2 - previous.at > 0 and v2 - previous.at < 0.12 and (humanoidRootPart.Position - previous.position).Magnitude < 16 and v2 - v.lastHit > 0.18 and DonkeyKongMotion.contact(
				previous.position,
				humanoidRootPart.Position,
				DonkeyKongMotion.position(v.origin, data, (math.max(data.born, previous.at))),
				position,
				DonkeyKongMotion.HitRadius
			) then
				v.lastHit = v2
				donkeyKongEvent:FireServer("Hit", {
					id = v.id,
					bot = data.id,
					at = v2,
					position = humanoidRootPart.Position
				})
			end
		end
	end

	v.previous = v3 and {
		at = v2,
		position = humanoidRootPart.Position,
		character = character
	} or nil
end))
table.insert(connections, game2.Session:GetAttributeChangedSignal("AdminMatchMode"):Connect(function()
	if game2.Session:GetAttribute("AdminMatchMode") == "DonkeyKong" then
		donkeyKongEvent:FireServer("Sync")
		return
	end

	clear() -- equivalent call inferred; original call site unknown
end))
donkeyKongEvent:FireServer("Sync")
script.Destroying:Connect(function()
	clear() -- equivalent call inferred; original call site unknown

	for _, connection in connections do
		connection:Disconnect()
	end
end)