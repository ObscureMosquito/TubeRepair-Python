#import "TubeRepair.h"


/*%hook NSMutableURLRequest

+ (instancetype)requestWithURL:(NSURL *)URL {
    NSMutableURLRequest *request = %orig(URL);
    addCustomHeaderToRequest(request);
    return request;
}

+ (instancetype)requestWithURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval {
    NSMutableURLRequest *request = %orig(URL, cachePolicy, timeoutInterval);
    addCustomHeaderToRequest(request);
    return request;
}

%end*/

/*%hook YTSignInPopoverController_iPhone

- (void)presentInPopoverFromRect:(CGRect)a3 inView:(id)a4 permittedArrowDirections:(unsigned int)a5 resourceLoader:(id)a6 {
    // Step 1: Request Device Code
    NSURL *deviceCodeRequestURL = [NSURL URLWithString:@"https://oauth2.googleapis.com/device/code"];
    
    // Use __bridge_transfer for ARC
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    CFRelease(uuidRef);
    
    NSDictionary *requestParams = @{
        @"client_id": globalClientID,
        @"client_secret": globalClientSecret,
        @"scope": @"http://gdata.youtube.com https://www.googleapis.com/auth/youtube-paid-content",
        @"device_id": uuidString,
        @"device_model": @"ytlr::",
        @"grant_type": @"urn:ietf:params:oauth:grant-type:device_code"
    };

    __autoreleasing NSError *error = nil;
    NSData *deviceCodeRequestBodyData = [NSPropertyListSerialization dataFromPropertyList:requestParams format:NSPropertyListXMLFormat_v1_0 errorDescription:NULL];
    NSMutableURLRequest *deviceCodeRequest = [[NSMutableURLRequest alloc] initWithURL:deviceCodeRequestURL];
    [deviceCodeRequest setHTTPMethod:@"POST"];
    [deviceCodeRequest setHTTPBody:deviceCodeRequestBodyData];
    [deviceCodeRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    __autoreleasing NSError *deviceCodeError = error;
    NSData *deviceCodeResponseData = [NSURLConnection sendSynchronousRequest:deviceCodeRequest returningResponse:NULL error:&deviceCodeError];

    __block NSString *deviceCode = nil;
    
    if (!deviceCodeError && deviceCodeResponseData) {
        NSDictionary *deviceCodeResponseDict = [NSPropertyListSerialization propertyListFromData:deviceCodeResponseData mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
        if (deviceCodeResponseDict) {
            deviceCode = [deviceCodeResponseDict objectForKey:@"device_code"];
            NSString *userCode = [deviceCodeResponseDict objectForKey:@"user_code"];
            NSString *verificationURL = [deviceCodeResponseDict objectForKey:@"verification_url"];

            // Replace subscripting with objectForKey for iOS 3 compatibility
            [self performSelectorOnMainThread:@selector(showDeviceCodeAlert:) withObject:@{@"verificationURL": verificationURL, @"userCode": userCode} waitUntilDone:NO];

            [self performSelectorInBackground:@selector(pollForToken:) withObject:deviceCode];
        }
    }
}

- (void)showDeviceCodeAlert:(NSDictionary *)params {
    // Replace subscripting with objectForKey for iOS 3 compatibility
    NSString *verificationURL = [params objectForKey:@"verificationURL"];
    NSString *userCode = [params objectForKey:@"userCode"];
    
    NSString *message = [NSString stringWithFormat:@"Please visit %@ and enter the code: %@, this is required in order to sign into TubeRepair securely.", verificationURL, userCode];
    UIAlertView *deviceCodeAlert = [[UIAlertView alloc] initWithTitle:@"Sign In Required" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [deviceCodeAlert show];
    
    [self performSelector:@selector(dismissDeviceCodeAlert:) withObject:deviceCodeAlert afterDelay:60.0];
}

- (void)dismissDeviceCodeAlert:(UIAlertView *)alert {
    if (alert.visible) {
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    }
}

- (void)pollForToken:(NSString *)deviceCode {
    BOOL shouldContinuePolling = YES;
    NSDate *pollingEndTime = [NSDate dateWithTimeIntervalSinceNow:60];
    
    while (shouldContinuePolling && [[NSDate date] compare:pollingEndTime] == NSOrderedAscending) {
        [NSThread sleepForTimeInterval:5];
        
        NSString *tokenRequestBodyString = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&device_code=%@&grant_type=urn:ietf:params:oauth:grant-type:device_code", globalClientID, globalClientSecret, deviceCode];
        NSData *tokenRequestBodyData = [tokenRequestBodyString dataUsingEncoding:NSUTF8StringEncoding];

        NSMutableURLRequest *tokenRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://oauth2.googleapis.com/token"]];
        [tokenRequest setHTTPMethod:@"POST"];
        [tokenRequest setHTTPBody:tokenRequestBodyData];
        [tokenRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        __autoreleasing NSError *tokenError = nil;
        NSData *tokenResponseData = [NSURLConnection sendSynchronousRequest:tokenRequest returningResponse:NULL error:&tokenError];
        
        if (!tokenError && tokenResponseData) {
            NSDictionary *tokenResponse = [NSPropertyListSerialization propertyListFromData:tokenResponseData mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
            NSString *accessToken = [tokenResponse objectForKey:@"access_token"];
            NSNumber *expiresIn = [tokenResponse objectForKey:@"expires_in"];
            
            if (accessToken && expiresIn) {
                NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:[expiresIn doubleValue]];
                NSString *settingsPath = @"/var/mobile/Library/Preferences/bag.xml.tuberepairpreference.plist";
                NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
                [prefs setObject:accessToken forKey:@"OAuthAccessToken"];
                [prefs setObject:expirationDate forKey:@"OAuthTokenExpirationDate"];
                [prefs writeToFile:settingsPath atomically:YES];
                
                [self performSelectorOnMainThread:@selector(showSuccessAlert) withObject:nil waitUntilDone:NO];
                shouldContinuePolling = NO;
            } else if ([[tokenResponse objectForKey:@"error"] isEqualToString:@"authorization_pending"]) {
                continue;
            } else {
                shouldContinuePolling = NO;
            }
        } else {
            shouldContinuePolling = NO;
        }
    }
}

- (void)showSuccessAlert {
    UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Authentication Successful" message:@"You have been successfully authenticated." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [successAlert show];
}

%end
*/
/*%hook YTNavigation_iPad

- (void)showSignInFromRect:(CGRect)rect inView:(id)view auth:(id)auth authedBlock:(id)authedBlock failedBlock:(id)failedBlock canceledBlock:(id)canceledBlock {
    // Step 1: Request Device Code
    NSURL *deviceCodeRequestURL = [NSURL URLWithString:@"https://oauth2.googleapis.com/device/code"];
    
    // Use __bridge_transfer for ARC
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    CFRelease(uuidRef);
    
    NSDictionary *requestParams = @{
        @"client_id": globalClientID,
        @"client_secret": globalClientSecret,
        @"scope": @"http://gdata.youtube.com https://www.googleapis.com/auth/youtube-paid-content",
        @"device_id": uuidString,
        @"device_model": @"ytlr::",
        @"grant_type": @"urn:ietf:params:oauth:grant-type:device_code"
    };

    __autoreleasing NSError *error = nil;
    NSData *deviceCodeRequestBodyData = [NSPropertyListSerialization dataFromPropertyList:requestParams format:NSPropertyListXMLFormat_v1_0 errorDescription:NULL];
    NSMutableURLRequest *deviceCodeRequest = [[NSMutableURLRequest alloc] initWithURL:deviceCodeRequestURL];
    [deviceCodeRequest setHTTPMethod:@"POST"];
    [deviceCodeRequest setHTTPBody:deviceCodeRequestBodyData];
    [deviceCodeRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    __autoreleasing NSError *deviceCodeError = error;
    NSData *deviceCodeResponseData = [NSURLConnection sendSynchronousRequest:deviceCodeRequest returningResponse:NULL error:&deviceCodeError];

    __block NSString *deviceCode = nil;
    
    if (!deviceCodeError && deviceCodeResponseData) {
        NSDictionary *deviceCodeResponseDict = [NSPropertyListSerialization propertyListFromData:deviceCodeResponseData mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
        if (deviceCodeResponseDict) {
            deviceCode = [deviceCodeResponseDict objectForKey:@"device_code"];
            NSString *userCode = [deviceCodeResponseDict objectForKey:@"user_code"];
            NSString *verificationURL = [deviceCodeResponseDict objectForKey:@"verification_url"];

            // Replace subscripting with objectForKey for iOS 3 compatibility
            [self performSelectorOnMainThread:@selector(showDeviceCodeAlert:) withObject:@{@"verificationURL": verificationURL, @"userCode": userCode} waitUntilDone:NO];

            [self performSelectorInBackground:@selector(pollForToken:) withObject:deviceCode];
        }
    }
}

%end*/