# In the normal mode of operation (ie if sourced), "return" is silent
if [[ ! -z "$(return 2>&1)" ]];
then
    echo >&2 "ERROR: You must use \"source $0\" to run this script."
    kill -INT $$
fi

if [[ ! "$0" =~ ("bash") ]];
then
    # Not sourced from Bash
    BASH_SOURCE="$0"
    # For zsh (http://zsh.sourceforge.net/FAQ/zshfaq03.html#l18)
    setopt shwordsplit || true
fi

helpstring="Usage: source $BASH_SOURCE [options]
    Options:
        -d debug information is printed
        -b Creates a bare virtualenv with only system installed packages
        -h displays this string
        -p Path to the venv location
        -w No value following, deletes and recreates the venv from scratch
    The virtualenv found at -p will either be activated or created"

DEBUG=""
INSTALL_DEFAULTS="true"
WIPE=""

OPTIND=1
while getopts "p:whbd" opts
do
    case $opts in
        b)
            INSTALL_DEFAULTS="";;
        d)
            DEBUG="true";;
        p)
            VENV_ROOT="$OPTARG";;
        w)
            WIPE=1;;
        h)
            echo >&2 "${helpstring}"
            return 1;;
        \?)
            echo >&2 "${helpstring}"
            return 1;;
        [?])
            echo >&2 "${helpstring}"
            return 1;;
    esac
done
unset OPTIND

if [ ! -n "$VENV_ROOT" ]
then
    echo "VENV_ROOT is not set, exiting. Use option -p or declare in shell profile"
fi

SYSTEM_INFO="$(uname -a)"
KERNEL_VERSION="$(uname -r)"
FEDORA_VERSION="$(echo $KERNEL_VERSION | awk -F. '{print $4}')"
if [[ ! $FEDORA_VERSION == *"fc"* ]];
then
    echo "Unrecognized Fedora version $FEDORA_VERSION! Exiting..."
    return 1
fi

# setup virtualenv
####################
PIP=/usr/bin/pip3
VIRTUALENV=virtualenv
PYTHON_VERSION=$(python -c "import sys; sys.stdout.write(sys.version[:3])")
VENV_DIR=${VENV_ROOT}/${FEDORA_VERSION}/py${PYTHON_VERSION}

if [ -n "$DEBUG" ]
then
    echo SYSTEM_INFO $SYSTEM_INFO
    echo KERNEL_VERSION $KERNEL_VERSION
    echo FEDORA_VERSION $FEDORA_VERSION
    echo PIP $PIP
    echo PYTHON_VERSION $PYTHON_VERSION
    echo VENV_DIR $VENV_DIR
    echo VIRTUALENV $VIRTUALENV
fi

# Install virtualenv if it's not already there
if ! $PIP show -q virtualenv >/dev/null ; then
    $PIP install --user virtualenv
fi

# Check if user wants to start from scratch
if [[ "$WIPE" == "1" ]];
then
    /bin/rm -rf $VENV_DIR
fi

# Create the virtualenv
if [ ! -d "${VENV_DIR}" ]
then
    # Make virtualenv
    ####################
    echo mkdir -p $VENV_DIR
    mkdir -p $VENV_DIR
    echo $VIRTUALENV -p python$PYTHON_VERSION --system-site-packages $VENV_DIR
    $VIRTUALENV -p python$PYTHON_VERSION --system-site-packages $VENV_DIR
    . $VENV_DIR/bin/activate

    # Check virtualenv
    ####################
    if [ -z ${VIRTUAL_ENV+x} ] ; then
        echo "ERROR: Could not activate virtualenv"
        return
    fi

    # Update PIP and PYTHON
    PIP=$VIRTUAL_ENV/bin/pip
    unalias pip 
    alias pip="$VIRTUAL_ENV/bin/pip"
    PYTHON=$VIRTUAL_ENV/bin/python
    unalias python
    alias python="$VIRTUAL_ENV/bin/python"

    # Install deps
    ####################
    #echo $PIP install -U importlib 'setuptools>25,<=38' 'pip>8,<10'
    echo $PIP install -U importlib setuptools
    #$PIP install -U importlib 'setuptools>25,<=38' 'pip>8,<10'
    $PIP install -U importlib setuptools

    # Install Additional Packages?
    ####################
    if [ -n "$INSTALL_DEFAULTS" ]
    then
        $PIP install -U cx_Oracle
        $PIP install -U ipython
        $PIP install -U jupyter
        $PIP install -U matplotlib
        $PIP install -U numpy
        $PIP install -U pandas
        $PIP install -U python-dateutil
        $PIP install -U pytz
        #$PIP install -U ROOT
        #$PIP install -U root_numpy
        $PIP install -U scipy
        $PIP install -U six
        $PIP install -U sqlalchemy
    fi
else
    echo source $VENV_DIR/bin/activate
    source $VENV_DIR/bin/activate
   
    unalias pip 
    alias pip="$VIRTUAL_ENV/bin/pip"
    unalias python
    alias python="$VIRTUAL_ENV/bin/python"

	# Setup PATH
    ####################
	#export PATH=$PATH:$VIRTUAL_ENV/lib/python3.7/site-packages/<pkg name>/scripts
fi

echo PYTHONPATH $PYTHONPATH
