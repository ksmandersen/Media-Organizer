# Media Organizer

The code in this project will enable you to automatically organize your TV Shows
into a nice folder structure, encode them into MPEG-4 (m4v), 
tag them with correct mp4v2 tags and automatically
add them to iTunes.

### Structure

This is all done by parsing the folder structure and filenaming. So far the code
understands the following formats:

	How.I.Met.Your.Mother.S01E04.garbage.m4v
	How I Met Your Mother S01E04 garbage.m4v
	How I Met Your Mother 01x04 garbage.m4v
	How I Met Your Mother - 104.garbage.m4v
	How I Met Your Mother - S01E04 garbage.m4v
	How I Met Your Mother - [1x04] garbage.m4v
	How I Met Your Mother/S01E04.garbage.m4v
	How I Met Your Mother/Season 1/1x04.garbage.m4v
	
Note: Not all variants are written here, but you get the pictures.
The output structure will look like this:

	How I Met Your Mother/Season 1/How I Met Your Mother - S01E04.m4v
	
### Encoding

Tv show files can be encoded from avi or mkv into MPEG-4 (m4v) files.
This is done using the Handbrake CLI runtime.

### Tagging

mp4v2 metadata tags are automatically added using 
[mp4v2 library](http://code.google.com/p/mp4v2/). The tags are downloaded 
from TheTVDB.

### iTunes Import

TV Shows can automatically be imported directly into iTunes upon completion.

**Important:**
If you want to preserve the folder structure provided by this code and avoid
duplicate files then you need to disable the following option in iTunes:

In the Advanced Preferences pane disable the option named
"Copy files to iTunes Media folder when adding to library" (see image below)

![iTunes preferences](https://github.com/ksmandersen/Media-Organizer/blob/master/img/itunes.png?raw=true)

## Dependencies

The code for this project is written in Ruby and uses Rubygems.

The encoding process uses [Handbrake CLI](http://handbrake.fr/downloads2.php)
and the [Handbrake RubyGem](http://rubygems.org/gems/handbrake). The Handbrake CLI
is offered as an installer and the rubygem can be installed with his command:
	
	gem install handbrake

Importing into iTunes requires OS X because it uses Automator workflows. 

Tagging files requires [mp4v2 library](http://code.google.com/p/mp4v2/) which needs
to be installed manually for now. It will be bundled in future releases.

## Installation
To get started install all the dependencies and run this command:

	git clone git://github.com/ksmandersen/Media-Sorter.git
	
Open up the ```Config.rb``` file in the text editor of your choice and edit
```target_path```, ```origin_path``` and ```handbrake_cli```.

If you've installed Handbrake CLI correctly you can find the path for it
by executing this command:

	which HandbrakeCLI

## Usage

Navigate to the cloned folder and run this command:

	ruby Run.rb
	
Several options can be passed along to override the config file

	Usage: Run.sh [options]
		-h, --help                       Display this screen
		-v, --verbose                    Run verbosely
		-f, --force                      Force overwrite of video files in target dir

	Paths:
		-i, --input-dir DIR              Input directory for video files
		-o, --output-dir DIR             Output directory for video files
			--handbrake-cli PATH         Path to the HandbrakeCLI binary
	
	Features:
			--[no-]tags                  Add mp4v2 tags to video files
			--[no-]encode                Encode video files to MPEG-4
			--[no-]import                Import video files to iTunes
			--[no-]cleanup               Delete original video files
			
## Disclaimer
This software is being actively developed and may have several bugs.
Use with caution and at own risk. This software is provided without
warrenty of any kind (see License).

## License
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to [http://unlicense.org/]()