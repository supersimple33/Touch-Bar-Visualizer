//
//  NSObject+NewAudioDevice.h
//  TouchBarVisualizer
//
//  Created by Addison Hanrattie on 9/3/19.
//  Copyright © 2019 Addison Hanrattie. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreAudio/CoreAudio.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewAudioDevice : NSObject

//+ (AudioObjectID) aggDeviceID;

- (void) newAggDevice:(CFArrayRef)devices;

- (void) destroyAggDevice;

@end

NS_ASSUME_NONNULL_END
