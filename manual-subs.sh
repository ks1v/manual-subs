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

blank_slide(){
    local NAME=$1
    local RESOLUTION=$2
    local COLOR_BACK=$3

    magick \
            -size $RESOLUTION \
            xc:$COLOR_BACK \
            $NAME
}

generate_slides() {
    local COUNTER=1
    local PARAGRAPH=""
    local LINE=""
    local RESOLUTION=1920x1080
    local COLOR_TITLE_DEFAULT=white
    local COLOR_BACK=black
    local FONT_NAME="/System/Library/Fonts/Helvetica.ttc"
    local FONT_SIZE_DEFAULT=70
    local FONT_SIZE_TITLE=100
    local GRAVITY_DEFAULT=West
    local GRAVITY_TITLE=Center

    local INPUT=$1
    local SLIDES=$2

    # Create the output directory for slides
    mkdir -p $SLIDES
    rm -f $SLIDES/*.png

    local FONT_SIZE=$FONT_SIZE_DEFAULT
    local COLOR_TITLE=$COLOR_TITLE_DEFAULT
    local GRAVITY=$GRAVITY_DEFAULT

    # Read the input file line by line
    while IFS=$'\r' read -r LINE; do
        # Remove carriage return at the end of the line
        LINE=${LINE%$'\r'}
        # Check if the line is not empty
        if [[ -n $LINE ]]; then
        if [[ $LINE  == *"RED"* ]]; then
            COLOR_TITLE=red;
        elif [[ $LINE  == *"TITLE"* ]]; then
            # Blank slide before TITLE
            blank_slide "$SLIDES/$(printf "%03d" "$COUNTER").png" $RESOLUTION $COLOR_BACK;
            printf "\rCreating slide #${COUNTER}"
            COUNTER=$(($COUNTER+1))

            FONT_SIZE=$FONT_SIZE_TITLE;
            GRAVITY=$GRAVITY_TITLE;
        else
            PARAGRAPH="$PARAGRAPH"$'\n\n'"$LINE";
        fi
        else 

        # Check if the paragraph is too long
        local P_LEN=${#PARAGRAPH}
        if (( "$P_LEN" > 660 )); then 
            echo
            echo "$COUNTER: $P_LEN"
            echo "    $PARAGRAPH" 
        else 
            printf "\rCreating slide #${COUNTER}"
        fi

        # Create a slide
        magick \
            -size $RESOLUTION \
            -background $COLOR_BACK \
            -fill $COLOR_TITLE \
            -font $FONT_NAME \
            -pointsize $FONT_SIZE \
            -gravity $GRAVITY \
            caption:"$PARAGRAPH" \
            -bordercolor $COLOR_BACK \
            -border 100x100 \
            $SLIDES/$(printf "%03d" "$COUNTER").png

        PARAGRAPH=""
        FONT_SIZE=$FONT_SIZE_DEFAULT
        COLOR_TITLE=$COLOR_TITLE_DEFAULT
        GRAVITY=$GRAVITY_DEFAULT
        COUNTER=$(($COUNTER+1))
        fi
    done < "$INPUT"
    # Blank slide before TITLE
    blank_slide "$SLIDES/$(printf "%03d" "$COUNTER").png" $RESOLUTION $COLOR_BACK;
    printf "\rCreating slide #${COUNTER}"
    echo ""
}

generate_pdf() {
    local SLIDES=$1
    local PDF=$2
    local files=()

    # Loop through the numerically sorted file names
    for file in $(ls $SLIDES/*.png | sort -n); do
        files+=("$file")
    done

    rm -f "$PDF"
    echo Creating PDF $PDF

    # Use convert to combine the files into a single PDF
    magick "${files[@]}" $PDF
}

brew_install_or_skip imagemagick;
generate_slides $INPUT $SLIDES;
generate_pdf $SLIDES $PDF;
open $PDF;

echo "DONE"
