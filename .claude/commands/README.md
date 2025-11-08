# Claude Code Custom Commands

This directory contains custom slash commands for the food_cal project.

## Universal Development Command

### `/dev "task description"`

**Your one command for everything!** 🎯

The `/dev` command is a smart, adaptive assistant that automatically:
- Analyzes what type of work you need
- Chooses the right workflow (refactor, design, debug, feature, etc.)
- Optimizes model usage (Sonnet for thinking, Haiku for execution)
- Delivers the best results efficiently

### Examples

```bash
# Refactoring
/dev "extract utilities from HomeProvider"

# Widget Design
/dev "redesign the EnergyMetricsWidget with modern animations"

# Bug Fixing
/dev "fix the crash when user profile is null"

# New Feature
/dev "add monthly calorie tracking graph"

# Investigation
/dev "explain how the food repository works"

# Optimization
/dev "improve app startup performance"

# Documentation
/dev "add documentation to the HealthMetrics class"
```

### What It Handles

- 🔧 **Refactoring** - Restructure code, extract utilities
- 🎨 **Design/UI** - Create widgets, improve layouts
- 🐛 **Bug Fixes** - Debug and fix errors
- ✨ **Features** - Add new functionality
- ⚡ **Optimization** - Improve performance
- 🧪 **Testing** - Add tests, improve coverage
- 📚 **Documentation** - Add comments, write docs
- 🔍 **Investigation** - Understand and analyze code

### Smart Model Selection

The `/dev` command automatically optimizes for cost and speed:
- 🧠 **Sonnet 4.5** for thinking, planning, creative work
- ⚡ **Haiku 4.5** for mechanical tasks (via Task agents)
- 💰 **60-70% cost savings** on average

## Why Just One Command?

**Simplicity wins!** Instead of remembering multiple commands:
- `/refactor` for refactoring
- `/design` for design
- `/debug` for debugging
- `/optimize` for optimization

You just use `/dev` for everything and it figures out the rest! 🚀

## Creating More Commands (If Needed)

To create a new command:

1. Create a `.md` file in `.claude/commands/`
2. Add frontmatter with `description` and optional `model`
3. Write the prompt template

**Example:**
```markdown
---
description: Your command description
model: haiku  # optional: sonnet (default), haiku, opus
---

Your prompt here with {{arg1}} placeholders...
```

## Learn More

- [Claude Code Documentation](https://docs.claude.com/claude-code)
- [Custom Commands Guide](https://docs.claude.com/claude-code/custom-commands)

---

**Pro Tip:** For 90% of your work, just use `/dev`. For special cases where you need fine-grained control, you can always just talk to Claude naturally in the conversation!
