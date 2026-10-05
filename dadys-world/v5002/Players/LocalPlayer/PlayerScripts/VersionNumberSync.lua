local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Universe = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("Universe"))

local function applyTo(instance)
	if not (instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox")) then
		return
	end

	local gameVersion = Workspace:GetAttribute("GameVersion")
	local placeSubversion = Universe:GetPlaceSubversion() or ""

	if gameVersion ~= nil then
		instance.Text = tostring(gameVersion) .. tostring(placeSubversion)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyToAll()
	for _, v in ipairs(CollectionService:GetTagged("VersionNumber")) do
		applyTo(v)
	end
end

applyToAll() -- equivalent call inferred; original call site unknown
CollectionService:GetInstanceAddedSignal("VersionNumber"):Connect(applyTo)
Workspace:GetAttributeChangedSignal("GameVersion"):Connect(applyToAll)