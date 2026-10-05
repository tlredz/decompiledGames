local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Finisher = require(ReplicatedStorage.Modules.Finisher)
require(ReplicatedStorage.Modules.Utility)
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self:_Init()
	return self
end

function object.PlayServer(object2)
	object2:_AnchorModel(0)
	wait(2.8)
	object2:_HideBody()
end

function object:PlayClient()
	local rootPart = self._subject.RootPart
	local v = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function register(p)
		v[p] = {
			Exponent = 1 + 4 * math.random(),
			OriginalTransparency = p.Transparency
		}
	end

	for _, part in pairs(self:_GetObjects(true)) do
		if not part:IsA("BasePart") or part.Transparency > 0.99 then
			continue
		end

		register(part) -- equivalent call inferred; original call site unknown

		if part.Parent ~= rootPart.Parent then
			continue
		end

		local selectionBox = Instance.new("SelectionBox")
		selectionBox.Adornee = part
		selectionBox.Color = BrickColor.new("Toothpaste")
		selectionBox.Parent = part
		register(selectionBox) -- equivalent call inferred; original call site unknown
	end

	local now = tick()

	local function set(p)
		for k, v2 in pairs(v) do
			k.Transparency = v2.OriginalTransparency + (1 - v2.OriginalTransparency) * p ^ v2.Exponent
		end
	end

	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		set(math.clamp((tick() - (now + 1.8)) / 1, 0, 1))
	end)
	table.insert(self._connections, renderSteppedConnection)
	self:CreateSound("rbxassetid://130113415", 1, 1, rootPart, true, 5)
	wait(2.8)
	renderSteppedConnection:Disconnect()
	set(1)
	self:_HideBody()
end

function object:_Init() end

return object