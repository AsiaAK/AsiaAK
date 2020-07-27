public with sharing class EsendexMessageDispatcherRequest {
    public String accountreference;
    public String defaultFrom;
    public String defaultType;
    public String defaultLang;
    public Integer defaultRetries;
    public Integer defaultValidity;
    public String defaultSendAt;
    public String defaultCharacterSet;
    public List<Message> messages;
    
    public class Message {
        public String fromNumber;
        public String toNumber;
        public String messageType;
        public String body;
        public String lang;
        public Integer retries;
        public Integer validity;
        public String characterSet;
    }
    
    public EsendexMessageDispatcherRequest() {
        this.messages = new List<Message>();
    }
    
    public String serialize() {
        String serializedOutput = '';
        XmlStreamWriter sw = new XmlStreamWriter();
        sw.writeStartDocument('UTF-8', '1.0');
        //<messages>
        sw.writeStartElement(null, 'messages', null);
            //<accountreference>
            sw.writeStartElement(null, 'accountreference', null);
            sw.writeCharacters(this.accountreference);
            sw.writeEndElement();
            //</accountreference>
            //<from>
            if(String.isNotBlank(this.defaultFrom)) {
                sw.writeStartElement(null, 'from', null);
                sw.writeCharacters(this.defaultFrom);
                sw.writeEndElement();
            }
            //</from>
            //<type>
            if(String.isNotBlank(this.defaultType)) {
                sw.writeStartElement(null, 'type', null);
                sw.writeCharacters(this.defaultType);
                sw.writeEndElement();
            }
            //</type>
            //<lang>
            if(String.isNotBlank(this.defaultLang)) {
                sw.writeStartElement(null, 'lang', null);
                sw.writeCharacters(this.defaultLang);
                sw.writeEndElement();
            }
            //</lang>
            //<retries>
            if(this.defaultRetries != null) {
                sw.writeStartElement(null, 'from', null);
                sw.writeCharacters(String.valueOf(this.defaultRetries));
                sw.writeEndElement();
            }
            //</retries>
            //<validity>
            if(this.defaultValidity != null) {
                sw.writeStartElement(null, 'validity', null);
                sw.writeCharacters(String.valueOf(this.defaultValidity));
                sw.writeEndElement();
            }
            //</validity>
            //<sendat>
            if(String.isNotBlank(this.defaultSendAt)) {
                sw.writeStartElement(null, 'sendat', null);
                sw.writeCharacters(this.defaultSendAt);
                sw.writeEndElement();
            }
            //</sendat>
            //<characterset>
            if(String.isNotBlank(this.defaultCharacterSet)) {
                sw.writeStartElement(null, 'characterset', null);
                sw.writeCharacters(this.defaultCharacterSet);
                sw.writeEndElement();
            }
            //</characterset>
            for(Message message :this.messages) {
                //<message>
                sw.writeStartElement(null, 'message', null);
                    //<from>
                    if(String.isNotBlank(message.fromNumber)) {
                        sw.writeStartElement(null, 'from', null);
                        sw.writeCharacters(message.fromNumber);
                        sw.writeEndElement();
                    }
                    //</from>
                    //<to>
                    if(String.isNotBlank(message.toNumber)) {
                    sw.writeStartElement(null, 'to', null);
                    sw.writeCharacters(message.toNumber);
                    sw.writeEndElement();
                    }
                    //</to>
                    //<type>
                    if(String.isNotBlank(message.messageType)) {
                        sw.writeStartElement(null, 'type', null);
                        sw.writeCharacters(message.messageType);
                        sw.writeEndElement();
                    }
                    //</type>
                    //<body>
                    sw.writeStartElement(null, 'body', null);
                    sw.writeCharacters(message.body);
                    sw.writeEndElement();
                    //</body>
                    //<lang>
                    if(String.isNotBlank(message.lang)) {
                        sw.writeStartElement(null, 'lang', null);
                        sw.writeCharacters(message.lang);
                        sw.writeEndElement();
                    }
                    //</lang>
                    //<retries>
                    if(message.retries != null) {
                        sw.writeStartElement(null, 'retries', null);
                        sw.writeCharacters(String.valueOf(message.retries));
                        sw.writeEndElement();
                    }
                    //</retries>
                    //<validity>
                    if(message.validity != null) {
                        sw.writeStartElement(null, 'validity', null);
                        sw.writeCharacters(String.valueOf(message.validity));
                        sw.writeEndElement();
                    }
                    //</validity>
                    //<characterset>
                    if(String.isNotBlank(message.characterSet)) {
                        sw.writeStartElement(null, 'characterset', null);
                        sw.writeCharacters(message.characterSet);
                        sw.writeEndElement();
                    }
                    //</characterset>
                sw.writeEndElement();
                //</message>
            }
        sw.writeEndElement();
        //</messages>
        sw.writeEndDocument();
        serializedOutput = sw.getXmlString();
        sw.close();
        return serializedOutput;
    }
}