%hook GTMOAuth2SignInInternal

// Log when setAccountsHost: is called
+ (void)setAccountsHost:(NSString *)host {
    %log(@"[GTMOAuth2SignInInternal] setAccountsHost: called with host: %@", host);
    %orig(host);
}

// Log when accountsHost is accessed
+ (NSString *)accountsHost {
    NSString *host = %orig;
    %log(@"[GTMOAuth2SignInInternal] accountsHost accessed: %@", host);
    return host;
}

// Log when setAuthorizationHost: is called
+ (void)setAuthorizationHost:(NSString *)host {
    %log(@"[GTMOAuth2SignInInternal] setAuthorizationHost: called with host: %@", host);
    %orig(host);
}

// Log when authorizationHost is accessed
+ (NSString *)authorizationHost {
    NSString *host = %orig;
    %log(@"[GTMOAuth2SignInInternal] authorizationHost accessed: %@", host);
    return host;
}

// Log when setUserInfoHost: is called
+ (void)setUserInfoHost:(NSString *)host {
    %log(@"[GTMOAuth2SignInInternal] setUserInfoHost: called with host: %@", host);
    %orig(host);
}

// Log when userInfoHost is accessed
+ (NSString *)userInfoHost {
    NSString *host = %orig;
    %log(@"[GTMOAuth2SignInInternal] userInfoHost accessed: %@", host);
    return host;
}

// Log when googleAuthorizationURL is accessed
+ (NSURL *)googleAuthorizationURL {
    NSURL *url = %orig;
    %log(@"[GTMOAuth2SignInInternal] googleAuthorizationURL accessed: %@", url);
    return url;
}

// Log when googleTokenURL is accessed
+ (NSURL *)googleTokenURL {
    NSURL *url = %orig;
    %log(@"[GTMOAuth2SignInInternal] googleTokenURL accessed: %@", url);
    return url;
}

// Log when googleRevocationURL is accessed
+ (NSURL *)googleRevocationURL {
    NSURL *url = %orig;
    %log(@"[GTMOAuth2SignInInternal] googleRevocationURL accessed: %@", url);
    return url;
}

// Log when googleUserInfoURL is accessed
+ (NSURL *)googleUserInfoURL {
    NSURL *url = %orig;
    %log(@"[GTMOAuth2SignInInternal] googleUserInfoURL accessed: %@", url);
    return url;
}

// Log when dealloc is called
- (void)dealloc {
    %log(@"[GTMOAuth2SignInInternal] dealloc called");
    %orig;
}

// Log when startSigningIn is called
- (void)startSigningIn {
    %log(@"[GTMOAuth2SignInInternal] startSigningIn called");
    %orig;
}

// Log when parametersForWebRequest is called
- (NSDictionary *)parametersForWebRequest {
    NSDictionary *params = %orig;
    %log(@"[GTMOAuth2SignInInternal] parametersForWebRequest called, params: %@", params);
    return params;
}

// Log when titleChanged: is called
- (void)titleChanged:(id)title {
    %log(@"[GTMOAuth2SignInInternal] titleChanged: called with title: %@", title);
    %orig(title);
}

// Log when cookiesChanged: is called
- (void)cookiesChanged:(id)cookies {
    %log(@"[GTMOAuth2SignInInternal] cookiesChanged: called with cookies: %@", cookies);
    %orig(cookies);
}

// Log when fetchClientLoginValuesWithAuth:service:source:doUberAuthFetch:parseBlock:completionHandler: is called
+ (void)fetchClientLoginValuesWithAuth:(id)auth service:(id)service source:(id)source doUberAuthFetch:(BOOL)fetch parseBlock:(id)block completionHandler:(id)handler {
    %log(@"[GTMOAuth2SignInInternal] fetchClientLoginValuesWithAuth:service:source:doUberAuthFetch:parseBlock:completionHandler: called with auth: %@, service: %@, source: %@, doUberAuthFetch: %d", auth, service, source, fetch);
    %orig(auth, service, source, fetch, block, handler);
}

// Log when fetchClientLoginValuesWithAuth:service:source:completionHandler: is called
+ (void)fetchClientLoginValuesWithAuth:(id)auth service:(id)service source:(id)source completionHandler:(id)handler {
    %log(@"[GTMOAuth2SignInInternal] fetchClientLoginValuesWithAuth:service:source:completionHandler: called with auth: %@, service: %@, source: %@", auth, service, source);
    %orig(auth, service, source, handler);
}

// Log when fetchUberAuthTokenWithAuth:service:source:completionHandler: is called
+ (void)fetchUberAuthTokenWithAuth:(id)auth service:(id)service source:(id)source completionHandler:(id)handler {
    %log(@"[GTMOAuth2SignInInternal] fetchUberAuthTokenWithAuth:service:source:completionHandler: called with auth: %@, service: %@, source: %@", auth, service, source);
    %orig(auth, service, source, handler);
}

// Log when fetchAuthTokenWithValues:service:isSessionOnly:completionHandler: is called
+ (void)fetchAuthTokenWithValues:(id)values service:(id)service isSessionOnly:(BOOL)sessionOnly completionHandler:(id)handler {
    %log(@"[GTMOAuth2SignInInternal] fetchAuthTokenWithValues:service:isSessionOnly:completionHandler: called with values: %@, service: %@, isSessionOnly: %d", values, service, sessionOnly);
    %orig(values, service, sessionOnly, handler);
}

// Log when fetchTokenAuthURLWithAuth:service:source:URLString:completionHandler: is called
+ (void)fetchTokenAuthURLWithAuth:(id)auth service:(id)service source:(id)source URLString:(NSString *)urlString completionHandler:(id)handler {
    %log(@"[GTMOAuth2SignInInternal] fetchTokenAuthURLWithAuth:service:source:URLString:completionHandler: called with auth: %@, service: %@, source: %@, URLString: %@", auth, service, source, urlString);
    %orig(auth, service, source, urlString, handler);
}

// Log when fetchTokenAuthURLWithValues:service:source:URLString:completionHandler: is called
+ (void)fetchTokenAuthURLWithValues:(id)values service:(id)service source:(id)source URLString:(NSString *)urlString completionHandler:(id)handler {
    %log(@"[GTMOAuth2SignInInternal] fetchTokenAuthURLWithValues:service:source:URLString:completionHandler: called with values: %@, service: %@, source: %@, URLString: %@", values, service, source, urlString);
    %orig(values, service, source, urlString, handler);
}

// Log when dictionaryWithClientLoginResponseString: is called
+ (NSDictionary *)dictionaryWithClientLoginResponseString:(NSString *)responseString {
    NSDictionary *dict = %orig(responseString);
    %log(@"[GTMOAuth2SignInInternal] dictionaryWithClientLoginResponseString: called with responseString: %@, resulting dictionary: %@", responseString, dict);
    return dict;
}

// Log when tokenAuthURLWithAuthToken:service:source:URLString: is called
+ (NSURL *)tokenAuthURLWithAuthToken:(NSString *)authToken service:(id)service source:(id)source URLString:(NSString *)urlString {
    NSURL *url = %orig(authToken, service, source, urlString);
    %log(@"[GTMOAuth2SignInInternal] tokenAuthURLWithAuthToken:service:source:URLString: called with authToken: %@, service: %@, source: %@, URLString: %@, resulting URL: %@", authToken, service, source, urlString, url);
    return url;
}

// Log when defaultSourceString is accessed
+ (NSString *)defaultSourceString {
    NSString *source = %orig;
    %log(@"[GTMOAuth2SignInInternal] defaultSourceString accessed: %@", source);
    return source;
}

// Log when authorizationEmail is accessed
- (NSString *)authorizationEmail {
    NSString *email = @"mauro.calderon.fernandez@gmail.com";
    %log(@"[GTMOAuth2SignInInternal] authorizationEmail accessed: %@", email);
    return email;
}

// Log when setAuthorizationEmail: is called
- (void)setAuthorizationEmail:(NSString *)email {
    %log(@"[GTMOAuth2SignInInternal] setAuthorizationEmail: called with email: %@", email);
    %orig(email);
}

// Log when authorizationTemplate is accessed
- (NSString *)authorizationTemplate {
    NSString *template = %orig;
    %log(@"[GTMOAuth2SignInInternal] authorizationTemplate accessed: %@", template);
    return template;
}

// Log when setAuthorizationTemplate: is called
- (void)setAuthorizationTemplate:(NSString *)template {
    %log(@"[GTMOAuth2SignInInternal] setAuthorizationTemplate: called with template: %@", template);
    %orig(template);
}

// Log when shouldUseLoginScope is accessed
- (BOOL)shouldUseLoginScope {
    BOOL useLoginScope = %orig;
    %log(@"[GTMOAuth2SignInInternal] shouldUseLoginScope accessed: %d", useLoginScope);
    return useLoginScope;
}

// Log when setShouldUseLoginScope: is called
- (void)setShouldUseLoginScope:(BOOL)useLoginScope {
    %log(@"[GTMOAuth2SignInInternal] setShouldUseLoginScope: called with useLoginScope: %d", useLoginScope);
    %orig(useLoginScope);
}

%end
