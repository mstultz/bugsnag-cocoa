//
//  EnabledErrorTypesScenario.m
//  iOSTestApp
//
//  Created by Robin Macharg on 27/02/2020.
//  Copyright © 2020 Bugsnag. All rights reserved.
//
// Test that enabling/disabling certain classes of crashes works as expected.
// C++ crashes are handled in a separate scenario, and OOM is not tested for.

#import "EnabledErrorTypesScenario.h"

// MARK: -

/**
 * Disable all crash reporting (except, implicitly, manual) and crash the app
 * (no report should be sent)
 */
@implementation DisableAllExceptManualExceptionsAndCrashScenario

- (void)startBugsnag {
    self.config.enabledErrorTypes = BSGErrorTypesNone;
    self.config.autoTrackSessions = YES;
    [super startBugsnag];
}

- (void)run {
    // From null prt scenario
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        volatile char *ptr = NULL;
        (void) *ptr;
    });
}

@end

// MARK: -


/**
 * Disable all crash reporting (except, implicitly, manual), send a manual report 
 * and crash the app (one session request with 2 sessions and 1 report should be sent)
 */
@implementation DisableAllExceptManualExceptionsSendManualAndCrashScenario

- (void)startBugsnag {
    self.config.enabledErrorTypes = BSGErrorTypesNone;
    self.config.autoTrackSessions = NO;
    [super startBugsnag];
}

- (void)run {
    // Manual crash
    [Bugsnag notifyError:[NSError errorWithDomain:@"com.bugsnag" code:833 userInfo:nil]];

    // From null prt scenario
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        volatile char *ptr = NULL;
        (void) *ptr;
    });
}

@end

// MARK: -

@implementation DisableNSExceptionScenario

- (void)startBugsnag {
    self.config.enabledErrorTypes = BSGErrorTypesNone
                                  | BSGErrorTypesMach
                               /* | BSGErrorTypesNSExceptions */
                                  | BSGErrorTypesSignals
                                  | BSGErrorTypesCPP
                                  | BSGErrorTypesOOMs;
    self.config.autoTrackSessions = NO;
    [super startBugsnag];
}

// Suppress the warning.  The async confuses the compiler.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-noreturn"
- (void)run  __attribute__((noreturn)) {
    // From ObjCExceptionScenario.  Wait 2 seconds before throwing.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @throw [NSException exceptionWithName:NSGenericException reason:@"An uncaught exception! SCREAM."
                                    userInfo:@{NSLocalizedDescriptionKey: @"I'm in your program, catching your exceptions!"}];
    });
}
#pragma clang diagnostic pop

@end

// MARK: -

@implementation DisableMachExceptionScenario

- (void)startBugsnag {
    self.config.enabledErrorTypes = BSGErrorTypesNone
                               /* | BSGErrorTypesMach */
                                  | BSGErrorTypesNSExceptions
                                  | BSGErrorTypesSignals
                                  | BSGErrorTypesCPP
                                  | BSGErrorTypesOOMs;
    self.config.autoTrackSessions = NO;
    [super startBugsnag];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-noreturn"
- (void)run  __attribute__((noreturn)) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        strcmp(0, ""); // Generate EXC_BAD_ACCESS (see e.g. https://stackoverflow.com/q/22488358/2431627)
    });
}
#pragma clang diagnostic pop

@end

// MARK: -

@implementation DisableSignalsExceptionScenario

- (void)startBugsnag {
    self.config.enabledErrorTypes = BSGErrorTypesNone
                                  | BSGErrorTypesMach
                                  | BSGErrorTypesNSExceptions
                               /* | BSGErrorTypesSignals */
                                  | BSGErrorTypesCPP
                               // OOMs are disabled since they raise a false positive 
                               /* | BSGErrorTypesOOMs */ ;
    self.config.autoTrackSessions = NO;
    [super startBugsnag];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-noreturn"
- (void)run  __attribute__((noreturn)) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        raise(SIGINT);
    });
}
#pragma  clang pop

@end