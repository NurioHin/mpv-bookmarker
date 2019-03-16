-- // Bookmarker Menu v1.0.2 for mpv \\ --

-- Maximum number of characters for bookmark name
local maxChar = 100
-- Number of bookmarks to be displayed per page
local bookmarksPerPage = 10
-- Whether to close the Bookmarker menu after loading a bookmark
local closeAfterLoad = true
-- The filename for the bookmarks file
local bookmarkerName = "bookmarker.json"
-- The rate at which the bookmarker needs to refresh its interface, lower is more frequent
local rate = 1

local utils = require 'mp.utils'
local bookmarks = {}
local currentSlot = 0
local currentPage = 1
local maxPage = 1
local active = false
local mode = "none"
local bookmarkStore = {}
local oldSlot = 0

-- // Controls \\ --

-- List of custom controls and their function
local controls = {
  ESC = function() abort("") end,
  DOWN = function() jumpSlot(1) displayBookmarks() end,
  UP = function() jumpSlot(-1) displayBookmarks() end,
  RIGHT = function() jumpPage(1) displayBookmarks() end,
  LEFT = function() jumpPage(-1) displayBookmarks() end,
  s = function() addBookmark(mp.get_property("filename")) displayBookmarks() end,
  S = function() mode="save" typerStart() end,
  r = function() mode="rename" typerStart() end,
  m = function() mode="move" moverStart() end,
  ENTER = function() jumpToBookmark(currentSlot) end,
  KP_ENTER = function() jumpToBookmark(currentSlot) end,
  DEL = function() deleteBookmark(currentSlot) displayBookmarks() end
}

-- Activate the custom controls
function activateControls(name)
  for key, func in pairs(controls) do
    mp.add_forced_key_binding(key, name..key, func)
  end
end

-- Deactivate the custom controls
function deactivateControls(name)
  for key, _ in pairs(controls) do
    mp.remove_key_binding(name..key)
  end
end

-- // Typer \\ --

-- Controls for the Typer
local typerControls = {
  ESC = function() typerExit() end,
  ENTER = function() typerCommit() end,
  KP_ENTER = function() typerCommit() end,
  BS = function() typer("backspace") end,
  DEL = function() typer("delete") end,
  SPACE = function() typer(" ") end,
  SHARP = function() typer("#") end,
  KP0 = function() typer("0") end,
  KP1 = function() typer("1") end,
  KP2 = function() typer("2") end,
  KP3 = function() typer("3") end,
  KP4 = function() typer("4") end,
  KP5 = function() typer("5") end,
  KP6 = function() typer("6") end,
  KP7 = function() typer("7") end,
  KP8 = function() typer("8") end,
  KP9 = function() typer("9") end,
  KP_DEC = function() typer(".") end
}

-- All standard keys for the Typer
local typerKeys = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","1","2","3","4","5","6","7","8","9","0","!","@","$","%","^","&","*","(",")","-","_","=","+","[","]","{","}","\\","|",":","'","\"",",",".","<",">","/","?","`","~"}
-- For some reason, semicolon is not possible

local typerText = ""
local typerActive = false

-- Function to activate the Typer
-- use typerStart() for custom controls around activating the Typer
function activateTyper()
  for key, func in pairs(typerControls) do
    mp.add_forced_key_binding(key, "typer"..key, func)
  end
  for i, key in ipairs(typerKeys) do
    mp.add_forced_key_binding(key, "typer"..key, function() typer(key) end)
  end
  typerText = ""
  typerActive = true
end

-- Function to deactivate the Typer
-- use typerExit() for custom controls around deactivating the Typer
function deactivateTyper()
  for key, _ in pairs(typerControls) do
    mp.remove_key_binding("typer"..key)
  end
  for i, key in ipairs(typerKeys) do
    mp.remove_key_binding("typer"..key)
  end
  typerActive = false
  return typerText
end

-- Function for handling the text as it is being typed
function typer(s)
  -- Don't touch this part
  if s == "backspace" then
    typerText = typerText:sub(1, typerText:len() - 1)
  elseif s == "delete" then
    typerText = ""
  else
    typerText = typerText .. s
  end

  -- Enter custom script and display message here
  if typerText:len() > maxChar then typerText = typerText:sub(1,maxChar) end
  mp.osd_message("Enter a bookmark name:\n"..typerText, 9999)
end

-- // Mover \\ --

-- Controls for the Mover
local moverControls = {
  ESC = function() moverExit() end,
  DOWN = function() jumpSlot(1) displayBookmarks() end,
  UP = function() jumpSlot(-1) displayBookmarks() end,
  RIGHT = function() jumpPage(1) displayBookmarks() end,
  LEFT = function() jumpPage(-1) displayBookmarks() end,
  s = function() addBookmark(mp.get_property("filename")) displayBookmarks() end,
  m = function() moverCommit() end,
  ENTER = function() moverCommit() end,
  KP_ENTER = function() moverCommit() end
}

-- Function to activate the Mover
function moverStart()
  if bookmarkExists(currentSlot) then
    deactivateControls("bookmarker")
    for key, func in pairs(moverControls) do
      mp.add_forced_key_binding(key, "mover"..key, func)
    end
    displayBookmarks()
  else
    moverExit()
  end
end

-- Function to commit the action of the Mover
function moverCommit()
  saveBookmarks()
  moverExit()
end

-- Function to deactivate the Mover
function moverExit()
  for key, _ in pairs(moverControls) do
    mp.remove_key_binding("mover"..key)
  end
  mode = "none"
  loadBookmarks()
  displayBookmarks()
  activateControls("bookmarker")
end

-- // General utilities \\ --

-- Check if the operating system is Mac OS
function isMacOS()
  local homedir = os.getenv("HOME")
  return (homedir ~= nil and string.sub(homedir,1,6) == "/Users")
end

-- Check if the operating system is Windows
function isWindows()
  local windir = os.getenv("windir")
  return (windir~=nil)
end

-- Check whether a certain file exists
function fileExists(path)
  local f = io.open(path,"r")
  if f~=nil then
    io.close(f)
    return true
  else
    return false
  end
end

-- Get the filepath of a file from the mpv config folder
function getFilepath(filename)
  if isWindows() then
  	return os.getenv("APPDATA"):gsub("\\", "/") .. "/mpv/" .. filename
  else	
	return os.getenv("HOME") .. "/.config/mpv/" .. filename
  end
end

-- Load a table from a JSON file
-- Returns nil if the file can't be found
function loadTable(path)
    local contents = ""
    local myTable = {}
    local file = io.open( path, "r" )
    if file then
        local contents = file:read( "*a" )
        myTable = utils.parse_json(contents);
        io.close(file)
        return myTable
    end
    return nil
end

-- Save a table as a JSON file file
-- Returns true if successful
function saveTable(t, path)
    local contents = utils.format_json(t)
    local file = io.open(path .. ".tmp", "wb")
    file:write(contents)
    io.close(file)
    os.remove(path)
    os.rename(path .. ".tmp", path)
    return true
end

-- Convert a pos (seconds) to a hh:mm:ss.mmm format
function getTime(pos)
  local hours = math.floor(pos/3600)
  local minutes = math.floor((pos % 3600)/60)
  local seconds = math.floor((pos % 60))
  local milliseconds = math.floor(pos % 1 * 1000)
  return string.format("%02d:%02d:%02d.%03d",hours,minutes,seconds,milliseconds)
end

-- // Bookmark functions \\ --

-- Checks whether the specified bookmark exists
function bookmarkExists(slot)
  return (slot >= 1 and slot <= #bookmarks)
end

-- Calculates the current page and the total number of pages
function calcPages()
  currentPage = math.floor((currentSlot - 1) / bookmarksPerPage) + 1
  if currentPage == 0 then currentPage = 1 end
  maxPage = math.floor((#bookmarks - 1) / bookmarksPerPage) + 1
  if maxPage == 0 then maxPage = 1 end
end

-- Get the amount of bookmarks on the specified page
function getAmountBookmarksOnPage(page)
  local n = bookmarksPerPage
  if page == maxPage then n = #bookmarks % bookmarksPerPage end
  if n == 0 then n = bookmarksPerPage end
  if #bookmarks == 0 then n = 0 end
  return n
end

-- Get the index of the first slot on the specified page
function getFirstSlotOnPage(page)
  return (page - 1) * bookmarksPerPage + 1
end

-- Get the index of the last slot on the specified page
function getLastSlotOnPage(page)
  local endSlot = getFirstSlotOnPage(page) + getAmountBookmarksOnPage(page) - 1
  if endSlot > #bookmarks then endSlot = #bookmarks end
  return endSlot
end

-- Jumps a certain amount of slots forward or backwards in the bookmarks list
-- Keeps in mind if the current mode is to move bookmarks
function jumpSlot(i)
  if mode == "move" then
    oldSlot = currentSlot
    bookmarkStore = bookmarks[oldSlot]
  end

  currentSlot = currentSlot + i
  local startSlot = getFirstSlotOnPage(currentPage)
  local endSlot = getLastSlotOnPage(currentPage)

  if currentSlot < startSlot then currentSlot = endSlot end
  if currentSlot > endSlot then currentSlot = startSlot end

  if mode == "move" then
    table.remove(bookmarks, oldSlot)
    table.insert(bookmarks, currentSlot, bookmarkStore)
  end
end

-- Jumps a certain amount of pages forward or backwards in the bookmarks list
-- Keeps in mind if the current mode is to move bookmarks
function jumpPage(i)
  if mode == "move" then
    oldSlot = currentSlot
    bookmarkStore = bookmarks[oldSlot]
  end

  local oldPos = currentSlot - getFirstSlotOnPage(currentPage) + 1
  currentPage = currentPage + i
  if currentPage < 1 then currentPage = maxPage + currentPage end
  if currentPage > maxPage then currentPage = currentPage - maxPage end

  local bookmarksOnPage = getAmountBookmarksOnPage(currentPage)
  if oldPos > bookmarksOnPage then oldPos = bookmarksOnPage end
  currentSlot = getFirstSlotOnPage(currentPage) + oldPos - 1

  if mode == "move" then
    table.remove(bookmarks, oldSlot)
    table.insert(bookmarks, currentSlot, bookmarkStore)
  end
end

-- Loads all the bookmarks in the global table and sets the current page and total number of pages
function loadBookmarks()
  bookmarks = loadTable(getFilepath(bookmarkerName))
  if bookmarks == nil then bookmarks = {} end

  if #bookmarks > 0 and currentSlot == 0 then currentSlot = 1 end

  calcPages()
end

-- Save the globally loaded bookmarks to the JSON file
function saveBookmarks()
  saveTable(bookmarks, getFilepath(bookmarkerName))
end

-- Add the current position as a bookmark to the global table and then saves it
-- Returns the slot of the newly added bookmark
function addBookmark(bname)
  if bname:len() > maxChar then bname = bname:sub(1,maxChar) end
  local bookmark = {
    name = bname,
    pos = mp.get_property_number("time-pos"),
    path = mp.get_property("path")
  }
  table.insert(bookmarks, bookmark)

  if #bookmarks == 1 then currentSlot = 1 end

  calcPages()
  saveBookmarks()
  return #bookmarks
end

-- Rename the bookmark at the specified slot
function renameBookmark(slot, name)
  if name:len() > maxChar then name = name:sub(1,maxChar) end
  if bookmarkExists(slot) then
    bookmarks[slot]["name"] = name
    saveBookmarks()
  else
    abort("Can't find the bookmark at slot " .. slot)
  end
end

-- Quickly saves a bookmark without bringing up the menu
function quickSave()
  if not active then
    loadBookmarks()
    local slot = addBookmark(mp.get_property("filename"))
    mp.osd_message("Saved new bookmark at slot " .. slot)
  end
end

-- Quickly loads the last bookmark without bringing up the menu
function quickLoad()
  if not active then
    loadBookmarks()
    local slot = #bookmarks
    mp.osd_message("Loaded bookmark at slot " .. slot)
    jumpToBookmark(slot)
  end
end

-- Deletes the bookmark in the specified slot from the global table and then saves it
function deleteBookmark(slot)
  table.remove(bookmarks, slot)
  if currentSlot > #bookmarks then currentSlot = #bookmarks end

  calcPages()
  saveBookmarks()
end

-- Jump to the specified bookmark
function jumpToBookmark(slot)
  if bookmarkExists(slot) then
    local bookmark = bookmarks[slot]
    if fileExists(bookmark["path"]) then
      if mp.get_property("path") == bookmark["path"] then
        mp.set_property_number("time-pos", bookmark["pos"])
      else
        mp.commandv("loadfile", bookmark["path"], "replace", "start="..bookmark["pos"])
      end
      if closeAfterLoad then abort("") end
    else
      abort("Can't find file for bookmark:\n" .. bookmark["name"])
    end
  else
    abort("Can't find the bookmark at slot " .. slot)
  end
end

-- Displays the current page of bookmarks
function displayBookmarks()
  -- Determine which slot is the first and last on the current page
  local startSlot = getFirstSlotOnPage(currentPage)
  local endSlot = getLastSlotOnPage(currentPage)

  -- Prepare the text to display and display it
  local display = "Bookmarks page " .. currentPage .. "/" .. maxPage .. ":"
  for i = startSlot, endSlot do
    local btext = bookmarks[i]["name"] .. " @ " .. getTime(bookmarks[i]["pos"])
    local selection = ""
    if i == currentSlot then
      selection = ">"
      if mode == "move" then btext = "----------------" end
    end
    display = display .. "\n" .. selection .. i .. ": " .. btext
  end
  mp.osd_message(display, rate)
end

local timer = mp.add_periodic_timer(rate * 0.95, displayBookmarks)
timer:kill()

-- Commits the message entered with the Typer
-- Should typically end with typerExit()
function typerCommit()
  if mode == "save" then
    addBookmark(typerText)
  elseif mode == "rename" then
    renameBookmark(currentSlot, typerText)
  end
  typerExit()
end

-- Exits the Typer without committing
function typerExit()
  deactivateTyper()
  displayBookmarks()
  timer:resume()
  mode = "none"
  activateControls("bookmarker")
end

-- Starts the Typer
function typerStart()
  deactivateControls("bookmarker")
  timer:kill()
  activateTyper()
  if mode == "rename" then typerText = bookmarks[currentSlot]["name"] end
  typer("")
end

-- Aborts the program with an optional error message
function abort(message)
  deactivateControls("bookmarker")
  timer:kill()
  mp.osd_message(message)
  active = false
end

-- Handles the state of the bookmarker
function handler()
  if active then
    abort("")
  else
    activateControls("bookmarker")
    loadBookmarks()
    displayBookmarks()
    timer:resume()
    active = true
  end
end

mp.register_script_message("bookmarker-menu", handler)
mp.register_script_message("bookmarker-quick-save", quickSave)
mp.register_script_message("bookmarker-quick-load", quickLoad)
