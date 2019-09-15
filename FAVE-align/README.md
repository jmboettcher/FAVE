# FAVE-align

For more information on the installation and use of FAVE-align, see the associated GitHub wiki pages: 
https://github.com/JoFrhwld/FAVE/wiki/FAVE-align

## Installation

### Dependencies

FAVE-align depends on **[HTK](http://htk.eng.cam.ac.uk/)** and **[SoX](http://sox.sourceforge.net/)** to work. 
As such, you'll need to have these installed.

As HTK requires modification of its source code to work properly, it is *strongly encouraged* that you refer to the GitHub wiki page on the topic (https://github.com/JoFrhwld/FAVE/wiki/HTK-3.4.1) even if you feel confident in what you're doing.

Otherwise [the FAVE GitHub wiki](https://github.com/JoFrhwld/FAVE/wiki) contains the relevant documentation for the installation and configuration of HTK and SoX.

## Usage

Usage:  

    python FAAValign.py [options] soundfile.wav [transcription.txt] [output.TextGrid]

Aligns a sound file with the corresponding transcription text. 
The transcription text is split into annotation breath groups, which are fed individually as "chunks" to the forced aligner. 
All output is concatenated into a single Praat TextGrid file.

### INPUT:

- sound file
- tab-delimited text file with the following columns:
    * first column:   speaker ID
    * second column:  speaker name
    * third column:   beginning of breath group (in seconds)
    * fourth column:  end of breath group (in seconds)
    * fifth column:   transcribed text

(If no name is specified for the transcription file, it will be assumed to have the same name as the sound file, plus ".txt" extension.)

### OUTPUT:
- Praat TextGrid file with orthographic and phonemic transcription tiers for
each speaker (If no name is specified, it will be given same name as the sound
file, plus ".TextGrid" extension.)

### Options:

Short | Long | Description
------ | -----| ------
 | `--version`  | Prints the program's version string and exits.
`-h` | `--help`  | Shows the help message and exits.
`-c [filename]` | `--check=[filename]`  | Checks whether phonetic transcriptions for all words in the transcription file can be found in the CMU Pronouncing Dictionary (file `dict`).  Returns a list of unknown words.
`-i [filename]` | `--import=[filename]`  | Adds a list of unknown words and their corresponding phonetic transcriptions to the CMU Pronouncing Dictionary prior to alignment.  User will be prompted interactively for the transcriptions of any remaining unknown words.  File must be tab-separated plain text file.
`-v` | `--verbose` | Detailed output on status of dictionary check and alignment progress.
`-d [filename]` | `--dict=[filename]` | Specifies the name of the file containing the pronunciation dictionary.  Default file is `/model/dict`.
`-n` | `--noprompt` | User is not prompted for the transcription of words not in the dictionary, or truncated words.  Unknown words are ignored by the aligner.


## Running selectTierAndQueue.praat

### Description, inputs, and outputs
This branch introduces a selectTierAndQueue.praat functionality which accomplishes two tasks: 1) selecting for one speaker per textgrid and 2) creating a queue of said speakers

#### Selecting for one speaker per textgrid

selectTierAndQueue.praat takes all of your textgrid files in a certain directory and scans through their tiers to generate textgrids that only have the phone and word tiers corresponding to the speaker in the file name.

The program assumes that files follow the following labeling format:

    LOCATION_Firstname_Lastname.TextGrid
    
It also assumes that for each speaker, there are only phone and word tiers. The program checks for the most common labeling methods in order to identify the target speaker: 
			1) First it looks for tiers named solely as "speaker" or the target's 
 			   full name. 
			2) Then it looks at tiers whose names contain "speaker" or the 
			   target's first or last name. 
		These targets can be easily adjusted in the trackTiers procedure in the code, depending on possible naming conventions used for the target speaker in the textgrid. Because selectTierAndQueue.praat runs through many possible conventions, it's especially useful when your target speaker is not uniformly identified in the textgrids. The more uniform your naming conventions for the target speaker, the fewer labeling methods the program needs to track.
        When two tiers corresponding to the speaker in the file name are not able to be identified, they're printed to the info window for manual discretion. In addition, successfully extracted files are listed with their tiers for double-checking.
	The output textgrid is saved to a new directory, FAVE-extract (or whatever you assign as your end directory), with the same file name:

	    LOCATION_Firstname_Lastname.TextGrid

#### Creating a queue of said speakers

selectTierAndQueue.praat adds all of the speakers referenced in the TextGrid file names to a queue for extraction. 
		This portion assumes you have an input file containing demographic info for all speakers with at least columns for:
		- first name (labeled "first")
		- last name ("last")
		- gender ("gender") 
		- location ("site")
		- birthyear ("birthyear")
		- ethnicity ("race_ethnicity")
 		- year of recording ("recording_year")
		- years of schooling ("education_years")
The input file can be labeled whatever you want, you will be calling it when you run the program.

Speakers that need manual discretion are printed in the info window.
(Note: unless noted, speakers are added to table even if their accompanying textgrids need to be manually prepared)

The output queue is saved to a new directory, FAVE-extract (or whatever you assign as your end directory), with the same file name:

	queue.txt

### Usage

In the directory `FAVE-align`, type:

    praat --run selectTierAndQueue.praat nameOfInputDemographicsFile.txt ../FAVE-extract

You may also change "../FAVE-extract" to your chosen end directory.
