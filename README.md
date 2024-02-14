# What is pcf-install

The tool is used to easily compile PCF components, build the solution as a release and then install it in your Power Platform environment.\
It can be used both for the initial installation and for updates.

# Prerequisites
- [Power Platform CLI (pac)](https://learn.microsoft.com/en-us/power-platform/developer/cli/introduction?tabs=windows)
- [msbuild](https://learn.microsoft.com/en-us/visualstudio/msbuild/walkthrough-using-msbuild?view=vs-2022#install-msbuild)

# Installation
Download the installer from the release and run the executable.

# Usage

## Add pac profile
If you have not yet added a profile for the respective environment in the Power Platform CLI, you have to do so with the following command:
```
pac auth create --environment < Your environment ID >
```

## Select the pac profile
Before you start the application you should check if the right profile is selected.\
First list all of your profiles with the following command to get the index of the right profile:
```
pac auth list
```
Then run this command to select the profile:
```
pac auth select --index < index >
```

## Run the script
Run `pcf-install` in the diretory where your `.pcfproj` file is located.
