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
local bookmarksPerPage = 25
-- Whether to close the Bookmarker menu after loading a bookmark
local closeAfterLoad = true
-- The filename for the bookmarks file
local bookmarkerName = "bookmarker.json"
-- The rate (in seconds) at which the bookmarker needs to refresh its interface, lower is more frequent
local rate = 1.5
```

It's recommended not to touch `bookmarkerName` but it's there to be changed in case you already have a file called `bookmarker.json` and don't want that to be overwritten

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
* `s`: Save a bookmark of the current media file and position
* `shift+s`: Save a bookmark of the current media file and position (shows a text input, allowing you to type)
* `r`: Rename the currently selected bookmark (shows a text input, allowing you to type)
* `f`: Change the filepath of the currently selected bookmark (shows a text input, allowing you to type)
* `m`: Move the currently selected bookmark

Changing the filepath of a bookmark is intended to quickly change a bookmark in case you moved the media file to a different folder, or perhaps the drive letter of your external drive changed.

#### When allowing text input

The Typer (as I named it) allows you to type text for various ends, like renaming a bookmark or changing its filepath.

* `ESC`: Cancel text input and return to the Bookmarker menu
* `ENTER`: Confirm text input and save/rename the bookmark
* `LEFT/RIGHT`: Move the cursor through the text, allowing you to input text in different places
* `Any text character`: Type for the text input. Allows special characters, spaces, numbers. Does not allow letters with accents

During text input for a bookmark's name, you can write `%t` or `%p` to input a timestamp in the name. (Note: This does not work for a bookmark's filepath.)

* `%t` is a timestamp in the format of hh:mm:ss.mmm
* `%p` is a timestamp in the format of S.mmm

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
* The default bookmark name now uses `media-title` instead of `filename`
* Changed some of the messages and added a few more error messages

#### Version 1.1.0

* Added minor property expansion to the Typer
* You can type `%t` or `%p` for the bookmark name and have it expand into the time or position respectively
* Added checks for all faulty behavior that I could think of and added error messages for those situations
* Cleaned up the code a bit

#### Version 1.0.2

* Added keypad keys to the Typer
* It's possible to commit moving files with the keypad enter key as well

#### Version 1.0.1

* Added the option to close the bookmarker menu after loading a bookmark

#### Version 1.0.0

* Initial release
