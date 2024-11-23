#!/usr/bin/env bash

set -euo pipefail

# Create some programming-related projects
projects=(
	"refactoring"
	"bug-fixes"
	"documentation"
	"performance"
)

# Add some tasks with custom UDA fields
echo "🔧 Creating sample tasks..."

# Refactoring tasks
task add project:refactoring +work "Refactor authentication middleware" manual_priority:3 follow:Y session:vim
task add project:refactoring +work "Convert callbacks to async/await" manual_priority:2 linear_issue_id:REF-123 release:v2.0

# Bug fixes
task add project:bug-fixes +work "Fix memory leak in connection pool" manual_priority:5 linear_issue_id:BUG-456 release:v1.9 +bug
task add project:bug-fixes +work "Debug race condition in cache invalidation" manual_priority:4 session:debug follow:Y

# Documentation
task add project:documentation +work "Update API documentation with new endpoints" manual_priority:1 release:v2.0
task add project:documentation +work "Create architecture diagram for new services" manual_priority:2 follow:N

# Performance tasks
task add project:performance +work "Optimize database queries for user dashboard" manual_priority:4 linear_issue_id:PERF-789
task add project:performance +work "Implement caching layer for frequently accessed data" manual_priority:3 session:research

# Add some dependencies
task 3 modify depends:1
task 7 modify depends:8

echo "✅ Sample tasks created!"

# Show the current task list
echo -e "\n📋 Current tasks:"
task current
