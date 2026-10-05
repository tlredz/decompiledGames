local import = _G.import("event")

local function nextPlayerId(p, p2)
	for i = 1, p.Capacity - 1 do
		local v = (p2 - 1 + i) % p.Capacity + 1

		if p.Players[v] ~= "null" then
			return v
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getStingTarget(object, p)
	if p == object.TurnPlayer then
		return nextPlayerId(object, p)
	end

	return object.TurnPlayer
end

local function getPetModel(p, list)
	local v, v2 = unpack(list)
	local matchPets = p.TableModel and p.TableModel:FindFirstChild("MatchPets")
	local child = matchPets and matchPets:FindFirstChild((tostring(v)))
	local child2 = child and child:FindFirstChild((tostring(v2)))
	return child2 and child2:FindFirstChild("Pet")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPetRoot(instance)
	return instance and (instance.PrimaryPart or instance:FindFirstChild("HumanoidRootPart", true))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearSwarmBees(object, catalystId)
	local petModel = getPetModel(object, catalystId)
	local swarmBees = petModel and petModel:FindFirstChild("SwarmBees")

	if swarmBees then
		swarmBees:Destroy()
	end
end

local function prepareSwarmBee(folder)
	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = false
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true
	end
end

local function syncSwarmBees(object, catalystId, p)
	local petModel = getPetModel(object, catalystId)
	local petRoot = getPetRoot(petModel) -- equivalent call inferred; original call site unknown

	if not (petModel and petRoot) then
		return
	end

	local parent = petModel:FindFirstChild("SwarmBees")

	if not parent then
		parent = Instance.new("Folder")
		parent.Name = "SwarmBees"
		parent.Parent = petModel
	end

	for _, child in ipairs(parent:GetChildren()) do
		if not (tonumber(child.Name) and p < tonumber(child.Name)) then
			continue
		end

		child:Destroy()
	end

	for i = 1, p do
		if parent:FindFirstChild((tostring(i))) then
			continue
		end

		local clone = petModel:Clone()
		clone.Name = tostring(i)
		local swarmBees = clone:FindFirstChild("SwarmBees")

		if swarmBees then
			swarmBees:Destroy()
		end

		prepareSwarmBee(clone)
		local petRoot2 = getPetRoot(clone) -- equivalent call inferred; original call site unknown

		if petRoot2 then
			local v2 = i % 2 == 0 and -1 or 1
			clone:PivotTo(petRoot.CFrame * CFrame.new(v2 * 2, i * 0.15 + 0.3, -0.45 - i * 0.1))
			clone.Parent = parent
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Name = "SwarmWeld"
			weldConstraint.Part0 = petRoot
			weldConstraint.Part1 = petRoot2
			weldConstraint.Parent = petRoot2
		else
			clone:Destroy()
		end
	end
end

local function addStrikes(object, stingTarget, player, p)
	if object.Players[stingTarget] ~= player then
		return
	end

	object.Strikes[stingTarget] = math.min(5, (object.Strikes[stingTarget] or 0) + p)
	import.firePlayers(object:players(), "strike", player, object.Strikes[stingTarget])
	local v2 = object:trigger("Strike")

	if object.Strikes[stingTarget] >= 5 then
		object:damage()
	end

	return v2
end

return {
	Sting = {
		Info = {
			DisplayName = "Sting",
			Description = "Add strike(s)",
			PetDescription = "Every 5 rounds, or at 3 buddies add strike(s).",
			RotationCooldown = 5,
			TurnPlayer = false
		},
		Triggers = function(_)
			return {
				{
					Event = "AnswerBegan",
					Condition = function(_, p)
						return p.StrikeAbilityRound ~= p.RoundNumber
					end
				}
			}
		end,
		Execute = function(_, object, p, p2)
			local stingTarget = getStingTarget(object, p.CatalystId[1]) -- equivalent call inferred; original call site unknown

			if not stingTarget then
				return
			end

			local player = object:getPlayer(stingTarget)
			local v3 = math.max(1, p2.Swarm or 1)
			object.StrikeAbilityRound = object.RoundNumber
			object:attack(p.CatalystId, stingTarget)
			clearSwarmBees(object, p.CatalystId) -- equivalent call inferred; original call site unknown

			if stingTarget == object.TurnPlayer then
				addStrikes(object, stingTarget, player, v3)
			else
				object:addActivation("Round", function()
					addStrikes(object, stingTarget, player, v3)
				end)
			end

			p2.Swarm = 1
		end
	},
	Swarm = {
		Info = {
			DisplayName = "Swarm",
			Description = "Add a buddy",
			PetDescription = "Answer in under 2s to gain a buddy.",
			MaxAnswerTime = 2,
			RequiredSwarm = 3,
			TurnPlayer = true
		},
		Triggers = function(_)
			return {
				{
					Event = "Correct",
					Condition = function(p, p2, _, _, _, _, p3)
						return not (p2.RoundNumber <= 1) and p3 <= (p.MaxAnswerTime or 4)
					end
				}
			}
		end,
		Execute = function(p, object, p2, p3)
			p3.Swarm = (p3.Swarm or 1) + 1
			syncSwarmBees(object, p2.CatalystId, p3.Swarm - 1)

			if p3.Swarm < (p.RequiredSwarm or 3) then
				return
			end

			local _, _ = unpack(p2.CatalystId)
			object:executeAbility(p3, "Sting")
		end
	}
}