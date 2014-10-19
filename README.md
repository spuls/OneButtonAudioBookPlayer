OneButtonAudioBookPlayer
========================

Arduino based audio book player to be controlled with only one button - targeted user: elderly grandmother.

The Arduino is used to control a Rogue MP3 shield. That shield has SD-card support, audio out and comes with 
appropriate libraries to ease programming.

Usage of player:
- The user interface is a single button. The prototype uses a big green button to turn playback on and off. 
  The state of playback is visualized via a green LED.
- When resuming playback afer pausing the last 10 seconds are repeated. I find, this makes it easier to follow
  after a brake.
- When the end of the last file is reached, playback starts with first file again.

Tips for filling the SD-card:
- The order of files copied (not their actual alphabetical order) defines the order of playback (so far). 
  The SD-card library returns a list of found files in that order. No sorting was additionally implemented.
  (The same behaviour had my old iRiver mp3 player as well, so I was used to that.)

Tips for changing the SD-card:
- When the card has to be changed, due to finished audio book, the player's power supply needs to be unplugged.
  After inserting the newly filled card the player can be plugged in again. During start-up the card is scanned,
  and determined if new content is on card - if so: start playback with first file, 
  else: continue playback from last known position.
