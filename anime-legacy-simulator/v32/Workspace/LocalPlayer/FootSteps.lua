local module = require("@game/ReplicatedStorage/Omni")
module:WaitInitialization()
local parent = script.Parent
local humanoid = parent:WaitForChild("Humanoid")
local leftFoot = parent:WaitForChild("LeftFoot")
local rightFoot = parent:WaitForChild("RightFoot")
local footSteps = module.Services.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Effects"):WaitForChild("Movement"):WaitForChild("FootSteps")
local v = nil
local connection = nil
local clone = footSteps:Clone()
clone.Anchored = false
clone.CanCollide = false
clone.CFrame = leftFoot.CFrame
local weldConstraint = Instance.new("WeldConstraint")
weldConstraint.Part0 = leftFoot
weldConstraint.Part1 = clone
weldConstraint.Parent = clone
clone.Parent = parent
local clone2 = footSteps:Clone()
clone2.Anchored = false
clone2.CanCollide = false
clone2.CFrame = rightFoot.CFrame
local weldConstraint2 = Instance.new("WeldConstraint")
weldConstraint2.Part0 = rightFoot
weldConstraint2.Part1 = clone2
weldConstraint2.Parent = clone2
clone2.Parent = parent

local function IsLowMode()
	local settings = module.Data and module.Data.Settings
	return settings ~= nil and settings["Low Mode"] == true
end

local function Update()
	local running = module.Instance:GetAttribute("Running")
	local wallRunning = parent:GetAttribute("WallRunning")
	local v2 = wallRunning or humanoid.MoveDirection.Magnitude > 0
	local v3 = wallRunning or humanoid.FloorMaterial ~= Enum.Material.Air
	local settings = module.Data and module.Data.Settings
	local v6 = (settings == nil or settings["Low Mode"] ~= true) and v2 and v3 and (running or wallRunning) and true or false

	if v6 == v then
		return
	end

	v = v6

	if v6 then
		module.Utils.Particles:EnableAll(clone)
		module.Utils.Particles:EnableAll(clone2)
	else
		module.Utils.Particles:DisableAll(clone)
		module.Utils.Particles:DisableAll(clone2)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Cleanup()
	if not connection then
		return
	end

	connection:Disconnect()
	connection = nil
end

parent.AttributeChanged:Connect(Update)
module.Instance.AttributeChanged:Connect(Update)
humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(Update)
humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(Update)
connection = module:OnDataChanged({ "Settings", "Low Mode" }, function()
	if parent.Parent then
		v = nil
		Update()
	else
		Cleanup() -- equivalent call inferred; original call site unknown
	end
end)
script.Destroying:Connect(Cleanup)
Update()