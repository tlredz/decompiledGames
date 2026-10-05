local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local adminWeatherShake = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("AdminWeatherShake")
local flag = false
local total = 0
local v = nil
local cFrame2 = nil
local cFrame3 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function RestoreOffset()
	if v and v.CFrame == cFrame3 then
		v.CFrame = cFrame2
	end

	v = nil
	cFrame2 = nil
	cFrame3 = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopShake()
	RunService:UnbindFromRenderStep("AdminWeatherShakeRestore")
	RunService:UnbindFromRenderStep("AdminWeatherShakeApply")
	RestoreOffset() -- equivalent call inferred; original call site unknown
	flag = false
end

local onClientEventConnection = adminWeatherShake.OnClientEvent:Connect(function()
	if flag then
		return
	end

	flag = true
	total = 0
	RunService:BindToRenderStep("AdminWeatherShakeRestore", Enum.RenderPriority.Camera.Value - 1, RestoreOffset)
	RunService:BindToRenderStep("AdminWeatherShakeApply", Enum.RenderPriority.Camera.Value + 4, function(p)
		total += p

		if total >= 0.73 then
			StopShake() -- equivalent call inferred; original call site unknown
		else
			local currentCamera = workspace.CurrentCamera

			if not currentCamera then
				return
			end

			local cFrame = currentCamera.CFrame
			local v4 = (1 - total / 0.73) ^ 2
			local v5 = total * 28 * 3.141592653589793 * 2
			local v6 = Vector3.new(math.cos(v5), math.sin(v5 * 1.3) * 0.7, 0) * 0.3 * v4
			v = currentCamera
			cFrame2 = cFrame
			cFrame3 = cFrame + cFrame:VectorToWorldSpace(v6)
			currentCamera.CFrame = cFrame3
		end
	end)
end)
script.Destroying:Connect(function()
	onClientEventConnection:Disconnect()
	StopShake() -- equivalent call inferred; original call site unknown
end)