local MechCache = {}
local object = setmetatable({}, {
	__mode = "k"
})
local v = {
	Root = { "MasterBone", "Root" },
	UpperTorso = { "MasterBone", "Root", "UpperTorso" },
	Waist = { "MasterBone", "Root", "Waist" },
	Head = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"Head"
	},
	["Eye.L"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"Head"
	},
	["Eye.R"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"Head"
	},
	["UpperArm.L"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"UpperArm.L"
	},
	["UpperArm.R"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"UpperArm.R"
	},
	["LowerArm.L"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"UpperArm.L",
		"LowerArm.L"
	},
	["LowerArm.R"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"UpperArm.R",
		"LowerArm.R"
	},
	["Hand.L"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"UpperArm.L",
		"LowerArm.L",
		"Hand.L"
	},
	["Hand.R"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"UpperArm.R",
		"LowerArm.R",
		"Hand.R"
	},
	["UpperLeg.L"] = {
		"MasterBone",
		"Root",
		"Waist",
		"UpperLeg.L"
	},
	["UpperLeg.R"] = {
		"MasterBone",
		"Root",
		"Waist",
		"UpperLeg.R"
	},
	["LowerLeg.L"] = {
		"MasterBone",
		"Root",
		"Waist",
		"UpperLeg.L",
		"LowerLeg.L"
	},
	["LowerLeg.R"] = {
		"MasterBone",
		"Root",
		"Waist",
		"UpperLeg.R",
		"LowerLeg.R"
	},
	["Foot.L"] = {
		"MasterBone",
		"Root",
		"Waist",
		"UpperLeg.L",
		"LowerLeg.L",
		"Foot.L"
	},
	["Foot.R"] = {
		"MasterBone",
		"Root",
		"Waist",
		"UpperLeg.R",
		"LowerLeg.R",
		"Foot.R"
	},
	["Foot.Sole.Extra.L"] = {
		{
			"MasterBone",
			"Root",
			"Waist",
			"UpperLeg.L",
			"LowerLeg.L",
			"Foot.L",
			"Foot.Front.Extra.L",
			"Foot.Front.Extra.001.L",
			"Foot.Sole.L",
			"Foot.Sole.Extra.L"
		},
		{
			"MasterBone",
			"Root",
			"Waist",
			"UpperLeg.L",
			"LowerLeg.L",
			"Foot.L"
		}
	},
	["Foot.Sole.L.001"] = {
		{
			"MasterBone",
			"Root",
			"Waist",
			"UpperLeg.L",
			"LowerLeg.L",
			"Foot.L",
			"Foot.Front.Extra.L",
			"Foot.Front.Extra.001.L",
			"Foot.Sole.L",
			"Foot.Sole.L.001"
		},
		{
			"MasterBone",
			"Root",
			"Waist",
			"UpperLeg.L",
			"LowerLeg.L",
			"Foot.L"
		}
	},
	["Foot.Sole.R.001"] = {
		{
			"MasterBone",
			"Root",
			"Waist",
			"UpperLeg.R",
			"LowerLeg.R",
			"Foot.R",
			"Foot.Front.Extra.R",
			"Foot.Front.Extra.001.R",
			"Foot.Sole.R",
			"Foot.Sole.R.001"
		},
		{
			"MasterBone",
			"Root",
			"Waist",
			"UpperLeg.R",
			"LowerLeg.R",
			"Foot.R"
		}
	},
	["LowerLeg.Back.Propulsor.Left.L"] = {
		{
			"MasterBone",
			"Root",
			"Waist",
			"UpperLeg.L",
			"LowerLeg.L",
			"LowerLeg.Back.Propulsor.Left.L"
		},
		{
			"MasterBone",
			"Root",
			"Waist",
			"UpperLeg.L",
			"LowerLeg.L"
		}
	},
	["LowerLeg.Back.Propulsor.Right.L"] = {
		{
			"MasterBone",
			"Root",
			"Waist",
			"UpperLeg.L",
			"LowerLeg.L",
			"LowerLeg.Back.Propulsor.Right.L"
		},
		{
			"MasterBone",
			"Root",
			"Waist",
			"UpperLeg.L",
			"LowerLeg.L"
		}
	},
	["LowerLeg.Back.Propulsor.Left.R"] = {
		{
			"MasterBone",
			"Root",
			"Waist",
			"UpperLeg.R",
			"LowerLeg.R",
			"LowerLeg.Back.Propulsor.Left.R"
		},
		{
			"MasterBone",
			"Root",
			"Waist",
			"UpperLeg.R",
			"LowerLeg.R"
		}
	},
	["LowerLeg.Back.Propulsor.Right.R"] = {
		{
			"MasterBone",
			"Root",
			"Waist",
			"UpperLeg.R",
			"LowerLeg.R",
			"LowerLeg.Back.Propulsor.Right.R"
		},
		{
			"MasterBone",
			"Root",
			"Waist",
			"UpperLeg.R",
			"LowerLeg.R"
		}
	},
	["Jetpack.Main"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"Jetpack.Main"
	},
	["Jetpack.Propulsive.L"] = {
		{
			"MasterBone",
			"Root",
			"UpperTorso",
			"Jetpack.Main",
			"Jetpack.Propulsive.L"
		},
		{
			"MasterBone",
			"Root",
			"UpperTorso",
			"Jetpack.Main"
		}
	},
	["Jetpack.Propulsive.R"] = {
		{
			"MasterBone",
			"Root",
			"UpperTorso",
			"Jetpack.Main",
			"Jetpack.Propulsive.R"
		},
		{
			"MasterBone",
			"Root",
			"UpperTorso",
			"Jetpack.Main"
		}
	},
	["UpperWing.L"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"Jetpack.Main",
		"UpperWing.L"
	},
	["UpperWing.R"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"Jetpack.Main",
		"UpperWing.R"
	},
	["UpperWing.Top.L"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"Jetpack.Main",
		"UpperWing.L",
		"UpperWing.Top.L"
	},
	["UpperWing.Top.R"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"Jetpack.Main",
		"UpperWing.R",
		"UpperWing.Top.R"
	},
	["UpperWing.Middle.Top.L"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"Jetpack.Main",
		"UpperWing.L",
		"UpperWing.Middle.Top.L"
	},
	["UpperWing.Middle.Top.R"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"Jetpack.Main",
		"UpperWing.R",
		"UpperWing.Middle.Top.R"
	},
	["UpperWing.Middle.001.L"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"Jetpack.Main",
		"UpperWing.L",
		"UpperWing.Middle.Top.L",
		"UpperWing.Middle.001.L"
	},
	["UpperWing.Middle.001.R"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"Jetpack.Main",
		"UpperWing.R",
		"UpperWing.Middle.Top.R",
		"UpperWing.Middle.001.R"
	},
	["UpperWing.Bottom.Top.L"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"Jetpack.Main",
		"UpperWing.L",
		"UpperWing.Top.L",
		"UpperWing.Bottom.Top.L"
	},
	["UpperWing.Bottom.Top.R"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"Jetpack.Main",
		"UpperWing.R",
		"UpperWing.Top.R",
		"UpperWing.Bottom.Top.R"
	},
	["UpperWing.Middle.Middle.004.L"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"Jetpack.Main",
		"UpperWing.L",
		"UpperWing.Middle.Middle.001.L",
		"UpperWing.Middle.Middle.002.L",
		"UpperWing.Middle.Middle.003.L",
		"UpperWing.Middle.Middle.004.L"
	},
	["UpperWing.Middle.Middle.004.R"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"Jetpack.Main",
		"UpperWing.R",
		"UpperWing.Middle.Middle.001.R",
		"UpperWing.Middle.Middle.002.R",
		"UpperWing.Middle.Middle.003.R",
		"UpperWing.Middle.Middle.004.R"
	},
	["Sword.root"] = {
		{
			"MasterBone",
			"Root",
			"UpperTorso",
			"UpperArm.R",
			"LowerArm.R",
			"Hand.R",
			"Sword.rootSWORD"
		},
		{
			"MasterBone",
			"Root",
			"UpperTorso",
			"UpperArm.R",
			"LowerArm.R",
			"Hand.R",
			"Sword.root"
		}
	},
	["Sword.rootSWORD"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"UpperArm.R",
		"LowerArm.R",
		"Hand.R",
		"Sword.rootSWORD"
	},
	["Bone.037"] = {
		{
			"MasterBone",
			"Root",
			"UpperTorso",
			"UpperArm.R",
			"LowerArm.R",
			"Hand.R",
			"Sword.rootSWORD",
			"Bone.037SWORD"
		},
		{
			"MasterBone",
			"Root",
			"UpperTorso",
			"UpperArm.R",
			"LowerArm.R",
			"Hand.R",
			"Sword.root",
			"Bone.037"
		}
	},
	["Bone.034"] = {
		{
			"MasterBone",
			"Root",
			"UpperTorso",
			"UpperArm.R",
			"LowerArm.R",
			"Hand.R",
			"Sword.rootSWORD",
			"Bone.037SWORD",
			"Bone.034SWORD"
		},
		{
			"MasterBone",
			"Root",
			"UpperTorso",
			"UpperArm.R",
			"LowerArm.R",
			"Hand.R",
			"Sword.root",
			"Bone.037",
			"Bone.034"
		}
	},
	Bone = {
		{
			"MasterBone",
			"Root",
			"UpperTorso",
			"UpperArm.R",
			"LowerArm.R",
			"Hand.R",
			"Sword.rootSWORD",
			"Bone.037SWORD",
			"Bone.034SWORD",
			"BoneSWORD"
		},
		{
			"MasterBone",
			"Root",
			"UpperTorso",
			"UpperArm.R",
			"LowerArm.R",
			"Hand.R",
			"Sword.root",
			"Bone.037",
			"Bone.034",
			"Bone"
		}
	},
	["Bone.007"] = {
		{
			"MasterBone",
			"Root",
			"UpperTorso",
			"UpperArm.R",
			"LowerArm.R",
			"Hand.R",
			"Sword.rootSWORD",
			"Bone.037SWORD",
			"Bone.034SWORD",
			"BoneSWORD",
			"Bone.007SWORD"
		},
		{
			"MasterBone",
			"Root",
			"UpperTorso",
			"UpperArm.R",
			"LowerArm.R",
			"Hand.R",
			"Sword.root",
			"Bone.037",
			"Bone.034",
			"Bone",
			"Bone.007"
		}
	},
	["Bone.038"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"UpperArm.R",
		"LowerArm.R",
		"Bone.039",
		"Bone.040",
		"Bone.038"
	},
	["Middle.Finger.002.L"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"UpperArm.L",
		"LowerArm.L",
		"Hand.L",
		"Middle.Finger.L",
		"Middle.Joint.L",
		"Middle.Finger.001.L",
		"Middle.Joint.001.L",
		"Middle.Finger.002.L"
	},
	["Middle.Finger.002.R"] = {
		"MasterBone",
		"Root",
		"UpperTorso",
		"UpperArm.R",
		"LowerArm.R",
		"Hand.R",
		"Middle.Finger.R",
		"Middle.Joint.R",
		"Middle.Finger.001.R",
		"Middle.Joint.001.R",
		"Middle.Finger.002.R"
	}
}

local function resolveRootPart(mech)
	if typeof(mech) ~= "Instance" then
		return nil
	end

	if mech:IsA("BasePart") then
		return mech
	end

	if mech:FindFirstChild("Mech") then
		mech = mech.Mech
	end

	if mech:IsA("Model") then
		return mech:FindFirstChild("RootPart") or mech.PrimaryPart
	end

	return nil
end

local function resolvePath(child, list)
	for _, childName in ipairs(list) do
		if not child then
			return nil
		end

		child = child:FindFirstChild(childName)
	end

	return child
end

local function resolveAnyPath(rootPart, list)
	if typeof(list[1]) ~= "table" then
		return (resolvePath(rootPart, list))
	end

	for _, v2 in ipairs(list) do
		local path = resolvePath(rootPart, v2)

		if path then
			return path
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addIfFound(list, p)
	if p then
		table.insert(list, p)
	end
end

local function buildCategories(data)
	local v2 = {
		["Jetpack.Main"] = {}
	}
	addIfFound(v2["Jetpack.Main"], data["Jetpack.Propulsive.L"]) -- equivalent call inferred; original call site unknown
	addIfFound(v2["Jetpack.Main"], data["Jetpack.Propulsive.R"]) -- equivalent call inferred; original call site unknown
	addIfFound(v2["Jetpack.Main"], data["UpperWing.Top.L"]) -- equivalent call inferred; original call site unknown
	addIfFound(v2["Jetpack.Main"], data["UpperWing.Top.R"]) -- equivalent call inferred; original call site unknown
	v2["UpperLeg.L"] = {}
	addIfFound(v2["UpperLeg.L"], data["LowerLeg.Back.Propulsor.Left.L"]) -- equivalent call inferred; original call site unknown
	addIfFound(v2["UpperLeg.L"], data["LowerLeg.Back.Propulsor.Right.L"]) -- equivalent call inferred; original call site unknown
	addIfFound(v2["UpperLeg.L"], data["Foot.Sole.Extra.L"]) -- equivalent call inferred; original call site unknown
	v2["UpperLeg.R"] = {}
	addIfFound(v2["UpperLeg.R"], data["LowerLeg.Back.Propulsor.Left.R"]) -- equivalent call inferred; original call site unknown
	addIfFound(v2["UpperLeg.R"], data["LowerLeg.Back.Propulsor.Right.R"]) -- equivalent call inferred; original call site unknown
	addIfFound(v2["UpperLeg.R"], data["Foot.Sole.R.001"]) -- equivalent call inferred; original call site unknown
	v2["Jetpack.Propulsive.Holder.Bottom"] = {}
	addIfFound(v2["Jetpack.Propulsive.Holder.Bottom"], data["Jetpack.Propulsive.L"]) -- equivalent call inferred; original call site unknown
	addIfFound(v2["Jetpack.Propulsive.Holder.Bottom"], data["Jetpack.Propulsive.R"]) -- equivalent call inferred; original call site unknown
	return v2
end

local function buildMechHits(result)
	local v2 = {
		["Eye.L"] = result.Head,
		["Eye.R"] = result.Head,
		["Foot.Sole.Extra.L"] = result["Foot.L"],
		["Foot.Sole.R.001"] = result["Foot.R"],
		["Jetpack.Propulsive.L"] = result["Jetpack.Propulsive.L"],
		["Jetpack.Propulsive.R"] = result["Jetpack.Propulsive.R"],
		["LowerArm.L"] = result["LowerArm.L"],
		["LowerArm.R"] = result["LowerArm.R"],
		["LowerLeg.Back.Propulsor.Left.L"] = result["LowerLeg.Back.Propulsor.Left.L"],
		["LowerLeg.Back.Propulsor.Left.R"] = result["LowerLeg.Back.Propulsor.Left.R"],
		["LowerLeg.Back.Propulsor.Right.L"] = result["LowerLeg.Back.Propulsor.Right.L"],
		["LowerLeg.Back.Propulsor.Right.R"] = result["LowerLeg.Back.Propulsor.Right.R"],
		["UpperWing.Top.L"] = result["UpperWing.Top.L"],
		["UpperWing.Top.R"] = result["UpperWing.Top.R"]
	}
	v2.Categories = buildCategories(v2)
	return v2
end

local function buildMechSlice(result)
	return {
		Bone = result.Bone,
		["Bone.007"] = result["Bone.007"],
		["Bone.034"] = result["Bone.034"],
		["Eye.L"] = result.Head,
		["Eye.R"] = result.Head,
		["Foot.Sole.Extra.L"] = result["Foot.L"],
		["Foot.Sole.L.001"] = result["Foot.L"],
		["Foot.Sole.R.001"] = result["Foot.R"],
		["Jetpack.Propulsive.L"] = result["Jetpack.Main"],
		["Jetpack.Propulsive.R"] = result["Jetpack.Main"],
		["LowerArm.L"] = result["LowerArm.L"],
		["LowerArm.R"] = result["LowerArm.R"],
		["LowerLeg.Back.Propulsor.Left.L"] = result["LowerLeg.L"],
		["LowerLeg.Back.Propulsor.Left.R"] = result["LowerLeg.R"],
		["LowerLeg.Back.Propulsor.Right.L"] = result["LowerLeg.L"],
		["LowerLeg.Back.Propulsor.Right.R"] = result["LowerLeg.R"],
		["Sword.root"] = result["Sword.root"],
		["UpperWing.Middle.Top.L"] = result["UpperWing.Middle.Top.L"],
		["UpperWing.Middle.Top.R"] = result["UpperWing.Middle.Top.R"],
		["UpperWing.Top.L"] = result["UpperWing.Top.L"],
		["UpperWing.Top.R"] = result["UpperWing.Top.R"]
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function indexCache(parent, rootPart, result)
	object[rootPart] = result
	local parent2 = rootPart.Parent

	if parent2 then
		object[parent2] = result

		if parent2.Parent then
			object[parent2.Parent] = result
		end
	end

	if typeof(parent) == "Instance" then
		object[parent] = result
	end
end

function MechCache.Set(parent)
	if tostring(parent) == "HumanoidRootPart" then
		parent = parent.Parent
	end

	local rootPart = resolveRootPart(parent)

	if not rootPart then
		return nil
	end

	if object[rootPart] then
		warn("y")
		return object[rootPart]
	end

	local result = {
		RootPart = rootPart
	}

	for k, v2 in pairs(v) do
		result[k] = resolveAnyPath(rootPart, v2)
	end

	result.Toe = result["Foot.L"]
	result["Sole R"] = result["Foot.R"]
	result["Sole L"] = result["Foot.L"]
	result["Extra R"] = result["LowerLeg.R"]
	result["Extra L"] = result["LowerLeg.L"]
	result["LowerlegBackPropulsor L1"] = result["LowerLeg.Back.Propulsor.Left.L"]
	result["LowerlegBackPropulsor L2"] = result["LowerLeg.Back.Propulsor.Right.L"]
	result["LowerlegBackPropulsor R1"] = result["LowerLeg.Back.Propulsor.Left.R"]
	result["LowerlegBackPropulsor R2"] = result["LowerLeg.Back.Propulsor.Right.R"]
	result.Categories = buildCategories(result)
	result.MechHits = buildMechHits(result)
	result.MechSlice = buildMechSlice(result)
	indexCache(parent, rootPart, result) -- equivalent call inferred; original call site unknown
	return result
end

function MechCache.Get(parent)
	if typeof(parent) ~= "Instance" then
		return MechCache.Set(parent)
	end

	if tostring(parent) == "HumanoidRootPart" or tostring(parent) == "RootPart" then
		parent = parent.Parent
	end

	if tostring(parent) == "Mech" then
		parent = parent.Parent
	end

	local v2 = object[parent]

	if v2 then
		return v2
	end

	local rootPart = resolveRootPart(parent)

	if rootPart and object[rootPart] then
		return object[rootPart]
	end

	return MechCache.Set(parent)
end

local function resetVFX(folder)
	for _, effect in ipairs(folder:GetDescendants()) do
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = false
			local _defRate = effect:GetAttribute("_defRate")

			if _defRate == nil then
				effect:SetAttribute("_defRate", effect.Rate)
			else
				effect.Rate = _defRate
			end
		elseif effect:IsA("Beam") or effect:IsA("Trail") then
			effect.Enabled = false
		end
	end
end

function MechCache.ResetVFX(p)
	if p then
		resetVFX(p)
	end
end

function MechCache.GetVFX(p, p2, instance, parent)
	local v2 = MechCache.Get(p)

	if not (v2 and parent) then
		return nil, false
	end

	v2._vfxPool = v2._vfxPool or {}
	local v3 = v2._vfxPool[p2]

	if v3 and v3.Parent then
		warn("hey")
		resetVFX(v3)
		return v3, true
	else
		local clone = instance:Clone()
		clone.Parent = parent
		v2._vfxPool[p2] = clone
		return clone, false
	end
end

function MechCache.GetVFXChildren(p, p2, instance, parent)
	local v2 = MechCache.Get(p)

	if not (v2 and (parent and instance)) then
		return {}, false
	end

	v2._vfxChildPool = v2._vfxChildPool or {}
	local v3 = v2._vfxChildPool[p2]

	if v3 and v3[1] and v3[1].Parent == parent then
		for _, v4 in ipairs(v3) do
			resetVFX(v4)
		end

		warn("here?")
		return v3, true
	else
		local clones = {}

		for _, child in ipairs(instance:GetChildren()) do
			local clone = child:Clone()
			clone.Parent = parent
			table.insert(clones, clone)
		end

		v2._vfxChildPool[p2] = clones
		return clones, false
	end
end

return MechCache