local Workspace = game:GetService("Workspace")
local currentCamera = Workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local _ = workspace.CurrentCamera
local v = Component.new({
	Tag = "UIScale"
})

local function map(p)
	return (math.clamp(0.4 + (p - 320) / 960 * 0.6, 0.4, 1))
end

function v:Construct()
	self.trove = Trove.new()
end

function v:UpdateScale()
	local viewportSize = currentCamera.ViewportSize
	self.Instance.Scale = math.clamp(0.4 + (math.min(viewportSize.X, viewportSize.Y) - 320) / 960 * 0.6, 0.4, 1) * 1
end

function v:Start()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateScale()
		self:UpdateScale()
	end

	self.trove:Add(currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale))
	updateScale() -- equivalent call inferred; original call site unknown
end

function v.Stop(p)
	p.trove:Destroy()
end

return v