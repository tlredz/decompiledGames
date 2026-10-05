local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local ChestAssets = require(script.Parent.ChestAssets)
local ChestSeal = {}
local v = {}

local function place(instance, state)
	local boundingBox, v2 = instance:GetBoundingBox()
	local sealEffect = instance:GetAttribute("SealEffect")
	local asset = vfxUtility.cloneAsset(
		ChestAssets.EffectFolder,
		instance,
		typeof(sealEffect) ~= "string" and "SealVFX" or sealEffect
	)
	state.seal = asset

	if asset == nil then
		return
	end

	local pivot = asset:GetPivot()
	local vector = Vector3.new(boundingBox.Position.X, boundingBox.Position.Y - v2.Y / 2, boundingBox.Position.Z)
	local spawnOffset = instance:GetAttribute("SpawnOffset")

	if typeof(spawnOffset) == "Vector3" then
		vector -= instance:GetPivot().Rotation * spawnOffset
	end

	asset:PivotTo(pivot + (vector - pivot.Position))
end

local function sync(instance, state)
	local v2 = instance:GetAttribute("ChestState") == "Locked"
	local sealed = state.sealed

	if v2 and state.seal == nil then
		place(instance, state)
	end

	if state.seal then
		vfxUtility.EnableAll(state.seal, v2)

		for _, v3 in state.seal:QueryDescendants("Light") do
			v3.Enabled = v2
		end
	end

	state.sealed = v2

	if sealed == true and not v2 then
		ChestAssets.play(state.breakSound)
		ChestAssets.burst(instance, "SealBreakEffect")
	end
end

function ChestSeal.track(instance)
	local v2 = v[instance]

	if v2 then
		sync(instance, v2)
		return
	end

	local v3 = {
		seal = nil,
		breakSound = ChestAssets.sound(instance, "SealBreakSound"),
		sealed = nil,
		conns = {}
	}
	v[instance] = v3
	sync(instance, v3)
	table.insert(v3.conns, instance:GetAttributeChangedSignal("ChestState"):Connect(function()
		sync(instance, v3)
	end))
	table.insert(v3.conns, instance.Destroying:Connect(function()
		ChestSeal.untrack(instance)
	end))
end

function ChestSeal.untrack(p)
	local v2 = v[p]

	if not v2 then
		return
	end

	for _, conn in v2.conns do
		conn:Disconnect()
	end

	if v2.breakSound then
		v2.breakSound:Destroy()
	end

	if v2.seal then
		v2.seal:Destroy()
	end

	v[p] = nil
end

function ChestSeal.teardown()
	for k in v do
		ChestSeal.untrack(k)
	end
end

return ChestSeal