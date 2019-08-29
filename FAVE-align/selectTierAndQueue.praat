##
##
## This program accomplishes two tasks: 
##
## 		First, it takes all of your textgrid files in a certain directory
## 	and scans through their tiers to generate textgrids that only have
## 	the phone and word tiers corresponding to the speaker in the file name.
## 	The program assumes that files follow the following labeling format:
##			Location_Firstname_Lastname.TextGrid
## 		It also assumes that for each speaker, there are only phone and word 
## 	tiers. The program checks for the most common labeling methods in order to 
##	identify the target speaker: 
##			1) First it looks for tiers named solely as "speaker" or the target's 
## 			   full name. 
##			2) Then it looks at tiers whose names contain "speaker" or the 
##			   target's first or last name. 
##		These targets can be easily adjusted in the trackTiers procedure. When 
##	two tiers corresponding to the speaker in the file name are not able to be 
##	identified, they're printed in info window for manual discretion. In addition, 
##	successfully extracted files are listed with their tiers for double-checking
##
##		Second, it adds all of the speakers referenced in the TextGrid file names
##	to a queue for extraction. 
##		This portion assumes an input file containing demographic info for all 
##	speakers, with at least columns for:
##			1) first name (labeled "First"), last name ("Last"), sex ("Sex"), and location ("Location").
##	Speakers that need manual discretion are printed in the info window.
##	(Note: unless noted, speakers are added to table even if their accompanying 
##	textgrids need to be manually prepared)
## 
##

form Get initial info
	sentence inputTableName Status.txt
	sentence endDirectory ../FAVE-extract
endform

# Gets list of TextGrid files 
strings = Create Strings as file list: "list", shellDirectory$ + "/*.TextGrid"
numberOfFiles = Get number of strings

writeInfoLine: "Here are all the files you need to manually prepare:"
appendInfoLine: "     (Note: unless noted, speakers have been added to table even if their"
appendInfoLine: "      accompanying textgrids need to be manually prepared)"
appendInfoLine: " "

# Gets table for looking up sex of speaker
inputTable$ = shellDirectory$ + "/" + inputTableName$
tableInfo = Read Table from tab-separated file: inputTable$

#prepares queue file
queue$ = endDirectory$ + "/queue.txt"
header$ = "First	Last	Sex	Location"
writeFileLine: queue$, header$

# Loops through each TextGrid listed in the input directory.
for ifile to numberOfFiles
	selectObject: strings
	fileName$ = Get string: ifile
	@parseInfo
	currentTextgrid = Read from file: shellDirectory$ + "/" + fileName$
	selectObject: currentTextgrid
	numTiers = Get number of tiers
	@match
	@formQueue
endfor

appendInfoLine: " "
appendInfoLine: " "
appendInfoLine: " "
appendInfoLine: " "
appendInfoLine: "You may also check the tier names of the files successfully extracted:"
appendInfoLine: " "

@listExtractedTiers
@sortQueue


##### Uses file name to get location, first name, and last name    #####

procedure parseInfo
	fileNameBare$ = fileName$ - ".TextGrid" 
	currentLength = length (fileNameBare$)
	firstUnderscore = index (fileNameBare$, "_")
	.location$ = left$ (fileNameBare$, firstUnderscore - 1)

	cutOff$ = right$ (fileNameBare$, currentLength - firstUnderscore)
	currentLength = length (cutOff$)
	secondUnderscore = index (cutOff$, "_")

	.lastName$ = left$ (cutOff$, secondUnderscore - 1)
	.firstName$ = right$ (cutOff$, currentLength - secondUnderscore)
endproc


##### Tags tiers that may indicate target speaker. First looks for #####
##### tiers named solely as "speaker" or the target's full name.   #####
##### Then it looks at tiers whose names contain "speaker" or the  #####
##### target's first or last name. Success identifying exactly two #####
##### tiers matching a target sends the TextGrid to get adjusted.  #####
##### and saved. Prints name in info window if manual discretion   #####
##### necessary.                                                   #####

procedure match
	.tierTracker# = zero# (numTiers)
	@trackTiers: 1, 2
	tierTrack = sum(.tierTracker#)
	if tierTrack = 2
		@saveAdjustedFile
	elsif tierTrack > 2
			@manualInfo
	else
		@trackTiers: 3, 6
		if sum (.tierTracker#) = 2
			@saveAdjustedFile
		else
			@manualInfo
		endif
	endif
endproc


##### Prints the file name for TextGrids whose appropriate tier    #####
##### was not located. o's mark ones that were flagged as positive #####
##### matches for give targets, x's mark negative matches.         #####

procedure manualInfo
	appendInfoLine: fileName$
	for tierNum from 1 to numTiers
		tierName$ = Get tier name: tierNum
		if match.tierTracker# [tierNum] 
			appendInfoLine: "o     ", tierNum, " " + tierName$
		else
			appendInfoLine: "x     ", tierNum, " " + tierName$
		endif
	endfor
endproc


##### Sets a variety of possible ways a tier might denote a target #####
##### speaker. Then, checks if a tier name matches with any of the #####
##### targets in a given range. If there is a match, it sets the   #####
##### corresponding space in the tier tracker to 1.                #####

procedure trackTiers: paramBegin, paramEnd
	target$ [1] = "^(?i" + parseInfo.firstName$ + ".*" + parseInfo.lastName$ + " - (phone|word))"
	target$ [2] = "^(?ispeaker - (phone|word))"
	target$ [3] = "(?i" + parseInfo.firstName$ + ")"
	target$ [4] = "(?i" + parseInfo.lastName$ + ")"
	target$ [5] = "(?ispeaker)"
	target$ [6] = "SUB"	
	for tierNum from 1 to numTiers
		selectObject: currentTextgrid
		tierName$ = Get tier name: tierNum
		match = 0
		for paramNum from paramBegin to paramEnd
			if index_regex (tierName$, target$ [paramNum])
				match = match + 1
			endif
		endfor
		if match > 0
			match.tierTracker# [tierNum] = 1
		endif
	endfor
endproc


##### Deletes all tiers that didn't match with a possible speaker  #####
##### name and saves the resulting text grid to the end directory. #####

procedure saveAdjustedFile
	tierNum = numTiers
		while tierNum > 0
			if ! match.tierTracker# [tierNum] 
				selectObject: currentTextgrid
				Remove tier: tierNum
			endif
			tierNum = tierNum - 1
		endwhile
	newName$ = endDirectory$ + "/" + fileName$
	if fileReadable: newName$
		newName$ = endDirectory$ + "/" + "adjusted_" + fileName$
	endif
	Save as text file: newName$		
	removeObject: currentTextgrid
endproc


##### Looks up sex of speaker from input table and then adds the   #####
##### speaker to the queue file for extraction. Prints name in     #####
##### info window and marks table if it needs manual discretion.   #####

procedure formQueue
	selectObject: tableInfo
	numRows = Get number of rows
	sex$ = "Please manually enter"
	for row to numRows
		firstCheck$ = Get value: row, "First"
		lastCheck$ = Get value: row, "Last"
		locationCheck$ = Get value: row, "Location"
		if (firstCheck$ = parseInfo.firstName$ && lastCheck$ = parseInfo.lastName$ && locationCheck$ = parseInfo.location$)
			search$ = Get value: row, "Sex"
			if (search$ = "M") | (search$ = "F")
				sex$ = search$
			endif
		endif
	endfor
	if sex$ = "Please manually enter"
		appendInfoLine: inputTable$
		appendInfoLine: "     " + parseInfo.firstName$ + " " + parseInfo.lastName$
	endif
	line$ = parseInfo.firstName$ + "	" + parseInfo.lastName$ + "	" + sex$ + "	" + parseInfo.location$
	appendFileLine: queue$, line$ 
endproc


##### Prints tier names for successfully extracted TextGrids, so a #####
##### user can double-check them                                   #####

procedure listExtractedTiers
	strings = Create Strings as file list: "list", endDirectory$ + "/*.TextGrid"
	numberOfFiles = Get number of strings
	for ifile to numberOfFiles
		selectObject: strings
		fileName$ = Get string: ifile
		adjustedTextgrid = Read from file: endDirectory$ + "/" + fileName$
		selectObject: adjustedTextgrid
		appendInfoLine: fileName$
		numTiers = Get number of tiers
		for tierNum from 1 to numTiers
			selectObject: adjustedTextgrid
			name$ = Get tier name: tierNum
			tierNum$ = string$(tierNum)
			appendInfoLine: "          " + tierNum$ + "     " + name$
		endfor
		removeObject: adjustedTextgrid
	endfor
endproc


##### Sorts queue by sex for easy manual editing                   #####

procedure sortQueue
	queue$ = endDirectory$ + "/queue.txt"
	queue = Read Table from tab-separated file: queue$
	selectObject: queue
	Sort rows: "Sex"
	firstrowa$ = Get value: 1, "First"
	firstrowb$ = Get value: 1, "Last"
	firstrowc$ = Get value: 1, "Sex"
	firstrowd$ = Get value: 1, "Location"
	Set column label (label): "First", firstrowa$
	Set column label (label): "Last", firstrowb$
	Set column label (label): "Sex", firstrowc$
	Set column label (label): "Location", firstrowd$
	Remove row: 1
	Save as tab-separated file: queue$
endproc
