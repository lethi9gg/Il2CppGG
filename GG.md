gg Class Reference
Table gg provides access to the GameGuardian functions. More...

Public Member Functions
mixed 	allocatePage (int mode=gg.PROT_READ|gg.PROT_EXEC, long address=0)
 	Allocated memory page (4 KB) in the target process. More...
 
string 	bytes (string text, string encoding='UTF-8')
 	Gets the text bytes in the specified encoding. More...
 
mixed 	copyMemory (long from, long to, int bytes)
 	Copy memory. More...
 
nil 	copyText (string text, bool fixLocale=true)
 	Copy text to the clipboard. More...
 
string 	disasm (int type, long address, int opcode)
 	Disassemble the specified value. More...
 
mixed 	dumpMemory (long from, long to, string dir, int flags=nil)
 	Dump memory to files on disk. More...
 
table 	getRangesList (string filter='')
 	Get the list of memory regions of the selected process. More...
 
mixed 	getTargetInfo ()
 	Get a table with information about the selected process if possible. More...
 
mixed 	getTargetPackage ()
 	Get the package name of the selected process, if possible. More...
 
bool 	isPackageInstalled (string pkg)
 	Check whether the specified application is installed on the system by the package name. More...
 
mixed 	makeRequest (string url, table headers={}, string data=nil)
 	Performs a GET or POST request over HTTP or HTTPS. More...
 
bool 	processKill ()
 	Force kill the selected process. More...
 
nil 	require (string version=nil, int build=0)
 	Checks the version of GameGuardian. More...
 
mixed 	saveVariable (mixed variable, string filename)
 	Saves the variable to a file. More...
 
nil 	skipRestoreState ()
 	Do not restore the state of the GameGuardian, after the script is completed. More...
 
nil 	sleep (int milliseconds)
 	Causes the currently executing script to sleep (temporarily cease execution) for the specified number of milliseconds, subject to the precision and accuracy of system timers and schedulers. More...
 
mixed 	unrandomizer (long qword=nil, long qincr=nil, double double_=nil, double dincr=nil)
 	Work with Unrandomizer. More...
 
Dialogs and toasts
Methods for show various dialogs and toasts.

nil 	toast (string text, bool fast=false)
 	Show the toast. More...
 
int 	alert (string text, string positive='ok', string negative=nil, string neutral=nil)
 	Displays a dialog with several buttons. More...
 
mixed 	prompt (table prompts, table defaults={}, table types={})
 	Displays the dialog for data entry. More...
 
mixed 	choice (table items, string selected=nil, string message=nil)
 	Displays the selection dialog from the list. More...
 
mixed 	multiChoice (table items, table selection={}, string message=nil)
 	Displays the multiple choice dialog. More...
 
GameGuardian UI related methods.
bool 	isVisible ()
 	Check if the GameGuardian UI is open. More...
 
nil 	setVisible (bool visible)
 	Open or close the GameGuardian UI. More...
 
int 	getActiveTab ()
 	Get active tab in the GameGuardian UI. More...
 
UI button related methods
nil 	showUiButton ()
 	Shows the UI button. More...
 
nil 	hideUiButton ()
 	Hides the UI button. More...
 
mixed 	isClickedUiButton ()
 	Gets the click status of the ui button. More...
 
Memory ranges related methods
int 	getRanges ()
 	Return memory regions as bit mask of flags REGION_*. More...
 
nil 	setRanges (int ranges)
 	Set memory regions to desired bit mask of flags REGION_*. More...
 
Search related methods
mixed 	searchNumber (string text, int type=gg.TYPE_AUTO, bool encrypted=false, int sign=gg.SIGN_EQUAL, long memoryFrom=0, long memoryTo=-1, long limit=0)
 	Perform a search for a number, with the specified parameters. More...
 
mixed 	refineNumber (string text, int type=gg.TYPE_AUTO, bool encrypted=false, int sign=gg.SIGN_EQUAL, long memoryFrom=0, long memoryTo=-1, long limit=0)
 	Perform a refine search for a number, with the specified parameters. More...
 
mixed 	startFuzzy (int type=gg.TYPE_AUTO, long memoryFrom=0, long memoryTo=-1, long limit=0)
 	Start a fuzzy search, with the specified parameters. More...
 
mixed 	searchFuzzy (string difference='0', int sign=gg.SIGN_FUZZY_EQUAL, int type=gg.TYPE_AUTO, long memoryFrom=0, long memoryTo=-1, long limit=0)
 	Refine fuzzy search, with the specified parameters. More...
 
mixed 	searchAddress (string text, long mask=-1, int type=gg.TYPE_AUTO, int sign=gg.SIGN_EQUAL, long memoryFrom=0, long memoryTo=-1, long limit=0)
 	Perform an address search with the specified parameters. More...
 
mixed 	refineAddress (string text, long mask=-1, int type=gg.TYPE_AUTO, int sign=gg.SIGN_EQUAL, long memoryFrom=0, long memoryTo=-1, long limit=0)
 	Perform an address refine search with the specified parameters. More...
 
mixed 	searchPointer (int maxOffset, long memoryFrom=0, long memoryTo=-1, long limit=0)
 	Searches for values that may be pointers to elements of the current search result. More...
 
Results related methods
long 	getResultsCount ()
 	Get the number of found results. More...
 
mixed 	getResults (int maxCount, int skip=0, long addressMin=nil, long addressMax=nil, string valueMin=nil, string valueMax=nil, int type=nil, string fractional=nil, int pointer=nil)
 	Load results into results list and return its as a table. More...
 
mixed 	editAll (string value, int type)
 	Edit all search results. More...
 
nil 	clearResults ()
 	Clear the list of search results. More...
 
mixed 	removeResults (table results)
 	Remove results from the list of results found. More...
 
mixed 	loadResults (table results)
 	Loads the search results from the table. More...
 
mixed 	getSelectedResults ()
 	Returns the selected items in the search results. More...
 
Values related methods
mixed 	setValues (table values)
 	Set the values for the list of items. More...
 
mixed 	getValues (table values)
 	Gets the values for the list of items. More...
 
mixed 	getValuesRange (table values)
 	Get the memory regions for the passed value table. More...
 
Memory editor related methods
nil 	gotoAddress (long address)
 	Go to the address in the memory editor. More...
 
mixed 	getSelectedElements ()
 	Returns the selected adresses in the memory editor. More...
 
Pause related methods
bool 	processPause ()
 	Pauses the selected process. More...
 
bool 	processResume ()
 	Resumes the selected process if it paused. More...
 
bool 	processToggle ()
 	Toggle the pause state of the selected process. More...
 
bool 	isProcessPaused ()
 	Get pause state of the selected process. More...
 
Speedhack related methods
mixed 	timeJump (string time)
 	Performs a time jump. More...
 
double 	getSpeed ()
 	Get the current speed from the speedhack. More...
 
mixed 	setSpeed (double speed)
 	Set the speed of the speedhack. More...
 
Saved lists related methods
mixed 	loadList (string file, int flags=0)
 	Load the saved list from the file. More...
 
mixed 	saveList (string file, int flags=0)
 	Save the saved list to the file. More...
 
mixed 	clearList ()
 	Clear the saved list. More...
 
mixed 	addListItems (table items)
 	Add items to the saved list. More...
 
mixed 	getListItems ()
 	Return the contents of the saved list as a table. More...
 
mixed 	removeListItems (table items)
 	Remove items from the saved list. More...
 
mixed 	getSelectedListItems ()
 	Returns the selected items in the saved lists. More...
 
Debug related methods.
string 	getFile ()
 	Gets the filename of the currently running script. More...
 
int 	getLine ()
 	Gets the current line number of the script being executed. More...
 
Locale related methods
string 	getLocale ()
 	Gets the string with the currently selected locale in the GameGuardian. More...
 
string 	numberToLocale (string num)
 	Replaces the decimal separator and the thousands separator with a localized version. More...
 
string 	numberFromLocale (string num)
 	Replaces the localized decimal separator and thousands separator with separators used in Lua (such as in English). More...
 
Public Attributes
string 	ANDROID_SDK_INT
 	The SDK version of the Android currently running on this device. More...
 
string 	PACKAGE
 	Package name of the GameGuardian. More...
 
GameGuardian version info
string 	VERSION
 	Text version of the GameGuardian. More...
 
int 	VERSION_INT
 	Numeric version of the GameGuardian. More...
 
int 	BUILD
 	Number build of the GameGuardian. More...
 
Dirs for files
string 	FILES_DIR
 	The path of the directory holding GameGuardian files. More...
 
string 	CACHE_DIR
 	The absolute path to the GameGuardian specific cache directory on the filesystem. More...
 
string 	EXT_FILES_DIR
 	The absolute path to the directory on the primary shared/external storage device where the GameGuardian can place persistent files it owns. More...
 
string 	EXT_CACHE_DIR
 	The absolute path to the GameGuardian specific directory on the primary shared/external storage device where the GameGuardian can place cache files it owns. More...
 
string 	EXT_STORAGE
 	The primary shared/external storage directory. More...
 
Type flags (TYPE_*)
See also
searchNumber, refineNumber, startFuzzy, searchFuzzy, searchAddress, refineAddress, getResults, editAll, removeResults, loadResults, getSelectedResults, setValues, getValues, addListItems, getListItems, getSelectedListItems
int 	TYPE_AUTO
 	Type Auto. More...
 
int 	TYPE_BYTE
 	Type Byte. More...
 
int 	TYPE_WORD
 	Type Word. More...
 
int 	TYPE_DWORD
 	Type Dword. More...
 
int 	TYPE_XOR
 	Type Xor. More...
 
int 	TYPE_FLOAT
 	Type Float. More...
 
int 	TYPE_QWORD
 	Type Qword. More...
 
int 	TYPE_DOUBLE
 	Type Double. More...
 
Search (expect fuzzy) sign flags (SIGN_*)
See also
searchNumber, refineNumber
int 	SIGN_EQUAL
 
int 	SIGN_NOT_EQUAL
 
int 	SIGN_LESS_OR_EQUAL
 
int 	SIGN_GREATER_OR_EQUAL
 
Fuzzy sign flags (SIGN_FUZZY_*)
See also
searchFuzzy
int 	SIGN_FUZZY_EQUAL
 
int 	SIGN_FUZZY_NOT_EQUAL
 
int 	SIGN_FUZZY_LESS
 
int 	SIGN_FUZZY_GREATER
 
Memory regions flags (REGION_*)
Flags used for set memory regions.

See also
getRanges, setRanges
int 	REGION_JAVA_HEAP
 	"Jh: Java heap" memory region. More...
 
int 	REGION_C_HEAP
 	"Ch: C++ heap" memory region. More...
 
int 	REGION_C_ALLOC
 	"Ca: C++ alloc" memory region. More...
 
int 	REGION_C_DATA
 	"Cd: C++ .data" memory region. More...
 
int 	REGION_C_BSS
 	"Cb: C++ .bss" memory region. More...
 
int 	REGION_PPSSPP
 	"PS: PPSSPP" memory region. More...
 
int 	REGION_ANONYMOUS
 	"A: Anonymous" memory region. More...
 
int 	REGION_JAVA
 	"J: Java" memory region. More...
 
int 	REGION_STACK
 	"S: Stack" memory region. More...
 
int 	REGION_ASHMEM
 	"As: Ashmem" memory region. More...
 
int 	REGION_VIDEO
 	"V: Video" memory region. More...
 
int 	REGION_OTHER
 	"O: Other (slow)" memory region. More...
 
int 	REGION_BAD
 	"B: Bad (dangerous)" memory region. More...
 
int 	REGION_CODE_APP
 	"Xa: Code app (dangerous)" memory region. More...
 
int 	REGION_CODE_SYS
 	"Xs: Code system (dangerous)" memory region. More...
 
Flags for load the saved lists (LOAD_*)
See also
loadList
int 	LOAD_VALUES_FREEZE
 	Load values and freeze. More...
 
int 	LOAD_VALUES
 	Load values. More...
 
int 	LOAD_APPEND
 	Append to list. More...
 
Flags for save the saved lists (SAVE_*)
See also
saveList
int 	SAVE_AS_TEXT
 	Save list as text. More...
 
Flags for field "freezeType" (FREEZE_*)
See also
addListItems, getListItems, getSelectedListItems
int 	FREEZE_NORMAL
 	Freezes the value, not allowing it to change. More...
 
int 	FREEZE_MAY_INCREASE
 	Allows the value to increase, but does not allow to decrease. More...
 
int 	FREEZE_MAY_DECREASE
 	Allows the value to decrease, but does not allow to increase. More...
 
int 	FREEZE_IN_RANGE
 	Allows the value to change only within specified range. More...
 
Flags for field "mode" (PROT_*)
See also
allocatePage
int 	PROT_NONE
 	Pages may not be accessed. More...
 
int 	PROT_READ
 	Pages may be read. More...
 
int 	PROT_WRITE
 	Pages may be written. More...
 
int 	PROT_EXEC
 	Pages may be executed. More...
 
Flags for the pointer filter in getResults (POINTER_*)
See also
getResults
int 	POINTER_NO
 	Not a pointer. More...
 
int 	POINTER_READ_ONLY
 	Pointer to read-only memory. More...
 
int 	POINTER_WRITABLE
 	Pointer to writable memory. More...
 
int 	POINTER_EXECUTABLE
 	Pointer to executable memory. More...
 
int 	POINTER_EXECUTABLE_WRITABLE
 	Pointer to executable and writable memory. More...
 
Flags for dumpMemory (DUMP_*)
See also
dumpMemory
int 	DUMP_SKIP_SYSTEM_LIBS
 	Skip system libraries. More...
 
Constants for the result in getActiveTab (TAB_*)
See also
getActiveTab
int 	TAB_SETTINGS
 	Settings tab. More...
 
int 	TAB_SEARCH
 	Search tab. More...
 
int 	TAB_SAVED_LIST
 	Saved list tab. More...
 
int 	TAB_MEMORY_EDITOR
 	Memory editor tab. More...
 
Constants for the type in disasm (ASM_*)
See also
disasm
int 	ASM_ARM
 	Arm x32. More...
 
int 	ASM_THUMB
 	Thumb. More...
 
int 	ASM_ARM64
 	ARM x64. More...
 
Detailed Description

Table gg provides access to the GameGuardian functions.

A global instance gg is automatically available. See the function details below for examples on usage.

You can print all availaible fields and methods via call print:

print(gg)
Member Function Documentation

◆ addListItems()
mixed addListItems	(	table 	items	)	
Add items to the saved list.

Parameters
items	A table with a list of items to add. Each element is a table with the following fields: address (long, required), value (string with a value, optional), flags (one of the constants TYPE_*, required), name (string, optional), freeze (boolean, optional, default false), freezeType (one of the constants FREEZE_*, optional, default FREEZE_NORMAL), freezeFrom (string, optional), freezeTo (string, optional). Values must be in English locale.
Returns
True or string with error.
Examples:
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
See also
getValues, getResults
◆ alert()
int alert	(	string 	text,
string 	positive = 'ok',
string 	negative = nil,
string 	neutral = nil 
)		
Displays a dialog with several buttons.

The return result depends on which of the buttons was pressed. The dialog can be canceled with the "Back" button (return code 0).

Parameters
text	Text message.
positive	Text for positive button. This button return code 1.
negative	Text for negative button. This button return code 2.
neutral	Text for neutral button. This button return code 3.
Returns
if dialog canceled - 0, else: 1 for positive, 2 for negative, 3 for neutral buttons.
Examples:
gg.alert('Script ended')
-- Show alert with single 'ok' button
gg.alert('Script ended', 'Yes')
-- Show alert with single 'Yes' button
gg.alert('A or B?', 'A', 'B')
-- Show alert with two buttons
gg.alert('A or C?', 'A', nil, 'C')
-- Show alert with two buttons
gg.alert('A or B or C?', 'A', 'B', 'C')
-- Show alert with three buttons
See also
toast
choice
multiChoice
◆ allocatePage()
mixed allocatePage	(	int 	mode = gg.PROT_READ | gg.PROT_EXEC,
long 	address = 0 
)		
Allocated memory page (4 KB) in the target process.

Parameters
mode	Bit mask of flags PROT_*.
address	If is not 0, then the kernel takes it as a hint about where to place the page; on Android, the page will be allocated at a nearby address page boundary.
Returns
Address of the page or string with error.
Examples:
print('allocatePage 1: ', string.format('0x%08x', gg.allocatePage()))
print('allocatePage 2: ', string.format('0x%08x', gg.allocatePage(gg.PROT_READ | gg.PROT_EXEC)))
print('allocatePage 3: ', string.format('0x%08x', gg.allocatePage(gg.PROT_READ | gg.PROT_WRITE)))
print('allocatePage 4: ', string.format('0x%08x', gg.allocatePage(gg.PROT_READ)))
print('allocatePage 5: ', string.format('0x%08x', gg.allocatePage(gg.PROT_READ | gg.PROT_WRITE, 0x12345)))
◆ bytes()
string bytes	(	string 	text,
string 	encoding = 'UTF-8' 
)		
Gets the text bytes in the specified encoding.

Parameters
text	
encoding	Possible values: 'ISO-8859-1', 'US-ASCII', 'UTF-16', 'UTF-16BE', 'UTF-16LE', 'UTF-8'
Returns
A table with a set of bytes in the specified encoding.
Examples:
print('UTF-8', gg.bytes('example'))
print('UTF-8', gg.bytes('example', 'UTF-8'))
print('UTF-16', gg.bytes('example', 'UTF-16LE'))
◆ choice()
mixed choice	(	table 	items,
string 	selected = nil,
string 	message = nil 
)		
Displays the selection dialog from the list.

The list is made up of the items table. Selected sets the index of the table that will be selected by default. Items must be numberic-array if you want show items in specified order.

Parameters
items	Table with items for choice.
selected	Is not specified or is specified as nil, then the list will be without the default choice.
message	Specifies the optional title of the dialog box.
Returns
nil if the dialog has been canceled, or the index of the selected item.
Examples:
print('1: ', gg.choice({'A', 'B', 'C', 'D'}))
-- show list of 4 items
print('2: ', gg.choice({'A', 'B', 'C', 'D'}, 2))
-- show list of 4 items with selected 2 item
print('3: ', gg.choice({'A', 'B', 'C', 'D'}, 3, 'Select letter:'))
-- show list of 4 items with selected 3 item and message
print('4: ', gg.choice({'A', 'B', 'C', 'D'}, nil, 'Select letter:'))
-- show list of 4 items without selection and message
See also
alert
multiChoice
prompt
◆ clearList()
mixed clearList	(		)	
Clear the saved list.

Returns
true or string with error.
Examples:
print('clearList:', gg.clearList())
◆ clearResults()
nil clearResults	(		)	
Clear the list of search results.

See also
removeResults
◆ copyMemory()
mixed copyMemory	(	long 	from,
long 	to,
int 	bytes 
)		
Copy memory.

Parameters
from	Address for source of copy.
to	Address for destination of copy.
bytes	Amount bytes to copy.
Returns
true or string with error.
Examples:
print('copyMemory:', gg.copyMemory(0x9000, 0x9010, 3))
-- copies 3 bytes 0x9000-0x9002 to 0x9010-0x9012
◆ copyText()
nil copyText	(	string 	text,
bool 	fixLocale = true 
)		
Copy text to the clipboard.

If the second parameter is true or not specified, the text will be converted as a number from the English locale to the selected one.

Parameters
text	The text for copy.
fixLocale	Flag to disable fix locale-specific separators.
Examples:
-- selected 'ru' locale, where decimal separator is ',' and thousand separator is ' '.
-- in English locale (en_US) decimal separator is '.' and thousand separator is ','.
gg.copyText('1,234,567.890')        -- Will copy '1 234 567,890'
gg.copyText('1,234,567.890', true)  -- Will copy '1 234 567,890'
gg.copyText('1,234,567.890', false) -- Will copy '1,234,567.890'
◆ disasm()
string disasm	(	int 	type,
long 	address,
int 	opcode 
)		
Disassemble the specified value.

Parameters
type	Type. One of the constants ASM_*. Throws an error if a non-existent type is passed.
address	The address of the value. May be needed for some opcodes.
opcode	Disassembly instruction. To disassemble Thumb32, the first 16-bit instruction should be in the lower half-word of the opcode, and the second in the upper half-word.
Returns
string Disassembled opcode string.
Examples:
print('ARM', gg.disasm(gg.ASM_ARM, 0x12345678, 0xE1A01002))
print('Thumb16', gg.disasm(gg.ASM_THUMB, 0x12345678, 0x0011))
print('Thumb32', gg.disasm(gg.ASM_THUMB, 0x12345678, 0xF800 | (0x0001 << 16)))
print('ARM64', gg.disasm(gg.ASM_ARM64, 0x12345678, 0x2A0103E2))
◆ dumpMemory()
mixed dumpMemory	(	long 	from,
long 	to,
string 	dir,
int 	flags = nil 
)		
Dump memory to files on disk.

Parameters
from	Address for start dump. Will be rounded to largest possible memory page.
to	Address for end dump. Will be rounded to smallest possible memory page.
dir	Directory for save dump files.
flags	Set of flags DUMP_* or nil.
Returns
true or string with error.
Examples:
print('dumpMemory:', gg.dumpMemory(0x9000, 0x9010, '/sdcard/dump'))
-- dump at least one memory page into the dir '/sdcard/dump'
print('dumpMemory:', gg.dumpMemory(0, -1, '/sdcard/dump'))
print('dumpMemory:', gg.dumpMemory(0, -1, '/sdcard/dump', nil))
print('dumpMemory:', gg.dumpMemory(0, -1, '/sdcard/dump', 0))
-- dump all memory into the dir '/sdcard/dump' (all same)
print('dumpMemory:', gg.dumpMemory(0, -1, '/sdcard/dump', gg.DUMP_SKIP_SYSTEM_LIBS))
-- dump all memory except system libraries into the dir '/sdcard/dump'
◆ editAll()
mixed editAll	(	string 	value,
int 	type 
)		
Edit all search results.

Before call this method you must load results via getResults. Value will be applied only for results with specified type.

Parameters
value	String with data for edit. Must be in English locale.
type	One constant from TYPE_*.
Returns
Int with count of changes or string with error.
Examples:
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
See also
setValues
◆ getActiveTab()
int getActiveTab	(		)	
Get active tab in the GameGuardian UI.

Returns
int One of the constants TAB_*.
See also
isVisible
◆ getFile()
string getFile	(		)	
Gets the filename of the currently running script.

Returns
The string with the filename of the currently running script.
E.g.:
'/sdcard/Notes/gg.example.lua'
See also
getLine
◆ getLine()
int getLine	(		)	
Gets the current line number of the script being executed.

Returns
The current line number of the script being executed.
E.g.:
24
See also
getFile
◆ getListItems()
mixed getListItems	(		)	
Return the contents of the saved list as a table.

Returns
Table with results or string with error. Each element is a table with the following fields: address (long), value (number), flags (one of the constants TYPE_*), name (string), freeze (boolean), freezeType (one of the constants FREEZE_*), freezeFrom (string), freezeTo (string).
Examples:
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
See also
getValues, getResults, getSelectedListItems
◆ getLocale()
string getLocale	(		)	
Gets the string with the currently selected locale in the GameGuardian.

Returns
The string with the currently selected locale in the GameGuardian.
E.g.:
en_US, zh_CN, ru, pt_BR, ar, uk
◆ getRanges()
int getRanges	(		)	
Return memory regions as bit mask of flags REGION_*.

Returns
Bit mask of flags REGION_*.
See also
setRanges
◆ getRangesList()
table getRangesList	(	string 	filter = ''	)	
Get the list of memory regions of the selected process.

Parameters
filter	The filter string. If specified, only those results that fall under the filter will be returned. Optional. The filter supports wildcards: ^ - the start of the data, $ - the end of the data, * - any number of any characters, ? - the one any character.
Returns
A list table with memory regions. Each element is a table with fields: state, start, end, type, name, internalName.
Examples:
print(gg.getRangesList())
local t = gg.getRangesList();
print(t[1].start)
print(t[1]['end']) -- cannot use dot-notation here because 'end' is a keyword in Lua, so you need to use square-bracket notation.
print(gg.getRangesList('libc.so'))
print(gg.getRangesList('lib*.so'))
print(gg.getRangesList('^/data/'))
print(gg.getRangesList('.so$'))
◆ getResults()
mixed getResults	(	int 	maxCount,
int 	skip = 0,
long 	addressMin = nil,
long 	addressMax = nil,
string 	valueMin = nil,
string 	valueMax = nil,
int 	type = nil,
string 	fractional = nil,
int 	pointer = nil 
)		
Load results into results list and return its as a table.

Parameters
maxCount	Max count of loaded results.
skip	The count of skipped results from the beginning. By default - 0.
addressMin	The minimum value of the address. Number or nil.
addressMax	The maximum value of the address. Number or nil.
valueMin	The minimum value of the value. Number as string or nil.
valueMax	The maximum value of the value. Number as string or nil.
type	Set of flags TYPE_* or nil.
fractional	Filter by fractional values. If the first character is "!", then the filter will exclude all values whose fractional part matches the specified one.
pointer	Set of flags POINTER_* or nil.
Returns
Table with results or string with error. Each element is a table with three keys: address (long), value (number), flags (one of the constants TYPE_*).
Examples:
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
See also
getValues, getSelectedResults
◆ getResultsCount()
long getResultsCount	(		)	
Get the number of found results.

Returns
The number of found results.
Examples:
gg.searchNumber('10', gg.TYPE_DWORD)
print('Found: ', gg.getResultsCount())
◆ getSelectedElements()
mixed getSelectedElements	(		)	
Returns the selected adresses in the memory editor.

Returns
Table with adresses (long) or string with error.
Examples:
print('Selected: ', gg.getSelectedElements())
See also
getSelectedResults, getSelectedListItems
◆ getSelectedListItems()
mixed getSelectedListItems	(		)	
Returns the selected items in the saved lists.

Returns
Table with results or string with error. Each element is a table with the following fields: address (long), value (number), flags (one of the constants TYPE_*), name (string), freeze (boolean), freezeType (one of the constants FREEZE_*), freezeFrom (string), freezeTo (string).
Examples:
print('Selected: ', gg.getSelectedListItems())
See also
getListItems, getSelectedResults, getSelectedElements
◆ getSelectedResults()
mixed getSelectedResults	(		)	
Returns the selected items in the search results.

Returns
Table with results or string with error. Each element is a table with three keys: address (long), value (number), flags (one of the constants TYPE_*).
Examples:
gg.searchNumber('10', gg.TYPE_DWORD)
gg.getResults(5)
print('Selected: ', gg.getSelectedResults())
See also
getResults, getSelectedListItems, getSelectedElements
◆ getSpeed()
double getSpeed	(		)	
Get the current speed from the speedhack.

Returns
The current speed from the speedhack.
See also
setSpeed
◆ getTargetInfo()
mixed getTargetInfo	(		)	
Get a table with information about the selected process if possible.

The set of fields can be different. Print the resulting table to see the available fields.

Possible fields: firstInstallTime, lastUpdateTime, packageName, sharedUserId, sharedUserLabel, versionCode, versionName, activities (name, label), installer, enabledSetting, backupAgentName, className, dataDir, descriptionRes, flags, icon, labelRes, logo, manageSpaceActivityName, name, nativeLibraryDir, permission, processName, publicSourceDir, sourceDir, targetSdkVersion, taskAffinity, theme, uid, label, cmdLine, pid, x64, RSS.

cmdLine - The contents of /proc/pid/cmdline. pid - PID of the process. x64 - True if the 64-bit process. RSS - The amount of RSS memory for the process, in KB.

Read about PackageInfo and ApplicationInfo in Android for means each field.

Returns
A table with information about the selected process or nil.
Examples:
-- check for game version
local v = gg.getTargetInfo()
if v.versionCode ~= 291 then
    print('This script only works with game version 291. You have game version ', v.versionCode, ' Please install version 291 and try again.')
    os.exit()
end
See also
getTargetPackage
◆ getTargetPackage()
mixed getTargetPackage	(		)	
Get the package name of the selected process, if possible.

Returns
The package name of the selected process as string or nil.
E.g.:
'com.blayzegames.iosfps'
See also
getTargetInfo
◆ getValues()
mixed getValues	(	table 	values	)	
Gets the values for the list of items.

Parameters
values	The table as a list of tables with address and flags fields (one of the constants TYPE_*).
Returns
A new table with results or string with error. Each element is a table with three keys: address (long), value (number), flags (one of the constants TYPE_*).
Examples:
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
See also
getResults, getListItems
◆ getValuesRange()
mixed getValuesRange	(	table 	values	)	
Get the memory regions for the passed value table.

Parameters
values	The table can be either an address list or a list of tables with the address field.
Returns
A table where each key, from the original table, will be associated with a short region code (Ch, for example). Or string with error.
Examples:
print('1: ', gg.getValuesRange({0x9000, 0x9010, 0x9020, 0x9030}))
-- table as a list of addresses
gg.searchNumber('10', gg.TYPE_DWORD)
local r = gg.getResults(5)
print('2: ', r, gg.getValuesRange(r))
-- table as a list of tables with the address field
◆ gotoAddress()
nil gotoAddress	(	long 	address	)	
Go to the address in the memory editor.

Parameters
address	Desired address.
◆ hideUiButton()
nil hideUiButton	(		)	
Hides the UI button.

See also
showUiButton
isClickedUiButton
◆ isClickedUiButton()
mixed isClickedUiButton	(		)	
Gets the click status of the ui button.

The call resets the click status.

Returns
true if the button has been clicked since the last check. false - if there was no click. nil - if the button is hidden.
Examples:
gg.showUiButton()
while true do
    if gg.isClickedUiButton() then
        -- do some action for click, menu for example
        local ret = gg.choice({'Item 1', 'Item 2', 'Item 3'}) or os.exit()
        gg.alert('You selected:', ret)
    end
    gg.sleep(100)
end
See also
showUiButton
hideUiButton
◆ isPackageInstalled()
bool isPackageInstalled	(	string 	pkg	)	
Check whether the specified application is installed on the system by the package name.

Parameters
pkg	String with package name.
Returns
true if package installed or false otherwise.
Examples:
print('Game installed:', gg.isPackageInstalled('com.blayzegames.iosfps'))
◆ isProcessPaused()
bool isProcessPaused	(		)	
Get pause state of the selected process.

Returns
true if the process paused or false otherwise.
See also
processPause
◆ isVisible()
bool isVisible	(		)	
Check if the GameGuardian UI is open.

Returns
true if the GameGuardian UI open or false otherwise.
See also
setVisible
◆ loadList()
mixed loadList	(	string 	file,
int 	flags = 0 
)		
Load the saved list from the file.

Parameters
file	File for load.
flags	Set of flags LOAD_*.
Returns
true or string with error.
Examples:
print('loadList:', gg.loadList('/sdcard/Notes/gg.victim.txt'))
print('loadList:', gg.loadList('/sdcard/Notes/gg.victim.txt', 0))
print('loadList:', gg.loadList('/sdcard/Notes/gg.victim.txt', gg.LOAD_APPEND))
print('loadList:', gg.loadList('/sdcard/Notes/gg.victim.txt', gg.LOAD_VALUES_FREEZE))
print('loadList:', gg.loadList('/sdcard/Notes/gg.victim.txt', gg.LOAD_APPEND | gg.LOAD_VALUES))
◆ loadResults()
mixed loadResults	(	table 	results	)	
Loads the search results from the table.

Existing search results will be cleared.

Parameters
results	The table as a list of tables with address and flags fields (one of the constants TYPE_*).
Returns
true or string with error.
Examples:
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
◆ makeRequest()
mixed makeRequest	(	string 	url,
table 	headers = {},
string 	data = nil 
)		
Performs a GET or POST request over HTTP or HTTPS.

The first time the function is called, the user is asked to access the Internet. Request one for each script run. If the user declines access, all subsequent calls will immediately return an error. If allowed - will be processed immediately. Permission to access must be obtained each time the script is run.

The function executes the query and returns a table with the result on success. On error, the string with the error text will be returned. In logcat there will be more information.

The result table can contain the following fields:

url - request url, for example 'http://httpbin.org/headers'
requestMethod - HTTP method, for example 'GET'
code - HTTP response code, for example 200
message - an HTTP message, for example 'Method Not Allowed'
headers - a table with all the response headers. Each value is also a table, with numeric keys. Usually there is only one value, but if the header has met several times, such as 'Set-Cookie', then there may be several values.
contentEncoding, contentLength, contentType, date, expiration, lastModified, usingProxy, cipherSuite - fields based on the methods of the class HttpURLConnection. If the method returns null, then this field will not be in the table.
error - true or false. true if the server returned an invalid code.
content - string of data from the server. Can be empty.
If the data string is not nil, the POST request will be executed, otherwise the GET.

By default, POST requests are set to "Content-Type" = "application/x-www-form-urlencoded". You can specify this header yourself to specify the desired type. Similarly, the header "Content-Length" is set. Other headers can be set by the system and depend on the implementation of the Android.

HTTPS requests do not perform certificate validation.

Parameters
url	A string with a URL.
headers	A table with request headers. The key is the name. The value is a table or a string. If this is a table, then the keys are ignored, and the values ​​are used.
data	A string with data for the POST request. If you specify nil, then there will be a GET request.
Returns
The table on success, the string on error.
Examples:
print('GET 1: ', gg.makeRequest('http://httpbin.org/headers').content) -- simple GET request
print('GET 2: ', gg.makeRequest('http://httpbin.org/headers', {['User-Agent']='My BOT'}).content) -- GET request with headers
print('GET 3: ', gg.makeRequest('http://httpbin.org/headers', {['User-Agent']={'My BOT', 'Tester'}}).content) -- GET request with headers
print('GET 4: ', gg.makeRequest('https://httpbin.org/get?param1=value2&param3=value4', {['User-Agent']='My BOT'}).content) -- HTTPS GET request with headers
print('POST 1: ', gg.makeRequest('http://httpbin.org/post', nil, 'post1=val2&post3=val4').content) -- simple POST request
print('POST 2: ', gg.makeRequest('http://httpbin.org/post', {['User-Agent']='My BOT'}, 'post1=val2&post3=val4').content) -- POST request with headers
print('POST 3: ', gg.makeRequest('http://httpbin.org/post', {['User-Agent']={'My BOT', 'Tester'}}, 'post1=val2&post3=val4').content) -- POST request with headers
print('POST 4: ', gg.makeRequest('https://httpbin.org/post?param1=value2&param3=value4', {['User-Agent']='My BOT'}, 'post1=val2&post3=val4').content) -- HTTPS POST request with headers
print('FULL: ', gg.makeRequest('https://httpbin.org/headers')) -- print full info about the request
◆ multiChoice()
mixed multiChoice	(	table 	items,
table 	selection = {},
string 	message = nil 
)		
Displays the multiple choice dialog.

Items must be numberic-array if you want show items in specified order.

Parameters
items	Table with items for choice.
selection	The table specifies the selection status for each item from items by same key. If key not found then the element will be unchecked.
message	Specifies the optional title of the dialog box.
Returns
nil if the dialog has been canceled, or a table with the selected keys and values true (analogue of the selected param).
Examples:
print('1: ', gg.multiChoice({'A', 'B', 'C', 'D'}))
-- show list of 4 items without checked items
print('2: ', gg.multiChoice({'A', 'B', 'C', 'D'}, {[2]=true, [4]=true}))
-- show list of 4 items with checked 2 and 4 items
print('3: ', gg.multiChoice({'A', 'B', 'C', 'D'}, {[3]=true}, 'Select letter:'))
-- show list of 4 items with checked 3 item and message
print('4: ', gg.multiChoice({'A', 'B', 'C', 'D'}, {}, 'Select letter:'))
-- show list of 4 items without checked items and message
-- Performing multiple actions
local t = gg.multiChoice({'A', 'B', 'C', 'D'})
if t == nil then
    gg.alert('Canceled')
else
    if t[1] then
        gg.alert('do A')
    end
    if t[2] then
        gg.alert('do B')
    end
    if t[3] then
        gg.alert('do C')
    end
    if t[4] then
        gg.alert('do D')
    end
end
See also
choice
prompt
◆ numberFromLocale()
string numberFromLocale	(	string 	num	)	
Replaces the localized decimal separator and thousands separator with separators used in Lua (such as in English).

Parameters
num	Number or string to replace.
Returns
Fixed number as string.
Examples:
print(gg.numberFromLocale('1.234,567')) -- print '1234.567' for German locale
◆ numberToLocale()
string numberToLocale	(	string 	num	)	
Replaces the decimal separator and the thousands separator with a localized version.

Parameters
num	Number or string to replace.
Returns
Fixed number as string.
Examples:
print(gg.numberToLocale('1,234.567')) -- print '1234,567' for German locale
◆ processKill()
bool processKill	(		)	
Force kill the selected process.

If you call this call too often, your script may be interrupted.

Attention
This can lead to data loss in this process.
Returns
true on success or false otherwise.
◆ processPause()
bool processPause	(		)	
Pauses the selected process.

Returns
true on success or false otherwise.
See also
isProcessPaused
◆ processResume()
bool processResume	(		)	
Resumes the selected process if it paused.

Returns
true on success or false otherwise.
See also
isProcessPaused
◆ processToggle()
bool processToggle	(		)	
Toggle the pause state of the selected process.

If process paused then it will be resumed else it will be paused.

Returns
true on success or false otherwise.
See also
isProcessPaused
◆ prompt()
mixed prompt	(	table 	prompts,
table 	defaults = {},
table 	types = {} 
)		
Displays the dialog for data entry.

For respect order of fields prompts must be numeric-array.

Parameters
prompts	The table specifies the keys and description for each input field.
defaults	The table specifies the default values for each key from prompts.
types	The table specifies the types for each key from prompts. Valid types: 'number', 'text', 'path', 'file', 'new_file', 'setting', 'speed', 'checkbox'. From the type depends output of additional elements near the input field (for example, buttons for selecting a path or file, internal or external keyboard and so on).
Also for the types 'number', 'setting', 'speed', the separators are converted to a localized version and vice versa during output.

For example, the string '6,789.12345' will be in the form displayed as '6789,12345' for the German locale (',' - decimal separator, '.' - thousands separator). If the user enters '4.567,89', then the script will receive '4567.89'.

To display the seek bar, you must specify the type 'number', the minimum and maximum value at the end of the prompt text, separated by a semicolon and surrounded by square brackets. The minimum value must be less than the maximum. If the default value is not in the range, the closest match will be used. Only integers can be used. The step size is always 1.

See examples.

If the config for seek bar is not recognized, the usual input of a number as text will be used.

Returns
nil if the dialog has been canceled, or the table with keys from prompts and values from input fields.
Examples:
print('prompt 1: ', gg.prompt(
    {'ask any', 'ask num', 'ask text', 'ask path', 'ask file', 'ask set', 'ask speed', 'checked', 'not checked'},
    {[1]='any val', [7]=123, [6]=-0.34, [8]=true},
    {[2]='number', [3]='text', [4]='path', [5]='file', [6]='setting', [7]='speed', [8]='checkbox', [9]='checkbox'}
))
print('prompt 2: ', gg.prompt(
    {'ask any', 'ask num', 'ask text', 'ask path', 'ask file', 'ask set', 'ask speed', 'check'},
    {[1]='any val', [7]=123, [6]=-0.34}
))
print('prompt 3: ', gg.prompt(
    {'ask any', 'ask num', 'ask text', 'ask path', 'ask file', 'ask set', 'ask speed', 'check'}
))
print('prompt 4: ', gg.prompt(
    {'seek bar 1 [32; 64]', 'seek bar 2 [-80; -60]'}, nil,
    {'number', 'number'}
))
print('prompt 5: ', gg.prompt(
    {'seek bar 1 [32; 64]', 'seek bar 2 [-80; -60]'},
    {42, -76},
    {'number', 'number'}
))
-- Performing multiple actions
local t = gg.prompt({'A', 'B', 'C', 'D'}, nil, {'checkbox', 'checkbox', 'checkbox', 'checkbox'})
if t == nil then
    gg.alert('Canceled')
else
    if t[1] then
        gg.alert('do A')
    end
    if t[2] then
        gg.alert('do B')
    end
    if t[3] then
        gg.alert('do C')
    end
    if t[4] then
        gg.alert('do D')
    end
end
See also
alert
choice
multiChoice
◆ refineAddress()
mixed refineAddress	(	string 	text,
long 	mask = -1,
int 	type = gg.TYPE_AUTO,
int 	sign = gg.SIGN_EQUAL,
long 	memoryFrom = 0,
long 	memoryTo = -1,
long 	limit = 0 
)		
Perform an address refine search with the specified parameters.

If no results in results list then do nothing.

Parameters
text	Search string. The format same as the format for the search from the GameGuardian UI. But it must be in English locale.
mask	Mask. Default is -1 (0xFFFFFFFFFFFFFFFF).
type	Type. One of the constants TYPE_*.
sign	Sign. SIGN_EQUAL or SIGN_NOT_EQUAL.
memoryFrom	Start memory address for the search.
memoryTo	End memory address for the search.
limit	Stopping the search after finding the specified number of results. 0 means to search all results.
Returns
true or string with error.
Examples:
gg.refineAddress('A20', 0xFFFFFFFF)
gg.refineAddress('B20', 0xFF0, gg.TYPE_DWORD, gg.SIGN_NOT_EQUAL)
gg.refineAddress('0B?0', 0xFFF, gg.TYPE_FLOAT)
gg.refineAddress('??F??', 0xBA0, gg.TYPE_BYTE, gg.SIGN_NOT_EQUAL, 0x9000, 0xA09000)
-- do nothing
gg.clearResults()
gg.refineAddress('A20', 0xFFFFFFFF)
-- refine search
gg.refineAddress('A20', 0xFFFFFFFF)
See also
searchAddress
◆ refineNumber()
mixed refineNumber	(	string 	text,
int 	type = gg.TYPE_AUTO,
bool 	encrypted = false,
int 	sign = gg.SIGN_EQUAL,
long 	memoryFrom = 0,
long 	memoryTo = -1,
long 	limit = 0 
)		
Perform a refine search for a number, with the specified parameters.

If no results in results list then do nothing.

Parameters
text	String for search. The format same as the format for the search from the GameGuardian UI. But it must be in English locale.
type	Type. One of the constants TYPE_*.
encrypted	Flag for run search encrypted values.
sign	Sign. One of the constants SIGN_*.
memoryFrom	Start memory address for the search.
memoryTo	End memory address for the search.
limit	Stopping the search after finding the specified number of results. 0 means to search all results.
Returns
true or string with error.
Examples:
-- number refine
gg.refineNumber('10', gg.TYPE_DWORD)
-- encrypted refine
gg.refineNumber('-10', gg.TYPE_DWORD, true)
-- range refine
gg.refineNumber('10~20', gg.TYPE_DWORD, false, gg.SIGN_NOT_EQUAL)
-- group refine with ranges
gg.refineNumber('6~7;7;1~2;0;0;0;0;6~8::29', gg.TYPE_DWORD)
-- refine for HEX '5C E3 0B 4B 90 9B 11 7B'
gg.refineNumber('5Ch;E3h;0Bh;4Bh;90h;9Bh;11h;7Bh::8', gg.TYPE_BYTE)
-- refine for HEX '5C ?? 0B 4B ?? 9B 11 7B' where '??' can be any byte
gg.refineNumber('5Ch;0~~0;0Bh;4Bh;0~~0;9Bh;11h;7Bh::8', gg.TYPE_BYTE)
-- do nothing
gg.clearResults()
gg.refineNumber('10', gg.TYPE_DWORD)
-- refine search
gg.refineNumber('10', gg.TYPE_DWORD)
-- see searchNumber for other search examples
See also
searchNumber
◆ removeListItems()
mixed removeListItems	(	table 	items	)	
Remove items from the saved list.

Parameters
items	The table as a list of tables with address. Or the table as a list of adresses.
Returns
True or string with error.
Examples:
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
-- creating a table as a list of adresses
t = {}
t[1] = 0x18004030 -- some desired address
t[2] = 0x18004040 -- another desired address
print('removeListItems: ', gg.removeListItems(t))
See also
getValues, getResults
◆ removeResults()
mixed removeResults	(	table 	results	)	
Remove results from the list of results found.

Parameters
results	The table as a list of tables with address and flags fields (one of the constants TYPE_*).
Returns
true or string with error.
Examples:
gg.searchNumber('10', gg.TYPE_DWORD)
local r = gg.getResults(5)
print('Remove first 5 results: ', gg.removeResults(r))
See also
clearResults
◆ require()
nil require	(	string 	version = nil,
int 	build = 0 
)		
Checks the version of GameGuardian.

If the version or build number is lower than required, the script will be ended with the message to update GameGuardian.

Parameters
version	Minimal version of GameGuardian to run the script.
build	Minimal build number to run the script. Optional.
Examples:
gg.require('8.31.1')
gg.require('8.31.1', 5645)
gg.require(nil, 5645)
See also
VERSION
VERSION_INT
BUILD
◆ saveList()
mixed saveList	(	string 	file,
int 	flags = 0 
)		
Save the saved list to the file.

Parameters
file	File to save.
flags	Set of flags SAVE_*.
Returns
true or string with error.
Examples:
print('saveList:', gg.saveList('/sdcard/Notes/gg.victim.txt'))
print('saveList:', gg.saveList('/sdcard/Notes/gg.victim.txt', 0))
print('saveList:', gg.saveList('/sdcard/Notes/gg.victim.txt', gg.SAVE_AS_TEXT))
◆ saveVariable()
mixed saveVariable	(	mixed 	variable,
string 	filename 
)		
Saves the variable to a file.

The result of the execution will be a .lua file, which can then be loaded via

local var = assert(loadfile(filename))()
Stores only strings, numbers, and tables. Cyclic references are processed correctly. If you need something more, read: lua-users wiki: Table Serialization

Parameters
variable	Variable to save.
filename	Full path to save the file.
Returns
true or string with error.
Examples:
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
◆ searchAddress()
mixed searchAddress	(	string 	text,
long 	mask = -1,
int 	type = gg.TYPE_AUTO,
int 	sign = gg.SIGN_EQUAL,
long 	memoryFrom = 0,
long 	memoryTo = -1,
long 	limit = 0 
)		
Perform an address search with the specified parameters.

If no results in results list then perform new search, else refine search. So if you need to perform a search, without refine, you must first call clearResults.

Parameters
text	Search string. The format same as the format for the search from the GameGuardian UI. But it must be in English locale.
mask	Mask. Default is -1 (0xFFFFFFFFFFFFFFFF).
type	Type. One of the constants TYPE_*.
sign	Sign. SIGN_EQUAL or SIGN_NOT_EQUAL.
memoryFrom	Start memory address for the search.
memoryTo	End memory address for the search.
limit	Stopping the search after finding the specified number of results. 0 means to search all results.
Returns
true or string with error.
Examples:
gg.searchAddress('A20', 0xFFFFFFFF)
gg.searchAddress('B20', 0xFF0, gg.TYPE_DWORD, gg.SIGN_NOT_EQUAL)
gg.searchAddress('0B?0', 0xFFF, gg.TYPE_FLOAT)
gg.searchAddress('??F??', 0xBA0, gg.TYPE_BYTE, gg.SIGN_NOT_EQUAL, 0x9000, 0xA09000)
-- start new search
gg.clearResults()
gg.searchAddress('A20', 0xFFFFFFFF)
-- refine search
gg.searchAddress('A20', 0xFFFFFFFF)
See also
clearResults
refineAddress
◆ searchFuzzy()
mixed searchFuzzy	(	string 	difference = '0',
int 	sign = gg.SIGN_FUZZY_EQUAL,
int 	type = gg.TYPE_AUTO,
long 	memoryFrom = 0,
long 	memoryTo = -1,
long 	limit = 0 
)		
Refine fuzzy search, with the specified parameters.

Parameters
difference	Difference between old and new values. By default is '0'. Must be in English locale.
sign	Sign. One of the constants SIGN_FUZZY_*.
type	Type. One of the constants TYPE_*.
memoryFrom	Start memory address for the search.
memoryTo	End memory address for the search.
limit	Stopping the search after finding the specified number of results. 0 means to search all results.
Returns
true or string with error.
Examples:
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
See also
startFuzzy
◆ searchNumber()
mixed searchNumber	(	string 	text,
int 	type = gg.TYPE_AUTO,
bool 	encrypted = false,
int 	sign = gg.SIGN_EQUAL,
long 	memoryFrom = 0,
long 	memoryTo = -1,
long 	limit = 0 
)		
Perform a search for a number, with the specified parameters.

If no results in results list then perform new search, else refine search. So if you need to perform a search, without refine, you must first call clearResults.

Parameters
text	String for search. The format same as the format for the search from the GameGuardian UI. But it must be in English locale.
type	Type. One of the constants TYPE_*.
encrypted	Flag for run search encrypted values.
sign	Sign. One of the constants SIGN_*.
memoryFrom	Start memory address for the search.
memoryTo	End memory address for the search.
limit	Stopping the search after finding the specified number of results. 0 means to search all results.
Returns
true or string with error.
Examples:
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
-- search for HEX '5C E3 0B 4B 90 9B 11 7B'
gg.searchNumber('h 5C E3 0B 4B 90 9B 11 7B')
-- search for HEX '5C ?? 0B 4B ?? 9B 11 7B' where '??' can be any byte
gg.searchNumber('5Ch;0~~0;0Bh;4Bh;0~~0;9Bh;11h;7Bh::8', gg.TYPE_BYTE)
-- search for text UTF-8 'şuşpançik' - type forced to gg.TYPE_BYTE
gg.searchNumber(':şuşpançik')
-- search for text UTF-16LE 'şuşandra' - type forced to gg.TYPE_WORD
gg.searchNumber(';şuşandra')
-- search for HEX '5C E3 0B' + UTF-8 'şuşpançik' + HEX '9B 11 7B' - type forced to gg.TYPE_BYTE
gg.searchNumber('Q 5C E3 0B \'şuşpançik\' 9B 11 7B')
gg.searchNumber("Q 5C E3 0B 'şuşpançik' 9B 11 7B") -- same as above
-- search for HEX '5C E3 0B' + UTF-16LE 'şuşandra' + HEX '9B 11 7B' - type forced to gg.TYPE_BYTE
gg.searchNumber('Q 5C E3 0B "şuşandra" 9B 11 7B')
-- search for HEX '5C E3 0B' + UTF-8 'şuşpançik' + HEX '9B' + UTF-16LE 'şuşandra' + '11 7B' - type forced to gg.TYPE_BYTE
gg.searchNumber('Q 5C E3 0B \'şuşpançik\' 9B "şuşandra" 11 7B')
gg.searchNumber("Q 5C E3 0B 'şuşpançik' 9B \"şuşandra\" 11 7B") -- same as above
-- search for ARM opcode
gg.searchNumber('~A MOV R1, R2', gg.TYPE_DWORD)
-- start new search
gg.clearResults()
gg.searchNumber('10', gg.TYPE_DWORD)
-- refine search if present some results in the result list
gg.searchNumber('10', gg.TYPE_DWORD)
See also
clearResults
refineNumber
◆ searchPointer()
mixed searchPointer	(	int 	maxOffset,
long 	memoryFrom = 0,
long 	memoryTo = -1,
long 	limit = 0 
)		
Searches for values that may be pointers to elements of the current search result.

Parameters
maxOffset	Maximum offset for pointers. Valid values: 0 - 65535.
memoryFrom	Start memory address for the search.
memoryTo	End memory address for the search.
limit	Stopping the search after finding the specified number of results. 0 means to search all results.
Returns
true or string with error.
Examples:
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
◆ setRanges()
nil setRanges	(	int 	ranges	)	
Set memory regions to desired bit mask of flags REGION_*.

Parameters
ranges	Bit mask of flags REGION_*.
Examples:
gg.setRanges(gg.REGION_C_HEAP)
gg.setRanges(bit32.bor(gg.REGION_C_HEAP, gg.REGION_C_ALLOC, gg.REGION_ANONYMOUS))
gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS)
See also
getRanges
skipRestoreState
◆ setSpeed()
mixed setSpeed	(	double 	speed	)	
Set the speed of the speedhack.

If speedhack was not loaded, then it will be loaded. The call is blocking. The script will wait for speedhack full load.

Parameters
speed	Desired speed. Must be in range [1.0E-9; 1.0E9].
Returns
true or string with error.
See also
getSpeed
◆ setValues()
mixed setValues	(	table 	values	)	
Set the values for the list of items.

Parameters
values	The table as a list of tables with three keys: address (long), value (string with a value), flags (one of the constants TYPE_*). Values must be in English locale.
Returns
true or string with error.
Examples:
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
See also
editAll
◆ setVisible()
nil setVisible	(	bool 	visible	)	
Open or close the GameGuardian UI.

If you call this call too often, your script may be interrupted.

Parameters
visible	true for open GameGuardian UI or false for hide. *
Examples:
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
See also
isVisible
◆ showUiButton()
nil showUiButton	(		)	
Shows the UI button.

The UI button has an icon with the letters "Sx" and is visible only when you open the GameGuardian interface. The button is floating, displayed on top of the main GameGuardian interface.

See also
hideUiButton
isClickedUiButton
◆ skipRestoreState()
nil skipRestoreState	(		)	
Do not restore the state of the GameGuardian, after the script is completed.

For example, by default, a set of memory regions restored after end script execution. This call allow prevent this.

Examples:
gg.setRanges(bit32.bxor(gg.REGION_C_HEAP, gg.REGION_C_ALLOC, gg.REGION_ANONYMOUS))
-- do some things like search values
-- gg.skipRestoreState() -- if you uncomment this line -
-- memory ranges after end script stay same as we set in first line.
-- If not - it will be restored to state which be before script run.
◆ sleep()
nil sleep	(	int 	milliseconds	)	
Causes the currently executing script to sleep (temporarily cease execution) for the specified number of milliseconds, subject to the precision and accuracy of system timers and schedulers.

Parameters
milliseconds	The length of time to sleep in milliseconds.
Examples:
-- 200 ms
gg.sleep(200)
-- 300 ms
local v = 300
gg.sleep(v)
◆ startFuzzy()
mixed startFuzzy	(	int 	type = gg.TYPE_AUTO,
long 	memoryFrom = 0,
long 	memoryTo = -1,
long 	limit = 0 
)		
Start a fuzzy search, with the specified parameters.

Parameters
type	Type. One of the constants TYPE_*.
memoryFrom	Start memory address for the search.
memoryTo	End memory address for the search.
limit	Stopping the search after finding the specified number of results. 0 means to search all results.
Returns
true or string with error.
Examples:
gg.startFuzzy()
gg.startFuzzy(gg.TYPE_DWORD)
gg.startFuzzy(gg.TYPE_FLOAT)
gg.startFuzzy(gg.TYPE_BYTE, 0x9000, 0xA09000)
See also
searchFuzzy
◆ timeJump()
mixed timeJump	(	string 	time	)	
Performs a time jump.

Parameters
time	String with time. The format is similar to the time format in the time jump dialog. But it must be in English locale.
Returns
true or string with error.
Examples:
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
◆ toast()
nil toast	(	string 	text,
bool 	fast = false 
)		
Show the toast.

If the second parameter is true, show the toast for a short period of time.

A toast is a view containing a quick little message for the user.

When the view is shown to the user, appears as a floating view over the application. It will never receive focus. The user will probably be in the middle of typing something else. The idea is to be as unobtrusive as possible, while still showing the user the information you want them to see. Two examples are the volume control, and the brief message saying that your settings have been saved.

Parameters
text	The text for toast.
fast	Flag for show the toast for a short period of time.
Examples:
gg.toast('This is toast')
-- Show text notification for a long period of time
gg.toast('This is toast', true)
-- Show text notification for a short period of time
See also
alert
◆ unrandomizer()
mixed unrandomizer	(	long 	qword = nil,
long 	qincr = nil,
double 	double_ = nil,
double 	dincr = nil 
)		
Work with Unrandomizer.

If Unrandomizer was not loaded, then it will be loaded. The call is blocking. The script will wait for Unrandomizer full load. You can set any parameter in nil so that it is not used.

Parameters
qword	Qword parameter. Set to nil to disable.
qincr	Qword increment. Set to nil to disable.
double_	Double parameter. Set to nil to disable.
dincr	Double increment. Set to nil to disable.
Returns
true or string with error.
Examples:
print('unrandomizer:', gg.unrandomizer(0)) -- set only qword = 0
print('unrandomizer:', gg.unrandomizer(0, 1)) -- set only qword = 0 with increment = 1
print('unrandomizer:', gg.unrandomizer(nil, nil, 0.3)) -- set only double without increment
print('unrandomizer:', gg.unrandomizer(nil, nil, 0.3, 0.01)) -- set only double with increment
print('unrandomizer:', gg.unrandomizer(2, 3, 0.45, 0.67)) -- set both
print('unrandomizer:', gg.unrandomizer()) -- off
Member Data Documentation

◆ ANDROID_SDK_INT
string ANDROID_SDK_INT
The SDK version of the Android currently running on this device.

Examples:
print("ANDROID_SDK_INT: "..gg.ANDROID_SDK_INT)
E.g.:
27
◆ ASM_ARM
int ASM_ARM
Arm x32.

See also
disasm
◆ ASM_ARM64
int ASM_ARM64
ARM x64.

See also
disasm
◆ ASM_THUMB
int ASM_THUMB
Thumb.

See also
disasm
◆ BUILD
int BUILD
Number build of the GameGuardian.

Examples:
print("GG build number: "..gg.BUILD)
E.g.:
5645
See also
require
◆ CACHE_DIR
string CACHE_DIR
The absolute path to the GameGuardian specific cache directory on the filesystem.

These files will be ones that get deleted first when the device runs low on storage. There is no guarantee when these files will be deleted.

Note: you should not rely on the system deleting these files for you; you should always have a reasonable maximum, such as 1 MB, for the amount of space you consume with cache files, and prune those files when exceeding that space. If your app requires a larger cache (larger than 1 MB), you should use EXT_CACHE_DIR instead.

Placed in internal memory. Not visible for other apps. Can be cleared by user.

Examples:
print("Cache dir: "..gg.CACHE_DIR)
E.g.:
'/data/data/catch_.me_.if_.you_.can_/cache'
◆ DUMP_SKIP_SYSTEM_LIBS
int DUMP_SKIP_SYSTEM_LIBS
Skip system libraries.

See also
dumpMemory
◆ EXT_CACHE_DIR
string EXT_CACHE_DIR
The absolute path to the GameGuardian specific directory on the primary shared/external storage device where the GameGuardian can place cache files it owns.

May return same value as CACHE_DIR if shared storage is not currently available. Usually placed in external memory. Visible for other apps. Can be cleared by user.

Examples:
print("External cache dir: "..gg.EXT_CACHE_DIR)
E.g.:
'/sdcard/Android/data/catch_.me_.if_.you_.can_/cache'
◆ EXT_FILES_DIR
string EXT_FILES_DIR
The absolute path to the directory on the primary shared/external storage device where the GameGuardian can place persistent files it owns.

May return same value as FILES_DIR if shared storage is not currently available. Usually placed in external memory. Visible for other apps.

Examples:
print("External files dir: "..gg.EXT_FILES_DIR)
E.g.:
'/sdcard/Android/data/catch_.me_.if_.you_.can_/files'
◆ EXT_STORAGE
string EXT_STORAGE
The primary shared/external storage directory.

Examples:
print("External storage: "..gg.EXT_STORAGE)
local file = io.open(gg.EXT_STORAGE.."/test_log.txt", "w")
file:write("This is log file")
file:close()
E.g.:
'/mnt/sdcard'
◆ FILES_DIR
string FILES_DIR
The path of the directory holding GameGuardian files.

Placed in internal memory. Not visible for other apps.

Examples:
print("Files dir: "..gg.FILES_DIR)
E.g.:
'/data/data/catch_.me_.if_.you_.can_/files'
◆ FREEZE_IN_RANGE
int FREEZE_IN_RANGE
Allows the value to change only within specified range.

See also
addListItems, getListItems, getSelectedListItems
◆ FREEZE_MAY_DECREASE
int FREEZE_MAY_DECREASE
Allows the value to decrease, but does not allow to increase.

See also
addListItems, getListItems, getSelectedListItems
◆ FREEZE_MAY_INCREASE
int FREEZE_MAY_INCREASE
Allows the value to increase, but does not allow to decrease.

See also
addListItems, getListItems, getSelectedListItems
◆ FREEZE_NORMAL
int FREEZE_NORMAL
Freezes the value, not allowing it to change.

Used by default.

See also
addListItems, getListItems, getSelectedListItems
◆ LOAD_APPEND
int LOAD_APPEND
Append to list.

See also
loadList
◆ LOAD_VALUES
int LOAD_VALUES
Load values.

See also
loadList
◆ LOAD_VALUES_FREEZE
int LOAD_VALUES_FREEZE
Load values and freeze.

See also
loadList
◆ PACKAGE
string PACKAGE
Package name of the GameGuardian.

Examples:
print("GG package: "..gg.PACKAGE)
E.g.:
'catch_.me_.if_.you_.can_'
◆ POINTER_EXECUTABLE
int POINTER_EXECUTABLE
Pointer to executable memory.

See also
getResults
◆ POINTER_EXECUTABLE_WRITABLE
int POINTER_EXECUTABLE_WRITABLE
Pointer to executable and writable memory.

See also
getResults
◆ POINTER_NO
int POINTER_NO
Not a pointer.

See also
getResults
◆ POINTER_READ_ONLY
int POINTER_READ_ONLY
Pointer to read-only memory.

See also
getResults
◆ POINTER_WRITABLE
int POINTER_WRITABLE
Pointer to writable memory.

See also
getResults
◆ PROT_EXEC
int PROT_EXEC
Pages may be executed.

See also
allocatePage
◆ PROT_NONE
int PROT_NONE
Pages may not be accessed.

See also
allocatePage
◆ PROT_READ
int PROT_READ
Pages may be read.

See also
allocatePage
◆ PROT_WRITE
int PROT_WRITE
Pages may be written.

See also
allocatePage
◆ REGION_ANONYMOUS
int REGION_ANONYMOUS
"A: Anonymous" memory region.

See also
getRanges, setRanges
◆ REGION_ASHMEM
int REGION_ASHMEM
"As: Ashmem" memory region.

See also
getRanges, setRanges
◆ REGION_BAD
int REGION_BAD
"B: Bad (dangerous)" memory region.

See also
getRanges, setRanges
◆ REGION_C_ALLOC
int REGION_C_ALLOC
"Ca: C++ alloc" memory region.

See also
getRanges, setRanges
◆ REGION_C_BSS
int REGION_C_BSS
"Cb: C++ .bss" memory region.

See also
getRanges, setRanges
◆ REGION_C_DATA
int REGION_C_DATA
"Cd: C++ .data" memory region.

See also
getRanges, setRanges
◆ REGION_C_HEAP
int REGION_C_HEAP
"Ch: C++ heap" memory region.

See also
getRanges, setRanges
◆ REGION_CODE_APP
int REGION_CODE_APP
"Xa: Code app (dangerous)" memory region.

See also
getRanges, setRanges
◆ REGION_CODE_SYS
int REGION_CODE_SYS
"Xs: Code system (dangerous)" memory region.

See also
getRanges, setRanges
◆ REGION_JAVA
int REGION_JAVA
"J: Java" memory region.

See also
getRanges, setRanges
◆ REGION_JAVA_HEAP
int REGION_JAVA_HEAP
"Jh: Java heap" memory region.

See also
getRanges, setRanges
◆ REGION_OTHER
int REGION_OTHER
"O: Other (slow)" memory region.

See also
getRanges, setRanges
◆ REGION_PPSSPP
int REGION_PPSSPP
"PS: PPSSPP" memory region.

See also
getRanges, setRanges
◆ REGION_STACK
int REGION_STACK
"S: Stack" memory region.

See also
getRanges, setRanges
◆ REGION_VIDEO
int REGION_VIDEO
"V: Video" memory region.

See also
getRanges, setRanges
◆ SAVE_AS_TEXT
int SAVE_AS_TEXT
Save list as text.

See also
saveList
◆ SIGN_EQUAL
int SIGN_EQUAL
See also
searchNumber, refineNumber
◆ SIGN_FUZZY_EQUAL
int SIGN_FUZZY_EQUAL
See also
searchFuzzy
◆ SIGN_FUZZY_GREATER
int SIGN_FUZZY_GREATER
See also
searchFuzzy
◆ SIGN_FUZZY_LESS
int SIGN_FUZZY_LESS
See also
searchFuzzy
◆ SIGN_FUZZY_NOT_EQUAL
int SIGN_FUZZY_NOT_EQUAL
See also
searchFuzzy
◆ SIGN_GREATER_OR_EQUAL
int SIGN_GREATER_OR_EQUAL
See also
searchNumber, refineNumber
◆ SIGN_LESS_OR_EQUAL
int SIGN_LESS_OR_EQUAL
See also
searchNumber, refineNumber
◆ SIGN_NOT_EQUAL
int SIGN_NOT_EQUAL
See also
searchNumber, refineNumber
◆ TAB_MEMORY_EDITOR
int TAB_MEMORY_EDITOR
Memory editor tab.

See also
getActiveTab
◆ TAB_SAVED_LIST
int TAB_SAVED_LIST
Saved list tab.

See also
getActiveTab
◆ TAB_SEARCH
int TAB_SEARCH
Search tab.

See also
getActiveTab
◆ TAB_SETTINGS
int TAB_SETTINGS
Settings tab.

See also
getActiveTab
◆ TYPE_AUTO
int TYPE_AUTO
Type Auto.

See also
searchNumber, refineNumber, startFuzzy, searchFuzzy, searchAddress, refineAddress, getResults, editAll, removeResults, loadResults, getSelectedResults, setValues, getValues, addListItems, getListItems, getSelectedListItems
◆ TYPE_BYTE
int TYPE_BYTE
Type Byte.

Size: 1 byte. Align: 1 byte boundary.

See also
searchNumber, refineNumber, startFuzzy, searchFuzzy, searchAddress, refineAddress, getResults, editAll, removeResults, loadResults, getSelectedResults, setValues, getValues, addListItems, getListItems, getSelectedListItems
◆ TYPE_DOUBLE
int TYPE_DOUBLE
Type Double.

Size: 8 byte. Align: 4 (x86) or 8 (ARM) byte boundary.

See also
searchNumber, refineNumber, startFuzzy, searchFuzzy, searchAddress, refineAddress, getResults, editAll, removeResults, loadResults, getSelectedResults, setValues, getValues, addListItems, getListItems, getSelectedListItems
◆ TYPE_DWORD
int TYPE_DWORD
Type Dword.

Size: 4 byte. Align: 4 byte boundary.

See also
searchNumber, refineNumber, startFuzzy, searchFuzzy, searchAddress, refineAddress, getResults, editAll, removeResults, loadResults, getSelectedResults, setValues, getValues, addListItems, getListItems, getSelectedListItems
◆ TYPE_FLOAT
int TYPE_FLOAT
Type Float.

Size: 4 byte. Align: 4 byte boundary.

See also
searchNumber, refineNumber, startFuzzy, searchFuzzy, searchAddress, refineAddress, getResults, editAll, removeResults, loadResults, getSelectedResults, setValues, getValues, addListItems, getListItems, getSelectedListItems
◆ TYPE_QWORD
int TYPE_QWORD
Type Qword.

Size: 8 byte. Align: 4 (x86) or 8 (ARM) byte boundary.

See also
searchNumber, refineNumber, startFuzzy, searchFuzzy, searchAddress, refineAddress, getResults, editAll, removeResults, loadResults, getSelectedResults, setValues, getValues, addListItems, getListItems, getSelectedListItems
◆ TYPE_WORD
int TYPE_WORD
Type Word.

Size: 2 byte. Align: 2 byte boundary.

See also
searchNumber, refineNumber, startFuzzy, searchFuzzy, searchAddress, refineAddress, getResults, editAll, removeResults, loadResults, getSelectedResults, setValues, getValues, addListItems, getListItems, getSelectedListItems
◆ TYPE_XOR
int TYPE_XOR
Type Xor.

Size: 4 byte. Align: 4 byte boundary.

See also
searchNumber, refineNumber, startFuzzy, searchFuzzy, searchAddress, refineAddress, getResults, editAll, removeResults, loadResults, getSelectedResults, setValues, getValues, addListItems, getListItems, getSelectedListItems
◆ VERSION
string VERSION
Text version of the GameGuardian.

Examples:
print("GG string version: "..gg.VERSION)
E.g.:
'8.31.1'
See also
require
◆ VERSION_INT
int VERSION_INT
Numeric version of the GameGuardian.

Examples:
print("GG numeric version: "..gg.VERSION_INT)
E.g.:
83101
See also
require
