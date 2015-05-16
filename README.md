# WordPress full site spell checker

This is a crude spell checker tool for a full WordPress site using the WordPress export XML file. 
This is basically me-ware as I've used this only once to run a spellcheck on older posts back from the days WP didn't have a spell checker built into the editor. It might be useful for other people so I thought I'd host it on Github.

It uses [Hunspell](http://hunspell.sourceforge.net/), a free and open source spell checker and generates a simple HTML "report" telling you what words are misspelled (or unknown to the spell checker) and in what posts they occur.
You'll still have to go in and manually fix the spelling errors. I'm sorry. But using the spell checker tool built into WP that's a no-brainer.

## Requirements

In order for this script to work you need to meet a few requirements.

1. You do not fear the command line.
2. You need to have Hunspell installed and accessible in your PowerShell CLI. The easiest way to get this is by installing it using [Chocolatey](https://chocolatey.org/packages/hunspell.portable). You can also manually install it from the website. Make sure you get help info printed out to see if it's accessible if you run this statement after installing:

        hunspell --help

    You should see the help info printed. If not, you need to make Hunspell accessible in your system path, or create a batch script that points to your Hunspell executable in the wp-spellcheck folder.

3. Get the files from the GitHub repository using Git or download the zip and unpack that in a folder somewhere.

4. Get your WP content by using the Export tool in the Tools menu and download the XML file. For now this only works for posts. I haven't tried pages. Maybe you'll get lucky.

## Usage

1. Open a PowerShell command prompt and navigate to the folder you put the script in.

3. Start the spell check run like this: 

        wp-spellcheck.ps1 -WpExportFile .\mywpexportfile.xml

    You guessed it. You'll need to replace that filename with whatever funky name you came up with.

4. Sit back and enjoy the progress bar while the script is doing it's thing. It's a PowerShell progress bar. Probably one of it's coolest features.

5. The "report" will open automatically in your browser. Now the rest is up to you I'm afraid.

## Using the output

The report HTML file is created in the same folder as the script and is surprisingly called `results.html`. You can reopen this later without having to run the script again.

It lists all the words found ordered by most occurrences in posts. For each post you'll find a link the blog's page. If you are logged on as an admin in WP you'll see an edit link at the bottom of the post, so you can jump right to the editor.
There you fix the mistakes, save and get on with the next one. Quite tedious indeed.

Next to each found word, there's a checkbox. Checking that will hide the list of posts for that word. This makes it handy to keep track of what's done.
Note that this isn't stored anywhere. So if you close the browser window and reopen the file it will be reset.

## A word about Hunspell

Hunspell is the spell checker used from the script and it's great because I wouldn't want to write that myself. You can find more info about it on [Hunspell website](http://hunspell.sourceforge.net/) including additional dictionaries if English doesn't cut it, or the manuals in case you want to add word exclusions or fancy stuff like that.
Since the script is just calling the Hunspell executable all settings and changes should be applied when running it. Should. Cause I didn't test that.

