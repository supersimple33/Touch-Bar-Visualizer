//
//  NSObject+NewAudioDevice.m
//  TouchBarVisualizer
//
//  Created by Addison Hanrattie on 9/3/19.
//  Copyright © 2019 Addison Hanrattie. All rights reserved.
//

#import "NewAudioDevice.h"
#include <CoreAudio/CoreAudio.h>

static AudioObjectID aggDeviceID = 0;

@implementation NewAudioDevice

- (void) newAggDevice:(CFArrayRef)devices :(AudioObjectID)inputID {
    
    // Adapted from bit.ly/2jZflVx
    // Create New Aggregate Device
    CFMutableDictionaryRef params = CFDictionaryCreateMutable(kCFAllocatorDefault, 10, NULL, NULL);
    
    CFDictionaryAddValue(params, CFSTR(kAudioAggregateDeviceUIDKey), CFSTR("TBV Aggregate Device"));
    CFDictionaryAddValue(params, CFSTR(kAudioAggregateDeviceNameKey), CFSTR("TBV Output"));

    
    static char stacked = 1;
    CFNumberRef cf_stacked = CFNumberCreate(kCFAllocatorDefault, kCFNumberCharType, &stacked);
    CFDictionaryAddValue(params, CFSTR(kAudioAggregateDeviceIsStackedKey), cf_stacked);
    
    CFDictionaryAddValue(params, CFSTR(kAudioAggregateDeviceSubDeviceListKey), devices);
    
    AudioObjectID resulting_id = 0;
    OSStatus result = AudioHardwareCreateAggregateDevice(params, &resulting_id);
    
    if (result)
    {
        printf("Error: %d\n", result);
    } else {
        aggDeviceID = resulting_id;
    }
    
    // Set Input and Output Devices
    UInt32 propertySize = sizeof(UInt32);
    AudioHardwareSetProperty(kAudioHardwarePropertyDefaultOutputDevice, propertySize, &resulting_id);
    AudioHardwareSetProperty(kAudioHardwarePropertyDefaultInputDevice, propertySize, &inputID);
}

- (void) destroyAggDevice {
    AudioHardwareDestroyAggregateDevice(aggDeviceID);
}

@end
