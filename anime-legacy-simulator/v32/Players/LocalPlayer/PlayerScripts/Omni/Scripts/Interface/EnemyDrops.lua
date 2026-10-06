local createVector = vector.create
local module = require("@game/ReplicatedStorage/Omni")
local _ = {
	Position = createVector(0, -7.5, -7.5),
	Rotation = createVector(0, 0, 0)
}
local _ = {
	Position = createVector(0, -1.5, -4),
	Rotation = createVector(-0, 160, -0)
}
local fusion = module.Libs.Fusion
local scope = fusion.scoped(fusion)
local enemyDrops = module.Interface:WaitForChild("Frames"):WaitForChild("EnemyDrops")
local enemyViewport = enemyDrops:WaitForChild("EnemyViewport")
local enemy = enemyDrops:WaitForChild("Enemy")
local health = enemyDrops:WaitForChild("Health")
local scroll = enemyDrops:WaitForChild("List"):WaitForChild("Scroll")
local drop = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Enemies"):WaitForChild("Interface"):WaitForChild("Drop")
local text = nil
local v2 = nil
local v3 = {}
local innerScopesByID = {}
local v4 = nil
local spring = scope:Spring(scope:Value(1), 10, 1)
local EnemyDrops = {}
local scope2 = fusion.scoped(fusion, {
	Build = function(self, layoutOrder: number)
		self.Scale = self:Value(0)
		self.ScaleSpring = self:Spring(self.Scale, 15, 1)
		self.Instance = drop:Clone()
		self.Instance.Name = self.Data.ID
		self.Instance.Main.UIGradient:SetAttribute("Rarity", self.Data.Info.Rarity or "Common")

		if self.Data.Info.Icon then
			self.Instance.Main.Icon.Visible = true
			self.Instance.Main.Viewport.Visible = false
			self.Instance.Main.Icon.Image = self.Data.Info.Icon or ""
		else
			self.Instance.Main.Icon.Visible = false
			self.Instance.Main.Viewport.Visible = true
			module.Utils.Camera.ViewportCharacter({
				Viewport = self.Instance.Main.Viewport,
				Animation = module.Utils.Characters.GetCharacterAnimation(self.Data.Name, "Idle"),
				Character = module.Utils.Characters.Get({
					Name = self.Data.Name,
					Shiny = self.Data.Shiny,
					RemoveHumanoidStates = true
				})
			})
		end

		self.Instance.Main.Chance.Text = not (self.Data.Chance >= 0.1) and "???" or `{module.Utils.Number:Round(self.Data.Chance)}%` or "???"
		self.Instance.Main.Amount.Text = self.Data.Minimum == self.Data.Maximum and `{module.Utils.Number:Format(self.Data.Maximum)}x` or `{module.Utils.Number:Format(self.Data.Minimum)} - {module.Utils.Number:Format(self.Data.Maximum)}x`
		self.Hover = module.Libs.NeoHover.GetByPseudoIdentifier(self.Data.Type)

		if not self.Hover then
			self.Tooltip = true
			self.Hover = module.Libs.NeoHover.GetByIdentifier("Tooltip")
		end

		local v5 = module.Button:Create(self.Instance.Main, "Small")
		v5:BindFunction("Click", function()
			if not self.Hover then
				return
			end

			if self.Tooltip then
				self.Hover:Click(self.Instance, {
					Text = self.Data.Name
				})
			else
				self.Hover:Click(self.Instance, {
					IsFake = true,
					Data = self.Data.Info,
					Name = self.Data.Name
				})
			end
		end)
		v5:BindOnEnter("Hover", function()
			if not self.Hover then
				return
			end

			if self.Tooltip then
				self.Hover:Open(self.Instance, {
					Text = self.Data.Name
				})
			else
				self.Hover:Open(self.Instance, {
					IsFake = true,
					Data = self.Data.Info,
					Name = self.Data.Name
				})
			end
		end)
		v5:BindOnLeave("Hover", function()
			if not self.Hover then
				return
			end

			self.Hover:Close(self.Instance)
		end)
		self.Instance.LayoutOrder = layoutOrder
		local uIScale = Instance.new("UIScale")
		uIScale.Scale = 0
		uIScale.Parent = self.Instance
		self:Hydrate(uIScale)({
			Scale = self.ScaleSpring
		})
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		task.delay(layoutOrder * 0.05, function()
			if not next(self) then
				return
			end

			self.Scale:set(1)
		end)
		return true
	end
})

local function ClearDrops()
	for _, v5 in innerScopesByID do
		if v5.Hover then
			v5.Hover:Close(v5.Instance)
		end

		v5.Instance:Destroy()
		v5:doCleanup()
	end

	table.clear(innerScopesByID)
end

local function CreateModel()
	local v5 = module.Shared.Enemies.StaticModels[text] ~= nil
	local model = module.Utils.Enemies.GetModel(text)

	if not model then
		return
	end

	local viewportCharacter = module.Utils.Camera.ViewportCharacter
	local v6 = {
		Viewport = enemyViewport,
		Animation = 0,
		Character = 0,
		CustomCFrame = 0
	}
	local animation

	if not v5 then
		animation = module.Utils.Characters.GetCharacterAnimation(text, "Idle") or nil
	end

	v6.Animation = animation
	v6.Character = model
	v6.CustomCFrame = CFrame.new(createVector(0, -7.5, -7.5)) * CFrame.Angles(0, 0, 0)
	local v8 = viewportCharacter(v6)
	v4 = v8 and v8[1]
	spring:setPosition(0)
end

local function UpdatePosition()
	if not v4 then
		return
	end

	local currentSpring = scope.peek(spring)

	if not currentSpring then
		return
	end

	local lerped = (createVector(0, -7.5, -7.5)):Lerp(createVector(0, -1.5, -4), currentSpring)
	local lerped2 = (createVector(0, 0, 0)):Lerp(createVector(-0, 160, -0), currentSpring)
	v4:PivotTo(CFrame.new(lerped) * CFrame.Angles(math.rad(lerped2.X), math.rad(lerped2.Y), (math.rad(lerped2.Z))))
end

function EnemyDrops:Open(p: number, p2)
	if typeof(self) ~= "string" then
		return
	end

	text = self
	v2 = p
	v3 = typeof(p2) == "table" and p2 or {}
	module.Frame:Open("EnemyDrops")
end

function EnemyDrops.Start()
	if not text then
		return
	end

	enemy.Title.Text = text
	health.Title.Text = `{module.Utils.Number:Format(v2 or 0)} Health`
	CreateModel()
	ClearDrops()

	for k, v5 in v3 do
		local innerScope = scope2:innerScope()
		innerScope.Data = v5

		if innerScope:Build(k) then
			innerScopesByID[v5.ID] = innerScope
		else
			innerScope:doCleanup()
		end
	end
end

function EnemyDrops.Stop()
	module.Utils.Camera.ClearViewport(enemyViewport)
	v4 = nil
	ClearDrops()
end

function EnemyDrops.Init()
	scope:Observer(spring):onBind(UpdatePosition)
	module.Frame:OnFrameOpened(enemyDrops, EnemyDrops.Start)
	module.Frame:OnFrameClosed(enemyDrops, EnemyDrops.Stop)
end

return EnemyDrops