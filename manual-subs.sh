#!/bin/sh

TEXT=$1;
INPUT=./texts/$TEXT.txt;
SLIDES=./slides/$TEXT
PDF=./pdfs/$TEXT.pdf

brew_install_or_skip() {
    local PACKAGE=$1
    echo "Checking if $PACKAGE is installed..."
    brew list "$PACKAGE" &>/dev/null || brew install "$PACKAGE"
}

generate_slides() {
    local COUNTER=1
    local PARAGRAPH=""
    local LINE=""
    local RESOLUTION=1920x1080
    local COLOR_TITLE=white
    local COLOR_BACK=black
    local FONT_NAME="/System/Library/Fonts/Helvetica.ttc"
    local FONT_SIZE=70
    local FONT_SIZE_TITLE=100

    local INPUT=$1
    local SLIDES=$2

    # Create the output directory for slides
    mkdir -p $SLIDES
    rm $SLIDES/*.png

    # Read the input file line by line
    while IFS=$'\r' read -r LINE; do
        # Remove carriage return at the end of the line
        LINE=${LINE%$'\r'}
        # Check if the line is not empty
        if [[ -n $LINE ]]; then
        if [[ $LINE  == *"RED"* ]]; then
            COLOR_TITLE=red;
        elif [[ $LINE  == *"TITLE"* ]]; then
            FONT_SIZE=$FONT_SIZE_TITLE;
        else
            PARAGRAPH="$PARAGRAPH"$'\n\n'"$LINE";
        fi
        else 

        # Check if the paragraph is too long
        local P_LEN=${#PARAGRAPH}
        if (( "$P_LEN" > 600 )); then 
            echo
            echo "$COUNTER: $P_LEN"
            echo "    $PARAGRAPH" 
        else 
            echo "$COUNTER"
        fi

        # Create a slide
        magick \
            -size $RESOLUTION \
            -background $COLOR_BACK \
            -fill $COLOR_TITLE \
            -font $FONT_NAME \
            -pointsize $FONT_SIZE \
            -gravity West \
            caption:"$PARAGRAPH" \
            -bordercolor $COLOR_BACK \
            -border 100x100 \
            $SLIDES/$(printf "%03d" "$COUNTER").png

        PARAGRAPH=""
        COLOR_TITLE=white
        FONT_SIZE=70;
        COUNTER=$(($COUNTER+1))
        fi
    done < "$INPUT"

    echo $(($COUNTER-1)) were made
}

generate_pdf() {
    local SLIDES=$1
    local PDF=$2
    local files=()

    # Loop through the numerically sorted file names
    for file in $(ls $SLIDES/*.png | sort -n); do
        files+=("$file")
    done

    # Use convert to combine the files into a single PDF
    rm -f "$PDF"
    magick "${files[@]}" $PDF

    echo $PDF was created
}


# Check if imagemagick is installed
brew_install_or_skip imagemagick

generate_slides $INPUT $SLIDES
generate_pdf $SLIDES $PDF
open $PDF

echo "DONE"
