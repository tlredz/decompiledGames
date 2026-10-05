local MissedHalloween = {}
MissedHalloween.__index = MissedHalloween
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Circular)
local color = Color3.new(1, 1, 1)
local v = { 1, 10 }
local v2 = { 6, 16 }
local v3 = { 0.08, 0.16 }
local tweenInfo2 = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tweenInfo4 = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo5 = TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local tweenInfo6 = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
local tweenInfo7 = TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local _ = { 3, 8 }
local v4 = { 1.5, 2.5 }
local object = setmetatable({}, {
	__mode = "k"
})
local object2 = setmetatable({}, {
	__mode = "k"
})

function MissedHalloween.Init(_, helpers)
	local self = setmetatable({}, MissedHalloween)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function MissedHalloween:LoadStylesheet()
	local tweens = self.tweens
	local isShown = self.helpers.isShown

	local function findCover(instance)
		local cover = instance:FindFirstChild("Cover", true)

		if not (cover and cover:IsA("GuiObject") and cover) then
			cover = nil
		end

		return cover
	end

	local function findSpiral(instance)
		local spiral = instance:FindFirstChild("Spiral", true)

		if not (spiral and spiral:IsA("GuiObject") and spiral) then
			spiral = nil
		end

		return spiral
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function baseColor(instance)
		return instance:GetAttribute("LightningBaseColor")
	end

	local function stopLoops(instance)
		for _, v5 in ipairs(object[instance] or {}) do
			task.cancel(v5)
		end

		object[instance] = nil

		for _, v5 in ipairs(object2[instance] or {}) do
			v5:Cancel()
		end

		object2[instance] = nil
	end

	local function strike(cover, random)
		local backgroundColor = baseColor(cover) -- equivalent call inferred; original call site unknown

		if random:NextNumber() < 0.4 then
			tweens.playTween(cover, tweenInfo2, {
				BackgroundColor3 = color
			})
			task.wait(tweenInfo2.Time)
			tweens.playTween(cover, tweenInfo3, {
				BackgroundColor3 = color:Lerp(backgroundColor, 0.55)
			})
			task.wait(tweenInfo3.Time + random:NextNumber(v3[1], v3[2]))
		end

		tweens.playTween(cover, tweenInfo2, {
			BackgroundColor3 = color
		})
		task.wait(tweenInfo2.Time)
		tweens.playTween(cover, tweenInfo4, {
			BackgroundColor3 = backgroundColor
		})
	end

	local function tiltTo(instance, object3)
		local tiltBaseRotation = instance:GetAttribute("TiltBaseRotation")
		local number = object3:NextNumber(v4[1], v4[2])
		tweens.playTween(instance, TweenInfo.new(number, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Rotation = tiltBaseRotation + object3:NextNumber(-0, 0)
		})
		task.wait(number)
	end

	function MissedHalloween.base(instance)
		tweens.saveInitials(instance)

		if typeof(instance:GetAttribute("TiltBaseRotation")) ~= "number" then
			instance:SetAttribute("TiltBaseRotation", instance.Rotation)
		end

		local cover = instance:FindFirstChild("Cover", true)

		if not (cover and cover:IsA("GuiObject") and cover) then
			cover = nil
		end

		if not cover then
			warn(("[Shared.EventCalendar.MissedHalloween] no Cover frame in %s; no lightning"):format(instance:GetFullName()))
			return
		end

		if typeof(cover:GetAttribute("LightningBaseColor")) ~= "Color3" then
			cover:SetAttribute("LightningBaseColor", cover.BackgroundColor3)
		end

		cover.BackgroundTransparency = 0.2
		local spiral = cover:FindFirstChild("Spiral", true)

		if not (spiral and spiral:IsA("GuiObject") and spiral) then
			spiral = nil
		end

		if spiral then
			if typeof(spiral:GetAttribute("SpiralBaseRotation")) ~= "number" then
				spiral:SetAttribute("SpiralBaseRotation", spiral.Rotation)
			end

			if typeof(spiral:GetAttribute("SpiralBaseSize")) ~= "UDim2" then
				spiral:SetAttribute("SpiralBaseSize", spiral.Size)
			end
		end
	end

	MissedHalloween.states = {}
	MissedHalloween.flags = {
		missed = function(instance, p2, object3)
			object3:ClearConnections(instance, "missed")
			stopLoops(instance)
			local cover = instance:FindFirstChild("Cover", true)

			if not (cover and cover:IsA("GuiObject") and cover) then
				cover = nil
			end

			if p2 then
				local parent = instance.Parent.Parent
				local retry = instance:FindFirstChild("Retry")
				local uIScale = retry and retry:FindFirstChildOfClass("UIScale")

				if uIScale then
					object3:AddConnection(instance, "missed", parent.TextButton.MouseEnter:Connect(function()
						tweens.playTween(uIScale, tweenInfo, {
							Scale = 1.2
						})
					end))
					object3:AddConnection(instance, "missed", parent.TextButton.MouseLeave:Connect(function()
						tweens.playTween(uIScale, tweenInfo, {
							Scale = 1
						})
					end))
				end

				local random = Random.new()
				local threads = {}
				object[instance] = threads

				if cover then
					cover.BackgroundTransparency = 0.2
					local v5 = { tweens.playTween(cover, tweenInfo5, {
							BackgroundTransparency = 0.075
						}) }
					local spiral = cover:FindFirstChild("Spiral", true)

					if not (spiral and spiral:IsA("GuiObject") and spiral) then
						spiral = nil
					end

					if spiral then
						local spiralBaseRotation = spiral:GetAttribute("SpiralBaseRotation")
						local spiralBaseSize = spiral:GetAttribute("SpiralBaseSize")
						spiral.Rotation = spiralBaseRotation
						spiral.Size = spiralBaseSize
						table.insert(v5, tweens.playTween(spiral, tweenInfo6, {
							Rotation = spiralBaseRotation + 360
						}))
						table.insert(v5, tweens.playTween(spiral, tweenInfo7, {
							Size = UDim2.new(
								spiralBaseSize.X.Scale * 1.15,
								spiralBaseSize.X.Offset * 1.15,
								spiralBaseSize.Y.Scale * 1.15,
								spiralBaseSize.Y.Offset * 1.15
							)
						}))
					end

					object2[instance] = v5
					table.insert(threads, task.spawn(function()
						local v6 = false

						while instance.Parent do
							local v7 = not isShown(instance)

							if v7 ~= v6 then
								v6 = v7

								for _, v8 in ipairs(v5) do
									if v7 then
										v8:Pause()
									else
										v8:Play()
									end
								end
							end

							task.wait(0.5)
						end
					end))
				end

				if cover and cover:GetAttribute("LightningBaseColor") then
					table.insert(threads, task.spawn(function()
						task.wait(random:NextNumber(v[1], v[2]))

						while instance.Parent do
							if isShown(instance) then
								strike(cover, random)
							end

							task.wait(random:NextNumber(v2[1], v2[2]))
						end
					end))
				end
			else
				instance.Rotation = instance:GetAttribute("TiltBaseRotation") or instance.Rotation

				if cover and cover:GetAttribute("LightningBaseColor") then
					cover.BackgroundColor3 = cover:GetAttribute("LightningBaseColor")
					cover.BackgroundTransparency = 0.2
				end

				if cover then
					cover = cover:FindFirstChild("Spiral", true)

					if not (cover and cover:IsA("GuiObject") and cover) then
						cover = nil
					end
				end

				if cover and cover:GetAttribute("SpiralBaseSize") then
					cover.Rotation = cover:GetAttribute("SpiralBaseRotation")
					cover.Size = cover:GetAttribute("SpiralBaseSize")
				end
			end
		end
	}
end

return MissedHalloween