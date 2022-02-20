# FamilyMatters
Utility for organizing family memories




Add the following code to the ~/.bashrc file
if [ -t 1 ]; then
	if command -v zsh # Git for Windows doesn't have zsh, this avoids it to exit 1 by startup
	then
		exec zsh
	fi	
fi