# GameGuardian gg Class Reference

[![GameGuardian](https://img.shields.io/badge/GameGuardian-v8.31.1-blue.svg)](https://gameguardian.net/)
[![Lua](https://img.shields.io/badge/Lua-5.1+-green.svg)](https://www.lua.org/)

This document provides a comprehensive reference for the `gg` table in GameGuardian, a powerful Android game hacking tool. The `gg` object exposes various functions and constants for scripting in Lua. It allows memory manipulation, searches, dialogs, and more.

A global instance `gg` is automatically available in scripts. You can print all available fields and methods using `print(gg)`.

**Note:** This reference is based on GameGuardian version 8.31.1 (build 5645). Always check compatibility with `gg.require()`.

## Table of Contents

- [Public Member Functions](#public-member-functions)
- [Dialogs and Toasts](#dialogs-and-toasts)
- [GameGuardian UI Related Methods](#gameguardian-ui-related-methods)
- [UI Button Related Methods](#ui-button-related-methods)
- [Memory Ranges Related Methods](#memory-ranges-related-methods)
- [Search Related Methods](#search-related-methods)
- [Results Related Methods](#results-related-methods)
- [Values Related Methods](#values-related-methods)
- [Memory Editor Related Methods](#memory-editor-related-methods)
- [Pause Related Methods](#pause-related-methods)
- [Speedhack Related Methods](#speedhack-related-methods)
- [Saved Lists Related Methods](#saved-lists-related-methods)
- [Debug Related Methods](#debug-related-methods)
- [Locale Related Methods](#locale-related-methods)
- [Public Attributes](#public-attributes)
- [GameGuardian Version Info](#gameguardian-version-info)
- [Dirs for Files](#dirs-for-files)
- [Type Flags (TYPE_*)](#type-flags-type_)
- [Search (Expect Fuzzy) Sign Flags (SIGN_*)](#search-expect-fuzzy-sign-flags-sign_)
- [Fuzzy Sign Flags (SIGN_FUZZY_*)](#fuzzy-sign-flags-sign_fuzzy_)
- [Memory Regions Flags (REGION_*)](#memory-regions-flags-region_)
- [Flags for Load the Saved Lists (LOAD_*)](#flags-for-load-the-saved-lists-load_)
- [Flags for Save the Saved Lists (SAVE_*)](#flags-for-save-the-saved-lists-save_)
- [Flags for Field "freezeType" (FREEZE_*)](#flags-for-field-freezetype-freeze_)
- [Flags for Field "mode" (PROT_*)](#flags-for-field-mode-prot_)
- [Flags for the Pointer Filter in getResults (POINTER_*)](#flags-for-the-pointer-filter-in-getresults-pointer_)
- [Flags for dumpMemory (DUMP_*)](#flags-for-dumpmemory-dump_)
- [Constants for the Result in getActiveTab (TAB_*)](#constants-for-the-result-in-getactivetab-tab_)
- [Constants for the Type in disasm (ASM_*)](#constants-for-the-type-in-disasm-asm_)
- [Detailed Description](#detailed-description)

## Public Member Functions

### allocatePage
```lua
mixed allocatePage(int mode = gg.PROT_READ | gg.PROT_EXEC, long address = 0)
```
Allocates a memory page (4 KB) in the target process.

- **Parameters:**
  - `mode`: Bit mask of flags `PROT_*`.
  - `address`: If not 0, the kernel takes it as a hint for placement.

- **Returns:** Address of the page or string with error.

- **Examples:**
```lua
print('allocatePage 1: ', string.format('0x%08x', gg.allocatePage()))
print('allocatePage 2: ', string.format('0x%08x', gg.allocatePage(gg.PROT_READ | gg.PROT_EXEC)))
print('allocatePage 3: ', string.format('0x%08x', gg.allocatePage(gg.PROT_READ | gg.PROT_WRITE)))
print('allocatePage 4: ', string.format('0x%08x', gg.allocatePage(gg.PROT_READ)))
print('allocatePage 5: ', string.format('0x%08x', gg.allocatePage(gg.PROT_READ | gg.PROT_WRITE, 0x12345)))
```

### bytes
```lua
string bytes(string text, string encoding = 'UTF-8')
```
Gets the text bytes in the specified encoding.

- **Parameters:**
  - `text`: The text.
  - `encoding`: Possible values: 'ISO-8859-1', 'US-ASCII', 'UTF-16', 'UTF-16BE', 'UTF-16LE', 'UTF-8'.

- **Returns:** A table with bytes in the encoding.

- **Examples:**
```lua
print('UTF-8', gg.bytes('example'))
print('UTF-8', gg.bytes('example', 'UTF-8'))
print('UTF-16', gg.bytes('example', 'UTF-16LE'))
```

### copyMemory
```lua
mixed copyMemory(long from, long to, int bytes)
```
Copies memory.

- **Parameters:**
  - `from`: Source address.
  - `to`: Destination address.
  - `bytes`: Number of bytes to copy.

- **Returns:** `true` or string with error.

- **Examples:**
```lua
print('copyMemory:', gg.copyMemory(0x9000, 0x9010, 3))
-- copies 3 bytes 0x9000-0x9002 to 0x9010-0x9012
```

### copyText
```lua
nil copyText(string text, bool fixLocale = true)
```
Copies text to the clipboard. If `fixLocale` is true, converts number separators to locale-specific.

- **Parameters:**
  - `text`: Text to copy.
  - `fixLocale`: Disable locale fix if false.

- **Examples:**
```lua
-- selected 'ru' locale, where decimal separator is ',' and thousand separator is ' '.
-- in English locale (en_US) decimal separator is '.' and thousand separator is ','.
gg.copyText('1,234,567.890')        -- Will copy '1 234 567,890'
gg.copyText('1,234,567.890', true)  -- Will copy '1 234 567,890'
gg.copyText('1,234,567.890', false) -- Will copy '1,234,567.890'
```

### disasm
```lua
string disasm(int type, long address, int opcode)
```
Disassembles the specified value.

- **Parameters:**
  - `type`: One of `ASM_*`.
  - `address`: Address of the value (may be needed for some opcodes).
  - `opcode`: Disassembly instruction.

- **Returns:** Disassembled opcode string.

- **Examples:**
```lua
print('ARM', gg.disasm(gg.ASM_ARM, 0x12345678, 0xE1A01002))
print('Thumb16', gg.disasm(gg.ASM_THUMB, 0x12345678, 0x0011))
print('Thumb32', gg.disasm(gg.ASM_THUMB, 0x12345678, 0xF800 | (0x0001 << 16)))
print('ARM64', gg.disasm(gg.ASM_ARM64, 0x12345678, 0x2A0103E2))
```

### dumpMemory
```lua
mixed dumpMemory(long from, long to, string dir, int flags = nil)
```
Dumps memory to files on disk.

- **Parameters:**
  - `from`: Start address (rounded to page).
  - `to`: End address (rounded to page).
  - `dir`: Directory for dump files.
  - `flags`: Set of `DUMP_*` or nil.

- **Returns:** `true` or string with error.

- **Examples:**
```lua
print('dumpMemory:', gg.dumpMemory(0x9000, 0x9010, '/sdcard/dump'))
-- dump at least one memory page into the dir '/sdcard/dump'
print('dumpMemory:', gg.dumpMemory(0, -1, '/sdcard/dump'))
print('dumpMemory:', gg.dumpMemory(0, -1, '/sdcard/dump', nil))
print('dumpMemory:', gg.dumpMemory(0, -1, '/sdcard/dump', 0))
-- dump all memory into the dir '/sdcard/dump' (all same)
print('dumpMemory:', gg.dumpMemory(0, -1, '/sdcard/dump', gg.DUMP_SKIP_SYSTEM_LIBS))
-- dump all memory except system libraries into the dir '/sdcard/dump'
```

### getRangesList
```lua
table getRangesList(string filter = '')
```
Gets the list of memory regions of the selected process.

- **Parameters:**
  - `filter`: Filter string (supports wildcards like `^`, `$`, `*`, `?`).

- **Returns:** Table with regions (fields: state, start, end, type, name, internalName).

- **Examples:**
```lua
print(gg.getRangesList())
local t = gg.getRangesList();
print(t[1].start)
print(t[1]['end']) -- cannot use dot-notation here because 'end' is a keyword in Lua, so you need to use square-bracket notation.
print(gg.getRangesList('libc.so'))
print(gg.getRangesList('lib*.so'))
print(gg.getRangesList('^/data/'))
print(gg.getRangesList('.so$'))
```

### getTargetInfo
```lua
mixed getTargetInfo()
```
Gets a table with information about the selected process.

- **Returns:** Table with fields like `packageName`, `versionCode`, etc., or nil.

- **Examples:**
```lua
-- check for game version
local v = gg.getTargetInfo()
if v.versionCode ~= 291 then
    print('This script only works with game version 291. You have game version ', v.versionCode, ' Please install version 291 and try again.')
    os.exit()
end
```

### getTargetPackage
```lua
mixed getTargetPackage()
```
Gets the package name of the selected process.

- **Returns:** Package name string or nil.

- **Examples:**
```lua
print(gg.getTargetPackage()) -- e.g., 'com.blayzegames.iosfps'
```

### isPackageInstalled
```lua
bool isPackageInstalled(string pkg)
```
Checks if the specified application is installed.

- **Parameters:**
  - `pkg`: Package name.

- **Returns:** `true` if installed.

- **Examples:**
```lua
print('Game installed:', gg.isPackageInstalled('com.blayzegames.iosfps'))
```

### makeRequest
```lua
mixed makeRequest(string url, table headers = {}, string data = nil)
```
Performs a GET or POST request over HTTP/HTTPS.

- **Parameters:**
  - `url`: URL string.
  - `headers`: Table of headers.
  - `data`: Data for POST (nil for GET).

- **Returns:** Table with response details or error string.

- **Examples:**
```lua
print('GET 1: ', gg.makeRequest('http://httpbin.org/headers').content) -- simple GET request
print('GET 2: ', gg.makeRequest('http://httpbin.org/headers', {['User-Agent']='My BOT'}).content) -- GET request with headers
-- ... (more examples in the original doc)
print('FULL: ', gg.makeRequest('https://httpbin.org/headers')) -- print full info about the request
```

### processKill
```lua
bool processKill()
```
Force kills the selected process (may cause data loss).

- **Returns:** `true` on success.

### require
```lua
nil require(string version = nil, int build = 0)
```
Checks GameGuardian version; exits if lower.

- **Parameters:**
  - `version`: Minimum version.
  - `build`: Minimum build (optional).

- **Examples:**
```lua
gg.require('8.31.1')
gg.require('8.31.1', 5645)
gg.require(nil, 5645)
```

### saveVariable
```lua
mixed saveVariable(mixed variable, string filename)
```
Saves a variable to a .lua file.

- **Parameters:**
  - `variable`: Variable to save (strings, numbers, tables).
  - `filename`: Full path.

- **Returns:** `true` or error string.

- **Examples:**
```lua
local t = {}
t['test1'] = {1, 2, 3, 4}
t['test2'] = 42
t['test3'] = 86.3
t['test4'] = 'weapon'
t[4] = t['test1']
gg.saveVariable(t, '/sdcard/test.lua') -- saved
local var = assert(loadfile('/sdcard/test.lua'))() -- loaded
-- Saving input between script restarts
local configFile = gg.getFile()..'.cfg'
local data = loadfile(configFile)
if data ~= nil then data = data() end
local input = gg.prompt({'Please input something'}, data)
if input == nil then os.exit() end
gg.saveVariable(input, configFile)
```

### skipRestoreState
```lua
nil skipRestoreState()
```
Prevents restoring GameGuardian state after script completion.

- **Examples:**
```lua
gg.setRanges(bit32.bxor(gg.REGION_C_HEAP, gg.REGION_C_ALLOC, gg.REGION_ANONYMOUS))
-- do some things like search values
-- gg.skipRestoreState() -- if you uncomment this line -
-- memory ranges after end script stay same as we set in first line.
-- If not - it will be restored to state which be before script run.
```

### sleep
```lua
nil sleep(int milliseconds)
```
Pauses script execution.

- **Parameters:**
  - `milliseconds`: Sleep duration.

- **Examples:**
```lua
-- 200 ms
gg.sleep(200)
-- 300 ms
local v = 300
gg.sleep(v)
```

### unrandomizer
```lua
mixed unrandomizer(long qword = nil, long qincr = nil, double double_ = nil, double dincr = nil)
```
Works with Unrandomizer (loads if not loaded).

- **Parameters:**
  - `qword`: Qword value (nil to disable).
  - `qincr`: Qword increment (nil to disable).
  - `double_`: Double value (nil to disable).
  - `dincr`: Double increment (nil to disable).

- **Returns:** `true` or error string.

- **Examples:**
```lua
print('unrandomizer:', gg.unrandomizer(0)) -- set only qword = 0
print('unrandomizer:', gg.unrandomizer(0, 1)) -- set only qword = 0 with increment = 1
print('unrandomizer:', gg.unrandomizer(nil, nil, 0.3)) -- set only double without increment
print('unrandomizer:', gg.unrandomizer(nil, nil, 0.3, 0.01)) -- set only double with increment
print('unrandomizer:', gg.unrandomizer(2, 3, 0.45, 0.67)) -- set both
print('unrandomizer:', gg.unrandomizer()) -- off
```

## Dialogs and Toasts

### toast
```lua
nil toast(string text, bool fast = false)
```
Shows a toast message.

- **Parameters:**
  - `text`: Message.
  - `fast`: Short duration if true.

- **Examples:**
```lua
gg.toast('This is toast')
gg.toast('This is toast', true)
```

### alert
```lua
int alert(string text, string positive = 'ok', string negative = nil, string neutral = nil)
```
Displays a dialog with buttons.

- **Parameters:**
  - `text`: Message.
  - `positive`: Positive button (code 1).
  - `negative`: Negative button (code 2).
  - `neutral`: Neutral button (code 3).

- **Returns:** 0 if canceled, else button code.

- **Examples:**
```lua
gg.alert('Script ended')
gg.alert('Script ended', 'Yes')
gg.alert('A or B?', 'A', 'B')
gg.alert('A or C?', 'A', nil, 'C')
gg.alert('A or B or C?', 'A', 'B', 'C')
```

### prompt
```lua
mixed prompt(table prompts, table defaults = {}, table types = {})
```
Displays data entry dialog.

- **Parameters:**
  - `prompts`: Table of descriptions (numeric array for order).
  - `defaults`: Default values.
  - `types`: Types like 'number', 'text', 'path', etc.

- **Returns:** Table with inputs or nil if canceled.

- **Examples:**
```lua
print('prompt 1: ', gg.prompt(
    {'ask any', 'ask num', 'ask text', 'ask path', 'ask file', 'ask set', 'ask speed', 'checked', 'not checked'},
    {[1]='any val', [7]=123, [6]=-0.34, [8]=true},
    {[2]='number', [3]='text', [4]='path', [5]='file', [6]='setting', [7]='speed', [8]='checkbox', [9]='checkbox'}
))
-- ... (more examples in original doc)
-- Performing multiple actions
local t = gg.prompt({'A', 'B', 'C', 'D'}, nil, {'checkbox', 'checkbox', 'checkbox', 'checkbox'})
if t == nil then
    gg.alert('Canceled')
else
    if t[1] then gg.alert('do A') end
    -- ... (similar for others)
end
```

### choice
```lua
mixed choice(table items, string selected = nil, string message = nil)
```
Displays single choice dialog.

- **Parameters:**
  - `items`: Table of items (numeric array for order).
  - `selected`: Default index.
  - `message`: Title.

- **Returns:** Index or nil if canceled.

- **Examples:**
```lua
print('1: ', gg.choice({'A', 'B', 'C', 'D'}))
print('2: ', gg.choice({'A', 'B', 'C', 'D'}, 2))
print('3: ', gg.choice({'A', 'B', 'C', 'D'}, 3, 'Select letter:'))
print('4: ', gg.choice({'A', 'B', 'C', 'D'}, nil, 'Select letter:'))
```

### multiChoice
```lua
mixed multiChoice(table items, table selection = {}, string message = nil)
```
Displays multiple choice dialog.

- **Parameters:**
  - `items`: Table of items (numeric array for order).
  - `selection`: Pre-checked items.
  - `message`: Title.

- **Returns:** Table of selected or nil if canceled.

- **Examples:**
```lua
print('1: ', gg.multiChoice({'A', 'B', 'C', 'D'}))
print('2: ', gg.multiChoice({'A', 'B', 'C', 'D'}, {[2]=true, [4]=true}))
print('3: ', gg.multiChoice({'A', 'B', 'C', 'D'}, {[3]=true}, 'Select letter:'))
print('4: ', gg.multiChoice({'A', 'B', 'C', 'D'}, {}, 'Select letter:'))
-- Performing multiple actions
local t = gg.multiChoice({'A', 'B', 'C', 'D'})
if t == nil then
    gg.alert('Canceled')
else
    if t[1] then gg.alert('do A') end
    -- ... (similar for others)
end
```

## GameGuardian UI Related Methods

### isVisible
```lua
bool isVisible()
```
Checks if GameGuardian UI is open.

- **Returns:** `true` if open.

### setVisible
```lua
nil setVisible(bool visible)
```
Opens or closes GameGuardian UI.

- **Parameters:**
  - `visible`: `true` to open.

- **Examples:**
```lua
function doAction()
    -- do some action for click, menu for example
    local ret = gg.choice({'Item 1', 'Item 2', 'Item 3'}) or os.exit(gg.setVisible(true))
    gg.alert('You selected: Item '..ret, 'OK')
end
gg.setVisible(false)
while true do
    if gg.isVisible() then
        gg.setVisible(false)
        doAction()
    end
    gg.sleep(100)
end
```

### getActiveTab
```lua
int getActiveTab()
```
Gets active tab in GameGuardian UI.

- **Returns:** One of `TAB_*`.

## UI Button Related Methods

### showUiButton
```lua
nil showUiButton()
```
Shows the UI button ("Sx" icon).

### hideUiButton
```lua
nil hideUiButton()
```
Hides the UI button.

### isClickedUiButton
```lua
mixed isClickedUiButton()
```
Gets and resets UI button click status.

- **Returns:** `true` if clicked, `false` if not, `nil` if hidden.

- **Examples:**
```lua
gg.showUiButton()
while true do
    if gg.isClickedUiButton() then
        -- do some action for click, menu for example
        local ret = gg.choice({'Item 1', 'Item 2', 'Item 3'}) or os.exit()
        gg.alert('You selected:', ret)
    end
    gg.sleep(100)
end
```

## Memory Ranges Related Methods

### getRanges
```lua
int getRanges()
```
Returns memory regions as bit mask of `REGION_*`.

### setRanges
```lua
nil setRanges(int ranges)
```
Sets memory regions to bit mask of `REGION_*`.

- **Examples:**
```lua
gg.setRanges(gg.REGION_C_HEAP)
gg.setRanges(bit32.bor(gg.REGION_C_HEAP, gg.REGION_C_ALLOC, gg.REGION_ANONYMOUS))
gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS)
```

## Search Related Methods

### searchNumber
```lua
mixed searchNumber(string text, int type = gg.TYPE_AUTO, bool encrypted = false, int sign = gg.SIGN_EQUAL, long memoryFrom = 0, long memoryTo = -1, long limit = 0)
```
Performs or refines number search.

- **Parameters:**
  - `text`: Search string (English locale).
  - `type`: `TYPE_*`.
  - `encrypted`: Search encrypted.
  - `sign`: `SIGN_*`.
  - `memoryFrom`: Start address.
  - `memoryTo`: End address.
  - `limit`: Max results (0 for all).

- **Returns:** `true` or error string.

- **Examples:**
```lua
-- number search
gg.searchNumber('10', gg.TYPE_DWORD)
-- encrypted search
gg.searchNumber('-10', gg.TYPE_DWORD, true)
-- range search
gg.searchNumber('10~20', gg.TYPE_DWORD, false, gg.SIGN_NOT_EQUAL)
-- group search with ranges
gg.searchNumber('6~7;7;1~2;0;0;0;0;6~8::29', gg.TYPE_DWORD)
-- search for HEX '5C E3 0B 4B 90 9B 11 7B'
gg.searchNumber('5Ch;E3h;0Bh;4Bh;90h;9Bh;11h;7Bh::8', gg.TYPE_BYTE)
gg.searchNumber('h 5C E3 0B 4B 90 9B 11 7B')
-- search for HEX '5C ?? 0B 4B ?? 9B 11 7B' where '??' can be any byte
gg.searchNumber('5Ch;0~~0;0Bh;4Bh;0~~0;9Bh;11h;7Bh::8', gg.TYPE_BYTE)
-- search for text UTF-8 'şuşpançik' - type forced to gg.TYPE_BYTE
gg.searchNumber(':şuşpançik')
-- search for text UTF-16LE 'şuşandra' - type forced to gg.TYPE_WORD
gg.searchNumber(';şuşandra')
-- search for HEX '5C E3 0B' + UTF-8 'şuşpançik' + HEX '9B 11 7B' - type forced to gg.TYPE_BYTE
gg.searchNumber('Q 5C E3 0B \'şuşpançik\' 9B 11 7B')
-- ... (more in original doc)
-- search for ARM opcode
gg.searchNumber('~A MOV R1, R2', gg.TYPE_DWORD)
-- start new search
gg.clearResults()
gg.searchNumber('10', gg.TYPE_DWORD)
-- refine search if present some results in the result list
gg.searchNumber('10', gg.TYPE_DWORD)
```

### refineNumber
```lua
mixed refineNumber(string text, int type = gg.TYPE_AUTO, bool encrypted = false, int sign = gg.SIGN_EQUAL, long memoryFrom = 0, long memoryTo = -1, long limit = 0)
```
Refines number search.

- **Parameters:** Same as `searchNumber`.

- **Examples:**
```lua
gg.refineNumber('10', gg.TYPE_DWORD)
gg.refineNumber('-10', gg.TYPE_DWORD, true)
gg.refineNumber('10~20', gg.TYPE_DWORD, false, gg.SIGN_NOT_EQUAL)
gg.refineNumber('6~7;7;1~2;0;0;0;0;6~8::29', gg.TYPE_DWORD)
gg.refineNumber('5Ch;E3h;0Bh;4Bh;90h;9Bh;11h;7Bh::8', gg.TYPE_BYTE)
gg.refineNumber('5Ch;0~~0;0Bh;4Bh;0~~0;9Bh;11h;7Bh::8', gg.TYPE_BYTE)
-- do nothing
gg.clearResults()
gg.refineNumber('10', gg.TYPE_DWORD)
-- refine search
gg.refineNumber('10', gg.TYPE_DWORD)
-- see searchNumber for other search examples
```

### startFuzzy
```lua
mixed startFuzzy(int type = gg.TYPE_AUTO, long memoryFrom = 0, long memoryTo = -1, long limit = 0)
```
Starts fuzzy search.

- **Parameters:**
  - `type`: `TYPE_*`.
  - `memoryFrom`: Start address.
  - `memoryTo`: End address.
  - `limit`: Max results.

- **Examples:**
```lua
gg.startFuzzy()
gg.startFuzzy(gg.TYPE_DWORD)
gg.startFuzzy(gg.TYPE_FLOAT)
gg.startFuzzy(gg.TYPE_BYTE, 0x9000, 0xA09000)
```

### searchFuzzy
```lua
mixed searchFuzzy(string difference = '0', int sign = gg.SIGN_FUZZY_EQUAL, int type = gg.TYPE_AUTO, long memoryFrom = 0, long memoryTo = -1, long limit = 0)
```
Refines fuzzy search.

- **Parameters:**
  - `difference`: Difference (English locale).
  - `sign`: `SIGN_FUZZY_*`.
  - `type`: `TYPE_*`.
  - `memoryFrom`: Start address.
  - `memoryTo`: End address.
  - `limit`: Max results.

- **Examples:**
```lua
gg.searchFuzzy()
-- value not changed
gg.searchFuzzy('0', gg.SIGN_FUZZY_NOT_EQUAL)
-- value changed
gg.searchFuzzy('0', gg.SIGN_FUZZY_GREATER)
-- value increased
gg.searchFuzzy('0', gg.SIGN_FUZZY_LESS)
-- value decreased
gg.searchFuzzy('15')
-- value increased by 15
gg.searchFuzzy('-115')
-- value decreased by 115
```

### searchAddress
```lua
mixed searchAddress(string text, long mask = -1, int type = gg.TYPE_AUTO, int sign = gg.SIGN_EQUAL, long memoryFrom = 0, long memoryTo = -1, long limit = 0)
```
Performs or refines address search.

- **Parameters:**
  - `text`: Search string.
  - `mask`: Mask (default -1).
  - `type`: `TYPE_*`.
  - `sign`: `SIGN_EQUAL` or `SIGN_NOT_EQUAL`.
  - `memoryFrom`: Start address.
  - `memoryTo`: End address.
  - `limit`: Max results.

- **Examples:**
```lua
gg.searchAddress('A20', 0xFFFFFFFF)
gg.searchAddress('B20', 0xFF0, gg.TYPE_DWORD, gg.SIGN_NOT_EQUAL)
gg.searchAddress('0B?0', 0xFFF, gg.TYPE_FLOAT)
gg.searchAddress('??F??', 0xBA0, gg.TYPE_BYTE, gg.SIGN_NOT_EQUAL, 0x9000, 0xA09000)
-- start new search
gg.clearResults()
gg.searchAddress('A20', 0xFFFFFFFF)
-- refine search
gg.searchAddress('A20', 0xFFFFFFFF)
```

### refineAddress
```lua
mixed refineAddress(string text, long mask = -1, int type = gg.TYPE_AUTO, int sign = gg.SIGN_EQUAL, long memoryFrom = 0, long memoryTo = -1, long limit = 0)
```
Refines address search.

- **Parameters:** Same as `searchAddress`.

- **Examples:**
```lua
gg.refineAddress('A20', 0xFFFFFFFF)
gg.refineAddress('B20', 0xFF0, gg.TYPE_DWORD, gg.SIGN_NOT_EQUAL)
gg.refineAddress('0B?0', 0xFFF, gg.TYPE_FLOAT)
gg.refineAddress('??F??', 0xBA0, gg.TYPE_BYTE, gg.SIGN_NOT_EQUAL, 0x9000, 0xA09000)
-- do nothing
gg.clearResults()
gg.refineAddress('A20', 0xFFFFFFFF)
-- refine search
gg.refineAddress('A20', 0xFFFFFFFF)
```

### searchPointer
```lua
mixed searchPointer(int maxOffset, long memoryFrom = 0, long memoryTo = -1, long limit = 0)
```
Searches for pointers to current search results.

- **Parameters:**
  - `maxOffset`: Max offset (0-65535).
  - `memoryFrom`: Start address.
  - `memoryTo`: End address.
  - `limit`: Max results.

- **Examples:**
```lua
gg.searchNumber('10', gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 5) -- search some values
gg.searchPointer(512) -- search for possible pointers to values finded before
gg.searchNumber('10', gg.TYPE_DWORD) -- search some values
gg.loadResults(gg.getResults(5))
gg.searchPointer(512) -- search for possible pointers to values loaded before
local t = {}
t[1] = {}
t[1].address = 0x18004030 -- some desired address
t[1].flags = gg.TYPE_DWORD
t[2] = {}
t[2].address = 0x18004040 -- another desired address
t[2].flags = gg.TYPE_BYTE
gg.loadResults(t)
gg.searchPointer(512) -- search for possible pointers to values loaded before
```

## Results Related Methods

### getResultsCount
```lua
long getResultsCount()
```
Gets number of found results.

- **Examples:**
```lua
gg.searchNumber('10', gg.TYPE_DWORD)
print('Found: ', gg.getResultsCount())
```

### getResults
```lua
mixed getResults(int maxCount, int skip = 0, long addressMin = nil, long addressMax = nil, string valueMin = nil, string valueMax = nil, int type = nil, string fractional = nil, int pointer = nil)
```
Loads results into list and returns as table.

- **Parameters:**
  - `maxCount`: Max to load.
  - `skip`: Skip from beginning.
  - `addressMin`: Min address.
  - `addressMax`: Max address.
  - `valueMin`: Min value (string).
  - `valueMax`: Max value (string).
  - `type`: `TYPE_*` set.
  - `fractional`: Fractional filter (e.g., '0.5', '!0.0').
  - `pointer`: `POINTER_*` set.

- **Returns:** Table with results or error.

- **Examples:**
```lua
gg.clearResults()
gg.startFuzzy(gg.TYPE_AUTO)
local r = gg.getResults(5)
print('First 5 results: ', r)
print('First result: ', r[1])
print('First result address: ', r[1].address)
print('First result value: ', r[1].value)
print('First result type: ', r[1].flags)
r = gg.getResults(3, 2)
print('Skip 2 items and get next 3: ', r)
r = gg.getResults(3, nil, 0x80000000, 0xF0000000)
print('Address between 0x80000000 and 0xF0000000: ', r)
r = gg.getResults(3, nil, nil, nil, 23, 45)
print('Value between 23 and 45: ', r)
r = gg.getResults(3, nil, nil, nil, nil, nil, gg.TYPE_DWORD | gg.TYPE_FLOAT)
print('Dword or Float: ', r)
r = gg.getResults(3, nil, nil, nil, nil, nil, nil, '0.5')
print('Only with fractional part equal 0.5: ', r)
r = gg.getResults(3, nil, nil, nil, nil, nil, nil, '!0.0')
print('Only with fractional part not equal 0.0: ', r)
r = gg.getResults(3, nil, nil, nil, nil, nil, nil, nil, gg.POINTER_READ_ONLY)
print('Only pointers to read-only memory: ', r)
```

### editAll
```lua
mixed editAll(string value, int type)
```
Edits all search results.

- **Parameters:**
  - `value`: Value string (English locale).
  - `type`: `TYPE_*`.

- **Returns:** Count of changes or error.

- **Examples:**
```lua
gg.searchNumber('10', gg.TYPE_DWORD)
gg.getResults(5)
gg.editAll('15', gg.TYPE_DWORD)
-- with float:
gg.searchNumber('10.1', gg.TYPE_FLOAT)
gg.getResults(5)
gg.editAll('15.2', gg.TYPE_FLOAT)
-- with XOR mode
gg.searchNumber('10X4', gg.TYPE_DWORD)
gg.getResults(5)
gg.editAll('15X4', gg.TYPE_DWORD)
-- edit few values at once
gg.searchNumber('10', gg.TYPE_DWORD)
gg.getResults(5)
gg.editAll('7;13;43;24;11', gg.TYPE_DWORD)
-- edit HEX
gg.searchNumber('h 5C E3 0B')
gg.getResults(30)
gg.editAll('h 4B 90 9B', gg.TYPE_BYTE)
-- edit text UTF-8
gg.searchNumber(':şuşpançik')
gg.getResults(100000)
gg.editAll(':şUşPaNçIk', gg.TYPE_BYTE)
-- edit text UTF-16LE
gg.searchNumber(';şuşandra')
gg.getResults(100000)
gg.editAll(';şUşAnDrA', gg.TYPE_WORD) -- UTF-16LE use WORD not BYTE!
-- edit HEX + UTF-8
gg.searchNumber("Q 5C E3 0B 'şuşpançik' 9B 11 7B")
gg.getResults(100000)
gg.editAll("Q 43 12 34 'şUşPaNçIk' 9F 1A 70", gg.TYPE_BYTE)
-- edit HEX + UTF-16LE
gg.searchNumber('Q 5C E3 0B "şuşandra" 9B 11 7B')
gg.getResults(100000)
gg.editAll('Q 41 F7 87 "şUşAnDrA" 9B 18 7B', gg.TYPE_BYTE)
-- edit HEX + UTF-8 + UTF-16LE
gg.searchNumber('Q 5C E3 0B \'şuşpançik\' 9B "şuşandra" 11 7B')
gg.getResults(100000)
gg.editAll('Q 41 F7 87 \'şUşPaNçIk\' 04 "şUşAnDrA" 71 3B', gg.TYPE_BYTE)
-- edit ARM opcodes
gg.searchNumber('~A MOV R1, R2', gg.TYPE_DWORD)
gg.getResults(100000)
gg.editAll('~A MOV R2, R3', gg.TYPE_DWORD)
```

### clearResults
```lua
nil clearResults()
```
Clears search results list.

### removeResults
```lua
mixed removeResults(table results)
```
Removes results from list.

- **Parameters:**
  - `results`: List of tables with address/flags.

- **Returns:** `true` or error.

- **Examples:**
```lua
gg.searchNumber('10', gg.TYPE_DWORD)
local r = gg.getResults(5)
print('Remove first 5 results: ', gg.removeResults(r))
```

### loadResults
```lua
mixed loadResults(table results)
```
Loads results from table (clears existing).

- **Parameters:**
  - `results`: List of tables with address/flags.

- **Returns:** `true` or error.

- **Examples:**
```lua
gg.searchNumber('10', gg.TYPE_DWORD)
local r = gg.getResults(5)
print('load first 5 results: ', gg.loadResults(r))
local t = {}
t[1] = {}
t[1].address = 0x18004030 -- some desired address
t[1].flags = gg.TYPE_DWORD
t[2] = {}
t[2].address = 0x18004040 -- another desired address
t[2].flags = gg.TYPE_BYTE
print('load from table: ', gg.loadResults(t))
```

### getSelectedResults
```lua
mixed getSelectedResults()
```
Returns selected search results.

- **Returns:** Table or error.

- **Examples:**
```lua
gg.searchNumber('10', gg.TYPE_DWORD)
gg.getResults(5)
print('Selected: ', gg.getSelectedResults())
```

## Values Related Methods

### setValues
```lua
mixed setValues(table values)
```
Sets values for list of items.

- **Parameters:**
  - `values`: List of tables with address/value/flags.

- **Returns:** `true` or error.

- **Examples:**
```lua
gg.searchNumber('10', gg.TYPE_DWORD)
local r = gg.getResults(5) -- load items
r[1].value = '15'
print('Edited: ', gg.setValues(r))
local t = {}
t[1] = {}
t[1].address = 0x18004030 -- some desired address
t[1].flags = gg.TYPE_DWORD
t[1].value = 12345
t[2] = {}
t[2].address = 0x18004040 -- another desired address
t[2].flags = gg.TYPE_BYTE
t[2].value = '7Fh'
print('Set', t, gg.setValues(t))
-- edit ARM opcode
gg.searchNumber('~A MOV R1, R2', gg.TYPE_DWORD)
local r = gg.getResults(5) -- load items
r[1].value = '~A MOV R2, R3'
print('Edited: ', gg.setValues(r))
```

### getValues
```lua
mixed getValues(table values)
```
Gets values for list of items.

- **Parameters:**
  - `values`: List of tables with address/flags.

- **Returns:** New table with values or error.

- **Examples:**
```lua
gg.searchNumber('10', gg.TYPE_DWORD)
local r = gg.getResults(5) -- load items
r = gg.getValues(r) -- refresh items values
print('First 5 results: ', r)
print('First result: ', r[1])
print('First result address: ', r[1].address)
print('First result value: ', r[1].value)
print('First result type: ', r[1].flags)
local t = {}
t[1] = {}
t[1].address = 0x18004030 -- some desired address
t[1].flags = gg.TYPE_DWORD
t[2] = {}
t[2].address = 0x18004040 -- another desired address
t[2].flags = gg.TYPE_BYTE
t = gg.getValues(t)
print(t)
```

### getValuesRange
```lua
mixed getValuesRange(table values)
```
Gets memory regions for values.

- **Parameters:**
  - `values`: Address list or tables with address.

- **Returns:** Table with region codes or error.

- **Examples:**
```lua
print('1: ', gg.getValuesRange({0x9000, 0x9010, 0x9020, 0x9030}))
-- table as a list of addresses
gg.searchNumber('10', gg.TYPE_DWORD)
local r = gg.getResults(5)
print('2: ', r, gg.getValuesRange(r))
-- table as a list of tables with the address field
```

## Memory Editor Related Methods

### gotoAddress
```lua
nil gotoAddress(long address)
```
Goes to address in memory editor.

- **Parameters:**
  - `address`: Target address.

### getSelectedElements
```lua
mixed getSelectedElements()
```
Returns selected addresses in memory editor.

- **Returns:** Table with addresses or error.

- **Examples:**
```lua
print('Selected: ', gg.getSelectedElements())
```

## Pause Related Methods

### processPause
```lua
bool processPause()
```
Pauses selected process.

- **Returns:** `true` on success.

### processResume
```lua
bool processResume()
```
Resumes paused process.

- **Returns:** `true` on success.

### processToggle
```lua
bool processToggle()
```
Toggles pause state.

- **Returns:** `true` on success.

### isProcessPaused
```lua
bool isProcessPaused()
```
Gets pause state.

- **Returns:** `true` if paused.

## Speedhack Related Methods

### timeJump
```lua
mixed timeJump(string time)
```
Performs time jump.

- **Parameters:**
  - `time`: Time string (English locale, e.g., '1:125:2:41:18').

- **Returns:** `true` or error.

- **Examples:**
```lua
print('jump 1:', gg.timeJump('42345678'))
-- jump for 1 year 125 days 2 hours 41 minutes 18 seconds
print('jump 2:', gg.timeJump('1:125:2:41:18'))
-- same as above
print('jump 3:', gg.timeJump('5:13'))
-- jump for 5 minutes 13 seconds
print('jump 4:', gg.timeJump('7:3:1'))
-- jump for 7 hours 3 minutes 1 seconds
print('jump 5:', gg.timeJump('3600'))
-- jump for 1 hour
print('jump 6:', gg.timeJump('2:15:54:32'))
-- jump for 2 days 15 hours 54 minutes 32 seconds
print('jump 7:', gg.timeJump('3600.15'))
-- jump for 1 hour 0.15 seconds
print('jump 8:', gg.timeJump('7:3:1.519'))
-- jump for 7 hours 3 minutes 1.519 seconds
```

### getSpeed
```lua
double getSpeed()
```
Gets current speedhack speed.

### setSpeed
```lua
mixed setSpeed(double speed)
```
Sets speedhack speed (loads if not loaded).

- **Parameters:**
  - `speed`: Range [1.0E-9; 1.0E9].

- **Returns:** `true` or error.

## Saved Lists Related Methods

### loadList
```lua
mixed loadList(string file, int flags = 0)
```
Loads saved list from file.

- **Parameters:**
  - `file`: File path.
  - `flags`: `LOAD_*` set.

- **Returns:** `true` or error.

- **Examples:**
```lua
print('loadList:', gg.loadList('/sdcard/Notes/gg.victim.txt'))
print('loadList:', gg.loadList('/sdcard/Notes/gg.victim.txt', 0))
print('loadList:', gg.loadList('/sdcard/Notes/gg.victim.txt', gg.LOAD_APPEND))
print('loadList:', gg.loadList('/sdcard/Notes/gg.victim.txt', gg.LOAD_VALUES_FREEZE))
print('loadList:', gg.loadList('/sdcard/Notes/gg.victim.txt', gg.LOAD_APPEND | gg.LOAD_VALUES))
```

### saveList
```lua
mixed saveList(string file, int flags = 0)
```
Saves saved list to file.

- **Parameters:**
  - `file`: File path.
  - `flags`: `SAVE_*` set.

- **Returns:** `true` or error.

- **Examples:**
```lua
print('saveList:', gg.saveList('/sdcard/Notes/gg.victim.txt'))
print('saveList:', gg.saveList('/sdcard/Notes/gg.victim.txt', 0))
print('saveList:', gg.saveList('/sdcard/Notes/gg.victim.txt', gg.SAVE_AS_TEXT))
```

### clearList
```lua
mixed clearList()
```
Clears saved list.

- **Returns:** `true` or error.

- **Examples:**
```lua
print('clearList:', gg.clearList())
```

### addListItems
```lua
mixed addListItems(table items)
```
Adds items to saved list.

- **Parameters:**
  - `items`: List of tables with address/value/flags/name/freeze/etc.

- **Returns:** `true` or error.

- **Examples:**
```lua
-- retrieving a table from another call
gg.searchNumber('10', gg.TYPE_DWORD)
t = gg.getResults(5) -- load items
t[1].value = '15'
t[1].freeze = true
print('addListItems: ', gg.addListItems(t))
-- creating a table as a list of items
t = {}
t[1] = {}
t[1].address = 0x18004030 -- some desired address
t[1].flags = gg.TYPE_DWORD
t[1].value = 12345
t[2] = {}
t[2].address = 0x18004040 -- another desired address
t[2].flags = gg.TYPE_BYTE
t[2].value = '7Fh'
t[2].freeze = true
t[3] = {}
t[3].address = 0x18005040 -- another desired address
t[3].flags = gg.TYPE_DWORD
t[3].value = '777'
t[3].freeze = true
t[3].freezeType = gg.FREEZE_MAY_INCREASE
t[4] = {}
t[4].address = 0x18007040 -- another desired address
t[4].flags = gg.TYPE_DWORD
t[4].value = '7777'
t[4].freeze = true
t[4].freezeType = gg.FREEZE_IN_RANGE
t[4].freezeFrom = '6666'
t[4].freezeTo = '8888'
print('addListItems: ', gg.addListItems(t))
-- The first 7 results are frozen with a value of 8.
gg.searchNumber('10', gg.TYPE_DWORD)
local t = gg.getResults(7)
for i, v in ipairs(t) do
    t[i].value = '8'
    t[i].freeze = true
end
gg.addListItems(t)
```

### getListItems
```lua
mixed getListItems()
```
Returns saved list contents as table.

- **Returns:** Table or error.

- **Examples:**
```lua
local r = gg.getListItems()
print('Items: ', r)
print('First item: ', r[1])
print('First item address: ', r[1].address)
print('First item value: ', r[1].value)
print('First item type: ', r[1].flags)
print('First item name: ', r[1].name)
print('First item freeze: ', r[1].freeze)
print('First item freeze type: ', r[1].freezeType)
print('First item freeze from: ', r[1].freezeFrom)
print('First item freeze to: ', r[1].freezeTo)
```

### removeListItems
```lua
mixed removeListItems(table items)
```
Removes items from saved list.

- **Parameters:**
  - `items`: List of tables with address or list of addresses.

- **Returns:** `true` or error.

- **Examples:**
```lua
-- retrieving a table from another call
t = gg.getListItems()
print('removeListItems: ', gg.removeListItems(t))
-- creating a table as a list of items
t = {}
t[1] = {}
t[1].address = 0x18004030 -- some desired address
t[2] = {}
t[2].address = 0x18004040 -- another desired address
print('removeListItems: ', gg.removeListItems(t))
-- creating a table as a list of addresses
t = {}
t[1] = 0x18004030 -- some desired address
t[2] = 0x18004040 -- another desired address
print('removeListItems: ', gg.removeListItems(t))
```

### getSelectedListItems
```lua
mixed getSelectedListItems()
```
Returns selected saved list items.

- **Returns:** Table or error.

- **Examples:**
```lua
print('Selected: ', gg.getSelectedListItems())
```

## Debug Related Methods

### getFile
```lua
string getFile()
```
Gets current script filename.

- **Returns:** Filename string.

- **Examples:**
```lua
print(gg.getFile()) -- e.g., '/sdcard/Notes/gg.example.lua'
```

### getLine
```lua
int getLine()
```
Gets current script line number.

- **Returns:** Line number.

- **Examples:**
```lua
print(gg.getLine()) -- e.g., 24
```

## Locale Related Methods

### getLocale
```lua
string getLocale()
```
Gets current GameGuardian locale.

- **Returns:** Locale string (e.g., 'en_US').

### numberToLocale
```lua
string numberToLocale(string num)
```
Replaces separators with locale-specific ones.

- **Examples:**
```lua
print(gg.numberToLocale('1,234.567')) -- print '1234,567' for German locale
```

### numberFromLocale
```lua
string numberFromLocale(string num)
```
Replaces locale separators with English ones.

- **Examples:**
```lua
print(gg.numberFromLocale('1.234,567')) -- print '1234.567' for German locale
```

## Public Attributes

### ANDROID_SDK_INT
`string ANDROID_SDK_INT`  
SDK version of current Android.

- **Examples:**
```lua
print("ANDROID_SDK_INT: "..gg.ANDROID_SDK_INT) -- e.g., 27
```

### PACKAGE
`string PACKAGE`  
GameGuardian package name.

- **Examples:**
```lua
print("GG package: "..gg.PACKAGE) -- e.g., 'catch_.me_.if_.you_.can_'
```

## GameGuardian Version Info

### VERSION
`string VERSION`  
Text version.

- **Examples:**
```lua
print("GG string version: "..gg.VERSION) -- e.g., '8.31.1'
```

### VERSION_INT
`int VERSION_INT`  
Numeric version.

- **Examples:**
```lua
print("GG numeric version: "..gg.VERSION_INT) -- e.g., 83101
```

### BUILD
`int BUILD`  
Build number.

- **Examples:**
```lua
print("GG build number: "..gg.BUILD) -- e.g., 5645
```

## Dirs for Files

### FILES_DIR
`string FILES_DIR`  
Internal files directory.

- **Examples:**
```lua
print("Files dir: "..gg.FILES_DIR) -- e.g., '/data/data/catch_.me_.if_.you_.can_/files'
```

### CACHE_DIR
`string CACHE_DIR`  
Internal cache directory.

- **Examples:**
```lua
print("Cache dir: "..gg.CACHE_DIR) -- e.g., '/data/data/catch_.me_.if_.you_.can_/cache'
```

### EXT_FILES_DIR
`string EXT_FILES_DIR`  
External files directory.

- **Examples:**
```lua
print("External files dir: "..gg.EXT_FILES_DIR) -- e.g., '/sdcard/Android/data/catch_.me_.if_.you_.can_/files'
```

### EXT_CACHE_DIR
`string EXT_CACHE_DIR`  
External cache directory.

- **Examples:**
```lua
print("External cache dir: "..gg.EXT_CACHE_DIR) -- e.g., '/sdcard/Android/data/catch_.me_.if_.you_.can_/cache'
```

### EXT_STORAGE
`string EXT_STORAGE`  
Primary external storage.

- **Examples:**
```lua
print("External storage: "..gg.EXT_STORAGE) -- e.g., '/mnt/sdcard'
local file = io.open(gg.EXT_STORAGE.."/test_log.txt", "w")
file:write("This is log file")
file:close()
```

## Type Flags (TYPE_*)

See functions like `searchNumber`, `getResults`, etc.

- `int TYPE_AUTO`: Type Auto.
- `int TYPE_BYTE`: Type Byte (1 byte, align 1).
- `int TYPE_WORD`: Type Word (2 bytes, align 2).
- `int TYPE_DWORD`: Type Dword (4 bytes, align 4).
- `int TYPE_XOR`: Type Xor (4 bytes, align 4).
- `int TYPE_FLOAT`: Type Float (4 bytes, align 4).
- `int TYPE_QWORD`: Type Qword (8 bytes, align 4/8).
- `int TYPE_DOUBLE`: Type Double (8 bytes, align 4/8).

## Search (Expect Fuzzy) Sign Flags (SIGN_*)

See `searchNumber`, `refineNumber`.

- `int SIGN_EQUAL`
- `int SIGN_NOT_EQUAL`
- `int SIGN_LESS_OR_EQUAL`
- `int SIGN_GREATER_OR_EQUAL`

## Fuzzy Sign Flags (SIGN_FUZZY_*)

See `searchFuzzy`.

- `int SIGN_FUZZY_EQUAL`
- `int SIGN_FUZZY_NOT_EQUAL`
- `int SIGN_FUZZY_LESS`
- `int SIGN_FUZZY_GREATER`

## Memory Regions Flags (REGION_*)

See `getRanges`, `setRanges`.

- `int REGION_JAVA_HEAP`: "Jh: Java heap"
- `int REGION_C_HEAP`: "Ch: C++ heap"
- `int REGION_C_ALLOC`: "Ca: C++ alloc"
- `int REGION_C_DATA`: "Cd: C++ .data"
- `int REGION_C_BSS`: "Cb: C++ .bss"
- `int REGION_PPSSPP`: "PS: PPSSPP"
- `int REGION_ANONYMOUS`: "A: Anonymous"
- `int REGION_JAVA`: "J: Java"
- `int REGION_STACK`: "S: Stack"
- `int REGION_ASHMEM`: "As: Ashmem"
- `int REGION_VIDEO`: "V: Video"
- `int REGION_OTHER`: "O: Other (slow)"
- `int REGION_BAD`: "B: Bad (dangerous)"
- `int REGION_CODE_APP`: "Xa: Code app (dangerous)"
- `int REGION_CODE_SYS`: "Xs: Code system (dangerous)"

## Flags for Load the Saved Lists (LOAD_*)

See `loadList`.

- `int LOAD_VALUES_FREEZE`: Load values and freeze.
- `int LOAD_VALUES`: Load values.
- `int LOAD_APPEND`: Append to list.

## Flags for Save the Saved Lists (SAVE_*)

See `saveList`.

- `int SAVE_AS_TEXT`: Save list as text.

## Flags for Field "freezeType" (FREEZE_*)

See `addListItems`, `getListItems`, `getSelectedListItems`.

- `int FREEZE_NORMAL`: Freezes value.
- `int FREEZE_MAY_INCREASE`: Allows increase.
- `int FREEZE_MAY_DECREASE`: Allows decrease.
- `int FREEZE_IN_RANGE`: Allows in range.

## Flags for Field "mode" (PROT_*)

See `allocatePage`.

- `int PROT_NONE`: No access.
- `int PROT_READ`: Read.
- `int PROT_WRITE`: Write.
- `int PROT_EXEC`: Execute.

## Flags for the Pointer Filter in getResults (POINTER_*)

See `getResults`.

- `int POINTER_NO`: Not a pointer.
- `int POINTER_READ_ONLY`: To read-only.
- `int POINTER_WRITABLE`: To writable.
- `int POINTER_EXECUTABLE`: To executable.
- `int POINTER_EXECUTABLE_WRITABLE`: To executable and writable.

## Flags for dumpMemory (DUMP_*)

See `dumpMemory`.

- `int DUMP_SKIP_SYSTEM_LIBS`: Skip system libs.

## Constants for the Result in getActiveTab (TAB_*)

See `getActiveTab`.

- `int TAB_SETTINGS`: Settings tab.
- `int TAB_SEARCH`: Search tab.
- `int TAB_SAVED_LIST`: Saved list tab.
- `int TAB_MEMORY_EDITOR`: Memory editor tab.

## Constants for the Type in disasm (ASM_*)

See `disasm`.

- `int ASM_ARM`: Arm x32.
- `int ASM_THUMB`: Thumb.
- `int ASM_ARM64`: ARM x64.

## Detailed Description

The `gg` table provides access to GameGuardian functions for scripting. Use `print(gg)` to see all fields/methods.

For more info, visit [GameGuardian.net](https://gameguardian.net/) or the forum.

**License:** This reference is for educational purposes. GameGuardian usage may violate game terms.