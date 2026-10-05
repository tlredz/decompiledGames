local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local landscape = ReplicatedStorage.AdminAbuse.FabAdminAbuse.Landscape
local clone = nil
local densitiesByAtmosphere = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function updateLandscape(instance, currentCamera)
	if instance.Parent ~= currentCamera then
		instance.Parent = currentCamera
	end

	instance:PivotTo(CFrame.new(currentCamera.CFrame.Position))
end

local function suppressAtmospheres()
	for _, atmosphere in Lighting:GetChildren() do
		if not atmosphere:IsA("Atmosphere") then
			continue
		end

		if densitiesByAtmosphere[atmosphere] == nil then
			densitiesByAtmosphere[atmosphere] = atmosphere.Density
		end

		atmosphere.Density = 0
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreAtmospheres()
	for k, density in densitiesByAtmosphere do
		if k.Parent ~= nil then
			k.Density = density
		end
	end

	table.clear(densitiesByAtmosphere)
end

local Landscape = {}

function Landscape.start()
	Landscape.finish()
	clone = landscape:Clone()
	suppressAtmospheres()
	Landscape.update()
end

function Landscape.update()
	local v = clone
	local currentCamera = Workspace.CurrentCamera

	if v ~= nil then
		if currentCamera ~= nil then
			updateLandscape(v, currentCamera) -- equivalent call inferred; original call site unknown
		end

		suppressAtmospheres()
	end
end

function Landscape.finish()
	local v = clone

	if v ~= nil then
		v:Destroy()
		clone = nil
	end

	restoreAtmospheres() -- equivalent call inferred; original call site unknown
end

return Landscape