//
//  Authorization.m
//  icestream
//
//  Created by Dev Chakraborty on 2015-09-19.
//  Copyright © 2015 IceStream. All rights reserved.
//

#import "Authorization.h"

#import <Security/Security.h>

OSStatus PreauthorizePrivilegedProcess(AuthorizationRef *authRef) {
    AuthorizationItem item = { kAuthorizationRightExecute, 0, NULL, 0 };
    AuthorizationRights rights = { 1, &item };
    AuthorizationFlags flags = kAuthorizationFlagInteractionAllowed | kAuthorizationFlagExtendRights | kAuthorizationFlagPreAuthorize;
    return AuthorizationCreate(&rights, kAuthorizationEmptyEnvironment, flags, authRef);
}

OSStatus LaunchPreauthorizedProcess(AuthorizationRef *authRef, NSString *path) {
    OSStatus status = AuthorizationExecuteWithPrivileges(*authRef, [path UTF8String], kAuthorizationFlagDefaults, NULL, NULL);
    AuthorizationFree(*authRef, kAuthorizationFlagDestroyRights);
    return status;
}