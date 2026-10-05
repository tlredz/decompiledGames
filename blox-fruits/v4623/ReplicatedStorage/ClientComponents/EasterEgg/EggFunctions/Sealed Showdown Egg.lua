local createVector = vector.create
local TimeUtil = require(game.ReplicatedStorage.Modules.Util.TimeUtil)
local Notification = require(game.ReplicatedStorage.Notification)
return function(object, parent)
	local flag = false
	local connection = nil
	local v = assert(parent:FindFirstAncestorWhichIsA("Model"))

	local function update()
		if flag then
			return
		end

		local child = game.ReplicatedStorage:FindFirstChild(object._UID)

		if child then
			connection:Disconnect()
			flag = true
			local zoneSize = child:GetAttribute("ZoneSize")
			local v2 = object.Maid:Add(Instance.new("Part"))
			local specialMesh = Instance.new("SpecialMesh", v2)
			specialMesh.Scale = Vector3.new(zoneSize, zoneSize, zoneSize)
			specialMesh.MeshType = Enum.MeshType.Sphere
			v2.Material = Enum.Material.ForceField
			v2.BrickColor = BrickColor.Red()
			v2.Size = createVector(1, 1, 1)
			v2.CanCollide = false
			v2.CanTouch = false
			v2.CanQuery = false
			v2.Anchored = true
			v2.CFrame = object._CFrame
			v2.Parent = workspace
			local proximityPrompt = Instance.new("ProximityPrompt")
			proximityPrompt:AddTag("ProximityPrompt")
			proximityPrompt.ObjectText = ""
			proximityPrompt.ActionText = ""
			proximityPrompt.MaxActivationDistance = child:GetAttribute("CollectionRadius")
			proximityPrompt.MaxIndicatorDistance = 120
			local triggeredConnection = proximityPrompt.Triggered:Connect(function(_)
				Notification.new("<Color=Red>The Egg is still sealed!<Color=/>"):Display()
			end)
			task.spawn(function()
				local v3 = assert(v:WaitForChild("SealedEgg_Sealed", 1))
				local v4 = assert(v:WaitForChild("SealedEgg_Unsealed", 1))
				local holdDuration = assert(child:GetAttribute("HoldDuration"))
				local v6 = assert(child:GetAttribute("TimeExpires"))
				local v7 = false

				while object.Instance.Parent do
					local v8 = math.max(0, v6 - DateTime.now().UnixTimestamp)
					proximityPrompt.ActionText = not (v8 > 0) and "Hold to Claim" or `{TimeUtil.format(v8, "minimal")}`
					v4.Transparency = v8 > 0 and 1 or 0
					v3.Transparency = v8 > 0 and 0 or 1

					if v8 == 0 then
						triggeredConnection:Disconnect()
						proximityPrompt.Parent = nil
						proximityPrompt.HoldDuration = holdDuration
						proximityPrompt.Triggered:Connect(function()
							child:FireServer("Collect")
						end)
						proximityPrompt.PromptButtonHoldBegan:Connect(function()
							child:FireServer("Start")
						end)
						proximityPrompt.PromptButtonHoldEnded:Connect(function(_)
							proximityPrompt.Parent = nil
							proximityPrompt.Parent = parent
						end)
						proximityPrompt.Parent = parent

						if not v7 then
							break
						end

						object:PlayPoofFX()
						break
					else
						task.wait(1)
						v7 = true
					end
				end
			end)
			proximityPrompt.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
			proximityPrompt.RequiresLineOfSight = false
			proximityPrompt.Parent = parent
		end
	end

	connection = object.Maid:Add(game.ReplicatedStorage.ChildAdded:Connect(update))
	update()
end