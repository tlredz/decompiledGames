local Pool = require(script.Parent.Parent.Pool)
local BoltGen = require(script.Parent.BoltGen)
local cframe = CFrame.new(1000000000, 1000000000, 1000000000)
local Rig = {
	MAX_BOLT_PARTS = 64,
	Rigs = setmetatable({}, {
		__mode = "k"
	})
}

local function buildSegment(p)
	local copyBare = Pool.copyBare(p)
	copyBare.Anchored = true
	copyBare.CanCollide = false
	copyBare.CanQuery = false
	copyBare.CanTouch = false
	copyBare.Massless = true
	copyBare.Locked = true
	copyBare.Archivable = false
	copyBare.Transparency = 0
	return copyBare, copyBare:FindFirstChildWhichIsA("Decal") or copyBare:FindFirstChildWhichIsA("Texture")
end

function Rig.layoutFor(data)
	return BoltGen.layout(data.SegmentCount.Max, data.ForkDepth.Max, data.ForkChance.Max, 64)
end

function Rig.buildRig(p)
	local layoutFor, mainSegs, forkSegs, forkSlots = Rig.layoutFor(p)
	local model = Instance.new("Model")
	model.Name = "LightningBolt"
	model.Archivable = false
	model:SetAttribute("_lightningBolt", true)
	local v4 = {
		partCount = layoutFor,
		mainSegs = mainSegs,
		forkSegs = forkSegs,
		forkSlots = forkSlots,
		parts = table.create(layoutFor),
		rollCFs = table.create(layoutFor),
		writeCFs = table.create(layoutFor),
		segLen = table.create(layoutFor),
		revealDist = table.create(layoutFor),
		revealOrder = table.create(layoutFor),
		widthScale = table.create(layoutFor),
		decals = table.create(layoutFor),
		slotDepth = table.create((math.max(forkSlots, 1))),
		ptBuf = table.create(mainSegs + 1),
		basePtBuf = table.create(mainSegs + 1),
		forkPtBuf = table.create(forkSegs + 1),
		forkAnchorPos = {},
		forkAnchorDir = {},
		forkAnchorReveal = {},
		forkAnchorSlot = {},
		forkAnchorPtIdx = {},
		forkOriginIdx = {},
		forkParentSlot = {},
		forkParentPtIdx = {},
		forkLen = {},
		forkU = {},
		forkV = {},
		forkSeedU = {},
		forkSeedV = {},
		forkLocalPts = {},
		forkWorldPts = {},
		prevLive = table.create(layoutFor),
		lastWrittenLen = table.create(layoutFor),
		sizeWriteIdx = table.create(layoutFor),
		newlyLiveIdx = table.create(layoutFor),
		gradColor = table.create(layoutFor)
	}

	for i = 1, forkSlots do
		v4.forkLocalPts[i] = table.create(forkSegs + 1)
		v4.forkWorldPts[i] = table.create(forkSegs + 1)
		v4.forkOriginIdx[i] = 0
		v4.forkParentSlot[i] = 0
	end

	local v5 = not (forkSlots > 0) and 0 or math.max(1, (math.ceil(forkSlots / 2))) or 0

	for i = 1, forkSlots do
		v4.slotDepth[i] = i <= v5 and 1 or 2
	end

	local v6 = math.max(0.45, not p.ForkLengthScale and 0.4 or p.ForkLengthScale.Max or 0.4)

	for i = 1, layoutFor do
		local renderTemplate = p.RenderTemplate
		local copyBare = Pool.copyBare(renderTemplate)
		copyBare.Anchored = true
		copyBare.CanCollide = false
		copyBare.CanQuery = false
		copyBare.CanTouch = false
		copyBare.Massless = true
		copyBare.Locked = true
		copyBare.Archivable = false
		copyBare.Transparency = 0
		local decal = copyBare:FindFirstChildWhichIsA("Decal") or copyBare:FindFirstChildWhichIsA("Texture")
		copyBare.Name = "Seg" .. i
		copyBare.CFrame = cframe
		copyBare.Parent = model
		v4.parts[i] = copyBare
		v4.decals[i] = decal
		v4.rollCFs[i] = cframe
		v4.writeCFs[i] = cframe
		v4.segLen[i] = 0.05
		v4.revealDist[i] = 1e999
		v4.revealOrder[i] = i
		v4.prevLive[i] = false
		v4.lastWrittenLen[i] = -1

		if i <= mainSegs then
			v4.widthScale[i] = 1
		else
			local v7 = math.floor((i - mainSegs - 1) / forkSegs) + 1
			v4.widthScale[i] = v6 ^ (v4.slotDepth[v7] or 1)
		end
	end

	Rig.Rigs[model] = v4
	return model, v4
end

function Rig.acquireBolt(p)
	local layoutFor = Rig.layoutFor(p)
	local v = p.Pool ~= false and Pool.acquire(p.RenderTemplate, "Lightning")

	if v then
		local rig = Rig.Rigs[v]

		if rig and rig.partCount == layoutFor and rig.parts[1] and rig.parts[1].Parent == v then
			v:SetAttribute("_PartIcleEmit", true)
			return v, rig
		else
			pcall(function()
				v:Destroy()
			end)
		end
	end

	local rig, v2 = Rig.buildRig(p)
	rig:SetAttribute("_PartIcleEmit", true)
	return rig, v2
end

return Rig