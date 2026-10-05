local import = _G.import("romodel")
local GuiService = game:GetService("GuiService")
local basic = _G.import("viewImports"):get("basic")
local v = false
local volume = 0
local volumeChangedConnection = nil
local model = import.model(basic.ImageButton, basic.Corner)

function model.init(data)
	local v2 = false
	return {
		BackgroundColor3 = Color3.fromRGB(18, 18, 21),
		BackgroundTransparency = 0.08,
		Size = UDim2.new(1, 0, 1, 0),
		CornerRadius = UDim.new(1, 0),
		MouseButton1Down = data.ToggledIcon and (function(p)
			v2 = not v2
			p.Instance.Icon.Image = v2 and data.ToggledIcon or data.Icon
			data.OnToggle(v2)
		end or nil) or nil,
		_Events = {
			MouseEnter = function(p)
				p.Highlighter.BackgroundTransparency = 0.92
			end,
			MouseLeave = function(p)
				p.Highlighter.BackgroundTransparency = 1
			end
		}
	}, {
		Highlighter = import.make(basic.Corner, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 36, 0, 36),
			BackgroundColor3 = Color3.fromRGB(208, 217, 251),
			BackgroundTransparency = 1,
			CornerRadius = UDim.new(1, 0)
		}),
		Icon = import.make(basic.ImageLabel, {
			Location = "Center",
			Scale = 0.6,
			Image = data.Icon
		})
	}
end

local model2 = import.model(model)

-- equivalent calls inferred from this helper; original call sites unknown
local function getSound()
	return workspace:FindFirstChildOfClass("Sound")
end

function model2.init()
	return {
		Icon = "rbxassetid://73352363465668",
		ToggledIcon = "rbxassetid://77294144685290",
		OnToggle = function(p)
			local sound = getSound() -- equivalent call inferred; original call site unknown

			if not sound then
				return
			end

			v = p

			if v then
				volume = sound.Volume
				sound.Volume = 0
				volumeChangedConnection = sound:GetPropertyChangedSignal("Volume"):Connect(function()
					if sound.Volume == 0 then
						return
					end

					volume = sound.Volume
					sound.Volume = 0
				end)
			else
				if volumeChangedConnection then
					volumeChangedConnection:Disconnect()
					volumeChangedConnection = nil
				end

				sound.Volume = volume
			end
		end
	}
end

local model3 = import.model(basic.EmptyList)

function model3:updateInset()
	local guiInset = GuiService:GetGuiInset()
	local v2 = plugin and 56 or guiInset.Y
	self.Size = UDim2.new(1, guiInset.X, 0, v2)
end

function model3.init()
	return {
		Position = UDim2.new(0, 215, 0, 0),
		Size = UDim2.new(1, 0, 0, 0),
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 6)
	}, {
		MuteButton = import.make(model2, {
			Size = UDim2.new(0.8, 0, 0.8, 0)
		})
	}
end

function model3:spawn()
	self:updateInset()
	self.InsetConnection = GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(function()
		self:updateInset()
	end)
end

function model3.despawn(p)
	p.InsetConnection:Disconnect()
end

local model4 = import.model("ScreenGui")

function model4.init()
	return {
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		Name = "TopBar",
		DisplayOrder = 6
	}, {
		Buttons = import.make(model3)
	}
end

return {
	TopBar = model4
}