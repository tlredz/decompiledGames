if not game:IsLoaded() then
	game.Loaded:Wait()
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIAnimations = require(ReplicatedStorage:WaitForChild("UI"):WaitForChild("UIAnimations"))
local parent = script.Parent
local main = parent:WaitForChild("Main")
local folder = Instance.new("Folder")
folder.Name = "WorldModelStorage"
folder.Parent = game:GetService("ReplicatedStorage")
local v = {}

for _, worldModel in parent:GetDescendants() do
	if worldModel:IsA("WorldModel") and worldModel.Parent then
		table.insert(v, {
			Parent = worldModel.Parent,
			WorldModel = worldModel
		})
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function shown()
	return parent.Enabled and main.Visible
end

if not shown() then
	UIAnimations.pause()
end

UIAnimations.start(parent)

for _, v2 in v do
	v2.WorldModel.Parent = folder
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createWorldModels()
	for _, v2 in v do
		v2.WorldModel.Parent = v2.Parent
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyWorldModels()
	for _, v2 in v do
		v2.WorldModel.Parent = folder
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function update()
	if shown() then
		createWorldModels() -- equivalent call inferred; original call site unknown
		UIAnimations.resume()
	else
		UIAnimations.pause()
		destroyWorldModels() -- equivalent call inferred; original call site unknown
	end
end

main:GetPropertyChangedSignal("Visible"):Connect(update)
parent:GetPropertyChangedSignal("Enabled"):Connect(update)
update() -- equivalent call inferred; original call site unknown