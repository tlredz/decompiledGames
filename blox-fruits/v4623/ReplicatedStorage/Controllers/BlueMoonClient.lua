local createVector = vector.create
local Lighting = game:GetService("Lighting")
game:GetService("TweenService")
local Net = require(game.ReplicatedStorage.Modules.Net)
local spr = require(script.spr)
local v = nil
local localPlayer = game.Players.LocalPlayer
local v2 = {}
local v3 = 0

local function tryAttachEmber()
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

	if workspace:FindFirstChild("AttachedAzureEmber") then
		return
	end

	local clone = script.EmberTemplate:Clone()
	clone:FindFirstChildWhichIsA("BodyPosition", true):Destroy()
	clone.Name = "AttachedAzureEmber"
	clone:PivotTo(character:GetPivot())
	clone.Parent = workspace
	local basePart = clone:FindFirstChildWhichIsA("BasePart")
	basePart:SetAttribute("ParticleScale", 1)
	basePart:SetAttribute("IsPlayerEmber", true)
	basePart.Anchored = true
	basePart.Size = createVector(1, 1, 1)
	task.defer(function()
		local humanoid = character:WaitForChild("Humanoid")
		local _, v4 = clone:GetBoundingBox()
		local v5 = math.max(v4.X, v4.Y, v4.Z)

		while clone.Parent and Lighting:GetAttribute("IsBlueMoon") and humanoid.Health > 0 do
			task.wait()
			task.wait()
			task.wait()
			local boundingBox, v6 = localPlayer.Character:GetBoundingBox()
			local position = (boundingBox * CFrame.new(0, 0, v6.Z) * CFrame.new(3, -0.5, v5)).Position
			spr.target(basePart, 1, 1, {
				Position = position
			})
			basePart:SetAttribute("ParticleScale", v3 <= 30 and 0.25 or v3 <= 60 and 0.5 or v3 <= 120 and 0.75 or 1)
		end

		clone:Destroy()
	end)
	v.new("MoonShrine.Wisps"):replicate({
		ID = 1,
		Adornees = { basePart }
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRandomDirection()
	return Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
end

local function spawnEmber()
	local clone = script.EmberTemplate:Clone()
	clone:FindFirstChildWhichIsA("BodyPosition", true):Destroy()
	local basePart = clone:FindFirstChildWhichIsA("BasePart", true)
	basePart:SetAttribute("ParticleScale", 1)
	clone.PrimaryPart = basePart
	local touchedConnection = nil

	local function onTouch(p)
		if not (p.Parent and p.Parent:IsDescendantOf(localPlayer.Character)) then
			return
		end

		if touchedConnection then
			touchedConnection:Disconnect()
		end

		touchedConnection = nil
		assert(v2.collectBlueEmberEvent, "bad remotes.collectBlueEmberEvent"):FireServer()
		clone:Destroy()
	end

	touchedConnection = basePart.Touched:Connect(onTouch)
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local pivot = character:GetPivot()
	local v4 = math.random(-35, 35)
	local v5 = math.random(200, 250)
	local cframe = CFrame.Angles(0, math.rad(v4), 0)
	local vector2 = Vector3.new(0, 10, -v5)
	local v6 = pivot * cframe * CFrame.new(vector2)
	clone:PivotTo(v6)
	basePart.Anchored = true
	clone.Parent = workspace
	v.new("MoonShrine.Wisps"):replicate({
		ID = 1,
		Adornees = { clone.PrimaryPart }
	})
	task.defer(function()
		local total = 0
		local v7 = 0.9
		local v8 = 0

		while clone.Parent and humanoid.Health > 0 do
			local character2 = localPlayer.Character

			if not character2 then
				continue
			end

			local v9 = task.wait()
			local position = character2:GetPivot().Position
			local position2 = clone:GetPivot().Position
			local magnitude = (position2 - position).Magnitude
			local v10 = math.max(position.Y + 25, 6)

			if magnitude <= 100 then
				total += v9

				if total >= 5 then
					v7 = math.max(0.5, v7 - v9 * 0.05)
				end

				local v11 = CFrame.lookAt(position2, position) * CFrame.Angles(0, 3.141592653589793, 0)
				local v12 = math.rad((math.random(-35, 35)))
				local position3 = (v11 * CFrame.Angles(0, v12, 0) * CFrame.new(0, 0, -35)).Position
				spr.target(basePart, 1, v7, {
					Position = Vector3.new(position3.X, math.clamp(position.Y + 1, 6, v10), position3.Z)
				})
			elseif magnitude <= 500 then
				local now = os.clock()

				if now - v8 >= 1 then
					local v11 = position2 + getRandomDirection() * 75
					local vector3 = Vector3.new(v11.X, math.clamp(v11.Y, 6, v10), v11.Z)
					spr.target(basePart, 1, 0.3, {
						Position = vector3
					})
					v8 = now
				end
			else
				if magnitude <= 1000 then
				end

				spr.target(basePart, 1, 0.3, {
					Position = position
				})
			end

			if not (clone.Parent and Lighting:GetAttribute("BlueMoonEnded")) then
				continue
			end

			clone:Destroy()
			break
		end

		if clone.Parent then
			clone:Destroy()
			clone = nil
		end
	end)
end

return {
	OnStart = function(_)
		local Effect = require(game.ReplicatedStorage.Effect)
		v = Effect
		v2.spawnBlueEmbersOnClient = Net:RemoteEvent("SpawnBlueEmbers")
		v2.collectBlueEmberEvent = Net:RemoteEvent("CollectBlueEmber")
		v2.blueMoonTimerTick = Net:RemoteEvent("BlueMoonTimerTick")
		v2.playShrineActivateCutscene = Net:RemoteEvent("PlayShrineActivateCutscene")
		v2.addedToBlueMoonParticipants = Net:RemoteEvent("AddedToBlueMoonParticipants")
		assert(v2.spawnBlueEmbersOnClient, "bad remotes.spawnBlueEmbersOnClient").OnClientEvent:Connect(function(p)
			for _ = 1, p do
				task.defer(spawnEmber)
			end
		end)
		assert(v2.blueMoonTimerTick, "bad remotes.blueMoonTimerTick").OnClientEvent:Connect(function(p)
			v3 = p
		end)
		assert(v2.playShrineActivateCutscene, "bad remotes.playShrineActivateCutscene").OnClientEvent:Connect(function()
			local kitsuneIsland = workspace.Map:FindFirstChild("KitsuneIsland")
			local optimizedcylinder = kitsuneIsland and kitsuneIsland:FindFirstChild("optimizedcylinder")

			if not optimizedcylinder then
				return
			end

			v.new("MoonShrine.Scene"):replicate({
				CFrame = optimizedcylinder.CFrame,
				LockRange = 550,
				GlobalRange = 1500
			})
			task.wait(12)
			tryAttachEmber()
		end)
		assert(v2.addedToBlueMoonParticipants, "bad remotes.addedToBlueMoonParticipants").OnClientEvent:Connect(function()
			tryAttachEmber()
		end)
	end
}