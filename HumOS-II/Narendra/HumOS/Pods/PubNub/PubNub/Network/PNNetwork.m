/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNNetwork.h"
#import "NSURLSessionConfiguration+PNConfigurationPrivate.h"
#import "PNNetworkResponseSerializer.h"
#import "PNRequestParameters.h"
#import "PNPrivateStructures.h"
#import "PubNub+CorePrivate.h"
#import "PNResult+Private.h"
#import "PNStatus+Private.h"
#import <libkern/OSAtomic.h>
#import "PNConfiguration.h"
#import "PNErrorStatus.h"
#import "PNErrorParser.h"
#import "PNURLBuilder.h"
#if __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH
    #import <UIKit/UIKit.h>
#endif // __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH
#import "PNConstants.h"
#import "PNLogMacro.h"
#import "PNHelpers.h"


#pragma mark Types

/**
 @brief  Definition for block which is used as NSURLSessionDataTask completion handler (passed during task 
         creation.
 
 @param data     Actual raw data which has been received from \b PubNub service in response.
 @param response HTTP response instance which hold metadata about response.
 @param error    Reference on error instance in case of any processing issues.
 
 @since 4.0.2
 */
typedef void(^NSURLSessionDataTaskCompletion)(NSData * _Nullable data, NSURLResponse * _Nullable response, 
                                              NSError * _Nullable error);

/**
 @brief  Definition for block which is used by \b PubNub SDK to process successfully completed request with
         pre-processed response.
 
 @param task           Reference on data load task which has been used to communicate with \b PubNub network.
 @param responseObject Serialized \b PubNub service response.
 
 @since 4.0.2
 */
typedef void(^NSURLSessionDataTaskSuccess)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject);

/**
 @brief  Definition for block which is used by \b PubNub SDK to process failed request.
 
 @param task  Reference on data load task which has been used to communicate with \b PubNub network.
 @param error Reference on error instance in case of any processing issues.
 
 @since 4.0.2
 */
typedef void(^NSURLSessionDataTaskFailure)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error);


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

@interface PNNetwork () <NSURLSessionDelegate>


#pragma mark - Information

/**
 @brief  Stores reference on client for which this network manager provide functionality.
 
 @since 4.0
 */
@property (nonatomic, weak) PubNub *client;

/**
 @brief  Stores reference on \b PubNub client configuration which define network manager behavior as well.
 
 @since 4.0
 */
@property (nonatomic, strong) PNConfiguration *configuration;

/**
 @brief  Stores reference on unique \b PubNub network manager instance identifier.
 
 @since 4.4.1
 */
@property (nonatomic, copy) NSString *identifier;

/**
 @brief      Stores whether \b PubNub network manager configured for long-poll request processing or not.
 @discussion This property taken into account when manager need to invalidate underlying \a NSURLSession and 
             dictate whether all scheduled requests should be completed or terminated.
 
 @since 4.0
 */
@property (nonatomic, assign) BOOL forLongPollRequests;

/**
 @brief      Stores value which should be as timeout interval for request.
 @discussion This property also used when session instance should be re-created.
 
 @since 4.0.2
 */
@property (nonatomic, assign) NSTimeInterval requestTimeout;

/**
 @brief      Stores value which should be as maximum simultaneous requests.
 @discussion This property also used when session instance should be re-created.
 
 @since 4.0.2
 */
@property (nonatomic, assign) NSInteger maximumConnections;


/**
 @brief  Stores reference on session instance which is used to send network requests.
 
 @since 4.0.2
 */
@property (nonatomic, strong) NSURLSession *session;

/**
 @brief  Stores reference on base URL which should be appeanded with reasource path to perform network
         request.
 
 @since 4.0.2
 */
@property (nonatomic, strong) NSURL *baseURL;

/**
 @brief  Stores reference on serializer used to pre-process service responses.
 
 @since 4.0.2
 */
@property (nonatomic, strong) PNNetworkResponseSerializer *serializer;

#if __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH

/**
 @brief      Stores reference on list of currently scheduled data tasks.
 @discussion List allow to get information about active data task synchronously at any moment 
             (when \c NSURLSession allow to get this information only from block which will be scheduled on
             processing queue).
 
 @since 4.5.0
 */
@property (nonatomic, strong) NSMutableArray<NSURLSessionDataTask *> *scheduledDataTasks;

/**
 @brief  Stores reference on identifier which has been used to request from system more time to complete
         pending tasks when client resign active.
 
 @since 4.5.0
 */
@property (nonatomic, assign) UIBackgroundTaskIdentifier tasksCompletionIdentifier;

#endif // __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH

/**
 @brief  Stores reference on queue which should be used by session to call callbacks and completion blocks on
         \c PNNetwork instance.
 
 @since 4.0.2
 */
@property (nonatomic, strong) NSOperationQueue *delegateQueue;

/**
 @brief      Stores reference on queue which is used to call \b PNNetwork response processing on another 
             queue.
 @discussion Response processing involves data parsing which is most time consuming operation. Dispatching 
             response processing on side queue allow to keep requests sending unaffected by processing delays.
 
 @since 4.0.2
 */
@property (nonatomic, strong) dispatch_queue_t processingQueue;

/**
 @brief  Stores reference on spin-lock which is used to protect access to session instance which can be 
         changed at any moment (invalidated instances can't be used and SDK should instantiate new instance).
 
 @since 4.0.2
 */
@property (nonatomic, assign) OSSpinLock lock;


#pragma mark - Initialization and Configuration

/**
 @brief  Initialize \b PubNub network manager with predefined options.
 
 @param client             Reference on client for which this network manager is creating.
 @param timeout            Maximum time which manager should wait for response on request.
 @param maximumConnections Maximum simultaneously connections (requests) which can be opened.
 @param longPollEnabled    Whether \b PubNub network manager should be configured for long-poll requests or 
                           not. This option affect the way how network manager handle reset.
 
 @return 4.0
 
 @since Initialized and ready to use \b PubNub network manager.
 */
- (instancetype)initForClient:(PubNub *)client requestTimeout:(NSTimeInterval)timeout
           maximumConnections:(NSInteger)maximumConnections longPoll:(BOOL)longPollEnabled;


#pragma mark - Request helper

/**
 @brief  Append additional parameters general for all requests.
 
 @param parameters Reference on request parameters instance which should be updated with required set of 
                   parameters.
 
 @since 4.0
 */
- (void)appendRequiredParametersTo:(PNRequestParameters *)parameters;

/**
 @brief  Construct URL request suitable to send POST request (if required).
 
 @param requestURL Reference on complete remote resource URL which should be used for request.
 @param postData   Reference on data which should be sent as POST body (if passed).
 
 @return Constructed and ready to use request object.
 
 @since 4.0
 */
- (NSURLRequest *)requestWithURL:(NSURL *)requestURL data:(NSData *)postData;

/**
 @brief  Construct data task which should be used to process provided request.
 
 @param request Reference on request which should be issued with data task to NSURL session.
 @param success Reference on data task success handling block which will be called by network manager.
 @param failure Reference on data task processing failure handling block which will be called by network 
                manager.
 
 @return Constructed and ready to use data task.
 
 @since 4.0
 */
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                      success:(NSURLSessionDataTaskSuccess)success
                                      failure:(NSURLSessionDataTaskFailure)failure;


#pragma mark - Request processing

/**
 @brief  Check whether specified operation is expecting result object or not.
 
 @param operation Operation type against which check should be performed.
 
 @return \c YES in case if this type of operation is expecting to receive in result object.
 
 @since 4.0
 */
- (BOOL)operationExpectResult:(PNOperationType)operation;

/**
 @brief  Retrieve reference on parser class which can be used to process received data for \c operation
 
 @param operation Operation type for which suitable parser should be found.
 
 @return Parser class which conforms to \b PNParser protocol.
 
 @since 4.0
 */
- (nullable Class <PNParser>)parserForOperation:(PNOperationType)operation;

/**
 @brief  Retrieve reference on class which can be used to represent request processing results.
 
 @param operation Type of operation which is expecting response from \b PubNub network.
 
 @return Target class which should be used instead of \b PNResult (if non will be found \b PNResult).
 
 @since 4.0
 */
- (Class)resultClassForOperation:(PNOperationType)operation;

/**
 @brief  Retrieve reference on class which can be used to represent request processing status.
 
 @param operation Type of operation which is expecting status from \b PubNub network.
 
 @return Target class which should be used instead of \b PNStatus (if non will be found \b PNStatus).
 
 @since 4.0
 */
- (Class)statusClassForOperation:(PNOperationType)operation;

/**
 @brief  Try process \c data using parser suitable for operation for which data has been received.
 
 @param data       Reference on data which has been received from \b PubNub network in response for operation.
 @param parser     Reference on class which should be used to parse data.
 @param block      Reference on block which should be called back at the end of parsing process.
 
 @since 4.0
 */
- (void)parseData:(nullable id)data withParser:(Class <PNParser>)parser
       completion:(void(^)(NSDictionary * _Nullable parsedData, BOOL parseError))block;

#if __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH

/**
 @brief  Complete processing of tasks which has been scheduled but not completelly processed before \b PubNub 
         client resign active state.
 
 @since 4.5.0
 
 @param dataTasks    List of \c NSURLSession data tasks which didn't completed before \b PubNub client resign
                     active state.
 @param onCompletion Whether list processed after another data task completed or right \b PubNub after client
                     resign active state.
 */
- (void)processIncompleteBeforeClientResignActiveTasks:(NSArray<NSURLSessionDataTask *> *)dataTasks
                                  onDataTaskCompletion:(BOOL)onCompletion;

#endif // __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH


#pragma mark - Session constructor

/**
 @brief  Complete AFNetworking/NSURLSession instantiation and configuration.
 
 @param timeout            Maximum time which manager should wait for response on request.
 @param maximumConnections Maximum simultaneously connections (requests) which can be opened.
 
 @since 4.0
 */
- (void)prepareSessionWithRequesrTimeout:(NSTimeInterval)timeout
                      maximumConnections:(NSInteger)maximumConnections;

/**
 @brief  Construct base NSURL session configuration.
 
 @param timeout            Maximum time which manager should wait for response on request.
 @param maximumConnections Maximum simultaneously connections (requests) which can be opened.
 
 @return Constructed and ready to use session configuration.
 
 @since 4.0
 */
- (NSURLSessionConfiguration *)configurationWithRequestTimeout:(NSTimeInterval)timeout
                                            maximumConnections:(NSInteger)maximumConnections;

/**
 @brief  Construct qaueue on which session will call delegate callbacks and completion blocks.
 
 @param configuration Reference on session configuration instance which should be used to complete queue 
                      configuration.
 
 @return Initialized and ready to use operaiton queue.
 
 @since 4.0.2
 */
- (NSOperationQueue *)operationQueueWithConfiguration:(NSURLSessionConfiguration *)configuration;

/**
 @brief  Construct NSURL session manager used to communicate with \b PubNub network.
 
 @param configuration Reference on complete configuration which should be applied to NSURL session.
 
 @return Constructed and ready to use NSURL session manager instance.
 
 @since 4.0
 */
- (NSURLSession *)sessionWithConfiguration:(NSURLSessionConfiguration *)configuration;

/**
 @brief  Allow to construct base URL basing on network configuraiton.
 
 @return Ready to use service URL.
 
 @since 4.0.2
 */
- (NSURL *)requestBaseURL;


#pragma mark - Handlers

/**
 @brief      Serialize service response or handle error.
 @discussion Depending on received metadata and data code will call passed success or failure blocks after 
             serialization process completion on secondary queue.
 
 @param data    Reference on RAW data received from service.
 @param task    Reference on data task which has been used to communicate with \b PubNub network.
 @param error   Reference on data/request processing error.
 @param success Reference on data task success handling block which will be called by network manager.
 @param failure Reference on data task processing failure handling block which will be called by network 
                manager.
 
 @since 4.0
 */
- (void)handleData:(nullable NSData *)data loadedWithTask:(nullable NSURLSessionDataTask *)task
             error:(nullable NSError *)requestError usingSuccess:(NSURLSessionDataTaskSuccess)success
           failure:(NSURLSessionDataTaskFailure)failure;

/**
 @brief      Handle successful operation processing completion.
 @discussion Called when request for \b PubNub network successfully completed processing.
 
 @param operation      Reference on operation type for which actual network request has been sent to \b PubNub
                       network.
 @param task           Reference on data task which has been used to deliver operation to \b PubNub network.
 @param responseObject Reference on pre-processed \b PubNub network response (de-serialized JSON).
 @param block          Depending on operation type it can be \b PNResultBlock, \b PNStatusBlock or
                       \b PNCompletionBlock blocks.`
 
 @since 4.0
 */
- (void)handleOperation:(PNOperationType)operation taskDidComplete:(nullable NSURLSessionDataTask *)task
               withData:(nullable id)responseObject completionBlock:(id)block;

/**
 @brief      Handle operation failure.
 @discussion Called when request for \b PubNub network did fail to process or service respond with error.
 
 @param operation Reference on operation type for which actual network request has been sent to \b PubNub 
                  network.
 @param task      Reference on data task which has been used to deliver operation to \b PubNub network.
 @param error     Reference on \a NSError instance which describe what exactly went wrong during operation 
                  processing.
 @param block     Depending on operation type it can be \b PNResultBlock, \b PNStatusBlock or
                  \b PNCompletionBlock blocks.
 
 @since 4.0
 */
- (void)handleOperation:(PNOperationType)operation taskDidFail:(nullable NSURLSessionDataTask *)task
              withError:(nullable NSError *)error completionBlock:(id)block;

/**
 @brief      Pre-processed service response handler.
 @discussion This method actually build result and status objects basing on pre-processed service response.
 
 @param data      Pre-processed data, using parser.
 @param task      Reference on data task which has been used to communicate with \b PubNub network.
 @param operation One of \b PNOperationType enum fields which clarify what kind of request has been done to
                  \b PubNub network and for which response has been processed.
 @param isError   Whether pre-processed data represent error or not.
 @param error     Reference on data/request processing error.
 @param block     Block which should be called at the end of pre-processed data wrapping into objects.
 
 @since 4.0
 */
- (void)handleParsedData:(nullable NSDictionary *)data loadedWithTask:(nullable NSURLSessionDataTask *)task
            forOperation:(PNOperationType)operation parsedAsError:(BOOL)isError
         processingError:(nullable NSError *)error completionBlock:(id)block;

/**
 @brief  Used to handle prepared objects and pass them to the code.
 
 @param operation One of \b PNOperationType enum fields which clarify for what kind of operation objects has
                  been created.
 @param result    Reference on object which stores useful server response.
 @param status    Reference on request processing result (can be error or ACK response).
 @param block     Block which should be called at the end of pre-processed data wrapping into objects.
 
 @since 4.0
 */
- (void)handleOperation:(PNOperationType)operation processingCompletedWithResult:(nullable PNResult *)result
                 status:(nullable PNStatus *)status completionBlock:(id)block;


#pragma mark - Misc

#if __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH

/**
 @brief  Check whether there \c operation is in the list of passed \c tasks. 
 
 @since 4.5.0
 
 @param operation One of \b PNOperationType enum fields which is used during search.
 @param tasks     List of currently scheduled and pending / executing data tasks among which should be found 
                  reference on \c operation.
 
 @return \c YES in case if \c operation has been found in list of passed \c tasks.
 */
- (BOOL)hasOperation:(PNOperationType)operation inDataTasks:(NSArray<NSURLSessionDataTask *> *)tasks;

/**
 @brief  Depending on current network manager state it may require to complete currently active tasks 
         completion from background execution context.
 
 @since 4.5.0
 */
- (void)endBackgroundTasksCompletionIfRequired;

#endif // __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH

/**
 @brief  Print out any session configuration instance customizations which has been done by developer.
 
 @since 4.4.0
 */
- (void)printIfRequiredSessionCustomizationInformation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNNetwork


#pragma mark - Initialization and Configuration

+ (instancetype)networkForClient:(PubNub *)client requestTimeout:(NSTimeInterval)timeout
              maximumConnections:(NSInteger)maximumConnections longPoll:(BOOL)longPollEnabled {
    
    return [[self alloc] initForClient:client requestTimeout:timeout maximumConnections:maximumConnections 
                              longPoll:longPollEnabled];
}

- (instancetype)initForClient:(PubNub *)client requestTimeout:(NSTimeInterval)timeout
           maximumConnections:(NSInteger)maximumConnections longPoll:(BOOL)longPollEnabled {
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        
        _client = client;
        [_client.logger enableLogLevel:(PNRequestLogLevel|PNInfoLogLevel)];
        _configuration = client.configuration;
        _forLongPollRequests = longPollEnabled;
#if __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH
        _scheduledDataTasks = [NSMutableArray new];
        _tasksCompletionIdentifier = UIBackgroundTaskInvalid;
#endif // __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH
        _identifier = [[NSString stringWithFormat:@"com.pubnub.network.%p", self] copy];
        _processingQueue = dispatch_queue_create([_identifier UTF8String], DISPATCH_QUEUE_CONCURRENT);;
        _serializer = [PNNetworkResponseSerializer new];
        _baseURL = [self requestBaseURL];
        _lock = OS_SPINLOCK_INIT;
        [self prepareSessionWithRequesrTimeout:timeout maximumConnections:maximumConnections];
    }
    
    return self;
}


#pragma mark - Request helper

- (void)appendRequiredParametersTo:(PNRequestParameters *)parameters {
    
    [parameters addPathComponents:@{@"{sub-key}": (self.configuration.subscribeKey?: @""),
                                    @"{pub-key}": (self.configuration.publishKey?: @"")}];
    [parameters addQueryParameters:@{@"uuid": (self.configuration.uuid?: @""),
                                     @"deviceid": (self.configuration.deviceID?: @""),
                                     @"pnsdk":[NSString stringWithFormat:@"PubNub-%@%%2F%@",
                                               kPNClientName, kPNLibraryVersion]}];
    if (self.configuration.authKey.length) {
        
        [parameters addQueryParameter:self.configuration.authKey forFieldName:@"auth"];
    }
}

- (NSURLRequest *)requestWithURL:(NSURL *)requestURL data:(NSData *)postData {
    
    NSURL *fullURL = [NSURL URLWithString:requestURL.absoluteString relativeToURL:self.baseURL];
    NSMutableURLRequest *httpRequest = [NSMutableURLRequest requestWithURL:fullURL];
    httpRequest.HTTPMethod = ([postData length] ? @"POST" : @"GET");
    OSSpinLockLock(&_lock);
    httpRequest.cachePolicy = self.session.configuration.requestCachePolicy;
    httpRequest.allHTTPHeaderFields = self.session.configuration.HTTPAdditionalHeaders;
    OSSpinLockUnlock(&_lock);
    if (postData) {
        
        NSMutableDictionary *allHeaders = [httpRequest.allHTTPHeaderFields mutableCopy];
        [allHeaders addEntriesFromDictionary:@{@"Content-Encoding":@"gzip",
                                               @"Content-Type":@"application/json;charset=UTF-8",
                                               @"Content-Length":[NSString stringWithFormat:@"%@",
                                                                  @(postData.length)]}];
        httpRequest.allHTTPHeaderFields = allHeaders;
        [httpRequest setHTTPBody:postData];
    }
    
    return [httpRequest copy];
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                      success:(NSURLSessionDataTaskSuccess)success
                                      failure:(NSURLSessionDataTaskFailure)failure {
    
    __block NSURLSessionDataTask *task = nil;
    __weak __typeof(self) weakSelf = self;
    NSURLSessionDataTaskCompletion handler = ^(NSData *data, NSURLResponse *response, NSError *error) {
        
        // Silence static analyzer warnings.
        // Code is aware about this case and at the end will simply call on 'nil' object method.
        // In most cases if referenced object become 'nil' it mean what there is no more need in
        // it and probably whole client instance has been deallocated.
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wreceiver-is-weak"
        [weakSelf handleData:data loadedWithTask:task error:(error?: task.error)
                usingSuccess:success failure:failure];
        #pragma clang diagnostic pop
    };
    OSSpinLockLock(&_lock);
    task = [self.session dataTaskWithRequest:request completionHandler:[handler copy]];
#if __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH
    if (self.configuration.shouldCompleteRequestsBeforeSuspension) {
        
        [self.scheduledDataTasks addObject:task];
    }
#endif // __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH
    OSSpinLockUnlock(&_lock);
    
    return task;
}


#pragma mark - Request processing

- (BOOL)operationExpectResult:(PNOperationType)operation {
    
    static NSArray *_resultExpectingOperations;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _resultExpectingOperations = @[
                   @(PNHistoryOperation), @(PNWhereNowOperation), @(PNHereNowGlobalOperation),
                   @(PNHereNowForChannelOperation), @(PNHereNowForChannelGroupOperation),
                   @(PNStateForChannelOperation), @(PNStateForChannelGroupOperation),
                   @(PNChannelGroupsOperation), @(PNChannelsForGroupOperation),
                   @(PNPushNotificationEnabledChannelsOperation), @(PNTimeOperation)];
    });
    
    return [_resultExpectingOperations containsObject:@(operation)];
}

- (Class <PNParser>)parserForOperation:(PNOperationType)operation {
    
    static NSDictionary *_parsers;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSMutableDictionary *parsers = [NSMutableDictionary new];
        for (Class class in [PNClass classesConformingToProtocol:@protocol(PNParser)]) {
            
            NSArray<NSNumber *> *operations = [(Class<PNParser>)class operations];
            for (NSNumber *operationType in operations) { parsers[operationType] = class; }
        }
        _parsers = [parsers copy];
    });
    
    return _parsers[@(operation)];
}

- (Class)resultClassForOperation:(PNOperationType)operation {
    
    Class class = [PNResult class];
    if (PNOperationResultClasses[operation]) {
        
        class = NSClassFromString(PNOperationResultClasses[operation]);
    }
    
    return class;
}

- (Class)statusClassForOperation:(PNOperationType)operation {
    
    Class class = [PNStatus class];
    if (PNOperationStatusClasses[operation]) {
        
        class = NSClassFromString(PNOperationStatusClasses[operation]);
    }
    
    return class;
}

- (void)processOperation:(PNOperationType)operationType withParameters:(PNRequestParameters *)parameters 
                    data:(NSData *)data completionBlock:(id)block {

    if (operationType == PNSubscribeOperation || operationType == PNUnsubscribeOperation) {
        
        [self cancelAllRequests];
    }
    
    [self appendRequiredParametersTo:parameters];
    // Silence static analyzer warnings.
    // Code is aware about this case and at the end will simply call on 'nil' object method.
    // In most cases if referenced object become 'nil' it mean what there is no more need in
    // it and probably whole client instance has been deallocated.
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wreceiver-is-weak"
    NSURL *requestURL = [PNURLBuilder URLForOperation:operationType withParameters:parameters];
    if (requestURL) {
        
        DDLogRequest(self.client.logger, @"<PubNub::Network> %@ %@", (data.length ? @"POST" : @"GET"), 
                     requestURL.absoluteString);
        
        __weak __typeof(self) weakSelf = self;
        [[self dataTaskWithRequest:[self requestWithURL:requestURL data:data]
                           success:^(NSURLSessionDataTask *task, id responseObject) {
                               
               [weakSelf handleOperation:operationType taskDidComplete:task withData:responseObject
                         completionBlock:block];
           }
           failure:^(NSURLSessionDataTask *task, id error) {
               
               [weakSelf handleOperation:operationType taskDidFail:task withError:error
                         completionBlock:block];
           }] resume];
    }
    else {
        
        PNErrorStatus *badRequestStatus = [PNErrorStatus statusForOperation:operationType
                                                                   category:PNBadRequestCategory
                                                        withProcessingError:nil];
        [self.client appendClientInformation:badRequestStatus];
        if (block) {
            
            if ([self operationExpectResult:operationType]) {
                
                ((PNCompletionBlock)block)(nil, badRequestStatus);
            }
            else { ((PNStatusBlock)block)(badRequestStatus); }
        }
    }
    #pragma clang diagnostic pop
}

- (void)parseData:(id)data withParser:(Class <PNParser>)parser 
       completion:(void(^)(NSDictionary *parsedData, BOOL parseError))block {

    __weak __typeof(self) weakSelf = self;
    void(^parseCompletion)(NSDictionary *) = ^(NSDictionary *processedData){
        
        if (processedData || parser == [PNErrorParser class]) {
            
            block(processedData, (parser == [PNErrorParser class]));
        }
        else {
            
            // Silence static analyzer warnings.
            // Code is aware about this case and at the end will simply call on 'nil' object method.
            // In most cases if referenced object become 'nil' it mean what there is no more need in
            // it and probably whole client instance has been deallocated.
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wreceiver-is-weak"
            [weakSelf parseData:data withParser:[PNErrorParser class] completion:[block copy]];
            #pragma clang diagnostic pop
        }
    };
    
    if (![parser requireAdditionalData]) {
        
        parseCompletion([parser parsedServiceResponse:data]);
    }
    else {

        NSMutableDictionary *additionalData = [NSMutableDictionary new];
        additionalData[@"stripMobilePayload"] = @(self.configuration.shouldStripMobilePayload);
        if ([self.configuration.cipherKey length]) {

            additionalData[@"cipherKey"] = self.configuration.cipherKey;
        }
        
        // If additional data required client should assume what potentially additional calculations
        // may be required and should temporarily shift to background queue.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

            NSDictionary *parsedData = [parser parsedServiceResponse:data withData:additionalData];
            pn_dispatch_async(self.processingQueue, ^{
                
                parseCompletion(parsedData);
            });
        });
    }
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH

- (void)processIncompleteBeforeClientResignActiveTasks:(NSArray<NSURLSessionDataTask *> *)dataTasks
                                  onDataTaskCompletion:(BOOL)onCompletion {
    
    NSUInteger incompleteTasksCount = dataTasks.count;
    if (incompleteTasksCount > 0 && self.forLongPollRequests) {
        
        if (![self hasOperation:PNUnsubscribeOperation inDataTasks:dataTasks]) {
            
            incompleteTasksCount = 0;
        }
    }
    
    if (incompleteTasksCount == 0) {
        
        DDLogRequest(self.client.logger, @"<PubNub::Network> All tasks completed. There is no need in "
                     "additional execution time in background context.");
        [self endBackgroundTasksCompletionIfRequired];
    }
    else if (!onCompletion) {
        
        DDLogRequest(self.client.logger, @"<PubNub::Network> There is %lu incompleted tasks. Required "
                     "additional execution time in background context.", (unsigned long)incompleteTasksCount);
    }
}
#endif // __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH

- (void)cancelAllRequests {

    OSSpinLockLock(&_lock);
#if __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH
    if (self.configuration.shouldCompleteRequestsBeforeSuspension) {
        
        [self.scheduledDataTasks removeAllObjects];
    }
#endif // __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH
    
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks,
                                                  NSArray *downloadTasks) {
        
        [dataTasks makeObjectsPerformSelector:@selector(cancel)];
        [uploadTasks makeObjectsPerformSelector:@selector(cancel)];
        [downloadTasks makeObjectsPerformSelector:@selector(cancel)];
        OSSpinLockUnlock(&self->_lock);
    }];
}

- (void)invalidate {
    
    OSSpinLockLock(&_lock);
    [_session invalidateAndCancel];
    _session = nil;
    OSSpinLockUnlock(&self->_lock);
}


#pragma mark - Operation information

- (NSInteger)packetSizeForOperation:(PNOperationType)operationType
                     withParameters:(PNRequestParameters *)parameters data:(NSData *)data {
    
    NSInteger size = -1;
    [self appendRequiredParametersTo:parameters];
    NSURL *requestURL = [PNURLBuilder URLForOperation:operationType withParameters:parameters];
    if (requestURL) {
        
        size = [PNURLRequest packetSizeForRequest:[self requestWithURL:requestURL data:data]];
    }
    
    return size;
}


#pragma mark - Session constructor

- (void)prepareSessionWithRequesrTimeout:(NSTimeInterval)timeout
                      maximumConnections:(NSInteger)maximumConnections {
    
    _requestTimeout = timeout;
    _maximumConnections = maximumConnections;
    NSURLSessionConfiguration *config = [self configurationWithRequestTimeout:timeout
                                                           maximumConnections:maximumConnections];
    _delegateQueue = [self operationQueueWithConfiguration:config];
    _session = [self sessionWithConfiguration:config];
    [self printIfRequiredSessionCustomizationInformation];
    
}

- (NSURLSessionConfiguration *)configurationWithRequestTimeout:(NSTimeInterval)timeout
                                            maximumConnections:(NSInteger)maximumConnections {
    
    // Prepare base configuration with predefined timeout values and maximum connections
    // to same host (basically how many requests can be handled at once).
    NSURLSessionConfiguration *configuration = nil;
    configuration = [NSURLSessionConfiguration pn_ephemeralSessionConfigurationWithIdentifier:self.identifier];
    configuration.HTTPShouldUsePipelining = !self.forLongPollRequests;
    configuration.timeoutIntervalForRequest = timeout;
    configuration.HTTPMaximumConnectionsPerHost = maximumConnections;
    
    return configuration;
}

- (NSOperationQueue *)operationQueueWithConfiguration:(NSURLSessionConfiguration *)configuration {
    
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = configuration.HTTPMaximumConnectionsPerHost;
    
    return queue;
}

- (NSURLSession *)sessionWithConfiguration:(NSURLSessionConfiguration *)configuration {
    
    // Construct sessions to process requests which should be sent to PubNub network.
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self
                                                     delegateQueue:_delegateQueue];
    
    return session;
}

- (NSURL *)requestBaseURL {
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"http%@://%@",
                                 (_configuration.TLSEnabled ? @"s" : @""), _configuration.origin]];
}


#pragma mark - Handlers

#if __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH

- (void)handleClientWillResignActive {
    
    OSSpinLockLock(&_lock);
    if (self.tasksCompletionIdentifier == UIBackgroundTaskInvalid) {
        
        // Give manager some time to figure out whether background task should be used to complete all 
        // scheduled data tasks or not.
        __weak __typeof__(self) weakSelf = self;
        self.tasksCompletionIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            
            [weakSelf endBackgroundTasksCompletionIfRequired];
        }];
             
        // Give some time before checking whether tasks has been scheduled for execution or not.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)),
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                           
            // Get list of scheduled operation.
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            OSSpinLockLock(&strongSelf->_lock);
            if (strongSelf.tasksCompletionIdentifier != UIBackgroundTaskInvalid) {
                
                [strongSelf processIncompleteBeforeClientResignActiveTasks:self.scheduledDataTasks
                                                      onDataTaskCompletion:NO];
            }
            OSSpinLockUnlock(&strongSelf->_lock);
        });
    } 
    OSSpinLockUnlock(&_lock);
}

- (void)handleClientDidBecomeActive {
    
    [self endBackgroundTasksCompletionIfRequired];
}

#endif // __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH


-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    
    if (error) {
        
        OSSpinLockLock(&_lock);
        // Clean up cached tasks if required.
#if __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH
        if (self.configuration.shouldCompleteRequestsBeforeSuspension) {
            
            [self.scheduledDataTasks removeAllObjects];
        }
#endif // __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH
        
        // Replace invalidated session with new one which can be used for next requests.
        [self prepareSessionWithRequesrTimeout:self.requestTimeout
                            maximumConnections:self.maximumConnections];
        OSSpinLockUnlock(&_lock);
    }
}

- (void)handleData:(NSData *)data loadedWithTask:(NSURLSessionDataTask *)task error:(NSError *)requestError 
      usingSuccess:(NSURLSessionDataTaskSuccess)success failure:(NSURLSessionDataTaskFailure)failure {
    
    dispatch_async(self.processingQueue, ^{
        
        NSError *serializationError = nil;
        id processedObject = [self.serializer serializedResponse:(NSHTTPURLResponse *)task.response
                                                        withData:data error:&serializationError];
        NSError *error = (requestError?: serializationError);
        (!error ? success : failure)(task, (error?: processedObject));
    });
}

- (void)handleOperation:(PNOperationType)operation taskDidComplete:(NSURLSessionDataTask *)task
               withData:(id)responseObject completionBlock:(id)block {
    
    __weak __typeof(self) weakSelf = self;
    [self parseData:responseObject withParser:[self parserForOperation:operation]
         completion:^(NSDictionary *parsedData, BOOL parseError) {

             // Silence static analyzer warnings.
             // Code is aware about this case and at the end will simply call on 'nil' object method.
             // In most cases if referenced object become 'nil' it mean what there is no more need in
             // it and probably whole client instance has been deallocated.
             #pragma clang diagnostic push
             #pragma clang diagnostic ignored "-Wreceiver-is-weak"
             [weakSelf handleParsedData:parsedData loadedWithTask:task forOperation:operation
                          parsedAsError:parseError processingError:task.error
                        completionBlock:[block copy]];
             #pragma clang diagnostic pop
         }];
}

- (void)handleOperation:(PNOperationType)operation taskDidFail:(NSURLSessionDataTask *)task
              withError:(NSError *)error completionBlock:(id)block {
    
    if (error.code == NSURLErrorCancelled) {
        
        [self handleOperation:operation taskDidComplete:task withData:nil completionBlock:block];
    }
    else {
        
        id errorDetails = nil;
        NSData *errorData = (error?: task.error).userInfo[kPNNetworkErrorResponseDataKey];
        if (errorData) {
            
            errorDetails = [NSJSONSerialization JSONObjectWithData:errorData
                                                           options:(NSJSONReadingOptions)0 error:NULL];
        }
        [self parseData:errorDetails withParser:[PNErrorParser class]
             completion:^(NSDictionary *parsedData, __unused BOOL parseError) {

                 [self handleParsedData:parsedData loadedWithTask:task forOperation:operation
                          parsedAsError:YES processingError:(error?: task.error)
                        completionBlock:[block copy]];
             }];
    }
}

- (void)handleParsedData:(NSDictionary *)data loadedWithTask:(NSURLSessionDataTask *)task
            forOperation:(PNOperationType)operation parsedAsError:(BOOL)isError
         processingError:(NSError *)error completionBlock:(id)block {
    
    PNResult *result = nil;
    PNStatus *status = nil;
    
    // Check whether request potentially has been cancelled prior actual sending to the network or
    // not
    if (task && ((NSHTTPURLResponse *)task.response).statusCode == 0 &&
        error && error.code == NSURLErrorBadServerResponse) {
        
        isError = YES;
        error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled
                                userInfo:error.userInfo];
    }
    if ([self operationExpectResult:operation] && !isError) {
        
        result = [[self resultClassForOperation:operation] objectForOperation:operation
                                                           completedWithTask:task
                                                               processedData:data
                                                             processingError:error];
    }
    
    if (isError || !data || ![self operationExpectResult:operation]){
        
        Class statusClass = (isError ? [PNErrorStatus class] : [self statusClassForOperation:operation]);
        status = (PNStatus *)[statusClass objectForOperation:operation completedWithTask:task
                                               processedData:data processingError:error];
    }
    
    if (result || status) {

        [self handleOperation:operation processingCompletedWithResult:result
                       status:status completionBlock:block];
    }
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH
    if (self.configuration.shouldCompleteRequestsBeforeSuspension) {
        
        OSSpinLockLock(&_lock);
        [self.scheduledDataTasks removeObject:task];
        if (self.tasksCompletionIdentifier != UIBackgroundTaskInvalid) {
            
            [self processIncompleteBeforeClientResignActiveTasks:self.scheduledDataTasks
                                            onDataTaskCompletion:YES];
        }
        OSSpinLockUnlock(&_lock); 
    }
#endif // __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH
}

- (void)handleOperation:(PNOperationType)operation processingCompletedWithResult:(PNResult *)result
                 status:(PNStatus *)status completionBlock:(id)block {
    
    // Silence static analyzer warnings.
    // Code is aware about this case and at the end will simply call on 'nil' object method.
    // In most cases if referenced object become 'nil' it mean what there is no more need in
    // it and probably whole client instance has been deallocated.
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wreceiver-is-weak"
    #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    [self.client appendClientInformation:result];
    [self.client appendClientInformation:status];
    if (block) {
        
        if ([self operationExpectResult:operation]) {
            
            ((PNCompletionBlock)block)(result, status);
        }
        else {
            
            ((void(^)(id))block)(result?: status);
        }
    }
    #pragma clang diagnostic pop
}


#pragma mark - Misc

#if __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH

- (BOOL)hasOperation:(PNOperationType)operation inDataTasks:(NSArray<NSURLSessionDataTask *> *)tasks {
    
    BOOL hasOperation = NO;
    for (NSURLSessionDataTask *dataTask in tasks) {
        
        if ([PNURLBuilder isURL:dataTask.originalRequest.URL forOperation:operation]) {
            
            hasOperation = YES;
            break;
        }
    }
    
    return hasOperation;
}

- (void)endBackgroundTasksCompletionIfRequired {
    
    bool locked = OSSpinLockTry(&_lock);
    if (self.tasksCompletionIdentifier != UIBackgroundTaskInvalid) {
        
        [[UIApplication sharedApplication] endBackgroundTask:self.tasksCompletionIdentifier];
        self.tasksCompletionIdentifier = UIBackgroundTaskInvalid;
    }
    if (locked) { OSSpinLockUnlock(&_lock); }
}

#endif // __IPHONE_OS_VERSION_MIN_REQUIRED && !TARGET_OS_WATCH

- (void)printIfRequiredSessionCustomizationInformation {
    
    if ([NSURLSessionConfiguration pn_HTTPAdditionalHeaders].count) {
        
        DDLogClientInfo(self.client.logger, @"<PubNub::Network> Custom HTTP headers is set by user: %@", 
                        [NSURLSessionConfiguration pn_HTTPAdditionalHeaders]);
    }
    
    if ([NSURLSessionConfiguration pn_networkServiceType] != NSURLNetworkServiceTypeDefault) {
        
        DDLogClientInfo(self.client.logger, @"<PubNub::Network> Custom network service type is set by user: %@",
                        @([NSURLSessionConfiguration pn_networkServiceType]));
    }
    
    if (![NSURLSessionConfiguration pn_allowsCellularAccess]) {
        
        DDLogClientInfo(self.client.logger, @"<PubNub::Network> User limited access to cellular data and only"
                        " WiFi connection can be used.");
    }
    
    if ([NSURLSessionConfiguration pn_protocolClasses].count) {
        
        DDLogClientInfo(self.client.logger, @"<PubNub::Network> Extra requests handling protocols defined by "
                        "user: %@", [NSURLSessionConfiguration pn_protocolClasses]);
    }
    
    if ([NSURLSessionConfiguration pn_connectionProxyDictionary].count) {
        
        DDLogClientInfo(self.client.logger, @"<PubNub::Network> Connection proxy has been set by user: %@", 
                        [NSURLSessionConfiguration pn_connectionProxyDictionary]);
    }
}

#pragma mark -


@end
