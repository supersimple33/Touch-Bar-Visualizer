# Touch Bar Visualizer
![version badge](https://img.shields.io/github/v/release/supersimple33/Touch-Bar-Visualizer)
![license badge](https://img.shields.io/github/license/supersimple33/Touch-Bar-Visualizer)
![stars badge](https://img.shields.io/github/stars/supersimple33/Touch-Bar-Visualizer)
![build badge](https://img.shields.io/circleci/build/github/supersimple33/Touch-Bar-Visualizer/master)
![The program in action](visual.png)
The Touch Bar Visualizer is a cosmetic program used to display the sound output from the computer as frequencies. The purpose of this program is to provide another cool trick for users that have a macbook equipped with a touchbar. While there are many music vissualizers out there this program is designed to both utilize a space on the keyboard often ignored and to provide a new way of directly viewing music when other programs may need space on the screen. Touch Bar Visualizer is written in Swift 5 and utilizes some objective-c methods. The backbone of the processing is based on Accelerate's vDSP methods. 

## Getting Started
These instructions will get you a copy of the project up and running on your local machine for general use.
### Prerequisites
In order to listen to system sound Touch Bar Visualizer requires BlackHole to be installed (however TBV will work just fine without blackhole and integrate the microphone and other audio inputs). BlackHole can be found [here](https://github.com/ExistentialAudio/BlackHole). Follow the instructions from BlackHole in order to download and run the installer and create a new audio device channel. 
- BlackHole may also be installed via homebrew by running the following command in terminal: 
- `brew install blackhole-2ch`
### Installation
Once BackHole has been installed (or not) you may either download the source of this project or download the latest [release](https://github.com/supersimple33/Touch-Bar-Visualizer/releases).
### Usage
Upon opening the app a new aggregate device will be created between soundflower and the currently selected output speakers. The volume levels for this device are then leveled using rnine's [AMCoreAudio](https://github.com/rnine/AMCoreAudio). Next the audio inputs will be analyzed and a visualization will be sent to the touch bar. When closing the app the aggregate device will be closed and the input returned to normal. You may switch between the blocks view and the line view using the switch within the window. The color of the line visualizer may be changed using the colorwell in the window. 
### Microphone & Other Audio Inputs
If you don't need or don't want to install blackhole you may press the `use without blackhole` button to capture audio from the default input audio device. This process also works if you have blackhole installed and unchecking and checking this option will switch between the two modes. This mode allows for easier interfacing with other programs that also monitor system sound or allows you to vissualize the sound in your current enviroment. 
### Background Usage
The app will continue to run in the background and can be found on the control strip along with volume and brightness settings. To shutdown the app ensure you quit not only just close the window. 

## ToDo
- ~~Add a different view for the Vissualizer (this is probably next and if you have any ideas create a PR or leave a comment.~~
- ~~Create a new menu for selecting different audio inputs other than soundflower.~~
## Community
- If you find a bug or would like to request a feature/leave feedback please open an issue
- Feel free to contribute any help is welcome!!!
