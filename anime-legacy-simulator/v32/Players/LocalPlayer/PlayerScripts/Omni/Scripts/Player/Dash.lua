local createVector = vector.create
local module = require("@game/ReplicatedStorage/Omni")
local v = { Enum.KeyCode.Q, Enum.KeyCode.ButtonL2 }
local mobile = module.Interface:WaitForChild("HUD"):WaitForChild("Mobile")
local assets = module.Services.ReplicatedStorage:WaitForChild("Assets")
local movement = assets:WaitForChild("Animations"):WaitForChild("Movement")
local dash = assets:WaitForChild("Sounds"):WaitForChild("Movement"):WaitForChild("Dash")
local dash2 = assets:WaitForChild("Effects"):WaitForChild("Movement"):WaitForChild("Dash")
local v2 = { movement:WaitForChild("Dash1"), movement:WaitForChild("Dash2") }
local v3 = 1
local flag = false
local raycastParams = RaycastParams.new()
raycastParams.RespectCanCollide = true
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Client.Maps }
local Dash = {
	Dash = function()
		if flag or module.Instance:GetAttribute("Frozen") then
			return
		end

		local character = module.Instance.Character

		if not character or character:GetAttribute("SkillDashBlocked") or character:GetAttribute("Mounted") and character:GetAttribute("Mounted") == "Aerial" then
			return
		end

		local humanoid = character:FindFirstChild("Humanoid")

		if not humanoid then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and humanoid.MoveDirection.Magnitude ~= 0) then
			return
		end

		flag = true
		task.delay(0.6, function()
			flag = false
		end)
		local renderSteppedConnection = nil
		local lastTime = tick()
		local moveDirection = humanoid.MoveDirection
		local v4 = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + moveDirection) * CFrame.Angles(
			1.5707963267948966,
			0,
			0
		)
		character:SetAttribute("Dashing", true)

		if not (module.Data.Settings["Low Mode"] or module.Data.Settings["Hide Effects"]) then
			local clone = dash2:Clone()
			clone:PivotTo(v4)
			clone.Parent = workspace.Cache
			module.Utils.Particles:Emit(clone)
			module.Services.Debris:AddItem(clone, 5)
		end

		renderSteppedConnection = module.Services.RunService.RenderStepped:Connect(function()
			if character:GetAttribute("SkillDashBlocked") then
				renderSteppedConnection:Disconnect()
				character:SetAttribute("Dashing", nil)
			else
				local v5 = 1 - 0.5 * ((tick() - lastTime) / 0.5)

				if v5 <= 0 or not (character and humanoid) then
					renderSteppedConnection:Disconnect()
					return
				end

				if humanoid.MoveDirection.Magnitude > 0 then
					moveDirection = humanoid.MoveDirection
				end

				local raycastResult = workspace:Raycast(
					humanoidRootPart.Position,
					humanoidRootPart.CFrame.LookVector * 5,
					raycastParams
				)

				if raycastResult and raycastResult.Instance then
					humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
				else
					humanoidRootPart.AssemblyLinearVelocity = moveDirection * 125 * v5
				end
			end
		end)
		task.delay(0.5, function()
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
			end

			if character then
				character:SetAttribute("Dashing", nil)
			end
		end)
		local animate = module:GetAnimate()
		local animation = v2[v3]

		if animate and animation and not (character:GetAttribute("Mounted") or animate:HasPersistentState()) then
			animate:PlayAnimation({
				Animation = animation,
				Priority = Enum.AnimationPriority.Action4
			})
		end

		v3 = v3 == 1 and 2 or 1
		module.Sound:Play(dash, humanoidRootPart)
	end
}
module.Button:Create(mobile.Dash, "Small"):BindFunction("Click", function()
	Dash.Dash()
end)
module.Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if table.find(v, input.KeyCode) then
		Dash.Dash()
	end
end)
return Dash