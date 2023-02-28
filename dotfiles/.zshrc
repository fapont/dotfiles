# Load aliases
if [ -f .aliases ]; then
    source .aliases
else
    print "404: .aliases not found."
fi

# Load environment variables
if [ -f .variables ]; then
    source .variables
else
    print "404: .variables not found."
fi

# Load functions
if [ -f .functions ]; then
    source .functions
else
    print "404: .functions not found."
fi