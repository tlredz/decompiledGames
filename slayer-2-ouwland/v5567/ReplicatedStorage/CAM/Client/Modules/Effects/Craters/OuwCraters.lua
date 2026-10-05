local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local children = script.Rocks:GetChildren()
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local typeof2 = typeof
local tweenInfo = TweenInfo.new(0.075, Enum.EasingStyle.Linear)
local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Sine)
return {
	Scales = function(options)
		local v = options or {}
		v.Radius = v.Radius or 10
		v.ScaleMult = v.ScaleMult or 1
		v.Duration = v.Duration or 1.5
		v.Count = v.Count or 15
		v.SlopeAngle = v.SlopeAngle or 0.39269908169872414
		v.OffsetMargin = v.OffsetMargin or 4
		local tweenInInfo = v.TweenInInfo or tweenInfo
		local tweenOutInfo = v.TweenOutInfo or tweenInfo2
		local cframe = nil
		local typeName = typeof2(v.Center)

		if typeName == "Vector3" then
			cframe = CFrame.new(v.Center)
		elseif typeName == "CFrame" then
			cframe = v.Center
		elseif typeName == "Instance" then
			if v.Center.ClassName == "Model" and v.Center.PrimaryPart ~= nil then
				cframe = v.Center.PrimaryPart.CFrame
			else
				cframe = v.Center.CFrame
			end
		end

		if cframe == nil then
			warn("No center")
			return
		end

		local v2 = math.rad(360 / v.Count)
		local folder = Instance.new("Folder", workspace.Debree.Craters)
		folder.Name = "OuwCrater-Scales-Fxholder"
		DebrisModule:AddItem(folder, v.Duration + tweenInInfo.Time + tweenOutInfo.Time + 0.01 * v.Count)

		for i = 1, v.Count do
			local v3 = math.random(40, 150) / 100
			local v4 = v2 * (i - 1)
			local v5 = math.cos(v4)
			local v6 = v.Radius - math.random(0, v.OffsetMargin)
			local v7 = v5 * math.clamp(v6, 1, v.Radius)
			local v8 = math.sin(v4)
			local v9 = v.Radius - math.random(0, v.OffsetMargin)
			local v10 = v8 * math.clamp(v9, 1, v.Radius)
			local v11 = cframe * CFrame.new(v7, 0, v10)
			local upVector = v11.UpVector
			local raycastResult = workspace:Raycast(v11.Position + upVector * 2, upVector * -35, RaycastHelper.Crater)

			if not (raycastResult ~= nil and raycastResult.Instance ~= nil) then
				continue
			end

			local position = raycastResult.Position
			local normal = raycastResult.Normal
			local clone = children[math.random(1, #children)]:Clone()
			clone:ScaleTo(v3 * v.ScaleMult)
			local textures = nil

			for _, texture in ipairs(raycastResult.Instance:GetChildren()) do
				if not texture:IsA("Texture") then
					continue
				end

				textures = textures or {}
				table.insert(textures, texture)
			end

			local top = clone.top
			top.Color = raycastResult.Instance.Color
			top.Color = raycastResult.Instance.Color
			top.Material = raycastResult.Instance.Material
			top.MaterialVariant = raycastResult.Instance.MaterialVariant

			if textures ~= nil then
				for _, v12 in ipairs(textures) do
					local clone_2 = v12:Clone()
					clone_2.Parent = top
				end
			end

			clone.Parent = folder
			local Y = clone:GetExtentsSize().Y
			local cframe2 = CFrame.lookAt(v11.Position, cframe.Position)
			local upVector2 = cframe2.UpVector
			local cframe3 = CFrame.fromRotationBetweenVectors(upVector2, normal)
			local v12 = CFrame.new(position) * (cframe3 * cframe2.Rotation) * CFrame.Angles(-v.SlopeAngle, 0, 0)
			local cFrame = v12 - normal * (Y * 0.25)
			local cFrame2 = v12 - normal * (Y * 1.5)
			clone.root.CFrame = cFrame2
			local v15 = i * 0.01
			local _ = v.Duration + tweenInInfo.Time + tweenOutInfo.Time + v15
			local root = clone.root
			task.delay(v15, function()
				TweenService:Create(root, tweenInInfo, {
					CFrame = cFrame
				}):Play()
				task.wait((math.max(v.Duration, tweenInInfo.Time)))
				TweenService:Create(root, tweenOutInfo, {
					CFrame = cFrame2
				}):Play()
				task.wait(tweenOutInfo.Time)
				clone:Destroy()
			end)
		end
	end
}