public with sharing class EsendexUtils {
    public static Map<Integer, String> FAILURE_DICTIONARY = new Map<Integer, String> {
        7 => 'We were unable to find a network to handle the destination of this message',
        12 => 'There is no recipient specified to whom we can send this message',
        4 => 'In order to send this message to this recipient, the recipient needs to have subscribed and no such subscription exists',
        13 => 'We received a message from the network when trying to send it to them and we were unable to retry or send it through another network',
        999 => 'An unspecified error has occurred when the network was processing the message',
        101 => 'The recipient of this message was not valid',
        16 => 'The recipient has a blockage in place which prevents receipt of this message',
        102 => 'The recipient\'s handset cannot support recipt of this message',
        199 => 'An unknown temporary issue has occurred after submitting this message to the network',
        200 => 'The recipient is temporarily unable to receive this message',
        6 => 'You do not have enough credit to send this message',
        8 => 'You have exceeded the maximum number of messages you can send per day through your account',
        17 => 'The network is blocking delivery of this message due to its content',
        0 => 'The failure reason is unavailable to us'
    };
    
    public static String stripPhoneNumber(String phoneNumber) {
        if(String.isNotBlank(phoneNumber)) {
            return phoneNumber.replaceAll('[^\\d.]', '');
        }
        return '';
    }
}