workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local sound = Util.Sound
local _ = Util.MasterClock
local debris = Util.Debris
local resume = coroutine.resume
local create = coroutine.create
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

-- equivalent calls inferred from this helper; original call sites unknown
local function getDir(devil)
	if devil then
		return script.Diable
	end

	return script
end

return function(data)
	local subEffect = data.SubEffect or 1

	if subEffect == 1 then
		local rootPart = data.RootPart
		local lifetime = data.Lifetime
		local timestamp = data.Timestamp
		local devil = data.Devil
		local v = Util.MasterClock:GetTime() - timestamp
		local v2 = math.max(0.1, lifetime - v)

		if rootPart ~= nil then
			if (workspace.CurrentCamera.CFrame.Position - rootPart.Position).Magnitude > 600 then
				return
			end

			local dir = getDir(devil) -- equivalent call inferred; original call site unknown
			local blackLegPartyLoop = Util.Anims:Get(rootPart.Parent, "BlackLegPartyLoop")
			blackLegPartyLoop.Looped = true
			blackLegPartyLoop:Play()
			local clone = dir.ParticlePart.black_leg_spin_thing:Clone()
			debris:AddItem(clone, 10)
			clone.Parent = rootPart
			local v3 = sound:Play("BlackLegSpinner", rootPart, nil, 1, 1)
			debris:AddItem(v3, v2 + 5)
			v3.Looped = true
			resume(create(function()
				local clone2 = dir.Smoke_tang_ting_kaboom:Clone()
				clone2.Position = rootPart.Position
				clone2.Parent = rootPart
				debris:AddItem(clone2, 10)
				local parentChangedConnection = nil
				parentChangedConnection = rootPart:GetPropertyChangedSignal("Parent"):Connect(function()
					clone2:Destroy()
					parentChangedConnection:Disconnect()
					parentChangedConnection = nil
				end)

				while clone2 ~= nil and rootPart ~= nil and clone2:FindFirstChild("Canceld") == nil do
					local position = rootPart.Position
					local ray, position2, _ = Util.Ray(
						position,
						CFrame.new(position).UpVector.Unit * -20,
						{ workspace.Characters, workspace.Enemies },
						false
					)

					if ray == nil then
						clone2.Smoke.Enabled = false
					else
						clone2.Position = position2
						clone2.Smoke.Color = ColorSequence.new(ray.Color)
						clone2.Smoke.Enabled = true
					end

					task.wait()
				end

				wait(4)

				if parentChangedConnection then
					parentChangedConnection:Disconnect()
					parentChangedConnection = nil
				end
			end))
			task.wait((math.max(0.01, v2 - v)))

			if rootPart and rootPart.Parent then
				if blackLegPartyLoop then
					blackLegPartyLoop:Stop()
				end

				local blackLegPartyEnd = Util.Anims:Get(rootPart.Parent, "BlackLegPartyEnd")
				blackLegPartyEnd:Play()
				blackLegPartyEnd:AdjustSpeed(2)

				for _, child in pairs(rootPart:GetChildren()) do
					if child.Name == "black_leg_spin_thing" then
						debris:AddItem(child, 1)

						for _, child2 in pairs(child:GetChildren()) do
							child2.Enabled = false
						end
					elseif child.Name == "Smoke_tang_ting_kaboom" then
						local boolValue = Instance.new("BoolValue")
						boolValue.Name = "Canceld"
						boolValue.Parent = child
						child.Smoke.Enabled = false
						debris:AddItem(child, 1)
					elseif child.Name == "BlackLegSpinner" then
						TweenService:Create(child, tweenInfo, {
							Volume = 0
						}):Play()
						debris:AddItem(child, 1)
					end
				end
			end
		end
	end
end