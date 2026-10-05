local misc = game.ReplicatedStorage.ReplicatedAssets.Misc
local import = _G.import("event")
local v = nil

local function wordLength(value)
	v = v or _G.import("bank")
	return #v:normalizeWord(value or "")
end

local function getPetModel(p, list)
	local v2, v3 = unpack(list)
	local matchPets = p.TableModel and p.TableModel:FindFirstChild("MatchPets")
	local child = matchPets and matchPets:FindFirstChild((tostring(v2)))
	local child2 = child and child:FindFirstChild((tostring(v3)))
	return child2 and child2:FindFirstChild("Pet")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPetRoot(petModel)
	return petModel and (petModel.PrimaryPart or petModel:FindFirstChild("HumanoidRootPart", true))
end

local function syncLeaves(p, catalystId, leaves)
	local petModel = getPetModel(p, catalystId)
	local petRoot = getPetRoot(petModel) -- equivalent call inferred; original call site unknown

	if not (petModel and petRoot) then
		return
	end

	local lilyLeaves = petModel:FindFirstChild("LilyLeaves") or Instance.new("Folder")
	lilyLeaves.Name = "LilyLeaves"
	lilyLeaves.Parent = petModel
	lilyLeaves:ClearAllChildren()

	for i = 1, leaves do
		local v2 = (i - 1) / 5 * 3.141592653589793 * 2
		local v3 = math.sin(v2) * 0.9
		local v4 = math.cos(v2) * 0.9
		local clone = misc.Leaf:Clone()
		clone.Name = i
		clone.CFrame = petRoot.CFrame * CFrame.new(v3 * 2, v4 * 2, 0)
		clone.Parent = lilyLeaves
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Name = "LeafWeld"
		weldConstraint.Part0 = petRoot
		weldConstraint.Part1 = clone
		weldConstraint.Parent = clone
	end
end

return {
	GrowLeaf = {
		Info = {
			DisplayName = "Bud",
			Description = "Grow a leaf",
			PetDescription = "10+ letter words grow leaves. Strikes remove leaves.",
			MinLength = 10,
			RequiredLeaves = 5,
			TurnPlayer = true
		},
		Triggers = function(_)
			return {
				{
					Event = "Correct",
					Condition = function(p, _, _, _, _, _, _, value)
						v = v or _G.import("bank")
						return #v:normalizeWord(value or "") >= (p.MinLength or 10)
					end
				}
			}
		end,
		Execute = function(p, object, p2, p3)
			local requiredLeaves = p.RequiredLeaves or 5
			p3.Leaves = math.min((p3.Leaves or 0) + 1, requiredLeaves)

			if requiredLeaves <= p3.Leaves then
				local _, _ = unpack(p2.CatalystId)
				p3.Leaves = 0
				object:executeAbility(p3, "Bloom")
			end

			syncLeaves(object, p2.CatalystId, p3.Leaves)
		end
	},
	LoseLeaf = {
		Info = {
			DisplayName = "Lose Leaf",
			Description = "Lose a leaf on strike",
			Silent = true,
			TurnPlayer = true
		},
		Triggers = function(_)
			return {
				{
					Event = "Strike",
					Condition = function(_, _, _, p)
						return (p.Leaves or 0) > 0
					end
				}
			}
		end,
		Execute = function(_, p, p2, p3)
			p3.Leaves = math.max((p3.Leaves or 0) - 1, 0)
			syncLeaves(p, p2.CatalystId, p3.Leaves)
		end
	},
	Bloom = {
		Info = {
			DisplayName = "Bloom",
			Description = "Heal 1 HP",
			PetDescription = "At 5 leaves, heal 1hp."
		},
		Triggers = function(_)
			return {}
		end,
		Execute = function(_, object, p)
			local v2 = p.CatalystId[1]

			if (object.MaxHP[v2] or 2) <= object.HP[v2] then
				return
			end

			object.HP[v2] += 1
			import.firePlayers(object:players(), "regenerate", object:getPlayer(v2))
		end
	}
}