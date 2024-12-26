#import "TubeRepair.h"

NSString *globalClientID = @"Hello";
NSString *globalClientSecret = @"Hello";

// Add custom headers to requests, this is used to add the auth token to allow for custom feeds and such.
void addCustomHeaderToRequest(NSMutableURLRequest *request) {
    NSString *settingsPath = @"/var/mobile/Library/Preferences/bag.xml.tuberepairpreference.plist";
    NSMutableDictionary *prefs = [[[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath] autorelease];
    NSString *headerName = [prefs objectForKey:@"apiKeyRHeader"];
    NSString *apiKey = [prefs objectForKey:@"apiKey"];
    NSString *oAuthToken = [prefs objectForKey:@"OAuthAccessToken"];
    
    if (headerName && [headerName length] > 0 && apiKey && [apiKey length] > 0) {
        [request setValue:apiKey forHTTPHeaderField:headerName];
    }
    
    if (oAuthToken && [oAuthToken length] > 0) {
        [request setValue:oAuthToken forHTTPHeaderField:@"OAuth-Token"];
    }
}

// Extract Client ID and Secret from script content using string search
void extractClientIDAndSecretFromScript(NSString *scriptContent, void(^completion)(BOOL success, NSString *clientID, NSString *clientSecret)) {
    NSString *clientId = nil;
    NSString *clientSecret = nil;
    
    // Find client_id
    NSRange clientIdRange = [scriptContent rangeOfString:@"client_id:\""];
    if (clientIdRange.location != NSNotFound) {
        NSRange startRange = NSMakeRange(clientIdRange.location + clientIdRange.length, scriptContent.length - (clientIdRange.location + clientIdRange.length));
        NSRange endRange = [scriptContent rangeOfString:@"\"" options:0 range:startRange];
        if (endRange.location != NSNotFound) {
            clientId = [[scriptContent substringWithRange:NSMakeRange(startRange.location, endRange.location - startRange.location)] retain];
        }
    }

    // Find client_secret
    NSRange clientSecretRange = [scriptContent rangeOfString:@"client_secret:\""];
    if (clientSecretRange.location != NSNotFound) {
        NSRange startRange = NSMakeRange(clientSecretRange.location + clientSecretRange.length, scriptContent.length - (clientSecretRange.location + clientSecretRange.length));
        NSRange endRange = [scriptContent rangeOfString:@"\"" options:0 range:startRange];
        if (endRange.location != NSNotFound) {
            clientSecret = [[scriptContent substringWithRange:NSMakeRange(startRange.location, endRange.location - startRange.location)] retain];
        }
    }

    // If both client ID and client secret are found, return them
    if (clientId && clientSecret) {
        globalClientID = clientId;
        globalClientSecret = clientSecret;
        completion(YES, clientId, clientSecret);
    } else {
        completion(NO, nil, nil);
    }
}

// Fetch YouTube TV page and extract the Client ID and Secret using synchronous request
void fetchYouTubeTVPageAndExtractClientID(void(^completion)(BOOL success, NSString *clientID, NSString *clientSecret)) {
    NSURL *url = [NSURL URLWithString:@"https://www.youtube.com/tv"];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setValue:@"https://www.youtube.com" forHTTPHeaderField:@"Origin"];
    [request setValue:@"SMART-TV; Tizen 4.0" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"https://www.youtube.com/tv" forHTTPHeaderField:@"Referer"];
    [request setValue:@"en-US" forHTTPHeaderField:@"Accept-Language"];
    
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) {
        NSLog(@"Error fetching YouTube TV page: %@", [error localizedDescription]);
        completion(NO, nil, nil);
        return;
    }
    
    NSString *htmlContent = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    // Instead of using regex, we'll manually search for the script URL
    NSRange scriptRange = [htmlContent rangeOfString:@"<script id=\"base-js\" src=\""];
    if (scriptRange.location != NSNotFound) {
        NSRange startRange = NSMakeRange(scriptRange.location + scriptRange.length, htmlContent.length - (scriptRange.location + scriptRange.length));
        NSRange endRange = [htmlContent rangeOfString:@"\"" options:0 range:startRange];
        if (endRange.location != NSNotFound) {
            NSString *relativeScriptUrl = [htmlContent substringWithRange:NSMakeRange(startRange.location, endRange.location - startRange.location)];
            NSURL *fullScriptUrl = [NSURL URLWithString:relativeScriptUrl relativeToURL:[NSURL URLWithString:@"https://www.youtube.com"]];
            
            NSMutableURLRequest *scriptRequest = [[[NSMutableURLRequest alloc] initWithURL:fullScriptUrl] autorelease];
            [scriptRequest setValue:@"Mozilla/5.0 (ChromiumStylePlatform) Cobalt/Version" forHTTPHeaderField:@"User-Agent"];
            [scriptRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [scriptRequest setValue:@"*/*" forHTTPHeaderField:@"Accept"];
            [scriptRequest setValue:@"https://www.youtube.com" forHTTPHeaderField:@"Origin"];
            [scriptRequest setValue:@"https://www.youtube.com/tv" forHTTPHeaderField:@"Referer"];
            [scriptRequest setValue:@"en-US" forHTTPHeaderField:@"Accept-Language"];
            
            NSData *scriptData = [NSURLConnection sendSynchronousRequest:scriptRequest returningResponse:&response error:&error];
            
            if (error) {
                NSLog(@"Error fetching script: %@", [error localizedDescription]);
                completion(NO, nil, nil);
                return;
            }
            
            NSString *scriptContent = [[[NSString alloc] initWithData:scriptData encoding:NSUTF8StringEncoding] autorelease];
            extractClientIDAndSecretFromScript(scriptContent, completion);
        }
    } else {
        NSLog(@"Failed to find script URL in YouTube TV page.");
        completion(NO, nil, nil);
    }
}

// Use NSPropertyListSerialization to mimic JSON parsing for older iOS versions
NSDictionary *parseJSONFromData(NSData *data, NSError **error) {
    NSString *dataString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSData *plistData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *errorDescription = nil;
    return [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable format:nil errorDescription:&errorDescription];
}

// Refresh OAuth token if needed
void refreshOAuthTokenIfNeeded(void) {
    NSString *settingsPath = @"/var/mobile/Library/Preferences/bag.xml.tuberepairpreference.plist";
    NSMutableDictionary *prefs = [[[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath] autorelease];
    NSString *accessToken = [prefs objectForKey:@"OAuthAccessToken"];
    NSDate *tokenExpirationDate = [prefs objectForKey:@"OAuthTokenExpirationDate"];
    NSString *refreshToken = [prefs objectForKey:@"OAuthRefreshToken"];
    
    // Check if token needs to be refreshed
    if (accessToken && refreshToken && (!tokenExpirationDate || [tokenExpirationDate compare:[NSDate date]] != NSOrderedDescending)) {
        NSString *tokenRequestBodyString = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&refresh_token=%@&grant_type=refresh_token", globalClientID, globalClientSecret, refreshToken];
        NSData *tokenRequestBodyData = [tokenRequestBodyString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableURLRequest *tokenRequest = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://oauth2.googleapis.com/token"]] autorelease];
        [tokenRequest setHTTPMethod:@"POST"];
        [tokenRequest setHTTPBody:tokenRequestBodyData];
        [tokenRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        NSURLResponse *response;
        NSError *error;
        NSData *tokenResponseData = [NSURLConnection sendSynchronousRequest:tokenRequest returningResponse:&response error:&error];
        
        if (!error && tokenResponseData) {
            NSDictionary *tokenResponse = parseJSONFromData(tokenResponseData, &error);
            if (!error && tokenResponse) {
                NSString *newAccessToken = [tokenResponse objectForKey:@"access_token"];
                NSNumber *expiresIn = [tokenResponse objectForKey:@"expires_in"];
                NSString *newRefreshToken = [tokenResponse objectForKey:@"refresh_token"]; // Some servers might return a new refresh token
                
                if (newAccessToken && expiresIn) {
                    // Manually calculate the new expiration date
                    NSDate *currentDate = [NSDate date];
                    NSDate *newExpirationDate = [currentDate addTimeInterval:[expiresIn doubleValue]];
                    [prefs setObject:newAccessToken forKey:@"OAuthAccessToken"];
                    [prefs setObject:newExpirationDate forKey:@"OAuthTokenExpirationDate"];
                    
                    // Only update the refresh token if a new one is provided
                    if (newRefreshToken) {
                        [prefs setObject:newRefreshToken forKey:@"OAuthRefreshToken"];
                        NSLog(@"Updated refresh token: %@", newRefreshToken);
                    } else {
                        NSLog(@"No new refresh token provided, retaining the existing one.");
                    }
                    
                    [prefs writeToFile:settingsPath atomically:YES];
                    NSLog(@"Successfully refreshed access token.");
                } else {
                    NSLog(@"Failed to parse access token or expiration time from response.");
                }
            } else {
                NSLog(@"Failed to refresh token: %@", [error localizedDescription]);
            }
        } else {
            NSLog(@"Error making refresh token request: %@", [error localizedDescription]);
        }
    } else {
        NSLog(@"No need to refresh the token yet.");
    }
}

// Manually add time interval to current date (iOS 3 compatibility)
NSDate *addTimeInterval(NSDate *date, NSTimeInterval interval) {
    NSTimeInterval currentTimeInterval = [date timeIntervalSince1970];
    return [NSDate dateWithTimeIntervalSince1970:(currentTimeInterval + interval)];
}
