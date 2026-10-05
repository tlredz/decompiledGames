local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- equivalent calls inferred from this helper; original call sites unknown
local function Darken(original: Color3, p: number)
	return Color3.new(original.R * p, original.G * p, original.B * p)
end

local object = setmetatable({}, {
	__mode = "k"
})

local function CaptureColors(instance)
	local v = {}

	if instance:IsA("GuiObject") then
		v.BackgroundColor3 = {
			Original = instance.BackgroundColor3
		}
	end

	if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
		v.ImageColor3 = {
			Original = instance.ImageColor3
		}
	end

	if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
		v.TextColor3 = {
			Original = instance.TextColor3
		}
	end

	return v
end

local function Setup(button)
	if not (button:IsA("ImageButton") and button:IsDescendantOf(playerGui)) or object[button] then
		return
	end

	object[button] = true
	button.AutoButtonColor = false
	local v = false
	local v2 = false
	local v3 = nil

	local function Capture()
		v3 = {}
		v3[button] = CaptureColors(button)

		for _, descendant in button:GetDescendants() do
			v3[descendant] = CaptureColors(descendant)
		end
	end

	local function Update()
		if not v3 then
			return
		end

		local v4 = v2 and 0.65 or v and 0.85 or 1

		for k, v5 in v3 do
			if not (k == button or k.Parent) then
				continue
			end

			for k2, v6 in v5 do
				local original = k[k2]

				if v6.Written and original ~= v6.Written then
					v6.Original = original
				end

				local written = Darken(v6.Original, v4) -- equivalent call inferred; original call site unknown
				k[k2] = written
				v6.Written = written
			end
		end

		if v4 == 1 then
			v3 = nil
		end
	end

	button.MouseEnter:Connect(function()
		if not (v or v3) then
			Capture()
		end

		v = true
		Update()
	end)
	button.MouseLeave:Connect(function()
		v = false
		v2 = false
		Update()
	end)
	button.SelectionGained:Connect(function()
		if not (v or v3) then
			Capture()
		end

		v = true
		Update()
	end)
	button.SelectionLost:Connect(function()
		v = false
		v2 = false
		Update()
	end)
	button.MouseButton1Down:Connect(function()
		if not v3 then
			Capture()
		end

		v2 = true
		Update()
	end)
	button.MouseButton1Up:Connect(function()
		v2 = false
		Update()
	end)
end

for _, v in CollectionService:GetTagged("Darken") do
	Setup(v)
end

CollectionService:GetInstanceAddedSignal("Darken"):Connect(Setup)