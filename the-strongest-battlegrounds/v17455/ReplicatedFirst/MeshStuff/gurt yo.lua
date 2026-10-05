warn("RUNNING MESH EMISSION SYSTEM")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
_G.MESH_EFFECT_FOLDER = game.Workspace:WaitForChild("MeshCache", 5) or game.Workspace.Camera
require(script.MeshEmitter)

if not _G.MESH_EFFECT_FOLDER then
	local GetEffectFolder

	GetEffectFolder = function()
		local meshEffectFolder = workspace:GetAttribute("MeshEffectFolder")

		if not meshEffectFolder then
			workspace:SetAttribute("MeshEffectFolder", "Workspace")
			return GetEffectFolder()
		end

		local v = string.split(meshEffectFolder, ".")
		local game2 = game

		for i = 1, #v do
			game2 = game2:FindFirstChild(v[i])

			if not game2 then
				return nil
			end
		end

		return game2
	end

	local _ = GetEffectFolder() or workspace.CurrentCamera
end

table.create(512)
table.create(512)
table.create(512)
table.create(512)
table.create(64)
local v = {
	Linked = {},
	Connections = {},
	Emit = function(self, p, p2: number?)
		local meshEmitter = self:GetMeshEmitter(p)

		if meshEmitter then
			meshEmitter:Emit(p2)
		end
	end,
	_Enable = function(self, p)
		local meshEmitter = self:GetMeshEmitter(p)

		if meshEmitter then
			meshEmitter:Enable()
		end
	end,
	_Disable = function(self, p)
		local meshEmitter = self:GetMeshEmitter(p)

		if meshEmitter then
			meshEmitter:Disable()
		end
	end,
	GetMeshEmitter = function(self, p2)
		return self.Linked[p2]
	end,
	_DestroyMeshEmitter = function(self, p)
		local meshEmitter = self:GetMeshEmitter(p)

		if meshEmitter then
			meshEmitter:Destroy()
		end

		self.Linked[p] = nil
		local connection = self.Connections[p]

		if connection then
			for k, connection2 in pairs(connection) do
				connection2:Disconnect()
				connection[k] = nil
			end

			self.Connections[p] = nil
		end
	end,
	_NewMeshEmitter = function(self, _) end
}
local v2 = {}
local tryLink

tryLink = function(instance)
	if v.Linked[instance] then
		return
	end

	if instance:IsDescendantOf(workspace) and instance.Value then
		local connection = v2[instance]

		if connection then
			connection:Disconnect()
			v2[instance] = nil
		end

		v:_NewMeshEmitter(instance)
	elseif not v2[instance] then
		v2[instance] = instance.AncestryChanged:Connect(function()
			tryLink(instance)
		end)
	end
end

local function tryUnlink(p)
	if v.Linked[p] then
		v:_DestroyMeshEmitter(p)
	end

	local connection = v2[p]

	if connection then
		connection:Disconnect()
		v2[p] = nil
	end
end

function v:Clean()
	for k, _ in pairs(self.Linked) do
		self:_DestroyMeshEmitter(k)
	end

	self.Linked = {}

	for k, connection in pairs(v2) do
		connection:Disconnect()
		v2[k] = nil
	end

	RunService:UnbindFromRenderStep("SET_EMITTERS")
end

for _, v3 in CollectionService:GetTagged("MeshEmitter") do
	tryLink(v3)
end

CollectionService:GetInstanceAddedSignal("MeshEmitter"):Connect(tryLink)
CollectionService:GetInstanceRemovedSignal("MeshEmitter"):Connect(tryUnlink)