local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local v = 0
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function stopEffect()
	RunService:UnbindFromRenderStep("TikfinityScreenFlip")
	flag = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startEffect()
	if flag then
		return
	end

	flag = true
	RunService:BindToRenderStep("TikfinityScreenFlip", Enum.RenderPriority.Camera.Value + 1, function()
		local now = os.clock()

		if v <= now then
			stopEffect() -- equivalent call inferred; original call site unknown
		else
			local currentCamera = Workspace.CurrentCamera

			if currentCamera then
				currentCamera.CFrame *= CFrame.Angles(0, 0, 3.141592653589793)
			end
		end
	end)
end

return {
	Run = function(_)
		v = os.clock() + 5
		startEffect() -- equivalent call inferred; original call site unknown
	end
}