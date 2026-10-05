local parent = script.Parent
local v = os.clock() + 10
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local util = ReplicatedStorage:WaitForChild("Util", (math.max(0, v - os.clock())))

if not (util and util:WaitForChild("AccessoryRigScaleFix", (math.max(0, v - os.clock())))) then
	warn("AccessoryRigScaleFix bootstrap timed out")
elseif parent and script.Parent == parent and parent:IsDescendantOf(workspace) then
	local AccessoryRigScaleFix = require(ReplicatedStorage.Util.AccessoryRigScaleFix)
	AccessoryRigScaleFix(parent)
end