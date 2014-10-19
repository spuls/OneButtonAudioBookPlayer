#include <NewSoftSerial.h>
#include <RogueMP3.h>
#include <RogueSD.h>

//#include <Serial.h>

// Definition of interrupt names
//#include < avr/io.h >
#include "C:\download\arduino\arduino-0023\hardware\tools\avr\avr\include\avr\io.h"
//#include <avr\include\avr\io.h>
// ISR interrupt service routine
//#include < avr/interrupt.h >
#include "C:\download\arduino\arduino-0023\hardware\tools\avr\avr\include\avr\interrupt.h"

NewSoftSerial rmp3_serial(6, 7);
RogueMP3 rmp3(rmp3_serial);
RogueSD filecommands(rmp3_serial);

// constants won't change. They're used here to 
// set pin numbers:
const int buttonPin = 2;     // the number of the pushbutton pin
const int ledPin =  13;      // the number of the LED pin


// variables will change:
volatile int buttonState = 0;         // variable for reading the pushbutton status
volatile int last_state = 0;
volatile int button_pressed = 0;

volatile int initStatus = 0; //0=uninit., 1=needReInit, 2=ReadFile, 3=SetParameter, 4=SaveFile, 5=Set up Player, 6=Initialized
boolean isPlaying = false;
volatile boolean doAction = false;

unsigned long button_time = 0;  
unsigned long last_button_time = 0;

// stat data
int32_t nrMP3s = 0;
uint32_t firstFileSize = 0;
uint16_t fileToPlay = 0;
uint16_t posInFile = 0;
int32_t nrMP3sRead = 0;
uint32_t fileSizeRead = 0;
uint16_t fileToPlayRead = 0;
uint16_t posInFileRead = 0;

char nameToPlay[128];

boolean noMoreFiles = false;


// Install the interrupt routine.
void pressedButton() 
{
   button_time = millis();
  //check to see if increment() was called in the last 250 milliseconds
  if (button_time - last_button_time < 750)
  {
    return;
  }
  last_button_time = button_time;
  // check the value again - since it takes some time to
  // activate the interrupt routine, we get a clear signal.
/*  buttonState = digitalRead(buttonPin);

  // check if the pushbutton is pressed.
  // if it is, the buttonState is HIGH:
  //if (buttonState == HIGH && last_state != buttonState) 
  if (buttonState == LOW && last_state != buttonState) 
  {     
    // turn LED on:    
    //digitalWrite(ledPin, HIGH);  
    button_pressed++;
    doAction = true;
    Serial.print("Do Action! ... ");
  }
  last_state = buttonState;
  */
  
  button_pressed++;
  doAction = true;
  return;
//  Serial.print("Do Action! ... ");
    
//  Serial.print("Pressed Button!\n");
}

void reInit()
{
  if(nrMP3s > 0)
  {
    char filename[128];
    filecommands.opendir("/");
    filecommands.readdir(filename, "*.mp3");
    int filehandle = filecommands.open(filename);
    fileinfo fi = filecommands.getfileinfo(filehandle);
    firstFileSize = fi.size;
    filecommands.close(filehandle);
    fileToPlay = 1;
    posInFile = 0;
  }
  else
  {
    firstFileSize = 0;
    fileToPlay = 0;
    posInFile = 0;
  }
  initStatus = 4;
}

//void saveInfo(int32_t *nr, uint32_t *fsize, uint16_t *fplay, uint16_t *pos)
void saveInfo()
{
  Serial.print("called saveInfo()\n");
  //noInterrupts();
//  Serial.print("some filecommands\n");
//  filecommands.closeall();
  filecommands.opendir("/");
  //  int fH = filecommands.getfreehandle();

//  Serial.print("open file\n");
  int fH = filecommands.open("playstat.txt", OPEN_RW);
/*
  if(fH==0)
  {
    Serial.print("No filehandles available!\n");
  }
  if(fH==-1)
  {
    Serial.print("Error requesting file handle!\n");
  }
  
  Serial.print("got handle\n");

  switch (filecommands.LastErrorCode)
  {
  case ERROR_INVALID_HANDLE:
    Serial.print("Invalid Handle\n");
    break;
  case ERROR_FILE_ALREADY_EXISTS:
    Serial.print("file already exists\n");
    break;
  case ERROR_OPEN_HANDLE_IN_USE:
    Serial.print("handle in use\n");
    break;
  case ERROR_OPEN_NO_FREE_HANDLES:
    Serial.print("no free handle\n");
    break;
  }
  */
  

 // int response = filecommands.writeln(fH, "");

//  Serial.print("write buffer\n");
  //  filecommands.open(fH, "playstat.txt", OPEN_WRITE);
  //  filecommands.writeln_prep(filehandle);
  char buff_save[128];
  sprintf(buff_save, "%li %lu %u %u", nrMP3s, firstFileSize, fileToPlay, posInFile);
  //  sprintf(buffer, "%d %d %d %d", *nr, *fsize, *fplay, *pos);
//  Serial.print("saveInfo: ");
//  Serial.print(buff_save);
  //filecommands.write(fH, strlen(buff_save), buff_save);
  
  
  filecommands.writeln_prep(fH);
  filecommands.print(buff_save);
  filecommands.writeln_finish();
  
  filecommands.close(fH);

//  Serial.print("\nsaveInfo finished\n");
  initStatus = 5;

  //interrupts();
}

void readFile()
{
  //Serial.print("Open playstat.txt\n");
  int filehandle = filecommands.open("playstat.txt", OPEN_RW);
  /*
  if(filehandle==0)
  {
    Serial.print("No filehandles available!\n");
  }
  if(filehandle==-1)
  {
    Serial.print("Error requesting file handle!\n");
  }
  
  Serial.print("got handle\n");

  switch (filecommands.LastErrorCode)
  {
  case ERROR_INVALID_HANDLE:
    Serial.print("Invalid Handle\n");
    break;
  case ERROR_FILE_ALREADY_EXISTS:
    Serial.print("file already exists\n");
    break;
  case ERROR_OPEN_HANDLE_IN_USE:
    Serial.print("handle in use\n");
    break;
  case ERROR_OPEN_NO_FREE_HANDLES:
    Serial.print("no free handle\n");
    break;
  }
  */
  char buffer[128];
  int ret = filecommands.read(filehandle, 128, buffer);
  filecommands.close(filehandle);

  
  if(ret>0)
  {
    //nrMP3sRead = atoi(buffer);
    sscanf(buffer, "%li %lu %u %u", &nrMP3sRead, &fileSizeRead, &fileToPlayRead, &posInFileRead);
  }
  initStatus = 3;
  /*
  Serial.print("nrMP3sRead, ret: ");
   Serial.print(ret); Serial.print(": "); Serial.print(nrMP3sRead); Serial.print(" ");
   Serial.print(fileSizeRead); Serial.print(" ");
   Serial.print(fileToPlayRead); Serial.print(" "); 
   Serial.print(posInFileRead); Serial.print(" "); Serial.print("\n");
   */
}

void setParameter()
{
  char filename[128];
  filecommands.opendir("/");
  filecommands.readdir(filename, "*.mp3");
  int fisrtfile = filecommands.open(filename);
  fileinfo fi = filecommands.getfileinfo(fisrtfile);
  uint32_t fileSize = fi.size;
  filecommands.close(fisrtfile);
  //check on actual data:
  if(nrMP3sRead != nrMP3s)
  {
    //Serial.print("nrMP3s: Need To ReInit!\n");
    //    reInit();
    initStatus = 1;
    return;
  }
  else if(fileSizeRead != fileSize)
  {
    /*
    Serial.print("fileSize: Need To ReInit!\n");
     Serial.print(fileSizeRead);
     Serial.print(" != ");
     Serial.print(fileSize);
     Serial.print("\n");
     */
    //    reInit();
    initStatus = 1;
    return;
  }
  else
  {
    firstFileSize = fileSize;
    fileToPlay = fileToPlayRead;
    posInFile = posInFileRead;
    initStatus = 5;

    Serial.print("set read values! ");
    Serial.print("posInFile: ");
    Serial.print(posInFile);
    Serial.print(", posInFileRead: ");
    Serial.print(posInFileRead);
    Serial.print("\n");

  }
}

void firstInit()
{
  /****************/
  /*
   * check if new audio book
   */
  /****************/
  // check on playstat.txt

    //Serial.print("find txt\n");
  filecommands.opendir("/");
  int32_t nrTXT = filecommands.filecount("*.txt");
  /*
  Serial.print("playstat.txt found: ");
   Serial.print(nrTXT);
   Serial.print("\n");
   */
  nrMP3s = filecommands.filecount("*.mp3");

  if(nrTXT == 0)
  {
    //no file found: need to read in new stat data
    initStatus = 1;
    //    reInit();
  }
  else
  {
    initStatus = 2;
    //stat file found: read data
    //Serial.print("Open playstat.txt\n");
    /*
    int filehandle = filecommands.open("playstat.txt", OPEN_RW);
     char buffer[16];
     int ret = filecommands.read(filehandle, 16, buffer);
     filecommands.close(filehandle);
     
     int32_t nrMP3sRead = 0;
     uint32_t fileSizeRead = 0;
     uint16_t fileToPlayRead = 0;
     uint16_t posInFileRead = 0;
     if(ret>0)
     {
     //nrMP3sRead = atoi(buffer);
     sscanf(buffer, "%li %lu %u %u", &nrMP3sRead, &fileSizeRead, &fileToPlayRead, &posInFileRead);
     }
     
     Serial.print("nrMP3sRead, ret: ");
     Serial.print(ret); Serial.print(": "); Serial.print(nrMP3sRead); Serial.print(" ");
     Serial.print(fileSizeRead); Serial.print(" ");
     Serial.print(fileToPlayRead); Serial.print(" "); 
     Serial.print(posInFileRead); Serial.print(" "); Serial.print("\n");
     
     char filename[128];
     filecommands.opendir("/");
     filecommands.readdir(filename, "*.mp3");
     int fisrtfile = filecommands.open(filename);
     fileinfo fi = filecommands.getfileinfo(fisrtfile);
     uint32_t fileSize = fi.size;
     filecommands.close(fisrtfile);
     //check on actual data:
     if(nrMP3sRead != nrMP3s)
     {
     //Serial.print("nrMP3s: Need To ReInit!\n");
     reInit();
     }
     else if(fileSizeRead != fileSize)
     {
     
     Serial.print("fileSize: Need To ReInit!\n");
     Serial.print(fileSizeRead);
     Serial.print(" != ");
     Serial.print(fileSize);
     Serial.print("\n");
     
     reInit();
     }
     else
     {
     firstFileSize = fileSize;
     fileToPlay = fileToPlayRead;
     posInFile = posInFileRead;
     
     Serial.print("set read values! ");
     Serial.print("posInFile: ");
     Serial.print(posInFile);
     Serial.print(", posInFileRead: ");
     Serial.print(posInFileRead);
     Serial.print("\n");
     
     }
     */
  }
  /*  
   Serial.print("Info found: nrMP3s: ");
   Serial.print(nrMP3s);
   Serial.print(", FileSize: ");
   Serial.print(firstFileSize);
   Serial.print(", fileToPlay: ");
   Serial.print(fileToPlay);
   Serial.print(", posInFile: ");
   Serial.print(posInFile);
   Serial.print("\n");
   */
  //  saveInfo();

}

/* @param file_nr starts at 0 */
boolean getFileName(uint16_t file_nr, char* name, int buffer_length)
{
  boolean ret = false;
  uint16_t counter = 0;
  char filename[buffer_length];
  filecommands.opendir("/");
  while(filecommands.readdir(filename, "*.mp3") == 0)
  {
    if(counter == file_nr)
    {
      strcpy(name, filename);
      ret = true;
      break;
    }
    counter++;
  }
//  Serial.println(name);
  return ret;
}

void setup()
{
  Serial.begin(9600);
  Serial.print("rmp3 init\n");
  rmp3_serial.begin(9600);

  Serial.print("rmp3 and file sync\n");
  rmp3.sync();
  filecommands.sync();
/*  
  char nTP[128];
  getFileName(1, nTP, 128); 
  nTP[127] = '\0';
*/
/*
  char nTP[128];
  filecommands.entrytofilename(nTP, 128, "./""*.mp3", 0);
  Serial.println(nTP);
  */
  
  

  Serial.print("set LEDs\n");  

  // initialize the LED pin as an output:
  pinMode(ledPin, OUTPUT);      
  // initialize the pushbutton pin as an input:
  pinMode(buttonPin, INPUT);

  //attachInterrupt(0, pressedButton, CHANGE);
  //attachInterrupt(0, pressedButton, FALLING);
  attachInterrupt(0, pressedButton, RISING);

  Serial.print("setup finished\n");
  /*
  char buffer[128];
   sprintf(buffer, "%li %lu %u %u", nrMP3s, firstFileSize, fileToPlay, posInFile);
   //sprintf(buffer, "%lu", firstFileSize);
   Serial.print("bevor saveInfo: ");
   Serial.print(buffer);
   */
  //saveInfo(&nrMP3s, &firstFileSize, &fileToPlay, &posInFile);

  /*
  char filename[128];
   filecommands.opendir("/");
   while(filecommands.readdir(filename, "*.mp3") == 0)
   {
   Serial.println(filename);
   }
   */


  //Serial.print("play file\n");
  //rmp3.playfile("01.mp3");
  //rmp3.playfile("/Daft Punk - Technologic.mp3");
  //Serial.print("done\n");
}

void loop()
{
//  Serial.print("loop\n");
  /*
  if(firstLoop)
   {
   firstLoop = false;
   //init player!
   firstInit();
   }
   */
  switch(initStatus)
  {
  case 0:
    {
      Serial.print("firstInit\n");
      firstInit();
      break;
    }
  case 1:
    {
      Serial.print("reInit\n");
      reInit();
      break;
    }
  case 2:
    {
      Serial.print("readFile\n");
      readFile();
      break;
    }
  case 3:
    {
      Serial.print("setParam\n");
      setParameter();
      Serial.print("setFileName\nfileToPlay: ");
      Serial.print(fileToPlay);
      Serial.print("\n");
//      filecommands.opendir("/");
      char nTP[128];
      //filecommands.entrytofilename(nTP, 128, "./""*.mp3", fileToPlay);
      getFileName(fileToPlay-1, nTP, 128);
      Serial.println(nTP);
      sprintf(nameToPlay, "%s", nTP);
      Serial.println(nameToPlay);
      Serial.print("\nsetFileName-Ende\n");
      break;
    }
  case 4:
    {
      Serial.print("saveInfo\n");
      saveInfo();
      break;
    }
  case 5:
    {
      Serial.print("play and pause.\n");
      //Serial.print(rmp3.getvolume());
      Serial.print("\n");
      rmp3.playfile(nameToPlay);
      int16_t leng = rmp3.gettracklength("/", nameToPlay);
      if(posInFile > leng)
      {
        Serial.print("Pos to long!\n");
      }
      else
      {
        rmp3.jump(posInFile);
      }
      rmp3.playpause();
      
      if(rmp3.getplaybackstatus() == 'P')
      {
        rmp3.playpause();
      }
      
      isPlaying = false;
      initStatus = 6;
      break;
    }
  case 6:
    {
      //Serial.print("Done\n");
      break;
    }
  }
  if(isPlaying && rmp3.getplaybackstatus() != 'P')
  {
    //should be playin' but isn't -> incremet file
//    Serial.print("increment file\n");
    posInFile = 0;
    fileToPlay++;
    /*
    if(nrMP3s < fileToPlay)
    {
      noMoreFiles = true;
      isPlaying = false;
    }
    else
    {
      char nTP[128];
//      filecommands.entrytofilename(nTP, 128, "./""*.mp3", fileToPlay);
      getFileName(fileToPlay-1, nTP, 128);
      sprintf(nameToPlay, "%s", nTP);
      rmp3.playfile(nameToPlay);
    }
    */
    if(nrMP3s < fileToPlay)
    {
      fileToPlay = 1;
      //noMoreFiles = true;
      //isPlaying = false;
    }
    
    char nTP[128];
//  filecommands.entrytofilename(nTP, 128, "./""*.mp3", fileToPlay);
    getFileName(fileToPlay-1, nTP, 128);
    sprintf(nameToPlay, "%s", nTP);
    rmp3.playfile(nameToPlay);
    
  }
  if(isPlaying && doAction)
  {
    //save and pause
    Serial.print("save and pause\n");
    doAction = false;
    playbackinfo info = rmp3.getplaybackinfo();
    posInFile = info.position;
    if(posInFile > 10)
    {
      posInFile -= 10;
    }
    else
    {
      posInFile = 0;
    }
    rmp3.playpause();
    isPlaying = false;
    saveInfo();
    Serial.print("return\n");
    return;
  }
  else if(!isPlaying && doAction && !noMoreFiles)
  {
    //load and play
    Serial.print("load and ... ");
    doAction = false;
    rmp3.playpause();
    isPlaying = true;
//    Serial.print("play\n");
  }
  if(button_pressed % 2 == 1)
  {
    digitalWrite(ledPin, HIGH);
//    isPlaying = true;

  }
  else
  {
    digitalWrite(ledPin, LOW);
//    isPlaying = false;
  }
}

