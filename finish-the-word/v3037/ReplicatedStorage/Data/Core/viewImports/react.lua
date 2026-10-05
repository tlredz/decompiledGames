local import = _G.import("event")
local import2 = _G.import("romodel")
local import3 = _G.import("global")
local basic = _G.import("viewImports"):get("basic")
local import4 = _G.import("dictUtil")
local import5 = _G.import("savedState")
local import6 = _G.import("sessionState")
local RunService = game:GetService("RunService")
local element = basic.Element
local imageButton = basic.ImageButton
local textLabel = basic.TextLabel
local model = import2.model(element)
model.Connected = {
	sessionState = {},
	savedState = {}
}

function model.init(p)
	return {
		ReactiveChildren = {},
		KeyChains = p.KeyChains
	}
end

function model:ClearReactiveChildren()
	for _, v in pairs(self.ReactiveChildren) do
		v:Destroy()
	end

	self.ReactiveChildren = nil
end

function model:apply(callback, p2, p3, p4, p5)
	local v, reactiveChildren = callback(self, p2, p3, p4, p5)
	self.ReactiveChildren = reactiveChildren
	import2.apply(self, v, reactiveChildren)
end

function model:connect(p, p2)
	local v = p == "sessionState"
	local playerSession

	if plugin or not RunService:IsServer() then
		playerSession = v and _G.playerSession or _G.playerSave

		if plugin then
			local v2 = newproxy(true)
			getmetatable(v2).__index = {
				UserId = 1,
				ClassName = "Player",
				GetFullName = function()
					return "game.Players.HinataSpikes19"
				end
			}
			local v3 = playerSession or {}
			v3.DailyQuests = {
				Win3 = {
					Progress = 1,
					Claimed = false
				},
				Playtime15 = {
					Progress = 300,
					Claimed = false
				}
			}
			playerSession = import3.shell(v2, "savedState", "playerSave", v2, import5(v2, v3))
			local shell = import3.shell(v2, "sessionState", "playerSession", v2, import6(v2, playerSession))

			if v then
				playerSession = shell or playerSession
			end
		end
	elseif self.Player then
		playerSession = import3.get(v and "playerSession" or "playerSave", self.Player)
	else
		return
	end

	self:apply(p2, playerSession, self.KeyChains[1], true)
	local v2 = 0
	model.Connected[p][self] = import.connect("StateChanged", function(_, p3, _, p4, items)
		if p3 ~= p then
			return
		end

		local has, _ = import4.has(self.KeyChains, function(value)
			local v3 = string.split(value, ".")

			if #v3 == 0 then
				return false
			end

			for k, item in pairs(items) do
				if not v3[k] then
					break
				end

				if not string.match(item, v3[k]) then
					return false
				end
			end

			return true
		end)

		if not has then
			return
		end

		v2 += 1
		task.defer(function()
			v2 -= 1

			if v2 > 0 then
				return
			end

			self:apply(p2, playerSession, items, p4)
		end)
	end, {
		Blocking = true
	})
end

function model.spawn(p)
	if p.SessionChanged and not model.Connected.sessionState[p] then
		model.connect(p, "sessionState", p.SessionChanged)
	end

	if p.SavedChanged and not model.Connected.savedState[p] then
		model.connect(p, "savedState", p.SavedChanged)
	end
end

function model.despawn(p)
	local v = model.Connected.sessionState[p]
	local v2 = model.Connected.savedState[p]

	if v then
		import.disconnect(v)
		model.Connected.sessionState[p] = nil
	end

	if v2 then
		import.disconnect(v2)
		model.Connected.savedState[p] = nil
	end
end

local model2 = import2.model(model)

function model2:applyText(p, p2, p3)
	local textSavedChanged = self:TextSavedChanged(p, p2, p3)

	if self.setText then
		self:setText(textSavedChanged)
	else
		self.Text = textSavedChanged
	end
end

function model2.init(p, _)
	return {
		SavedChanged = p.TextSavedChanged and model2.applyText,
		SessionChanged = p.TextSessionChanged and model2.applyText
	}
end

local model3 = import2.model(model)

function model3.init(data)
	local key = data.Key
	local v = "Current" .. data.Key
	return {
		Size = UDim2.new(1, 0, 1, 0),
		Height = 1,
		MaxWidth = 1,
		MinWidth = 0,
		MaxValue = 1000,
		KeyChains = { "Character.Statistics." .. key, "Character.Statistics." .. v, "Statistics." .. key },
		SessionChanged = data.Key and function(object, player, _)
			local statistics = player.Character.Statistics
			local transformedStat = player:getTransformedStat(key)
			object.CurrentValue = statistics[v]
			object.MaxValue = transformedStat
			object.Fill:TweenSize(object:_getSize(), "Out", "Quad", 0.4, true)
			object.TextLabel.Text = object:_getString()
		end,
		SavedChanged = function(object, _, _, _)
			object.MaxValue = _G.playerSession:getTransformedStat(key)
			object.Fill:TweenSize(object:_getSize(), "Out", "Quad", 0.4, true)
			object.TextLabel.Text = object:_getString()
		end
	}, {
		Fill = import2.make("ImageLabel", {
			ZIndex = -1,
			AnchorPoint = data.FillAnchorPoint,
			Position = data.FillPosition,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = data.FillImage
		}),
		TextLabel = import2.make(textLabel, {
			Location = "Center",
			ZIndex = 2,
			Scale = 0.5,
			AspectRatio = 6.066666666666666,
			BackgroundTransparency = 1,
			TextScaled = true,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
			TextStrokeTransparency = 0,
			TextFont = Enum.Font.GothamSemibold
		})
	}
end

function model3:_getSize()
	return UDim2.new(self.CurrentValue / self.MaxValue * self.MaxWidth, 0, self.Height, 0)
end

function model3:_getString()
	return self.CurrentValue .. " | " .. self.MaxValue
end

function model3:prespawn()
	self.CurrentValue = self.MaxValue
	self.Fill.Size = self:_getSize()
	self.TextLabel.Text = self:_getString()
end

local model4 = import2.model(imageButton, model)

function model4.prespawn(p)
	return {
		KeyChains = { p.DisabledKey },
		SessionChanged = p.DisabledKey and function(data, p2, value)
			local disabled

			if value then
				disabled = p2

				for k in value:gmatch("[^%.]+") do
					if type(disabled) == "table" then
						disabled = disabled[k]
					else
						disabled = nil
						break
					end
				end
			else
				disabled = false
			end

			if disabled and disabled ~= 0 then
				local disabledOverlay = data.DisabledOverlay

				if disabledOverlay then
					disabledOverlay:Destroy()
				end

				return {
					Disabled = disabled
				}, {
					DisabledOverlay = import2.make(
						data.DisabledOverlayModel,
						data.DisabledOverlayProperties and data.DisabledOverlayProperties(p2, disabled),
						data.DisabledOverlayChildren
					)
				}
			else
				if data.DisabledOverlay then
					data.DisabledOverlay:discard()
				end

				return {
					Disabled = disabled
				}
			end
		end
	}
end

local model5 = import2.model(model4)

function model5.prespawn(p)
	return {
		MouseEnter = function(p2)
			local parent = p2.Parent

			for _, v in pairs(parent._Children) do
				if not v.TweenSize then
					continue
				end

				if v == p2 then
					v:TweenSize(p.MaxSize or UDim2.new(0.6, 0, 1.1, 0), "Out", "Quad", 0.1, true)
				else
					v:TweenSize(p.MinSize or UDim2.new(0.25, 0, 1, 0), "Out", "Quad", 0.1, true)
				end
			end
		end,
		MouseLeave = function(p2)
			local parent = p2.Parent

			for _, v in pairs(parent._Children) do
				if v.TweenSize then
					v:TweenSize(p.MinSize or UDim2.new(0.25, 0, 1, 0), "Out", "Quad", 0.1, false)
				end
			end
		end
	}
end

return {
	Reactive = model,
	StatFill = model3,
	Button = model4,
	ResizeHoverButton = model5,
	LinkedText = model2
}