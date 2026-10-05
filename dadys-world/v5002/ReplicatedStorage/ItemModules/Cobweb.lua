local createVector = vector.create
local Cobweb = {
	Name = "Cobweb",
	AbilityOnlyItem = true,
	Rarity = "Rare",
	PointCost = 0,
	Icon = "rbxassetid://6794188517",
	Description = "Throw down a cobweb that stuns the Twisteds who walk into it.",
	WebLifetime = 20,
	StunDuration = 6,
	CatchRadius = 7,
	MaxCatches = 2
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

local function buildPatch(vector2)
	local part = Instance.new("Part")
	part.Name = "CobwebPatch"
	part.Shape = Enum.PartType.Cylinder
	part.Size = createVector(0.2, 14, 14)
	part.CFrame = CFrame.new(vector2) * CFrame.Angles(0, 0, 1.5707963267948966)
	part.Color = Color3.fromRGB(235, 235, 240)
	part.Material = Enum.Material.Sand
	part.Transparency = 0.35
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	return part
end

function Cobweb.UseItem(instance, p)
	local v = {
		Outcome = true,
		Reason = "Cobweb thrown!"
	}
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return v
	end

	Audio:Play("Sounds.Misc.UseSound", {
		Parent = humanoidRootPart
	})
	local ServerScriptService = game:GetService("ServerScriptService")
	local success, result = pcall(function()
		return require(ServerScriptService.MonsterAI.Modules.StunEffect)
	end)
	local success2, result2 = pcall(function()
		return require(ServerScriptService.MonsterAI.BehaviorTree.BTDebug)
	end)

	if success and result and success2 and result2 then
		local v2 = humanoidRootPart.Position.Y - humanoidRootPart.Size.Y / 2
		local vector2 = Vector3.new(humanoidRootPart.Position.X, v2, humanoidRootPart.Position.Z)
		local patch = buildPatch(vector2)
		local currentRoom = workspace:FindFirstChild("CurrentRoom")
		patch.Parent = currentRoom and currentRoom:FindFirstChildOfClass("Model") or workspace
		task.spawn(function()
			local v3 = os.clock() + Cobweb.WebLifetime
			local count = 0
			local v4 = {}

			while os.clock() < v3 and count < Cobweb.MaxCatches and patch.Parent do
				for _, v6 in ipairs(result2.registeredAis()) do
					local chaser = v6.chaser

					if not chaser or not chaser.Parent or v4[chaser] then
						continue
					end

					local humanoidRootPart2 = chaser:FindFirstChild("HumanoidRootPart")

					if not (humanoidRootPart2 and (humanoidRootPart2.Position - vector2).Magnitude <= Cobweb.CatchRadius and result.apply(
						v6.ai,
						Cobweb.StunDuration,
						{
							source = "Cobweb"
						}
					)) then
						continue
					end

					v4[chaser] = true
					count += 1
					local BuffIndicator = require(ReplicatedStorage.Modules.Gameplay.BuffIndicator)
					BuffIndicator.tell(
						instance,
						string.format("Your Cobweb caught a Twisted! Stunned for %d seconds!", Cobweb.StunDuration)
					)

					if Cobweb.MaxCatches <= count then
						break
					end
				end

				task.wait(0.25)
			end

			if patch.Parent then
				patch:Destroy()
			end
		end)
		p.Value = "None"
		local child = workspace.Info.PlayerStats:FindFirstChild(instance.Name)

		if child then
			local survivalPoints = child:WaitForChild("SurvivalPoints")
			survivalPoints.Value += 5
		end

		return v
	else
		warn("[Cobweb] StunEffect/BTDebug unavailable — web not armed")
		p.Value = "None"
		return v
	end
end

return Cobweb