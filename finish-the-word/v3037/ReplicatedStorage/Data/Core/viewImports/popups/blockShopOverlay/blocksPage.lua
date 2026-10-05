local createVector = vector.create
local import = _G.import("romodel")
local import2 = _G.import("event")
local import3 = _G.import("sync")
local import4 = _G.import("global")
local import5 = _G.import("eggCollection")
local import6 = _G.import("mathUtil")
local import7 = _G.import("viewImports")
local basic = import7:get("basic")
local menu = import7:get("menu")
local ux = import7:get("ux")
local eggBillboard = import7:get("eggBillboard")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local localPlayer = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local eggs = game.ReplicatedStorage.ReplicatedAssets.Eggs
local v = {
	"New",
	"Furry",
	"Starter",
	"Expensive"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getOrigin()
	return workspace.Meta.Shop:FindFirstChild("Origin")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCamCFrame(currentIndex)
	local origin = getOrigin() -- equivalent call inferred; original call site unknown

	if not origin then
		return currentCamera.CFrame
	end

	local rightVector = origin.CFrame.RightVector
	local lookVector = origin.CFrame.LookVector
	local v2 = origin.Position - rightVector * ((currentIndex - 1) * 12)
	return CFrame.lookAt(v2 + createVector(0, 2, 0) + lookVector * 7, v2 + createVector(0, 1.5, 0))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isUnlocked(p)
	return import4.get("playerSave", localPlayer).Eggs[p]
end

local function buildButtons(p)
	local v2 = import5:get(p)
	local unlocked = isUnlocked(p) -- equivalent call inferred; original call site unknown
	local lastTime = tick()

	if unlocked then
		return import.make(eggBillboard.ButtonBar, {
			NoInput = true,
			Position = UDim2.new(0.5, 0, 0.8, 0),
			Size = UDim2.new(0.4, 0, 0.125, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			HorizontalAlignment = Enum.HorizontalAlignment.Center
		})
	end

	return import.make(import.wrap(menu.Button, basic.ConstrainedElement), {
		AspectRatio = 3.5,
		Position = UDim2.new(0.5, 0, 0.8, 0),
		Size = UDim2.new(0.2, 0, 0.1, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		Text = "Unlock",
		MouseButton1Down = function(p2)
			if tick() - lastTime < 0.05 then
				return
			end

			lastTime = tick()
			local parent = p2.Parent
			import3.request("unlockEgg", function()
				parent:setButtons(p)
			end, function(p3)
				if not p3 then
					return
				end

				if p3 == "Not enough cash" then
					import2.fire("openMenu", "Store", {
						PageId = "DeveloperProducts"
					})
				end

				import2.fire("signal", p3)
			end)(p)
		end
	}, {
		CostContainer = import.make(eggBillboard.CostContainer, {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Position = UDim2.new(0.5, 0, -1.25, 0),
			Size = UDim2.new(1, 0, 1, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			Cost = v2.UnlockCost,
			Currency = "Cash"
		})
	})
end

local model = import.model(basic.ImageButton, ux.Button, basic.Corner)

function model.init(data)
	return {
		NoAspectRatio = true,
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(30, 25, 50),
		Size = UDim2.new(0, 60, 0, 60),
		AnchorPoint = data.Anchor,
		Position = data.Position,
		CornerRadius = UDim.new(0.25, 0)
	}, {
		ButtonLabel = import.make(basic.TextLabel, {
			Location = "Center",
			Size = UDim2.new(0.7, 0, 0.7, 0),
			Text = data.Label,
			StrokeWidth = 3
		})
	}
end

local model2 = import.model(eggBillboard.Container)

function model2.init(p)
	return {
		BackgroundTransparency = 0,
		Position = UDim2.new(0.985, 0, 0.024, 0),
		Size = UDim2.new(0.25, 0, 0.4, 0),
		AnchorPoint = Vector2.new(1, 0),
		EggData = p.EggData,
		EggId = p.EggId,
		NoButtons = true
	}
end

local model3 = import.model(basic.Viewport)

function model3.init(p)
	local child = eggs:FindFirstChild(p.Id)
	return {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		LightColor = Color3.new(1, 1, 1)
	}, {
		Camera = import.make("Camera", {
			FieldOfView = 45
		}),
		World = import.make("WorldModel", nil, child and {
			Egg = import.make(child:Clone(), {})
		} or nil)
	}
end

function model3:prespawn()
	local instance = self.Instance
	local instance2 = self.Camera.Instance
	local instance3 = self.World.Egg.Instance

	if not instance3 then
		return
	end

	instance.CurrentCamera = instance2
	local boundingBox, v2 = instance3:GetBoundingBox()
	local v3 = math.max(v2.X, v2.Y, v2.Z)
	self.Spinning = true
	instance2.CFrame = CFrame.lookAt(boundingBox.Position + Vector3.new(0, v3 * 0.2, v3 * 2.2), boundingBox.Position)
	local egg = instance3.Egg
	local cFrame = egg.CFrame
	task.spawn(function()
		while self.Spinning do
			task.wait(0)
			local vectorToObjectSpace = egg.PivotOffset:Inverse():VectorToObjectSpace(createVector(0, 1, 0))
			egg.CFrame = cFrame * CFrame.fromAxisAngle(vectorToObjectSpace, os.clock() * 2)
		end
	end)
end

function model3:despawn()
	self.Spinning = false
end

local model4 = import.model(basic.ImageButton, ux.Button, basic.Corner, basic.Stroke)

function model4.init(p)
	return {
		Scale = 0.4,
		BackgroundColor3 = Color3.fromRGB(18, 14, 30),
		BackgroundTransparency = 0,
		CornerRadius = UDim.new(0.15, 0),
		StrokeWidth = 2,
		MouseButton1Down = function(p2)
			for k, v2 in pairs(v) do
				if v2 == p.Id then
					p2.Parent.Parent:navigate(k)
				end
			end
		end
	}, {
		Viewport = import.make(model3, {
			Id = p.Id
		})
	}
end

local model5 = import.model(basic.EmptyList, basic.ConstrainedElement, basic.Padding)

function model5.init()
	local result = {}

	for i, id in ipairs(v) do
		result[i] = import.make(model4, {
			Id = id,
			LayoutOrder = i
		})
	end

	return {
		AspectRatio = 0.75,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(0.98, 0, 0.97, 0),
		Size = UDim2.new(0.1875, 0, 0.25, 0),
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0.1, 0),
		Wraps = true
	}, result
end

local model6 = import.model(basic.EmptyElement)

function model6.init()
	local eggId = v[1]
	local eggData = import5:get(eggId)
	local _ = isUnlocked(eggId) -- equivalent call inferred; original call site unknown
	return {
		Size = UDim2.new(1, 0, 1, 0),
		CurrentIndex = 1
	}, {
		DisplayName = import.make(basic.TextLabel, {
			Position = UDim2.new(0.5, 0, 0.2, 0),
			Size = UDim2.new(1, 0, 0.05, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			Text = eggData.DisplayName,
			StrokeWidth = 2
		}),
		LeftButton = import.make(model, {
			Label = "<",
			Anchor = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 20, 0.5, 0),
			MouseButton1Down = function(p)
				local parent = p.Parent
				parent:navigate(parent.CurrentIndex - 1)
			end
		}),
		RightButton = import.make(model, {
			Label = ">",
			Anchor = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -20, 0.5, 0),
			MouseButton1Down = function(p)
				local parent = p.Parent
				parent:navigate(parent.CurrentIndex + 1)
			end
		}),
		Foo = import.make(model2, {
			EggData = eggData,
			EggId = eggId
		}),
		ShortcutList = import.make(model5)
	}
end

function model6:setButtons(p)
	local v2 = import5:get(p)
	local unlocked = isUnlocked(p) -- equivalent call inferred; original call site unknown

	if self.Buttons then
		self.Buttons:Destroy()
	end

	if self.CostContainer then
		self.CostContainer:Destroy()
	end

	import.apply(self, nil, {
		CostContainer = unlocked and import.make(eggBillboard.CostContainer, {
			BackgroundTransparency = 1,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Position = UDim2.new(0.5, 0, 0.725, 0),
			Size = UDim2.new(0.2, 0, 0.075, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Cost = import6.formatNumber(v2.Cost),
			Currency = v2.Currency
		}) or nil,
		Buttons = buildButtons(p)
	})

	if unlocked and self.Buttons then
		self.Buttons.OnOpen = self.OpenEgg
	end
end

function model6:navigate(currentIndex)
	if currentIndex < 1 or #v < currentIndex then
		return
	end

	self.CurrentIndex = currentIndex
	local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local camCFrame = getCamCFrame(currentIndex) -- equivalent call inferred; original call site unknown
	TweenService:Create(currentCamera, tweenInfo, {
		CFrame = camCFrame
	}):Play()
	local eggId = v[currentIndex]
	local eggData = import5:get(eggId)

	if self.Foo then
		self.Foo:Destroy()
	end

	import.apply(self, nil, {
		Foo = import.make(model2, {
			EggData = eggData,
			EggId = eggId
		})
	})
	self.DisplayName.Text = eggData.DisplayName
	self:setButtons(eggId)
end

function model6:prespawn()
	if self.ActiveModels then
		return
	end

	local origin = getOrigin() -- equivalent call inferred; original call site unknown

	if not origin then
		return
	end

	local rightVector = origin.CFrame.RightVector
	local shop = workspace.Meta.Shop
	local activeModels3 = {}

	for k, childName in pairs(v) do
		local child = eggs:FindFirstChild(childName)

		if not child then
			continue
		end

		local clone = child:Clone()
		clone.Parent = shop
		local v3 = origin.Position - rightVector * ((k - 1) * 12)
		local boundingBox, v4 = clone:GetBoundingBox()
		local v5 = clone:GetPivot().Position.Y - (boundingBox.Position.Y - v4.Y / 2)
		clone:PivotTo(CFrame.new(v3 + Vector3.new(0, v5, 0)))
		table.insert(activeModels3, {
			Model = clone,
			Base = v3 + Vector3.new(0, v5, 0),
			Phase = (k - 1) * 1.3
		})
	end

	self.ActiveModels = activeModels3

	function self.OpenEgg(p)
		if not self.Foo then
			return
		end

		local activeModels = self.ActiveModels or {}
		self.Foo:openEgg(p, function()
			local activeModels2 = self.ActiveModels or {}

			for _, activeModel in pairs(activeModels2) do
				for _, part in pairs(activeModel.Model:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Transparency = 1
					end
				end
			end

			self.Visible = false
		end, function()
			for _, activeModel in pairs(activeModels) do
				for _, part in pairs(activeModel.Model:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Transparency = 0
					end
				end
			end

			self.Visible = true
		end)
	end

	if self.Buttons and isUnlocked(v[1]) then
		self.Buttons.OnOpen = self.OpenEgg
	end

	self.PrevCameraType = currentCamera.CameraType
	currentCamera.CameraType = Enum.CameraType.Scriptable
	local currentCamera2 = currentCamera
	local origin2 = getOrigin() -- equivalent call inferred; original call site unknown
	local cframe

	if origin2 then
		local rightVector2 = origin2.CFrame.RightVector
		local lookVector = origin2.CFrame.LookVector
		local v4 = origin2.Position - rightVector2 * 0
		cframe = CFrame.lookAt(v4 + createVector(0, 2, 0) + lookVector * 7, v4 + createVector(0, 1.5, 0))
	else
		cframe = currentCamera.CFrame
	end

	currentCamera2.CFrame = cframe
	local total = 0
	self.BobCon = RunService.RenderStepped:Connect(function(dt)
		total += dt

		for _, v4 in pairs(activeModels3) do
			local v5 = math.sin(total * 2 + v4.Phase) * 0.35
			v4.Model:PivotTo(CFrame.new(v4.Base + Vector3.new(0, v5, 0)) * CFrame.Angles(
				0,
				total * 0.6108652381980153,
				math.sin(total * 1.6 + v4.Phase) * 0.17453292519943295
			))
		end
	end)
	self:setButtons(v[1])
end

function model6.despawn(data)
	if data.BobCon then
		data.BobCon:Disconnect()
	end

	if data.Buttons and data.Buttons.InputCon then
		data.Buttons.InputCon:Disconnect()
	end

	for _, v2 in pairs(data.ActiveModels or {}) do
		v2.Model:Destroy()
	end

	currentCamera.CameraType = data.PrevCameraType or Enum.CameraType.Custom
end

return {
	BlocksPage = model6
}