local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DuelAudioController = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("DuelAudioController"))
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
return function(data)
	local clone = data.template:Clone()
	local trails = {}
	local v = 0

	for _, trail in ipairs(clone:GetDescendants()) do
		if not trail:IsA("Trail") then
			continue
		end

		table.insert(trails, trail)
		v = math.max(v, trail.Lifetime)
		trail.Enabled = false
	end

	clone:PivotTo(data.model:GetPivot())
	DuelAudioController.bindRoot(clone, data.soundGroup)
	clone.Parent = data.parent or Workspace
	local flag = false
	local v2 = false
	local heartbeatConnection = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function finish()
		if flag then
			return
		end

		flag = true

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
		end

		for _, v3 in trails do
			v3.Enabled = false
		end

		Debris:AddItem(clone, v + 0.1)
	end

	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if data.model.Parent then
			clone:PivotTo(data.model:GetPivot())

			if not v2 then
				v2 = true

				for _, v3 in trails do
					v3.Enabled = true
				end
			end
		else
			finish() -- equivalent call inferred; original call site unknown
		end
	end)
	return {
		destroy = finish
	}
end