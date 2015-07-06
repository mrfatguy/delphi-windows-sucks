# Windows Sucks

This is a batch-tool, that can run through all your image files in given directory and correct their file dates according to real photo data stored in EXIF record.

_Program's name is intentionally like that, because Windows sucks. It changes file date during each save of it. And thus if you, for example rotate some incorrectly shot photo, you'll end up with file date set to the moment you correcte the image, not to the day, it was actually shot. This little tool can help in this case, if only your image contains proper EXIF record (most images produced by digital cameras has)._

For Delphi developer this piece of source code may be useful to learn, how to operate on EXIF records or how to batch-process all files in given folder.

There's a slight problem with `WindowsSucks.tzf` file. When present in the same directory as `WindowsSucks.exe` it should enable time shifting feature (left-bottom corner combo box). I'm pretty sure, that it was working nice and dandy. But in the only `.exe` file, that I have, it does not work at all. Both files are present in the same directory, but mentioned combo box remains disabled and time shifting feature is not available. I'm pretty sure, that this is something really small and you should be able to fix it right after opening this project in your Delphi.

**This project ABANDONED! There is no wiki, issues and no support. There will be no future updates. Unfortunately, you're on your own.**

### Status

Last time `.dproj` file saved in Delphi: **12 November 2011**. Last time `.exe` file built: **6 January 2013**.

This is the only of my Delphi projects, that was written in English from scratch and in the same time, the only that was ever opened or compiled in Delphi 2010.

**You're only getting project's source code and nothing else! You need to find all missing Delphi components by yourself.**

I don't have access to either most of my components used in this or any other of my Delphi projects, nor to Delphi itself. Even translation of this project to English was done by text-editing all `.dfm` and `.pas` files and therefore it may be cracked. It was made in hope to be useful to anyone and for the same reason I'm releasing its source code, but you're using this project or source code at your own responsibility.

Keep in mind, that both comments and names (variables, object) are in Polish. I didn't find enough time and determination to translated them as well. I only translated strings.

**This project ABANDONED! There is no wiki, issues and no support. There will be no future updates. Unfortunately, you're on your own.**