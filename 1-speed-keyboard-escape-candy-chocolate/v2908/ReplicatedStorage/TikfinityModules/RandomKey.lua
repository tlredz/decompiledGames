local createVector = vector.create
local RunService = game:GetService("RunService")
local v = 0
local v2 = nil
local v3 = createVector(0, 0, 0)
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function stopEffect()
	RunService:UnbindFromRenderStep("TikfinityRandomKey")
	v2 = nil
	flag = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startEffect()
	if flag then
		return
	end

	flag = true
	RunService:BindToRenderStep("TikfinityRandomKey", Enum.RenderPriority.Input.Value + 2, function()
		local now = os.clock()

		if v <= now then
			stopEffect() -- equivalent call inferred; original call site unknown
		else
			local v4 = v2

			if v4 then
				v4:Move(v3, true)
			end
		end
	end)
end

return {
	Run = function(p)
		local v4 = {
			createVector(1, 0, 0),
			createVector(-1, 0, 0),
			createVector(0, 0, 1),
			createVector(0, 0, -1)
		}
		v2 = p
		v3 = v4[math.random(1, #v4)]
		v = os.clock() + 0.5
		startEffect() -- equivalent call inferred; original call site unknown
	end
}