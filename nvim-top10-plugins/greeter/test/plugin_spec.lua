-- lua/myplugin/tests/init_spec.lua
local myplugin = require("greeter")

describe("MyPlugin", function()
	it("should print a message", function()
		local expected_message = "Hi, Dear Viewer, consider subscribing"
		local actual_message = myplugin.greet("Dear Viewer")
		assert.are.same(expected_message, actual_message)
	end)
end)
