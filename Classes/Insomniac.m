//
//  Insomniac.m
//  cctracker
//
//  Created by Paul Borokhov on 3/29/10.
//  Copyright 2010 Paul Borokhov. All rights reserved.
/*
 **
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * DriveTracker is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#import "Insomniac.h"
#import "SynthesizeSingleton.h"
#import "DataCollector.h"
#import "MMRemoteDataRecorder.h"
#import "cctrackerAppDelegate.h"

@implementation Insomniac

SYNTHESIZE_SINGLETON_FOR_CLASS(Insomniac);

-(Insomniac*)init {
    if ((self = [super init])) {
        self.mustDisableIdleTimer = ![[NSUserDefaults standardUserDefaults] boolForKey:@"allowLocking"];
        self.playa = nil;
        if (![Insomniac supportsMultitasking]) [NSThread detachNewThreadSelector:@selector(setupAudioSession) toTarget:self withObject:nil];
        [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(sendErroredData:) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)setMustDisableIdleTimer:(BOOL)new {
    BOOL old = self.mustDisableIdleTimer;
    _mustDisableIdleTimer = new;
    if (new != old) [[NSNotificationCenter defaultCenter] postNotificationName:MustDisableIdleTimerChangedNotification object:nil];
    if (new && [DataCollector sharedDataCollector].collectingData) [UIApplication sharedApplication].idleTimerDisabled = YES;
    if (!new && [DataCollector sharedDataCollector].collectingData) [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)setupAudioSession {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    /**/AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        NSLog(@"Failed to set category on AVAudioSession");
        return;
    }
    
    if (![self enableMixing]) return;
    
    // TODO: Currently this will "play" through a Bluetooth headset, if one is connected, which is silly (and potentially even more wasteful from a battery standpoint).
    // Using kAudioSessionProperty_OverrideCategoryDefaultToSpeaker or kAudioSessionProperty_OverrideAudioRoute is only supported on 3.1+
    // and, according to the docs, only for the AVAudioSessionCategoryRecord category. We should consider whether we care about this.
    // Set the buffer to something more aggressive to prevent low-power sleep on screen lock
    OSStatus propertySetError = 0;
    Float32 preferredBufferDuration = 0.02; // 23 ms is the low-power buffer. just use 20 to prevent low power.
    propertySetError = AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(preferredBufferDuration), &preferredBufferDuration);
    if (propertySetError) {
        NSLog(@"Failed to set shorter I/O buffer on AVAudioSession, code %ld", propertySetError);
        return;        
    }
    
    BOOL active = [session setActive:YES error:nil];
    if (!active) {
        NSLog(@"Failed to set category on AVAudioSession");
        return;
    }
    
    // if we've gotten this far, then everything has been successful! no need to disable the idle timer.
    //self.mustDisableIdleTimer = NO;//*/
    
    // IMPORTANT!
    // The system deactivates your audio session for a Clock or Calendar alarm or incoming phone call. When the user dismisses the alarm, or chooses to ignore a phone call, the system allows your session to become active again. Do reactivate it, upon interruption end, to ensure that your audio works.
    // We handle this using AVAudioPlayerDelegate methods
    [pool drain];
}

- (BOOL)enableMixing {
    OSStatus propertySetError = 0;
    UInt32 allowMixing = true;
    propertySetError = AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof (allowMixing), &allowMixing);
    /* Here’s what the args mean:
     1. The identifier, or key, for the audio session property you want to set. Other audio session properties are described in Audio Session Services Property Identifiers.
     2. The size, in bytes, of the property value that you are applying.
     3. The value to apply to the property.
     
     This property has a value of false (0) by default. When the audio session category changes, such as during an interruption, the value of this property reverts to false. IMPORTANT! To regain mixing behavior you must then set this property again. ! *////*
    if (propertySetError) {
        NSLog(@"Failed to allow mixing on AVAudioSession");
        return NO;
    }
    return YES;
}

- (void)startDatacollection {
    if (mustDisableIdleTimer) {
        // disable screen locking
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    } else {
        [NSThread detachNewThreadSelector:@selector(startPlayback) toTarget:self withObject:nil];
    }
}

- (void)stopDatacollection {
    // regardless, enable screen locking. this way if the user changed preferences midtrip, we don't screw them.
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    if (mustDisableIdleTimer) {
    } else {
        [NSThread detachNewThreadSelector:@selector(stopPlayback) toTarget:self withObject:nil];
    }
}

- (void)startPlayback {
    if ([Insomniac supportsMultitasking]) return;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    // play some toonz!
    NSURL* soundURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"silence" ofType:@"wav"]];
    NSError *err = nil;
    if (!self.playa) self.playa = [[[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&err] autorelease];
    if (err) {
        // shucks, couldn't init player, revert to ghetto disable screen locking
        NSLog(@"Failed to init audio player, reverting to disabling idle timer");
        self.playa = nil;
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        return;
    }
    self.playa.numberOfLoops = -1;
    self.playa.volume = 0.0;
    [self.playa play];
    [pool drain];
}

- (void)stopPlayback {
    if ([Insomniac supportsMultitasking]) return;

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if (self.playa) {
        [self.playa stop];
    }
    [pool drain];
}

+ (BOOL)supportsMultitasking {
    if (![[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)] || ![UIDevice currentDevice].multitaskingSupported) return NO;
    else return YES;
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    // Called when an audio player is interrupted, such as by an incoming phone call.
    // Upon interruption, your application’s audio session is deactivated and the audio player pauses. You cannot use the audio player again until you receive a notification that the interruption has ended.
    [player stop];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player {
    // Called when an interruption ends, such as by a user ignoring an incoming phone call.
    // When an interruption ends, the audio session for your application is automatically reactivated, allowing you to interact with the audio player. To resume playback, call the play method.
    // Mixing properties do not persist across interruptions, so we must reenable them
    if (![self enableMixing]) self.mustDisableIdleTimer = YES;
    [self startDatacollection];
}

- (void) sendErroredData:(id) sender {
    [NSThread detachNewThreadSelector:@selector(sendWaitingData:) toTarget:self withObject:nil];
}

- (void) sendWaitingData:(id) withObject {
    NSAutoreleasePool *threadpool = [[NSAutoreleasePool alloc] init];
    if (!((cctrackerAppDelegate*)[[UIApplication sharedApplication] delegate]).hasLocalData) {
        [threadpool release];
        return;
    }
    NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/%@",WaitingDataFilename];
    BOOL success = NO;
        //NSLog(@"sending waiting data...");
    @synchronized([[UIApplication sharedApplication] delegate]) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSString *data = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
        NSMutableArray *failedlines = [NSMutableArray array];
            if (![MMRemoteDataRecorder makeURLRequest:data])
                [failedlines addObject:data];
        if ([failedlines count] != 0) [[[failedlines componentsJoinedByString:@"\n"] stringByAppendingString:@"\n"] writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        else success = [@"" writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        [pool release];
    }
    if (success) ((cctrackerAppDelegate*)[[UIApplication sharedApplication] delegate]).hasLocalData = NO;
    [[DataCollector sharedDataCollector].recorder reinitializeFallbackHandle];
    [threadpool drain];
}

@end
