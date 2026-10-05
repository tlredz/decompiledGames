local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Debris = require(game.ReplicatedStorage.Util.Debris)

local function module(data)
	local Global = require(game.ReplicatedStorage.Global)

	if Global.FastMode then
		return
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
	raycastParams.FilterDescendantsInstances = { workspace.Map }
	local folder = Instance.new("Folder", workspace._WorldOrigin)
	Debris:AddItem(folder, 5)

	for i = 1, data.amount do
		local part = Instance.new("Part")
		part.CastShadow = false
		part.Size = createVector(0.5, 0.5, 0.5)
		part.CanCollide = false
		part.Anchored = true
		part.CFrame = data.origin * CFrame.fromOrientation(0, math.rad(360 / data.amount * i), 0) * CFrame.new(
			0,
			0,
			data.offset - data.offset / 2
		)
		part.Parent = folder
		local raycastResult = workspace:Raycast(
			data.origin * CFrame.Angles(0, math.rad(360 / data.amount * i), 0) * CFrame.new(0, 0, data.offset).Position + createVector(
				0,
				10,
				0
			),
			createVector(0, -20, 0),
			raycastParams
		)

		if raycastResult then
			part.Color = raycastResult.Instance.Color
			part.Material = raycastResult.Material
			local tween = TweenService:Create(
				part,
				TweenInfo.new(data.tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Size = Vector3.new(
						math.random(data.size[1] - data.size[1] / 3.5, data.size[1]),
						math.random(data.size[2] - data.size[2] / 3.5, data.size[2]),
						math.random(data.size[3] - data.size[3] / 3.5, data.size[3])
					),
					CFrame = CFrame.new(raycastResult.Position) * CFrame.fromOrientation(
						0,
						math.rad(360 / data.amount * i),
						0
					) * CFrame.Angles(math.rad((math.random(-65, -45))), 0, 0)
				}
			)
			local v2 = part
			coroutine.wrap(function()
				tween.Completed:Wait()
				wait(data.waitTime)
				local tween2 = TweenService:Create(
					v2,
					TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Position = v2.Position - Vector3.new(0, data.size[2] / 2, 0),
						Transparency = 1,
						Size = Vector3.new()
					}
				)
				task.defer(function()
					tween2:Play()
				end)
				tween2.Completed:Wait()
				v2:Destroy()
			end)()
			tween:Play()
		else
			part:Destroy()
		end
	end
end

return module