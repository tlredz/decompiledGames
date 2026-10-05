local createVector = vector.create
local import = _G.import("romodel")
local import2 = _G.import("global")
local import3 = _G.import("event")
local import4 = _G.import("itemModules")
_G.import("iconData")
local import5 = _G.import("eggCollection")
local import6 = _G.import("animUtil")
local import7 = _G.import("modelUtil")
local import8 = _G.import("iterUtil")
local import9 = _G.import("mathUtil")
local import10 = _G.import("effectUtil")
local import11 = _G.import("clientUtil")
local import12 = _G.import("viewImports")
local basic = import12:get("basic")
local menu = import12:get("menu")
local petRewardFrame = import12:get("item").PetRewardFrame
local petViewport = import12:get("item").PetViewport
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local localPlayer = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local replicatedAssets = game.ReplicatedStorage.ReplicatedAssets
local cframe = CFrame.new(0, 0, -7)
local model = import.model("Part")

function model.init()
	return {
		Size = createVector(1, 1, 1),
		Anchored = true,
		CanCollide = false,
		Transparency = 1
	}
end

function model:prespawn()
	local instance = self.Instance
	self.RenderCon = RunService.RenderStepped:Connect(function()
		instance.CFrame = currentCamera.CFrame
	end)
end

function model.despawn(p)
	p.RenderCon:Disconnect()
end

local function attachCameraEffects(attached)
	local particles = import10.particles("PackRollParticles", attached.Instance)
	import10.scale(particles, 0.75)
	local manualWeld = import7.manualWeld(attached.Instance, particles, cframe)
	task.delay(0.1, function()
		local v = import10.emit("PackRollExpl", attached.Instance)
		import10.scale(v, 0.75)
		import7.manualWeld(attached.Instance, v, cframe)
	end)
	return {
		ParticlesWeld = manualWeld
	}
end

local model2 = import.model(basic.EmptyElement, basic.ConstrainedElement)

function model2.init(data)
	local item = import4:getItem("Pet", data.PetId)
	return {
		Location = "Center",
		Size = data.UseFrame and UDim2.new(0.165, 0, 0.165, 0) or UDim2.new(0.4, 0, 0.4, 0)
	}, {
		Reward = data.UseFrame and import.make(petRewardFrame, {
			Size = UDim2.new(1, 0, 1, 0),
			Id = data.PetId,
			ItemType = "Pet"
		}) or import.make(petViewport, {
			Location = "Center",
			Id = data.PetId,
			NoSpin = data.NoSpin
		}),
		NameLabel = import.make(basic.TextLabel, {
			Position = data.UseFrame and UDim2.new(0, 0, 0.05, 0) or UDim2.new(0, 0, -0.2, 0),
			Size = UDim2.new(1, 0, 0.22, 0),
			Text = item.DisplayName,
			StrokeWidth = 3,
			ZIndex = 2
		}),
		RarityLabel = import.make(import.wrap(basic.TextLabel, basic.Gradient), {
			Position = data.UseFrame and UDim2.new(0, 0, 0.225, 0) or UDim2.new(0, 0, -0.02, 0),
			Size = UDim2.new(1, 0, 0.15, 0),
			Text = item.Rarity,
			GradientColor = replicatedAssets.Ui.Gradients[item.Rarity].Color,
			StrokeWidth = 3,
			ZIndex = 2
		}),
		StatusLabel = import.make(basic.TextLabel, {
			Position = data.UseFrame and UDim2.new(0.5, 0, 0.77, 0) or UDim2.new(0.5, 0, 1.2, 0),
			Size = UDim2.new(0.6, 0, 0.15, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			Text = data.IsNew and "NEW!" or "+EXP",
			TextColor3 = data.IsNew and Color3.fromRGB(90, 255, 120) or Color3.fromRGB(251, 255, 10),
			StrokeWidth = 3,
			ZIndex = 2
		})
	}
end

function model2:prespawn()
	if not self.Order then
		return
	end

	self.Size = UDim2.new(0, 0, 0, 0)
	task.delay((self.Order - 1) * 0.1, function()
		import11.sound("IndividualReward")
		self:tween(TweenInfo.new(0.3, Enum.EasingStyle.Back), {
			Size = UDim2.new(0.15, 0, 0.15, 0)
		})
	end)
end

local model3 = import.model(basic.ImageButton, basic.EmptyElement)

function model3.init(p)
	local reward = p.Reward
	return {
		Size = UDim2.new(1, 0, 1, 0),
		NoAspectRatio = true,
		ZIndex = 10,
		Attached = import.mount(import.make(model), workspace),
		MouseButton1Down = function(p2)
			p2.Parent:continue()
		end
	}, {
		Pet = import.make(model2, {
			PetId = reward.Id,
			IsNew = reward.IsNew,
			NoSpin = true
		})
	}
end

function model3.prespawn(p)
	local v = attachCameraEffects(p.Attached)
	import11.sound("PackOpen")
	local viewportFrame = p.Pet.Instance.ViewportFrame
	task.spawn(import6.animate, 0.4, function(p2)
		local v2 = 2 - 1.5 * import9.backOut(p2)
		viewportFrame.Position = UDim2.new(0.5, 0, v2, 0)
		local C0 = cframe * CFrame.new(0, (v2 - 0.5) * -2.5, 0)
		v.ParticlesWeld.C0 = C0
	end)
	local pet = viewportFrame.WorldModel.Pet
	task.spawn(function()
		import6.animate(0.2, function(p2)
			local cubicOut = import9.cubicOut(p2)

			if not pet.PrimaryPart then
				return
			end

			pet:SetPrimaryPartCFrame(CFrame.Angles(0, 3.141592653589793 + cubicOut * 1, 0))
		end)
		import6.animate(0.8, function(p2)
			local backOut = import9.backOut(p2)

			if not pet.PrimaryPart then
				return
			end

			pet:SetPrimaryPartCFrame(CFrame.Angles(0, 4.141592653589793 - backOut, 0))
		end)
	end)
	task.spawn(function()
		TweenService:Create(currentCamera, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			FieldOfView = 65
		}):Play()
		task.wait(0.2)
		TweenService:Create(currentCamera, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			FieldOfView = 70
		}):Play()
	end)
end

local model4 = import.model("ImageButton")

function model3.despawn(p)
	if not p.Attached then
		return
	end

	p.Attached:Destroy()
end

function model4.init(p)
	return {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.25,
		ZIndex = -1,
		MouseButton1Down = function()
			p.OnClose()
		end
	}, {
		Inner = import.make(basic.EmptyList, {
			Location = "Center",
			Size = UDim2.new(0.5, 0, 1, 0),
			NoAspectRatio = true,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			FillDirectionMaxCells = 5,
			Padding = UDim.new(0.014, 0),
			Wraps = true
		}, import8.toDict(p.Rewards, function(order, p3)
			return order, import.make(model2, {
				Order = order,
				Size = UDim2.new(0, 0, 0, 0),
				PetId = p3.Id,
				IsNew = p3.IsNew,
				UseFrame = true
			})
		end))
	}
end

function model4.prespawn(_)
	import11.sound("Rewards")
end

local model5 = import.model(basic.EmptyElement)

function model5.init(p)
	local cam = import.mount(import.make(model), workspace)
	local orientation = import5:get(p.EggId).Orientation or createVector(0, 0, 0)
	local baseCF = CFrame.new(0, 0, -8) * CFrame.Angles(
		math.rad(orientation.X),
		math.rad(orientation.Y),
		(math.rad(orientation.Z))
	)
	local child = replicatedAssets.Eggs:FindFirstChild(p.EggId)

	if child then
		local clone = child:Clone()
		clone.Parent = cam.Instance

		for _, part in ipairs(clone:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			part.CanCollide = false
			part.Anchored = false
		end

		import7.manualWeld(cam.Instance, clone.PrimaryPart, baseCF)
	end

	return {
		Size = UDim2.new(1, 0, 1, 0),
		AnimationReady = false,
		Reward = p.PetId,
		Cam = cam,
		BaseCF = baseCF
	}
end

function model5:prespawn()
	task.spawn(function()
		local manualWeld = self.Cam.Instance:FindFirstChildWhichIsA("Model").PrimaryPart:FindFirstChild("ManualWeld")
		local v = 2

		if import2.get("playerSave", localPlayer):hasPass(1860766842) then
			v *= 0.25
		end

		import11.sound("PackSpin")
		import6.animate(v, function(p)
			local v2 = p < 0.5 and import9.quadIn(p * 2) / 2 or 0.5 + (p - 0.5) * 2
			local v3 = v2 * 30

			if manualWeld then
				local vectorToObjectSpace = manualWeld.Part1.PivotOffset:Inverse():VectorToObjectSpace(createVector(
					0,
					1,
					0
				))
				manualWeld.C0 = self.BaseCF * CFrame.fromAxisAngle(vectorToObjectSpace, v3)
			end

			currentCamera.FieldOfView = 70 - v2 * 20
		end)
		self.AnimationReady = true
		self:tryReveal()
	end)
end

function model5.despawn(p)
	if not p.Cam then
		return
	end

	p.Cam:Destroy()
end

function model5:setReward(reward)
	self.Reward = reward
	self:tryReveal()
end

function model5:tryReveal()
	if not (self.AnimationReady and self.Reward) then
		return
	end

	if self.Cam then
		self.Cam:Destroy()
	end

	import.apply(self, nil, {
		RewardView = import.make(model3, {
			Reward = self.Reward
		})
	})
	self.Parent:updateLabel()
	self.Parent.SkipButton.Visible = true
end

function model5:continue()
	if self.OnCooldown then
		return
	end

	self.OnCooldown = true
	self.RewardView:Destroy()
	self.Parent:advance()
	local v = self.QuickOpen and 0.125 or 0.5
	task.delay(v, function()
		self.OnCooldown = false
	end)
end

local model6 = import.model("ScreenGui", basic.Ui)

function model6.init(p)
	print("[DOF TRACE] eggOpeningOverlay.init mounting EggOpeningBlur")
	return {
		IgnoreGuiInset = true,
		DisplayOrder = 4,
		Name = "EggOpeningOverlay",
		EggId = p.EggId,
		AllRewards = nil,
		CurrentIndex = 0,
		DepthOfField = import.mount(import.make("DepthOfFieldEffect", {
			Name = "EggOpeningBlur",
			InFocusRadius = 7,
			FarIntensity = 0.5
		}), game.Lighting)
	}, {
		EggRound = import.make(model5, {
			EggId = p.EggId
		}),
		ClickLabel = import.make(basic.TextLabel, {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0.875, 0),
			Size = UDim2.new(0.6, 0, 0.035, 0),
			StrokeWidth = 2,
			Text = ""
		}),
		SkipButton = import.make(import.wrap(menu.Button, basic.ConstrainedElement), {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0.04, 0, 0.94, 0),
			Size = UDim2.new(0.2, 0, 0.08, 0),
			AspectRatio = 3.5,
			Text = "Skip",
			Visible = false,
			ZIndex = 1000,
			_Events = {
				MouseButton1Down = function(p2)
					p2.Parent:skipToEnd()
				end
			}
		})
	}
end

function model6:updateLabel()
	local v = #self.AllRewards - self.CurrentIndex
	self.ClickLabel.Text = v > 0 and string.format("Click to continue (%d remaining)", v) or "Click to continue"
end

function model6:setRewards(allRewards)
	self.AllRewards = allRewards
	self.CurrentIndex = 1
	self.EggRound:setReward(allRewards[1])
end

function model6:advance()
	if self.CurrentIndex >= #self.AllRewards then
		import.apply(self, nil, {
			EggRound = nil,
			FinalView = import.make(basic.EmptyElement, {
				Size = UDim2.new(1, 0, 1, 0)
			}, {
				View = import.make(model4, {
					Rewards = self.AllRewards,
					OnClose = function()
						if self.OnClose then
							self.OnClose()
						end

						self.OnClose = nil
						self:Destroy()
					end
				})
			})
		})
		self.SkipButton.Visible = false
		self.ClickLabel.Text = "Click to close"
	else
		self.CurrentIndex += 1
		import.apply(self.EggRound, nil, {
			RewardView = import.make(model3, {
				Reward = self.AllRewards[self.CurrentIndex]
			})
		})
		self:updateLabel()
	end
end

function model6:skipToEnd()
	if not import2.get("playerSave", localPlayer):hasPass(1860766842) then
		MarketplaceService:PromptGamePassPurchase(localPlayer, 1860766842)
		return
	end

	self.SkipButton.Visible = false
	self.EggRound:Destroy()
	self.CurrentIndex = #self.AllRewards
	self:advance()
end

function model6:setPromptsEnabled(enabled)
	for _, child in ipairs(workspace.Meta.Eggs:GetChildren()) do
		local root = child:FindFirstChild("Root")
		local proximityPrompt = root and root:FindFirstChildOfClass("ProximityPrompt")

		if proximityPrompt then
			proximityPrompt.Enabled = enabled
		end
	end
end

function model6:prespawn()
	import3.fire("setHudVisibility", false)
	self:setPromptsEnabled(false)
end

function model6:despawn()
	import3.fire("setHudVisibility", true)
	self:setPromptsEnabled(true)

	if self.DepthOfField then
		self.DepthOfField:Destroy()
	end

	if self.OnClose then
		self.OnClose()
	end
end

return {
	EggOpeningOverlay = model6
}