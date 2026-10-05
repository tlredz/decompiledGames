local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AttributeCounter = require(ReplicatedStorage.Util.AttributeCounter)
local parent = script.Parent
local humanoid = parent:WaitForChild("Humanoid")
local v = nil
local v2 = false
local autoRotate = humanoid.AutoRotate

-- equivalent calls inferred from this helper; original call sites unknown
local function setMovementDisabled(flag: boolean)
	if v2 == flag then
		return
	end

	v2 = flag

	if flag then
		autoRotate = humanoid.AutoRotate
		humanoid.AutoRotate = false
		local folder = Instance.new("Folder")
		folder.Name = "DisableMovement"
		folder.Parent = parent
		v = folder
		ContextActionService:BindAction("AttributeCounterDisableMovement", function()
			return Enum.ContextActionResult.Sink
		end, false, table.unpack(Enum.PlayerActions:GetEnumItems()))
	else
		ContextActionService:UnbindAction("AttributeCounterDisableMovement")

		if v then
			v:Destroy()
			v = nil
		end

		if humanoid.Parent then
			humanoid.AutoRotate = autoRotate
		end
	end
end

local connection = AttributeCounter.connect(parent, "DisableMovement", function(p)
	setMovementDisabled(p > 0)
end, true)
script.Destroying:Once(function()
	connection:Disconnect()
	setMovementDisabled(false) -- equivalent call inferred; original call site unknown
end)