game:GetService("CollectionService")
require(script.Parent.MeshCache)
local Mesh = require(script.Parent.Mesh)
local _ = {
	"SizeX",
	"SizeY",
	"SizeZ",
	"Size",
	"Spin",
	"SpinX",
	"SpinY",
	"SpinZ",
	"Color",
	"Transparency"
}

local function meshOnDeath(p)
	local meshEmitter = p.MeshEmitter
	local activeMeshIndex = meshEmitter.ActiveMeshIndex
	local v = activeMeshIndex[p]

	if not v then
		return
	end

	activeMeshIndex[p] = nil
	local activeMeshes = meshEmitter.ActiveMeshes
	local count = #activeMeshes

	if v ~= count then
		local activeMesh = activeMeshes[count]
		activeMeshes[v] = activeMesh
		activeMeshIndex[activeMesh] = v
	end

	activeMeshes[count] = nil
	meshEmitter.Activity -= 1
end

local function noopOnDeath() end

local MeshEmitter = {}

function MeshEmitter.new(_, _, _) end

function MeshEmitter._BuildSequenceCache(_) end

function MeshEmitter._CreateCache(_) end

function MeshEmitter.Emit(_, _: number?) end

function MeshEmitter._AddActiveMesh(state, p)
	p.OnDeath = meshOnDeath
	local activeMeshes = state.ActiveMeshes
	local v = #activeMeshes + 1
	activeMeshes[v] = p
	state.ActiveMeshIndex[p] = v
	state.Activity += 1
end

function MeshEmitter:Destroy()
	self.EmissionEnabled = false
	local activeMeshes = self.ActiveMeshes
	local count = #activeMeshes
	local v = table.create(count)

	for i = 1, count do
		v[i] = activeMeshes[i]
	end

	self.ActiveMeshes = {}
	self.ActiveMeshIndex = {}
	self.Activity = 0

	for i = 1, count do
		local v2 = v[i]
		v2.OnDeath = noopOnDeath
		v2:Destroy()
	end

	self.MeshCache:Destroy()
end

function MeshEmitter.Enable(p)
	p.EmissionEnabled = true
end

function MeshEmitter.Disable(p)
	p.EmissionEnabled = false
end

function MeshEmitter.Step(_, _, _, _, _, _, _, _) end

MeshEmitter.releaseProperty = Mesh.releaseProperty
return MeshEmitter