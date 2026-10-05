local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Craters_Config = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.Craters_Config)
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local map = vfxUtility.RayParams.Map

local function fn(p, range, items)
	local raycastResult = workspace:Raycast(p.Position, -p.UpVector * range, map)

	if not (raycastResult and raycastResult.Instance) then
		return false
	end

	local result = Craters_Config.Get_Part()
	result.Anchored = true
	result.CanCollide = false
	result.Material = raycastResult.Material
	result.CanQuery = false
	result.CanTouch = false
	result.MaterialVariant = raycastResult.Instance.MaterialVariant
	result.Color = raycastResult.Instance.Color
	result.CFrame = CFrame.new(raycastResult.Position)
	result.Reflectance = raycastResult.Instance.Reflectance
	result.Transparency = raycastResult.Instance.Transparency

	if items then
		for k, item in next, items, nil do
			if result[k] ~= nil then
				result[k] = item
			end
		end
	end

	return result, raycastResult
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fn2(p, p2)
	return Random.new():NextNumber(p, p2)
end

function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function getXAndZPositions(p, p2, p3)
	return math.cos(p) * p2 + p3, math.sin(p) * p2 + p3
end

local v = {}
local createConnection

createConnection = function(p, p2)
	if v[p] then
		table.insert(v[p], p2)
		return
	end

	v[p] = {}
	createConnection(p, p2)
end

local function getConnection(p, p2)
	local v2 = v[p]

	if v2 == nil then
		return false
	end

	for _, v3 in ipairs(v2) do
		if v3 == p2 then
			return true
		end
	end

	return false
end

local function fn3(name, p)
	local v2 = v[name]
	local v3

	if v2 == nil then
		v3 = false
	else
		local flag = true

		for _, v4 in ipairs(v2) do
			if v4 ~= p then
				continue
			end

			v3 = true
			flag = false
			break
		end

		if flag then
			v3 = false
		end
	end

	if not v3 then
		return true
	end

	for i, v4 in ipairs(v[name]) do
		if v4 ~= p then
			continue
		end

		table.remove(v[name], i)

		if #v[name] == 0 then
			v[name] = nil
		end

		return false
	end

	return true
end

local Styles = {}

function Styles.Crater(p, data)
	local partCount = data.PartCount or 5
	local radius = data.Radius or 5
	local range = data.Range or 5
	local angle = data.Angle or 45
	local blockSize = data.BlockSize or { 3, 5 }

	for i = 1, partCount do
		local v2 = i * (6.283185307179586 / partCount)
		local xAndZPositions, v3 = getXAndZPositions(v2, radius, 0)
		local v4 = p * Vector3.new(xAndZPositions, 0, v3)
		local v5 = (i + 1) * (6.283185307179586 / partCount)
		local xAndZPositions2, v6 = getXAndZPositions(v5, radius, 0)
		local magnitude = (v4 - p * Vector3.new(xAndZPositions2, 0, v6)).Magnitude
		local v9 = fn2(blockSize[1], blockSize[2]) -- equivalent call inferred; original call site unknown
		local vector2 = Vector3.new(magnitude + 0.5, v9, v9)
		local v10 = fn(CFrame.new(v4), range, {
			Size = vector2
		})

		if not v10 then
			continue
		end

		v10.Name = "CraterPart-" .. i
		local v11 = {
			CFrame = CFrame.lookAt(v10.Position, (Vector3.new(p.X, 0, p.Z))) * CFrame.fromEulerAnglesXYZ(
				math.rad(angle),
				0,
				0
			)
		}
		v10.CFrame = CFrame.lookAt(v10.Position, (Vector3.new(p.X, 0, p.Z)))
		v10.CFrame *= CFrame.new(0, -2.5, 0)
		TweenService:Create(v10, TweenInfo.new(data.AnimationSpeed or 0.25, Enum.EasingStyle.Sine), v11):Play()
		local v12 = v10
		coroutine.wrap(function()
			wait(data.HoldTime)
			local tween = TweenService:Create(v12, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
				Size = createVector(0, 0, 0)
			})
			tween:Play()
			tween.Completed:Wait()
			Craters_Config.Delete_Part(v12)
		end)()
	end
end

function Styles.Orbit(p, data)
	local partCount = data.PartCount or 5
	local radius = data.Radius or 5
	local range = data.Range or 5
	local blockSize = data.BlockSize or { 1, 3 }

	for i = 1, partCount do
		local v2 = i * (6.283185307179586 / partCount)
		local xAndZPositions, v3 = getXAndZPositions(v2, radius, 0)
		local v4 = p * Vector3.new(xAndZPositions, 0, v3)
		local v7 = fn2(blockSize[1], blockSize[2]) -- equivalent call inferred; original call site unknown
		local v8 = fn(CFrame.new(v4), range, {
			Size = Vector3.new(v7, v7, v7)
		})

		if not v8 then
			continue
		end

		v8.Name = "OrbitPart-" .. i
		local v9 = {
			CFrame = v8.CFrame * CFrame.fromEulerAnglesXYZ(
				Random.new():NextNumber(-1000, 1000),
				Random.new():NextNumber(-1000, 1000),
				fn2(-1000, 1000)
			)
		}
		v8.CFrame *= CFrame.new(0, -2.5, 0)
		TweenService:Create(v8, TweenInfo.new(data.AnimationSpeed or 0.25, Enum.EasingStyle.Sine), v9):Play()
		local v10 = v8
		coroutine.wrap(function()
			wait(data.HoldTime)
			local tween = TweenService:Create(v10, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
				Size = createVector(0, 0, 0)
			})
			tween:Play()
			tween.Completed:Wait()
			Craters_Config.Delete_Part(v10)
		end)()
	end
end

function Styles.Path(p, data)
	local width = data.Width or { 4, 4 }
	local blockSize = data.BlockSize or { 2, 2 }
	local distance = data.Distance or 15
	local range = data.Range or 5

	for i = 1, distance, data.stepSize or 1 do
		local lerped = lerp(width[1], width[2], i / distance)
		local lerped2 = lerp(blockSize[1], blockSize[2], i / distance)
		local _ = p * CFrame.new(0, 0, -i)
		local v2 = fn(p * CFrame.new(lerped, 0, -i), range, {
			Size = createVector(0, 0, 0)
		})
		local v3 = fn(p * CFrame.new(-lerped, 0, -i), range, {
			Size = createVector(0, 0, 0)
		})
		local v4 = {
			Size = Vector3.new(lerped2, lerped2, lerped2)
		}

		if v3 then
			v3.Orientation = Vector3.new(
				Random.new():NextNumber(-1000, 1000),
				Random.new():NextNumber(-1000, 1000),
				fn2(-1000, 1000)
			)
			v3.Name = "leftPartPath-" .. i
			TweenService:Create(v3, TweenInfo.new(data.AnimationSpeed or 0.25, Enum.EasingStyle.Sine), v4):Play()
			local v5 = v3
			coroutine.wrap(function()
				wait(data.HoldTime)
				local tween = TweenService:Create(v5, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
					Size = createVector(0, 0, 0)
				})
				tween:Play()
				tween.Completed:Wait()
				Craters_Config.Delete_Part(v5)
			end)()
		end

		if v2 then
			v2.Orientation = Vector3.new(
				Random.new():NextNumber(-1000, 1000),
				Random.new():NextNumber(-1000, 1000),
				fn2(-1000, 1000)
			)
			v2.Name = "rightPartPath-" .. i
			TweenService:Create(v2, TweenInfo.new(data.AnimationSpeed or 0.25, Enum.EasingStyle.Sine), v4):Play()
			local v5 = v2
			coroutine.wrap(function()
				wait(data.HoldTime)
				local tween = TweenService:Create(v5, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
					Size = createVector(0, 0, 0)
				})
				tween:Play()
				tween.Completed:Wait()
				Craters_Config.Delete_Part(v5)
			end)()
		end

		if not data.delayTime then
			continue
		end

		if data.delayTime == "Stepped" then
			RunService.Heartbeat:Wait()
		else
			local delayTime = data.delayTime
			task.wait(delayTime)
		end
	end
end

function Styles.RoundedPath(p, data)
	local width = data.Width or { 4, 4 }
	local blockSize = data.BlockSize or { 2, 2 }
	local distance = data.Distance or 15
	local range = data.Range or 5
	local lerped = nil
	local v2 = nil
	local lerped2 = nil

	for i = 1, distance, data.stepSize or 1 do
		lerped = lerp(width[1], width[2], i / distance)
		lerped2 = lerp(blockSize[1], blockSize[2], i / distance)
		v2 = p * CFrame.new(0, 0, -i)
		local v3 = {
			Size = Vector3.new(lerped2, lerped2, lerped2)
		}
		local v4 = fn(p * CFrame.new(-lerped, 0, -i), range, {
			Size = createVector(0, 0, 0)
		})

		if v4 then
			v4.Orientation = Vector3.new(
				Random.new():NextNumber(-1000, 1000),
				Random.new():NextNumber(-1000, 1000),
				fn2(-1000, 1000)
			)
			v4.Name = "leftPartPath-" .. i
			TweenService:Create(v4, TweenInfo.new(data.AnimationSpeed or 0.25, Enum.EasingStyle.Sine), v3):Play()
			local v5 = v4
			coroutine.wrap(function()
				local holdTime = data.HoldTime
				task.wait(holdTime)
				local tween = TweenService:Create(v5, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
					Size = createVector(0, 0, 0)
				})
				tween:Play()
				tween.Completed:Wait()
				Craters_Config.Delete_Part(v5)
			end)()
		end

		local v5 = fn(p * CFrame.new(lerped, 0, -i), range, {
			Size = createVector(0, 0, 0)
		})

		if v5 then
			v5.Orientation = Vector3.new(
				Random.new():NextNumber(-1000, 1000),
				Random.new():NextNumber(-1000, 1000),
				fn2(-1000, 1000)
			)
			v5.Name = "rightPartPath-" .. i
			TweenService:Create(v5, TweenInfo.new(data.AnimationSpeed or 0.25, Enum.EasingStyle.Sine), v3):Play()
			local v6 = v5
			coroutine.wrap(function()
				local holdTime = data.HoldTime
				task.wait(holdTime)
				local tween = TweenService:Create(v6, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
					Size = createVector(0, 0, 0)
				})
				tween:Play()
				tween.Completed:Wait()
				Craters_Config.Delete_Part(v6)
			end)()
		end

		if not data.delayTime then
			continue
		end

		if data.delayTime == "Stepped" then
			RunService.Heartbeat:Wait()
		else
			local delayTime = data.delayTime
			task.wait(delayTime)
		end
	end

	local partCount = data.PartCount or lerped / 2
	local range2 = data.Range or 5

	for i = 1, partCount do
		local v3 = i * (-3.141592653589793 / partCount)
		local xAndZPositions, v4 = getXAndZPositions(v3, lerped, 0)
		local v5 = v2 * Vector3.new(xAndZPositions, 0, v4)
		local v6 = fn(CFrame.new(v5), range2, {
			Size = Vector3.new(lerped2, lerped2, lerped2)
		})

		if v6 then
			v6.Name = "OrbitPart-" .. i
			local v7 = {
				CFrame = v6.CFrame * CFrame.fromEulerAnglesXYZ(
					Random.new():NextNumber(-1000, 1000),
					Random.new():NextNumber(-1000, 1000),
					fn2(-1000, 1000)
				)
			}
			v6.CFrame *= CFrame.new(0, -2.5, 0)
			TweenService:Create(v6, TweenInfo.new(data.AnimationSpeed or 0.25, Enum.EasingStyle.Sine), v7):Play()
			local v8 = v6
			coroutine.wrap(function()
				local holdTime = data.HoldTime
				task.wait(holdTime)
				local tween = TweenService:Create(v8, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
					Size = createVector(0, 0, 0)
				})
				tween:Play()
				tween.Completed:Wait()
				Craters_Config.Delete_Part(v8)
			end)()
		end

		if not data.delayTime then
			continue
		end

		if data.delayTime == "Stepped" then
			RunService.Heartbeat:Wait()
		else
			local delayTime = data.delayTime
			task.wait(delayTime)
		end
	end
end

function Styles.ClosedPath(p, data)
	local width = data.Width or { 4, 4 }
	local blockSize = data.BlockSize or { 2, 2 }
	local distance = data.Distance or 15
	local _ = data.Range or 5
	local partCount = data.PartCount or width[1] / 2
	local v2 = width[1]
	local range = data.Range or 5

	for i = 1, partCount do
		local v3 = i * (3.141592653589793 / partCount)
		local xAndZPositions, v4 = getXAndZPositions(v3, v2, 0)
		local v5 = p * Vector3.new(xAndZPositions, 0, v4)
		local v6 = fn(CFrame.new(v5), range, {
			Size = Vector3.new(blockSize[1], blockSize[1], blockSize[1])
		})

		if not v6 then
			continue
		end

		v6.Name = "OrbitPart-" .. i
		local v7 = {
			CFrame = v6.CFrame * CFrame.fromEulerAnglesXYZ(
				Random.new():NextNumber(-1000, 1000),
				Random.new():NextNumber(-1000, 1000),
				fn2(-1000, 1000)
			)
		}
		v6.CFrame *= CFrame.new(0, -2.5, 0)
		TweenService:Create(v6, TweenInfo.new(data.AnimationSpeed or 0.25, Enum.EasingStyle.Sine), v7):Play()
		local v8 = v6
		coroutine.wrap(function()
			local holdTime = data.HoldTime
			task.wait(holdTime)
			local tween = TweenService:Create(v8, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
				Size = createVector(0, 0, 0)
			})
			tween:Play()
			tween.Completed:Wait()
			Craters_Config.Delete_Part(v8)
		end)()
	end

	for i = 1, distance, data.stepSize or 1 do
		local lerped = lerp(width[1], width[2], i / distance)
		local lerped2 = lerp(blockSize[1], blockSize[2], i / distance)
		local v3 = {
			Size = Vector3.new(lerped2, lerped2, lerped2)
		}
		local v4 = fn(p * CFrame.new(-lerped, 0, -i), range, {
			Size = createVector(0, 0, 0)
		})

		if v4 then
			v4.Orientation = Vector3.new(
				Random.new():NextNumber(-1000, 1000),
				Random.new():NextNumber(-1000, 1000),
				fn2(-1000, 1000)
			)
			v4.Name = "leftPartPath-" .. i
			TweenService:Create(v4, TweenInfo.new(data.AnimationSpeed or 0.25, Enum.EasingStyle.Sine), v3):Play()
			local v5 = v4
			coroutine.wrap(function()
				local holdTime = data.HoldTime
				task.wait(holdTime)
				local tween = TweenService:Create(v5, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
					Size = createVector(0, 0, 0)
				})
				tween:Play()
				tween.Completed:Wait()
				Craters_Config.Delete_Part(v5)
			end)()
		end

		local v5 = fn(p * CFrame.new(lerped, 0, -i), range, {
			Size = createVector(0, 0, 0)
		})

		if v5 then
			v5.Orientation = Vector3.new(
				Random.new():NextNumber(-1000, 1000),
				Random.new():NextNumber(-1000, 1000),
				fn2(-1000, 1000)
			)
			v5.Name = "rightPartPath-" .. i
			TweenService:Create(v5, TweenInfo.new(data.AnimationSpeed or 0.25, Enum.EasingStyle.Sine), v3):Play()
			local v6 = v5
			coroutine.wrap(function()
				local holdTime = data.HoldTime
				task.wait(holdTime)
				local tween = TweenService:Create(v6, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
					Size = createVector(0, 0, 0)
				})
				tween:Play()
				tween.Completed:Wait()
				Craters_Config.Delete_Part(v6)
			end)()
		end

		if not data.delayTime then
			continue
		end

		if data.delayTime == "Stepped" then
			RunService.Heartbeat:Wait()
		else
			local delayTime = data.delayTime
			task.wait(delayTime)
		end
	end
end

function Styles.WallBreak(cFrame, data)
	local partCount = data.PartCount or 5
	local height = data.Height or { 3, 4 }
	local width = data.Width or { -2, 2 }
	local range = data.Range or 10
	local blockSize = data.BlockSize or { 3, 6 }

	for _ = 1, partCount do
		local v2 = fn(cFrame, range, {
			Size = createVector(0, 0, 0)
		})

		if v2 then
			v2.Anchored = false
			v2.CanCollide = data.Collidable or true
			v2.CFrame = cFrame
			local tweenInfo = TweenInfo.new(data.AnimationSpeed or 0.25, Enum.EasingStyle.Sine)
			local v7 = fn2(blockSize[1], blockSize[2]) -- equivalent call inferred; original call site unknown
			local v8 = blockSize[1]
			local v9 = blockSize[2]
			TweenService:Create(v2, tweenInfo, {
				Size = Vector3.new(v7, Random.new():NextNumber(v8, v9), fn2(blockSize[1], blockSize[2]))
			}):Play()
			local bodyVelocity = Instance.new("BodyVelocity", v2)
			bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
			bodyVelocity.P = 100000
			local v12 = fn2(width[1], width[2]) -- equivalent call inferred; original call site unknown
			local v13 = height[1]
			local v14 = height[2]
			bodyVelocity.Velocity = Vector3.new(v12, Random.new():NextNumber(v13, v14), fn2(width[1], width[2]))
			local bodyAngularVelocity = Instance.new("BodyAngularVelocity", v2)
			bodyAngularVelocity.AngularVelocity = Vector3.new(
				Random.new():NextNumber(-40, 40),
				Random.new():NextNumber(-40, 40),
				fn2(-40, 40)
			)
			bodyAngularVelocity.MaxTorque = createVector(1e999, 1e999, 1e999)
			bodyAngularVelocity.P = 100000
			local Debris = game:GetService("Debris")
			Debris:AddItem(bodyVelocity, 0.25)
			local Debris2 = game:GetService("Debris")
			Debris2:AddItem(bodyAngularVelocity, 0.1)
			local v15 = v2
			coroutine.wrap(function()
				local holdTime = data.HoldTime or 2
				task.wait(holdTime)
				local tween = TweenService:Create(v15, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
					Size = createVector(0, 0, 0)
				})
				tween:Play()
				tween.Completed:Wait()
				Craters_Config.Delete_Part(v15)
			end)()
		end

		if not data.delayTime then
			continue
		end

		if data.delayTime == "Stepped" then
			RunService.Heartbeat:Wait()
		else
			local delayTime = data.delayTime
			task.wait(delayTime)
		end
	end
end

function Styles.ExpandingCrater(p, data)
	local partCount = data.PartCount or 5
	local radius = data.Radius or { 5, 25 }
	local blockSize = data.BlockSize or { 2, 10 }
	local range = data.Range or 5
	local increaseSpeed = data.IncreaseSpeed or 1
	local angle = data.Angle or 45

	for i = 1, partCount do
		local v2 = i * (6.283185307179586 / partCount)
		local xAndZPositions, v3 = getXAndZPositions(v2, radius[1], 0)
		local v4 = p * Vector3.new(xAndZPositions, 0, v3)
		local v5 = (i + 1) * (6.283185307179586 / partCount)
		local xAndZPositions2, v6 = getXAndZPositions(v5, radius[1], 0)
		local vector2 = Vector3.new(
			(v4 - p * Vector3.new(xAndZPositions2, 0, v6)).Magnitude + 0.5,
			blockSize[1],
			blockSize[1]
		)
		local v7 = fn(CFrame.new(v4), range, {
			Size = vector2
		})

		if not v7 then
			continue
		end

		v7.Name = "CraterPart-" .. i
		local v8 = {
			CFrame = CFrame.lookAt(v7.Position, (Vector3.new(p.X, 0, p.Z))) * CFrame.fromEulerAnglesXYZ(
				math.rad(angle),
				0,
				0
			)
		}
		v7.CFrame = CFrame.lookAt(v7.Position, (Vector3.new(p.X, 0, p.Z)))
		v7.CFrame *= CFrame.new(0, -2.5, 0)
		TweenService:Create(v7, TweenInfo.new(data.AnimationSpeed or 0.25, Enum.EasingStyle.Sine), v8):Play()
		local v9 = i
		local v10 = v7
		coroutine.wrap(function()
			local animationSpeed = data.AnimationSpeed or 0.25
			task.wait(animationSpeed)

			for i2 = radius[1], radius[2], increaseSpeed do
				local lerped = lerp(radius[1], radius[2], i2 / radius[2])
				local lerped2 = lerp(blockSize[1], blockSize[2], i2 / radius[2])
				local v11 = v9 * (6.283185307179586 / partCount)
				local xAndZPositions3, v12 = getXAndZPositions(v11, lerped, 0)
				local v13 = p * Vector3.new(xAndZPositions3, 0, v12)
				local raycastResult = workspace:Raycast(
					CFrame.new(v13).Position,
					-CFrame.new(v13).UpVector * range,
					map
				)

				if raycastResult and raycastResult.Instance then
					local v14 = v9 * (6.283185307179586 / partCount)
					local xAndZPositions4, v15 = getXAndZPositions(v14, lerped, 0)
					local v16 = p * Vector3.new(xAndZPositions4, 0, v15)
					local v17 = (v9 + 1) * (6.283185307179586 / partCount)
					local xAndZPositions5, v18 = getXAndZPositions(v17, lerped, 0)
					local vector3 = Vector3.new(
						(v16 - p * Vector3.new(xAndZPositions5, 0, v18)).Magnitude + 0.5,
						lerped2,
						lerped2
					)
					v10.Position = raycastResult.Position
					v10.Material = raycastResult.Material
					v10.MaterialVariant = raycastResult.Instance.MaterialVariant
					v10.Color = raycastResult.Instance.Color
					v10.CFrame = CFrame.new(raycastResult.Position)
					v10.Reflectance = raycastResult.Instance.Reflectance
					v10.Transparency = raycastResult.Instance.Transparency
					v10.Size = vector3
					v10.CFrame = CFrame.lookAt(v10.Position, (Vector3.new(p.X, 0, p.Z))) * CFrame.fromEulerAnglesXYZ(
						math.rad(angle),
						0,
						0
					)
				end

				RunService.Heartbeat:Wait()
			end

			local holdTime = data.HoldTime
			task.wait(holdTime)
			local tween = TweenService:Create(v10, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
				Size = createVector(0, 0, 0)
			})
			tween:Play()
			tween.Completed:Wait()
			Craters_Config.Delete_Part(v10)
		end)()
	end
end

function Styles.ExpandingOrbit(p, data)
	local partCount = data.PartCount or 5
	local radius = data.Radius or { 5, 25 }
	local blockSize = data.BlockSize or { 2, 10 }
	local range = data.Range or 5
	local increaseSpeed = data.IncreaseSpeed or 0.8

	for i = 1, partCount do
		local v2 = i * (6.283185307179586 / partCount)
		local xAndZPositions, v3 = getXAndZPositions(v2, radius[1], 0)
		local v4 = p * Vector3.new(xAndZPositions, 0, v3)
		local v5 = fn(CFrame.new(v4), range, {
			Size = Vector3.new(blockSize[1], blockSize[1], blockSize[1])
		})

		if not v5 then
			continue
		end

		v5.Name = "OrbitPart-" .. i
		local cframe = CFrame.fromEulerAnglesXYZ(
			Random.new():NextNumber(-1000, 1000),
			Random.new():NextNumber(-1000, 1000),
			fn2(-1000, 1000)
		)
		local v6 = {
			CFrame = v5.CFrame * cframe
		}
		v5.CFrame *= CFrame.new(0, -2.5, 0)
		local tween = TweenService:Create(v5, TweenInfo.new(data.AnimationSpeed or 0.25, Enum.EasingStyle.Sine), v6)
		tween:Play()
		local v8 = i
		local v9 = v5
		coroutine.wrap(function()
			tween.Completed:Wait()

			for i2 = radius[1], radius[2], increaseSpeed do
				local lerped = lerp(radius[1], radius[2], i2 / radius[2])
				local lerped2 = lerp(blockSize[1], blockSize[2], i2 / radius[2])
				local v11 = v8 * (6.283185307179586 / partCount)
				local xAndZPositions2, v12 = getXAndZPositions(v11, lerped, 0)
				local v13 = p * Vector3.new(xAndZPositions2, 0, v12)
				local raycastResult = workspace:Raycast(
					CFrame.new(v13).Position,
					-CFrame.new(v13).UpVector * range,
					map
				)

				if raycastResult and raycastResult.Instance then
					v9.Position = raycastResult.Position
					v9.Material = raycastResult.Material
					v9.MaterialVariant = raycastResult.Instance.MaterialVariant
					v9.Color = raycastResult.Instance.Color
					v9.CFrame = CFrame.new(raycastResult.Position)
					v9.Reflectance = raycastResult.Instance.Reflectance
					v9.Transparency = raycastResult.Instance.Transparency
					v9.Size = Vector3.new(lerped2, lerped2, lerped2)
					v9.CFrame *= cframe
				end

				RunService.Heartbeat:Wait()
			end

			wait(data.HoldTime)
			local tween2 = TweenService:Create(v9, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
				Size = createVector(0, 0, 0)
			})
			tween2:Play()
			tween2.Completed:Wait()
			Craters_Config.Delete_Part(v9)
		end)()
	end
end

function Styles.RisingRocks(instance, data)
	local blockSize = data.BlockSize or { 3, 5 }
	local radius = data.Radius or 5
	local iterations = data.Iterations or 15
	local height = data.Height or { 8, 10 }
	local animationSpeed = data.AnimationSpeed or 0.8
	local holdTime = data.HoldTime or 1

	if type(iterations) == "number" then
		for i = 1, iterations do
			local v2 = radius * math.sqrt((Random.new():NextNumber(0, 1)))
			local v3 = Random.new():NextNumber(0, 1) * 2 * 3.141592653589793
			local v4 = instance.X + v2 * math.cos(v3)
			local v5 = instance.Z + v2 * math.sin(v3)
			local v8 = fn2(blockSize[1], blockSize[2]) -- equivalent call inferred; original call site unknown
			local v9 = fn(CFrame.new(v4, instance.Y, v5), data.Range or 8, {
				Size = Vector3.new(v8, v8, v8)
			})

			if not v9 then
				continue
			end

			v9.Name = "RisingPart - " .. i
			v9.CFrame *= CFrame.fromEulerAnglesXYZ(
				Random.new():NextNumber(-1000, 1000),
				Random.new():NextNumber(-1000, 1000),
				fn2(-1000, 1000)
			)
			local tweenInfo = TweenInfo.new(animationSpeed, Enum.EasingStyle.Sine)
			local position = v9.Position
			local v12 = height[1]
			local v13 = height[2]
			TweenService:Create(v9, tweenInfo, {
				Position = position + Vector3.new(0, Random.new():NextNumber(v12, v13), 0)
			}):Play()
			local tween = TweenService:Create(v9, TweenInfo.new(holdTime, Enum.EasingStyle.Sine), {
				Size = createVector(0, 0, 0)
			})
			tween:Play()
			local v14 = v9
			tween.Completed:Once(function()
				Craters_Config.Delete_Part(v14)
			end)

			if not data.delayTime then
				continue
			end

			if data.delayTime == "Stepped" then
				RunService.Heartbeat:Wait()
			else
				local delayTime = data.delayTime
				task.wait(delayTime)
			end
		end
	elseif iterations == "Held" then
		local iterationName = data.IterationName or "Iterations"
		local name = instance.Name

		if v[name] then
			table.insert(v[name], iterationName)
		else
			v[name] = {}
			createConnection(name, iterationName)
		end

		local thread = nil
		task.spawn(function()
			while true do
				local v2 = iterationName
				local v3 = v[instance.Name]
				local flag

				if v3 == nil then
					flag = false
				else
					local flag2 = true

					for _, v4 in ipairs(v3) do
						if v4 ~= v2 then
							continue
						end

						flag = true
						flag2 = false
						break
					end

					if flag2 then
						flag = false
					end
				end

				if flag then
					local pivot = instance:GetPivot()
					local v4 = radius * math.sqrt((Random.new():NextNumber(0, 1)))
					local v5 = Random.new():NextNumber(0, 1) * 2 * 3.141592653589793
					local v6 = pivot.X + v4 * math.cos(v5)
					local v7 = pivot.Z + v4 * math.sin(v5)
					local v10 = fn2(blockSize[1], blockSize[2]) -- equivalent call inferred; original call site unknown
					local v11 = fn(CFrame.new(v6, pivot.Y, v7), data.Range or 8, {
						Size = Vector3.new(v10, v10, v10)
					})

					if v11 then
						v11.Name = "RisingPart"
						v11.CFrame *= CFrame.fromEulerAnglesXYZ(
							Random.new():NextNumber(-1000, 1000),
							Random.new():NextNumber(-1000, 1000),
							fn2(-1000, 1000)
						)
						local tweenInfo = TweenInfo.new(animationSpeed, Enum.EasingStyle.Sine)
						local position = v11.Position
						local v14 = height[1]
						local v15 = height[2]
						TweenService:Create(v11, tweenInfo, {
							Position = position + Vector3.new(0, Random.new():NextNumber(v14, v15), 0)
						}):Play()
						local tween = TweenService:Create(v11, TweenInfo.new(holdTime, Enum.EasingStyle.Sine), {
							Size = createVector(0, 0, 0)
						})
						tween:Play()
						local v16 = v11
						tween.Completed:Once(function()
							Craters_Config.Delete_Part(v16)
						end)

						if data.delayTime then
							if data.delayTime == "Stepped" then
								RunService.PostSimulation:Wait()
							else
								task.wait(data.delayTime)
							end
						else
							RunService.PostSimulation:Wait()
						end

						continue
					end
				end

				if thread ~= nil then
					task.cancel(thread)
					thread = nil
				end

				break
			end
		end)
		local timeOut = data.TimeOut or 5

		if timeOut ~= nil then
			thread = task.delay(timeOut, function()
				thread = nil
				fn3(name, iterationName)
			end)
		end
	end
end

function Styles.Line(p, data)
	local blockSize = data.BlockSize or { 0.5, 3 }
	local distance = data.Distance or 25

	for i = 1, distance, data.stepSize or 1 do
		local lerped = lerp(blockSize[1], blockSize[2], i / distance)
		local v2 = fn(p * CFrame.new(0, 0, -i), data.Range or 8, {
			Size = createVector(0, 0, 0)
		})

		if v2 then
			v2.Name = "Line-" .. i
			v2.CFrame *= CFrame.fromEulerAnglesXYZ(
				Random.new():NextNumber(-1000, 1000),
				Random.new():NextNumber(-1000, 1000),
				fn2(-1000, 1000)
			)
			TweenService:Create(v2, TweenInfo.new(data.AnimationSpeed or 0.25, Enum.EasingStyle.Sine), {
				Size = Vector3.new(lerped, lerped, lerped)
			}):Play()
			local v3 = v2
			coroutine.wrap(function()
				wait(data.HoldTime)
				local tween = TweenService:Create(v3, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
					Size = createVector(0, 0, 0)
				})
				tween:Play()
				tween.Completed:Wait()
				Craters_Config.Delete_Part(v3)
			end)()
		end

		if not data.delayTime then
			continue
		end

		if data.delayTime == "Stepped" then
			RunService.Heartbeat:Wait()
		else
			local delayTime = data.delayTime
			task.wait(delayTime)
		end
	end
end

function Styles.endConnection(p, p2)
	if p2 == nil then
		return
	else
		return (fn3(p.Name, p2))
	end
end

return Styles