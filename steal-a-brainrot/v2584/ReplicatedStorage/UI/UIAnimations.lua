local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}
local flag = false

local function addTilt(instance)
	local models = {}

	for _, childName in { "BannerViewport", "BannerViewportDropShadow" } do
		local child = instance:FindFirstChild(childName)
		local bannerViewport = child and child:FindFirstChild("BannerViewport")
		local banner = bannerViewport and bannerViewport:FindFirstChild("Banner")

		if banner then
			table.insert(models, {
				model = banner,
				basePivot = banner:GetPivot()
			})
		end
	end

	table.insert(v3, {
		banner = instance,
		viewport = instance:FindFirstChild("BannerViewport"),
		models = models,
		angleX = 0,
		angleY = 0
	})
end

local function register(descendant)
	local anim = descendant:GetAttribute("Anim")

	if anim == "Offset" then
		table.insert(v, {
			object = descendant,
			duration = descendant:GetAttribute("Duration") or 5,
			dual = false
		})
	elseif anim == "DualOffset" then
		table.insert(v, {
			object = descendant,
			duration = descendant:GetAttribute("Duration") or 10,
			dual = true
		})
	elseif anim == "Spin" then
		table.insert(v2, {
			object = descendant,
			speed = descendant:GetAttribute("Speed") or 60
		})
	elseif anim == "CursorTilt" then
		addTilt(descendant)
	elseif anim == "ModelSpin" then
		local animationController = descendant:FindFirstChildOfClass("AnimationController")
		local loop = descendant:FindFirstChild("Loop")
		local animator = animationController and animationController:FindFirstChildOfClass("Animator")

		if animator and loop then
			local success, result = pcall(animator.LoadAnimation, animator, loop)

			if success then
				result.Looped = true
				table.insert(v5, {
					object = descendant,
					track = result
				})

				if not flag then
					result:Play()
				end
			end
		end

		local speed = descendant:GetAttribute("Speed") or 60
		local floatHeight = descendant:GetAttribute("FloatHeight") or 0

		if speed ~= 0 or floatHeight ~= 0 then
			table.insert(v4, {
				object = descendant,
				basePivot = descendant:GetPivot(),
				speed = speed,
				floatHeight = floatHeight,
				floatSpeed = descendant:GetAttribute("FloatSpeed") or 2
			})
		end
	end
end

local function pruneTracks()
	for i = #v5, 1, -1 do
		if not v5[i].object.Parent then
			table.remove(v5, i)
		end
	end
end

local UIAnimations = {}

function UIAnimations.pause()
	flag = true
	pruneTracks()

	for _, v7 in v5 do
		v7.track:Stop()
	end
end

function UIAnimations.resume()
	flag = false
	pruneTracks()

	for _, v7 in v5 do
		v7.track:Play()
	end
end

function UIAnimations.start(folder)
	local v7 = v6[folder]

	if v7 then
		return v7
	end

	for _, descendant in folder:GetDescendants() do
		register(descendant)
	end

	local descendantAddedConnection = folder.DescendantAdded:Connect(register)
	local total = 0
	local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
		if flag then
			return
		end

		total += dt

		for i = #v, 1, -1 do
			local v8 = v[i]

			if v8.object.Parent then
				local v9 = total / v8.duration % 1

				if v8.dual then
					v8.object.Position = UDim2.new(v9, 0, 1 - v9, 0)
				else
					local position = v8.object.Position
					v8.object.Position = UDim2.new(v9, 0, position.Y.Scale, position.Y.Offset)
				end
			else
				table.remove(v, i)
			end
		end

		for i = #v2, 1, -1 do
			local v8 = v2[i]

			if v8.object.Parent then
				v8.object.Rotation = (v8.object.Rotation + v8.speed * dt) % 360
			else
				table.remove(v2, i)
			end
		end

		for i = #v4, 1, -1 do
			local v8 = v4[i]

			if v8.object.Parent then
				local basePivot = v8.basePivot

				if v8.floatHeight > 0 then
					basePivot *= CFrame.new(0, math.sin(total * v8.floatSpeed) * v8.floatHeight, 0)
				end

				v8.object:PivotTo(basePivot * CFrame.Angles(0, math.rad(total * v8.speed % 360), 0))
			else
				table.remove(v4, i)
			end
		end

		local currentCamera = workspace.CurrentCamera

		if #v3 > 0 and currentCamera then
			local mouseLocation = UserInputService:GetMouseLocation()
			local viewportSize = currentCamera.ViewportSize
			local v8 = math.clamp(-((mouseLocation.Y / viewportSize.Y - 0.5) * 2) * 12, -12, 12)
			local v9 = math.clamp((mouseLocation.X / viewportSize.X - 0.5) * 2 * 6, -6, 6)
			local unit = Vector3.new(math.cos(total * 7.5), math.sin(total * 7.5), -1).Unit

			for i = #v3, 1, -1 do
				local v10 = v3[i]

				if v10.banner.Parent then
					v10.angleX += (v8 - v10.angleX) * 0.15
					v10.angleY += (v9 - v10.angleY) * 0.15

					for _, model in v10.models do
						model.model:PivotTo(model.basePivot * CFrame.Angles(
							math.rad(v10.angleX),
							math.rad(v10.angleY),
							0
						))
					end

					local viewport = v10.viewport

					if viewport then
						viewport.LightDirection = unit
					end
				else
					table.remove(v3, i)
				end
			end
		end
	end)

	local function stop()
		v6[folder] = nil
		descendantAddedConnection:Disconnect()
		renderSteppedConnection:Disconnect()
	end

	v6[folder] = stop
	return stop
end

return UIAnimations