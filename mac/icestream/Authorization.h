//
//  Authorization.h
//  icestream
//
//  Created by Dev Chakraborty on 2015-09-19.
//  Copyright © 2015 IceStream. All rights reserved.
//

#import <Foundation/Foundation.h>

OSStatus PreauthorizePrivilegedProcess(AuthorizationRef *authRef);
OSStatus LaunchPreauthorizedProcess(AuthorizationRef *authRef, NSString *path);
