local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local v2 = not v
local import = _G.import("event")
local import2 = _G.import("romodel")
local import3 = _G.import("iterator")
local import4 = _G.import("collection")
local import5 = _G.import("mathUtil")
_G.import("stringUtil")
local import6 = _G.import("clientUtil")
local import7 = _G.import("itemModules")
local import8 = _G.import("iconData")
local import9 = _G.import("rankData")
local import10 = _G.import("viewImports")
local react = import10:get("react")
local basic = import10:get("basic")
local ux = import10:get("ux")
local avatar = import10:get("avatar").Avatar
local v3 = import4("Ability", game.ReplicatedStorage.Data.Config.abilityCollection)
import10:get("item")
local model = import2.model(basic.EmptyElement)

function model.init(data)
	return {
		Key = string.upper(data.Text),
		Size = UDim2.new(1, 0, 1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeYY
	}, {
		UIScale = import2.make(import2.wrap("UIScale", basic.Element), {}),
		Inner = import2.make(import2.wrap(basic.Corner, basic.Stroke, basic.ConstrainedElement), {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = data.BackgroundTransparency or 0,
			StrokeTransparency = data.StrokeTransparency or 0,
			Size = UDim2.new(1, 0, 1, 0),
			StrokeWidth = 2,
			CornerRadius = UDim.new(0.1, 0)
		}, {
			TextLabel = import2.make(basic.TextLabel, {
				Location = "Center",
				Size = UDim2.new(0.9, 0, 0.9, 0),
				StrokeWidth = 2,
				TextTransparency = data.TextTransparency or 0,
				TextStrokeTransparency = data.TextStrokeTransparency or 0,
				Text = string.upper(data.Text),
				Scale = true
			}),
			InnerBack = import2.make(import2.wrap(basic.Corner, basic.ConstrainedElement), {
				Visible = false,
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 1,
				StrokeTransparency = data.StrokeTransparency or 0,
				Size = UDim2.new(1, 0, 1, 0),
				CornerRadius = UDim.new(0.1, 0),
				ZIndex = 3
			}, {
				UIStroke = import2.make(import2.wrap("UIStroke", basic.Gradient), {
					Thickness = 3,
					Color = Color3.new(1, 1, 1),
					RotSpeed = 800,
					GradientTransparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(0.8, 1),
						NumberSequenceKeypoint.new(1, 0)
					}),
					GradientColor = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.new(0.0823529, 0.478431, 1)),
						ColorSequenceKeypoint.new(0.9, Color3.new(0.423529, 0.866667, 1)),
						ColorSequenceKeypoint.new(1, Color3.new(0.745098, 0.996078, 1))
					})
				})
			})
		})
	}
end

function model.prespawn(p)
	p.UIScale.Scale = 0.6
	p.UIScale:tween(TweenInfo.new(0.4, Enum.EasingStyle.Back), {
		Scale = 1
	})
end

function model:correct(p2)
	task.delay(p2 * 0.05, function()
		self.Inner:tween(TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
			Position = UDim2.new(0, 0, -0.5, 0)
		})
		task.wait(0.05)
		self.Inner:tween(TweenInfo.new(0.5, Enum.EasingStyle.Back), {
			Position = UDim2.new(0, 0, 0, 0)
		})
		task.wait(0.5)
		self.Inner:tween(TweenInfo.new(0.2, Enum.EasingStyle.Back), {
			Rotation = 0
		})
	end)
end

local model2 = import2.model(basic.Element)

function model2.init()
	return {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.new(0, 0, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 2, 1.05, 0)
	}
end

function model2:prespawn()
	self.Con = true
	task.spawn(function()
		while self.Con do
			self.BackgroundTransparency = 1
			task.wait(0.75)
			self.BackgroundTransparency = 0
			task.wait(0.75)
		end
	end)
end

function model2:despawn()
	self.Con = false
end

local model3 = import2.model(basic.TextLabel)

function model3.init(p)
	return {
		Location = "Center",
		Size = UDim2.new(1, 0, 0.45, 0),
		Text = p.Text,
		TextTransparency = 0,
		TextStrokeTransparency = 0,
		StrokeWidth = 2,
		LayoutOrder = p.LayoutOrder,
		RichText = true,
		Scale = true
	}
end

local model4 = import2.model(basic.EmptyList)

function model4.init()
	return {
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.new(0, 0, 0.475, 0),
		Size = UDim2.new(1, 0, 0.12, 0),
		Visible = false,
		ZIndex = 1,
		FillDirection = Enum.FillDirection.Vertical
	}
end

function model4:clear()
	for k, guiObject in pairs(self._Children) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		self._Children[k] = nil
		guiObject:Destroy()
	end
end

function model4:push(text)
	local layoutOrder = self:guiChildren() + 1
	import2.apply(self, nil, {
		[layoutOrder] = import2.make(model3, {
			Text = text,
			LayoutOrder = layoutOrder
		})
	})
end

function model4:set(p)
	self:clear()
	self:push(p)
end

local model5 = import2.model(basic.EmptyElement)

function model5.init()
	return {
		LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0.4, 0),
		Word = "",
		LockedCount = 0
	}, {
		Keys = import2.make(basic.EmptyList, {
			Size = UDim2.new(1, 0, 1, 0),
			Padding = UDim.new(0.01, 0),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Wraps = false
		}),
		BlinkingInput = import2.make(model2, {
			Position = UDim2.new(0.5, 0, 0.5, 0)
		})
	}
end

function model5:reset(value)
	self:clear()
	self.LockedCount = 0
	self:updateBlinking(0)
	local v4 = value or ""

	for i = 1, #v4 do
		self:push(v4:sub(i, i), true)
	end

	self.LockedCount = #v4
	self.BlinkingInput.Visible = localPlayer and localPlayer:GetAttribute("IsTurn")
	self:updateBlinking(self.Keys:guiChildren())
end

function model5:clear()
	for k, guiObject in pairs(self.Keys._Children) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		self.Keys._Children[k] = nil
		guiObject:Destroy()
	end
end

function model5:skin(p2)
	if not p2 then
		return
	end

	local item = import7:getItem("Skin", p2)

	if not item then
		return
	end

	local v4 = import10:get("sprite")[item.Sheet and "SpriteSheet" or "Sprite"]
	import2.apply(self, {}, {
		Sprite = import2.make(v4, {
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(0, 0, 0),
			AspectRatio = 1.33,
			Size = UDim2.new(6, 0, 6, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 1, 0),
			Images = item.Sprite,
			ZIndex = 10,
			Speed = 1,
			Loop = 1
		})
	})

	if item.Sound then
		import6.sound(item.Sound)
	end

	if item.VignetteColor or item.VignetteAnim then
		local vignettePopup = import10:get("vignettePopup").VignettePopup
		import2.mount(import2.make(vignettePopup, {
			Image = "rbxassetid://93609453890037",
			VignetteColor = item.VignetteColor,
			VignetteAnim = item.VignetteAnim
		}), plugin and game.StarterGui or localPlayer.PlayerGui)
	end
end

function model5:correct(value, p)
	self:clear()
	self.BlinkingInput.Visible = false
	self:skin(p)

	for i = 1, #value do
		local text = value:sub(i, i)
		import2.apply(self.Keys, nil, {
			[i] = import2.make(model, {
				Text = text
			})
		})
	end

	for k, guiObject in pairs(self.Keys._Children) do
		if guiObject:IsA("GuiObject") then
			guiObject:correct(k)
		end
	end
end

function model5:keyStroke(value)
	import6.sound("KeyStroke")

	if self.Keys:guiChildren() < #value then
		self:push("c")
	else
		self:pop()
	end

	for _, guiObject in pairs(self.Keys:GetChildren()) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local name = tonumber(guiObject.Name)
		guiObject.Inner.TextLabel.Text = string.upper(value:sub(name, name))
	end
end

function model5:currentWord()
	local textsByName = {}

	for _, guiObject in pairs(self.Keys:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			textsByName[tonumber(guiObject.Name)] = guiObject.Inner.TextLabel.Text
		end
	end

	return table.concat(textsByName)
end

function model5:prespawn()
	self.Con = import.remoteConnect("updateTyping", function(p)
		if self.Ui.RoundEnded then
			return
		end

		self:keyStroke(p)
	end)
	self.Con1 = import.connect("keyStroke", function(p)
		if self.Ui.RoundEnded then
			return
		end

		local currentWord = self:currentWord()
		self:keyStroke(p == -1 and currentWord:sub(1, #currentWord - 1) or currentWord .. p)
	end)
	self.Con2 = import.remoteConnect("correct", function(p, p2, p3)
		self.Ui.RoundEnded = true
		self:correct(p, p3)

		if p2 then
			self:censor()
		else
			self:decensor()
		end
	end)
end

function model5.despawn(p)
	for _, v4 in pairs({ "Con", "Con1", "Con2" }) do
		import.disconnect(p[v4])
	end
end

function model5:censor()
	for _, guiObject in pairs(self.Keys:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject.Inner.TextLabel.Text = "#"
		end
	end
end

function model5:decensor()
	for _, guiObject in pairs(self.Keys._Children) do
		if guiObject:IsA("GuiObject") then
			guiObject.Inner.TextLabel.Text = guiObject.Key
		end
	end
end

function model5:updateBlinking(p2)
	self.BlinkingInput.Position = UDim2.new(0.5 + 0.0336 * p2 + 0.005, 0, 0.5, 0)
end

function model5:push(text, _)
	local guiChildren = self.Keys:guiChildren()
	import2.apply(self.Keys, nil, {
		[guiChildren + 1] = import2.make(model, {
			Text = text
		})
	})
	self:updateBlinking(guiChildren + 1)
end

function model5:pop(_)
	local guiChildren = self.Keys:guiChildren()

	if guiChildren <= self.LockedCount then
		return
	end

	local v4 = self.Keys._Children[tostring(guiChildren)]
	self.Keys._Children[tostring(guiChildren)] = nil
	v4.UIScale:tween(TweenInfo.new(0.15), {
		Scale = 0
	})
	task.delay(0.15, function()
		v4:Destroy()
	end)
	self:updateBlinking(guiChildren - 1)
end

local model6 = import2.model(basic.EmptyList)

function model6.init()
	return {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0.2, 0),
		Size = UDim2.new(0.8, 0, 1, 0),
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0.025, 0)
	}, {
		QuestionLabel = import2.make(basic.TextLabel, {
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(1, 0, 0),
			Size = UDim2.new(1, 0, 1, 0),
			Text = "Type a word starting with...",
			StrokeWidth = 2
		})
	}
end

function model6:update(p2)
	self.QuestionLabel.Text = p2.QuestionLabel or "Type a word starting with..."
end

function model6.spawn(question)
	question.Ui.Question = question
end

local model7 = import2.model(basic.ConstrainedElement, basic.EmptyList)

function model7.init()
	return {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0.04, 0),
		AspectRatio = 7,
		Size = UDim2.new(1, 0, 0.2, 0),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(PHONE and 0.25 or 0.6, 0)
	}, {
		Question = import2.make(model6, {
			LayoutOrder = 1
		}),
		AnswerInput = import2.make(model5, {
			LayoutOrder = 2
		})
	}
end

local model8 = import2.model(basic.ImageButton)

function model8.init(p)
	local text = p.Text or ""
	return {
		BackgroundTransparency = 1,
		ImageTransparency = 1,
		Size = UDim2.new(0.42, 0, 0.42, 0),
		AspectRatio = 1,
		Visible = p.Visible ~= false,
		Choice = text,
		MouseButton1Down = function(p2)
			if not (localPlayer:GetAttribute("IsTurn") and p2.Choice ~= "") then
				return
			end

			import.remoteFire("chooseLetter", string.lower(p2.Choice))
		end
	}, {
		Key = import2.make(model, {
			Text = text
		})
	}
end

local model9 = import2.model(basic.List)

function model9.init()
	return {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0.24, 0),
		Size = UDim2.new(0.8, 0, 0.3, 0),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0.015, 0),
		Wraps = true,
		Visible = false,
		ZIndex = 7
	}
end

function model9.spawn(choiceList)
	choiceList.Ui.ChoiceList = choiceList
end

function model9:updateChoices(p2)
	for k, guiObject in pairs(self._Children) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		self._Children[k] = nil
		guiObject:Destroy()
	end

	import2.apply(self, nil, import3.gen(4, function(layoutOrder)
		local v4 = p2[layoutOrder]
		return layoutOrder, import2.make(model8, {
			LayoutOrder = layoutOrder,
			Text = v4 or "",
			Visible = v4 ~= nil
		})
	end))
	self.Visible = true
end

local model10 = import2.model(basic.ImageLabel)

function model10.init()
	return {
		Location = "Center",
		Scale = 0.65,
		ZIndex = 3,
		Progress = 0,
		Rate = 1
	}
end

function model10:prespawn()
	self.Con = RunService.RenderStepped:Connect(function()
		self.Rotation = self.Progress * 360 * self.Rate
	end)
end

function model10.despawn(p)
	p.Con:Disconnect()
end

local model11 = import2.model(basic.ImageLabel)

function model11:pause()
	self.Id = nil
end

function model11:unfreeze()
	self.FreezeId = nil
	self.Image = "rbxassetid://73203662117191"
end

function model11:freeze(duration)
	local GUID = HttpService:GenerateGUID()
	self.FreezeId = GUID
	self.Image = import8.FrozenTime
	task.delay(duration, function()
		if self.FreezeId ~= GUID then
			return
		end

		self:unfreeze()
	end)
end

function model11:time(p)
	local cachedSize = self.CachedSize
	local scale = cachedSize.X.Scale
	local scale2 = cachedSize.Y.Scale
	self:unfreeze()
	local GUID = HttpService:GenerateGUID()
	local v4 = 1
	self.Id = GUID
	task.spawn(function()
		local total = 0
		local v5 = math.floor(total)

		while total < p and self.Id == GUID do
			local progress = total / p
			local v7 = math.floor(total)

			if v5 < v7 then
				v4 = 1 - v4
				task.spawn(function()
					import6.sound(v4 == 1 and "Tick" or "Tock")
					self:tween(TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
						Size = UDim2.new(scale * 1.5, 0, scale2 * 1.5, 0)
					})
					task.wait(0.1)
					self:tween(TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = UDim2.new(scale, 0, scale2, 0)
					})
				end)
				v5 = v7
			end

			self.LongHand.Progress = progress
			self.ShortHand.Progress = progress
			self.Timer.Text = import5.round(p - total, 1)
			self.Remaining = p - total
			total += task.wait(0)
		end
	end)
end

function model11.init(p)
	return {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, -0.5, 0),
		Size = UDim2.new(1, 0, 1, 0),
		Image = "rbxassetid://73203662117191",
		CachedSize = p.Size or UDim2.new(1, 0, 1, 0),
		ZIndex = 2
	}, {
		LongHand = import2.make(model10, {
			Image = "rbxassetid://112677138768672",
			Rate = 0.08333333333333333
		}),
		ShortHand = import2.make(model10, {
			Image = "rbxassetid://91130071943836"
		}),
		Timer = import2.make(basic.TextLabel, {
			Location = "Center",
			Size = UDim2.new(1, 0, 0.3, 0),
			Text = "11.3s",
			ZIndex = 4,
			StrokeWidth = 2
		})
	}
end

function model11:prespawn()
	self:con(import.remoteConnect("timeBoost", function()
		self:time(self.Remaining + 7)
	end))
	self:con(import.remoteConnect("PauseTimer", function()
		self:pause()
	end))
	self:con(import.remoteConnect("PlayTimer", function()
		self:time(self.Remaining)
	end))
	self:con(import.connect("freeze", function(p)
		self:freeze(p)
	end))
end

function model11:despawn()
	self.Id = nil
	self.FreezeId = nil
	self:clean(function(p)
		import.disconnect(p)
	end)
end

function model11.spawn(timer)
	timer.Ui.Timer = timer
end

local model12 = import2.model(basic.TextLabel, basic.Scale)

function model12.init()
	return {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.2, 0, 0.35, 0),
		Size = UDim2.new(0.35, 0, 0.05, 0),
		Font = Enum.Font.FredokaOne,
		TextColor3 = Color3.fromRGB(212, 212, 212),
		StrokeWidth = 3,
		ZIndex = 20
	}
end

function model12:prespawn()
	self.Position = UDim2.new(0.5, 0, 0.8, 0)
	self:tween(TweenInfo.new(0.8, Enum.EasingStyle.Elastic), {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		TextTransparency = 0
	})
	task.delay(1, function()
		self:Destroy()
	end)
end

local model13 = import2.model(basic.ImageLabel)

function model13.init()
	return {
		Size = UDim2.new(1, 0, 1, 0),
		SizeConstraint = Enum.SizeConstraint[TABLET and "RelativeXX" or "RelativeYY"],
		BackgroundColor3 = Color3.new(0, 0, 0),
		Image = "rbxassetid://79056006416031"
	}, {
		X = import2.make(import2.wrap(basic.TextLabel, basic.ConstrainedElement), {
			Location = "Center",
			Scale = 0.65,
			Text = "X",
			TextColor3 = Color3.fromHex("d97779"),
			StrokeWidth = 0
		}),
		UIScale = import2.make(import2.wrap("UIScale", basic.Element))
	}
end

function model13:activate(p)
	task.spawn(function()
		self.ImageColor3 = Color3.fromRGB(255, 94, 177)
		self.X.TextColor3 = Color3.new(0.901961, 0.298039, 0.376471)
		self.X.UIStroke.Thickness = 5

		if p then
			return
		end

		self:tween(TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(1.2, 0, 1.2, 0)
		})
		task.wait(0.1)
		self:tween(TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, 0, 1, 0)
		})
	end)
end

function model13:deactivate()
	self.ImageColor3 = Color3.fromRGB(255, 255, 255)
	self.X.TextColor3 = Color3.fromHex("d97779")
	self.X.UIStroke.Thickness = 0
end

local model14 = import2.model(basic.EmptyList, basic.Padding)

function model14.init(p)
	return {
		PaddingTop = UDim.new(0.1, 0),
		PaddingBottom = UDim.new(0.1, 0),
		Size = UDim2.new(1, 0, 1, 0),
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		FillDirection = p.FillDirection
	}, import3.gen(5, function(p2)
		return p2, import2.make(model13, {})
	end)
end

function model14:prespawn()
	self.Con = import.remoteConnect("strike", function(_, p, p2)
		self[tostring(p)]:activate()

		if not p2 then
			return
		end

		import2.mount(import2.make(model12, {
			Text = "ALREADY USED!"
		}), self.Ui.Instance)
	end)
	self.Con2 = import.remoteConnect("updateStrikes", function(p)
		self:update(p)
	end)
end

function model14:update(p)
	self:reset()

	for i = 1, p do
		self[tostring(i)]:activate(true)
	end
end

function model14.spawn(strikes)
	strikes.Ui.Strikes = strikes
end

function model14.despawn(p)
	import.disconnect(p.Con)
	import.disconnect(p.Con2)
end

function model14:reset()
	for _, guiObject in pairs(self._Children) do
		if guiObject:IsA("GuiObject") then
			guiObject:deactivate()
		end
	end
end

local model15 = import2.model(basic.EmptyElement, basic.ConstrainedElement)

function model15.init()
	return {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 0.9, 0),
		AspectRatio = 1,
		Scale = 0.3
	}, {
		Timer = import2.make(model11),
		Strikes = import2.make(model14)
	}
end

local model16 = import2.model(basic.ImageLabel)

function model16.init(options)
	return {
		Size = UDim2.new(1, 0, 1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Image = "rbxassetid://78861457365926",
		PopIn = (options or {}).PopIn
	}, {
		UIScale = import2.make(import2.wrap("UIScale", basic.Element))
	}
end

function model16:pop()
	self.Name = "popped"
	task.spawn(function()
		self.UIScale:tween(TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Scale = 0
		})
		task.wait(0.25)
		self.Instance:Destroy()
	end)
end

function model16.prespawn(p)
	if not p.PopIn then
		return
	end

	p.UIScale.Scale = 0.6
	p.UIScale:tween(TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	})
end

local model17 = import2.model(basic.ConstrainedElement, basic.EmptyList)

function model17.init()
	return {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0.01, 0, 0.9, 0),
		AspectRatio = 2.2,
		Scale = v and 0.12 or 0.175,
		Padding = UDim.new(0.05, 0),
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		FillDirection = Enum.FillDirection.Horizontal,
		MaxHealth = 2
	}, import3.gen(2, function(layoutOrder)
		return layoutOrder, import2.make(model16, {
			LayoutOrder = layoutOrder,
			Size = UDim2.new(1, 0, 1, 0)
		})
	end)
end

function model17:heartCount()
	local count = 0

	for _, guiObject in pairs(self.Instance:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			count += 1
		end
	end

	return count
end

function model17:setHealth(maxHealth)
	self.MaxHealth = maxHealth
	local aspectRatio = math.max(2.2, maxHealth * 1.05)
	self.AspectRatio = aspectRatio
	self.AspectRatioConstraint.AspectRatio = aspectRatio

	for k, guiObject in pairs(self._Children) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		self._Children[k] = nil
		guiObject:Destroy()
	end

	import2.apply(self, nil, import3.gen(maxHealth, function(layoutOrder)
		return layoutOrder, import2.make(model16, {
			LayoutOrder = layoutOrder,
			Size = UDim2.new(1, 0, 1, 0),
			PopIn = layoutOrder > 2
		})
	end))
end

function model17:restore()
	local heartCount = self:heartCount()

	if (self.MaxHealth or 2) <= heartCount then
		return
	end

	local layoutOrder = heartCount + 1
	import2.apply(self, nil, {
		[tostring(layoutOrder)] = import2.make(model16, {
			LayoutOrder = layoutOrder,
			Size = UDim2.new(1, 0, 1, 0),
			PopIn = true
		})
	})
end

function model17:prespawn()
	self.Con = import.remoteConnect("takeDamage", function(p)
		if p ~= localPlayer.UserId then
			return
		end

		local heartCount = self:heartCount()
		local v4 = self._Children[tostring(heartCount)]

		if not v4 then
			return
		end

		v4:pop()
	end)
	self.Con2 = import.remoteConnect("regenerate", function(p)
		if p ~= localPlayer.UserId then
			return
		end

		self:restore()
	end)
end

function model17.despawn(p)
	import.disconnect(p.Con)
	import.disconnect(p.Con2)
end

local model18 = import2.model(basic.ImageButton, ux.Button)

function model18.init()
	return {
		Size = UDim2.new(1, 0, 1, 0),
		Image = import8.Time,
		MouseButton1Down = function(_)
			import.remoteFire("purchaseTimeBoost")
		end
	}, {
		TimeBoostLabel = import2.make(basic.TextLabel, {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 0.4, 0),
			StrokeWidth = 3,
			Text = "+7 SECS"
		}),
		Count = import2.make(import2.wrap(basic.TextLabel, react.LinkedText), {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(-0.1, 0, 1, 0),
			Size = UDim2.new(0.4, 0, 0.4, 0),
			StrokeWidth = 3,
			KeyChains = { "Statistics.TimeBoost" },
			TextSavedChanged = function(_, p)
				return string.format("(%s)", p.Statistics.TimeBoost)
			end
		})
	}
end

function model18:prespawn()
	self.Con = import.remoteConnect("timeBoostDenied", function()
		import2.mount(import2.make(model12, {
			Text = "2 TIME BOOSTS PER ROUND!"
		}), self.Ui.Instance)
	end)
end

function model18.despawn(p)
	import.disconnect(p.Con)
end

local model19 = import2.model(basic.ConstrainedElement, basic.EmptyList)

function model19.init()
	return {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(0.99, 0, 0.9, 0),
		AspectRatio = 2.2,
		Scale = v and 0.15 or 0.175,
		Padding = UDim.new(0.05, 0),
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Bottom
	}, {
		TimerButton = import2.make(model18)
	}
end

local model20 = import2.model("ImageButton")

function model20.init(p)
	return {
		BackgroundTransparency = 1,
		Size = UDim2.new(1.2, 0, 1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		MouseEnter = function(p2)
			p2.ImageLabel.BackgroundColor3 = Color3.fromRGB(187.20000000000002, 187.20000000000002, 187.20000000000002)
		end,
		MouseLeave = function(p2)
			p2.ImageLabel.BackgroundColor3 = Color3.fromRGB(234, 234, 234)
		end,
		MouseButton1Down = function(_)
			if p.Key == "Enter" then
				import.fire("tryAnswer")
			else
				import.fire("tryKeystroke", p.Key == "Back" and -1 or p.Key)
			end
		end
	}, {
		ImageLabel = import2.make(basic.Corner, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0.9, 0, 0.9, 0),
			BackgroundColor3 = Color3.fromRGB(226, 226, 226)
		}, {
			Shadow = import2.make(basic.Corner, {
				ZIndex = -1,
				Position = UDim2.new(0, 0, 0.02, 0),
				Size = UDim2.new(1, 0, 1, 0)
			}),
			TextLabel = import2.make(basic.TextLabel, {
				ZIndex = 2,
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0.35, 0),
				Size = UDim2.new(0.9, 0, 0.5, 0),
				Text = string.lower(p.Key),
				TextColor3 = Color3.new(0, 0, 0),
				Font = Enum.Font.SourceSans
			})
		})
	}
end

local model21 = import2.model(basic.EmptyElement)

function model21.init(p)
	return {
		Size = UDim2.new(1, 0, 0.3333333333333333, 0)
	}, {
		Inner = import2.make(basic.EmptyList, {
			Position = UDim2.new(p.Offset or 0, 0, 0, 0),
			Size = UDim2.new(1, 0, 1, 0),
			VerticalAlignment = Enum.VerticalAlignment.Center
		}, import3.mapArr(p.Keys, function(p2, p3)
			return p2, import2.make(model20, {
				Key = p3
			})
		end))
	}
end

local model22 = import2.model(basic.ConstrainedElement, basic.EmptyList)
model22.Layouts = {
	Qwerty = {
		{
			"Q",
			"W",
			"E",
			"R",
			"T",
			"Y",
			"U",
			"I",
			"O",
			"P",
			"Back"
		},
		{
			"A",
			"S",
			"D",
			"F",
			"G",
			"H",
			"J",
			"K",
			"L",
			"Enter"
		},
		{
			"Z",
			"X",
			"C",
			"V",
			"B",
			"N",
			"M",
			",",
			"."
		}
	}
}
local v4 = { 0, 0.05, 0.1 }

function model22.init()
	local v5 = TABLET and 0.99 or 0.9
	return {
		BackgroundTransparency = 1,
		Visible = true,
		AspectRatio = 4.3999999999999995,
		Location = "Center",
		Size = UDim2.new(v5, 0, v5, 0),
		FillDirection = Enum.FillDirection.Vertical
	}, import3.mapArr(model22.Layouts.Qwerty, function(p, keys)
		return p, import2.make(model21, {
			Keys = keys,
			Offset = v4[p]
		})
	end)
end

local model23 = import2.model(basic.EmptyElement)

function model23.init()
	local v5 = {
		Location = "BottomCenter",
		Size = UDim2.new(1, 0, 0.15, 0)
	}
	local v6 = {
		LifeBar = import2.make(model17),
		TimeBar = import2.make(model19),
		CenterBar = 0,
		Keyboard = 0
	}
	local centerBar

	if not v then
		centerBar = import2.make(model15) or nil
	end

	v6.CenterBar = centerBar
	v6.Keyboard = v and import2.make(model22) or nil
	return v5, v6
end

local model24 = import2.model(basic.EmptyElement)

function model24.init()
	return {
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, TABLET and 0.35 or 0.5, 0),
		BackgroundTransparency = 0.75,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0
	}, {
		LifeBar = import2.make(model17, {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(TABLET and 0.01 or 0.05, 0, -0.025, 0),
			Scale = TABLET and 0.2 or 0.125
		}),
		TimeBar = import2.make(model19, {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(TABLET and 0.99 or 0.94, 0, -0.04, 0),
			Size = UDim2.new(1, 0, 1, 0)
		}),
		Timer = import2.make(model11, {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(TABLET and 0 or 0.065, 0, TABLET and -0.45 or -0.35, 0),
			Size = UDim2.new(1, 0, TABLET and 0.5 or 0.4, 0)
		}) or nil,
		Keyboard = import2.make(model22) or nil,
		Strikes = PHONE and import2.make(model14, {
			Position = UDim2.new(0.5, 0, 0, 0),
			AnchorPoint = Vector2.new(0.5, 1),
			Size = UDim2.new(0.075, 0, 0.25, 0)
		}) or nil
	}
end

local model25 = import2.model(basic.EmptyElement)

function model25.init()
	return {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 1, 0)
	}, {
		Strikes = import2.make(model14, {
			Size = UDim2.new(1, 0, 1, 0),
			FillDirection = Enum.FillDirection.Vertical
		})
	}
end

local model26 = import2.model(basic.EmptyElement)

function model26.init()
	return {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(0.98, 0, 0.35, 0),
		Size = UDim2.new(0.05, 0, 0.55, 0)
	}, {
		CenterBar = import2.make(model25)
	}
end

local model27 = import2.model(basic.Corner, basic.ConstrainedElement)

function model27.init(p)
	return {
		CornerRadius = UDim.new(1, 0),
		BackgroundColor3 = Color3.new(1, 1, 1)
	}, {
		Inner = import2.make(basic.Corner, {
			CornerRadius = UDim.new(1, 0),
			Location = "Center",
			Size = UDim2.new(0.9, 0, 0.9, 0),
			BackgroundColor3 = Color3.new(0.635294, 0.6, 0.988235),
			ClipsDescendants = false
		}, {
			Inner = import2.make(basic.Corner, {
				CornerRadius = UDim.new(1, 0),
				Location = "Center",
				Size = UDim2.new(0.91, 0, 0.91, 0),
				BackgroundColor3 = Color3.new(0.666667, 0.635294, 0.988235),
				ClipsDescendants = false
			}),
			Image = import2.make(basic.ImageLabel, {
				Image = p.Icon,
				Location = "Center",
				Size = UDim2.new(1.01, 0, 1.01, 0)
			})
		}),
		Shadow = import2.make(basic.Corner, {
			CornerRadius = UDim.new(1, 0),
			ZIndex = -1,
			Position = UDim2.new(0, 0, 0.05, 0),
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(0.133333, 0.180392, 0.560784)
		})
	}
end

local model28 = import2.model(basic.ImageLabel)

function model28.init(data)
	return {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(-0.5, 0, 0.7, 0),
		AspectRatio = 3,
		Scale = v and 0.6 or 0.3,
		Visible = false,
		ZIndex = 20
	}, {
		OuterStroke = import2.make(basic.Corner, {
			CornerRadius = UDim.new(0.11, 0),
			Position = UDim2.new(0.01, 0, 0.043, 0),
			Size = UDim2.new(0.981, 0, 0.895, 0),
			ZIndex = -10,
			BackgroundTransparency = 0.8,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		}, {
			TextBox = import2.make(basic.EmptyList, {
				Position = UDim2.new(0.29, 0, 0, 0),
				Size = UDim2.new(0.7, 0, 1, 0),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0.05, 0)
			}, {
				TitleText = import2.make(basic.TextLabel, {
					LayoutOrder = 1,
					Size = UDim2.new(1, 0, 0.3, 0),
					RichText = true,
					Text = string.format("Activated: <font color=\"rgb(251,224,0)\">%s</font>", data.AbilityName),
					StrokeWidth = 3
				}),
				Effect = import2.make(basic.EmptyList, {
					LayoutOrder = 2,
					Size = UDim2.new(1, 0, 0.3, 0),
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0.02, 0)
				}, {
					Icon = import2.make(basic.ImageLabel, {
						Size = UDim2.new(1, 0, 1, 0),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Image = import8.Time
					}),
					Text = import2.make(basic.TextLabel, {
						LayoutOrder = 2,
						Size = UDim2.new(0.7, 0, 0.8, 0),
						Text = data.AbilityDescription,
						StrokeWidth = 3,
						Color3.new(0.984314, 0.878431, 0)
					})
				})
			}),
			CircleIcon = import2.make(model27, {
				Size = UDim2.new(0.85, 0, 0.85, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.18, 0, 0.5, 0),
				Icon = data.CatalystIcon
			})
		})
	}
end

function model28:prespawn()
	self.Visible = true
	self:tween(TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(-0.01, 0, 0.7, 0)
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRankFromUserId(userId)
	local playerByUserId = Players:GetPlayerByUserId(userId)
	return playerByUserId and playerByUserId:GetAttribute("RankedRankId") or "Unranked"
end

local function getRankedPlayerStates()
	local rankedPlayerIds = workspace:GetAttribute("RankedPlayerIds")

	if not rankedPlayerIds then
		return {}
	end

	local jSONDecode = HttpService:JSONDecode(rankedPlayerIds)
	return import3.fromArray(jSONDecode):map(function(p, userId)
		return p, {
			UserId = userId
		}
	end):dict()
end

local model29 = import2.model(basic.EmptyList)

function model29.init(p)
	local rankFromUserId = getRankFromUserId(p.UserId) -- equivalent call inferred; original call site unknown
	local v5 = {
		Name = tostring(p.UserId),
		Size = UDim2.new(1, 0, 1, 0),
		LayoutOrder = p.LayoutOrder,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0.04, 0),
		BackgroundTransparency = 1,
		UserId = p.UserId
	}
	local v6 = {
		AvatarFrame = import2.make(basic.EmptyElement, {
			Size = UDim2.new(1, 0, 1, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			LayoutOrder = 2
		}, {
			Avatar = import2.make(avatar, {
				Size = UDim2.new(1, 0, 1, 0),
				UserId = p.UserId
			})
		}),
		RankIcon = 0
	}
	local rankIcon

	if rankFromUserId ~= "Unranked" then
		rankIcon = import2.make("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1.4, 0, 1.4, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			LayoutOrder = 1,
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 20
		}) or nil
	end

	v6.RankIcon = rankIcon
	return v5, v6
end

function model29:render()
	local rankFromUserId = getRankFromUserId(self.UserId) -- equivalent call inferred; original call site unknown
	local v5 = import9[rankFromUserId] or import9.Unranked
	self.RankIcon.Image = v5.Icon
end

function model29:spawn()
	if not self.RankIcon then
		return
	end

	self:render()
end

local model30 = import2.model(basic.EmptyList, basic.ConstrainedElement)

function model30.init(options)
	local playerStates = (options or {}).PlayerStates or {}
	local count = #playerStates
	return {
		Name = "RankedPlayerBar",
		AnchorPoint = Vector2.new(1, 0),
		AspectRatio = 2.5,
		Position = UDim2.new(v and 0.965 or 0.985, 0, (TABLET or not v) and 0.035 or 0.01, 0),
		Size = UDim2.new(v and 0.075 or 0.08, 0, 1, 0),
		FillDirection = Enum.FillDirection[v2 and "Vertical" or "Horizontal"],
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(v2 and 0.3 or 0.1, 0),
		Visible = count > 0,
		PlayerStates = playerStates,
		ZIndex = 20
	}, import3.gen(count, function(layoutOrder)
		local playerState = playerStates[layoutOrder]
		return tostring(playerState.UserId), import2.make(model29, {
			LayoutOrder = layoutOrder,
			UserId = playerState.UserId
		})
	end)
end

local model31 = import2.model("ScreenGui", basic.Ui)

local function renderNotes(state)
	state.HintInput:clear()

	for _, v5 in ipairs(state.Notes or {}) do
		state.HintInput:push(v5)
	end
end

local function updateVisibility(data)
	local prompt = data.Prompt
	local v5 = prompt and prompt.Choices ~= nil
	local invisible = data.Invisible
	local isTurn = localPlayer:GetAttribute("IsTurn")
	data.TopBar.Visible = not invisible
	local rankedPlayerBar = data.RankedPlayerBar
	rankedPlayerBar.Visible = #(data.PlayerStates or {}) > 0 and not invisible
	local hintInput = data.HintInput
	hintInput.Visible = #(data.Notes or {}) > 0 and not (v5 or invisible)
	data.ChoiceList.Visible = v5 and not invisible
	data.TopBar.AnswerInput.Visible = not (v5 or invisible)
	data.BottomBar.TimeBar.Visible = not v5 and isTurn and not invisible
	local v8 = v5 or not isTurn or invisible

	if v then
		data.BottomBar:tween(TweenInfo.new(0.15, Enum.EasingStyle.Cubic), {
			AnchorPoint = v8 and Vector2.new(0, 0) or Vector2.new(0, 1)
		})
		data.BottomBar.Timer.Visible = not invisible
	else
		data.BottomBar.CenterBar.Visible = not invisible
	end

	if PHONE then
		data.Ui.Strikes.Size = v8 and UDim2.new(0.075, 0, 0.4, 0) or UDim2.new(0.075, 0, 0, 0)
	end
end

function model31.init(options)
	TABLET = v and workspace.CurrentCamera.ViewportSize.X / workspace.CurrentCamera.ViewportSize.Y < 1.5
	PHONE = v and not TABLET

	if plugin then
		v = false
		TABLET = false
	end

	print("[DOF TRACE] gameplayWindow.init mounting DepthOfFieldEffect")
	local playerStates = (options or {}).PlayerStates or getRankedPlayerStates()
	return {
		IgnoreGuiInset = true,
		DepthOfField = import2.mount(import2.make("DepthOfFieldEffect"), game.Lighting),
		ScreenInsets = PHONE and Enum.ScreenInsets.None or Enum.ScreenInsets.DeviceSafeInsets,
		PlayerStates = playerStates
	}, {
		BottomBar = import2.make(v and model24 or model23),
		TopBar = import2.make(model7),
		RankedPlayerBar = import2.make(model30, {
			PlayerStates = playerStates
		}),
		HintInput = import2.make(model4),
		ChoiceList = import2.make(model9),
		RightBar = TABLET and import2.make(model26) or nil
	}
end

function model31:question(prompt, p, value)
	self.Ui.RoundEnded = false
	self.Ui.Strikes:update(value or 0)
	self.Prompt = prompt
	self.Question:update(prompt)
	self.Timer:time(p)
	task.defer(function()
		if prompt.Choices then
			self.QueuedNotes = {}
			self.Notes = {}
			self.ChoiceList:updateChoices(prompt.Choices)
		else
			self.Notes = self.QueuedNotes or {}
			self.QueuedNotes = {}
			self.TopBar.AnswerInput:reset(prompt.RequiredLetter)
		end

		renderNotes(self)
		updateVisibility(self)
	end)
end

function model31:note(p)
	self.QueuedNotes = self.QueuedNotes or {}
	self.Notes = self.Notes or {}
	table.insert(self.QueuedNotes, p)
	table.insert(self.Notes, p)
	task.defer(function()
		renderNotes(self)
		updateVisibility(self)
	end)
end

function model31:hint(p)
	self:note("<font size=\"5\">hint:</font> " .. (not self.Prompt and "" or self.Prompt.RequiredLetter or "") .. p)
end

function model31:setHealth(p2)
	self.BottomBar.LifeBar:setHealth(p2)
end

function model31:setInvisible(invisible)
	self.Invisible = invisible
	updateVisibility(self)
end

function model31:setAbilityPopup(data)
	if self.AbilityPopup then
		self.AbilityPopup:Destroy()
		self.AbilityPopup = nil
	end

	if not data then
		return
	end

	local v5 = v3:get(data.AbilityId)
	local abilityConfig = data.AbilityConfig or {}
	self.AbilityPopup = import2.make(model28, {
		AbilityName = abilityConfig.DisplayName or v5.Info.DisplayName,
		AbilityDescription = abilityConfig.Description or v5.Info.Description,
		CatalystIcon = import7:getItem("Pet", data.CatalystId).Icon
	})
	import2.apply(self, nil, {
		AbilityPopup = self.AbilityPopup
	})
	import6.sound("Special10")
end

function model31:prespawn()
	if plugin then
		self.ScreenInsets = PHONE and Enum.ScreenInsets.None or Enum.ScreenInsets.DeviceSafeInsets
		self.BottomBar.AnchorPoint = Vector2.new(0, 1)
	end

	task.spawn(function()
		if plugin or not v then
			return
		end

		localPlayer.PlayerGui.TouchGui.TouchControlFrame.JumpButton.Visible = false
	end)
end

function model31.despawn(p)
	p.DepthOfField:Destroy()

	if plugin then
		return
	end

	local touchGui = localPlayer.PlayerGui:FindFirstChild("TouchGui")

	if not touchGui then
		return
	end

	touchGui.TouchControlFrame.JumpButton.Visible = true
end

return {
	GameplayWindow = model31,
	AbilityPopup = model28,
	AnswerInput = model5,
	HintInput = model4
}