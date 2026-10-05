local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local t = require(ReplicatedStorage.Packages.t)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = {}
local v2 = {
	ModelAdded = Signal.new(),
	ApplyModelHidden = function(folder, flag: boolean)
		t.strict(t.instanceIsA("Model"))(folder)
		t.strict(t.boolean)(flag)

		for _, part in ipairs(folder:GetDescendants()) do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = flag and 1 or 0
			end
		end
	end,
	ResolveModel = function(childName: string)
		t.strict(t.string)(childName)
		local model = Workspace:FindFirstChild(childName)

		if model == nil then
			return nil
		end

		assert(model:IsA("Model"), (`Workspace area egg {childName} must be a Model`))
		return model
	end
}

function v2.SetHidden(p: string, flag: boolean)
	t.strict(t.string)(p)
	t.strict(t.boolean)(flag)

	if flag then
		v[p] = true
	else
		v[p] = nil
	end

	for _, model in ipairs(Workspace:GetChildren()) do
		if model.Name == p and model:IsA("Model") then
			v2.ApplyModelHidden(model, flag)
		end
	end
end

function v2.Start()
	Workspace.ChildAdded:Connect(function(model)
		if not model:IsA("Model") or model.Parent ~= Workspace then
			return
		end

		if v[model.Name] == true then
			v2.ApplyModelHidden(model, true)
		end

		v2.ModelAdded:Fire(model)
	end)
end

return table.freeze(v2)