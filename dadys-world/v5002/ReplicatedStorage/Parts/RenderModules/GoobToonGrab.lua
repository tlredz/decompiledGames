local createVector = vector.create
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)

local function renderlerp(instance, p, instance2, value, p2, p3, p4, p5, instance3)
	local renderSteppedConnection = nil
	local total = 0
	local v = value or 0.5
	local v2 = false
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if instance and p and instance2 then
			if p5 == true and instance3 then
				if instance3.Parent == nil then
					v2 = true
					renderSteppedConnection:Disconnect()
				else
					local _, v3, _ = CFrame.lookAt(instance3.PrimaryPart.Position, instance2.CFrame.Position):ToOrientation()
					local X = instance2.CFrame.Position.X
					local Y = instance2.CFrame.Position.Y
					local Z = instance2.CFrame.Position.Z
					local cFrame = instance3.PrimaryPart.CFrame
					local v4 = CFrame.new(X, Y, Z) * CFrame.fromOrientation(0, v3, 0)
					total += dt
					local v5 = total / v
					local value2 = TweenService:GetValue(math.min(total / v, 1), p2, p3)
					local lerped = cFrame.Position:Lerp(v4.Position, value2)
					local lerped2 = cFrame.Rotation:Lerp(v4.Rotation, value2)
					instance:PivotTo(CFrame.new(lerped) * lerped2)

					if v5 >= 1 then
						v2 = true
						renderSteppedConnection:Disconnect()
					end
				end
			else
				total += dt
				local v3 = total / v
				local value2 = TweenService:GetValue(math.min(total / v, 1), p2, p3)
				local lerped = p.Position:Lerp(instance2.Position, value2)
				local lerped2 = p.Rotation:Lerp(instance2.Rotation, value2)
				instance:PivotTo(CFrame.new(lerped) * lerped2)

				if v3 >= 1 then
					v2 = true
					renderSteppedConnection:Disconnect()
				end
			end
		else
			v2 = true
			renderSteppedConnection:Disconnect()
		end
	end)

	if p4 then
		while not v2 do
			task.wait()
		end
	end
end

local function renderlerp2(clone, pivot: CFrame, pivot2: CFrame, p: number, p2, _, p3)
	local renderSteppedConnection = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function disconnect()
		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end
	end

	local quad = Enum.EasingStyle.Quad
	local out = Enum.EasingDirection.Out
	local cframe = CFrame.new(pivot2.Position, pivot2.Position + (pivot2.Position - pivot.Position).Unit)
	local lastTime = tick()
	renderSteppedConnection = RunService.RenderStepped:Connect(function(_)
		if clone and pivot and cframe and (not p3 or p3.Parent ~= nil) then
			local v = (tick() - lastTime) / p
			local v2 = v > 1 and 1 or v
			clone:PivotTo((pivot:Lerp(cframe, (TweenService:GetValue(v2, quad, out)))))

			if v2 >= 1 and renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end

			return
		end

		disconnect() -- equivalent call inferred; original call site unknown
	end)

	if p2 then
		while renderSteppedConnection do
			task.wait()
		end
	end
end

return {
	RenderObject = function(list)
		local v, v2, clone, shoulderl, shoulderr, skin
		local controlFlowState = 9

		while true do
			if controlFlowState == 0 then
				break
			end

			if controlFlowState == 1 then
				clone = ReplicatedStorage.Parts.GoobArms.Default:Clone()
				controlFlowState = 5
				continue
			else
				if controlFlowState == 2 then
					break
				end

				if controlFlowState == 3 then
					shoulderl = v.RootPart:FindFirstChild("shoulder.l", true)
					shoulderr = v.RootPart:FindFirstChild("shoulder.r", true)

					if shoulderl and shoulderr then
						controlFlowState = 4
					else
						controlFlowState = 6
					end

					continue
				elseif controlFlowState == 4 then
					local config = v:WaitForChild("Config")
					local currentSkin = v:GetAttribute("CurrentSkin")
					local moduleName = config:WaitForChild("ModuleName")
					clone.Parent = workspace
					clone:PivotTo(v.PrimaryPart:GetPivot())
					clone.PrimaryPart.RopeConstraint.Attachment0 = shoulderl
					clone.PrimaryPart.RopeConstraint2.Attachment0 = shoulderr
					skin = currentSkin ~= "Default" and TowerLUT:GetSkin(moduleName.Value, currentSkin)

					if skin then
						controlFlowState = 8
					else
						controlFlowState = 7
					end

					continue
				elseif controlFlowState == 5 then
					if v.Parent then
						controlFlowState = 3
					else
						controlFlowState = 2
					end

					continue
				else
					if controlFlowState == 6 then
						controlFlowState = 5
						continue
					end

					if controlFlowState == 7 then
						Debris:AddItem(clone, 0.75)
						renderlerp2(clone, v:GetPivot(), v2:GetPivot(), 0.25, true, true, v)
						local renderSteppedConnection = nil

						-- equivalent calls inferred from this helper; original call sites unknown
						local function disconnect()
							if renderSteppedConnection then
								renderSteppedConnection:Disconnect()
								renderSteppedConnection = nil
							end
						end

						local v3 = clone
						local v4 = v
						local v5 = v2
						local v6 = v:FindFirstChild("Grabbing")
						renderSteppedConnection = RunService.RenderStepped:Connect(function()
							if v3 and v3.Parent and v4 and v4.Parent and v5 and v5.Parent then
								local position = v4:GetPivot().Position
								local v7 = CFrame.lookAt(v5:GetPivot().Position, position, createVector(0, 1, 0)) * CFrame.Angles(
									0,
									3.141592653589793,
									0
								)
								v3:PivotTo(v7)

								if (v7.Position - position).Magnitude <= 4.5 or v6 and not v6.Value then
									disconnect() -- equivalent call inferred; original call site unknown

									if v3 then
										v3:Destroy()
									end
								end
							else
								disconnect() -- equivalent call inferred; original call site unknown
							end
						end)
						controlFlowState = 0
						continue
					elseif controlFlowState == 8 then
						local module = require(skin)
						module.UseAbility(v, clone)
						controlFlowState = 7
						continue
					else
						if controlFlowState ~= 9 then
							break
						end

						v = list[1]
						v2 = list[2]

						if v and v.Parent ~= nil then
							controlFlowState = 1
						else
							controlFlowState = 0
						end

						continue
					end
				end
			end
		end
	end
}