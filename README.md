Delete-Files
============

An OSX Automator action for (optionally securely) deleting files, bypassing the "Move to Trash" step.

Installation Instructions and Release Notes
Copyright 2005-2012 Justin Middleton, email: jrmiddle@gmail.com

# Description


"Delete Files" is a simple automator action which provides a file deletion facility.
It takes files and/or folders on input, and outputs the POSIX paths of files that were
successfully deleted. Note that this does *NOT* move files to the trash, it really,
really, really deletes them permanently.  This makes it useful for things like cleaning
out web caches.

But remember, that which has been unseen cannot be reseen. **Use With Care.**

Three sample workflows are included:

- "Delete Items" and "Delete and Wipe Items" are suitable as Finder plugins; copy them to ~/Library/Workflows/Applications/Finder to make them accessible through the Automator contextual menu.

- "Wipe Safari Caches" is a sample workflow that will wipe your Safari caches, history, and icons.

This action is free to use, provided that credit is given to me in any published work which uses the software.
If you like it, or have suggestions, or just want to say "Hi," feel free to drop me a line at jrmiddle@gmail.com.
