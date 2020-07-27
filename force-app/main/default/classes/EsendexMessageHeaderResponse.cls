public class EsendexMessageHeaderResponse {
    public Integer statusCode;
    public String responseData;
    public string status;
    
    public String messageStatus;
    public String to;
    public Integer code;
    public String detail;
    public String description;
    public Boolean permanentFailure;
    public String id;
    
    public EsendexMessageHeaderResponse(HttpResponse response) {
        this.statusCode = response.getStatusCode();
        this.responseData = response.getBody();
        this.status = response.getStatus();
    }
    
    public void deserialize() {
        Dom.Document document = new Dom.Document();
        document.load(responseData);
        Dom.XmlNode rootNode = document.getRootElement();
        this.id = rootNode.getAttributeValue('id', null);
        for(Dom.XmlNode childNode :rootNode.getChildren()) {
            if(childNode.getName() == 'status') {
                this.messageStatus = childNode.getText();
            }
            if(childNode.getName() == 'to') {
                for(Dom.XmlNode toChildNode :childNode.getChildren()) {
                    if(toChildNode.getName() == 'phonenumber') {
                        this.to = toChildNode.getText();
                    }
                }
            }
            if(childNode.getName() == 'FailureReason') {
                for(Dom.XmlNode failureChildNode :childNode.getChildren()) {
                    if(failureChildNode.getName() == 'Code') {
                        this.code = Integer.valueOf(failureChildNode.getText());
                    }
                    if(failureChildNode.getName() == 'Detail') {
                        this.detail = failureChildNode.getText();
                        this.description = EsendexUtils.FAILURE_DICTIONARY.get(this.code);
                    }
                    if(failureChildNode.getName() == 'PermanentFailure') {
                        this.permanentFailure = Boolean.valueOf(failureChildNode.getText());
                    }
                }
            }
        }
    }
}