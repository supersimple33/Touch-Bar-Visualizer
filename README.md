# Touch Bar Visualizer
![The program in action](visual.png)
The Touch Bar Visualizer is a cosmetic program used to display the sound output from the computer as frequencies. The purpose of this program is to provide another cool trick for users that have a macbook equipped with a touchbar. While there are many music vissualizers out there this program is designed to both utilize a space on the keyboard often ignored and to provide a new way of directly viewing music when other programs may need space on the screen. Touch Bar Visualizer is written in Swift 5 and utilizes some objective-c methods. The backbone of the processing is based on Accelerate's vDSP methods. 

## Getting Started
These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.
### Prerequisites
In order to listen to system sound Touch Bar Visualizer requires sound flower to be installed. Sound flower can be found [here](https://github.com/mattingalls/Soundflower). Follow the instructions from Soundflower in order to download and run the installer and create a new audio device channel.
### Installation
Once Soundflower has been installed you may either download the source of this project or download the latest release.
### Usage
Upon opening the app a new aggregate device will be created between soundflower and the currently selected output speakers. The volume levels for this device are then leveled using rnine's [AMCoreAudio](https://github.com/rnine/AMCoreAudio). Next the audio inputs will be analyzed and a vissualization will be sent to the touch bar. When closing the app the aggregate device will be closed and the input returned to normal. 
### Background Usage
The app will continue to run in the background and can be found on the control strip along with volume and brightness settings. 

## ToDo
- Add a different view for the Vissualizer
- Create a new menu for selecting different audio inputs other than soundflower.
- Feel free to contribute any help is welcome!!!
