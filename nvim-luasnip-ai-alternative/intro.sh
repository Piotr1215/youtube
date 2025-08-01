#!/bin/bash
set -euo pipefail

# Intro script for LuaSnip AI Alternative video
# This script sets up the demo environment

echo "🚀 Setting up LuaSnip AI Alternative Demo"
echo "=========================================="

# Check if Neovim is installed
if ! command -v nvim &> /dev/null; then
    echo "❌ Neovim is not installed. Please install it first."
    exit 1
fi

echo "✅ Neovim found: $(nvim --version | head -1)"

# Create demo directory
mkdir -p demo/{react,go,python}

# Create sample files for demonstration
cat > demo/react/App.jsx << 'EOF'
// Demo file for React component snippets
import React from 'react';

// We'll create components here using LuaSnip
EOF

cat > demo/go/main.go << 'EOF'
package main

import "fmt"

// Demo file for Go error handling snippets

func main() {
    fmt.Println("LuaSnip Go Demo")
}
EOF

cat > demo/python/app.py << 'EOF'
#!/usr/bin/env python3
"""
Demo file for Python class and function snippets
"""

# We'll create classes and functions here using LuaSnip
EOF

# Create LuaSnip configuration example
mkdir -p config/nvim/lua/snippets

cat > config/nvim/lua/snippets/init.lua << 'EOF'
-- LuaSnip configuration for the demo
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node
local rep = require("luasnip.extras").rep

-- Load snippets
require("snippets.javascript")
require("snippets.go")
require("snippets.python")

-- Set up keybindings
vim.keymap.set({"i", "s"}, "<C-j>", function()
    if ls.expand_or_jumpable() then
        ls.expand_or_jump()
    end
end, {silent = true})

vim.keymap.set({"i", "s"}, "<C-k>", function()
    if ls.jumpable(-1) then
        ls.jump(-1)
    end
end, {silent = true})
EOF

cat > config/nvim/lua/snippets/javascript.lua << 'EOF'
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local rep = require("luasnip.extras").rep

-- React functional component
ls.add_snippets("javascript", {
    s("rfc", {
        t("const "), i(1, "ComponentName"), t(" = () => {"),
        t({"", "  return (", "    <div>"}),
        i(2, "content"),
        t({"", "    </div>", "  );", "};", "", "export default "}),
        rep(1),
        t(";")
    }),
    
    -- Console log with variable
    s("cl", {
        t("console.log('"), i(1, "label"), t(": ', "), i(2, "variable"), t(");")
    }),
    
    -- useState hook
    s("us", {
        t("const ["), i(1, "state"), t(", set"), 
        f(function(args) return args[1][1]:gsub("^%l", string.upper) end, {1}),
        t("] = useState("), i(2, "initial"), t(");")
    })
})
EOF

cat > config/nvim/lua/snippets/go.lua << 'EOF'
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

-- Go error handling
ls.add_snippets("go", {
    s("iferr", {
        t("if err != nil {"),
        t({"", "    return "}), i(1, "nil, err"),
        t({"", "}"})
    }),
    
    -- Go function with error return
    s("func", {
        t("func "), i(1, "name"), t("("), i(2, "params"), t(") ("), i(3, "returns"), t(", error) {"),
        t({"", "    "}), i(4, "// implementation"),
        t({"", "    return "}), i(5, "result"), t(", nil"),
        t({"", "}"})
    })
})
EOF

cat > config/nvim/lua/snippets/python.lua << 'EOF'
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node

-- Python class
ls.add_snippets("python", {
    s("class", {
        t("class "), i(1, "ClassName"), t(":"),
        t({"", "    def __init__(self, "}), i(2, "args"), t("):"),
        t({"", "        "}), i(3, "# initialization"),
        t({"", "", "    def "}), i(4, "method_name"), t("(self):"),
        t({"", "        "}), i(5, "# method implementation"),
    }),
    
    -- Python function with docstring
    s("def", {
        t("def "), i(1, "function_name"), t("("), i(2, "args"), t("):"),
        t({"", "    \"\"\""}), i(3, "Function description"), t({"\"\"\"", "    "}),
        i(4, "# implementation"),
        t({"", "    return "}), i(5, "result")
    })
})
EOF

echo ""
echo "✅ Demo environment created:"
echo "   📁 demo/ - Sample files for demonstration"
echo "   📁 config/ - LuaSnip configuration examples"
echo ""
echo "🎯 Ready for LuaSnip AI Alternative demo!"
echo ""
echo "💡 To start the demo:"
echo "   1. cd demo"
echo "   2. nvim (with LuaSnip installed)"
echo "   3. Try snippets: rfc, cl, us (JavaScript), iferr, func (Go), class, def (Python)"
echo ""
echo "🚀 Let's show how LuaSnip beats AI coding assistants!"