local createVector = vector.create
local resume = coroutine.resume
local create = coroutine.create
local TweenService = game:GetService("TweenService")
local Debris = require(game.ReplicatedStorage.Util.Debris)
return function(data)
	local cframe = data.Cframe or CFrame.new()
	local ammount = data.Ammount or 6
	local despawn = data.Despawn or 1
	local size = data.Size or 4
	local distance = data.Distance or 6
	local v = size / 4
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { workspace.Map }
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	local raycastResult = workspace:Raycast(
		(cframe * CFrame.new(0, 3, 0)).Position,
		createVector(0, -20, 0),
		raycastParams
	)

	if raycastResult and raycastResult.Position then
		resume(create(function()
			local children = script.Rocks:GetChildren()

			for i = 1, ammount do
				local v2 = i
				resume(create(function()
					for i2 = 1, 2 do
						local v3 = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
							-1.5707963267948966,
							math.rad(v2 * 60),
							0
						) * CFrame.new(0, 0, math.random(-distance, -distance / 2) * i2)
						local raycastResult2 = workspace:Raycast(
							(v3 * CFrame.new(0, 3, 0)).Position,
							createVector(0, -20, 0),
							raycastParams
						)

						if not (raycastResult2 and raycastResult2.Instance and raycastResult2.Instance.Transparency < 1) then
							continue
						end

						local clone = children[math.random(1, #children)]:Clone()
						Debris:AddItem(clone, 4 + despawn)
						clone.Color = raycastResult2.Instance.Color
						clone.Material = raycastResult2.Material
						clone.CFrame = v3 * CFrame.new(0, -25, 0)
						clone.Size = Vector3.new(
							math.random(size, size + 1),
							math.random(size, size + 1),
							math.random(size, size + 1)
						)
						clone.Parent = workspace._WorldOrigin
						TweenService:Create(
							clone,
							TweenInfo.new(
								math.random() / 10,
								Enum.EasingStyle.Quint,
								Enum.EasingDirection.Out,
								0,
								false,
								0
							),
							{
								CFrame = clone.CFrame * CFrame.new(0, math.random(23, 24), 0) * CFrame.Angles(
									math.rad((math.random(15, 25))),
									math.random(-180, 180),
									(math.rad((math.random(-15, 15))))
								)
							}
						):Play()
						task.delay(despawn, function()
							TweenService:Create(
								clone,
								TweenInfo.new(
									Random.new():NextNumber(0.1, 0.5),
									Enum.EasingStyle.Back,
									Enum.EasingDirection.In
								),
								{
									CFrame = clone.CFrame * CFrame.new(0, -7 * v, 0)
								}
							):Play()
						end)
					end
				end))
			end
		end))
	end
end