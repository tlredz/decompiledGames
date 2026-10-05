local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local childrenByName = {}
local v = {}

function TweenKey(p, p2)
	local v2 = childrenByName[p]

	if not v2 then
		return
	end

	if v2:GetAttribute("Origin") == nil then
		v2:SetAttribute("Origin", v2:GetPivot())
	end

	if v[v2] then
		v[v2]:Stop()
		v[v2] = nil
	end

	local origin = v2:GetAttribute("Origin")
	local pivot = v2:GetPivot()
	local v3 = origin * CFrame.Angles(0, 0, 0.05235987755982989)

	if not p2 then
		v3 = origin
	end

	local tweenModule = Client.TweenModule.new(function(p3)
		v2:PivotTo((pivot:Lerp(v3, p3)))
	end, 0.25, "Quad")
	v[v2] = tweenModule
	tweenModule:Play()

	if p2 then
		v2.Note:Play()
	end
end

Client.Events.PressPianoKey:Connect(function(p, instance)
	if p == localPlayer then
		return
	end

	if instance and instance:FindFirstChild("Note") then
		instance.Note:Play()
	end
end)
Client.Events.ReleasePianoKey:Connect(function(_, _) end)

function PianoAdded(instance)
	local v2 = {}
	local v3 = {}

	local function update()
		for k in pairs(v2) do
			if v3[k] then
				continue
			end

			v2[k] = nil
			TweenKey(k, false)
		end

		for k in pairs(v3) do
			if v2[k] then
				continue
			end

			v2[k] = true
			TweenKey(k, true)
			Client.Events.PressPianoKey:FireAllClients(childrenByName[k])
		end
	end

	local v4 = {}

	for _, child in pairs(instance:WaitForChild("Keys"):GetChildren()) do
		if string.sub(child.Name, 1, 5) == "Touch" then
			local v6 = child
			local v7 = string.sub(child.Name, 6)
			child.Touched:Connect(function(otherPart)
				v4[v6] = true
				v3[v7] = true
				update()
				task.spawn(function()
					while true do
						local partsInPart = workspace:GetPartsInPart(v6)
						local flag = false

						for k, v9 in pairs(partsInPart) do
							if v9.Parent ~= localPlayer.Character then
								continue
							end

							flag = true
							break
						end

						if flag then
							task.wait()
						else
							v4[v6] = nil
							local v9 = false

							for k in pairs(v4) do
								if k.Name ~= v6.Name then
									continue
								end

								v9 = true
								break
							end

							if not v9 then
								v3[v7] = nil
							end

							update()
							break
						end
					end
				end)
			end)
		else
			childrenByName[child.Name] = child
		end
	end
end

Client.Utility.ForAllTagged("FloorPiano", PianoAdded)

function TrampolineAdded(instance)
	if instance.Parent ~= workspace.Structures then
		return
	end

	local v2 = time() - 5
	local canvas = instance:WaitForChild("Canvas")
	local touchZone = instance:WaitForChild("TouchZone")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function connectTouch(p)
		p.Touched:Connect(function(otherPart)
			if otherPart and otherPart.Parent == localPlayer.Character and localPlayer.Character and localPlayer.Character.PrimaryPart then
				local v3 = time()

				if v2 + 0.4 < v3 then
					v2 = time()
					local primaryPart = localPlayer.Character.PrimaryPart
					local v4 = primaryPart.AssemblyMass * createVector(0, 1, 0) * 70
					primaryPart.AssemblyLinearVelocity = Vector3.new()
					primaryPart:ApplyImpulse(v4)
				end
			end
		end)
	end

	connectTouch(canvas) -- equivalent call inferred; original call site unknown
	connectTouch(touchZone) -- equivalent call inferred; original call site unknown
end

Client.Utility.ForAllTagged("Trampoline", TrampolineAdded)

function DiceDomeAdded(p)
	if p.Parent ~= workspace.Structures then
		return
	end

	local flag = false
	p.Functional.TouchZone.Touched:Connect(function(otherPart)
		if flag then
			return
		end

		if otherPart.Parent == localPlayer.Character then
			flag = true
			task.delay(1, function()
				flag = false
			end)
			Client.Events.RequestRollDice:FireServer(p)
		end
	end)
end

Client.Utility.ForAllTagged("DiceRoller", DiceDomeAdded)
return {}