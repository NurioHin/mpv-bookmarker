# Bookmarker Menu for mpv v1.2.0

A bookmarker menu to manage all your bookmarks in MPV. This script is based on [mpv-bookmarker](https://github.com/nimatrueway/mpv-bookmark-lua-script) and has been rewritten to include a bookmarker menu. All of the code has been written from scratch, aside from the general file/JSON management utilities.

**Warning:** The bookmarks created with this script are not compatible with those created with [mpv-bookmarker](https://github.com/nimatrueway/mpv-bookmark-lua-script).

## New in version 1.2.0

* Added a cursor to the Typer, allowing you to insert text in other places than the end of the line
* Added the ability to change the filepath of a bookmark, in case you moved files to a different folder, or your external drive is suddenly assigned a different drive letter
* Changed the way filepaths are saved and loaded, to accomodate the ability to edit them
* Introduced version numbers to the bookmarks for potential backward compatibility
* Because of this, all older bookmarks should still be compatible with version 1.2.0
* Changed some of the messages and added a few more error messages

## Installation

Copy `bookmarker-menu.lua` to the scripts folder for mpv then add the following lines to `input.conf`:

```
B script_message bookmarker-menu
b script_message bookmarker-quick-save
ctrl+b script_message bookmarker-quick-load
```

The keys are only a suggestion, and can be changed to something else.

Open `bookmarker-menu.lua` in a text editor, and you can easily change these settings:

```lua
-- Maximum number of characters for bookmark name
local maxChar = 100
-- Number of bookmarks to be displayed per page
local bookmarksPerPage = 10
-- Whether to close the Bookmarker menu after loading a bookmark
local closeAfterLoad = true
```

## Usage

#### When the Bookmarker menu is closed

* *`B` or whichever key you configured in `input.conf`*: Pull up the Bookmarker menu
* *`b` or whichever key you configured in `input.conf`*: Quickly add a new bookmark
* *`ctrl+b` or whichever key you configured in `input.conf`*: Quickly load the latest bookmark

#### When the Bookmarker menu is open

* *`B` or whichever key you configured in `input.conf`*: Close the Bookmarker menu
* `ESC`: Close the Bookmarker menu
* `UP/DOWN`: Navigate through the bookmarks on the current page
* `LEFT/RIGHT`: Navigate through pages of bookmarks
* `ENTER`: Load the currently selected bookmark
* `DELETE`: Delete the currently selected bookmark
* `r`: Rename the currently selected bookmark (shows a text input, allowing you to type)
* `s`: Save a bookmark of the current file and position
* `shift+s`: Save a bookmark of the current file and position (shows a text input, allowing you to type)
* `m`: Move the currently selected bookmark

#### When allowing text input
* `ESC`: Cancel text input and return to the Bookmarker menu
* `ENTER`: Confirm text input and save/rename the bookmark
* `Any text character`: Type for the text input. Allows special characters, spaces, numbers. Does not allow letters with accents

During text input, you can write `%t` or `%p` to input a timestamp in the name.

* `%t` is a timestamp in the format of hh:mm:ss.mmm
* `%p` is a timestamp in the format of ssss.mmm

For example, `Awesome moment @ %t` will show up as `Awesome moment @ 00:13:41.673` in the menu

#### When moving bookmarks
* `ESC`: Cancel moving and return to the Bookmarker menu
* `ENTER`: Confirm moving the bookmark
* `m`: Confirm moving the bookmark
* `s`: Save a bookmark of the current file and position
* `UP/DOWN`: Navigate through the bookmarks on the current page
* `LEFT/RIGHT`: Navigate through pages of bookmarks

## Testing

This has been tested on Windows. In theory, it should also work for Unix systems, but it hasn't been tested on those.

## Changelog

#### Version 1.2.0

* Added a cursor to the Typer, allowing you to insert text in other places than the end of the line
* Added the ability to change the filepath of a bookmark, in case you moved files to a different folder, or your external drive is suddenly assigned a different drive letter
* Changed the way filepaths are saved and loaded, to accomodate the ability to edit them
* Introduced version numbers to the bookmarks for potential backward compatibility
* Because of this, all older bookmarks should still be compatible with version 1.2.0
* Changed some of the messages and added a few more error messages

#### Version 1.1.0

* Added more functionality to the Typer
* I should've kept better track of changes

#### Version 1.0.0

* Initial release
