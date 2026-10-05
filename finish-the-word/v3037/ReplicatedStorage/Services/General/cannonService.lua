local import = _G.import("event")
local import2 = _G.import("bodyUtil")
local import3 = _G.import("effectUtil")
local import4 = _G.import("modelUtil")
local import5 = _G.import("soundData")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local v = {
	R6 = {
		"106832579613241",
		"106865268607575",
		"85602315006376",
		"128629782487517"
	},
	R15 = {
		"88460966204069",
		"81330130573448",
		"99636725902450",
		"88503948875089"
	}
}
local v2 = {}

for _, v3 in pairs(v) do
	for _, v4 in pairs(v3) do
		v2["rbxassetid://" .. v4] = true
	end
end

local v3 = {}
local v4 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function getCannon()
	local meta = workspace:FindFirstChild("Meta")
	local stations = meta and meta:FindFirstChild("Stations")
	local ranked = stations and stations:FindFirstChild("Ranked")
	return ranked and ranked.Cannon
end

local function getSeatParts(cannon)
	local partsByName = {}

	for _, part in pairs(cannon.Seats:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		local name = tonumber(part.Name)

		if name then
			partsByName[name] = part
		end
	end

	return partsByName
end

local function setupCannon()
	local cannon = workspace.Meta.Stations.Ranked.Cannon
	local main = cannon.Main
	local part = main.Part
	local pivot = main:GetPivot()

	for _, child in pairs(cannon.Seats:GetChildren()) do
		local cannonSeatToMainWeld = child:FindFirstChild("CannonSeatToMainWeld")

		if cannonSeatToMainWeld then
			cannonSeatToMainWeld:Destroy()
		end

		local weld = import4.weld(part, child)
		weld.Name = "CannonSeatToMainWeld"
	end

	RunService.Heartbeat:Connect(function()
		main:PivotTo(pivot * CFrame.Angles(0, 0, math.sin(os.clock() * 1) * 0.17453292519943295))
	end)
end

local function playCannonExplosion(cannon)
	local now = os.clock()

	if now - v4 < 0.75 then
		return
	end

	v4 = now
	local explosion = cannon.Main.Explosion
	local cannonExplosion = import5.CannonExplosion
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. cannonExplosion[1]
	sound.Volume = cannonExplosion.Volume
	sound.Parent = explosion
	sound:Play()
	Debris:AddItem(sound, cannonExplosion.TimeLength or 5)
	import3.emitObject(explosion)
end

local function placeInSlot(player, cFrame, seatPart)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local cannonSeatWeld = humanoidRootPart:FindFirstChild("CannonSeatWeld")

	if cannonSeatWeld then
		cannonSeatWeld:Destroy()
	end

	humanoidRootPart.CFrame = cFrame

	if seatPart then
		local manualWeld = import4.manualWeld(seatPart, humanoidRootPart, seatPart.CFrame:ToObjectSpace(cFrame))
		manualWeld.Name = "CannonSeatWeld"
	end
end

setupCannon()
local CannonService = {}

function CannonService.seat(player, p)
	for _, v5 in pairs(v3) do
		if v5 == player then
			return
		end
	end

	local cannon = getCannon() -- equivalent call inferred; original call site unknown

	if not cannon then
		return
	end

	local seatParts = getSeatParts(cannon)

	if not p then
		p = 1

		while v3[p] do
			p += 1
		end
	end

	v3[p] = player
	local seatPart = seatParts[p]

	if not seatPart then
		local v5 = 0

		for k in pairs(seatParts) do
			if v5 < k then
				v5 = k
			end
		end

		seatPart = seatParts[v5]
	end

	if not (seatPart and v3[p] == player) then
		return
	end

	local character = player.Character
	local name = character.Humanoid.RigType.Name
	placeInSlot(player, seatPart.CFrame, seatPart)
	import2.animate(character, v[name][p], {
		Looped = true,
		Priority = "Action"
	})
end

function CannonService.unseat(player)
	local v5 = nil

	for k, v7 in pairs(v3) do
		if v7 ~= player then
			continue
		end

		v5 = k
		break
	end

	if not v5 then
		return
	end

	import2.stopAnimationsInSet(player.Character, v2)
	v3[v5] = nil
	local cannon = getCannon() -- equivalent call inferred; original call site unknown

	if not cannon then
		return
	end

	local exitTeleport = cannon.ExitTeleport
	local cFrame = exitTeleport.CFrame
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local cannonSeatWeld = humanoidRootPart:FindFirstChild("CannonSeatWeld")

		if cannonSeatWeld then
			cannonSeatWeld:Destroy()
		end

		humanoidRootPart.CFrame = cFrame
	end

	import.remoteFire(player, "cannonExit", exitTeleport.CFrame)
	return v5
end

function CannonService.launch(items)
	local cannon = getCannon() -- equivalent call inferred; original call site unknown
	local seatParts = getSeatParts(cannon)
	local position = cannon.Main:GetPivot().Position

	for _, item in pairs(items) do
		local v5 = nil

		for k, v7 in pairs(v3) do
			if v7 ~= item then
				continue
			end

			v3[k] = nil
			v5 = k
			break
		end

		local v7 = seatParts[v5].Position - position
		local unit = Vector3.new(v7.X, 0, v7.Z).Unit
		local character = item.Character
		playCannonExplosion(cannon)
		import2.stopAnimationsInSet(character, v2)
		local humanoid = character.Humanoid
		local humanoidRootPart = character.HumanoidRootPart
		local cannonSeatWeld = humanoidRootPart:FindFirstChild("CannonSeatWeld")

		if cannonSeatWeld then
			cannonSeatWeld:Destroy()
		end

		humanoid.PlatformStand = true
		humanoid.AutoRotate = false
		humanoidRootPart:SetNetworkOwner(nil)
		task.spawn(function()
			local total = 192

			while character.Parent do
				local v11 = RunService.PostSimulation:Wait()
				total += 48 * v11
				humanoidRootPart.CFrame = (humanoidRootPart.CFrame + (humanoidRootPart.CFrame.upVector + unit * 0.06).unit * total * v11) * CFrame.Angles(
					0,
					12 * v11,
					0
				)
			end
		end)
	end
end

return CannonService