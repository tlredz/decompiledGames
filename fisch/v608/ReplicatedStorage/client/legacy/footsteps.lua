local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local footsteps = ReplicatedStorage.resources.sounds.footsteps
local v = nil
local v2 = {}

local function updatefootsteps(k)
	local v3 = v2[k]

	if not v3 then
		return
	end

	local v4 = footsteps:FindFirstChild(v3.humanoid.FloorMaterial.Name) or footsteps.Plastic
	v3.sound.SoundId = v4.SoundId
	v3.sound.Volume = v4.Volume
	v3.sound.PlaybackSpeed = (v3.rootPart.AssemblyLinearVelocity * createVector(1, 0, 1)).Magnitude / 12 + v4.PlaybackSpeed - 1
end

local total = 0
RunService.PostSimulation:Connect(function(dt: number)
	if not v then
		return
	end

	total += dt

	if total < 0.25 then
		return
	end

	total = 0
	debug.profilebegin("updateFootsteps")
	local v3 = v.Position // 25

	for k, v4 in v2 do
		local rootPart = v4.rootPart
		local sound = v4.sound
		local enabled = v4.enabled

		if k ~= localPlayer then
			local abs = (v3 - rootPart.Position // 25):Abs()

			if abs.X + abs.Y + abs.Z > 1 then
				continue
			end
		end

		if enabled then
			updatefootsteps(k)
		end

		local magnitude = (rootPart.AssemblyLinearVelocity * createVector(1, 0, 1)).Magnitude
		local humanoid = v4.humanoid
		local v5

		if magnitude > 9 then
			v5 = humanoid:GetState() == Enum.HumanoidStateType.Running
		else
			v5 = false
		end

		if v5 == enabled then
			continue
		end

		sound.Playing = v5
		v4.enabled = v5
	end

	debug.profileend()
end)

local function setupCharacter(player)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	local humanoid = character:WaitForChild("Humanoid")

	if player == localPlayer then
		v = humanoidRootPart
	end

	local sound = Instance.new("Sound")
	sound.Name = "Footsteps"
	sound.Looped = true
	sound.Parent = humanoidRootPart
	v2[player] = {
		rootPart = humanoidRootPart,
		humanoid = humanoid,
		sound = sound,
		enabled = false
	}
end

local function watchPlayerCharacters(p)
	setupCharacter(p)
	p.CharacterRemoving:Connect(function()
		v2[p] = nil
	end)
	p.CharacterAdded:Connect(function()
		setupCharacter(p)
	end)
end

for _, v3 in Players:GetPlayers() do
	task.spawn(watchPlayerCharacters, v3)
end

Players.PlayerAdded:Connect(watchPlayerCharacters)
Players.PlayerRemoving:Connect(function(player)
	v2[player] = nil
end)