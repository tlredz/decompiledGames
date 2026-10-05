local createVector = vector.create
local RunService = game:GetService("RunService")
local v = 0
local v2 = nil
local controls = nil
local v3 = createVector(0, 0, 0)
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function stopEffect()
	RunService:UnbindFromRenderStep("TikfinitySlipperyFloor")
	v2 = nil
	controls = nil
	v3 = createVector(0, 0, 0)
	flag = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startEffect()
	if flag then
		return
	end

	flag = true
	RunService:BindToRenderStep("TikfinitySlipperyFloor", Enum.RenderPriority.Input.Value + 2, function(p: number)
		local now = os.clock()

		if v <= now then
			stopEffect() -- equivalent call inferred; original call site unknown
		else
			local v4 = v2
			local v5 = controls

			if not (v4 and v5) then
				return
			end

			local moveVector = v5:GetMoveVector()
			local v6 = 1 - math.exp(-(moveVector.Magnitude > 0.01 and 6 or 1.8) * p)
			v3 = v3:Lerp(moveVector, v6)

			if v3.Magnitude < 0.01 then
				v3 = createVector(0, 0, 0)
			end

			v4:Move(v3, true)
		end
	end)
end

return {
	Run = function(instance)
		local playerScripts = instance:FindFirstChild("PlayerScripts")
		local playerModule = playerScripts and playerScripts:FindFirstChild("PlayerModule")

		if not (playerModule and playerModule:IsA("ModuleScript")) then
			return
		end

		local success, result = pcall(require, playerModule)

		if not success then
			return
		end

		v2 = instance
		controls = result:GetControls()
		v = os.clock() + 6
		startEffect() -- equivalent call inferred; original call site unknown
	end
}