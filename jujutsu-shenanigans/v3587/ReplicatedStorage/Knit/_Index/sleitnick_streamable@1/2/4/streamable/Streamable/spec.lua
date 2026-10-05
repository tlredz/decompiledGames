return function()
	local Streamable = require(script.Parent.Streamable)
	local folder = nil
	local model = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function CreateInstance(name)
		local folder2 = Instance.new("Folder")
		folder2.Name = name
		folder2.Archivable = false
		folder2.Parent = folder
		return folder2
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function CreatePrimary()
		local part = Instance.new("Part")
		part.Anchored = true
		part.Parent = model
		model.PrimaryPart = part
		return part
	end

	beforeAll(function()
		folder = Instance.new("Folder")
		folder.Name = "KnitTestFolder"
		folder.Archivable = false
		folder.Parent = workspace
		model = Instance.new("Model")
		model.Name = "KnitTestModel"
		model.Archivable = false
		model.Parent = workspace
	end)
	afterEach(function()
		folder:ClearAllChildren()
		model:ClearAllChildren()
	end)
	afterAll(function()
		folder:Destroy()
		model:Destroy()
	end)
	describe("Streamable", function()
		it("should detect instance that is immediately available", function()
			local instance = CreateInstance("TestImmediate") -- equivalent call inferred; original call site unknown
			local v2 = Streamable.new(folder, "TestImmediate")
			local count = 0
			local count2 = 0
			v2:Observe(function(_, maid)
				count += 1
				maid:Add(function()
					count2 += 1
				end)
			end)
			task.wait()
			instance.Parent = nil
			task.wait()
			instance.Parent = folder
			task.wait()
			v2:Destroy()
			task.wait()
			expect(count).to.equal(2)
			expect(count2).to.equal(2)
		end)
		it("should detect instance that is not immediately available", function()
			local v = Streamable.new(folder, "TestImmediate")
			local count = 0
			local count2 = 0
			v:Observe(function(_, maid)
				count += 1
				maid:Add(function()
					count2 += 1
				end)
			end)
			task.wait(0.1)
			local instance = CreateInstance("TestImmediate") -- equivalent call inferred; original call site unknown
			task.wait()
			instance.Parent = nil
			task.wait()
			instance.Parent = folder
			task.wait()
			v:Destroy()
			task.wait()
			expect(count).to.equal(2)
			expect(count2).to.equal(2)
		end)
		it("should detect primary part that is immediately available", function()
			local primaryPart = CreatePrimary() -- equivalent call inferred; original call site unknown
			local primary = Streamable.primary(model)
			local count = 0
			local count2 = 0
			primary:Observe(function(_, maid)
				count += 1
				maid:Add(function()
					count2 += 1
				end)
			end)
			task.wait()
			primaryPart.Parent = nil
			task.wait()
			primaryPart.Parent = model
			model.PrimaryPart = primaryPart
			task.wait()
			primary:Destroy()
			task.wait()
			expect(count).to.equal(2)
			expect(count2).to.equal(2)
		end)
		it("should detect primary part that is not immediately available", function()
			local primary = Streamable.primary(model)
			local count = 0
			local count2 = 0
			primary:Observe(function(_, maid)
				count += 1
				maid:Add(function()
					count2 += 1
				end)
			end)
			task.wait(0.1)
			local primaryPart = CreatePrimary() -- equivalent call inferred; original call site unknown
			task.wait()
			primaryPart.Parent = nil
			task.wait()
			primaryPart.Parent = model
			model.PrimaryPart = primaryPart
			task.wait()
			primary:Destroy()
			task.wait()
			expect(count).to.equal(2)
			expect(count2).to.equal(2)
		end)
	end)
end