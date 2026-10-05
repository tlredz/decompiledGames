local RunService = game:GetService("RunService")
local v = 0
local v2 = nil
local controls = nil
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function stopEffect()
	RunService:UnbindFromRenderStep("TikfinityReverseControls")
	v2 = nil
	controls = nil
	flag = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startEffect()
	if flag then
		return
	end

	flag = true
	RunService:BindToRenderStep("TikfinityReverseControls", Enum.RenderPriority.Input.Value + 1, function()
		local now = os.clock()

		if v <= now then
			stopEffect() -- equivalent call inferred; original call site unknown
		else
			local v3 = v2
			local v4 = controls

			if v3 and v4 then
				local moveVector = v4:GetMoveVector()
				v3:Move(Vector3.new(-moveVector.X, moveVector.Y, -moveVector.Z), true)
			end
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
		v = os.clock() + 5
		startEffect() -- equivalent call inferred; original call site unknown
	end
}