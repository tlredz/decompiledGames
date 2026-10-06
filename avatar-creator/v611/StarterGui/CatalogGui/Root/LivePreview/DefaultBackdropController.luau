local createVector = vector.create
local parent = script.Parent
local defaultBackdrop = parent:WaitForChild("DefaultBackdrop")
local camera = defaultBackdrop:FindFirstChildOfClass("Camera") or Instance.new("Camera", defaultBackdrop)
camera.FieldOfView = 48
camera.CFrame = CFrame.lookAt(createVector(0, 5, 17), createVector(0, 2, -3))
defaultBackdrop.CurrentCamera = camera
local avatar = parent:WaitForChild("Avatar")

-- equivalent calls inferred from this helper; original call sites unknown
local function fit()
	defaultBackdrop.Position = avatar.Position
	defaultBackdrop.Size = avatar.Size
end

avatar:GetPropertyChangedSignal("Position"):Connect(fit)
avatar:GetPropertyChangedSignal("Size"):Connect(fit)

local function bind(image)
	if image.Name ~= "LookBackdrop" or not image:IsA("ImageLabel") then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function visibility()
		defaultBackdrop.Visible = not image.Visible or image.Image == ""
	end

	image:GetPropertyChangedSignal("Visible"):Connect(visibility)
	image:GetPropertyChangedSignal("Image"):Connect(visibility)
	visibility() -- equivalent call inferred; original call site unknown
end

parent.ChildAdded:Connect(bind)

for _, child in parent:GetChildren() do
	bind(child)
end

fit() -- equivalent call inferred; original call site unknown