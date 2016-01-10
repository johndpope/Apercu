//
//  ActiveSlider.swift
//  Apercu
//
//  Created by David Lantrip on 1/9/16.
//  Copyright © 2016 Apercu. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable

class ActiveSlider: UIView {
    var rect1: CGRect!
    var touchBoundingRect: CGRect!
//    touchBoundingRect = CGRectMake(10.0, 35.0, frameWidth - 20.0, 24)
    
    override func drawRect(rect: CGRect) {
        rect1 = rect
        drawCanvas1()
    }
    
    func onTouch(sender: UITapGestureRecognizer) {

    }
    
    func drawCanvas1(fillWidth fillWidth: CGFloat = 123) {
        let onClick = UITapGestureRecognizer(target: self, action: Selector("onTouch:"))
        self.addGestureRecognizer(onClick)
        
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Color Declarations
        let color = UIColor(red: 0.440, green: 0.440, blue: 0.440, alpha: 1.000)
        let color2 = UIColor(red: 0.000, green: 0.401, blue: 0.526, alpha: 1.000)
        var color2HueComponent: CGFloat = 1,
        color2SaturationComponent: CGFloat = 1,
        color2BrightnessComponent: CGFloat = 1
        color2.getHue(&color2HueComponent, saturation: &color2SaturationComponent, brightness: &color2BrightnessComponent, alpha: nil)
        
        let color3 = UIColor(hue: color2HueComponent, saturation: color2SaturationComponent, brightness: 0.8, alpha: CGColorGetAlpha(color2.CGColor))
        
        //// Gradient Declarations
        let gradient2 = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [color2.CGColor, color3.CGColor], [0, 1])!
        
        //// Shadow Declarations
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        shadow.shadowOffset = CGSizeMake(3.1, 3.1)
        shadow.shadowBlurRadius = 5
        
        //// Variable Declarations
        let circleOrigin: CGFloat = fillWidth + 10 - 11
        let frameWidth: CGFloat = rect1.width
        let barWidth: CGFloat = frameWidth - 20
        touchBoundingRect = CGRectMake(10.0, 35.0, frameWidth - 20.0, 24)
        
        //// Frames
        let frame = CGRectMake(0, 0, frameWidth, 79)
        
        
        //// Group
        //// Fill Rectangle Drawing
        let fillRectangleRect = CGRectMake(10, 37, fillWidth, 18)
        let fillRectanglePath = UIBezierPath(roundedRect: fillRectangleRect, cornerRadius: 8)
        CGContextSaveGState(context)
        fillRectanglePath.addClip()
        CGContextDrawLinearGradient(context, gradient2,
            CGPointMake(fillRectangleRect.minX, fillRectangleRect.midY),
            CGPointMake(fillRectangleRect.maxX, fillRectangleRect.midY),
            CGGradientDrawingOptions())
        CGContextRestoreGState(context)
        
        
        //// Main Rectangle 2 Drawing
        let mainRectangle2Path = UIBezierPath(roundedRect: CGRectMake(10, 37, barWidth, 18), cornerRadius: 8)
        UIColor.grayColor().setStroke()
        mainRectangle2Path.lineWidth = 2
        mainRectangle2Path.stroke()
        
        
        
        
        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalInRect: CGRectMake(circleOrigin, 35, 22, 22))
        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, (shadow.shadowColor as! UIColor).CGColor)
        UIColor.lightGrayColor().setFill()
        ovalPath.fill()
        CGContextRestoreGState(context)
        
        UIColor.grayColor().setStroke()
        ovalPath.lineWidth = 2
        ovalPath.stroke()
        
        
        //// Text Drawing
        let textRect = CGRectMake(frame.minX + 10, frame.minY + 62, 37, 17)
        let textTextContent = NSString(string: "None")
        let textStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = .Left
        
        let textFontAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(15), NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: textStyle]
        
        let textTextHeight: CGFloat = textTextContent.boundingRectWithSize(CGSizeMake(textRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, textRect);
        textTextContent.drawInRect(CGRectMake(textRect.minX, textRect.minY + (textRect.height - textTextHeight) / 2, textRect.width, textTextHeight), withAttributes: textFontAttributes)
        CGContextRestoreGState(context)
        
        
        //// Text 2 Drawing
        let text2Rect = CGRectMake(frame.minX + floor((frame.width - 25) * 0.24419) + 0.5, frame.minY + 62, 25, 17)
        let text2TextContent = NSString(string: "1m")
        let text2Style = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        text2Style.alignment = .Left
        
        let text2FontAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(15), NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: text2Style]
        
        let text2TextHeight: CGFloat = text2TextContent.boundingRectWithSize(CGSizeMake(text2Rect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: text2FontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, text2Rect);
        text2TextContent.drawInRect(CGRectMake(text2Rect.minX, text2Rect.minY + (text2Rect.height - text2TextHeight) / 2, text2Rect.width, text2TextHeight), withAttributes: text2FontAttributes)
        CGContextRestoreGState(context)
        
        
        //// Text 3 Drawing
        let text3Rect = CGRectMake(frame.minX + floor((frame.width - 25) * 0.48140) + 0.5, frame.minY + 62, 25, 17)
        let text3TextContent = NSString(string: "2m")
        let text3Style = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        text3Style.alignment = .Center
        
        let text3FontAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(15), NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: text3Style]
        
        let text3TextHeight: CGFloat = text3TextContent.boundingRectWithSize(CGSizeMake(text3Rect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: text3FontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, text3Rect);
        text3TextContent.drawInRect(CGRectMake(text3Rect.minX, text3Rect.minY + (text3Rect.height - text3TextHeight) / 2, text3Rect.width, text3TextHeight), withAttributes: text3FontAttributes)
        CGContextRestoreGState(context)
        
        
        //// Text 4 Drawing
        let text4Rect = CGRectMake(frame.minX + floor((frame.width - 25) * 0.72442 - 0.25) + 0.75, frame.minY + 62, 25, 17)
        let text4TextContent = NSString(string: "5m")
        let text4Style = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        text4Style.alignment = .Center
        
        let text4FontAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(15), NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: text4Style]
        
        let text4TextHeight: CGFloat = text4TextContent.boundingRectWithSize(CGSizeMake(text4Rect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: text4FontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, text4Rect);
        text4TextContent.drawInRect(CGRectMake(text4Rect.minX, text4Rect.minY + (text4Rect.height - text4TextHeight) / 2, text4Rect.width, text4TextHeight), withAttributes: text4FontAttributes)
        CGContextRestoreGState(context)
        
        
        //// Text 5 Drawing
        let text5Rect = CGRectMake(frame.minX + frame.width - 40, frame.minY + 62, 30, 17)
        let text5TextContent = NSString(string: "10m")
        let text5Style = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        text5Style.alignment = .Right
        
        let text5FontAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(15), NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: text5Style]
        
        let text5TextHeight: CGFloat = text5TextContent.boundingRectWithSize(CGSizeMake(text5Rect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: text5FontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, text5Rect);
        text5TextContent.drawInRect(CGRectMake(text5Rect.minX, text5Rect.minY + (text5Rect.height - text5TextHeight) / 2, text5Rect.width, text5TextHeight), withAttributes: text5FontAttributes)
        CGContextRestoreGState(context)
        
        
        //// Text 6 Drawing
        let text6Rect = CGRectMake(frame.minX + floor((frame.width - 210) * 0.50000 + 0.5), frame.minY + 6, 210, 21)
        let text6TextContent = NSString(string: "Most Active Period:")
        let text6Style = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        text6Style.alignment = .Center
        
        let text6FontAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(UIFont.buttonFontSize()), NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName: text6Style]
        
        let text6TextHeight: CGFloat = text6TextContent.boundingRectWithSize(CGSizeMake(text6Rect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: text6FontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, text6Rect);
        text6TextContent.drawInRect(CGRectMake(text6Rect.minX, text6Rect.minY + (text6Rect.height - text6TextHeight) / 2, text6Rect.width, text6TextHeight), withAttributes: text6FontAttributes)
        CGContextRestoreGState(context)
    }


}