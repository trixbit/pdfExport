//
//  UITextView+PDFExporter.m
//  PDF
//
//  Created by Emanuel Jarnea on 09/11/15.
//  Copyright © 2015 Trixbit Solutions. All rights reserved.
//

#import "UITextView+PDFExporter.h"
#import <CoreText/CTFramesetter.h>

@implementation UITextView (PDFExporter)

- (NSData *)PDFData
{
    UITextView *textView = self;
    
    // Prepare the text using a Core Text Framesetter.
    CFAttributedStringRef currentText = (CFAttributedStringRef)CFBridgingRetain(textView.attributedText);
    if (currentText) {
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(currentText);
        if (framesetter) {
            
            NSMutableData *pdfData = [NSMutableData new];
            
            // Create the PDF context.
            UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);
            
            CFRange currentRange = CFRangeMake(0, 0);
            NSInteger currentPage = 0;
            BOOL done = NO;
            
            CGSize pageSize = CGSizeMake((textView.textContainer.size.width -
                                          textView.textContainerInset.left - textView.textContainerInset.right -
                                          2 * textView.textContainer.lineFragmentPadding),
                                         textView.contentSize.height);
            CGRect pageRect = CGRectMake(0, 0, pageSize.width, pageSize.height);
            
            do {
                
                // Mark the beginning of a new page.
                UIGraphicsBeginPDFPageWithInfo(pageRect, nil);
                
                // Get the graphics context.
                CGContextRef    currentContext = UIGraphicsGetCurrentContext();
                
                // Clear the graphics context to achieve a transparent background.
                CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 0.0);
                CGContextClearRect(currentContext, pageRect);
                
                currentPage++;
                
                // Render the current page and update the current range to
                // point to the beginning of the next page.
                currentRange = [self renderPage:currentPage withPageSize:pageSize withTextRange:currentRange andFramesetter:framesetter];
                //                currentRange = [self renderPa renderPageWithTextRange:currentRange andFramesetter:framesetter];
                
                // If we're at the end of the text, exit the loop.
                if (currentRange.location == CFAttributedStringGetLength((CFAttributedStringRef)currentText))
                    done = YES;
            } while (!done);
            
            // Close the PDF context and write the contents out.
            UIGraphicsEndPDFContext();
            
            // Release the framewetter.
            CFRelease(framesetter);
            
            return [NSData dataWithData:pdfData];
            
        } else {
            NSLog(@"Could not create the framesetter needed to lay out the atrributed string.");
        }
        // Release the attributed string.
        CFRelease(currentText);
    } else {
        NSLog(@"Could not create the attributed string for the framesetter");
    }
    return nil;
}

// Use Core Text to draw the text in a frame on the page.
- (CFRange)renderPage:(NSInteger)pageNum withPageSize:(CGSize)size withTextRange:(CFRange)currentRange
       andFramesetter:(CTFramesetterRef)framesetter
{
    // Get the graphics context.
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    
    // Create a path object to enclose the text.
    CGRect frameRect = CGRectMake(0, 0, size.width, size.height);
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, frameRect);
    
    // Get the frame that will do the rendering.
    // The currentRange variable specifies only the starting point. The framesetter
    // lays out as much text as will fit into the frame.
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, NULL);
    CGPathRelease(framePath);
    
    // Core Text draws from the bottom-left corner up, so flip
    // the current transform prior to drawing.
    CGContextTranslateCTM(currentContext, 0, size.height);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    
    // Draw the frame.
    CTFrameDraw(frameRef, currentContext);
    
    // Update the current range based on what was drawn.
    currentRange = CTFrameGetVisibleStringRange(frameRef);
    currentRange.location += currentRange.length;
    currentRange.length = 0;
    CFRelease(frameRef);
    
    return currentRange;
}

@end
