local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local sounds = script.Parent:WaitForChild("Sounds")
local cframe = CFrame.new(17.5, 0, 0)

local function rebaseGatePiece(part)
	if not part:IsA("BasePart") or part:GetAttribute("CFsRebased") then
		return
	end

	local startCF = part:GetAttribute("StartCF")
	local endCF = part:GetAttribute("EndCF")

	if startCF == nil or endCF == nil then
		return
	end

	local v = part.CFrame * startCF:Inverse()
	part:SetAttribute("StartCF", part.CFrame)
	part:SetAttribute("EndCF", v * endCF)
	part:SetAttribute("CFsRebased", true)
end

local class = {}
class.__index = class

function class:PoseGate(top)
	local gate = self.Gate

	if gate == nil then
		return
	end

	if gate:GetAttribute("IsCF") then
		local v = self.GateOpen and "EndCF" or "StartCF"

		for _, part in top ~= nil and { top } or gate:GetChildren(), nil, nil do
			if not part:IsA("BasePart") then
				continue
			end

			rebaseGatePiece(part)
			local attribute = part:GetAttribute(v)

			if attribute then
				part.CFrame = attribute
			end
		end
	else
		local gateStart = gate:GetAttribute("GateStart")

		if top == nil then
			top = gate:FindFirstChild("Top")
		end

		if gateStart == nil or top == nil or top.Name ~= "Top" or not top:IsA("BasePart") then
			return
		end

		if self.GateOpen then
			gateStart *= cframe
		end

		top.CFrame = gateStart
	end
end

function class:Reset(p, p2)
	if self.Lever == nil then
		return
	end

	local A_ = self.Lever:FindFirstChild("A_")

	if A_ == nil then
		return
	end

	if p then
		if not p2 then
			A_:SetAttribute("On", false)
		end

		if self.Tweens then
			for _, tween in self.Tweens do
				tween:Cancel()
			end

			table.clear(self.Tweens)
		end

		if self.Dusts then
			for _, dust in self.Dusts do
				dust:Destroy()
			end

			table.clear(self.Dusts)
		end

		if self.Shake then
			if self.Shake:IsShaking() then
				self.Shake:Stop()
			end

			self.Shake = nil
		end

		if self.LeverStop then
			self.LeverStop()
			self.LeverStop = nil
		end

		if self.GateStop then
			self.GateStop()
			self.GateStop = nil
		end

		if self.Sounds then
			for _, sound in self.Sounds do
				if not (sound and sound.Parent) then
					continue
				end

				sound:Stop()
				sound:Destroy()
			end

			table.clear(self.Sounds)
		end

		if self.Gate and not p2 then
			self.GateOpen = false
			self:PoseGate()
		end
	end

	local endPivot

	if A_:GetAttribute("On") then
		endPivot = A_:GetAttribute("EndPivot")
	else
		endPivot = A_:GetAttribute("StartPivot")
	end

	if not endPivot then
		return
	end

	A_:PivotTo(endPivot)
end

function class:Destroy(p)
	self:Reset(true, p)

	if p and self.Lever then
		local A_ = self.Lever:FindFirstChild("A_")
		local leverMain = A_ and A_:FindFirstChild("LeverMain")
		local proximityPrompt = leverMain and leverMain:FindFirstChild("ProximityPrompt")

		if proximityPrompt then
			proximityPrompt.Enabled = false
		end
	end

	self.HoldStarted = nil

	for _, v in { self.Connections, self.PromptConnections } do
		if v == nil then
			continue
		end

		for _, connection in v do
			connection:Disconnect()
		end
	end

	self.Connections = nil
	self.PromptConnections = nil
	self.Tweens = nil
	self.Dusts = nil
	self.Sounds = nil
	self.LeverStop = nil
	self.GateStop = nil
	setmetatable(self, nil)
end

local tweenInfo = TweenInfo.new(0.1)
local tweenInfo2 = TweenInfo.new(7, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
local color = Color3.new(0.109804, 0.952941, 0.109804)
local color2 = Color3.new(0.941176, 0.345098, 0.345098)
local color3 = Color3.fromRGB(250, 186, 48)
local color4 = Color3.fromRGB(150, 85, 85)
local color5 = Color3.fromRGB(85, 150, 85)
local color6 = Color3.fromRGB(175, 124, 30)

local function playSequence(parent, p: string, p2: string, p3: string, clones)
	local clone = sounds[p]:Clone()
	clone.Parent = parent
	table.insert(clones, clone)
	clone:Play()
	local clone2 = sounds[p2]:Clone()
	clone2.Looped = true
	clone2.Parent = parent
	table.insert(clones, clone2)
	clone2:Play()
	local flag = false
	return function()
		if flag then
			return
		end

		flag = true

		if clone.Parent then
			clone:Stop()
			clone:Destroy()
		end

		if clone2.Parent then
			clone2:Stop()
			clone2:Destroy()
		end

		local clone3 = sounds[p3]:Clone()
		clone3.Parent = parent
		clone3:Play()
		DebrisModule:AddItem(clone3, 0)
	end
end

return function(instance, instance2, maid, instance3, p: number, value: number?)
	local v = value or 1
	local object = setmetatable({
		Lever = instance,
		Gate = instance2,
		GateOpen = false,
		Connections = {},
		PromptConnections = {},
		Tweens = {},
		Dusts = {},
		Sounds = {},
		LeverStop = nil,
		GateStop = nil
	}, class)
	maid:Add(task.spawn(function()
		local A_ = instance:WaitForChild("A_")
		local leverMain = A_:WaitForChild("LeverMain")
		local proximityPrompt = leverMain:WaitForChild("ProximityPrompt")

		if instance2 and not instance2:GetAttribute("IsCF") and instance2:GetAttribute("GateStart") == nil then
			instance2:SetAttribute("GateStart", instance2:WaitForChild("Top").CFrame)
		end

		object:PoseGate()
		local on = A_:GetAttribute("On") or false
		local v2 = nil
		local v3 = on

		local function track(p2, p3)
			if object.Tweens then
				if object.Tweens[p2] then
					object.Tweens[p2]:Cancel()
				end

				object.Tweens[p2] = p3
			end

			return p3
		end

		local function updateColors()
			local level = instance3:GetAttribute("Level")
			local v4 = level and level % 1 == 0
			local color9, color10

			if on then
				if v4 then
					color9 = color
				else
					color9 = color3
				end

				if v4 then
					color10 = color5
				else
					color10 = color6
				end
			else
				color9 = color2
				color10 = color4
			end

			local color7 = instance:FindFirstChild("color")
			local pointLight = color7 and color7:FindFirstChild("PointLight")
			local color8 = A_:FindFirstChild("color")

			if pointLight then
				local tween = TweenService:Create(pointLight, tweenInfo, {
					Color = color9
				})

				if object.Tweens then
					if object.Tweens.Light then
						object.Tweens.Light:Cancel()
					end

					object.Tweens.Light = tween
				end

				tween:Play()
			end

			if color7 then
				local tween = TweenService:Create(color7, tweenInfo, {
					Color = color10
				})

				if object.Tweens then
					if object.Tweens.ParentColor then
						object.Tweens.ParentColor:Cancel()
					end

					object.Tweens.ParentColor = tween
				end

				tween:Play()
			end

			if color8 then
				local tween = TweenService:Create(color8, tweenInfo, {
					Color = color10
				})

				if object.Tweens then
					if object.Tweens.LeverColor then
						object.Tweens.LeverColor:Cancel()
					end

					object.Tweens.LeverColor = tween
				end

				tween:Play()
			end
		end

		local function Update()
			local level = instance3:GetAttribute("Level")
			local v4 = level and level % 1 == 0
			updateColors()

			if not v4 then
				return
			end

			if v3 ~= on then
				if instance2 then
					local center

					if instance2:GetAttribute("IsCF") then
						center = instance2:FindFirstChild("Center")
					else
						center = instance2:FindFirstChild("Top")
					end

					if center then
						if on then
							if object.GateStop then
								object.GateStop()
								object.GateStop = nil
							end

							local gateStop = playSequence(
								center,
								"PS2gateBEGINLIFT",
								"PS2gateOPENLOOP",
								"PS2leverGATESTOP",
								object.Sounds
							)
							object.GateStop = gateStop
							task.delay(tweenInfo2.Time, function()
								if object.GateStop == gateStop then
									gateStop()
									object.GateStop = nil
								end
							end)
						elseif object.GateStop then
							object.GateStop()
							object.GateStop = nil
						end
					end

					object.GateOpen = on

					if instance2:GetAttribute("IsCF") then
						object:PoseGate()
						local center2 = on and instance2:FindFirstChild("Center")

						if center2 then
							local clone = script.IsCF.At:Clone()
							clone.Parent = center2
							DebrisModule:AddItem(clone, 3)
							Ouwmit.Emit(clone)
						end
					else
						local gateStart = instance2:GetAttribute("GateStart")
						local top = instance2:FindFirstChild("Top")

						if gateStart and top then
							if on then
								local tween = TweenService:Create(top, tweenInfo2, {
									CFrame = gateStart * cframe
								})

								if object.Tweens then
									if object.Tweens.Gate then
										object.Tweens.Gate:Cancel()
									end

									object.Tweens.Gate = tween
								end

								tween:Play()

								if object.Shake and object.Shake:IsShaking() then
									object.Shake:Stop()
								end

								object.Shake = Cam_Shaker(top.Position, {
									FadeInTime = 0.3,
									Frequency = 0.15,
									Amplitude = 0.2,
									SustainTime = 2,
									FadeOutTime = 3,
									RotationInfluence = createVector(0.1, 0.1, 0.1),
									PositionInfluence = createVector(2, 2, 2)
								})
								local bottom = instance2:FindFirstChild("Bottom")

								for _, child in script.OpenDusts:GetChildren() do
									for _, parent in { top, bottom } do
										if not parent then
											continue
										end

										local clone = child:Clone()
										clone.Parent = parent

										if object.Dusts then
											table.insert(object.Dusts, clone)
										end

										task.delay(3, function()
											if clone.Parent then
												clone.Enabled = false
											end
										end)
										local v7 = clone
										task.delay(7, function()
											if v7.Parent then
												v7:Destroy()
											end
										end)
									end
								end
							else
								local tween = TweenService:Create(top, tweenInfo2, {
									CFrame = gateStart
								})

								if object.Tweens then
									if object.Tweens.Gate then
										object.Tweens.Gate:Cancel()
									end

									object.Tweens.Gate = tween
								end

								tween:Play()
							end
						end
					end
				end

				v3 = on
			end
		end

		local startPivot = A_:GetAttribute("StartPivot")

		if not startPivot then
			startPivot = A_:GetPivot()
			A_:SetAttribute("StartPivot", startPivot)
		end

		local v4 = startPivot * CFrame.Angles(0, 2.356194490192345, 0)
		A_:SetAttribute("EndPivot", v4)

		local function bindPrompt(p2)
			for _, promptConnection in object.PromptConnections do
				promptConnection:Disconnect()
			end

			table.clear(object.PromptConnections)
			proximityPrompt = p2
			proximityPrompt.Enabled = not on
			table.insert(object.PromptConnections, proximityPrompt.Triggered:Connect(function()
				if proximityPrompt.HoldDuration > 0 and not v2 or on then
					return
				end

				on = true
				A_:SetAttribute("On", on)
				proximityPrompt.Enabled = false
				SignalEvent.ToServer("training_signaler", "StateChanged", instance)
				local color7 = instance:FindFirstChild("color")
				local v6 = (instance3:GetAttribute("Level") or p) + v
				local v7 = v6 % 1 == 0

				if color7 then
					local clone = script.Attachment:Clone()
					clone.Parent = color7
					DebrisModule:AddItem(clone, 1.5)
					local color8

					if v7 then
						if on then
							color8 = color
						else
							color8 = color2
						end
					else
						color8 = color3
					end

					Ouwmit.Emit(clone, {
						ColorWhitelist = "SetColor",
						Color = color8
					})
				end

				instance3:SetAttribute("Level", v6)
				v2 = nil
			end))
			table.insert(object.PromptConnections, proximityPrompt.PromptButtonHoldBegan:Connect(function()
				if proximityPrompt:GetAttribute("OnCooldown") then
					v2 = nil
					return
				end

				local v5, v6

				if on then
					v5 = v4
					v6 = startPivot
				else
					v5 = startPivot
					v6 = v4
				end

				object.HoldStarted = os.clock()
				v2 = true

				if object.LeverStop then
					object.LeverStop()
					object.LeverStop = nil
				end

				object.LeverStop = playSequence(
					leverMain,
					"PS2leverPULL",
					"PS2leverPULLloop",
					"PS2leverSTOP",
					object.Sounds
				)

				while object.HoldStarted ~= nil do
					A_:PivotTo(v5:Lerp(
						v6,
						(math.clamp((os.clock() - object.HoldStarted) / proximityPrompt.HoldDuration, 0, 1))
					))
					task.wait()
				end
			end))
			table.insert(object.PromptConnections, proximityPrompt.PromptButtonHoldEnded:Connect(function()
				if object.HoldStarted == nil then
					return
				end

				task.wait()

				if object.HoldStarted == nil then
					return
				end

				if os.clock() - object.HoldStarted < proximityPrompt.HoldDuration then
					object:Reset()
				end

				object.HoldStarted = nil

				if object.LeverStop then
					object.LeverStop()
					object.LeverStop = nil
				end
			end))
		end

		Update()
		object.HoldStarted = nil
		bindPrompt(proximityPrompt)
		table.insert(object.Connections, instance3:GetAttributeChangedSignal("Level"):Connect(Update))
		table.insert(object.Connections, instance.DescendantAdded:Connect(function(instance4)
			if instance4:IsA("ProximityPrompt") then
				bindPrompt(instance4)
			elseif instance4:IsA("BasePart") then
				if instance4.Name == "LeverMain" then
					leverMain = instance4
				end

				object:Reset()
				updateColors()
			end
		end))

		if instance2 then
			table.insert(object.Connections, instance2.ChildAdded:Connect(function(child)
				object:PoseGate(child)
			end))
		end
	end))
	return object
end