local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "LODModel"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self:_SetupLODs()
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "SetLOD", function(p: number)
		self:_SetLOD(p)
	end))
end

function v:_SetLOD(p2: number)
	print("set", p2)
	self._usePart:ApplyMesh(self._lods[p2])
end

function v:_SetupLODs()
	local partsByName = {}
	local count = 0
	local parts = {}

	for _, part in self.Instance:GetChildren() do
		if not part:IsA("MeshPart") then
			continue
		end

		partsByName[part.Name] = part
		count += 1
	end

	for i = 1, count do
		local part = partsByName[tostring(i)]

		if part then
			if part:IsA("MeshPart") then
				table.insert(parts, part)

				if i == count then
					self._usePart = part
				else
					part.Parent = nil
					local usePart = part
					self._Janitor:Add(function()
						usePart.Parent = self.Instance
					end)
				end
			else
				warn(part:GetFullName(), "is not a MeshPart")
			end
		else
			warn(i, "is not a child of", self.Instance:GetFullName())
		end
	end

	self._lods = parts
end

function v:Stop()
	self._Janitor:Destroy()
end

return v