# MSX-Templates-for-VisualStudio
## MSX Application Template Pack for MS Visual Studio (and other environments)

### Version 00.06.00 - Codename Sam

Nov 19th, 2023</br>
Damned Angel / 2020-2023

---

## Table of contents
1. [Introduction](#introduction)
1. [To Caesar what is Caesar's - My note of acknowledgement and thanks](#to-caesar-what-is-caesars)
1. [Where to get the templates](#where-to-get-the-templates)
1. [I don’t like/have/care for/use MS Visual Studio](#i-dont-likehavecare-foruse-ms-visual-studio)
1. [Starting a project](#starting-a-project)
	1. [Setting up the environment](#setting-up-the-environment)
	1. [Creating your MSX project in Visual Studio](#creating-your-msx-project-in-visual-studio)
	1. [Creating your MSX project WITHOUT Visual Studio](#creating-your-msx-project-without-visual-studio)
	1. [Building (compiling/assembling) your MSX Application in Visual Studio](#building-compilingassembling-your-msx-application-in-visual-studio)
	1. [Building (compiling/assembling) your MSX Application WITHOUT Visual Studio](#building-compilingassembling-your-msx-application-without-visual-studio)
1. [Running your MSX applications on emulators](#running-your-msx-applications-on-emulators)
	1. [Running your BIN program in WebMSX](#running-your-bin-program-in-webmsx)
	1. [Running your BIN program in OpenMSX](#running-your-bin-program-in-openmsx)
	1. [Running your ROM program in WebMSX](#running-your-rom-program-in-webmsx)
	1. [Running your ROM program in OpenMSX](#running-your-rom-program-in-openmsx)
	1. [Running your standard MSX-DOS program in WebMSX](#running-your-standard-msx-dos-program-in-webmsx)
	1. [Running your standard MSX-DOS program in OpenMSX](#running-your-standard-msx-dos-program-in-openmsx)
	1. [Running your MSX-DOS program with overlays in WebMSX](#running-your-msx-dos-program-with-overlays-in-webmsx)
	1. [Running your MSX-DOS program with overlays in OpenMSX](#running-your-msx-dos-program-with-overlays-in-openmsx)

---

## Introduction
This asset is intended to document information about Damned Angel’s MSX Templates for MS Visual Studio (and other
environments).

4 templates are available:
- **MSX BIN applications** (BLOADable binary) ;
- **MSX ROM applications**;
- **MSX-DOS applications**; and
- **MSX-DOS application Overlays** (MDOs).

Each of the templates above has 2 variants:
- The Visual Studio one (\*.Template.zip), which allows VS to instantiate a project with build commands already
configured;
- The generic one (\*.Application.zip), which is a raw functional project, to be unzipped and edited with your
favorite IDE. Build commands must be issued in command-line (Windows, Linux and MacOS), or configured manually in your IDE.

**MSX-wise, the variants are equal and provide the same functionality.**

---

## To Caesar what is Caesar's
### Or: My note of acknowledgement and thanks
All the work I have been putting into the construction of the templates have been HEAVILY and COMPLETELY influenced by
[Konamiman](https://www.konamiman.com/msx/msx-e.html)'s work on
[SDCC libraries](https://www.konamiman.com/msx/msx-e.html#sdcc) and by
[Avelino Herrera](http://avelinoherrera.com/blog/)’s
[SDCC backend for MSXDOS](http://msx.avelinoherrera.com/index_en.html#sdccmsxdos) and SDCC
[backend for MSX ROMs](http://msx.avelinoherrera.com/index_en.html#sdccmsx).

Without their work, the MSX VS templates and makefiles I developed would not be there.

Masters, thank you very much for pioneering and publishing the content on MSX file formats generation.

In the current version of the templates, the build script has been unified in a single python file, supporting Windows, Linux and MacOS. Originally, however, there was a BAT script for Windows and a port for bash (Linux and MacOS) by [Pedro de Medeiros](https://github.com/pvmm).

Pedro, you have my eternal gratitude for your interest, ideas, patience and willful caring for the build script.

Additionally, I want to thank everbody on the WhatsApp **"MSX Pascal, C, ASM etc."** group, which are too many to cite
individually, but who helped a lot analyzing bugs and finding solutions. Thank you all!

---

## Where to get the templates
Please access the project's [Github](https://github.com/DamnedAngel/MSX-Templates-for-VisualStudio/releases) to get the
latest version of the templates.

After reading the release notes, go down to the Asset section of the page and you will find the templates and their
variants. 

---

## I don’t like/have/care for/use MS Visual Studio
If you don’t use MS VIsual Studio but still want to use the MSX project templates, you are lucky.

Although the templates are conceptualized and developed inside Microsoft Visual Studio, their bindings to this
environment are fairly loose. Surely, the VS-Specific templates (\*.Template.zip) include specific files that define
Visual Studio solutions and projects, but one can thoroughly disregard them and still take advantage of the project
structure and build script, along with his/her preferred IDE/Editors. In fact, a raw version of the templates
(\*.Application.zip) is readily provided for your convenience.

To use the templates outside Visual Studio (Windows, Linux, MacOS):
1. Make sure to have Python, SDCC and Hex2Bin installed in the path of your OS.
1. Download the raw template (\*.Application.zip) and unzip it in an appropriate folder in you computer.
1. Take advantage of the project structure.
1. Use the configuration files as described in this manual.
1. Build your project:
	1. Open a console of your Operating System (run **"CMD"** on Windows).
	1. Go to your project’s folder with the **“cd”** command.
	1. Enter one of the following commands (replace **\<PROFILE\>** with **“Debug”** or **“Release”** (case sensitive)):
		1. Windows (backslash):

				Build:			python .\Make\make.py <PROFILE>
				Rebuild All: 		python .\Make\make.py <PROFILE> clean all
				Clean:			python .\Make\make.py <PROFILE> clean

		1. Linux/Mac (slash):

				Build:			python ./Make/make.py <PROFILE>
				Rebuild All: 		python ./Make/make.py <PROFILE> clean all
				Clean:			python ./Make/make.py <PROFILE> clean
1. Have FUN!

---

## Starting a project
### Setting up the environment
1. Download and install your preferred IDE/Code editor.
	1. In case you wish to use MS Visual Studio, download it from https://visualstudio.microsoft.com/downloads/. The
	free "Community" version is good enough. **Be sure to install some workload, preferably the support for C++ and/or
	C++ games. Such extensions are NOT used for building the MSX programs, but they seem to be necessary in order for
	VS to recognize the MSX project templates.**
1. Download and install the latest version of SDCC from http://sdcc.sourceforge.net/.
	1. You may need to recompile from the source if the binary distribution for your OS is not available. It is a
	straightforward process, though.
	1. Make sure you have sdcc.exe and sdasz80.exe (comes with SDCC) in your OS’s path variable (open a command
	prompt/terminal/shell and type **sdcc \<enter\>** and **sdasz80 \<enter\>** and be sure the programs are executed).
1. Download and install Hex2Bin from http://hex2bin.sourceforge.net/.
	1. Again, you may need to recompile from the source if the binary distribution for your OS is not available. It is
	also a very straightforward process.
	1. Make sure you have hex2bin.exe in your Windows path variable (open a prompt/terminal/shell and type **hex2bin
	\<enter\>** and be sure the programs are executed).
1. Install Python from https://www.python.org/.
1. Download the MSX Application Templates from the project's
[Github](https://github.com/DamnedAngel/MSX-Templates-for-VisualStudio/releases).
	1. If you are using Visual Studio:
		1. Download the the Visual Studio templates (**\*.Template.zip**).
		1. Open Windows Explorer and go to **C:\\Users\\[User Name]\\Documents\\Visual Studio
		[Version]\\Templates\ProjectTemplates\\** (create the folders, if needed).
		1. Copy/Move the MSX Application Templates zip files to this folder:
	
			![MSX templates in VS's template folder](templates-in-vs-folder.png "MSX templates in VS's template folder")
		
		1. That should be all. In some installations, however, VS is stubborn to recognize the templates. If you
		encounter such a problem, things you may try:
			1. Create a new folder under “ProjectTemplates” and name it "MSX". Put the templates there.
			1. Unzip the templates, each in their own separate folder.
			1. If you installed VS without any workload (Language support), try to install C/C++ workloads
	1. If you are **NOT** using Visual Studio:
		1. Download the raw templates (**\*.Application.zip**). These should be unzipped in your development folder every
		time you want to create a new project.
1. Have a beer.

### Creating your MSX project in Visual Studio
1. After installing the templates, fire MS Visual Studio up.
1. Create you MSX project:
	1. Click the **Create a new project** button: 
	
		![Create a new project](vs-wizard-1.png "Create a new project")
	1. Locate the MSX templates on the template list. Sometimes their are shown in the bottom of the list, so you
	may have to scroll down:
	
		![MSX templates shown in VS's template list](vs-wizard-2.png "MSX templates shown in VS's template list")
	1. Choose the template you want and click **Next**.
	1. Fill in the name of your solution and project and set your preferred location for the project files:
	
		![Solution and Project names form](vs-wizard-3.png "Solution and Project names form")
	**Notes:**
		1. At this point, VS will double your project name as the Solution Name. If you don’t intend to have multiple
		projects inside the solution, leave it that way.
		1. Leave the **Place solution and project in the same directory** checkbox unmarked.
	1. Click the **Create** button.
	1. Sit and relax. When the fairies of the 8-bit realms complete their job, you should see the lovable Visual
	Studio Project Screen, inviting you to rock and roll:
	
		![MSX Project in Visual Studio](vs-wizard-4.png "MSX Project in Visual Studio")
1. Congrats! You have an MSX Application project. Have another beer.

### Creating your MSX project WITHOUT Visual Studio
1. After downloading the appropriate raw template (**\*.Application.zip**), create a folder for your project and unzip
the template into it.
1. Open the project files in the IDE of your choice.
1. Congrats! You have an MSX Application project. Have another beer.

### Building (compiling/assembling) your MSX application in Visual Studio
1. Select the configuration you want to use for the compiling/assembling:
	
	![MSX VS Project Profile](vs-building-1.png "MSX Project Profile in VS")
	**Note:** Later in this document we will (eventually) discuss what this option is for. For the moment, choose
	whatever you like, there will be no difference.
1. Select **Build | Build Solution** menu option:

	![MSX VS Project Build](vs-building-2.png "MSX Project Build in VS")
1. Visual Studio will run the make script. When it ends, you should see the results of the build process and the
messages of success in the bottom **Output** panel:

	![MSX VS Project Build Success](vs-building-3.png "MSX Project Build in VS success")
1. Inspect your generated binary file:
	1. Open Windows Explorer and navigate to the directory holding your solution (the folder you defined in step 2.iv
	of [Creating your MSX Application in Visual Studio](#creating-your-msx-application-in-visual-studio) section above.
	1. Access your solution’s folder.
	1. Access your project’s folder.
	1. Access the directory of your chosen build configuration (Debug/Release - see step 1 above).
	1. Access the "bin" folder. Your program should be there (the extension of the file may vary according to the type
	of project you chose):
	
		![MSX Win Project Binary File](vs-building-4.png "MSX Project binary file in Windows")
1. Yey! You successfully built your MSX application! Have one more beer!

### Building (compiling/assembling) your MSX application WITHOUT Visual Studio
1. Open a console of your Operating System (run **"CMD"** on Windows).
1. Go to your project’s folder:
	1. Windows:
		![MSX Win Project Build CD](win-building-1.png "MSX CD in Windows")
	1. Linux/Mac:
			![MSX Linux Project Build CD](linux-building-1.png "MSX CD in Linux/Mac")
1. Enter one of the following commands (replace **\<PROFILE\>** with **“Debug”** or **“Release”** (case sensitive)):
	1. Windows (backslash):

			Build:			python .\Make\make.py <PROFILE>
			Rebuild All: 		python .\Make\make.py <PROFILE> clean all
			Clean:			python .\Make\make.py <PROFILE> clean

		![MSX Win Project Build Script](win-building-2.png "MSX build script in Windows")
	1. Linux/Mac (slash):

			Build:			python ./Make/make.py <PROFILE>
			Rebuild All: 		python ./Make/make.py <PROFILE> clean all
			Clean:			python ./Make/make.py <PROFILE> clean

		![MSX Linux Project Build Script](linux-building-2.png "MSX build script in Linux/Mac")
1. When the script ends, you should see the results of the build process and the messages of success:
	1. Windows:
		![MSX Win Project Build Success](win-building-3.png "MSX Project Build in Windows success")
	1. Linux/Mac:
		![MSX Linux Project Build Success](linux-building-3.png "MSX Project Build in Linux/Mac success")
1. Inspect your generated binary file:
	1. Windows:
		![MSX Win Project Binary File](win-building-4.png "MSX Project binary file in Windows")
	1. Linux/Mac:
		![MSX Linux Project Binary File](linux-building-4.png "MSX Project binary file in Linux/Mac")
1. Yey! You successfully built your MSX application! Have one more beer!

---

## Running your MSX applications on emulators
The processes below suppose you have the emulators and its tools configured. If you don't, you will probably still be
able to use [WebMSX](https://webmsx.org/), which operation is very straight forward.

### Running your BIN program in WebMSX
1. Build your BIN project as instructed in the sections
[Building (compiling/assembling) your MSX Application in Visual Studio](#building-compilingassembling-your-msx-application-in-visual-studio)
or
[Building (compiling/assembling) your MSX Application WITHOUT Visual Studio](#building-compilingassembling-your-msx-application-without-visual-studio).
1. Fire WebMSX up and select **Drive A | Import Files to Disk** menu option:

	![WebMSX Import File Menu](WebMSX-BIN-1.png "WebMSX Import File Menu")
1. Select your program in the **Open File dialog** and click **Open**:
 
	![WebMSX Import BIN File](WebMSX-BIN-2.png "WebMSX Import BIN File")
1. In MSX-BASIC, type the command **FILES \<ENTER\>** to confirm that your program was added to the disk image:

	![WebMSX FILES Command](WebMSX-BIN-3.png "WebMSX FILES command")
1. Now… the time of truth! The moment we all have been waiting for… Type **BLOAD “MSXAPP.BIN”, R \<ENTER\>**
and you should see you program blissfully running:

	![WebMSX BIN Program Running](WebMSX-BIN-4.png "WebMSX BIN program running")
1. Yey! You successfully executed your MSX BIN application! Have one more beer!

## Running your BIN program in OpenMSX
1. Build your BIN project as instructed in the sections
[Building (compiling/assembling) your MSX Application in Visual Studio](#building-compilingassembling-your-msx-application-in-visual-studio)
or
[Building (compiling/assembling) your MSX Application WITHOUT Visual Studio](#building-compilingassembling-your-msx-application-without-visual-studio).
1. Fire OpenMSX's Catapult up, start the emulation and, in the **Session tab**, click on **Disk A** and select
**Browse for disk folder (DirAsDisk)** on the drop down menu:

	![OpenMSX Mount Dir as Disk](OpenMSX-BIN-1.png "OpenMSX Mount Dir as Disk")
1. Select your program’s folder in the Browse for Folder dialog and click on the **Select Folder** button:

	![OpenMSX Select Dir](OpenMSX-BIN-2.png "OpenMSX Select disk")

1. In MSX-BASIC, type the command **FILES \<ENTER\>** to confirm that your program was added to the disk image:

	![OpenMSX FILES Command](OpenMSX-BIN-3.png "OpenMSX FILES command")

1. Now… the time of truth! The moment we all have been waiting for… Type **BLOAD “\<FLOPPY DRIVE\>:MSXAPP.BIN”, R
\<ENTER\>** and you should see you program blissfully running:

	![OpenMSX BIN Program Running](OpenMSX-BIN-4.png "OpenMSX BIN program running")

1. Yey! You successfully executed your MSX BIN application! Have one more beer!

## Running your ROM program in WebMSX:
1. Build your ROM project as instructed in the sections
[Building (compiling/assembling) your MSX Application in Visual Studio](#building-compilingassembling-your-msx-application-in-visual-studio)
or
[Building (compiling/assembling) your MSX Application WITHOUT Visual Studio](#building-compilingassembling-your-msx-application-without-visual-studio).
1. Fire WebMSX up, drag the ROM file from your filesystem explorer and drop it on WebMSX's **Cartridge 1** panel:

	![WebMSX ROM File Drop](WebMSX-ROM-1.png "WebMSX ROM file drop")

1. During the boot process, you will see a (very fast) flash with the messages from the cartridge (don't worry they are
repeated. That is an effect of the ROM mirroring feature of the emulator):

	![WebMSX ROM Program Running](WebMSX-ROM-2.png "WebMSX ROM program running")

	**NOTE:** the messages are shown for just a brief moment because the example program just shows the messages and
	quits. Your program may (and probably will) have a different behavior.

1. Since the example program in its original settings implements extensions to the CALL command in basic, you can also
test this feature after the boot, typing **CALL CMD1 ("Message") \<ENTER\>** and **CALL RUNCART \<ENTER\>**:

	![WebMSX ROM Call Extensions](WebMSX-ROM-3.png "WebMSX ROM call extensions")

1. That's it! You successfully executed your MSX Cartridge ROM! One more beer for you!

## Running your ROM program in OpenMSX:
1. Build your ROM project as instructed in the sections
[Building (compiling/assembling) your MSX Application in Visual Studio](#building-compilingassembling-your-msx-application-in-visual-studio)
or
[Building (compiling/assembling) your MSX Application WITHOUT Visual Studio](#building-compilingassembling-your-msx-application-without-visual-studio).
1. Run OpenMSX's Catapult. In the **Session** tab, click on **Cart A** and select **Browse ROM image** in the drop down
menu:

	![OpenMSX ROM Open Image](OpenMSX-ROM-1.png "OpenMSX Open ROM Image")

1. Select your ROM file in the **Select ROM image** dialog and click on the **Open** button:

	![OpenMSX ROM Open File](OpenMSX-ROM-2.png "OpenMSX Open ROM File")

1. Back on Catapult's window, click on **Start** button on the bottom right:

	![OpenMSX ROM Start](OpenMSX-ROM-3.png "OpenMSX Start")

1. During the boot process, you will see a (very fast) flash with the messages from the cartridge (don't worry they
are repeated. That is an effect of the ROM mirroring feature of the emulator):

	![OpenMSX ROM Program Running](OpenMSX-ROM-4.png "OpenMSX ROM program running")
	**NOTE:** the messages are shown for just a brief moment because the example program just shows the messages and
	quits. Your program may (and probably will) have a different behavior.

1. Since the example program in its original settings implements extensions to the CALL command in basic, you can also
test this feature after the boot, typing **CALL CMD1 ("Message") \<ENTER\>** and **CALL RUNCART \<ENTER\>**:

	![OpenMSX ROM Call Extensions](OpenMSX-ROM-5.png "OpenMSX ROM call extensions")

1. You made it! You successfully executed your MSX Cartridge ROM! One more beer for you!

### Running your standard MSX-DOS program in WebMSX
1. Make sure that the **MDO_SUPPORT** option in *ApplicationSettings.txt** is set to **_OFF**:

	![WebMSX DOS MDO Support](WebMSX-DOS-1.png "WebMSX MDO Support in MSX-DOS Projects")
1. Build your MSX-DOS project as instructed in the sections
[Building (compiling/assembling) your MSX Application in Visual Studio](#building-compilingassembling-your-msx-application-in-visual-studio)
or
[Building (compiling/assembling) your MSX Application WITHOUT Visual Studio](#building-compilingassembling-your-msx-application-without-visual-studio).
1. Select WebMSX's **Drive A | Add Boot Disk** menu option:

	![WebMSX DOS Boot Disk](WebMSX-DOS-2.png "WebMSX Boot Disk")
1. Select WebMSX's **Drive A | Import Files to Disk** menu option:

	![WebMSX DOS Import File Menu](WebMSX-DOS-3.png "WebMSX Import File Menu")
1. Navigate to your project's binary file folder, select your executable and click the **Open** button:

	![WebMSX DOS Import COM File](WebMSX-DOS-4.png "WebMSX Import COM File")
1. Now your floppy image is complete, with MSX-DOS and your executable. Reset WebMSX to boot into MSX-DOS by selecting
**System | Reset** menu option:

	![WebMSX DOS Reset](WebMSX-DOS-5.png "WebMSX Reset")
1. When MSX-DOS boot completes, issue the "**DIR \<ENTER\>**" command and confirm that your program is available to be
executed:

	![WebMSX DOS Dir](WebMSX-DOS-6.png "WebMSX DOS DIR")
1. Execute your program by typing "**MSXAPP \<ENTER\>**":

	![WebMSX DOS Program Run](WebMSX-DOS-7.png "WebMSX DOS program run")
1. Since the default configuration of the MSX-DOS template includes support to command line parameters, we can
experiment that too. Type "**MSXAPP \<PARAMETERS\> \<ENTER\>**":

	![WebMSX DOS Parameters](WebMSX-DOS-8.png "WebMSX DOS program run with parameters")
1. Congrats for having your MSX-DOS program run! Have one more beer!

### Running your standard MSX-DOS program in OpenMSX
1. Although our target is using OpenMSX, we will still use WebMSX to generate the floppy disk image. Run steps
1 through 7 of the previous section
([Running your standard MSX-DOS program in WebMSX](#running-your-rom-program-in-webmsx)).
1. Once you confirmed that the floppy disk image is correct in the previous steps, select WebMSX's 
**Drive A | Save Disk Image** menu option and store the file somewhere in your computer.

	![OpenMSX DOS Save Disk Image](OpenMSX-DOS-1.png "WebMSX Save Disk Image")
1. Fire OpenMSX's Catapult front-end up and choose an MSX model with floppy disk to be emulated. In the
example below I chose Panasonic FS-A1GT (Turbo-R) because it is fast:

	![OpenMSX DOS Select Machine](OpenMSX-DOS-2.png "OpenMSX Machine selection")
1. Click on **Disk A** button and select **Browse for disk image** menu option:

	![OpenMSX DOS Browse for Disk Image](OpenMSX-DOS-3.png "OpenMSX Browse for Disk Image")
1. In the **Select disk image** dialog, navigate to the folder you saved the floppy image file. Select the
image file and click the **Open** button:

	![OpenMSX DOS Select Disk Image](OpenMSX-DOS-4.png "OpenMSX Select Disk Image")
1. In Catapult's main window, click the **Start** button:

	![OpenMSX DOS Start Emulation](OpenMSX-DOS-5.png "OpenMSX Start")
1. When MSX-DOS boot completes, issue the "**DIR \<ENTER\>**" command and confirm that your program is available to be
executed:

	![OpenMSX DOS Dir](OpenMSX-DOS-6.png "OpenMSX DOS DIR")
1. Execute your program by typing "**MSXAPP \<ENTER\>**":

	![OpenMSX DOS Program Run](OpenMSX-DOS-7.png "OpenMSX DOS program run")
1. Since the default configuration of the MSX-DOS template includes support to command line parameters, we can
experiment that too. Type "**MSXAPP \<PARAMETERS\> \<ENTER\>**":

	![OpenMSX DOS Parameters](OpenMSX-DOS-8.png "OpenMSX DOS program run with parameters")
1. Congrats for succeeding running your MSX-DOS program! Have one more beer!

### Running your MSX-DOS program with overlays in WebMSX
1. In the MSX-DOS module of your project (the program itself, not the MDO (MSX-DOS Overlay) module yet), make sure
that the **MDO_SUPPORT** option in the **ApplicationSettings.txt** config file is set to **_ON**:

	![WebMSX MDO MDO Support](WebMSX-MDO-1.png "MDO Support in MSX-DOS Projects")
1. Build your MSX-DOS project module as instructed in the sections
[Building (compiling/assembling) your MSX Application in Visual Studio](#building-compilingassembling-your-msx-application-in-visual-studio)
or
[Building (compiling/assembling) your MSX Application WITHOUT Visual Studio](#building-compilingassembling-your-msx-application-without-visual-studio).
1. In the MDO module of your project, make sure that the **MSX_BIN_PATH** option in both **TargetConfig_Debug.txt** and
**TargetConfig_Release.txt** config files points to the main MSX-DOS application's bin folders, so that the build
process will automatically place the MDOs files with the COM executable file:
 
	![WebMSX MDO BIN PATH](WebMSX-MDO-2.png "MSX_BIN_PATH Configuration")
1. Still in the MDO module of your project, make sure that the **MDO_APPLICATION_PROJECT_PATH** and
**MDO_PARENT_PROJECT_PATH** variables in the **MDOSettings.txt** config file point to your main MSX-DOS module
project:
 
	![WebMSX MDO Hierarchy](WebMSX-MDO-3.png "MDO_APPLICATION_PROJECT_PATH and MDO_PARENT_PROJECT_PATH configurations")
1. Build your MDO module as instructed in the sections
[Building (compiling/assembling) your MSX Application in Visual Studio](#building-compilingassembling-your-msx-application-in-visual-studio)
or
[Building (compiling/assembling) your MSX Application WITHOUT Visual Studio](#building-compilingassembling-your-msx-application-without-visual-studio).
1. Select WebMSX's **Drive A | Add Boot Disk** menu option:

	![WebMSX MDO Boot Disk](WebMSX-DOS-2.png "WebMSX Boot Disk")
1. Select WebMSX's **Drive A | Import Files to Disk** menu option:

	![WebMSX MDO Import File Menu](WebMSX-DOS-3.png "WebMSX Import File Menu")
1. Navigate to your project's binary file folder, select your COM executable and your MDO library and click the **Open** button:

	![WebMSX MDO Import COM and MDO File](WebMSX-MDO-4.png "WebMSX Import COM and MDO Files")
1. Now your floppy image is complete, with MSX-DOS and your executable. Reset WebMSX to boot into MSX-DOS by selecting
**System | Reset** menu option:

	![WebMSX MDO Reset](WebMSX-DOS-5.png "WebMSX Reset")
1. When MSX-DOS boot completes, issue the "**DIR \<ENTER\>**" command and confirm that your files are available to be
executed:

	![WebMSX MDO Dir](WebMSX-MDO-5.png "WebMSX DOS DIR")
1. Execute your program by typing "**MSXAPP \<ENTER\>**":

	![WebMSX DOS Program Run](WebMSX-DOS-7.png "WebMSX DOS program run")
1. Since the default configuration of the MSX-DOS template includes support to command line parameters, we can
experiment that too. Type "**MSXAPP \<PARAMETERS\> \<ENTER\>**":

	![WebMSX DOS Parameters](WebMSX-DOS-8.png "WebMSX DOS program run with parameters")
1. Congrats for having your MSX-DOS program run! Have one more beer!

### Running your standard MSX-DOS program in OpenMSX
1. Although our target is using OpenMSX, we will still use WebMSX to generate the floppy disk image. Run steps
1 through 6 of the previous section
([Running your standard MSX-DOS program in WebMSX](#running-your-rom-program-in-webmsx)).
1. Once you confirmed that the floppy disk image is correct in the previous steps, select WebMSX's 
**Drive A | Save Disk Image** menu option and store the file somewhere in your computer.

	![OpenMSX DOS Save Disk Image](OpenMSX-DOS-1.png "WebMSX Save Disk Image")
1. Fire OpenMSX's Catapult front-end up and choose an MSX model with floppy disk to be emulated. In the
example below I chose Panasonic FS-A1GT (Turbo-R) because it is fast:

	![OpenMSX DOS Select Machine](OpenMSX-DOS-2.png "OpenMSX Machine selection")
1. Click on **Disk A** button and select **Browse for disk image** menu option:

	![OpenMSX DOS Browse for Disk Image](OpenMSX-DOS-3.png "OpenMSX Browse for Disk Image")
1. In the **Select disk image** dialog, navigate to the folder you saved the floppy image file. Select the
image file and click the **Open** button:

	![OpenMSX DOS Select Disk Image](OpenMSX-DOS-4.png "OpenMSX Select Disk Image")
1. In Catapult's main window, click the **Start** button:

	![OpenMSX DOS Start Emulation](OpenMSX-DOS-5.png "OpenMSX Start")
1. When MSX-DOS boot completes, issue the "**DIR \<ENTER\>**" command and confirm that your program is available to be
executed:

	![OpenMSX DOS Dir](OpenMSX-DOS-6.png "OpenMSX DOS DIR")
1. Execute your program by typing "**MSXAPP \<ENTER\>**":

	![OpenMSX DOS Program Run](OpenMSX-DOS-7.png "OpenMSX DOS program run")
1. Since the default configuration of the MSX-DOS template includes support to command line parameters, we can
experiment that too. Type "**MSXAPP \<PARAMETERS\> \<ENTER\>**":

	![OpenMSX DOS Parameters](OpenMSX-DOS-8.png "OpenMSX DOS program run with parameters")
1. Congrats for succeeding running your MSX-DOS program! Have one more beer!

