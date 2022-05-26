# Neovim Dark mode

Background service that observes the value of NSUserDefaults `AppleInterfaceStyle`.
In other words: it listens for changes in your MacOS appearance, to see if it's in dark mode or not.

Whenever it detects change it will send a `SIGUSR1` signal to `nvim`, in neovim you can trigger a command, using the `Signal` autocommand.


## Getting started
 
### Building the package

First build the package using the following command.

```sh
swift build --configuration release 
```

Next move it to a directory included in your `$PATH` variable.

### Create a plist file for launchctl 

Create a `io.jascha030.nvim-dark-mode.plist` in `$HOME/Library/LaunchAgents/`.

```xml 
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>io.jascha030.nvim-dark-mode</string>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>{YOUR_LOG_DIR}/log/nvim-dark-mode-stderr.log</string>
    <key>StandardOutPath</key>
    <string>{YOUR_LOG_DIR}/log/nvim-dark-mode-stdout.log</string>
    <key>ProgramArguments</key>
    <array>
       <string>{YOUR_BIN_PATH}/nvim-dark-mode</string>
    </array>
</dict>
</plist>
```

### Register the launch agent 

```sh 
launchctl load -w $HOME/Library/LaunchAgents/io.jascha030.nvim-dark-mode.plist
```

## Neovim 

Here is an excerpt from my neovim config, using the Signal autocommand.

```lua
local os_is_dark = function()
    return (vim.call(
        'system',
        [[echo $(defaults read -globalDomain AppleInterfaceStyle &> /dev/null && echo 'dark' || echo 'light')]]
    )):find('dark') ~= nil
end

local is_dark = function()
    return vim.o.background == 'dark'
end

local set_scheme_for_style = function(dark)
    vim.g = vim.tbl_deep_extend('force', vim.g, {
        tokyonight_colors = vim.tbl_deep_extend(
            'force',
            theme_colors,
            dark and color_overrides.dark or color_overrides.light
        ),
        tokyonight_style = dark and 'storm' or 'day',
        tokyonight_italic_functions = true,
        tokyonight_italic_comments = true,
        tokyonight_sidebars = { 'terminal', 'packer' },
    })

    vim.cmd([[colorscheme tokyonight]])
end

local set_from_os = function()
    if os_is_dark() then
        vim.o.background = 'dark'
    else
        vim.o.background = 'light'
    end

    set_scheme_for_style(os_is_dark())
end

local init = function()
    set_from_os()

    vim.api.nvim_create_autocmd('Signal', {
        pattern = '*',
        callback = function()
            set_from_os()
        end,
    })
end

local toggle = function()
    if is_dark() then
        vim.o.background = 'light'
    else
        vim.o.background = 'dark'
    end

    set_scheme_for_style(is_dark())
end

return {
    toggle = toggle,
    init = init,
}
```

## Credits 

This package was heavily inspired by, and based on https://github.com/bouk/dark-mode-notify, which in turn was a modified version of https://github.com/mnewt/dotemacs/blob/master/bin/dark-mode-notifier.swift 

