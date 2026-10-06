local module = require("@game/ReplicatedStorage/Omni")
local currentCamera = workspace.CurrentCamera
local fieldOfView = currentCamera.FieldOfView
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local flag = false
local v = {}
local FOV = {
	Set = function(fieldOfView2: number)
		module.Services.TweenService:Create(currentCamera, tweenInfo, {
			FieldOfView = fieldOfView2
		}):Play()
	end
}

function FOV.Update()
	if flag then
		return
	end

	local v2 = fieldOfView

	for _, v3 in v do
		v2 += v3
	end

	FOV.Set(v2)
end

function FOV.Add(p: string, p2: number)
	if v[p] then
		return
	end

	v[p] = p2
	FOV.Update()
end

function FOV.Remove(p: string)
	if v[p] then
		v[p] = nil
		FOV.Update()
	end
end

function FOV.Disable()
	if flag then
		return
	end

	flag = true
	FOV.Set(fieldOfView)
end

function FOV.Enable(flag2: boolean)
	local v2

	if flag2 == nil then
		v2 = false
	else
		v2 = not flag2
	end

	if v2 == flag then
		return
	end

	if v2 then
		FOV.Disable()
		return
	end

	flag = false
	FOV.Update()
end

return FOV