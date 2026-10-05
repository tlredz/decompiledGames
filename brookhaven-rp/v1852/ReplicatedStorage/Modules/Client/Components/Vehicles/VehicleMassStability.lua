local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleMassStability"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._isEnabled = false
end

function v:Start()
	local instance = self.Instance
	local parent = instance.Parent
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = createVector(0, 0, 0)
	bodyGyro.CFrame = CFrame.new()
	bodyGyro.Parent = instance
	self._Janitor:Add(bodyGyro)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setEnabled(isEnabled: boolean)
		self._isEnabled = isEnabled
		bodyGyro.MaxTorque = isEnabled and createVector(0, 0, 1e999) or createVector(0, 0, 0)
	end

	if instance:GetAttribute("OnlyDuringWheelie") == true == true then
		local wheelie

		if parent ~= nil then
			wheelie = parent:FindFirstChild("Wheelie")
		end

		if wheelie == nil or not wheelie:IsA("BoolValue") then
			setEnabled(false) -- equivalent call inferred; original call site unknown
			warn("VehicleMassStability: OnlyDuringWheelie set but Chassis.Wheelie BoolValue not found")
		else
			local value = wheelie.Value == true
			setEnabled(value) -- equivalent call inferred; original call site unknown
			self._Janitor:Add(wheelie.Changed:Connect(function(flag: boolean)
				setEnabled(flag == true) -- equivalent call inferred; original call site unknown
			end))
		end
	else
		setEnabled(true) -- equivalent call inferred; original call site unknown
	end

	self._Janitor:Add(RunService.Stepped:Connect(function()
		if self._isEnabled ~= true then
			return
		end

		bodyGyro.CFrame = CFrame.lookAt(
			instance.Position,
			instance.Position + instance.CFrame.LookVector,
			createVector(0, 1, 0)
		)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v