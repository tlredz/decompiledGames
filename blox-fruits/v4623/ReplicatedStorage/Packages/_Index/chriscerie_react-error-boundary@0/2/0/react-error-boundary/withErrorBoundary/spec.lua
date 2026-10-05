local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local withErrorBoundary = require(script.Parent.withErrorBoundary)
local createElement = React.createElement
return function()
	describe("ErrorBoundary", function()
		local folder = nil
		local v = nil
		local flag = true
		local v2 = nil
		beforeEach(function()
			folder = Instance.new("Folder")
			v = ReactRoblox.createRoot(folder)
			flag = false
			v2 = "💥💥💥"
		end)

		local function fn(p)
			if flag then
				error(v2)
			end

			return p.children or createElement("Frame", {
				key = "Content"
			})
		end

		local function render()
			local v3 = withErrorBoundary(fn, {
				fallback = createElement("Frame", {
					key = "Fallback"
				})
			})
			v:render(createElement(v3))
			task.wait()
		end

		it("should render children within the created HOC", function()
			render()
			expect(folder:FindFirstChild("Content")).to.be.ok()
		end)
		it("should catch errors with the created HOC", function()
			flag = true
			render()
			expect(folder:FindFirstChild("Fallback")).to.be.ok()
		end)
		it("should forward refs", function()
			local v3 = withErrorBoundary(React.forwardRef(function(_, ref2)
				return createElement("Frame", {
					key = "Content",
					ref = ref2
				})
			end), {
				fallback = createElement("Frame", {
					key = "Fallback"
				})
			})
			local ref = React.createRef()
			v:render(createElement(v3, {
				ref = ref
			}))
			task.wait()
			expect(ref.current).to.be.ok()
		end)
	end)
end