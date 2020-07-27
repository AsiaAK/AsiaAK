public  class EsendexHelper {
    public static List<EsendexError__c> errors;
    public static List<EsendexMessageBatch__c> batches;
    public static Map<String, EsendexMessageHeader__c> headers;
    public static List<Opportunity> sObjects;
    public static Esendex__c config;
    
    static {
        errors = new List<EsendexError__c>();
        batches = new List<EsendexMessageBatch__c>();
        headers = new Map<String, EsendexMessageHeader__c>();
        
        config = Esendex__c.getValues('Config');
        if(config == null) {
            config = new Esendex__c(
                Name = 'Config',
                Account__c = '',
                From__c = ''
            );
        }
    }
    
    public static void execute(String flowType) {
        if(flowType == 'message dispatcher') {
            EsendexMessageDispatcherRequest request = mapOpportunitiesToDispatcherRequest();
            EsendexMessageDispatcherResponse dispatcherResponse = Esendex.messageDispatcher(request);
            parseMessageDispatcherResponse(dispatcherResponse);
            flowType = 'message header';
        }
        if(flowType == 'message header') {
            EsendexMessageHeaderResponse headerResponse;
            for(String messageHeaderId :headers.keySet()) {
                 headerResponse = Esendex.messageHeader(messageHeaderId);
                 parseMessageHeaderResponse(headerResponse);
            }
        }
        performDML();
    }
    
    private static EsendexMessageDispatcherRequest mapOpportunitiesToDispatcherRequest() {
        EsendexMessageDispatcherRequest request = new EsendexMessageDispatcherRequest();
        request.accountreference = config.Account__c;
        request.defaultFrom = config.From__c;
        request.defaultType = 'SMS';
        request.defaultCharacterSet = 'Unicode';
        EsendexMessageDispatcherRequest.Message tempMessage;
        for(Opportunity record :sObjects) {
            tempMessage = new EsendexMessageDispatcherRequest.Message();
            //tempMessage.toNumber = record.Account.PersonMobilePhone;
            tempMessage.toNumber = record.Account.Phone;
            tempMessage.body = record.ReminderSMSTextAuto__c;
            request.messages.add(tempMessage);
        }
        return request;
    }
    
    private static void parseMessageDispatcherResponse(EsendexMessageDispatcherResponse response) {
        if(response.statusCode != 200) {
            errors.add(new EsendexError__c(
                StatusCode__c = response.statusCode,
                Message__c = response.responseData,
                Status__c = response.status
            ));
            for(Opportunity record :sObjects) {
                record.LastSMSStatus__c = 'An error occured when trying to send the SMS to Esendex. For more details please consult the latest error entry in the Esendex error report.';
            }
        } else {
            response.deserialize();
            batches.add(new EsendexMessageBatch__c(
                BatchId__c = response.batchId
            ));
            for(EsendexMessageDispatcherResponse.MessageHeader messageHeader :response.messageHeaders) {
                headers.put(messageHeader.id, new EsendexMessageHeader__c(
                    HeaderId__c = messageHeader.id,
                    Uri__c = messageHeader.uri,
                    MessageBatchRef__r = new EsendexMessageBatch__c(BatchId__c = response.batchId)
                ));
            }
        }
    }
    
    private static void parseMessageHeaderResponse(EsendexMessageHeaderResponse response) {
        system.debug(response.responseData);
        if(response.statusCode != 200) {
            errors.add(new EsendexError__c(
                StatusCode__c = response.statusCode,
                Message__c = response.responseData,
                Status__c = response.status
            ));
            for(Opportunity record :sObjects) {
                record.LastSMSStatus__c = 'An error occured when trying to retrieve the SMS status. An automated process will try to retrieve this information at a later time.';
            }
        } else {
            response.deserialize();
            EsendexMessageHeader__c tempHeader = headers.get(response.id);
            tempHeader.Status__c = response.messageStatus;
            tempHeader.PermanentFailure__c = (response.permanentFailure == null)? false : response.permanentFailure;
            tempHeader.FailureCode__c = response.code;
            tempHeader.FailureDescription__c = response.detail;
            tempHeader.FailureDetail__c = response.description;
            for(Opportunity record :sObjects) {
                //if(EsendexUtils.stripPhoneNumber(record.Account.PersonMobilePhone).contains(response.to)) {
                if(EsendexUtils.stripPhoneNumber(record.Account.Phone).contains(response.to)) {
                    tempHeader.OpportunityRef__c = record.Id;
                    record.LastSmsSentAt__c = System.now();
                    record.LastSMSStatus__c = 'Last SMS is being processed by Esendex.';
                    if(tempHeader.Status__c == 'Delivered') {
                        record.LastSMSStatus__c = 'Last SMS was delivered.';
                    } 
                    if(tempHeader.Status__c.contains('Failed')) {
                        record.LastSMSStatus__c = 'Last SMS could not be sent. Please check the related message header for more details.';
                    }
                    break;
                }
            }
        }
    }
    
    private static void performDML() {
        try {
            if(!errors.isEmpty()) {
                insert errors;
            }
            if(!batches.isEmpty()) {
                upsert batches BatchId__c;
                if(!headers.isEmpty()) {
                    upsert headers.values() HeaderId__c;
                }
            }
            system.debug(sObjects);
            if(sObjects != null && !sObjects.isEmpty()) {
                update sObjects;
            }
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        }
    }
}