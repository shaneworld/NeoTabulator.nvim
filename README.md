<div align="center">

# NeoTabulator
    
##### Revolutionize your table experience in markdown
    
</div>

## Features

- Automatically create and insert tables based on specified table size and alignment.

- Automatic formatting of single table rows in normal mode.

- Automatically format selected table range in visual mode

## Usage

### Installation

Using [lazy](https://github.com/folke/lazy.nvim):

```lua
{
    "shaneworld/NeoTabulator.nvim",
    require("NeoTabulator").setup({
        -- Alignment
        -- Default value: center
        -- Options: center, left, right
        mode = mode_options.center,
        -- Keymaps
        -- Below are default values
        create_table = "<leader>ta",
        format_normal = "<leader>fn",
        format_visual = "<leader>fv"
    })
}
```

### Tutorial

#### Insert a new table

Go to the place where you want to insert your table, press `<leader>ta` and you will get `:CreateTable ` waiting for you to input the alignment and size of table.

(Or you can manually call the function `CreateTable`)

- `:CreateTable l <height>x<width>` - Creates a **left-aligned** table with `<height>` rows and `<width>` cols.

- `:CreateTable c <height>x<width>` - Creates a **center-aligned** table with `<height>` rows and `<width>` cols.

- `:CreateTable r <height>x<width>` - Creates a **right-aligned** table with `<height>` rows and `<width>` cols.

- `:CreateTable <height>x<width>` - Creates a new table with `<height>` rows and `<width>` cols.

#### Formatting in normal mode

Press `<leader>fn`.

#### Formatting in visual mode

Select the area to be formatted and press `<leader>fv`.

## TODO

- [ ] Optimize algorithm.

- [ ] Improve interactive experience.

- [ ] Add function of automatic formatting when saving.
