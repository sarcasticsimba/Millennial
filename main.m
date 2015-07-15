/*
 * Millenial - A tool for the meme generation
 * main.m
 *
 *  $ mill <template path> <save path> <top text> ... ---- <bottom text> ...
 *
 *  The top and bottom text can be any number of words, they're delimited by
 *  four hyphens.
 *
 *  To have blank text on the top or bottom, pass in an underscore (_)
 *      $ mill template.png bottom.png _ ---- just bottom
 *      $ mill template.png top.png just top ---- _
 *      $ mill template.png no_caption.png _ ---- _
 *
 */

#import <Foundation/Foundation.h>
#import <Appkit/Appkit.h>

#define NINETY_FIVE_PERCENT 0.95
#define MAX_FONT_HEIGHT 0.5
#define MAX_FONT_WIDTH  0.8
#define MAX_FONT_SIZE 1000
#define STROKE_WIDTH @(-5)
#define DELIMITER @"----"
#define GENERIC_ERROR -1
#define IMPACT @"Impact"
#define MINIMUM_ARGS 6
#define BLANK @"_"
#define SPACE @" "
#define BOTTOM 0

/*
 *  fontSizeForImageDimensions
 *      Determines font size necessary to write a string of text
 *
 *  Parameters:
 *      NSSize dimensions
 *          Image dimensions
 *      NSString *text
 *          The text that's gotta fit on that image
 *
 *  Behavior:
 *      The maximum font size is limited to the smaller of:
 *          - 50% of image height
 *          - 80% of image width
 *          - 1000 points
 */
CGFloat fontSizeForImageDimensions(NSSize dimensions, NSString *text)
{
    NSMutableDictionary *attributes;
    NSSize str_size;
    NSFont *font;
    int i;
    
    if (dimensions.width == 0.0 || dimensions.height == 0.0) {
        return 0.0;
    }
    
    attributes = [[NSMutableDictionary alloc] init];
    str_size   = NSZeroSize;
    
    dimensions.height *= MAX_FONT_HEIGHT;
    dimensions.width  *= MAX_FONT_WIDTH;
    
    for (i = 1; i <= MAX_FONT_SIZE; i++) {
        font = [[NSFontManager sharedFontManager] convertWeight:YES
                                                         ofFont:[NSFont fontWithName:IMPACT size:i]];
        [attributes setObject:font forKey:NSFontAttributeName];
        str_size = [text sizeWithAttributes:attributes];
        
        if ((str_size.width  > dimensions.width) || (str_size.height > dimensions.height)) {
            break;
        }
    }
    
    return (CGFloat)i;
}

/*
 *  writeTextToImage
 *      Writes the given strings to the top and bottom of given NSImage
 *
 *  Parameters:
 *      NSImage *image
 *          Image to be modified. Expected to be initialized with the contents
 *          of an existing file.
 *      NSString *topText
 *          Text that will appear on the top of the image
 *      NSString *bottomText
 *          Text that will appear on the bottom of the image
 *
 *  Behavior:
 *      Y coordinate of:
 *          - Bottom text is zero
 *          - Top text is 95% of the image height minus text size in points
 *      X coordinates are calculated the same
 *          1. Applies the formatting to the string, grabs the width
 *          2. Subtracts the text width from the image width
 *          3. Halves that figure, which is the x-offset
 */
void writeTextToImage(NSImage *image, NSString *topText, NSString *bottomText)
{
    NSDictionary *topTextAttributes, *bottomTextAttributes;
    NSMutableDictionary *attributes;
    CGFloat xpos_t, xpos_b, ypos;
    NSFont *impact;
    
    impact = [NSFont fontWithName:IMPACT
                        size:fontSizeForImageDimensions(image.size, topText)];
    attributes = [[NSMutableDictionary alloc]
                    initWithObjects:@[impact,
                                      [NSColor whiteColor],
                                      [NSColor blackColor],
                                      STROKE_WIDTH]
                            forKeys:@[NSFontAttributeName,
                                      NSForegroundColorAttributeName,
                                      NSStrokeColorAttributeName,
                                      NSStrokeWidthAttributeName]];
    
    topTextAttributes = [[NSDictionary alloc] initWithDictionary:attributes];
    
    [attributes setObject:[NSFont fontWithName:IMPACT size:fontSizeForImageDimensions(image.size, bottomText)] forKey:NSFontAttributeName];
    
    bottomTextAttributes = [[NSDictionary alloc] initWithDictionary:attributes];
    
    xpos_t = (image.size.width - [[NSAttributedString alloc] initWithString:topText     attributes:topTextAttributes].size.width)    / 2;
    xpos_b = (image.size.width - [[NSAttributedString alloc] initWithString:bottomText  attributes:bottomTextAttributes].size.width) / 2;
    
    ypos = (image.size.height * NINETY_FIVE_PERCENT) - [[topTextAttributes objectForKey:@"NSFont"] pointSize];

    [image lockFocus];
    [bottomText drawAtPoint: NSMakePoint(xpos_b, BOTTOM) withAttributes:bottomTextAttributes];
    [topText    drawAtPoint: NSMakePoint(xpos_t, ypos)   withAttributes:topTextAttributes];
    [image unlockFocus];
}

/*
 *  saveImageToDisk
 *      Saves the given NSImage to the disk at the specified path
 *
 *  Parameters:
 *      NSImage *imageToSave
 *          duh
 *      NSString *savePath
 *          Where the image gets saved
 *
 *  Behavior:
 *      Saves the image as a PNG
 */
void saveImageToDisk(NSImage *imageToSave, NSString *savePath)
{
    NSBitmapImageRep *imageRep;
    NSDictionary *imageProps;
    NSData *imageData;
    
    imageData  = [imageToSave TIFFRepresentation];
    imageRep   = [NSBitmapImageRep imageRepWithData:imageData];
    imageProps = [NSDictionary dictionaryWithObject:@(1.0)
                                             forKey:NSImageCompressionFactor];
    imageData  = [imageRep representationUsingType:NSPNGFileType
                                        properties:imageProps];
    
    [imageData writeToFile:savePath atomically:NO];
}

/*
 *  argumentsFormattedCorrectly
 *      Checks whether the command line arguments contain the delimiter
 *
 *  Parameters:
 *      char **argv
 *          duh
 *
 *  Behavior:
 *      Loops through argv, checks whether the delimiter (----) exists.
 */
BOOL argumentsFormattedCorrectly(char **argv)
{
    while (++argv && *argv) {
        if ([@(*argv) containsString:DELIMITER]) {
            break;
        }
    }
    
    return (*argv != NULL);
}

/*
 *  fillTopAndBottomTexts
 *      Populates the top/bottom NSStrings with the text taken from the
 *      command line arguments
 *  
 *  Parameters:
 *      char **argv
 *          duh
 *      NSString **top
 *          Pointer to the NSString that will hold the text displayed at the top
 *          of the image
 *      NSString **bot
 *          Pointer to the NSString that will hold the text displayed at the
 *          bottom of the image
 *
 *  Behavior:
 *      If the first non-image path parameter is "_", it just assigns the string
 *      to a space. It then increments argv by two so it can still be at the
 *      right index to check the bottom string.
 *
 *      Once the check for "_" happens, it just iterates through argv, appending
 *      each entry to the string to be displayed, stopping only when it reaches
 *      the delimiter (if it's iterating the top string) or *argv is null.
 */
void fillTopAndBottomTexts(char **argv, NSString **top, NSString **bot)
{
    NSMutableString *t, *b;

    t = [[NSMutableString alloc] init];
    b = [[NSMutableString alloc] init];
    argv += 2;
    
    if ([@(argv[1]) isEqualToString:BLANK]) {
        [t setString:SPACE];
        argv += 2;
    } else {
        while (++argv && *argv && ![@(*argv) containsString:DELIMITER]) {
            [t appendString:SPACE];
            [t appendString:@(*argv)];
        }
    }
    
    if ([@(argv[1]) isEqualToString:BLANK]) {
        [b setString:SPACE];
    } else {
        while (++argv && *argv) {
            [b appendString:SPACE];
            [b appendString:@(*argv)];
        }
    }
    
    *top = [[NSString alloc] initWithString:t];
    *bot = [[NSString alloc] initWithString:b];
}

/* Pff, who needs objects? */
int main(int argc, char *argv[])
{
    @autoreleasepool {
        NSString *filePath, *savePath,
                 *topText,  *botText;
        NSImage *img;
        char **itr;
        
        if (argc < MINIMUM_ARGS) {
            printf("Not enough arguments!\n");
            return GENERIC_ERROR;
        }
        
        filePath = @(argv[1]);
        savePath = @(argv[2]);
        itr = argv;
        
        if (!(img = [[NSImage alloc] initWithContentsOfFile:filePath])) {
            printf("File %s doesn't exist!\n", argv[1]);
            return GENERIC_ERROR;
        }
        
        if (!argumentsFormattedCorrectly(itr)) {
            printf("Incorrectly formatted arguments!\n");
            return GENERIC_ERROR;
        }
        
        fillTopAndBottomTexts(itr, &topText, &botText);
        writeTextToImage(img, topText, botText);
        saveImageToDisk(img, savePath);
    }
        
    return 0;
}