
source /local/global/login
source /local/global/login.useful

setenv PRINTER spb

source /local/global/poplogin.new           # Set up Poplog

source /local/global/TeXlogin               # Set up TeX
setenv TEXINPUTS $HOME/tex/inputs/new:$HOME/tex/inputs:/local/lib/tex/inputs/beta:$TEXINPUTS

source /local/global/xlogin                 # Set up X11

source /local/global/GNUlogin               # Set up GNU

set path = ($HOME/bin $HOME/bin/$HOST_TYPE $path)

umask 022
echo ""
uptime
echo ""


