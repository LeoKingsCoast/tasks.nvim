<h1 align="center">Tasks.nvim</h1>

This is a plugin to view and manage tasks (TODO Comments and/or Markdown Checkboxes) in a project.

All found tasks will be displayed in a window, where you can check them as done and save changes. TODO Comments will be deleted and Markdown Checkboxes will be checked once changes are saved.

https://github.com/user-attachments/assets/d4281d59-9512-4932-bfc0-e9fa1d2cc565

## Requirements

- [Ripgrep](https://github.com/BurntSushi/ripgrep)

## Install

Lazy.nvim:

```lua
{
    "LeoKingsCoast/tasks.nvim"
}
```

## Usage

### Commands

- `:TasksOpen`: Opens the tasks window
- `:TasksWrite`: Saves changes, even with tasks window closed

Inside the tasks window:

- `:W`: Saves changes

### Default Keymaps

Inside the tasks window:

- `Enter`: Toggles selected task (done / not done)
- `gd`: Jumps to task location in the project

## Future Development

- [ ] Add an update function to redo the search
- [ ] Improve task window appearance
- [ ] Customizable behavior (ask before saving, closing window on save or on jump)
- [ ] Customizable subdirectories to always look for tasks
- [ ] Tasks window visual customization
