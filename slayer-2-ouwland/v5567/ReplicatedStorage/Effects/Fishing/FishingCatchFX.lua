local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- equivalent calls inferred from this helper; original call sites unknown
local function findCatch(childName)
	if type(childName) ~= "string" then
		return nil
	end

	local debree = workspace:FindFirstChild("Debree")

	if debree == nil then
		return nil
	end

	return debree:WaitForChild(childName, 0.1)
end

local function catchRoot(part)
	if part:IsA("BasePart") then
		return part
	end

	local root = part:FindFirstChild("Root")

	if root == nil or not root:IsA("BasePart") then
		return part:FindFirstChildWhichIsA("BasePart", true)
	end

	return root
end

local function onRing(childName, value)
	local catch = findCatch(childName) -- equivalent call inferred; original call site unknown
	local parent

	if catch ~= nil then
		local root

		if catch:IsA("BasePart") then
			root = catch
		else
			root = catch:FindFirstChild("Root")

			if root == nil or not root:IsA("BasePart") then
				root = catch:FindFirstChildWhichIsA("BasePart", true)
			end
		end

		parent = root or nil
	end

	if parent == nil then
		return
	end

	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local drops_VFX

	if assets ~= nil then
		drops_VFX = assets:FindFirstChild("Drops_VFX") or nil
	end

	local circular

	if drops_VFX ~= nil then
		circular = drops_VFX:FindFirstChild("Circular") or nil
	end

	local attachment

	if circular ~= nil then
		attachment = circular:FindFirstChild((tostring(value or 1))) or nil
	end

	if attachment == nil or not attachment:IsA("Attachment") then
		return
	end

	local clone = attachment:Clone()

	for _, emitter in clone:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	clone.Parent = parent
end

local function playSplashSound(waterEffect, childName: string)
	local sound = script:FindFirstChild(childName)

	if sound == nil or not sound:IsA("Sound") then
		return
	end

	local clone = sound:Clone()
	clone.Parent = waterEffect
	clone:Play()
	clone.Ended:Once(function()
		clone:Destroy()
	end)
end

local function onSplash(childName, p)
	local catch = findCatch(childName) -- equivalent call inferred; original call site unknown
	local parent

	if catch ~= nil then
		local root

		if catch:IsA("BasePart") then
			root = catch
		else
			root = catch:FindFirstChild("Root")

			if root == nil or not root:IsA("BasePart") then
				root = catch:FindFirstChildWhichIsA("BasePart", true)
			end
		end

		parent = root or nil
	end

	if parent == nil then
		return
	end

	local waterEffect = parent:FindFirstChild("WaterEffect")

	if waterEffect == nil then
		if p ~= true then
			return
		end

		local effect = script:FindFirstChild("Effect")

		if effect == nil then
			return
		end

		waterEffect = effect:Clone()
		waterEffect.Name = "WaterEffect"
		waterEffect.Parent = parent
	end

	local splash = waterEffect:FindFirstChild("Splash")

	if splash ~= nil then
		Ouwmit.Emit(splash)
	end

	playSplashSound(waterEffect, p == true and "PS2fishingBAITSPLASH" or "PS2fishingBAITPULL")
	local toEnable = waterEffect:FindFirstChild("ToEnable")

	if toEnable ~= nil then
		Ouwmit.Enable(toEnable, p == true)
	end

	if p ~= true then
		local worldPosition = waterEffect.WorldPosition
		waterEffect.Parent = workspace.Debree
		waterEffect.WorldPosition = worldPosition
		DebrisModule:AddItem(waterEffect, 5)
	end
end

local function onDrop(childName, value)
	local catch = findCatch(childName) -- equivalent call inferred; original call site unknown
	local v

	if catch ~= nil then
		local root

		if catch:IsA("BasePart") then
			root = catch
		else
			root = catch:FindFirstChild("Root")

			if root == nil or not root:IsA("BasePart") then
				root = catch:FindFirstChildWhichIsA("BasePart", true)
			end
		end

		v = root or nil
	end

	if catch == nil or v == nil or type(value) ~= "number" then
		return
	end

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "CatchCountdown"
	billboardGui.Adornee = v
	billboardGui.Size = UDim2.fromScale(1, 1)
	billboardGui.StudsOffset = createVector(0, 1.4, 0)
	billboardGui.AlwaysOnTop = true
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.SourceSansSemibold
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Thickness = 2
	uIStroke.Transparency = 0.25
	uIStroke.Parent = textLabel
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Rotation = -90
	uIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	uIGradient.Parent = uIStroke
	textLabel.Parent = billboardGui
	billboardGui.Parent = v
	local v2 = os.clock() + value
	task.spawn(function()
		local v3 = false

		while catch.Parent ~= nil do
			local v4 = v2 - os.clock()

			if v4 <= 0 then
				break
			end

			textLabel.Text = tostring((math.ceil(v4)))

			if not v3 and v4 <= 0.35 then
				v3 = true

				for _, part in catch:GetDescendants() do
					if part:IsA("BasePart") then
						TweenService:Create(part, tweenInfo, {
							Transparency = 1
						}):Play()
					end
				end

				if catch:IsA("BasePart") then
					TweenService:Create(catch, tweenInfo, {
						Transparency = 1
					}):Play()
				end

				TweenService:Create(textLabel, tweenInfo, {
					TextTransparency = 1
				}):Play()
				TweenService:Create(uIStroke, tweenInfo, {
					Transparency = 1
				}):Play()
			end

			task.wait(0.1)
		end
	end)
end

return function(p: string, ...)
	if p == "Ring" then
		onRing(...)
	elseif p == "Splash" then
		onSplash(...)
	elseif p == "Drop" then
		onDrop(...)
	end
end