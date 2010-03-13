//
//  Spaces.h
//  RConsole
//
//  Created by greg on 12/03/10.
//  Copyright 2010 Grégoire Lejeune. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface Spaces : NSObject {

}

- (NSInteger)spaceNumber;
- (void)moveWindowToCurrentSpace:(NSWindow*)win;
- (void)moveWindow:(NSWindow *)win toSpaceNumber:(NSInteger)space;
- (NSInteger)getSpaceNumberOfWindow:(NSWindow *)win;
@end
