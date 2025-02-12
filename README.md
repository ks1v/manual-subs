# Manual subtitle generator

Takes a text of a play and makes a PDF file with slides

## Usage
```bash
./manual-subs.sh <playID>
```

## Structure
* `./texts/<playID>.txt` - play text
* `./slides/<playID>/000.png` - individual slides
* `./pdfs/<playID>.pdf` - output file

## Defualt slide style

Background color - black

|           | Text  | Titles |
|-----------|-------|--------|
| Font size | 70    | 100    | 
| Color     | White | White  |
| Alignment | Left  | Center |

## Text format

Text file should be marked down as follows: 
1. Empty line separates two slides
2. Titles should be preceded with a `TITLE` keyword on the first line
3. Entire slide's text can be rendered red instead of white. In that case it should be preceded with `RED` keyword on the first line

### Example
This input creates three slides:

```
RED
Characters:
* Sanya, 35 years old
* Pasha, 37 years old
* Crocodile
* Mermaid
* Deep sea fish

TITLE
PART 1

Sanya. Would you be a fucking friend already?
Pasha. Am I fucking not?
Sanya. A motherfucker, that’s who you are.
Pasha. You are a motherfucker yourself.
```