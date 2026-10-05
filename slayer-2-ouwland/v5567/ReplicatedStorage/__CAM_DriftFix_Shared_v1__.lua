local ReplicatedStorage = game:GetService("ReplicatedStorage")

if script.Parent == ReplicatedStorage and script.Name == "__CAM_DriftFix_Shared_v1__" then
	local RunService = game:GetService("RunService")
	local v = 0
	local cFrame = nil
	local heartbeatConnection = nil
	local flag = false
	local v2 = Enum.RenderPriority.Camera.Value + 1

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getCamera()
		return workspace.CurrentCamera
	end

	return {
		activate = function()
			v += 1

			if v == 1 then
				if not flag then
					flag = true
					RunService:BindToRenderStep("__CAM_DriftFix_Shared_v1__", v2, function()
						local camera = getCamera() -- equivalent call inferred; original call site unknown

						if camera then
							cFrame = camera.CFrame
						end
					end)
				end

				heartbeatConnection = RunService.Heartbeat:Connect(function()
					local camera = getCamera() -- equivalent call inferred; original call site unknown

					if camera and cFrame then
						camera.CFrame = cFrame
					end
				end)
			end
		end,
		deactivate = function()
			v = math.max(0, v - 1)

			if v == 0 then
				if heartbeatConnection then
					heartbeatConnection:Disconnect()
					heartbeatConnection = nil
				end

				if flag then
					RunService:UnbindFromRenderStep("__CAM_DriftFix_Shared_v1__")
					flag = false
				end

				cFrame = nil
			end
		end
	}
else
	local __CAM_DriftFix_Shared_v1__ = ReplicatedStorage:FindFirstChild("__CAM_DriftFix_Shared_v1__")

	if not __CAM_DriftFix_Shared_v1__ then
		__CAM_DriftFix_Shared_v1__ = script:Clone()
		__CAM_DriftFix_Shared_v1__.Name = "__CAM_DriftFix_Shared_v1__"
		__CAM_DriftFix_Shared_v1__.Parent = ReplicatedStorage
	end

	return require(__CAM_DriftFix_Shared_v1__)
end