public class EsendexMessageDispatcherResponse {
    public Integer statusCode;
    public String responseData;
    public String status;
    
    public String batchId;
    public List<MessageHeader> messageHeaders;
    
    public class MessageHeader {
        public String id;
        public String uri;
    }
    
    public EsendexMessageDispatcherResponse(HttpResponse response) {
        this.statusCode = response.getStatusCode();
        this.responseData = response.getBody();
        this.status = response.getStatus();
    }
    
    public void deserialize() {
        Dom.Document document = new Dom.Document();
        document.load(responseData);
        Dom.XmlNode rootNode = document.getRootElement();
        this.batchId = rootNode.getAttributeValue('batchid', null);
        this.messageHeaders = new List<MessageHeader>();
        MessageHeader tempHeader;
        for(Dom.XmlNode childNode :rootNode.getChildren()) {
            if(childNode.getName() == 'messageheader') {
                tempHeader = new MessageHeader();
                tempHeader.id = childNode.getAttributeValue('id', null);
                tempHeader.uri = childNode.getAttributeValue('uri', null);
                this.messageHeaders.add(tempHeader);
            }
        }
    }
}