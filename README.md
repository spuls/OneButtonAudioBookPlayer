OneButtonAudioBookPlayer
========================

Arduino based audio book player to be controlled with only one button - targeted user: elderly grandparent.

## Electronics
The Arduino is used to control a Rogue MP3 shield. That shield has SD-card support, audio out and comes with 
appropriate libraries to ease programming. The audio out is without amplifier, thus, a speaker system with 
amplifier is needed. When using headphones this needs to be considered if dealing with hearing impaired people.

## Usage of player:
- The user interface is a single button. The prototype uses a big green button to turn playback on and off. 
  The state of playback is visualized via a green LED.
- When resuming playback afer pausing the last 10 seconds are repeated. I find, this makes it easier to follow
  after a brake.
- When the end of the last file is reached, playback starts with first file again.

## Tips for filling the SD-card
- The order of files copied (not their actual alphabetical order) defines the order of playback (so far). 
  The SD-card library returns a list of found files in that order. No sorting was additionally implemented.
  (The same behaviour had my old iRiver mp3 player as well, so I was used to that.)
- This should obviously not be done by the targeted enduser (i.e. elderly grandparent).

## Tips for changing the SD-card
- When the card has to be changed, due to finished audio book, the player's power supply needs to be unplugged.
  After inserting the newly filled card the player can be plugged in again. During start-up the card is scanned,
  and determined if new content is on card - if so: start playback with first file, 
  else: continue playback from last known position.
- Again, this should obviously not be done by the targeted enduser (i.e. elderly grandparent).

## 3D printing stuff
- Each side of the assembly has to printed.
- The bottom and side parts are skrewed together. The top is "press"-fit - don't really press, be gentle.
- SketchUp files are included (formerly known as Google SketchUp). Version 8 was used.
- For simply printing stuff, the *.stl files are also included.