local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local tweenInfo = TweenInfo.new(1.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
local CameraDisorientatingEffect = {
	Priority = Enum.RenderPriority.Camera.Value,
	Defaults = {
		Side_Squish = {
			Low = 0.85,
			High = 1,
			Time = 1.025,
			Easing_Style = Enum.EasingStyle.Quad,
			Enabled = true
		},
		Up_Squish = {
			Low = 0.85,
			High = 1,
			Time = 1.5374999999999999,
			Easing_Style = Enum.EasingStyle.Quad,
			Enabled = true
		},
		Side_Tilt = {
			Low = -7,
			High = 7,
			Time = 1.7937499999999997,
			Easing_Style = Enum.EasingStyle.Sine,
			Enabled = true
		}
	},
	Traffic = {}
}
local TweenService = game:GetService("TweenService")
local clock = os.clock
local RunService = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
local random = math.random
local tostring2 = tostring
local _ = TweenInfo.new

function terminated(p)
	return p == nil or CameraDisorientatingEffect.Traffic[p] == nil
end

function CameraDisorientatingEffect:Terminate(p2)
	if p2 == nil then
		return
	end

	if self.Traffic[p2] then
		self.Traffic[p2] = nil
	end
end

function CameraDisorientatingEffect.New(data, p, p2)
	local v = tostring2(random(1, 999)) .. tostring2(random(1, 999))
	local v2 = p2 == nil and {} or p2
	local v3 = p == nil and 1 or p

	if v2.Side_Squish == nil then
		v2.Side_Squish = data.Defaults.Side_Squish
	end

	if v2.Up_Squish == nil then
		v2.Up_Squish = data.Defaults.Up_Squish
	end

	if v2.Side_Tilt == nil then
		v2.Side_Tilt = data.Defaults.Side_Tilt
	end

	data.Traffic[v] = true
	local v4 = "render_for" .. v
	local now = clock()
	local v5 = {}
	local flag = true
	local v6 = {}

	for k, v7 in pairs(v2) do
		if v7.Enabled ~= true then
			continue
		end

		local numberValue = Instance.new("NumberValue", script)
		v5[k] = numberValue
		numberValue.Value = k == "Side_Tilt" and 0 or 1
		DebrisModule:AddItem(numberValue, v3 + 1.25)
	end

	local v7 = false

	for k, v8 in pairs(v5) do
		local v9 = v8
		local v10 = k
		task.spawn(function()
			local now2 = clock()
			local v11 = v3 + 1.25

			while flag and v9 and v9.Parent == script and clock() - now2 <= v11 do
				local time = v2[v10].Time or data.Defaults[v10].Time
				local easing_Style = v2[v10].Easing_Style or data.Defaults[v10].Easing_Style
				local low = v2[v10].Low or data.Defaults[v10].Low
				local high = v2[v10].High or data.Defaults[v10].High
				v6[v10 .. 1] = TweenService:Create(
					v9,
					TweenInfo.new(time, easing_Style, Enum.EasingDirection.InOut, 0, false, 0),
					{
						Value = low
					}
				)
				v6[v10 .. 1]:Play()
				task.wait(time)

				if v9 and v9.Parent == script and v7 == false and flag then
					v6[v10 .. 2] = TweenService:Create(
						v9,
						TweenInfo.new(time, easing_Style, Enum.EasingDirection.InOut, 0, false, 0),
						{
							Value = high
						}
					)
					v6[v10 .. 2]:Play()
				end

				task.wait(time)
			end
		end)
	end

	local function Delete()
		if flag then
			flag = false

			if v6 then
				for _, v8 in pairs(v6) do
					v8:Cancel()
				end

				v6 = nil
			end

			if v5 then
				for k, v8 in pairs(v5) do
					TweenService:Create(v8, tweenInfo, {
						Value = k == "Side_Tilt" and 0 or 1
					}):Play()
				end
			end

			v7 = true
			task.wait(1.25)
			v7 = false
			RunService:UnbindFromRenderStep(v4)

			if CameraDisorientatingEffect and v then
				CameraDisorientatingEffect:Terminate(v)
			end

			if v5 then
				for _, v8 in pairs(v5) do
					v8:Destroy()
				end

				v5 = nil
			end
		end
	end

	RunService:BindToRenderStep(v4, data.Priority, function()
		local v8 = terminated(v) == false
		local value = v5 and v5.Side_Squish and v5.Side_Squish.Value or 1
		local value2 = v5 and v5.Up_Squish and v5.Up_Squish.Value or 1
		local value3 = v5 and v5.Side_Tilt and v5.Side_Tilt.Value or 1
		local cframe = CFrame.new(0, 0, 0, value, 0, 0, 0, value2, 0, 0, 0, 1)
		currentCamera.CFrame = currentCamera.CFrame * CFrame.Angles(0, 0, (math.rad(value3))) * cframe

		if not (v8 and clock() - now <= v3) and v7 ~= true then
			Delete()
		end
	end)
	return v
end

function CameraDisorientatingEffect.Terminate_All(_)
	for k, _ in pairs(CameraDisorientatingEffect.Traffic) do
		CameraDisorientatingEffect:Terminate(k)
	end
end

return CameraDisorientatingEffect