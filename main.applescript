-- main.applescript
-- Delete Files v2

--  Created by Justin Middleton on 9/7/05.
--  v1.1 on 5/13/06
--  V2 on 12/30/2012
--  Copyright (c) 2005-2012, Justin R. Middleton<jrmiddle@gmail.com>
--  All rights reserved.
--
--  Redistribution and use in source and binary forms, with or without
--  modification, are permitted provided that the following conditions are met:
--
--  1. Redistributions of source code must retain the above copyright notice, this
--     list of conditions and the following disclaimer.
--  2. Redistributions in binary form must reproduce the above copyright notice,
--     this list of conditions and the following disclaimer in the documentation
--     and/or other materials provided with the distribution.
--
--  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
--  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
--  The views and conclusions contained in the software and documentation are those
--  of the authors and should not be interpreted as representing official policies,
--  either expressed or implied, of the FreeBSD Project.

on run {input, parameters}
	
	-- coerce input to list (thanks sal)
	if the class of input is not list then Â
		set input to input as list
	
	set the output to {}
	
	-- Confirm if necessary
	
	if (|confirmAction| of parameters) then
		set confText to (|confirmText| of parameters)
		set conf to (display dialog confText default button "No" buttons {"No", "Yes"} with icon note)
		if (button returned of conf as string) is "No" then
			return output
		end if
	end if
	
	set delType to |deleteType| of parameters
	
	-- display alert "delType: " & delType
	
	-- compute rm type (thanks for the tip, sal)
	set type_indicator to ((|deleteType| of parameters) as integer) + 1
	set rmcmd to item type_indicator of {"rm ", "srm -s ", "srm -m ", "srm "}
	
	if (|ignorePermissions| of parameters) then
		set rmcmd to rmcmd & "-f "
	end if
	
	set rmcmd_pre to ""
	set rmcmd_post to ""
	
	if (|filesOnly| of parameters) then
		-- leaving directory tree in place.
		-- if we do it recursively here, then we have to traverse
		-- the tree ourselves, because "rm -r" implies "rm -d".
		if (|withRecursion| of parameters) then
			set rmcmd_pre to "find "
			set rmcmd_post to "-type f | while read l; do " & rmcmd & " -- \"$l\"; done"
		else
			set rmcmd_pre to rmcmd & " --"
		end if
	else
		if (|withRecursion| of parameters) then
			-- "rm -r" takes dirs with it, so we don't have to worry
			-- about a "-d" flag.
			set rmcmd to rmcmd & "-r "
		else
			-- we're not recursing, but we do want to remove empty
			-- directories. Include the "-d" flag.
			set rmcmd to rmcmd & "-d "
		end if
		set rmcmd_pre to rmcmd & " --"
	end if
	
	repeat with f in input
		try
			tell application "Finder"
				set pospath to (quoted form of POSIX path of (f as alias))
			end tell
			
			-- if we're not forcing, there's still the possiblity
			-- that the file is owned by us but read only or locked
			-- try to make them writable/mutable, and complain
			-- if we can't. otherwise we risk getting stuck
			-- with a prompt from "rm"
			
			if not (|ignorePermissions| of parameters) then
				set chmodcmd to ("chmod -R +w " & pospath)
				set chflagscmd to ("chflags -R nouchg " & pospath)
				set chcmd to chmodcmd & " && " & chflagscmd
				-- display alert "chmod/chflags: " & chcmd
				do shell script chcmd
			end if
			
			set cmd to rmcmd_pre & " " & pospath & " " & rmcmd_post
			-- display alert "command: " & cmd
			do shell script (cmd)
			set end of output to pospath
			
		on error errMsg
			
			if not (|ignoreErrors| of parameters) then
				set rsp to (display dialog ("Error deleting item " & pospath & ": " & errMsg) default button "Stop" buttons {"Stop", "Continue"} with icon caution)
				
				if (button returned of rsp as string) is "Stop" then
					exit repeat
				end if -- if buttonReturned
				
			end if -- if not ignoreErrors
			
		end try
	end repeat
	return output
end run

(*
==============================
  Find all directories unwriteable (and unable to coerce into writeability)
  by this user. Immediate child nodes won't be deletable.
==============================
*)

on findUndeletableDirs(inRoot)
	set retval to {}
	set unwriteableDirs_raw to do shell script ("find " & inRoot & " -type d | while read l; do if [ ! -O \"$l\" ]; then if [ ! -G \"$l\" ]; then if [ ! -w \"$l\" ]; then echo $l; fi; fi; fi; done ")
	set text item delimiters to return
	set retval to every text item of unwriteableDirs_raw
	return retval
end findUndeletableDirs


