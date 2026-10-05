local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Misc = require(ReplicatedStorage.Util.Misc)
local scaleParticle = Misc.ScaleParticle
local _ = Util.Sound
local debris = Util.Debris
local terrain = Workspace:FindFirstChildOfClass("Terrain")
local blueMoonWisp = script:WaitForChild("BlueMoonWisp")
local playerBlueMoonWisp = script:WaitForChild("PlayerBlueMoonWisp")
local color = Color3.fromRGB(62, 107, 255)
local v = {}
local v2 = {}
local v3 = false
local v4 = {}

for _, emitter in script.PlayerBlueMoonWisp.Attachment:GetChildren() do
	if emitter:IsA("ParticleEmitter") then
		scaleParticle(emitter, 0.8)
	end
end

local children = blueMoonWisp.Attachment:GetChildren()

for _, emitter in ipairs(children) do
	if emitter:IsA("ParticleEmitter") then
		v[emitter.Name] = { 1 / emitter.Rate, os.clock() }
	end
end

local children2 = playerBlueMoonWisp.Attachment:GetChildren()

for _, emitter in ipairs(children2) do
	if emitter:IsA("ParticleEmitter") then
		v2[emitter.Name] = { 1 / emitter.Rate, os.clock() }
	end
end

local function spawnEffect(position: Vector3, color2: Color3?)
	Util.Sound:Play("KitsuneZSpawnEmber", position, nil, 1 + math.random(-12, 12) / 100, 0.8)
	local clone = script.WispSpawn:Clone()
	debris:AddItem(clone, 2)
	local descendants = clone:GetDescendants()
	clone.CFrame = CFrame.new(position)
	clone.Parent = _WorldOrigin

	if color2 then
		Util.ColorShiftObjectDescendantsTable(clone, {
			Default_Color1 = color,
			Shifted_Color1 = color2
		})
	end

	for _, emitter in ipairs(descendants) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end
end

local function despawnEffect(position: Vector3, color2: Color3)
	Util.Sound:Play("KitsuneZTransformedBullet", position, nil, 1.15 + math.random(-5, 12) / 100, 0.8)
	local clone = script.WispDespawn:Clone()
	debris:AddItem(clone, 2)
	local descendants = clone:GetDescendants()
	clone.CFrame = CFrame.new(position)
	clone.Parent = _WorldOrigin

	if color2 then
		Util.ColorShiftObjectDescendantsTable(clone, {
			Default_Color1 = color,
			Shifted_Color1 = color2
		})
	end

	for _, emitter in ipairs(descendants) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function checkVisible(position: Vector3)
	local worldToViewportPoint, v5 = workspace.CurrentCamera:WorldToViewportPoint(position)

	if v5 and worldToViewportPoint.Z <= 800 then
		return true
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function checkLoop()
	if v3 == false then
		v3 = true
		task.spawn(function()
			os.clock()

			while next(v4) do
				for k, v5 in pairs(v4) do
					if k == nil or k.Parent == nil then
						if v5 then
							v5:Destroy()
						end

						v4[k] = nil
					elseif checkVisible(k.Position) then
						v5.CFrame = CFrame.new(k.Position)
						local children3 = v5:GetChildren()
						local playerWisp = v5:GetAttribute("PlayerWisp")

						for _, emitter in ipairs(children3) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v6 = playerWisp ~= nil and v2[emitter.Name] or v[emitter.Name]

							if os.clock() - v6[2] > v6[1] then
								emitter:Emit(1)
							end
						end
					end
				end

				local now = os.clock()

				for k, _ in pairs(v) do
					local nows = v[k]

					if now - nows[2] > nows[1] then
						nows[2] = now
					end
				end

				for k, _ in pairs(v2) do
					local nows = v2[k]

					if now - nows[2] > nows[1] then
						nows[2] = now
					end
				end

				RunService.RenderStepped:Wait()
			end

			v3 = false
		end)
	end
end

return function(data)
	local ID = data.ID
	local adornees = data.Adornees

	if typeof(adornees) == "table" and next(adornees) then
		if ID == 1 then
			for _, adornee in ipairs(adornees) do
				if not (adornee and adornee.Parent ~= nil) then
					continue
				end

				local clone = (adornee:GetAttribute("IsPlayerEmber") and script.PlayerBlueMoonWisp.Attachment or script.BlueMoonWisp.Attachment):Clone()
				clone.Name = "_AzureWispAttachment"
				local v6 = adornee
				local success, result = pcall(function()
					clone.CFrame = CFrame.new(v6.Position)
					clone.Parent = terrain

					if data.Color then
						Util.ColorShiftObjectDescendantsTable(clone, {
							Default_Color1 = color,
							Shifted_Color1 = data.Color
						})
					end

					local play = Util.Sound:Play("KitsuneZFireLoop", clone, nil, 1 + math.random(-12, 12) / 100, 0.3)
					play.Looped = true
					v4[v6] = clone

					if checkVisible(v6.Position) then
						spawnEffect(v6.Position, data.Color)
					end
				end)

				if not success then
					warn(script.Parent.Name .. ": Wisp creation failed")
					warn(result)

					if clone then
						clone:Destroy()
					end

					v4[adornee] = nil
				end

				checkLoop() -- equivalent call inferred; original call site unknown
			end
		elseif ID == 2 and next(v4) then
			for _, adornee in ipairs(adornees) do
				if not v4[adornee] then
					continue
				end

				v4[adornee]:Destroy()
				v4[adornee] = nil

				if checkVisible(adornee.Position) and adornee ~= nil and adornee.Parent ~= nil then
					despawnEffect(adornee.Position, data.Color)
				end
			end
		end
	else
		warn(script.Parent.Name .. ": 'Adornees' is either not a table of parts/attachments, or empty")
	end
end